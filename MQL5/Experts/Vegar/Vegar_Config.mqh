#ifndef __VEGAR_CONFIG_MQH__
#define __VEGAR_CONFIG_MQH__

#include "Vegar_Types.mqh"

// RC9: nivel de confirmacao do MSS.
// ESTRUTURAL = comportamento RC8: ultimo pivo 2/2 confirmado ANTES do sweep.
//   Nos dados de 22-24/09 esse nivel ficou em mediana 2,7 ATR do preco,
//   8 velas atras, com prazo de 5 velas M1: 0 de 20 sweeps confirmaram.
// INTERNO    = pivo 1/1 mais recente dentro de InpMSSMaxDistanciaATR do
//   extremo do sweep; sem pivo nessa faixa, usa a maxima/minima da vela
//   do sweep e da anterior (quebra da estrutura interna do M1/M5).
enum ENUM_VEGAR_MSS_MODE
  {
   VEGAR_MSS_ESTRUTURAL=0,   // Estrutural (RC8)
   VEGAR_MSS_INTERNO=1       // Interno (RC9)
  };

input group "=== IDENTIFICAÇÃO E EXECUÇÃO ==="
input long   InpMagicNumber=VEGAR_DEFAULT_MAGIC;                    // Magic Number
input double InpLoteOperacional=0.01;                               // Lote Operacional

input group "=== ESTRATÉGIA ==="
input int    InpForcaMinimaZona=40;                                 // Força Mínima da Zona (0-100)
input double InpEqualToleranceATR=0.10;                              // Tolerância Equal High/Low por ATR
input double InpZoneWidthATR=0.05;                                  // Espessura da Zona por ATR
input double InpApproachDistanceATR=0.35;                            // Distância de Aproximação por ATR
input double InpMinSweepATR=0.03;                                   // Penetração Mínima do Sweep por ATR
input double InpMaxSweepATR=0.60;                                   // Penetração Máxima do Sweep por ATR
input double InpMSSBufferATR=0.02;                                  // Buffer de confirmação MSS por ATR
input double InpMinFVGATR=0.05;                                     // Tamanho mínimo FVG por ATR
input int    InpMaxBarsSweepToMSS=5;                                // Máximo de Candles Sweep → MSS
input ENUM_VEGAR_MSS_MODE InpModoMSS=VEGAR_MSS_INTERNO;              // Nível do MSS (Interno=RC9, Estrutural=RC8)
input double InpMSSMaxDistanciaATR=1.5;                              // MSS Interno: distância máx. do sweep por ATR
input int    InpMaxBarsMssToDisplacement=2;                          // Máximo de Candles MSS → Deslocamento (RC8=1)
input double InpDisplacementRangeMult=1.5;                           // Deslocamento: range mínimo x média 20 (RC8=2.0)
input int    InpMaxBarsMssToRetest=6;                               // Máximo de Candles MSS → Reteste
input bool   InpConfirmarM5QuandoM1=true;                            // Confirmar M5 quando operar M1
input bool   InpAtivarMicroContinuacaoOperacional=true;               // RC8: segunda familia operacional, subordinada ao M15

input group "=== SESSÕES ==="
input bool   InpAtivarFiltroDeSessao=false;                          // Ativar filtro de sessão; false = sessão livre
input bool   InpOperarLondon=true;                                  // Operar London
input string InpInicioLondonNY="03:00";                             // Início London (horário NY)
input string InpFimLondonNY="05:00";                                // Fim London (horário NY)
input bool   InpOperarNewYork=true;                                 // Operar New York
input string InpInicioNewYorkNY="08:30";                            // Início New York (horário NY)
input string InpFimNewYorkNY="11:00";                               // Fim New York (horário NY)

