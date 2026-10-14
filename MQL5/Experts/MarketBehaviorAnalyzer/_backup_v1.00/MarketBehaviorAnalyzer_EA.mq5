//+------------------------------------------------------------------+
//| MarketBehaviorAnalyzer_EA.mq5                                    |
//| Multi-timeframe live market research collector                    |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property description "Non-trading multi-timeframe market behavior research collector."

#include "MBA_Core.mqh"

input string InpRootFolder             = "MarketBehaviorAnalyzer";
input bool   InpUseCommonFolder        = true;
input int    InpAnalysisTimezoneOffset = -3;          // server -> analysis time, fixed hours
input int    InpPartSizeMB             = 25;
input bool   InpWriteRawTicks          = true;
input bool   InpWriteTickAggregates    = true;
input bool   InpWriteEvents            = true;
input bool   InpWriteForward           = true;
input int    InpForwardMaxBars         = 10;
input int    InpATRPeriod               = 14;
input int    InpFeatureLookback         = 20;
input int    InpFlushEveryRows          = 100;
input bool   InpWriteDOM                = true;
input bool   InpWriteNewsContext        = true;

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

long g_part_bytes=25*1024*1024;
string g_run_id="";
string g_root="";
long g_rows_since_flush=0;

datetime g_last_bar[MBA_TF_COUNT];
datetime g_recent_bar_time[MBA_TF_COUNT][MBA_MAX_FORWARD+2];
string   g_recent_event_id[MBA_TF_COUNT][MBA_MAX_FORWARD+2];
double   g_recent_close[MBA_TF_COUNT][MBA_MAX_FORWARD+2];
long     g_recent_index_marker[MBA_TF_COUNT];

MBA_TickAgg g_live_m1_tick;
datetime g_live_m1_start=0;
double g_prev_tick_price=0;
bool g_has_prev_tick=false;
string g_news_seen[];

string ErrorText(int code){return StringFormat("ERR=%d",code);}

void LogError(string where,string detail)
  {
   string f[]; MBA_Add(f,g_run_id);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_Add(f,_Symbol);MBA_Add(f,where);MBA_Add(f,detail);MBA_AddL(f,GetLastError());
   g_errors.WriteFields(f);
  }

string BuildEventId(ENUM_TIMEFRAMES tf,datetime t)
  {
   return StringFormat("%s-%s-%s",MBA_SafeName(_Symbol),MBA_TFName(tf),TimeToString(t,TIME_DATE|TIME_MINUTES));
  }

void WriteRun()
  {
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,"LIVE");MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_Add(f,"0");MBA_Add(f,"0");MBA_AddL(f,InpAnalysisTimezoneOffset);MBA_AddL(f,InpPartSizeMB);MBA_Add(f,MBA_Bool(InpWriteRawTicks));MBA_Add(f,"FALSE");MBA_Add(f,"1.00");g_runs.WriteFields(f);g_runs.Flush();
  }

bool InitWriters()
  {
   g_root=InpRootFolder+"\\"+MBA_SafeName(_Symbol)+"\\LIVE";
   long mb=MathMax(1,InpPartSizeMB)*1024*1024;
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      string croot=g_root+"\\CANDLES";
      string eroot=g_root+"\\EVENTS";
      string froot=g_root+"\\FORWARD";
      string troot=g_root+"\\TICKS";
      g_candles[i].Init(croot,"candles_"+MBA_TFNames[i],MBA_CandleHeader(),mb,InpUseCommonFolder);
      g_events[i].Init(eroot,"events_"+MBA_TFNames[i],MBA_EventHeader(),mb,InpUseCommonFolder);
      g_forward[i].Init(froot,"forward_"+MBA_TFNames[i],MBA_ForwardHeader(),mb,InpUseCommonFolder);
      g_tickagg[i].Init(troot,"tick_aggregate_"+MBA_TFNames[i],MBA_TickAggHeader(),mb,InpUseCommonFolder);
      g_last_bar[i]=0;
     }
   g_rawticks.Init(g_root+"\\RAW_TICKS","raw_ticks", "run_id,symbol,time_msc,time,bid,ask,last,volume,volume_real,flags,spread_points,tick_direction,source", mb, InpUseCommonFolder);
   g_runs.Init(g_root+"\\RUNS","runs",MBA_RunHeader(),mb,InpUseCommonFolder);
   g_errors.Init(g_root+"\\LOGS","errors","run_id,time,symbol,where,detail,last_error",mb,InpUseCommonFolder);
   g_news.Init(g_root+"\\NEWS","news",MBA_NewsHeader(),mb,InpUseCommonFolder);
   g_dom_levels.Init(g_root+"\\DOM","dom_levels",MBA_DOMLevelHeader(),mb,InpUseCommonFolder);
   g_dom_snapshots.Init(g_root+"\\DOM","dom_snapshots",MBA_DOMSnapshotHeader(),mb,InpUseCommonFolder);
   return true;
  }

