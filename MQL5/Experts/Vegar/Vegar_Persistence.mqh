#ifndef __VEGAR_PERSISTENCE_MQH__
#define __VEGAR_PERSISTENCE_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Profit.mqh"
#include "Vegar_Csv.mqh"

string gVegarLeaseKey="";
string gVegarLeaseFileName="";
int gVegarLeaseFileHandle=INVALID_HANDLE;
bool gVegarLeaseOwned=false;

bool gVegarRecoveryComplete=false;
bool gVegarOwnershipAmbiguous=false;
string gVegarRecoveryDetail="NOT_STARTED";

// Validated persistence identity cached during startup reconciliation.
bool   gVegarPersistenceValid=false;
long   gVegarPersistAccount=0;
string gVegarPersistServer="";
string gVegarPersistSymbol="";
long   gVegarPersistMagic=0;
long   gVegarPersistPositionID=0;
ulong  gVegarPersistPositionTicket=0;
string gVegarPersistPayloadHash="";

double gVegarPersistPeak=0.0;
double gVegarPersistProtected=0.0;
double gVegarPersistCommitted=0.0;
bool   gVegarPersistPeakKnown=false;
bool   gVegarPersistRunner=false;
datetime gVegarPersistLastRunnerUpdate=0;
string gVegarPersistTradeCycleID="";
string gVegarPersistIntentID="";
string gVegarPersistOpportunityID="";
string gVegarPersistSetupID="";
string gVegarPersistFocusZoneID="";
double gVegarPersistTechnicalStop=0.0;
double gVegarPersistTakeProfit=0.0;
bool   gVegarPersistProtectedFloorInstalled=false;
bool   gVegarPersistBrokerTPRemovedForRunner=false;

string Vegar_OwnershipRegistryFileName()
  {
   return "VEGAR_OWNERSHIP_"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"_"+Vegar_SanitizeFileToken(AccountInfoString(ACCOUNT_SERVER))+"_"+Vegar_SanitizeFileToken(_Symbol)+"_"+(string)InpMagicNumber+".csv";
  }

bool Vegar_LoadOwnershipRegistry()
  {
   Vegar_OwnershipResetRegistry();
   string f=Vegar_OwnershipRegistryFileName();
   if(!FileIsExist(f,FILE_COMMON)) return true;
   int h=FileOpen(f,FILE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON|FILE_SHARE_READ,',');
   if(h==INVALID_HANDLE) return false;
   while(!FileIsEnding(h))
     {
      string account=FileReadString(h); if(FileIsEnding(h) && account=="") break;
      string server=FileReadString(h),symbol=FileReadString(h),magic=FileReadString(h),pid=FileReadString(h),ts=FileReadString(h);
      if((long)StringToInteger(account)!=AccountInfoInteger(ACCOUNT_LOGIN)) continue;
      if(server!=AccountInfoString(ACCOUNT_SERVER) || symbol!=_Symbol || (long)StringToInteger(magic)!=InpMagicNumber) continue;
      long id=(long)StringToInteger(pid); if(id>0) Vegar_OwnershipRegisterPositionID(id);
     }
   FileClose(h); return true;
  }

bool Vegar_RegisterOwnedPositionIDPersistent(const long position_id)
  {
   if(position_id<=0) return false;
   bool already=Vegar_OwnershipHasPositionID(position_id);
   Vegar_OwnershipRegisterPositionID(position_id);
   if(already) return true;
   string f=Vegar_OwnershipRegistryFileName();
   int h=FileOpen(f,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON|FILE_SHARE_READ,',');
   if(h==INVALID_HANDLE) return false;
   FileSeek(h,0,SEEK_END);
   FileWrite(h,(string)AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER),_Symbol,(string)InpMagicNumber,(string)position_id,(string)(long)TimeTradeServer());
   FileFlush(h); FileClose(h); return true;
  }

string Vegar_StateFileName()
  {
   return "VEGAR_STATE_"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"_"+Vegar_SanitizeFileToken(AccountInfoString(ACCOUNT_SERVER))+"_"+Vegar_SanitizeFileToken(_Symbol)+"_"+(string)InpMagicNumber+".state";
  }

string Vegar_StateTempFileName() { return Vegar_StateFileName()+".tmp"; }

