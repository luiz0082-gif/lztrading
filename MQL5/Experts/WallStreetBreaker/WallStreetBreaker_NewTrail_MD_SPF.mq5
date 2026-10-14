//+------------------------------------------------------------------+
//|                                       WallStreetBreaker_USD.mq5  |
//|   v2.38: saida por perda em $ passa a ser SO por software; SL de emergencia
//|          no servidor virou opcional (InpEmergencyOnServer=false). Antes um
//|          unico input ligava os dois, e o operador (sem SL) desligava ambos:
//|          posicao presa ficava sem nenhuma saida e travava o EA (1 posicao).
//|   v2.37: magic padrao 61937420 (era 20250101, igual ao de outro EA)
//|   v2.37: P&L diario (meta/limite) so deste EA (simbolo+magic, fechado) - nao mais
//|          equity da conta inteira; painel mais nitido; aviso de magic em conflito
//|   v2.36: HUD futurista (painel canvas) - so instrumentacao, logica de entrada intacta
//|   v2.35: meta diaria em $ (InpDailyGoalUsd) + filtro de spread    |
//|          em pontos (InpMaxSpreadPoints)                          |
//|   v2.34: Adaptive Money Trail (HWM + dist. sublinear + estrutural);|
//|          TP $ removido quando o trail ativa                      |
//|   v2.33: retry de entrada na mesma barra, filtros menos restritivos
//|   v2.32: lote normalizado, SL emergencia no servidor, checagens  |
//|   v2.31: Sem SL, TP em $, trailing em $ — telemetria CSV         |
//|          + GetSignal com range sempre calculado                  |
//|          + Fixes: TP com prioridade, slPrice>0, overnight,       |
//|            volume step na piramidacao, IsTradeAllowed            |
//+------------------------------------------------------------------+
#property copyright "WSB v2.3"
#property version   "2.38"
#define WSB_VERSION "2.38"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Canvas\Canvas.mqh>

CTrade        trade;
CPositionInfo posInfo;

enum ENUM_PANEL_THEME { THEME_CYBER = 0, THEME_MATRIX = 1, THEME_SOLAR = 2, THEME_ICE = 3 };
enum ENUM_DAILY_PNL_SRC { PNL_OWN_REALIZED = 0, PNL_ACCOUNT_EQUITY = 1 };

//==================== INPUTS ====================
input group "=== MONEY (SEM SL -> lote fixo) ==="
input double InpFixedLot          = 0.01;
input double InpTakeProfitUsd     = 10.0;   // TP em $ - so vale ate o trail ativar (0 = sem TP)
input bool   InpUseEmergencyStop  = true;   // saida por perda em $ (fecha a mercado, por software)
input double InpEmergencyStopUsd  = 100.0;  // perda flutuante em $ que fecha a posicao
input bool   InpEmergencyOnServer = false;  // v2.38: true = tambem coloca SL real no servidor (o operador NAO usa SL: padrao false)

input group "=== ADAPTIVE MONEY TRAIL ==="
input bool   InpTrailEnable               = true;
input double InpTrailActivationMoney      = 5.00;   // $ de lucro flutuante que ativa o trail
input bool   InpTrailRemoveTPOnActivation = true;   // trail ativo => TP removido (runner)
input bool   InpStructuralTrailEnable     = true;   // 2a fonte: stop sob HL / sobre LH

input group "=== CIRCUIT BREAKER DIARIO ==="
input double InpMaxDailyLossPct   = 5.0;
input double InpMaxDailyGainPct   = 10.0;
input double InpDailyGoalUsd      = 20.0;   // meta diaria em $ (P&L do dia na base escolhida abaixo). 0 = desligada
input ENUM_DAILY_PNL_SRC InpDailyPnlSource = PNL_OWN_REALIZED; // base do P&L diario: so este EA fechado (recomendado) / equity da conta
input int    InpMaxTradesPerDay   = 8;

input group "=== ENTRADA (breakout + volatilidade) ==="
input int    InpAtrPeriod         = 14;
input double InpBreakoutMult      = 0.95;   // ATR atual >= fator * ATR prev (0.95 = tolera leve queda)
input int    InpRangeBars         = 12;
input int    InpMinAdx            = 15;

input group "=== PIRAMIDACAO ==="
input bool   InpUsePyramiding     = true;
input int    InpMaxPyramidAdds    = 3;
input double InpPyramidStepAtr    = 1.5;
input double InpPyramidLotFactor  = 0.6;

input group "=== SPREAD ==="
input int    InpMaxSpreadPoints   = 0;      // bloqueia ENTRADA/PIRAMIDE se spread > N pontos. 0 = desligado

input group "=== SESSAO ==="
input bool   InpUseSessionFilter  = true;
input int    InpStartHour         = 8;
input int    InpEndHour           = 20;

input group "=== PAINEL HUD ==="
input bool   InpShowPanel         = true;
input ENUM_PANEL_THEME InpPanelTheme = THEME_CYBER;
input int    InpPanelScalePct     = 80;     // v2.38: escala do painel (50-150 %). Diminui sozinho se nao couber no grafico
input int    InpPanelX            = 20;
input int    InpPanelY            = 24;
input bool   InpPanelStartMinimized = false;
input int    InpPanelUpdateMs     = 250;

input group "=== TELEMETRIA CSV ==="
input bool   InpUseTelemetry      = true;
input int    InpHeartbeatSec      = 60;

input group "=== EXTRAS ==="
input int    InpMagicNumber       = 61937420;   // UNICO deste EA (nao reutilize em outro EA/grafico)
input int    InpMaxHoldMinutes    = 0;      // 0 = desligado. Fecha posicao presa (sem SL) apos N min
input int    InpDeviation         = 30;     // desvio maximo em pontos
input int    InpEntryRetries      = 3;      // tentativas de entrada na mesma barra (falha transitoria)
input string InpComment           = "WSB2";

//==================== GLOBAIS ====================
int      hAtr, hAdx;
double   gAtrBuffer[], gAdxBuffer[];
datetime gLastBarTime = 0;
double   gDayStartEquity = 0;
int      gDayTrades = 0;
int      gCurrentDay = -1;
bool     gGoalHit = false;      // meta diaria $ ja atingida hoje (loga 1x)

//--- P&L do dia SOMENTE deste EA (simbolo + magic, trades fechados) - cache
double   gOwnRealized = 0;
int      gOwnWins = 0, gOwnLosses = 0;
uint     gOwnStamp = 0;

//--- entrada pendente (retry na mesma barra)
int      gPendSig = 0, gPendTries = 0;
datetime gPendBar = 0, gPendLast = 0;
double   gPAtr=0, gPAtrP=0, gPAdx=0, gPHi=0, gPLo=0, gPCp=0;
string   gPReason = "";
datetime gEmergFailLast = 0;

//--- telemetria
ulong    gSeq = 0;
datetime gLastHeartbeat = 0;

//--- HUD: estado exposto ao painel (apenas leitura pela logica de trading)
bool     gPaused = false;                       // botao PAUSAR: bloqueia novas entradas/piramides
long     gCntBars = 0, gCntSig = 0, gCntPass = 0, gCntBlocked = 0;
long     gCntSent = 0, gCntFail = 0, gCntOrdBlock = 0, gCntExit = 0, gCntPyr = 0;
int      gLastSig = 0;
double   gLastAtr = 0, gLastAtrP = 0, gLastAdx = 0, gLastHi = 0, gLastLo = 0, gLastCp = 0;
string   gLastDecision = "-", gLastReason = "-", gLastOrdBlock = "";
datetime gLastEvalTime = 0;
ulong    gStartMs = 0;
string   gUiTicker = "WSB iniciando...";
string   gEvLog[10];
ulong    gUiTicks = 0, gUiTicksPrev = 0;
uint     gUiRateStamp = 0;
double   gUiTickRate = 0;

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
   // --- HUD: contadores e log de eventos (independe de InpUseTelemetry)
   if(event == "ORDER_SENT")       gCntSent++;
   else if(event == "ORDER_FAIL")  gCntFail++;
   else if(event == "ORDER_BLOCK") { gCntOrdBlock++; gLastOrdBlock = reason; }
   else if(event == "PYRAMID" && decision == "OK") gCntPyr++;
   else if(StringFind(event, "EXIT_") == 0) gCntExit++;
   if(event != "HEARTBEAT")
   {
      string uiLine = StringSubstr(TimeToString(TimeCurrent(), TIME_SECONDS), 0, 8) + " " + event + " " + decision + " " + reason;
      gUiTicker = uiLine;
      for(int ui = 9; ui > 0; ui--) gEvLog[ui] = gEvLog[ui-1];
      gEvLog[0] = uiLine;
   }

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
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpDeviation);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetMarginMode();

   hAtr = iATR(_Symbol, PERIOD_M15, InpAtrPeriod);
   hAdx = iADX(_Symbol, PERIOD_M15, 14);
   if(hAtr == INVALID_HANDLE || hAdx == INVALID_HANDLE)
   {
      if(hAtr != INVALID_HANDLE) IndicatorRelease(hAtr);
      if(hAdx != INVALID_HANDLE) IndicatorRelease(hAdx);
      PrintFormat("WSB2: falha ao criar indicadores (ATR=%d ADX=%d)", hAtr, hAdx);
      return INIT_FAILED;
   }

   ArraySetAsSeries(gAtrBuffer, true);
   ArraySetAsSeries(gAdxBuffer, true);

   if(InpTrailEnable && InpTrailActivationMoney <= 0)
   {
      Print("WSB2: InpTrailActivationMoney deve ser > 0");
      IndicatorRelease(hAtr);
      IndicatorRelease(hAdx);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpTrailEnable && !TrailEngine_Init())
      Print("WSB2: Trail Engine sem ATR -> buffer estrutural = 2 ticks");
   if(InpTrailEnable && InpTakeProfitUsd > 0 && InpTakeProfitUsd <= InpTrailActivationMoney)
      PrintFormat("WSB2: AVISO TP $%.2f <= ativacao $%.2f -> o TP fecha antes do trail ativar",
                  InpTakeProfitUsd, InpTrailActivationMoney);

   ResetDailyStats();
   OwnRealizedRefresh(true);

   gStartMs = GetTickCount64();
   gUiRateStamp = GetTickCount();
   if(InpShowPanel && !(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))) PanelCreate();
   EventSetMillisecondTimer(250);

   PrintFormat("WSB2: %s | lot_in=%.2f vol_min=%.2f vol_step=%.2f vol_max=%.2f stops_lvl=%d | lot_efetivo=%.2f",
               _Symbol, InpFixedLot,
               SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP),
               SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX),
               (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL), NormalizeLot(InpFixedLot));

   TEvent("INIT", "OK", "EA inicializada",
          0, 0, 0, 0,
          StringFormat("lot=%.2f tp=%.2f trail=%d act=%.2f rmTP=%d struct=%d mult=%.2f adx=%d bars=%d sess=%d-%d goal=%.2f spr=%d",
                       InpFixedLot, InpTakeProfitUsd, InpTrailEnable, InpTrailActivationMoney,
                       InpTrailRemoveTPOnActivation, InpStructuralTrailEnable,
                       InpBreakoutMult, InpMinAdx, InpRangeBars, InpStartHour, InpEndHour, InpDailyGoalUsd, InpMaxSpreadPoints));
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   PanelDestroy();
   IndicatorRelease(hAtr);
   IndicatorRelease(hAdx);
   TrailEngine_Deinit();
   TEvent("DEINIT", "OK", StringFormat("reason=%d", reason));
}

void ResetDailyStats()
{
   gDayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   gDayTrades = 0;
   gGoalHit = false;
   gCurrentDay = (int)(TimeCurrent() / 86400);
   TEvent("DAILY_RESET", "OK", "", 0, 0, 0, 0,
          StringFormat("equity=%.2f", gDayStartEquity));
}

//+------------------------------------------------------------------+
//| P&L do dia = SOMENTE trades FECHADOS deste EA (simbolo + magic). |
//| Ignora outros EAs/simbolos da mesma conta e o flutuante.         |
//+------------------------------------------------------------------+
void OwnRealizedRefresh(const bool force)
{
   uint now = GetTickCount();
   if(!force && gOwnStamp != 0 && now - gOwnStamp < 2000) return;
   gOwnStamp = now; if(gOwnStamp == 0) gOwnStamp = 1;
   datetime t  = TimeCurrent();
   datetime d0 = t - (t % 86400);
   if(!HistorySelect(d0, t + 3600)) return;
   int n = HistoryDealsTotal();
   ulong ids[]; int idn = 0;
   for(int i = 0; i < n; i++)
   {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      if(HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(d, DEAL_MAGIC) != InpMagicNumber) continue;
      ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      bool have = false;
      for(int k = 0; k < idn; k++) if(ids[k] == pid) { have = true; break; }
      if(!have) { ArrayResize(ids, idn + 1); ids[idn] = pid; idn++; }
   }
   double sum = 0.0; int w = 0, l = 0;
   for(int i = 0; i < n; i++)
   {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      if(HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      ulong pid = (ulong)HistoryDealGetInteger(d, DEAL_POSITION_ID);
      bool mine = false;
      for(int k = 0; k < idn; k++) if(ids[k] == pid) { mine = true; break; }
      if(!mine) continue;
      long typ = HistoryDealGetInteger(d, DEAL_TYPE);
      if(typ != DEAL_TYPE_BUY && typ != DEAL_TYPE_SELL) continue;
      long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      double net = HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_COMMISSION) +
                   HistoryDealGetDouble(d, DEAL_SWAP)   + HistoryDealGetDouble(d, DEAL_FEE);
      sum += net;
      if(en == DEAL_ENTRY_OUT || en == DEAL_ENTRY_OUT_BY || en == DEAL_ENTRY_INOUT) { if(net >= 0.0) w++; else l++; }
   }
   gOwnRealized = sum; gOwnWins = w; gOwnLosses = l;
}

