//+------------------------------------------------------------------+
//| MarketBehaviorAnalyzer_EA.mq5                                    |
//| Multi-timeframe live market research collector (non-trading)     |
//|                                                                  |
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
#property version   "1.22"
#property description "Non-trading multi-timeframe market behavior research collector."

#include "MBA_Core.mqh"

input string InpRootFolder             = "MarketBehaviorAnalyzer";
input bool   InpUseCommonFolder        = true;
input int    InpAnalysisTimezoneOffset = -3;          // fallback only: server->UTC hours when InpUseDynamicUTC=false
input int    InpPartSizeMB             = 25;
input bool   InpWriteRawTicks          = true;
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
input bool   InpBrokerFolder            = true;       // root\<broker>\<symbol>\LIVE (avoids two terminals mixing the same symbol)
input int    InpMaxCatchupBars          = 200000;     // sanity cap of bars back-filled per timeframe in one go
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

#define MBA_TC_MAX 40

CMBAWriter g_candles[MBA_TF_COUNT];
CMBAWriter g_events[MBA_TF_COUNT];
CMBAWriter g_forward[MBA_TF_COUNT];
CMBAWriter g_tickagg[MBA_TF_COUNT];
CMBAWriter g_rawticks;
CMBAWriter g_runs;
CMBAWriter g_errors;
CMBAWriter g_news;
CMBAWriter g_dom_levels;
CMBAWriter g_dom_snapshots;
CMBAWriter g_spec;
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
   string inputs=StringFormat("dynUTC=%s;lookback=%d;atr=%d;fwd=%d;rawticks=%s;dom=%s;news=%s/%d",MBA_Bool(InpUseDynamicUTC),InpFeatureLookback,InpATRPeriod,InpForwardMaxBars,MBA_Bool(InpWriteRawTicks),MBA_Bool(InpWriteDOM),InpNewsCurrencies,InpNewsMinImportance);
   MBA_FillSpecRow(f,g_run_id,InpCommissionPerLotDeclared,inputs);
   g_spec.WriteFields(f);g_spec.Flush();
  }

bool InitWriters()
  {
   string base=InpRootFolder;
   if(InpBrokerFolder) base+="\\"+g_broker;
   g_root=base+"\\"+MBA_SafeName(_Symbol)+"\\LIVE";
   long mb=MathMax(1,InpPartSizeMB)*1024*1024;
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      g_candles[i].Init(g_root+"\\CANDLES","candles_"+MBA_TFNames[i],MBA_CandleHeader(),mb,InpUseCommonFolder);
      g_events[i].Init(g_root+"\\EVENTS","events_"+MBA_TFNames[i],MBA_EventHeader(),mb,InpUseCommonFolder);
      g_forward[i].Init(g_root+"\\FORWARD","forward_"+MBA_TFNames[i],MBA_ForwardHeader(),mb,InpUseCommonFolder);
      g_tickagg[i].Init(g_root+"\\TICKS","tick_aggregate_"+MBA_TFNames[i],MBA_TickAggHeader(),mb,InpUseCommonFolder);
      g_last_bar[i]=0;g_tc_cnt[i]=0;g_tc_seeded[i]=false;g_bf_first[i]=0;g_bf_wait[i]=false;g_bf_t0[i]=0;g_bf_total[i]=-1;g_bf_stable[i]=0;
     }
   g_rawticks.Init(g_root+"\\RAW_TICKS","raw_ticks","run_id,symbol,time_msc,time,bid,ask,last,volume,volume_real,flags,spread_points,tick_direction,source",mb,InpUseCommonFolder);
   g_runs.Init(g_root+"\\RUNS","runs",MBA_RunHeader(),mb,InpUseCommonFolder);
   g_errors.Init(g_root+"\\LOGS","errors","run_id,time,symbol,where,detail,last_error",mb,InpUseCommonFolder);
   g_news.Init(g_root+"\\NEWS","news",MBA_NewsHeader(),mb,InpUseCommonFolder);
   g_dom_levels.Init(g_root+"\\DOM","dom_levels",MBA_DOMLevelHeader(),mb,InpUseCommonFolder);
   g_dom_snapshots.Init(g_root+"\\DOM","dom_snapshots",MBA_DOMSnapshotHeader(),mb,InpUseCommonFolder);
   g_spec.Init(g_root+"\\META","symbol_spec",MBA_SpecHeader(),mb,InpUseCommonFolder);
   return true;
  }

