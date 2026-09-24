#ifndef __VEGAR_SETUP_MQH__
#define __VEGAR_SETUP_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Time.mqh"
#include "Vegar_Liquidity.mqh"
#include "Vegar_Channel.mqh"
#include "Vegar_Flow.mqh"
#include "Vegar_Structure.mqh"
#include "Vegar_News.mqh"
#include "Vegar_Risk.mqh"
#include "Vegar_Csv.mqh"
#include "Vegar_OpportunityReplay.mqh"

// Implemented by the RC8 observability layer, included after this module.
void Vegar_RC8ObserveClosedBar(const MqlRates &bar);
void Vegar_RC8OnTechnicalSignal(SVegarOpportunity &opp);
void Vegar_RC8MarkOperationalApproachMetadata(SVegarOpportunity &opp);
void Vegar_RC8WriteApproachEvent(const string event_name,const string candidate_id,const SVegarZoneEventSnapshot &snap,const string detail);

SVegarOpportunity gVegarOpportunity;
SVegarIntent gVegarIntent;
SVegarFlowSnapshot gVegarExecutionFlow;
SVegarFlowSnapshot gVegarM5Flow;
ENUM_VEGAR_REASON_CODE gVegarLastSetupReason=VEGAR_REASON_NONE;

void Vegar_ResetIntent()
  {
   ZeroMemory(gVegarIntent);
  }

void Vegar_ResetOpportunity()
  {
   ZeroMemory(gVegarOpportunity);
   gVegarOpportunity.state=VEGAR_SETUP_IDLE;
   Vegar_ResetIntent();
  }


void Vegar_ResetApproachLatch()
  {
   ZeroMemory(gVegarApproachLatch);
   gVegarApproachLatch.minimum_distance_atr=999.0;
  }

bool Vegar_LiveApproachMetrics(const SVegarZone &z,double &distance_atr,bool &touched,bool &entered)
  {
   distance_atr=999.0; touched=false; entered=false;
   if(!z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL) return false;
   if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) return false;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0 || !Vegar_UpdateTick()) return false;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5;
   double d=0.0;
   if(p<z.low) d=z.low-p; else if(p>z.high) d=p-z.high;
   distance_atr=d/atr;
   entered=(p>=z.low && p<=z.high);
   touched=entered || distance_atr<=InpApproachDistanceATR;
   return true;
  }

void Vegar_ExpireApproachLatch(const string reason)
  {
   if(!gVegarApproachLatch.active) return;
   SVegarZoneEventSnapshot snap; ZeroMemory(snap); snap.valid=true; snap.zone_id=gVegarApproachLatch.zone_id; snap.symbol=_Symbol; snap.distance_atr=gVegarApproachLatch.minimum_distance_atr;
   Vegar_RC8WriteApproachEvent("APPROACH_LATCH_EXPIRED",gVegarApproachLatch.candidate_id,snap,reason);
   Vegar_ResetApproachLatch();
  }

void Vegar_UpdateLiveApproachLatch()
  {
   if(!gVegarOperational || Vegar_HasOwnedPosition() || gVegarOpportunity.active) return;
   datetime currentBar=iTime(_Symbol,Vegar_ExecutionTF(),0);
   if(gVegarApproachLatch.active && currentBar>0 && currentBar!=gVegarApproachLatch.current_bar_time)
     {
      gVegarApproachLatch.current_bar_time=currentBar;
      gVegarApproachLatch.bars_alive++;
      if(gVegarApproachLatch.bars_alive>2)
        { Vegar_ExpireApproachLatch("MAX_2_EXEC_BARS"); return; }
     }

   if(gVegarApproachLatch.active)
     {
      int li=Vegar_FindZoneIndex(gVegarApproachLatch.zone_id);
      if(li<0 || !gVegarZones[li].valid || gVegarZones[li].symbol!=_Symbol ||
         gVegarZones[li].state==VEGAR_ZONE_INVALIDATED || gVegarZones[li].state==VEGAR_ZONE_EXPIRED || gVegarZones[li].state==VEGAR_ZONE_SWEPT)
        { Vegar_ExpireApproachLatch("ZONE_NOT_ELIGIBLE"); return; }
     }

   int zi=Vegar_SelectTechnicalCandidateZone(); if(zi<0) return;
   double dist=999.0; bool touched=false,entered=false;
   if(!Vegar_LiveApproachMetrics(gVegarZones[zi],dist,touched,entered) || dist>InpApproachDistanceATR) return;

   long nowMsc=gVegarTick.time_msc;
   if(!gVegarApproachLatch.active || gVegarApproachLatch.zone_id!=gVegarZones[zi].id)
     {
      if(gVegarApproachLatch.active) Vegar_ExpireApproachLatch("INCOMPATIBLE_CANDIDATE_REPLACED");
      Vegar_ResetApproachLatch();
      gVegarApproachLatch.active=true;
      gVegarApproachLatch.candidate_id=Vegar_NextID("CAND");
      gVegarApproachLatch.zone_id=gVegarZones[zi].id;
      gVegarApproachLatch.direction=gVegarZones[zi].operational_bias;
      gVegarApproachLatch.first_approach_time_msc=nowMsc;
      gVegarApproachLatch.last_approach_time_msc=nowMsc;
      gVegarApproachLatch.minimum_distance_atr=dist;
      gVegarApproachLatch.touched_zone=touched;
      gVegarApproachLatch.entered_zone=entered;
      gVegarApproachLatch.current_bar_time=currentBar;
      gVegarApproachLatch.bars_alive=0;
      SVegarZoneEventSnapshot snap; ZeroMemory(snap); snap.valid=true; snap.zone_id=gVegarZones[zi].id; snap.symbol=_Symbol; snap.role=gVegarZones[zi].role; snap.type=gVegarZones[zi].type; snap.source_tf=gVegarZones[zi].source_tf; snap.bias=gVegarZones[zi].operational_bias; snap.pre_state=gVegarZones[zi].state; snap.pre_strength=gVegarZones[zi].strength_score; snap.low=gVegarZones[zi].low; snap.high=gVegarZones[zi].high; snap.mid=gVegarZones[zi].mid; snap.distance_atr=dist; snap.approach_observed=true;
      Vegar_RC8WriteApproachEvent("APPROACH_LATCH_CREATED",gVegarApproachLatch.candidate_id,snap,"APPROACH_FROM_LIVE_PRICE");
     }
   else
     {
      bool changed=(dist+1e-9<gVegarApproachLatch.minimum_distance_atr || (touched&&!gVegarApproachLatch.touched_zone) || (entered&&!gVegarApproachLatch.entered_zone));
      gVegarApproachLatch.last_approach_time_msc=nowMsc;
      if(dist<gVegarApproachLatch.minimum_distance_atr) gVegarApproachLatch.minimum_distance_atr=dist;
      gVegarApproachLatch.touched_zone=(gVegarApproachLatch.touched_zone||touched);
      gVegarApproachLatch.entered_zone=(gVegarApproachLatch.entered_zone||entered);
      if(changed)
        {
         SVegarZoneEventSnapshot snap; ZeroMemory(snap); snap.valid=true; snap.zone_id=gVegarZones[zi].id; snap.symbol=_Symbol; snap.role=gVegarZones[zi].role; snap.type=gVegarZones[zi].type; snap.source_tf=gVegarZones[zi].source_tf; snap.bias=gVegarZones[zi].operational_bias; snap.pre_state=gVegarZones[zi].state; snap.pre_strength=gVegarZones[zi].strength_score; snap.low=gVegarZones[zi].low; snap.high=gVegarZones[zi].high; snap.mid=gVegarZones[zi].mid; snap.distance_atr=dist; snap.approach_observed=true;
         Vegar_RC8WriteApproachEvent("APPROACH_LATCH_UPDATED",gVegarApproachLatch.candidate_id,snap,"APPROACH_FROM_LIVE_PRICE");
        }
     }
  }