input group "=== NOTÍCIAS ==="
input bool   InpAtivarFiltroNoticias=true;                           // Ativar Filtro de Notícias
input int    InpImpactoMinimo=3;                                    // Impacto Mínimo (3=High no calendário MT5)
input int    InpMinutosAntes=30;                                    // Minutos Antes
input int    InpMinutosDepois=30;                                   // Minutos Depois
input bool   InpPerfilAutomaticoMetais=false;                         // Perfil Automático para Metais
input int    InpMetaisMinutosAntes=60;                              // Metais: minutos antes
input int    InpMetaisMinutosDepois=60;                             // Metais: minutos depois
input string InpTesterNewsFile="VEGAR_NEWS_HISTORY.csv";             // Histórico determinístico de notícias no Tester

input group "=== GERENCIAMENTO DE RISCO ==="
input bool   InpAtivarStopLoss=true;                                // Ativar Stop Loss inicial broker-side
input double InpStopLossMaximoMoney=0.00;                            // Stop Loss Máximo em Dinheiro (0=não configurado)
input double InpStopBufferATR=0.10;                                  // Buffer Técnico do Stop por ATR
input int    InpMaxTradesPerDay=2;                                  // Máximo de Operações por Dia
input int    InpMaxConsecutiveLosses=2;                              // Máximo de Perdas Consecutivas
input double InpLimitePerdaDiariaMoney=0.00;                         // Limite de Perda Diária em Dinheiro (0=desativado)
input double InpMargemMinimaPermitidaPct=0.0;                      // Margem Mínima Permitida (%)
input double InpMaxSpreadTargetPercent=15.0;                         // Custo Máximo do Spread Sobre a Meta (%)
input int    InpDesvioMaxExecucaoTicks=0;                            // Desvio Máximo de Execução em Ticks
input double InpComissaoRoundTurnPorLoteMoney=0.00;                  // Comissão round-turn por lote; 0=modelo indefinido

input group "=== GERENCIAMENTO DE PROFIT ==="
input bool   InpAtivarMetaOperacao=false;                            // Ativar Meta por Operação
input double InpMetaOperacaoMoney=0.00;                              // Meta por Operação em Dinheiro
input ENUM_VEGAR_PROFIT_MODE InpModoGestaoLucro=VEGAR_PROFIT_TAKE_PROFIT_E_RUNNER; // Modo de Gestão de Lucro
input bool   InpAtivarTakeProfit=false;                              // Ativar Take Profit
input double InpTakeProfitMoney=0.00;                                // Take Profit em Dinheiro
input bool   InpAtivarMetaDiaria=false;                              // Ativar Meta Diária
input double InpMetaDiariaMoney=0.00;                                // Meta Diária em Dinheiro
input bool   InpAtivarRunner=false;                                  // Ativar Runner
input double InpLucroParaAtivarRunner=0.00;                          // Lucro para Ativar Runner
input double InpLucroInicialProtegido=0.00;                          // Lucro Inicial Protegido
input double InpDistanciaRunnerMoney=0.00;                           // Distância do Runner em Dinheiro
input double InpPassoRunnerMoney=0.00;                               // Passo de Atualização do Runner

