//+------------------------------------------------------------------+
//|                                                AccelChain.mq5    |
//|  LZ Trading - micro-scalper de ACELERACAO com escada (XAUUSD)    |
//|                                                                  |
//|  TESE (hipotese, nao evidencia): quando o preco passa de         |
//|  "movimento" para ACELERACAO direcional (estrutura M1 a favor +  |
//|  velocidade, eficiencia e pressao de ticks), a continuacao anda  |
//|  varios degraus. O EA entra na aceleracao com uma corrente de    |
//|  4 a 8 pernas (a 1a a mercado, as demais STOP pre-programadas) e |
//|  cada novo degrau executado trava lucro na perna anterior. Se o  |
//|  momentum morre, cancela pendentes e desmonta; num recuo as      |
//|  pernas saem uma a uma, de tras pra frente, com lucro travado.   |
//|                                                                  |
//|  Sem indicadores classicos: so estrutura de swings M1, estatistica|
//|  de ticks (velocidade, eficiencia, pressao, atividade) e custo.  |
//|  Piramidagem e decisao EXPLICITA (nao e martingale: a exposicao  |
//|  so cresce depois que o preco anda a favor).                     |
//|  Exige conta HEDGING. Execucao SINCRONA nesta versao.            |
//|  Doc: MQL5/Experts/AccelChain/README.md                          |
//+------------------------------------------------------------------+
#property copyright "LZ Trading"
#property version   "1.00"
#property description "AccelChain - aceleracao de ticks/estrutura M1 + corrente de 4-8 pernas"

#include <Trade/Trade.mqh>
#include <LZ/LZPanel.mqh>

#define EA_NAME     "AccelChain"
#define EA_VERSION  "1.00"
#define CSV_SCHEMA  "1.0"
#define MAXL        12
#define TICKBUF     8192

//==================================================================
// INPUTS  (regra: todo stop/protecao tem seu proprio true/false)
//==================================================================
input group "=== GERAL ==="
input ulong           InpMagic            = 26100201;   // Magic
input ENUM_TIMEFRAMES InpSignalTF         = PERIOD_M1;  // Timeframe da estrutura (swings)
input int             InpDeviationPts     = 30;         // Desvio maximo a mercado (pontos)
input bool            InpAllowBuy         = true;       // Permitir compra
input bool            InpAllowSell        = true;       // Permitir venda

input group "=== DIRECAO (estrutura do M1) ==="
input int             InpSwingBars        = 2;          // Barras de cada lado para confirmar um swing
input int             InpStructLookback   = 40;         // Barras fechadas analisadas
input int             InpMinBias          = 20;         // Vies minimo (|0..100|) para armar

input group "=== MOMENTO (ticks) ==="
input int             InpImpulseSec       = 5;          // Janela do impulso (s)
input double          InpImpulseSteps     = 2.0;        // Deslocamento minimo na janela (x degrau)
input double          InpMinEfficiency    = 0.35;       // Eficiencia minima em 10 s (0..1)
input double          InpMinPressure      = 0.25;       // Pressao de ticks minima em 10 s (0..1)

input group "=== ATIVIDADE E CUSTO ==="
input double          InpMinActivity      = 40.0;       // Atividade minima (0..100). Abaixo = mercado parado
input double          InpMaxSpreadToStep  = 1.0;        // Spread maximo = x degrau

input group "=== GATILHOS ==="
input bool            InpUseBreakout      = true;       // [true/false] A: rompimento com momentum
input int             InpBreakBars        = 3;          // Micro topo/fundo = ultimas N barras fechadas
input double          InpMaxChaseSteps    = 1.5;        // Nao perseguir: rompimento alem de x degraus
input bool            InpUsePullback      = true;       // [true/false] B: micro-pullback + reaceleracao
input int             InpPullbackMinPct   = 20;         // Recuo minimo (% do impulso)
input int             InpPullbackMaxPct   = 65;         // Recuo maximo (% do impulso)
input int             InpCooldownSec      = 20;         // Pausa apos fim de corrente (s)

input group "=== SCORE -> NUMERO DE PERNAS ==="
input int             InpMinScore         = 60;         // Score minimo (0..100). +10 = forte, +20 = excepcional
input int             InpLegsNormal       = 4;          // Pernas: sinal normal
input int             InpLegsStrong       = 6;          // Pernas: sinal forte
input int             InpLegsExceptional  = 8;          // Pernas: sinal excepcional

input group "=== CORRENTE ==="
input int             InpStepPoints       = 15;         // Degrau entre as ordens (pontos)

input group "=== PROFIT ==="
input double          InpLot              = 0.01;       // Lote fixo (base)
input bool            InpUseDecreasingLots= false;      // [true/false] Lotes decrescentes (perna i = base x fator^i)
input double          InpLotDecay         = 0.80;       // Fator por perna - lido se decrescente = true
input bool            InpUseTP            = false;      // [true/false] TP comum da corrente (ordem no servidor)
input double          InpTPExtraSteps     = 3.0;        // TP = ultimo degrau + x degraus - lido se TP = true
input bool            InpUseProfitLock    = true;       // [true/false] Escada de lucro: cada nova perna trava a anterior
input double          InpLockStepFrac     = 0.5;        // Trava = nova entrada - (x degrau)
input bool            InpLockOnServer     = false;      // [true/false] Trava como SL no servidor (false = EA fecha a mercado)
input bool            InpUseExhaustionExit= true;       // [true/false] Saida por exaustao de momentum
input bool            InpUseDailyTarget   = false;      // [true/false] Meta diaria (para de abrir correntes)
input double          InpDailyTargetMoney = 50.0;       // Meta diaria (moeda) - lida se a meta estiver true
input double          InpCommissionPerLotRT = 0.0;      // Custo: comissao ida+volta por lote (moeda)

input group "=== STOPS E PROTECOES (cada um com seu true/false) ==="
input bool            InpUseStopLoss      = false;      // [true/false] Airbag: SL no servidor em cada ordem
input int             InpStopLossPoints   = 300;        // Distancia do airbag (pontos) - lida se true
input bool            InpUseInvalidation  = true;       // [true/false] Estrutura quebrou: cancela e zera a corrente
input double          InpInvalidationMaxSteps = 6.0;    // Invalidacao no maximo a x degraus da entrada
input bool            InpUseChainLossStop = true;       // [true/false] Perda maxima da corrente (software)
input double          InpChainLossMoney   = 10.0;       // Perda maxima da corrente (moeda) - lida se true
input bool            InpUseDailyLossStop = true;       // [true/false] Perda diaria maxima (fecha tudo, para o dia)
input double          InpDailyLossMoney   = 30.0;       // Perda diaria maxima (moeda) - lida se true
input bool            InpUsePendingTTL    = true;       // [true/false] Validade das ordens pendentes
input int             InpPendingTTLSec    = 120;        // Validade das pendentes (s) - lida se true
input bool            InpUseMaxSeqAge     = true;       // [true/false] Idade maxima da corrente (fecha tudo)
input int             InpMaxSeqAgeSec     = 180;        // Idade maxima (s) - lida se true
input bool            InpUseFailCooldown  = true;       // [true/false] Pausa extra apos corrente perdedora
input int             InpFailCooldownSec  = 60;         // Pausa apos perda (s) - lida se true

input group "=== SESSAO ==="
input bool            InpUseSession       = true;       // [true/false] Operar so na janela (GMT)
input int             InpSessionStartGMT  = 7;          // Inicio (hora GMT)
input int             InpSessionEndGMT    = 20;         // Fim (hora GMT)
input bool            InpUseBlackout      = false;      // [true/false] Janela proibida (noticia manual)
input int             InpBlackoutStartGMT = 12;         // Inicio do blackout (hora GMT)
input int             InpBlackoutEndGMT   = 14;         // Fim do blackout (hora GMT)

input group "=== TELEMETRIA / PAINEL ==="
input bool            InpWriteCSV         = true;       // Gravar CSV (events/trades/chains/decisions)
input bool            InpShowPanel        = true;       // Painel
input int             InpPanelX           = 10;
input int             InpPanelY           = 20;
input int             InpPanelScale       = 100;        // Escala do painel (%)

//==================================================================
// CONSTANTES (documentadas no README)
//==================================================================
#define W_DIRECTION   0.35
#define W_MOMENTUM    0.30
#define W_ACTIVITY    0.20
#define W_EXECUTION   0.15
#define MARGIN_USE_PCT 50.0     // a corrente nao usa mais que isso da margem livre
#define EXH_PRESS     0.10      // exaustao: pressao abaixo disto
#define EXH_EFF       0.25      // exaustao: eficiencia abaixo disto
#define EXH_ACT       30.0      // exaustao: atividade abaixo disto
#define EXH_HOLD_MS   2000      // exaustao sustentada por este tempo

//==================================================================
// ESTADO
//==================================================================
struct SWin
{
   int    n;
   double first, last, net, path, hi, lo;
   int    up, dn;
};

struct SStruct                 // estrutura do M1 (recalculada a cada barra nova)
{
   bool   ready;
   datetime barTime;
   double medRange;            // mediana do range das barras analisadas
   double h1, h2, l1, l2;      // ultimos dois swings (0 = inexistente)
   int    hh, hl;              // +1 / 0 / -1
   double drift;               // -1..+1
   double mt, mb;              // micro topo / fundo (ultimas InpBreakBars barras)
};

struct SMicro                  // microfluxo (ticks), recalculado a cada 100 ms
{
   bool   ready;
   double disp3, dispI, disp10, disp20, disp2;
   double eff10, press10, press3;
   double tps10, tpsBase;
   double activity;
};

struct SView                   // ultima avaliacao (painel)
{
   int    dir;
   double bias, D, M, A, E, total, spreadStep;
   string trigger;
};

struct SLeg
{
   bool     planned, placed, filled, open, cancelled, closeDone;
   ulong    order, pos;
   double   lot, planPrice, openPrice, slInit, tpInit, slLast, tpLast, lockPx, mfe, mae;
   datetime openTime, closeSeen;
   int      lockMods, closeReq;
   uint     lastErrMs;
};

struct SChain
{
   bool     active, setupDone;
   ulong    id;
   int      dir, n;
   datetime t0, tLast;
   double   e0, step, lot, tp, invalid, spreadPts, activity, sD, sM, sE, score;
   int      filled, closed, cancelled, maxLevel;
   double   gross, comm, swap, net, peakFloat, troughFloat;
   string   trigger, cancelReason, endReason, flatten;
   SLeg     leg[MAXL];
};

CTrade     g_trade;
CLZPanel   g_panel;
SStruct    g_st;
SMicro     g_mc;
SView      g_view;
SChain     g_ch;
MqlTick    g_tick;

double     g_tpx[TICKBUF];
ulong      g_tms[TICKBUF];
int        g_thead = 0, g_tcount = 0;
ulong      g_lastMicroMs = 0, g_lastBaseMs = 0;
double     g_tpsBaseCache = 0;

string     g_sym;
ENUM_TIMEFRAMES g_tf;
double     g_tickSize, g_point, g_tvLoss;
int        g_digits;
string     g_ccy;
bool       g_ready = false;
datetime   g_lastBar = 0;

string     g_state = "INIT", g_block = "", g_lastBlockLogged = "";
datetime   g_lastBlockLogTime = 0;
string     g_lastDecKey = "";

datetime   g_dayStart = 0;
double     g_dayStartEquity = 0, g_dayRealized = 0;
int        g_dayChains = 0, g_dayWinChains = 0;
bool       g_haltDay = false;  string g_haltReason = "";
bool       g_targetHit = false;
datetime   g_pauseUntil = 0, g_lastChainEnd = 0;
bool       g_orphan = false;
string     g_lastCloseReason = "";
double     g_slipEma = 0;
ulong      g_exhaustSinceMs = 0;
bool       g_decayWarned = false;

string     g_runId;
ulong      g_evSeq = 0, g_decSeq = 0, g_tradeSeq = 0, g_chainCounter = 0;
datetime   g_startTime, g_lastHeartbeat = 0;
string     g_lastEvent = "-", g_lastOrder = "-";
string     g_pathCache[4], g_periodCache[4];

//==================================================================
// UTILITARIOS
//==================================================================
double NormPrice(const double p) { return NormalizeDouble(MathRound(p / g_tickSize) * g_tickSize, g_digits); }
double FloorTick(const double p) { return NormalizeDouble(MathFloor(p / g_tickSize + 1e-9) * g_tickSize, g_digits); }
double CeilTick(const double p)  { return NormalizeDouble(MathCeil(p / g_tickSize - 1e-9) * g_tickSize, g_digits); }
double MoneyPerPrice(const double lot) { return lot * g_tvLoss / g_tickSize; }
double PriceToMoney(const double dp, const double lot) { return dp * MoneyPerPrice(lot); }
double Clamp(const double v, const double lo, const double hi) { return MathMax(lo, MathMin(hi, v)); }

