#ifndef __VEGAR_PANEL_MQH__
#define __VEGAR_PANEL_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Time.mqh"
#include "Vegar_News.mqh"
#include "Vegar_Structure.mqh"
#include "Vegar_Setup.mqh"
#include "Vegar_Profit.mqh"
#include "Vegar_Csv.mqh"
#include "Vegar_Execution.mqh"
#include "Vegar_Visual.mqh"

#define VEGAR_PANEL_PREFIX "VEGAR_PANEL_"

bool gVegarEntriesPaused=false;
datetime gVegarCloseConfirmUntil=0;
bool gVegarPanelMinimized=false;
string gVegarPanelLastActionText="--";
string gVegarPanelLastActionResult="";
datetime gVegarPanelLastActionTime=0;
int gVegarPanelLastActionSeverity=0;
string gVegarPanelPressedButton="";
ulong gVegarPanelPressedUntilMsc=0;

double gVegarPanelCachedDailyNet=0.0;
int gVegarPanelCachedTrades=0;
int gVegarPanelCachedLossStreak=0;
ulong gVegarPanelStatsRefreshMsc=0;

void Vegar_PanelActionFeedback(const string text,const string result,const int severity,const string button_id)
  {
   gVegarPanelLastActionText=text;
   gVegarPanelLastActionResult=result;
   gVegarPanelLastActionSeverity=severity;
   gVegarPanelLastActionTime=TimeTradeServer(); if(gVegarPanelLastActionTime<=0) gVegarPanelLastActionTime=TimeCurrent();
   gVegarPanelPressedButton=button_id;
   gVegarPanelPressedUntilMsc=GetTickCount64()+350;
  }

void Vegar_PanelApplyButtonVisual(const string id)
  {
   string n=VEGAR_PANEL_PREFIX+id; if(ObjectFind(0,n)<0) return;
   bool pressed=(gVegarPanelPressedButton==id && GetTickCount64()<gVegarPanelPressedUntilMsc);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,pressed?C'23,58,74':C'16,33,50');
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,pressed?C'53,224,230':C'34,53,74');
  }

void Vegar_PanelUpdateActionAnimation()
  {
   if(gVegarPanelPressedButton!="" && GetTickCount64()>=gVegarPanelPressedUntilMsc)
     {
      string id=gVegarPanelPressedButton;
      gVegarPanelPressedButton="";
      gVegarPanelPressedUntilMsc=0;
      Vegar_PanelApplyButtonVisual(id);
     }
  }

int Vegar_PanelPx(const int value)
  {
   return (int)MathRound((double)value*(double)InpEscalaPainelPct/100.0);
  }

long Vegar_PanelBackgroundColor(const color c)
  {
   int pct=(int)MathMax(0,MathMin(100,InpOpacidadePainelPercent));
   long raw=0;
   if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,raw)) raw=(long)clrBlack;
   int alpha=(int)MathRound(255.0*(double)pct/100.0);
   return (long)Vegar_BlendColor(c,(color)raw,alpha);
  }

void Vegar_PanelEnforceTopLayer()
  {
   int total=ObjectsTotal(0,0,-1);
   for(int i=0;i<total;i++)
     {
      string n=ObjectName(0,i,0,-1);
      if(StringFind(n,VEGAR_PANEL_PREFIX)!=0) continue;
      ObjectSetInteger(0,n,OBJPROP_BACK,false);
      long z=1000;
      if(StringFind(n,VEGAR_PANEL_PREFIX+"BTN_")==0) z=1200;
      else if(StringFind(n,VEGAR_PANEL_PREFIX+"LAST_ACTION")==0) z=1150;
      else if((ENUM_OBJECT)ObjectGetInteger(0,n,OBJPROP_TYPE)==OBJ_LABEL) z=1100;
      ObjectSetInteger(0,n,OBJPROP_ZORDER,z);
     }
  }

void Vegar_PanelDelete()
  {
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      string n=ObjectName(0,i,0,-1);
      if(StringFind(n,VEGAR_PANEL_PREFIX)==0)
         ObjectDelete(0,n);
     }
  }

void Vegar_PanelBox(const string id,const int x,const int y,const int w,const int h,const color bg,const color border)
  {
   string n=VEGAR_PANEL_PREFIX+id;
   if(ObjectFind(0,n)<0)
      ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);

   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,Vegar_PanelPx(x));
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,Vegar_PanelPx(y));
   ObjectSetInteger(0,n,OBJPROP_XSIZE,Vegar_PanelPx(w));
   ObjectSetInteger(0,n,OBJPROP_YSIZE,Vegar_PanelPx(h));
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,Vegar_PanelBackgroundColor(bg));
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,n,OBJPROP_BACK,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,1000);
  }

void Vegar_PanelLabel(const string id,const int x,const int y,const string text,const color c=clrGainsboro,const int size=9)
  {
   string n=VEGAR_PANEL_PREFIX+id;
   if(ObjectFind(0,n)<0)
      ObjectCreate(0,n,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,Vegar_PanelPx(x));
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,Vegar_PanelPx(y));
   ObjectSetString(0,n,OBJPROP_TEXT,text);
   ObjectSetString(0,n,OBJPROP_FONT,"Segoe UI");
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,(long)MathMax(9,Vegar_PanelPx(size)));
   ObjectSetInteger(0,n,OBJPROP_COLOR,c);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,1001);
  }

void Vegar_PanelButton(const string id,const int x,const int y,const int w,const int h,const string text)
  {
   string n=VEGAR_PANEL_PREFIX+id;
   if(ObjectFind(0,n)<0)
      ObjectCreate(0,n,OBJ_BUTTON,0,0,0);

   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,Vegar_PanelPx(x));
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,Vegar_PanelPx(y));
   ObjectSetInteger(0,n,OBJPROP_XSIZE,Vegar_PanelPx(w));
   ObjectSetInteger(0,n,OBJPROP_YSIZE,Vegar_PanelPx(h));
   ObjectSetString(0,n,OBJPROP_TEXT,text);
   ObjectSetString(0,n,OBJPROP_FONT,"Segoe UI");
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,(long)MathMax(9,Vegar_PanelPx(9)));
   ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);
   bool pressed=(gVegarPanelPressedButton==id && GetTickCount64()<gVegarPanelPressedUntilMsc);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,pressed?C'23,58,74':C'16,33,50');
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,pressed?C'53,224,230':C'34,53,74');
   ObjectSetInteger(0,n,OBJPROP_STATE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,1002);
  }

string Vegar_PanelBiasPT(const ENUM_VEGAR_BIAS b)
  {
   if(b==VEGAR_BIAS_BUYER) return "COMPRADOR";
   if(b==VEGAR_BIAS_SELLER) return "VENDEDOR";
   return "NEUTRO";
  }

