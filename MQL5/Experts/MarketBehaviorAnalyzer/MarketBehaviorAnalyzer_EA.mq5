//+------------------------------------------------------------------+
//| MarketBehaviorAnalyzer_EA.mq5                                    |
//| Multi-timeframe live market research collector (non-trading)     |
//|                                                                  |
//| v1.23 - integrity release (see docs/MBA.md):                     |
//|  * A bar is only marked as processed after its candle row is     |
//|    written; failures are retried and, after InpMaxBarRetries,    |
//|    logged as CRITICAL:BarSkipped (v1.22 skipped silently).       |
//|  * RAW_TICKS captured with CopyTicksRange + persistent cursor    |
//|    (OnTick alone loses ticks) and back-filled on first run.      |
//|  * Historical UTC uses the NY-close DST rule (v1.22 used the     |
//|    current offset for all history = 1 h wrong in winter).        |
//|  * MAE/MFE are positive distances; max_up/max_down added.        |
//|  * Time-based forward (1..240 min) from M1 bars: FORWARD_TIME.   |
//|  * D1 timeframe, bar spread, OHLC-vs-ticks audit per candle.     |
//|  * META/data_quality snapshots (expected vs written, gaps...).   |
//| v1.22 - history depth counted in days, not bars (1.22); per-timeframe history depth (1.21), maximum-history back-fill (1.20), research-pipeline fixes (1.11: calendar history back-fill, news de-dup key; 1.12: resume no longer rewrites bars when the terminal series is stale at start)                                  |
//|  * One row per (event, horizon): FORWARD is written exactly once,|
//|    when the horizon bar closes (v1.00 rewrote it every second).  |
//|  * One tick-aggregate row per bar (v1.00 wrote M1 twice).        |
//|  * Deterministic keys: event_key / forward_key.                  |
//|  * Restart/gap safe: resumes from the last stored bar and        |
//|    back-fills missing bars from server history (no duplicates).  |
//|  * Context is KNOWN_BEFORE_EVENT (closed bars before event open);|
//|    the event bar itself is described separately.                 |
//|  * Real UTC per row (server offset), broker/server in every row. |
//|  * Calendar with importance/currency/names, de-duplicated.       |
//|  * New levels: prev-day H/L, session H/L, swing H/L (ATR units). |
//|  * Symbol/broker specification snapshot per run (META).          |
//|  * DOM throttled and OFF by default (feed volume is saturated).  |
//+------------------------------------------------------------------+
#property strict
#property version   "1.23"
#property description "Non-trading multi-timeframe market behavior research collector."

#include "MBA_Core.mqh"

enum MBA_DST_INPUT
  {
   MBA_DSTIN_AUTO=0,           // AUTO (NY-close rule when the broker follows it)
   MBA_DSTIN_US_NY_CLOSE=1,    // NY-close server: UTC+2 winter / UTC+3 US daylight saving
   MBA_DSTIN_FIXED_CURRENT=2,  // current offset for all history (v1.22 behaviour)
   MBA_DSTIN_FIXED_INPUT=3     // InpAnalysisTimezoneOffset
  };

input string InpRootFolder             = "MarketBehaviorAnalyzer";
input bool   InpUseCommonFolder        = true;
input int    InpAnalysisTimezoneOffset = -3;          // fallback only: server->UTC hours when InpUseDynamicUTC=false
input int    InpPartSizeMB             = 25;
input bool   InpWriteRawTicks          = true;        // RAW_TICKS via CopyTicksRange (complete), see InpRawTickBackfillDays
input bool   InpWriteTickAggregates    = true;
input bool   InpWriteEvents            = true;
input bool   InpWriteForward           = true;
input int    InpForwardMaxBars         = 10;          // max 10
input int    InpATRPeriod               = 14;
input int    InpFeatureLookback         = 20;         // max 40
input int    InpFlushEveryRows          = 100;
input bool   InpWriteDOM                = false;      // broker DOM volume was saturated (constant total); keep off unless verified
input bool   InpWriteNewsContext        = true;
// ---- v1.10
input bool   InpUseDynamicUTC           = true;       // analysis_time = real UTC from server offset
input MBA_DST_INPUT InpDstMode          = MBA_DSTIN_AUTO; // v1.23: how history is converted to UTC
input bool   InpBrokerFolder            = true;       // root\<broker>\<symbol>\LIVE (avoids two terminals mixing the same symbol)
input int    InpMaxCatchupBars          = 200000;     // (unused since v1.23.1 - it used to skip history, see CatchUpOne)
input int    InpInitialBackfillDays     = 30;         // first run on this broker/symbol (no CSV yet): build this many days of history from the server; 0 = off
input int    InpBackfillBudgetMs        = 700;        // max milliseconds per timer tick spent back-filling (keeps the chart responsive)
input bool   InpBackfillMaxHistory      = true;       // first run: go back as far as the terminal/server allow (ignores InpInitialBackfillDays)
input int    InpBackfillMaxDays         = 3650;       // upper bound for the maximum-history mode
input int    InpDaysM1                  = 1000;       // maximum-history mode: how far back per timeframe (days). 1000 d ~ Jan/2024 (needs Max bars in chart >= ~1.000.000)
input int    InpDaysM5                  = 520;        // ~ mid 2025
input int    InpDaysM15                 = 1000;
input int    InpDaysM30                 = 1000;
input int    InpDaysH1                  = 2000;
input int    InpDaysH4                  = 3650;
input int    InpDaysD1                  = 3650;
input int    InpDaysW1                  = 3650;
input int    InpDaysMN1                 = 3650;
input int    InpBackfillSyncWaitSec     = 120;        // max seconds to wait per timeframe for the terminal to download history
input int    InpTickHistoryDays         = 120;        // ticks (tick count/spread) are rebuilt only for bars newer than this; older bars get tick_data_ok=FALSE (0 = always try)
input int    InpNewsHistoryDays         = 1095;       // calendar history window in maximum-history mode
input bool   InpWriteDOMLevels          = false;      // per-level DOM rows (huge)
input int    InpDOMMinIntervalMs        = 1000;       // DOM snapshot throttle
input string InpNewsCurrencies          = "USD";      // calendar currencies, comma separated; "" = all
input int    InpNewsMinImportance       = 2;          // 0 none,1 low,2 moderate,3 high
input int    InpNewsPollSec             = 30;
input double InpCommissionPerLotDeclared = 0.0;       // round-turn commission per lot declared by the user (0 = unknown)
// ---- v1.23 integrity
input int    InpMaxBarRetries           = 5;          // consecutive failures on the same bar before it is logged as CRITICAL:BarSkipped
input int    InpRetryDelayMs            = 2000;       // wait between retries of a failed bar
input double InpOhlcTolerancePoints     = 1.0;        // server candle vs candle rebuilt from ticks (bid): max accepted deviation
input int    InpQualityIntervalSec      = 300;        // META/data_quality snapshot period
// ---- v1.23 raw ticks
input int    InpRawTickBackfillDays     = 14;         // first run (no RAW_TICKS yet): ticks from the server this many days back (0 = from now)
input int    InpRawTickChunkSec         = 3600;       // size of each CopyTicksRange request while catching up
input int    InpRawTickBudgetMs         = 400;        // max milliseconds per call spent writing ticks
// ---- v1.23 time-based forward (FORWARD_TIME)
input bool   InpWriteTimeForward        = true;       // horizons in minutes, measured on M1 bars, for events of timeframes up to InpTimeFwdMaxTFSec
input string InpTimeHorizonsMin         = "1,3,5,10,15,30,60,120,240"; // up to 16 horizons, 1..1440 minutes
input int    InpTimeFwdMaxTFSec         = 14400;      // events of timeframes with period <= this (14400 = up to H4)
input double InpTimeFwdTargetP1         = 100;        // absolute target 1 (points) for hit_*_p1_min; <=0 disables
input double InpTimeFwdTargetP2         = 200;
input double InpTimeFwdTargetP3         = 300;
input int    InpTimeFwdCacheMin         = 20000;      // M1 bars kept in memory while computing FORWARD_TIME

#define MBA_TC_MAX 40

CMBAWriter g_candles[MBA_TF_COUNT];
CMBAWriter g_events[MBA_TF_COUNT];
CMBAWriter g_forward[MBA_TF_COUNT];
CMBAWriter g_tfwd[MBA_TF_COUNT];
CMBAWriter g_tickagg[MBA_TF_COUNT];
CMBAWriter g_rawticks;
CMBAWriter g_runs;
CMBAWriter g_errors;
CMBAWriter g_news;
CMBAWriter g_dom_levels;
CMBAWriter g_dom_snapshots;
CMBAWriter g_spec;
CMBAWriter g_quality;
CMBANews   g_cal;

string g_run_id="";
string g_root="";
string g_broker="";
string g_server="";
long   g_rows_since_flush=0;

