#ifndef __VEGAR_RC8_MQH__
#define __VEGAR_RC8_MQH__

// RC8 corrective/observability layer. This module must not recalibrate strategy math.

SVegarObservationCandidate gVegarObservationCandidate;
SVegarSignalMarker gVegarSignalMarkers[];
SVegarFlowSnapshot gVegarLiveFlow;

datetime gVegarLastMomentWrite=0;
long gVegarLastMomentTickMsc=0;
double gVegarLastMomentMid=0.0;
string gVegarLastMomentSignature="";
string gVegarLastGateSummary="NOT_EVALUATED";


string Vegar_RC8ContextJournalFileName()
  {
   return "VEGAR_CONTEXT_"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"_"+
          Vegar_SanitizeFileToken(AccountInfoString(ACCOUNT_SERVER))+"_CHART_"+(string)ChartID()+".ctx";
  }

bool Vegar_RC8ReadContextJournal(string &old_symbol,ENUM_TIMEFRAMES &old_tf,long &old_magic)
  {
   old_symbol=""; old_tf=PERIOD_CURRENT; old_magic=0;
   string f=Vegar_RC8ContextJournalFileName();
   if(!FileIsExist(f,FILE_COMMON)) return false;
   int h=FileOpen(f,FILE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON|FILE_SHARE_READ,',');
   if(h==INVALID_HANDLE) return false;
   string account=FileReadString(h);
   string server=FileReadString(h);
   old_symbol=FileReadString(h);
   string tf=FileReadString(h);
   string magic=FileReadString(h);
   FileClose(h);
   if((long)StringToInteger(account)!=AccountInfoInteger(ACCOUNT_LOGIN)) return false;
   if(server!=AccountInfoString(ACCOUNT_SERVER) || old_symbol=="") return false;
   old_tf=(ENUM_TIMEFRAMES)(int)StringToInteger(tf);
   old_magic=(long)StringToInteger(magic);
   return true;
  }

bool Vegar_RC8WriteContextJournal()
  {
   string f=Vegar_RC8ContextJournalFileName();
   int h=FileOpen(f,FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON|FILE_SHARE_READ,',');
   if(h==INVALID_HANDLE) return false;
   FileWrite(h,(string)AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER),_Symbol,
             (string)(int)Vegar_ExecutionTF(),(string)InpMagicNumber,(string)(long)TimeTradeServer());
   FileFlush(h); FileClose(h); return true;
  }

void Vegar_RC8LogContextChangeStarted()
  {
   string old_symbol=""; ENUM_TIMEFRAMES old_tf=PERIOD_CURRENT; long old_magic=0;
   if(!Vegar_RC8ReadContextJournal(old_symbol,old_tf,old_magic)) return;
   ENUM_TIMEFRAMES new_tf=Vegar_ExecutionTF();
   if(old_symbol==_Symbol && old_tf==new_tf && old_magic==InpMagicNumber) return;
   Vegar_WriteDiagnostic("CONTEXT_CHANGE_STARTED","RESETTING","NONE","",
                         "OldSymbol="+old_symbol+
                         "|NewSymbol="+_Symbol+
                         "|OldExecutionTF="+Vegar_TFText(old_tf)+
                         "|NewExecutionTF="+Vegar_TFText(new_tf)+
                         "|OldMagic="+(string)old_magic+
                         "|NewMagic="+(string)InpMagicNumber);
  }

void Vegar_RC8ResetObservationCandidate()
  {
   ZeroMemory(gVegarObservationCandidate);
   gVegarObservationCandidate.state=VEGAR_SETUP_IDLE;
  }

void Vegar_RC8ResetMarkers()
  {
   ArrayResize(gVegarSignalMarkers,0);
  }

void Vegar_RC8WriteApproachEvent(const string event_name,const string candidate_id,const SVegarZoneEventSnapshot &snap,const string detail)
  {
   Vegar_WriteApproachDecision(event_name,candidate_id,snap,detail);
   Vegar_WriteDiagnostic(event_name,"OBSERVED","NONE",candidate_id,
                         "ZoneID="+snap.zone_id+"|PreZoneState="+Vegar_ZoneStateText(snap.pre_state)+
                         "|PostZoneState="+Vegar_ZoneStateText(snap.post_state)+
                         "|DistanceATR="+DoubleToString(snap.distance_atr,6)+"|"+detail);
  }

void Vegar_ResetMarketContext()
  {
   ArrayResize(gVegarZones,0);
   ArrayResize(gVegarObservationZones,0);
   gVegarFocusZoneID="";
   ZeroMemory(gVegarChannelH4);
   ZeroMemory(gVegarChannelM15);
   ZeroMemory(gVegarSupersededChannelH4);
   ZeroMemory(gVegarSupersededChannelM15);
   gVegarHasSupersededChannelH4=false;
   gVegarHasSupersededChannelM15=false;
   Vegar_ResetOpportunity();
   Vegar_ResetApproachLatch();
   Vegar_RC8ResetObservationCandidate();
   ArrayResize(gVegarReplayJobs,0);
   gVegarM15Context=VEGAR_M15_UNKNOWN;
   gVegarM15RangeConsecutive=0;
   gVegarLastBarH4=0;
   gVegarLastBarM15=0;
   gVegarLastBarM5=0;
   gVegarLastBarM1=0;
   Vegar_ResetObjectStateCache();
   Vegar_RC8ResetMarkers();
   ZeroMemory(gVegarLiveFlow);
   gVegarLastMomentWrite=0;
   gVegarLastMomentTickMsc=0;
   gVegarLastMomentMid=0.0;
   gVegarLastMomentSignature="";
   Vegar_WriteDiagnostic("MARKET_CONTEXT_RESET","COMPLETE","NONE","",
                         "Symbol="+_Symbol+"|TF="+Vegar_TFText(Vegar_ExecutionTF())+"|RunID="+gVegarRunID);
  }

bool Vegar_RC8KnownObjectPrefix(const string name)
  {
   return (StringFind(name,"VEGAR_PANEL_")==0 ||
           StringFind(name,"VEGAR_VIS_")==0 ||
           StringFind(name,"VEGAR_UI_")==0 ||
           StringFind(name,"VEGAR_ZONE_")==0 ||
           StringFind(name,"VEGAR_CHANNEL_")==0 ||
           StringFind(name,"VEGAR_MARKER_")==0);
  }

void Vegar_RC8StartupCleanup()
  {
   int deleted=0;
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      string n=ObjectName(0,i,0,-1);
      if(!Vegar_RC8KnownObjectPrefix(n)) continue;
      if(ObjectDelete(0,n)) deleted++;
     }
   Vegar_WriteDiagnostic("STARTUP_VISUAL_CLEANUP","COMPLETE","NONE","",
                         "DeletedKnownVEGARObjects="+(string)deleted+"|ThirdPartyObjectsPreserved=1");
  }

void Vegar_RC8DrawRecoveredPositionVisual()
  {
   ulong ticket=0; long pid=0; ENUM_VEGAR_BIAS d=VEGAR_BIAS_NONE; double entry=0.0,vol=0.0;
   if(!Vegar_FindOwnedPosition(ticket,pid,d,entry,vol)) return;
   string n="VEGAR_VIS_RECOVERED_POSITION";
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_HLINE,0,0,entry);
   ObjectSetDouble(0,n,OBJPROP_PRICE,entry);
   ObjectSetInteger(0,n,OBJPROP_COLOR,(d==VEGAR_BIAS_BUYER?clrAqua:clrOrangeRed));
   ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_DASHDOT);
   ObjectSetString(0,n,OBJPROP_TEXT,"VEGAR RECOVERED | "+Vegar_BiasText(d)+" | "+DoubleToString(vol,2));
   Vegar_SetMarketObjectLayer(n);
   Vegar_DrawRunnerLevel();
  }

int Vegar_RC8NearestZoneInArray(SVegarZone &zones[],double &distance_atr)
  {
   distance_atr=DBL_MAX;
   if(!Vegar_UpdateTick()) return -1;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) return -1;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5;
   int best=-1;
   for(int i=0;i<ArraySize(zones);i++)
     {
      if(!zones[i].valid || zones[i].symbol!=_Symbol) continue;
      if(zones[i].state==VEGAR_ZONE_INVALIDATED || zones[i].state==VEGAR_ZONE_EXPIRED || zones[i].state==VEGAR_ZONE_SWEPT) continue;
      double d=0.0; if(p<zones[i].low)d=zones[i].low-p; else if(p>zones[i].high)d=p-zones[i].high;
      double da=d/atr;
      if(da<distance_atr){distance_atr=da;best=i;}
     }
   return best;
  }

bool Vegar_RC8MomentRelevant(double &op_dist,string &op_id,double &obs_dist,string &obs_id)
  {
   int oi=Vegar_RC8NearestZoneInArray(gVegarZones,op_dist); op_id=(oi>=0?gVegarZones[oi].id:"");
   int mi=Vegar_RC8NearestZoneInArray(gVegarObservationZones,obs_dist); obs_id=(mi>=0?gVegarObservationZones[mi].id:"");
   if(oi>=0 && op_dist<=2.0) return true;
   if(gVegarOpportunity.active || gVegarObservationCandidate.active) return true;
   return false;
  }