string Vegar_PanelCandidateStateText()
  {
   if(gVegarOpportunity.active) return Vegar_CandidateStateText(gVegarOpportunity.candidate_state);
   if(gVegarApproachLatch.active) return "APPROACH";
   return "NONE";
  }

string Vegar_PanelOpportunityStateText()
  {
   return (gVegarOpportunity.active?Vegar_SetupStateText(gVegarOpportunity.state):"IDLE");
  }

string Vegar_PanelExecutionSignalState()
  {
   if(!gVegarOpportunity.technical_signal_ready) return "N/A";
   return (gVegarOpportunity.execution_authorized?"AUTORIZADA":"BLOQUEADA");
  }

string Vegar_ConfigPanelText()
  {
   if(gVegarConfigValidity==VEGAR_CONFIG_VALID) return "VALIDA";
   return "INVALIDA";
  }

color Vegar_ExecutionPanelColor()
  {
   if(gVegarExecutionState==VEGAR_EXECUTION_ENABLED) return C'0,220,160';
   if(gVegarExecutionState==VEGAR_EXECUTION_BLOCKED_NEWS ||
      gVegarExecutionState==VEGAR_EXECUTION_BLOCKED_SESSION ||
      gVegarExecutionState==VEGAR_EXECUTION_BLOCKED_SPREAD) return clrGold;
   return clrTomato;
  }

int Vegar_PanelNearestZoneIndex(const bool above)
  {
   if(!Vegar_UpdateTick()) return -1;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5;
   double best=DBL_MAX;
   int bestIdx=-1;

   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      if(!gVegarZones[i].valid || gVegarZones[i].symbol!=_Symbol || gVegarZones[i].role!=VEGAR_ZONE_ROLE_OPERATIONAL ||
         gVegarZones[i].state==VEGAR_ZONE_INVALIDATED ||
         gVegarZones[i].state==VEGAR_ZONE_EXPIRED || gVegarZones[i].state==VEGAR_ZONE_SWEPT)
         continue;

      double d=(above?gVegarZones[i].mid-p:p-gVegarZones[i].mid);
      if(d<0.0 || d>=best) continue;
      best=d;
      bestIdx=i;
     }

   return bestIdx;
  }

string Vegar_PanelZoneCompact(const int idx)
  {
   if(idx<0 || idx>=ArraySize(gVegarZones)) return "N/A";
   return Vegar_BiasText(gVegarZones[idx].operational_bias)+" | "+
          Vegar_TFText(gVegarZones[idx].source_tf)+" | F"+
          DoubleToString(gVegarZones[idx].strength_score,0)+" | "+
          Vegar_ZoneStateText(gVegarZones[idx].state);
  }

string Vegar_PanelZoneAlignment(const int zi)
  {
   if(zi<0 || zi>=ArraySize(gVegarZones)) return "NEUTRAL";

   ENUM_VEGAR_BIAS zone=gVegarZones[zi].operational_bias;
   ENUM_VEGAR_CHANNEL_DIRECTION ch=gVegarChannelM15.direction;

   if(ch==VEGAR_CHANNEL_NEUTRAL)
     {
      if((zone==VEGAR_BIAS_BUYER && gVegarM15Context==VEGAR_M15_TREND_UP) ||
         (zone==VEGAR_BIAS_SELLER && gVegarM15Context==VEGAR_M15_TREND_DOWN))
         return "PARTIAL";
      return "NEUTRAL";
     }

   if((zone==VEGAR_BIAS_BUYER && ch==VEGAR_CHANNEL_BUYER) ||
      (zone==VEGAR_BIAS_SELLER && ch==VEGAR_CHANNEL_SELLER))
      return "ALIGNED";

   return "CONFLICTING";
  }

string Vegar_StageText(const bool approved,const bool applicable=true)
  {
   if(!applicable) return "N/A";
   return (approved?"APROVADO":"AGUARDANDO");
  }

string Vegar_MoneyOrDash(const double value,const bool valid)
  {
   if(!valid) return "--";
   return DoubleToString(value,2)+" "+gVegarSymbol.account_currency;
  }

string Vegar_PriceOrDash(const double value)
  {
   if(value<=0.0) return "--";
   return DoubleToString(value,gVegarSymbol.digits);
  }

string Vegar_NewsStateText()
  {
   if(gVegarNewsStatus.state==VEGAR_NEWS_CLEAR) return "CLEAR";
   if(gVegarNewsStatus.state==VEGAR_NEWS_BLOCKED) return "BLOCKED";
   if(gVegarNewsStatus.state==VEGAR_NEWS_UNAVAILABLE) return "UNAVAILABLE";
   return "DISABLED";
  }

string Vegar_NewsImpactText(const int importance)
  {
   if(importance>=3) return "ALTO ("+(string)importance+")";
   if(importance==2) return "MEDIO (2)";
   if(importance==1) return "BAIXO (1)";
   return "N/A";
  }

string Vegar_SecondsHuman(const int sec)
  {
   if(sec==0) return "agora";
   int a=(int)MathAbs((double)sec);
   int h=a/3600;
   int m=(a%3600)/60;
   if(h>0) return StringFormat("%02dh%02dm",h,m);
   return StringFormat("%02dm",m);
  }

datetime Vegar_PanelPeriodStart(const int mode,const datetime now)
  {
   MqlDateTime d; TimeToStruct(now,d); d.hour=0; d.min=0; d.sec=0;
   if(mode==1)
     {
      datetime day=StructToTime(d); int dow=d.day_of_week; int back=(dow==0?6:dow-1); return day-back*86400;
     }
   if(mode==2) { d.day=1; return StructToTime(d); }
   if(mode==3) { d.mon=1; d.day=1; return StructToTime(d); }
   return Vegar_NewYorkTradingDayStartServer(now);
  }

