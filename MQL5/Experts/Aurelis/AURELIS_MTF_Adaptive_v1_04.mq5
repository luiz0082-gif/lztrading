//+------------------------------------------------------------------+
//|                                               AURELIS_MTF_Adaptive_v1_01.mq5
//|  AURELIS - Adaptive market map / structure / region / trigger EA
//|  Specification baseline: AURELIS_Especificacao_Matematica_v1.0
//|  Platform: MetaTrader 5 / MQL5
//|  Design goal: deterministic, closed-bar, explainable execution with semantic direction gates
//+------------------------------------------------------------------+
#property strict
#property version   "1.11"
#property description "AURELIS - adaptive context, structure, regions and triggers for M1/M5/M15"
#property description "No external indicator dependency. Closed-bar decision engine. CSV telemetry."

#include <Trade/Trade.mqh>
#include <Canvas/Canvas.mqh>

CTrade trade;

//====================================================================
// ENUMERATIONS
//====================================================================
enum ENUM_AURELIS_PROFILE
  {
   PROFILE_AUTO = 0,
   PROFILE_M1   = 1,
   PROFILE_M5   = 5,
   PROFILE_M15  = 15
  };

enum ENUM_DAILY_TARGET_ACTION
  {
   DAILY_BLOCK_NEW_ENTRIES = 0,
   DAILY_CLOSE_AND_BLOCK   = 1,
   DAILY_NONE              = 2
  };

enum ENUM_TP_MODE
  {
   TP_STRUCTURE = 0,
   TP_RR        = 1,
   TP_MONEY     = 2,
   TP_HYBRID    = 3
  };

enum ENUM_SL_MODE
  {
   SL_STRUCTURAL = 0,
   SL_ATR        = 1,
   SL_HYBRID     = 2
  };

enum ENUM_EXIT_OPPOSITE
  {
   EXIT_OPPOSITE_DISABLED = 0,
   EXIT_OPPOSITE_SHIFT    = 1,
   EXIT_OPPOSITE_BOS      = 2
  };

enum ENUM_REGION_BIAS
  {
   REGION_NEUTRAL = 0,
   REGION_SUPPORT = 1,
   REGION_RESIST  = -1
  };

enum ENUM_REGIME
  {
   REGIME_TRANSITION = 0,
   REGIME_BULLISH    = 1,
   REGIME_BEARISH    = -1,
   REGIME_RANGE      = 2
  };

enum ENUM_VOL_REGIME
  {
   VOL_LOW    = 0,
   VOL_NORMAL = 1,
   VOL_HIGH   = 2
  };

enum ENUM_ACTION
  {
   ACTION_NO_TRADE = 0,
   ACTION_BUY      = 1,
   ACTION_SELL     = -1
  };

enum ENUM_TRIGGER_MODE
  {
   TRIGGER_STRICT   = 0,   // evento + reacao + estrutura + deslocamento (v1.03)
   TRIGGER_BALANCED = 1    // evento + reacao + (estrutura OU deslocamento)
  };

enum ENUM_TRAIL_MODE
  {
   TRAIL_OFF       = 0,   // Desligado
   TRAIL_MONEY_HWM = 1,   // Dinheiro (HWM por faixas)
   TRAIL_POINTS    = 2    // Pontos (distancia fixa)
  };

enum ENUM_STATS_PERIOD
  {
   STATS_DAY   = 0,   // Dia
   STATS_WEEK  = 1,   // Semana
   STATS_MONTH = 2    // Mes
  };

//====================================================================
// INPUTS - OFFICIAL V1.0 + INTERNAL CONTROL
//====================================================================
input group "AURELIS 01 | Perfil e timeframe de operacao"
input ENUM_AURELIS_PROFILE InpProfile = PROFILE_AUTO;  // Perfil (AUTO = opera o TF do grafico M1/M5/M15)
input long   InpMagicBase = 8401500;                   // Magic base (magic final = base + TF; cada TF tem o seu)
input bool   InpEnableTrading = true;                  // Abrir ordens (false = so analisa e desenha)

input group "AURELIS 02 | Permissao por timeframe (quem pode ABRIR ordens)"
// Cada grafico com o EA opera SOMENTE o timeframe dele. Se aparecerem ordens de outro TF, elas vem de outro
// grafico com o EA anexado (magic diferente). Use as opcoes abaixo para liberar/bloquear cada TF.
input bool   InpTradeOnM1  = true;    // Permitir abrir ordens quando o EA estiver no grafico M1
input bool   InpTradeOnM5  = true;    // Permitir abrir ordens quando o EA estiver no grafico M5
input bool   InpTradeOnM15 = true;    // Permitir abrir ordens quando o EA estiver no grafico M15
input bool   InpOneTradeAcrossTFs = true; // Bloquear entrada se OUTRO TF do AURELIS ja tem posicao neste simbolo

input group "AURELIS 03 | Visual, CSV e logs"
input bool   InpDrawMarketMap = true;      // Desenhar mapa de mercado no grafico
input bool   InpDrawGeometry = true;       // Desenhar geometria (swings/canais)
input bool   InpDrawRegions = true;        // Desenhar regioes
input bool   InpDrawLabels = true;         // Desenhar rotulos
input bool   InpDrawTradeMarkers = true;   // Marcar entradas no grafico
input bool   InpWriteCSV = true;           // Gravar telemetria CSV
input bool   InpPrintTechnicalLog = false; // Log tecnico detalhado no Experts
input bool   InpPrintDecisionLine = true;  // 1 linha no Experts por barra com o motivo da decisao

input group "AURELIS 04 | Dados e normalizacao"
input int    InpATRPeriod = 14;               // Periodo do ATR
input int    InpStructureLookbackBars = 180;  // Barras de estrutura
input int    InpRangeLookbackBars = 64;       // Barras de range
input int    InpSpreadSamples = 80;           // Amostras de spread
input double InpBreakBufferATR = 0.05;        // Buffer de rompimento (x ATR)
input double InpSweepMaxDepthATR = 0.40;      // Profundidade maxima do sweep (x ATR)
input double InpConfluenceATR = 0.12;         // Tolerancia de confluencia (x ATR)
input double InpRegionActivationATR = 0.15;   // Ativacao de regiao (x ATR)
input double InpZoneAlphaATR = 0.10;          // Espessura base da zona (x ATR)
input double InpZoneMaxATR = 0.35;            // Espessura maxima da zona (x ATR)
input double InpLineToleranceATR = 0.12;      // Tolerancia de linha (x ATR)
input double InpMinChannelWidthATR = 0.25;    // Largura minima do canal (x ATR)
input double InpMaxChannelWidthATR = 4.00;    // Largura maxima do canal (x ATR)
input double InpChannelSlopeTolerance = 0.35; // Tolerancia de inclinacao do canal
input double InpDecayBars = 120.0;            // Decaimento (barras)

input group "AURELIS 05 | Swing e estrutura"
input int    InpSwingFractalRadius = 2;       // Raio do fractal de swing
input double InpSwingExcursionATR = 0.50;     // Excursao minima do swing (x ATR)
input int    InpMaxSwingAgeBars = 120;        // Idade maxima do swing (barras)
input double InpMinImpulseATR = 0.80;         // Impulso minimo (x ATR)
input double InpMinEfficiency = 0.45;         // Eficiencia minima do impulso
input double InpMinRetracement = 0.20;        // Retracao minima
input double InpMaxPullback = 0.78;           // Pullback maximo
input int    InpFailureLookbackBars = 4;      // Barras para detectar falha

input group "AURELIS 06 | Regioes, setups e gatilho"
input double InpMinSetupScore = 62.0;         // Score minimo do setup (0-100)
input double InpMinTargetATR = 0.80;          // Alvo minimo (x ATR)
input double InpMinSpaceATR = 0.80;           // Espaco livre minimo ate o obstaculo (x ATR)
input double InpMinCloseLocationBuy = 0.65;   // Fechamento minimo na faixa do candle (compra)
input double InpMaxCloseLocationSell = 0.35;  // Fechamento maximo na faixa do candle (venda)
input double InpMinWickRejection = 0.25;      // Rejeicao minima de pavio
input double InpMinBodyATR = 0.35;            // Corpo minimo do candle (x ATR)
input int    InpTriggerLookbackBars = 3;      // Barras para procurar o gatilho
input ENUM_TRIGGER_MODE InpTriggerMode = TRIGGER_BALANCED; // Gatilho: BALANCED = estrutura OU deslocamento | STRICT = ambos
input bool   InpNeutralRegionsAsSR = true;    // Regiao neutra vira suporte (abaixo do preco) ou resistencia (acima)
input bool   InpAllowCounterTrendReversal = true; // Permitir reversao contra a tendencia do contexto
input double InpContextConflictStrength = 60.0;   // Forca do contexto que conta como conflito
input double InpContextAlignedStrength = 55.0;    // Forca do contexto que conta como alinhado

input group "AURELIS 07 | Contexto multi-timeframe (so leitura, NAO abre ordem)"
input bool   InpUseMonthlyContext = true;     // Usar contexto Mensal
input bool   InpUseWeeklyContext = true;      // Usar contexto Semanal
input bool   InpUseDailyContext = true;       // Usar contexto Diario
input bool   InpUseH4Context = true;          // Usar contexto H4

input group "AURELIS 08 | Mapa temporal"
input bool   InpUseSessionMap = true;         // Usar mapa de sessao
input int    InpSessionStartHour = 0;         // Inicio da sessao (hora)
input int    InpSessionStartMinute = 0;       // Inicio da sessao (minuto)
input int    InpSessionEndHour = 23;          // Fim da sessao (hora)
input int    InpSessionEndMinute = 59;        // Fim da sessao (minuto)
input int    InpMapLookbackDays = 2;          // Dias de historico no mapa

input group "AURELIS 09 | Filtro de spread"
input bool   InpSpreadFilter = true;          // Ativar filtro de spread
input int    InpMaxSpreadPointsM1  = 40;      // Spread maximo no M1 (pontos). Bloqueia entrada acima disso
input int    InpMaxSpreadPointsM5  = 50;      // Spread maximo no M5 (pontos)
input int    InpMaxSpreadPointsM15 = 60;      // Spread maximo no M15 (pontos)
input bool   InpSpreadSpikeFilter = true;     // Bloquear picos de spread
input double InpSpreadSpikeRatio = 2.0;       // Pico = spread atual / mediana recente >= este valor
input double InpSpreadMinAbsolutePoints = 1.0; // Pico so vale se o spread passar de (pontos)

input group "AURELIS 10 | Filtro de horario e noticias"
input bool   InpSessionFilter = false;        // Restringir horario de operacao
input int    InpTradeStartHour = 0;           // Operar a partir de (hora)
input int    InpTradeStartMinute = 0;         // Operar a partir de (minuto)
input int    InpTradeEndHour = 23;            // Operar ate (hora)
input int    InpTradeEndMinute = 59;          // Operar ate (minuto)
input bool   InpNewsFilterEnabled = false;    // Bloquear em noticias
input string InpNewsCurrency = "USD";         // Moeda das noticias
input int    InpNewsMinutesBefore = 20;       // Minutos antes da noticia
input int    InpNewsMinutesAfter = 20;        // Minutos depois da noticia

input group "AURELIS RISCO 1/4 | Tamanho da posicao (lote)"
input bool   InpUseRiskSizing = false;        // Lote por risco % (precisa de Stop Loss ativo)
input double InpRiskPercent = 0.50;           // Risco por trade (% do saldo)
input double InpFixedLot = 0.01;              // Lote fixo (quando o risco % esta desligado)
input double InpMaxLots = 0.0;                // Lote maximo (0 = sem limite)

input group "AURELIS RISCO 2/4 | Stop Loss"
input bool   InpUseStopLoss = false;          // Usar Stop Loss na ordem
input ENUM_SL_MODE InpSLMode = SL_STRUCTURAL; // Tipo de Stop Loss
input double InpStopATR = 1.50;               // Stop em ATR (quando o modo usa ATR)
input bool   InpEmergencyStopEnabled = false; // Stop de emergencia (fecha a posicao ao exceder)
input double InpEmergencyStopATR = 3.0;       // Distancia do stop de emergencia (x ATR)

input group "AURELIS RISCO 3/4 | Limites de exposicao"
input int    InpMaxPositions = 1;             // Maximo de posicoes simultaneas deste TF
input bool   InpOnePositionPerTF = true;      // Apenas 1 posicao por TF
input int    InpMaxTradesPerDay = 0;          // Maximo de trades por dia (0 = sem limite)
input int    InpCooldownM1Minutes = 3;        // Pausa apos saida no M1 (minutos)
input int    InpCooldownM5Minutes = 5;        // Pausa apos saida no M5 (minutos)
input int    InpCooldownM15Minutes = 0;       // Pausa apos saida no M15 (minutos)

input group "AURELIS RISCO 4/4 | Saida por tempo e estrutura"
input ENUM_EXIT_OPPOSITE InpExitOppositeStructure = EXIT_OPPOSITE_SHIFT; // Sair quando a estrutura virar contra
input bool   InpTimeExitEnabled = true;       // Sair por tempo maximo de posse
input int    InpMaxHoldHoursM15 = 24;         // Tempo maximo no M15 (horas)
input int    InpMaxHoldMinutesM5 = 180;       // Tempo maximo no M5 (minutos)
input int    InpMaxHoldMinutesM1 = 45;        // Tempo maximo no M1 (minutos)

input group "AURELIS RISCO 4/4 | Saida por perda em dinheiro (sem SL)"
input bool   InpLossExitMoneyEnabled = true;  // v1.11: fecha a mercado (software) se a perda flutuante passar do limite; nao coloca SL
input double InpMaxLossMoney = 50.0;          // Perda maxima por posicao em $ (swap incluido). 0 = desligado

input group "AURELIS LUCRO 1/4 | Take Profit"
input bool   InpUseTakeProfit = true;         // Usar Take Profit na ordem
input ENUM_TP_MODE InpTPMode = TP_STRUCTURE;  // Tipo de Take Profit
input double InpRRMultiple = 2.0;             // Relacao risco:retorno (modo RR)
input double InpMoneyTargetPerTrade = 0.0;    // Meta em dinheiro por trade (0 = desligado)

input group "AURELIS LUCRO 2/4 | Breakeven (dinheiro e pontos)"
input bool   InpBreakEvenEnabled = true;      // Ativar breakeven
input double InpBreakEvenStartMoney = 3.0;    // Breakeven: ativar com lucro de ($)
input int    InpBreakEvenOffsetPoints = 20;   // Breakeven: folga alem da entrada (pontos)

input group "AURELIS LUCRO 3/4 | Trailing (dinheiro HWM ou pontos)"
input ENUM_TRAIL_MODE InpTrailingMode = TRAIL_MONEY_HWM; // Modo: Desligado | Dinheiro (HWM por faixas) | Pontos (distancia fixa)
input bool   InpTrailingOverrideTP = true;    // Trailing remove o Take Profit ao ativar
input double InpTrailStartMoney = 5.0;        // DINHEIRO: ativa com lucro de ($)
input string InpTrailTiers = "5:60;10:60;20:50;50:40;100:35;200:30"; // DINHEIRO: faixas "lucro maximo $ : distancia %" (distancia = % do lucro maximo que pode devolver)
input int    InpTrailStartPoints = 300;       // PONTOS: ativa com lucro de (pontos)
input int    InpTrailDistancePoints = 200;    // PONTOS: distancia do preco ao stop (pontos)
input int    InpTrailStepPoints = 20;         // Passo minimo para mover o stop (pontos)
input bool   InpUseSwingTrailing = false;     // Tambem proteger atras do ultimo swing (vale o stop mais apertado)
input int    InpTrailingBufferPoints = 30;    // Folga do swing (pontos)

input group "AURELIS LUCRO 4/4 | Meta diaria (resultado geral M1+M5+M15)"
input bool   InpDailyTargetMoneyEnabled = false; // Usar meta diaria em dinheiro
input double InpDailyTargetMoney = 0.0;       // Meta diaria (moeda da conta)
input ENUM_DAILY_TARGET_ACTION InpDailyTargetAction = DAILY_BLOCK_NEW_ENTRIES; // Ao bater a meta
input bool   InpIncludeFloatingPnL = true;    // Incluir lucro flutuante no resultado do dia

input group "AURELIS 11 | Execucao"
input int    InpDeviationPoints = 30;         // Desvio maximo (pontos)

input group "AURELIS 12 | Painel"
input bool   InpShowPanel = true;             // Mostrar painel HUD
input int    InpPanelScalePct = 75;           // v1.11: escala do painel (50-100 %). Diminui sozinho se nao couber no grafico
input int    InpPanelX = 20;                  // Posicao X do painel
input int    InpPanelY = 60;                  // Posicao Y do painel
input bool   InpPanelStartMinimized = false;  // Iniciar painel minimizado
input ENUM_STATS_PERIOD InpStatsWLPeriod = STATS_DAY; // Periodo de W / L / ASS no painel

//====================================================================
// DATA STRUCTURES
//====================================================================
struct PriceLevel
  {
   string id;
   string type;
   string source;
   double price;
   double strength;
   int    age_bars;
   int    bias;
   bool   valid;
  };

struct Region
  {
   string id;
   string type;
   string source1;
   string source2;
   string source3;
   double low;
   double high;
   double center;
   double score;
   double strength;
   int    source_count;
   int    bias;
   bool   active;
   bool   valid;
  };

struct Swing
  {
   datetime time;
   double   price;
   double   excursion;
   int      shift;
   bool     confirmed;
   bool     major;
  };

struct Trendline
  {
   bool     valid;
   bool     bullish;
   datetime t1;
   datetime t2;
   double   p1;
   double   p2;
   double   slope_price_per_sec;
   double   score;
   int      touches;
   datetime validation_time;
   string   state;
  };

struct Channel
  {
   bool     valid;
   bool     bullish;
   Trendline top;
   Trendline bottom;
   double   width;
   double   width_norm;
   double   score;
   string   state;
  };

struct TFAnalysis
  {
   ENUM_TIMEFRAMES tf;
   double atr;
   double atr_slow;
   double vol_ratio;
   int    vol_regime;
   int    signal;
   int    regime;
   double strength;
   datetime bar_time;
   double last_swing_high;
   double prev_swing_high;
   double last_swing_low;
   double prev_swing_low;
   bool bos_up;
   bool bos_down;
   bool shift_up;
   bool shift_down;
   bool failed_break_up;
   bool failed_break_down;
   bool data_ok;
  };

struct ContextSnapshot
  {
   int direction;
   double strength;
   string class_name;
   double weighted_sum;
   double weight_sum;
   TFAnalysis tfs[5];
  };

struct TriggerResult
  {
   bool event_ok;
   bool reaction_ok;
   bool structure_ok;
   bool displacement_ok;
   bool confirmed;
   bool sweep;
   bool breakout;
   bool retest;
   bool trendline_touch;
   bool sr_touch;
   int shift_direction;
   string event_name;
   string reaction_name;
   string structure_name;
   string type;
   int bars_ago;
   double quality;
   double sweep_level;
  };

struct SetupCandidate
  {
   bool valid;
   int direction;
   string id;
   string type;
   string region_id;
   int region_index;
   double score;
   double context_quality;
   double region_quality;
   double liquidity_quality;
   double structure_quality;
   double trigger_quality;
   double space_quality;
   double entry;
   double sl;
   double tp;
   double nearest_obstacle;
   double space_norm;
   double atr;
   double spread;
   bool space_ok;
   bool context_ok;
   bool structure_ok;
   bool trigger_ok;
   bool breakout;
   bool sweep;
   bool reversal;
   TriggerResult trigger;
   string reason_primary;
   string reason_secondary;
  };

struct Decision
  {
   int action;
   bool allowed;
   string reason_primary;
   string reason_secondary;
   double score;
   double entry;
   double sl;
   double tp;
   string region_id;
   string setup_id;
   string trigger_id;
   string setup_type;
  };

//====================================================================
// GLOBAL STATE
//====================================================================
ENUM_TIMEFRAMES g_workTF = PERIOD_M15;
ulong           g_magic = 0;
string          g_profileName = "M15";

PriceLevel g_levels[];
Region     g_regions[];
Swing      g_workHighs[];
Swing      g_workLows[];
Trendline  g_lta;
Trendline  g_ltb;
Channel    g_channelUp;
Channel    g_channelDown;
ContextSnapshot g_context;
Decision   g_lastDecision;
SetupCandidate g_bestBuy;
SetupCandidate g_bestSell;

MqlTradeResult g_lastTradeResult;

datetime g_lastBarTime = 0;
datetime g_lastDecisionBar = 0;
datetime g_lastExitTime = 0;
string   g_lastEventId = "";
string   g_lastRegionId = "";
string   g_lastSetupId = "";
string   g_lastTriggerId = "";
string   g_lastReason = "INIT";
string   g_lastLocalRegime = "RANGE";
string   g_lastDecisionText = "NO TRADE";
string   g_lastState = "SCANNING";
string   g_lastNewsStatus = "OFF";
string   g_lastVolStatus = "NORMAL";
string   g_lastContextClass = "NEUTRAL";
int      g_lastContextDirection = 0;
double   g_lastContextStrength = 0.0;
double   g_lastATR = 0.0;
double   g_lastSpread = 0.0;
double   g_lastRegionScore = 0.0;
double   g_lastSetupScore = 0.0;
double   g_lastSpaceNorm = 0.0;
double   g_dailyPnL = 0.0;
datetime g_dayStart = 0;
bool     g_dailyTargetHit = false;
bool     g_tradingPaused = false;
bool     g_gSpread=true,g_gSession=true,g_gNews=true,g_gDaily=true,g_gPos=true,g_gCool=true,g_gAuto=true,g_gData=true;
double   g_spreadPts=0.0;        // spread atual em pontos
double   g_spreadLimitPts=0.0;   // limite do TF em pontos
bool     g_csvHeaderWritten = false;
int      g_csvHandle = INVALID_HANDLE;
long     g_eventSequence = 0;

// spread sample ring
 double g_spreadBuffer[100];
int    g_spreadCount = 0;
int    g_spreadIndex = 0;

#define AURELIS_PREFIX "AURX_"
#define PANEL_BG      "AURELIS_PANEL_BG"
#define PANEL_TITLE   "AURELIS_PANEL_TITLE"
#define PANEL_STATUS  "AURELIS_PANEL_STATUS"
#define PANEL_INFO    "AURELIS_PANEL_INFO"
#define PANEL_BTN_PAUSE "AURELIS_BTN_PAUSE"
#define PANEL_BTN_FLAT  "AURELIS_BTN_FLAT"
#define PANEL_ROW_PREFIX "AURELIS_PANEL_ROW_"
#define AURELIS_TRADE_PREFIX "AURELIS_TRADE_"

//====================================================================
// STRING / MATH HELPERS
//====================================================================
double ClampD(const double x,const double a,const double b)
  {
   return MathMax(a,MathMin(x,b));
  }

double SafeDiv(const double a,const double b)
  {
   if(MathAbs(b)<1.0e-12)
      return 0.0;
   return a/b;
  }

double NormDistance(const double a,const double b,const double atr)
  {
   return MathAbs(a-b)/MathMax(atr,_Point);
  }

string TFToShort(const ENUM_TIMEFRAMES tf)
  {
   if(tf==PERIOD_M1) return "M1";
   if(tf==PERIOD_M5) return "M5";
   if(tf==PERIOD_M15) return "M15";
   if(tf==PERIOD_M30) return "M30";
   if(tf==PERIOD_H1) return "H1";
   if(tf==PERIOD_H4) return "H4";
   if(tf==PERIOD_D1) return "D1";
   if(tf==PERIOD_W1) return "W1";
   if(tf==PERIOD_MN1) return "MN";
   return "TF";
  }

string SignToText(const int dir)
  {
   if(dir>0) return "BUY";
   if(dir<0) return "SELL";
   return "NEUTRAL";
  }

string RegimeToText(const int regime)
  {
   if(regime==REGIME_BULLISH) return "BULLISH";
   if(regime==REGIME_BEARISH) return "BEARISH";
   if(regime==REGIME_RANGE) return "RANGE";
   return "TRANSITION";
  }

string VolToText(const int regime)
  {
   if(regime==VOL_LOW) return "LOW";
   if(regime==VOL_HIGH) return "HIGH";
   return "NORMAL";
  }

string ActionToText(const int action)
  {
   if(action==ACTION_BUY) return "BUY";
   if(action==ACTION_SELL) return "SELL";
   return "NO TRADE";
  }

string BoolText(const bool value)
  {
   return value ? "YES" : "NO";
  }

uint HashString(const string text)
  {
   ulong hash=2166136261;
   const int n=StringLen(text);
   for(int i=0;i<n;i++)
     {
      hash ^= (uchar)StringGetCharacter(text,i);
      hash *= 16777619;
     }
   return (uint)(hash & 0xFFFFFFFF);
  }

string StableId(const string prefix,const string key)
  {
   return prefix+IntegerToString((int)HashString(key));
  }

string EventIdMake(const string region_id,const string setup_id,const datetime trigger_time,const int direction)
  {
   string key=_Symbol+"|"+TFToShort(g_workTF)+"|"+region_id+"|"+setup_id+"|"+
              IntegerToString((int)trigger_time)+"|"+IntegerToString(direction);
   return "E"+IntegerToString((int)HashString(key));
  }

