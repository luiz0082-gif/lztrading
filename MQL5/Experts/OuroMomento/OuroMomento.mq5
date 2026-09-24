//+------------------------------------------------------------------+
//|                                                 OuroMomento.mq5  |
//|  "OuroMomento" — impulso + recuo a favor do VWAP (XAUUSD)        |
//|  Timeframe: M1 a M30 (padrão M5)                                 |
//|                                                                  |
//|  Leitura de preço em 3 passos:                                   |
//|   1. QUEM MANDA: preço acima do VWAP da sessão = comprador no    |
//|      controle; abaixo = vendedor.                                |
//|   2. PEGADA: um candle de IMPULSO (corpo >= 1,2 ATR, fechando    |
//|      na ponta) a favor de quem manda. Ordem grande sendo         |
//|      executada deixa esse rastro — e ordens grandes são          |
//|      fatiadas, então o fluxo tende a continuar.                  |
//|   3. PREÇO JUSTO: não persegue. Coloca ordem LIMITADA no meio    |
//|      do corpo do impulso e espera o recuo por até 5 candles.     |
//|                                                                  |
//|  Stop além do impulso, alvo 1,2R, saída por tempo se o           |
//|  movimento não vier em 12 candles. Uma operação por vez.         |
//|  Meta diária e perda máxima diária (obrigatória) em US$.         |
//+------------------------------------------------------------------+
#property copyright "lztrading"
#property version   "1.00"
#property description "Impulso + recuo a favor do VWAP no XAUUSD, M1 a M30."
#property description "Perda máxima diária é obrigatória."

#include <Trade/Trade.mqh>
#include <DolarFix/FixClock.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== Timeframe ==="
input ENUM_TIMEFRAMES InpTF = PERIOD_M5; // Timeframe de operação (M1 a M30)

input group "=== Meta e limite diário (US$) ==="
input double InpDailyTarget     = 12.0; // Meta diária em US$ (atingiu -> fecha e para)
input double InpDailyMaxLoss    = 0.0;  // Perda máxima diária em US$ (OBRIGATÓRIO > 0)
input int    InpMaxTradesPerDay = 4;    // Máximo de entradas por dia
input double InpMaxRiskPctTrade = 1.0;  // Teto de risco por trade (% do equity)

input group "=== Horário (Londres) ==="
input int InpVWAPAnchorH = 7;   // Âncora do VWAP (início da sessão europeia)
input int InpEntryStartH = 8;   // Início das entradas
input int InpEntryEndH   = 16;  // Fim das entradas (16:00 Londres = fechamento europeu)
input int InpFlatH       = 17;  // Fecha tudo neste horário

input group "=== Setup — FIXO, não otimize ==="
input int    InpATRPeriod     = 14;  // ATR (no timeframe de operação)
input double InpImpulseATR    = 1.2; // Corpo mínimo do impulso (× ATR)
input double InpCloseInTop    = 0.25;// Fechamento nos X% extremos do candle
input double InpMaxStretchATR = 2.0; // Não entra se o preço estiver > X ATR longe do VWAP
input double InpRetrace       = 0.5; // Entrada limitada em X do corpo do impulso
input int    InpPendingBars   = 5;   // Validade da ordem limitada (candles)
input double InpStopBufATR    = 0.2; // Folga do stop além do impulso (× ATR)
input double InpTP_R          = 1.2; // Alvo em R
input int    InpMaxBarsTrade  = 12;  // Saída por tempo (candles)
input int    InpCooldownBars  = 3;   // Pausa após um stop (candles)
input double InpMaxSpreadFrac = 0.15;// Spread máx. como fração do risco R

input group "=== Proteção da conta ==="
input double InpMaxDDPercent = 10.0; // Desliga o EA se equity cair X% do pico

input group "=== Relógio do servidor (CONFIRA NO LOG) ==="
input int             InpServerGMTOffset = 2;          // Offset GMT do servidor no INVERNO
input ENUM_SERVER_DST InpServerDST       = SRV_DST_US; // Regra de DST do servidor

