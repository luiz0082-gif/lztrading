#ifndef __VEGAR_RISK_MQH__
#define __VEGAR_RISK_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Time.mqh"
#include "Vegar_Liquidity.mqh"

bool Vegar_DealLooksOwned(const ulong deal_ticket)
  {
   if(deal_ticket==0) return false;
   if(HistoryDealGetString(deal_ticket,DEAL_SYMBOL)!=_Symbol) return false;
   long position_id=(long)HistoryDealGetInteger(deal_ticket,DEAL_POSITION_ID);
   long magic=(long)HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
   string c=HistoryDealGetString(deal_ticket,DEAL_COMMENT);
   if(magic==InpMagicNumber && StringFind(c,VEGAR_COMMENT_PREFIX)==0)
     {
      Vegar_OwnershipRegisterPositionID(position_id);
      return true;
     }
   // Exit deals can arrive without the original comment/magic on some broker paths.
   // Once a TradeCycle position-id was positively registered by its entry, keep its lifecycle owned.
   return Vegar_OwnershipHasPositionID(position_id);
  }

int Vegar_FindCycleIndex(const long &ids[],const long id)
  {
   for(int i=0;i<ArraySize(ids);i++) if(ids[i]==id) return i;
   return -1;
  }

// RC8: daily accounting is by TradeCycle (DEAL_POSITION_ID), never by individual deal.
// result is the net sum of all owned deal components; trades counts unique cycles started today;
// loss_streak is calculated from completed cycles ordered by their last exit time.
void Vegar_RefreshDailyStats(double &result,int &trades,int &loss_streak)
  {
   result=0.0; trades=0; loss_streak=0;
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   datetime from=Vegar_NewYorkTradingDayStartServer(now);
   if(!HistorySelect(from,now)) return;
   int total=HistoryDealsTotal();

   for(int seed=0;seed<total;seed++)
     {
      ulong seedTicket=HistoryDealGetTicket(seed); if(seedTicket==0) continue;
      if((long)HistoryDealGetInteger(seedTicket,DEAL_MAGIC)!=InpMagicNumber || HistoryDealGetString(seedTicket,DEAL_SYMBOL)!=_Symbol) continue;
      string seedComment=HistoryDealGetString(seedTicket,DEAL_COMMENT);
      if(StringFind(seedComment,VEGAR_COMMENT_PREFIX)==0)
         Vegar_OwnershipRegisterPositionID((long)HistoryDealGetInteger(seedTicket,DEAL_POSITION_ID));
     }

   long ids[]; double pnls[]; bool hasEntry[]; bool hasExit[]; datetime lastExit[];
   ArrayResize(ids,0); ArrayResize(pnls,0); ArrayResize(hasEntry,0); ArrayResize(hasExit,0); ArrayResize(lastExit,0);
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i); if(ticket==0 || !Vegar_DealLooksOwned(ticket)) continue;
      long pid=(long)HistoryDealGetInteger(ticket,DEAL_POSITION_ID); if(pid<=0) continue;
      int ci=Vegar_FindCycleIndex(ids,pid);
      if(ci<0)
        {
         ci=ArraySize(ids); ArrayResize(ids,ci+1); ArrayResize(pnls,ci+1); ArrayResize(hasEntry,ci+1); ArrayResize(hasExit,ci+1); ArrayResize(lastExit,ci+1);
         ids[ci]=pid; pnls[ci]=0.0; hasEntry[ci]=false; hasExit[ci]=false; lastExit[ci]=0;
        }
      double p=HistoryDealGetDouble(ticket,DEAL_PROFIT)+HistoryDealGetDouble(ticket,DEAL_COMMISSION)+HistoryDealGetDouble(ticket,DEAL_SWAP)+HistoryDealGetDouble(ticket,DEAL_FEE);
      pnls[ci]+=p; result+=p;
      ENUM_DEAL_ENTRY e=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
      datetime dt=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(e==DEAL_ENTRY_IN || e==DEAL_ENTRY_INOUT) hasEntry[ci]=true;
      if(e==DEAL_ENTRY_OUT || e==DEAL_ENTRY_OUT_BY || e==DEAL_ENTRY_INOUT)
        { hasExit[ci]=true; if(dt>lastExit[ci]) lastExit[ci]=dt; }
     }

   for(int i=0;i<ArraySize(ids);i++) if(hasEntry[i]) trades++;

   // Stable sort completed cycles by last exit time ascending, then walk backwards.
   for(int a=0;a<ArraySize(ids)-1;a++)
      for(int b=a+1;b<ArraySize(ids);b++)
         if(lastExit[b]>0 && (lastExit[a]==0 || lastExit[b]<lastExit[a]))
           {
            long ti=ids[a]; ids[a]=ids[b]; ids[b]=ti;
            double tp=pnls[a]; pnls[a]=pnls[b]; pnls[b]=tp;
            bool te=hasEntry[a]; hasEntry[a]=hasEntry[b]; hasEntry[b]=te;
            bool tx=hasExit[a]; hasExit[a]=hasExit[b]; hasExit[b]=tx;
            datetime tt=lastExit[a]; lastExit[a]=lastExit[b]; lastExit[b]=tt;
           }
   for(int j=ArraySize(ids)-1;j>=0;j--)
     {
      if(!hasExit[j] || lastExit[j]<=0) continue;
      if(pnls[j]<0.0) loss_streak++;
      else break;
     }
  }