void FlushAll()
  {
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Flush();g_events[i].Flush();g_forward[i].Flush();g_tickagg[i].Flush();}
   g_rawticks.Flush();g_runs.Flush();g_errors.Flush();g_news.Flush();g_dom_levels.Flush();g_dom_snapshots.Flush();g_rows_since_flush=0;
  }

void WriteTickAggregateRow(ENUM_TIMEFRAMES tf,datetime from_time,datetime to_time,MBA_TickAgg &a,string source);


string NewsImpactName(ENUM_CALENDAR_EVENT_IMPACT impact)
  {
   switch(impact){case CALENDAR_IMPACT_POSITIVE:return "POSITIVE";case CALENDAR_IMPACT_NEGATIVE:return "NEGATIVE";default:return "NA";}
  }

bool NewsSeen(ulong id)
  {
   string k=MBA_UD(id);for(int i=0;i<ArraySize(g_news_seen);i++)if(g_news_seen[i]==k)return true;return false;
  }

void MarkNewsSeen(ulong id)
  {
   int n=ArraySize(g_news_seen);if(n<5000){ArrayResize(g_news_seen,n+1);g_news_seen[n]=MBA_UD(id);}
  }

void CaptureLiveNews(datetime t)
  {
   if(!InpWriteNewsContext)return;
   MqlCalendarValue vals[];int n=CalendarValueHistory(vals,t-60,t+60,NULL,NULL);if(n<=0)return;
   for(int i=0;i<n;i++)
     {
      if(NewsSeen(vals[i].id))continue;
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,MBA_UD(vals[i].event_id));MBA_Add(f,MBA_UD(vals[i].id));MBA_Add(f,MBA_DT(vals[i].time,true));MBA_Add(f,MBA_DT(vals[i].period,true));MBA_AddL(f,(long)vals[i].revision);MBA_AddL(f,vals[i].actual_value);MBA_AddL(f,vals[i].prev_value);MBA_AddL(f,vals[i].revised_prev_value);MBA_AddL(f,vals[i].forecast_value);MBA_Add(f,NewsImpactName(vals[i].impact_type));MBA_Add(f,"CALENDAR");g_news.WriteFields(f);MarkNewsSeen(vals[i].id);
     }
  }

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
   MqlBookInfo book[];if(!MarketBookGet(_Symbol,book))return;
   double best_bid=0,best_ask=0,total_bid=0,total_ask=0;int bid_levels=0,ask_levels=0;
   for(int i=0;i<ArraySize(book);i++)
     {
      string typ=DOMTypeName(book[i].type);
      if(book[i].type==BOOK_TYPE_BUY || book[i].type==BOOK_TYPE_BUY_MARKET){total_bid+=(book[i].volume_real>0?book[i].volume_real:(double)book[i].volume);bid_levels++;if(best_bid==0||book[i].price>best_bid)best_bid=book[i].price;}
      if(book[i].type==BOOK_TYPE_SELL || book[i].type==BOOK_TYPE_SELL_MARKET){total_ask+=(book[i].volume_real>0?book[i].volume_real:(double)book[i].volume);ask_levels++;if(best_ask==0||book[i].price<best_ask)best_ask=book[i].price;}
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_AddL(f,i);MBA_Add(f,typ);MBA_AddD(f,book[i].price,MBA_Digits());MBA_AddL(f,(long)book[i].volume);MBA_AddD(f,book[i].volume_real,6);MBA_Add(f,"LIVE_DOM");g_dom_levels.WriteFields(f);
     }
   double den=total_bid+total_ask;double imb=den>0?(total_bid-total_ask)/den:0;double spr=(best_bid>0&&best_ask>0)?(best_ask-best_bid)/_Point:0;
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_AddD(f,best_bid,MBA_Digits());MBA_AddD(f,best_ask,MBA_Digits());MBA_AddD(f,spr,2);MBA_AddD(f,total_bid,6);MBA_AddD(f,total_ask,6);MBA_AddD(f,imb,6);MBA_AddL(f,bid_levels+ask_levels);MBA_Add(f,"LIVE_DOM");g_dom_snapshots.WriteFields(f);
  }

