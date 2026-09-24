//+------------------------------------------------------------------+
//|                                       WallStreetBreaker_USD.mq5  |
//|   v2.5: diagnóstico de "não abre ordens" (permissões, retcode,   |
//|         motivo por candle na aba Experts, varredura de sinais)   |
//|         + desvio configurável (15 pts no ouro = requote)         |
//|   v2.4: correções de segurança sobre a v2.3                      |
//|                                                                  |
//|   A LÓGICA DE ENTRADA E DE SAÍDA NÃO MUDOU (breakout + ATR + ADX,|
//|   TP em $, trailing em $, piramidação). O que mudou:             |
//|                                                                  |
//|   1. Stop de emergência agora fica NO SERVIDOR desde a entrada.  |
//|      Antes era só no EA: VPS caiu / MT5 travou = posição sem     |
//|      proteção nenhuma.                                           |
//|   2. Fecha posições na sexta antes do fim do mercado (opcional). |
//|      No seu backtest, 19/01/2026 01:01: stop de $50 virou -$80   |
//|      por gap de fim de semana.                                   |
//|   3. Perda diária atingida agora FECHA as posições (antes só     |
//|      bloqueava novas entradas e a posição aberta seguia perdendo)|
//|   4. Limite de perda em $ para o CONJUNTO de posições            |
//|      (piramidação) — antes cada posição tinha seu limite.        |
//|   5. Piramidação respeita sessão e circuit breaker.              |
//|   6. Equity do início do dia e contagem de trades sobrevivem a   |
//|      reinício do MT5 (antes zeravam e liberavam o dia de novo).  |
//|   7. Trailing respeita o stop level da corretora e só move o SL  |
//|      com passo mínimo (antes podia mandar modify a cada tick).   |
//|   8. Limpeza das variáveis globais de posições já fechadas.      |
//|   9. Preços normalizados pelo tick size; removido #property      |
//|      strict (é de MQL4).                                         |
//+------------------------------------------------------------------+
#property copyright "WSB v2.5"
#property version   "2.50"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

CTrade        trade;
CPositionInfo posInfo;

//==================== INPUTS ====================
input group "=== MONEY (lote fixo, TP e trailing em $) ==="
input double InpFixedLot          = 0.01;
input double InpTakeProfitUsd     = 5.0;
input double InpTrailActivateUsd  = 3.0;
input double InpTrailDistanceUsd  = 1.0;
input double InpTrailMinStepUsd   = 0.20;  // [v2.4] só move o SL se melhorar pelo menos isso
input bool   InpUseEmergencyStop  = true;
input double InpEmergencyStopUsd  = 30.0;
input bool   InpEmergencyOnServer = true;  // [v2.4] grava o stop de emergência no servidor (SL real)
input double InpMaxBasketLossUsd  = 60.0;  // [v2.4] perda máx. somando TODAS as posições (0 = desliga)

input group "=== CIRCUIT BREAKER DIARIO ==="
input double InpMaxDailyLossPct   = 5.0;
input double InpMaxDailyGainPct   = 10.0;
input int    InpMaxTradesPerDay   = 8;
input bool   InpCloseOnDailyLoss  = true;  // [v2.4] perda diária atingida -> fecha as posições

input group "=== FIM DE SEMANA ==="
input bool   InpCloseFriday       = true;  // [v2.4] zera na sexta antes do fechamento
input int    InpFridayCloseHour   = 22;    // [v2.4] hora do SERVIDOR para zerar na sexta

input group "=== ENTRADA (breakout + volatilidade) ==="
input int    InpAtrPeriod         = 14;
input double InpBreakoutMult      = 1.15;   // ATR atual >= fator * ATR prev
input int    InpRangeBars         = 12;
input int    InpMinAdx            = 18;

input group "=== PIRAMIDACAO ==="
input bool   InpUsePyramiding     = true;
input int    InpMaxPyramidAdds    = 3;
input double InpPyramidStepAtr    = 1.5;
input double InpPyramidLotFactor  = 0.6;
input bool   InpPyramidForceMinLot= true;  // [v2.4] true = igual v2.3 (arredonda p/ lote mínimo). false = pula se lote < mínimo

input group "=== SESSAO ==="
input bool   InpUseSessionFilter  = true;
input int    InpStartHour         = 8;
input int    InpEndHour           = 20;

input group "=== TELEMETRIA CSV ==="
input bool   InpUseTelemetry      = true;
input int    InpHeartbeatSec      = 60;

input group "=== EXTRAS ==="
input int    InpMagicNumber       = 20250101;
input string InpComment           = "WSB2";
input int    InpDeviationPts      = 50;    // [v2.5] desvio máx. em pontos (15 no ouro = requote em conta real)

