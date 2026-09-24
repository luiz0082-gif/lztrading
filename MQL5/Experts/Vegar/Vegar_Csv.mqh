#ifndef __VEGAR_CSV_MQH__
#define __VEGAR_CSV_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"
#include "Vegar_Time.mqh"

SVegarRuntimeStats gVegarStats;
ulong gVegarIdCounter=0;
string gVegarCsvLastError="";

// OBJECT_STATE is append-only, but Schema 2100 records only state changes (or an
// explicitly marked low-rate heartbeat).  This eliminates the RC5 snapshot flood.
string   gVegarObjectCacheIDs[];
string   gVegarObjectCacheHashes[];
datetime gVegarObjectCacheLastWrite[];

int Vegar_TelemetryPricePrecision()
  {
   int p=gVegarSymbol.digits+4;
   if(p<6) p=6;
   if(p>12) p=12;
   return p;
  }

string Vegar_ShortHash(const string value)
  {
   string h=value;
   int p=StringFind(h,"-"); if(p>=0) h=StringSubstr(h,p+1);
   if(StringLen(h)>8) h=StringSubstr(h,0,8);
   return h;
  }

string Vegar_ShortConfigHash() { return Vegar_ShortHash(gVegarStrategyConfigHash!=""?gVegarStrategyConfigHash:gVegarConfigHash); }

string Vegar_DateCompact(const datetime t)
  {
   MqlDateTime d; TimeToStruct(t,d);
   return StringFormat("%04d%02d%02d",d.year,d.mon,d.day);
  }

string Vegar_TimeCompactUTC()
  {
   datetime t=TimeGMT(); if(t<=0) t=TimeCurrent();
   MqlDateTime d; TimeToStruct(t,d);
   return StringFormat("%04d%02d%02dT%02d%02d%02dZ",d.year,d.mon,d.day,d.hour,d.min,d.sec);
  }

string Vegar_MakeRunID()
  {
   return Vegar_TimeCompactUTC()+"_"+Vegar_Fnv1a64Hex((string)AccountInfoInteger(ACCOUNT_LOGIN)+"|"+AccountInfoString(ACCOUNT_SERVER)+"|"+_Symbol+"|"+(string)ChartID()+"|"+(string)GetMicrosecondCount());
  }

string Vegar_MakeInstanceID()
  {
   return "I_"+Vegar_Fnv1a64Hex((string)AccountInfoInteger(ACCOUNT_LOGIN)+"|"+AccountInfoString(ACCOUNT_SERVER)+"|"+_Symbol+"|"+(string)InpMagicNumber+"|"+(string)ChartID()+"|"+(string)GetMicrosecondCount());
  }

string Vegar_NextID(const string prefix)
  {
   gVegarIdCounter++;
   return prefix+"_"+Vegar_TimeCompactUTC()+"_"+(string)gVegarIdCounter;
  }

string Vegar_CsvEscape(string v)
  {
   StringReplace(v,"\"","\"\"");
   return "\""+v+"\"";
  }

void Vegar_GetTelemetryTimes(datetime &server,datetime &utc,long &server_msc,long &utc_msc,long &tick_msc)
  {
   server=TimeTradeServer(); if(server<=0) server=TimeCurrent();
   utc=Vegar_ServerToUTC(server);
   tick_msc=(gVegarTick.time_msc>0 ? gVegarTick.time_msc : 0);
   server_msc=(long)server*1000;
   if(tick_msc>0)
     {
      long tick_sec=tick_msc/1000;
      // MqlTick.time_msc is preserved as raw TickTimeMsc.  It is used as server
      // milliseconds only when it is temporally consistent with the server clock.
      if(MathAbs((double)tick_sec-(double)server)<=5.0) server_msc=tick_msc;
     }
   long offset_sec=(long)server-(long)utc;
   utc_msc=server_msc-offset_sec*1000;
  }

string Vegar_CommonPrefixForContext(const string event_id,const string opportunity_id,const string snapshot_id,const string setup_id,const string signal_id,const string intent_id,
                                    const string event_name,const string state,const string primary,const string secondary,
                                    const string symbol,const ENUM_TIMEFRAMES execution_tf,const long magic,const string run_id,const string instance_id)
  {
   datetime server=0,utc=0; long server_msc=0,utc_msc=0,tick_msc=0;
   Vegar_GetTelemetryTimes(server,utc,server_msc,utc_msc,tick_msc);
   string accountMode=EnumToString((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE));
   string broker=AccountInfoString(ACCOUNT_COMPANY);
   string s="";
   s += (string)VEGAR_SCHEMA_VERSION+","+Vegar_CsvEscape(VEGAR_EA_VERSION)+","+Vegar_CsvEscape(VEGAR_BUILD_ID)+",";
   s += Vegar_CsvEscape(run_id)+","+Vegar_CsvEscape(instance_id)+","+Vegar_CsvEscape(gVegarConfigHash)+","+Vegar_CsvEscape(gVegarStrategyConfigHash)+","+Vegar_CsvEscape(gVegarTelemetryConfigHash)+","+Vegar_CsvEscape(gVegarVisualConfigHash)+",";
   s += (string)(++gVegarStats.sequence)+","+Vegar_CsvEscape(event_id)+",";
   s += Vegar_CsvEscape(TimeToString(utc,TIME_DATE|TIME_SECONDS))+","+(string)utc_msc+","+Vegar_CsvEscape(TimeToString(server,TIME_DATE|TIME_SECONDS))+","+(string)server_msc+","+(string)tick_msc+",";
   s += Vegar_CsvEscape(broker)+","+Vegar_CsvEscape(accountMode)+","+(string)AccountInfoInteger(ACCOUNT_LOGIN)+","+Vegar_CsvEscape(AccountInfoString(ACCOUNT_SERVER))+",";
   s += Vegar_CsvEscape(symbol)+","+Vegar_CsvEscape(Vegar_TFText(execution_tf))+","+(string)magic+",";
   s += Vegar_CsvEscape(opportunity_id)+","+Vegar_CsvEscape(snapshot_id)+","+Vegar_CsvEscape(setup_id)+","+Vegar_CsvEscape(signal_id)+","+Vegar_CsvEscape(intent_id)+",";
   s += Vegar_CsvEscape(event_name)+","+Vegar_CsvEscape(state)+","+Vegar_CsvEscape(primary)+","+Vegar_CsvEscape(secondary);
   return s;
  }

string Vegar_CommonPrefix(const string event_id,const string opportunity_id,const string snapshot_id,const string setup_id,const string signal_id,const string intent_id,
                          const string event_name,const string state,const string primary,const string secondary)
  {
   return Vegar_CommonPrefixForContext(event_id,opportunity_id,snapshot_id,setup_id,signal_id,intent_id,event_name,state,primary,secondary,
                                       _Symbol,Vegar_ExecutionTF(),InpMagicNumber,gVegarRunID,gVegarInstanceID);
  }

string Vegar_CommonHeader()
  {
   return "SchemaVersion,EAVersion,BuildID,RunID,InstanceID,ConfigHash,StrategyConfigHash,TelemetryConfigHash,VisualConfigHash,SequenceNumber,EventID,TimestampUTC,TimestampUTC_Msc,TimestampServer,TimestampServer_Msc,TickTimeMsc,Broker,AccountMode,Account,Server,Symbol,ExecutionTF,MagicNumber,OpportunityID,SnapshotID,SetupID,SignalID,IntentID,Event,State,PrimaryReason,SecondaryReason";
  }

string Vegar_CsvPathForContext(const string family,const int part,const string symbol,const ENUM_TIMEFRAMES tf,const string strategy_hash)
  {
   datetime t=TimeTradeServer(); if(t<=0) t=TimeCurrent();
   string base="VEGAR\\VEGAR_"+family+"_S"+(string)VEGAR_SCHEMA_VERSION+"_"+Vegar_DateCompact(t)+"_"+Vegar_SanitizeFileToken(symbol)+"_"+Vegar_TFText(tf)+"_"+Vegar_ShortHash(strategy_hash);
   return base+StringFormat("_PART%03d.csv",part);
  }

string Vegar_CsvPath(const string family,const int part)
  {
   return Vegar_CsvPathForContext(family,part,_Symbol,Vegar_ExecutionTF(),gVegarStrategyConfigHash!=""?gVegarStrategyConfigHash:gVegarConfigHash);
  }

