#ifndef __VEGAR_LIQUIDITY_MQH__
#define __VEGAR_LIQUIDITY_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"

SVegarZone gVegarZones[];                 // OPERATIONAL only
SVegarZone gVegarObservationZones[];      // OBSERVATION only - never execution authority
string gVegarFocusZoneID="";

bool Vegar_IsPivotHigh(MqlRates &r[],const int idx,const int left=2,const int right=2)
  {
   int n=ArraySize(r);
   if(idx-right<0 || idx+left>=n) return false;
   double p=r[idx].high;
   for(int k=1;k<=left;k++) if(r[idx+k].high>=p) return false;
   for(int k=1;k<=right;k++) if(r[idx-k].high>p) return false;
   return true;
  }

bool Vegar_IsPivotLow(MqlRates &r[],const int idx,const int left=2,const int right=2)
  {
   int n=ArraySize(r);
   if(idx-right<0 || idx+left>=n) return false;
   double p=r[idx].low;
   for(int k=1;k<=left;k++) if(r[idx+k].low<=p) return false;
   for(int k=1;k<=right;k++) if(r[idx-k].low<p) return false;
   return true;
  }

string Vegar_ZoneTypeText(const ENUM_VEGAR_ZONE_TYPE t)
  {
   switch(t)
     {
      case VEGAR_ZONE_H4_SWING_HIGH: return "H4_SWING_HIGH";
      case VEGAR_ZONE_H4_SWING_LOW: return "H4_SWING_LOW";
      case VEGAR_ZONE_M15_SWING_HIGH: return "M15_SWING_HIGH";
      case VEGAR_ZONE_M15_SWING_LOW: return "M15_SWING_LOW";
      case VEGAR_ZONE_EXEC_SWING_HIGH: return "EXEC_SWING_HIGH";
      case VEGAR_ZONE_EXEC_SWING_LOW: return "EXEC_SWING_LOW";
      case VEGAR_ZONE_EQUAL_HIGH: return "EQUAL_HIGH";
      case VEGAR_ZONE_EQUAL_LOW: return "EQUAL_LOW";
      case VEGAR_ZONE_PDH: return "PDH";
      case VEGAR_ZONE_PDL: return "PDL";
      case VEGAR_ZONE_PWH: return "PWH";
      case VEGAR_ZONE_PWL: return "PWL";
      case VEGAR_ZONE_COMPOSITE: return "COMPOSITE";
      default: return "UNKNOWN";
     }
  }

int Vegar_ZoneOriginScore(const ENUM_VEGAR_ZONE_TYPE t)
  {
   if(t==VEGAR_ZONE_PWH || t==VEGAR_ZONE_PWL) return 25;
   if(t==VEGAR_ZONE_PDH || t==VEGAR_ZONE_PDL) return 22;
   if(t==VEGAR_ZONE_H4_SWING_HIGH || t==VEGAR_ZONE_H4_SWING_LOW) return 20;
   if(t==VEGAR_ZONE_M15_SWING_HIGH || t==VEGAR_ZONE_M15_SWING_LOW || t==VEGAR_ZONE_EQUAL_HIGH || t==VEGAR_ZONE_EQUAL_LOW) return 14;
   if(t==VEGAR_ZONE_EXEC_SWING_HIGH || t==VEGAR_ZONE_EXEC_SWING_LOW) return 8;
   return 0;
  }

string Vegar_ZoneScopedID(const ENUM_VEGAR_ZONE_TYPE type,const ENUM_TIMEFRAMES tf,const string source_identity)
  {
   return "ZONE_"+Vegar_SanitizeFileToken(_Symbol)+"_"+Vegar_TFText(tf)+"_"+Vegar_ZoneTypeText(type)+"_"+source_identity;
  }

string Vegar_ZoneCompositeID(const SVegarZone &z)
  {
   string material=_Symbol+"|"+Vegar_TFText(z.primary_source_tf)+"|"+z.source_ids;
   return "ZONE_"+Vegar_SanitizeFileToken(_Symbol)+"_"+Vegar_TFText(z.primary_source_tf)+"_COMPOSITE_"+Vegar_Fnv1a64Hex(material);
  }

bool Vegar_ZoneContextValid(const SVegarZone &z)
  {
   bool ok=(z.symbol==_Symbol && z.magic==InpMagicNumber);
   if(!ok)
      PrintFormat("[VEGAR][CROSS_SYMBOL_ENTITY_REJECTED] EntityID=%s | EntitySymbol=%s | CurrentSymbol=%s | EntityMagic=%I64d | CurrentMagic=%I64d",
                  z.id,z.symbol,_Symbol,z.magic,InpMagicNumber);
   return ok;
  }

int Vegar_FindZoneIndex(const string id)
  {
   for(int i=0;i<ArraySize(gVegarZones);i++)
      if(gVegarZones[i].valid && gVegarZones[i].id==id && Vegar_ZoneContextValid(gVegarZones[i])) return i;
   return -1;
  }

int Vegar_FindObservationZoneIndex(const string id)
  {
   for(int i=0;i<ArraySize(gVegarObservationZones);i++)
      if(gVegarObservationZones[i].valid && gVegarObservationZones[i].id==id && gVegarObservationZones[i].symbol==_Symbol) return i;
   return -1;
  }

void Vegar_RecalcZoneGeometry(SVegarZone &z)
  {
   z.mid=(z.low+z.high)*0.5;
   z.width=MathMax(0.0,z.high-z.low);
  }

void Vegar_InitZoneIdentity(SVegarZone &z,const ENUM_VEGAR_ZONE_ROLE role)
  {
   z.account=(string)AccountInfoInteger(ACCOUNT_LOGIN);
   z.server=AccountInfoString(ACCOUNT_SERVER);
   z.symbol=_Symbol;
   z.execution_tf=Vegar_ExecutionTF();
   z.magic=InpMagicNumber;
   z.instance_id=gVegarInstanceID;
   z.run_id=gVegarRunID;
   z.role=role;
  }

string Vegar_SourceIdentityForZone(const SVegarZone &z)
  {
   string kind=Vegar_ZoneTypeText(z.type);
   if(z.type==VEGAR_ZONE_H4_SWING_HIGH || z.type==VEGAR_ZONE_M15_SWING_HIGH || z.type==VEGAR_ZONE_EXEC_SWING_HIGH) kind="PIVOT_HIGH";
   else if(z.type==VEGAR_ZONE_H4_SWING_LOW || z.type==VEGAR_ZONE_M15_SWING_LOW || z.type==VEGAR_ZONE_EXEC_SWING_LOW) kind="PIVOT_LOW";
   return "SRC_"+Vegar_SanitizeFileToken(z.symbol)+"_"+Vegar_TFText(z.source_tf)+"_"+kind+"_"+(string)(long)z.source_time;
  }

void Vegar_InitZoneProvenance(SVegarZone &z)
  {
   z.source_count=1;
   z.source_ids=Vegar_SourceIdentityForZone(z);
   z.source_types=Vegar_ZoneTypeText(z.type);
   z.source_tfs=Vegar_TFText(z.source_tf);
   z.source_times=(string)(long)z.source_time;
   z.source_confirmed_times=(string)(long)z.confirmed_time;
   z.source_atrs=DoubleToString(z.source_atr,12);
   z.primary_source_type=z.type;
   z.primary_source_tf=z.source_tf;
  }

bool Vegar_ZonesCompatibleForMerge(const SVegarZone &a,const SVegarZone &b)
  {
   if(!Vegar_ZoneContextValid(a) || !Vegar_ZoneContextValid(b)) return false;
   if(a.role!=VEGAR_ZONE_ROLE_OPERATIONAL || b.role!=VEGAR_ZONE_ROLE_OPERATIONAL) return false;
   if(a.operational_bias!=b.operational_bias) return false;
   if(a.state==VEGAR_ZONE_SWEPT || b.state==VEGAR_ZONE_SWEPT) return false;
   double gap=0.0;
   if(a.high<b.low) gap=b.low-a.high;
   else if(b.high<a.low) gap=a.low-b.high;
   double atr=MathMax(a.source_atr,b.source_atr);
   double tol=MathMax(2.0*gVegarSymbol.tick_size,InpZoneWidthATR*atr);
   return (gap<=tol);
  }

