//+------------------------------------------------------------------+
//| MarketBehaviorAnalyzer_History.mq5                               |
//| Historical reconstruction + statistics + discovery engine         |
//+------------------------------------------------------------------+
#property strict
#property version   "1.23"
#property description "Historical market behavior research processor. Non-trading."

#include "MBA_Core.mqh"

// v1.10: same row schema as the live EA (event_key/forward_key, closed-bar MTF, levels, calendar importance).

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
// ---- v1.10
input bool   InpBrokerFolder             = true;       // root\<broker>\<symbol>\HISTORY\<run>
enum MBA_DST_INPUT
  {
   MBA_DSTIN_AUTO=0,           // AUTO (NY-close rule when the broker follows it)
   MBA_DSTIN_US_NY_CLOSE=1,    // NY-close server: UTC+2 winter / UTC+3 US daylight saving
   MBA_DSTIN_FIXED_CURRENT=2,  // current offset for all history
   MBA_DSTIN_FIXED_INPUT=3     // InpAnalysisTimezoneOffset
  };
input MBA_DST_INPUT InpDstMode           = MBA_DSTIN_AUTO;
input double InpOhlcTolerancePoints      = 1.0;
input bool   InpWriteTimeForward         = true;       // FORWARD_TIME: horizons in minutes on M1 bars (events up to InpTimeFwdMaxTFSec)
input string InpTimeHorizonsMin          = "1,3,5,10,15,30,60,120,240";
input int    InpTimeFwdMaxTFSec          = 14400;
input double InpTimeFwdTargetP1          = 100;
input double InpTimeFwdTargetP2          = 200;
input double InpTimeFwdTargetP3          = 300;
input string InpNewsCurrencies           = "USD";
input int    InpNewsMinImportance        = 2;
input double InpCommissionPerLotDeclared = 0.0;

CMBAWriter g_candles[MBA_TF_COUNT];
CMBAWriter g_events[MBA_TF_COUNT];
CMBAWriter g_forward[MBA_TF_COUNT];
CMBAWriter g_tfwd[MBA_TF_COUNT];
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
CMBAWriter g_spec;
CMBANews   g_cal;
string g_broker="";
string g_server="";
int g_dst=MBA_DST_FIXED_CURRENT;
int g_hz[];
double g_ptgt[3];
double g_comm_points=0;

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

datetime AnalysisAt(datetime server_t)
  { return server_t-(datetime)MBA_OffsetAt(server_t,g_dst,-InpAnalysisTimezoneOffset*3600); }

string BuildEventId(ENUM_TIMEFRAMES tf,datetime t)
  { return StringFormat("%s-%s-%s",MBA_SafeName(_Symbol),MBA_TFName(tf),TimeToString(t,TIME_DATE|TIME_MINUTES)); }

string BuildEventKey(ENUM_TIMEFRAMES tf,datetime t)
  { return StringFormat("%s|%s|%s|%s|%s",g_broker,_Symbol,MBA_TFName(tf),TimeToString(t,TIME_DATE|TIME_MINUTES|TIME_SECONDS),"HISTORY"); }

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
   string f[];MBA_FillTickAggRow(f,_Symbol,MBA_TFName(tf),from_time,to_time,a,source);g_tickagg[idx].WriteFields(f);
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
   for(int i=0;i<MBA_TF_COUNT;i++){g_candles[i].Flush();g_events[i].Flush();g_forward[i].Flush();g_tfwd[i].Flush();g_tickagg[i].Flush();}
   g_rawticks.Flush();g_runs.Flush();g_errors.Flush();g_hourly.Flush();g_dayhour.Flush();g_patterns.Flush();g_discovery.Flush();g_integrity.Flush();g_news.Flush();g_spec.Flush();g_rows_since_flush=0;
  }