void UpdateLiveM1TickAgg(const MqlTick &tk)
  {
   datetime minute=iTime(_Symbol,PERIOD_M1,0);
   if(minute<=0) return;
   if(g_live_m1_start==0) {g_live_m1_start=minute;MBA_ResetTickAgg(g_live_m1_tick);}
   if(minute!=g_live_m1_start)
     {
      if(InpWriteTickAggregates) WriteTickAggregateRow(PERIOD_M1,g_live_m1_start,minute-1,g_live_m1_tick,"LIVE_CAPTURE");
      g_live_m1_start=minute;MBA_ResetTickAgg(g_live_m1_tick);
     }
   double price=tk.last>0?tk.last:((tk.bid>0&&tk.ask>0)?(tk.bid+tk.ask)/2.0:tk.bid);
   MBA_AccumulateTick(g_live_m1_tick,tk,g_prev_tick_price,g_has_prev_tick);
   if(price>0){g_prev_tick_price=price;g_has_prev_tick=true;}
  }

void WriteRawTick(const MqlTick &tk)
  {
   if(!InpWriteRawTicks) return;
   double price=tk.last>0?tk.last:((tk.bid>0&&tk.ask>0)?(tk.bid+tk.ask)/2.0:tk.bid);
   int td=0;
   if(g_has_prev_tick){if(price>g_prev_tick_price)td=1;else if(price<g_prev_tick_price)td=-1;}
   double spread=(tk.bid>0&&tk.ask>0)?(tk.ask-tk.bid)/_Point:0;
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_AddU(f,tk.time_msc);MBA_Add(f,MBA_TimeMS(tk.time_msc));MBA_AddD(f,tk.bid,MBA_Digits());MBA_AddD(f,tk.ask,MBA_Digits());MBA_AddD(f,tk.last,MBA_Digits());MBA_AddL(f,(long)tk.volume);MBA_AddD(f,tk.volume_real,4);MBA_AddL(f,(long)tk.flags);MBA_AddD(f,spread,2);MBA_Add(f,IntegerToString(td));MBA_Add(f,"LIVE_CAPTURE");g_rawticks.WriteFields(f);
  }

void WriteTickAggregateRow(ENUM_TIMEFRAMES tf,datetime from_time,datetime to_time,MBA_TickAgg &a,string source)
  {
   int idx=MBA_TFIndex(tf); if(idx<0) return;
   string f[];MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(from_time,true));MBA_Add(f,MBA_DT(to_time,true));MBA_AddL(f,a.tick_count);MBA_AddL(f,a.up_ticks);MBA_AddL(f,a.down_ticks);MBA_AddL(f,a.unchanged_ticks);MBA_AddD(f,MBA_SafeRatio((double)a.up_ticks,(double)MathMax(1,a.up_ticks+a.down_ticks+a.unchanged_ticks)),6);MBA_AddD(f,MBA_SafeRatio((double)a.down_ticks,(double)MathMax(1,a.up_ticks+a.down_ticks+a.unchanged_ticks)),6);
   MBA_AddD(f,(a.bid_min==DBL_MAX?0:a.bid_min),MBA_Digits());MBA_AddD(f,(a.bid_max==-DBL_MAX?0:a.bid_max),MBA_Digits());MBA_AddD(f,(a.ask_min==DBL_MAX?0:a.ask_min),MBA_Digits());MBA_AddD(f,(a.ask_max==-DBL_MAX?0:a.ask_max),MBA_Digits());MBA_AddD(f,(a.last_min==DBL_MAX?0:a.last_min),MBA_Digits());MBA_AddD(f,(a.last_max==-DBL_MAX?0:a.last_max),MBA_Digits());MBA_AddD(f,(a.spread_min==DBL_MAX?0:a.spread_min),2);MBA_AddD(f,(a.spread_max==-DBL_MAX?0:a.spread_max),2);MBA_AddD(f,MBA_SafeRatio(a.spread_sum,(double)MathMax(1,a.tick_count)),2);MBA_AddD(f,MBA_SafeRatio(a.tick_interval_sum_ms,(double)MathMax(1,a.tick_interval_count)),2);
   double minutes=MathMax(1.0,(double)((to_time-from_time)+1)/60.0);MBA_AddD(f,(double)a.tick_count/minutes,4);MBA_Add(f,source);g_tickagg[idx].WriteFields(f);
  }