void Vegar_PanelOwnedBreakdownSince(const datetime from,double &gross_profit,double &losses,double &commission,double &swap,double &fees,double &net,int &trades)
  {
   gross_profit=losses=commission=swap=fees=net=0.0; trades=0;
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent();
   if(!HistorySelect(from,now)) return;
   int total=HistoryDealsTotal();
   // First pass admits only explicit VEGAR evidence into the runtime registry.
   for(int i=0;i<total;i++)
     {
      ulong d=HistoryDealGetTicket(i); if(d==0)continue;
      if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol || (long)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagicNumber)continue;
      if(StringFind(HistoryDealGetString(d,DEAL_COMMENT),VEGAR_COMMENT_PREFIX)==0)
         Vegar_OwnershipRegisterPositionID((long)HistoryDealGetInteger(d,DEAL_POSITION_ID));
     }
   for(int i=0;i<total;i++)
     {
      ulong d=HistoryDealGetTicket(i); if(d==0)continue;
      if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol || (long)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagicNumber)continue;
      long pid=(long)HistoryDealGetInteger(d,DEAL_POSITION_ID); string c=HistoryDealGetString(d,DEAL_COMMENT);
      if(StringFind(c,VEGAR_COMMENT_PREFIX)!=0 && !Vegar_OwnershipHasPositionID(pid))continue;
      double pr=HistoryDealGetDouble(d,DEAL_PROFIT);
      if(pr>=0.0) gross_profit+=pr; else losses+=pr;
      commission+=HistoryDealGetDouble(d,DEAL_COMMISSION);
      swap+=HistoryDealGetDouble(d,DEAL_SWAP);
      fees+=HistoryDealGetDouble(d,DEAL_FEE);
      ENUM_DEAL_ENTRY e=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(d,DEAL_ENTRY);
      if(e==DEAL_ENTRY_OUT || e==DEAL_ENTRY_OUT_BY)trades++;
     }
   net=gross_profit+losses+commission+swap+fees;
  }

double Vegar_PanelOwnedResultSince(const datetime from,int &trades)
  {
   double g=0.0,l=0.0,c=0.0,s=0.0,f=0.0,n=0.0;
   Vegar_PanelOwnedBreakdownSince(from,g,l,c,s,f,n,trades);
   return n;
  }

string Vegar_PanelCompactMoney(const double v)
  {
   double a=MathAbs(v);
   if(a>=1000000.0) return DoubleToString(v/1000000.0,1)+"M";
   if(a>=1000.0) return DoubleToString(v/1000.0,1)+"K";
   return DoubleToString(v,1);
  }

string Vegar_PanelMoneyHuman(const double v)
  {
   string c=gVegarSymbol.account_currency;
   if(c=="USD") return "$"+DoubleToString(v,2);
   if(c=="EUR") return "EUR "+DoubleToString(v,2);
   if(c=="GBP") return "GBP "+DoubleToString(v,2);
   return c+" "+DoubleToString(v,2);
  }

void Vegar_PanelRefreshSlowStats()
  {
   ulong now=GetTickCount64();
   if(gVegarPanelStatsRefreshMsc!=0 && now-gVegarPanelStatsRefreshMsc<1000) return;
   gVegarPanelStatsRefreshMsc=now;
   Vegar_RefreshDailyStats(gVegarPanelCachedDailyNet,gVegarPanelCachedTrades,gVegarPanelCachedLossStreak);
  }

string Vegar_PanelPnlLine(const string tag,const double net,const double gross,const double losses,const double commission,const double swap,const double fees)
  {
   return tag+" N"+Vegar_PanelCompactMoney(net)+" B"+Vegar_PanelCompactMoney(gross)+" L"+Vegar_PanelCompactMoney(losses)+
          " C"+Vegar_PanelCompactMoney(commission)+" S"+Vegar_PanelCompactMoney(swap)+" F"+Vegar_PanelCompactMoney(fees);
  }

string Vegar_PanelMarketState()
  {
   ENUM_SYMBOL_TRADE_MODE m=(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   if(m==SYMBOL_TRADE_MODE_DISABLED || m==SYMBOL_TRADE_MODE_CLOSEONLY) return "FECHADO";
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)) return "FECHADO";
   if(!Vegar_RC8SymbolSessionOpen(_Symbol)) return "FECHADO";
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED) || !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return "FECHADO";
   return "ABERTO";
  }

string Vegar_PanelWaitingFor()
  {
   // Keep this field deliberately human and limited to the official operational vocabulary.
   if(gVegarIntent.valid && !gVegarIntent.processed) return "PREFLIGHT";
   if(gVegarOpportunity.active)
     {
      switch(gVegarOpportunity.state)
        {
         case VEGAR_SETUP_LIQUIDITY_APPROACH: return "SWEEP";
         case VEGAR_SETUP_SWEEP_CONFIRMED:
         case VEGAR_SETUP_WAITING_MSS: return "MSS";
         case VEGAR_SETUP_MSS_CONFIRMED:
         case VEGAR_SETUP_WAITING_DISPLACEMENT: return "DISP";
         case VEGAR_SETUP_DISPLACEMENT_CONFIRMED:
         case VEGAR_SETUP_ENTRY_ZONE_CREATED:
         case VEGAR_SETUP_WAITING_RETEST: return "RETEST";
         case VEGAR_SETUP_RETEST_CONFIRMED: return "GATES";
         case VEGAR_SETUP_ENTRY_INTENT:
         case VEGAR_SETUP_PREFLIGHT: return "PREFLIGHT";
         default: return "LOCALIZACAO";
        }
     }
   if(gVegarApproachLatch.active) return "SWEEP";
   if(gVegarObservationCandidate.active)
     {
      switch(gVegarObservationCandidate.state)
        {
         case VEGAR_SETUP_LIQUIDITY_APPROACH: return "SWEEP";
         case VEGAR_SETUP_SWEEP_CONFIRMED:
         case VEGAR_SETUP_WAITING_MSS: return "MSS";
         case VEGAR_SETUP_MSS_CONFIRMED:
         case VEGAR_SETUP_WAITING_DISPLACEMENT: return "DISP";
         case VEGAR_SETUP_DISPLACEMENT_CONFIRMED:
         case VEGAR_SETUP_ENTRY_ZONE_CREATED:
         case VEGAR_SETUP_WAITING_RETEST: return "RETEST";
         case VEGAR_SETUP_RETEST_CONFIRMED: return "GATES";
         default: return "LOCALIZACAO";
        }
     }
   double d=DBL_MAX; int zi=Vegar_SelectTechnicalCandidateZone();
   if(zi>=0)
     {
      double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
      if(atr>0.0 && gVegarTick.bid>0.0 && gVegarTick.ask>0.0)
        {
         double p=(gVegarTick.bid+gVegarTick.ask)*0.5,dp=0.0;
         if(p<gVegarZones[zi].low) dp=gVegarZones[zi].low-p;
         else if(p>gVegarZones[zi].high) dp=p-gVegarZones[zi].high;
         d=dp/atr;
        }
      if(d<=InpApproachDistanceATR) return "SWEEP";
     }
   return "LOCALIZACAO";
  }

string Vegar_PanelSignalState()
  {
   if(gVegarOpportunity.technical_signal_ready)
      return (gVegarOpportunity.direction==VEGAR_BIAS_BUYER?"COMPRA PRONTA":"VENDA PRONTA");
   if(gVegarObservationCandidate.technical_signal_ready) return "OBS READY";
   return "NENHUM";
  }

