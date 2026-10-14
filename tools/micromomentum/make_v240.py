"""Gera MicroMomentum_v240.mq5 (ordem pendente real) a partir da v2.20.

Cada patch exige o trecho de origem exatamente uma vez.
Uso (raiz do repositorio):  python tools/micromomentum/make_v240.py
"""
SRC = r"MQL5/Experts/MicroMomentum/MicroMomentum_v220.mq5"
DST = r"MQL5/Experts/MicroMomentum/MicroMomentum_v240.mq5"

s = open(SRC, encoding="utf-8", newline="").read().replace("\r\n", "\n")


def rep(a, b, cnt=1):
    global s
    assert s.count(a) == cnt, (s.count(a), a)
    s = s.replace(a, b)


# ---------------------------------------------------------------- cabecalho
rep("//|                                           MicroMomentum_v220.mq5 |",
    "//|                                           MicroMomentum_v240.mq5 |")
rep("Micro-Momentum Tick Scalper  v2.20       |", "Micro-Momentum Tick Scalper  v2.40       |")
rep('#property copyright   "MicroMomentum v2.20"', '#property copyright   "MicroMomentum v2.40"')
rep('#property version     "2.20"', '#property version     "2.40"')
rep('#property description "v2.20: filtros de entrada, pullback virtual, escape anti-slippage, telemetria MAE-tempo."',
    '#property description "v2.20: filtros de entrada, pullback virtual, escape anti-slippage, telemetria MAE-tempo."\n'
    '#property description "v2.40: ordem pendente REAL (limit no recuo ou stop na continuacao), cancelada em ms se o movimento mudar."')
rep('#define EA_VERSION "2.20"', '#define EA_VERSION "2.40.2"')

# --------------------------------------------------------------------- enum
rep("enum ENUM_EA_STATE", """enum ENUM_PEND_MODE
{
   PEND_LIMIT = 0, // LIMIT: espera o recuo do impulso (preco melhor, sem slippage)
   PEND_STOP  = 1  // STOP: confirma a continuacao (entra so se o movimento seguir)
};

enum ENUM_EA_STATE""")

# ------------------------------------------------------------------- inputs
rep('input group "=== Risco & Filtros ==="', '''input group "=== v2.40 Ordem pendente real (substitui a entrada a mercado) ==="
input bool           InpPendEnable            = false;     // Entrar por ordem pendente real
input ENUM_PEND_MODE InpPendMode              = PEND_LIMIT; // Tipo da pendente
input double         InpPendLimitPct          = 30.0;      // LIMIT: recuo de N% do impulso a partir do preco atual
input int            InpPendMinOffsetPts      = 8;         // LIMIT: recuo minimo (pts)
input int            InpPendStopPts           = 10;        // STOP: distancia alem do preco atual (pts)
input int            InpPendTtlMs             = 1500;      // Cancela se nao preencher em N ms
input int            InpPendCancelPts         = 40;        // LIMIT: cancela se o preco fugir N pts alem do extremo | STOP: cancela se recuar N pts do extremo
input int            InpPendRearmMs           = 300;       // Intervalo minimo entre duas pendentes (ms)
input int            InpPendSafetyExpirySec   = 180;       // Expiracao de seguranca no servidor (s; 0 = GTC). O cancelamento real e do EA

input group "=== Risco & Filtros ==="''')

# ----------------------------------------------------------------- globais
rep("long          g_last_entry_msc = 0;\n", """long          g_last_entry_msc = 0;

// v2.40: ordem pendente real (no maximo uma por vez)
bool          g_pend_on = false;
ulong         g_pend_ticket = 0;
int           g_pend_dir = 0;
double        g_pend_price = 0, g_pend_vol = 0, g_pend_ext = 0, g_pend_ext0 = 0, g_pend_spread = 0;
long          g_pend_t0 = 0, g_pend_next_ms = 0;
ulong         g_pend_lat = 0;
bool          g_pend_ct = false;
SSig          g_pend_sig;
bool          g_pend_gtc = false;   // a corretora recusou expiracao: usar GTC
""")