double FloorLot(const double v)
{
   double st = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_STEP);
   double vmax = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MAX);
   if(st <= 0) st = 0.01;
   double l = MathMin(MathFloor(v / st + 1e-9) * st, vmax);
   int vd = (int)MathMax(0, MathRound(-MathLog10(st)));
   return NormalizeDouble(l, vd);
}

string Ts(const datetime t) { string s = TimeToString(t, TIME_DATE | TIME_SECONDS); StringReplace(s, ".", "-"); return s; }
string P(const double v) { return DoubleToString(v, g_digits); }
string N(const double v, const int dg) { return DoubleToString(v, dg); }
string N0(const double v, const int dg) { return (v == 0.0) ? "" : DoubleToString(v, dg); }
string B(const bool v) { return v ? "true" : "false"; }
string Esc(string s)
{
   StringReplace(s, ";", ","); StringReplace(s, "\"", "'"); StringReplace(s, "\r", " "); StringReplace(s, "\n", " ");
   return s;
}
string DirStr(const int d) { return d > 0 ? "BUY" : (d < 0 ? "SELL" : "NONE"); }

string RetDesc(const uint rc)
{
   switch(rc)
   {
      case 0:     return "";
      case 10004: return "REQUOTE";
      case 10006: return "REJECT";
      case 10008: return "PLACED";
      case 10009: return "DONE";
      case 10010: return "DONE_PARTIAL";
      case 10013: return "INVALID";
      case 10014: return "INVALID_VOLUME";
      case 10015: return "INVALID_PRICE";
      case 10016: return "INVALID_STOPS";
      case 10017: return "TRADE_DISABLED";
      case 10018: return "MARKET_CLOSED";
      case 10019: return "NO_MONEY";
      case 10020: return "PRICE_CHANGED";
      case 10021: return "PRICE_OFF";
      case 10022: return "INVALID_EXPIRATION";
      case 10024: return "TOO_MANY_REQUESTS";
      case 10025: return "NO_CHANGES";
      case 10027: return "AUTOTRADING_DISABLED_TERMINAL";
      case 10028: return "AUTOTRADING_DISABLED_SERVER";
      case 10030: return "INVALID_FILL";
      case 10031: return "NO_CONNECTION";
      case 10033: return "LIMIT_ORDERS";
      case 10034: return "LIMIT_VOLUME";
      case 10036: return "POSITION_CLOSED";
      case 10040: return "LIMIT_POSITIONS";
      case 10044: return "ONLY_CLOSE";
   }
   return "RC_" + IntegerToString((int)rc);
}
bool RetOk(const uint rc) { return rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_PLACED || rc == TRADE_RETCODE_DONE_PARTIAL; }

ENUM_ORDER_TYPE_FILLING PickFilling()
{
   long fm = SymbolInfoInteger(g_sym, SYMBOL_FILLING_MODE);
   if((fm & SYMBOL_FILLING_IOC) != 0) return ORDER_FILLING_IOC;
   if((fm & SYMBOL_FILLING_FOK) != 0) return ORDER_FILLING_FOK;
   return ORDER_FILLING_RETURN;
}

bool HourIn(const int h, const int a, const int b)
{
   if(a < b) return (h >= a && h < b);
   return (h >= a || h < b);
}
bool InSession()
{
   if(!InpUseSession) return true;
   MqlDateTime d; TimeToStruct(TimeGMT(), d);
   return HourIn(d.hour, InpSessionStartGMT, InpSessionEndGMT);
}
bool InBlackout()
{
   if(!InpUseBlackout) return false;
   MqlDateTime d; TimeToStruct(TimeGMT(), d);
   return HourIn(d.hour, InpBlackoutStartGMT, InpBlackoutEndGMT);
}
string SessionName()
{
   MqlDateTime d; TimeToStruct(TimeGMT(), d);
   if(d.hour >= 7 && d.hour < 12)  return "LONDON";
   if(d.hour >= 12 && d.hour < 16) return "OVERLAP";
   if(d.hour >= 16 && d.hour < 21) return "NY";
   return "ASIA_OFF";
}

//==================================================================
// CSV (padrao docs/CSV.md: ';', append, cabecalho estavel)
//==================================================================
#define K_EVENTS 0
#define K_TRADES 1
#define K_CHAINS 2
#define K_DECIS  3

string CsvKindName(const int k)
{
   if(k == K_EVENTS) return "events";
   if(k == K_TRADES) return "trades";
   if(k == K_CHAINS) return "chains";
   return "decisions";
}

string CsvHeader(const int k)
{
   if(k == K_EVENTS)
      return "schema_version;timestamp_utc;server_time;ea_name;ea_version;symbol;timeframe;magic;instance_id;"
             "event_id;event_type;severity;state;decision;reason_code;reason_detail;bid;ask;spread_points;"
             "balance;equity;daily_pnl;position_count;position_volume;position_profit;chain_id;leg;retcode;"
             "retcode_description;request_price;execution_price;requested_volume;latency_ms;order_id;position_id;"
             "old_lock;new_lock;activity;score;comment";
   if(k == K_TRADES)
      return "schema_version;trade_id;chain_id;leg;ea_name;ea_version;symbol;timeframe;magic;direction;entry_time;"
             "exit_time;duration_sec;volume;entry_price;exit_price;initial_sl;initial_tp;final_sl;final_tp;"
             "gross_profit;commission;swap;net_profit;risk_money;realized_r;mfe_price;mae_price;mfe_money;mae_money;"
             "exit_reason;setup;signal;regime;session;day_of_week;planned_entry_price;entry_slippage_points;"
             "chain_score;chain_legs_planned;chain_step_price;chain_activity;lock_mods;position_id;final_lock_price";
   if(k == K_CHAINS)
      return "schema_version;chain_id;ea_name;ea_version;symbol;timeframe;magic;direction;start_time;end_time;"
             "duration_sec;legs_planned;legs_filled;legs_cancelled;base_lot;step_price;activity;score;"
             "direction_score;momentum_score;execution_score;trigger;spread_points_start;gross_profit;"
             "commission;swap;net_profit;max_level_reached;peak_float_money;trough_float_money;cancel_reason;end_reason";
   return "schema_version;decision_id;timestamp_utc;server_time;ea_name;ea_version;symbol;timeframe;magic;state;"
          "setup;signal;direction;trigger_price;market_price;invalid_price;distance_to_trigger;"
          "distance_to_invalidation;spread_points;decision;reason_code;reason_detail;order_sent;trade_id;"
          "score;direction_score;momentum_score;activity_score;execution_score;structure_bias;trigger;legs_planned;step_price";
}

string CsvPeriod() { MqlDateTime d; TimeToStruct(TimeCurrent(), d); return StringFormat("%04d-%02d", d.year, d.mon); }