string Vegar_PersistenceLine(const string key,const string value) { return key+"="+value+"\n"; }

void Vegar_PositionRealizedLedger(const long position_id,double &realized,double &commission,double &swap,double &fees)
  {
   realized=commission=swap=fees=0.0; if(position_id<=0) return;
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent();
   if(!HistorySelect(0,now)) return;
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong d=HistoryDealGetTicket(i); if(d==0)continue;
      if((long)HistoryDealGetInteger(d,DEAL_POSITION_ID)!=position_id) continue;
      if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
      if((long)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagicNumber && !Vegar_OwnershipHasPositionID(position_id)) continue;
      realized+=HistoryDealGetDouble(d,DEAL_PROFIT);
      commission+=HistoryDealGetDouble(d,DEAL_COMMISSION);
      swap+=HistoryDealGetDouble(d,DEAL_SWAP);
      fees+=HistoryDealGetDouble(d,DEAL_FEE);
     }
  }

string Vegar_BuildPersistencePayload()
  {
   double realized=0,commission=0,swap=0,fees=0; Vegar_PositionRealizedLedger(gVegarProfit.position_id,realized,commission,swap,fees);
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent(); datetime utc=Vegar_ServerToUTC(now);
   datetime entryTime=0; double tp=0.0;
   if(gVegarProfit.position_ticket>0 && PositionSelectByTicket(gVegarProfit.position_ticket)) { entryTime=(datetime)PositionGetInteger(POSITION_TIME); tp=PositionGetDouble(POSITION_TP); }
   string p="";
   p+=Vegar_PersistenceLine("PersistenceSchemaVersion",(string)VEGAR_PERSISTENCE_SCHEMA);
   p+=Vegar_PersistenceLine("EAVersion",VEGAR_EA_VERSION);
   p+=Vegar_PersistenceLine("BuildID",VEGAR_BUILD_ID);
   p+=Vegar_PersistenceLine("Account",(string)AccountInfoInteger(ACCOUNT_LOGIN));
   p+=Vegar_PersistenceLine("Server",AccountInfoString(ACCOUNT_SERVER));
   p+=Vegar_PersistenceLine("Symbol",_Symbol);
   p+=Vegar_PersistenceLine("Magic",(string)InpMagicNumber);
   p+=Vegar_PersistenceLine("PositionTicket",(string)gVegarProfit.position_ticket);
   p+=Vegar_PersistenceLine("PositionID",(string)gVegarProfit.position_id);
   p+=Vegar_PersistenceLine("Direction",(string)(int)gVegarProfit.direction);
   p+=Vegar_PersistenceLine("Entry",DoubleToString(gVegarProfit.entry_price,Vegar_TelemetryPricePrecision()));
   p+=Vegar_PersistenceLine("Volume",DoubleToString(gVegarProfit.volume,8));
   p+=Vegar_PersistenceLine("TradeCycleID",gVegarProfit.trade_cycle_id);
   p+=Vegar_PersistenceLine("IntentID",gVegarProfit.intent_id);
   p+=Vegar_PersistenceLine("OpportunityID",gVegarProfit.opportunity_id);
   p+=Vegar_PersistenceLine("SetupID",gVegarProfit.setup_id);
   p+=Vegar_PersistenceLine("TechnicalStop",DoubleToString(gVegarProfit.technical_stop,Vegar_TelemetryPricePrecision()));
   p+=Vegar_PersistenceLine("TakeProfit",DoubleToString(tp,Vegar_TelemetryPricePrecision()));
   p+=Vegar_PersistenceLine("PeakKnown",gVegarProfit.peak_known?"1":"0");
   p+=Vegar_PersistenceLine("PeakProfitMoney",DoubleToString(gVegarProfit.peak_profit_money,8));
   p+=Vegar_PersistenceLine("ProtectedProfitMoney",DoubleToString(gVegarProfit.protected_profit_money,8));
   p+=Vegar_PersistenceLine("LastCommittedPeak",DoubleToString(gVegarProfit.last_committed_peak,8));
   p+=Vegar_PersistenceLine("RunnerActive",gVegarProfit.runner_active?"1":"0");
   p+=Vegar_PersistenceLine("LastRunnerUpdate",(string)(long)gVegarProfit.last_runner_update);
   p+=Vegar_PersistenceLine("ProtectedFloorInstalled",gVegarProfit.protected_floor_installed?"1":"0");
   p+=Vegar_PersistenceLine("BrokerTPRemovedForRunner",gVegarProfit.broker_tp_removed_for_runner?"1":"0");
   p+=Vegar_PersistenceLine("EntryTime",(string)(long)entryTime);
   p+=Vegar_PersistenceLine("ExecutionTF",(string)(int)Vegar_ExecutionTF());
   p+=Vegar_PersistenceLine("FocusZoneID",gVegarProfit.focus_zone_id);
   p+=Vegar_PersistenceLine("RealizedProfit",DoubleToString(realized,8));
   p+=Vegar_PersistenceLine("Commission",DoubleToString(commission,8));
   p+=Vegar_PersistenceLine("Swap",DoubleToString(swap,8));
   p+=Vegar_PersistenceLine("Fees",DoubleToString(fees,8));
   p+=Vegar_PersistenceLine("ManagementState",gVegarProfit.active?"ACTIVE":"INACTIVE");
   p+=Vegar_PersistenceLine("TimestampUTC",Vegar_TimeIso(utc));
   return p;
  }

