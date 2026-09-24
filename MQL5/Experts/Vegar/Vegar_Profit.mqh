#ifndef __VEGAR_PROFIT_MQH__
#define __VEGAR_PROFIT_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Risk.mqh"

SVegarProfitState gVegarProfit;

// Implemented in Vegar_Execution.mqh
bool Vegar_ModifyOwnedPositionSLTP(const ulong ticket,const double sl,const double tp,string &detail);
// Implemented in Vegar_Persistence.mqh.
bool Vegar_SaveOperationalState();

void Vegar_ResetProfitState()
  {
   ZeroMemory(gVegarProfit);
  }

void Vegar_ProfitAttach(const ulong ticket,const long position_id,const ENUM_VEGAR_BIAS direction,const double entry,const double volume)
  {
   Vegar_ResetProfitState();
   gVegarProfit.active=true; gVegarProfit.position_ticket=ticket; gVegarProfit.position_id=position_id;
   gVegarProfit.direction=direction; gVegarProfit.entry_price=entry; gVegarProfit.volume=volume;
   gVegarProfit.peak_profit_money=0.0; gVegarProfit.peak_known=true; gVegarProfit.protected_profit_money=0.0; gVegarProfit.last_committed_peak=0.0;
   gVegarProfit.last_runner_update=0; gVegarProfit.technical_stop=0.0; gVegarProfit.take_profit=0.0;
   gVegarProfit.protected_floor_installed=false; gVegarProfit.broker_tp_removed_for_runner=false;
  }

bool Vegar_ProtectedMoneyToSL(const double protected_money,double &sl_price)
  {
   sl_price=0.0;
   if(protected_money<=0.0 || !gVegarProfit.active) return false;
   return Vegar_FindPriceForNetProfitMoney(gVegarProfit.direction,gVegarProfit.volume,gVegarProfit.entry_price,protected_money,sl_price);
  }

bool Vegar_IsProtectionTighter(const ENUM_VEGAR_BIAS direction,const double current_sl,const double candidate_sl)
  {
   if(candidate_sl<=0.0) return false;
   if(current_sl<=0.0) return true;
   if(direction==VEGAR_BIAS_BUYER) return (candidate_sl>current_sl+gVegarSymbol.tick_size*0.5);
   if(direction==VEGAR_BIAS_SELLER) return (candidate_sl<current_sl-gVegarSymbol.tick_size*0.5);
   return false;
  }

bool Vegar_InstallRunnerFloorAndRemoveTP(const double protected_money,string &detail)
  {
   detail="";
   if(!gVegarProfit.active || !PositionSelectByTicket(gVegarProfit.position_ticket)) { detail="POSITION_NOT_FOUND"; return false; }
   double desiredSL=0.0; if(!Vegar_ProtectedMoneyToSL(protected_money,desiredSL)) { detail="FLOOR_PRICE_FAIL"; return false; }
   double currentSL=PositionGetDouble(POSITION_SL);
   if(!Vegar_IsProtectionTighter(gVegarProfit.direction,currentSL,desiredSL) && currentSL>0.0) desiredSL=currentSL;
   // HYBRID invariant: TP is removed on the same server modification that installs/keeps the protected floor.
   if(!Vegar_ModifyOwnedPositionSLTP(gVegarProfit.position_ticket,desiredSL,0.0,detail)) return false;
   if(!PositionSelectByTicket(gVegarProfit.position_ticket)) { detail="VERIFY_POSITION_FAIL"; return false; }
   double tol=MathMax(gVegarSymbol.point,gVegarSymbol.tick_size)*0.5;
   double brokerSL=PositionGetDouble(POSITION_SL),brokerTP=PositionGetDouble(POSITION_TP);
   bool floorOk=(brokerSL>0.0 && (gVegarProfit.direction==VEGAR_BIAS_BUYER ? brokerSL+tol>=desiredSL : brokerSL-tol<=desiredSL));
   bool tpRemoved=(MathAbs(brokerTP)<=tol);
   if(!floorOk || !tpRemoved) { detail="RUNNER_VERIFY_FAIL"; return false; }
   gVegarProfit.last_server_sl=brokerSL;
   gVegarProfit.protected_floor_installed=true;
   gVegarProfit.broker_tp_removed_for_runner=true;
   return true;
  }