bool Vegar_CsvHeaderMatches(const string path,const string expected_header)
  {
   if(!FileIsExist(path)) return true;
   int h=FileOpen(path,FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(h==INVALID_HANDLE) return false;
   string actual="";
   if(!FileIsEnding(h)) actual=FileReadString(h);
   FileClose(h);
   return (actual==expected_header);
  }

bool Vegar_CsvAppendContext(const string family,const string header,const string row,const string symbol,const ENUM_TIMEFRAMES tf,const string strategy_hash)
  {
   if(!InpAtivarCSV) return true;
   FolderCreate("VEGAR");
   long maxBytes=(long)InpTamanhoMaxArquivoMB*1024*1024;
   int part=1; string path=""; long size=0;
   for(;part<10000;part++)
     {
      path=Vegar_CsvPathForContext(family,part,symbol,tf,strategy_hash);
      if(!FileIsExist(path)) { size=0; break; }
      if(!Vegar_CsvHeaderMatches(path,header))
        {
         // Do not contaminate an existing dataset with an incompatible schema/header.
         gVegarCsvLastError="CSV_SCHEMA_HEADER_MISMATCH:"+path;
         gVegarStats.csv_errors++;
         PrintFormat("[VEGAR][CSV_SCHEMA_HEADER_MISMATCH] %s",path);
         continue;
        }
      int probe=FileOpen(path,FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
      if(probe==INVALID_HANDLE) continue;
      size=(long)FileSize(probe); FileClose(probe);
      if(size<maxBytes) break;
     }
   if(part>=10000) { gVegarCsvLastError="CSV_ROTATION_EXHAUSTED"; gVegarStats.csv_errors++; return false; }
   int h=FileOpen(path,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(h==INVALID_HANDLE)
     { gVegarCsvLastError="FILE_OPEN_ERROR="+(string)GetLastError(); gVegarStats.csv_errors++; return false; }
   bool empty=(FileSize(h)==0);
   FileSeek(h,0,SEEK_END);
   if(empty) FileWriteString(h,header+"\r\n");
   FileWriteString(h,row+"\r\n");
   FileFlush(h); FileClose(h);
   return true;
  }

bool Vegar_CsvAppend(const string family,const string header,const string row)
  {
   return Vegar_CsvAppendContext(family,header,row,_Symbol,Vegar_ExecutionTF(),gVegarStrategyConfigHash!=""?gVegarStrategyConfigHash:gVegarConfigHash);
  }

void Vegar_WriteDiagnostic(const string event,const string state,const string primary,const string secondary,const string detail)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",Detail";
   string r=Vegar_CommonPrefix(eid,"","","","","",event,state,primary,secondary)+","+Vegar_CsvEscape(detail);
   Vegar_CsvAppend("DIAGNOSTIC",h,r);
   if(InpNivelLog>=1) PrintFormat("[VEGAR][%s] %s | %s | %s",event,primary,secondary,detail);
  }

void Vegar_WriteRunConfig()
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",Product,PropertyVersion,AccountCurrency,Leverage,Environment,AccountTradeMode,IsTester,IsOptimization,EngineState,ExecutionState,ExecutionReason,ConfigValidity,ConfigReason,ConfigDetail,StrategyCanonical,TelemetryCanonical,VisualCanonical,Magic,Lote,MinZoneStrength,EqualToleranceATR,ZoneWidthATR,ApproachDistanceATR,MinSweepATR,MaxSweepATR,MSSBufferATR,MinFVGATR,StopEnabled,StopLossMaxMoney,StopBufferATR,MaxBarsSweepToMSS,MaxBarsMssToRetest,ConfirmM5,SessionFilterEnabled,LondonEnabled,LondonStartNY,LondonEndNY,NewYorkEnabled,NewYorkStartNY,NewYorkEndNY,NewsEnabled,NewsMinImpact,NewsMinutesBefore,NewsMinutesAfter,MetalsAutoProfile,MetalsMinutesBefore,MetalsMinutesAfter,TesterNewsFile,MaxTradesPerDay,MaxConsecutiveLosses,DailyLossMoney,MinMarginPct,MaxSpreadTargetPct,DeviationTicks,CommissionRoundTurnPerLot,OperationTargetEnabled,OperationTargetMoney,ProfitMode,TPEnabled,TPMoney,DailyTargetEnabled,DailyTargetMoney,RunnerEnabled,RunnerActivation,RunnerInitialProtected,RunnerDistance,RunnerStep,ReplayEnabled,ReplayHorizon,IntrabarTraceEnabled,IntrabarPostCandles,CsvEnabled,CsvMaxMB,FlushSeconds,LogLevel,SelfTests,ObjectHeartbeatMinutes,DisplayMicroLiquidity,MicroContinuationOperational,MaxSignalMarkersOnChart,SweptMarkerCandles,WeakZonesObservational,ConfigHashAlgorithm,NoCsvOverwrite,NoHistoricalRowUpdate,NoOutcomeToDecisionFeedback";
   string r=Vegar_CommonPrefix(eid,"","","","","","RUN_CONFIG","START","NONE","");
   r += ","+Vegar_CsvEscape(VEGAR_PRODUCT_NAME)+","+Vegar_CsvEscape(VEGAR_MQL_VERSION)+","+Vegar_CsvEscape(gVegarSymbol.account_currency)+","+(string)AccountInfoInteger(ACCOUNT_LEVERAGE)+","+Vegar_CsvEscape(Vegar_EnvironmentText(gVegarEnvironment))+","+(string)gVegarAccountTradeMode+","+(gVegarIsTester?"1":"0")+","+(gVegarIsOptimization?"1":"0");
   r += ","+Vegar_CsvEscape(Vegar_EngineStateText(gVegarEngineState))+","+Vegar_CsvEscape(Vegar_ExecutionStateText(gVegarExecutionState))+","+Vegar_CsvEscape(Vegar_ReasonText(gVegarExecutionReason))+","+Vegar_CsvEscape(EnumToString(gVegarConfigValidity))+","+Vegar_CsvEscape(Vegar_ReasonText(gVegarConfigReason))+","+Vegar_CsvEscape(gVegarConfigDetail);
   r += ","+Vegar_CsvEscape(Vegar_StrategyCanonicalString())+","+Vegar_CsvEscape(Vegar_TelemetryCanonicalString())+","+Vegar_CsvEscape(Vegar_VisualCanonicalString());
   r += ","+(string)InpMagicNumber+","+DoubleToString(InpLoteOperacional,8)+","+(string)InpForcaMinimaZona+","+DoubleToString(InpEqualToleranceATR,8)+","+DoubleToString(InpZoneWidthATR,8)+","+DoubleToString(InpApproachDistanceATR,8)+","+DoubleToString(InpMinSweepATR,8)+","+DoubleToString(InpMaxSweepATR,8)+","+DoubleToString(InpMSSBufferATR,8)+","+DoubleToString(InpMinFVGATR,8);
   r += ","+(InpAtivarStopLoss?"1":"0")+","+DoubleToString(InpStopLossMaximoMoney,8)+","+DoubleToString(InpStopBufferATR,8)+","+(string)InpMaxBarsSweepToMSS+","+(string)InpMaxBarsMssToRetest+","+(InpConfirmarM5QuandoM1?"1":"0");
   r += ","+(InpAtivarFiltroDeSessao?"1":"0")+","+(InpOperarLondon?"1":"0")+","+Vegar_CsvEscape(InpInicioLondonNY)+","+Vegar_CsvEscape(InpFimLondonNY)+","+(InpOperarNewYork?"1":"0")+","+Vegar_CsvEscape(InpInicioNewYorkNY)+","+Vegar_CsvEscape(InpFimNewYorkNY);
   r += ","+(InpAtivarFiltroNoticias?"1":"0")+","+(string)InpImpactoMinimo+","+(string)InpMinutosAntes+","+(string)InpMinutosDepois+","+(InpPerfilAutomaticoMetais?"1":"0")+","+(string)InpMetaisMinutosAntes+","+(string)InpMetaisMinutosDepois+","+Vegar_CsvEscape(InpTesterNewsFile);
   r += ","+(string)InpMaxTradesPerDay+","+(string)InpMaxConsecutiveLosses+","+DoubleToString(InpLimitePerdaDiariaMoney,8)+","+DoubleToString(InpMargemMinimaPermitidaPct,8)+","+DoubleToString(InpMaxSpreadTargetPercent,8)+","+(string)InpDesvioMaxExecucaoTicks+","+DoubleToString(InpComissaoRoundTurnPorLoteMoney,8);
   r += ","+(InpAtivarMetaOperacao?"1":"0")+","+DoubleToString(InpMetaOperacaoMoney,8)+","+(string)(int)InpModoGestaoLucro+","+(InpAtivarTakeProfit?"1":"0")+","+DoubleToString(InpTakeProfitMoney,8)+","+(InpAtivarMetaDiaria?"1":"0")+","+DoubleToString(InpMetaDiariaMoney,8);
   r += ","+(InpAtivarRunner?"1":"0")+","+DoubleToString(InpLucroParaAtivarRunner,8)+","+DoubleToString(InpLucroInicialProtegido,8)+","+DoubleToString(InpDistanciaRunnerMoney,8)+","+DoubleToString(InpPassoRunnerMoney,8);
   r += ","+(InpAtivarOpportunityReplay?"1":"0")+","+(string)InpHorizonteReplayCandles+","+(InpAtivarIntrabarTrace?"1":"0")+","+(string)InpCandlesPosEventoIntrabar+","+(InpAtivarCSV?"1":"0")+","+(string)InpTamanhoMaxArquivoMB+","+(string)InpFlushIntervalSeconds+","+(string)InpNivelLog+","+(InpExecutarSelfTests?"1":"0")+","+(string)InpObjectHeartbeatMinutes+","+(InpExibirMicroLiquidezObservacional?"1":"0")+","+(InpAtivarMicroContinuacaoOperacional?"1":"0")+","+(string)InpMaxSignalMarkersOnChart+","+(string)InpSweptMarkerCandles+","+(InpExibirZonasFracasObservacionais?"1":"0")+",FNV1A64,1,1,1";
   Vegar_CsvAppend("RUN_CONFIG",h,r);
  }

void Vegar_WriteCandleSnapshot(const ENUM_TIMEFRAMES tf,const MqlRates &b,const SVegarFlowSnapshot &flow,const ENUM_VEGAR_M15_CONTEXT m15,
                               const string focus_id,const double focus_strength,const SVegarChannel &channel,const ENUM_VEGAR_SETUP_STATE setup_state)
  {
   double range=b.high-b.low; if(range<=0.0) return;
   int pp=Vegar_TelemetryPricePrecision();
   double body=MathAbs(b.close-b.open),upper=b.high-MathMax(b.open,b.close),lower=MathMin(b.open,b.close)-b.low;
   int barShift=iBarShift(_Symbol,tf,b.time,true); if(barShift<1) barShift=1;
   double avgVol=Vegar_AvgTickVolume(tf,barShift,20),atr=Vegar_ATR(tf,barShift),avgRange=Vegar_AvgRange(tf,barShift,20);
   string direction=(b.close>b.open?"BULL":(b.close<b.open?"BEAR":"DOJI"));
   double spreadPoints=(double)b.spread,spreadTicks=(gVegarSymbol.tick_size>0?spreadPoints*gVegarSymbol.point/gVegarSymbol.tick_size:0.0),spreadMoney=0.0;
   if(spreadPoints>0.0){ double ask=b.close+spreadPoints*gVegarSymbol.point,p=0.0; if(Vegar_CalcProfit(ORDER_TYPE_BUY,InpLoteOperacional,ask,b.close,p)) spreadMoney=MathAbs(p); }
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",Timeframe,BarOpenTime,BarCloseTime,Open,High,Low,Close,Direction,RangePrice,RangePoints,RangeTicks,BodyPrice,BodyPoints,BodyPercent,UpperWickPrice,UpperWickPercent,LowerWickPrice,LowerWickPercent,CloseLocationPercent,TickVolume,AvgTickVolume20,RelativeTickVolume,ATR14,AvgRange20,RangeVsATR,RangeVsAvg20,SpreadAtClosePoints,SpreadAtCloseTicks,SpreadAtCloseMoney,DirectionalBody,CloseLocationMean,NetProgress,Expansion,BuyerAbsorbed,SellerAbsorbed,DualAbsorption,OperationalFlowScore,OperationalFlowClass,ObservationFlowClass,DecisionAuthority,M15Context,FocusZoneID,FocusZoneStrength,ChannelID,ChannelDirection,ChannelStrength,ChannelPositionPercent,SetupState";
   string r=Vegar_CommonPrefix(eid,"","","","","","CANDLE_CLOSED","SNAPSHOT","NONE","");
   r += ","+Vegar_CsvEscape(Vegar_TFText(tf))+","+Vegar_CsvEscape(Vegar_TimeIso(b.time))+","+Vegar_CsvEscape(Vegar_TimeIso(b.time+PeriodSeconds(tf)))+","+DoubleToString(b.open,gVegarSymbol.digits)+","+DoubleToString(b.high,gVegarSymbol.digits)+","+DoubleToString(b.low,gVegarSymbol.digits)+","+DoubleToString(b.close,gVegarSymbol.digits)+","+direction;
   r += ","+DoubleToString(range,pp)+","+DoubleToString(Vegar_PriceToPoints(range),4)+","+DoubleToString(Vegar_PriceToTicks(range),4)+","+DoubleToString(body,pp)+","+DoubleToString(Vegar_PriceToPoints(body),4)+","+DoubleToString(body/range*100.0,6)+","+DoubleToString(upper,pp)+","+DoubleToString(upper/range*100.0,6)+","+DoubleToString(lower,pp)+","+DoubleToString(lower/range*100.0,6)+","+DoubleToString((b.close-b.low)/range*100.0,6);
   r += ","+(string)b.tick_volume+","+DoubleToString(avgVol,4)+","+DoubleToString(avgVol>0?(double)b.tick_volume/avgVol:0.0,6)+","+DoubleToString(atr,pp)+","+DoubleToString(avgRange,pp)+","+DoubleToString(atr>0?range/atr:0.0,6)+","+DoubleToString(avgRange>0?range/avgRange:0.0,6);
   r += ","+DoubleToString(spreadPoints,4)+","+DoubleToString(spreadTicks,4)+","+DoubleToString(spreadMoney,6)+","+DoubleToString(flow.directional_body,6)+","+DoubleToString(flow.close_location_mean,6)+","+DoubleToString(flow.net_progress,6)+","+DoubleToString(flow.expansion,6)+","+(flow.buyer_absorbed?"1":"0")+","+(flow.seller_absorbed?"1":"0")+","+(flow.dual_absorption?"1":"0")+","+DoubleToString(flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(flow.flow_class))+","+Vegar_CsvEscape(flow.observation_flow_class)+","+(flow.decision_authority?"1":"0");
   r += ","+Vegar_CsvEscape(Vegar_M15ContextText(m15))+","+Vegar_CsvEscape(focus_id)+","+DoubleToString(focus_strength,6)+","+Vegar_CsvEscape(channel.id)+","+Vegar_CsvEscape(Vegar_ChannelText(channel.direction))+","+DoubleToString(channel.strength_score,6)+","+DoubleToString(channel.current_price_position_percent,6)+","+Vegar_CsvEscape(Vegar_SetupStateText(setup_state));
   Vegar_CsvAppend("CANDLE_SNAPSHOT",h,r);
  }

void Vegar_LiquidityDensity(double price,double atr,int &oa,int &ob,int &o05,int &o1,int &o2,int &o3,int &o5,
                            int &va,int &vb,int &v05,int &v1,int &v2,int &v3,double &nob,double &nos,double &nvb,double &nvs)
  {
   oa=ob=o05=o1=o2=o3=o5=va=vb=v05=v1=v2=v3=0; nob=nos=nvb=nvs=DBL_MAX;
   if(atr<=0.0) return;
   for(int i=0;i<ArraySize(gVegarZones);i++)
     {
      SVegarZone z=gVegarZones[i]; if(!z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OPERATIONAL || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
      double d=MathAbs(price-z.mid)/atr;
      if(z.mid>=price) oa++; else ob++; if(d<=0.5)o05++; if(d<=1)o1++; if(d<=2)o2++; if(d<=3)o3++; if(d<=5)o5++;
      if(z.operational_bias==VEGAR_BIAS_BUYER && d<nob) nob=d;
      if(z.operational_bias==VEGAR_BIAS_SELLER && d<nos) nos=d;
     }
   for(int j=0;j<ArraySize(gVegarObservationZones);j++)
     {
      SVegarZone z=gVegarObservationZones[j]; if(!z.valid || z.symbol!=_Symbol || z.role!=VEGAR_ZONE_ROLE_OBSERVATION || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED) continue;
      double d=MathAbs(price-z.mid)/atr;
      if(z.mid>=price) va++; else vb++; if(d<=0.5)v05++; if(d<=1)v1++; if(d<=2)v2++; if(d<=3)v3++;
      if(z.operational_bias==VEGAR_BIAS_BUYER && d<nvb) nvb=d;
      if(z.operational_bias==VEGAR_BIAS_SELLER && d<nvs) nvs=d;
     }
   if(nob==DBL_MAX)nob=-1; if(nos==DBL_MAX)nos=-1; if(nvb==DBL_MAX)nvb=-1; if(nvs==DBL_MAX)nvs=-1;
  }

int Vegar_CsvNearestZone(const ENUM_VEGAR_ZONE_ROLE role,double &distance_atr,string &zone_id,ENUM_TIMEFRAMES &tf,ENUM_VEGAR_BIAS &direction)
  {
   distance_atr=DBL_MAX; zone_id=""; tf=PERIOD_CURRENT; direction=VEGAR_BIAS_NONE;
   if(!Vegar_UpdateTick()) return -1;
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1); if(atr<=0.0) return -1;
   double p=(gVegarTick.bid+gVegarTick.ask)*0.5;
   int best=-1;
   if(role==VEGAR_ZONE_ROLE_OPERATIONAL)
     {
      for(int i=0;i<ArraySize(gVegarZones);i++)
        {
         SVegarZone z=gVegarZones[i];
         if(!z.valid || z.symbol!=_Symbol || z.role!=role || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
         double d=0.0; if(p<z.low)d=z.low-p; else if(p>z.high)d=p-z.high; double da=d/atr;
         if(da<distance_atr){distance_atr=da;best=i;zone_id=z.id;tf=z.source_tf;direction=z.operational_bias;}
        }
     }
   else
     {
      for(int i=0;i<ArraySize(gVegarObservationZones);i++)
        {
         SVegarZone z=gVegarObservationZones[i];
         if(!z.valid || z.symbol!=_Symbol || z.role!=role || z.state==VEGAR_ZONE_INVALIDATED || z.state==VEGAR_ZONE_EXPIRED || z.state==VEGAR_ZONE_SWEPT) continue;
         double d=0.0; if(p<z.low)d=z.low-p; else if(p>z.high)d=p-z.high; double da=d/atr;
         if(da<distance_atr){distance_atr=da;best=i;zone_id=z.id;tf=z.source_tf;direction=z.operational_bias;}
        }
     }
   if(best<0) distance_atr=-1.0;
   return best;
  }

void Vegar_WriteMarketState(const SVegarChannel &h4,const SVegarChannel &m15,const SVegarFlowSnapshot &flow,const ENUM_VEGAR_M15_CONTEXT context,
                            const string focus_id,const double distance_atr,const SVegarSessionStatus &session,const SVegarNewsStatus &news)
  {
   double mid=0.0; if(Vegar_UpdateTick()) mid=(gVegarTick.bid+gVegarTick.ask)*0.5; else mid=iClose(_Symbol,Vegar_ExecutionTF(),1);
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1);
   int oa,ob,o05,o1,o2,o3,o5,va,vb,v05,v1,v2,v3; double nob,nos,nvb,nvs;
   Vegar_LiquidityDensity(mid,atr,oa,ob,o05,o1,o2,o3,o5,va,vb,v05,v1,v2,v3,nob,nos,nvb,nvs);

   string nearestOp="",nearestObs=""; double nearestOpDist=-1.0,nearestObsDist=-1.0; ENUM_TIMEFRAMES nearestOpTf=PERIOD_CURRENT,nearestObsTf=PERIOD_CURRENT; ENUM_VEGAR_BIAS nearestOpDir=VEGAR_BIAS_NONE,nearestObsDir=VEGAR_BIAS_NONE;
   Vegar_CsvNearestZone(VEGAR_ZONE_ROLE_OPERATIONAL,nearestOpDist,nearestOp,nearestOpTf,nearestOpDir);
   Vegar_CsvNearestZone(VEGAR_ZONE_ROLE_OBSERVATION,nearestObsDist,nearestObs,nearestObsTf,nearestObsDir);

   bool signalReady=gVegarOpportunity.technical_signal_ready;
   string locationState=(nearestOp!=""?"AVAILABLE":"NONE");
   string approachState=(gVegarApproachLatch.active?"LATCHED":(gVegarOpportunity.active?Vegar_ApproachModeText(gVegarOpportunity.approach_mode):"NONE"));
   string contextGate=(signalReady?gVegarOpportunity.context_gate:"NOT_EVALUATED");
   string sessionGate=(signalReady?gVegarOpportunity.session_gate:(InpAtivarFiltroDeSessao?"NOT_EVALUATED":"NOT_APPLICABLE"));
   string newsGate=(signalReady?gVegarOpportunity.news_gate:(InpAtivarFiltroNoticias?"NOT_EVALUATED":"NOT_APPLICABLE"));
   string spreadGate=(signalReady?gVegarOpportunity.spread_gate:"NOT_EVALUATED");
   string oppositeGate=(signalReady?gVegarOpportunity.opposite_liquidity_gate:"NOT_EVALUATED");
   string targetGate=(signalReady?gVegarOpportunity.target_space_gate:"NOT_EVALUATED");
   string riskGate=(signalReady?gVegarOpportunity.risk_gate:"NOT_EVALUATED");
   string executionGate=(signalReady?(gVegarOpportunity.execution_authorized?"PASS":"FAIL"):"NOT_EVALUATED");
   string candidateState=(gVegarOpportunity.active?Vegar_CandidateStateText(gVegarOpportunity.candidate_state):(gVegarApproachLatch.active?"APPROACH":"NONE"));
   string opportunityState=(gVegarOpportunity.active?Vegar_SetupStateText(gVegarOpportunity.state):"IDLE");
   string signalState=(signalReady?"TECHNICAL_SIGNAL_READY":"NOT_READY");

   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",H4ChannelID,H4ChannelDirection,H4ChannelStrength,H4GeometryClass,M15Structure,M15ChannelID,M15ChannelDirection,M15ChannelStrength,M15GeometryClass,ExecutionFlowScore,ExecutionFlowClass,PDH,PDL,PWH,PWL,FocusZoneID,DistanceToFocusZoneATR,Session,NewsState,LocationState,ApproachState,ContextGateState,SessionGateState,NewsGateState,SpreadGateState,OppositeLiquidityState,TargetSpaceState,RiskGateState,ExecutionGateState,NearestOperationalZoneID,NearestOperationalDirection,NearestOperationalTF,NearestOperationalDistanceATR,NearestObservationZoneID,NearestObservationDirection,NearestObservationTF,NearestObservationDistanceATR,OperationalZonesAbove,OperationalZonesBelow,OperationalZonesWithin0_5ATR,OperationalZonesWithin1ATR,OperationalZonesWithin2ATR,OperationalZonesWithin3ATR,OperationalZonesWithin5ATR,ObservationZonesAbove,ObservationZonesBelow,ObservationZonesWithin0_5ATR,ObservationZonesWithin1ATR,ObservationZonesWithin2ATR,ObservationZonesWithin3ATR,NearestOperationalBuyerDistanceATR,NearestOperationalSellerDistanceATR,NearestObservationBuyerDistanceATR,NearestObservationSellerDistanceATR,CandidateState,OpportunityState,SignalState";
   string r=Vegar_CommonPrefix(eid,"","","","","","MARKET_STATE","SNAPSHOT","NONE","");
   r += ","+Vegar_CsvEscape(h4.id)+","+Vegar_CsvEscape(Vegar_ChannelText(h4.direction))+","+DoubleToString(h4.strength_score,6)+","+Vegar_CsvEscape(Vegar_ChannelGeometryText(h4.geometry_class))+","+Vegar_CsvEscape(Vegar_M15ContextText(context))+","+Vegar_CsvEscape(m15.id)+","+Vegar_CsvEscape(Vegar_ChannelText(m15.direction))+","+DoubleToString(m15.strength_score,6)+","+Vegar_CsvEscape(Vegar_ChannelGeometryText(m15.geometry_class))+","+DoubleToString(flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(flow.flow_class));
   r += ","+DoubleToString(iHigh(_Symbol,PERIOD_D1,1),gVegarSymbol.digits)+","+DoubleToString(iLow(_Symbol,PERIOD_D1,1),gVegarSymbol.digits)+","+DoubleToString(iHigh(_Symbol,PERIOD_W1,1),gVegarSymbol.digits)+","+DoubleToString(iLow(_Symbol,PERIOD_W1,1),gVegarSymbol.digits)+","+Vegar_CsvEscape(focus_id)+","+DoubleToString(distance_atr,6)+","+Vegar_CsvEscape(session.label)+","+Vegar_CsvEscape(EnumToString(news.state));
   r += ","+locationState+","+approachState+","+contextGate+","+sessionGate+","+newsGate+","+spreadGate+","+oppositeGate+","+targetGate+","+riskGate+","+executionGate;
   r += ","+Vegar_CsvEscape(nearestOp)+","+Vegar_CsvEscape(Vegar_BiasText(nearestOpDir))+","+Vegar_CsvEscape(Vegar_TFText(nearestOpTf))+","+DoubleToString(nearestOpDist,6)+","+Vegar_CsvEscape(nearestObs)+","+Vegar_CsvEscape(Vegar_BiasText(nearestObsDir))+","+Vegar_CsvEscape(Vegar_TFText(nearestObsTf))+","+DoubleToString(nearestObsDist,6);
   r += ","+(string)oa+","+(string)ob+","+(string)o05+","+(string)o1+","+(string)o2+","+(string)o3+","+(string)o5+","+(string)va+","+(string)vb+","+(string)v05+","+(string)v1+","+(string)v2+","+(string)v3+","+DoubleToString(nob,6)+","+DoubleToString(nos,6)+","+DoubleToString(nvb,6)+","+DoubleToString(nvs,6)+","+Vegar_CsvEscape(candidateState)+","+Vegar_CsvEscape(opportunityState)+","+Vegar_CsvEscape(signalState);
   Vegar_CsvAppend("MARKET_STATE",h,r);
  }

int Vegar_ObjectCacheIndex(const string id)
  {
   for(int i=0;i<ArraySize(gVegarObjectCacheIDs);i++) if(gVegarObjectCacheIDs[i]==id) return i;
   return -1;
  }

bool Vegar_ObjectShouldWrite(const string id,const string fingerprint,string &event_name)
  {
   datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
   string hash=Vegar_Fnv1a64Hex(fingerprint);
   int i=Vegar_ObjectCacheIndex(id);
   if(i<0)
     {
      int n=ArraySize(gVegarObjectCacheIDs); ArrayResize(gVegarObjectCacheIDs,n+1); ArrayResize(gVegarObjectCacheHashes,n+1); ArrayResize(gVegarObjectCacheLastWrite,n+1);
      gVegarObjectCacheIDs[n]=id; gVegarObjectCacheHashes[n]=hash; gVegarObjectCacheLastWrite[n]=now; event_name="OBJECT_CREATED"; return true;
     }
   if(gVegarObjectCacheHashes[i]!=hash)
     { gVegarObjectCacheHashes[i]=hash; gVegarObjectCacheLastWrite[i]=now; event_name="OBJECT_CHANGED"; return true; }
   if(InpObjectHeartbeatMinutes>0 && now-gVegarObjectCacheLastWrite[i]>=InpObjectHeartbeatMinutes*60)
     { gVegarObjectCacheLastWrite[i]=now; event_name="OBJECT_HEARTBEAT"; return true; }
   return false;
  }

void Vegar_ResetObjectStateCache()
  {
   ArrayResize(gVegarObjectCacheIDs,0); ArrayResize(gVegarObjectCacheHashes,0); ArrayResize(gVegarObjectCacheLastWrite,0);
  }

string Vegar_ZoneFingerprint(const SVegarZone &z)
  {
   int pp=Vegar_TelemetryPricePrecision();
   return z.id+"|"+z.symbol+"|"+(string)(int)z.role+"|"+(string)(int)z.type+"|"+(string)(int)z.state+"|"+DoubleToString(z.low,pp)+"|"+DoubleToString(z.high,pp)+"|"+DoubleToString(z.strength_score,6)+"|"+z.source_ids+"|"+z.source_types+"|"+z.source_tfs+"|"+z.source_times+"|"+z.source_confirmed_times+"|"+z.source_atrs+"|"+(z.focus?"1":"0")+"|"+(z.valid?"1":"0")+
          "|"+(string)z.touch_count+"|"+(string)z.touch_episode_count+"|"+(string)(long)z.last_touch_time+"|"+(string)z.bars_since_last_touch+
          "|"+DoubleToString(z.reaction_atr_3bars,6)+"|"+DoubleToString(z.reaction_atr_5bars,6)+"|"+DoubleToString(z.reaction_atr_10bars,6)+"|"+DoubleToString(z.maximum_reaction_atr,6)+
          "|"+(string)z.time_to_reaction_1atr_sec+"|"+(string)z.time_to_reaction_2atr_sec;
  }

string Vegar_ChannelFingerprint(const SVegarChannel &c)
  {
   int pp=Vegar_TelemetryPricePrecision();
   return c.id+"|"+c.symbol+"|"+(string)(int)c.direction+"|"+(string)(int)c.geometry_class+"|"+(string)c.anchor1_time+"|"+(string)c.anchor2_time+"|"+DoubleToString(c.anchor1_price,pp)+"|"+DoubleToString(c.anchor2_price,pp)+"|"+DoubleToString(c.current_upper_rail,pp)+"|"+DoubleToString(c.current_mid_rail,pp)+"|"+DoubleToString(c.current_lower_rail,pp)+"|"+DoubleToString(c.strength_score,6)+"|"+(c.superseded?"1":"0")+"|"+(c.valid?"1":"0");
  }

string Vegar_ObjectStateHeader()
  {
   return Vegar_CommonHeader()+",ObjectStateHash,ObjectEvent,ObjectID,ObjectType,ZoneRole,SourceTF,Direction,LiquiditySide,PriceLow,PriceHigh,PriceMid,ZoneWidth,SourceATR,StrengthScore,StrengthClass,ObjectState,Focus,Valid,SourceCount,SourceIDs,SourceTypes,SourceTFs,SourceTimes,SourceConfirmedTimes,SourceATRs,PrimarySourceType,PrimarySourceTF,TouchBarCount,TouchEpisodeCount,TimeSinceLastTouch,BarsSinceLastTouch,ReactionATR_3Bars,ReactionATR_5Bars,ReactionATR_10Bars,MaximumReactionATR,TimeToReaction1ATR,TimeToReaction2ATR,CreatedAt,ChangedAt,ParentOpportunityID,ChannelGeometryClass,Anchor1Time,Anchor1Price,Anchor2Time,Anchor2Price,SlopePricePerBar,SlopeATRPerBar,OffsetPrice,CurrentUpperRail,CurrentMidRail,CurrentLowerRail,ChannelWidthPrice,ChannelWidthATR,CurrentPricePositionPercent,DistanceUpperRailATR,DistanceLowerRailATR,EfficiencyRatio,RespectFraction,CoherentConfirmations,StructureScoreComponent,SlopeScoreComponent,ERScoreComponent,RespectScoreComponent,Superseded";
  }

void Vegar_WriteObjectState(const SVegarZone &z,const string parent_opp="")
  {
   if(z.id=="") return;
   if(z.symbol!="" && z.symbol!=_Symbol)
     { PrintFormat("[VEGAR][CROSS_SYMBOL_ENTITY_REJECTED] Zone=%s EntitySymbol=%s Current=%s",z.id,z.symbol,_Symbol); return; }
   string event_name=""; string fp=Vegar_ZoneFingerprint(z); if(!Vegar_ObjectShouldWrite(z.id,fp,event_name)) return;
   int pp=Vegar_TelemetryPricePrecision(); string eid=Vegar_NextID("EV"),hash=Vegar_Fnv1a64Hex(fp);
   string h=Vegar_ObjectStateHeader();
   string r=Vegar_CommonPrefix(eid,parent_opp,"","","","",event_name,Vegar_ZoneStateText(z.state),"NONE","");
   datetime now=TimeTradeServer(); if(now<=0)now=TimeCurrent(); int since=(z.last_touch_time>0?(int)(now-z.last_touch_time):-1);
   r += ","+Vegar_CsvEscape(hash)+","+Vegar_CsvEscape(event_name)+","+Vegar_CsvEscape(z.id)+","+Vegar_CsvEscape(Vegar_ZoneTypeText(z.type))+","+Vegar_CsvEscape(Vegar_ZoneRoleText(z.role))+","+Vegar_CsvEscape(Vegar_TFText(z.source_tf))+","+Vegar_CsvEscape(Vegar_BiasText(z.operational_bias))+","+Vegar_CsvEscape(EnumToString(z.liquidity_side));
   r += ","+DoubleToString(z.low,gVegarSymbol.digits)+","+DoubleToString(z.high,gVegarSymbol.digits)+","+DoubleToString(z.mid,gVegarSymbol.digits)+","+DoubleToString(z.width,pp)+","+DoubleToString(z.source_atr,pp)+","+DoubleToString(z.strength_score,6)+","+Vegar_CsvEscape(Vegar_StrengthClassText(z.strength_class))+","+Vegar_CsvEscape(Vegar_ZoneStateText(z.state))+","+(z.focus?"1":"0")+","+(z.valid?"1":"0");
   r += ","+(string)z.source_count+","+Vegar_CsvEscape(z.source_ids)+","+Vegar_CsvEscape(z.source_types)+","+Vegar_CsvEscape(z.source_tfs)+","+Vegar_CsvEscape(z.source_times)+","+Vegar_CsvEscape(z.source_confirmed_times)+","+Vegar_CsvEscape(z.source_atrs)+","+Vegar_CsvEscape(Vegar_ZoneTypeText(z.primary_source_type))+","+Vegar_CsvEscape(Vegar_TFText(z.primary_source_tf));
   r += ","+(string)z.touch_count+","+(string)z.touch_episode_count+","+(string)since+","+(string)z.bars_since_last_touch+","+DoubleToString(z.reaction_atr_3bars,6)+","+DoubleToString(z.reaction_atr_5bars,6)+","+DoubleToString(z.reaction_atr_10bars,6)+","+DoubleToString(z.maximum_reaction_atr,6)+","+(string)z.time_to_reaction_1atr_sec+","+(string)z.time_to_reaction_2atr_sec+","+Vegar_CsvEscape(Vegar_TimeIso(z.confirmed_time))+","+Vegar_CsvEscape(Vegar_TimeIso(z.last_changed))+","+Vegar_CsvEscape(parent_opp);
   // Channel-only fields in the unified Schema 2100 OBJECT_STATE contract.
   for(int k=0;k<24;k++) r+=",";
   Vegar_CsvAppend("OBJECT_STATE",h,r);
  }

void Vegar_WriteChannelObjectState(const SVegarChannel &c)
  {
   if(c.id=="") return;
   if(c.symbol!="" && c.symbol!=_Symbol)
     { PrintFormat("[VEGAR][CROSS_SYMBOL_ENTITY_REJECTED] Channel=%s EntitySymbol=%s Current=%s",c.id,c.symbol,_Symbol); return; }
   string event_name=""; string fp=Vegar_ChannelFingerprint(c); if(!Vegar_ObjectShouldWrite(c.id,fp,event_name)) return;
   int pp=Vegar_TelemetryPricePrecision(); string eid=Vegar_NextID("EV"),hash=Vegar_Fnv1a64Hex(fp);
   string state=(c.superseded?"SUPERSEDED":(c.valid?"ACTIVE":"INVALID"));
   string h=Vegar_ObjectStateHeader();
   string r=Vegar_CommonPrefix(eid,"","","","","",event_name,state,"NONE","");
   // Common object identity.
   r += ","+Vegar_CsvEscape(hash)+","+Vegar_CsvEscape(event_name)+","+Vegar_CsvEscape(c.id)+",CHANNEL";
   // ZoneRole blank, then TF and Direction; zone-specific geometry/provenance blank.
   r += ",,"+Vegar_CsvEscape(Vegar_TFText(c.tf))+","+Vegar_CsvEscape(Vegar_ChannelText(c.direction))+",";
   for(int k=0;k<5;k++) r+=","; // low/high/mid/width/sourceATR
   r += ","+DoubleToString(c.strength_score,6)+","+Vegar_CsvEscape(Vegar_StrengthClassText(c.strength_class))+","+Vegar_CsvEscape(state)+",,"+(c.valid?"1":"0");
   for(int k=0;k<19;k++) r+=","; // source + touch/reaction fields through TimeToReaction2ATR
   r += ","+Vegar_CsvEscape(Vegar_TimeIso(c.created_time))+","+Vegar_CsvEscape(Vegar_TimeIso(c.last_changed))+","; // ParentOpportunityID blank
   // Channel-specific fields.
   r += ","+Vegar_CsvEscape(Vegar_ChannelGeometryText(c.geometry_class))+","+Vegar_CsvEscape(Vegar_TimeIso(c.anchor1_time))+","+DoubleToString(c.anchor1_price,gVegarSymbol.digits)+","+Vegar_CsvEscape(Vegar_TimeIso(c.anchor2_time))+","+DoubleToString(c.anchor2_price,gVegarSymbol.digits);
   r += ","+DoubleToString(c.slope_price_per_bar,pp)+","+DoubleToString(c.slope_atr_per_bar,6)+","+DoubleToString(c.offset_price,pp)+","+DoubleToString(c.current_upper_rail,gVegarSymbol.digits)+","+DoubleToString(c.current_mid_rail,gVegarSymbol.digits)+","+DoubleToString(c.current_lower_rail,gVegarSymbol.digits)+","+DoubleToString(c.channel_width_price,pp)+","+DoubleToString(c.channel_width_atr,6)+","+DoubleToString(c.current_price_position_percent,6)+","+DoubleToString(c.distance_upper_rail_atr,6)+","+DoubleToString(c.distance_lower_rail_atr,6);
   r += ","+DoubleToString(c.efficiency_ratio,6)+","+DoubleToString(c.respect_fraction,6)+","+(string)c.coherent_confirmations+","+DoubleToString(c.structure_score_component,6)+","+DoubleToString(c.slope_score_component,6)+","+DoubleToString(c.er_score_component,6)+","+DoubleToString(c.respect_score_component,6)+","+(c.superseded?"1":"0");
   Vegar_CsvAppend("OBJECT_STATE",h,r);
  }

string Vegar_SignalDecisionHeader()
  {
   return Vegar_CommonHeader()+",CandidateID,SetupFamily,CandidateState,TechnicalSignalReady,OperationalEligibleAtApproach,OperationalApproachArmed,OperationalSignalReady,ExecutionAuthorized,GateName,GateState,Decision,Accepted,Blocked,ReasonCode,FailedGateCount,FailedGates,SourceZoneID,ZoneRole,SourceZonePreState,SourceZonePostState,SourceZoneConsumedByOpportunity,ApproachMode,ApproachFirstTime,ApproachMinimumDistanceATR,SweepSameBarAsApproach,ZoneStrength,CurrentPrice,DistanceATR,BarHigh,BarLow,BarClose,ClosedFlowScore,ClosedFlowClass,LiveFlowScore,LiveFlowClass,ChannelID,Context,MarkerID,SweepState,MSSState,DisplacementState,FVGState,OBState,RetestState,NextState,Detail,PipelineState,MSSRequiredLevel,MSSBestObserved,MSSDistanceMissing,DisplacementRequiredRangeRatio,DisplacementObservedRangeRatio,DisplacementRequiredCloseLocation,DisplacementObservedCloseLocation";
  }

void Vegar_WriteSignalDecision(const string gate,const string input_state,const bool accepted,const ENUM_VEGAR_REASON_CODE reason,const SVegarOpportunity &opp,const SVegarFlowSnapshot &flow,const string next_state)
  {
   SVegarFlowSnapshot live=Vegar_CalcLiveFlow(Vegar_ExecutionTF());
   string role=Vegar_ZoneRoleText(opp.source_zone_role);
   double price=(Vegar_UpdateTick()?(opp.direction==VEGAR_BIAS_SELLER?gVegarTick.bid:gVegarTick.ask):iClose(_Symbol,Vegar_ExecutionTF(),1));
   double atr=Vegar_ATR(Vegar_ExecutionTF(),1),dist=-1.0;
   if(atr>0.0 && opp.source_zone_mid>0.0) dist=MathAbs(price-opp.source_zone_mid)/atr;
   MqlRates b; ZeroMemory(b); Vegar_GetBar(Vegar_ExecutionTF(),1,b);
   string channel_id=gVegarChannelM15.id;
   string eid=Vegar_NextID("EV");
   string h=Vegar_SignalDecisionHeader();
   string gate_state=(accepted?"PASS":"FAIL");
   if(input_state=="PASS" || input_state=="FAIL" || input_state=="NOT_APPLICABLE" || input_state=="NOT_EVALUATED") gate_state=input_state;
   string r=Vegar_CommonPrefix(eid,opp.opportunity_id,opp.snapshot_id,opp.setup_id,opp.signal_id,"","SIGNAL_DECISION",accepted?"ACCEPTED":"BLOCKED",Vegar_ReasonText(reason),gate);
   r += ","+Vegar_CsvEscape(opp.candidate_id)+","+Vegar_CsvEscape(Vegar_SetupFamilyText(opp.setup_family))+","+Vegar_CsvEscape(Vegar_CandidateStateText(opp.candidate_state))+","+(opp.technical_signal_ready?"1":"0")+","+(opp.operational_eligible_at_approach?"1":"0")+","+(opp.operational_approach_armed?"1":"0")+","+(opp.operational_signal_ready?"1":"0")+","+(opp.execution_authorized?"1":"0")+","+Vegar_CsvEscape(gate)+","+Vegar_CsvEscape(gate_state)+","+Vegar_CsvEscape(accepted?"ACCEPTED":"BLOCKED")+","+(accepted?"1":"0")+","+(accepted?"0":"1")+","+Vegar_CsvEscape(Vegar_ReasonText(reason))+","+(string)opp.failed_gate_count+","+Vegar_CsvEscape(opp.failed_gates);
   r += ","+Vegar_CsvEscape(opp.source_zone_id!=""?opp.source_zone_id:opp.focus_zone_id)+","+Vegar_CsvEscape(role)+","+Vegar_CsvEscape(Vegar_ZoneStateText(opp.source_zone_pre_state))+","+Vegar_CsvEscape(Vegar_ZoneStateText(opp.source_zone_post_state))+","+(opp.source_zone_consumed_by_opportunity?"1":"0")+","+Vegar_CsvEscape(Vegar_ApproachModeText(opp.approach_mode))+","+Vegar_CsvEscape(Vegar_TimeIso(opp.approach_first_time))+","+DoubleToString(opp.approach_minimum_distance_atr,6)+","+(opp.sweep_same_bar_as_approach?"1":"0")+","+DoubleToString(opp.focus_zone_strength,6)+","+DoubleToString(price,gVegarSymbol.digits)+","+DoubleToString(dist,6)+","+DoubleToString(b.high,gVegarSymbol.digits)+","+DoubleToString(b.low,gVegarSymbol.digits)+","+DoubleToString(b.close,gVegarSymbol.digits);
   r += ","+DoubleToString(flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(flow.flow_class))+","+DoubleToString(live.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(live.flow_class))+","+Vegar_CsvEscape(channel_id)+","+Vegar_CsvEscape(Vegar_M15ContextText(gVegarM15Context))+","+Vegar_CsvEscape(opp.marker_id);
   r += ","+Vegar_CsvEscape(opp.sweep_time>0?"CONFIRMED":"WAITING")+","+Vegar_CsvEscape(opp.mss_time>0?"CONFIRMED":"WAITING")+","+Vegar_CsvEscape(opp.displacement_time>0?"CONFIRMED":"WAITING")+","+Vegar_CsvEscape(opp.retest_type==VEGAR_RETEST_FVG?"VALID":"NONE")+","+Vegar_CsvEscape(opp.retest_type==VEGAR_RETEST_ORDER_BLOCK?"VALID":"NONE")+","+Vegar_CsvEscape(opp.retest_time>0?"CONFIRMED":"WAITING")+","+Vegar_CsvEscape(next_state)+",,"+Vegar_CsvEscape(opp.pipeline_state)+","+DoubleToString(opp.mss_required_level,gVegarSymbol.digits)+","+DoubleToString(opp.mss_best_observed,gVegarSymbol.digits)+","+DoubleToString(opp.mss_distance_missing,gVegarSymbol.digits)+","+DoubleToString(opp.displacement_required_range_ratio,6)+","+DoubleToString(opp.displacement_observed_range_ratio,6)+","+DoubleToString(opp.displacement_required_close_location,6)+","+DoubleToString(opp.displacement_observed_close_location,6);
   Vegar_CsvAppend("SIGNAL_DECISIONS",h,r);
  }

void Vegar_WriteApproachDecision(const string event_name,const string candidate_id,const SVegarZoneEventSnapshot &snap,const string detail)
  {
   SVegarFlowSnapshot closed=Vegar_CalcFlow(Vegar_ExecutionTF());
   SVegarFlowSnapshot live=Vegar_CalcLiveFlow(Vegar_ExecutionTF());
   string eid=Vegar_NextID("EV");
   string h=Vegar_SignalDecisionHeader();
   string r=Vegar_CommonPrefix(eid,"","","","","",event_name,"OBSERVED","NONE","");
   ENUM_VEGAR_APPROACH_MODE mode=(StringFind(detail,"LIVE")>=0?VEGAR_APPROACH_LIVE:VEGAR_APPROACH_CLOSED_BAR);
   r += ","+Vegar_CsvEscape(candidate_id)+",STRUCTURAL_REVERSAL,APPROACH,0,1,1,0,0,"+Vegar_CsvEscape(event_name)+",NOT_EVALUATED,OBSERVED,1,0,NONE,0,,"+Vegar_CsvEscape(snap.zone_id)+","+Vegar_CsvEscape(Vegar_ZoneRoleText(snap.role))+","+Vegar_CsvEscape(Vegar_ZoneStateText(snap.pre_state))+","+Vegar_CsvEscape(Vegar_ZoneStateText(snap.post_state))+",0,"+Vegar_CsvEscape(Vegar_ApproachModeText(mode))+","+Vegar_CsvEscape(Vegar_TimeIso(snap.closed_bar_time))+","+DoubleToString(snap.distance_atr,6)+","+(snap.sweep_observed?"1":"0")+","+DoubleToString(snap.pre_strength,6)+","+DoubleToString(snap.closed_bar_close,gVegarSymbol.digits)+","+DoubleToString(snap.distance_atr,6)+","+DoubleToString(snap.closed_bar_high,gVegarSymbol.digits)+","+DoubleToString(snap.closed_bar_low,gVegarSymbol.digits)+","+DoubleToString(snap.closed_bar_close,gVegarSymbol.digits);
   r += ","+DoubleToString(closed.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(closed.flow_class))+","+DoubleToString(live.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(live.flow_class))+","+Vegar_CsvEscape(gVegarChannelM15.id)+","+Vegar_CsvEscape(Vegar_M15ContextText(gVegarM15Context))+",,"+(snap.sweep_observed?"CONFIRMED":"WAITING")+",WAITING,WAITING,NONE,NONE,WAITING,"+Vegar_CsvEscape(event_name)+","+Vegar_CsvEscape(detail)+",CANDIDATE_APPROACH,0,0,0,2.000000,0,0,0";
   Vegar_CsvAppend("SIGNAL_DECISIONS",h,r);
  }

void Vegar_WriteOpportunitySnapshot(const SVegarOpportunity &opp,const string snapshot_stage,const string actual_decision,const ENUM_VEGAR_REASON_CODE block_reason,const SVegarFlowSnapshot &flow,const SVegarChannel &channel)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",CandidateID,SetupFamily,CandidateState,ObservationCandidate,TechnicalSignalReady,OperationalEligibleAtApproach,OperationalApproachArmed,OperationalSignalReady,ExecutionAuthorized,FailedGateCount,FailedGates,MarkerID,SnapshotStage,HypotheticalDirection,HypotheticalEntryBid,HypotheticalEntryAsk,HypotheticalEntryPrice,CurrentSpreadPoints,CurrentSpreadTicks,CurrentSpreadMoney,TechnicalStopPrice,TechnicalStopMoney,OppositeLiquidityPrice,ExpectedMoneyAtOppositeLiquidity,ZoneID,ZoneRole,ZoneStrength,SourceZonePreState,SourceZonePostState,SourceZoneConsumedByOpportunity,ApproachMode,ApproachFirstTime,ApproachMinimumDistanceATR,SweepSameBarAsApproach,ChannelID,ChannelDirection,ChannelStrength,ChannelPositionPercent,DirectionalBody,CloseLocationMean,NetProgress,Expansion,FlowScore,FlowClass,M15Context,ContextGate,M5Gate,SessionGate,NewsGate,OppositeLiquidityGate,TargetSpaceGate,SpreadGate,StopGate,RiskGate,PreflightGate,EAActualDecision,BlockReason,PipelineState,DailyTargetGate,DailyLossGate,MaxTradesGate,LossStreakGate,PositionGate,OwnershipGate,MarketGate,TradingPermissionGate,MarginGate,StopsLevelGate,FreezeLevelGate,OrderCheckGate,MSSRequiredLevel,MSSBestObserved,MSSDistanceMissing,DisplacementRequiredRangeRatio,DisplacementObservedRangeRatio,DisplacementRequiredCloseLocation,DisplacementObservedCloseLocation";
   double entry=(opp.direction==VEGAR_BIAS_BUYER?opp.hypothetical_entry_ask:opp.hypothetical_entry_bid);
   string r=Vegar_CommonPrefix(eid,opp.opportunity_id,opp.snapshot_id,opp.setup_id,opp.signal_id,"","OPPORTUNITY_SNAPSHOT",snapshot_stage,Vegar_ReasonText(block_reason),"");
   r += ","+Vegar_CsvEscape(opp.candidate_id)+","+Vegar_CsvEscape(Vegar_SetupFamilyText(opp.setup_family))+","+Vegar_CsvEscape(Vegar_CandidateStateText(opp.candidate_state))+","+(opp.observation_candidate?"1":"0")+","+(opp.technical_signal_ready?"1":"0")+","+(opp.operational_eligible_at_approach?"1":"0")+","+(opp.operational_approach_armed?"1":"0")+","+(opp.operational_signal_ready?"1":"0")+","+(opp.execution_authorized?"1":"0")+","+(string)opp.failed_gate_count+","+Vegar_CsvEscape(opp.failed_gates)+","+Vegar_CsvEscape(opp.marker_id)+","+Vegar_CsvEscape(snapshot_stage)+","+Vegar_CsvEscape(Vegar_BiasText(opp.direction));
   r += ","+DoubleToString(opp.hypothetical_entry_bid,gVegarSymbol.digits)+","+DoubleToString(opp.hypothetical_entry_ask,gVegarSymbol.digits)+","+DoubleToString(entry,gVegarSymbol.digits)+","+DoubleToString(Vegar_CurrentSpreadPoints(),4)+","+DoubleToString(Vegar_CurrentSpreadTicks(),4)+","+DoubleToString(Vegar_SpreadMoney(InpLoteOperacional),6)+","+DoubleToString(opp.technical_stop,gVegarSymbol.digits)+","+DoubleToString(opp.technical_stop_money,6)+","+DoubleToString(opp.opposite_liquidity_price,gVegarSymbol.digits)+","+DoubleToString(opp.expected_money_opposite,6);
   r += ","+Vegar_CsvEscape(opp.source_zone_id!=""?opp.source_zone_id:opp.focus_zone_id)+","+Vegar_CsvEscape(Vegar_ZoneRoleText(opp.source_zone_role))+","+DoubleToString(opp.focus_zone_strength,6)+","+Vegar_CsvEscape(Vegar_ZoneStateText(opp.source_zone_pre_state))+","+Vegar_CsvEscape(Vegar_ZoneStateText(opp.source_zone_post_state))+","+(opp.source_zone_consumed_by_opportunity?"1":"0")+","+Vegar_CsvEscape(Vegar_ApproachModeText(opp.approach_mode))+","+Vegar_CsvEscape(Vegar_TimeIso(opp.approach_first_time))+","+DoubleToString(opp.approach_minimum_distance_atr,6)+","+(opp.sweep_same_bar_as_approach?"1":"0");
   r += ","+Vegar_CsvEscape(channel.id)+","+Vegar_CsvEscape(Vegar_ChannelText(channel.direction))+","+DoubleToString(channel.strength_score,6)+","+DoubleToString(channel.current_price_position_percent,6)+","+DoubleToString(flow.directional_body,6)+","+DoubleToString(flow.close_location_mean,6)+","+DoubleToString(flow.net_progress,6)+","+DoubleToString(flow.expansion,6)+","+DoubleToString(flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(flow.flow_class))+","+Vegar_CsvEscape(Vegar_M15ContextText(gVegarM15Context));
   r += ","+Vegar_CsvEscape(opp.context_gate)+","+Vegar_CsvEscape(opp.m5_gate)+","+Vegar_CsvEscape(opp.session_gate)+","+Vegar_CsvEscape(opp.news_gate)+","+Vegar_CsvEscape(opp.opposite_liquidity_gate)+","+Vegar_CsvEscape(opp.target_space_gate)+","+Vegar_CsvEscape(opp.spread_gate)+","+Vegar_CsvEscape(opp.stop_gate)+","+Vegar_CsvEscape(opp.risk_gate)+","+Vegar_CsvEscape(opp.preflight_gate)+","+Vegar_CsvEscape(actual_decision)+","+Vegar_CsvEscape(Vegar_ReasonText(block_reason));
   r += ","+Vegar_CsvEscape(opp.pipeline_state)+","+Vegar_CsvEscape(opp.daily_target_gate)+","+Vegar_CsvEscape(opp.daily_loss_gate)+","+Vegar_CsvEscape(opp.max_trades_gate)+","+Vegar_CsvEscape(opp.loss_streak_gate)+","+Vegar_CsvEscape(opp.position_gate)+","+Vegar_CsvEscape(opp.ownership_gate)+","+Vegar_CsvEscape(opp.market_gate)+","+Vegar_CsvEscape(opp.trading_permission_gate)+","+Vegar_CsvEscape(opp.margin_gate)+","+Vegar_CsvEscape(opp.stops_level_gate)+","+Vegar_CsvEscape(opp.freeze_level_gate)+","+Vegar_CsvEscape(opp.order_check_gate)+","+DoubleToString(opp.mss_required_level,gVegarSymbol.digits)+","+DoubleToString(opp.mss_best_observed,gVegarSymbol.digits)+","+DoubleToString(opp.mss_distance_missing,gVegarSymbol.digits)+","+DoubleToString(opp.displacement_required_range_ratio,6)+","+DoubleToString(opp.displacement_observed_range_ratio,6)+","+DoubleToString(opp.displacement_required_close_location,6)+","+DoubleToString(opp.displacement_observed_close_location,6);
   Vegar_CsvAppend("OPPORTUNITY_SNAPSHOT",h,r);
  }

