//+------------------------------------------------------------------+
//|                                                  PieceTrend.mq5   |
//|        Price Action Trend Following Expert Advisor for MT5       |
//|        No external indicators / no martingale / no recovery     |
//+------------------------------------------------------------------+
#property strict
#property version   "1.10"
#property description "PieceTrend - Price Action Trend Following"
#property description "Structure -> Trend -> Context -> Invalidation -> Risk -> Trigger -> Execution"

#include <Trade/Trade.mqh>
#include <Canvas\Canvas.mqh>

//====================================================================
// INPUTS
//====================================================================
input group "ENGINE"
input bool            InpEnableTrading     = true;
input int             InpInstanceID        = 1;
input long            InpMagicNumber       = 0;      // 0 = deterministic automatic magic
input bool            InpDebug             = false;

input group "RISK"
input bool            InpUseFixedLot       = true;
input double          InpFixedLot          = 0.01;
input bool            InpRiskEnable        = true;
input double          InpRiskMoneyPerTrade = 2.00;
input bool            InpSpreadFilterEnable = true;
input double          InpMaxSpreadPoints   = 30.0;
input bool            InpStopLossEnable    = false;
input bool            InpMaxStopPointsEnable = false;
input double          InpMaxStopPoints     = 0.0;
input bool            InpMaxLossMoneyEnable = false;
input double          InpMaxLossMoney      = 10.0;
input bool            InpEmergencyLossEnable = false;
input double          InpEmergencyLossMoney  = 20.0;

input group "PROFIT"
input bool            InpTPEnable          = true;
input double          InpTPMoney           = 10.0;
input bool            InpTrailEnable       = true;
input double          InpTrailActivationMoney = 5.0;

input group "DAILY"
input bool            InpDailyTargetEnable = false;
input double          InpDailyTargetMoney = 20.0;
input bool            InpDailyLossLimitEnable = false;
input double          InpDailyLossLimitMoney  = 20.0;

input group "PANEL"
input bool            InpShowPanel         = true;
input int             InpPanelX            = 18;
input int             InpPanelY            = 24;
input bool            InpPanelStartMinimized = false;

input group "DRAWING"
input bool            InpDrawStructure     = true;
input bool            InpDrawZones         = true;
input bool            InpDrawChannel       = true;
input bool            InpDrawTradeMarkers  = true;
input bool            InpDrawLabels        = true;

input group "TELEMETRY"
input bool            InpWriteCSV          = true;
input bool            InpWriteHeartbeat    = true;
input int             InpHeartbeatSeconds  = 5;

//====================================================================
// CONSTANTS / INTERNAL PARAMETERS
//====================================================================
#define PT_PREFIX                "PieceTrend_"
#define PT_PANEL_PREFIX          "PTP_"
#define PT_CORE_FILE             "PieceTrend_"

const int    PT_SWING_RADIUS       = 2;
const int    PT_PROM_WINDOW        = 5;
const int    PT_PA_SCALE_BARS      = 20;
const int    PT_MICRO_SCALE_BARS   = 8;
const double PT_MICRO_PROM_FACTOR  = 0.20;
const int    PT_MICRO_SWING_RADIUS  = 1;
const int    PT_MICRO_PROM_WINDOW   = 2;
const double PT_MAJOR_PROM_FACTOR  = 0.60;
const double PT_HH_BUFFER_FACTOR = 0.10;
const double PT_HL_BUFFER_FACTOR = 0.05;
const double PT_ZONE_FACTOR        = 0.30;
const double PT_BREAK_FACTOR       = 0.10;
const double PT_RETEST_LOW_FACTOR  = 0.30;
const double PT_RETEST_HIGH_FACTOR = 0.20;
const double PT_TRIGGER_BUFFER     = 0.05;
const double PT_STOP_BUFFER_FACTOR = 0.10;
const double PT_MIN_STOP_FACTOR    = 2.0;
const double PT_TRAIL_RATIO        = 0.60;
const double PT_TRAIL_EXPONENT     = 0.82;
const double PT_MAX_RISK_NORM      = 2.50;
const double PT_MIN_SPACE_RATIO    = 0.70;
const double PT_CHASE_FACTOR       = 0.25;
// FIX v1.10: setup engine rebalanced; micro window independent; defense thresholds retained (antes 0.55/0.35 e 0.25/0.45 saturavam quase sempre)
const double PT_PE_DIRECTIONAL     = 0.30;
const double PT_PE_MIXED           = 0.12;
const double PT_WHIP_CAUTION       = 0.50;
const double PT_WHIP_DEFENSIVE     = 0.70;
const double PT_EXPANSION          = 1.80;
const double PT_EXPANSION_EXTREME  = 2.50;
// FIX v1.01/v1.10: faixas do score de defesa
const double PT_DEF_CAUTION_SCORE   = 40.0;
const double PT_DEF_DEFENSIVE_SCORE = 60.0;
const double PT_DEF_HARD_SCORE      = 80.0;
const int    PT_LOSS_CAUTION       = 2;
const int    PT_LOSS_COOLDOWN      = 3;
const int    PT_COOLDOWN_MIN_BARS  = 6;
#define PT_MAX_SWINGS_STORE    32
const int    PT_MAX_SCAN_BARS      = 1000;

//====================================================================
// ENUMS / STRUCTS
//====================================================================
enum ENUM_PT_DIRECTION
  {
   PT_DIR_NONE = 0,
   PT_DIR_BUY  = 1,
   PT_DIR_SELL = -1
  };

enum ENUM_PT_TREND_STATE
  {
   PT_TREND_NONE = 0,
   PT_TREND_BUY,
   PT_TREND_SELL,
   PT_TREND_TRANSITION
  };

enum ENUM_PT_CONTEXT
  {
   PT_CTX_NO_TREND = 0,
   PT_CTX_IMPULSE,
   PT_CTX_PULLBACK,
   PT_CTX_RETEST,
   PT_CTX_SWEEP,
   PT_CTX_TRANSITION,
   PT_CTX_RANGE,
   PT_CTX_DEFENSIVE
  };

enum ENUM_PT_SETUP
  {
   PT_SETUP_NONE = 0,
   PT_SETUP_PULLBACK_REJECTION,
   PT_SETUP_BREAK_RETEST,
   PT_SETUP_SWEEP_RECLAIM
  };

enum ENUM_PT_DEFENSE
  {
   PT_DEF_NORMAL = 0,
   PT_DEF_CAUTION,
   PT_DEF_DEFENSIVE,
   PT_DEF_HARD
  };

enum ENUM_PT_STATE
  {
   PT_STATE_INIT = 0,
   PT_STATE_SCANNING,
   PT_STATE_NO_TREND,
   PT_STATE_TREND_READY,
   PT_STATE_CONTEXT_BUILDING,
   PT_STATE_SETUP_ARMED,
   PT_STATE_TRIGGER_WAIT,
   PT_STATE_ENTRY_READY,
   PT_STATE_ORDER_SENT,
   PT_STATE_POSITION_OPEN,
   PT_STATE_POSITION_MANAGING,
   PT_STATE_DAY_LOCK,
   PT_STATE_COOLDOWN,
   PT_STATE_DEFENSIVE_LOCK,
   PT_STATE_PAUSED
  };

struct PTSwing
  {
   int      index;
   datetime time;
   double   price;
   double   prominence;
   bool     isHigh;
   bool     major;
  };

struct PTZone
  {
   bool     active;
   int      id;
   int      direction;
   string   type;
   double   low;
   double   high;
   double   score;
   datetime time;
  };

struct PTCandidate
  {
   bool      active;
   int       direction;
   ENUM_PT_SETUP setup;
   double    score;
   double    zoneLow;
   double    zoneHigh;
   double    triggerHigh;
   double    triggerLow;
   double    plannedEntry;
   double    invalidation;
   double    riskDistance;
   double    riskNorm;
   double    nearestObstacle;
   double    spaceDistance;
   double    spaceRatio;
   int       triggerBar;
   datetime  eventTime;
   string    eventId;
   string    reasonCode;
   string    reasonDetail;
  };

//====================================================================
// GLOBALS
//====================================================================
CTrade g_trade;

long                g_magic = 0;
ENUM_TIMEFRAMES     g_workTF = PERIOD_CURRENT;
ulong               g_eventSeq = 0;
datetime            g_lastBarTime = 0;
datetime            g_dayStart = 0;
datetime            g_lastHeartbeatTime = 0;
datetime            g_lastDailyNetCalc = 0;
double              g_cachedDailyNet = 0.0;
bool                g_tfValid = false;
int                 g_loadedBars = 0;
datetime            g_lastAnalysisBar = 0;
datetime            g_lastDrawingUpdate = 0;
bool                g_hudBgDirty = true;
int                 g_hudLastHeight = 0;

// Convencao: [0] = pivo MAIS RECENTE, [1] = anterior, ...
PTSwing             g_majorHighs[PT_MAX_SWINGS_STORE];
PTSwing             g_majorLows[PT_MAX_SWINGS_STORE];
PTSwing             g_microHighs[PT_MAX_SWINGS_STORE];
PTSwing             g_microLows[PT_MAX_SWINGS_STORE];
int                 g_majorHighCount = 0;
int                 g_majorLowCount  = 0;
int                 g_microHighCount = 0;
int                 g_microLowCount  = 0;

ENUM_PT_TREND_STATE g_trendState = PT_TREND_NONE;
ENUM_PT_CONTEXT     g_context = PT_CTX_NO_TREND;
ENUM_PT_DEFENSE     g_defense = PT_DEF_NORMAL;
ENUM_PT_STATE       g_state = PT_STATE_INIT;
int                 g_direction = PT_DIR_NONE;

double              g_paScale = 0.0;
double              g_microScale = 0.0;
double              g_trendScore = 0.0;
double              g_structureScore = 0.0;
double              g_continuationScore = 0.0;
double              g_pullbackQuality = 0.0;
double              g_recencyScore = 0.0;
double              g_pathEfficiency = 0.0;
double              g_whipsawIndex = 0.0;
double              g_rangeRatio = 0.0;
double              g_defenseScore = 0.0;

PTZone              g_zone;
PTCandidate         g_candidate;
int                 g_consecutiveLosses = 0;
int                 g_consecutiveWins   = 0;
datetime            g_cooldownUntilBar = 0;

bool                g_paused = false;
bool                g_panelMinimized = false;
bool                g_mapVisible = true;
bool                g_labelsVisible = true;
int                 g_panelX = 18;
int                 g_panelY = 24;

ulong               g_positionTicket = 0;
long                g_positionId = 0;
double              g_entryPrice = 0.0;
double              g_positionVolume = 0.0;
double              g_plannedRiskMoney = 0.0;
double              g_plannedVolume = 0.0;
double              g_positionMaxProfit = 0.0;
double              g_positionHighWaterPrice = 0.0;
double              g_currentProfit = 0.0;
double              g_currentTrailDistanceMoney = 0.0;
double              g_currentTrailDistancePrice = 0.0;
double              g_currentTrailStop = 0.0;
double              g_lockedProfit = 0.0;
bool                g_trailActive = false;
double              g_virtualInvalidation = 0.0;
double              g_positionTP = 0.0;
string              g_positionSetup = "";
string              g_positionTrigger = "";
string              g_positionEventId = "";
datetime            g_positionEntryTime = 0;

long                g_lastProcessedDeal = 0;
string              g_pendingExitReason = "";
int                 g_dailyTrailActivated = 0;
double              g_dailyTrailClosedProfit = 0.0;
double              g_dailyTpClosedProfit = 0.0;
double              g_dailySlClosedProfit = 0.0;
double              g_dailyEmergencyClosedProfit = 0.0;
int                 g_dailyDefensiveEvents = 0;
int                 g_dailyCooldownEvents = 0;

//====================================================================
// FORWARD DECLARATIONS
//====================================================================
void ResetCandidate();
void ResetZone();
void AnalyzeNewBar();
void ManagePosition();
void UpdatePanel();
void UpdateDrawings();
void WriteCoreEvent(string eventType,string reasonCode,string reasonDetail,string action="");
void ChannelMetrics(string &state,double &slope,double &integrity);
void WritePriceAction();
void WriteTradeEvent(string eventType,string exitReason="");
void WriteDailySnapshot();
void WriteError(string stage,string operation,int errorCode,long tradeRetcode,string reason,string details);
bool ModifyPositionStops(double sl,double tp);
bool DailyEntryBlockedCode();

//====================================================================
// UTILITY
//====================================================================
string TFToString(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_M15:return "M15";
     }
   return EnumToString(tf);
  }

string DirectionToString(int dir)
  {
   if(dir==PT_DIR_BUY) return "BUY";
   if(dir==PT_DIR_SELL) return "SELL";
   return "NONE";
  }

string TrendToString(ENUM_PT_TREND_STATE s)
  {
   if(s==PT_TREND_BUY) return "BUY";
   if(s==PT_TREND_SELL) return "SELL";
   if(s==PT_TREND_TRANSITION) return "TRANSITION";
   return "NONE";
  }

string ContextToString(ENUM_PT_CONTEXT c)
  {
   switch(c)
     {
      case PT_CTX_IMPULSE: return "IMPULSE";
      case PT_CTX_PULLBACK: return "PULLBACK";
      case PT_CTX_RETEST: return "RETEST";
      case PT_CTX_SWEEP: return "SWEEP";
      case PT_CTX_TRANSITION: return "TRANSITION";
      case PT_CTX_RANGE: return "RANGE";
      case PT_CTX_DEFENSIVE: return "DEFENSIVE";
     }
   return "NO_TREND";
  }

string SetupToString(ENUM_PT_SETUP s)
  {
   if(s==PT_SETUP_PULLBACK_REJECTION) return "PULLBACK_REJECTION";
   if(s==PT_SETUP_BREAK_RETEST) return "BREAK_RETEST";
   if(s==PT_SETUP_SWEEP_RECLAIM) return "SWEEP_RECLAIM";
   return "NONE";
  }

string DefenseToString(ENUM_PT_DEFENSE d)
  {
   if(d==PT_DEF_CAUTION) return "CAUTION";
   if(d==PT_DEF_DEFENSIVE) return "DEFENSIVE";
   if(d==PT_DEF_HARD) return "HARD";
   return "NORMAL";
  }

string StateToString(ENUM_PT_STATE s)
  {
   switch(s)
     {
      case PT_STATE_SCANNING: return "SCANNING";
      case PT_STATE_NO_TREND: return "NO_TREND";
      case PT_STATE_TREND_READY: return "TREND_READY";
      case PT_STATE_CONTEXT_BUILDING: return "CONTEXT_BUILDING";
      case PT_STATE_SETUP_ARMED: return "SETUP_ARMED";
      case PT_STATE_TRIGGER_WAIT: return "TRIGGER_WAIT";
      case PT_STATE_ENTRY_READY: return "ENTRY_READY";
      case PT_STATE_ORDER_SENT: return "ORDER_SENT";
      case PT_STATE_POSITION_OPEN: return "POSITION_OPEN";
      case PT_STATE_POSITION_MANAGING: return "POSITION_MANAGING";
      case PT_STATE_DAY_LOCK: return "DAY_LOCK";
      case PT_STATE_COOLDOWN: return "COOLDOWN";
      case PT_STATE_DEFENSIVE_LOCK: return "DEFENSIVE_LOCK";
      case PT_STATE_PAUSED: return "PAUSED";
     }
   return "INIT";
  }

string PriceToString(double p)
  {
   if(p<=0.0) return "-";
   return DoubleToString(p,_Digits);
  }

string MoneyToString(double v)
  {
   return StringFormat("%s%.2f",(v<0?"-":""),MathAbs(v));
  }

double Clamp(double v,double lo,double hi)
  {
   if(v<lo) return lo;
   if(v>hi) return hi;
   return v;
  }

double SafeDiv(const double numerator,const double denominator,const double fallback=0.0)
  {
   if(!MathIsValidNumber(numerator) || !MathIsValidNumber(denominator))
      return fallback;
   if(MathAbs(denominator)<1.0e-12)
      return fallback;
   return numerator/denominator;
  }


double MedianFromArray(double &src[])
  {
   int n=ArraySize(src);
   if(n<=0) return 0.0;
   double temp[];
   ArrayResize(temp,n);
   for(int i=0;i<n;i++) temp[i]=src[i];
   ArraySort(temp);
   if((n%2)==1) return temp[n/2];
   return 0.5*(temp[n/2-1]+temp[n/2]);
  }

double BarRange(const MqlRates &r)
  {
   return MathMax(r.high-r.low,_Point);
  }

int TFMinutes(ENUM_TIMEFRAMES tf)
  {
   if(tf==PERIOD_M1)  return 1;
   if(tf==PERIOD_M5)  return 5;
   if(tf==PERIOD_M15) return 15;
   return 5;
  }

string TFModeText()
  {
   return "AUTO";
  }

bool ResolveWorkTimeframe()
  {
   g_workTF=(ENUM_TIMEFRAMES)_Period;
   g_tfValid=(g_workTF==PERIOD_M1 || g_workTF==PERIOD_M5 || g_workTF==PERIOD_M15);
   return g_tfValid;
  }

int RequiredStructuralBars()
  {
   return MathMin(PT_MAX_SCAN_BARS,MathMax(48,(int)MathRound(720.0/TFMinutes(g_workTF))));
  }

int RequiredContextBars()
  {
   return MathMin(PT_MAX_SCAN_BARS,MathMax(24,(int)MathRound(240.0/TFMinutes(g_workTF))));
  }

int RequiredMicroBars()
  {
   return MathMax(2,(int)MathRound(30.0/TFMinutes(g_workTF)));
  }

void ChannelMetrics(string &state,double &slope,double &integrity)
  {
   state="NONE"; slope=0.0; integrity=0.0;
   if(g_majorHighCount<2 || g_majorLowCount<2) return;
   double barsH=MathMax(1.0,(double)MathAbs(g_majorHighs[1].index-g_majorHighs[0].index));
   double barsL=MathMax(1.0,(double)MathAbs(g_majorLows[1].index-g_majorLows[0].index));
   double sh=(g_majorHighs[0].price-g_majorHighs[1].price)/barsH;
   double sl=(g_majorLows[0].price-g_majorLows[1].price)/barsL;
   slope=0.5*(sh+sl);
   double slopeScale=MathMax(g_paScale/MathMax((double)RequiredStructuralBars(),1.0),_Point);
   integrity=1.0-Clamp(MathAbs(sh-sl)/MathMax(slopeScale,_Point),0.0,1.0);
   if(sh>0.0 && sl>0.0) state="UP";
   else if(sh<0.0 && sl<0.0) state="DOWN";
   else state="MIXED";
  }

string DayKey(datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return StringFormat("%04d%02d%02d",dt.year,dt.mon,dt.day);
  }

datetime StartOfServerDay(datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t,dt);
   dt.hour=0; dt.min=0; dt.sec=0;
   return StructToTime(dt);
  }

bool IsOurPositionSelected()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC)==g_magic) return true;
     }
   return false;
  }

bool HasAnySymbolPosition()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol) return true;
     }
   return false;
  }

int OurPositionCount()
  {
   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC)!=g_magic) continue;
      count++;
     }
   return count;
  }

bool SelectOurPosition()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC)!=g_magic) continue;
      g_positionTicket=ticket;
      return true;
     }
   return false;
  }

//====================================================================
// MAGIC
//====================================================================
uint HashFNV1a(string s)
  {
   uint hash=2166136261;
   int n=StringLen(s);
   for(int i=0;i<n;i++)
     {
      ushort ch=StringGetCharacter(s,i);
      hash ^= (uint)ch;
      hash *= 16777619;
     }
   return hash;
  }

long CalculateMagic()
  {
   if(InpMagicNumber>0) return InpMagicNumber;
   string seed="PieceTrend|"+_Symbol+"|"+TFToString(g_workTF)+"|"+IntegerToString(InpInstanceID)+"|PT-20261001";
   uint h=HashFNV1a(seed);
   return (long)(700000000 + (h % 900000000));
  }

bool TradeResultSucceeded()
  {
   uint rc=g_trade.ResultRetcode();
   return (rc==TRADE_RETCODE_DONE || rc==TRADE_RETCODE_DONE_PARTIAL || rc==TRADE_RETCODE_PLACED || rc==TRADE_RETCODE_NO_CHANGES);
  }

//====================================================================
// FILE NAMES / CSV
//====================================================================
string BaseCsvName()
  {
   return PT_CORE_FILE+_Symbol+"_"+TFToString(g_workTF);
  }

string CoreFileName()         { return BaseCsvName()+"_CORE.csv"; }
string PriceActionFileName()  { return BaseCsvName()+"_PRICEACTION.csv"; }
string TradesFileName()       { return BaseCsvName()+"_TRADES.csv"; }
string DailyFileName()        { return BaseCsvName()+"_DAILY.csv"; }
string ErrorsFileName()       { return BaseCsvName()+"_ERRORS.csv"; }