string ResolvePath(const int k)
{
   string per = CsvPeriod();
   if(g_pathCache[k] != "" && g_periodCache[k] == per) return g_pathCache[k];
   string a = "LZTrading", b = a + "\\" + EA_NAME, c = b + "\\" + CsvKindName(k);
   FolderCreate(a); FolderCreate(b); FolderCreate(c);
   string dir = c + "\\";
   string path = dir + EA_NAME + "_" + CsvKindName(k) + "_" + per + ".csv";
   string hdr = CsvHeader(k);
   if(FileIsExist(path))
   {
      int h = FileOpen(path, FILE_READ | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
      if(h != INVALID_HANDLE)
      {
         string first = FileReadString(h);
         FileClose(h);
         StringTrimRight(first); StringTrimLeft(first);
         if(first != "" && first != hdr)
         {
            path = dir + EA_NAME + "_" + CsvKindName(k) + "_" + per + "_schema" + CSV_SCHEMA + "_" + g_runId + ".csv";
            Print(EA_NAME, ": cabecalho divergente em arquivo existente; usando ", path);
         }
      }
   }
   g_pathCache[k] = path; g_periodCache[k] = per;
   return path;
}

void CsvWrite(const int k, const string line)
{
   if(!InpWriteCSV) return;
   string path = ResolvePath(k);
   int h = FileOpen(path, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(h == INVALID_HANDLE) { Print(EA_NAME, ": CSV falhou ao abrir ", path, " err=", GetLastError()); return; }
   if(FileSize(h) == 0) FileWriteString(h, CsvHeader(k) + "\r\n");
   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, line + "\r\n");
   FileClose(h);
}

void OpenStats(int &cnt, double &vol, double &profit)
{
   cnt = 0; vol = 0; profit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != g_sym || (ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      cnt++; vol += PositionGetDouble(POSITION_VOLUME);
      profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
}
double OpenFloat() { int c; double v, p; OpenStats(c, v, p); return p; }
double DailyPnl()  { return g_dayRealized + OpenFloat(); }

void LogEvent(const string type, const string sev, const string decision, const string reason, const string detail,
              const int leg = -1, const uint retcode = 0, const double reqPx = 0, const double execPx = 0,
              const double vol = 0, const long latMs = -1, const ulong orderId = 0, const ulong posId = 0,
              const double oldLock = 0, const double newLock = 0)
{
   g_lastEvent = type + (reason != "" ? ":" + reason : "");
   if(!InpWriteCSV) return;
   g_evSeq++;
   int cnt; double vl, pr; OpenStats(cnt, vl, pr);
   double bid = g_tick.bid, ask = g_tick.ask;
   double sp = (g_point > 0 && ask > 0) ? (ask - bid) / g_point : 0;
   string r = CSV_SCHEMA + ";" + Ts(TimeGMT()) + ";" + Ts(TimeCurrent()) + ";" + EA_NAME + ";" + EA_VERSION + ";" + g_sym + ";" +
              EnumToString(g_tf) + ";" + IntegerToString((long)InpMagic) + ";" + g_runId + ";" +
              g_runId + "-" + IntegerToString((long)g_evSeq) + ";" + type + ";" + sev + ";" + g_state + ";" +
              decision + ";" + reason + ";" + Esc(detail) + ";" + N(bid, g_digits) + ";" + N(ask, g_digits) + ";" +
              N(sp, 1) + ";" + N(AccountInfoDouble(ACCOUNT_BALANCE), 2) + ";" + N(AccountInfoDouble(ACCOUNT_EQUITY), 2) + ";" +
              N(g_dayRealized + pr, 2) + ";" + IntegerToString(cnt) + ";" + N(vl, 2) + ";" + N(pr, 2) + ";" +
              (g_ch.active ? IntegerToString((long)g_ch.id) : "") + ";" + (leg >= 0 ? IntegerToString(leg) : "") + ";" +
              (retcode > 0 ? IntegerToString((int)retcode) : "") + ";" + RetDesc(retcode) + ";" +
              N0(reqPx, g_digits) + ";" + N0(execPx, g_digits) + ";" + N0(vol, 2) + ";" +
              (latMs >= 0 ? IntegerToString(latMs) : "") + ";" + (orderId > 0 ? IntegerToString((long)orderId) : "") + ";" +
              (posId > 0 ? IntegerToString((long)posId) : "") + ";" + N0(oldLock, g_digits) + ";" + N0(newLock, g_digits) + ";" +
              (g_mc.ready ? N(g_mc.activity, 1) : "") + ";" + (g_view.total > 0 ? N(g_view.total, 1) : "") + ";";
   CsvWrite(K_EVENTS, r);
}

void LogDecision(const string decision, const string reason, const string detail, const int dir, const double trigPx,
                 const double market, const double invalid, const bool sent, const ulong chainId, const int legs)
{
   if(!InpWriteCSV) return;
   string key = reason + "|" + IntegerToString((long)g_st.barTime) + "|" + decision + "|" + IntegerToString(dir);
   if(key == g_lastDecKey) return;
   g_lastDecKey = key;
   g_decSeq++;
   double sp = (g_point > 0) ? (g_tick.ask - g_tick.bid) / g_point : 0;
   string r = CSV_SCHEMA + ";" + g_runId + "-D" + IntegerToString((long)g_decSeq) + ";" + Ts(TimeGMT()) + ";" + Ts(TimeCurrent()) + ";" +
              EA_NAME + ";" + EA_VERSION + ";" + g_sym + ";" + EnumToString(g_tf) + ";" + IntegerToString((long)InpMagic) + ";" +
              g_state + ";ACCEL_CHAIN;" + g_view.trigger + ";" + DirStr(dir) + ";" + N0(trigPx, g_digits) + ";" + N0(market, g_digits) + ";" +
              N0(invalid, g_digits) + ";" + (trigPx != 0 ? N(MathAbs(market - trigPx), g_digits) : "") + ";" +
              (invalid != 0 ? N(MathAbs(market - invalid), g_digits) : "") + ";" + N(sp, 1) + ";" + decision + ";" + reason + ";" +
              Esc(detail) + ";" + B(sent) + ";" + (chainId > 0 ? IntegerToString((long)chainId) : "") + ";" +
              N(g_view.total, 1) + ";" + N(g_view.D, 1) + ";" + N(g_view.M, 1) + ";" + N(g_view.A, 1) + ";" + N(g_view.E, 1) + ";" +
              N(g_view.bias, 1) + ";" + g_view.trigger + ";" + (legs > 0 ? IntegerToString(legs) : "") + ";" +
              N0(InpStepPoints * g_point, g_digits);
   CsvWrite(K_DECIS, r);
}

//--- bloqueio: painel imediato; CSV so quando muda (>= 10 s entre linhas)
void SetBlock(const string code, const string detail)
{
   g_block = code + ": " + detail;
   if(code == g_lastBlockLogged) return;
   if(TimeCurrent() - g_lastBlockLogTime < 10) return;
   g_lastBlockLogged = code; g_lastBlockLogTime = TimeCurrent();
   LogEvent("BLOCK", "INFO", "BLOCK", code, detail);
}
void ClearBlock() { g_block = ""; g_lastBlockLogged = ""; }

//==================================================================
// MOTOR DE TICKS
//==================================================================
void PushTick(const MqlTick &t)
{
   double mid = (t.bid + t.ask) / 2.0;
   ulong ms = (t.time_msc > 0) ? (ulong)t.time_msc : (ulong)t.time * 1000;
   if(g_tcount > 0)
   {
      int last = (g_thead - 1 + TICKBUF) % TICKBUF;
      if(g_tms[last] == ms && g_tpx[last] == mid) return;
   }
   g_tms[g_thead] = ms; g_tpx[g_thead] = mid;
   g_thead = (g_thead + 1) % TICKBUF;
   if(g_tcount < TICKBUF) g_tcount++;
}

int TickIdx(const int k) { return (((g_thead - 1 - k) % TICKBUF) + TICKBUF) % TICKBUF; }   // k = 0 -> mais recente

ulong NowMs() { return g_tcount > 0 ? g_tms[TickIdx(0)] : 0; }

bool Win(const ulong nowMs, const int sec, SWin &w)
{
   ZeroMemory(w);
   if(g_tcount < 2) return false;
   ulong from = nowMs - (ulong)sec * 1000;
   int cnt = 0; double prev = 0;
   for(int k = 0; k < g_tcount; k++)
   {
      int ix = TickIdx(k);
      if(g_tms[ix] < from) break;
      double p = g_tpx[ix];
      if(cnt == 0) { w.last = p; w.hi = p; w.lo = p; }
      else
      {
         double d = prev - p;                        // variacao do mais antigo para o mais novo
         w.path += MathAbs(d);
         if(d > 0) w.up++; else if(d < 0) w.dn++;
         w.hi = MathMax(w.hi, p); w.lo = MathMin(w.lo, p);
      }
      prev = p; w.first = p; cnt++;
   }
   w.n = cnt; w.net = w.last - w.first;
   return cnt >= 2;
}

double TpsBase(const ulong nowMs)
{
   if(nowMs - g_lastBaseMs < 1000 && g_tpsBaseCache > 0) return g_tpsBaseCache;
   g_lastBaseMs = nowMs;
   ulong from = nowMs - 300000;
   int cnt = 0; ulong oldest = nowMs;
   for(int k = 0; k < g_tcount; k++)
   {
      int ix = TickIdx(k);
      if(g_tms[ix] < from) break;
      cnt++; oldest = g_tms[ix];
   }
   double span = MathMax(20.0, (double)(nowMs - oldest) / 1000.0);
   g_tpsBaseCache = cnt / span;
   return g_tpsBaseCache;
}

void UpdateMicro()
{
   ulong nowMs = NowMs();
   if(nowMs == 0) return;
   if(nowMs - g_lastMicroMs < 100 && g_mc.ready) return;
   g_lastMicroMs = nowMs;
   int oldest = TickIdx(g_tcount - 1);
   g_mc.ready = (g_tcount >= 40 && (nowMs - g_tms[oldest]) >= 20000);
   if(!g_mc.ready) return;

   SWin w2, w3, wI, w10, w20;
   Win(nowMs, 2, w2); Win(nowMs, 3, w3); Win(nowMs, InpImpulseSec, wI); Win(nowMs, 10, w10); Win(nowMs, 20, w20);
   g_mc.disp3 = w3.net; g_mc.dispI = wI.net; g_mc.disp10 = w10.net; g_mc.disp20 = w20.net; g_mc.disp2 = w2.net;
   g_mc.eff10 = (w10.path > 0) ? w10.net / w10.path : 0;                    // com sinal
   g_mc.press10 = (w10.up + w10.dn > 0) ? (double)(w10.up - w10.dn) / (w10.up + w10.dn) : 0;
   g_mc.press3 = (w3.up + w3.dn > 0) ? (double)(w3.up - w3.dn) / (w3.up + w3.dn) : 0;
   g_mc.tps10 = w10.n / 10.0;
   g_mc.tpsBase = TpsBase(nowMs);

   double tickRatio = (g_mc.tpsBase > 0) ? g_mc.tps10 / g_mc.tpsBase : 0;
   double curRange = iHigh(g_sym, g_tf, 0) - iLow(g_sym, g_tf, 0);
   double lastRange = g_st.ready ? (iHigh(g_sym, g_tf, 1) - iLow(g_sym, g_tf, 1)) : 0;
   double rngRatio = (g_st.ready && g_st.medRange > 0) ? MathMax(curRange, lastRange) / g_st.medRange : 0;
   g_mc.activity = 100.0 * (0.5 * Clamp(tickRatio / 1.5, 0, 1) + 0.5 * Clamp(rngRatio / 1.5, 0, 1));
}

//==================================================================
// ESTRUTURA DO M1
//==================================================================
bool UpdateStructure()
{
   g_st.ready = false;
   int n = InpStructLookback, W = InpSwingBars;
   MqlRates r[]; ArraySetAsSeries(r, true);
   if(CopyRates(g_sym, g_tf, 1, n, r) != n) return false;

   double rg[]; ArrayResize(rg, n);
   for(int i = 0; i < n; i++) rg[i] = r[i].high - r[i].low;
   ArraySort(rg);
   g_st.medRange = rg[n / 2];
   if(g_st.medRange <= 0) return false;

   g_st.h1 = g_st.h2 = g_st.l1 = g_st.l2 = 0;
   for(int i = W; i < n - W; i++)
   {
      bool ph = true, pl = true;
      for(int j = 1; j <= W; j++)
      {
         if(r[i].high <= r[i - j].high || r[i].high <= r[i + j].high) ph = false;
         if(r[i].low  >= r[i - j].low  || r[i].low  >= r[i + j].low)  pl = false;
      }
      if(ph) { if(g_st.h1 == 0) g_st.h1 = r[i].high; else if(g_st.h2 == 0) g_st.h2 = r[i].high; }
      if(pl) { if(g_st.l1 == 0) g_st.l1 = r[i].low;  else if(g_st.l2 == 0) g_st.l2 = r[i].low; }
      if(g_st.h2 != 0 && g_st.l2 != 0) break;
   }
   g_st.hh = (g_st.h1 != 0 && g_st.h2 != 0) ? (g_st.h1 > g_st.h2 ? 1 : (g_st.h1 < g_st.h2 ? -1 : 0)) : 0;
   g_st.hl = (g_st.l1 != 0 && g_st.l2 != 0) ? (g_st.l1 > g_st.l2 ? 1 : (g_st.l1 < g_st.l2 ? -1 : 0)) : 0;
   int back = MathMin(8, n - 1);
   g_st.drift = Clamp((r[0].close - r[back].close) / (3.0 * g_st.medRange), -1, 1);

   g_st.mt = r[0].high; g_st.mb = r[0].low;
   for(int i = 1; i < InpBreakBars && i < n; i++) { g_st.mt = MathMax(g_st.mt, r[i].high); g_st.mb = MathMin(g_st.mb, r[i].low); }
   g_st.barTime = iTime(g_sym, g_tf, 0);
   g_st.ready = true;
   return true;
}

//--- vies -100..+100: HH/HL + posicao do preco ao vivo vs ultimo swing + deriva
double Bias(const double px)
{
   if(!g_st.ready) return 0;
   double brk = 0;
   if(g_st.h1 != 0 && px > g_st.h1) brk = 1;
   else if(g_st.l1 != 0 && px < g_st.l1) brk = -1;
   return 100.0 * (0.25 * g_st.hh + 0.25 * g_st.hl + 0.25 * brk + 0.25 * g_st.drift);
}

//==================================================================
// CORRENTE: estado
//==================================================================
void ResetChain()
{
   g_ch.active = false; g_ch.setupDone = false; g_ch.id = 0; g_ch.dir = 0; g_ch.n = 0;
   g_ch.t0 = 0; g_ch.tLast = 0;
   g_ch.e0 = 0; g_ch.step = 0; g_ch.lot = 0; g_ch.tp = 0; g_ch.invalid = 0; g_ch.spreadPts = 0;
   g_ch.activity = 0; g_ch.sD = 0; g_ch.sM = 0; g_ch.sE = 0; g_ch.score = 0;
   g_ch.filled = 0; g_ch.closed = 0; g_ch.cancelled = 0; g_ch.maxLevel = -1;
   g_ch.gross = 0; g_ch.comm = 0; g_ch.swap = 0; g_ch.net = 0; g_ch.peakFloat = 0; g_ch.troughFloat = 0;
   g_ch.trigger = ""; g_ch.cancelReason = ""; g_ch.endReason = ""; g_ch.flatten = "";
   for(int i = 0; i < MAXL; i++) ZeroMemory(g_ch.leg[i]);
   g_exhaustSinceMs = 0;
}

bool ParseComment(const string c, ulong &chain, int &leg)
{
   chain = 0; leg = -1;
   if(StringLen(c) < 4 || StringSubstr(c, 0, 2) != "AC") return false;
   int u = StringFind(c, "_");
   if(u < 3) return false;
   chain = (ulong)StringToInteger(StringSubstr(c, 2, u - 2));
   leg = (int)StringToInteger(StringSubstr(c, u + 1));
   return (leg >= 0 && leg < MAXL);
}

int CountPendings()
{
   int n = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i);
      if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) == g_sym && (ulong)OrderGetInteger(ORDER_MAGIC) == InpMagic) n++;
   }
   return n;
}
int CountLegsOpen() { int n = 0; for(int i = 0; i < MAXL; i++) if(g_ch.leg[i].open) n++; return n; }
double LegMarkPrice() { return (g_ch.dir > 0) ? g_tick.bid : g_tick.ask; }

//==================================================================
// EXECUCAO
//==================================================================
bool SendMarketLeg(const int dir, const double lot, const double slDist, const double tpDist,
                   const string comment, double &fillPx, double &reqPx)
{
   fillPx = 0; reqPx = 0;
   ENUM_ORDER_TYPE ot = dir > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   for(int att = 0; att < 3; att++)
   {
      if(!SymbolInfoTick(g_sym, g_tick)) continue;
      double px = dir > 0 ? g_tick.ask : g_tick.bid;
      double sl = (slDist > 0) ? NormPrice(px - dir * slDist) : 0;
      double tp = (tpDist > 0) ? NormPrice(px + dir * tpDist) : 0;
      reqPx = px;
      ulong t0 = GetMicrosecondCount();
      bool ok = g_trade.PositionOpen(g_sym, ot, lot, px, sl, tp, comment);
      long lat = (long)((GetMicrosecondCount() - t0) / 1000);
      uint rc = g_trade.ResultRetcode();
      g_lastOrder = StringFormat("MKT %s %.2f rc=%d", DirStr(dir), lot, (int)rc);
      LogEvent("ORDER_SEND", "INFO", "PASS", "MARKET_LEG", StringFormat("tentativa %d", att + 1), 0, 0, px, 0, lot, lat);
      if(ok && RetOk(rc))
      {
         fillPx = g_trade.ResultPrice();
         LogEvent("ORDER_PLACED", "INFO", "PASS", "MARKET_LEG", "leg 0 executada", 0, rc, px, fillPx, lot, lat, g_trade.ResultOrder());
         return true;
      }
      LogEvent("ORDER_REJECTED", "ERROR", "BLOCK", "BROKER_REJECT", g_trade.ResultRetcodeDescription(), 0, rc, px, 0, lot, lat);
      if(rc != TRADE_RETCODE_REQUOTE && rc != TRADE_RETCODE_PRICE_CHANGED && rc != TRADE_RETCODE_PRICE_OFF) break;
   }
   return false;
}

