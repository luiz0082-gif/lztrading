//+------------------------------------------------------------------+
//|                         FluxMatrix_PRO.mq5                        |
//|      Liquidity + Candle Flow + Immediate Grid Recovery EA        |
//|                                                                  |
//|  Produto user-facing: FluxMatrix PRO                             |
//|  Baseline funcional preservada; alteracoes limitadas a identidade|
//|  painel, telemetria, TP/trailing, persistencia e janela          |
//|  operacional, conforme especificacao corretiva aprovada.         |
//|                                                                  |
//|  Build tecnico interno: FMX-20261009-PROT (v2.11)                       |
//|  v2.11: protecoes monetarias OPCIONAIS (todas OFF), diagnostico de      |
//|  setup religado, telemetria filtrada por magic, fallback TP money ativo.|
//|  Schema de telemetria/state: 3                                  |
//+------------------------------------------------------------------+
#property copyright "ZanonTrader Quant Engineering"
#property version   "2.11"

#include <Trade/Trade.mqh>

CTrade trade;

#define FMX_PRODUCT_NAME       "FluxMatrix PRO"
#define FMX_BUILD_ID           "FMX-20261009-PROT"
#define FMX_SCHEMA_VERSION     3
#define FMX_TELEMETRY_FOLDER   "FluxMatrix_PRO"
#define FMX_STATE_SUBFOLDER    "FluxMatrix_PRO\\state"
#define FMX_TELEMETRY_FAMILIES 12

#define DAY_PNL_MAX_POSITIONS 512

enum ENUM_TREND_FILTER_MODE
  {
   TREND_EMA200_HARD = 0,
   TREND_EMA200_SOFT = 1,
   TREND_FILTER_OFF  = 2
  };

enum ENUM_RECOVERY_GRID_MODE
  {
   RECOVERY_GRID_FIXED = 0,
   RECOVERY_GRID_ATR   = 1
  };

enum ENUM_TAKE_PROFIT_UNIT
  {
   TAKE_PROFIT_POINTS = 0,
   TAKE_PROFIT_MONEY  = 1
  };

enum ENUM_RECOVERY_NEWS_GUARD_STATE
  {
   REC_NEWS_OFF         = 0,
   REC_NEWS_CLEAR       = 1,
   REC_NEWS_BLOCKED     = 2,
   REC_NEWS_UNAVAILABLE = 3,
   REC_NEWS_TESTER_BYPASS = 4
  };

enum ENUM_EA_STATE
  {
   STATE_INIT = 0,
   STATE_FLAT,
   STATE_NEWS_LOCK,
   STATE_DAILY_TARGET_LOCK,
   STATE_SINGLE_BUY,
   STATE_SINGLE_SELL,
   STATE_BASKET_BUY,
   STATE_BASKET_SELL,
   STATE_RECOVERY_ARMED_BUY,
   STATE_RECOVERY_ARMED_SELL,
   STATE_RECOVERY_BLOCKED,
   STATE_SESSION_LOCK,
   STATE_OPERATIONAL_WINDOW_LOCK,
   STATE_RECONCILIATION
  };

// v1.09 - unidade do trailing.
// PONTOS trata 100 pontos como a mesma coisa com 0.01 ou com 0.31 lote.
// DINHEIRO normaliza pelo volume aberto: e' o que voce realmente arrisca.
enum ENUM_TRAILING_UNIT
  {
   TRAILING_POINTS = 0,
   TRAILING_MONEY  = 1
  };

enum ENUM_PANEL_THEME
  {
   PANEL_THEME_PDA      = 0,   // padrao oficial (PDA XAU) - verde lima
   PANEL_THEME_GRAPHITE = 1,   // cinza / preto
   PANEL_THEME_PRICE    = 2,   // laranja / vermelho
   PANEL_THEME_CYAN     = 3,   // ciano
   PANEL_THEME_CUSTOM   = 4    // usa InpCustomAccent
  };

input group "=== IDENTIDADE / EXECUCAO ==="
input string   InpAllowedSymbol                  = "XAUUSD";       // Simbolo permitido
input bool     InpAllowBrokerSuffix              = true;           // Aceitar sufixo da corretora
input ulong    InpMagicNumber                    = 25082601;       // Ownership: _Symbol + Magic
input bool     InpAllowBuy                       = true;           // Permitir COMPRA
input bool     InpAllowSell                      = true;           // Permitir VENDA
input int      InpDeviationPoints                = 30;             // Desvio maximo na execucao
input int      InpOrderFailureCooldownSeconds    = 60;             // Pausa apos rejeicao de ordem

input group "=== SINAL / TENDENCIA / ATR ==="
input ENUM_TREND_FILTER_MODE InpTrendFilterMode  = TREND_EMA200_HARD;
input int      InpTrendEMAPeriod                 = 200;
input int      InpTrendConfirmBars               = 5;
input int      InpATRPeriod                      = 14;

input group "=== SINAL / LIQUIDEZ ==="
input int      InpSwingDepth                     = 2;
input int      InpLiquidityLookback              = 180;
input int      InpExtremeLookbackFast            = 60;
input int      InpExtremeLookbackSlow            = 120;
input double   InpEqualLiquidityATR              = 0.08;
input int      InpEqualLiquidityMinPoints        = 30;
input double   InpSweepMinATR                    = 0.03;
input double   InpSweepMaxATR                    = 0.80;
input double   InpLiquidityNearATR               = 0.10;
input double   InpMinEntryLiquidityScore         = 40.0;

input group "=== SINAL / CANDLE FLOW ==="
input int      InpFlowLookback                   = 3;
input bool     InpUseTickVolume                  = true;
input int      InpVolumeLookback                 = 20;
input double   InpVolumeFullScoreRatio           = 1.20;
input double   InpMinFlowScore                   = 60.0;
input double   InpFlowDominance                  = 10.0;
input double   InpMinCombinedScore               = 65.0;

input group "=== RECOVERY ==="
input double   InpInitialLot                     = 0.01;
input double   InpMultiplier                     = 2.0;
input int      InpMaxRecoveryLevels              = 6;
input ENUM_RECOVERY_GRID_MODE InpRecoveryGridMode= RECOVERY_GRID_ATR;
input int      InpGridDistancePoints             = 200;
input double   InpGridATRMultiplier              = 2.00;
input int      InpGridMinPoints                  = 300;
input int      InpGridMaxPoints                  = 800;

input group "=== TAKE PROFIT ==="
input bool     InpTakeProfitEnabled              = true;
input ENUM_TAKE_PROFIT_UNIT InpTakeProfitUnit    = TAKE_PROFIT_POINTS;
input int      InpInitialTakeProfitPoints        = 150;
input int      InpBasketTakeProfitPoints         = 150;
input double   InpInitialTakeProfitMoney         = 5.00;
input double   InpBasketTakeProfitMoney          = 10.00;

input group "=== TRAILING STOP ==="
input bool     InpTrailingStopEnabled            = true;
input ENUM_TRAILING_UNIT InpTrailingUnit         = TRAILING_MONEY;

input group "=== TRAILING SINGLE / PONTOS ==="
input int      InpTrailingActivationPoints       = 100;
input int      InpTrailingDistancePoints         = 80;
input int      InpTrailingStepPoints             = 20;
input int      InpTrailingMinLockPoints          = 30;

input group "=== TRAILING SINGLE / DINHEIRO ==="
input double   InpTrailingActivationMoney        = 3.00;
input double   InpTrailingDistanceMoney          = 1.50;
input double   InpTrailingStepMoney              = 0.30;
input double   InpTrailingMinLockMoney           = 0.50;

input group "=== TRAILING BASKET / PONTOS ==="
input int      InpBasketTrailingActivationPoints = 100;
input int      InpBasketTrailingDistancePoints   = 70;
input int      InpBasketTrailingStepPoints       = 20;
input int      InpBasketTrailingMinLockPoints    = 30;

input group "=== TRAILING BASKET / DINHEIRO ==="
input double   InpBasketTrailingActivationMoney  = 10.00;
input double   InpBasketTrailingDistanceMoney    = 5.00;
input double   InpBasketTrailingStepMoney        = 0.50;
input double   InpBasketTrailingMinLockMoney     = 0.50;
input int      InpTrailMinDistancePoints         = 25;             // Baseline LiquidityFlow v1.09

input group "=== MARGEM / EXECUTION SAFETY ==="
input double   InpMinMarginLevelPct              = 500.0;
input double   InpMaxBasketVolume                = 0.65;
input double   InpMaxSpreadATRPercent            = 25.0;

input group "=== PROTECOES MONETARIAS (OPCIONAIS - TODAS DESLIGADAS) ==="
input bool     InpUseBasketLossAlert             = false;          // Alerta: perda flutuante do cesto
input double   InpBasketLossAlertPct             = 3.0;            // Alerta a partir de X% do saldo
input bool     InpUseRecoveryBlockOnLoss         = false;          // Bloqueia NOVAS pernas de recovery
input double   InpRecoveryBlockLossPct           = 8.0;            // ... quando flutuante >= X% do saldo
input bool     InpUseBasketLossClosePct          = false;          // Encerra o cesto por perda (% do saldo)
input double   InpBasketLossClosePct             = 15.0;           // ... flutuante >= X% do saldo
input bool     InpUseBasketLossCloseMoney        = false;          // Encerra o cesto por perda (dinheiro)
input double   InpBasketLossCloseMoney           = 500.0;          // ... flutuante >= X (moeda da conta)
input bool     InpUseBasketMaxAgeClose           = false;          // Encerra cesto preso por tempo
input double   InpBasketMaxAgeHours              = 24.0;           // ... idade >= X horas

input group "=== JANELA OPERACIONAL ==="
input bool     InpUseTradingDays                 = false;
input bool     InpTradeMonday                    = true;
input bool     InpTradeTuesday                   = true;
input bool     InpTradeWednesday                 = true;
input bool     InpTradeThursday                  = true;
input bool     InpTradeFriday                    = true;
input bool     InpUseTradingHours                = false;
input int      InpTradingStartHour               = 6;
input int      InpTradingStartMinute             = 0;
input int      InpTradingEndHour                 = 11;
input int      InpTradingEndMinute               = 0;

input group "=== SESSAO REAL DO BROKER ==="
input bool     InpUseSessionFilter               = true;
input int      InpBlockMinutesAfterOpen          = 15;
input int      InpBlockMinutesBeforeClose        = 30;
input bool     InpForceCloseBeforeSessionEnd     = false;
input int      InpForceCloseMinutesBefore        = 5;

input group "=== META / LIMITES PRESERVADOS ==="
input double   InpDailyProfitTarget              = 150.00;

input group "=== CALENDARIO ECONOMICO NATIVO ==="
input bool     InpUseNewsFilter                  = true;
input int      InpMinutesBeforeNews              = 30;
input int      InpMinutesAfterNews               = 30;
input ENUM_CALENDAR_EVENT_IMPORTANCE InpMinNewsImportance = CALENDAR_IMPORTANCE_HIGH;

input group "=== RECOVERY NEWS GUARD ==="
input bool     InpRecoveryNewsGuardEnabled       = true;
input int      InpRecoveryNewsMinutesBefore      = 10;
input int      InpRecoveryNewsMinutesAfter       = 15;

input group "=== PAINEL LUMERA ==="
input bool     InpVerboseLogs                    = true;
input bool     InpShowPanel                      = true;
input int      InpPanelX                         = 12;
input int      InpPanelY                         = 14;
input ENUM_PANEL_THEME InpPanelTheme             = PANEL_THEME_CYAN;
input color    InpCustomAccent                   = C'0,214,255';
input bool     InpPanelStartMinimized            = false;
input int      InpExportDays                     = 7;

input group "=== TELEMETRIA ==="
input bool     InpEnableCsvTelemetry             = true;
input bool     InpCsvBarsEveryBar                = true;
input int      InpCsvLiveIntervalSec             = 10;
input int      InpTelemetryPartMaxKB             = 5120;

struct BasketState
  {
   bool               active;
   ENUM_POSITION_TYPE direction;
   int                positions;
   int                recoveryLevel;
   double             totalVolume;
   double             averagePrice;
   double             worstEntry;
   double             lastExecutedLot;
   double             basketProfit;
   double             basketFloatingLoss;
   double             maxAdverseExcursion;
   double             maxFavorableExcursion;
   datetime           basketStart;
   datetime           lastRecovery;
   ulong              basketId;
  };

struct SignalContext
  {
   datetime signalBar;
   datetime activationBar;
   int      direction;
   double   liquidityLevel;
   double   liquidityScore;
   double   buyFlowScore;
   double   sellFlowScore;
   double   combinedScore;
   double   atr;
   double   spread;
   string   liquidityType;
  };

// v1.11 - fotografia do mercado na vela fechada. Fonte unica para o
// painel e para a telemetria: sem isto os dois recalculavam separado e
// podiam divergir.
struct MarketSnapshot
  {
   bool     valid;
   datetime bar;
   double   atr,bid,ask,spreadPts,spreadAtrPct;
   double   ema,close1,distEmaPts;
   bool     trendBuy,trendSell;
   double   liqBuyScore,liqSellScore,liqBuyLevel,liqSellLevel;
   string   liqBuyType,liqSellType;
   double   flowBuy,flowSell;
   double   combBuy,combSell,combBest;
   double   volRatio;
   string   flowSide,trendLabel;
  };

struct LiquidityContext
  {
   bool   valid;
   double level;
   double score;
   string type;
  };

int       gHandleEMA = INVALID_HANDLE;
int       gHandleATR = INVALID_HANDLE;
double    gEMA[];
double    gATR[];
BasketState   gBasket;
SignalContext gLastSignal;
MarketSnapshot gSnap;
ENUM_EA_STATE gState = STATE_INIT;

datetime  gLastBarTime = 0;
datetime  gLastOrderFailureTime = 0;
datetime  gLastRecoveryBlockLogTime = 0;
datetime  gLastInconsistentLogTime = 0;
datetime  gLastTPFailLogTime = 0;
datetime  gLastNewsCheck = 0;
bool      gCachedNewsBlocked = false;
string    gCachedNewsName = "";
string    gCachedNewsCurrency = "";
datetime  gCachedNewsTime = 0;
string    gNativeCalendarPanelDetail = "";

bool      gRecoveryArmed = false;
datetime  gRecoveryArmedTime = 0;
double    gRecoveryArmedPrice = 0.0;

bool      gDailyTargetLock = false;
datetime  gCurrentDayStart = 0;
double    gDayStartBalance = 0.0;
string    gExitReasonHint = "";

bool      gPrevBasketActive = false;
int       gPrevBasketPositions = 0;
double    gLastKnownBasketTP = 0.0;

bool      gSingleDynamicTrailActive = false;
bool      gBasketDynamicTrailActive = false;

// v1.08 (B6) - guarda anti-duplicacao de ordem.
// O terminal pode nao ter registrado a posicao recem aberta quando
// RefreshBasketState() roda logo apos o envio. Sem esta guarda, worstEntry
// e recoveryLevel ficam defasados e o mesmo nivel de grid pode ser enviado
// duas vezes no tick seguinte.
int       gExpectedPositions = 0;
datetime  gOrderSentTime     = 0;

// v1.08 - cache do resultado do dia (bruto ganho / bruto perdido / liquido)
double    gDayGrossWin   = 0.0;
double    gDayGrossLoss  = 0.0;
double    gDayNet        = 0.0;
int       gDayWins       = 0;
int       gDayLosses     = 0;
datetime  gDayStatsRefresh = 0;
double    gWeekProfit  = 0.0;
double    gMonthProfit = 0.0;
double    gYearProfit  = 0.0;
int       gTradesWeek  = 0;
int       gTradesMonth = 0;
int       gTradesYear  = 0;
datetime  gPeriodRefresh = 0;

// v1.12 - diagnostico da telemetria (aparece no painel)
long      gCsvRows        = 0;
int       gCsvErrors      = 0;
int       gCsvLastError   = 0;
datetime  gCsvLastErrLog  = 0;
datetime  gCsvLastLive    = 0;
string    gCsvBtnFeedback = "";
datetime  gCsvBtnUntil    = 0;
double    gDayWorstMAE     = 0.0;   // pior excursao adversa fechada no dia

// v1.09 - controles manuais do painel (padrao PDA)
bool      gUserEntryPause        = false;

ENUM_ORDER_TYPE_FILLING gFillingMode = ORDER_FILLING_IOC;

string    PFX = "FMX_PANEL_";

string    gRunID="";
string    gConfigHash="";
long      gSequenceNumber=0;
long      gIdSequence=0;
string    gSignalID="";
string    gDecisionID="";
string    gIntentID="";
string    gRequestID="";
bool      gStartupReconciled=false;
bool      gRecoveryReconciliation=false;
bool      gWasConnected=true;
bool      gPendingRequestReconcile=false;
int       gPendingPositionsBefore=0;
datetime  gPendingRequestSince=0;
string    gPendingRequestKind="";
double    gTrailingPeakPrice=0.0;
double    gTrailingFloorPrice=0.0;
double    gTrailingLastCommittedStep=0.0;
bool      gStateLoaded=false;
double    gPrevBasketVolume=0.0;
bool      gProtAlerted=false;
bool      gProtBlockRecovery=false;
datetime  gProtLastCloseTry=0;
string    gTelFamName[12];
int       gTelFamPart[12];
bool      gStateConfigMatch=false;

// TP Money: solver economico + fallback EA-side apenas quando broker-side nao esta confirmado.
bool      gTPMoneySolverOk=false;
bool      gTPMoneyMonitorOnly=false;
int       gTPMoneyResolvedPositions=0;
double    gResolvedTPMoneyTarget=0.0;
double    gResolvedTPMoneyProjected=0.0;
double    gResolvedTPMoneyDifference=0.0;
datetime  gLastTPMoneySolverAttempt=0;
datetime  gLastTPMoneySolverFailLog=0;

// Recovery News Guard: fonte exclusiva = calendario economico nativo MT5.
ENUM_RECOVERY_NEWS_GUARD_STATE gRecoveryNewsState=REC_NEWS_CLEAR;
datetime  gRecoveryNewsLastCheck=0;
string    gRecoveryNewsEventName="";
string    gRecoveryNewsCurrency="";
datetime  gRecoveryNewsEventTime=0;
ulong     gRecoveryNewsEventID=0;
datetime  gRecoveryNewsWindowStart=0;
datetime  gRecoveryNewsWindowEnd=0;
bool      gRecoveryNewsNeedsReevaluation=false;
datetime  gLastRecoveryNewsBlockLog=0;
bool      gRecoveryNewsTesterBypassLogged=false;

bool      gCsvExportPending=false;
bool      gDataRefreshPending=false;
datetime  gLastPerformanceTelemetry=0;
datetime  gLastRiskTelemetry=0;


// v1.08 - estado do painel (recolhido / expandido)
bool      gPanelMinimized   = false;
bool      gPanelForceRedraw = false;
bool      gUiDegraded       = false;

// v1.08 - motor de diagnostico do painel (o que esta acontecendo / aguardando)
string    gSetupHead   = "INICIANDO";
string    gSetupDetail = "";
int       gSetupLevel  = 0;   // 0=neutro  1=aguardando  2=bloqueado  3=pronto/ativo

//--- geometria do painel (a soma dos blocos tem que bater com PANEL_H_FULL)
#define PANEL_W       470
#define PANEL_H_FULL  724
#define PANEL_H_MIN   86
#define CLOCK_Y_FULL  585
#define CLOCK_Y_MIN   60

//--- paleta do painel (preenchida por ApplyPanelTheme no OnInit)
color gcBg, gcCard, gcCardAlt, gcLine, gcTxt, gcMuted, gcUp, gcDown, gcWarn, gcAccent, gcAccentDk;
#define FONT_UI       "Segoe UI"
#define FONT_UI_B     "Segoe UI Semibold"
#define FONT_MONO     "Consolas"

//+------------------------------------------------------------------+
//| PROTOTIPOS - bloco unico, antes de qualquer definicao.            |
//| CORRECAO A1: na v1.07 LogEvent() era chamado antes de existir.    |
//+------------------------------------------------------------------+
bool     IsAllowedSymbol();
bool     IsNewBar();
bool     RefreshIndicators(int needBars=220);
void     ResetSignal(SignalContext &s);
void     ResetBasketStruct(BasketState &b);
void     RefreshBasketState();
void     HandleBasketTransition();
void     UpdateDailyState();
datetime DayStart(datetime t);
double   GetProfitFrom(datetime from,datetime to);
void     GetDayPnLBreakdown(datetime from,datetime to,double &grossWin,double &grossLoss,double &net,int &wins,int &losses);
void     RefreshDayStats(bool force=false);
void     RefreshPeriodStats(bool force=false);
double   GetTodayProfit();
double   GetMonthProfit();
double   GetYearProfit();
int      GetOwnClosedTradesCount(datetime from,datetime to);
string   GetLatestOwnExitReason();
bool     IsNewsBlocked(string &name,string &currency,datetime &when);
bool     CheckCurrencyNews(const string currency,const datetime now,string &event_name,datetime &event_time);
bool     IsSpreadAllowed(double atr,double &spreadPoints,double &spreadAtrPct);
bool     IsTrendAllowed(int direction);
void     EvaluateLiquidity(int direction,double atr,LiquidityContext &out);
bool     IsConfirmedSwingLow(int shift,int depth);
bool     IsConfirmedSwingHigh(int shift,int depth);
void     ConsiderLiquidityCandidate(int direction,double level,double baseScore,string type,double atr,LiquidityContext &best);
double   FindEqualLiquidityLevel(int direction,double atr);
double   FindExtremeLevel(int direction,int lookback);
void     CalculateFlowScores(double &buyScore,double &sellScore,bool logResult=true);
double   BodyScore(int direction,int shift);
double   CloseLocationScore(int direction,int shift);
double   WickScore(int direction,int shift);
double   PersistenceScore(int direction,int lookback);
double   MicrostructureScore(int direction);
double   VolumeScore();
bool     BuildInitialSignal(SignalContext &sig);
bool     CanOpenNewBasket(const SignalContext &sig,string &reason);
bool     CanAttemptRecovery(int direction,double atr,string &reason);
bool     SendInitialOrder(const SignalContext &sig);
bool     SendRecoveryOrder(int direction,double atr);
bool     PreflightOrder(ENUM_ORDER_TYPE type,double volume,double price,string &reason,double &projectedMarginLevel);
bool     TradeRetcodeSuccess(uint retcode);
ENUM_ORDER_TYPE_FILLING GetFillingMode();
double   NormalizeVolume(double lot);
double   NormalizePriceToTick(double price);
double   ProjectedWorstCaseVolume();
void     ManageOpenBasketTick();
void     ArmRecoveryIfDistanceReached(double atr);
double   GetRecoveryDistancePrice(double atr);
void     UpdateBasketTP();
void     UpdateStaticBasketTP();
void     ClearOwnedTakeProfits();
void     DoSinglePositionTrailing();
void     DoBasketPositionTrailing();
bool     AdjustProtectionPrices(int direction,double &sl,double &tp);
double   ApplyMinLock(int direction,double desiredSL,double reference,double point,int lockPoints);
bool     SafePositionModify(ulong ticket,double sl,double tp,string scope);
string   ProfitRunnerPanelText();
string   TakeProfitUnitToString();
double   ActiveTakeProfitMoneyTarget();
bool     ProjectOwnedProfitAtPrice(double targetPrice,double &projectedProfit,string &reason);
bool     SolveBasketTPMoney(double targetMoney,double &solvedPrice,double &projectedProfit,double &difference,string &reason);
bool     SolveSingleTPMoney(int direction,double volume,double openPrice,double targetMoney,double &solvedPrice,double &projectedProfit,double &difference,string &reason);
void     MonitorTakeProfitMoney();
ENUM_RECOVERY_NEWS_GUARD_STATE EvaluateRecoveryNewsGuard(bool forceRefresh,string &eventName,string &currency,datetime &eventTime,datetime &windowStart,datetime &windowEnd);
string   RecoveryNewsGuardStateToString(ENUM_RECOVERY_NEWS_GUARD_STATE state);
string   RecoveryNewsGuardPanelText(color &stateColor);
void     ResetRecoveryArmedForNews(string reason);
void     CloseAllBasketPositions(string reason);
void     LogEvent(string event,string extra="");
string   StateToString(ENUM_EA_STATE state);
void     UpdateState();

void     CreatePanel();
void     DeletePanel();
void     UpdatePanel();
void     UpdatePanelLiveFields();
void     PanelFastText(string name,string text);
void     PanelRect(string name,int x,int y,int w,int h,color bg,color border);
void     PanelText(string name,string text,int x,int y,int size,color clr,string font,ENUM_ANCHOR_POINT anchor);
void     PanelBar(string name,int x,int y,int w,int h,double pct,color fill,color track);
void     PanelButton(string name,string text,int x,int y,int w,int h,int size,color txtClr,color bdClr,color bgClr);
void     TogglePanelMinimized();
void     SetPanelGroupVisible(string groupPrefix,bool visible);
void     ApplyPanelTheme();
void     UpdateClock();
int      ServerLocalDeltaMinutes();
string   DeltaHoursText(int deltaMin);
string   DayRolloverLocalText(int deltaMin);
void     PanelRow(string id,string caption,string value,int x,int y,int wRight,color valueClr);
void     PanelSection(string id,string txt,int x,int y);
color    PanelPLColor(double v);
color    PanelLevelColor(int level);
void     BuildSetupDiagnosis(double bf,double sf,LiquidityContext &bl,LiquidityContext &sl);
void     RunSetupDiagnosisFromSnapshot();
bool     IsOwnTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request);
void     CheckMonetaryProtections();
void     GetActivityStatus(string &head,string &det,int &level);
string   NativeCalendarPanelState(color &stateColor);
string   PtsText(double pts);
string   MoneyText(double v);

bool     IsAwaitingOrderConfirmation(string &reason);
bool     GetSessionBounds(bool &inSession,int &minsFromOpen,int &minsToClose);
bool     IsSessionWindowAllowed(string &reason);
bool     IsOperationalWindowAllowed(string &reason);
bool     IsTradingDayEnabled(int dayOfWeek);
string   OperationalWindowText();
void     ClearCaches();

bool     ExportDealsCsv(string &outPath,int &rows);
datetime WeekStart(datetime t);
double   GetWeekProfit();
void     CaptureMarketSnapshot();

string   CsvNum(double v,int dig);
string   CsvSanitize(string t);
string   CsvErrText(int code);
string   TelemetryFile(string family);
bool     TelemetryWrite(string family,string event,string detail,double price=0.0,double volume=0.0,string extra="",
                        ulong orderTicket=0,ulong dealTicket=0,ulong positionId=0);
void     TelemetryEnsureFamilies();
void     TelemetryPerformanceSnapshot();
void     TelemetryRiskSnapshot(string reason);
string   TelemetryFamilyForEvent(string event);
string   NextCausalId(string prefix);
void     CsvBarRow(string decisao,string motivo);
void     CsvEventRow(string evento,string detalhe,double preco,double volume,string extra);
bool     CsvEventRow2(string evento,string detalhe);
void     CsvBasketRow(string reason,double realized,long durationSec,int prevPositions);

double   MoneyToPoints(double money);
double   MoneyPerPoint();

string   BuildConfigHash();
string   BuildRunID();
string   StateFileName();
bool     SaveState(string reason);
bool     LoadState();
void     ReconcileStartupState();
void     ReconcileConnectionState(string reason);
int      CountOwnedPositions();
int      CountOwnedOrders();
void     MarkPendingRequest(string kind,int positionsBefore);
void     ReconcilePendingRequest();


