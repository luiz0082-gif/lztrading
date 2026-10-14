"""Gera MicroMomentum_v220.mq5 a partir de MicroMomentum_v210.mq5 aplicando patches exatos.

Cada patch exige que o trecho de origem exista exatamente uma vez; se a v2.10 mudar,
o script falha em vez de gerar um arquivo errado.

Uso (na raiz do repositorio):  python tools/micromomentum/make_v220.py
"""
SRC = r"MQL5/Experts/MicroMomentum/MicroMomentum_v210.mq5"
DST = r"MQL5/Experts/MicroMomentum/MicroMomentum_v220.mq5"

s = open(SRC, encoding="utf-8", newline="").read().replace("\r\n", "\n")


def rep(a, b, cnt=1):
    global s
    assert s.count(a) == cnt, (s.count(a), a)
    s = s.replace(a, b)


# ---------------------------------------------------------------- cabecalho
rep("//|                                                MicroMomentum.mq5 |",
    "//|                                           MicroMomentum_v220.mq5 |")
rep("Micro-Momentum Tick Scalper  v2.10       |", "Micro-Momentum Tick Scalper  v2.20       |")
rep('#property copyright   "MicroMomentum v2.10"', '#property copyright   "MicroMomentum v2.20"')
rep('#property version     "2.10"', '#property version     "2.20"')
rep('#property description "v2.10: anti-preso (escape no zero a zero) + contexto de tendencia leve."',
    '#property description "v2.10: anti-preso (escape no zero a zero) + contexto de tendencia leve."\n'
    '#property description "v2.20: filtros de entrada, pullback virtual, escape anti-slippage, telemetria MAE-tempo."')
rep('#define EA_VERSION "2.10"', '#define EA_VERSION "2.20"')

# ------------------------------------------------------------------- inputs
rep('input group "=== Risco & Filtros ==="', '''input group "=== v2.20 Filtros de entrada (0 / vazio = desligado) ==="
input int            InpMaxImpulsePts         = 0;         // Teto de impulso (pts): acima disso nao entra (anti-pico)
input string         InpBlockWindows          = "";        // Janelas sem entrada, hora do servidor: "HH:MM-HH:MM;HH:MM-HH:MM"
input double         InpStackGateMoney        = 0.0;       // Nao empilha se alguma posicao aberta estiver pior que -$ (liquido)
input int            InpStackMinGapMs         = 0;         // Intervalo minimo entre entradas com posicao aberta (ms)

input group "=== v2.20 Entrada por micro-pullback (ordem virtual, sem pendente) ==="
input bool           InpPullbackEntry         = false;     // Esperar recuo do impulso antes de entrar
input double         InpPullbackPct           = 30.0;      // Entra quando recuar N% do impulso desde o extremo
input double         InpPullbackInvalidPct    = 70.0;      // Cancela se recuar mais que N% (impulso morreu)
input int            InpPullbackWaitMs        = 1500;      // Cancela se nao recuar em N ms

input group "=== v2.20 Anti-slippage (reacao, sai no zero a zero) ==="
input int            InpSlipHighPts           = 0;         // Slippage de entrada >= N pts marca a posicao (0 = off)
input int            InpSlipEscapeSec         = 3;         // Escape mais cedo (s) para posicao marcada; exige InpEscapeSec > 0

input group "=== Risco & Filtros ==="''')

# -------------------------------------------------------------------- SPos
rep("   bool     ct;         // entrada contra a tendencia M1\n};", """   bool     ct;         // entrada contra a tendencia M1
   long     mae_ms;     // ms desde a abertura ate o pior ponto (pts)
   double   p1, p3, p5; // pts em ~1s/3s/5s apos a abertura (DBL_MAX = nao amostrado)
   double   e_imp;      // impulso (pts) na direcao da entrada
   double   e_pbwait, e_pbret; // espera (ms) e recuo (%) quando entrou por pullback (DBL_MAX = n/a)
   bool     slip_high;  // slippage de entrada >= InpSlipHighPts
};""")
rep("   p.ct = false;\n}", """   p.ct = false;
   p.mae_ms = -1; p.p1 = DBL_MAX; p.p3 = DBL_MAX; p.p5 = DBL_MAX;
   p.e_imp = DBL_MAX; p.e_pbwait = DBL_MAX; p.e_pbret = DBL_MAX; p.slip_high = false;
}""")