datetime g_last_bar[MBA_TF_COUNT];
datetime g_bf_first[MBA_TF_COUNT];    // maximum-history mode: first (oldest) bar to process
bool     g_bf_wait[MBA_TF_COUNT];     // waiting for the terminal to provide the deep history
datetime g_bf_t0[MBA_TF_COUNT];
long     g_bf_total[MBA_TF_COUNT];
int      g_bf_stable[MBA_TF_COUNT];
long     g_tc[MBA_TF_COUNT][MBA_TC_MAX];   // previous tick counts per timeframe (for tick_density_ratio)
int      g_tc_cnt[MBA_TF_COUNT];
bool     g_tc_seeded[MBA_TF_COUNT];

double   g_prev_tick_price=0;
bool     g_has_prev_tick=false;
string   g_news_seen[];
datetime g_cal_loaded_at=0;
datetime g_cal_from=0;
datetime g_last_news_poll=0;
ulong    g_last_dom_ms=0;
datetime g_last_err_time=0;

// ---- v1.23 state
int      g_dst_mode=MBA_DST_FIXED_CURRENT;     // resolved
int      g_fail_n[MBA_TF_COUNT];               // consecutive failures on the pending bar
ulong    g_retry_at[MBA_TF_COUNT];
// data-quality counters (this run)
datetime g_dq_first[MBA_TF_COUNT];
datetime g_dq_last[MBA_TF_COUNT];
long     g_dq_cndl[MBA_TF_COUNT],g_dq_evt[MBA_TF_COUNT],g_dq_fwd[MBA_TF_COUNT],g_dq_tagg[MBA_TF_COUNT],g_dq_tfwd[MBA_TF_COUNT],g_dq_tfwd_skip[MBA_TF_COUNT];
long     g_dq_retry[MBA_TF_COUNT],g_dq_skipped[MBA_TF_COUNT],g_dq_tickok[MBA_TF_COUNT],g_dq_tickmiss[MBA_TF_COUNT];
long     g_dq_ohlc_chk[MBA_TF_COUNT],g_dq_ohlc_diff[MBA_TF_COUNT],g_dq_gap_ev[MBA_TF_COUNT],g_dq_dst_mm[MBA_TF_COUNT];
double   g_dq_ohlc_dev[MBA_TF_COUNT];
int      g_dq_gap_max[MBA_TF_COUNT];
datetime g_last_quality=0;
// raw tick capture
bool     g_rt_ready=false;
ulong    g_rt_cursor=0;       // time_msc of the last tick written
int      g_rt_dupe=0;         // ticks already written with time_msc == g_rt_cursor
long     g_dq_raw=0;
long     g_rt_err=0;
long     g_rt_empty=0;
long     g_rt_lag_ms=0;
ulong    g_rt_last_call=0;
// time-based forward
int      g_hz[];
double   g_ptgt[3];
int      g_hmax=0;
bool     g_tfwd_on[MBA_TF_COUNT];
datetime g_tfwd_last[MBA_TF_COUNT];
int      g_tfwd_fail[MBA_TF_COUNT];
MqlRates g_m1c[];
datetime g_m1c_from=0;
datetime g_m1c_to=0;
datetime g_m1_nd_from=0;   // window known to have no M1 data in this terminal (skipped without further requests)
datetime g_m1_nd_to=0;
double   g_comm_points=0;

//+------------------------------------------------------------------+
void LogError(string where,string detail)
  {
   string f[]; MBA_Add(f,g_run_id);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_Add(f,_Symbol);MBA_Add(f,where);MBA_Add(f,detail);MBA_AddL(f,GetLastError());
   g_errors.WriteFields(f);
  }

string BuildEventId(ENUM_TIMEFRAMES tf,datetime t)
  {
   return StringFormat("%s-%s-%s",MBA_SafeName(_Symbol),MBA_TFName(tf),TimeToString(t,TIME_DATE|TIME_MINUTES));
  }

// Deterministic identity of an observation. run_id is audit only and never part of the key.
string BuildEventKey(ENUM_TIMEFRAMES tf,datetime t)
  {
   return StringFormat("%s|%s|%s|%s|%s",g_broker,_Symbol,MBA_TFName(tf),TimeToString(t,TIME_DATE|TIME_MINUTES|TIME_SECONDS),"LIVE");
  }

int FixedInputOffsetSec()
  {
   return -InpAnalysisTimezoneOffset*3600;
  }

void WriteRun()
  {
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,"LIVE");MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_Add(f,"0");MBA_Add(f,"0");
   MBA_AddL(f,InpUseDynamicUTC?-MBA_ServerOffsetSec()/3600:InpAnalysisTimezoneOffset);
   MBA_AddL(f,InpPartSizeMB);MBA_Add(f,MBA_Bool(InpWriteRawTicks));MBA_Add(f,"FALSE");MBA_Add(f,MBA_VERSION);
   g_runs.WriteFields(f);g_runs.Flush();
  }

void WriteSpec()
  {
   string f[];
   string inputs=StringFormat("dstMode=%s;lookback=%d;atr=%d;fwd=%d;tfwd=%s/%s;rawticks=%s/%dd;dom=%s;news=%s/%d;ohlcTol=%.1f",MBA_DstBasisName(g_dst_mode),InpFeatureLookback,InpATRPeriod,InpForwardMaxBars,MBA_Bool(InpWriteTimeForward),InpTimeHorizonsMin,MBA_Bool(InpWriteRawTicks),InpRawTickBackfillDays,MBA_Bool(InpWriteDOM),InpNewsCurrencies,InpNewsMinImportance,InpOhlcTolerancePoints);
   MBA_FillSpecRow(f,g_run_id,InpCommissionPerLotDeclared,inputs);
   g_spec.WriteFields(f);g_spec.Flush();
  }

bool InitWriters()
  {
   string base=InpRootFolder;
   if(InpBrokerFolder) base+="\\"+g_broker;
   g_root=base+"\\"+MBA_SafeName(_Symbol)+"\\LIVE";
   long mb=MathMax(1,InpPartSizeMB)*1024*1024;
   bool ok=true;
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      ok&=g_candles[i].Init(g_root+"\\CANDLES","candles_"+MBA_TFNames[i],MBA_CandleHeader(),mb,InpUseCommonFolder);
      ok&=g_events[i].Init(g_root+"\\EVENTS","events_"+MBA_TFNames[i],MBA_EventHeader(),mb,InpUseCommonFolder);
      ok&=g_forward[i].Init(g_root+"\\FORWARD","forward_"+MBA_TFNames[i],MBA_ForwardHeader(),mb,InpUseCommonFolder);
      ok&=g_tfwd[i].Init(g_root+"\\FORWARD_TIME","forward_time_"+MBA_TFNames[i],MBA_TimeFwdHeader(),mb,InpUseCommonFolder);
      ok&=g_tickagg[i].Init(g_root+"\\TICKS","tick_aggregate_"+MBA_TFNames[i],MBA_TickAggHeader(),mb,InpUseCommonFolder);
      g_last_bar[i]=0;g_tc_cnt[i]=0;g_tc_seeded[i]=false;g_bf_first[i]=0;g_bf_wait[i]=false;g_bf_t0[i]=0;g_bf_total[i]=-1;g_bf_stable[i]=0;
      g_fail_n[i]=0;g_retry_at[i]=0;
      g_dq_first[i]=0;g_dq_last[i]=0;g_dq_cndl[i]=0;g_dq_evt[i]=0;g_dq_fwd[i]=0;g_dq_tagg[i]=0;g_dq_tfwd[i]=0;g_dq_tfwd_skip[i]=0;
      g_dq_retry[i]=0;g_dq_skipped[i]=0;g_dq_tickok[i]=0;g_dq_tickmiss[i]=0;g_dq_ohlc_chk[i]=0;g_dq_ohlc_diff[i]=0;g_dq_gap_ev[i]=0;g_dq_dst_mm[i]=0;
      g_dq_ohlc_dev[i]=0;g_dq_gap_max[i]=0;
      g_tfwd_on[i]=false;g_tfwd_last[i]=0;g_tfwd_fail[i]=0;
     }
   ok&=g_rawticks.Init(g_root+"\\RAW_TICKS","raw_ticks","run_id,symbol,time_msc,time,bid,ask,last,volume,volume_real,flags,spread_points,tick_direction,source",mb,InpUseCommonFolder);
   ok&=g_runs.Init(g_root+"\\RUNS","runs",MBA_RunHeader(),mb,InpUseCommonFolder);
   ok&=g_errors.Init(g_root+"\\LOGS","errors","run_id,time,symbol,where,detail,last_error",mb,InpUseCommonFolder);
   ok&=g_news.Init(g_root+"\\NEWS","news",MBA_NewsHeader(),mb,InpUseCommonFolder);
   ok&=g_dom_levels.Init(g_root+"\\DOM","dom_levels",MBA_DOMLevelHeader(),mb,InpUseCommonFolder);
   ok&=g_dom_snapshots.Init(g_root+"\\DOM","dom_snapshots",MBA_DOMSnapshotHeader(),mb,InpUseCommonFolder);
   ok&=g_spec.Init(g_root+"\\META","symbol_spec",MBA_SpecHeader(),mb,InpUseCommonFolder);
   ok&=g_quality.Init(g_root+"\\META","data_quality",MBA_QualityHeader(),mb,InpUseCommonFolder);
   return ok;
  }

