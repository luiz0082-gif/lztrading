//+------------------------------------------------------------------+
//| MarketBehaviorAnalyzer_History.mq5                               |
//| Historical reconstruction + statistics + discovery engine         |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property description "Historical market behavior research processor. Non-trading."

#include "MBA_Core.mqh"

input string InpRootFolder             = "MarketBehaviorAnalyzer";
input bool   InpUseCommonFolder        = true;
input int    InpAnalysisTimezoneOffset = -3;
input int    InpPartSizeMB             = 25;
input int    InpHistoryDays             = 90;          // 0 = use dates below
input datetime InpStartDate             = D'2026.01.01 00:00:00';
input datetime InpEndDate               = D'2026.10.01 23:59:59';
input bool   InpUseDateInputs            = false;
input bool   InpWriteTickAggregates      = true;
input bool   InpWriteHistoricalRawTicks  = false;      // Can become enormous.
input bool   InpBuildNewsContext         = true;
input int    InpATRPeriod                = 14;
input int    InpFeatureLookback          = 20;
input int    InpForwardMaxBars           = 10;
input int    InpDiscoveryMaxGroups       = 60000;
input int    InpFlushEveryRows           = 5000;

CMBAWriter g_candles[MBA_TF_COUNT];
CMBAWriter g_events[MBA_TF_COUNT];
CMBAWriter g_forward[MBA_TF_COUNT];
CMBAWriter g_tickagg[MBA_TF_COUNT];
CMBAWriter g_rawticks;
CMBAWriter g_runs;
CMBAWriter g_errors;
CMBAWriter g_hourly;
CMBAWriter g_dayhour;
CMBAWriter g_patterns;
CMBAWriter g_discovery;
CMBAWriter g_integrity;
CMBAWriter g_news;

string g_run_id="";
string g_root="";
long g_rows_since_flush=0;
long g_total_events=0;

// Fixed-size direct statistics: TF x minute-of-day and TF x day-of-week x minute.
MBA_Stat g_hour_stats[MBA_TF_COUNT*1440];
MBA_Stat g_dayhour_stats[MBA_TF_COUNT*7*1440];

// Pattern table (known set, deliberately explicit for repeatability).
string g_pattern_names[]=
  {"DOJI","HAMMER","INVERTED_HAMMER","SHOOTING_STAR","HANGING_MAN","BULLISH_ENGULFING","BEARISH_ENGULFING","INSIDE_BAR","OUTSIDE_BAR","PIN_BAR","MARUBOZU","HARAMI","TWEEZER_TOP","TWEEZER_BOTTOM","MORNING_STAR_3BAR","EVENING_STAR_3BAR"};
MBA_Stat g_pattern_stats[MBA_TF_COUNT*16*1440];

// Open-addressed discovery table.
string g_disc_keys[];
long g_disc_n[];
long g_disc_up[];
long g_disc_down[];
double g_disc_mfe[];
double g_disc_mae[];
double g_disc_body[];
double g_disc_range[];
double g_disc_vol[];
ulong g_disc_hash[];
int g_disc_capacity=0;
int g_disc_used=0;

string BuildEventId(ENUM_TIMEFRAMES tf,datetime t)
  { return StringFormat("%s-%s-%s",MBA_SafeName(_Symbol),MBA_TFName(tf),TimeToString(t,TIME_DATE|TIME_MINUTES)); }

string DayHourKey(int tfIndex,datetime analysis_time)
  {
   return MBA_TFNames[tfIndex]+"|"+IntegerToString(MBA_DayOfWeek(analysis_time))+"|"+IntegerToString(MBA_MinuteOfDay(analysis_time));
  }

void InitStat(MBA_Stat &s)
  {
   s.n=0;s.bull=0;s.bear=0;s.doji=0;s.range_sum=0;s.range_sq_sum=0;s.body_sum=0;s.volume_sum=0;s.volume_ratio_sum=0;s.tick_density_sum=0;s.spread_sum=0;s.forward_up=0;s.forward_down=0;s.mfe_sum=0;s.mae_sum=0;
  }

void ResetStats()
  {
   int n=ArraySize(g_hour_stats);for(int i=0;i<n;i++)InitStat(g_hour_stats[i]);
   n=ArraySize(g_dayhour_stats);for(int i=0;i<n;i++)InitStat(g_dayhour_stats[i]);
   n=ArraySize(g_pattern_stats);for(int i=0;i<n;i++)InitStat(g_pattern_stats[i]);
  }

ulong MBA_Hash(string s)
  {
   ulong h=1469598103934665603ULL;
   int n=StringLen(s);
   for(int i=0;i<n;i++){ushort c=StringGetCharacter(s,i);h^=(ulong)c;h*=1099511628211ULL;}
   return h;
  }

void InitDiscoveryTable()
  {
   g_disc_capacity=1;while(g_disc_capacity<InpDiscoveryMaxGroups*2)g_disc_capacity*=2;
   ArrayResize(g_disc_keys,g_disc_capacity);ArrayResize(g_disc_n,g_disc_capacity);ArrayResize(g_disc_up,g_disc_capacity);ArrayResize(g_disc_down,g_disc_capacity);ArrayResize(g_disc_mfe,g_disc_capacity);ArrayResize(g_disc_mae,g_disc_capacity);ArrayResize(g_disc_body,g_disc_capacity);ArrayResize(g_disc_range,g_disc_capacity);ArrayResize(g_disc_vol,g_disc_capacity);ArrayResize(g_disc_hash,g_disc_capacity);
   for(int i=0;i<g_disc_capacity;i++){g_disc_keys[i]="";g_disc_n[i]=0;g_disc_up[i]=0;g_disc_down[i]=0;g_disc_mfe[i]=0;g_disc_mae[i]=0;g_disc_body[i]=0;g_disc_range[i]=0;g_disc_vol[i]=0;g_disc_hash[i]=0;}
   g_disc_used=0;
  }

