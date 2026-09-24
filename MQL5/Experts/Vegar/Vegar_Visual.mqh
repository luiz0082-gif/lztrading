#ifndef __VEGAR_VISUAL_MQH__
#define __VEGAR_VISUAL_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Liquidity.mqh"
#include "Vegar_Channel.mqh"
#include "Vegar_Setup.mqh"
#include "Vegar_Profit.mqh"

#define VEGAR_VIS_PREFIX "VEGAR_VIS_"

color Vegar_BlendColor(const color fg,const color bg,const int alpha_0_255)
  {
   int a=(int)MathMax(0,MathMin(255,alpha_0_255));
   long f=(long)fg,b=(long)bg;
   int fr=(int)(f & 0xFF), fg_g=(int)((f>>8) & 0xFF), fb=(int)((f>>16) & 0xFF);
   int br=(int)(b & 0xFF), bg_g=(int)((b>>8) & 0xFF), bb=(int)((b>>16) & 0xFF);
   int rr=(fr*a+br*(255-a))/255;
   int rg=(fg_g*a+bg_g*(255-a))/255;
   int rb=(fb*a+bb*(255-a))/255;
   return (color)(rr | (rg<<8) | (rb<<16));
  }

color Vegar_VisualOpacityColor(const color c,const int alpha_0_255)
  {
   long raw=0;
   if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,raw)) raw=(long)clrBlack;
   return Vegar_BlendColor(c,(color)raw,alpha_0_255);
  }

void Vegar_SetMarketObjectLayer(const string name,const bool foreground=false,const int zorder=0)
  {
   if(ObjectFind(0,name)<0) return;
   ObjectSetInteger(0,name,OBJPROP_BACK,!foreground);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

color Vegar_BuyerColor(const ENUM_VEGAR_STRENGTH_CLASS c)
  {
   if(c==VEGAR_STRENGTH_MUITO_FRACA) return C'52,84,76';
   if(c==VEGAR_STRENGTH_FRACA) return C'37,125,98';
   if(c==VEGAR_STRENGTH_MEDIA) return C'20,170,120';
   if(c==VEGAR_STRENGTH_FORTE) return C'0,215,150';
   return C'0,255,180';
  }

color Vegar_SellerColor(const ENUM_VEGAR_STRENGTH_CLASS c)
  {
   if(c==VEGAR_STRENGTH_MUITO_FRACA) return C'92,58,52';
   if(c==VEGAR_STRENGTH_FRACA) return C'145,68,55';
   if(c==VEGAR_STRENGTH_MEDIA) return C'195,70,55';
   if(c==VEGAR_STRENGTH_FORTE) return C'235,60,50';
   return C'255,45,55';
  }

color Vegar_ZoneColor(const SVegarZone &z)
  {
   if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED) return clrDimGray;
   return (z.operational_bias==VEGAR_BIAS_BUYER?Vegar_BuyerColor(z.strength_class):Vegar_SellerColor(z.strength_class));
  }

void Vegar_DeleteVisualObjects()
  {
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,VEGAR_VIS_PREFIX)==0) ObjectDelete(0,name);
     }
  }

void Vegar_DeleteZoneObjectsById(const string zone_id)
  {
   string box=VEGAR_VIS_PREFIX+"ZONE_"+zone_id;
   string border=VEGAR_VIS_PREFIX+"ZONE_BORDER_"+zone_id;
   string label=VEGAR_VIS_PREFIX+"ZLBL_"+zone_id;
   if(ObjectFind(0,box)>=0) ObjectDelete(0,box);
   if(ObjectFind(0,border)>=0) ObjectDelete(0,border);
   if(ObjectFind(0,label)>=0) ObjectDelete(0,label);
  }

bool Vegar_StringArrayContains(string &items[],const string value)
  {
   for(int i=0;i<ArraySize(items);i++)
      if(items[i]==value) return true;
   return false;
  }

void Vegar_AddDesiredVisual(string &items[],const string value)
  {
   if(Vegar_StringArrayContains(items,value)) return;
   int n=ArraySize(items);
   ArrayResize(items,n+1);
   items[n]=value;
  }

void Vegar_PruneZoneVisuals(string &desired[])
  {
   string p1=VEGAR_VIS_PREFIX+"ZONE_";
   string p2=VEGAR_VIS_PREFIX+"ZLBL_";
   string p3=VEGAR_VIS_PREFIX+"ZONE_BORDER_";
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,-1);
      if((StringFind(name,p1)==0 || StringFind(name,p2)==0 || StringFind(name,p3)==0) && !Vegar_StringArrayContains(desired,name))
         ObjectDelete(0,name);
     }
  }

void Vegar_DeleteChannelObjects(const ENUM_TIMEFRAMES tf)
  {
   string suffix=Vegar_TFText(tf);
   string names[5];
   names[0]=VEGAR_VIS_PREFIX+"CH_A_"+suffix;
   names[1]=VEGAR_VIS_PREFIX+"CH_B_"+suffix;
   names[2]=VEGAR_VIS_PREFIX+"CH_MID_"+suffix;
   names[3]=VEGAR_VIS_PREFIX+"CH_LBL_"+suffix;
   names[4]=VEGAR_VIS_PREFIX+"CH_BAND_"+suffix;
   for(int i=0;i<5;i++)
      if(ObjectFind(0,names[i])>=0) ObjectDelete(0,names[i]);
  }

void Vegar_PruneRetestVisuals()
  {
   string currentBox="";
   string currentLabel="";
   if(gVegarOpportunity.active && gVegarOpportunity.retest_type!=VEGAR_RETEST_NONE &&
      gVegarOpportunity.retest_low>0.0)
     {
      currentBox=VEGAR_VIS_PREFIX+"RETEST_"+gVegarOpportunity.opportunity_id;
      currentLabel=VEGAR_VIS_PREFIX+"RETEST_LBL_"+gVegarOpportunity.opportunity_id;
     }

   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,-1);
      bool isRetest=(StringFind(name,VEGAR_VIS_PREFIX+"RETEST_")==0 ||
                     StringFind(name,VEGAR_VIS_PREFIX+"RETEST_LBL_")==0);
      if(isRetest && name!=currentBox && name!=currentLabel)
         ObjectDelete(0,name);
     }
  }


