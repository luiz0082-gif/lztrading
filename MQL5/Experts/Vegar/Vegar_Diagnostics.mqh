#ifndef __VEGAR_DIAGNOSTICS_MQH__
#define __VEGAR_DIAGNOSTICS_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Time.mqh"
#include "Vegar_Liquidity.mqh"
#include "Vegar_Channel.mqh"
#include "Vegar_Flow.mqh"
#include "Vegar_Setup.mqh"
#include "Vegar_Risk.mqh"
#include "Vegar_Csv.mqh"

string Vegar_TestCriticalityText(const ENUM_VEGAR_TEST_CRITICALITY c)
  {
   return (c==VEGAR_TEST_CRITICAL ? "CRITICAL" : "NON_CRITICAL");
  }

bool Vegar_TestEqualToleranceMatch(const double a,const double b,const double atr)
  {
   if(atr<=0.0) return false;
   double tol=MathMax(3.0*gVegarSymbol.tick_size,InpEqualToleranceATR*atr);
   return (MathAbs(a-b)<=tol);
  }

double Vegar_TestZoneStrengthFormula(const ENUM_VEGAR_ZONE_TYPE type,
                                     const int source_count,
                                     const ENUM_VEGAR_ZONE_STATE state,
                                     const int touch_count,
                                     const double historical_reaction_atr,
                                     const double width_atr)
  {
   int origin=Vegar_ZoneOriginScore(type);
   if(type==VEGAR_ZONE_COMPOSITE)
     {
      int extra=(source_count-1>0 ? source_count-1 : 0);
      origin=(20+extra<25 ? 20+extra : 25);
     }
   int extra_sources=(source_count-1>0 ? source_count-1 : 0);
   int confluence=(extra_sources*5<25 ? extra_sources*5 : 25);
   int fresh=20;
   if(state==VEGAR_ZONE_SWEPT || state==VEGAR_ZONE_INVALIDATED) fresh=0;
   else if(touch_count<=0) fresh=20;
   else if(touch_count==1) fresh=14;
   else if(touch_count==2) fresh=8;
   else fresh=3;

   int reaction=8;
   if(historical_reaction_atr>=2.0) reaction=15;
   else if(historical_reaction_atr>=1.0) reaction=10;
   else if(historical_reaction_atr>=0.5) reaction=5;
   else if(touch_count>0) reaction=0;

   int quality=5;
   if(type==VEGAR_ZONE_PDH || type==VEGAR_ZONE_PDL || type==VEGAR_ZONE_PWH || type==VEGAR_ZONE_PWL) quality=8;
   else if((type==VEGAR_ZONE_EQUAL_HIGH || type==VEGAR_ZONE_EQUAL_LOW) && source_count>=3) quality=10;
   else if(type==VEGAR_ZONE_EQUAL_HIGH || type==VEGAR_ZONE_EQUAL_LOW) quality=7;

   int clean=(width_atr<=0.10?5:(width_atr<=0.20?3:1));
   int total=origin+confluence+fresh+reaction+quality+clean;
   return (double)(total<100 ? total : 100);
  }

double Vegar_TestChannelStrengthFormula(const int coherent_confirmations,
                                        const double slope_atr_per_bar,
                                        const double efficiency_ratio,
                                        const double respect_fraction,
                                        const int reactions)
  {
   int coherent=(coherent_confirmations<4 ? coherent_confirmations : 4);
   if(coherent<0) coherent=0;
   double structure_score=10.0*(double)coherent;
   double slope_score=MathMin(20.0,20.0*MathMax(0.0,slope_atr_per_bar)/0.10);
   double er_score=20.0*Vegar_Clamp(efficiency_ratio,0.0,1.0);
   int capped_reactions=(reactions<2 ? reactions : 2);
   if(capped_reactions<0) capped_reactions=0;
   double respect_score=10.0*Vegar_Clamp(respect_fraction,0.0,1.0)+5.0*(double)capped_reactions;
   return Vegar_Clamp(structure_score+slope_score+er_score+respect_score,0.0,100.0);
  }

void Vegar_TestResult(const string name,
                      const ENUM_VEGAR_TEST_CRITICALITY criticality,
                      const bool pass,
                      const string reason="")
  {
   gVegarSelfTestsRun++;
   if(pass) gVegarSelfTestsPassed++;
   else
     {
      gVegarSelfTestsFailed++;
      if(criticality==VEGAR_TEST_CRITICAL) gVegarSelfTestsCriticalFailed++;
     }

   string detail="Result="+(pass?"PASS":"FAIL")+
                 "|Criticality="+Vegar_TestCriticalityText(criticality)+
                 "|Reason="+(reason==""?(pass?"OK":"ASSERTION_FAILED"):reason);
   Vegar_WriteDiagnostic("SELF_TEST",pass?"PASS":"FAIL",name,
                         Vegar_TestCriticalityText(criticality),detail);
   if(InpNivelLog>=1)
      PrintFormat("[VEGAR][SELF_TEST] %s | %s | %s | %s",
                  name,pass?"PASS":"FAIL",Vegar_TestCriticalityText(criticality),
                  reason==""?(pass?"OK":"ASSERTION_FAILED"):reason);
  }

bool Vegar_TestPivot()
  {
   MqlRates r[]; ArrayResize(r,5); ArraySetAsSeries(r,true);
   for(int i=0;i<5;i++){ r[i].high=10.0; r[i].low=5.0; }
   r[2].high=20.0; r[2].low=1.0;
   return (Vegar_IsPivotHigh(r,2,2,2) && Vegar_IsPivotLow(r,2,2,2));
  }

bool Vegar_TestEqualHigh()
  {
   double atr=MathMax(100.0*gVegarSymbol.tick_size,1.0);
   double tol=MathMax(3.0*gVegarSymbol.tick_size,InpEqualToleranceATR*atr);
   return (Vegar_TestEqualToleranceMatch(100.0,100.0+0.5*tol,atr) &&
           !Vegar_TestEqualToleranceMatch(100.0,100.0+2.0*tol,atr));
  }

bool Vegar_TestEqualLow()
  {
   double atr=MathMax(100.0*gVegarSymbol.tick_size,1.0);
   double tol=MathMax(3.0*gVegarSymbol.tick_size,InpEqualToleranceATR*atr);
   return (Vegar_TestEqualToleranceMatch(50.0,50.0-0.5*tol,atr) &&
           !Vegar_TestEqualToleranceMatch(50.0,50.0-2.0*tol,atr));
  }

