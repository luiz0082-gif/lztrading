"""Gera MicroMomentum_v230.mq5 (reacao precoce ao caminho) a partir da v2.20.

Cada patch exige o trecho de origem exatamente uma vez.
Uso (raiz do repositorio):  python tools/micromomentum/make_v230.py
"""
SRC = r"MQL5/Experts/MicroMomentum/MicroMomentum_v220.mq5"
DST = r"MQL5/Experts/MicroMomentum/MicroMomentum_v230.mq5"

s = open(SRC, encoding="utf-8", newline="").read().replace("\r\n", "\n")


def rep(a, b, cnt=1):
    global s
    assert s.count(a) == cnt, (s.count(a), a)
    s = s.replace(a, b)


# ---------------------------------------------------------------- cabecalho
rep("//|                                           MicroMomentum_v220.mq5 |",
    "//|                                           MicroMomentum_v230.mq5 |")
rep("Micro-Momentum Tick Scalper  v2.20       |", "Micro-Momentum Tick Scalper  v2.30       |")
rep('#property copyright   "MicroMomentum v2.20"', '#property copyright   "MicroMomentum v2.30"')
rep('#property version     "2.20"', '#property version     "2.30"')
rep('#property description "v2.20: filtros de entrada, pullback virtual, escape anti-slippage, telemetria MAE-tempo."',
    '#property description "v2.20: filtros de entrada, pullback virtual, escape anti-slippage, telemetria MAE-tempo."\n'
    '#property description "v2.30: reacao precoce ao caminho (marca a posicao fraca aos N ms; sem stop)."')
rep('#define EA_VERSION "2.20"', '#define EA_VERSION "2.30"')

# ------------------------------------------------------------------- inputs
rep('input group "=== Risco & Filtros ==="', '''input group "=== v2.30 Reacao precoce ao caminho (sem stop) ==="
input bool           InpEarlyEnable           = false;     // Avaliar o caminho da posicao aos N ms
input int            InpEarlyCheckMs          = 5000;      // Instante da avaliacao (ms apos a abertura)
input int            InpEarlyWeakPts          = 60;        // Fraca se estiver pior que -N pts na avaliacao
input bool           InpEarlyExitEnable       = true;      // Posicao fraca sai assim que o liquido voltar ao limiar abaixo
input double         InpEarlyExitMoney        = 0.00;      // Liquido minimo p/ a saida antecipada ($; 0 = zero a zero)
input bool           InpEarlyBlockEntries     = false;     // Sem novas entradas enquanto houver posicao fraca aberta

input group "=== Risco & Filtros ==="''')

# -------------------------------------------------------------------- SPos
rep("   bool     slip_high;  // slippage de entrada >= InpSlipHighPts\n};",
    "   bool     slip_high;  // slippage de entrada >= InpSlipHighPts\n"
    "   bool     early_checked; // v2.30: avaliacao precoce ja feita\n"
    "   bool     weak;          // v2.30: marcada fraca na avaliacao precoce\n"
    "   double   early_pts;     // v2.30: pts na avaliacao precoce (DBL_MAX = nao amostrado)\n};")
rep("p.e_imp = DBL_MAX; p.e_pbwait = DBL_MAX; p.e_pbret = DBL_MAX; p.slip_high = false;",
    "p.e_imp = DBL_MAX; p.e_pbwait = DBL_MAX; p.e_pbret = DBL_MAX; p.slip_high = false;\n"
    "   p.early_checked = false; p.weak = false; p.early_pts = DBL_MAX;")

# --------------------------------------------------------- trades.csv (aditivo)
rep(",pb_retrace_pct,slip_high\";", ",pb_retrace_pct,slip_high,early_pts,early_weak\";")
rep('                     (p.slip_high ? "1" : "0"));',
    '                     (p.slip_high ? "1" : "0") + "," + OptD(p.early_pts, 1) + "," + (p.weak ? "1" : "0"));')

# ----------------------------------------------------------------- globais
rep("long          g_last_entry_msc = 0;\n", "long          g_last_entry_msc = 0;\nint           g_weak_count = 0;   // v2.30: posicoes abertas marcadas fracas\n")

# ----------------------------------------------- avaliacao precoce (SyncPositions)
rep("   g_own_count = 0; g_own_buy = 0; g_own_sell = 0; g_float = 0;\n",
    "   g_own_count = 0; g_own_buy = 0; g_own_sell = 0; g_float = 0; g_weak_count = 0;\n")
rep("      if(g_pos[k].p5 == DBL_MAX && age >= 5000 && age <= 7000) g_pos[k].p5 = g_pos[k].pts;",
    """      if(g_pos[k].p5 == DBL_MAX && age >= 5000 && age <= 7000) g_pos[k].p5 = g_pos[k].pts;

      // v2.30: avaliacao precoce do caminho (uma vez por posicao, janela de 2,5 s apos o instante)
      if(InpEarlyEnable && !g_pos[k].early_checked && age >= InpEarlyCheckMs)
      {
         g_pos[k].early_checked = true;
         if(age <= InpEarlyCheckMs + 2500)
         {
            g_pos[k].early_pts = g_pos[k].pts;
            if(g_pos[k].pts <= -InpEarlyWeakPts)
            {
               g_pos[k].weak = true;
               LogEvent("WARN", "EARLY_WEAK", "ticket=" + I((long)g_pos[k].ticket) + " pts=" + D(g_pos[k].pts, 1) +
                        " aos " + I(age) + "ms net=" + Sg(g_pos[k].net));
            }
         }
      }
      if(g_pos[k].weak) g_weak_count++;""")

# ------------------------------------------------------------ bloqueio de entrada
rep('      g_tick.time_msc - g_last_entry_msc < InpStackMinGapMs) skip = "pilha_intervalo";\n',
    '      g_tick.time_msc - g_last_entry_msc < InpStackMinGapMs) skip = "pilha_intervalo";\n'
    '   if(skip == "" && InpEarlyEnable && InpEarlyBlockEntries && g_weak_count > 0) skip = "reacao_precoce_bloqueio";\n')

# ------------------------------------------------------------ saida antecipada
rep("      // tempo maximo (opcional): tambem so fecha no zero a zero ou lucro\n",
    """      // v2.30 REACAO PRECOCE: posicao marcada fraca sai assim que o liquido chegar ao limiar (nunca no negativo se limiar >= 0)
      if(why == "" && InpEarlyEnable && InpEarlyExitEnable && g_pos[k].weak && net >= InpEarlyExitMoney)
         why = "ESCAPE_EARLY";

      // tempo maximo (opcional): tambem so fecha no zero a zero ou lucro
""")

# ---------------------------------------------------------- validacao e log
rep('   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";',
    '   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";\n'
    '   if(InpEarlyCheckMs < 1000 || InpEarlyWeakPts <= 0) err = "Reacao precoce: check >= 1000 ms e pts fraca > 0";')
rep('   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));',
    '''   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));
   LogParam("InpEarlyEnable", (string)InpEarlyEnable);
   LogParam("InpEarlyCheckMs", I(InpEarlyCheckMs));
   LogParam("InpEarlyWeakPts", I(InpEarlyWeakPts));
   LogParam("InpEarlyExitEnable", (string)InpEarlyExitEnable);
   LogParam("InpEarlyExitMoney", D(InpEarlyExitMoney, 2));
   LogParam("InpEarlyBlockEntries", (string)InpEarlyBlockEntries);''')

open(DST, "w", encoding="utf-8", newline="").write(s.replace("\n", "\r\n"))
print("ok", len(s))