string Vegar_VisualBiasShort(const ENUM_VEGAR_BIAS bias)
  {
   return (bias==VEGAR_BIAS_BUYER ? "B" : (bias==VEGAR_BIAS_SELLER ? "S" : "N"));
  }

int Vegar_VisualLaneIndex(const datetime t,const int salt=0)
  {
   long v=(long)t+(long)salt*17;
   if(v<0) v=-v;
   return (int)(v%3);
  }

double Vegar_VisualLaneOffset(const ENUM_VEGAR_BIAS bias,const datetime t,const double atr,const int salt=0)
  {
   double unit=MathMax(4.0*MathMax(gVegarSymbol.tick_size,gVegarSymbol.point),0.035*MathMax(atr,gVegarSymbol.tick_size));
   double d=(1.0+(double)Vegar_VisualLaneIndex(t,salt))*unit;
   return (bias==VEGAR_BIAS_BUYER ? -d : d);
  }


bool Vegar_VisualLabelCollision(const string owner,const datetime t,const double price)
  {
   int x=0,y=0;
   if(!ChartTimePriceToXY(0,0,t,price,x,y)) return false;
   int total=ObjectsTotal(0,0,-1);
   for(int i=0;i<total;i++)
     {
      string n=ObjectName(0,i,0,-1);
      if(n==owner || StringFind(n,VEGAR_VIS_PREFIX)!=0) continue;
      ENUM_OBJECT ot=(ENUM_OBJECT)ObjectGetInteger(0,n,OBJPROP_TYPE);
      if(ot!=OBJ_TEXT) continue;
      datetime tt=(datetime)ObjectGetInteger(0,n,OBJPROP_TIME,0);
      double pp=ObjectGetDouble(0,n,OBJPROP_PRICE,0);
      if(tt<=0 || pp<=0.0) continue;
      int ox=0,oy=0;
      if(!ChartTimePriceToXY(0,0,tt,pp,ox,oy)) continue;
      if(MathAbs((double)(ox-x))<88.0 && MathAbs((double)(oy-y))<18.0) return true;
     }
   return false;
  }

double Vegar_VisualResolveLabelY(const string owner,const ENUM_VEGAR_BIAS bias,const datetime t,const double base_price,const double atr,const int salt,int &lane_used)
  {
   double unit=MathMax(4.0*MathMax(gVegarSymbol.tick_size,gVegarSymbol.point),0.035*MathMax(atr,gVegarSymbol.tick_size));
   double sign=(bias==VEGAR_BIAS_BUYER?-1.0:1.0);
   int saltLane=(salt<0?-salt:salt)%2;
   for(int lane=0;lane<4;lane++)
     {
      double y=base_price+sign*(1.0+(double)lane+0.15*(double)saltLane)*unit;
      if(!Vegar_VisualLabelCollision(owner,t,y)) { lane_used=lane; return y; }
     }
   lane_used=3;
   return base_price+sign*4.0*unit;
  }

void Vegar_DeleteSweptMarkerById(const string zone_id)
  {
   string n=VEGAR_VIS_PREFIX+"SWEEP_HIST_"+zone_id;
   if(ObjectFind(0,n)>=0) ObjectDelete(0,n);
  }

void Vegar_DrawSweptZoneMarker(const SVegarZone &z)
  {
   if(!InpExibirEventos || !z.valid || z.state!=VEGAR_ZONE_SWEPT) { if(z.id!="") Vegar_DeleteSweptMarkerById(z.id); return; }
   datetime t=(z.last_changed>0?z.last_changed:z.confirmed_time);
   if(t<=0) return;
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   int life=MathMax(1,InpSweptMarkerCandles)*PeriodSeconds(Vegar_ExecutionTF());
   if(now>0 && life>0 && (now-t)>life) { Vegar_DeleteSweptMarkerById(z.id); return; }
   string n=VEGAR_VIS_PREFIX+"SWEEP_HIST_"+z.id;
   int lane=0;
   double base=(z.operational_bias==VEGAR_BIAS_BUYER?z.low:z.high);
   double y=Vegar_VisualResolveLabelY(n,z.operational_bias,t,base,z.source_atr,(int)z.type,lane);
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_TEXT,0,t,y); else ObjectMove(0,n,0,t,y);
   string arrow=(z.operational_bias==VEGAR_BIAS_BUYER?"↑":"↓");
   ObjectSetString(0,n,OBJPROP_TEXT,"SWEEP"+arrow);
   ObjectSetString(0,n,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte-1));
   ObjectSetInteger(0,n,OBJPROP_COLOR,Vegar_VisualOpacityColor(Vegar_ZoneColor(z),165));
   ObjectSetString(0,n,OBJPROP_TOOLTIP,"SWEPT | "+Vegar_TFText(z.source_tf)+" | F"+DoubleToString(z.strength_score,0)+" | "+z.id);
   Vegar_SetMarketObjectLayer(n,true,20);
   if(lane>0) Vegar_WriteDiagnostic("UI_LABEL_COLLISION_AVOIDED","PASS","NONE",z.id,"Lane="+(string)lane+"|Owner=SWEEP");
  }