// Return prior/historical tick average reference for a candle. Uses tick volume when no usable tick history exists.
double HistoricalVolumeRatio(ENUM_TIMEFRAMES tf,int shift,const MqlRates &r)
  {
   MqlRates x[];int n=CopyRates(_Symbol,tf,shift+1,InpFeatureLookback,x);if(n<=0) return 1.0;double s=0;int c=0;for(int i=0;i<n;i++){s+=(double)x[i].tick_volume;c++;}return c>0?MBA_SafeRatio((double)r.tick_volume,s/c):1.0;
  }

string MTFStateLive(datetime event_time,ENUM_TIMEFRAMES tf)
  {
   MqlRates r[];int n=CopyRates(_Symbol,tf,0,InpFeatureLookback+50,r);if(n<=0)return "UNKNOWN";ArraySetAsSeries(r,true);
   // CopyRates with as_series=true: shift grows into past. Find the most recent bar that opened before the event.
   for(int s=1;s<n;s++) if(r[s].time<event_time) return MBA_StateFromRates(r, n-1-s, InpFeatureLookback);
   return "UNKNOWN";
  }

string GetMTFStateAtEvent(datetime event_time,ENUM_TIMEFRAMES tf)
  {
   MqlRates r[];int n=CopyRates(_Symbol,tf,0,InpFeatureLookback+60,r);if(n<=0)return "UNKNOWN";
   ArraySetAsSeries(r,false);
   int idx=MBA_FindIndexBefore(r,event_time);if(idx<1)return "UNKNOWN";
   return MBA_StateFromRates(r,idx,InpFeatureLookback);
  }

string GetDailyOpenDistance(double price)
  {
   double o=iOpen(_Symbol,PERIOD_D1,0);if(o==0)o=iOpen(_Symbol,PERIOD_D1,1);return MBA_D(o>0?(price-o)/_Point:0,2);
  }

string GetWeeklyOpenDistance(double price)
  {
   double o=iOpen(_Symbol,PERIOD_W1,0);if(o==0)o=iOpen(_Symbol,PERIOD_W1,1);return MBA_D(o>0?(price-o)/_Point:0,2);
  }

string GetMonthlyOpenDistance(double price)
  {
   double o=iOpen(_Symbol,PERIOD_MN1,0);if(o==0)o=iOpen(_Symbol,PERIOD_MN1,1);return MBA_D(o>0?(price-o)/_Point:0,2);
  }

