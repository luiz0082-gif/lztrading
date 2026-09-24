#ifndef __VEGAR_DATA_MQH__
#define __VEGAR_DATA_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"

SVegarSymbolMeta gVegarSymbol;
int gVegarAtrH4=INVALID_HANDLE;
int gVegarAtrM15=INVALID_HANDLE;
int gVegarAtrM5=INVALID_HANDLE;
int gVegarAtrM1=INVALID_HANDLE;
MqlTick gVegarTick;

datetime gVegarLastBarH4=0;
datetime gVegarLastBarM15=0;
datetime gVegarLastBarM5=0;
datetime gVegarLastBarM1=0;

bool Vegar_LoadSymbolMeta()
  {
   ZeroMemory(gVegarSymbol);
   gVegarSymbol.symbol=_Symbol;
   gVegarSymbol.base_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   gVegarSymbol.profit_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   gVegarSymbol.account_currency=AccountInfoString(ACCOUNT_CURRENCY);
   gVegarSymbol.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   gVegarSymbol.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   gVegarSymbol.tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   gVegarSymbol.tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   gVegarSymbol.contract_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   gVegarSymbol.volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   gVegarSymbol.volume_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   gVegarSymbol.volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   gVegarSymbol.stops_level_points=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   gVegarSymbol.freeze_level_points=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   gVegarSymbol.filling_flags=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   gVegarSymbol.valid=(gVegarSymbol.point>0.0 && gVegarSymbol.tick_size>0.0 &&
                       gVegarSymbol.volume_min>0.0 && gVegarSymbol.volume_max>=gVegarSymbol.volume_min &&
                       gVegarSymbol.volume_step>0.0 && gVegarSymbol.digits>=0);
   return gVegarSymbol.valid;
  }

int Vegar_AtrHandle(const ENUM_TIMEFRAMES tf)
  {
   if(tf==PERIOD_H4) return gVegarAtrH4;
   if(tf==PERIOD_M15) return gVegarAtrM15;
   if(tf==PERIOD_M5) return gVegarAtrM5;
   if(tf==PERIOD_M1) return gVegarAtrM1;
   return INVALID_HANDLE;
  }

bool Vegar_DataInit()
  {
   ResetLastError();
   if(!Vegar_LoadSymbolMeta())
     {
      PrintFormat("[VEGAR] DATA_INIT_FATAL: invalid symbol metadata Symbol=%s Point=%.10f TickSize=%.10f VolMin=%.8f VolMax=%.8f VolStep=%.8f Digits=%d Error=%d",
                  _Symbol,gVegarSymbol.point,gVegarSymbol.tick_size,gVegarSymbol.volume_min,gVegarSymbol.volume_max,gVegarSymbol.volume_step,gVegarSymbol.digits,GetLastError());
      return false;
     }

   ResetLastError();
   gVegarAtrH4=iATR(_Symbol,PERIOD_H4,14);
   gVegarAtrM15=iATR(_Symbol,PERIOD_M15,14);
   gVegarAtrM5=iATR(_Symbol,PERIOD_M5,14);
   gVegarAtrM1=iATR(_Symbol,PERIOD_M1,14);
   if(gVegarAtrH4==INVALID_HANDLE || gVegarAtrM15==INVALID_HANDLE ||
      gVegarAtrM5==INVALID_HANDLE || gVegarAtrM1==INVALID_HANDLE)
     {
      PrintFormat("[VEGAR] DATA_INIT_FATAL: ATR handle creation failed H4=%d M15=%d M5=%d M1=%d Error=%d",
                  gVegarAtrH4,gVegarAtrM15,gVegarAtrM5,gVegarAtrM1,GetLastError());
      return false;
     }

   // A first tick can legitimately be unavailable during terminal/symbol warm-up.
   // Do not classify this transient state as fatal initialization failure.
   SymbolInfoTick(_Symbol,gVegarTick);
   return true;
  }

void Vegar_DataDeinit()
  {
   if(gVegarAtrH4!=INVALID_HANDLE) IndicatorRelease(gVegarAtrH4);
   if(gVegarAtrM15!=INVALID_HANDLE) IndicatorRelease(gVegarAtrM15);
   if(gVegarAtrM5!=INVALID_HANDLE) IndicatorRelease(gVegarAtrM5);
   if(gVegarAtrM1!=INVALID_HANDLE) IndicatorRelease(gVegarAtrM1);
   gVegarAtrH4=gVegarAtrM15=gVegarAtrM5=gVegarAtrM1=INVALID_HANDLE;
  }

bool Vegar_CopyRates(const ENUM_TIMEFRAMES tf,const int start_shift,const int count,MqlRates &rates[])
  {
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,tf,start_shift,count,rates);
   return (copied==count);
  }