bool PlacePending(const int idx, const double price, const double sl, const double tp, const double lot, const string comment)
{
   ENUM_ORDER_TYPE ot = g_ch.dir > 0 ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
   ENUM_ORDER_TYPE_TIME tt = ORDER_TIME_GTC;
   datetime exp = 0;
   long em = SymbolInfoInteger(g_sym, SYMBOL_EXPIRATION_MODE);
   if((em & SYMBOL_EXPIRATION_SPECIFIED) != 0 && InpUsePendingTTL)
   { tt = ORDER_TIME_SPECIFIED; exp = TimeCurrent() + InpPendingTTLSec; }
   ulong t0 = GetMicrosecondCount();
   bool ok = g_trade.OrderOpen(g_sym, ot, lot, 0, price, sl, tp, tt, exp, comment);
   long lat = (long)((GetMicrosecondCount() - t0) / 1000);
   uint rc = g_trade.ResultRetcode();
   g_lastOrder = StringFormat("STOP L%d %s rc=%d", idx, P(price), (int)rc);
   if(ok && RetOk(rc))
   {
      g_ch.leg[idx].placed = true; g_ch.leg[idx].planned = true; g_ch.leg[idx].order = g_trade.ResultOrder();
      g_ch.leg[idx].planPrice = price; g_ch.leg[idx].slInit = sl; g_ch.leg[idx].tpInit = tp;
      LogEvent("ORDER_PLACED", "INFO", "PASS", "PENDING_STOP", StringFormat("leg %d stop @ %s lote %.2f", idx, P(price), lot),
               idx, rc, price, 0, lot, lat, g_ch.leg[idx].order);
      return true;
   }
   LogEvent("ORDER_REJECTED", "WARN", "BLOCK", "BROKER_REJECT", g_trade.ResultRetcodeDescription(), idx, rc, price, 0, lot, lat);
   return false;
}

void CancelPendings(const string reason)
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      ulong t = OrderGetTicket(k);
      if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != g_sym || (ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic) continue;
      ulong cid; int idx = -1;
      ParseComment(OrderGetString(ORDER_COMMENT), cid, idx);
      bool ok = g_trade.OrderDelete(t);
      uint rc = g_trade.ResultRetcode();
      if(ok && RetOk(rc))
      {
         if(idx >= 0 && g_ch.active && cid == g_ch.id && !g_ch.leg[idx].cancelled) { g_ch.leg[idx].cancelled = true; g_ch.cancelled++; }
         LogEvent("ORDER_CANCEL", "INFO", "PASS", reason, StringFormat("pendente %I64u cancelada", t), idx, rc, 0, 0, 0, -1, t);
      }
      else
         LogEvent("ERROR", "ERROR", "BLOCK", "CANCEL_FAILED", g_trade.ResultRetcodeDescription(), idx, rc, 0, 0, 0, -1, t);
   }
   if(g_ch.active && g_ch.cancelReason == "") g_ch.cancelReason = reason;
}

void CloseAllLegs(const string reason)
{
   g_lastCloseReason = reason;
   for(int k = PositionsTotal() - 1; k >= 0; k--)
   {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != g_sym || (ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      bool ok = g_trade.PositionClose(t, (ulong)InpDeviationPts);
      uint rc = g_trade.ResultRetcode();
      if(!(ok && RetOk(rc)))
         LogEvent("ERROR", "ERROR", "BLOCK", "CLOSE_FAILED", g_trade.ResultRetcodeDescription(), -1, rc, 0, 0, 0, -1, 0, t);
   }
}

//--- fecha UMA leg a mercado (saida de lucro pela escada)
void CloseLeg(const int i, const int req, const string reason)
{
   uint nowMs = GetTickCount();
   if(g_ch.leg[i].lastErrMs != 0 && nowMs - g_ch.leg[i].lastErrMs < 1000) return;
   g_ch.leg[i].closeReq = req;
   bool ok = g_trade.PositionClose(g_ch.leg[i].pos, (ulong)InpDeviationPts);
   uint rc = g_trade.ResultRetcode();
   g_lastOrder = StringFormat("CLOSE L%d rc=%d", i, (int)rc);
   if(!(ok && RetOk(rc)))
   {
      g_ch.leg[i].lastErrMs = nowMs;
      LogEvent("ERROR", "ERROR", "BLOCK", "CLOSE_FAILED", g_trade.ResultRetcodeDescription(), i, rc, 0, 0, g_ch.leg[i].lot, -1, 0, g_ch.leg[i].pos);
   }
   else
      LogEvent("ORDER_SEND", "INFO", "PASS", reason, StringFormat("leg %d fechada pela escada (trava %s)", i, P(g_ch.leg[i].lockPx)),
               i, rc, 0, 0, g_ch.leg[i].lot, -1, 0, g_ch.leg[i].pos);
}

//==================================================================
// ESCADA DE LUCRO: cada nova perna executada trava a anterior
//==================================================================
void ApplyLock(const int prev, const double newEntry)
{
   if(!InpUseProfitLock || !g_ch.leg[prev].open) return;
   int dir = g_ch.dir;
   double cost = (g_tick.ask - g_tick.bid) + ((InpCommissionPerLotRT > 0) ? InpCommissionPerLotRT / MoneyPerPrice(1.0) : 0);
   double cand = newEntry - dir * InpLockStepFrac * g_ch.step;
   double floorLvl = g_ch.leg[prev].openPrice + dir * cost;          // nunca abaixo de entrada + custo
   if((floorLvl - cand) * dir > 0) cand = floorLvl;
   cand = (dir > 0) ? FloorTick(cand) : CeilTick(cand);
   double mark = LegMarkPrice();
   if((mark - cand) * dir <= 0) return;                               // preco ja esta no nivel: nao ha lucro a travar
   double old = g_ch.leg[prev].lockPx;
   if(old != 0 && (cand - old) * dir <= 0) return;
   g_ch.leg[prev].lockPx = cand;
   g_ch.leg[prev].lockMods++;
   LogEvent("POSITION_MODIFY", "INFO", "PASS", "LOCK_LEVEL",
            StringFormat("leg %d trava %s (nova entrada %s)", prev, P(cand), P(newEntry)), prev, 0, 0, 0, g_ch.leg[prev].lot, -1, 0,
            g_ch.leg[prev].pos, old, cand);
   if(InpLockOnServer)
   {
      double stopsP = (double)SymbolInfoInteger(g_sym, SYMBOL_TRADE_STOPS_LEVEL) * g_point;
      if((mark - cand) * dir >= stopsP + g_tickSize)
      {
         bool ok = g_trade.PositionModify(g_ch.leg[prev].pos, cand, g_ch.leg[prev].tpLast);
         uint rc = g_trade.ResultRetcode();
         if(!(ok && RetOk(rc)))
            LogEvent("ERROR", "WARN", "BLOCK", "MODIFY_FAILED", g_trade.ResultRetcodeDescription(), prev, rc, 0, 0, g_ch.leg[prev].lot, -1, 0,
                     g_ch.leg[prev].pos, old, cand);
      }
   }
}

//--- executa as travas por software (e como rede de seguranca no modo servidor)
void ManageLocks()
{
   double mark = LegMarkPrice();
   for(int i = 0; i < MAXL; i++)
   {
      if(!g_ch.leg[i].open || g_ch.leg[i].lockPx == 0) continue;
      if((mark - g_ch.leg[i].lockPx) * g_ch.dir <= 0) CloseLeg(i, 1, "LOCK_EXIT");
   }
}

//==================================================================
// SYNC / FECHAMENTOS
//==================================================================
void ProcessLegClosed(const int idx);

void SyncChain()
{
   if(!g_ch.active) return;
   bool seen[MAXL], pend[MAXL];
   for(int i = 0; i < MAXL; i++) { seen[i] = false; pend[i] = false; }
   double floatMoney = 0;

   for(int k = PositionsTotal() - 1; k >= 0; k--)
   {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != g_sym || (ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      ulong cid; int idx;
      if(!ParseComment(PositionGetString(POSITION_COMMENT), cid, idx) || cid != g_ch.id) continue;
      seen[idx] = true;
      floatMoney += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      double op = PositionGetDouble(POSITION_PRICE_OPEN);
      bool justFilled = !g_ch.leg[idx].filled;
      if(justFilled)
      {
         g_ch.leg[idx].filled = true; g_ch.leg[idx].placed = true; g_ch.leg[idx].planned = true;
         g_ch.leg[idx].openPrice = op;
         g_ch.leg[idx].openTime = (datetime)PositionGetInteger(POSITION_TIME);
         g_ch.leg[idx].slInit = PositionGetDouble(POSITION_SL);
         g_ch.leg[idx].tpInit = PositionGetDouble(POSITION_TP);
         g_ch.leg[idx].mfe = 0; g_ch.leg[idx].mae = 0;
         g_ch.filled++; g_ch.tLast = TimeCurrent();
         g_ch.maxLevel = MathMax(g_ch.maxLevel, idx);
         double slip = (g_ch.leg[idx].planPrice > 0) ? (op - g_ch.leg[idx].planPrice) * g_ch.dir / g_point : 0;
         g_slipEma = 0.7 * g_slipEma + 0.3 * MathMax(0.0, slip);
         LogEvent("POSITION_OPEN", "INFO", "PASS", "LEG_FILLED", StringFormat("leg %d aberta slippage %.1f pts", idx, slip),
                  idx, 0, g_ch.leg[idx].planPrice, op, PositionGetDouble(POSITION_VOLUME), -1, 0, t);
      }
      g_ch.leg[idx].open = true; g_ch.leg[idx].pos = t;
      g_ch.leg[idx].slLast = PositionGetDouble(POSITION_SL);
      g_ch.leg[idx].tpLast = PositionGetDouble(POSITION_TP);
      double ex = (LegMarkPrice() - op) * g_ch.dir;
      if(ex > g_ch.leg[idx].mfe) g_ch.leg[idx].mfe = ex;
      if(ex < g_ch.leg[idx].mae) g_ch.leg[idx].mae = ex;
      if(justFilled && idx > 0) ApplyLock(idx - 1, op);              // a nova perna trava a anterior
   }
   if(floatMoney > g_ch.peakFloat) g_ch.peakFloat = floatMoney;
   if(floatMoney < g_ch.troughFloat) g_ch.troughFloat = floatMoney;

   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      ulong t = OrderGetTicket(k);
      if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != g_sym || (ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic) continue;
      ulong cid; int idx;
      if(!ParseComment(OrderGetString(ORDER_COMMENT), cid, idx) || cid != g_ch.id) continue;
      pend[idx] = true; g_ch.leg[idx].order = t;
   }

   for(int i = 0; i < MAXL; i++)
   {
      if(g_ch.leg[i].placed && !g_ch.leg[i].filled && !g_ch.leg[i].cancelled && !pend[i] && !seen[i] && i != 0)
      {
         g_ch.leg[i].cancelled = true; g_ch.cancelled++;
         LogEvent("ORDER_CANCEL", "INFO", "PASS", "PENDING_GONE", StringFormat("leg %d pendente expirou/cancelada", i), i, 0,
                  g_ch.leg[i].planPrice, 0, 0, -1, g_ch.leg[i].order);
      }
      if(g_ch.leg[i].open && !seen[i]) { g_ch.leg[i].open = false; g_ch.leg[i].closeSeen = TimeCurrent(); }
      if(g_ch.leg[i].filled && !g_ch.leg[i].open && !g_ch.leg[i].closeDone) ProcessLegClosed(i);
   }
}

void ProcessLegClosed(const int idx)
{
   if(!HistorySelectByPosition(g_ch.leg[idx].pos)) { if(TimeCurrent() - g_ch.leg[idx].closeSeen < 5) return; }
   double exitPx = 0, profit = 0, comm = 0, swap = 0, fee = 0;
   datetime exitTime = 0; long reason = -1; bool found = false;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      comm += HistoryDealGetDouble(d, DEAL_COMMISSION);
      swap += HistoryDealGetDouble(d, DEAL_SWAP);
      fee  += HistoryDealGetDouble(d, DEAL_FEE);
      if(en == DEAL_ENTRY_OUT || en == DEAL_ENTRY_OUT_BY || en == DEAL_ENTRY_INOUT)
      {
         found = true;
         exitPx = HistoryDealGetDouble(d, DEAL_PRICE);
         exitTime = (datetime)HistoryDealGetInteger(d, DEAL_TIME);
         profit += HistoryDealGetDouble(d, DEAL_PROFIT);
         reason = HistoryDealGetInteger(d, DEAL_REASON);
      }
   }
   if(!found && TimeCurrent() - g_ch.leg[idx].closeSeen < 5) return;
   g_ch.leg[idx].closeDone = true;
   g_ch.closed++;

   double net = profit + comm + swap + fee;
   g_ch.gross += profit; g_ch.comm += comm + fee; g_ch.swap += swap; g_ch.net += net;
   g_dayRealized += net;

   string er = "UNKNOWN";
   if(found)
   {
      if(reason == DEAL_REASON_TP) er = "TP";
      else if(reason == DEAL_REASON_SL)
         er = ((g_ch.leg[idx].slLast - g_ch.leg[idx].openPrice) * g_ch.dir > 0) ? "TRAIL" : "SL";
      else if(reason == DEAL_REASON_EXPERT)
         er = (g_ch.leg[idx].closeReq == 1) ? "TRAIL" : ((g_lastCloseReason != "") ? g_lastCloseReason : "EMERGENCY");
      else if(reason == DEAL_REASON_CLIENT || reason == DEAL_REASON_MOBILE || reason == DEAL_REASON_WEB) er = "MANUAL";
      else if(reason == DEAL_REASON_SO) er = "EMERGENCY";
   }
   else
      LogEvent("WARNING", "WARN", "PASS", "NO_CLOSE_DEAL", StringFormat("leg %d sem deal de saida no historico", idx), idx, 0, 0, 0, 0, -1, 0, g_ch.leg[idx].pos);

   double lot = g_ch.leg[idx].lot;
   double mfeM = PriceToMoney(g_ch.leg[idx].mfe, lot), maeM = PriceToMoney(g_ch.leg[idx].mae, lot);
   double slip = (g_ch.leg[idx].planPrice > 0) ? (g_ch.leg[idx].openPrice - g_ch.leg[idx].planPrice) * g_ch.dir / g_point : 0;
   double riskMoney = (g_ch.leg[idx].slInit != 0) ? PriceToMoney(MathAbs(g_ch.leg[idx].openPrice - g_ch.leg[idx].slInit), lot) : 0;
   g_tradeSeq++;
   MqlDateTime dt; TimeToStruct(g_ch.leg[idx].openTime, dt);
   string r = CSV_SCHEMA + ";" + g_runId + "-T" + IntegerToString((long)g_tradeSeq) + ";" + IntegerToString((long)g_ch.id) + ";" +
              IntegerToString(idx) + ";" + EA_NAME + ";" + EA_VERSION + ";" + g_sym + ";" + EnumToString(g_tf) + ";" +
              IntegerToString((long)InpMagic) + ";" + DirStr(g_ch.dir) + ";" + Ts(g_ch.leg[idx].openTime) + ";" + (found ? Ts(exitTime) : "") + ";" +
              (found ? IntegerToString((long)(exitTime - g_ch.leg[idx].openTime)) : "") + ";" + N(lot, 2) + ";" +
              N(g_ch.leg[idx].openPrice, g_digits) + ";" + (found ? N(exitPx, g_digits) : "") + ";" + N0(g_ch.leg[idx].slInit, g_digits) + ";" +
              N0(g_ch.leg[idx].tpInit, g_digits) + ";" + N0(g_ch.leg[idx].slLast, g_digits) + ";" + N0(g_ch.leg[idx].tpLast, g_digits) + ";" +
              (found ? N(profit, 2) : "") + ";" + N(comm + fee, 2) + ";" + N(swap, 2) + ";" + (found ? N(net, 2) : "") + ";" +
              N0(riskMoney, 2) + ";" + ((found && riskMoney > 0) ? N(net / riskMoney, 2) : "") + ";" +
              N(g_ch.leg[idx].mfe, g_digits) + ";" + N(g_ch.leg[idx].mae, g_digits) + ";" + N(mfeM, 2) + ";" + N(maeM, 2) + ";" + er + ";" +
              "ACCEL_CHAIN;" + g_ch.trigger + ";" + IntegerToString(g_view.dir) + ";" + SessionName() + ";" +
              IntegerToString(dt.day_of_week) + ";" + N0(g_ch.leg[idx].planPrice, g_digits) + ";" + N(slip, 1) + ";" +
              N(g_ch.score, 1) + ";" + IntegerToString(g_ch.n) + ";" + N(g_ch.step, g_digits) + ";" +
              N(g_ch.activity, 1) + ";" + IntegerToString(g_ch.leg[idx].lockMods) + ";" + IntegerToString((long)g_ch.leg[idx].pos) + ";" +
              N0(g_ch.leg[idx].lockPx, g_digits);
   CsvWrite(K_TRADES, r);
   LogEvent("POSITION_CLOSE", "INFO", "PASS", er, StringFormat("leg %d net %.2f", idx, net), idx, 0, 0, exitPx, lot, -1, 0, g_ch.leg[idx].pos);
}