void UpdateForwardQueue(int tfIndex)
  {
   if(!InpWriteForward) return;
   ENUM_TIMEFRAMES tf=MBA_TFs[tfIndex];
   MqlRates r[];int n=CopyRates(_Symbol,tf,0,InpForwardMaxBars+25,r);if(n<=0)return;ArraySetAsSeries(r,true);
   // Current latest closed bar is shift 1. An event with +H completed bars is at shift H+1.
   for(int h=1;h<=InpForwardMaxBars;h++)
     {
      int event_shift=h+1;
      if(event_shift>=n) break;
      datetime event_time=r[event_shift].time;
      string event_id=BuildEventId(tf,event_time);
      if(StringLen(event_id)==0) continue;
      double event_close=r[event_shift].close;
      int dir=MBA_Direction(r[event_shift]);
      double future_high=-DBL_MAX,future_low=DBL_MAX;
      int time_to_mfe=-1,time_to_mae=-1;
      double best_mfe=-DBL_MAX,best_mae=DBL_MAX;
      for(int k=1;k<=h;k++)
        {
         future_high=MathMax(future_high,r[k].high);
         future_low=MathMin(future_low,r[k].low);
         double fav=0,adv=0;
         if(dir>0){fav=(r[k].high-event_close)/_Point;adv=(r[k].low-event_close)/_Point;}
         else if(dir<0){fav=(event_close-r[k].low)/_Point;adv=(event_close-r[k].high)/_Point;}
         else {fav=MathMax(MathAbs(r[k].high-event_close),MathAbs(r[k].low-event_close))/_Point;adv=0;}
         if(fav>best_mfe){best_mfe=fav;time_to_mfe=k;}
         if(adv<best_mae){best_mae=adv;time_to_mae=k;}
        }
      double mfe=MathMax(0,best_mfe);double mae=(best_mae==DBL_MAX?0:best_mae);
      double future_close=r[1].close;
      double ret=(future_close-event_close)/_Point;
      int d=future_close>event_close?1:(future_close<event_close?-1:0);
      MqlRates all[];int na=CopyRates(_Symbol,tf,0,InpFeatureLookback+50,all);double atr=0;
      if(na>0){ArraySetAsSeries(all,false);int ai=MBA_FindIndexBefore(all,event_time);if(ai>=0)atr=MBA_ATRAt(all,ai,InpATRPeriod);}
      double ret_atr=atr>0?(future_close-event_close)/atr:0;
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,event_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(event_time,true));MBA_AddL(f,h);MBA_Add(f,MBA_DT(r[1].time,true));MBA_AddD(f,future_close,MBA_Digits());MBA_AddD(f,ret,2);MBA_AddD(f,ret_atr,6);MBA_AddD(f,future_high,MBA_Digits());MBA_AddD(f,future_low,MBA_Digits());MBA_AddD(f,mfe,2);MBA_AddD(f,mae,2);MBA_AddD(f,atr>0?mfe*_Point/atr:0,6);MBA_AddD(f,atr>0?mae*_Point/atr:0,6);MBA_AddL(f,time_to_mfe);MBA_AddL(f,time_to_mae);MBA_Add(f,MBA_Dir(d));MBA_Add(f,"LIVE_CAPTURE");g_forward[tfIndex].WriteFields(f);g_rows_since_flush++;
     }
  }

int MBA_DirectionFromPrice(double a,double b)
  {
   if(b>a)return 1;if(b<a)return -1;return 0;
  }

void RegisterRecentEvent(int tfIndex,datetime t,double close_price,string event_id)
  {
   for(int q=MBA_MAX_FORWARD;q>=1;q--)
     {
      g_recent_event_id[tfIndex][q]=g_recent_event_id[tfIndex][q-1];
      g_recent_bar_time[tfIndex][q]=g_recent_bar_time[tfIndex][q-1];
      g_recent_close[tfIndex][q]=g_recent_close[tfIndex][q-1];
     }
   g_recent_event_id[tfIndex][0]=event_id;g_recent_bar_time[tfIndex][0]=t;g_recent_close[tfIndex][0]=close_price;
  }