void Vegar_WriteRiskState(const SVegarRiskSnapshot &risk,const SVegarOpportunity &opp,const string intent_id)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",Pass,Volume,StopEnabled,TechnicalStopPrice,TechnicalStopMoney,StopMoneyLimit,FreeMargin,MarginLevel,ProjectedMargin,ProjectedFreeMargin,SpreadPoints,SpreadTicks,SpreadMoney,SpreadTargetPercent,EconomicTargetMoney,ExpectedMoneyOpposite,DailyResult,TradesToday,ConsecutiveLosses,CommissionModelIncomplete,EstimatedRoundTurnCommission,EstimatedFee,EstimatedSwap,EstimatedTotalCosts,ExpectedRewardNet,DailyLossLimit,RealizedLoss,OpenWorstCaseRisk,EstimatedNewTradeWorstCase,DailyRemainingRisk";
   string r=Vegar_CommonPrefix(eid,opp.opportunity_id,opp.snapshot_id,opp.setup_id,opp.signal_id,intent_id,"RISK_STATE",risk.pass?"APPROVED":"BLOCKED",Vegar_ReasonText(risk.reason),"");
   r += ","+(risk.pass?"1":"0")+","+DoubleToString(risk.volume,8)+","+(InpAtivarStopLoss?"1":"0")+","+DoubleToString(risk.technical_stop_price,gVegarSymbol.digits)+","+DoubleToString(risk.technical_stop_money,6)+","+DoubleToString(InpStopLossMaximoMoney,6)+","+DoubleToString(risk.free_margin,6)+","+DoubleToString(risk.margin_level,6)+","+DoubleToString(risk.projected_margin,6)+","+DoubleToString(risk.projected_free_margin,6)+","+DoubleToString(risk.spread_points,4)+","+DoubleToString(risk.spread_ticks,4)+","+DoubleToString(risk.spread_money,6)+","+DoubleToString(risk.spread_target_percent,6)+","+DoubleToString(risk.economic_target_money,6)+","+DoubleToString(risk.expected_money_opposite,6)+","+DoubleToString(risk.daily_result,6)+","+(string)risk.trades_today+","+(string)risk.consecutive_losses+","+(risk.commission_model_incomplete?"1":"0")+","+DoubleToString(risk.estimated_round_turn_commission,6)+","+DoubleToString(risk.estimated_fee,6)+","+DoubleToString(risk.estimated_swap,6)+","+DoubleToString(risk.estimated_total_costs,6)+","+DoubleToString(risk.expected_reward_net,6)+","+DoubleToString(risk.daily_loss_limit,6)+","+DoubleToString(risk.realized_loss,6)+","+DoubleToString(risk.open_worst_case_risk,6)+","+DoubleToString(risk.estimated_new_trade_worst_case,6)+","+DoubleToString(risk.daily_remaining_risk,6);
   Vegar_CsvAppend("RISK_STATE",h,r);
  }