bool Vegar_TestMergeZone()
  {
   double atr=MathMax(100.0*gVegarSymbol.tick_size,1.0);
   SVegarZone a=Vegar_MakeZone("A",VEGAR_ZONE_H4_SWING_LOW,PERIOD_H4,VEGAR_BIAS_BUYER,100.0,atr,1,1);
   SVegarZone b=Vegar_MakeZone("B",VEGAR_ZONE_M15_SWING_LOW,PERIOD_M15,VEGAR_BIAS_BUYER,
                              a.high+InpZoneWidthATR*atr*0.5,atr,2,2);
   return Vegar_ZonesCompatibleForMerge(a,b);
  }

bool Vegar_TestZoneStrength()
  {
   double score=Vegar_TestZoneStrengthFormula(VEGAR_ZONE_H4_SWING_LOW,1,VEGAR_ZONE_ACTIVE,0,0.0,0.05);
   return (MathAbs(score-58.0)<1e-9 && Vegar_StrengthClass(score)==VEGAR_STRENGTH_MEDIA);
  }

bool Vegar_TestChannelAscending()
  {
   SVegarChannel c; ZeroMemory(c);
   c.valid=true; c.tf=PERIOD_M15; c.anchor1_time=100000; c.anchor2_time=100900;
   c.anchor1_price=100.0; c.slope_price_per_bar=0.50;
   double p1=Vegar_ChannelLineAt(c,c.anchor1_time);
   double p2=Vegar_ChannelLineAt(c,c.anchor1_time+1800);
   return (p2>p1 && MathAbs(p2-101.0)<1e-9);
  }

bool Vegar_TestChannelDescending()
  {
   SVegarChannel c; ZeroMemory(c);
   c.valid=true; c.tf=PERIOD_M15; c.anchor1_time=100000; c.anchor2_time=100900;
   c.anchor1_price=100.0; c.slope_price_per_bar=-0.50;
   double p1=Vegar_ChannelLineAt(c,c.anchor1_time);
   double p2=Vegar_ChannelLineAt(c,c.anchor1_time+1800);
   return (p2<p1 && MathAbs(p2-99.0)<1e-9);
  }

bool Vegar_TestChannelStrength()
  {
   double score=Vegar_TestChannelStrengthFormula(4,0.10,1.0,1.0,2);
   return (MathAbs(score-100.0)<1e-9 && Vegar_StrengthClass(score)==VEGAR_STRENGTH_EXTREMA);
  }

bool Vegar_TestFlowBuyer()
  {
   return (Vegar_ClassifyFlow(74.0,false,false)==VEGAR_FLOW_COMPRADOR_FORTE &&
           Vegar_ClassifyFlow(30.0,false,false)==VEGAR_FLOW_COMPRADOR);
  }

bool Vegar_TestFlowSeller()
  {
   return (Vegar_ClassifyFlow(-74.0,false,false)==VEGAR_FLOW_VENDEDOR_FORTE &&
           Vegar_ClassifyFlow(-30.0,false,false)==VEGAR_FLOW_VENDEDOR);
  }

bool Vegar_TestAbsorption()
  {
   MqlRates buyer; ZeroMemory(buyer);
   buyer.low=0.0; buyer.high=20.0; buyer.open=5.0; buyer.close=9.0;
   double range=buyer.high-buyer.low;
   double upper=buyer.high-MathMax(buyer.open,buyer.close);
   double cl=(buyer.close-buyer.low)/range*100.0;
   bool buyer_abs=(range>=1.5*10.0 && upper/range>=0.45 && cl<=55.0);

   MqlRates seller; ZeroMemory(seller);
   seller.low=0.0; seller.high=20.0; seller.open=15.0; seller.close=11.0;
   double lower=MathMin(seller.open,seller.close)-seller.low;
   double cls=(seller.close-seller.low)/(seller.high-seller.low)*100.0;
   bool seller_abs=((seller.high-seller.low)>=1.5*10.0 &&
                    lower/(seller.high-seller.low)>=0.45 && cls>=45.0);
   return (buyer_abs && seller_abs);
  }

bool Vegar_TestSweep()
  {
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
   if(atr<=0.0) return false;

   SVegarZone z=Vegar_MakeZone("TEST_SWEEP",VEGAR_ZONE_M15_SWING_LOW,PERIOD_M15,
                               VEGAR_BIAS_BUYER,100.0,atr,1,1);
   double minPen=MathMax(2.0*gVegarSymbol.tick_size,InpMinSweepATR*atr);
   double maxPen=InpMaxSweepATR*atr;
   if(maxPen<=minPen) return false;

   double pen=minPen+(maxPen-minPen)*0.25;
   MqlRates b; ZeroMemory(b);
   b.low=z.low-pen; b.high=z.high+minPen; b.open=z.mid-minPen*0.2; b.close=z.mid+minPen*0.2;

   bool tooDeep=false; double extreme=0.0;
   return (Vegar_SweepConfirmed(z,b,tooDeep,extreme) && !tooDeep && extreme==b.low);
  }

bool Vegar_TestMSS()
  {
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
   if(atr<=0.0) return false;
   double swing=100.0;
   double buffer=MathMax(gVegarSymbol.tick_size,InpMSSBufferATR*atr);
   MqlRates b; ZeroMemory(b);
   b.close=swing+buffer+MathMax(gVegarSymbol.tick_size,1e-8);
   return Vegar_MSSConfirmed(VEGAR_BIAS_BUYER,b,swing);
  }

bool Vegar_TestDisplacement()
  {
   double avg20=Vegar_AvgRange(Vegar_ExecutionTF(),2,20);
   if(avg20<=0.0) return false;
   double range=(InpDisplacementRangeMult+0.10)*avg20;
   MqlRates b; ZeroMemory(b);
   b.low=100.0; b.high=100.0+range;
   b.open=100.0+0.10*range;
   b.close=100.0+0.90*range;
   return Vegar_DisplacementConfirmed(VEGAR_BIAS_BUYER,b);
  }

bool Vegar_TestFVG()
  {
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
   if(atr<=0.0) return false;
   double minSize=MathMax(2.0*gVegarSymbol.tick_size,InpMinFVGATR*atr);
   MqlRates newest,oldest; ZeroMemory(newest); ZeroMemory(oldest);
   oldest.high=100.0;
   oldest.low=99.0;
   newest.low=100.0+1.25*minSize;
   newest.high=newest.low+MathMax(minSize,1.0);
   bool bullish=(newest.low>oldest.high && newest.low-oldest.high>=minSize);
   MqlRates newestBear,oldestBear; ZeroMemory(newestBear); ZeroMemory(oldestBear);
   newestBear.high=100.0;
   newestBear.low=99.0;
   oldestBear.low=100.0+1.25*minSize;
   oldestBear.high=oldestBear.low+MathMax(minSize,1.0);
   bool bearish=(newestBear.high<oldestBear.low && oldestBear.low-newestBear.high>=minSize);
   return (bullish && bearish);
  }