double Vegar_RealizedLossTodayMoney()
  {
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   datetime from=Vegar_NewYorkTradingDayStartServer(now);
   if(!HistorySelect(from,now)) return 0.0;
   int total=HistoryDealsTotal();

   // Seed ownership from positively identifiable VEGAR entries before grouping cycle economics.
   for(int seed=0;seed<total;seed++)
     {
      ulong seedTicket=HistoryDealGetTicket(seed); if(seedTicket==0) continue;
      if((long)HistoryDealGetInteger(seedTicket,DEAL_MAGIC)!=InpMagicNumber || HistoryDealGetString(seedTicket,DEAL_SYMBOL)!=_Symbol) continue;
      string seedComment=HistoryDealGetString(seedTicket,DEAL_COMMENT);
      if(StringFind(seedComment,VEGAR_COMMENT_PREFIX)==0)
         Vegar_OwnershipRegisterPositionID((long)HistoryDealGetInteger(seedTicket,DEAL_POSITION_ID));
     }

   long ids[]; double pnls[];
   ArrayResize(ids,0); ArrayResize(pnls,0);
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i); if(ticket==0 || !Vegar_DealLooksOwned(ticket)) continue;
      long pid=(long)HistoryDealGetInteger(ticket,DEAL_POSITION_ID); if(pid<=0) continue;
      int ci=Vegar_FindCycleIndex(ids,pid);
      if(ci<0)
        {
         ci=ArraySize(ids); ArrayResize(ids,ci+1); ArrayResize(pnls,ci+1);
         ids[ci]=pid; pnls[ci]=0.0;
        }
      pnls[ci]+=HistoryDealGetDouble(ticket,DEAL_PROFIT)+HistoryDealGetDouble(ticket,DEAL_COMMISSION)+HistoryDealGetDouble(ticket,DEAL_SWAP)+HistoryDealGetDouble(ticket,DEAL_FEE);
     }

   double realizedLoss=0.0;
   for(int j=0;j<ArraySize(ids);j++)
      if(pnls[j]<0.0) realizedLoss+=-pnls[j];
   return MathMax(0.0,realizedLoss);
  }

double Vegar_TradeCycleNetPnL(const long position_id)
  {
   if(position_id<=0) return 0.0;
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   if(!HistorySelect(0,now)) return 0.0;
   double net=0.0;
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong d=HistoryDealGetTicket(i); if(d==0) continue;
      if((long)HistoryDealGetInteger(d,DEAL_POSITION_ID)!=position_id) continue;
      if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
      if((long)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagicNumber && !Vegar_OwnershipHasPositionID(position_id)) continue;
      net+=HistoryDealGetDouble(d,DEAL_PROFIT)+HistoryDealGetDouble(d,DEAL_COMMISSION)+HistoryDealGetDouble(d,DEAL_SWAP)+HistoryDealGetDouble(d,DEAL_FEE);
     }
   return net;
  }