void Vegar_RC8UpdateMomentState()
  {
   if(!gVegarOperational || !Vegar_UpdateTick()) return;
   double opDist=DBL_MAX,obsDist=DBL_MAX; string opId="",obsId="";
   bool relevant=Vegar_RC8MomentRelevant(opDist,opId,obsDist,obsId);
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent();
   gVegarLiveFlow=Vegar_CalcLiveFlow(Vegar_ExecutionTF());
   double mid=(gVegarTick.bid+gVegarTick.ask)*0.5;
   double velPts=0.0,velAtrMin=0.0;
   if(gVegarLastMomentTickMsc>0 && gVegarTick.time_msc>gVegarLastMomentTickMsc)
     {
      double dt=(double)(gVegarTick.time_msc-gVegarLastMomentTickMsc)/1000.0;
      if(dt>0.0 && gVegarSymbol.point>0.0) velPts=(mid-gVegarLastMomentMid)/gVegarSymbol.point/dt;
      double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
      if(dt>0.0 && atr>0.0) velAtrMin=(mid-gVegarLastMomentMid)/atr*60.0/dt;
     }
   string sig=opId+"|"+obsId+"|"+Vegar_FlowClassText(gVegarLiveFlow.flow_class)+"|"+Vegar_SetupStateText(gVegarOpportunity.state)+"|"+Vegar_SetupStateText(gVegarObservationCandidate.state);
   bool changed=(sig!=gVegarLastMomentSignature);
   if(!relevant && !changed) return;
   if(!InpAtivarIntrabarTrace && gVegarLastMomentWrite>0 && now-gVegarLastMomentWrite<1 && !changed) return;
   SVegarChannel c=(gVegarChannelM15.valid?gVegarChannelM15:Vegar_BuildChannel(PERIOD_M15));
   Vegar_WriteMomentState(velPts,velAtrMin,opId,(opDist==DBL_MAX?-1.0:opDist),obsId,(obsDist==DBL_MAX?-1.0:obsDist),gVegarExecutionFlow,gVegarLiveFlow,c);
   gVegarLastMomentWrite=now;
   gVegarLastMomentTickMsc=gVegarTick.time_msc;
   gVegarLastMomentMid=mid;
   gVegarLastMomentSignature=sig;
  }

void Vegar_RC8AppendFailure(string &list,int &count,const string gate)
  {
   if(list!="") list+=";";
   list+=gate; count++;
  }

void Vegar_RC8LogGate(SVegarOpportunity &opp,const string gate,const ENUM_VEGAR_GATE_STATE state,const ENUM_VEGAR_REASON_CODE reason)
  {
   bool pass=(state==VEGAR_GATE_PASS || state==VEGAR_GATE_NOT_APPLICABLE);
   Vegar_WriteSignalDecision(gate,Vegar_GateStateText(state),pass,reason,opp,gVegarExecutionFlow,Vegar_SetupStateText(opp.state));
  }

void Vegar_RC8SetOpportunityGate(SVegarOpportunity &opp,const string gate,const ENUM_VEGAR_GATE_STATE state)
  {
   string v=Vegar_GateStateText(state);
   if(gate=="ContextGate") opp.context_gate=v;
   else if(gate=="M5Gate") opp.m5_gate=v;
   else if(gate=="SessionGate") opp.session_gate=v;
   else if(gate=="NewsGate") opp.news_gate=v;
   else if(gate=="OppositeLiquidityGate") opp.opposite_liquidity_gate=v;
   else if(gate=="TargetSpaceGate") opp.target_space_gate=v;
   else if(gate=="SpreadGate") opp.spread_gate=v;
   else if(gate=="StopGate") opp.stop_gate=v;
   else if(gate=="DailyTargetGate") opp.daily_target_gate=v;
   else if(gate=="DailyLossGate") opp.daily_loss_gate=v;
   else if(gate=="MaxTradesGate") opp.max_trades_gate=v;
   else if(gate=="LossStreakGate") opp.loss_streak_gate=v;
   else if(gate=="PositionGate") opp.position_gate=v;
   else if(gate=="OwnershipGate") opp.ownership_gate=v;
   else if(gate=="MarketGate") opp.market_gate=v;
   else if(gate=="TradingPermissionGate") opp.trading_permission_gate=v;
   else if(gate=="MarginGate") opp.margin_gate=v;
   else if(gate=="StopsLevelGate") opp.stops_level_gate=v;
   else if(gate=="FreezeLevelGate") opp.freeze_level_gate=v;
   else if(gate=="OrderCheckGate") opp.order_check_gate=v;

   bool riskFail=(opp.stop_gate=="FAIL" || opp.daily_target_gate=="FAIL" || opp.daily_loss_gate=="FAIL" ||
                  opp.max_trades_gate=="FAIL" || opp.loss_streak_gate=="FAIL" || opp.position_gate=="FAIL" ||
                  opp.ownership_gate=="FAIL" || opp.margin_gate=="FAIL");
   opp.risk_gate=(riskFail?"FAIL":"PASS");
  }

bool Vegar_RC8SymbolSessionOpen(const string symbol)
  {
   if(symbol=="") return false;
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)) return false;
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent(); if(now<=0)return false;
   MqlDateTime cur; TimeToStruct(now,cur);
   int nowSec=cur.hour*3600+cur.min*60+cur.sec;
   bool any=false;
   for(uint idx=0;idx<32;idx++)
     {
      datetime from=0,to=0;
      if(!SymbolInfoSessionTrade(symbol,(ENUM_DAY_OF_WEEK)cur.day_of_week,idx,from,to)) break;
      any=true;
      MqlDateTime f,t; TimeToStruct(from,f); TimeToStruct(to,t);
      int fs=f.hour*3600+f.min*60+f.sec;
      int ts=t.hour*3600+t.min*60+t.sec;
      if(fs==ts) return true; // broker-declared full-day session
      if(fs<ts && nowSec>=fs && nowSec<ts) return true;
      if(fs>ts && (nowSec>=fs || nowSec<ts)) return true;
     }
   return false; // no declared open session -> fail-safe closed
  }

bool Vegar_RC8MarketGate(const ENUM_VEGAR_BIAS d)
  {
   ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   if(mode==SYMBOL_TRADE_MODE_DISABLED || mode==SYMBOL_TRADE_MODE_CLOSEONLY) return false;
   if(mode==SYMBOL_TRADE_MODE_LONGONLY && d!=VEGAR_BIAS_BUYER) return false;
   if(mode==SYMBOL_TRADE_MODE_SHORTONLY && d!=VEGAR_BIAS_SELLER) return false;
   if(!Vegar_RC8SymbolSessionOpen(_Symbol)) return false;
   return true;
  }