//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   ApplyPanelTheme();

   if(!IsAllowedSymbol())
     {
      Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=SYMBOL_NOT_ALLOWED | Symbol=",_Symbol," | Allowed=",InpAllowedSymbol);
      return INIT_FAILED;
     }

   if(_Period!=PERIOD_M1)
     {
      Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=TIMEFRAME_NOT_M1 | Period=",EnumToString((ENUM_TIMEFRAMES)_Period));
      return INIT_FAILED;
     }

   ENUM_ACCOUNT_MARGIN_MODE marginMode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(marginMode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=HEDGING_ACCOUNT_REQUIRED | MarginMode=",EnumToString(marginMode));
      return INIT_FAILED;
     }

   if(InpInitialLot<=0.0 || InpMultiplier<1.0 || InpMaxRecoveryLevels<0)
     {
      Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INVALID_RECOVERY_INPUTS");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpTakeProfitEnabled)
     {
      if(InpTakeProfitUnit==TAKE_PROFIT_POINTS &&
         (InpInitialTakeProfitPoints<=0 || InpBasketTakeProfitPoints<=0))
        {
         Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INVALID_TAKE_PROFIT_POINTS");
         return INIT_PARAMETERS_INCORRECT;
        }
      if(InpTakeProfitUnit==TAKE_PROFIT_MONEY &&
         (InpInitialTakeProfitMoney<=0.0 || InpBasketTakeProfitMoney<=0.0))
        {
         Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INVALID_TAKE_PROFIT_MONEY");
         return INIT_PARAMETERS_INCORRECT;
        }
     }

   if(InpTrailingStopEnabled)
     {
      if(InpTrailingUnit==TRAILING_POINTS)
        {
         if(InpTrailingActivationPoints<=0 || InpTrailingDistancePoints<=0 || InpTrailingStepPoints<=0 ||
            InpTrailingMinLockPoints<0 || InpBasketTrailingActivationPoints<=0 ||
            InpBasketTrailingDistancePoints<=0 || InpBasketTrailingStepPoints<=0 ||
            InpBasketTrailingMinLockPoints<0)
           {
            Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INVALID_TRAILING_POINTS");
            return INIT_PARAMETERS_INCORRECT;
           }
        }
      else
        {
         if(InpTrailMinDistancePoints<0 || InpTrailingActivationMoney<=0.0 || InpTrailingDistanceMoney<=0.0 || InpTrailingStepMoney<=0.0 ||
            InpTrailingMinLockMoney<0.0 || InpBasketTrailingActivationMoney<=0.0 ||
            InpBasketTrailingDistanceMoney<=0.0 || InpBasketTrailingStepMoney<=0.0 ||
            InpBasketTrailingMinLockMoney<0.0)
           {
            Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INVALID_TRAILING_MONEY");
            return INIT_PARAMETERS_INCORRECT;
           }
        }
     }

   if(InpUseTradingHours &&
      (InpTradingStartHour<0 || InpTradingStartHour>23 ||
       InpTradingEndHour<0 || InpTradingEndHour>23 ||
       InpTradingStartMinute<0 || InpTradingStartMinute>59 ||
       InpTradingEndMinute<0 || InpTradingEndMinute>59))
     {
      Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INVALID_TRADING_HOURS");
      return INIT_PARAMETERS_INCORRECT;
     }

   if((InpUseBasketLossAlert && InpBasketLossAlertPct<=0.0) ||
      (InpUseRecoveryBlockOnLoss && InpRecoveryBlockLossPct<=0.0) ||
      (InpUseBasketLossClosePct && InpBasketLossClosePct<=0.0) ||
      (InpUseBasketLossCloseMoney && InpBasketLossCloseMoney<=0.0) ||
      (InpUseBasketMaxAgeClose && InpBasketMaxAgeHours<=0.0))
     {
      Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INVALID_PROTECTION_VALUES");
      return INIT_PARAMETERS_INCORRECT;
     }

   gFillingMode=GetFillingMode();
   if(InpTakeProfitUnit!=TAKE_PROFIT_POINTS && InpTakeProfitUnit!=TAKE_PROFIT_MONEY)
     { Print(FMX_PRODUCT_NAME," | INIT_FAILED | Invalid TakeProfitUnit"); return INIT_PARAMETERS_INCORRECT; }
   if(InpRecoveryNewsGuardEnabled &&
      (InpRecoveryNewsMinutesBefore<0 || InpRecoveryNewsMinutesAfter<0))
     { Print(FMX_PRODUCT_NAME," | INIT_FAILED | Invalid Recovery News window"); return INIT_PARAMETERS_INCORRECT; }

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpDeviationPoints);
   trade.SetTypeFilling(gFillingMode);
   trade.SetAsyncMode(false);

   gHandleEMA=iMA(_Symbol,PERIOD_M1,InpTrendEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   gHandleATR=iATR(_Symbol,PERIOD_M1,InpATRPeriod);
   if(gHandleEMA==INVALID_HANDLE || gHandleATR==INVALID_HANDLE)
     {
      Print(FMX_PRODUCT_NAME," | EVENT=INIT_FAILED | Reason=INDICATOR_HANDLE_FAILED | Error=",GetLastError());
      return INIT_FAILED;
     }

   ArraySetAsSeries(gEMA,true);
   ArraySetAsSeries(gATR,true);
   ResetBasketStruct(gBasket);
   ResetSignal(gLastSignal);

   FolderCreate(FMX_TELEMETRY_FOLDER);
   FolderCreate(FMX_STATE_SUBFOLDER);

   gConfigHash=BuildConfigHash();
   gRunID=BuildRunID();
   gSequenceNumber=0;
   gIdSequence=0;
   gSignalID="";
   gDecisionID="";
   gIntentID="";
   gRequestID="";
   gStartupReconciled=false;
   gRecoveryReconciliation=false;
   gWasConnected=(bool)TerminalInfoInteger(TERMINAL_CONNECTED);

   gCurrentDayStart=DayStart((TimeTradeServer()>0?TimeTradeServer():TimeCurrent()));
   RefreshDayStats(true);
   RefreshPeriodStats(true);
   double today=gDayNet;
   gDayStartBalance=AccountInfoDouble(ACCOUNT_BALANCE)-today;
   if(gDayStartBalance<=0.0) gDayStartBalance=AccountInfoDouble(ACCOUNT_BALANCE);

   RefreshIndicators();
   LoadState();
   ReconcileStartupState();
   gPrevBasketActive=gBasket.active;
   gPrevBasketPositions=gBasket.positions;

   if(InpUseNewsFilter && (bool)MQLInfoInteger(MQL_TESTER))
      LogEvent("NEWS_FILTER_TESTER_DISABLED","EntryCalendarAuthority=false | LiquidityFlowParity=true");

   EventSetTimer(1);

   gPanelMinimized=InpPanelStartMinimized;
   if(InpShowPanel) CreatePanel();

   gState=STATE_INIT;
   UpdateState();

   TelemetryEnsureFamilies();
   TelemetryWrite("RUN_CONFIG","RUN_STARTED",
                  "ProductName="+FMX_PRODUCT_NAME+
                  " | BuildID="+FMX_BUILD_ID+
                  " | ConfigHash="+gConfigHash+
                  " | TradingWindow="+OperationalWindowText()+
                  " | TakeProfit="+(InpTakeProfitEnabled?TakeProfitUnitToString():"OFF")+
                  " | Trailing="+(InpTrailingStopEnabled?(InpTrailingUnit==TRAILING_MONEY?"MONEY":"POINTS"):"OFF")+
                  " | TrailMinDistancePoints="+IntegerToString(InpTrailMinDistancePoints)+
                  " | RecoveryNewsGuard="+(InpRecoveryNewsGuardEnabled?"ON":"OFF")+
                  " | RecoveryNewsBefore="+IntegerToString(InpRecoveryNewsMinutesBefore)+
                  " | RecoveryNewsAfter="+IntegerToString(InpRecoveryNewsMinutesAfter));

   TelemetryWrite("RUN_CONFIG","RUN_INPUTS",
                  "InitialLot="+DoubleToString(InpInitialLot,3)+
                  " | Multiplier="+DoubleToString(InpMultiplier,3)+
                  " | MaxRecoveryLevels="+IntegerToString(InpMaxRecoveryLevels)+
                  " | GridMode="+(InpRecoveryGridMode==RECOVERY_GRID_ATR?"ATR":"FIXO")+
                  " | GridDistPts="+IntegerToString(InpGridDistancePoints)+
                  " | GridATRMult="+DoubleToString(InpGridATRMultiplier,2)+
                  " | GridMin="+IntegerToString(InpGridMinPoints)+
                  " | GridMax="+IntegerToString(InpGridMaxPoints)+
                  " | TPUnit="+TakeProfitUnitToString()+
                  " | TPInitialMoney="+DoubleToString(InpInitialTakeProfitMoney,2)+
                  " | TPBasketMoney="+DoubleToString(InpBasketTakeProfitMoney,2)+
                  " | TPInitialPts="+IntegerToString(InpInitialTakeProfitPoints)+
                  " | TPBasketPts="+IntegerToString(InpBasketTakeProfitPoints)+
                  " | TrailAct$="+DoubleToString(InpTrailingActivationMoney,2)+
                  " | TrailDist$="+DoubleToString(InpTrailingDistanceMoney,2)+
                  " | BasketTrailAct$="+DoubleToString(InpBasketTrailingActivationMoney,2)+
                  " | BasketTrailDist$="+DoubleToString(InpBasketTrailingDistanceMoney,2)+
                  " | MinMarginPct="+DoubleToString(InpMinMarginLevelPct,0)+
                  " | MaxBasketVolume="+DoubleToString(InpMaxBasketVolume,2)+
                  " | MaxSpreadATRPct="+DoubleToString(InpMaxSpreadATRPercent,1)+
                  " | DailyTarget="+DoubleToString(InpDailyProfitTarget,2)+
                  " | MinLiq="+DoubleToString(InpMinEntryLiquidityScore,0)+
                  " | MinFlow="+DoubleToString(InpMinFlowScore,0)+
                  " | FlowDom="+DoubleToString(InpFlowDominance,0)+
                  " | MinCombined="+DoubleToString(InpMinCombinedScore,0)+
                  " | TrendConfirmBars="+IntegerToString(InpTrendConfirmBars)+
                  " | ProtAlert="+(InpUseBasketLossAlert?DoubleToString(InpBasketLossAlertPct,1)+"%":"OFF")+
                  " | ProtRecoveryBlock="+(InpUseRecoveryBlockOnLoss?DoubleToString(InpRecoveryBlockLossPct,1)+"%":"OFF")+
                  " | ProtClosePct="+(InpUseBasketLossClosePct?DoubleToString(InpBasketLossClosePct,1)+"%":"OFF")+
                  " | ProtCloseMoney="+(InpUseBasketLossCloseMoney?DoubleToString(InpBasketLossCloseMoney,2):"OFF")+
                  " | ProtMaxAge="+(InpUseBasketMaxAgeClose?DoubleToString(InpBasketMaxAgeHours,1)+"h":"OFF"));

   LogEvent("CONFIG",
            "BuildID="+FMX_BUILD_ID+
            " | ConfigHash="+gConfigHash+
            " | TrendMode="+EnumToString(InpTrendFilterMode)+
            " | TakeProfitEnabled="+(InpTakeProfitEnabled?"true":"false")+
            " | TakeProfitUnit="+TakeProfitUnitToString()+
            " | InitialTP="+(InpTakeProfitUnit==TAKE_PROFIT_MONEY ? DoubleToString(InpInitialTakeProfitMoney,2)+"$" : IntegerToString(InpInitialTakeProfitPoints)+"pts")+
            " | BasketTP="+(InpTakeProfitUnit==TAKE_PROFIT_MONEY ? DoubleToString(InpBasketTakeProfitMoney,2)+"$" : IntegerToString(InpBasketTakeProfitPoints)+"pts")+
            " | TrailingEnabled="+(InpTrailingStopEnabled?"true":"false")+
            " | TrailingUnit="+(InpTrailingUnit==TRAILING_MONEY?"MONEY":"POINTS")+
            " | TrailMinDistancePoints="+IntegerToString(InpTrailMinDistancePoints)+
            " | RecoveryMode=GRID_IMMEDIATE"+
            " | FillingMode="+EnumToString(gFillingMode)+
            " | MaxSpreadATRPercent="+DoubleToString(InpMaxSpreadATRPercent,1)+
            " | SessionFilter="+(InpUseSessionFilter?"true":"false")+
            " | OperationalWindow="+OperationalWindowText());

   if(InpTrailingStopEnabled && InpTrailingUnit==TRAILING_POINTS &&
      (InpTrailingActivationPoints-InpTrailingDistancePoints)<InpTrailingMinLockPoints)
      LogEvent("CONFIG_WARNING",
               "Reason=SINGLE_TRAIL_GIVEBACK"+
               " | Activation="+IntegerToString(InpTrailingActivationPoints)+
               " | Distance="+IntegerToString(InpTrailingDistancePoints)+
               " | MinLock="+IntegerToString(InpTrailingMinLockPoints));

   if(InpTrailingStopEnabled && InpTrailingUnit==TRAILING_POINTS &&
      (InpBasketTrailingActivationPoints-InpBasketTrailingDistancePoints)<InpBasketTrailingMinLockPoints)
      LogEvent("CONFIG_WARNING",
               "Reason=BASKET_TRAIL_GIVEBACK"+
               " | Activation="+IntegerToString(InpBasketTrailingActivationPoints)+
               " | Distance="+IntegerToString(InpBasketTrailingDistancePoints)+
               " | MinLock="+IntegerToString(InpBasketTrailingMinLockPoints));

   if(InpMaxBasketVolume<=0.0)
      LogEvent("CONFIG_WARNING","Reason=MAX_BASKET_VOLUME_DISABLED");

   double worstVol=ProjectedWorstCaseVolume();
   double marginWorst=0.0;
   double refPrice=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   if(refPrice<=0.0) refPrice=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,NormalizeVolume(worstVol),refPrice,marginWorst))
      marginWorst=0.0;

   {
      double realVol=0.0,lot=NormalizeVolume(InpInitialLot),lastLot=lot;
      for(int k=0;k<=InpMaxRecoveryLevels;k++)
        {
         if(k>0) lot=NormalizeVolume(lot*InpMultiplier);
         if(InpMaxBasketVolume>0.0 && realVol+lot>InpMaxBasketVolume) break;
         realVol+=lot; lastLot=lot;
        }
      double tv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
      double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
      double mpp1=(ts>0.0 ? realVol*tv/ts : 0.0);
      double eq=AccountInfoDouble(ACCOUNT_EQUITY);
      string cfgWarn=(worstVol>realVol+1e-9 ? "CAP_OU_TRUNCAMENTO_REDUZ_PROJECAO" : "OK");
      LogEvent("RISK_REAL",
               "RealWorstVolume="+DoubleToString(realVol,2)+
               " | RealLastLot="+DoubleToString(lastLot,2)+
               " | LossPer1USD="+DoubleToString(mpp1,2)+
               " | LossPer25USD="+DoubleToString(mpp1*25.0,2)+
               " | LossPer100USD="+DoubleToString(mpp1*100.0,2)+
               " | PctEquityPer100USD="+DoubleToString((eq>0.0 ? mpp1*100.0/eq*100.0 : 0.0),1)+
               " | Note="+cfgWarn);
      TelemetryWrite("RISK_STATE","RISK_REAL","RealWorstVolume="+DoubleToString(realVol,2)+
                     " | LossPer1USD="+DoubleToString(mpp1,2)+" | LossPer100USD="+DoubleToString(mpp1*100.0,2)+" | Note="+cfgWarn);
      if(InpMaxBasketVolume>0.0 && worstVol>InpMaxBasketVolume)
         LogEvent("CONFIG_WARNING","Reason=MAX_RECOVERY_LEVELS_EXCEED_MAX_BASKET_VOLUME | Projected="+DoubleToString(worstVol,2)+
                  " | Cap="+DoubleToString(InpMaxBasketVolume,2)+" | EffectiveVolume="+DoubleToString(realVol,2));
   }
   LogEvent("RISK_PROJECTION",
            "MaxRecoveryLevels="+IntegerToString(InpMaxRecoveryLevels)+
            " | LastLevelLot="+DoubleToString(InpInitialLot*MathPow(InpMultiplier,(double)InpMaxRecoveryLevels),2)+
            " | WorstCaseTotalVolume="+DoubleToString(worstVol,2)+
            " | EstimatedMarginAtWorstCase="+DoubleToString(marginWorst,2)+
            " | Equity="+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+
            " | GridMode="+(InpRecoveryGridMode==RECOVERY_GRID_ATR?"ATR":"FIXO")+
            " | GridMin="+IntegerToString(InpGridMinPoints)+
            " | GridMax="+IntegerToString(InpGridMaxPoints));

   if(InpUseSessionFilter)
     {
      bool inSession=false;
      int minsOpen=0,minsClose=0;
      bool sessionRead=GetSessionBounds(inSession,minsOpen,minsClose);
      LogEvent("BROKER_SESSION",
               "Read="+(sessionRead?"true":"false")+
               " | InSession="+(inSession?"true":"false")+
               " | MinutesFromOpen="+IntegerToString(minsOpen)+
               " | MinutesToClose="+IntegerToString(minsClose));
     }

   SaveState("INIT_COMPLETE");
   UpdatePanel();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   SaveState("BEFORE_DEINIT");
   TelemetryWrite("POSITION_MANAGEMENT","BEFORE_DEINIT",
                  "Reason="+IntegerToString(reason)+
                  " | BasketActive="+(gBasket.active?"true":"false"));
   EventKillTimer();
   if(gHandleEMA!=INVALID_HANDLE) IndicatorRelease(gHandleEMA);
   if(gHandleATR!=INVALID_HANDLE) IndicatorRelease(gHandleATR);
   DeletePanel();
   Comment("");
  }

//+------------------------------------------------------------------+
//| OnTimer - v1.08                                                   |
//| Redesenha SO os relogios. Nao chama UpdatePanel inteiro de        |
//| proposito: o painel le estado de posicoes, e disparar essa        |
//| leitura fora do fluxo de tick abriria espaco para efeito          |
//| colateral (ex.: timeout de confirmacao de ordem contado sem que   |
//| a lista de posicoes tenha sido atualizada por um tick).           |
//+------------------------------------------------------------------+
void OnTimer()
  {
   bool connected=(bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   if(!connected)
     {
      gWasConnected=false;
     }
   else if(!gWasConnected)
     {
      gWasConnected=true;
      ReconcileConnectionState("RECONNECT");
     }

   if(gPendingRequestReconcile)
      ReconcilePendingRequest();

   if(gRecoveryReconciliation && !gPendingRequestReconcile && CountOwnedOrders()==0)
      ReconcileConnectionState("RECONCILIATION_CLEAR");

   if(gDataRefreshPending)
     {
      gDataRefreshPending=false;
      RefreshIndicators();
      RefreshBasketState();
      RefreshDayStats(true);
      RefreshPeriodStats(true);
      CaptureMarketSnapshot();
      ReconcileConnectionState("USER_REFRESH");
      gCsvBtnFeedback="DADOS ATUALIZADOS";
      gCsvBtnUntil=TimeCurrent()+5;
      TelemetryWrite("MARKET_STATE","USER_REFRESH","Atualizacao staged concluida");
      gPanelForceRedraw=true;
     }

   if(gCsvExportPending)
     {
      gCsvExportPending=false;
      string path=""; int rows=0;
      bool ok=ExportDealsCsv(path,rows);
      if(ok)
        {
         gCsvBtnFeedback="CSV OK "+IntegerToString(rows);
         TelemetryWrite("DEALS_EXPORT","MANUAL_EXPORT_OK",
                        "Rows="+IntegerToString(rows)+" | File="+path);
        }
      else
        {
         gCsvBtnFeedback="CSV ERRO "+IntegerToString(gCsvLastError);
         TelemetryWrite("DEALS_EXPORT","MANUAL_EXPORT_FAILED",
                        "Error="+IntegerToString(gCsvLastError));
        }
      gCsvBtnUntil=TimeCurrent()+8;
      gPanelForceRedraw=true;
     }

   datetime now=TimeCurrent();

   if(gCsvBtnUntil>0 && now>gCsvBtnUntil)
     {
      gCsvBtnUntil=0;
      gCsvBtnFeedback="";
      gPanelForceRedraw=true;
     }

   if(InpEnableCsvTelemetry)
     {
      if(gLastPerformanceTelemetry==0 || (now-gLastPerformanceTelemetry)>=60)
        {
         gLastPerformanceTelemetry=now;
         TelemetryPerformanceSnapshot();
        }
      if(gBasket.active && (gLastRiskTelemetry==0 || (now-gLastRiskTelemetry)>=10))
        {
         gLastRiskTelemetry=now;
         TelemetryRiskSnapshot("LIVE");
        }
     }

   if(InpShowPanel)
     {
      UpdateClock();
      if(gPanelForceRedraw || gCsvBtnUntil>0)
         UpdatePanel();
      ChartRedraw(0);
     }
  }

//+------------------------------------------------------------------+
//| OnChartEvent - v1.08                                              |
//| Unico ponto de interacao do painel: o botao recolher/expandir.    |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK || !InpShowPanel) return;

   ObjectSetInteger(0,sparam,OBJPROP_STATE,false);

   if(sparam==PFX+"F_BTN_TOGGLE" || sparam==PFX+"M_BTN_TOGGLE")
     {
      TogglePanelMinimized();
      return;
     }

   if(sparam==PFX+"F_BTN_PAUSE")
     {
      if(!gUserEntryPause)
        {
         gUserEntryPause=true;
         LogEvent("USER_PAUSE_CHANGED","Paused=true");
         TelemetryWrite("POSITION_MANAGEMENT","USER_PAUSE_CHANGED","Paused=true");
         SaveState("USER_PAUSE_CHANGED");
        }
      gPanelForceRedraw=true;
      UpdatePanel();
      ChartRedraw(0);
      return;
     }

   if(sparam==PFX+"F_BTN_ON")
     {
      if(gUserEntryPause)
        {
         gUserEntryPause=false;
         LogEvent("USER_PAUSE_CHANGED","Paused=false");
         TelemetryWrite("POSITION_MANAGEMENT","USER_PAUSE_CHANGED","Paused=false");
         SaveState("USER_PAUSE_CHANGED");
        }
      gPanelForceRedraw=true;
      UpdatePanel();
      ChartRedraw(0);
      return;
     }

   if(sparam==PFX+"F_BTN_CSV")
     {
      if(!gCsvExportPending)
        {
         gCsvExportPending=true;
         gCsvBtnFeedback="EXPORTANDO...";
         gCsvBtnUntil=TimeCurrent()+30;
        }
      gPanelForceRedraw=true;
      UpdatePanel();
      ChartRedraw(0);
      return;
     }

   if(sparam==PFX+"F_BTN_REFRESH")
     {
      if(!gDataRefreshPending)
        {
         gDataRefreshPending=true;
         gCsvBtnFeedback="ATUALIZANDO...";
         gCsvBtnUntil=TimeCurrent()+30;
        }
      gPanelForceRedraw=true;
      UpdatePanel();
      ChartRedraw(0);
      return;
     }
  }

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   bool connected=(bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   if(connected && !gWasConnected)
     {
      gWasConnected=true;
      ReconcileConnectionState("RECONNECT_TICK");
     }
   else if(!connected)
     {
      gWasConnected=false;
     }

   UpdateDailyState();
   RefreshBasketState();
   ReconcilePendingRequest();
   HandleBasketTransition();
   UpdateState();

   if(gBasket.active) ManageOpenBasketTick();

   if(InpEnableCsvTelemetry && InpCsvLiveIntervalSec>0 && gBasket.active)
     {
      datetime nowT=TimeCurrent();
      if(gCsvLastLive==0 || (nowT-gCsvLastLive)>=InpCsvLiveIntervalSec)
        {
         gCsvLastLive=nowT;
         CsvBarRow("LIVE",StateToString(gState));
        }
     }

   bool newBar=IsNewBar();
   if(newBar)
     {
      if(!RefreshIndicators())
        {
         UpdatePanel();
         return;
        }

      if(InpVerboseLogs)
         LogEvent("NEW_BAR",
                  "Bar="+TimeToString(iTime(_Symbol,PERIOD_M1,1),TIME_DATE|TIME_MINUTES)+
                  " | CurrentOpenBarUsed=false | FutureDataUsed=false");

      CaptureMarketSnapshot();
      RunSetupDiagnosisFromSnapshot();
      RefreshPeriodStats();

      string csvDecisao="AGUARDA";
      string csvMotivo="";

      double atr=(ArraySize(gATR)>1 ? gATR[1] : 0.0);
      if(atr>0.0 && !gBasket.active)
        {
         SignalContext sig;
         ResetSignal(sig);
         if(BuildInitialSignal(sig))
           {
            gSignalID=NextCausalId("SIG");
            string blockReason="";
            if(CanOpenNewBasket(sig,blockReason))
              {
               gDecisionID=NextCausalId("DEC");
               csvDecisao="ENTRADA";
               csvMotivo=(sig.direction>0?"BUY":"SELL");
               LogEvent("SIGNAL_APPROVED",
                        "SignalID="+gSignalID+
                        " | DecisionID="+gDecisionID+
                        " | Direction="+(sig.direction>0?"BUY":"SELL")+
                        " | Liquidity="+sig.liquidityType+
                        " | Level="+DoubleToString(sig.liquidityLevel,_Digits)+
                        " | LiquidityScore="+DoubleToString(sig.liquidityScore,1)+
                        " | BuyFlow="+DoubleToString(sig.buyFlowScore,1)+
                        " | SellFlow="+DoubleToString(sig.sellFlowScore,1)+
                        " | Combined="+DoubleToString(sig.combinedScore,1)+
                        " | CurrentOpenBarUsed=false | FutureDataUsed=false");
               bool initialSent=SendInitialOrder(sig);
               TelemetryWrite("SIGNAL_FUNNEL","SIGNAL_APPROVED",
                              "Direction="+(sig.direction>0?"BUY":"SELL")+
                              " | Liquidity="+sig.liquidityType+
                              " | LiquidityScore="+DoubleToString(sig.liquidityScore,1)+
                              " | Combined="+DoubleToString(sig.combinedScore,1)+
                              " | OrderSendCalled=true | OrderAccepted="+(initialSent?"true":"false"));
              }
            else
              {
               gDecisionID=NextCausalId("DEC");
               csvDecisao="BLOQUEADO";
               csvMotivo=blockReason;
               TelemetryWrite("SIGNAL_FUNNEL","SIGNAL_REJECTED",
                              "Reason="+blockReason+
                              " | Direction="+(sig.direction>0?"BUY":"SELL")+
                              " | Combined="+DoubleToString(sig.combinedScore,1));
               LogEvent("SIGNAL_REJECTED",
                        "SignalID="+gSignalID+
                        " | DecisionID="+gDecisionID+
                        " | Reason="+blockReason+
                        " | Direction="+(sig.direction>0?"BUY":"SELL")+
                        " | Combined="+DoubleToString(sig.combinedScore,1));
              }
           }
         else
           {
            csvDecisao="SEM_SETUP";
            csvMotivo=gSetupHead;
            TelemetryWrite("SIGNAL_FUNNEL","NO_SETUP",gSetupHead+" | "+gSetupDetail);
           }
        }
      else if(gBasket.active)
        {
         csvDecisao="EM_GESTAO";
         csvMotivo=StateToString(gState);
        }

      CsvBarRow(csvDecisao,csvMotivo);
     }

   UpdateState();
   UpdatePanel();
  }

//+------------------------------------------------------------------+
//| v2.11 - so transacoes deste simbolo+magic. Antes gravava todos os |
//| negocios da conta (outros EAs) em EXECUTION/DEALS_EXPORT.         |
//+------------------------------------------------------------------+
bool IsOwnTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request)
  {
   if(trans.type==TRADE_TRANSACTION_REQUEST)
      return ((ulong)request.magic==InpMagicNumber && (request.symbol=="" || request.symbol==_Symbol));
   if(trans.symbol!="" && trans.symbol!=_Symbol) return false;
   if(trans.deal>0 && HistoryDealSelect(trans.deal))
      return ((ulong)HistoryDealGetInteger(trans.deal,DEAL_MAGIC)==InpMagicNumber);
   if(trans.type==TRADE_TRANSACTION_POSITION)
     {
      if(PositionSelectByTicket(trans.position))
         return ((ulong)PositionGetInteger(POSITION_MAGIC)==InpMagicNumber);
      return false;
     }
   if(trans.order>0)
     {
      if(OrderSelect(trans.order))
         return ((ulong)OrderGetInteger(ORDER_MAGIC)==InpMagicNumber);
      if(HistoryOrderSelect(trans.order))
         return ((ulong)HistoryOrderGetInteger(trans.order,ORDER_MAGIC)==InpMagicNumber);
     }
   return (trans.symbol==_Symbol);
  }

//+------------------------------------------------------------------+
//| OnTradeTransaction - evidencia broker e persistencia              |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(!IsOwnTransaction(trans,request)) return;

   string type=EnumToString(trans.type);
   string detail="Type="+type+
                 " | Order="+StringFormat("%I64u",trans.order)+
                 " | Deal="+StringFormat("%I64u",trans.deal)+
                 " | Position="+StringFormat("%I64u",trans.position)+
                 " | Price="+DoubleToString(trans.price,_Digits)+
                 " | Volume="+DoubleToString(trans.volume,2)+
                 " | ResultRetcode="+IntegerToString((int)result.retcode);

   TelemetryWrite("EXECUTION","TRADE_TRANSACTION",detail,trans.price,trans.volume,"",
                  trans.order,trans.deal,trans.position);

   if(trans.deal>0)
      TelemetryWrite("DEALS_EXPORT","DEAL_OBSERVED",detail,trans.price,trans.volume,"",
                     trans.order,trans.deal,trans.position);

   if(trans.type==TRADE_TRANSACTION_DEAL_ADD ||
      trans.type==TRADE_TRANSACTION_POSITION ||
      trans.type==TRADE_TRANSACTION_ORDER_DELETE)
     {
      RefreshBasketState();
      SaveState("TRADE_TRANSACTION");
     }
  }


//+------------------------------------------------------------------+
//| Identidade / barra                                                |
//+------------------------------------------------------------------+
bool IsAllowedSymbol()
  {
   if(_Symbol==InpAllowedSymbol) return true;
   if(InpAllowBrokerSuffix && StringFind(_Symbol,InpAllowedSymbol)==0) return true;
   return false;
  }

bool IsNewBar()
  {
   datetime t=iTime(_Symbol,PERIOD_M1,0);
   if(t<=0) return false;
   if(t!=gLastBarTime)
     {
      gLastBarTime=t;
      return true;
     }
   return false;
  }

bool RefreshIndicators(int needBars=220)
  {
   int barsNeeded=needBars;
   int trendNeeded=InpTrendConfirmBars+5;
   if(trendNeeded>barsNeeded) barsNeeded=trendNeeded;
   if(InpLiquidityLookback+10>barsNeeded) barsNeeded=InpLiquidityLookback+10;
   if(CopyBuffer(gHandleEMA,0,0,barsNeeded,gEMA)<trendNeeded) return false;
   if(CopyBuffer(gHandleATR,0,0,10,gATR)<3) return false;
   return (gATR[1]>0.0);
  }

void ResetSignal(SignalContext &s)
  {
   s.signalBar=0; s.activationBar=0; s.direction=0;
   s.liquidityLevel=0.0; s.liquidityScore=0.0;
   s.buyFlowScore=0.0; s.sellFlowScore=0.0; s.combinedScore=0.0;
   s.atr=0.0; s.spread=0.0; s.liquidityType="NONE";
  }

void ResetBasketStruct(BasketState &b)
  {
   b.active=false; b.direction=POSITION_TYPE_BUY; b.positions=0; b.recoveryLevel=0;
   b.totalVolume=0.0; b.averagePrice=0.0; b.worstEntry=0.0; b.lastExecutedLot=0.0;
   b.basketProfit=0.0; b.basketFloatingLoss=0.0; b.maxAdverseExcursion=0.0;
   b.maxFavorableExcursion=0.0; b.basketStart=0; b.lastRecovery=0; b.basketId=0;
  }

//+------------------------------------------------------------------+
//| RefreshBasketState                                                |
//| CORRECAO C1: lastExecutedLot = volume da posicao MAIS RECENTE.    |
//| CORRECAO C2: floating inclui SWAP.                                |
//| CORRECAO C3: log de direcao mista limitado por tempo.             |
//+------------------------------------------------------------------+
void RefreshBasketState()
  {
   int count=0;
   double totalVol=0.0,weighted=0.0,worst=0.0,lastLot=0.0,profit=0.0;
   ENUM_POSITION_TYPE dir=POSITION_TYPE_BUY;
   datetime firstTime=0;
   long newestMsc=-1;
   bool dirSet=false;
   bool mixed=false;

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i);
      if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;

      ENUM_POSITION_TYPE pt=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(!dirSet) { dir=pt; dirSet=true; }
      if(pt!=dir) { mixed=true; continue; }

      double vol=PositionGetDouble(POSITION_VOLUME);
      double price=PositionGetDouble(POSITION_PRICE_OPEN);
      double p=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      datetime opent=(datetime)PositionGetInteger(POSITION_TIME);
      long   openMsc=(long)PositionGetInteger(POSITION_TIME_MSC);

      count++; totalVol+=vol; weighted+=price*vol; profit+=p;
      if(firstTime==0 || opent<firstTime) firstTime=opent;

      // Pior entrada (referencia do grid).
      if(count==1) worst=price;
      else
        {
         if(dir==POSITION_TYPE_BUY && price<worst) worst=price;
         if(dir==POSITION_TYPE_SELL && price>worst) worst=price;
        }

      // Ultima executada (referencia do multiplicador).
      if(openMsc>newestMsc) { newestMsc=openMsc; lastLot=vol; }
     }

   if(mixed && (gLastInconsistentLogTime==0 || (TimeCurrent()-gLastInconsistentLogTime)>=60))
     {
      gLastInconsistentLogTime=TimeCurrent();
      LogEvent("BASKET_INCONSISTENT","Reason=MIXED_DIRECTIONS | Action=OPPOSITE_POSITIONS_IGNORED");
     }

   if(count<=0)
     {
      if(!gPrevBasketActive) ResetBasketStruct(gBasket);
      else
        {
         gBasket.active=false; gBasket.positions=0; gBasket.totalVolume=0.0;
         gBasket.basketProfit=0.0; gBasket.basketFloatingLoss=0.0;
        }
      return;
     }

   bool wasActive=gBasket.active;
   ulong oldId=gBasket.basketId;
   double oldMAE=gBasket.maxAdverseExcursion,oldMFE=gBasket.maxFavorableExcursion;
   datetime oldStart=gBasket.basketStart;

   gBasket.active=true; gBasket.direction=dir; gBasket.positions=count;
   gBasket.recoveryLevel=count-1;
   gBasket.totalVolume=totalVol; gBasket.averagePrice=(totalVol>0.0 ? weighted/totalVol : 0.0);
   gBasket.worstEntry=worst; gBasket.lastExecutedLot=lastLot;
   gBasket.basketProfit=profit; gBasket.basketFloatingLoss=(profit<0.0 ? -profit : 0.0);
   gBasket.basketStart=(oldStart>0 ? oldStart : firstTime);
   gBasket.basketId=(oldId>0 ? oldId : (ulong)TimeCurrent());

   if(!wasActive)
     {
      gBasket.maxAdverseExcursion=0.0; gBasket.maxFavorableExcursion=0.0;
      gBasket.basketStart=firstTime; gBasket.basketId=(ulong)TimeCurrent();
     }
   else
     {
      gBasket.maxAdverseExcursion=oldMAE; gBasket.maxFavorableExcursion=oldMFE;
     }

   if(gBasket.basketProfit<0.0 && -gBasket.basketProfit>gBasket.maxAdverseExcursion)
      gBasket.maxAdverseExcursion=-gBasket.basketProfit;
   if(gBasket.basketProfit>0.0 && gBasket.basketProfit>gBasket.maxFavorableExcursion)
      gBasket.maxFavorableExcursion=gBasket.basketProfit;
  }

void HandleBasketTransition()
  {
   if(!gPrevBasketActive && gBasket.active)
     {
      gSingleDynamicTrailActive=false;
      gBasketDynamicTrailActive=false;
      gProtAlerted=false; gProtBlockRecovery=false;
      LogEvent("BASKET_STARTED","BasketId="+StringFormat("%I64u",gBasket.basketId)+
               " | Direction="+(gBasket.direction==POSITION_TYPE_BUY?"BUY":"SELL")+
               " | Positions="+IntegerToString(gBasket.positions));
      SaveState("BASKET_STATE_CHANGED");
     }

   if(gPrevBasketActive && !gBasket.active)
     {
      string brokerReason=GetLatestOwnExitReason();
      string reason=(gExitReasonHint!="" ? gExitReasonHint : brokerReason);
      if(reason=="") reason=(gPrevBasketPositions>1 ? "TARGET_OR_BROKER_CLOSE" : "TARGET_OR_TRAILING");
      double realized=(gBasket.basketStart>0 ? GetProfitFrom(gBasket.basketStart,TimeCurrent()) : 0.0);
      long duration=(gBasket.basketStart>0 ? (long)(TimeCurrent()-gBasket.basketStart) : 0);
      string closeEvent=(brokerReason=="TP" ? "BASKET_CLOSED_TARGET" : "BASKET_CLOSED");
      CsvBasketRow(reason,realized,duration,gPrevBasketPositions);
      LogEvent(closeEvent,
               "Reason="+reason+
               " | PreviousPositions="+IntegerToString(gPrevBasketPositions)+
               " | Realized="+DoubleToString(realized,2)+
               " | MAE="+DoubleToString(gBasket.maxAdverseExcursion,2)+
               " | MFE="+DoubleToString(gBasket.maxFavorableExcursion,2)+
               " | DurationSec="+IntegerToString((int)duration));
      gRecoveryArmed=false; gRecoveryArmedTime=0; gRecoveryArmedPrice=0.0; gExitReasonHint="";
      gSingleDynamicTrailActive=false;
      gBasketDynamicTrailActive=false;
      gLastKnownBasketTP=0.0;
      if(gBasket.maxAdverseExcursion>gDayWorstMAE)
         gDayWorstMAE=gBasket.maxAdverseExcursion;
      gExpectedPositions=0; gOrderSentTime=0;
      ResetBasketStruct(gBasket);
      RefreshDayStats(true);   // v1.08: painel do dia atualiza no fechamento.
      RefreshPeriodStats(true);
      SaveState("BASKET_STATE_CHANGED");
     }
   gPrevBasketActive=gBasket.active;
   gPrevBasketPositions=gBasket.positions;
   if(gBasket.active) gPrevBasketVolume=gBasket.totalVolume;
  }

//+------------------------------------------------------------------+
//| Estado diario / resultado do dia                                  |
//+------------------------------------------------------------------+
datetime DayStart(datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt); dt.hour=0; dt.min=0; dt.sec=0; return StructToTime(dt);
  }

double GetProfitFrom(datetime from,datetime to)
  {
   if(!HistorySelect(from,to)) return 0.0;
   double result=0.0;
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpMagicNumber) continue;
      ENUM_DEAL_TYPE dt=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(dt!=DEAL_TYPE_BUY && dt!=DEAL_TYPE_SELL) continue;
      result+=HistoryDealGetDouble(ticket,DEAL_PROFIT);
      result+=HistoryDealGetDouble(ticket,DEAL_SWAP);
      result+=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
     }
   return result;
  }

//+------------------------------------------------------------------+
//| v1.08 - GetDayPnLBreakdown                                        |
//| Agrupa os deals por POSITION_ID e classifica cada posicao         |
//| fechada como ganho ou perda. grossWin+grossLoss == net.           |
//| Observacao honesta: uma posicao aberta ontem e fechada hoje tem   |
//| a comissao de entrada fora da janela (mesma convencao ja usada    |
//| pelo calculo de lucro diario da v1.07).                           |
//+------------------------------------------------------------------+
void GetDayPnLBreakdown(datetime from,datetime to,double &grossWin,double &grossLoss,double &net,int &wins,int &losses)
  {
   grossWin=0.0; grossLoss=0.0; net=0.0; wins=0; losses=0;
   if(!HistorySelect(from,to)) return;

   long   posIds[];
   double posNet[];
   int    n=0;

   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpMagicNumber) continue;
      ENUM_DEAL_TYPE dt=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(dt!=DEAL_TYPE_BUY && dt!=DEAL_TYPE_SELL) continue;

      double v=HistoryDealGetDouble(ticket,DEAL_PROFIT)
              +HistoryDealGetDouble(ticket,DEAL_SWAP)
              +HistoryDealGetDouble(ticket,DEAL_COMMISSION);
      net+=v;

      long pid=(long)HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
      int idx=-1;
      for(int k=0;k<n;k++)
         if(posIds[k]==pid) { idx=k; break; }

      if(idx<0)
        {
         if(n>=DAY_PNL_MAX_POSITIONS) continue;   // net continua correto
         ArrayResize(posIds,n+1);
         ArrayResize(posNet,n+1);
         posIds[n]=pid; posNet[n]=0.0; idx=n; n++;
        }
      posNet[idx]+=v;
     }

   for(int k=0;k<n;k++)
     {
      if(posNet[k]>0.0)      { grossWin+=posNet[k];  wins++;   }
      else if(posNet[k]<0.0) { grossLoss+=posNet[k]; losses++; }
     }
  }

