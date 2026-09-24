#ifndef __VEGAR_EXECUTION_MQH__
#define __VEGAR_EXECUTION_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Time.mqh"
#include "Vegar_News.mqh"
#include "Vegar_Risk.mqh"
#include "Vegar_Profit.mqh"
#include "Vegar_Persistence.mqh"
#include "Vegar_Csv.mqh"

SVegarExecutionRequest gVegarExecutionRequest;

void Vegar_ResetExecutionRequest()
  {
   ZeroMemory(gVegarExecutionRequest);
  }

double Vegar_InitialStopPriceForRequest(const double technical_stop,const bool enabled)
  {
   return (enabled && technical_stop>0.0 ? Vegar_NormalizePriceToTick(technical_stop) : 0.0);
  }

ENUM_ORDER_TYPE_FILLING Vegar_SelectFillingMode()
  {
   long f=gVegarSymbol.filling_flags;
   if((f & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) return ORDER_FILLING_FOK;
   if((f & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC) return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
  }

bool Vegar_ExecutionAuthorization(ENUM_VEGAR_REASON_CODE &reason)
  {
   reason=VEGAR_REASON_NONE;
   if(!Vegar_RecoveryAllowsTrading()) { reason=(gVegarOwnershipAmbiguous?BLOCKED_OWNERSHIP_AMBIGUOUS:BLOCKED_RECOVERY); return false; }
   if(gVegarEngineState==VEGAR_ENGINE_PAUSED) { reason=ENGINE_PAUSED; return false; }
   if(gVegarEngineState==VEGAR_ENGINE_ERROR) { reason=ORDER_REQUEST_NOT_ALLOWED; return false; }
   if(gVegarEnvironment==VEGAR_ENV_TESTER || gVegarEnvironment==VEGAR_ENV_DEMO || gVegarEnvironment==VEGAR_ENV_REAL)
      return true;
   reason=ACCOUNT_MODE_UNSUPPORTED;
   return false;
  }

bool Vegar_SymbolTradeAvailable(const ENUM_VEGAR_BIAS direction,ENUM_VEGAR_REASON_CODE &reason)
  {
   ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   if(mode==SYMBOL_TRADE_MODE_DISABLED || mode==SYMBOL_TRADE_MODE_CLOSEONLY) { reason=MARKET_CLOSED; return false; }
   if(mode==SYMBOL_TRADE_MODE_LONGONLY && direction!=VEGAR_BIAS_BUYER) { reason=MARKET_CLOSED; return false; }
   if(mode==SYMBOL_TRADE_MODE_SHORTONLY && direction!=VEGAR_BIAS_SELLER) { reason=MARKET_CLOSED; return false; }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) { reason=TRADING_DISABLED; return false; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) { reason=AUTOTRADING_DISABLED; return false; }
   reason=VEGAR_REASON_NONE; return true;
  }

bool Vegar_CheckPositionConflict(ENUM_VEGAR_REASON_CODE &reason)
  {
   if(Vegar_HasAmbiguousVegarPosition()) { reason=BLOCKED_OWNERSHIP_AMBIGUOUS; return false; }
   if(Vegar_HasOwnedPosition()) { reason=POSITION_EXISTS; return false; }
   ENUM_ACCOUNT_MARGIN_MODE mm=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mm!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Vegar_HasExternalPositionOnSymbol())
     { reason=NETTING_EXTERNAL_POSITION; return false; }
   reason=VEGAR_REASON_NONE; return true;
  }