input group "=== VISUALIZAÇÃO ==="
input bool   InpExibirZonas=true;                                    // Exibir Zonas
input bool   InpExibirCanais=true;                                   // Exibir Canais
input bool   InpExibirCanalH4=true;                                  // Exibir Canal H4
input bool   InpExibirCanalM15=true;                                 // Exibir Canal M15
input bool   InpExibirForca=true;                                    // Exibir Força
input bool   InpExibirFluxo=true;                                    // Exibir Fluxo
input bool   InpExibirFVG=true;                                      // Exibir FVG
input bool   InpExibirOrderBlock=true;                               // Exibir Order Block
input bool   InpExibirEventos=true;                                  // Exibir Eventos
input bool   InpExibirZonaFoco=true;                                 // Exibir Zona em Foco
input bool   InpExibirZonasInvalidadas=false;                        // Exibir Zonas Invalidadas
input int    InpMaxZonasAcima=2;                                     // Máximo de Zonas Acima
input int    InpMaxZonasAbaixo=2;                                    // Máximo de Zonas Abaixo
input int    InpTransparenciaZonas=70;                               // Transparência das Zonas (0-100)
input int    InpTamanhoFonte=9;                                      // Tamanho da Fonte
input int    InpEscalaPainelPct=100;                                  // Escala do Painel (%) - baseline 100
input int    InpOpacidadePainelPercent=90;                               // Opacidade do Painel (%) - faixa 75..100
input bool   InpExibirLinhaCentralCanal=true;                          // Exibir linha central do canal (visual)
input bool   InpExibirMicroLiquidezObservacional=true;                 // Exibir microliquidez M1/M5 (operacional quando alinhada ao M15)
input int    InpMaxSignalMarkersOnChart=100;                            // Máximo de setas históricas visíveis
input int    InpSweptMarkerCandles=30;                                  // Candles para manter marcador discreto de zona consumida
input bool   InpExibirZonasFracasObservacionais=false;                   // Mostrar zona abaixo da força mínima apenas como linha observacional

input group "=== CSV E DIAGNÓSTICO ==="
input bool   InpAtivarCSV=true;                                      // Ativar CSV
input int    InpTamanhoMaxArquivoMB=50;                              // Tamanho Máximo por Arquivo MB
input bool   InpAtivarOpportunityReplay=true;                        // Ativar Opportunity Replay
input int    InpHorizonteReplayCandles=30;                           // Horizonte do Replay em Candles
input bool   InpAtivarIntrabarTrace=false;                           // Ativar Intrabar Trace
input int    InpCandlesPosEventoIntrabar=2;                          // Candles Pós-Evento do Intrabar
input int    InpFlushIntervalSeconds=5;                              // Flush Interval em segundos
input int    InpNivelLog=2;                                         // Nível de Log: 0 mínimo, 1 normal, 2 detalhado
input bool   InpExecutarSelfTests=true;                              // Executar self-tests determinísticos no OnInit
input int    InpObjectHeartbeatMinutes=15;                             // Heartbeat opcional de objetos ativos (0=off)


string gVegarConfigHash="";
string gVegarStrategyConfigHash="";
string gVegarTelemetryConfigHash="";
string gVegarVisualConfigHash="";
ENUM_VEGAR_CONFIG_VALIDITY gVegarConfigValidity=VEGAR_CONFIG_INVALID;
ENUM_VEGAR_REASON_CODE gVegarConfigReason=CONFIG_INVALID_GENERAL;
string gVegarConfigDetail="";

ENUM_VEGAR_ENVIRONMENT gVegarEnvironment=VEGAR_ENV_UNSUPPORTED;
ENUM_VEGAR_ENGINE_STATE gVegarEngineState=VEGAR_ENGINE_ACTIVE;
ENUM_VEGAR_EXECUTION_STATE gVegarExecutionState=VEGAR_EXECUTION_BLOCKED_CONFIGURATION;
ENUM_VEGAR_REASON_CODE gVegarExecutionReason=EXECUTION_BLOCKED_CONFIGURATION;
string gVegarExecutionDetail="";
long gVegarAccountTradeMode=-1;
bool gVegarIsTester=false;
bool gVegarIsOptimization=false;

bool Vegar_DetectEnvironment()
  {
   gVegarIsTester=(bool)MQLInfoInteger(MQL_TESTER);
   gVegarIsOptimization=(bool)MQLInfoInteger(MQL_OPTIMIZATION);
   gVegarAccountTradeMode=AccountInfoInteger(ACCOUNT_TRADE_MODE);

   if(gVegarIsTester)
     {
      gVegarEnvironment=VEGAR_ENV_TESTER;
      return true;
     }

   ENUM_ACCOUNT_TRADE_MODE mode=(ENUM_ACCOUNT_TRADE_MODE)gVegarAccountTradeMode;
   if(mode==ACCOUNT_TRADE_MODE_DEMO)
     {
      gVegarEnvironment=VEGAR_ENV_DEMO;
      return true;
     }
   if(mode==ACCOUNT_TRADE_MODE_REAL)
     {
      gVegarEnvironment=VEGAR_ENV_REAL;
      return true;
     }

   gVegarEnvironment=VEGAR_ENV_UNSUPPORTED;
   return false;
  }

