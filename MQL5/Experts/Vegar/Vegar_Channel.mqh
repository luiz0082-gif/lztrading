#ifndef __VEGAR_CHANNEL_MQH__
#define __VEGAR_CHANNEL_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Liquidity.mqh"

SVegarChannel gVegarChannelH4;
SVegarChannel gVegarChannelM15;
SVegarChannel gVegarSupersededChannelH4;
SVegarChannel gVegarSupersededChannelM15;
bool gVegarHasSupersededChannelH4=false;
bool gVegarHasSupersededChannelM15=false;

bool Vegar_FindLastTwoPivotLows(const ENUM_TIMEFRAMES tf,datetime &t1,double &p1,datetime &t2,double &p2)
  {
   MqlRates r[]; if(!Vegar_CopyRates(tf,1,140,r)) return false;
   int found=0;
   for(int i=3;i<ArraySize(r)-3;i++)
     {
      if(!Vegar_IsPivotLow(r,i,2,2)) continue;
      if(found==0) { t2=r[i].time; p2=r[i].low; found=1; }
      else { t1=r[i].time; p1=r[i].low; return true; }
     }
   return false;
  }

bool Vegar_FindLastTwoPivotHighs(const ENUM_TIMEFRAMES tf,datetime &t1,double &p1,datetime &t2,double &p2)
  {
   MqlRates r[]; if(!Vegar_CopyRates(tf,1,140,r)) return false;
   int found=0;
   for(int i=3;i<ArraySize(r)-3;i++)
     {
      if(!Vegar_IsPivotHigh(r,i,2,2)) continue;
      if(found==0) { t2=r[i].time; p2=r[i].high; found=1; }
      else { t1=r[i].time; p1=r[i].high; return true; }
     }
   return false;
  }

void Vegar_InitChannelIdentity(SVegarChannel &c)
  {
   c.account=(string)AccountInfoInteger(ACCOUNT_LOGIN);
   c.server=AccountInfoString(ACCOUNT_SERVER);
   c.symbol=_Symbol;
   c.execution_tf=Vegar_ExecutionTF();
   c.magic=InpMagicNumber;
   c.instance_id=gVegarInstanceID;
   c.run_id=gVegarRunID;
  }

string Vegar_ChannelScopedID(const SVegarChannel &c)
  {
   return "CH_"+Vegar_SanitizeFileToken(c.symbol)+"_"+Vegar_TFText(c.tf)+"_"+Vegar_ChannelText(c.direction)+"_"+
          (string)(long)c.anchor1_time+"_"+(string)(long)c.anchor2_time;
  }

bool Vegar_ChannelContextValid(const SVegarChannel &c)
  {
   bool ok=(c.symbol==_Symbol && c.magic==InpMagicNumber);
   if(!ok)
      PrintFormat("[VEGAR][CROSS_SYMBOL_ENTITY_REJECTED] EntityID=%s | EntitySymbol=%s | CurrentSymbol=%s | EntityMagic=%I64d | CurrentMagic=%I64d",
                  c.id,c.symbol,_Symbol,c.magic,InpMagicNumber);
   return ok;
  }

double Vegar_ChannelLineAt(const SVegarChannel &c,const datetime t)
  {
   if(!c.valid || c.anchor2_time==c.anchor1_time) return 0.0;
   int sec=PeriodSeconds(c.tf); if(sec<=0) return 0.0;
   double bars=(double)(t-c.anchor1_time)/(double)sec;
   return c.anchor1_price+c.slope_price_per_bar*bars;
  }

double Vegar_ChannelER(const ENUM_TIMEFRAMES tf)
  {
   MqlRates r[]; if(!Vegar_CopyRates(tf,1,11,r)) return 0.0;
   double numerator=MathAbs(r[0].close-r[10].close);
   double denom=0.0;
   for(int i=0;i<10;i++) denom+=MathAbs(r[i].close-r[i+1].close);
   if(denom<=0.0) return 0.0;
   return Vegar_Clamp(numerator/denom,0.0,1.0);
  }

ENUM_VEGAR_CHANNEL_GEOMETRY Vegar_ClassifyChannelGeometry(const ENUM_TIMEFRAMES tf)
  {
   datetime l1t=0,l2t=0,h1t=0,h2t=0; double l1=0,l2=0,h1=0,h2=0;
   bool lows=Vegar_FindLastTwoPivotLows(tf,l1t,l1,l2t,l2);
   bool highs=Vegar_FindLastTwoPivotHighs(tf,h1t,h1,h2t,h2);
   if(!lows || !highs) return VEGAR_CHANNEL_GEOMETRY_NEUTRAL;
   double lowDelta=l2-l1, highDelta=h2-h1;
   if(lowDelta>0.0 && highDelta<0.0) return VEGAR_CHANNEL_GEOMETRY_COMPRESSION;
   if(lowDelta<0.0 && highDelta>0.0) return VEGAR_CHANNEL_GEOMETRY_EXPANSION;
   if((lowDelta>0.0 && highDelta>0.0) || (lowDelta<0.0 && highDelta<0.0)) return VEGAR_CHANNEL_GEOMETRY_TREND;
   return VEGAR_CHANNEL_GEOMETRY_MIXED;
  }