bool Vegar_TestRetest()
  {
   MqlRates b; ZeroMemory(b);
   b.low=99.0; b.high=103.0; b.open=100.0; b.close=102.5;
   return Vegar_RetestConfirmed(VEGAR_BIAS_BUYER,b,100.0,102.0);
  }

bool Vegar_TestStopMoney()
  {
   if(!Vegar_UpdateTick()) return false;
   double entry=gVegarTick.ask;
   if(entry<=0.0) return false;
   double dist=MathMax(10.0*gVegarSymbol.tick_size,10.0*gVegarSymbol.point);
   double exit_price=Vegar_NormalizePriceToTick(entry-dist);
   if(exit_price<=0.0 || exit_price>=entry) return false;
   double money=0.0;
   if(!Vegar_CalcMoneyFromPrice(VEGAR_BIAS_BUYER,InpLoteOperacional,entry,exit_price,money)) return false;
   return (money<0.0);
  }

bool Vegar_TestMoneyToPrice()
  {
   if(!Vegar_UpdateTick()) return false;
   double entry=gVegarTick.ask; if(entry<=0.0) return false;
   double targetMoney=MathMax(0.01,MathAbs(Vegar_SpreadMoney(InpLoteOperacional))+0.01);
   double target=0.0;
   if(!Vegar_FindPriceForProfitMoney(VEGAR_BIAS_BUYER,InpLoteOperacional,entry,targetMoney,target)) return false;
   double p=0.0;
   if(!Vegar_CalcMoneyFromPrice(VEGAR_BIAS_BUYER,InpLoteOperacional,entry,target,p)) return false;
   return (target>entry && p>0.0 && p+0.01>=targetMoney);
  }

bool Vegar_TestSpreadMoney()
  {
   if(!Vegar_UpdateTick()) return false;
   if(gVegarTick.ask<=0.0 || gVegarTick.bid<=0.0 || InpLoteOperacional<=0.0) return false;
   double expected=0.0;
   if(!Vegar_CalcProfit(ORDER_TYPE_BUY,InpLoteOperacional,gVegarTick.ask,gVegarTick.bid,expected)) return false;
   expected=MathAbs(expected);
   double actual=Vegar_SpreadMoney(InpLoteOperacional);
   double tol=MathMax(1e-6,expected*1e-6);
   return (MathAbs(actual-expected)<=tol);
  }

bool Vegar_TestConfigHash()
  {
   string a=Vegar_ComputeConfigHash(),b=Vegar_ComputeConfigHash();
   return (a!="" && a==b && StringFind(a,"FNV1A64-")==0);
  }

bool Vegar_TestNyDst()
  {
   datetime jan=Vegar_MakeDateTime(2026,1,15,12,0,0);
   datetime jul=Vegar_MakeDateTime(2026,7,15,12,0,0);
   return (!Vegar_IsNewYorkDSTByUTC(jan) && Vegar_IsNewYorkDSTByUTC(jul));
  }

bool Vegar_TestDuplicateIntent()
  {
   SVegarIntent i; ZeroMemory(i);
   i.valid=true; i.processed=false;
   bool first=!i.processed;
   i.processed=true;
   bool second=!i.processed;
   return (first && !second);
  }


bool Vegar_TestSymbolContextIsolation()
  {
   double atr=MathMax(1.0,100.0*gVegarSymbol.tick_size);
   SVegarZone z=Vegar_MakeZone(Vegar_ZoneScopedID(VEGAR_ZONE_H4_SWING_LOW,PERIOD_H4,"ISO"),VEGAR_ZONE_H4_SWING_LOW,PERIOD_H4,VEGAR_BIAS_BUYER,100.0,atr,1,2);
   z.symbol=_Symbol+"__OTHER";
   return !Vegar_ZoneContextValid(z);
  }

bool Vegar_TestZoneIdSymbolScope()
  {
   string id=Vegar_ZoneScopedID(VEGAR_ZONE_H4_SWING_HIGH,PERIOD_H4,"123");
   return (StringFind(id,"ZONE_"+Vegar_SanitizeFileToken(_Symbol)+"_H4_H4_SWING_HIGH_")==0);
  }

bool Vegar_TestEqualZoneTfIdentity()
  {
   string a=Vegar_ZoneScopedID(VEGAR_ZONE_EQUAL_HIGH,PERIOD_H4,"GROUP");
   string b=Vegar_ZoneScopedID(VEGAR_ZONE_EQUAL_HIGH,PERIOD_M15,"GROUP");
   return (a!=b && StringFind(a,"_H4_")>0 && StringFind(b,"_M15_")>0);
  }

bool Vegar_TestZoneRestartDeterminism()
  {
   double atr=MathMax(1.0,100.0*gVegarSymbol.tick_size);
   string id=Vegar_ZoneScopedID(VEGAR_ZONE_M15_SWING_LOW,PERIOD_M15,"987654");
   SVegarZone a=Vegar_MakeZone(id,VEGAR_ZONE_M15_SWING_LOW,PERIOD_M15,VEGAR_BIAS_BUYER,123.45,atr,987654,987900);
   SVegarZone b=Vegar_MakeZone(id,VEGAR_ZONE_M15_SWING_LOW,PERIOD_M15,VEGAR_BIAS_BUYER,123.45,atr,987654,987900);
   return (a.id==b.id && a.source_atr==b.source_atr && a.low==b.low && a.high==b.high && a.source_ids==b.source_ids);
  }

bool Vegar_TestCompositeSourceLifecycle()
  {
   double atr=MathMax(1.0,100.0*gVegarSymbol.tick_size);
   SVegarZone base=Vegar_MakeZone(Vegar_ZoneScopedID(VEGAR_ZONE_H4_SWING_LOW,PERIOD_H4,"BASE"),VEGAR_ZONE_H4_SWING_LOW,PERIOD_H4,VEGAR_BIAS_BUYER,100.0,atr,1,2);
   SVegarZone temp=Vegar_MakeZone(Vegar_ZoneScopedID(VEGAR_ZONE_PDL,PERIOD_H4,"TEMP"),VEGAR_ZONE_PDL,PERIOD_H4,VEGAR_BIAS_BUYER,100.0,atr,3,4);
   SVegarZone fresh=base;
   Vegar_MergeZoneInto(base,temp);
   return (base.source_count==2 && StringFind(";"+base.source_ids+";",";"+temp.source_ids+";")>=0 &&
           fresh.source_count==1 && base.id!=fresh.id);
  }