bool InitWriters()
  {
   g_root=InpRootFolder+(InpBrokerFolder?"\\"+g_broker:"")+"\\"+MBA_SafeName(_Symbol)+"\\HISTORY\\"+g_run_id;
   long mb=MathMax(1,InpPartSizeMB)*1024*1024;
   for(int i=0;i<MBA_TF_COUNT;i++)
     {
      g_candles[i].Init(g_root+"\\CANDLES","candles_"+MBA_TFNames[i],MBA_CandleHeader(),mb,InpUseCommonFolder);
      g_events[i].Init(g_root+"\\EVENTS","events_"+MBA_TFNames[i],MBA_EventHeader(),mb,InpUseCommonFolder);
      g_forward[i].Init(g_root+"\\FORWARD","forward_"+MBA_TFNames[i],MBA_ForwardHeader(),mb,InpUseCommonFolder);
      g_tfwd[i].Init(g_root+"\\FORWARD_TIME","forward_time_"+MBA_TFNames[i],MBA_TimeFwdHeader(),mb,InpUseCommonFolder);
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
   g_spec.Init(g_root+"\\META","symbol_spec",MBA_SpecHeader(),mb,InpUseCommonFolder);
   return true;
  }

void WriteRun(datetime from_dt,datetime to_dt)
  {
   string f[];MBA_Add(f,g_run_id);MBA_Add(f,"HISTORY");MBA_Add(f,_Symbol);MBA_Add(f,MBA_DT(TimeCurrent(),true));MBA_Add(f,MBA_DT(from_dt,true));MBA_Add(f,MBA_DT(to_dt,true));MBA_AddL(f,InpAnalysisTimezoneOffset);MBA_AddL(f,InpPartSizeMB);MBA_Add(f,"FALSE");MBA_Add(f,MBA_Bool(InpWriteTickAggregates));MBA_Add(f,MBA_VERSION);g_runs.WriteFields(f);g_runs.Flush();
   string sf[];MBA_FillSpecRow(sf,g_run_id,InpCommissionPerLotDeclared,StringFormat("dstMode=%s;lookback=%d;atr=%d;fwd=%d;news=%s/%d",MBA_DstBasisName(g_dst),InpFeatureLookback,InpATRPeriod,InpForwardMaxBars,InpNewsCurrencies,InpNewsMinImportance));g_spec.WriteFields(sf);
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
   if(idx<0)return;ENUM_TIMEFRAMES tf=MBA_TFs[tfIndex];int n=ArraySize(rates);
   string ekey=BuildEventKey(tf,rates[idx].time);
   for(int h=1;h<=InpForwardMaxBars;h++)
     {
      if(idx+h>=n)break;
      string f[];MBA_FillForwardRow(f,g_run_id,ekey,BuildEventId(tf,rates[idx].time),g_broker,g_server,"HISTORY",MBA_TFName(tf),rates,idx,h,atr,source);
      g_forward[tfIndex].WriteFields(f);g_rows_since_flush++;
     }
  }

void UpdateStats(int tfIndex,const MqlRates &rates[],int idx,double vol_ratio,double tick_density,double spread_avg,double mfe5,double mae5,bool forward_up)
  {
   int d=MBA_Direction(rates[idx]);
   double range=MBA_Range(rates[idx]);
   double body=MBA_Body(rates[idx]);
   datetime at=AnalysisAt(rates[idx].time);
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
   if(StringLen(patterns)==0)return;string p[];int n=StringSplit(patterns,StringGetCharacter("|",0),p);datetime at=AnalysisAt(rates[idx].time);int minute=MBA_MinuteOfDay(at);
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
   datetime at=AnalysisAt(rates[idx].time);string tf=MBA_TFNames[tfIndex];string dir=MBA_Dir(MBA_Direction(rates[idx]));string minute=IntegerToString(MBA_MinuteOfDay(at));string day=IntegerToString(MBA_DayOfWeek(at));string bb=MBA_BucketPct(MBA_SafeRatio(MBA_Body(rates[idx]),MBA_Range(rates[idx])));string rb=MBA_BucketRatio(MBA_SafeRatio(MBA_Range(rates[idx]),atr));string vb=MBA_BucketVolume(vol_ratio);
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


void WriteHistoricalNews(datetime from_dt,datetime to_dt)
  {
   if(!InpBuildNewsContext)return;
   string cur[];int nc=0;
   if(StringLen(InpNewsCurrencies)>0) nc=StringSplit(InpNewsCurrencies,',',cur);
   for(int p=0;p<MathMax(1,nc);p++)
     {
      MqlCalendarValue v[];
      string c="";if(nc>0){c=cur[p];StringTrimLeft(c);StringTrimRight(c);}
      int n=(nc>0)?CalendarValueHistory(v,from_dt,to_dt,NULL,c):CalendarValueHistory(v,from_dt,to_dt,NULL,NULL);
      for(int i=0;i<n;i++)
        {
         int imp=g_cal.Importance(v[i].event_id);
         if(imp<InpNewsMinImportance) continue;
         MqlCalendarEvent ev;string name="",code="";int etype=0,sector=0;
         if(CalendarEventById(v[i].event_id,ev))
           {
            name=ev.name;etype=(int)ev.type;sector=(int)ev.sector;
            MqlCalendarCountry cc;if(CalendarCountryById(ev.country_id,cc))code=cc.code;
           }
         int off=MBA_OffsetAt(v[i].time,g_dst,-InpAnalysisTimezoneOffset*3600);
         string f[];MBA_Add(f,g_run_id);MBA_Add(f,MBA_UD(v[i].event_id));MBA_Add(f,MBA_UD(v[i].id));MBA_Add(f,MBA_DT(v[i].time,true));MBA_Add(f,MBA_DT(v[i].time-off,true));MBA_Add(f,MBA_DT(v[i].period,true));MBA_AddL(f,(long)v[i].revision);
         MBA_Add(f,v[i].HasActualValue()?DoubleToString(v[i].GetActualValue(),6):"");
         MBA_Add(f,v[i].HasPreviousValue()?DoubleToString(v[i].GetPreviousValue(),6):"");
         MBA_Add(f,v[i].HasRevisedValue()?DoubleToString(v[i].GetRevisedValue(),6):"");
         MBA_Add(f,v[i].HasForecastValue()?DoubleToString(v[i].GetForecastValue(),6):"");
         MBA_Add(f,(v[i].impact_type==CALENDAR_IMPACT_POSITIVE?"POSITIVE":(v[i].impact_type==CALENDAR_IMPACT_NEGATIVE?"NEGATIVE":"NA")));
         MBA_AddL(f,imp);MBA_Add(f,g_cal.Currency(v[i].event_id));MBA_Add(f,code);MBA_Add(f,name);MBA_AddL(f,etype);MBA_AddL(f,sector);
         MBA_Add(f,"CALENDAR_HISTORY");MBA_Add(f,MBA_SCHEMA_VERSION);
         g_news.WriteFields(f);g_rows_since_flush++;if(g_rows_since_flush>=InpFlushEveryRows)FlushAll();
        }
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
   long tcbuf[40];int tccnt=0;
   for(int i=0;i<n;i++)
     {
      datetime t=rates[i].time;if(t<from_dt||t>to_dt)continue;
      if(i>0)
        {
         int sec=PeriodSeconds(tf);if(sec>0 && t-rates[i-1].time>sec*2)gaps++;
        }
      if(i<InpFeatureLookback)continue;
      if(i+InpForwardMaxBars>=n)continue; // need complete forward window for discovery/statistics
      MBA_BarCtx c;
      c.run_id=g_run_id;c.symbol=_Symbol;c.tf_name=MBA_TFName(tf);c.source="HISTORICAL_SERVER";c.broker=g_broker;c.server=g_server;c.data_source="HISTORY";
      c.bar=rates[i];c.server_time=t;c.event_id=BuildEventId(tf,t);c.event_key=BuildEventKey(tf,t);
      int off=MBA_OffsetAt(t,g_dst,-InpAnalysisTimezoneOffset*3600);
      c.utc_basis=MBA_DstBasisName(g_dst);c.bar_spread=(double)rates[i].spread;
      c.utc_offset_sec=off;c.utc_time=t-(datetime)off;c.analysis_time=c.utc_time;
      c.range=MBA_Range(rates[i]);c.body=MBA_Body(rates[i]);c.uw=MBA_UpperWick(rates[i]);c.lw=MBA_LowerWick(rates[i]);
      double prev_close=rates[i-1].close;c.true_range=MathMax(c.range,MathMax(MathAbs(rates[i].high-prev_close),MathAbs(rates[i].low-prev_close)));
      c.atr=MBA_ATRAt(rates,i,InpATRPeriod);c.avg_tv=MBA_AvgTickVolumeAt(rates,i,InpFeatureLookback);c.vr=c.avg_tv>0?(double)rates[i].tick_volume/c.avg_tv:1.0;
      int sec=PeriodSeconds(tf);c.gap_bars=0;if(sec>0&&tf!=PERIOD_MN1){int g=(int)((t-rates[i-1].time)/sec)-1;c.gap_bars=(g>0?g:0);}
      MBA_TickAgg ta;MBA_ResetTickAgg(ta);bool tok=false;
      if(InpWriteTickAggregates)
        {
         datetime end=(i+1<n?rates[i+1].time-1:MBA_NextBarTime(t,tf)-1);if(sec>0&&tf!=PERIOD_MN1)end=MathMin(end,t+sec-1);
         tok=MBA_CopyTickAggregate(_Symbol,t,end,ta);
         if(tok)WriteTickAggregateRow(tf,t,end,ta,"HISTORICAL_SERVER");else tick_missing++;
        }
      MBA_OhlcCheck(rates[i],ta,tok,InpOhlcTolerancePoints,c.ohlc_status,c.ohlc_dev);
      c.tick_ok=tok;c.tick_count=tok?ta.tick_count:0;
      c.tick_density=tok?(double)ta.tick_count/MathMax(1.0,(double)MathMax(sec,60)/60.0):MBA_NaN();
      double mtc=0;if(tccnt>=3){double ss=0;for(int q=0;q<tccnt;q++)ss+=(double)tcbuf[q];mtc=ss/tccnt;}
      c.tick_density_ratio=(tok&&mtc>0)?(double)ta.tick_count/mtc:MBA_NaN();
      c.spread_avg=tok?MBA_SafeRatio(ta.spread_sum,(double)MathMax(1,ta.tick_count)):MBA_NaN();c.spread_max=tok?ta.spread_max:MBA_NaN();c.spread_min=tok?ta.spread_min:MBA_NaN();
      if(tok){int cap=MathMin(InpFeatureLookback,40);if(tccnt<cap){tcbuf[tccnt]=ta.tick_count;tccnt++;}else{for(int q=1;q<cap;q++)tcbuf[q-1]=tcbuf[q];tcbuf[cap-1]=ta.tick_count;}}
      c.pattern=MBA_Patterns(rates,i);c.structure_at_close=MBA_StateFromRates(rates,i,InpFeatureLookback);c.structure_before=MBA_StateFromRates(rates,i-1,InpFeatureLookback);
      c.vol_state=MBA_VolatilityState(MBA_SafeRatio(c.range,c.atr));
      double px=rates[i].close;
      double daily_open=MBA_OpenAtOrBefore(cD1,t),weekly_open=MBA_OpenAtOrBefore(cW1,t),monthly_open=MBA_OpenAtOrBefore(cMN1,t);
      c.d_open_pts=daily_open>0?(px-daily_open)/_Point:MBA_NaN();c.w_open_pts=weekly_open>0?(px-weekly_open)/_Point:MBA_NaN();c.m_open_pts=monthly_open>0?(px-monthly_open)/_Point:MBA_NaN();
      double pdh=0,pdl=0;MBA_PrevDayLevels(cD1,t,pdh,pdl);c.pdh_atr=MBA_DistATR(px,pdh,c.atr);c.pdl_atr=MBA_DistATR(px,pdl,c.atr);
      int lf=MathMax(0,i-InpFeatureLookback);double ph=rates[lf].high,pl=rates[lf].low;for(int j=lf;j<i;j++){ph=MathMax(ph,rates[j].high);pl=MathMin(pl,rates[j].low);}
      c.prev_high_atr=MBA_DistATR(px,ph,c.atr);c.prev_low_atr=MBA_DistATR(px,pl,c.atr);
      double shh=0,sll=0;MBA_SwingLevels(rates,i,shh,sll);c.swing_high_atr=MBA_DistATR(px,shh,c.atr);c.swing_low_atr=MBA_DistATR(px,sll,c.atr);
      c.sess_high_atr=MBA_NaN();c.sess_low_atr=MBA_NaN();
      if(sec>0&&sec<=3600)
        {
         MqlDateTime du;TimeToStruct(c.utc_time,du);datetime day0=c.utc_time-(datetime)(du.hour*3600+du.min*60+du.sec);
         datetime sess_start_server=day0+(datetime)(MBA_SessionStartHour(du.hour)*3600)+(datetime)off;
         double shi=0,slo=0;if(t>sess_start_server&&MBA_SessionLevels(cM1,sess_start_server,t,shi,slo)){c.sess_high_atr=MBA_DistATR(px,shi,c.atr);c.sess_low_atr=MBA_DistATR(px,slo,c.atr);}
        }
      c.mtf[0]=MBA_StateClosedAt(cM1,PERIOD_M1,t,InpFeatureLookback);c.mtf[1]=MBA_StateClosedAt(cM5,PERIOD_M5,t,InpFeatureLookback);c.mtf[2]=MBA_StateClosedAt(cM15,PERIOD_M15,t,InpFeatureLookback);c.mtf[3]=MBA_StateClosedAt(cM30,PERIOD_M30,t,InpFeatureLookback);
      c.mtf[4]=MBA_StateClosedAt(cH1,PERIOD_H1,t,InpFeatureLookback);c.mtf[5]=MBA_StateClosedAt(cH4,PERIOD_H4,t,InpFeatureLookback);c.mtf[6]=MBA_StateClosedAt(cD1,PERIOD_D1,t,InpFeatureLookback);c.mtf[7]=MBA_StateClosedAt(cW1,PERIOD_W1,t,InpFeatureLookback);c.mtf[8]=MBA_StateClosedAt(cMN1,PERIOD_MN1,t,InpFeatureLookback);
      c.news_n=0;c.news_high_n=0;c.news_min_next=MBA_NaN();c.news_min_since=MBA_NaN();
      if(!InpBuildNewsContext)c.news_state="DISABLED";
      else if(g_cal.Count()<=0)c.news_state="UNAVAILABLE";
      else{g_cal.Context(t,3600,c.news_n,c.news_high_n,c.news_min_next,c.news_min_since);c.news_state=(c.news_n>0?StringFormat("EVENTS_%d_AROUND_60M",c.news_n):"NONE_60M");}
      string f[];MBA_FillCandleRow(f,c);g_candles[tfIndex].WriteFields(f);
      MBA_FillEventRow(f,c);g_events[tfIndex].WriteFields(f);
      double atr=c.atr,vr=c.vr,tick_density=(tok?c.tick_density:0),spread_avg=(tok?c.spread_avg:0),tick_density_ratio=(tok?(MathIsValidNumber(c.tick_density_ratio)?c.tick_density_ratio:0):0);
      string pattern=c.pattern,structure=c.structure_before;string m15=c.mtf[2],h1=c.mtf[4];
      int fi=i+MathMin(5,InpForwardMaxBars);MBA_Exc x5;MBA_Excursion(rates,i,MathMin(5,InpForwardMaxBars),MBA_Direction(rates[i]),x5);
      double mfe5=x5.mfe,mae5=x5.mae;
      bool forward_up=rates[fi].close>rates[i].close;
      WriteForwardForBar(tfIndex,rates,i,atr,"HISTORICAL_SERVER");
      if(InpWriteTimeForward && ArraySize(g_hz)>0 && sec>0 && sec<=InpTimeFwdMaxTFSec)
        {
         MBA_TFwdEvent te;
         te.run_id=g_run_id;te.event_key=c.event_key;te.event_id=c.event_id;te.broker=g_broker;te.server=g_server;te.symbol=_Symbol;te.tf_name=c.tf_name;te.data_source="HISTORY";te.source="TIME_FORWARD_HISTORY";
         te.event_open=t;te.event_close=rates[i+1].time;te.ref=rates[i].close;te.atr=c.atr;te.spread_points=(double)rates[i].spread;te.commission_points=g_comm_points;te.dir=MBA_Direction(rates[i]);
         MBA_WriteTimeForward(g_tfwd[tfIndex],te,cM1,g_hz,g_ptgt);
        }
      UpdateStats(tfIndex,rates,i,vr,tick_density,spread_avg,mfe5,mae5,forward_up);
      UpdatePatternStats(tfIndex,rates,i,pattern,mfe5,mae5,forward_up);
      DiscoverForEvent(tfIndex,rates,i,atr,vr,tick_density_ratio,structure,m15,h1,mfe5,mae5,forward_up);
      processed++;g_total_events++;g_rows_since_flush++;if(g_rows_since_flush>=InpFlushEveryRows)FlushAll();
     }
   RecordIntegrity(tf,from_dt,to_dt,n,processed,gaps,tick_attempted,tick_missing);
  }

int OnStart()
  {
   g_broker=MBA_SafeToken(AccountInfoString(ACCOUNT_COMPANY));g_server=MBA_SafeToken(AccountInfoString(ACCOUNT_SERVER));
   g_run_id=StringFormat("HIST_%s_%s",MBA_SafeName(_Symbol),TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   datetime from_dt,to_dt;if(!GetRange(from_dt,to_dt)){Print("MBA: invalid date range.");return 1;}
   g_dst=MBA_ResolveDstMode((int)InpDstMode);
   MBA_ParseHorizons(InpTimeHorizonsMin,g_hz);g_ptgt[0]=InpTimeFwdTargetP1;g_ptgt[1]=InpTimeFwdTargetP2;g_ptgt[2]=InpTimeFwdTargetP3;
   {double tv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE),tsz=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);double vpp=(tsz>0?tv*_Point/tsz:0);g_comm_points=(InpCommissionPerLotDeclared>0&&vpp>0)?InpCommissionPerLotDeclared/vpp:0;}
   ResetStats();InitDiscoveryTable();if(!InitWriters())return 2;WriteRun(from_dt,to_dt);
   if(InpBuildNewsContext){g_cal.Load(from_dt-86400,to_dt+2*86400,InpNewsCurrencies,InpNewsMinImportance);WriteHistoricalNews(from_dt,to_dt);}
   for(int i=0;i<MBA_TF_COUNT;i++)ProcessTF(MBA_TFs[i],from_dt,to_dt);
   if(InpWriteHistoricalRawTicks)WriteRawTicksRange(from_dt,to_dt);
   WriteStats();FlushAll();
   Print("MBA history complete. Events: ",g_total_events," Run: ",g_run_id);
   return 0;
  }