input group "=== DIAGNOSTICO ==="
input bool   InpVerbose           = true;  // [v2.5] escreve na aba Experts o motivo de cada candle
input int    InpScanDays          = 30;    // [v2.5] ao iniciar, conta quantos sinais houve nos últimos N dias

//==================== GLOBAIS ====================
int      hAtr, hAdx;
double   gAtrBuffer[], gAdxBuffer[];
datetime gLastBarTime = 0;
double   gDayStartEquity = 0;
int      gDayTrades = 0;
int      gCurrentDay = -1;
bool     gDailyLossHit = false;
bool     gScanDone     = false;

//--- telemetria
ulong    gSeq = 0;
datetime gLastHeartbeat = 0;

//+------------------------------------------------------------------+
//| TELEMETRIA CSV                                                   |
//+------------------------------------------------------------------+
string TN(double v, int d=5)
{
   if(v == EMPTY_VALUE || v != v) return "";
   return DoubleToString(v, d);
}

string TS()
{
   return TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
}

// Abre, escreve, fecha. Nunca deixa lock no arquivo.
void TLog(string event,
          int    dir, int n_pos,
          int    newbar, int circuit, int session,
          double atr, double atr_prev, double adx,
          double range_hi, double range_lo, double close_prev,
          int    signal,
          string decision, string reason,
          ulong  ticket, double price, double volume, double profit,
          string note)
{
   if(!InpUseTelemetry) return;

   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   string fname = StringFormat("WSB2_%04d%02d%02d.csv", t.year, t.mon, t.day);

   int h = FileOpen(fname, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
   if(h == INVALID_HANDLE)
   {
      PrintFormat("WSB2: FileOpen falhou %s err=%d", fname, GetLastError());
      return;
   }
   FileSeek(h, 0, SEEK_END);
   bool novo = (FileTell(h) == 0);

   double eq     = AccountInfoDouble(ACCOUNT_EQUITY);
   double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
   gSeq++;

   if(novo)
   {
      FileWrite(h,
         "timestamp","seq","event","magic","symbol","dir","n_pos",
         "newbar","circuit","session","atr","atr_prev","adx",
         "range_hi","range_lo","close_prev","signal",
         "decision","reason","ticket","price","volume","profit",
         "spread","equity","day_start_equity","day_trades","note");
   }

   FileWrite(h,
      TS(), IntegerToString((long)gSeq), event,
      IntegerToString(InpMagicNumber), _Symbol,
      IntegerToString(dir), IntegerToString(n_pos),
      IntegerToString(newbar), IntegerToString(circuit), IntegerToString(session),
      TN(atr), TN(atr_prev), TN(adx,2),
      TN(range_hi), TN(range_lo), TN(close_prev),
      IntegerToString(signal),
      decision, reason,
      IntegerToString((long)ticket),
      TN(price), TN(volume,2), TN(profit,2),
      TN(spread), TN(eq,2), TN(gDayStartEquity,2), IntegerToString(gDayTrades),
      note);

   FileFlush(h);
   FileClose(h);
}

void TEvent(string event, string decision, string reason,
            ulong ticket=0, double price=0, double volume=0, double profit=0,
            string note="")
{
   TLog(event, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        decision, reason, ticket, price, volume, profit, note);
}

//+------------------------------------------------------------------+
//| Utilidades de preço / volume                           [v2.4]    |
//+------------------------------------------------------------------+
double NormPrice(double p)
{
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) return NormalizeDouble(p, _Digits);
   return NormalizeDouble(MathRound(p / ts) * ts, _Digits);
}

// Arredonda o lote PARA BAIXO no passo da corretora. Retorna 0 se ficar abaixo do mínimo.
double FloorLot(double lot)
{
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0) return 0;
   double l = MathFloor(lot / step + 1e-9) * step;
   if(l < vmin) return 0;
   return MathMin(l, vmax);
}

double MoneyPerPointPerLot()
{
   double tickVal  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point    = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tickSize <= 0 || point <= 0) return 0;
   return tickVal * point / tickSize;
}

// Distância de preço que corresponde a 'usd' para o volume 'vol'
double PriceDistForUsd(double usd, double vol)
{
   double mpp   = MoneyPerPointPerLot();
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(mpp <= 0 || vol <= 0) return 0;
   return usd / (mpp * vol) * point;
}