bool Vegar_PrepareZoneEventSnapshot(const MqlRates &bar,SVegarZoneEventSnapshot &snap)
  {
   ZeroMemory(snap);
   double d=DBL_MAX; int zi=-1;
   if(gVegarApproachLatch.active)
     {
      int li=Vegar_FindZoneIndex(gVegarApproachLatch.zone_id);
      if(li>=0 && gVegarZones[li].valid && gVegarZones[li].symbol==_Symbol && gVegarZones[li].role==VEGAR_ZONE_ROLE_OPERATIONAL &&
         gVegarZones[li].state!=VEGAR_ZONE_INVALIDATED && gVegarZones[li].state!=VEGAR_ZONE_EXPIRED && gVegarZones[li].state!=VEGAR_ZONE_SWEPT &&
         gVegarZones[li].strength_score>=InpForcaMinimaZona)
        {
         double bd=999.0;
         bool closed=Vegar_ClosedBarApproachForRole(gVegarZones[li],bar,VEGAR_ZONE_ROLE_OPERATIONAL,bd);
         if(closed || gVegarApproachLatch.touched_zone || gVegarApproachLatch.minimum_distance_atr<=InpApproachDistanceATR)
           { zi=li; d=MathMin(bd,gVegarApproachLatch.minimum_distance_atr); }
        }
     }
   if(zi<0) zi=Vegar_SelectTechnicalCandidateZoneForBar(bar,d);
   if(zi<0) return false;

   SVegarZone z=gVegarZones[zi];
   snap.valid=true; snap.zone_id=z.id; snap.symbol=z.symbol; snap.role=z.role; snap.type=z.type; snap.source_tf=z.source_tf; snap.bias=z.operational_bias; snap.liquidity_side=z.liquidity_side;
   snap.pre_state=z.state; snap.pre_strength=z.strength_score; snap.low=z.low; snap.high=z.high; snap.mid=z.mid; snap.source_atr=z.source_atr;
   snap.closed_bar_time=bar.time; snap.closed_bar_open=bar.open; snap.closed_bar_high=bar.high; snap.closed_bar_low=bar.low; snap.closed_bar_close=bar.close;
   double closedDist=999.0; bool closedApproach=Vegar_ClosedBarApproachForRole(z,bar,VEGAR_ZONE_ROLE_OPERATIONAL,closedDist);
   bool liveApproach=(gVegarApproachLatch.active && gVegarApproachLatch.zone_id==z.id);
   snap.approach_observed=(closedApproach||liveApproach);
   snap.distance_atr=(liveApproach?MathMin(closedDist,gVegarApproachLatch.minimum_distance_atr):closedDist);
   bool deep=false; double extreme=0.0; snap.sweep_observed=Vegar_SweepConfirmed(z,bar,deep,extreme); snap.sweep_too_deep=deep; snap.sweep_extreme=extreme;
   snap.post_state=snap.pre_state;
   return snap.approach_observed || snap.sweep_observed || snap.sweep_too_deep;
  }

void Vegar_UpdateZoneEventPostState(SVegarZoneEventSnapshot &snap)
  {
   if(!snap.valid) return;
   int zi=Vegar_FindZoneIndex(snap.zone_id);
   if(zi>=0) snap.post_state=gVegarZones[zi].state;
  }