//==================================================================
// SCORE E GATILHOS
//==================================================================
double ExecScore(const double step)
{
   double spread = g_tick.ask - g_tick.bid;
   double e = 100.0 * Clamp(1.0 - spread / (InpMaxSpreadToStep * step), 0, 1);
   double slipPen = (step > 0) ? MathMin(40.0, 50.0 * (g_slipEma * g_point) / step) : 0;
   return MathMax(0.0, e - slipPen);
}

//--- A) rompimento do micro topo/fundo com momentum. Retorna true se dispara.
bool CheckBreakout(const int dir, const double step, double &momentum, double &level, string &why)
{
   why = "";
   double px = dir > 0 ? g_tick.ask : g_tick.bid;
   level = dir > 0 ? g_st.mt : g_st.mb;
   if((px - level) * dir <= 0) return false;                       // ainda nao rompeu: estado ARMADO
   if((px - level) * dir > InpMaxChaseSteps * step)
   { why = "CHASE_TOO_FAR"; return false; }
   bool speedOk = (g_mc.dispI * dir >= InpImpulseSteps * step);
   bool effOk   = (g_mc.eff10 * dir >= InpMinEfficiency);
   bool pressOk = (g_mc.press10 * dir >= InpMinPressure);
   if(!(speedOk && effOk && pressOk)) { why = "WEAK_MOMENTUM"; return false; }
   double v3 = g_mc.disp3 * dir / 3.0, v10 = g_mc.disp10 * dir / 10.0;
   double accel = (v10 <= 0) ? (v3 > 0 ? 1.0 : 0.0) : Clamp(v3 / v10 / 1.5, 0, 1);
   double speed = Clamp(g_mc.dispI * dir / (InpImpulseSteps * step * 2.0), 0, 1);
   momentum = 100.0 * (0.30 * speed + 0.25 * Clamp(g_mc.eff10 * dir / 0.8, 0, 1) +
                       0.25 * Clamp(g_mc.press10 * dir / 0.6, 0, 1) + 0.20 * accel);
   return true;
}

//--- B) impulso -> recuo pequeno -> reaceleracao. Usa o buffer de ticks (janela de 20 s).
bool CheckPullback(const int dir, const double step, double &momentum, double &level, string &why)
{
   why = "";
   ulong nowMs = NowMs();
   ulong from = nowMs - 20000;
   // pass 1: pico (maximo de y = preco*dir) na janela
   double peak = -DBL_MAX; int kp = -1; int kLast = -1;
   for(int k = 0; k < g_tcount; k++)
   {
      int ix = TickIdx(k);
      if(g_tms[ix] < from) break;
      double y = g_tpx[ix] * dir;
      if(y > peak) { peak = y; kp = k; }
      kLast = k;
   }
   if(kp < 0 || kLast < 1) return false;
   // base = minimo de y mais antigo que o pico; fundo do recuo = minimo mais novo que o pico
   double base = DBL_MAX, pbLow = DBL_MAX;
   for(int k = 0; k <= kLast; k++)
   {
      double y = g_tpx[TickIdx(k)] * dir;
      if(k < kp)  pbLow = MathMin(pbLow, y);
      if(k > kp)  base = MathMin(base, y);
   }
   double cur = (dir > 0 ? g_tick.ask : g_tick.bid) * dir;
   if(kp == 0 || base == DBL_MAX) return false;
   if(pbLow == DBL_MAX) pbLow = cur;
   double impulse = peak - base;
   if(impulse < InpImpulseSteps * 1.5 * step) return false;
   double pb = peak - pbLow;
   double retr = pb / impulse * 100.0;
   if(retr < InpPullbackMinPct || retr > InpPullbackMaxPct) return false;
   double reaccel = cur - pbLow;
   if(reaccel < 0.5 * step || cur >= peak) return false;           // nao reacelerou (ou ja virou rompimento: gatilho A)
   if(g_mc.disp2 * dir <= 0) { why = "NO_REACCEL"; return false; }
   if(g_mc.press3 * dir < InpMinPressure) { why = "WEAK_MOMENTUM"; return false; }
   level = (dir > 0 ? 1.0 : -1.0) * peak;                           // preco do pico
   momentum = 100.0 * (0.5 * Clamp(reaccel / step, 0, 1) + 0.5 * Clamp(impulse / (3.0 * step), 0, 1));
   return true;
}