// SL de emergência no servidor para uma nova entrada (0 = sem SL)
double EmergencySL(int dir, double entry, double vol)
{
   if(!InpUseEmergencyStop || !InpEmergencyOnServer) return 0;
   double dist = PriceDistForUsd(InpEmergencyStopUsd, vol);
   if(dist <= 0) return 0;
   return NormPrice(dir == 1 ? entry - dist : entry + dist);
}

//+------------------------------------------------------------------+
//| [v2.5] Permissões: o motivo nº 1 de "backtest opera, real não"   |
//+------------------------------------------------------------------+
bool TradingAllowed(string &why)
{
   if(MQLInfoInteger(MQL_TESTER)) { why = "tester"; return true; }
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
   { why = "terminal DESCONECTADO da corretora"; return false; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   { why = "botão 'Algo Trading' DESLIGADO na barra de ferramentas do MT5"; return false; }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   { why = "'Permitir Algo Trading' desmarcado nas propriedades do EA (F7 no gráfico > aba Comum)"; return false; }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
   { why = "conta sem permissão de negociar (logado com senha de INVESTIDOR?)"; return false; }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
   { why = "a corretora não permite robôs nesta conta"; return false; }
   long mode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
   if(mode == SYMBOL_TRADE_MODE_DISABLED || mode == SYMBOL_TRADE_MODE_CLOSEONLY)
   { why = "negociação de " + _Symbol + " bloqueada pela corretora (use o símbolo certo, ex.: com sufixo)"; return false; }
   why = "ok";
   return true;
}

//+------------------------------------------------------------------+
//| [v2.5] Quantos sinais houve nos últimos N dias (uma vez só)      |
//| Se der ~0, o EA não está quebrado: o sinal é que não aconteceu.  |
//+------------------------------------------------------------------+
void SignalScan()
{
   if(gScanDone || InpScanDays <= 0) return;
   int n    = InpScanDays * 96;                 // candles M15 por dia
   int need = n + InpRangeBars + 3;
   if(BarsCalculated(hAtr) < need || BarsCalculated(hAdx) < need) return;   // tenta no próximo tick

   double a[], x[];
   MqlRates r[];
   ArraySetAsSeries(a, true);
   ArraySetAsSeries(x, true);
   ArraySetAsSeries(r, true);
   if(CopyBuffer(hAtr, 0, 0, need, a) < need || CopyBuffer(hAdx, 0, 0, need, x) < need ||
      CopyRates(_Symbol, PERIOD_M15, 0, need, r) < need) return;
   gScanDone = true;

   int cAdx = 0, cAtr = 0, cBrk = 0, cAll = 0;
   datetime last = 0;
   for(int i = 1; i <= n; i++)
   {
      MqlDateTime t; TimeToStruct(r[i].time, t);
      bool sess = !InpUseSessionFilter || (t.hour >= InpStartHour && t.hour < InpEndHour);
      double hi = -DBL_MAX, lo = DBL_MAX;
      for(int j = i + 1; j <= i + InpRangeBars; j++) { hi = MathMax(hi, r[j].high); lo = MathMin(lo, r[j].low); }
      bool brk   = (r[i].close > hi || r[i].close < lo);
      bool okAdx = (x[i] >= InpMinAdx);
      bool okAtr = (a[i] >= a[i+1] * InpBreakoutMult);
      if(okAdx) cAdx++;
      if(okAtr) cAtr++;
      if(brk)   cBrk++;
      if(okAdx && okAtr && brk && sess) { cAll++; if(last == 0) last = r[i].time; }
   }
   string msg = StringFormat("Últimos %d dias (%d candles M15): ADX ok em %d, ATR ok em %d, rompimento em %d  =>  "
                             "SINAIS COMPLETOS: %d (último: %s)",
                             InpScanDays, n, cAdx, cAtr, cBrk, cAll,
                             last > 0 ? TimeToString(last, TIME_DATE|TIME_MINUTES) : "nenhum");
   PrintFormat("WSB2 SCAN | %s", msg);
   TEvent("SIGNAL_SCAN", "OK", msg);
}

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpDeviationPts);   // [v2.5] era 15 fixo
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetMarginMode();

   hAtr = iATR(_Symbol, PERIOD_M15, InpAtrPeriod);
   hAdx = iADX(_Symbol, PERIOD_M15, 14);
   if(hAtr == INVALID_HANDLE || hAdx == INVALID_HANDLE) return INIT_FAILED;

   ArraySetAsSeries(gAtrBuffer, true);
   ArraySetAsSeries(gAdxBuffer, true);

   ResetDailyStats();
   CleanupGlobals();

   TEvent("INIT", "OK", "EA inicializada",
          0, 0, 0, 0,
          StringFormat("v2.5 lot=%.2f tp=%.2f act=%.2f dist=%.2f emerg=%.2f srv=%d basket=%.2f mult=%.2f adx=%d bars=%d sess=%d-%d",
                       InpFixedLot, InpTakeProfitUsd, InpTrailActivateUsd, InpTrailDistanceUsd,
                       InpEmergencyStopUsd, (int)InpEmergencyOnServer, InpMaxBasketLossUsd,
                       InpBreakoutMult, InpMinAdx, InpRangeBars, InpStartHour, InpEndHour));
   // [v2.5] diagnóstico visível na aba Experts
   string why;
   bool perm = TradingAllowed(why);
   PrintFormat("WSB2 v2.5 | %s | servidor %s | permissão: %s | lote %.2f (mín %.2f) | sessão %s %d-%dh | stop lvl %d pts",
               _Symbol, TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), perm ? "OK" : "BLOQUEADO -> " + why,
               InpFixedLot, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
               InpUseSessionFilter ? "ligada" : "desligada", InpStartHour, InpEndHour,
               (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL));
   if(!perm)
      Alert("WSB2: não vai abrir ordens -> " + why);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(hAtr);
   IndicatorRelease(hAdx);
   TEvent("DEINIT", "OK", StringFormat("reason=%d", reason));
}

