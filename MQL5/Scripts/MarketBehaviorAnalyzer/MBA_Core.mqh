//+------------------------------------------------------------------+
//| MBA_Core.mqh                                                     |
//| Market Behavior Research Engine - shared core                    |
//+------------------------------------------------------------------+
#property strict

#define MBA_TF_COUNT 8
#define MBA_MAX_FORWARD 10
#define MBA_SCHEMA_VERSION "2"
#define MBA_VERSION "1.22"

enum MBA_SESSION
  {
   MBA_SESSION_ASIA=0,
   MBA_SESSION_LONDON=1,
   MBA_SESSION_LONDON_NY=2,
   MBA_SESSION_NEW_YORK=3,
   MBA_SESSION_OFF=4
  };

struct MBA_TickAgg
  {
   long   tick_count;
   long   up_ticks;
   long   down_ticks;
   long   unchanged_ticks;
   double bid_min;
   double bid_max;
   double ask_min;
   double ask_max;
   double last_min;
   double last_max;
   double spread_min;
   double spread_max;
   double spread_sum;
   double tick_interval_sum_ms;
   long   tick_interval_count;
   ulong  first_time_msc;
   ulong  last_time_msc;
  };

struct MBA_Stat
  {
   long   n;
   long   bull;
   long   bear;
   long   doji;
   double range_sum;
   double range_sq_sum;
   double body_sum;
   double volume_sum;
   double volume_ratio_sum;
   double tick_density_sum;
   double spread_sum;
   long   forward_up;
   long   forward_down;
   double mfe_sum;
   double mae_sum;
  };

struct MBA_Discovery
  {
   string key;
   long   n;
   long   forward_up;
   long   forward_down;
   double mfe_sum;
   double mae_sum;
   double body_sum;
   double range_sum;
   double volume_ratio_sum;
  };

// Timeframes requested by the project.
ENUM_TIMEFRAMES MBA_TFs[MBA_TF_COUNT]=
  {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_W1,PERIOD_MN1};

string MBA_TFNames[MBA_TF_COUNT]=
  {"M1","M5","M15","M30","H1","H4","W1","MN1"};

string MBA_SafeName(string s)
  {
   StringReplace(s,"\\","_");
   StringReplace(s,"/","_");
   StringReplace(s,":","_");
   StringReplace(s,"*","_");
   StringReplace(s,"?","_");
   StringReplace(s,"\"","_");
   StringReplace(s,"<","_");
   StringReplace(s,">","_");
   StringReplace(s,"|","_");
   StringReplace(s,".","_");
   return s;
  }

string MBA_TFName(ENUM_TIMEFRAMES tf)
  {
   for(int i=0;i<MBA_TF_COUNT;i++)
      if(MBA_TFs[i]==tf) return MBA_TFNames[i];
   return IntegerToString((int)tf);
  }

int MBA_TFIndex(ENUM_TIMEFRAMES tf)
  {
   for(int i=0;i<MBA_TF_COUNT;i++)
      if(MBA_TFs[i]==tf) return i;
   return -1;
  }

int MBA_Digits()
  {
   return (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
  }

string MBA_DT(datetime t,bool seconds=true)
  {
   return TimeToString(t,seconds?(TIME_DATE|TIME_SECONDS):(TIME_DATE|TIME_MINUTES));
  }

string MBA_UInt64ToString(ulong v)
  {
   return StringFormat("%I64u",v);
  }

string MBA_TimeMS(ulong tms)
  {
   datetime t=(datetime)(tms/1000);
   int ms=(int)(tms%1000);
   return StringFormat("%s.%03d",MBA_DT(t,true),ms);
  }

string MBA_D(double v,int digits=8)
  {
   if(!MathIsValidNumber(v)) return "";
   return DoubleToString(v,digits);
  }

string MBA_L(long v)
  {
   return StringFormat("%I64d",v);
  }

string MBA_UD(ulong v)
  {
   return StringFormat("%I64u",v);
  }

string MBA_Bool(bool v)
  {
   return v?"TRUE":"FALSE";
  }

string MBA_Dir(int d)
  {
   if(d>0) return "BULLISH";
   if(d<0) return "BEARISH";
   return "DOJI";
  }

int MBA_Direction(const MqlRates &r)
  {
   if(r.close>r.open) return 1;
   if(r.close<r.open) return -1;
   return 0;
  }

double MBA_Range(const MqlRates &r)
  {
   return r.high-r.low;
  }

double MBA_Body(const MqlRates &r)
  {
   return MathAbs(r.close-r.open);
  }

double MBA_UpperWick(const MqlRates &r)
  {
   return r.high-MathMax(r.open,r.close);
  }

double MBA_LowerWick(const MqlRates &r)
  {
   return MathMin(r.open,r.close)-r.low;
  }

double MBA_SafeRatio(double a,double b)
  {
   if(b==0.0) return 0.0;
   return a/b;
  }

double MBA_ClosePosition(const MqlRates &r)
  {
   double range=r.high-r.low;
   if(range<=0.0) return 0.5;
   return (r.close-r.low)/range;
  }

string MBA_BucketPct(double pct)
  {
   double p=pct*100.0;
   if(p<10) return "00_10";
   if(p<20) return "10_20";
   if(p<30) return "20_30";
   if(p<40) return "30_40";
   if(p<50) return "40_50";
   if(p<60) return "50_60";
   if(p<70) return "60_70";
   if(p<80) return "70_80";
   if(p<90) return "80_90";
   return "90_100";
  }

string MBA_BucketRatio(double x)
  {
   if(x<0.25) return "00_025";
   if(x<0.50) return "025_050";
   if(x<0.75) return "050_075";
   if(x<1.00) return "075_100";
   if(x<1.25) return "100_125";
   if(x<1.50) return "125_150";
   if(x<1.75) return "150_175";
   if(x<2.00) return "175_200";
   if(x<2.50) return "200_250";
   if(x<3.00) return "250_300";
   return "300_PLUS";
  }

string MBA_BucketVolume(double x)
  {
   if(x<0.50) return "LT_050";
   if(x<0.75) return "050_075";
   if(x<1.00) return "075_100";
   if(x<1.25) return "100_125";
   if(x<1.50) return "125_150";
   if(x<2.00) return "150_200";
   if(x<3.00) return "200_300";
   return "300_PLUS";
  }

string MBA_BucketIntRatio(double x)
  {
   if(x<0.50) return "LT_050";
   if(x<0.75) return "050_075";
   if(x<1.00) return "075_100";
   if(x<1.25) return "100_125";
   if(x<1.50) return "125_150";
   if(x<2.00) return "150_200";
   if(x<3.00) return "200_300";
   return "300_PLUS";
  }

string MBA_BucketSigned(double x)
  {
   if(x<-2.0) return "LT_N2";
   if(x<-1.0) return "N2_N1";
   if(x<-0.25) return "N1_N025";
   if(x<0.25) return "N025_P025";
   if(x<1.0) return "P025_P1";
   if(x<2.0) return "P1_P2";
   return "P2_PLUS";
  }

string MBA_DayName(datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t,dt);
   switch(dt.day_of_week)
     {
      case 0: return "SUNDAY";
      case 1: return "MONDAY";
      case 2: return "TUESDAY";
      case 3: return "WEDNESDAY";
      case 4: return "THURSDAY";
      case 5: return "FRIDAY";
      case 6: return "SATURDAY";
     }
   return "UNKNOWN";
  }