void Vegar_UpdateChannelTelemetry(SVegarChannel &c)
  {
   if(!c.valid) return;
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   double base=Vegar_ChannelLineAt(c,now);
   if(c.direction==VEGAR_CHANNEL_BUYER)
     { c.current_lower_rail=base; c.current_upper_rail=base+c.offset_price; }
   else if(c.direction==VEGAR_CHANNEL_SELLER)
     { c.current_upper_rail=base; c.current_lower_rail=base-c.offset_price; }
   else
     { c.current_lower_rail=base-c.offset_price*0.5; c.current_upper_rail=base+c.offset_price*0.5; }
   c.current_mid_rail=(c.current_lower_rail+c.current_upper_rail)*0.5;
   c.channel_width_price=MathMax(0.0,c.current_upper_rail-c.current_lower_rail);
   double atr=Vegar_ATR(c.tf,1);
   c.channel_width_atr=(atr>0.0?c.channel_width_price/atr:0.0);
   double price=(gVegarTick.bid>0.0 && gVegarTick.ask>0.0?(gVegarTick.bid+gVegarTick.ask)*0.5:iClose(_Symbol,c.tf,1));
   if(c.channel_width_price>0.0)
      c.current_price_position_percent=100.0*(price-c.current_lower_rail)/c.channel_width_price;
   else c.current_price_position_percent=50.0;
   c.distance_upper_rail_atr=(atr>0.0?MathAbs(c.current_upper_rail-price)/atr:0.0);
   c.distance_lower_rail_atr=(atr>0.0?MathAbs(price-c.current_lower_rail)/atr:0.0);
  }

void Vegar_CalcChannelStrength(SVegarChannel &c)
  {
   if(!c.valid) { c.strength_score=0.0; c.strength_class=VEGAR_STRENGTH_MUITO_FRACA; return; }
   MqlRates r[]; if(!Vegar_CopyRates(c.tf,1,24,r)) { c.valid=false; return; }
   int coherent=0;
   double prevHi=0.0,prevLo=0.0; bool haveHi=false,haveLo=false;
   for(int i=ArraySize(r)-4;i>=3;i--)
     {
      if(Vegar_IsPivotHigh(r,i,2,2))
        {
         if(haveHi)
           {
            if(c.direction==VEGAR_CHANNEL_BUYER && r[i].high>prevHi) coherent++;
            if(c.direction==VEGAR_CHANNEL_SELLER && r[i].high<prevHi) coherent++;
           }
         prevHi=r[i].high; haveHi=true;
        }
      if(Vegar_IsPivotLow(r,i,2,2))
        {
         if(haveLo)
           {
            if(c.direction==VEGAR_CHANNEL_BUYER && r[i].low>prevLo) coherent++;
            if(c.direction==VEGAR_CHANNEL_SELLER && r[i].low<prevLo) coherent++;
           }
         prevLo=r[i].low; haveLo=true;
        }
     }
   coherent=(coherent<4 ? coherent : 4);
   c.coherent_confirmations=coherent;
   double structure_score=10.0*coherent;
   double atr=Vegar_ATR(c.tf,1);
   c.slope_atr_per_bar=(atr>0.0 ? MathAbs(c.slope_price_per_bar)/atr : 0.0);
   double slope_score=MathMin(20.0,20.0*c.slope_atr_per_bar/0.10);
   c.efficiency_ratio=Vegar_ChannelER(c.tf);
   double er_score=20.0*c.efficiency_ratio;

   int inside=0; int reactions=0;
   double boundaryTol=MathMax(2.0*gVegarSymbol.tick_size,0.10*atr);
   for(int i=0;i<20;i++)
     {
      double base=Vegar_ChannelLineAt(c,r[i].time);
      double upper=base,lower=base;
      if(c.direction==VEGAR_CHANNEL_BUYER) { lower=base; upper=base+c.offset_price; }
      else if(c.direction==VEGAR_CHANNEL_SELLER) { upper=base; lower=base-c.offset_price; }
      else { lower=base-c.offset_price*0.5; upper=base+c.offset_price*0.5; }
      if(r[i].close>=lower && r[i].close<=upper) inside++;
      if(MathAbs(r[i].low-lower)<=boundaryTol || MathAbs(r[i].high-upper)<=boundaryTol) reactions++;
     }
   c.respect_fraction=(double)inside/20.0;
   double respect_score=10.0*c.respect_fraction + 5.0*(double)(reactions<2 ? reactions : 2);
   c.structure_score_component=structure_score;
   c.slope_score_component=slope_score;
   c.er_score_component=er_score;
   c.respect_score_component=respect_score;
   c.strength_score=Vegar_Clamp(structure_score+slope_score+er_score+respect_score,0.0,100.0);
   c.strength_class=Vegar_StrengthClass(c.strength_score);
   c.geometry_class=Vegar_ClassifyChannelGeometry(c.tf);
   Vegar_UpdateChannelTelemetry(c);
  }