bool Vegar_ParseHHMM(const string s,int &minutes)
  {
   int p=StringFind(s,":");
   if(p<1) return false;
   int hh=(int)StringToInteger(StringSubstr(s,0,p));
   int mm=(int)StringToInteger(StringSubstr(s,p+1));
   if(hh<0 || hh>23 || mm<0 || mm>59) return false;
   minutes=hh*60+mm;
   return true;
  }

string Vegar_StrategyCanonicalString()
  {
   string s="";
   s += "Magic="+(string)InpMagicNumber+"|Lot="+DoubleToString(InpLoteOperacional,8)+"|";
   s += "ZoneMin="+(string)InpForcaMinimaZona+"|EqATR="+DoubleToString(InpEqualToleranceATR,8)+"|ZoneATR="+DoubleToString(InpZoneWidthATR,8)+"|Approach="+DoubleToString(InpApproachDistanceATR,8)+"|";
   s += "SweepMin="+DoubleToString(InpMinSweepATR,8)+"|SweepMax="+DoubleToString(InpMaxSweepATR,8)+"|MSSBuf="+DoubleToString(InpMSSBufferATR,8)+"|FVG="+DoubleToString(InpMinFVGATR,8)+"|StopBuf="+DoubleToString(InpStopBufferATR,8)+"|";
   s += "BarsSM="+(string)InpMaxBarsSweepToMSS+"|MSSMode="+(string)(int)InpModoMSS+"|MSSMaxDist="+DoubleToString(InpMSSMaxDistanciaATR,8)+"|BarsMD="+(string)InpMaxBarsMssToDisplacement+"|DispMult="+DoubleToString(InpDisplacementRangeMult,8)+"|BarsMR="+(string)InpMaxBarsMssToRetest+"|M5="+(InpConfirmarM5QuandoM1?"1":"0")+"|MicroOp="+(InpAtivarMicroContinuacaoOperacional?"1":"0")+"|";
   if(InpAtivarFiltroDeSessao)
      s += "SessionFilter=1|Lon="+(InpOperarLondon?"1":"0")+InpInicioLondonNY+InpFimLondonNY+"|NY="+(InpOperarNewYork?"1":"0")+InpInicioNewYorkNY+InpFimNewYorkNY+"|";
   else
      s += "SessionFilter=0|";
   s += "News="+(InpAtivarFiltroNoticias?"1":"0")+"|Imp="+(string)InpImpactoMinimo+"|NB="+(string)InpMinutosAntes+"|NA="+(string)InpMinutosDepois+"|MetalAuto="+(InpPerfilAutomaticoMetais?"1":"0")+"|MB="+(string)InpMetaisMinutosAntes+"|MA="+(string)InpMetaisMinutosDepois+"|TesterNewsFile="+InpTesterNewsFile+"|";
   s += "StopEnabled="+(InpAtivarStopLoss?"1":"0")+"|StopMoney="+DoubleToString(InpStopLossMaximoMoney,8)+"|MaxTrades="+(string)InpMaxTradesPerDay+"|LossStreak="+(string)InpMaxConsecutiveLosses+"|DailyLoss="+DoubleToString(InpLimitePerdaDiariaMoney,8)+"|MinMargin="+DoubleToString(InpMargemMinimaPermitidaPct,8)+"|SpreadTarget="+DoubleToString(InpMaxSpreadTargetPercent,8)+"|Dev="+(string)InpDesvioMaxExecucaoTicks+"|Comm="+DoubleToString(InpComissaoRoundTurnPorLoteMoney,8)+"|";
   s += "OpTargetOn="+(InpAtivarMetaOperacao?"1":"0")+"|OpTarget="+DoubleToString(InpMetaOperacaoMoney,8)+"|ProfitMode="+(string)(int)InpModoGestaoLucro+"|TPOn="+(InpAtivarTakeProfit?"1":"0")+"|TP="+DoubleToString(InpTakeProfitMoney,8)+"|";
   s += "DailyTargetOn="+(InpAtivarMetaDiaria?"1":"0")+"|DailyTarget="+DoubleToString(InpMetaDiariaMoney,8)+"|RunnerOn="+(InpAtivarRunner?"1":"0")+"|RunnerActivation="+DoubleToString(InpLucroParaAtivarRunner,8)+"|RunnerProtected="+DoubleToString(InpLucroInicialProtegido,8)+"|RunnerDistance="+DoubleToString(InpDistanciaRunnerMoney,8)+"|RunnerStep="+DoubleToString(InpPassoRunnerMoney,8);
   return s;
  }