bool Vegar_SourceAlreadyPresent(const SVegarZone &z,const string source_id)
  {
   string token=";"+z.source_ids+";";
   return (StringFind(token,";"+source_id+";")>=0);
  }

void Vegar_AppendSourceProvenance(SVegarZone &dst,const SVegarZone &src)
  {
   // Preserve provenance at source granularity. Equal/composite zones may carry
   // multiple source pivots; merging the derivative zone ID alone would destroy
   // SourceIDs/Times/ConfirmedTimes/ATRs required for deterministic replay.
   string ids[],types[],tfs[],times[],confirmed[],atrs[];
   ushort sep=StringGetCharacter(";",0);
   int ni=StringSplit(src.source_ids,sep,ids);
   int nt=StringSplit(src.source_types,sep,types);
   int nf=StringSplit(src.source_tfs,sep,tfs);
   int nm=StringSplit(src.source_times,sep,times);
   int nc=StringSplit(src.source_confirmed_times,sep,confirmed);
   int na=StringSplit(src.source_atrs,sep,atrs);
   if(ni<=0)
     {
      ArrayResize(ids,1); ids[0]=src.id; ni=1;
      ArrayResize(types,1); types[0]=Vegar_ZoneTypeText(src.type); nt=1;
      ArrayResize(tfs,1); tfs[0]=Vegar_TFText(src.source_tf); nf=1;
      ArrayResize(times,1); times[0]=(string)(long)src.source_time; nm=1;
      ArrayResize(confirmed,1); confirmed[0]=(string)(long)src.confirmed_time; nc=1;
      ArrayResize(atrs,1); atrs[0]=DoubleToString(src.source_atr,12); na=1;
     }
   for(int k=0;k<ni;k++)
     {
      string sid=ids[k]; if(sid=="" || Vegar_SourceAlreadyPresent(dst,sid)) continue;
      if(dst.source_ids!="")
        {
         dst.source_ids+=";"; dst.source_types+=";"; dst.source_tfs+=";";
         dst.source_times+=";"; dst.source_confirmed_times+=";"; dst.source_atrs+=";";
        }
      dst.source_ids+=sid;
      dst.source_types+=(k<nt?types[k]:Vegar_ZoneTypeText(src.type));
      dst.source_tfs+=(k<nf?tfs[k]:Vegar_TFText(src.source_tf));
      dst.source_times+=(k<nm?times[k]:(string)(long)src.source_time);
      dst.source_confirmed_times+=(k<nc?confirmed[k]:(string)(long)src.confirmed_time);
      dst.source_atrs+=(k<na?atrs[k]:DoubleToString(src.source_atr,12));
      dst.source_count++;
     }
   ENUM_VEGAR_ZONE_TYPE primary=(src.primary_source_type!=VEGAR_ZONE_UNKNOWN?src.primary_source_type:src.type);
   int pscore=Vegar_ZoneOriginScore(primary),dscore=Vegar_ZoneOriginScore(dst.primary_source_type);
   bool prefer=(pscore>dscore || (pscore==dscore && (primary==VEGAR_ZONE_EQUAL_HIGH || primary==VEGAR_ZONE_EQUAL_LOW) && dst.primary_source_type!=primary));
   if(prefer)
     {
      dst.primary_source_type=primary;
      dst.primary_source_tf=(src.primary_source_tf!=PERIOD_CURRENT?src.primary_source_tf:src.source_tf);
     }
  }

void Vegar_MergeZoneInto(SVegarZone &dst,const SVegarZone &src)
  {
   dst.low=MathMin(dst.low,src.low);
   dst.high=MathMax(dst.high,src.high);
   Vegar_AppendSourceProvenance(dst,src);
   dst.type=VEGAR_ZONE_COMPOSITE;
   // Preserve RC5 operational normalization (max source ATR), but provenance keeps every immutable SourceATR.
   if(src.source_atr>dst.source_atr) dst.source_atr=src.source_atr;
   if(src.confirmed_time>dst.confirmed_time) dst.confirmed_time=src.confirmed_time;
   dst.last_changed=TimeTradeServer();
   Vegar_RecalcZoneGeometry(dst);
   dst.id=Vegar_ZoneCompositeID(dst);
  }

int Vegar_AddOrMergeZone(SVegarZone &z)
  {
   if(!Vegar_ZoneContextValid(z) || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL) return -1;
   int existing=Vegar_FindZoneIndex(z.id);
   if(existing>=0) return existing;
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      if(!gVegarZones[i].valid || !Vegar_ZoneContextValid(gVegarZones[i])) continue;
      if(gVegarZones[i].state==VEGAR_ZONE_INVALIDATED || gVegarZones[i].state==VEGAR_ZONE_EXPIRED || gVegarZones[i].state==VEGAR_ZONE_SWEPT) continue;
      if(Vegar_ZonesCompatibleForMerge(gVegarZones[i],z))
        {
         Vegar_MergeZoneInto(gVegarZones[i],z);
         return i;
        }
     }
   int n=ArraySize(gVegarZones);
   if(n>=VEGAR_MAX_ZONES) return -1;
   ArrayResize(gVegarZones,n+1);
   gVegarZones[n]=z;
   return n;
  }

int Vegar_AddObservationZone(SVegarZone &z)
  {
   if(z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OBSERVATION) return -1;
   int existing=Vegar_FindObservationZoneIndex(z.id);
   if(existing>=0) return existing;
   int n=ArraySize(gVegarObservationZones);
   if(n>=VEGAR_MAX_ZONES) return -1;
   ArrayResize(gVegarObservationZones,n+1);
   gVegarObservationZones[n]=z;
   return n;
  }

SVegarZone Vegar_MakeZoneRole(const string id,const ENUM_VEGAR_ZONE_TYPE type,const ENUM_TIMEFRAMES tf,
                              const ENUM_VEGAR_BIAS bias,const double center,const double atr,const datetime source_time,const datetime confirm_time,
                              const ENUM_VEGAR_ZONE_ROLE role,const int source_count=1,const double explicit_low=0.0,const double explicit_high=0.0)
  {
   SVegarZone z; ZeroMemory(z);
   Vegar_InitZoneIdentity(z,role);
   z.id=id; z.type=type; z.source_tf=tf; z.operational_bias=bias;
   z.liquidity_side=(bias==VEGAR_BIAS_SELLER ? VEGAR_LIQ_BUY_SIDE : VEGAR_LIQ_SELL_SIDE);
   z.state=VEGAR_ZONE_CREATED; z.source_time=source_time; z.confirmed_time=confirm_time; z.last_changed=confirm_time;
   z.source_atr=atr; z.touch_count=0; z.touch_episode_count=0; z.last_touch_time=0; z.bars_since_last_touch=-1;
   z.historical_reaction_atr=0.0; z.reaction_atr_3bars=0.0; z.reaction_atr_5bars=0.0; z.reaction_atr_10bars=0.0;
   z.maximum_reaction_atr=0.0; z.time_to_reaction_1atr_sec=-1; z.time_to_reaction_2atr_sec=-1;
   double pad=MathMax(2.0*gVegarSymbol.tick_size,InpZoneWidthATR*atr);
   if(explicit_high>explicit_low && explicit_low>0.0) { z.low=explicit_low-pad; z.high=explicit_high+pad; }
   else { z.low=center-pad; z.high=center+pad; }
   Vegar_RecalcZoneGeometry(z); z.valid=true; z.focus=false;
   Vegar_InitZoneProvenance(z);
   if(source_count>1) z.source_count=source_count;
   return z;
  }

SVegarZone Vegar_MakeZone(const string id,const ENUM_VEGAR_ZONE_TYPE type,const ENUM_TIMEFRAMES tf,
                          const ENUM_VEGAR_BIAS bias,const double center,const double atr,const datetime source_time,const datetime confirm_time,
                          const int source_count=1,const double explicit_low=0.0,const double explicit_high=0.0)
  {
   return Vegar_MakeZoneRole(id,type,tf,bias,center,atr,source_time,confirm_time,VEGAR_ZONE_ROLE_OPERATIONAL,source_count,explicit_low,explicit_high);
  }