void EnsureHeader(string fileName,string header)
  {
   if(!InpWriteCSV) return;
   int h=FileOpen(fileName,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE)
     {
      h=FileOpen(fileName,FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
      if(h==INVALID_HANDLE) return;
     }
   if(FileSize(h)==0)
     {
      string cols[];
      int count=StringSplit(header,';',cols);
      if(count>0)
        {
         for(int i=0;i<count;i++) FileWriteString(h,cols[i]+(i<count-1?";":"\r\n"));
        }
     }
   FileClose(h);
  }

void InitCsvFiles()
  {
   string core="timestamp;server_date;server_time;symbol;timeframe;magic;instance_id;event_seq;event_id;event_type;system_state;direction;trend_state;trend_score;structure_state;context_class;setup_type;setup_score;trigger_type;trigger_state;bid;ask;spread_points;spread_money;pa_scale;micro_scale;last_hh;last_hl;last_lh;last_ll;zone_id;zone_type;zone_low;zone_high;zone_score;planned_entry;actual_entry;invalidation;risk_distance_points;risk_distance_norm;risk_money;volume_planned;volume_executed;nearest_obstacle;space_distance;space_ratio;tp_enabled;tp_money;tp_price;trail_enabled;trail_active;trail_activation_money;trail_max_profit;trail_distance_money;trail_distance_price;trail_stop_price;locked_profit;daily_net;daily_target;daily_loss;daily_loss_limit;consecutive_wins;consecutive_losses;path_efficiency;whipsaw_index;range_ratio;defense_score;defense_state;cooldown_remaining;action;reason_code;reason_detail;order_ticket;deal_ticket;position_ticket;floating_profit;closed_trade_profit;time_in_trade;mql_retcode";
   EnsureHeader(CoreFileName(),core);
   string pa="timestamp;bar_time;symbol;timeframe;pa_scale;micro_scale;swing_high_1;swing_high_2;swing_high_3;swing_low_1;swing_low_2;swing_low_3;last_hh;last_hl;last_lh;last_ll;structure_state;trend_direction;trend_score;structure_score;continuation_score;pullback_quality;recency_score;last_impulse;previous_impulse;pullback_size;pullback_ratio;context_class;context_direction;context_strength;break_detected;break_direction;break_distance;retest_active;sweep_active;sweep_direction;zone_id;zone_type;zone_low;zone_high;zone_score;channel_state;channel_slope;channel_integrity;candidate_direction;candidate_setup;candidate_score;planned_entry;planned_invalidation;planned_risk_distance;nearest_obstacle;space_ratio;path_efficiency;whipsaw_index;range_ratio";
   EnsureHeader(PriceActionFileName(),pa);
   string tr="timestamp;symbol;timeframe;magic;event_seq;event_type;position_id;order_ticket;deal_ticket;side;volume;planned_entry;requested_price;fill_price;sl_before;sl_after;tp_before;tp_after;floating_profit;max_profit;trail_distance_money;trail_stop_price;locked_profit;gross_profit;commission;swap;fee;net_profit;entry_time;exit_time;time_in_trade;exit_reason;setup_type;trigger_type;trend_state;context_class;defense_state";
   EnsureHeader(TradesFileName(),tr);
   string da="date;symbol;timeframe;magic;starting_balance;ending_balance;gross_profit;gross_loss;net_profit;wins;losses;win_rate;average_win;average_loss;largest_win;largest_loss;profit_factor;consecutive_wins;consecutive_losses;daily_target;daily_target_hit;daily_loss_limit;daily_loss_limit_hit;trades;buy_trades;sell_trades;max_intraday_drawdown;max_intraday_loss;trail_activated;trail_closed_profit;tp_closed_profit;sl_closed_profit;emergency_closed_profit;defensive_events;cooldown_events";
   EnsureHeader(DailyFileName(),da);
   string er="timestamp;symbol;timeframe;magic;stage;operation;error_code;mql_error;trade_retcode;trade_comment;bid;ask;volume;price;sl;tp;order_ticket;deal_ticket;position_ticket;reason;details;recovery_action";
   EnsureHeader(ErrorsFileName(),er);
  }

string NowString()
  {
   return TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS);
  }

void AppendCsvLine(string fileName,string line)
  {
   if(!InpWriteCSV) return;
   int h=FileOpen(fileName,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE)
     {
      h=FileOpen(fileName,FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
      if(h==INVALID_HANDLE) return;
     }
   FileSeek(h,0,SEEK_END);
   FileWriteString(h,line+"\r\n");
   FileClose(h);
  }

//====================================================================
// EVENT IDS
//====================================================================
string NewEventId()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   g_eventSeq++;
   return StringFormat("PT-%04d%02d%02d-%02d%02d%02d-%I64u",dt.year,dt.mon,dt.day,dt.hour,dt.min,dt.sec,g_eventSeq);
  }

//====================================================================
// PRICE / MONEY UTILITIES
//====================================================================
double NormalizeVolume(double volume)
  {
   double minv=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxv=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step<=0.0) step=minv;
   volume=MathMin(volume,maxv);
   double v=MathFloor(volume/step+1e-10)*step;
   if(v<minv) return 0.0;
   int digits=0;
   double s=step;
   while(digits<8 && MathAbs(s-MathRound(s))>1e-8) { s*=10.0; digits++; }
   return NormalizeDouble(v,digits);
  }

bool CalcProfitForMove(int direction,double volume,double fromPrice,double toPrice,double &profit)
  {
   ENUM_ORDER_TYPE type=(direction==PT_DIR_BUY?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
   ResetLastError();
   if(!OrderCalcProfit(type,_Symbol,volume,fromPrice,toPrice,profit))
     return false;
   return true;
  }

double MoneyForPriceDistance(int direction,double volume,double fromPrice,double distance)
  {
   if(distance<=0.0 || volume<=0.0) return 0.0;
   double to=(direction==PT_DIR_BUY?fromPrice+distance:fromPrice-distance);
   double p=0.0;
   if(!CalcProfitForMove(direction,volume,fromPrice,to,p)) return 0.0;
   return MathAbs(p);
  }

bool PriceDistanceForMoney(int direction,double volume,double fromPrice,double money,double &distance)
  {
   distance=0.0;
   if(money<=0.0 || volume<=0.0 || fromPrice<=0.0) return false;
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick<=0.0) tick=_Point;
   double lo=0.0;
   double hi=tick*10.0;
   double p=0.0;
   for(int i=0;i<60;i++)
     {
      if(MoneyForPriceDistance(direction,volume,fromPrice,hi)>=money) break;
      hi*=2.0;
      if(hi>fromPrice*0.5) break;
     }
   if(MoneyForPriceDistance(direction,volume,fromPrice,hi)<money) return false;
   for(int i=0;i<60;i++)
     {
      double mid=0.5*(lo+hi);
      double mp=MoneyForPriceDistance(direction,volume,fromPrice,mid);
      if(mp>=money) hi=mid; else lo=mid;
     }
   distance=hi;
   return true;
  }

double StopBufferPrice()
  {
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick<=0.0) tick=_Point;
   double spread=SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SymbolInfoDouble(_Symbol,SYMBOL_BID);
   return MathMax(MathMax(PT_MIN_STOP_FACTOR*tick,PT_STOP_BUFFER_FACTOR*g_paScale),1.20*spread);
  }

double EntryBufferPrice()
  {
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick<=0.0) tick=_Point;
   return MathMax(2.0*tick,PT_TRIGGER_BUFFER*g_microScale);
  }

//====================================================================
// DAILY CONTROL
//====================================================================
double CalculateDailyNet()
  {
   datetime from=StartOfServerDay(TimeCurrent());
   datetime to=TimeCurrent();
   if(!HistorySelect(from,to)) return 0.0;
   double net=0.0;
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong deal=HistoryDealGetTicket(i);
      if(deal==0) continue;
      if((long)HistoryDealGetInteger(deal,DEAL_MAGIC)!=g_magic) continue;
      if(HistoryDealGetString(deal,DEAL_SYMBOL)!=_Symbol) continue;
      net += HistoryDealGetDouble(deal,DEAL_PROFIT);
      net += HistoryDealGetDouble(deal,DEAL_COMMISSION);
      net += HistoryDealGetDouble(deal,DEAL_SWAP);
      net += HistoryDealGetDouble(deal,DEAL_FEE);
     }
   return net;
  }

void RefreshDailyNet(const bool force=false)
  {
   datetime now=TimeCurrent();
   if(now<=0) now=TimeTradeServer();
   if(!force && g_lastDailyNetCalc>0 && (now-g_lastDailyNetCalc)<1) return;
   g_cachedDailyNet=CalculateDailyNet();
   g_lastDailyNetCalc=now;
  }

double DailyNet()
  {
   RefreshDailyNet(false);
   return g_cachedDailyNet;
  }

bool DailyEntryBlocked(string &reason,string &detail)
  {
   double net=DailyNet();
   if(InpDailyTargetEnable && net>=InpDailyTargetMoney && InpDailyTargetMoney>0.0)
     {
      reason="DAILY_TARGET_REACHED";
      detail=StringFormat("DailyNet=%.2f >= Target=%.2f",net,InpDailyTargetMoney);
      return true;
     }
   if(InpDailyLossLimitEnable && net<=-MathAbs(InpDailyLossLimitMoney) && InpDailyLossLimitMoney>0.0)
     {
      reason="DAILY_LOSS_LIMIT";
      detail=StringFormat("DailyNet=%.2f <= -Limit=%.2f",net,MathAbs(InpDailyLossLimitMoney));
      return true;
     }
   return false;
  }

//====================================================================
// SCALE ENGINE
//====================================================================
bool ComputeScales(MqlRates &rates[])
  {
   int n=ArraySize(rates);
   if(n<PT_PA_SCALE_BARS+5) return false;
   double a[];
   ArrayResize(a,PT_PA_SCALE_BARS);
   for(int k=0;k<PT_PA_SCALE_BARS;k++) a[k]=BarRange(rates[1+k]);
   g_paScale=MedianFromArray(a);
   double b[];
   ArrayResize(b,PT_MICRO_SCALE_BARS);
   for(int k=0;k<PT_MICRO_SCALE_BARS;k++) b[k]=BarRange(rates[1+k]);
   g_microScale=MedianFromArray(b);
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick<=0.0) tick=_Point;
   g_paScale=MathMax(g_paScale,4.0*tick);
   g_microScale=MathMax(g_microScale,2.0*tick);
   return (g_paScale>0.0 && g_microScale>0.0);
  }

//====================================================================
// SWING ENGINE
//====================================================================
double SwingProminenceWindow(MqlRates &rates[],int idx,bool isHigh,int window)
  {
   int n=ArraySize(rates);
   double leftExtreme=isHigh?DBL_MAX:-DBL_MAX;
   double rightExtreme=isHigh?DBL_MAX:-DBL_MAX;
   for(int k=1;k<=MathMax(1,window);k++)
     {
      int l=idx+k;
      int r=idx-k;
      if(l<n)
        {
         if(isHigh) leftExtreme=MathMin(leftExtreme,rates[l].low);
         else       leftExtreme=MathMax(leftExtreme,rates[l].high);
        }
      if(r>=1 && r<n)
        {
         if(isHigh) rightExtreme=MathMin(rightExtreme,rates[r].low);
         else       rightExtreme=MathMax(rightExtreme,rates[r].high);
        }
     }
   if(isHigh)
     {
      double base=MathMax(leftExtreme,rightExtreme);
      return rates[idx].high-base;
     }
   double base=MathMin(leftExtreme,rightExtreme);
   return base-rates[idx].low;
  }

double SwingProminence(MqlRates &rates[],int idx,bool isHigh)
  {
   return SwingProminenceWindow(rates,idx,isHigh,PT_PROM_WINDOW);
  }

bool IsMicroSwingHigh(MqlRates &rates[],int i)
  {
   int n=ArraySize(rates);
   if(i-PT_MICRO_SWING_RADIUS<1 || i+PT_MICRO_SWING_RADIUS>=n) return false;
   return rates[i].high>rates[i-1].high && rates[i].high>rates[i+1].high;
  }

bool IsMicroSwingLow(MqlRates &rates[],int i)
  {
   int n=ArraySize(rates);
   if(i-PT_MICRO_SWING_RADIUS<1 || i+PT_MICRO_SWING_RADIUS>=n) return false;
   return rates[i].low<rates[i-1].low && rates[i].low<rates[i+1].low;
  }

bool IsSwingHigh(MqlRates &rates[],int i)
  {
   int n=ArraySize(rates);
   if(i-PT_SWING_RADIUS<1 || i+PT_SWING_RADIUS>=n) return false;
   return rates[i].high>rates[i-1].high && rates[i].high>rates[i-2].high &&
          rates[i].high>rates[i+1].high && rates[i].high>rates[i+2].high;
  }

bool IsSwingLow(MqlRates &rates[],int i)
  {
   int n=ArraySize(rates);
   if(i-PT_SWING_RADIUS<1 || i+PT_SWING_RADIUS>=n) return false;
   return rates[i].low<rates[i-1].low && rates[i].low<rates[i-2].low &&
          rates[i].low<rates[i+1].low && rates[i].low<rates[i+2].low;
  }

// FIX v1.01: o pivo mais recente fica SEMPRE em [0].
// Antes, enquanto o array nao estava cheio, o novo pivo era anexado em [count],
// deixando o mais ANTIGO em [0] e quebrando toda a leitura de estrutura/tendencia.
void PushSwing(PTSwing &arr[],int &count,PTSwing &s)
  {
   int max=ArraySize(arr);
   int newCount=MathMin(count+1,max);
   for(int i=newCount-1;i>0;i--) arr[i]=arr[i-1];
   arr[0]=s;
   count=newCount;
  }

void DetectSwings(MqlRates &rates[])
  {
   g_majorHighCount=0; g_majorLowCount=0; g_microHighCount=0; g_microLowCount=0;
   int n=ArraySize(rates);

   // MAJOR: janela estrutural (~12h), raio 2, prominence baseada no PA_SCALE.
   int majorScan=MathMin(RequiredStructuralBars(),n-PT_SWING_RADIUS-1);
   for(int i=majorScan;i>=PT_SWING_RADIUS+1;i--)
     {
      if(IsSwingHigh(rates,i))
        {
         PTSwing s;
         s.index=i; s.time=rates[i].time; s.price=rates[i].high; s.isHigh=true;
         s.prominence=SwingProminence(rates,i,true);
         s.major=(s.prominence>=PT_MAJOR_PROM_FACTOR*g_paScale);
         if(s.major) PushSwing(g_majorHighs,g_majorHighCount,s);
        }
      if(IsSwingLow(rates,i))
        {
         PTSwing s;
         s.index=i; s.time=rates[i].time; s.price=rates[i].low; s.isHigh=false;
         s.prominence=SwingProminence(rates,i,false);
         s.major=(s.prominence>=PT_MAJOR_PROM_FACTOR*g_paScale);
         if(s.major) PushSwing(g_majorLows,g_majorLowCount,s);
        }
     }

   // MICRO: janela independente (~30min), sem usar a janela de 12h.
   // Usa raio 1 e prominence contra MICRO_SCALE; isso evita que a microestrutura
   // seja filtrada pelo tamanho da estrutura major.
   int microScan=MathMin(MathMax(RequiredMicroBars(),PT_MICRO_SWING_RADIUS+2),n-PT_MICRO_SWING_RADIUS-1);
   for(int i=microScan;i>=PT_MICRO_SWING_RADIUS+1;i--)
     {
      if(IsMicroSwingHigh(rates,i))
        {
         PTSwing s;
         s.index=i; s.time=rates[i].time; s.price=rates[i].high; s.isHigh=true;
         s.prominence=SwingProminenceWindow(rates,i,true,PT_MICRO_PROM_WINDOW);
         s.major=false;
         if(s.prominence>=PT_MICRO_PROM_FACTOR*g_microScale)
            PushSwing(g_microHighs,g_microHighCount,s);
        }
      if(IsMicroSwingLow(rates,i))
        {
         PTSwing s;
         s.index=i; s.time=rates[i].time; s.price=rates[i].low; s.isHigh=false;
         s.prominence=SwingProminenceWindow(rates,i,false,PT_MICRO_PROM_WINDOW);
         s.major=false;
         if(s.prominence>=PT_MICRO_PROM_FACTOR*g_microScale)
            PushSwing(g_microLows,g_microLowCount,s);
        }
     }
  }

//====================================================================
// STRUCTURE / TREND ENGINE
//====================================================================
// Helpers use chronological semantics: [0] is the most recently stored pivot.
// For highs/lows separately, the newest two values are compared directly.
bool BuildTrendScores()
  {
   g_structureScore=0.0;
   g_continuationScore=0.0;
   g_pullbackQuality=0.0;
   g_recencyScore=0.0;
   g_trendScore=0.0;

   bool buy=false,sell=false;
   if(g_majorHighCount>=2 && g_majorLowCount>=2)
     {
      double hh0=g_majorHighs[0].price, hh1=g_majorHighs[1].price;
      double hl0=g_majorLows[0].price,  hl1=g_majorLows[1].price;
      buy=(hh0>hh1+PT_HH_BUFFER_FACTOR*g_paScale && hl0>hl1+PT_HL_BUFFER_FACTOR*g_paScale);
      sell=(g_majorLows[0].price<g_majorLows[1].price-PT_HH_BUFFER_FACTOR*g_paScale &&
            g_majorHighs[0].price<g_majorHighs[1].price-PT_HL_BUFFER_FACTOR*g_paScale);
     }

   if(buy)
     {
      bool hhCur=(g_majorHighCount>=2 && g_majorHighs[0].price>g_majorHighs[1].price+PT_HH_BUFFER_FACTOR*g_paScale);
      bool hlCur=(g_majorLowCount>=2 && g_majorLows[0].price>g_majorLows[1].price+PT_HL_BUFFER_FACTOR*g_paScale);
      bool hhPrev=(g_majorHighCount>=3 && g_majorHighs[1].price>g_majorHighs[2].price+PT_HH_BUFFER_FACTOR*g_paScale);
      bool hlPrev=(g_majorLowCount>=3 && g_majorLows[1].price>g_majorLows[2].price+PT_HL_BUFFER_FACTOR*g_paScale);
      g_structureScore=((hhCur?1.0:0.0)+(hlCur?1.0:0.0)+(hhPrev?1.0:0.0)+(hlPrev?1.0:0.0))/4.0;
      double impCur=g_majorHighs[0].price-g_majorLows[0].price;
      double impPrev=g_majorHighs[1].price-g_majorLows[1].price;
      g_continuationScore=(impPrev>_Point?Clamp(impCur/impPrev,0.0,1.0):0.0);
      double pb=(g_majorHighs[1].price-g_majorLows[0].price);
      double pbRatio=(impPrev>_Point?Clamp(pb/impPrev,0.0,2.0):1.0);
      g_pullbackQuality=1.0-Clamp((pbRatio-0.20)/(0.75-0.20),0.0,1.0);
      int barsSince=(int)iBarShift(_Symbol,g_workTF,g_majorHighs[0].time,false);
      g_recencyScore=MathExp(-MathMax(0,barsSince)/12.0);
      g_trendState=PT_TREND_BUY;
      g_direction=PT_DIR_BUY;
     }
   else if(sell)
     {
      bool llCur=(g_majorLowCount>=2 && g_majorLows[0].price<g_majorLows[1].price-PT_HH_BUFFER_FACTOR*g_paScale);
      bool lhCur=(g_majorHighCount>=2 && g_majorHighs[0].price<g_majorHighs[1].price-PT_HL_BUFFER_FACTOR*g_paScale);
      bool llPrev=(g_majorLowCount>=3 && g_majorLows[1].price<g_majorLows[2].price-PT_HH_BUFFER_FACTOR*g_paScale);
      bool lhPrev=(g_majorHighCount>=3 && g_majorHighs[1].price<g_majorHighs[2].price-PT_HL_BUFFER_FACTOR*g_paScale);
      g_structureScore=((llCur?1.0:0.0)+(lhCur?1.0:0.0)+(llPrev?1.0:0.0)+(lhPrev?1.0:0.0))/4.0;
      double impCur=g_majorHighs[0].price-g_majorLows[0].price;
      double impPrev=g_majorHighs[1].price-g_majorLows[1].price;
      g_continuationScore=(impPrev>_Point?Clamp(impCur/impPrev,0.0,1.0):0.0);
      double pb=(g_majorHighs[0].price-g_majorLows[1].price);
      double pbRatio=(impPrev>_Point?Clamp(pb/impPrev,0.0,2.0):1.0);
      g_pullbackQuality=1.0-Clamp((pbRatio-0.20)/(0.75-0.20),0.0,1.0);
      int barsSince=(int)iBarShift(_Symbol,g_workTF,g_majorLows[0].time,false);
      g_recencyScore=MathExp(-MathMax(0,barsSince)/12.0);
      g_trendState=PT_TREND_SELL;
      g_direction=PT_DIR_SELL;
     }
   else
     {
      g_trendState=PT_TREND_NONE;
      g_direction=PT_DIR_NONE;
      g_structureScore=(g_majorHighCount>=2 && g_majorLowCount>=2?0.25:0.0);
     }

   g_trendScore=100.0*(0.40*g_structureScore+0.30*g_continuationScore+0.20*g_pullbackQuality+0.10*g_recencyScore);
   if(g_trendState==PT_TREND_NONE && g_majorHighCount>=2 && g_majorLowCount>=2)
      g_context=PT_CTX_TRANSITION;
   return true;
  }

bool CheckTransition(MqlRates &rates[])
  {
   if(g_majorHighCount<1 || g_majorLowCount<1) return false;
   double close=rates[1].close;
   if(g_trendState==PT_TREND_BUY)
     {
      double lastHL=g_majorLows[0].price;
      if(close<lastHL-PT_HH_BUFFER_FACTOR*g_paScale) return true;
     }
   if(g_trendState==PT_TREND_SELL)
     {
      double lastLH=g_majorHighs[0].price;
      if(close>lastLH+PT_HH_BUFFER_FACTOR*g_paScale) return true;
     }
   return false;
  }