bool Vegar_RC8EvaluateGateMatrix(SVegarOpportunity &opp,ENUM_VEGAR_REASON_CODE &primary_reason)
  {
   opp.failed_gate_count=0; opp.failed_gates=""; primary_reason=VEGAR_REASON_NONE;
   bool all=true;
#define VEGAR_GATE_RECORD(NAME,STATE,REASON) { ENUM_VEGAR_GATE_STATE __st=(STATE); ENUM_VEGAR_REASON_CODE __rs=(REASON); Vegar_RC8SetOpportunityGate(opp,NAME,__st); if(__st==VEGAR_GATE_FAIL){all=false;Vegar_RC8AppendFailure(opp.failed_gates,opp.failed_gate_count,NAME);if(primary_reason==VEGAR_REASON_NONE)primary_reason=__rs;} Vegar_RC8LogGate(opp,NAME,__st,__rs); }

   int zi=Vegar_FindZoneIndex(opp.source_zone_id!=""?opp.source_zone_id:opp.focus_zone_id);
   bool zoneOk=false;
   if(zi>=0 && gVegarZones[zi].valid && gVegarZones[zi].symbol==_Symbol &&
      gVegarZones[zi].role==VEGAR_ZONE_ROLE_OPERATIONAL && gVegarZones[zi].strength_score>=InpForcaMinimaZona)
     {
      ENUM_VEGAR_ZONE_STATE zs=gVegarZones[zi].state;
      zoneOk=(zs!=VEGAR_ZONE_INVALIDATED && zs!=VEGAR_ZONE_EXPIRED &&
              (zs!=VEGAR_ZONE_SWEPT || opp.source_zone_consumed_by_opportunity));
     }
   else if(opp.source_zone_id!="" &&
           (opp.source_zone_role==VEGAR_ZONE_ROLE_OPERATIONAL || opp.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION) &&
           opp.source_zone_pre_state!=VEGAR_ZONE_INVALIDATED && opp.source_zone_pre_state!=VEGAR_ZONE_EXPIRED &&
           opp.focus_zone_strength>=InpForcaMinimaZona)
     {
      // Immutable source snapshot remains valid for the Opportunity even if the global map was rebuilt.
      zoneOk=(opp.source_zone_post_state!=VEGAR_ZONE_INVALIDATED && opp.source_zone_post_state!=VEGAR_ZONE_EXPIRED &&
              (opp.source_zone_post_state!=VEGAR_ZONE_SWEPT || opp.source_zone_consumed_by_opportunity));
     }
   VEGAR_GATE_RECORD("ZoneGate",zoneOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,zoneOk?VEGAR_REASON_NONE:NO_ACTIVE_ZONE);

   ENUM_VEGAR_REASON_CODE reason=VEGAR_REASON_NONE; bool contextOk=Vegar_ContextAllowsDirection(opp.direction,reason);
   VEGAR_GATE_RECORD("ContextGate",contextOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,contextOk?VEGAR_REASON_NONE:reason);

   bool m5Applicable=(Vegar_ExecutionTF()==PERIOD_M1 && InpConfirmarM5QuandoM1); bool m5Ok=(!m5Applicable || !Vegar_CheckM5Conflict(opp.direction));
   VEGAR_GATE_RECORD("M5Gate",!m5Applicable?VEGAR_GATE_NOT_APPLICABLE:(m5Ok?VEGAR_GATE_PASS:VEGAR_GATE_FAIL),m5Ok?VEGAR_REASON_NONE:M5_CONFIRM_CONFLICT);

   SVegarSessionStatus session; reason=VEGAR_REASON_NONE; bool sessionOk=Vegar_SessionGateAllowsEntry(reason,session);
   VEGAR_GATE_RECORD("SessionGate",sessionOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,sessionOk?VEGAR_REASON_NONE:reason);

   reason=VEGAR_REASON_NONE; bool newsOk=Vegar_NewsAllowsEntry(reason);
   VEGAR_GATE_RECORD("NewsGate",newsOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,newsOk?VEGAR_REASON_NONE:reason);

   if(!Vegar_UpdateTick()) { VEGAR_GATE_RECORD("OppositeLiquidityGate",VEGAR_GATE_FAIL,PRICE_INVALID); }
   else
     {
      double entry=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid),op=0.0,str=0.0; string oid="";
      bool oppOk=Vegar_FindOppositeLiquidity(opp.direction,entry,op,oid,str);
      if(oppOk){opp.opposite_liquidity_price=op; double target=0.0; Vegar_CalcEconomicTarget(opp.direction,entry,op,target,opp.expected_money_opposite);}
      VEGAR_GATE_RECORD("OppositeLiquidityGate",oppOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,oppOk?VEGAR_REASON_NONE:NO_VALID_OPPOSITE_ZONE);
     }

   double econTarget=0.0,expected=0.0; bool targetOk=false;
   if(Vegar_UpdateTick() && opp.opposite_liquidity_price>0.0)
     {
      double entry=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid);
      targetOk=Vegar_CalcEconomicTarget(opp.direction,entry,opp.opposite_liquidity_price,econTarget,expected);
      if(targetOk && InpAtivarMetaOperacao && expected+1e-8<InpMetaOperacaoMoney) targetOk=false;
     }
   VEGAR_GATE_RECORD("TargetSpaceGate",targetOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,targetOk?VEGAR_REASON_NONE:TARGET_SPACE_INSUFFICIENT);

   double spreadMoney=Vegar_SpreadMoney(InpLoteOperacional); bool spreadOk=(econTarget>0.0 && spreadMoney/econTarget*100.0<=InpMaxSpreadTargetPercent);
   VEGAR_GATE_RECORD("SpreadGate",spreadOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,spreadOk?VEGAR_REASON_NONE:SPREAD_TOO_HIGH);

   bool stopOk=true; reason=VEGAR_REASON_NONE;
   if(InpAtivarStopLoss)
      stopOk=(InpStopLossMaximoMoney>0.0 && opp.technical_stop>0.0 &&
              opp.technical_stop_money+Vegar_EstimatedRoundTurnCommission(InpLoteOperacional)<=InpStopLossMaximoMoney+1e-8);
   VEGAR_GATE_RECORD("StopGate",InpAtivarStopLoss?(stopOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL):VEGAR_GATE_NOT_APPLICABLE,stopOk?VEGAR_REASON_NONE:STOP_MONEY_EXCEEDED);

   double daily=0.0; int trades=0,losses=0; Vegar_RefreshDailyStats(daily,trades,losses);
   bool dailyTargetOk=(!InpAtivarMetaDiaria || daily<InpMetaDiariaMoney);
   VEGAR_GATE_RECORD("DailyTargetGate",InpAtivarMetaDiaria?(dailyTargetOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL):VEGAR_GATE_NOT_APPLICABLE,dailyTargetOk?VEGAR_REASON_NONE:DAILY_TARGET_REACHED);
   double realizedLoss=Vegar_RealizedLossTodayMoney();
   double openWorst=Vegar_OpenWorstCaseRiskMoney();
   double newWorst=(InpAtivarStopLoss ? opp.technical_stop_money+Vegar_EstimatedRoundTurnCommission(InpLoteOperacional) : MathMax(0.0,InpLimitePerdaDiariaMoney));
   double dailyRemaining=InpLimitePerdaDiariaMoney-realizedLoss-openWorst-newWorst;
   bool dailyLossOk=(InpLimitePerdaDiariaMoney<=0.0 || dailyRemaining>=-1e-8);
   ENUM_VEGAR_REASON_CODE dailyLossReason=(daily<=-InpLimitePerdaDiariaMoney?DAILY_LOSS_REACHED:DAILY_RISK_BUDGET_INSUFFICIENT);
   VEGAR_GATE_RECORD("DailyLossGate",InpLimitePerdaDiariaMoney>0.0?(dailyLossOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL):VEGAR_GATE_NOT_APPLICABLE,dailyLossOk?VEGAR_REASON_NONE:dailyLossReason);
   bool tradesOk=(trades<InpMaxTradesPerDay); VEGAR_GATE_RECORD("MaxTradesGate",tradesOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,tradesOk?VEGAR_REASON_NONE:MAX_TRADES_REACHED);
   bool lossOk=(losses<InpMaxConsecutiveLosses); VEGAR_GATE_RECORD("LossStreakGate",lossOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,lossOk?VEGAR_REASON_NONE:LOSS_STREAK_LOCK);

   reason=VEGAR_REASON_NONE; bool positionOk=Vegar_CheckPositionConflict(reason);
   VEGAR_GATE_RECORD("PositionGate",positionOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,positionOk?VEGAR_REASON_NONE:reason);

   bool ownershipOk=(gVegarRecoveryComplete && !gVegarOwnershipAmbiguous && !Vegar_HasAmbiguousVegarPosition());
   VEGAR_GATE_RECORD("OwnershipGate",ownershipOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,ownershipOk?VEGAR_REASON_NONE:BLOCKED_OWNERSHIP_AMBIGUOUS);

   bool marketOk=Vegar_RC8MarketGate(opp.direction); VEGAR_GATE_RECORD("MarketGate",marketOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,marketOk?VEGAR_REASON_NONE:MARKET_CLOSED);
   bool permOk=(gVegarEngineState==VEGAR_ENGINE_ACTIVE && MQLInfoInteger(MQL_TRADE_ALLOWED) && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && Vegar_EnvironmentAllowsTrading());
   VEGAR_GATE_RECORD("TradingPermissionGate",permOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,permOk?VEGAR_REASON_NONE:TRADING_DISABLED);

   bool marginOk=false; if(Vegar_UpdateTick()) {double m=0.0; ENUM_ORDER_TYPE ot=(opp.direction==VEGAR_BIAS_BUYER?ORDER_TYPE_BUY:ORDER_TYPE_SELL); double e=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid); marginOk=OrderCalcMargin(ot,_Symbol,InpLoteOperacional,e,m) && AccountInfoDouble(ACCOUNT_MARGIN_FREE)-m>0.0; if(marginOk && InpMargemMinimaPermitidaPct>0.0){double total=AccountInfoDouble(ACCOUNT_MARGIN)+m; double ml=(total>0?AccountInfoDouble(ACCOUNT_EQUITY)/total*100.0:999999); marginOk=(ml>=InpMargemMinimaPermitidaPct);}}
   VEGAR_GATE_RECORD("MarginGate",marginOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,marginOk?VEGAR_REASON_NONE:MARGIN_TOO_LOW);

   bool stopsOk=true,freezeOk=true;
   if(Vegar_UpdateTick())
     {
      double e=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid),sl=(InpAtivarStopLoss?opp.technical_stop:0.0);
      double minD=(double)gVegarSymbol.stops_level_points*gVegarSymbol.point,frz=(double)gVegarSymbol.freeze_level_points*gVegarSymbol.point;
      if(InpAtivarStopLoss){ if(opp.direction==VEGAR_BIAS_BUYER){stopsOk=(sl>0&&sl<e&&e-sl>=minD);freezeOk=(sl>0&&e-sl>=frz);} else {stopsOk=(sl>e&&sl-e>=minD);freezeOk=(sl>0&&sl-e>=frz);} }
     }
   VEGAR_GATE_RECORD("StopsLevelGate",InpAtivarStopLoss?(stopsOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL):VEGAR_GATE_NOT_APPLICABLE,stopsOk?VEGAR_REASON_NONE:STOPS_INVALID);
   VEGAR_GATE_RECORD("FreezeLevelGate",InpAtivarStopLoss?(freezeOk?VEGAR_GATE_PASS:VEGAR_GATE_FAIL):VEGAR_GATE_NOT_APPLICABLE,freezeOk?VEGAR_REASON_NONE:FREEZE_LEVEL_BLOCK);

   // RC8: OrderCheckGate is finalized only in PRE-FLIGHT, after the definitive request is frozen.
   // No temporary request may be checked here, otherwise the checked request could differ from OrderSend.
   VEGAR_GATE_RECORD("OrderCheckGate",VEGAR_GATE_NOT_EVALUATED,VEGAR_REASON_NONE)

#undef VEGAR_GATE_RECORD
   opp.operational_signal_ready=all;
   opp.execution_authorized=all;
   opp.pipeline_state="GATE_EVALUATION";
   opp.preflight_gate=(all?"REACHABLE":"BLOCKED_BY_GATES");
   opp.last_reason=primary_reason;
   gVegarLastGateSummary=(opp.failed_gate_count==0?"PASS":opp.failed_gates);
   Vegar_WriteOpportunitySnapshot(opp,"GATE_EVALUATION",all?"PASS":"BLOCKED",primary_reason,gVegarExecutionFlow,gVegarChannelM15);
   return all;
  }

int Vegar_RC8FindMarker(const string marker_id)
  {
   for(int i=0;i<ArraySize(gVegarSignalMarkers);i++) if(gVegarSignalMarkers[i].marker_id==marker_id) return i;
   return -1;
  }

double Vegar_RC8MarkerDisplayPrice(const SVegarSignalMarker &m)
  {
   int shift=iBarShift(m.symbol,m.tf,m.signal_time,false);
   if(shift<0) return m.signal_price;
   MqlRates b; if(!Vegar_GetBarForSymbol(m.symbol,m.tf,shift,b)) return m.signal_price;
   double atr=0.0;
   if(m.symbol==_Symbol) atr=Vegar_ATR(m.tf,shift);
   double tick=(m.symbol==_Symbol?gVegarSymbol.tick_size:SymbolInfoDouble(m.symbol,SYMBOL_TRADE_TICK_SIZE));
   if(tick<=0.0) tick=SymbolInfoDouble(m.symbol,SYMBOL_POINT);
   double offset=MathMax(3.0*tick,(atr>0.0?0.08*atr:0.0));
   if(offset<=0.0) offset=3.0*tick;
   return (m.direction==VEGAR_BIAS_BUYER?b.low-offset:b.high+offset);
  }