void Vegar_DrawWeakZoneObservation(const SVegarZone &z)
  {
   string n=VEGAR_VIS_PREFIX+"WEAK_"+z.id;
   string lbl=VEGAR_VIS_PREFIX+"WEAK_LBL_"+z.id;
   if(!InpExibirZonasFracasObservacionais || !z.valid || z.strength_score>=InpForcaMinimaZona || z.state==VEGAR_ZONE_SWEPT)
     {
      if(ObjectFind(0,n)>=0) ObjectDelete(0,n);
      if(ObjectFind(0,lbl)>=0) ObjectDelete(0,lbl);
      return;
     }
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_HLINE,0,0,z.mid);
   ObjectSetDouble(0,n,OBJPROP_PRICE,z.mid);
   ObjectSetInteger(0,n,OBJPROP_COLOR,Vegar_VisualOpacityColor(Vegar_ZoneColor(z),70));
   ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_DOT); ObjectSetInteger(0,n,OBJPROP_WIDTH,1);
   ObjectSetString(0,n,OBJPROP_TOOLTIP,"Zona fraca observacional | "+z.id);
   Vegar_SetMarketObjectLayer(n);
   datetime t=TimeTradeServer(); if(t<=0) t=TimeCurrent();
   int lane=0;
   double y=Vegar_VisualResolveLabelY(lbl,z.operational_bias,t,z.mid,z.source_atr,(int)z.type,lane);
   if(ObjectFind(0,lbl)<0) ObjectCreate(0,lbl,OBJ_TEXT,0,t,y); else ObjectMove(0,lbl,0,t,y);
   ObjectSetString(0,lbl,OBJPROP_TEXT,"[OBS "+Vegar_VisualBiasShort(z.operational_bias)+"] "+Vegar_TFText(z.source_tf));
   ObjectSetString(0,lbl,OBJPROP_TOOLTIP,"Zona fraca observacional | F"+DoubleToString(z.strength_score,0)+" | "+z.id);
   ObjectSetString(0,lbl,OBJPROP_FONT,"Consolas"); ObjectSetInteger(0,lbl,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte-1));
   ObjectSetInteger(0,lbl,OBJPROP_COLOR,Vegar_VisualOpacityColor(Vegar_ZoneColor(z),120)); Vegar_SetMarketObjectLayer(lbl,true,7);
   if(lane>0) Vegar_WriteDiagnostic("UI_LABEL_COLLISION_AVOIDED","PASS","NONE",z.id,"Lane="+(string)lane+"|Owner=WEAK_OBS");
  }

void Vegar_ClearHistoricalVisualMarks()
  {
   int removed=0;
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      string n=ObjectName(0,i,0,-1);
      bool history=(StringFind(n,"VEGAR_MARKER_")==0 ||
                    StringFind(n,VEGAR_VIS_PREFIX+"EV_")==0 ||
                    StringFind(n,VEGAR_VIS_PREFIX+"SWEEP_HIST_")==0);
      if(history && ObjectDelete(0,n)) removed++;
     }
   Vegar_WriteDiagnostic("HISTORICAL_MARKS_CLEARED","PASS","NONE","",StringFormat("Removed=%d",removed));
  }

void Vegar_PruneOrphanVisualText()
  {
   int removed=0;
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      string n=ObjectName(0,i,0,-1),pair="";
      if(StringFind(n,VEGAR_VIS_PREFIX+"ZLBL_")==0)
         pair=VEGAR_VIS_PREFIX+"ZONE_"+StringSubstr(n,StringLen(VEGAR_VIS_PREFIX+"ZLBL_"));
      else if(StringFind(n,VEGAR_VIS_PREFIX+"OBS_LBL_")==0)
         pair=VEGAR_VIS_PREFIX+"OBS_ZONE_"+StringSubstr(n,StringLen(VEGAR_VIS_PREFIX+"OBS_LBL_"));
      else if(StringFind(n,VEGAR_VIS_PREFIX+"WEAK_LBL_")==0)
         pair=VEGAR_VIS_PREFIX+"WEAK_"+StringSubstr(n,StringLen(VEGAR_VIS_PREFIX+"WEAK_LBL_"));
      if(pair!="" && ObjectFind(0,pair)<0)
        {
         if(ObjectDelete(0,n)) removed++;
        }
     }
   if(removed>0) Vegar_WriteDiagnostic("ORPHAN_VISUAL_REMOVED","PASS","NONE","",StringFormat("Removed=%d",removed));
  }