void Vegar_CaptureClosedBarApproachCandidate(const SVegarZoneEventSnapshot &snap)
  {
   if(!snap.valid || !snap.approach_observed || snap.sweep_observed || gVegarOpportunity.active) return;
   long barMsc=(long)snap.closed_bar_time*1000;
   if(!gVegarApproachLatch.active || gVegarApproachLatch.zone_id!=snap.zone_id)
     {
      if(gVegarApproachLatch.active) Vegar_ExpireApproachLatch("INCOMPATIBLE_CANDIDATE_REPLACED");
      Vegar_ResetApproachLatch();
      gVegarApproachLatch.active=true;
      gVegarApproachLatch.candidate_id=Vegar_NextID("CAND");
      gVegarApproachLatch.zone_id=snap.zone_id;
      gVegarApproachLatch.direction=snap.bias;
      gVegarApproachLatch.first_approach_time_msc=barMsc;
      gVegarApproachLatch.last_approach_time_msc=barMsc;
      gVegarApproachLatch.minimum_distance_atr=snap.distance_atr;
      gVegarApproachLatch.current_bar_time=snap.closed_bar_time;
      gVegarApproachLatch.bars_alive=0;
      gVegarApproachLatch.touched_zone=(snap.closed_bar_low<=snap.high && snap.closed_bar_high>=snap.low);
      gVegarApproachLatch.entered_zone=gVegarApproachLatch.touched_zone;
      Vegar_RC8WriteApproachEvent("APPROACH_LATCH_CREATED",gVegarApproachLatch.candidate_id,snap,"APPROACH_FROM_CLOSED_BAR");
     }
   else
     {
      gVegarApproachLatch.last_approach_time_msc=barMsc;
      if(snap.distance_atr<gVegarApproachLatch.minimum_distance_atr) gVegarApproachLatch.minimum_distance_atr=snap.distance_atr;
      gVegarApproachLatch.touched_zone=(gVegarApproachLatch.touched_zone || (snap.closed_bar_low<=snap.high && snap.closed_bar_high>=snap.low));
      gVegarApproachLatch.entered_zone=(gVegarApproachLatch.entered_zone || gVegarApproachLatch.touched_zone);
      Vegar_RC8WriteApproachEvent("APPROACH_LATCH_UPDATED",gVegarApproachLatch.candidate_id,snap,"APPROACH_FROM_CLOSED_BAR");
     }
  }

bool Vegar_StartOpportunityFromSnapshot(const SVegarZoneEventSnapshot &snap)
  {
   if(!snap.valid || !snap.approach_observed || !snap.sweep_observed || gVegarOpportunity.active || Vegar_HasOwnedPosition()) return false;
   Vegar_ResetOpportunity();
   gVegarOpportunity.active=true;
   gVegarOpportunity.candidate_id=(gVegarApproachLatch.active && gVegarApproachLatch.zone_id==snap.zone_id ? gVegarApproachLatch.candidate_id : Vegar_NextID("CAND"));
   gVegarOpportunity.candidate_state=VEGAR_CANDIDATE_PROMOTED;
   gVegarOpportunity.setup_family=VEGAR_SETUP_FAMILY_STRUCTURAL_REVERSAL;
   gVegarOpportunity.observation_candidate=false;
   gVegarOpportunity.opportunity_id=Vegar_NextID("OPP");
   gVegarOpportunity.setup_id=Vegar_NextID("SETUP");
   gVegarOpportunity.signal_id=Vegar_NextID("SIG");
   gVegarOpportunity.created_time=snap.closed_bar_time;
   gVegarOpportunity.direction=snap.bias;
   gVegarOpportunity.focus_zone_id=snap.zone_id;
   gVegarOpportunity.focus_zone_strength=snap.pre_strength;
   gVegarOpportunity.source_zone_id=snap.zone_id;
   gVegarOpportunity.source_zone_role=snap.role;
   gVegarOpportunity.source_zone_type=snap.type;
   gVegarOpportunity.source_zone_tf=snap.source_tf;
   gVegarOpportunity.source_zone_bias=snap.bias;
   gVegarOpportunity.source_zone_liquidity_side=snap.liquidity_side;
   gVegarOpportunity.source_zone_pre_state=snap.pre_state;
   gVegarOpportunity.source_zone_post_state=snap.post_state;
   gVegarOpportunity.source_zone_consumed_by_opportunity=false;
   gVegarOpportunity.source_zone_low=snap.low; gVegarOpportunity.source_zone_high=snap.high; gVegarOpportunity.source_zone_mid=snap.mid; gVegarOpportunity.source_zone_atr=snap.source_atr;
   bool live=(gVegarApproachLatch.active && gVegarApproachLatch.zone_id==snap.zone_id);
   bool closed=true;
   gVegarOpportunity.approach_mode=(live&&closed?VEGAR_APPROACH_BOTH:(live?VEGAR_APPROACH_LIVE:VEGAR_APPROACH_CLOSED_BAR));
   gVegarOpportunity.approach_first_time=(live && gVegarApproachLatch.first_approach_time_msc>0 ? (datetime)(gVegarApproachLatch.first_approach_time_msc/1000) : snap.closed_bar_time);
   gVegarOpportunity.approach_minimum_distance_atr=(live?MathMin(snap.distance_atr,gVegarApproachLatch.minimum_distance_atr):snap.distance_atr);
   gVegarOpportunity.sweep_same_bar_as_approach=snap.sweep_observed;
   gVegarOpportunity.operational_eligible_at_approach=true; // legacy field retained; no execution authority in RC8.
   gVegarOpportunity.approach_block_reason=VEGAR_REASON_NONE;
   gVegarOpportunity.operational_approach_armed=true;
   gVegarStats.opportunities_created++;
   Vegar_SetOpportunityState(VEGAR_SETUP_LIQUIDITY_APPROACH,VEGAR_REASON_NONE,"OPPORTUNITY_STARTED");
   Vegar_RC8WriteApproachEvent("OPPORTUNITY_PROMOTED",gVegarOpportunity.candidate_id,snap,"SetupFamily=STRUCTURAL_REVERSAL|ApproachMode="+Vegar_ApproachModeText(gVegarOpportunity.approach_mode));
   if(gVegarApproachLatch.active && gVegarApproachLatch.zone_id==snap.zone_id)
     {
      Vegar_RC8WriteApproachEvent("APPROACH_LATCH_PROMOTED",gVegarApproachLatch.candidate_id,snap,"OpportunityID="+gVegarOpportunity.opportunity_id);
      Vegar_ResetApproachLatch();
     }
   return true;
  }