void Vegar_RC8DrawMarker(const SVegarSignalMarker &m)
  {
   string n="VEGAR_MARKER_"+m.marker_id;
   double drawPrice=Vegar_RC8MarkerDisplayPrice(m);
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_ARROW,0,m.signal_time,drawPrice);
   else ObjectMove(0,n,0,m.signal_time,drawPrice);
   color c=clrGold;
   bool observation=(m.marker_class==VEGAR_MARKER_OBSERVATION_BUY || m.marker_class==VEGAR_MARKER_OBSERVATION_SELL);
   if(m.marker_class==VEGAR_MARKER_VALID_BUY) c=C'0,220,160';
   else if(m.marker_class==VEGAR_MARKER_VALID_SELL) c=clrOrangeRed;
   else if(observation) c=clrLightBlue;
   ObjectSetInteger(0,n,OBJPROP_COLOR,c);
   ObjectSetInteger(0,n,OBJPROP_ARROWCODE,(m.direction==VEGAR_BIAS_BUYER?233:234));
   ObjectSetInteger(0,n,OBJPROP_WIDTH,(observation?1:2));
   ObjectSetInteger(0,n,OBJPROP_BACK,false);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,20);
   ObjectSetString(0,n,OBJPROP_TOOLTIP,(observation?"OBS | ":"")+Vegar_MarkerClassText(m.marker_class)+" | "+Vegar_ReasonText(m.primary_reason)+" | "+m.failed_gates);
  }

void Vegar_RC8PruneMarkers()
  {
   int maxN=MathMax(1,InpMaxSignalMarkersOnChart);
   int n=ArraySize(gVegarSignalMarkers);
   if(n<=maxN) return;
   int remove=n-maxN;
   for(int i=0;i<remove;i++)
     {
      string on="VEGAR_MARKER_"+gVegarSignalMarkers[i].marker_id;
      string ex="VEGAR_MARKER_EXEC_"+gVegarSignalMarkers[i].marker_id;
      if(ObjectFind(0,on)>=0) ObjectDelete(0,on);
      if(ObjectFind(0,ex)>=0) ObjectDelete(0,ex);
     }
   for(int i=remove;i<n;i++) gVegarSignalMarkers[i-remove]=gVegarSignalMarkers[i];
   ArrayResize(gVegarSignalMarkers,maxN);
  }

string Vegar_RC8OppositeZoneID(const SVegarOpportunity &opp)
  {
   if(opp.opposite_liquidity_price<=0.0) return "";
   double p=0.0,s=0.0; string id=""; double entry=(opp.direction==VEGAR_BIAS_BUYER?opp.hypothetical_entry_ask:opp.hypothetical_entry_bid);
   if(entry<=0.0 && Vegar_UpdateTick()) entry=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid);
   if(Vegar_FindOppositeLiquidity(opp.direction,entry,p,id,s)) return id;
   return "";
  }

string Vegar_RC8CreateSignalMarker(SVegarOpportunity &opp,const ENUM_VEGAR_REASON_CODE primary)
  {
   SVegarSignalMarker m; ZeroMemory(m);
   m.active=true; m.marker_id=Vegar_NextID("MARKER"); m.candidate_id=opp.candidate_id; m.setup_family=opp.setup_family; m.opportunity_id=opp.opportunity_id; m.setup_id=opp.setup_id; m.signal_id=opp.signal_id;
   m.symbol=_Symbol; m.tf=Vegar_ExecutionTF(); m.signal_time=(opp.retest_time>0?opp.retest_time:iTime(_Symbol,Vegar_ExecutionTF(),1));
   Vegar_UpdateTick(); m.signal_price=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid); m.direction=opp.direction;
   m.technical_signal_ready=opp.technical_signal_ready; m.operational_eligible_at_approach=opp.operational_eligible_at_approach; m.operational_signal_ready=opp.operational_signal_ready; m.preflight_passed=false;
   m.zone_id=opp.focus_zone_id; m.zone_role=opp.source_zone_role; m.execution_authorized=opp.execution_authorized;
   m.context_gate=opp.context_gate; m.m5_gate=opp.m5_gate; m.session_gate=opp.session_gate; m.news_gate=opp.news_gate;
   m.target_space_gate=opp.target_space_gate; m.spread_gate=opp.spread_gate; m.risk_gate=opp.risk_gate; m.preflight_gate=opp.preflight_gate;
   m.failed_gate_count=opp.failed_gate_count; m.failed_gates=opp.failed_gates; m.primary_reason=primary;
   bool observation=(opp.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION_OBSERVATION);
   if(observation) m.marker_class=(opp.direction==VEGAR_BIAS_BUYER?VEGAR_MARKER_OBSERVATION_BUY:VEGAR_MARKER_OBSERVATION_SELL);
   else if(opp.execution_authorized) m.marker_class=(opp.direction==VEGAR_BIAS_BUYER?VEGAR_MARKER_VALID_BUY:VEGAR_MARKER_VALID_SELL);
   else m.marker_class=(opp.direction==VEGAR_BIAS_BUYER?VEGAR_MARKER_BLOCKED_BUY:VEGAR_MARKER_BLOCKED_SELL);
   m.final_state=(observation?"OBSERVATION_ONLY":(opp.execution_authorized?"EXECUTION_AUTHORIZED":"BLOCKED"));
   int n=ArraySize(gVegarSignalMarkers); ArrayResize(gVegarSignalMarkers,n+1); gVegarSignalMarkers[n]=m;
   opp.marker_id=m.marker_id;
   Vegar_RC8DrawMarker(gVegarSignalMarkers[n]);
   double target=0.0,expected=0.0,spreadPct=0.0; string oid=Vegar_RC8OppositeZoneID(opp);
   if(Vegar_UpdateTick() && opp.opposite_liquidity_price>0.0){double e=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid); if(Vegar_CalcEconomicTarget(opp.direction,e,opp.opposite_liquidity_price,target,expected)&&target>0.0)spreadPct=Vegar_SpreadMoney(InpLoteOperacional)/target*100.0;}
   Vegar_WriteSignalMarker(gVegarSignalMarkers[n],opp,gVegarExecutionFlow,gVegarLiveFlow,gVegarChannelM15,Vegar_SpreadMoney(InpLoteOperacional),spreadPct,oid,opp.opposite_liquidity_price,expected);
   Vegar_RC8PruneMarkers();
   return m.marker_id;
  }

void Vegar_RC8OnTechnicalSignal(SVegarOpportunity &opp)
  {
   if(opp.technical_signal_ready && opp.marker_id!="") return;
   opp.technical_signal_ready=true;
   opp.pipeline_state="TECHNICAL_SIGNAL_READY";
   ENUM_VEGAR_REASON_CODE reason=VEGAR_REASON_NONE;
   bool pass=Vegar_RC8EvaluateGateMatrix(opp,reason);
   opp.execution_authorized=pass; opp.last_reason=reason;
   if(pass)
     {
      opp.pipeline_state="EXECUTION_AUTHORIZED";
      Vegar_WriteOpportunitySnapshot(opp,"EXECUTION_AUTHORIZED","PASS",VEGAR_REASON_NONE,gVegarExecutionFlow,gVegarChannelM15);
     }
   Vegar_RC8CreateSignalMarker(opp,reason);
   Vegar_WriteOpportunitySnapshot(opp,"TECHNICAL_SIGNAL_READY",pass?"EXECUTION_AUTHORIZED":"BLOCKED",reason,gVegarExecutionFlow,gVegarChannelM15);
  }

void Vegar_RC8MarkMarkerBlockedLater(const ENUM_VEGAR_REASON_CODE reason,const string gate)
  {
   string mid=gVegarOpportunity.marker_id; int mi=Vegar_RC8FindMarker(mid); if(mi<0) return;
   SVegarSignalMarker m=gVegarSignalMarkers[mi];
   ENUM_VEGAR_MARKER_CLASS previous=m.marker_class;
   m.marker_class=(m.direction==VEGAR_BIAS_BUYER?VEGAR_MARKER_BLOCKED_BUY:VEGAR_MARKER_BLOCKED_SELL);
   m.primary_reason=reason;
   m.final_state="BLOCKED_AFTER_SIGNAL";
   if(gate!="")
     {
      bool present=(StringFind(";"+m.failed_gates+";",";"+gate+";")>=0);
      if(!present)
        {
         if(m.failed_gates!="") m.failed_gates+=";";
         m.failed_gates+=gate;
         m.failed_gate_count++;
        }
     }
   gVegarSignalMarkers[mi]=m;
   Vegar_RC8DrawMarker(gVegarSignalMarkers[mi]);
   if(previous!=m.marker_class)
      Vegar_WriteDiagnostic("MARKER_STATE_CHANGED","BLOCKED",Vegar_ReasonText(reason),m.marker_id,
                            "Previous="+Vegar_MarkerClassText(previous)+"|Current="+Vegar_MarkerClassText(m.marker_class)+
                            "|Gate="+gate+"|Reason="+Vegar_ReasonText(reason));
   double target=0.0,expected=gVegarOpportunity.expected_money_opposite,spreadPct=0.0; string oid=Vegar_RC8OppositeZoneID(gVegarOpportunity);
   if(gVegarIntent.economic_target_money>0.0) spreadPct=Vegar_SpreadMoney(gVegarIntent.requested_volume)/gVegarIntent.economic_target_money*100.0;
   Vegar_WriteSignalMarker(gVegarSignalMarkers[mi],gVegarOpportunity,gVegarExecutionFlow,gVegarLiveFlow,gVegarChannelM15,
                           Vegar_SpreadMoney(gVegarIntent.requested_volume),spreadPct,oid,gVegarOpportunity.opposite_liquidity_price,expected);
  }