void Vegar_DrawZone(const SVegarZone &z,const datetime right_time)
  {
   if(!InpExibirZonas || !z.valid)
     {
      if(z.id!="") { Vegar_DeleteZoneObjectsById(z.id); Vegar_DeleteSweptMarkerById(z.id); }
      return;
     }
   if(z.state==VEGAR_ZONE_SWEPT)
     {
      Vegar_DeleteZoneObjectsById(z.id);
      Vegar_DrawSweptZoneMarker(z);
      return;
     }
   Vegar_DeleteSweptMarkerById(z.id);
   if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED)
     {
      Vegar_DeleteZoneObjectsById(z.id);
      return;
     }
   if(z.strength_score<InpForcaMinimaZona && !z.focus)
     {
      Vegar_DeleteZoneObjectsById(z.id);
      Vegar_DrawWeakZoneObservation(z);
      return;
     }

   string weak=VEGAR_VIS_PREFIX+"WEAK_"+z.id,weakLbl=VEGAR_VIS_PREFIX+"WEAK_LBL_"+z.id;
   if(ObjectFind(0,weak)>=0) ObjectDelete(0,weak);
   if(ObjectFind(0,weakLbl)>=0) ObjectDelete(0,weakLbl);

   string box=VEGAR_VIS_PREFIX+"ZONE_"+z.id;
   string border=VEGAR_VIS_PREFIX+"ZONE_BORDER_"+z.id;
   datetime left=(z.confirmed_time>0?z.confirmed_time:iTime(_Symbol,z.source_tf,20));
   color c=Vegar_ZoneColor(z);
   int fillAlpha=(z.focus?26:14); // ~10% focus, ~5.5% active
   if(z.state==VEGAR_ZONE_TOUCHED) fillAlpha=(z.focus?30:18);

   if(ObjectFind(0,box)<0) ObjectCreate(0,box,OBJ_RECTANGLE,0,left,z.low,right_time,z.high);
   else { ObjectMove(0,box,0,left,z.low); ObjectMove(0,box,1,right_time,z.high); }
   ObjectSetInteger(0,box,OBJPROP_COLOR,Vegar_VisualOpacityColor(c,fillAlpha));
   ObjectSetInteger(0,box,OBJPROP_FILL,true);
   ObjectSetInteger(0,box,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,box,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetString(0,box,OBJPROP_TOOLTIP,"Zona | "+Vegar_TFText(z.source_tf)+" | "+Vegar_ZoneStateText(z.state)+" | F"+DoubleToString(z.strength_score,0)+" | "+z.id);
   Vegar_SetMarketObjectLayer(box,false,0);

   if(ObjectFind(0,border)<0) ObjectCreate(0,border,OBJ_RECTANGLE,0,left,z.low,right_time,z.high);
   else { ObjectMove(0,border,0,left,z.low); ObjectMove(0,border,1,right_time,z.high); }
   ObjectSetInteger(0,border,OBJPROP_FILL,false);
   ObjectSetInteger(0,border,OBJPROP_COLOR,Vegar_VisualOpacityColor(c,z.focus?190:125));
   ObjectSetInteger(0,border,OBJPROP_WIDTH,z.focus?2:1);
   ObjectSetInteger(0,border,OBJPROP_STYLE,(z.state==VEGAR_ZONE_TOUCHED?STYLE_DASH:STYLE_SOLID));
   Vegar_SetMarketObjectLayer(border,false,1);

   string label=VEGAR_VIS_PREFIX+"ZLBL_"+z.id;
   double baseY=(z.operational_bias==VEGAR_BIAS_BUYER?z.low:z.high);
   int lane=0;
   double y=Vegar_VisualResolveLabelY(label,z.operational_bias,right_time,baseY,z.source_atr,(int)z.type,lane);
   if(ObjectFind(0,label)<0) ObjectCreate(0,label,OBJ_TEXT,0,right_time,y); else ObjectMove(0,label,0,right_time,y);
   string side=Vegar_VisualBiasShort(z.operational_bias);
   string text=(z.focus && InpExibirZonaFoco ? "[FOCO "+side+"] " : "["+side+"] ")+Vegar_TFText(z.source_tf);
   if(InpExibirForca) text+=" F"+DoubleToString(z.strength_score,0);
   ObjectSetString(0,label,OBJPROP_TEXT,text);
   ObjectSetString(0,label,OBJPROP_TOOLTIP,"Zona | "+Vegar_TFText(z.source_tf)+" | "+Vegar_ZoneStateText(z.state)+" | F"+DoubleToString(z.strength_score,0)+" | "+z.id);
   ObjectSetInteger(0,label,OBJPROP_COLOR,Vegar_VisualOpacityColor(c,z.focus?220:170));
   ObjectSetInteger(0,label,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte-1));
   ObjectSetString(0,label,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,label,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   Vegar_SetMarketObjectLayer(label,true,10);
   if(lane>0) Vegar_WriteDiagnostic("UI_LABEL_COLLISION_AVOIDED","PASS","NONE",z.id,"Lane="+(string)lane+"|Owner=ZONE");
  }