int MBA_DayOfWeek(datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt); return dt.day_of_week;
  }

int MBA_MinuteOfDay(datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt); return dt.hour*60+dt.min;
  }

int MBA_Hour(datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt); return dt.hour;
  }

int MBA_Minute(datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt); return dt.min;
  }

datetime MBA_AnalysisTime(datetime server_time,int offset_hours)
  {
   return server_time+(datetime)(offset_hours*3600);
  }

string MBA_Session(datetime analysis_time)
  {
   MqlDateTime dt; TimeToStruct(analysis_time,dt);
   int h=dt.hour;
   if(h>=0 && h<8) return "ASIA";
   if(h>=8 && h<13) return "LONDON";
   if(h>=13 && h<17) return "LONDON_NY_OVERLAP";
   if(h>=17 && h<22) return "NEW_YORK";
   return "OFF_SESSION";
  }

string MBA_StateFromRates(const MqlRates &rates[],int idx,int lookback=20)
  {
   if(idx<1) return "UNKNOWN";
   int a=MathMax(0,idx-lookback);
   int n=idx-a;
   if(n<3) return "UNKNOWN";

   double sum10=0,sum20=0;
   int n10=MathMin(10,n);
   int n20=MathMin(20,n);
   for(int i=idx-n10;i<idx;i++) sum10+=rates[i].close;
   for(int i=idx-n20;i<idx;i++) sum20+=rates[i].close;
   double sma10=sum10/n10;
   double sma20=sum20/n20;

   double ph=rates[a].high,pl=rates[a].low;
   for(int i=a+1;i<idx;i++)
     {
      ph=MathMax(ph,rates[i].high);
      pl=MathMin(pl,rates[i].low);
     }

   if(rates[idx].close>ph) return "BREAK_UP";
   if(rates[idx].close<pl) return "BREAK_DOWN";
   if(sma10>sma20 && rates[idx].close>sma20) return "BULLISH";
   if(sma10<sma20 && rates[idx].close<sma20) return "BEARISH";
   return "RANGE";
  }

string MBA_GetStateAtOrBefore(const MqlRates &rates[],datetime event_open,int lookback=20)
  {
   int n=ArraySize(rates);
   if(n<=0) return "UNKNOWN";
   int lo=0,hi=n-1,best=-1;
   while(lo<=hi)
     {
      int mid=(lo+hi)/2;
      if(rates[mid].time<event_open)
        { best=mid; lo=mid+1; }
      else hi=mid-1;
     }
   if(best<1) return "UNKNOWN";
   return MBA_StateFromRates(rates,best,lookback);
  }

int MBA_FindIndexBefore(const MqlRates &rates[],datetime t)
  {
   int n=ArraySize(rates);
   int lo=0,hi=n-1,best=-1;
   while(lo<=hi)
     {
      int mid=(lo+hi)/2;
      if(rates[mid].time<t)
        { best=mid; lo=mid+1; }
      else hi=mid-1;
     }
   return best;
  }

double MBA_ATRAt(const MqlRates &rates[],int idx,int period=14)
  {
   if(idx<1) return 0.0;
   int from=MathMax(1,idx-period+1);
   int n=idx-from+1;
   if(n<=0) return 0.0;
   double sum=0;
   for(int i=from;i<=idx;i++)
     {
      double prevClose=rates[i-1].close;
      double tr=MathMax(rates[i].high-rates[i].low,
                        MathMax(MathAbs(rates[i].high-prevClose),MathAbs(rates[i].low-prevClose)));
      sum+=tr;
     }
   return sum/n;
  }

double MBA_AvgRangeAt(const MqlRates &rates[],int idx,int lookback=20)
  {
   if(idx<=0) return 0.0;
   int from=MathMax(0,idx-lookback);
   int to=idx-1;
   if(to<from) return 0.0;
   double s=0; int n=0;
   for(int i=from;i<=to;i++){s+=MBA_Range(rates[i]);n++;}
   return n>0?s/n:0.0;
  }

double MBA_AvgTickVolumeAt(const MqlRates &rates[],int idx,int lookback=20)
  {
   if(idx<=0) return 0.0;
   int from=MathMax(0,idx-lookback);
   int to=idx-1;
   double s=0; int n=0;
   for(int i=from;i<=to;i++){s+=(double)rates[i].tick_volume;n++;}
   return n>0?s/n:0.0;
  }

bool MBA_IsDoji(const MqlRates &r)
  {
   double range=MBA_Range(r); if(range<=0) return true;
   return MBA_SafeRatio(MBA_Body(r),range)<=0.10;
  }

bool MBA_IsHammer(const MqlRates &r)
  {
   double range=MBA_Range(r); if(range<=0) return false;
   double body=MBA_Body(r),uw=MBA_UpperWick(r),lw=MBA_LowerWick(r);
   return (lw>=body*2.0 && uw<=body && MBA_SafeRatio(body,range)<=0.45 && MBA_ClosePosition(r)>=0.55);
  }

bool MBA_IsInvertedHammer(const MqlRates &r)
  {
   double range=MBA_Range(r); if(range<=0) return false;
   double body=MBA_Body(r),uw=MBA_UpperWick(r),lw=MBA_LowerWick(r);
   return (uw>=body*2.0 && lw<=body && MBA_SafeRatio(body,range)<=0.45 && MBA_ClosePosition(r)<=0.60);
  }

bool MBA_IsShootingStar(const MqlRates &r)
  {
   return MBA_IsInvertedHammer(r) && r.close<=r.open;
  }

bool MBA_IsHangingMan(const MqlRates &r)
  {
   return MBA_IsHammer(r) && r.close<=r.open;
  }

bool MBA_IsBullEngulf(const MqlRates &prev,const MqlRates &r)
  {
   return prev.close<prev.open && r.close>r.open && r.open<=prev.close && r.close>=prev.open;
  }