string JoinReasons(const string a,const string b,const string c="")
  {
   string out="";
   if(a!="") out=a;
   if(b!="") out+=(out==""?"":"|")+b;
   if(c!="") out+=(out==""?"":"|")+c;
   return out;
  }

bool IsNear(const double price,const double low,const double high,const double tolerance)
  {
   if(price>=low-tolerance && price<=high+tolerance)
      return true;
   return false;
  }

bool StringContains(const string text,const string needle)
  {
   return StringFind(text,needle)>=0;
  }

double NormalizePrice(const double price)
  {
   double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick_size<=0.0) tick_size=_Point;
   double normalized=MathRound(price/tick_size)*tick_size;
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   return NormalizeDouble(normalized,digits);
  }

double PriceDistanceToMoney(const double price_distance,const double volume)
  {
   double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tick_size<=0.0 || tick_value<=0.0 || volume<=0.0)
      return 0.0;
   return (price_distance/tick_size)*tick_value*volume;
  }

datetime DayStart(const datetime when)
  {
   MqlDateTime dt;
   TimeToStruct(when,dt);
   dt.hour=0;
   dt.min=0;
   dt.sec=0;
   return StructToTime(dt);
  }

//====================================================================
// PROFILE / SYMBOL
//====================================================================
bool ValidateInputs()
  {
   if(InpATRPeriod<5) return false;
   if(InpStructureLookbackBars<40) return false;
   if(InpRangeLookbackBars<20) return false;
   if(InpSwingFractalRadius<1 || InpSwingFractalRadius>10) return false;
   if(InpMaxSwingAgeBars<=InpSwingFractalRadius) return false;
   if(InpDecayBars<=0.0) return false;
   if(InpMinImpulseATR<=0.0 || InpMinEfficiency<0.0 || InpMinEfficiency>1.0) return false;
   if(InpMinRetracement<0.0 || InpMaxPullback<=InpMinRetracement || InpMaxPullback>1.0) return false;
   if(InpMinSetupScore<0.0 || InpMinSetupScore>100.0) return false;
   if(InpMinTargetATR<=0.0 || InpMinSpaceATR<=0.0) return false;
   if(InpMaxSpreadPointsM1<=0 || InpMaxSpreadPointsM5<=0 || InpMaxSpreadPointsM15<=0) return false;
   if(InpFixedLot<=0.0) return false;
   if(InpMaxLots<0.0 || InpRiskPercent<0.0) return false;
   if(InpDeviationPoints<0) return false;
   if(InpSessionStartHour<0 || InpSessionStartHour>23 || InpSessionEndHour<0 || InpSessionEndHour>23) return false;
   if(InpTradeStartHour<0 || InpTradeStartHour>23 || InpTradeEndHour<0 || InpTradeEndHour>23) return false;
   if(InpSessionStartMinute<0 || InpSessionStartMinute>59 || InpSessionEndMinute<0 || InpSessionEndMinute>59) return false;
   if(InpTradeStartMinute<0 || InpTradeStartMinute>59 || InpTradeEndMinute<0 || InpTradeEndMinute>59) return false;
   if(InpDailyTargetMoney<0.0 || InpMoneyTargetPerTrade<0.0) return false;
   if(InpConfluenceATR<=0.0 || InpRegionActivationATR<=0.0 || InpZoneAlphaATR<=0.0 || InpZoneMaxATR<=0.0) return false;
   if(InpLineToleranceATR<=0.0 || InpMinChannelWidthATR<=0.0 || InpMaxChannelWidthATR<=InpMinChannelWidthATR) return false;
   if(InpBreakEvenStartMoney<0.0 || InpBreakEvenOffsetPoints<0) return false;
   if(InpTrailingMode==TRAIL_MONEY_HWM && InpTrailStartMoney<=0.0) return false;
   if(InpTrailStartPoints<0 || InpTrailDistancePoints<=0 || InpTrailStepPoints<0 || InpTrailingBufferPoints<0) return false;
   return true;
  }

bool ResolveProfile()
  {
   if(InpProfile==PROFILE_AUTO)
     {
      if(_Period==PERIOD_M1) g_workTF=PERIOD_M1;
      else if(_Period==PERIOD_M5) g_workTF=PERIOD_M5;
      else if(_Period==PERIOD_M15) g_workTF=PERIOD_M15;
      else
        {
         Print("AURELIS: chart timeframe must be M1, M5 or M15 when Profile=AUTO.");
         return false;
        }
     }
   else
     {
      if(InpProfile==PROFILE_M1) g_workTF=PERIOD_M1;
      else if(InpProfile==PROFILE_M5) g_workTF=PERIOD_M5;
      else if(InpProfile==PROFILE_M15) g_workTF=PERIOD_M15;
      else return false;
      if(_Period!=g_workTF)
        {
         PrintFormat("AURELIS: explicit profile %s requires same chart timeframe. Current=%s",
                     TFToShort(g_workTF),TFToShort((ENUM_TIMEFRAMES)_Period));
         return false;
        }
     }
   g_profileName=TFToShort(g_workTF);
   g_magic=(ulong)(InpMagicBase+(long)g_workTF);
   return true;
  }

bool ValidateSymbol()
  {
   if(SymbolInfoDouble(_Symbol,SYMBOL_POINT)<=0.0) return false;
   if(SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)<=0.0) return false;
   if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)<=0.0) return false;
   if(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)<=0.0) return false;
   long trade_mode=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   if(trade_mode==SYMBOL_TRADE_MODE_DISABLED)
      return false;
   return true;
  }

//====================================================================
// MARKET DATA / ATR
//====================================================================
int LoadRates(const ENUM_TIMEFRAMES tf,const int count,MqlRates &rates[])
  {
   ArrayFree(rates);
   int copied=CopyRates(_Symbol,tf,0,count,rates);
   if(copied>0)
      ArraySetAsSeries(rates,true);
   return copied;
  }

double ATRFromRates(const MqlRates &rates[],const int total,const int shift,const int period)
  {
   if(total<(shift+period+2) || period<=0)
      return 0.0;
   double sum=0.0;
   int used=0;
   for(int i=shift;i<shift+period;i++)
     {
      if(i+1>=total) break;
      double tr1=rates[i].high-rates[i].low;
      double tr2=MathAbs(rates[i].high-rates[i+1].close);
      double tr3=MathAbs(rates[i].low-rates[i+1].close);
      double tr=MathMax(tr1,MathMax(tr2,tr3));
      if(tr<0.0) continue;
      sum+=tr;
      used++;
     }
   return SafeDiv(sum,(double)used);
  }

double GetATR(const ENUM_TIMEFRAMES tf,const int period,const int shift=1)
  {
   MqlRates rates[];
   int total=LoadRates(tf,period+shift+5,rates);
   if(total<=0) return 0.0;
   return ATRFromRates(rates,total,shift,period);
  }

bool CheckDataQuality(const MqlRates &rates[],const int total,const double spread,const double atr,double &quality,string &reason)
  {
   quality=100.0;
   reason="OK";
   if(total<(InpATRPeriod+InpSwingFractalRadius+10))
     {
      quality=0.0;
      reason="INSUFFICIENT_BARS";
      return false;
     }
   if(atr<=0.0)
     {
      quality=0.0;
      reason="ATR_INVALID";
      return false;
     }
   for(int i=0;i<MathMin(total-1,20);i++)
     {
      if(rates[i].time<=rates[i+1].time || rates[i].high<rates[i].low)
        {
         quality=0.0;
         reason="TIMESTAMP_OR_OHLC_INVALID";
         return false;
        }
     }
   double spread_norm=SafeDiv(spread,atr);
   if(spread_norm>0.50) quality-=25.0;
   if(spread_norm>1.00) quality-=60.0;
   if(!MathIsValidNumber(atr) || !MathIsValidNumber(spread))
     {
      quality=0.0;
      reason="NUMERIC_INVALID";
      return false;
     }
   quality=ClampD(quality,0.0,100.0);
   return true;
  }

int DetermineVolRegime(const double atr_fast,const double atr_slow,double &ratio)
  {
   ratio=SafeDiv(atr_fast,MathMax(atr_slow,_Point));
   if(ratio<0.75) return VOL_LOW;
   if(ratio>1.25) return VOL_HIGH;
   return VOL_NORMAL;
  }

ENUM_TIMEFRAMES SlowTFFor(const ENUM_TIMEFRAMES tf)
  {
   if(tf==PERIOD_M1) return PERIOD_M5;
   if(tf==PERIOD_M5) return PERIOD_M15;
   if(tf==PERIOD_M15) return PERIOD_H1;
   if(tf==PERIOD_H1) return PERIOD_H4;
   if(tf==PERIOD_H4) return PERIOD_D1;
   if(tf==PERIOD_D1) return PERIOD_W1;
   if(tf==PERIOD_W1) return PERIOD_MN1;
   return PERIOD_H1;
  }

//====================================================================
// SWING ENGINE
//====================================================================
void CollectSwings(const ENUM_TIMEFRAMES tf,Swing &highs[],Swing &lows[])
  {
   ArrayResize(highs,0);
   ArrayResize(lows,0);

   int radius=InpSwingFractalRadius;
   int need=InpStructureLookbackBars+InpATRPeriod+radius+20;
   MqlRates rates[];
   int total=LoadRates(tf,need,rates);
   if(total<=0) return;

   int max_shift=(int)MathMin(InpStructureLookbackBars,total-radius-3);
   if(max_shift<radius+1) return;

   for(int s=radius+1;s<=max_shift;s++)
     {
      int left=s-radius;
      int right=s+radius;
      bool is_high=true;
      bool is_low=true;
      double h=rates[s].high;
      double l=rates[s].low;
      for(int j=left;j<=right;j++)
        {
         if(j==s) continue;
         if(rates[j].high>h) is_high=false;
         if(rates[j].low<l) is_low=false;
        }
      double atr=ATRFromRates(rates,total,s,InpATRPeriod);
      if(atr<=0.0) continue;

      if(is_high)
        {
         double future_low=rates[s-1].low;
         for(int j=s-1;j>=MathMax(1,s-radius);j--)
            future_low=MathMin(future_low,rates[j].low);
         double excursion=h-future_low;
         if(excursion>=InpSwingExcursionATR*atr)
           {
            Swing sw;
            sw.time=rates[s].time;
            sw.price=h;
            sw.excursion=excursion;
            sw.shift=s;
            sw.confirmed=true;
            sw.major=(excursion>=1.20*atr);
            int n=ArraySize(highs);
            if(n<64)
              {
               ArrayResize(highs,n+1);
               highs[n]=sw;
              }
           }
        }

      if(is_low)
        {
         double future_high=rates[s-1].high;
         for(int j=s-1;j>=MathMax(1,s-radius);j--)
            future_high=MathMax(future_high,rates[j].high);
         double excursion=future_high-l;
         if(excursion>=InpSwingExcursionATR*atr)
           {
            Swing sw;
            sw.time=rates[s].time;
            sw.price=l;
            sw.excursion=excursion;
            sw.shift=s;
            sw.confirmed=true;
            sw.major=(excursion>=1.20*atr);
            int n=ArraySize(lows);
            if(n<64)
              {
               ArrayResize(lows,n+1);
               lows[n]=sw;
              }
           }
        }
     }
  }

void GetRecentSwingPair(const Swing &swings[],double &last_price,double &prev_price,bool &ok)
  {
   last_price=0.0;
   prev_price=0.0;
   ok=false;
   if(ArraySize(swings)<2) return;
   last_price=swings[0].price;
   prev_price=swings[1].price;
   ok=true;
  }

//====================================================================
// STRUCTURE ENGINE
//====================================================================
int DetermineStructureSignal(const Swing &highs[],const Swing &lows[])
  {
   if(ArraySize(highs)<2 || ArraySize(lows)<2)
      return 0;
   bool hh=highs[0].price>highs[1].price;
   bool lh=highs[0].price<highs[1].price;
   bool hl=lows[0].price>lows[1].price;
   bool ll=lows[0].price<lows[1].price;
   if(hh && hl) return 2;
   if(lh && ll) return -2;
   if(hh || hl) return 1;
   if(lh || ll) return -1;
   return 0;
  }

int DetermineRegimeFromSignal(const int signal)
  {
   if(signal>=2) return REGIME_BULLISH;
   if(signal<=-2) return REGIME_BEARISH;
   if(signal==0) return REGIME_RANGE;
   return REGIME_TRANSITION;
  }

void DetectBreaks(const ENUM_TIMEFRAMES tf,const Swing &highs[],const Swing &lows[],const double atr,
                  bool &bos_up,bool &bos_down,bool &shift_up,bool &shift_down,
                  bool &failed_up,bool &failed_down)
  {
   bos_up=false; bos_down=false; shift_up=false; shift_down=false; failed_up=false; failed_down=false;
   if(ArraySize(highs)<1 || ArraySize(lows)<1 || atr<=0.0) return;
   MqlRates rates[];
   int total=LoadRates(tf,MathMax(20,InpFailureLookbackBars+10),rates);
   if(total<5) return;
   double buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());
   double c=rates[1].close;
   double last_h=highs[0].price;
   double last_l=lows[0].price;
   bos_up=(c>last_h+buffer);
   bos_down=(c<last_l-buffer);
   int prev_signal=DetermineStructureSignal(highs,lows);
   shift_up=(prev_signal<=0 && bos_up);
   shift_down=(prev_signal>=0 && bos_down);

   int n=(int)MathMin(InpFailureLookbackBars,total-1);
   // A failure requires a prior confirmed excursion beyond the level and a later close back through it.
   for(int s=n;s>=2;s--)
     {
      if(rates[s].high>last_h+buffer)
        {
         for(int j=s-1;j>=1;j--)
           {
            if(rates[j].close<=last_h+buffer)
              { failed_up=true; break; }
           }
        }
      if(rates[s].low<last_l-buffer)
        {
         for(int j=s-1;j>=1;j--)
           {
            if(rates[j].close>=last_l-buffer)
              { failed_down=true; break; }
           }
        }
      if(failed_up && failed_down) break;
     }
  }

TFAnalysis AnalyzeTF(const ENUM_TIMEFRAMES tf)
  {
   TFAnalysis a;
   a.tf=tf;
   a.atr=0.0;
   a.atr_slow=0.0;
   a.vol_ratio=1.0;
   a.vol_regime=VOL_NORMAL;
   a.signal=0;
   a.regime=REGIME_RANGE;
   a.strength=0.0;
   a.bar_time=0;
   a.last_swing_high=0.0;
   a.prev_swing_high=0.0;
   a.last_swing_low=0.0;
   a.prev_swing_low=0.0;
   a.bos_up=false; a.bos_down=false; a.shift_up=false; a.shift_down=false;
   a.failed_break_up=false; a.failed_break_down=false;
   a.data_ok=false;

   MqlRates rates[];
   int total=LoadRates(tf,InpStructureLookbackBars+InpATRPeriod+InpSwingFractalRadius+20,rates);
   if(total<InpATRPeriod+10) return a;
   a.bar_time=rates[1].time;
   a.atr=ATRFromRates(rates,total,1,InpATRPeriod);
   ENUM_TIMEFRAMES slow=SlowTFFor(tf);
   a.atr_slow=GetATR(slow,InpATRPeriod,1);
   a.vol_regime=DetermineVolRegime(a.atr,a.atr_slow,a.vol_ratio);
   Swing highs[],lows[];
   CollectSwings(tf,highs,lows);
   if(ArraySize(highs)>=1) a.last_swing_high=highs[0].price;
   if(ArraySize(highs)>=2) a.prev_swing_high=highs[1].price;
   if(ArraySize(lows)>=1) a.last_swing_low=lows[0].price;
   if(ArraySize(lows)>=2) a.prev_swing_low=lows[1].price;
   a.signal=DetermineStructureSignal(highs,lows);
   a.regime=DetermineRegimeFromSignal(a.signal);
   a.strength=ClampD(50.0*MathAbs((double)a.signal),0.0,100.0);
   double spread=CurrentSpread();
   string reason="";
   double quality=0.0;
   a.data_ok=CheckDataQuality(rates,total,spread,a.atr,quality,reason);
   DetectBreaks(tf,highs,lows,a.atr,a.bos_up,a.bos_down,a.shift_up,a.shift_down,a.failed_break_up,a.failed_break_down);
   return a;
  }

//====================================================================
// MARKET MAP
//====================================================================
struct MapSnapshot
  {
   double monthly_open;
   double weekly_open;
   double daily_open;
   double session_open;
   double current_week_high;
   double current_week_low;
   double previous_week_high;
   double previous_week_low;
   double previous_day_high;
   double previous_day_low;
   double current_day_high;
   double current_day_low;
   double weekly_mid_up;
   double weekly_mid_down;
   double daily_mid_up;
   double daily_mid_down;
   double range_high;
   double range_low;
   double range_mid;
   double range_width_norm;
   double session_high;
   double session_low;
  };

MapSnapshot g_map;

void ResetMap()
  {
   g_map.monthly_open=0.0;
   g_map.weekly_open=0.0;
   g_map.daily_open=0.0;
   g_map.session_open=0.0;
   g_map.current_week_high=0.0;
   g_map.current_week_low=0.0;
   g_map.previous_week_high=0.0;
   g_map.previous_week_low=0.0;
   g_map.previous_day_high=0.0;
   g_map.previous_day_low=0.0;
   g_map.current_day_high=0.0;
   g_map.current_day_low=0.0;
   g_map.weekly_mid_up=0.0;
   g_map.weekly_mid_down=0.0;
   g_map.daily_mid_up=0.0;
   g_map.daily_mid_down=0.0;
   g_map.range_high=0.0;
   g_map.range_low=0.0;
   g_map.range_mid=0.0;
   g_map.range_width_norm=0.0;
   g_map.session_high=0.0;
   g_map.session_low=0.0;
  }

void BuildMap(const double atr)
  {
   ResetMap();
   g_map.monthly_open=iOpen(_Symbol,PERIOD_MN1,0);
   g_map.weekly_open=iOpen(_Symbol,PERIOD_W1,0);
   g_map.daily_open=iOpen(_Symbol,PERIOD_D1,0);
   g_map.current_week_high=iHigh(_Symbol,PERIOD_W1,0);
   g_map.current_week_low=iLow(_Symbol,PERIOD_W1,0);
   g_map.previous_week_high=iHigh(_Symbol,PERIOD_W1,1);
   g_map.previous_week_low=iLow(_Symbol,PERIOD_W1,1);
   g_map.previous_day_high=iHigh(_Symbol,PERIOD_D1,1);
   g_map.previous_day_low=iLow(_Symbol,PERIOD_D1,1);
   g_map.current_day_high=iHigh(_Symbol,PERIOD_D1,0);
   g_map.current_day_low=iLow(_Symbol,PERIOD_D1,0);

   if(g_map.weekly_open>0.0)
     {
      if(g_map.current_week_high>g_map.weekly_open)
         g_map.weekly_mid_up=(g_map.weekly_open+g_map.current_week_high)/2.0;
      if(g_map.current_week_low<g_map.weekly_open)
         g_map.weekly_mid_down=(g_map.weekly_open+g_map.current_week_low)/2.0;
     }

   if(g_map.daily_open>0.0)
     {
      if(g_map.current_day_high>g_map.daily_open)
         g_map.daily_mid_up=(g_map.daily_open+g_map.current_day_high)/2.0;
      if(g_map.current_day_low<g_map.daily_open)
         g_map.daily_mid_down=(g_map.daily_open+g_map.current_day_low)/2.0;
     }

   MqlRates rates[];
   int total=LoadRates(g_workTF,InpRangeLookbackBars+5,rates);
   if(total>5)
     {
      double rh=rates[1].high;
      double rl=rates[1].low;
      int end=(int)MathMin(total-1,InpRangeLookbackBars);
      for(int i=1;i<=end;i++)
        {
         rh=MathMax(rh,rates[i].high);
         rl=MathMin(rl,rates[i].low);
        }
      g_map.range_high=rh;
      g_map.range_low=rl;
      g_map.range_mid=(rh+rl)/2.0;
      g_map.range_width_norm=SafeDiv(rh-rl,atr);
     }

   if(InpUseSessionMap)
      BuildSessionMap(g_map.session_open,g_map.session_high,g_map.session_low);
  }

void BuildSessionMap(double &session_open,double &session_high,double &session_low)
  {
   session_open=0.0;
   session_high=0.0;
   session_low=0.0;
   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now,dt);
   dt.hour=InpSessionStartHour;
   dt.min=InpSessionStartMinute;
   dt.sec=0;
   datetime start=StructToTime(dt);
   datetime end=start;
   MqlDateTime dt_end=dt;
   dt_end.hour=InpSessionEndHour;
   dt_end.min=InpSessionEndMinute;
   dt_end.sec=59;
   end=StructToTime(dt_end);
   if(InpSessionEndHour<InpSessionStartHour ||
      (InpSessionEndHour==InpSessionStartHour && InpSessionEndMinute<InpSessionStartMinute))
      end+=86400;
   if(now<start)
     {
      start-=86400;
      end-=86400;
     }
   MqlRates rates[];
   int total=LoadRates(PERIOD_M1,1440*2,rates);
   if(total<=0) return;
   int session_shift=iBarShift(_Symbol,PERIOD_M1,start,false);
   if(session_shift>=0)
      session_open=iOpen(_Symbol,PERIOD_M1,session_shift);
   double hi=-1.0e100,lo=1.0e100;
   for(int i=1;i<total;i++)
     {
      if(rates[i].time<start) break;
      if(rates[i].time>end) continue;
      hi=MathMax(hi,rates[i].high);
      lo=MathMin(lo,rates[i].low);
     }
   if(hi>-9.0e99) session_high=hi;
   if(lo< 9.0e99) session_low=lo;
  }

void AddLevel(const string id,const string type,const string source,const double price,const double strength,
              const int age,const int bias)
  {
   if(price<=0.0 || !MathIsValidNumber(price)) return;
   int n=ArraySize(g_levels);
   if(n>=96) return;
   PriceLevel l;
   l.id=id; l.type=type; l.source=source; l.price=price; l.strength=strength;
   l.age_bars=age; l.bias=bias; l.valid=true;
   ArrayResize(g_levels,n+1);
   g_levels[n]=l;
  }

int LevelAgeFromTime(const datetime t)
  {
   if(t<=0) return 9999;
   int s=iBarShift(_Symbol,g_workTF,t,true);
   if(s<0) s=iBarShift(_Symbol,g_workTF,t,false);
   return s<0 ? 9999 : s;
  }