void RefreshDayStats(bool force=false)
  {
   datetime now=TimeCurrent();
   if(!force && gDayStatsRefresh>0 && (now-gDayStatsRefresh)<5) return;
   gDayStatsRefresh=now;
   GetDayPnLBreakdown(DayStart(now),now,gDayGrossWin,gDayGrossLoss,gDayNet,gDayWins,gDayLosses);
  }

double GetTodayProfit()
  {
   RefreshDayStats();
   return gDayNet;
  }

double GetMonthProfit()
  {
   MqlDateTime dt; TimeToStruct(TimeCurrent(),dt); dt.day=1; dt.hour=0; dt.min=0; dt.sec=0;
   return GetProfitFrom(StructToTime(dt),TimeCurrent());
  }
void UpdateDailyState()
  {
   static datetime lastCheck=0;
   datetime now=TimeCurrent();
   datetime ds=DayStart(now);
   if(ds==gCurrentDayStart && lastCheck>0 && (now-lastCheck)<5) return;
   lastCheck=now;

   if(ds!=gCurrentDayStart)
     {
      gCurrentDayStart=ds;
      gDailyTargetLock=false;
      gDayWorstMAE=0.0;
      gDayStartBalance=AccountInfoDouble(ACCOUNT_BALANCE);
      RefreshDayStats(true);
      LogEvent("NEW_TRADING_DAY","DayStartBalance="+DoubleToString(gDayStartBalance,2));
     }

   RefreshDayStats(true);
   RefreshPeriodStats(true);
   double today=gDayNet;
   if(gDayStartBalance<=0.0) gDayStartBalance=AccountInfoDouble(ACCOUNT_BALANCE)-today;

   if(InpDailyProfitTarget>0.0 && today>=InpDailyProfitTarget && !gDailyTargetLock)
     {
      gDailyTargetLock=true;
      LogEvent("DAILY_TARGET_REACHED","Today="+DoubleToString(today,2));
     }
  }

string GetLatestOwnExitReason()
  {
   datetime now=TimeCurrent();
   if(!HistorySelect(now-600,now)) return "";
   for(int i=HistoryDealsTotal()-1;i>=0;i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpMagicNumber) continue;
      ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY) continue;
      ENUM_DEAL_REASON r=(ENUM_DEAL_REASON)HistoryDealGetInteger(ticket,DEAL_REASON);
      if(r==DEAL_REASON_TP) return "TP";
      if(r==DEAL_REASON_SL) return "SL_OR_TRAILING";
      if(r==DEAL_REASON_EXPERT) return "EXPERT_CLOSE";
      if(r==DEAL_REASON_CLIENT) return "CLIENT_CLOSE";
      if(r==DEAL_REASON_MOBILE) return "MOBILE_CLOSE";
      if(r==DEAL_REASON_WEB) return "WEB_CLOSE";
      return EnumToString(r);
     }
   return "";
  }

//+------------------------------------------------------------------+
//| Noticias                                                          |
//+------------------------------------------------------------------+
bool IsNewsBlocked(string &name,string &currency,datetime &when)
  {
   name=""; currency=""; when=0;
   if(!InpUseNewsFilter) return false;
   if((bool)MQLInfoInteger(MQL_TESTER)) return false;
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();

   if(gLastNewsCheck>0 && (now-gLastNewsCheck)<15)
     { name=gCachedNewsName; currency=gCachedNewsCurrency; when=gCachedNewsTime; return gCachedNewsBlocked; }

   gLastNewsCheck=now; gCachedNewsBlocked=false; gCachedNewsName=""; gCachedNewsCurrency=""; gCachedNewsTime=0;
   string currencies[3];
   currencies[0]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   currencies[1]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   currencies[2]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);

   for(int c=0;c<3;c++)
     {
      string cur=currencies[c]; if(cur=="") continue;
      bool dup=false; for(int j=0;j<c;j++) if(currencies[j]==cur) { dup=true; break; }
      if(dup) continue;
      string en=""; datetime et=0;
      if(CheckCurrencyNews(cur,now,en,et))
        {
         if(!gCachedNewsBlocked || MathAbs((double)(et-now))<MathAbs((double)(gCachedNewsTime-now)))
           { gCachedNewsBlocked=true; gCachedNewsName=en; gCachedNewsCurrency=cur; gCachedNewsTime=et; }
        }
     }
   name=gCachedNewsName; currency=gCachedNewsCurrency; when=gCachedNewsTime;
   return gCachedNewsBlocked;
  }

bool CheckCurrencyNews(const string currency,const datetime now,string &event_name,datetime &event_time)
  {
   event_name=""; event_time=0;
   if(InpMinutesBeforeNews<0 || InpMinutesAfterNews<0) return false;
   int before=InpMinutesBeforeNews*60,after=InpMinutesAfterNews*60;
   MqlCalendarValue values[];
   ResetLastError();
   int total=CalendarValueHistory(values,now-after,now+before,"",currency);
   if(total<=0) return false;
   bool found=false; double best=DBL_MAX;
   for(int i=0;i<total;i++)
     {
      MqlCalendarEvent ev; if(!CalendarEventById(values[i].event_id,ev)) continue;
      if(ev.time_mode!=CALENDAR_TIMEMODE_DATETIME) continue;
      if(ev.importance<InpMinNewsImportance) continue;
      datetime t=values[i].time;
      if(now<t-before || now>t+after) continue;
      double d=MathAbs((double)(t-now));
      if(!found || d<best) { found=true; best=d; event_name=ev.name; event_time=t; }
     }
   return found;
  }
string RecoveryNewsGuardStateToString(ENUM_RECOVERY_NEWS_GUARD_STATE state)
  {
   switch(state)
     {
      case REC_NEWS_OFF:           return "OFF";
      case REC_NEWS_CLEAR:         return "CLEAR";
      case REC_NEWS_BLOCKED:       return "BLOCKED";
      case REC_NEWS_UNAVAILABLE:   return "UNAVAILABLE";
      case REC_NEWS_TESTER_BYPASS: return "TESTER_BYPASS";
     }
   return "UNAVAILABLE";
  }
ENUM_RECOVERY_NEWS_GUARD_STATE EvaluateRecoveryNewsGuard(bool forceRefresh,string &eventName,string &currency,datetime &eventTime,datetime &windowStart,datetime &windowEnd)
  {
   eventName=""; currency=""; eventTime=0; windowStart=0; windowEnd=0;

   if(!InpRecoveryNewsGuardEnabled)
     {
      gRecoveryNewsState=REC_NEWS_OFF;
      return REC_NEWS_OFF;
     }

   if((bool)MQLInfoInteger(MQL_TESTER))
     {
      gRecoveryNewsState=REC_NEWS_TESTER_BYPASS;
      gRecoveryNewsEventName=""; gRecoveryNewsCurrency=""; gRecoveryNewsEventTime=0; gRecoveryNewsEventID=0;
      gRecoveryNewsWindowStart=0; gRecoveryNewsWindowEnd=0;
      if(!gRecoveryNewsTesterBypassLogged)
        {
         gRecoveryNewsTesterBypassLogged=true;
         LogEvent("RECOVERY_NEWS_GUARD_TESTER_BYPASS","Authority=false");
        }
      return REC_NEWS_TESTER_BYPASS;
     }

   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   if(now<=0)
     {
      gRecoveryNewsState=REC_NEWS_UNAVAILABLE;
      gRecoveryNewsEventName=""; gRecoveryNewsCurrency=""; gRecoveryNewsEventTime=0; gRecoveryNewsEventID=0;
      gRecoveryNewsWindowStart=0; gRecoveryNewsWindowEnd=0;
      return REC_NEWS_UNAVAILABLE;
     }

   if(!forceRefresh && gRecoveryNewsLastCheck>0 && (now-gRecoveryNewsLastCheck)<5)
     {
      eventName=gRecoveryNewsEventName; currency=gRecoveryNewsCurrency; eventTime=gRecoveryNewsEventTime;
      windowStart=gRecoveryNewsWindowStart; windowEnd=gRecoveryNewsWindowEnd;
      return gRecoveryNewsState;
     }

   ENUM_RECOVERY_NEWS_GUARD_STATE oldState=gRecoveryNewsState;
   string oldEventName=gRecoveryNewsEventName;
   string oldCurrency=gRecoveryNewsCurrency;
   datetime oldEventTime=gRecoveryNewsEventTime;
   ulong oldEventID=gRecoveryNewsEventID;
   datetime oldWindowStart=gRecoveryNewsWindowStart;
   datetime oldWindowEnd=gRecoveryNewsWindowEnd;

   gRecoveryNewsLastCheck=now;
   gRecoveryNewsState=REC_NEWS_CLEAR;
   gRecoveryNewsEventName=""; gRecoveryNewsCurrency=""; gRecoveryNewsEventTime=0; gRecoveryNewsEventID=0;
   gRecoveryNewsWindowStart=0; gRecoveryNewsWindowEnd=0;

   int before=(int)MathMax(0,InpRecoveryNewsMinutesBefore)*60;
   int after =(int)MathMax(0,InpRecoveryNewsMinutesAfter)*60;
   bool anyCalendarRead=false;
   bool found=false;
   double best=DBL_MAX;

   string currencies[3];
   currencies[0]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   currencies[1]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   currencies[2]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);

   for(int c=0;c<3;c++)
     {
      string cur=currencies[c]; if(cur=="") continue;
      bool dup=false; for(int j=0;j<c;j++) if(currencies[j]==cur) { dup=true; break; }
      if(dup) continue;

      MqlCalendarValue values[];
      ResetLastError();
      int total=CalendarValueHistory(values,now-after,now+before,"",cur);
      if(total>=0) anyCalendarRead=true;
      if(total<=0) continue;

      for(int i=0;i<total;i++)
        {
         MqlCalendarEvent ev;
         if(!CalendarEventById(values[i].event_id,ev)) continue;
         if(ev.time_mode!=CALENDAR_TIMEMODE_DATETIME) continue;
         if(ev.importance<InpMinNewsImportance) continue;

         datetime t=values[i].time;
         datetime ws=t-before;
         datetime we=t+after;
         if(now<ws || now>=we) continue;

         double d=MathAbs((double)(t-now));
         if(!found || d<best)
           {
            found=true; best=d;
            gRecoveryNewsEventName=ev.name;
            gRecoveryNewsCurrency=cur;
            gRecoveryNewsEventTime=t;
            gRecoveryNewsEventID=values[i].event_id;
            gRecoveryNewsWindowStart=ws;
            gRecoveryNewsWindowEnd=we;
           }
        }
     }

   if(found) gRecoveryNewsState=REC_NEWS_BLOCKED;
   else if(!anyCalendarRead) gRecoveryNewsState=REC_NEWS_UNAVAILABLE;
   else gRecoveryNewsState=REC_NEWS_CLEAR;

   eventName=gRecoveryNewsEventName; currency=gRecoveryNewsCurrency; eventTime=gRecoveryNewsEventTime;
   windowStart=gRecoveryNewsWindowStart; windowEnd=gRecoveryNewsWindowEnd;

   if((oldState==REC_NEWS_BLOCKED || oldState==REC_NEWS_UNAVAILABLE) && gRecoveryNewsState==REC_NEWS_CLEAR)
     {
      gRecoveryNewsNeedsReevaluation=true;
      string det="Previous="+RecoveryNewsGuardStateToString(oldState)+
                 " | EventID="+StringFormat("%I64u",oldEventID)+
                 " | Currency="+oldCurrency+
                 " | Event="+oldEventName+
                 " | EventTime="+(oldEventTime>0?TimeToString(oldEventTime,TIME_DATE|TIME_MINUTES):"")+
                 " | RecoveryWindowStart="+(oldWindowStart>0?TimeToString(oldWindowStart,TIME_DATE|TIME_MINUTES):"")+
                 " | RecoveryWindowEnd="+(oldWindowEnd>0?TimeToString(oldWindowEnd,TIME_DATE|TIME_MINUTES):"")+
                 " | New=CLEAR | OrderSendCalled=false";
      // Sem file I/O no caminho que pode liberar uma Recovery neste mesmo tick.
      LogEvent("RECOVERY_NEWS_WINDOW_CLEARED",det);
     }

   return gRecoveryNewsState;
  }

void ResetRecoveryArmedForNews(string reason)
  {
   gRecoveryArmed=false;
   gRecoveryArmedTime=0;
   gRecoveryArmedPrice=0.0;
   gRecoveryNewsNeedsReevaluation=true;
   if(reason!="") LogEvent(reason,"RecoveryArmed=false | OrderSendCalled=false");
  }

string RecoveryNewsGuardPanelText(color &stateColor)
  {
   // UI-only snapshot.  It does NOT call EvaluateRecoveryNewsGuard(), so the
   // panel cannot arm, clear or otherwise mutate the operational News Guard.
   if(!InpRecoveryNewsGuardEnabled)
     { stateColor=gcMuted; return "Rec News: OFF"; }

   if((bool)MQLInfoInteger(MQL_TESTER))
     { stateColor=gcMuted; return "Rec News: TESTER BYPASS"; }

   static datetime lastCheck=0;
   static ENUM_RECOVERY_NEWS_GUARD_STATE cachedState=REC_NEWS_CLEAR;
   static string cachedName="",cachedCurrency="";
   static datetime cachedTime=0,cachedStart=0,cachedEnd=0;

   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   if(now<=0)
     { stateColor=gcDown; return "Rec News: SEM DADOS"; }

   if(lastCheck==0 || (now-lastCheck)>=5)
     {
      lastCheck=now;
      cachedState=REC_NEWS_CLEAR;
      cachedName=""; cachedCurrency=""; cachedTime=0; cachedStart=0; cachedEnd=0;

      int before=(int)MathMax(0,InpRecoveryNewsMinutesBefore)*60;
      int after =(int)MathMax(0,InpRecoveryNewsMinutesAfter)*60;
      bool anyCalendarRead=false;
      bool found=false;
      double best=DBL_MAX;

      string currencies[3];
      currencies[0]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
      currencies[1]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
      currencies[2]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);

      for(int c=0;c<3;c++)
        {
         string cur=currencies[c]; if(cur=="") continue;
         bool dup=false; for(int j=0;j<c;j++) if(currencies[j]==cur) { dup=true; break; }
         if(dup) continue;

         MqlCalendarValue values[];
         ResetLastError();
         int total=CalendarValueHistory(values,now-after,now+before,"",cur);
         if(total>=0) anyCalendarRead=true;
         if(total<=0) continue;

         for(int i=0;i<total;i++)
           {
            MqlCalendarEvent ev;
            if(!CalendarEventById(values[i].event_id,ev)) continue;
            if(ev.time_mode!=CALENDAR_TIMEMODE_DATETIME) continue;
            if(ev.importance<InpMinNewsImportance) continue;

            datetime t=values[i].time;
            datetime ws=t-before;
            datetime we=t+after;
            if(now<ws || now>=we) continue;

            double d=MathAbs((double)(t-now));
            if(!found || d<best)
              {
               found=true; best=d;
               cachedName=ev.name;
               cachedCurrency=cur;
               cachedTime=t;
               cachedStart=ws;
               cachedEnd=we;
              }
           }
        }

      if(found) cachedState=REC_NEWS_BLOCKED;
      else if(!anyCalendarRead) cachedState=REC_NEWS_UNAVAILABLE;
      else cachedState=REC_NEWS_CLEAR;
     }

   if(cachedState==REC_NEWS_UNAVAILABLE)
     { stateColor=gcDown; return "Rec News: SEM DADOS"; }
   if(cachedState==REC_NEWS_BLOCKED)
     {
      stateColor=gcDown;
      if(cachedTime>now)
         return "Rec News: BLOQUEADO | "+cachedCurrency+" "+cachedName+
                " | faltam "+IntegerToString((int)MathCeil((double)(cachedTime-now)/60.0))+" min";
      return "Rec News: BLOQUEADO | "+cachedCurrency+" "+cachedName+
             " | libera em "+IntegerToString((int)MathCeil((double)(cachedEnd-now)/60.0))+" min";
     }

   stateColor=gcUp;
   return "Rec News: LIVRE";
  }


//+------------------------------------------------------------------+
//| Spread / tendencia                                                |
//+------------------------------------------------------------------+
bool IsSpreadAllowed(double atr,double &spreadPoints,double &spreadAtrPct)
  {
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK),bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(point<=0.0 || atr<=0.0 || ask<=0.0 || bid<=0.0) return false;
   double spread=ask-bid; spreadPoints=spread/point; spreadAtrPct=(spread/atr)*100.0;
   if(InpMaxSpreadATRPercent<=0.0) return true;
   return (spreadAtrPct<=InpMaxSpreadATRPercent);
  }

bool IsTrendAllowed(int direction)
  {
   if(InpTrendFilterMode==TREND_FILTER_OFF) return true;
   if(ArraySize(gEMA)<=InpTrendConfirmBars+1) return false;
   if(InpTrendFilterMode==TREND_EMA200_SOFT)
     { double c=iClose(_Symbol,PERIOD_M1,1); return (direction>0 ? c>gEMA[1] : c<gEMA[1]); }

   int n=InpTrendConfirmBars; if(n<1) n=1;
   for(int i=1;i<=n;i++)
     {
      double lo=iLow(_Symbol,PERIOD_M1,i),hi=iHigh(_Symbol,PERIOD_M1,i);
      if(lo<=0.0 || hi<=0.0 || gEMA[i]<=0.0) return false;
      if(direction>0 && lo<=gEMA[i]) return false;
      if(direction<0 && hi>=gEMA[i]) return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Motor de liquidez (inalterado na logica)                          |
//+------------------------------------------------------------------+
bool IsConfirmedSwingLow(int shift,int depth)
  {
   if(shift<=depth || depth<1) return false;
   double v=iLow(_Symbol,PERIOD_M1,shift); if(v<=0.0) return false;
   for(int d=1;d<=depth;d++)
     { if(v>=iLow(_Symbol,PERIOD_M1,shift-d)) return false; if(v>=iLow(_Symbol,PERIOD_M1,shift+d)) return false; }
   return true;
  }

bool IsConfirmedSwingHigh(int shift,int depth)
  {
   if(shift<=depth || depth<1) return false;
   double v=iHigh(_Symbol,PERIOD_M1,shift); if(v<=0.0) return false;
   for(int d=1;d<=depth;d++)
     { if(v<=iHigh(_Symbol,PERIOD_M1,shift-d)) return false; if(v<=iHigh(_Symbol,PERIOD_M1,shift+d)) return false; }
   return true;
  }

void ConsiderLiquidityCandidate(int direction,double level,double baseScore,string type,double atr,LiquidityContext &best)
  {
   if(level<=0.0 || atr<=0.0) return;
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT); if(point<=0.0) return;
   double lo=iLow(_Symbol,PERIOD_M1,1),hi=iHigh(_Symbol,PERIOD_M1,1),cl=iClose(_Symbol,PERIOD_M1,1);
   double minSweep=atr*InpSweepMinATR,maxSweep=atr*InpSweepMaxATR;
   double nearDist=MathMax(atr*InpLiquidityNearATR,InpEqualLiquidityMinPoints*point);
   double score=0.0; string evType="";

   if(direction>0)
     {
      double penetration=level-lo;
      if(lo<level && cl>level && penetration>=minSweep && penetration<=maxSweep) { score=baseScore; evType="SWEEP_"+type; }
      else if(MathAbs(lo-level)<=nearDist && cl>level) { score=MathMin(baseScore,50.0); evType="RETEST_"+type; }
      else if(MathAbs(cl-level)<=nearDist) { score=MathMin(baseScore,30.0); evType="NEAR_"+type; }
     }
   else
     {
      double penetration=hi-level;
      if(hi>level && cl<level && penetration>=minSweep && penetration<=maxSweep) { score=baseScore; evType="SWEEP_"+type; }
      else if(MathAbs(hi-level)<=nearDist && cl<level) { score=MathMin(baseScore,50.0); evType="RETEST_"+type; }
      else if(MathAbs(cl-level)<=nearDist) { score=MathMin(baseScore,30.0); evType="NEAR_"+type; }
     }

   if(score>best.score) { best.valid=(score>0.0); best.level=level; best.score=score; best.type=evType; }
  }

double FindEqualLiquidityLevel(int direction,double atr)
  {
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT); if(point<=0.0 || atr<=0.0) return 0.0;
   double tol=MathMax(InpEqualLiquidityMinPoints*point,atr*InpEqualLiquidityATR);
   double swings[]; int count=0;
   int depth=InpSwingDepth; if(depth<1) depth=1;
   int maxShift=InpLiquidityLookback; if(maxShift<depth+5) maxShift=depth+5;

   for(int i=depth+1;i<=maxShift;i++)
     {
      bool ok=(direction>0 ? IsConfirmedSwingLow(i,depth) : IsConfirmedSwingHigh(i,depth));
      if(!ok) continue;
      double v=(direction>0 ? iLow(_Symbol,PERIOD_M1,i) : iHigh(_Symbol,PERIOD_M1,i));
      ArrayResize(swings,count+1); swings[count]=v; count++; if(count>=40) break;
     }
   if(count<2) return 0.0;

   double signalPrice=(direction>0 ? iLow(_Symbol,PERIOD_M1,1) : iHigh(_Symbol,PERIOD_M1,1));
   double bestLevel=0.0,bestDist=DBL_MAX;
   for(int a=0;a<count-1;a++)
      for(int b=a+1;b<count;b++)
         if(MathAbs(swings[a]-swings[b])<=tol)
           {
            double level=(swings[a]+swings[b])*0.5;
            double d=MathAbs(signalPrice-level);
            if(d<bestDist) { bestDist=d; bestLevel=level; }
           }
   return bestLevel;
  }

double FindExtremeLevel(int direction,int lookback)
  {
   if(lookback<5) lookback=5;
   double level=0.0;
   for(int i=2;i<2+lookback;i++)
     {
      double v=(direction>0 ? iLow(_Symbol,PERIOD_M1,i) : iHigh(_Symbol,PERIOD_M1,i));
      if(v<=0.0) continue;
      if(level==0.0) level=v;
      else { if(direction>0 && v<level) level=v; if(direction<0 && v>level) level=v; }
     }
   return level;
  }

void EvaluateLiquidity(int direction,double atr,LiquidityContext &out)
  {
   out.valid=false; out.level=0.0; out.score=0.0; out.type="NONE";
   double pd=(direction>0 ? iLow(_Symbol,PERIOD_D1,1) : iHigh(_Symbol,PERIOD_D1,1));
   ConsiderLiquidityCandidate(direction,pd,90.0,(direction>0?"PDL":"PDH"),atr,out);
   double equalLevel=FindEqualLiquidityLevel(direction,atr);
   if(equalLevel>0.0) ConsiderLiquidityCandidate(direction,equalLevel,100.0,(direction>0?"EQUAL_LOW":"EQUAL_HIGH"),atr,out);

   int depth=InpSwingDepth; if(depth<1) depth=1;
   int maxShift=InpLiquidityLookback; if(maxShift<depth+5) maxShift=depth+5;
   for(int i=depth+1;i<=maxShift;i++)
     {
      bool ok=(direction>0 ? IsConfirmedSwingLow(i,depth) : IsConfirmedSwingHigh(i,depth));
      if(!ok) continue;
      double level=(direction>0 ? iLow(_Symbol,PERIOD_M1,i) : iHigh(_Symbol,PERIOD_M1,i));
      ConsiderLiquidityCandidate(direction,level,80.0,(direction>0?"SWING_LOW":"SWING_HIGH"),atr,out);
     }

   ConsiderLiquidityCandidate(direction,FindExtremeLevel(direction,InpExtremeLookbackFast),70.0,(direction>0?"EXTREME_LOW_60":"EXTREME_HIGH_60"),atr,out);
   ConsiderLiquidityCandidate(direction,FindExtremeLevel(direction,InpExtremeLookbackSlow),70.0,(direction>0?"EXTREME_LOW_120":"EXTREME_HIGH_120"),atr,out);
  }

//+------------------------------------------------------------------+
//| Candle Flow (inalterado; removido o parametro atr nao utilizado)  |
//+------------------------------------------------------------------+
double BodyScore(int direction,int shift)
  {
   double o=iOpen(_Symbol,PERIOD_M1,shift),c=iClose(_Symbol,PERIOD_M1,shift),h=iHigh(_Symbol,PERIOD_M1,shift),l=iLow(_Symbol,PERIOD_M1,shift);
   double range=h-l; if(range<=0.0) return 0.0;
   bool dirOk=(direction>0 ? c>o : c<o); if(!dirOk) return 0.0;
   double ratio=MathAbs(c-o)/range;
   if(ratio>=0.70) return 30.0;
   if(ratio>=0.55) return 25.0;
   if(ratio>=0.40) return 18.0;
   if(ratio>=0.25) return 10.0;
   return 0.0;
  }

double CloseLocationScore(int direction,int shift)
  {
   double c=iClose(_Symbol,PERIOD_M1,shift),h=iHigh(_Symbol,PERIOD_M1,shift),l=iLow(_Symbol,PERIOD_M1,shift);
   double range=h-l; if(range<=0.0) return 0.0;
   double loc=(direction>0 ? (c-l)/range : (h-c)/range);
   if(loc>=0.85) return 20.0;
   if(loc>=0.70) return 15.0;
   if(loc>=0.60) return 10.0;
   if(loc>=0.50) return 5.0;
   return 0.0;
  }

double WickScore(int direction,int shift)
  {
   double o=iOpen(_Symbol,PERIOD_M1,shift),c=iClose(_Symbol,PERIOD_M1,shift),h=iHigh(_Symbol,PERIOD_M1,shift),l=iLow(_Symbol,PERIOD_M1,shift);
   double range=h-l; if(range<=0.0) return 0.0;
   double upper=h-MathMax(o,c),lower=MathMin(o,c)-l;
   double wick=(direction>0 ? lower : upper),opposite=(direction>0 ? upper : lower),ratio=wick/range;
   if(ratio>=0.45 && wick>opposite*1.25) return 15.0;
   if(ratio>=0.30 && wick>opposite) return 12.0;
   if(ratio>=0.20) return 8.0;
   if(ratio>=0.12) return 4.0;
   return 0.0;
  }

double PersistenceScore(int direction,int lookback)
  {
   if(lookback<2) lookback=2;
   double bull=0.0,bear=0.0;
   for(int i=1;i<=lookback;i++)
     {
      double o=iOpen(_Symbol,PERIOD_M1,i),c=iClose(_Symbol,PERIOD_M1,i);
      if(c>o) bull+=(c-o); else if(c<o) bear+=(o-c);
     }
   double total=bull+bear; if(total<=0.0) return 0.0;
   double ratio=(direction>0 ? bull : bear)/total;
   if(ratio>=0.80) return 15.0;
   if(ratio>=0.68) return 12.0;
   if(ratio>=0.58) return 8.0;
   if(ratio>=0.52) return 4.0;
   return 0.0;
  }

double MicrostructureScore(int direction)
  {
   double c1=iClose(_Symbol,PERIOD_M1,1),h1=iHigh(_Symbol,PERIOD_M1,1),l1=iLow(_Symbol,PERIOD_M1,1);
   double c2=iClose(_Symbol,PERIOD_M1,2),h2=iHigh(_Symbol,PERIOD_M1,2),l2=iLow(_Symbol,PERIOD_M1,2);
   double h3=iHigh(_Symbol,PERIOD_M1,3),l3=iLow(_Symbol,PERIOD_M1,3);
   if(direction>0)
     { if(c1>h2) return 10.0; if(l1>l2 && c1>c2) return 8.0; if(l2>l3 && c1>c2) return 5.0; }
   else
     { if(c1<l2) return 10.0; if(h1<h2 && c1<c2) return 8.0; if(h2<h3 && c1<c2) return 5.0; }
   return 0.0;
  }

double VolumeScore()
  {
   if(!InpUseTickVolume) return 0.0;
   int n=InpVolumeLookback; if(n<5) n=5;
   long v1=iVolume(_Symbol,PERIOD_M1,1); if(v1<=0) return 0.0;
   double avg=0.0; int cnt=0;
   for(int i=2;i<2+n;i++) { long v=iVolume(_Symbol,PERIOD_M1,i); if(v<=0) continue; avg+=(double)v; cnt++; }
   if(cnt<=0) return 0.0;
   avg/=cnt; if(avg<=0.0) return 0.0;
   double ratio=(double)v1/avg,full=InpVolumeFullScoreRatio; if(full<=1.0) full=1.20;
   if(ratio>=full) return 10.0;
   if(ratio>=1.10) return 7.0;
   if(ratio>=1.00) return 4.0;
   return 0.0;
  }

void CalculateFlowScores(double &buyScore,double &sellScore,bool logResult=true)
  {
   int lb=InpFlowLookback; if(lb<2) lb=2;
   double vScore=VolumeScore();
   buyScore =BodyScore(1,1)+CloseLocationScore(1,1)+WickScore(1,1)+PersistenceScore(1,lb)+MicrostructureScore(1)+vScore;
   sellScore=BodyScore(-1,1)+CloseLocationScore(-1,1)+WickScore(-1,1)+PersistenceScore(-1,lb)+MicrostructureScore(-1)+vScore;
   if(buyScore>100.0)  buyScore=100.0;
   if(sellScore>100.0) sellScore=100.0;
   if(logResult && InpVerboseLogs)
     {
      string ev="FLOW_NEUTRAL";
      if(buyScore>=InpMinFlowScore && buyScore>=sellScore+InpFlowDominance) ev="FLOW_BUY";
      else if(sellScore>=InpMinFlowScore && sellScore>=buyScore+InpFlowDominance) ev="FLOW_SELL";
      LogEvent(ev,"BuyFlow="+DoubleToString(buyScore,1)+" | SellFlow="+DoubleToString(sellScore,1));
     }
  }

bool BuildInitialSignal(SignalContext &sig)
  {
   ResetSignal(sig);
   double atr=(ArraySize(gATR)>1 ? gATR[1] : 0.0); if(atr<=0.0) return false;
   double buyFlow=0.0,sellFlow=0.0; CalculateFlowScores(buyFlow,sellFlow,true);
   LiquidityContext buyLiq,sellLiq; EvaluateLiquidity(1,atr,buyLiq); EvaluateLiquidity(-1,atr,sellLiq);

   if(InpVerboseLogs && buyLiq.valid)
     {
      string ev=(StringFind(buyLiq.type,"SWEEP_")==0 ? "LIQUIDITY_SWEEP" : (StringFind(buyLiq.type,"RETEST_")==0 ? "LIQUIDITY_RETEST" : "LIQUIDITY_DETECTED"));
      LogEvent(ev,"Direction=BUY | Type="+buyLiq.type+" | Level="+DoubleToString(buyLiq.level,_Digits)+" | Score="+DoubleToString(buyLiq.score,1));
     }
   if(InpVerboseLogs && sellLiq.valid)
     {
      string ev=(StringFind(sellLiq.type,"SWEEP_")==0 ? "LIQUIDITY_SWEEP" : (StringFind(sellLiq.type,"RETEST_")==0 ? "LIQUIDITY_RETEST" : "LIQUIDITY_DETECTED"));
      LogEvent(ev,"Direction=SELL | Type="+sellLiq.type+" | Level="+DoubleToString(sellLiq.level,_Digits)+" | Score="+DoubleToString(sellLiq.score,1));
     }

   bool buyOk=InpAllowBuy && IsTrendAllowed(1) && buyLiq.valid && buyLiq.score>=InpMinEntryLiquidityScore && buyFlow>=InpMinFlowScore && buyFlow>=sellFlow+InpFlowDominance;
   bool sellOk=InpAllowSell && IsTrendAllowed(-1) && sellLiq.valid && sellLiq.score>=InpMinEntryLiquidityScore && sellFlow>=InpMinFlowScore && sellFlow>=buyFlow+InpFlowDominance;
   double buyCombined=(buyLiq.valid ? 0.40*buyLiq.score+0.60*buyFlow : 0.0);
   double sellCombined=(sellLiq.valid ? 0.40*sellLiq.score+0.60*sellFlow : 0.0);

   if(buyOk && buyCombined>=InpMinCombinedScore && (!sellOk || buyCombined>=sellCombined))
     { sig.direction=1; sig.liquidityLevel=buyLiq.level; sig.liquidityScore=buyLiq.score; sig.liquidityType=buyLiq.type; sig.combinedScore=buyCombined; }
   else if(sellOk && sellCombined>=InpMinCombinedScore)
     { sig.direction=-1; sig.liquidityLevel=sellLiq.level; sig.liquidityScore=sellLiq.score; sig.liquidityType=sellLiq.type; sig.combinedScore=sellCombined; }
   else
     {
      if(InpVerboseLogs)
         LogEvent("SIGNAL_REJECTED",
                  "Reason=SETUP_SCORE_NOT_MET | BuyLiq="+DoubleToString(buyLiq.score,1)+
                  " | SellLiq="+DoubleToString(sellLiq.score,1)+
                  " | BuyFlow="+DoubleToString(buyFlow,1)+
                  " | SellFlow="+DoubleToString(sellFlow,1)+
                  " | BuyCombined="+DoubleToString(buyCombined,1)+
                  " | SellCombined="+DoubleToString(sellCombined,1));
      return false;
     }

   sig.signalBar=iTime(_Symbol,PERIOD_M1,1); sig.activationBar=iTime(_Symbol,PERIOD_M1,0);
   sig.buyFlowScore=buyFlow; sig.sellFlowScore=sellFlow; sig.atr=atr;
   double sp=0.0,spPct=0.0; IsSpreadAllowed(atr,sp,spPct); sig.spread=sp; gLastSignal=sig;
   return true;
  }