bool Vegar_StopsValidForEntry(const ENUM_VEGAR_BIAS direction,const double entry,const double sl,const double tp,ENUM_VEGAR_REASON_CODE &reason)
  {
   if(entry<=0.0) { reason=STOPS_INVALID; return false; }
   if(InpAtivarStopLoss && sl<=0.0) { reason=STOPS_INVALID; return false; }
   double minDist=(double)gVegarSymbol.stops_level_points*gVegarSymbol.point;
   double freezeDist=(double)gVegarSymbol.freeze_level_points*gVegarSymbol.point;
   if(direction==VEGAR_BIAS_BUYER)
     {
      if(InpAtivarStopLoss && (sl>=entry || entry-sl<minDist)) { reason=STOPS_INVALID; return false; }
      if(tp>0.0 && (tp<=entry || tp-entry<minDist)) { reason=STOPS_INVALID; return false; }
      if(InpAtivarStopLoss && sl>0.0 && entry-sl<freezeDist) { reason=FREEZE_LEVEL_BLOCK; return false; }
      if(tp>0.0 && tp-entry<freezeDist) { reason=FREEZE_LEVEL_BLOCK; return false; }
     }
   else
     {
      if(InpAtivarStopLoss && (sl<=entry || sl-entry<minDist)) { reason=STOPS_INVALID; return false; }
      if(tp>0.0 && (tp>=entry || entry-tp<minDist)) { reason=STOPS_INVALID; return false; }
      if(InpAtivarStopLoss && sl>0.0 && sl-entry<freezeDist) { reason=FREEZE_LEVEL_BLOCK; return false; }
      if(tp>0.0 && entry-tp<freezeDist) { reason=FREEZE_LEVEL_BLOCK; return false; }
     }
   reason=VEGAR_REASON_NONE; return true;
  }