string Vegar_TelemetryCanonicalString()
  {
   string s="";
   s += "CSV="+(InpAtivarCSV?"1":"0")+"|MaxMB="+(string)InpTamanhoMaxArquivoMB+"|Replay="+(InpAtivarOpportunityReplay?"1":"0")+"|Horizon="+(string)InpHorizonteReplayCandles+"|";
   s += "Trace="+(InpAtivarIntrabarTrace?"1":"0")+"|TracePost="+(string)InpCandlesPosEventoIntrabar+"|Flush="+(string)InpFlushIntervalSeconds+"|Log="+(string)InpNivelLog+"|SelfTests="+(InpExecutarSelfTests?"1":"0")+"|Heartbeat="+(string)InpObjectHeartbeatMinutes;
   return s;
  }

string Vegar_VisualCanonicalString()
  {
   string s="";
   s += "Zones="+(InpExibirZonas?"1":"0")+"|Channels="+(InpExibirCanais?"1":"0")+"|H4="+(InpExibirCanalH4?"1":"0")+"|M15="+(InpExibirCanalM15?"1":"0")+"|";
   s += "Strength="+(InpExibirForca?"1":"0")+"|Flow="+(InpExibirFluxo?"1":"0")+"|FVG="+(InpExibirFVG?"1":"0")+"|OB="+(InpExibirOrderBlock?"1":"0")+"|Events="+(InpExibirEventos?"1":"0")+"|Focus="+(InpExibirZonaFoco?"1":"0")+"|";
   s += "Invalid="+(InpExibirZonasInvalidadas?"1":"0")+"|Above="+(string)InpMaxZonasAcima+"|Below="+(string)InpMaxZonasAbaixo+"|ZoneAlpha="+(string)InpTransparenciaZonas+"|Font="+(string)InpTamanhoFonte+"|PanelScale="+(string)InpEscalaPainelPct+"|PanelOpacity="+(string)InpOpacidadePainelPercent+"|CenterLine="+(InpExibirLinhaCentralCanal?"1":"0")+"|ObsMicro="+(InpExibirMicroLiquidezObservacional?"1":"0")+"|Markers="+(string)InpMaxSignalMarkersOnChart+"|SweptBars="+(string)InpSweptMarkerCandles+"|WeakObs="+(InpExibirZonasFracasObservacionais?"1":"0");
   return s;
  }

string Vegar_ConfigCanonicalString()
  {
   return Vegar_StrategyCanonicalString();
  }

string Vegar_Fnv1a64Hex(const string text_value)
  {
   ulong h=1469598103934665603;
   uchar bytes[];
   StringToCharArray(text_value,bytes,0,WHOLE_ARRAY,CP_UTF8);
   int n=ArraySize(bytes);
   if(n>0 && bytes[n-1]==0) n--;
   for(int i=0;i<n;i++)
     {
      h ^= (ulong)bytes[i];
      h *= 1099511628211;
     }
   return StringFormat("%016I64X",h);
  }