bool MBA_IsBearEngulf(const MqlRates &prev,const MqlRates &r)
  {
   return prev.close>prev.open && r.close<r.open && r.open>=prev.close && r.close<=prev.open;
  }

bool MBA_IsInsideBar(const MqlRates &prev,const MqlRates &r)
  {
   return r.high<prev.high && r.low>prev.low;
  }

bool MBA_IsOutsideBar(const MqlRates &prev,const MqlRates &r)
  {
   return r.high>prev.high && r.low<prev.low;
  }

bool MBA_IsPinBar(const MqlRates &r)
  {
   double body=MBA_Body(r),range=MBA_Range(r); if(range<=0) return false;
   return (MathMax(MBA_UpperWick(r),MBA_LowerWick(r))>=body*2.5 && MBA_SafeRatio(body,range)<=0.40);
  }

bool MBA_IsMarubozu(const MqlRates &r)
  {
   double range=MBA_Range(r); if(range<=0) return false;
   return MBA_SafeRatio(MBA_UpperWick(r)+MBA_LowerWick(r),range)<=0.08;
  }

bool MBA_IsHarami(const MqlRates &prev,const MqlRates &r)
  {
   double pHi=MathMax(prev.open,prev.close),pLo=MathMin(prev.open,prev.close);
   double cHi=MathMax(r.open,r.close),cLo=MathMin(r.open,r.close);
   return MBA_Body(r)<MBA_Body(prev) && cHi<pHi && cLo>pLo;
  }

bool MBA_IsTweezerTop(const MqlRates &prev,const MqlRates &r)
  {
   return MathAbs(prev.high-r.high)<=10*_Point && prev.close>prev.open && r.close<r.open;
  }

bool MBA_IsTweezerBottom(const MqlRates &prev,const MqlRates &r)
  {
   return MathAbs(prev.low-r.low)<=10*_Point && prev.close<prev.open && r.close>r.open;
  }

string MBA_Patterns(const MqlRates &rates[],int idx)
  {
   if(idx<1) return "";
   MqlRates r=rates[idx];
   MqlRates p=rates[idx-1];
   string s="";
   if(MBA_IsDoji(r)) s+="DOJI|";
   if(MBA_IsHammer(r)) s+="HAMMER|";
   if(MBA_IsInvertedHammer(r)) s+="INVERTED_HAMMER|";
   if(MBA_IsShootingStar(r)) s+="SHOOTING_STAR|";
   if(MBA_IsHangingMan(r)) s+="HANGING_MAN|";
   if(MBA_IsBullEngulf(p,r)) s+="BULLISH_ENGULFING|";
   if(MBA_IsBearEngulf(p,r)) s+="BEARISH_ENGULFING|";
   if(MBA_IsInsideBar(p,r)) s+="INSIDE_BAR|";
   if(MBA_IsOutsideBar(p,r)) s+="OUTSIDE_BAR|";
   if(MBA_IsPinBar(r)) s+="PIN_BAR|";
   if(MBA_IsMarubozu(r)) s+="MARUBOZU|";
   if(MBA_IsHarami(p,r)) s+="HARAMI|";
   if(MBA_IsTweezerTop(p,r)) s+="TWEEZER_TOP|";
   if(MBA_IsTweezerBottom(p,r)) s+="TWEEZER_BOTTOM|";

   if(idx>=2)
     {
      MqlRates p2=rates[idx-2];
      int d2=MBA_Direction(p2),d1=MBA_Direction(p),d0=MBA_Direction(r);
      if(d2<0 && d1<0 && d0>0) s+="MORNING_STAR_3BAR|";
      if(d2>0 && d1>0 && d0<0) s+="EVENING_STAR_3BAR|";
     }
   if(StringLen(s)>0) StringSetCharacter(s,StringLen(s)-1,' ');
   StringReplace(s," ","");
   return s;
  }

void MBA_ResetTickAgg(MBA_TickAgg &a)
  {
   a.tick_count=0; a.up_ticks=0; a.down_ticks=0; a.unchanged_ticks=0;
   a.bid_min=DBL_MAX; a.bid_max=-DBL_MAX;
   a.ask_min=DBL_MAX; a.ask_max=-DBL_MAX;
   a.last_min=DBL_MAX; a.last_max=-DBL_MAX;
   a.spread_min=DBL_MAX; a.spread_max=-DBL_MAX; a.spread_sum=0;
   a.tick_interval_sum_ms=0; a.tick_interval_count=0;
   a.first_time_msc=0; a.last_time_msc=0;
  }

void MBA_AccumulateTick(MBA_TickAgg &a,const MqlTick &tk,double prev_price,bool has_prev)
  {
   double mid=(tk.bid>0 && tk.ask>0)?(tk.bid+tk.ask)/2.0:((tk.last>0)?tk.last:tk.bid);
   double spread=(tk.bid>0 && tk.ask>0)?(tk.ask-tk.bid)/_Point:0.0;
   a.tick_count++;
   if(a.first_time_msc==0) a.first_time_msc=tk.time_msc;
   if(a.last_time_msc>0)
     {
      ulong dt=tk.time_msc-a.last_time_msc;
      a.tick_interval_sum_ms+=(double)dt;
      a.tick_interval_count++;
     }
   a.last_time_msc=tk.time_msc;
   if(tk.bid>0){a.bid_min=MathMin(a.bid_min,tk.bid);a.bid_max=MathMax(a.bid_max,tk.bid);}
   if(tk.ask>0){a.ask_min=MathMin(a.ask_min,tk.ask);a.ask_max=MathMax(a.ask_max,tk.ask);}
   double lp=tk.last>0?tk.last:mid;
   if(lp>0){a.last_min=MathMin(a.last_min,lp);a.last_max=MathMax(a.last_max,lp);}
   if(spread>0){a.spread_min=MathMin(a.spread_min,spread);a.spread_max=MathMax(a.spread_max,spread);a.spread_sum+=spread;}
   if(has_prev)
     {
      if(lp>prev_price) a.up_ticks++;
      else if(lp<prev_price) a.down_ticks++;
      else a.unchanged_ticks++;
     }
  }

bool MBA_CopyTickAggregate(string symbol,datetime from_time,datetime to_time,MBA_TickAgg &agg,bool capture_raw=false,string raw_prefix="")
  {
   MBA_ResetTickAgg(agg);
   ulong from_msc=(ulong)from_time*1000ULL;
   ulong to_msc=(ulong)to_time*1000ULL+999ULL;
   MqlTick ticks[];
   int copied=CopyTicksRange(symbol,ticks,COPY_TICKS_ALL,from_msc,to_msc);
   if(copied<=0) return false;
   double prev=0; bool has=false;
   for(int i=0;i<copied;i++)
     {
      MBA_AccumulateTick(agg,ticks[i],prev,has);
      double lp=ticks[i].last>0?ticks[i].last:((ticks[i].bid>0&&ticks[i].ask>0)?(ticks[i].bid+ticks[i].ask)/2.0:ticks[i].bid);
      if(lp>0){prev=lp;has=true;}
     }
   return true;
  }