SVegarZone Vegar_SourceZoneSnapshot(const SVegarOpportunity &opp)
  {
   SVegarZone z; ZeroMemory(z);
   z.valid=true; z.id=opp.source_zone_id; z.symbol=_Symbol; z.role=opp.source_zone_role; z.type=opp.source_zone_type; z.source_tf=opp.source_zone_tf;
   z.operational_bias=opp.source_zone_bias; z.liquidity_side=opp.source_zone_liquidity_side; z.state=opp.source_zone_pre_state; z.strength_score=opp.focus_zone_strength;
   z.low=opp.source_zone_low; z.high=opp.source_zone_high; z.mid=opp.source_zone_mid; z.source_atr=opp.source_zone_atr;
   return z;
  }

void Vegar_SetOpportunityState(const ENUM_VEGAR_SETUP_STATE s,const ENUM_VEGAR_REASON_CODE reason,const string stage)
  {
   gVegarOpportunity.state=s; gVegarOpportunity.pipeline_state=stage; gVegarOpportunity.state_time=TimeTradeServer(); gVegarOpportunity.last_reason=reason;
   gVegarOpportunity.snapshot_id=Vegar_NextID("SNAP");
   Vegar_WriteSignalDecision(stage,Vegar_SetupStateText(s),reason==VEGAR_REASON_NONE,reason,gVegarOpportunity,gVegarExecutionFlow,Vegar_SetupStateText(s));
   Vegar_WriteOpportunitySnapshot(gVegarOpportunity,stage,(reason==VEGAR_REASON_NONE?"ACCEPTED":"BLOCKED"),reason,gVegarExecutionFlow,gVegarChannelM15);
  }

void Vegar_TerminateOpportunity(const ENUM_VEGAR_SETUP_STATE terminal,const ENUM_VEGAR_REASON_CODE reason,const string stage)
  {
   if(!gVegarOpportunity.active) return;
   Vegar_SetOpportunityState(terminal,reason,stage);
   if(InpAtivarOpportunityReplay) Vegar_ReplayQueue(gVegarOpportunity);
   gVegarOpportunity.terminal_recorded=true;
   if(terminal==VEGAR_SETUP_BLOCKED) gVegarStats.opportunities_blocked++;
   if(terminal==VEGAR_SETUP_EXPIRED) gVegarStats.opportunities_expired++;
   gVegarOpportunity.active=false;
  }

bool Vegar_PreApproachSpreadGate(const ENUM_VEGAR_BIAS direction,double &opposite_price,double &expected_money,ENUM_VEGAR_REASON_CODE &reason)
  {
   reason=VEGAR_REASON_NONE; opposite_price=0.0; expected_money=0.0;
   if(!Vegar_UpdateTick()) { reason=PRICE_INVALID; return false; }
   double entry=(direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid);
   string zid=""; double strength=0.0;
   if(!Vegar_FindOppositeLiquidity(direction,entry,opposite_price,zid,strength)) { reason=ECONOMIC_TARGET_UNAVAILABLE; return false; }
   double target=0.0;
   if(!Vegar_CalcEconomicTarget(direction,entry,opposite_price,target,expected_money)) { reason=ECONOMIC_TARGET_UNAVAILABLE; return false; }
   if(InpAtivarMetaOperacao && expected_money<InpMetaOperacaoMoney) { reason=TARGET_SPACE_INSUFFICIENT; return false; }
   double spreadMoney=Vegar_SpreadMoney(InpLoteOperacional);
   if(target<=0.0) { reason=ECONOMIC_TARGET_UNAVAILABLE; return false; }
   if(spreadMoney/target*100.0>InpMaxSpreadTargetPercent) { reason=SPREAD_TOO_HIGH; return false; }
   return true;
  }

bool Vegar_CheckM5Conflict(const ENUM_VEGAR_BIAS direction)
  {
   if(Vegar_ExecutionTF()!=PERIOD_M1 || !InpConfirmarM5QuandoM1) return false;
   gVegarM5Flow=Vegar_CalcFlow(PERIOD_M5);
   SVegarChannel c=Vegar_BuildChannel(PERIOD_M5);
   double ph=0,lh=0,pl=0,ll=0; datetime t1,t2;
   bool hi=Vegar_FindLastTwoPivotHighs(PERIOD_M5,t1,ph,t2,lh);
   bool lo=Vegar_FindLastTwoPivotLows(PERIOD_M5,t1,pl,t2,ll);
   bool trendDown=(hi&&lo&&lh<ph&&ll<pl&&c.direction==VEGAR_CHANNEL_SELLER);
   bool trendUp=(hi&&lo&&lh>ph&&ll>pl&&c.direction==VEGAR_CHANNEL_BUYER);
   if(direction==VEGAR_BIAS_BUYER && gVegarM5Flow.flow_score<=-60.0 && trendDown) return true;
   if(direction==VEGAR_BIAS_SELLER && gVegarM5Flow.flow_score>=60.0 && trendUp) return true;
   return false;
  }