bool Vegar_GetBar(const ENUM_TIMEFRAMES tf,const int shift,MqlRates &bar)
  {
   MqlRates r[];
   ArraySetAsSeries(r,true);
   if(CopyRates(_Symbol,tf,shift,1,r)!=1) return false;
   bar=r[0];
   return true;
  }

double Vegar_ATR(const ENUM_TIMEFRAMES tf,const int shift=1)
  {
   int h=Vegar_AtrHandle(tf);
   if(h==INVALID_HANDLE) return 0.0;
   double b[];
   ArraySetAsSeries(b,true);
   if(CopyBuffer(h,0,shift,1,b)!=1) return 0.0;
   return b[0];
  }

bool Vegar_TimeframeSynchronized(const ENUM_TIMEFRAMES tf,const int min_bars)
  {
   long sync=0;
   if(!SeriesInfoInteger(_Symbol,tf,SERIES_SYNCHRONIZED,sync) || sync==0) return false;
   int bars=Bars(_Symbol,tf);
   if(bars<min_bars) return false;
   return true;
  }

bool Vegar_AllRequiredDataReady(ENUM_VEGAR_REASON_CODE &reason)
  {
   if(!Vegar_TimeframeSynchronized(PERIOD_H4,300) ||
      !Vegar_TimeframeSynchronized(PERIOD_M15,500) ||
      !Vegar_TimeframeSynchronized(PERIOD_M5,500) ||
      ((_Period==PERIOD_M1) && !Vegar_TimeframeSynchronized(PERIOD_M1,500)))
     {
      reason=DATA_NOT_READY;
      return false;
     }
   if(BarsCalculated(gVegarAtrH4)<300 || BarsCalculated(gVegarAtrM15)<500 ||
      BarsCalculated(gVegarAtrM5)<500 || ((_Period==PERIOD_M1) && BarsCalculated(gVegarAtrM1)<500))
     {
      reason=DATA_NOT_SYNCHRONIZED;
      return false;
     }
   reason=VEGAR_REASON_NONE;
   return true;
  }

string Vegar_DataReadinessDetail()
  {
   long syncH4=0,syncM15=0,syncM5=0,syncM1=0;
   SeriesInfoInteger(_Symbol,PERIOD_H4,SERIES_SYNCHRONIZED,syncH4);
   SeriesInfoInteger(_Symbol,PERIOD_M15,SERIES_SYNCHRONIZED,syncM15);
   SeriesInfoInteger(_Symbol,PERIOD_M5,SERIES_SYNCHRONIZED,syncM5);
   SeriesInfoInteger(_Symbol,PERIOD_M1,SERIES_SYNCHRONIZED,syncM1);
   return StringFormat("Bars H4=%d M15=%d M5=%d M1=%d | Calc H4=%d M15=%d M5=%d M1=%d | Sync H4=%d M15=%d M5=%d M1=%d",
                       Bars(_Symbol,PERIOD_H4),Bars(_Symbol,PERIOD_M15),Bars(_Symbol,PERIOD_M5),Bars(_Symbol,PERIOD_M1),
                       BarsCalculated(gVegarAtrH4),BarsCalculated(gVegarAtrM15),BarsCalculated(gVegarAtrM5),BarsCalculated(gVegarAtrM1),
                       (int)syncH4,(int)syncM15,(int)syncM5,(int)syncM1);
  }

ENUM_TIMEFRAMES Vegar_ExecutionTF()
  {
   if(_Period==PERIOD_M1) return PERIOD_M1;
   return PERIOD_M5;
  }

double Vegar_NormalizePriceToTick(const double price)
  {
   if(gVegarSymbol.tick_size<=0.0) return NormalizeDouble(price,gVegarSymbol.digits);
   double n=MathRound(price/gVegarSymbol.tick_size)*gVegarSymbol.tick_size;
   return NormalizeDouble(n,gVegarSymbol.digits);
  }

double Vegar_PriceToTicks(const double price_distance)
  {
   if(gVegarSymbol.tick_size<=0.0) return 0.0;
   return price_distance/gVegarSymbol.tick_size;
  }

double Vegar_PriceToPoints(const double price_distance)
  {
   if(gVegarSymbol.point<=0.0) return 0.0;
   return price_distance/gVegarSymbol.point;
  }

bool Vegar_UpdateTick()
  {
   return SymbolInfoTick(_Symbol,gVegarTick);
  }

double Vegar_CurrentSpreadPrice()
  {
   if(gVegarTick.ask<=0.0 || gVegarTick.bid<=0.0) return 0.0;
   return gVegarTick.ask-gVegarTick.bid;
  }

double Vegar_CurrentSpreadPoints() { return Vegar_PriceToPoints(Vegar_CurrentSpreadPrice()); }
double Vegar_CurrentSpreadTicks()  { return Vegar_PriceToTicks(Vegar_CurrentSpreadPrice()); }