void Vegar_AddReferenceZone(const ENUM_VEGAR_ZONE_TYPE type,const double level,const ENUM_TIMEFRAMES tf,const datetime source_time,const datetime confirm_time,const ENUM_VEGAR_BIAS bias)
  {
   if(level<=0.0) return;
   double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) return;
   string id=Vegar_ZoneScopedID(type,tf,(string)(long)source_time);
   SVegarZone z=Vegar_MakeZone(id,type,tf,bias,level,atr,source_time,confirm_time);
   Vegar_AddOrMergeZone(z);
  }

void Vegar_AppendZoneEvent(SVegarZone &events[],const SVegarZone &z)
  {
   int n=ArraySize(events); ArrayResize(events,n+1); events[n]=z;
  }

void Vegar_CollectPivotZoneEvents(const ENUM_TIMEFRAMES tf,const int lookback,SVegarZone &events[])
  {
   int count=(lookback>20 ? lookback : 20)+5;
   MqlRates r[]; if(!Vegar_CopyRates(tf,1,count,r)) return;
   ENUM_VEGAR_ZONE_TYPE hiType=(tf==PERIOD_H4?VEGAR_ZONE_H4_SWING_HIGH:VEGAR_ZONE_M15_SWING_HIGH);
   ENUM_VEGAR_ZONE_TYPE loType=(tf==PERIOD_H4?VEGAR_ZONE_H4_SWING_LOW:VEGAR_ZONE_M15_SWING_LOW);
   for(int i=count-4;i>=3;i--)
     {
      datetime confirm_time=r[i-2].time+PeriodSeconds(tf);
      double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) continue;
      if(Vegar_IsPivotHigh(r,i,2,2))
        {
         string id=Vegar_ZoneScopedID(hiType,tf,(string)(long)r[i].time);
         SVegarZone z=Vegar_MakeZone(id,hiType,tf,VEGAR_BIAS_SELLER,r[i].high,atr,r[i].time,confirm_time);
         Vegar_AppendZoneEvent(events,z);
        }
      if(Vegar_IsPivotLow(r,i,2,2))
        {
         string id=Vegar_ZoneScopedID(loType,tf,(string)(long)r[i].time);
         SVegarZone z=Vegar_MakeZone(id,loType,tf,VEGAR_BIAS_BUYER,r[i].low,atr,r[i].time,confirm_time);
         Vegar_AppendZoneEvent(events,z);
        }
     }
  }

void Vegar_BuildEqualZoneEvent(const ENUM_TIMEFRAMES tf,MqlRates &r[],int &idxs[],const int pos,const bool high_side,SVegarZone &events[])
  {
   int n=ArraySize(idxs); if(pos<0 || pos>=n) return;
   int idx=idxs[pos]; datetime confirm_time=r[idx-2].time+PeriodSeconds(tf);
   double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) return;
   double tol=MathMax(3.0*gVegarSymbol.tick_size,InpEqualToleranceATR*atr);
   double base=(high_side?r[idx].high:r[idx].low),minp=base,maxp=base; string source_material=(string)(long)r[idx].time; int matches=1;
   for(int older=pos+1;older<n;older++)
     {
      int oi=idxs[older]; double px=(high_side?r[oi].high:r[oi].low);
      if(MathAbs(px-base)<=tol){matches++;minp=MathMin(minp,px);maxp=MathMax(maxp,px);source_material+="_"+(string)(long)r[oi].time;}
     }
   if(matches<2) return;
   ENUM_VEGAR_ZONE_TYPE type=(high_side?VEGAR_ZONE_EQUAL_HIGH:VEGAR_ZONE_EQUAL_LOW);
   ENUM_VEGAR_BIAS bias=(high_side?VEGAR_BIAS_SELLER:VEGAR_BIAS_BUYER);
   string group=Vegar_Fnv1a64Hex(_Symbol+"|"+Vegar_TFText(tf)+"|"+source_material);
   string id=Vegar_ZoneScopedID(type,tf,group);
   SVegarZone z=Vegar_MakeZone(id,type,tf,bias,(minp+maxp)*0.5,atr,r[idx].time,confirm_time,matches,minp,maxp);
   z.source_ids=""; z.source_types=""; z.source_tfs=""; z.source_times=""; z.source_confirmed_times=""; z.source_atrs=""; z.source_count=0;
   ENUM_VEGAR_ZONE_TYPE pivotType=(tf==PERIOD_H4?(high_side?VEGAR_ZONE_H4_SWING_HIGH:VEGAR_ZONE_H4_SWING_LOW):(high_side?VEGAR_ZONE_M15_SWING_HIGH:VEGAR_ZONE_M15_SWING_LOW));
   for(int q=pos;q<n;q++)
     {
      int pi=idxs[q]; double px=(high_side?r[pi].high:r[pi].low); if(MathAbs(px-base)>tol) continue;
      datetime pct=r[pi-2].time+PeriodSeconds(tf); double patr=Vegar_ATRAtTime(tf,pct); if(patr<=0.0)patr=atr;
      string sid="SRC_"+Vegar_SanitizeFileToken(_Symbol)+"_"+Vegar_TFText(tf)+"_"+(high_side?"PIVOT_HIGH_":"PIVOT_LOW_")+(string)(long)r[pi].time;
      if(z.source_ids!=""){z.source_ids+=";";z.source_types+=";";z.source_tfs+=";";z.source_times+=";";z.source_confirmed_times+=";";z.source_atrs+=";";}
      z.source_ids+=sid; z.source_types+=Vegar_ZoneTypeText(pivotType); z.source_tfs+=Vegar_TFText(tf); z.source_times+=(string)(long)r[pi].time; z.source_confirmed_times+=(string)(long)pct; z.source_atrs+=DoubleToString(patr,12); z.source_count++;
     }
   z.primary_source_type=type; z.primary_source_tf=tf; Vegar_AppendZoneEvent(events,z);
  }

void Vegar_CollectEqualZoneEvents(const ENUM_TIMEFRAMES tf,const int lookback,SVegarZone &events[])
  {
   int count=(lookback>30?lookback:30)+5; MqlRates r[]; if(!Vegar_CopyRates(tf,1,count,r)) return;
   int hi[],lo[]; ArrayResize(hi,0); ArrayResize(lo,0);
   for(int i=3;i<count-3;i++)
     {
      if(Vegar_IsPivotHigh(r,i,2,2)){int n=ArraySize(hi);ArrayResize(hi,n+1);hi[n]=i;}
      if(Vegar_IsPivotLow(r,i,2,2)){int n=ArraySize(lo);ArrayResize(lo,n+1);lo[n]=i;}
     }
   for(int p=ArraySize(hi)-1;p>=0;p--) Vegar_BuildEqualZoneEvent(tf,r,hi,p,true,events);
   for(int p=ArraySize(lo)-1;p>=0;p--) Vegar_BuildEqualZoneEvent(tf,r,lo,p,false,events);
  }

void Vegar_CollectReferenceZoneEvent(const ENUM_VEGAR_ZONE_TYPE type,const double level,const ENUM_TIMEFRAMES tf,const datetime source_time,const datetime confirm_time,const ENUM_VEGAR_BIAS bias,SVegarZone &events[])
  {
   if(level<=0.0 || source_time<=0 || confirm_time<=0) return;
   double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) return;
   string id=Vegar_ZoneScopedID(type,tf,(string)(long)source_time);
   SVegarZone z=Vegar_MakeZone(id,type,tf,bias,level,atr,source_time,confirm_time);
   Vegar_AppendZoneEvent(events,z);
  }