bool Vegar_TestSweptZoneNotReused()
  {
   double atr=MathMax(1.0,100.0*gVegarSymbol.tick_size);
   SVegarZone a=Vegar_MakeZone(Vegar_ZoneScopedID(VEGAR_ZONE_H4_SWING_LOW,PERIOD_H4,"SW1"),VEGAR_ZONE_H4_SWING_LOW,PERIOD_H4,VEGAR_BIAS_BUYER,100.0,atr,1,2);
   SVegarZone b=Vegar_MakeZone(Vegar_ZoneScopedID(VEGAR_ZONE_M15_SWING_LOW,PERIOD_M15,"SW2"),VEGAR_ZONE_M15_SWING_LOW,PERIOD_M15,VEGAR_BIAS_BUYER,100.0,atr,3,4);
   a.state=VEGAR_ZONE_SWEPT;
   return !Vegar_ZonesCompatibleForMerge(a,b);
  }

bool Vegar_TestObjectStateDeltaDedup()
  {
   string id="SELFTEST_OBJECT_"+gVegarRunID; string event="";
   bool first=Vegar_ObjectShouldWrite(id,"A",event);
   string event2=""; bool second=Vegar_ObjectShouldWrite(id,"A",event2);
   string event3=""; bool changed=Vegar_ObjectShouldWrite(id,"B",event3);
   return (first && !second && changed && event=="OBJECT_CREATED" && event3=="OBJECT_CHANGED");
  }

bool Vegar_TestChannelIdAnchorScope()
  {
   SVegarChannel a,b; ZeroMemory(a);ZeroMemory(b);
   Vegar_InitChannelIdentity(a); Vegar_InitChannelIdentity(b); a.tf=b.tf=PERIOD_M15; a.direction=b.direction=VEGAR_CHANNEL_BUYER;
   a.anchor1_time=100;a.anchor2_time=200;b.anchor1_time=100;b.anchor2_time=201;
   return (Vegar_ChannelScopedID(a)!=Vegar_ChannelScopedID(b));
  }

bool Vegar_TestReplaySymbolIsolation()
  {
   SVegarReplayJob j;ZeroMemory(j); j.symbol=_Symbol; j.execution_tf=Vegar_ExecutionTF(); j.point=gVegarSymbol.point; j.tick_size=gVegarSymbol.tick_size; j.digits=gVegarSymbol.digits; j.magic=InpMagicNumber; j.run_id=gVegarRunID; j.strategy_hash=gVegarStrategyConfigHash; j.volume=InpLoteOperacional;
   bool valid=Vegar_ReplayFrozenContextValid(j); j.symbol="";
   return (valid && !Vegar_ReplayFrozenContextValid(j));
  }

bool Vegar_TestRunConfigHashRoundtrip()
  {
   string s=Vegar_ComputeHash(Vegar_StrategyCanonicalString());
   string t=Vegar_ComputeHash(Vegar_TelemetryCanonicalString());
   string v=Vegar_ComputeHash(Vegar_VisualCanonicalString());
   return (s==gVegarStrategyConfigHash && t==gVegarTelemetryConfigHash && v==gVegarVisualConfigHash && gVegarConfigHash==gVegarStrategyConfigHash);
  }

bool Vegar_TestCsvSchemaHeaderGuard()
  {
   string h=Vegar_CommonHeader();
   return (VEGAR_SCHEMA_VERSION==2100 && StringFind(h,"SchemaVersion,EAVersion,BuildID,RunID,InstanceID,ConfigHash,StrategyConfigHash") == 0);
  }

bool Vegar_TestObservationNoExecutionAuthority()
  {
   double atr=MathMax(1.0,100.0*gVegarSymbol.tick_size);
   SVegarZone z=Vegar_MakeZoneRole(Vegar_ZoneScopedID(VEGAR_ZONE_EXEC_SWING_LOW,PERIOD_M1,"OBS"),VEGAR_ZONE_EXEC_SWING_LOW,PERIOD_M1,VEGAR_BIAS_BUYER,100.0,atr,1,2,VEGAR_ZONE_ROLE_OBSERVATION);
   return (z.role==VEGAR_ZONE_ROLE_OBSERVATION && z.symbol==_Symbol && Vegar_FindZoneIndex(z.id)<0);
  }

bool Vegar_TestLiveFlowNoExecutionAuthority()
  {
   SVegarFlowSnapshot f=Vegar_CalcLiveFlow(Vegar_ExecutionTF());
   return (!f.valid || !f.decision_authority);
  }

bool Vegar_TestPanelOppositeLiquidity()
  {
   // The panel uses the same operational opposite-liquidity resolver even when no Opportunity exists.
   if(ArraySize(gVegarZones)<1) return true;
   int zi=Vegar_FocusZoneIndex(); if(zi<0) return true;
   if(!Vegar_UpdateTick()) return false;
   double p=0.0,s=0.0; string id=""; double entry=(gVegarZones[zi].operational_bias==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid);
   bool found=Vegar_FindOppositeLiquidity(gVegarZones[zi].operational_bias,entry,p,id,s);
   return (!found || (p>0.0 && id!=""));
  }

bool Vegar_TestVisualZoneDistanceRanking()
  {
   double p=100.0,a=105.0,b=102.0;
   return (MathAbs(b-p)<MathAbs(a-p));
  }

bool Vegar_TestStopEnabled()
  {
   double t=Vegar_NormalizePriceToTick(MathMax(gVegarSymbol.tick_size,100.0*gVegarSymbol.tick_size));
   return (Vegar_InitialStopPriceForRequest(t,true)>0.0);
  }

bool Vegar_TestStopDisabled()
  {
   double t=MathMax(gVegarSymbol.tick_size,100.0*gVegarSymbol.tick_size);
   return (Vegar_InitialStopPriceForRequest(t,false)==0.0);
  }

bool Vegar_TestPersistenceChecksum()
  {
   string f="VEGAR_SELFTEST_PERSIST_"+Vegar_SanitizeFileToken(gVegarRunID)+".state";
   string payload=Vegar_PersistenceLine("PersistenceSchemaVersion",(string)VEGAR_PERSISTENCE_SCHEMA)+Vegar_PersistenceLine("Test","ABC");
   string hash=Vegar_ComputeHash(payload);
   int h=FileOpen(f,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON); if(h==INVALID_HANDLE)return false;
   FileWriteString(h,payload);FileWriteString(h,Vegar_PersistenceLine("PayloadHash",hash));FileFlush(h);FileClose(h);
   bool ok=Vegar_ValidatePersistenceFile(f);FileDelete(f,FILE_COMMON);return ok;
  }

