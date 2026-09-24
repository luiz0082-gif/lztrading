#ifndef __VEGAR_OPPORTUNITY_REPLAY_MQH__
#define __VEGAR_OPPORTUNITY_REPLAY_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Risk.mqh"
#include "Vegar_Csv.mqh"

SVegarReplayJob gVegarReplayJobs[];

int Vegar_ReplayFind(const string opportunity_id,const string marker_id)
  {
   for(int i=0;i<ArraySize(gVegarReplayJobs);i++)
      if(gVegarReplayJobs[i].opportunity_id==opportunity_id && gVegarReplayJobs[i].marker_id==marker_id) return i;
   return -1;
  }

void Vegar_ReplayQueueWithMarker(const SVegarOpportunity &opp,const string marker_id)
  {
   if(!InpAtivarOpportunityReplay) return;
   string oid=opp.opportunity_id;
   if(oid=="") oid=opp.candidate_id;
   if(oid=="") return;
   if(Vegar_ReplayFind(oid,marker_id)>=0) return;
   if(ArraySize(gVegarReplayJobs)>=VEGAR_MAX_REPLAY_JOBS)
     {
      // Drop only completed jobs first; never overwrite an active job silently.
      int remove=-1;
      for(int q=0;q<ArraySize(gVegarReplayJobs);q++) if(gVegarReplayJobs[q].completed){remove=q;break;}
      if(remove<0) return;
      for(int q=remove+1;q<ArraySize(gVegarReplayJobs);q++) gVegarReplayJobs[q-1]=gVegarReplayJobs[q];
      ArrayResize(gVegarReplayJobs,ArraySize(gVegarReplayJobs)-1);
     }

   int n=ArraySize(gVegarReplayJobs); ArrayResize(gVegarReplayJobs,n+1); ZeroMemory(gVegarReplayJobs[n]);
   gVegarReplayJobs[n].active=true; gVegarReplayJobs[n].completed=false;
   gVegarReplayJobs[n].account=(string)AccountInfoInteger(ACCOUNT_LOGIN);
   gVegarReplayJobs[n].server=AccountInfoString(ACCOUNT_SERVER);
   gVegarReplayJobs[n].symbol=_Symbol;
   gVegarReplayJobs[n].execution_tf=Vegar_ExecutionTF();
   gVegarReplayJobs[n].point=gVegarSymbol.point;
   gVegarReplayJobs[n].tick_size=gVegarSymbol.tick_size;
   gVegarReplayJobs[n].digits=gVegarSymbol.digits;
   gVegarReplayJobs[n].account_currency=gVegarSymbol.account_currency;
   gVegarReplayJobs[n].magic=InpMagicNumber;
   gVegarReplayJobs[n].run_id=gVegarRunID;
   gVegarReplayJobs[n].instance_id=gVegarInstanceID;
   gVegarReplayJobs[n].marker_id=marker_id;
   gVegarReplayJobs[n].strategy_hash=gVegarStrategyConfigHash;
   gVegarReplayJobs[n].opportunity_id=oid;
   gVegarReplayJobs[n].direction=opp.direction;
   gVegarReplayJobs[n].origin_time=(opp.created_time>0?opp.created_time:TimeTradeServer());
   gVegarReplayJobs[n].entry_bar_time=(opp.retest_time>0?opp.retest_time:opp.state_time);
   if(gVegarReplayJobs[n].entry_bar_time<=0) gVegarReplayJobs[n].entry_bar_time=iTime(_Symbol,gVegarReplayJobs[n].execution_tf,1);
   gVegarReplayJobs[n].entry_bid=opp.hypothetical_entry_bid;
   gVegarReplayJobs[n].entry_ask=opp.hypothetical_entry_ask;
   if((gVegarReplayJobs[n].entry_bid<=0.0 || gVegarReplayJobs[n].entry_ask<=0.0) && Vegar_UpdateTick())
     {
      gVegarReplayJobs[n].entry_bid=gVegarTick.bid;
      gVegarReplayJobs[n].entry_ask=gVegarTick.ask;
     }
   gVegarReplayJobs[n].entry_price=(opp.direction==VEGAR_BIAS_BUYER?gVegarReplayJobs[n].entry_ask:gVegarReplayJobs[n].entry_bid);
   gVegarReplayJobs[n].stop_price=opp.technical_stop;
   gVegarReplayJobs[n].volume=InpLoteOperacional;
   gVegarReplayJobs[n].target_money=(InpAtivarMetaOperacao?InpMetaOperacaoMoney:(InpAtivarTakeProfit?InpTakeProfitMoney:opp.expected_money_opposite));
   gVegarReplayJobs[n].opposite_liquidity_price=opp.opposite_liquidity_price;
   gVegarReplayJobs[n].horizon_bars=InpHorizonteReplayCandles;
   gVegarReplayJobs[n].cost_model_incomplete=(InpComissaoRoundTurnPorLoteMoney<=0.0);
  }