void Vegar_CollectCurrentTemporalReferenceEvents(SVegarZone &events[])
  {
   datetime d1=iTime(_Symbol,PERIOD_D1,1),d0=iTime(_Symbol,PERIOD_D1,0);
   datetime w1=iTime(_Symbol,PERIOD_W1,1),w0=iTime(_Symbol,PERIOD_W1,0);
   if(d1>0 && d0>0)
     {
      Vegar_CollectReferenceZoneEvent(VEGAR_ZONE_PDH,iHigh(_Symbol,PERIOD_D1,1),PERIOD_H4,d1,d0,VEGAR_BIAS_SELLER,events);
      Vegar_CollectReferenceZoneEvent(VEGAR_ZONE_PDL,iLow(_Symbol,PERIOD_D1,1),PERIOD_H4,d1,d0,VEGAR_BIAS_BUYER,events);
     }
   if(w1>0 && w0>0)
     {
      Vegar_CollectReferenceZoneEvent(VEGAR_ZONE_PWH,iHigh(_Symbol,PERIOD_W1,1),PERIOD_H4,w1,w0,VEGAR_BIAS_SELLER,events);
      Vegar_CollectReferenceZoneEvent(VEGAR_ZONE_PWL,iLow(_Symbol,PERIOD_W1,1),PERIOD_H4,w1,w0,VEGAR_BIAS_BUYER,events);
     }
  }

void Vegar_SortZoneEventsChronologically(SVegarZone &events[])
  {
   int n=ArraySize(events);
   for(int i=1;i<n;i++)
     {
      SVegarZone key=events[i]; int j=i-1;
      while(j>=0)
        {
         bool after=(events[j].confirmed_time>key.confirmed_time);
         if(!after && events[j].confirmed_time==key.confirmed_time) after=(StringCompare(events[j].id,key.id)>0);
         if(!after) break;
         events[j+1]=events[j]; j--;
        }
      events[j+1]=key;
     }
  }

void Vegar_UpdateZoneStatesHistorical(const MqlRates &bar,const double atr)
  {
   if(atr<=0.0) return;
   double minSweep=MathMax(2.0*gVegarSymbol.tick_size,InpMinSweepATR*atr),maxSweep=InpMaxSweepATR*atr;
   datetime close_time=bar.time+PeriodSeconds(Vegar_ExecutionTF());
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      if(!gVegarZones[i].valid || gVegarZones[i].role!=VEGAR_ZONE_ROLE_OPERATIONAL ||
         gVegarZones[i].state==VEGAR_ZONE_EXPIRED || gVegarZones[i].state==VEGAR_ZONE_INVALIDATED ||
         gVegarZones[i].state==VEGAR_ZONE_SWEPT) continue;
      if(gVegarZones[i].confirmed_time>0 && close_time<gVegarZones[i].confirmed_time) continue;
      ENUM_VEGAR_ZONE_STATE old=gVegarZones[i].state;
      if(gVegarZones[i].operational_bias==VEGAR_BIAS_BUYER)
        {
         if(bar.close<gVegarZones[i].low-maxSweep) gVegarZones[i].state=VEGAR_ZONE_INVALIDATED;
         else if(bar.low<=gVegarZones[i].low-minSweep && bar.close>=gVegarZones[i].mid) gVegarZones[i].state=VEGAR_ZONE_SWEPT;
         else if(bar.low<=gVegarZones[i].high) gVegarZones[i].state=VEGAR_ZONE_TOUCHED;
         else if(gVegarZones[i].state==VEGAR_ZONE_CREATED) gVegarZones[i].state=VEGAR_ZONE_ACTIVE;
        }
      else if(gVegarZones[i].operational_bias==VEGAR_BIAS_SELLER)
        {
         if(bar.close>gVegarZones[i].high+maxSweep) gVegarZones[i].state=VEGAR_ZONE_INVALIDATED;
         else if(bar.high>=gVegarZones[i].high+minSweep && bar.close<=gVegarZones[i].mid) gVegarZones[i].state=VEGAR_ZONE_SWEPT;
         else if(bar.high>=gVegarZones[i].low) gVegarZones[i].state=VEGAR_ZONE_TOUCHED;
         else if(gVegarZones[i].state==VEGAR_ZONE_CREATED) gVegarZones[i].state=VEGAR_ZONE_ACTIVE;
        }
      if(old!=gVegarZones[i].state) gVegarZones[i].last_changed=close_time;
     }
  }

void Vegar_ReplayZoneLifecycleWindow(const datetime after_time,const datetime through_time)
  {
   if(through_time<=after_time) return;
   ENUM_TIMEFRAMES tf=Vegar_ExecutionTF(); int sec=PeriodSeconds(tf); if(sec<=0) return;
   MqlRates bars[]; ArraySetAsSeries(bars,false);
   datetime from_time=after_time-sec; if(from_time<0)from_time=0;
   int copied=CopyRates(_Symbol,tf,from_time,through_time,bars); if(copied<=0) return;
   for(int i=0;i<copied;i++)
     {
      datetime close_time=bars[i].time+sec;
      if(close_time<=after_time || close_time>through_time) continue;
      double atr=Vegar_ATRAtTime(tf,close_time); if(atr<=0.0) continue;
      Vegar_UpdateZoneStatesHistorical(bars[i],atr);
     }
  }

void Vegar_ApplyOldTerminalStates(SVegarZone &old[])
  {
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      int oi=Vegar_FindZoneByIdInArray(old,gVegarZones[i].id); if(oi<0) continue;
      ENUM_VEGAR_ZONE_STATE st=old[oi].state;
      if(st==VEGAR_ZONE_SWEPT || st==VEGAR_ZONE_INVALIDATED || st==VEGAR_ZONE_EXPIRED)
        { gVegarZones[i].state=st; if(old[oi].last_changed>gVegarZones[i].last_changed) gVegarZones[i].last_changed=old[oi].last_changed; }
     }
  }

void Vegar_ScanPivotZones(const ENUM_TIMEFRAMES tf,const int lookback)
  {
   int count=(lookback>20 ? lookback : 20)+5;
   MqlRates r[]; if(!Vegar_CopyRates(tf,1,count,r)) return;
   ENUM_VEGAR_ZONE_TYPE hiType=(tf==PERIOD_H4?VEGAR_ZONE_H4_SWING_HIGH:VEGAR_ZONE_M15_SWING_HIGH);
   ENUM_VEGAR_ZONE_TYPE loType=(tf==PERIOD_H4?VEGAR_ZONE_H4_SWING_LOW:VEGAR_ZONE_M15_SWING_LOW);
   // Chronological replay: oldest confirmed pivot first.
   for(int i=count-4;i>=3;i--)
     {
      datetime confirm_time=r[i-2].time+PeriodSeconds(tf);
      double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) continue;
      if(Vegar_IsPivotHigh(r,i,2,2))
        {
         string id=Vegar_ZoneScopedID(hiType,tf,(string)(long)r[i].time);
         SVegarZone z=Vegar_MakeZone(id,hiType,tf,VEGAR_BIAS_SELLER,r[i].high,atr,r[i].time,confirm_time);
         Vegar_AddOrMergeZone(z);
        }
      if(Vegar_IsPivotLow(r,i,2,2))
        {
         string id=Vegar_ZoneScopedID(loType,tf,(string)(long)r[i].time);
         SVegarZone z=Vegar_MakeZone(id,loType,tf,VEGAR_BIAS_BUYER,r[i].low,atr,r[i].time,confirm_time);
         Vegar_AddOrMergeZone(z);
        }
     }
  }

