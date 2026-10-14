//+------------------------------------------------------------------+
//|                                              ChainScalper.mq5    |
//|  LZ Trading - scalper M1 de CORRENTE de posicoes (XAUUSD)        |
//|                                                                  |
//|  TESE (hipotese, nao evidencia): quando ha tendencia em M1, o    |
//|  mercado esta em movimento (nao parado) e o preco rompe a        |
//|  maxima/minima das ultimas barras, a continuacao tende a andar   |
//|  varios "degraus" seguidos. O EA monta uma corrente de 4 a 8     |
//|  posicoes na direcao do rompimento: a 1a a mercado e as demais   |
//|  como ordens STOP pre-programadas, uma por degrau. A medida que  |
//|  o preco avanca, cada posicao recebe protecao ESCALONADA: as     |
//|  mais novas tem trailing curto, as mais antigas trailing largo.  |
//|  Se o preco recuar, saem uma a uma, de tras pra frente, ja com   |
//|  lucro travado.                                                  |
//|                                                                  |
//|  FALSIFICACAO: custo (spread+comissao) maior que o degrau;       |
//|  rompimentos que revertem no proprio degrau (placebo: inverter   |
//|  a direcao); resultado concentrado em um unico regime/sessao.    |
//|                                                                  |
//|  SEM STOP em nenhuma ordem (decisao do dono): a trava de lucro e |
//|  feita pelo EA (fecha a leg a mercado). Piramidagem tambem e     |
//|  decisao EXPLICITA do projeto.                                   |
//|  Exige conta HEDGING (cada degrau e uma posicao independente).   |
//|  Doc: MQL5/Experts/ChainScalper/README.md                        |
//+------------------------------------------------------------------+
#property copyright "LZ Trading"
#property version   "1.08"
#property description "ChainScalper M1 - corrente de 4-8 posicoes com saida escalonada"

#include <Trade/Trade.mqh>
#include <LZ/LZPanel.mqh>

#define EA_NAME     "ChainScalper"
#define EA_VERSION  "1.08"
#define CSV_SCHEMA  "1.1"
#define MAXL        16
#define PB0         8      // 0..7 = escada a favor (STOP); 8..15 = entradas de recuo (LIMIT)

//==================================================================
// INPUTS
//==================================================================
input group "=== GERAL ==="
input ulong           InpMagic            = 26100101;   // Magic (identifica a corrente)
input ENUM_TIMEFRAMES InpSignalTF         = PERIOD_M1;  // Timeframe de analise e gatilho (explicito)
input int             InpDeviationPts     = 30;         // Desvio maximo a mercado (pontos)
input bool            InpAllowBuy         = true;       // Permitir compra
input bool            InpAllowSell        = true;       // Permitir venda

input group "=== ANALISE: TENDENCIA (barras fechadas) ==="
input int             InpEmaFast          = 9;          // EMA rapida
input int             InpEmaSlow          = 34;         // EMA lenta
input int             InpSlopeBars        = 5;          // Barras para a inclinacao da EMA lenta

input group "=== ANALISE: MERCADO PARADO ==="
input int             InpAtrPeriod        = 14;         // ATR (movimento atual)
input int             InpAtrBasePeriod    = 100;        // ATR base (movimento normal)
input double          InpMinAtrToSpread   = 4.0;        // ATR minimo = x * spread
input double          InpMinAtrExpansion  = 0.85;       // ATR14/ATR100 minimo (abaixo disso = parado)
input int             InpMaxSpreadPts     = 40;         // Spread maximo (pontos)

input group "=== GATILHO: ROMPIMENTO ==="
input int             InpBreakBars        = 3;          // Maxima/minima das ultimas N barras fechadas
input double          InpMaxChaseAtr      = 0.6;        // Nao perseguir: rompimento ja foi alem de x ATR
input double          InpMaxBarRangeAtr   = 3.0;        // Barra atual maior que x ATR = exaustao/spike
input int             InpCooldownSec      = 20;         // Pausa apos fim de corrente (s). 1 corrente por barra.

input group "=== CORRENTE (tamanho e degraus) ==="
input int             InpMinLegs          = 4;          // Posicoes minimas (score baixo)
input int             InpMaxLegs          = 8;          // Posicoes maximas (score alto)
input int             InpStepPoints       = 15;         // Degrau entre as ordens (pontos)

input group "=== PROFIT ==="
input double          InpLot              = 0.01;       // Lote fixo por posicao
input bool            InpUseTP            = true;       // [true/false] TP comum da corrente (ordem no servidor)
input double          InpTPExtraSteps     = 3.0;        // TP = ultimo degrau + x degraus
input bool            InpUseProfitLock    = true;       // [true/false] Saida escalonada: trava de lucro por posicao (software)
input double          InpTrailBaseSteps   = 1.5;        // Distancia da trava da posicao mais nova (x degrau)
input double          InpTrailRankSteps   = 0.5;        // Acrescimo por posicao mais nova a frente (x degrau)
input bool            InpUseDailyTarget   = false;      // [true/false] Meta diaria (para de abrir correntes)
input double          InpDailyTargetMoney = 50.0;       // Meta diaria (moeda da conta) - lida se a meta estiver true
input double          InpCommissionPerLotRT = 0.0;      // Custo: comissao ida+volta por lote (moeda da conta)

input group "=== PROFIT: ENTRADAS DE RECUO (LIMIT, programadas conforme o preco estica a favor) ==="
input bool            InpUsePullbackLimits  = true;     // [true/false] Programa entradas LIMIT de recuo, o mais perto possivel
input int             InpPullbackDistPoints = 15;       // Distancia do recuo ate o extremo (pontos; nunca menor que o minimo do broker)
input int             InpPullbackAdvancePoints = 15;    // Cada novo extremo de x pontos a favor programa o proximo recuo
input int             InpMaxPullbackOrders  = 4;        // Maximo de ordens de recuo pendentes ao mesmo tempo (1..8)
input bool            InpUsePullbackTP      = true;     // [true/false] TP nas entradas de recuo (scalp do retorno)
input int             InpPullbackTpPoints   = 30;       // TP das entradas de recuo (pontos) - lido se true

input group "=== STOPS E PROTECOES (cada um com seu true/false) ==="
input bool            InpUseStopLoss      = false;      // [true/false] SL inicial no servidor em cada ordem
input int             InpStopLossPoints   = 200;        // Distancia do SL inicial (pontos) - lida se o SL estiver true
input bool            InpUseChainLossStop = true;       // [true/false] Perda maxima da corrente (software): fecha tudo
input double          InpChainLossMoney   = 10.0;       // Perda maxima da corrente (moeda da conta) - lida se true
input bool            InpChainLossReadsVol= true;       // [true/false] Perda da corrente le a volatilidade: nunca menor que x ATR do M1 na exposicao aberta
input double          InpChainLossAtrMult = 2.0;        // x ATR do M1 (movimento contra) usado como piso - lido se true
input bool            InpUseDailyLossStop = true;       // [true/false] Perda diaria maxima: fecha tudo e para o dia
input double          InpDailyLossMoney   = 30.0;       // Perda diaria maxima (moeda da conta) - lida se true
input bool            InpUsePendingTTL    = true;       // [true/false] Validade das ordens pendentes
input int             InpPendingTTLSec    = 120;        // Validade das pendentes (s) - lida se true

input group "=== OUTROS TFs (contexto: so segura em vela forte e rapida CONTRA) ==="
input bool            InpUseHtfShockGuard = true;       // [true/false] Nao abre/estende se M15 ou H1 abrir vela forte e rapida contra
input double          InpHtfShockMult     = 2.0;        // Choque = corpo da vela >= x mediana do range (20 velas)

input group "=== SESSAO ==="
input bool            InpUseSession       = true;       // [true/false] Operar so na janela (GMT)
input int             InpSessionStartGMT  = 7;          // Inicio (hora GMT)
input int             InpSessionEndGMT    = 20;         // Fim (hora GMT)

input group "=== MANUTENCAO ==="
input bool            InpResetDailyPnl    = false;      // [true/false] Zera o resultado do dia ao carregar o EA (use uma vez e volte para false)

input group "=== TELEMETRIA / PAINEL ==="
input bool            InpWriteCSV         = true;       // Gravar CSV (events/trades/chains/decisions)
input bool            InpShowPanel        = true;       // Painel
input int             InpPanelX           = 10;
input int             InpPanelY           = 20;
input int             InpPanelScale       = 100;        // Escala do painel (%)

//==================================================================
// CONSTANTES DE SCORE (documentadas no README; definem so o tamanho da corrente)
//==================================================================
#define SC_SEP_ATR     0.5    // |EMArapida-EMAlenta| / ATR
#define SC_SLOPE_ATR   0.4    // inclinacao da EMA lenta em SlopeBars / ATR
#define SC_EXPANSION   1.10   // ATR14 / ATR100
#define SC_ER          0.35   // eficiencia de Kaufman (10 barras)
#define SC_BODY        0.60   // corpo/range da ultima barra fechada, a favor
#define SC_MAX         5

#define TRAIL_MIN_IMPROVE_STEPS 0.25   // melhora minima do nivel de trava (x degrau)
#define MARGIN_USE_PCT          50.0   // a corrente nao usa mais que isso da margem livre

//==================================================================
// ESTADO
//==================================================================
struct SAnalysis
{
   bool     ready;
   datetime barTime;       // abertura da barra de formacao (shift 0)
   int      trend;         // +1 / -1 / 0
   double   emaF, emaS, slope, atr, atrBase, expn, er, hh, ll, close1, sepAtr, slopeAtr, bodyQ;
   int      score;
   bool     sc[SC_MAX];
};

struct SLeg
{
   bool     planned;       // faz parte do plano
   bool     placed;        // ordem enviada (a mercado ou pendente)
   bool     filled;        // virou posicao
   bool     open;          // posicao aberta agora
   bool     cancelled;     // pendente cancelada/expirada
   bool     closeDone;     // fechamento processado (CSV escrito)
   ulong    order;
   ulong    pos;
   double   planPrice;
   double   openPrice;
   datetime openTime;
   datetime closeSeen;
   double   slInit, tpInit, lockPx, tpLast;   // lockPx = nivel de trava de lucro (virtual, so no EA)
   int      closeReq;      // 1 = fechamento pedido pela trava de lucro
   double   mfe, mae;      // excursao em preco (mfe>=0, mae<=0)
   int      trailMods;
   uint     lastModErrMs;
};

struct SChain
{
   bool     active;
   bool     setupDone;
   ulong    id;
   int      dir;
   int      n;
   datetime t0, tLast, startBar;
   double   e0, step, d0, atr, lot, riskLeg, tp, spreadPts, extreme, pbRef;
   int      score;
   int      filled, closed, cancelled;
   double   gross, comm, swap, net;
   double   peakFloat, troughFloat;
   int      maxLevel;
   string   cancelReason, endReason, flatten;
   SLeg     leg[MAXL];
};

CTrade     g_trade;
CLZPanel   g_panel;
SAnalysis  g_an;
SChain     g_ch;
MqlTick    g_tick;

