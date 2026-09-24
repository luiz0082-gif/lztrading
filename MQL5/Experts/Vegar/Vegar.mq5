//+------------------------------------------------------------------+
//|                                                        Vegar.mq5 |
//|                   VEGAR - Quantitative Trading Expert Advisor    |
//|                   Internal EAVersion 1.01.0 / RC8                |
//+------------------------------------------------------------------+
#property strict
#property version   "1.01"
#property description "VEGAR - operational MTF liquidity, structure, flow and retest EA"

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
#include "Vegar_Profit.mqh"
#include "Vegar_Csv.mqh"
#include "Vegar_OpportunityReplay.mqh"
#include "Vegar_Persistence.mqh"
#include "Vegar_Execution.mqh"
#include "Vegar_Setup.mqh"
#include "Vegar_Visual.mqh"
#include "Vegar_Runtime.mqh"
#include "Vegar_Panel.mqh"
#include "Vegar_Diagnostics.mqh"

bool gVegarOperational=false;
bool gVegarTimeframeAllowed=false;
bool gVegarLeaseAcquired=false;
bool gVegarWaitingForData=false;
datetime gVegarLastTimerFlush=0;
ulong gVegarLastMaintenanceTimerMsc=0;
bool gVegarSessionTelemetryInitialized=false;
bool gVegarSessionTelemetryLastPass=false;
ENUM_VEGAR_REASON_CODE gVegarSessionTelemetryLastReason=VEGAR_REASON_NONE;
string gVegarSessionTelemetryLastLabel="";

void Vegar_SetBlocked(const ENUM_VEGAR_REASON_CODE reason,const string detail)
  {
   gVegarStats.last_block=Vegar_ReasonText(reason);
   Vegar_SetExecutionBlockedByReason(reason,detail);
   Vegar_WriteDiagnostic("OPERATION_BLOCK","BLOCKED",Vegar_ReasonText(reason),"",detail);
  }

void Vegar_RefreshExecutionStateRuntime()
  {
   if(gVegarEngineState==VEGAR_ENGINE_ERROR)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_ERROR,INTERNAL_ERROR,"ENGINE_ERROR");
      return;
     }
   if(gVegarEngineState==VEGAR_ENGINE_PAUSED)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_EXECUTION,ENGINE_PAUSED,"NOVAS ENTRADAS PAUSADAS");
      return;
     }
   if(!Vegar_EnvironmentAllowsTrading())
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_ACCOUNT,ACCOUNT_MODE_UNSUPPORTED,"AMBIENTE NAO SUPORTADO");
      return;
     }
   if(!gVegarTimeframeAllowed)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_DATA,TIMEFRAME_NOT_ALLOWED,"VEGAR REQUER GRAFICO M1 OU M5");
      return;
     }
   if(gVegarCriticalSelfTestFailed)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_SELF_TEST,SELF_TEST_FAILED,
                              StringFormat("UNIT_CRITICAL_FAILED=%d|PIPELINE_CRITICAL_FAILED=%d",gVegarSelfTestsCriticalFailed,gVegarPipelineTestsCriticalFailed));
      return;
     }
   if(gVegarConfigValidity!=VEGAR_CONFIG_VALID)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_CONFIGURATION,gVegarConfigReason,gVegarConfigDetail);
      return;
     }
   if(!gVegarLeaseAcquired)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_ACCOUNT,DUPLICATE_INSTANCE,"INSTANCE LEASE INDISPONIVEL");
      return;
     }
   if(!gVegarRecoveryComplete)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_RECOVERY,BLOCKED_RECOVERY,gVegarRecoveryDetail);
      return;
     }
   if(gVegarOwnershipAmbiguous)
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_OWNERSHIP,BLOCKED_OWNERSHIP_AMBIGUOUS,gVegarRecoveryDetail);
      return;
     }

   ENUM_VEGAR_REASON_CODE dataReason=VEGAR_REASON_NONE;
   if(!gVegarOperational || !Vegar_AllRequiredDataReady(dataReason))
     {
      if(dataReason==VEGAR_REASON_NONE) dataReason=DATA_NOT_READY;
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_DATA,dataReason,"DADOS/INDICADORES AINDA NAO PRONTOS");
      return;
     }

   if(Vegar_HasOwnedPosition())
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_POSITION,POSITION_EXISTS,"POSICAO VEGAR EM GERENCIAMENTO");
      return;
     }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_EXECUTION,TRADING_DISABLED,"MQL_TRADE_ALLOWED=FALSE");
      return;
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_EXECUTION,AUTOTRADING_DISABLED,"TERMINAL_TRADE_ALLOWED=FALSE");
      return;
     }

   Vegar_SetExecutionState(VEGAR_EXECUTION_ENABLED,VEGAR_REASON_NONE,"READY");
  }