void Vegar_ScanEqualSide(const ENUM_TIMEFRAMES tf,MqlRates &r[],int &idxs[],const bool high_side)
  {
   int n=ArraySize(idxs);
   // Newest candidate is processed only after older pivots were available, using its contemporary confirmation ATR.
   for(int pos=n-1;pos>=0;pos--)
     {
      int idx=idxs[pos];
      datetime confirm_time=r[idx-2].time+PeriodSeconds(tf);
      double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) continue;
      double tol=MathMax(3.0*gVegarSymbol.tick_size,InpEqualToleranceATR*atr);
      double base=(high_side?r[idx].high:r[idx].low),minp=base,maxp=base;
      string source_material=(string)(long)r[idx].time;
      int matches=1;
      for(int older=pos+1;older<n;older++)
        {
         int oi=idxs[older];
         double p=(high_side?r[oi].high:r[oi].low);
         if(MathAbs(p-base)<=tol)
           {
            matches++; minp=MathMin(minp,p); maxp=MathMax(maxp,p);
            source_material+="_"+(string)(long)r[oi].time;
           }
        }
      if(matches<2) continue;
      ENUM_VEGAR_ZONE_TYPE type=(high_side?VEGAR_ZONE_EQUAL_HIGH:VEGAR_ZONE_EQUAL_LOW);
      ENUM_VEGAR_BIAS bias=(high_side?VEGAR_BIAS_SELLER:VEGAR_BIAS_BUYER);
      string group=Vegar_Fnv1a64Hex(_Symbol+"|"+Vegar_TFText(tf)+"|"+source_material);
      string id=Vegar_ZoneScopedID(type,tf,group);
      SVegarZone z=Vegar_MakeZone(id,type,tf,bias,(minp+maxp)*0.5,atr,r[idx].time,confirm_time,matches,minp,maxp);
      z.source_ids=""; z.source_types=""; z.source_tfs=""; z.source_times=""; z.source_confirmed_times=""; z.source_atrs=""; z.source_count=0;
      ENUM_VEGAR_ZONE_TYPE pivotType=(tf==PERIOD_H4?(high_side?VEGAR_ZONE_H4_SWING_HIGH:VEGAR_ZONE_H4_SWING_LOW):(high_side?VEGAR_ZONE_M15_SWING_HIGH:VEGAR_ZONE_M15_SWING_LOW));
      for(int q=pos;q<n;q++)
        {
         int pi=idxs[q]; double pp=(high_side?r[pi].high:r[pi].low); if(MathAbs(pp-base)>tol) continue;
         datetime pct=r[pi-2].time+PeriodSeconds(tf); double patr=Vegar_ATRAtTime(tf,pct); if(patr<=0.0) patr=atr;
         string sid="SRC_"+Vegar_SanitizeFileToken(_Symbol)+"_"+Vegar_TFText(tf)+"_"+(high_side?"PIVOT_HIGH_":"PIVOT_LOW_")+(string)(long)r[pi].time;
         if(z.source_ids!="") { z.source_ids+=";"; z.source_types+=";"; z.source_tfs+=";"; z.source_times+=";"; z.source_confirmed_times+=";"; z.source_atrs+=";"; }
         z.source_ids+=sid; z.source_types+=Vegar_ZoneTypeText(pivotType); z.source_tfs+=Vegar_TFText(tf);
         z.source_times+=(string)(long)r[pi].time; z.source_confirmed_times+=(string)(long)pct; z.source_atrs+=DoubleToString(patr,12); z.source_count++;
        }
      z.primary_source_type=type; z.primary_source_tf=tf;
      Vegar_AddOrMergeZone(z);
     }
  }

void Vegar_ScanEqualZones(const ENUM_TIMEFRAMES tf,const int lookback)
  {
   int count=(lookback>30 ? lookback : 30)+5;
   MqlRates r[]; if(!Vegar_CopyRates(tf,1,count,r)) return;
   int hiIdx[]; int loIdx[]; ArrayResize(hiIdx,0); ArrayResize(loIdx,0);
   // store newest-to-oldest, as series indices grow into the past
   for(int i=3;i<count-3;i++)
     {
      if(Vegar_IsPivotHigh(r,i,2,2)) { int n=ArraySize(hiIdx); ArrayResize(hiIdx,n+1); hiIdx[n]=i; }
      if(Vegar_IsPivotLow(r,i,2,2))  { int n=ArraySize(loIdx); ArrayResize(loIdx,n+1); loIdx[n]=i; }
     }
   Vegar_ScanEqualSide(tf,r,hiIdx,true);
   Vegar_ScanEqualSide(tf,r,loIdx,false);
  }

void Vegar_AddPreviousPeriodReferences()
  {
   datetime d1=iTime(_Symbol,PERIOD_D1,1),d0=iTime(_Symbol,PERIOD_D1,0);
   datetime w1=iTime(_Symbol,PERIOD_W1,1),w0=iTime(_Symbol,PERIOD_W1,0);
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      if(!gVegarZones[i].valid || !Vegar_ZoneContextValid(gVegarZones[i])) continue;
      bool temporal=(gVegarZones[i].type==VEGAR_ZONE_PDH || gVegarZones[i].type==VEGAR_ZONE_PDL || gVegarZones[i].type==VEGAR_ZONE_PWH || gVegarZones[i].type==VEGAR_ZONE_PWL);
      if(!temporal) continue;
      if((gVegarZones[i].type==VEGAR_ZONE_PDH || gVegarZones[i].type==VEGAR_ZONE_PDL) && d1>0 && gVegarZones[i].source_time!=d1) gVegarZones[i].state=VEGAR_ZONE_EXPIRED;
      if((gVegarZones[i].type==VEGAR_ZONE_PWH || gVegarZones[i].type==VEGAR_ZONE_PWL) && w1>0 && gVegarZones[i].source_time!=w1) gVegarZones[i].state=VEGAR_ZONE_EXPIRED;
     }
   if(d1>0 && d0>0)
     {
      Vegar_AddReferenceZone(VEGAR_ZONE_PDH,iHigh(_Symbol,PERIOD_D1,1),PERIOD_H4,d1,d0,VEGAR_BIAS_SELLER);
      Vegar_AddReferenceZone(VEGAR_ZONE_PDL,iLow(_Symbol,PERIOD_D1,1),PERIOD_H4,d1,d0,VEGAR_BIAS_BUYER);
     }
   if(w1>0 && w0>0)
     {
      Vegar_AddReferenceZone(VEGAR_ZONE_PWH,iHigh(_Symbol,PERIOD_W1,1),PERIOD_H4,w1,w0,VEGAR_BIAS_SELLER);
      Vegar_AddReferenceZone(VEGAR_ZONE_PWL,iLow(_Symbol,PERIOD_W1,1),PERIOD_H4,w1,w0,VEGAR_BIAS_BUYER);
     }
  }

void Vegar_CalcTouchMetrics(SVegarZone &z)
  {
   MqlRates r[]; int count=120;
   z.touch_count=0; z.touch_episode_count=0; z.last_touch_time=0; z.bars_since_last_touch=-1;
   if(!Vegar_CopyRates(z.source_tf,1,count,r)) return;
   bool inside_prev=false;
   int last_shift=-1;
   // chronological iteration
   for(int i=count-1;i>=0;i--)
     {
      if(r[i].time<z.confirmed_time) continue;
      bool inside=(r[i].low<=z.high && r[i].high>=z.low);
      if(inside)
        {
         z.touch_count++;
         if(!inside_prev) z.touch_episode_count++;
         if(z.last_touch_time==0 || r[i].time>z.last_touch_time) { z.last_touch_time=r[i].time; last_shift=i; }
        }
      inside_prev=inside;
     }
   if(last_shift>=0) z.bars_since_last_touch=last_shift;
  }

int Vegar_CountZoneTouches(const SVegarZone &z)
  {
   SVegarZone tmp=z; Vegar_CalcTouchMetrics(tmp); return tmp.touch_count;
  }

void Vegar_CalcReactionMetrics(SVegarZone &z)
  {
   z.reaction_atr_3bars=0.0; z.reaction_atr_5bars=0.0; z.reaction_atr_10bars=0.0; z.maximum_reaction_atr=0.0;
   z.time_to_reaction_1atr_sec=-1; z.time_to_reaction_2atr_sec=-1;
   if(z.source_atr<=0.0) return;
   MqlRates r[]; int count=160;
   if(!Vegar_CopyRates(z.source_tf,1,count,r)) return;
   bool seen=false; int after=0; datetime touch_time=0;
   for(int i=count-1;i>=0;i--)
     {
      if(r[i].time<z.confirmed_time) continue;
      bool touch=(r[i].low<=z.high && r[i].high>=z.low);
      if(!seen && touch) { seen=true; touch_time=r[i].time; continue; }
      if(!seen) continue;
      after++;
      double reaction=(z.operational_bias==VEGAR_BIAS_BUYER ? r[i].high-z.high : z.low-r[i].low);
      double ratr=MathMax(0.0,reaction/z.source_atr);
      z.maximum_reaction_atr=MathMax(z.maximum_reaction_atr,ratr);
      if(after<=3) z.reaction_atr_3bars=MathMax(z.reaction_atr_3bars,ratr);
      if(after<=5) z.reaction_atr_5bars=MathMax(z.reaction_atr_5bars,ratr);
      if(after<=10) z.reaction_atr_10bars=MathMax(z.reaction_atr_10bars,ratr);
      if(z.time_to_reaction_1atr_sec<0 && ratr>=1.0) z.time_to_reaction_1atr_sec=(int)(r[i].time-touch_time);
      if(z.time_to_reaction_2atr_sec<0 && ratr>=2.0) z.time_to_reaction_2atr_sec=(int)(r[i].time-touch_time);
     }
   z.historical_reaction_atr=z.maximum_reaction_atr; // operational RC5 authority preserved
  }