void FlushAll()
  {
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Flush();g_events[i].Flush();g_forward[i].Flush();g_tfwd[i].Flush();g_tickagg[i].Flush();}
   g_rawticks.Flush();g_runs.Flush();g_errors.Flush();g_news.Flush();g_dom_levels.Flush();g_dom_snapshots.Flush();g_spec.Flush();g_quality.Flush();g_rows_since_flush=0;
  }

//+------------------------------------------------------------------+
//| Tick aggregates                                                  |
//+------------------------------------------------------------------+
bool WriteTickAggregateRow(ENUM_TIMEFRAMES tf,datetime from_time,datetime to_time,MBA_TickAgg &a,string source)
  {
   int idx=MBA_TFIndex(tf); if(idx<0) return false;
   string f[];
   MBA_FillTickAggRow(f,_Symbol,MBA_TFName(tf),from_time,to_time,a,source);
   return g_tickagg[idx].WriteFields(f);
  }

// Mean of the previous tick counts of a timeframe; seeds from server tick history for short timeframes.
void SeedTickHistory(int i,int shift)
  {
   g_tc_seeded[i]=true;
   ENUM_TIMEFRAMES tf=MBA_TFs[i];
   int sec=PeriodSeconds(tf);
   if(sec<=0 || sec>1800) return;                       // H1+ builds up from live bars (ticks of many hours are too heavy)
   int n=MathMin(InpFeatureLookback,MBA_TC_MAX);
   for(int k=n;k>=1;k--)
     {
      datetime bt=iTime(_Symbol,tf,shift+k);
      if(bt<=0) continue;
      datetime be=iTime(_Symbol,tf,shift+k-1)-1;
      if(be<=bt) be=bt+sec-1;
      be=MathMin(be,bt+sec-1);
      MBA_TickAgg a;
      if(!MBA_CopyTickAggregate(_Symbol,bt,be,a)) continue;
      PushTickCount(i,a.tick_count);
     }
  }

void PushTickCount(int i,long cnt)
  {
   int cap=MathMin(InpFeatureLookback,MBA_TC_MAX);
   if(g_tc_cnt[i]<cap){g_tc[i][g_tc_cnt[i]]=cnt;g_tc_cnt[i]++;return;}
   for(int k=1;k<cap;k++) g_tc[i][k-1]=g_tc[i][k];
   g_tc[i][cap-1]=cnt;
  }

double MeanTickCount(int i)
  {
   if(g_tc_cnt[i]<3) return 0.0;
   double s=0;for(int k=0;k<g_tc_cnt[i];k++) s+=(double)g_tc[i][k];
   return s/g_tc_cnt[i];
  }

//+------------------------------------------------------------------+
//| Calendar                                                         |
//+------------------------------------------------------------------+
bool NewsSeen(const string &key)
  {
   for(int i=ArraySize(g_news_seen)-1;i>=0;i--) if(g_news_seen[i]==key) return true;
   return false;
  }

void MarkNewsSeen(const string &key)
  {
   int n=ArraySize(g_news_seen);
   if(n<50000){ArrayResize(g_news_seen,n+1);g_news_seen[n]=key;}
  }

int CalendarDays()
  {
   return InpBackfillMaxHistory?MathMax(7,InpNewsHistoryDays):MathMax(7,InpInitialBackfillDays+2);
  }

void RefreshCalendarWindow()
  {
   if(!InpWriteNewsContext) return;
   datetime now=TimeTradeServer();
   if(g_cal_loaded_at>0 && now-g_cal_loaded_at<3600) return;
   // wide enough for the initial back-fill window (calendar importance is cached, so reloading is cheap)
   g_cal_from=now-(datetime)CalendarDays()*86400;
   g_cal.Load(g_cal_from,now+2*86400,InpNewsCurrencies,InpNewsMinImportance);
   g_cal_loaded_at=now;
  }

// Writes calendar values of [from,to] that are not in the CSV yet. Key = value_id|revision|actual_value (exactly as written in the file),
// so the same value is never written twice, including across restarts; a revision or a newly released actual creates a new row.
// source "CALENDAR" = live capture; "CALENDAR_BACKFILL" = values as the server holds them NOW (may include later revisions).
// v1.23: event_time_utc uses the DST rule of the event date (not the current offset).
int WriteCalendarRange(datetime from,datetime to,string source)
  {
   string cur[];int nc=0,written=0;
   if(StringLen(InpNewsCurrencies)>0) nc=StringSplit(InpNewsCurrencies,',',cur);
   for(int p=0;p<MathMax(1,nc);p++)
     {
      MqlCalendarValue v[];
      string c="";if(nc>0){c=cur[p];StringTrimLeft(c);StringTrimRight(c);}
      int n=(nc>0)?CalendarValueHistory(v,from,to,NULL,c):CalendarValueHistory(v,from,to,NULL,NULL);
      for(int i=0;i<n;i++)
        {
         int imp=g_cal.Importance(v[i].event_id);
         if(imp<InpNewsMinImportance) continue;
         string av=v[i].HasActualValue()?DoubleToString(v[i].GetActualValue(),6):"";
         string key=MBA_UD(v[i].id)+"|"+MBA_L((long)v[i].revision)+"|"+av;
         if(NewsSeen(key)) continue;
         MqlCalendarEvent ev;string name="",code="";int etype=0,sector=0;
         if(CalendarEventById(v[i].event_id,ev))
           {
            name=ev.name;etype=(int)ev.type;sector=(int)ev.sector;
            MqlCalendarCountry cc;if(CalendarCountryById(ev.country_id,cc))code=cc.code;
           }
         int off=MBA_OffsetAt(v[i].time,g_dst_mode,FixedInputOffsetSec());
         string f[];MBA_Add(f,g_run_id);MBA_Add(f,MBA_UD(v[i].event_id));MBA_Add(f,MBA_UD(v[i].id));MBA_Add(f,MBA_DT(v[i].time,true));MBA_Add(f,MBA_DT(v[i].time-off,true));MBA_Add(f,MBA_DT(v[i].period,true));MBA_AddL(f,(long)v[i].revision);
         MBA_Add(f,av);
         MBA_Add(f,v[i].HasPreviousValue()?DoubleToString(v[i].GetPreviousValue(),6):"");
         MBA_Add(f,v[i].HasRevisedValue()?DoubleToString(v[i].GetRevisedValue(),6):"");
         MBA_Add(f,v[i].HasForecastValue()?DoubleToString(v[i].GetForecastValue(),6):"");
         MBA_Add(f,(v[i].impact_type==CALENDAR_IMPACT_POSITIVE?"POSITIVE":(v[i].impact_type==CALENDAR_IMPACT_NEGATIVE?"NEGATIVE":"NA")));
         MBA_AddL(f,imp);MBA_Add(f,g_cal.Currency(v[i].event_id));MBA_Add(f,code);MBA_Add(f,name);MBA_AddL(f,etype);MBA_AddL(f,sector);
         MBA_Add(f,source);MBA_Add(f,MBA_SCHEMA_VERSION);
         g_news.WriteFields(f);MarkNewsSeen(key);g_rows_since_flush++;written++;
        }
     }
   return written;
  }

void CaptureLiveNews()
  {
   if(!InpWriteNewsContext) return;
   datetime now=TimeTradeServer();
   if(g_last_news_poll>0 && now-g_last_news_poll<InpNewsPollSec) return;
   g_last_news_poll=now;
   WriteCalendarRange(now-86400,now+86400,"CALENDAR");
  }

//+------------------------------------------------------------------+
//| DOM (throttled, optional)                                        |
//+------------------------------------------------------------------+
string DOMTypeName(ENUM_BOOK_TYPE type)
  {
   if(type==BOOK_TYPE_BUY) return "BUY";
   if(type==BOOK_TYPE_SELL) return "SELL";
   if(type==BOOK_TYPE_BUY_MARKET) return "BUY_MARKET";
   if(type==BOOK_TYPE_SELL_MARKET) return "SELL_MARKET";
   return "UNKNOWN";
  }

