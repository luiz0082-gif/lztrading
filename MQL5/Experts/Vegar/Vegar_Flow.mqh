#ifndef __VEGAR_FLOW_MQH__
#define __VEGAR_FLOW_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Data.mqh"

ENUM_VEGAR_FLOW_CLASS Vegar_ClassifyFlow(const double score,const bool buyer_absorbed,const bool seller_absorbed)
  {
   if(buyer_absorbed) return VEGAR_FLOW_BUYER_ABSORBED;
   if(seller_absorbed) return VEGAR_FLOW_SELLER_ABSORBED;
   if(score>=60.0) return VEGAR_FLOW_COMPRADOR_FORTE;
   if(score>=25.0) return VEGAR_FLOW_COMPRADOR;
   if(score<=-60.0) return VEGAR_FLOW_VENDEDOR_FORTE;
   if(score<=-25.0) return VEGAR_FLOW_VENDEDOR;
   return VEGAR_FLOW_NEUTRO;
  }

SVegarFlowSnapshot Vegar_CalcFlowAtShift(const ENUM_TIMEFRAMES tf,const int shift)
  {
   SVegarFlowSnapshot f; ZeroMemory(f);
   f.tf=tf;
   MqlRates r[];
   if(!Vegar_CopyRates(tf,shift,21,r)) return f;
   f.bar_time=r[0].time;
   double sum_body=0.0,sum_loc=0.0,sum_range5=0.0,sum_range20=0.0;
   for(int i=0;i<20;i++) sum_range20 += MathMax(0.0,r[i].high-r[i].low);
   for(int i=0;i<5;i++)
     {
      double range=r[i].high-r[i].low;
      if(range<=0.0) return f;
      sum_body += (r[i].close-r[i].open)/range;
      sum_loc += ((r[i].close-r[i].low)/range)*2.0-1.0;
      sum_range5 += range;
     }
   f.directional_body=sum_body/5.0;
   f.close_location_mean=sum_loc/5.0;
   double atr=Vegar_ATR(tf,shift);
   if(atr<=0.0) return f;
   f.net_progress=Vegar_Clamp((r[0].close-r[5].close)/(1.5*atr),-1.0,1.0);
   double avg5=sum_range5/5.0;
   double avg20=sum_range20/20.0;
   f.expansion=(avg20>0.0 ? Vegar_Clamp(avg5/avg20-1.0,0.0,1.0) : 0.0);
   double sign=(f.net_progress>0.0 ? 1.0 : (f.net_progress<0.0 ? -1.0 : 0.0));
   double raw=0.40*f.directional_body + 0.25*f.close_location_mean + 0.25*f.net_progress + 0.10*sign*f.expansion;
   f.flow_score=Vegar_Clamp(raw*100.0,-100.0,100.0);

   double range0=r[0].high-r[0].low;
   if(range0>0.0 && avg20>0.0)
     {
      double upper=r[0].high-MathMax(r[0].open,r[0].close);
      double lower=MathMin(r[0].open,r[0].close)-r[0].low;
      double close_loc=(r[0].close-r[0].low)/range0*100.0;
      f.buyer_absorbed=(range0>=1.5*avg20 && upper/range0>=0.45 && close_loc<=55.0);
      f.seller_absorbed=(range0>=1.5*avg20 && lower/range0>=0.45 && close_loc>=45.0);
     }
   f.dual_absorption=(f.buyer_absorbed && f.seller_absorbed);
   f.observation_flow_class=(f.dual_absorption?"TWO_SIDED_ABSORPTION":Vegar_FlowClassText(Vegar_ClassifyFlow(f.flow_score,f.buyer_absorbed,f.seller_absorbed)));
   f.flow_class=Vegar_ClassifyFlow(f.flow_score,f.buyer_absorbed,f.seller_absorbed);
   f.decision_authority=true;
   f.valid=true;
   return f;
  }

SVegarFlowSnapshot Vegar_CalcFlow(const ENUM_TIMEFRAMES tf)
  {
   return Vegar_CalcFlowAtShift(tf,1);
  }


SVegarFlowSnapshot Vegar_CalcLiveFlow(const ENUM_TIMEFRAMES tf)
  {
   // Observation-only: current/open candle is never fed into signal confirmation.
   SVegarFlowSnapshot f; ZeroMemory(f); f.tf=tf; f.decision_authority=false;
   MqlRates r[]; ArraySetAsSeries(r,true);
   if(CopyRates(_Symbol,tf,0,21,r)!=21) return f;
   f.bar_time=r[0].time;
   double sum_body=0.0,sum_loc=0.0,sum_range5=0.0,sum_range20=0.0;
   for(int i=1;i<=20;i++) sum_range20+=MathMax(0.0,r[i].high-r[i].low);
   for(int i=0;i<5;i++)
     {
      double range=r[i].high-r[i].low; if(range<=0.0) return f;
      sum_body+=(r[i].close-r[i].open)/range;
      sum_loc+=((r[i].close-r[i].low)/range)*2.0-1.0;
      sum_range5+=range;
     }
   f.directional_body=sum_body/5.0;
   f.close_location_mean=sum_loc/5.0;
   double atr=Vegar_ATR(tf,1); if(atr<=0.0) return f;
   f.net_progress=Vegar_Clamp((r[0].close-r[5].close)/(1.5*atr),-1.0,1.0);
   double avg5=sum_range5/5.0,avg20=sum_range20/20.0;
   f.expansion=(avg20>0.0?Vegar_Clamp(avg5/avg20-1.0,0.0,1.0):0.0);
   double sign=(f.net_progress>0.0?1.0:(f.net_progress<0.0?-1.0:0.0));
   double raw=0.40*f.directional_body+0.25*f.close_location_mean+0.25*f.net_progress+0.10*sign*f.expansion;
   f.flow_score=Vegar_Clamp(raw*100.0,-100.0,100.0);
   double range0=r[0].high-r[0].low;
   if(range0>0.0 && avg20>0.0)
     {
      double upper=r[0].high-MathMax(r[0].open,r[0].close);
      double lower=MathMin(r[0].open,r[0].close)-r[0].low;
      double close_loc=(r[0].close-r[0].low)/range0*100.0;
      f.buyer_absorbed=(range0>=1.5*avg20 && upper/range0>=0.45 && close_loc<=55.0);
      f.seller_absorbed=(range0>=1.5*avg20 && lower/range0>=0.45 && close_loc>=45.0);
     }
   f.dual_absorption=(f.buyer_absorbed && f.seller_absorbed);
   f.flow_class=Vegar_ClassifyFlow(f.flow_score,f.buyer_absorbed,f.seller_absorbed);
   f.observation_flow_class=(f.dual_absorption?"TWO_SIDED_ABSORPTION":Vegar_FlowClassText(f.flow_class));
   f.valid=true;
   return f;
  }

#endif