bool TrendValid()
  {
   return (g_trendState==PT_TREND_BUY || g_trendState==PT_TREND_SELL) && g_structureScore>=0.50 && g_trendScore>=55.0;
  }

//====================================================================
// DEFENSE ENGINE
//====================================================================
double ComputePathEfficiency(MqlRates &rates[],int n)
  {
   int available=ArraySize(rates);
   int N=MathMin(n,available-1);
   if(N<2) return 1.0;
   double directional=MathAbs(rates[1].close-rates[N].close);
   double path=0.0;
   for(int i=1;i<N;i++) path += MathAbs(rates[i].close-rates[i+1].close);
   if(path<=_Point) return 1.0;
   return Clamp(directional/path,0.0,1.0);
  }

double ComputeWhipsaw(MqlRates &rates[],int n)
  {
   int available=ArraySize(rates);
   int N=MathMin(n,available-3);
   if(N<6) return 0.0;
   int flips=0, obs=0;
   int prev=0;
   for(int i=1;i<N;i++)
     {
      int dir=0;
      if(rates[i].close>rates[i+1].close) dir=1;
      else if(rates[i].close<rates[i+1].close) dir=-1;
      if(dir!=0)
        {
         if(prev!=0 && dir!=prev) flips++;
         prev=dir; obs++;
        }
     }
   if(obs<=1) return 0.0;
   return (double)flips/(double)(obs-1);
  }

double ComputeDefenseScore(MqlRates &rates[])
  {
   int n=MathMin(RequiredContextBars(),ArraySize(rates)-3);
   g_pathEfficiency=ComputePathEfficiency(rates,n);
   g_whipsawIndex=ComputeWhipsaw(rates,n);
   g_rangeRatio=BarRange(rates[1])/MathMax(g_paScale,_Point);

   double lowEfficiencyScore=0.0;
   if(g_pathEfficiency<PT_PE_MIXED) lowEfficiencyScore=100.0;
   else if(g_pathEfficiency<PT_PE_DIRECTIONAL)
      lowEfficiencyScore=100.0*SafeDiv(PT_PE_DIRECTIONAL-g_pathEfficiency,PT_PE_DIRECTIONAL-PT_PE_MIXED);

   double whipScore=0.0;
   if(g_whipsawIndex>=PT_WHIP_DEFENSIVE) whipScore=100.0;
   else if(g_whipsawIndex>PT_WHIP_CAUTION)
      whipScore=100.0*SafeDiv(g_whipsawIndex-PT_WHIP_CAUTION,PT_WHIP_DEFENSIVE-PT_WHIP_CAUTION);

   double expansionScore=0.0;
   if(g_rangeRatio>=PT_EXPANSION_EXTREME) expansionScore=100.0;
   else if(g_rangeRatio>PT_EXPANSION)
      expansionScore=100.0*SafeDiv(g_rangeRatio-PT_EXPANSION,PT_EXPANSION_EXTREME-PT_EXPANSION);
   g_defenseScore=Clamp(0.35*lowEfficiencyScore+0.35*whipScore+0.30*expansionScore,0.0,100.0);

   if(g_defenseScore>=PT_DEF_HARD_SCORE) g_defense=PT_DEF_HARD;
   else if(g_defenseScore>=PT_DEF_DEFENSIVE_SCORE) g_defense=PT_DEF_DEFENSIVE;
   else if(g_defenseScore>=PT_DEF_CAUTION_SCORE) g_defense=PT_DEF_CAUTION;
   else g_defense=PT_DEF_NORMAL;
   return g_defenseScore;
  }

//====================================================================
// CONTEXT / ZONE / SETUP
//====================================================================
void BuildZone()
  {
   ResetZone();
   if(!TrendValid() || g_majorHighCount<1 || g_majorLowCount<1) return;
   double anchor=0.0;
   if(g_direction==PT_DIR_BUY) anchor=g_majorLows[0].price; else anchor=g_majorHighs[0].price;
   g_zone.active=true;
   g_zone.id=(int)(g_eventSeq+1);
   g_zone.direction=g_direction;
   g_zone.type=(g_direction==PT_DIR_BUY?"BUY_ANCHOR":"SELL_ANCHOR");
   g_zone.low=anchor-PT_ZONE_FACTOR*g_paScale;
   g_zone.high=anchor+PT_ZONE_FACTOR*g_paScale;
   g_zone.score=Clamp(100.0*(1.0-MathAbs(SymbolInfoDouble(_Symbol,SYMBOL_BID)-anchor)/(2.0*g_paScale)),0.0,100.0);
   g_zone.time=TimeCurrent();
  }

bool IsNearZone(double price)
  {
   return g_zone.active && price>=g_zone.low && price<=g_zone.high;
  }

bool FindNearestObstacle(int direction,double entry,double &obstacle)
  {
   obstacle=0.0;
   double best=(direction==PT_DIR_BUY?DBL_MAX:-DBL_MAX);
   bool found=false;

   // Obstáculo é a estrutura CONTRÁRIA ao sentido da operação:
   // BUY -> próxima resistência/major high acima da entrada.
   // SELL -> próximo suporte/major low abaixo da entrada.
   if(direction==PT_DIR_BUY)
     {
      for(int i=0;i<g_majorHighCount;i++)
        {
         double p=g_majorHighs[i].price;
         if(p>entry && p<best) { best=p; found=true; }
        }
     }
   else if(direction==PT_DIR_SELL)
     {
      for(int i=0;i<g_majorLowCount;i++)
        {
         double p=g_majorLows[i].price;
         if(p<entry && p>best) { best=p; found=true; }
        }
     }
   if(found) obstacle=best;
   return found;
  }

bool BuildCandidate(MqlRates &rates[])
  {
   ResetCandidate();
   if(!TrendValid()) return false;
   BuildZone();
   if(!g_zone.active) return false;
   if(ArraySize(rates)<6) return false;

   int idx=1;
   MqlRates r=rates[idx];
   double range=BarRange(r);
   double body=MathAbs(r.close-r.open);
   double upperWick=r.high-MathMax(r.open,r.close);
   double lowerWick=MathMin(r.open,r.close)-r.low;
   double closeLoc=(r.close-r.low)/range;
   double upperLoc=(r.high-r.close)/range;
   bool rejectionBuy=(lowerWick/range>=0.35 && closeLoc>=0.55 && body/range>=0.20);
   bool rejectionSell=(upperWick/range>=0.35 && upperLoc>=0.55 && body/range>=0.20);

   double entry=0.0, inv=0.0, triggerHigh=r.high, triggerLow=r.low;
   ENUM_PT_SETUP setup=PT_SETUP_NONE;
   double setupLevel=0.0;
   double sweepLevel=0.0;

   if(g_direction==PT_DIR_BUY)
     {
      // 1) Pullback + rejection: a rejeição já é o SETUP; o rompimento da máxima
      // da barra é o TRIGGER. Não exigir que a mesma barra já rompa a microestrutura.
      bool zoneTouch=(r.low<=g_zone.high && r.high>=g_zone.low);
      if(zoneTouch && rejectionBuy)
        {
         setup=PT_SETUP_PULLBACK_REJECTION;
         triggerHigh=r.high;
        }

      // 2) Break + retest: usa o ÚLTIMO major high confirmado [0], não [1].
      // A barra [2] precisa ter rompido antes da barra de reteste [1].
      if(setup==PT_SETUP_NONE && g_majorHighCount>=1 && ArraySize(rates)>3)
        {
         double level=g_majorHighs[0].price;
         bool priorBreak=rates[2].close>level+PT_BREAK_FACTOR*g_paScale;
         bool ret=(r.low<=level+PT_RETEST_HIGH_FACTOR*g_paScale && r.low>=level-PT_RETEST_LOW_FACTOR*g_paScale);
         bool reclaim=(r.close>level);
         if(priorBreak && ret && reclaim)
           {
            setup=PT_SETUP_BREAK_RETEST;
            setupLevel=level;
            triggerHigh=MathMax(r.high,level);
           }
        }

      // 3) Sweep + reclaim: usa somente micro swing recente (~30min).
      // A continuação acima da máxima é o TRIGGER, portanto não é exigida aqui.
      if(setup==PT_SETUP_NONE && g_microLowCount>=1)
        {
         double prevLow=g_microLows[0].price;
         bool sweep=(r.low<prevLow-0.05*g_microScale && r.close>prevLow);
         if(sweep)
           {
            setup=PT_SETUP_SWEEP_RECLAIM;
            sweepLevel=prevLow;
            triggerHigh=r.high;
           }
        }

      if(setup==PT_SETUP_NONE) return false;
      entry=triggerHigh+EntryBufferPrice();

      // Invalidação específica do setup, sempre atrás da estrutura que invalidaria
      // a premissa, em vez de usar a zona inteira para todos os casos.
      if(setup==PT_SETUP_PULLBACK_REJECTION)
         inv=MathMin(g_zone.low,r.low)-StopBufferPrice();
      else if(setup==PT_SETUP_BREAK_RETEST)
         inv=MathMin(setupLevel,r.low)-StopBufferPrice();
      else
         inv=MathMin(sweepLevel,r.low)-StopBufferPrice();
     }
   else if(g_direction==PT_DIR_SELL)
     {
      bool zoneTouch=(r.high>=g_zone.low && r.low<=g_zone.high);
      if(zoneTouch && rejectionSell)
        {
         setup=PT_SETUP_PULLBACK_REJECTION;
         triggerLow=r.low;
        }

      if(setup==PT_SETUP_NONE && g_majorLowCount>=1 && ArraySize(rates)>3)
        {
         double level=g_majorLows[0].price;
         bool priorBreak=rates[2].close<level-PT_BREAK_FACTOR*g_paScale;
         bool ret=(r.high>=level-PT_RETEST_HIGH_FACTOR*g_paScale && r.high<=level+PT_RETEST_LOW_FACTOR*g_paScale);
         bool reclaim=(r.close<level);
         if(priorBreak && ret && reclaim)
           {
            setup=PT_SETUP_BREAK_RETEST;
            setupLevel=level;
            triggerLow=MathMin(r.low,level);
           }
        }

      if(setup==PT_SETUP_NONE && g_microHighCount>=1)
        {
         double prevHigh=g_microHighs[0].price;
         bool sweep=(r.high>prevHigh+0.05*g_microScale && r.close<prevHigh);
         if(sweep)
           {
            setup=PT_SETUP_SWEEP_RECLAIM;
            sweepLevel=prevHigh;
            triggerLow=r.low;
           }
        }

      if(setup==PT_SETUP_NONE) return false;
      entry=triggerLow-EntryBufferPrice();

      if(setup==PT_SETUP_PULLBACK_REJECTION)
         inv=MathMax(g_zone.high,r.high)+StopBufferPrice();
      else if(setup==PT_SETUP_BREAK_RETEST)
         inv=MathMax(setupLevel,r.high)+StopBufferPrice();
      else
         inv=MathMax(sweepLevel,r.high)+StopBufferPrice();
     }

   if(entry<=0.0 || inv<=0.0) return false;
   double riskDist=(g_direction==PT_DIR_BUY?entry-inv:inv-entry);
   if(riskDist<=_Point) return false;
   double riskNorm=riskDist/MathMax(g_paScale,_Point);

   double obstacle=0.0;
   double space=0.0,spaceRatio=DBL_MAX;
   if(FindNearestObstacle(g_direction,entry,obstacle))
     {
      space=(g_direction==PT_DIR_BUY?obstacle-entry:entry-obstacle);
      spaceRatio=space/riskDist;
      if(space<=0.0) return false;
     }
   else
     {
      space=999999.0*g_paScale;
      spaceRatio=999999.0;
     }

   // Score calibrado por tipo de setup. Proximity é relevante para pullback,
   // mas não deve punir um breakout/retest que necessariamente se afasta da zona.
   double proximity=100.0*(1.0-Clamp(MathAbs((entry-(g_zone.low+g_zone.high)*0.5))/(MathMax(g_paScale,_Point)),0.0,1.0));
   double reaction=100.0*Clamp(MathMax(lowerWick,upperWick)/range,0.0,1.0);
   double spaceScore=100.0*Clamp(spaceRatio/1.50,0.0,1.0);
   double setupQuality=0.0;

   if(setup==PT_SETUP_PULLBACK_REJECTION)
     {
      double bodyScore=100.0*Clamp(body/range,0.0,1.0);
      setupQuality=0.30*proximity+0.35*reaction+0.20*bodyScore+0.15*spaceScore;
     }
   else if(setup==PT_SETUP_BREAK_RETEST)
     {
      double breakStrength=100.0*Clamp(MathAbs(rates[2].close-setupLevel)/MathMax(g_paScale,_Point),0.0,1.0);
      double reclaimStrength=100.0*Clamp(MathAbs(r.close-setupLevel)/MathMax(g_paScale,_Point),0.0,1.0);
      setupQuality=0.40*breakStrength+0.25*reclaimStrength+0.15*reaction+0.20*spaceScore;
     }
   else
     {
      double sweepDepth=100.0*Clamp(MathAbs(r.high-r.low)/MathMax(g_microScale,_Point),0.0,1.0);
      double reclaimStrength=100.0*Clamp(MathAbs(r.close-sweepLevel)/MathMax(g_microScale,_Point),0.0,1.0);
      setupQuality=0.30*sweepDepth+0.30*reclaimStrength+0.20*reaction+0.20*spaceScore;
     }

   g_candidate.active=true;
   g_candidate.direction=g_direction;
   g_candidate.setup=setup;
   g_candidate.score=Clamp(setupQuality,0.0,100.0);
   g_candidate.zoneLow=g_zone.low;
   g_candidate.zoneHigh=g_zone.high;
   g_candidate.triggerHigh=triggerHigh;
   g_candidate.triggerLow=triggerLow;
   g_candidate.plannedEntry=NormalizeDouble(entry,_Digits);
   g_candidate.invalidation=NormalizeDouble(inv,_Digits);
   g_candidate.riskDistance=riskDist;
   g_candidate.riskNorm=riskNorm;
   g_candidate.nearestObstacle=obstacle;
   g_candidate.spaceDistance=space;
   g_candidate.spaceRatio=spaceRatio;
   g_candidate.triggerBar=1;
   g_candidate.eventTime=TimeCurrent();
   g_candidate.eventId=NewEventId();
   g_candidate.reasonCode="SETUP_VALID";
   g_candidate.reasonDetail=StringFormat("setup=%s score=%.1f riskNorm=%.2f spaceRatio=%.2f",SetupToString(setup),g_candidate.score,riskNorm,spaceRatio);
   return true;
  }

//====================================================================
// ENTRY VALIDATION / SIZING
//====================================================================
bool CalculatePlannedVolume(double entry,double invalidation,double &volume,double &riskMoney)
  {
   volume=0.0; riskMoney=0.0;
   double risk=MathAbs(entry-invalidation);
   if(risk<=_Point) return false;

   if(InpUseFixedLot)
     {
      if(InpFixedLot<=0.0) return false;
      volume=NormalizeVolume(InpFixedLot);
      if(volume<=0.0) return false;
      riskMoney=MoneyForPriceDistance(g_direction,volume,entry,risk);
      return (riskMoney>0.0);
     }

   if(!InpRiskEnable || InpRiskMoneyPerTrade<=0.0) return false;
   double loss1=MoneyForPriceDistance(g_direction,1.0,entry,risk);
   if(loss1<=0.0) return false;
   double raw=InpRiskMoneyPerTrade/loss1;
   volume=NormalizeVolume(raw);
   if(volume<=0.0) return false;
   riskMoney=MoneyForPriceDistance(g_direction,volume,entry,risk);
   return (riskMoney>0.0);
  }

bool ValidateCandidate(double &volume,double &riskMoney,string &reason,string &detail)
  {
   reason=""; detail="";
   if(!g_candidate.active) { reason="NO_SETUP"; detail="candidate inactive"; return false; }
   if(g_candidate.riskNorm>PT_MAX_RISK_NORM)
     {
      reason="INVALIDATION_TOO_FAR";
      detail=StringFormat("RiskDistanceNorm=%.2f > 2.50",g_candidate.riskNorm);
      return false;
     }
   if(InpMaxStopPointsEnable && InpMaxStopPoints>0.0)
     {
      double points=g_candidate.riskDistance/_Point;
      if(points>InpMaxStopPoints)
        {
         reason="INVALIDATION_TOO_FAR";
         detail=StringFormat("RiskDistancePoints=%.1f > MaxStopPoints=%.1f",points,InpMaxStopPoints);
         return false;
        }
     }
   if(g_candidate.spaceRatio<PT_MIN_SPACE_RATIO)
     {
      reason="SPACE_INSUFFICIENT";
      detail=StringFormat("SpaceRatio=%.2f < %.2f",g_candidate.spaceRatio,PT_MIN_SPACE_RATIO);
      return false;
     }

   if(!CalculatePlannedVolume(g_candidate.plannedEntry,g_candidate.invalidation,volume,riskMoney))
     {
      reason="VOLUME_BELOW_MIN";
      detail="Risk sizing produced no valid broker volume";
      return false;
     }
   if(InpMaxLossMoneyEnable && InpMaxLossMoney>0.0 && riskMoney>InpMaxLossMoney)
     {
      reason="RISK_TOO_HIGH";
      detail=StringFormat("RiskMoney=%.2f > MaxLossMoney=%.2f",riskMoney,InpMaxLossMoney);
      return false;
     }

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
     {
      reason="NO_DATA"; detail="SymbolInfoTick failed"; return false;
     }
   double spread=tick.ask-tick.bid;
   double spreadPoints=spread/_Point;
   if(InpSpreadFilterEnable && InpMaxSpreadPoints>0.0 && spreadPoints>InpMaxSpreadPoints)
     {
      reason="SPREAD_TOO_HIGH";
      detail=StringFormat("SpreadPoints=%.1f > MaxSpreadPoints=%.1f",spreadPoints,InpMaxSpreadPoints);
      return false;
     }
   return true;
  }