input group "=== Execução ==="
input ulong InpMagic        = 26092600; // Magic number
input int   InpDeviationPts = 50;       // Desvio máximo (pontos)

//+------------------------------------------------------------------+
//| Globais                                                          |
//+------------------------------------------------------------------+
CTrade   g_trade;
datetime g_lastBar     = 0;
datetime g_pendPlaced  = 0;   // abertura do candle em que a limitada foi colocada
datetime g_day         = 0;
bool     g_dayDone     = false;
bool     g_killed      = false;
string   g_gvPeak, g_gvKill;

//+------------------------------------------------------------------+
//| Utilidades                                                       |
//+------------------------------------------------------------------+
double NormPrice(const double p)
  {
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0.0)
      return NormalizeDouble(p, _Digits);
   return NormalizeDouble(MathRound(p / ts) * ts, _Digits);
  }

double ATR(const int n)
  {
   MqlRates r[];
   ArraySetAsSeries(r, true);
   if(CopyRates(_Symbol, InpTF, 1, n + 1, r) < n + 1)
      return 0.0;
   double s = 0.0;
   for(int i = 0; i < n; i++)
      s += MathMax(r[i].high, r[i + 1].close) - MathMin(r[i].low, r[i + 1].close);
   return s / n;
  }

// VWAP ancorado: candles FECHADOS desde a âncora (servidor), ponderado pelo volume de ticks
double VWAP(const datetime anchorSrv)
  {
   MqlRates r[];
   int n = CopyRates(_Symbol, InpTF, anchorSrv, TimeCurrent(), r);
   if(n < 2)
      return 0.0;
   datetime cur = iTime(_Symbol, InpTF, 0);
   double pv = 0.0, v = 0.0;
   for(int i = 0; i < n; i++)
     {
      if(r[i].time >= cur)
         continue;                               // candle em formação fica de fora
      double tp  = (r[i].high + r[i].low + r[i].close) / 3.0;
      double vol = (double)MathMax(r[i].tick_volume, (long)1);
      pv += tp * vol;
      v  += vol;
     }
   return v > 0.0 ? pv / v : 0.0;
  }

double LossPerLot(const double dist)
  {
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue <= 0.0)
      tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize <= 0.0 || tickValue <= 0.0)
      return 0.0;
   return dist / tickSize * tickValue;
  }

double RiskPerTrade()
  {
   return MathMin(InpDailyMaxLoss / 2.0,                                   // 2 stops cheios = fim do dia
                  AccountInfoDouble(ACCOUNT_EQUITY) * InpMaxRiskPctTrade / 100.0);
  }

double LotsForRisk(const double riskMoney, const double dist)
  {
   double lpl  = LossPerLot(dist);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(lpl <= 0.0 || step <= 0.0 || riskMoney <= 0.0)
      return 0.0;
   double lots = MathFloor(riskMoney / lpl / step) * step;
   if(lots < vmin)
      return 0.0;                 // nunca arredonda o risco para cima
   return MathMin(lots, vmax);
  }

double DealNet(const ulong d)
  {
   return HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) +
          HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
  }

bool IsOurs(const ulong magic, const string sym) { return magic == InpMagic && sym == _Symbol; }

//+------------------------------------------------------------------+
//| Posição / ordens                                                 |
//+------------------------------------------------------------------+
ulong OurPosition()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t > 0 && IsOurs((ulong)PositionGetInteger(POSITION_MAGIC), PositionGetString(POSITION_SYMBOL)))
         return t;
     }
   return 0;
  }

ulong OurPending()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(t > 0 && IsOurs((ulong)OrderGetInteger(ORDER_MAGIC), OrderGetString(ORDER_SYMBOL)))
         return t;
     }
   return 0;
  }