int DiscSlot(string key)
  {
   ulong h=MBA_Hash(key);int mask=g_disc_capacity-1;int p=(int)(h&(ulong)mask);
   for(int tries=0;tries<g_disc_capacity;tries++)
     {
      if(g_disc_keys[p]=="" || (g_disc_hash[p]==h && g_disc_keys[p]==key)) return p;
      p=(p+1)&mask;
     }
   return -1;
  }

void UpdateDiscovery(string key,double body,double range,double vol_ratio,int forward_dir,double mfe,double mae)
  {
   if(g_disc_used>=InpDiscoveryMaxGroups)return;
   int p=DiscSlot(key);if(p<0)return;
   if(g_disc_keys[p]==""){g_disc_keys[p]=key;g_disc_hash[p]=MBA_Hash(key);g_disc_used++;}
   g_disc_n[p]++;if(forward_dir>0)g_disc_up[p]++;else if(forward_dir<0)g_disc_down[p]++;g_disc_mfe[p]+=mfe;g_disc_mae[p]+=mae;g_disc_body[p]+=body;g_disc_range[p]+=range;g_disc_vol[p]+=vol_ratio;
  }


void WriteTickAggregateRow(ENUM_TIMEFRAMES tf,datetime from_time,datetime to_time,MBA_TickAgg &a,string source)
  {
   int idx=MBA_TFIndex(tf);if(idx<0)return;
   string f[];MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(from_time,true));MBA_Add(f,MBA_DT(to_time,true));MBA_AddL(f,a.tick_count);MBA_AddL(f,a.up_ticks);MBA_AddL(f,a.down_ticks);MBA_AddL(f,a.unchanged_ticks);long den=MathMax(1,a.up_ticks+a.down_ticks+a.unchanged_ticks);MBA_AddD(f,MBA_SafeRatio((double)a.up_ticks,(double)den),6);MBA_AddD(f,MBA_SafeRatio((double)a.down_ticks,(double)den),6);MBA_AddD(f,a.bid_min==DBL_MAX?0:a.bid_min,MBA_Digits());MBA_AddD(f,a.bid_max==-DBL_MAX?0:a.bid_max,MBA_Digits());MBA_AddD(f,a.ask_min==DBL_MAX?0:a.ask_min,MBA_Digits());MBA_AddD(f,a.ask_max==-DBL_MAX?0:a.ask_max,MBA_Digits());MBA_AddD(f,a.last_min==DBL_MAX?0:a.last_min,MBA_Digits());MBA_AddD(f,a.last_max==-DBL_MAX?0:a.last_max,MBA_Digits());MBA_AddD(f,a.spread_min==DBL_MAX?0:a.spread_min,2);MBA_AddD(f,a.spread_max==-DBL_MAX?0:a.spread_max,2);MBA_AddD(f,MBA_SafeRatio(a.spread_sum,(double)MathMax(1,a.tick_count)),2);MBA_AddD(f,MBA_SafeRatio(a.tick_interval_sum_ms,(double)MathMax(1,a.tick_interval_count)),2);double minutes=MathMax(1.0,(double)((to_time-from_time)+1)/60.0);MBA_AddD(f,(double)a.tick_count/minutes,4);MBA_Add(f,source);g_tickagg[idx].WriteFields(f);
  }

int FindIndexAtOrBefore(const MqlRates &rates[],datetime t)
  {
   int n=ArraySize(rates);int lo=0,hi=n-1,best=-1;
   while(lo<=hi){int mid=(lo+hi)/2;if(rates[mid].time<=t){best=mid;lo=mid+1;}else hi=mid-1;}
   return best;
  }

double OpenAtOrBefore(const MqlRates &rates[],datetime t)
  {
   int idx=FindIndexAtOrBefore(rates,t);return idx>=0?rates[idx].open:0.0;
  }

void LogError(string where,string detail)
  {
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_Add(f,_Symbol);MBA_Add(f,where);MBA_Add(f,detail);MBA_AddL(f,GetLastError());g_errors.WriteFields(f);
  }

void FlushAll()
  {
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Flush();g_events[i].Flush();g_forward[i].Flush();g_tickagg[i].Flush();}
   g_rawticks.Flush();g_runs.Flush();g_errors.Flush();g_hourly.Flush();g_dayhour.Flush();g_patterns.Flush();g_discovery.Flush();g_integrity.Flush();g_news.Flush();g_rows_since_flush=0;
  }