bool Vegar_BuildTradeRequest(SVegarIntent &intent,MqlTradeRequest &req)
  {
   ZeroMemory(req);
   if(!Vegar_UpdateTick()) return false;
   req.action=TRADE_ACTION_DEAL;
   req.symbol=_Symbol;
   req.magic=(ulong)InpMagicNumber;
   req.volume=intent.requested_volume;
   req.type=(intent.direction==VEGAR_BIAS_BUYER?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
   req.price=(intent.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid);
   req.sl=Vegar_InitialStopPriceForRequest(intent.stop_price,InpAtivarStopLoss);
   req.tp=(intent.take_profit_price>0.0?Vegar_NormalizePriceToTick(intent.take_profit_price):0.0);
   req.deviation=(ulong)MathMax(0,MathRound((double)InpDesvioMaxExecucaoTicks*gVegarSymbol.tick_size/gVegarSymbol.point));
   req.type_filling=Vegar_SelectFillingMode();
   req.type_time=ORDER_TIME_GTC;
   int suffix_start=StringLen(intent.intent_id)-18; if(suffix_start<0) suffix_start=0;
   req.comment=VEGAR_COMMENT_PREFIX+"|"+StringSubstr(intent.intent_id,suffix_start);
   intent.entry_price=req.price;
   return (req.price>0.0);
  }

string Vegar_ExecutionRequestCanonical(const MqlTradeRequest &r)
  {
   // Hash every request field that can alter entry semantics. Zero-valued fields are included too,
   // so a mutation between OrderCheck and OrderSend cannot hide outside the canonical string.
   return (string)(int)r.action+"|"+r.symbol+"|"+(string)r.magic+"|"+
          (string)r.order+"|"+DoubleToString(r.volume,8)+"|"+DoubleToString(r.price,gVegarSymbol.digits)+"|"+
          DoubleToString(r.stoplimit,gVegarSymbol.digits)+"|"+DoubleToString(r.sl,gVegarSymbol.digits)+"|"+DoubleToString(r.tp,gVegarSymbol.digits)+"|"+
          (string)r.deviation+"|"+(string)(int)r.type+"|"+(string)(int)r.type_filling+"|"+(string)(int)r.type_time+"|"+
          (string)(long)r.expiration+"|"+r.comment+"|"+(string)r.position+"|"+(string)r.position_by;
  }

bool Vegar_FreezeExecutionRequest(SVegarIntent &intent,const SVegarRiskSnapshot &risk,SVegarExecutionRequest &frozen)
  {
   ZeroMemory(frozen);
   if(!Vegar_BuildTradeRequest(intent,frozen.request)) return false;
   // Finalize all monetary prices against the exact entry price that will be checked/sent.
   frozen.request.tp=0.0;
   if(InpAtivarTakeProfit && (InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT || InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT_E_RUNNER))
     {
      double finalTP=0.0;
      if(!Vegar_FindPriceForNetProfitMoney(intent.direction,intent.requested_volume,frozen.request.price,InpTakeProfitMoney,finalTP)) return false;
      frozen.request.tp=Vegar_NormalizePriceToTick(finalTP);
      intent.take_profit_price=frozen.request.tp;
     }
   double finalStopPnl=0.0;
   if(InpAtivarStopLoss && !Vegar_CalcMoneyFromPrice(intent.direction,intent.requested_volume,frozen.request.price,frozen.request.sl,finalStopPnl)) return false;
   frozen.valid=true;
   frozen.intent_id=intent.intent_id;
   frozen.opportunity_id=intent.opportunity_id;
   frozen.technical_stop_price=risk.technical_stop_price;
   frozen.technical_stop_money=(InpAtivarStopLoss?MathAbs(MathMin(0.0,finalStopPnl)):risk.technical_stop_money);
   frozen.estimated_costs=Vegar_EstimatedRoundTurnCommission(intent.requested_volume);
   frozen.stop_money_final=frozen.technical_stop_money+frozen.estimated_costs;
   frozen.tp_money_final=0.0;
   if(frozen.request.tp>0.0)
     {
      double actualTPGross=0.0;
      if(!Vegar_CalcMoneyFromPrice(intent.direction,intent.requested_volume,frozen.request.price,frozen.request.tp,actualTPGross)) return false;
      frozen.tp_money_final=actualTPGross-frozen.estimated_costs;
     }
   frozen.economic_spread_money=Vegar_SpreadMoney(intent.requested_volume);
   double finalExpected=0.0;
   if(gVegarOpportunity.opposite_liquidity_price>0.0 && Vegar_CalcMoneyFromPrice(intent.direction,intent.requested_volume,frozen.request.price,gVegarOpportunity.opposite_liquidity_price,finalExpected))
      finalExpected=MathMax(0.0,finalExpected-frozen.estimated_costs);
   frozen.expected_reward_net=finalExpected;
   frozen.canonical=Vegar_ExecutionRequestCanonical(frozen.request);
   frozen.request_hash=Vegar_ComputeHash(frozen.canonical);
   frozen.frozen=true;
   frozen.frozen_at=TimeTradeServer();
   return true;
  }

bool Vegar_ExecutionRequestIntegrityOK(const SVegarExecutionRequest &frozen)
  {
   if(!frozen.valid || !frozen.frozen || frozen.request_hash=="") return false;
   return (Vegar_ComputeHash(Vegar_ExecutionRequestCanonical(frozen.request))==frozen.request_hash);
  }

bool Vegar_IntentFocusStillValid(const SVegarIntent &intent)
  {
   int zi=Vegar_FindZoneIndex(intent.focus_zone_id);
   if(zi>=0)
      return (gVegarZones[zi].valid && gVegarZones[zi].state!=VEGAR_ZONE_INVALIDATED && gVegarZones[zi].state!=VEGAR_ZONE_EXPIRED);
   int oi=Vegar_FindObservationZoneIndex(intent.focus_zone_id);
   if(oi>=0)
      return (gVegarObservationZones[oi].valid && gVegarObservationZones[oi].strength_score>=InpForcaMinimaZona &&
              gVegarObservationZones[oi].state!=VEGAR_ZONE_INVALIDATED && gVegarObservationZones[oi].state!=VEGAR_ZONE_EXPIRED);
   // Immutable source snapshot remains authoritative after a map rebuild.
   return (gVegarOpportunity.source_zone_id==intent.focus_zone_id &&
           gVegarOpportunity.source_zone_pre_state!=VEGAR_ZONE_INVALIDATED &&
           gVegarOpportunity.source_zone_pre_state!=VEGAR_ZONE_EXPIRED &&
           gVegarOpportunity.focus_zone_strength>=InpForcaMinimaZona);
  }

bool Vegar_Preflight(SVegarIntent &intent,const SVegarRiskSnapshot &risk,SVegarExecutionResult &x)
  {
   ZeroMemory(x); x.reason=VEGAR_REASON_NONE; Vegar_ResetExecutionRequest();
   if(!intent.valid) { x.reason=STALE_INTENT; return false; }
   if(intent.processed) { x.reason=DUPLICATE_INTENT; return false; }
   if(gVegarCriticalSelfTestFailed) { x.reason=SELF_TEST_FAILED; return false; }
   if(gVegarConfigValidity!=VEGAR_CONFIG_VALID) { x.reason=gVegarConfigReason; return false; }
   ENUM_VEGAR_REASON_CODE reason;
   if(!Vegar_ExecutionAuthorization(reason)) { x.reason=reason; return false; }
   if(!Vegar_CheckPositionConflict(reason)) { x.reason=reason; return false; }
   if(!Vegar_AllRequiredDataReady(reason)) { x.reason=reason; return false; }
   if(intent.signal_bar_time<=0 || intent.signal_bar_time!=iTime(_Symbol,Vegar_ExecutionTF(),1)) { x.reason=STALE_INTENT; return false; }
   if(!Vegar_IntentFocusStillValid(intent)) { x.reason=SETUP_INVALIDATED_REASON; return false; }
   SVegarSessionStatus session;
   if(!Vegar_SessionGateAllowsEntry(reason,session)) { x.reason=reason; return false; }
   if(!Vegar_NewsAllowsEntry(reason)) { x.reason=reason; return false; }
   if(!Vegar_VolumeExactlyValid(intent.requested_volume)) { x.reason=LOT_INVALID; return false; }
   if(!risk.pass) { x.reason=risk.reason; return false; }
   if(!Vegar_SymbolTradeAvailable(intent.direction,reason)) { x.reason=reason; return false; }

   if(!Vegar_FreezeExecutionRequest(intent,risk,gVegarExecutionRequest)) { x.reason=PRICE_INVALID; return false; }
   x.request_hash=gVegarExecutionRequest.request_hash; x.request_frozen=gVegarExecutionRequest.frozen;
   x.stop_money_final=gVegarExecutionRequest.stop_money_final; x.tp_money_final=gVegarExecutionRequest.tp_money_final;
   x.estimated_costs=gVegarExecutionRequest.estimated_costs; x.economic_spread_money=gVegarExecutionRequest.economic_spread_money; x.expected_reward_net=gVegarExecutionRequest.expected_reward_net;
   if(!Vegar_StopsValidForEntry(intent.direction,gVegarExecutionRequest.request.price,gVegarExecutionRequest.request.sl,gVegarExecutionRequest.request.tp,reason)) { x.reason=reason; return false; }
   if(InpAtivarStopLoss && gVegarExecutionRequest.stop_money_final>InpStopLossMaximoMoney+1e-8) { x.reason=STOP_MONEY_EXCEEDED; return false; }
   if(InpAtivarMetaOperacao && gVegarExecutionRequest.expected_reward_net+1e-8<InpMetaOperacaoMoney) { x.reason=TARGET_SPACE_INSUFFICIENT; return false; }
   if(InpLimitePerdaDiariaMoney>0.0)
     {
      double dres=0.0; int dtr=0,dls=0; Vegar_RefreshDailyStats(dres,dtr,dls);
      double realizedLoss=Vegar_RealizedLossTodayMoney();
      double remain=InpLimitePerdaDiariaMoney-realizedLoss-Vegar_OpenWorstCaseRiskMoney()-(InpAtivarStopLoss?gVegarExecutionRequest.stop_money_final:InpLimitePerdaDiariaMoney);
      if(remain<-1e-8) { x.reason=DAILY_RISK_BUDGET_INSUFFICIENT; return false; }
     }
   if(!Vegar_ExecutionRequestIntegrityOK(gVegarExecutionRequest)) { x.reason=INTERNAL_ERROR; return false; }

   MqlTradeCheckResult check; ZeroMemory(check); ResetLastError();
   x.order_check_called=true; gVegarExecutionRequest.order_check_called=true;
   if(!OrderCheck(gVegarExecutionRequest.request,check))
     {
      gVegarExecutionRequest.order_check_retcode=check.retcode; gVegarExecutionRequest.order_check_comment=check.comment;
      x.order_check_retcode=check.retcode; x.order_check_comment=check.comment; x.reason=ORDER_CHECK_REJECTED; return false;
     }
   gVegarExecutionRequest.order_check_retcode=check.retcode; gVegarExecutionRequest.order_check_comment=check.comment;
   x.order_check_retcode=check.retcode; x.order_check_comment=check.comment;
   if(check.retcode!=TRADE_RETCODE_DONE && check.retcode!=TRADE_RETCODE_PLACED)
     { x.reason=ORDER_CHECK_REJECTED; return false; }
   if(!Vegar_ExecutionRequestIntegrityOK(gVegarExecutionRequest)) { x.reason=INTERNAL_ERROR; return false; }
   x.preflight_ok=true; x.requested_price=gVegarExecutionRequest.request.price; return true;
  }

bool Vegar_ExecuteIntent(SVegarIntent &intent,const SVegarRiskSnapshot &risk,SVegarExecutionResult &x)
  {
   if(!Vegar_Preflight(intent,risk,x))
     {
      intent.processed=true; gVegarStats.intents_processed++;
      Vegar_SetExecutionBlockedByReason(x.reason,"PREFLIGHT");
      return false;
     }
   intent.processed=true; gVegarStats.intents_processed++;
   if(!Vegar_ExecutionRequestIntegrityOK(gVegarExecutionRequest) || gVegarExecutionRequest.intent_id!=intent.intent_id)
     { x.reason=INTERNAL_ERROR; return false; }

   // RC8 P0 invariant: this exact object was approved by OrderCheck and is sent unchanged.
   MqlTradeResult res; ZeroMemory(res);
   x.order_send_called=true; gVegarStats.order_send_attempts++;
   ResetLastError();
   bool ok=OrderSend(gVegarExecutionRequest.request,res);
   x.trade_retcode=res.retcode; x.trade_comment=res.comment; x.order_ticket=res.order; x.deal_ticket=res.deal; x.fill_price=res.price; x.requested_price=gVegarExecutionRequest.request.price;
   gVegarStats.last_trade_retcode=res.retcode; gVegarStats.last_trade_comment=res.comment;
   if(!ok || (res.retcode!=TRADE_RETCODE_DONE && res.retcode!=TRADE_RETCODE_DONE_PARTIAL && res.retcode!=TRADE_RETCODE_PLACED))
     {
      x.reason=ORDER_SEND_REJECTED;
      Vegar_SetExecutionBlockedByReason(x.reason,res.comment);
      return false;
     }
   x.request_accepted=true; x.reason=VEGAR_REASON_NONE;
   Vegar_SetExecutionState(VEGAR_EXECUTION_ENABLED,VEGAR_REASON_NONE,"ORDER_REQUEST_ACCEPTED");
   return true;
  }

bool Vegar_ModifyOwnedPositionSLTP(const ulong ticket,const double sl,const double tp,string &detail)
  {
   detail="";
   if(!PositionSelectByTicket(ticket) || !Vegar_IsCurrentSelectedPositionOwned()) { detail="OWNERSHIP_FAIL"; return false; }
   double currentSL=PositionGetDouble(POSITION_SL),currentTP=PositionGetDouble(POSITION_TP);
   double tol=MathMax(gVegarSymbol.point,gVegarSymbol.tick_size)*0.5;
   if(MathAbs(currentSL-sl)<=tol && MathAbs(currentTP-tp)<=tol) { detail="IDEMPOTENT_OK"; return true; }
   MqlTradeRequest req; MqlTradeResult res; ZeroMemory(req); ZeroMemory(res);
   req.action=TRADE_ACTION_SLTP; req.symbol=_Symbol; req.position=ticket; req.magic=(ulong)InpMagicNumber;
   req.sl=(sl>0.0?Vegar_NormalizePriceToTick(sl):0.0); req.tp=(tp>0.0?Vegar_NormalizePriceToTick(tp):0.0);
   if(!Vegar_UpdateTick()) { detail="NO_TICK"; return false; }
   double market=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY?gVegarTick.bid:gVegarTick.ask);
   double freeze=(double)gVegarSymbol.freeze_level_points*gVegarSymbol.point;
   if(req.sl>0.0 && MathAbs(market-req.sl)<freeze) { detail="FREEZE_LEVEL_BLOCK"; return false; }
   bool ok=OrderSend(req,res);
   if(ok && res.retcode==TRADE_RETCODE_DONE) { detail="MODIFIED"; return true; }
   if(ok && res.retcode==TRADE_RETCODE_NO_CHANGES)
     {
      if(PositionSelectByTicket(ticket))
        {
         double brokerSL=PositionGetDouble(POSITION_SL),brokerTP=PositionGetDouble(POSITION_TP);
         if(MathAbs(brokerSL-req.sl)<=tol && MathAbs(brokerTP-req.tp)<=tol) { detail="IDEMPOTENT_OK"; return true; }
        }
      detail="NO_CHANGES_STATE_MISMATCH"; return false;
     }
   detail="RETCODE="+(string)res.retcode+" "+res.comment; return false;
  }