bool Vegar_ReadPersistenceFile(const string f,string &payload,string &stored_hash)
  {
   payload=""; stored_hash="";
   if(!FileIsExist(f,FILE_COMMON)) return false;
   int h=FileOpen(f,FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON|FILE_SHARE_READ);
   if(h==INVALID_HANDLE) return false;
   while(!FileIsEnding(h))
     {
      string line=FileReadString(h); if(line=="") continue;
      int e=StringFind(line,"="); if(e<=0) continue;
      string key=StringSubstr(line,0,e),value=StringSubstr(line,e+1);
      if(key=="PayloadHash") stored_hash=value;
      else payload+=Vegar_PersistenceLine(key,value);
     }
   FileClose(h);
   return (payload!="" && stored_hash!="");
  }

bool Vegar_ValidatePersistenceFile(const string f)
  {
   string payload="",stored=""; if(!Vegar_ReadPersistenceFile(f,payload,stored)) return false;
   return (Vegar_ComputeHash(payload)==stored);
  }

bool Vegar_SaveOperationalState()
  {
   if(!gVegarProfit.active || gVegarProfit.position_id<=0)
     { return true; }
   string payload=Vegar_BuildPersistencePayload();
   string hash=Vegar_ComputeHash(payload);
   string tmp=Vegar_StateTempFileName(),dst=Vegar_StateFileName();
   int h=FileOpen(tmp,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON);
   if(h==INVALID_HANDLE) { Vegar_WriteDiagnostic("PERSISTENCE_WRITE","FAIL","OPEN_TMP","",(string)GetLastError()); return false; }
   FileWriteString(h,payload);
   FileWriteString(h,Vegar_PersistenceLine("PayloadHash",hash));
   FileFlush(h); FileClose(h);
   if(!Vegar_ValidatePersistenceFile(tmp))
     { FileDelete(tmp,FILE_COMMON); Vegar_WriteDiagnostic("PERSISTENCE_CHECKSUM","FAIL","CHECKSUM_INVALID","","Temporary persistence validation failed"); return false; }
   ResetLastError();
   if(!FileMove(tmp,FILE_COMMON,dst,FILE_COMMON|FILE_REWRITE))
     { Vegar_WriteDiagnostic("PERSISTENCE_ATOMIC_MOVE","FAIL","FILE_MOVE_FAILED","",(string)GetLastError()); return false; }
   gVegarPersistenceValid=true; gVegarPersistPayloadHash=hash;
   return true;
  }

void Vegar_ClearOperationalState()
  {
   string f=Vegar_StateFileName(),tmp=Vegar_StateTempFileName();
   if(FileIsExist(tmp,FILE_COMMON)) FileDelete(tmp,FILE_COMMON);
   if(FileIsExist(f,FILE_COMMON)) FileDelete(f,FILE_COMMON);
   gVegarPersistenceValid=false;
  }