//+------------------------------------------------------------------+
//| Dia: equity inicial e contagem persistentes            [v2.4]    |
//+------------------------------------------------------------------+
string GVDay()   { return "WSB2_DAYID_" + IntegerToString(InpMagicNumber); }
string GVDayEq() { return "WSB2_DAYEQ_" + IntegerToString(InpMagicNumber); }

// Conta as entradas principais (não piramidação) de hoje no histórico
int CountEntriesToday()
{
   datetime dayStart = (datetime)((long)TimeCurrent() / 86400 * 86400);
   if(!HistorySelect(dayStart, TimeCurrent() + 60)) return 0;
   int n = 0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
   {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      if(HistoryDealGetInteger(d, DEAL_MAGIC) != InpMagicNumber) continue;
      if(HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      if(StringFind(HistoryDealGetString(d, DEAL_COMMENT), "_pyr") >= 0) continue;
      n++;
   }
   return n;
}

void ResetDailyStats()
{
   int today = (int)(TimeCurrent() / 86400);
   if(GlobalVariableCheck(GVDay()) && (int)GlobalVariableGet(GVDay()) == today && GlobalVariableCheck(GVDayEq()))
   {
      gDayStartEquity = GlobalVariableGet(GVDayEq());       // reinício no meio do dia: mantém a base
   }
   else
   {
      gDayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      GlobalVariableSet(GVDay(), today);
      GlobalVariableSet(GVDayEq(), gDayStartEquity);
   }
   gCurrentDay   = today;
   gDayTrades    = CountEntriesToday();
   gDailyLossHit = false;
   TEvent("DAILY_RESET", "OK", "", 0, 0, 0, 0,
          StringFormat("equity=%.2f trades=%d", gDayStartEquity, gDayTrades));
}

double DailyPnlPct()
{
   if(gDayStartEquity <= 0) return 0;
   return (AccountInfoDouble(ACCOUNT_EQUITY) - gDayStartEquity) / gDayStartEquity * 100.0;
}

bool CircuitBreakerOK(string &reason)
{
   double pnlPct = DailyPnlPct();
   if(pnlPct <= -InpMaxDailyLossPct) { reason = StringFormat("perda_diaria %.2f%%", pnlPct); return false; }
   if(pnlPct >=  InpMaxDailyGainPct) { reason = StringFormat("meta_diaria %.2f%%", pnlPct); return false; }
   if(gDayTrades >= InpMaxTradesPerDay) { reason = StringFormat("max_trades %d", gDayTrades); return false; }
   reason = StringFormat("pnl=%.2f%% trades=%d", pnlPct, gDayTrades);
   return true;
}

bool SessionOK(string &reason)
{
   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   if(!InpUseSessionFilter) { reason = "sem_filtro"; return true; }
   bool ok = (t.hour >= InpStartHour && t.hour < InpEndHour);
   reason = StringFormat("hora_servidor=%02d janela=%d-%d", t.hour, InpStartHour, InpEndHour);
   return ok;
}

// [v2.4] Sexta perto do fechamento: não abre nada e zera o que tiver
bool FridayCutoff()
{
   if(!InpCloseFriday) return false;
   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   return (t.day_of_week == 5 && t.hour >= InpFridayCloseHour) || t.day_of_week == 6 || t.day_of_week == 0;
}

bool NewBar()
{
   datetime t = (datetime)iTime(_Symbol, PERIOD_M15, 0);
   if(t == 0) return false;
   if(t == gLastBarTime) return false;
   gLastBarTime = t;
   return true;
}

int CountMyPositions(int &dirOut)
{
   int count = 0; dirOut = 0;
   for(int i = PositionsTotal()-1; i>=0; i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Symbol() != _Symbol) continue;
      if(posInfo.Magic()  != InpMagicNumber) continue;
      count++;
      dirOut = (posInfo.PositionType()==POSITION_TYPE_BUY) ? 1 : -1;
   }
   return count;
}