void Vegar_EmitSessionGateTelemetry()
  {
   ENUM_VEGAR_REASON_CODE reason=VEGAR_REASON_NONE;
   SVegarSessionStatus status;
   bool pass=Vegar_SessionGateAllowsEntry(reason,status);

   if(gVegarSessionTelemetryInitialized &&
      pass==gVegarSessionTelemetryLastPass &&
      reason==gVegarSessionTelemetryLastReason &&
      status.label==gVegarSessionTelemetryLastLabel)
      return;

   gVegarSessionTelemetryInitialized=true;
   gVegarSessionTelemetryLastPass=pass;
   gVegarSessionTelemetryLastReason=reason;
   gVegarSessionTelemetryLastLabel=status.label;

   string detail="Filter="+(InpAtivarFiltroDeSessao?"ON":"OFF")+
                 "|Session="+status.label+
                 "|London="+(status.london?"1":"0")+
                 "|NewYork="+(status.new_york?"1":"0");

   if(pass)
      Vegar_WriteDiagnostic("SESSION_GATE_PASS","PASS","NONE","",detail);
   else
      Vegar_WriteDiagnostic("SESSION_GATE_BLOCK","BLOCKED",Vegar_ReasonText(reason),"",detail);
  }

void Vegar_WriteObjectStateDeltas()
  {
   // Iteration is allowed; Vegar_ObjectShouldWrite() emits only actual deltas or the configured heartbeat.
   // This routine never republishes unchanged entities on each execution bar.
   for(int i=0;i<ArraySize(gVegarZones);i++)
      if(gVegarZones[i].valid)
         Vegar_WriteObjectState(gVegarZones[i]);
   for(int i=0;i<ArraySize(gVegarObservationZones);i++)
      if(gVegarObservationZones[i].valid)
         Vegar_WriteObjectState(gVegarObservationZones[i]);
   if(gVegarHasSupersededChannelH4) Vegar_WriteChannelObjectState(gVegarSupersededChannelH4);
   if(gVegarHasSupersededChannelM15) Vegar_WriteChannelObjectState(gVegarSupersededChannelM15);
   if(gVegarChannelH4.valid) Vegar_WriteChannelObjectState(gVegarChannelH4);
   if(gVegarChannelM15.valid) Vegar_WriteChannelObjectState(gVegarChannelM15);
  }

void Vegar_WriteAllObjectStates()
  {
   // Startup/rebuild snapshot entry point. The same fingerprint guard prevents duplicate rows.
   Vegar_WriteObjectStateDeltas();
  }

void Vegar_ProcessCandleSnapshot(const ENUM_TIMEFRAMES tf,const int shift,const bool backfill)
  {
   MqlRates b;
   if(!Vegar_GetBar(tf,shift,b)) return;

   SVegarFlowSnapshot flow=Vegar_CalcFlowAtShift(tf,shift);
   SVegarChannel c;
   ZeroMemory(c);
   c.tf=tf;
   c.direction=VEGAR_CHANNEL_NEUTRAL;

   ENUM_VEGAR_M15_CONTEXT ctx=VEGAR_M15_UNKNOWN;
   string focus="";
   double strength=0.0;
   ENUM_VEGAR_SETUP_STATE st=VEGAR_SETUP_IDLE;

   if(!backfill)
     {
      if(tf==PERIOD_H4) c=gVegarChannelH4;
      else if(tf==PERIOD_M15) c=gVegarChannelM15;
      else c=Vegar_BuildChannel(tf);

      int zi=Vegar_FocusZoneIndex();
      strength=(zi>=0?gVegarZones[zi].strength_score:0.0);
      focus=gVegarFocusZoneID;
      ctx=gVegarM15Context;
      st=gVegarOpportunity.state;
     }

   Vegar_WriteCandleSnapshot(tf,b,flow,ctx,focus,strength,c,st);
   if(backfill)
      Vegar_WriteDiagnostic("CANDLE_BACKFILL","RAW_SAFE","NONE","",
                            Vegar_TFText(tf)+" "+Vegar_TimeIso(b.time)+" derived context intentionally not reconstructed with future state");
  }