void Vegar_ReplayQueue(const SVegarOpportunity &opp)
  {
   Vegar_ReplayQueueWithMarker(opp,opp.marker_id);
  }

void Vegar_ReplayDiagnostic(const SVegarReplayJob &j,const string event,const string primary,const string detail)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",MarkerID,Detail";
   string r=Vegar_CommonPrefixForContext(eid,j.opportunity_id,"","","","",event,"REPLAY",primary,"",j.symbol,j.execution_tf,j.magic,j.run_id,j.instance_id)+","+Vegar_CsvEscape(j.marker_id)+","+Vegar_CsvEscape(detail);
   Vegar_CsvAppendContext("DIAGNOSTIC",h,r,j.symbol,j.execution_tf,j.strategy_hash);
  }

void Vegar_WriteOpportunityOutcome(const SVegarReplayJob &j,const int horizon,double mfePoints,double mfeTicks,double mfeMoney,double maePoints,double maeTicks,double maeMoney,
                                   int timeMfeSec,int timeMfeBars,int timeMaeSec,int timeMaeBars,bool r25,bool r50,bool r75,bool r100,int t25,int t50,int t75,int t100,
                                   bool r1,bool r15,bool r2,int t1,int t15,int t2,bool reachedOpp,int timeOpp,bool stopTouched,int timeStop,const string firstOutcome)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",MarkerID,ReplaySymbol,ReplayTF,OutcomeHorizonBars,MaxFavorablePrice,MaxAdversePrice,MFE_Points,MFE_Ticks,MFE_Money,MAE_Points,MAE_Ticks,MAE_Money,TimeToMFESeconds,TimeToMFEBars,TimeToMAESeconds,TimeToMAEBars,Reached25PercentMeta,Reached50PercentMeta,Reached75PercentMeta,Reached100PercentMeta,TimeTo25PercentMeta,TimeTo50PercentMeta,TimeTo75PercentMeta,TimeTo100PercentMeta,Reached1R,Reached1_5R,Reached2R,TimeTo1R,TimeTo1_5R,TimeTo2R,ReachedOppositeLiquidity,TimeToOppositeLiquidity,TechnicalStopTouched,TimeToTechnicalStop,FirstTouchOutcome,CostModelIncomplete,DecisionAuthority";
   double maxFav=(j.direction==VEGAR_BIAS_BUYER?j.entry_price+mfePoints*j.point:j.entry_price-mfePoints*j.point);
   double maxAdv=(j.direction==VEGAR_BIAS_BUYER?j.entry_price-maePoints*j.point:j.entry_price+maePoints*j.point);
   string r=Vegar_CommonPrefixForContext(eid,j.opportunity_id,"","","","","OPPORTUNITY_OUTCOME","COMPLETED","NONE","",j.symbol,j.execution_tf,j.magic,j.run_id,j.instance_id);
   r += ","+Vegar_CsvEscape(j.marker_id)+","+Vegar_CsvEscape(j.symbol)+","+Vegar_CsvEscape(Vegar_TFText(j.execution_tf))+","+(string)horizon+","+DoubleToString(maxFav,j.digits)+","+DoubleToString(maxAdv,j.digits)+","+DoubleToString(mfePoints,4)+","+DoubleToString(mfeTicks,4)+","+DoubleToString(mfeMoney,6)+","+DoubleToString(maePoints,4)+","+DoubleToString(maeTicks,4)+","+DoubleToString(maeMoney,6)+","+(string)timeMfeSec+","+(string)timeMfeBars+","+(string)timeMaeSec+","+(string)timeMaeBars;
   r += ","+(r25?"1":"0")+","+(r50?"1":"0")+","+(r75?"1":"0")+","+(r100?"1":"0")+","+(string)t25+","+(string)t50+","+(string)t75+","+(string)t100+","+(r1?"1":"0")+","+(r15?"1":"0")+","+(r2?"1":"0")+","+(string)t1+","+(string)t15+","+(string)t2+","+(reachedOpp?"1":"0")+","+(string)timeOpp+","+(stopTouched?"1":"0")+","+(string)timeStop+","+Vegar_CsvEscape(firstOutcome)+","+(j.cost_model_incomplete?"1":"0")+",0";
   Vegar_CsvAppendContext("OPPORTUNITY_OUTCOME",h,r,j.symbol,j.execution_tf,j.strategy_hash);
  }