bool CanEnter(string &reason,string &detail,double &volume,double &riskMoney)
  {
   reason=""; detail=""; volume=0; riskMoney=0;
   RefreshDailyNet(true);
   if(!InpEnableTrading) { reason="RISK_DISABLED"; detail="EnableTrading=false"; return false; }
   if(g_paused) { reason="MANUAL_PAUSE"; detail="EA paused"; return false; }
   if(OurPositionCount()>0) { reason="POSITION_EXISTS"; detail="Maximum 1 position per instance"; return false; }
   long marginMode=AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if((marginMode==ACCOUNT_MARGIN_MODE_RETAIL_NETTING || marginMode==ACCOUNT_MARGIN_MODE_EXCHANGE) && HasAnySymbolPosition())
     { reason="POSITION_EXISTS"; detail="Netting account: a symbol can only have one merged position"; return false; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     { reason="EXECUTION_ERROR"; detail="Trading not allowed by terminal/program"; return false; }
   if(g_defense==PT_DEF_HARD) { reason="DEFENSIVE_LOCK"; detail=StringFormat("DefenseScore=%.1f",g_defenseScore); return false; }
   if(g_defense==PT_DEF_DEFENSIVE && g_candidate.score<65.0)
     { reason="DEFENSIVE_LOCK"; detail=StringFormat("DefenseScore=%.1f and SetupScore=%.1f",g_defenseScore,g_candidate.score); return false; }
   if(g_cooldownUntilBar>0 && TimeCurrent()<g_cooldownUntilBar)
     { reason="COOLDOWN"; detail="Loss cluster cooldown"; return false; }
   if(g_consecutiveLosses>=PT_LOSS_CAUTION && g_candidate.score<65.0)
     { reason="DEFENSIVE_LOCK"; detail=StringFormat("LossClusterCaution=%d and SetupScore=%.1f",g_consecutiveLosses,g_candidate.score); return false; }
   if(DailyEntryBlocked(reason,detail)) return false;
   if(!TrendValid()) { reason="NO_TREND"; detail=StringFormat("TrendScore=%.1f",g_trendScore); return false; }
   return ValidateCandidate(volume,riskMoney,reason,detail);
  }

//====================================================================
// TRADE EXECUTION
//====================================================================
void StorePositionContext()
  {
   if(!SelectOurPosition()) return;
   g_positionId=(long)PositionGetInteger(POSITION_IDENTIFIER);
   g_positionTicket=(ulong)PositionGetInteger(POSITION_TICKET);
   g_entryPrice=PositionGetDouble(POSITION_PRICE_OPEN);
   g_positionVolume=PositionGetDouble(POSITION_VOLUME);
   g_currentProfit=PositionGetDouble(POSITION_PROFIT);
   g_positionMaxProfit=MathMax(0.0,g_currentProfit);
   long ptype=PositionGetInteger(POSITION_TYPE);
   g_positionHighWaterPrice=PositionGetDouble(POSITION_PRICE_OPEN);
   if(ptype==POSITION_TYPE_BUY) g_positionHighWaterPrice=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   else if(ptype==POSITION_TYPE_SELL) g_positionHighWaterPrice=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   g_currentTrailDistanceMoney=0.0;
   g_currentTrailDistancePrice=0.0;
   g_currentTrailStop=PositionGetDouble(POSITION_SL);
   g_lockedProfit=0.0;
   g_trailActive=false;
   g_positionEntryTime=(datetime)PositionGetInteger(POSITION_TIME);
   g_virtualInvalidation=g_candidate.invalidation;
   g_positionTP=PositionGetDouble(POSITION_TP);
   g_positionSetup=SetupToString(g_candidate.setup);
   g_positionTrigger=(g_candidate.setup==PT_SETUP_SWEEP_RECLAIM?"SWEEP_RECLAIM":"MICRO_BREAK");
   g_positionEventId=g_candidate.eventId;
   // Re-anchor the money target to the actual fill, because slippage changes the exact price needed for TP=$X.
   if(InpTPEnable && InpTPMoney>0.0)
     {
      double d=0.0; int dir=(ptype==POSITION_TYPE_BUY?PT_DIR_BUY:PT_DIR_SELL);
      if(PriceDistanceForMoney(dir,g_positionVolume,g_entryPrice,InpTPMoney,d))
        {
         double target=NormalizeDouble(dir==PT_DIR_BUY?g_entryPrice+d:g_entryPrice-d,_Digits);
         double broker_tp=PositionGetDouble(POSITION_TP);
         double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
         if(tick<=0.0) tick=_Point;
         if(broker_tp<=0.0 || MathAbs(broker_tp-target)>tick)
           {
            if(ModifyPositionStops(PositionGetDouble(POSITION_SL),target))
               g_positionTP=target;
           }
         else
            g_positionTP=broker_tp;
        }
     }
  }

bool ModifyPositionStops(double sl,double tp)
  {
   if(!SelectOurPosition()) return false;
   ulong ticket=g_positionTicket;
   ResetLastError();
   bool ok=g_trade.PositionModify(ticket,sl,tp);
   if(!ok || !TradeResultSucceeded())
     {
      WriteError("POSITION_MANAGER","PositionModify",GetLastError(),g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription(),"preserve existing protection");
      return false;
     }
   return true;
  }

void ExecuteCandidate()
  {
   if(!g_candidate.active) return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   double triggerPrice=(g_direction==PT_DIR_BUY?tick.ask:tick.bid);
   bool crossed=(g_direction==PT_DIR_BUY?triggerPrice>=g_candidate.plannedEntry:triggerPrice<=g_candidate.plannedEntry);
   if(!crossed) return;
   if(MathAbs(triggerPrice-g_candidate.plannedEntry)>PT_CHASE_FACTOR*g_paScale)
     {
      g_candidate.active=false;
      WriteCoreEvent("SETUP_CANCELLED","CHASE_PRICE",StringFormat("Current=%.5f Planned=%.5f",triggerPrice,g_candidate.plannedEntry),"CANCEL");
      return;
     }
   string reason,detail; double volume,riskMoney;
   if(!CanEnter(reason,detail,volume,riskMoney))
     {
      WriteCoreEvent("ENTRY_BLOCKED",reason,detail,"NO_ORDER");
      if(reason=="DAILY_TARGET_REACHED" || reason=="DAILY_LOSS_LIMIT") g_state=PT_STATE_DAY_LOCK;
      else if(reason=="DEFENSIVE_LOCK") g_state=PT_STATE_DEFENSIVE_LOCK;
      else if(reason=="COOLDOWN") g_state=PT_STATE_COOLDOWN;
      return;
     }

   g_plannedRiskMoney=riskMoney;
   g_plannedVolume=volume;
   double sl=0.0,tp=0.0;
   if(InpStopLossEnable) sl=NormalizeDouble(g_candidate.invalidation,_Digits);
   if(InpTPEnable && InpTPMoney>0.0)
     {
      double d=0.0;
      if(PriceDistanceForMoney(g_direction,volume,triggerPrice,InpTPMoney,d))
         tp=NormalizeDouble(g_direction==PT_DIR_BUY?triggerPrice+d:triggerPrice-d,_Digits);
     }

   g_trade.SetExpertMagicNumber(g_magic);
   g_trade.SetDeviationInPoints((ulong)MathMax(1,(int)MathRound(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)+2)));
   g_state=PT_STATE_ORDER_SENT;
   bool ok=false;
   if(g_direction==PT_DIR_BUY)
      ok=g_trade.Buy(volume,_Symbol,0.0,sl,tp,"PieceTrend");
   else
      ok=g_trade.Sell(volume,_Symbol,0.0,sl,tp,"PieceTrend");

   if(!ok || !TradeResultSucceeded())
     {
      int err=GetLastError();
      WriteError("EXECUTION","MarketOrder",err,g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription(),"candidate preserved for reassessment; no recovery");
      WriteCoreEvent("ERROR","EXECUTION_ERROR",g_trade.ResultRetcodeDescription(),"NO_ORDER");
      g_state=PT_STATE_ENTRY_READY;
      return;
     }
   WriteCoreEvent("ORDER_SENT","SETUP_VALID",g_candidate.reasonDetail,"ORDER_SENT");
   g_candidate.active=false;
   StorePositionContext();
   if(OurPositionCount()>0)
     {
      g_state=PT_STATE_POSITION_OPEN;
      WriteCoreEvent("POSITION_OPEN","ORDER_FILLED",StringFormat("Fill=%.5f Volume=%.2f",g_entryPrice,g_positionVolume),"MANAGE");
     }
  }

//====================================================================
// POSITION MANAGER / TRAILING
//====================================================================
string PositionCloseReason()
  {
   double p=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
   if(InpEmergencyLossEnable && InpEmergencyLossMoney>0.0 && p<=-MathAbs(InpEmergencyLossMoney)) return "EMERGENCY_LOSS";
   return "";
  }

bool CloseOurPosition(string reason)
  {
   if(!SelectOurPosition()) return false;
   g_trade.SetExpertMagicNumber(g_magic);
   ResetLastError();
   g_pendingExitReason=reason;
   bool ok=g_trade.PositionClose(g_positionTicket);
   if(!ok || !TradeResultSucceeded())
     {
      WriteError("POSITION_MANAGER","PositionClose",GetLastError(),g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription(),"position remains open");
      g_pendingExitReason="";
      return false;
     }
   WriteCoreEvent("POSITION_CLOSE_REQUESTED",reason,"Position close accepted by trade server",reason);
   return true;
  }

void ApplyDynamicTrailing()
  {
   if(!InpTrailEnable || !SelectOurPosition()) return;
   long type=(long)PositionGetInteger(POSITION_TYPE);
   int dir=(type==POSITION_TYPE_BUY?PT_DIR_BUY:PT_DIR_SELL);
   double price=(type==POSITION_TYPE_BUY?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   double profit=PositionGetDouble(POSITION_PROFIT);
   g_currentProfit=profit;
   g_positionTP=PositionGetDouble(POSITION_TP);
   if(g_positionHighWaterPrice<=0.0) g_positionHighWaterPrice=price;
   if(dir==PT_DIR_BUY) g_positionHighWaterPrice=MathMax(g_positionHighWaterPrice,price);
   else g_positionHighWaterPrice=MathMin(g_positionHighWaterPrice,price);
   if(profit>g_positionMaxProfit) g_positionMaxProfit=profit;
   if(g_positionMaxProfit<InpTrailActivationMoney || InpTrailActivationMoney<=0.0) return;

   if(!g_trailActive)
     {
      g_trailActive=true;
      g_dailyTrailActivated++;
      if(InpTPEnable && PositionGetDouble(POSITION_TP)>0.0)
        {
         // Official PieceTrend rule: once trail activates, TP becomes a runner.
         if(ModifyPositionStops(PositionGetDouble(POSITION_SL),0.0))
           g_positionTP=0.0;
         WriteTradeEvent("TP_REMOVED","");
        }
      WriteCoreEvent("TRAIL_ACTIVATED","SETUP_VALID",StringFormat("MaxProfit=%.2f",g_positionMaxProfit),"TRAIL_ACTIVE");
     }

   double A=InpTrailActivationMoney;
   double D_A=PT_TRAIL_RATIO*A;
   double D=D_A*MathPow(MathMax(g_positionMaxProfit/A,1.0),PT_TRAIL_EXPONENT);
   g_currentTrailDistanceMoney=D;
   double distancePrice=0.0;
   double hwm=g_positionHighWaterPrice;
   if(hwm<=0.0) hwm=price;
   if(!PriceDistanceForMoney(dir,g_positionVolume,hwm,D,distancePrice)) return;
   g_currentTrailDistancePrice=distancePrice;

   double monetaryStop=(dir==PT_DIR_BUY?hwm-distancePrice:hwm+distancePrice);
   double structuralStop=0.0;
   bool structuralValid=false;
   if(dir==PT_DIR_BUY && g_majorLowCount>=1)
     {
      structuralStop=g_majorLows[0].price-StopBufferPrice();
      structuralValid=(structuralStop<price);
     }
   if(dir==PT_DIR_SELL && g_majorHighCount>=1)
     {
      structuralStop=g_majorHighs[0].price+StopBufferPrice();
      structuralValid=(structuralStop>price);
     }

   double existing=PositionGetDouble(POSITION_SL);
   double candidateStop=monetaryStop;
   if(structuralValid)
     candidateStop=(dir==PT_DIR_BUY?MathMax(monetaryStop,structuralStop):MathMin(monetaryStop,structuralStop));
   candidateStop=NormalizeDouble(candidateStop,_Digits);

   bool moreProtective=false;
   if(dir==PT_DIR_BUY) moreProtective=(existing<=0.0 || candidateStop>existing+_Point);
   else moreProtective=(existing<=0.0 || candidateStop<existing-_Point);
   if(!moreProtective) return;

   if(ModifyPositionStops(candidateStop,PositionGetDouble(POSITION_TP)))
     {
      g_currentTrailStop=candidateStop;
      double locked=MoneyForPriceDistance(dir,g_positionVolume,g_entryPrice,MathAbs(g_entryPrice-candidateStop));
      if(dir==PT_DIR_SELL) locked=MoneyForPriceDistance(dir,g_positionVolume,g_entryPrice,MathAbs(candidateStop-g_entryPrice));
      g_lockedProfit=MathMax(0.0,locked);
      WriteCoreEvent("TRAIL_MOVED","SETUP_VALID",StringFormat("Stop=%s DistanceMoney=%.2f Locked=%.2f",PriceToString(candidateStop),D,g_lockedProfit),"MODIFY_SL");
      WriteTradeEvent("TRAIL_MOVED","");
     }
  }

void ManagePosition()
  {
   if(!SelectOurPosition())
     {
      if(g_positionTicket!=0)
        {
         g_positionTicket=0;
         g_state=(g_paused?PT_STATE_PAUSED:PT_STATE_SCANNING);
         // Daily stats will be reconstructed from history; trade transaction records the exit.
        }
      return;
     }
   g_state=PT_STATE_POSITION_MANAGING;
   string closeReason=PositionCloseReason();
   if(closeReason!="")
     {
      CloseOurPosition(closeReason);
      return;
     }
   ApplyDynamicTrailing();
  }

//====================================================================
// NEW BAR ANALYSIS
//====================================================================
void ResetCandidate()
  {
   ZeroMemory(g_candidate);
   g_plannedRiskMoney=0.0;
   g_plannedVolume=0.0;
   g_candidate.setup=PT_SETUP_NONE;
   g_candidate.direction=PT_DIR_NONE;
  }

void ResetZone()
  {
   ZeroMemory(g_zone);
  }

bool LoadRates(MqlRates &rates[],int required)
  {
   ArraySetAsSeries(rates,true);
   ResetLastError();
   int copied=CopyRates(_Symbol,g_workTF,0,required,rates);
   if(copied<required) return false;
   return (copied>=PT_PA_SCALE_BARS+10);
  }

void UpdateLossCluster()
  {
   datetime from=StartOfServerDay(TimeCurrent());
   datetime to=TimeCurrent();
   if(!HistorySelect(from,to)) return;
   int total=HistoryDealsTotal();
   int losses=0,wins=0;
   for(int i=total-1;i>=0;i--)
     {
      ulong deal=HistoryDealGetTicket(i);
      if(deal==0) continue;
      if((long)HistoryDealGetInteger(deal,DEAL_MAGIC)!=g_magic) continue;
      if(HistoryDealGetString(deal,DEAL_SYMBOL)!=_Symbol) continue;
      long entry=HistoryDealGetInteger(deal,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY) continue;
      double net=HistoryDealGetDouble(deal,DEAL_PROFIT)+HistoryDealGetDouble(deal,DEAL_COMMISSION)+HistoryDealGetDouble(deal,DEAL_SWAP)+HistoryDealGetDouble(deal,DEAL_FEE);
      if(net<0.0) { losses++; wins=0; }
      else if(net>0.0) { wins++; losses=0; }
      else continue;
      if(losses>=PT_LOSS_COOLDOWN || wins>=PT_LOSS_COOLDOWN) break;
     }
   g_consecutiveLosses=losses;
   g_consecutiveWins=wins;
   if(g_consecutiveLosses>=PT_LOSS_COOLDOWN && g_cooldownUntilBar==0)
      g_cooldownUntilBar=iTime(_Symbol,g_workTF,0)+PT_COOLDOWN_MIN_BARS*TFMinutes(g_workTF)*60;
  }

void BuildContext(MqlRates &rates[])
  {
   if(g_trendState==PT_TREND_TRANSITION)
     {
      g_context=PT_CTX_TRANSITION;
      return;
     }
   if(!TrendValid())
     {
      g_context=(CheckTransition(rates)?PT_CTX_TRANSITION:PT_CTX_NO_TREND);
      return;
     }
   double price=(g_direction==PT_DIR_BUY?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   bool near=IsNearZone(price);
   if(near) g_context=PT_CTX_PULLBACK;
   else
     {
      if(g_direction==PT_DIR_BUY && rates[1].close>g_majorHighs[0].price+0.25*g_paScale) g_context=PT_CTX_IMPULSE;
      else if(g_direction==PT_DIR_SELL && rates[1].close<g_majorLows[0].price-0.25*g_paScale) g_context=PT_CTX_IMPULSE;
      else g_context=PT_CTX_PULLBACK;
     }
   // Retest: price is around latest broken structural level.
   if(g_direction==PT_DIR_BUY && g_majorHighCount>0)
     {
      double lvl=g_majorHighs[0].price;
      if(rates[1].low<=lvl+0.15*g_paScale && rates[1].high>=lvl-0.20*g_paScale && rates[1].close>lvl) g_context=PT_CTX_RETEST;
     }
   if(g_direction==PT_DIR_SELL && g_majorLowCount>0)
     {
      double lvl=g_majorLows[0].price;
      if(rates[1].high>=lvl-0.15*g_paScale && rates[1].low<=lvl+0.20*g_paScale && rates[1].close<lvl) g_context=PT_CTX_RETEST;
     }
   if(g_defense>=PT_DEF_DEFENSIVE) g_context=PT_CTX_DEFENSIVE;
  }

void AnalyzeNewBar()
  {
   MqlRates rates[];
   int required=MathMin(PT_MAX_SCAN_BARS,MathMax(RequiredStructuralBars(),RequiredContextBars()+20));
   if(!LoadRates(rates,required))
     {
      g_loadedBars=0;
      g_state=PT_STATE_SCANNING;
      WriteCoreEvent("DATA_READY","NO_DATA","Insufficient bars for analysis","WAIT");
      return;
     }
   g_loadedBars=ArraySize(rates);
   if(!ComputeScales(rates)) return;
   ENUM_PT_TREND_STATE priorTrend=g_trendState;
   DetectSwings(rates);
   BuildTrendScores();
   bool transitioned=false;
   if(priorTrend==PT_TREND_BUY && g_majorLowCount>0 && rates[1].close<g_majorLows[0].price-PT_HH_BUFFER_FACTOR*g_paScale)
      transitioned=true;
   if(priorTrend==PT_TREND_SELL && g_majorHighCount>0 && rates[1].close>g_majorHighs[0].price+PT_HH_BUFFER_FACTOR*g_paScale)
      transitioned=true;
   if(transitioned)
     {
      g_trendState=PT_TREND_TRANSITION;
      g_context=PT_CTX_TRANSITION;
      g_direction=PT_DIR_NONE;
     }
   ComputeDefenseScore(rates);
   UpdateLossCluster();
   BuildContext(rates);
   ResetCandidate();
   if(g_defense==PT_DEF_HARD)
     {
      g_state=PT_STATE_DEFENSIVE_LOCK;
     }
   else if(!TrendValid())
     {
      g_state=PT_STATE_NO_TREND;
     }
   else
     {
      g_state=PT_STATE_TREND_READY;
      if(BuildCandidate(rates))
        {
         if(g_cooldownUntilBar>TimeCurrent() && g_trendScore>=55.0)
           {
            g_cooldownUntilBar=0;
            WriteCoreEvent("COOLDOWN_OFF","","New structural setup with TrendScore>=55","REARM");
           }
         g_state=PT_STATE_TRIGGER_WAIT;
         if(g_candidate.riskNorm<=PT_MAX_RISK_NORM && g_candidate.spaceRatio>=PT_MIN_SPACE_RATIO)
            g_state=PT_STATE_SETUP_ARMED;
         else
           {
            string gateReason="";
            string gateDetail="";
            if(g_candidate.riskNorm>PT_MAX_RISK_NORM)
              { gateReason="INVALIDATION_TOO_FAR"; gateDetail=StringFormat("RiskNorm=%.2f > %.2f",g_candidate.riskNorm,PT_MAX_RISK_NORM); }
            else if(g_candidate.spaceRatio<PT_MIN_SPACE_RATIO)
              { gateReason="SPACE_INSUFFICIENT"; gateDetail=StringFormat("SpaceRatio=%.2f < %.2f",g_candidate.spaceRatio,PT_MIN_SPACE_RATIO); }
            WriteCoreEvent("SETUP_NOT_ARMED",gateReason,gateDetail,"WAIT");
           }
        }
      else
        {
         g_state=PT_STATE_CONTEXT_BUILDING;
        }
     }

   g_lastAnalysisBar=rates[1].time;
   WritePriceAction();
   WriteCoreEvent("BAR_ANALYSIS","","Analysis refresh","ANALYZE");
   UpdateDrawings();
  }

//====================================================================
// TELEMETRY
//====================================================================
string LastHH()
  {
   if(g_majorHighCount<2) return (g_majorHighCount>0?PriceToString(g_majorHighs[0].price):"");
   if(g_majorHighs[0].price>g_majorHighs[1].price) return PriceToString(g_majorHighs[0].price);
   if(g_majorHighCount>=3 && g_majorHighs[1].price>g_majorHighs[2].price) return PriceToString(g_majorHighs[1].price);
   return "";
  }
string LastHL()
  {
   if(g_majorLowCount<2) return (g_majorLowCount>0?PriceToString(g_majorLows[0].price):"");
   if(g_majorLows[0].price>g_majorLows[1].price) return PriceToString(g_majorLows[0].price);
   if(g_majorLowCount>=3 && g_majorLows[1].price>g_majorLows[2].price) return PriceToString(g_majorLows[1].price);
   return "";
  }
string LastLH()
  {
   if(g_majorHighCount<2) return "";
   if(g_majorHighs[0].price<g_majorHighs[1].price) return PriceToString(g_majorHighs[0].price);
   if(g_majorHighCount>=3 && g_majorHighs[1].price<g_majorHighs[2].price) return PriceToString(g_majorHighs[1].price);
   return "";
  }
string LastLL()
  {
   if(g_majorLowCount<2) return "";
   if(g_majorLows[0].price<g_majorLows[1].price) return PriceToString(g_majorLows[0].price);
   if(g_majorLowCount>=3 && g_majorLows[1].price<g_majorLows[2].price) return PriceToString(g_majorLows[1].price);
   return "";
  }

long CurrentOrderTicket() { return (long)g_trade.ResultOrder(); }
long CurrentDealTicket()  { return (long)g_trade.ResultDeal(); }
long CurrentRetcode()     { return (long)g_trade.ResultRetcode(); }

void WriteCoreEvent(string eventType,string reasonCode,string reasonDetail,string action="")
  {
   if(!InpWriteCSV) return;
   g_eventSeq++;
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   double spreadPoints=(tick.ask-tick.bid)/_Point;
   double volForSpread=(g_positionVolume>0.0?g_positionVolume:(g_plannedVolume>0.0?g_plannedVolume:SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)));
   int spreadDir=(g_direction==PT_DIR_SELL?PT_DIR_SELL:PT_DIR_BUY);
   double spreadMoney=MoneyForPriceDistance(spreadDir,volForSpread,(spreadDir==PT_DIR_SELL?tick.bid:tick.ask),tick.ask-tick.bid);
   double daily=DailyNet();
   int cooldown=0;
   if(g_cooldownUntilBar>TimeCurrent()) cooldown=(int)((g_cooldownUntilBar-TimeCurrent())/MathMax(1,TFMinutes(g_workTF)*60));
   string eid=(g_candidate.eventId!=""?g_candidate.eventId:g_positionEventId);
   double closedNet=0.0;
   if(g_lastProcessedDeal>0 && HistoryDealSelect((ulong)g_lastProcessedDeal))
     {
      ulong d=(ulong)g_lastProcessedDeal;
      closedNet=HistoryDealGetDouble(d,DEAL_PROFIT)+HistoryDealGetDouble(d,DEAL_COMMISSION)+HistoryDealGetDouble(d,DEAL_SWAP)+HistoryDealGetDouble(d,DEAL_FEE);
     }
   double riskMoney=(g_plannedRiskMoney>0.0?g_plannedRiskMoney:InpRiskMoneyPerTrade);
   double riskPoints=(g_candidate.riskDistance>0.0?g_candidate.riskDistance/_Point:0.0);
   double volPlanned=g_plannedVolume;
   if(volPlanned<=0.0) volPlanned=(g_positionVolume>0.0?g_positionVolume:0.0);
   int timeInTrade=(g_positionEntryTime>0?(int)(TimeCurrent()-g_positionEntryTime):0);
   string triggerType=(g_candidate.setup==PT_SETUP_SWEEP_RECLAIM?"SWEEP_RECLAIM":"MICRO_BREAK");
   string triggerState=(g_candidate.active?"WAIT":"IDLE");
   string structureState=TrendToString(g_trendState);
   if(g_majorHighCount>=2 && g_majorLowCount>=2)
     {
      if(g_trendState==PT_TREND_BUY) structureState="HH/HL";
      else if(g_trendState==PT_TREND_SELL) structureState="LH/LL";
     }
   string line=StringFormat(
      "%s;%s;%s;%s;%s;%I64d;%d;%I64u;%s;%s;%s;%s;%s;%.2f;%s;%s;%s;%.2f;%s;%s;%.5f;%.5f;%.1f;%.2f;%.5f;%.5f;%s;%s;%s;%s;%d;%s;%.5f;%.5f;%.2f;%.5f;%.5f;%.5f;%.1f;%.3f;%.2f;%.4f;%.4f;%.5f;%.5f;%.3f;%d;%.2f;%.5f;%d;%d;%.2f;%.2f;%.2f;%.5f;%.5f;%.2f;%.2f;%.2f;%.2f;%.2f;%d;%d;%.4f;%.4f;%.4f;%.2f;%s;%d;%s;%s;%s;%I64d;%I64d;%I64d;%.2f;%.2f;%d;%I64d",
      NowString(),TimeToString(TimeCurrent(),TIME_DATE),TimeToString(TimeCurrent(),TIME_SECONDS),_Symbol,TFToString(g_workTF),
      g_magic,InpInstanceID,g_eventSeq,eid,eventType,StateToString(g_state),DirectionToString(g_direction),TrendToString(g_trendState),g_trendScore,
      structureState,ContextToString(g_context),SetupToString(g_candidate.setup),g_candidate.score,triggerType,triggerState,
      tick.bid,tick.ask,spreadPoints,spreadMoney,g_paScale,g_microScale,LastHH(),LastHL(),LastLH(),LastLL(),g_zone.id,g_zone.type,g_zone.low,g_zone.high,g_zone.score,
      g_candidate.plannedEntry,g_entryPrice,g_candidate.invalidation,riskPoints,g_candidate.riskNorm,riskMoney,volPlanned,g_positionVolume,g_candidate.nearestObstacle,g_candidate.spaceDistance,g_candidate.spaceRatio,
      (InpTPEnable?1:0),InpTPMoney,g_positionTP,(InpTrailEnable?1:0),(g_trailActive?1:0),InpTrailActivationMoney,g_positionMaxProfit,g_currentTrailDistanceMoney,g_currentTrailDistancePrice,g_currentTrailStop,g_lockedProfit,
      daily,InpDailyTargetMoney,MathMin(0.0,daily),InpDailyLossLimitMoney,g_consecutiveWins,g_consecutiveLosses,g_pathEfficiency,g_whipsawIndex,g_rangeRatio,g_defenseScore,
      DefenseToString(g_defense),cooldown,action,reasonCode,reasonDetail,(long)g_trade.ResultOrder(),(long)g_trade.ResultDeal(),(long)g_positionTicket,g_currentProfit,closedNet,timeInTrade,(long)g_trade.ResultRetcode());
   AppendCsvLine(CoreFileName(),line);
  }

void WritePriceAction()
  {
   if(!InpWriteCSV) return;
   MqlRates rates[];
   if(!LoadRates(rates,MathMin(PT_MAX_SCAN_BARS,RequiredStructuralBars()+10))) return;
   double lastImp=0,prevImp=0,pb=0,pbr=0;
   if(g_majorHighCount>=2 && g_majorLowCount>=2)
     {
      lastImp=MathAbs(g_majorHighs[0].price-g_majorLows[0].price);
      prevImp=MathAbs(g_majorHighs[1].price-g_majorLows[1].price);
      if(g_direction==PT_DIR_BUY) pb=MathAbs(g_majorHighs[0].price-g_majorLows[1].price);
      if(g_direction==PT_DIR_SELL) pb=MathAbs(g_majorLows[0].price-g_majorHighs[1].price);
      pbr=(lastImp>0?pb/lastImp:0);
     }
   double breakDist=0.0;
   bool breakDet=false;
   if(g_direction==PT_DIR_BUY && g_majorHighCount>0) { breakDist=rates[1].close-g_majorHighs[0].price; breakDet=(breakDist>0); }
   if(g_direction==PT_DIR_SELL && g_majorLowCount>0) { breakDist=g_majorLows[0].price-rates[1].close; breakDet=(breakDist>0); }
   string channelState; double channelSlope; double channelIntegrity;
   ChannelMetrics(channelState,channelSlope,channelIntegrity);
   string line=StringFormat("%s;%s;%s;%s;%.5f;%.5f;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%.2f;%.2f;%.2f;%.2f;%.2f;%.5f;%.5f;%.5f;%.3f;%s;%s;%.2f;%d;%s;%.5f;%d;%d;%s;%d;%s;%.5f;%.5f;%.2f;%s;%.6f;%.2f;%s;%s;%.2f;%.5f;%.5f;%.5f;%.5f;%.3f;%.4f;%.4f;%.4f",
      NowString(),TimeToString(rates[1].time,TIME_DATE|TIME_SECONDS),_Symbol,TFToString(g_workTF),g_paScale,g_microScale,
      (g_majorHighCount>0?PriceToString(g_majorHighs[0].price):""),(g_majorHighCount>1?PriceToString(g_majorHighs[1].price):""),(g_majorHighCount>2?PriceToString(g_majorHighs[2].price):""),
      (g_majorLowCount>0?PriceToString(g_majorLows[0].price):""),(g_majorLowCount>1?PriceToString(g_majorLows[1].price):""),(g_majorLowCount>2?PriceToString(g_majorLows[2].price):""),
      LastHH(),LastHL(),LastLH(),LastLL(),TrendToString(g_trendState),DirectionToString(g_direction),g_trendScore,g_structureScore,g_continuationScore,g_pullbackQuality,g_recencyScore,lastImp,prevImp,pb,pbr,ContextToString(g_context),DirectionToString(g_direction),g_trendScore,(breakDet?1:0),DirectionToString(g_direction),breakDist,(g_context==PT_CTX_RETEST?1:0),0,"NONE",g_zone.id,g_zone.type,g_zone.low,g_zone.high,g_zone.score,channelState,channelSlope,channelIntegrity,DirectionToString(g_direction),SetupToString(g_candidate.setup),g_candidate.score,g_candidate.plannedEntry,g_candidate.invalidation,g_candidate.riskDistance,g_candidate.nearestObstacle,g_candidate.spaceRatio,g_pathEfficiency,g_whipsawIndex,g_rangeRatio);
   AppendCsvLine(PriceActionFileName(),line);
  }

// helper returning string 0/1 without relying on bool formatting
string _falseBool(bool v) { return (v?"1":"0"); }

void WriteTradeEvent(string eventType,string exitReason="")
  {
   if(!InpWriteCSV) return;
   double sl=0.0,tp=0.0,floating=g_currentProfit;
   if(SelectOurPosition())
     {
      sl=PositionGetDouble(POSITION_SL);
      tp=PositionGetDouble(POSITION_TP);
      floating=PositionGetDouble(POSITION_PROFIT);
     }
   double gross=0.0,commission=0.0,swap=0.0,fee=0.0,net=0.0,fill=0.0,vol=0.0;
   datetime dealTime=0;
   long orderTicket=(long)g_trade.ResultOrder();
   long dealTicket=(long)g_trade.ResultDeal();
   if(g_lastProcessedDeal>0 && HistoryDealSelect((ulong)g_lastProcessedDeal))
     {
      ulong d=(ulong)g_lastProcessedDeal;
      gross=HistoryDealGetDouble(d,DEAL_PROFIT);
      commission=HistoryDealGetDouble(d,DEAL_COMMISSION);
      swap=HistoryDealGetDouble(d,DEAL_SWAP);
      fee=HistoryDealGetDouble(d,DEAL_FEE);
      net=gross+commission+swap+fee;
      fill=HistoryDealGetDouble(d,DEAL_PRICE);
      vol=HistoryDealGetDouble(d,DEAL_VOLUME);
      dealTime=(datetime)HistoryDealGetInteger(d,DEAL_TIME);
      dealTicket=g_lastProcessedDeal;
      orderTicket=(long)HistoryDealGetInteger(d,DEAL_ORDER);
     }
   if(vol<=0.0) vol=(g_positionVolume>0.0?g_positionVolume:0.0);
   int dir=g_direction;
   if(dir==PT_DIR_NONE && vol>0.0)
     {
      if(SelectOurPosition()) dir=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY?PT_DIR_BUY:PT_DIR_SELL);
     }
   string line=StringFormat(
      "%s;%s;%s;%I64d;%I64u;%s;%I64d;%I64d;%I64d;%s;%.4f;%.5f;%.5f;%.5f;%.5f;%.5f;%.5f;%.5f;%.2f;%.2f;%.2f;%.5f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%s;%s;%d;%s;%s;%s;%s;%s;%s",
      NowString(),_Symbol,TFToString(g_workTF),g_magic,g_eventSeq,eventType,
      g_positionId,orderTicket,dealTicket,DirectionToString(dir),vol,
      g_candidate.plannedEntry,0.0,(fill>0.0?fill:g_entryPrice),
      0.0,sl,0.0,tp,floating,g_positionMaxProfit,g_currentTrailDistanceMoney,
      g_currentTrailStop,g_lockedProfit,gross,commission,swap,fee,net,
      TimeToString(g_positionEntryTime,TIME_DATE|TIME_SECONDS),
      (dealTime>0?TimeToString(dealTime,TIME_DATE|TIME_SECONDS):NowString()),
      (g_positionEntryTime>0?(int)((dealTime>0?dealTime:TimeCurrent())-g_positionEntryTime):0),
      exitReason,g_positionSetup,g_positionTrigger,TrendToString(g_trendState),ContextToString(g_context),DefenseToString(g_defense));
   AppendCsvLine(TradesFileName(),line);
  }