# --------------------------------------------------------- trades.csv (aditivo)
rep(',sl,tp,counter_trend";',
    ',sl,tp,counter_trend,mae_ms,pts_1s,pts_3s,pts_5s,entry_impulse_pts,pb_wait_ms,pb_retrace_pct,slip_high";')
rep('                     (p.ct ? "1" : "0"));', '''                     (p.ct ? "1" : "0") + "," + (p.mae_ms >= 0 ? I(p.mae_ms) : "") + "," + OptD(p.p1, 1) + "," + OptD(p.p3, 1) + "," +
                     OptD(p.p5, 1) + "," + OptD(p.e_imp, 1) + "," + OptD(p.e_pbwait, 0) + "," + OptD(p.e_pbret, 1) + "," +
                     (p.slip_high ? "1" : "0"));''')
rep("string I(const long v)                  { return IntegerToString(v); }",
    "string I(const long v)                  { return IntegerToString(v); }\n"
    "string OptD(const double v, const int dig) { return (v == DBL_MAX) ? \"\" : DoubleToString(v, dig); }")

# ----------------------------------------------------------------- globais
rep("bool          g_ctx_ct = false;\n", """bool          g_ctx_ct = false;
double        g_ctx_imp = DBL_MAX, g_ctx_pbwait = DBL_MAX, g_ctx_pbret = DBL_MAX;
long          g_last_entry_msc = 0;

// v2.20: pullback virtual
bool          g_pb_on = false;
int           g_pb_dir = 0;
long          g_pb_t0 = 0;
double        g_pb_ext = 0, g_pb_base = 0;
SSig          g_pb_sig;
double        g_pb_fire_wait = DBL_MAX, g_pb_fire_pct = DBL_MAX;

// v2.20: janelas sem entrada (minutos do dia, hora do servidor)
int           g_win_n = 0;
int           g_win_s[];
int           g_win_e[];
""")

# ---------------------------------------------------- contexto da entrada
rep("         g_ctx_lat    = lat;\n", """         g_ctx_lat    = lat;
         g_ctx_imp    = (dir > 0) ? s.up : s.dn;
         g_ctx_pbwait = g_pb_fire_wait;
         g_ctx_pbret  = g_pb_fire_pct;
""")
rep("      g_pos[k].ct = g_ctx_ct;\n      g_ctx_valid = false;", """      g_pos[k].ct = g_ctx_ct;
      g_pos[k].e_imp = g_ctx_imp; g_pos[k].e_pbwait = g_ctx_pbwait; g_pos[k].e_pbret = g_ctx_pbret;
      g_pos[k].slip_high = (InpSlipHighPts > 0 && g_ctx_slip >= InpSlipHighPts);
      g_ctx_valid = false;""")

# --------------------------------------------- tempo do MAE e pts em 1/3/5 s
rep("      if(g_pos[k].pts < g_pos[k].trough_pts) g_pos[k].trough_pts = g_pos[k].pts;", """      if(g_pos[k].pts < g_pos[k].trough_pts)
      {
         g_pos[k].trough_pts = g_pos[k].pts;
         g_pos[k].mae_ms = g_tick.time_msc - g_pos[k].open_msc;
      }
      long age = g_tick.time_msc - g_pos[k].open_msc;
      if(g_pos[k].p1 == DBL_MAX && age >= 1000 && age <= 3000) g_pos[k].p1 = g_pos[k].pts;
      if(g_pos[k].p3 == DBL_MAX && age >= 3000 && age <= 5000) g_pos[k].p3 = g_pos[k].pts;
      if(g_pos[k].p5 == DBL_MAX && age >= 5000 && age <= 7000) g_pos[k].p5 = g_pos[k].pts;""")