void Vegar_ProcessIntentIfAny()
  {
   if(!gVegarIntent.valid || gVegarIntent.processed) return;

   if(gVegarEngineState!=VEGAR_ENGINE_ACTIVE)
     {
      gVegarStats.last_block="ENGINE_PAUSED";
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_EXECUTION,ENGINE_PAUSED,"NOVAS ENTRADAS PAUSADAS");
      Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,ENGINE_PAUSED,"ENGINE_PAUSED");
      gVegarIntent.processed=true;
      return;
     }

   if(gVegarCriticalSelfTestFailed)
     {
      gVegarStats.last_block=Vegar_ReasonText(SELF_TEST_FAILED);
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_SELF_TEST,SELF_TEST_FAILED,
                              StringFormat("UNIT_CRITICAL_FAILED=%d|PIPELINE_CRITICAL_FAILED=%d",gVegarSelfTestsCriticalFailed,gVegarPipelineTestsCriticalFailed));
      Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,SELF_TEST_FAILED,"SELF_TEST_BLOCK");
      gVegarIntent.processed=true;
      return;
     }

   if(gVegarConfigValidity!=VEGAR_CONFIG_VALID)
     {
      gVegarStats.last_block=Vegar_ReasonText(gVegarConfigReason);
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_CONFIGURATION,gVegarConfigReason,gVegarConfigDetail);
      Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,gVegarConfigReason,"CONFIGURATION_BLOCK");
      gVegarIntent.processed=true;
      return;
     }

   SVegarRiskSnapshot risk;
   bool riskPass=Vegar_RiskEvaluate(gVegarOpportunity,risk);
   Vegar_WriteRiskState(risk,gVegarOpportunity,gVegarIntent.intent_id);
   if(!riskPass)
     {
      gVegarStats.last_block=Vegar_ReasonText(risk.reason);
      Vegar_RC8MarkMarkerBlockedLater(risk.reason,"RiskGate");
      Vegar_SetExecutionBlockedByReason(risk.reason,"RISK_OR_ECONOMIC_BLOCK");
      Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,risk.reason,"RISK_OR_ECONOMIC_BLOCK");
      gVegarIntent.processed=true;
      return;
     }

   gVegarOpportunity.technical_stop=risk.technical_stop_price;
   gVegarOpportunity.technical_stop_money=risk.technical_stop_money;
   gVegarIntent.stop_price=risk.technical_stop_price;
   gVegarIntent.stop_money=risk.technical_stop_money;
   gVegarIntent.economic_target_money=risk.economic_target_money;

   Vegar_DrawTradeLevels(gVegarIntent);

   Vegar_SetOpportunityState(VEGAR_SETUP_PREFLIGHT,VEGAR_REASON_NONE,"PREFLIGHT");
   SVegarExecutionResult x;
   bool ok=Vegar_ExecuteIntent(gVegarIntent,risk,x);
   if(x.order_check_called)
     {
      bool ocpass=(x.order_check_retcode==TRADE_RETCODE_DONE || x.order_check_retcode==TRADE_RETCODE_PLACED);
      Vegar_RC8SetOpportunityGate(gVegarOpportunity,"OrderCheckGate",ocpass?VEGAR_GATE_PASS:VEGAR_GATE_FAIL);
      Vegar_RC8LogGate(gVegarOpportunity,"OrderCheckGate",ocpass?VEGAR_GATE_PASS:VEGAR_GATE_FAIL,ocpass?VEGAR_REASON_NONE:ORDER_CHECK_REJECTED);
      Vegar_SetOpportunityState(VEGAR_SETUP_PREFLIGHT,ocpass?VEGAR_REASON_NONE:ORDER_CHECK_REJECTED,"ORDERCHECK");
     }
   Vegar_WriteExecution("EXECUTION",gVegarIntent,x);
   if(gVegarExecutionRequest.valid)
      Vegar_WriteDiagnostic("EXECUTION_REQUEST_FROZEN",x.request_accepted?"SENT":"CHECKED",Vegar_ReasonText(x.reason),gVegarIntent.intent_id,
                            "RequestHash="+gVegarExecutionRequest.request_hash+"|OrderCheckRetcode="+(string)gVegarExecutionRequest.order_check_retcode+
                            "|EstimatedCosts="+DoubleToString(gVegarExecutionRequest.estimated_costs,2)+"|SpreadMoney="+DoubleToString(gVegarExecutionRequest.economic_spread_money,2)+
                            "|ExpectedRewardNet="+DoubleToString(gVegarExecutionRequest.expected_reward_net,2));
   Vegar_RC8UpdateMarkerAfterExecution(x,gVegarIntent);

   if(!ok)
     {
      gVegarStats.last_block=Vegar_ReasonText(x.reason);
      Vegar_SetExecutionBlockedByReason(x.reason,"PREFLIGHT_OR_SEND_REJECTED");
      Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,x.reason,"PREFLIGHT_OR_SEND_REJECTED");
      return;
     }

   gVegarOpportunity.pipeline_state="ORDERSEND";
   Vegar_SetOpportunityState(VEGAR_SETUP_ORDER_REQUEST,VEGAR_REASON_NONE,"ORDERSEND");
   Vegar_ReplayQueue(gVegarOpportunity);
   gVegarOpportunity.active=false;
  }