bool Vegar_CalcMoneyFromPrice(const ENUM_VEGAR_BIAS direction,const double volume,const double entry_price,const double exit_price,double &money)
  {
   ENUM_ORDER_TYPE type=(direction==VEGAR_BIAS_BUYER?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
   return Vegar_CalcProfit(type,volume,entry_price,exit_price,money);
  }

double Vegar_EstimatedRoundTurnCommission(const double volume)
  {
   if(volume<=0.0 || InpComissaoRoundTurnPorLoteMoney<=0.0) return 0.0;
   return InpComissaoRoundTurnPorLoteMoney*volume;
  }

bool Vegar_FindPriceForProfitMoney(const ENUM_VEGAR_BIAS direction,const double volume,const double entry_price,const double target_money,double &target_price)
  {
   target_price=0.0;
   if(volume<=0.0 || entry_price<=0.0 || target_money<=0.0) return false;
   double step=MathMax(gVegarSymbol.tick_size,Vegar_ATR(Vegar_ExecutionTF(),1)*0.25);
   if(step<=0.0) step=100.0*gVegarSymbol.point;
   double lo=entry_price,hi=entry_price;
   double probe=entry_price; double p=0.0;
   bool bracket=false;
   for(int i=0;i<40;i++)
     {
      probe=(direction==VEGAR_BIAS_BUYER ? entry_price+step : entry_price-step);
      if(probe<=0.0) return false;
      if(!Vegar_CalcMoneyFromPrice(direction,volume,entry_price,probe,p)) return false;
      if(p>=target_money)
        {
         bracket=true;
         if(direction==VEGAR_BIAS_BUYER) { lo=entry_price; hi=probe; }
         else { lo=probe; hi=entry_price; }
         break;
        }
      step*=2.0;
     }
   if(!bracket) return false;
   for(int k=0;k<60;k++)
     {
      double mid=(lo+hi)*0.5;
      if(!Vegar_CalcMoneyFromPrice(direction,volume,entry_price,mid,p)) return false;
      if(direction==VEGAR_BIAS_BUYER)
        { if(p>=target_money) hi=mid; else lo=mid; }
      else
        { if(p>=target_money) lo=mid; else hi=mid; }
     }
   target_price=Vegar_NormalizePriceToTick(direction==VEGAR_BIAS_BUYER?hi:lo);
   return (target_price>0.0);
  }

// Target requested by the operator is NET. Commission is added to the required gross PnL.
bool Vegar_FindPriceForNetProfitMoney(const ENUM_VEGAR_BIAS direction,const double volume,const double entry_price,const double target_net_money,double &target_price)
  {
   double required_gross=target_net_money+Vegar_EstimatedRoundTurnCommission(volume);
   return Vegar_FindPriceForProfitMoney(direction,volume,entry_price,required_gross,target_price);
  }

bool Vegar_CalcEconomicTarget(const ENUM_VEGAR_BIAS direction,const double entry_price,const double opposite_price,double &economic_target,double &expected_money)
  {
   economic_target=0.0; expected_money=0.0;
   if(opposite_price>0.0)
     {
      if(!Vegar_CalcMoneyFromPrice(direction,InpLoteOperacional,entry_price,opposite_price,expected_money)) expected_money=0.0;
      expected_money=MathMax(0.0,expected_money-Vegar_EstimatedRoundTurnCommission(InpLoteOperacional));
     }
   if(InpAtivarMetaOperacao) economic_target=InpMetaOperacaoMoney;
   else if(InpAtivarTakeProfit) economic_target=InpTakeProfitMoney;
   else economic_target=expected_money;
   return (economic_target>0.0);
  }

// Worst-case open risk for the same EA/symbol. This is deliberately fail-safe: a VEGAR-owned
// position without a server SL consumes the full daily budget, preventing additive exposure.
double Vegar_OpenWorstCaseRiskMoney()
  {
   double risk=0.0;
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i); if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber) continue;
      long pid=(long)PositionGetInteger(POSITION_IDENTIFIER);
      string c=PositionGetString(POSITION_COMMENT);
      if(StringFind(c,VEGAR_COMMENT_PREFIX)!=0 && !Vegar_OwnershipHasPositionID(pid)) continue;
      double sl=PositionGetDouble(POSITION_SL),entry=PositionGetDouble(POSITION_PRICE_OPEN),vol=PositionGetDouble(POSITION_VOLUME);
      if(sl<=0.0) return MathMax(0.0,InpLimitePerdaDiariaMoney);
      ENUM_POSITION_TYPE pt=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ENUM_VEGAR_BIAS dir=(pt==POSITION_TYPE_BUY?VEGAR_BIAS_BUYER:VEGAR_BIAS_SELLER);
      double p=0.0; if(Vegar_CalcMoneyFromPrice(dir,vol,entry,sl,p)) risk+=MathAbs(MathMin(0.0,p))-0.0+Vegar_EstimatedRoundTurnCommission(vol);
     }
   return MathMax(0.0,risk);
  }