void CaptureDOM(const string &symbol)
  {
   if(!InpWriteDOM || symbol!=_Symbol)return;
   ulong ms=GetTickCount64();
   if(g_last_dom_ms>0 && ms-g_last_dom_ms<(ulong)MathMax(0,InpDOMMinIntervalMs)) return;
   g_last_dom_ms=ms;
   MqlBookInfo book[];if(!MarketBookGet(_Symbol,book))return;
   double best_bid=0,best_ask=0,total_bid=0,total_ask=0;int bid_levels=0,ask_levels=0;
   for(int i=0;i<ArraySize(book);i++)
     {
      double vol=(book[i].volume_real>0?book[i].volume_real:(double)book[i].volume);
      if(book[i].type==BOOK_TYPE_BUY || book[i].type==BOOK_TYPE_BUY_MARKET){total_bid+=vol;bid_levels++;if(best_bid==0||book[i].price>best_bid)best_bid=book[i].price;}
      if(book[i].type==BOOK_TYPE_SELL || book[i].type==BOOK_TYPE_SELL_MARKET){total_ask+=vol;ask_levels++;if(best_ask==0||book[i].price<best_ask)best_ask=book[i].price;}
      if(InpWriteDOMLevels)
        {
         string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_AddL(f,i);MBA_Add(f,DOMTypeName(book[i].type));MBA_AddD(f,book[i].price,MBA_Digits());MBA_AddL(f,(long)book[i].volume);MBA_AddD(f,book[i].volume_real,6);MBA_Add(f,"LIVE_DOM");
         g_dom_levels.WriteFields(f);
        }
     }
   double den=total_bid+total_ask;double imb=den>0?(total_bid-total_ask)/den:0;double spr=(best_bid>0&&best_ask>0)?(best_ask-best_bid)/_Point:0;
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_AddD(f,best_bid,MBA_Digits());MBA_AddD(f,best_ask,MBA_Digits());MBA_AddD(f,spr,2);MBA_AddD(f,total_bid,6);MBA_AddD(f,total_ask,6);MBA_AddD(f,imb,6);MBA_AddL(f,bid_levels+ask_levels);MBA_Add(f,"LIVE_DOM");
   g_dom_snapshots.WriteFields(f);
  }

//+------------------------------------------------------------------+
//| Raw ticks (v1.23): CopyTicksRange + persistent cursor            |
//| OnTick() is only a trigger; the terminal may merge NewTick       |
//| events, so ticks are read as ranges from the stored cursor.      |
//+------------------------------------------------------------------+
bool WriteRawTick(const MqlTick &tk,string source)
  {
   double price=tk.last>0?tk.last:((tk.bid>0&&tk.ask>0)?(tk.bid+tk.ask)/2.0:tk.bid);
   int td=0;
   if(g_has_prev_tick){if(price>g_prev_tick_price)td=1;else if(price<g_prev_tick_price)td=-1;}
   if(price>0){g_prev_tick_price=price;g_has_prev_tick=true;}
   double spread=(tk.bid>0&&tk.ask>0)?(tk.ask-tk.bid)/_Point:0;
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_AddU(f,tk.time_msc);MBA_Add(f,MBA_TimeMS(tk.time_msc));MBA_AddD(f,tk.bid,MBA_Digits());MBA_AddD(f,tk.ask,MBA_Digits());MBA_AddD(f,tk.last,MBA_Digits());MBA_AddL(f,(long)tk.volume);MBA_AddD(f,tk.volume_real,4);MBA_AddL(f,(long)tk.flags);MBA_AddD(f,spread,2);MBA_Add(f,IntegerToString(td));MBA_Add(f,source);
   return g_rawticks.WriteFields(f);
  }

void InitRawTickCursor()
  {
   g_rt_ready=false;
   if(!InpWriteRawTicks) return;
   ulong now_ms=(ulong)TimeCurrent()*1000ULL;
   string tail[];
   int k=g_rawticks.TailLines(tail,300);
   if(k>0)
     {
      string c[];
      ulong last=0;
      if(StringSplit(tail[k-1],',',c)>2) last=(ulong)StringToInteger(c[2]);
      if(last>0)
        {
         int dupe=0;
         for(int q=k-1;q>=0;q--)
           {
            string d[];
            if(StringSplit(tail[q],',',d)>2 && (ulong)StringToInteger(d[2])==last) dupe++; else break;
           }
         g_rt_cursor=last;g_rt_dupe=dupe;
         if(InpRawTickBackfillDays>0 && now_ms>last && (now_ms-last)>(ulong)InpRawTickBackfillDays*86400000ULL)
           {
            ulong newc=now_ms-(ulong)InpRawTickBackfillDays*86400000ULL;
            LogError("WARN:RawTickGap",StringFormat("last stored tick %s is older than InpRawTickBackfillDays=%d; cursor moved to %s (ticks in between are NOT collected)",MBA_TimeMS(last),InpRawTickBackfillDays,MBA_TimeMS(newc)));
            g_rt_cursor=newc;g_rt_dupe=0;
           }
         g_rt_ready=true;
         return;
        }
     }
   g_rt_cursor=(InpRawTickBackfillDays>0)?(now_ms-(ulong)InpRawTickBackfillDays*86400000ULL):now_ms;
   g_rt_dupe=0;
   g_rt_ready=true;
   LogError("INFO:RawTickStart",StringFormat("first RAW_TICKS run, cursor=%s backfill_days=%d",MBA_TimeMS(g_rt_cursor),InpRawTickBackfillDays));
  }

void CaptureRawTicks()
  {
   if(!InpWriteRawTicks || !g_rt_ready) return;
   ulong t0=GetTickCount64();
   ulong chunk=(ulong)MathMax(60,InpRawTickChunkSec)*1000ULL;
   for(int guard=0;guard<500;guard++)
     {
      ulong now_ms=(ulong)TimeCurrent()*1000ULL;
      ulong from=g_rt_cursor;
      ulong to=0;
      bool chunked=false;
      if(now_ms>from && now_ms-from>chunk){to=from+chunk;chunked=true;}
      MqlTick tk[];
      ResetLastError();
      int n=CopyTicksRange(_Symbol,tk,COPY_TICKS_ALL,from,to);
      if(n<0)
        {
         g_rt_err++;
         if(g_rt_err<=20 || g_rt_err%100==0) LogError("CopyTicksRange",StringFormat("failed from=%s chunked=%s",MBA_TimeMS(from),MBA_Bool(chunked)));
         return;
        }
      string src=(now_ms>from && now_ms-from>5000)?"BACKFILL_RANGE":"CAPTURE_RANGE";
      int skipped=0;
      bool budget_hit=false;
      for(int k=0;k<n;k++)
        {
         if((ulong)tk[k].time_msc<g_rt_cursor) continue;
         if((ulong)tk[k].time_msc==g_rt_cursor && skipped<g_rt_dupe){skipped++;continue;}
         if(!WriteRawTick(tk[k],src)){g_rt_err++;LogError("WriteRawTick","write failed");return;}
         if((ulong)tk[k].time_msc==g_rt_cursor) g_rt_dupe++;
         else {g_rt_cursor=(ulong)tk[k].time_msc;g_rt_dupe=1;}
         g_dq_raw++;g_rows_since_flush++;
         if((k&1023)==1023 && (long)(GetTickCount64()-t0)>(long)MathMax(50,InpRawTickBudgetMs)){budget_hit=true;break;}
        }
      if(budget_hit) break;
      if(!chunked) break;
      // whole chunk consumed: move to its end (a tick exactly at `to` would already have moved the cursor there)
      if(g_rt_cursor<to){g_rt_cursor=to;g_rt_dupe=0;if(n==0)g_rt_empty++;}
      if((long)(GetTickCount64()-t0)>(long)MathMax(50,InpRawTickBudgetMs)) break;
     }
   long lag=(long)((ulong)TimeCurrent()*1000ULL)-(long)g_rt_cursor;
   g_rt_lag_ms=(lag>0?lag:0);
  }

//+------------------------------------------------------------------+
//| Forward: one row per (event, horizon), written when the horizon |
//| bar closes. rr[nr-1] is the horizon bar.                         |
//+------------------------------------------------------------------+
int WriteForwardForClosedBar(int tfIndex,const MqlRates &rr[],int nr,string source)
  {
   if(!InpWriteForward) return 0;
   ENUM_TIMEFRAMES tf=MBA_TFs[tfIndex];
   int hmax=MathMin(InpForwardMaxBars,MBA_MAX_FORWARD);
   int rows=0;
   for(int h=1;h<=hmax;h++)
     {
      int ei=nr-1-h;
      if(ei<1) break;
      double atr=MBA_ATRAt(rr,ei,InpATRPeriod);
      string ekey=BuildEventKey(tf,rr[ei].time);
      string f[];
      MBA_FillForwardRow(f,g_run_id,ekey,BuildEventId(tf,rr[ei].time),g_broker,g_server,"LIVE",MBA_TFName(tf),rr,ei,h,atr,source);
      if(g_forward[tfIndex].WriteFields(f)){rows++;g_rows_since_flush++;}
      else LogError("WriteForward",MBA_TFName(tf)+" "+ekey+" h="+IntegerToString(h));
     }
   return rows;
  }