void Vegar_ManageOwnedPosition()
  {
   ulong ticket=0;
   long pid=0;
   ENUM_VEGAR_BIAS d=VEGAR_BIAS_NONE;
   double entry=0.0,vol=0.0;

   if(!Vegar_FindOwnedPosition(ticket,pid,d,entry,vol)) return;

   if(gVegarOpportunity.opportunity_id!="" && gVegarOpportunity.state!=VEGAR_SETUP_POSITION_MANAGEMENT)
      Vegar_SetOpportunityState(VEGAR_SETUP_POSITION_MANAGEMENT,VEGAR_REASON_NONE,"POSITION_MANAGEMENT");

   if(!gVegarProfit.active || gVegarProfit.position_ticket!=ticket)
      Vegar_ProfitAttach(ticket,pid,d,entry,vol);

   double oldPeak=gVegarProfit.peak_profit_money;
   double oldFloor=gVegarProfit.protected_profit_money;
   bool oldRunner=gVegarProfit.runner_active;

   Vegar_ProfitUpdateFromSelectedPosition();

   if(oldPeak!=gVegarProfit.peak_profit_money ||
      oldFloor!=gVegarProfit.protected_profit_money ||
      oldRunner!=gVegarProfit.runner_active)
     {
      Vegar_WriteProfitManagement(gVegarProfit,"PROFIT_UPDATE");
      Vegar_SaveOperationalState();
     }

   if(gVegarProfit.software_exit_requested)
     {
      if(Vegar_CloseOwnedPosition(gVegarProfit.exit_reason))
         gVegarProfit.software_exit_requested=false;
     }
  }