//+------------------------------------------------------------------+
//| Autorizacao                                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| v1.08 (B6) - guarda anti-duplicacao.                              |
//| Bloqueia um novo envio enquanto a posicao anterior ainda nao       |
//| apareceu na lista do terminal. Sem isto, um grid pode ser          |
//| executado duas vezes com o mesmo lote.                             |
//+------------------------------------------------------------------+
bool IsAwaitingOrderConfirmation(string &reason)
  {
   reason="";
   if(gExpectedPositions<=0) return false;

   if(gBasket.positions>=gExpectedPositions)
     {
      gExpectedPositions=0;
      return false;
     }

   if((TimeCurrent()-gOrderSentTime)<5)
     {
      reason="AWAITING_ORDER_CONFIRMATION";
      return true;
     }

   LogEvent("ORDER_CONFIRMATION_TIMEOUT",
            "Expected="+IntegerToString(gExpectedPositions)+
            " | Observed="+IntegerToString(gBasket.positions)+
            " | ElapsedSec="+IntegerToString((int)(TimeCurrent()-gOrderSentTime)));
   gExpectedPositions=0;
   return false;
  }

//+------------------------------------------------------------------+
//| v1.09 - SESSAO DO SIMBOLO                                         |
//|                                                                   |
//| Le as sessoes declaradas pela corretora. Nao ha horario fixo no   |
//| codigo: muda de broker ou de fuso e continua correto.             |
//|                                                                   |
//| O MT5 nunca devolve uma sessao cruzando a meia-noite: ela vem     |
//| partida em "termina 24:00" + "comeca 00:00" no dia seguinte.      |
//| Por isso a continuidade e' verificada nos dois sentidos, senao o  |
//| EA bloquearia um "fechamento" que nao existe.                     |
//+------------------------------------------------------------------+
bool GetSessionBounds(bool &inSession,int &minsFromOpen,int &minsToClose)
  {
   inSession=false; minsFromOpen=99999; minsToClose=99999;

   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   if(now<=0) return false;

   MqlDateTime dt;
   TimeToStruct(now,dt);
   ENUM_DAY_OF_WEEK dow=(ENUM_DAY_OF_WEEK)dt.day_of_week;
   int sec=dt.hour*3600+dt.min*60+dt.sec;

   const int DAYSEC=86400;
   datetime f=0,t=0;

   for(int i=0;i<8;i++)
     {
      if(!SymbolInfoSessionTrade(_Symbol,dow,i,f,t)) break;
      int a=(int)f, b=(int)t;
      if(b<=a) b=DAYSEC;                 // sessao ate o fim do dia
      if(sec<a || sec>b) continue;       // nao e' esta sessao

      inSession=true;

      // Abertura: se a sessao comeca em 00:00 e o dia anterior termina
      // em 24:00, o mercado nunca fechou - nao existe "abertura" aqui.
      bool realOpen=true;
      if(a==0)
        {
         ENUM_DAY_OF_WEEK pv=(ENUM_DAY_OF_WEEK)((dow+6)%7);
         datetime pf=0,pt=0;
         for(int k=0;k<8;k++)
           {
            if(!SymbolInfoSessionTrade(_Symbol,pv,k,pf,pt)) break;
            if((int)pt>=DAYSEC) { realOpen=false; break; }
           }
        }

      // Fechamento: mesma logica no sentido oposto.
      bool realClose=true;
      if(b>=DAYSEC)
        {
         ENUM_DAY_OF_WEEK nx=(ENUM_DAY_OF_WEEK)((dow+1)%7);
         datetime nf=0,nt=0;
         if(SymbolInfoSessionTrade(_Symbol,nx,0,nf,nt) && (int)nf==0)
            realClose=false;
        }

      minsFromOpen=(realOpen  ? (sec-a)/60 : 99999);
      minsToClose =(realClose ? (b-sec)/60 : 99999);
      return true;
     }

   return true;   // consultou com sucesso, mas esta fora de sessao
  }

bool IsSessionWindowAllowed(string &reason)
  {
   reason="";
   if(!InpUseSessionFilter) return true;

   bool inSession=false;
   int fromOpen=0,toClose=0;
   if(!GetSessionBounds(inSession,fromOpen,toClose)) return true;

   if(!inSession)
     {
      reason="MARKET_CLOSED";
      return false;
     }

   if(InpBlockMinutesAfterOpen>0 && fromOpen<InpBlockMinutesAfterOpen)
     {
      reason="SESSION_OPEN_"+IntegerToString(InpBlockMinutesAfterOpen-fromOpen)+"MIN_LEFT";
      return false;
     }

   if(InpBlockMinutesBeforeClose>0 && toClose<=InpBlockMinutesBeforeClose)
     {
      reason="SESSION_CLOSE_IN_"+IntegerToString(toClose)+"MIN";
      return false;
     }

   return true;
  }


//+------------------------------------------------------------------+
//| v1.11 - LUCRO DA SEMANA E DO MES                                  |
//| Semana comeca na SEGUNDA 00:00 do servidor (mesma base do dia).   |
//+------------------------------------------------------------------+
datetime WeekStart(datetime t)
  {
   MqlDateTime d; TimeToStruct(t,d);
   int dow=d.day_of_week;            // 0 = domingo
   int back=(dow==0 ? 6 : dow-1);
   return DayStart(t)-back*86400;
  }

double GetWeekProfit()
  {
   datetime now=TimeCurrent();
   return GetProfitFrom(WeekStart(now),now);
  }

void RefreshPeriodStats(bool force=false)
  {
   datetime now=TimeCurrent();
   if(!force && gPeriodRefresh>0 && (now-gPeriodRefresh)<15) return;
   gPeriodRefresh=now;
   gWeekProfit =GetWeekProfit();
   gMonthProfit=GetMonthProfit();
   gYearProfit =GetYearProfit();
   gTradesWeek =GetOwnClosedTradesCount(WeekStart(now),now);
   MqlDateTime d; TimeToStruct(now,d);
   d.hour=0; d.min=0; d.sec=0; d.day=1;
   datetime monthStart=StructToTime(d);
   gTradesMonth=GetOwnClosedTradesCount(monthStart,now);
   d.mon=1;
   datetime yearStart=StructToTime(d);
   gTradesYear=GetOwnClosedTradesCount(yearStart,now);
  }

//+------------------------------------------------------------------+
//| v1.11 - TELEMETRIA CSV                                            |
//|                                                                   |
//| Telemetria padrao append-only em MQL5\\Files\\FluxMatrix_PRO\\             |
//|   AAAA.MM.DD_SIMBOLO_MAGIC_bars.csv                               |
//|   AAAA.MM.DD_SIMBOLO_MAGIC_events.csv                             |
//|   AAAA.MM.DD_SIMBOLO_MAGIC_baskets.csv                            |
//|                                                                   |
//| Separados de proposito: misturar granularidades num arquivo so    |
//| inviabiliza tabela dinamica. bars = contexto continuo (o que o    |
//| log do MT5 nao tem), events = decisoes, baskets = resultado.      |
//|                                                                   |
//| Escrita abre/fecha a cada linha. E' mais lento que manter o       |
//| handle aberto, mas se o terminal cair nada se perde - e a         |
//| frequencia (1 linha/minuto) torna o custo irrelevante.            |
//+------------------------------------------------------------------+

// Ponto decimal fixo: com locale pt-BR o MT5 escreveria virgula e
// quebraria o separador do CSV.
string CsvNum(double v,int dig)
  {
   string t=DoubleToString(v,dig);
   StringReplace(t,",",".");
   return t;
  }

string CsvSanitize(string t)
  {
   StringReplace(t,":","-");
   StringReplace(t,"/","-");
   StringReplace(t,"\\","-");
   StringReplace(t," ","_");
   StringReplace(t,";","_");
   StringReplace(t,"\r"," ");
   StringReplace(t,"\n"," ");
   return t;
  }

string CsvErrText(int code)
  {
   switch(code)
     {
      case 5002: return "NOME_DE_ARQUIVO_INVALIDO";
      case 5004: return "NAO_CONSEGUIU_ABRIR";
      case 5018: return "CAMINHO_E_UMA_PASTA";
      case 5019: return "ARQUIVO_NAO_EXISTE";
      case 5020: return "NAO_CONSEGUIU_REESCREVER";
      case 5024: return "PASTA_INEXISTENTE";
     }
   return "ERRO_"+IntegerToString(code);
  }

//+------------------------------------------------------------------+
//| Escrita append.                                                   |
//|                                                                   |
//| CORRECAO v1.12: a versao anterior abria com FILE_READ|FILE_WRITE. |
//| No MT5 essa combinacao NAO cria arquivo novo - ela falha com      |
//| 5019 quando o arquivo ainda nao existe, e como a primeira         |
//| gravacao do dia e' sempre num arquivo novo, NADA era gravado.     |
//| Agora: arquivo novo -> FILE_WRITE (cria); existente -> READ|WRITE |
//| com seek no fim.                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Fotografia do mercado na vela fechada                             |
//+------------------------------------------------------------------+
void CaptureMarketSnapshot()
  {
   gSnap.valid=false;
   gSnap.bar=iTime(_Symbol,PERIOD_M1,1);

   double atr=(ArraySize(gATR)>1 ? gATR[1] : 0.0);
   gSnap.atr=atr;
   gSnap.bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   gSnap.ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   double sp=0.0,spPct=0.0;
   IsSpreadAllowed(atr,sp,spPct);
   gSnap.spreadPts=sp; gSnap.spreadAtrPct=spPct;

   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   gSnap.ema   =(ArraySize(gEMA)>1 ? gEMA[1] : 0.0);
   gSnap.close1=iClose(_Symbol,PERIOD_M1,1);
   gSnap.distEmaPts=(point>0.0 && gSnap.ema>0.0 ? (gSnap.close1-gSnap.ema)/point : 0.0);

   gSnap.trendBuy =IsTrendAllowed(1);
   gSnap.trendSell=IsTrendAllowed(-1);
   gSnap.trendLabel="NEUTRO";
   if(InpTrendFilterMode==TREND_FILTER_OFF)            gSnap.trendLabel="OFF";
   else if(gSnap.trendBuy && !gSnap.trendSell)         gSnap.trendLabel="COMPRA";
   else if(gSnap.trendSell && !gSnap.trendBuy)         gSnap.trendLabel="VENDA";

   gSnap.flowBuy=0.0; gSnap.flowSell=0.0;
   gSnap.liqBuyScore=0.0; gSnap.liqSellScore=0.0;
   gSnap.liqBuyLevel=0.0; gSnap.liqSellLevel=0.0;
   gSnap.liqBuyType="NONE"; gSnap.liqSellType="NONE";
   gSnap.combBuy=0.0; gSnap.combSell=0.0; gSnap.combBest=0.0;

   if(atr>0.0)
     {
      CalculateFlowScores(gSnap.flowBuy,gSnap.flowSell,false);

      LiquidityContext bl,sl;
      EvaluateLiquidity(1,atr,bl);
      EvaluateLiquidity(-1,atr,sl);
      gSnap.liqBuyScore=bl.score;  gSnap.liqBuyLevel=bl.level;  if(bl.type!="") gSnap.liqBuyType=bl.type;
      gSnap.liqSellScore=sl.score; gSnap.liqSellLevel=sl.level; if(sl.type!="") gSnap.liqSellType=sl.type;

      // Mesmas condicoes de BuildInitialSignal: o painel e o CSV nao
      // podem mostrar score que a logica de entrada nao reconheceria.
      bool buyOk =InpAllowBuy  && gSnap.trendBuy  && bl.valid &&
                  bl.score>=InpMinEntryLiquidityScore &&
                  gSnap.flowBuy>=InpMinFlowScore &&
                  gSnap.flowBuy>=gSnap.flowSell+InpFlowDominance;
      bool sellOk=InpAllowSell && gSnap.trendSell && sl.valid &&
                  sl.score>=InpMinEntryLiquidityScore &&
                  gSnap.flowSell>=InpMinFlowScore &&
                  gSnap.flowSell>=gSnap.flowBuy+InpFlowDominance;

      gSnap.combBuy =(buyOk  ? 0.40*bl.score+0.60*gSnap.flowBuy  : 0.0);
      gSnap.combSell=(sellOk ? 0.40*sl.score+0.60*gSnap.flowSell : 0.0);
      gSnap.combBest=MathMax(gSnap.combBuy,gSnap.combSell);
      gSnap.valid=true;
     }

   gSnap.flowSide="NEUTRO";
   if(gSnap.flowBuy>=InpMinFlowScore && gSnap.flowBuy>=gSnap.flowSell+InpFlowDominance)       gSnap.flowSide="COMPRA";
   else if(gSnap.flowSell>=InpMinFlowScore && gSnap.flowSell>=gSnap.flowBuy+InpFlowDominance) gSnap.flowSide="VENDA";

   // volume da vela contra a media das 20 anteriores
   gSnap.volRatio=0.0;
   long v1=iVolume(_Symbol,PERIOD_M1,1);
   if(v1>0)
     {
      double soma=0.0; int c=0;
      for(int i=2;i<22;i++) { long v=iVolume(_Symbol,PERIOD_M1,i); if(v>0){ soma+=(double)v; c++; } }
      if(c>0 && soma>0.0) gSnap.volRatio=(double)v1/(soma/c);
     }
  }

//+------------------------------------------------------------------+
//| bars.csv - contexto completo, 1 linha por vela                    |
//+------------------------------------------------------------------+
void CsvBarRow(string decisao,string motivo)
  {
   if(!InpEnableCsvTelemetry || !InpCsvBarsEveryBar) return;

   string detail=
      "Decision="+decisao+
      " | Reason="+motivo+
      " | Bar="+TimeToString(gSnap.bar,TIME_DATE|TIME_MINUTES)+
      " | ATR="+CsvNum(gSnap.atr,_Digits)+
      " | Bid="+CsvNum(gSnap.bid,_Digits)+
      " | Ask="+CsvNum(gSnap.ask,_Digits)+
      " | SpreadPts="+CsvNum(gSnap.spreadPts,1)+
      " | SpreadATR="+CsvNum(gSnap.spreadAtrPct,2)+
      " | EMA="+CsvNum(gSnap.ema,_Digits)+
      " | Trend="+gSnap.trendLabel+
      " | LiqBuy="+gSnap.liqBuyType+":"+CsvNum(gSnap.liqBuyScore,1)+
      " | LiqSell="+gSnap.liqSellType+":"+CsvNum(gSnap.liqSellScore,1)+
      " | FlowBuy="+CsvNum(gSnap.flowBuy,1)+
      " | FlowSell="+CsvNum(gSnap.flowSell,1)+
      " | Combined="+CsvNum(gSnap.combBest,1)+
      " | Basket="+(gBasket.active?"ACTIVE":"FLAT")+
      " | Legs="+IntegerToString(gBasket.positions)+
      " | Volume="+CsvNum(gBasket.totalVolume,2)+
      " | Window="+OperationalWindowText();

   string marketEvent=(decisao=="LIVE"?"LIVE_SNAPSHOT":"CLOSED_BAR");
   double px=(decisao=="LIVE"?SymbolInfoDouble(_Symbol,SYMBOL_BID):gSnap.close1);
   if(decisao=="LIVE")
      detail+=" | LiveBid="+CsvNum(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits)+
              " | LiveAsk="+CsvNum(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits)+
              " | Floating="+CsvNum(gBasket.basketProfit,2)+
              " | MarginLevel="+CsvNum(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),2)+
              " | FreeMargin="+CsvNum(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2);
   TelemetryWrite("MARKET_STATE",marketEvent,detail,px,gBasket.totalVolume,
                  "State="+StateToString(gState));
  }

//+------------------------------------------------------------------+
//| events.csv - 1 linha por decisao, com o contexto do momento       |
//+------------------------------------------------------------------+
void CsvEventRow(string evento,string detalhe,double preco,double volume,string extra)
  {
   if(!InpEnableCsvTelemetry) return;
   string family=TelemetryFamilyForEvent(evento);
   string d=detalhe;
   if(extra!="")
     {
      if(d!="") d+=" | ";
      d+=extra;
     }
   TelemetryWrite(family,evento,d,preco,volume,"State="+StateToString(gState));
  }

// Versao que devolve o resultado da escrita, usada no teste de arranque.
bool CsvEventRow2(string evento,string detalhe)
  {
   long antes=gCsvRows;
   CsvEventRow(evento,detalhe,0.0,0.0,"");
   return (gCsvRows>antes);
  }

//+------------------------------------------------------------------+
//| baskets.csv - 1 linha por cesto fechado                           |
//| Guarda o CONTEXTO DA ENTRADA junto do resultado: e' o arquivo     |
//| que permite responder "que tipo de setup vira perda grande".      |
//+------------------------------------------------------------------+
void CsvBasketRow(string reason,double realized,long durationSec,int prevPositions)
  {
   if(!InpEnableCsvTelemetry) return;

   string detail=
      "ExitReason="+reason+
      " | DurationSec="+IntegerToString((int)durationSec)+
      " | Direction="+(gBasket.direction==POSITION_TYPE_BUY?"BUY":"SELL")+
      " | Legs="+IntegerToString(prevPositions)+
      " | Volume="+CsvNum(gPrevBasketVolume,2)+
      " | Average="+CsvNum(gBasket.averagePrice,_Digits)+
      " | WorstEntry="+CsvNum(gBasket.worstEntry,_Digits)+
      " | TP="+CsvNum(gLastKnownBasketTP,_Digits)+
      " | MAE="+CsvNum(gBasket.maxAdverseExcursion,2)+
      " | MFE="+CsvNum(gBasket.maxFavorableExcursion,2)+
      " | Realized="+CsvNum(realized,2)+
      " | EntryLiquidity="+gLastSignal.liquidityType+
      " | EntryScore="+CsvNum(gLastSignal.combinedScore,1);

   TelemetryWrite("BASKET_SUMMARY","BASKET_CLOSED",detail,0.0,gPrevBasketVolume,
                  "BasketID="+StringFormat("%I64u",gBasket.basketId));
  }

//+------------------------------------------------------------------+
//| Janela operacional por dia/hora do servidor da corretora          |
//+------------------------------------------------------------------+


bool IsTradingDayEnabled(int dayOfWeek)
  {
   switch(dayOfWeek)
     {
      case 1: return InpTradeMonday;
      case 2: return InpTradeTuesday;
      case 3: return InpTradeWednesday;
      case 4: return InpTradeThursday;
      case 5: return InpTradeFriday;
     }
   return false;
  }

string OperationalWindowText()
  {
   if(!InpUseTradingDays && !InpUseTradingHours) return "LIVRE";
   string h=StringFormat("%02d:%02d-%02d:%02d Broker",
                         InpTradingStartHour,InpTradingStartMinute,
                         InpTradingEndHour,InpTradingEndMinute);
   if(!InpUseTradingHours) h="Horario livre";
   if(!InpUseTradingDays)  return h+" | Dias livres";
   return h+" | Seg-Sex configuravel";
  }

bool IsOperationalWindowAllowed(string &reason)
  {
   reason="";

   // Paridade: com os dois filtros OFF esta extensao nao possui autoridade.
   if(!InpUseTradingDays && !InpUseTradingHours) return true;

   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   if(now<=0)
     {
      reason="BROKER_TIME_UNAVAILABLE";
      return false;
     }

   MqlDateTime d;
   TimeToStruct(now,d);
   int currentMin=d.hour*60+d.min;
   int startMin=InpTradingStartHour*60+InpTradingStartMinute;
   int endMin=InpTradingEndHour*60+InpTradingEndMinute;

   int sessionDay=d.day_of_week;
   bool timeAllowed=true;

   if(InpUseTradingHours)
     {
      if(startMin==endMin)
        {
         timeAllowed=true; // mesma hora representa janela de 24h
        }
      else if(startMin<endMin)
        {
         timeAllowed=(currentMin>=startMin && currentMin<endMin);
        }
      else
        {
         // Janela atravessa meia-noite. O trecho apos 00:00 pertence
         // ao dia operacional em que a janela comecou.
         timeAllowed=(currentMin>=startMin || currentMin<endMin);
         if(currentMin<endMin)
            sessionDay=(sessionDay+6)%7;
        }
     }

   if(InpUseTradingDays && !IsTradingDayEnabled(sessionDay))
     {
      reason="DIA_DESABILITADO";
      return false;
     }

   if(!timeAllowed)
     {
      reason="FORA_HORARIO_OPERACIONAL";
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| v1.10 - LIMPAR CACHE (botao do painel)                            |
//|                                                                   |
//| Zera tudo que o EA guarda para nao recalcular a cada tick:        |
//| calendario de noticias, resultado do dia, buffers de indicador,   |
//| estado do cesto e os objetos do painel. Nao mexe em posicao       |
//| aberta nem em trava de risco.                                     |
//+------------------------------------------------------------------+
void ClearCaches()
  {
   gLastNewsCheck=0; gCachedNewsBlocked=false;
   gCachedNewsName=""; gCachedNewsCurrency=""; gCachedNewsTime=0;
   gNativeCalendarPanelDetail="";
   gRecoveryNewsLastCheck=0;
   gRecoveryNewsState=(InpRecoveryNewsGuardEnabled?REC_NEWS_CLEAR:REC_NEWS_OFF);
   gRecoveryNewsEventName=""; gRecoveryNewsCurrency=""; gRecoveryNewsEventTime=0; gRecoveryNewsEventID=0;
   gRecoveryNewsWindowStart=0; gRecoveryNewsWindowEnd=0;
   gDayStatsRefresh=0;
   gPeriodRefresh=0;
   RefreshDayStats(true);
   RefreshPeriodStats(true);
   RefreshIndicators();
   RefreshBasketState();
   CaptureMarketSnapshot();
   gLastRecoveryBlockLogTime=0;
   gLastInconsistentLogTime=0;
   gLastTPFailLogTime=0;
   gPanelForceRedraw=true;
   LogEvent("CACHE_REFRESHED",
            "Noticias=reset | Periodos=recalculados | Indicadores=recarregados | TradingState=intacto");
  }

//+------------------------------------------------------------------+
//| v1.10 - EXPORTAR CSV                                              |
//|                                                                   |
//| Destino: MQL5\\Files\\FluxMatrix_PRO\\         |
//| No MetaTrader: Arquivo > Abrir Pasta de Dados > MQL5 > Files > FluxMatrix_PRO |
//| Exporta os DEALS reais do historico - nada reconstruido de        |
//| memoria, para o arquivo bater com o extrato da corretora.         |
//+------------------------------------------------------------------+
bool ExportDealsCsv(string &outPath,int &rows)
  {
   outPath=""; rows=0;
   int days=InpExportDays; if(days<1) days=1;
   datetime to=TimeCurrent();
   datetime from=DayStart(to)-(days-1)*86400;

   if(!HistorySelect(from,to))
     {
      gCsvLastError=GetLastError();
      Print(FMX_PRODUCT_NAME," | EVENT=CSV_EXPORT_FAILED | Reason=HISTORY_SELECT | Error=",gCsvLastError);
      return false;
     }

   outPath=TelemetryFile("DEALS_EXPORT");
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong t=HistoryDealGetTicket(i);
      if(t==0) continue;
      if(HistoryDealGetString(t,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(t,DEAL_MAGIC)!=InpMagicNumber) continue;

      ENUM_DEAL_TYPE dt=(ENUM_DEAL_TYPE)HistoryDealGetInteger(t,DEAL_TYPE);
      if(dt!=DEAL_TYPE_BUY && dt!=DEAL_TYPE_SELL) continue;

      double prof=HistoryDealGetDouble(t,DEAL_PROFIT);
      double swap=HistoryDealGetDouble(t,DEAL_SWAP);
      double comm=HistoryDealGetDouble(t,DEAL_COMMISSION);
      string detail=
         "DealTicket="+StringFormat("%I64u",t)+
         " | PositionID="+StringFormat("%I64d",HistoryDealGetInteger(t,DEAL_POSITION_ID))+
         " | Type="+(dt==DEAL_TYPE_BUY?"BUY":"SELL")+
         " | Entry="+EnumToString((ENUM_DEAL_ENTRY)HistoryDealGetInteger(t,DEAL_ENTRY))+
         " | DealTime="+TimeToString((datetime)HistoryDealGetInteger(t,DEAL_TIME),TIME_DATE|TIME_MINUTES|TIME_SECONDS)+
         " | Commission="+CsvNum(comm,2)+
         " | Swap="+CsvNum(swap,2)+
         " | Profit="+CsvNum(prof,2)+
         " | Net="+CsvNum(prof+swap+comm,2)+
         " | Reason="+EnumToString((ENUM_DEAL_REASON)HistoryDealGetInteger(t,DEAL_REASON));

      ulong positionId=(ulong)HistoryDealGetInteger(t,DEAL_POSITION_ID);
      ulong orderId=(ulong)HistoryDealGetInteger(t,DEAL_ORDER);
      if(TelemetryWrite("DEALS_EXPORT","DEAL_EXPORT",detail,
                        HistoryDealGetDouble(t,DEAL_PRICE),
                        HistoryDealGetDouble(t,DEAL_VOLUME),
                        "Comment="+HistoryDealGetString(t,DEAL_COMMENT),
                        orderId,t,positionId))
         rows++;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| v1.10 - A PERNA NOVA CABE DENTRO DO STOP?                         |
//|                                                                   |
//| Achado nos logs de 27 e 28/08: as tres perdas do periodo tiveram  |
//| a MESMA assinatura - o EA abriu a ultima perna com 56%, 61% e 88% |
//| do stop ja consumido, e o cesto morreu 160s, 21s e 4s depois.     |
//| Em 28/08 03:23 o volume dobrou (0.31 -> 0.63) faltando $18 para   |
//| o stop de $150: essa perna nunca teve espaco para recuperar nada, |
//| so cortou pela metade a distancia que faltava para morrer.        |
//|                                                                   |
//| A conta: com o volume JA somado a perna nova, quantos pontos o    |
//| preco ainda pode andar contra antes do stop? Se for menos que um  |
//| grid, a perna nao consegue nem chegar ao proximo nivel - ela nao  |
//| e' recuperacao, e' aceleracao de perda.                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| v1.09 - CONVERSAO DINHEIRO <-> PONTOS                             |
//|                                                                   |
//| Depende do volume ABERTO. 100 pontos com 0.01 lote nao e' o mesmo |
//| risco que 100 pontos com 0.31 lote - e o cesto passa por ambos.   |
//+------------------------------------------------------------------+
double MoneyPerPoint()
  {
   if(gBasket.totalVolume<=0.0) return 0.0;
   double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize =SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double point    =SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(tickValue<=0.0 || tickSize<=0.0 || point<=0.0) return 0.0;
   return gBasket.totalVolume*tickValue*point/tickSize;
  }

double MoneyToPoints(double money)
  {
   if(money<=0.0) return 0.0;
   double mpp=MoneyPerPoint();
   if(mpp<=0.0) return 0.0;
   return money/mpp;
  }
bool CanOpenNewBasket(const SignalContext &sig,string &reason)
  {
   reason="";
   if(!gStartupReconciled)      { reason="STARTUP_RECONCILIATION"; return false; }
   if(gRecoveryReconciliation)  { reason="RECOVERY_RECONCILIATION"; return false; }
   if(gPendingRequestReconcile) { reason="PENDING_REQUEST_RECONCILIATION"; return false; }
   if(gBasket.active)           { reason="BASKET_ALREADY_OPEN"; return false; }
   if(gDailyTargetLock)         { reason="DAILY_TARGET_LOCK"; return false; }
   if(gUserEntryPause)          { reason="PAUSA_MANUAL"; return false; }
   if(IsAwaitingOrderConfirmation(reason)) return false;

   // Baseline LiquidityFlow: sessao real da corretora continua autoridade.
   if(!IsSessionWindowAllowed(reason)) return false;

   // Extensao autorizada. Defaults OFF para preservar paridade.
   if(!IsOperationalWindowAllowed(reason)) return false;

   string nn="",nc=""; datetime nt=0;
   if(IsNewsBlocked(nn,nc,nt))
     {
      reason="NEWS_BLOCK";
      LogEvent("NEWS_BLOCK","Currency="+nc+" | Event="+nn+" | Time="+TimeToString(nt,TIME_DATE|TIME_MINUTES));
      return false;
     }

   double sp=0.0,spPct=0.0;
   if(!IsSpreadAllowed(sig.atr,sp,spPct))
     {
      reason="SPREAD_BLOCK";
      LogEvent("SPREAD_BLOCK","SpreadPoints="+DoubleToString(sp,1)+" | SpreadATRPercent="+DoubleToString(spPct,2));
      return false;
     }

   if(gLastOrderFailureTime>0 && (TimeCurrent()-gLastOrderFailureTime)<InpOrderFailureCooldownSeconds)
     { reason="ORDER_FAILURE_COOLDOWN"; return false; }

   return true;
  }

//+------------------------------------------------------------------+
//| CanAttemptRecovery                                                |
//| CORRECAO A2: removidos os parametros buyFlow/sellFlow que eram    |
//| auto-atribuidos e nunca usados no modo GRID_IMMEDIATE.            |
//+------------------------------------------------------------------+
bool CanAttemptRecovery(int direction,double atr,string &reason)
  {
   reason="";

   if(!gBasket.active)                                  { reason="NO_BASKET"; return false; }
   if(gRecoveryReconciliation)                          { reason="RECOVERY_RECONCILIATION"; return false; }
   if(gPendingRequestReconcile)                         { reason="PENDING_REQUEST_RECONCILIATION"; return false; }
   if(IsAwaitingOrderConfirmation(reason))              return false;
   if(gBasket.recoveryLevel>=InpMaxRecoveryLevels)      { reason="MAX_RECOVERY_LEVEL"; return false; }
   if(gProtBlockRecovery)                               { reason="PROTECAO_PERDA_BLOQUEIA_RECOVERY"; return false; }
   if(InpMaxBasketVolume>0.0)
     {
      double nextLot=NormalizeVolume((gBasket.lastExecutedLot>0.0 ? gBasket.lastExecutedLot : InpInitialLot)*InpMultiplier);
      if(gBasket.totalVolume+nextLot>InpMaxBasketVolume+1e-9) { reason="MAX_BASKET_VOLUME_REACHED"; return false; }
     }

   double sp=0.0,spPct=0.0;
   if(!IsSpreadAllowed(atr,sp,spPct))
     { reason="SPREAD_BLOCK_"+DoubleToString(spPct,2)+"PCT_ATR"; return false; }

   if(gLastOrderFailureTime>0 &&
      (TimeCurrent()-gLastOrderFailureTime)<InpOrderFailureCooldownSeconds)
     { reason="ORDER_FAILURE_COOLDOWN"; return false; }

   double recoveryDistance=GetRecoveryDistancePrice(atr);
   if(recoveryDistance<=0.0)                            { reason="INVALID_RECOVERY_DISTANCE"; return false; }

   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(ask<=0.0 || bid<=0.0)                             { reason="INVALID_PRICES"; return false; }

   bool gridReached=
      (direction>0
       ? ask<=gBasket.worstEntry-recoveryDistance
       : bid>=gBasket.worstEntry+recoveryDistance);

   if(!gridReached)                                     { reason="GRID_NOT_REACHED"; return false; }

   return true;
  }

//+------------------------------------------------------------------+
//| Volume                                                            |
//| CORRECAO B2: trunca para baixo (nunca envia mais do que o         |
//| calculado) e deriva os digitos do step real do simbolo.           |
//+------------------------------------------------------------------+
double NormalizeVolume(double lot)
  {
   double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step  =SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step<=0.0) step=(minLot>0.0 ? minLot : 0.01);

   // tolerancia de 1e-8 para nao perder um step por erro de ponto flutuante
   lot=MathFloor(lot/step+1e-8)*step;
   if(lot<minLot) lot=minLot;
   if(maxLot>0.0 && lot>maxLot) lot=maxLot;

   int digits=0;
   double s=step;
   while(digits<8 && MathAbs(s-MathRound(s))>1e-9) { s*=10.0; digits++; }
   return NormalizeDouble(lot,digits);
  }

double NormalizePriceToTick(double price)
  {
   if(price<=0.0) return 0.0;
   double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize<=0.0) tickSize=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(tickSize<=0.0) return NormalizeDouble(price,_Digits);
   double ticks=MathRound(price/tickSize);
   return NormalizeDouble(ticks*tickSize,_Digits);
  }

double ProjectedWorstCaseVolume()
  {
   // Soma geometrica: L0 * (m^(n+1) - 1) / (m - 1), n = niveis de recovery.
   int n=InpMaxRecoveryLevels;
   if(InpMultiplier<=1.0) return InpInitialLot*(double)(n+1);
   return InpInitialLot*(MathPow(InpMultiplier,(double)(n+1))-1.0)/(InpMultiplier-1.0);
  }

ENUM_ORDER_TYPE_FILLING GetFillingMode()
  {
   long filling=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   if((filling & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) return ORDER_FILLING_FOK;
   if((filling & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC) return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
  }

bool PreflightOrder(ENUM_ORDER_TYPE type,double volume,double price,string &reason,double &projectedMarginLevel)
  {
   reason=""; projectedMarginLevel=0.0;
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) { reason="TERMINAL_TRADE_DISABLED"; return false; }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))           { reason="MQL_TRADE_DISABLED";      return false; }

   volume=NormalizeVolume(volume);
   double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),maxLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(volume<minLot || (maxLot>0.0 && volume>maxLot)) { reason="INVALID_VOLUME"; return false; }
   if(InpMaxBasketVolume>0.0 && gBasket.totalVolume+volume>InpMaxBasketVolume) { reason="MAX_BASKET_VOLUME"; return false; }

   double marginNew=0.0;
   if(!OrderCalcMargin(type,_Symbol,volume,price,marginNew)) { reason="ORDER_CALC_MARGIN_FAILED"; return false; }
   double equity=AccountInfoDouble(ACCOUNT_EQUITY),margin=AccountInfoDouble(ACCOUNT_MARGIN),projectedMargin=margin+marginNew;
   projectedMarginLevel=(projectedMargin>0.0 ? (equity/projectedMargin)*100.0 : DBL_MAX);
   if(InpMinMarginLevelPct>0.0 && projectedMarginLevel<InpMinMarginLevelPct) { reason="PROJECTED_MARGIN_LEVEL_LOW"; return false; }

   MqlTradeRequest req; MqlTradeCheckResult chk; ZeroMemory(req); ZeroMemory(chk);
   req.action=TRADE_ACTION_DEAL; req.magic=InpMagicNumber; req.symbol=_Symbol; req.volume=volume; req.type=type;
   req.price=price; req.deviation=InpDeviationPoints;
   req.type_filling=gFillingMode;             // CORRECAO B1
   req.type_time=ORDER_TIME_GTC;
   ResetLastError();
   if(!OrderCheck(req,chk))
     {
      reason="ORDERCHECK_CALL_FAILED_"+IntegerToString(GetLastError());
      return false;
     }

   // Em MqlTradeCheckResult, retcode 0 com comment "Done" representa preflight valido.
   if(chk.retcode!=0 &&
      chk.retcode!=TRADE_RETCODE_DONE &&
      chk.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
      chk.retcode!=TRADE_RETCODE_PLACED)
     {
      reason="ORDERCHECK_REJECT_"+IntegerToString((int)chk.retcode)+"_"+chk.comment;
      return false;
     }

   if(InpVerboseLogs)
      LogEvent("ORDER_PREFLIGHT_OK",
               "CheckRetcode="+IntegerToString((int)chk.retcode)+
               " | CheckComment="+chk.comment+
               " | Volume="+DoubleToString(volume,2)+
               " | ProjectedMarginLevel="+DoubleToString(projectedMarginLevel,2));
   return true;
  }