//+------------------------------------------------------------------+
//| Process one closed bar (live or back-fill)                       |
//| The bar is marked as processed (g_last_bar) only after its       |
//| candle row is on disk. Failures are retried.                     |
//+------------------------------------------------------------------+
bool BarFailed(int i,datetime t,string why)
  {
   g_fail_n[i]++;g_dq_retry[i]++;
   LogError("ProcessBar",StringFormat("%s %s %s attempt=%d/%d",MBA_TFName(MBA_TFs[i]),why,TimeToString(t,TIME_DATE|TIME_MINUTES),g_fail_n[i],MathMax(1,InpMaxBarRetries)));
   if(g_fail_n[i]>=MathMax(1,InpMaxBarRetries))
     {
      // give up on this bar so the collector does not stall forever; the loss is explicit in the log and in META/data_quality
      LogError("CRITICAL:BarSkipped",StringFormat("%s %s was NOT collected (%s)",MBA_TFName(MBA_TFs[i]),TimeToString(t,TIME_DATE|TIME_MINUTES),why));
      g_dq_skipped[i]++;
      g_last_bar[i]=t;
      g_fail_n[i]=0;
      g_retry_at[i]=0;
     }
   else g_retry_at[i]=GetTickCount64()+(ulong)MathMax(200,InpRetryDelayMs);
   return false;
  }

bool ProcessBar(int i,int shift,string source)
  {
   ENUM_TIMEFRAMES tf=MBA_TFs[i];
   datetime t=iTime(_Symbol,tf,shift);
   if(t<=0){g_retry_at[i]=GetTickCount64()+(ulong)MathMax(200,InpRetryDelayMs);return false;}
   int want=MathMax(InpFeatureLookback+5,120);
   MqlRates rr[];
   int nr=CopyRates(_Symbol,tf,shift,want,rr);
   if(nr<3 || rr[nr-1].time!=t) return BarFailed(i,t,"rates unavailable");
   int idx=nr-1;
   MBA_BarCtx c;
   c.run_id=g_run_id;c.symbol=_Symbol;c.tf_name=MBA_TFName(tf);c.source=source;c.broker=g_broker;c.server=g_server;c.data_source="LIVE";
   c.bar=rr[idx];c.server_time=t;
   c.event_id=BuildEventId(tf,t);c.event_key=BuildEventKey(tf,t);
   // ---- time basis (v1.23: history is converted with the DST rule of the bar date)
   int off=0;
   bool dst_mismatch=false;
   if(InpUseDynamicUTC)
     {
      off=MBA_OffsetAt(t,g_dst_mode,FixedInputOffsetSec());
      if(g_dst_mode==MBA_DST_US_NY_CLOSE)
        {
         c.utc_basis=MBA_DstBasisName(g_dst_mode);
         // cross-check against the live clock when the bar just closed
         if(source=="LIVE_CAPTURE" && (TimeTradeServer()-t)<=(datetime)(PeriodSeconds(tf)+3600) && MBA_ServerOffsetSec()!=off) dst_mismatch=true;
        }
      else c.utc_basis=(source=="LIVE_CAPTURE"?"LIVE_CLOCK_OFFSET":"BACKFILL_ASSUMES_CURRENT_OFFSET");
     }
   else {off=FixedInputOffsetSec();c.utc_basis="FIXED_INPUT";}
   c.utc_offset_sec=off;c.utc_time=t-(datetime)off;c.analysis_time=c.utc_time;
   // ---- geometry
   c.range=MBA_Range(c.bar);c.body=MBA_Body(c.bar);c.uw=MBA_UpperWick(c.bar);c.lw=MBA_LowerWick(c.bar);
   double prev_close=rr[idx-1].close;
   c.true_range=MathMax(c.range,MathMax(MathAbs(c.bar.high-prev_close),MathAbs(c.bar.low-prev_close)));
   c.atr=MBA_ATRAt(rr,idx,InpATRPeriod);
   c.avg_tv=MBA_AvgTickVolumeAt(rr,idx,InpFeatureLookback);
   c.vr=c.avg_tv>0?(double)c.bar.tick_volume/c.avg_tv:1.0;
   c.bar_spread=(double)c.bar.spread;
   int sec=PeriodSeconds(tf);
   c.gap_bars=0;
   if(sec>0 && tf!=PERIOD_MN1){int g=(int)((t-rr[idx-1].time)/sec)-1;c.gap_bars=(g>0?g:0);}
   c.pattern=MBA_Patterns(rr,idx);
   c.structure_at_close=MBA_StateFromRates(rr,idx,InpFeatureLookback);
   c.structure_before=MBA_StateFromRates(rr,idx-1,InpFeatureLookback);
   c.vol_state=MBA_VolatilityState(MBA_SafeRatio(c.range,c.atr));
   // ---- ticks (single aggregate per bar)
   bool want_ticks=(InpTickHistoryDays<=0) || (t>=TimeTradeServer()-(datetime)InpTickHistoryDays*86400);
   if(want_ticks && !g_tc_seeded[i]) SeedTickHistory(i,shift);
   datetime nxt=(shift>=1?iTime(_Symbol,tf,shift-1):0);
   datetime end=(nxt>t?nxt-1:MBA_NextBarTime(t,tf)-1);
   if(sec>0 && tf!=PERIOD_MN1) end=MathMin(end,t+sec-1);
   MBA_TickAgg ta;
   MBA_ResetTickAgg(ta);
   c.tick_ok=want_ticks && MBA_CopyTickAggregate(_Symbol,t,end,ta);
   c.tick_count=c.tick_ok?ta.tick_count:0;
   c.tick_density=c.tick_ok?(double)ta.tick_count/MathMax(1.0,(double)MathMax(sec,60)/60.0):MBA_NaN();
   double mtc=MeanTickCount(i);
   c.tick_density_ratio=(c.tick_ok&&mtc>0)?(double)ta.tick_count/mtc:MBA_NaN();
   c.spread_avg=c.tick_ok?MBA_SafeRatio(ta.spread_sum,(double)MathMax(1,ta.tick_count)):MBA_NaN();
   c.spread_max=c.tick_ok?ta.spread_max:MBA_NaN();
   c.spread_min=c.tick_ok?ta.spread_min:MBA_NaN();
   // ---- audit: candle served by the broker vs candle rebuilt from the ticks (bid chart only)
   c.ohlc_status="NA";c.ohlc_dev=MBA_NaN();
   if(c.tick_ok && ta.bid_first>0 && SymbolInfoInteger(_Symbol,SYMBOL_CHART_MODE)==SYMBOL_CHART_MODE_BID)
     {
      double dv=MathMax(MathMax(MathAbs(c.bar.open-ta.bid_first),MathAbs(c.bar.high-ta.bid_max)),MathMax(MathAbs(c.bar.low-ta.bid_min),MathAbs(c.bar.close-ta.bid_last)))/_Point;
      c.ohlc_dev=dv;
      c.ohlc_status=(dv<=InpOhlcTolerancePoints?"OK":"DIFF");
     }
   // ---- location / levels (all known before the event bar opens, except *_open which are the open of the period)
   double dopen=0,wopen=0,mopen=0,pdh=0,pdl=0;
   MqlRates d1[],w1[],mn[];
   if(CopyRates(_Symbol,PERIOD_D1,t-15*86400,t,d1)>0){dopen=MBA_OpenAtOrBefore(d1,t);MBA_PrevDayLevels(d1,t,pdh,pdl);}
   if(CopyRates(_Symbol,PERIOD_W1,t-21*86400,t,w1)>0) wopen=MBA_OpenAtOrBefore(w1,t);
   if(CopyRates(_Symbol,PERIOD_MN1,t-75*86400,t,mn)>0) mopen=MBA_OpenAtOrBefore(mn,t);
   double px=c.bar.close;
   c.d_open_pts=dopen>0?(px-dopen)/_Point:MBA_NaN();
   c.w_open_pts=wopen>0?(px-wopen)/_Point:MBA_NaN();
   c.m_open_pts=mopen>0?(px-mopen)/_Point:MBA_NaN();
   c.pdh_atr=MBA_DistATR(px,pdh,c.atr);c.pdl_atr=MBA_DistATR(px,pdl,c.atr);
   double ph=0,pl=0;int from=MathMax(0,idx-InpFeatureLookback);
   ph=rr[from].high;pl=rr[from].low;
   for(int j=from;j<idx;j++){ph=MathMax(ph,rr[j].high);pl=MathMin(pl,rr[j].low);}
   c.prev_high_atr=MBA_DistATR(px,ph,c.atr);c.prev_low_atr=MBA_DistATR(px,pl,c.atr);
   double sh=0,sl=0;MBA_SwingLevels(rr,idx,sh,sl);
   c.swing_high_atr=MBA_DistATR(px,sh,c.atr);c.swing_low_atr=MBA_DistATR(px,sl,c.atr);
   c.sess_high_atr=MBA_NaN();c.sess_low_atr=MBA_NaN();
   if(sec>0 && sec<=3600)
     {
      MqlDateTime du;TimeToStruct(c.utc_time,du);
      datetime day0=c.utc_time-(datetime)(du.hour*3600+du.min*60+du.sec);
      datetime sess_start_server=day0+(datetime)(MBA_SessionStartHour(du.hour)*3600)+(datetime)off;
      if(t>sess_start_server)
        {
         MqlRates m1[];
         if(CopyRates(_Symbol,PERIOD_M1,sess_start_server,t-1,m1)>0)
           {
            double shi=0,slo=0;
            if(MBA_SessionLevels(m1,sess_start_server,t,shi,slo)){c.sess_high_atr=MBA_DistATR(px,shi,c.atr);c.sess_low_atr=MBA_DistATR(px,slo,c.atr);}
           }
        }
     }
   // ---- multi-timeframe context: only bars closed BEFORE the event bar opens
   for(int s=0;s<MBA_TF_COUNT;s++)
     {
      ENUM_TIMEFRAMES htf=MBA_TFs[s];
      MqlRates hr[];
      int sh_i=iBarShift(_Symbol,htf,t,false);
      if(sh_i<0){c.mtf[s]="UNKNOWN";continue;}
      int nh=CopyRates(_Symbol,htf,sh_i,InpFeatureLookback+10,hr);
      c.mtf[s]=(nh>0)?MBA_StateClosedAt(hr,htf,t,InpFeatureLookback):"UNKNOWN";
     }
   // ---- calendar (scheduled events are known in advance; actual values are not used here)
   c.news_n=0;c.news_high_n=0;c.news_min_next=MBA_NaN();c.news_min_since=MBA_NaN();
   if(!InpWriteNewsContext) c.news_state="DISABLED";
   else if(g_cal.Count()<=0 || t<g_cal_from) c.news_state="UNAVAILABLE";
   else
     {
      g_cal.Context(t,3600,c.news_n,c.news_high_n,c.news_min_next,c.news_min_since);
      c.news_state=(c.news_n>0?StringFormat("EVENTS_%d_AROUND_60M",c.news_n):"NONE_60M");
     }
   // ---- write: the candle row decides whether the bar is done (nothing else is written before it, so a retry never duplicates)
   string f[];
   MBA_FillCandleRow(f,c);
   if(!g_candles[i].WriteFields(f)) return BarFailed(i,t,"candle write failed");
   g_dq_cndl[i]++;
   if(g_dq_first[i]==0) g_dq_first[i]=t;
   g_dq_last[i]=t;
   g_fail_n[i]=0;g_retry_at[i]=0;
   if(InpWriteEvents)
     {
      MBA_FillEventRow(f,c);
      if(g_events[i].WriteFields(f)) g_dq_evt[i]++;
      else LogError("WriteEvent",MBA_TFName(tf)+" "+TimeToString(t,TIME_DATE|TIME_MINUTES));
     }
   if(c.tick_ok)
     {
      if(InpWriteTickAggregates)
        {
         if(WriteTickAggregateRow(tf,t,end,ta,source)) g_dq_tagg[i]++;
         else LogError("WriteTickAggregate",MBA_TFName(tf)+" "+TimeToString(t,TIME_DATE|TIME_MINUTES));
        }
      PushTickCount(i,ta.tick_count);
      g_dq_tickok[i]++;
     }
   else g_dq_tickmiss[i]++;
   if(c.ohlc_status=="OK" || c.ohlc_status=="DIFF")
     {
      g_dq_ohlc_chk[i]++;
      if(c.ohlc_status=="DIFF") g_dq_ohlc_diff[i]++;
      if(c.ohlc_dev>g_dq_ohlc_dev[i]) g_dq_ohlc_dev[i]=c.ohlc_dev;
     }
   if(c.gap_bars>0){g_dq_gap_ev[i]++;if(c.gap_bars>g_dq_gap_max[i])g_dq_gap_max[i]=c.gap_bars;}
   if(dst_mismatch) g_dq_dst_mm[i]++;
   g_dq_fwd[i]+=WriteForwardForClosedBar(i,rr,nr,source);
   g_last_bar[i]=t;
   g_rows_since_flush++;
   return true;
  }