string Vegar_PanelPipelineState()
  {
   if((gVegarOpportunity.active || gVegarOpportunity.technical_signal_ready) && gVegarOpportunity.pipeline_state!="") return gVegarOpportunity.pipeline_state;
   if(gVegarOpportunity.active || gVegarOpportunity.technical_signal_ready) return Vegar_SetupStateText(gVegarOpportunity.state);
   if(gVegarApproachLatch.active) return "CANDIDATE_APPROACH";
   if(gVegarObservationCandidate.active) return "OBS_"+Vegar_SetupStateText(gVegarObservationCandidate.state);
   return "IDLE";
  }

void Vegar_PanelNearestObservation(string &id,ENUM_TIMEFRAMES &tf,ENUM_VEGAR_BIAS &dir,double &dist)
  {
   id=""; tf=PERIOD_CURRENT; dir=VEGAR_BIAS_NONE; dist=-1.0;
   if(gVegarTick.bid<=0.0 || gVegarTick.ask<=0.0) return;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0)return;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5,best=DBL_MAX;
   for(int i=0;i<ArraySize(gVegarObservationZones);i++)
     {
      SVegarZone z=gVegarObservationZones[i]; if(!z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OBSERVATION || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
      double dp=0.0; if(p<z.low)dp=z.low-p; else if(p>z.high)dp=p-z.high; double da=dp/atr;
      if(da<best){best=da;id=z.id;tf=z.source_tf;dir=z.operational_bias;dist=da;}
     }
  }



string Vegar_PanelFit(const string text,const int max_chars)
  {
   if(max_chars<=0) return "";
   int n=StringLen(text);
   if(n<=max_chars) return text;
   if(max_chars<=3) return StringSubstr(text,0,max_chars);
   return StringSubstr(text,0,max_chars-3)+"...";
  }

color Vegar_PanelColorTitle()     { return C'53,224,230'; }
color Vegar_PanelColorText()      { return C'232,238,245'; }
color Vegar_PanelColorSecondary() { return C'168,183,200'; }
color Vegar_PanelColorWeak()      { return C'120,136,154'; }
color Vegar_PanelColorOK()        { return C'46,230,166'; }
color Vegar_PanelColorAlert()     { return C'244,197,66'; }
color Vegar_PanelColorError()     { return C'255,91,91'; }
color Vegar_PanelColorBuy()       { return C'53,224,230'; }
color Vegar_PanelColorSell()      { return C'255,122,69'; }

string Vegar_PanelFamilyShort()
  {
   if(gVegarOpportunity.active || gVegarOpportunity.technical_signal_ready)
     {
      if(gVegarOpportunity.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION ||
         gVegarOpportunity.setup_family==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION_OBSERVATION) return "MICRO";
      return "STRUCTURAL";
     }
   if(gVegarObservationCandidate.active) return "MICRO";
   return (InpAtivarMicroContinuacaoOperacional ? "AMBAS" : "STRUCTURAL");
  }

string Vegar_PanelSignalHuman()
  {
   if(gVegarOpportunity.technical_signal_ready)
     {
      if(!gVegarOpportunity.execution_authorized) return "BLOQUEADO";
      return (gVegarOpportunity.direction==VEGAR_BIAS_BUYER ? "BUY READY" : "SELL READY");
     }
   // Observation-only micro candidates are telemetry, not an execution-ready signal.
   return "NENHUM";
  }

color Vegar_PanelSignalColor()
  {
   string s=Vegar_PanelSignalHuman();
   if(s=="BUY READY") return Vegar_PanelColorBuy();
   if(s=="SELL READY") return Vegar_PanelColorSell();
   if(s=="BLOQUEADO") return Vegar_PanelColorAlert();
   return Vegar_PanelColorSecondary();
  }

string Vegar_PanelBlockShort()
  {
   if(gVegarExecutionState==VEGAR_EXECUTION_ENABLED) return "--";
   switch(gVegarExecutionState)
     {
      case VEGAR_EXECUTION_BLOCKED_CONFIGURATION: return "CONFIG";
      case VEGAR_EXECUTION_BLOCKED_SESSION:       return "SESSAO";
      case VEGAR_EXECUTION_BLOCKED_NEWS:          return "NEWS";
      case VEGAR_EXECUTION_BLOCKED_SPREAD:        return "SPREAD";
      case VEGAR_EXECUTION_BLOCKED_RISK:          return "RISCO";
      case VEGAR_EXECUTION_BLOCKED_DAILY_LIMIT:   return "LIMITE DIARIO";
      case VEGAR_EXECUTION_BLOCKED_POSITION:      return "POSICAO";
      case VEGAR_EXECUTION_BLOCKED_MARKET:        return "MERCADO";
      case VEGAR_EXECUTION_BLOCKED_EXECUTION:     return (gVegarEngineState==VEGAR_ENGINE_PAUSED?"PAUSADO":"EXECUCAO");
      case VEGAR_EXECUTION_BLOCKED_DATA:          return "DADOS";
      case VEGAR_EXECUTION_BLOCKED_ACCOUNT:       return "CONTA";
      case VEGAR_EXECUTION_BLOCKED_SELF_TEST:     return "SELF-TEST";
      case VEGAR_EXECUTION_BLOCKED_RECOVERY:      return "RECOVERY";
      case VEGAR_EXECUTION_BLOCKED_OWNERSHIP:     return "OWNERSHIP";
      case VEGAR_EXECUTION_ERROR:                 return "ERRO";
      default:                                    return "BLOQUEADO";
     }
  }

string Vegar_PanelStageValue(const string stage)
  {
   datetime sweep=0,mss=0,disp=0,retest=0;
   if(gVegarOpportunity.active || gVegarOpportunity.technical_signal_ready)
     {
      sweep=gVegarOpportunity.sweep_time;
      mss=gVegarOpportunity.mss_time;
      disp=gVegarOpportunity.displacement_time;
      retest=gVegarOpportunity.retest_time;
     }
   else if(gVegarObservationCandidate.active)
     {
      sweep=gVegarObservationCandidate.sweep_time;
      mss=gVegarObservationCandidate.mss_time;
      disp=gVegarObservationCandidate.displacement_time;
      retest=gVegarObservationCandidate.retest_time;
     }

   if(stage=="SWEEP" && sweep>0) return "✓";
   if(stage=="MSS" && mss>0) return "✓";
   if(stage=="DISP" && disp>0) return "✓";
   if(stage=="RETEST" && retest>0) return "✓";
   string w=Vegar_PanelWaitingFor();
   if((stage=="SWEEP" && w=="SWEEP") ||
      (stage=="MSS" && w=="MSS") ||
      (stage=="DISP" && w=="DISP") ||
      (stage=="RETEST" && w=="RETEST")) return "aguardando";
   return "--";
  }