void Vegar_WriteProfitManagement(const SVegarProfitState &p,const string event)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",PositionTicket,PositionID,TradeCycleID,IntentIDRef,OpportunityIDRef,SetupIDRef,FocusZoneID,Direction,EntryPrice,Volume,FloatingProfit,Swap,CommissionEstimate,FeeEstimate,NetPnL,PeakKnown,PeakProfit,RunnerActive,ProtectedFloor,LastCommittedPeak,LastRunnerUpdate,LastServerSL,ProtectedFloorInstalled,BrokerTPRemovedForRunner,SoftwareExitRequested,ExitReason";
   string r=Vegar_CommonPrefix(eid,p.opportunity_id,"",p.setup_id,"",p.intent_id,event,p.active?"ACTIVE":"INACTIVE","NONE","");
   r += ","+(string)p.position_ticket+","+(string)p.position_id+","+Vegar_CsvEscape(p.trade_cycle_id)+","+Vegar_CsvEscape(p.intent_id)+","+Vegar_CsvEscape(p.opportunity_id)+","+Vegar_CsvEscape(p.setup_id)+","+Vegar_CsvEscape(p.focus_zone_id)+","+Vegar_CsvEscape(Vegar_BiasText(p.direction))+","+DoubleToString(p.entry_price,gVegarSymbol.digits)+","+DoubleToString(p.volume,8)+","+DoubleToString(p.current_profit_money,6)+","+DoubleToString(p.current_swap_money,6)+","+DoubleToString(p.current_commission_money,6)+","+DoubleToString(p.current_fee_money,6)+","+DoubleToString(p.current_net_profit_money,6)+","+(p.peak_known?"1":"0")+","+DoubleToString(p.peak_profit_money,6)+","+(p.runner_active?"1":"0")+","+DoubleToString(p.protected_profit_money,6)+","+DoubleToString(p.last_committed_peak,6)+","+Vegar_CsvEscape(Vegar_TimeIso(p.last_runner_update))+","+DoubleToString(p.last_server_sl,gVegarSymbol.digits)+","+(p.protected_floor_installed?"1":"0")+","+(p.broker_tp_removed_for_runner?"1":"0")+","+(p.software_exit_requested?"1":"0")+","+Vegar_CsvEscape(p.exit_reason);
   Vegar_CsvAppend("PROFIT_MANAGEMENT",h,r);
  }