string MBA_TickAggHeader()
  {
   return "symbol,timeframe,start_time,end_time,tick_count,up_ticks,down_ticks,unchanged_ticks,up_ratio,down_ratio,bid_min,bid_max,ask_min,ask_max,last_min,last_max,spread_min_points,spread_max_points,spread_avg_points,avg_tick_interval_ms,tick_density_per_minute,source";
  }

string MBA_CandleHeader()
  {
   return "run_id,event_id,event_key,broker,server,symbol,timeframe,data_source,server_time,analysis_time,utc_time,server_utc_offset_sec,utc_basis,day_of_week,hour,minute,minute_of_day,slot_hhmm,week_start,session,open,high,low,close,range,body,upper_wick,lower_wick,body_pct,upper_wick_pct,lower_wick_pct,close_position,direction,true_range,atr,range_atr,tick_volume,real_volume,volume_avg,volume_ratio,tick_count,tick_data_ok,tick_density_per_minute,tick_density_ratio,spread_avg_points,spread_max_points,spread_min_points,range_bucket,body_bucket,volume_bucket,pattern,structure_before,structure_at_close,volatility_state,gap_bars,source,schema_version";
  }

string MBA_EventHeader()
  {
   return "run_id,event_id,event_key,broker,server,symbol,timeframe,data_source,server_time,analysis_time,day_of_week,hour,minute,slot_hhmm,week_start,session,direction,body_pct,upper_wick_pct,lower_wick_pct,close_position,range_atr,volume_ratio,tick_density_ratio,spread_avg_points,pattern,structure_before,structure_at_close,volatility_state,price_position_daily_open,price_position_weekly_open,price_position_monthly_open,previous_high_distance_atr,previous_low_distance_atr,prev_day_high_distance_atr,prev_day_low_distance_atr,session_high_distance_atr,session_low_distance_atr,swing_high_distance_atr,swing_low_distance_atr,mtf_M1,mtf_M5,mtf_M15,mtf_M30,mtf_H1,mtf_H4,mtf_W1,mtf_MN1,mtf_basis,news_state,news_events_60m,news_high_events_60m,news_min_to_next_high,news_min_since_last_high,gap_bars,source,schema_version";
  }

string MBA_ForwardHeader()
  {
   return "run_id,forward_key,event_key,event_id,broker,server,symbol,timeframe,data_source,event_time,horizon_bars,future_time,future_close,future_return_points,future_return_atr,future_high,future_low,mfe_points,mae_points,mfe_atr,mae_atr,time_to_mfe_bars,time_to_mae_bars,direction_after,mfe_mae_basis,source,schema_version";
  }

string MBA_RunHeader()
  {
   return "run_id,mode,symbol,server_time,start_range,end_range,analysis_offset_hours,part_size_mb,write_raw_ticks,write_historical_ticks,version";
  }

string MBA_NewsHeader()
  {
   return "run_id,event_id,calendar_value_id,event_time_server,event_time_utc,period,revision,actual_value,prev_value,revised_prev_value,forecast_value,impact_type,importance,currency,country_code,event_name,event_type,sector,source,schema_version";
  }

string MBA_DOMLevelHeader()
  {
   return "run_id,symbol,event_time,level_index,type,price,volume,volume_real,source";
  }

string MBA_DOMSnapshotHeader()
  {
   return "run_id,symbol,event_time,best_bid,best_ask,spread_points,total_bid_volume,total_ask_volume,imbalance,levels,source";
  }

// Returns the theoretical next bar open time for a timeframe.
datetime MBA_NextBarTime(datetime bar_time,ENUM_TIMEFRAMES tf)
  {
   // Used only when an explicit next bar timestamp is not available.
   int sec=PeriodSeconds(tf);
   if(sec>0) return bar_time+sec;
   if(tf==PERIOD_W1) return bar_time+7*86400;
   if(tf==PERIOD_MN1)
     {
      MqlDateTime d; TimeToStruct(bar_time,d);
      d.day=1; d.hour=0; d.min=0; d.sec=0;
      if(d.mon==12){d.mon=1;d.year++;}
      else d.mon++;
      return StructToTime(d);
     }
   return bar_time+60;
  }

string MBA_VolatilityState(double range_atr,double range_percentile=0.0)
  {
   if(range_atr<=0) return "UNKNOWN";
   if(range_atr<0.50) return "VERY_LOW";
   if(range_atr<0.85) return "LOW";
   if(range_atr<1.25) return "NORMAL";
   if(range_atr<1.75) return "HIGH";
   return "EXTREME";
  }

string MBA_StructureState(const MqlRates &rates[],int idx,int lookback=20)
  {
   return MBA_StateFromRates(rates,idx,lookback);
  }

// Add field to a dynamic string array.
void MBA_Add(string &a[],string value)
  {
   int n=ArraySize(a); ArrayResize(a,n+1); a[n]=value;
  }

void MBA_AddD(string &a[],double value,int digits=8)
  {
   MBA_Add(a,MBA_D(value,digits));
  }

void MBA_AddL(string &a[],long value)
  {
   MBA_Add(a,MBA_L(value));
  }

void MBA_AddU(string &a[],ulong value)
  {
   MBA_Add(a,MBA_UD(value));
  }

// CSV escape for strings; numeric fields remain safe as-is.
string MBA_CSVEscape(string s)
  {
   if(StringFind(s,",")>=0 || StringFind(s,"\"")>=0 || StringFind(s,"\n")>=0 || StringFind(s,"\r")>=0)
     {
      StringReplace(s,"\"","\"\"");
      return "\""+s+"\"";
     }
   return s;
  }