bool TradeRetcodeSuccess(uint retcode)
  { return (retcode==TRADE_RETCODE_DONE || retcode==TRADE_RETCODE_DONE_PARTIAL || retcode==TRADE_RETCODE_PLACED); }
bool SendInitialOrder(const SignalContext &sig)
  {
   double volume=NormalizeVolume(InpInitialLot);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK),bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(point<=0.0 || ask<=0.0 || bid<=0.0) return false;

   ENUM_ORDER_TYPE type=(sig.direction>0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   double price=(sig.direction>0 ? ask : bid),tp=0.0,sl=0.0;

   if(InpTakeProfitEnabled && InpTakeProfitUnit==TAKE_PROFIT_POINTS && InpInitialTakeProfitPoints>0)
     {
      // Paridade exata do caminho POINTS da baseline.
      tp=NormalizeDouble(price+(sig.direction>0 ? 1.0 : -1.0)*InpInitialTakeProfitPoints*point,_Digits);
      if(tp>0.0 && !AdjustProtectionPrices(sig.direction,sl,tp))
        {
         LogEvent("INITIAL_ORDER_FAILED","Reason=INVALID_TP_VS_STOPS_LEVEL");
         return false;
        }
     }
   else if(InpTakeProfitEnabled && InpTakeProfitUnit==TAKE_PROFIT_MONEY && InpInitialTakeProfitMoney>0.0)
     {
      double projected=0.0,diff=0.0; string solveReason="";
      if(SolveSingleTPMoney(sig.direction,volume,price,InpInitialTakeProfitMoney,tp,projected,diff,solveReason))
        {
         double tmpSL=0.0,tmpTP=tp;
         if(AdjustProtectionPrices(sig.direction,tmpSL,tmpTP))
           {
            tp=tmpTP;
            gTPMoneySolverOk=true;
            gResolvedTPMoneyTarget=InpInitialTakeProfitMoney;
            gResolvedTPMoneyProjected=projected;
            gResolvedTPMoneyDifference=diff;
           }
         else
           {
            tp=0.0;
            gTPMoneyMonitorOnly=true;
           }
        }
      else
        {
         tp=0.0;
         gTPMoneyMonitorOnly=true;
         LogEvent("TP_MONEY_SOLVER_FAILED","Scope=SINGLE | Reason="+solveReason+" | BrokerTP=false | MonitorEASide=true");
        }
     }

   string reason=""; double pml=0.0;
   if(!PreflightOrder(type,volume,price,reason,pml))
     {
      gLastOrderFailureTime=TimeCurrent();
      LogEvent("INITIAL_ORDER_FAILED","Reason="+reason+" | Volume="+DoubleToString(volume,2)+" | ProjectedMarginLevel="+DoubleToString(pml,2));
      return false;
     }

   int positionsBefore=CountOwnedPositions();
   bool sent=false; ResetLastError();
   if(sig.direction>0) sent=trade.Buy(volume,_Symbol,ask,0.0,tp,"FluxMatrix PRO Initial Buy");
   else                sent=trade.Sell(volume,_Symbol,bid,0.0,tp,"FluxMatrix PRO Initial Sell");
   uint rc=trade.ResultRetcode();
   if(!sent || !TradeRetcodeSuccess(rc))
     {
      gLastOrderFailureTime=TimeCurrent();
      if(rc==TRADE_RETCODE_TIMEOUT || rc==TRADE_RETCODE_CONNECTION || !(bool)TerminalInfoInteger(TERMINAL_CONNECTED))
         MarkPendingRequest("L0",positionsBefore);
      LogEvent("INITIAL_ORDER_FAILED","Retcode="+IntegerToString((int)rc)+" | Comment="+trade.ResultRetcodeDescription());
      return false;
     }

   gRecoveryArmed=false; gExitReasonHint=""; gLastKnownBasketTP=tp;
   gExpectedPositions=positionsBefore+1; gOrderSentTime=TimeCurrent();
   RefreshBasketState();
   if(gBasket.active && InpTakeProfitEnabled && InpTakeProfitUnit==TAKE_PROFIT_MONEY)
      UpdateStaticBasketTP();

   CsvEventRow("INITIAL_ORDER_SENT",(sig.direction>0?"BUY":"SELL"),trade.ResultPrice(),volume,
               "tp="+CsvNum(tp,_Digits)+" score="+CsvNum(sig.combinedScore,1)+" liq="+sig.liquidityType);
   LogEvent("INITIAL_ORDER_SENT",
            "Direction="+(sig.direction>0?"BUY":"SELL")+
            " | Volume="+DoubleToString(volume,2)+
            " | Price="+DoubleToString(trade.ResultPrice(),_Digits)+
            " | TP="+DoubleToString(tp,_Digits)+
            " | ProjectedMarginLevel="+DoubleToString(pml,2));
   TelemetryWrite("EXECUTION","ORDERSEND_RESULT","Scope=L0 | Success=true | Retcode="+IntegerToString((int)rc),trade.ResultPrice(),volume);
   SaveState("L0_CONFIRMED");
   return true;
  }
bool SendRecoveryOrder(int direction,double atr)
  {
   if(!gBasket.active || gBasket.recoveryLevel>=InpMaxRecoveryLevels) return false;

   double baseLot=(gBasket.lastExecutedLot>0.0 ? gBasket.lastExecutedLot : InpInitialLot);
   double volume=NormalizeVolume(baseLot*InpMultiplier);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK),bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(ask<=0.0 || bid<=0.0) return false;

   ENUM_ORDER_TYPE type=(direction>0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   double price=(direction>0 ? ask : bid);
   int positionsBefore=gBasket.positions;

   string reason=""; double pml=0.0;
   if(!PreflightOrder(type,volume,price,reason,pml))
     {
      gLastOrderFailureTime=TimeCurrent(); gRecoveryArmed=false;
      if(StringFind(reason,"MARGIN")>=0)
         LogEvent("RECOVERY_BLOCKED_MARGIN","Reason="+reason+" | Volume="+DoubleToString(volume,2)+" | ProjectedMarginLevel="+DoubleToString(pml,2));
      else
         LogEvent("RECOVERY_ORDER_FAILED","Reason="+reason+" | Volume="+DoubleToString(volume,2));
      return false;
     }

   // Unica rechecagem final autorizada: NEWS. Nao recalcula Grid/WorstEntry/timing.
   string en="",cur=""; datetime et=0,ws=0,we=0;
   ENUM_RECOVERY_NEWS_GUARD_STATE ng=EvaluateRecoveryNewsGuard(true,en,cur,et,ws,we);
   if(ng==REC_NEWS_BLOCKED || ng==REC_NEWS_UNAVAILABLE)
     {
      gRecoveryArmed=false; gRecoveryArmedTime=0; gRecoveryArmedPrice=0.0;
      gRecoveryNewsNeedsReevaluation=true;
      string ev=(ng==REC_NEWS_BLOCKED ? "RECOVERY_NEWS_WINDOW_ENTERED_BEFORE_SEND" : "RECOVERY_BLOCKED_NEWS_DATA_UNAVAILABLE");
      string d="RecoveryLevel="+IntegerToString(gBasket.recoveryLevel+1)+
               " | EventID="+StringFormat("%I64u",gRecoveryNewsEventID)+
               " | Currency="+cur+" | Event="+en+
               " | EventTime="+(et>0?TimeToString(et,TIME_DATE|TIME_MINUTES):"")+
               " | OrderSendCalled=false";
      LogEvent(ev,d);
      TelemetryWrite("RECOVERY_DECISIONS",ev,d,price,volume);
      return false;
     }

   bool sent=false; ResetLastError();
   if(direction>0) sent=trade.Buy(volume,_Symbol,ask,0.0,0.0,"FluxMatrix PRO Recovery Buy");
   else            sent=trade.Sell(volume,_Symbol,bid,0.0,0.0,"FluxMatrix PRO Recovery Sell");
   uint rc=trade.ResultRetcode();
   if(!sent || !TradeRetcodeSuccess(rc))
     {
      gLastOrderFailureTime=TimeCurrent(); gRecoveryArmed=false;
      if(rc==TRADE_RETCODE_TIMEOUT || rc==TRADE_RETCODE_CONNECTION || !(bool)TerminalInfoInteger(TERMINAL_CONNECTED))
         MarkPendingRequest("RECOVERY",positionsBefore);
      LogEvent("RECOVERY_ORDER_FAILED","Retcode="+IntegerToString((int)rc)+" | Comment="+trade.ResultRetcodeDescription()+" | Volume="+DoubleToString(volume,2));
      TelemetryWrite("EXECUTION","ORDERSEND_RESULT","Scope=RECOVERY | Success=false | Retcode="+IntegerToString((int)rc)+" | Comment="+trade.ResultRetcodeDescription(),price,volume);
      return false;
     }

   gRecoveryArmed=false; gRecoveryArmedTime=0; gRecoveryArmedPrice=0.0;
   gExpectedPositions=positionsBefore+1; gOrderSentTime=TimeCurrent();
   RefreshBasketState();
   gBasket.lastRecovery=TimeCurrent();

   gSingleDynamicTrailActive=false;
   gBasketDynamicTrailActive=false;
   UpdateStaticBasketTP();

   CsvEventRow("RECOVERY_ORDER_SENT",(direction>0?"BUY":"SELL"),trade.ResultPrice(),volume,
               "nivel="+IntegerToString(gBasket.recoveryLevel)+" base="+CsvNum(baseLot,2)+" total="+CsvNum(gBasket.totalVolume,2));
   LogEvent("RECOVERY_ORDER_SENT",
            "RecoveryLevel="+IntegerToString(gBasket.recoveryLevel)+
            " | BaseLot="+DoubleToString(baseLot,2)+
            " | Volume="+DoubleToString(volume,2)+
            " | Price="+DoubleToString(trade.ResultPrice(),_Digits)+
            " | TotalVolume="+DoubleToString(gBasket.totalVolume,2)+
            " | Mode=GRID_IMMEDIATE"+
            " | ProjectedMarginLevel="+DoubleToString(pml,2));
   TelemetryWrite("RECOVERY_DECISIONS","RECOVERY_CONFIRMED",
                  "RecoveryLevel="+IntegerToString(gBasket.recoveryLevel)+
                  " | BaseLot="+DoubleToString(baseLot,2)+
                  " | TotalVolume="+DoubleToString(gBasket.totalVolume,2),trade.ResultPrice(),volume);
   SaveState("RECOVERY_CONFIRMED");
   return true;
  }

//+------------------------------------------------------------------+
//| v1.10 - DISTANCIA DO GRID, COM PISO E TETO                        |
//|                                                                   |
//| Motivo da mudanca (logs 27-28/08): com grid fixo de 200 pontos e  |
//| ATR M1 de ~175, cada 1,15 vela dispara um nivel. Um movimento de  |
//| US$ 8-10 numa direcao so - que o ouro faz varias vezes ao dia -   |
//| percorria 5-6 niveis e levava a perda de -3 para -141.            |
//|                                                                   |
//| Refazendo os 85 cestos reais do periodo com o deslocamento de     |
//| preco que de fato ocorreu:                                        |
//|   grid 200 -> MAE medio 11.66 | pior 159.14 | 1 estouro de stop   |
//|   grid 400 -> MAE medio  4.19 | pior  35.02 | 0 estouros          |
//| O cesto que perdeu -155.36 teria parado em 3 pernas e MAE 35.     |
//+------------------------------------------------------------------+
double GetRecoveryDistancePrice(double atr)
  {
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(point<=0.0) return 0.0;

   double dist;
   if(InpRecoveryGridMode==RECOVERY_GRID_ATR && atr>0.0)
      dist=atr*InpGridATRMultiplier;
   else
      dist=InpGridDistancePoints*point;

   if(InpGridMinPoints>0 && dist<InpGridMinPoints*point) dist=InpGridMinPoints*point;
   if(InpGridMaxPoints>0 && dist>InpGridMaxPoints*point) dist=InpGridMaxPoints*point;
   return dist;
  }
void ArmRecoveryIfDistanceReached(double atr)
  {
   if(!gBasket.active) return;
   if(gBasket.recoveryLevel>=InpMaxRecoveryLevels) return;

   double distance=GetRecoveryDistancePrice(atr);
   if(distance<=0.0) return;

   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(ask<=0.0 || bid<=0.0) return;

   int direction=(gBasket.direction==POSITION_TYPE_BUY ? 1 : -1);
   bool reached=
      (direction>0
       ? ask<=gBasket.worstEntry-distance
       : bid>=gBasket.worstEntry+distance);

   if(!reached)
     {
      gRecoveryArmed=false;
      gRecoveryArmedTime=0;
      gRecoveryArmedPrice=0.0;
      return;
     }

   // Extensao isolada: envolve o motor original; nao reescreve Grid/timing.
   string en="",cur=""; datetime et=0,ws=0,we=0;
   ENUM_RECOVERY_NEWS_GUARD_STATE ng=EvaluateRecoveryNewsGuard(false,en,cur,et,ws,we);
   if(ng==REC_NEWS_BLOCKED || ng==REC_NEWS_UNAVAILABLE)
     {
      gRecoveryArmed=false;
      gRecoveryArmedTime=0;
      gRecoveryArmedPrice=0.0;
      gRecoveryNewsNeedsReevaluation=true;
      string ev=(ng==REC_NEWS_BLOCKED ? "RECOVERY_BLOCKED_NEWS_WINDOW" : "RECOVERY_BLOCKED_NEWS_DATA_UNAVAILABLE");
      if(gLastRecoveryNewsBlockLog==0 || (TimeCurrent()-gLastRecoveryNewsBlockLog)>=30)
        {
         gLastRecoveryNewsBlockLog=TimeCurrent();
         string d="RecoveryLevel="+IntegerToString(gBasket.recoveryLevel+1)+
                  " | GridReached=true | EventID="+StringFormat("%I64u",gRecoveryNewsEventID)+
                  " | Currency="+cur+" | Event="+en+
                  " | EventTime="+(et>0?TimeToString(et,TIME_DATE|TIME_MINUTES):"")+
                  " | RecoveryWindowStart="+(ws>0?TimeToString(ws,TIME_DATE|TIME_MINUTES):"")+
                  " | RecoveryWindowEnd="+(we>0?TimeToString(we,TIME_DATE|TIME_MINUTES):"")+
                  " | OrderSendCalled=false";
         LogEvent(ev,d);
         TelemetryWrite("RECOVERY_DECISIONS",ev,d,(direction>0?ask:bid),0.0);
        }
      return;
     }

   if(gRecoveryNewsNeedsReevaluation && (ng==REC_NEWS_CLEAR || ng==REC_NEWS_TESTER_BYPASS))
     {
      gRecoveryNewsNeedsReevaluation=false;
      LogEvent("RECOVERY_REEVALUATION_AFTER_NEWS",
               "RecoveryLevel="+IntegerToString(gBasket.recoveryLevel+1)+
               " | GridReached=true | WorstEntry="+DoubleToString(gBasket.worstEntry,_Digits)+
               " | TriggerPrice="+DoubleToString((direction>0?ask:bid),_Digits));
     }

   string reason="";
   if(!CanAttemptRecovery(direction,atr,reason))
     {
      if(reason!="GRID_NOT_REACHED" &&
         (gLastRecoveryBlockLogTime==0 || (TimeCurrent()-gLastRecoveryBlockLogTime)>=30))
        {
         gLastRecoveryBlockLogTime=TimeCurrent();
         CsvEventRow("RECOVERY_BLOCKED",reason,(direction>0?ask:bid),0.0,
                     "nivel_desejado="+IntegerToString(gBasket.recoveryLevel+1));
         LogEvent("RECOVERY_BLOCKED",
                  "Mode=GRID_IMMEDIATE | Reason="+reason+
                  " | NextLevel="+IntegerToString(gBasket.recoveryLevel+1)+
                  " | WorstEntry="+DoubleToString(gBasket.worstEntry,_Digits)+
                  " | Distance="+DoubleToString(distance,_Digits));
        }
      return;
     }

   gRecoveryArmed=true;
   gRecoveryArmedTime=TimeCurrent();
   gRecoveryArmedPrice=(direction>0 ? ask : bid);

   LogEvent("RECOVERY_GRID_TRIGGERED",
            "Mode=GRID_IMMEDIATE"+
            " | NextLevel="+IntegerToString(gBasket.recoveryLevel+1)+
            " | WorstEntry="+DoubleToString(gBasket.worstEntry,_Digits)+
            " | TriggerPrice="+DoubleToString(gRecoveryArmedPrice,_Digits)+
            " | Distance="+DoubleToString(distance,_Digits)+
            " | GridPontosEfetivo="+DoubleToString(distance/SymbolInfoDouble(_Symbol,SYMBOL_POINT),0)+
            " | ATR="+DoubleToString(atr,_Digits)+
            " | NoFlowGate=true | NoMicroLiquidityGate=true | NoClosedBarWait=true");

   SendRecoveryOrder(direction,atr);
  }

//+------------------------------------------------------------------+
//| Gestao por tick                                                   |
//+------------------------------------------------------------------+
void CheckMonetaryProtections()
  {
   if(!gBasket.active) return;
   if(!(InpUseBasketLossAlert || InpUseRecoveryBlockOnLoss || InpUseBasketLossClosePct ||
        InpUseBasketLossCloseMoney || InpUseBasketMaxAgeClose)) return;

   double loss=gBasket.basketFloatingLoss;
   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   double pct=(bal>0.0 ? loss/bal*100.0 : 0.0);
   double ageH=(gBasket.basketStart>0 ? (double)(TimeCurrent()-gBasket.basketStart)/3600.0 : 0.0);
   string ctx="Loss="+DoubleToString(loss,2)+" | LossPctBalance="+DoubleToString(pct,2)+
              " | AgeHours="+DoubleToString(ageH,2)+" | Legs="+IntegerToString(gBasket.positions)+
              " | Volume="+DoubleToString(gBasket.totalVolume,2);

   if(InpUseBasketLossAlert && !gProtAlerted && pct>=InpBasketLossAlertPct)
     {
      gProtAlerted=true;
      LogEvent("PROTECTION_ALERT",ctx);
      TelemetryWrite("RISK_STATE","PROTECTION_ALERT",ctx);
      if(!(bool)MQLInfoInteger(MQL_TESTER))
         SendNotification(FMX_PRODUCT_NAME+" ALERTA: cesto "+DoubleToString(pct,1)+"% do saldo contra ("+DoubleToString(loss,2)+")");
     }

   if(InpUseRecoveryBlockOnLoss && !gProtBlockRecovery && pct>=InpRecoveryBlockLossPct)
     {
      gProtBlockRecovery=true;
      gRecoveryArmed=false;
      LogEvent("PROTECTION_RECOVERY_BLOCKED",ctx);
      TelemetryWrite("RISK_STATE","PROTECTION_RECOVERY_BLOCKED",ctx);
     }

   string why="";
   if(InpUseBasketLossClosePct && pct>=InpBasketLossClosePct)           why="PROTECAO_PERDA_PCT";
   else if(InpUseBasketLossCloseMoney && loss>=InpBasketLossCloseMoney) why="PROTECAO_PERDA_DINHEIRO";
   else if(InpUseBasketMaxAgeClose && ageH>=InpBasketMaxAgeHours)       why="PROTECAO_IDADE_MAXIMA";
   if(why=="") return;

   if(gProtLastCloseTry>0 && (TimeCurrent()-gProtLastCloseTry)<3) return;
   gProtLastCloseTry=TimeCurrent();
   LogEvent("PROTECTION_CLOSE",ctx+" | Reason="+why);
   TelemetryWrite("RISK_STATE","PROTECTION_CLOSE",ctx+" | Reason="+why);
   CloseAllBasketPositions(why);
   RefreshBasketState();
  }

void ManageOpenBasketTick()
  {
   if(!gBasket.active) return;

   RefreshBasketState();
   if(!gBasket.active) return;

   if(InpForceCloseBeforeSessionEnd && InpForceCloseMinutesBefore>0)
     {
      bool inSess=false; int fOpen=0,tClose=0;
      if(GetSessionBounds(inSess,fOpen,tClose) && inSess &&
         tClose<=InpForceCloseMinutesBefore)
        {
         LogEvent("BASKET_SESSION_CLOSE",
                  "Reason=SESSION_END_IN_"+IntegerToString(tClose)+"MIN"+
                  " | Positions="+IntegerToString(gBasket.positions)+
                  " | Volume="+DoubleToString(gBasket.totalVolume,2)+
                  " | Floating="+DoubleToString(gBasket.basketProfit,2));
         CloseAllBasketPositions("SESSION_END_PROTECTION");
         RefreshBasketState();
         if(!gBasket.active) return;
        }
     }

   CheckMonetaryProtections();
   if(!gBasket.active) return;

   double atr=(ArraySize(gATR)>1 ? gATR[1] : 0.0);

   // Timing original: ao atingir o Grid valido, recovery neste tick.
   if(atr>0.0)
      ArmRecoveryIfDistanceReached(atr);

   RefreshBasketState();
   if(!gBasket.active) return;

   UpdateBasketTP();
   MonitorTakeProfitMoney();   // v2.11: fallback EA-side (so age quando TP broker nao confirmado)
   RefreshBasketState();
   if(!gBasket.active) return;

   if(InpTrailingStopEnabled)
     {
      if(gBasket.positions==1) DoSinglePositionTrailing();
      else                     DoBasketPositionTrailing();
     }
   else
     {
      gSingleDynamicTrailActive=false;
      gBasketDynamicTrailActive=false;
     }
  }

//+------------------------------------------------------------------+
//| Protecoes de preco                                                |
//| CORRECAO B5: agora invalida precos impossiveis em vez de devolver |
//| true cegamente (evitava loop de "invalid stops").                 |
//+------------------------------------------------------------------+
bool AdjustProtectionPrices(int direction,double &sl,double &tp)
  {
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   if(point<=0.0 || bid<=0.0 || ask<=0.0) return false;

   long stopsLevel =(long)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long freezeLevel=(long)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   long guardPoints=(long)MathMax((double)stopsLevel,(double)freezeLevel)+2;
   double guard=guardPoints*point;

   if(direction>0)
     {
      if(sl>0.0)
        {
         double maxSL=bid-guard;
         if(sl>maxSL) sl=maxSL;
         if(sl<=0.0) return false;
        }
      if(tp>0.0)
        {
         double minTP=ask+guard;
         if(tp<minTP) tp=minTP;
        }
     }
   else
     {
      if(sl>0.0)
        {
         double minSL=ask+guard;
         if(sl<minSL) sl=minSL;
        }
      if(tp>0.0)
        {
         double maxTP=bid-guard;
         if(tp>maxTP) tp=maxTP;
         if(tp<=0.0) return false;
        }
     }

   if(sl>0.0) sl=NormalizeDouble(sl,_Digits);
   if(tp>0.0) tp=NormalizeDouble(tp,_Digits);
   return true;
  }

//+------------------------------------------------------------------+
//| v1.08 (D1) - trava de lucro minimo apos o trailing ativar.        |
//+------------------------------------------------------------------+
double ApplyMinLock(int direction,double desiredSL,double reference,double point,int lockPoints)
  {
   if(lockPoints<=0 || reference<=0.0 || point<=0.0) return desiredSL;
   double lock=(direction>0
                ? reference+lockPoints*point
                : reference-lockPoints*point);
   return (direction>0 ? MathMax(desiredSL,lock) : MathMin(desiredSL,lock));
  }

//+------------------------------------------------------------------+
//| CORRECAO B4 - modificacao com log de falha (antes: silenciosa)    |
//+------------------------------------------------------------------+
bool SafePositionModify(ulong ticket,double sl,double tp,string scope)
  {
   ResetLastError();
   if(trade.PositionModify(ticket,sl,tp)) return true;

   uint rc=trade.ResultRetcode();

   // 10036 = position closed. Acontece quando o TP e' atingido no mesmo
   // instante em que o loop tenta reescrever a ordem. Nao custa nada e
   // nao e' falha: so nao vale poluir o log.
   if(rc==10036) return false;

   if(gLastTPFailLogTime==0 || (TimeCurrent()-gLastTPFailLogTime)>=30)
     {
      gLastTPFailLogTime=TimeCurrent();
      LogEvent("POSITION_MODIFY_FAILED",
               "Scope="+scope+
               " | Ticket="+StringFormat("%I64u",ticket)+
               " | SL="+DoubleToString(sl,_Digits)+
               " | TP="+DoubleToString(tp,_Digits)+
               " | Retcode="+IntegerToString((int)rc)+
               " | Comment="+trade.ResultRetcodeDescription()+
               " | LastError="+IntegerToString(GetLastError()));
     }
   return false;
  }
void UpdateBasketTP()
  {
   if(!gBasket.active) return;
   if(!InpTakeProfitEnabled)
     {
      ClearOwnedTakeProfits();
      return;
     }
   UpdateStaticBasketTP();
  }

//+------------------------------------------------------------------+
//| UpdateStaticBasketTP                                              |
//| CORRECAO B3: aplica stops level e loga falhas.                    |
//+------------------------------------------------------------------+
void UpdateStaticBasketTP()
  {
   if(!gBasket.active || gBasket.totalVolume<=0.0 || gBasket.averagePrice<=0.0) return;
   if(!InpTakeProfitEnabled) return;

   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT); if(point<=0.0) return;
   int direction=(gBasket.direction==POSITION_TYPE_BUY ? 1 : -1);
   double target=0.0;

   if(InpTakeProfitUnit==TAKE_PROFIT_POINTS)
     {
      int tpPoints=(gBasket.positions==1 ? InpInitialTakeProfitPoints : InpBasketTakeProfitPoints);
      if(tpPoints<=0) return;
      // Paridade: mesma matematica da baseline LiquidityFlow.
      target=(direction>0
              ? gBasket.averagePrice+tpPoints*point
              : gBasket.averagePrice-tpPoints*point);
     }
   else
     {
      double targetMoney=ActiveTakeProfitMoneyTarget();
      double projected=0.0,diff=0.0; string solveReason="";
      if(targetMoney<=0.0) return;
      if(!SolveBasketTPMoney(targetMoney,target,projected,diff,solveReason))
        {
         gTPMoneySolverOk=false;
         gTPMoneyMonitorOnly=true;
         if(gLastTPMoneySolverFailLog==0 || (TimeCurrent()-gLastTPMoneySolverFailLog)>=30)
           {
            gLastTPMoneySolverFailLog=TimeCurrent();
            LogEvent("TP_MONEY_SOLVER_FAILED",
                     "Scope="+(gBasket.positions==1?"SINGLE":"BASKET")+
                     " | TargetMoney="+DoubleToString(targetMoney,2)+
                     " | Reason="+solveReason+
                     " | MonitorEASide=true");
           }
         return;
        }
      gTPMoneySolverOk=true;
      gTPMoneyMonitorOnly=false;
      gResolvedTPMoneyTarget=targetMoney;
      gResolvedTPMoneyProjected=projected;
      gResolvedTPMoneyDifference=diff;
      gTPMoneyResolvedPositions=gBasket.positions;
     }

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i); if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;

      ulong ticket=(ulong)PositionGetInteger(POSITION_TICKET);
      double currentTP=PositionGetDouble(POSITION_TP);
      double currentSL=PositionGetDouble(POSITION_SL);

      double newSL=currentSL;
      if(gBasket.positions>1 && currentSL!=0.0 && !gBasketDynamicTrailActive) newSL=0.0;

      double newTP=target;
      double slForCheck=newSL;
      if(!AdjustProtectionPrices(direction,slForCheck,newTP))
        {
         if(InpTakeProfitUnit==TAKE_PROFIT_MONEY)
           {
            if(!gTPMoneyMonitorOnly)
               LogEvent("TP_MONEY_MONITOR_ONLY","Reason=ADJUST_PROTECTION_FAILED | MonitorEASide=true");
            gTPMoneyMonitorOnly=true;
           }
         continue;
        }
      newSL=slForCheck;

      bool need=(MathAbs(currentTP-newTP)>point || MathAbs(newSL-currentSL)>0.0);
      if(!need) continue;

      if(SafePositionModify(ticket,newSL,newTP,(InpTakeProfitUnit==TAKE_PROFIT_MONEY?"TP_MONEY":"STATIC_TP")))
        {
         gLastKnownBasketTP=newTP;
         if(InpVerboseLogs)
            LogEvent(InpTakeProfitUnit==TAKE_PROFIT_MONEY?"TP_MONEY_UPDATED":"BASKET_TP_UPDATED",
                     "Ticket="+StringFormat("%I64u",ticket)+
                     " | TP="+DoubleToString(newTP,_Digits)+
                     " | AvgPrice="+DoubleToString(gBasket.averagePrice,_Digits));
        }
     }
  }

string TakeProfitUnitToString()
  {
   if(!InpTakeProfitEnabled) return "OFF";
   return (InpTakeProfitUnit==TAKE_PROFIT_MONEY ? "MONEY" : "POINTS");
  }

double ActiveTakeProfitMoneyTarget()
  {
   if(!InpTakeProfitEnabled || InpTakeProfitUnit!=TAKE_PROFIT_MONEY) return 0.0;
   return (gBasket.positions<=1 ? InpInitialTakeProfitMoney : InpBasketTakeProfitMoney);
  }

bool ProjectOwnedProfitAtPrice(double targetPrice,double &projectedProfit,string &reason)
  {
   projectedProfit=0.0; reason="";
   int owned=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i); if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      ENUM_POSITION_TYPE pt=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ENUM_ORDER_TYPE ot=(pt==POSITION_TYPE_BUY?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
      double vol=PositionGetDouble(POSITION_VOLUME);
      double open=PositionGetDouble(POSITION_PRICE_OPEN);
      double pcalc=0.0; ResetLastError();
      if(!OrderCalcProfit(ot,_Symbol,vol,open,targetPrice,pcalc))
        { reason="ORDERCALCPROFIT_FAILED_"+IntegerToString(GetLastError()); return false; }
      projectedProfit+=pcalc; owned++;
     }
   if(owned<=0) { reason="NO_OWNED_POSITIONS"; return false; }
   return true;
  }

bool SolveSingleTPMoney(int direction,double volume,double openPrice,double targetMoney,double &solvedPrice,double &projectedProfit,double &difference,string &reason)
  {
   solvedPrice=0.0; projectedProfit=0.0; difference=0.0; reason="";
   if(volume<=0.0 || openPrice<=0.0 || targetMoney<=0.0) { reason="INVALID_INPUT"; return false; }
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(point<=0.0 || tick<=0.0) { reason="INVALID_SYMBOL_PRICE_STEP"; return false; }
   if(tickValue<=0.0) { reason="INVALID_TICK_VALUE"; return false; }
   ENUM_ORDER_TYPE type=(direction>0?ORDER_TYPE_BUY:ORDER_TYPE_SELL);

   double lo=openPrice,hi=openPrice,span=MathMax(100.0*point,tick); bool bracket=false;
   for(int k=0;k<40;k++)
     {
      double candidate=(direction>0?openPrice+span:openPrice-span);
      if(candidate<=tick) { reason="PRICE_BOUND_EXHAUSTED"; return false; }
      candidate=NormalizePriceToTick(candidate);
      double pc=0.0; ResetLastError();
      if(!OrderCalcProfit(type,_Symbol,volume,openPrice,candidate,pc))
        { reason="ORDERCALCPROFIT_FAILED_"+IntegerToString(GetLastError()); return false; }
      if(pc>=targetMoney) { if(direction>0) hi=candidate; else lo=candidate; bracket=true; break; }
      if(direction>0) lo=candidate; else hi=candidate;
      span*=2.0;
     }
   if(!bracket) { reason="TARGET_NOT_BRACKETED"; return false; }

   for(int k=0;k<60;k++)
     {
      if(MathAbs(hi-lo)<=tick) break;
      double mid=NormalizePriceToTick((lo+hi)/2.0),pc=0.0;
      if(!OrderCalcProfit(type,_Symbol,volume,openPrice,mid,pc))
        { reason="ORDERCALCPROFIT_FAILED_"+IntegerToString(GetLastError()); return false; }
      if(direction>0) { if(pc>=targetMoney) hi=mid; else lo=mid; }
      else            { if(pc>=targetMoney) lo=mid; else hi=mid; }
     }
   solvedPrice=NormalizePriceToTick(direction>0?hi:lo);
   if(!OrderCalcProfit(type,_Symbol,volume,openPrice,solvedPrice,projectedProfit))
     { reason="ORDERCALCPROFIT_FINAL_FAILED_"+IntegerToString(GetLastError()); return false; }
   difference=projectedProfit-targetMoney;
   return true;
  }