//==================================================================
// INICIO DA CORRENTE
//==================================================================
void StartChain(const int dir, const string trig, const double trigPx, const double score, const double sD, const double sM, const double sE)
{
   double ask = g_tick.ask, bid = g_tick.bid, px = dir > 0 ? ask : bid;
   double spreadP = ask - bid;
   double stopsP = (double)SymbolInfoInteger(g_sym, SYMBOL_TRADE_STOPS_LEVEL) * g_point;
   double freezeP = (double)SymbolInfoInteger(g_sym, SYMBOL_TRADE_FREEZE_LEVEL) * g_point;
   double minPend = MathMax(MathMax(stopsP, freezeP), g_tickSize);

   double S = CeilTick(InpStepPoints * g_point);
   if(S < minPend)
   {
      string d = StringFormat("degrau %d pts < minimo do broker %.0f pts (stops/freeze level)", InpStepPoints, minPend / g_point);
      SetBlock("STEP_TOO_SMALL", d);
      LogDecision("BLOCK", "STEP_TOO_SMALL", d, dir, trigPx, px, 0, false, 0, 0);
      return;
   }
   double slDist = InpUseStopLoss ? CeilTick(InpStopLossPoints * g_point) : 0;
   if(InpUseStopLoss && slDist < minPend + spreadP)
   {
      string d = StringFormat("airbag %d pts < minimo (stops level + spread) %.0f pts", InpStopLossPoints, (minPend + spreadP) / g_point);
      SetBlock("SL_TOO_CLOSE", d);
      LogDecision("BLOCK", "SL_TOO_CLOSE", d, dir, trigPx, px, 0, false, 0, 0);
      return;
   }

   //--- pernas: score -> 4/6/8
   int n = InpLegsNormal;
   if(score >= InpMinScore + 20) n = InpLegsExceptional;
   else if(score >= InpMinScore + 10) n = InpLegsStrong;
   n = MathMax(1, MathMin(MAXL, n));

   //--- lotes por perna (fixo; decrescente opcional, nunca abaixo do minimo do simbolo)
   double vmin = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MIN);
   double lots[MAXL];
   double totalLots = 0;
   for(int i = 0; i < n; i++)
   {
      double raw = InpUseDecreasingLots ? InpLot * MathPow(InpLotDecay, i) : InpLot;
      double l = FloorLot(raw);
      if(l < vmin)
      {
         l = vmin;
         if(!g_decayWarned) { g_decayWarned = true; LogEvent("WARNING", "WARN", "PASS", "LOT_AT_MIN", "lote decrescente limitado ao minimo do simbolo; use lote base maior"); }
      }
      lots[i] = l; totalLots += l;
   }

   //--- margem
   double marg = 0;
   if(!OrderCalcMargin(dir > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, g_sym, totalLots, px, marg) || marg <= 0)
   { SetBlock("NO_MARGIN", "OrderCalcMargin falhou"); return; }
   double freeM = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   while(n > 1 && marg > freeM * MARGIN_USE_PCT / 100.0)
   {
      totalLots -= lots[n - 1]; n--;
      if(!OrderCalcMargin(dir > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, g_sym, totalLots, px, marg)) break;
   }
   if(marg > freeM * MARGIN_USE_PCT / 100.0)
   {
      string d = StringFormat("margem %.2f > %.0f%% da livre %.2f", marg, MARGIN_USE_PCT, freeM);
      SetBlock("NO_MARGIN", d);
      LogDecision("BLOCK", "NO_MARGIN", d, dir, trigPx, px, 0, false, 0, n);
      return;
   }

   //--- invalidacao: ultimo swing contra, limitado a InpInvalidationMaxSteps degraus
   double refSw = (dir > 0) ? ((g_st.l1 != 0) ? g_st.l1 : g_st.mb) : ((g_st.h1 != 0) ? g_st.h1 : g_st.mt);
   double capSw = px - dir * InpInvalidationMaxSteps * S;
   double invalid = (dir > 0) ? MathMax(refSw, capSw) : MathMin(refSw, capSw);

   g_chainCounter++;
   GlobalVariableSet("AC_" + IntegerToString((long)InpMagic) + "_chain", (double)g_chainCounter);
   ResetChain();
   g_ch.id = g_chainCounter; g_ch.dir = dir; g_ch.n = n; g_ch.t0 = TimeCurrent(); g_ch.tLast = g_ch.t0;
   g_ch.step = S; g_ch.lot = InpLot; g_ch.invalid = NormPrice(invalid);
   g_ch.trigger = trig; g_ch.score = score; g_ch.sD = sD; g_ch.sM = sM; g_ch.sE = sE;
   g_ch.activity = g_mc.activity; g_ch.spreadPts = spreadP / g_point;
   g_ch.active = true;
   for(int i = 0; i < n; i++) { g_ch.leg[i].lot = lots[i]; g_ch.leg[i].planned = true; }

   LogEvent("SIGNAL", "INFO", "PASS", trig, StringFormat("%s score %.1f (D %.0f M %.0f A %.0f E %.0f) n %d step %d pts lot %.2f invalida %s",
            DirStr(dir), score, sD, sM, g_mc.activity, sE, n, InpStepPoints, InpLot, P(g_ch.invalid)), -1, 0, px, 0, lots[0]);

   string cm0 = StringFormat("AC%I64u_0", g_ch.id);
   double tpDist = InpUseTP ? (n - 1 + InpTPExtraSteps) * S : 0;
   double fill, req;
   if(!SendMarketLeg(dir, lots[0], slDist, tpDist, cm0, fill, req))
   {
      LogDecision("BLOCK", "BROKER_REJECT", g_trade.ResultRetcodeDescription(), dir, trigPx, px, g_ch.invalid, true, g_ch.id, n);
      ResetChain();
      g_lastChainEnd = TimeCurrent();
      SetBlock("BROKER_REJECT", "leg 0 recusada: " + g_trade.ResultRetcodeDescription());
      return;
   }
   LogDecision("PASS", trig, StringFormat("score %.1f n %d", score, n), dir, trigPx, px, g_ch.invalid, true, g_ch.id, n);

   g_ch.e0 = (fill > 0) ? fill : px;
   g_ch.leg[0].placed = true; g_ch.leg[0].planPrice = req;
   g_ch.tp = InpUseTP ? NormPrice(g_ch.e0 + dir * tpDist) : 0;
   g_dayChains++;

   SymbolInfoTick(g_sym, g_tick);
   for(int i = 1; i < n; i++)
   {
      double price = NormPrice(g_ch.e0 + dir * i * S);
      double cur = dir > 0 ? g_tick.ask : g_tick.bid;
      double dist = (price - cur) * dir;
      if(dist < minPend)
      {
         g_ch.leg[i].cancelled = true; g_ch.cancelled++;
         LogEvent("WARNING", "WARN", "BLOCK", "LEVEL_PASSED", StringFormat("leg %d: nivel %s ja alcancado (dist %s < min %s)", i, P(price), P(dist), P(minPend)), i);
         continue;
      }
      double sl = (slDist > 0) ? NormPrice(price - dir * slDist) : 0;
      string cm = StringFormat("AC%I64u_%d", g_ch.id, i);
      if(!PlacePending(i, price, sl, g_ch.tp, lots[i], cm)) { g_ch.leg[i].cancelled = true; g_ch.cancelled++; }
   }
   g_ch.setupDone = true;
   ClearBlock();
}

//==================================================================
// AVALIACAO DE ENTRADA (a cada tick, com a corrente inativa)
//==================================================================
void TryStartChain()
{
   if(g_orphan)    { SetBlock("ORPHAN", "posicoes/ordens sem corrente associada"); g_state = "BLOQUEADO"; return; }
   if(g_haltDay)   { SetBlock("DAILY_LOSS_REACHED", g_haltReason); g_state = "PARADO"; return; }
   if(g_targetHit) { SetBlock("DAILY_TARGET_REACHED", "meta diaria atingida"); g_state = "META"; return; }
   if(TimeCurrent() < g_pauseUntil)
   { SetBlock("COOLDOWN", StringFormat("pausa apos corrente perdedora ate %s", TimeToString(g_pauseUntil, TIME_SECONDS))); g_state = "PAUSA"; return; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_EXPERT) || !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
   { SetBlock("TRADING_NOT_ALLOWED", "AutoTrading/conta/EA sem permissao"); g_state = "BLOQUEADO"; return; }
   if(SymbolInfoInteger(g_sym, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
   { SetBlock("SYMBOL_DISABLED", "modo de negociacao do simbolo nao e FULL"); g_state = "BLOQUEADO"; return; }
   if(!InSession()) { SetBlock("SESSION_CLOSED", StringFormat("fora da janela %02d-%02d GMT", InpSessionStartGMT, InpSessionEndGMT)); g_state = "FORA SESSAO"; return; }
   if(InBlackout()) { SetBlock("NEWS_BLOCK", StringFormat("blackout %02d-%02d GMT", InpBlackoutStartGMT, InpBlackoutEndGMT)); g_state = "BLACKOUT"; return; }
   if(!g_st.ready || !g_mc.ready) { SetBlock("DATA_NOT_READY", "aquecendo (estrutura M1 e 20 s de ticks)"); g_state = "AQUECENDO"; return; }
   if(TimeCurrent() - g_lastChainEnd < InpCooldownSec)
   { SetBlock("COOLDOWN", StringFormat("%d s apos a ultima corrente", InpCooldownSec)); g_state = "AGUARDANDO"; return; }

   g_state = "AGUARDANDO";
   double step = InpStepPoints * g_point;
   double spread = g_tick.ask - g_tick.bid;
   double mid = (g_tick.ask + g_tick.bid) / 2.0;
   g_view.spreadStep = (step > 0) ? spread / step : 0;
   g_view.bias = Bias(mid);
   g_view.A = g_mc.activity;
   g_view.E = ExecScore(step);
   g_view.trigger = ""; g_view.D = 0; g_view.M = 0; g_view.total = 0; g_view.dir = 0;

   //--- custo e mercado parado (obrigatorios)
   if(spread > InpMaxSpreadToStep * step)
   { SetBlock("SPREAD_HIGH", StringFormat("spread %.0f pts > %.2f x degrau (%d pts)", spread / g_point, InpMaxSpreadToStep, InpStepPoints)); return; }
   if(g_mc.activity < InpMinActivity)
   { SetBlock("DEAD_MARKET", StringFormat("atividade %.0f < %.0f", g_mc.activity, InpMinActivity)); return; }

   //--- direcao pela estrutura
   int dir = 0;
   if(g_view.bias >= InpMinBias) dir = 1; else if(g_view.bias <= -InpMinBias) dir = -1;
   if(dir == 0) { SetBlock("NO_TREND", StringFormat("vies %.0f dentro de +-%d", g_view.bias, InpMinBias)); return; }
   if(dir > 0 && !InpAllowBuy)  { SetBlock("DIRECTION_OFF", "compra desligada"); return; }
   if(dir < 0 && !InpAllowSell) { SetBlock("DIRECTION_OFF", "venda desligada"); return; }
   g_view.dir = dir;

   //--- gatilhos
   string trig = "", why = "", why2 = "";
   double mom = 0, lvl = 0;
   if(InpUseBreakout && CheckBreakout(dir, step, mom, lvl, why)) trig = "BREAKOUT";
   else if(InpUsePullback && CheckPullback(dir, step, mom, lvl, why2)) trig = "PULLBACK";
   if(trig == "" && why == "") why = why2;
   if(trig == "")
   {
      if(why != "") { SetBlock(why, why == "CHASE_TOO_FAR" ? "rompimento ja foi alem do limite" : "momentum insuficiente"); }
      else { g_block = ""; g_state = "ARMADO"; }
      return;
   }

   //--- score
   double D = MathMin(100.0, MathAbs(g_view.bias));
   double total = W_DIRECTION * D + W_MOMENTUM * mom + W_ACTIVITY * g_mc.activity + W_EXECUTION * g_view.E;
   g_view.D = D; g_view.M = mom; g_view.total = total; g_view.trigger = trig;
   double px = dir > 0 ? g_tick.ask : g_tick.bid;
   double trigPx = (trig == "PULLBACK") ? MathAbs(lvl) : lvl;
   if(total < InpMinScore)
   {
      string d = StringFormat("score %.1f < %d (D %.0f M %.0f A %.0f E %.0f)", total, InpMinScore, D, mom, g_mc.activity, g_view.E);
      SetBlock("LOW_SCORE", d);
      LogDecision("BLOCK", "LOW_SCORE", d, dir, trigPx, px, 0, false, 0, 0);
      return;
   }
   StartChain(dir, trig, trigPx, total, D, mom, g_view.E);
}

//==================================================================
// GERENCIAMENTO
//==================================================================
void FinalizeChain()
{
   datetime now = TimeCurrent();
   string er = (g_ch.flatten != "") ? g_ch.flatten : (g_ch.cancelReason != "" ? "ESCADA_ENCERRADA" : (g_ch.net >= 0 ? "ESCADA_ENCERRADA" : "SL"));
   g_ch.endReason = er;
   string r = CSV_SCHEMA + ";" + IntegerToString((long)g_ch.id) + ";" + EA_NAME + ";" + EA_VERSION + ";" + g_sym + ";" + EnumToString(g_tf) + ";" +
              IntegerToString((long)InpMagic) + ";" + DirStr(g_ch.dir) + ";" + Ts(g_ch.t0) + ";" + Ts(now) + ";" +
              IntegerToString((long)(now - g_ch.t0)) + ";" + IntegerToString(g_ch.n) + ";" + IntegerToString(g_ch.filled) + ";" +
              IntegerToString(g_ch.cancelled) + ";" + N(g_ch.lot, 2) + ";" + N(g_ch.step, g_digits) + ";" + N(g_ch.activity, 1) + ";" +
              N(g_ch.score, 1) + ";" + N(g_ch.sD, 1) + ";" + N(g_ch.sM, 1) + ";" + N(g_ch.sE, 1) + ";" + g_ch.trigger + ";" +
              N(g_ch.spreadPts, 1) + ";" + N(g_ch.gross, 2) + ";" + N(g_ch.comm, 2) + ";" + N(g_ch.swap, 2) + ";" + N(g_ch.net, 2) + ";" +
              IntegerToString(g_ch.maxLevel + 1) + ";" + N(g_ch.peakFloat, 2) + ";" + N(g_ch.troughFloat, 2) + ";" + g_ch.cancelReason + ";" + er;
   CsvWrite(K_CHAINS, r);
   LogEvent("CHAIN_END", "INFO", "PASS", er, StringFormat("corrente %I64u (%s): %d/%d pernas, net %.2f", g_ch.id, g_ch.trigger, g_ch.filled, g_ch.n, g_ch.net));

   if(g_ch.net >= 0) g_dayWinChains++;
   if(InpUseFailCooldown && g_ch.net < 0)
   {
      g_pauseUntil = now + InpFailCooldownSec;
      LogEvent("RISK", "INFO", "BLOCK", "FAIL_COOLDOWN", StringFormat("corrente perdedora: pausa %d s", InpFailCooldownSec));
   }
   if(InpUseDailyTarget && g_dayRealized >= InpDailyTargetMoney && !g_targetHit)
   {
      g_targetHit = true;
      LogEvent("RISK", "INFO", "BLOCK", "DAILY_TARGET_REACHED", StringFormat("dia %.2f >= meta %.2f", g_dayRealized, InpDailyTargetMoney));
   }
   if(InpUseDailyLossStop && g_dayRealized <= -InpDailyLossMoney && !g_haltDay)
   {
      g_haltDay = true; g_haltReason = StringFormat("perda diaria %.2f <= -%.2f", g_dayRealized, InpDailyLossMoney);
      LogEvent("KILL_SWITCH", "ERROR", "BLOCK", "DAILY_LOSS", g_haltReason);
   }
   g_lastChainEnd = now;
   g_lastCloseReason = "";
   ResetChain();
}

//--- exaustao: conta quantos sinais de momentum morrendo (na direcao da corrente)
int ExhaustionCount()
{
   int d = g_ch.dir, c = 0;
   if(g_mc.press10 * d < EXH_PRESS) c++;
   if(g_mc.disp3 * d <= 0) c++;
   if(g_mc.eff10 * d < EXH_EFF) c++;
   if(g_mc.activity < EXH_ACT) c++;
   return c;
}

void ManageChain()
{
   datetime now = TimeCurrent();
   int openN = CountLegsOpen();
   int pendN = CountPendings();
   g_state = "CORRENTE";

   //--- 1) emergencias e invalidacao: nao dependem de sinal
   if(g_ch.flatten == "")
   {
      double mark = LegMarkPrice();
      if(InpUseDailyLossStop && DailyPnl() <= -InpDailyLossMoney)
      {
         g_ch.flatten = "DAILY_LOSS"; g_haltDay = true; g_haltReason = StringFormat("perda diaria %.2f", DailyPnl());
         LogEvent("KILL_SWITCH", "ERROR", "BLOCK", "DAILY_LOSS", g_haltReason);
      }
      else if(InpUseChainLossStop && g_ch.filled > 0 && openN > 0 && g_ch.net + OpenFloat() <= -InpChainLossMoney)
      {
         g_ch.flatten = "EMERGENCY";
         LogEvent("RISK", "ERROR", "BLOCK", "CHAIN_LOSS", StringFormat("corrente %.2f <= -%.2f", g_ch.net + OpenFloat(), InpChainLossMoney));
      }
      else if(InpUseInvalidation && openN > 0 && (mark - g_ch.invalid) * g_ch.dir <= 0)
      {
         g_ch.flatten = "INVALIDATION";
         LogEvent("RISK", "WARN", "BLOCK", "INVALIDATION", StringFormat("preco %s cruzou a invalidacao %s", P(mark), P(g_ch.invalid)));
      }
      else if(InpUseMaxSeqAge && g_ch.setupDone && now - g_ch.t0 >= InpMaxSeqAgeSec)
         g_ch.flatten = "TIME_EXIT";
   }
   if(g_ch.flatten != "")
   {
      if(pendN > 0) CancelPendings(g_ch.flatten);
      if(openN > 0) CloseAllLegs(g_ch.flatten);
      return;
   }

   //--- 2) exaustao de momentum: 2 sinais cancelam pendentes; 3 sustentados por 2 s desmontam
   if(InpUseExhaustionExit && g_mc.ready && openN > 0 && (g_ch.filled >= 2 || now - g_ch.t0 >= 5))
   {
      int c = ExhaustionCount();
      if(c >= 3)
      {
         if(g_exhaustSinceMs == 0) g_exhaustSinceMs = NowMs();
         else if(NowMs() - g_exhaustSinceMs >= EXH_HOLD_MS)
         {
            g_ch.flatten = "EXHAUSTION";
            LogEvent("RISK", "INFO", "PASS", "EXHAUSTION", StringFormat("momentum esgotado (%d/4 sinais) por >= %d ms", c, EXH_HOLD_MS));
            if(pendN > 0) CancelPendings("EXHAUSTION");
            CloseAllLegs("EXHAUSTION");
            return;
         }
      }
      else g_exhaustSinceMs = 0;
      if(c >= 2 && pendN > 0) { CancelPendings("MOMENTUM_FADE"); pendN = 0; }
   }

   //--- 3) pendentes: invalidacao da tese
   if(pendN > 0 && g_ch.setupDone)
   {
      if(openN == 0)                                   CancelPendings("NO_OPEN_LEGS");
      else if(InpUsePendingTTL && now - g_ch.t0 >= InpPendingTTLSec) CancelPendings("PENDING_TTL");
      else if(!InSession() || InBlackout())            CancelPendings("SESSION_OR_BLACKOUT");
      else if(g_st.ready && Bias((g_tick.ask + g_tick.bid) / 2.0) * g_ch.dir <= -InpMinBias) CancelPendings("STRUCTURE_FLIP");
   }

   //--- 4) escada de lucro
   if(openN > 0 && InpUseProfitLock) ManageLocks();
}

//==================================================================
// DIA / ORFAOS
//==================================================================
double SumDealsSince(const datetime from)
{
   double s = 0;
   if(!HistorySelect(from, TimeCurrent() + 60)) return 0;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      if(HistoryDealGetString(d, DEAL_SYMBOL) != g_sym || (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) != InpMagic) continue;
      long en = HistoryDealGetInteger(d, DEAL_ENTRY);
      if(en == DEAL_ENTRY_IN) { s += HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE); continue; }
      s += HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_COMMISSION) +
           HistoryDealGetDouble(d, DEAL_SWAP) + HistoryDealGetDouble(d, DEAL_FEE);
   }
   return s;
}