bool Vegar_ActivateOperationalCore()
  {
   ENUM_VEGAR_REASON_CODE dataReason=VEGAR_REASON_NONE;
   if(!Vegar_AllRequiredDataReady(dataReason))
     {
      gVegarWaitingForData=true;
      gVegarOperational=false;
      string readiness=Vegar_DataReadinessDetail();
      Vegar_SetBlocked(dataReason,"Required H4/M15/M5/M1 history not ready/synchronized | "+readiness);
      PrintFormat("[VEGAR] INIT_WAIT_DATA: %s | %s",Vegar_ReasonText(dataReason),readiness);
      return false;
     }

   gVegarWaitingForData=false;

   // RC8 startup safety order: reconcile broker/history/persistence first, then clean only VEGAR visuals.
   Vegar_ReconcileOperationalState();
   Vegar_RC8StartupCleanup();
   Vegar_UpdateNews();
   Vegar_RebuildLiquidityMap();
   Vegar_RebuildObservationLiquidity();
   Vegar_UpdateChannels();
   Vegar_UpdateM15Context(false);
   Vegar_SelectFocusZone(gVegarM15Context);
   Vegar_ResetOpportunity();
   Vegar_RC8ResetObservationCandidate();

   gVegarLastBarH4=iTime(_Symbol,PERIOD_H4,1);
   gVegarLastBarM15=iTime(_Symbol,PERIOD_M15,1);
   gVegarLastBarM5=iTime(_Symbol,PERIOD_M5,1);
   gVegarLastBarM1=iTime(_Symbol,PERIOD_M1,1);

   Vegar_WriteRunConfig();

   if(InpComissaoRoundTurnPorLoteMoney<=0.0)
      Vegar_WriteDiagnostic("COMMISSION_MODEL_UNDEFINED","OBSERVE_ONLY",
                            Vegar_ReasonText(COMMISSION_MODEL_UNDEFINED),"",
                            "Opportunity Replay will mark CostModelIncomplete=true");

   Vegar_WriteAllObjectStates();
   if(InpExecutarSelfTests)
      Vegar_RunSelfTests();
   else
     {
      gVegarSelfTestsCompleted=false;
      gVegarCriticalSelfTestFailed=false;
      Vegar_WriteDiagnostic("SELF_TEST_SUMMARY","SKIPPED","NONE","",
                            "Self-tests disabled by input; no self-test execution authority asserted");
     }

   gVegarOperational=true;
   gVegarStats.last_block="";

   Vegar_RefreshExecutionStateRuntime();
   Vegar_RefreshVisuals();
   Vegar_RC8DrawRecoveredPositionVisual();
   Vegar_PanelUpdate();

   Vegar_RC8WriteContextJournal();
   Vegar_WriteDiagnostic("CONTEXT_CHANGE_COMPLETE","READY","NONE","",
                         "Symbol="+_Symbol+"|ExecutionTF="+Vegar_TFText(Vegar_ExecutionTF())+
                         "|Zones="+(string)ArraySize(gVegarZones)+"|ObservationZones="+(string)ArraySize(gVegarObservationZones));
   Vegar_WriteDiagnostic("INIT","READY","NONE","",
                         "VEGAR operational core ready | Environment="+Vegar_EnvironmentText(gVegarEnvironment)+
                         " | ExecutionState="+Vegar_ExecutionStateText(gVegarExecutionState));
   return true;
  }