// P&L do dia na base escolhida (meta, limite e barra do painel usam ESTA funcao)
double DailyPnlUsd()
{
   if(InpDailyPnlSource == PNL_ACCOUNT_EQUITY)
      return AccountInfoDouble(ACCOUNT_EQUITY) - gDayStartEquity;
   OwnRealizedRefresh(false);
   return gOwnRealized;
}

// Posicoes com ESTE magic neste simbolo que NAO foram abertas pelo WSB (outro EA com o mesmo magic)
int MagicConflict(int &n, string &cmt)
{
   n = 0; cmt = "";
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      string c = PositionGetString(POSITION_COMMENT);
      if(StringFind(c, InpComment) == 0) continue;
      n++; if(cmt == "") cmt = c;
   }
   return n;
}

bool CircuitBreakerOK(string &reason)
{
   int today = (int)(TimeCurrent() / 86400);
   if(today != gCurrentDay) ResetDailyStats();
   double pnlUsd = DailyPnlUsd();
   double pnlPct = (gDayStartEquity > 0) ? pnlUsd / gDayStartEquity * 100.0 : 0.0;
   if(pnlPct <= -InpMaxDailyLossPct) { reason = StringFormat("perda_diaria %.2f%%", pnlPct); return false; }
   if(pnlPct >=  InpMaxDailyGainPct) { reason = StringFormat("meta_diaria %.2f%%", pnlPct); return false; }
   if(InpDailyGoalUsd > 0 && pnlUsd >= InpDailyGoalUsd)
   {
      reason = StringFormat("meta_diaria_usd %.2f >= %.2f", pnlUsd, InpDailyGoalUsd);
      if(!gGoalHit)
      {
         gGoalHit = true;
         TEvent("DAILY_GOAL", "BLOCK", reason, 0, 0, 0, pnlUsd, "sem novas entradas ate o proximo dia");
      }
      return false;
   }
   if(gDayTrades >= InpMaxTradesPerDay) { reason = StringFormat("max_trades %d", gDayTrades); return false; }
   reason = StringFormat("pnl=%.2f%% ($%.2f) trades=%d", pnlPct, pnlUsd, gDayTrades);
   return true;
}

bool SessionOK(string &reason)
{
   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   if(!InpUseSessionFilter) { reason = "sem_filtro"; return true; }
   bool ok;
   if(InpStartHour <= InpEndHour)
      ok = (t.hour >= InpStartHour && t.hour < InpEndHour);
   else
      ok = (t.hour >= InpStartHour || t.hour < InpEndHour); // janela cruza a meia-noite
   reason = StringFormat("hora_servidor=%02d janela=%d-%d", t.hour, InpStartHour, InpEndHour);
   return ok;
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

double MoneyPerPointPerLot()
{
   double tickVal  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point    = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tickSize <= 0 || point <= 0) return 0;
   return tickVal * point / tickSize;
}

double PriceForProfit(ulong ticket, double targetUsd)
{
   if(!posInfo.SelectByTicket(ticket)) return 0;
   double open  = posInfo.PriceOpen();
   double vol   = posInfo.Volume();
   double mpp   = MoneyPerPointPerLot();
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(mpp <= 0 || vol <= 0) return 0;
   double points = targetUsd / (mpp * vol);
   double dist   = points * point;
   if(posInfo.PositionType() == POSITION_TYPE_BUY) return open + dist;
   return open - dist;
}

string GVName(ulong ticket, string suffix)
{ return "WSB2_"+suffix+"_"+IntegerToString((long)ticket); }

//+------------------------------------------------------------------+
//| Normaliza lote (min/max/step).                                   |
//| Causa comum de "nao abre ordens": 0.01 abaixo do volume minimo   |
//| do simbolo (indices/cripto costumam exigir 0.1 ou 1.0).          |
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
{
   double vMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double vStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(vStep <= 0 || vMin <= 0) return 0;
   lot = MathFloor(lot / vStep + 1e-9) * vStep;
   if(lot < vMin) lot = vMin;
   if(lot > vMax) lot = vMax;
   int dig = 0;
   for(double s = vStep; s < 1.0 - 1e-12 && dig < 8; s *= 10.0) dig++;
   return NormalizeDouble(lot, dig);
}

bool HasMargin(ENUM_ORDER_TYPE type, double lot)
{
   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                           : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double margin = 0;
   if(!OrderCalcMargin(type, _Symbol, lot, price, margin)) return true;
   return margin <= AccountInfoDouble(ACCOUNT_MARGIN_FREE);
}

// Spread atual em PONTOS do simbolo
double SpreadPoints()
{
   double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(pt <= 0) return 0;
   return (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / pt;
}

double MinStopDistance()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   long sl = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   long fz = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   return MathMax((double)MathMax(sl, fz), 5.0) * point;
}

// Remove GlobalVariables de posicoes que ja fecharam (ex.: fechadas pelo SL no servidor)
void PurgeStaleGV()
{
   for(int i = GlobalVariablesTotal()-1; i >= 0; i--)
   {
      string n = GlobalVariableName(i);
      if(StringFind(n, "WSB2_TRAIL_") != 0 && StringFind(n, "WSB2_MAX_") != 0 && StringFind(n, "WSB2_HWMP_") != 0) continue;
      int p = StringFind(n, "_", 5);
      if(p < 0) continue;
      ulong tk = (ulong)StringToInteger(StringSubstr(n, p+1));
      if(tk > 0 && !PositionSelectByTicket(tk)) GlobalVariableDel(n);
   }
}

//+------------------------------------------------------------------+
//| ADAPTIVE MONEY TRAIL ENGINE  (modulo isolado: EXIT / PROTECTION) |
//|                                                                  |
//|  Money activation + High-Water Mark + distancia sublinear        |
//|     D(P) = 0.60 * A * (P/A)^0.82                                 |
//|  + conversao $ -> preco via OrderCalcProfit (busca binaria)      |
//|  + trail estrutural (HL / LH, so em nova barra)                  |
//|  + regra "nunca afrouxa".                                        |
//|                                                                  |
//|  Estado POR POSICAO (a piramidacao mantem varias abertas).       |
//|  Dependencias do host: trade, posInfo, TEvent(), GVName(),       |
//|  MinStopDistance(), InpTrail*.                                   |
//|  O host chama apenas:                                            |
//|     TrailEngine_Init / _Deinit                                   |
//|     TrailEngine_Update(ticket)   (por tick, por posicao)         |
//|     TrailEngine_Forget(ticket)   (posicao fechada pelo host)     |
//|     TrailEngine_Prune()          (limpa estados de fechadas)     |
//+------------------------------------------------------------------+
#define PT_TRAIL_INITIAL_RATIO 0.60
#define PT_TRAIL_EXPONENT      0.82
#define PT_TRAIL_TF            PERIOD_M15   // TF da estrutura (new bar)
#define PT_TRAIL_SWING_N       2            // barras de cada lado do pivo
#define PT_TRAIL_LOOKBACK      300          // barras lidas p/ achar pivos
#define PT_TRAIL_ATR_PERIOD    14           // escala do buffer estrutural
#define PT_TRAIL_VERBOSE       0            // 1 = loga HWM / stop calculado a cada mudanca

enum ENUM_TRAIL_RESULT
{
   TRAIL_OFF    = 0,   // trail ainda nao ativo (TP $ segue valendo)
   TRAIL_ACTIVE = 1,   // trail ativo (TP $ removido se InpTrailRemoveTPOnActivation)
   TRAIL_CLOSED = 2    // o engine fechou a posicao (stop cruzado)
};

struct AdaptiveTrailState
{
   bool     active;
   ulong    position_ticket;
   int      direction;              // +1 BUY, -1 SELL
   double   entry_price;
   double   volume;
   double   max_profit;             // High-Water Mark ($)
   double   hwm_price;              // preco que gerou o HWM
   double   trail_distance_money;
   double   trail_distance_price;
   double   locked_profit;          // max_profit - distancia
   double   monetary_stop;
   double   structural_stop;
   double   trail_stop_price;       // stop final (mais protetivo)
   double   last_sent_stop;
   datetime activation_time;
   datetime last_bar;               // ultima barra estrutural processada
   datetime last_tp_try;
   datetime last_close_try;
   datetime last_mod_fail;
   bool     tp_removed;
   int      move_count;
};

AdaptiveTrailState gAT[];
int                gATAtr = INVALID_HANDLE;

//--- ciclo de vida -------------------------------------------------
bool TrailEngine_Init()
{
   ArrayResize(gAT, 0);
   gATAtr = iATR(_Symbol, PT_TRAIL_TF, PT_TRAIL_ATR_PERIOD);
   return (gATAtr != INVALID_HANDLE);
}

void TrailEngine_Deinit()
{
   if(gATAtr != INVALID_HANDLE) IndicatorRelease(gATAtr);
   gATAtr = INVALID_HANDLE;
}

int TE_Find(ulong ticket)
{
   for(int i = 0; i < ArraySize(gAT); i++)
      if(gAT[i].position_ticket == ticket) return i;
   return -1;
}

void TE_Remove(int idx)
{
   int n = ArraySize(gAT);
   for(int i = idx; i < n - 1; i++) gAT[i] = gAT[i+1];
   ArrayResize(gAT, n - 1);
}

// Cria (ou restaura apos restart do EA) o estado de um ticket.
// Nunca reutiliza HWM de outra posicao: o estado e chaveado pelo ticket.
int TE_Bind(ulong ticket)
{
   int i = TE_Find(ticket);
   if(i >= 0) return i;

   i = ArraySize(gAT);
   ArrayResize(gAT, i + 1);
   ZeroMemory(gAT[i]);
   gAT[i].position_ticket = ticket;

   string gT = GVName(ticket, "TRAIL");
   string gM = GVName(ticket, "MAX");
   string gH = GVName(ticket, "HWMP");
   if(GlobalVariableCheck(gT) && GlobalVariableGet(gT) > 0 && GlobalVariableCheck(gM))
   {
      gAT[i].active     = true;                       // trail ja estava ativo
      gAT[i].max_profit = GlobalVariableGet(gM);      // HWM preservado
      gAT[i].hwm_price  = GlobalVariableCheck(gH) ? GlobalVariableGet(gH) : 0;
   }
   return i;
}

void TrailEngine_Forget(ulong ticket)
{
   GlobalVariableDel(GVName(ticket, "TRAIL"));
   GlobalVariableDel(GVName(ticket, "MAX"));
   GlobalVariableDel(GVName(ticket, "HWMP"));
   int i = TE_Find(ticket);
   if(i >= 0) TE_Remove(i);
}

void TrailEngine_Prune()
{
   for(int i = ArraySize(gAT) - 1; i >= 0; i--)
      if(!PositionSelectByTicket(gAT[i].position_ticket)) TE_Remove(i);
}

void TE_Persist(const AdaptiveTrailState &st)
{
   GlobalVariableSet(GVName(st.position_ticket, "TRAIL"), 1);
   GlobalVariableSet(GVName(st.position_ticket, "MAX"),   st.max_profit);
   GlobalVariableSet(GVName(st.position_ticket, "HWMP"),  st.hwm_price);
}

string TE_Note(const AdaptiveTrailState &st)
{
   return StringFormat("max=%.2f dist=%.2f dist_px=%.5f locked=%.2f hwm_px=%.5f mon=%.5f str=%.5f fin=%.5f moves=%d tp_off=%d",
                       st.max_profit, st.trail_distance_money, st.trail_distance_price,
                       st.locked_profit, st.hwm_price, st.monetary_stop, st.structural_stop,
                       st.trail_stop_price, st.move_count, st.tp_removed ? 1 : 0);
}

//--- matematica ----------------------------------------------------
// D(P) = 0.60 * A * (P/A)^0.82   (P = HWM; sempre >= A)
double TE_DistanceMoney(double maxProfit)
{
   double A = InpTrailActivationMoney;
   if(A <= 0) return 0;
   double P = MathMax(maxProfit, A);
   return PT_TRAIL_INITIAL_RATIO * A * MathPow(P / A, PT_TRAIL_EXPONENT);
}

// Arredonda ao tick. up=true -> para cima (BUY: stop mais perto do preco = mais protetivo)
double TE_ToTick(double price, bool up)
{
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   int    dg = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(ts <= 0) return NormalizeDouble(price, dg);
   double n = price / ts;
   n = up ? MathCeil(n - 1e-9) : MathFloor(n + 1e-9);
   return NormalizeDouble(n * ts, dg);
}

// Quanto $ vale um deslocamento 'd' A FAVOR partindo de 'ref'
bool TE_MoveMoney(bool isBuy, double vol, double ref, double d, double &money)
{
   double p = 0;
   bool ok = isBuy ? OrderCalcProfit(ORDER_TYPE_BUY,  _Symbol, vol, ref, ref + d, p)
                   : OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, vol, ref, ref - d, p);
   money = p;
   return ok;
}

// Plano B se OrderCalcProfit falhar: tick value
double TE_FallbackDelta(double vol, double money)
{
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tv <= 0 || ts <= 0 || vol <= 0) return -1;
   return money * ts / (tv * vol);
}