void NewDayCheck()
{
   datetime today = (datetime)(TimeCurrent() / 86400 * 86400);
   if(today == g_dayStart) return;
   bool first = (g_dayStart == 0);
   g_dayStart = today;
   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayRealized = first ? SumDealsSince(today) : 0;
   g_dayChains = 0; g_dayWinChains = 0;
   g_haltDay = false; g_haltReason = ""; g_targetHit = false;
   if(first && InpUseDailyLossStop && g_dayRealized <= -InpDailyLossMoney)
   { g_haltDay = true; g_haltReason = StringFormat("perda diaria %.2f (recuperada do historico)", g_dayRealized); }
   if(!first) LogEvent("DAY_RESET", "INFO", "PASS", "DAY_RESET", StringFormat("novo dia: equity %.2f", g_dayStartEquity));
}

void ScanOrphans()
{
   int pos = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == g_sym && (ulong)PositionGetInteger(POSITION_MAGIC) == InpMagic) pos++;
   }
   if(g_ch.active) { g_orphan = false; return; }
   if(CountPendings() > 0) CancelPendings("ORPHAN_PENDING");
   bool was = g_orphan;
   g_orphan = (pos > 0);
   if(g_orphan && !was) LogEvent("WARNING", "WARN", "BLOCK", "ORPHAN", StringFormat("%d posicoes sem contexto de corrente", pos));
   if(!g_orphan && was) LogEvent("INFO", "INFO", "PASS", "ORPHAN_CLEARED", "sem posicoes orfas");
}

//==================================================================
// PAINEL
//==================================================================
void DrawPanel()
{
   if(!InpShowPanel) return;
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) return;

   color sc = LZ_MUTED;
   if(g_state == "CORRENTE") sc = LZ_INFO;
   else if(g_state == "ARMADO") sc = LZ_PROFIT;
   else if(g_state == "PARADO") sc = LZ_LOSS;
   else if(g_state == "META") sc = LZ_GOLD;
   else if(g_state == "AGUARDANDO") sc = LZ_ACCENT;
   else sc = LZ_WARN;

   double sp = (g_point > 0 && g_tick.ask > 0) ? (g_tick.ask - g_tick.bid) / g_point : 0;
   double dpnl = DailyPnl();

   g_panel.Begin();
   g_panel.Header("LZ TRADING  //  ACCEL CHAIN " + EA_VERSION,
                  StringFormat("%s %s  spread %.0f pt  dia %s %+.2f", g_sym, EnumToString(g_tf), sp, g_ccy, dpnl), g_state, sc);
   if(g_panel.Expanded())
   {
      if(g_state == "CORRENTE")    g_panel.Strip("CORRENTE", StringFormat("%s #%I64u %s  score %.0f  n=%d", DirStr(g_ch.dir), g_ch.id, g_ch.trigger, g_ch.score, g_ch.n), LZ_INFO);
      else if(g_state == "ARMADO") g_panel.Strip("ARMADO", "estrutura e atividade ok, aguardando gatilho", LZ_PROFIT);
      else if(g_block != "")       g_panel.Strip("BLOQUEIO", g_block, (g_state == "PARADO") ? LZ_LOSS : LZ_WARN);
      else                         g_panel.Strip(g_state, "-", sc);

      g_panel.Section("DIRECAO / MOMENTO");
      color bc = (g_view.bias > 0) ? LZ_PROFIT : (g_view.bias < 0 ? LZ_LOSS : LZ_MUTED);
      g_panel.KV2("VIES M1", StringFormat("%+.0f", g_view.bias), bc, "ATIVIDADE", g_mc.ready ? StringFormat("%.0f", g_mc.activity) : "-", LZ_TEXT);
      g_panel.KV2("SPREAD/DEGRAU", StringFormat("%.2f", g_view.spreadStep), g_view.spreadStep > InpMaxSpreadToStep ? LZ_LOSS : LZ_TEXT,
                  "TICKS/s", g_mc.ready ? StringFormat("%.1f (base %.1f)", g_mc.tps10, g_mc.tpsBase) : "-", LZ_TEXT);
      g_panel.KV2("EFIC. 10s", g_mc.ready ? StringFormat("%+.2f", g_mc.eff10) : "-", LZ_TEXT,
                  "PRESSAO 10s", g_mc.ready ? StringFormat("%+.2f", g_mc.press10) : "-", LZ_TEXT);
      g_panel.KV2("SCORE", g_view.total > 0 ? StringFormat("%.0f / min %d", g_view.total, InpMinScore) : "-", LZ_TEXT,
                  "D/M/A/E", g_view.total > 0 ? StringFormat("%.0f/%.0f/%.0f/%.0f", g_view.D, g_view.M, g_view.A, g_view.E) : "-", LZ_TEXT);

      g_panel.Section("CORRENTE");
      if(g_ch.active)
      {
         g_panel.ChipBegin();
         for(int i = 0; i < g_ch.n && i < MAXL; i++)
         {
            string t = StringFormat("L%d", i + 1);
            color c = LZ_LINE;
            if(g_ch.leg[i].open)           { c = LZ_PROFIT; t += (g_ch.leg[i].lockPx != 0 ? " TRAVADA" : " ABERTA"); }
            else if(g_ch.leg[i].closeDone) { c = LZ_MUTED;  t += " FECHADA"; }
            else if(g_ch.leg[i].cancelled) { c = LZ_WARN;   t += " CANC"; }
            else if(g_ch.leg[i].placed)    { c = LZ_INFO;   t += " STOP"; }
            g_panel.ChipFlow(t, c);
         }
         g_panel.ChipEnd();
         double flt = OpenFloat();
         g_panel.KV2("DEGRAU", StringFormat("%d pts", InpStepPoints), LZ_TEXT, "INVALIDA EM", InpUseInvalidation ? P(g_ch.invalid) : "OFF", LZ_TEXT);
         g_panel.KV2("FLUTUANTE", StringFormat("%s %+.2f", g_ccy, flt), flt >= 0 ? LZ_PROFIT : LZ_LOSS,
                     "REALIZADO", StringFormat("%+.2f", g_ch.net), g_ch.net >= 0 ? LZ_PROFIT : LZ_LOSS);
         g_panel.KV("IDADE", StringFormat("%d s", (int)(TimeCurrent() - g_ch.t0)), LZ_TEXT);
      }
      else
         g_panel.KV("CORRENTE", "nenhuma ativa", LZ_MUTED);

      g_panel.Section("RISCO");
      if(InpUseDailyLossStop)
         g_panel.Bar("PERDA DO DIA", StringFormat("%s %+.2f / -%.2f", g_ccy, dpnl, InpDailyLossMoney),
                     (dpnl < 0) ? MathMin(100.0, -dpnl / InpDailyLossMoney * 100.0) : 0.0, (dpnl < 0) ? LZ_LOSS : LZ_PROFIT);
      else
         g_panel.KV("PERDA DO DIA", StringFormat("%s %+.2f  (limite DESLIGADO)", g_ccy, dpnl), (dpnl < 0) ? LZ_LOSS : LZ_PROFIT);
      g_panel.KV2("PERDA MAX CORR.", InpUseChainLossStop ? StringFormat("%s %.2f", g_ccy, InpChainLossMoney) : "OFF", LZ_TEXT,
                  "AIRBAG SL", InpUseStopLoss ? StringFormat("%d pts", InpStopLossPoints) : "OFF", LZ_TEXT);
      g_panel.KV2("CORRENTES HOJE", StringFormat("%d (%d +)", g_dayChains, g_dayWinChains), LZ_TEXT,
                  "REALIZADO DIA", StringFormat("%+.2f", g_dayRealized), g_dayRealized >= 0 ? LZ_PROFIT : LZ_LOSS);

      g_panel.Section("TELEMETRIA");
      g_panel.KV("ULTIMO EVENTO", g_lastEvent, LZ_TEXT);
      g_panel.KV("ULTIMA ORDEM", g_lastOrder, LZ_TEXT);
      g_panel.KV2("CSV", InpWriteCSV ? CSV_SCHEMA : "OFF", InpWriteCSV ? LZ_TEXT : LZ_WARN,
                  "UPTIME", StringFormat("%d min", (int)((TimeCurrent() - g_startTime) / 60)), LZ_TEXT);
   }
   g_panel.End();
}