void BuildLevelObjects(const double atr)
  {
   ArrayResize(g_levels,0);

   AddLevel("WOPEN","TEMPORAL","WeeklyOpen",g_map.weekly_open,60.0,0,REGION_NEUTRAL);
   AddLevel("DOPEN","TEMPORAL","DailyOpen",g_map.daily_open,55.0,0,REGION_NEUTRAL);
   if(InpUseMonthlyContext)
      AddLevel("MOPEN","TEMPORAL","MonthlyOpen",g_map.monthly_open,45.0,0,REGION_NEUTRAL);

   AddLevel("PW_HIGH","EXTREME","PreviousWeekHigh",g_map.previous_week_high,72.0,InpMapLookbackDays*24,REGION_RESIST);
   AddLevel("PW_LOW","EXTREME","PreviousWeekLow",g_map.previous_week_low,72.0,InpMapLookbackDays*24,REGION_SUPPORT);
   AddLevel("PD_HIGH","EXTREME","PreviousDayHigh",g_map.previous_day_high,68.0,24,REGION_RESIST);
   AddLevel("PD_LOW","EXTREME","PreviousDayLow",g_map.previous_day_low,68.0,24,REGION_SUPPORT);
   AddLevel("CW_HIGH","EXTREME","CurrentWeekHigh",g_map.current_week_high,64.0,0,REGION_RESIST);
   AddLevel("CW_LOW","EXTREME","CurrentWeekLow",g_map.current_week_low,64.0,0,REGION_SUPPORT);
   AddLevel("CD_HIGH","EXTREME","CurrentDayHigh",g_map.current_day_high,60.0,0,REGION_RESIST);
   AddLevel("CD_LOW","EXTREME","CurrentDayLow",g_map.current_day_low,60.0,0,REGION_SUPPORT);

   AddLevel("WM_UP","MIDPOINT","WeeklyExpansionMidUp",g_map.weekly_mid_up,58.0,0,REGION_NEUTRAL);
   AddLevel("WM_DN","MIDPOINT","WeeklyExpansionMidDown",g_map.weekly_mid_down,58.0,0,REGION_NEUTRAL);
   AddLevel("DM_UP","MIDPOINT","DailyExpansionMidUp",g_map.daily_mid_up,50.0,0,REGION_NEUTRAL);
   AddLevel("DM_DN","MIDPOINT","DailyExpansionMidDown",g_map.daily_mid_down,50.0,0,REGION_NEUTRAL);

   AddLevel("R_HIGH","RANGE","RangeHigh",g_map.range_high,62.0,0,REGION_RESIST);
   AddLevel("R_LOW","RANGE","RangeLow",g_map.range_low,62.0,0,REGION_SUPPORT);
   AddLevel("R_MID","RANGE","RangeMid",g_map.range_mid,45.0,0,REGION_NEUTRAL);

   if(InpUseSessionMap)
     {
      AddLevel("SOPEN","TEMPORAL","SessionOpen",g_map.session_open,52.0,0,REGION_NEUTRAL);
      AddLevel("S_HIGH","EXTREME","SessionHigh",g_map.session_high,60.0,0,REGION_RESIST);
      AddLevel("S_LOW","EXTREME","SessionLow",g_map.session_low,60.0,0,REGION_SUPPORT);
     }

   for(int i=0;i<ArraySize(g_workHighs);i++)
     {
      if(!g_workHighs[i].confirmed) continue;
      if(g_workHighs[i].shift>InpMaxSwingAgeBars) continue;
      AddLevel("SH"+IntegerToString(i),"SWING","SwingHigh",g_workHighs[i].price,
               g_workHighs[i].major?70.0:58.0,g_workHighs[i].shift,REGION_RESIST);
     }
   for(int i=0;i<ArraySize(g_workLows);i++)
     {
      if(!g_workLows[i].confirmed) continue;
      if(g_workLows[i].shift>InpMaxSwingAgeBars) continue;
      AddLevel("SL"+IntegerToString(i),"SWING","SwingLow",g_workLows[i].price,
               g_workLows[i].major?70.0:58.0,g_workLows[i].shift,REGION_SUPPORT);
     }

   if(g_lta.valid)
     AddLevel("LTA","GEOMETRY","LTA",LinePrice(g_lta,TimeTradeServer()),75.0,0,REGION_SUPPORT);
   if(g_ltb.valid)
     AddLevel("LTB","GEOMETRY","LTB",LinePrice(g_ltb,TimeTradeServer()),75.0,0,REGION_RESIST);
   if(g_channelUp.valid)
     {
      AddLevel("CHUP_B","GEOMETRY","ChannelUpBottom",LinePrice(g_channelUp.bottom,TimeTradeServer()),78.0,0,REGION_SUPPORT);
      AddLevel("CHUP_T","GEOMETRY","ChannelUpTop",LinePrice(g_channelUp.top,TimeTradeServer()),78.0,0,REGION_RESIST);
     }
   if(g_channelDown.valid)
     {
      AddLevel("CHDN_B","GEOMETRY","ChannelDownBottom",LinePrice(g_channelDown.bottom,TimeTradeServer()),78.0,0,REGION_SUPPORT);
      AddLevel("CHDN_T","GEOMETRY","ChannelDownTop",LinePrice(g_channelDown.top,TimeTradeServer()),78.0,0,REGION_RESIST);
     }
  }

//====================================================================
// TRENDLINE / CHANNEL ENGINE
//====================================================================
double LinePrice(const Trendline &line,const datetime when)
  {
   if(!line.valid || line.t2<=line.t1) return 0.0;
   return line.p1+line.slope_price_per_sec*(double)(when-line.t1);
  }

double TrendlineScoreFromSwings(const Swing &s1,const Swing &s2,const Swing &s3,const double atr,const double line_tol)
  {
   if(atr<=0.0 || s2.time<=s1.time || s3.time<=s2.time) return 0.0;
   double slope=(s2.price-s1.price)/(double)(s2.time-s1.time);
   double pred3=s1.price+slope*(double)(s3.time-s1.time);
   double touch_error=SafeDiv(MathAbs(pred3-s3.price),atr);
   double touch_quality=ClampD(1.0-touch_error/SafeDiv(line_tol,atr),0.0,1.0);
   double slope_norm=SafeDiv(MathAbs(slope)*(double)PeriodSeconds(g_workTF),atr);
   double slope_stability=ClampD(slope_norm/0.25,0.0,1.0);
   double recency=ClampD(1.0-(double)s3.shift/(double)InpMaxSwingAgeBars,0.0,1.0);
   double break_integrity=1.0;
   double score=100.0*(0.35*touch_quality+0.25*slope_stability+0.20*recency+0.20*break_integrity);
   return ClampD(score,0.0,100.0);
  }

void BuildTrendlines(const double atr,const Swing &highs[],const Swing &lows[])
  {
   g_lta.valid=false; g_lta.state="INVALID"; g_lta.touches=0; g_lta.score=0.0;
   g_ltb.valid=false; g_ltb.state="INVALID"; g_ltb.touches=0; g_ltb.score=0.0;
   if(atr<=0.0) return;

   double tol=MathMax(InpLineToleranceATR*atr,2.0*CurrentSpread());
   double break_buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());

   if(ArraySize(lows)>=3)
     {
      Swing s1=lows[2],s2=lows[1],s3=lows[0];
      if(s2.time>s1.time && s3.time>s2.time && s2.price>s1.price && s3.price>s2.price)
        {
         double slope=(s2.price-s1.price)/(double)(s2.time-s1.time);
         double pred3=s1.price+slope*(double)(s3.time-s1.time);
         bool touch=MathAbs(pred3-s3.price)<=tol;
         bool intact=true;
         MqlRates r[]; int total=LoadRates(g_workTF,MathMin(InpStructureLookbackBars+10,220),r);
         if(total>10)
           {
            int from=iBarShift(_Symbol,g_workTF,s3.time,false);
            if(from<1) from=1;
            int to=1;
            for(int sh=from;sh>=to;sh--)
              {
               double lp=s1.price+slope*(double)(r[sh].time-s1.time);
               if(r[sh].close<lp-break_buffer) { intact=false; break; }
              }
           }
         if(touch && intact)
           {
            g_lta.valid=true; g_lta.bullish=true;
            g_lta.t1=s1.time; g_lta.t2=s2.time;
            g_lta.p1=s1.price; g_lta.p2=s2.price;
            g_lta.slope_price_per_sec=slope; g_lta.touches=3;
            g_lta.score=TrendlineScoreFromSwings(s1,s2,s3,atr,tol);
            g_lta.validation_time=TimeTradeServer(); g_lta.state="VALID";
           }
        }
     }

   if(ArraySize(highs)>=3)
     {
      Swing s1=highs[2],s2=highs[1],s3=highs[0];
      if(s2.time>s1.time && s3.time>s2.time && s2.price<s1.price && s3.price<s2.price)
        {
         double slope=(s2.price-s1.price)/(double)(s2.time-s1.time);
         double pred3=s1.price+slope*(double)(s3.time-s1.time);
         bool touch=MathAbs(pred3-s3.price)<=tol;
         bool intact=true;
         MqlRates r[]; int total=LoadRates(g_workTF,MathMin(InpStructureLookbackBars+10,220),r);
         if(total>10)
           {
            int from=iBarShift(_Symbol,g_workTF,s3.time,false);
            if(from<1) from=1;
            for(int sh=from;sh>=1;sh--)
              {
               double lp=s1.price+slope*(double)(r[sh].time-s1.time);
               if(r[sh].close>lp+break_buffer) { intact=false; break; }
              }
           }
         if(touch && intact)
           {
            g_ltb.valid=true; g_ltb.bullish=false;
            g_ltb.t1=s1.time; g_ltb.t2=s2.time;
            g_ltb.p1=s1.price; g_ltb.p2=s2.price;
            g_ltb.slope_price_per_sec=slope; g_ltb.touches=3;
            g_ltb.score=TrendlineScoreFromSwings(s1,s2,s3,atr,tol);
            g_ltb.validation_time=TimeTradeServer(); g_ltb.state="VALID";
           }
        }
     }
  }

void BuildChannel(const bool bullish,const Swing &highs[],const Swing &lows[],const double atr,Channel &channel)
  {
   channel.valid=false;
   channel.bullish=bullish;
   channel.width=0.0;
   channel.width_norm=0.0;
   channel.score=0.0;
   channel.state="INVALID";
   channel.top.valid=false;
   channel.bottom.valid=false;

   if(atr<=0.0 || ArraySize(highs)<3 || ArraySize(lows)<3) return;

   Swing h1=highs[2],h2=highs[1],h3=highs[0];
   Swing l1=lows[2],l2=lows[1],l3=lows[0];
   if(h2.time<=h1.time || h3.time<=h2.time || l2.time<=l1.time || l3.time<=l2.time) return;

   double top_slope=(h2.price-h1.price)/(double)(h2.time-h1.time);
   double bot_slope=(l2.price-l1.price)/(double)(l2.time-l1.time);
   double top_norm=SafeDiv(top_slope*(double)PeriodSeconds(g_workTF),atr);
   double bot_norm=SafeDiv(bot_slope*(double)PeriodSeconds(g_workTF),atr);
   double slope_eps=0.015;
   if(bullish)
     {
      if(top_norm<=slope_eps || bot_norm<=slope_eps) return;
     }
   else
     {
      if(top_norm>=-slope_eps || bot_norm>=-slope_eps) return;
     }
   if(MathAbs(top_norm-bot_norm)>InpChannelSlopeTolerance) return;

   double top_pred3=h1.price+top_slope*(double)(h3.time-h1.time);
   double bot_pred3=l1.price+bot_slope*(double)(l3.time-l1.time);
   double tol=MathMax(InpLineToleranceATR*atr,2.0*CurrentSpread());
   if(MathAbs(top_pred3-h3.price)>tol || MathAbs(bot_pred3-l3.price)>tol) return;

   Trendline top; top.valid=true; top.bullish=false;
   top.t1=h1.time; top.t2=h2.time; top.p1=h1.price; top.p2=h2.price;
   top.slope_price_per_sec=top_slope; top.touches=3;
   top.score=TrendlineScoreFromSwings(h1,h2,h3,atr,tol);
   top.validation_time=TimeTradeServer(); top.state="VALID";

   Trendline bottom; bottom.valid=true; bottom.bullish=true;
   bottom.t1=l1.time; bottom.t2=l2.time; bottom.p1=l1.price; bottom.p2=l2.price;
   bottom.slope_price_per_sec=bot_slope; bottom.touches=3;
   bottom.score=TrendlineScoreFromSwings(l1,l2,l3,atr,tol);
   bottom.validation_time=TimeTradeServer(); bottom.state="VALID";

   datetime now=TimeTradeServer();
   double top_now=LinePrice(top,now);
   double bot_now=LinePrice(bottom,now);
   if(top_now<=bot_now) return;
   double width=top_now-bot_now;
   double width_norm=SafeDiv(width,atr);
   if(width_norm<InpMinChannelWidthATR || width_norm>InpMaxChannelWidthATR) return;

   channel.valid=true;
   channel.top=top;
   channel.bottom=bottom;
   channel.width=width;
   channel.width_norm=width_norm;
   channel.score=(top.score+bottom.score)/2.0;
   channel.state="VALID";
   double width_old=MathAbs(LinePrice(top,l1.time)-LinePrice(bottom,l1.time));
   if(width_old>0.0)
     {
      if(width>width_old*1.15) channel.state="EXPANDING";
      else if(width<width_old*0.85) channel.state="COMPRESSED";
     }
  }

//====================================================================
// REGION ENGINE
//====================================================================
void AddSource(string &s1,string &s2,string &s3,int &count,const string source)
  {
   if(count==0){s1=source;count++;return;}
   if(count==1){s2=source;count++;return;}
   if(count==2){s3=source;count++;return;}
  }

void BuildRegions(const double price,const double atr)
  {
   ArrayResize(g_regions,0);
   int n=ArraySize(g_levels);
   if(n<=0) return;
   bool used[96];
   ArrayInitialize(used,false);
   double confluence_tol=MathMax(InpConfluenceATR*atr,2.0*CurrentSpread());
   double activation=MathMax(InpRegionActivationATR*atr,2.0*CurrentSpread());

   for(int i=0;i<n;i++)
     {
      if(used[i] || !g_levels[i].valid) continue;

      used[i]=true;
      double center=g_levels[i].price;
      double weighted_sum=center*g_levels[i].strength;
      double weight_sum=g_levels[i].strength;
      double low=center,high=center;
      int source_count=0;
      int support_count=0,resist_count=0;
      int visible_count=0;
      string s1="",s2="",s3="";
      source_count=1;
      AddSource(s1,s2,s3,visible_count,g_levels[i].source);
      if(g_levels[i].bias>0) support_count++;
      if(g_levels[i].bias<0) resist_count++;

      // Two-pass clustering converges the weighted center without mutating history.
      for(int pass=0;pass<2;pass++)
        {
         for(int j=0;j<n;j++)
           {
            if(used[j] || !g_levels[j].valid) continue;
            if(MathAbs(g_levels[j].price-center)<=confluence_tol)
              {
               used[j]=true;
               double freshness=MathExp(-g_levels[j].age_bars/MathMax(InpDecayBars,1.0));
               double w=g_levels[j].strength*freshness;
               weighted_sum+=g_levels[j].price*w;
               weight_sum+=w;
               low=MathMin(low,g_levels[j].price);
               high=MathMax(high,g_levels[j].price);
               source_count++;
               AddSource(s1,s2,s3,visible_count,g_levels[j].source);
               if(g_levels[j].bias>0) support_count++;
               if(g_levels[j].bias<0) resist_count++;
               center=SafeDiv(weighted_sum,weight_sum);
              }
           }
        }

      double zone_width=MathMax(InpZoneAlphaATR*atr,MathMax(2.0*CurrentSpread(),_Point));
      zone_width=MathMin(zone_width,InpZoneMaxATR*atr);
      low=MathMin(low,center-zone_width/2.0);
      high=MathMax(high,center+zone_width/2.0);

      double avg_strength=SafeDiv(weight_sum,(double)MathMax(source_count,1));
      double freshness_quality=ClampD(avg_strength/100.0,0.0,1.0);
      double liquidity_quality=(StringContains(s1,"Swing") || StringContains(s1,"Session") ||
                                StringContains(s1,"Previous") || StringContains(s1,"Equal") ||
                                StringContains(s2,"Swing") || StringContains(s2,"Session") ||
                                StringContains(s2,"Previous") || StringContains(s3,"Swing")) ? 1.0 : 0.50;
      double geometry_quality=(StringContains(s1,"LTA") || StringContains(s1,"LTB") ||
                               StringContains(s1,"Channel") || StringContains(s2,"LTA") ||
                               StringContains(s2,"LTB") || StringContains(s2,"Channel") ||
                               StringContains(s3,"LTA") || StringContains(s3,"LTB") ||
                               StringContains(s3,"Channel")) ? 1.0 : 0.50;
      double location_quality=1.0-ClampD(NormDistance(price,center,atr)/SafeDiv(activation*3.0,atr),0.0,1.0);
      double structure_quality=(source_count>=2)?1.0:0.60;
      double space_quality=0.50;
      double score=100.0*(0.20*location_quality+0.20*structure_quality+0.15*liquidity_quality+
                          0.15*geometry_quality+0.15*freshness_quality+0.15*space_quality);
      score=ClampD(score,0.0,100.0);
      bool active=(MathAbs(price-center)<=activation*3.0);
      int bias=REGION_NEUTRAL;
      if(support_count>resist_count) bias=REGION_SUPPORT;
      else if(resist_count>support_count) bias=REGION_RESIST;
      if(source_count<2 && avg_strength<65.0) active=false;

      Region r;
      string key=_Symbol+"|"+TFToShort(g_workTF)+"|"+DoubleToString(center,(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS))+"|"+s1+"|"+s2+"|"+s3;
      r.id=StableId("R",key);
      r.type=(source_count>=2 ? "COMPOSITE" : g_levels[i].type);
      r.source1=s1; r.source2=s2; r.source3=s3;
      r.low=low; r.high=high; r.center=center;
      r.score=score; r.strength=avg_strength; r.source_count=source_count;
      r.bias=bias; r.active=active; r.valid=(source_count>=2 || avg_strength>=65.0);
      int rn=ArraySize(g_regions);
      if(rn<32)
        {
         ArrayResize(g_regions,rn+1);
         g_regions[rn]=r;
        }
     }
  }

int BestActiveRegionForDirection(const int direction,const double price,const double atr)
  {
   int best=-1;
   double best_score=-1.0e9;
   double activation=MathMax(InpRegionActivationATR*atr,2.0*CurrentSpread());
   double buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());
   for(int i=0;i<ArraySize(g_regions);i++)
     {
      Region r=g_regions[i];
      if(!r.valid) continue;
      double dist=0.0;
      if(price<r.low) dist=r.low-price;
      else if(price>r.high) dist=price-r.high;
      if(dist>activation*3.0) continue;

      bool direct=(direction>0 && r.bias==REGION_SUPPORT) || (direction<0 && r.bias==REGION_RESIST);
      bool neutral=(r.bias==REGION_NEUTRAL);
      bool broken_in_direction=(direction>0 && price>r.high+buffer) || (direction<0 && price<r.low-buffer);
      bool breakout_candidate=(direction>0 && r.bias==REGION_RESIST && !broken_in_direction) ||
                               (direction<0 && r.bias==REGION_SUPPORT && !broken_in_direction);

      // A counter-bias region is never a direct rejection candidate.
      // It is considered only as a breakout/retest candidate, and only when price has
      // actually crossed the region. Neutral regions are weaker and cannot masquerade as S/R.
      if(!direct && !(neutral) && !broken_in_direction) continue;
      if(breakout_candidate) continue;

      double proximity=1.0-ClampD(SafeDiv(dist,activation),0.0,1.0);
      double candidate=r.score+25.0*proximity;
      if(direct) candidate+=18.0;
      else if(neutral) candidate+=2.0;
      else candidate+=8.0;

      // If the region is on the wrong side of the current price for a direct reaction,
      // require an actual breakout crossing before allowing it.
      if(direction>0 && r.bias==REGION_SUPPORT && r.low>price+activation) continue;
      if(direction<0 && r.bias==REGION_RESIST && r.high<price-activation) continue;

      if(candidate>best_score)
        {
         best_score=candidate;
         best=i;
        }
     }
   return best;
  }

//====================================================================
// CONTEXT ENGINE
//====================================================================
int FindTFIndex(const ContextSnapshot &ctx,const ENUM_TIMEFRAMES tf)
  {
   for(int i=0;i<5;i++)
      if(ctx.tfs[i].tf==tf) return i;
   return -1;
  }

void FillContext(const ENUM_TIMEFRAMES tf,const int index,ContextSnapshot &ctx,double weight,double &weighted_sum,double &weight_sum)
  {
   TFAnalysis a=AnalyzeTF(tf);
   ctx.tfs[index]=a;
   if(!a.data_ok) return;
   weighted_sum+=(double)a.signal*weight;
   weight_sum+=weight;
  }

ContextSnapshot EvaluateContext()
  {
   ContextSnapshot ctx;
   for(int i=0;i<5;i++)
     {
      ctx.tfs[i].tf=PERIOD_CURRENT;
      ctx.tfs[i].data_ok=false;
      ctx.tfs[i].signal=0;
      ctx.tfs[i].strength=0.0;
     }
   double weighted_sum=0.0,weight_sum=0.0;

   if(g_workTF==PERIOD_M15)
     {
      int idx=0;
      if(InpUseMonthlyContext){ FillContext(PERIOD_MN1,idx++,ctx,0.10,weighted_sum,weight_sum); }
      if(InpUseWeeklyContext){ FillContext(PERIOD_W1,idx++,ctx,0.25,weighted_sum,weight_sum); }
      if(InpUseDailyContext){ FillContext(PERIOD_D1,idx++,ctx,0.30,weighted_sum,weight_sum); }
      if(InpUseH4Context){ FillContext(PERIOD_H4,idx++,ctx,0.25,weighted_sum,weight_sum); }
      FillContext(PERIOD_M15,idx++,ctx,0.10,weighted_sum,weight_sum);
     }
   else if(g_workTF==PERIOD_M5)
     {
      FillContext(PERIOD_H1,0,ctx,0.40,weighted_sum,weight_sum);
      FillContext(PERIOD_M15,1,ctx,0.40,weighted_sum,weight_sum);
      FillContext(PERIOD_M5,2,ctx,0.20,weighted_sum,weight_sum);
     }
   else
     {
      FillContext(PERIOD_M15,0,ctx,0.45,weighted_sum,weight_sum);
      FillContext(PERIOD_M5,1,ctx,0.45,weighted_sum,weight_sum);
      FillContext(PERIOD_M1,2,ctx,0.10,weighted_sum,weight_sum);
     }

   ctx.weighted_sum=weighted_sum;
   ctx.weight_sum=weight_sum;
   ctx.direction=(weighted_sum>0.20?1:(weighted_sum<-0.20?-1:0));
   ctx.strength=SafeDiv(MathAbs(weighted_sum),MathMax(weight_sum,0.0001))*100.0;
   ctx.strength=ClampD(ctx.strength,0.0,100.0);
   if(ctx.direction==0 || ctx.strength<InpContextAlignedStrength) ctx.class_name="NEUTRAL";
   else ctx.class_name=(ctx.strength>=InpContextConflictStrength?"ALIGNED":"TRANSITION");
   if(ctx.direction!=0 && ctx.strength>=InpContextConflictStrength)
      ctx.class_name="ALIGNED";
   return ctx;
  }

bool ContextAllowsDirection(const ContextSnapshot &ctx,const int direction,const bool reversal_setup)
  {
   if(ctx.weight_sum<=0.0) return false;
   if(ctx.direction==0 || ctx.strength<InpContextAlignedStrength)
      return true;
   if(ctx.direction==direction)
      return true;
   if(reversal_setup && InpAllowCounterTrendReversal)
      return true;
   return false;
  }

double ContextQuality(const ContextSnapshot &ctx,const int direction,const bool reversal_setup)
  {
   if(ctx.direction==0 || ctx.strength<InpContextAlignedStrength)
      return 0.65;
   if(ctx.direction==direction)
      return ClampD(0.55+0.45*ctx.strength/100.0,0.0,1.0);
   if(reversal_setup && InpAllowCounterTrendReversal)
      return 0.55;
   return 0.20;
  }

//====================================================================
// EVENT / REACTION HELPERS
//====================================================================
void GetCandleMetrics(const MqlRates &bar,const int direction,double atr,double &rejection,double &close_location,double &body_norm)
  {
   double range=MathMax(bar.high-bar.low,_Point);
   double body=MathAbs(bar.close-bar.open);
   body_norm=SafeDiv(body,atr);
   close_location=SafeDiv(bar.close-bar.low,range);
   if(direction>0)
     rejection=SafeDiv(MathMin(bar.open,bar.close)-bar.low,range);
   else
     rejection=SafeDiv(bar.high-MathMax(bar.open,bar.close),range);
  }

bool DetectRecentSweep(const Region &region,const int direction,const MqlRates &rates[],const int total,
                       const double atr,int &bars_ago,double &sweep_level)
  {
   bars_ago=-1;
   sweep_level=region.center;
   if(total<3) return false;
   double break_buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());
   double reentry_tol=MathMax(InpConfluenceATR*atr,2.0*CurrentSpread());
   double pool=direction>0?region.low:region.high;
   for(int s=1;s<=MathMin(InpTriggerLookbackBars,total-1);s++)
     {
      if(direction>0)
        {
         double overshoot=pool-rates[s].low;
         if(rates[s].low<pool-break_buffer && rates[s].close>=pool-reentry_tol && SafeDiv(overshoot,atr)<=InpSweepMaxDepthATR)
           {
            bars_ago=s;
            sweep_level=pool;
            return true;
           }
        }
      else
        {
         double overshoot=rates[s].high-pool;
         if(rates[s].high>pool+break_buffer && rates[s].close<=pool+reentry_tol && SafeDiv(overshoot,atr)<=InpSweepMaxDepthATR)
           {
            bars_ago=s;
            sweep_level=pool;
            return true;
           }
        }
     }
   return false;
  }

bool DetectBreakout(const Region &region,const int direction,const MqlRates &rates[],const int total,const double atr)
  {
   if(total<4) return false;
   double buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());
   if(direction>0)
      return rates[1].close>region.high+buffer && rates[2].close<=region.high+buffer;
   return rates[1].close<region.low-buffer && rates[2].close>=region.low-buffer;
  }

bool DetectRetest(const Region &region,const int direction,const MqlRates &rates[],const int total,const double atr)
  {
   if(total<5) return false;
   double tol=MathMax(InpConfluenceATR*atr,2.0*CurrentSpread());
   double level=direction>0?region.high:region.low;
   bool prior_break=false;
   for(int s=2;s<=MathMin(4,total-1);s++)
     {
      if(direction>0 && rates[s].close>region.high+MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread())) prior_break=true;
      if(direction<0 && rates[s].close<region.low-MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread())) prior_break=true;
     }
   if(!prior_break) return false;
   if(direction>0)
      return rates[1].low<=level+tol && rates[1].close>level;
   return rates[1].high>=level-tol && rates[1].close<level;
  }

bool DetectTrendlineTouch(const Trendline &line,const int direction,const MqlRates &bar,const double atr)
  {
   if(!line.valid) return false;
   double tol=MathMax(InpLineToleranceATR*atr,2.0*CurrentSpread());
   double lp=LinePrice(line,bar.time);
   if(lp<=0.0) return false;
   if(direction>0)
      return MathAbs(bar.low-lp)<=tol || MathAbs(bar.close-lp)<=tol;
   return MathAbs(bar.high-lp)<=tol || MathAbs(bar.close-lp)<=tol;
  }