string Vegar_PersistGet(const string payload,const string key)
  {
   string tag=key+"="; int p=StringFind(payload,tag); if(p<0) return "";
   p+=StringLen(tag); int e=StringFind(payload,"\n",p); if(e<0)e=StringLen(payload);
   return StringSubstr(payload,p,e-p);
  }

bool Vegar_LoadPersistenceCache()
  {
   gVegarPersistenceValid=false;
   string payload="",stored=""; if(!Vegar_ReadPersistenceFile(Vegar_StateFileName(),payload,stored)) return false;
   if(Vegar_ComputeHash(payload)!=stored) return false;
   if((int)StringToInteger(Vegar_PersistGet(payload,"PersistenceSchemaVersion"))!=VEGAR_PERSISTENCE_SCHEMA) return false;
   gVegarPersistAccount=(long)StringToInteger(Vegar_PersistGet(payload,"Account"));
   gVegarPersistServer=Vegar_PersistGet(payload,"Server"); gVegarPersistSymbol=Vegar_PersistGet(payload,"Symbol"); gVegarPersistMagic=(long)StringToInteger(Vegar_PersistGet(payload,"Magic"));
   gVegarPersistPositionTicket=(ulong)StringToInteger(Vegar_PersistGet(payload,"PositionTicket")); gVegarPersistPositionID=(long)StringToInteger(Vegar_PersistGet(payload,"PositionID"));
   gVegarPersistPeakKnown=(StringToInteger(Vegar_PersistGet(payload,"PeakKnown"))!=0); gVegarPersistPeak=StringToDouble(Vegar_PersistGet(payload,"PeakProfitMoney")); gVegarPersistProtected=StringToDouble(Vegar_PersistGet(payload,"ProtectedProfitMoney")); gVegarPersistCommitted=StringToDouble(Vegar_PersistGet(payload,"LastCommittedPeak"));
   gVegarPersistRunner=(StringToInteger(Vegar_PersistGet(payload,"RunnerActive"))!=0); gVegarPersistLastRunnerUpdate=(datetime)StringToInteger(Vegar_PersistGet(payload,"LastRunnerUpdate"));
   gVegarPersistProtectedFloorInstalled=(StringToInteger(Vegar_PersistGet(payload,"ProtectedFloorInstalled"))!=0);
   gVegarPersistBrokerTPRemovedForRunner=(StringToInteger(Vegar_PersistGet(payload,"BrokerTPRemovedForRunner"))!=0);
   gVegarPersistTradeCycleID=Vegar_PersistGet(payload,"TradeCycleID"); gVegarPersistIntentID=Vegar_PersistGet(payload,"IntentID"); gVegarPersistOpportunityID=Vegar_PersistGet(payload,"OpportunityID"); gVegarPersistSetupID=Vegar_PersistGet(payload,"SetupID"); gVegarPersistFocusZoneID=Vegar_PersistGet(payload,"FocusZoneID");
   gVegarPersistTechnicalStop=StringToDouble(Vegar_PersistGet(payload,"TechnicalStop")); gVegarPersistTakeProfit=StringToDouble(Vegar_PersistGet(payload,"TakeProfit")); gVegarPersistPayloadHash=stored;
   gVegarPersistenceValid=(gVegarPersistAccount==AccountInfoInteger(ACCOUNT_LOGIN) && gVegarPersistServer==AccountInfoString(ACCOUNT_SERVER) && gVegarPersistSymbol==_Symbol && gVegarPersistMagic==InpMagicNumber && gVegarPersistPositionID>0);
   return gVegarPersistenceValid;
  }

bool Vegar_HistoryProvesPosition(const long position_id)
  {
   if(position_id<=0) return false;
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent(); if(!HistorySelect(0,now)) return false;
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong d=HistoryDealGetTicket(i); if(d==0)continue;
      if((long)HistoryDealGetInteger(d,DEAL_POSITION_ID)!=position_id) continue;
      if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
      if((long)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagicNumber) continue;
      string c=HistoryDealGetString(d,DEAL_COMMENT);
      ENUM_DEAL_ENTRY e=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(d,DEAL_ENTRY);
      if(e==DEAL_ENTRY_IN && StringFind(c,VEGAR_COMMENT_PREFIX)==0) return true;
     }
   return false;
  }