//+------------------------------------------------------------------+
//| Time-based forward engine (v1.23)                                |
//| For every event of a timeframe <= InpTimeFwdMaxTFSec, once the   |
//| longest horizon is complete, writes one row per horizon (minutes)|
//| measured on M1 bars. Cursor = last event_time in the file.       |
//+------------------------------------------------------------------+
bool EnsureM1Cache(datetime need_from,datetime need_to)
  {
   if(ArraySize(g_m1c)>0 && need_from>=g_m1c_from && need_to<=g_m1c_to) return true;
   datetime a=need_from-120;
   datetime b=need_to+(datetime)MathMax(600,InpTimeFwdCacheMin)*60;
   datetime lim=iTime(_Symbol,PERIOD_M1,0)-1;
   if(b>lim) b=lim;
   ArrayResize(g_m1c,0);
   int n=CopyRates(_Symbol,PERIOD_M1,a,b,g_m1c);
   if(n<=0)
     {
      ArrayResize(g_m1c,0);
      g_m1_nd_from=a;g_m1_nd_to=b;                  // no M1 bars at all in this window: later events inside it are skipped at once
      LogError("INFO:TimeFwdNoM1",StringFormat("no M1 bars between %s and %s in this terminal; FORWARD_TIME skipped for events in that window",TimeToString(a,TIME_DATE|TIME_MINUTES),TimeToString(b,TIME_DATE|TIME_MINUTES)));
      return false;
     }
   ArraySetAsSeries(g_m1c,false);
   g_m1c_from=a;g_m1c_to=b;
   return (need_to<=b);
  }

bool TimeFwdOne(int i)
  {
   if(!g_tfwd_on[i]) return false;
   ENUM_TIMEFRAMES tf=MBA_TFs[i];
   if(g_tfwd_last[i]==0)
     {
      string c[];
      string ll=g_tfwd[i].LastDataLine();
      if(StringLen(ll)>0 && StringSplit(ll,',',c)>9) g_tfwd_last[i]=StringToTime(c[9]);              // event_time of the last row
      else
        {
         string fl=g_candles[i].FirstDataLine();
         if(StringLen(fl)==0 || StringSplit(fl,',',c)<=8) return false;                              // no candle yet
         datetime ft=StringToTime(c[8]);
         if(ft<=0) return false;
         g_tfwd_last[i]=ft-1;
        }
      if(g_tfwd_last[i]==0) return false;
     }
   datetime m1_first=(datetime)SeriesInfoInteger(_Symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE);
   for(int it=0;it<3000;it++)
     {
      int sh=iBarShift(_Symbol,tf,g_tfwd_last[i],false);
      if(sh<0) return false;
      int ns=sh-1;
      if(ns<1) return false;
      datetime eo=iTime(_Symbol,tf,ns);
      if(eo<=0 || eo>g_last_bar[i]) return false;                 // candle of this event not written yet
      datetime ec=iTime(_Symbol,tf,ns-1);
      if(ec<=eo) ec=eo+(datetime)PeriodSeconds(tf);
      datetime need_to=ec+(datetime)(g_hmax*60);
      if(iTime(_Symbol,PERIOD_M1,0)<need_to) return false;        // longest horizon not complete yet
      if(ec<m1_first || m1_first<=0)                              // no M1 history that old in this terminal: cheap skip
        {
         g_tfwd_last[i]=eo;g_dq_tfwd_skip[i]++;
         continue;
        }
      if(ec>=g_m1_nd_from && need_to<=g_m1_nd_to)                 // inside a window already known to be empty
        {
         g_tfwd_last[i]=eo;g_dq_tfwd_skip[i]++;
         continue;
        }
      if(!EnsureM1Cache(ec,need_to-1))
        {
         g_tfwd_last[i]=eo;g_dq_tfwd_skip[i]++;                  // EnsureM1Cache logged the empty window
         continue;
        }
      int want=MathMax(InpFeatureLookback+5,120);
      MqlRates rr[];
      int nr=CopyRates(_Symbol,tf,ns,want,rr);
      if(nr<3 || rr[nr-1].time!=eo)
        {
         g_tfwd_fail[i]++;
         if(g_tfwd_fail[i]>=MathMax(1,InpMaxBarRetries))
           {
            LogError("CRITICAL:TimeFwdSkipped",StringFormat("%s %s event rates unavailable",MBA_TFName(tf),TimeToString(eo,TIME_DATE|TIME_MINUTES)));
            g_tfwd_last[i]=eo;g_tfwd_fail[i]=0;g_dq_tfwd_skip[i]++;
            continue;
           }
         return false;
        }
      g_tfwd_fail[i]=0;
      int idx=nr-1;
      MBA_TFwdEvent e;
      e.run_id=g_run_id;e.event_key=BuildEventKey(tf,eo);e.event_id=BuildEventId(tf,eo);e.broker=g_broker;e.server=g_server;e.symbol=_Symbol;
      e.tf_name=MBA_TFName(tf);e.data_source="LIVE";e.source="TIME_FORWARD";
      e.event_open=eo;e.event_close=ec;e.ref=rr[idx].close;e.atr=MBA_ATRAt(rr,idx,InpATRPeriod);
      e.spread_points=(double)rr[idx].spread;e.commission_points=g_comm_points;e.dir=MBA_Direction(rr[idx]);
      int r=MBA_WriteTimeForward(g_tfwd[i],e,g_m1c,g_hz,g_ptgt);
      if(r<0){LogError("WriteTimeForward",MBA_TFName(tf)+" "+TimeToString(eo,TIME_DATE|TIME_MINUTES));return false;}
      g_dq_tfwd[i]+=r;g_rows_since_flush+=r;
      g_tfwd_last[i]=eo;
      return true;                                                 // one expensive event per call
     }
   return true;
  }