bool Vegar_CloseOwnedPosition(const string reason_text)
  {
   ulong ticket=0; long pid=0; ENUM_VEGAR_BIAS dir=VEGAR_BIAS_NONE; double entry=0.0,vol=0.0;
   if(!Vegar_FindOwnedPosition(ticket,pid,dir,entry,vol)) return false;
   if(!PositionSelectByTicket(ticket) || !Vegar_UpdateTick()) return false;
   MqlTradeRequest req; MqlTradeResult res; ZeroMemory(req); ZeroMemory(res);
   req.action=TRADE_ACTION_DEAL; req.symbol=_Symbol; req.position=ticket; req.magic=(ulong)InpMagicNumber; req.volume=PositionGetDouble(POSITION_VOLUME);
   req.type=(dir==VEGAR_BIAS_BUYER?ORDER_TYPE_SELL:ORDER_TYPE_BUY);
   req.price=(dir==VEGAR_BIAS_BUYER?gVegarTick.bid:gVegarTick.ask);
   req.deviation=(ulong)MathMax(0,MathRound((double)InpDesvioMaxExecucaoTicks*gVegarSymbol.tick_size/gVegarSymbol.point));
   req.type_filling=Vegar_SelectFillingMode(); req.type_time=ORDER_TIME_GTC; req.comment=VEGAR_COMMENT_PREFIX+"|EXIT|"+StringSubstr(reason_text,0,12);
   bool ok=OrderSend(req,res);
   Vegar_WriteTradeLifecycle("POSITION_CLOSE_REQUEST",res.order,res.deal,ticket,pid,reason_text+"|"+(string)res.retcode+"|"+res.comment);
   return (ok && (res.retcode==TRADE_RETCODE_DONE || res.retcode==TRADE_RETCODE_DONE_PARTIAL || res.retcode==TRADE_RETCODE_PLACED));
  }