bool InitWriters()
  {
   g_root=InpRootFolder+"\\"+MBA_SafeName(_Symbol)+"\\HISTORY\\"+g_run_id;
   long mb=MathMax(1,InpPartSizeMB)*1024*1024;
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      g_candles[i].Init(g_root+"\\CANDLES","candles_"+MBA_TFNames[i],MBA_CandleHeader(),mb,InpUseCommonFolder);
      g_events[i].Init(g_root+"\\EVENTS","events_"+MBA_TFNames[i],MBA_EventHeader(),mb,InpUseCommonFolder);
      g_forward[i].Init(g_root+"\\FORWARD","forward_"+MBA_TFNames[i],MBA_ForwardHeader(),mb,InpUseCommonFolder);
      g_tickagg[i].Init(g_root+"\\TICKS","tick_aggregate_"+MBA_TFNames[i],MBA_TickAggHeader(),mb,InpUseCommonFolder);
     }
   g_rawticks.Init(g_root+"\\RAW_TICKS","raw_ticks","run_id,symbol,time_msc,time,bid,ask,last,volume,volume_real,flags,spread_points,tick_direction,source",mb,InpUseCommonFolder);
   g_runs.Init(g_root+"\\RUNS","runs",MBA_RunHeader(),mb,InpUseCommonFolder);
   g_errors.Init(g_root+"\\LOGS","errors","run_id,time,symbol,where,detail,last_error",mb,InpUseCommonFolder);
   g_hourly.Init(g_root+"\\STATS","hourly_stats","run_id,symbol,timeframe,hour,minute,minute_of_day,sample_size,bull_count,bear_count,doji_count,bull_rate,bear_rate,mean_range,mean_body,mean_volume,mean_volume_ratio,mean_tick_density,mean_spread,forward_up_rate,median_not_available_note",mb,InpUseCommonFolder);
   g_dayhour.Init(g_root+"\\STATS","day_hour_stats","run_id,symbol,timeframe,day_of_week,day_name,hour,minute,minute_of_day,sample_size,bull_count,bear_count,bull_rate,bear_rate,mean_range,mean_body,mean_volume,mean_volume_ratio,mean_tick_density,mean_spread",mb,InpUseCommonFolder);
   g_patterns.Init(g_root+"\\STATS","pattern_stats","run_id,symbol,timeframe,pattern,hour,minute,sample_size,occurrences,rate,mean_range,mean_body,forward_up_rate,median_mfe_note",mb,InpUseCommonFolder);
   g_discovery.Init(g_root+"\\DISCOVERY","discoveries","run_id,symbol,timeframe,minute_of_day,discovery_key,condition_count,sample_size,coverage,base_rate_bull,conditional_forward_up_rate,effect_delta,forward_down_rate,mean_mfe,mean_mae,mean_body,mean_range,mean_volume_ratio",mb,InpUseCommonFolder);
   g_integrity.Init(g_root+"\\STATS","integrity","run_id,symbol,timeframe,start_time,end_time,requested_bars,processed_bars,missing_or_gap_count,data_source,tick_data_attempted,tick_data_missing",mb,InpUseCommonFolder);
   g_news.Init(g_root+"\\NEWS","news",MBA_NewsHeader(),mb,InpUseCommonFolder);
   return true;
  }

void WriteRun(datetime from_dt,datetime to_dt)
  {
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,"HISTORY");MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_Add(f,MBA_DT(from_dt,true));MBA_Add(f,MBA_DT(to_dt,true));MBA_AddL(f,InpAnalysisTimezoneOffset);MBA_AddL(f,InpPartSizeMB);MBA_Add(f,"FALSE");MBA_Add(f,MBA_Bool(InpWriteTickAggregates));MBA_Add(f,"1.00");g_runs.WriteFields(f);g_runs.Flush();
  }

bool GetRange(datetime &from_dt,datetime &to_dt)
  {
   if(InpUseDateInputs)
     {from_dt=InpStartDate;to_dt=InpEndDate;return from_dt<to_dt;}
   to_dt=TimeCurrent();from_dt=to_dt-(datetime)MathMax(1,InpHistoryDays)*86400;return from_dt<to_dt;
  }

void RecordIntegrity(ENUM_TIMEFRAMES tf,datetime from_dt,datetime to_dt,int requested,int processed,int gaps,bool tick_attempted,int tick_missing)
  {
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(from_dt,true));MBA_Add(f,MBA_DT(to_dt,true));MBA_AddL(f,requested);MBA_AddL(f,processed);MBA_AddL(f,gaps);MBA_Add(f,"SERVER_HISTORY");MBA_Add(f,MBA_Bool(tick_attempted));MBA_AddL(f,tick_missing);g_integrity.WriteFields(f);
  }

double VolumeRatio(const MqlRates &rates[],int idx)
  {
   if(idx<=0)return 1.0;int from=MathMax(0,idx-InpFeatureLookback);int to=idx-1;double s=0;int n=0;for(int i=from;i<=to;i++){s+=(double)rates[i].tick_volume;n++;}return n>0?MBA_SafeRatio((double)rates[idx].tick_volume,s/n):1.0;
  }

bool GetNewsState(datetime t,string &state)
  {
   if(!InpBuildNewsContext){state="DISABLED";return false;}
   MqlCalendarValue vals[];
   datetime from=t-3600,to=t+3600;
   ResetLastError();int n=CalendarValueHistory(vals,from,to,NULL,NULL);
   if(n<0){state="ERROR";return false;}
   if(n==0){state="NONE_WITHIN_60M";return true;}
   int high=0,medium=0,low=0;
   for(int i=0;i<n;i++)
     {
      // importance is exposed through event metadata, not directly on the value structure in all terminal builds;
      // therefore count presence here and leave detailed classification for a later enrichment pass.
      if(vals[i].time>=t) high++; else low++;
     }
   state=StringFormat("EVENTS_%d_AROUND_60M",n);
   return true;
  }

void WriteRawTicksRange(datetime from_dt,datetime to_dt)
  {
   if(!InpWriteHistoricalRawTicks)return;
   MqlTick ticks[];int n=CopyTicksRange(_Symbol,ticks,COPY_TICKS_ALL,(ulong)from_dt*1000ULL,(ulong)to_dt*1000ULL+999ULL);if(n<=0)return;
   double prev=0;bool has=false;
   for(int i=0;i<n;i++)
     {
      double price=ticks[i].last>0?ticks[i].last:((ticks[i].bid>0&&ticks[i].ask>0)?(ticks[i].bid+ticks[i].ask)/2.0:ticks[i].bid);
      int td=0;if(has){if(price>prev)td=1;else if(price<prev)td=-1;}
      double spr=(ticks[i].bid>0&&ticks[i].ask>0)?(ticks[i].ask-ticks[i].bid)/_Point:0;
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_AddU(f,ticks[i].time_msc);MBA_Add(f,MBA_TimeMS(ticks[i].time_msc));MBA_AddD(f,ticks[i].bid,MBA_Digits());MBA_AddD(f,ticks[i].ask,MBA_Digits());MBA_AddD(f,ticks[i].last,MBA_Digits());MBA_AddL(f,(long)ticks[i].volume);MBA_AddD(f,ticks[i].volume_real,4);MBA_AddL(f,(long)ticks[i].flags);MBA_AddD(f,spr,2);MBA_Add(f,IntegerToString(td));MBA_Add(f,"HISTORICAL_SERVER");g_rawticks.WriteFields(f);g_rows_since_flush++;
      if(price>0){prev=price;has=true;}
      if(g_rows_since_flush>=InpFlushEveryRows)FlushAll();
     }
  }