bool DetectSRTouch(const Region &region,const MqlRates &bar,const double atr)
  {
   double tol=MathMax(InpConfluenceATR*atr,2.0*CurrentSpread());
   return IsNear(bar.high,region.low,region.high,tol) || IsNear(bar.low,region.low,region.high,tol) ||
          IsNear(bar.close,region.low,region.high,tol);
  }

bool DetectMicroStructureShift(const ENUM_TIMEFRAMES tf,const int direction,const double atr,
                               const int max_event_shift,bool &shift_out,bool &bos_out,int &bars_ago_out)
  {
   shift_out=false; bos_out=false; bars_ago_out=-1;
   Swing highs[],lows[];
   CollectSwings(tf,highs,lows);
   if(ArraySize(highs)<1 || ArraySize(lows)<1) return false;
   MqlRates rates[];
   int total=LoadRates(tf,InpStructureLookbackBars+InpATRPeriod+InpSwingFractalRadius+20,rates);
   if(total<10) return false;
   double buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());
   int pre=DetermineStructureSignal(highs,lows);
   int look=(int)MathMin(InpTriggerLookbackBars,total-1);
   if(max_event_shift>0) look=(int)MathMin(look,max_event_shift);
   for(int s=1;s<=look;s++)
     {
      if(direction>0 && rates[s].close>highs[0].price+buffer)
        {
         bos_out=true;
         if(pre<=0) shift_out=true;
         bars_ago_out=s;
         return true;
        }
      if(direction<0 && rates[s].close<lows[0].price-buffer)
        {
         bos_out=true;
         if(pre>=0) shift_out=true;
         bars_ago_out=s;
         return true;
        }
     }
   return false;
  }

bool DetectDisplacement(const int direction,const MqlRates &bar,const MqlRates &rates[],const int bar_shift,const double atr)
  {
   double body_norm=SafeDiv(MathAbs(bar.close-bar.open),atr);
   if(body_norm<InpMinBodyATR) return false;
   if(direction>0 && bar.close<=bar.open) return false;
   if(direction<0 && bar.close>=bar.open) return false;
   double buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());
   double micro_high=-1.0e100, micro_low=1.0e100;
   int available=0;
   for(int s=bar_shift+1;s<=bar_shift+3 && s<ArraySize(rates);s++)
     {
      micro_high=MathMax(micro_high,rates[s].high);
      micro_low=MathMin(micro_low,rates[s].low);
      available++;
     }
   if(available<2) return false;
   if(direction>0) return bar.close>micro_high+buffer;
   return bar.close<micro_low-buffer;
  }

//====================================================================
// IMPULSE / RETRACEMENT ENGINE
//====================================================================
bool FindRecentDirectionalImpulse(const int direction,const double atr,double &start,double &end,double &ratio,double &efficiency)
  {
   start=0.0; end=0.0; ratio=0.0; efficiency=0.0;
   MqlRates rates[];
   int total=LoadRates(g_workTF,InpStructureLookbackBars+InpATRPeriod+InpSwingFractalRadius+25,rates);
   if(total<10 || atr<=0.0) return false;
   double buffer=MathMax(InpBreakBufferATR*atr,1.5*CurrentSpread());

   if(direction>0 && ArraySize(g_workLows)>=1 && ArraySize(g_workHighs)>=1)
     {
      for(int h=0;h<ArraySize(g_workHighs);h++)
        {
         int s_high=iBarShift(_Symbol,g_workTF,g_workHighs[h].time,false);
         if(s_high<1) continue;
         for(int l=0;l<ArraySize(g_workLows);l++)
           {
            int s_low=iBarShift(_Symbol,g_workTF,g_workLows[l].time,false);
            if(s_low<=s_high) continue;
            double dist=g_workHighs[h].price-g_workLows[l].price;
            if(dist/MathMax(atr,_Point)<InpMinImpulseATR) continue;
            double sum_tr=0.0; int used=0;
            for(int sh=s_high;sh<s_low && sh+1<total;sh++)
              {
               double tr1=rates[sh].high-rates[sh].low;
               double tr2=MathAbs(rates[sh].high-rates[sh+1].close);
               double tr3=MathAbs(rates[sh].low-rates[sh+1].close);
               sum_tr+=MathMax(tr1,MathMax(tr2,tr3)); used++;
              }
            efficiency=SafeDiv(dist,MathMax(sum_tr,_Point));
            double current_close=rates[1].close;
            double retr=MathMax(0.0,g_workHighs[h].price-current_close);
            ratio=SafeDiv(retr,dist);
            start=g_workLows[l].price; end=g_workHighs[h].price;
            bool origin_intact=current_close>start+buffer;
            bool end_not_invalidated=current_close<end+buffer;
            return used>0 && efficiency>=InpMinEfficiency && ratio>=InpMinRetracement && ratio<=InpMaxPullback && origin_intact && end_not_invalidated;
           }
        }
     }

   if(direction<0 && ArraySize(g_workHighs)>=1 && ArraySize(g_workLows)>=1)
     {
      for(int l=0;l<ArraySize(g_workLows);l++)
        {
         int s_low=iBarShift(_Symbol,g_workTF,g_workLows[l].time,false);
         if(s_low<1) continue;
         for(int h=0;h<ArraySize(g_workHighs);h++)
           {
            int s_high=iBarShift(_Symbol,g_workTF,g_workHighs[h].time,false);
            if(s_high<=s_low) continue;
            double dist=g_workHighs[h].price-g_workLows[l].price;
            if(dist/MathMax(atr,_Point)<InpMinImpulseATR) continue;
            double sum_tr=0.0; int used=0;
            for(int sh=s_low;sh<s_high && sh+1<total;sh++)
              {
               double tr1=rates[sh].high-rates[sh].low;
               double tr2=MathAbs(rates[sh].high-rates[sh+1].close);
               double tr3=MathAbs(rates[sh].low-rates[sh+1].close);
               sum_tr+=MathMax(tr1,MathMax(tr2,tr3)); used++;
              }
            efficiency=SafeDiv(dist,MathMax(sum_tr,_Point));
            double current_close=rates[1].close;
            double retr=MathMax(0.0,current_close-g_workLows[l].price);
            ratio=SafeDiv(retr,dist);
            start=g_workHighs[h].price; end=g_workLows[l].price;
            bool origin_intact=current_close<start-buffer;
            bool end_not_invalidated=current_close>end-buffer;
            return used>0 && efficiency>=InpMinEfficiency && ratio>=InpMinRetracement && ratio<=InpMaxPullback && origin_intact && end_not_invalidated;
           }
        }
     }
   return false;
  }

bool IsPullbackCondition(const int direction,const double ratio)
  {
   return ratio>=InpMinRetracement && ratio<=InpMaxPullback;
  }

//====================================================================
// TRIGGER ENGINE
//====================================================================
TriggerResult EvaluateTrigger(const Region &region,const SetupCandidate &setup,const MqlRates &rates[],const int total,const double atr)
  {
   TriggerResult tr;
   tr.event_ok=false; tr.reaction_ok=false; tr.structure_ok=false; tr.displacement_ok=false;
   tr.confirmed=false; tr.sweep=false; tr.breakout=false; tr.retest=false; tr.trendline_touch=false; tr.sr_touch=false;
   tr.shift_direction=0; tr.event_name="NONE"; tr.reaction_name="NONE"; tr.structure_name="NONE";
   tr.type="NONE"; tr.bars_ago=-1; tr.quality=0.0; tr.sweep_level=0.0;

   if(total<8) return tr;
   MqlRates bar=rates[1];

   tr.sweep=DetectRecentSweep(region,setup.direction,rates,total,atr,tr.bars_ago,tr.sweep_level);
   tr.breakout=DetectBreakout(region,setup.direction,rates,total,atr);
   tr.retest=DetectRetest(region,setup.direction,rates,total,atr);
   tr.sr_touch=DetectSRTouch(region,bar,atr);
   tr.trendline_touch=DetectTrendlineTouch(setup.direction>0?g_lta:g_ltb,setup.direction,bar,atr);

   int event_shift=1;
   if(tr.sweep) { tr.event_ok=true; tr.event_name="SWEEP"; event_shift=(int)MathMax(1,tr.bars_ago); }
   else if(tr.retest) { tr.event_ok=true; tr.event_name="RETEST"; event_shift=1; }
   else if(tr.breakout) { tr.event_ok=true; tr.event_name="BREAKOUT"; event_shift=1; }
   else if(tr.trendline_touch) { tr.event_ok=true; tr.event_name="TRENDLINE_TOUCH"; event_shift=1; }
   else if(tr.sr_touch && region.bias==(setup.direction>0?REGION_SUPPORT:REGION_RESIST))
     { tr.event_ok=true; tr.event_name="REGION_TOUCH"; event_shift=1; }
   else if(region.active && region.bias==REGION_NEUTRAL)
     { tr.event_ok=true; tr.event_name="REGION_ACTIVE"; event_shift=1; }

   // Reaction must occur on or after the event, never before it.
   bool reaction_found=false;
   int reaction_shift=-1;
   double best_q=0.0;
   int end_shift=(int)MathMin(event_shift,total-1);
   for(int s=1;s<=end_shift;s++)
     {
      double rejection=0.0,close_location=0.0,body_norm=0.0;
      GetCandleMetrics(rates[s],setup.direction,atr,rejection,close_location,body_norm);
      bool close_ok=(setup.direction>0?close_location>=InpMinCloseLocationBuy:close_location<=InpMaxCloseLocationSell);
      bool wick_ok=(rejection>=InpMinWickRejection);
      bool response=(wick_ok || close_ok);
      if(tr.retest && s==1) response=true;
      if(tr.breakout && s==1) response=true;
      if(response)
        {
         reaction_found=true;
         reaction_shift=s;
         best_q=MathMax(best_q,MathMax(wick_ok?0.60:0.0,close_ok?0.60:0.0));
         break;
        }
     }
   tr.reaction_ok=reaction_found;
   if(tr.reaction_ok) tr.reaction_name="REJECTION";

   bool shift=false,bos=false;
   int structure_shift=-1;
   DetectMicroStructureShift(g_workTF,setup.direction,atr,event_shift,shift,bos,structure_shift);
   tr.shift_direction=setup.direction;
   if(shift || bos)
     {
      tr.structure_ok=true;
      tr.structure_name=shift?"SHIFT":"BOS";
     }

   tr.displacement_ok=false;
   int disp_look=(int)MathMin(event_shift,total-1);
   for(int ds=1;ds<=disp_look;ds++)
     {
      if(DetectDisplacement(setup.direction,rates[ds],rates,ds,atr))
        { tr.displacement_ok=true; break; }
     }
   if(tr.displacement_ok) tr.type="DISPLACEMENT";

   bool chain_ok=false;
   bool follow_ok=tr.structure_ok && tr.displacement_ok;                 // modo estrito
   if(InpTriggerMode==TRIGGER_BALANCED) follow_ok=tr.structure_ok || tr.displacement_ok;
   if(setup.type=="REVERSAL_SWEEP")
      chain_ok=tr.sweep && tr.reaction_ok && follow_ok;
   else
      chain_ok=tr.event_ok && tr.reaction_ok && follow_ok;

   tr.confirmed=chain_ok;
   double q=0.0;
   q+=tr.event_ok?0.25:0.0;
   q+=tr.reaction_ok?0.25:0.0;
   q+=tr.structure_ok?0.25:0.0;
   q+=tr.displacement_ok?0.25:0.0;
   MqlRates confirm_bar=rates[1];
   double rej=0.0,cl=0.0,body=0.0;
   GetCandleMetrics(confirm_bar,setup.direction,atr,rej,cl,body);
   if(setup.direction>0 && cl>=0.75) q+=0.05;
   if(setup.direction<0 && cl<=0.25) q+=0.05;
   tr.quality=ClampD(q,0.0,1.0);
   return tr;
  }

//====================================================================
// SPACE / TARGET / RISK
//====================================================================
bool FindNearestObstacle(const int direction,const double entry,const double atr,double &obstacle,string &obstacle_source)
  {
   obstacle=0.0;
   obstacle_source="";
   double min_dist=1.0e100;
   double min_required=MathMax(InpMinTargetATR*atr,MathMax(3.0*CurrentSpread(),_Point));
   for(int i=0;i<ArraySize(g_levels);i++)
     {
      if(!g_levels[i].valid) continue;
      double dist=direction>0?(g_levels[i].price-entry):(entry-g_levels[i].price);
      if(dist<min_required) continue;
      if(dist<min_dist)
        {
         min_dist=dist;
         obstacle=g_levels[i].price;
         obstacle_source=g_levels[i].source;
        }
     }
   if(min_dist>=9.0e99)
      return false;
   return true;
  }

double StructuralStop(const int direction,const double entry,const double atr)
  {
   double buffer=MathMax(0.05*atr,CurrentSpread());
   if(direction>0 && ArraySize(g_workLows)>0)
      return NormalizePrice(g_workLows[0].price-buffer);
   if(direction<0 && ArraySize(g_workHighs)>0)
      return NormalizePrice(g_workHighs[0].price+buffer);
   return direction>0?NormalizePrice(entry-InpStopATR*atr):NormalizePrice(entry+InpStopATR*atr);
  }

double BuildSL(const int direction,const double entry,const double atr)
  {
   if(!InpUseStopLoss) return 0.0;
   double structural=StructuralStop(direction,entry,atr);
   double atr_sl=direction>0?entry-InpStopATR*atr:entry+InpStopATR*atr;
   double sl=structural;
   if(InpSLMode==SL_ATR) sl=atr_sl;
   else if(InpSLMode==SL_HYBRID)
     sl=(direction>0?MathMin(structural,atr_sl):MathMax(structural,atr_sl));
   sl=NormalizePrice(sl);
   double min_dist=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
   if(direction>0 && sl>=entry-min_dist) sl=NormalizePrice(entry-min_dist);
   if(direction<0 && sl<=entry+min_dist) sl=NormalizePrice(entry+min_dist);
   return sl;
  }

double BuildTP(const int direction,const double entry,const double sl,const double structural_target,const double atr,const double volume)
  {
   if(!InpUseTakeProfit) return 0.0;
   double ref_risk=InpStopATR*atr;
   if(sl>0.0) ref_risk=MathAbs(entry-sl);
   double rr_tp=direction>0?entry+InpRRMultiple*ref_risk:entry-InpRRMultiple*ref_risk;
   double money_tp=0.0;
   if(InpMoneyTargetPerTrade>0.0 && volume>0.0)
     {
      double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
      double tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
      if(tick_size>0.0 && tick_value>0.0)
        {
         double price_delta=InpMoneyTargetPerTrade*tick_size/(tick_value*volume);
         money_tp=direction>0?entry+price_delta:entry-price_delta;
        }
     }

   double tp=0.0;
   if(InpTPMode==TP_STRUCTURE) tp=structural_target;
   else if(InpTPMode==TP_RR) tp=rr_tp;
   else if(InpTPMode==TP_MONEY) tp=money_tp;
   else
     {
      if(structural_target<=0.0) tp=rr_tp;
      else if(direction>0) tp=MathMin(structural_target,rr_tp);
      else tp=MathMax(structural_target,rr_tp);
     }

   if(tp<=0.0) return 0.0;
   tp=NormalizePrice(tp);
   double min_dist=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
   if(direction>0 && tp<=entry+min_dist) return 0.0;
   if(direction<0 && tp>=entry-min_dist) return 0.0;
   return tp;
  }

double NormalizeVolume(double volume)
  {
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step<=0.0) step=vmin;
   if(InpMaxLots>0.0) vmax=MathMin(vmax,InpMaxLots);
   if(vmax<vmin) vmax=vmin;
   volume=MathMax(vmin,MathMin(volume,vmax));
   volume=MathFloor(volume/step+1.0e-9)*step;
   volume=NormalizeDouble(volume,8);
   if(volume<vmin) volume=vmin;
   return volume;
  }

double CalculateVolume(const double entry,const double sl)
  {
   if(!InpUseRiskSizing || !InpUseStopLoss || sl<=0.0)
      return NormalizeVolume(InpFixedLot);
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double risk_money=equity*InpRiskPercent/100.0;
   double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tick_size<=0.0 || tick_value<=0.0 || risk_money<=0.0)
      return NormalizeVolume(InpFixedLot);
   double distance=MathAbs(entry-sl);
   double loss_per_lot=(distance/tick_size)*tick_value;
   if(loss_per_lot<=0.0)
      return NormalizeVolume(InpFixedLot);
   return NormalizeVolume(risk_money/loss_per_lot);
  }

bool EvaluateSpaceAndTargets(const int direction,const double entry,const double atr,const double volume,
                             double &obstacle,double &space_norm,double &tp,double &sl,string &reason)
  {
   reason="";
   string source="";
   if(!FindNearestObstacle(direction,entry,atr,obstacle,source))
     {
      reason="TARGET_OBSTRUCTED";
      return false;
     }
   space_norm=NormDistance(entry,obstacle,atr);
   double spread_norm=SafeDiv(CurrentSpread(),atr);
   double min_space=MathMax(InpMinSpaceATR,2.0*spread_norm);
   if(space_norm<min_space)
     {
      reason="SPACE_LOW";
      return false;
     }
   sl=BuildSL(direction,entry,atr);
   tp=BuildTP(direction,entry,sl,obstacle,atr,volume);
   if(InpUseTakeProfit && tp<=0.0)
     {
      reason="TARGET_OBSTRUCTED";
      return false;
     }
   return true;
  }

//====================================================================
// SETUP ENGINE
//====================================================================
string ClassifySetup(const int direction,const Region &region,const ContextSnapshot &ctx,const double atr,
                     TriggerResult &trigger_out,bool &reversal,bool &is_breakout,bool &is_sweep,
                     double &liquidity_quality,double &structure_quality)
  {
   reversal=false; is_breakout=false; is_sweep=false;
   liquidity_quality=0.0;
   structure_quality=0.0;

   MqlRates rates[];
   int total=LoadRates(g_workTF,InpTriggerLookbackBars+InpStructureLookbackBars+InpATRPeriod+20,rates);
   if(total<10) return "";

   double imp_start=0.0,imp_end=0.0,retr_ratio=0.0,eff=0.0;
   bool impulse=FindRecentDirectionalImpulse(direction,atr,imp_start,imp_end,retr_ratio,eff);
   bool pullback=impulse && IsPullbackCondition(direction,retr_ratio);

   SetupCandidate setup_probe;
   setup_probe.direction=direction;
   setup_probe.type="S/R_REJECTION";
   TriggerResult tr=EvaluateTrigger(region,setup_probe,rates,total,atr);

   bool aligned_region=(region.bias==(direction>0?REGION_SUPPORT:REGION_RESIST));
   bool opposite_region=(region.bias==(direction>0?REGION_RESIST:REGION_SUPPORT));
   if(InpNeutralRegionsAsSR && region.bias==REGION_NEUTRAL)
     {
      double px=CurrentBid();
      if(direction>0 && region.center<=px) aligned_region=true;    // neutra abaixo do preco = suporte
      if(direction<0 && region.center>=px) aligned_region=true;    // neutra acima do preco = resistencia
     }

   // Reversal is only valid at the corresponding liquidity side and requires the full chain.
   if(tr.sweep && aligned_region)
     {
      is_sweep=true;
      reversal=true;
      liquidity_quality=1.0;
      structure_quality=tr.structure_ok?1.0:0.35;
      trigger_out=tr;
      return "REVERSAL_SWEEP";
     }

   // Breakout requires crossing a region against its prior role.
   if(tr.breakout && opposite_region)
     {
      is_breakout=true;
      liquidity_quality=0.75;
      structure_quality=tr.structure_ok?0.95:0.35;
      trigger_out=tr;
      return "BREAKOUT";
     }
   if(tr.retest && opposite_region)
     {
      liquidity_quality=0.85;
      structure_quality=tr.structure_ok?1.0:0.35;
      trigger_out=tr;
      return "BREAKOUT_RETEST";
     }

   // Continuation/pullback must use a region that supports the trade direction.
   if(aligned_region && pullback)
     {
      liquidity_quality=0.75;
      structure_quality=0.95;
      trigger_out=tr;
      return "PULLBACK";
     }

   if(aligned_region && impulse && ((direction>0 && ctx.direction>=0) || (direction<0 && ctx.direction<=0)))
     {
      liquidity_quality=0.65;
      structure_quality=0.90;
      trigger_out=tr;
      return "CONTINUATION";
     }

   if(aligned_region)
     {
      liquidity_quality=0.70;
      structure_quality=0.80;
      trigger_out=tr;
      if((direction>0 && g_lta.valid && StringContains(region.source1,"LTA")) ||
         (direction<0 && g_ltb.valid && StringContains(region.source1,"LTB")) ||
         StringContains(region.source1,"Channel") || StringContains(region.source2,"Channel"))
         return "TRENDLINE_REJECTION";
      return "S/R_REJECTION";
     }

   return "";
  }

SetupCandidate BuildCandidate(const int direction,const int region_index,const ContextSnapshot &ctx,const double atr)
  {
   SetupCandidate c;
   c.valid=false;
   c.direction=direction;
   c.id=""; c.type=""; c.region_id=""; c.region_index=region_index;
   c.score=0.0;
   c.context_quality=0.0; c.region_quality=0.0; c.liquidity_quality=0.0; c.structure_quality=0.0;
   c.trigger_quality=0.0; c.space_quality=0.0;
   c.entry=0.0; c.sl=0.0; c.tp=0.0; c.nearest_obstacle=0.0; c.space_norm=0.0;
   c.atr=atr; c.spread=CurrentSpread();
   c.space_ok=false; c.context_ok=false; c.structure_ok=false; c.trigger_ok=false;
   c.breakout=false;c.sweep=false;c.reversal=false;
   c.reason_primary="NO_SETUP"; c.reason_secondary="";
   if(region_index<0 || region_index>=ArraySize(g_regions)) return c;
   Region region=g_regions[region_index];
   if(!region.valid) return c;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return c;
   double entry=direction>0?tick.ask:tick.bid;
   c.entry=entry;

   TriggerResult tr;
   bool reversal=false,is_breakout=false,is_sweep=false;
   double liq_q=0.0,struct_q=0.0;
   string type=ClassifySetup(direction,region,ctx,atr,tr,reversal,is_breakout,is_sweep,liq_q,struct_q);
   if(type=="") return c;
   c.type=type;
   c.reversal=reversal;
   c.breakout=is_breakout;
   c.sweep=is_sweep;
   c.trigger=tr;
   c.context_quality=ContextQuality(ctx,direction,reversal);
   c.context_ok=ContextAllowsDirection(ctx,direction,reversal);
   c.region_quality=ClampD(region.score/100.0,0.0,1.0);
   c.liquidity_quality=liq_q;
   c.structure_quality=struct_q;
   c.trigger_quality=tr.quality;

   double volume_guess=NormalizeVolume(InpFixedLot);
   double obstacle=0.0,space=0.0,tp=0.0,sl=0.0;
   string space_reason="";
   c.space_ok=EvaluateSpaceAndTargets(direction,entry,atr,volume_guess,obstacle,space,tp,sl,space_reason);
   c.nearest_obstacle=obstacle;
   c.space_norm=space;
   c.sl=sl;
   c.tp=tp;
   c.space_quality=ClampD(SafeDiv(space,2.5),0.0,1.0);
   c.structure_ok=(InpTriggerMode==TRIGGER_STRICT)?tr.structure_ok:(tr.structure_ok || tr.displacement_ok);
   c.trigger_ok=tr.confirmed;

   // Semantic hard gates: a trade direction must agree with the region role unless
   // the setup is an explicitly classified breakout/retest/reversal.
   bool region_direction_ok=(region.bias==(direction>0?REGION_SUPPORT:REGION_RESIST));
   if(type=="BREAKOUT" || type=="BREAKOUT_RETEST") region_direction_ok=(region.bias==(direction>0?REGION_RESIST:REGION_SUPPORT));
   if(reversal) region_direction_ok=(region.bias==(direction>0?REGION_SUPPORT:REGION_RESIST));
   if(InpNeutralRegionsAsSR && region.bias==REGION_NEUTRAL && type!="BREAKOUT" && type!="BREAKOUT_RETEST")
      region_direction_ok=(direction>0?region.center<=CurrentBid():region.center>=CurrentBid());

   c.score=100.0*(0.20*c.context_quality+0.20*c.region_quality+0.15*c.liquidity_quality+
                  0.15*c.structure_quality+0.15*c.trigger_quality+0.15*c.space_quality);
   if(c.breakout) c.score+=3.0;
   if(c.sweep) c.score+=5.0;
   if(g_context.direction==direction && g_context.strength>=InpContextAlignedStrength) c.score+=3.0;
   if(g_context.direction!=0 && g_context.direction!=direction && g_context.strength>=InpContextConflictStrength && !reversal) c.score-=20.0;
   if(g_lastVolStatus=="HIGH") c.score-=3.0;
   c.score=ClampD(c.score,0.0,100.0);

   string key=_Symbol+"|"+TFToShort(g_workTF)+"|"+region.id+"|"+type+"|"+IntegerToString(direction)+"|"+IntegerToString((int)g_lastDecisionBar);
   c.id=StableId("S",key);
   c.region_id=region.id;

   if(!region_direction_ok) c.reason_primary="REGION_DIRECTION_CONFLICT";
   else if(!c.context_ok) c.reason_primary="CONTEXT_CONFLICT";
   else if(!c.structure_ok) c.reason_primary="NO_STRUCTURE";
   else if(!c.trigger_ok) c.reason_primary=tr.sweep?"SWEEP_NO_REACTION":"NO_TRIGGER";
   else if(!c.space_ok) c.reason_primary=space_reason;
   else if(c.score<InpMinSetupScore) c.reason_primary="SETUP_LOW";
   else c.reason_primary="READY";
   c.reason_secondary=JoinReasons(tr.event_name,tr.structure_name,tr.displacement_ok?"DISPLACEMENT_OK":"DISPLACEMENT_WEAK");
   c.valid=true;
   return c;
  }