void WriteDailySnapshot()
  {
   if(!InpWriteCSV) return;
   datetime from=StartOfServerDay(TimeCurrent());
   datetime to=TimeCurrent();
   double grossProfit=0.0,grossLoss=0.0,netProfit=0.0;
   double winSum=0.0,lossSum=0.0,largestWin=0.0,largestLoss=0.0;
   int wins=0,losses=0,trades=0,buyTrades=0,sellTrades=0;
   double equityCurve=0.0,peakCurve=0.0,maxDD=0.0,maxLoss=0.0;
   if(HistorySelect(from,to))
     {
      int total=HistoryDealsTotal();
      for(int i=0;i<total;i++)
        {
         ulong d=HistoryDealGetTicket(i);
         if(d==0) continue;
         if((long)HistoryDealGetInteger(d,DEAL_MAGIC)!=g_magic) continue;
         if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
         long de=HistoryDealGetInteger(d,DEAL_ENTRY);
         if(de!=DEAL_ENTRY_OUT && de!=DEAL_ENTRY_OUT_BY) continue;
         double gross=HistoryDealGetDouble(d,DEAL_PROFIT);
         double net=gross+HistoryDealGetDouble(d,DEAL_COMMISSION)+HistoryDealGetDouble(d,DEAL_SWAP)+HistoryDealGetDouble(d,DEAL_FEE);
         netProfit+=net;
         if(gross>0.0) { grossProfit+=gross; wins++; winSum+=gross; largestWin=MathMax(largestWin,gross); }
         if(gross<0.0) { grossLoss+=gross; losses++; lossSum+=gross; largestLoss=MathMin(largestLoss,gross); }
         trades++;
         long dtype=HistoryDealGetInteger(d,DEAL_TYPE);
         if(dtype==DEAL_TYPE_BUY) buyTrades++;
         if(dtype==DEAL_TYPE_SELL) sellTrades++;
         equityCurve+=net;
         peakCurve=MathMax(peakCurve,equityCurve);
         maxDD=MathMax(maxDD,peakCurve-equityCurve);
         maxLoss=MathMin(maxLoss,equityCurve);
        }
     }
   double winRate=(trades>0?100.0*(double)wins/(double)trades:0.0);
   double avgWin=(wins>0?winSum/wins:0.0);
   double avgLoss=(losses>0?MathAbs(lossSum)/losses:0.0);
   double profitFactor=(MathAbs(grossLoss)>0.0?grossProfit/MathAbs(grossLoss):0.0);
   double endingBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   double startingBalance=endingBalance-netProfit;
   double dnet=DailyNet();
   string line=StringFormat(
      "%s;%s;%s;%I64d;%.2f;%.2f;%.2f;%.2f;%.2f;%d;%d;%.2f;%.2f;%.2f;%.2f;%.2f;%.3f;%d;%d;%.2f;%s;%.2f;%s;%d;%d;%d;%.2f;%.2f;%d;%.2f;%.2f;%.2f;%.2f;%d;%d",
      DayKey(TimeCurrent()),_Symbol,TFToString(g_workTF),g_magic,
      startingBalance,endingBalance,grossProfit,grossLoss,dnet,wins,losses,winRate,
      avgWin,avgLoss,largestWin,largestLoss,profitFactor,g_consecutiveWins,g_consecutiveLosses,
      InpDailyTargetMoney,(InpDailyTargetEnable&&dnet>=InpDailyTargetMoney?"1":"0"),
      InpDailyLossLimitMoney,(InpDailyLossLimitEnable&&dnet<=-MathAbs(InpDailyLossLimitMoney)?"1":"0"),
      trades,buyTrades,sellTrades,maxDD,MathAbs(maxLoss),g_dailyTrailActivated,g_dailyTrailClosedProfit,
      g_dailyTpClosedProfit,g_dailySlClosedProfit,g_dailyEmergencyClosedProfit,g_dailyDefensiveEvents,g_dailyCooldownEvents);
   AppendCsvLine(DailyFileName(),line);
  }

void WriteError(string stage,string operation,int errorCode,long tradeRetcode,string reason,string details)
  {
   if(!InpWriteCSV) return;
   MqlTick t; SymbolInfoTick(_Symbol,t);
   double sl=0.0,tp=0.0;
   if(SelectOurPosition()) { sl=PositionGetDouble(POSITION_SL); tp=PositionGetDouble(POSITION_TP); }
   string line=StringFormat(
      "%s;%s;%s;%I64d;%s;%s;%d;%d;%I64d;%s;%.5f;%.5f;%.4f;%.5f;%.5f;%.5f;%I64d;%I64d;%I64d;%s;%s;%s",
      NowString(),_Symbol,TFToString(g_workTF),g_magic,stage,operation,errorCode,errorCode,tradeRetcode,
      g_trade.ResultRetcodeDescription(),t.bid,t.ask,g_positionVolume,g_entryPrice,sl,tp,
      (long)g_trade.ResultOrder(),(long)g_trade.ResultDeal(),(long)g_positionTicket,reason,details,"NO_RECOVERY");
   AppendCsvLine(ErrorsFileName(),line);
  }


//====================================================================
// DRAWING ENGINE - ADVANCED PRICE ACTION MAP
//====================================================================
// The chart is part of the strategy's observability layer.
// Every visible object answers one of these questions:
//   WHERE is structure?
//   WHAT is the active trend?
//   WHERE is the setup zone?
//   WHERE is the thesis invalidated?
//   WHERE is the planned entry?
//   HOW MUCH space exists ahead?
//   HOW is the open position being protected?
// Existing objects are updated in-place to avoid visual flicker.
//====================================================================
void DeleteDrawingPrefix(string prefix)
  {
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,prefix)==0) ObjectDelete(0,name);
     }
  }

void SetObjCommon(const string name,const color clr,const int width=1,
                  const ENUM_LINE_STYLE style=STYLE_SOLID,const bool back=true)
  {
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

void SetTrendLine(const string name,const datetime t1,const double p1,const datetime t2,const double p2,
                  const color clr,const int width=1,const ENUM_LINE_STYLE style=STYLE_SOLID,const bool ray=true)
  {
   if(t1<=0 || t2<=0 || p1<=0.0 || p2<=0.0) return;
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_TREND,0,t1,p1,t2,p2);
   ObjectMove(0,name,0,t1,p1);
   ObjectMove(0,name,1,t2,p2);
   SetObjCommon(name,clr,width,style,true);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,ray);
  }

void SetHLine(const string name,const double price,const color clr,
              const ENUM_LINE_STYLE style=STYLE_DOT,const int width=1)
  {
   if(price<=0.0 || !MathIsValidNumber(price))
     {
      ObjectDelete(0,name);
      return;
     }
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_HLINE,0,0,price);
   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   SetObjCommon(name,clr,width,style,true);
  }

void SetTextAt(const string name,const string text,const datetime t,const double p,const color clr,
               const int fontsize=8,const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER,const string tooltip="")
  {
   if(t<=0 || p<=0.0)
     {
      ObjectDelete(0,name);
      return;
     }
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_TEXT,0,t,p);
   ObjectMove(0,name,0,t,p);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Segoe UI");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   if(tooltip!="") ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
  }

void SetZoneRect(const string name,const datetime t1,const double high,const datetime t2,const double low,
                 const color clr)
  {
   if(t1<=0 || t2<=0 || high<=low)
     {
      ObjectDelete(0,name);
      return;
     }
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,high,t2,low);
   ObjectMove(0,name,0,t1,high);
   ObjectMove(0,name,1,t2,low);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_FILL,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

void SetVerticalMarker(const string name,const datetime t,const color clr,const ENUM_LINE_STYLE style=STYLE_DASH)
  {
   if(t<=0)
     {
      ObjectDelete(0,name);
      return;
     }
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_VLINE,0,t,0);
   ObjectMove(0,name,0,t,0.0);
   SetObjCommon(name,clr,1,style,true);
  }

string SwingRoleText(const bool isHigh,const int idx,const PTSwing &arr[])
  {
   if(idx<0 || idx>=ArraySize(arr)) return "SWING";
   if(idx+1>=ArraySize(arr)) return (isHigh?"LH":"LL");
   if(isHigh) return (arr[idx].price>arr[idx+1].price?"HH":"LH");
   return (arr[idx].price>arr[idx+1].price?"HL":"LL");
  }

double SwingStrength(const PTSwing &s)
  {
   if(g_paScale<=0.0) return 0.0;
   return Clamp(55.0+25.0*SafeDiv(s.prominence,g_paScale),0.0,100.0);
  }

void DrawSwingPoint(const string id,const PTSwing &s,const string role,const color clr)
  {
   if(!InpDrawStructure || s.time<=0 || s.price<=0.0) return;
   SetTextAt(PT_PREFIX+id+"_TAG",
             role+"  |  "+DoubleToString(SwingStrength(s),0),
             s.time,s.price,clr,8,
             s.isHigh?ANCHOR_LEFT_LOWER:ANCHOR_LEFT_UPPER,
             StringFormat("%s | price=%s | prominence=%.4f | scale=%.4f | strength=%.1f",
                          role,PriceToString(s.price),s.prominence,g_paScale,SwingStrength(s)));
   // Small structural tick centered on the swing.
   string line=PT_PREFIX+id+"_TICK";
   datetime t2=s.time+(datetime)MathMax(1,TFMinutes(g_workTF))*60;
   SetTrendLine(line,s.time,s.price,t2,s.price,clr,1,STYLE_SOLID,false);
  }

void DrawMajorStructurePath()
  {
   if(!InpDrawStructure) return;

   PTSwing path[12];
   int n=0;
   for(int i=0;i<MathMin(g_majorHighCount,6) && n<12;i++) path[n++]=g_majorHighs[i];
   for(int i=0;i<MathMin(g_majorLowCount,6) && n<12;i++)  path[n++]=g_majorLows[i];
   if(n<2) return;

   // Sort oldest -> newest. Series index is larger for older candles.
   for(int i=0;i<n-1;i++)
      for(int j=i+1;j<n;j++)
         if(path[i].index<path[j].index)
           {
            PTSwing tmp=path[i]; path[i]=path[j]; path[j]=tmp;
           }

   for(int i=0;i<n-1;i++)
     {
      string name=PT_PREFIX+"STRUCT_SEG_"+IntegerToString(i);
      color c=(path[i].isHigh==path[i+1].isHigh)?clrSlateGray:(g_direction==PT_DIR_BUY?clrAqua:(g_direction==PT_DIR_SELL?clrTomato:clrLightSteelBlue));
      SetTrendLine(name,path[i].time,path[i].price,path[i+1].time,path[i+1].price,c,2,STYLE_SOLID,false);
     }

   for(int i=n;i<12;i++)
     {
      ObjectDelete(0,PT_PREFIX+"STRUCT_SEG_"+IntegerToString(i));
     }

   for(int i=0;i<n;i++)
     {
      string role="SWING";
      if(path[i].isHigh)
        {
         bool hh=(i+1<n && path[i].price>path[i+1].price);
         role=hh?"HH":"LH";
        }
      else
        {
         bool hl=(i+1<n && path[i].price>path[i+1].price);
         role=hl?"HL":"LL";
        }
      color c=path[i].isHigh?((role=="HH")?clrAqua:clrTomato):((role=="HL")?clrLimeGreen:clrOrangeRed);
      DrawSwingPoint("SW_"+IntegerToString(i),path[i],role,c);
     }
   for(int i=n;i<12;i++)
     {
      ObjectDelete(0,PT_PREFIX+"SW_"+IntegerToString(i)+"_TAG");
      ObjectDelete(0,PT_PREFIX+"SW_"+IntegerToString(i)+"_TICK");
     }
  }