void WriteForwardForBar(int tfIndex,const MqlRates &rates[],int idx,double atr,string source)
  {
   if(idx<0)return;ENUM_TIMEFRAMES tf=MBA_TFs[tfIndex];int n=ArraySize(rates);double event_close=rates[idx].close;int dir=MBA_Direction(rates[idx]);
   double cumulative_high=-DBL_MAX,cumulative_low=DBL_MAX;double best_mfe=-DBL_MAX,best_mae=DBL_MAX;int best_mfe_h=-1,best_mae_h=-1;
   for(int h=1;h<=InpForwardMaxBars;h++)
     {
      int fi=idx+h;if(fi>=n)break;
      cumulative_high=MathMax(cumulative_high,rates[fi].high);cumulative_low=MathMin(cumulative_low,rates[fi].low);
      double fav=0,adv=0;
      if(dir>0){fav=(cumulative_high-event_close)/_Point;adv=(cumulative_low-event_close)/_Point;}
      else if(dir<0){fav=(event_close-cumulative_low)/_Point;adv=(event_close-cumulative_high)/_Point;}
      else {fav=MathMax(MathAbs(cumulative_high-event_close),MathAbs(cumulative_low-event_close))/_Point;adv=0;}
      if(fav>best_mfe){best_mfe=fav;best_mfe_h=h;}
      if(adv<best_mae){best_mae=adv;best_mae_h=h;}
      double fc=rates[fi].close;double ret=(fc-event_close)/_Point;int d=fc>event_close?1:(fc<event_close?-1:0);double retatr=atr>0?(fc-event_close)/atr:0;double mfe=MathMax(0,best_mfe);double mae=(best_mae==DBL_MAX?0:best_mae);
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,BuildEventId(tf,rates[idx].time));MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(rates[idx].time,true));MBA_AddL(f,h);MBA_Add(f,MBA_DT(rates[fi].time,true));MBA_AddD(f,fc,MBA_Digits());MBA_AddD(f,ret,2);MBA_AddD(f,retatr,6);MBA_AddD(f,cumulative_high,MBA_Digits());MBA_AddD(f,cumulative_low,MBA_Digits());MBA_AddD(f,mfe,2);MBA_AddD(f,mae,2);MBA_AddD(f,atr>0?mfe*_Point/atr:0,6);MBA_AddD(f,atr>0?mae*_Point/atr:0,6);MBA_AddL(f,best_mfe_h);MBA_AddL(f,best_mae_h);MBA_Add(f,MBA_Dir(d));MBA_Add(f,source);g_forward[tfIndex].WriteFields(f);g_rows_since_flush++;
     }
  }

void UpdateStats(int tfIndex,const MqlRates &rates[],int idx,double vol_ratio,double tick_density,double spread_avg,double mfe5,double mae5,bool forward_up)
  {
   int d=MBA_Direction(rates[idx]);
   double range=MBA_Range(rates[idx]);
   double body=MBA_Body(rates[idx]);
   datetime at=MBA_AnalysisTime(rates[idx].time,InpAnalysisTimezoneOffset);
   int minute=MBA_MinuteOfDay(at);
   int day=MBA_DayOfWeek(at);

   int hidx=tfIndex*1440+minute;
   g_hour_stats[hidx].n++;
   if(d>0) g_hour_stats[hidx].bull++;
   else if(d<0) g_hour_stats[hidx].bear++;
   else g_hour_stats[hidx].doji++;
   g_hour_stats[hidx].range_sum+=range;
   g_hour_stats[hidx].range_sq_sum+=range*range;
   g_hour_stats[hidx].body_sum+=body;
   g_hour_stats[hidx].volume_sum+=(double)rates[idx].tick_volume;
   g_hour_stats[hidx].volume_ratio_sum+=vol_ratio;
   g_hour_stats[hidx].tick_density_sum+=tick_density;
   g_hour_stats[hidx].spread_sum+=spread_avg;
   if(forward_up) g_hour_stats[hidx].forward_up++;
   else g_hour_stats[hidx].forward_down++;
   g_hour_stats[hidx].mfe_sum+=mfe5;
   g_hour_stats[hidx].mae_sum+=mae5;

   int didx=(tfIndex*7+day)*1440+minute;
   g_dayhour_stats[didx].n++;
   if(d>0) g_dayhour_stats[didx].bull++;
   else if(d<0) g_dayhour_stats[didx].bear++;
   else g_dayhour_stats[didx].doji++;
   g_dayhour_stats[didx].range_sum+=range;
   g_dayhour_stats[didx].body_sum+=body;
   g_dayhour_stats[didx].volume_sum+=(double)rates[idx].tick_volume;
   g_dayhour_stats[didx].volume_ratio_sum+=vol_ratio;
   g_dayhour_stats[didx].tick_density_sum+=tick_density;
   g_dayhour_stats[didx].spread_sum+=spread_avg;
   if(forward_up) g_dayhour_stats[didx].forward_up++;
   else g_dayhour_stats[didx].forward_down++;
   g_dayhour_stats[didx].mfe_sum+=mfe5;
   g_dayhour_stats[didx].mae_sum+=mae5;
  }