void Vegar_WriteExecution(const string event,const SVegarIntent &intent,const SVegarExecutionResult &x)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",Direction,Volume,EntryPrice,StopEnabled,StopPrice,TakeProfitPrice,PreflightOK,OrderCheckCalled,OrderSendCalled,RequestAccepted,OrderCheckRetcode,OrderCheckComment,TradeRetcode,TradeComment,OrderTicket,DealTicket,RequestedPrice,FillPrice,RequestHash,RequestFrozen,StopMoneyFinal,TPMoneyFinal,EstimatedCosts,EconomicSpreadMoney,ExpectedRewardNet";
   string r=Vegar_CommonPrefix(eid,intent.opportunity_id,intent.snapshot_id,intent.setup_id,intent.signal_id,intent.intent_id,event,x.request_accepted?"ACCEPTED":"REJECTED",Vegar_ReasonText(x.reason),"");
   r += ","+Vegar_CsvEscape(Vegar_BiasText(intent.direction))+","+DoubleToString(intent.requested_volume,8)+","+DoubleToString(intent.entry_price,gVegarSymbol.digits)+","+(InpAtivarStopLoss?"1":"0")+","+DoubleToString(intent.stop_price,gVegarSymbol.digits)+","+DoubleToString(intent.take_profit_price,gVegarSymbol.digits)+","+(x.preflight_ok?"1":"0")+","+(x.order_check_called?"1":"0")+","+(x.order_send_called?"1":"0")+","+(x.request_accepted?"1":"0")+","+(string)x.order_check_retcode+","+Vegar_CsvEscape(x.order_check_comment)+","+(string)x.trade_retcode+","+Vegar_CsvEscape(x.trade_comment)+","+(string)x.order_ticket+","+(string)x.deal_ticket+","+DoubleToString(x.requested_price,gVegarSymbol.digits)+","+DoubleToString(x.fill_price,gVegarSymbol.digits)+","+Vegar_CsvEscape(x.request_hash)+","+(x.request_frozen?"1":"0")+","+DoubleToString(x.stop_money_final,6)+","+DoubleToString(x.tp_money_final,6)+","+DoubleToString(x.estimated_costs,6)+","+DoubleToString(x.economic_spread_money,6)+","+DoubleToString(x.expected_reward_net,6);
   Vegar_CsvAppend("EXECUTION",h,r);
  }