# ------------------------------------------------------ filtros em TryEntry
rep("   g_ctx_ct = ct;\n", """   // v2.20: filtros de entrada (todos desligados por padrao)
   double mvv = (s.dir > 0) ? s.up : s.dn;
   if(skip == "" && InpMaxImpulsePts > 0 && mvv > InpMaxImpulsePts) skip = "impulso_excessivo";
   if(skip == "" && InBlockWindow()) skip = "janela_bloqueada";
   if(skip == "" && InpStackGateMoney > 0)
   {
      for(int q = 0; q < ArraySize(g_pos); q++)
         if(g_pos[q].seen && g_pos[q].net <= -InpStackGateMoney) { skip = "pilha_posicao_negativa"; break; }
   }
   if(skip == "" && InpStackMinGapMs > 0 && g_own_count > 0 && g_last_entry_msc > 0 &&
      g_tick.time_msc - g_last_entry_msc < InpStackMinGapMs) skip = "pilha_intervalo";
   g_ctx_ct = ct;
""")
rep("      g_trades_candle++;\n", "      g_trades_candle++;\n      g_last_entry_msc = g_tick.time_msc;\n")

rep("void TryEntry(const SSig &s)\n{", """//--- janelas sem entrada: "HH:MM-HH:MM;HH:MM-HH:MM" (hora do servidor; fim exclusivo; aceita virada de dia)
bool ParseWindows()
{
   g_win_n = 0;
   ArrayResize(g_win_s, 0);
   ArrayResize(g_win_e, 0);
   string txt = InpBlockWindows;
   StringTrimLeft(txt); StringTrimRight(txt);
   if(txt == "") return true;

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
      ArrayResize(g_win_s, g_win_n + 1);
      ArrayResize(g_win_e, g_win_n + 1);
      g_win_s[g_win_n] = s0;
      g_win_e[g_win_n] = e0;
      g_win_n++;
   }
   return true;
}

bool InBlockWindow()
{
   if(g_win_n == 0) return false;
   MqlDateTime d;
   TimeToStruct(TimeTradeServer(), d);
   int m = d.hour * 60 + d.min;
   for(int i = 0; i < g_win_n; i++)
   {
      if(g_win_s[i] < g_win_e[i]) { if(m >= g_win_s[i] && m < g_win_e[i]) return true; }
      else                        { if(m >= g_win_s[i] || m < g_win_e[i]) return true; }
   }
   return false;
}

void TryEntry(const SSig &s)
{""")

# ---------------------------------------------------- pullback virtual
rep("      g_cooldown_until = g_tick.time_msc + MathMax(InpCooldownMs, 1000);\n   }\n}\n", """      g_cooldown_until = g_tick.time_msc + MathMax(InpCooldownMs, 1000);
   }
}

//+------------------------------------------------------------------+
//| v2.20: entrada por micro-pullback (ordem virtual)                |
//| Em vez de entrar no fim do impulso, arma e espera recuar N% do   |
//| impulso. Cancela se recuar demais ou se o tempo acabar.          |
//+------------------------------------------------------------------+
void PbCancel(const string why)
{
   if(!g_pb_on) return;
   LogSignal(g_pb_sig, "SKIP", why);
   g_pb_on = false;
}

void PullbackStep()
{
   if(g_pb_on)
   {
      if(g_state != ST_SCANNING) { PbCancel("pullback_cancelado_estado"); return; }

      double bid = g_tick.bid;
      if(g_pb_dir > 0) { if(bid > g_pb_ext) g_pb_ext = bid; }
      else             { if(bid < g_pb_ext) g_pb_ext = bid; }

      double range = (g_pb_dir > 0) ? (g_pb_ext - g_pb_base) : (g_pb_base - g_pb_ext);
      double retr  = (g_pb_dir > 0) ? (g_pb_ext - bid)       : (bid - g_pb_ext);
      double pct   = (range > 0) ? retr / range * 100.0 : 0.0;
      long   el    = g_tick.time_msc - g_pb_t0;

      if(pct > InpPullbackInvalidPct) { PbCancel("pullback_invalidado"); return; }
      if(el > InpPullbackWaitMs)      { PbCancel("pullback_expirou");    return; }
      if(pct >= InpPullbackPct)
      {
         SSig s = g_pb_sig;
         s.dir = g_pb_dir;
         g_pb_on = false;
         g_pb_fire_wait = (double)el;
         g_pb_fire_pct  = pct;
         TryEntry(s);
         g_pb_fire_wait = DBL_MAX;
         g_pb_fire_pct  = DBL_MAX;
      }
      return;
   }

   if(g_state == ST_SCANNING && g_sig.dir != 0)
   {
      g_pb_on   = true;
      g_pb_dir  = g_sig.dir;
      g_pb_t0   = g_tick.time_msc;
      g_pb_sig  = g_sig;
      g_pb_ext  = g_tick.bid;
      g_pb_base = (g_sig.dir > 0) ? g_tick.bid - g_sig.up * g_point : g_tick.bid + g_sig.dn * g_point;
      LogSignal(g_sig, "WAIT", "aguarda_pullback");
   }
}

void EntryFlow()
{
   if(!InpPullbackEntry)
   {
      if(g_state == ST_SCANNING && g_sig.dir != 0) TryEntry(g_sig);
      return;
   }
   if(g_pb_on && g_sig.dir == -g_pb_dir) PbCancel("pullback_sinal_oposto");
   PullbackStep();
}
""")