double PriceForProfit(ulong ticket, double targetUsd)
{
   if(!posInfo.SelectByTicket(ticket)) return 0;
   double dist = PriceDistForUsd(targetUsd, posInfo.Volume());
   if(dist <= 0) return 0;
   if(posInfo.PositionType() == POSITION_TYPE_BUY) return posInfo.PriceOpen() + dist;
   return posInfo.PriceOpen() - dist;
}

string GVName(ulong ticket, string suffix)
{ return "WSB2_"+suffix+"_"+IntegerToString((long)ticket); }

// [v2.4] Apaga TRAIL/MAX de posições que já não existem (fechadas pelo SL no servidor etc.)
void CleanupGlobals()
{
   for(int i = GlobalVariablesTotal()-1; i >= 0; i--)
   {
      string name = GlobalVariableName(i);
      string pre  = "";
      if(StringFind(name, "WSB2_TRAIL_") == 0) pre = "WSB2_TRAIL_";
      else if(StringFind(name, "WSB2_MAX_") == 0) pre = "WSB2_MAX_";
      else continue;
      ulong ticket = (ulong)StringToInteger(StringSubstr(name, StringLen(pre)));
      if(ticket > 0 && !PositionSelectByTicket(ticket))
         GlobalVariableDel(name);
   }
}

// [v2.4] Fecha todas as posições deste EA
void CloseAllMine(string event, string reason)
{
   for(int i = PositionsTotal()-1; i>=0; i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != InpMagicNumber) continue;
      ulong  ticket = posInfo.Ticket();
      double profit = posInfo.Profit();
      double price  = posInfo.PriceCurrent();
      double vol    = posInfo.Volume();
      bool ok = trade.PositionClose(ticket);
      TEvent(event, ok?"OK":"FAIL", reason, ticket, price, vol, profit,
             StringFormat("retcode=%d", trade.ResultRetcode()));
      GlobalVariableDel(GVName(ticket,"TRAIL"));
      GlobalVariableDel(GVName(ticket,"MAX"));
   }
}

// [v2.4] Proteções que valem a cada tick (não só no candle novo)
void AccountGuards()
{
   int dir = 0;
   if(CountMyPositions(dir) == 0) return;

   if(FridayCutoff())
   {
      CloseAllMine("EXIT_FRIDAY", "zera antes do fim de semana");
      return;
   }

   if(InpCloseOnDailyLoss && DailyPnlPct() <= -InpMaxDailyLossPct)
   {
      if(!gDailyLossHit)
         TEvent("DAILY_LOSS", "HIT", StringFormat("pnl=%.2f%%", DailyPnlPct()));
      gDailyLossHit = true;
      CloseAllMine("EXIT_DAILY_LOSS", "perda diaria atingida");
      return;
   }

   if(InpMaxBasketLossUsd > 0)
   {
      double total = 0;
      for(int i = PositionsTotal()-1; i>=0; i--)
      {
         if(!posInfo.SelectByIndex(i)) continue;
         if(posInfo.Symbol() != _Symbol || posInfo.Magic() != InpMagicNumber) continue;
         total += posInfo.Profit() + posInfo.Swap();
      }
      if(total <= -InpMaxBasketLossUsd)
         CloseAllMine("EXIT_BASKET", StringFormat("soma=%.2f <= -%.2f", total, InpMaxBasketLossUsd));
   }
}