string     g_sym;
ENUM_TIMEFRAMES g_tf;
int        h_emaF = INVALID_HANDLE, h_emaS = INVALID_HANDLE, h_atr = INVALID_HANDLE, h_atrB = INVALID_HANDLE;
double     g_tickSize, g_point, g_tvLoss;
int        g_digits;
string     g_ccy;
bool       g_ready = false;
datetime   g_lastBar = 0;

string     g_state = "INIT";
string     g_block = "";
string     g_lastBlockLogged = "";
datetime   g_lastBlockLogTime = 0;
string     g_lastDecKey = "";

// dia / risco
datetime   g_dayStart = 0;
double     g_dayStartEquity = 0, g_dayStartBalance = 0;
double     g_dayRealized = 0;
int        g_dayChains = 0, g_dayWinChains = 0;
bool       g_haltDay = false;  string g_haltReason = "";
bool       g_targetHit = false;
datetime   g_lastChainEnd = 0;
datetime   g_lastChainBar = 0;
bool       g_orphan = false;
double     g_htfM15 = 0, g_htfH1 = 0;      // choque dos TFs maiores (corpo / mediana do range, com sinal)
datetime   g_htfLast = 0;
string     g_lastCloseReason = "";

// telemetria
string     g_runId;
ulong      g_evSeq = 0, g_decSeq = 0, g_tradeSeq = 0;
datetime   g_startTime;
datetime   g_lastHeartbeat = 0;
string     g_lastEvent = "-", g_lastOrder = "-";
string     g_pathCache[4];
string     g_periodCache[4];
ulong      g_chainCounter = 0;

//==================================================================
// UTILITARIOS
//==================================================================
double NormPrice(const double p) { return NormalizeDouble(MathRound(p / g_tickSize) * g_tickSize, g_digits); }
double FloorTick(const double p) { return NormalizeDouble(MathFloor(p / g_tickSize + 1e-9) * g_tickSize, g_digits); }
double CeilTick(const double p)  { return NormalizeDouble(MathCeil(p / g_tickSize - 1e-9) * g_tickSize, g_digits); }

double MoneyPerPrice(const double lot) { return lot * g_tvLoss / g_tickSize; }
double PriceToMoney(const double dp, const double lot) { return dp * MoneyPerPrice(lot); }

double FloorLot(const double v)
{
   double st = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_STEP);
   double vmax = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MAX);
   if(st <= 0) st = 0.01;
   double l = MathFloor(v / st + 1e-9) * st;
   l = MathMin(l, vmax);
   int vd = (int)MathMax(0, MathRound(-MathLog10(st)));
   return NormalizeDouble(l, vd);
}

string Ts(const datetime t)
{
   string s = TimeToString(t, TIME_DATE | TIME_SECONDS);
   StringReplace(s, ".", "-");
   return s;
}
string P(const double v) { return DoubleToString(v, g_digits); }
string N(const double v, const int dg) { return DoubleToString(v, dg); }
string N0(const double v, const int dg) { return (v == 0.0) ? "" : DoubleToString(v, dg); }
string B(const bool v) { return v ? "true" : "false"; }
string Esc(string s)
{
   StringReplace(s, ";", ",");
   StringReplace(s, "\"", "'");
   StringReplace(s, "\r", " ");
   StringReplace(s, "\n", " ");
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
      case 10007: return "CANCEL";
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
      case 10032: return "ONLY_REAL";
      case 10033: return "LIMIT_ORDERS";
      case 10034: return "LIMIT_VOLUME";
      case 10035: return "INVALID_ORDER";
      case 10036: return "POSITION_CLOSED";
      case 10038: return "CLOSE_VOLUME_EXCEEDS";
      case 10039: return "CLOSE_ORDER_EXISTS";
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

bool InSession()
{
   if(!InpUseSession) return true;
   MqlDateTime d; TimeToStruct(TimeGMT(), d);
   int h = d.hour;
   if(InpSessionStartGMT < InpSessionEndGMT) return (h >= InpSessionStartGMT && h < InpSessionEndGMT);
   return (h >= InpSessionStartGMT || h < InpSessionEndGMT);
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
// CSV (padrao docs/CSV.md: delimitador ';', append, cabecalho estavel)
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
             "old_sl;new_sl;trail_rank;trail_dist_price;atr;score;comment";
   if(k == K_TRADES)
      return "schema_version;trade_id;chain_id;leg;ea_name;ea_version;symbol;timeframe;magic;direction;entry_time;"
             "exit_time;duration_sec;volume;entry_price;exit_price;initial_sl;initial_tp;final_sl;final_tp;"
             "gross_profit;commission;swap;net_profit;risk_money;realized_r;mfe_price;mae_price;mfe_money;mae_money;"
             "exit_reason;setup;signal;regime;session;day_of_week;planned_entry_price;entry_slippage_points;"
             "chain_score;chain_legs_planned;chain_step_price;chain_atr;trail_mods;position_id;final_lock_price";
   if(k == K_CHAINS)
      return "schema_version;chain_id;ea_name;ea_version;symbol;timeframe;magic;direction;start_time;end_time;"
             "duration_sec;legs_planned;legs_filled;legs_cancelled;lot_per_leg;risk_per_leg_money;"
             "planned_chain_risk_money;step_price;atr;score;sl_dist_price;spread_points_start;gross_profit;"
             "commission;swap;net_profit;net_over_planned_risk;max_level_reached;peak_float_money;trough_float_money;"
             "cancel_reason;end_reason";
   return "schema_version;decision_id;timestamp_utc;server_time;ea_name;ea_version;symbol;timeframe;magic;state;"
          "setup;signal;direction;trigger_price;market_price;invalid_price;distance_to_trigger;"
          "distance_to_invalidation;risk_money;risk_structure;spread_points;decision;reason_code;reason_detail;"
          "order_sent;trade_id;score;trend;atr;atr_expansion;efficiency_ratio;legs_planned;step_price";
}

string CsvPeriod(const int k)
{
   MqlDateTime d; TimeToStruct(TimeCurrent(), d);
   return StringFormat("%04d-%02d", d.year, d.mon);
}

bool EnsureFolders(const int k)
{
   string a = "LZTrading", b = a + "\\" + EA_NAME, c = b + "\\" + CsvKindName(k);
   FolderCreate(a); FolderCreate(b); FolderCreate(c);
   return true;
}

string ResolvePath(const int k)
{
   string per = CsvPeriod(k);
   if(g_pathCache[k] != "" && g_periodCache[k] == per) return g_pathCache[k];
   EnsureFolders(k);
   string dir = "LZTrading\\" + EA_NAME + "\\" + CsvKindName(k) + "\\";
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
   if(h == INVALID_HANDLE)
   {
      Print(EA_NAME, ": CSV falhou ao abrir ", path, " err=", GetLastError());
      return;
   }
   if(FileSize(h) == 0) FileWriteString(h, CsvHeader(k) + "\r\n");
   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, line + "\r\n");
   FileClose(h);
}

//--- snapshot de posicoes do EA
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

double DailyPnl()
{
   int c; double v, p; OpenStats(c, v, p);
   return g_dayRealized + p;
}

void LogEvent(const string type, const string sev, const string decision, const string reason, const string detail,
              const int leg = -1, const uint retcode = 0, const double reqPx = 0, const double execPx = 0,
              const double vol = 0, const long latMs = -1, const ulong orderId = 0, const ulong posId = 0,
              const double oldSl = 0, const double newSl = 0, const int rank = -1, const double trailDist = 0)
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
              N(DailyPnl(), 2) + ";" + IntegerToString(cnt) + ";" + N(vl, 2) + ";" + N(pr, 2) + ";" +
              (g_ch.active ? IntegerToString((long)g_ch.id) : "") + ";" + (leg >= 0 ? IntegerToString(leg) : "") + ";" +
              (retcode > 0 ? IntegerToString((int)retcode) : "") + ";" + RetDesc(retcode) + ";" +
              N0(reqPx, g_digits) + ";" + N0(execPx, g_digits) + ";" + N0(vol, 2) + ";" +
              (latMs >= 0 ? IntegerToString(latMs) : "") + ";" + (orderId > 0 ? IntegerToString((long)orderId) : "") + ";" +
              (posId > 0 ? IntegerToString((long)posId) : "") + ";" + N0(oldSl, g_digits) + ";" + N0(newSl, g_digits) + ";" +
              (rank >= 0 ? IntegerToString(rank) : "") + ";" + N0(trailDist, g_digits) + ";" +
              (g_an.ready ? N(g_an.atr, g_digits) : "") + ";" + (g_an.ready ? IntegerToString(g_an.score) : "") + ";";
   CsvWrite(K_EVENTS, r);
}

void LogDecision(const string decision, const string reason, const string detail, const int dir, const double trigger,
                 const double market, const double invalid, const double riskMoney, const double riskStruct,
                 const bool sent, const ulong chainId, const int legs, const double step)
{
   if(!InpWriteCSV) return;
   string key = reason + "|" + IntegerToString((long)g_an.barTime) + "|" + decision;
   if(key == g_lastDecKey) return;
   g_lastDecKey = key;
   g_decSeq++;
   double sp = (g_point > 0) ? (g_tick.ask - g_tick.bid) / g_point : 0;
   string r = CSV_SCHEMA + ";" + g_runId + "-D" + IntegerToString((long)g_decSeq) + ";" + Ts(TimeGMT()) + ";" + Ts(TimeCurrent()) + ";" +
              EA_NAME + ";" + EA_VERSION + ";" + g_sym + ";" + EnumToString(g_tf) + ";" + IntegerToString((long)InpMagic) + ";" +
              g_state + ";BREAKOUT_CHAIN;" + (dir != 0 ? "TREND_BREAK" : "") + ";" + DirStr(dir) + ";" +
              N0(trigger, g_digits) + ";" + N0(market, g_digits) + ";" + N0(invalid, g_digits) + ";" +
              (trigger != 0 ? N(MathAbs(market - trigger), g_digits) : "") + ";" +
              (invalid != 0 ? N(MathAbs(market - invalid), g_digits) : "") + ";" + N0(riskMoney, 2) + ";" +
              N0(riskStruct, g_digits) + ";" + N(sp, 1) + ";" + decision + ";" + reason + ";" + Esc(detail) + ";" + B(sent) + ";" +
              (chainId > 0 ? IntegerToString((long)chainId) : "") + ";" + (g_an.ready ? IntegerToString(g_an.score) : "") + ";" +
              IntegerToString(g_an.trend) + ";" + (g_an.ready ? N(g_an.atr, g_digits) : "") + ";" +
              (g_an.ready ? N(g_an.expn, 2) : "") + ";" + (g_an.ready ? N(g_an.er, 2) : "") + ";" +
              (legs > 0 ? IntegerToString(legs) : "") + ";" + N0(step, g_digits);
   CsvWrite(K_DECIS, r);
}

//--- bloqueio: painel imediato, CSV so quando muda (>=10 s entre linhas)
void SetBlock(const string code, const string detail)
{
   g_block = code + ": " + detail;
   if(code == g_lastBlockLogged) return;
   if(TimeCurrent() - g_lastBlockLogTime < 10) return;
   g_lastBlockLogged = code; g_lastBlockLogTime = TimeCurrent();
   LogEvent("BLOCK", "INFO", "BLOCK", code, detail);
}
void ClearBlock()
{
   g_block = "";
   if(g_lastBlockLogged != "") { g_lastBlockLogged = ""; }
}