string Vegar_ComputeHash(const string canonical)
  {
   return "FNV1A64-"+Vegar_Fnv1a64Hex(canonical);
  }

string Vegar_ComputeConfigHash()
  {
   return Vegar_ComputeHash(Vegar_StrategyCanonicalString());
  }

void Vegar_RefreshConfigHashes()
  {
   gVegarStrategyConfigHash=Vegar_ComputeHash(Vegar_StrategyCanonicalString());
   gVegarTelemetryConfigHash=Vegar_ComputeHash(Vegar_TelemetryCanonicalString());
   gVegarVisualConfigHash=Vegar_ComputeHash(Vegar_VisualCanonicalString());
   gVegarConfigHash=gVegarStrategyConfigHash;
  }

ENUM_VEGAR_CONFIG_VALIDITY Vegar_ValidateConfiguration(ENUM_VEGAR_REASON_CODE &reason,string &detail)
  {
   reason=VEGAR_REASON_NONE;
   detail="OK";

   if(InpMagicNumber<=0 || InpLoteOperacional<=0.0 || InpForcaMinimaZona<0 || InpForcaMinimaZona>100 ||
      InpEqualToleranceATR<0.0 || InpZoneWidthATR<=0.0 || InpApproachDistanceATR<0.0 ||
      InpMinSweepATR<0.0 || InpMaxSweepATR<=InpMinSweepATR || InpMSSBufferATR<0.0 ||
      InpMinFVGATR<0.0 || InpStopBufferATR<0.0 || InpMaxBarsSweepToMSS<1 || InpMaxBarsMssToRetest<1 ||
      InpMSSMaxDistanciaATR<=0.0 || InpMaxBarsMssToDisplacement<1 || InpDisplacementRangeMult<=0.0 ||
      InpMaxTradesPerDay<1 || InpMaxConsecutiveLosses<1 || InpMargemMinimaPermitidaPct<0.0 ||
      InpMaxSpreadTargetPercent<=0.0 || InpDesvioMaxExecucaoTicks<0 || InpTamanhoMaxArquivoMB<1 ||
      InpHorizonteReplayCandles<1 || InpFlushIntervalSeconds<1 || InpMaxSignalMarkersOnChart<1 || InpSweptMarkerCandles<1 || InpEscalaPainelPct<70 || InpEscalaPainelPct>160 ||
      InpOpacidadePainelPercent<0 || InpOpacidadePainelPercent>100 || InpMaxSignalMarkersOnChart<1 ||
      InpObjectHeartbeatMinutes<0)
     {
      reason=CONFIG_INVALID_GENERAL;
      detail="INPUT_RANGE_INVALID";
      return VEGAR_CONFIG_INVALID;
     }

   int tmp=0;
   if(InpAtivarFiltroDeSessao)
     {
      if(!InpOperarLondon && !InpOperarNewYork)
        {
         reason=CONFIG_SESSION_INVALID;
         detail="FILTRO_SESSAO_ATIVO_SEM_JANELA_HABILITADA";
         return VEGAR_CONFIG_INVALID;
        }

      if((InpOperarLondon &&
          (!Vegar_ParseHHMM(InpInicioLondonNY,tmp) || !Vegar_ParseHHMM(InpFimLondonNY,tmp))) ||
         (InpOperarNewYork &&
          (!Vegar_ParseHHMM(InpInicioNewYorkNY,tmp) || !Vegar_ParseHHMM(InpFimNewYorkNY,tmp))))
        {
         reason=CONFIG_SESSION_INVALID;
         detail="SESSION_HHMM_INVALID";
         return VEGAR_CONFIG_INVALID;
        }
     }

   if(InpAtivarStopLoss && InpStopLossMaximoMoney<=0.0)
     {
      reason=CONFIG_STOP_MONEY_UNSET;
      detail="STOP LOSS ATIVO SEM LIMITE MONEY";
      return VEGAR_CONFIG_INVALID;
     }

   if(InpAtivarMetaOperacao && InpMetaOperacaoMoney<=0.0)
     {
      reason=CONFIG_OPERATION_TARGET_INVALID;
      detail="META_OPERACAO_ATIVA_SEM_VALOR";
      return VEGAR_CONFIG_INVALID;
     }
   if(InpAtivarTakeProfit && InpTakeProfitMoney<=0.0)
     {
      reason=CONFIG_TAKE_PROFIT_INVALID;
      detail="TAKE_PROFIT_ATIVO_SEM_VALOR";
      return VEGAR_CONFIG_INVALID;
     }
   if(InpAtivarMetaDiaria && InpMetaDiariaMoney<=0.0)
     {
      reason=CONFIG_DAILY_TARGET_INVALID;
      detail="META_DIARIA_ATIVA_SEM_VALOR";
      return VEGAR_CONFIG_INVALID;
     }
   if(InpAtivarRunner)
     {
      if(InpLucroParaAtivarRunner<=0.0 || InpLucroInicialProtegido<=0.0 ||
         InpDistanciaRunnerMoney<=0.0 || InpPassoRunnerMoney<=0.0 ||
         InpLucroInicialProtegido>=InpLucroParaAtivarRunner)
        {
         reason=CONFIG_RUNNER_INVALID;
         detail="RUNNER_PARAMETROS_INVALIDOS";
         return VEGAR_CONFIG_INVALID;
        }
     }

   if(!InpAtivarTakeProfit && !InpAtivarRunner)
     {
      reason=CONFIG_PROFIT_EXIT_UNSET;
      detail="SAIDA POSITIVA NAO CONFIGURADA";
      return VEGAR_CONFIG_INVALID;
     }

   if(InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT && !InpAtivarTakeProfit)
     {
      reason=CONFIG_PROFIT_MODE_CONFLICT;
      detail="MODO_TP_EXIGE_TP_ATIVO";
      return VEGAR_CONFIG_INVALID;
     }
   if(InpModoGestaoLucro==VEGAR_PROFIT_RUNNER && !InpAtivarRunner)
     {
      reason=CONFIG_PROFIT_MODE_CONFLICT;
      detail="MODO_RUNNER_EXIGE_RUNNER_ATIVO";
      return VEGAR_CONFIG_INVALID;
     }
   if(InpModoGestaoLucro==VEGAR_PROFIT_TAKE_PROFIT_E_RUNNER && (!InpAtivarTakeProfit || !InpAtivarRunner))
     {
      reason=CONFIG_PROFIT_MODE_CONFLICT;
      detail="MODO_TP_RUNNER_EXIGE_AMBOS_ATIVOS";
      return VEGAR_CONFIG_INVALID;
     }

   return VEGAR_CONFIG_VALID;
  }