// Acha dP (em preco) tal que Profit(dP) = money. Busca binaria sobre OrderCalcProfit.
double TE_PriceDeltaForMoney(bool isBuy, double vol, double ref, double money)
{
   double tick = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(money <= 0 || vol <= 0 || ref <= 0 || tick <= 0) return -1;

   double cap = isBuy ? ref * 10.0 : ref * 0.999;   // SELL: preco nao pode ir a <= 0
   double hi = tick, m = 0;
   if(!TE_MoveMoney(isBuy, vol, ref, hi, m)) return TE_FallbackDelta(vol, money);

   for(int it = 0; it < 60 && m < money && hi < cap; it++)   // bracket
   {
      hi = MathMin(hi * 2.0, cap);
      if(!TE_MoveMoney(isBuy, vol, ref, hi, m)) return TE_FallbackDelta(vol, money);
   }
   if(m < money) return -1;

   double lo = 0;
   for(int k = 0; k < 50; k++)                               // bisseccao
   {
      double mid = 0.5 * (lo + hi);
      if(!TE_MoveMoney(isBuy, vol, ref, mid, m)) return TE_FallbackDelta(vol, money);
      if(m < money) lo = mid; else hi = mid;
   }
   return hi;
}

// Recalcula distancia, locked e stop monetario a partir do HWM. Nunca afrouxa.
void TE_RecalcMoney(AdaptiveTrailState &st)
{
   const bool isBuy = (st.direction > 0);
   st.trail_distance_money = TE_DistanceMoney(st.max_profit);
   st.locked_profit        = st.max_profit - st.trail_distance_money;

   double dp = TE_PriceDeltaForMoney(isBuy, st.volume, st.hwm_price, st.trail_distance_money);
   if(dp <= 0)
   {
      if(st.monetary_stop == 0)
         TEvent("TRAIL_ERROR", "FAIL", "conversao_money_price", st.position_ticket,
                st.hwm_price, st.volume, st.max_profit, TE_Note(st));
      return;
   }
   st.trail_distance_price = dp;

   double stop = isBuy ? TE_ToTick(st.hwm_price - dp, true)
                       : TE_ToTick(st.hwm_price + dp, false);
   if(st.monetary_stop == 0 || (isBuy ? stop > st.monetary_stop : stop < st.monetary_stop))
      st.monetary_stop = stop;
}

// Restart do EA com GV antiga sem preco do HWM: reconstroi a partir da entrada
void TE_RestoreHwmPrice(AdaptiveTrailState &st, double px, double profit)
{
   const bool isBuy = (st.direction > 0);
   int    dg = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double dp = TE_PriceDeltaForMoney(isBuy, st.volume, st.entry_price, st.max_profit);
   if(dp > 0)
      st.hwm_price = NormalizeDouble(isBuy ? st.entry_price + dp : st.entry_price - dp, dg);
   else
   {
      st.hwm_price  = px;
      st.max_profit = MathMax(st.max_profit, profit);
   }
   GlobalVariableSet(GVName(st.position_ticket, "HWMP"), st.hwm_price);
}

//--- trail estrutural (so em NOVA BARRA) --------------------------
// BUY: maior pivo de fundo (HL) confirmado apos a abertura - buffer
// SELL: menor pivo de topo (LH) confirmado apos a abertura + buffer
void TE_UpdateStructural(AdaptiveTrailState &st)
{
   const bool     isBuy    = (st.direction > 0);
   const int      N        = PT_TRAIL_SWING_N;
   const datetime openTime = posInfo.Time();

   double   hi[], lo[];
   datetime tm[];
   ArraySetAsSeries(hi, true);
   ArraySetAsSeries(lo, true);
   ArraySetAsSeries(tm, true);
   int n = MathMin(CopyHigh(_Symbol, PT_TRAIL_TF, 0, PT_TRAIL_LOOKBACK, hi),
           MathMin(CopyLow (_Symbol, PT_TRAIL_TF, 0, PT_TRAIL_LOOKBACK, lo),
                   CopyTime(_Symbol, PT_TRAIL_TF, 0, PT_TRAIL_LOOKBACK, tm)));
   if(n <= 2 * N + 1) return;

   double best = 0;
   for(int s = N + 1; s < n - N; s++)       // s>=N+1: pivo ja confirmado por N barras fechadas
   {
      if(tm[s] <= openTime) break;          // so estrutura formada depois da entrada
      bool piv = true;
      for(int k = 1; k <= N && piv; k++)
      {
         if(isBuy) { if(!(lo[s] < lo[s-k] && lo[s] < lo[s+k])) piv = false; }
         else      { if(!(hi[s] > hi[s-k] && hi[s] > hi[s+k])) piv = false; }
      }
      if(!piv) continue;
      double lvl = isBuy ? lo[s] : hi[s];
      if(best == 0 || (isBuy ? lvl > best : lvl < best)) best = lvl;
   }
   if(best == 0) return;

   double tick = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double atr  = 0, ab[1];
   if(gATAtr != INVALID_HANDLE && CopyBuffer(gATAtr, 0, 1, 1, ab) == 1) atr = ab[0];
   double buf  = MathMax(2.0 * tick, 0.10 * atr);   // escala estrutural = ATR(M15)

   double cand = isBuy ? TE_ToTick(best - buf, true) : TE_ToTick(best + buf, false);
   if(st.structural_stop == 0 || (isBuy ? cand > st.structural_stop : cand < st.structural_stop))
   {
      st.structural_stop = cand;               // estrutural tambem nunca afrouxa
      TEvent("TRAIL_STRUCTURAL_UPDATED", "OK",
             StringFormat("%s pivot=%.5f buf=%.5f stop=%.5f", isBuy ? "HL" : "LH", best, buf, cand),
             st.position_ticket, 0, st.volume, 0, "");
   }
}

//--- nucleo por posicao -------------------------------------------
ENUM_TRAIL_RESULT TE_Process(AdaptiveTrailState &st)
{
   const ulong  ticket = st.position_ticket;
   const bool   isBuy  = (posInfo.PositionType() == POSITION_TYPE_BUY);
   const double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double px     = isBuy ? bid : ask;          // BUY mede em Bid, SELL em Ask
   const double profit = posInfo.Profit();
   if(bid <= 0 || ask <= 0) return st.active ? TRAIL_ACTIVE : TRAIL_OFF;

   st.direction   = isBuy ? 1 : -1;
   st.entry_price = posInfo.PriceOpen();
   st.volume      = posInfo.Volume();

   //--- 1) ativacao: so uma vez por posicao, nunca reativa
   if(!st.active)
   {
      if(profit < InpTrailActivationMoney) return TRAIL_OFF;
      st.active          = true;
      st.max_profit      = profit;
      st.hwm_price       = px;
      st.activation_time = TimeCurrent();
      TE_Persist(st);
      TE_RecalcMoney(st);
      TEvent("TRAIL_ACTIVATED", "OK", "profit>=activation", ticket, px, st.volume, profit,
             StringFormat("act=%.2f ratio=%.2f exp=%.2f %s", InpTrailActivationMoney,
                          PT_TRAIL_INITIAL_RATIO, PT_TRAIL_EXPONENT, TE_Note(st)));
   }
   else if(st.hwm_price <= 0)
      TE_RestoreHwmPrice(st, px, profit);

   //--- 2) High-Water Mark: so sobe, nunca recebe o lucro atual direto
   if(profit > st.max_profit)
   {
      st.max_profit = profit;
      st.hwm_price  = px;
      TE_Persist(st);
      TE_RecalcMoney(st);
      if(PT_TRAIL_VERBOSE)
         TEvent("TRAIL_HWM_UPDATED", "OK", "", ticket, px, st.volume, profit, TE_Note(st));
   }
   else if(st.monetary_stop == 0)
      TE_RecalcMoney(st);                         // restart / falha anterior de conversao

   //--- 3) TP removido assim que o trail esta ativo
   if(InpTrailRemoveTPOnActivation && !st.tp_removed)
   {
      if(posInfo.TakeProfit() == 0)
      {
         st.tp_removed = true;                    // TP $ do EA e por software: o host para de checar
         TEvent("TRAIL_TP_REMOVED", "OK", "tp_usd_desligado", ticket, px, st.volume, profit, TE_Note(st));
      }
      else if(TimeCurrent() - st.last_tp_try >= 5)
      {
         st.last_tp_try = TimeCurrent();
         bool okTp = trade.PositionModify(ticket, posInfo.StopLoss(), 0);
         if(okTp) st.tp_removed = true;
         TEvent(okTp ? "TRAIL_TP_REMOVED" : "TRAIL_BROKER_REJECT", okTp ? "OK" : "FAIL", "tp_servidor",
                ticket, px, st.volume, profit, StringFormat("retcode=%d", trade.ResultRetcode()));
         posInfo.SelectByTicket(ticket);
      }
   }

   //--- 4) trail estrutural: apenas em NOVA BARRA
   if(InpStructuralTrailEnable)
   {
      datetime bt = iTime(_Symbol, PT_TRAIL_TF, 0);
      if(bt != 0 && bt != st.last_bar)
      {
         st.last_bar = bt;
         TE_UpdateStructural(st);
      }
   }

   //--- 5) stop final = mais protetivo entre monetario e estrutural
   double cand = st.monetary_stop;
   if(st.structural_stop > 0)
      cand = (cand <= 0) ? st.structural_stop
                         : (isBuy ? MathMax(cand, st.structural_stop)
                                  : MathMin(cand, st.structural_stop));
   if(PT_TRAIL_VERBOSE && cand > 0 && cand != st.trail_stop_price)
      TEvent("TRAIL_STOP_CALCULATED", "OK", StringFormat("cand=%.5f", cand), ticket, px, st.volume, profit, TE_Note(st));
   st.trail_stop_price = cand;
   if(cand <= 0) return TRAIL_ACTIVE;

   //--- 6) preco ja cruzou o stop (nao da pra colocar SL no servidor): fecha a mercado
   if(isBuy ? (bid <= cand) : (ask >= cand))
   {
      if(TimeCurrent() - st.last_close_try < 2) return TRAIL_ACTIVE;
      st.last_close_try = TimeCurrent();
      bool okC = trade.PositionClose(ticket);
      TEvent("EXIT_TRAIL", okC ? "OK" : "FAIL", StringFormat("px=%.5f cruzou stop=%.5f", px, cand),
             ticket, px, st.volume, profit,
             StringFormat("retcode=%d %s", trade.ResultRetcode(), TE_Note(st)));
      return okC ? TRAIL_CLOSED : TRAIL_ACTIVE;
   }

   //--- 7) nunca afrouxa + movimento minimo + limites do broker
   const double slCur = posInfo.StopLoss();
   double newSl = (slCur > 0) ? (isBuy ? MathMax(slCur, cand) : MathMin(slCur, cand)) : cand;

   const double tick    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   const double point   = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const double minMove = (tick > 0) ? tick : point;
   if(slCur > 0)
   {
      double gain = isBuy ? (newSl - slCur) : (slCur - newSl);
      if(gain < minMove * 0.999) return TRAIL_ACTIVE;                 // nada a melhorar
      double fz = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * point;
      if(fz > 0 && (isBuy ? (bid - slCur) <= fz : (slCur - ask) <= fz))
         return TRAIL_ACTIVE;                                          // SL atual dentro do freeze level
   }
   const double md = MinStopDistance();
   if(isBuy ? (newSl > bid - md) : (newSl < ask + md)) return TRAIL_ACTIVE;   // viola stops level
   if(TimeCurrent() - st.last_mod_fail < 2) return TRAIL_ACTIVE;

   //--- 8) envia (slPrice > 0 garantido: cand > 0)
   const double tpKeep = InpTrailRemoveTPOnActivation ? 0.0 : posInfo.TakeProfit();
   bool okM = trade.PositionModify(ticket, newSl, tpKeep);
   if(okM)
   {
      st.last_sent_stop = newSl;
      st.move_count++;
      TEvent("TRAIL_STOP_MOVED", "OK", StringFormat("sl=%.5f old=%.5f", newSl, slCur),
             ticket, px, st.volume, profit,
             StringFormat("retcode=%d %s", trade.ResultRetcode(), TE_Note(st)));
   }
   else
   {
      st.last_mod_fail = TimeCurrent();
      TEvent("TRAIL_BROKER_REJECT", "FAIL", StringFormat("sl=%.5f old=%.5f", newSl, slCur),
             ticket, px, st.volume, profit, StringFormat("retcode=%d", trade.ResultRetcode()));
   }
   posInfo.SelectByTicket(ticket);
   return TRAIL_ACTIVE;
}

// Chamado pelo host, 1x por tick por posicao. NAO decide entrada.
ENUM_TRAIL_RESULT TrailEngine_Update(ulong ticket)
{
   if(!InpTrailEnable) return TRAIL_OFF;
   if(!posInfo.SelectByTicket(ticket)) return TRAIL_OFF;
   int idx = TE_Bind(ticket);
   ENUM_TRAIL_RESULT r = TE_Process(gAT[idx]);
   if(r == TRAIL_CLOSED) TrailEngine_Forget(ticket);
   return r;
}

//--- consultas (por ticket) ----------------------------------------
bool   TrailEngine_IsActive(ulong ticket)      { int i = TE_Find(ticket); return (i >= 0 && gAT[i].active); }
double TrailEngine_MaxProfit(ulong ticket)     { int i = TE_Find(ticket); return (i >= 0) ? gAT[i].max_profit : 0; }
double TrailEngine_DistanceMoney(ulong ticket) { int i = TE_Find(ticket); return (i >= 0) ? gAT[i].trail_distance_money : 0; }
double TrailEngine_LockedProfit(ulong ticket)  { int i = TE_Find(ticket); return (i >= 0) ? gAT[i].locked_profit : 0; }
double TrailEngine_StopPrice(ulong ticket)     { int i = TE_Find(ticket); return (i >= 0) ? gAT[i].trail_stop_price : 0; }

// Resumo para o heartbeat (sem ';' para nao quebrar o CSV)
string TrailEngine_Summary()
{
   string s = "";
   for(int i = 0; i < ArraySize(gAT); i++)
      if(gAT[i].active)
         s += StringFormat(" | T%I64u %s", gAT[i].position_ticket, TE_Note(gAT[i]));
   return s;
}