//==================================================================
// SIMBOLO / ANALISE
//==================================================================
void RefreshSymbol()
{
   g_tickSize = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_SIZE);
   g_point    = SymbolInfoDouble(g_sym, SYMBOL_POINT);
   g_digits   = (int)SymbolInfoInteger(g_sym, SYMBOL_DIGITS);
   g_tvLoss   = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(g_tvLoss <= 0) g_tvLoss = SymbolInfoDouble(g_sym, SYMBOL_TRADE_TICK_VALUE);
   if(g_tickSize <= 0) g_tickSize = g_point;
}

bool UpdateAnalysis()
{
   g_an.ready = false;
   double f[], s[], a[], b[];
   ArraySetAsSeries(f, true); ArraySetAsSeries(s, true); ArraySetAsSeries(a, true); ArraySetAsSeries(b, true);
   int need = InpSlopeBars + 1;
   if(CopyBuffer(h_emaF, 0, 1, 1, f) != 1) return false;
   if(CopyBuffer(h_emaS, 0, 1, need, s) != need) return false;
   if(CopyBuffer(h_atr, 0, 1, 1, a) != 1) return false;
   if(CopyBuffer(h_atrB, 0, 1, 1, b) != 1) return false;
   int nr = (int)MathMax(InpBreakBars, 11);
   MqlRates r[]; ArraySetAsSeries(r, true);
   if(CopyRates(g_sym, g_tf, 1, nr, r) != nr) return false;
   if(a[0] <= 0 || b[0] <= 0) return false;

   g_an.barTime = iTime(g_sym, g_tf, 0);
   g_an.emaF = f[0]; g_an.emaS = s[0]; g_an.slope = s[0] - s[InpSlopeBars];
   g_an.atr = a[0]; g_an.atrBase = b[0]; g_an.expn = a[0] / b[0];
   g_an.close1 = r[0].close;

   g_an.hh = r[0].high; g_an.ll = r[0].low;
   for(int i = 1; i < InpBreakBars; i++) { g_an.hh = MathMax(g_an.hh, r[i].high); g_an.ll = MathMin(g_an.ll, r[i].low); }

   double net = MathAbs(r[0].close - r[10].close), sum = 0;
   for(int i = 0; i < 10; i++) sum += MathAbs(r[i].close - r[i + 1].close);
   g_an.er = (sum > 0) ? net / sum : 0;

   g_an.trend = 0;
   if(g_an.emaF > g_an.emaS && g_an.close1 > g_an.emaS && g_an.slope > 0) g_an.trend = 1;
   else if(g_an.emaF < g_an.emaS && g_an.close1 < g_an.emaS && g_an.slope < 0) g_an.trend = -1;

   double rng = r[0].high - r[0].low;
   double body = (r[0].close - r[0].open) * g_an.trend;
   g_an.bodyQ = (rng > 0 && g_an.trend != 0) ? body / rng : 0;
   g_an.sepAtr = MathAbs(g_an.emaF - g_an.emaS) / g_an.atr;
   g_an.slopeAtr = MathAbs(g_an.slope) / g_an.atr;

   g_an.sc[0] = g_an.sepAtr >= SC_SEP_ATR;
   g_an.sc[1] = g_an.slopeAtr >= SC_SLOPE_ATR;
   g_an.sc[2] = g_an.expn >= SC_EXPANSION;
   g_an.sc[3] = g_an.er >= SC_ER;
   g_an.sc[4] = g_an.bodyQ >= SC_BODY;
   g_an.score = 0;
   for(int i = 0; i < SC_MAX; i++) if(g_an.sc[i]) g_an.score++;
   if(g_an.trend == 0) g_an.score = 0;
   g_an.ready = true;
   return true;
}

//==================================================================
// CORRENTE: reset / busca de ordens e posicoes
//==================================================================
void ResetChain()
{
   g_ch.active = false; g_ch.setupDone = false; g_ch.id = 0; g_ch.dir = 0; g_ch.n = 0;
   g_ch.t0 = 0; g_ch.tLast = 0; g_ch.startBar = 0;
   g_ch.e0 = 0; g_ch.step = 0; g_ch.d0 = 0; g_ch.atr = 0; g_ch.lot = 0; g_ch.riskLeg = 0; g_ch.tp = 0; g_ch.spreadPts = 0; g_ch.extreme = 0; g_ch.pbRef = 0;
   g_ch.score = 0; g_ch.filled = 0; g_ch.closed = 0; g_ch.cancelled = 0;
   g_ch.gross = 0; g_ch.comm = 0; g_ch.swap = 0; g_ch.net = 0;
   g_ch.peakFloat = 0; g_ch.troughFloat = 0; g_ch.maxLevel = -1;
   g_ch.cancelReason = ""; g_ch.endReason = ""; g_ch.flatten = "";
   for(int i = 0; i < MAXL; i++) ZeroMemory(g_ch.leg[i]);
}

//--- "CS<chain>_<leg>"  -> true se pertence a corrente atual
bool ParseComment(const string c, ulong &chain, int &leg)
{
   chain = 0; leg = -1;
   if(StringLen(c) < 4 || StringSubstr(c, 0, 2) != "CS") return false;
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

int CountLegsOpen()
{
   int n = 0;
   for(int i = 0; i < MAXL; i++) if(g_ch.leg[i].open) n++;
   return n;
}

double LegMarkPrice() { return (g_ch.dir > 0) ? g_tick.bid : g_tick.ask; }

//--- atualiza fills, fechamentos, excursoes
void ProcessLegClosed(const int idx);

void SyncChain()
{
   if(!g_ch.active) return;
   bool seen[MAXL];
   for(int i = 0; i < MAXL; i++) seen[i] = false;
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
      if(!g_ch.leg[idx].filled)
      {
         g_ch.leg[idx].filled = true; g_ch.leg[idx].placed = true; g_ch.leg[idx].planned = true;
         g_ch.leg[idx].openPrice = op;
         g_ch.leg[idx].openTime = (datetime)PositionGetInteger(POSITION_TIME);
         g_ch.leg[idx].slInit = PositionGetDouble(POSITION_SL);
         g_ch.leg[idx].tpInit = PositionGetDouble(POSITION_TP);
         g_ch.leg[idx].mfe = 0; g_ch.leg[idx].mae = 0;
         g_ch.filled++;
         g_ch.tLast = TimeCurrent();
         if(idx < PB0) g_ch.maxLevel = MathMax(g_ch.maxLevel, idx);
         double slip = (g_ch.leg[idx].planPrice > 0) ? (op - g_ch.leg[idx].planPrice) * g_ch.dir / g_point : 0;
         LogEvent("POSITION_OPEN", "INFO", "PASS", "LEG_FILLED", StringFormat("leg %d aberta slippage %.1f pts", idx, slip),
                  idx, 0, g_ch.leg[idx].planPrice, op, PositionGetDouble(POSITION_VOLUME), -1, 0, t);
      }
      g_ch.leg[idx].open = true;
      g_ch.leg[idx].pos = t;
      g_ch.leg[idx].tpLast = PositionGetDouble(POSITION_TP);
      double mark = LegMarkPrice();
      double ex = (mark - op) * g_ch.dir;
      if(ex > g_ch.leg[idx].mfe) g_ch.leg[idx].mfe = ex;
      if(ex < g_ch.leg[idx].mae) g_ch.leg[idx].mae = ex;
   }
   if(floatMoney > g_ch.peakFloat) g_ch.peakFloat = floatMoney;
   if(floatMoney < g_ch.troughFloat) g_ch.troughFloat = floatMoney;

   //--- pendentes ainda vivas
   bool pend[MAXL];
   for(int i = 0; i < MAXL; i++) pend[i] = false;
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
      //--- pendente sumiu sem virar posicao: expirou/cancelada
      if(g_ch.leg[i].placed && !g_ch.leg[i].filled && !g_ch.leg[i].cancelled && !pend[i] && !seen[i] && i != 0)
      {
         g_ch.leg[i].cancelled = true; g_ch.cancelled++;
         LogEvent("ORDER_CANCEL", "INFO", "PASS", "PENDING_GONE", StringFormat("leg %d pendente expirou/cancelada", i), i, 0, g_ch.leg[i].planPrice, 0, 0, -1, g_ch.leg[i].order);
      }
      //--- posicao sumiu: fechamento
      if(g_ch.leg[i].open && !seen[i])
      {
         g_ch.leg[i].open = false;
         g_ch.leg[i].closeSeen = TimeCurrent();
      }
      if(g_ch.leg[i].filled && !g_ch.leg[i].open && !g_ch.leg[i].closeDone)
         ProcessLegClosed(i);
   }
}

//--- le o fechamento no historico e grava a linha de TRADES
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
   if(!found && TimeCurrent() - g_ch.leg[idx].closeSeen < 5) return;   // historico ainda nao chegou
   g_ch.leg[idx].closeDone = true;
   g_ch.closed++;

   double net = profit + comm + swap + fee;
   g_ch.gross += profit; g_ch.comm += comm + fee; g_ch.swap += swap; g_ch.net += net;
   g_dayRealized += net;

   string er = "UNKNOWN";
   if(found)
   {
      if(reason == DEAL_REASON_TP) er = "TP";
      else if(reason == DEAL_REASON_SL) er = "SL";
      else if(reason == DEAL_REASON_EXPERT)
         er = (g_ch.leg[idx].closeReq == 1) ? "TRAIL" : ((g_lastCloseReason != "") ? g_lastCloseReason : "EMERGENCY");
      else if(reason == DEAL_REASON_CLIENT || reason == DEAL_REASON_MOBILE || reason == DEAL_REASON_WEB) er = "MANUAL";
      else if(reason == DEAL_REASON_SO) er = "EMERGENCY";
   }
   else
      LogEvent("WARNING", "WARN", "PASS", "NO_CLOSE_DEAL", StringFormat("leg %d sem deal de saida no historico", idx), idx, 0, 0, 0, 0, -1, 0, g_ch.leg[idx].pos);

   double mfeM = PriceToMoney(g_ch.leg[idx].mfe, g_ch.lot), maeM = PriceToMoney(g_ch.leg[idx].mae, g_ch.lot);
   double slip = (g_ch.leg[idx].planPrice > 0) ? (g_ch.leg[idx].openPrice - g_ch.leg[idx].planPrice) * g_ch.dir / g_point : 0;
   g_tradeSeq++;
   MqlDateTime dt; TimeToStruct(g_ch.leg[idx].openTime, dt);
   string r = CSV_SCHEMA + ";" + g_runId + "-T" + IntegerToString((long)g_tradeSeq) + ";" + IntegerToString((long)g_ch.id) + ";" +
              IntegerToString(idx) + ";" + EA_NAME + ";" + EA_VERSION + ";" + g_sym + ";" + EnumToString(g_tf) + ";" +
              IntegerToString((long)InpMagic) + ";" + DirStr(g_ch.dir) + ";" + Ts(g_ch.leg[idx].openTime) + ";" + (found ? Ts(exitTime) : "") + ";" +
              (found ? IntegerToString((long)(exitTime - g_ch.leg[idx].openTime)) : "") + ";" + N(g_ch.lot, 2) + ";" +
              N(g_ch.leg[idx].openPrice, g_digits) + ";" + (found ? N(exitPx, g_digits) : "") + ";" + N0(g_ch.leg[idx].slInit, g_digits) + ";" +
              N0(g_ch.leg[idx].tpInit, g_digits) + ";" + "" + ";" + N0(g_ch.leg[idx].tpLast, g_digits) + ";" +
              (found ? N(profit, 2) : "") + ";" + N(comm + fee, 2) + ";" + N(swap, 2) + ";" + (found ? N(net, 2) : "") + ";" +
              N0(g_ch.riskLeg, 2) + ";" + ((found && g_ch.riskLeg > 0) ? N(net / g_ch.riskLeg, 2) : "") + ";" +
              N(g_ch.leg[idx].mfe, g_digits) + ";" + N(g_ch.leg[idx].mae, g_digits) + ";" + N(mfeM, 2) + ";" + N(maeM, 2) + ";" + er + ";" +
              (idx >= PB0 ? "PULLBACK_LIMIT;TREND_PULLBACK;" : "BREAKOUT_CHAIN;TREND_BREAK;") + (g_an.ready ? IntegerToString(g_an.trend) : "") + ";" + SessionName() + ";" +
              IntegerToString(dt.day_of_week) + ";" + N0(g_ch.leg[idx].planPrice, g_digits) + ";" + N(slip, 1) + ";" +
              IntegerToString(g_ch.score) + ";" + IntegerToString(g_ch.n) + ";" + N(g_ch.step, g_digits) + ";" +
              N(g_ch.atr, g_digits) + ";" + IntegerToString(g_ch.leg[idx].trailMods) + ";" + IntegerToString((long)g_ch.leg[idx].pos) + ";" + N0(g_ch.leg[idx].lockPx, g_digits);
   CsvWrite(K_TRADES, r);
   LogEvent("POSITION_CLOSE", "INFO", "PASS", er, StringFormat("leg %d net %.2f", idx, net), idx, 0, 0, exitPx, g_ch.lot, -1, 0, g_ch.leg[idx].pos);
}