//+------------------------------------------------------------------+
//| META/data_quality                                                |
//+------------------------------------------------------------------+
void WriteQuality()
  {
   g_last_quality=TimeTradeServer();
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      ENUM_TIMEFRAMES tf=MBA_TFs[i];
      long expected=0;
      if(g_dq_first[i]>0 && g_dq_last[i]>=g_dq_first[i])
        {
         // real bars held by the terminal between the first and last bar of this run (Bars(start,stop) over a history hole returns a theoretical count)
         int s1=iBarShift(_Symbol,tf,g_dq_first[i],true),s2=iBarShift(_Symbol,tf,g_dq_last[i],true);
         if(s1>=0 && s2>=0 && s1>=s2) expected=s1-s2+1;
        }
      long missing=expected-g_dq_cndl[i];
      long wfail=g_candles[i].WriteFailures()+g_events[i].WriteFailures()+g_forward[i].WriteFailures()+g_tickagg[i].WriteFailures()+g_tfwd[i].WriteFailures();
      string status="OK";
      if(g_bf_wait[i] && g_dq_cndl[i]==0) status="WAITING_HISTORY";
      else if(g_dq_cndl[i]==0) status="NO_BARS_THIS_RUN";
      else if(missing>0 || g_dq_skipped[i]>0 || wfail>0) status="CHECK";
      else if(missing<0) status="MORE_ROWS_THAN_BARS";
      string f[];
      MBA_Add(f,g_run_id);MBA_Add(f,MBA_DT(TimeTradeServer(),true));MBA_Add(f,MBA_DT(TimeGMT(),true));MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFNames[i]);
      MBA_Add(f,g_dq_first[i]>0?MBA_DT(g_dq_first[i],true):"");MBA_Add(f,g_dq_last[i]>0?MBA_DT(g_dq_last[i],true):"");
      MBA_AddL(f,expected);MBA_AddL(f,g_dq_cndl[i]);MBA_AddL(f,missing);MBA_AddL(f,g_dq_evt[i]);MBA_AddL(f,g_dq_fwd[i]);MBA_AddL(f,g_dq_tagg[i]);MBA_AddL(f,g_dq_tfwd[i]);MBA_AddL(f,g_dq_tfwd_skip[i]);
      MBA_AddL(f,g_dq_retry[i]);MBA_AddL(f,g_dq_skipped[i]);MBA_AddL(f,wfail);MBA_AddL(f,g_dq_tickok[i]);MBA_AddL(f,g_dq_tickmiss[i]);
      MBA_AddL(f,g_dq_ohlc_chk[i]);MBA_AddL(f,g_dq_ohlc_diff[i]);MBA_AddD(f,g_dq_ohlc_dev[i],2);MBA_AddL(f,g_dq_gap_ev[i]);MBA_AddL(f,g_dq_gap_max[i]);MBA_AddL(f,g_dq_dst_mm[i]);
      MBA_Add(f,"");MBA_Add(f,"");MBA_Add(f,"");MBA_Add(f,"");MBA_Add(f,status);
      g_quality.WriteFields(f);
     }
   if(InpWriteRawTicks)
     {
      string f[];
      MBA_Add(f,g_run_id);MBA_Add(f,MBA_DT(TimeTradeServer(),true));MBA_Add(f,MBA_DT(TimeGMT(),true));MBA_Add(f,_Symbol);MBA_Add(f,"RAW_TICKS");
      for(int k=0;k<12;k++) MBA_Add(f,"");              // columns 6..17
      MBA_AddL(f,g_rawticks.WriteFailures());           // column 18: write_failures
      for(int k=0;k<8;k++) MBA_Add(f,"");               // columns 19..26
      MBA_AddL(f,g_dq_raw);MBA_Add(f,MBA_TimeMS(g_rt_cursor));MBA_AddL(f,g_rt_lag_ms);MBA_AddL(f,g_rt_err+g_rt_empty);
      MBA_Add(f,(g_rt_err>0)?"CHECK":"OK");
      g_quality.WriteFields(f);
     }
   g_quality.Flush();
  }

int DaysFor(ENUM_TIMEFRAMES tf)
  {
   int d=InpBackfillMaxDays;
   if(tf==PERIOD_M1) d=InpDaysM1;
   else if(tf==PERIOD_M5) d=InpDaysM5;
   else if(tf==PERIOD_M15) d=InpDaysM15;
   else if(tf==PERIOD_M30) d=InpDaysM30;
   else if(tf==PERIOD_H1) d=InpDaysH1;
   else if(tf==PERIOD_H4) d=InpDaysH4;
   else if(tf==PERIOD_D1) d=InpDaysD1;
   else if(tf==PERIOD_W1) d=InpDaysW1;
   else if(tf==PERIOD_MN1) d=InpDaysMN1;
   return MathMax(1,MathMin(d,InpBackfillMaxDays));
  }

// Maximum-history start: oldest bar the terminal can provide for a timeframe
// (bounded by the server first date, the terminal "Max bars in chart" setting and InpBackfillMaxDays).
bool ResolveBackfillStart(int i)
  {
   ENUM_TIMEFRAMES tf=MBA_TFs[i];
   datetime nowl=TimeLocal();
   if(g_bf_t0[i]==0) g_bf_t0[i]=nowl;
   int sec=PeriodSeconds(tf);
   if(sec<=0) sec=60;
   long maxb=TerminalInfoInteger(TERMINAL_MAXBARS);
   long want=(long)DaysFor(tf)*86400/sec+1;
   if(tf==PERIOD_MN1) want=(long)DaysFor(tf)/28+1;
   long deep=MathMin(maxb-1,want);
   MqlRates tmp[];
   CopyRates(_Symbol,tf,(int)deep,1,tmp);                 // asks the terminal to download the deepest bar it is allowed to hold
   long total=Bars(_Symbol,tf);
   bool sync=(bool)SeriesInfoInteger(_Symbol,tf,SERIES_SYNCHRONIZED);
   if(total==g_bf_total[i]) g_bf_stable[i]++; else {g_bf_stable[i]=0;g_bf_total[i]=total;}
   bool timeout=(nowl-g_bf_t0[i])>=InpBackfillSyncWaitSec;
   if(!(sync && g_bf_stable[i]>=3) && !timeout) return false;
   // history depth in BARS from the requested number of DAYS (weekends/breaks make bars-per-day < 86400/period)
   datetime cap_t=TimeTradeServer()-(datetime)DaysFor(tf)*86400;
   int sh_cap=iBarShift(_Symbol,tf,cap_t,false);
   long depth=MathMin(total,maxb)-1;
   if(sh_cap>0) depth=MathMin(depth,(long)sh_cap);
   if(depth<1) depth=1;
   int pad=InpFeatureLookback+3;                           // skip the first bars: not enough lookback for indicators
   long start_shift=depth-pad;
   if(start_shift<1) start_shift=1;
   datetime t0=iTime(_Symbol,tf,(int)start_shift);
   bool limited=(total>=maxb-1 && (sh_cap<=0 || sh_cap>maxb-1));
   string lf[];MBA_Add(lf,g_run_id);MBA_Add(lf,MBA_DT(TimeCurrent(),true));MBA_Add(lf,_Symbol);MBA_Add(lf,"INFO:BackfillStart");
   MBA_Add(lf,StringFormat("%s first_bar=%s requested_days=%d bars_local=%d max_bars_in_chart=%d server_first=%s limited_by_max_bars=%s timeout=%s",MBA_TFName(tf),MBA_DT(t0,true),DaysFor(tf),(int)total,(int)maxb,MBA_DT((datetime)SeriesInfoInteger(_Symbol,tf,SERIES_SERVER_FIRSTDATE),true),MBA_Bool(limited),MBA_Bool(timeout)));
   MBA_AddL(lf,0);
   g_errors.WriteFields(lf);
   g_bf_wait[i]=false;
   if(t0>0) g_bf_first[i]=t0;
   else g_last_bar[i]=iTime(_Symbol,tf,1);                  // nothing deep available: just go live
   return true;
  }