void CloseAll(const string why)
  {
   ulong o = OurPending();
   if(o > 0)
      g_trade.OrderDelete(o);
   ulong p = OurPosition();
   if(p > 0 && g_trade.PositionClose(p))
      PrintFormat("[OM] Posição fechada (%s)", why);
  }

// Resultado do dia (servidor): fechado + flutuante
double DayPnL(const datetime srvDay)
  {
   double pnl = 0.0;
   if(HistorySelect(srvDay, TimeCurrent() + 60))
      for(int i = 0; i < HistoryDealsTotal(); i++)
        {
         ulong d = HistoryDealGetTicket(i);
         if(d > 0 && IsOurs((ulong)HistoryDealGetInteger(d, DEAL_MAGIC), HistoryDealGetString(d, DEAL_SYMBOL)))
            pnl += DealNet(d);
        }
   ulong p = OurPosition();
   if(p > 0 && PositionSelectByTicket(p))
      pnl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   return pnl;
  }

// Entradas do dia e dados da última saída (para a pausa após stop)
int DayStats(const datetime srvDay, datetime &lastExitTime, double &lastExitNet)
  {
   int n = 0;
   lastExitTime = 0;
   lastExitNet  = 0.0;
   if(!HistorySelect(srvDay, TimeCurrent() + 60))
      return 0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0 || !IsOurs((ulong)HistoryDealGetInteger(d, DEAL_MAGIC), HistoryDealGetString(d, DEAL_SYMBOL)))
         continue;
      long entry = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(entry == DEAL_ENTRY_IN)
         n++;
      else if(entry == DEAL_ENTRY_OUT)
        {
         lastExitTime = (datetime)HistoryDealGetInteger(d, DEAL_TIME);
         lastExitNet  = DealNet(d);
        }
     }
   return n;
  }

//+------------------------------------------------------------------+
//| Proteção de drawdown                                             |
//+------------------------------------------------------------------+
void CheckDrawdown()
  {
   if(g_killed)
      return;
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   double peak = GlobalVariableCheck(g_gvPeak) ? GlobalVariableGet(g_gvPeak) : eq;
   if(eq > peak)
      peak = eq;
   GlobalVariableSet(g_gvPeak, peak);
   if(peak > 0.0 && (peak - eq) / peak * 100.0 >= InpMaxDDPercent)
     {
      g_killed = true;
      GlobalVariableSet(g_gvKill, 1.0);
      CloseAll("proteção de drawdown");
      string msg = StringFormat("[OM] EA DESLIGADO: equity caiu %.1f%% do pico. Apague a variável global '%s' "
                                "para religar — depois de revisar.", (peak - eq) / peak * 100.0, g_gvKill);
      Print(msg);
      if(!MQLInfoInteger(MQL_TESTER))
         Alert(msg);
     }
  }