void Vegar_DrawChannel(const SVegarChannel &c)
  {
   if(!InpExibirCanais || !c.valid)
     {
      if(c.tf==PERIOD_H4 || c.tf==PERIOD_M15) Vegar_DeleteChannelObjects(c.tf);
      return;
     }
   if(c.tf==PERIOD_H4 && !InpExibirCanalH4) { Vegar_DeleteChannelObjects(c.tf); return; }
   if(c.tf==PERIOD_M15 && !InpExibirCanalM15) { Vegar_DeleteChannelObjects(c.tf); return; }

   datetime t1=c.anchor1_time,t2=iTime(_Symbol,c.tf,1); if(t1<=0 || t2<=t1) return;
   double base1=Vegar_ChannelLineAt(c,t1),base2=Vegar_ChannelLineAt(c,t2);
   color col=(c.direction==VEGAR_CHANNEL_BUYER?C'53,224,230':(c.direction==VEGAR_CHANNEL_SELLER?C'255,122,69':C'86,108,130'));
   string a=VEGAR_VIS_PREFIX+"CH_A_"+Vegar_TFText(c.tf),b=VEGAR_VIS_PREFIX+"CH_B_"+Vegar_TFText(c.tf);
   double y1a=base1,y2a=base2,y1b=base1,y2b=base2;
   if(c.direction==VEGAR_CHANNEL_BUYER) { y1b+=c.offset_price; y2b+=c.offset_price; }
   else if(c.direction==VEGAR_CHANNEL_SELLER) { y1b-=c.offset_price; y2b-=c.offset_price; }
   else { y1a-=c.offset_price*0.5; y2a-=c.offset_price*0.5; y1b+=c.offset_price*0.5; y2b+=c.offset_price*0.5; }

   if(ObjectFind(0,a)<0) ObjectCreate(0,a,OBJ_TREND,0,t1,y1a,t2,y2a); else { ObjectMove(0,a,0,t1,y1a); ObjectMove(0,a,1,t2,y2a); }
   if(ObjectFind(0,b)<0) ObjectCreate(0,b,OBJ_TREND,0,t1,y1b,t2,y2b); else { ObjectMove(0,b,0,t1,y1b); ObjectMove(0,b,1,t2,y2b); }
   bool h4=(c.tf==PERIOD_H4);
   int railAlpha=(h4?165:120);
   int railWidth=(h4?2:1);
   color rail=Vegar_VisualOpacityColor(col,railAlpha);
   ObjectSetInteger(0,a,OBJPROP_RAY_RIGHT,true); ObjectSetInteger(0,b,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,a,OBJPROP_COLOR,rail); ObjectSetInteger(0,b,OBJPROP_COLOR,rail);
   ObjectSetInteger(0,a,OBJPROP_STYLE,STYLE_SOLID); ObjectSetInteger(0,b,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,a,OBJPROP_WIDTH,railWidth); ObjectSetInteger(0,b,OBJPROP_WIDTH,railWidth);
   Vegar_SetMarketObjectLayer(a,false,0); Vegar_SetMarketObjectLayer(b,false,0);

   string bandName=VEGAR_VIS_PREFIX+"CH_BAND_"+Vegar_TFText(c.tf);
   if(ObjectFind(0,bandName)<0) ObjectCreate(0,bandName,OBJ_CHANNEL,0,t1,y1a,t2,y2a,t1,y1b);
   else { ObjectMove(0,bandName,0,t1,y1a); ObjectMove(0,bandName,1,t2,y2a); ObjectMove(0,bandName,2,t1,y1b); }
   int fillAlpha=(h4?17:13); // H4 ~6.7%, M15 ~5.1%
   ObjectSetInteger(0,bandName,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,bandName,OBJPROP_COLOR,Vegar_VisualOpacityColor(col,fillAlpha));
   ObjectSetInteger(0,bandName,OBJPROP_FILL,true);
   ObjectSetInteger(0,bandName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,bandName,OBJPROP_WIDTH,1);
   ObjectSetString(0,bandName,OBJPROP_TOOLTIP,"Canal "+Vegar_TFText(c.tf)+" | "+Vegar_ChannelText(c.direction)+" | F"+DoubleToString(c.strength_score,0));
   Vegar_SetMarketObjectLayer(bandName,false,0);

   string midName=VEGAR_VIS_PREFIX+"CH_MID_"+Vegar_TFText(c.tf);
   if(InpExibirLinhaCentralCanal)
     {
      double y1m=(y1a+y1b)*0.5,y2m=(y2a+y2b)*0.5;
      if(ObjectFind(0,midName)<0) ObjectCreate(0,midName,OBJ_TREND,0,t1,y1m,t2,y2m);
      else { ObjectMove(0,midName,0,t1,y1m); ObjectMove(0,midName,1,t2,y2m); }
      ObjectSetInteger(0,midName,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(0,midName,OBJPROP_COLOR,Vegar_VisualOpacityColor(col,h4?70:50));
      ObjectSetInteger(0,midName,OBJPROP_STYLE,STYLE_DASH);
      ObjectSetInteger(0,midName,OBJPROP_WIDTH,1);
      Vegar_SetMarketObjectLayer(midName,false,0);
     }
   else if(ObjectFind(0,midName)>=0) ObjectDelete(0,midName);

   string lbl=VEGAR_VIS_PREFIX+"CH_LBL_"+Vegar_TFText(c.tf);
   datetime lt=TimeTradeServer(); if(lt<=0) lt=TimeCurrent(); lt+=PeriodSeconds(Vegar_ExecutionTF())*4;
   double lb=Vegar_ChannelLineAt(c,lt),la=lb,lbb=lb;
   if(c.direction==VEGAR_CHANNEL_BUYER) lbb+=c.offset_price;
   else if(c.direction==VEGAR_CHANNEL_SELLER) lbb-=c.offset_price;
   else { la-=c.offset_price*0.5; lbb+=c.offset_price*0.5; }
   double labelBase=(la+lbb)*0.5;
   int lane=0;
   ENUM_VEGAR_BIAS ldir=(c.direction==VEGAR_CHANNEL_BUYER?VEGAR_BIAS_BUYER:(c.direction==VEGAR_CHANNEL_SELLER?VEGAR_BIAS_SELLER:VEGAR_BIAS_SELLER));
   double labelY=Vegar_VisualResolveLabelY(lbl,ldir,lt,labelBase,MathMax(c.offset_price,gVegarSymbol.tick_size),(int)c.tf,lane);
   if(ObjectFind(0,lbl)<0) ObjectCreate(0,lbl,OBJ_TEXT,0,lt,labelY); else ObjectMove(0,lbl,0,lt,labelY);
   ObjectSetString(0,lbl,OBJPROP_TEXT,"CANAL "+Vegar_TFText(c.tf)+" | "+Vegar_ChannelText(c.direction)+" | F"+DoubleToString(c.strength_score,0));
   ObjectSetString(0,lbl,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,lbl,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte-1));
   ObjectSetInteger(0,lbl,OBJPROP_COLOR,Vegar_VisualOpacityColor(col,h4?190:150));
   Vegar_SetMarketObjectLayer(lbl,true,8);
  }

void Vegar_DrawRetestZone()
  {
   if(!gVegarOpportunity.active || gVegarOpportunity.retest_type==VEGAR_RETEST_NONE || gVegarOpportunity.retest_low<=0.0) return;
   bool show=(gVegarOpportunity.retest_type==VEGAR_RETEST_FVG?InpExibirFVG:InpExibirOrderBlock); if(!show) return;
   string n=VEGAR_VIS_PREFIX+"RETEST_"+gVegarOpportunity.opportunity_id;
   datetime t1=gVegarOpportunity.displacement_time,t2=TimeTradeServer()+PeriodSeconds(Vegar_ExecutionTF())*6;
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_RECTANGLE,0,t1,gVegarOpportunity.retest_low,t2,gVegarOpportunity.retest_high);
   else { ObjectMove(0,n,0,t1,gVegarOpportunity.retest_low); ObjectMove(0,n,1,t2,gVegarOpportunity.retest_high); }
   color c=(gVegarOpportunity.direction==VEGAR_BIAS_BUYER?C'53,224,230':C'255,122,69');
   ObjectSetInteger(0,n,OBJPROP_COLOR,Vegar_VisualOpacityColor(c,17));
   ObjectSetInteger(0,n,OBJPROP_FILL,true);
   ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_DASH);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,1);
   ObjectSetString(0,n,OBJPROP_TOOLTIP,(gVegarOpportunity.retest_type==VEGAR_RETEST_FVG?"FVG":"OB")+" | Opportunity="+gVegarOpportunity.opportunity_id);
   Vegar_SetMarketObjectLayer(n,false,1);
   string lbl=VEGAR_VIS_PREFIX+"RETEST_LBL_"+gVegarOpportunity.opportunity_id;
   int lane=0;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) atr=gVegarOpportunity.retest_high-gVegarOpportunity.retest_low;
   double y=Vegar_VisualResolveLabelY(lbl,gVegarOpportunity.direction,t2,gVegarOpportunity.retest_mid,atr,9,lane);
   if(ObjectFind(0,lbl)<0) ObjectCreate(0,lbl,OBJ_TEXT,0,t2,y); else ObjectMove(0,lbl,0,t2,y);
   ObjectSetString(0,lbl,OBJPROP_TEXT,(gVegarOpportunity.retest_type==VEGAR_RETEST_FVG?"FVG":"OB"));
   ObjectSetString(0,lbl,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,lbl,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte-1));
   ObjectSetInteger(0,lbl,OBJPROP_COLOR,Vegar_VisualOpacityColor(c,180));
   Vegar_SetMarketObjectLayer(lbl,true,12);
  }