void UpdatePatternStats(int tfIndex,const MqlRates &rates[],int idx,string patterns,double mfe5,double mae5,bool forward_up)
  {
   if(StringLen(patterns)==0)return;string p[];int n=StringSplit(patterns,StringGetCharacter("|",0),p);datetime at=MBA_AnalysisTime(rates[idx].time,InpAnalysisTimezoneOffset);int minute=MBA_MinuteOfDay(at);
   for(int k=0;k<n;k++)
     {
      int pid=-1;for(int j=0;j<ArraySize(g_pattern_names);j++)if(p[k]==g_pattern_names[j]){pid=j;break;}if(pid<0)continue;
      int pos=(tfIndex*16+pid)*1440+minute;
      g_pattern_stats[pos].n++;
      g_pattern_stats[pos].range_sum+=MBA_Range(rates[idx]);
      g_pattern_stats[pos].body_sum+=MBA_Body(rates[idx]);
      if(forward_up) g_pattern_stats[pos].forward_up++; else g_pattern_stats[pos].forward_down++;
      g_pattern_stats[pos].mfe_sum+=mfe5;
      g_pattern_stats[pos].mae_sum+=mae5;
     }
  }

void DiscoverForEvent(int tfIndex,const MqlRates &rates[],int idx,double atr,double vol_ratio,double tick_ratio,string structure,string m15,string h1,double mfe5,double mae5,bool forward_up)
  {
   datetime at=MBA_AnalysisTime(rates[idx].time,InpAnalysisTimezoneOffset);string tf=MBA_TFNames[tfIndex];string dir=MBA_Dir(MBA_Direction(rates[idx]));string minute=IntegerToString(MBA_MinuteOfDay(at));string day=IntegerToString(MBA_DayOfWeek(at));string bb=MBA_BucketPct(MBA_SafeRatio(MBA_Body(rates[idx]),MBA_Range(rates[idx])));string rb=MBA_BucketRatio(MBA_SafeRatio(MBA_Range(rates[idx]),atr));string vb=MBA_BucketVolume(vol_ratio);
   string keys[6];int kc=0;
   keys[kc++]=tf+"|MIN="+minute+"|DIR="+dir;
   keys[kc++]=keys[0]+"|BODY="+bb;
   keys[kc++]=keys[1]+"|RANGE_ATR="+rb;
   keys[kc++]=keys[2]+"|VOL="+vb;
   keys[kc++]=keys[3]+"|STRUCT="+structure;
   keys[kc++]=keys[4]+"|M15="+m15+"|H1="+h1;
   for(int k=0;k<kc;k++)UpdateDiscovery(keys[k],MBA_SafeRatio(MBA_Body(rates[idx]),MathMax(MBA_Range(rates[idx]),_Point)),MBA_SafeRatio(MBA_Range(rates[idx]),MathMax(atr,_Point)),vol_ratio,forward_up?1:-1,mfe5,mae5);
  }

string DayNameByIndex(int day)
  {
   switch(day)
     {
      case 0:return "SUNDAY";
      case 1:return "MONDAY";
      case 2:return "TUESDAY";
      case 3:return "WEDNESDAY";
      case 4:return "THURSDAY";
      case 5:return "FRIDAY";
      case 6:return "SATURDAY";
     }
   return "UNKNOWN";
  }