bool Vegar_FindLastMicroSwing(const ENUM_VEGAR_BIAS direction,const datetime before_time,double &level)
  {
   level=0.0; MqlRates r[]; ENUM_TIMEFRAMES tf=Vegar_ExecutionTF();
   if(!Vegar_CopyRates(tf,1,80,r)) return false;
   for(int i=3;i<ArraySize(r)-3;i++)
     {
      datetime confirmed=r[i].time+3*PeriodSeconds(tf);
      if(before_time>0 && confirmed>=before_time) continue;
      if(direction==VEGAR_BIAS_BUYER && Vegar_IsPivotHigh(r,i,2,2)) { level=r[i].high; return true; }
      if(direction==VEGAR_BIAS_SELLER && Vegar_IsPivotLow(r,i,2,2)) { level=r[i].low; return true; }
     }
   return false;
  }

bool Vegar_SweepConfirmed(const SVegarZone &z,const MqlRates &bar,bool &too_deep,double &extreme)
  {
   too_deep=false; extreme=0.0;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) return false;
   double minPen=MathMax(2.0*gVegarSymbol.tick_size,InpMinSweepATR*atr);
   double maxPen=InpMaxSweepATR*atr;
   if(z.operational_bias==VEGAR_BIAS_BUYER)
     {
      extreme=bar.low; double pen=z.low-bar.low;
      if(pen>maxPen && bar.close<z.low) { too_deep=true; return false; }
      return (bar.low<=z.low-minPen && bar.close>=z.mid);
     }
   if(z.operational_bias==VEGAR_BIAS_SELLER)
     {
      extreme=bar.high; double pen=bar.high-z.high;
      if(pen>maxPen && bar.close>z.high) { too_deep=true; return false; }
      return (bar.high>=z.high+minPen && bar.close<=z.mid);
     }
   return false;
  }

bool Vegar_MSSConfirmed(const ENUM_VEGAR_BIAS direction,const MqlRates &bar,const double swing_level)
  {
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0 || swing_level<=0.0) return false;
   double buffer=MathMax(gVegarSymbol.tick_size,InpMSSBufferATR*atr);
   if(direction==VEGAR_BIAS_BUYER) return (bar.close>swing_level+buffer);
   if(direction==VEGAR_BIAS_SELLER) return (bar.close<swing_level-buffer);
   return false;
  }

bool Vegar_DisplacementConfirmed(const ENUM_VEGAR_BIAS direction,const MqlRates &bar)
  {
   double range=bar.high-bar.low; if(range<=0.0) return false;
   double avg20=Vegar_AvgRange(Vegar_ExecutionTF(),2,20); if(avg20<=0.0) return false;
   double body=MathAbs(bar.close-bar.open); double cl=(bar.close-bar.low)/range;
   if(direction==VEGAR_BIAS_BUYER) return (range>=2.0*avg20 && body/range>=0.60 && cl>=0.75);
   if(direction==VEGAR_BIAS_SELLER) return (range>=2.0*avg20 && body/range>=0.60 && cl<=0.25);
   return false;
  }

bool Vegar_CreateFVG(const ENUM_VEGAR_BIAS direction,double &low,double &high)
  {
   MqlRates r[]; if(!Vegar_CopyRates(Vegar_ExecutionTF(),1,3,r)) return false;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) return false;
   double minSize=MathMax(2.0*gVegarSymbol.tick_size,InpMinFVGATR*atr);
   if(direction==VEGAR_BIAS_BUYER)
     {
      if(r[0].low>r[2].high && r[0].low-r[2].high>=minSize) { low=r[2].high; high=r[0].low; return true; }
     }
   else if(direction==VEGAR_BIAS_SELLER)
     {
      if(r[0].high<r[2].low && r[2].low-r[0].high>=minSize) { low=r[0].high; high=r[2].low; return true; }
     }
   return false;
  }

bool Vegar_CreateOrderBlock(const ENUM_VEGAR_BIAS direction,const datetime displacement_time,double &low,double &high)
  {
   MqlRates r[]; if(!Vegar_CopyRates(Vegar_ExecutionTF(),1,12,r)) return false;
   for(int i=1;i<ArraySize(r);i++)
     {
      if(r[i].time>=displacement_time) continue;
      if(gVegarOpportunity.sweep_time>0 && r[i].time<gVegarOpportunity.sweep_time-PeriodSeconds(Vegar_ExecutionTF())*2) break;
      bool bearish=(r[i].close<r[i].open),bullish=(r[i].close>r[i].open);
      if(direction==VEGAR_BIAS_BUYER && bearish) { low=r[i].low; high=r[i].high; return true; }
      if(direction==VEGAR_BIAS_SELLER && bullish) { low=r[i].low; high=r[i].high; return true; }
     }
   return false;
  }

bool Vegar_RetestConfirmed(const ENUM_VEGAR_BIAS direction,const MqlRates &bar,const double low,const double high)
  {
   double range=bar.high-bar.low; if(range<=0.0) return false;
   double mid=(low+high)*0.5; double cl=(bar.close-bar.low)/range;
   if(direction==VEGAR_BIAS_BUYER)
      return (bar.low<=high && bar.close>=mid && bar.close>bar.open && cl>=0.60);
   if(direction==VEGAR_BIAS_SELLER)
      return (bar.high>=low && bar.close<=mid && bar.close<bar.open && cl<=0.40);
   return false;
  }