void SelectBestSetups(const ContextSnapshot &ctx,const double atr)
  {
   g_bestBuy.valid=false;
   g_bestSell.valid=false;
   int buy_region=BestActiveRegionForDirection(ACTION_BUY,CurrentBid(),atr);
   int sell_region=BestActiveRegionForDirection(ACTION_SELL,CurrentBid(),atr);
   if(buy_region>=0) g_bestBuy=BuildCandidate(ACTION_BUY,buy_region,ctx,atr);
   if(sell_region>=0) g_bestSell=BuildCandidate(ACTION_SELL,sell_region,ctx,atr);
  }

//====================================================================
// FILTERS / DAILY / NEWS / COOLDOWN
//====================================================================
double CurrentSpread()
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return 0.0;
   return MathMax(0.0,tick.ask-tick.bid);
  }

double CurrentBid()
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return 0.0;
   return tick.bid;
  }

double CurrentAsk()
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return 0.0;
   return tick.ask;
  }

void UpdateSpreadStats()
  {
   double s=CurrentSpread();
   if(s<=0.0) return;
   int capacity=(int)MathMin(InpSpreadSamples,100);
   g_spreadBuffer[g_spreadIndex]=s;
   g_spreadIndex=(g_spreadIndex+1)%capacity;
   if(g_spreadCount<capacity) g_spreadCount++;
  }

double MedianSpread()
  {
   if(g_spreadCount<=0) return CurrentSpread();
   double temp[100];
   int n=g_spreadCount;
   for(int i=0;i<n;i++) temp[i]=g_spreadBuffer[i];
   // insertion sort - small fixed buffer, deterministic
   for(int i=1;i<n;i++)
     {
      double key=temp[i];
      int j=i-1;
      while(j>=0 && temp[j]>key)
        { temp[j+1]=temp[j]; j--; }
      temp[j+1]=key;
     }
   if((n%2)==1) return temp[n/2];
   return (temp[n/2-1]+temp[n/2])/2.0;
  }

int SpreadLimitPointsForTF()
  {
   if(g_workTF==PERIOD_M1) return InpMaxSpreadPointsM1;
   if(g_workTF==PERIOD_M5) return InpMaxSpreadPointsM5;
   return InpMaxSpreadPointsM15;
  }

// Filtro de spread em PONTOS (nao depende de ATR). O parametro atr e mantido so por compatibilidade.
bool IsSpreadBlocked(const double atr,string &reason)
  {
   reason="";
   double spread=CurrentSpread();
   g_spreadPts=SafeDiv(spread,_Point);
   g_spreadLimitPts=(double)SpreadLimitPointsForTF();
   if(!InpSpreadFilter) return false;
   if(g_spreadPts>g_spreadLimitPts)
     {
      reason="SPREAD_HIGH";
      return true;
     }
   if(InpSpreadSpikeFilter && g_spreadCount>=10)
     {
      double med=MedianSpread();
      double ratio=SafeDiv(spread,med);
      if(ratio>=InpSpreadSpikeRatio && spread>=InpSpreadMinAbsolutePoints*_Point)
        {
         reason="SPREAD_HIGH";
         return true;
        }
     }
   return false;
  }

bool IsWithinWindow(const int sh,const int sm,const int eh,const int em)
  {
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(),dt);
   int now=dt.hour*60+dt.min;
   int start=sh*60+sm;
   int end=eh*60+em;
   if(start<=end) return now>=start && now<=end;
   return now>=start || now<=end;
  }

bool IsSessionBlocked(string &reason)
  {
   reason="";
   if(!InpSessionFilter) return false;
   if(IsWithinWindow(InpTradeStartHour,InpTradeStartMinute,InpTradeEndHour,InpTradeEndMinute))
      return false;
   reason="SESSION_BLOCK";
   return true;
  }

bool IsNewsBlocked(string &reason)
  {
   reason="";
   if(!InpNewsFilterEnabled)
     {
      g_lastNewsStatus="OFF";
      return false;
     }
   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   datetime from=now-InpNewsMinutesBefore*60;
   datetime to=now+InpNewsMinutesAfter*60;
   MqlCalendarValue values[];
   string currency=InpNewsCurrency;
   int total=CalendarValueHistory(values,from,to,NULL,currency);
   if(total<0)
     {
      g_lastNewsStatus="UNAVAILABLE";
      reason="NEWS_BLOCK";
      return true;
     }
   for(int i=0;i<total;i++)
     {
      MqlCalendarEvent ev;
      if(!CalendarEventById(values[i].event_id,ev)) continue;
      if(ev.importance==CALENDAR_IMPORTANCE_HIGH)
        {
         g_lastNewsStatus="BLOCKED";
         reason="NEWS_BLOCK";
         return true;
        }
     }
   g_lastNewsStatus="CLEAR";
   return false;
  }

bool IsStatsMagic(const long mg);   // declaracao antecipada (definida junto das estatisticas)

void UpdateDailyState()
  {
   static uint s_lastCalc=0;
   uint tick_ms=GetTickCount();
   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   datetime ds=DayStart(now);
   if(s_lastCalc!=0 && ds==g_dayStart && (tick_ms-s_lastCalc)<1000) return;
   s_lastCalc=tick_ms;
   if(g_dayStart!=ds)
     {
      g_dayStart=ds;
      g_dailyTargetHit=false;
     }
   g_dailyPnL=0.0;
   HistorySelect(g_dayStart,now);
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      string sym=HistoryDealGetString(ticket,DEAL_SYMBOL);
      long magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
      if(sym!=_Symbol || !IsStatsMagic(magic)) continue;
      g_dailyPnL+=HistoryDealGetDouble(ticket,DEAL_PROFIT);
      g_dailyPnL+=HistoryDealGetDouble(ticket,DEAL_SWAP);
      g_dailyPnL+=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
     }
   if(InpIncludeFloatingPnL)
     {
      for(int i=0;i<PositionsTotal();i++)
        {
         ulong ticket=PositionGetTicket(i);
         if(ticket==0) continue;
         if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
         if(!IsStatsMagic(PositionGetInteger(POSITION_MAGIC))) continue;
         g_dailyPnL+=PositionGetDouble(POSITION_PROFIT);
        }
     }
   if(InpDailyTargetMoneyEnabled && InpDailyTargetMoney>0.0)
     {
      if(g_dailyPnL>=InpDailyTargetMoney)
         g_dailyTargetHit=true;
     }
   else
      g_dailyTargetHit=false;
  }

//====================================================================
// ESTATISTICAS LIQUIDAS REALIZADAS (dia / semana / mes)
// Liquido = lucro + comissao + swap + taxa. So operacoes ja fechadas: nao oscila com o preco.
//====================================================================
double   g_stNet[3]  = {0.0,0.0,0.0};   // 0=dia 1=semana 2=mes
int      g_stWins[3] = {0,0,0};
int      g_stLoss[3] = {0,0,0};
bool     g_statsDirty = true;
uint     g_statsLastMs = 0;

datetime WeekStartOf(const datetime when)
  {
   datetime ds=DayStart(when);
   MqlDateTime dt;
   TimeToStruct(ds,dt);
   int back=(dt.day_of_week+6)%7;          // segunda-feira = 0
   return ds-(datetime)(back*86400);
  }

datetime MonthStartOf(const datetime when)
  {
   MqlDateTime dt;
   TimeToStruct(when,dt);
   dt.day=1;
   dt.hour=0;
   dt.min=0;
   dt.sec=0;
   return StructToTime(dt);
  }

bool IsStatsMagic(const long mg)
  {
   // sempre o resultado GERAL do EA neste simbolo: M1 + M5 + M15 (mesmo magic base nos 3 graficos)
   return (mg==InpMagicBase+(long)PERIOD_M1 || mg==InpMagicBase+(long)PERIOD_M5 || mg==InpMagicBase+(long)PERIOD_M15);
  }

void UpdateStats(const bool force=false)
  {
   uint ms=GetTickCount();
   if(!force && !g_statsDirty && g_statsLastMs!=0 && (ms-g_statsLastMs)<5000) return;
   g_statsLastMs=ms;
   g_statsDirty=false;

   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   datetime start[3];
   start[0]=DayStart(now);
   start[1]=WeekStartOf(now);
   start[2]=MonthStartOf(now);
   datetime from=(start[1]<start[2])?start[1]:start[2];
   if(start[0]<from) from=start[0];

   double net[3]; int w[3]; int l[3];
   for(int p=0;p<3;p++) { net[p]=0.0; w[p]=0; l[p]=0; }

   if(!HistorySelect(from,now+60)) return;
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong tk=HistoryDealGetTicket(i);
      if(tk==0) continue;
      long type=HistoryDealGetInteger(tk,DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL) continue;
      if(HistoryDealGetString(tk,DEAL_SYMBOL)!=_Symbol) continue;
      if(!IsStatsMagic(HistoryDealGetInteger(tk,DEAL_MAGIC))) continue;
      datetime t=(datetime)HistoryDealGetInteger(tk,DEAL_TIME);
      double v=HistoryDealGetDouble(tk,DEAL_PROFIT)+HistoryDealGetDouble(tk,DEAL_SWAP)+
               HistoryDealGetDouble(tk,DEAL_COMMISSION)+HistoryDealGetDouble(tk,DEAL_FEE);
      long en=HistoryDealGetInteger(tk,DEAL_ENTRY);
      bool closing=(en==DEAL_ENTRY_OUT || en==DEAL_ENTRY_INOUT || en==DEAL_ENTRY_OUT_BY);
      for(int p=0;p<3;p++)
        {
         if(t<start[p]) continue;
         net[p]+=v;
         if(closing)
           {
            if(v>0.0) w[p]++;
            else if(v<0.0) l[p]++;
           }
        }
     }
   for(int p=0;p<3;p++) { g_stNet[p]=net[p]; g_stWins[p]=w[p]; g_stLoss[p]=l[p]; }
  }

int CountEntryDealsToday()
  {
   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   HistorySelect(DayStart(now),now);
   int count=0;
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=g_magic) continue;
      long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(entry==DEAL_ENTRY_IN || entry==DEAL_ENTRY_INOUT) count++;
     }
   return count;
  }

datetime FindLastExitTime()
  {
   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   datetime ds=DayStart(now);
   HistorySelect(ds,now);
   datetime latest=0;
   int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=g_magic) continue;
      long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY && entry!=DEAL_ENTRY_INOUT) continue;
      datetime t=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(t>latest) latest=t;
     }
   return latest;
  }

bool IsCooldownBlocked(string &reason)
  {
   reason="";
   int minutes=InpCooldownM15Minutes;
   if(g_workTF==PERIOD_M5) minutes=InpCooldownM5Minutes;
   if(g_workTF==PERIOD_M1) minutes=InpCooldownM1Minutes;
   if(minutes<=0) return false;
   g_lastExitTime=FindLastExitTime();
   if(g_lastExitTime<=0) return false;
   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   if((now-g_lastExitTime)<minutes*60)
     {
      reason="COOLDOWN";
      return true;
     }
   return false;
  }

int CountManagedPositions()
  {
   int count=0;
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=g_magic) continue;
      count++;
     }
   return count;
  }

// Este EA so abre ordens do TF do grafico onde esta anexado; aqui fica a permissao opcional por TF.
bool TFTradingAllowed()
  {
   if(g_workTF==PERIOD_M1) return InpTradeOnM1;
   if(g_workTF==PERIOD_M5) return InpTradeOnM5;
   return InpTradeOnM15;
  }

// posicoes do AURELIS neste simbolo em QUALQUER TF (magic = base + TF)
int CountAllTFPositions()
  {
   int count=0;
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      long mg=PositionGetInteger(POSITION_MAGIC);
      if(mg==InpMagicBase+(long)PERIOD_M1 || mg==InpMagicBase+(long)PERIOD_M5 || mg==InpMagicBase+(long)PERIOD_M15) count++;
     }
   return count;
  }

bool HasManagedPosition()
  {
   return CountManagedPositions()>0;
  }

bool IsPositionGateBlocked(string &reason)
  {
   reason="";
   if(!TFTradingAllowed())
     {
      reason="TF_DISABLED";
      return true;
     }
   int count=CountManagedPositions();
   if(InpOneTradeAcrossTFs && CountAllTFPositions()>count)
     {
      reason="OTHER_TF_POSITION";
      return true;
     }
   if(InpOnePositionPerTF && count>0)
     {
      reason="POSITION_LIMIT";
      return true;
     }
   if(InpMaxPositions>0 && count>=InpMaxPositions)
     {
      reason="POSITION_LIMIT";
      return true;
     }
   return false;
  }

bool IsDailyBlocked(string &reason)
  {
   reason="";
   if(InpMaxTradesPerDay>0 && CountEntryDealsToday()>=InpMaxTradesPerDay)
     {
      reason="DAILY_LIMIT";
      return true;
     }
   if(InpDailyTargetMoneyEnabled && InpDailyTargetMoney>0.0 && g_dailyTargetHit && InpDailyTargetAction!=DAILY_NONE)
     {
      reason="DAILY_LIMIT";
      return true;
     }
   return false;
  }

//====================================================================
// DECISION ENGINE
//====================================================================
Decision MakeNoTrade(const string reason,const string secondary="")
  {
   Decision d;
   d.action=ACTION_NO_TRADE;
   d.allowed=false;
   d.reason_primary=reason;
   d.reason_secondary=secondary;
   d.score=0.0;
   d.entry=0.0; d.sl=0.0; d.tp=0.0;
   d.region_id="";d.setup_id="";d.trigger_id="";d.setup_type="";
   return d;
  }

Decision EvaluateDecision(const double atr)
  {
   if(g_tradingPaused) return MakeNoTrade("TRADING_PAUSED");
   if(!InpEnableTrading) return MakeNoTrade("TRADING_DISABLED");
   if(atr<=0.0) { g_gData=false; return MakeNoTrade("DATA_INVALID"); }
   g_gData=true;

   g_gAuto=(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)!=0 && MQLInfoInteger(MQL_TRADE_ALLOWED)!=0 &&
            AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)!=0 && AccountInfoInteger(ACCOUNT_TRADE_EXPERT)!=0);
   string r_sp="",r_se="",r_nw="",r_dy="",r_ps="",r_cd="";
   g_gSpread=!IsSpreadBlocked(atr,r_sp);
   g_gSession=!IsSessionBlocked(r_se);
   g_gNews=!IsNewsBlocked(r_nw);
   g_gDaily=!IsDailyBlocked(r_dy);
   g_gPos=!IsPositionGateBlocked(r_ps);
   g_gCool=!IsCooldownBlocked(r_cd);
   if(!g_gAuto) return MakeNoTrade("AUTOTRADING_OFF","Habilite o botao Algo Trading e a opcao Permitir negociacao algoritmica no EA");
   if(!g_gSpread) return MakeNoTrade(r_sp);
   if(!g_gSession) return MakeNoTrade(r_se);
   if(!g_gNews) return MakeNoTrade(r_nw);
   if(!g_gDaily) return MakeNoTrade(r_dy);
   if(!g_gPos) return MakeNoTrade(r_ps);
   if(!g_gCool) return MakeNoTrade(r_cd);

   bool buy_exists=g_bestBuy.valid;
   bool sell_exists=g_bestSell.valid;
   if(!buy_exists && !sell_exists) return MakeNoTrade("NO_REGION","NO_TRIGGER");

   // Hard-gate eligibility is evaluated before score comparison. This prevents a high-score
   // but invalid BUY candidate from suppressing a valid SELL candidate, and vice versa.
   bool buy_eligible=buy_exists && g_bestBuy.context_ok && g_bestBuy.structure_ok &&
                      g_bestBuy.trigger_ok && g_bestBuy.space_ok && g_bestBuy.score>=InpMinSetupScore &&
                      g_bestBuy.reason_primary=="READY";
   bool sell_eligible=sell_exists && g_bestSell.context_ok && g_bestSell.structure_ok &&
                      g_bestSell.trigger_ok && g_bestSell.space_ok && g_bestSell.score>=InpMinSetupScore &&
                      g_bestSell.reason_primary=="READY";

   SetupCandidate selected;
   bool selected_ok=false;
   if(buy_eligible && sell_eligible)
     {
      if(g_bestBuy.score>=g_bestSell.score) { selected=g_bestBuy; selected_ok=true; }
      else { selected=g_bestSell; selected_ok=true; }
     }
   else if(buy_eligible) { selected=g_bestBuy; selected_ok=true; }
   else if(sell_eligible) { selected=g_bestSell; selected_ok=true; }

   if(!selected_ok)
     {
      // Preserve an informative no-trade reason from the strongest candidate.
      if(buy_exists && (!sell_exists || g_bestBuy.score>=g_bestSell.score))
        return MakeNoTrade(g_bestBuy.reason_primary,g_bestBuy.reason_secondary);
      if(sell_exists) return MakeNoTrade(g_bestSell.reason_primary,g_bestSell.reason_secondary);
      return MakeNoTrade("NO_SETUP");
     }

   Decision d;
   d.action=selected.direction;
   d.allowed=true;
   d.reason_primary="READY";
   d.reason_secondary=selected.reason_secondary;
   d.score=selected.score;
   d.entry=selected.entry;
   d.sl=selected.sl;
   d.tp=selected.tp;
   d.region_id=selected.region_id;
   d.setup_id=selected.id;
   d.trigger_id=StableId("T",selected.id+"|"+selected.trigger.event_name+"|"+IntegerToString((int)g_lastDecisionBar));
   d.setup_type=selected.type;
   return d;
  }

//====================================================================
// EXECUTION ENGINE
//====================================================================
bool CheckRiskParameters(const Decision &decision,double &volume,string &reason)
  {
   reason="";
   volume=0.0;
   if(decision.action==ACTION_NO_TRADE) {reason="NO_TRIGGER";return false;}
   volume=CalculateVolume(decision.entry,decision.sl);
   if(volume<=0.0) {reason="RISK_INVALID";return false;}
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(volume<vmin || volume>vmax || step<=0.0)
     {reason="RISK_INVALID";return false;}
   return true;
  }

string BuildOrderComment(const Decision &decision)
  {
   // Nome + timeframe que abriu a ordem. Ex.: Aurelis_M1, Aurelis_M5, Aurelis_M15
   return "Aurelis_"+g_profileName;
  }

bool ExecuteDecision(const Decision &decision)
  {
   if(decision.action==ACTION_NO_TRADE) return false;
   if(!TFTradingAllowed())
     {
      g_lastReason="TF_DISABLED";
      return false;
     }
   if((ENUM_TIMEFRAMES)_Period!=g_workTF)
     {
      g_lastReason="CHART_TF_MISMATCH";
      return false;
     }
   if(InpOneTradeAcrossTFs && CountAllTFPositions()>CountManagedPositions())
     {
      g_lastReason="OTHER_TF_POSITION";
      return false;
     }

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
     {
      g_lastReason="DATA_INVALID";
      return false;
     }

   double atr=GetATR(g_workTF,InpATRPeriod,1);
   if(atr<=0.0)
     {
      g_lastReason="DATA_INVALID";
      return false;
     }

   double spread=tick.ask-tick.bid;
   string spread_reason="";
   if(IsSpreadBlocked(atr,spread_reason))
     {
      g_lastReason=spread_reason;
      return false;
     }

   double price=decision.action>0?tick.ask:tick.bid;
   double sl=0.0;
   double tp=0.0;
   if(InpUseStopLoss)
      sl=BuildSL(decision.action,price,atr);

   double obstacle=0.0;
   string obstacle_source="";
   if(!FindNearestObstacle(decision.action,price,atr,obstacle,obstacle_source))
     {
      g_lastReason="TARGET_OBSTRUCTED";
      return false;
     }

   double space_norm=NormDistance(price,obstacle,atr);
   double min_space=MathMax(InpMinSpaceATR,2.0*SafeDiv(spread,atr));
   if(space_norm<min_space)
     {
      g_lastReason="SPACE_LOW";
      return false;
     }

   // Recalculate lot size with the refreshed quote and SL.
   double volume=CalculateVolume(price,sl);
   if(volume<=0.0)
     {
      g_lastReason="RISK_INVALID";
      return false;
     }
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(InpMaxLots>0.0) vmax=MathMin(vmax,InpMaxLots);
   if(volume<vmin || volume>vmax || step<=0.0)
     {
      g_lastReason="RISK_INVALID";
      return false;
     }

   tp=BuildTP(decision.action,price,sl,obstacle,atr,volume);
   if(InpUseTakeProfit && tp<=0.0)
     {
      g_lastReason="TARGET_OBSTRUCTED";
      return false;
     }

   string comment=BuildOrderComment(decision);
   ResetLastError();
   bool sent=false;
   trade.SetExpertMagicNumber(g_magic);
   trade.SetDeviationInPoints(InpDeviationPoints);
   trade.SetTypeFillingBySymbol(_Symbol);
   if(decision.action>0)
      sent=trade.Buy(volume,_Symbol,price,sl,tp,comment);
   else
      sent=trade.Sell(volume,_Symbol,price,sl,tp,comment);

   g_lastTradeResult.retcode=trade.ResultRetcode();
   g_lastTradeResult.deal=trade.ResultDeal();
   g_lastTradeResult.order=trade.ResultOrder();
   g_lastTradeResult.volume=trade.ResultVolume();
   g_lastTradeResult.price=trade.ResultPrice();
   g_lastTradeResult.bid=tick.bid;
   g_lastTradeResult.ask=tick.ask;
   g_lastTradeResult.comment=trade.ResultComment();

   if(!sent || (trade.ResultRetcode()!=TRADE_RETCODE_DONE &&
                trade.ResultRetcode()!=TRADE_RETCODE_PLACED &&
                trade.ResultRetcode()!=TRADE_RETCODE_DONE_PARTIAL))
     {
      g_lastReason="ORDER_REJECTED_"+IntegerToString((int)trade.ResultRetcode());
      PrintFormat("AURELIS ORDEM RECUSADA | %s %.2f lot @ %s sl=%s tp=%s | retcode=%d (%s)",
                  decision.action>0?"BUY":"SELL",volume,DoubleToString(price,Digits()),
                  DoubleToString(sl,Digits()),DoubleToString(tp,Digits()),
                  (int)trade.ResultRetcode(),trade.ResultRetcodeDescription());
      return false;
     }

   g_lastReason="ORDER_SENT";
   PrintFormat("AURELIS ORDEM ABERTA | %s %.2f lot @ %s sl=%s tp=%s | %s score=%.1f",
               decision.action>0?"BUY":"SELL",volume,DoubleToString(trade.ResultPrice()>0.0?trade.ResultPrice():price,Digits()),
               DoubleToString(sl,Digits()),DoubleToString(tp,Digits()),decision.setup_type,decision.score);
   if(InpDrawTradeMarkers) DrawTradeMarker(decision,trade.ResultPrice()>0.0?trade.ResultPrice():price);
   return true;
  }

//====================================================================
// POSITION MANAGER
//====================================================================
int HoldLimitMinutes()
  {
   if(g_workTF==PERIOD_M15) return InpMaxHoldHoursM15*60;
   if(g_workTF==PERIOD_M5) return InpMaxHoldMinutesM5;
   return InpMaxHoldMinutesM1;
  }

//====================================================================
// TRAILING EM DINHEIRO (HWM por faixas) E EM PONTOS
//   MaxProfit (HWM) -> TrailDistanceMoney = HWM x faixa% -> lucro protegido = HWM - distancia -> TrailStop
//====================================================================
struct TrailTier
  {
   double thr;   // lucro maximo (HWM) a partir do qual a faixa vale ($)
   double pct;   // distancia = % do lucro maximo que pode ser devolvido
  };

TrailTier g_tiers[];