int OnInit()
  {
   ZeroMemory(gVegarStats);

   gVegarEngineState=VEGAR_ENGINE_ACTIVE;
   gVegarExecutionState=VEGAR_EXECUTION_BLOCKED_CONFIGURATION;
   gVegarExecutionReason=EXECUTION_BLOCKED_CONFIGURATION;
   gVegarExecutionDetail="INIT";

   bool environmentOk=Vegar_DetectEnvironment();

   Vegar_RefreshConfigHashes();
   gVegarRunID=Vegar_MakeRunID();
   gVegarInstanceID=Vegar_MakeInstanceID();
   gVegarTimeframeAllowed=(_Period==PERIOD_M1 || _Period==PERIOD_M5);

   PrintFormat("[VEGAR][BUILD] BuildID=%s | EAVersion=%s | SchemaVersion=%d | Symbol=%s | TF=%s | Environment=%s",
               VEGAR_BUILD_ID,VEGAR_EA_VERSION,VEGAR_SCHEMA_VERSION,_Symbol,
               EnumToString((ENUM_TIMEFRAMES)_Period),Vegar_EnvironmentText(gVegarEnvironment));

   if(!Vegar_DataInit())
     {
      gVegarEngineState=VEGAR_ENGINE_ERROR;
      Vegar_SetExecutionState(VEGAR_EXECUTION_ERROR,INTERNAL_ERROR,"SYMBOL_METADATA_OR_ATR_HANDLE_INIT_FAILED");
      Print("[VEGAR] INIT_FAILED: symbol metadata / ATR handles unavailable");
      return INIT_FAILED;
     }

   Vegar_RC8LogContextChangeStarted();
   Vegar_ResetMarketContext();

   gVegarConfigValidity=Vegar_ValidateConfiguration(gVegarConfigReason,gVegarConfigDetail);

   if(!environmentOk)
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_ACCOUNT,ACCOUNT_MODE_UNSUPPORTED,"Only TESTER/DEMO/REAL are supported");
   else if(!gVegarTimeframeAllowed)
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_DATA,TIMEFRAME_NOT_ALLOWED,"VEGAR REQUER GRAFICO M1 OU M5");
   else if(gVegarConfigValidity!=VEGAR_CONFIG_VALID)
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_CONFIGURATION,gVegarConfigReason,gVegarConfigDetail);
   else
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_DATA,DATA_NOT_READY,"INITIAL_DATA_WARMUP");

   Vegar_UpdateTick();
   EventSetMillisecondTimer(250);
   Vegar_PanelInit();

   string startDetail=
      "Environment="+Vegar_EnvironmentText(gVegarEnvironment)+
      "|AccountTradeMode="+(string)gVegarAccountTradeMode+
      "|IsTester="+(gVegarIsTester?"1":"0")+
      "|IsOptimization="+(gVegarIsOptimization?"1":"0")+
      "|Symbol="+_Symbol+
      "|ExecutionTF="+Vegar_TFText(Vegar_ExecutionTF())+
      "|Magic="+(string)InpMagicNumber+
      "|EAVersion="+VEGAR_EA_VERSION+
      "|BuildID="+VEGAR_BUILD_ID+
      "|SchemaVersion="+(string)VEGAR_SCHEMA_VERSION+
      "|ConfigHash="+gVegarConfigHash+
      "|StrategyConfigHash="+gVegarStrategyConfigHash+
      "|TelemetryConfigHash="+gVegarTelemetryConfigHash+
      "|VisualConfigHash="+gVegarVisualConfigHash+
      "|EngineState="+Vegar_EngineStateText(gVegarEngineState)+
      "|ExecutionState="+Vegar_ExecutionStateText(gVegarExecutionState)+
      "|SessionFilter="+(InpAtivarFiltroDeSessao?"1":"0");

   Vegar_WriteDiagnostic("VEGAR_START","START",environmentOk?"NONE":"ACCOUNT_MODE_UNSUPPORTED","",startDetail);

   if(gVegarEnvironment==VEGAR_ENV_REAL)
      Vegar_WriteDiagnostic("ENVIRONMENT_REAL_CONFIRMED","DETECTED","NONE","",
                            "ACCOUNT_TRADE_MODE_REAL detected automatically");

   if(!environmentOk)
      Vegar_SetBlocked(ACCOUNT_MODE_UNSUPPORTED,"Only TESTER/DEMO/REAL are supported");

   if(!gVegarTimeframeAllowed)
     {
      Vegar_SetBlocked(TIMEFRAME_NOT_ALLOWED,"VEGAR REQUER GRÁFICO M1 OU M5");
      Vegar_WriteRunConfig();
      Vegar_PanelUpdate();
      return INIT_SUCCEEDED;
     }

   if(!Vegar_AcquireInstanceLease())
     {
      Vegar_SetBlocked(DUPLICATE_INSTANCE,"Account+Symbol+Magic already active on another chart");
      Vegar_WriteRunConfig();
      Vegar_PanelUpdate();
      return INIT_SUCCEEDED;
     }

   gVegarLeaseAcquired=true;

   if(!Vegar_ActivateOperationalCore())
     {
      Vegar_WriteRunConfig();
      Vegar_WriteDiagnostic("INIT_WAIT_DATA","BLOCKED",gVegarStats.last_block,"",
                            "EA remains attached and retries data readiness from OnTimer");
      Vegar_PanelUpdate();
      return INIT_SUCCEEDED;
     }

   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();

   if(gVegarOpportunity.active)
      Vegar_WriteDiagnostic("SETUP_ABORTED_BY_REINIT","ABORTED",
                            Vegar_ReasonText(SETUP_ABORTED_BY_REINIT),"",
                            StringFormat("DeinitReason=%d Opportunity=%s",reason,gVegarOpportunity.opportunity_id));

   if(Vegar_HasOwnedPosition()) Vegar_SaveOperationalState();
   else Vegar_ClearOperationalState();

   Vegar_RC8WriteContextJournal();

   Vegar_WriteDiagnostic("DEINIT","STOP","NONE","",StringFormat("Reason=%d",reason));

   if(gVegarLeaseAcquired) Vegar_ReleaseInstanceLease();
   gVegarLeaseAcquired=false;

   Vegar_PanelDelete();
   Vegar_DeleteVisualObjects();
   Vegar_DataDeinit();
  }