void Vegar_DrawEvent(const string tag,const datetime t,const double price,const ENUM_VEGAR_BIAS direction)
  {
   if(!InpExibirEventos || t<=0 || price<=0.0) return;
   string n=VEGAR_VIS_PREFIX+"EV_"+tag+"_"+(string)(long)t;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) atr=10.0*MathMax(gVegarSymbol.tick_size,gVegarSymbol.point);
   int lane=0;
   double y=Vegar_VisualResolveLabelY(n,direction,t,price,atr,(int)StringLen(tag),lane);
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_TEXT,0,t,y); else ObjectMove(0,n,0,t,y);
   string arrow=(direction==VEGAR_BIAS_BUYER?"↑":"↓");
   string text=tag;
   if(tag=="SWEEP") text="SWEEP"+arrow;
   else if(tag=="MSS") text="MSS"+arrow;
   else if(tag=="DISPLACEMENT") text="DISP"+arrow;
   else if(tag=="RETEST") text="RETEST"+arrow;
   else if(tag=="ENTRY") text=(direction==VEGAR_BIAS_BUYER?"BUY":"SELL");
   else if(tag=="EXIT") text="EXIT";
   else if(tag=="SL") text="SL";
   else if(tag=="TP") text="TP";
   else if(tag=="RUNNER") text="RUNNER";
   ObjectSetString(0,n,OBJPROP_TEXT,text);
   ObjectSetString(0,n,OBJPROP_TOOLTIP,tag+" | "+TimeToString(t,TIME_DATE|TIME_SECONDS));
   ObjectSetString(0,n,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte-1));
   color ec=(direction==VEGAR_BIAS_BUYER?C'53,224,230':C'255,122,69');
   if(tag=="SL") ec=C'255,91,91';
   if(tag=="TP" || tag=="RUNNER") ec=C'46,230,166';
   ObjectSetInteger(0,n,OBJPROP_COLOR,ec);
   Vegar_SetMarketObjectLayer(n,true,20);
   if(lane>0) Vegar_WriteDiagnostic("UI_LABEL_COLLISION_AVOIDED","PASS","NONE",tag,"Lane="+(string)lane+"|Owner=EVENT");
  }

void Vegar_DrawFlowLabel()
  {
   string n=VEGAR_VIS_PREFIX+"FLOW_LABEL";
   if(!InpExibirFluxo)
     {
      if(ObjectFind(0,n)>=0) ObjectDelete(0,n);
      return;
     }
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,18);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,24);
   ObjectSetString(0,n,OBJPROP_TEXT,"FLOW "+DoubleToString(gVegarExecutionFlow.flow_score,0));
   color c=(gVegarExecutionFlow.flow_score>0?C'53,224,230':(gVegarExecutionFlow.flow_score<0?C'255,122,69':C'168,183,200'));
   ObjectSetInteger(0,n,OBJPROP_COLOR,c);
   ObjectSetString(0,n,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte));
   Vegar_SetMarketObjectLayer(n,true,5);
  }

void Vegar_DrawTradeLevels(const SVegarIntent &intent)
  {
   if(!InpExibirEventos || !intent.valid) return;
   string stopName=VEGAR_VIS_PREFIX+"STOP_"+intent.intent_id;
   if(intent.stop_price>0.0)
     {
      if(ObjectFind(0,stopName)<0) ObjectCreate(0,stopName,OBJ_HLINE,0,0,intent.stop_price);
      ObjectSetDouble(0,stopName,OBJPROP_PRICE,intent.stop_price); ObjectSetInteger(0,stopName,OBJPROP_COLOR,(InpAtivarStopLoss?C'255,91,91':C'244,197,66')); ObjectSetInteger(0,stopName,OBJPROP_STYLE,(InpAtivarStopLoss?STYLE_DASH:STYLE_DOT));
      ObjectSetString(0,stopName,OBJPROP_TEXT,"SL");
      ObjectSetString(0,stopName,OBJPROP_TOOLTIP,(InpAtivarStopLoss?"SL":"SL TECNICO / OFF")+" | "+DoubleToString(intent.stop_price,gVegarSymbol.digits)+" | -"+DoubleToString(intent.stop_money,2)+" "+gVegarSymbol.account_currency); Vegar_SetMarketObjectLayer(stopName,true,8);
     }
   if(intent.take_profit_price>0.0)
     {
      string tpName=VEGAR_VIS_PREFIX+"TARGET_"+intent.intent_id;
      if(ObjectFind(0,tpName)<0) ObjectCreate(0,tpName,OBJ_HLINE,0,0,intent.take_profit_price);
      ObjectSetDouble(0,tpName,OBJPROP_PRICE,intent.take_profit_price); ObjectSetInteger(0,tpName,OBJPROP_COLOR,C'46,230,166'); ObjectSetInteger(0,tpName,OBJPROP_STYLE,STYLE_DASH);
      ObjectSetString(0,tpName,OBJPROP_TEXT,"TP");
      ObjectSetString(0,tpName,OBJPROP_TOOLTIP,"TP | "+DoubleToString(intent.take_profit_price,gVegarSymbol.digits)+" | +"+DoubleToString(InpTakeProfitMoney,2)+" "+gVegarSymbol.account_currency); Vegar_SetMarketObjectLayer(tpName,true,8);
     }
   Vegar_DrawEvent("ENTRY",intent.signal_bar_time,intent.entry_price,intent.direction);
  }