bool ParseTrailTiers()
  {
   ArrayResize(g_tiers,0);
   string parts[];
   int n=StringSplit(InpTrailTiers,';',parts);
   double last=0.0;
   bool ok=(n>0);
   for(int i=0;i<n && ok;i++)
     {
      string p=parts[i];
      StringTrimLeft(p);
      StringTrimRight(p);
      if(p=="") continue;
      string kv[];
      if(StringSplit(p,':',kv)!=2) { ok=false; break; }
      string sa=kv[0];
      string sb=kv[1];
      StringTrimLeft(sa); StringTrimRight(sa);
      StringTrimLeft(sb); StringTrimRight(sb);
      double thr=StringToDouble(sa);
      double pct=StringToDouble(sb);
      if(thr<=0.0 || pct<=0.0 || pct>100.0 || thr<=last) { ok=false; break; }
      int k=ArraySize(g_tiers);
      ArrayResize(g_tiers,k+1);
      g_tiers[k].thr=thr;
      g_tiers[k].pct=pct;
      last=thr;
     }
   if(ok && ArraySize(g_tiers)==0) ok=false;
   if(!ok)
     {
      PrintFormat("AURELIS: InpTrailTiers invalido (%s). Usando o padrao 5:60;10:60;20:50;50:40;100:35;200:30",InpTrailTiers);
      double tt[6]={5.0,10.0,20.0,50.0,100.0,200.0};
      double pp[6]={60.0,60.0,50.0,40.0,35.0,30.0};
      ArrayResize(g_tiers,6);
      for(int i=0;i<6;i++) { g_tiers[i].thr=tt[i]; g_tiers[i].pct=pp[i]; }
     }
   return ok;
  }

double TrailPctFor(const double hwm)
  {
   if(ArraySize(g_tiers)==0) ParseTrailTiers();
   double pct=g_tiers[0].pct;
   for(int i=0;i<ArraySize(g_tiers);i++)
      if(hwm>=g_tiers[i].thr) pct=g_tiers[i].pct;
   return pct;
  }

// distancia de preco equivalente a "money" para o volume dado
double MoneyToPriceDistance(const double money,const double volume)
  {
   double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tick_size<=0.0 || tick_value<=0.0 || volume<=0.0) return 0.0;
   return (money/(tick_value*volume))*tick_size;
  }

// HWM (maior lucro aberto da posicao) persiste em variavel global do terminal: sobrevive a reinicio do EA
string HwmKey(const ulong ticket) { return StringFormat("AURELIS_HWM_%I64u",ticket); }

double HwmRead(const ulong ticket,const double fallback)
  {
   string key=HwmKey(ticket);
   if(GlobalVariableCheck(key)) return GlobalVariableGet(key);
   GlobalVariableSet(key,fallback);
   return fallback;
  }

void HwmWrite(const ulong ticket,const double value)
  {
   GlobalVariableSet(HwmKey(ticket),value);
  }

void HwmDelete(const ulong ticket)
  {
   string key=HwmKey(ticket);
   if(GlobalVariableCheck(key)) GlobalVariableDel(key);
  }

double BetterSL(const int direction,const double a,const double b)
  {
   if(a<=0.0) return b;
   if(b<=0.0) return a;
   return (direction>0)?MathMax(a,b):MathMin(a,b);
  }

bool PositionIsManaged(const int index,ulong &ticket)
  {
   ticket=PositionGetTicket(index);
   if(ticket==0) return false;
   if(PositionGetString(POSITION_SYMBOL)!=_Symbol) return false;
   if((ulong)PositionGetInteger(POSITION_MAGIC)!=g_magic) return false;
   return true;
  }

bool ModifyPosition(const ulong ticket,const double sl,const double tp,const string reason)
  {
   if(!trade.PositionModify(ticket,sl,tp))
     {
      if(InpPrintTechnicalLog)
         PrintFormat("AURELIS PositionModify failed ticket=%I64u ret=%d %s",
                     ticket,trade.ResultRetcode(),trade.ResultRetcodeDescription());
      return false;
     }
   if(InpWriteCSV)
      WriteTelemetry("POSITION","",ACTION_NO_TRADE,g_lastDecision,reason,sl,tp);
   return true;
  }

void ManageOnePosition(const ulong ticket,const datetime now)
  {
   if(!PositionSelectByTicket(ticket)) return;
   long type=PositionGetInteger(POSITION_TYPE);
   int direction=(type==POSITION_TYPE_BUY?1:-1);
   double open_price=PositionGetDouble(POSITION_PRICE_OPEN);
   double current=(direction>0?CurrentBid():CurrentAsk());
   double atr=GetATR(g_workTF,InpATRPeriod,1);
   if(atr<=0.0) return;
   double current_sl=PositionGetDouble(POSITION_SL);
   double current_tp=PositionGetDouble(POSITION_TP);

   if(InpEmergencyStopEnabled)
     {
      double adverse=direction>0?open_price-current:current-open_price;
      if(adverse>=InpEmergencyStopATR*atr)
        {
         trade.PositionClose(ticket,InpDeviationPoints);
         g_lastReason="EMERGENCY_STOP";
         WriteTelemetry("POSITION", "", ACTION_NO_TRADE, g_lastDecision,"EMERGENCY_STOP",current_sl,current_tp);
         return;
        }
     }

   // v1.11: saida por perda em dinheiro (nao depende de SL; o operador nao usa SL)
   if(InpLossExitMoneyEnabled && InpMaxLossMoney>0.0)
     {
      double floating=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      if(floating<=-InpMaxLossMoney)
        {
         bool closed=trade.PositionClose(ticket,InpDeviationPoints);
         g_lastReason=closed?"LOSS_MONEY_EXIT":"LOSS_MONEY_EXIT_FAIL";
         PrintFormat("AURELIS %s ticket=%I64u floating=%.2f limite=-%.2f ret=%d %s",
                     g_lastReason,ticket,floating,InpMaxLossMoney,trade.ResultRetcode(),trade.ResultRetcodeDescription());
         WriteTelemetry("POSITION", "", ACTION_NO_TRADE, g_lastDecision,g_lastReason,current_sl,current_tp);
         return;
        }
     }

   if(InpTimeExitEnabled)
     {
      datetime open_time=(datetime)PositionGetInteger(POSITION_TIME);
      int limit=HoldLimitMinutes();
      if(limit>0 && (now-open_time)>=limit*60)
        {
         bool closed=trade.PositionClose(ticket,InpDeviationPoints);
         g_lastReason=closed?"TIME_EXIT":"TIME_EXIT_FAIL";
         if(!closed)
            PrintFormat("AURELIS TIME_EXIT falhou ticket=%I64u ret=%d %s",ticket,trade.ResultRetcode(),trade.ResultRetcodeDescription());
         WriteTelemetry("POSITION", "", ACTION_NO_TRADE, g_lastDecision,g_lastReason,current_sl,current_tp);
         return;
        }
     }

   if(InpExitOppositeStructure!=EXIT_OPPOSITE_DISABLED && g_lastDecisionBar>0 &&
      g_lastDecisionBar!=0)
     {
      static datetime s_exitBar=0;
      static TFAnalysis s_exitA;
      datetime cur_bar=iTime(_Symbol,g_workTF,0);
      if(cur_bar!=s_exitBar) { s_exitA=AnalyzeTF(g_workTF); s_exitBar=cur_bar; }
      TFAnalysis a=s_exitA;
      bool close_for_exit=false;
      if(direction>0)
        {
         if(InpExitOppositeStructure==EXIT_OPPOSITE_SHIFT) close_for_exit=a.shift_down;
         else close_for_exit=a.bos_down;
        }
      else
        {
         if(InpExitOppositeStructure==EXIT_OPPOSITE_SHIFT) close_for_exit=a.shift_up;
         else close_for_exit=a.bos_up;
        }
      if(close_for_exit)
        {
         trade.PositionClose(ticket,InpDeviationPoints);
         g_lastReason="OPPOSITE_STRUCTURE";
         WriteTelemetry("POSITION","",ACTION_NO_TRADE,g_lastDecision,"OPPOSITE_STRUCTURE",current_sl,current_tp);
         return;
        }
     }

   if(InpTrailingMode==TRAIL_OFF && !InpBreakEvenEnabled) return;

   double volume=PositionGetDouble(POSITION_VOLUME);
   double swap_money=PositionGetDouble(POSITION_SWAP);
   double net_open=PositionGetDouble(POSITION_PROFIT)+swap_money;
   double moved_points=(direction>0?current-open_price:open_price-current)/_Point;
   long stops_lvl=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long freeze_lvl=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   double min_dist=(double)(MathMax(stops_lvl,freeze_lvl)+2)*_Point;

   double want_sl=0.0;       // stop desejado (0 = nada a fazer)
   double trail_sl=0.0;      // stop do trailing puro (para detectar cruzamento)
   bool   trailing_on=false;
   string why="";

   // ---- Breakeven (dinheiro + pontos) ----
   if(InpBreakEvenEnabled && net_open>=InpBreakEvenStartMoney)
     {
      want_sl=open_price+(double)direction*InpBreakEvenOffsetPoints*_Point;
      why="BREAKEVEN";
     }

   // ---- Trailing em dinheiro: HWM -> distancia por faixa -> stop ----
   if(InpTrailingMode==TRAIL_MONEY_HWM)
     {
      double hwm=HwmRead(ticket,net_open);
      if(net_open>hwm)
        {
         hwm=net_open;
         HwmWrite(ticket,hwm);
        }
      double unit=MoneyToPriceDistance(1.0,volume);     // preco por $1 de lucro
      if(hwm>=InpTrailStartMoney && unit>0.0)
        {
         double pct=TrailPctFor(hwm);
         double dist_money=hwm*pct/100.0;               // TrailDistanceMoney
         double lock_money=hwm-dist_money;              // lucro protegido
         trail_sl=open_price+(double)direction*(lock_money-swap_money)*unit;
         trailing_on=true;
         string tw=StringFormat("TRAIL_MONEY_HWM|hwm=%.2f|dist=%.0f%%=%.2f|lock=%.2f",hwm,pct,dist_money,lock_money);
         double nb=BetterSL(direction,want_sl,trail_sl);
         if(nb==trail_sl) why=tw;
         want_sl=nb;
        }
     }
   // ---- Trailing em pontos: distancia fixa do preco ----
   else if(InpTrailingMode==TRAIL_POINTS)
     {
      if(moved_points>=InpTrailStartPoints)
        {
         trail_sl=current-(double)direction*InpTrailDistancePoints*_Point;
         trailing_on=true;
         string tw=StringFormat("TRAIL_POINTS|move=%.0f|dist=%d",moved_points,InpTrailDistancePoints);
         double nb=BetterSL(direction,want_sl,trail_sl);
         if(nb==trail_sl) why=tw;
         want_sl=nb;
        }
     }

   // ---- Protecao atras do swing (opcional) ----
   if(trailing_on && InpUseSwingTrailing)
     {
      double buf=InpTrailingBufferPoints*_Point;
      if(direction>0 && ArraySize(g_workLows)>0)
        {
         double s=g_workLows[0].price-buf;
         if(s<current-min_dist)
           {
            double nb=BetterSL(direction,want_sl,s);
            if(nb==s) why="TRAIL_SWING";
            want_sl=nb;
           }
        }
      if(direction<0 && ArraySize(g_workHighs)>0)
        {
         double s=g_workHighs[0].price+buf;
         if(s>current+min_dist)
           {
            double nb=BetterSL(direction,want_sl,s);
            if(nb==s) why="TRAIL_SWING";
            want_sl=nb;
           }
        }
     }

   if(want_sl<=0.0) return;

   // preco ja devolveu ate o stop do trailing (stop nao pode ser colocado): fecha a mercado
   if(trail_sl>0.0)
     {
      bool crossed=(direction>0)?(current<=trail_sl):(current>=trail_sl);
      if(crossed)
        {
         if(trade.PositionClose(ticket,InpDeviationPoints))
           {
            HwmDelete(ticket);
            g_lastReason="TRAIL_EXIT";
            WriteTelemetry("POSITION","",ACTION_NO_TRADE,g_lastDecision,"TRAIL_EXIT|"+why,current_sl,current_tp);
           }
         return;
        }
     }

   double limit=(direction>0)?current-min_dist:current+min_dist;
   if(direction>0) want_sl=MathMin(want_sl,limit);
   else want_sl=MathMax(want_sl,limit);
   want_sl=NormalizePrice(want_sl);

   double step=(double)MathMax(1,InpTrailStepPoints)*_Point;
   bool improve=false;
   if(current_sl<=0.0) improve=true;
   else if(direction>0 && want_sl>current_sl+step) improve=true;
   else if(direction<0 && want_sl<current_sl-step) improve=true;
   if(!improve) return;

   static uint s_lastTry=0;
   uint now_ms=GetTickCount();
   if(s_lastTry!=0 && (now_ms-s_lastTry)<500) return;
   s_lastTry=now_ms;

   double new_tp=current_tp;
   if(trailing_on && InpTrailingOverrideTP) new_tp=0.0;
   ModifyPosition(ticket,want_sl,new_tp,why);
  }

void ManagePositions()
  {
   datetime now=TimeTradeServer();
   if(now<=0) now=TimeCurrent();
   UpdateDailyState();
   if(InpDailyTargetMoneyEnabled && InpDailyTargetMoney>0.0 && g_dailyTargetHit &&
      InpDailyTargetAction==DAILY_CLOSE_AND_BLOCK)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
        {
         ulong ticket=0;
         if(PositionIsManaged(i,ticket))
            trade.PositionClose(ticket,InpDeviationPoints);
        }
     }
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=0;
      if(!PositionIsManaged(i,ticket)) continue;
      ManageOnePosition(ticket,now);
     }
  }

void CloseAllManagedPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=0;
      if(PositionIsManaged(i,ticket))
         trade.PositionClose(ticket,InpDeviationPoints);
     }
  }

//====================================================================
// TELEMETRY / CSV
//====================================================================
string CsvFileName()
  {
   return "AURELIS_"+_Symbol+"_"+g_profileName+"_Events.csv";
  }

bool OpenCSV()
  {
   if(!InpWriteCSV) return true;
   if(g_csvHandle!=INVALID_HANDLE) return true;
   g_csvHandle=FileOpen(CsvFileName(),FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(g_csvHandle==INVALID_HANDLE)
      g_csvHandle=FileOpen(CsvFileName(),FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(g_csvHandle==INVALID_HANDLE)
     {
      PrintFormat("AURELIS CSV open failed. Error=%d",GetLastError());
      return false;
     }
   if(FileSize(g_csvHandle)==0)
     {
      FileWrite(g_csvHandle,
                "timestamp","symbol","timeframe","event_id","event_type","direction",
                "context_direction","context_strength","context_class","structure_state","volatility_regime",
                "weekly_open","daily_open","session_open","current_high","current_low","midpoint_up","midpoint_down",
                "region_id","region_type","region_low","region_high","region_score","region_sources",
                "setup_id","setup_type","setup_score","trigger_id","trigger_type","event","reaction","structure_event","displacement",
                "entry","sl","tp","nearest_obstacle","space_norm","atr","spread",
                "decision","reason_code","reason_detail","order_ticket","deal_ticket","position_ticket",
                "pnl","daily_pnl","daily_target","time_in_trade","system_state");
      g_csvHeaderWritten=true;
     }
   FileSeek(g_csvHandle,0,SEEK_END);
   return true;
  }

void WriteTelemetry(const string event_type,const string event_id,const int direction,const Decision &decision,
                    const string reason_detail,const double event_sl,const double event_tp)
  {
   if(!InpWriteCSV) return;
   if(!OpenCSV()) return;
   double pnl=0.0;
   ulong position_ticket=0;
   ulong order_ticket=g_lastTradeResult.order;
   ulong deal_ticket=g_lastTradeResult.deal;
   if(PositionSelect(_Symbol))
     {
      if((ulong)PositionGetInteger(POSITION_MAGIC)==g_magic)
        {
         pnl=PositionGetDouble(POSITION_PROFIT);
         position_ticket=(ulong)PositionGetInteger(POSITION_TICKET);
        }
     }
   FileSeek(g_csvHandle,0,SEEK_END);
   string ts=TimeToString(TimeTradeServer(),TIME_DATE|TIME_SECONDS);
   string reason=decision.reason_primary;
   if(reason=="") reason=g_lastReason;
   string region_sources="";
   int region_idx=FindRegionIndex(g_lastRegionId);
   if(region_idx>=0)
      region_sources=g_regions[region_idx].source1+"|"+g_regions[region_idx].source2+"|"+g_regions[region_idx].source3;
   string trigger_event="";
   string trigger_reaction="";
   string trigger_structure="";
   string displacement="";
   string trigger_type="";
   SetupCandidate sc=g_bestBuy;
   if(direction<0) sc=g_bestSell;
   if(sc.valid)
     {
      trigger_event=sc.trigger.event_name;
      trigger_reaction=sc.trigger.reaction_name;
      trigger_structure=sc.trigger.structure_name;
      displacement=BoolText(sc.trigger.displacement_ok);
      trigger_type=sc.trigger.type;
     }

   datetime pos_time=0;
   if(position_ticket>0) pos_time=(datetime)PositionGetInteger(POSITION_TIME);
   long time_in_trade=(pos_time>0 ? (long)(TimeTradeServer()-pos_time) : 0);

   FileWrite(g_csvHandle,
             ts,_Symbol,g_profileName,event_id,event_type,SignToText(direction),
             g_lastContextDirection,DoubleToString(g_lastContextStrength,1),g_lastContextClass,
             g_lastLocalRegime,g_lastVolStatus,
             DoubleToString(g_map.weekly_open,Digits()),DoubleToString(g_map.daily_open,Digits()),DoubleToString(g_map.session_open,Digits()),
             DoubleToString(g_map.current_week_high,Digits()),DoubleToString(g_map.current_week_low,Digits()),
             DoubleToString(g_map.weekly_mid_up,Digits()),DoubleToString(g_map.weekly_mid_down,Digits()),
             g_lastRegionId,
             (region_idx>=0?g_regions[region_idx].type:""),
             (region_idx>=0?DoubleToString(g_regions[region_idx].low,Digits()):""),
             (region_idx>=0?DoubleToString(g_regions[region_idx].high,Digits()):""),
             DoubleToString(g_lastRegionScore,1),region_sources,
             g_lastSetupId,(sc.valid?sc.type:""),DoubleToString(g_lastSetupScore,1),g_lastTriggerId,trigger_type,
             trigger_event,trigger_reaction,trigger_structure,displacement,
             DoubleToString(decision.entry>0?decision.entry:0.0,Digits()),
             DoubleToString(event_sl,Digits()),DoubleToString(event_tp,Digits()),
             DoubleToString(g_bestBuy.nearest_obstacle>0 && direction>0?g_bestBuy.nearest_obstacle:(g_bestSell.nearest_obstacle>0 && direction<0?g_bestSell.nearest_obstacle:0.0),Digits()),
             DoubleToString(g_lastSpaceNorm,2),DoubleToString(g_lastATR,Digits()),DoubleToString(g_lastSpread,Digits()),
             ActionToText(decision.action),reason,reason_detail,
             order_ticket,deal_ticket,position_ticket,
             DoubleToString(pnl,2),DoubleToString(g_dailyPnL,2),DoubleToString(InpDailyTargetMoney,2),
             time_in_trade,g_lastState);
   FileFlush(g_csvHandle);
  }

int FindRegionIndex(const string region_id)
  {
   for(int i=0;i<ArraySize(g_regions);i++)
      if(g_regions[i].id==region_id) return i;
   return -1;
  }

//====================================================================
// CHART DRAWING
//====================================================================
void DeleteObjectsByPrefix(const string prefix)
  {
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,prefix)==0)
         ObjectDelete(0,name);
     }
  }

void DrawTextPrice(const string name,const datetime when,const double price,const string text,const color clr,const int size=8)
  {
   if(!InpDrawLabels || price<=0.0 || when<=0) return;
   string n=AURELIS_PREFIX+"TXT_"+name;
   if(ObjectFind(0,n)>=0) ObjectDelete(0,n);
   if(!ObjectCreate(0,n,OBJ_TEXT,0,when,price)) return;
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,n,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetString(0,n,OBJPROP_FONT,"Consolas");
   ObjectSetString(0,n,OBJPROP_TEXT,text);
  }

void DrawHLine(const string name,const double price,const color clr,const string text)
  {
   if(price<=0.0) return;
   string n=AURELIS_PREFIX+name;
   if(!ObjectCreate(0,n,OBJ_HLINE,0,0,price)) return;
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,n,OBJPROP_BACK,true);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetString(0,n,OBJPROP_TEXT,text);
   datetime label_time=TimeTradeServer()+PeriodSeconds(g_workTF)*4;
   DrawTextPrice(name,label_time,price,text,clr,8);
  }

void DrawTrend(const string name,const Trendline &line,const color clr,const string label)
  {
   if(!line.valid) return;
   string n=AURELIS_PREFIX+name;
   datetime t3=TimeTradeServer()+PeriodSeconds(g_workTF)*32;
   double p3=LinePrice(line,t3);
   if(!ObjectCreate(0,n,OBJ_TREND,0,line.t1,line.p1,t3,p3)) return;
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,n,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,n,OBJPROP_BACK,true);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   DrawTextPrice(name+"_LABEL",t3,p3,label,clr,9);
  }

string RegionBiasText(const int bias)
  {
   if(bias==REGION_SUPPORT) return "SUPPORT";
   if(bias==REGION_RESIST) return "RESISTANCE";
   return "NEUTRAL";
  }

string RegionSources(const Region &r)
  {
   string out=r.source1;
   if(r.source2!="") out+=(out==""?"":" + ")+r.source2;
   if(r.source3!="") out+=(out==""?"":" + ")+r.source3;
   return out;
  }

void DrawRegionZone(const string name,const Region &r,const color border_clr,const bool selected)
  {
   if(!InpDrawRegions || !r.valid) return;
   datetime t1=TimeTradeServer()-PeriodSeconds(g_workTF)*10;
   datetime t2=TimeTradeServer()+PeriodSeconds(g_workTF)*32;
   string n=AURELIS_PREFIX+"ZONE_"+name;
   if(!ObjectCreate(0,n,OBJ_RECTANGLE,0,t1,r.low,t2,r.high)) return;
   ObjectSetInteger(0,n,OBJPROP_COLOR,border_clr);
   ObjectSetInteger(0,n,OBJPROP_STYLE,selected?STYLE_SOLID:STYLE_DOT);
   ObjectSetInteger(0,n,OBJPROP_WIDTH,selected?2:1);
   ObjectSetInteger(0,n,OBJPROP_FILL,true);
   ObjectSetInteger(0,n,OBJPROP_BACK,true);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   string lbl=RegionBiasText(r.bias)+" | "+RegionSources(r)+" | "+DoubleToString(r.score,0);
   DrawTextPrice(name+"_LABEL",t2,r.high,lbl,border_clr,8);
  }

void DrawTradeMarker(const Decision &decision,const double actual_price)
  {
   if(!InpDrawTradeMarkers || actual_price<=0.0) return;
   datetime now=TimeTradeServer();
   string base=AURELIS_TRADE_PREFIX+IntegerToString((int)now)+"_"+IntegerToString((int)g_eventSequence);
   color clr=decision.action>0?clrLimeGreen:clrTomato;
   string side=decision.action>0?"BUY":"SELL";
   string txt=side+" | "+decision.setup_type+" | S "+DoubleToString(decision.score,0)+" | "+decision.region_id;
   ObjectCreate(0,base+"_V",OBJ_VLINE,0,now,0);
   ObjectSetInteger(0,base+"_V",OBJPROP_COLOR,clr);
   ObjectSetInteger(0,base+"_V",OBJPROP_STYLE,STYLE_DASH);
   ObjectSetInteger(0,base+"_V",OBJPROP_WIDTH,1);
   ObjectSetInteger(0,base+"_V",OBJPROP_BACK,true);
   ObjectSetInteger(0,base+"_V",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,base+"_V",OBJPROP_HIDDEN,true);
   DrawTextPrice(base+"_TXT",now,actual_price,txt,clr,9);
  }