void DrawTrendAndChannel()
  {
   // Clean previous geometry first so stale channels cannot survive a regime change.
   if(!InpDrawChannel)
     {
      DeleteDrawingPrefix(PT_PREFIX+"CH_");
      return;
     }

   if(g_majorHighCount<2 || g_majorLowCount<2)
     {
      DeleteDrawingPrefix(PT_PREFIX+"CH_");
      return;
     }

   datetime now=TimeCurrent();
   if(now<=0) now=TimeTradeServer();
   datetime ext=now+(datetime)(TFMinutes(g_workTF)*60*40);
   if(ext<=now) ext=now+3600;

   // FIX v1.01: [0] = pivo mais recente, [1] = anterior -> dt = t0 - t1 (positivo).
   double highSlope=(g_majorHighs[0].price-g_majorHighs[1].price)/
                    (double)MathMax(1,(int)(g_majorHighs[0].time-g_majorHighs[1].time));
   double lowSlope=(g_majorLows[0].price-g_majorLows[1].price)/
                   (double)MathMax(1,(int)(g_majorLows[0].time-g_majorLows[1].time));

   double hp= g_majorHighs[0].price + highSlope*(double)(ext-g_majorHighs[0].time);
   double lp= g_majorLows[0].price  + lowSlope *(double)(ext-g_majorLows[0].time);
   if(hp<=lp) { DeleteDrawingPrefix(PT_PREFIX+"CH_"); return; }

   color c=(g_trendState==PT_TREND_BUY?clrDeepSkyBlue:(g_trendState==PT_TREND_SELL?clrTomato:clrSlateGray));
   SetTrendLine(PT_PREFIX+"CH_TOP",g_majorHighs[1].time,g_majorHighs[1].price,ext,hp,c,2,STYLE_DASH,true);
   SetTrendLine(PT_PREFIX+"CH_BOTTOM",g_majorLows[1].time,g_majorLows[1].price,ext,lp,c,2,STYLE_DASH,true);

   datetime mid_t1=(g_majorHighs[1].time>g_majorLows[1].time?g_majorHighs[1].time:g_majorLows[1].time);
   double top1=g_majorHighs[1].price + highSlope*(double)(mid_t1-g_majorHighs[1].time);
   double bot1=g_majorLows[1].price  + lowSlope *(double)(mid_t1-g_majorLows[1].time);
   double mid1=(top1+bot1)/2.0;
   double midExt=(hp+lp)/2.0;
   SetTrendLine(PT_PREFIX+"CH_MID",mid_t1,mid1,ext,midExt,clrSlateGray,1,STYLE_DOT,true);

   double width=hp-lp;
   double widthNorm=SafeDiv(width,g_paScale);
   double slopeNorm=SafeDiv(0.5*(MathAbs(highSlope)+MathAbs(lowSlope))*(double)TFMinutes(g_workTF)*60.0,g_paScale);
   double symmetry=1.0-Clamp(SafeDiv(MathAbs(highSlope-lowSlope)*(double)TFMinutes(g_workTF)*60.0,MathMax(g_paScale*0.35,_Point)),0.0,1.0);
   string cstate=(g_trendState==PT_TREND_BUY?"UP CHANNEL":(g_trendState==PT_TREND_SELL?"DOWN CHANNEL":"MIXED CHANNEL"));
   string ctext=StringFormat("%s  | width %.2f PA | slope %.2f | integrity %.0f",
                             cstate,widthNorm,slopeNorm,100.0*symmetry);
   SetTextAt(PT_PREFIX+"CH_INFO",ctext,ext,midExt,c,8,ANCHOR_LEFT_UPPER,
             StringFormat("Channel width=%.5f (%.2f PA) | slopeNorm=%.3f | integrity=%.1f",width,widthNorm,slopeNorm,100.0*symmetry));

   // Live channel position marker.
   double cur=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double topNow=g_majorHighs[0].price + highSlope*(double)(now-g_majorHighs[0].time);
   double botNow=g_majorLows[0].price + lowSlope*(double)(now-g_majorLows[0].time);
   double pos=SafeDiv(cur-botNow,MathMax(topNow-botNow,_Point));
   pos=Clamp(pos,0.0,1.0);
   string posTxt=StringFormat("CHANNEL POS %.0f%%",100.0*pos);
   SetTextAt(PT_PREFIX+"CH_POS",posTxt,now,cur,clrWhite,8,ANCHOR_RIGHT_UPPER,
             StringFormat("Current price=%s | lower=%s | upper=%s | position=%.1f%%",
                          PriceToString(cur),PriceToString(botNow),PriceToString(topNow),100.0*pos));
  }

void DrawZoneLayer()
  {
   if(!InpDrawZones || !g_zone.active)
     {
      DeleteDrawingPrefix(PT_PREFIX+"ZONE_");
      return;
     }

   datetime now=TimeCurrent();
   if(now<=0) now=TimeTradeServer();
   int barsLeft=20;
   int barsRight=35;
   datetime t1=g_zone.time-(datetime)(TFMinutes(g_workTF)*60*barsLeft);
   datetime t2=now+(datetime)(TFMinutes(g_workTF)*60*barsRight);
   color edge=(g_zone.direction==PT_DIR_BUY?clrLimeGreen:clrTomato);
   color center=(g_zone.direction==PT_DIR_BUY?clrDeepSkyBlue:clrOrange);

   SetZoneRect(PT_PREFIX+"ZONE_BOX",t1,g_zone.high,t2,g_zone.low,edge);
   SetHLine(PT_PREFIX+"ZONE_CENTER",(g_zone.high+g_zone.low)/2.0,center,STYLE_DOT,1);
   string label=(g_zone.direction==PT_DIR_BUY?"BUY ZONE":"SELL ZONE");
   string detail=StringFormat("%s | score %.0f | range %s - %s | scale %.2f",
                              label,g_zone.score,PriceToString(g_zone.low),PriceToString(g_zone.high),g_paScale);
   SetTextAt(PT_PREFIX+"ZONE_LABEL",detail,t2,g_zone.high,edge,8,ANCHOR_LEFT_UPPER,
             StringFormat("%s | score %.1f | low=%s | high=%s | anchor=%s",
                          label,g_zone.score,PriceToString(g_zone.low),PriceToString(g_zone.high),PriceToString((g_zone.low+g_zone.high)/2.0)));
  }

void DrawBreakMarkers()
  {
   if(!InpDrawStructure || g_majorHighCount<1 || g_majorLowCount<1)
     {
      DeleteDrawingPrefix(PT_PREFIX+"BREAK_");
      return;
     }
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,g_workTF,0,8,rates);
   if(copied<4)
     {
      DeleteDrawingPrefix(PT_PREFIX+"BREAK_");
      return;
     }

   double buffer=MathMax(0.10*g_paScale,2.0*SymbolInfoDouble(_Symbol,SYMBOL_POINT));
   bool bosUp=(rates[1].close>g_majorHighs[0].price+buffer);
   bool bosDn=(rates[1].close<g_majorLows[0].price-buffer);
   if(bosUp)
     {
      SetVerticalMarker(PT_PREFIX+"BREAK_UP",rates[1].time,clrAqua,STYLE_DASHDOT);
      SetTextAt(PT_PREFIX+"BREAK_UP_TXT","BOS UP  |  CLOSE CONFIRMED",rates[1].time,rates[1].high,clrAqua,8,ANCHOR_LEFT_LOWER,
                StringFormat("Break up | close=%s | level=%s | buffer=%s",PriceToString(rates[1].close),PriceToString(g_majorHighs[0].price),PriceToString(buffer)));
     }
   else
     {
      ObjectDelete(0,PT_PREFIX+"BREAK_UP"); ObjectDelete(0,PT_PREFIX+"BREAK_UP_TXT");
     }
   if(bosDn)
     {
      SetVerticalMarker(PT_PREFIX+"BREAK_DN",rates[1].time,clrTomato,STYLE_DASHDOT);
      SetTextAt(PT_PREFIX+"BREAK_DN_TXT","BOS DOWN  |  CLOSE CONFIRMED",rates[1].time,rates[1].low,clrTomato,8,ANCHOR_LEFT_UPPER,
                StringFormat("Break down | close=%s | level=%s | buffer=%s",PriceToString(rates[1].close),PriceToString(g_majorLows[0].price),PriceToString(buffer)));
     }
   else
     {
      ObjectDelete(0,PT_PREFIX+"BREAK_DN"); ObjectDelete(0,PT_PREFIX+"BREAK_DN_TXT");
     }
  }

void DrawCandidatePlan()
  {
   if(!g_mapVisible || !g_candidate.active)
     {
      DeleteDrawingPrefix(PT_PREFIX+"PLAN_");
      return;
     }
   int dir=g_candidate.direction;
   color tc=(dir==PT_DIR_BUY?clrLimeGreen:clrTomato);
   datetime now=TimeCurrent();
   if(now<=0) now=TimeTradeServer();
   datetime future=now+(datetime)(TFMinutes(g_workTF)*60*30);

   // Entry + invalidation + obstacle.
   SetHLine(PT_PREFIX+"PLAN_ENTRY",g_candidate.plannedEntry,tc,STYLE_SOLID,2);
   SetHLine(PT_PREFIX+"PLAN_INV",g_candidate.invalidation,clrOrangeRed,STYLE_DOT,2);
   if(g_candidate.nearestObstacle>0.0)
      SetHLine(PT_PREFIX+"PLAN_OBS",g_candidate.nearestObstacle,clrGold,STYLE_DASH,1);
   else
      ObjectDelete(0,PT_PREFIX+"PLAN_OBS");

   // Visual risk band.
   double hi=MathMax(g_candidate.plannedEntry,g_candidate.invalidation);
   double lo=MathMin(g_candidate.plannedEntry,g_candidate.invalidation);
   SetZoneRect(PT_PREFIX+"PLAN_RISK_BAND",now,hi,future,lo,clrOrangeRed);

   // Space band from entry to nearest obstacle.
   if(g_candidate.nearestObstacle>0.0)
     {
      double shi=MathMax(g_candidate.plannedEntry,g_candidate.nearestObstacle);
      double slo=MathMin(g_candidate.plannedEntry,g_candidate.nearestObstacle);
      SetZoneRect(PT_PREFIX+"PLAN_SPACE_BAND",now,shi,future,slo,clrDeepSkyBlue);
     }
   else ObjectDelete(0,PT_PREFIX+"PLAN_SPACE_BAND");

   string plan=StringFormat("%s  |  SETUP %s  |  SCORE %.0f",
                            dir==PT_DIR_BUY?"BUY PLAN":"SELL PLAN",SetupToString(g_candidate.setup),g_candidate.score);
   SetTextAt(PT_PREFIX+"PLAN_LABEL",plan,future,g_candidate.plannedEntry,tc,8,ANCHOR_LEFT_UPPER,
             StringFormat("Setup=%s | score=%.1f | entry=%s | invalidation=%s | risk=%s | space=%s | spaceRatio=%.2f",
                          SetupToString(g_candidate.setup),g_candidate.score,PriceToString(g_candidate.plannedEntry),
                          PriceToString(g_candidate.invalidation),PriceToString(g_candidate.riskDistance),
                          PriceToString(g_candidate.spaceDistance),g_candidate.spaceRatio));

   SetTextAt(PT_PREFIX+"PLAN_INV_TXT",
             StringFormat("INVALIDATION  %s  | R %.2f PA",PriceToString(g_candidate.invalidation),g_candidate.riskNorm),
             future,g_candidate.invalidation,clrOrangeRed,8,ANCHOR_LEFT_UPPER);
   if(g_candidate.nearestObstacle>0.0)
      SetTextAt(PT_PREFIX+"PLAN_OBS_TXT",
                StringFormat("OBSTACLE  %s  | SPACE %.2f PA",PriceToString(g_candidate.nearestObstacle),g_candidate.spaceRatio),
                future,g_candidate.nearestObstacle,clrGold,8,ANCHOR_LEFT_UPPER);
  }

void DrawTriggerMarkers()
  {
   if(!InpDrawTradeMarkers || !g_candidate.active)
     {
      DeleteDrawingPrefix(PT_PREFIX+"TRIGGER_");
      return;
     }
   if(g_candidate.eventTime<=0)
     {
      DeleteDrawingPrefix(PT_PREFIX+"TRIGGER_");
      return;
     }
   color c=(g_candidate.direction==PT_DIR_BUY?clrLimeGreen:clrTomato);
   SetVerticalMarker(PT_PREFIX+"TRIGGER_V",g_candidate.eventTime,c,STYLE_DASHDOTDOT);
   string txt=(g_candidate.setup==PT_SETUP_SWEEP_RECLAIM?"SWEEP + RECLAIM":
               g_candidate.setup==PT_SETUP_BREAK_RETEST?"BREAK + RETEST":"REJECTION + MICRO BREAK");
   SetTextAt(PT_PREFIX+"TRIGGER_TXT",txt,g_candidate.eventTime,
             g_candidate.direction==PT_DIR_BUY?g_candidate.triggerLow:g_candidate.triggerHigh,
             c,8,g_candidate.direction==PT_DIR_BUY?ANCHOR_LEFT_UPPER:ANCHOR_LEFT_LOWER,
             "Trigger chain: "+txt+" | eventId="+g_candidate.eventId);
  }