ENUM_VEGAR_OWNERSHIP_STATE Vegar_ResolveOwnershipEvidence(const bool magic_match,const bool comment_match,const bool registry_match,const bool persistence_match,const bool history_match)
  {
   if(!magic_match) return VEGAR_OWNERSHIP_NOT_VEGAR;
   if(comment_match || registry_match || persistence_match || history_match) return VEGAR_OWNERSHIP_CONFIRMED;
   return VEGAR_OWNERSHIP_AMBIGUOUS;
  }

ENUM_VEGAR_OWNERSHIP_STATE Vegar_SelectedPositionOwnershipState()
  {
   if(PositionGetString(POSITION_SYMBOL)!=_Symbol) return VEGAR_OWNERSHIP_NOT_VEGAR;
   long magic=(long)PositionGetInteger(POSITION_MAGIC),pid=(long)PositionGetInteger(POSITION_IDENTIFIER);
   string c=PositionGetString(POSITION_COMMENT);
   return Vegar_ResolveOwnershipEvidence(magic==InpMagicNumber,
                                         StringFind(c,VEGAR_COMMENT_PREFIX)==0,
                                         Vegar_OwnershipHasPositionID(pid),
                                         (gVegarPersistenceValid && gVegarPersistPositionID==pid),
                                         Vegar_HistoryProvesPosition(pid));
  }

bool Vegar_IsCurrentSelectedPositionOwned()
  {
   ENUM_VEGAR_OWNERSHIP_STATE st=Vegar_SelectedPositionOwnershipState();
   if(st==VEGAR_OWNERSHIP_CONFIRMED)
     {
      long pid=(long)PositionGetInteger(POSITION_IDENTIFIER); if(pid>0) Vegar_RegisterOwnedPositionIDPersistent(pid);
      return true;
     }
   if(st==VEGAR_OWNERSHIP_AMBIGUOUS) gVegarOwnershipAmbiguous=true;
   return false;
  }

bool Vegar_FindOwnedPosition(ulong &ticket,long &position_id,ENUM_VEGAR_BIAS &direction,double &entry,double &volume)
  {
   ticket=0; position_id=0; direction=VEGAR_BIAS_NONE; entry=0.0; volume=0.0;
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong t=PositionGetTicket(i); if(t==0 || !PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(!Vegar_IsCurrentSelectedPositionOwned()) continue;
      ticket=t; position_id=(long)PositionGetInteger(POSITION_IDENTIFIER);
      ENUM_POSITION_TYPE pt=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); direction=(pt==POSITION_TYPE_BUY?VEGAR_BIAS_BUYER:VEGAR_BIAS_SELLER);
      entry=PositionGetDouble(POSITION_PRICE_OPEN); volume=PositionGetDouble(POSITION_VOLUME); return true;
     }
   return false;
  }

bool Vegar_HasOwnedPosition(){ulong t;long id;ENUM_VEGAR_BIAS d;double e,v;return Vegar_FindOwnedPosition(t,id,d,e,v);}

bool Vegar_HasAmbiguousVegarPosition()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong t=PositionGetTicket(i); if(t==0 || !PositionSelectByTicket(t))continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol)continue;
      if((long)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber)continue;
      if(Vegar_SelectedPositionOwnershipState()==VEGAR_OWNERSHIP_AMBIGUOUS)return true;
     }
   return false;
  }

bool Vegar_HasExternalPositionOnSymbol()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong t=PositionGetTicket(i); if(t==0 || !PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(Vegar_SelectedPositionOwnershipState()!=VEGAR_OWNERSHIP_CONFIRMED) return true;
     }
   return false;
  }

bool Vegar_IsChartOpen(const long chart_id)
  {
   long c=ChartFirst(); while(c>=0){if(c==chart_id)return true;c=ChartNext(c);} return false;
  }