bool Vegar_ReplayFrozenContextValid(const SVegarReplayJob &j)
  {
   return (j.symbol!="" && j.execution_tf!=PERIOD_CURRENT && j.point>0.0 && j.tick_size>0.0 && j.digits>=0 && j.magic>0 && j.run_id!="" && j.strategy_hash!="" && j.volume>0.0);
  }

string Vegar_ReplayResolveSameBarSequence(const SVegarReplayJob &j,const MqlRates &bar)
  {
   if(!InpAtivarIntrabarTrace) return "AMBIGUOUS_SAME_BAR";
   ulong from_msc=(ulong)bar.time*1000;
   ulong to_msc=from_msc+(ulong)PeriodSeconds(j.execution_tf)*1000-1;
   MqlTick ticks[]; ArrayResize(ticks,0);
   int copied=CopyTicksRange(j.symbol,ticks,COPY_TICKS_ALL,from_msc,to_msc);
   if(copied<=0) return "AMBIGUOUS_SAME_BAR";
   for(int i=0;i<copied;i++)
     {
      double exit_price=(j.direction==VEGAR_BIAS_BUYER?ticks[i].bid:ticks[i].ask);
      if(exit_price<=0.0) continue;
      bool stop_hit=false,target_hit=false;
      if(j.stop_price>0.0)
         stop_hit=(j.direction==VEGAR_BIAS_BUYER?exit_price<=j.stop_price:exit_price>=j.stop_price);
      if(j.target_money>0.0)
        {
         double money=0.0;
         if(Vegar_CalcMoneyFromPriceForSymbol(j.symbol,j.direction,j.volume,j.entry_price,exit_price,money))
            target_hit=(money>=j.target_money);
        }
      if(target_hit && stop_hit) return "AMBIGUOUS_SAME_TICK";
      if(target_hit) return "TARGET_BEFORE_STOP";
      if(stop_hit) return "STOP_BEFORE_TARGET";
     }
   return "AMBIGUOUS_SAME_BAR";
  }