// Process ONE closed bar after g_last_bar (live bar, restart gap or initial history). Returns true when more bars remain.
bool CatchUpOne(int i)
  {
   ENUM_TIMEFRAMES tf=MBA_TFs[i];
   if(g_bf_wait[i]){ResolveBackfillStart(i);return false;}
   if(GetTickCount64()<g_retry_at[i]) return false;            // a failed bar waits before the next attempt
   if(g_bf_first[i]>0)
     {
      int sh0=iBarShift(_Symbol,tf,g_bf_first[i],true);
      if(sh0>=1)
        {
         // g_bf_first is cleared only after the bar is really processed (v1.22 cleared it first and a failure jumped to live, skipping the history)
         if(ProcessBar(i,sh0,(sh0==1)?"LIVE_CAPTURE":"BACKFILL_SERVER")) g_bf_first[i]=0;
         else if(g_last_bar[i]>=g_bf_first[i]) g_bf_first[i]=0;  // the bar was given up after the retry limit
         return (sh0>1) || g_bf_first[i]>0;
        }
      g_bf_first[i]=0;
     }
   datetime latest=iTime(_Symbol,tf,1);
   if(latest<=0 || latest<=g_last_bar[i]) return false;
   int shift=1;
   if(g_last_bar[i]>0)
     {
      int sh=iBarShift(_Symbol,tf,g_last_bar[i],true);
      // v1.23.1: always the NEXT bar after the last stored one. The old cap (MathMin(sh-1,InpMaxCatchupBars)) jumped to the bar InpMaxCatchupBars from now
      // whenever more bars were pending, silently skipping the rest of the history (M1 kept only 200001 candles).
      if(sh>1) shift=sh-1;
     }
   ProcessBar(i,shift,(shift==1)?"LIVE_CAPTURE":"BACKFILL_SERVER");
   return shift>1;
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   g_broker=MBA_SafeToken(AccountInfoString(ACCOUNT_COMPANY));
   g_server=MBA_SafeToken(AccountInfoString(ACCOUNT_SERVER));
   g_run_id=StringFormat("LIVE_%s_%s",MBA_SafeName(_Symbol),TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   g_dst_mode=InpUseDynamicUTC?MBA_ResolveDstMode((int)InpDstMode):MBA_DST_FIXED_INPUT;
   if(!InitWriters())
     {
      Print("MBA: could not open one or more output files (check the folder/permissions). Collection aborted.");
      return INIT_FAILED;
     }
   WriteRun();
   WriteSpec();
   LogError("INFO:UtcMode",StringFormat("server_utc_offset_now=%d s, history conversion=%s",MBA_ServerOffsetSec(),MBA_DstBasisName(g_dst_mode)));
   // schema change: older parts with another header stay untouched; history is rebuilt under the new schema
   for(int i=0;i<MBA_TF_COUNT;i++)
      if(g_candles[i].HasForeignParts())
        {
         LogError("WARN:SchemaChange",MBA_TFName(MBA_TFs[i])+" has CSV parts with another header (older schema). Rows of schema "+MBA_SCHEMA_VERSION+" go to new parts; archive the old LIVE folder first to avoid mixing schemas.");
         break;
        }
   // time-based forward configuration
   ArrayResize(g_hz,0);
   if(InpWriteTimeForward) MBA_ParseHorizons(InpTimeHorizonsMin,g_hz);
   g_hmax=(ArraySize(g_hz)>0?g_hz[ArraySize(g_hz)-1]:0);
   g_ptgt[0]=InpTimeFwdTargetP1;g_ptgt[1]=InpTimeFwdTargetP2;g_ptgt[2]=InpTimeFwdTargetP3;
   double tv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE),ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double vpp=(ts>0?tv*_Point/ts:0);
   g_comm_points=(InpCommissionPerLotDeclared>0 && vpp>0)?InpCommissionPerLotDeclared/vpp:0;
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      int ps=PeriodSeconds(MBA_TFs[i]);
      g_tfwd_on[i]=(InpWriteTimeForward && g_hmax>0 && ps>0 && ps<=InpTimeFwdMaxTFSec);
     }
   // resume: continue after the last stored bar of each timeframe (no duplicates, gaps are back-filled)
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      datetime latest=iTime(_Symbol,MBA_TFs[i],1);
      g_last_bar[i]=latest;
      string ll=g_candles[i].LastDataLine();
      if(StringLen(ll)>0)
        {
         string c[];
         if(StringSplit(ll,',',c)>8)
           {
            datetime lt=StringToTime(c[8]);   // server_time column
            // resume from the stored bar even when the terminal series is still stale right after a start (latest < lt): CatchUpOne only advances when latest > g_last_bar, so nothing is rewritten
            if(lt>0) g_last_bar[i]=lt;
           }
        }
      else if(InpBackfillMaxHistory)
        {
         g_last_bar[i]=0;                      // set by ResolveBackfillStart once the terminal has the deep history
         g_bf_wait[i]=true;
        }
      else if(InpInitialBackfillDays>0)
        {
         // fresh start: begin InpInitialBackfillDays back; bars are produced in small batches by OnTimer
         int sh0=iBarShift(_Symbol,MBA_TFs[i],TimeCurrent()-(datetime)InpInitialBackfillDays*86400,false);
         if(sh0>1){datetime st=iTime(_Symbol,MBA_TFs[i],sh0);if(st>0)g_last_bar[i]=st;}
        }
     }
   // news de-duplication across restarts (calendar_value_id|revision|actual_value)
   ArrayResize(g_news_seen,0);
   if(InpWriteNewsContext)
     {
      string keys[];
      int nk=g_news.LoadKeys(keys,2,6,7);
      for(int k=0;k<nk;k++) MarkNewsSeen(keys[k]);
     }
   g_last_news_poll=0;g_cal_loaded_at=0;
   RefreshCalendarWindow();
   // calendar history for the whole back-fill window (surprise = actual vs forecast can then be studied); runs once, de-duplicated
   if(InpWriteNewsContext && (InpBackfillMaxHistory || InpInitialBackfillDays>0))
     {
      datetime now=TimeTradeServer();
      int nw=WriteCalendarRange(now-(datetime)CalendarDays()*86400,now,"CALENDAR_BACKFILL");
      string lf[];MBA_Add(lf,g_run_id);MBA_Add(lf,MBA_DT(TimeCurrent(),true));MBA_Add(lf,_Symbol);MBA_Add(lf,"INFO:CalendarBackfill");MBA_Add(lf,StringFormat("rows_written=%d days=%d",nw,CalendarDays()));MBA_AddL(lf,0);
      g_errors.WriteFields(lf);
     }
   InitRawTickCursor();
   if(InpWriteDOM)MarketBookAdd(_Symbol);
   g_last_quality=TimeTradeServer();
   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(InpWriteDOM)MarketBookRelease(_Symbol);
   WriteQuality();
   FlushAll();
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Close();g_events[i].Close();g_forward[i].Close();g_tfwd[i].Close();g_tickagg[i].Close();}
   g_rawticks.Close();g_runs.Close();g_errors.Close();g_news.Close();g_dom_levels.Close();g_dom_snapshots.Close();g_spec.Close();g_quality.Close();
  }

void OnBookEvent(const string &symbol)
  {
   CaptureDOM(symbol);
  }

void OnTick()
  {
   ulong ms=GetTickCount64();
   if(ms-g_rt_last_call<250) return;                  // OnTick only triggers the range read; throttled
   g_rt_last_call=ms;
   CaptureRawTicks();
  }

void OnTimer()
  {
   RefreshCalendarWindow();
   CaptureLiveNews();
   CaptureRawTicks();
   // round-robin, one bar per timeframe per pass, within a time budget
   ulong t0=GetTickCount64();
   bool more=true;
   while(more && (long)(GetTickCount64()-t0)<(long)MathMax(100,InpBackfillBudgetMs))
     {
      more=false;
      for(int i=0;i<MBA_TF_COUNT;i++)
        {
         if(CatchUpOne(i)) more=true;
         if(TimeFwdOne(i)) more=true;
        }
     }
   if(g_rows_since_flush>=InpFlushEveryRows) FlushAll();
   if(InpQualityIntervalSec>0 && TimeTradeServer()-g_last_quality>=InpQualityIntervalSec) WriteQuality();
  }