void WriteStats()
  {
   for(int tfIndex=0;tfIndex<MBA_TF_COUNT;tfIndex++)
     {
      for(int minute=0;minute<1440;minute++)
        {
         MBA_Stat s=g_hour_stats[tfIndex*1440+minute];if(s.n<=0)continue;int hour=minute/60,min=minute%60;string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFNames[tfIndex]);MBA_AddL(f,hour);MBA_AddL(f,min);MBA_AddL(f,minute);MBA_AddL(f,s.n);MBA_AddL(f,s.bull);MBA_AddL(f,s.bear);MBA_AddL(f,s.doji);MBA_AddD(f,MBA_SafeRatio((double)s.bull,(double)s.n),6);MBA_AddD(f,MBA_SafeRatio((double)s.bear,(double)s.n),6);MBA_AddD(f,s.range_sum/s.n,4);MBA_AddD(f,s.body_sum/s.n,4);MBA_AddD(f,s.volume_sum/s.n,2);MBA_AddD(f,s.volume_ratio_sum/s.n,6);MBA_AddD(f,s.tick_density_sum/s.n,4);MBA_AddD(f,s.spread_sum/s.n,2);MBA_AddD(f,MBA_SafeRatio((double)s.forward_up,(double)(s.forward_up+s.forward_down)),6);MBA_Add(f,"MEDIAN_REQUIRES_EVENT_DISTRIBUTION_CSV");g_hourly.WriteFields(f);
        }
      for(int day=0;day<7;day++)for(int minute=0;minute<1440;minute++)
        {
         MBA_Stat s=g_dayhour_stats[(tfIndex*7+day)*1440+minute];if(s.n<=0)continue;int hour=minute/60,min=minute%60;string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFNames[tfIndex]);MBA_AddL(f,day);MBA_Add(f,DayNameByIndex(day));MBA_AddL(f,hour);MBA_AddL(f,min);MBA_AddL(f,minute);MBA_AddL(f,s.n);MBA_AddL(f,s.bull);MBA_AddL(f,s.bear);MBA_AddD(f,MBA_SafeRatio((double)s.bull,(double)s.n),6);MBA_AddD(f,MBA_SafeRatio((double)s.bear,(double)s.n),6);MBA_AddD(f,s.range_sum/s.n,4);MBA_AddD(f,s.body_sum/s.n,4);MBA_AddD(f,s.volume_sum/s.n,2);MBA_AddD(f,s.volume_ratio_sum/s.n,6);MBA_AddD(f,s.tick_density_sum/s.n,4);MBA_AddD(f,s.spread_sum/s.n,2);g_dayhour.WriteFields(f);
        }
      for(int pid=0;pid<ArraySize(g_pattern_names);pid++)for(int minute=0;minute<1440;minute++)
        {
         MBA_Stat s=g_pattern_stats[(tfIndex*16+pid)*1440+minute];if(s.n<=0)continue;int hour=minute/60,min=minute%60;string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFNames[tfIndex]);MBA_Add(f,g_pattern_names[pid]);MBA_AddL(f,hour);MBA_AddL(f,min);MBA_AddL(f,s.n);MBA_AddL(f,s.n);MBA_AddD(f,MBA_SafeRatio((double)s.n,(double)s.n),6);MBA_AddD(f,s.range_sum/s.n,4);MBA_AddD(f,s.body_sum/s.n,4);MBA_AddD(f,MBA_SafeRatio((double)s.forward_up,(double)(s.forward_up+s.forward_down)),6);MBA_Add(f,"MEDIAN_MFE_REQUIRES_FORWARD_DISTRIBUTION");g_patterns.WriteFields(f);
        }
     }

   for(int i=0;i<g_disc_capacity;i++)
     {
      if(g_disc_keys[i]==""||g_disc_n[i]<=0)continue;
      string tmp[];StringSplit(g_disc_keys[i],StringGetCharacter("|",0),tmp);int cc=MathMax(1,ArraySize(tmp));
      int tfidx=-1;for(int q=0;q<MBA_TF_COUNT;q++)if(StringFind(g_disc_keys[i],MBA_TFNames[q]+"|MIN=")==0){tfidx=q;break;}
      int minute=-1;int mp=StringFind(g_disc_keys[i],"|MIN=");if(mp>=0){int st=mp+5;int ep=StringFind(g_disc_keys[i],"|",st);string ms=(ep<0?StringSubstr(g_disc_keys[i],st):StringSubstr(g_disc_keys[i],st,ep-st));minute=(int)StringToInteger(ms);}
      double base=0,coverage=0;
      if(tfidx>=0&&minute>=0){MBA_Stat bs=g_hour_stats[tfidx*1440+minute];base=MBA_SafeRatio((double)bs.bull,(double)MathMax(1,bs.n));coverage=MBA_SafeRatio((double)g_disc_n[i],(double)MathMax(1,bs.n));}
      double cond=MBA_SafeRatio((double)g_disc_up[i],(double)g_disc_n[i]);
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,_Symbol);MBA_Add(f,tfidx>=0?MBA_TFNames[tfidx]:"UNKNOWN");MBA_AddL(f,minute);MBA_Add(f,g_disc_keys[i]);MBA_AddL(f,cc);MBA_AddL(f,g_disc_n[i]);MBA_AddD(f,coverage,8);MBA_AddD(f,base,8);MBA_AddD(f,cond,8);MBA_AddD(f,cond-base,8);MBA_AddD(f,MBA_SafeRatio((double)g_disc_down[i],(double)g_disc_n[i]),8);MBA_AddD(f,g_disc_mfe[i]/g_disc_n[i],4);MBA_AddD(f,g_disc_mae[i]/g_disc_n[i],4);MBA_AddD(f,g_disc_body[i]/g_disc_n[i],6);MBA_AddD(f,g_disc_range[i]/g_disc_n[i],6);MBA_AddD(f,g_disc_vol[i]/g_disc_n[i],6);g_discovery.WriteFields(f);
     }
  }


string NewsImpactNameH(ENUM_CALENDAR_EVENT_IMPACT impact)
  {
   switch(impact){case CALENDAR_IMPACT_POSITIVE:return "POSITIVE";case CALENDAR_IMPACT_NEGATIVE:return "NEGATIVE";default:return "NA";}
  }

void WriteHistoricalNews(datetime from_dt,datetime to_dt)
  {
   if(!InpBuildNewsContext)return;
   MqlCalendarValue vals[];int n=CalendarValueHistory(vals,from_dt,to_dt,NULL,NULL);if(n<=0)return;
   for(int i=0;i<n;i++)
     {
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,MBA_UD(vals[i].event_id));MBA_Add(f,MBA_UD(vals[i].id));MBA_Add(f,MBA_DT(vals[i].time,true));MBA_Add(f,MBA_DT(vals[i].period,true));MBA_AddL(f,(long)vals[i].revision);MBA_AddL(f,vals[i].actual_value);MBA_AddL(f,vals[i].prev_value);MBA_AddL(f,vals[i].revised_prev_value);MBA_AddL(f,vals[i].forecast_value);MBA_Add(f,NewsImpactNameH(vals[i].impact_type));MBA_Add(f,"CALENDAR_HISTORY");g_news.WriteFields(f);g_rows_since_flush++;if(g_rows_since_flush>=InpFlushEveryRows)FlushAll();
     }
  }