//+------------------------------------------------------------------+
//| Gestao por posicao: TP $, trailing $                             |
//+------------------------------------------------------------------+
void ManagePositions()
{
   double point  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double digits = (double)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   TrailEngine_Prune();
   for(int i = PositionsTotal()-1; i>=0; i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Symbol() != _Symbol) continue;
      if(posInfo.Magic()  != InpMagicNumber) continue;

      ulong  ticket = posInfo.Ticket();
      double profit = posInfo.Profit();

      // SL de emergencia no SERVIDOR: protege se o EA/terminal cair.
      if(InpUseEmergencyStop && InpEmergencyOnServer && posInfo.StopLoss() == 0)
      {
         double eSl = NormalizeDouble(PriceForProfit(ticket, -InpEmergencyStopUsd), (int)digits);
         double px  = posInfo.PriceCurrent();
         bool   isBuy = (posInfo.PositionType() == POSITION_TYPE_BUY);
         bool   valid = (eSl > 0) && (isBuy ? (px - eSl >= MinStopDistance()) : (eSl - px >= MinStopDistance()));
         if(valid && TimeCurrent() - gEmergFailLast >= 30 && !trade.PositionModify(ticket, eSl, 0))
         {
            gEmergFailLast = TimeCurrent();   // evita spam de tentativas a cada tick
            PrintFormat("WSB2: SL emergencia falhou ticket=%I64u retcode=%d", ticket, trade.ResultRetcode());
         }
         if(!posInfo.SelectByTicket(ticket)) continue;
      }

      // Posicao presa (sem SL de estrategia): saida por tempo, opcional
      if(InpMaxHoldMinutes > 0 && (TimeCurrent() - posInfo.Time()) / 60 >= InpMaxHoldMinutes)
      {
         bool ok = trade.PositionClose(ticket);
         TEvent("EXIT_TIME", ok?"OK":"FAIL", "max_hold", ticket, posInfo.PriceCurrent(),
                posInfo.Volume(), profit, StringFormat("retcode=%d", trade.ResultRetcode()));
         TrailEngine_Forget(ticket);
         continue;
      }

      // v2.38: perda em $ incluindo swap; so por software (sem SL no servidor, salvo InpEmergencyOnServer)
      if(InpUseEmergencyStop && (profit + posInfo.Swap()) <= -InpEmergencyStopUsd)
      {
         bool ok = trade.PositionClose(ticket);
         TEvent("EXIT_EMERGENCY", ok?"OK":"FAIL", "profit<=-limit",
                ticket, posInfo.PriceCurrent(), posInfo.Volume(), profit,
                StringFormat("retcode=%d", trade.ResultRetcode()));
         TrailEngine_Forget(ticket);
         continue;
      }

      // Trail adaptativo: ativacao -> HWM -> stop (money + estrutural).
      // Roda ANTES do TP: ao ativar, o TP $ deixa de valer
      // (InpTrailRemoveTPOnActivation) e a posicao vira runner.
      ENUM_TRAIL_RESULT tr = TrailEngine_Update(ticket);
      if(tr == TRAIL_CLOSED) continue;

      bool tpOff = (tr == TRAIL_ACTIVE && InpTrailRemoveTPOnActivation);
      if(!tpOff && InpTakeProfitUsd > 0 && profit >= InpTakeProfitUsd)
      {
         bool ok = trade.PositionClose(ticket);
         TEvent("EXIT_TP", ok?"OK":"FAIL", "profit>=tp",
                ticket, posInfo.PriceCurrent(), posInfo.Volume(), profit,
                StringFormat("retcode=%d", trade.ResultRetcode()));
         TrailEngine_Forget(ticket);
         continue;
      }
   }
}

//+------------------------------------------------------------------+
//| Piramidacao (sem SL novo)                                        |
//+------------------------------------------------------------------+
void TryPyramid(double atr)
{
   if(!InpUsePyramiding) return;

   string cbr = "";
   if(!CircuitBreakerOK(cbr)) return;   // nao piramida com limite diario atingido

   int dir = 0;
   int n = CountMyPositions(dir);
   if(n == 0 || n > InpMaxPyramidAdds) return;
   if(InpMaxSpreadPoints > 0 && SpreadPoints() > InpMaxSpreadPoints) return;   // spread alto: nao piramida

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
      double newLot = NormalizeLot(baseVol * MathPow(InpPyramidLotFactor, addsSoFar+1));
      ENUM_ORDER_TYPE ot = (dir==1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      if(newLot <= 0 || !HasMargin(ot, newLot)) return;

      bool ok;
      if(dir==1) ok = trade.Buy (newLot, _Symbol, 0, 0, 0, InpComment+"_pyr");
      else       ok = trade.Sell(newLot, _Symbol, 0, 0, 0, InpComment+"_pyr");

      TEvent("PYRAMID", ok?"OK":"FAIL",
             StringFormat("dir=%d adds=%d move=%.5f step=%.5f", dir, addsSoFar, move, nextStep),
             trade.ResultOrder(), price, newLot, 0,
             StringFormat("retcode=%d", trade.ResultRetcode()));
   }
}

//+------------------------------------------------------------------+
//| Sinal: breakout com expansao de ATR                              |
//|                                                                  |
//| Ordem:                                                           |
//|   1) le ATR/ADX                                                  |
//|   2) calcula range (hi/lo) e closePrev SEMPRE                    |
//|   3) aplica filtros (ADX, ATR)                                   |
//|   4) decide rompimento                                           |
//|                                                                  |
//| Assim, a telemetria sempre registra range e closePrev,           |
//| mesmo quando o filtro de ATR/ADX bloqueia.                       |
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

   // --- 1) Range SEMPRE calculado antes de qualquer filtro ---
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

   // Helper inline: estado do rompimento (para enriquecer a reason)
   bool   rompUp = (cp > hi);
   bool   rompDn = (cp < lo);
   double ratio  = (atrP > 0) ? atr / atrP : 0;
   double distHi = hi - cp;   // >0 se ainda esta abaixo
   double distLo = cp - lo;   // >0 se ainda esta acima

   string ctx = StringFormat("ratio=%.3f cp=%.5f hi=%.5f lo=%.5f dHi=%.5f dLo=%.5f rompUp=%d rompDn=%d",
                             ratio, cp, hi, lo, distHi, distLo, rompUp?1:0, rompDn?1:0);

   // --- 2) Filtro de ADX ---
   if(adx < InpMinAdx)
   {
      reason = StringFormat("adx=%.2f < %d | %s", adx, InpMinAdx, ctx);
      return 0;
   }

   // --- 3) Filtro de expansao de ATR ---
   if(atr < atrP * InpBreakoutMult)
   {
      reason = StringFormat("atr=%.5f atrP=%.5f ratio=%.3f < %.2f | %s",
                            atr, atrP, ratio, InpBreakoutMult, ctx);
      return 0;
   }

   // --- 4) Rompimento ---
   if(rompUp) { reason = StringFormat("breakout_up | %s", ctx); return  1; }
   if(rompDn) { reason = StringFormat("breakout_dn | %s", ctx); return -1; }
   reason = StringFormat("sem_rompimento | %s", ctx);
   return 0;
}

//+------------------------------------------------------------------+
//| Envia a entrada pendente. Retorna true se enviada ou definitiva  |
//| (sem necessidade de nova tentativa).                             |
//+------------------------------------------------------------------+
bool SendEntry(int nPos)
{
   int    sig = gPendSig;
   double atr = gPAtr, atrPrev = gPAtrP, adx = gPAdx, rHi = gPHi, rLo = gPLo, cPrev = gPCp;
   string sigReason = gPReason;
   gPendTries++;
   gPendLast = TimeCurrent();

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED) || !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      if(gPendTries == 1)
         TLog("ORDER_BLOCK", sig, nPos, 1, 1, 1, atr, atrPrev, adx, rHi, rLo, cPrev,
              sig, "BLOCK", "AlgoTrading desligado", 0, 0, 0, 0, "");
      if(gPendTries >= InpEntryRetries) gPendSig = 0;
      return false;
   }

   // Filtro de spread (pontos): spread alto costuma ser transitorio -> tenta de novo na mesma barra
   double spPts = SpreadPoints();
   if(InpMaxSpreadPoints > 0 && spPts > InpMaxSpreadPoints)
   {
      if(gPendTries == 1)
         TLog("ORDER_BLOCK", sig, nPos, 1, 1, 1, atr, atrPrev, adx, rHi, rLo, cPrev,
              sig, "BLOCK", StringFormat("spread %.0f pts > %d", spPts, InpMaxSpreadPoints),
              0, 0, 0, 0, "");
      if(gPendTries >= InpEntryRetries) gPendSig = 0;
      return false;
   }

   double lot = NormalizeLot(InpFixedLot);
   ENUM_ORDER_TYPE otype = (sig==1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(lot <= 0 || !HasMargin(otype, lot))
   {
      string why = (lot <= 0) ? "lote_invalido" : "margem_insuficiente";
      PrintFormat("WSB2: ordem bloqueada (%s) lot_in=%.2f min=%.2f step=%.2f", why, InpFixedLot,
                  SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP));
      TLog("ORDER_BLOCK", sig, nPos, 1, 1, 1, atr, atrPrev, adx, rHi, rLo, cPrev,
           sig, "BLOCK", why, 0, 0, InpFixedLot, 0, "");
      gPendSig = 0;
      return true;
   }

   bool ok = false;
   if(sig==1)       ok = trade.Buy (lot, _Symbol, 0, 0, 0, InpComment);
   else if(sig==-1) ok = trade.Sell(lot, _Symbol, 0, 0, 0, InpComment);
   if(ok && trade.ResultRetcode() != TRADE_RETCODE_DONE && trade.ResultRetcode() != TRADE_RETCODE_PLACED)
      ok = false;

   if(ok)
   {
      gDayTrades++;
      gPendSig = 0;
      TLog("ORDER_SENT", sig, nPos, 1, 1, 1, atr, atrPrev, adx, rHi, rLo, cPrev,
           sig, "EXEC", sigReason,
           trade.ResultOrder(), trade.ResultPrice(), trade.ResultVolume(), 0,
           StringFormat("retcode=%d comment=%s trades=%d try=%d",
                        trade.ResultRetcode(), trade.ResultComment(), gDayTrades, gPendTries));
      return true;
   }

   PrintFormat("WSB2: ORDER_FAIL sig=%d lot=%.2f try=%d/%d retcode=%d (%s)", sig, lot, gPendTries,
               InpEntryRetries, trade.ResultRetcode(), trade.ResultRetcodeDescription());
   TLog("ORDER_FAIL", sig, nPos, 1, 1, 1, atr, atrPrev, adx, rHi, rLo, cPrev,
        sig, "FAIL", sigReason, 0, 0, lot, 0,
        StringFormat("retcode=%d comment=%s try=%d", trade.ResultRetcode(), trade.ResultComment(), gPendTries));
   if(gPendTries >= InpEntryRetries) gPendSig = 0;
   return false;
}

//====================================================================
// HUD ENGINE (canvas) - Galactic design system
//====================================================================


struct UiTheme { color bg1; color bg2; color accent; color accent2; color good; color bad; color warn; color text; color dim; color line; };
struct UiHit   { int x; int y; int w; int h; int id; };

CCanvas  g_canvas;
// v2.38: escala do painel. Todo o desenho usa coordenadas de projeto (560x700) e estes
// wrappers multiplicam por g_s; assim o layout/estetica ficam iguais, so menores.
double   g_s=1.0;
int      SC(const int v)  { return (int)MathRound(v*g_s); }
int      SCh(const int v) { return MathMax(1,(int)MathRound(v*g_s)); }
void cvLine(const int x1,const int y1,const int x2,const int y2,const uint c)   { g_canvas.Line(SC(x1),SC(y1),SC(x2),SC(y2),c); }
void cvLineAA(const int x1,const int y1,const int x2,const int y2,const uint c) { g_canvas.LineAA(SC(x1),SC(y1),SC(x2),SC(y2),c); }
void cvCircle(const int x,const int y,const int r,const uint c)                 { g_canvas.FillCircle(SC(x),SC(y),SCh(r),c); }
void cvRect(const int x1,const int y1,const int x2,const int y2,const uint c)   { g_canvas.FillRectangle(SC(x1),SC(y1),SC(x2+1)-1,SC(y2+1)-1,c); }
UiTheme  th;
UiHit    g_hit[40];
int      g_hitN=0;
int      g_hover=-1;
int      g_uiW=560, g_uiH=700, g_uiHmin=64;
int      g_uiX=20, g_uiY=60, g_uiOp=255;
int      g_uiTab=0;
int      g_uiThemeIdx=0;
bool     g_uiMin=false, g_uiReady=false, g_uiDrag=false, g_uiPrevDown=false, g_uiInside=false;
int      g_uiDragDX=0, g_uiDragDY=0;
uint     g_uiCloseArm=0;
uint     g_uiLastDraw=0;
uint     g_uiLastSample=0;
double   g_uiPnl[120];
int      g_uiPnlN=0;
bool     g_gate[9];
string   g_gateTxt[9];