void Vegar_RC8UpdateMarkerAfterExecution(const SVegarExecutionResult &x,const SVegarIntent &intent)
  {
   string mid=gVegarOpportunity.marker_id; int mi=Vegar_RC8FindMarker(mid); if(mi<0) return;
   SVegarSignalMarker m=gVegarSignalMarkers[mi];
   m.intent_id=intent.intent_id; m.preflight_passed=x.preflight_ok; m.pipeline_state=(x.request_accepted?"ORDERSEND":(x.order_check_called?"ORDERCHECK":"PREFLIGHT")); m.order_send_called=x.order_send_called; m.order_accepted=x.request_accepted; m.order_ticket=x.order_ticket; m.deal_ticket=x.deal_ticket;
   if(x.request_accepted) m.final_state="ORDER_ACCEPTED";
   else if(x.order_send_called || !x.preflight_ok)
     {
      ENUM_VEGAR_MARKER_CLASS previous=m.marker_class;
      m.marker_class=(m.direction==VEGAR_BIAS_BUYER?VEGAR_MARKER_BLOCKED_BUY:VEGAR_MARKER_BLOCKED_SELL); m.primary_reason=x.reason; m.final_state=(x.order_send_called?"ORDER_SEND_REJECTED":"PREFLIGHT_REJECTED");
      if(m.failed_gates!="")m.failed_gates+=";"; m.failed_gates+=(x.order_send_called?"OrderSend":"Preflight"); m.failed_gate_count++;
      if(previous!=m.marker_class)
         Vegar_WriteDiagnostic("MARKER_STATE_CHANGED","BLOCKED",Vegar_ReasonText(x.reason),m.marker_id,
                               "Previous="+Vegar_MarkerClassText(previous)+"|Current="+Vegar_MarkerClassText(m.marker_class)+
                               "|Reason="+Vegar_ReasonText(x.reason));
     }
   gVegarSignalMarkers[mi]=m;
   Vegar_RC8DrawMarker(gVegarSignalMarkers[mi]);
   double target=0.0,exp=gVegarOpportunity.expected_money_opposite,pct=0.0; string oid=Vegar_RC8OppositeZoneID(gVegarOpportunity); if(intent.economic_target_money>0.0)pct=Vegar_SpreadMoney(intent.requested_volume)/intent.economic_target_money*100.0;
   Vegar_WriteSignalMarker(gVegarSignalMarkers[mi],gVegarOpportunity,gVegarExecutionFlow,gVegarLiveFlow,gVegarChannelM15,Vegar_SpreadMoney(intent.requested_volume),pct,oid,gVegarOpportunity.opposite_liquidity_price,exp);
  }

void Vegar_RC8DrawExecLabel(const SVegarSignalMarker &m)
  {
   if(!m.deal_confirmed || m.deal_ticket==0) return;
   string n="VEGAR_MARKER_EXEC_"+m.marker_id;
   double base=Vegar_RC8MarkerDisplayPrice(m);
   double atr=Vegar_ATR(m.tf,1);
   if(atr<=0.0) atr=10.0*MathMax(gVegarSymbol.tick_size,gVegarSymbol.point);
   int lane=0;
   double y=Vegar_VisualResolveLabelY(n,m.direction,m.signal_time,base,atr,17,lane);
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_TEXT,0,m.signal_time,y);
   else ObjectMove(0,n,0,m.signal_time,y);
   ObjectSetString(0,n,OBJPROP_TEXT,(m.direction==VEGAR_BIAS_BUYER?"BUY":"SELL"));
   ObjectSetString(0,n,OBJPROP_TOOLTIP,"ENTRY | Deal "+(string)m.deal_ticket);
   ObjectSetString(0,n,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,n,OBJPROP_COLOR,(m.direction==VEGAR_BIAS_BUYER?C'53,224,230':C'255,122,69'));
   ObjectSetInteger(0,n,OBJPROP_BACK,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,20);
  }

void Vegar_RC8RecordMarkerRealOutcome(const ulong exit_deal)
  {
   if(exit_deal==0 || !HistoryDealSelect(exit_deal)) return;
   long pid=(long)HistoryDealGetInteger(exit_deal,DEAL_POSITION_ID);
   if(pid<=0) return;
   int mi=-1;
   for(int i=ArraySize(gVegarSignalMarkers)-1;i>=0;i--)
      if(gVegarSignalMarkers[i].position_id==pid){mi=i;break;}
   if(mi<0) return;

   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent();
   if(!HistorySelect(0,now)) return;
   double gross=0.0,loss=0.0,commission=0.0,swap=0.0,fees=0.0,net=0.0;
   double entry_price=0.0,exit_price=HistoryDealGetDouble(exit_deal,DEAL_PRICE);
   datetime entry_time=0,exit_time=(datetime)HistoryDealGetInteger(exit_deal,DEAL_TIME);
   int deals=0;
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong d=HistoryDealGetTicket(i); if(d==0)continue;
      if((long)HistoryDealGetInteger(d,DEAL_POSITION_ID)!=pid)continue;
      if(HistoryDealGetString(d,DEAL_SYMBOL)!=gVegarSignalMarkers[mi].symbol)continue;
      if((long)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagicNumber && !Vegar_OwnershipHasPositionID(pid))continue;
      double pr=HistoryDealGetDouble(d,DEAL_PROFIT);
      if(pr>=0.0)gross+=pr; else loss+=pr;
      commission+=HistoryDealGetDouble(d,DEAL_COMMISSION);
      swap+=HistoryDealGetDouble(d,DEAL_SWAP);
      fees+=HistoryDealGetDouble(d,DEAL_FEE);
      ENUM_DEAL_ENTRY de=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(d,DEAL_ENTRY);
      datetime dt=(datetime)HistoryDealGetInteger(d,DEAL_TIME);
      if((de==DEAL_ENTRY_IN || de==DEAL_ENTRY_INOUT) && (entry_time==0 || dt<entry_time)) {entry_time=dt;entry_price=HistoryDealGetDouble(d,DEAL_PRICE);}
      deals++;
     }
   net=gross+loss+commission+swap+fees;
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",MarkerID,PositionID,EntryTime,ExitTime,EntryPrice,ExitPrice,GrossProfit,Losses,Commission,Swap,Fees,NetResult,DealCount,OutcomeMode,DecisionAuthority";
   string r=Vegar_CommonPrefix(eid,gVegarSignalMarkers[mi].opportunity_id,gVegarSignalMarkers[mi].candidate_id,gVegarSignalMarkers[mi].setup_id,gVegarSignalMarkers[mi].signal_id,gVegarSignalMarkers[mi].intent_id,"SIGNAL_MARKER_REAL_OUTCOME","CLOSED","NONE","");
   r+=","+Vegar_CsvEscape(gVegarSignalMarkers[mi].marker_id)+","+(string)pid+","+Vegar_CsvEscape(Vegar_TimeIso(entry_time))+","+Vegar_CsvEscape(Vegar_TimeIso(exit_time))+","+
      DoubleToString(entry_price,Vegar_TelemetryPricePrecision())+","+DoubleToString(exit_price,Vegar_TelemetryPricePrecision())+","+
      DoubleToString(gross,8)+","+DoubleToString(loss,8)+","+DoubleToString(commission,8)+","+DoubleToString(swap,8)+","+DoubleToString(fees,8)+","+DoubleToString(net,8)+","+(string)deals+",REAL,1";
   Vegar_CsvAppend("SIGNAL_MARKER_REAL_OUTCOME",h,r);
   gVegarSignalMarkers[mi].final_state="POSITION_CLOSED";
  }

void Vegar_RC8ConfirmMarkerDeal(const ulong deal)
  {
   if(deal==0 || !HistoryDealSelect(deal)) return;
   if((long)HistoryDealGetInteger(deal,DEAL_MAGIC)!=InpMagicNumber || HistoryDealGetString(deal,DEAL_SYMBOL)!=_Symbol) return;
   long pid=(long)HistoryDealGetInteger(deal,DEAL_POSITION_ID);
   for(int i=ArraySize(gVegarSignalMarkers)-1;i>=0;i--)
     {
      if(gVegarSignalMarkers[i].deal_confirmed) continue;
      if(!gVegarSignalMarkers[i].order_accepted) continue;
      gVegarSignalMarkers[i].deal_confirmed=true; gVegarSignalMarkers[i].deal_ticket=deal; gVegarSignalMarkers[i].position_id=pid; gVegarSignalMarkers[i].final_state="DEAL_CONFIRMED";
      Vegar_RC8DrawMarker(gVegarSignalMarkers[i]);
      Vegar_RC8DrawExecLabel(gVegarSignalMarkers[i]);
      break;
     }
  }

bool Vegar_RC8MicroAlignedWithM15(const ENUM_VEGAR_BIAS direction)
  {
   // RC9: em TRANSICAO o M15 nao aponta contra nenhum lado; com RC8 a familia
   // micro ficava sem autoridade em ~22% do tempo por esse motivo.
   if(InpMicroAutoridadeEmTransicao && gVegarM15Context==VEGAR_M15_TRANSITION &&
      (direction==VEGAR_BIAS_BUYER || direction==VEGAR_BIAS_SELLER)) return true;
   if(direction==VEGAR_BIAS_BUYER) return (gVegarM15Context==VEGAR_M15_TREND_UP);
   if(direction==VEGAR_BIAS_SELLER) return (gVegarM15Context==VEGAR_M15_TREND_DOWN);
   return false;
  }

bool Vegar_RC8ObservationZoneAuthorized(const SVegarZone &z)
  {
   return (InpAtivarMicroContinuacaoOperacional && Vegar_RC8MicroAlignedWithM15(z.operational_bias) && z.strength_score>=InpForcaMinimaZona);
  }