SVegarChannel Vegar_BuildChannel(const ENUM_TIMEFRAMES tf)
  {
   SVegarChannel c; ZeroMemory(c); Vegar_InitChannelIdentity(c); c.tf=tf; c.direction=VEGAR_CHANNEL_NEUTRAL;
   datetime l1t=0,l2t=0,h1t=0,h2t=0; double l1=0,l2=0,h1=0,h2=0;
   bool lows=Vegar_FindLastTwoPivotLows(tf,l1t,l1,l2t,l2);
   bool highs=Vegar_FindLastTwoPivotHighs(tf,h1t,h1,h2t,h2);
   int sec=PeriodSeconds(tf); if(sec<=0) return c;

   // Operational authority deliberately preserved from RC5: rising lows are checked first, then falling highs.
   if(lows && l2>l1)
     {
      c.direction=VEGAR_CHANNEL_BUYER; c.anchor1_time=l1t; c.anchor2_time=l2t; c.anchor1_price=l1; c.anchor2_price=l2;
      double bars=(double)(l2t-l1t)/sec; if(bars<=0.0) return c;
      c.slope_price_per_bar=(l2-l1)/bars;
      MqlRates r[]; if(!Vegar_CopyRates(tf,1,120,r)) return c;
      double maxOffset=0.0;
      for(int i=0;i<ArraySize(r);i++)
        {
         if(r[i].time<l1t) continue;
         double line=l1+c.slope_price_per_bar*((double)(r[i].time-l1t)/sec);
         maxOffset=MathMax(maxOffset,r[i].high-line);
        }
      c.offset_price=MathMax(0.0,maxOffset); c.valid=(c.offset_price>0.0);
     }
   else if(highs && h2<h1)
     {
      c.direction=VEGAR_CHANNEL_SELLER; c.anchor1_time=h1t; c.anchor2_time=h2t; c.anchor1_price=h1; c.anchor2_price=h2;
      double bars=(double)(h2t-h1t)/sec; if(bars<=0.0) return c;
      c.slope_price_per_bar=(h2-h1)/bars;
      MqlRates r[]; if(!Vegar_CopyRates(tf,1,120,r)) return c;
      double maxOffset=0.0;
      for(int i=0;i<ArraySize(r);i++)
        {
         if(r[i].time<h1t) continue;
         double line=h1+c.slope_price_per_bar*((double)(r[i].time-h1t)/sec);
         maxOffset=MathMax(maxOffset,line-r[i].low);
        }
      c.offset_price=MathMax(0.0,maxOffset); c.valid=(c.offset_price>0.0);
     }
   else
     {
      MqlRates r[]; if(!Vegar_CopyRates(tf,1,20,r)) return c;
      double hi=r[0].high,lo=r[0].low;
      for(int i=1;i<20;i++) { hi=MathMax(hi,r[i].high); lo=MathMin(lo,r[i].low); }
      c.direction=VEGAR_CHANNEL_NEUTRAL; c.anchor1_time=r[19].time; c.anchor2_time=r[0].time;
      c.anchor1_price=(hi+lo)*0.5; c.anchor2_price=c.anchor1_price; c.slope_price_per_bar=0.0; c.offset_price=hi-lo; c.valid=(hi>lo);
     }
   c.id=Vegar_ChannelScopedID(c);
   c.created_time=TimeTradeServer(); c.last_changed=c.created_time; c.superseded=false;
   Vegar_CalcChannelStrength(c);
   return c;
  }

void Vegar_UpdateChannels()
  {
   SVegarChannel nextH4=Vegar_BuildChannel(PERIOD_H4);
   SVegarChannel nextM15=Vegar_BuildChannel(PERIOD_M15);
   gVegarHasSupersededChannelH4=false; gVegarHasSupersededChannelM15=false;
   if(gVegarChannelH4.valid && nextH4.valid && gVegarChannelH4.id!=nextH4.id)
     { gVegarSupersededChannelH4=gVegarChannelH4; gVegarSupersededChannelH4.superseded=true; gVegarHasSupersededChannelH4=true; }
   if(gVegarChannelM15.valid && nextM15.valid && gVegarChannelM15.id!=nextM15.id)
     { gVegarSupersededChannelM15=gVegarChannelM15; gVegarSupersededChannelM15.superseded=true; gVegarHasSupersededChannelM15=true; }
   gVegarChannelH4=nextH4; gVegarChannelM15=nextM15;
  }

#endif