void Vegar_WriteTradeLifecycle(const string event,const ulong order_ticket,const ulong deal_ticket,const ulong position_ticket,const long position_id,const string detail)
  {
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",OrderTicket,DealTicket,PositionTicket,PositionID,TradeCycleID,NetPnL,Detail";
   string r=Vegar_CommonPrefix(eid,"","","","","",event,"LIFECYCLE","NONE","")+","+(string)order_ticket+","+(string)deal_ticket+","+(string)position_ticket+","+(string)position_id+","+Vegar_CsvEscape("TC_"+(string)position_id)+","+DoubleToString(Vegar_TradeCycleNetPnL(position_id),8)+","+Vegar_CsvEscape(detail);
   Vegar_CsvAppend("TRADE_LIFECYCLE",h,r);
  }

string Vegar_MarkerColorText(const ENUM_VEGAR_MARKER_CLASS c)
  {
   if(c==VEGAR_MARKER_VALID_BUY) return "GREEN_CYAN";
   if(c==VEGAR_MARKER_VALID_SELL) return "RED_ORANGE";
   if(c==VEGAR_MARKER_BLOCKED_BUY || c==VEGAR_MARKER_BLOCKED_SELL) return "YELLOW";
   if(c==VEGAR_MARKER_OBSERVATION_BUY || c==VEGAR_MARKER_OBSERVATION_SELL) return "OBS_LIGHT_BLUE";
   return "NONE";
  }