color Vegar_PanelStageColor(const string value)
  {
   if(value=="✓") return Vegar_PanelColorOK();
   if(value=="falhou") return Vegar_PanelColorError();
   if(value=="aguardando") return Vegar_PanelColorSecondary();
   return Vegar_PanelColorWeak();
  }

string Vegar_PanelDirectionText(const ENUM_VEGAR_BIAS d)
  {
   if(d==VEGAR_BIAS_BUYER) return "BUY";
   if(d==VEGAR_BIAS_SELLER) return "SELL";
   return "NEUTRO";
  }

color Vegar_PanelDirectionColor(const ENUM_VEGAR_BIAS d)
  {
   if(d==VEGAR_BIAS_BUYER) return Vegar_PanelColorBuy();
   if(d==VEGAR_BIAS_SELLER) return Vegar_PanelColorSell();
   return Vegar_PanelColorSecondary();
  }

string Vegar_PanelZoneShort(const int zi)
  {
   if(zi<0 || zi>=ArraySize(gVegarZones)) return "--";
   string side=Vegar_VisualBiasShort(gVegarZones[zi].operational_bias);
   string prefix=(gVegarZones[zi].focus?"[FOCO ":"[")+side+"] ";
   return prefix+Vegar_TFText(gVegarZones[zi].source_tf)+" F"+DoubleToString(gVegarZones[zi].strength_score,0);
  }

string Vegar_PanelObservationShort(const string id,const ENUM_TIMEFRAMES tf,const ENUM_VEGAR_BIAS dir,const double strength=-1.0)
  {
   if(id=="") return "--";
   string v="[OBS "+Vegar_VisualBiasShort(dir)+"] "+Vegar_TFText(tf);
   if(strength>=0.0) v+=" F"+DoubleToString(strength,0);
   return v;
  }

double Vegar_PanelDistanceToRangeATR(const double low,const double high)
  {
   if(low<=0.0 || high<=0.0 || gVegarTick.bid<=0.0 || gVegarTick.ask<=0.0) return -1.0;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) return -1.0;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5,dp=0.0;
   if(p<low) dp=low-p; else if(p>high) dp=p-high;
   return dp/atr;
  }

void Vegar_PanelInit()
  {
   color bg=C'7,16,25';
   color card=C'12,24,38';
   color border=C'34,53,74';

   if(gVegarPanelMinimized)
     {
      Vegar_PanelBox("BG",10,18,460,92,bg,border);
      Vegar_PanelBox("BOX_MIN",18,26,444,76,card,border);
      Vegar_PanelButton("BTN_MINMAX",430,30,24,20,"□");
      Vegar_PanelEnforceTopLayer();
      return;
     }

   Vegar_PanelBox("BG",10,18,460,620,bg,border);
   Vegar_PanelBox("BOX_HEADER",18,26,444,58,card,border);
   Vegar_PanelBox("BOX_STATE",18,90,444,88,card,border);
   Vegar_PanelBox("BOX_SETUP",18,184,219,180,card,border);
   Vegar_PanelBox("BOX_RISK",243,184,219,180,card,border);
   Vegar_PanelBox("BOX_CONTEXT",18,370,444,76,card,border);
   Vegar_PanelBox("BOX_POSITION",18,452,444,96,card,border);
   Vegar_PanelBox("BOX_FOOT",18,554,444,44,card,border);

   Vegar_PanelButton("BTN_MINMAX",430,30,24,20,"—");
   Vegar_PanelButton("BTN_PAUSE",18,604,95,26,"PAUSAR");
   Vegar_PanelButton("BTN_FLUSH",121,604,75,26,"CSV");
   Vegar_PanelButton("BTN_CLEAR",204,604,95,26,"LIMPAR");
   Vegar_PanelButton("BTN_CLOSE",307,604,95,26,"FECHAR");
   Vegar_PanelEnforceTopLayer();
  }