class CMBAWriter
  {
private:
   string m_root;
   string m_base;
   string m_header;
   long   m_max_bytes;
   bool   m_common;
   int    m_handle;
   int    m_part;
   long   m_rows;
   long   m_total_rows;

   string PartName(int part)
     {
      return StringFormat("%s\\%s_part%03d.csv",m_root,m_base,part);
     }

   bool OpenPart(int part,bool append)
     {
      if(m_handle!=INVALID_HANDLE) FileClose(m_handle);
      m_part=part;
      string fn=PartName(part);
      int flags=FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE;
      if(m_common) flags|=FILE_COMMON;
      m_handle=FileOpen(fn,flags,0,CP_UTF8);
      if(m_handle==INVALID_HANDLE) return false;
      FileSeek(m_handle,0,SEEK_END);
      long sz=(long)FileGetInteger(m_handle,FILE_SIZE);
      if(sz==0 && StringLen(m_header)>0)
        {
         FileWriteString(m_handle,m_header+"\r\n");
         FileFlush(m_handle);
        }
      return true;
     }

   int FindLastPart()
     {
      int p=1;
      while(true)
        {
         string fn=PartName(p);
         if(!FileIsExist(fn,m_common?FILE_COMMON:0)) break;
         p++;
         if(p>100000) break;
        }
      return MathMax(1,p-1);
     }

public:
   CMBAWriter(){m_handle=INVALID_HANDLE;m_part=0;m_rows=0;m_total_rows=0;m_common=false;m_max_bytes=25*1024*1024;}
   ~CMBAWriter(){Close();}

   bool Init(string root,string base,string header,long max_bytes,bool common)
     {
      m_root=root; m_base=base; m_header=header; m_max_bytes=max_bytes; m_common=common;
      int last=FindLastPart();
      string fn=PartName(last);
      long sz=0;
      if(FileIsExist(fn,common?FILE_COMMON:0))
        {
         int h=FileOpen(fn,FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE|(common?FILE_COMMON:0),0,CP_UTF8);
         if(h!=INVALID_HANDLE){sz=(long)FileGetInteger(h,FILE_SIZE);FileClose(h);}
        }
      if(sz>=m_max_bytes && last<100000) last++;
      // Schema safety: never append rows to a part written with a different header.
      else if(sz>0 && StringLen(m_header)>0 && FirstLine(last)!=m_header && last<100000) last++;
      return OpenPart(last,true);
     }

   // First line (header) of a part, without CR/LF. Empty when the part does not exist.
   string FirstLine(int part)
     {
      string fn=PartName(part);
      if(!FileIsExist(fn,m_common?FILE_COMMON:0)) return "";
      int h=FileOpen(fn,FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE|(m_common?FILE_COMMON:0),0,CP_UTF8);
      if(h==INVALID_HANDLE) return "";
      string line="";
      if(!FileIsEnding(h)) line=FileReadString(h);
      FileClose(h);
      StringReplace(line,"\r","");
      return line;
     }

   // Last data line of the newest part that has the current header. Used to resume without duplicating rows.
   string LastDataLine()
     {
      for(int p=m_part;p>=1;p--)
        {
         if(FirstLine(p)!=m_header) continue;
         string fn=PartName(p);
         int h=FileOpen(fn,FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE|(m_common?FILE_COMMON:0),0,CP_UTF8);
         if(h==INVALID_HANDLE) continue;
         string last="";
         bool first=true;
         while(!FileIsEnding(h))
           {
            string ln=FileReadString(h);
            if(first){first=false;continue;}
            StringReplace(ln,"\r","");
            if(StringLen(ln)>0) last=ln;
           }
         FileClose(h);
         if(StringLen(last)>0) return last;
        }
      return "";
     }

   // Loads "col_a|col_b|col_c" keys of every row of every part that has the current header (comma split; columns must precede free-text fields).
   int LoadKeys(string &keys[],int col_a,int col_b,int col_c,int max_keys=50000)
     {
      ArrayResize(keys,0);
      for(int p=1;p<=m_part;p++)
        {
         if(FirstLine(p)!=m_header) continue;
         int h=FileOpen(PartName(p),FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE|(m_common?FILE_COMMON:0),0,CP_UTF8);
         if(h==INVALID_HANDLE) continue;
         bool first=true;
         while(!FileIsEnding(h))
           {
            string ln=FileReadString(h);
            if(first){first=false;continue;}
            StringReplace(ln,"\r","");
            string c[];
            int n=StringSplit(ln,',',c);
            if(n<=MathMax(col_a,MathMax(col_b,col_c))) continue;
            int k=ArraySize(keys);
            if(k>=max_keys) break;
            ArrayResize(keys,k+1);
            keys[k]=c[col_a]+"|"+c[col_b]+"|"+c[col_c];
           }
         FileClose(h);
        }
      return ArraySize(keys);
     }

   void Close()
     {
      if(m_handle!=INVALID_HANDLE){FileFlush(m_handle);FileClose(m_handle);m_handle=INVALID_HANDLE;}
     }

   bool WriteFields(string &fields[])
     {
      if(m_handle==INVALID_HANDLE) return false;
      string line="";
      int n=ArraySize(fields);
      for(int i=0;i<n;i++)
        {
         if(i>0) line+=",";
         line+=MBA_CSVEscape(fields[i]);
        }
      return WriteLine(line);
     }

   bool WriteLine(string line)
     {
      if(m_handle==INVALID_HANDLE) return false;
      long current=(long)FileGetInteger(m_handle,FILE_SIZE);
      long projected=current+(long)StringLen(line)+2;
      if(m_max_bytes>0 && current>0 && projected>m_max_bytes)
        {
         if(!OpenPart(m_part+1,false)) return false;
         current=(long)FileGetInteger(m_handle,FILE_SIZE);
        }
      FileWriteString(m_handle,line+"\r\n");
      m_rows++;m_total_rows++;
      return true;
     }

   void Flush(){if(m_handle!=INVALID_HANDLE) FileFlush(m_handle);}
   int Part(){return m_part;}
   long Rows(){return m_rows;}
   long TotalRows(){return m_total_rows;}
  };

string MBA_MTFStateString(const string &m1,const string &m5,const string &m15,const string &m30,const string &h1,const string &h4,const string &w1,const string &mn1)
  {
   return "M1="+m1+"|M5="+m5+"|M15="+m15+"|M30="+m30+"|H1="+h1+"|H4="+h4+"|W1="+w1+"|MN1="+mn1;
  }

//+------------------------------------------------------------------+
//| v1.10 additions                                                  |
//+------------------------------------------------------------------+
double MBA_NaN(){return MathSqrt(-1.0);}

// Current broker server offset from UTC in seconds (server = UTC + offset; e.g. UTC+3 -> +10800), rounded to 15 min. Valid for "now" only.
int MBA_ServerOffsetSec()
  {
   long d=(long)(TimeTradeServer()-TimeGMT());
   return (int)(MathRound((double)d/900.0)*900.0);
  }