void Vegar_WriteSignalMarker(const SVegarSignalMarker &m,const SVegarOpportunity &opp,const SVegarFlowSnapshot &closed_flow,const SVegarFlowSnapshot &live_flow,const SVegarChannel &channel,
                             const double spread_money,const double spread_target_percent,const string opposite_id,const double opposite_price,const double expected_money)
  {
   double strength=opp.focus_zone_strength;
   string role=Vegar_ZoneRoleText(m.zone_role);
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",MarkerID,CandidateID,MarkerOpportunityID,SetupFamily,MarkerSetupID,MarkerSignalID,MarkerIntentID,MarkerSymbol,MarkerTF,SignalTime,SignalPrice,Direction,MarkerClass,MarkerColor,TechnicalSignalReady,ExecutionAuthorized,OperationalEligibleAtApproach,OperationalSignalReady,PreflightPassed,OrderSendCalled,OrderAccepted,DealConfirmed,ZoneID,ZoneRole,ZoneStrength,ContextGate,M5Gate,SessionGate,NewsGate,TargetSpaceGate,SpreadGate,RiskGate,PreflightGate,ChannelID,ChannelDirection,ChannelStrength,ChannelPositionPercent,ClosedFlowScore,ClosedFlowClass,LiveFlowScore,LiveFlowClass,M15Context,FailedGateCount,FailedGates,PrimaryReason,SpreadMoney,SpreadTargetPercent,TechnicalStopPrice,TechnicalStopMoney,OppositeLiquidityID,OppositeLiquidityPrice,ExpectedMoneyAtOppositeLiquidity,OrderTicket,DealTicket,PositionID,FinalState";
   string r=Vegar_CommonPrefix(eid,m.opportunity_id,"",m.setup_id,m.signal_id,m.intent_id,"SIGNAL_MARKER",m.final_state,Vegar_ReasonText(m.primary_reason),"");
   r += ","+Vegar_CsvEscape(m.marker_id)+","+Vegar_CsvEscape(m.candidate_id)+","+Vegar_CsvEscape(m.opportunity_id)+","+Vegar_CsvEscape(Vegar_SetupFamilyText(m.setup_family))+","+Vegar_CsvEscape(m.setup_id)+","+Vegar_CsvEscape(m.signal_id)+","+Vegar_CsvEscape(m.intent_id)+","+Vegar_CsvEscape(m.symbol)+","+Vegar_CsvEscape(Vegar_TFText(m.tf))+","+Vegar_CsvEscape(Vegar_TimeIso(m.signal_time))+","+DoubleToString(m.signal_price,gVegarSymbol.digits)+","+Vegar_CsvEscape(Vegar_BiasText(m.direction))+","+Vegar_CsvEscape(Vegar_MarkerClassText(m.marker_class))+","+Vegar_CsvEscape(Vegar_MarkerColorText(m.marker_class));
   r += ","+(m.technical_signal_ready?"1":"0")+","+(m.execution_authorized?"1":"0")+","+(m.operational_eligible_at_approach?"1":"0")+","+(m.operational_signal_ready?"1":"0")+","+(m.preflight_passed?"1":"0")+","+(m.order_send_called?"1":"0")+","+(m.order_accepted?"1":"0")+","+(m.deal_confirmed?"1":"0")+","+Vegar_CsvEscape(m.zone_id)+","+Vegar_CsvEscape(role)+","+DoubleToString(strength,6);
   r += ","+Vegar_CsvEscape(m.context_gate)+","+Vegar_CsvEscape(m.m5_gate)+","+Vegar_CsvEscape(m.session_gate)+","+Vegar_CsvEscape(m.news_gate)+","+Vegar_CsvEscape(m.target_space_gate)+","+Vegar_CsvEscape(m.spread_gate)+","+Vegar_CsvEscape(m.risk_gate)+","+Vegar_CsvEscape(m.preflight_gate);
   r += ","+Vegar_CsvEscape(channel.id)+","+Vegar_CsvEscape(Vegar_ChannelText(channel.direction))+","+DoubleToString(channel.strength_score,6)+","+DoubleToString(channel.current_price_position_percent,6)+","+DoubleToString(closed_flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(closed_flow.flow_class))+","+DoubleToString(live_flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(live_flow.flow_class))+","+Vegar_CsvEscape(Vegar_M15ContextText(gVegarM15Context));
   r += ","+(string)m.failed_gate_count+","+Vegar_CsvEscape(m.failed_gates)+","+Vegar_CsvEscape(Vegar_ReasonText(m.primary_reason))+","+DoubleToString(spread_money,6)+","+DoubleToString(spread_target_percent,6)+","+DoubleToString(opp.technical_stop,gVegarSymbol.digits)+","+DoubleToString(opp.technical_stop_money,6)+","+Vegar_CsvEscape(opposite_id)+","+DoubleToString(opposite_price,gVegarSymbol.digits)+","+DoubleToString(expected_money,6)+","+(string)m.order_ticket+","+(string)m.deal_ticket+","+(string)m.position_id+","+Vegar_CsvEscape(m.final_state);
   Vegar_CsvAppend("SIGNAL_MARKERS",h,r);
  }