void OnTick()
  {
   if(!Vegar_UpdateTick()) return;

   // Position management has priority and remains active even when new entries are paused/blocked.
   if(Vegar_HasOwnedPosition()) Vegar_ManageOwnedPosition();
   // RC8 Live Approach latch is observational only: it remembers location contact without confirming sweep/signal.
   Vegar_UpdateLiveApproachLatch();
   Vegar_RC8UpdateMomentState();

   if(!gVegarTimeframeAllowed) return;

   if(InpAtivarIntrabarTrace && gVegarOpportunity.active)
      Vegar_WriteIntrabarTrace(gVegarOpportunity.opportunity_id,gVegarOpportunity.state);

   if(!gVegarOperational) return;

   int shH4[],shM15[],shM5[],shM1[];
   int nH4=Vegar_GetNewClosedBarShifts(PERIOD_H4,gVegarLastBarH4,shH4);
   int nM15=Vegar_GetNewClosedBarShifts(PERIOD_M15,gVegarLastBarM15,shM15);
   int nM5=Vegar_GetNewClosedBarShifts(PERIOD_M5,gVegarLastBarM5,shM5);
   int nM1=Vegar_GetNewClosedBarShifts(PERIOD_M1,gVegarLastBarM1,shM1);

   bool newH4=(nH4>0);
   bool newM15=(nM15>0);
   bool newM5=(nM5>0);
   bool newM1=(nM1>0);

   if(newM1 || newM5) Vegar_RebuildObservationLiquidity();

   if(newH4 || newM15)
     {
      Vegar_RebuildLiquidityMap();
      Vegar_UpdateChannels();
      Vegar_UpdateM15Context(newM15);
      Vegar_SelectFocusZone(gVegarM15Context);
      Vegar_WriteObjectStateDeltas();
     }

   for(int i=0;i<nH4;i++) Vegar_ProcessCandleSnapshot(PERIOD_H4,shH4[i],shH4[i]!=1);
   for(int i=0;i<nM15;i++) Vegar_ProcessCandleSnapshot(PERIOD_M15,shM15[i],shM15[i]!=1);
   for(int i=0;i<nM5;i++) Vegar_ProcessCandleSnapshot(PERIOD_M5,shM5[i],shM5[i]!=1);
   for(int i=0;i<nM1;i++) Vegar_ProcessCandleSnapshot(PERIOD_M1,shM1[i],shM1[i]!=1);

   bool newExec=(Vegar_ExecutionTF()==PERIOD_M1?newM1:newM5);

   if(newExec)
     {
      ENUM_VEGAR_REASON_CODE dr=VEGAR_REASON_NONE;
      if(!Vegar_AllRequiredDataReady(dr))
        {
         Vegar_SetBlocked(dr,"Runtime data gate");
         return;
        }

      if(!Vegar_HasOwnedPosition() && gVegarEngineState==VEGAR_ENGINE_ACTIVE)
        {
         Vegar_ProcessSetupOnClosedBar();
         Vegar_ProcessIntentIfAny();
         Vegar_WriteObjectStateDeltas();
        }

      int zi=Vegar_FocusZoneIndex();
      double dist=0.0;
      if(zi>=0) Vegar_IsWithinApproach(gVegarZones[zi],dist);

      SVegarSessionStatus session=Vegar_CurrentSessionStatus();
      // MARKET_STATE keeps every gate in its own field. Economic gates are not used to create Candidate/Opportunity.
      Vegar_WriteMarketState(gVegarChannelH4,gVegarChannelM15,gVegarExecutionFlow,
                             gVegarM15Context,gVegarFocusZoneID,dist,session,gVegarNewsStatus);

      Vegar_RefreshVisuals();
     }

   Vegar_RefreshExecutionStateRuntime();
  }