void Vegar_ProfitUpdateFromSelectedPosition()
  {
   if(!gVegarProfit.active) return;
   if(!PositionSelectByTicket(gVegarProfit.position_ticket)) { gVegarProfit.active=false; return; }
   gVegarProfit.current_profit_money=PositionGetDouble(POSITION_PROFIT);
   gVegarProfit.current_swap_money=PositionGetDouble(POSITION_SWAP);
   gVegarProfit.current_commission_money=-Vegar_EstimatedRoundTurnCommission(gVegarProfit.volume);
   gVegarProfit.current_fee_money=0.0;
   double economic=gVegarProfit.current_profit_money+gVegarProfit.current_swap_money+gVegarProfit.current_commission_money+gVegarProfit.current_fee_money;
   gVegarProfit.current_net_profit_money=economic;

   if(!gVegarProfit.peak_known)
     {
      gVegarProfit.peak_profit_money=economic;
      gVegarProfit.last_committed_peak=economic;
      gVegarProfit.peak_known=true;
      gVegarProfit.last_runner_update=TimeTradeServer();
      Vegar_SaveOperationalState();
      return;
     }
   if(economic>gVegarProfit.peak_profit_money) gVegarProfit.peak_profit_money=economic;
   if(!InpAtivarRunner || InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT) return;

   if(!gVegarProfit.runner_active && gVegarProfit.peak_profit_money>=InpLucroParaAtivarRunner)
     {
      string detail="";
      gVegarProfit.protected_profit_money=InpLucroInicialProtegido;
      if(Vegar_InstallRunnerFloorAndRemoveTP(gVegarProfit.protected_profit_money,detail))
        {
         gVegarProfit.runner_active=true;
         gVegarProfit.last_committed_peak=gVegarProfit.peak_profit_money;
         gVegarProfit.last_runner_update=TimeTradeServer();
         Vegar_SaveOperationalState();
        }
      else
        {
         // Fail-safe: never declare RUNNER active without server-side floor and confirmed TP removal.
         gVegarProfit.runner_active=false;
         gVegarProfit.software_exit_requested=true;
         gVegarProfit.exit_reason="RUNNER_ACTIVATION_PROTECTION_FAILED";
         return;
        }
     }

   if(gVegarProfit.runner_active && gVegarProfit.peak_profit_money>=gVegarProfit.last_committed_peak+InpPassoRunnerMoney)
     {
      double candidate=gVegarProfit.peak_profit_money-InpDistanciaRunnerMoney;
      if(candidate>gVegarProfit.protected_profit_money)
        {
         gVegarProfit.protected_profit_money=candidate;
         gVegarProfit.last_committed_peak=gVegarProfit.peak_profit_money;
        }
     }

   if(gVegarProfit.runner_active && gVegarProfit.protected_profit_money>0.0)
     {
      if(economic<=gVegarProfit.protected_profit_money)
        {
         gVegarProfit.software_exit_requested=true;
         gVegarProfit.exit_reason="RUNNER_PROTECTED_FLOOR";
        }
      double desiredSL=0.0;
      if(Vegar_ProtectedMoneyToSL(gVegarProfit.protected_profit_money,desiredSL))
        {
         double currentSL=PositionGetDouble(POSITION_SL);
         bool tighter=Vegar_IsProtectionTighter(gVegarProfit.direction,currentSL,desiredSL);
         if(tighter)
           {
            string detail="";
            if(Vegar_ModifyOwnedPositionSLTP(gVegarProfit.position_ticket,desiredSL,0.0,detail))
              {
               if(PositionSelectByTicket(gVegarProfit.position_ticket))
                 {
                  double tol=MathMax(gVegarSymbol.point,gVegarSymbol.tick_size)*0.5;
                  double tp=PositionGetDouble(POSITION_TP);
                  if(MathAbs(tp)<=tol)
                    {
                     gVegarProfit.last_server_sl=PositionGetDouble(POSITION_SL);
                     gVegarProfit.broker_tp_removed_for_runner=true;
                     gVegarProfit.protected_floor_installed=true;
                     gVegarProfit.last_runner_update=TimeTradeServer();
                     Vegar_SaveOperationalState();
                    }
                 }
              }
           }
        }
     }
  }

#endif