# ------------------------------------------------- escape anti-slippage
rep("""         int esc = (g_pos[k].ct && InpCTEscapeSec > 0) ? InpCTEscapeSec : InpEscapeSec;
         if(hold >= (long)esc * 1000 && g_pos[k].trough_net <= -InpEscapeArmMoney && net >= InpEscapeMinMoney)
            why = g_pos[k].ct ? "ESCAPE_CT" : "ESCAPE";""", """         int esc = (g_pos[k].ct && InpCTEscapeSec > 0) ? InpCTEscapeSec : InpEscapeSec;
         bool slip_fast = (g_pos[k].slip_high && InpSlipEscapeSec > 0 && InpSlipEscapeSec < esc);
         if(slip_fast) esc = InpSlipEscapeSec;
         if(hold >= (long)esc * 1000 && g_pos[k].trough_net <= -InpEscapeArmMoney && net >= InpEscapeMinMoney)
            why = slip_fast ? "ESCAPE_SLIP" : (g_pos[k].ct ? "ESCAPE_CT" : "ESCAPE");""")

# ------------------------------------------------------------------ OnTick
rep("   if(g_state == ST_SCANNING && g_sig.dir != 0) TryEntry(g_sig);\n\n   LogTick(g_sig);",
    "   EntryFlow();\n\n   LogTick(g_sig);")

# ---------------------------------------------------------- validacao e log
rep('   if(InpCTImpulseMult < 1.0)          err = "Multiplicador contra-tendencia deve ser >= 1";', '''   if(InpCTImpulseMult < 1.0)          err = "Multiplicador contra-tendencia deve ser >= 1";
   if(InpMaxImpulsePts < 0 || (InpMaxImpulsePts > 0 && InpMaxImpulsePts < InpMinPointsDisplacement))
                                       err = "Teto de impulso deve ser 0 (off) ou >= impulso minimo";
   if(InpStackGateMoney < 0 || InpStackMinGapMs < 0) err = "Porteira de empilhamento nao pode ser negativa";
   if(InpPullbackPct <= 0 || InpPullbackPct >= 100 || InpPullbackInvalidPct <= InpPullbackPct || InpPullbackInvalidPct > 100)
                                       err = "Pullback: 0 < pct < invalido <= 100";
   if(InpPullbackWaitMs <= 0)          err = "Pullback: espera deve ser > 0 ms";
   if(InpSlipHighPts < 0 || InpSlipEscapeSec < 0) err = "Anti-slippage nao pode ser negativo";
   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";''')
rep('   LogParam("InpRetries", I(InpRetries));', '''   LogParam("InpRetries", I(InpRetries));
   LogParam("InpMaxImpulsePts", I(InpMaxImpulsePts));
   LogParam("InpBlockWindows", InpBlockWindows);
   LogParam("InpStackGateMoney", D(InpStackGateMoney, 2));
   LogParam("InpStackMinGapMs", I(InpStackMinGapMs));
   LogParam("InpPullbackEntry", (string)InpPullbackEntry);
   LogParam("InpPullbackPct", D(InpPullbackPct, 1));
   LogParam("InpPullbackInvalidPct", D(InpPullbackInvalidPct, 1));
   LogParam("InpPullbackWaitMs", I(InpPullbackWaitMs));
   LogParam("InpSlipHighPts", I(InpSlipHighPts));
   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));''')

open(DST, "w", encoding="utf-8", newline="").write(s.replace("\n", "\r\n"))
print("ok", len(s))