int Vegar_RC8ObservationBestZone(const MqlRates &bar,double &distance,const bool authorized_only=false)
  {
   distance=DBL_MAX; int best=-1; double bestStrength=-1.0; datetime bestRecent=0;
   for(int i=0;i<ArraySize(gVegarObservationZones);i++)
     {
      SVegarZone z=gVegarObservationZones[i];
      if(!z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OBSERVATION) continue;
      if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
      if(z.strength_score<InpForcaMinimaZona) continue;
      if(authorized_only && !Vegar_RC8ObservationZoneAuthorized(z)) continue;
      // RC8: micro zones remain observable even when not aligned; M15 alignment grants operational authority later.
      double d=999.0; if(!Vegar_ClosedBarApproachForRole(z,bar,VEGAR_ZONE_ROLE_OBSERVATION,d)) continue;
      bool better=(d<distance-1e-12 || (MathAbs(d-distance)<=1e-12 &&
                   (z.strength_score>bestStrength+1e-9 ||
                    (MathAbs(z.strength_score-bestStrength)<=1e-9 && z.confirmed_time>bestRecent))));
      if(better){best=i;distance=d;bestStrength=z.strength_score;bestRecent=z.confirmed_time;}
     }
   return best;
  }

void Vegar_RC8ObservationStart(const int zi,const MqlRates &bar)
  {
   if(zi<0 || zi>=ArraySize(gVegarObservationZones)) return;
   Vegar_RC8ResetObservationCandidate();
   SVegarZone z=gVegarObservationZones[zi];
   gVegarObservationCandidate.active=true;
   gVegarObservationCandidate.candidate_id=Vegar_NextID("OBSCAND");
   gVegarObservationCandidate.candidate_state=VEGAR_CANDIDATE_APPROACH;
   bool microOperational=Vegar_RC8ObservationZoneAuthorized(z);
   gVegarObservationCandidate.setup_family=(microOperational?VEGAR_SETUP_FAMILY_MICRO_CONTINUATION:VEGAR_SETUP_FAMILY_MICRO_CONTINUATION_OBSERVATION);
   gVegarObservationCandidate.symbol=_Symbol;
   gVegarObservationCandidate.execution_tf=Vegar_ExecutionTF();
   gVegarObservationCandidate.direction=z.operational_bias;
   gVegarObservationCandidate.zone_id=z.id;
   gVegarObservationCandidate.zone_role=z.role;
   gVegarObservationCandidate.zone_tf=z.source_tf;
   gVegarObservationCandidate.zone_strength=z.strength_score;
   gVegarObservationCandidate.source_zone_pre_state=z.state;
   gVegarObservationCandidate.source_zone_post_state=z.state;
   gVegarObservationCandidate.approach_mode=VEGAR_APPROACH_CLOSED_BAR;
   gVegarObservationCandidate.approach_first_time=bar.time;
   double d=999.0; Vegar_ClosedBarApproachForRole(z,bar,VEGAR_ZONE_ROLE_OBSERVATION,d);
   gVegarObservationCandidate.approach_minimum_distance_atr=d;
   gVegarObservationCandidate.created_time=bar.time;
   gVegarObservationCandidate.state=VEGAR_SETUP_LIQUIDITY_APPROACH;
   gVegarObservationCandidate.operational_eligible_at_approach=microOperational;
   gVegarObservationCandidate.approach_block_reason=(microOperational?VEGAR_REASON_NONE:OBSERVATION_ONLY);
   gVegarObservationCandidate.operational_approach_armed=microOperational;

   SVegarZoneEventSnapshot snap; ZeroMemory(snap);
   snap.valid=true; snap.zone_id=z.id; snap.symbol=z.symbol; snap.role=z.role; snap.type=z.type; snap.source_tf=z.source_tf;
   snap.bias=z.operational_bias; snap.liquidity_side=z.liquidity_side; snap.pre_state=z.state; snap.pre_strength=z.strength_score;
   snap.low=z.low; snap.high=z.high; snap.mid=z.mid; snap.source_atr=z.source_atr; snap.closed_bar_time=bar.time;
   snap.closed_bar_open=bar.open; snap.closed_bar_high=bar.high; snap.closed_bar_low=bar.low; snap.closed_bar_close=bar.close;
   snap.approach_observed=true; snap.distance_atr=d; snap.post_state=z.state;
   Vegar_RC8WriteApproachEvent("OBSERVATION_APPROACH",gVegarObservationCandidate.candidate_id,snap,
                               "SetupFamily="+Vegar_SetupFamilyText(gVegarObservationCandidate.setup_family)+"|DecisionAuthority="+(microOperational?"1":"0")+"|M15="+Vegar_M15ContextText(gVegarM15Context));
  }

bool Vegar_RC8ObservationOrderBlock(const ENUM_VEGAR_BIAS direction,const datetime displacement,const datetime sweep,double &low,double &high)
  {
   MqlRates r[]; if(!Vegar_CopyRates(Vegar_ExecutionTF(),1,12,r)) return false;
   for(int i=1;i<ArraySize(r);i++)
     {
      if(r[i].time>=displacement) continue;
      if(sweep>0 && r[i].time<sweep-PeriodSeconds(Vegar_ExecutionTF())*2) break;
      bool bearish=(r[i].close<r[i].open),bullish=(r[i].close>r[i].open);
      if(direction==VEGAR_BIAS_BUYER && bearish){low=r[i].low;high=r[i].high;return true;}
      if(direction==VEGAR_BIAS_SELLER && bullish){low=r[i].low;high=r[i].high;return true;}
     }
   return false;
  }

void Vegar_RC8ObservationToOpportunity(SVegarOpportunity &o)
  {
   ZeroMemory(o);
   o.active=false;
   o.candidate_id=gVegarObservationCandidate.candidate_id;
   o.candidate_state=gVegarObservationCandidate.candidate_state;
   o.setup_family=gVegarObservationCandidate.setup_family;
   o.observation_candidate=true;
   o.opportunity_id="OBS_"+gVegarObservationCandidate.candidate_id;
   o.setup_id="OBS_SETUP_"+gVegarObservationCandidate.candidate_id;
   o.signal_id="OBS_SIG_"+gVegarObservationCandidate.candidate_id;
   o.direction=gVegarObservationCandidate.direction;
   o.focus_zone_id=gVegarObservationCandidate.zone_id;
   o.focus_zone_strength=gVegarObservationCandidate.zone_strength;
   o.source_zone_id=gVegarObservationCandidate.zone_id;
   o.source_zone_role=VEGAR_ZONE_ROLE_OBSERVATION;
   o.source_zone_tf=gVegarObservationCandidate.zone_tf;
   int zi=Vegar_FindObservationZoneIndex(gVegarObservationCandidate.zone_id);
   if(zi>=0)
     {
      o.source_zone_type=gVegarObservationZones[zi].type;
      o.source_zone_bias=gVegarObservationZones[zi].operational_bias;
      o.source_zone_liquidity_side=gVegarObservationZones[zi].liquidity_side;
      o.source_zone_low=gVegarObservationZones[zi].low;
      o.source_zone_high=gVegarObservationZones[zi].high;
      o.source_zone_mid=gVegarObservationZones[zi].mid;
      o.source_zone_atr=gVegarObservationZones[zi].source_atr;
     }
   o.source_zone_pre_state=gVegarObservationCandidate.source_zone_pre_state;
   o.source_zone_post_state=gVegarObservationCandidate.source_zone_post_state;
   o.source_zone_consumed_by_opportunity=(gVegarObservationCandidate.sweep_time>0);
   o.approach_mode=gVegarObservationCandidate.approach_mode;
   o.approach_first_time=gVegarObservationCandidate.approach_first_time;
   o.approach_minimum_distance_atr=gVegarObservationCandidate.approach_minimum_distance_atr;
   o.sweep_same_bar_as_approach=gVegarObservationCandidate.sweep_same_bar_as_approach;
   o.created_time=gVegarObservationCandidate.created_time;
   o.sweep_time=gVegarObservationCandidate.sweep_time;
   o.mss_time=gVegarObservationCandidate.mss_time;
   o.displacement_time=gVegarObservationCandidate.displacement_time;
   o.retest_time=gVegarObservationCandidate.retest_time;
   o.sweep_extreme=gVegarObservationCandidate.sweep_extreme;
   o.micro_break_level=gVegarObservationCandidate.micro_break_level;
   o.retest_type=gVegarObservationCandidate.retest_type;
   o.retest_low=gVegarObservationCandidate.retest_low;
   o.retest_high=gVegarObservationCandidate.retest_high;
   o.retest_mid=gVegarObservationCandidate.retest_mid;
   o.hypothetical_entry_bid=gVegarObservationCandidate.hypothetical_entry_bid;
   o.hypothetical_entry_ask=gVegarObservationCandidate.hypothetical_entry_ask;
   o.technical_stop=gVegarObservationCandidate.technical_stop;
   o.technical_stop_money=gVegarObservationCandidate.technical_stop_money;
   o.opposite_liquidity_price=gVegarObservationCandidate.opposite_liquidity_price;
   o.expected_money_opposite=gVegarObservationCandidate.expected_money_opposite;
   o.mss_required_level=gVegarObservationCandidate.mss_required_level;
   o.mss_best_observed=gVegarObservationCandidate.mss_best_observed;
   o.mss_distance_missing=gVegarObservationCandidate.mss_distance_missing;
   o.displacement_required_range_ratio=gVegarObservationCandidate.displacement_required_range_ratio;
   o.displacement_observed_range_ratio=gVegarObservationCandidate.displacement_observed_range_ratio;
   o.displacement_required_close_location=gVegarObservationCandidate.displacement_required_close_location;
   o.displacement_observed_close_location=gVegarObservationCandidate.displacement_observed_close_location;
   o.operational_eligible_at_approach=gVegarObservationCandidate.operational_eligible_at_approach;
   o.approach_block_reason=gVegarObservationCandidate.approach_block_reason;
   o.operational_approach_armed=gVegarObservationCandidate.operational_approach_armed;
   o.operational_signal_ready=false;
   o.execution_authorized=false;
   o.state=VEGAR_SETUP_RETEST_CONFIRMED;
   o.technical_signal_ready=true;
   if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
     {
      o.failed_gate_count=0;
      o.failed_gates="";
      o.preflight_gate="NOT_EVALUATED";
      o.last_reason=VEGAR_REASON_NONE;
     }
   else
     {
      o.failed_gate_count=1;
      o.failed_gates="OBSERVATION_ONLY";
      o.preflight_gate="NOT_APPLICABLE";
      o.last_reason=OBSERVATION_ONLY;
     }
  }