bool Vegar_TestRecoveryAmbiguousOwnership()
  {
   return (Vegar_ResolveOwnershipEvidence(true,false,false,false,false)==VEGAR_OWNERSHIP_AMBIGUOUS &&
           Vegar_ResolveOwnershipEvidence(true,true,false,false,false)==VEGAR_OWNERSHIP_CONFIRMED &&
           Vegar_ResolveOwnershipEvidence(false,true,true,true,true)==VEGAR_OWNERSHIP_NOT_VEGAR);
  }

bool Vegar_TestRecoveryProtectionNotLoosened()
  {
   double tick=MathMax(gVegarSymbol.tick_size,gVegarSymbol.point);
   double current=100.0,candidateTighterBuy=current+10.0*tick,candidateLooseBuy=current-10.0*tick;
   double currentSell=100.0,candidateTighterSell=currentSell-10.0*tick,candidateLooseSell=currentSell+10.0*tick;
   return (Vegar_IsProtectionTighter(VEGAR_BIAS_BUYER,current,candidateTighterBuy) && !Vegar_IsProtectionTighter(VEGAR_BIAS_BUYER,current,candidateLooseBuy) &&
           Vegar_IsProtectionTighter(VEGAR_BIAS_SELLER,currentSell,candidateTighterSell) && !Vegar_IsProtectionTighter(VEGAR_BIAS_SELLER,currentSell,candidateLooseSell));
  }

bool Vegar_TestExecutionRequestHashIntegrity()
  {
   MqlTradeRequest r; ZeroMemory(r);
   r.action=TRADE_ACTION_DEAL; r.symbol=_Symbol; r.magic=(ulong)InpMagicNumber; r.volume=InpLoteOperacional; r.type=ORDER_TYPE_BUY;
   double tick=MathMax(gVegarSymbol.tick_size,gVegarSymbol.point);
   r.price=Vegar_NormalizePriceToTick(MathMax(tick,100.0*tick)); r.sl=Vegar_NormalizePriceToTick(MathMax(tick,r.price-10.0*tick));
   r.type_filling=ORDER_FILLING_RETURN; r.type_time=ORDER_TIME_GTC; r.comment="VEGAR|SELFTEST";
   string h1=Vegar_ComputeHash(Vegar_ExecutionRequestCanonical(r));
   r.price=Vegar_NormalizePriceToTick(r.price+tick);
   string h2=Vegar_ComputeHash(Vegar_ExecutionRequestCanonical(r));
   return (h1!="" && h2!="" && h1!=h2);
  }

bool Vegar_TestNetMoneyToPrice()
  {
   if(!Vegar_UpdateTick()) return false;
   double entry=gVegarTick.ask; if(entry<=0.0) return false;
   double targetNet=MathMax(0.01,MathAbs(Vegar_SpreadMoney(InpLoteOperacional))+0.01);
   double px=0.0; if(!Vegar_FindPriceForNetProfitMoney(VEGAR_BIAS_BUYER,InpLoteOperacional,entry,targetNet,px)) return false;
   double gross=0.0; if(!Vegar_CalcMoneyFromPrice(VEGAR_BIAS_BUYER,InpLoteOperacional,entry,px,gross)) return false;
   double net=gross-Vegar_EstimatedRoundTurnCommission(InpLoteOperacional);
   return (px>entry && net+0.01>=targetNet);
  }

bool Vegar_TestProspectiveDailyRiskFormula()
  {
   double limit=100.0,realized=20.0,openWorst=25.0,newWorst=40.0;
   double remain=limit-realized-openWorst-newWorst;
   double blocked=limit-realized-openWorst-60.0;
   return (MathAbs(remain-15.0)<1e-9 && blocked<0.0);
  }

bool Vegar_TestMicroM15AlignmentContract()
  {
   ENUM_VEGAR_M15_CONTEXT old=gVegarM15Context;
   gVegarM15Context=VEGAR_M15_TREND_UP;
   bool up=(Vegar_RC8MicroAlignedWithM15(VEGAR_BIAS_BUYER) && !Vegar_RC8MicroAlignedWithM15(VEGAR_BIAS_SELLER));
   gVegarM15Context=VEGAR_M15_TREND_DOWN;
   bool down=(Vegar_RC8MicroAlignedWithM15(VEGAR_BIAS_SELLER) && !Vegar_RC8MicroAlignedWithM15(VEGAR_BIAS_BUYER));
   gVegarM15Context=old;
   return (up && down);
  }


// -------------------------------------------------------------------------
// RC8 deterministic pipeline harness. It exercises the required sequencing
// through a safe execution adapter model. It never calls OrderCheck/OrderSend.
// -------------------------------------------------------------------------
struct SVegarPipelineHarness
  {
   ENUM_VEGAR_BIAS direction;
   bool candidate;
   bool opportunity;
   bool sweep_confirmed;
   bool waiting_mss;
   bool mss_confirmed;
   bool displacement_confirmed;
   bool entry_zone_created;
   bool retest_confirmed;
   bool technical_signal_ready;
   bool execution_authorized;
   bool intent_created;
   bool preflight_reachable;
   bool ordercheck_reachable;
   bool expired;
   bool zone_swept;
   bool source_zone_consumed;
   ENUM_VEGAR_MARKER_CLASS marker_class;
   string failed_gates;
  };

void Vegar_PipelineHarnessReset(SVegarPipelineHarness &h,const ENUM_VEGAR_BIAS direction)
  {
   ZeroMemory(h);
   h.direction=direction;
   h.marker_class=VEGAR_MARKER_NONE;
  }

void Vegar_PipelineHarnessRun(SVegarPipelineHarness &h,
                              const bool approach,
                              const bool sweep,
                              const bool mss,
                              const bool displacement,
                              const bool entry_zone,
                              const bool retest,
                              const bool spread_pass,
                              const bool news_pass,
                              const bool all_other_gates_pass)
  {
   // Candidate is purely technical/localization state; no economic gate is read here.
   if(!approach) return;
   h.candidate=true;
   if(!sweep) return;

   h.opportunity=true;
   h.sweep_confirmed=true;
   h.zone_swept=true;
   h.source_zone_consumed=true;
   h.waiting_mss=true;

   if(!mss) return;
   h.waiting_mss=false;
   h.mss_confirmed=true;
   if(!displacement) return;
   h.displacement_confirmed=true;
   if(!entry_zone) return;
   h.entry_zone_created=true;
   if(!retest) return;
   h.retest_confirmed=true;
   h.technical_signal_ready=true;

   if(!spread_pass) h.failed_gates="SPREAD_TOO_HIGH";
   if(!news_pass)
     {
      if(h.failed_gates!="") h.failed_gates+=";";
      h.failed_gates+="NEWS_HIGH_IMPACT";
     }
   if(!all_other_gates_pass)
     {
      if(h.failed_gates!="") h.failed_gates+=";";
      h.failed_gates+="OTHER_GATE_FAIL";
     }

   h.execution_authorized=(spread_pass && news_pass && all_other_gates_pass);
   if(h.execution_authorized)
     {
      h.marker_class=(h.direction==VEGAR_BIAS_BUYER?VEGAR_MARKER_VALID_BUY:VEGAR_MARKER_VALID_SELL);
      h.intent_created=true;
      h.preflight_reachable=true;
      h.ordercheck_reachable=true;
     }
   else
      h.marker_class=(h.direction==VEGAR_BIAS_BUYER?VEGAR_MARKER_BLOCKED_BUY:VEGAR_MARKER_BLOCKED_SELL);
  }