void DrawMap()
  {
   if(!InpDrawMarketMap || !g_mapVisible) return;
   DeleteObjectsByPrefix(AURELIS_PREFIX);
   double price=CurrentBid();
   color c_week=clrMagenta;
   color c_daily=clrSilver;
   color c_mid=clrGold;
   color c_ext=clrAqua;
   color c_sr=clrOrange;
   if(g_map.weekly_open>0) DrawHLine("WOPEN",g_map.weekly_open,c_week,"WEEK OPEN  "+DoubleToString(g_map.weekly_open,Digits()));
   if(g_map.daily_open>0) DrawHLine("DOPEN",g_map.daily_open,c_daily,"DAY OPEN   "+DoubleToString(g_map.daily_open,Digits()));
   if(g_map.monthly_open>0) DrawHLine("MOPEN",g_map.monthly_open,clrSlateGray,"MONTH OPEN "+DoubleToString(g_map.monthly_open,Digits()));
   if(g_map.weekly_mid_up>0) DrawHLine("WMUP",g_map.weekly_mid_up,c_mid,"WEEK MID +  "+DoubleToString(g_map.weekly_mid_up,Digits()));
   if(g_map.weekly_mid_down>0) DrawHLine("WMDN",g_map.weekly_mid_down,c_mid,"WEEK MID -  "+DoubleToString(g_map.weekly_mid_down,Digits()));
   if(g_map.daily_mid_up>0) DrawHLine("DMUP",g_map.daily_mid_up,clrKhaki,"DAY MID +   "+DoubleToString(g_map.daily_mid_up,Digits()));
   if(g_map.daily_mid_down>0) DrawHLine("DMDN",g_map.daily_mid_down,clrKhaki,"DAY MID -   "+DoubleToString(g_map.daily_mid_down,Digits()));
   if(g_map.current_week_high>0) DrawHLine("CW_HIGH",g_map.current_week_high,c_ext,"WEEK HIGH  "+DoubleToString(g_map.current_week_high,Digits()));
   if(g_map.current_week_low>0) DrawHLine("CW_LOW",g_map.current_week_low,c_ext,"WEEK LOW   "+DoubleToString(g_map.current_week_low,Digits()));
   if(g_map.previous_week_high>0) DrawHLine("PW_HIGH",g_map.previous_week_high,clrDeepSkyBlue,"PREV WEEK HIGH "+DoubleToString(g_map.previous_week_high,Digits()));
   if(g_map.previous_week_low>0) DrawHLine("PW_LOW",g_map.previous_week_low,clrDeepSkyBlue,"PREV WEEK LOW  "+DoubleToString(g_map.previous_week_low,Digits()));
   if(g_map.previous_day_high>0) DrawHLine("PDH",g_map.previous_day_high,clrTomato,"PREV DAY HIGH "+DoubleToString(g_map.previous_day_high,Digits()));
   if(g_map.previous_day_low>0) DrawHLine("PDL",g_map.previous_day_low,clrLimeGreen,"PREV DAY LOW  "+DoubleToString(g_map.previous_day_low,Digits()));
   if(g_map.range_high>0) DrawHLine("RHIGH",g_map.range_high,clrDarkOrange,"RANGE HIGH  "+DoubleToString(g_map.range_high,Digits()));
   if(g_map.range_low>0) DrawHLine("RLOW",g_map.range_low,clrDarkOrange,"RANGE LOW   "+DoubleToString(g_map.range_low,Digits()));
   if(g_map.range_mid>0) DrawHLine("RMID",g_map.range_mid,clrGray,"RANGE MID   "+DoubleToString(g_map.range_mid,Digits()));

   // Draw relevant regions close to current price, capped to avoid chart pollution.
   if(InpDrawRegions)
     {
      double atr=GetATR(g_workTF,InpATRPeriod,1);
      int drawn=0;
      for(int pass=0;pass<2 && drawn<8;pass++)
        {
         for(int i=0;i<ArraySize(g_regions) && drawn<8;i++)
           {
            Region r=g_regions[i];
            if(!r.valid) continue;
            if(pass==0 && !r.active) continue;
            if(pass==1 && r.active) continue;
            if(atr>0.0 && NormDistance(price,r.center,atr)>5.0) continue;
            bool selected=(r.id==g_lastRegionId);
            color zclr=selected?clrWhite:(r.bias==REGION_SUPPORT?clrLimeGreen:(r.bias==REGION_RESIST?clrTomato:clrKhaki));
            DrawRegionZone(IntegerToString(i),r,zclr,selected);
            drawn++;
           }
        }
     }

   if(InpDrawGeometry)
     {
      if(g_lta.valid) DrawTrend("LTA",g_lta,clrLimeGreen,"LTA  | SUPPORT DYNAMIC");
      if(g_ltb.valid) DrawTrend("LTB",g_ltb,clrTomato,"LTB  | RESISTANCE DYNAMIC");
      if(g_channelUp.valid)
        {
         DrawTrend("CH_UP_TOP",g_channelUp.top,clrGreen,"CHANNEL UP  | TOP");
         DrawTrend("CH_UP_BOTTOM",g_channelUp.bottom,clrGreen,"CHANNEL UP  | BOTTOM");
         datetime tm=TimeTradeServer()+PeriodSeconds(g_workTF)*26;
         double mid=(LinePrice(g_channelUp.top,tm)+LinePrice(g_channelUp.bottom,tm))/2.0;
         DrawTextPrice("CH_UP_INFO",tm,mid,"CHANNEL UP  | "+g_channelUp.state+" | "+DoubleToString(g_channelUp.score,0),clrGreen,8);
        }
      if(g_channelDown.valid)
        {
         DrawTrend("CH_DN_TOP",g_channelDown.top,clrDodgerBlue,"CHANNEL DOWN | TOP");
         DrawTrend("CH_DN_BOTTOM",g_channelDown.bottom,clrDodgerBlue,"CHANNEL DOWN | BOTTOM");
         datetime tm=TimeTradeServer()+PeriodSeconds(g_workTF)*26;
         double mid=(LinePrice(g_channelDown.top,tm)+LinePrice(g_channelDown.bottom,tm))/2.0;
         DrawTextPrice("CH_DN_INFO",tm,mid,"CHANNEL DOWN | "+g_channelDown.state+" | "+DoubleToString(g_channelDown.score,0),clrDodgerBlue,8);
        }
     }

   // Dynamic explanation of the current decision/candidate, kept separate from trade markers.
   if(InpDrawLabels && price>0.0)
     {
      string explanation="NO TRADE";
      color eclr=clrGold;
      if(g_lastDecision.action>0) { explanation="BUY | "+g_lastDecision.setup_type+" | "+g_lastReason; eclr=clrLimeGreen; }
      else if(g_lastDecision.action<0) { explanation="SELL | "+g_lastDecision.setup_type+" | "+g_lastReason; eclr=clrTomato; }
      else if(g_bestBuy.valid || g_bestSell.valid)
        {
         SetupCandidate c=g_bestBuy.valid && (!g_bestSell.valid || g_bestBuy.score>=g_bestSell.score)?g_bestBuy:g_bestSell;
         explanation=(c.direction>0?"BUY CANDIDATE":"SELL CANDIDATE")+" | "+c.type+" | "+c.reason_primary;
         eclr=c.direction>0?clrLimeGreen:clrTomato;
        }
      DrawTextPrice("ANALYSIS",TimeTradeServer()+PeriodSeconds(g_workTF)*3,price,explanation,eclr,9);
     }
  }

//====================================================================
// HUD ENGINE v3 - canvas em 2 camadas (fundo estatico + camada viva)
// Fontes em pixels (positivo), texto sempre ajustado a largura da area
//====================================================================
#define HUD_W        500
#define HUD_H_EXP    750
#define HUD_H_MIN    96
#define HUD_OBJ_BG   "AURELIS_HUD_BG"
#define HUD_OBJ_UI   "AURELIS_HUD_UI"

#define HC_BG1   C'4,7,16'
#define HC_BG2   C'11,18,40'
#define HC_CYAN  C'0,229,255'
#define HC_GREEN C'0,255,170'
#define HC_RED   C'255,61,113'
#define HC_AMBER C'255,176,32'
#define HC_TEXT  C'228,238,255'
#define HC_DIM   C'150,168,204'
#define HC_CARD  C'6,11,25'
#define HC_TRACK C'14,21,40'

// cards: y, h
#define HY_MKT   96
#define HH_MKT   92
#define HY_CTX   194
#define HH_CTX   100
#define HY_SET   300
#define HH_SET   120
#define HY_TRG   426
#define HH_TRG   72
#define HY_GAT   504
#define HH_GAT   60
#define HY_DAY   570
#define HH_DAY   112
#define HY_BTN   690

struct HudBtn { int x,y,w,h; };

CCanvas g_hudBg;
CCanvas g_hudUi;
HudBtn  g_hudBtn[4];          // 0=min/exp 1=pause 2=close all 3=map
bool    g_hudReady=false;
bool    g_hudMin=false;
bool    g_hudBgDirty=true;
bool    g_hudDrag=false;
bool    g_hudDown=false;
bool    g_hudInside=false;
bool    g_mapVisible=true;
int     g_hudX=20;
int     g_hudY=60;
int     g_hudH=0;
int     g_hudHover=-1;
int     g_hudDX=0;
int     g_hudDY=0;
int     g_hudAnim=0;

// v1.11: escala do painel. Todo o desenho usa coordenadas de projeto (500x750) e estes
// wrappers multiplicam por g_hs: layout e estetica iguais, so menores.
double g_hs=1.0;
int  HS(const int v)  { return (int)MathRound(v*g_hs); }
int  HSh(const int v) { return MathMax(1,(int)MathRound(v*g_hs)); }
void hLine(CCanvas &cv,const int x1,const int y1,const int x2,const int y2,const uint c)  { cv.Line(HS(x1),HS(y1),HS(x2),HS(y2),c); }
void hRect(CCanvas &cv,const int x1,const int y1,const int x2,const int y2,const uint c)  { cv.FillRectangle(HS(x1),HS(y1),HS(x2+1)-1,HS(y2+1)-1,c); }
void hRectO(CCanvas &cv,const int x1,const int y1,const int x2,const int y2,const uint c) { cv.Rectangle(HS(x1),HS(y1),HS(x2+1)-1,HS(y2+1)-1,c); }
void hCircle(CCanvas &cv,const int x,const int y,const int r,const uint c)               { cv.FillCircle(HS(x),HS(y),HSh(r),c); }
void hTriF(CCanvas &cv,const int x1,const int y1,const int x2,const int y2,const int x3,const int y3,const uint c)
  { cv.FillTriangle(HS(x1),HS(y1),HS(x2),HS(y2),HS(x3),HS(y3),c); }

uint HA(const color c,const int a=255)
  {
   int v=a; if(v<0) v=0; if(v>255) v=255;
   return ColorToARGB(c,(uchar)v);
  }

color HLerp(const color c1,const color c2,double t)
  {
   t=ClampD(t,0.0,1.0);
   int r1=c1&0xFF,g1=(c1>>8)&0xFF,b1=(c1>>16)&0xFF;
   int r2=c2&0xFF,g2=(c2>>8)&0xFF,b2=(c2>>16)&0xFF;
   int r=(int)MathRound(r1+(r2-r1)*t);
   int g=(int)MathRound(g1+(g2-g1)*t);
   int b=(int)MathRound(b1+(b2-b1)*t);
   return (color)((b<<16)|(g<<8)|r);
  }

// Texto com ajuste automatico: reduz a fonte (ate -3 px) e, se ainda nao couber, corta com "..".
// align: 0 esquerda, 1 centro, 2 direita.  maxW = largura disponivel em pixels.
void HT(CCanvas &cv,const int x,const int y,const int maxW0,const string text,const color c,
        const int size,const bool bold=false,const int align=0,const string font="Segoe UI")
  {
   string s=text;
   uint fl=bold?FW_BOLD:FW_SEMIBOLD;
   int maxW=HS(maxW0);
   int sz=MathMax(7,(int)MathRound(size*g_hs));
   int minSz=MathMax(7,(int)MathRound(MathMax(9,size-3)*g_hs));
   if(minSz>sz) minSz=sz;
   cv.FontSet(font,sz,fl);
   while(sz>minSz && cv.TextWidth(s)>maxW)
     {
      sz--;
      cv.FontSet(font,sz,fl);
     }
   if(cv.TextWidth(s)>maxW)
     {
      int n=StringLen(s);
      while(n>3 && cv.TextWidth(StringSubstr(s,0,n)+"..")>maxW) n--;
      s=StringSubstr(s,0,n)+"..";
     }
   int w=cv.TextWidth(s);
   int px=HS(x);
   if(align==1) px=px-w/2;
   else if(align==2) px=px-w;
   cv.TextOut(px,HS(y),s,HA(c,255));
  }

void HBrackets(CCanvas &cv,const int x,const int y,const int w,const int h,const int L,const color c,const int a)
  {
   uint u=HA(c,a);
   hLine(cv,x,y,x+L,y,u);                   hLine(cv,x,y,x,y+L,u);
   hLine(cv,x+w-1,y,x+w-1-L,y,u);           hLine(cv,x+w-1,y,x+w-1,y+L,u);
   hLine(cv,x,y+h-1,x+L,y+h-1,u);           hLine(cv,x,y+h-1,x,y+h-1-L,u);
   hLine(cv,x+w-1,y+h-1,x+w-1-L,y+h-1,u);   hLine(cv,x+w-1,y+h-1,x+w-1,y+h-1-L,u);
  }

void HCard(CCanvas &cv,const int y,const int h,const string title)
  {
   const int x=12,w=HUD_W-24;
   hRect(cv,x,y,x+w-1,y+h-1,HA(HC_CARD,210));
   hRectO(cv,x,y,x+w-1,y+h-1,HA(HC_CYAN,55));
   HBrackets(cv,x,y,w,h,8,HC_CYAN,230);
   hRect(cv,x+8,y+7,x+10,y+16,HA(HC_GREEN,255));
   HT(cv,x+16,y+3,440,title,HC_DIM,12,true);
  }

void HBar(CCanvas &cv,const int x,const int y,const int w,const int h,const double frac,const color c,const double marker=-1.0)
  {
   hRect(cv,x,y,x+w-1,y+h-1,HA(HC_TRACK,240));
   int fw=(int)MathRound(w*ClampD(frac,0.0,1.0));
   if(fw>0)
     {
      hRect(cv,x,y,x+fw-1,y+h-1,HA(c,235));
      hRect(cv,x,y,x+fw-1,y+MathMax(0,h/3-1),HA(clrWhite,45));
     }
   hRectO(cv,x,y,x+w-1,y+h-1,HA(HC_CYAN,80));
   if(marker>=0.0)
     {
      int mx=x+(int)MathRound(w*ClampD(marker,0.0,1.0));
      hLine(cv,mx,y-3,mx,y+h+2,HA(clrWhite,235));
     }
  }

void HLed(CCanvas &cv,const int x,const int y,const int r,const color c,const double pulse)
  {
   hCircle(cv,x,y,r+4,HA(c,(int)(16+26*pulse)));
   hCircle(cv,x,y,r+2,HA(c,(int)(45+55*pulse)));
   hCircle(cv,x,y,r,HA(c,255));
  }

void HChip(CCanvas &cv,const int x,const int y,const int w,const int h,const string label,const bool on,const color c)
  {
   hRect(cv,x,y,x+w-1,y+h-1,HA(on?c:HC_TRACK,on?42:200));
   hRectO(cv,x,y,x+w-1,y+h-1,HA(on?c:HC_DIM,on?230:90));
   HT(cv,x+w/2,y+h/2-8,w-10,label,on?c:HC_DIM,12,true,1);
  }

void HTri(CCanvas &cv,const int cx,const int cy,const int s,const bool up,const color c,const int a=255)
  {
   if(up) hTriF(cv,cx-s,cy+s/2,cx+s,cy+s/2,cx,cy-s,HA(c,a));
   else   hTriF(cv,cx-s,cy-s/2,cx+s,cy-s/2,cx,cy+s,HA(c,a));
  }

void HudLayout()
  {
   g_hudBtn[0].x=HUD_W-46; g_hudBtn[0].y=14; g_hudBtn[0].w=32; g_hudBtn[0].h=28;
   int bw=153,gap=8,x=12;
   for(int i=1;i<=3;i++)
     {
      g_hudBtn[i].x=x; g_hudBtn[i].y=HY_BTN; g_hudBtn[i].w=bw; g_hudBtn[i].h=32;
      x+=bw+gap;
     }
  }

string HudBtnLabel(const int id)
  {
   if(id==0) return g_hudMin?"+":"-";
   if(id==1) return g_tradingPaused?"RESUME":"PAUSE";
   if(id==2) return "CLOSE ALL";
   return g_mapVisible?"MAP: ON":"MAP: OFF";
  }

//--------------------------------------------------------------------
// camada estatica (fundo + cartoes)
//--------------------------------------------------------------------
void HudDrawBg(const int W,const int H)
  {
   g_hudBg.Erase(0);
   for(int y=0;y<H;y++)
     {
      double t=(double)y/MathMax(1,H-1);
      hLine(g_hudBg,0,y,W-1,y,HA(HLerp(HC_BG1,HC_BG2,t),236));
     }
   for(int x=0;x<W;x+=24) hLine(g_hudBg,x,0,x,H-1,HA(HC_CYAN,8));
   for(int y=0;y<H;y+=24) hLine(g_hudBg,0,y,W-1,y,HA(HC_CYAN,8));

   const int c=14;   // cantos chanfrados
   for(int k=0;k<3;k++)
     {
      int a=(k==0)?255:(k==1?90:35);
      uint u=HA(HC_CYAN,a);
      hLine(g_hudBg,c-k,k,W-1-k,k,u);
      hLine(g_hudBg,W-1-k,k,W-1-k,H-1-c+k,u);
      hLine(g_hudBg,k,c-k,k,H-1-k,u);
      hLine(g_hudBg,k,H-1-k,W-1-c+k,H-1-k,u);
      hLine(g_hudBg,k,c-k,c-k,k,u);
      hLine(g_hudBg,W-1-k,H-1-c+k,W-1-c+k,H-1-k,u);
     }
   hRect(g_hudBg,14,58,124,59,HA(HC_GREEN,255));
   hLine(g_hudBg,14,60,W-14,60,HA(HC_CYAN,60));

   if(g_hudMin) return;
   HCard(g_hudBg,HY_MKT,HH_MKT,"MERCADO");
   HCard(g_hudBg,HY_CTX,HH_CTX,"CONTEXTO MTF");
   HCard(g_hudBg,HY_SET,HH_SET,"SETUPS");
   HCard(g_hudBg,HY_TRG,HH_TRG,"CADEIA DE GATILHO");
   HCard(g_hudBg,HY_GAT,HH_GAT,"PORTOES");
   HCard(g_hudBg,HY_DAY,HH_DAY,"RESULTADO LIQUIDO GERAL (M1+M5+M15)");
  }

//--------------------------------------------------------------------
// camada viva
//--------------------------------------------------------------------
bool HudPickCandidate(SetupCandidate &out)
  {
   if(g_bestBuy.valid && (!g_bestSell.valid || g_bestBuy.score>=g_bestSell.score)) { out=g_bestBuy; return true; }
   if(g_bestSell.valid) { out=g_bestSell; return true; }
   return false;
  }