void Vegar_HandleTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   if(trans.symbol!=_Symbol) return;
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD && trans.deal>0)
     {
      gVegarStats.last_deal_ticket=trans.deal;
      if(trans.position>0) gVegarStats.last_position_ticket=trans.position;
      if(!HistoryDealSelect(trans.deal)) return;
      string comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
      ENUM_DEAL_ENTRY entryType=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
      long position_id=(long)HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);
      long deal_magic=(long)HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
      bool explicit_comment=(StringFind(comment,VEGAR_COMMENT_PREFIX)==0);
      if(entryType==DEAL_ENTRY_IN && deal_magic==InpMagicNumber && explicit_comment) Vegar_RegisterOwnedPositionIDPersistent(position_id);
      bool owned_cycle=((deal_magic==InpMagicNumber && explicit_comment) || Vegar_OwnershipHasPositionID(position_id));
      if(!owned_cycle) return;
      Vegar_WriteTradeLifecycle(entryType==DEAL_ENTRY_IN?"DEAL_ENTRY":"DEAL_EXIT",trans.order,trans.deal,trans.position,position_id,comment);
      if(entryType==DEAL_ENTRY_IN)
        {
         ulong ticket=0; long pid=0; ENUM_VEGAR_BIAS d=VEGAR_BIAS_NONE; double ep=0.0,v=0.0;
         if(Vegar_FindOwnedPosition(ticket,pid,d,ep,v))
           {
            Vegar_ProfitAttach(ticket,pid,d,ep,v); Vegar_SaveOperationalState();
           }
        }
      else if(entryType==DEAL_ENTRY_OUT || entryType==DEAL_ENTRY_OUT_BY)
        {
         if(!Vegar_HasOwnedPosition()) { Vegar_ResetProfitState(); Vegar_ClearOperationalState(); }
        }
     }
  }

#endif