string MBA_SafeToken(string s,int max_len=28)
  {
   string out="";
   int n=StringLen(s);
   for(int i=0;i<n && StringLen(out)<max_len;i++)
     {
      ushort c=StringGetCharacter(s,i);
      bool ok=(c>='0'&&c<='9')||(c>='A'&&c<='Z')||(c>='a'&&c<='z')||c=='-'||c=='_';
      out+=ok?ShortToString(c):"_";
     }
   if(StringLen(out)==0) out="UNKNOWN";
   return out;
  }

string MBA_SlotHHMM(datetime at)
  {
   MqlDateTime dt; TimeToStruct(at,dt);
   return StringFormat("%02d:%02d",dt.hour,dt.min);
  }

// Monday (date only) of the week of the analysis time: stable block id for independent-sample analysis.
string MBA_WeekStart(datetime at)
  {
   MqlDateTime dt; TimeToStruct(at,dt);
   int back=(dt.day_of_week+6)%7;
   datetime day=at-(datetime)(dt.hour*3600+dt.min*60+dt.sec);
   return TimeToString(day-(datetime)back*86400,TIME_DATE);
  }

// Session start hour on the analysis clock (same boundaries as MBA_Session).
int MBA_SessionStartHour(int hour)
  {
   if(hour>=22) return 22;
   if(hour>=17) return 17;
   if(hour>=13) return 13;
   if(hour>=8)  return 8;
   return 0;
  }

// Largest index with rates[idx].time<=t (rates ascending). -1 when none.
int MBA_IdxAtOrBefore(const MqlRates &a[],datetime t)
  {
   int n=ArraySize(a),lo=0,hi=n-1,best=-1;
   while(lo<=hi)
     {
      int mid=(lo+hi)/2;
      if(a[mid].time<=t){best=mid;lo=mid+1;}
      else hi=mid-1;
     }
   return best;
  }

double MBA_OpenAtOrBefore(const MqlRates &a[],datetime t)
  {
   int i=MBA_IdxAtOrBefore(a,t);
   return i>=0?a[i].open:0.0;
  }

// Previous completed day high/low relative to time t (d1 ascending).
bool MBA_PrevDayLevels(const MqlRates &d1[],datetime t,double &h,double &l)
  {
   int i=MBA_IdxAtOrBefore(d1,t);
   if(i<1){h=0;l=0;return false;}
   h=d1[i-1].high;l=d1[i-1].low;return true;
  }

// Most recent confirmed 2-left/2-right fractal swings strictly before the event bar (needs idx-3 or older).
void MBA_SwingLevels(const MqlRates &r[],int idx,double &sh,double &sl,int max_back=100)
  {
   sh=0;sl=0;
   int from=idx-3,to=MathMax(2,idx-max_back);
   bool gh=false,gl=false;
   for(int j=from;j>=to;j--)
     {
      if(!gh && r[j].high>r[j-1].high && r[j].high>r[j-2].high && r[j].high>=r[j+1].high && r[j].high>=r[j+2].high){sh=r[j].high;gh=true;}
      if(!gl && r[j].low<r[j-1].low && r[j].low<r[j-2].low && r[j].low<=r[j+1].low && r[j].low<=r[j+2].low){sl=r[j].low;gl=true;}
      if(gh&&gl)break;
     }
  }

// High/low of M1 bars in [sess_start_server, event_open) (m1 ascending). False when no bar.
bool MBA_SessionLevels(const MqlRates &m1[],datetime sess_start_server,datetime event_open,double &hi,double &lo)
  {
   bool any=false;hi=0;lo=0;
   int e=MBA_IdxAtOrBefore(m1,event_open-1);
   for(int i=e;i>=0;i--)
     {
      if(m1[i].time<sess_start_server)break;
      if(!any){hi=m1[i].high;lo=m1[i].low;any=true;}
      else {hi=MathMax(hi,m1[i].high);lo=MathMin(lo,m1[i].low);}
     }
   return any;
  }

// Higher-timeframe state using ONLY bars already closed at event_close (no look-ahead into the forming bar).
string MBA_StateClosedAt(const MqlRates &r[],ENUM_TIMEFRAMES htf,datetime event_close,int lookback=20)
  {
   int n=ArraySize(r);
   if(n<=0) return "UNKNOWN";
   int sec=PeriodSeconds(htf);
   int lo=0,hi=n-1,best=-1;
   while(lo<=hi)
     {
      int mid=(lo+hi)/2;
      bool closed;
      if(htf==PERIOD_MN1) closed=(mid+1<n && r[mid+1].time<=event_close);
      else closed=(sec>0 && r[mid].time+sec<=event_close);
      if(closed){best=mid;lo=mid+1;}
      else hi=mid-1;
     }
   if(best<1) return "UNKNOWN";
   return MBA_StateFromRates(r,best,lookback);
  }

// Distance of price to a level in ATR units; NaN when level or ATR is unavailable.
double MBA_DistATR(double price,double level,double atr)
  {
   if(level<=0 || atr<=0) return MBA_NaN();
   return (price-level)/atr;
  }