bool SolveBasketTPMoney(double targetMoney,double &solvedPrice,double &projectedProfit,double &difference,string &reason)
  {
   solvedPrice=0.0; projectedProfit=0.0; difference=0.0; reason="";
   if(!gBasket.active || gBasket.totalVolume<=0.0 || gBasket.averagePrice<=0.0 || targetMoney<=0.0)
     { reason="INVALID_BASKET_OR_TARGET"; return false; }
   int direction=(gBasket.direction==POSITION_TYPE_BUY?1:-1);
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT),tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(point<=0.0 || tick<=0.0) { reason="INVALID_SYMBOL_PRICE_STEP"; return false; }
   if(tickValue<=0.0) { reason="INVALID_TICK_VALUE"; return false; }

   double lo=gBasket.averagePrice,hi=gBasket.averagePrice,span=MathMax(100.0*point,tick); bool bracket=false;
   for(int k=0;k<40;k++)
     {
      double candidate=(direction>0?gBasket.averagePrice+span:gBasket.averagePrice-span);
      if(candidate<=tick) { reason="PRICE_BOUND_EXHAUSTED"; return false; }
      candidate=NormalizePriceToTick(candidate);
      double pc=0.0; string rr="";
      if(!ProjectOwnedProfitAtPrice(candidate,pc,rr)) { reason=rr; return false; }
      if(pc>=targetMoney) { if(direction>0) hi=candidate; else lo=candidate; bracket=true; break; }
      if(direction>0) lo=candidate; else hi=candidate;
      span*=2.0;
     }
   if(!bracket) { reason="TARGET_NOT_BRACKETED"; return false; }
   for(int k=0;k<60;k++)
     {
      if(MathAbs(hi-lo)<=tick) break;
      double mid=NormalizePriceToTick((lo+hi)/2.0),pc=0.0; string rr="";
      if(!ProjectOwnedProfitAtPrice(mid,pc,rr)) { reason=rr; return false; }
      if(direction>0) { if(pc>=targetMoney) hi=mid; else lo=mid; }
      else            { if(pc>=targetMoney) lo=mid; else hi=mid; }
     }
   solvedPrice=NormalizePriceToTick(direction>0?hi:lo);
   if(!ProjectOwnedProfitAtPrice(solvedPrice,projectedProfit,reason)) return false;
   difference=projectedProfit-targetMoney;
   return true;
  }

void MonitorTakeProfitMoney()
  {
   if(!gBasket.active || !InpTakeProfitEnabled || InpTakeProfitUnit!=TAKE_PROFIT_MONEY) return;
   double target=ActiveTakeProfitMoneyTarget(); if(target<=0.0) return;
   // Broker-side e autoridade preferida; EA-side fecha somente quando a protecao nao esta confirmada.
   if(!gTPMoneyMonitorOnly && gTPMoneySolverOk && gLastKnownBasketTP>0.0) return;
   if(gBasket.basketProfit>=target)
     {
      string det="TargetMoney="+DoubleToString(target,2)+" | Floating="+DoubleToString(gBasket.basketProfit,2)+
                 " | SolvedPrice="+DoubleToString(gLastKnownBasketTP,_Digits)+" | MonitorOnly=true";
      LogEvent("TAKE_PROFIT_MONEY_TRIGGERED",det);
      TelemetryWrite("POSITION_MANAGEMENT","TAKE_PROFIT_MONEY_TRIGGERED",det);
      gExitReasonHint="TAKE_PROFIT_MONEY";
      CloseAllBasketPositions("TAKE_PROFIT_MONEY");
     }
  }



void ClearOwnedTakeProfits()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i);
      if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;

      ulong ticket=(ulong)PositionGetInteger(POSITION_TICKET);
      double currentTP=PositionGetDouble(POSITION_TP);
      if(currentTP<=0.0) continue;

      double currentSL=PositionGetDouble(POSITION_SL);
      SafePositionModify(ticket,currentSL,0.0,"TP_DISABLED");
     }
   gLastKnownBasketTP=0.0;
  }

//+------------------------------------------------------------------+
//| Trailing da posicao unica                                         |
//+------------------------------------------------------------------+
void DoSinglePositionTrailing()
  {
   if(!gBasket.active || gBasket.positions!=1 || !InpTrailingStopEnabled) return;

   gBasketDynamicTrailActive=false;

   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   if(point<=0.0 || bid<=0.0 || ask<=0.0) return;

   int direction=(gBasket.direction==POSITION_TYPE_BUY ? 1 : -1);
   double favorablePoints=(direction>0 ?
                           (bid-gBasket.averagePrice)/point :
                           (gBasket.averagePrice-ask)/point);

   int actPts =InpTrailingActivationPoints;
   int distPts=InpTrailingDistancePoints;
   int stepPts=InpTrailingStepPoints;
   int lockPts=InpTrailingMinLockPoints;

   if(InpTrailingUnit==TRAILING_MONEY)
     {
      actPts =(int)MathRound(MoneyToPoints(InpTrailingActivationMoney));
      distPts=(int)MathRound(MoneyToPoints(InpTrailingDistanceMoney));
      stepPts=(int)MathRound(MoneyToPoints(InpTrailingStepMoney));
      lockPts=(int)MathRound(MoneyToPoints(InpTrailingMinLockMoney));
      if(actPts<1 || distPts<1) return;
      if(distPts<InpTrailMinDistancePoints) distPts=InpTrailMinDistancePoints;
      int minStep=(int)MathMax(3.0,(double)distPts/10.0);
      if(stepPts<minStep) stepPts=minStep;
     }

   if(!gSingleDynamicTrailActive)
     {
      if(favorablePoints<actPts) return;

      gSingleDynamicTrailActive=true;
      LogEvent("PROFIT_TRAIL_ACTIVATED",
               "Scope=SINGLE"+
               " | Unit="+(InpTrailingUnit==TRAILING_MONEY?"MONEY":"POINTS")+
               " | FavorablePoints="+DoubleToString(favorablePoints,1)+
               " | FloatingMoney="+DoubleToString(gBasket.basketProfit,2)+
               " | Activation="+IntegerToString(actPts)+
               " | TrailDistance="+IntegerToString(distPts)+
               " | MinLock="+IntegerToString(lockPts)+
               " | MoneyPerPoint="+DoubleToString(MoneyPerPoint(),4)+
               " | DistanciaEfetivaMoney="+DoubleToString(distPts*MoneyPerPoint(),2)+
               " | PassoEfetivoMoney="+DoubleToString(stepPts*MoneyPerPoint(),2));
      SaveState("TRAILING_ACTIVATED");
     }

   double desiredSL=(direction>0 ? bid-distPts*point : ask+distPts*point);
   desiredSL=ApplyMinLock(direction,desiredSL,gBasket.averagePrice,point,lockPts);

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i);
      if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;

      ulong ticket=(ulong)PositionGetInteger(POSITION_TICKET);
      double currentSL=PositionGetDouble(POSITION_SL);
      double currentTP=PositionGetDouble(POSITION_TP);

      double newSL=desiredSL;
      double newTP=currentTP; // TP nao e' autoridade do trailing.

      if(direction>0)
        {
         if(currentSL>0.0) newSL=MathMax(newSL,currentSL);
        }
      else
        {
         if(currentSL>0.0) newSL=MathMin(newSL,currentSL);
        }

      if(!AdjustProtectionPrices(direction,newSL,newTP)) continue;

      double step=stepPts*point;
      bool slStep=(direction>0 ?
                   (currentSL==0.0 || newSL>=currentSL+step) :
                   (currentSL==0.0 || newSL<=currentSL-step));
      if(!slStep) continue;

      if(SafePositionModify(ticket,newSL,newTP,"SINGLE_TRAIL"))
        {
         gLastKnownBasketTP=newTP;
         gTrailingFloorPrice=newSL;
         LogEvent("DYNAMIC_TRAILING_UPDATED",
                  "Scope=SINGLE"+
                  " | Ticket="+StringFormat("%I64u",ticket)+
                  " | SL="+DoubleToString(newSL,_Digits)+
                  " | TP="+DoubleToString(newTP,_Digits)+
                  " | FavorablePoints="+DoubleToString(favorablePoints,1));
         SaveState("TRAILING_UPDATED");
        }
     }
  }



//+------------------------------------------------------------------+
//| Trailing do cesto                                                 |
//+------------------------------------------------------------------+
void DoBasketPositionTrailing()
  {
   if(!gBasket.active || gBasket.positions<=1 || !InpTrailingStopEnabled) return;

   gSingleDynamicTrailActive=false;

   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   if(point<=0.0 || bid<=0.0 || ask<=0.0) return;

   int direction=(gBasket.direction==POSITION_TYPE_BUY ? 1 : -1);
   double favorablePoints=(direction>0 ?
                           (bid-gBasket.averagePrice)/point :
                           (gBasket.averagePrice-ask)/point);

   int actPts =InpBasketTrailingActivationPoints;
   int distPts=InpBasketTrailingDistancePoints;
   int stepPts=InpBasketTrailingStepPoints;
   int lockPts=InpBasketTrailingMinLockPoints;

   if(InpTrailingUnit==TRAILING_MONEY)
     {
      actPts =(int)MathRound(MoneyToPoints(InpBasketTrailingActivationMoney));
      distPts=(int)MathRound(MoneyToPoints(InpBasketTrailingDistanceMoney));
      stepPts=(int)MathRound(MoneyToPoints(InpBasketTrailingStepMoney));
      lockPts=(int)MathRound(MoneyToPoints(InpBasketTrailingMinLockMoney));
      if(actPts<1 || distPts<1) return;
      if(distPts<InpTrailMinDistancePoints) distPts=InpTrailMinDistancePoints;
      int minStep=(int)MathMax(3.0,(double)distPts/10.0);
      if(stepPts<minStep) stepPts=minStep;
     }

   if(!gBasketDynamicTrailActive)
     {
      if(favorablePoints<actPts) return;

      gBasketDynamicTrailActive=true;
      LogEvent("BASKET_PROFIT_TRAIL_ACTIVATED",
               "Unit="+(InpTrailingUnit==TRAILING_MONEY?"MONEY":"POINTS")+
               " | FavorablePoints="+DoubleToString(favorablePoints,1)+
               " | FloatingMoney="+DoubleToString(gBasket.basketProfit,2)+
               " | Activation="+IntegerToString(actPts)+
               " | TrailDistance="+IntegerToString(distPts)+
               " | MinLock="+IntegerToString(lockPts)+
               " | MoneyPerPoint="+DoubleToString(MoneyPerPoint(),4)+
               " | DistanciaEfetivaMoney="+DoubleToString(distPts*MoneyPerPoint(),2)+
               " | PassoEfetivoMoney="+DoubleToString(stepPts*MoneyPerPoint(),2)+
               " | Positions="+IntegerToString(gBasket.positions)+
               " | Volume="+DoubleToString(gBasket.totalVolume,2));
      SaveState("TRAILING_ACTIVATED");
     }

   double desiredSL=(direction>0 ? bid-distPts*point : ask+distPts*point);
   desiredSL=ApplyMinLock(direction,desiredSL,gBasket.averagePrice,point,lockPts);

   bool modified=false;
   double panelTP=gLastKnownBasketTP;
   double loggedSL=desiredSL;

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i);
      if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;

      ulong ticket=(ulong)PositionGetInteger(POSITION_TICKET);
      double currentSL=PositionGetDouble(POSITION_SL);
      double currentTP=PositionGetDouble(POSITION_TP);

      double newSL=desiredSL;
      double newTP=currentTP;

      if(direction>0)
        {
         if(currentSL>0.0) newSL=MathMax(newSL,currentSL);
        }
      else
        {
         if(currentSL>0.0) newSL=MathMin(newSL,currentSL);
        }

      if(!AdjustProtectionPrices(direction,newSL,newTP)) continue;

      double step=stepPts*point;
      bool slStep=(direction>0 ?
                   (currentSL==0.0 || newSL>=currentSL+step) :
                   (currentSL==0.0 || newSL<=currentSL-step));
      if(!slStep) continue;

      if(SafePositionModify(ticket,newSL,newTP,"BASKET_TRAIL"))
        {
         modified=true;
         panelTP=newTP;
         loggedSL=newSL;
        }
     }

   if(modified)
     {
      gLastKnownBasketTP=panelTP;
      gTrailingFloorPrice=loggedSL;
      LogEvent("DYNAMIC_TRAILING_UPDATED",
               "Scope=BASKET"+
               " | CommonSL="+DoubleToString(loggedSL,_Digits)+
               " | TP="+DoubleToString(panelTP,_Digits)+
               " | FavorablePoints="+DoubleToString(favorablePoints,1)+
               " | Positions="+IntegerToString(gBasket.positions));
      SaveState("TRAILING_UPDATED");
     }
  }

void CloseAllBasketPositions(string reason)
  {
   gExitReasonHint=reason;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i); if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      ulong ticket=(ulong)PositionGetInteger(POSITION_TICKET);
      ResetLastError();
      if(!trade.PositionClose(ticket,InpDeviationPoints))
         LogEvent("BASKET_CLOSE_FAILED",
                  "Ticket="+StringFormat("%I64u",ticket)+
                  " | Retcode="+IntegerToString((int)trade.ResultRetcode())+
                  " | Comment="+trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Estado                                                            |
//+------------------------------------------------------------------+
void UpdateState()
  {
   if(gBasket.active)
     {
      if(gRecoveryReconciliation)
        { gState=STATE_RECONCILIATION; return; }
      if(gRecoveryArmed)
        {
         gState=(gBasket.direction==POSITION_TYPE_BUY?STATE_RECOVERY_ARMED_BUY:STATE_RECOVERY_ARMED_SELL);
         return;
        }
      gState=(gBasket.positions<=1
              ? (gBasket.direction==POSITION_TYPE_BUY?STATE_SINGLE_BUY:STATE_SINGLE_SELL)
              : (gBasket.direction==POSITION_TYPE_BUY?STATE_BASKET_BUY:STATE_BASKET_SELL));
      return;
     }

   if(gDailyTargetLock) { gState=STATE_DAILY_TARGET_LOCK; return; }
   if(!gStartupReconciled || gRecoveryReconciliation) { gState=STATE_RECONCILIATION; return; }

   string sessReason="";
   if(!IsSessionWindowAllowed(sessReason)) { gState=STATE_SESSION_LOCK; return; }
   string opReason="";
   if(!IsOperationalWindowAllowed(opReason)) { gState=STATE_OPERATIONAL_WINDOW_LOCK; return; }
   string nn="",nc=""; datetime nt=0;
   if(IsNewsBlocked(nn,nc,nt)) { gState=STATE_NEWS_LOCK; return; }
   gState=STATE_FLAT;
  }
string StateToString(ENUM_EA_STATE state)
  {
   switch(state)
     {
      case STATE_INIT:                    return "INIT";
      case STATE_FLAT:                    return "FLAT";
      case STATE_NEWS_LOCK:               return "NEWS_LOCK";
      case STATE_DAILY_TARGET_LOCK:       return "DAILY_TARGET_LOCK";
      case STATE_SINGLE_BUY:              return "SINGLE_BUY";
      case STATE_SINGLE_SELL:             return "SINGLE_SELL";
      case STATE_BASKET_BUY:              return "BASKET_BUY";
      case STATE_BASKET_SELL:             return "BASKET_SELL";
      case STATE_RECOVERY_ARMED_BUY:      return "RECOVERY_ARMED_BUY";
      case STATE_RECOVERY_ARMED_SELL:     return "RECOVERY_ARMED_SELL";
      case STATE_RECOVERY_BLOCKED:        return "RECOVERY_BLOCKED";
      case STATE_SESSION_LOCK:            return "BROKER_SESSION_LOCK";
      case STATE_OPERATIONAL_WINDOW_LOCK: return "OPERATIONAL_WINDOW_LOCK";
      case STATE_RECONCILIATION:          return "RECONCILIATION";
     }
   return "UNKNOWN";
  }

void LogEvent(string event,string extra="")
  {
   // Logging textual is intentionally file-I/O free.  CSV telemetry is
   // emitted explicitly after trading-critical actions, so observability
   // cannot delay Signal/Recovery/OrderSend compared with LiquidityFlow.
   string base=FMX_PRODUCT_NAME+" | EVENT="+event+
               " | State="+StateToString(gState)+
               " | Symbol="+_Symbol+
               " | Magic="+IntegerToString((int)InpMagicNumber)+
               " | RunID="+gRunID+
               " | ConfigHash="+gConfigHash;
   if(extra!="") base+=" | "+extra;
   Print(base);
  }

string ProfitRunnerPanelText()
  {
   if(!InpTrailingStopEnabled) return "OFF";
   if(gBasketDynamicTrailActive) return "BASKET ATIVO";
   if(gSingleDynamicTrailActive) return "SINGLE ATIVO";
   if(gBasket.active)
      return (gBasket.positions>1 ? "BASKET PRONTO" : "SINGLE PRONTO");
   return "PRONTO";
  }

//+------------------------------------------------------------------+
//|                    PAINEL v1.08                                   |
//|  Primitivas de desenho + motor de diagnostico operacional         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| v1.08 - TEMAS DO PAINEL                                           |
//|                                                                   |
//| PRICE: gradiente termico dourado -> laranja -> vermelho.          |
//| A leitura continua univoca porque a TEMPERATURA carrega o         |
//| significado: quanto mais quente, pior. Dourado = a favor,         |
//| laranja = aguardando/atencao, vermelho = contra/bloqueado.        |
//+------------------------------------------------------------------+
void ApplyPanelTheme()
  {
   switch(InpPanelTheme)
     {
      case PANEL_THEME_CYAN:
         gcBg      = C'11,13,17';
         gcCard    = C'19,22,29';
         gcCardAlt = C'24,28,36';
         gcLine    = C'40,46,58';
         gcTxt     = C'226,232,242';
         gcMuted   = C'112,124,145';
         gcUp      = C'0,224,150';
         gcWarn    = C'255,186,64';
         gcDown    = C'255,86,102';
         gcAccent  = C'0,214,255';
         gcAccentDk= C'0,64,80';
         break;

      case PANEL_THEME_CUSTOM:
         gcBg      = C'11,13,17';
         gcCard    = C'19,22,29';
         gcCardAlt = C'24,28,36';
         gcLine    = C'40,46,58';
         gcTxt     = C'226,232,242';
         gcMuted   = C'112,124,145';
         gcUp      = C'0,224,150';
         gcWarn    = C'255,186,64';
         gcDown    = C'255,86,102';
         gcAccent  = InpCustomAccent;
         gcAccentDk= C'40,46,58';
         break;

      case PANEL_THEME_PRICE:
         gcBg      = C'13,9,6';
         gcCard    = C'23,16,10';
         gcCardAlt = C'30,21,13';
         gcLine    = C'58,42,24';
         gcTxt     = C'242,232,220';
         gcMuted   = C'138,122,102';
         gcUp      = C'255,200,69';
         gcWarn    = C'255,138,0';
         gcDown    = C'255,45,63';
         gcAccent  = C'255,107,0';
         gcAccentDk= C'82,38,8';
         break;

      case PANEL_THEME_GRAPHITE:
         gcBg      = C'10,10,11';      // preto
         gcCard    = C'22,22,24';
         gcCardAlt = C'32,32,35';
         gcLine    = C'58,58,62';
         gcTxt     = C'232,232,236';
         gcMuted   = C'128,128,134';
         // Estrutura toda em cinza. O vermelho fica SO no negativo:
         // num painel de risco a perda precisa saltar - se ela ficar
         // cinza como o resto, o painel deixa de avisar.
         gcUp      = C'240,240,244';   // branco  - a favor
         gcWarn    = C'160,160,166';   // cinza   - aguardando
         gcDown    = C'255,77,90';     // vermelho- contra
         gcAccent  = C'186,186,194';   // cinza claro de destaque
         gcAccentDk= C'52,52,56';
         break;

      default:  // PANEL_THEME_PDA - identico ao PDA XAUUSD M5 v2
         gcBg      = C'10,13,16';
         gcCard    = C'17,22,26';
         gcCardAlt = C'23,30,35';
         gcLine    = C'44,56,62';
         gcTxt     = C'224,232,236';
         gcMuted   = C'120,138,146';
         gcUp      = C'50,205,50';     // clrLimeGreen - identidade PDA
         gcWarn    = C'230,168,60';
         gcDown    = C'255,99,71';     // clrTomato
         gcAccent  = C'50,205,50';
         gcAccentDk= C'26,84,26';
         break;
     }
  }

color PanelLevelColor(int level)
  {
   switch(level)
     {
      case 3:  return gcUp;              // pronto / operando bem
      case 2:  return gcDown;            // bloqueado
      case 1:  return gcWarn;            // aguardando condicao
     }
   return gcAccent;
  }

string PtsText(double pts)
  {
   if(pts<0.0) pts=0.0;
   return DoubleToString(pts,0)+"p";
  }

string MoneyText(double v)
  {
   return (v>0.0 ? "+" : "")+DoubleToString(v,2);
  }

void PanelRect(string name,int x,int y,int w,int h,color bg,color border)
  {
   string n=PFX+name;
   if(ObjectFind(0,n)<0)
     {
      if(!ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0))
        {
         gUiDegraded=true;
         return;
        }
     }

   if(w<1) w=1;
   if(h<1) h=1;

   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,n,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,n,OBJPROP_COLOR,border);
   ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,n,OBJPROP_BACK,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,0);
  }

void PanelText(string name,string text,int x,int y,int size,color clr,string font,ENUM_ANCHOR_POINT anchor)
  {
   string n=PFX+name;
   bool created=(ObjectFind(0,n)<0);
   if(created)
     {
      if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0))
        {
         gUiDegraded=true;
         return;
        }
     }

   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,1);

   if(created || ObjectGetString(0,n,OBJPROP_FONT)!=font)
      ObjectSetString(0,n,OBJPROP_FONT,font);
   if(created || ObjectGetString(0,n,OBJPROP_TEXT)!=text)
      ObjectSetString(0,n,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| v1.08 - botao clicavel (unico objeto do painel que recebe clique) |
//| OBJ_BUTTON e' o unico tipo que dispara CHARTEVENT_OBJECT_CLICK    |
//| de forma confiavel no MT5.                                        |
//+------------------------------------------------------------------+
void PanelButton(string name,string text,int x,int y,int w,int h,int size,color txtClr,color bdClr,color bgClr)
  {
   string n=PFX+name;
   bool created=(ObjectFind(0,n)<0);
   if(created)
     {
      if(!ObjectCreate(0,n,OBJ_BUTTON,0,0,0))
        {
         gUiDegraded=true;
         return;
        }
     }

   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bgClr);
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,bdClr);
   ObjectSetInteger(0,n,OBJPROP_COLOR,txtClr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,n,OBJPROP_STATE,false);
   ObjectSetInteger(0,n,OBJPROP_BACK,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,2);
   if(created || ObjectGetString(0,n,OBJPROP_FONT)!=FONT_UI_B)
      ObjectSetString(0,n,OBJPROP_FONT,FONT_UI_B);
   if(created || ObjectGetString(0,n,OBJPROP_TEXT)!=text)
      ObjectSetString(0,n,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| v1.08 - RELOGIOS                                                  |
//|                                                                   |
//| TimeTradeServer() = hora do servidor de trade, calculada pelo     |
//|   terminal. Continua correndo com o mercado fechado.              |
//| TimeCurrent()     = hora do ULTIMO TICK. Congela fora do pregao,  |
//|   por isso NAO serve para relogio.                                |
//| TimeLocal()       = hora do PC.                                   |
//|                                                                   |
//| No Strategy Tester TimeLocal() acompanha o tempo simulado, entao  |
//| o delta aparece como 0. Isso e' comportamento do tester, nao erro.|
//+------------------------------------------------------------------+
int ServerLocalDeltaMinutes()
  {
   datetime srv=TimeTradeServer();
   if(srv<=0) srv=TimeCurrent();
   datetime loc=TimeLocal();
   if(srv<=0 || loc<=0) return 0;
   return (int)MathRound((double)((long)srv-(long)loc)/60.0);
  }

string DeltaHoursText(int deltaMin)
  {
   string sign=(deltaMin<0 ? "-" : "+");
   int a=(int)MathAbs((double)deltaMin);
   int h=a/60, m=a%60;
   if(m==0) return sign+IntegerToString(h)+"h";
   return sign+IntegerToString(h)+"h"+StringFormat("%02d",m);
  }

// Hora LOCAL em que a meia-noite do servidor acontece, ou seja, o
// momento em que o contador diario do EA zera.
string DayRolloverLocalText(int deltaMin)
  {
   int day=24*60;
   int v=((day-deltaMin)%day+day)%day;
   return StringFormat("%02d:%02d",v/60,v%60);
  }

//+------------------------------------------------------------------+
//| Redesenha SOMENTE os relogios.                                    |
//| Chamado tambem por OnTimer: sem isto o relogio congelaria quando  |
//| nao chegam ticks (fim de semana, mercado fechado).                |
//+------------------------------------------------------------------+
void UpdateClock()
  {
   if(!InpShowPanel) return;
   gPanelForceRedraw=true;
  }

//+------------------------------------------------------------------+
//| Alterna recolhido / expandido.                                    |
//| FULL e MIN usam grupos persistentes separados; apenas a visibilidade|
//| e' alternada para evitar churn de objetos no grafico.             |
//+------------------------------------------------------------------+
void TogglePanelMinimized()
  {
   gPanelMinimized=!gPanelMinimized;
   gPanelForceRedraw=true;
   UpdatePanel();
   ChartRedraw(0);
  }


void SetPanelGroupVisible(string groupPrefix,bool visible)
  {
   string prefix=PFX+groupPrefix;
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,prefix)!=0) continue;
      ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(visible ? OBJ_ALL_PERIODS : 0));
     }
  }
// Barra de progresso: trilho + preenchimento proporcional (0..100).
void PanelBar(string name,int x,int y,int w,int h,double pct,color fill,color track)
  {
   if(pct<0.0)   pct=0.0;
   if(pct>100.0) pct=100.0;
   PanelRect(name+"_T",x,y,w,h,track,track);

   int fw=(int)MathRound(w*pct/100.0);
   if(fw<1)
     {
      // sem progresso: preenchimento invisivel (mesma cor do trilho)
      PanelRect(name+"_F",x,y,1,h,track,track);
      return;
     }
   if(fw>w) fw=w;
   PanelRect(name+"_F",x,y,fw,h,fill,fill);
  }

// Linha "rotulo .......... valor" com valor alinhado a direita.
void PanelRow(string id,string caption,string value,int x,int y,int wRight,color valueClr)
  {
   PanelText(id+"_C",caption,x,y,8,gcMuted,FONT_UI,ANCHOR_LEFT_UPPER);
   PanelText(id+"_V",value,x+wRight,y-1,9,valueClr,FONT_MONO,ANCHOR_RIGHT_UPPER);
  }

// Titulo de secao: no padrao PDA ele usa a cor de destaque e peso
// semibold - e' o que separa visualmente os blocos sem precisar de
// mais linhas horizontais.
void PanelSection(string id,string txt,int x,int y)
  {
   PanelText(id,txt,x,y,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
  }

color PanelPLColor(double v)
  {
   if(v> 1e-8) return gcUp;
   if(v<-1e-8) return gcDown;
   return gcMuted;
  }

//+------------------------------------------------------------------+
//| MOTOR DE DIAGNOSTICO - parte de barra fechada (1x por vela)       |
//| Explica exatamente qual condicao de entrada esta faltando.        |
//+------------------------------------------------------------------+
void RunSetupDiagnosisFromSnapshot()
  {
   if(!gSnap.valid) return;
   LiquidityContext bl,sl;
   bl.valid=(gSnap.liqBuyScore>0.0);  bl.score=gSnap.liqBuyScore;  bl.level=gSnap.liqBuyLevel;
   bl.type=(gSnap.liqBuyType=="NONE" ? "" : gSnap.liqBuyType);
   sl.valid=(gSnap.liqSellScore>0.0); sl.score=gSnap.liqSellScore; sl.level=gSnap.liqSellLevel;
   sl.type=(gSnap.liqSellType=="NONE" ? "" : gSnap.liqSellType);
   BuildSetupDiagnosis(gSnap.flowBuy,gSnap.flowSell,bl,sl);
  }

void BuildSetupDiagnosis(double bf,double sf,LiquidityContext &bl,LiquidityContext &sl)
  {
   bool tBuy =IsTrendAllowed(1);
   bool tSell=IsTrendAllowed(-1);

   bool liqBuy =(bl.valid && bl.score>=InpMinEntryLiquidityScore);
   bool liqSell=(sl.valid && sl.score>=InpMinEntryLiquidityScore);

   bool flowBuy =(bf>=InpMinFlowScore && bf>=sf+InpFlowDominance);
   bool flowSell=(sf>=InpMinFlowScore && sf>=bf+InpFlowDominance);

   bool buyOk =(InpAllowBuy  && tBuy  && liqBuy  && flowBuy);
   bool sellOk=(InpAllowSell && tSell && liqSell && flowSell);

   double buyComb =(buyOk  ? 0.40*bl.score+0.60*bf : 0.0);
   double sellComb=(sellOk ? 0.40*sl.score+0.60*sf : 0.0);
   double comb=MathMax(buyComb,sellComb);

   if(buyOk || sellOk)
     {
      string dn=(buyComb>=sellComb ? "COMPRA" : "VENDA");
      if(comb>=InpMinCombinedScore)
        {
         gSetupHead  ="SETUP QUALIFICADO - "+dn;
         gSetupDetail="Score "+DoubleToString(comb,0)+" / "+DoubleToString(InpMinCombinedScore,0)+
                      "   Liquidez + Fluxo + EMA200 alinhados";
         gSetupLevel =3;
        }
      else
        {
         gSetupHead  ="SCORE INSUFICIENTE";
         gSetupDetail="Direcao "+dn+"   Score "+DoubleToString(comb,0)+" / "+DoubleToString(InpMinCombinedScore,0)+
                      "   faltam "+DoubleToString(InpMinCombinedScore-comb,0)+" pontos";
         gSetupLevel =1;
        }
      return;
     }

   gSetupLevel=1;

   if(!flowBuy && !flowSell)
     {
      gSetupHead  ="AGUARDANDO FLUXO DE VELA";
      gSetupDetail="Compra "+DoubleToString(bf,0)+"   Venda "+DoubleToString(sf,0)+
                   "   min "+DoubleToString(InpMinFlowScore,0)+" com dominancia "+DoubleToString(InpFlowDominance,0);
      return;
     }

   bool   isBuy=flowBuy;
   string dn   =(isBuy ? "COMPRA" : "VENDA");
   double fscore=(isBuy ? bf : sf);
   bool   allowOk=(isBuy ? InpAllowBuy : InpAllowSell);
   bool   trendOk=(isBuy ? tBuy : tSell);
   bool   liqOk  =(isBuy ? liqBuy : liqSell);
   double lscore =(isBuy ? bl.score : sl.score);
   string ltype  =(isBuy ? bl.type  : sl.type);
   if(ltype=="") ltype="NENHUMA";

   if(!allowOk)
     {
      gSetupHead  ="DIRECAO DESABILITADA";
      gSetupDetail="Fluxo aponta "+dn+" mas o parametro de "+dn+" esta desligado";
      gSetupLevel =2;
      return;
     }

   if(!trendOk)
     {
      gSetupHead  ="FLUXO CONTRA A TENDENCIA";
      gSetupDetail="Fluxo "+dn+" ("+DoubleToString(fscore,0)+")   EMA"+IntegerToString(InpTrendEMAPeriod)+
                   " nao autoriza "+dn;
      return;
     }

   if(!liqOk)
     {
      gSetupHead  ="AGUARDANDO LIQUIDEZ";
      gSetupDetail="Fluxo "+dn+" ok ("+DoubleToString(fscore,0)+")   Liquidez "+ltype+
                   " "+DoubleToString(lscore,0)+" / min "+DoubleToString(InpMinEntryLiquidityScore,0);
      return;
     }

   gSetupHead  ="AGUARDANDO CONFLUENCIA";
   gSetupDetail="Condicoes parciais em "+dn;
  }

//+------------------------------------------------------------------+
//| MOTOR DE DIAGNOSTICO - parte de tick                              |
//| Prioridade: bloqueios > cesto aberto > diagnostico de setup.      |
//+------------------------------------------------------------------+
string NativeCalendarPanelState(color &stateColor)
  {
   gNativeCalendarPanelDetail="";

   if(!InpUseNewsFilter)
     {
      stateColor=gcMuted;
      gNativeCalendarPanelDetail="Filtro desativado";
      return "DESATIVADO";
     }

   if((bool)MQLInfoInteger(MQL_TESTER))
     {
      stateColor=gcMuted;
      gNativeCalendarPanelDetail="Calendario nativo indisponivel no tester";
      return "INDISPONIVEL";
     }

   string nn="",nc=""; datetime nt=0;
   if(IsNewsBlocked(nn,nc,nt))
     {
      stateColor=gcDown;
      datetime nowBlocked=TimeTradeServer(); if(nowBlocked<=0) nowBlocked=TimeCurrent();
      int mins=(nt>0 ? (int)MathRound((double)(nt-nowBlocked)/60.0) : 0);
      if(nt>nowBlocked)
         gNativeCalendarPanelDetail=nc+" "+nn+" | faltam "+IntegerToString(MathMax(0,mins))+" min";
      else
         gNativeCalendarPanelDetail=nc+" "+nn+" | janela pos-evento";
      return "BLOQUEADO";
     }

   static datetime lastScan=0;
   static string cached="LIVRE";
   static string cachedDetail="Nenhum evento relevante proximo";
   static bool cachedAttention=false;
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();

   if(lastScan==0 || (now-lastScan)>=60)
     {
      lastScan=now;
      cached="LIVRE";
      cachedDetail="Nenhum evento relevante proximo";
      cachedAttention=false;
      bool anyCalendarRead=false;
      datetime bestTime=0;
      string bestName="",bestCurrency="";

      string currencies[3];
      currencies[0]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
      currencies[1]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
      currencies[2]=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);

      int attentionSeconds=MathMax(60,InpMinutesBeforeNews)*60;
      if(attentionSeconds<3600) attentionSeconds=3600;

      for(int c=0;c<3;c++)
        {
         string cur=currencies[c];
         if(cur=="") continue;
         bool dup=false;
         for(int j=0;j<c;j++) if(currencies[j]==cur) { dup=true; break; }
         if(dup) continue;

         MqlCalendarValue values[];
         ResetLastError();
         int total=CalendarValueHistory(values,now,now+attentionSeconds,"",cur);
         if(total>=0) anyCalendarRead=true;
         if(total<=0) continue;

         for(int i=0;i<total;i++)
           {
            MqlCalendarEvent ev;
            if(!CalendarEventById(values[i].event_id,ev)) continue;
            if(ev.time_mode!=CALENDAR_TIMEMODE_DATETIME) continue;
            if(ev.importance<InpMinNewsImportance) continue;
            if(values[i].time<=now) continue;

            if(bestTime==0 || values[i].time<bestTime)
              {
               bestTime=values[i].time;
               bestName=ev.name;
               bestCurrency=cur;
              }
           }
        }

      if(!anyCalendarRead && GetLastError()!=0)
        {
         cached="INDISPONIVEL";
         cachedDetail="Consulta ao calendario nativo falhou";
        }
      else if(bestTime>0)
        {
         int mins=(int)MathCeil((double)(bestTime-now)/60.0);
         cachedAttention=true;
         cached="ATENCAO";
         cachedDetail=bestCurrency+" "+bestName+" | "+IntegerToString(MathMax(0,mins))+" min";
        }
     }

   gNativeCalendarPanelDetail=cachedDetail;
   if(cached=="ATENCAO")
     {
      stateColor=gcWarn;
      return cached;
     }
   if(cached=="INDISPONIVEL")
     {
      stateColor=gcMuted;
      return cached;
     }

   stateColor=gcUp;
   return "LIVRE";
  }