double Vegar_ZoneHistoricalReactionATR(const SVegarZone &z)
  {
   SVegarZone tmp=z; Vegar_CalcReactionMetrics(tmp); return tmp.maximum_reaction_atr;
  }

void Vegar_RecalculateZoneStrength(SVegarZone &z)
  {
   int origin=Vegar_ZoneOriginScore(z.primary_source_type);
   int extra_sources=(z.source_count-1>0 ? z.source_count-1 : 0);
   int confluence=(extra_sources*5<25 ? extra_sources*5 : 25);
   Vegar_CalcTouchMetrics(z);
   int fresh=20;
   if(z.state==VEGAR_ZONE_SWEPT || z.state==VEGAR_ZONE_INVALIDATED) fresh=0;
   else if(z.touch_count<=0) fresh=20;
   else if(z.touch_count==1) fresh=14;
   else if(z.touch_count==2) fresh=8;
   else fresh=3;
   Vegar_CalcReactionMetrics(z);
   int reaction=8;
   if(z.historical_reaction_atr>=2.0) reaction=15;
   else if(z.historical_reaction_atr>=1.0) reaction=10;
   else if(z.historical_reaction_atr>=0.5) reaction=5;
   else if(z.touch_count>0) reaction=0;
   int quality=5;
   if(z.primary_source_type==VEGAR_ZONE_PDH || z.primary_source_type==VEGAR_ZONE_PDL || z.primary_source_type==VEGAR_ZONE_PWH || z.primary_source_type==VEGAR_ZONE_PWL) quality=8;
   else if((z.primary_source_type==VEGAR_ZONE_EQUAL_HIGH || z.primary_source_type==VEGAR_ZONE_EQUAL_LOW) && z.source_count>=3) quality=10;
   else if(z.primary_source_type==VEGAR_ZONE_EQUAL_HIGH || z.primary_source_type==VEGAR_ZONE_EQUAL_LOW) quality=7;
   double width_atr=(z.source_atr>0.0 ? z.width/z.source_atr : 999.0);
   int clean=(width_atr<=0.10?5:(width_atr<=0.20?3:1));
   int total_score=origin+confluence+fresh+reaction+quality+clean;
   z.strength_score=(double)(total_score<100 ? total_score : 100);
   z.strength_class=Vegar_StrengthClass(z.strength_score);
  }

int Vegar_FindZoneByIdInArray(SVegarZone &arr[],const string id)
  {
   for(int i=0;i<ArraySize(arr);i++) if(arr[i].valid && arr[i].id==id && arr[i].symbol==_Symbol) return i;
   return -1;
  }

void Vegar_RebuildLiquidityMap()
  {
   SVegarZone old[]; ArrayResize(old,ArraySize(gVegarZones));
   for(int i=0;i<ArraySize(gVegarZones);i++) old[i]=gVegarZones[i];
   ArrayResize(gVegarZones,0);

   SVegarZone events[]; ArrayResize(events,0);
   Vegar_CollectPivotZoneEvents(PERIOD_H4,120,events);
   Vegar_CollectPivotZoneEvents(PERIOD_M15,160,events);
   Vegar_CollectEqualZoneEvents(PERIOD_H4,120,events);
   Vegar_CollectEqualZoneEvents(PERIOD_M15,160,events);
   Vegar_CollectCurrentTemporalReferenceEvents(events);
   Vegar_SortZoneEventsChronologically(events);

   datetime cursor=0;
   for(int e=0;e<ArraySize(events);e++)
     {
      datetime t=events[e].confirmed_time;
      if(cursor>0 && t>cursor) Vegar_ReplayZoneLifecycleWindow(cursor,t);
      // Runtime continuity: if the identity that existed before this event was already
      // terminal, restore it before deciding whether a new source may merge into it.
      if(ArraySize(old)>0) Vegar_ApplyOldTerminalStates(old);
      SVegarZone z=events[e]; Vegar_AddOrMergeZone(z);
      if(ArraySize(old)>0) Vegar_ApplyOldTerminalStates(old);
      if(t>cursor) cursor=t;
     }

   datetime last_bar=iTime(_Symbol,Vegar_ExecutionTF(),1);
   datetime through=(last_bar>0?last_bar+PeriodSeconds(Vegar_ExecutionTF()):TimeTradeServer());
   if(cursor>0 && through>cursor) Vegar_ReplayZoneLifecycleWindow(cursor,through);
   if(ArraySize(old)>0) Vegar_ApplyOldTerminalStates(old);

   for(int i=0;i<ArraySize(gVegarZones);i++)
      if(gVegarZones[i].valid && Vegar_ZoneContextValid(gVegarZones[i])) Vegar_RecalculateZoneStrength(gVegarZones[i]);

   // Keep disappeared derivative/temporal identities for one cycle as terminal history.
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent();
   for(int oi=0;oi<ArraySize(old) && ArraySize(gVegarZones)<VEGAR_MAX_ZONES;oi++)
     {
      if(!old[oi].valid || old[oi].symbol!=_Symbol || old[oi].magic!=InpMagicNumber) continue;
      if(old[oi].state==VEGAR_ZONE_EXPIRED) continue;
      if(Vegar_FindZoneByIdInArray(gVegarZones,old[oi].id)>=0) continue;
      SVegarZone terminal=old[oi]; terminal.state=VEGAR_ZONE_EXPIRED; terminal.focus=false; terminal.last_changed=now;
      int nn=ArraySize(gVegarZones); ArrayResize(gVegarZones,nn+1); gVegarZones[nn]=terminal;
     }
  }

void Vegar_ScanObservationPivots(const ENUM_TIMEFRAMES tf,const int lookback)
  {
   int count=(lookback>30?lookback:30)+5;
   MqlRates r[]; if(!Vegar_CopyRates(tf,1,count,r)) return;
   for(int i=count-4;i>=3;i--)
     {
      datetime confirm_time=r[i-2].time+PeriodSeconds(tf);
      double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) continue;
      if(Vegar_IsPivotHigh(r,i,2,2))
        {
         string id=Vegar_ZoneScopedID(VEGAR_ZONE_EXEC_SWING_HIGH,tf,(string)(long)r[i].time);
         SVegarZone z=Vegar_MakeZoneRole(id,VEGAR_ZONE_EXEC_SWING_HIGH,tf,VEGAR_BIAS_SELLER,r[i].high,atr,r[i].time,confirm_time,VEGAR_ZONE_ROLE_OBSERVATION);
         Vegar_RecalculateZoneStrength(z); Vegar_AddObservationZone(z);
        }
      if(Vegar_IsPivotLow(r,i,2,2))
        {
         string id=Vegar_ZoneScopedID(VEGAR_ZONE_EXEC_SWING_LOW,tf,(string)(long)r[i].time);
         SVegarZone z=Vegar_MakeZoneRole(id,VEGAR_ZONE_EXEC_SWING_LOW,tf,VEGAR_BIAS_BUYER,r[i].low,atr,r[i].time,confirm_time,VEGAR_ZONE_ROLE_OBSERVATION);
         Vegar_RecalculateZoneStrength(z); Vegar_AddObservationZone(z);
        }
     }
  }