//+------------------------------------------------------------------+
//| Economic calendar context (importance/currency filtered)         |
//+------------------------------------------------------------------+
class CMBANews
  {
private:
   datetime m_time[];
   int      m_imp[];
   ulong    m_cache_id[];
   int      m_cache_imp[];
   string   m_cache_cur[];

   int CacheIndex(ulong event_id)
     {
      for(int i=0;i<ArraySize(m_cache_id);i++) if(m_cache_id[i]==event_id) return i;
      MqlCalendarEvent ev;
      int imp=0; string cur="";
      if(CalendarEventById(event_id,ev))
        {
         imp=(int)ev.importance;
         MqlCalendarCountry c;
         if(CalendarCountryById(ev.country_id,c)) cur=c.currency;
        }
      int k=ArraySize(m_cache_id);
      ArrayResize(m_cache_id,k+1);ArrayResize(m_cache_imp,k+1);ArrayResize(m_cache_cur,k+1);
      m_cache_id[k]=event_id;m_cache_imp[k]=imp;m_cache_cur[k]=cur;
      return k;
     }

public:
   int Importance(ulong event_id){return m_cache_imp[CacheIndex(event_id)];}
   string Currency(ulong event_id){return m_cache_cur[CacheIndex(event_id)];}

   // Loads [from,to]; currencies="USD,EUR" ("" = all). Keeps events with importance>=min_importance (0..3).
   int Load(datetime from,datetime to,string currencies,int min_importance)
     {
      ArrayResize(m_time,0);ArrayResize(m_imp,0);
      string cur[];
      int nc=0;
      if(StringLen(currencies)>0) nc=StringSplit(currencies,',',cur);
      int passes=MathMax(1,nc);
      for(int p=0;p<passes;p++)
        {
         MqlCalendarValue v[];
         string c="";
         if(nc>0){c=cur[p];StringTrimLeft(c);StringTrimRight(c);}
         int n=(nc>0)?CalendarValueHistory(v,from,to,NULL,c):CalendarValueHistory(v,from,to,NULL,NULL);
         for(int i=0;i<n;i++)
           {
            int imp=Importance(v[i].event_id);
            if(imp<min_importance) continue;
            int k=ArraySize(m_time);
            ArrayResize(m_time,k+1);ArrayResize(m_imp,k+1);
            m_time[k]=v[i].time;m_imp[k]=imp;
           }
        }
      // insertion sort (calendar is almost sorted already)
      int n2=ArraySize(m_time);
      for(int i=1;i<n2;i++)
        {
         datetime tt=m_time[i];int ii=m_imp[i];int j=i-1;
         while(j>=0 && m_time[j]>tt){m_time[j+1]=m_time[j];m_imp[j+1]=m_imp[j];j--;}
         m_time[j+1]=tt;m_imp[j+1]=ii;
        }
      return n2;
     }

   int Count(){return ArraySize(m_time);}

   // Context around t: events within +/-window_sec, high-importance counts, minutes to next/since last high-importance event (within 24h).
   void Context(datetime t,int window_sec,int &n,int &n_high,double &min_to_next_high,double &min_since_high)
     {
      n=0;n_high=0;min_to_next_high=MBA_NaN();min_since_high=MBA_NaN();
      int total=ArraySize(m_time);
      if(total<=0) return;
      int lo=0,hi=total;
      while(lo<hi){int mid=(lo+hi)/2; if(m_time[mid]<t-window_sec) lo=mid+1; else hi=mid;}
      for(int i=lo;i<total && m_time[i]<=t+window_sec;i++){n++;if(m_imp[i]>=3)n_high++;}
      int pos=lo;
      while(pos<total && m_time[pos]<t) pos++;
      for(int i=pos;i<total && m_time[i]<=t+86400;i++) if(m_imp[i]>=3){min_to_next_high=(double)(m_time[i]-t)/60.0;break;}
      for(int i=pos-1;i>=0 && m_time[i]>=t-86400;i--) if(m_imp[i]>=3){min_since_high=(double)(t-m_time[i])/60.0;break;}
     }
  };

//+------------------------------------------------------------------+
//| One bar worth of data shared by the live EA and the history tool |
//+------------------------------------------------------------------+
struct MBA_BarCtx
  {
   string   run_id;
   string   event_id;
   string   event_key;
   string   broker;
   string   server;
   string   data_source;
   string   symbol;
   string   tf_name;
   string   source;
   string   utc_basis;
   datetime server_time;
   datetime analysis_time;
   datetime utc_time;
   int      utc_offset_sec;
   int      gap_bars;
   MqlRates bar;
   double   range,body,uw,lw,true_range,atr,avg_tv,vr;
   long     tick_count;
   bool     tick_ok;
   double   tick_density,tick_density_ratio,spread_avg,spread_max,spread_min;
   string   pattern,structure_before,structure_at_close,vol_state;
   double   d_open_pts,w_open_pts,m_open_pts;
   double   prev_high_atr,prev_low_atr,pdh_atr,pdl_atr,sess_high_atr,sess_low_atr,swing_high_atr,swing_low_atr;
   string   mtf[8];
   string   news_state;
   int      news_n,news_high_n;
   double   news_min_next,news_min_since;
  };

void MBA_FillCandleRow(string &f[],const MBA_BarCtx &c)
  {
   ArrayResize(f,0);
   MBA_Add(f,c.run_id);MBA_Add(f,c.event_id);MBA_Add(f,c.event_key);MBA_Add(f,c.broker);MBA_Add(f,c.server);MBA_Add(f,c.symbol);MBA_Add(f,c.tf_name);MBA_Add(f,c.data_source);
   MBA_Add(f,MBA_DT(c.server_time,true));MBA_Add(f,MBA_DT(c.analysis_time,true));MBA_Add(f,MBA_DT(c.utc_time,true));
   MBA_AddL(f,c.utc_offset_sec);MBA_Add(f,c.utc_basis);
   MBA_Add(f,MBA_DayName(c.analysis_time));MBA_AddL(f,MBA_Hour(c.analysis_time));MBA_AddL(f,MBA_Minute(c.analysis_time));MBA_AddL(f,MBA_MinuteOfDay(c.analysis_time));
   MBA_Add(f,MBA_SlotHHMM(c.analysis_time));MBA_Add(f,MBA_WeekStart(c.analysis_time));MBA_Add(f,MBA_Session(c.analysis_time));
   MBA_AddD(f,c.bar.open,MBA_Digits());MBA_AddD(f,c.bar.high,MBA_Digits());MBA_AddD(f,c.bar.low,MBA_Digits());MBA_AddD(f,c.bar.close,MBA_Digits());
   MBA_AddD(f,c.range,2);MBA_AddD(f,c.body,2);MBA_AddD(f,c.uw,2);MBA_AddD(f,c.lw,2);
   MBA_AddD(f,MBA_SafeRatio(c.body,c.range),6);MBA_AddD(f,MBA_SafeRatio(c.uw,c.range),6);MBA_AddD(f,MBA_SafeRatio(c.lw,c.range),6);
   MBA_AddD(f,MBA_ClosePosition(c.bar),6);MBA_Add(f,MBA_Dir(MBA_Direction(c.bar)));
   MBA_AddD(f,c.true_range,2);MBA_AddD(f,c.atr,2);MBA_AddD(f,MBA_SafeRatio(c.range,c.atr),6);
   MBA_AddL(f,(long)c.bar.tick_volume);MBA_AddD(f,(double)c.bar.real_volume,4);MBA_AddD(f,c.avg_tv,2);MBA_AddD(f,c.vr,6);
   MBA_AddL(f,c.tick_ok?c.tick_count:0);MBA_Add(f,MBA_Bool(c.tick_ok));
   MBA_AddD(f,c.tick_density,4);MBA_AddD(f,c.tick_density_ratio,4);
   MBA_AddD(f,c.spread_avg,2);MBA_AddD(f,c.spread_max,2);MBA_AddD(f,c.spread_min,2);
   MBA_Add(f,MBA_BucketRatio(MBA_SafeRatio(c.range,c.atr)));MBA_Add(f,MBA_BucketPct(MBA_SafeRatio(c.body,c.range)));MBA_Add(f,MBA_BucketVolume(c.vr));
   MBA_Add(f,c.pattern);MBA_Add(f,c.structure_before);MBA_Add(f,c.structure_at_close);MBA_Add(f,c.vol_state);
   MBA_AddL(f,c.gap_bars);MBA_Add(f,c.source);MBA_Add(f,MBA_SCHEMA_VERSION);
  }