void HudDrawUi(const int W,const int H)
  {
   g_hudUi.Erase(0);
   g_spreadLimitPts=(double)SpreadLimitPointsForTF();
   g_spreadPts=SafeDiv(CurrentSpread(),_Point);   // spread ao vivo em pontos
   double pulse=0.5+0.5*MathSin(g_hudAnim*0.9);
   const color acc=HC_GREEN, warn=HC_AMBER, bad=HC_RED, cy=HC_CYAN, txt=HC_TEXT, dim=HC_DIM;

   // ---- cabecalho ----
   int hx[6]={30,40,40,30,20,20}, hy[6]={12,18,30,36,30,18};
   for(int i=0;i<6;i++) hLine(g_hudUi,hx[i],hy[i],hx[(i+1)%6],hy[(i+1)%6],HA(acc,255));
   hCircle(g_hudUi,30,24,3,HA(cy,255));
   HT(g_hudUi,52,3,220,"AURELIS",acc,24,true);
   HT(g_hudUi,52,36,390,"MTF ADAPTIVE  |  v1.11  |  "+_Symbol+"  "+g_profileName,dim,12);

   // botao min/exp
   hRect(g_hudUi,g_hudBtn[0].x,g_hudBtn[0].y,g_hudBtn[0].x+g_hudBtn[0].w-1,g_hudBtn[0].y+g_hudBtn[0].h-1,
                         HA(g_hudHover==0?cy:C'10,16,34',g_hudHover==0?90:220));
   hRectO(g_hudUi,g_hudBtn[0].x,g_hudBtn[0].y,g_hudBtn[0].x+g_hudBtn[0].w-1,g_hudBtn[0].y+g_hudBtn[0].h-1,HA(cy,200));
   HT(g_hudUi,g_hudBtn[0].x+g_hudBtn[0].w/2,g_hudBtn[0].y+3,28,HudBtnLabel(0),cy,18,true,1,"Consolas");

   // ---- pilula de status ----
   string st; color sc;
   if(!g_gAuto)                          { st="AUTOTRADING DESLIGADO"; sc=bad; }
   else if(g_tradingPaused)              { st="PAUSADO"; sc=warn; }
   else if(!InpEnableTrading)            { st="TRADING DESATIVADO (INPUT)"; sc=bad; }
   else if(!TFTradingAllowed())          { st="TF "+g_profileName+" SEM PERMISSAO DE ORDEM"; sc=warn; }
   else if(CountManagedPositions()>0)    { st="EM POSICAO  |  GERENCIANDO"; sc=cy; }
   else if(g_lastReason=="READY" || g_lastReason=="ORDER_SENT") { st="SETUP CONFIRMADO"; sc=acc; }
   else if(!g_gSpread || !g_gSession || !g_gNews || !g_gDaily || !g_gCool || !g_gPos || !g_gData)
                                         { st="BLOQUEADO  |  "+g_lastReason; sc=warn; }
   else                                  { st="ARMADO  |  "+g_lastReason; sc=acc; }
   hRect(g_hudUi,12,62,W-13,90,HA(sc,22));
   hRectO(g_hudUi,12,62,W-13,90,HA(sc,120));
   HLed(g_hudUi,28,76,4,sc,pulse);
   HT(g_hudUi,42,68,W-42-24,st,sc,14,true);

   if(!g_hudMin)
     {
      double bid=CurrentBid(), ask=CurrentAsk();
      int dg=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

      // ---- MERCADO ----
      int y=HY_MKT;
      HT(g_hudUi,24,y+24,60,"BID",dim,11,true);
      HT(g_hudUi,24,y+37,130,DoubleToString(bid,dg),txt,20,true,0,"Consolas");
      HT(g_hudUi,164,y+24,60,"ASK",dim,11,true);
      HT(g_hudUi,164,y+37,130,DoubleToString(ask,dg),txt,20,true,0,"Consolas");
      double lim=MathMax(g_spreadLimitPts,1.0);
      double frac=InpSpreadFilter?g_spreadPts/lim:0.0;
      color spc=(frac>1.0)?bad:(frac>0.7?warn:acc);
      HT(g_hudUi,476,y+24,172,StringFormat("SPREAD %.0f pts",g_spreadPts),spc,12,true,2);
      HBar(g_hudUi,304,y+44,172,10,MathMin(frac,1.0),spc,InpSpreadFilter?1.0:-1.0);
      HT(g_hudUi,304,y+58,172,InpSpreadFilter?StringFormat("limite %.0f pts",g_spreadLimitPts):"filtro desligado",dim,11);
      HT(g_hudUi,24,y+72,452,StringFormat("ATR %s   VOL %s   REGIME %s",DoubleToString(g_lastATR,dg),g_lastVolStatus,g_lastLocalRegime),dim,12);

      // ---- CONTEXTO ----
      y=HY_CTX;
      int cd=g_context.direction;
      color cc=(cd>0)?acc:(cd<0?bad:warn);
      string ctxTxt=(cd>0?"COMPRA":(cd<0?"VENDA":"NEUTRO"))+StringFormat("  %.0f%%",g_context.strength);
      HT(g_hudUi,24,y+22,150,ctxTxt,cc,16,true);
      HT(g_hudUi,476,y+26,100,g_context.class_name,cc,12,true,2);
      HBar(g_hudUi,182,y+30,186,10,g_context.strength/100.0,cc,InpContextAlignedStrength/100.0);
      int shown=0;
      for(int i=0;i<5;i++)
        {
         if(!g_context.tfs[i].data_ok) continue;
         int cx=24+shown*92;
         int sg=g_context.tfs[i].signal;
         color chc=(sg>0)?acc:(sg<0?bad:dim);
         hRect(g_hudUi,cx,y+52,cx+83,y+93,HA(chc,sg==0?10:30));
         hRectO(g_hudUi,cx,y+52,cx+83,y+93,HA(chc,sg==0?70:200));
         HT(g_hudUi,cx+42,y+55,76,TFToShort(g_context.tfs[i].tf),txt,12,true,1);
         if(sg==0) hRect(g_hudUi,cx+34,y+78,cx+50,y+79,HA(dim,255));
         else
           {
            bool up=(sg>0);
            if(MathAbs(sg)>=2) { HTri(g_hudUi,cx+30,y+78,6,up,chc); HTri(g_hudUi,cx+54,y+78,6,up,chc); }
            else HTri(g_hudUi,cx+42,y+78,6,up,chc);
           }
         shown++;
        }
      if(shown==0) HT(g_hudUi,24,y+58,452,"sem dados MTF ainda",warn,12);

      // ---- SETUPS ----
      y=HY_SET;
      double thr=InpMinSetupScore/100.0;
      bool bv=g_bestBuy.valid, sv=g_bestSell.valid;
      double bsc=bv?g_bestBuy.score:0.0, ssc=sv?g_bestSell.score:0.0;
      HT(g_hudUi,24,y+22,46,"BUY",acc,13,true);
      HBar(g_hudUi,74,y+26,200,10,bsc/100.0,acc,thr);
      HT(g_hudUi,284,y+21,38,StringFormat("%3.0f",bsc),bv?acc:dim,15,true,0,"Consolas");
      HT(g_hudUi,476,y+23,150,bv?g_bestBuy.reason_primary:"sem regiao",bv?(g_bestBuy.reason_primary=="READY"?acc:warn):dim,12,false,2);
      HT(g_hudUi,24,y+46,46,"SELL",bad,13,true);
      HBar(g_hudUi,74,y+50,200,10,ssc/100.0,bad,thr);
      HT(g_hudUi,284,y+45,38,StringFormat("%3.0f",ssc),sv?bad:dim,15,true,0,"Consolas");
      HT(g_hudUi,476,y+47,150,sv?g_bestSell.reason_primary:"sem regiao",sv?(g_bestSell.reason_primary=="READY"?bad:warn):dim,12,false,2);
      SetupCandidate pc;
      bool hp=HudPickCandidate(pc);
      int ri=FindRegionIndex(g_lastRegionId);
      string regTxt=(ri>=0)?(RegionBiasText(g_regions[ri].bias)+"  "+RegionSources(g_regions[ri])):"sem regiao ativa";
      HT(g_hudUi,24,y+74,68,"REGIAO",dim,12,true);
      HT(g_hudUi,96,y+74,380,regTxt,txt,12);
      HT(g_hudUi,24,y+94,68,"SETUP",dim,12,true);
      HT(g_hudUi,96,y+94,380,(hp?(pc.type==""?"-":pc.type):"-")+StringFormat("   min %.0f",InpMinSetupScore),txt,12);

      // ---- CADEIA DE GATILHO ----
      y=HY_TRG;
      bool ev=hp&&pc.trigger.event_ok, rc=hp&&pc.trigger.reaction_ok, sr=hp&&pc.trigger.structure_ok, dp=hp&&pc.trigger.displacement_ok;
      bool cf=hp&&pc.trigger_ok;
      HT(g_hudUi,476,y+4,200,cf?"CONFIRMADO":"AGUARDANDO",cf?acc:dim,12,true,2);
      string evn=(hp&&pc.trigger.event_name!="NONE")?pc.trigger.event_name:"EVENTO";
      HChip(g_hudUi,24,y+28,107,34,evn,ev,cy);
      HChip(g_hudUi,139,y+28,107,34,"REACAO",rc,cy);
      HChip(g_hudUi,254,y+28,107,34,"ESTRUT.",sr,cy);
      HChip(g_hudUi,369,y+28,107,34,"DISPLAC.",dp,cy);

      // ---- PORTOES ----
      y=HY_GAT;
      string gl[8]={"SPRD","SESS","NEWS","DIA","POS","COOL","AUTO","DADOS"};
      bool gv[8];
      gv[0]=g_gSpread; gv[1]=g_gSession; gv[2]=g_gNews; gv[3]=g_gDaily;
      gv[4]=g_gPos; gv[5]=g_gCool; gv[6]=g_gAuto; gv[7]=g_gData;
      for(int g=0;g<8;g++)
        {
         int gx=24+(int)(g*56.5);
         color gc=gv[g]?acc:bad;
         hCircle(g_hudUi,gx+5,y+30,3,HA(gc,255));
         HT(g_hudUi,gx+13,y+22,40,gl[g],gv[g]?txt:gc,11,true);
        }
      HT(g_hudUi,24,y+40,452,"MOTIVO: "+g_lastReason,g_lastDecision.action!=0?acc:dim,12);

      // ---- RESULTADO LIQUIDO (realizado = fixo, nao oscila com o preco) ----
      y=HY_DAY;
      double netD=g_stNet[0], netW=g_stNet[1], netM=g_stNet[2];
      int selp=(int)InpStatsWLPeriod;
      int nWin=g_stWins[selp], nLoss=g_stLoss[selp];
      color pcol=(netD>=0.0)?acc:bad;
      HT(g_hudUi,24,y+20,160,(netD>=0.0?"+":"")+DoubleToString(netD,2),pcol,22,true,0,"Consolas");
      HT(g_hudUi,192,y+21,60,StringFormat("W: %d",nWin),acc,13,true);
      HT(g_hudUi,258,y+21,60,StringFormat("L: %d",nLoss),nLoss>0?bad:dim,13,true);
      string perTxt=(selp==0?"dia":(selp==1?"sem":"mes"));
      double assPct=(nWin+nLoss>0)?100.0*nWin/(nWin+nLoss):0.0;
      string assTxt=(nWin+nLoss>0)?StringFormat("ASS: %.0f%% %s",assPct,perTxt):("ASS: -- "+perTxt);
      color assCol=(nWin+nLoss==0)?dim:((assPct>=50.0)?acc:warn);
      HT(g_hudUi,476,y+21,150,assTxt,assCol,13,true,2);

      string mdTxt="MD: off";
      color mdCol=dim;
      double mfrac=0.0;
      if(InpDailyTargetMoneyEnabled && InpDailyTargetMoney>0.0)
        {
         mfrac=netD/InpDailyTargetMoney;
         mdTxt=StringFormat("MD: %s / %s (%.0f%%)",DoubleToString(netD,2),DoubleToString(InpDailyTargetMoney,2),mfrac*100.0);
         mdCol=(mfrac>=1.0)?acc:txt;
        }
      HT(g_hudUi,476,y+40,290,mdTxt,mdCol,12,true,2);

      hRect(g_hudUi,24,y+58,W-25,y+67,HA(HC_TRACK,240));
      int half=(W-48)/2;
      if(mfrac>0.0) hRect(g_hudUi,24+half,y+58,24+half+(int)(half*MathMin(mfrac,1.0)),y+67,HA(acc,235));
      if(mfrac<0.0) hRect(g_hudUi,24+half-(int)(half*MathMin(-mfrac,1.0)),y+58,24+half-1,y+67,HA(bad,235));
      hRectO(g_hudUi,24,y+58,W-25,y+67,HA(cy,80));
      hLine(g_hudUi,24+half,y+55,24+half,y+70,HA(clrWhite,230));

      HT(g_hudUi,24,y+74,220,"LS: "+(netW>=0.0?"+":"")+DoubleToString(netW,2),(netW>=0.0)?acc:bad,13,true);
      HT(g_hudUi,476,y+74,220,"LM: "+(netM>=0.0?"+":"")+DoubleToString(netM,2),(netM>=0.0)?acc:bad,13,true,2);

      string tr=(g_lastDecision.entry>0.0)?StringFormat("E %s  SL %s  TP %s  SP %.1fA",DoubleToString(g_lastDecision.entry,dg),
                 g_lastDecision.sl>0.0?DoubleToString(g_lastDecision.sl,dg):"-",g_lastDecision.tp>0.0?DoubleToString(g_lastDecision.tp,dg):"-",g_lastSpaceNorm):"sem trade planejado";
      HT(g_hudUi,24,y+94,452,tr,dim,12);

      // ---- botoes ----
      for(int b=1;b<=3;b++)
        {
         bool hov=(g_hudHover==b);
         bool act=(b==1)?!g_tradingPaused:(b==3?g_mapVisible:false);
         color bcl=(b==2)?bad:(act?acc:cy);
         hRect(g_hudUi,g_hudBtn[b].x,g_hudBtn[b].y,g_hudBtn[b].x+g_hudBtn[b].w-1,g_hudBtn[b].y+g_hudBtn[b].h-1,
                               HA(bcl,hov?110:(act?42:16)));
         hRectO(g_hudUi,g_hudBtn[b].x,g_hudBtn[b].y,g_hudBtn[b].x+g_hudBtn[b].w-1,g_hudBtn[b].y+g_hudBtn[b].h-1,HA(bcl,hov?255:170));
         HT(g_hudUi,g_hudBtn[b].x+g_hudBtn[b].w/2,g_hudBtn[b].y+8,g_hudBtn[b].w-12,HudBtnLabel(b),(act||hov)?clrWhite:txt,12,true,1);
        }

      // ---- rodape ----
      color fc=InpWriteCSV?acc:warn;
      HLed(g_hudUi,20,HUD_H_EXP-14,3,fc,pulse);
      HT(g_hudUi,32,HUD_H_EXP-22,444,"CSV "+string(InpWriteCSV?"ON":"OFF")+"  |  "+CsvFileName(),dim,11);
     }

   int sy=(g_hudAnim*7)%MathMax(1,H);
   hLine(g_hudUi,2,sy,W-3,sy,HA(cy,18));
  }

//--------------------------------------------------------------------
// ciclo de vida
//--------------------------------------------------------------------
void HudRecalcScale()
  {
   double s=MathMax(0.5,MathMin(1.0,InpPanelScalePct/100.0));
   int chh=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS), cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   if(chh>40) s=MathMin(s,(double)(chh-8)/HUD_H_EXP);   // nunca maior que o grafico: nada some
   if(cw>40)  s=MathMin(s,(double)(cw-8)/HUD_W);
   g_hs=MathMax(0.45,s);
  }
int HudPxW() { return HS(HUD_W); }
int HudPxH() { return HS(g_hudMin?HUD_H_MIN:HUD_H_EXP); }

void HudClampPos()
  {
   int chh=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS), cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   if(chh>0) g_hudY=(int)ClampD(g_hudY,0,MathMax(0,chh-HudPxH()));
   if(cw>0)  g_hudX=(int)ClampD(g_hudX,0,MathMax(0,cw-HudPxW()));
  }

void PanelCreate()
  {
   if(!InpShowPanel) return;
   g_hudMin=InpPanelStartMinimized;
   g_hudX=InpPanelX; g_hudY=InpPanelY;
   HudRecalcScale();
   HudClampPos();
   g_hudH=HudPxH();
   HudLayout();
   bool a=g_hudBg.CreateBitmapLabel(HUD_OBJ_BG,g_hudX,g_hudY,HudPxW(),g_hudH,COLOR_FORMAT_ARGB_NORMALIZE);
   bool b=g_hudUi.CreateBitmapLabel(HUD_OBJ_UI,g_hudX,g_hudY,HudPxW(),g_hudH,COLOR_FORMAT_ARGB_NORMALIZE);
   if(!a || !b)
     {
      Print("AURELIS HUD: falha ao criar canvas. Erro=",GetLastError());
      return;
     }
   g_hudReady=true;
   g_hudBgDirty=true;
   PanelUpdate();
  }

void PanelUpdate()
  {
   if(!InpShowPanel || !g_hudReady) return;
   int H=g_hudMin?HUD_H_MIN:HUD_H_EXP;
   int Hpx=HS(H);
   if(Hpx!=g_hudH || (int)g_hudBg.Width()!=HudPxW())
     {
      g_hudH=Hpx;
      g_hudBg.Resize(HudPxW(),Hpx);
      g_hudUi.Resize(HudPxW(),Hpx);
      g_hudBgDirty=true;
     }
   if(g_hudBgDirty)
     {
      HudDrawBg(HUD_W,H);
      g_hudBg.Update(false);
      g_hudBgDirty=false;
     }
   g_hudAnim++;
   HudDrawUi(HUD_W,H);
   g_hudUi.Update(false);
   ChartRedraw();
  }

// chamado em CHARTEVENT_CHART_CHANGE: refaz a escala se o grafico mudou de tamanho
void HudOnChartChange()
  {
   if(!InpShowPanel || !g_hudReady) return;
   double old=g_hs;
   HudRecalcScale();
   if(MathAbs(g_hs-old)<=0.01) return;
   HudClampPos();
   ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_XDISTANCE,g_hudX); ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_YDISTANCE,g_hudY);
   ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_XDISTANCE,g_hudX); ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_YDISTANCE,g_hudY);
   g_hudH=-1;            // forca Resize + redesenho do fundo
   PanelUpdate();
  }

void PanelDestroy()
  {
   if(!g_hudReady) return;
   g_hudUi.Destroy();
   g_hudBg.Destroy();
   g_hudReady=false;
   ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
  }

int HudHit(const int x,const int y)
  {
   for(int i=0;i<4;i++)
     {
      if(i>=1 && g_hudMin) continue;
      if(x>=g_hudBtn[i].x && x<=g_hudBtn[i].x+g_hudBtn[i].w && y>=g_hudBtn[i].y && y<=g_hudBtn[i].y+g_hudBtn[i].h) return i;
     }
   return -1;
  }

void HudAction(const int id)
  {
   if(id==0)
     {
      g_hudMin=!g_hudMin;
      g_hudBgDirty=true;
     }
   else if(id==1)
     {
      g_tradingPaused=!g_tradingPaused;
      g_lastReason=g_tradingPaused?"TRADING_PAUSED":"TRADING_RESUMED";
      if(InpWriteCSV) WriteTelemetry("DECISION","",0,g_lastDecision,g_lastReason,0.0,0.0);
     }
   else if(id==2)
     {
      CloseAllManagedPositions();
      g_lastReason="MANUAL_CLOSE_ALL";
      if(InpWriteCSV) WriteTelemetry("POSITION","",0,g_lastDecision,g_lastReason,0.0,0.0);
     }
   else if(id==3)
     {
      g_mapVisible=!g_mapVisible;
      if(!g_mapVisible) { DeleteObjectsByPrefix(AURELIS_PREFIX); ChartRedraw(); }
      else DrawMap();
     }
   PanelUpdate();
  }

void HudMouse(const int mx,const int my,const uint flags)
  {
   if(!g_hudReady) return;
   int H=HudPxH();
   int px=mx-g_hudX, py=my-g_hudY;
   bool inside=(px>=0 && px<HudPxW() && py>=0 && py<H);
   int cx=(int)(px/g_hs), cy=(int)(py/g_hs);        // coordenadas de projeto (botoes e cabecalho)
   bool down=((flags&1)!=0);

   if(inside!=g_hudInside)
     {
      g_hudInside=inside;
      ChartSetInteger(0,CHART_MOUSE_SCROLL,!inside);
     }
   int hover=inside?HudHit(cx,cy):-1;
   if(hover!=g_hudHover)
     {
      g_hudHover=hover;
      PanelUpdate();
     }
   if(down && !g_hudDown)
     {
      if(hover>=0) HudAction(hover);
      else if(inside && cy<60) { g_hudDrag=true; g_hudDX=px; g_hudDY=py; }
     }
   if(g_hudDrag && down)
     {
      int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      g_hudX=(int)ClampD(mx-g_hudDX,0,MathMax(0,cw-HudPxW()));
      g_hudY=(int)ClampD(my-g_hudDY,0,MathMax(0,ch-H));
      ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_XDISTANCE,g_hudX); ObjectSetInteger(0,HUD_OBJ_BG,OBJPROP_YDISTANCE,g_hudY);
      ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_XDISTANCE,g_hudX); ObjectSetInteger(0,HUD_OBJ_UI,OBJPROP_YDISTANCE,g_hudY);
      ChartRedraw();
     }
   if(!down) g_hudDrag=false;
   g_hudDown=down;
  }

//====================================================================
// DIAGNOSTICO (CSV + Experts)
//====================================================================
string DiagString()
  {
   return StringFormat("GATES SP=%d SE=%d NW=%d DY=%d PS=%d CD=%d AU=%d DT=%d | BUY %s s=%.0f | SELL %s s=%.0f | spr=%.0f lim=%.0f",
                       (int)g_gSpread,(int)g_gSession,(int)g_gNews,(int)g_gDaily,(int)g_gPos,(int)g_gCool,(int)g_gAuto,(int)g_gData,
                       g_bestBuy.valid?g_bestBuy.reason_primary:"-",g_bestBuy.valid?g_bestBuy.score:0.0,
                       g_bestSell.valid?g_bestSell.reason_primary:"-",g_bestSell.valid?g_bestSell.score:0.0,
                       g_spreadPts,g_spreadLimitPts);
  }

//====================================================================
// ANALYSIS ORCHESTRATOR
//====================================================================
bool IsNewWorkBar()
  {
   datetime t=iTime(_Symbol,g_workTF,0);
   if(t<=0) return false;
   if(t!=g_lastBarTime)
     {
      g_lastBarTime=t;
      return true;
     }
   return false;
  }

void UpdateGlobalSnapshot(const double atr,const TFAnalysis &local_tf)
  {
   g_lastATR=atr;
   g_lastSpread=CurrentSpread();
   g_lastVolStatus=VolToText(local_tf.vol_regime);
   g_lastLocalRegime=RegimeToText(local_tf.regime);
   g_lastContextClass=g_context.class_name;
   g_lastContextDirection=g_context.direction;
   g_lastContextStrength=g_context.strength;
   g_lastDecisionBar=iTime(_Symbol,g_workTF,1);
  }

void RunAnalysis()
  {
   g_lastState="SCANNING";
   g_lastReason="SCANNING";
   g_lastRegionId="";
   g_lastSetupId="";
   g_lastTriggerId="";
   g_lastRegionScore=0.0;
   g_lastSetupScore=0.0;
   g_lastSpaceNorm=0.0;
   g_bestBuy.valid=false;
   g_bestSell.valid=false;
   g_lastDecision=MakeNoTrade("NO_REGION");

   MqlRates work_rates[];
   int total=LoadRates(g_workTF,InpStructureLookbackBars+InpATRPeriod+InpSwingFractalRadius+25,work_rates);
   double spread=CurrentSpread();
   double atr=ATRFromRates(work_rates,total,1,InpATRPeriod);
   string data_reason="";
   double dq=0.0;
   bool data_ok=CheckDataQuality(work_rates,total,spread,atr,dq,data_reason);
   if(!data_ok)
     {
      g_gData=false;
      g_lastState="BLOCKED_NO_TRADE";
      g_lastReason="DATA_INVALID";
      g_lastDecision=MakeNoTrade("DATA_INVALID",data_reason);
      WriteTelemetry("DECISION","",0,g_lastDecision,data_reason,0.0,0.0);
      PanelUpdate();
      return;
     }

   g_context=EvaluateContext();
   CollectSwings(g_workTF,g_workHighs,g_workLows);
   BuildTrendlines(atr,g_workHighs,g_workLows);
   BuildChannel(true,g_workHighs,g_workLows,atr,g_channelUp);
   BuildChannel(false,g_workHighs,g_workLows,atr,g_channelDown);
   BuildMap(atr);
   BuildLevelObjects(atr);
   BuildRegions(CurrentBid(),atr);

   TFAnalysis local=AnalyzeTF(g_workTF);
   UpdateGlobalSnapshot(atr,local);
   SelectBestSetups(g_context,atr);

   // Display best available candidate even if later rejected by hard gate.
   if(g_bestBuy.valid && (!g_bestSell.valid || g_bestBuy.score>=g_bestSell.score))
     {
      g_lastRegionId=g_bestBuy.region_id;
      g_lastRegionScore=g_regions[g_bestBuy.region_index].score;
      g_lastSetupId=g_bestBuy.id;
      g_lastSetupScore=g_bestBuy.score;
      g_lastSpaceNorm=g_bestBuy.space_norm;
     }
   else if(g_bestSell.valid)
     {
      g_lastRegionId=g_bestSell.region_id;
      g_lastRegionScore=g_regions[g_bestSell.region_index].score;
      g_lastSetupId=g_bestSell.id;
      g_lastSetupScore=g_bestSell.score;
      g_lastSpaceNorm=g_bestSell.space_norm;
     }

   g_lastState="CONTEXT_READY";
   g_lastDecision=EvaluateDecision(atr);
   g_lastDecisionText=ActionToText(g_lastDecision.action);
   g_lastReason=g_lastDecision.reason_primary;

   if(g_lastDecision.allowed)
     {
      g_lastState="TRIGGER_CONFIRMED";
      datetime trig_time=g_lastDecisionBar;
      g_lastEventId=EventIdMake(g_lastDecision.region_id,g_lastDecision.setup_id,trig_time,g_lastDecision.action);
      g_lastTriggerId=g_lastDecision.trigger_id;
      string consumed_key=g_lastEventId;
      static string consumedEvent="";
      if(consumedEvent==consumed_key)
        {
         g_lastDecision=MakeNoTrade("EVENT_CONSUMED",g_lastDecision.setup_type);
         g_lastReason="EVENT_CONSUMED";
        }
      else if(ExecuteDecision(g_lastDecision))
        {
         consumedEvent=consumed_key;
         g_lastState="ORDER_SENT";
        }
     }
   else
     {
      if(g_lastDecision.reason_primary=="NO_REGION") g_lastState="BLOCKED_NO_TRADE";
      else if(g_lastDecision.reason_primary=="NO_TRIGGER" || g_lastDecision.reason_primary=="NO_STRUCTURE") g_lastState="TRIGGER_ARMED";
      else g_lastState="BLOCKED_NO_TRADE";
     }

   if(g_lastDecision.action==ACTION_BUY && g_bestBuy.valid)
      g_lastTriggerId=g_lastDecision.trigger_id;
   else if(g_lastDecision.action==ACTION_SELL && g_bestSell.valid)
      g_lastTriggerId=g_lastDecision.trigger_id;

   if(InpPrintDecisionLine)
      PrintFormat("AURELIS %s %s | %s | ctx=%s %.0f%% | %s",_Symbol,g_profileName,g_lastReason,
                  SignToText(g_context.direction),g_context.strength,DiagString());
   WriteTelemetry("DECISION",g_lastEventId,g_lastDecision.action,g_lastDecision,DiagString(),
                  g_lastDecision.sl,g_lastDecision.tp);
   DrawMap();
   PanelUpdate();
  }

//====================================================================
// EVENT CALLBACKS
//====================================================================
int OnInit()
  {
   if(!ValidateInputs())
     {
      Print("AURELIS: invalid input combination. Review the parameter groups before starting the EA.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(!ResolveProfile()) return INIT_PARAMETERS_INCORRECT;
   if(!ValidateSymbol())
     {
      Print("AURELIS: symbol properties invalid or trading disabled.");
      return INIT_FAILED;
     }

   trade.SetExpertMagicNumber(g_magic);
   trade.SetDeviationInPoints(InpDeviationPoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_dayStart=DayStart(TimeTradeServer());
   UpdateDailyState();
   UpdateStats(true);
   ParseTrailTiers();
   OpenCSV();
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   PanelCreate();
   EventSetMillisecondTimer(250);
   PrintFormat("AURELIS v1.10 iniciado | %s %s | magic=%I64u | spreadMax=%d pts | gatilho=%s | scoreMin=%.0f | AutoTrading=%s",
               _Symbol,g_profileName,g_magic,
               SpreadLimitPointsForTF(),
               InpTriggerMode==TRIGGER_STRICT?"STRICT":"BALANCED",InpMinSetupScore,
               (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)!=0 && MQLInfoInteger(MQL_TRADE_ALLOWED)!=0)?"ON":"OFF");
   g_lastState="SCANNING";
   g_lastReason="INIT";
   g_lastDecision=MakeNoTrade("NO_REGION");
   WriteTelemetry("MARKET","",0,g_lastDecision,"EA_INIT",0.0,0.0);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   PanelDestroy();
   DeleteObjectsByPrefix(AURELIS_PREFIX);
   DeleteObjectsByPrefix(AURELIS_TRADE_PREFIX);
   if(g_csvHandle!=INVALID_HANDLE)
     {
      FileClose(g_csvHandle);
      g_csvHandle=INVALID_HANDLE;
     }
  }

void OnTick()
  {
   UpdateSpreadStats();
   UpdateDailyState();
   ManagePositions();
   if(IsNewWorkBar())
      RunAnalysis();
  }

void OnTimer()
  {
   UpdateDailyState();
   UpdateStats();
   ManagePositions();
   PanelUpdate();     // HUD a 4 Hz, independente de ticks
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE) HudOnChartChange();
   if(id==CHARTEVENT_MOUSE_MOVE)
      HudMouse((int)lparam,(int)dparam,(uint)StringToInteger(sparam));
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD) return;
   ulong deal=trans.deal;
   if(deal==0) return;
   g_statsDirty=true;     // novo deal: recalcula W/L, dia, semana e mes
   if(!HistoryDealSelect(deal)) return;
   string sym=HistoryDealGetString(deal,DEAL_SYMBOL);
   long magic=HistoryDealGetInteger(deal,DEAL_MAGIC);
   if(sym!=_Symbol || (ulong)magic!=g_magic) return;
   long entry=HistoryDealGetInteger(deal,DEAL_ENTRY);
   if(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_INOUT || entry==DEAL_ENTRY_OUT_BY)
     {
      ulong pos_id=(ulong)HistoryDealGetInteger(deal,DEAL_POSITION_ID);
      if(pos_id>0 && !PositionSelectByTicket(pos_id)) HwmDelete(pos_id);
     }
   int dir=0;
   long dtype=HistoryDealGetInteger(deal,DEAL_TYPE);
   if(dtype==DEAL_TYPE_BUY) dir=1;
   else if(dtype==DEAL_TYPE_SELL) dir=-1;
   g_lastTradeResult.deal=deal;
   g_lastTradeResult.order=(ulong)HistoryDealGetInteger(deal,DEAL_ORDER);
   g_lastTradeResult.volume=HistoryDealGetDouble(deal,DEAL_VOLUME);
   g_lastTradeResult.price=HistoryDealGetDouble(deal,DEAL_PRICE);
   g_lastTradeResult.comment=HistoryDealGetString(deal,DEAL_COMMENT);
   string etype=(entry==DEAL_ENTRY_IN?"ORDER_FILLED":(entry==DEAL_ENTRY_OUT||entry==DEAL_ENTRY_OUT_BY?"POSITION_CLOSED":"DEAL"));
   g_lastState=(entry==DEAL_ENTRY_IN?"POSITION_OPEN":"POSITION_MANAGED");
   g_lastReason=etype;
   if(InpWriteCSV) WriteTelemetry(etype,"",dir,g_lastDecision,etype,PositionSelect(_Symbol)?PositionGetDouble(POSITION_SL):0.0,PositionSelect(_Symbol)?PositionGetDouble(POSITION_TP):0.0);
  }

//====================================================================
// END OF AURELIS
//====================================================================