void Vegar_ScanObservationEqualSide(const ENUM_TIMEFRAMES tf,MqlRates &r[],int &idxs[],const bool high_side)
  {
   int n=ArraySize(idxs);
   for(int pos=n-1;pos>=0;pos--)
     {
      int idx=idxs[pos]; datetime confirm_time=r[idx-2].time+PeriodSeconds(tf);
      double atr=Vegar_ATRAtTime(tf,confirm_time); if(atr<=0.0) continue;
      double tol=MathMax(3.0*gVegarSymbol.tick_size,InpEqualToleranceATR*atr);
      double base=(high_side?r[idx].high:r[idx].low),minp=base,maxp=base; string material=(string)(long)r[idx].time; int matches=1;
      for(int q=pos+1;q<n;q++)
        {
         int oi=idxs[q]; double px=(high_side?r[oi].high:r[oi].low); if(MathAbs(px-base)>tol) continue;
         matches++; minp=MathMin(minp,px); maxp=MathMax(maxp,px); material+="_"+(string)(long)r[oi].time;
        }
      if(matches<2) continue;
      ENUM_VEGAR_ZONE_TYPE type=(high_side?VEGAR_ZONE_EQUAL_HIGH:VEGAR_ZONE_EQUAL_LOW); ENUM_VEGAR_BIAS bias=(high_side?VEGAR_BIAS_SELLER:VEGAR_BIAS_BUYER);
      string id=Vegar_ZoneScopedID(type,tf,Vegar_Fnv1a64Hex(_Symbol+"|OBS|"+Vegar_TFText(tf)+"|"+material));
      SVegarZone z=Vegar_MakeZoneRole(id,type,tf,bias,(minp+maxp)*0.5,atr,r[idx].time,confirm_time,VEGAR_ZONE_ROLE_OBSERVATION,matches,minp,maxp);
      z.source_ids=""; z.source_types=""; z.source_tfs=""; z.source_times=""; z.source_confirmed_times=""; z.source_atrs=""; z.source_count=0;
      for(int q=pos;q<n;q++)
        {
         int pi=idxs[q]; double px=(high_side?r[pi].high:r[pi].low); if(MathAbs(px-base)>tol) continue;
         datetime pct=r[pi-2].time+PeriodSeconds(tf); double patr=Vegar_ATRAtTime(tf,pct); if(patr<=0.0) patr=atr;
         string sid="SRC_"+Vegar_SanitizeFileToken(_Symbol)+"_"+Vegar_TFText(tf)+"_OBS_"+(high_side?"PIVOT_HIGH_":"PIVOT_LOW_")+(string)(long)r[pi].time;
         if(z.source_ids!="") { z.source_ids+=";"; z.source_types+=";"; z.source_tfs+=";"; z.source_times+=";"; z.source_confirmed_times+=";"; z.source_atrs+=";"; }
         z.source_ids+=sid; z.source_types+=(high_side?"OBS_PIVOT_HIGH":"OBS_PIVOT_LOW"); z.source_tfs+=Vegar_TFText(tf); z.source_times+=(string)(long)r[pi].time; z.source_confirmed_times+=(string)(long)pct; z.source_atrs+=DoubleToString(patr,12); z.source_count++;
        }
      z.primary_source_type=type; z.primary_source_tf=tf; Vegar_RecalculateZoneStrength(z); Vegar_AddObservationZone(z);
     }
  }

void Vegar_ScanObservationEquals(const ENUM_TIMEFRAMES tf,const int lookback)
  {
   int count=(lookback>30?lookback:30)+5; MqlRates r[]; if(!Vegar_CopyRates(tf,1,count,r)) return;
   int hi[],lo[]; ArrayResize(hi,0); ArrayResize(lo,0);
   for(int i=3;i<count-3;i++)
     {
      if(Vegar_IsPivotHigh(r,i,2,2)){int n=ArraySize(hi);ArrayResize(hi,n+1);hi[n]=i;}
      if(Vegar_IsPivotLow(r,i,2,2)){int n=ArraySize(lo);ArrayResize(lo,n+1);lo[n]=i;}
     }
   Vegar_ScanObservationEqualSide(tf,r,hi,true); Vegar_ScanObservationEqualSide(tf,r,lo,false);
  }

void Vegar_RebuildObservationLiquidity()
  {
   // RC8: M1/M5 zones can carry operational MICRO_CONTINUATION authority.
   // Preserve terminal lifecycle by stable zone id so a consumed sweep cannot be recreated every bar.
   SVegarZone old[]; ArrayResize(old,ArraySize(gVegarObservationZones));
   for(int i=0;i<ArraySize(gVegarObservationZones);i++) old[i]=gVegarObservationZones[i];

   ArrayResize(gVegarObservationZones,0);
   Vegar_ScanObservationPivots(PERIOD_M5,100);
   Vegar_ScanObservationEquals(PERIOD_M5,100);
   Vegar_ScanObservationPivots(PERIOD_M1,120);
   Vegar_ScanObservationEquals(PERIOD_M1,120);

   for(int i=0;i<ArraySize(gVegarObservationZones);i++)
     {
      int oi=Vegar_FindZoneByIdInArray(old,gVegarObservationZones[i].id);
      if(oi<0) continue;
      ENUM_VEGAR_ZONE_STATE st=old[oi].state;
      if(st==VEGAR_ZONE_SWEPT || st==VEGAR_ZONE_INVALIDATED || st==VEGAR_ZONE_EXPIRED)
        {
         gVegarObservationZones[i].state=st;
         if(old[oi].last_changed>gVegarObservationZones[i].last_changed)
            gVegarObservationZones[i].last_changed=old[oi].last_changed;
        }
     }
  }

void Vegar_UpdateZoneStates(const MqlRates &closed_exec_bar)
  {
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
   if(atr<=0.0) return;
   double minSweep=MathMax(2.0*gVegarSymbol.tick_size,InpMinSweepATR*atr);
   double maxSweep=InpMaxSweepATR*atr;
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      if(!gVegarZones[i].valid || !Vegar_ZoneContextValid(gVegarZones[i]) || gVegarZones[i].role!=VEGAR_ZONE_ROLE_OPERATIONAL ||
         gVegarZones[i].state==VEGAR_ZONE_EXPIRED || gVegarZones[i].state==VEGAR_ZONE_INVALIDATED || gVegarZones[i].state==VEGAR_ZONE_SWEPT) continue;
      ENUM_VEGAR_ZONE_STATE old=gVegarZones[i].state;
      if(gVegarZones[i].operational_bias==VEGAR_BIAS_BUYER)
        {
         if(closed_exec_bar.close<gVegarZones[i].low-maxSweep) gVegarZones[i].state=VEGAR_ZONE_INVALIDATED;
         else if(closed_exec_bar.low<=gVegarZones[i].low-minSweep && closed_exec_bar.close>=gVegarZones[i].mid) gVegarZones[i].state=VEGAR_ZONE_SWEPT;
         else if(closed_exec_bar.low<=gVegarZones[i].high) gVegarZones[i].state=VEGAR_ZONE_TOUCHED;
         else if(gVegarZones[i].state==VEGAR_ZONE_CREATED) gVegarZones[i].state=VEGAR_ZONE_ACTIVE;
        }
      else if(gVegarZones[i].operational_bias==VEGAR_BIAS_SELLER)
        {
         if(closed_exec_bar.close>gVegarZones[i].high+maxSweep) gVegarZones[i].state=VEGAR_ZONE_INVALIDATED;
         else if(closed_exec_bar.high>=gVegarZones[i].high+minSweep && closed_exec_bar.close<=gVegarZones[i].mid) gVegarZones[i].state=VEGAR_ZONE_SWEPT;
         else if(closed_exec_bar.high>=gVegarZones[i].low) gVegarZones[i].state=VEGAR_ZONE_TOUCHED;
         else if(gVegarZones[i].state==VEGAR_ZONE_CREATED) gVegarZones[i].state=VEGAR_ZONE_ACTIVE;
        }
      if(old!=gVegarZones[i].state) gVegarZones[i].last_changed=TimeTradeServer();
      Vegar_RecalculateZoneStrength(gVegarZones[i]);
     }
  }

bool Vegar_ZoneCompatibleWithContext(const SVegarZone &z,const ENUM_VEGAR_M15_CONTEXT context)
  {
   if(z.role!=VEGAR_ZONE_ROLE_OPERATIONAL || !Vegar_ZoneContextValid(z) || z.state==VEGAR_ZONE_SWEPT) return false;
   if(context==VEGAR_M15_TREND_UP && z.operational_bias==VEGAR_BIAS_SELLER) return false;
   if(context==VEGAR_M15_TREND_DOWN && z.operational_bias==VEGAR_BIAS_BUYER) return false;
   return true;
  }