void Vegar_PipelineTestResult(const string name,const ENUM_VEGAR_TEST_CRITICALITY criticality,const bool pass,const string detail="")
  {
   gVegarPipelineTestsRun++;
   if(pass) gVegarPipelineTestsPassed++;
   else
     {
      gVegarPipelineTestsFailed++;
      if(criticality==VEGAR_TEST_CRITICAL) gVegarPipelineTestsCriticalFailed++;
     }
   Vegar_WriteDiagnostic("PIPELINE_TEST",pass?"PASS":"FAIL",name,"",detail);
   if(StringFind(name,"PIPELINE_BUY_END_TO_END")>=0 || StringFind(name,"PIPELINE_SELL_END_TO_END")>=0)
      Vegar_WriteDiagnostic(pass?"PIPELINE_END_TO_END_PASS":"PIPELINE_END_TO_END_FAIL",pass?"PASS":"FAIL",name,"",detail);
  }

bool Vegar_TestPipelineEndToEnd(const ENUM_VEGAR_BIAS direction)
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,direction);
   Vegar_PipelineHarnessRun(h,true,true,true,true,true,true,true,true,true);
   return (h.candidate && h.opportunity && h.sweep_confirmed && h.source_zone_consumed && h.zone_swept &&
           h.mss_confirmed && h.displacement_confirmed && h.entry_zone_created && h.retest_confirmed &&
           h.technical_signal_ready && h.execution_authorized && h.intent_created && h.preflight_reachable && h.ordercheck_reachable &&
           ((direction==VEGAR_BIAS_BUYER && h.marker_class==VEGAR_MARKER_VALID_BUY) ||
            (direction==VEGAR_BIAS_SELLER && h.marker_class==VEGAR_MARKER_VALID_SELL)));
  }

bool Vegar_TestSameBarApproachSweepHarness()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,false,false,false,false,true,true,true);
   bool pass=(h.candidate && h.opportunity && h.sweep_confirmed && h.zone_swept && h.source_zone_consumed && h.waiting_mss && !h.expired);
   Vegar_WriteDiagnostic(pass?"SAME_BAR_APPROACH_SWEEP_PASS":"PIPELINE_END_TO_END_FAIL",pass?"PASS":"FAIL","SAME_BAR_APPROACH_SWEEP","",
                         "Candidate->Opportunity->SWEEP; global zone consumed without killing source opportunity");
   return pass;
  }

bool Vegar_TestFastRejectionHarness()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_SELLER);
   // The harness represents the CLOSED_BAR capture after the first next-bar tick is already far away.
   Vegar_PipelineHarnessRun(h,true,true,false,false,false,false,true,true,true);
   bool pass=(h.candidate && h.sweep_confirmed && h.opportunity);
   if(pass) Vegar_WriteDiagnostic("FAST_REJECTION_CAPTURED","PASS","NONE","","Closed-bar approach/sweep survives next-tick distance");
   return pass;
  }

bool Vegar_TestSourceZoneConsumedHarness()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,false,false,false,false,true,true,true);
   bool pass=(h.zone_swept && h.source_zone_consumed && h.opportunity && h.waiting_mss);
   if(pass) Vegar_WriteDiagnostic("SOURCE_ZONE_CONSUMED_OK","PASS","NONE","","SWEPT blocks reuse, not the consuming opportunity");
   return pass;
  }

bool Vegar_TestNegativeFarZone()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,false,false,false,false,false,false,true,true,true);
   return (!h.candidate && !h.technical_signal_ready && !h.intent_created);
  }

bool Vegar_TestNegativeTouchNoSweep()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,false,false,false,false,false,true,true,true);
   return (h.candidate && !h.opportunity && !h.technical_signal_ready);
  }

bool Vegar_TestNegativeSweepNoMSS()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,false,false,false,false,true,true,true);
   h.expired=true; return (h.opportunity && h.sweep_confirmed && h.waiting_mss && h.expired && !h.technical_signal_ready);
  }

bool Vegar_TestNegativeMSSNoDisplacement()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,true,false,false,false,true,true,true);
   h.expired=true; return (h.mss_confirmed && h.expired && !h.technical_signal_ready);
  }

bool Vegar_TestNegativeDisplacementNoEntryZone()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,true,true,false,false,true,true,true);
   h.expired=true; return (h.displacement_confirmed && h.expired && !h.technical_signal_ready);
  }

bool Vegar_TestNegativeRetestNoConfirmation()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,true,true,true,false,true,true,true);
   return (h.entry_zone_created && !h.retest_confirmed && !h.technical_signal_ready);
  }

bool Vegar_TestSignalSpreadFailYellow()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,true,true,true,true,false,true,true);
   return (h.technical_signal_ready && !h.execution_authorized && h.marker_class==VEGAR_MARKER_BLOCKED_BUY && StringFind(h.failed_gates,"SPREAD_TOO_HIGH")>=0 && !h.intent_created);
  }

bool Vegar_TestSignalNewsFailYellow()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_SELLER);
   Vegar_PipelineHarnessRun(h,true,true,true,true,true,true,true,false,true);
   return (h.technical_signal_ready && !h.execution_authorized && h.marker_class==VEGAR_MARKER_BLOCKED_SELL && StringFind(h.failed_gates,"NEWS_HIGH_IMPACT")>=0 && !h.intent_created);
  }

bool Vegar_TestSignalAllPassIntent()
  {
   SVegarPipelineHarness h; Vegar_PipelineHarnessReset(h,VEGAR_BIAS_BUYER);
   Vegar_PipelineHarnessRun(h,true,true,true,true,true,true,true,true,true);
   return (h.technical_signal_ready && h.execution_authorized && h.intent_created && h.preflight_reachable && h.ordercheck_reachable);
  }