bool Vegar_BuildStopsAndTargets(SVegarOpportunity &opp)
  {
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0 || opp.sweep_extreme<=0.0) return false;
   double buffer=MathMax(2.0*gVegarSymbol.tick_size,InpStopBufferATR*atr);
   if(opp.direction==VEGAR_BIAS_BUYER) opp.technical_stop=Vegar_NormalizePriceToTick(opp.sweep_extreme-buffer);
   else opp.technical_stop=Vegar_NormalizePriceToTick(opp.sweep_extreme+buffer);
   if(!Vegar_UpdateTick()) return false;
   double entry=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid);
   double stopPnl=0.0; if(!Vegar_CalcMoneyFromPrice(opp.direction,InpLoteOperacional,entry,opp.technical_stop,stopPnl)) return false;
   opp.technical_stop_money=MathAbs(stopPnl);
   // RC8: opposite liquidity/target is an execution gate, not a prerequisite for the technical pattern.
   opp.opposite_liquidity_price=0.0; opp.expected_money_opposite=0.0;
   string zid=""; double strength=0.0;
   if(Vegar_FindOppositeLiquidity(opp.direction,entry,opp.opposite_liquidity_price,zid,strength))
     {
      double target=0.0;
      Vegar_CalcEconomicTarget(opp.direction,entry,opp.opposite_liquidity_price,target,opp.expected_money_opposite);
     }
   return true;
  }

bool Vegar_CreateIntentFromOpportunity()
  {
   if(gVegarOpportunity.intent_emitted) return false;
   if(!Vegar_UpdateTick()) return false;
   Vegar_ResetIntent();
   gVegarIntent.valid=true; gVegarIntent.processed=false; gVegarIntent.intent_id=Vegar_NextID("INTENT");
   gVegarIntent.opportunity_id=gVegarOpportunity.opportunity_id; gVegarIntent.snapshot_id=gVegarOpportunity.snapshot_id; gVegarIntent.setup_id=gVegarOpportunity.setup_id; gVegarIntent.signal_id=gVegarOpportunity.signal_id; gVegarIntent.focus_zone_id=gVegarOpportunity.focus_zone_id; gVegarIntent.direction=gVegarOpportunity.direction;
   gVegarIntent.signal_bar_time=gVegarOpportunity.retest_time; gVegarIntent.created_time=TimeTradeServer(); gVegarIntent.requested_volume=InpLoteOperacional;
   gVegarIntent.entry_price=(gVegarIntent.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid); gVegarIntent.stop_price=gVegarOpportunity.technical_stop; gVegarIntent.stop_money=gVegarOpportunity.technical_stop_money;
   double target=0.0,expected=0.0;
   if(!Vegar_CalcEconomicTarget(gVegarIntent.direction,gVegarIntent.entry_price,gVegarOpportunity.opposite_liquidity_price,target,expected)) { gVegarIntent.valid=false; return false; }
   gVegarIntent.economic_target_money=target;
   gVegarIntent.take_profit_price=0.0;
   if(InpAtivarTakeProfit && (InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT || InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT_E_RUNNER))
     {
      if(!Vegar_FindPriceForNetProfitMoney(gVegarIntent.direction,gVegarIntent.requested_volume,gVegarIntent.entry_price,InpTakeProfitMoney,gVegarIntent.take_profit_price)) { gVegarIntent.valid=false; return false; }
     }
   gVegarOpportunity.intent_emitted=true; gVegarStats.intents_created++;
   return true;
  }

bool Vegar_StartOpportunityIfEligible()
  {
   // Legacy entry point retained for ABI/source continuity. RC8 starts from a PRE-state closed-bar snapshot.
   MqlRates bar; if(!Vegar_GetBar(Vegar_ExecutionTF(),1,bar)) return false;
   SVegarZoneEventSnapshot snap; if(!Vegar_PrepareZoneEventSnapshot(bar,snap)) return false;
   return Vegar_StartOpportunityFromSnapshot(snap);
  }