void FlushAll()
  {
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Flush();g_events[i].Flush();g_forward[i].Flush();g_tickagg[i].Flush();}
   g_rawticks.Flush();g_runs.Flush();g_errors.Flush();g_news.Flush();g_dom_levels.Flush();g_dom_snapshots.Flush();g_spec.Flush();g_rows_since_flush=0;
  }

//+------------------------------------------------------------------+
//| Tick aggregates                                                  |
//+------------------------------------------------------------------+
void WriteTickAggregateRow(ENUM_TIMEFRAMES tf,datetime from_time,datetime to_time,MBA_TickAgg &a,string source)
  {
   int idx=MBA_TFIndex(tf); if(idx<0) return;
   long den=MathMax(1,a.up_ticks+a.down_ticks+a.unchanged_ticks);
   string f[];MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(from_time,true));MBA_Add(f,MBA_DT(to_time,true));MBA_AddL(f,a.tick_count);MBA_AddL(f,a.up_ticks);MBA_AddL(f,a.down_ticks);MBA_AddL(f,a.unchanged_ticks);
   MBA_AddD(f,MBA_SafeRatio((double)a.up_ticks,(double)den),6);MBA_AddD(f,MBA_SafeRatio((double)a.down_ticks,(double)den),6);
   MBA_AddD(f,(a.bid_min==DBL_MAX?0:a.bid_min),MBA_Digits());MBA_AddD(f,(a.bid_max==-DBL_MAX?0:a.bid_max),MBA_Digits());MBA_AddD(f,(a.ask_min==DBL_MAX?0:a.ask_min),MBA_Digits());MBA_AddD(f,(a.ask_max==-DBL_MAX?0:a.ask_max),MBA_Digits());
   MBA_AddD(f,(a.last_min==DBL_MAX?0:a.last_min),MBA_Digits());MBA_AddD(f,(a.last_max==-DBL_MAX?0:a.last_max),MBA_Digits());
   MBA_AddD(f,(a.spread_min==DBL_MAX?0:a.spread_min),2);MBA_AddD(f,(a.spread_max==-DBL_MAX?0:a.spread_max),2);
   MBA_AddD(f,MBA_SafeRatio(a.spread_sum,(double)MathMax(1,a.tick_count)),2);MBA_AddD(f,MBA_SafeRatio(a.tick_interval_sum_ms,(double)MathMax(1,a.tick_interval_count)),2);
   double minutes=MathMax(1.0,(double)((to_time-from_time)+1)/60.0);MBA_AddD(f,(double)a.tick_count/minutes,4);MBA_Add(f,source);
   g_tickagg[idx].WriteFields(f);
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
int WriteCalendarRange(datetime from,datetime to,string source)
  {
   string cur[];int nc=0,written=0;
   if(StringLen(InpNewsCurrencies)>0) nc=StringSplit(InpNewsCurrencies,',',cur);
   int off=InpUseDynamicUTC?MBA_ServerOffsetSec():-InpAnalysisTimezoneOffset*3600;
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
//| Raw ticks                                                        |
//+------------------------------------------------------------------+
void WriteRawTick(const MqlTick &tk)
  {
   double price=tk.last>0?tk.last:((tk.bid>0&&tk.ask>0)?(tk.bid+tk.ask)/2.0:tk.bid);
   int td=0;
   if(g_has_prev_tick){if(price>g_prev_tick_price)td=1;else if(price<g_prev_tick_price)td=-1;}
   if(price>0){g_prev_tick_price=price;g_has_prev_tick=true;}
   if(!InpWriteRawTicks) return;
   double spread=(tk.bid>0&&tk.ask>0)?(tk.ask-tk.bid)/_Point:0;
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_AddU(f,tk.time_msc);MBA_Add(f,MBA_TimeMS(tk.time_msc));MBA_AddD(f,tk.bid,MBA_Digits());MBA_AddD(f,tk.ask,MBA_Digits());MBA_AddD(f,tk.last,MBA_Digits());MBA_AddL(f,(long)tk.volume);MBA_AddD(f,tk.volume_real,4);MBA_AddL(f,(long)tk.flags);MBA_AddD(f,spread,2);MBA_Add(f,IntegerToString(td));MBA_Add(f,"LIVE_CAPTURE");
   g_rawticks.WriteFields(f);
  }

//+------------------------------------------------------------------+
//| Forward: one row per (event, horizon), written when the horizon |
//| bar closes. rr[nr-1] is the horizon bar.                         |
//+------------------------------------------------------------------+
void WriteForwardForClosedBar(int tfIndex,const MqlRates &rr[],int nr,string source)
  {
   if(!InpWriteForward) return;
   ENUM_TIMEFRAMES tf=MBA_TFs[tfIndex];
   int hmax=MathMin(InpForwardMaxBars,MBA_MAX_FORWARD);
   const MqlRates fb=rr[nr-1];
   for(int h=1;h<=hmax;h++)
     {
      int ei=nr-1-h;
      if(ei<1) break;
      double event_close=rr[ei].close;
      int dir=MBA_Direction(rr[ei]);
      double future_high=-DBL_MAX,future_low=DBL_MAX,best_mfe=-DBL_MAX,best_mae=DBL_MAX;
      int t_mfe=-1,t_mae=-1;
      for(int k=1;k<=h;k++)
        {
         const MqlRates b=rr[ei+k];
         future_high=MathMax(future_high,b.high);future_low=MathMin(future_low,b.low);
         double fav=0,adv=0;
         if(dir>0){fav=(b.high-event_close)/_Point;adv=(b.low-event_close)/_Point;}
         else if(dir<0){fav=(event_close-b.low)/_Point;adv=(event_close-b.high)/_Point;}
         else {fav=MathMax(MathAbs(b.high-event_close),MathAbs(b.low-event_close))/_Point;adv=0;}
         if(fav>best_mfe){best_mfe=fav;t_mfe=k;}
         if(adv<best_mae){best_mae=adv;t_mae=k;}
        }
      double mfe=MathMax(0,best_mfe);double mae=(best_mae==DBL_MAX?0:best_mae);
      double fc=fb.close;double ret=(fc-event_close)/_Point;
      int d=fc>event_close?1:(fc<event_close?-1:0);
      double atr=MBA_ATRAt(rr,ei,InpATRPeriod);
      string ekey=BuildEventKey(tf,rr[ei].time);
      string f[];
      MBA_Add(f,g_run_id);MBA_Add(f,ekey+"|"+IntegerToString(h));MBA_Add(f,ekey);MBA_Add(f,BuildEventId(tf,rr[ei].time));
      MBA_Add(f,g_broker);MBA_Add(f,g_server);MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,"LIVE");
      MBA_Add(f,MBA_DT(rr[ei].time,true));MBA_AddL(f,h);MBA_Add(f,MBA_DT(fb.time,true));MBA_AddD(f,fc,MBA_Digits());
      MBA_AddD(f,ret,2);MBA_AddD(f,atr>0?(fc-event_close)/atr:0,6);MBA_AddD(f,future_high,MBA_Digits());MBA_AddD(f,future_low,MBA_Digits());
      MBA_AddD(f,mfe,2);MBA_AddD(f,mae,2);MBA_AddD(f,atr>0?mfe*_Point/atr:0,6);MBA_AddD(f,atr>0?mae*_Point/atr:0,6);
      MBA_AddL(f,t_mfe);MBA_AddL(f,t_mae);MBA_Add(f,MBA_Dir(d));MBA_Add(f,"EVENT_CANDLE_DIRECTION");MBA_Add(f,source);MBA_Add(f,MBA_SCHEMA_VERSION);
      g_forward[tfIndex].WriteFields(f);g_rows_since_flush++;
     }
  }