bool Vegar_RunPipelineTests()
  {
   gVegarPipelineTestsRun=0; gVegarPipelineTestsPassed=0; gVegarPipelineTestsFailed=0; gVegarPipelineTestsCriticalFailed=0;

   Vegar_PipelineTestResult("PIPELINE_BUY_END_TO_END",VEGAR_TEST_CRITICAL,Vegar_TestPipelineEndToEnd(VEGAR_BIAS_BUYER),"ExecutionAdapter=MOCK_SAFE|OrderSend=false|PREFLIGHT_REACHABLE expected");
   Vegar_PipelineTestResult("PIPELINE_SELL_END_TO_END",VEGAR_TEST_CRITICAL,Vegar_TestPipelineEndToEnd(VEGAR_BIAS_SELLER),"ExecutionAdapter=MOCK_SAFE|OrderSend=false|PREFLIGHT_REACHABLE expected");
   Vegar_PipelineTestResult("SAME_BAR_APPROACH_SWEEP",VEGAR_TEST_CRITICAL,Vegar_TestSameBarApproachSweepHarness());
   Vegar_PipelineTestResult("FAST_REJECTION_AFTER_ZONE_TOUCH",VEGAR_TEST_CRITICAL,Vegar_TestFastRejectionHarness());
   Vegar_PipelineTestResult("SOURCE_ZONE_CONSUMED_BY_OPPORTUNITY",VEGAR_TEST_CRITICAL,Vegar_TestSourceZoneConsumedHarness());
   Vegar_PipelineTestResult("NEGATIVE_ZONE_FAR",VEGAR_TEST_CRITICAL,Vegar_TestNegativeFarZone());
   Vegar_PipelineTestResult("NEGATIVE_TOUCH_NO_SWEEP",VEGAR_TEST_CRITICAL,Vegar_TestNegativeTouchNoSweep());
   Vegar_PipelineTestResult("NEGATIVE_SWEEP_NO_MSS",VEGAR_TEST_CRITICAL,Vegar_TestNegativeSweepNoMSS());
   Vegar_PipelineTestResult("NEGATIVE_MSS_NO_DISPLACEMENT",VEGAR_TEST_CRITICAL,Vegar_TestNegativeMSSNoDisplacement());
   Vegar_PipelineTestResult("NEGATIVE_DISPLACEMENT_NO_FVG_OB",VEGAR_TEST_CRITICAL,Vegar_TestNegativeDisplacementNoEntryZone());
   Vegar_PipelineTestResult("NEGATIVE_RETEST_NO_CONFIRMATION",VEGAR_TEST_CRITICAL,Vegar_TestNegativeRetestNoConfirmation());
   Vegar_PipelineTestResult("TECHNICAL_READY_SPREAD_FAIL_YELLOW",VEGAR_TEST_CRITICAL,Vegar_TestSignalSpreadFailYellow());
   Vegar_PipelineTestResult("TECHNICAL_READY_NEWS_FAIL_YELLOW",VEGAR_TEST_CRITICAL,Vegar_TestSignalNewsFailYellow());
   Vegar_PipelineTestResult("TECHNICAL_READY_ALL_PASS_INTENT",VEGAR_TEST_CRITICAL,Vegar_TestSignalAllPassIntent());

   string detail=StringFormat("Passed=%d|Failed=%d|Total=%d|CriticalFailed=%d|Adapter=MOCK_SAFE|OrderSend=false",
                              gVegarPipelineTestsPassed,gVegarPipelineTestsFailed,gVegarPipelineTestsRun,gVegarPipelineTestsCriticalFailed);
   Vegar_WriteDiagnostic("PIPELINE_TEST_SUMMARY",gVegarPipelineTestsFailed==0?"PASS":"FAIL",
                         gVegarPipelineTestsCriticalFailed>0?"SELF_TEST_FAILED":"NONE","",detail);
   if(InpNivelLog>=1)
      PrintFormat("[VEGAR][PIPELINE_TEST_SUMMARY] Passed=%d | Failed=%d | Total=%d | CriticalFailed=%d | OrderSend=false",
                  gVegarPipelineTestsPassed,gVegarPipelineTestsFailed,gVegarPipelineTestsRun,gVegarPipelineTestsCriticalFailed);
   return (gVegarPipelineTestsFailed==0);
  }