void Vegar_ProcessActiveOpportunity(const MqlRates &bar)
  {
   if(!gVegarOpportunity.active) return;
   int zi=Vegar_FindZoneIndex(gVegarOpportunity.source_zone_id);
   if(zi>=0 && gVegarZones[zi].state==VEGAR_ZONE_INVALIDATED)
     { Vegar_TerminateOpportunity(VEGAR_SETUP_INVALIDATED_STATE,SETUP_INVALIDATED_REASON,"ZONE_INVALIDATED"); return; }
   // The Opportunity owns an immutable source-zone snapshot. Global SWEPT is expected after the consuming sweep.
   SVegarZone z=Vegar_SourceZoneSnapshot(gVegarOpportunity);
   ENUM_TIMEFRAMES tf=Vegar_ExecutionTF();

   if(gVegarOpportunity.state==VEGAR_SETUP_LIQUIDITY_APPROACH)
     {
      bool deep=false; double extreme=0.0;
      if(Vegar_SweepConfirmed(z,bar,deep,extreme))
        {
         gVegarOpportunity.sweep_time=bar.time; gVegarOpportunity.sweep_extreme=extreme; gVegarOpportunity.bars_since_sweep=0;
         gVegarOpportunity.source_zone_consumed_by_opportunity=true;
         gVegarOpportunity.sweep_same_bar_as_approach=(gVegarOpportunity.created_time==bar.time);
         int szi=Vegar_FindZoneIndex(gVegarOpportunity.source_zone_id);
         if(szi>=0) gVegarOpportunity.source_zone_post_state=gVegarZones[szi].state;
         if(!Vegar_FindLastMicroSwing(gVegarOpportunity.direction,bar.time,gVegarOpportunity.micro_break_level))
           { Vegar_TerminateOpportunity(VEGAR_SETUP_EXPIRED,MSS_NOT_CONFIRMED,"NO_MICRO_SWING"); return; }
         Vegar_SetOpportunityState(VEGAR_SETUP_SWEEP_CONFIRMED,VEGAR_REASON_NONE,"SWEEP_CONFIRMED");
         Vegar_SetOpportunityState(VEGAR_SETUP_WAITING_MSS,VEGAR_REASON_NONE,"WAITING_MSS");
        }
      else if(deep)
        { Vegar_TerminateOpportunity(VEGAR_SETUP_INVALIDATED_STATE,SWEEP_TOO_DEEP,"SWEEP_TOO_DEEP"); return; }
      return;
     }

   if(gVegarOpportunity.state==VEGAR_SETUP_WAITING_MSS)
     {
      gVegarOpportunity.bars_since_sweep++;
      if(gVegarOpportunity.bars_since_sweep>InpMaxBarsSweepToMSS)
        { Vegar_TerminateOpportunity(VEGAR_SETUP_EXPIRED,MSS_NOT_CONFIRMED,"SWEEP_TO_MSS_EXPIRED"); return; }
      double __atr_mss=Vegar_ATR(Vegar_ExecutionTF(),1);
      double __buf_mss=MathMax(gVegarSymbol.tick_size,InpMSSBufferATR*__atr_mss);
      gVegarOpportunity.mss_required_level=(gVegarOpportunity.direction==VEGAR_BIAS_BUYER ? gVegarOpportunity.micro_break_level+__buf_mss : gVegarOpportunity.micro_break_level-__buf_mss);
      if(gVegarOpportunity.mss_best_observed==0.0 ||
         (gVegarOpportunity.direction==VEGAR_BIAS_BUYER && bar.close>gVegarOpportunity.mss_best_observed) ||
         (gVegarOpportunity.direction==VEGAR_BIAS_SELLER && bar.close<gVegarOpportunity.mss_best_observed)) gVegarOpportunity.mss_best_observed=bar.close;
      gVegarOpportunity.mss_distance_missing=(gVegarOpportunity.direction==VEGAR_BIAS_BUYER ? MathMax(0.0,gVegarOpportunity.mss_required_level-gVegarOpportunity.mss_best_observed) : MathMax(0.0,gVegarOpportunity.mss_best_observed-gVegarOpportunity.mss_required_level));
      if(Vegar_MSSConfirmed(gVegarOpportunity.direction,bar,gVegarOpportunity.micro_break_level))
        {
         gVegarOpportunity.mss_time=bar.time; gVegarOpportunity.bars_since_mss=0;
         Vegar_SetOpportunityState(VEGAR_SETUP_MSS_CONFIRMED,VEGAR_REASON_NONE,"MSS_CONFIRMED");
         double __avg_disp=Vegar_AvgRange(Vegar_ExecutionTF(),2,20); double __rng_disp=bar.high-bar.low;
         gVegarOpportunity.displacement_required_range_ratio=2.0;
         gVegarOpportunity.displacement_observed_range_ratio=(__avg_disp>0.0?__rng_disp/__avg_disp:0.0);
         gVegarOpportunity.displacement_required_close_location=(gVegarOpportunity.direction==VEGAR_BIAS_BUYER?0.75:0.25);
         gVegarOpportunity.displacement_observed_close_location=(__rng_disp>0.0?(bar.close-bar.low)/__rng_disp:0.0);
         if(Vegar_DisplacementConfirmed(gVegarOpportunity.direction,bar))
           {
            gVegarOpportunity.displacement_time=bar.time;
            Vegar_SetOpportunityState(VEGAR_SETUP_DISPLACEMENT_CONFIRMED,VEGAR_REASON_NONE,"DISPLACEMENT_CONFIRMED");
           }
         else Vegar_SetOpportunityState(VEGAR_SETUP_WAITING_DISPLACEMENT,VEGAR_REASON_NONE,"WAITING_DISPLACEMENT");
        }
      return;
     }

   if(gVegarOpportunity.state==VEGAR_SETUP_WAITING_DISPLACEMENT)
     {
      gVegarOpportunity.bars_since_mss++;
      if(gVegarOpportunity.bars_since_mss>1)
        { Vegar_TerminateOpportunity(VEGAR_SETUP_EXPIRED,DISPLACEMENT_NOT_CONFIRMED,"MSS_TO_DISPLACEMENT_EXPIRED"); return; }
      double __avg_disp2=Vegar_AvgRange(Vegar_ExecutionTF(),2,20); double __rng_disp2=bar.high-bar.low;
      gVegarOpportunity.displacement_required_range_ratio=2.0;
      gVegarOpportunity.displacement_observed_range_ratio=(__avg_disp2>0.0?__rng_disp2/__avg_disp2:0.0);
      gVegarOpportunity.displacement_required_close_location=(gVegarOpportunity.direction==VEGAR_BIAS_BUYER?0.75:0.25);
      gVegarOpportunity.displacement_observed_close_location=(__rng_disp2>0.0?(bar.close-bar.low)/__rng_disp2:0.0);
      if(!Vegar_DisplacementConfirmed(gVegarOpportunity.direction,bar)) return;
      gVegarOpportunity.displacement_time=bar.time;
      Vegar_SetOpportunityState(VEGAR_SETUP_DISPLACEMENT_CONFIRMED,VEGAR_REASON_NONE,"DISPLACEMENT_CONFIRMED");
     }

   if(gVegarOpportunity.state==VEGAR_SETUP_DISPLACEMENT_CONFIRMED)
     {
      double lo=0.0,hi=0.0;
      if(Vegar_CreateFVG(gVegarOpportunity.direction,lo,hi)) gVegarOpportunity.retest_type=VEGAR_RETEST_FVG;
      else if(Vegar_CreateOrderBlock(gVegarOpportunity.direction,gVegarOpportunity.displacement_time,lo,hi)) gVegarOpportunity.retest_type=VEGAR_RETEST_ORDER_BLOCK;
      else { Vegar_TerminateOpportunity(VEGAR_SETUP_EXPIRED,NO_FVG_OR_OB,"NO_ENTRY_ZONE"); return; }
      gVegarOpportunity.retest_low=lo; gVegarOpportunity.retest_high=hi; gVegarOpportunity.retest_mid=(lo+hi)*0.5;
      if(!Vegar_BuildStopsAndTargets(gVegarOpportunity)) { Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,ECONOMIC_TARGET_UNAVAILABLE,"ECONOMIC_PREP_FAIL"); return; }
      Vegar_SetOpportunityState(VEGAR_SETUP_ENTRY_ZONE_CREATED,VEGAR_REASON_NONE,(gVegarOpportunity.retest_type==VEGAR_RETEST_FVG?"FVG_CREATED":"OB_CREATED"));
      Vegar_SetOpportunityState(VEGAR_SETUP_WAITING_RETEST,VEGAR_REASON_NONE,"WAITING_RETEST");
      return;
     }

   if(gVegarOpportunity.state==VEGAR_SETUP_WAITING_RETEST)
     {
      gVegarOpportunity.bars_since_mss++;
      if(gVegarOpportunity.bars_since_mss>InpMaxBarsMssToRetest)
        { Vegar_TerminateOpportunity(VEGAR_SETUP_EXPIRED,RETEST_EXPIRED,"RETEST_EXPIRED"); return; }
      if(!Vegar_RetestConfirmed(gVegarOpportunity.direction,bar,gVegarOpportunity.retest_low,gVegarOpportunity.retest_high)) return;
      gVegarOpportunity.retest_time=bar.time;
      Vegar_UpdateTick(); gVegarOpportunity.hypothetical_entry_bid=gVegarTick.bid; gVegarOpportunity.hypothetical_entry_ask=gVegarTick.ask;
      Vegar_SetOpportunityState(VEGAR_SETUP_RETEST_CONFIRMED,VEGAR_REASON_NONE,"RETEST_CONFIRMED");
      Vegar_RC8OnTechnicalSignal(gVegarOpportunity);
      if(!gVegarOpportunity.execution_authorized)
        {
         ENUM_VEGAR_REASON_CODE r=(gVegarOpportunity.last_reason==VEGAR_REASON_NONE?ORDER_REQUEST_NOT_ALLOWED:gVegarOpportunity.last_reason);
         Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,r,"GATE_EVALUATION_BLOCKED");
         return;
        }
      if(!Vegar_CreateIntentFromOpportunity()) { Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,ECONOMIC_TARGET_UNAVAILABLE,"INTENT_BUILD_FAIL"); return; }
      Vegar_SetOpportunityState(VEGAR_SETUP_ENTRY_INTENT,VEGAR_REASON_NONE,"ENTRY_INTENT");
      return;
     }
  }