bool Vegar_AcquireInstanceLease()
  {
   string identity=(string)AccountInfoInteger(ACCOUNT_LOGIN)+"|"+AccountInfoString(ACCOUNT_SERVER)+"|"+_Symbol+"|"+(string)InpMagicNumber;
   string hash=Vegar_Fnv1a64Hex(identity); gVegarLeaseKey="VEGAR_LEASE_"+hash; gVegarLeaseFileName="VEGAR_INSTANCE_"+hash+".lock";
   if(!GlobalVariableCheck(gVegarLeaseKey)) GlobalVariableSet(gVegarLeaseKey,0.0);
   double existing=GlobalVariableGet(gVegarLeaseKey); long myChart=ChartID();
   if(existing!=0.0 && (long)existing!=myChart){if(Vegar_IsChartOpen((long)existing))return false;GlobalVariableSet(gVegarLeaseKey,0.0);}
   if(!GlobalVariableSetOnCondition(gVegarLeaseKey,(double)myChart,0.0)){existing=GlobalVariableGet(gVegarLeaseKey);if((long)existing!=myChart)return false;}
   ResetLastError(); gVegarLeaseFileHandle=FileOpen(gVegarLeaseFileName,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(gVegarLeaseFileHandle==INVALID_HANDLE){if(GlobalVariableCheck(gVegarLeaseKey)&&(long)GlobalVariableGet(gVegarLeaseKey)==myChart)GlobalVariableSet(gVegarLeaseKey,0.0);return false;}
   string stamp=gVegarInstanceID+"|"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"|"+AccountInfoString(ACCOUNT_SERVER)+"|"+_Symbol+"|"+(string)InpMagicNumber;
   uchar bytes[]; StringToCharArray(stamp,bytes,0,WHOLE_ARRAY,CP_UTF8); FileSeek(gVegarLeaseFileHandle,0,SEEK_SET); FileWriteArray(gVegarLeaseFileHandle,bytes,0,ArraySize(bytes)); FileFlush(gVegarLeaseFileHandle);
   gVegarLeaseOwned=true; return true;
  }

void Vegar_ReleaseInstanceLease()
  {
   if(gVegarLeaseFileHandle!=INVALID_HANDLE){FileClose(gVegarLeaseFileHandle);gVegarLeaseFileHandle=INVALID_HANDLE;if(gVegarLeaseFileName!="")FileDelete(gVegarLeaseFileName,FILE_COMMON);}
   if(gVegarLeaseKey!=""&&GlobalVariableCheck(gVegarLeaseKey)&&(long)GlobalVariableGet(gVegarLeaseKey)==ChartID())GlobalVariableSet(gVegarLeaseKey,0.0);
   gVegarLeaseOwned=false;
  }

bool Vegar_RecoveryAllowsTrading()
  {
   return (gVegarRecoveryComplete && !gVegarOwnershipAmbiguous);
  }

bool Vegar_ReconcileOperationalState()
  {
   gVegarRecoveryComplete=false; gVegarOwnershipAmbiguous=false; gVegarRecoveryDetail="RECONCILING";
   Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_RECOVERY,BLOCKED_RECOVERY,"STARTUP_RECONCILIATION");
   if(!Vegar_LoadOwnershipRegistry()) Vegar_WriteDiagnostic("RECOVERY","WARN","OWNERSHIP_REGISTRY_READ_FAILED","","");
   bool persistence_ok=Vegar_LoadPersistenceCache();
   if(FileIsExist(Vegar_StateFileName(),FILE_COMMON) && !persistence_ok)
      Vegar_WriteDiagnostic("PERSISTENCE_CHECKSUM","FAIL","INVALID_OR_INCOMPATIBLE","","Persistence ignored; broker state will not be weakened");

   ulong ticket=0; long pid=0; ENUM_VEGAR_BIAS dir=VEGAR_BIAS_NONE; double entry=0.0,vol=0.0;
   bool confirmed=Vegar_FindOwnedPosition(ticket,pid,dir,entry,vol);
   if(Vegar_HasAmbiguousVegarPosition())
     {
      gVegarOwnershipAmbiguous=true; gVegarRecoveryComplete=true; gVegarRecoveryDetail="OWNERSHIP_AMBIGUOUS";
      Vegar_SetExecutionState(VEGAR_EXECUTION_BLOCKED_OWNERSHIP,BLOCKED_OWNERSHIP_AMBIGUOUS,"POSITION_EVIDENCE_INSUFFICIENT");
      Vegar_WriteDiagnostic("OWNERSHIP_RECONCILIATION","BLOCKED",Vegar_ReasonText(BLOCKED_OWNERSHIP_AMBIGUOUS),"","No destructive management allowed; new exposure blocked");
      return true;
     }

   if(!confirmed)
     {
      if(persistence_ok) { Vegar_WriteDiagnostic("SETUP_ABORTED_BY_REINIT","FLAT",Vegar_ReasonText(SETUP_ABORTED_BY_REINIT),"","Valid persistence had no confirmed open position; state cleared"); Vegar_ClearOperationalState(); }
      Vegar_ResetProfitState(); gVegarRecoveryComplete=true; gVegarRecoveryDetail="FLAT_RECONCILED";
      Vegar_WriteDiagnostic("RECOVERY_COMPLETE","FLAT","NONE","","Positions/orders/deals/history/persistence reconciled");
      return true;
     }

   Vegar_RegisterOwnedPositionIDPersistent(pid);
   Vegar_ProfitAttach(ticket,pid,dir,entry,vol);
   if(PositionSelectByTicket(ticket)) gVegarProfit.last_server_sl=PositionGetDouble(POSITION_SL);
   if(persistence_ok && gVegarPersistPositionID==pid)
     {
      gVegarProfit.peak_known=gVegarPersistPeakKnown; gVegarProfit.peak_profit_money=gVegarPersistPeak; gVegarProfit.protected_profit_money=gVegarPersistProtected; gVegarProfit.last_committed_peak=gVegarPersistCommitted;
      gVegarProfit.runner_active=gVegarPersistRunner; gVegarProfit.last_runner_update=gVegarPersistLastRunnerUpdate; gVegarProfit.trade_cycle_id=gVegarPersistTradeCycleID; gVegarProfit.intent_id=gVegarPersistIntentID; gVegarProfit.opportunity_id=gVegarPersistOpportunityID; gVegarProfit.setup_id=gVegarPersistSetupID; gVegarProfit.focus_zone_id=gVegarPersistFocusZoneID;
      gVegarProfit.technical_stop=gVegarPersistTechnicalStop; gVegarProfit.take_profit=gVegarPersistTakeProfit;
      gVegarProfit.protected_floor_installed=gVegarPersistProtectedFloorInstalled;
      gVegarProfit.broker_tp_removed_for_runner=gVegarPersistBrokerTPRemovedForRunner;
      Vegar_WriteDiagnostic("RECOVERY_STATE_RESTORED","ACTIVE","NONE","","Atomic persistence checksum valid");
     }
   else
     {
      // No historical peak is invented from current floating P/L.
      gVegarProfit.peak_known=false; gVegarProfit.peak_profit_money=0.0; gVegarProfit.last_committed_peak=0.0; gVegarProfit.runner_active=false; gVegarProfit.last_runner_update=0;
      if(PositionSelectByTicket(ticket))
        {
         double sl=PositionGetDouble(POSITION_SL); gVegarProfit.last_server_sl=sl;
         if(sl>0.0)
           {
            double protectedPnl=0.0; if(Vegar_CalcMoneyFromPrice(dir,vol,entry,sl,protectedPnl) && protectedPnl>0.0) gVegarProfit.protected_profit_money=protectedPnl;
           }
        }
      Vegar_WriteDiagnostic("RECOVERY_PROTECTION_UNCERTAIN","ACTIVE",Vegar_ReasonText(RECOVERY_PROTECTION_UNCERTAIN),"","PeakKnown=false; existing broker-side SL preserved and never loosened");
     }
   gVegarRecoveryComplete=true; gVegarRecoveryDetail="OWNED_POSITION_RECONCILED";
   Vegar_SaveOperationalState();
   Vegar_WriteDiagnostic("RECOVERY_COMPLETE","ACTIVE","NONE","","Ownership confirmed and management state reconciled");
   return true;
  }

// Backward-compatible RC5 entry point now delegates to the complete RC8 reconciliation.
bool Vegar_LoadOperationalState(){ return Vegar_ReconcileOperationalState(); }
void Vegar_PrimeOwnershipFromOperationalState(){ Vegar_LoadPersistenceCache(); if(gVegarPersistenceValid) Vegar_OwnershipRegisterPositionID(gVegarPersistPositionID); }

#endif