//==================================================================
// EXECUCAO
//==================================================================
bool SendMarketLeg(const int dir, const double lot, const double slDist, const double tpDistFromEntry,
                   const string comment, double &fillPx, double &slOut, double &tpOut, double &reqPx)
{
   fillPx = 0; slOut = 0; tpOut = 0; reqPx = 0;
   ENUM_ORDER_TYPE ot = dir > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   for(int att = 0; att < 3; att++)
   {
      if(!SymbolInfoTick(g_sym, g_tick)) continue;
      double px = dir > 0 ? g_tick.ask : g_tick.bid;
      double sl = (slDist > 0) ? NormPrice(px - dir * slDist) : 0;   // 0 = sem SL (InpUseStopLoss=false)
      double tp = (tpDistFromEntry > 0) ? NormPrice(px + dir * tpDistFromEntry) : 0;
      reqPx = px; slOut = sl; tpOut = tp;
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
   {
      tt = ORDER_TIME_SPECIFIED;
      exp = TimeCurrent() + InpPendingTTLSec;
   }
   ulong t0 = GetMicrosecondCount();
   bool ok = g_trade.OrderOpen(g_sym, ot, lot, 0, price, sl, tp, tt, exp, comment);
   long lat = (long)((GetMicrosecondCount() - t0) / 1000);
   uint rc = g_trade.ResultRetcode();
   g_lastOrder = StringFormat("STOP L%d %s rc=%d", idx, P(price), (int)rc);
   if(ok && RetOk(rc))
   {
      g_ch.leg[idx].placed = true; g_ch.leg[idx].planned = true; g_ch.leg[idx].order = g_trade.ResultOrder();
      g_ch.leg[idx].planPrice = price; g_ch.leg[idx].slInit = sl; g_ch.leg[idx].tpInit = tp;
      LogEvent("ORDER_PLACED", "INFO", "PASS", "PENDING_STOP", StringFormat("leg %d stop @ %s", idx, P(price)),
               idx, rc, price, 0, lot, lat, g_ch.leg[idx].order);
      return true;
   }
   LogEvent("ORDER_REJECTED", "WARN", "BLOCK", "BROKER_REJECT", g_trade.ResultRetcodeDescription(), idx, rc, price, 0, lot, lat);
   return false;
}

bool PlacePullback(const int idx, const double price, const double tp)
{
   ENUM_ORDER_TYPE ot = g_ch.dir > 0 ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
   ENUM_ORDER_TYPE_TIME tt = ORDER_TIME_GTC;
   datetime exp = 0;
   long em = SymbolInfoInteger(g_sym, SYMBOL_EXPIRATION_MODE);
   if((em & SYMBOL_EXPIRATION_SPECIFIED) != 0 && InpUsePendingTTL)
   { tt = ORDER_TIME_SPECIFIED; exp = TimeCurrent() + InpPendingTTLSec; }
   string comment = StringFormat("CS%I64u_%d", g_ch.id, idx);
   ulong t0 = GetMicrosecondCount();
   bool ok = g_trade.OrderOpen(g_sym, ot, g_ch.lot, 0, price, 0, tp, tt, exp, comment);
   long lat = (long)((GetMicrosecondCount() - t0) / 1000);
   uint rc = g_trade.ResultRetcode();
   g_lastOrder = StringFormat("LIMIT L%d %s rc=%d", idx, P(price), (int)rc);
   if(ok && RetOk(rc))
   {
      g_ch.leg[idx].placed = true; g_ch.leg[idx].planned = true; g_ch.leg[idx].order = g_trade.ResultOrder();
      g_ch.leg[idx].planPrice = price; g_ch.leg[idx].slInit = 0; g_ch.leg[idx].tpInit = tp;
      LogEvent("ORDER_PLACED", "INFO", "PASS", "PULLBACK_LIMIT", StringFormat("recuo %d limit @ %s tp %s", idx - PB0 + 1, P(price), tp > 0 ? P(tp) : "OFF"),
               idx, rc, price, 0, g_ch.lot, lat, g_ch.leg[idx].order);
      return true;
   }
   LogEvent("ORDER_REJECTED", "WARN", "BLOCK", "BROKER_REJECT", g_trade.ResultRetcodeDescription(), idx, rc, price, 0, g_ch.lot, lat);
   return false;
}

//--- cancela ordens pendentes da corrente mais velhas que ttl segundos (cada ordem tem a sua idade)
void CancelStale(const int ttl)
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      ulong t = OrderGetTicket(k);
      if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != g_sym || (ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic) continue;
      if(TimeCurrent() - (datetime)OrderGetInteger(ORDER_TIME_SETUP) < ttl) continue;
      ulong cid; int idx = -1;
      ParseComment(OrderGetString(ORDER_COMMENT), cid, idx);
      bool ok = g_trade.OrderDelete(t);
      uint rc = g_trade.ResultRetcode();
      if(ok && RetOk(rc))
      {
         if(idx >= 0 && g_ch.active && cid == g_ch.id && !g_ch.leg[idx].cancelled) { g_ch.leg[idx].cancelled = true; g_ch.cancelled++; }
         LogEvent("ORDER_CANCEL", "INFO", "PASS", "PENDING_TTL", StringFormat("pendente %I64u cancelada por validade", t), idx, rc, 0, 0, 0, -1, t);
      }
      else
         LogEvent("ERROR", "ERROR", "BLOCK", "CANCEL_FAILED", g_trade.ResultRetcodeDescription(), idx, rc, 0, 0, 0, -1, t);
   }
}