# ------------------------------- posicao preenchida pela pendente: contexto de entrada
rep("   if(g_ctx_valid && GetTickCount64() - g_ctx_ms < 5000)\n",
    """   if(g_pend_on && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == g_pend_ticket)
   {
      bool pbuy = (g_pos[k].type == POSITION_TYPE_BUY);
      g_pos[k].e_up = g_pend_sig.up; g_pos[k].e_dn = g_pend_sig.dn; g_pos[k].e_n = g_pend_sig.n;
      g_pos[k].e_spread = g_pend_spread;
      g_pos[k].e_slip = pbuy ? (g_pos[k].open_price - g_pend_price) / g_point : (g_pend_price - g_pos[k].open_price) / g_point;
      g_pos[k].e_lat = g_pend_lat;
      g_pos[k].ct = g_pend_ct;
      g_pos[k].e_imp = pbuy ? g_pend_sig.up : g_pend_sig.dn;
      g_pos[k].e_pbwait = (double)(g_pos[k].open_msc - g_pend_t0);   // pb_wait_ms = espera ate o preenchimento
      g_pos[k].slip_high = (InpSlipHighPts > 0 && g_pos[k].e_slip >= InpSlipHighPts);
      g_trades_candle++;
      g_last_entry_msc = g_tick.time_msc;
      g_cooldown_until = g_tick.time_msc + InpCooldownMs;
      LogEvent("INFO", "PEND_FILLED", "ticket=" + I((long)tk) + " preco_ordem=" + D(g_pend_price, _Digits) +
               " preenchido=" + D(g_pos[k].open_price, _Digits) + " slip_pts=" + D(g_pos[k].e_slip, 1) +
               " espera_ms=" + I((long)g_pos[k].e_pbwait));
      g_pend_on = false;
      g_ctx_valid = false;
   }
   else if(g_ctx_valid && GetTickCount64() - g_ctx_ms < 5000)
""")

# ------------------------------------------------- TryEntry: troca a mercado por pendente
rep("void TryEntry(const SSig &s)\n{", "void PendPlace(const SSig &s, const double vol);\n\nvoid TryEntry(const SSig &s)\n{")
rep('   LogSignal(s, "ENTER", ct ? "ok_contra_tendencia" : "ok");\n   if(SendMarket(s.dir, vol, s))',
    '   if(InpPendEnable) { PendPlace(s, vol); return; }\n\n'
    '   LogSignal(s, "ENTER", ct ? "ok_contra_tendencia" : "ok");\n   if(SendMarket(s.dir, vol, s))')