//==================================================================
// EVENTOS DO EA
//==================================================================
int OnInit()
{
   g_sym = _Symbol; g_tf = InpSignalTF;
   g_ccy = AccountInfoString(ACCOUNT_CURRENCY);

   string err = "";
   double lotMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), lotMax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(InpSwingBars < 1 || InpStructLookback < 4 * InpSwingBars + 10) err = "InpSwingBars >= 1 e InpStructLookback >= 4 x swing + 10";
   else if(InpMinBias < 1 || InpMinBias > 100) err = "InpMinBias entre 1 e 100";
   else if(InpImpulseSec < 2 || InpImpulseSec > 20) err = "InpImpulseSec entre 2 e 20";
   else if(InpImpulseSteps <= 0) err = "InpImpulseSteps > 0";
   else if(InpMinEfficiency < 0 || InpMinEfficiency > 1 || InpMinPressure < 0 || InpMinPressure > 1) err = "eficiencia e pressao minimas entre 0 e 1";
   else if(InpMinActivity < 0 || InpMinActivity > 100) err = "InpMinActivity entre 0 e 100";
   else if(InpMaxSpreadToStep <= 0) err = "InpMaxSpreadToStep > 0";
   else if(!InpUseBreakout && !InpUsePullback) err = "ligue pelo menos um gatilho (rompimento ou pullback)";
   else if(InpBreakBars < 1 || InpBreakBars > 10) err = "InpBreakBars entre 1 e 10";
   else if(InpMaxChaseSteps <= 0) err = "InpMaxChaseSteps > 0";
   else if(InpPullbackMinPct < 0 || InpPullbackMaxPct > 100 || InpPullbackMinPct >= InpPullbackMaxPct) err = "recuo: 0 <= min < max <= 100";
   else if(InpMinScore < 0 || InpMinScore > 80) err = "InpMinScore entre 0 e 80";
   else if(InpLegsNormal < 1 || InpLegsNormal > InpLegsStrong || InpLegsStrong > InpLegsExceptional || InpLegsExceptional > MAXL)
      err = StringFormat("pernas: 1 <= normal <= forte <= excepcional <= %d", MAXL);
   else if(InpStepPoints <= 0) err = "InpStepPoints > 0";
   else if(InpLot < lotMin || InpLot > lotMax) err = StringFormat("InpLot fora do permitido (%.2f a %.2f)", lotMin, lotMax);
   else if(lotStep > 0 && MathAbs(InpLot / lotStep - MathRound(InpLot / lotStep)) > 1e-6) err = StringFormat("InpLot nao e multiplo do passo %.2f", lotStep);
   else if(InpUseDecreasingLots && (InpLotDecay <= 0 || InpLotDecay > 1)) err = "lotes decrescentes ligados exigem 0 < InpLotDecay <= 1";
   else if(InpUseTP && InpTPExtraSteps < 0) err = "InpTPExtraSteps >= 0";
   else if(InpUseProfitLock && (InpLockStepFrac <= 0 || InpLockStepFrac >= 1)) err = "escada ligada exige 0 < InpLockStepFrac < 1";
   else if(InpUseDailyTarget && InpDailyTargetMoney <= 0) err = "meta diaria ligada exige InpDailyTargetMoney > 0";
   else if(InpUseStopLoss && InpStopLossPoints <= 0) err = "airbag ligado exige InpStopLossPoints > 0";
   else if(InpUseInvalidation && InpInvalidationMaxSteps <= 0) err = "invalidacao ligada exige InpInvalidationMaxSteps > 0";
   else if(InpUseChainLossStop && InpChainLossMoney <= 0) err = "perda maxima da corrente ligada exige InpChainLossMoney > 0";
   else if(InpUseDailyLossStop && InpDailyLossMoney <= 0) err = "perda diaria ligada exige InpDailyLossMoney > 0";
   else if(InpUsePendingTTL && InpPendingTTLSec <= 0) err = "validade ligada exige InpPendingTTLSec > 0";
   else if(InpUseMaxSeqAge && InpMaxSeqAgeSec <= 0) err = "idade maxima ligada exige InpMaxSeqAgeSec > 0";
   else if(InpUseFailCooldown && InpFailCooldownSec <= 0) err = "pausa ligada exige InpFailCooldownSec > 0";
   if(err != "") { Print(EA_NAME, ": INIT_FAILED - ", err); return INIT_PARAMETERS_INCORRECT; }

   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Print(EA_NAME, ": INIT_FAILED - conta NETTING: as posicoes da corrente seriam fundidas. Use conta HEDGING.");
      return INIT_FAILED;
   }
   if(!SymbolSelect(g_sym, true)) { Print(EA_NAME, ": simbolo indisponivel"); return INIT_FAILED; }
   g_tickSize = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_SIZE);
   g_point    = SymbolInfoDouble(g_sym, SYMBOL_POINT);
   g_digits   = (int)SymbolInfoInteger(g_sym, SYMBOL_DIGITS);
   g_tvLoss   = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(g_tvLoss <= 0) g_tvLoss = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE);
   if(g_tickSize <= 0) g_tickSize = g_point;
   if(g_tickSize <= 0 || g_point <= 0 || g_tvLoss <= 0) { Print(EA_NAME, ": especificacao do simbolo invalida"); return INIT_FAILED; }
   string up = g_sym; StringToUpper(up);
   if(StringFind(up, "XAU") < 0 && StringFind(up, "GOLD") < 0)
      Print(EA_NAME, ": AVISO - pensado para XAUUSD; simbolo atual ", g_sym, " nao foi calibrado");

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints((ulong)InpDeviationPts);
   g_trade.SetTypeFilling(PickFilling());
   g_trade.SetAsyncMode(false);

   MqlDateTime d; TimeToStruct(TimeLocal(), d);
   g_runId = StringFormat("%04d%02d%02d%02d%02d%02d", d.year, d.mon, d.day, d.hour, d.min, d.sec);
   g_startTime = TimeCurrent();
   for(int i = 0; i < 4; i++) { g_pathCache[i] = ""; g_periodCache[i] = ""; }
   string gv = "AC_" + IntegerToString((long)InpMagic) + "_chain";
   g_chainCounter = GlobalVariableCheck(gv) ? (ulong)GlobalVariableGet(gv) : 0;

   ZeroMemory(g_st); ZeroMemory(g_mc);
   g_view.dir = 0; g_view.bias = 0; g_view.D = 0; g_view.M = 0; g_view.A = 0; g_view.E = 0; g_view.total = 0; g_view.spreadStep = 0;
   g_view.trigger = "";
   ResetChain();
   SymbolInfoTick(g_sym, g_tick);
   NewDayCheck();
   ScanOrphans();
   UpdateStructure();

   if(InpShowPanel)
   {
      g_panel.Init("LZP_AC_", InpPanelX, InpPanelY, 400);
      g_panel.SetScale(InpPanelScale);
   }
   EventSetTimer(1);

   LogEvent("INIT", "INFO", "PASS", "INIT",
            StringFormat("v%s %s %s step=%dpts lot=%.2f decr=%s legs=%d/%d/%d minScore=%d | triggers A=%s B=%s | SL=%s(%d) lock=%s(server=%s) exh=%s inval=%s chainLoss=%s(%.1f) dailyLoss=%s(%.1f) ttl=%s(%d) age=%s(%d) failCd=%s(%d) TP=%s sess=%s(%d-%dGMT) blackout=%s",
                         EA_VERSION, g_sym, EnumToString(g_tf), InpStepPoints, InpLot, B(InpUseDecreasingLots), InpLegsNormal, InpLegsStrong, InpLegsExceptional,
                         InpMinScore, B(InpUseBreakout), B(InpUsePullback), B(InpUseStopLoss), InpStopLossPoints, B(InpUseProfitLock), B(InpLockOnServer),
                         B(InpUseExhaustionExit), B(InpUseInvalidation), B(InpUseChainLossStop), InpChainLossMoney, B(InpUseDailyLossStop), InpDailyLossMoney,
                         B(InpUsePendingTTL), InpPendingTTLSec, B(InpUseMaxSeqAge), InpMaxSeqAgeSec, B(InpUseFailCooldown), InpFailCooldownSec,
                         B(InpUseTP), B(InpUseSession), InpSessionStartGMT, InpSessionEndGMT, B(InpUseBlackout)));
   if(SymbolInfoInteger(g_sym, SYMBOL_SPREAD) > InpMaxSpreadToStep * InpStepPoints)
      Print(EA_NAME, ": AVISO - spread atual (", (int)SymbolInfoInteger(g_sym, SYMBOL_SPREAD), " pts) maior que ", InpMaxSpreadToStep,
            " x degrau (", InpStepPoints, " pts): o EA ficara bloqueado por SPREAD_HIGH ate o spread cair ou o degrau aumentar.");
   PrintFormat("%s v%s pronto: %s %s magic=%I64u tick=%s stops=%d freeze=%d fill=%s",
               EA_NAME, EA_VERSION, g_sym, EnumToString(g_tf), InpMagic, P(g_tickSize),
               (int)SymbolInfoInteger(g_sym, SYMBOL_TRADE_STOPS_LEVEL), (int)SymbolInfoInteger(g_sym, SYMBOL_TRADE_FREEZE_LEVEL),
               EnumToString(PickFilling()));
   g_ready = true;
   g_state = "AQUECENDO";
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   if(g_ready) LogEvent("DEINIT", "INFO", "PASS", "DEINIT", StringFormat("motivo %d; corrente ativa=%s", reason, B(g_ch.active)));
   if(g_ch.active)
      Print(EA_NAME, ": ATENCAO - corrente ", g_ch.id, " ativa no DEINIT; sem o EA nao ha trava de lucro por software. Verifique as posicoes.");
   g_panel.Destroy();
}

void OnTick()
{
   if(!g_ready) return;
   if(!SymbolInfoTick(g_sym, g_tick)) return;
   PushTick(g_tick);
   NewDayCheck();

   datetime bt = iTime(g_sym, g_tf, 0);
   if(bt != g_lastBar)
   {
      g_lastBar = bt;
      g_tvLoss = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE_LOSS);
      if(g_tvLoss <= 0) g_tvLoss = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE);
      UpdateStructure();
   }
   UpdateMicro();

   if(g_ch.active)
   {
      SyncChain();
      if(g_ch.active)
      {
         if(g_ch.setupDone && g_ch.closed >= g_ch.filled && CountLegsOpen() == 0 && CountPendings() == 0) FinalizeChain();
         else ManageChain();
      }
      return;
   }
   ScanOrphans();
   TryStartChain();
}

void OnTimer()
{
   if(!g_ready) return;
   SymbolInfoTick(g_sym, g_tick);
   if(g_ch.active)
   {
      SyncChain();
      if(g_ch.active)
      {
         if(g_ch.setupDone && g_ch.closed >= g_ch.filled && CountLegsOpen() == 0 && CountPendings() == 0) FinalizeChain();
         else ManageChain();
      }
   }
   datetime now = TimeCurrent();
   if(now - g_lastHeartbeat >= 300)
   {
      g_lastHeartbeat = now;
      LogEvent("HEARTBEAT", "INFO", "PASS", "HEARTBEAT", StringFormat("estado %s bloqueio [%s] ticks=%d", g_state, g_block, g_tcount));
   }
   DrawPanel();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(g_panel.OnEvent(id, sparam)) DrawPanel();
}
//+------------------------------------------------------------------+