int Vegar_GetNewClosedBarShifts(const ENUM_TIMEFRAMES tf,datetime &last_seen,int &shifts[])
  {
   ArrayResize(shifts,0);
   datetime newest=iTime(_Symbol,tf,1);
   if(newest<=0) return 0;
   if(last_seen==0) { last_seen=newest; return 0; }
   if(newest==last_seen) return 0;
   int oldShift=iBarShift(_Symbol,tf,last_seen,true);
   if(oldShift<2) oldShift=iBarShift(_Symbol,tf,last_seen,false);
   if(oldShift<2) oldShift=2;
   int maxBackfill=(oldShift-1<500 ? oldShift-1 : 500);
   for(int s=maxBackfill;s>=1;s--)
     {
      int n=ArraySize(shifts); ArrayResize(shifts,n+1); shifts[n]=s;
     }
   last_seen=newest;
   return ArraySize(shifts);
  }

bool Vegar_IsNewClosedBar(const ENUM_TIMEFRAMES tf,datetime &last_seen,datetime &closed_bar_time)
  {
   datetime t=iTime(_Symbol,tf,1);
   if(t<=0) return false;
   closed_bar_time=t;
   if(last_seen==0)
     {
      last_seen=t;
      return false;
     }
   if(t!=last_seen)
     {
      last_seen=t;
      return true;
     }
   return false;
  }

double Vegar_AvgRange(const ENUM_TIMEFRAMES tf,const int first_shift,const int count)
  {
   MqlRates r[];
   if(!Vegar_CopyRates(tf,first_shift,count,r)) return 0.0;
   double sum=0.0;
   for(int i=0;i<count;i++) sum += MathMax(0.0,r[i].high-r[i].low);
   return (count>0 ? sum/count : 0.0);
  }

double Vegar_AvgTickVolume(const ENUM_TIMEFRAMES tf,const int first_shift,const int count)
  {
   MqlRates r[];
   if(!Vegar_CopyRates(tf,first_shift,count,r)) return 0.0;
   double sum=0.0;
   for(int i=0;i<count;i++) sum += (double)r[i].tick_volume;
   return (count>0 ? sum/count : 0.0);
  }

bool Vegar_CalcProfit(const ENUM_ORDER_TYPE type,const double volume,const double open_price,const double close_price,double &profit)
  {
   profit=0.0;
   ResetLastError();
   return OrderCalcProfit(type,_Symbol,volume,open_price,close_price,profit);
  }

double Vegar_SpreadMoney(const double volume)
  {
   if(volume<=0.0 || gVegarTick.ask<=0.0 || gVegarTick.bid<=0.0) return 0.0;
   double p=0.0;
   if(!Vegar_CalcProfit(ORDER_TYPE_BUY,volume,gVegarTick.ask,gVegarTick.bid,p)) return 0.0;
   return MathAbs(p);
  }


double Vegar_ATRAtTime(const ENUM_TIMEFRAMES tf,const datetime confirmed_time)
  {
   if(confirmed_time<=0) return 0.0;
   // Confirmation timestamps are represented at the close/open boundary. Query the
   // last second that was actually known at confirmation to avoid mapping to the
   // newly opened bar and accidentally using one bar of future volatility.
   datetime known_time=confirmed_time-1;
   int shift=iBarShift(_Symbol,tf,known_time,false);
   if(shift<1) shift=1;
   return Vegar_ATR(tf,shift);
  }

bool Vegar_GetBarForSymbol(const string symbol,const ENUM_TIMEFRAMES tf,const int shift,MqlRates &bar)
  {
   MqlRates r[];
   ArraySetAsSeries(r,true);
   if(CopyRates(symbol,tf,shift,1,r)!=1) return false;
   bar=r[0];
   return true;
  }

bool Vegar_CalcProfitForSymbol(const string symbol,const ENUM_ORDER_TYPE type,const double volume,const double open_price,const double close_price,double &profit)
  {
   profit=0.0;
   if(symbol=="") return false;
   ResetLastError();
   return OrderCalcProfit(type,symbol,volume,open_price,close_price,profit);
  }

bool Vegar_CalcMoneyFromPriceForSymbol(const string symbol,const ENUM_VEGAR_BIAS direction,const double volume,const double open_price,const double close_price,double &money)
  {
   ENUM_ORDER_TYPE type=(direction==VEGAR_BIAS_BUYER?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
   return Vegar_CalcProfitForSymbol(symbol,type,volume,open_price,close_price,money);
  }

bool Vegar_VolumeExactlyValid(const double volume)
  {
   if(volume<gVegarSymbol.volume_min-1e-12 || volume>gVegarSymbol.volume_max+1e-12) return false;
   double steps=(volume-gVegarSymbol.volume_min)/gVegarSymbol.volume_step;
   return (MathAbs(steps-MathRound(steps))<1e-7);
  }

#endif