void UiApplyTheme()
  {
   switch(g_uiThemeIdx)
     {
      case 1:
         th.bg1=C'2,10,6';   th.bg2=C'6,26,15';  th.accent=C'0,255,120';  th.accent2=C'190,255,0';
         th.good=C'0,255,120'; th.bad=C'255,70,70'; th.warn=C'255,200,0'; th.text=C'210,255,225';
         th.dim=C'90,140,105'; th.line=C'22,64,40'; break;
      case 2:
         th.bg1=C'14,8,4';   th.bg2=C'36,19,8';  th.accent=C'255,170,0';  th.accent2=C'255,80,40';
         th.good=C'120,255,120'; th.bad=C'255,60,60'; th.warn=C'255,225,70'; th.text=C'255,238,215';
         th.dim=C'155,122,90'; th.line=C'74,46,20'; break;
      case 3:
         th.bg1=C'6,12,22';  th.bg2=C'14,30,50'; th.accent=C'140,220,255'; th.accent2=C'185,140,255';
         th.good=C'90,255,200'; th.bad=C'255,110,130'; th.warn=C'255,215,120'; th.text=C'235,245,255';
         th.dim=C'120,145,175'; th.line=C'32,54,84'; break;
      default:
         th.bg1=C'5,8,20';   th.bg2=C'14,20,46'; th.accent=C'0,229,255';  th.accent2=C'255,45,149';
         th.good=C'0,255,163'; th.bad=C'255,59,92'; th.warn=C'255,184,0'; th.text=C'222,236,255';
         th.dim=C'112,132,168'; th.line=C'28,40,78'; break;
     }
  }

uint UiAR(const color c,const int a)
  {
   int aa=a; if(aa<0) aa=0; if(aa>255) aa=255;
   return ColorToARGB(c,(uchar)aa);
  }

color UiLerp(const color c1,const color c2,const double t0)
  {
   double t=UiClamp(t0,0.0,1.0);
   int r1=(int)(c1&0xFF), g1=(int)((c1>>8)&0xFF), b1=(int)((c1>>16)&0xFF);
   int r2=(int)(c2&0xFF), g2=(int)((c2>>8)&0xFF), b2=(int)((c2>>16)&0xFF);
   int r=(int)MathRound(r1+(r2-r1)*t), g=(int)MathRound(g1+(g2-g1)*t), b=(int)MathRound(b1+(b2-b1)*t);
   return (color)((b<<16)|(g<<8)|r);
  }

string UiTrunc(const string s,const int n)
  {
   if(StringLen(s)<=n) return s;
   return StringSubstr(s,0,MathMax(0,n-2))+"..";
  }

string UiMoney(const double v)
  {
   return (v>=0.0?"+":"-")+"$"+DoubleToString(MathAbs(v),2);
  }

color UiPnlColor(const double v) { if(MathAbs(v)<0.005) return th.text; return (v>0.0)?th.good:th.bad; }

void UiText(int x,const int y,const string s0,const color c,const int size=10,const bool bold=false,const int align=0,const bool mono=true)
  {
   int sz=MathMax(7,(int)MathRound((size+2)*g_s));  // +2px: texto maior = bordas nitidas
   g_canvas.FontSet(mono?"Consolas":"Bahnschrift",sz,bold?FW_BOLD:FW_NORMAL);
   string s=s0;
   int w=g_canvas.TextWidth(s);
   int xs=SC(x), ys=SC(y), WS=SC(g_uiW), m12=SC(12);
   int maxW=(align==0)?(WS-m12-xs):((align==2)?(xs-m12):(2*MathMin(xs-m12,WS-m12-xs)));
   if(maxW<8) maxW=8;
   if(w>maxW)                                       // nunca vaza nem cola em outro bloco
     {
      int n=StringLen(s);
      while(n>3 && g_canvas.TextWidth(StringSubstr(s,0,n)+"..")>maxW) n--;
      s=StringSubstr(s,0,n)+"..";
      w=g_canvas.TextWidth(s);
     }
   if(align==1) xs-=w/2; else if(align==2) xs-=w;
   g_canvas.TextOut(xs,ys,s,UiAR(c,255));
  }

void UiFill(const int x,const int y,const int w,const int h,const color c)
  {
   if(w<=0 || h<=0) return;
   cvRect(x,y,x+w-1,y+h-1,UiAR(c,g_uiOp));
  }

void UiFrame(const int x,const int y,const int w,const int h,const color c)
  {
   uint k=UiAR(c,255);
   int x2=x+w-1,y2=y+h-1,ch=4;
   cvLine(x+ch,y,x2-ch,y,k);   cvLine(x2-ch,y,x2,y+ch,k);
   cvLine(x2,y+ch,x2,y2-ch,k); cvLine(x2,y2-ch,x2-ch,y2,k);
   cvLine(x2-ch,y2,x+ch,y2,k); cvLine(x+ch,y2,x,y2-ch,k);
   cvLine(x,y2-ch,x,y+ch,k);   cvLine(x,y+ch,x+ch,y,k);
  }

void UiHitAdd(const int x,const int y,const int w,const int h,const int id)
  {
   if(g_hitN>=40) return;
   g_hit[g_hitN].x=x; g_hit[g_hitN].y=y; g_hit[g_hitN].w=w; g_hit[g_hitN].h=h; g_hit[g_hitN].id=id;
   g_hitN++;
  }

int UiHitAt(const int mx,const int my)
  {
   for(int i=g_hitN-1;i>=0;i--)
      if(mx>=g_hit[i].x && mx<g_hit[i].x+g_hit[i].w && my>=g_hit[i].y && my<g_hit[i].y+g_hit[i].h) return g_hit[i].id;
   return -1;
  }

void UiBtn(const int x,const int y,const int w,const int h,const string label,const int id,const bool active,const color acc)
  {
   bool hov=(g_hover==id);
   color fill=active?UiLerp(th.bg2,acc,0.38):(hov?UiLerp(th.bg2,acc,0.20):UiLerp(th.bg1,th.line,0.55));
   UiFill(x,y,w,h,fill);
   UiFrame(x,y,w,h,(active||hov)?acc:th.line);
   UiText(x+w/2,y+(h-13)/2,label,active?th.text:(hov?acc:th.dim),9,true,1,false);
   UiHitAdd(x,y,w,h,id);
  }

void UiSection(const int x,const int y,const int w,const string t)
  {
   UiFill(x,y+3,3,10,th.accent);
   UiText(x+10,y+1,t,th.accent,9,true,0,false);
   int tw=(int)MathRound(g_canvas.TextWidth(t)/g_s);
   cvLine(x+18+tw,y+8,x+w,y+8,UiAR(th.line,255));
  }

void UiBar(const int x,const int y,const int w,const int h,const double v,const color c,const double marker=-1.0)
  {
   UiFill(x,y,w,h,UiLerp(th.bg1,th.line,0.65));
   int fw=(int)(w*UiClamp(v,0.0,1.0));
   if(fw>0) { UiFill(x,y,fw,h,c); UiFill(x,y,fw,1,UiLerp(c,clrWhite,0.45)); }
   if(marker>=0.0)
     {
      int mx=x+(int)(w*UiClamp(marker,0.0,1.0));
      cvLine(mx,y-2,mx,y+h+1,UiAR(th.text,255));
     }
  }

void UiLed(const int x,const int y,const bool ok,const string label,const bool warn=false)
  {
   color c=ok?th.good:(warn?th.warn:th.bad);
   cvCircle(x+7,y+7,7,UiAR(UiLerp(th.bg1,c,0.30),g_uiOp));
   cvCircle(x+7,y+7,4,UiAR(c,255));
   cvCircle(x+6,y+6,1,UiAR(clrWhite,255));
   UiText(x+20,y,label,ok?th.text:th.dim,10,false,0);
  }

void UiPill(const int x,const int y,const int w,const int h,const string t,const color c)
  {
   UiFill(x,y,w,h,UiLerp(th.bg1,c,0.22));
   UiFrame(x,y,w,h,c);
   UiText(x+w/2,y+(h-13)/2,t,c,9,true,1,false);
  }

void UiKV(const int x,const int y,const int w,const string k,const string v,const color c)
  {
   UiText(x,y,k,th.dim,10,false,0);
   UiText(x+w,y,v,c,10,true,2);
  }

void UiGauge(const int cx,const int cy,const int r,const double v,const color clr,const string big,const string sub)
  {
   int segs=40;
   for(int i=0;i<segs;i++)
     {
      double a1=M_PI+M_PI*i/segs, a2=M_PI+M_PI*(i+1)/segs;
      bool on=((i+0.5)/segs)<=v;
      color c=on?UiLerp(th.accent2,clr,(double)i/segs):th.line;
      for(int k=0;k<6;k++)
        {
         int rr=r-k;
         cvLineAA(cx+(int)(rr*MathCos(a1)),cy+(int)(rr*MathSin(a1)),cx+(int)(rr*MathCos(a2)),cy+(int)(rr*MathSin(a2)),UiAR(c,255));
        }
     }
   double na=M_PI+M_PI*UiClamp(v,0.0,1.0);
   cvLineAA(cx,cy,cx+(int)((r-12)*MathCos(na)),cy+(int)((r-12)*MathSin(na)),UiAR(th.text,255));
   cvCircle(cx,cy,5,UiAR(clr,255));
   UiText(cx,cy-34,big,th.text,20,true,1,false);
   UiText(cx,cy+10,sub,th.dim,9,false,1);
  }

void UiSpark(const int x,const int y,const int w,const int h)
  {
   UiFill(x,y,w,h,UiLerp(th.bg1,th.bg2,0.5));
   UiFrame(x,y,w,h,th.line);
   if(g_uiPnlN<2) { UiText(x+w/2,y+h/2-6,"coletando dados...",th.dim,9,false,1); return; }
   double mn=0.0,mx=0.0;
   for(int i=0;i<g_uiPnlN;i++) { mn=MathMin(mn,g_uiPnl[i]); mx=MathMax(mx,g_uiPnl[i]); }
   if(mx-mn<0.5) { mx+=0.25; mn-=0.25; }
   int zy=y+h-4-(int)((0.0-mn)/(mx-mn)*(h-8));
   for(int xx=x+2;xx<x+w-2;xx+=6) cvLine(xx,zy,xx+2,zy,UiAR(th.dim,255));
   double lastv=g_uiPnl[g_uiPnlN-1];
   color c=(MathAbs(lastv)<0.005)?th.dim:(lastv>0.0?th.good:th.bad);
   for(int i=0;i<g_uiPnlN-1;i++)
     {
      int x1=x+3+(int)((double)i*(w-6)/(g_uiPnlN-1)), x2=x+3+(int)((double)(i+1)*(w-6)/(g_uiPnlN-1));
      int y1=y+h-4-(int)((g_uiPnl[i]-mn)/(mx-mn)*(h-8));
      int y2=y+h-4-(int)((g_uiPnl[i+1]-mn)/(mx-mn)*(h-8));
      cvLineAA(x1,y1,x2,y2,UiAR(c,255));
     }
  }

void UiChevron(const int x,const int y,const int dir,const color c)
  {
   uint k=UiAR(c,255);
   if(dir>0) { cvLineAA(x-5,y+4,x,y-3,k); cvLineAA(x,y-3,x+5,y+4,k); }
   else if(dir<0) { cvLineAA(x-5,y-3,x,y+4,k); cvLineAA(x,y+4,x+5,y-3,k); }
   else cvLine(x-5,y,x+5,y,k);
  }

//====================================================================
// HUD - dados e abas do WallStreetBreaker
//====================================================================
double UiClamp(const double v,const double a,const double b)
  {
   if(v<a) return a;
   if(v>b) return b;
   return v;
  }

double gUiRealized=0.0;
int    gUiWins=0, gUiLosses=0;
uint   gUiRealStamp=0;

double UiFloating()
  {
   double s=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong tk=PositionGetTicket(i);
      if(tk==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      s+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
     }
   return s;
  }

// P&L do dia = SOMENTE trades FECHADOS deste EA (simbolo + magic). Nao inclui flutuante.
void UiRefreshRealized(const bool force=false)
  {
   OwnRealizedRefresh(force);
   gUiRealized=gOwnRealized; gUiWins=gOwnWins; gUiLosses=gOwnLosses;
  }

// estado do circuit breaker SEM efeitos colaterais (nao dispara reset/log)
void UiCircuit(double &pnlUsd,double &lossLimUsd,double &goalUsd,bool &lossHit,bool &gainHit,bool &goalHit,bool &tradesHit)
  {
   double base=(gDayStartEquity>0.0)?gDayStartEquity:AccountInfoDouble(ACCOUNT_EQUITY);
   pnlUsd=DailyPnlUsd();
   double pct=(base>0.0)?pnlUsd/base*100.0:0.0;
   lossLimUsd=base*InpMaxDailyLossPct/100.0;
   goalUsd=(InpDailyGoalUsd>0.0)?InpDailyGoalUsd:base*InpMaxDailyGainPct/100.0;
   lossHit=(pct<=-InpMaxDailyLossPct);
   gainHit=(pct>=InpMaxDailyGainPct);
   goalHit=(InpDailyGoalUsd>0.0 && pnlUsd>=InpDailyGoalUsd);
   tradesHit=(gDayTrades>=InpMaxTradesPerDay);
  }