bool Vegar_ReplayEvaluateJob(SVegarReplayJob &j)
  {
   if(!j.active || j.completed) return false;
   if(!Vegar_ReplayFrozenContextValid(j))
     {
      Vegar_ReplayDiagnostic(j,"REPLAY_SYMBOL_UNAVAILABLE",Vegar_ReasonText(REPLAY_SYMBOL_UNAVAILABLE),"Frozen replay context incomplete");
      j.active=false; j.completed=true; return false;
     }
   if(j.symbol=="" || !SymbolSelect(j.symbol,true))
     {
      Vegar_ReplayDiagnostic(j,"REPLAY_SYMBOL_UNAVAILABLE",Vegar_ReasonText(REPLAY_SYMBOL_UNAVAILABLE),"Historical symbol unavailable; no cross-symbol substitution");
      j.active=false; j.completed=true; return false;
     }
   if(j.symbol!=_Symbol && (j.point<=0.0 || j.tick_size<=0.0 || j.digits<=0))
     {
      Vegar_ReplayDiagnostic(j,"REPLAY_SYMBOL_UNAVAILABLE",Vegar_ReasonText(REPLAY_SYMBOL_UNAVAILABLE),"Frozen symbol metadata invalid");
      j.active=false; j.completed=true; return false;
     }

   int originShift=iBarShift(j.symbol,j.execution_tf,j.entry_bar_time,false);
   if(originShift<j.horizon_bars+1) return false;
   double mfeMoney=-DBL_MAX,maeMoney=0.0,mfePrice=j.entry_price,maePrice=j.entry_price;
   int timeMfeSec=0,timeMaeSec=0,timeMfeBars=0,timeMaeBars=0;
   bool r25=false,r50=false,r75=false,r100=false,r1=false,r15=false,r2=false,reachedOpp=false,stopTouched=false;
   int t25=-1,t50=-1,t75=-1,t100=-1,t1=-1,t15=-1,t2=-1,timeOpp=-1,timeStop=-1;
   string firstOutcome="NEITHER";
   double stopRisk=0.0;
   if(j.stop_price>0.0)
     {
      double p=0.0; if(Vegar_CalcMoneyFromPriceForSymbol(j.symbol,j.direction,j.volume,j.entry_price,j.stop_price,p)) stopRisk=MathAbs(p);
     }

   for(int k=1;k<=j.horizon_bars;k++)
     {
      int shift=originShift-k; if(shift<1) break;
      MqlRates b; if(!Vegar_GetBarForSymbol(j.symbol,j.execution_tf,shift,b)) continue;
      double spreadPrice=(double)b.spread*j.point;
      double favExit=(j.direction==VEGAR_BIAS_BUYER?b.high:b.low+spreadPrice);
      double advExit=(j.direction==VEGAR_BIAS_BUYER?b.low:b.high+spreadPrice);
      double pf=0.0,pa=0.0;
      if(!Vegar_CalcMoneyFromPriceForSymbol(j.symbol,j.direction,j.volume,j.entry_price,favExit,pf)) continue;
      if(!Vegar_CalcMoneyFromPriceForSymbol(j.symbol,j.direction,j.volume,j.entry_price,advExit,pa)) continue;
      if(pf>mfeMoney){mfeMoney=pf;mfePrice=favExit;timeMfeBars=k;timeMfeSec=k*PeriodSeconds(j.execution_tf);}
      if(pa<maeMoney){maeMoney=pa;maePrice=advExit;timeMaeBars=k;timeMaeSec=k*PeriodSeconds(j.execution_tf);}
      if(j.target_money>0.0)
        {
         if(!r25 && pf>=0.25*j.target_money){r25=true;t25=k*PeriodSeconds(j.execution_tf);} if(!r50 && pf>=0.50*j.target_money){r50=true;t50=k*PeriodSeconds(j.execution_tf);}
         if(!r75 && pf>=0.75*j.target_money){r75=true;t75=k*PeriodSeconds(j.execution_tf);} if(!r100 && pf>=j.target_money){r100=true;t100=k*PeriodSeconds(j.execution_tf);}
        }
      if(stopRisk>0.0)
        {
         if(!r1 && pf>=stopRisk){r1=true;t1=k*PeriodSeconds(j.execution_tf);} if(!r15 && pf>=1.5*stopRisk){r15=true;t15=k*PeriodSeconds(j.execution_tf);} if(!r2 && pf>=2.0*stopRisk){r2=true;t2=k*PeriodSeconds(j.execution_tf);}
        }
      bool stopThis=false,targetThis=(j.target_money>0.0 && pf>=j.target_money);
      if(j.stop_price>0.0)
        {
         stopThis=(j.direction==VEGAR_BIAS_BUYER?b.low<=j.stop_price:b.high+spreadPrice>=j.stop_price);
         if(stopThis && !stopTouched){stopTouched=true;timeStop=k*PeriodSeconds(j.execution_tf);}
        }
      if(!reachedOpp && j.opposite_liquidity_price>0.0)
        {
         if((j.direction==VEGAR_BIAS_BUYER && b.high>=j.opposite_liquidity_price) || (j.direction==VEGAR_BIAS_SELLER && b.low+spreadPrice<=j.opposite_liquidity_price))
           {reachedOpp=true;timeOpp=k*PeriodSeconds(j.execution_tf);}
        }
      if(firstOutcome=="NEITHER")
        {
         // Without tick trace the sequence inside an OHLC candle cannot be proven.
         if(targetThis && stopThis) firstOutcome=Vegar_ReplayResolveSameBarSequence(j,b);
         else if(targetThis) firstOutcome="TARGET_BEFORE_STOP";
         else if(stopThis) firstOutcome="STOP_BEFORE_TARGET";
        }
     }

   if(mfeMoney==-DBL_MAX) return false;
   double mfePoints=MathMax(0.0,MathAbs(mfePrice-j.entry_price)/j.point);
   double maePoints=MathMax(0.0,MathAbs(maePrice-j.entry_price)/j.point);
   double mfeTicks=(j.tick_size>0?MathAbs(mfePrice-j.entry_price)/j.tick_size:0.0);
   double maeTicks=(j.tick_size>0?MathAbs(maePrice-j.entry_price)/j.tick_size:0.0);
   Vegar_WriteOpportunityOutcome(j,j.horizon_bars,mfePoints,mfeTicks,MathMax(0.0,mfeMoney),maePoints,maeTicks,MathAbs(MathMin(0.0,maeMoney)),timeMfeSec,timeMfeBars,timeMaeSec,timeMaeBars,r25,r50,r75,r100,t25,t50,t75,t100,r1,r15,r2,t1,t15,t2,reachedOpp,timeOpp,stopTouched,timeStop,firstOutcome);
   j.completed=true; j.active=false; return true;
  }

void Vegar_ReplayProcess()
  {
   if(!InpAtivarOpportunityReplay) return;
   for(int i=0;i<ArraySize(gVegarReplayJobs);i++) if(gVegarReplayJobs[i].active && !gVegarReplayJobs[i].completed) Vegar_ReplayEvaluateJob(gVegarReplayJobs[i]);
  }

#endif