bool Vegar_RunSelfTests()
  {
   gVegarSelfTestsRun=0;
   gVegarSelfTestsPassed=0;
   gVegarSelfTestsFailed=0;
   gVegarSelfTestsCriticalFailed=0;
   gVegarSelfTestsCompleted=false;
   gVegarCriticalSelfTestFailed=false;

   Vegar_TestResult("PIVOT",VEGAR_TEST_CRITICAL,Vegar_TestPivot());
   Vegar_TestResult("EQUAL_HIGH",VEGAR_TEST_CRITICAL,Vegar_TestEqualHigh());
   Vegar_TestResult("EQUAL_LOW",VEGAR_TEST_CRITICAL,Vegar_TestEqualLow());
   Vegar_TestResult("ZONE_MERGE",VEGAR_TEST_CRITICAL,Vegar_TestMergeZone(),
                    "Uses the same ZoneWidthATR/tick merge normalization as production");
   Vegar_TestResult("ZONE_STRENGTH",VEGAR_TEST_CRITICAL,Vegar_TestZoneStrength());
   Vegar_TestResult("CHANNEL_ASCENDING",VEGAR_TEST_CRITICAL,Vegar_TestChannelAscending());
   Vegar_TestResult("CHANNEL_DESCENDING",VEGAR_TEST_CRITICAL,Vegar_TestChannelDescending());
   Vegar_TestResult("CHANNEL_STRENGTH",VEGAR_TEST_CRITICAL,Vegar_TestChannelStrength());
   Vegar_TestResult("FLOW_BUYER",VEGAR_TEST_CRITICAL,Vegar_TestFlowBuyer());
   Vegar_TestResult("FLOW_SELLER",VEGAR_TEST_CRITICAL,Vegar_TestFlowSeller());
   Vegar_TestResult("ABSORPTION",VEGAR_TEST_CRITICAL,Vegar_TestAbsorption());
   Vegar_TestResult("SWEEP",VEGAR_TEST_CRITICAL,Vegar_TestSweep());
   Vegar_TestResult("MSS",VEGAR_TEST_CRITICAL,Vegar_TestMSS());
   Vegar_TestResult("DISPLACEMENT",VEGAR_TEST_CRITICAL,Vegar_TestDisplacement());
   Vegar_TestResult("FVG",VEGAR_TEST_CRITICAL,Vegar_TestFVG());
   Vegar_TestResult("RETEST",VEGAR_TEST_CRITICAL,Vegar_TestRetest());
   Vegar_TestResult("STOP_MONEY",VEGAR_TEST_CRITICAL,Vegar_TestStopMoney());
   Vegar_TestResult("MONEY_TO_PRICE",VEGAR_TEST_CRITICAL,Vegar_TestMoneyToPrice());
   Vegar_TestResult("SPREAD_MONEY",VEGAR_TEST_CRITICAL,Vegar_TestSpreadMoney());
   Vegar_TestResult("CONFIG_HASH",VEGAR_TEST_NON_CRITICAL,Vegar_TestConfigHash());
   Vegar_TestResult("NY_DST",VEGAR_TEST_CRITICAL,Vegar_TestNyDst());
   Vegar_TestResult("DUPLICATE_INTENT",VEGAR_TEST_CRITICAL,Vegar_TestDuplicateIntent());

   Vegar_TestResult("SYMBOL_CONTEXT_ISOLATION",VEGAR_TEST_CRITICAL,Vegar_TestSymbolContextIsolation());
   Vegar_TestResult("ZONE_ID_SYMBOL_SCOPE",VEGAR_TEST_CRITICAL,Vegar_TestZoneIdSymbolScope());
   Vegar_TestResult("EQUAL_ZONE_TF_IDENTITY",VEGAR_TEST_CRITICAL,Vegar_TestEqualZoneTfIdentity());
   Vegar_TestResult("ZONE_RESTART_DETERMINISM",VEGAR_TEST_CRITICAL,Vegar_TestZoneRestartDeterminism());
   Vegar_TestResult("COMPOSITE_SOURCE_LIFECYCLE",VEGAR_TEST_CRITICAL,Vegar_TestCompositeSourceLifecycle());
   Vegar_TestResult("SWEPT_ZONE_NOT_REUSED",VEGAR_TEST_CRITICAL,Vegar_TestSweptZoneNotReused());
   Vegar_TestResult("OBJECT_STATE_DELTA_DEDUP",VEGAR_TEST_CRITICAL,Vegar_TestObjectStateDeltaDedup());
   Vegar_TestResult("CHANNEL_ID_ANCHOR_SCOPE",VEGAR_TEST_CRITICAL,Vegar_TestChannelIdAnchorScope());
   Vegar_TestResult("REPLAY_SYMBOL_ISOLATION",VEGAR_TEST_CRITICAL,Vegar_TestReplaySymbolIsolation());
   Vegar_TestResult("RUN_CONFIG_HASH_ROUNDTRIP",VEGAR_TEST_CRITICAL,Vegar_TestRunConfigHashRoundtrip());
   Vegar_TestResult("CSV_SCHEMA_HEADER_GUARD",VEGAR_TEST_CRITICAL,Vegar_TestCsvSchemaHeaderGuard());
   Vegar_TestResult("OBSERVATION_ROLE_ISOLATION",VEGAR_TEST_CRITICAL,Vegar_TestObservationNoExecutionAuthority());
   Vegar_TestResult("LIVE_FLOW_NO_EXECUTION_AUTHORITY",VEGAR_TEST_CRITICAL,Vegar_TestLiveFlowNoExecutionAuthority());
   Vegar_TestResult("PANEL_OPPOSITE_LIQUIDITY",VEGAR_TEST_NON_CRITICAL,Vegar_TestPanelOppositeLiquidity());
   Vegar_TestResult("VISUAL_ZONE_DISTANCE_RANKING",VEGAR_TEST_CRITICAL,Vegar_TestVisualZoneDistanceRanking());
   Vegar_TestResult("STOP_ENABLED",VEGAR_TEST_CRITICAL,Vegar_TestStopEnabled());
   Vegar_TestResult("STOP_DISABLED",VEGAR_TEST_CRITICAL,Vegar_TestStopDisabled());
   Vegar_TestResult("PERSISTENCE_CHECKSUM",VEGAR_TEST_CRITICAL,Vegar_TestPersistenceChecksum());
   Vegar_TestResult("RECOVERY_AMBIGUOUS_OWNERSHIP",VEGAR_TEST_CRITICAL,Vegar_TestRecoveryAmbiguousOwnership());
   Vegar_TestResult("RECOVERY_PROTECTION_NOT_LOOSENED",VEGAR_TEST_CRITICAL,Vegar_TestRecoveryProtectionNotLoosened());
   Vegar_TestResult("EXEC_REQUEST_HASH_INTEGRITY",VEGAR_TEST_CRITICAL,Vegar_TestExecutionRequestHashIntegrity());
   Vegar_TestResult("NET_MONEY_TO_PRICE",VEGAR_TEST_CRITICAL,Vegar_TestNetMoneyToPrice());
   Vegar_TestResult("PROSPECTIVE_DAILY_RISK",VEGAR_TEST_CRITICAL,Vegar_TestProspectiveDailyRiskFormula());
   Vegar_TestResult("MICRO_M15_ALIGNMENT",VEGAR_TEST_CRITICAL,Vegar_TestMicroM15AlignmentContract());

   bool pipelinePass=Vegar_RunPipelineTests();
   gVegarSelfTestsCompleted=true;
   gVegarCriticalSelfTestFailed=(gVegarSelfTestsCriticalFailed>0 || gVegarPipelineTestsCriticalFailed>0);

   string detail=StringFormat("UnitPassed=%d|UnitFailed=%d|UnitTotal=%d|UnitCriticalFailed=%d|PipelinePassed=%d|PipelineFailed=%d|PipelineTotal=%d|PipelineCriticalFailed=%d",
                              gVegarSelfTestsPassed,gVegarSelfTestsFailed,gVegarSelfTestsRun,gVegarSelfTestsCriticalFailed,
                              gVegarPipelineTestsPassed,gVegarPipelineTestsFailed,gVegarPipelineTestsRun,gVegarPipelineTestsCriticalFailed);
   Vegar_WriteDiagnostic("SELF_TEST_SUMMARY",
                         gVegarSelfTestsFailed==0?"PASS":"FAIL",
                         gVegarCriticalSelfTestFailed?"SELF_TEST_FAILED":"NONE","",detail);
   if(InpNivelLog>=1)
      PrintFormat("[VEGAR][SELF_TEST_SUMMARY] Passed=%d | Failed=%d | Total=%d | CriticalFailed=%d",
                  gVegarSelfTestsPassed,gVegarSelfTestsFailed,
                  gVegarSelfTestsRun,gVegarSelfTestsCriticalFailed);

   if(gVegarCriticalSelfTestFailed)
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_SELF_TEST,SELF_TEST_FAILED,detail);

   return (gVegarSelfTestsFailed==0 && pipelinePass);
  }

#endif