void Vegar_RC8ObservationTelemetry(const string stage,const ENUM_VEGAR_SETUP_STATE state,const ENUM_VEGAR_REASON_CODE reason)
  {
   SVegarOpportunity o; Vegar_RC8ObservationToOpportunity(o);
   o.state=state; o.pipeline_state=stage; o.last_reason=reason;
   o.technical_signal_ready=(stage=="TECHNICAL_SIGNAL_READY");
   bool accepted=(reason==VEGAR_REASON_NONE);
   Vegar_WriteSignalDecision(stage,Vegar_SetupStateText(state),accepted,reason,o,gVegarExecutionFlow,Vegar_SetupStateText(state));
   Vegar_WriteOpportunitySnapshot(o,stage,accepted?"ACCEPTED":"BLOCKED",reason,gVegarExecutionFlow,gVegarChannelM15);
  }

void Vegar_RC8ObservationFinishSignal()
  {
   SVegarOpportunity o; Vegar_RC8ObservationToOpportunity(o);
   bool operationalFamily=(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION);
   bool aligned=Vegar_RC8MicroAlignedWithM15(o.direction);
   bool strong=(o.focus_zone_strength>=InpForcaMinimaZona);
   bool canPromote=(InpAtivarMicroContinuacaoOperacional && operationalFamily && aligned && strong &&
                    !gVegarOpportunity.active && !Vegar_HasOwnedPosition());

   if(canPromote)
     {
      o.active=true;
      o.observation_candidate=false;
      o.setup_family=VEGAR_SETUP_FAMILY_MICRO_CONTINUATION;
      o.operational_eligible_at_approach=true;
      o.approach_block_reason=VEGAR_REASON_NONE;
      o.operational_approach_armed=true;
      o.operational_signal_ready=false;
      o.execution_authorized=false;
      o.failed_gate_count=0; o.failed_gates="";
      o.preflight_gate="NOT_EVALUATED";
      o.last_reason=VEGAR_REASON_NONE;
      o.state=VEGAR_SETUP_RETEST_CONFIRMED;
      o.pipeline_state="TECHNICAL_SIGNAL_READY";
      o.technical_signal_ready=false; // force the common operational gate/marker path below
      gVegarOpportunity=o;
      gVegarStats.opportunities_created++;
      Vegar_RC8OnTechnicalSignal(gVegarOpportunity);
      gVegarObservationCandidate.marker_id=gVegarOpportunity.marker_id;

      if(gVegarOpportunity.execution_authorized)
        {
         if(Vegar_CreateIntentFromOpportunity())
            Vegar_SetOpportunityState(VEGAR_SETUP_ENTRY_INTENT,VEGAR_REASON_NONE,"ENTRY_INTENT");
         else
            Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,ECONOMIC_TARGET_UNAVAILABLE,"MICRO_INTENT_BUILD_FAIL");
        }
      else
        {
         ENUM_VEGAR_REASON_CODE rr=(gVegarOpportunity.last_reason==VEGAR_REASON_NONE?ORDER_REQUEST_NOT_ALLOWED:gVegarOpportunity.last_reason);
         Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,rr,"MICRO_GATE_EVALUATION_BLOCKED");
        }
     }
   else if(operationalFamily)
     {
      // It was a real MICRO_CONTINUATION candidate. Do not relabel it as merely observational
      // when it loses M15 alignment or concurrency/position authority at signal time.
      ENUM_VEGAR_REASON_CODE rr=(!aligned?M15_DIRECTION_CONFLICT:(Vegar_HasOwnedPosition()?POSITION_EXISTS:ORDER_REQUEST_NOT_ALLOWED));
      o.observation_candidate=false;
      o.setup_family=VEGAR_SETUP_FAMILY_MICRO_CONTINUATION;
      o.operational_eligible_at_approach=true;
      o.technical_signal_ready=true;
      o.operational_signal_ready=false;
      o.execution_authorized=false;
      o.failed_gate_count=1;
      o.failed_gates=(!aligned?"ContextGate":"ConcurrencyGate");
      o.last_reason=rr;
      o.pipeline_state="TECHNICAL_SIGNAL_READY";
      o.marker_id=Vegar_RC8CreateSignalMarker(o,rr);
      Vegar_WriteOpportunitySnapshot(o,"TECHNICAL_SIGNAL_READY","BLOCKED",rr,gVegarExecutionFlow,gVegarChannelM15);
      if(InpAtivarOpportunityReplay) Vegar_ReplayQueueWithMarker(o,o.marker_id);
      gVegarObservationCandidate.marker_id=o.marker_id;
     }
   else
     {
      o.setup_family=VEGAR_SETUP_FAMILY_MICRO_CONTINUATION_OBSERVATION;
      o.execution_authorized=false;
      o.operational_signal_ready=false;
      o.failed_gate_count=1;
      o.failed_gates="OBSERVATION_ONLY";
      o.last_reason=OBSERVATION_ONLY;
      o.marker_id=Vegar_RC8CreateSignalMarker(o,OBSERVATION_ONLY);
      Vegar_WriteOpportunitySnapshot(o,"OBSERVATION_TECHNICAL_SIGNAL_READY","OBSERVATION_ONLY",OBSERVATION_ONLY,gVegarExecutionFlow,gVegarChannelM15);
      if(InpAtivarOpportunityReplay) Vegar_ReplayQueueWithMarker(o,o.marker_id);
      gVegarObservationCandidate.marker_id=o.marker_id;
     }

   gVegarObservationCandidate.technical_signal_ready=true;
   gVegarObservationCandidate.active=false;
   gVegarObservationCandidate.candidate_state=VEGAR_CANDIDATE_PROMOTED;
   gVegarObservationCandidate.state=VEGAR_SETUP_RETEST_CONFIRMED;
  }