void Vegar_WriteMomentState(const double velocity_points_sec,const double velocity_atr_min,const string nearest_op_id,const double nearest_op_atr,const string nearest_obs_id,const double nearest_obs_atr,const SVegarFlowSnapshot &closed_flow,const SVegarFlowSnapshot &live_flow,const SVegarChannel &channel)
  {
   if(!Vegar_UpdateTick()) return;
   MqlRates b; if(!Vegar_GetBar(Vegar_ExecutionTF(),0,b)) return;
   double mid=(gVegarTick.bid+gVegarTick.ask)*0.5,range=b.high-b.low,atr=Vegar_ATR(Vegar_ExecutionTF(),1);
   double bodyRatio=(range>0?MathAbs(gVegarTick.bid-b.open)/range:0),closeLoc=(range>0?(gVegarTick.bid-b.low)/range:0),liveRangeATR=(atr>0?range/atr:0);
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",Bid,Ask,Mid,SpreadPoints,SpreadTicks,SpreadMoney,LiveCandleOpen,LiveCandleHigh,LiveCandleLow,CurrentPrice,LiveRangeATR,LiveBodyRatio,LiveCloseLocation,ClosedFlowScore,ClosedFlowClass,LiveFlowScore,LiveFlowClass,NearestOperationalZoneID,NearestOperationalDistanceATR,NearestObservationZoneID,NearestObservationDistanceATR,ChannelID,ChannelPositionPercent,DistanceUpperRailATR,DistanceLowerRailATR,PriceVelocityPointsPerSecond,PriceVelocityATRPerMinute,DecisionAuthority";
   string r=Vegar_CommonPrefix(eid,"","","","","","MOMENT_STATE","OBSERVATION","NONE","");
   r += ","+DoubleToString(gVegarTick.bid,gVegarSymbol.digits)+","+DoubleToString(gVegarTick.ask,gVegarSymbol.digits)+","+DoubleToString(mid,gVegarSymbol.digits)+","+DoubleToString(Vegar_CurrentSpreadPoints(),4)+","+DoubleToString(Vegar_CurrentSpreadTicks(),4)+","+DoubleToString(Vegar_SpreadMoney(InpLoteOperacional),6)+","+DoubleToString(b.open,gVegarSymbol.digits)+","+DoubleToString(b.high,gVegarSymbol.digits)+","+DoubleToString(b.low,gVegarSymbol.digits)+","+DoubleToString(gVegarTick.bid,gVegarSymbol.digits)+","+DoubleToString(liveRangeATR,6)+","+DoubleToString(bodyRatio,6)+","+DoubleToString(closeLoc,6);
   r += ","+DoubleToString(closed_flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(closed_flow.flow_class))+","+DoubleToString(live_flow.flow_score,6)+","+Vegar_CsvEscape(Vegar_FlowClassText(live_flow.flow_class))+","+Vegar_CsvEscape(nearest_op_id)+","+DoubleToString(nearest_op_atr,6)+","+Vegar_CsvEscape(nearest_obs_id)+","+DoubleToString(nearest_obs_atr,6)+","+Vegar_CsvEscape(channel.id)+","+DoubleToString(channel.current_price_position_percent,6)+","+DoubleToString(channel.distance_upper_rail_atr,6)+","+DoubleToString(channel.distance_lower_rail_atr,6)+","+DoubleToString(velocity_points_sec,6)+","+DoubleToString(velocity_atr_min,6)+",0";
   Vegar_CsvAppend("MOMENT_STATE",h,r);
  }

void Vegar_WriteIntrabarTrace(const string opportunity_id,const ENUM_VEGAR_SETUP_STATE state)
  {
   if(!InpAtivarIntrabarTrace || opportunity_id=="" || !Vegar_UpdateTick()) return;
   string eid=Vegar_NextID("EV");
   string h=Vegar_CommonHeader()+",TimeMsc,Bid,Ask,Last,Spread,VolumeReal,TickFlags,TraceOpportunityID,TraceSetupState";
   string r=Vegar_CommonPrefix(eid,opportunity_id,"","","","","INTRABAR_TRACE",Vegar_SetupStateText(state),"NONE","");
   r += ","+(string)gVegarTick.time_msc+","+DoubleToString(gVegarTick.bid,gVegarSymbol.digits)+","+DoubleToString(gVegarTick.ask,gVegarSymbol.digits)+","+DoubleToString(gVegarTick.last,gVegarSymbol.digits)+","+DoubleToString(Vegar_CurrentSpreadPrice(),Vegar_TelemetryPricePrecision())+","+DoubleToString(gVegarTick.volume_real,6)+","+(string)gVegarTick.flags+","+Vegar_CsvEscape(opportunity_id)+","+Vegar_CsvEscape(Vegar_SetupStateText(state));
   Vegar_CsvAppend("INTRABAR_TRACE",h,r);
  }

void Vegar_FlushCsv()
  {
   Vegar_WriteDiagnostic("CSV_FLUSH","OK","NONE","","Append writers flushed per write");
  }

#endif