bool Vegar_RiskEvaluate(const SVegarOpportunity &opp,SVegarRiskSnapshot &r)
  {
   ZeroMemory(r); r.pass=false; r.reason=VEGAR_REASON_NONE; r.volume=InpLoteOperacional;
   if(!Vegar_VolumeExactlyValid(r.volume)) { r.reason=LOT_INVALID; return false; }
   if(!Vegar_UpdateTick()) { r.reason=PRICE_INVALID; return false; }
   double entry=(opp.direction==VEGAR_BIAS_BUYER?gVegarTick.ask:gVegarTick.bid);
   if(entry<=0.0 || opp.technical_stop<=0.0) { r.reason=PRICE_INVALID; return false; }
   r.technical_stop_price=opp.technical_stop;
   double stopPnl=0.0;
   if(!Vegar_CalcMoneyFromPrice(opp.direction,r.volume,entry,opp.technical_stop,stopPnl)) { r.reason=INTERNAL_ERROR; return false; }
   r.technical_stop_money=MathAbs(MathMin(0.0,stopPnl));
   r.estimated_round_turn_commission=Vegar_EstimatedRoundTurnCommission(r.volume);
   r.estimated_fee=0.0; r.estimated_swap=0.0;
   r.estimated_total_costs=r.estimated_round_turn_commission;
   r.commission_model_incomplete=(InpComissaoRoundTurnPorLoteMoney<=0.0);
   if(InpAtivarStopLoss)
     {
      if(InpStopLossMaximoMoney<=0.0) { r.reason=CONFIG_STOP_MONEY_UNSET; return false; }
      if(r.technical_stop_money+r.estimated_total_costs>InpStopLossMaximoMoney+1e-8) { r.reason=STOP_MONEY_EXCEEDED; return false; }
     }

   double opposite=opp.opposite_liquidity_price;
   if(!Vegar_CalcEconomicTarget(opp.direction,entry,opposite,r.economic_target_money,r.expected_money_opposite)) { r.reason=ECONOMIC_TARGET_UNAVAILABLE; return false; }
   r.expected_reward_net=r.expected_money_opposite;
   if(InpAtivarMetaOperacao && r.expected_reward_net+1e-8<InpMetaOperacaoMoney) { r.reason=TARGET_SPACE_INSUFFICIENT; return false; }

   r.spread_points=Vegar_CurrentSpreadPoints(); r.spread_ticks=Vegar_CurrentSpreadTicks(); r.spread_money=Vegar_SpreadMoney(r.volume);
   if(r.economic_target_money<=0.0) { r.reason=ECONOMIC_TARGET_UNAVAILABLE; return false; }
   r.spread_target_percent=r.spread_money/r.economic_target_money*100.0;
   if(r.spread_target_percent>InpMaxSpreadTargetPercent) { r.reason=SPREAD_TOO_HIGH; return false; }

   Vegar_RefreshDailyStats(r.daily_result,r.trades_today,r.consecutive_losses);
   if(InpAtivarMetaDiaria && r.daily_result>=InpMetaDiariaMoney) { r.reason=DAILY_TARGET_REACHED; return false; }
   if(InpLimitePerdaDiariaMoney>0.0 && r.daily_result<=-InpLimitePerdaDiariaMoney) { r.reason=DAILY_LOSS_REACHED; return false; }
   if(r.trades_today>=InpMaxTradesPerDay) { r.reason=MAX_TRADES_REACHED; return false; }
   if(r.consecutive_losses>=InpMaxConsecutiveLosses) { r.reason=LOSS_STREAK_LOCK; return false; }

   // RC8 prospective Daily Loss budget.
   r.daily_loss_limit=MathMax(0.0,InpLimitePerdaDiariaMoney);
   r.realized_loss=Vegar_RealizedLossTodayMoney();
   r.open_worst_case_risk=Vegar_OpenWorstCaseRiskMoney();
   r.estimated_new_trade_worst_case=(InpAtivarStopLoss ? r.technical_stop_money+r.estimated_total_costs : r.daily_loss_limit);
   r.daily_remaining_risk=r.daily_loss_limit-r.realized_loss-r.open_worst_case_risk-r.estimated_new_trade_worst_case;
   if(r.daily_loss_limit>0.0 && r.daily_remaining_risk<-1e-8)
     { r.reason=DAILY_RISK_BUDGET_INSUFFICIENT; return false; }

   ENUM_ORDER_TYPE type=(opp.direction==VEGAR_BIAS_BUYER?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
   r.free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   r.margin_level=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   if(!OrderCalcMargin(type,_Symbol,r.volume,entry,r.projected_margin)) { r.reason=MARGIN_TOO_LOW; return false; }
   r.projected_free_margin=r.free_margin-r.projected_margin;
   if(r.projected_free_margin<=0.0) { r.reason=MARGIN_TOO_LOW; return false; }
   if(InpMargemMinimaPermitidaPct>0.0)
     {
      double equity=AccountInfoDouble(ACCOUNT_EQUITY);
      double margin=AccountInfoDouble(ACCOUNT_MARGIN)+r.projected_margin;
      double projectedLevel=(margin>0.0?equity/margin*100.0:999999.0);
      if(projectedLevel<InpMargemMinimaPermitidaPct) { r.reason=MARGIN_TOO_LOW; return false; }
     }
   r.pass=true; return true;
  }

#endif