void ProcessClosedBar(int i)
  {
   ENUM_TIMEFRAMES tf=MBA_TFs[i];
   datetime t=iTime(_Symbol,tf,1);if(t<=0||t==g_last_bar[i])return;
   MqlRates r[];int n=CopyRates(_Symbol,tf,1,InpFeatureLookback+5,r);if(n<3){g_last_bar[i]=t;return;}ArraySetAsSeries(r,true);
   // series array: shift 0 == requested shift 1 (latest closed bar)
   MqlRates bar=r[0];
   double range=MBA_Range(bar),body=MBA_Body(bar),uw=MBA_UpperWick(bar),lw=MBA_LowerWick(bar);
   double atr=0; // get an explicit historical window in chronological order
   MqlRates rr[];int nr=CopyRates(_Symbol,tf,MathMax(0,bar.time-(InpFeatureLookback+5)*MathMax(60,PeriodSeconds(tf))),bar.time,rr);if(nr>1){ArraySetAsSeries(rr,false);atr=MBA_ATRAt(rr,nr-1,InpATRPeriod);}
   double vr=HistoricalVolumeRatio(tf,1,bar);
   MBA_TickAgg ta;datetime next_open=iTime(_Symbol,tf,0);datetime end=(next_open>bar.time?next_open-1:MBA_NextBarTime(bar.time,tf)-1);
   bool tickok=false;
   if(tf==PERIOD_M1 && bar.time<g_live_m1_start && g_live_m1_start>0)
     {
      // Historical M1 aggregate already written on minute transition; use server history query for the exact candle here only for robust persistence.
      tickok=MBA_CopyTickAggregate(_Symbol,bar.time,end,ta);
     }
   else tickok=MBA_CopyTickAggregate(_Symbol,bar.time,end,ta);
   if(InpWriteTickAggregates && tickok) WriteTickAggregateRow(tf,bar.time,end,ta,"LIVE_CAPTURE");

   double avg_tv=MBA_AvgTickVolumeAt(rr,nr-1,InpFeatureLookback);double tick_density=tickok?ta.tick_count/MathMax(1.0,(double)PeriodSeconds(tf)/60.0):0;double tick_density_ratio=tickok?MBA_SafeRatio((double)ta.tick_count,MathMax(1.0,avg_tv)):0;
   string pattern=MBA_Patterns(rr,nr-1);
   string structure=MBA_StructureState(rr,nr-1,InpFeatureLookback);
   string vol_state=MBA_VolatilityState(MBA_SafeRatio(range,atr));
   datetime at=MBA_AnalysisTime(t,InpAnalysisTimezoneOffset);
   string event_id=BuildEventId(tf,t);

   string f[];
   MBA_Add(f,g_run_id);MBA_Add(f,event_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(t,true));MBA_Add(f,MBA_DT(at,true));MBA_Add(f,MBA_DT(t+InpAnalysisTimezoneOffset*3600,true));MBA_Add(f,MBA_DayName(at));MBA_AddL(f,MBA_Hour(at));MBA_AddL(f,MBA_Minute(at));MBA_AddL(f,MBA_MinuteOfDay(at));MBA_Add(f,MBA_Session(at));MBA_AddD(f,bar.open,MBA_Digits());MBA_AddD(f,bar.high,MBA_Digits());MBA_AddD(f,bar.low,MBA_Digits());MBA_AddD(f,bar.close,MBA_Digits());MBA_AddD(f,range,2);MBA_AddD(f,body,2);MBA_AddD(f,uw,2);MBA_AddD(f,lw,2);MBA_AddD(f,MBA_SafeRatio(body,range),6);MBA_AddD(f,MBA_SafeRatio(uw,range),6);MBA_AddD(f,MBA_SafeRatio(lw,range),6);MBA_AddD(f,MBA_ClosePosition(bar),6);MBA_Add(f,MBA_Dir(MBA_Direction(bar)));double prev_close=(nr>=2?rr[nr-2].close:bar.open);double true_range=MathMax(range,MathMax(MathAbs(bar.high-prev_close),MathAbs(bar.low-prev_close)));MBA_AddD(f,true_range,2);MBA_AddD(f,atr,2);MBA_AddD(f,MBA_SafeRatio(range,atr),6);MBA_AddL(f,(long)bar.tick_volume);MBA_AddD(f,(double)bar.real_volume,4);MBA_AddD(f,MBA_AvgTickVolumeAt(rr,nr-1,InpFeatureLookback),2);MBA_AddD(f,vr,6);MBA_AddL(f,tickok?ta.tick_count:0);MBA_AddD(f,tick_density,4);MBA_AddD(f,tick_density_ratio,4);MBA_AddD(f,tickok?MBA_SafeRatio(ta.spread_sum,(double)MathMax(1,ta.tick_count)):0,2);MBA_AddD(f,tickok?ta.spread_max:0,2);MBA_AddD(f,tickok?ta.spread_min:0,2);MBA_Add(f,MBA_BucketRatio(MBA_SafeRatio(range,atr)));MBA_Add(f,MBA_BucketPct(MBA_SafeRatio(body,range)));MBA_Add(f,MBA_BucketVolume(vr));MBA_Add(f,pattern);MBA_Add(f,structure);MBA_Add(f,vol_state);MBA_Add(f,"LIVE_CAPTURE");
   g_candles[i].WriteFields(f);

   string states[8];
   for(int s=0;s<8;s++) states[s]=GetMTFStateAtEvent(t,MBA_TFs[s]);
   string ef[];MBA_Add(ef,g_run_id);MBA_Add(ef,event_id);MBA_Add(ef,_Symbol);MBA_Add(ef,MBA_TFName(tf));MBA_Add(ef,MBA_DT(t,true));MBA_Add(ef,MBA_DT(at,true));MBA_Add(ef,MBA_DayName(at));MBA_AddL(ef,MBA_Hour(at));MBA_AddL(ef,MBA_Minute(at));MBA_Add(ef,MBA_Session(at));MBA_Add(ef,MBA_Dir(MBA_Direction(bar)));MBA_AddD(ef,MBA_SafeRatio(body,range),6);MBA_AddD(ef,MBA_SafeRatio(uw,range),6);MBA_AddD(ef,MBA_SafeRatio(lw,range),6);MBA_AddD(ef,MBA_ClosePosition(bar),6);MBA_AddD(ef,MBA_SafeRatio(range,atr),6);MBA_AddD(ef,vr,6);MBA_AddD(ef,tick_density_ratio,6);MBA_AddD(ef,tickok?MBA_SafeRatio(ta.spread_sum,(double)MathMax(1,ta.tick_count)):0,2);MBA_Add(ef,pattern);MBA_Add(ef,structure);MBA_Add(ef,vol_state);MBA_Add(ef,GetDailyOpenDistance(bar.close));MBA_Add(ef,GetWeeklyOpenDistance(bar.close));MBA_Add(ef,GetMonthlyOpenDistance(bar.close));double ph=rr[0].high,pl=rr[0].low;for(int j=0;j<nr-1;j++){ph=MathMax(ph,rr[j].high);pl=MathMin(pl,rr[j].low);}MBA_AddD(ef,atr>0?(bar.close-ph)/atr:0,6);MBA_AddD(ef,atr>0?(bar.close-pl)/atr:0,6);for(int s=0;s<8;s++)MBA_Add(ef,states[s]);MBA_Add(ef,InpWriteNewsContext?"CALENDAR_AVAILABLE":"DISABLED");MBA_Add(ef,"LIVE_CAPTURE");
   if(InpWriteEvents)g_events[i].WriteFields(ef);

   RegisterRecentEvent(i,t,bar.close,event_id);
   g_last_bar[i]=t;
   g_rows_since_flush++;
   if(g_rows_since_flush>=InpFlushEveryRows)FlushAll();
  }