void GetActivityStatus(string &head,string &det,int &level)
  {
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   if(gBasket.active)
     {
      if(gRecoveryReconciliation)
        {
         head="RECOVERY_RECONCILIATION";
         det="Exposicao owned em reconciliacao; nova exposicao bloqueada";
         level=2; return;
        }

      string dir=(gBasket.direction==POSITION_TYPE_BUY?"COMPRA":"VENDA");
      if(gRecoveryArmed)
        {
         head="RECOVERY ARMADO - "+dir;
         det="Nivel "+IntegerToString(gBasket.recoveryLevel+1)+" de "+IntegerToString(InpMaxRecoveryLevels);
         level=1; return;
        }

      if(gBasket.positions>1)
        {
         head="CESTO EM RECOVERY - "+dir;
         det="Nivel "+IntegerToString(gBasket.recoveryLevel)+"/"+IntegerToString(InpMaxRecoveryLevels)+
             " | "+IntegerToString(gBasket.positions)+" pernas | "+DoubleToString(gBasket.totalVolume,2)+" lotes";
         level=(gBasket.basketProfit>=0.0?3:1); return;
        }

      double favorable=0.0;
      if(point>0.0 && bid>0.0 && ask>0.0)
         favorable=(gBasket.direction==POSITION_TYPE_BUY
                    ? (bid-gBasket.averagePrice)/point
                    : (gBasket.averagePrice-ask)/point);

      head="POSICAO ABERTA - "+dir;
      det="Resultado "+MoneyText(gBasket.basketProfit)+" | Favoravel "+PtsText(favorable)+
          " | Trailing "+ProfitRunnerPanelText();
      level=(gBasket.basketProfit>=0.0?3:1); return;
     }

   if(!gStartupReconciled || gRecoveryReconciliation)
     {
      head="RECONCILIANDO ESTADO";
      det="Novas entradas bloqueadas ate confirmar realidade do broker";
      level=1; return;
     }

   if(gUserEntryPause)
     {
      head="PAUSADO PELO USUARIO";
      det="Somente novas entradas L0 estao pausadas";
      level=2; return;
     }

   if(gDailyTargetLock)
     {
      head="META DIARIA ATINGIDA";
      det="Lucro Hoje "+MoneyText(gDayNet)+" | Meta "+MoneyText(InpDailyProfitTarget);
      level=3; return;
     }

   string sessReason="";
   if(!IsSessionWindowAllowed(sessReason))
     {
      head="SESSAO REAL DO BROKER BLOQUEADA";
      det=sessReason;
      level=2; return;
     }

   string opReason="";
   if(!IsOperationalWindowAllowed(opReason))
     {
      if(opReason=="DIA_DESABILITADO")
        {
         head="FORA DA JANELA OPERACIONAL";
         det="DIA DESABILITADO";
        }
      else
        {
         head="AGUARDANDO JANELA OPERACIONAL";
         det="Proxima janela "+OperationalWindowText();
        }
      level=1; return;
     }

   string nn="",nc=""; datetime nt=0;
   if(IsNewsBlocked(nn,nc,nt))
     {
      head="CALENDARIO ECONOMICO BLOQUEADO";
      det=nc+" "+nn+" "+TimeToString(nt,TIME_MINUTES);
      level=2; return;
     }

   if(gLastOrderFailureTime>0 && (TimeCurrent()-gLastOrderFailureTime)<InpOrderFailureCooldownSeconds)
     {
      int rest=InpOrderFailureCooldownSeconds-(int)(TimeCurrent()-gLastOrderFailureTime);
      head="COOLDOWN DE EXECUCAO";
      det="Nova tentativa em "+IntegerToString(rest)+"s";
      level=2; return;
     }

   double atr=(ArraySize(gATR)>1?gATR[1]:0.0);
   double sp=0.0,spPct=0.0;
   if(atr>0.0 && !IsSpreadAllowed(atr,sp,spPct))
     {
      head="SPREAD ACIMA DO LIMITE";
      det=DoubleToString(spPct,1)+"% ATR | limite "+DoubleToString(InpMaxSpreadATRPercent,1)+"%";
      level=2; return;
     }

   head=gSetupHead;
   det=gSetupDetail;
   level=gSetupLevel;
  }

//+------------------------------------------------------------------+
//| Construcao / destruicao                                           |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   if(!InpShowPanel) return;
   UpdatePanel();
   ChartRedraw(0);
  }

void DeletePanel()
  {
   ObjectsDeleteAll(0,PFX);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Fast path LIVE: somente texto de campos operacionais por tick.   |
//| Nao recalcula Signal/Liquidity/Flow/Score e nao chama redraw.    |
//+------------------------------------------------------------------+
void PanelFastText(string name,string text)
  {
   string n=PFX+name;
   if(ObjectFind(0,n)<0) return;
   if(ObjectGetString(0,n,OBJPROP_TEXT)!=text)
      ObjectSetString(0,n,OBJPROP_TEXT,text);
  }

void UpdatePanelLiveFields()
  {
   if(!InpShowPanel) return;

   string head="",det=""; int level=0;
   GetActivityStatus(head,det,level);
   if(gPanelMinimized)
     {
      PanelFastText("M_STATE",head);
      return;
     }

   double atr=(ArraySize(gATR)>1?gATR[1]:0.0);
   double spreadPts=0.0,spreadPct=0.0;
   IsSpreadAllowed(atr,spreadPts,spreadPct);
   PanelFastText("F_SPREAD_V",DoubleToString(spreadPts,0)+"p");
   PanelFastText("F_SPREAD_D",DoubleToString(spreadPct,1)+"% ATR");
   PanelFastText("F_STATE_V",head);
   string shortDet=det; if(StringLen(shortDet)>72) shortDet=StringSubstr(shortDet,0,72);
   PanelFastText("F_STATE_D",shortDet);

   string context="FLAT";
   if(gBasket.active) context=(gBasket.positions>1?"RECOVERY":"POSICAO");
   else if(gLastSignal.direction>0) context="SINAL COMPRA";
   else if(gLastSignal.direction<0) context="SINAL VENDA";
   PanelFastText("F_CONTEXT_V",context);

   double livePx=(gBasket.active && gBasket.direction==POSITION_TYPE_SELL ? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID));
   double liveSL=0.0;
   for(int pi=PositionsTotal()-1;pi>=0;pi--)
     {
      string ps=PositionGetSymbol(pi); if(ps!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      double psl=PositionGetDouble(POSITION_SL);
      if(psl>0.0) { liveSL=psl; break; }
     }

   PanelFastText("F_D2","Basket "+(gBasket.active?"ATIVO":"FLAT")+
                 " | Pernas "+IntegerToString(gBasket.positions)+
                 " | Vol "+DoubleToString(gBasket.totalVolume,2)+
                 " | Float "+MoneyText(gBasket.basketProfit));
   PanelFastText("F_D3","Avg "+DoubleToString(gBasket.averagePrice,_Digits)+
                 " | Worst "+DoubleToString(gBasket.worstEntry,_Digits)+
                 " | Px "+DoubleToString(livePx,_Digits)+
                 " | SL "+(liveSL>0.0?DoubleToString(liveSL,_Digits):"VIRTUAL/OFF"));

   double recDist=(atr>0.0?GetRecoveryDistancePrice(atr):0.0);
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double nextRec=0.0;
   if(gBasket.active && recDist>0.0)
      nextRec=(gBasket.direction==POSITION_TYPE_BUY?gBasket.worstEntry-recDist:gBasket.worstEntry+recDist);
   PanelFastText("F_D4","Recovery "+IntegerToString(gBasket.recoveryLevel)+"/"+IntegerToString(InpMaxRecoveryLevels)+
                 " | Grid "+DoubleToString((point>0.0?recDist/point:0.0),0)+"p | Next "+DoubleToString(nextRec,_Digits));

   string tpDiag="TP "+DoubleToString(gLastKnownBasketTP,_Digits);
   if(InpTakeProfitEnabled && InpTakeProfitUnit==TAKE_PROFIT_MONEY)
      tpDiag+=" | Target "+MoneyText(ActiveTakeProfitMoneyTarget())+" | Proj "+MoneyText(gResolvedTPMoneyProjected);
   PanelFastText("F_D5",tpDiag+" | Trail "+ProfitRunnerPanelText());

   PanelFastText("F_M1_V",DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),0)+"%");
   PanelFastText("F_M6_V",DoubleToString(gBasket.totalVolume,2)+" lot");
   PanelFastText("F_BAL","Bal "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+
                 " | Eq "+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+
                 " | Free "+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2));
  }

//+------------------------------------------------------------------+
//| UpdatePanel                                                       |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   if(!InpShowPanel) return;

   // Campos operacionais LIVE passam pelo fast path em toda chamada/tick.
   UpdatePanelLiveFields();

   static ulong lastDraw=0;
   ulong nowMs=GetTickCount64();
   if(!gPanelForceRedraw && lastDraw>0 && (nowMs-lastDraw)<250) return;
   gPanelForceRedraw=false;
   lastDraw=nowMs;

   RefreshDayStats();
   RefreshPeriodStats();

   string head="",det=""; int level=0;
   GetActivityStatus(head,det,level);
   color stateColor=PanelLevelColor(level);

   double atr=(ArraySize(gATR)>1?gATR[1]:0.0);
   double spreadPts=0.0,spreadPct=0.0;
   IsSpreadAllowed(atr,spreadPts,spreadPct);

   string trend="NEUTRO";
   bool tb=IsTrendAllowed(1),ts=IsTrendAllowed(-1);
   if(InpTrendFilterMode==TREND_FILTER_OFF) trend="OFF";
   else if(tb && !ts) trend="COMPRA";
   else if(ts && !tb) trend="VENDA";

   string context="FLAT";
   if(gBasket.active)
      context=(gBasket.positions>1?"RECOVERY":"POSICAO");
   else if(gLastSignal.direction>0) context="SINAL COMPRA";
   else if(gLastSignal.direction<0) context="SINAL VENDA";

   color newsColor=gcMuted;
   string newsState=NativeCalendarPanelState(newsColor);

   datetime srv=TimeTradeServer(); if(srv<=0) srv=TimeCurrent();
   datetime loc=TimeLocal();
   string mode=((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO?"DEMO":"REAL");

   int X=InpPanelX,Y=InpPanelY,W=PANEL_W;
   int L=X+14,R=X+W-14;
   int innerW=W-28;

   if(gPanelMinimized)
     {
      SetPanelGroupVisible("F_",false);

      PanelRect("M_BG",X,Y,W,PANEL_H_MIN,gcBg,gcLine);
      PanelRect("M_HD",X,Y,W,34,gcCardAlt,gcCardAlt);
      PanelRect("M_AC",X,Y,4,34,gcAccent,gcAccent);
      PanelText("M_TITLE",FMX_PRODUCT_NAME,L,Y+7,11,gcTxt,FONT_UI_B,ANCHOR_LEFT_UPPER);
      PanelText("M_ONLINE","ONLINE",R-38,Y+9,8,gcUp,FONT_UI_B,ANCHOR_RIGHT_UPPER);
      PanelButton("M_BTN_TOGGLE","+",R-24,Y+6,24,22,10,gcTxt,gcAccent,gcCard);
      PanelText("M_META",_Symbol+" | M1 | "+mode,L,Y+38,8,gcMuted,FONT_MONO,ANCHOR_LEFT_UPPER);
      PanelText("M_STATE",head,L,Y+57,8,stateColor,FONT_UI_B,ANCHOR_LEFT_UPPER);
      SetPanelGroupVisible("M_",true);
      return;
     }

   SetPanelGroupVisible("M_",false);

   PanelRect("F_BG",X,Y,W,PANEL_H_FULL,gcBg,gcLine);
   PanelRect("F_HD",X,Y,W,42,gcCardAlt,gcCardAlt);
   PanelRect("F_AC",X,Y,4,42,gcAccent,gcAccent);
   PanelText("F_TITLE",FMX_PRODUCT_NAME,L,Y+6,12,gcTxt,FONT_UI_B,ANCHOR_LEFT_UPPER);
   PanelText("F_ONLINE","ONLINE",R-40,Y+7,8,gcUp,FONT_UI_B,ANCHOR_RIGHT_UPPER);
   PanelText("F_META",_Symbol+" | M1 | "+mode,L,Y+24,8,gcMuted,FONT_MONO,ANCHOR_LEFT_UPPER);
   PanelButton("F_BTN_TOGGLE","-",R-24,Y+8,24,22,10,gcTxt,gcAccent,gcCard);

   int y=Y+48;

   // ESTADO OPERACIONAL
   PanelRect("F_STATE_CARD",X+8,y,W-16,52,gcCard,gcLine);
   PanelRect("F_STATE_AC",X+8,y,4,52,stateColor,stateColor);
   PanelText("F_STATE_L","ESTADO OPERACIONAL",L,y+6,7,gcMuted,FONT_UI_B,ANCHOR_LEFT_UPPER);
   PanelText("F_STATE_V",head,L,y+20,9,stateColor,FONT_UI_B,ANCHOR_LEFT_UPPER);
   string shortDet=det; if(StringLen(shortDet)>72) shortDet=StringSubstr(shortDet,0,72);
   PanelText("F_STATE_D",shortDet,L,y+35,7,gcMuted,FONT_UI,ANCHOR_LEFT_UPPER);
   y+=60;

   // TENDENCIA / SPREAD / CONTEXTO
   int cardGap=6;
   int cardW=(W-28-cardGap*2)/3;
   PanelRect("F_TREND_CARD",X+8,y,cardW,58,gcCard,gcLine);
   PanelText("F_TREND_L","TENDENCIA",X+16,y+7,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
   PanelText("F_TREND_V",trend,X+16,y+25,9,(trend=="COMPRA"?gcUp:(trend=="VENDA"?gcDown:gcMuted)),FONT_MONO,ANCHOR_LEFT_UPPER);
   PanelText("F_TREND_D","EMA "+IntegerToString(InpTrendEMAPeriod),X+16,y+41,7,gcMuted,FONT_UI,ANCHOR_LEFT_UPPER);

   int x2=X+8+cardW+cardGap;
   PanelRect("F_SPREAD_CARD",x2,y,cardW,58,gcCard,gcLine);
   PanelText("F_SPREAD_L","SPREAD",x2+8,y+7,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
   PanelText("F_SPREAD_V",DoubleToString(spreadPts,0)+"p",x2+8,y+25,9,
             (InpMaxSpreadATRPercent<=0.0 || spreadPct<=InpMaxSpreadATRPercent?gcUp:gcDown),FONT_MONO,ANCHOR_LEFT_UPPER);
   PanelText("F_SPREAD_D",DoubleToString(spreadPct,1)+"% ATR",x2+8,y+41,7,gcMuted,FONT_UI,ANCHOR_LEFT_UPPER);

   int x3=x2+cardW+cardGap;
   PanelRect("F_CONTEXT_CARD",x3,y,cardW,58,gcCard,gcLine);
   PanelText("F_CONTEXT_L","CONTEXTO",x3+8,y+7,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
   PanelText("F_CONTEXT_V",context,x3+8,y+25,8,gcTxt,FONT_MONO,ANCHOR_LEFT_UPPER);
   PanelText("F_CONTEXT_D","Score "+DoubleToString(gSnap.combBest,0),x3+8,y+41,7,gcMuted,FONT_UI,ANCHOR_LEFT_UPPER);
   y+=66;

   // CALENDARIO NATIVO
   PanelRect("F_NEWS_CARD",X+8,y,W-16,40,gcCard,gcLine);
   PanelText("F_NEWS_L","CALENDARIO ECONOMICO",L,y+7,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
   PanelText("F_NEWS_V",newsState,R,y+7,8,newsColor,FONT_MONO,ANCHOR_RIGHT_UPPER);
   PanelText("F_NEWS_D",gNativeCalendarPanelDetail,L,y+23,7,gcMuted,FONT_UI,ANCHOR_LEFT_UPPER);
   y+=48;

   // GESTAO / METAS
   int colW=(W-22)/2;
   int leftX=X+8,rightX=X+12+colW;
   PanelRect("F_MGMT_CARD",leftX,y,colW,185,gcCard,gcLine);
   PanelText("F_MGMT_H","GESTAO DA CONTA",leftX+8,y+7,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
   int ry=y+25;
   PanelRow("F_M1","Margem",DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),0)+"%",leftX+8,ry,colW-16,gcTxt); ry+=19;
   PanelRow("F_M2","Take Profit",(InpTakeProfitEnabled?TakeProfitUnitToString():"OFF"),leftX+8,ry,colW-16,(InpTakeProfitEnabled?gcUp:gcMuted)); ry+=19;
   PanelRow("F_M3","Trailing",ProfitRunnerPanelText(),leftX+8,ry,colW-16,(InpTrailingStopEnabled?gcUp:gcMuted)); ry+=19;
   PanelRow("F_M4","Recovery",IntegerToString(gBasket.recoveryLevel)+"/"+IntegerToString(InpMaxRecoveryLevels),leftX+8,ry,colW-16,gcTxt); ry+=19;
   PanelRow("F_M5","Grid",(InpRecoveryGridMode==RECOVERY_GRID_ATR?"ATR":"FIXO"),leftX+8,ry,colW-16,gcTxt); ry+=19;
   PanelRow("F_M6","Exposicao",DoubleToString(gBasket.totalVolume,2)+" lot",leftX+8,ry,colW-16,gcTxt);

   PanelRect("F_PERF_CARD",rightX,y,colW,185,gcCard,gcLine);
   PanelText("F_PERF_H","METAS / ASSERTIVIDADE",rightX+8,y+7,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
   ry=y+25;
   PanelRow("F_P1","Meta Diaria",MoneyText(InpDailyProfitTarget),rightX+8,ry,colW-16,gcTxt); ry+=19;
   PanelRow("F_P2","Lucro Hoje",MoneyText(gDayNet),rightX+8,ry,colW-16,PanelPLColor(gDayNet)); ry+=19;
   PanelRow("F_P3","Lucro Semana",MoneyText(gWeekProfit),rightX+8,ry,colW-16,PanelPLColor(gWeekProfit)); ry+=19;
   PanelRow("F_P4","Lucro Mes",MoneyText(gMonthProfit),rightX+8,ry,colW-16,PanelPLColor(gMonthProfit)); ry+=19;
   PanelRow("F_P5","Lucro Ano",MoneyText(gYearProfit),rightX+8,ry,colW-16,PanelPLColor(gYearProfit)); ry+=19;
   PanelRow("F_P6","Operacoes H/S/M/A",
            IntegerToString(gDayWins+gDayLosses)+"/"+IntegerToString(gTradesWeek)+"/"+
            IntegerToString(gTradesMonth)+"/"+IntegerToString(gTradesYear),
            rightX+8,ry,colW-16,gcTxt); ry+=19;
   int dayTrades=gDayWins+gDayLosses;
   double acc=(dayTrades>0?(double)gDayWins/dayTrades*100.0:0.0);
   PanelRow("F_P7","Assertividade Hoje",DoubleToString(acc,1)+"%",rightX+8,ry,colW-16,gcTxt);
   y+=193;

   // DIAGNOSTICO
   PanelRect("F_DIAG_CARD",X+8,y,W-16,166,gcCard,gcLine);
   PanelText("F_DIAG_H","DIAGNOSTICO / OUTRAS INFORMACOES",L,y+7,7,gcAccent,FONT_UI_B,ANCHOR_LEFT_UPPER);
   PanelText("F_D1","Score "+DoubleToString(gSnap.combBest,1)+
             " | Liq B/S "+DoubleToString(gSnap.liqBuyScore,0)+"/"+DoubleToString(gSnap.liqSellScore,0)+
             " | Flow B/S "+DoubleToString(gSnap.flowBuy,0)+"/"+DoubleToString(gSnap.flowSell,0),
             L,y+24,7,gcTxt,FONT_MONO,ANCHOR_LEFT_UPPER);
   double livePx=(gBasket.active && gBasket.direction==POSITION_TYPE_SELL ? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID));
   double liveSL=0.0;
   for(int pi=PositionsTotal()-1;pi>=0;pi--)
     {
      string ps=PositionGetSymbol(pi); if(ps!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      double psl=PositionGetDouble(POSITION_SL);
      if(psl>0.0) { liveSL=psl; break; }
     }
   PanelText("F_D2","Basket "+(gBasket.active?"ATIVO":"FLAT")+
             " | Pernas "+IntegerToString(gBasket.positions)+
             " | Vol "+DoubleToString(gBasket.totalVolume,2)+
             " | Float "+MoneyText(gBasket.basketProfit),L,y+41,7,gcTxt,FONT_MONO,ANCHOR_LEFT_UPPER);
   PanelText("F_D3","Avg "+DoubleToString(gBasket.averagePrice,_Digits)+
             " | Worst "+DoubleToString(gBasket.worstEntry,_Digits)+
             " | Px "+DoubleToString(livePx,_Digits)+
             " | TrailSL "+(liveSL>0.0?DoubleToString(liveSL,_Digits):"--"),L,y+58,7,gcTxt,FONT_MONO,ANCHOR_LEFT_UPPER);
   double recDist=(atr>0.0?GetRecoveryDistancePrice(atr):0.0);
   double nextRec=0.0;
   if(gBasket.active && recDist>0.0)
      nextRec=(gBasket.direction==POSITION_TYPE_BUY?gBasket.worstEntry-recDist:gBasket.worstEntry+recDist);
   PanelText("F_D4","Recovery "+IntegerToString(gBasket.recoveryLevel)+"/"+IntegerToString(InpMaxRecoveryLevels)+
             " | Grid "+DoubleToString((SymbolInfoDouble(_Symbol,SYMBOL_POINT)>0.0?recDist/SymbolInfoDouble(_Symbol,SYMBOL_POINT):0.0),0)+"p"+
             " | Next "+DoubleToString(nextRec,_Digits),L,y+75,7,gcTxt,FONT_MONO,ANCHOR_LEFT_UPPER);
   string tpDiag="TP "+DoubleToString(gLastKnownBasketTP,_Digits);
   if(InpTakeProfitEnabled && InpTakeProfitUnit==TAKE_PROFIT_MONEY)
      tpDiag+=" | Target "+MoneyText(ActiveTakeProfitMoneyTarget())+" | Proj "+MoneyText(gResolvedTPMoneyProjected);
   PanelText("F_D5",tpDiag+" | Trail "+ProfitRunnerPanelText(),L,y+92,7,gcTxt,FONT_MONO,ANCHOR_LEFT_UPPER);
   color recNewsColor=gcMuted;
   string recNewsText=RecoveryNewsGuardPanelText(recNewsColor);
   if(StringLen(recNewsText)>72) recNewsText=StringSubstr(recNewsText,0,72);
   PanelText("F_D6",recNewsText,L,y+109,7,recNewsColor,FONT_MONO,ANCHOR_LEFT_UPPER);
   PanelText("F_D7","Janela "+OperationalWindowText()+" | Persist "+(gStateLoaded?"OK":"NOVO")+" | UI "+(gUiDegraded?"DEGRADED":"OK"),
             L,y+126,7,(gUiDegraded?gcWarn:gcMuted),FONT_MONO,ANCHOR_LEFT_UPPER);
   string ids="ConfigHash "+gConfigHash+" | RunID "+gRunID;
   if(StringLen(ids)>74) ids=StringSubstr(ids,0,74);
   PanelText("F_D8",ids,L,y+143,7,gcMuted,FONT_MONO,ANCHOR_LEFT_UPPER);
   y+=174;

   // CONTA / RELOGIOS
   PanelRect("F_FOOT_CARD",X+8,y,W-16,42,gcCard,gcLine);
   PanelText("F_CLOCK","Broker "+TimeToString(srv,TIME_MINUTES|TIME_SECONDS)+
             " | Local "+TimeToString(loc,TIME_MINUTES|TIME_SECONDS),L,y+7,7,gcMuted,FONT_MONO,ANCHOR_LEFT_UPPER);
   PanelText("F_BAL","Bal "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+
             " | Eq "+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+
             " | Free "+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2),L,y+24,7,gcTxt,FONT_MONO,ANCHOR_LEFT_UPPER);
   y+=50;

   // BOTOES
   int by=y;
   PanelButton("F_BTN_PAUSE","PAUSAR",X+8,by,82,26,8,gcTxt,gcWarn,gcCard);
   PanelButton("F_BTN_CSV",(gCsvBtnFeedback!="" && TimeCurrent()<=gCsvBtnUntil?gCsvBtnFeedback:"CSV"),X+96,by,96,26,8,gcTxt,gcAccent,gcCard);
   PanelButton("F_BTN_REFRESH","ATUALIZAR DADOS",X+198,by,154,26,8,gcTxt,gcAccent,gcCard);
   PanelButton("F_BTN_ON",(gUserEntryPause?"OFF":"ON"),X+358,by,98,26,8,
               (gUserEntryPause?gcMuted:gcUp),gcAccent,gcCard);

   SetPanelGroupVisible("F_",true);
  }

//+------------------------------------------------------------------+
//| End of file                                                      |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| FluxMatrix PRO - utilitarios de telemetria/persistencia          |
//+------------------------------------------------------------------+
string TelemetryClean(string t)
  {
   StringReplace(t,";","|");
   StringReplace(t,"\r"," ");
   StringReplace(t,"\n"," ");
   return t;
  }

string TelemetryFile(string family)
  {
   string fam=CsvSanitize(family);
   string sym=CsvSanitize(_Symbol);
   long maxBytes=(long)InpTelemetryPartMaxKB*1024;
   if(maxBytes<65536) maxBytes=65536;

   FolderCreate(FMX_TELEMETRY_FOLDER);

   int slot=-1;
   for(int q=0;q<12;q++)
     {
      if(gTelFamName[q]==fam) { slot=q; break; }
      if(gTelFamName[q]=="") { gTelFamName[q]=fam; gTelFamPart[q]=1; slot=q; break; }
     }
   int startPart=(slot>=0 && gTelFamPart[slot]>0 ? gTelFamPart[slot] : 1);

   for(int part=startPart;part<=9999;part++)
     {
      string fn=StringFormat("%s\\%s_%s_%I64u_PART%03d.csv",
                             FMX_TELEMETRY_FOLDER,fam,sym,InpMagicNumber,part);
      if(slot>=0) gTelFamPart[slot]=part;
      if(!FileIsExist(fn)) return fn;

      int h=FileOpen(fn,FILE_READ|FILE_TXT|FILE_ANSI);
      if(h==INVALID_HANDLE) return fn;
      long sz=(long)FileSize(h);
      FileClose(h);
      if(sz<maxBytes) return fn;
     }

   return StringFormat("%s\\%s_%s_%I64u_PART9999.csv",
                       FMX_TELEMETRY_FOLDER,fam,sym,InpMagicNumber);
  }

string NextCausalId(string prefix)
  {
   gIdSequence++;
   return prefix+"_"+gRunID+"_"+IntegerToString((int)gIdSequence);
  }

bool TelemetryWrite(string family,string event,string detail,double price,double volume,string extra,
                    ulong orderTicket,ulong dealTicket,ulong positionId)
  {
   if(!InpEnableCsvTelemetry) return false;

   string fn=TelemetryFile(family);
   bool exists=FileIsExist(fn);

   ResetLastError();
   int h;
   if(exists) h=FileOpen(fn,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
   else       h=FileOpen(fn,FILE_WRITE|FILE_TXT|FILE_ANSI);

   if(h==INVALID_HANDLE)
     {
      int err=GetLastError();
      gCsvErrors++;
      gCsvLastError=err;
      if(gCsvErrors==1 || gCsvLastErrLog==0 || (TimeCurrent()-gCsvLastErrLog)>=300)
        {
         gCsvLastErrLog=TimeCurrent();
         Print(FMX_PRODUCT_NAME,
               " | EVENT=TELEMETRY_WRITE_FAILED | Family=",family,
               " | Error=",err," | ",CsvErrText(err)," | File=",fn);
        }
      return false;
     }

   if(exists) FileSeek(h,0,SEEK_END);

   if(!exists || FileTell(h)<=0)
     {
      FileWriteString(h,
         "SchemaVersion;ProductName;BuildID;RunID;ConfigHash;Broker;Server;Account;"
         "Symbol;Timeframe;Magic;BasketID;SignalID;DecisionID;IntentID;RequestID;"
         "OrderTicket;DealTicket;PositionID;ServerTime;UTC;SequenceNumber;"
         "Family;Event;Detail;Price;Volume;Extra\r\n");
     }

   gSequenceNumber++;
   datetime srv=TimeTradeServer(); if(srv<=0) srv=TimeCurrent();
   datetime utc=TimeGMT();

   ulong commonOrder=orderTicket;
   ulong commonDeal=dealTicket;
   ulong commonPosition=positionId;
   if(commonOrder==0 && commonDeal==0 &&
      (StringFind(event,"ORDERSEND_RESULT")>=0 || StringFind(event,"ORDER_SENT")>=0))
     {
      commonOrder=trade.ResultOrder();
      commonDeal=trade.ResultDeal();
     }

   string line=
      IntegerToString(FMX_SCHEMA_VERSION)+";"+
      TelemetryClean(FMX_PRODUCT_NAME)+";"+
      TelemetryClean(FMX_BUILD_ID)+";"+
      TelemetryClean(gRunID)+";"+
      TelemetryClean(gConfigHash)+";"+
      TelemetryClean(AccountInfoString(ACCOUNT_COMPANY))+";"+
      TelemetryClean(AccountInfoString(ACCOUNT_SERVER))+";"+
      StringFormat("%I64d",AccountInfoInteger(ACCOUNT_LOGIN))+";"+
      TelemetryClean(_Symbol)+";M1;"+
      StringFormat("%I64u",InpMagicNumber)+";"+
      StringFormat("%I64u",gBasket.basketId)+";"+
      TelemetryClean(gSignalID)+";"+
      TelemetryClean(gDecisionID)+";"+
      TelemetryClean(gIntentID)+";"+
      TelemetryClean(gRequestID)+";"+
      StringFormat("%I64u",commonOrder)+";"+
      StringFormat("%I64u",commonDeal)+";"+
      StringFormat("%I64u",commonPosition)+";"+
      TimeToString(srv,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+";"+
      TimeToString(utc,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+";"+
      StringFormat("%I64d",gSequenceNumber)+";"+
      TelemetryClean(family)+";"+
      TelemetryClean(event)+";"+
      TelemetryClean(detail)+";"+
      CsvNum(price,_Digits)+";"+
      CsvNum(volume,2)+";"+
      TelemetryClean(extra);

   FileWriteString(h,line+"\r\n");
   FileFlush(h);
   FileClose(h);

   gCsvRows++;
   gCsvLastError=0;
   return true;
  }

string TelemetryFamilyForEvent(string event)
  {
   if(StringFind(event,"RECOVERY")>=0) return "RECOVERY_DECISIONS";
   if(StringFind(event,"CALENDAR")>=0 || StringFind(event,"NEWS")>=0) return "CALENDAR_STATE";
   if(StringFind(event,"ORDER")>=0 || StringFind(event,"PREFLIGHT")>=0 || StringFind(event,"EXECUTION")>=0) return "EXECUTION";
   if(StringFind(event,"TRAIL")>=0 || StringFind(event,"TP_")>=0 || StringFind(event,"POSITION_MODIFY")>=0) return "POSITION_MANAGEMENT";
   if(StringFind(event,"MARGIN")>=0 || StringFind(event,"RISK")>=0 || StringFind(event,"OWNERSHIP")>=0) return "RISK_STATE";
   if(StringFind(event,"BASKET_CLOSED")>=0 || StringFind(event,"SUMMARY")>=0) return "BASKET_SUMMARY";
   if(StringFind(event,"BASKET")>=0) return "BASKET_STATE";
   if(StringFind(event,"SIGNAL")>=0 || StringFind(event,"SCORE")>=0 || StringFind(event,"FLOW")>=0 || StringFind(event,"LIQUID")>=0) return "SIGNAL_FUNNEL";
   return "MARKET_STATE";
  }

void TelemetryEnsureFamilies()
  {
   string families[12]={"RUN_CONFIG","MARKET_STATE","SIGNAL_FUNNEL","RISK_STATE","RECOVERY_DECISIONS",
                        "EXECUTION","POSITION_MANAGEMENT","BASKET_STATE","BASKET_SUMMARY","DEALS_EXPORT",
                        "CALENDAR_STATE","PERFORMANCE"};
   for(int i=0;i<ArraySize(families);i++)
     {
      string f=TelemetryFile(families[i]);
      int h=FileOpen(f,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
      if(h!=INVALID_HANDLE) FileClose(h);
     }
  }

void TelemetryPerformanceSnapshot()
  {
   RefreshDayStats();
   RefreshPeriodStats();

   int dayTrades=gDayWins+gDayLosses;
   double accuracy=(dayTrades>0 ? (double)gDayWins/dayTrades*100.0 : 0.0);

   string detail=
      "LucroHoje="+CsvNum(gDayNet,2)+
      " | LucroSemana="+CsvNum(gWeekProfit,2)+
      " | LucroMes="+CsvNum(gMonthProfit,2)+
      " | LucroAno="+CsvNum(gYearProfit,2)+
      " | TradesH="+IntegerToString(dayTrades)+
      " | TradesS="+IntegerToString(gTradesWeek)+
      " | TradesM="+IntegerToString(gTradesMonth)+
      " | TradesA="+IntegerToString(gTradesYear)+
      " | WinsHoje="+IntegerToString(gDayWins)+
      " | LossesHoje="+IntegerToString(gDayLosses)+
      " | AssertividadeHoje="+CsvNum(accuracy,2);

   TelemetryWrite("PERFORMANCE","PERFORMANCE_SNAPSHOT",detail);
  }
void TelemetryRiskSnapshot(string reason)
  {
   double margin=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   string detail=
      "Reason="+reason+
      " | BasketProfit="+CsvNum(gBasket.basketProfit,2)+
      " | Positions="+IntegerToString(gBasket.positions)+
      " | Volume="+CsvNum(gBasket.totalVolume,2)+
      " | MarginLevel="+CsvNum(margin,2)+
      " | FreeMargin="+CsvNum(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2)+
      " | MinMarginLevel="+CsvNum(InpMinMarginLevelPct,2)+
      " | MaxBasketVolume="+CsvNum(InpMaxBasketVolume,2)+
      " | Reconciliation="+(gRecoveryReconciliation?"true":"false");

   TelemetryWrite("RISK_STATE","RISK_SNAPSHOT",detail,0.0,gBasket.totalVolume);
  }

double GetYearProfit()
  {
   datetime now=TimeCurrent();
   MqlDateTime d; TimeToStruct(now,d);
   d.mon=1; d.day=1; d.hour=0; d.min=0; d.sec=0;
   return GetProfitFrom(StructToTime(d),now);
  }

int GetOwnClosedTradesCount(datetime from,datetime to)
  {
   if(!HistorySelect(from,to)) return 0;
   int count=0;
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpMagicNumber) continue;

      ENUM_DEAL_TYPE dt=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(dt!=DEAL_TYPE_BUY && dt!=DEAL_TYPE_SELL) continue;

      ENUM_DEAL_ENTRY en=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(en==DEAL_ENTRY_OUT || en==DEAL_ENTRY_OUT_BY) count++;
     }
   return count;
  }

string HashText(const string value)
  {
   ulong h=5381;
   int n=StringLen(value);
   for(int i=0;i<n;i++)
      h=((h<<5)+h)+(ulong)StringGetCharacter(value,i);
   return StringFormat("%I64u",h);
  }
string BuildConfigHash()
  {
   string cfg=
      InpAllowedSymbol+"|"+(InpAllowBrokerSuffix?"1":"0")+"|"+
      StringFormat("%I64u",InpMagicNumber)+"|"+(InpAllowBuy?"1":"0")+"|"+(InpAllowSell?"1":"0")+"|"+
      IntegerToString(InpDeviationPoints)+"|"+IntegerToString(InpOrderFailureCooldownSeconds)+"|"+
      IntegerToString((int)InpTrendFilterMode)+"|"+IntegerToString(InpTrendEMAPeriod)+"|"+
      IntegerToString(InpTrendConfirmBars)+"|"+IntegerToString(InpATRPeriod)+"|"+
      IntegerToString(InpSwingDepth)+"|"+IntegerToString(InpLiquidityLookback)+"|"+
      IntegerToString(InpExtremeLookbackFast)+"|"+IntegerToString(InpExtremeLookbackSlow)+"|"+
      DoubleToString(InpEqualLiquidityATR,8)+"|"+IntegerToString(InpEqualLiquidityMinPoints)+"|"+
      DoubleToString(InpSweepMinATR,8)+"|"+DoubleToString(InpSweepMaxATR,8)+"|"+
      DoubleToString(InpLiquidityNearATR,8)+"|"+DoubleToString(InpMinEntryLiquidityScore,8)+"|"+
      IntegerToString(InpFlowLookback)+"|"+(InpUseTickVolume?"1":"0")+"|"+
      IntegerToString(InpVolumeLookback)+"|"+DoubleToString(InpVolumeFullScoreRatio,8)+"|"+
      DoubleToString(InpMinFlowScore,8)+"|"+DoubleToString(InpFlowDominance,8)+"|"+
      DoubleToString(InpMinCombinedScore,8)+"|"+
      DoubleToString(InpInitialLot,8)+"|"+DoubleToString(InpMultiplier,8)+"|"+
      IntegerToString(InpMaxRecoveryLevels)+"|"+IntegerToString((int)InpRecoveryGridMode)+"|"+
      IntegerToString(InpGridDistancePoints)+"|"+DoubleToString(InpGridATRMultiplier,8)+"|"+
      IntegerToString(InpGridMinPoints)+"|"+IntegerToString(InpGridMaxPoints)+"|"+
      (InpTakeProfitEnabled?"1":"0")+"|"+IntegerToString((int)InpTakeProfitUnit)+"|"+
      IntegerToString(InpInitialTakeProfitPoints)+"|"+IntegerToString(InpBasketTakeProfitPoints)+"|"+
      DoubleToString(InpInitialTakeProfitMoney,8)+"|"+DoubleToString(InpBasketTakeProfitMoney,8)+"|"+
      (InpTrailingStopEnabled?"1":"0")+"|"+IntegerToString((int)InpTrailingUnit)+"|"+
      IntegerToString(InpTrailingActivationPoints)+"|"+IntegerToString(InpTrailingDistancePoints)+"|"+
      IntegerToString(InpTrailingStepPoints)+"|"+IntegerToString(InpTrailingMinLockPoints)+"|"+
      DoubleToString(InpTrailingActivationMoney,8)+"|"+DoubleToString(InpTrailingDistanceMoney,8)+"|"+
      DoubleToString(InpTrailingStepMoney,8)+"|"+DoubleToString(InpTrailingMinLockMoney,8)+"|"+
      IntegerToString(InpBasketTrailingActivationPoints)+"|"+IntegerToString(InpBasketTrailingDistancePoints)+"|"+
      IntegerToString(InpBasketTrailingStepPoints)+"|"+IntegerToString(InpBasketTrailingMinLockPoints)+"|"+
      DoubleToString(InpBasketTrailingActivationMoney,8)+"|"+DoubleToString(InpBasketTrailingDistanceMoney,8)+"|"+
      DoubleToString(InpBasketTrailingStepMoney,8)+"|"+DoubleToString(InpBasketTrailingMinLockMoney,8)+"|"+
      IntegerToString(InpTrailMinDistancePoints)+"|"+
      DoubleToString(InpMinMarginLevelPct,8)+"|"+DoubleToString(InpMaxBasketVolume,8)+"|"+
      DoubleToString(InpMaxSpreadATRPercent,8)+"|"+
      (InpUseTradingDays?"1":"0")+"|"+(InpTradeMonday?"1":"0")+"|"+(InpTradeTuesday?"1":"0")+"|"+
      (InpTradeWednesday?"1":"0")+"|"+(InpTradeThursday?"1":"0")+"|"+(InpTradeFriday?"1":"0")+"|"+
      (InpUseTradingHours?"1":"0")+"|"+IntegerToString(InpTradingStartHour)+"|"+IntegerToString(InpTradingStartMinute)+"|"+
      IntegerToString(InpTradingEndHour)+"|"+IntegerToString(InpTradingEndMinute)+"|"+
      (InpUseSessionFilter?"1":"0")+"|"+IntegerToString(InpBlockMinutesAfterOpen)+"|"+
      IntegerToString(InpBlockMinutesBeforeClose)+"|"+(InpForceCloseBeforeSessionEnd?"1":"0")+"|"+
      IntegerToString(InpForceCloseMinutesBefore)+"|"+DoubleToString(InpDailyProfitTarget,8)+"|"+
      (InpUseNewsFilter?"1":"0")+"|"+IntegerToString(InpMinutesBeforeNews)+"|"+IntegerToString(InpMinutesAfterNews)+"|"+
      IntegerToString((int)InpMinNewsImportance)+"|"+(InpRecoveryNewsGuardEnabled?"1":"0")+"|"+
      IntegerToString(InpRecoveryNewsMinutesBefore)+"|"+IntegerToString(InpRecoveryNewsMinutesAfter)+"|"+
      (InpUseBasketLossAlert?"1":"0")+DoubleToString(InpBasketLossAlertPct,2)+"|"+
      (InpUseRecoveryBlockOnLoss?"1":"0")+DoubleToString(InpRecoveryBlockLossPct,2)+"|"+
      (InpUseBasketLossClosePct?"1":"0")+DoubleToString(InpBasketLossClosePct,2)+"|"+
      (InpUseBasketLossCloseMoney?"1":"0")+DoubleToString(InpBasketLossCloseMoney,2)+"|"+
      (InpUseBasketMaxAgeClose?"1":"0")+DoubleToString(InpBasketMaxAgeHours,2);
   return HashText(cfg);
  }

string BuildRunID()
  {
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   string stamp=TimeToString(now,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   StringReplace(stamp,".","");
   StringReplace(stamp,":","");
   StringReplace(stamp," ","_");

   ulong tick=GetTickCount64();
   string raw=
      StringFormat("%I64d",AccountInfoInteger(ACCOUNT_LOGIN))+"_"+
      CsvSanitize(AccountInfoString(ACCOUNT_SERVER))+"_"+
      CsvSanitize(_Symbol)+"_"+StringFormat("%I64u",InpMagicNumber)+"_"+stamp+"_"+
      StringFormat("%I64u",tick);
   return raw;
  }

string StateFileName()
  {
   string server=CsvSanitize(AccountInfoString(ACCOUNT_SERVER));
   string symbol=CsvSanitize(_Symbol);
   string account=StringFormat("%I64d",AccountInfoInteger(ACCOUNT_LOGIN));
   return StringFormat("%s\\FMX_STATE_%s_%s_%s_%I64u.dat",
                       FMX_STATE_SUBFOLDER,account,server,symbol,InpMagicNumber);
  }

void StateWriteKV(int h,string key,string value)
  {
   FileWrite(h,key,value);
  }

bool SaveState(string reason)
  {
   FolderCreate(FMX_TELEMETRY_FOLDER);
   FolderCreate(FMX_STATE_SUBFOLDER);
   string fn=StateFileName();

   ResetLastError();
   int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_ANSI,';');
   if(h==INVALID_HANDLE)
     {
      Print(FMX_PRODUCT_NAME," | EVENT=STATE_SAVE_FAILED | Error=",GetLastError()," | File=",fn);
      return false;
     }

   StateWriteKV(h,"SchemaVersion",IntegerToString(FMX_SCHEMA_VERSION));
   StateWriteKV(h,"ConfigHash",gConfigHash);
   StateWriteKV(h,"Account",StringFormat("%I64d",AccountInfoInteger(ACCOUNT_LOGIN)));
   StateWriteKV(h,"Server",AccountInfoString(ACCOUNT_SERVER));
   StateWriteKV(h,"Symbol",_Symbol);
   StateWriteKV(h,"Magic",StringFormat("%I64u",InpMagicNumber));
   StateWriteKV(h,"Reason",reason);
   StateWriteKV(h,"SavedAt",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));

   StateWriteKV(h,"BasketActive",(gBasket.active?"1":"0"));
   StateWriteKV(h,"BasketID",StringFormat("%I64u",gBasket.basketId));
   StateWriteKV(h,"Direction",IntegerToString((int)gBasket.direction));
   StateWriteKV(h,"BasketStart",StringFormat("%I64d",(long)gBasket.basketStart));
   StateWriteKV(h,"RecoveryLevel",IntegerToString(gBasket.recoveryLevel));
   StateWriteKV(h,"Positions",IntegerToString(gBasket.positions));
   StateWriteKV(h,"TotalVolume",DoubleToString(gBasket.totalVolume,8));
   StateWriteKV(h,"AveragePrice",DoubleToString(gBasket.averagePrice,_Digits));
   StateWriteKV(h,"WorstEntry",DoubleToString(gBasket.worstEntry,_Digits));
   StateWriteKV(h,"LastExecutedLot",DoubleToString(gBasket.lastExecutedLot,8));
   StateWriteKV(h,"LastRecovery",StringFormat("%I64d",(long)gBasket.lastRecovery));

   int ownedIdx=0;
   double observedSL=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i);
      if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      string key="PositionTicket"+IntegerToString(ownedIdx);
      StateWriteKV(h,key,StringFormat("%I64u",(ulong)PositionGetInteger(POSITION_TICKET)));
      StateWriteKV(h,"PositionID"+IntegerToString(ownedIdx),StringFormat("%I64u",(ulong)PositionGetInteger(POSITION_IDENTIFIER)));
      ownedIdx++;
      double psl=PositionGetDouble(POSITION_SL);
      if(psl>0.0)
        {
         if(observedSL<=0.0) observedSL=psl;
         else if(gBasket.direction==POSITION_TYPE_BUY) observedSL=MathMax(observedSL,psl);
         else observedSL=MathMin(observedSL,psl);
        }
     }
   StateWriteKV(h,"CurrentSL",DoubleToString(observedSL,_Digits));

   StateWriteKV(h,"TakeProfitEnabled",(InpTakeProfitEnabled?"1":"0"));
   StateWriteKV(h,"InitialTP",IntegerToString(InpInitialTakeProfitPoints));
   StateWriteKV(h,"BasketTP",IntegerToString(InpBasketTakeProfitPoints));
   StateWriteKV(h,"LastKnownBasketTP",DoubleToString(gLastKnownBasketTP,_Digits));
   StateWriteKV(h,"TakeProfitUnit",IntegerToString((int)InpTakeProfitUnit));
   StateWriteKV(h,"InitialTPMoney",DoubleToString(InpInitialTakeProfitMoney,8));
   StateWriteKV(h,"BasketTPMoney",DoubleToString(InpBasketTakeProfitMoney,8));
   StateWriteKV(h,"TPMoneySolverOk",(gTPMoneySolverOk?"1":"0"));
   StateWriteKV(h,"TPMoneyMonitorOnly",(gTPMoneyMonitorOnly?"1":"0"));
   StateWriteKV(h,"ResolvedTPMoneyTarget",DoubleToString(gResolvedTPMoneyTarget,8));
   StateWriteKV(h,"ResolvedTPMoneyProjected",DoubleToString(gResolvedTPMoneyProjected,8));
   StateWriteKV(h,"RecoveryNewsGuardEnabled",(InpRecoveryNewsGuardEnabled?"1":"0"));
   StateWriteKV(h,"RecoveryNewsMinutesBefore",IntegerToString(InpRecoveryNewsMinutesBefore));
   StateWriteKV(h,"RecoveryNewsMinutesAfter",IntegerToString(InpRecoveryNewsMinutesAfter));
   StateWriteKV(h,"RecoveryNewsGuardState",IntegerToString((int)gRecoveryNewsState));

   StateWriteKV(h,"TrailingEnabled",(InpTrailingStopEnabled?"1":"0"));
   StateWriteKV(h,"TrailingUnit",IntegerToString((int)InpTrailingUnit));
   StateWriteKV(h,"SingleTrailingActive",(gSingleDynamicTrailActive?"1":"0"));
   StateWriteKV(h,"BasketTrailingActive",(gBasketDynamicTrailActive?"1":"0"));
   StateWriteKV(h,"TrailingPeak",DoubleToString(gTrailingPeakPrice,_Digits));
   StateWriteKV(h,"TrailingFloor",DoubleToString(gTrailingFloorPrice,_Digits));
   StateWriteKV(h,"LastCommittedStep",DoubleToString(gTrailingLastCommittedStep,_Digits));

   StateWriteKV(h,"UserPauseState",(gUserEntryPause?"1":"0"));
   StateWriteKV(h,"RecoveryArmed",(gRecoveryArmed?"1":"0"));
   StateWriteKV(h,"RecoveryArmedTime",StringFormat("%I64d",(long)gRecoveryArmedTime));
   StateWriteKV(h,"RecoveryArmedPrice",DoubleToString(gRecoveryArmedPrice,_Digits));

   FileFlush(h);
   FileClose(h);

   gStateLoaded=true;
   TelemetryWrite("POSITION_MANAGEMENT","STATE_SAVED",
                  "Reason="+reason+" | File="+fn+" | BasketActive="+(gBasket.active?"true":"false"));
   return true;
  }

bool LoadState()
  {
   gStateLoaded=false;
   gStateConfigMatch=false;

   string fn=StateFileName();
   if(!FileIsExist(fn))
     {
      TelemetryWrite("POSITION_MANAGEMENT","STATE_NOT_FOUND","File="+fn);
      return false;
     }

   ResetLastError();
   int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_ANSI,';');
   if(h==INVALID_HANDLE)
     {
      Print(FMX_PRODUCT_NAME," | EVENT=STATE_LOAD_FAILED | Error=",GetLastError()," | File=",fn);
      return false;
     }

   int stSchema=-1;
   string stConfig="";
   string stAccount="",stServer="",stSymbol="",stMagic="";
   bool stBasketActive=false;
   ulong stBasketId=0;
   datetime stBasketStart=0,stLastRecovery=0;
   double stLastTP=0.0,stPeak=0.0,stFloor=0.0,stStep=0.0;
   bool stSingleTrail=false,stBasketTrail=false,stPause=false;
   
   while(!FileIsEnding(h))
     {
      string key=FileReadString(h);
      if(FileIsEnding(h) && key=="") break;
      string val=FileReadString(h);

      if(key=="SchemaVersion") stSchema=(int)StringToInteger(val);
      else if(key=="ConfigHash") stConfig=val;
      else if(key=="Account") stAccount=val;
      else if(key=="Server") stServer=val;
      else if(key=="Symbol") stSymbol=val;
      else if(key=="Magic") stMagic=val;
      else if(key=="BasketActive") stBasketActive=(val=="1");
      else if(key=="BasketID") stBasketId=(ulong)StringToInteger(val);
      else if(key=="BasketStart") stBasketStart=(datetime)StringToInteger(val);
      else if(key=="LastRecovery") stLastRecovery=(datetime)StringToInteger(val);
      else if(key=="LastKnownBasketTP") stLastTP=StringToDouble(val);
      else if(key=="SingleTrailingActive") stSingleTrail=(val=="1");
      else if(key=="BasketTrailingActive") stBasketTrail=(val=="1");
      else if(key=="TrailingPeak") stPeak=StringToDouble(val);
      else if(key=="TrailingFloor") stFloor=StringToDouble(val);
      else if(key=="LastCommittedStep") stStep=StringToDouble(val);
      else if(key=="UserPauseState") stPause=(val=="1");
     }

   FileClose(h);

   if(stSchema!=FMX_SCHEMA_VERSION)
     {
      TelemetryWrite("RISK_STATE","STATE_SCHEMA_MISMATCH",
                     "Stored="+IntegerToString(stSchema)+
                     " | Current="+IntegerToString(FMX_SCHEMA_VERSION)+
                     " | Action=BROKER_RECONSTRUCTION_ONLY");
      return false;
     }

   string currentAccount=StringFormat("%I64d",AccountInfoInteger(ACCOUNT_LOGIN));
   string currentMagic=StringFormat("%I64u",InpMagicNumber);
   if(stAccount!=currentAccount || stServer!=AccountInfoString(ACCOUNT_SERVER) ||
      stSymbol!=_Symbol || stMagic!=currentMagic)
     {
      Print(FMX_PRODUCT_NAME," | EVENT=STATE_IDENTITY_MISMATCH | File=",fn);
      TelemetryWrite("RISK_STATE","STATE_IDENTITY_MISMATCH","File="+fn);
      return false;
     }

   gStateLoaded=true;
   gStateConfigMatch=(stConfig==gConfigHash);

   // Broker reality vai reconstruir volume, media, pior entrada e RecoveryLevel.
   // Do state restauramos somente identidade e protecoes que nao sao inferiveis
   // com seguranca a partir do snapshot atual.
   if(stBasketActive)
     {
      gBasket.basketId=stBasketId;
      gBasket.basketStart=stBasketStart;
      gBasket.lastRecovery=stLastRecovery;
     }

   gLastKnownBasketTP=stLastTP;
   gUserEntryPause=stPause;

   if(gStateConfigMatch)
     {
      gSingleDynamicTrailActive=stSingleTrail;
      gBasketDynamicTrailActive=stBasketTrail;
      gTrailingPeakPrice=stPeak;
      gTrailingFloorPrice=stFloor;
      gTrailingLastCommittedStep=stStep;
      // Recovery authorization never survives restart. Re-evaluate Grid + News + gates from current broker reality.
      gRecoveryArmed=false;
      gRecoveryArmedTime=0;
      gRecoveryArmedPrice=0.0;
     }
   else
     {
      gSingleDynamicTrailActive=false;
      gBasketDynamicTrailActive=false;
      gTrailingPeakPrice=0.0;
      gTrailingFloorPrice=0.0;
      gTrailingLastCommittedStep=0.0;
      gRecoveryArmed=false;
      TelemetryWrite("RISK_STATE","STATE_CONFIG_MISMATCH",
                     "Stored="+stConfig+" | Current="+gConfigHash+
                     " | Action=BROKER_REALITY_RECONCILIATION");
     }

   TelemetryWrite("POSITION_MANAGEMENT","STATE_LOADED",
                  "ConfigMatch="+(gStateConfigMatch?"true":"false")+
                  " | StoredBasket="+(stBasketActive?"true":"false"));
   return true;
  }

int CountOwnedPositions()
  {
   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string sym=PositionGetSymbol(i);
      if(sym!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      count++;
     }
   return count;
  }

int CountOwnedOrders()
  {
   int count=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0) continue;
      if(OrderGetString(ORDER_SYMBOL)!=_Symbol) continue;
      if((ulong)OrderGetInteger(ORDER_MAGIC)!=InpMagicNumber) continue;
      count++;
     }
   return count;
  }