void MBA_FillEventRow(string &f[],const MBA_BarCtx &c)
  {
   ArrayResize(f,0);
   MBA_Add(f,c.run_id);MBA_Add(f,c.event_id);MBA_Add(f,c.event_key);MBA_Add(f,c.broker);MBA_Add(f,c.server);MBA_Add(f,c.symbol);MBA_Add(f,c.tf_name);MBA_Add(f,c.data_source);
   MBA_Add(f,MBA_DT(c.server_time,true));MBA_Add(f,MBA_DT(c.analysis_time,true));
   MBA_Add(f,MBA_DayName(c.analysis_time));MBA_AddL(f,MBA_Hour(c.analysis_time));MBA_AddL(f,MBA_Minute(c.analysis_time));
   MBA_Add(f,MBA_SlotHHMM(c.analysis_time));MBA_Add(f,MBA_WeekStart(c.analysis_time));MBA_Add(f,MBA_Session(c.analysis_time));
   MBA_Add(f,MBA_Dir(MBA_Direction(c.bar)));
   MBA_AddD(f,MBA_SafeRatio(c.body,c.range),6);MBA_AddD(f,MBA_SafeRatio(c.uw,c.range),6);MBA_AddD(f,MBA_SafeRatio(c.lw,c.range),6);
   MBA_AddD(f,MBA_ClosePosition(c.bar),6);MBA_AddD(f,MBA_SafeRatio(c.range,c.atr),6);MBA_AddD(f,c.vr,6);
   MBA_AddD(f,c.tick_density_ratio,6);MBA_AddD(f,c.spread_avg,2);
   MBA_Add(f,c.pattern);MBA_Add(f,c.structure_before);MBA_Add(f,c.structure_at_close);MBA_Add(f,c.vol_state);
   MBA_AddD(f,c.d_open_pts,2);MBA_AddD(f,c.w_open_pts,2);MBA_AddD(f,c.m_open_pts,2);
   MBA_AddD(f,c.prev_high_atr,6);MBA_AddD(f,c.prev_low_atr,6);
   MBA_AddD(f,c.pdh_atr,6);MBA_AddD(f,c.pdl_atr,6);MBA_AddD(f,c.sess_high_atr,6);MBA_AddD(f,c.sess_low_atr,6);
   MBA_AddD(f,c.swing_high_atr,6);MBA_AddD(f,c.swing_low_atr,6);
   for(int s=0;s<8;s++) MBA_Add(f,c.mtf[s]);
   MBA_Add(f,"CLOSED_BARS_BEFORE_EVENT_OPEN");
   MBA_Add(f,c.news_state);MBA_AddL(f,c.news_n);MBA_AddL(f,c.news_high_n);MBA_AddD(f,c.news_min_next,1);MBA_AddD(f,c.news_min_since,1);
   MBA_AddL(f,c.gap_bars);MBA_Add(f,c.source);MBA_Add(f,MBA_SCHEMA_VERSION);
  }

// Broker servers that follow the New-York close: UTC+2 in winter, UTC+3 while US daylight saving is active.
// Approximation at day granularity (US DST: 2nd Sunday of March .. 1st Sunday of November).
int MBA_ServerOffsetUSDST(datetime server_time)
  {
   MqlDateTime d; TimeToStruct(server_time,d);
   MqlDateTime m; m.year=d.year;m.mon=3;m.day=1;m.hour=0;m.min=0;m.sec=0;
   datetime mar1=StructToTime(m);
   TimeToStruct(mar1,m);
   int first_sun=1+((7-m.day_of_week)%7);
   datetime dst_start=mar1+(datetime)((first_sun+7-1)*86400);
   MqlDateTime n; n.year=d.year;n.mon=11;n.day=1;n.hour=0;n.min=0;n.sec=0;
   datetime nov1=StructToTime(n);
   TimeToStruct(nov1,n);
   int nov_sun=1+((7-n.day_of_week)%7);
   datetime dst_end=nov1+(datetime)((nov_sun-1)*86400);
   return (server_time>=dst_start && server_time<dst_end)?10800:7200;
  }

string MBA_SpecHeader()
  {
   return "run_id,time_server,time_utc,broker,server,account_currency,leverage,symbol,description,digits,point,tick_size,tick_value,contract_size,volume_min,volume_step,volume_max,stops_level,freeze_level,spread_now_points,swap_long,swap_short,swap_mode,trade_mode,exec_mode,filling_mode,margin_initial,server_utc_offset_sec,terminal_build,commission_per_lot_declared,commission_known,ea_version,schema_version,inputs";
  }

void MBA_FillSpecRow(string &f[],string run_id,double commission_declared,string inputs)
  {
   ArrayResize(f,0);
   string sym=_Symbol;
   MBA_Add(f,run_id);MBA_Add(f,MBA_DT(TimeTradeServer(),true));MBA_Add(f,MBA_DT(TimeGMT(),true));
   MBA_Add(f,AccountInfoString(ACCOUNT_COMPANY));MBA_Add(f,AccountInfoString(ACCOUNT_SERVER));MBA_Add(f,AccountInfoString(ACCOUNT_CURRENCY));MBA_AddL(f,AccountInfoInteger(ACCOUNT_LEVERAGE));
   MBA_Add(f,sym);MBA_Add(f,SymbolInfoString(sym,SYMBOL_DESCRIPTION));
   MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_DIGITS));MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_POINT),8);
   MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_SIZE),8);MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_VALUE),6);MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_TRADE_CONTRACT_SIZE),4);
   MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_VOLUME_MIN),4);MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_VOLUME_STEP),4);MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_VOLUME_MAX),4);
   MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_TRADE_STOPS_LEVEL));MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_TRADE_FREEZE_LEVEL));MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_SPREAD));
   MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_SWAP_LONG),4);MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_SWAP_SHORT),4);MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_SWAP_MODE));
   MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_TRADE_MODE));MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_TRADE_EXEMODE));MBA_AddL(f,SymbolInfoInteger(sym,SYMBOL_FILLING_MODE));
   MBA_AddD(f,SymbolInfoDouble(sym,SYMBOL_MARGIN_INITIAL),4);
   MBA_AddL(f,MBA_ServerOffsetSec());MBA_AddL(f,TerminalInfoInteger(TERMINAL_BUILD));
   MBA_AddD(f,commission_declared,4);MBA_Add(f,MBA_Bool(commission_declared>0.0));
   MBA_Add(f,MBA_VERSION);MBA_Add(f,MBA_SCHEMA_VERSION);MBA_Add(f,inputs);
  }