void Vegar_DrawRunnerLevel()
  {
   string n=VEGAR_VIS_PREFIX+"RUNNER_LEVEL";
   if(!gVegarProfit.active || !gVegarProfit.runner_active || gVegarProfit.protected_profit_money<=0.0)
     { if(ObjectFind(0,n)>=0) ObjectDelete(0,n); return; }
   double p=0.0; if(!Vegar_ProtectedMoneyToSL(gVegarProfit.protected_profit_money,p)) return;
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_HLINE,0,0,p);
   ObjectSetDouble(0,n,OBJPROP_PRICE,p); ObjectSetInteger(0,n,OBJPROP_COLOR,C'46,230,166'); ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_SOLID); ObjectSetString(0,n,OBJPROP_TEXT,"RUNNER"); ObjectSetString(0,n,OBJPROP_TOOLTIP,"RUNNER | Protected floor "+DoubleToString(gVegarProfit.protected_profit_money,2)+" "+gVegarSymbol.account_currency); Vegar_SetMarketObjectLayer(n,true,8);
  }

void Vegar_DrawObservationZone(const SVegarZone &z,const datetime right_time)
  {
   string n=VEGAR_VIS_PREFIX+"OBS_ZONE_"+z.id;
   string lbl=VEGAR_VIS_PREFIX+"OBS_LBL_"+z.id;
   if(!InpExibirMicroLiquidezObservacional || !z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OBSERVATION ||
      z.state==VEGAR_ZONE_SWEPT || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED)
     {
      if(ObjectFind(0,n)>=0) ObjectDelete(0,n);
      if(ObjectFind(0,lbl)>=0) ObjectDelete(0,lbl);
      return;
     }
   datetime left=(z.confirmed_time>0?z.confirmed_time:iTime(_Symbol,z.source_tf,10));
   bool m15Aligned=((z.operational_bias==VEGAR_BIAS_BUYER && gVegarM15Context==VEGAR_M15_TREND_UP) ||
                    (z.operational_bias==VEGAR_BIAS_SELLER && gVegarM15Context==VEGAR_M15_TREND_DOWN));
   bool microAuthority=(InpAtivarMicroContinuacaoOperacional && m15Aligned && z.strength_score>=InpForcaMinimaZona);
   color microColor=(z.operational_bias==VEGAR_BIAS_BUYER?C'53,224,230':C'255,122,69');
   if(!microAuthority) microColor=C'120,136,154';
   if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_RECTANGLE,0,left,z.low,right_time,z.high);
   else { ObjectMove(0,n,0,left,z.low); ObjectMove(0,n,1,right_time,z.high); }
   ObjectSetInteger(0,n,OBJPROP_COLOR,Vegar_VisualOpacityColor(microColor,microAuthority?13:90));
   ObjectSetInteger(0,n,OBJPROP_FILL,microAuthority);
   ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,1);
   ObjectSetString(0,n,OBJPROP_TOOLTIP,(microAuthority?"MICRO CONTINUATION":"MICRO OBS")+" | "+Vegar_TFText(z.source_tf)+" | F"+DoubleToString(z.strength_score,0)+" | "+z.id);
   Vegar_SetMarketObjectLayer(n,false,0);

   int lane=0;
   double base=(z.operational_bias==VEGAR_BIAS_BUYER?z.low:z.high);
   double labelY=Vegar_VisualResolveLabelY(lbl,z.operational_bias,right_time,base,z.source_atr,(int)z.type,lane);
   if(ObjectFind(0,lbl)<0) ObjectCreate(0,lbl,OBJ_TEXT,0,right_time,labelY); else ObjectMove(0,lbl,0,right_time,labelY);
   ObjectSetString(0,lbl,OBJPROP_TEXT,"[OBS "+Vegar_VisualBiasShort(z.operational_bias)+"] "+Vegar_TFText(z.source_tf));
   ObjectSetString(0,lbl,OBJPROP_TOOLTIP,(microAuthority?"MICRO CONTINUATION":"MICRO OBS")+" | F"+DoubleToString(z.strength_score,0)+" | "+z.id);
   ObjectSetString(0,lbl,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,lbl,OBJPROP_FONTSIZE,(long)MathMax(8,InpTamanhoFonte-1));
   ObjectSetInteger(0,lbl,OBJPROP_COLOR,Vegar_VisualOpacityColor(microColor,microAuthority?170:120));
   Vegar_SetMarketObjectLayer(lbl,true,9);
   if(lane>0) Vegar_WriteDiagnostic("UI_LABEL_COLLISION_AVOIDED","PASS","NONE",z.id,"Lane="+(string)lane+"|Owner=OBS_ZONE");
  }

void Vegar_PruneObservationVisuals(string &desired[])
  {
   string p1=VEGAR_VIS_PREFIX+"OBS_ZONE_";
   string p2=VEGAR_VIS_PREFIX+"OBS_LBL_";
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      string n=ObjectName(0,i,0,-1);
      if((StringFind(n,p1)==0 || StringFind(n,p2)==0) && !Vegar_StringArrayContains(desired,n)) ObjectDelete(0,n);
     }
  }