void Vegar_PanelUpdate()
  {
   Vegar_PanelInit();
   SVegarSessionStatus sess=Vegar_CurrentSessionStatus();
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();

   Vegar_PanelRefreshSlowStats();
   double dailyNet=gVegarPanelCachedDailyNet;
   int trades=gVegarPanelCachedTrades;
   int losses=gVegarPanelCachedLossStreak;

   bool online=(bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   color onlineColor=(online?Vegar_PanelColorOK():Vegar_PanelColorError());
   string waiting=Vegar_PanelWaitingFor();
   string block=Vegar_PanelBlockShort();

   if(gVegarPanelMinimized)
     {
      string posText="Sem posicao";
      if(Vegar_HasOwnedPosition() && gVegarProfit.active)
         posText="Posicao | "+Vegar_PanelDirectionText(gVegarProfit.direction)+" | "+Vegar_PanelCompactMoney(gVegarProfit.current_net_profit_money);
      Vegar_PanelLabel("MIN_TITLE",28,32,Vegar_PanelFit("VEGAR | "+_Symbol+" | "+Vegar_TFText(Vegar_ExecutionTF())+" | "+Vegar_EnvironmentText(gVegarEnvironment),49),Vegar_PanelColorText(),10);
      Vegar_PanelLabel("MIN_ONLINE",355,32,online?"ONLINE":"OFFLINE",onlineColor,9);
      Vegar_PanelLabel("MIN_STATE",28,55,Vegar_PanelFit("Motor: "+Vegar_EngineStateText(gVegarEngineState)+" | Sinal: "+Vegar_PanelSignalHuman()+" | Aguardando: "+waiting,58),Vegar_PanelColorSecondary(),9);
      Vegar_PanelLabel("MIN_POS",28,77,Vegar_PanelFit(posText+" | Hoje: "+Vegar_PanelMoneyHuman(dailyNet),58),Vegar_PanelColorSecondary(),9);
      ObjectSetString(0,VEGAR_PANEL_PREFIX+"BTN_MINMAX",OBJPROP_TEXT,"□");
      Vegar_PanelEnforceTopLayer();
      ChartRedraw();
      return;
     }

   int zi=Vegar_FocusZoneIndex();
   string obsId=""; ENUM_TIMEFRAMES obsTf=PERIOD_CURRENT; ENUM_VEGAR_BIAS obsDir=VEGAR_BIAS_NONE; double obsDist=-1.0;
   Vegar_PanelNearestObservation(obsId,obsTf,obsDir,obsDist);

   ENUM_VEGAR_BIAS setupDir=VEGAR_BIAS_NONE;
   if(gVegarOpportunity.active || gVegarOpportunity.technical_signal_ready) setupDir=gVegarOpportunity.direction;
   else if(gVegarObservationCandidate.active) setupDir=gVegarObservationCandidate.direction;
   else if(zi>=0 && zi<ArraySize(gVegarZones)) setupDir=gVegarZones[zi].operational_bias;
   else if(obsId!="") setupDir=obsDir;

   double focusDist=-1.0;
   if(zi>=0 && zi<ArraySize(gVegarZones) && gVegarTick.bid>0.0 && gVegarTick.ask>0.0)
     {
      double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
      if(atr>0.0)
        {
         double p=(gVegarTick.bid+gVegarTick.ask)*0.5,dp=0.0;
         if(p<gVegarZones[zi].low) dp=gVegarZones[zi].low-p;
         else if(p>gVegarZones[zi].high) dp=p-gVegarZones[zi].high;
         focusDist=dp/atr;
        }
     }

   string setupZone="--";
   double setupDist=-1.0;
   if(gVegarOpportunity.active || gVegarOpportunity.technical_signal_ready)
     {
      if(gVegarOpportunity.source_zone_role==VEGAR_ZONE_ROLE_OBSERVATION)
         setupZone=Vegar_PanelObservationShort(gVegarOpportunity.source_zone_id,gVegarOpportunity.source_zone_tf,gVegarOpportunity.direction,gVegarOpportunity.focus_zone_strength);
      else
         setupZone="[FOCO "+Vegar_VisualBiasShort(gVegarOpportunity.direction)+"] "+Vegar_TFText(gVegarOpportunity.source_zone_tf)+" F"+DoubleToString(gVegarOpportunity.focus_zone_strength,0);
      setupDist=Vegar_PanelDistanceToRangeATR(gVegarOpportunity.source_zone_low,gVegarOpportunity.source_zone_high);
     }
   else if(gVegarObservationCandidate.active)
     {
      setupZone=Vegar_PanelObservationShort(gVegarObservationCandidate.zone_id,gVegarObservationCandidate.zone_tf,gVegarObservationCandidate.direction,gVegarObservationCandidate.zone_strength);
      for(int oi=0;oi<ArraySize(gVegarObservationZones);oi++)
        if(gVegarObservationZones[oi].id==gVegarObservationCandidate.zone_id)
          { setupDist=Vegar_PanelDistanceToRangeATR(gVegarObservationZones[oi].low,gVegarObservationZones[oi].high); break; }
     }
   else if(zi>=0)
     { setupZone=Vegar_PanelZoneShort(zi); setupDist=focusDist; }
   else
     { setupZone=Vegar_PanelObservationShort(obsId,obsTf,obsDir); setupDist=obsDist; }

   // HEADER
   Vegar_PanelLabel("TITLE",28,32,"VEGAR",Vegar_PanelColorText(),12);
   Vegar_PanelLabel("ONLINE",362,33,online?"ONLINE":"OFFLINE",onlineColor,9);
   Vegar_PanelLabel("SUB",28,58,Vegar_PanelFit(_Symbol+" | "+Vegar_TFText(Vegar_ExecutionTF())+" | "+Vegar_EnvironmentText(gVegarEnvironment),28),Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("TIME",246,58,Vegar_PanelFit("SERVER "+TimeToString(sess.server_time,TIME_SECONDS)+"  NY "+TimeToString(sess.ny_time,TIME_SECONDS),31),Vegar_PanelColorWeak(),9);

   // ESTADO OPERACIONAL
   Vegar_PanelLabel("STATE_TITLE",28,98,"ESTADO OPERACIONAL",Vegar_PanelColorTitle(),10);
   color engineColor=(gVegarEngineState==VEGAR_ENGINE_ACTIVE?Vegar_PanelColorOK():(gVegarEngineState==VEGAR_ENGINE_PAUSED?Vegar_PanelColorAlert():Vegar_PanelColorError()));
   color marketColor=(Vegar_PanelMarketState()=="ABERTO"?Vegar_PanelColorOK():Vegar_PanelColorAlert());
   color configColor=(gVegarConfigValidity==VEGAR_CONFIG_VALID?Vegar_PanelColorOK():Vegar_PanelColorError());
   Vegar_PanelLabel("STATE_MOTOR",28,120,Vegar_PanelFit("Motor: "+Vegar_EngineStateText(gVegarEngineState),21),engineColor,9);
   Vegar_PanelLabel("STATE_MARKET",168,120,Vegar_PanelFit("Mercado: "+Vegar_PanelMarketState(),19),marketColor,9);
   Vegar_PanelLabel("STATE_CONFIG",323,120,Vegar_PanelFit("Config: "+Vegar_ConfigPanelText(),17),configColor,9);
   Vegar_PanelLabel("STATE_SIGNAL",28,141,Vegar_PanelFit("Sinal: "+Vegar_PanelSignalHuman(),21),Vegar_PanelSignalColor(),9);
   Vegar_PanelLabel("STATE_FAMILY",168,141,Vegar_PanelFit("Familia: "+Vegar_PanelFamilyShort(),20),Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("STATE_WAIT",323,141,Vegar_PanelFit("Aguardando: "+waiting,18),Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("STATE_BLOCK",28,161,Vegar_PanelFit("Bloqueio: "+block,60),block=="--"?Vegar_PanelColorWeak():Vegar_PanelColorAlert(),9);

   // SETUP
   Vegar_PanelLabel("SETUP_TITLE",28,192,"SETUP",Vegar_PanelColorTitle(),10);
   Vegar_PanelLabel("SETUP_DIR",28,214,"Direcao: "+Vegar_PanelDirectionText(setupDir),Vegar_PanelDirectionColor(setupDir),9);
   Vegar_PanelLabel("SETUP_ZONE",28,234,Vegar_PanelFit("Zona: "+setupZone,27),Vegar_PanelColorText(),9);
   Vegar_PanelLabel("SETUP_DIST",28,254,"Distancia: "+(setupDist>=0.0?DoubleToString(setupDist,2)+" ATR":"--"),Vegar_PanelColorSecondary(),9);
   string sw=Vegar_PanelStageValue("SWEEP"), ms=Vegar_PanelStageValue("MSS"), di=Vegar_PanelStageValue("DISP"), re=Vegar_PanelStageValue("RETEST");
   Vegar_PanelLabel("SETUP_SW",28,274,"Sweep: "+sw,Vegar_PanelStageColor(sw),9);
   Vegar_PanelLabel("SETUP_MSS",28,294,"MSS: "+ms,Vegar_PanelStageColor(ms),9);
   Vegar_PanelLabel("SETUP_DISP",28,314,"Disp: "+di,Vegar_PanelStageColor(di),9);
   Vegar_PanelLabel("SETUP_RET",28,334,"Retest: "+re,Vegar_PanelStageColor(re),9);

   // RISCO
   double spreadMoney=Vegar_SpreadMoney(InpLoteOperacional);
   double newTradeRisk=(InpAtivarStopLoss?MathMax(0.0,gVegarOpportunity.technical_stop_money)+Vegar_EstimatedRoundTurnCommission(InpLoteOperacional):MathMax(0.0,InpLimitePerdaDiariaMoney));
   double dailyRemain=InpLimitePerdaDiariaMoney-Vegar_RealizedLossTodayMoney()-Vegar_OpenWorstCaseRiskMoney()-newTradeRisk;
   Vegar_PanelLabel("RISK_TITLE",253,192,"RISCO",Vegar_PanelColorTitle(),10);
   Vegar_PanelLabel("RISK_LOT",253,214,"Lote: "+DoubleToString(InpLoteOperacional,2),Vegar_PanelColorText(),9);
   Vegar_PanelLabel("RISK_STOP",253,234,"Stop: "+(InpAtivarStopLoss?"ON":"OFF"),InpAtivarStopLoss?Vegar_PanelColorSecondary():Vegar_PanelColorAlert(),9);
   Vegar_PanelLabel("RISK_SPREAD",253,254,Vegar_PanelFit("Spread: "+DoubleToString(Vegar_CurrentSpreadPoints(),1)+" pts / "+Vegar_PanelMoneyHuman(spreadMoney),27),Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("RISK_BUDGET",253,274,"Budget Dia: "+(InpLimitePerdaDiariaMoney>0.0?Vegar_PanelMoneyHuman(InpLimitePerdaDiariaMoney):"OFF"),Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("RISK_REMAIN",253,294,"Restante: "+(InpLimitePerdaDiariaMoney>0.0?Vegar_PanelMoneyHuman(dailyRemain):"OFF"),dailyRemain<0.0?Vegar_PanelColorError():Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("RISK_TRADES",253,314,"Trades: "+(string)trades+" / "+(string)InpMaxTradesPerDay,Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("RISK_LOSS",253,334,"Loss Streak: "+(string)losses,Vegar_PanelColorSecondary(),9);

   // CONTEXTO
   Vegar_PanelLabel("CTX_TITLE",28,378,"CONTEXTO",Vegar_PanelColorTitle(),10);
   string h4=Vegar_ChannelText(gVegarChannelH4.direction)+" F"+DoubleToString(gVegarChannelH4.strength_score,0);
   string m15=Vegar_ChannelText(gVegarChannelM15.direction)+" F"+DoubleToString(gVegarChannelM15.strength_score,0);
   Vegar_PanelLabel("CTX_1",28,400,Vegar_PanelFit("H4: "+h4+" | M15: "+m15+" | Flow: "+DoubleToString(gVegarExecutionFlow.flow_score,0)+" | News: "+Vegar_NewsStateText(),64),Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("CTX_2",28,422,Vegar_PanelFit("Focus estrutural: "+(focusDist>=0.0?DoubleToString(focusDist,2)+" ATR":"--")+" | Microzona: "+(obsDist>=0.0?DoubleToString(obsDist,2)+" ATR":"--"),64),Vegar_PanelColorSecondary(),9);

   // POSICAO / PROFIT
   Vegar_PanelLabel("POS_TITLE",28,460,"POSICAO / PROFIT",Vegar_PanelColorTitle(),10);
   ulong pt=0; long pid=0; ENUM_VEGAR_BIAS pd=VEGAR_BIAS_NONE; double pe=0.0,pv=0.0;
   bool hasPos=Vegar_FindOwnedPosition(pt,pid,pd,pe,pv);
   bool floatingKnown=(hasPos && gVegarProfit.active);
   double floating=(floatingKnown?gVegarProfit.current_net_profit_money:0.0);
   string pmode=(InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT?"TP":(InpModoGestaoLucro==VEGAR_PROFIT_RUNNER?"RUNNER":"HYBRID"));
   if(!hasPos)
      Vegar_PanelLabel("POS_1",28,482,"Sem posicao",Vegar_PanelColorWeak(),9);
   else
      Vegar_PanelLabel("POS_1",28,482,Vegar_PanelFit(Vegar_PanelDirectionText(pd)+" | Lote "+DoubleToString(pv,2)+" | Preco "+DoubleToString(pe,gVegarSymbol.digits)+" | Floating "+(floatingKnown?Vegar_PanelMoneyHuman(floating):"--"),60),Vegar_PanelDirectionColor(pd),9);
   Vegar_PanelLabel("POS_2",28,504,Vegar_PanelFit("Meta Op: "+(InpAtivarMetaOperacao?Vegar_PanelMoneyHuman(InpMetaOperacaoMoney):"OFF")+" | TP: "+(InpAtivarTakeProfit?Vegar_PanelMoneyHuman(InpTakeProfitMoney):"OFF")+" | Modo: "+pmode+" | Hoje: "+Vegar_PanelMoneyHuman(dailyNet),62),Vegar_PanelColorSecondary(),9);
   Vegar_PanelLabel("POS_3",28,526,Vegar_PanelFit("Floating: "+(floatingKnown?Vegar_PanelMoneyHuman(floating):"--")+" | Peak: "+((gVegarProfit.active&&gVegarProfit.peak_known)?Vegar_PanelMoneyHuman(gVegarProfit.peak_profit_money):"--")+" | Floor: "+(gVegarProfit.protected_floor_installed?Vegar_PanelMoneyHuman(gVegarProfit.protected_profit_money):"--")+" | Runner: "+(gVegarProfit.runner_active?"ATIVO":"AGUARDANDO"),64),Vegar_PanelColorSecondary(),9);

   // FOOTER
   string actionText="--";
   if(gVegarPanelLastActionTime>0 && now-gVegarPanelLastActionTime<=3) actionText=gVegarPanelLastActionText;
   color actionColor=(gVegarPanelLastActionSeverity>=2?Vegar_PanelColorError():(gVegarPanelLastActionSeverity==1?Vegar_PanelColorAlert():Vegar_PanelColorSecondary()));
   Vegar_PanelLabel("LAST_ACTION",28,561,Vegar_PanelFit("Ultima acao: "+actionText,62),actionColor,9);
   Vegar_PanelLabel("FOOT",28,580,Vegar_PanelFit("Broker: "+AccountInfoString(ACCOUNT_COMPANY)+" | Bal: "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+" | Eq: "+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2),62),Vegar_PanelColorWeak(),9);

   ObjectSetString(0,VEGAR_PANEL_PREFIX+"BTN_PAUSE",OBJPROP_TEXT,gVegarEngineState==VEGAR_ENGINE_PAUSED?"RETOMAR":"PAUSAR");
   if(gVegarCloseConfirmUntil>TimeCurrent()) ObjectSetString(0,VEGAR_PANEL_PREFIX+"BTN_CLOSE",OBJPROP_TEXT,"CONFIRMAR");
   else ObjectSetString(0,VEGAR_PANEL_PREFIX+"BTN_CLOSE",OBJPROP_TEXT,"FECHAR");

   Vegar_PanelEnforceTopLayer();
   ChartRedraw();
  }

bool Vegar_PanelHandleChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK) return false;
   if(StringFind(sparam,VEGAR_PANEL_PREFIX)!=0) return false;

   ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
   string clicked=StringSubstr(sparam,StringLen(VEGAR_PANEL_PREFIX));
   Vegar_WriteDiagnostic("BUTTON_CLICK_RECEIVED","USER_ACTION","NONE",clicked,"Object="+sparam);
   Vegar_PanelActionFeedback("PROCESSANDO","RECEIVED",0,clicked);

   if(sparam==VEGAR_PANEL_PREFIX+"BTN_MINMAX")
     {
      gVegarPanelMinimized=!gVegarPanelMinimized;
      Vegar_PanelDelete();
      Vegar_WriteDiagnostic(gVegarPanelMinimized?"PANEL_MINIMIZED":"PANEL_MAXIMIZED",
                            "USER_ACTION","NONE","",
                            "UI-only action; engine, position management, state machine and CSV remain active");
      Vegar_PanelActionFeedback(gVegarPanelMinimized?"PAINEL MINIMIZADO":"PAINEL MAXIMIZADO","SUCCESS",0,"BTN_MINMAX");
      Vegar_WriteDiagnostic("BUTTON_ACTION_SUCCESS","SUCCESS","NONE","BTN_MINMAX",gVegarPanelLastActionText);
      Vegar_PanelUpdate();
      return true;
     }

   if(sparam==VEGAR_PANEL_PREFIX+"BTN_PAUSE")
     {
      bool pausing=(gVegarEngineState!=VEGAR_ENGINE_PAUSED);
      if(pausing)
        {
         gVegarEntriesPaused=true;
         gVegarEngineState=VEGAR_ENGINE_PAUSED;
         Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_EXECUTION,ENGINE_PAUSED,"USER_PAUSE");
         if(gVegarOpportunity.active)
            Vegar_TerminateOpportunity(VEGAR_SETUP_BLOCKED,ENGINE_PAUSED,"USER_PAUSE");
         if(gVegarIntent.valid && !gVegarIntent.processed)
            gVegarIntent.processed=true;
         Vegar_WriteDiagnostic("ENGINE_PAUSED","USER_ACTION",Vegar_ReasonText(ENGINE_PAUSED),"","New entries paused; open-position management remains active");
         Vegar_PanelActionFeedback("ENTRADAS PAUSADAS","SUCCESS",1,"BTN_PAUSE");
         Vegar_WriteDiagnostic("BUTTON_ACTION_SUCCESS","SUCCESS","NONE","BTN_PAUSE","ENTRADAS PAUSADAS");
        }
      else
        {
         gVegarEntriesPaused=false;
         gVegarEngineState=VEGAR_ENGINE_ACTIVE;
         Vegar_ResetIntent();
         Vegar_WriteDiagnostic("ENGINE_RESUMED","USER_ACTION","NONE","","Old EntryIntent not reused; waiting for contemporary setup");
         Vegar_PanelActionFeedback("VEGAR RETOMADO","SUCCESS",0,"BTN_PAUSE");
         Vegar_WriteDiagnostic("BUTTON_ACTION_SUCCESS","SUCCESS","NONE","BTN_PAUSE","VEGAR RETOMADO");
        }

      Vegar_PanelUpdate();
      return true;
     }

   if(sparam==VEGAR_PANEL_PREFIX+"BTN_FLUSH")
     {
      Vegar_FlushCsv();
      Vegar_WriteDiagnostic("CSV_MANUAL_FLUSH","USER_ACTION","NONE","","Panel button");
      Vegar_PanelActionFeedback("CSV SALVO","SUCCESS",0,"BTN_FLUSH");
      Vegar_WriteDiagnostic("BUTTON_ACTION_SUCCESS","SUCCESS","NONE","BTN_FLUSH","CSV SALVO");
      Vegar_PanelUpdate();
      return true;
     }

   if(sparam==VEGAR_PANEL_PREFIX+"BTN_CLEAR")
     {
      Vegar_ClearHistoricalVisualMarks();
      Vegar_RefreshVisuals();
      Vegar_WriteDiagnostic("VISUAL_MARKS_CLEARED","USER_ACTION","NONE","","Historical markers/events removed; active structure rebuilt");
      Vegar_PanelActionFeedback("MARCAS LIMPAS","SUCCESS",0,"BTN_CLEAR");
      Vegar_WriteDiagnostic("BUTTON_ACTION_SUCCESS","SUCCESS","NONE","BTN_CLEAR","MARCAS LIMPAS");
      Vegar_PanelUpdate();
      return true;
     }

   if(sparam==VEGAR_PANEL_PREFIX+"BTN_CLOSE")
     {
      datetime now=TimeCurrent();
      if(gVegarCloseConfirmUntil>now)
        {
         gVegarCloseConfirmUntil=0;
         if(!Vegar_HasOwnedPosition())
           {
            Vegar_PanelActionFeedback("NENHUMA POSICAO VEGAR","NO_POSITION",1,"BTN_CLOSE");
            Vegar_WriteDiagnostic("BUTTON_ACTION_SUCCESS","NO_POSITION","NONE","BTN_CLOSE","NENHUMA POSICAO VEGAR");
           }
         else
           {
            bool closed=Vegar_CloseOwnedPosition("USER_PANEL_CLOSE");
            if(closed)
              {
               Vegar_PanelActionFeedback("FECHAMENTO SOLICITADO","SUCCESS",1,"BTN_CLOSE");
               Vegar_WriteDiagnostic("BUTTON_ACTION_SUCCESS","SUCCESS","NONE","BTN_CLOSE","FECHAMENTO SOLICITADO");
              }
            else
              {
               Vegar_PanelActionFeedback("FALHA: FECHAMENTO","FAILED",2,"BTN_CLOSE");
               Vegar_WriteDiagnostic("BUTTON_ACTION_FAILED","FAILED","ORDER_SEND_REJECTED","BTN_CLOSE","Close request failed");
              }
           }
        }
      else
        {
         gVegarCloseConfirmUntil=now+10;
         Vegar_PanelActionFeedback("CONFIRMAR FECHAR","CONFIRM",1,"BTN_CLOSE");
        }

      Vegar_PanelUpdate();
      return true;
     }

   return false;
  }

#endif