//+------------------------------------------------------------------+
//| Gestao por posicao: TP $, trailing $                             |
//+------------------------------------------------------------------+
void ManagePositions()
{
   double point     = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits    = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double stopLevel = MathMax((double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL), 5.0) * point;

   for(int i = PositionsTotal()-1; i>=0; i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Symbol() != _Symbol) continue;
      if(posInfo.Magic()  != InpMagicNumber) continue;

      ulong  ticket = posInfo.Ticket();
      double profit = posInfo.Profit();

      // Stop de emergência no EA (continua como 2ª camada; a 1ª é o SL no servidor)
      if(InpUseEmergencyStop && profit <= -InpEmergencyStopUsd)
      {
         bool ok = trade.PositionClose(ticket);
         TEvent("EXIT_EMERGENCY", ok?"OK":"FAIL", "profit<=-limit",
                ticket, posInfo.PriceCurrent(), posInfo.Volume(), profit,
                StringFormat("retcode=%d", trade.ResultRetcode()));
         GlobalVariableDel(GVName(ticket,"TRAIL"));
         GlobalVariableDel(GVName(ticket,"MAX"));
         continue;
      }

      string gvTrail = GVName(ticket, "TRAIL");
      string gvMax   = GVName(ticket, "MAX");
      bool trailingActive = GlobalVariableCheck(gvTrail) && GlobalVariableGet(gvTrail) > 0;

      if(!trailingActive && profit >= InpTrailActivateUsd)
      {
         GlobalVariableSet(gvTrail, 1);
         GlobalVariableSet(gvMax, profit);
         trailingActive = true;
         TEvent("TRAIL_ACTIVATE", "OK", "profit>=activate",
                ticket, posInfo.PriceCurrent(), posInfo.Volume(), profit);
      }

      if(!trailingActive)
      {
         if(profit >= InpTakeProfitUsd)
         {
            bool ok = trade.PositionClose(ticket);
            TEvent("EXIT_TP", ok?"OK":"FAIL", "profit>=tp",
                   ticket, posInfo.PriceCurrent(), posInfo.Volume(), profit,
                   StringFormat("retcode=%d", trade.ResultRetcode()));
         }
         continue;
      }

      double maxPnl = GlobalVariableGet(gvMax);
      if(profit > maxPnl) { maxPnl = profit; GlobalVariableSet(gvMax, maxPnl); }

      double trailTarget = maxPnl - InpTrailDistanceUsd;
      double floorTarget = InpTrailActivateUsd - InpTrailDistanceUsd;
      if(trailTarget < floorTarget) trailTarget = floorTarget;

      if(profit <= trailTarget)
      {
         bool ok = trade.PositionClose(ticket);
         TEvent("EXIT_TRAIL", ok?"OK":"FAIL",
                StringFormat("profit=%.2f <= target=%.2f max=%.2f", profit, trailTarget, maxPnl),
                ticket, posInfo.PriceCurrent(), posInfo.Volume(), profit,
                StringFormat("retcode=%d", trade.ResultRetcode()));
         GlobalVariableDel(gvTrail);
         GlobalVariableDel(gvMax);
         continue;
      }

      double slPrice   = NormPrice(PriceForProfit(ticket, trailTarget));
      double slCurrent = posInfo.StopLoss();
      double minStep   = PriceDistForUsd(InpTrailMinStepUsd, posInfo.Volume());   // [v2.4]
      if(slPrice <= 0) continue;

      if(posInfo.PositionType() == POSITION_TYPE_BUY)
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if((slCurrent == 0 || slPrice >= slCurrent + minStep) && slPrice < bid - stopLevel)
         {
            bool ok = trade.PositionModify(ticket, slPrice, 0);
            TEvent("TRAIL_SL_MOVE", ok?"OK":"FAIL",
                   StringFormat("sl=%s old=%s max=%.2f", DoubleToString(slPrice, digits), DoubleToString(slCurrent, digits), maxPnl),
                   ticket, bid, posInfo.Volume(), profit,
                   StringFormat("retcode=%d", trade.ResultRetcode()));
         }
      }
      else
      {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if((slCurrent == 0 || slPrice <= slCurrent - minStep) && slPrice > ask + stopLevel)
         {
            bool ok = trade.PositionModify(ticket, slPrice, 0);
            TEvent("TRAIL_SL_MOVE", ok?"OK":"FAIL",
                   StringFormat("sl=%s old=%s max=%.2f", DoubleToString(slPrice, digits), DoubleToString(slCurrent, digits), maxPnl),
                   ticket, ask, posInfo.Volume(), profit,
                   StringFormat("retcode=%d", trade.ResultRetcode()));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Piramidacao                                                      |
//+------------------------------------------------------------------+
void TryPyramid(double atr)
{
   if(!InpUsePyramiding) return;

   // [v2.4] piramidação obedece sessão, circuit breaker e fim de semana
   string r1, r2;
   if(!CircuitBreakerOK(r1) || !SessionOK(r2) || FridayCutoff() || gDailyLossHit) return;

   int dir = 0;
   int n = CountMyPositions(dir);
   if(n == 0 || n > InpMaxPyramidAdds) return;

   ulong firstTicket = 0;
   datetime oldest = 0;
   double basePrice = 0, baseVol = 0;

   for(int i = PositionsTotal()-1; i>=0; i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Symbol() != _Symbol || posInfo.Magic() != InpMagicNumber) continue;
      if(oldest == 0 || posInfo.Time() < oldest)
      {
         oldest = posInfo.Time();
         firstTicket = posInfo.Ticket();
         basePrice = posInfo.PriceOpen();
         baseVol   = posInfo.Volume();
      }
   }
   if(firstTicket == 0) return;

   double price = (dir==1) ?
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double move = (dir==1) ? (price - basePrice) : (basePrice - price);
   int addsSoFar = n - 1;
   double nextStep = atr * InpPyramidStepAtr * (addsSoFar + 1);

   if(move >= nextStep)
   {
      // [v2.4] lote no passo da corretora; v2.3 usava NormalizeDouble(,2) e forçava o mínimo
      double newLot = FloorLot(baseVol * MathPow(InpPyramidLotFactor, addsSoFar+1));
      if(newLot <= 0)
      {
         if(!InpPyramidForceMinLot) return;   // respeita o fator: não aumenta risco
         newLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      }

      bool ok;
      double sl = EmergencySL(dir, price, newLot);
      if(dir==1) ok = trade.Buy (newLot, _Symbol, 0, sl, 0, InpComment+"_pyr");
      else       ok = trade.Sell(newLot, _Symbol, 0, sl, 0, InpComment+"_pyr");

      TEvent("PYRAMID", ok?"OK":"FAIL",
             StringFormat("dir=%d adds=%d move=%.5f step=%.5f", dir, addsSoFar, move, nextStep),
             trade.ResultOrder(), price, newLot, 0,
             StringFormat("retcode=%d sl=%.2f", trade.ResultRetcode(), sl));
   }
}

//+------------------------------------------------------------------+
//| Sinal: breakout com expansao de ATR (inalterado)                 |
//+------------------------------------------------------------------+
int GetSignal(double &atrOut, double &atrPrev, double &adxOut,
              double &rangeHigh, double &rangeLow, double &closePrev,
              string &reason)
{
   if(CopyBuffer(hAtr, 0, 0, 3, gAtrBuffer) < 3) { reason = "copy_atr"; return 0; }
   if(CopyBuffer(hAdx, 0, 0, 3, gAdxBuffer) < 3) { reason = "copy_adx"; return 0; }

   double atr  = gAtrBuffer[1];
   double atrP = gAtrBuffer[2];
   double adx  = gAdxBuffer[1];
   atrOut = atr; atrPrev = atrP; adxOut = adx;

   double hi = -DBL_MAX, lo = DBL_MAX;
   for(int i = 2; i <= InpRangeBars+1; i++)
   {
      double h = iHigh(_Symbol, PERIOD_M15, i);
      double l = iLow (_Symbol, PERIOD_M15, i);
      if(h > hi) hi = h;
      if(l < lo) lo = l;
   }
   rangeHigh = hi; rangeLow = lo;

   double cp = iClose(_Symbol, PERIOD_M15, 1);
   closePrev = cp;

   bool   rompUp = (cp > hi);
   bool   rompDn = (cp < lo);
   double ratio  = (atrP > 0) ? atr / atrP : 0;
   double distHi = hi - cp;
   double distLo = cp - lo;

   string ctx = StringFormat("ratio=%.3f cp=%.5f hi=%.5f lo=%.5f dHi=%.5f dLo=%.5f rompUp=%d rompDn=%d",
                             ratio, cp, hi, lo, distHi, distLo, rompUp?1:0, rompDn?1:0);

   if(adx < InpMinAdx)
   {
      reason = StringFormat("adx=%.2f < %d | %s", adx, InpMinAdx, ctx);
      return 0;
   }

   if(atr < atrP * InpBreakoutMult)
   {
      reason = StringFormat("atr=%.5f atrP=%.5f ratio=%.3f < %.2f | %s",
                            atr, atrP, ratio, InpBreakoutMult, ctx);
      return 0;
   }

   if(rompUp) { reason = StringFormat("breakout_up | %s", ctx); return  1; }
   if(rompDn) { reason = StringFormat("breakout_dn | %s", ctx); return -1; }
   reason = StringFormat("sem_rompimento | %s", ctx);
   return 0;
}

//+------------------------------------------------------------------+
void OnTick()
{
   // [v2.4] virada de dia checada a cada tick (antes só no candle novo)
   if((int)(TimeCurrent() / 86400) != gCurrentDay) ResetDailyStats();

   if(CopyBuffer(hAtr, 0, 0, 3, gAtrBuffer) < 3) return;
   double atr = gAtrBuffer[1];
   if(atr <= 0) return;

   SignalScan();             // [v2.5] roda uma vez quando os indicadores estiverem prontos
   AccountGuards();          // [v2.4]
   ManagePositions();
   TryPyramid(atr);

   // Heartbeat
   if(TimeCurrent() - gLastHeartbeat >= InpHeartbeatSec)
   {
      gLastHeartbeat = TimeCurrent();
      CleanupGlobals();      // [v2.4]
      if(InpUseTelemetry)
      {
         double eq = AccountInfoDouble(ACCOUNT_EQUITY);
         TEvent("HEARTBEAT", "OK", "", 0, 0, 0, 0,
                StringFormat("atr=%.5f equity=%.2f", atr, eq));
      }
   }

   if(!NewBar()) return;

   int    dir = 0;
   int    nPos = CountMyPositions(dir);
   string cbReason = "", sessReason = "";
   bool   cbOk  = CircuitBreakerOK(cbReason);
   bool   sesOk = SessionOK(sessReason);

   double atrPrev=0, adx=0, rHi=0, rLo=0, cPrev=0;
   string sigReason = "";
   int    sig = GetSignal(atr, atrPrev, adx, rHi, rLo, cPrev, sigReason);

   string decision = "PASS";
   string reason   = sigReason;
   string permWhy  = "";
   bool   permOk   = TradingAllowed(permWhy);   // [v2.5]

   if(!permOk)             { decision = "BLOCK"; reason = "permissao: " + permWhy + " | " + sigReason; }
   else if(!cbOk)               { decision = "BLOCK"; reason = "circuit: " + cbReason + " | " + sigReason; }
   else if(gDailyLossHit)  { decision = "BLOCK"; reason = "daily_loss_hit | " + sigReason; }
   else if(FridayCutoff()) { decision = "BLOCK"; reason = "friday_cutoff | " + sigReason; }
   else if(!sesOk)         { decision = "BLOCK"; reason = "session: " + sessReason + " | " + sigReason; }
   else if(nPos > 0)       { decision = "BLOCK"; reason = StringFormat("ja_tem_posicao dir=%d | %s", dir, sigReason); }
   else if(sig == 0)       { decision = "BLOCK"; reason = "sinal: " + sigReason; }

   TLog("BAR_EVAL", dir, nPos,
        1, cbOk?1:0, sesOk?1:0,
        atr, atrPrev, adx, rHi, rLo, cPrev,
        sig, decision, reason,
        0, 0, 0, 0,
        StringFormat("cb=%s sess=%s", cbReason, sessReason));

   // [v2.5] motivo de cada candle na aba Experts (sem precisar abrir o CSV)
   if(InpVerbose)
      PrintFormat("WSB2 %s %s | %s", TimeToString(iTime(_Symbol, PERIOD_M15, 1), TIME_MINUTES), decision, reason);

   if(decision != "PASS") return;

   double lot = FloorLot(InpFixedLot);
   if(lot <= 0) { TEvent("ORDER_SKIP", "FAIL", "lote abaixo do minimo"); return; }

   double px = (sig == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = EmergencySL(sig, px, lot);     // [v2.4] proteção no servidor desde a entrada

   bool ok = false;
   if(sig==1)       ok = trade.Buy (lot, _Symbol, 0, sl, 0, InpComment);
   else if(sig==-1) ok = trade.Sell(lot, _Symbol, 0, sl, 0, InpComment);

   // [v2.5] OrderSend pode "passar" e a corretora recusar: confere o retcode
   uint rc = trade.ResultRetcode();
   ok = ok && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL || rc == TRADE_RETCODE_PLACED);

   if(ok)
   {
      gDayTrades++;
      TLog("ORDER_SENT", sig, nPos,
           1, 1, 1,
           atr, atrPrev, adx, rHi, rLo, cPrev,
           sig, "EXEC", sigReason,
           trade.ResultOrder(), trade.ResultPrice(), trade.ResultVolume(), 0,
           StringFormat("retcode=%d comment=%s trades=%d sl=%.2f",
                        trade.ResultRetcode(), trade.ResultComment(), gDayTrades, sl));
   }
   else
   {
      TLog("ORDER_FAIL", sig, nPos,
           1, 1, 1,
           atr, atrPrev, adx, rHi, rLo, cPrev,
           sig, "FAIL", sigReason,
           0, 0, lot, 0,
           StringFormat("retcode=%d comment=%s",
                        trade.ResultRetcode(), trade.ResultComment()));
      PrintFormat("WSB2 ORDEM RECUSADA: retcode %d = %s", trade.ResultRetcode(), trade.ResultRetcodeDescription());
   }
}
//+------------------------------------------------------------------+