//+------------------------------------------------------------------+
//| Process one closed bar (live or back-fill)                       |
//+------------------------------------------------------------------+
bool ProcessBar(int i,int shift,string source)
  {
   ENUM_TIMEFRAMES tf=MBA_TFs[i];
   datetime t=iTime(_Symbol,tf,shift);
   if(t<=0) return false;
   int want=MathMax(InpFeatureLookback+5,120);
   MqlRates rr[];
   int nr=CopyRates(_Symbol,tf,shift,want,rr);
   if(nr<3 || rr[nr-1].time!=t){g_last_bar[i]=t;LogError("ProcessBar",MBA_TFName(tf)+" rates unavailable "+TimeToString(t));return false;}
   int idx=nr-1;
   MBA_BarCtx c;
   c.run_id=g_run_id;c.symbol=_Symbol;c.tf_name=MBA_TFName(tf);c.source=source;c.broker=g_broker;c.server=g_server;c.data_source="LIVE";
   c.bar=rr[idx];c.server_time=t;
   c.event_id=BuildEventId(tf,t);c.event_key=BuildEventKey(tf,t);
   // ---- time basis
   int off=0;
   if(InpUseDynamicUTC){off=MBA_ServerOffsetSec();c.utc_basis=(source=="LIVE_CAPTURE"?"LIVE_CLOCK_OFFSET":"BACKFILL_ASSUMES_CURRENT_OFFSET");}
   else {off=-InpAnalysisTimezoneOffset*3600;c.utc_basis="FIXED_INPUT";}
   c.utc_offset_sec=off;c.utc_time=t-(datetime)off;c.analysis_time=c.utc_time;
   // ---- geometry
   c.range=MBA_Range(c.bar);c.body=MBA_Body(c.bar);c.uw=MBA_UpperWick(c.bar);c.lw=MBA_LowerWick(c.bar);
   double prev_close=rr[idx-1].close;
   c.true_range=MathMax(c.range,MathMax(MathAbs(c.bar.high-prev_close),MathAbs(c.bar.low-prev_close)));
   c.atr=MBA_ATRAt(rr,idx,InpATRPeriod);
   c.avg_tv=MBA_AvgTickVolumeAt(rr,idx,InpFeatureLookback);
   c.vr=c.avg_tv>0?(double)c.bar.tick_volume/c.avg_tv:1.0;
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
   if(c.tick_ok)
     {
      if(InpWriteTickAggregates) WriteTickAggregateRow(tf,t,end,ta,source);
      PushTickCount(i,ta.tick_count);
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
   for(int s=0;s<8;s++)
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
   // ---- write
   string f[];
   MBA_FillCandleRow(f,c);g_candles[i].WriteFields(f);
   if(InpWriteEvents){MBA_FillEventRow(f,c);g_events[i].WriteFields(f);}
   WriteForwardForClosedBar(i,rr,nr,source);
   g_last_bar[i]=t;
   g_rows_since_flush++;
   return true;
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
   if(g_bf_first[i]>0)
     {
      int sh0=iBarShift(_Symbol,tf,g_bf_first[i],true);
      g_bf_first[i]=0;
      if(sh0>=1){ProcessBar(i,sh0,(sh0==1)?"LIVE_CAPTURE":"BACKFILL_SERVER");return sh0>1;}
     }
   datetime latest=iTime(_Symbol,tf,1);
   if(latest<=0 || latest<=g_last_bar[i]) return false;
   int shift=1;
   if(g_last_bar[i]>0)
     {
      int sh=iBarShift(_Symbol,tf,g_last_bar[i],true);
      if(sh>1) shift=MathMin(sh-1,MathMax(1,InpMaxCatchupBars));
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
   if(!InitWriters())return INIT_FAILED;
   WriteRun();
   WriteSpec();
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
   if(InpWriteDOM)MarketBookAdd(_Symbol);
   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(InpWriteDOM)MarketBookRelease(_Symbol);
   FlushAll();
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Close();g_events[i].Close();g_forward[i].Close();g_tickagg[i].Close();}
   g_rawticks.Close();g_runs.Close();g_errors.Close();g_news.Close();g_dom_levels.Close();g_dom_snapshots.Close();g_spec.Close();
  }

void OnBookEvent(const string &symbol)
  {
   CaptureDOM(symbol);
  }

void OnTick()
  {
   MqlTick tk;if(!SymbolInfoTick(_Symbol,tk))return;
   WriteRawTick(tk);
  }

void OnTimer()
  {
   RefreshCalendarWindow();
   CaptureLiveNews();
   // round-robin, one bar per timeframe per pass, within a time budget
   ulong t0=GetTickCount64();
   bool more=true;
   while(more && (long)(GetTickCount64()-t0)<(long)MathMax(100,InpBackfillBudgetMs))
     {
      more=false;
      for(int i=0;i<MBA_TF_COUNT;i++) if(CatchUpOne(i)) more=true;
     }
   if(g_rows_since_flush>=InpFlushEveryRows) FlushAll();
  }