int OnInit()
  {
   g_run_id=StringFormat("LIVE_%s_%s",MBA_SafeName(_Symbol),TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   if(!InitWriters())return INIT_FAILED;
   WriteRun();
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      g_last_bar[i]=iTime(_Symbol,MBA_TFs[i],1);
      for(int q=0;q<=MBA_MAX_FORWARD+1;q++){g_recent_event_id[i][q]="";g_recent_bar_time[i][q]=0;g_recent_close[i][q]=0;}
     }
   MBA_ResetTickAgg(g_live_m1_tick);
   ArrayResize(g_news_seen,0);
   if(InpWriteDOM)MarketBookAdd(_Symbol);
   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(InpWriteDOM)MarketBookRelease(_Symbol);
   if(g_live_m1_start>0 && g_live_m1_tick.tick_count>0 && InpWriteTickAggregates)
      WriteTickAggregateRow(PERIOD_M1,g_live_m1_start,TimeCurrent(),g_live_m1_tick,"LIVE_CAPTURE");
   FlushAll();
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Close();g_events[i].Close();g_forward[i].Close();g_tickagg[i].Close();}
   g_rawticks.Close();g_runs.Close();g_errors.Close();g_news.Close();g_dom_levels.Close();g_dom_snapshots.Close();
  }

void OnBookEvent(const string &symbol)
  {
   CaptureDOM(symbol);
  }

void OnTick()
  {
   MqlTick tk;if(!SymbolInfoTick(_Symbol,tk))return;
   if(InpWriteRawTicks)WriteRawTick(tk);
   UpdateLiveM1TickAgg(tk);
   if(g_has_prev_tick)
     {
      double p=tk.last>0?tk.last:((tk.bid>0&&tk.ask>0)?(tk.bid+tk.ask)/2.0:tk.bid);
      if(p>0){g_prev_tick_price=p;g_has_prev_tick=true;}
     }
  }

void OnTimer()
  {
   CaptureLiveNews(TimeCurrent());
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      ProcessClosedBar(i);
      if(InpWriteForward)UpdateForwardQueue(i);
     }
   if(g_rows_since_flush>=InpFlushEveryRows)FlushAll();
  }