void UiRefreshGates()
  {
   double pnl,ll,gl; bool lh,gh,goh,th2;
   UiCircuit(pnl,ll,gl,lh,gh,goh,th2);
   string r="";
   bool env=(TerminalInfoInteger(TERMINAL_CONNECTED) && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) &&
             MQLInfoInteger(MQL_TRADE_ALLOWED) && AccountInfoInteger(ACCOUNT_TRADE_ALLOWED));
   g_gate[0]=env;                       g_gateTxt[0]=!TerminalInfoInteger(TERMINAL_CONNECTED)?"SEM_CONEXAO":(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)?"ALGO_TRADING_OFF":"EA_SEM_PERMISSAO");
   g_gate[1]=SessionOK(r);              g_gateTxt[1]="FORA_DA_SESSAO ("+r+")";
   g_gate[2]=!(lh||gh);                 g_gateTxt[2]=lh?"PERDA_DIARIA_MAX":"GANHO_DIARIO_MAX";
   g_gate[3]=!goh;                      g_gateTxt[3]="META_USD_ATINGIDA";
   g_gate[4]=!th2;                      g_gateTxt[4]="MAX_TRADES_DIA";
   g_gate[5]=(InpMaxSpreadPoints<=0 || SpreadPoints()<=InpMaxSpreadPoints); g_gateTxt[5]="SPREAD "+DoubleToString(SpreadPoints(),0)+" > "+IntegerToString(InpMaxSpreadPoints);
   int d=0; g_gate[6]=(CountMyPositions(d)==0); g_gateTxt[6]="POSICAO_ABERTA";
   g_gate[7]=!gPaused;                  g_gateTxt[7]="PAUSADO_NO_PAINEL";
   double lot=NormalizeLot(InpFixedLot);
   g_gate[8]=(lot>0.0 && HasMargin(ORDER_TYPE_BUY,lot)); g_gateTxt[8]=(lot<=0.0)?"LOTE_INVALIDO":"MARGEM_INSUFICIENTE";
  }

string UiFirstBlock()
  {
   for(int i=0;i<9;i++) if(!g_gate[i] && i!=6) return g_gateTxt[i];
   return "";
  }

void UiStatus(string &txt,color &clr)
  {
   int d=0; int n=CountMyPositions(d);
   clr=th.good; txt="AGUARDANDO";
   if(gPaused)      { txt="PAUSADO";    clr=th.warn; return; }
   if(!g_gate[0])   { txt="AMBIENTE";   clr=th.bad;  return; }
   if(!g_gate[2] || !g_gate[3] || !g_gate[4]) { txt="TRAVA DO DIA"; clr=th.bad; return; }
   if(n>0)          { txt="EM POSICAO"; clr=th.accent; return; }
   if(gPendSig!=0)  { txt="ARMADO";     clr=th.warn; return; }
   if(!g_gate[1])   { txt="FORA SESSAO";clr=th.warn; return; }
   if(!g_gate[5])   { txt="SPREAD";     clr=th.warn; return; }
  }

void UiSamplePnl()
  {
   double v=gUiRealized;
   if(g_uiPnlN<120) { g_uiPnl[g_uiPnlN]=v; g_uiPnlN++; }
   else { for(int i=0;i<119;i++) g_uiPnl[i]=g_uiPnl[i+1]; g_uiPnl[119]=v; }
  }

void UiGaugeMark(const int cx,const int cy,const int r,const double frac,const color c)
  {
   double a=M_PI+M_PI*UiClamp(frac,0.0,1.0);
   cvLineAA(cx+(int)((r+2)*MathCos(a)),cy+(int)((r+2)*MathSin(a)),cx+(int)((r+9)*MathCos(a)),cy+(int)((r+9)*MathSin(a)),UiAR(c,255));
  }

//--- cabecalho / rodape ------------------------------------------------
void UiBackground(const int W,const int H)
  {
   for(int y=0;y<H;y+=2)
     {
      color c=UiLerp(th.bg1,th.bg2,(double)y/MathMax(H-1,1));
      cvRect(0,y,W-1,y+1,UiAR(c,g_uiOp));
     }
   color gc=UiLerp(th.bg2,th.line,0.12);
   for(int x=0;x<W;x+=36) cvLine(x,0,x,H-1,UiAR(gc,g_uiOp));
   for(int y=0;y<H;y+=36) cvLine(0,y,W-1,y,UiAR(gc,g_uiOp));
   UiFrame(0,0,W,H,UiLerp(th.line,th.accent,0.45));
   uint k=UiAR(th.accent,255); int L=16;
   cvLine(0,0,L,0,k); cvLine(0,0,0,L,k);
   cvLine(W-1,0,W-1-L,0,k); cvLine(W-1,0,W-1,L,k);
   cvLine(0,H-1,L,H-1,k); cvLine(0,H-1,0,H-1-L,k);
   cvLine(W-1,H-1,W-1-L,H-1,k); cvLine(W-1,H-1,W-1,H-1-L,k);
  }

void UiHeader(const int W)
  {
   int cx=32,cy=30;
   for(int i=0;i<6;i++)
     {
      double a1=M_PI/3.0*i-M_PI/6.0, a2=M_PI/3.0*(i+1)-M_PI/6.0;
      cvLineAA(cx+(int)(17*MathCos(a1)),cy+(int)(17*MathSin(a1)),cx+(int)(17*MathCos(a2)),cy+(int)(17*MathSin(a2)),UiAR(th.accent,255));
      cvLineAA(cx+(int)(9*MathCos(a1)),cy+(int)(9*MathSin(a1)),cx+(int)(9*MathCos(a2)),cy+(int)(9*MathSin(a2)),UiAR(th.accent2,255));
     }
   cvCircle(cx,cy,3,UiAR(th.text,255));
   UiText(60,9,"WALL STREET BREAKER",th.text,13,true,0,false);
   UiText(60,33,"v"+WSB_VERSION+"  |  "+_Symbol+"  |  M15  |  magic "+IntegerToString(InpMagicNumber),th.dim,9,false,0);

   string st; color sc; UiStatus(st,sc);
   int px=W-34-10-140,py=16;
   UiFill(px,py,140,26,UiLerp(th.bg1,sc,0.22));
   UiFrame(px,py,140,26,sc);
   bool pulse=((GetTickCount()/500)%2)==0;
   cvCircle(px+14,py+13,pulse?5:3,UiAR(sc,255));
   UiText(px+82,py+6,st,sc,9,true,1,false);

   bool hov=(g_hover==1);
   UiFill(W-34,16,24,26,hov?UiLerp(th.bg2,th.accent,0.25):UiLerp(th.bg1,th.line,0.55));
   UiFrame(W-34,16,24,26,hov?th.accent:th.line);
   cvLine(W-28,29,W-16,29,UiAR(th.text,255));
   if(g_uiMin) cvLine(W-22,23,W-22,35,UiAR(th.text,255));
   UiHitAdd(W-34,16,24,26,1);

   int sx=(int)((GetTickCount()/5)%(uint)W);
   cvLine(0,58,W-1,58,UiAR(th.line,255));
   for(int i=0;i<60;i++)
     {
      int xx=sx-i; if(xx<0 || xx>=W) continue;
      cvLine(xx,58,xx,58,UiAR(UiLerp(th.line,th.accent,1.0-i/60.0),255));
     }
  }

void UiTabs(const int W)
  {
   string names[4]; names[0]="PAINEL"; names[1]="SINAL"; names[2]="POSICOES"; names[3]="SISTEMA";
   int x0=18,tw=(W-36)/4,y=66;
   for(int i=0;i<4;i++)
     {
      int x=x0+i*tw;
      bool act=(g_uiTab==i),hov=(g_hover==10+i);
      if(act) UiFill(x,y,tw-4,24,UiLerp(th.bg2,th.accent,0.16));
      else if(hov) UiFill(x,y,tw-4,24,UiLerp(th.bg2,th.line,0.5));
      UiText(x+(tw-4)/2,y+5,names[i],act?th.accent:(hov?th.text:th.dim),9,true,1,false);
      if(act) UiFill(x,y+23,tw-4,2,th.accent);
      UiHitAdd(x,y,tw-4,26,10+i);
     }
  }

void UiFooter(const int W,const int H)
  {
   int y=H-66,x=18;
   UiBtn(x,y,110,30,gPaused?"RETOMAR":"PAUSAR",20,gPaused,th.warn);
   bool armed=(g_uiCloseArm!=0 && GetTickCount()-g_uiCloseArm<3000);
   UiBtn(x+118,y,130,30,armed?"CONFIRMAR?":"FECHAR TUDO",21,armed,th.bad);
   UiBtn(x+256,y,90,30,"TEMA",22,false,th.accent2);
   cvLine(14,H-28,W-15,H-28,UiAR(th.line,255));
   cvCircle(22,H-15,3,UiAR(th.accent,255));
   UiText(32,H-22,UiTrunc(gUiTicker,66),th.dim,9,false,0);
  }

//--- aba PAINEL --------------------------------------------------------
void UiTabCore(const int W)
  {
   int X0=18,CW=W-36,y=98;
   UiRefreshRealized();
   UiSection(X0,y,CW,"P&L DO DIA  (fechado, so este EA)");
   UiText(X0,y+20,UiMoney(gUiRealized),UiPnlColor(gUiRealized),26,true,0,false);
   double fl=UiFloating();
   UiText(X0+CW,y+20,"EM ABERTO (fora do P&L)  "+UiMoney(fl),th.dim,10,false,2);
   UiText(X0+CW,y+38,StringFormat("TRADES %d/%d   W %d   L %d",gDayTrades,InpMaxTradesPerDay,gUiWins,gUiLosses),th.text,10,false,2);

   double pnl,ll,gl; bool lh,gh,goh,th2;
   UiCircuit(pnl,ll,gl,lh,gh,goh,th2);
   int by=y+68,bh=12,mid=X0+CW/2;
   UiFill(X0,by,CW,bh,UiLerp(th.bg1,th.line,0.65));
   if(pnl>=0.0 && gl>0.0) UiFill(mid,by,(int)(CW/2*UiClamp(pnl/gl,0.0,1.0)),bh,goh?th.warn:th.good);
   else if(pnl<0.0 && ll>0.0) { int fw=(int)(CW/2*UiClamp(-pnl/ll,0.0,1.0)); UiFill(mid-fw,by,fw,bh,th.bad); }
   cvLine(mid,by-3,mid,by+bh+2,UiAR(th.text,255));
   UiText(X0,by+15,"-"+DoubleToString(ll,2),th.dim,9,false,0);
   UiText(X0+CW,by+15,"+"+DoubleToString(gl,2),th.dim,9,false,2);
   UiText(mid,by+15,(InpDailyPnlSource==PNL_OWN_REALIZED?"realizado ":"equity conta ")+UiMoney(pnl),goh?th.warn:th.dim,9,true,1,false);

   UiText(X0,y+104,"CURVA DO DIA (realizado)",th.dim,8,false,0);
   UiSpark(X0,y+118,CW,60);

   int gy=y+192;
   UiSection(X0,gy,CW,"GATES DE ENTRADA");
   string gn[9];
   gn[0]="AMBIENTE"; gn[1]="SESSAO"; gn[2]="CIRCUIT"; gn[3]="META USD"; gn[4]="TRADES/DIA";
   gn[5]="SPREAD";   gn[6]="POSICAO"; gn[7]="EA ATIVO"; gn[8]="LOTE/MARGEM";
   int cw3=CW/3;
   for(int i=0;i<9;i++) UiLed(X0+(i%3)*cw3,gy+22+(i/3)*26,g_gate[i],gn[i],(i==5||i==6));
   string why=UiFirstBlock();
   int mcN=0; string mcC=""; MagicConflict(mcN,mcC);
   if(mcN>0) UiText(X0,gy+100,"MAGIC EM CONFLITO: "+IntegerToString(mcN)+" pos. de outro EA (coment '"+mcC+"')",th.bad,10,true,0);
   else      UiText(X0,gy+100,why==""?"nenhum bloqueio de entrada":"bloqueio: "+UiTrunc(why,60),why==""?th.good:th.warn,10,true,0);

   int sy=gy+124;
   UiSection(X0,sy,CW,"MOTOR DE SINAL  (M15 fechado)");
   int r=50,cy=sy+24+r+10;
   double ratio=(gLastAtrP>0.0)?gLastAtr/gLastAtrP:0.0;
   bool adxOk=(gLastAdx>=InpMinAdx), atrOk=(ratio>=InpBreakoutMult);
   int cxA=X0+CW/4, cxB=X0+3*CW/4;
   UiGauge(cxA,cy,r,UiClamp(gLastAdx/50.0,0.0,1.0),adxOk?th.good:th.warn,DoubleToString(gLastAdx,1),"ADX  min "+IntegerToString(InpMinAdx));
   UiGaugeMark(cxA,cy,r,InpMinAdx/50.0,th.text);
   UiGauge(cxB,cy,r,UiClamp(ratio/2.0,0.0,1.0),atrOk?th.good:th.warn,DoubleToString(ratio,2),"ATR/ATR prev  min "+DoubleToString(InpBreakoutMult,2));
   UiGaugeMark(cxB,cy,r,InpBreakoutMult/2.0,th.text);

   int dy=cy+30;
   UiSection(X0,dy,CW,"ULTIMA AVALIACAO");
   color dc=(gLastDecision=="PASS")?th.good:(gLastDecision=="BLOCK"?th.warn:th.dim);
   string sg=(gLastSig>0)?"COMPRA":(gLastSig<0?"VENDA":"SEM SINAL");
   UiText(X0,dy+20,gLastDecision,dc,12,true,0,false);
   UiText(X0+90,dy+22,sg,gLastSig>0?th.good:(gLastSig<0?th.bad:th.dim),10,true,0);
   UiText(X0,dy+42,UiTrunc(gLastReason,70),th.dim,9,false,0);
  }

//--- aba SINAL ---------------------------------------------------------
double UiPriceY(const double p,const double pmin,const double pmax,const int top,const int h)
  {
   if(pmax-pmin<=0.0) return top+h/2;
   return top+h-(p-pmin)/(pmax-pmin)*h;
  }