void Vegar_ProcessSetupOnClosedBar()
  {
   gVegarExecutionFlow=Vegar_CalcFlow(Vegar_ExecutionTF());
   if(!gVegarExecutionFlow.valid) { gVegarLastSetupReason=DATA_NOT_READY; return; }
   MqlRates bar; if(!Vegar_GetBar(Vegar_ExecutionTF(),1,bar)) { gVegarLastSetupReason=DATA_NOT_READY; return; }

   // RC8 ordering contract: PRE-state technical detection precedes global zone lifecycle mutation.
   SVegarZoneEventSnapshot snap; bool hasSnapshot=Vegar_PrepareZoneEventSnapshot(bar,snap);
   if(!gVegarOpportunity.active && hasSnapshot && snap.approach_observed)
     {
      if(snap.sweep_observed) Vegar_StartOpportunityFromSnapshot(snap);
      else Vegar_CaptureClosedBarApproachCandidate(snap);
     }

   // RC8 micro-liquidity is isolated by role but can become operational MICRO_CONTINUATION when aligned to M15.
   Vegar_RC8ObserveClosedBar(bar);

   // Only now mutate global lifecycle. The consuming Opportunity is insulated by its immutable source copy.
   Vegar_UpdateZoneStates(bar);
   if(hasSnapshot)
     {
      Vegar_UpdateZoneEventPostState(snap);
      if(gVegarOpportunity.active && gVegarOpportunity.source_zone_id==snap.zone_id)
         gVegarOpportunity.source_zone_post_state=snap.post_state;
      if(snap.sweep_observed)
         Vegar_RC8WriteApproachEvent("APPROACH_SWEEP_SAME_BAR",(gVegarOpportunity.active?gVegarOpportunity.candidate_id:""),snap,"PreState="+Vegar_ZoneStateText(snap.pre_state)+"|PostState="+Vegar_ZoneStateText(snap.post_state));
     }

   if(gVegarOpportunity.active) Vegar_ProcessActiveOpportunity(bar);
  }

#endif