# ------------------------------------------------- pendente: colocar e gerenciar
rep("void EntryFlow()\n{\n   if(!InpPullbackEntry)", '''//+------------------------------------------------------------------+
//| v2.40: ordem pendente real                                       |
//| LIMIT: ordem no preco do recuo esperado (preenche no preco da    |
//|        ordem ou melhor, sem slippage de entrada).                |
//| STOP : ordem alem do preco atual; so executa se o movimento      |
//|        continuar.                                                |
//| A ordem fica no servidor; o EA cancela em ms se o movimento      |
//| mudar (TTL, fuga, recuo, sinal oposto, bloqueio).                |
//+------------------------------------------------------------------+
double PendTickRound(const double price)
{
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) ts = g_point;
   return NormalizeDouble(MathRound(price / ts) * ts, _Digits);
}

void PendPlace(const SSig &s, const double vol)
{
   if(g_pend_on) return;

   int    dir = s.dir;
   double pt  = g_point;
   double ask = g_tick.ask, bid = g_tick.bid;
   double lvl = MathMax((double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL),
                        (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL)) * pt;
   double imp = (dir > 0) ? s.up : s.dn;
   double price = 0;
   ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY_LIMIT;

   if(InpPendMode == PEND_LIMIT)
   {
      double off = MathMax((double)InpPendMinOffsetPts, imp * InpPendLimitPct / 100.0) * pt;
      if(dir > 0) { price = MathMin(ask - off, ask - lvl - pt); ot = ORDER_TYPE_BUY_LIMIT; }
      else        { price = MathMax(bid + off, bid + lvl + pt); ot = ORDER_TYPE_SELL_LIMIT; }
   }
   else
   {
      double off = (double)InpPendStopPts * pt;
      if(dir > 0) { price = MathMax(ask + off, ask + lvl + pt); ot = ORDER_TYPE_BUY_STOP; }
      else        { price = MathMin(bid - off, bid - lvl - pt); ot = ORDER_TYPE_SELL_STOP; }
   }
   price = PendTickRound(price);

   // TP/SL do servidor ancorados no preco da ordem
   double tp = 0, sl = 0, tpd = 0, sld = 0;
   if(InpServerSideStops)
   {
      if(InpTPMode == EXIT_POINTS)      tpd = InpTPPoints * pt;
      else if(InpTPMode == EXIT_MONEY)  tpd = MoneyToDist(InpTPMoney, vol);
      if(InpSLMode == EXIT_POINTS)      sld = InpSLPoints * pt;
      else if(InpSLMode == EXIT_MONEY)  sld = MoneyToDist(InpSLMoney, vol);
      if(dir > 0) { if(tpd > 0) tp = price + tpd; if(sld > 0) sl = price - sld; }
      else        { if(tpd > 0) tp = price - tpd; if(sld > 0) sl = price + sld; }
      if(tp > 0) tp = PendTickRound(tp);
      if(sl > 0) sl = PendTickRound(sl);
   }

   // expiracao no servidor so como rede de seguranca (o cancelamento real e do EA, em ms).
   // Corretoras exigem folga minima: o padrao e 180 s; se recusar (10022) cai para GTC e o EA limpa as pendentes proprias.
   ENUM_ORDER_TYPE_TIME tt = ORDER_TIME_GTC;
   datetime exp = 0;
   if(!g_pend_gtc && InpPendSafetyExpirySec > 0 &&
      (SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_MODE) & SYMBOL_EXPIRATION_SPECIFIED) != 0)
   {
      tt  = ORDER_TIME_SPECIFIED;
      exp = TimeTradeServer() + (datetime)InpPendSafetyExpirySec;
   }

   LogSignal(s, "WAIT", InpPendMode == PEND_LIMIT ? "pendente_limit" : "pendente_stop");

   ENUM_ORDER_TYPE_FILLING fills[3] = { ORDER_FILLING_RETURN, ORDER_FILLING_IOC, ORDER_FILLING_FOK };
   bool done = false;
   uint rc = 0;
   ulong lat = 0;
   for(int f = 0; f < 3; f++)
   {
      m_trade.SetTypeFilling(fills[f]);
      for(int rp = 0; rp < 2; rp++)
      {
         ulong t0 = GetMicrosecondCount();
         bool sent = false;
         switch(ot)
         {
            case ORDER_TYPE_BUY_LIMIT:  sent = m_trade.BuyLimit(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PBUY");  break;
            case ORDER_TYPE_SELL_LIMIT: sent = m_trade.SellLimit(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PSELL"); break;
            case ORDER_TYPE_BUY_STOP:   sent = m_trade.BuyStop(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PBUY");   break;
            default:                    sent = m_trade.SellStop(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PSELL");  break;
         }
         lat = GetMicrosecondCount() - t0;
         rc  = m_trade.ResultRetcode();
         done = (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_PLACED);
         LogOrder("PEND_OPEN", dir, vol, price, sl, tp, f, done, lat,
                  EnumToString(ot) + " fill=" + EnumToString(fills[f]) + " tt=" + EnumToString(tt) + (sent ? "" : " send_failed"));
         if(done) break;
         if(rc == TRADE_RETCODE_INVALID_EXPIRATION && tt != ORDER_TIME_GTC)
         {
            tt = ORDER_TIME_GTC; exp = 0; g_pend_gtc = true;
            LogEvent("WARN", "PEND_EXPIRY_FALLBACK", "corretora recusou a expiracao (10022); usando GTC. O EA cancela e limpa as pendentes proprias.");
            continue;   // repete o mesmo preenchimento sem expiracao
         }
         break;
      }
      if(done || rc != TRADE_RETCODE_INVALID_FILL) break;   // so tenta outro filling se o erro for de filling
   }
   m_trade.SetTypeFillingBySymbol(_Symbol);

   if(!done)
   {
      LogEvent("ERROR", "PEND_REJECTED", "retcode=" + I((long)rc) + " " + m_trade.ResultRetcodeDescription() +
               " tipo=" + EnumToString(ot) + " preco=" + D(price, _Digits));
      g_pend_next_ms = g_tick.time_msc + MathMax(InpPendRearmMs, 1000);
      return;
   }

   g_pend_on     = true;
   g_pend_ticket = m_trade.ResultOrder();
   g_pend_dir    = dir;
   g_pend_price  = price;
   g_pend_vol    = vol;
   g_pend_t0     = g_tick.time_msc;
   g_pend_ext    = bid;
   g_pend_ext0   = bid;
   g_pend_lat    = lat;
   g_pend_spread = g_spread;
   g_pend_ct     = g_ctx_ct;
   g_pend_sig    = s;
   LogEvent("INFO", "PEND_PLACED", "ticket=" + I((long)g_pend_ticket) + " " + EnumToString(ot) + " @ " + D(price, _Digits) +
            " tp=" + D(tp, _Digits) + " ttl=" + I(InpPendTtlMs) + "ms lat_us=" + I((long)lat));
}

//--- apaga pendentes proprias (simbolo + magic): ao ligar (sobras de queda) e ao desligar o EA
void PendCleanup(const string why)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong tk = OrderGetTicket(i);
      if(tk == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC) != (long)InpMagicNumber) continue;
      long ty = OrderGetInteger(ORDER_TYPE);
      if(ty != ORDER_TYPE_BUY_LIMIT && ty != ORDER_TYPE_SELL_LIMIT && ty != ORDER_TYPE_BUY_STOP && ty != ORDER_TYPE_SELL_STOP) continue;
      bool ok = m_trade.OrderDelete(tk);
      LogEvent("INFO", "PEND_CLEANUP", "ticket=" + I((long)tk) + " motivo=" + why + " ok=" + (ok ? "1" : "0") +
               " retcode=" + I((long)m_trade.ResultRetcode()));
   }
   g_pend_on = false;
}

bool PendHardBlock()
{
   return (g_state == ST_PAUSED || g_state == ST_BLOCK_TRADING || g_state == ST_BLOCK_GOAL ||
           g_state == ST_BLOCK_STOP || g_state == ST_BLOCK_LOSSES || g_state == ST_BLOCK_SESSION);
}

void PendManage()
{
   if(!g_pend_on) return;
   long age = g_tick.time_msc - g_pend_t0;

   if(!OrderSelect(g_pend_ticket))
   {
      // sumiu do servidor: preenchida, cancelada ou expirada
      string st = "desconhecido";
      long os = -1;
      if(HistoryOrderSelect(g_pend_ticket))
      {
         os = HistoryOrderGetInteger(g_pend_ticket, ORDER_STATE);
         st = EnumToString((ENUM_ORDER_STATE)os);
      }
      if(os == ORDER_STATE_FILLED && age < InpPendTtlMs + 5000) return;   // aguarda a posicao aparecer (AddPos limpa)
      LogEvent("INFO", "PEND_GONE", "ticket=" + I((long)g_pend_ticket) + " estado=" + st + " apos " + I(age) + "ms");
      g_pend_on = false;
      g_ctx_valid = false;
      g_pend_next_ms = g_tick.time_msc + InpPendRearmMs;
      return;
   }

   double bid = g_tick.bid;
   if(g_pend_dir > 0) { if(bid > g_pend_ext) g_pend_ext = bid; }
   else               { if(bid < g_pend_ext) g_pend_ext = bid; }

   string why = "";
   if(age >= InpPendTtlMs)                     why = "pend_ttl";
   else if(PendHardBlock())                    why = "pend_estado";
   else if(g_own_count >= InpMaxOpenPositions) why = "pend_limite_posicoes";
   else if(g_sig.dir == -g_pend_dir)           why = "pend_sinal_oposto";
   else if(InpPendMode == PEND_LIMIT)
   {
      double away = (g_pend_dir > 0) ? (g_pend_ext - g_pend_ext0) : (g_pend_ext0 - g_pend_ext);
      if(away / g_point >= InpPendCancelPts)   why = "pend_fugiu";
   }
   else
   {
      double rec = (g_pend_dir > 0) ? (g_pend_ext - bid) : (bid - g_pend_ext);
      if(rec / g_point >= InpPendCancelPts)    why = "pend_recuou";
   }
   if(why == "") return;

   ulong t0 = GetMicrosecondCount();
   m_trade.OrderDelete(g_pend_ticket);
   ulong lat = GetMicrosecondCount() - t0;
   uint rc = m_trade.ResultRetcode();
   bool done = (rc == TRADE_RETCODE_DONE);
   LogOrder("PEND_CANCEL", g_pend_dir, g_pend_vol, g_pend_price, 0, 0, 0, done, lat, why + " age=" + I(age) + "ms");
   LogSignal(g_pend_sig, "SKIP", why);
   if(done)
   {
      g_pend_on = false;
      g_ctx_valid = false;
      g_pend_next_ms = g_tick.time_msc + InpPendRearmMs;
   }
   // se falhou (ordem ja executada/removida) a proxima passada resolve pelo OrderSelect/AddPos
}

void EntryFlow()
{
   if(InpPendEnable)
   {
      PendManage();
      if(!g_pend_on && g_state == ST_SCANNING && g_sig.dir != 0 && g_tick.time_msc >= g_pend_next_ms) TryEntry(g_sig);
      return;
   }
   if(!InpPullbackEntry)''')