//+------------------------------------------------------------------+
//| Procura o setup no último candle fechado                         |
//+------------------------------------------------------------------+
void LookForSetup(const datetime lonDay)
  {
   MqlRates r[];
   ArraySetAsSeries(r, true);
   if(CopyRates(_Symbol, InpTF, 1, 1, r) < 1)
      return;
   double atr = ATR(InpATRPeriod);
   double vw  = VWAP(ClkLondonToServer(lonDay + InpVWAPAnchorH * 3600));
   if(atr <= 0.0 || vw <= 0.0)
      return;

   double o = r[0].open, h = r[0].high, l = r[0].low, c = r[0].close;
   double body = MathAbs(c - o), rng = h - l;
   if(rng <= 0.0 || body < InpImpulseATR * atr)
      return;                                             // sem pegada: nada a fazer

   int dir = 0;
   if(c > o && c > vw && (h - c) <= InpCloseInTop * rng && (c - vw) <= InpMaxStretchATR * atr)
      dir = +1;                                           // impulso comprador acima do VWAP
   if(c < o && c < vw && (c - l) <= InpCloseInTop * rng && (vw - c) <= InpMaxStretchATR * atr)
      dir = -1;                                           // impulso vendedor abaixo do VWAP
   if(dir == 0)
      return;

   double buf   = InpStopBufATR * atr;
   double entry = NormPrice(c - dir * InpRetrace * body);  // meio do corpo
   double sl    = NormPrice(dir > 0 ? l - buf : h + buf);  // além do impulso
   double R     = MathAbs(entry - sl);
   double tp    = NormPrice(entry + dir * InpTP_R * R);

   MqlTick tk;
   if(!SymbolInfoTick(_Symbol, tk))
      return;
   if((tk.ask - tk.bid) > InpMaxSpreadFrac * R)
     {
      PrintFormat("[OM] Setup ignorado: spread %.2f alto para R %.2f", tk.ask - tk.bid, R);
      return;
     }
   double minDist = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + 2) * _Point;
   if((dir > 0 && entry >= tk.ask - minDist) || (dir < 0 && entry <= tk.bid + minDist))
      return;                                             // preço já voltou até a entrada: não persegue

   double risk = RiskPerTrade();
   double lots = LotsForRisk(risk, R);
   if(lots <= 0.0)
     {
      PrintFormat("[OM] Setup ignorado: 0,01 lote arriscaria US$ %.2f (> US$ %.2f permitido)",
                  LossPerLot(R) * SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), risk);
      return;
     }

   bool ok = (dir > 0)
             ? g_trade.BuyLimit(lots, entry, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "OM impulso C")
             : g_trade.SellLimit(lots, entry, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "OM impulso V");
   if(ok)
     {
      g_pendPlaced = iTime(_Symbol, InpTF, 0);
      PrintFormat("[OM] %s limitada %.2f | stop %.2f | alvo %.2f | %.2f lotes | risco US$ %.2f | VWAP %.2f",
                  dir > 0 ? "COMPRA" : "VENDA", entry, sl, tp, lots, LossPerLot(R) * lots, vw);
     }
  }