void DrawPositionLayer()
  {
   if(!InpDrawTradeMarkers || !SelectOurPosition())
     {
      DeleteDrawingPrefix(PT_PREFIX+"POS_");
      return;
     }

   long type=PositionGetInteger(POSITION_TYPE);
   int dir=(type==POSITION_TYPE_BUY?PT_DIR_BUY:PT_DIR_SELL);
   double sl=PositionGetDouble(POSITION_SL);
   double tp=PositionGetDouble(POSITION_TP);
   double current=(dir==PT_DIR_BUY?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   datetime now=TimeCurrent();
   if(now<=0) now=TimeTradeServer();
   datetime future=now+(datetime)(TFMinutes(g_workTF)*60*24);

   SetHLine(PT_PREFIX+"POS_ENTRY",g_entryPrice,clrWhite,STYLE_DOT,2);
   SetHLine(PT_PREFIX+"POS_INV",g_virtualInvalidation,clrOrangeRed,STYLE_DOT,1);
   if(sl>0.0) SetHLine(PT_PREFIX+"POS_SL",sl,clrOrange,STYLE_SOLID,2);
   else ObjectDelete(0,PT_PREFIX+"POS_SL");
   if(tp>0.0) SetHLine(PT_PREFIX+"POS_TP",tp,clrDeepSkyBlue,STYLE_DASH,1);
   else ObjectDelete(0,PT_PREFIX+"POS_TP");
   if(g_currentTrailStop>0.0) SetHLine(PT_PREFIX+"POS_TRAIL",g_currentTrailStop,clrGold,STYLE_SOLID,2);
   else ObjectDelete(0,PT_PREFIX+"POS_TRAIL");

   if(g_positionHighWaterPrice>0.0)
      SetHLine(PT_PREFIX+"POS_HWM",g_positionHighWaterPrice,clrMediumPurple,STYLE_DASHDOT,1);
   else ObjectDelete(0,PT_PREFIX+"POS_HWM");

   double lockPrice=g_currentTrailStop;
   double profit=g_currentProfit;
   string headline=(dir==PT_DIR_BUY?"LIVE BUY":"LIVE SELL");
   string info=StringFormat("%s | P/L %.2f | Max %.2f | Trail %s | HWM %s",
                            headline,profit,g_positionMaxProfit,
                            g_trailActive?"ACTIVE":"WAIT",
                            g_positionHighWaterPrice>0?PriceToString(g_positionHighWaterPrice):"-");
   SetTextAt(PT_PREFIX+"POS_INFO",info,future,current,dir==PT_DIR_BUY?clrLimeGreen:clrTomato,8,ANCHOR_LEFT_UPPER,
             StringFormat("Entry=%s | Current=%s | SL=%s | TP=%s | Trail=%s | HWM=%s | profit=%.2f",
                          PriceToString(g_entryPrice),PriceToString(current),PriceToString(sl),PriceToString(tp),
                          PriceToString(lockPrice),PriceToString(g_positionHighWaterPrice),profit));

   if(g_trailActive)
     SetTextAt(PT_PREFIX+"POS_TRAIL_TXT",
               StringFormat("TRAIL  %s  | dist $%.2f  | locked $%.2f",
                            PriceToString(g_currentTrailStop),g_currentTrailDistanceMoney,g_lockedProfit),
               future,g_currentTrailStop,clrGold,8,ANCHOR_LEFT_UPPER);
   else ObjectDelete(0,PT_PREFIX+"POS_TRAIL_TXT");
  }

void DrawLivePriceLabel()
  {
   if(!g_mapVisible)
     {
      ObjectDelete(0,PT_PREFIX+"LIVE_PRICE");
      return;
     }
   double price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(price<=0.0) return;
   datetime now=TimeCurrent();
   if(now<=0) now=TimeTradeServer();
   string txt=StringFormat("LIVE %s  |  %s  |  %s",
                           PriceToString(price),TFToString(g_workTF),StateToString(g_state));
   SetTextAt(PT_PREFIX+"LIVE_PRICE",txt,now,price,clrWhite,8,ANCHOR_RIGHT_UPPER,
             StringFormat("Bid=%s | TF=%s | state=%s | trend=%s | context=%s | defense=%s",
                          PriceToString(price),TFToString(g_workTF),StateToString(g_state),
                          TrendToString(g_trendState),ContextToString(g_context),DefenseToString(g_defense)));
  }

void UpdateDrawings()
  {
   if(!g_mapVisible)
     {
      DeleteDrawingPrefix(PT_PREFIX);
      return;
     }

   // Structure path and labels.
   if(InpDrawStructure) DrawMajorStructurePath();
   else DeleteDrawingPrefix(PT_PREFIX+"SW_");

   // Channel geometry.
   DrawTrendAndChannel();

   // Active zone.
   DrawZoneLayer();

   // BOS markers / structural events.
   DrawBreakMarkers();

   // Planned trade geometry.
   DrawCandidatePlan();
   DrawTriggerMarkers();

   // Position-management geometry is updated continuously by OnTimer.
   DrawPositionLayer();
   DrawLivePriceLabel();

   g_lastDrawingUpdate=TimeCurrent();
   if(g_lastDrawingUpdate<=0) g_lastDrawingUpdate=TimeTradeServer();
   ChartRedraw(0);
  }

//====================================================================
// PANEL ENGINE - HUD v3 / 2-LAYER CANVAS
// Visual baseline ported from the supplied AURELIS HUD block.
// PieceTrend semantics only; no AURELIS decision logic is used here.
//====================================================================
#define HUD_W        500
#define HUD_H_EXP    750
#define HUD_H_MIN    96
#define HUD_OBJ_BG   "PTP_HUD_BG"
#define HUD_OBJ_UI   "PTP_HUD_UI"
#define HUD_OBJ_DRAG "PTP_HUD_DRAG"
#define HUD_OBJ_MIN  "PTP_HUD_MIN"
#define HUD_OBJ_PAUSE "PTP_HUD_PAUSE"
#define HUD_OBJ_CLOSE "PTP_HUD_CLOSE"
#define HUD_OBJ_MAP  "PTP_HUD_MAP"
#define HUD_OBJ_DRAW "PTP_HUD_DRAW"

#define HC_BG1   C'4,7,16'
#define HC_BG2   C'11,18,40'
#define HC_CYAN  C'0,229,255'
#define HC_GREEN C'0,255,170'
#define HC_RED   C'255,61,113'
#define HC_AMBER C'255,176,32'
#define HC_TEXT  C'228,238,255'
#define HC_DIM   C'150,168,204'
#define HC_CARD  C'6,11,25'
#define HC_TRACK C'14,21,40'

#define HY_MKT   96
#define HH_MKT   92
#define HY_CTX   194
#define HH_CTX   100
#define HY_SET   300
#define HH_SET   120
#define HY_TRG   426
#define HH_TRG   72
#define HY_GAT   504
#define HH_GAT   60
#define HY_DAY   570
#define HH_DAY   112
#define HY_BTN   690

struct HudBtn
  {
   int x;
   int y;
   int w;
   int h;
  };

CCanvas g_hudBg;
CCanvas g_hudUi;
HudBtn  g_hudBtn[4];
bool    g_hudReady=false;
bool    g_hudDrag=false;
bool    g_hudDown=false;
bool    g_hudInside=false;
int     g_hudHover=-1;
int     g_hudDX=0;
int     g_hudDY=0;

uint HA(const color c,const int a=255)
  {
   int v=a;
   if(v<0) v=0;
   if(v>255) v=255;
   return ColorToARGB(c,(uchar)v);
  }

color HLerp(const color c1,const color c2,double t)
  {
   t=Clamp(t,0.0,1.0);
   int r1=(int)(c1&0xFF),g1=(int)((c1>>8)&0xFF),b1=(int)((c1>>16)&0xFF);
   int r2=(int)(c2&0xFF),g2=(int)((c2>>8)&0xFF),b2=(int)((c2>>16)&0xFF);
   int r=(int)MathRound(r1+(r2-r1)*t);
   int g=(int)MathRound(g1+(g2-g1)*t);
   int b=(int)MathRound(b1+(b2-b1)*t);
   return (color)((b<<16)|(g<<8)|r);
  }

void HT(CCanvas &cv,const int x,const int y,const int maxW,const string text,const color c,
        const int size,const bool bold=false,const int align=0)
  {
   string s=text;
   int sz=size;
   int minSz=MathMax(8,size-3);
   cv.FontSet(bold?"Segoe UI Semibold":"Segoe UI",sz,0,0);
   while(sz>minSz && cv.TextWidth(s)>maxW)
     {
      sz--;
      cv.FontSet(bold?"Segoe UI Semibold":"Segoe UI",sz,0,0);
     }
   if(cv.TextWidth(s)>maxW)
     {
      int n=StringLen(s);
      while(n>3 && cv.TextWidth(StringSubstr(s,0,n)+"..")>maxW) n--;
      s=StringSubstr(s,0,n)+"..";
     }
   uint flags=TA_LEFT|TA_VCENTER;
   int px=x;
   if(align==1)
     {
      flags=TA_CENTER|TA_VCENTER;
      px=x;
     }
   else if(align==2)
     {
      flags=TA_RIGHT|TA_VCENTER;
      px=x+maxW;
     }
   cv.TextOut(px,y,s,HA(c,255),flags);
  }

void HBrackets(CCanvas &cv,const int x,const int y,const int w,const int h,const int L,const color c,const int a)
  {
   uint u=HA(c,a);
   cv.Line(x,y,x+L,y,u);
   cv.Line(x,y,x,y+L,u);
   cv.Line(x+w-1,y,x+w-1-L,y,u);
   cv.Line(x+w-1,y,x+w-1,y+L,u);
   cv.Line(x,y+h-1,x+L,y+h-1,u);
   cv.Line(x,y+h-1,x,y+h-1-L,u);
   cv.Line(x+w-1,y+h-1,x+w-1-L,y+h-1,u);
   cv.Line(x+w-1,y+h-1,x+w-1,y+h-1-L,u);
  }


// ------------------------------------------------------------------
// PieceTrend canvas primitives
// ------------------------------------------------------------------
void PTLine(CCanvas &cv,const int x1,const int y1,const int x2,const int y2,const color c,const int width=1)
  {
   uint u=HA(c,255);
   int w=MathMax(1,width);
   for(int k=0;k<w;k++)
      cv.Line(x1,y1+k,x2,y2+k,u);
  }

void PTRoundRect(CCanvas &cv,const int x,const int y,const int w,const int h,const int r,
                 const uint fill_color,const uint border_color,const bool fill=true)
  {
   int rr=MathMax(0,MathMin(r,MathMin(w,h)/2));
   if(fill)
     {
      if(w>2*rr && h>2*rr)
        {
         cv.FillRectangle(x+rr,y,x+w-rr-1,y+h-1,fill_color);
         cv.FillRectangle(x,y+rr,x+w-1,y+h-rr-1,fill_color);
        }
      cv.FillCircle(x+rr,y+rr,rr,fill_color);
      cv.FillCircle(x+w-rr-1,y+rr,rr,fill_color);
      cv.FillCircle(x+rr,y+h-rr-1,rr,fill_color);
      cv.FillCircle(x+w-rr-1,y+h-rr-1,rr,fill_color);
     }

   if(border_color!=0)
     {
      cv.Line(x+rr,y,x+w-rr-1,y,border_color);
      cv.Line(x+rr,y+h-1,x+w-rr-1,y+h-1,border_color);
      cv.Line(x,y+rr,x,y+h-rr-1,border_color);
      cv.Line(x+w-1,y+rr,x+w-1,y+h-rr-1,border_color);
      // Pequenos segmentos internos deixam o contorno consistente sem depender
      // de metodos adicionais da biblioteca Canvas.
      int n=MathMax(1,rr);
      for(int i=0;i<n;i++)
        {
         cv.Line(x+rr-i,y+i,x+rr-i,y+i,border_color);
         cv.Line(x+w-1-rr+i,y+i,x+w-1-rr+i,y+i,border_color);
         cv.Line(x+rr-i,y+h-1-i,x+rr-i,y+h-1-i,border_color);
         cv.Line(x+w-1-rr+i,y+h-1-i,x+w-1-rr+i,y+h-1-i,border_color);
        }
     }
  }

void PTText(CCanvas &cv,const int x,const int y,const string text,const int size,const color c,
            const bool bold=false,const uint flags=(TA_LEFT|TA_VCENTER),const int maxW=0)
  {
   int sz=MathMax(8,size);
   cv.FontSet(bold?"Segoe UI Semibold":"Segoe UI",sz,0,0);
   string s=text;
   if(maxW>0 && cv.TextWidth(s)>maxW)
     {
      int n=StringLen(s);
      while(n>3 && cv.TextWidth(StringSubstr(s,0,n)+"..")>maxW) n--;
      s=StringSubstr(s,0,n)+"..";
     }
   cv.TextOut(x,y,s,HA(c,255),flags);
  }

void HCard(CCanvas &cv,const int y,const int h,const string title,const color accent=HC_CYAN)
  {
   const int x=12,w=HUD_W-24;
   cv.FillRectangle(x,y,x+w-1,y+h-1,HA(HC_CARD,220));
   cv.Rectangle(x,y,x+w-1,y+h-1,HA(accent,58));
   HBrackets(cv,x,y,w,h,8,accent,220);
   cv.FillRectangle(x+8,y+7,x+10,y+16,HA(accent,255));
   HT(cv,x+16,y+7,440,title,HC_DIM,11,true,0);
  }

void HBar(CCanvas &cv,const int x,const int y,const int w,const int h,const double frac,const color c,const double marker=-1.0)
  {
   cv.FillRectangle(x,y,x+w-1,y+h-1,HA(HC_TRACK,240));
   int fw=(int)MathRound(w*Clamp(frac,0.0,1.0));
   if(fw>0)
     {
      cv.FillRectangle(x,y,x+fw-1,y+h-1,HA(c,235));
      cv.FillRectangle(x,y,x+fw-1,y+MathMax(0,h/3-1),HA(clrWhite,45));
     }
   cv.Rectangle(x,y,x+w-1,y+h-1,HA(HC_CYAN,80));
   if(marker>=0.0)
     {
      int mx=x+(int)MathRound(w*Clamp(marker,0.0,1.0));
      cv.Line(mx,y-3,mx,y+h+2,HA(clrWhite,235));
     }
  }

void HLed(CCanvas &cv,const int x,const int y,const int r,const color c,const double pulse)
  {
   cv.FillCircle(x,y,r+4,HA(c,(int)(16+26*pulse)));
   cv.FillCircle(x,y,r+2,HA(c,(int)(45+55*pulse)));
   cv.FillCircle(x,y,r,HA(c,255));
  }

void HChip(CCanvas &cv,const int x,const int y,const int w,const int h,const string label,const bool on,const color c)
  {
   cv.FillRectangle(x,y,x+w-1,y+h-1,HA(on?c:HC_TRACK,on?42:200));
   cv.Rectangle(x,y,x+w-1,y+h-1,HA(on?c:HC_DIM,on?230:90));
   HT(cv,x+w/2,y+h/2-6,w,label,on?c:HC_DIM,10,true,1);
  }

void HudLayout()
  {
   g_hudBtn[0].x=HUD_W-46;
   g_hudBtn[0].y=14;
   g_hudBtn[0].w=32;
   g_hudBtn[0].h=28;
   int bw=115,gap=8,x=12;
   for(int i=1;i<=3;i++)
     {
      g_hudBtn[i].x=x;
      g_hudBtn[i].y=HY_BTN;
      g_hudBtn[i].w=bw;
      g_hudBtn[i].h=32;
      x+=bw+gap;
     }
  }

string HudBtnLabel(const int id)
  {
   if(id==0) return g_panelMinimized?"+":"-";
   if(id==1) return g_paused?"RESUME":"PAUSE";
   if(id==2) return "CLOSE ALL";
   return g_mapVisible?"MAP: ON":"MAP: OFF";
  }

void HudCreateHitObject(const string name)
  {
   if(ObjectFind(0,name)>=0) return;
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0)) return;
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,200);
  }

void HudPlaceHit(const string name,const int x,const int y,const int w,const int h)
  {
   HudCreateHitObject(name);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
  }

void HudPlaceControls()
  {
   HudPlaceHit(HUD_OBJ_DRAG,g_panelX+8,g_panelY+2,HUD_W-62,54);
   HudPlaceHit(HUD_OBJ_MIN,g_panelX+HUD_W-46,g_panelY+14,32,28);
   for(int i=1;i<=3;i++)
     {
      if(g_panelMinimized) ObjectDelete(0,PT_PANEL_PREFIX+(i==1?"HUD_PAUSE":(i==2?"HUD_CLOSE":"HUD_MAP")));
      else
        {
         string name=(i==1?HUD_OBJ_PAUSE:(i==2?HUD_OBJ_CLOSE:HUD_OBJ_MAP));
         HudPlaceHit(name,g_panelX+g_hudBtn[i].x,g_panelY+g_hudBtn[i].y,g_hudBtn[i].w,g_hudBtn[i].h);
        }
     }
  }

void HudDelete()
  {
   string names[]={HUD_OBJ_BG,HUD_OBJ_UI,HUD_OBJ_DRAG,HUD_OBJ_MIN,HUD_OBJ_PAUSE,HUD_OBJ_CLOSE,HUD_OBJ_MAP,HUD_OBJ_DRAW};
   for(int i=0;i<ArraySize(names);i++) ObjectDelete(0,names[i]);
   if(g_hudReady)
     {
      g_hudUi.Destroy();
      g_hudBg.Destroy();
      g_hudReady=false;
     }
   g_hudLastHeight=0;
   g_hudBgDirty=true;
   ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
  }

bool HudCreate()
  {
   if(g_hudReady) return true;
   HudLayout();
   int H=g_panelMinimized?HUD_H_MIN:HUD_H_EXP;
   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   g_panelX=(int)Clamp(g_panelX,0,MathMax(0,cw-HUD_W));
   g_panelY=(int)Clamp(g_panelY,0,MathMax(0,ch-H));
   if(!g_hudBg.CreateBitmapLabel(0,0,HUD_OBJ_BG,g_panelX,g_panelY,HUD_W,H,COLOR_FORMAT_ARGB_NORMALIZE)) return false;
   if(!g_hudUi.CreateBitmapLabel(0,0,HUD_OBJ_UI,g_panelX,g_panelY,HUD_W,H,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      g_hudBg.Destroy();
      return false;
     }
   ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_ZORDER,40);
   ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_ZORDER,50);
   g_hudReady=true;
   g_hudLastHeight=H;
   g_hudBgDirty=true;
   HudPlaceControls();
   return true;
  }

void HudResize()
  {
   if(!g_hudReady) return;
   int H=g_panelMinimized?HUD_H_MIN:HUD_H_EXP;
   if(H!=g_hudLastHeight)
     {
      g_hudBg.Resize(HUD_W,H);
      g_hudUi.Resize(HUD_W,H);
      g_hudLastHeight=H;
      g_hudBgDirty=true;
     }
   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   g_panelX=(int)Clamp(g_panelX,0,MathMax(0,cw-HUD_W));
   g_panelY=(int)Clamp(g_panelY,0,MathMax(0,ch-H));
   ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_XDISTANCE,g_panelX);
   ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_YDISTANCE,g_panelY);
   ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_XDISTANCE,g_panelX);
   ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_YDISTANCE,g_panelY);
  }

void HudDrawBg()
  {
   int H=g_panelMinimized?HUD_H_MIN:HUD_H_EXP;
   g_hudBg.Erase(0);
   for(int y=0;y<H;y++)
     {
      double t=(double)y/MathMax(1,H-1);
      g_hudBg.Line(0,y,HUD_W-1,y,HA(HLerp(HC_BG1,HC_BG2,t),236));
     }
   for(int x=0;x<HUD_W;x+=24) g_hudBg.Line(x,0,x,H-1,HA(HC_CYAN,8));
   for(int y=0;y<H;y+=24) g_hudBg.Line(0,y,HUD_W-1,y,HA(HC_CYAN,8));

   for(int k=0;k<3;k++)
     {
      int a=(k==0?255:(k==1?90:35));
      uint u=HA(HC_CYAN,a);
      g_hudBg.Line(14-k,k,HUD_W-1-k,k,u);
      g_hudBg.Line(HUD_W-1-k,k,HUD_W-1-k,H-15+k,u);
      g_hudBg.Line(k,14-k,k,H-1-k,u);
      g_hudBg.Line(k,H-1-k,HUD_W-15+k,H-1-k,u);
     }

   if(g_panelMinimized)
     {
      g_hudBg.FillRectangle(14,18,17,43,HA(HC_GREEN,255));
      g_hudBg.Line(14,H-22,HUD_W-14,H-22,HA(HC_CYAN,60));
      g_hudBg.Update(false);
      return;
     }

   g_hudBg.FillRectangle(14,58,124,59,HA(HC_GREEN,255));
   g_hudBg.Line(14,60,HUD_W-14,60,HA(HC_CYAN,60));
   HCard(g_hudBg,HY_MKT,HH_MKT,"MERCADO",C'96,112,128');
   HCard(g_hudBg,HY_CTX,HH_CTX,"TREND / STRUCTURE",C'95,137,171');
   HCard(g_hudBg,HY_SET,HH_SET,"CONTEXT / SETUP",C'190,146,68');
   HCard(g_hudBg,HY_TRG,HH_TRG,"TRIGGER",C'95,137,171');
   HCard(g_hudBg,HY_GAT,HH_GAT,"GATES / DEFENSE",C'178,147,70');
   HCard(g_hudBg,HY_DAY,HH_DAY,"PROFIT / DAILY",C'94,171,117');
   g_hudBg.FillRectangle(14,HUD_H_EXP-51,HUD_W-14,HUD_H_EXP-50,HA(HC_CYAN,70));
   g_hudBg.Update(false);
  }

void PanelDrawButton(CCanvas &cv,const int x,const int y,const int w,const int h,const string text,const bool active,const color accent)
  {
   color bg=active?C'48,43,31':C'33,37,44';
   PTRoundRect(cv,x,y,w,h,6,HA(bg),HA(active?accent:C'66,72,82'),true);
   HT(cv,x+w/2,y+5,w,text,active?accent:clrWhite,10,true,1);
  }

string PanelContextText()
  {
   if(g_context==PT_CTX_NO_TREND) return "WAIT STRUCTURE";
   if(g_context==PT_CTX_DEFENSIVE) return "DEFENSIVE";
   return ContextToString(g_context);
  }

string PanelSetupText()
  {
   if(g_candidate.active) return SetupToString(g_candidate.setup);
   if(g_trendState==PT_TREND_BUY || g_trendState==PT_TREND_SELL) return "WAITING SETUP";
   return "WAITING TREND";
  }

string PanelZoneText()
  {
   if(!g_zone.active) return "NOT BUILT";
   if(g_candidate.direction==PT_DIR_SELL) return "RESISTANCE";
   if(g_candidate.direction==PT_DIR_BUY) return "SUPPORT";
   if(g_direction==PT_DIR_SELL) return "RESISTANCE";
   return "SUPPORT";
  }

string PanelTriggerText()
  {
   if(g_candidate.active) return (g_state==PT_STATE_SETUP_ARMED?"ARMED":"WAIT");
   if(g_trendState==PT_TREND_BUY || g_trendState==PT_TREND_SELL) return "WAIT";
   return "BLOCKED";
  }