# ---------------------------------------------------------- validacao e log
rep('   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";',
    '''   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";
   if(InpPendLimitPct <= 0 || InpPendLimitPct >= 100 || InpPendMinOffsetPts < 0 || InpPendStopPts <= 0)
                                       err = "Pendente: pct em (0,100), recuo minimo >= 0, distancia stop > 0";
   if(InpPendTtlMs <= 0 || InpPendCancelPts <= 0 || InpPendRearmMs < 0) err = "Pendente: TTL e cancelamento devem ser > 0";''')
rep('   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));',
    '''   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));
   LogParam("InpPendEnable", (string)InpPendEnable);
   LogParam("InpPendMode", EnumToString(InpPendMode));
   LogParam("InpPendLimitPct", D(InpPendLimitPct, 1));
   LogParam("InpPendMinOffsetPts", I(InpPendMinOffsetPts));
   LogParam("InpPendStopPts", I(InpPendStopPts));
   LogParam("InpPendTtlMs", I(InpPendTtlMs));
   LogParam("InpPendCancelPts", I(InpPendCancelPts));
   LogParam("InpPendRearmMs", I(InpPendRearmMs));
   LogParam("expiration_mode_flags", I(SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_MODE)));
   LogParam("trade_exemode", I(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_EXEMODE)));''')

rep("   TrendUpdate();\n   DailyRefresh(true);\n   SyncPositions();\n",
    "   TrendUpdate();\n   DailyRefresh(true);\n   SyncPositions();\n   if(InpPendEnable) PendCleanup(\"inicio\");\n")
rep("void OnDeinit(const int reason)\n{\n   EventKillTimer();\n",
    "void OnDeinit(const int reason)\n{\n   EventKillTimer();\n   if(InpPendEnable) PendCleanup(\"fim\");\n")
rep('   LogParam("InpPendRearmMs", I(InpPendRearmMs));',
    '   LogParam("InpPendRearmMs", I(InpPendRearmMs));\n   LogParam("InpPendSafetyExpirySec", I(InpPendSafetyExpirySec));\n'
    '   if(InpPendEnable && InpPullbackEntry) LogEvent("WARN", "PULLBACK_IGNORADO", "InpPullbackEntry ignorado: a ordem pendente tem prioridade");')

open(DST, "w", encoding="utf-8", newline="").write(s.replace("\n", "\r\n"))
print("ok", len(s))