void OnTimer()
  {
   Vegar_UpdateTick();

   // RC8 UX timer: 250 ms supports button press animation without Sleep().
   Vegar_PanelUpdateActionAnimation();
   Vegar_RC8UpdateMomentState();

   ulong now_msc=GetTickCount64();
   bool maintenance=(gVegarLastMaintenanceTimerMsc==0 || now_msc-gVegarLastMaintenanceTimerMsc>=1000);
   if(maintenance)
     {
      gVegarLastMaintenanceTimerMsc=now_msc;

      if(gVegarTimeframeAllowed && gVegarLeaseAcquired && !gVegarOperational)
        {
         ENUM_VEGAR_REASON_CODE dataReason=VEGAR_REASON_NONE;
         if(Vegar_AllRequiredDataReady(dataReason))
           {
            Vegar_WriteDiagnostic("DATA_READY_RETRY","PASS","NONE","",
                                  "Historical series and ATR buffers synchronized; activating operational core");
            Vegar_ActivateOperationalCore();
           }
         else
           {
            gVegarWaitingForData=true;
            gVegarStats.last_block=Vegar_ReasonText(dataReason);
            Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_DATA,dataReason,Vegar_DataReadinessDetail());
           }
        }

      Vegar_UpdateNews();
      Vegar_ReplayProcess();
      Vegar_EmitSessionGateTelemetry();

      if(Vegar_HasOwnedPosition()) Vegar_SaveOperationalState();
      Vegar_RefreshExecutionStateRuntime();
     }

   // Panel refresh is lightweight and deliberately runs at the UI timer cadence.
   Vegar_PanelUpdate();
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   Vegar_HandleTradeTransaction(trans,request,result);
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD && trans.deal>0)
     {
      Vegar_RC8ConfirmMarkerDeal(trans.deal);
      if(HistoryDealSelect(trans.deal) && HistoryDealGetString(trans.deal,DEAL_SYMBOL)==_Symbol && Vegar_DealLooksOwned(trans.deal))
        {
         ENUM_DEAL_ENTRY pe=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         if(pe==DEAL_ENTRY_IN && gVegarProfit.active)
           {
            long ppid=(long)HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);
            gVegarProfit.trade_cycle_id="TC_"+(string)ppid;
            gVegarProfit.intent_id=gVegarIntent.intent_id;
            gVegarProfit.opportunity_id=gVegarOpportunity.opportunity_id;
            gVegarProfit.setup_id=gVegarOpportunity.setup_id;
            gVegarProfit.focus_zone_id=gVegarOpportunity.focus_zone_id;
            gVegarProfit.technical_stop=gVegarIntent.stop_price;
            gVegarProfit.take_profit=gVegarIntent.take_profit_price;
            Vegar_SaveOperationalState();
           }
        }
     }

   if(trans.type==TRADE_TRANSACTION_DEAL_ADD && trans.deal>0 && HistoryDealSelect(trans.deal))
     {
      if(HistoryDealGetString(trans.deal,DEAL_SYMBOL)==_Symbol && Vegar_DealLooksOwned(trans.deal))
        {
         gVegarStats.last_deal_ticket=trans.deal;
         if(trans.position>0) gVegarStats.last_position_ticket=trans.position;

         ENUM_DEAL_ENTRY e=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         ENUM_DEAL_TYPE dt=(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         ENUM_VEGAR_BIAS d=(dt==DEAL_TYPE_BUY?VEGAR_BIAS_BUYER:VEGAR_BIAS_SELLER);

         if(e==DEAL_ENTRY_IN)
           {
            Vegar_DrawEvent("ENTRY",(datetime)HistoryDealGetInteger(trans.deal,DEAL_TIME),
                            HistoryDealGetDouble(trans.deal,DEAL_PRICE),d);
            if(gVegarOpportunity.opportunity_id!="")
               Vegar_SetOpportunityState(VEGAR_SETUP_POSITION_OPEN,VEGAR_REASON_NONE,"POSITION_OPEN");
           }
         else if(e==DEAL_ENTRY_OUT || e==DEAL_ENTRY_OUT_BY)
           {
            Vegar_DrawEvent("EXIT",(datetime)HistoryDealGetInteger(trans.deal,DEAL_TIME),
                            HistoryDealGetDouble(trans.deal,DEAL_PRICE),d);
            Vegar_RC8RecordMarkerRealOutcome(trans.deal);
            if(gVegarOpportunity.opportunity_id!="")
               Vegar_SetOpportunityState(VEGAR_SETUP_POSITION_CLOSED,VEGAR_REASON_NONE,"POSITION_CLOSED");
           }
        }
     }

   Vegar_RefreshExecutionStateRuntime();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   Vegar_PanelHandleChartEvent(id,lparam,dparam,sparam);
  }