int Vegar_SelectFocusZone(const ENUM_VEGAR_M15_CONTEXT context)
  {
   for(int i=0;i<ArraySize(gVegarZones);i++) gVegarZones[i].focus=false;
   gVegarFocusZoneID="";
   if(!Vegar_UpdateTick()) return -1;
   double midPrice=(gVegarTick.bid+gVegarTick.ask)*0.5;
   int best=-1; double bestDist=DBL_MAX; double bestStrength=-1.0; datetime bestRecent=0;
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      SVegarZone z=gVegarZones[i];
      if(!z.valid || !Vegar_ZoneContextValid(z) || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
      if(z.strength_score<(double)InpForcaMinimaZona) continue;
      if(!Vegar_ZoneCompatibleWithContext(z,context)) continue;
      if(z.operational_bias==VEGAR_BIAS_BUYER && z.mid>midPrice) continue;
      if(z.operational_bias==VEGAR_BIAS_SELLER && z.mid<midPrice) continue;
      double d=0.0;
      if(midPrice<z.low) d=z.low-midPrice; else if(midPrice>z.high) d=midPrice-z.high;
      bool better=(d<bestDist-1e-12 || (MathAbs(d-bestDist)<=1e-12 && (z.strength_score>bestStrength+1e-9 || (MathAbs(z.strength_score-bestStrength)<=1e-9 && z.confirmed_time>bestRecent))));
      if(better) { bestDist=d; bestStrength=z.strength_score; bestRecent=z.confirmed_time; best=i; }
     }
   if(best>=0) { gVegarZones[best].focus=true; gVegarFocusZoneID=gVegarZones[best].id; }
   return best;
  }

int Vegar_FocusZoneIndex() { return Vegar_FindZoneIndex(gVegarFocusZoneID); }


// RC8: technical location selector is deliberately independent from M15/session/news/spread gates.
// It answers only whether a structurally eligible operational zone deserves technical monitoring.
int Vegar_SelectTechnicalCandidateZone()
  {
   if(!Vegar_UpdateTick()) return -1;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5;
   int best=-1; double bestDist=DBL_MAX; double bestStrength=-1.0; datetime bestRecent=0;
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      SVegarZone z=gVegarZones[i];
      if(!z.valid || !Vegar_ZoneContextValid(z) || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL) continue;
      if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
      if(z.strength_score<(double)InpForcaMinimaZona) continue;
      if(z.operational_bias==VEGAR_BIAS_BUYER && z.mid>p) continue;
      if(z.operational_bias==VEGAR_BIAS_SELLER && z.mid<p) continue;
      double d=0.0; if(p<z.low)d=z.low-p; else if(p>z.high)d=p-z.high;
      bool better=(d<bestDist-1e-12 || (MathAbs(d-bestDist)<=1e-12 &&
                   (z.strength_score>bestStrength+1e-9 ||
                    (MathAbs(z.strength_score-bestStrength)<=1e-9 && z.confirmed_time>bestRecent))));
      if(better){best=i;bestDist=d;bestStrength=z.strength_score;bestRecent=z.confirmed_time;}
     }
   return best;
  }

double Vegar_ZoneDistanceATRToBar(const SVegarZone &z,const MqlRates &bar,const double atr)
  {
   if(atr<=0.0) return 999.0;
   double d=0.0;
   if(bar.high<z.low) d=z.low-bar.high;
   else if(bar.low>z.high) d=bar.low-z.high;
   return d/atr;
  }

bool Vegar_ClosedBarApproachForRole(const SVegarZone &z,const MqlRates &bar,const ENUM_VEGAR_ZONE_ROLE role,double &distance_atr)
  {
   distance_atr=999.0;
   if(!z.valid || z.symbol!=_Symbol || z.role!=role) return false;
   if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) return false;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) return false;
   distance_atr=Vegar_ZoneDistanceATRToBar(z,bar,atr);
   return (distance_atr<=InpApproachDistanceATR);
  }

int Vegar_SelectTechnicalCandidateZoneForBar(const MqlRates &bar,double &distance_atr)
  {
   distance_atr=DBL_MAX;
   int best=-1; double bestStrength=-1.0; datetime bestRecent=0;
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      SVegarZone z=gVegarZones[i];
      if(!z.valid || !Vegar_ZoneContextValid(z) || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL) continue;
      if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
      if(z.strength_score<(double)InpForcaMinimaZona) continue;
      if(z.operational_bias==VEGAR_BIAS_BUYER && z.mid>bar.close) continue;
      if(z.operational_bias==VEGAR_BIAS_SELLER && z.mid<bar.close) continue;
      double d=999.0; if(!Vegar_ClosedBarApproachForRole(z,bar,VEGAR_ZONE_ROLE_OPERATIONAL,d)) continue;
      bool better=(d<distance_atr-1e-12 || (MathAbs(d-distance_atr)<=1e-12 &&
                   (z.strength_score>bestStrength+1e-9 ||
                    (MathAbs(z.strength_score-bestStrength)<=1e-9 && z.confirmed_time>bestRecent))));
      if(better){best=i;distance_atr=d;bestStrength=z.strength_score;bestRecent=z.confirmed_time;}
     }
   return best;
  }

int Vegar_SelectObservationCandidateZone(const MqlRates &bar,double &distance_atr)
  {
   distance_atr=DBL_MAX;
   int best=-1; double bestStrength=-1.0; datetime bestRecent=0;
   for(int i=0;i<ArraySize(gVegarObservationZones);i++)
     {
      SVegarZone z=gVegarObservationZones[i];
      if(!z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OBSERVATION) continue;
      if(z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
      double d=999.0; if(!Vegar_ClosedBarApproachForRole(z,bar,VEGAR_ZONE_ROLE_OBSERVATION,d)) continue;
      bool better=(d<distance_atr-1e-12 || (MathAbs(d-distance_atr)<=1e-12 &&
                   (z.strength_score>bestStrength+1e-9 ||
                    (MathAbs(z.strength_score-bestStrength)<=1e-9 && z.confirmed_time>bestRecent))));
      if(better){best=i;distance_atr=d;bestStrength=z.strength_score;bestRecent=z.confirmed_time;}
     }
   return best;
  }

bool Vegar_IsWithinApproach(const SVegarZone &z,double &distance_atr)
  {
   distance_atr=999.0;
   if(!Vegar_ZoneContextValid(z) || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL || z.state==VEGAR_ZONE_SWEPT) return false;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0 || !Vegar_UpdateTick()) return false;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5;
   double d=0.0; if(p<z.low) d=z.low-p; else if(p>z.high) d=p-z.high;
   distance_atr=d/atr;
   return (d<=InpApproachDistanceATR*atr);
  }

bool Vegar_ClosedBarObservedApproach(const SVegarZone &z,const MqlRates &bar,double &distance_atr)
  {
   distance_atr=999.0;
   if(!Vegar_ZoneContextValid(z) || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL || z.state==VEGAR_ZONE_SWEPT) return false;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) return false;
   double d=0.0;
   if(bar.high<z.low) d=z.low-bar.high;
   else if(bar.low>z.high) d=bar.low-z.high;
   else d=0.0;
   distance_atr=d/atr;
   return (d<=InpApproachDistanceATR*atr);
  }

bool Vegar_FindOppositeLiquidity(const ENUM_VEGAR_BIAS direction,const double from_price,double &price,string &zone_id,double &strength)
  {
   price=0.0; zone_id=""; strength=0.0; double best=DBL_MAX;
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      SVegarZone z=gVegarZones[i];
      if(!z.valid || !Vegar_ZoneContextValid(z) || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT || z.strength_score<(double)InpForcaMinimaZona) continue;
      if(direction==VEGAR_BIAS_BUYER && z.operational_bias==VEGAR_BIAS_SELLER && z.mid>from_price)
        { double d=z.mid-from_price; if(d<best) { best=d; price=z.mid; zone_id=z.id; strength=z.strength_score; } }
      if(direction==VEGAR_BIAS_SELLER && z.operational_bias==VEGAR_BIAS_BUYER && z.mid<from_price)
        { double d=from_price-z.mid; if(d<best) { best=d; price=z.mid; zone_id=z.id; strength=z.strength_score; } }
     }
   return (price>0.0);
  }

#endif
