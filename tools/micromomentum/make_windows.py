"""Gera as versoes com HORARIOS PERMITIDOS (whitelist):
    v2.50 = v2.30 (reacao precoce, entrada a mercado)  + janelas permitidas
    v2.60 = v2.40.1 (ordem pendente real)               + janelas permitidas

O EA so abre NOVAS entradas dentro das janelas permitidas; fora delas o estado vira BLOCK_SESSION
("fora das janelas permitidas"), ordens pendentes sao canceladas e posicoes abertas continuam gerenciadas.
As janelas sao lidas em UTC (TimeGMT) por padrao, para o horario de verao do servidor nao deslocar o filtro;
pode-se escolher hora do servidor.

Cada patch exige o trecho de origem exatamente uma vez.
Uso (raiz do repositorio):  python tools/micromomentum/make_windows.py
"""
import re

D = "MQL5/Experts/MicroMomentum/"
JOBS = [(D + "MicroMomentum_v230.mq5", D + "MicroMomentum_v250.mq5", "2.50", "v230", "v250",
         "v2.50: horarios permitidos (whitelist em UTC) sobre a v2.30 (reacao precoce)."),
        (D + "MicroMomentum_v240.mq5", D + "MicroMomentum_v260.mq5", "2.60", "v240", "v260",
         "v2.60: horarios permitidos (whitelist em UTC) sobre a v2.40.1 (ordem pendente real).")]