void UiTabSignal(const int W)
  {
   int X0=18,CW=W-36,y=98;
   double ratio=(gLastAtrP>0.0)?gLastAtr/gLastAtrP:0.0;
   bool adxOk=(gLastAdx>=InpMinAdx), atrOk=(ratio>=InpBreakoutMult);
   bool up=(gLastCp>gLastHi && gLastHi>0.0), dn=(gLastCp<gLastLo && gLastLo>0.0);

   UiSection(X0,y,CW,"CADEIA DO GATILHO");
   int cw5=CW/5;
   UiLed(X0,y+22,adxOk,"ADX");
   UiLed(X0+cw5,y+22,atrOk,"ATR EXP");
   UiLed(X0+2*cw5,y+22,up,"ROMP ALTA",true);
   UiLed(X0+3*cw5,y+22,dn,"ROMP BAIXA",true);
   UiLed(X0+4*cw5,y+22,gLastSig!=0,"SINAL");

   UiText(X0,y+52,"ADX",th.dim,10,false,0);
   UiBar(X0+90,y+54,CW-90-70,10,gLastAdx/50.0,adxOk?th.good:th.warn,InpMinAdx/50.0);
   UiText(X0+CW,y+52,DoubleToString(gLastAdx,1),th.text,10,true,2);
   UiText(X0,y+74,"ATR / ATR prev",th.dim,10,false,0);
   UiBar(X0+90,y+76,CW-90-70,10,ratio/2.0,atrOk?th.good:th.warn,InpBreakoutMult/2.0);
   UiText(X0+CW,y+74,DoubleToString(ratio,3),th.text,10,true,2);

   int ry=y+104;
   UiSection(X0,ry,CW,"RANGE "+IntegerToString(InpRangeBars)+" BARRAS x PRECO");
   int top=ry+26,h=150;
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(gLastHi>0.0 && gLastLo>0.0)
     {
      double pmin=MathMin(MathMin(gLastLo,bid),gLastCp), pmax=MathMax(MathMax(gLastHi,bid),gLastCp);
      double pad=MathMax((pmax-pmin)*0.18,gLastAtr*0.2);
      pmin-=pad; pmax+=pad;
      int yHi=(int)UiPriceY(gLastHi,pmin,pmax,top,h), yLo=(int)UiPriceY(gLastLo,pmin,pmax,top,h);
      int yCp=(int)UiPriceY(gLastCp,pmin,pmax,top,h), yBid=(int)UiPriceY(bid,pmin,pmax,top,h);
      UiFill(X0,top,CW,h,UiLerp(th.bg1,th.bg2,0.5));
      UiFrame(X0,top,CW,h,th.line);
      UiFill(X0+1,top+1,CW-2,MathMax(1,yHi-top-1),UiLerp(th.bg1,th.good,0.10));          // zona de rompimento p/ cima
      UiFill(X0+1,yLo,CW-2,MathMax(1,top+h-yLo-1),UiLerp(th.bg1,th.bad,0.10));           // zona de rompimento p/ baixo
      UiFill(X0+1,yHi,CW-2,MathMax(1,yLo-yHi),UiLerp(th.bg1,th.accent,0.08));            // caixa do range
      cvLine(X0+1,yHi,X0+CW-2,yHi,UiAR(th.good,255));
      cvLine(X0+1,yLo,X0+CW-2,yLo,UiAR(th.bad,255));
      UiText(X0+8,yHi-14,"HI  "+DoubleToString(gLastHi,Digits()),th.good,9,true,0);
      UiText(X0+8,yLo+3,"LO  "+DoubleToString(gLastLo,Digits()),th.bad,9,true,0);
      // fechamento anterior
      int cxp=X0+CW/3;
      cvCircle(cxp,yCp,5,UiAR(th.warn,255));
      UiText(cxp+10,yCp-6,"close "+DoubleToString(gLastCp,Digits()),th.warn,9,false,0);
      // preco ao vivo
      uint kb=UiAR(th.accent,255);
      for(int xx=X0+4;xx<X0+CW-4;xx+=8) cvLine(xx,yBid,xx+4,yBid,kb);
      UiPill(X0+CW-124,MathMax(top+2,MathMin(top+h-22,yBid-10)),116,20,DoubleToString(bid,Digits()),th.accent);
      double pt=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double dHi=(gLastHi-bid), dLo=(bid-gLastLo);
      UiKV(X0,top+h+10,CW/2-10,"ATE HI (ao vivo)",StringFormat("%.0f pts / %.2f ATR",dHi/pt,UiClamp(SafeDivWSB(dHi,gLastAtr),-99.0,99.0)),dHi<=0?th.good:th.text);
      UiKV(X0+CW/2+10,top+h+10,CW/2-10,"ATE LO (ao vivo)",StringFormat("%.0f pts / %.2f ATR",dLo/pt,UiClamp(SafeDivWSB(dLo,gLastAtr),-99.0,99.0)),dLo<=0?th.bad:th.text);
     }
   else
     {
      UiFill(X0,top,CW,h,UiLerp(th.bg1,th.bg2,0.5));
      UiFrame(X0,top,CW,h,th.line);
      UiText(X0+CW/2,top+h/2-6,"aguardando primeiro fechamento M15...",th.dim,10,false,1);
     }

   int ey=top+h+40;
   UiSection(X0,ey,CW,"ULTIMA AVALIACAO");
   color dc=(gLastDecision=="PASS")?th.good:(gLastDecision=="BLOCK"?th.warn:th.dim);
   UiText(X0,ey+20,gLastDecision,dc,12,true,0,false);
   UiText(X0+90,ey+22,(gLastEvalTime>0?TimeToString(gLastEvalTime,TIME_DATE|TIME_SECONDS):"--"),th.dim,10,false,0);
   string rs=gLastReason;
   UiText(X0,ey+42,UiTrunc(rs,74),th.dim,9,false,0);
   if(StringLen(rs)>72) UiText(X0,ey+56,UiTrunc(StringSubstr(rs,72),74),th.dim,9,false,0);
  }

//--- aba POSICOES --------------------------------------------------------
void UiTabPositions(const int W)
  {
   int X0=18,CW=W-36,y=98;
   UiSection(X0,y,CW,"POSICOES DO EA  (simbolo + magic)");
   UiText(X0,y+20,"TICKET",th.dim,8,false,0);
   UiText(X0+84,y+20,"LADO",th.dim,8,false,0);
   UiText(X0+150,y+20,"LOTE",th.dim,8,false,0);
   UiText(X0+222,y+20,"ENTRADA",th.dim,8,false,0);
   UiText(X0+CW-92,y+20,"P&L",th.dim,8,false,2);
   UiText(X0+CW,y+20,"TRAIL",th.dim,8,false,2);

   int row=0; ulong bestTk=0; double bestPf=-1.0e100;
   double baseOpen=0.0,baseDir=0.0; datetime oldest=0; int cnt=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong tk=PositionGetTicket(i);
      if(tk==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      cnt++;
      long type=PositionGetInteger(POSITION_TYPE);
      double pf=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      datetime ot=(datetime)PositionGetInteger(POSITION_TIME);
      if(oldest==0 || ot<oldest) { oldest=ot; baseOpen=PositionGetDouble(POSITION_PRICE_OPEN); baseDir=(type==POSITION_TYPE_BUY)?1.0:-1.0; }
      if(pf>bestPf) { bestPf=pf; bestTk=tk; }
      if(row<5)
        {
         int yy=y+36+row*20;
         color tc=(type==POSITION_TYPE_BUY)?th.good:th.bad;
         cvCircle(X0+5,yy+6,3,UiAR(tc,255));
         UiText(X0+16,yy,IntegerToString((long)tk),th.text,10,false,0);
         UiText(X0+84,yy,(type==POSITION_TYPE_BUY)?"BUY":"SELL",tc,10,true,0);
         UiText(X0+150,yy,DoubleToString(PositionGetDouble(POSITION_VOLUME),2),th.text,10,false,0);
         UiText(X0+222,yy,DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),Digits()),th.text,10,false,0);
         UiText(X0+CW-92,yy,UiMoney(pf),UiPnlColor(pf),10,true,2);
         bool ta=TrailEngine_IsActive(tk);
         UiText(X0+CW,yy,ta?"ATIVO":"--",ta?th.accent:th.dim,10,true,2);
         row++;
        }
     }
   if(cnt==0) UiText(X0,y+38,"sem posicao aberta",th.dim,10,false,0);

   int ty=y+36+5*20+6;
   UiSection(X0,ty,CW,"TRAIL ADAPTATIVO");
   int half=CW/2-10;
   if(bestTk>0)
     {
      int ti=TE_Find(bestTk);
      bool act=(ti>=0 && gAT[ti].active);
      double mx=(ti>=0)?gAT[ti].max_profit:0.0;
      UiText(X0,ty+20,"posicao #"+IntegerToString((long)bestTk),th.dim,9,false,0);
      UiPill(X0+CW-120,ty+18,120,20,act?"TRAIL ATIVO":"ARMANDO",act?th.accent:th.warn);
      if(!act)
        {
         UiText(X0,ty+46,"ativa em +"+DoubleToString(InpTrailActivationMoney,2)+"   (lucro atual "+UiMoney(bestPf)+")",th.text,10,false,0);
         UiBar(X0,ty+66,CW,12,bestPf/MathMax(InpTrailActivationMoney,0.01),th.accent,1.0);
         if(InpTakeProfitUsd>0.0) UiText(X0,ty+84,"TP em "+UiMoney(InpTakeProfitUsd)+" vale ate o trail ativar",th.dim,9,false,0);
        }
      else
        {
         UiKV(X0,ty+46,half,"HWM (maximo)",UiMoney(mx),th.good);
         UiKV(X0+half+20,ty+46,half,"DISTANCIA",UiMoney(gAT[ti].trail_distance_money),th.text);
         UiKV(X0,ty+66,half,"LUCRO TRAVADO",UiMoney(gAT[ti].locked_profit),th.good);
         UiKV(X0+half+20,ty+66,half,"STOP FINAL",gAT[ti].trail_stop_price>0?DoubleToString(gAT[ti].trail_stop_price,Digits()):"--",th.text);
         UiKV(X0,ty+86,half,"STOP MONETARIO",gAT[ti].monetary_stop>0?DoubleToString(gAT[ti].monetary_stop,Digits()):"--",th.dim);
         UiKV(X0+half+20,ty+86,half,"STOP ESTRUTURAL",gAT[ti].structural_stop>0?DoubleToString(gAT[ti].structural_stop,Digits()):"--",th.dim);
         UiBar(X0,ty+108,CW,8,(mx>0.0)?(bestPf/mx):0.0,th.accent);
         UiText(X0,ty+120,"movimentos "+IntegerToString(gAT[ti].move_count)+"   TP "+(gAT[ti].tp_removed?"removido (runner)":"mantido"),th.dim,9,false,0);
        }
     }
   else UiText(X0,ty+22,"sem posicao: o trail arma ao abrir",th.dim,10,false,0);

   int py=ty+142;
   UiSection(X0,py,CW,"PIRAMIDACAO");
   if(!InpUsePyramiding) UiText(X0,py+22,"desligada",th.dim,10,false,0);
   else if(cnt==0) UiText(X0,py+22,"aguardando posicao base",th.dim,10,false,0);
   else
     {
      double px=(baseDir>0)?SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double move=(baseDir>0)?(px-baseOpen):(baseOpen-px);
      int adds=cnt-1;
      double atr=gAtrBuffer[1];
      double step=atr*InpPyramidStepAtr*(adds+1);
      bool full=(cnt>InpMaxPyramidAdds);
      UiKV(X0,py+22,half,"ADDS",IntegerToString(adds)+" / "+IntegerToString(InpMaxPyramidAdds),full?th.warn:th.text);
      UiKV(X0+half+20,py+22,half,"PROXIMO PASSO",full?"limite":DoubleToString(step,Digits()),th.text);
      UiBar(X0,py+46,CW,10,full?1.0:move/MathMax(step,_Point),full?th.warn:th.accent,1.0);
      UiText(X0,py+60,"movimento a favor "+DoubleToString(move,Digits())+"  (lote prox "+DoubleToString(NormalizeLot(InpFixedLot*MathPow(InpPyramidLotFactor,adds+1)),2)+")",th.dim,9,false,0);
     }
  }