//+------------------------------------------------------------------+
//| Loop principal                                                   |
//+------------------------------------------------------------------+
void Process()
  {
   datetime srvDay = ClkDayStart(TimeCurrent());
   if(srvDay != g_day)
     {
      g_day = srvDay;
      g_dayDone = false;
     }
   CheckDrawdown();

   datetime lon    = ClkServerToLondon(TimeCurrent());
   datetime lonDay = ClkDayStart(lon);
   int      lonMin = (int)((lon - lonDay) / 60);
   int      perSec = PeriodSeconds(InpTF);

   //--- Horário de zerar
   if(lonMin >= InpFlatH * 60)
     {
      CloseAll("fim do dia");
      return;
     }

   //--- Meta / perda do dia
   double pnl = DayPnL(srvDay);
   if(!g_dayDone && (pnl >= InpDailyTarget || pnl <= -InpDailyMaxLoss))
     {
      g_dayDone = true;
      CloseAll(pnl >= InpDailyTarget ? "meta do dia" : "perda máxima do dia");
      PrintFormat("[OM] Dia encerrado: US$ %.2f (%s)", pnl, pnl >= InpDailyTarget ? "META" : "PERDA MÁXIMA");
     }

   //--- Saída por tempo: o movimento não veio
   ulong pos = OurPosition();
   if(pos > 0 && PositionSelectByTicket(pos))
     {
      datetime opened = (datetime)PositionGetInteger(POSITION_TIME);
      if(TimeCurrent() - opened >= (long)InpMaxBarsTrade * perSec)
         if(g_trade.PositionClose(pos))
            Print("[OM] Saída por tempo: o impulso não continuou.");
     }

   //--- Validade da ordem limitada
   ulong pend = OurPending();
   bool entryWindow = ClkIsWeekday(lonDay) && lonMin >= InpEntryStartH * 60 && lonMin < InpEntryEndH * 60;
   if(pend > 0)
     {
      datetime cur = iTime(_Symbol, InpTF, 0);
      bool expired = (g_pendPlaced > 0 && cur - g_pendPlaced >= (long)InpPendingBars * perSec) || g_pendPlaced == 0;
      if(expired || !entryWindow || g_dayDone || g_killed)
        {
         g_trade.OrderDelete(pend);
         g_pendPlaced = 0;
        }
     }

   //--- Novo candle: procurar setup
   datetime bar = iTime(_Symbol, InpTF, 0);
   if(bar == g_lastBar)
      return;
   g_lastBar = bar;

   if(g_dayDone || g_killed || !entryWindow)
      return;
   if(OurPosition() > 0 || OurPending() > 0)
      return;                                             // uma operação por vez

   datetime lastExit;
   double   lastNet;
   int trades = DayStats(srvDay, lastExit, lastNet);
   if(trades >= InpMaxTradesPerDay)
      return;
   if(lastExit > 0 && lastNet < -0.5 * RiskPerTrade() && TimeCurrent() - lastExit < (long)InpCooldownBars * perSec)
      return;                                             // pausa após stop: respeita o mercado

   LookForSetup(lonDay);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   g_clkOffset = InpServerGMTOffset;
   g_clkDST    = InpServerDST;

   int ps = PeriodSeconds(InpTF);
   if(ps < 60 || ps > 1800)
     {
      Alert("[OM] Timeframe deve ser de M1 a M30.");
      return INIT_PARAMETERS_INCORRECT;
     }
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpDailyMaxLoss <= 0.0)
     {
      Alert("[OM] Defina a PERDA MÁXIMA DIÁRIA (InpDailyMaxLoss). Sem ela o EA não opera.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpDailyMaxLoss > eq * 0.05)
     {
      Alert(StringFormat("[OM] Perda diária US$ %.2f é mais de 5%% da conta (US$ %.2f). Recusando.", InpDailyMaxLoss, eq));
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpDailyTarget <= 0.0 || InpEntryStartH >= InpEntryEndH || InpEntryEndH > InpFlatH || InpVWAPAnchorH > InpEntryStartH)
      return INIT_PARAMETERS_INCORRECT;
   if(InpDailyTarget > eq * 0.01)
      PrintFormat("[OM] AVISO: meta de US$ %.2f = %.1f%% da conta por dia. Não é sustentável.",
                  InpDailyTarget, InpDailyTarget / eq * 100.0);
   if(StringFind(_Symbol, "XAU") < 0)
      PrintFormat("[OM] AVISO: desenhado para XAUUSD, não para %s.", _Symbol);

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(InpDeviationPts);
   g_trade.SetTypeFillingBySymbol(_Symbol);

   g_gvPeak = StringFormat("OM_%I64u_peak", InpMagic);
   g_gvKill = StringFormat("OM_%I64u_killed", InpMagic);
   g_killed = GlobalVariableCheck(g_gvKill) && GlobalVariableGet(g_gvKill) > 0.0;
   if(g_killed)
      PrintFormat("[OM] EA DESLIGADO pela proteção de drawdown (variável global %s).", g_gvKill);

   // Ordem limitada que sobrou de antes de um reinício: sem saber a idade, cancela
   ulong pend = OurPending();
   if(pend > 0)
      g_trade.OrderDelete(pend);

   PrintFormat("[OM] %s | Servidor %s = Londres %s | risco/trade US$ %.2f | meta US$ %.2f | perda máx US$ %.2f",
               EnumToString(InpTF), TimeToString(TimeCurrent(), TIME_MINUTES),
               TimeToString(ClkServerToLondon(TimeCurrent()), TIME_MINUTES),
               RiskPerTrade(), InpDailyTarget, InpDailyMaxLoss);
   EventSetTimer(5);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason) { EventKillTimer(); }
void OnTick()  { Process(); }
void OnTimer() { Process(); }
//+------------------------------------------------------------------+