void Vegar_RC8ObserveClosedBar(const MqlRates &bar)
  {
   // Independent M1/M5 family. When aligned to M15 it is operational MICRO_CONTINUATION;
   // otherwise it remains observational telemetry only.
   // RC9: ha uma unica vaga de candidato micro. Um candidato sem autoridade
   // (so observacao) ainda antes do sweep cede a vaga para uma zona com
   // autoridade operacional; com RC8 ele bloqueava o candidato valido.
   if(gVegarObservationCandidate.active &&
      gVegarObservationCandidate.setup_family!=VEGAR_SETUP_FAMILY_MICRO_CONTINUATION &&
      gVegarObservationCandidate.state==VEGAR_SETUP_LIQUIDITY_APPROACH)
     {
      double dAuth=999.0; int ziAuth=Vegar_RC8ObservationBestZone(bar,dAuth,true);
      if(ziAuth>=0 && gVegarObservationZones[ziAuth].id!=gVegarObservationCandidate.zone_id)
        {
         Vegar_WriteDiagnostic("OBSERVATION_SLOT_PREEMPTED","REPLACED","NONE","",
                               "Old="+gVegarObservationCandidate.zone_id+"|New="+gVegarObservationZones[ziAuth].id);
         Vegar_RC8ResetObservationCandidate();
        }
     }
   if(!gVegarObservationCandidate.active)
     {
      double d=999.0; int zi=Vegar_RC8ObservationBestZone(bar,d,true);
      if(zi<0) zi=Vegar_RC8ObservationBestZone(bar,d,false);
      if(zi<0)return; Vegar_RC8ObservationStart(zi,bar);
      if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
         Vegar_RC8ObservationTelemetry("OPPORTUNITY_STARTED",VEGAR_SETUP_LIQUIDITY_APPROACH,VEGAR_REASON_NONE);
     }
   int zi=Vegar_FindObservationZoneIndex(gVegarObservationCandidate.zone_id);
   if(zi<0){Vegar_RC8ResetObservationCandidate();return;}
   SVegarZone z=gVegarObservationZones[zi];

   if(gVegarObservationCandidate.state==VEGAR_SETUP_LIQUIDITY_APPROACH)
     {
      bool deep=false;double ex=0.0;
      if(Vegar_SweepConfirmed(z,bar,deep,ex))
        {
         gVegarObservationCandidate.sweep_time=bar.time;
         gVegarObservationCandidate.sweep_extreme=ex;
         gVegarObservationCandidate.bars_since_sweep=0;
         gVegarObservationCandidate.sweep_same_bar_as_approach=(gVegarObservationCandidate.created_time==bar.time);
         gVegarObservationCandidate.source_zone_post_state=VEGAR_ZONE_SWEPT;
         gVegarObservationZones[zi].state=VEGAR_ZONE_SWEPT;
         gVegarObservationZones[zi].last_changed=TimeTradeServer();
         if(!Vegar_FindMSSLevel(gVegarObservationCandidate.direction,bar.time,ex,gVegarObservationCandidate.micro_break_level))
           {
            if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
               Vegar_RC8ObservationTelemetry("NO_MICRO_SWING",VEGAR_SETUP_EXPIRED,MSS_NOT_CONFIRMED);
            Vegar_RC8ResetObservationCandidate(); return;
           }
         gVegarObservationCandidate.state=VEGAR_SETUP_WAITING_MSS;
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
           {
            Vegar_RC8ObservationTelemetry("SWEEP_CONFIRMED",VEGAR_SETUP_SWEEP_CONFIRMED,VEGAR_REASON_NONE);
            Vegar_RC8ObservationTelemetry("WAITING_MSS",VEGAR_SETUP_WAITING_MSS,VEGAR_REASON_NONE);
           }
        }
      else if(deep)
        {
         gVegarObservationZones[zi].state=VEGAR_ZONE_INVALIDATED;
         gVegarObservationZones[zi].last_changed=TimeTradeServer();
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
            Vegar_RC8ObservationTelemetry("SWEEP_TOO_DEEP",VEGAR_SETUP_INVALIDATED_STATE,SWEEP_TOO_DEEP);
         Vegar_RC8ResetObservationCandidate();
        }
      return;
     }
   if(gVegarObservationCandidate.state==VEGAR_SETUP_WAITING_MSS)
     {
      gVegarObservationCandidate.bars_since_sweep++;
      double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
      double buf=MathMax(gVegarSymbol.tick_size,InpMSSBufferATR*atr);
      gVegarObservationCandidate.mss_required_level=(gVegarObservationCandidate.direction==VEGAR_BIAS_BUYER ? gVegarObservationCandidate.micro_break_level+buf : gVegarObservationCandidate.micro_break_level-buf);
      if(gVegarObservationCandidate.mss_best_observed==0.0 ||
         (gVegarObservationCandidate.direction==VEGAR_BIAS_BUYER && bar.close>gVegarObservationCandidate.mss_best_observed) ||
         (gVegarObservationCandidate.direction==VEGAR_BIAS_SELLER && bar.close<gVegarObservationCandidate.mss_best_observed))
         gVegarObservationCandidate.mss_best_observed=bar.close;
      gVegarObservationCandidate.mss_distance_missing=(gVegarObservationCandidate.direction==VEGAR_BIAS_BUYER ?
         MathMax(0.0,gVegarObservationCandidate.mss_required_level-gVegarObservationCandidate.mss_best_observed) :
         MathMax(0.0,gVegarObservationCandidate.mss_best_observed-gVegarObservationCandidate.mss_required_level));

      if(gVegarObservationCandidate.bars_since_sweep>InpMaxBarsSweepToMSS)
        {
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
            Vegar_RC8ObservationTelemetry("SWEEP_TO_MSS_EXPIRED",VEGAR_SETUP_EXPIRED,MSS_NOT_CONFIRMED);
         Vegar_RC8ResetObservationCandidate();return;
        }
      if(Vegar_MSSConfirmed(gVegarObservationCandidate.direction,bar,gVegarObservationCandidate.micro_break_level))
        {
         gVegarObservationCandidate.mss_time=bar.time;gVegarObservationCandidate.bars_since_mss=0;
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
            Vegar_RC8ObservationTelemetry("MSS_CONFIRMED",VEGAR_SETUP_MSS_CONFIRMED,VEGAR_REASON_NONE);

         double avg=Vegar_AvgRange(Vegar_ExecutionTF(),2,20),rng=bar.high-bar.low;
         gVegarObservationCandidate.displacement_required_range_ratio=InpDisplacementRangeMult;
         gVegarObservationCandidate.displacement_observed_range_ratio=(avg>0.0?rng/avg:0.0);
         gVegarObservationCandidate.displacement_required_close_location=(gVegarObservationCandidate.direction==VEGAR_BIAS_BUYER?0.75:0.25);
         gVegarObservationCandidate.displacement_observed_close_location=(rng>0.0?(bar.close-bar.low)/rng:0.0);
         if(Vegar_DisplacementConfirmed(gVegarObservationCandidate.direction,bar))
           {
            gVegarObservationCandidate.displacement_time=bar.time;gVegarObservationCandidate.state=VEGAR_SETUP_DISPLACEMENT_CONFIRMED;
            if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
               Vegar_RC8ObservationTelemetry("DISPLACEMENT_CONFIRMED",VEGAR_SETUP_DISPLACEMENT_CONFIRMED,VEGAR_REASON_NONE);
           }
         else
           {
            gVegarObservationCandidate.state=VEGAR_SETUP_WAITING_DISPLACEMENT;
            if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
               Vegar_RC8ObservationTelemetry("WAITING_DISPLACEMENT",VEGAR_SETUP_WAITING_DISPLACEMENT,VEGAR_REASON_NONE);
           }
        }
      return;
     }
   if(gVegarObservationCandidate.state==VEGAR_SETUP_WAITING_DISPLACEMENT)
     {
      gVegarObservationCandidate.bars_since_mss++;
      double avg=Vegar_AvgRange(Vegar_ExecutionTF(),2,20),rng=bar.high-bar.low;
      gVegarObservationCandidate.displacement_required_range_ratio=InpDisplacementRangeMult;
      gVegarObservationCandidate.displacement_observed_range_ratio=(avg>0.0?rng/avg:0.0);
      gVegarObservationCandidate.displacement_required_close_location=(gVegarObservationCandidate.direction==VEGAR_BIAS_BUYER?0.75:0.25);
      gVegarObservationCandidate.displacement_observed_close_location=(rng>0.0?(bar.close-bar.low)/rng:0.0);
      if(gVegarObservationCandidate.bars_since_mss>InpMaxBarsMssToDisplacement)
        {
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
            Vegar_RC8ObservationTelemetry("MSS_TO_DISPLACEMENT_EXPIRED",VEGAR_SETUP_EXPIRED,DISPLACEMENT_NOT_CONFIRMED);
         Vegar_RC8ResetObservationCandidate();return;
        }
      if(!Vegar_DisplacementConfirmed(gVegarObservationCandidate.direction,bar))return;
      gVegarObservationCandidate.displacement_time=bar.time;gVegarObservationCandidate.state=VEGAR_SETUP_DISPLACEMENT_CONFIRMED;
      if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
         Vegar_RC8ObservationTelemetry("DISPLACEMENT_CONFIRMED",VEGAR_SETUP_DISPLACEMENT_CONFIRMED,VEGAR_REASON_NONE);
     }
   if(gVegarObservationCandidate.state==VEGAR_SETUP_DISPLACEMENT_CONFIRMED)
     {
      double lo=0.0,hi=0.0;
      if(Vegar_CreateFVG(gVegarObservationCandidate.direction,lo,hi)) gVegarObservationCandidate.retest_type=VEGAR_RETEST_FVG;
      else if(Vegar_RC8ObservationOrderBlock(gVegarObservationCandidate.direction,gVegarObservationCandidate.displacement_time,gVegarObservationCandidate.sweep_time,lo,hi)) gVegarObservationCandidate.retest_type=VEGAR_RETEST_ORDER_BLOCK;
      else
        {
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
            Vegar_RC8ObservationTelemetry("NO_ENTRY_ZONE",VEGAR_SETUP_EXPIRED,NO_FVG_OR_OB);
         Vegar_RC8ResetObservationCandidate();return;
        }
      gVegarObservationCandidate.retest_low=lo;gVegarObservationCandidate.retest_high=hi;gVegarObservationCandidate.retest_mid=(lo+hi)*0.5;
      SVegarOpportunity temp; Vegar_RC8ObservationToOpportunity(temp); temp.state=VEGAR_SETUP_ENTRY_ZONE_CREATED; temp.sweep_time=gVegarObservationCandidate.sweep_time; temp.sweep_extreme=gVegarObservationCandidate.sweep_extreme;
      if(!Vegar_BuildStopsAndTargets(temp))
        {
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
            Vegar_RC8ObservationTelemetry("ECONOMIC_PREP_FAIL",VEGAR_SETUP_BLOCKED,ECONOMIC_TARGET_UNAVAILABLE);
         Vegar_RC8ResetObservationCandidate();return;
        }
      gVegarObservationCandidate.technical_stop=temp.technical_stop;gVegarObservationCandidate.technical_stop_money=temp.technical_stop_money;gVegarObservationCandidate.opposite_liquidity_price=temp.opposite_liquidity_price;gVegarObservationCandidate.expected_money_opposite=temp.expected_money_opposite;gVegarObservationCandidate.state=VEGAR_SETUP_WAITING_RETEST;
      if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
        {
         Vegar_RC8ObservationTelemetry(gVegarObservationCandidate.retest_type==VEGAR_RETEST_FVG?"FVG_CREATED":"OB_CREATED",VEGAR_SETUP_ENTRY_ZONE_CREATED,VEGAR_REASON_NONE);
         Vegar_RC8ObservationTelemetry("WAITING_RETEST",VEGAR_SETUP_WAITING_RETEST,VEGAR_REASON_NONE);
        }
      return;
     }
   if(gVegarObservationCandidate.state==VEGAR_SETUP_WAITING_RETEST)
     {
      gVegarObservationCandidate.bars_since_mss++;
      if(gVegarObservationCandidate.bars_since_mss>InpMaxBarsMssToRetest)
        {
         if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
            Vegar_RC8ObservationTelemetry("RETEST_EXPIRED",VEGAR_SETUP_EXPIRED,RETEST_EXPIRED);
         Vegar_RC8ResetObservationCandidate();return;
        }
      if(!Vegar_RetestConfirmed(gVegarObservationCandidate.direction,bar,gVegarObservationCandidate.retest_low,gVegarObservationCandidate.retest_high))return;
      gVegarObservationCandidate.retest_time=bar.time;Vegar_UpdateTick();gVegarObservationCandidate.hypothetical_entry_bid=gVegarTick.bid;gVegarObservationCandidate.hypothetical_entry_ask=gVegarTick.ask;
      if(gVegarObservationCandidate.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION)
         Vegar_RC8ObservationTelemetry("RETEST_CONFIRMED",VEGAR_SETUP_RETEST_CONFIRMED,VEGAR_REASON_NONE);
      Vegar_RC8ObservationFinishSignal();return;
     }
  }

void Vegar_RC8MarkOperationalApproachMetadata(SVegarOpportunity &opp)
  {
   opp.candidate_id=(opp.candidate_id==""?Vegar_NextID("CAND"):opp.candidate_id);
   opp.observation_candidate=false;
   opp.operational_eligible_at_approach=true;
   opp.approach_block_reason=VEGAR_REASON_NONE;
   opp.operational_approach_armed=true;
   if(gVegarObservationCandidate.active && gVegarObservationCandidate.zone_id==opp.focus_zone_id) Vegar_RC8ResetObservationCandidate();
  }

#endif