void Vegar_SetExecutionState(const ENUM_VEGAR_EXECUTION_STATE state,const ENUM_VEGAR_REASON_CODE reason,const string detail)
  {
   gVegarExecutionState=state;
   gVegarExecutionReason=reason;
   gVegarExecutionDetail=detail;
  }

ENUM_VEGAR_EXECUTION_STATE Vegar_ExecutionStateForReason(const ENUM_VEGAR_REASON_CODE reason)
  {
   if(reason==CONFIG_STOP_MONEY_UNSET || reason==CONFIG_OPERATION_TARGET_INVALID || reason==CONFIG_TAKE_PROFIT_INVALID ||
      reason==CONFIG_DAILY_TARGET_INVALID || reason==CONFIG_RUNNER_INVALID || reason==CONFIG_PROFIT_EXIT_UNSET ||
      reason==CONFIG_PROFIT_MODE_CONFLICT || reason==CONFIG_INVALID_GENERAL || reason==CONFIG_SESSION_INVALID ||
      reason==EXECUTION_BLOCKED_CONFIGURATION)
      return VEGAR_EXECUTION_BLOCKED_CONFIGURATION;

   if(reason==SELF_TEST_FAILED) return VEGAR_EXECUTION_BLOCKED_SELF_TEST;
   if(reason==BLOCKED_RECOVERY) return VEGAR_EXECUTION_BLOCKED_RECOVERY;
   if(reason==BLOCKED_OWNERSHIP_AMBIGUOUS) return VEGAR_EXECUTION_BLOCKED_OWNERSHIP;
   if(reason==SESSION_BLOCKED) return VEGAR_EXECUTION_BLOCKED_SESSION;
   if(reason==NEWS_HIGH_IMPACT || reason==NEWS_DATA_UNAVAILABLE) return VEGAR_EXECUTION_BLOCKED_NEWS;
   if(reason==SPREAD_TOO_HIGH) return VEGAR_EXECUTION_BLOCKED_SPREAD;
   if(reason==DAILY_TARGET_REACHED || reason==DAILY_LOSS_REACHED || reason==MAX_TRADES_REACHED || reason==LOSS_STREAK_LOCK)
      return VEGAR_EXECUTION_BLOCKED_DAILY_LIMIT;
   if(reason==POSITION_EXISTS || reason==NETTING_EXTERNAL_POSITION || reason==POSITION_OWNERSHIP_AMBIGUOUS)
      return VEGAR_EXECUTION_BLOCKED_POSITION;
   if(reason==DATA_NOT_READY || reason==DATA_NOT_SYNCHRONIZED || reason==TIMEFRAME_NOT_ALLOWED)
      return VEGAR_EXECUTION_BLOCKED_DATA;
   if(reason==ACCOUNT_MODE_UNSUPPORTED || reason==ENVIRONMENT_DETECTION_FAILED || reason==EXECUTION_BLOCKED_ACCOUNT || reason==DUPLICATE_INSTANCE)
      return VEGAR_EXECUTION_BLOCKED_ACCOUNT;
   if(reason==MARKET_CLOSED || reason==STOPS_INVALID || reason==FREEZE_LEVEL_BLOCK)
      return VEGAR_EXECUTION_BLOCKED_MARKET;
   if(reason==TRADING_DISABLED || reason==AUTOTRADING_DISABLED || reason==ORDER_CHECK_REJECTED || reason==ORDER_SEND_REJECTED ||
      reason==ORDER_REQUEST_NOT_ALLOWED || reason==ENGINE_PAUSED)
      return VEGAR_EXECUTION_BLOCKED_EXECUTION;
   if(reason==STOP_MONEY_EXCEEDED || reason==TARGET_SPACE_INSUFFICIENT || reason==LOT_INVALID || reason==MARGIN_TOO_LOW ||
      reason==PRICE_INVALID || reason==ECONOMIC_TARGET_UNAVAILABLE)
      return VEGAR_EXECUTION_BLOCKED_RISK;
   return VEGAR_EXECUTION_BLOCKED_EXECUTION;
  }

void Vegar_SetExecutionBlockedByReason(const ENUM_VEGAR_REASON_CODE reason,const string detail)
  {
   Vegar_SetExecutionState(Vegar_ExecutionStateForReason(reason),reason,detail);
  }

bool Vegar_EnvironmentAllowsTrading()
  {
   return (gVegarEnvironment==VEGAR_ENV_TESTER || gVegarEnvironment==VEGAR_ENV_DEMO || gVegarEnvironment==VEGAR_ENV_REAL);
  }

bool Vegar_ConfigurationAllowsOrderSend()
  {
   return (gVegarConfigValidity==VEGAR_CONFIG_VALID &&
           gVegarEngineState==VEGAR_ENGINE_ACTIVE &&
           !gVegarCriticalSelfTestFailed &&
           Vegar_EnvironmentAllowsTrading());
  }

#endif