void Vegar_RefreshVisuals()
  {
   datetime right=TimeTradeServer()+PeriodSeconds(Vegar_ExecutionTF())*8;
   double mid=(gVegarTick.bid+gVegarTick.ask)*0.5;
   string desiredZones[];
   bool used[]; ArrayResize(used,ArraySize(gVegarZones)); for(int u=0;u<ArraySize(used);u++)used[u]=false;

   // Visual corrective rule: SWEPT is historical-only and weak zones are not operational boxes.
   for(int sh=0;sh<ArraySize(gVegarZones);sh++)
     {
      if(gVegarZones[sh].valid && gVegarZones[sh].symbol==_Symbol && gVegarZones[sh].role==VEGAR_ZONE_ROLE_OPERATIONAL)
        {
         if(gVegarZones[sh].state==VEGAR_ZONE_SWEPT) Vegar_DrawSweptZoneMarker(gVegarZones[sh]);
         else if(gVegarZones[sh].strength_score<InpForcaMinimaZona) Vegar_DrawWeakZoneObservation(gVegarZones[sh]);
        }
     }

   int focus=Vegar_FocusZoneIndex();
   if(focus>=0 && focus<ArraySize(gVegarZones) && gVegarZones[focus].valid && gVegarZones[focus].symbol==_Symbol && gVegarZones[focus].role==VEGAR_ZONE_ROLE_OPERATIONAL &&
      gVegarZones[focus].state!=VEGAR_ZONE_SWEPT && gVegarZones[focus].strength_score>=InpForcaMinimaZona)
     {
      used[focus]=true;
      Vegar_AddDesiredVisual(desiredZones,VEGAR_VIS_PREFIX+"ZONE_"+gVegarZones[focus].id);
      Vegar_AddDesiredVisual(desiredZones,VEGAR_VIS_PREFIX+"ZONE_BORDER_"+gVegarZones[focus].id);
      Vegar_AddDesiredVisual(desiredZones,VEGAR_VIS_PREFIX+"ZLBL_"+gVegarZones[focus].id);
      Vegar_DrawZone(gVegarZones[focus],right);
     }

   // Visual corrective rule: nearest zones by price distance, never by array insertion order.
   for(int side=0;side<2;side++)
     {
      int cap=(int)MathMin(2,(side==0?InpMaxZonasAcima:InpMaxZonasAbaixo));
      for(int slot=0;slot<cap;slot++)
        {
         int best=-1; double bestD=DBL_MAX;
         for(int i=0;i<ArraySize(gVegarZones);i++)
           {
            if(used[i])continue; SVegarZone z=gVegarZones[i];
            if(!z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL)continue;
            if(z.state==VEGAR_ZONE_SWEPT || z.strength_score<InpForcaMinimaZona)continue;
            if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED)continue;
            bool above=(z.mid>=mid); if((side==0 && !above)||(side==1 && above))continue;
            double d=MathAbs(z.mid-mid);
            bool better=(d<bestD-1e-12);
            if(!better && MathAbs(d-bestD)<=1e-12)
              {
               if(best<0 || z.strength_score>gVegarZones[best].strength_score+1e-9) better=true;
               else if(best>=0 && MathAbs(z.strength_score-gVegarZones[best].strength_score)<=1e-9 && z.confirmed_time>gVegarZones[best].confirmed_time) better=true;
              }
            if(better) {best=i;bestD=d;}
           }
         if(best<0)break; used[best]=true;
         Vegar_AddDesiredVisual(desiredZones,VEGAR_VIS_PREFIX+"ZONE_"+gVegarZones[best].id);
         Vegar_AddDesiredVisual(desiredZones,VEGAR_VIS_PREFIX+"ZONE_BORDER_"+gVegarZones[best].id);
         Vegar_AddDesiredVisual(desiredZones,VEGAR_VIS_PREFIX+"ZLBL_"+gVegarZones[best].id);
         Vegar_DrawZone(gVegarZones[best],right);
        }
     }
   Vegar_PruneZoneVisuals(desiredZones);

   string desiredObs[];
   if(InpExibirMicroLiquidezObservacional)
     {
      // Keep only the nearest few observation zones to avoid chart pollution.
      bool ou[]; ArrayResize(ou,ArraySize(gVegarObservationZones)); for(int j=0;j<ArraySize(ou);j++)ou[j]=false;
      for(int k=0;k<2;k++)
        {
         int best=-1; double bd=DBL_MAX;
         for(int i=0;i<ArraySize(gVegarObservationZones);i++)
           {
            if(ou[i] || !gVegarObservationZones[i].valid || gVegarObservationZones[i].symbol!=_Symbol)continue;
            double d=MathAbs(gVegarObservationZones[i].mid-mid); if(d<bd){bd=d;best=i;}
           }
         if(best<0)break;ou[best]=true;string n=VEGAR_VIS_PREFIX+"OBS_ZONE_"+gVegarObservationZones[best].id;Vegar_AddDesiredVisual(desiredObs,n);Vegar_AddDesiredVisual(desiredObs,VEGAR_VIS_PREFIX+"OBS_LBL_"+gVegarObservationZones[best].id);Vegar_DrawObservationZone(gVegarObservationZones[best],right);
        }
     }
   Vegar_PruneObservationVisuals(desiredObs);

   Vegar_DrawChannel(gVegarChannelH4);
   Vegar_DrawChannel(gVegarChannelM15);
   Vegar_PruneRetestVisuals();
   Vegar_DrawRetestZone();
   Vegar_DrawFlowLabel();
   Vegar_DrawRunnerLevel();

   if(gVegarOpportunity.sweep_time>0) Vegar_DrawEvent("SWEEP",gVegarOpportunity.sweep_time,gVegarOpportunity.sweep_extreme,gVegarOpportunity.direction);
   if(gVegarOpportunity.mss_time>0) Vegar_DrawEvent("MSS",gVegarOpportunity.mss_time,gVegarOpportunity.micro_break_level,gVegarOpportunity.direction);
   if(gVegarOpportunity.displacement_time>0) Vegar_DrawEvent("DISPLACEMENT",gVegarOpportunity.displacement_time,gVegarOpportunity.retest_mid>0?gVegarOpportunity.retest_mid:gVegarOpportunity.sweep_extreme,gVegarOpportunity.direction);
   if(gVegarOpportunity.retest_time>0) Vegar_DrawEvent("RETEST",gVegarOpportunity.retest_time,gVegarOpportunity.retest_mid,gVegarOpportunity.direction);
   Vegar_PruneOrphanVisualText();
   ChartRedraw();
  }

#endif