def patch(src, dst, ver, old_tag, new_tag, desc):
    s = open(src, encoding="utf-8", newline="").read().replace("\r\n", "\n")

    def rep(a, b, cnt=1):
        nonlocal s
        assert s.count(a) == cnt, (dst, s.count(a), a[:70])
        s = s.replace(a, b)

    # ---- cabecalho e versao
    s, n1 = re.subn(r"MicroMomentum_%s\.mq5" % old_tag, "MicroMomentum_%s.mq5" % new_tag, s)
    assert n1 == 1, (dst, "arquivo no cabecalho", n1)
    s, n2 = re.subn(r"Tick Scalper  v2\.\d\d       \|", "Tick Scalper  v%s       |" % ver, s)
    assert n2 == 1, (dst, "versao no cabecalho", n2)
    s, n3 = re.subn(r'#property copyright   "MicroMomentum v[0-9.]+"', '#property copyright   "MicroMomentum v%s"' % ver, s)
    assert n3 == 1
    s, n4 = re.subn(r'#property version     "[0-9.]+"', '#property version     "%s"' % ver, s)
    assert n4 == 1
    s, n5 = re.subn(r'#define EA_VERSION "[0-9.]+"', '#define EA_VERSION "%s"' % ver, s)
    assert n5 == 1
    rep('#property description "Telemetria CSV append-only por sessao. Painel HUD com controles."',
        '#property description "%s"\n#property description "Telemetria CSV append-only por sessao. Painel HUD com controles."' % desc)

    # ---- enum da base de tempo
    rep("enum ENUM_EA_STATE", """enum ENUM_TIME_BASE
{
   TB_UTC    = 0, // UTC (TimeGMT): nao muda com o horario de verao do servidor
   TB_SERVER = 1  // Hora do servidor (TimeTradeServer)
};

enum ENUM_EA_STATE""")

    # ---- inputs (menu proprio)
    rep('input group "=== Risco & Filtros ==="', '''input group "=== v2.50 Horarios permitidos (so opera dentro das janelas) ==="
input bool           InpAllowWindowsEnable    = false;     // Ligar a lista de horarios permitidos
input ENUM_TIME_BASE InpAllowTimeBase         = TB_UTC;    // Base de tempo das janelas
input string         InpAllowWindows          = "";        // Janelas permitidas "HH:MM-HH:MM;HH:MM-HH:MM" (fim exclusivo; aceita virada de dia)

input group "=== Risco & Filtros ==="''')

    # ---- globais
    rep("long          g_last_entry_msc = 0;\n", """long          g_last_entry_msc = 0;

// horarios permitidos (minutos do dia na base escolhida)
int           g_aw_n = 0;
int           g_aw_s[];
int           g_aw_e[];
""")

    # ---- funcoes (antes de ComputeState)
    rep("ENUM_EA_STATE ComputeState(string &why)\n{", """//--- lista de janelas "HH:MM-HH:MM;..." -> minutos do dia
bool ParseAllowWindows()
{
   g_aw_n = 0;
   ArrayResize(g_aw_s, 0);
   ArrayResize(g_aw_e, 0);
   string txt = InpAllowWindows;
   StringTrimLeft(txt); StringTrimRight(txt);
   if(txt == "") return false;

   string parts[];
   int n = StringSplit(txt, ';', parts);
   for(int i = 0; i < n; i++)
   {
      StringTrimLeft(parts[i]); StringTrimRight(parts[i]);
      if(parts[i] == "") continue;
      string hh[];
      if(StringSplit(parts[i], '-', hh) != 2) return false;
      string a[], b[];
      if(StringSplit(hh[0], ':', a) != 2 || StringSplit(hh[1], ':', b) != 2) return false;
      int s0 = (int)StringToInteger(a[0]) * 60 + (int)StringToInteger(a[1]);
      int e0 = (int)StringToInteger(b[0]) * 60 + (int)StringToInteger(b[1]);
      if(s0 < 0 || s0 > 1439 || e0 < 0 || e0 > 1439 || s0 == e0) return false;
      ArrayResize(g_aw_s, g_aw_n + 1);
      ArrayResize(g_aw_e, g_aw_n + 1);
      g_aw_s[g_aw_n] = s0;
      g_aw_e[g_aw_n] = e0;
      g_aw_n++;
   }
   return (g_aw_n > 0);
}

bool InAllowWindow()
{
   if(!InpAllowWindowsEnable) return true;
   datetime t = (InpAllowTimeBase == TB_UTC) ? TimeGMT() : TimeTradeServer();
   MqlDateTime d;
   TimeToStruct(t, d);
   int m = d.hour * 60 + d.min;
   for(int i = 0; i < g_aw_n; i++)
   {
      if(g_aw_s[i] < g_aw_e[i]) { if(m >= g_aw_s[i] && m < g_aw_e[i]) return true; }
      else                      { if(m >= g_aw_s[i] || m < g_aw_e[i]) return true; }
   }
   return false;
}

ENUM_EA_STATE ComputeState(string &why)
{""")

    # ---- estado: fora das janelas = BLOCK_SESSION
    rep("   if(g_own_count >= InpMaxOpenPositions) { why = \"limite de posicoes abertas\"; return ST_IN_POSITION; }\n",
        """   if(InpAllowWindowsEnable && !InAllowWindow())
   {
      why = "fora das janelas permitidas (" + (InpAllowTimeBase == TB_UTC ? "UTC" : "servidor") + " " + InpAllowWindows + ")";
      return ST_BLOCK_SESSION;
   }

   if(g_own_count >= InpMaxOpenPositions) { why = "limite de posicoes abertas"; return ST_IN_POSITION; }
""")

    # ---- validacao e log
    rep('   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";',
        '   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";\n'
        '   if(InpAllowWindowsEnable && !ParseAllowWindows()) err = "InpAllowWindows vazio ou invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";')
    rep('   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));',
        '''   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));
   LogParam("InpAllowWindowsEnable", (string)InpAllowWindowsEnable);
   LogParam("InpAllowTimeBase", EnumToString(InpAllowTimeBase));
   LogParam("InpAllowWindows", InpAllowWindows);
   LogParam("server_minus_gmt_sec", I((long)(TimeTradeServer() - TimeGMT())));''')

    open(dst, "w", encoding="utf-8", newline="").write(s.replace("\n", "\r\n"))
    print("ok", dst, len(s))


for j in JOBS:
    patch(*j)