void CancelPendings(const string reason, const bool forwardOnly = false)
{
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      ulong t = OrderGetTicket(k);
      if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != g_sym || (ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic) continue;
      ulong cid; int idx = -1;
      ParseComment(OrderGetString(ORDER_COMMENT), cid, idx);
      if(forwardOnly && idx >= PB0) continue;
      bool ok = g_trade.OrderDelete(t);
      uint rc = g_trade.ResultRetcode();
      if(ok && RetOk(rc))
      {
         if(idx >= 0 && g_ch.active && cid == g_ch.id && !g_ch.leg[idx].cancelled)
         { g_ch.leg[idx].cancelled = true; g_ch.cancelled++; }
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

//==================================================================
// INICIO DA CORRENTE
//==================================================================
void StartChain(const int dir)
{
   double ask = g_tick.ask, bid = g_tick.bid, px = dir > 0 ? ask : bid;
   double spreadP = ask - bid;
   double atr = g_an.atr;
   double stopsP = (double)SymbolInfoInteger(g_sym, SYMBOL_TRADE_STOPS_LEVEL) * g_point;
   double freezeP = (double)SymbolInfoInteger(g_sym, SYMBOL_TRADE_FREEZE_LEVEL) * g_point;
   double minPend = MathMax(MathMax(stopsP, freezeP), g_tickSize);   // distancia minima do broker para pendentes/SL
   double trigger = dir > 0 ? g_an.hh : g_an.ll;

   //--- degrau fixo em pontos; se o broker nao aceita, bloqueia (nao altera o valor em silencio)
   double S = CeilTick(InpStepPoints * g_point);
   if(S < minPend)
   {
      string d = StringFormat("degrau %d pts < minimo do broker %.0f pts (stops/freeze level)", InpStepPoints, minPend / g_point);
      SetBlock("STEP_TOO_SMALL", d);
      LogDecision("BLOCK", "STEP_TOO_SMALL", d, dir, trigger, px, 0, 0, 0, false, 0, 0, S);
      return;
   }
   double d0 = InpUseStopLoss ? CeilTick(InpStopLossPoints * g_point) : 0;
   if(InpUseStopLoss && d0 < minPend + spreadP)
   {
      string d = StringFormat("SL %d pts < minimo (stops level + spread) %.0f pts", InpStopLossPoints, (minPend + spreadP) / g_point);
      SetBlock("SL_TOO_CLOSE", d);
      LogDecision("BLOCK", "SL_TOO_CLOSE", d, dir, trigger, px, 0, 0, d0, false, 0, 0, S);
      return;
   }
   double invalid = (d0 > 0) ? NormPrice(px - dir * d0) : 0;

   //--- lote fixo (validado no OnInit)
   double lot = FloorLot(InpLot);
   double vmin = SymbolInfoDouble(g_sym, SYMBOL_VOLUME_MIN);
   if(lot < vmin)
   {
      string d = StringFormat("lote %.4f < minimo %.2f", lot, vmin);
      SetBlock("LOT_INVALID", d);
      LogDecision("BLOCK", "LOT_INVALID", d, dir, trigger, px, invalid, 0, d0, false, 0, 0, S);
      return;
   }
   double riskLeg = (d0 > 0) ? PriceToMoney(d0, lot) : 0;   // risco ate o SL (0 = sem SL)

   //--- tamanho da corrente: score -> n, limitado pela margem
   int n = InpMinLegs + (int)MathRound((double)(InpMaxLegs - InpMinLegs) * g_an.score / (double)SC_MAX);
   n = MathMax(InpMinLegs, MathMin(InpMaxLegs, n));
   double marg = 0;
   if(!OrderCalcMargin(dir > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, g_sym, lot, px, marg) || marg <= 0)
   { SetBlock("NO_MARGIN", "OrderCalcMargin falhou"); return; }
   double freeM = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   while(n >= InpMinLegs && n * marg > freeM * MARGIN_USE_PCT / 100.0) n--;
   if(n < InpMinLegs)
   {
      string d = StringFormat("margem/pos %.2f, livre %.2f, limite %.0f%%", marg, freeM, MARGIN_USE_PCT);
      SetBlock("NO_MARGIN", d);
      LogDecision("BLOCK", "NO_MARGIN", d, dir, trigger, px, invalid, riskLeg, d0, false, 0, n, S);
      return;
   }

   //--- registra e envia
   g_chainCounter++;
   GlobalVariableSet("CS_" + IntegerToString((long)InpMagic) + "_chain", (double)g_chainCounter);
   ResetChain();
   g_ch.id = g_chainCounter; g_ch.dir = dir; g_ch.n = n; g_ch.t0 = TimeCurrent(); g_ch.tLast = g_ch.t0;
   g_ch.startBar = g_an.barTime; g_ch.step = S; g_ch.d0 = d0; g_ch.atr = atr; g_ch.lot = lot; g_ch.riskLeg = riskLeg;
   g_ch.score = g_an.score; g_ch.spreadPts = spreadP / g_point;
   g_lastChainBar = g_an.barTime;
   g_ch.active = true;   // so LogEvent enxerga o chain_id

   LogEvent("SIGNAL", "INFO", "PASS", "BREAKOUT", StringFormat("%s score %d n %d step %d pts lot %.2f SL %s", DirStr(dir), g_an.score, n,
            InpStepPoints, lot, InpUseStopLoss ? P(d0) : "OFF"), -1, 0, px, 0, lot);

   string cm0 = StringFormat("CS%I64u_0", g_ch.id);
   double tpDist = InpUseTP ? (n - 1 + InpTPExtraSteps) * S : 0;
   double fill, sl0, tp0, req;
   if(!SendMarketLeg(dir, lot, d0, tpDist, cm0, fill, sl0, tp0, req))
   {
      LogDecision("BLOCK", "BROKER_REJECT", g_trade.ResultRetcodeDescription(), dir, trigger, px, invalid, riskLeg, d0, true, g_ch.id, n, S);
      ResetChain();
      g_lastChainEnd = TimeCurrent();
      SetBlock("BROKER_REJECT", "leg 0 recusada: " + g_trade.ResultRetcodeDescription());
      return;
   }
   LogDecision("PASS", "BREAKOUT", StringFormat("score %d n %d", g_an.score, n), dir, trigger, px, invalid, riskLeg, d0, true, g_ch.id, n, S);

   g_ch.e0 = (fill > 0) ? fill : px;
   g_ch.leg[0].planned = true; g_ch.leg[0].placed = true; g_ch.leg[0].planPrice = req;
   g_ch.tp = InpUseTP ? NormPrice(g_ch.e0 + dir * tpDist) : 0;
   g_ch.extreme = g_ch.e0; g_ch.pbRef = g_ch.e0;
   g_dayChains++;

   //--- pendentes 1..n-1, uma por degrau, relativas ao preco real de execucao
   SymbolInfoTick(g_sym, g_tick);
   for(int i = 1; i < n; i++)
   {
      double price = NormPrice(g_ch.e0 + dir * i * S);
      double cur = dir > 0 ? g_tick.ask : g_tick.bid;
      double dist = (price - cur) * dir;
      g_ch.leg[i].planned = true;
      if(dist < minPend)
      {
         g_ch.leg[i].cancelled = true; g_ch.cancelled++;
         LogEvent("WARNING", "WARN", "BLOCK", "LEVEL_PASSED", StringFormat("leg %d: nivel %s ja alcancado (dist %s < min %s)", i, P(price), P(dist), P(minPend)), i);
         continue;
      }
      double sl = (d0 > 0) ? NormPrice(price - dir * d0) : 0;
      string cm = StringFormat("CS%I64u_%d", g_ch.id, i);
      if(!PlacePending(i, price, sl, g_ch.tp, lot, cm)) { g_ch.leg[i].cancelled = true; g_ch.cancelled++; }
   }
   g_ch.setupDone = true;
   ClearBlock();
}

//==================================================================
// CONTEXTO DE TFs MAIORES (M15 e H1): nao e filtro, so segura em choque
//==================================================================
//--- corpo da vela recem-aberta (ou que acabou de fechar) / mediana do range das 20 anteriores; com sinal; 0 = sem choque
double HtfShock(const ENUM_TIMEFRAMES tf)
{
   MqlRates r[]; ArraySetAsSeries(r, true);
   if(CopyRates(g_sym, tf, 0, 22, r) != 22) return 0;
   double rg[]; ArrayResize(rg, 20);
   for(int i = 0; i < 20; i++) rg[i] = r[i + 2].high - r[i + 2].low;
   ArraySort(rg);
   double med = rg[10];
   if(med <= 0) return 0;
   int per = PeriodSeconds(tf);
   if(TimeCurrent() - r[0].time > per / 3) return 0;        // so vela RECEM-aberta: "rapida"
   double b0 = r[0].close - r[0].open;                       // vela atual (close = preco)
   double b1 = r[1].close - r[1].open;                       // vela que acabou de fechar
   double b = (MathAbs(b0) >= MathAbs(b1)) ? b0 : b1;
   return b / med;
}

void UpdateHtf()
{
   datetime t = TimeCurrent();
   if(t == g_htfLast) return;
   g_htfLast = t;
   g_htfM15 = HtfShock(PERIOD_M15);
   g_htfH1  = HtfShock(PERIOD_H1);
}

bool HtfAdverse(const int dir, string &why)
{
   why = "";
   if(!InpUseHtfShockGuard) return false;
   if(g_htfM15 * dir <= -InpHtfShockMult) { why = StringFormat("M15 com vela %+.1fx a mediana contra a direcao", g_htfM15); return true; }
   if(g_htfH1  * dir <= -InpHtfShockMult) { why = StringFormat("H1 com vela %+.1fx a mediana contra a direcao", g_htfH1); return true; }
   return false;
}

//==================================================================
// GATILHO
//==================================================================
void TryStartChain()
{
   //--- protecoes e permissoes
   if(g_orphan)    { SetBlock("ORPHAN", "posicoes/ordens sem corrente associada (protegidas por SL/TP do broker)"); g_state = "BLOQUEADO"; return; }
   if(g_haltDay)   { SetBlock("DAILY_LOSS_REACHED", g_haltReason); g_state = "PARADO"; return; }
   if(g_targetHit) { SetBlock("DAILY_TARGET_REACHED", "meta diaria atingida"); g_state = "META"; return; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_EXPERT) || !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
   { SetBlock("TRADING_NOT_ALLOWED", "AutoTrading/conta/EA sem permissao"); g_state = "BLOQUEADO"; return; }
   if(SymbolInfoInteger(g_sym, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
   { SetBlock("SYMBOL_DISABLED", "modo de negociacao do simbolo nao e FULL"); g_state = "BLOQUEADO"; return; }
   if(!InSession()) { SetBlock("SESSION_CLOSED", StringFormat("fora da janela %02d-%02d GMT", InpSessionStartGMT, InpSessionEndGMT)); g_state = "FORA SESSAO"; return; }
   if(!g_an.ready)  { SetBlock("DATA_NOT_READY", "indicadores nao prontos"); g_state = "BLOQUEADO"; return; }
   if(TimeCurrent() - g_lastChainEnd < InpCooldownSec)
   { SetBlock("COOLDOWN", StringFormat("%d s apos a ultima corrente", InpCooldownSec)); g_state = "AGUARDANDO"; return; }

   g_state = "AGUARDANDO";
   double spP = g_tick.ask - g_tick.bid;
   double spPts = spP / g_point;
   if(spPts > InpMaxSpreadPts) { SetBlock("SPREAD_HIGH", StringFormat("spread %.0f > max %d pts", spPts, InpMaxSpreadPts)); return; }

   //--- mercado parado
   if(g_an.atr < InpMinAtrToSpread * spP)
   { SetBlock("DEAD_MARKET", StringFormat("ATR %.2f < %.1f x spread %.2f", g_an.atr, InpMinAtrToSpread, spP)); return; }
   if(g_an.expn < InpMinAtrExpansion)
   { SetBlock("DEAD_MARKET", StringFormat("ATR14/ATR100 %.2f < %.2f", g_an.expn, InpMinAtrExpansion)); return; }

   //--- tendencia
   if(g_an.trend == 0) { SetBlock("NO_TREND", "EMAs/inclinacao nao alinhadas"); return; }
   int dir = g_an.trend;
   if(dir > 0 && !InpAllowBuy)  { SetBlock("DIRECTION_OFF", "compra desligada"); return; }
   if(dir < 0 && !InpAllowSell) { SetBlock("DIRECTION_OFF", "venda desligada"); return; }
   string whyHtf;
   if(HtfAdverse(dir, whyHtf)) { SetBlock("HTF_SHOCK", whyHtf + " - aguardando"); return; }

   //--- rompimento (decisao intrabar explicita: usa preco ao vivo contra o extremo das barras FECHADAS)
   double px = dir > 0 ? g_tick.ask : g_tick.bid;
   double lvl = dir > 0 ? g_an.hh : g_an.ll;
   bool broke = dir > 0 ? (px > lvl) : (px < lvl);
   if(!broke) { g_block = ""; g_state = "ARMADO"; return; }

   double beyond = (px - lvl) * dir;
   if(beyond > InpMaxChaseAtr * g_an.atr)
   {
      string d = StringFormat("rompimento %s alem do nivel (max %.1f ATR = %s)", P(beyond), InpMaxChaseAtr, P(InpMaxChaseAtr * g_an.atr));
      SetBlock("CHASE_TOO_FAR", d);
      LogDecision("BLOCK", "CHASE_TOO_FAR", d, dir, lvl, px, 0, 0, 0, false, 0, 0, 0);
      return;
   }
   double barRange = iHigh(g_sym, g_tf, 0) - iLow(g_sym, g_tf, 0);
   if(barRange > InpMaxBarRangeAtr * g_an.atr)
   {
      string d = StringFormat("barra atual %s > %.1f ATR", P(barRange), InpMaxBarRangeAtr);
      SetBlock("INVALIDATION", d);
      LogDecision("BLOCK", "INVALIDATION", d, dir, lvl, px, 0, 0, 0, false, 0, 0, 0);
      return;
   }
   if(g_lastChainBar == g_an.barTime)
   { SetBlock("COOLDOWN", "uma corrente por barra"); return; }

   StartChain(dir);
}

//==================================================================
// GERENCIAMENTO
//==================================================================
//--- fecha UMA leg a mercado (saida de lucro pela trava; nao e ordem de stop)
void CloseLeg(const int i, const int req, const string reason)
{
   uint nowMs = GetTickCount();
   if(g_ch.leg[i].lastModErrMs != 0 && nowMs - g_ch.leg[i].lastModErrMs < 1000) return;
   g_ch.leg[i].closeReq = req;
   bool ok = g_trade.PositionClose(g_ch.leg[i].pos, (ulong)InpDeviationPts);
   uint rc = g_trade.ResultRetcode();
   g_lastOrder = StringFormat("CLOSE L%d rc=%d", i, (int)rc);
   if(!(ok && RetOk(rc)))
   {
      g_ch.leg[i].lastModErrMs = nowMs;
      LogEvent("ERROR", "ERROR", "BLOCK", "CLOSE_FAILED", g_trade.ResultRetcodeDescription(), i, rc, 0, 0, g_ch.lot, -1, 0, g_ch.leg[i].pos);
   }
   else
      LogEvent("ORDER_SEND", "INFO", "PASS", reason, StringFormat("leg %d fechada pela trava de lucro %s", i, P(g_ch.leg[i].lockPx)),
               i, rc, 0, 0, g_ch.lot, -1, 0, g_ch.leg[i].pos);
}

//--- trava de lucro escalonada, SEM ordem de stop no servidor: o EA guarda o nivel e fecha a leg a mercado se o preco voltar a ele
void ManageTrail()
{
   int dir = g_ch.dir;
   double S = g_ch.step;
   double spreadP = g_tick.ask - g_tick.bid;
   double commPrice = (InpCommissionPerLotRT > 0) ? InpCommissionPerLotRT / MoneyPerPrice(1.0) : 0;
   double cost = spreadP + commPrice;
   double minImp = MathMax(g_tickSize, TRAIL_MIN_IMPROVE_STEPS * S);
   double mark = LegMarkPrice();

   for(int i = 0; i < MAXL; i++)
   {
      if(!g_ch.leg[i].open) continue;
      double lk = g_ch.leg[i].lockPx;

      //--- 1) recuou ate o nivel travado: realiza o lucro desta leg
      if(lk > 0 && (mark - lk) * dir <= 0) { CloseLeg(i, 1, "TRAIL_EXIT"); continue; }

      //--- 2) novo nivel: posicoes mais novas travam perto, as antigas ficam largas
      int rank = 0;
      for(int j = i + 1; j < MAXL; j++) if(g_ch.leg[j].open && ((j >= PB0) == (i >= PB0))) rank++;
      double dist = S * (InpTrailBaseSteps + rank * InpTrailRankSteps);
      double desired = dir > 0 ? FloorTick(mark - dist) : CeilTick(mark + dist);
      double locked = (desired - g_ch.leg[i].openPrice) * dir;
      if(locked < cost) continue;                          // ainda nao ha lucro a travar
      if((mark - desired) * dir < g_tickSize) continue;
      if(lk != 0 && (desired - lk) * dir < minImp) continue;

      g_ch.leg[i].lockPx = desired;
      g_ch.leg[i].trailMods++;
      LogEvent("POSITION_MODIFY", "INFO", "PASS", "LOCK_LEVEL",
               StringFormat("leg %d rank %d trava virtual (sem ordem no servidor) lucro travado %s", i, rank, P(locked)),
               i, 0, 0, 0, g_ch.lot, -1, 0, g_ch.leg[i].pos, lk, desired, rank, dist);
   }
}

void FinalizeChain()
{
   datetime now = TimeCurrent();
   double planned = g_ch.n * g_ch.riskLeg;
   string er = g_ch.flatten != "" ? g_ch.flatten : (g_ch.net >= 0 ? "TRAIL_OR_TP" : "SL");
   g_ch.endReason = er;
   string r = CSV_SCHEMA + ";" + IntegerToString((long)g_ch.id) + ";" + EA_NAME + ";" + EA_VERSION + ";" + g_sym + ";" + EnumToString(g_tf) + ";" +
              IntegerToString((long)InpMagic) + ";" + DirStr(g_ch.dir) + ";" + Ts(g_ch.t0) + ";" + Ts(now) + ";" +
              IntegerToString((long)(now - g_ch.t0)) + ";" + IntegerToString(g_ch.n) + ";" + IntegerToString(g_ch.filled) + ";" +
              IntegerToString(g_ch.cancelled) + ";" + N(g_ch.lot, 2) + ";" + N0(g_ch.riskLeg, 2) + ";" + N0(planned, 2) + ";" +
              N(g_ch.step, g_digits) + ";" + N(g_ch.atr, g_digits) + ";" + IntegerToString(g_ch.score) + ";" + N(g_ch.d0, g_digits) + ";" +
              N(g_ch.spreadPts, 1) + ";" + N(g_ch.gross, 2) + ";" + N(g_ch.comm, 2) + ";" + N(g_ch.swap, 2) + ";" + N(g_ch.net, 2) + ";" +
              (planned > 0 ? N(g_ch.net / planned, 3) : "") + ";" + IntegerToString(g_ch.maxLevel + 1) + ";" +
              N(g_ch.peakFloat, 2) + ";" + N(g_ch.troughFloat, 2) + ";" + g_ch.cancelReason + ";" + er;
   CsvWrite(K_CHAINS, r);
   LogEvent("CHAIN_END", "INFO", "PASS", er,
            StringFormat("corrente %I64u: %d/%d legs, net %.2f (%.2f%% do risco planejado)", g_ch.id, g_ch.filled, g_ch.n, g_ch.net,
                         planned > 0 ? 100.0 * g_ch.net / planned : 0.0));

   if(g_ch.net >= 0) g_dayWinChains++;
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

//--- perda maxima da corrente em dinheiro, com PISO de volatilidade: nunca menor que x ATR(M1) na exposicao aberta
double ChainLossLimit()
{
   double lim = InpChainLossMoney;
   if(InpChainLossReadsVol && g_an.ready)
   {
      int c; double vol, p;
      OpenStats(c, vol, p);
      double volLim = InpChainLossAtrMult * g_an.atr * MoneyPerPrice(vol);
      if(volLim > lim) lim = volLim;
   }
   return lim;
}

//--- a cada novo extremo a favor, programa UMA entrada LIMIT de recuo o mais perto possivel do preco
void ProgramPullbacks()
{
   int dir = g_ch.dir;
   double mark = LegMarkPrice();
   if(g_ch.extreme == 0 || (mark - g_ch.extreme) * dir > 0) g_ch.extreme = mark;
   if((g_ch.extreme - g_ch.pbRef) * dir < InpPullbackAdvancePoints * g_point) return;

   string why;
   if(HtfAdverse(dir, why)) return;
   if(g_an.ready && g_an.trend != dir) return;
   if(!InSession()) return;

   int pend = 0;
   for(int i = PB0; i < MAXL; i++)
      if(g_ch.leg[i].placed && !g_ch.leg[i].filled && !g_ch.leg[i].cancelled) pend++;
   if(pend >= InpMaxPullbackOrders) return;

   double stopsP = (double)SymbolInfoInteger(g_sym, SYMBOL_TRADE_STOPS_LEVEL) * g_point;
   double freezeP = (double)SymbolInfoInteger(g_sym, SYMBOL_TRADE_FREEZE_LEVEL) * g_point;
   double minD = MathMax(MathMax(stopsP, freezeP), g_tickSize);
   double dist = MathMax(InpPullbackDistPoints * g_point, minD);
   double price = (dir > 0) ? FloorTick(g_ch.extreme - dist) : CeilTick(g_ch.extreme + dist);
   double cur = (dir > 0) ? g_tick.ask : g_tick.bid;
   double lim = (dir > 0) ? cur - minD : cur + minD;                   // o broker exige distancia minima do preco atual
   if((price - lim) * dir > 0) price = (dir > 0) ? FloorTick(lim) : CeilTick(lim);

   for(int i = PB0; i < MAXL; i++)                                      // nao empilha duas ordens de recuo no mesmo nivel
      if(g_ch.leg[i].placed && !g_ch.leg[i].filled && !g_ch.leg[i].cancelled && MathAbs(g_ch.leg[i].planPrice - price) < 0.5 * InpPullbackAdvancePoints * g_point)
      { g_ch.pbRef = g_ch.extreme; return; }

   int slot = -1;
   for(int i = PB0; i < MAXL; i++)
   {
      if(!g_ch.leg[i].placed || g_ch.leg[i].closeDone || (g_ch.leg[i].cancelled && !g_ch.leg[i].filled)) { slot = i; break; }
   }
   if(slot < 0) return;
   ZeroMemory(g_ch.leg[slot]);
   double tp = InpUsePullbackTP ? NormPrice(price + dir * InpPullbackTpPoints * g_point) : 0;
   PlacePullback(slot, price, tp);
   g_ch.pbRef = g_ch.extreme;                                           // mesmo se recusada, so tenta de novo no proximo extremo
}

double OpenFloat()
{
   int c; double v, p; OpenStats(c, v, p);
   return p;
}

void ManageChain()
{
   datetime now = TimeCurrent();
   int openN = CountLegsOpen();
   int pendN = CountPendings();
   g_state = "CORRENTE";

   //--- 1) emergencias: nao dependem de sinal
   if(g_ch.flatten == "")
   {
      if(InpUseDailyLossStop && DailyPnl() <= -InpDailyLossMoney)
      {
         g_ch.flatten = "DAILY_LOSS"; g_haltDay = true;
         g_haltReason = StringFormat("perda diaria %.2f", DailyPnl());
         LogEvent("KILL_SWITCH", "ERROR", "BLOCK", "DAILY_LOSS", g_haltReason);
      }
      else if(InpUseChainLossStop && g_ch.filled > 0 && openN > 0 && g_ch.net + OpenFloat() <= -ChainLossLimit())
      {
         g_ch.flatten = "EMERGENCY";
         LogEvent("RISK", "ERROR", "BLOCK", "CHAIN_LOSS",
                  StringFormat("corrente %.2f <= -%.2f (dinheiro %.2f, piso de volatilidade %s)", g_ch.net + OpenFloat(), ChainLossLimit(),
                               InpChainLossMoney, InpChainLossReadsVol ? "ligado" : "desligado"));
      }
   }
   if(g_ch.flatten != "")
   {
      if(pendN > 0) CancelPendings(g_ch.flatten);
      if(openN > 0) CloseAllLegs(g_ch.flatten);
      return;
   }

   //--- 2) pendentes: invalidacao da tese
   string whyH = "";
   if(pendN > 0 && g_ch.setupDone)
   {
      if(openN == 0)                                   CancelPendings("NO_OPEN_LEGS", true);   // so a escada a favor; recuos seguem ate a validade
      if(HtfAdverse(g_ch.dir, whyH))                   CancelPendings("HTF_SHOCK");
      else if(g_an.ready && g_an.trend != g_ch.dir)    CancelPendings("TREND_FLIP");
      else if(!InSession())                            CancelPendings("SESSION_CLOSE");
      if(InpUsePendingTTL)                             CancelStale(InpPendingTTLSec);
   }

   //--- 2b) entradas de recuo conforme o preco estica a favor
   if(openN > 0 && InpUsePullbackLimits && g_ch.setupDone) ProgramPullbacks();

   //--- 3) saida escalonada
   if(openN > 0 && InpUseProfitLock) ManageTrail();
}

//==================================================================
// DIA
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

//--- base do dia (variavel global do terminal): o que ja foi realizado hoje e NAO deve contar. So vale para o dia em que foi gravada.
string DayBaseKey() { return "CS_" + IntegerToString((long)InpMagic) + "_dayBase"; }
double DayBase(const datetime today)
{
   string k = DayBaseKey();
   if(GlobalVariableCheck(k) && GlobalVariableCheck(k + "_d") && (datetime)(long)GlobalVariableGet(k + "_d") == today) return GlobalVariableGet(k);
   return 0;
}
void SetDayBase(const datetime today, const double v)
{
   string k = DayBaseKey();
   GlobalVariableSet(k, v);
   GlobalVariableSet(k + "_d", (double)today);
}

void NewDayCheck()
{
   datetime today = (datetime)(TimeCurrent() / 86400 * 86400);
   if(today == g_dayStart) return;
   bool first = (g_dayStart == 0);
   g_dayStart = today;
   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_dayRealized = first ? SumDealsSince(today) - DayBase(today) : 0;
   g_dayChains = 0; g_dayWinChains = 0;
   g_haltDay = false; g_haltReason = ""; g_targetHit = false;
   if(first && InpUseDailyLossStop && g_dayRealized <= -InpDailyLossMoney)
   { g_haltDay = true; g_haltReason = StringFormat("perda diaria %.2f (recuperada do historico)", g_dayRealized); }
   if(!first) LogEvent("DAY_RESET", "INFO", "PASS", "DAY_RESET", StringFormat("novo dia: equity %.2f", g_dayStartEquity));
}

//--- reinicio com posicoes abertas: reconstroi a corrente pelos comentarios (CS<id>_<leg>) e passa a gerencia-la
void AdoptOrphans()
{
   if(g_ch.active) return;
   ulong bestId = 0; int mine = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != g_sym || (ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      mine++;
      ulong cid; int idx;
      if(ParseComment(PositionGetString(POSITION_COMMENT), cid, idx) && cid > bestId) bestId = cid;
   }
   if(mine == 0)
   {
      if(CountPendings() > 0) CancelPendings("ORPHAN_PENDING");      // sem posicao nao ha o que adotar
      bool was0 = g_orphan; g_orphan = false;
      if(was0) LogEvent("INFO", "INFO", "PASS", "ORPHAN_CLEARED", "sem posicoes orfas");
      return;
   }
   if(bestId == 0)
   {
      bool was1 = g_orphan; g_orphan = true;
      if(!was1) LogEvent("WARNING", "WARN", "BLOCK", "ORPHAN", StringFormat("%d posicoes sem comentario do EA: nao da para reconstruir a corrente", mine));
      return;
   }

   ResetChain();
   g_ch.id = bestId;
   int dir = 0, maxIdx = 0, adopted = 0, unmatched = 0, firstIdx = MAXL;
   double e0 = 0, lot = 0, firstOpen = 0;
   datetime t0 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != g_sym || (ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      ulong cid; int idx;
      if(!ParseComment(PositionGetString(POSITION_COMMENT), cid, idx) || cid != bestId) { unmatched++; continue; }
      adopted++;
      dir = ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
      lot = PositionGetDouble(POSITION_VOLUME);
      double op = PositionGetDouble(POSITION_PRICE_OPEN);
      datetime tm = (datetime)PositionGetInteger(POSITION_TIME);
      if(t0 == 0 || tm < t0) t0 = tm;
      if(idx < PB0 && idx > maxIdx) maxIdx = idx;
      if(idx == 0) e0 = op;
      if(idx < firstIdx) { firstIdx = idx; firstOpen = op; }
   }
   for(int k = OrdersTotal() - 1; k >= 0; k--)
   {
      ulong t = OrderGetTicket(k);
      if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != g_sym || (ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic) continue;
      ulong cid; int idx;
      if(ParseComment(OrderGetString(ORDER_COMMENT), cid, idx) && cid == bestId && idx < PB0 && idx > maxIdx) maxIdx = idx;
   }
   double S = CeilTick(InpStepPoints * g_point);
   if(e0 == 0) e0 = firstOpen - dir * firstIdx * S;
   g_ch.dir = dir; g_ch.n = maxIdx + 1; g_ch.t0 = t0; g_ch.tLast = TimeCurrent();
   g_ch.e0 = e0; g_ch.step = S; g_ch.lot = lot;
   g_ch.active = true; g_ch.setupDone = true;
   g_ch.extreme = (dir > 0) ? g_tick.bid : g_tick.ask; g_ch.pbRef = g_ch.extreme;
   if(bestId > g_chainCounter) g_chainCounter = bestId;
   g_orphan = (unmatched > 0);
   LogEvent("WARNING", "WARN", "PASS", "CHAIN_ADOPTED",
            StringFormat("corrente %I64u reconstruida: %s, %d posicoes, %d fora da corrente. Limites de perda valem; travas de lucro recomecam do zero", bestId, DirStr(dir), adopted, unmatched));
}

void ScanOrphans() { AdoptOrphans(); }

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
   else if(g_state == "PAUSA" || g_state == "BLOQUEADO" || g_state == "FORA SESSAO") sc = LZ_WARN;
   else if(g_state == "AGUARDANDO") sc = LZ_ACCENT;

   double bid = g_tick.bid, ask = g_tick.ask;
   double sp = (g_point > 0 && ask > 0) ? (ask - bid) / g_point : 0;
   double dpnl = DailyPnl();

   g_panel.Begin();
   g_panel.Header("LZ TRADING  //  CHAIN SCALPER " + EA_VERSION,
                  StringFormat("%s %s  spread %.0f pt  dia %s %+.2f", g_sym, EnumToString(g_tf), sp, g_ccy, dpnl), g_state, sc);
   if(g_panel.Expanded())
   {
      if(g_state == "CORRENTE")      g_panel.Strip("CORRENTE", StringFormat("%s #%I64u  score %d  n=%d", DirStr(g_ch.dir), g_ch.id, g_ch.score, g_ch.n), LZ_INFO);
      else if(g_state == "ARMADO")   g_panel.Strip("ARMADO", "tendencia ok, aguardando rompimento", LZ_PROFIT);
      else if(g_block != "")         g_panel.Strip("BLOQUEIO", g_block, (g_state == "PARADO") ? LZ_LOSS : LZ_WARN);
      else                           g_panel.Strip(g_state, "-", sc);

      g_panel.Section("ANALISE (barras fechadas)");
      string tr = (g_an.ready && g_an.trend != 0) ? (g_an.trend > 0 ? "ALTA" : "BAIXA") : "SEM TENDENCIA";
      color tc = (!g_an.ready || g_an.trend == 0) ? LZ_MUTED : (g_an.trend > 0 ? LZ_PROFIT : LZ_LOSS);
      g_panel.KV2("TENDENCIA", tr, tc, "SCORE", g_an.ready ? StringFormat("%d/%d", g_an.score, SC_MAX) : "-", LZ_TEXT);
      g_panel.KV2("ATR", g_an.ready ? StringFormat("%.2f (x%.2f)", g_an.atr, g_an.expn) : "-", LZ_TEXT,
                  "EFIC.", g_an.ready ? StringFormat("%.2f", g_an.er) : "-", LZ_TEXT);
      if(g_an.ready)
      {
         double lvl = g_an.trend > 0 ? g_an.hh : g_an.ll;
         if(g_an.trend != 0) g_panel.KV("NIVEL ROMP.", StringFormat("%s", P(lvl)), LZ_ACCENT);
      }

      g_panel.Section("OUTROS TFs (so contexto)");
      g_panel.KV2("M15", StringFormat("%+.1fx", g_htfM15), (MathAbs(g_htfM15) >= InpHtfShockMult) ? LZ_WARN : LZ_MUTED,
                  "H1", StringFormat("%+.1fx", g_htfH1), (MathAbs(g_htfH1) >= InpHtfShockMult) ? LZ_WARN : LZ_MUTED);

      g_panel.Section("CORRENTE");
      if(g_ch.active)
      {
         g_panel.ChipBegin();
         for(int i = 0; i < g_ch.n && i < MAXL; i++)
         {
            string t = StringFormat("L%d", i + 1);
            color c = LZ_LINE;
            if(g_ch.leg[i].open)             { c = LZ_PROFIT; t += " ABERTA"; }
            else if(g_ch.leg[i].closeDone)   { c = LZ_MUTED;  t += " FECHADA"; }
            else if(g_ch.leg[i].cancelled)   { c = LZ_WARN;   t += " CANC"; }
            else if(g_ch.leg[i].placed)      { c = LZ_INFO;   t += " STOP"; }
            g_panel.ChipFlow(t, c);
         }
         g_panel.ChipEnd();
         int pbPend = 0, pbOpen = 0;
         for(int i = PB0; i < MAXL; i++)
         {
            if(g_ch.leg[i].open) pbOpen++;
            else if(g_ch.leg[i].placed && !g_ch.leg[i].filled && !g_ch.leg[i].cancelled) pbPend++;
         }
         if(InpUsePullbackLimits)
            g_panel.KV("RECUO (limit)", StringFormat("%d pendentes / %d abertas  extremo %s", pbPend, pbOpen, P(g_ch.extreme)), LZ_TEXT);
         double flt = 0; int cnt; double vv; OpenStats(cnt, vv, flt);
         g_panel.KV2("DEGRAU", StringFormat("%d pts", InpStepPoints), LZ_TEXT, "SL INICIAL", InpUseStopLoss ? StringFormat("%d pts", InpStopLossPoints) : "OFF", LZ_TEXT);
         g_panel.KV2("LOTE/POS", StringFormat("%.2f", g_ch.lot), LZ_TEXT, "PERDA MAX CORR.", InpUseChainLossStop ? StringFormat("%s %.2f", g_ccy, g_ch.active ? ChainLossLimit() : InpChainLossMoney) : "OFF", LZ_TEXT);
         g_panel.KV2("FLUTUANTE", StringFormat("%s %+.2f", g_ccy, flt), flt >= 0 ? LZ_PROFIT : LZ_LOSS,
                     "REALIZADO", StringFormat("%+.2f", g_ch.net), g_ch.net >= 0 ? LZ_PROFIT : LZ_LOSS);
         g_panel.KV("IDADE", StringFormat("%d s (stall %d s)", (int)(TimeCurrent() - g_ch.t0), (int)(TimeCurrent() - g_ch.tLast)), LZ_TEXT);
      }
      else
         g_panel.KV("CORRENTE", "nenhuma ativa", LZ_MUTED);

      g_panel.Section("RISCO");
      double lim = InpDailyLossMoney;
      if(InpUseDailyLossStop)
         g_panel.Bar("PERDA DO DIA", StringFormat("%s %+.2f / -%.2f", g_ccy, dpnl, lim), (dpnl < 0) ? MathMin(100.0, -dpnl / lim * 100.0) : 0.0,
                     (dpnl < 0) ? LZ_LOSS : LZ_PROFIT);
      else
         g_panel.KV("PERDA DO DIA", StringFormat("%s %+.2f  (limite DESLIGADO)", g_ccy, dpnl), (dpnl < 0) ? LZ_LOSS : LZ_PROFIT);
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

   //--- validacao de inputs
   string err = "";
   double lotMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), lotMax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(InpEmaFast >= InpEmaSlow) err = "EMA rapida deve ser menor que a lenta";
   else if(InpMinLegs < 2 || InpMaxLegs > PB0 || InpMinLegs > InpMaxLegs) err = StringFormat("pernas: 2 <= min <= max <= %d", PB0);
   else if(InpBreakBars < 1 || InpBreakBars > 10) err = "InpBreakBars deve estar entre 1 e 10";
   else if(InpSlopeBars < 1) err = "InpSlopeBars >= 1";
   else if(InpStepPoints <= 0) err = "InpStepPoints > 0";
   else if(InpLot < lotMin || InpLot > lotMax) err = StringFormat("InpLot fora do permitido (%.2f a %.2f)", lotMin, lotMax);
   else if(lotStep > 0 && MathAbs(InpLot / lotStep - MathRound(InpLot / lotStep)) > 1e-6) err = StringFormat("InpLot nao e multiplo do passo %.2f", lotStep);
   else if(InpUseProfitLock && (InpTrailBaseSteps <= 0 || InpTrailRankSteps < 0)) err = "trava de lucro ligada exige InpTrailBaseSteps > 0 e InpTrailRankSteps >= 0";
   else if(InpUseTP && InpTPExtraSteps < 0) err = "InpTPExtraSteps >= 0";
   else if(InpUseStopLoss && InpStopLossPoints <= 0) err = "SL ligado exige InpStopLossPoints > 0";
   else if(InpUseChainLossStop && InpChainLossMoney <= 0) err = "perda maxima da corrente ligada exige InpChainLossMoney > 0";
   else if(InpUseDailyLossStop && InpDailyLossMoney <= 0) err = "perda diaria ligada exige InpDailyLossMoney > 0";
   else if(InpUseDailyTarget && InpDailyTargetMoney <= 0) err = "meta diaria ligada exige InpDailyTargetMoney > 0";
   else if(InpUsePendingTTL && InpPendingTTLSec <= 0) err = "validade ligada exige InpPendingTTLSec > 0";
   else if(InpUseHtfShockGuard && InpHtfShockMult <= 0) err = "guarda de TFs maiores ligada exige InpHtfShockMult > 0";
   else if(InpUsePullbackLimits && (InpPullbackDistPoints <= 0 || InpPullbackAdvancePoints <= 0 || InpMaxPullbackOrders < 1 || InpMaxPullbackOrders > 8))
      err = "recuo ligado exige distancia > 0, avanco > 0 e 1 <= max de ordens <= 8";
   else if(InpUsePullbackLimits && InpUsePullbackTP && InpPullbackTpPoints <= 0) err = "TP do recuo ligado exige InpPullbackTpPoints > 0";
   else if(InpUsePullbackLimits && !InpUsePendingTTL) err = "recuo ligado exige a validade das pendentes ligada (InpUsePendingTTL), senao as ordens ficariam para sempre";
   else if(InpChainLossReadsVol && InpChainLossAtrMult <= 0) err = "piso de volatilidade ligado exige InpChainLossAtrMult > 0";
   if(err != "") { Print(EA_NAME, ": INIT_FAILED - ", err); return INIT_PARAMETERS_INCORRECT; }

   // v1.08: nenhum limite de perda e obrigatorio (decisao do operador: tudo opcional).
   // Nao bloqueia o INIT; so avisa, porque sem limite a perda da corrente e ilimitada.
   if(!InpUseStopLoss && !InpUseChainLossStop && !InpUseDailyLossStop)
      Print(EA_NAME, ": AVISO - nenhum limite de perda ligado (SL, perda da corrente, perda diaria). ",
            "A perda da corrente aberta e ilimitada; so a trava de lucro e o TP atuam.");

   //--- conta hedging obrigatoria: cada degrau e uma posicao independente
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Print(EA_NAME, ": INIT_FAILED - conta NETTING: as posicoes da corrente seriam fundidas. Use conta HEDGING.");
      return INIT_FAILED;
   }
   if(!SymbolSelect(g_sym, true)) { Print(EA_NAME, ": simbolo indisponivel"); return INIT_FAILED; }
   RefreshSymbol();
   if(g_tickSize <= 0 || g_point <= 0 || g_tvLoss <= 0) { Print(EA_NAME, ": especificacao do simbolo invalida"); return INIT_FAILED; }
   string up = g_sym; StringToUpper(up);
   if(StringFind(up, "XAU") < 0 && StringFind(up, "GOLD") < 0)
      Print(EA_NAME, ": AVISO - pensado para XAUUSD; simbolo atual ", g_sym, " nao foi calibrado");

   h_emaF = iMA(g_sym, g_tf, InpEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   h_emaS = iMA(g_sym, g_tf, InpEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   h_atr  = iATR(g_sym, g_tf, InpAtrPeriod);
   h_atrB = iATR(g_sym, g_tf, InpAtrBasePeriod);
   if(h_emaF == INVALID_HANDLE || h_emaS == INVALID_HANDLE || h_atr == INVALID_HANDLE || h_atrB == INVALID_HANDLE)
   { Print(EA_NAME, ": falha ao criar indicadores"); return INIT_FAILED; }

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints((ulong)InpDeviationPts);
   g_trade.SetTypeFilling(PickFilling());
   g_trade.SetAsyncMode(false);

   MqlDateTime d; TimeToStruct(TimeLocal(), d);
   g_runId = StringFormat("%04d%02d%02d%02d%02d%02d", d.year, d.mon, d.day, d.hour, d.min, d.sec);
   g_startTime = TimeCurrent();
   for(int i = 0; i < 4; i++) { g_pathCache[i] = ""; g_periodCache[i] = ""; }

   string gv = "CS_" + IntegerToString((long)InpMagic) + "_chain";
   g_chainCounter = GlobalVariableCheck(gv) ? (ulong)GlobalVariableGet(gv) : 0;

   ZeroMemory(g_an);
   ResetChain();
   SymbolInfoTick(g_sym, g_tick);
   NewDayCheck();
   if(InpResetDailyPnl)
   {
      double before = g_dayRealized;
      SetDayBase(g_dayStart, SumDealsSince(g_dayStart));      // tudo que ja foi realizado hoje deixa de contar
      g_dayRealized = 0; g_dayChains = 0; g_dayWinChains = 0;
      g_haltDay = false; g_haltReason = ""; g_targetHit = false;
      LogEvent("RISK", "WARN", "PASS", "DAILY_RESET_MANUAL", StringFormat("resultado do dia zerado manualmente (antes %.2f). Historico e CSV nao foram alterados.", before));
      Print(EA_NAME, ": resultado do dia ZERADO (antes ", DoubleToString(before, 2), "). Volte InpResetDailyPnl para false, senao zera de novo a cada carga.");
   }
   ScanOrphans();

   if(MQLInfoInteger(MQL_TESTER) || InpShowPanel)
   {
      g_panel.Init("LZP_CS_", InpPanelX, InpPanelY, 400);
      g_panel.SetScale(InpPanelScale);
   }
   EventSetTimer(1);

   LogEvent("INIT", "INFO", "PASS", "INIT",
            StringFormat("v%s %s %s step=%dpts legs=%d-%d lot=%.2f | SL=%s(%d) TP=%s lock=%s chainLoss=%s(%.1f) dailyLoss=%s(%.1f) ttl=%s(%d) target=%s sess=%s(%d-%dGMT) htf=%s(%.1f)",
                         EA_VERSION, g_sym, EnumToString(g_tf), InpStepPoints, InpMinLegs, InpMaxLegs, InpLot,
                         B(InpUseStopLoss), InpStopLossPoints, B(InpUseTP), B(InpUseProfitLock), B(InpUseChainLossStop), InpChainLossMoney,
                         B(InpUseDailyLossStop), InpDailyLossMoney, B(InpUsePendingTTL), InpPendingTTLSec, B(InpUseDailyTarget),
                         B(InpUseSession), InpSessionStartGMT, InpSessionEndGMT, B(InpUseHtfShockGuard), InpHtfShockMult));
   LogEvent("INIT", "INFO", "PASS", "INIT_PULLBACK",
            StringFormat("recuo=%s(dist %d pts, avanco %d pts, max %d, tp %s %d pts) perdaCorrenteVol=%s(%.1f x ATR)",
                         B(InpUsePullbackLimits), InpPullbackDistPoints, InpPullbackAdvancePoints, InpMaxPullbackOrders,
                         B(InpUsePullbackTP), InpPullbackTpPoints, B(InpChainLossReadsVol), InpChainLossAtrMult));
   if(InpStepPoints * g_point < SymbolInfoInteger(g_sym, SYMBOL_SPREAD) * g_point)
      Print(EA_NAME, ": AVISO - degrau de ", InpStepPoints, " pts e menor que o spread atual (", (int)SymbolInfoInteger(g_sym, SYMBOL_SPREAD), " pts): cada degrau nasce abaixo do custo.");
   PrintFormat("%s v%s pronto: %s %s magic=%I64u tick=%s stops=%d freeze=%d fill=%s",
               EA_NAME, EA_VERSION, g_sym, EnumToString(g_tf), InpMagic, P(g_tickSize),
               (int)SymbolInfoInteger(g_sym, SYMBOL_TRADE_STOPS_LEVEL), (int)SymbolInfoInteger(g_sym, SYMBOL_TRADE_FREEZE_LEVEL),
               EnumToString(PickFilling()));
   g_ready = true;
   g_state = "AGUARDANDO";
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   if(g_ready) LogEvent("DEINIT", "INFO", "PASS", "DEINIT", StringFormat("motivo %d; corrente ativa=%s", reason, B(g_ch.active)));
   if(g_ch.active)
      Print(EA_NAME, ": ATENCAO - corrente ", g_ch.id, " ativa no DEINIT; sem o EA nao ha gerenciamento. Ao recarregar, o EA assume as posicoes pelos comentarios.");
   int hs[4];
   hs[0] = h_emaF; hs[1] = h_emaS; hs[2] = h_atr; hs[3] = h_atrB;
   for(int i = 0; i < 4; i++) if(hs[i] != INVALID_HANDLE) IndicatorRelease(hs[i]);
   g_panel.Destroy();
}

void OnTick()
{
   if(!g_ready) return;
   if(!SymbolInfoTick(g_sym, g_tick)) return;
   NewDayCheck();

   datetime bt = iTime(g_sym, g_tf, 0);
   if(bt != g_lastBar)
   {
      g_lastBar = bt;
      RefreshSymbol();
      UpdateAnalysis();
   }

   UpdateHtf();

   //--- protecao e gerenciamento nunca dependem de sinal novo
   if(g_ch.active)
   {
      SyncChain();
      if(g_ch.active)
      {
         if(g_ch.setupDone && g_ch.closed >= g_ch.filled && CountLegsOpen() == 0 && CountPendings() == 0)
            FinalizeChain();
         else
            ManageChain();
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
   UpdateHtf();
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
      LogEvent("HEARTBEAT", "INFO", "PASS", "HEARTBEAT", StringFormat("estado %s bloqueio [%s]", g_state, g_block));
   }
   DrawPanel();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(g_panel.OnEvent(id, sparam)) DrawPanel();
}
//+------------------------------------------------------------------+