//--- aba SISTEMA ---------------------------------------------------------
void UiTabSystem(const int W)
  {
   int X0=18,CW=W-36,y=98;
   UiSection(X0,y,CW,"FUNIL DE DECISAO (desde que o EA iniciou)");
   string nm[7]; long val[7]; color cl[7];
   nm[0]="BARRAS M15 AVALIADAS"; val[0]=gCntBars;     cl[0]=th.accent;
   nm[1]="COM SINAL";            val[1]=gCntSig;      cl[1]=th.accent;
   nm[2]="LIBERADAS (PASS)";     val[2]=gCntPass;     cl[2]=th.good;
   nm[3]="BLOQUEADAS";           val[3]=gCntBlocked;  cl[3]=th.warn;
   nm[4]="ORDENS ENVIADAS";      val[4]=gCntSent;     cl[4]=th.good;
   nm[5]="ORDENS BLOQUEADAS";    val[5]=gCntOrdBlock; cl[5]=th.warn;
   nm[6]="ORDENS COM FALHA";     val[6]=gCntFail;     cl[6]=th.bad;
   long mx=MathMax(gCntBars,1);
   for(int i=0;i<7;i++)
     {
      int yy=y+22+i*24;
      UiText(X0,yy,nm[i],th.text,10,false,0);
      UiText(X0+CW,yy,IntegerToString(val[i]),cl[i],11,true,2);
      UiBar(X0,yy+14,CW,5,(double)val[i]/(double)mx,cl[i]);
     }
   int ey=y+22+7*24+4;
   UiText(X0,ey,"piramides "+IntegerToString(gCntPyr)+"   saidas "+IntegerToString(gCntExit)+(gLastOrdBlock!=""?"   ultimo bloqueio: "+UiTrunc(gLastOrdBlock,34):""),th.dim,9,false,0);

   int ay=ey+22;
   UiSection(X0,ay,CW,"AMBIENTE");
   int half=CW/2-10;
   UiKV(X0,ay+22,half,"LOTE EFETIVO",DoubleToString(NormalizeLot(InpFixedLot),2),th.text);
   UiKV(X0+half+20,ay+22,half,"VOL MIN / STEP",DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),2)+" / "+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP),2),th.text);
   double sp=SpreadPoints();
   UiKV(X0,ay+42,half,"SPREAD (pts)",DoubleToString(sp,0)+(InpMaxSpreadPoints>0?" / "+IntegerToString(InpMaxSpreadPoints):" (sem limite)"),g_gate[5]?th.text:th.warn);
   UiKV(X0+half+20,ay+42,half,"TICKS/s",DoubleToString(gUiTickRate,1),th.text);
   UiKV(X0,ay+62,half,"EQUITY",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2),th.text);
   UiKV(X0+half+20,ay+62,half,"MARGEM LIVRE",DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2),th.text);
   ulong up=GetTickCount64()-gStartMs;
   UiKV(X0,ay+82,half,"UPTIME",StringFormat("%dh %02dm",(int)(up/3600000),(int)((up/60000)%60)),th.text);
   UiKV(X0+half+20,ay+82,half,"CONEXAO / ALGO",(TerminalInfoInteger(TERMINAL_CONNECTED)?"OK":"OFF")+" / "+(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)?"ON":"OFF"),g_gate[0]?th.good:th.bad);
   MqlDateTime t; TimeToStruct(TimeCurrent(),t);
   UiText(X0,ay+104,InpUseTelemetry?StringFormat("CSV: WSB2_%04d%02d%02d.csv",t.year,t.mon,t.day):"telemetria CSV desligada",th.dim,9,false,0);
   int mcN2=0; string mcC2=""; MagicConflict(mcN2,mcC2);
   UiText(X0+CW,ay+104,"MAGIC "+IntegerToString(InpMagicNumber)+(mcN2>0?"  CONFLITO":"  ok"),mcN2>0?th.bad:th.good,9,true,2);

   int ly=ay+128;
   UiSection(X0,ly,CW,"EVENTOS RECENTES");
   for(int i=0;i<8;i++)
     {
      if(gEvLog[i]=="") break;
      UiText(X0,ly+22+i*16,UiTrunc(gEvLog[i],74),i==0?th.text:th.dim,9,false,0);
     }
  }

//--- render / eventos ------------------------------------------------------
void UiDraw()
  {
   if(!g_uiReady) return;
   g_hitN=0;
   int W=g_uiW,H=g_uiMin?g_uiHmin:g_uiH;
   g_canvas.Erase(0);
   UiBackground(W,H);
   UiHeader(W);
   if(!g_uiMin)
     {
      UiTabs(W);
      switch(g_uiTab)
        {
         case 0: UiTabCore(W);      break;
         case 1: UiTabSignal(W);    break;
         case 2: UiTabPositions(W); break;
         case 3: UiTabSystem(W);    break;
        }
      UiFooter(W,H);
     }
   g_canvas.Update(true);
  }

void UiRecalcScale()
  {
   double s=MathMax(0.5,MathMin(1.5,InpPanelScalePct/100.0));
   int chh=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS), cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   if(chh>40) s=MathMin(s,(double)(chh-8)/g_uiH);   // nunca maior que o grafico: nada some
   if(cw>40)  s=MathMin(s,(double)(cw-8)/g_uiW);
   g_s=MathMax(0.45,s);
  }
int UiPxW() { return SC(g_uiW); }
int UiPxH() { return SC(g_uiMin?g_uiHmin:g_uiH); }

bool PanelCreate()
  {
   if(!InpShowPanel) return true;
   g_uiThemeIdx=(int)InpPanelTheme;
   UiApplyTheme();
   g_uiOp=255;                                     // painel 100% opaco (candles nao vazam por tras do texto)
   g_uiX=InpPanelX; g_uiY=InpPanelY; g_uiMin=InpPanelStartMinimized;
   UiRecalcScale();
   {
      int chh0=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS), cw0=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      if(chh0>0) g_uiY=(int)MathMax(0,MathMin(g_uiY,chh0-UiPxH()));
      if(cw0>0)  g_uiX=(int)MathMax(0,MathMin(g_uiX,cw0-UiPxW()));
   }
   if(!g_canvas.CreateBitmapLabel("WSB_HUD",g_uiX,g_uiY,UiPxW(),UiPxH(),COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("WSB2: falha ao criar o HUD. Erro=",GetLastError());
      return false;
     }
   ObjectSetInteger(0,"WSB_HUD",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"WSB_HUD",OBJPROP_ZORDER,100);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   g_uiReady=true;
   UiRefreshRealized(true);
   UiRefreshGates();
   UiDraw();
   return true;
  }

void PanelDestroy()
  {
   if(g_uiReady) { g_canvas.Destroy(); g_uiReady=false; }
   ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
  }

void PanelUpdate()
  {
   uint now=GetTickCount();
   if(now-gUiRateStamp>=1000)
     {
      gUiTickRate=(double)(gUiTicks-gUiTicksPrev)*1000.0/(double)(now-gUiRateStamp);
      gUiTicksPrev=gUiTicks; gUiRateStamp=now;
     }
   if(!InpShowPanel || !g_uiReady) return;
   if(now-g_uiLastSample>=5000) { g_uiLastSample=now; UiRefreshRealized(true); UiSamplePnl(); }
   if(now-g_uiLastDraw<(uint)MathMax(100,InpPanelUpdateMs)) return;
   g_uiLastDraw=now;
   UiRefreshGates();
   UiDraw();
  }

void UiCloseAll()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong tk=PositionGetTicket(i);
      if(tk==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      double vol=PositionGetDouble(POSITION_VOLUME), pf=PositionGetDouble(POSITION_PROFIT), px=PositionGetDouble(POSITION_PRICE_CURRENT);
      bool ok=trade.PositionClose(tk);
      TEvent("EXIT_MANUAL",ok?"OK":"FAIL","painel_fechar_tudo",tk,px,vol,pf,StringFormat("retcode=%d",trade.ResultRetcode()));
      if(ok) TrailEngine_Forget(tk);
     }
   gPendSig=0;
  }

void UiAction(const int id)
  {
   switch(id)
     {
      case 1:
         g_uiMin=!g_uiMin; g_canvas.Resize(UiPxW(),UiPxH());
         {
            int chh1=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
            if(chh1>0) { g_uiY=(int)MathMax(0,MathMin(g_uiY,chh1-UiPxH())); ObjectSetInteger(0,"WSB_HUD",OBJPROP_YDISTANCE,g_uiY); }
         }
         break;
      case 10: case 11: case 12: case 13: g_uiTab=id-10; break;
      case 20:
         gPaused=!gPaused;
         if(gPaused) gPendSig=0;
         TEvent("PANEL",gPaused?"PAUSE":"RESUME","botao_painel");
         break;
      case 21:
         if(g_uiCloseArm!=0 && GetTickCount()-g_uiCloseArm<3000) { g_uiCloseArm=0; UiCloseAll(); }
         else g_uiCloseArm=GetTickCount();
         break;
      case 22: g_uiThemeIdx=(g_uiThemeIdx+1)%4; UiApplyTheme(); break;
     }
   UiRefreshRealized(true);
   UiRefreshGates();
   UiDraw();
  }

void UiMouse(const int mx,const int my,const uint flags)
  {
   if(!InpShowPanel || !g_uiReady) return;
   bool down=((flags&1)!=0);
   int px=mx-g_uiX,py=my-g_uiY,H=UiPxH();
   bool inside=(px>=0 && px<UiPxW() && py>=0 && py<H);
   int lx=(int)(px/g_s),ly=(int)(py/g_s);           // coordenadas de projeto (hits e cabecalho)
   int hid=inside?UiHitAt(lx,ly):-1;
   if(hid!=g_hover) g_hover=hid;
   if(inside!=g_uiInside && !g_uiDrag) { g_uiInside=inside; ChartSetInteger(0,CHART_MOUSE_SCROLL,!inside); }
   if(g_uiDrag)
     {
      if(down)
        {
         int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS),chh=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
         g_uiX=(int)MathMax(0,MathMin(cw-UiPxW(),mx-g_uiDragDX));
         g_uiY=(int)MathMax(0,MathMin(chh-H,my-g_uiDragDY));
         ObjectSetInteger(0,"WSB_HUD",OBJPROP_XDISTANCE,g_uiX);
         ObjectSetInteger(0,"WSB_HUD",OBJPROP_YDISTANCE,g_uiY);
        }
      else { g_uiDrag=false; ChartSetInteger(0,CHART_MOUSE_SCROLL,!inside); }
     }
   else if(down && !g_uiPrevDown && inside)
     {
      if(hid>=0) UiAction(hid);
      else if(ly<58)
        {
         g_uiDrag=true; g_uiDragDX=mx-g_uiX; g_uiDragDY=my-g_uiY;
         ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
        }
     }
   g_uiPrevDown=down;
  }

double SafeDivWSB(const double a,const double b) { return (b!=0.0)?a/b:0.0; }

void OnTimer()
  {
   PanelUpdate();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_MOUSE_MOVE) UiMouse((int)lparam,(int)dparam,(uint)StringToInteger(sparam));
   else if(id==CHARTEVENT_CHART_CHANGE && InpShowPanel && g_uiReady)
     {
      double old=g_s;
      UiRecalcScale();
      if(MathAbs(g_s-old)>0.01)
        {
         g_canvas.Resize(UiPxW(),UiPxH());
         int chh=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS), cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
         if(chh>0) g_uiY=(int)MathMax(0,MathMin(g_uiY,chh-UiPxH()));
         if(cw>0)  g_uiX=(int)MathMax(0,MathMin(g_uiX,cw-UiPxW()));
         ObjectSetInteger(0,"WSB_HUD",OBJPROP_XDISTANCE,g_uiX);
         ObjectSetInteger(0,"WSB_HUD",OBJPROP_YDISTANCE,g_uiY);
         UiDraw();
        }
     }
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD) gOwnStamp=0;   // recalcula o P&L do dia no proximo uso
  }

//+------------------------------------------------------------------+
void OnTick()
{
   gUiTicks++;
   if(CopyBuffer(hAtr, 0, 0, 3, gAtrBuffer) < 3) return;
   double atr = gAtrBuffer[1];
   if(atr <= 0) return;

   ManagePositions();
   if(!gPaused) TryPyramid(atr);

   // Heartbeat
   if(InpUseTelemetry && TimeCurrent() - gLastHeartbeat >= InpHeartbeatSec)
   {
      gLastHeartbeat = TimeCurrent();
      double eq = AccountInfoDouble(ACCOUNT_EQUITY);
      TEvent("HEARTBEAT", "OK", "", 0, 0, 0, 0,
             StringFormat("atr=%.5f equity=%.2f%s", atr, eq, TrailEngine_Summary()));
   }

   // Retry da entrada pendente na MESMA barra (falha transitoria: requote, off quotes...)
   if(!gPaused && gPendSig != 0 && gPendBar == gLastBarTime && TimeCurrent() - gPendLast >= 2)
   {
      int d = 0;
      string r1 = "", r2 = "";
      if(CountMyPositions(d) == 0 && CircuitBreakerOK(r1) && SessionOK(r2))
         SendEntry(0);
      else if(CountMyPositions(d) > 0)
         gPendSig = 0;
   }

   if(!NewBar()) return;

   gPendSig = 0;   // nova barra invalida sinal antigo
   PurgeStaleGV();

   int    dir = 0;
   int    nPos = CountMyPositions(dir);
   string cbReason = "", sessReason = "";
   bool   cbOk  = CircuitBreakerOK(cbReason);
   bool   sesOk = SessionOK(sessReason);

   // Avalia sinal mesmo se bloqueado — gravamos os valores
   double atrPrev=0, adx=0, rHi=0, rLo=0, cPrev=0;
   string sigReason = "";
   int    sig = GetSignal(atr, atrPrev, adx, rHi, rLo, cPrev, sigReason);

   string decision = "PASS";
   string reason   = sigReason;

   if(!cbOk)         { decision = "BLOCK"; reason = "circuit: " + cbReason + " | " + sigReason; }
   else if(!sesOk)   { decision = "BLOCK"; reason = "session: " + sessReason + " | " + sigReason; }
   else if(gPaused) { decision = "BLOCK"; reason = "pausado_painel | " + sigReason; }
   else if(nPos > 0) { decision = "BLOCK"; reason = StringFormat("ja_tem_posicao dir=%d | %s", dir, sigReason); }
   else if(sig == 0) { decision = "BLOCK"; reason = "sinal: " + sigReason; }

   // HUD: ultimo estado avaliado
   gLastSig = sig; gLastAtr = atr; gLastAtrP = atrPrev; gLastAdx = adx;
   gLastHi = rHi; gLastLo = rLo; gLastCp = cPrev;
   gLastDecision = decision; gLastReason = reason; gLastEvalTime = TimeCurrent();
   gCntBars++;
   if(sig != 0) gCntSig++;
   if(decision == "PASS") gCntPass++; else gCntBlocked++;

   TLog("BAR_EVAL", dir, nPos,
        1, cbOk?1:0, sesOk?1:0,
        atr, atrPrev, adx, rHi, rLo, cPrev,
        sig, decision, reason,
        0, 0, 0, 0,
        StringFormat("cb=%s sess=%s", cbReason, sessReason));

   if(decision != "PASS") return;

   gPendSig = sig; gPendTries = 0; gPendBar = gLastBarTime; gPendLast = 0;
   gPAtr = atr; gPAtrP = atrPrev; gPAdx = adx; gPHi = rHi; gPLo = rLo; gPCp = cPrev; gPReason = sigReason;
   SendEntry(nPos);
}
//+------------------------------------------------------------------+