void HudDrawUi()
  {
   int H=g_panelMinimized?HUD_H_MIN:HUD_H_EXP;
   g_hudUi.Erase(0);
   double pulse=0.0;
   const color acc=HC_GREEN;
   const color warn=HC_AMBER;
   const color bad=HC_RED;
   const color cy=HC_CYAN;
   const color txt=HC_TEXT;
   const color dim=HC_DIM;

   if(g_panelMinimized)
     {
      PTLine(g_hudUi,14,57,HUD_W-14,57,HC_CYAN,1);
      HT(g_hudUi,34,30,240,"PIECETREND",HC_TEXT,15,true,0);
      HT(g_hudUi,154,30,250,TFToString(g_workTF)+"  |  "+_Symbol,HC_DIM,10,false,0);
      // FIX v1.01: ordem dos argumentos de HT era (..., "+", 18, HC_AMBER, ...) => cor/tamanho trocados
      HT(g_hudUi,HUD_W-52,29,28,"+",HC_AMBER,18,true,1);
      g_hudUi.Update(false);
      return;
     }

   // Header / chrome
   PTLine(g_hudUi,30,12,40,18,acc,1);
   PTLine(g_hudUi,40,18,40,30,acc,1);
   PTLine(g_hudUi,40,30,30,36,acc,1);
   g_hudUi.FillCircle(30,24,3,HA(cy,255));
   HT(g_hudUi,52,8,250,"PIECETREND",txt,23,true,0);
   HT(g_hudUi,52,36,390,"PRICE ACTION TREND ENGINE",dim,10,false,0);
   HT(g_hudUi,320,12,150,"ENGINE "+TFToString(g_workTF),HC_AMBER,10,true,0);
   HT(g_hudUi,320,32,140,_Symbol+"  |  AUTO",dim,9,false,0);
   // FIX v1.01: idem acima (texto "-" do botao minimizar)
   HT(g_hudUi,404,20,34,"-",HC_AMBER,16,true,1);

   color stateColor=dim;
   string status="SCANNING";
   if(g_paused) { stateColor=warn; status="PAUSED"; }
   else if(OurPositionCount()>0) { stateColor=cy; status="POSITION MANAGING"; }
   else if(g_state==PT_STATE_DEFENSIVE_LOCK || g_defense==PT_DEF_HARD) { stateColor=bad; status="DEFENSIVE LOCK"; }
   else if(g_candidate.active) { stateColor=acc; status="SETUP ARMED"; }
   else if(g_trendState==PT_TREND_BUY || g_trendState==PT_TREND_SELL) { stateColor=warn; status="TREND READY"; }
   else if(g_trendState==PT_TREND_NONE) { stateColor=warn; status="WAITING STRUCTURE"; }
   if(!g_tfValid) { stateColor=bad; status="INVALID CHART TF"; }
   PTText(g_hudUi,28,77,"●",12,stateColor,true,TA_LEFT|TA_VCENTER);
   HT(g_hudUi,48,69,430,status,stateColor,14,true,0);
   HT(g_hudUi,48,90,420,"CHART "+TFToString((ENUM_TIMEFRAMES)_Period)+" = ENGINE "+TFToString(g_workTF)+"   |   MAGIC "+StringFormat("%I64d",g_magic),dim,8,false,0);

   // Market
   int y=HY_MKT;
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double spread=MathMax(0.0,ask-bid);
   double spreadPts=spread/_Point;
   double spreadMoney=0.0;
   double volGuess=(g_positionVolume>0.0?g_positionVolume:(g_plannedVolume>0.0?g_plannedVolume:SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)));
   if(volGuess>0.0) spreadMoney=MoneyForPriceDistance(g_direction==PT_DIR_SELL?PT_DIR_SELL:PT_DIR_BUY,volGuess,g_direction==PT_DIR_SELL?bid:ask,spread);
   HT(g_hudUi,24,y+22,120,"BID",dim,10,true,0);
   HT(g_hudUi,24,y+46,120,PriceToString(bid),txt,18,true,0);
   HT(g_hudUi,164,y+22,120,"ASK",dim,10,true,0);
   HT(g_hudUi,164,y+46,120,PriceToString(ask),txt,18,true,0);
   color spc=(g_paScale>0.0 && spread/g_paScale>0.15)?bad:(g_paScale>0.0 && spread/g_paScale>0.10?warn:acc);
   HT(g_hudUi,304,y+20,172,"SPREAD "+DoubleToString(spreadPts,1)+" pt",spc,11,true,0);
   double spreadFrac=(InpMaxSpreadPoints>0.0?spreadPts/InpMaxSpreadPoints:0.0);
   HBar(g_hudUi,304,y+46,172,10,Clamp(spreadFrac,0.0,1.0),spc,1.0);
   HT(g_hudUi,304,y+63,172,"MAX "+DoubleToString(InpMaxSpreadPoints,1)+" pt  |  SP $"+DoubleToString(spreadMoney,2),dim,9,false,0);
   HT(g_hudUi,24,y+75,452,"MICRO "+PriceToString(g_microScale)+"   RANGE "+DoubleToString(g_rangeRatio,2)+"   BARS "+IntegerToString(g_loadedBars)+"   LIVE "+TimeToString(TimeCurrent(),TIME_SECONDS),dim,8,false,0);

   // Trend / Structure
   y=HY_CTX;
   color tc=g_direction==PT_DIR_BUY?acc:(g_direction==PT_DIR_SELL?bad:warn);
   HT(g_hudUi,24,y+21,140,"TREND",dim,10,true,0);
   HT(g_hudUi,24,y+46,140,TrendToString(g_trendState),tc,18,true,0);
   HT(g_hudUi,182,y+21,72,"SCORE",dim,10,true,0);
   HT(g_hudUi,182,y+46,90,DoubleToString(g_trendScore,1),tc,18,true,0);
   HBar(g_hudUi,282,y+49,188,8,g_trendScore/100.0,tc,0.55);
   HT(g_hudUi,282,y+68,188,"Structure "+DoubleToString(g_structureScore,1)+"  |  Cont "+DoubleToString(g_continuationScore,1),dim,9,false,0);
   HT(g_hudUi,24,y+82,446,"HH "+PriceToString(g_majorHighCount>=1?g_majorHighs[0].price:0.0)+"   HL "+PriceToString(g_majorLowCount>=1?g_majorLows[0].price:0.0)+"   ANALYSIS "+(g_lastAnalysisBar>0?TimeToString(g_lastAnalysisBar,TIME_MINUTES):"-")+"   SW "+IntegerToString(g_majorHighCount)+"H/"+IntegerToString(g_majorLowCount)+"L",dim,8,false,0);

   // Context / Setup
   y=HY_SET;
   color setupColor=g_candidate.active?(g_candidate.direction==PT_DIR_BUY?acc:bad):dim;
   HT(g_hudUi,24,y+22,150,"CONTEXT",dim,10,true,0);
   HT(g_hudUi,24,y+48,180,PanelContextText(),setupColor,15,true,0);
   HT(g_hudUi,258,y+22,120,"SETUP",dim,10,true,0);
   HT(g_hudUi,258,y+48,210,PanelSetupText(),setupColor,13,true,0);
   HT(g_hudUi,24,y+74,90,"ZONE",dim,9,true,0);
   HT(g_hudUi,80,y+74,160,PanelZoneText(),g_zone.active?HC_AMBER:dim,10,true,0);
   HT(g_hudUi,258,y+74,70,"SCORE",dim,9,true,0);
   HT(g_hudUi,308,y+74,160,g_candidate.active?DoubleToString(g_candidate.score,1):"--",g_candidate.active?HC_AMBER:dim,12,true,0);
   HT(g_hudUi,24,y+96,120,"ENTRY PLAN",dim,9,true,0);
   HT(g_hudUi,116,y+96,160,PriceToString(g_candidate.plannedEntry),txt,11,true,0);
   HT(g_hudUi,258,y+96,100,"TRIGGER",dim,9,true,0);
   HT(g_hudUi,322,y+96,146,PanelTriggerText(),g_candidate.active?acc:dim,11,true,0);
   double panelVol=InpUseFixedLot?NormalizeVolume(InpFixedLot):g_plannedVolume;
   double panelRisk=(g_candidate.active && panelVol>0.0)?MoneyForPriceDistance(g_candidate.direction,panelVol,g_candidate.plannedEntry,g_candidate.riskDistance):0.0;
   string volMode=InpUseFixedLot?("LOT FIXED "+DoubleToString(InpFixedLot,2)):("LOT RISK $"+DoubleToString(InpRiskMoneyPerTrade,2));
   HT(g_hudUi,24,y+114,444,volMode+"  |  INV "+PriceToString(g_candidate.invalidation)+"  |  RISK $"+DoubleToString(panelRisk,2),dim,8,false,0);

   // Trigger chain
   y=HY_TRG;
   bool setupActive=g_candidate.active;
   bool triggerReady=setupActive && g_state>=PT_STATE_TRIGGER_WAIT;
   bool structReady=(g_majorHighCount>=2 && g_majorLowCount>=2);
   bool riskReady=(g_candidate.riskDistance>0.0 && g_candidate.riskNorm<=PT_MAX_RISK_NORM);
   string ev1=setupActive?(SetupToString(g_candidate.setup)):"SETUP";
   HChip(g_hudUi,24,y+28,135,34,ev1,setupActive,cy);
   HChip(g_hudUi,169,y+28,100,34,"REACTION",setupActive,cy);
   HChip(g_hudUi,279,y+28,100,34,"STRUCTURE",structReady,cy);
   HChip(g_hudUi,389,y+28,88,34,"TRIGGER",triggerReady,cy);
   HT(g_hudUi,24,y+8,220,"SETUP CHAIN",dim,10,true,0);
   HT(g_hudUi,476,y+8,200,triggerReady?"CONFIRMED":"WAITING",triggerReady?acc:dim,10,true,2);

   // Gates / defense
   y=HY_GAT;
   double riskRatio=(g_candidate.riskDistance>0.0?g_candidate.riskNorm:0.0);
   bool gateTrend=(g_trendState==PT_TREND_BUY || g_trendState==PT_TREND_SELL);
   bool gateStruct=(g_majorHighCount>=1 && g_majorLowCount>=1);
   bool gateSetup=g_candidate.active;
   bool gateRisk=(riskReady && g_candidate.spaceRatio>=PT_MIN_SPACE_RATIO);
   bool gateSpread=(!InpSpreadFilterEnable || InpMaxSpreadPoints<=0.0 || spreadPts<=InpMaxSpreadPoints);
   bool gateDaily=!DailyEntryBlockedCode();
   bool gateDefense=(g_defense<PT_DEF_HARD && !(g_defense==PT_DEF_DEFENSIVE && g_candidate.score<65.0));
   bool gateExec=(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)!=0 && MQLInfoInteger(MQL_TRADE_ALLOWED)!=0 && AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)!=0 && AccountInfoInteger(ACCOUNT_TRADE_EXPERT)!=0 && !g_paused);
   string labels[8]={"TR","ST","SU","RK","SPR","DAY","DEF","EX"};
   bool vals[8]={gateTrend,gateStruct,gateSetup,gateRisk,gateSpread,gateDaily,gateDefense,gateExec};
   for(int i=0;i<8;i++)
     {
      int gx=24+i*57;
      color gc=vals[i]?acc:bad;
      g_hudUi.FillCircle(gx+4,y+31,3,HA(gc,255));
      HT(g_hudUi,gx+13,y+22,42,labels[i],vals[i]?txt:gc,9,true,0);
     }
   HT(g_hudUi,24,y+43,450,"DEF "+DefenseToString(g_defense)+"  |  EFF "+DoubleToString(g_pathEfficiency,2)+"  |  WHIP "+DoubleToString(g_whipsawIndex,2)+"  |  LOSSES "+IntegerToString(g_consecutiveLosses),dim,9,false,0);

   // Profit / Daily
   y=HY_DAY;
   double daily=DailyNet();
   color pc=(g_currentProfit>=0.0?acc:bad);
   HT(g_hudUi,24,y+20,130,"FLOAT",dim,9,true,0);
   HT(g_hudUi,24,y+45,160,MoneyToString(g_currentProfit),pc,18,true,0);
   HT(g_hudUi,192,y+20,110,"MAX",dim,9,true,0);
   HT(g_hudUi,192,y+45,150,MoneyToString(g_positionMaxProfit),txt,14,true,0);
   HT(g_hudUi,350,y+20,120,"TRAIL",dim,9,true,0);
   HT(g_hudUi,350,y+45,120,g_trailActive?"ACTIVE":"WAIT",g_trailActive?warn:dim,12,true,0);
   HT(g_hudUi,24,y+72,90,"DIST",dim,9,true,0);
   HT(g_hudUi,80,y+72,120,MoneyToString(g_currentTrailDistanceMoney),txt,10,true,0);
   HT(g_hudUi,192,y+72,90,"LOCK",dim,9,true,0);
   HT(g_hudUi,246,y+72,110,MoneyToString(g_lockedProfit),acc,10,true,0);
   HT(g_hudUi,350,y+72,90,"TP",dim,9,true,0);
   string tpText=(g_positionTP>0.0?PriceToString(g_positionTP):(InpTPEnable?"ARM":"OFF"));
   HT(g_hudUi,390,y+72,80,tpText,HC_AMBER,10,true,0);

   double tgt=InpDailyTargetMoney;
   double targetFrac=(tgt>0.0?daily/tgt:0.0);
   HT(g_hudUi,24,y+94,100,"TODAY",dim,9,true,0);
   HT(g_hudUi,86,y+94,160,MoneyToString(daily),daily>=0.0?acc:bad,11,true,0);
   string targetText=InpDailyTargetEnable?("TARGET "+MoneyToString(tgt)):"TARGET OFF";
   HT(g_hudUi,250,y+94,220,targetText,InpDailyTargetEnable?(targetFrac>=1.0?acc:txt):dim,10,true,0);

   // Buttons
   int by=HY_BTN;
   PanelDrawButton(g_hudUi,g_hudBtn[1].x,by,g_hudBtn[1].w,g_hudBtn[1].h,HudBtnLabel(1),g_paused,g_paused?C'96,171,117':C'207,165,74');
   PanelDrawButton(g_hudUi,g_hudBtn[2].x,by,g_hudBtn[2].w,g_hudBtn[2].h,HudBtnLabel(2),false,C'182,87,76');
   PanelDrawButton(g_hudUi,g_hudBtn[3].x,by,g_hudBtn[3].w,g_hudBtn[3].h,HudBtnLabel(3),g_mapVisible,C'95,137,171');
   PanelDrawButton(g_hudUi,g_hudBtn[0].x,14,g_hudBtn[0].w,g_hudBtn[0].h,HudBtnLabel(0),false,HC_AMBER);

   HLed(g_hudUi,20,HUD_H_EXP-14,3,InpWriteCSV?acc:warn,pulse);
   HT(g_hudUi,32,HUD_H_EXP-22,450,"CSV "+(InpWriteCSV?"ON":"OFF")+"  |  CORE + PA + TRADES + DAILY + ERRORS",dim,8,false,0);
   g_hudUi.Update(false);
  }

bool DailyEntryBlockedCode()
  {
   if(InpDailyTargetEnable && InpDailyTargetMoney>0.0 && DailyNet()>=InpDailyTargetMoney) return true;
   if(InpDailyLossLimitEnable && InpDailyLossLimitMoney>0.0 && DailyNet()<=-InpDailyLossLimitMoney) return true;
   return false;
  }

void HudAction(const int id)
  {
   if(id==0)
     {
      g_panelMinimized=!g_panelMinimized;
      g_hudBgDirty=true;
      HudResize();
      HudPlaceControls();
      return;
     }
   if(id==1)
     {
      g_paused=!g_paused;
      g_state=g_paused?PT_STATE_PAUSED:PT_STATE_SCANNING;
      WriteCoreEvent(g_paused?"MANUAL_PAUSE":"MANUAL_RESUME","","User panel action",g_paused?"PAUSE":"RESUME");
      return;
     }
   if(id==2)
     {
      CloseOurPosition("MANUAL_CLOSE");
      return;
     }
   if(id==3)
     {
      g_mapVisible=!g_mapVisible;
      if(!g_mapVisible) DeleteDrawingPrefix(PT_PREFIX);
      else UpdateDrawings();
      WriteCoreEvent("MAP_TOGGLE","","User panel action",g_mapVisible?"MAP_ON":"MAP_OFF");
      return;
     }
  }

int HudHit(const int x,const int y)
  {
   if(x>=g_hudBtn[0].x && x<=g_hudBtn[0].x+g_hudBtn[0].w && y>=g_hudBtn[0].y && y<=g_hudBtn[0].y+g_hudBtn[0].h) return 0;
   if(g_panelMinimized) return -1;
   for(int i=1;i<=3;i++)
     if(x>=g_hudBtn[i].x && x<=g_hudBtn[i].x+g_hudBtn[i].w && y>=g_hudBtn[i].y && y<=g_hudBtn[i].y+g_hudBtn[i].h) return i;
   return -1;
  }

void HudMouse(const int mx,const int my,const uint flags)
  {
   if(!g_hudReady) return;
   int H=g_panelMinimized?HUD_H_MIN:HUD_H_EXP;
   int cx=mx-g_panelX;
   int cy=my-g_panelY;
   bool inside=(cx>=0 && cx<HUD_W && cy>=0 && cy<H);
   bool down=((flags&1)!=0);
   if(inside!=g_hudInside)
     {
      g_hudInside=inside;
      ChartSetInteger(0,CHART_MOUSE_SCROLL,!inside);
     }
   int hover=inside?HudHit(cx,cy):-1;
   if(hover!=g_hudHover)
     {
      g_hudHover=hover;
      HudDrawUi();
     }
   if(down && !g_hudDown)
     {
      if(hover>=0)
        {
         HudAction(hover);
         HudDrawBg();
         HudDrawUi();
        }
      else if(inside && cy<60)
        {
         g_hudDrag=true;
         g_hudDX=cx;
         g_hudDY=cy;
        }
     }
   if(g_hudDrag && down)
     {
      int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      int Hc=g_panelMinimized?HUD_H_MIN:HUD_H_EXP;
      g_panelX=(int)Clamp(mx-g_hudDX,0,MathMax(0,cw-HUD_W));
      g_panelY=(int)Clamp(my-g_hudDY,0,MathMax(0,ch-Hc));
      ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_XDISTANCE,g_panelX);
      ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_YDISTANCE,g_panelY);
      ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_XDISTANCE,g_panelX);
      ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_YDISTANCE,g_panelY);
      HudPlaceControls();
      ChartRedraw(0);
     }
   if(!down) g_hudDrag=false;
   g_hudDown=down;
  }

void UpdatePanel()
  {
   if(!InpShowPanel)
     {
      HudDelete();
      return;
     }
   if(!HudCreate()) return;
   HudResize();
   if(g_hudBgDirty)
     {
      HudDrawBg();
      g_hudBgDirty=false;
     }
   HudDrawUi();
   ChartRedraw(0);
  }

//====================================================================
// EVENTS
//====================================================================
int OnInit()
  {
   if(!ResolveWorkTimeframe())
     {
      Print("PieceTrend: anexe o EA somente em M1, M5 ou M15. O timeframe e reconhecido automaticamente pelo grafico.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpInstanceID<0) return INIT_PARAMETERS_INCORRECT;
   if(InpUseFixedLot && InpFixedLot<=0.0) return INIT_PARAMETERS_INCORRECT;
   if(!InpUseFixedLot && InpRiskEnable && InpRiskMoneyPerTrade<=0.0) return INIT_PARAMETERS_INCORRECT;
   if(InpSpreadFilterEnable && InpMaxSpreadPoints<=0.0) return INIT_PARAMETERS_INCORRECT;
   if(InpTrailEnable && InpTrailActivationMoney<=0.0) return INIT_PARAMETERS_INCORRECT;
   g_magic=CalculateMagic();
   g_panelX=InpPanelX; g_panelY=InpPanelY;
   g_panelMinimized=InpPanelStartMinimized;
   g_mapVisible=InpDrawStructure||InpDrawZones||InpDrawChannel||InpDrawTradeMarkers;
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   g_labelsVisible=InpDrawLabels;
   g_dayStart=StartOfServerDay(TimeCurrent());
   g_state=PT_STATE_SCANNING;
   g_trade.SetExpertMagicNumber(g_magic);
   g_trade.SetAsyncMode(false);
   HudLayout();
   InitCsvFiles();
   AnalyzeNewBar();
   g_lastBarTime=iTime(_Symbol,g_workTF,0);
   RefreshDailyNet(true);
   WriteCoreEvent("INIT","","PieceTrend initialized | TF=AUTO/"+TFToString(g_workTF)+" | Magic="+IntegerToString((int)g_magic),"INIT");
   UpdatePanel();
   EventSetMillisecondTimer(250);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   WriteDailySnapshot();
   WriteCoreEvent("DEINIT","","PieceTrend shutdown","DEINIT");
   EventKillTimer();
   HudDelete();
   DeleteDrawingPrefix(PT_PREFIX);
  }

void OnTick()
  {
   if((ENUM_TIMEFRAMES)_Period!=g_workTF)
     {
      if(!ResolveWorkTimeframe()) return;
      g_lastBarTime=0;
      g_state=PT_STATE_SCANNING;
     }
   datetime currentBar=iTime(_Symbol,g_workTF,0);
   if(currentBar>0 && currentBar!=g_lastBarTime)
     {
      g_lastBarTime=currentBar;
      if(StartOfServerDay(TimeCurrent())!=g_dayStart)
        {
         WriteDailySnapshot();
         g_dayStart=StartOfServerDay(TimeCurrent());
         g_consecutiveLosses=0;
         g_consecutiveWins=0;
         g_dailyTrailActivated=0; g_dailyTrailClosedProfit=0.0; g_dailyTpClosedProfit=0.0; g_dailySlClosedProfit=0.0; g_dailyEmergencyClosedProfit=0.0; g_dailyDefensiveEvents=0; g_dailyCooldownEvents=0;
         RefreshDailyNet(true);
        }
      AnalyzeNewBar();
     }
   ManagePosition();
   if(g_candidate.active && OurPositionCount()==0) ExecuteCandidate();
  }

void OnTimer()
  {
   if((ENUM_TIMEFRAMES)_Period!=g_workTF)
      ResolveWorkTimeframe();
   RefreshDailyNet(false);
   if(StartOfServerDay(TimeCurrent())!=g_dayStart)
     {
      WriteDailySnapshot();
      g_dayStart=StartOfServerDay(TimeCurrent());
      g_dailyTrailActivated=0; g_dailyTrailClosedProfit=0.0; g_dailyTpClosedProfit=0.0; g_dailySlClosedProfit=0.0; g_dailyEmergencyClosedProfit=0.0; g_dailyDefensiveEvents=0; g_dailyCooldownEvents=0;
      RefreshDailyNet(true);
     }
   ManagePosition();
   datetime now=TimeCurrent();
   if(now<=0) now=TimeTradeServer();
   if(InpWriteHeartbeat && (g_lastHeartbeatTime==0 || (now-g_lastHeartbeatTime)>=MathMax(1,InpHeartbeatSeconds)))
     {
      g_lastHeartbeatTime=now;
      WriteCoreEvent("CORE_HEARTBEAT","","timer heartbeat","HEARTBEAT");
     }
   if(g_lastDrawingUpdate==0 || (now-g_lastDrawingUpdate)>=1)
     {
      g_lastDrawingUpdate=now;
      UpdateDrawings();
     }
   UpdatePanel();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      HudMouse((int)lparam,(int)dparam,(uint)StringToInteger(sparam));
      return;
     }
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      UpdatePanel();
      return;
     }
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD) return;
   if(trans.deal==0) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if((long)HistoryDealGetInteger(trans.deal,DEAL_MAGIC)!=g_magic) return;
   if(HistoryDealGetString(trans.deal,DEAL_SYMBOL)!=_Symbol) return;
   long entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
   double net=HistoryDealGetDouble(trans.deal,DEAL_PROFIT)+HistoryDealGetDouble(trans.deal,DEAL_COMMISSION)+HistoryDealGetDouble(trans.deal,DEAL_SWAP)+HistoryDealGetDouble(trans.deal,DEAL_FEE);
   if(entry==DEAL_ENTRY_IN || entry==DEAL_ENTRY_INOUT)
     {
      g_lastProcessedDeal=(long)trans.deal;
      StorePositionContext();
      WriteTradeEvent("ORDER_FILLED","");
     }
   if(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY)
     {
      g_lastProcessedDeal=(long)trans.deal;
      if(net>0.0) { g_consecutiveWins++; g_consecutiveLosses=0; }
      else if(net<0.0) { g_consecutiveLosses++; g_consecutiveWins=0; }
      long dealReason=HistoryDealGetInteger(trans.deal,DEAL_REASON);
      string finalExitReason=g_pendingExitReason;
      if(finalExitReason=="")
        {
         if(dealReason==DEAL_REASON_TP) finalExitReason="TP";
         else if(dealReason==DEAL_REASON_SL) finalExitReason=(g_trailActive?"TRAIL":"SL");
         else if(g_trailActive) finalExitReason="TRAIL";
         else finalExitReason=(net>0.0?"PROFIT_EXIT":(net<0.0?"LOSS_EXIT":"BREAKEVEN_EXIT"));
        }
      if(finalExitReason=="TRAIL") g_dailyTrailClosedProfit+=net;
      if(finalExitReason=="TP") g_dailyTpClosedProfit+=net;
      if(finalExitReason=="SL") g_dailySlClosedProfit+=net;
      if(finalExitReason=="EMERGENCY_LOSS") g_dailyEmergencyClosedProfit+=net;
      if(g_consecutiveLosses>=PT_LOSS_COOLDOWN)
        {
         datetime b=iTime(_Symbol,g_workTF,0);
         g_cooldownUntilBar=b+PT_COOLDOWN_MIN_BARS*TFMinutes(g_workTF)*60;
         g_dailyCooldownEvents++;
         WriteCoreEvent("COOLDOWN_ON","COOLDOWN",StringFormat("ConsecutiveLosses=%d",g_consecutiveLosses),"LOCK_ENTRIES");
        }
      else if(g_consecutiveLosses>=PT_LOSS_CAUTION)
        {
         g_dailyDefensiveEvents++;
         WriteCoreEvent("DEFENSE_ON","COOLDOWN",StringFormat("ConsecutiveLosses=%d",g_consecutiveLosses),"CAUTION");
        }
      WriteTradeEvent("POSITION_CLOSED",finalExitReason);
      g_pendingExitReason="";
      g_positionTicket=0; g_positionId=0; g_currentProfit=0; g_positionVolume=0; g_positionMaxProfit=0; g_positionHighWaterPrice=0; g_trailActive=false; g_currentTrailStop=0; g_positionTP=0; g_lockedProfit=0;
     }
   RefreshDailyNet(true);
   UpdatePanel();
  }

//+------------------------------------------------------------------+