void ProcessTF(ENUM_TIMEFRAMES tf,datetime from_dt,datetime to_dt)
  {
   int tfIndex=MBA_TFIndex(tf);if(tfIndex<0)return;
   MqlRates rates[];ResetLastError();int n=CopyRates(_Symbol,tf,from_dt,to_dt,rates);if(n<=0){LogError("CopyRates",MBA_TFName(tf));RecordIntegrity(tf,from_dt,to_dt,0,0,0,false,0);return;}ArraySetAsSeries(rates,false);
   // Preload context series once per timeframe run to avoid CopyRates on every event.
   datetime ctx_from=from_dt-900*86400;
   MqlRates cM1[],cM5[],cM15[],cM30[],cH1[],cH4[],cW1[],cMN1[],cD1[];
   CopyRates(_Symbol,PERIOD_M1,ctx_from,to_dt,cM1);ArraySetAsSeries(cM1,false);
   CopyRates(_Symbol,PERIOD_M5,ctx_from,to_dt,cM5);ArraySetAsSeries(cM5,false);
   CopyRates(_Symbol,PERIOD_M15,ctx_from,to_dt,cM15);ArraySetAsSeries(cM15,false);
   CopyRates(_Symbol,PERIOD_M30,ctx_from,to_dt,cM30);ArraySetAsSeries(cM30,false);
   CopyRates(_Symbol,PERIOD_H1,ctx_from,to_dt,cH1);ArraySetAsSeries(cH1,false);
   CopyRates(_Symbol,PERIOD_H4,ctx_from,to_dt,cH4);ArraySetAsSeries(cH4,false);
   CopyRates(_Symbol,PERIOD_W1,ctx_from,to_dt,cW1);ArraySetAsSeries(cW1,false);
   CopyRates(_Symbol,PERIOD_MN1,ctx_from,to_dt,cMN1);ArraySetAsSeries(cMN1,false);
   CopyRates(_Symbol,PERIOD_D1,ctx_from,to_dt,cD1);ArraySetAsSeries(cD1,false);
   int processed=0,gaps=0,tick_missing=0;bool tick_attempted=InpWriteTickAggregates;
   for(int i=0;i<n;i++)
     {
      datetime t=rates[i].time;if(t<from_dt||t>to_dt)continue;
      if(i>0)
        {
         int sec=PeriodSeconds(tf);if(sec>0 && t-rates[i-1].time>sec*2)gaps++;
        }
      if(i<InpFeatureLookback)continue;
      if(i+InpForwardMaxBars>=n)continue; // need complete forward window for discovery/statistics
      double range=MBA_Range(rates[i]),body=MBA_Body(rates[i]),uw=MBA_UpperWick(rates[i]),lw=MBA_LowerWick(rates[i]);
      double prev_close=rates[i-1].close;double true_range=MathMax(range,MathMax(MathAbs(rates[i].high-prev_close),MathAbs(rates[i].low-prev_close)));
      double atr=MBA_ATRAt(rates,i,InpATRPeriod);double range_atr=MBA_SafeRatio(range,atr);double vr=VolumeRatio(rates,i);
      MBA_TickAgg ta;MBA_ResetTickAgg(ta);bool tok=false;if(InpWriteTickAggregates){datetime end=(i+1<n?rates[i+1].time-1:MBA_NextBarTime(t,tf)-1);tok=MBA_CopyTickAggregate(_Symbol,t,end,ta);if(tok)WriteTickAggregateRow(tf,t,end,ta,"HISTORICAL_SERVER");else tick_missing++;}
      double avg_tv=MBA_AvgTickVolumeAt(rates,i,InpFeatureLookback);double tick_density=tok?ta.tick_count/MathMax(1.0,(double)PeriodSeconds(tf)/60.0):0;double tick_density_ratio=tok?MBA_SafeRatio((double)ta.tick_count,MathMax(1.0,avg_tv)):0;double spread_avg=tok?MBA_SafeRatio(ta.spread_sum,(double)MathMax(1,ta.tick_count)):0;
      string pattern=MBA_Patterns(rates,i);string structure=MBA_StructureState(rates,i,InpFeatureLookback);string vol_state=MBA_VolatilityState(range_atr);datetime at=MBA_AnalysisTime(t,InpAnalysisTimezoneOffset);string news="DISABLED";if(InpBuildNewsContext)GetNewsState(t,news);
      double mfe5=0,mae5=0;int fi=i+MathMin(5,InpForwardMaxBars);if(fi<n){double fc=rates[fi].close,fh=rates[fi].high,fl=rates[fi].low;if(MBA_Direction(rates[i])>0){mfe5=(fh-rates[i].close)/_Point;mae5=(fl-rates[i].close)/_Point;}else if(MBA_Direction(rates[i])<0){mfe5=(rates[i].close-fl)/_Point;mae5=(rates[i].close-fh)/_Point;}else{mfe5=MathMax((fh-rates[i].close)/_Point,(rates[i].close-fl)/_Point);mae5=MathMin((fl-rates[i].close)/_Point,(fh-rates[i].close)/_Point);}}
      bool forward_up=rates[fi].close>rates[i].close;
      string f[];MBA_Add(f,g_run_id);MBA_Add(f,BuildEventId(tf,t));MBA_Add(f,_Symbol);MBA_Add(f,MBA_TFName(tf));MBA_Add(f,MBA_DT(t,true));MBA_Add(f,MBA_DT(at,true));MBA_Add(f,MBA_DT(t,true));MBA_Add(f,MBA_DayName(at));MBA_AddL(f,MBA_Hour(at));MBA_AddL(f,MBA_Minute(at));MBA_AddL(f,MBA_MinuteOfDay(at));MBA_Add(f,MBA_Session(at));MBA_AddD(f,rates[i].open,MBA_Digits());MBA_AddD(f,rates[i].high,MBA_Digits());MBA_AddD(f,rates[i].low,MBA_Digits());MBA_AddD(f,rates[i].close,MBA_Digits());MBA_AddD(f,range,2);MBA_AddD(f,body,2);MBA_AddD(f,uw,2);MBA_AddD(f,lw,2);MBA_AddD(f,MBA_SafeRatio(body,range),6);MBA_AddD(f,MBA_SafeRatio(uw,range),6);MBA_AddD(f,MBA_SafeRatio(lw,range),6);MBA_AddD(f,MBA_ClosePosition(rates[i]),6);MBA_Add(f,MBA_Dir(MBA_Direction(rates[i])));MBA_AddD(f,true_range,2);MBA_AddD(f,atr,2);MBA_AddD(f,range_atr,6);MBA_AddL(f,(long)rates[i].tick_volume);MBA_AddD(f,(double)rates[i].real_volume,4);MBA_AddD(f,MBA_AvgTickVolumeAt(rates,i,InpFeatureLookback),2);MBA_AddD(f,vr,6);MBA_AddL(f,tok?ta.tick_count:0);MBA_AddD(f,tick_density,4);MBA_AddD(f,tick_density_ratio,4);MBA_AddD(f,spread_avg,2);MBA_AddD(f,tok?ta.spread_max:0,2);MBA_AddD(f,tok?ta.spread_min:0,2);MBA_Add(f,MBA_BucketRatio(range_atr));MBA_Add(f,MBA_BucketPct(MBA_SafeRatio(body,range)));MBA_Add(f,MBA_BucketVolume(vr));MBA_Add(f,pattern);MBA_Add(f,structure);MBA_Add(f,vol_state);MBA_Add(f,"HISTORICAL_SERVER");g_candles[tfIndex].WriteFields(f);

      // MTF state: reconstruct from arrays by loading the corresponding timeframe once per event is costly;
      // for the compact processor, derive the local TF state and load higher/lower context in a bounded cache below.
      string mtf[8];
      mtf[0]=MBA_GetStateAtOrBefore(cM1,t,InpFeatureLookback);
      mtf[1]=MBA_GetStateAtOrBefore(cM5,t,InpFeatureLookback);
      mtf[2]=MBA_GetStateAtOrBefore(cM15,t,InpFeatureLookback);
      mtf[3]=MBA_GetStateAtOrBefore(cM30,t,InpFeatureLookback);
      mtf[4]=MBA_GetStateAtOrBefore(cH1,t,InpFeatureLookback);
      mtf[5]=MBA_GetStateAtOrBefore(cH4,t,InpFeatureLookback);
      mtf[6]=MBA_GetStateAtOrBefore(cW1,t,InpFeatureLookback);
      mtf[7]=MBA_GetStateAtOrBefore(cMN1,t,InpFeatureLookback);
      string ef[];MBA_Add(ef,g_run_id);MBA_Add(ef,BuildEventId(tf,t));MBA_Add(ef,_Symbol);MBA_Add(ef,MBA_TFName(tf));MBA_Add(ef,MBA_DT(t,true));MBA_Add(ef,MBA_DT(at,true));MBA_Add(ef,MBA_DayName(at));MBA_AddL(ef,MBA_Hour(at));MBA_AddL(ef,MBA_Minute(at));MBA_Add(ef,MBA_Session(at));MBA_Add(ef,MBA_Dir(MBA_Direction(rates[i])));MBA_AddD(ef,MBA_SafeRatio(body,range),6);MBA_AddD(ef,MBA_SafeRatio(uw,range),6);MBA_AddD(ef,MBA_SafeRatio(lw,range),6);MBA_AddD(ef,MBA_ClosePosition(rates[i]),6);MBA_AddD(ef,range_atr,6);MBA_AddD(ef,vr,6);MBA_AddD(ef,tick_density,6);MBA_AddD(ef,spread_avg,2);MBA_Add(ef,pattern);MBA_Add(ef,structure);MBA_Add(ef,vol_state);double ph=rates[MathMax(0,i-InpFeatureLookback)].high,pl=rates[MathMax(0,i-InpFeatureLookback)].low;for(int j=MathMax(0,i-InpFeatureLookback);j<i;j++){ph=MathMax(ph,rates[j].high);pl=MathMin(pl,rates[j].low);}
      double daily_open=OpenAtOrBefore(cD1,t),weekly_open=OpenAtOrBefore(cW1,t),monthly_open=OpenAtOrBefore(cMN1,t);
      MBA_AddD(ef,daily_open>0?(rates[i].close-daily_open)/_Point:0,2);MBA_AddD(ef,weekly_open>0?(rates[i].close-weekly_open)/_Point:0,2);MBA_AddD(ef,monthly_open>0?(rates[i].close-monthly_open)/_Point:0,2);MBA_AddD(ef,atr>0?(rates[i].close-ph)/atr:0,6);MBA_AddD(ef,atr>0?(rates[i].close-pl)/atr:0,6);for(int s=0;s<8;s++)MBA_Add(ef,mtf[s]);MBA_Add(ef,news);MBA_Add(ef,"HISTORICAL_SERVER");g_events[tfIndex].WriteFields(ef);

      WriteForwardForBar(tfIndex,rates,i,atr,"HISTORICAL_SERVER");
      UpdateStats(tfIndex,rates,i,vr,tick_density,spread_avg,mfe5,mae5,forward_up);
      UpdatePatternStats(tfIndex,rates,i,pattern,mfe5,mae5,forward_up);
      string m15=mtf[2],h1=mtf[4];DiscoverForEvent(tfIndex,rates,i,atr,vr,tick_density_ratio,structure,m15,h1,mfe5,mae5,forward_up);
      processed++;g_total_events++;g_rows_since_flush++;if(g_rows_since_flush>=InpFlushEveryRows)FlushAll();
     }
   RecordIntegrity(tf,from_dt,to_dt,n,processed,gaps,tick_attempted,tick_missing);
  }

int OnStart()
  {
   g_run_id=StringFormat("HIST_%s_%s",MBA_SafeName(_Symbol),TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   datetime from_dt,to_dt;if(!GetRange(from_dt,to_dt)){Print("MBA: invalid date range.");return 1;}
   ResetStats();InitDiscoveryTable();if(!InitWriters())return 2;WriteRun(from_dt,to_dt);
   if(InpBuildNewsContext)WriteHistoricalNews(from_dt,to_dt);
   for(int i=0;i<MBA_TF_COUNT;i++)ProcessTF(MBA_TFs[i],from_dt,to_dt);
   if(InpWriteHistoricalRawTicks)WriteRawTicksRange(from_dt,to_dt);
   WriteStats();FlushAll();
   Print("MBA history complete. Events: ",g_total_events," Run: ",g_run_id);
   return 0;
  }