void ReconcileStartupState()
  {
   gStartupReconciled=false;
   gRecoveryReconciliation=false;

   // Ordem obrigatoria de reconciliacao: positions -> orders -> history.
   RefreshBasketState();
   int owned=CountOwnedPositions();
   int ownedOrders=CountOwnedOrders();

   datetime histFrom=(gBasket.basketStart>0 ? gBasket.basketStart-86400 : TimeCurrent()-30*86400);
   HistorySelect(histFrom,TimeCurrent());

   if(ownedOrders>0)
     {
      // Este EA envia market orders sincronas e nao mantem pending orders como
      // parte da estrategia. Uma ordem owned ainda ativa no startup e' estado
      // excepcional e bloqueia nova exposicao ate reconciliacao explicita.
      gRecoveryReconciliation=true;
      TelemetryWrite("EXECUTION","OWNED_ACTIVE_ORDERS_ON_STARTUP",
                     "Count="+IntegerToString(ownedOrders));
      LogEvent("OWNED_ACTIVE_ORDERS_ON_STARTUP",
               "Count="+IntegerToString(ownedOrders)+" | Action=BLOCK_NEW_EXPOSURE");
     }

   if(owned>0)
     {
      if(!gStateLoaded)
        {
         gRecoveryReconciliation=true;
         TelemetryWrite("POSITION_MANAGEMENT","RECOVERY_RECONCILIATION",
                        "StateAbsent=true | OwnedPositions="+IntegerToString(owned));
        }

      RefreshBasketState();

      // Em conta hedging, pernas owned sao observaveis individualmente.
      gBasket.recoveryLevel=(gBasket.positions>0 ? gBasket.positions-1 : 0);

      // Reconcilia protecao broker-proven. Nunca inventa peak historico.
      bool anySL=false;
      double brokerFloor=0.0;
      for(int i=PositionsTotal()-1;i>=0;i--)
        {
         string sym=PositionGetSymbol(i);
         if(sym!=_Symbol) continue;
         if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;

         double sl=PositionGetDouble(POSITION_SL);
         if(sl<=0.0) continue;
         anySL=true;
         if(brokerFloor<=0.0) brokerFloor=sl;
         else if(gBasket.direction==POSITION_TYPE_BUY) brokerFloor=MathMax(brokerFloor,sl);
         else brokerFloor=MathMin(brokerFloor,sl);
        }

      if(!InpTrailingStopEnabled)
        {
         // Nao existe outra autoridade que instale SL por posicao.
         // Portanto, com trailing explicitamente OFF, um SL legado nao pode
         // permanecer governando silenciosamente o cesto.
         if(anySL)
           {
            for(int i=PositionsTotal()-1;i>=0;i--)
              {
               string sym=PositionGetSymbol(i);
               if(sym!=_Symbol) continue;
               if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
               ulong ticket=(ulong)PositionGetInteger(POSITION_TICKET);
               double tp=PositionGetDouble(POSITION_TP);
               SafePositionModify(ticket,0.0,tp,"TRAILING_DISABLED_RECONCILE");
              }
           }
         gSingleDynamicTrailActive=false;
         gBasketDynamicTrailActive=false;
         gTrailingPeakPrice=0.0;
         gTrailingFloorPrice=0.0;
         gTrailingLastCommittedStep=0.0;
        }
      else if(anySL)
        {
         // O SL confirmado no broker e a autoridade factual. O pico historico
         // permanece desconhecido; o proximo tick so pode apertar, nunca afrouxar.
         gSingleDynamicTrailActive=(gBasket.positions==1);
         gBasketDynamicTrailActive=(gBasket.positions>1);
         gTrailingFloorPrice=brokerFloor;
         gTrailingLastCommittedStep=brokerFloor;
         gTrailingPeakPrice=0.0;
         TelemetryWrite("POSITION_MANAGEMENT","TRAILING_RESTORED_FROM_BROKER",
                        "Scope="+(gBasket.positions==1?"SINGLE":"BASKET")+
                        " | Floor="+DoubleToString(brokerFloor,_Digits));
        }
      else if(!gStateLoaded || !gStateConfigMatch)
        {
         gSingleDynamicTrailActive=false;
         gBasketDynamicTrailActive=false;
         gTrailingPeakPrice=0.0;
         gTrailingFloorPrice=0.0;
         gTrailingLastCommittedStep=0.0;
        }

      // Stale Recovery decision is never trusted across restart, even with a valid state file.
      gRecoveryArmed=false;
      gRecoveryArmedTime=0;
      gRecoveryArmedPrice=0.0;
      gDecisionID="";

      // TP estatico e reconciliado com a media real. SafePositionModify
      // preserva broker constraints e confirma o estado depois da chamada.
      if(InpTakeProfitEnabled) UpdateStaticBasketTP();
      else ClearOwnedTakeProfits();

      gRecoveryReconciliation=(ownedOrders>0);
      gStartupReconciled=true;
      SaveState("STARTUP_RECONCILED");
      TelemetryWrite("POSITION_MANAGEMENT","STARTUP_RECONCILED",
                     "OwnedPositions="+IntegerToString(owned)+
                     " | OwnedOrders="+IntegerToString(ownedOrders)+
                     " | RecoveryLevel="+IntegerToString(gBasket.recoveryLevel)+
                     " | StateLoaded="+(gStateLoaded?"true":"false")+
                     " | BrokerSL="+(anySL?"true":"false")+
                     " | NewExposureBlocked="+(gRecoveryReconciliation?"true":"false"));
      return;
     }

   ResetBasketStruct(gBasket);
   gRecoveryArmed=false;
   gSingleDynamicTrailActive=false;
   gBasketDynamicTrailActive=false;
   gTrailingPeakPrice=0.0;
   gTrailingFloorPrice=0.0;
   gTrailingLastCommittedStep=0.0;
   gRecoveryReconciliation=(ownedOrders>0);
   gStartupReconciled=true;

   TelemetryWrite("POSITION_MANAGEMENT","STARTUP_RECONCILED",
                  "OwnedPositions=0 | OwnedOrders="+IntegerToString(ownedOrders)+
                  " | StateLoaded="+(gStateLoaded?"true":"false")+
                  " | NewExposureBlocked="+(gRecoveryReconciliation?"true":"false"));
  }

void ReconcileConnectionState(string reason)
  {
   bool beforeActive=gBasket.active;
   int beforePositions=gBasket.positions;

   RefreshBasketState();
   int ownedOrders=CountOwnedOrders();
   HistorySelect(TimeCurrent()-7*86400,TimeCurrent());

   if(ownedOrders>0)
      gRecoveryReconciliation=true;
   else if(gBasket.active || CountOwnedPositions()==0)
      gRecoveryReconciliation=false;

   if(gPendingRequestReconcile)
      ReconcilePendingRequest();

   TelemetryWrite("POSITION_MANAGEMENT","CONNECTION_RECONCILED",
                  "Reason="+reason+
                  " | BeforeActive="+(beforeActive?"true":"false")+
                  " | BeforePositions="+IntegerToString(beforePositions)+
                  " | NowActive="+(gBasket.active?"true":"false")+
                  " | NowPositions="+IntegerToString(gBasket.positions)+
                  " | OwnedOrders="+IntegerToString(ownedOrders)+
                  " | Reconciliation="+(gRecoveryReconciliation?"true":"false"));

   SaveState("CONNECTION_RECONCILED");
  }

void MarkPendingRequest(string kind,int positionsBefore)
  {
   // Somente uma falha de envio em ambiente possivelmente desconectado/ambigua
   // exige reconciliacao. Enquanto pendente, nenhuma nova exposicao e enviada.
   gPendingRequestReconcile=true;
   gPendingPositionsBefore=positionsBefore;
   gPendingRequestSince=TimeCurrent();
   gPendingRequestKind=kind;
   TelemetryWrite("EXECUTION","REQUEST_PENDING_RECONCILIATION",
                  "Kind="+kind+" | PositionsBefore="+IntegerToString(positionsBefore));
  }

void ReconcilePendingRequest()
  {
   if(!gPendingRequestReconcile) return;
   if(!(bool)TerminalInfoInteger(TERMINAL_CONNECTED)) return;

   RefreshBasketState();
   int nowPositions=CountOwnedPositions();
   int nowOrders=CountOwnedOrders();

   if(nowPositions>gPendingPositionsBefore)
     {
      TelemetryWrite("EXECUTION","REQUEST_RECONCILED",
                     "Result=POSITION_CONFIRMED | Kind="+gPendingRequestKind+
                     " | Positions="+IntegerToString(nowPositions));
      gPendingRequestReconcile=false;
      gExpectedPositions=0;
      SaveState("REQUEST_RECONCILED");
      return;
     }

   if(nowOrders>0)
     {
      TelemetryWrite("EXECUTION","REQUEST_RECONCILIATION_WAIT",
                     "Result=ACTIVE_OWNED_ORDER | Kind="+gPendingRequestKind+
                     " | Orders="+IntegerToString(nowOrders));
      return;
     }

   datetime from=gPendingRequestSince-5;
   if(from<0) from=0;
   bool foundIn=false;
   bool foundOut=false;

   if(HistorySelect(from,TimeCurrent()))
     {
      int total=HistoryDealsTotal();
      for(int i=0;i<total;i++)
        {
         ulong d=HistoryDealGetTicket(i);
         if(d==0) continue;
         if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
         if((ulong)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagicNumber) continue;

         ENUM_DEAL_ENTRY en=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(d,DEAL_ENTRY);
         if(en==DEAL_ENTRY_IN || en==DEAL_ENTRY_INOUT) foundIn=true;
         if(en==DEAL_ENTRY_OUT || en==DEAL_ENTRY_OUT_BY || en==DEAL_ENTRY_INOUT) foundOut=true;
        }
     }

   // Houve entrada e depois saida, e nao existe exposicao adicional:
   // a solicitacao terminou sem posicao viva e pode ser liberada.
   if(foundIn && foundOut && nowPositions<=gPendingPositionsBefore)
     {
      TelemetryWrite("EXECUTION","REQUEST_RECONCILED",
                     "Result=ENTRY_AND_EXIT_CONFIRMED | Kind="+gPendingRequestKind);
      gPendingRequestReconcile=false;
      gExpectedPositions=0;
      SaveState("REQUEST_RECONCILED");
      return;
     }

   // Entrada broker-proven sem posicao ainda visivel: permanecer fail-closed.
   if(foundIn && !foundOut)
     {
      if((TimeCurrent()-gPendingRequestSince)>=30)
         TelemetryWrite("EXECUTION","REQUEST_RECONCILIATION_WAIT",
                        "Result=ENTRY_DEAL_WITHOUT_VISIBLE_POSITION | Kind="+gPendingRequestKind);
      return;
     }

   // Sem qualquer evidencia broker-proven por 60 s conectado: classifica
   // a tentativa ambigua como nao executada e libera nova avaliacao.
   if((TimeCurrent()-gPendingRequestSince)>=60)
     {
      TelemetryWrite("EXECUTION","REQUEST_RECONCILED",
                     "Result=NO_BROKER_EVIDENCE | Kind="+gPendingRequestKind+
                     " | BlockReleasedAfterSec=60");
      gPendingRequestReconcile=false;
      gExpectedPositions=0;
     }
  }

