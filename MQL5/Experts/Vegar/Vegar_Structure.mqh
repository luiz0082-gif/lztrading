#ifndef __VEGAR_STRUCTURE_MQH__
#define __VEGAR_STRUCTURE_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Channel.mqh"

ENUM_VEGAR_M15_CONTEXT gVegarM15Context=VEGAR_M15_UNKNOWN;
int gVegarM15RangeConsecutive=0;

bool Vegar_LastTwoHighLowAtShift(const ENUM_TIMEFRAMES tf,const int base_shift,double &prevHigh,double &lastHigh,double &prevLow,double &lastLow)
  {
   MqlRates r[]; if(!Vegar_CopyRates(tf,base_shift,140,r)) return false;
   bool gotLastH=false,gotPrevH=false,gotLastL=false,gotPrevL=false;
   for(int i=3;i<ArraySize(r)-3;i++)
     {
      if(!gotLastH && Vegar_IsPivotHigh(r,i,2,2)) { lastHigh=r[i].high; gotLastH=true; }
      else if(gotLastH && !gotPrevH && Vegar_IsPivotHigh(r,i,2,2)) { prevHigh=r[i].high; gotPrevH=true; }
      if(!gotLastL && Vegar_IsPivotLow(r,i,2,2)) { lastLow=r[i].low; gotLastL=true; }
      else if(gotLastL && !gotPrevL && Vegar_IsPivotLow(r,i,2,2)) { prevLow=r[i].low; gotPrevL=true; }
      if(gotPrevH && gotPrevL) return true;
     }
   return false;
  }

double Vegar_ER10AtShift(const ENUM_TIMEFRAMES tf,const int shift)
  {
   MqlRates r[]; if(!Vegar_CopyRates(tf,shift,11,r)) return 0.0;
   double numerator=MathAbs(r[0].close-r[10].close),denom=0.0;
   for(int i=0;i<10;i++) denom+=MathAbs(r[i].close-r[i+1].close);
   return (denom>0.0?Vegar_Clamp(numerator/denom,0.0,1.0):0.0);
  }

ENUM_VEGAR_CHANNEL_DIRECTION Vegar_ChannelDirectionAtShift(const ENUM_TIMEFRAMES tf,const int shift)
  {
   double ph=0,lh=0,pl=0,ll=0;
   if(!Vegar_LastTwoHighLowAtShift(tf,shift,ph,lh,pl,ll)) return VEGAR_CHANNEL_NEUTRAL;
   if(ll>pl) return VEGAR_CHANNEL_BUYER;
   if(lh<ph) return VEGAR_CHANNEL_SELLER;
   return VEGAR_CHANNEL_NEUTRAL;
  }

ENUM_VEGAR_M15_CONTEXT Vegar_CalcM15ContextAtShift(const int shift)
  {
   double ph=0,lh=0,pl=0,ll=0;
   bool ok=Vegar_LastTwoHighLowAtShift(PERIOD_M15,shift,ph,lh,pl,ll);
   ENUM_VEGAR_CHANNEL_DIRECTION dir=Vegar_ChannelDirectionAtShift(PERIOD_M15,shift);
   double er=Vegar_ER10AtShift(PERIOD_M15,shift);
   if(dir==VEGAR_CHANNEL_NEUTRAL && er<0.30) return VEGAR_M15_RANGE;
   if(!ok) return VEGAR_M15_TRANSITION;
   if(lh>ph && ll>pl && dir==VEGAR_CHANNEL_BUYER) return VEGAR_M15_TREND_UP;
   if(lh<ph && ll<pl && dir==VEGAR_CHANNEL_SELLER) return VEGAR_M15_TREND_DOWN;
   return VEGAR_M15_TRANSITION;
  }

ENUM_VEGAR_M15_CONTEXT Vegar_CalcM15Context()
  {
   return Vegar_CalcM15ContextAtShift(1);
  }

void Vegar_UpdateM15Context(const bool new_m15_bar)
  {
   gVegarM15Context=Vegar_CalcM15ContextAtShift(1);
   gVegarM15RangeConsecutive=0;
   for(int shift=1;shift<=64;shift++)
     {
      if(Vegar_CalcM15ContextAtShift(shift)==VEGAR_M15_RANGE) gVegarM15RangeConsecutive++;
      else break;
     }
  }

bool Vegar_ContextAllowsDirection(const ENUM_VEGAR_BIAS direction,ENUM_VEGAR_REASON_CODE &reason)
  {
   if(gVegarM15RangeConsecutive>=8)
     {
      reason=M15_RANGE_BLOCK; return false;
     }
   if(direction==VEGAR_BIAS_BUYER && gVegarM15Context==VEGAR_M15_TREND_DOWN)
     {
      reason=M15_DIRECTION_CONFLICT; return false;
     }
   if(direction==VEGAR_BIAS_SELLER && gVegarM15Context==VEGAR_M15_TREND_UP)
     {
      reason=M15_DIRECTION_CONFLICT; return false;
     }
   reason=VEGAR_REASON_NONE; return true;
  }

#endif
