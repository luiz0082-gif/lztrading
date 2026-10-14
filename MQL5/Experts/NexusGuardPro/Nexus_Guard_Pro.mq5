//+------------------------------------------------------------------+
//|                                      Nexus_Guard_Pro.mq5       |
//| NEXUS GUARD PRO - multi-asset M1/M5/M30 research EA             |
//|                                                                  |
//| Research software. No profitability or robustness claim.        |
//| Signals use closed candles. MARKET BUY=live ASK, SELL=live BID. |
//+------------------------------------------------------------------+
#property copyright "NEXUS GUARD PRO"
#property version   "1.00"
#property strict
#property description "NEXUS GUARD PRO multi-asset M1/M5/M30 research EA"
#property description "Perfis M1/M5/M30, risco, calendario, trailing PieceTrend e pipeline auditavel (telemetria schema 7)"

enum ENUM_NMX_PROFILE_MODE { PROFILE_AUTO=0, // Automatico pelo periodo do grafico
                             PROFILE_MANUAL=1 // Configuracao manual
                           };
enum ENUM_NMX_SETUP_MODE { SETUP_REVERSAL=0, // Reversao depois de varredura
                           SETUP_CONTINUATION=1, // Continuacao depois de rompimento
                           SETUP_ADAPTIVE=2 // Escolha automatica pelo regime
                         };
enum ENUM_NMX_ENTRY_MODE { ENTRY_CONFIRMATION=0, // Entrada na confirmacao
                           ENTRY_RETEST=1 // Aguarda retorno ao nivel
                         };
enum ENUM_NMX_DIRECTION { DIR_NONE=0, DIR_BUY=1, DIR_SELL=-1 };
enum ENUM_NMX_SETUP { NMX_NONE=0, NMX_SWEEP_REVERSAL=1, NMX_BREAKOUT_CONTINUATION=2 };
enum ENUM_NMX_STATE
  {
   ST_INITIALIZING=0, ST_WAIT_CONTEXT=1, ST_WAIT_LEVEL=2, ST_WAIT_EVENT=3,
   ST_WAIT_STRUCTURE=4, ST_WAIT_RETEST=5, ST_SIGNAL_READY=6, ST_PREFLIGHT=7,
   ST_ORDER_PENDING=8, ST_IN_POSITION=9, ST_COOLDOWN=10, ST_BLOCKED=11,
   ST_PAUSED=12
  };
enum ENUM_NMX_REGIME
  {
   REGIME_UNKNOWN=0, REGIME_RANGE=1, REGIME_TREND_UP=2, REGIME_TREND_DOWN=3,
   REGIME_TRANSITION=4, REGIME_EVENT_SHOCK=5, REGIME_INSUFFICIENT_DATA=6
  };
enum ENUM_NMX_LEVEL_TYPE
  {
   LEVEL_NONE=0, LEVEL_PDH=1, LEVEL_PDL=2, LEVEL_PWH=3, LEVEL_PWL=4,
   LEVEL_SESSION_HIGH=5, LEVEL_SESSION_LOW=6, LEVEL_SWING_HIGH=7,
   LEVEL_SWING_LOW=8, LEVEL_EQUAL_HIGHS=9, LEVEL_EQUAL_LOWS=10
  };
enum ENUM_NMX_RISK_MODE { RISK_PERCENT_EQUITY=0, // Lote calculado pelo risco
                          RISK_FIXED_LOT=1 // Lote fixo definido pelo operador
                        };
enum ENUM_NMX_RISK_CAP_MODE
  {
   RISK_CAP_OFF=0, // Limite percentual desativado
   RISK_CAP_PLANNED_STOP=1, // Limita pelo stop planejado
   RISK_CAP_BROKER_STOP_ONLY=2 // Limita somente com stop no broker
  };
enum ENUM_NMX_EQUITY_GUARD_SCOPE
  {
   EQUITY_GUARD_ACCOUNT=0,     // Legado: usa equity total da conta
   EQUITY_GUARD_NEXUS_MAGIC=1  // Isola DailyLoss/DD ao PnL da familia de Magic do Nexus
  };
enum ENUM_NMX_STOP_MODE
  {
   STOP_STRUCTURE=0, STOP_MONEY=1, STOP_ATR=2, STOP_STRUCTURE_CAPPED_BY_MONEY=3
  };
enum ENUM_NMX_PROTECTION_MODE
  {
   PROTECTION_IMMEDIATE=0,
   PROTECTION_DELAYED=1,
   PROTECTION_NONE=2
  };
enum ENUM_NMX_TARGET_MODE
  {
   TARGET_NONE=0, TARGET_FIXED_R=1, TARGET_MONEY=2, TARGET_OPPOSITE_LEVEL=3,
   TARGET_HYBRID=4, TARGET_TRAILING_ONLY=5, TARGET_MONEY_THEN_TRAILING=6
  };
enum ENUM_NMX_TRAILING_MODE
  {
   TRAIL_MONEY=0, TRAIL_POINTS=1, TRAIL_ATR=2, TRAIL_STRUCTURE=3
  };
enum ENUM_NMX_BREAKER_ACTION
  {
   BREAKER_ALERT_ONLY=0, // Apenas alerta e registro
   BREAKER_PAUSE_ENTRIES=1, // Pausa novas entradas
   BREAKER_CLOSE_AND_PAUSE=2 // Fecha a posicao e pausa entradas
  };
enum ENUM_NMX_NEWS_IMPORTANCE
  {
   NEWS_LOW_OR_HIGHER=0, NEWS_MODERATE_OR_HIGHER=1, NEWS_HIGH_ONLY=2
  };
enum ENUM_NMX_NEWS_FAIL_MODE { NEWS_FAIL_CLOSED=0, NEWS_FAIL_OPEN=1 };
enum ENUM_NMX_PANEL_MODE { PANEL_EXPANDED=0, PANEL_MINIMIZED=1 };
enum ENUM_NMX_TEL6_PROFILE { TEL6_STANDARD=0, TEL6_RESEARCH=1, TEL6_FORENSIC=2 };

input group "NEXUS GUARD PRO / CONFIGURACAO GERAL"
input bool                    InpTradingEnabled=false;             // Ativar execucao de ordens ao iniciar
input long                    InpMagicNumber=62031061;             // Identificador exclusivo das ordens Nexus
input ENUM_NMX_PROFILE_MODE   InpProfileMode=PROFILE_AUTO;         // Perfil automatico pelo periodo ou manual
input ENUM_TIMEFRAMES         InpManualTimeframe=PERIOD_M5;        // Periodo usado somente no perfil manual
input ENUM_NMX_SETUP_MODE     InpManualSetupMode=SETUP_ADAPTIVE;   // Setup usado somente no perfil manual
input ENUM_NMX_ENTRY_MODE     InpManualEntryMode=ENTRY_RETEST;     // Entrada por confirmacao ou reteste
input int                     InpTimerSeconds=3;                   // Frequencia geral de atualizacao, em segundos

input group "DADOS E REGIME DE MERCADO"
input int                     InpBarsToLoad=900;                   // Velas carregadas para calculos e backfill
input int                     InpMinimumHistoryBars=400;           // Historico minimo para liberar o motor
input int                     InpATRPeriod=14;                     // Periodo do ATR
input int                     InpRegimeLookback=30;                // Velas avaliadas para definir o regime
input double                  InpTrendEfficiencyMin=0.34;          // Eficiencia minima para classificar tendencia
input double                  InpRangeEfficiencyMax=0.22;          // Eficiencia maxima para classificar lateralidade
input double                  InpTrendMoveATRMin=1.80;             // Movimento minimo em ATR para tendencia
input double                  InpEventShockATR=3.20;               // Amplitude em ATR que caracteriza choque

input group "CONTEXTO DE MULTIPLOS PERIODOS"
input bool                    InpRequireFullMTFAlignment=false;    // Exigir alinhamento total M1, M5 e M30
input int                     InpMTFRefreshSeconds=15;             // Intervalo de atualizacao do contexto MTF

input group "MAPA DE NIVEIS"
input int                     InpLevelLookback=300;                // Velas usadas para localizar niveis
input int                     InpSwingStrength=3;                  // Forca minima de topo ou fundo local
input int                     InpMaxLevelsPerSide=12;              // Maximo de niveis acima e abaixo do preco
input double                  InpEqualToleranceATR=0.06;           // Tolerancia para topos ou fundos iguais
input double                  InpMergeToleranceATR=0.04;           // Distancia para unir niveis proximos
input double                  InpMaxLevelDistanceATR=5.0;          // Distancia maxima do nivel em ATR
input double                  InpMinimumLevelQuality=50.0;         // Qualidade minima do nivel, de 0 a 100

input group "EVENTO, ESTRUTURA E FLUXO DE VELA"
input double                  InpSweepMinATR=0.04;                 // Varredura minima do nivel em ATR
input double                  InpSweepMaxATR=1.25;                 // Varredura maxima aceita em ATR
input double                  InpBreakoutBufferATR=0.04;           // Folga exigida no rompimento, em ATR
input double                  InpMinRejectionWick=0.30;            // Proporcao minima do pavio de rejeicao
input double                  InpBuyCLVMin=0.60;                   // Fechamento minimo da vela para compra
input double                  InpSellCLVMax=0.40;                  // Fechamento maximo da vela para venda
input double                  InpMinDisplacementRangeATR=0.85;     // Amplitude minima da vela de impulso
input double                  InpMinDisplacementBody=0.55;         // Corpo minimo da vela de impulso
input double                  InpMaxDisplacementOverlap=0.65;      // Sobreposicao maxima com a vela anterior
input int                     InpMaxStructureBars=4;               // Velas maximas para confirmar mudanca estrutural
input double                  InpStructureBreakBufferATR=0.03;     // Folga do rompimento estrutural
input int                     InpMaxRetestBars=6;                  // Velas maximas para ocorrer o reteste
input double                  InpRetestToleranceATR=0.12;          // Tolerancia de toque no reteste, em ATR
input double                  InpRetestInvalidationATR=0.20;       // Folga antes de invalidar o reteste
input double                  InpRetestConfirmCLV=0.55;            // Fechamento minimo da vela de confirmacao do reteste (venda usa 1-valor)
input double                  InpMinimumQualityScore=72.0;         // Score minimo para liberar o sinal
input bool                    InpUseRelativeTickVolume=true;       // Considerar volume de ticks relativo
input int                     InpRelativeVolumeLookback=20;        // Velas da media de volume relativo
input bool                    InpUseVWAPContext=true;              // Considerar VWAP diario no score

input group "RISCO E PROTECAO"
input ENUM_NMX_RISK_MODE      InpRiskMode=RISK_PERCENT_EQUITY;     // Calcular lote por risco ou usar lote fixo
input double                  InpRiskPercent=0.25;                 // Percentual de equity arriscado por entrada
input double                  InpFixedLot=0.01;                    // Lote quando o modo for lote fixo
input double                  InpHardMaxRiskPercent=0.50;          // Limite maximo de risco por entrada
input ENUM_NMX_RISK_CAP_MODE  InpRiskCapMode=RISK_CAP_PLANNED_STOP;// Como aplicar o limite maximo de risco
input ENUM_NMX_STOP_MODE      InpStopMode=STOP_STRUCTURE_CAPPED_BY_MONEY;// Metodo de calculo do stop
input double                  InpStopMoney=15.00;                  // Perda monetaria planejada no stop
input double                  InpStopATR=1.20;                     // Distancia do stop no modo ATR
input double                  InpStopBufferATR=0.10;               // Folga estrutural do stop em ATR
input int                     InpStopBufferTicks=2;                // Folga adicional do stop em ticks
input ENUM_NMX_PROTECTION_MODE InpProtectionMode=PROTECTION_IMMEDIATE;// Stop imediato, atrasado ou sem stop inicial
input int                     InpDelayedStopM1Minutes=15;          // Minutos negativos antes do stop no M1
input int                     InpDelayedStopM5Minutes=30;          // Minutos negativos antes do stop no M5
input int                     InpDelayedStopM30Minutes=120;        // Minutos negativos antes do stop no M30
input bool                    InpResetNegativeTimerOnRecovery=true;// Zerar cronometro quando voltar ao positivo
input double                  InpMaxDailyLossPercent=1.50;         // Perda diaria maxima da conta, em percentual
input bool                    InpUseDailyProfitTarget=false;       // Pausar novas entradas ao bater meta diaria
input double                  InpDailyProfitTargetMoney=200.00;    // Meta diaria de lucro em dinheiro
input bool                    InpUseDailyLossMoney=false;          // Pausar por perda diaria em dinheiro
input double                  InpDailyLossMoney=100.00;            // Limite diario de perda em dinheiro
input double                  InpMaxDrawdownPercent=8.00;          // Drawdown maximo desde o pico diario
input ENUM_NMX_EQUITY_GUARD_SCOPE InpEquityGuardScope=EQUITY_GUARD_ACCOUNT; // Escopo dos guards de perda/DD
input int                     InpMaxTradesPerDay=8;                // Numero maximo de operacoes fechadas no dia
input int                     InpMaxConsecutiveLosses=3;           // Perdas consecutivas antes de pausar
input int                     InpMaxOpenPositions=3;               // Posicoes Nexus simultaneas permitidas
input int                     InpMaxCurrencyExposures=2;           // Exposicoes maximas por moeda
input double                  InpMinimumMarginLevel=300.0;         // Nivel minimo de margem em percentual
input bool                    InpUseFloatingBreaker=false;         // Disjuntor de perda flutuante (funciona sem SL no broker)
input double                  InpFloatingLossPositionMoney=60.00;  // Perda flutuante liquida por posicao que aciona o disjuntor
input double                  InpFloatingLossTotalMoney=120.00;    // Perda flutuante liquida total das posicoes Nexus que aciona o disjuntor
input ENUM_NMX_BREAKER_ACTION InpFloatingBreakerAction=BREAKER_CLOSE_AND_PAUSE; // Acao quando o disjuntor dispara

input group "ALVO E GERENCIAMENTO DA POSICAO"
input ENUM_NMX_TARGET_MODE    InpTargetMode=TARGET_MONEY_THEN_TRAILING;// Metodo de alvo e saida
input double                  InpTargetMoney=25.00;                // Lucro monetario usado como alvo
input double                  InpTargetR=1.80;                     // Multiplo de risco usado no alvo R
input double                  InpMinimumExpectedR=1.00;            // Relacao retorno/risco minima
input bool                    InpUseTrailing=true;                 // Ativar trailing stop
input ENUM_NMX_TRAILING_MODE  InpTrailingMode=TRAIL_MONEY;         // Unidade usada pelo trailing
input double                  InpTrailingActivationMoney=20.00;   // Lucro liquido de PICO que arma o trailing monetario (remove o TP)
input double                  InpTrailRatio=0.60;                  // Recuo inicial = razao x ativacao (modo TRAIL_MONEY, lei PieceTrend)
input double                  InpTrailExponent=0.82;               // Crescimento do recuo com o pico: D = razao x ativ x (pico/ativ)^expoente
input double                  InpTrailingStepMoney=0.50;      // Avanco minimo do piso protegido para enviar novo SL
input double                  InpTrailingActivationPoints=100.0;   // Ativacao do trailing em pontos
input double                  InpTrailingDistancePoints=60.0;      // Distancia do trailing em pontos
input double                  InpTrailingStepPoints=10.0;          // Passo do trailing em pontos
input double                  InpTrailingActivationATR=1.20;       // Ativacao do trailing em ATR
input double                  InpTrailingDistanceATR=1.00;         // Distancia do trailing em ATR
input double                  InpTrailingStepATR=0.20;             // Passo do trailing em ATR
input bool                    InpUseBreakEven=false;               // Mover protecao para preco de entrada
input double                  InpBreakEvenTriggerR=1.00;           // Lucro em R para ativar break-even
input int                     InpBreakEvenOffsetTicks=1;           // Lucro adicional protegido em ticks
input bool                    InpUseTimeStop=true;                 // Encerrar posicao ao exceder tempo maximo
input int                     InpManualMaxBarsInTrade=36;          // Velas maximas no perfil manual

input group "EXECUCAO E SPREAD ADAPTATIVO"
input bool                    InpUseAdaptiveSpread=true;          // Ajustar spread automaticamente ao simbolo/corretora
input int                     InpSpreadLearningWindow=300;        // Amostras mantidas para aprender o spread normal
input int                     InpSpreadMinimumSamples=40;         // Amostras exigidas antes de confiar no aprendizado
input double                  InpSpreadPercentile=75.0;           // Percentil do spread normal usado como referencia
input double                  InpSpreadSafetyMultiplier=1.35;     // Folga aplicada sobre o spread normal aprendido
input double                  InpSpreadMinimumATRLimit=0.10;      // Menor limite automatico permitido em ATR
input double                  InpSpreadMaximumATRLimit=0.30;      // Teto de emergencia do limite automatico em ATR
input double                  InpSpreadWarmupATRLimit=0.20;       // Limite temporario durante o aprendizado inicial
input int                     InpSpreadSampleSeconds=3;           // Intervalo entre amostras de spread
input double                  InpMaxSpreadPoints=0.0;              // TETO ABSOLUTO de spread em pontos (vale sempre, tambem no modo adaptativo); zero desativa
input double                  InpMaxSpreadATRRatio=0.20;           // Limite fixo quando o modo automatico estiver desligado
input int                     InpMaxDeviationPoints=20;            // Desvio maximo aceito pelo broker, em pontos
input double                  InpMaxEntryDriftATRRatio=0.25;       // Distancia maxima entre sinal e preco executavel, em ATR
input int                     InpCooldownBars=5;                   // Velas de espera depois de uma operacao encerrada
input int                     InpCooldownAfterRejectBars=0;        // Velas de espera depois de candidato rejeitado (0 = sem espera)

input group "NOTICIAS ECONOMICAS"
input bool                    InpUseNewsFilter=true;                // Pausar entradas perto de noticias
input int                     InpNewsMinutesBefore=30;             // Minutos de bloqueio antes da noticia
input int                     InpNewsMinutesAfter=15;              // Minutos de bloqueio depois da noticia
input int                     InpNewsWarningMinutes=60;            // Antecedencia para avisar no painel
input ENUM_NMX_NEWS_IMPORTANCE InpNewsImportance=NEWS_HIGH_ONLY;   // Importancia minima da noticia
input ENUM_NMX_NEWS_FAIL_MODE InpNewsFailMode=NEWS_FAIL_CLOSED;    // Conduta quando calendario falhar
input bool                    InpXAUUsesUSDNews=true;              // Aplicar noticias USD ao ouro
input bool                    InpTesterAllowWithoutCalendar=true;  // Permitir tester sem calendario historico





input group "REGISTROS E ARQUIVOS CSV"
input bool                    InpVerboseJournal=true;              // Registrar eventos importantes no Diario do MT5
input bool                    InpEnableCSV=true;                   // Ativar arquivos CSV exclusivos do Nexus
input bool                    InpCSVInCommonFolder=false;          // Gravar na pasta comum dos terminais
input string                  InpCSVPrefix="NEXUS_GUARD_PRO";      // Prefixo dos arquivos CSV

input int                     InpCSVMaxFileMB=25;                  // Rotacionar legado para nova PART ao atingir o limite

input group "TEL6 / TELEMETRIA E PESQUISA"
input bool                    InpEnableTEL6=true;                  // Ativar telemetria estruturada Schema 6
input ENUM_NMX_TEL6_PROFILE   InpTEL6Profile=TEL6_RESEARCH;       // STANDARD, RESEARCH ou FORENSIC
input int                     InpTEL6MaxFileMB=25;                 // Rotacao append-only PART001+
input int                     InpTEL6OutcomeBars=30;               // Horizonte maximo do contrafactual em candles
input int                     InpTEL6MomentIntervalMs=1000;        // Amostragem MOMENT_STATE no modo FORENSIC
input int                     InpTEL6IntrabarIntervalMs=250;       // Amostragem INTRABAR_TRACE quando armado
input int                     InpTEL6IntrabarPostSignalSeconds=120;// Janela forense apos oportunidade/sinal
input int                     InpTEL6ProfitSampleSeconds=5;        // Intervalo minimo entre linhas PROFIT_MANAGEMENT sem mudanca relevante
input double                  InpTEL6ProfitSampleMoney=0.50;       // Variacao minima de P/L que forca nova linha PROFIT_MANAGEMENT
input int                     InpTEL6StateHeartbeatSeconds=30;     // Heartbeat maximo de MARKET/RISK
input bool                    InpTEL6FlushCritical=true;           // Flush imediato em eventos operacionais criticos

input group "PAINEL VISUAL"
input bool                    InpShowPanel=true;                   // Exibir painel no grafico
input ENUM_BASE_CORNER        InpPanelCorner=CORNER_LEFT_UPPER;    // Canto de ancoragem do painel
input int                     InpPanelX=2;                         // Distancia horizontal do painel
input int                     InpPanelY=2;                         // Distancia vertical do painel
input bool                    InpAvoidNativeOneClickOverlay=true;  // Evitar sobreposicao ao painel nativo
input int                     InpNativeTopOverlayHeight=78;        // Altura reservada ao painel nativo
input long                    InpPanelZOrder=1000;                 // Prioridade entre objetos do grafico
input int                     InpPanelScalePercent=100;            // Escala visual do painel em percentual
input bool                    InpShowLiveScore=true;               // Mostrar score mudando em tempo real
input int                     InpLiveScoreRefreshMs=250;           // Atualizacao visual do score em milissegundos
input int                     InpLiveProjectionSeconds=3;          // Segundos finais para indicar pre-armado

struct RuntimeProfile
  {
   ENUM_TIMEFRAMES tf;
   ENUM_NMX_SETUP_MODE setup_mode;
   ENUM_NMX_ENTRY_MODE entry_mode;
   string name;
   int max_structure_bars;
   int max_retest_bars;
   int max_bars_trade;
   double minimum_score;
   double risk_percent;
   double max_spread_atr;
  };

struct SymbolModel
  {
   bool valid;
   int digits;
   double point;
   double tick_size;
   double tick_value;
   double tick_value_profit;
   double tick_value_loss;
   double contract_size;
   double volume_min;
   double volume_max;
   double volume_step;
   long stops_level;
   long freeze_level;
   string base_currency;
   string profit_currency;
   string margin_currency;
   string asset_class;
  };

struct MarketLevel
  {
   bool valid;
   ENUM_NMX_LEVEL_TYPE type;
   int side;
   double price;
   double quality;
   int age;
   int tests;
   int confluences;
   datetime source_time;
  };

struct FlowSnapshot
  {
   bool valid;
   double range;
   double body_ratio;
   double upper_wick;
   double lower_wick;
   double clv;
   double range_atr;
   double overlap;
   double relative_volume;
   double efficiency;
   int direction;
  };

struct TimeframeBias
  {
   bool valid;
   bool confirmed;
   ENUM_TIMEFRAMES timeframe;
   ENUM_NMX_DIRECTION direction;
   ENUM_NMX_REGIME regime;
   double efficiency;
   double move_atr;
   double atr;
   datetime closed_bar_time;
   string reason;
  };

struct Candidate
  {
   bool valid;
   ENUM_NMX_SETUP setup;
   ENUM_NMX_DIRECTION direction;
   MarketLevel level;
   datetime event_time;
   datetime state_time;
   double atr;
   double signal_anchor;
   double extreme;
   double micro_break;
   double retest_level;
   double opposite_target;
   double score;
   int bars_waited;
   string reason;
   FlowSnapshot flow;
  };

struct TradeIntent
  {
   bool valid;
   ENUM_NMX_DIRECTION direction;
   ENUM_NMX_SETUP setup;
   double signal_anchor;
   double entry;
   double stop;
   double target;
   double volume;
   double calculated_volume;
   double requested_stop_money;
   double risk_money;
   double hard_max_risk_money;
   double effective_risk_money;
   double effective_risk_percent;
   double expected_profit;
   double expected_r;
   double drift_atr;
   string tag;
  };

struct PositionInfoNMX
  {
   bool valid;
   ulong ticket;
   ulong identifier;
   long magic;
   ENUM_TIMEFRAMES origin_tf;
   string comment;
   ENUM_POSITION_TYPE type;
   double volume;
   double open_price;
   double stop;
   double target;
   double profit;
   double swap;
   datetime open_time;
  };

struct DailyStats
  {
   double net;
   double gross;
   double costs;
   double realized_profit;
   double realized_loss;
   int trades;
   int wins;
   int losses;
   int breakeven;
   int consecutive_losses;
   double start_equity;
   double peak_equity;
   double daily_loss_percent;
   double drawdown_percent;
   bool blocked;
   string reason;
  };


struct MoneyStopSolverDiagnostics
  {
   bool     attempted;
   bool     success;
   ENUM_ORDER_TYPE type;
   double   volume;
   double   entry;
   double   requested_money;
   double   probe_price;
   long     probe_ticks;
   bool     probe_calc_ok;
   double   probe_pnl;
   int      last_error;
   long     bracket_low_ticks;
   long     bracket_high_ticks;
   int      iterations;
   double   calculated_stop;
   double   validated_loss;
   string   failure_reason;
  };

struct MoneyTargetSolverDiagnostics
  {
   bool     attempted;
   bool     success;
   ENUM_ORDER_TYPE type;
   double   volume;
   double   entry;
   double   configured_money;
   double   authoritative_money;
   double   probe_price;
   long     probe_ticks;
   bool     probe_calc_ok;
   double   probe_pnl;
   int      last_error;
   long     bracket_low_ticks;
   long     bracket_high_ticks;
   int      iterations;
   double   calculated_target;
   double   validated_profit;
   double   tolerance_money;
   string   failure_reason;
  };

struct MoneyTrailLockSolverDiagnostics
  {
   bool     attempted;
   bool     success;
   double   requested_floor;
   double   gross_required;
   double   estimated_costs;
   double   swap;
   double   probe_price;
   long     probe_ticks;
   bool     probe_calc_ok;
   double   probe_gross;
   int      last_error;
   long     bracket_low_ticks;
   long     bracket_high_ticks;
   int      iterations;
   double   calculated_stop;
   double   gross_profit_at_sl;
   double   expected_net_floor;
   double   tolerance_money;
   string   failure_reason;
  };



struct TEL6OutcomeTrack
  {
   bool active;
   string opportunity_id;
   string signal_id;
   ENUM_NMX_DIRECTION direction;
   datetime start_server;
   datetime origin_bar_time;
   double entry;
   double stop;
   double target;
   double opposite_target;
   double target_money;
   double volume;
   double risk_distance;
   double mfe_price;
   double mae_price;
   double mfe_points;
   double mae_points;
   double mfe_money;
   double mae_money;
   datetime mfe_time;
   datetime mae_time;
   datetime hit_05r_time;
   datetime hit_10r_time;
   datetime hit_15r_time;
   datetime hit_20r_time;
   datetime hit_target_time;
   datetime hit_target_money_time;
   datetime hit_stop_time;
   bool hit_opposite_liquidity;
   datetime opposite_liquidity_time;
   string decision;
   string final_ordering;
  };

struct TEL6ObjectCache
  {
   string object_id;
   string state_hash;
   bool seen;
  };

struct TEL6TradeLink
  {
   ulong position_id;
   string candidate_id;
   string opportunity_id;
   string setup_id;
   string signal_id;
   string intent_id;
  };

struct TEL6PositionStateCache
  {
   ulong position_id;
   string state_hash;
   ulong last_ms;
   double last_pnl;
  };

RuntimeProfile g_profile;
SymbolModel g_symbol;
MarketLevel g_levels[];
MqlRates g_rates[];
Candidate g_candidate;
DailyStats g_stats;
ENUM_NMX_STATE g_state=ST_INITIALIZING;
ENUM_NMX_REGIME g_regime=REGIME_UNKNOWN;
ENUM_NMX_PANEL_MODE g_panel_mode=PANEL_EXPANDED;
datetime g_last_bar=0;
datetime g_last_trade_bar=0;
datetime g_cooldown_anchor_bar=0;
int g_cooldown_bars=0;
ulong g_costs_cache_pid=0; double g_costs_cache_value=0.0; ulong g_costs_cache_ms=0;
ulong g_modify_block_until_ms=0;
string g_last_block_key="";
string g_breaker_reason="";
ulong g_owner_pids[]; bool g_owner_flags[];
datetime g_last_news_check=0;
datetime g_next_news_time=0;
datetime g_clear_armed_until=0;
datetime g_power_armed_until=0;
int g_atr_handle=INVALID_HANDLE;
double g_atr=0.0;
double g_regime_efficiency=0.0;
double g_regime_move_atr=0.0;
double g_vwap=0.0;
double g_live_score=0.0;
double g_last_spread_atr=0.0;
double g_last_spread_points=0.0;
double g_spread_samples_atr[];
int g_spread_sample_count=0;
int g_spread_sample_cursor=0;
ulong g_last_spread_sample_ms=0;
double g_adaptive_spread_baseline=0.0;
double g_effective_spread_atr_limit=0.0;
string g_reason="INITIALIZING";
string g_blocking_gate="";
string g_last_event="";
string g_last_event_reason="";
string g_last_action="";
string g_last_action_result="";
string g_config_reason="";
string g_config_detail="";
string g_last_gate_reason="";
string g_last_gate_detail="";
datetime g_last_gate_time=0;
string g_news_status="NOT_CHECKED";
string g_next_news_name="";
bool g_entries_paused=false;
bool g_runtime_trading_enabled=false;
bool g_config_blocked=false;
bool g_switch_state_restored=false;
bool g_live_score_valid=false;
bool g_live_structure_ready=false;
bool g_live_prearmed=false;
bool g_prearm_logged=false;
bool g_clear_menu=false;
string g_prefix="";
long g_magic=0;
double g_atr_ratio=0.0;
int g_rendered_panel_mode=-1;
TimeframeBias g_mtf[3];
datetime g_last_mtf_update=0;
ulong g_last_live_render_ms=0;
datetime g_last_audit_snapshot=0;
ulong g_audit_sequence=0;
string g_run_id="";
ulong g_telemetry_sequence=0;
ulong g_decision_sequence=0;
ulong g_intent_sequence=0;
string g_config_hash="";
string g_current_signal_id="";
string g_current_signal_signature="";
string g_current_decision_id="";
string g_current_intent_id="";
MoneyStopSolverDiagnostics g_money_stop_diag;
MoneyTargetSolverDiagnostics g_money_target_diag;
MoneyTrailLockSolverDiagnostics g_money_trail_lock_diag;
bool g_telemetry_ok=true;
string g_telemetry_error="";
string g_current_csv_part="PART001";
bool g_panel_layout_logged=false;
int g_last_panel_scale=-1;
string g_last_panel_layout_error="";
long g_last_chart_width=0;
long g_last_chart_height=0;
double g_pending_reference_stop=0.0;
double g_pending_reference_risk=0.0;
string g_last_export_file="";
const string NMX_EA_NAME="NEXUS GUARD PRO";
const string NMX_RELEASE="RC";
const string NMX_VERSION="1.00";
const string NMX_BUILD_ID="NGP-20261006-UNIFIED";
const int NMX_SCHEMA_VERSION=5; // Schema legado preservado para dual telemetry
const int NMX_TEL6_SCHEMA_VERSION=7;
const string NMX_TEL6_BUILD_ID="NGP-20261006-UNIFIED";
const string NMX_TEL6_RELEASE_STATE="RC";

bool g_tel6_initialized=false;
bool g_tel6_write_fault=false;
ulong g_tel6_sequence=0;
ulong g_tel6_id_counter=0;
ulong g_tel6_last_moment_ms=0;
ulong g_tel6_last_intrabar_ms=0;
ulong g_tel6_last_market_heartbeat_ms=0;
ulong g_tel6_last_risk_heartbeat_ms=0;
datetime g_tel6_intrabar_armed_until=0;
string g_tel6_run_id="";
string g_tel6_instance_id="";
string g_tel6_config_hash="";
string g_tel6_strategy_hash="";
string g_tel6_telemetry_hash="";
string g_tel6_visual_hash="";
string g_tel6_candidate_id="";
string g_tel6_setup_id="";
string g_tel6_signal_id="";
string g_tel6_opportunity_id="";
string g_tel6_decision_id="";
string g_tel6_intent_id="";
string g_tel6_marker_id="";
string g_tel6_last_market_hash="";
string g_tel6_last_risk_hash="";
bool g_tel6_opportunity_snapshot_written=false;
bool g_tel6_preflight_ordercheck_executed=false;
bool g_tel6_preflight_ordercheck_bool=false;
TEL6OutcomeTrack g_tel6_outcomes[];
TEL6ObjectCache g_tel6_objects[];
TEL6TradeLink g_tel6_trade_links[];
TEL6PositionStateCache g_tel6_position_states[];
string g_tel6_pending_candidate_id="";
string g_tel6_pending_opportunity_id="";
string g_tel6_pending_setup_id="";
string g_tel6_pending_signal_id="";
string g_tel6_pending_intent_id="";

const string NGP_PORTFOLIO_RISK_CONTRACT="PORTFOLIO_RISK_PERMISSION";
const string NGP_PORTFOLIO_RISK_STATE="PREPARED_NOT_CONNECTED";


color C_BG=C'10,16,26';
color C_BLOCK=C'17,27,42';
color C_BORDER=C'38,58,86';
color C_TEXT=C'206,221,239';
color C_CYAN=C'28,225,209';
color C_BLUE=C'56,156,255';
color C_GREEN=C'41,225,154';
color C_YELLOW=C'255,200,45';
color C_RED=C'255,66,91';
color C_MUTED=C'112,136,163';

double Clamp(const double v,const double lo,const double hi)
  { return MathMax(lo,MathMin(hi,v)); }

bool Positive(const double v)
  { return MathIsValidNumber(v) && v>0.0; }

string BoolText(const bool v)
  { return v ? "true" : "false"; }


string TrimCopy(string value)
  {
   StringTrimLeft(value); StringTrimRight(value); return value;
  }

string UpperCopy(string value)
  { StringToUpper(value); return value; }

string LowerCopy(string value)
  { StringToLower(value); return value; }

string SanitizeSecretFree(string value)
  {
   StringReplace(value,"\r"," "); StringReplace(value,"\n"," ");
   return value;
  }

uint FNV1a32(const string value)
  {
   uint h=2166136261;
   int n=StringLen(value);
   for(int i=0;i<n;i++)
     {
      uint ch=(uint)StringGetCharacter(value,i);
      h^=(ch & 0xFF); h*=16777619;
      if(ch>255) { h^=((ch>>8)&0xFF); h*=16777619; }
     }
   return h;
  }

string Hash8(const string value)
  { return StringFormat("%08X",FNV1a32(value)); }

ulong NextTelemetrySequence()
  { g_telemetry_sequence++; return g_telemetry_sequence; }

string ShortRunID()
  {
   int n=StringLen(g_run_id); return (n<=10 ? g_run_id : StringSubstr(g_run_id,n-10));
  }

string CurrentSignalID()
  {
   if(!g_candidate.valid) return "";
   string sig=StringFormat("%I64d|%d|%d|%.10f",(long)g_candidate.event_time,(int)g_candidate.setup,
                           (int)g_candidate.direction,g_candidate.signal_anchor);
   if(sig!=g_current_signal_signature)
     {
      g_current_signal_signature=sig;
      g_current_signal_id=StringFormat("SIG_%s_%s",ShortRunID(),Hash8(sig));
      g_current_decision_id=""; g_current_intent_id="";
     }
   return g_current_signal_id;
  }

string NewDecisionID()
  {
   g_decision_sequence++;
   g_current_decision_id=StringFormat("DEC_%s_%I64u",ShortRunID(),g_decision_sequence);
   return g_current_decision_id;
  }

string NewIntentID()
  {
   g_intent_sequence++;
   g_current_intent_id=StringFormat("INT_%s_%I64u",ShortRunID(),g_intent_sequence);
   return g_current_intent_id;
  }

string UTCNowText()
  { return TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS); }

string ServerNowText()
  { return TimeToString(TimeTradeServer(),TIME_DATE|TIME_SECONDS); }

string TelemetryIdentityHeader()
  {
   return "SchemaVersion;ProductName;ProductVersion;BuildID;ReleaseState;RunID;ConfigHash;SequenceNumber;DecisionID;IntentID;SignalID;EventID;ServerTimestamp;UTCTimestamp;Broker;Symbol;Timeframe;Magic";
  }

void CSVAddIdentity(string &row,const string decision_id="",const string intent_id="",const string signal_id="",const string event_id="")
  {
   CSVAddI(row,NMX_SCHEMA_VERSION); CSVAdd(row,NMX_EA_NAME); CSVAdd(row,NMX_VERSION); CSVAdd(row,NMX_BUILD_ID);
   CSVAdd(row,NMX_RELEASE); CSVAdd(row,g_run_id); CSVAdd(row,g_config_hash); CSVAddU(row,NextTelemetrySequence());
   CSVAdd(row,decision_id); CSVAdd(row,intent_id); CSVAdd(row,signal_id); CSVAdd(row,event_id);
   CSVAdd(row,ServerNowText()); CSVAdd(row,UTCNowText()); CSVAdd(row,AccountInfoString(ACCOUNT_COMPANY));
   CSVAdd(row,_Symbol); CSVAdd(row,TimeframeShort(g_profile.tf)); CSVAddI(row,g_magic);
  }

string RiskSafetyStateText()
  {
   if(InpRiskCapMode==RISK_CAP_OFF && InpProtectionMode==PROTECTION_NONE)
      return "RISCO ELEVADO: CAP OFF + SEM PROTECAO";
   if(InpRiskCapMode==RISK_CAP_OFF) return "RISCO ELEVADO: RISK CAP OFF";
   if(InpProtectionMode==PROTECTION_NONE) return "RISCO ELEVADO: SEM PROTECAO";
   if(InpProtectionMode==PROTECTION_DELAYED) return "RISCO ELEVADO: PROTECAO ATRASADA";

   bool exact_baseline=(InpRiskMode==RISK_PERCENT_EQUITY &&
                        MathAbs(InpRiskPercent-0.25)<0.000001 &&
                        MathAbs(InpHardMaxRiskPercent-0.50)<0.000001 &&
                        InpRiskCapMode==RISK_CAP_PLANNED_STOP &&
                        InpStopMode==STOP_STRUCTURE_CAPPED_BY_MONEY &&
                        MathAbs(InpStopMoney-15.00)<0.000001 &&
                        InpProtectionMode==PROTECTION_IMMEDIATE);
   if(exact_baseline) return "BASELINE SEGURO";

   if(InpRiskCapMode==RISK_CAP_PLANNED_STOP && InpProtectionMode==PROTECTION_IMMEDIATE)
     {
      if(InpRiskMode==RISK_FIXED_LOT || InpRiskPercent>0.25 || InpHardMaxRiskPercent>0.50)
         return "PERFIL AGRESSIVO LIMITADO";
      return "PERFIL LIMITADO / FORA DO BASELINE";
     }
   return "PERFIL DE PESQUISA";
  }













string StateKey(const string suffix)
  { return StringFormat("NGP.%I64d.%s.%s.%s",g_magic,_Symbol,EnumToString(g_profile.tf),suffix); }

string FamilyStateKey(const string suffix)
  {
   // Portfolio safeguards are shared by every chart/symbol that belongs to the
   // same account and Nexus Magic family.  Keeping _Symbol in this key made
   // daily equity baselines diverge between charts in a multi-asset deployment.
   return StringFormat("NGP.%I64d.%I64d.FAMILY.%s",AccountInfoInteger(ACCOUNT_LOGIN),InpMagicNumber,suffix);
  }

string PositionStateKey(const PositionInfoNMX &p,const string suffix)
  { return StringFormat("NGP.%I64d.%I64d.%s.POSITION.%I64u.%s",AccountInfoInteger(ACCOUNT_LOGIN),InpMagicNumber,_Symbol,p.ticket,suffix); }

string LegacyPositionStateKey(const PositionInfoNMX &p,const string suffix)
  {
   return StringFormat("NMX.%I64d.%s.%s.P.%I64u.%s",p.magic,_Symbol,
                       EnumToString(p.origin_tf),p.ticket,suffix);
  }

string SwitchStateKey(const string suffix)
  {
   return StringFormat("NGP.%I64d.%I64d.%I64d.%s.TF_SWITCH.%s",AccountInfoInteger(ACCOUNT_LOGIN),
                       InpMagicNumber,ChartID(),_Symbol,suffix);
  }

bool IsNexusMagic(const long magic)
  {
   return magic==InpMagicNumber || magic==InpMagicNumber+1 ||
          magic==InpMagicNumber+5 || magic==InpMagicNumber+30;
  }

string TimeframeShort(const ENUM_TIMEFRAMES tf)
  {
   if(tf==PERIOD_M1) return "M1";
   if(tf==PERIOD_M5) return "M5";
   if(tf==PERIOD_M30) return "M30";
   return EnumToString(tf);
  }

string ProtectionModeText()
  {
   if(InpProtectionMode==PROTECTION_DELAYED) return "STOP ATRASADO";
   if(InpProtectionMode==PROTECTION_NONE) return "SEM STOP INICIAL";
   return "STOP IMEDIATO";
  }

string EquityGuardScopeText()
  {
   return (InpEquityGuardScope==EQUITY_GUARD_NEXUS_MAGIC ? "NEXUS_MAGIC" : "ACCOUNT");
  }

double NexusOwnFloatingNet()
  {
   double total=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(!IsNexusMagic(PositionGetInteger(POSITION_MAGIC))) continue;
      total+=PositionGetDouble(POSITION_PROFIT);
      total+=PositionGetDouble(POSITION_SWAP);
     }
   return total;
  }

void ObserveAdaptiveSpread(const MqlTick &tick)
  {
   if(!InpUseAdaptiveSpread || !Positive(g_atr) || !Positive(g_symbol.point) ||
      !Positive(tick.bid) || !Positive(tick.ask) || tick.ask<=tick.bid) return;
   ulong now_ms=GetTickCount64();
   if(g_last_spread_sample_ms>0 &&
      now_ms-g_last_spread_sample_ms<(ulong)MathMax(1,InpSpreadSampleSeconds)*1000) return;
   g_last_spread_sample_ms=now_ms;
   int capacity=MathMax(20,InpSpreadLearningWindow);
   if(ArraySize(g_spread_samples_atr)!=capacity)
     {
      ArrayResize(g_spread_samples_atr,capacity);
      ArrayInitialize(g_spread_samples_atr,0.0);
      g_spread_sample_count=0; g_spread_sample_cursor=0;
     }
   double ratio=(tick.ask-tick.bid)/g_atr;
   if(!MathIsValidNumber(ratio) || ratio<=0.0 || ratio>2.0) return;
   // Spread acima do teto absoluto nunca entra no aprendizado: o limite adaptativo nao pode "andar" para cima dele.
   if(InpMaxSpreadPoints>0.0 && (tick.ask-tick.bid)/g_symbol.point>InpMaxSpreadPoints) return;
   g_spread_samples_atr[g_spread_sample_cursor]=ratio;
   g_spread_sample_cursor=(g_spread_sample_cursor+1)%capacity;
   if(g_spread_sample_count<capacity) g_spread_sample_count++;
  }

double SpreadPercentile(const double percentile)
  {
   if(g_spread_sample_count<=0) return 0.0;
   double ordered[]; ArrayResize(ordered,g_spread_sample_count);
   for(int i=0;i<g_spread_sample_count;i++) ordered[i]=g_spread_samples_atr[i];
   ArraySort(ordered);
   double p=Clamp(percentile,1.0,99.0)/100.0;
   int index=(int)MathFloor(p*(g_spread_sample_count-1));
   return ordered[MathMax(0,MathMin(index,g_spread_sample_count-1))];
  }

double EffectiveSpreadATRLimit()
  {
   if(!InpUseAdaptiveSpread)
     {
      g_adaptive_spread_baseline=0.0;
      g_effective_spread_atr_limit=MathMax(0.001,g_profile.max_spread_atr);
      return g_effective_spread_atr_limit;
     }
   int required=MathMax(10,MathMin(InpSpreadMinimumSamples,MathMax(20,InpSpreadLearningWindow)));
   if(g_spread_sample_count<required)
     {
      g_adaptive_spread_baseline=0.0;
      g_effective_spread_atr_limit=Clamp(InpSpreadWarmupATRLimit,
                                         InpSpreadMinimumATRLimit,
                                         InpSpreadMaximumATRLimit);
      return g_effective_spread_atr_limit;
     }
   g_adaptive_spread_baseline=SpreadPercentile(InpSpreadPercentile);
   g_effective_spread_atr_limit=Clamp(g_adaptive_spread_baseline*MathMax(1.0,InpSpreadSafetyMultiplier),
                                      InpSpreadMinimumATRLimit,
                                      InpSpreadMaximumATRLimit);
   return g_effective_spread_atr_limit;
  }

string SpreadLearningText()
  {
   if(!InpUseAdaptiveSpread) return "FIXO";
   int required=MathMax(10,MathMin(InpSpreadMinimumSamples,MathMax(20,InpSpreadLearningWindow)));
   if(g_spread_sample_count<required)
      return StringFormat("APRENDENDO %d/%d",g_spread_sample_count,required);
   return "ADAPTATIVO";
  }

int DelayedStopMinutes(const ENUM_TIMEFRAMES tf)
  {
   if(tf==PERIOD_M1) return MathMax(0,InpDelayedStopM1Minutes);
   if(tf==PERIOD_M5) return MathMax(0,InpDelayedStopM5Minutes);
   if(tf==PERIOD_M30) return MathMax(0,InpDelayedStopM30Minutes);
   return MathMax(0,InpDelayedStopM5Minutes);
  }

bool InitialBrokerStopEnabled()
  { return InpProtectionMode==PROTECTION_IMMEDIATE; }

bool HardRiskEnforcedAtEntry()
  {
   if(InpRiskCapMode==RISK_CAP_PLANNED_STOP) return true;
   if(InpRiskCapMode==RISK_CAP_BROKER_STOP_ONLY)
      return InpProtectionMode==PROTECTION_IMMEDIATE;
   return false;
  }

string RiskCapModeText()
  {
   if(InpRiskCapMode==RISK_CAP_PLANNED_STOP) return "PLANNED_STOP";
   if(InpRiskCapMode==RISK_CAP_BROKER_STOP_ONLY) return "BROKER_STOP_ONLY";
   return "OFF";
  }

ENUM_TIMEFRAMES PositionOriginTimeframe(const long magic,const string comment)
  {
   // R3 compatibility: old positions encoded the timeframe in Magic.
   if(magic==InpMagicNumber+1) return PERIOD_M1;
   if(magic==InpMagicNumber+5) return PERIOD_M5;
   if(magic==InpMagicNumber+30) return PERIOD_M30;
   // R4 uses one stable Magic and records the source profile in the comment.
   if(StringFind(comment,"NMX_M1_")==0) return PERIOD_M1;
   if(StringFind(comment,"NMX_M5_")==0) return PERIOD_M5;
   if(StringFind(comment,"NMX_M30_")==0) return PERIOD_M30;
   return g_profile.tf;
  }

double ReadPositionState(const PositionInfoNMX &p,const string suffix,const double fallback)
  {
   string key=PositionStateKey(p,suffix);
   if(GlobalVariableCheck(key)) return GlobalVariableGet(key);
   string legacy=LegacyPositionStateKey(p,suffix);
   if(GlobalVariableCheck(legacy))
     {
      double value=GlobalVariableGet(legacy);
      GlobalVariableSet(key,value);
      return value;
     }
   return fallback;
  }

bool HasPositionState(const PositionInfoNMX &p,const string suffix)
  {
   return GlobalVariableCheck(PositionStateKey(p,suffix)) ||
          GlobalVariableCheck(LegacyPositionStateKey(p,suffix));
  }

void WritePositionState(const PositionInfoNMX &p,const string suffix,const double value)
  { GlobalVariableSet(PositionStateKey(p,suffix),value); }





void SaveTimeframeSwitchState()
  {
   GlobalVariableSet(SwitchStateKey("TIME"),(double)TimeLocal());
   GlobalVariableSet(SwitchStateKey("RUNTIME"),g_runtime_trading_enabled ? 1.0 : 0.0);
   GlobalVariableSet(SwitchStateKey("PAUSED"),g_entries_paused ? 1.0 : 0.0);
   GlobalVariableSet(SwitchStateKey("FROM_TF"),(double)g_profile.tf);
   GlobalVariablesFlush();
  }

bool RestoreTimeframeSwitchState()
  {
   string time_key=SwitchStateKey("TIME");
   if(!GlobalVariableCheck(time_key)) return false;
   datetime stored=(datetime)(long)GlobalVariableGet(time_key);
   bool fresh=(stored>0 && MathAbs((long)(TimeLocal()-stored))<=30);
   if(fresh)
     {
      string runtime_key=SwitchStateKey("RUNTIME");
      string pause_key=SwitchStateKey("PAUSED");
      g_runtime_trading_enabled=GlobalVariableCheck(runtime_key) && GlobalVariableGet(runtime_key)>0.5;
      g_entries_paused=GlobalVariableCheck(pause_key) && GlobalVariableGet(pause_key)>0.5;
     }
   GlobalVariableDel(time_key);
   GlobalVariableDel(SwitchStateKey("RUNTIME"));
   GlobalVariableDel(SwitchStateKey("PAUSED"));
   GlobalVariableDel(SwitchStateKey("FROM_TF"));
   return fresh;
  }

string AccountModeText()
  {
   ENUM_ACCOUNT_TRADE_MODE m=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   if(m==ACCOUNT_TRADE_MODE_DEMO) return "DEMO";
   if(m==ACCOUNT_TRADE_MODE_REAL) return "REAL";
   if(m==ACCOUNT_TRADE_MODE_CONTEST) return "CONTEST";
   return "UNKNOWN";
  }

string SetupText(const ENUM_NMX_SETUP s)
  {
   if(s==NMX_SWEEP_REVERSAL) return "SWEEP REVERSAL";
   if(s==NMX_BREAKOUT_CONTINUATION) return "BREAKOUT CONTINUATION";
   return "NONE";
  }

string DirectionText(const ENUM_NMX_DIRECTION d)
  {
   if(d==DIR_BUY) return "BUY";
   if(d==DIR_SELL) return "SELL";
   return "NONE";
  }

string LevelText(const ENUM_NMX_LEVEL_TYPE t)
  {
   switch(t)
     {
      case LEVEL_PDH: return "PDH"; case LEVEL_PDL: return "PDL";
      case LEVEL_PWH: return "PWH"; case LEVEL_PWL: return "PWL";
      case LEVEL_SESSION_HIGH: return "SESSION HIGH";
      case LEVEL_SESSION_LOW: return "SESSION LOW";
      case LEVEL_SWING_HIGH: return "SWING HIGH";
      case LEVEL_SWING_LOW: return "SWING LOW";
      case LEVEL_EQUAL_HIGHS: return "EQUAL HIGHS";
      case LEVEL_EQUAL_LOWS: return "EQUAL LOWS";
      default: return "NONE";
     }
  }

string RegimeText(const ENUM_NMX_REGIME r)
  {
   switch(r)
     {
      case REGIME_RANGE: return "RANGE"; case REGIME_TREND_UP: return "TREND_UP";
      case REGIME_TREND_DOWN: return "TREND_DOWN"; case REGIME_TRANSITION: return "TRANSITION";
      case REGIME_EVENT_SHOCK: return "EVENT_SHOCK";
      case REGIME_INSUFFICIENT_DATA: return "INSUFFICIENT_DATA";
      default: return "UNKNOWN";
     }
  }

string StateText(const ENUM_NMX_STATE s)
  {
   switch(s)
     {
      case ST_INITIALIZING: return "INICIALIZANDO";
      case ST_WAIT_CONTEXT: return "AGUARDANDO CONTEXTO";
      case ST_WAIT_LEVEL: return "AGUARDANDO NIVEL";
      case ST_WAIT_EVENT: return "AGUARDANDO EVENTO";
      case ST_WAIT_STRUCTURE: return "AGUARDANDO ESTRUTURA";
      case ST_WAIT_RETEST: return "AGUARDANDO RETESTE";
      case ST_SIGNAL_READY: return "SINAL PRONTO";
      case ST_PREFLIGHT: return "PREFLIGHT";
      case ST_ORDER_PENDING: return "ORDEM PENDENTE";
      case ST_IN_POSITION: return "POSICAO ABERTA";
      case ST_COOLDOWN: return "COOLDOWN";
      case ST_BLOCKED: return "BLOQUEADO";
      case ST_PAUSED: return "ENTRADAS PAUSADAS";
     }
   return "DESCONHECIDO";
  }

datetime DayStart(const datetime value)
  {
   MqlDateTime p; if(!TimeToStruct(value,p)) return 0;
   p.hour=0; p.min=0; p.sec=0; return StructToTime(p);
  }

int VolumeDigits(const double step)
  {
   int d=0; double x=step;
   while(d<8 && MathAbs(x-MathRound(x))>1e-8) { x*=10.0; d++; }
   return d;
  }

double NormalizeVolumeDown(const double value)
  {
   if(!g_symbol.valid || !Positive(value)) return 0.0;
   double capped=MathMin(value,g_symbol.volume_max);
   double result=MathFloor((capped+1e-12)/g_symbol.volume_step)*g_symbol.volume_step;
   result=NormalizeDouble(result,VolumeDigits(g_symbol.volume_step));
   if(result<g_symbol.volume_min-1e-12) return 0.0;
   return result;
  }

double NormalizePrice(const double value)
  {
   if(!g_symbol.valid || !Positive(value)) return 0.0;
   return NormalizeDouble(MathRound(value/g_symbol.tick_size)*g_symbol.tick_size,g_symbol.digits);
  }

double NormalizePriceSide(const double value,const bool up)
  {
   if(!g_symbol.valid || !Positive(value)) return 0.0;
   double raw=value/g_symbol.tick_size;
   double ticks=(up ? MathCeil(raw-1e-10) : MathFloor(raw+1e-10));
   return NormalizeDouble(ticks*g_symbol.tick_size,g_symbol.digits);
  }

ENUM_ORDER_TYPE_FILLING FillingMode()
  {
   long flags=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   if((flags&SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) return ORDER_FILLING_FOK;
   if((flags&SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC) return ORDER_FILLING_IOC;
   if((ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE)!=SYMBOL_TRADE_EXECUTION_MARKET)
      return ORDER_FILLING_RETURN;
   return ORDER_FILLING_FOK;
  }

bool LoadSymbolModel(string &reason)
  {
   ZeroMemory(g_symbol);
   g_symbol.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   g_symbol.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   g_symbol.tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   g_symbol.tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   g_symbol.tick_value_profit=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_PROFIT);
   g_symbol.tick_value_loss=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
   g_symbol.contract_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   g_symbol.volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   g_symbol.volume_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   g_symbol.volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   g_symbol.stops_level=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   g_symbol.freeze_level=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   g_symbol.base_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   g_symbol.profit_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   g_symbol.margin_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);
   string s=_Symbol; StringToUpper(s);
   if(StringFind(s,"XAU")>=0 || StringFind(s,"GOLD")>=0) g_symbol.asset_class="METAL";
   else if(StringLen(g_symbol.base_currency)==3 && StringLen(g_symbol.profit_currency)==3) g_symbol.asset_class="FOREX";
   else g_symbol.asset_class="CFD";
   g_symbol.valid=(g_symbol.digits>=0 && Positive(g_symbol.point) && Positive(g_symbol.tick_size) &&
                   Positive(g_symbol.volume_min) && Positive(g_symbol.volume_max) && Positive(g_symbol.volume_step));
   if(!g_symbol.valid) { reason="SYMBOL_SPECIFICATION_INVALID"; return false; }
   if(!Positive(g_symbol.tick_value) && !Positive(g_symbol.tick_value_profit) && !Positive(g_symbol.tick_value_loss))
     { reason="SYMBOL_MONEY_MODEL_UNVERIFIED"; return false; }
   reason="SYMBOL_MODEL_READY";
   return true;
  }

bool ConfigureProfile(string &reason)
  {
   ENUM_TIMEFRAMES tf=(InpProfileMode==PROFILE_AUTO ? (ENUM_TIMEFRAMES)_Period : InpManualTimeframe);
   if(tf!=PERIOD_M1 && tf!=PERIOD_M5 && tf!=PERIOD_M30)
     { reason="ONLY_M1_M5_M30_ALLOWED"; return false; }
   g_profile.tf=tf;
   // R4: one stable family Magic. The source timeframe travels separately in
   // the order comment and position metadata, so a chart-period change cannot
   // orphan an open position from trailing/break-even/time-stop management.
   g_magic=InpMagicNumber;
   if(InpProfileMode==PROFILE_MANUAL)
     {
      g_profile.setup_mode=InpManualSetupMode;
      g_profile.entry_mode=InpManualEntryMode;
      g_profile.name="MANUAL";
      g_profile.max_structure_bars=InpMaxStructureBars;
      g_profile.max_retest_bars=InpMaxRetestBars;
      g_profile.max_bars_trade=InpManualMaxBarsInTrade;
      g_profile.minimum_score=InpMinimumQualityScore;
      g_profile.risk_percent=InpRiskPercent;
      g_profile.max_spread_atr=InpMaxSpreadATRRatio;
     }
   else if(tf==PERIOD_M1)
     {
      g_profile.setup_mode=SETUP_REVERSAL; g_profile.entry_mode=ENTRY_CONFIRMATION;
      g_profile.name="M1 TACTICAL"; g_profile.max_structure_bars=3; g_profile.max_retest_bars=0;
      g_profile.max_bars_trade=20; g_profile.minimum_score=72.0;
      g_profile.risk_percent=MathMin(InpRiskPercent,0.15); g_profile.max_spread_atr=MathMin(InpMaxSpreadATRRatio,0.08);
     }
   else if(tf==PERIOD_M5)
     {
      g_profile.setup_mode=SETUP_ADAPTIVE; g_profile.entry_mode=ENTRY_RETEST;
      g_profile.name="M5 ADAPTIVE"; g_profile.max_structure_bars=4; g_profile.max_retest_bars=6;
      g_profile.max_bars_trade=36; g_profile.minimum_score=72.0;
      g_profile.risk_percent=MathMin(InpRiskPercent,0.25); g_profile.max_spread_atr=MathMin(InpMaxSpreadATRRatio,0.06);
     }
   else
     {
      g_profile.setup_mode=SETUP_CONTINUATION; g_profile.entry_mode=ENTRY_RETEST;
      g_profile.name="M30 STRUCTURAL"; g_profile.max_structure_bars=3; g_profile.max_retest_bars=8;
      g_profile.max_bars_trade=24; g_profile.minimum_score=70.0;
      g_profile.risk_percent=MathMin(InpRiskPercent,0.35); g_profile.max_spread_atr=MathMin(InpMaxSpreadATRRatio,0.05);
     }
   reason="PROFILE_READY";
   return true;
  }

int CSVFlags(const bool read=false)
  {
   // CSV telemetry is append-only. FILE_WRITE by itself truncates the file on
   // every event, which was why only the most recent Nexus row remained.
   int flags=FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE;
   if(InpCSVInCommonFolder) flags|=FILE_COMMON;
   return flags;
  }

string CSVSafeToken(string value)
  {
   StringReplace(value," ","_"); StringReplace(value,"/","_"); StringReplace(value,"\\","_");
   StringReplace(value,":","_"); StringReplace(value,"*","_"); StringReplace(value,"?","_");
   StringReplace(value,"\"","_"); StringReplace(value,"<","_"); StringReplace(value,">","_");
   StringReplace(value,"|","_");
   return value;
  }

string CSVFamilyToken(string subject)
  {
   subject=UpperCopy(subject);
   if(subject=="AUDIT") return "AUDIT";
   if(subject=="CANDLES") return "CANDLES";
   if(subject=="TRADES") return "TRADES";
   if(subject=="JOURNAL") return "JOURNAL";
   if(subject=="NEWS_INTELLIGENCE") return "NEWS_INTELLIGENCE";
   if(subject=="NEWS_DECISIONS") return "NEWS_DECISIONS";
   if(subject=="RISK_STATE") return "RISK_STATE";
   if(subject=="EXECUTION") return "EXECUTION";
   if(subject=="POSITION_MANAGEMENT") return "POSITION_MANAGEMENT";
   if(subject=="RUN_CONFIG") return "RUN_CONFIG";
   return CSVSafeToken(subject);
  }

string CSVRelativeFolder()
  { return "NEXUS_GUARD_PRO\\"+CSVSafeToken(_Symbol); }

bool EnsureCSVFolder()
  {
   int common=(InpCSVInCommonFolder ? FILE_COMMON : 0);
   ResetLastError();
   FolderCreate("NEXUS_GUARD_PRO",common);
   ResetLastError();
   if(FolderCreate(CSVRelativeFolder(),common) || GetLastError()==0 || GetLastError()==5010) return true;
   // FolderCreate returns false when it already exists on some builds.  A file
   // open later remains the final authority, so do not treat that alone as fatal.
   return true;
  }

string CSVPartFile(const string subject,const int part,const datetime when=0)
  {
   datetime stamp=(when>0 ? when : TimeTradeServer());
   if(stamp<=0) stamp=TimeLocal();
   string day=TimeToString(stamp,TIME_DATE); StringReplace(day,".","");
   return StringFormat("%s\\%s_%s_%s_%s_PART%03d.csv",CSVRelativeFolder(),CSVFamilyToken(subject),
                       CSVSafeToken(_Symbol),CSVSafeToken(TimeframeShort(g_profile.tf)),day,part);
  }

string CSVSubjectFile(const string subject,const datetime when=0)
  { return CSVPartFile(subject,1,when); }

string CSVFolderText()
  { return (InpCSVInCommonFolder ? "Terminal\\Common\\Files\\" : "MQL5\\Files\\")+CSVRelativeFolder(); }

bool CSVFileExists(const string file_name)
  { return FileIsExist(file_name,(InpCSVInCommonFolder ? FILE_COMMON : 0)); }

string CSVResolveCompatibleFile(const string subject,const string header,const datetime when=0)
  {
   EnsureCSVFolder();
   ulong max_bytes=(ulong)MathMax(1,InpCSVMaxFileMB)*1024*1024;
   for(int part=1;part<=999;part++)
     {
      string file_name=CSVPartFile(subject,part,when);
      if(!CSVFileExists(file_name))
        {
         g_current_csv_part=StringFormat("PART%03d",part);
         return file_name;
        }
      ResetLastError();
      int h=FileOpen(file_name,CSVFlags(true));
      if(h==INVALID_HANDLE) continue;
      ulong size=FileSize(h);
      FileSeek(h,0,SEEK_SET);
      string existing=(size>0 ? FileReadString(h) : "");
      StringTrimLeft(existing); StringTrimRight(existing);
      string first_data="";
      if(size>0 && !FileIsEnding(h))
        {
         first_data=FileReadString(h);
         StringTrimLeft(first_data); StringTrimRight(first_data);
        }
      FileClose(h);

      bool schema_compatible=true;
      if(first_data!="")
        {
         int sep=StringFind(first_data,";");
         string schema_token=(sep>=0 ? StringSubstr(first_data,0,sep) : first_data);
         schema_compatible=((int)StringToInteger(schema_token)==NMX_SCHEMA_VERSION);
        }
      if(size==0 || (existing==header && schema_compatible && size<max_bytes))
        {
         g_current_csv_part=StringFormat("PART%03d",part);
         return file_name;
        }
     }
   g_telemetry_ok=false; g_telemetry_error="CSV_PART_EXHAUSTED";
   return CSVPartFile(subject,999,when);
  }

string CSVCell(string value)
  {
   bool quote=(StringFind(value,";")>=0 || StringFind(value,"\"")>=0 ||
               StringFind(value,"\r")>=0 || StringFind(value,"\n")>=0);
   StringReplace(value,"\"","\"\""); StringReplace(value,"\r"," "); StringReplace(value,"\n"," ");
   return (quote ? "\""+value+"\"" : value);
  }

void CSVAdd(string &row,const string value)
  {
   if(StringLen(row)>0) row+=";";
   row+=CSVCell(value);
  }

void CSVAddI(string &row,const long value)
  { CSVAdd(row,StringFormat("%I64d",value)); }

void CSVAddU(string &row,const ulong value)
  { CSVAdd(row,StringFormat("%I64u",value)); }

void CSVAddD(string &row,const double value,const int digits=6)
  { CSVAdd(row,DoubleToString(value,digits)); }

bool CSVAppendLine(const string file_name,const string header,const string row,const string subject)
  {
   string resolved=CSVResolveCompatibleFile(subject,header);
   ResetLastError();
   int h=FileOpen(resolved,CSVFlags(false));
   if(h==INVALID_HANDLE)
     {
      g_telemetry_ok=false;
      g_telemetry_error=StringFormat("CSV_OPEN_FAILED_%s_%d",subject,GetLastError());
      PrintFormat("NGP|TELEMETRY_IO_ERROR|subject=%s|file=%s|folder=%s|error=%d",
                  subject,resolved,CSVFolderText(),GetLastError());
      return false;
     }
   bool empty=(FileSize(h)==0); FileSeek(h,0,SEEK_END);
   if(empty) FileWriteString(h,header+"\r\n");
   uint written=FileWriteString(h,row+"\r\n");
   FileFlush(h); FileClose(h);
   if(written==0)
     {
      g_telemetry_ok=false;
      g_telemetry_error=StringFormat("CSV_WRITE_FAILED_%s_%d",subject,GetLastError());
      PrintFormat("NGP|TELEMETRY_IO_ERROR|subject=%s|file=%s|folder=%s|error=%d",
                  subject,resolved,CSVFolderText(),GetLastError());
      return false;
     }
   if(g_telemetry_error=="" || StringFind(g_telemetry_error,subject)>=0)
     { g_telemetry_ok=true; g_telemetry_error=""; }
   return true;
  }

bool CSVEnsureFile(const string file_name,const string header,const string subject)
  {
   string resolved=CSVResolveCompatibleFile(subject,header);
   ResetLastError();
   int h=FileOpen(resolved,CSVFlags(false));
   if(h==INVALID_HANDLE)
     {
      g_telemetry_ok=false; g_telemetry_error=StringFormat("CSV_OPEN_FAILED_%s_%d",subject,GetLastError());
      PrintFormat("NGP|TELEMETRY_IO_ERROR|subject=%s|file=%s|folder=%s|error=%d",
                  subject,resolved,CSVFolderText(),GetLastError());
      return false;
     }
   if(FileSize(h)==0) FileWriteString(h,header+"\r\n");
   FileFlush(h); FileClose(h);
   if(g_telemetry_error=="" || StringFind(g_telemetry_error,subject)>=0)
     { g_telemetry_ok=true; g_telemetry_error=""; }
   return true;
  }






string JournalCSVHeader()
  {
   return TelemetryIdentityHeader()+";LocalTime;Severity;Component;Event;Reason;RawMessage;OrderID;DealID;PositionID";
  }

string EventSeverity(const string event_name)
  {
   string e=UpperCopy(event_name);
   if(StringFind(e,"CRITICAL")>=0) return "CRITICAL";
   if(StringFind(e,"ERROR")>=0 || StringFind(e,"FAILED")>=0) return "ERROR";
   if(StringFind(e,"REJECTED")>=0 || StringFind(e,"BLOCK")>=0) return "BLOCK";
   if(StringFind(e,"NEWS")>=0) return "NEWS";
   if(StringFind(e,"RISK")>=0 || StringFind(e,"MARGIN")>=0 || StringFind(e,"STOP")>=0) return "RISK";
   if(StringFind(e,"ORDER")>=0 || StringFind(e,"DEAL")>=0 || StringFind(e,"POSITION")>=0 || StringFind(e,"TRADE")>=0) return "TRADE";
   if(StringFind(e,"CANDIDATE")>=0 || StringFind(e,"PREFLIGHT")>=0 || StringFind(e,"INTENT")>=0) return "DECISION";
   if(StringFind(e,"WARNING")>=0) return "WARNING";
   return "INFO";
  }

string EventComponent(const string event_name)
  {
   string e=UpperCopy(event_name);
   if(StringFind(e,"NEWS")>=0 || StringFind(e,"CALENDAR")>=0) return "NEWS";
   if(StringFind(e,"PANEL")>=0) return "PANEL";
   if(StringFind(e,"CSV")>=0 || StringFind(e,"TELEMETRY")>=0) return "TELEMETRY";
   if(StringFind(e,"RISK")>=0 || StringFind(e,"MARGIN")>=0 || StringFind(e,"STOP")>=0) return "RISK";
   if(StringFind(e,"ORDER")>=0 || StringFind(e,"DEAL")>=0 || StringFind(e,"POSITION")>=0 || StringFind(e,"TRADE")>=0) return "EXECUTION";
   return "ENGINE";
  }

void WriteJournalCSV(const string event_name,const string clean,const string order_id="",const string deal_id="",const string position_id="")
  {
   if(!InpEnableCSV) return;
   string row="";
   CSVAddIdentity(row,g_current_decision_id,g_current_intent_id,CurrentSignalID());
   CSVAdd(row,TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS)); CSVAdd(row,EventSeverity(event_name));
   CSVAdd(row,EventComponent(event_name)); CSVAdd(row,event_name); CSVAdd(row,g_reason);
   CSVAdd(row,StringFormat("NGP|%s|%s|%s|%s",event_name,_Symbol,TimeframeShort(g_profile.tf),clean));
   CSVAdd(row,order_id); CSVAdd(row,deal_id); CSVAdd(row,position_id);
   CSVAppendLine(CSVSubjectFile("JOURNAL"),JournalCSVHeader(),row,"JOURNAL");
  }













bool EventBelongsInJournal(const string event_name)
  {
   // LIVE_SCORE_UPDATED is high-frequency observability, not an operational event.
   // It remains in AUDIT.csv, while crossings/confirmation remain in Journal.
   if(event_name=="LIVE_SCORE_UPDATED") return false;
   return true;
  }

//+------------------------------------------------------------------+
//| TEL6 - telemetry-only layer (Schema 6)                           |
//| Invariant: NO_OUTCOME_TO_DECISION_FEEDBACK                       |
//+------------------------------------------------------------------+
uint TEL6FNV1a32(const string value)
  {
   uint h=2166136261;
   int n=StringLen(value);
   for(int i=0;i<n;i++)
     {
      uint ch=(uint)StringGetCharacter(value,i);
      h^=(ch & 0xFF); h*=16777619;
      if(ch>255) { h^=((ch>>8)&0xFF); h*=16777619; }
     }
   return h;
  }

string TEL6Hash8(const string value)
  { return StringFormat("%08X",TEL6FNV1a32(value)); }

string TEL6ProfileText()
  {
   if(InpTEL6Profile==TEL6_FORENSIC) return "FORENSIC";
   if(InpTEL6Profile==TEL6_RESEARCH) return "RESEARCH";
   return "STANDARD";
  }

string TEL6ShortRunID()
  {
   return TEL6Hash8(g_tel6_run_id);
  }

ulong TEL6NextSequence()
  { g_tel6_sequence++; return g_tel6_sequence; }

string TEL6NewID(const string prefix)
  {
   g_tel6_id_counter++;
   return StringFormat("%s_%s_%I64u",prefix,TEL6ShortRunID(),g_tel6_id_counter);
  }

string TEL6StrategyConfigCanonical()
  {
   string s="";
   s+=StringFormat("Symbol=%s|TF=%s|Magic=%I64d|ProfileMode=%d|SetupMode=%d|EntryMode=%d|Timer=%d|",_Symbol,EnumToString(g_profile.tf),InpMagicNumber,(int)InpProfileMode,(int)g_profile.setup_mode,(int)g_profile.entry_mode,InpTimerSeconds);
   s+=StringFormat("Bars=%d|MinHist=%d|ATR=%d|Regime=%d|TrendER=%.10f|RangeER=%.10f|TrendMove=%.10f|Shock=%.10f|",InpBarsToLoad,InpMinimumHistoryBars,InpATRPeriod,InpRegimeLookback,InpTrendEfficiencyMin,InpRangeEfficiencyMax,InpTrendMoveATRMin,InpEventShockATR);
   s+=StringFormat("MTF=%s|MTFRefresh=%d|LevelLookback=%d|Swing=%d|MaxLevelSide=%d|EqTol=%.10f|MergeTol=%.10f|MaxLevelDist=%.10f|MinLevel=%.10f|",BoolText(InpRequireFullMTFAlignment),InpMTFRefreshSeconds,InpLevelLookback,InpSwingStrength,InpMaxLevelsPerSide,InpEqualToleranceATR,InpMergeToleranceATR,InpMaxLevelDistanceATR,InpMinimumLevelQuality);
   s+=StringFormat("SweepMin=%.10f|SweepMax=%.10f|BreakBuf=%.10f|Wick=%.10f|BuyCLV=%.10f|SellCLV=%.10f|DispRange=%.10f|DispBody=%.10f|Overlap=%.10f|MaxStruct=%d|StructBuf=%.10f|MaxRetest=%d|RetTol=%.10f|RetInv=%.10f|MinScore=%.10f|RelVol=%s|RelVolLB=%d|VWAP=%s|",InpSweepMinATR,InpSweepMaxATR,InpBreakoutBufferATR,InpMinRejectionWick,InpBuyCLVMin,InpSellCLVMax,InpMinDisplacementRangeATR,InpMinDisplacementBody,InpMaxDisplacementOverlap,InpMaxStructureBars,InpStructureBreakBufferATR,InpMaxRetestBars,InpRetestToleranceATR,InpRetestInvalidationATR,InpMinimumQualityScore,BoolText(InpUseRelativeTickVolume),InpRelativeVolumeLookback,BoolText(InpUseVWAPContext));
   s+=StringFormat("RiskMode=%d|RiskPct=%.10f|FixedLot=%.10f|HardMax=%.10f|RiskCap=%d|StopMode=%d|StopMoney=%.10f|StopATR=%.10f|StopBufATR=%.10f|StopBufTicks=%d|Protection=%d|DelayM1=%d|DelayM5=%d|DelayM30=%d|ResetNeg=%s|",(int)InpRiskMode,InpRiskPercent,InpFixedLot,InpHardMaxRiskPercent,(int)InpRiskCapMode,(int)InpStopMode,InpStopMoney,InpStopATR,InpStopBufferATR,InpStopBufferTicks,(int)InpProtectionMode,InpDelayedStopM1Minutes,InpDelayedStopM5Minutes,InpDelayedStopM30Minutes,BoolText(InpResetNegativeTimerOnRecovery));
   s+=StringFormat("MaxDailyLoss=%.10f|DailyProfitOn=%s|DailyProfit=%.10f|DailyLossMoneyOn=%s|DailyLossMoney=%.10f|MaxDD=%.10f|MaxTrades=%d|MaxLossSeq=%d|MaxOpen=%d|MaxCurr=%d|MinMargin=%.10f|",InpMaxDailyLossPercent,BoolText(InpUseDailyProfitTarget),InpDailyProfitTargetMoney,BoolText(InpUseDailyLossMoney),InpDailyLossMoney,InpMaxDrawdownPercent,InpMaxTradesPerDay,InpMaxConsecutiveLosses,InpMaxOpenPositions,InpMaxCurrencyExposures,InpMinimumMarginLevel);
   s+=StringFormat("TargetMode=%d|TargetMoney=%.10f|TargetR=%.10f|MinR=%.10f|Trailing=%s|TrailMode=%d|TrailActMoney=%.10f|TrailRatio=%.10f|TrailExp=%.10f|TrailStepMoney=%.10f|TrailActPts=%.10f|TrailDistPts=%.10f|TrailStepPts=%.10f|TrailActATR=%.10f|TrailDistATR=%.10f|TrailStepATR=%.10f|BE=%s|BETrigger=%.10f|BEOffset=%d|TimeStop=%s|ManualMaxBars=%d|",(int)InpTargetMode,InpTargetMoney,InpTargetR,InpMinimumExpectedR,BoolText(InpUseTrailing),(int)InpTrailingMode,InpTrailingActivationMoney,InpTrailRatio,InpTrailExponent,InpTrailingStepMoney,InpTrailingActivationPoints,InpTrailingDistancePoints,InpTrailingStepPoints,InpTrailingActivationATR,InpTrailingDistanceATR,InpTrailingStepATR,BoolText(InpUseBreakEven),InpBreakEvenTriggerR,InpBreakEvenOffsetTicks,BoolText(InpUseTimeStop),InpManualMaxBarsInTrade);
   s+=StringFormat("AdaptiveSpread=%s|SpreadWindow=%d|SpreadMinSamples=%d|SpreadPctl=%.10f|SpreadMult=%.10f|SpreadMinATR=%.10f|SpreadMaxATR=%.10f|SpreadWarmup=%.10f|SpreadSampleSec=%d|MaxSpreadPts=%.10f|MaxSpreadATR=%.10f|MaxDev=%d|MaxDrift=%.10f|Cooldown=%d|",BoolText(InpUseAdaptiveSpread),InpSpreadLearningWindow,InpSpreadMinimumSamples,InpSpreadPercentile,InpSpreadSafetyMultiplier,InpSpreadMinimumATRLimit,InpSpreadMaximumATRLimit,InpSpreadWarmupATRLimit,InpSpreadSampleSeconds,InpMaxSpreadPoints,InpMaxSpreadATRRatio,InpMaxDeviationPoints,InpMaxEntryDriftATRRatio,InpCooldownBars);
   s+=StringFormat("News=%s|Before=%d|After=%d|Warn=%d|Importance=%d|Fail=%d|XAUUSD=%s|TesterBypass=%s|TradingEnabled=%s|EquityGuardScope=%d|",BoolText(InpUseNewsFilter),InpNewsMinutesBefore,InpNewsMinutesAfter,InpNewsWarningMinutes,(int)InpNewsImportance,(int)InpNewsFailMode,BoolText(InpXAUUsesUSDNews),BoolText(InpTesterAllowWithoutCalendar),BoolText(InpTradingEnabled),(int)InpEquityGuardScope);
   s+=StringFormat("CooldownReject=%d|RetestCLV=%.6f|Breaker=%s|BrkPos=%.4f|BrkTot=%.4f|BrkAct=%d|",InpCooldownAfterRejectBars,InpRetestConfirmCLV,BoolText(InpUseFloatingBreaker),InpFloatingLossPositionMoney,InpFloatingLossTotalMoney,(int)InpFloatingBreakerAction);
   return s;
  }

string TEL6TelemetryConfigCanonical()
  {
   return StringFormat("EnableTEL6=%s|Profile=%d|MaxMB=%d|OutcomeBars=%d|MomentMs=%d|IntrabarMs=%d|PostSignalSec=%d|StateHeartbeatSec=%d|FlushCritical=%s|EnableCSV=%s|CommonFolder=%s|Prefix=%s|ProfitSampleSec=%d|ProfitSampleMoney=%.4f",
                       BoolText(InpEnableTEL6),(int)InpTEL6Profile,InpTEL6MaxFileMB,InpTEL6OutcomeBars,
                       InpTEL6MomentIntervalMs,InpTEL6IntrabarIntervalMs,InpTEL6IntrabarPostSignalSeconds,InpTEL6StateHeartbeatSeconds,BoolText(InpTEL6FlushCritical),
                       BoolText(InpEnableCSV),BoolText(InpCSVInCommonFolder),InpCSVPrefix,InpTEL6ProfitSampleSeconds,InpTEL6ProfitSampleMoney);
  }

string TEL6VisualConfigCanonical()
  {
   return StringFormat("Show=%s|Corner=%d|X=%d|Y=%d|AvoidNative=%s|NativeH=%d|Z=%I64d|Scale=%d|LiveScore=%s|LiveMs=%d|Projection=%d",
                       BoolText(InpShowPanel),(int)InpPanelCorner,InpPanelX,InpPanelY,BoolText(InpAvoidNativeOneClickOverlay),
                       InpNativeTopOverlayHeight,InpPanelZOrder,InpPanelScalePercent,BoolText(InpShowLiveScore),InpLiveScoreRefreshMs,InpLiveProjectionSeconds);
  }

void TEL6RefreshHashes()
  {
   g_tel6_strategy_hash=TEL6Hash8(TEL6StrategyConfigCanonical());
   g_tel6_telemetry_hash=TEL6Hash8(TEL6TelemetryConfigCanonical());
   g_tel6_visual_hash=TEL6Hash8(TEL6VisualConfigCanonical());
   g_tel6_config_hash=TEL6Hash8(g_tel6_strategy_hash+"|"+g_tel6_telemetry_hash+"|"+g_tel6_visual_hash);
  }

bool TEL6SubjectEnabled(const string subject)
  {
   if(!InpEnableTEL6) return false;
   if(subject=="OBJECT_STATE" || subject=="OPPORTUNITY_SNAPSHOT" || subject=="OPPORTUNITY_OUTCOME" ||
      subject=="SIGNAL_MARKERS" || subject=="PROFIT_MANAGEMENT")
      return InpTEL6Profile>=TEL6_RESEARCH;
   if(subject=="MOMENT_STATE" || subject=="INTRABAR_TRACE")
      return InpTEL6Profile>=TEL6_FORENSIC;
   return true;
  }

string TEL6IdentityHeader()
  {
   return "SchemaVersion;ProductName;EAVersion;BuildID;ReleaseState;RunID;InstanceID;ConfigHash;StrategyConfigHash;TelemetryConfigHash;VisualConfigHash;SequenceNumber;EventID;TimestampUTC;TimestampUTC_Msc;TimestampServer;TimestampServer_Msc;TickTimeMsc;Broker;Server;AccountMode;Environment;Symbol;ExecutionTF;MagicNumber;CandidateID;OpportunityID;SnapshotID;SetupID;SignalID;DecisionID;IntentID;MarkerID;TradeCycleID;ObjectID;Event;State;PrimaryReason;SecondaryReason";
  }

void TEL6AddIdentity(string &row,const string event_name,const string state_name,const string primary_reason,const string secondary_reason,
                     const string snapshot_id="",const string trade_cycle_id="",const string object_id="")
  {
   MqlTick tick; ZeroMemory(tick); SymbolInfoTick(_Symbol,tick);
   ulong seq=TEL6NextSequence();
   string event_id=StringFormat("EVT_%s_%I64u",TEL6ShortRunID(),seq);
   long tick_msc=(long)tick.time_msc;
   // MT5 expoe milissegundos do tick, nao um relogio de evento UTC/server com
   // precisao sub-segundo. Portanto nao rotular TickTimeMsc como timestamp do
   // evento: UTC/Server ficam em resolucao de segundo (.000) e o tick segue separado.
   long server_msc=(long)TimeTradeServer()*1000;
   long utc_msc=(long)TimeGMT()*1000;
   CSVAddI(row,NMX_TEL6_SCHEMA_VERSION); CSVAdd(row,NMX_EA_NAME); CSVAdd(row,NMX_VERSION); CSVAdd(row,NMX_TEL6_BUILD_ID);
   CSVAdd(row,NMX_TEL6_RELEASE_STATE); CSVAdd(row,g_tel6_run_id); CSVAdd(row,g_tel6_instance_id); CSVAdd(row,g_tel6_config_hash);
   CSVAdd(row,g_tel6_strategy_hash); CSVAdd(row,g_tel6_telemetry_hash); CSVAdd(row,g_tel6_visual_hash); CSVAddU(row,seq); CSVAdd(row,event_id);
   CSVAdd(row,TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS)); CSVAddI(row,utc_msc);
   CSVAdd(row,TimeToString(TimeTradeServer(),TIME_DATE|TIME_SECONDS)); CSVAddI(row,server_msc); CSVAddI(row,tick_msc);
   CSVAdd(row,AccountInfoString(ACCOUNT_COMPANY)); CSVAdd(row,AccountInfoString(ACCOUNT_SERVER)); CSVAdd(row,AccountModeText());
   CSVAdd(row,(bool)MQLInfoInteger(MQL_TESTER) ? "TESTER" : "TERMINAL"); CSVAdd(row,_Symbol); CSVAdd(row,TimeframeShort(g_profile.tf)); CSVAddI(row,g_magic);
   CSVAdd(row,g_tel6_candidate_id); CSVAdd(row,g_tel6_opportunity_id); CSVAdd(row,snapshot_id); CSVAdd(row,g_tel6_setup_id);
   CSVAdd(row,g_tel6_signal_id); CSVAdd(row,g_tel6_decision_id); CSVAdd(row,g_tel6_intent_id); CSVAdd(row,g_tel6_marker_id); CSVAdd(row,trade_cycle_id); CSVAdd(row,object_id);
   CSVAdd(row,event_name); CSVAdd(row,state_name); CSVAdd(row,primary_reason); CSVAdd(row,secondary_reason);
  }

int TEL6OpenFile(const string file_name)
  {
   // TEL6 usa UTF-8 para preservar nomes de noticias/simbolos/textos sem
   // contaminar o legado, que continua com o writer original.
   return FileOpen(file_name,CSVFlags(false),0,CP_UTF8);
  }

string TEL6PartFile(const string subject,const int part,const datetime when=0)
  {
   datetime stamp=(when>0 ? when : TimeTradeServer());
   if(stamp<=0) stamp=TimeLocal();
   string day=TimeToString(stamp,TIME_DATE); StringReplace(day,".","");
   EnsureCSVFolder();
   return StringFormat("%s\\NEXUS_GUARD_PRO_%s_S7_%s_%s_%s_%s_%s_PART%03d.csv",CSVRelativeFolder(),CSVSafeToken(subject),day,
                       CSVSafeToken(_Symbol),CSVSafeToken(TimeframeShort(g_profile.tf)),g_tel6_strategy_hash,TEL6ShortRunID(),part);
  }

string TEL6ResolvePartFile(const string subject,const datetime when=0)
  {
   long max_bytes=(long)MathMax(1,InpTEL6MaxFileMB)*1024*1024;
   for(int part=1;part<=9999;part++)
     {
      string file_name=TEL6PartFile(subject,part,when);
      ResetLastError();
      int h=TEL6OpenFile(file_name);
      if(h==INVALID_HANDLE) return file_name;
      long size=(long)FileSize(h);
      FileClose(h);
      if(size<max_bytes || size==0) return file_name;
     }
   return TEL6PartFile(subject,9999,when);
  }

bool TEL6AppendLine(const string subject,const string header,const string row,const bool critical=false,const datetime when=0)
  {
   if(!TEL6SubjectEnabled(subject)) return true;
   string file_name=TEL6ResolvePartFile(subject,when);
   ResetLastError();
   int h=TEL6OpenFile(file_name);
   if(h==INVALID_HANDLE)
     {
      if(!g_tel6_write_fault)
        {
         g_tel6_write_fault=true;
         PrintFormat("NMX|TEL6_CSV_OPEN_FAILED|subject=%s|file=%s|error=%d",subject,file_name,GetLastError());
        }
      return false;
     }
   bool empty=(FileSize(h)==0); FileSeek(h,0,SEEK_END);
   if(empty) FileWriteString(h,header+"\r\n");
   uint written=FileWriteString(h,row+"\r\n");
   if(critical && InpTEL6FlushCritical) FileFlush(h);
   FileClose(h);
   if(written==0)
     {
      if(!g_tel6_write_fault)
        {
         g_tel6_write_fault=true;
         PrintFormat("NMX|TEL6_CSV_WRITE_FAILED|subject=%s|file=%s|error=%d",subject,file_name,GetLastError());
        }
      return false;
     }
   return true;
  }

bool TEL6EnsureSubjectFile(const string subject,const string header)
  {
   if(!TEL6SubjectEnabled(subject)) return true;
   string file_name=TEL6ResolvePartFile(subject);
   ResetLastError();
   int h=TEL6OpenFile(file_name);
   if(h==INVALID_HANDLE) return false;
   if(FileSize(h)==0) FileWriteString(h,header+"\r\n");
   FileFlush(h); FileClose(h); return true;
  }

string TEL6RunConfigHeader()
  { return TEL6IdentityHeader()+";TelemetryProfile;StrategyCanonical;TelemetryCanonical;VisualCanonical;InputTradingEnabled;RuntimeTradingEnabled;ProfileName;ProfileSetupMode;ProfileEntryMode;AssetClass;Digits;Point;TickSize;TickValue;ContractSize;VolumeMin;VolumeMax;VolumeStep;StopsLevel;FreezeLevel;RiskMode;RiskPercent;FixedLot;HardMaxRiskPercent;RiskCapMode;EquityGuardScope;RiskSafetyState;StopMode;StopMoney;ProtectionMode;TargetMode;TargetMoney;TrailingMode;NewsFilter;PortfolioRiskPermissionContract;PortfolioRiskPermissionState;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6CandleHeader()
  { return TEL6IdentityHeader()+";BarOpenTime;BarCloseTime;Open;High;Low;Close;CandleDirection;Range;Body;UpperWick;LowerWick;BodyPct;UpperWickPct;LowerWickPct;CLV;TickVolume;RealVolume;RelativeVolume;ATR;AverageRange;RangeATR;Overlap;Efficiency;FlowDirection;VWAP;Regime;RegimeER;RegimeMoveATR;MTF_M1;MTF_M5;MTF_M30;MTFAlignment;NearestLevel;BarSpreadPoints;MarketBid;MarketAsk;MarketSpreadPoints;MarketSpreadATR;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6MarketHeader()
  { return TEL6IdentityHeader()+";Regime;RegimeER;RegimeMoveATR;ATR;VWAP;FlowDirection;FlowRangeATR;FlowCLV;FlowRelativeVolume;MTF_M1;MTF_M1_ER;MTF_M5;MTF_M5_ER;MTF_M30;MTF_M30_ER;MTFAlignment;NearestLevel;NewsStatus;NextNewsName;NextNewsTime;SpreadPoints;SpreadATR;SpreadLimitATR;SpreadLearning;CandidateValid;Setup;Direction;Score;MinimumScore;BlockingGate;RuntimeTradingEnabled;EntriesPaused;ConfigBlocked;DailyRiskBlocked;CurrentOpenBarUsed;FutureDataUsed;StateHash"; }

string TEL6ObjectHeader()
  { return TEL6IdentityHeader()+";ObjectType;Side;Price;Quality;Age;Tests;Confluences;SourceTime;ObjectEvent;TouchedByClosedBar;SweptByClosedBar;DistanceATR;StateHash;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6MomentHeader()
  { return TEL6IdentityHeader()+";Bid;Ask;Mid;SpreadPoints;SpreadATR;LiveOpen;LiveHigh;LiveLow;LiveClose;LiveRange;LiveBodyRatio;LiveUpperWick;LiveLowerWick;LiveCLV;LiveRangeATR;LiveOverlap;LiveRelativeVolume;LiveEfficiency;LiveDirection;DistanceCandidateLevelATR;CandidateScoreLive;PositionOpen;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6DecisionHeader()
  { return TEL6IdentityHeader()+";Stage;Setup;Direction;Score;MinimumScore;ScoreGate;LevelGate;ContextGate;EventGate;StructureGate;RetestGate;MTFGate;NativeNewsGate;SpreadGate;EntryDriftGate;VolumeGate;RiskGate;TargetGate;MarginGate;PositionGate;CurrencyExposureGate;DailyLimitGate;ConfigGate;RuntimeTradingGate;EntryPauseGate;ConnectionGate;MarketOpenGate;SymbolTradeModeGate;StopBrokerGate;TradingPermissionGate;ExecutionGate;LevelQuality;MinimumLevelQuality;CandidateAgeBars;ObservedSpreadATR;SpreadLimitATR;EntryDriftATR;MaxEntryDriftATR;CalculatedVolume;ExecutableVolume;VolumeMin;VolumeMax;VolumeStep;EffectiveRiskMoney;EffectiveRiskPercent;HardMaxRiskPercent;TargetPrice;ExpectedR;MinimumExpectedR;OppositeLiquidity;MarginLevel;OpenPositions;MaxOpenPositions;DailyNet;TradesToday;MaxTradesPerDay;ConsecutiveLosses;MaxConsecutiveLosses;NewsStatus;TerminalConnected;TerminalTradeAllowed;MQLTradeAllowed;AccountTradeAllowed;AccountExpertAllowed;NextState;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6OpportunityHeader()
  { return TEL6IdentityHeader()+";Decision;Setup;Direction;SignalAnchor;HypotheticalEntry;Bid;Ask;SpreadPoints;SpreadATR;LevelType;LevelSide;LevelPrice;LevelQuality;LevelAge;LevelTests;LevelConfluences;ATR;VWAP;Regime;RegimeER;RegimeMoveATR;MTFAlignment;FlowRange;FlowBodyRatio;FlowUpperWick;FlowLowerWick;FlowCLV;FlowRangeATR;FlowOverlap;FlowRelativeVolume;FlowEfficiency;Score;MinimumScore;TechnicalStop;RequestedStopMoney;OppositeLiquidity;AvailableTarget;TargetMode;TargetMoneyMilestone;CalculatedVolume;ExecutableVolume;EffectiveRiskMoney;EffectiveRiskPercent;NewsStatus;BlockingGate;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6OutcomeHeader()
  { return TEL6IdentityHeader()+";Decision;Direction;Entry;Stop;Target;OppositeLiquidity;TargetMoneyMilestone;Volume;RiskDistance;BarsObserved;MFEDistancePrice;MAEDistancePrice;MFEPoints;MAEPoints;MFEMoney;MAEMoney;TimeToMFESec;TimeToMAESec;Hit05R;Hit10R;Hit15R;Hit20R;HitTarget;HitTargetMoney;HitStop;HitOppositeLiquidity;Hit05RTime;Hit10RTime;Hit15RTime;Hit20RTime;TargetTime;TargetMoneyTime;StopTime;OppositeLiquidityTime;Ordering;OutcomeComplete;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6MarkerHeader()
  { return TEL6IdentityHeader()+";MarkerClass;ChartObjectCreated;Direction;Price;LevelType;LevelPrice;FlowDirection;Score;MinimumScore;Stop;Target;SpreadATR;ExecutionState;FinalResult;CurrentOpenBarUsed;FutureDataUsed"; }

string TEL6RiskHeader()
  { return TEL6IdentityHeader()+";Trigger;Balance;Equity;FreeMargin;MarginLevel;RiskMode;RiskPercent;FixedLot;RiskCapMode;EquityGuardScope;RiskSafetyState;HardMaxRiskPercent;StopMode;StopMoney;PlannedRiskMoney;EffectiveRiskMoney;EffectiveRiskPercent;OpenPositions;MaxOpenPositions;CurrencyExposureLimit;DailyNet;DailyRealizedProfit;DailyRealizedLoss;DailyLossPercent;MaxDailyLossPercent;DrawdownPercent;MaxDrawdownPercent;TradesToday;MaxTradesPerDay;ConsecutiveLosses;MaxConsecutiveLosses;VolumeMin;VolumeMax;VolumeStep;StopsLevel;FreezeLevel;PortfolioRiskPermissionContract;PortfolioRiskPermissionState;Blocked;BlockReason;StateHash"; }

string TEL6ProfitHeader()
  { return TEL6IdentityHeader()+";Action;PositionTicket;PositionIdentifier;PositionType;Volume;OpenPrice;CurrentSL;CurrentTP;RequestedNewSL;RequestedNewTP;CurrentNetPnL;PeakProfitMoney;TroughProfitMoney;TargetMode;TargetMoneyMilestone;TrailingEnabled;TrailingMode;TrailingActive;TrailingActivationMoney;TrailDistanceMoney;PersistedLockMoney;ProtectedProfitMoney;TrailFloorMoney;TimeStopEnabled;Reason;TradeRetcode"; }

string TEL6ExecutionHeader()
  { return TEL6IdentityHeader()+";Stage;Action;Direction;RequestedVolume;RequestedPrice;RequestedSL;RequestedTP;OrderCheckExecuted;OrderCheckBool;OrderCheckRetcode;OrderCheckComment;ProjectedMargin;ProjectedMarginFree;ProjectedMarginLevel;OrderSendCalled;OrderSendBool;TradeRetcode;TradeComment;OrderTicket;DealTicket;ExecutionPrice;FinalState"; }

string TEL6TradeHeader()
  { return TEL6IdentityHeader()+";LifecycleEvent;PositionIdentifier;PositionTicket;OrderTicket;DealTicket;DealEntry;DealType;DealReason;Volume;Price;Profit;Commission;Swap;Fee;DealNet;PositionFinalNet;PositionResult;OpenPrice;CurrentSL;CurrentTP;OriginTF;DurationSeconds"; }

string TEL6DiagnosticHeader()
  { return TEL6IdentityHeader()+";Severity;Component;Message;TerminalConnected;TerminalTradeAllowed;MQLTradeAllowed;AccountTradeAllowed;AccountExpertAllowed;MarketOpen;DataBarsLoaded;ATRValid;ConfigBlocked;TelemetryWriteFault"; }

string TEL6IntrabarHeader()
  { return TEL6IdentityHeader()+";Bid;Ask;Last;SpreadPoints;SpreadATR;TickFlags;TickVolume;TickVolumeReal;OpenBarTime;OpenBarOpen;OpenBarHigh;OpenBarLow;OpenBarClose;SetupState;ArmedUntil;CurrentOpenBarUsed;FutureDataUsed"; }

void TEL6EnsureFiles()
  {
   bool ok=true;
   if(!TEL6EnsureSubjectFile("RUN_CONFIG",TEL6RunConfigHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("CANDLE_SNAPSHOT",TEL6CandleHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("MARKET_STATE",TEL6MarketHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("OBJECT_STATE",TEL6ObjectHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("MOMENT_STATE",TEL6MomentHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("SIGNAL_DECISIONS",TEL6DecisionHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("OPPORTUNITY_SNAPSHOT",TEL6OpportunityHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("OPPORTUNITY_OUTCOME",TEL6OutcomeHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("SIGNAL_MARKERS",TEL6MarkerHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("RISK_STATE",TEL6RiskHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("PROFIT_MANAGEMENT",TEL6ProfitHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("EXECUTION",TEL6ExecutionHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("TRADE_LIFECYCLE",TEL6TradeHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("DIAGNOSTIC",TEL6DiagnosticHeader())) ok=false;
   if(!TEL6EnsureSubjectFile("INTRABAR_TRACE",TEL6IntrabarHeader())) ok=false;
   if(!ok)
     {
      g_tel6_write_fault=true;
      PrintFormat("NMX|TEL6_INIT_FILE_ERROR|run=%s|schema=%d|last_error=%d",g_tel6_run_id,NMX_TEL6_SCHEMA_VERSION,GetLastError());
     }
  }

void TEL6EnsureCandidateIdentity()
  {
   if(!g_candidate.valid) return;
   if(g_tel6_candidate_id!="") return;
   string sig=StringFormat("%I64d|%d|%d|%d|%.10f|%.10f",(long)g_candidate.event_time,(int)g_candidate.setup,
                           (int)g_candidate.direction,(int)g_candidate.level.type,g_candidate.level.price,g_candidate.signal_anchor);
   g_tel6_candidate_id=StringFormat("CND_%s_%s",TEL6ShortRunID(),TEL6Hash8(sig));
   g_tel6_setup_id=StringFormat("SET_%s_%s",TEL6ShortRunID(),TEL6Hash8(sig+"|SETUP"));
   TEL6ArmIntrabar(InpTEL6IntrabarPostSignalSeconds);
  }

void TEL6EnsureSignalIdentity()
  {
   TEL6EnsureCandidateIdentity();
   if(g_tel6_signal_id=="") g_tel6_signal_id=TEL6NewID("SIG");
   if(g_tel6_opportunity_id=="") g_tel6_opportunity_id=TEL6NewID("OPP");
  }

void TEL6ResetCandidateIdentity()
  {
   g_tel6_candidate_id=""; g_tel6_setup_id=""; g_tel6_signal_id=""; g_tel6_opportunity_id="";
   g_tel6_decision_id=""; g_tel6_intent_id=""; g_tel6_marker_id=""; g_tel6_opportunity_snapshot_written=false;
  }

void TEL6ArmIntrabar(const int seconds)
  {
   if(InpTEL6Profile<TEL6_FORENSIC) return;
   datetime until=TimeTradeServer()+MathMax(1,seconds);
   if(until>g_tel6_intrabar_armed_until) g_tel6_intrabar_armed_until=until;
  }

string TEL6Gate(const bool applicable,const bool pass)
  {
   if(!applicable) return "N/A";
   return pass ? "PASS" : "FAIL";
  }

string TEL6NewsGate()
  {
   if(!InpUseNewsFilter || g_news_status=="DISABLED" || g_news_status=="CLEAR" || g_news_status=="TESTER_CALENDAR_BYPASS") return "PASS";
   if(g_news_status=="CALENDAR_UNAVAILABLE" && InpNewsFailMode==NEWS_FAIL_OPEN) return "PASS";
   if(g_news_status=="PRE-BLACKOUT" || g_news_status=="POST-EVENT" || g_news_status=="CALENDAR_UNAVAILABLE") return "FAIL";
   return "UNKNOWN";
  }


bool TEL6TradePermissionOK()
  {
   return TerminalInfoInteger(TERMINAL_CONNECTED) && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) &&
          MQLInfoInteger(MQL_TRADE_ALLOWED) && AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) && AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  }

string TEL6TradeCycleID(const ulong position_identifier)
  {
   if(position_identifier==0) return "";
   return StringFormat("TRD_%s_%I64u",TEL6ShortRunID(),position_identifier);
  }

void TEL6RememberPendingTradeLink()
  {
   g_tel6_pending_candidate_id=g_tel6_candidate_id;
   g_tel6_pending_opportunity_id=g_tel6_opportunity_id;
   g_tel6_pending_setup_id=g_tel6_setup_id;
   g_tel6_pending_signal_id=g_tel6_signal_id;
   g_tel6_pending_intent_id=g_tel6_intent_id;
  }

void TEL6ClearPendingTradeLink()
  {
   g_tel6_pending_candidate_id="";
   g_tel6_pending_opportunity_id="";
   g_tel6_pending_setup_id="";
   g_tel6_pending_signal_id="";
   g_tel6_pending_intent_id="";
  }

int TEL6FindTradeLink(const ulong position_id)
  {
   for(int i=0;i<ArraySize(g_tel6_trade_links);i++) if(g_tel6_trade_links[i].position_id==position_id) return i;
   return -1;
  }

void TEL6BindTradeLink(const ulong position_id)
  {
   if(position_id==0 || TEL6FindTradeLink(position_id)>=0) return;
   if(g_tel6_pending_signal_id=="" && g_tel6_signal_id=="") return;
   int n=ArraySize(g_tel6_trade_links); ArrayResize(g_tel6_trade_links,n+1);
   TEL6TradeLink link; ZeroMemory(link); link.position_id=position_id;
   link.candidate_id=(g_tel6_pending_candidate_id!=""?g_tel6_pending_candidate_id:g_tel6_candidate_id);
   link.opportunity_id=(g_tel6_pending_opportunity_id!=""?g_tel6_pending_opportunity_id:g_tel6_opportunity_id);
   link.setup_id=(g_tel6_pending_setup_id!=""?g_tel6_pending_setup_id:g_tel6_setup_id);
   link.signal_id=(g_tel6_pending_signal_id!=""?g_tel6_pending_signal_id:g_tel6_signal_id);
   link.intent_id=(g_tel6_pending_intent_id!=""?g_tel6_pending_intent_id:g_tel6_intent_id);
   g_tel6_trade_links[n]=link;
   g_tel6_pending_candidate_id=""; g_tel6_pending_opportunity_id=""; g_tel6_pending_setup_id=""; g_tel6_pending_signal_id=""; g_tel6_pending_intent_id="";
  }

void TEL6ApplyTradeLink(const ulong position_id,string &save_candidate,string &save_opportunity,string &save_setup,string &save_signal,string &save_intent)
  {
   save_candidate=g_tel6_candidate_id; save_opportunity=g_tel6_opportunity_id; save_setup=g_tel6_setup_id; save_signal=g_tel6_signal_id; save_intent=g_tel6_intent_id;
   int idx=TEL6FindTradeLink(position_id); if(idx<0) return;
   g_tel6_candidate_id=g_tel6_trade_links[idx].candidate_id; g_tel6_opportunity_id=g_tel6_trade_links[idx].opportunity_id;
   g_tel6_setup_id=g_tel6_trade_links[idx].setup_id; g_tel6_signal_id=g_tel6_trade_links[idx].signal_id; g_tel6_intent_id=g_tel6_trade_links[idx].intent_id;
  }

void TEL6RestoreTradeLink(const string save_candidate,const string save_opportunity,const string save_setup,const string save_signal,const string save_intent)
  {
   g_tel6_candidate_id=save_candidate; g_tel6_opportunity_id=save_opportunity; g_tel6_setup_id=save_setup; g_tel6_signal_id=save_signal; g_tel6_intent_id=save_intent;
  }

void TEL6DropTradeLink(const ulong position_id)
  {
   int idx=TEL6FindTradeLink(position_id);
   if(idx<0) return;
   for(int i=idx;i<ArraySize(g_tel6_trade_links)-1;i++) g_tel6_trade_links[i]=g_tel6_trade_links[i+1];
   ArrayResize(g_tel6_trade_links,ArraySize(g_tel6_trade_links)-1);
  }

int TEL6FindPositionState(const ulong position_id)
  {
   for(int i=0;i<ArraySize(g_tel6_position_states);i++) if(g_tel6_position_states[i].position_id==position_id) return i;
   return -1;
  }

bool TEL6PositionStateChanged(const ulong position_id,const string state_hash,const bool force=false)
  {
   int idx=TEL6FindPositionState(position_id);
   if(idx<0)
     {
      int n=ArraySize(g_tel6_position_states); ArrayResize(g_tel6_position_states,n+1);
      g_tel6_position_states[n].position_id=position_id; g_tel6_position_states[n].state_hash=state_hash;
      g_tel6_position_states[n].last_ms=0; g_tel6_position_states[n].last_pnl=0.0;
      return true;
     }
   if(force || g_tel6_position_states[idx].state_hash!=state_hash)
     {
      g_tel6_position_states[idx].state_hash=state_hash;
      return true;
     }
   return false;
  }

void TEL6DropPositionState(const ulong position_id)
  {
   int idx=TEL6FindPositionState(position_id);
   if(idx<0) return;
   for(int i=idx;i<ArraySize(g_tel6_position_states)-1;i++) g_tel6_position_states[i]=g_tel6_position_states[i+1];
   ArrayResize(g_tel6_position_states,ArraySize(g_tel6_position_states)-1);
  }

void TEL6WriteRunConfig()
  {
   if(!TEL6SubjectEnabled("RUN_CONFIG")) return;
   string row=""; string snap=TEL6NewID("SNP");
   TEL6AddIdentity(row,"RUN_CONFIG","INITIALIZED","CONFIG_SNAPSHOT","",snap,"","");
   CSVAdd(row,TEL6ProfileText());
   CSVAdd(row,TEL6StrategyConfigCanonical()); CSVAdd(row,TEL6TelemetryConfigCanonical()); CSVAdd(row,TEL6VisualConfigCanonical());
   CSVAdd(row,BoolText(InpTradingEnabled)); CSVAdd(row,BoolText(g_runtime_trading_enabled)); CSVAdd(row,g_profile.name);
   CSVAdd(row,EnumToString(g_profile.setup_mode)); CSVAdd(row,EnumToString(g_profile.entry_mode)); CSVAdd(row,g_symbol.asset_class);
   CSVAddI(row,g_symbol.digits); CSVAddD(row,g_symbol.point,10); CSVAddD(row,g_symbol.tick_size,10); CSVAddD(row,g_symbol.tick_value,10);
   CSVAddD(row,g_symbol.contract_size,4); CSVAddD(row,g_symbol.volume_min,4); CSVAddD(row,g_symbol.volume_max,4); CSVAddD(row,g_symbol.volume_step,4);
   CSVAddI(row,g_symbol.stops_level); CSVAddI(row,g_symbol.freeze_level); CSVAdd(row,EnumToString(InpRiskMode)); CSVAddD(row,InpRiskPercent,8);
   CSVAddD(row,InpFixedLot,4); CSVAddD(row,InpHardMaxRiskPercent,8); CSVAdd(row,RiskCapModeText()); CSVAdd(row,EnumToString(InpEquityGuardScope)); CSVAdd(row,RiskSafetyStateText()); CSVAdd(row,EnumToString(InpStopMode));
   CSVAddD(row,InpStopMoney,2); CSVAdd(row,ProtectionModeText()); CSVAdd(row,EnumToString(InpTargetMode)); CSVAddD(row,InpTargetMoney,2);
   CSVAdd(row,EnumToString(InpTrailingMode)); CSVAdd(row,BoolText(InpUseNewsFilter)); 
   
   CSVAdd(row,NGP_PORTFOLIO_RISK_CONTRACT); CSVAdd(row,NGP_PORTFOLIO_RISK_STATE); CSVAdd(row,"false"); CSVAdd(row,"false");
   TEL6AppendLine("RUN_CONFIG",TEL6RunConfigHeader(),row,true);
  }

void TEL6WriteCandleSnapshot()
  {
   if(!TEL6SubjectEnabled("CANDLE_SNAPSHOT") || ArraySize(g_rates)<3 || g_rates[1].time<=0) return;
   static datetime last_bar=0;
   if(last_bar>=g_rates[1].time) return;
   last_bar=g_rates[1].time;
   MqlRates b=g_rates[1];
   double range=b.high-b.low; double body=MathAbs(b.close-b.open);
   double upper=b.high-MathMax(b.open,b.close); double lower=MathMin(b.open,b.close)-b.low;
   FlowSnapshot f; ZeroMemory(f); CalculateFlow(1,f);
   double avg_range=0.0; int count=0;
   int max_i=MathMin(ArraySize(g_rates)-1,21);
   for(int i=2;i<=max_i;i++) { avg_range+=g_rates[i].high-g_rates[i].low; count++; }
   if(count>0) avg_range/=count;
   MqlTick tick; ZeroMemory(tick); SymbolInfoTick(_Symbol,tick);
   double market_spread=(Positive(g_symbol.point) ? (tick.ask-tick.bid)/g_symbol.point : 0.0);
   string row=""; string snap=TEL6NewID("SNP");
   TEL6AddIdentity(row,"CANDLE_CLOSED",StateText(g_state),g_reason,g_blocking_gate,snap,"","");
   CSVAdd(row,TimeToString(b.time,TIME_DATE|TIME_SECONDS)); CSVAdd(row,TimeToString(b.time+PeriodSeconds(g_profile.tf),TIME_DATE|TIME_SECONDS));
   CSVAddD(row,b.open,g_symbol.digits); CSVAddD(row,b.high,g_symbol.digits); CSVAddD(row,b.low,g_symbol.digits); CSVAddD(row,b.close,g_symbol.digits);
   CSVAdd(row,b.close>b.open ? "BULL" : (b.close<b.open ? "BEAR" : "DOJI")); CSVAddD(row,range,10); CSVAddD(row,body,10);
   CSVAddD(row,upper,10); CSVAddD(row,lower,10); CSVAddD(row,Positive(range)?body/range:0.0,10); CSVAddD(row,Positive(range)?upper/range:0.0,10);
   CSVAddD(row,Positive(range)?lower/range:0.0,10); CSVAddD(row,f.clv,10); CSVAddU(row,(ulong)b.tick_volume); CSVAddU(row,(ulong)b.real_volume);
   CSVAddD(row,f.relative_volume,10); CSVAddD(row,g_atr,10); CSVAddD(row,avg_range,10); CSVAddD(row,f.range_atr,10); CSVAddD(row,f.overlap,10);
   CSVAddD(row,f.efficiency,10); CSVAddI(row,f.direction); CSVAddD(row,g_vwap,g_symbol.digits); CSVAdd(row,RegimeText(g_regime));
   CSVAddD(row,g_regime_efficiency,10); CSVAddD(row,g_regime_move_atr,10); CSVAdd(row,BiasText(0)); CSVAdd(row,BiasText(1)); CSVAdd(row,BiasText(2));
   CSVAdd(row,MTFAlignmentText()); CSVAdd(row,NearestLevelText()); CSVAddI(row,(long)b.spread); CSVAddD(row,tick.bid,g_symbol.digits); CSVAddD(row,tick.ask,g_symbol.digits);
   CSVAddD(row,market_spread,4); CSVAddD(row,Positive(g_atr)?(tick.ask-tick.bid)/g_atr:0.0,10); CSVAdd(row,"false"); CSVAdd(row,"false");
   TEL6AppendLine("CANDLE_SNAPSHOT",TEL6CandleHeader(),row,false,b.time);
  }

string TEL6MarketStateHash()
  {
   return TEL6Hash8(StringFormat("%d|%.8f|%.8f|%.8f|%.8f|%s|%s|%s|%s|%.8f|%.8f|%d|%d|%.4f|%s|%s|%s",
                                 (int)g_regime,g_regime_efficiency,g_regime_move_atr,g_atr,g_vwap,BiasText(0),BiasText(1),BiasText(2),
                                 g_news_status,g_last_spread_points,g_last_spread_atr,(int)g_state,(int)g_candidate.valid,g_candidate.score,
                                 g_reason,
                                 g_blocking_gate,NearestLevelText()));
  }

void TEL6WriteMarketState(const string trigger,const bool force=false)
  {
   if(!TEL6SubjectEnabled("MARKET_STATE")) return;
   if(!force && trigger=="TIMER")
     {
      ulong now_ms=GetTickCount64();
      ulong min_gap=(ulong)MathMax(1,InpTEL6StateHeartbeatSeconds)*1000;
      if(g_tel6_last_market_heartbeat_ms>0 && now_ms-g_tel6_last_market_heartbeat_ms<min_gap) return;
      g_tel6_last_market_heartbeat_ms=now_ms;
     }
   string hash=TEL6MarketStateHash();
   if(!force && hash==g_tel6_last_market_hash) return;
   g_tel6_last_market_hash=hash;
   FlowSnapshot f; ZeroMemory(f); CalculateFlow(1,f);
   string row="";
   TEL6AddIdentity(row,"MARKET_STATE",StateText(g_state),trigger,g_reason,"","","");
   CSVAdd(row,RegimeText(g_regime)); CSVAddD(row,g_regime_efficiency,10); CSVAddD(row,g_regime_move_atr,10); CSVAddD(row,g_atr,10);
   CSVAddD(row,g_vwap,g_symbol.digits); CSVAddI(row,f.direction); CSVAddD(row,f.range_atr,10); CSVAddD(row,f.clv,10); CSVAddD(row,f.relative_volume,10);
   CSVAdd(row,BiasText(0)); CSVAddD(row,g_mtf[0].efficiency,10); CSVAdd(row,BiasText(1)); CSVAddD(row,g_mtf[1].efficiency,10);
   CSVAdd(row,BiasText(2)); CSVAddD(row,g_mtf[2].efficiency,10); CSVAdd(row,MTFAlignmentText()); CSVAdd(row,NearestLevelText());
   CSVAdd(row,g_news_status); CSVAdd(row,g_next_news_name); CSVAdd(row,g_next_news_time>0?TimeToString(g_next_news_time,TIME_DATE|TIME_SECONDS):"");
   
   
   CSVAddD(row,g_last_spread_points,4); CSVAddD(row,g_last_spread_atr,10); CSVAddD(row,g_effective_spread_atr_limit,10); CSVAdd(row,SpreadLearningText());
   CSVAdd(row,BoolText(g_candidate.valid)); CSVAdd(row,g_candidate.valid?SetupText(g_candidate.setup):"NONE");
   CSVAdd(row,g_candidate.valid?DirectionText(g_candidate.direction):"NONE"); CSVAddD(row,g_candidate.valid?g_candidate.score:0.0,4); CSVAddD(row,g_profile.minimum_score,4);
   CSVAdd(row,g_blocking_gate); CSVAdd(row,BoolText(g_runtime_trading_enabled)); CSVAdd(row,BoolText(g_entries_paused)); CSVAdd(row,BoolText(g_config_blocked));
   CSVAdd(row,BoolText(g_stats.blocked)); CSVAdd(row,"false"); CSVAdd(row,"false"); CSVAdd(row,hash);
   TEL6AppendLine("MARKET_STATE",TEL6MarketHeader(),row,false);
  }

int TEL6FindObjectCache(const string object_id)
  {
   for(int i=0;i<ArraySize(g_tel6_objects);i++) if(g_tel6_objects[i].object_id==object_id) return i;
   return -1;
  }

string TEL6LevelObjectID(const MarketLevel &level)
  {
   string sig=StringFormat("%d|%d|%I64d|%.10f",(int)level.type,level.side,(long)level.source_time,level.price);
   return StringFormat("OBJ_%s_%s",TEL6ShortRunID(),TEL6Hash8(sig));
  }

string TEL6LevelStateHash(const MarketLevel &level)
  {
   return TEL6Hash8(StringFormat("%d|%d|%.10f|%.6f|%d|%d|%d|%I64d",(int)level.type,level.side,level.price,level.quality,
                                 level.age,level.tests,level.confluences,(long)level.source_time));
  }

void TEL6WriteObjectStateRow(const MarketLevel &level,const string object_id,const string object_event,const string state_hash)
  {
   if(!TEL6SubjectEnabled("OBJECT_STATE")) return;
   bool touched=false,swept=false;
   if(ArraySize(g_rates)>1)
     {
      touched=(g_rates[1].low<=level.price && g_rates[1].high>=level.price);
      swept=(level.side>0 ? g_rates[1].high>level.price && g_rates[1].close<level.price :
                            g_rates[1].low<level.price && g_rates[1].close>level.price);
     }
   double distance_atr=(Positive(g_atr) && ArraySize(g_rates)>1 ? MathAbs(g_rates[1].close-level.price)/g_atr : 0.0);
   string row="";
   TEL6AddIdentity(row,"OBJECT_STATE",object_event,LevelText(level.type),"", "","",object_id);
   CSVAdd(row,LevelText(level.type)); CSVAddI(row,level.side); CSVAddD(row,level.price,g_symbol.digits); CSVAddD(row,level.quality,4);
   CSVAddI(row,level.age); CSVAddI(row,level.tests); CSVAddI(row,level.confluences); CSVAdd(row,TimeToString(level.source_time,TIME_DATE|TIME_SECONDS));
   CSVAdd(row,object_event); CSVAdd(row,BoolText(touched)); CSVAdd(row,BoolText(swept)); CSVAddD(row,distance_atr,10); CSVAdd(row,state_hash);
   CSVAdd(row,"false"); CSVAdd(row,"false");
   TEL6AppendLine("OBJECT_STATE",TEL6ObjectHeader(),row,false);
  }

void TEL6SyncObjectStates()
  {
   if(!TEL6SubjectEnabled("OBJECT_STATE")) return;
   for(int i=0;i<ArraySize(g_tel6_objects);i++) g_tel6_objects[i].seen=false;
   for(int i=0;i<ArraySize(g_levels);i++)
     {
      if(!g_levels[i].valid) continue;
      string object_id=TEL6LevelObjectID(g_levels[i]); string hash=TEL6LevelStateHash(g_levels[i]);
      int idx=TEL6FindObjectCache(object_id);
      if(idx<0)
        {
         int n=ArraySize(g_tel6_objects); ArrayResize(g_tel6_objects,n+1);
         g_tel6_objects[n].object_id=object_id; g_tel6_objects[n].state_hash=hash; g_tel6_objects[n].seen=true;
         TEL6WriteObjectStateRow(g_levels[i],object_id,"CREATED",hash);
        }
      else
        {
         g_tel6_objects[idx].seen=true;
         if(g_tel6_objects[idx].state_hash!=hash)
           {
            g_tel6_objects[idx].state_hash=hash;
            TEL6WriteObjectStateRow(g_levels[i],object_id,"UPDATED",hash);
           }
        }

      // Eventos efemeros do candle fechado nao pertencem ao hash estrutural do
      // objeto. Registrar separadamente preserva a semantica EVENT-DRIVEN:
      // um nivel pode continuar ACTIVE e, ainda assim, ter sido TOUCHED/SWEPT.
      if(ArraySize(g_rates)>1)
        {
         bool touched=(g_rates[1].low<=g_levels[i].price && g_rates[1].high>=g_levels[i].price);
         bool swept=(g_levels[i].side>0 ?
                     (g_rates[1].high>g_levels[i].price && g_rates[1].close<g_levels[i].price) :
                     (g_rates[1].low<g_levels[i].price && g_rates[1].close>g_levels[i].price));
         if(swept)
            TEL6WriteObjectStateRow(g_levels[i],object_id,"SWEPT",hash);
         else if(touched)
            TEL6WriteObjectStateRow(g_levels[i],object_id,"TOUCHED",hash);
        }
     }
   for(int i=ArraySize(g_tel6_objects)-1;i>=0;i--)
     {
      if(g_tel6_objects[i].seen) continue;
      MarketLevel empty; ZeroMemory(empty); empty.valid=false;
      string row="";
      TEL6AddIdentity(row,"OBJECT_STATE","EXPIRED","LEVEL_REMOVED_FROM_ACTIVE_MAP","","","",g_tel6_objects[i].object_id);
      CSVAdd(row,"UNKNOWN"); CSVAddI(row,0); CSVAddD(row,0.0,g_symbol.digits); CSVAddD(row,0.0,4); CSVAddI(row,0); CSVAddI(row,0); CSVAddI(row,0);
      CSVAdd(row,""); CSVAdd(row,"EXPIRED"); CSVAdd(row,"false"); CSVAdd(row,"false"); CSVAddD(row,0.0,10); CSVAdd(row,g_tel6_objects[i].state_hash);
      CSVAdd(row,"false"); CSVAdd(row,"false");
      TEL6AppendLine("OBJECT_STATE",TEL6ObjectHeader(),row,false);
      for(int j=i;j<ArraySize(g_tel6_objects)-1;j++) g_tel6_objects[j]=g_tel6_objects[j+1];
      ArrayResize(g_tel6_objects,ArraySize(g_tel6_objects)-1);
     }
  }

void TEL6WriteMomentState()
  {
   if(!TEL6SubjectEnabled("MOMENT_STATE")) return;
   ulong now_ms=GetTickCount64();
   if(g_tel6_last_moment_ms>0 && now_ms-g_tel6_last_moment_ms<(ulong)MathMax(100,InpTEL6MomentIntervalMs)) return;
   if(!g_candidate.valid && !HasOwnPositionForSymbol(_Symbol) && TimeTradeServer()>g_tel6_intrabar_armed_until) return;
   g_tel6_last_moment_ms=now_ms;
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick)) return;
   FlowSnapshot f; MqlRates live; ZeroMemory(f); ZeroMemory(live); CalculateLiveFlow(f,live);
   double distance=0.0;
   if(g_candidate.valid && Positive(g_candidate.atr)) distance=MathAbs(((tick.bid+tick.ask)*0.5)-g_candidate.level.price)/g_candidate.atr;
   string row="";
   TEL6AddIdentity(row,"MOMENT_STATE",StateText(g_state),g_reason,g_blocking_gate,"","","");
   CSVAddD(row,tick.bid,g_symbol.digits); CSVAddD(row,tick.ask,g_symbol.digits); CSVAddD(row,(tick.bid+tick.ask)*0.5,g_symbol.digits);
   CSVAddD(row,Positive(g_symbol.point)?(tick.ask-tick.bid)/g_symbol.point:0.0,4); CSVAddD(row,Positive(g_atr)?(tick.ask-tick.bid)/g_atr:0.0,10);
   CSVAddD(row,live.open,g_symbol.digits); CSVAddD(row,live.high,g_symbol.digits); CSVAddD(row,live.low,g_symbol.digits); CSVAddD(row,live.close,g_symbol.digits);
   CSVAddD(row,f.range,10); CSVAddD(row,f.body_ratio,10); CSVAddD(row,f.upper_wick,10); CSVAddD(row,f.lower_wick,10); CSVAddD(row,f.clv,10);
   CSVAddD(row,f.range_atr,10); CSVAddD(row,f.overlap,10); CSVAddD(row,f.relative_volume,10); CSVAddD(row,f.efficiency,10); CSVAddI(row,f.direction);
   CSVAddD(row,distance,10); CSVAddD(row,g_live_score,4); CSVAdd(row,BoolText(HasOwnPositionForSymbol(_Symbol))); CSVAdd(row,"true"); CSVAdd(row,"false");
   TEL6AppendLine("MOMENT_STATE",TEL6MomentHeader(),row,false);
  }

void TEL6WriteSignalDecision(const string stage,const string primary_reason,const TradeIntent &intent,const bool have_intent,const string execution_gate="N/A")
  {
   if(!TEL6SubjectEnabled("SIGNAL_DECISIONS")) return;
   if(g_candidate.valid) TEL6EnsureCandidateIdentity();
   if(stage=="SIGNAL_READY" || stage=="INTENT" || StringFind(stage,"PREFLIGHT")>=0 || StringFind(stage,"ORDER")>=0) TEL6EnsureSignalIdentity();
   g_tel6_decision_id=TEL6NewID("DEC");

   bool have_candidate=g_candidate.valid;
   ENUM_NMX_DIRECTION direction=(have_candidate ? g_candidate.direction : (intent.direction!=DIR_NONE ? intent.direction : DIR_NONE));
   bool context_ok=(g_regime!=REGIME_INSUFFICIENT_DATA && g_regime!=REGIME_EVENT_SHOCK);
   bool mtf_ok=(!InpRequireFullMTFAlignment || (direction!=DIR_NONE && FullMTFAligned(direction)));
   bool spread_ok=(g_last_spread_atr<=g_effective_spread_atr_limit+1e-12 || !Positive(g_effective_spread_atr_limit));
   double margin_level=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   bool margin_ok=(margin_level<=0.0 || margin_level>=InpMinimumMarginLevel);
   int open_positions=CountOwnPositions();
   bool position_ok=(open_positions<InpMaxOpenPositions && !HasOwnPositionForSymbol(_Symbol));
   bool daily_ok=!g_stats.blocked;
   bool connected=(bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   bool terminal_trade=(bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
   bool mql_trade=(bool)MQLInfoInteger(MQL_TRADE_ALLOWED);
   bool account_trade=(bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   bool account_expert=(bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
   bool trade_permission_ok=(connected && terminal_trade && mql_trade && account_trade && account_expert);
   bool market_open=MarketOpen();

   string exposure_reason="";
   bool exposure_ok=CurrencyExposureAllowed(exposure_reason);

   string stop_reason="";
   bool stop_broker_ok=(!have_intent || StopsRespectBroker(intent,stop_reason));

   ENUM_SYMBOL_TRADE_MODE symbol_mode=(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   bool symbol_mode_ok=(symbol_mode!=SYMBOL_TRADE_MODE_DISABLED && symbol_mode!=SYMBOL_TRADE_MODE_CLOSEONLY);
   if(symbol_mode_ok && direction==DIR_BUY && symbol_mode==SYMBOL_TRADE_MODE_SHORTONLY) symbol_mode_ok=false;
   if(symbol_mode_ok && direction==DIR_SELL && symbol_mode==SYMBOL_TRADE_MODE_LONGONLY) symbol_mode_ok=false;

   string score_gate=(have_candidate ? (g_candidate.score+1e-12>=g_profile.minimum_score ? "PASS" : "FAIL") : "N/A");
   string level_gate=(have_candidate ? (g_candidate.level.valid ? "PASS" : "FAIL") : "N/A");
   string event_gate=(have_candidate ? "PASS" : "N/A");

   string structure_gate="N/A";
   if(have_candidate)
     {
      if(g_state==ST_WAIT_STRUCTURE) structure_gate="PENDING";
      else if(g_state==ST_WAIT_RETEST || g_state==ST_SIGNAL_READY || g_state==ST_PREFLIGHT || g_state==ST_ORDER_PENDING || g_state==ST_IN_POSITION) structure_gate="PASS";
      else if(StringFind(primary_reason,"STRUCTURE")>=0 || StringFind(primary_reason,"MICRO_BREAK")>=0) structure_gate="FAIL";
     }

   string retest_gate="N/A";
   if(have_candidate && g_profile.entry_mode==ENTRY_RETEST)
     {
      if(g_state==ST_WAIT_RETEST) retest_gate="PENDING";
      else if(g_state==ST_SIGNAL_READY || g_state==ST_PREFLIGHT || g_state==ST_ORDER_PENDING || g_state==ST_IN_POSITION) retest_gate="PASS";
      else if(StringFind(primary_reason,"RETEST")>=0) retest_gate="FAIL";
     }

   string drift_gate="N/A";
   if(have_intent) drift_gate=(intent.drift_atr<=InpMaxEntryDriftATRRatio+1e-12 ? "PASS" : "FAIL");
   else if(StringFind(primary_reason,"ENTRY_DRIFT")>=0) drift_gate="FAIL";

   string volume_gate="N/A";
   if(have_intent) volume_gate=(Positive(intent.volume) ? "PASS" : "FAIL");
   else if(StringFind(primary_reason,"VOLUME")>=0 || StringFind(primary_reason,"LOT")>=0) volume_gate="FAIL";

   string risk_gate="N/A";
   if(have_intent)
      risk_gate=(!HardRiskEnforcedAtEntry() || intent.effective_risk_percent<=InpHardMaxRiskPercent+1e-8 ? "PASS" : "FAIL");
   else if(StringFind(primary_reason,"RISK")>=0) risk_gate="FAIL";

   string target_gate="N/A";
   bool target_required=(InpTargetMode!=TARGET_NONE && InpTargetMode!=TARGET_TRAILING_ONLY);
   if(have_intent && target_required)
      target_gate=(Positive(intent.target) ? "PASS" : "FAIL");
   else if(StringFind(primary_reason,"TARGET")>=0 || StringFind(primary_reason,"RR_")>=0 || StringFind(primary_reason,"OPPOSITE_LEVEL")>=0)
      target_gate="FAIL";

   string row="";
   TEL6AddIdentity(row,"SIGNAL_DECISION",StateText(g_state),primary_reason,stage,"","","");
   CSVAdd(row,stage);
   CSVAdd(row,have_candidate?SetupText(g_candidate.setup):(intent.setup!=NMX_NONE?SetupText(intent.setup):"NONE"));
   CSVAdd(row,DirectionText(direction));
   CSVAddD(row,have_candidate?g_candidate.score:0.0,4); CSVAddD(row,g_profile.minimum_score,4);
   CSVAdd(row,score_gate); CSVAdd(row,level_gate); CSVAdd(row,TEL6Gate(true,context_ok)); CSVAdd(row,event_gate); CSVAdd(row,structure_gate); CSVAdd(row,retest_gate);
   CSVAdd(row,TEL6Gate(InpRequireFullMTFAlignment,mtf_ok)); CSVAdd(row,TEL6NewsGate()); CSVAdd(row,TEL6Gate(true,spread_ok));
   CSVAdd(row,drift_gate); CSVAdd(row,volume_gate); CSVAdd(row,risk_gate); CSVAdd(row,target_gate);
   CSVAdd(row,TEL6Gate(true,margin_ok)); CSVAdd(row,TEL6Gate(true,position_ok)); CSVAdd(row,TEL6Gate(true,exposure_ok));
   CSVAdd(row,TEL6Gate(true,daily_ok)); CSVAdd(row,TEL6Gate(true,!g_config_blocked)); CSVAdd(row,TEL6Gate(true,g_runtime_trading_enabled));
   CSVAdd(row,TEL6Gate(true,!g_entries_paused)); CSVAdd(row,TEL6Gate(true,connected)); CSVAdd(row,TEL6Gate(true,market_open));
   CSVAdd(row,TEL6Gate(direction!=DIR_NONE,symbol_mode_ok)); CSVAdd(row,TEL6Gate(have_intent,stop_broker_ok)); CSVAdd(row,TEL6Gate(true,trade_permission_ok)); CSVAdd(row,execution_gate);

   CSVAddD(row,have_candidate?g_candidate.level.quality:0.0,4); CSVAddD(row,InpMinimumLevelQuality,4); CSVAddI(row,have_candidate?CandidateAgeBars():0);
   CSVAddD(row,g_last_spread_atr,10); CSVAddD(row,g_effective_spread_atr_limit,10);
   CSVAddD(row,intent.drift_atr,10); CSVAddD(row,InpMaxEntryDriftATRRatio,10);
   CSVAddD(row,intent.calculated_volume,4); CSVAddD(row,intent.volume,4); CSVAddD(row,g_symbol.volume_min,4); CSVAddD(row,g_symbol.volume_max,4); CSVAddD(row,g_symbol.volume_step,4);
   CSVAddD(row,intent.effective_risk_money,2); CSVAddD(row,intent.effective_risk_percent,8); CSVAddD(row,InpHardMaxRiskPercent,8);
   CSVAddD(row,intent.target,g_symbol.digits); CSVAddD(row,intent.expected_r,8); CSVAddD(row,InpMinimumExpectedR,8);
   CSVAddD(row,have_candidate?g_candidate.opposite_target:0.0,g_symbol.digits);
   CSVAddD(row,margin_level,4); CSVAddI(row,open_positions); CSVAddI(row,InpMaxOpenPositions); CSVAddD(row,g_stats.net,2); CSVAddI(row,g_stats.trades);
   CSVAddI(row,InpMaxTradesPerDay); CSVAddI(row,g_stats.consecutive_losses); CSVAddI(row,InpMaxConsecutiveLosses); CSVAdd(row,g_news_status);
   
   
   CSVAdd(row,BoolText(connected)); CSVAdd(row,BoolText(terminal_trade)); CSVAdd(row,BoolText(mql_trade)); CSVAdd(row,BoolText(account_trade)); CSVAdd(row,BoolText(account_expert));
   CSVAdd(row,StateText(g_state)); CSVAdd(row,"false"); CSVAdd(row,"false");
   TEL6AppendLine("SIGNAL_DECISIONS",TEL6DecisionHeader(),row,true);
  }

int TEL6FindOutcome(const string opportunity_id)
  {
   for(int i=0;i<ArraySize(g_tel6_outcomes);i++) if(g_tel6_outcomes[i].active && g_tel6_outcomes[i].opportunity_id==opportunity_id) return i;
   return -1;
  }

void TEL6StartOutcome(const string decision,const TradeIntent &intent,const bool have_intent)
  {
   if(!TEL6SubjectEnabled("OPPORTUNITY_OUTCOME") || g_tel6_opportunity_id=="" || TEL6FindOutcome(g_tel6_opportunity_id)>=0) return;
   int n=ArraySize(g_tel6_outcomes); ArrayResize(g_tel6_outcomes,n+1);
   TEL6OutcomeTrack o; ZeroMemory(o);
   o.active=true; o.opportunity_id=g_tel6_opportunity_id; o.signal_id=g_tel6_signal_id; o.direction=(g_candidate.valid?g_candidate.direction:intent.direction);
   o.start_server=TimeTradeServer(); o.origin_bar_time=(g_candidate.valid?g_candidate.event_time:g_rates[1].time);
   MqlTick tick; ZeroMemory(tick); SymbolInfoTick(_Symbol,tick);
   o.entry=(have_intent && Positive(intent.entry) ? intent.entry : (o.direction==DIR_BUY?tick.ask:tick.bid));
   o.stop=(have_intent?intent.stop:0.0); o.target=(have_intent?intent.target:0.0); o.opposite_target=(g_candidate.valid?g_candidate.opposite_target:0.0);
   o.target_money=((InpTargetMode==TARGET_MONEY || InpTargetMode==TARGET_MONEY_THEN_TRAILING) ? InpTargetMoney : 0.0);
   o.volume=(have_intent?intent.volume:0.0); o.risk_distance=(Positive(o.stop)?MathAbs(o.entry-o.stop):0.0); o.decision=decision; o.final_ordering="NEITHER";
   g_tel6_outcomes[n]=o;
  }

void TEL6UpdateOutcomeIntent(const TradeIntent &intent)
  {
   if(g_tel6_opportunity_id=="") return;
   int idx=TEL6FindOutcome(g_tel6_opportunity_id); if(idx<0) return;
   TEL6OutcomeTrack o=g_tel6_outcomes[idx];
   if(Positive(intent.entry)) o.entry=intent.entry;
   if(Positive(intent.stop)) o.stop=intent.stop;
   if(Positive(intent.target)) o.target=intent.target;
   if(Positive(intent.volume)) o.volume=intent.volume;
   if(Positive(o.stop)) o.risk_distance=MathAbs(o.entry-o.stop);
   g_tel6_outcomes[idx]=o;
  }

void TEL6WriteOpportunitySnapshot(const string decision,const TradeIntent &intent,const bool have_intent,const string primary_reason)
  {
   if(!TEL6SubjectEnabled("OPPORTUNITY_SNAPSHOT") || g_tel6_opportunity_snapshot_written) return;
   TEL6EnsureSignalIdentity();
   MqlTick tick; ZeroMemory(tick); SymbolInfoTick(_Symbol,tick);
   double entry=(have_intent && Positive(intent.entry) ? intent.entry : (g_candidate.direction==DIR_BUY?tick.ask:tick.bid));
   double technical_stop=0.0; if(g_candidate.valid && Positive(entry)) TechnicalStop(g_candidate,entry,technical_stop);
   string snap=TEL6NewID("SNP"); string row="";
   TEL6AddIdentity(row,"OPPORTUNITY_SNAPSHOT",StateText(g_state),primary_reason,decision,snap,"","");
   CSVAdd(row,decision); CSVAdd(row,SetupText(g_candidate.setup)); CSVAdd(row,DirectionText(g_candidate.direction)); CSVAddD(row,g_candidate.signal_anchor,g_symbol.digits);
   CSVAddD(row,entry,g_symbol.digits); CSVAddD(row,tick.bid,g_symbol.digits); CSVAddD(row,tick.ask,g_symbol.digits);
   CSVAddD(row,Positive(g_symbol.point)?(tick.ask-tick.bid)/g_symbol.point:0.0,4); CSVAddD(row,Positive(g_atr)?(tick.ask-tick.bid)/g_atr:0.0,10);
   CSVAdd(row,LevelText(g_candidate.level.type)); CSVAddI(row,g_candidate.level.side); CSVAddD(row,g_candidate.level.price,g_symbol.digits); CSVAddD(row,g_candidate.level.quality,4);
   CSVAddI(row,g_candidate.level.age); CSVAddI(row,g_candidate.level.tests); CSVAddI(row,g_candidate.level.confluences); CSVAddD(row,g_candidate.atr,10); CSVAddD(row,g_vwap,g_symbol.digits);
   CSVAdd(row,RegimeText(g_regime)); CSVAddD(row,g_regime_efficiency,10); CSVAddD(row,g_regime_move_atr,10); CSVAdd(row,MTFAlignmentText());
   CSVAddD(row,g_candidate.flow.range,10); CSVAddD(row,g_candidate.flow.body_ratio,10); CSVAddD(row,g_candidate.flow.upper_wick,10); CSVAddD(row,g_candidate.flow.lower_wick,10);
   CSVAddD(row,g_candidate.flow.clv,10); CSVAddD(row,g_candidate.flow.range_atr,10); CSVAddD(row,g_candidate.flow.overlap,10); CSVAddD(row,g_candidate.flow.relative_volume,10); CSVAddD(row,g_candidate.flow.efficiency,10);
   CSVAddD(row,g_candidate.score,4); CSVAddD(row,g_profile.minimum_score,4); CSVAddD(row,technical_stop,g_symbol.digits); CSVAddD(row,InpStopMoney,2); CSVAddD(row,g_candidate.opposite_target,g_symbol.digits);
   CSVAddD(row,have_intent?intent.target:0.0,g_symbol.digits); CSVAdd(row,EnumToString(InpTargetMode)); CSVAddD(row,InpTargetMoney,2);
   CSVAddD(row,have_intent?intent.calculated_volume:0.0,4); CSVAddD(row,have_intent?intent.volume:0.0,4);
   CSVAddD(row,have_intent?intent.effective_risk_money:0.0,2); CSVAddD(row,have_intent?intent.effective_risk_percent:0.0,8); CSVAdd(row,g_news_status);
   
   CSVAdd(row,g_blocking_gate);
   CSVAdd(row,"false"); CSVAdd(row,"false");
   TEL6AppendLine("OPPORTUNITY_SNAPSHOT",TEL6OpportunityHeader(),row,true);
   g_tel6_opportunity_snapshot_written=true;
   TEL6StartOutcome(decision,intent,have_intent); TEL6ArmIntrabar(InpTEL6IntrabarPostSignalSeconds);
  }

void TEL6WriteSignalMarker(const string marker_class,const TradeIntent &intent,const bool have_intent,const string execution_state,const string final_result="")
  {
   if(!TEL6SubjectEnabled("SIGNAL_MARKERS")) return;
   TEL6EnsureSignalIdentity(); g_tel6_marker_id=TEL6NewID("MRK");
   MqlTick tick; ZeroMemory(tick); SymbolInfoTick(_Symbol,tick);
   double price=(have_intent && Positive(intent.entry)?intent.entry:(g_candidate.direction==DIR_BUY?tick.ask:tick.bid));
   string row="";
   TEL6AddIdentity(row,"SIGNAL_MARKER",marker_class,g_reason,execution_state,"","","");
   CSVAdd(row,marker_class); CSVAdd(row,"false"); CSVAdd(row,DirectionText(g_candidate.direction)); CSVAddD(row,price,g_symbol.digits);
   CSVAdd(row,LevelText(g_candidate.level.type)); CSVAddD(row,g_candidate.level.price,g_symbol.digits); CSVAddI(row,g_candidate.flow.direction);
   CSVAddD(row,g_candidate.score,4); CSVAddD(row,g_profile.minimum_score,4); CSVAddD(row,have_intent?intent.stop:0.0,g_symbol.digits); CSVAddD(row,have_intent?intent.target:0.0,g_symbol.digits);
   CSVAddD(row,g_last_spread_atr,10); CSVAdd(row,execution_state); CSVAdd(row,final_result); CSVAdd(row,"false"); CSVAdd(row,"false");
   TEL6AppendLine("SIGNAL_MARKERS",TEL6MarkerHeader(),row,true);
  }

string TEL6RiskStateHash()
  {
   return TEL6Hash8(StringFormat("%.2f|%.2f|%.2f|%.2f|%.4f|%.4f|%d|%d|%d|%s",AccountInfoDouble(ACCOUNT_BALANCE),AccountInfoDouble(ACCOUNT_EQUITY),
                                 AccountInfoDouble(ACCOUNT_MARGIN_FREE),AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),g_stats.daily_loss_percent,g_stats.drawdown_percent,
                                 g_stats.trades,g_stats.consecutive_losses,CountOwnPositions(),g_stats.reason));
  }

void TEL6WriteRiskState(const string trigger,const TradeIntent &intent,const bool have_intent,const bool force=false)
  {
   if(!TEL6SubjectEnabled("RISK_STATE")) return;
   if(!force && trigger=="TIMER")
     {
      ulong now_ms=GetTickCount64();
      ulong min_gap=(ulong)MathMax(1,InpTEL6StateHeartbeatSeconds)*1000;
      if(g_tel6_last_risk_heartbeat_ms>0 && now_ms-g_tel6_last_risk_heartbeat_ms<min_gap) return;
      g_tel6_last_risk_heartbeat_ms=now_ms;
     }
   string hash=TEL6RiskStateHash(); if(!force && hash==g_tel6_last_risk_hash) return; g_tel6_last_risk_hash=hash;
   string row="";
   TEL6AddIdentity(row,"RISK_STATE",g_stats.blocked?"BLOCKED":"NORMAL",trigger,g_stats.reason,"","","");
   CSVAdd(row,trigger); CSVAddD(row,AccountInfoDouble(ACCOUNT_BALANCE),2); CSVAddD(row,AccountInfoDouble(ACCOUNT_EQUITY),2);
   CSVAddD(row,AccountInfoDouble(ACCOUNT_MARGIN_FREE),2); CSVAddD(row,AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),4); CSVAdd(row,EnumToString(InpRiskMode));
   CSVAddD(row,InpRiskPercent,8); CSVAddD(row,InpFixedLot,4); CSVAdd(row,RiskCapModeText()); CSVAdd(row,EnumToString(InpEquityGuardScope)); CSVAdd(row,RiskSafetyStateText()); CSVAddD(row,InpHardMaxRiskPercent,8); CSVAdd(row,EnumToString(InpStopMode));
   CSVAddD(row,InpStopMoney,2); CSVAddD(row,have_intent?intent.risk_money:0.0,2); CSVAddD(row,have_intent?intent.effective_risk_money:0.0,2);
   CSVAddD(row,have_intent?intent.effective_risk_percent:0.0,8); CSVAddI(row,CountOwnPositions()); CSVAddI(row,InpMaxOpenPositions); CSVAddI(row,InpMaxCurrencyExposures);
   CSVAddD(row,g_stats.net,2); CSVAddD(row,g_stats.realized_profit,2); CSVAddD(row,g_stats.realized_loss,2); CSVAddD(row,g_stats.daily_loss_percent,8); CSVAddD(row,InpMaxDailyLossPercent,8);
   CSVAddD(row,g_stats.drawdown_percent,8); CSVAddD(row,InpMaxDrawdownPercent,8); CSVAddI(row,g_stats.trades); CSVAddI(row,InpMaxTradesPerDay); CSVAddI(row,g_stats.consecutive_losses); CSVAddI(row,InpMaxConsecutiveLosses);
   CSVAddD(row,g_symbol.volume_min,4); CSVAddD(row,g_symbol.volume_max,4); CSVAddD(row,g_symbol.volume_step,4); CSVAddI(row,g_symbol.stops_level); CSVAddI(row,g_symbol.freeze_level);
   CSVAdd(row,NGP_PORTFOLIO_RISK_CONTRACT); CSVAdd(row,NGP_PORTFOLIO_RISK_STATE);
   CSVAdd(row,BoolText(g_stats.blocked)); CSVAdd(row,g_stats.reason); CSVAdd(row,hash);
   TEL6AppendLine("RISK_STATE",TEL6RiskHeader(),row,force);
  }

void TEL6WriteProfitManagement(const string action,const PositionInfoNMX &p,const double new_sl,const double new_tp,const string reason,const uint retcode)
  {
   if(!TEL6SubjectEnabled("PROFIT_MANAGEMENT")) return;
   string save_candidate,save_opportunity,save_setup,save_signal,save_intent;
   TEL6ApplyTradeLink(p.identifier,save_candidate,save_opportunity,save_setup,save_signal,save_intent);
   double current=PositionNetEstimate(p); double peak=ReadPositionState(p,"PEAK",current); double trough=ReadPositionState(p,"TROUGH",current);
   bool trail_active=ReadPositionState(p,"TRAIL",0.0)>0.5; double lock=ReadPositionState(p,"LOCK",0.0);
   string row=""; string trade_id=TEL6TradeCycleID(p.identifier);
   TEL6AddIdentity(row,"PROFIT_MANAGEMENT",action,reason,"","",trade_id,"");
   CSVAdd(row,action); CSVAddU(row,p.ticket); CSVAddU(row,p.identifier); CSVAdd(row,EnumToString(p.type)); CSVAddD(row,p.volume,4); CSVAddD(row,p.open_price,g_symbol.digits);
   CSVAddD(row,p.stop,g_symbol.digits); CSVAddD(row,p.target,g_symbol.digits); CSVAddD(row,new_sl,g_symbol.digits); CSVAddD(row,new_tp,g_symbol.digits);
   CSVAddD(row,current,2); CSVAddD(row,peak,2); CSVAddD(row,trough,2); CSVAdd(row,EnumToString(InpTargetMode)); CSVAddD(row,InpTargetMoney,2);
   CSVAdd(row,BoolText(InpUseTrailing)); CSVAdd(row,EnumToString(InpTrailingMode)); CSVAdd(row,BoolText(trail_active));
   CSVAddD(row,InpTrailingActivationMoney,2); CSVAddD(row,(trail_active ? TrailDistanceMoney(peak) : 0.0),2); CSVAddD(row,lock,2); CSVAddD(row,MathMax(0.0,lock),2);
   CSVAddD(row,(trail_active ? TrailFloorMoney(peak) : 0.0),2);
   CSVAdd(row,BoolText(InpUseTimeStop)); CSVAdd(row,reason); CSVAddI(row,retcode);
   TEL6AppendLine("PROFIT_MANAGEMENT",TEL6ProfitHeader(),row,true);
   TEL6RestoreTradeLink(save_candidate,save_opportunity,save_setup,save_signal,save_intent);
  }

void TEL6MaybeWriteProfitState(const PositionInfoNMX &p,const string trigger,const bool force=false)
  {
   if(!TEL6SubjectEnabled("PROFIT_MANAGEMENT")) return;
   double current=PositionNetEstimate(p);
   // Estado estrutural: SL/TP/lock/trail. Variacao de P/L por tick NAO e mudanca de estado:
   // e amostrada por tempo e por delta monetario (evita centenas de MB por posicao).
   double lock=ReadPositionState(p,"LOCK",0.0); bool trail=ReadPositionState(p,"TRAIL",0.0)>0.5;
   string hash=TEL6Hash8(StringFormat("%I64u|%.10f|%.10f|%.6f|%s",p.identifier,p.stop,p.target,lock,BoolText(trail)));
   bool structural=TEL6PositionStateChanged(p.identifier,hash,force);
   int idx=TEL6FindPositionState(p.identifier);
   if(idx<0) return;
   ulong now_ms=GetTickCount64();
   bool due=(g_tel6_position_states[idx].last_ms==0 ||
             now_ms-g_tel6_position_states[idx].last_ms>=(ulong)MathMax(1,InpTEL6ProfitSampleSeconds)*1000 ||
             MathAbs(current-g_tel6_position_states[idx].last_pnl)>=InpTEL6ProfitSampleMoney);
   if(!structural && !due) return;
   g_tel6_position_states[idx].last_ms=now_ms;
   g_tel6_position_states[idx].last_pnl=current;
   TEL6WriteProfitManagement("STATE_CHANGE",p,p.stop,p.target,trigger,0);
  }

void TEL6WriteExecution(const string stage,const string final_state,const TradeIntent &intent,const bool have_intent,
                        const MqlTradeRequest &request,const bool order_check_executed,const bool order_check_bool,const MqlTradeCheckResult &check,
                        const bool order_send_called,const bool order_send_bool,const MqlTradeResult &result,const string primary_reason,
                        const ulong position_id=0)
  {
   if(!TEL6SubjectEnabled("EXECUTION")) return;
   string save_candidate,save_opportunity,save_setup,save_signal,save_intent;
   if(position_id>0) TEL6ApplyTradeLink(position_id,save_candidate,save_opportunity,save_setup,save_signal,save_intent);
   string row=""; string trade_id=(position_id>0 ? TEL6TradeCycleID(position_id) : "");
   TEL6AddIdentity(row,"EXECUTION",final_state,primary_reason,stage,"",trade_id,"");
   CSVAdd(row,stage); CSVAdd(row,(order_check_executed || order_send_called) ? EnumToString(request.action) : "NOT_REACHED");
   CSVAdd(row,have_intent?DirectionText(intent.direction):"NONE");
   CSVAddD(row,request.volume,4); CSVAddD(row,request.price,g_symbol.digits); CSVAddD(row,request.sl,g_symbol.digits); CSVAddD(row,request.tp,g_symbol.digits);
   CSVAdd(row,BoolText(order_check_executed)); CSVAdd(row,order_check_executed?BoolText(order_check_bool):"N/A");
   CSVAdd(row,order_check_executed?IntegerToString((int)check.retcode):"N/A"); CSVAdd(row,order_check_executed?check.comment:"NOT_REACHED");
   CSVAddD(row,order_check_executed?check.margin:0.0,2); CSVAddD(row,order_check_executed?check.margin_free:0.0,2); CSVAddD(row,order_check_executed?check.margin_level:0.0,4);
   CSVAdd(row,BoolText(order_send_called)); CSVAdd(row,order_send_called?BoolText(order_send_bool):"N/A");
   CSVAdd(row,order_send_called?IntegerToString((int)result.retcode):"N/A"); CSVAdd(row,order_send_called?result.comment:"NOT_REACHED");
   CSVAddU(row,result.order); CSVAddU(row,result.deal); CSVAddD(row,result.price,g_symbol.digits); CSVAdd(row,final_state);
   TEL6AppendLine("EXECUTION",TEL6ExecutionHeader(),row,true);
   if(position_id>0) TEL6RestoreTradeLink(save_candidate,save_opportunity,save_setup,save_signal,save_intent);
  }

long TEL6PositionDurationSeconds(const ulong position_id)
  {
   if(!HistorySelectByPosition(position_id)) return 0;
   datetime t_in=0,t_out=0;
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong deal=HistoryDealGetTicket(i); if(deal==0) continue;
      datetime when=(datetime)HistoryDealGetInteger(deal,DEAL_TIME);
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal,DEAL_ENTRY)==DEAL_ENTRY_IN && (t_in==0 || when<t_in)) t_in=when;
      if(when>t_out) t_out=when;
     }
   return (t_in>0 && t_out>=t_in ? (long)(t_out-t_in) : 0);
  }

void TEL6WriteTradeLifecycle(const string lifecycle_event,const ulong position_id,const ulong position_ticket,const ulong order_ticket,const ulong deal_ticket,
                             const ENUM_DEAL_ENTRY deal_entry,const ENUM_DEAL_TYPE deal_type,const ENUM_DEAL_REASON deal_reason,const double volume,
                             const double price,const double profit,const double commission,const double swap,const double fee,const double position_final_net,
                             const string position_result,const PositionInfoNMX &p,const bool have_position)
  {
   if(!TEL6SubjectEnabled("TRADE_LIFECYCLE")) return;
   TEL6BindTradeLink(position_id);
   string save_candidate,save_opportunity,save_setup,save_signal,save_intent;
   TEL6ApplyTradeLink(position_id,save_candidate,save_opportunity,save_setup,save_signal,save_intent);
   string trade_id=TEL6TradeCycleID(position_id); string row="";
   TEL6AddIdentity(row,"TRADE_LIFECYCLE",lifecycle_event,position_result,EnumToString(deal_reason),"",trade_id,"");
   CSVAdd(row,lifecycle_event); CSVAddU(row,position_id); CSVAddU(row,position_ticket); CSVAddU(row,order_ticket); CSVAddU(row,deal_ticket);
   CSVAdd(row,EnumToString(deal_entry)); CSVAdd(row,EnumToString(deal_type)); CSVAdd(row,EnumToString(deal_reason)); CSVAddD(row,volume,4); CSVAddD(row,price,g_symbol.digits);
   CSVAddD(row,profit,2); CSVAddD(row,commission,2); CSVAddD(row,swap,2); CSVAddD(row,fee,2); CSVAddD(row,profit+commission+swap+fee,2);
   CSVAddD(row,position_final_net,2); CSVAdd(row,position_result); CSVAddD(row,have_position?p.open_price:0.0,g_symbol.digits); CSVAddD(row,have_position?p.stop:0.0,g_symbol.digits);
   CSVAddD(row,have_position?p.target:0.0,g_symbol.digits); CSVAdd(row,have_position?TimeframeShort(p.origin_tf):"");
   CSVAddI(row,have_position ? MathMax(0,(long)(TimeTradeServer()-p.open_time)) :
                  (lifecycle_event=="POSITION_CLOSED" ? TEL6PositionDurationSeconds(position_id) : 0));
   TEL6AppendLine("TRADE_LIFECYCLE",TEL6TradeHeader(),row,true);
   TEL6RestoreTradeLink(save_candidate,save_opportunity,save_setup,save_signal,save_intent);
   if(lifecycle_event=="POSITION_CLOSED")
     {
      TEL6DropTradeLink(position_id);
      TEL6DropPositionState(position_id);
     }
  }

string TEL6Severity(const string event_name)
  {
   if(StringFind(event_name,"FAILED")>=0 || StringFind(event_name,"ERROR")>=0 || StringFind(event_name,"REJECTED")>=0) return "ERROR";
   if(StringFind(event_name,"BLOCK")>=0 || StringFind(event_name,"UNAVAILABLE")>=0 || StringFind(event_name,"DISABLED")>=0 || StringFind(event_name,"WARNING")>=0) return "WARN";
   return "INFO";
  }

string TEL6Component(const string event_name)
  {
   if(StringFind(event_name,"ORDER")>=0 || StringFind(event_name,"PREFLIGHT")>=0 || StringFind(event_name,"DEAL")>=0) return "EXECUTION";
   if(StringFind(event_name,"TRAIL")>=0 || StringFind(event_name,"POSITION")>=0 || StringFind(event_name,"STOP")>=0) return "POSITION_MANAGEMENT";
   if(StringFind(event_name,"NEWS")>=0 || StringFind(event_name,"CALENDAR")>=0) return "NEWS";
   if(StringFind(event_name,"RISK")>=0 || StringFind(event_name,"DRAWDOWN")>=0 || StringFind(event_name,"MARGIN")>=0) return "RISK";
   if(StringFind(event_name,"CSV")>=0 || StringFind(event_name,"INIT")>=0 || StringFind(event_name,"DEINIT")>=0 || StringFind(event_name,"CONFIG")>=0) return "ENGINE";
   return "STRATEGY";
  }

void TEL6WriteDiagnostic(const string event_name,const string message)
  {
   if(!g_tel6_initialized || !TEL6SubjectEnabled("DIAGNOSTIC")) return;
   string severity=TEL6Severity(event_name);
   string component=TEL6Component(event_name);
   // DIAGNOSTIC e para saude tecnica, nao para duplicar toda a estrategia.
   // Eventos normais de sinal/gestao ja possuem familias especializadas.
   if(component!="ENGINE" && severity=="INFO") return;
   if(component=="STRATEGY") return;
   string row="";
   TEL6AddIdentity(row,"DIAGNOSTIC",StateText(g_state),event_name,g_reason,"","","");
   CSVAdd(row,severity); CSVAdd(row,component); CSVAdd(row,message);
   CSVAdd(row,BoolText((bool)TerminalInfoInteger(TERMINAL_CONNECTED))); CSVAdd(row,BoolText((bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)));
   CSVAdd(row,BoolText((bool)MQLInfoInteger(MQL_TRADE_ALLOWED))); CSVAdd(row,BoolText((bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)));
   CSVAdd(row,BoolText((bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT))); CSVAdd(row,BoolText(MarketOpen())); CSVAddI(row,ArraySize(g_rates));
   CSVAdd(row,BoolText(Positive(g_atr))); CSVAdd(row,BoolText(g_config_blocked)); 
   CSVAdd(row,BoolText(g_tel6_write_fault));
   TEL6AppendLine("DIAGNOSTIC",TEL6DiagnosticHeader(),row,severity!="INFO");
  }

void TEL6WriteIntrabar()
  {
   if(!TEL6SubjectEnabled("INTRABAR_TRACE") || TimeTradeServer()>g_tel6_intrabar_armed_until) return;
   ulong now_ms=GetTickCount64();
   if(g_tel6_last_intrabar_ms>0 && now_ms-g_tel6_last_intrabar_ms<(ulong)MathMax(50,InpTEL6IntrabarIntervalMs)) return;
   g_tel6_last_intrabar_ms=now_ms;
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick)) return;
   MqlRates live[]; ArraySetAsSeries(live,true); if(CopyRates(_Symbol,g_profile.tf,0,1,live)<1) return;
   string row="";
   TEL6AddIdentity(row,"INTRABAR_TRACE",StateText(g_state),g_reason,g_blocking_gate,"","","");
   CSVAddD(row,tick.bid,g_symbol.digits); CSVAddD(row,tick.ask,g_symbol.digits); CSVAddD(row,tick.last,g_symbol.digits);
   CSVAddD(row,Positive(g_symbol.point)?(tick.ask-tick.bid)/g_symbol.point:0.0,4); CSVAddD(row,Positive(g_atr)?(tick.ask-tick.bid)/g_atr:0.0,10);
   CSVAddI(row,(long)tick.flags); CSVAddU(row,(ulong)tick.volume); CSVAddD(row,tick.volume_real,4); CSVAdd(row,TimeToString(live[0].time,TIME_DATE|TIME_SECONDS));
   CSVAddD(row,live[0].open,g_symbol.digits); CSVAddD(row,live[0].high,g_symbol.digits); CSVAddD(row,live[0].low,g_symbol.digits); CSVAddD(row,live[0].close,g_symbol.digits);
   CSVAdd(row,StateText(g_state)); CSVAdd(row,TimeToString(g_tel6_intrabar_armed_until,TIME_DATE|TIME_SECONDS)); CSVAdd(row,"true"); CSVAdd(row,"false");
   TEL6AppendLine("INTRABAR_TRACE",TEL6IntrabarHeader(),row,false);
  }

void TEL6FinalizeOutcome(const int idx,const string ordering,const bool complete)
  {
   if(idx<0 || idx>=ArraySize(g_tel6_outcomes)) return;
   TEL6OutcomeTrack o=g_tel6_outcomes[idx];
   int bars=iBarShift(_Symbol,g_profile.tf,o.origin_bar_time,false); if(bars<0) bars=0;
   string saved_opp=g_tel6_opportunity_id; string saved_sig=g_tel6_signal_id;
   g_tel6_opportunity_id=o.opportunity_id; g_tel6_signal_id=o.signal_id;
   string row="";
   TEL6AddIdentity(row,"OPPORTUNITY_OUTCOME",complete?"COMPLETE":"CHECKPOINT",o.decision,ordering,"","","");
   CSVAdd(row,o.decision); CSVAdd(row,DirectionText(o.direction)); CSVAddD(row,o.entry,g_symbol.digits); CSVAddD(row,o.stop,g_symbol.digits); CSVAddD(row,o.target,g_symbol.digits);
   CSVAddD(row,o.opposite_target,g_symbol.digits); CSVAddD(row,o.target_money,2); CSVAddD(row,o.volume,4); CSVAddD(row,o.risk_distance,10); CSVAddI(row,bars);
   CSVAddD(row,o.mfe_price,g_symbol.digits); CSVAddD(row,o.mae_price,g_symbol.digits); CSVAddD(row,o.mfe_points,4); CSVAddD(row,o.mae_points,4);
   CSVAddD(row,o.mfe_money,2); CSVAddD(row,o.mae_money,2); CSVAddI(row,o.mfe_time>0?MathMax(0,(long)(o.mfe_time-o.start_server)):0); CSVAddI(row,o.mae_time>0?MathMax(0,(long)(o.mae_time-o.start_server)):0);
   CSVAdd(row,BoolText(o.hit_05r_time>0)); CSVAdd(row,BoolText(o.hit_10r_time>0)); CSVAdd(row,BoolText(o.hit_15r_time>0)); CSVAdd(row,BoolText(o.hit_20r_time>0));
   CSVAdd(row,BoolText(o.hit_target_time>0)); CSVAdd(row,BoolText(o.hit_target_money_time>0)); CSVAdd(row,BoolText(o.hit_stop_time>0)); CSVAdd(row,BoolText(o.hit_opposite_liquidity));
   CSVAdd(row,o.hit_05r_time>0?TimeToString(o.hit_05r_time,TIME_DATE|TIME_SECONDS):""); CSVAdd(row,o.hit_10r_time>0?TimeToString(o.hit_10r_time,TIME_DATE|TIME_SECONDS):"");
   CSVAdd(row,o.hit_15r_time>0?TimeToString(o.hit_15r_time,TIME_DATE|TIME_SECONDS):""); CSVAdd(row,o.hit_20r_time>0?TimeToString(o.hit_20r_time,TIME_DATE|TIME_SECONDS):"");
   CSVAdd(row,o.hit_target_time>0?TimeToString(o.hit_target_time,TIME_DATE|TIME_SECONDS):""); CSVAdd(row,o.hit_target_money_time>0?TimeToString(o.hit_target_money_time,TIME_DATE|TIME_SECONDS):""); CSVAdd(row,o.hit_stop_time>0?TimeToString(o.hit_stop_time,TIME_DATE|TIME_SECONDS):"");
   CSVAdd(row,o.opposite_liquidity_time>0?TimeToString(o.opposite_liquidity_time,TIME_DATE|TIME_SECONDS):""); CSVAdd(row,ordering); CSVAdd(row,BoolText(complete));
   CSVAdd(row,"false"); CSVAdd(row,"true");
   TEL6AppendLine("OPPORTUNITY_OUTCOME",TEL6OutcomeHeader(),row,true);
   g_tel6_opportunity_id=saved_opp; g_tel6_signal_id=saved_sig;
   if(complete) { o.active=false; g_tel6_outcomes[idx]=o; }
  }

void TEL6CompactOutcomes()
  {
   int total=ArraySize(g_tel6_outcomes);
   if(total<256) return;
   int active_count=0;
   for(int i=0;i<total;i++) if(g_tel6_outcomes[i].active) active_count++;
   if(total-active_count<total/2) return;
   int dst=0;
   for(int i=0;i<total;i++)
     {
      if(!g_tel6_outcomes[i].active) continue;
      if(dst!=i) g_tel6_outcomes[dst]=g_tel6_outcomes[i];
      dst++;
     }
   ArrayResize(g_tel6_outcomes,dst);
  }

void TEL6UpdateOutcomes()
  {
   if(!TEL6SubjectEnabled("OPPORTUNITY_OUTCOME") || ArraySize(g_tel6_outcomes)==0) return;
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick)) return;
   for(int i=0;i<ArraySize(g_tel6_outcomes);i++)
     {
      if(!g_tel6_outcomes[i].active) continue;
      TEL6OutcomeTrack o=g_tel6_outcomes[i];
      double exit_price=(o.direction==DIR_BUY?tick.bid:tick.ask);
      double favorable=(o.direction==DIR_BUY?exit_price-o.entry:o.entry-exit_price);
      double adverse=(o.direction==DIR_BUY?o.entry-exit_price:exit_price-o.entry);
      if(favorable>o.mfe_price) { o.mfe_price=favorable; o.mfe_points=(Positive(g_symbol.point)?favorable/g_symbol.point:0.0); o.mfe_time=TimeTradeServer(); }
      if(adverse>o.mae_price) { o.mae_price=adverse; o.mae_points=(Positive(g_symbol.point)?adverse/g_symbol.point:0.0); o.mae_time=TimeTradeServer(); }
      if(Positive(o.volume))
        {
         double pnl=0.0; ENUM_ORDER_TYPE type=(o.direction==DIR_BUY?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
         if(OrderCalcProfit(type,_Symbol,o.volume,o.entry,exit_price,pnl))
           {
            if(pnl>o.mfe_money) o.mfe_money=pnl;
            if(pnl<0.0 && MathAbs(pnl)>o.mae_money) o.mae_money=MathAbs(pnl);
            if(Positive(o.target_money) && pnl>=o.target_money && o.hit_target_money_time==0) o.hit_target_money_time=TimeTradeServer();
           }
        }
      if(Positive(o.risk_distance))
        {
         double r=(favorable/o.risk_distance);
         if(r>=0.5 && o.hit_05r_time==0) o.hit_05r_time=TimeTradeServer();
         if(r>=1.0 && o.hit_10r_time==0) o.hit_10r_time=TimeTradeServer();
         if(r>=1.5 && o.hit_15r_time==0) o.hit_15r_time=TimeTradeServer();
         if(r>=2.0 && o.hit_20r_time==0) o.hit_20r_time=TimeTradeServer();
        }
      bool target_hit=(Positive(o.target) && (o.direction==DIR_BUY?tick.bid>=o.target:tick.ask<=o.target));
      bool stop_hit=(Positive(o.stop) && (o.direction==DIR_BUY?tick.bid<=o.stop:tick.ask>=o.stop));
      bool opp_hit=(Positive(o.opposite_target) && (o.direction==DIR_BUY?tick.bid>=o.opposite_target:tick.ask<=o.opposite_target));
      if(target_hit && o.hit_target_time==0) o.hit_target_time=TimeTradeServer();
      if(stop_hit && o.hit_stop_time==0) o.hit_stop_time=TimeTradeServer();
      if(opp_hit && !o.hit_opposite_liquidity) { o.hit_opposite_liquidity=true; o.opposite_liquidity_time=TimeTradeServer(); }
      g_tel6_outcomes[i]=o;
      if(o.hit_target_time>0 && o.hit_stop_time>0)
        {
         string ord=(o.hit_target_time==o.hit_stop_time ? "AMBIGUOUS_SAME_SAMPLE" : (o.hit_target_time<o.hit_stop_time ? "TARGET_BEFORE_STOP" : "STOP_BEFORE_TARGET"));
         TEL6FinalizeOutcome(i,ord,true); continue;
        }
      if(o.hit_target_time>0) { TEL6FinalizeOutcome(i,"TARGET_BEFORE_STOP",true); continue; }
      if(o.hit_stop_time>0) { TEL6FinalizeOutcome(i,"STOP_BEFORE_TARGET",true); continue; }
      int bars=iBarShift(_Symbol,g_profile.tf,o.origin_bar_time,false);
      if(bars>=MathMax(1,InpTEL6OutcomeBars)) TEL6FinalizeOutcome(i,"NEITHER",true);
     }
   TEL6CompactOutcomes();
  }

void TEL6Initialize()
  {
   if(!InpEnableTEL6) return;
   g_tel6_sequence=0; g_tel6_id_counter=0; g_tel6_write_fault=false; g_tel6_last_market_hash=""; g_tel6_last_risk_hash="";
   g_tel6_last_market_heartbeat_ms=0; g_tel6_last_risk_heartbeat_ms=0; g_tel6_last_moment_ms=0; g_tel6_last_intrabar_ms=0;
   ArrayResize(g_tel6_outcomes,0); ArrayResize(g_tel6_objects,0); ArrayResize(g_tel6_trade_links,0); ArrayResize(g_tel6_position_states,0);
   TEL6ClearPendingTradeLink(); TEL6RefreshHashes();
   long now_local=(long)TimeLocal();
   ulong runtime_nonce=GetTickCount64();
   string identity_seed=StringFormat("%I64d|%s|%I64d|%s|%s|%I64d|%I64u",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER),
                                     ChartID(),_Symbol,TimeframeShort(g_profile.tf),now_local,runtime_nonce);
   g_tel6_run_id=StringFormat("RUN_%I64d_%s",now_local,TEL6Hash8(identity_seed));
   g_tel6_instance_id=StringFormat("INS_%s",TEL6Hash8(StringFormat("%I64d|%s|%I64d|%s|%s",AccountInfoInteger(ACCOUNT_LOGIN),
                                      AccountInfoString(ACCOUNT_SERVER),ChartID(),_Symbol,TimeframeShort(g_profile.tf))));
   g_tel6_initialized=true; TEL6EnsureFiles(); TEL6WriteRunConfig();
  }

void LogEvent(const string event_name,const string detail)
  {
   string clean=detail; StringReplace(clean,";","|"); StringReplace(clean,"\r"," "); StringReplace(clean,"\n"," ");
   g_last_event=event_name; g_last_event_reason=clean;
   bool journal_event=EventBelongsInJournal(event_name);
   if(journal_event && InpVerboseJournal)
      PrintFormat("NGP|%s|%s|%s|%s",event_name,_Symbol,EnumToString(g_profile.tf),clean);
   if(journal_event) WriteJournalCSV(event_name,clean);
   TEL6WriteDiagnostic(event_name,clean);
  }


bool LoadRatesAndATR()
  {
   ArraySetAsSeries(g_rates,true);
   int need=MathMax(InpBarsToLoad,InpMinimumHistoryBars+50);
   int copied=CopyRates(_Symbol,g_profile.tf,0,need,g_rates);
   if(copied<InpMinimumHistoryBars) { g_reason="INSUFFICIENT_HISTORY"; return false; }
   if(g_atr_handle==INVALID_HANDLE) return false;
   double values[]; ArraySetAsSeries(values,true);
   if(CopyBuffer(g_atr_handle,0,0,3,values)<3 || !Positive(values[1]))
     { g_reason="ATR_UNAVAILABLE"; return false; }
   g_atr=values[1];
   return true;
  }

bool IsNewBar()
  {
   datetime current=iTime(_Symbol,g_profile.tf,0);
   if(current<=0) return false;
   if(g_last_bar==0) { g_last_bar=current; return false; }
   if(current==g_last_bar) return false;
   g_last_bar=current;
   return true;
  }

double BarOverlap(const int shift)
  {
   if(shift+1>=ArraySize(g_rates)) return 1.0;
   double range=g_rates[shift].high-g_rates[shift].low;
   if(!Positive(range)) return 1.0;
   double overlap=MathMax(0.0,MathMin(g_rates[shift].high,g_rates[shift+1].high)-
                                        MathMax(g_rates[shift].low,g_rates[shift+1].low));
   return Clamp(overlap/range,0.0,1.0);
  }

double RelativeTickVolume(const int shift)
  {
   int end=MathMin(ArraySize(g_rates)-1,shift+InpRelativeVolumeLookback);
   double total=0.0; int count=0;
   for(int i=shift+1;i<=end;i++) { if(g_rates[i].tick_volume>0) { total+=(double)g_rates[i].tick_volume; count++; } }
   if(count==0) return 0.0;
   return (double)g_rates[shift].tick_volume/(total/count);
  }

bool CalculateFlow(const int shift,FlowSnapshot &f)
  {
   ZeroMemory(f);
   if(shift<1 || shift+2>=ArraySize(g_rates) || !Positive(g_atr)) return false;
   MqlRates b=g_rates[shift];
   f.range=b.high-b.low;
   if(!Positive(f.range)) return false;
   f.body_ratio=MathAbs(b.close-b.open)/f.range;
   f.upper_wick=(b.high-MathMax(b.open,b.close))/f.range;
   f.lower_wick=(MathMin(b.open,b.close)-b.low)/f.range;
   f.clv=(b.close-b.low)/f.range;
   f.range_atr=f.range/g_atr;
   f.overlap=BarOverlap(shift);
   f.relative_volume=RelativeTickVolume(shift);
   double net=MathAbs(b.close-g_rates[shift+2].close);
   double path=MathAbs(g_rates[shift].close-g_rates[shift+1].close)+
               MathAbs(g_rates[shift+1].close-g_rates[shift+2].close);
   f.efficiency=(path>0.0 ? Clamp(net/path,0.0,1.0) : 0.0);
   f.direction=(b.close>b.open ? 1 : (b.close<b.open ? -1 : 0));
   f.valid=true;
   return true;
  }

bool CalculateLiveFlow(FlowSnapshot &f,MqlRates &live_bar)
  {
   ZeroMemory(f); ZeroMemory(live_bar);
   if(ArraySize(g_rates)<InpRelativeVolumeLookback+3 || !Positive(g_atr)) return false;
   MqlRates current[]; ArraySetAsSeries(current,true);
   if(CopyRates(_Symbol,g_profile.tf,0,1,current)!=1) return false;
   live_bar=current[0];
   f.range=live_bar.high-live_bar.low;
   if(!Positive(f.range)) return false;
   f.body_ratio=MathAbs(live_bar.close-live_bar.open)/f.range;
   f.upper_wick=(live_bar.high-MathMax(live_bar.open,live_bar.close))/f.range;
   f.lower_wick=(MathMin(live_bar.open,live_bar.close)-live_bar.low)/f.range;
   f.clv=(live_bar.close-live_bar.low)/f.range;
   f.range_atr=f.range/g_atr;
   double overlap=MathMax(0.0,MathMin(live_bar.high,g_rates[1].high)-
                                MathMax(live_bar.low,g_rates[1].low));
   f.overlap=Clamp(overlap/f.range,0.0,1.0);
   double average_volume=0.0; int volume_count=0;
   int end=MathMin(ArraySize(g_rates)-1,InpRelativeVolumeLookback);
   for(int i=1;i<=end;i++)
     {
      if(g_rates[i].tick_volume<=0) continue;
      average_volume+=(double)g_rates[i].tick_volume; volume_count++;
     }
   f.relative_volume=(volume_count>0 ? (double)live_bar.tick_volume/(average_volume/volume_count) : 0.0);
   double net=MathAbs(live_bar.close-g_rates[2].close);
   double path=MathAbs(live_bar.close-g_rates[1].close)+MathAbs(g_rates[1].close-g_rates[2].close);
   f.efficiency=(path>0.0 ? Clamp(net/path,0.0,1.0) : 0.0);
   f.direction=(live_bar.close>live_bar.open ? 1 : (live_bar.close<live_bar.open ? -1 : 0));
   f.valid=true;
   return true;
  }

bool DirectionalDisplacement(const FlowSnapshot &f,const ENUM_NMX_DIRECTION d)
  {
   if(!f.valid) return false;
   bool direction=(d==DIR_BUY ? f.direction>0 && f.clv>=InpBuyCLVMin : f.direction<0 && f.clv<=InpSellCLVMax);
   return direction && f.range_atr>=InpMinDisplacementRangeATR &&
          f.body_ratio>=InpMinDisplacementBody && f.overlap<=InpMaxDisplacementOverlap;
  }

double DisplacementQuality(const FlowSnapshot &f,const ENUM_NMX_DIRECTION d)
  {
   if(!f.valid) return 0.0;
   double close_quality=(d==DIR_BUY ? f.clv : 1.0-f.clv)*100.0;
   double body=Clamp(f.body_ratio/MathMax(InpMinDisplacementBody,0.01)*70.0,0.0,100.0);
   double expansion=Clamp(f.range_atr/MathMax(InpMinDisplacementRangeATR,0.01)*65.0,0.0,100.0);
   double overlap=(1.0-f.overlap)*100.0;
   return Clamp(0.30*close_quality+0.25*body+0.25*expansion+0.20*overlap,0.0,100.0);
  }

bool CalculateVWAP(const int shift,double &vwap)
  {
   vwap=0.0; if(shift<1 || shift>=ArraySize(g_rates)) return false;
   datetime start=DayStart(g_rates[shift].time);
   double weighted=0.0,volume=0.0;
   for(int i=shift;i<ArraySize(g_rates);i++)
     {
      if(g_rates[i].time<start) break;
      double v=(double)g_rates[i].tick_volume;
      if(v<=0.0) continue;
      weighted+=(g_rates[i].high+g_rates[i].low+g_rates[i].close)/3.0*v;
      volume+=v;
     }
   if(volume<=0.0) return false;
   vwap=weighted/volume;
   return Positive(vwap);
  }

void CalculateRegime()
  {
   if(ArraySize(g_rates)<InpRegimeLookback+5 || !Positive(g_atr))
     { g_regime=REGIME_INSUFFICIENT_DATA; return; }
   int n=MathMax(5,InpRegimeLookback);
   double path=0.0;
   for(int i=1;i<n;i++) path+=MathAbs(g_rates[i].close-g_rates[i+1].close);
   double net=g_rates[1].close-g_rates[n].close;
   g_regime_efficiency=(path>0.0 ? MathAbs(net)/path : 0.0);
   g_regime_move_atr=MathAbs(net)/g_atr;
   int reference=MathMin(ArraySize(g_rates)-2,MathMax(20,InpRegimeLookback*3));
   double average_range=0.0;
   for(int i=2;i<=reference;i++) average_range+=g_rates[i].high-g_rates[i].low;
   average_range=(reference>1 ? average_range/(reference-1) : 0.0);
   g_atr_ratio=(Positive(average_range) ? g_atr/average_range : 0.0);
   FlowSnapshot recent;
   if(CalculateFlow(1,recent) && recent.range_atr>=InpEventShockATR)
     { g_regime=REGIME_EVENT_SHOCK; return; }
   if(g_regime_efficiency>=InpTrendEfficiencyMin && g_regime_move_atr>=InpTrendMoveATRMin)
      g_regime=(net>0.0 ? REGIME_TREND_UP : REGIME_TREND_DOWN);
   else if(g_regime_efficiency<=InpRangeEfficiencyMax) g_regime=REGIME_RANGE;
   else g_regime=REGIME_TRANSITION;
  }

bool CalculateTimeframeBias(const ENUM_TIMEFRAMES timeframe,TimeframeBias &bias)
  {
   ZeroMemory(bias);
   bias.timeframe=timeframe;
   bias.reason="INSUFFICIENT_DATA";
   int need=MathMax(InpRegimeLookback+2,InpATRPeriod+2);
   MqlRates rates[]; ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,timeframe,1,need,rates);
   if(copied<MathMax(8,MathMax(InpRegimeLookback,InpATRPeriod)+1)) return false;

   int atr_count=MathMin(InpATRPeriod,copied-1);
   double atr_sum=0.0;
   for(int i=0;i<atr_count;i++)
     {
      double previous_close=rates[i+1].close;
      double true_range=MathMax(rates[i].high-rates[i].low,
                                MathMax(MathAbs(rates[i].high-previous_close),MathAbs(rates[i].low-previous_close)));
      atr_sum+=true_range;
     }
   bias.atr=(atr_count>0 ? atr_sum/atr_count : 0.0);
   if(!Positive(bias.atr)) { bias.reason="ATR_UNAVAILABLE"; return false; }

   int n=MathMin(InpRegimeLookback,copied-1);
   double path=0.0;
   for(int i=0;i<n-1;i++) path+=MathAbs(rates[i].close-rates[i+1].close);
   double net=rates[0].close-rates[n-1].close;
   bias.efficiency=(path>0.0 ? MathAbs(net)/path : 0.0);
   bias.move_atr=MathAbs(net)/bias.atr;
   bias.closed_bar_time=rates[0].time;
   bias.direction=(net>0.0 ? DIR_BUY : (net<0.0 ? DIR_SELL : DIR_NONE));
   bias.confirmed=false;

   if(bias.efficiency>=InpTrendEfficiencyMin && bias.move_atr>=InpTrendMoveATRMin)
     {
      bias.regime=(bias.direction==DIR_BUY ? REGIME_TREND_UP : REGIME_TREND_DOWN);
      bias.confirmed=true;
      bias.reason="CONFIRMED_TREND";
     }
   else if(bias.efficiency<=InpRangeEfficiencyMax)
     {
      bias.regime=REGIME_RANGE;
      bias.direction=DIR_NONE;
      bias.reason="RANGE";
     }
   else
     {
      bias.regime=REGIME_TRANSITION;
      bias.reason="TRANSITIONAL_BIAS";
     }
   bias.valid=true;
   return true;
  }

void UpdateMTFContext()
  {
   CalculateTimeframeBias(PERIOD_M1,g_mtf[0]);
   CalculateTimeframeBias(PERIOD_M5,g_mtf[1]);
   CalculateTimeframeBias(PERIOD_M30,g_mtf[2]);
   g_last_mtf_update=TimeTradeServer();
  }

bool FullMTFAligned(const ENUM_NMX_DIRECTION direction)
  {
   if(direction==DIR_NONE) return false;
   for(int i=0;i<3;i++)
      if(!g_mtf[i].valid || !g_mtf[i].confirmed || g_mtf[i].direction!=direction) return false;
   return true;
  }

ENUM_NMX_DIRECTION MTFConsensusDirection(int &aligned)
  {
   int buys=0,sells=0;
   for(int i=0;i<3;i++)
     {
      if(!g_mtf[i].valid || !g_mtf[i].confirmed) continue;
      if(g_mtf[i].direction==DIR_BUY) buys++;
      else if(g_mtf[i].direction==DIR_SELL) sells++;
     }
   aligned=MathMax(buys,sells);
   if(buys>=2 && buys>sells) return DIR_BUY;
   if(sells>=2 && sells>buys) return DIR_SELL;
   return DIR_NONE;
  }

bool IsPivotHigh(const int shift,const int strength)
  {
   if(shift-strength<1 || shift+strength>=ArraySize(g_rates)) return false;
   double p=g_rates[shift].high;
   for(int i=1;i<=strength;i++) if(g_rates[shift-i].high>=p || g_rates[shift+i].high>p) return false;
   return true;
  }

bool IsPivotLow(const int shift,const int strength)
  {
   if(shift-strength<1 || shift+strength>=ArraySize(g_rates)) return false;
   double p=g_rates[shift].low;
   for(int i=1;i<=strength;i++) if(g_rates[shift-i].low<=p || g_rates[shift+i].low<p) return false;
   return true;
  }

int CountLevelTests(const double price,const int side,const int oldest)
  {
   int tests=0; double tolerance=InpEqualToleranceATR*g_atr;
   for(int i=2;i<=oldest && i<ArraySize(g_rates);i++)
     {
      double v=(side>0 ? g_rates[i].high : g_rates[i].low);
      if(MathAbs(v-price)<=tolerance) tests++;
     }
   return tests;
  }

void AddLevel(const ENUM_NMX_LEVEL_TYPE type,const int side,const double price,const int age,const datetime source,const double base_quality)
  {
   if(!Positive(price) || !Positive(g_atr)) return;
   for(int i=0;i<ArraySize(g_levels);i++)
     {
      if(g_levels[i].side==side && MathAbs(g_levels[i].price-price)<=InpMergeToleranceATR*g_atr)
        {
         g_levels[i].price=(g_levels[i].price*g_levels[i].confluences+price)/(g_levels[i].confluences+1);
         g_levels[i].confluences++;
         g_levels[i].quality=Clamp(MathMax(g_levels[i].quality,base_quality)+7.0,0.0,100.0);
         return;
        }
     }
   int n=ArraySize(g_levels); ArrayResize(g_levels,n+1);
   g_levels[n].valid=true; g_levels[n].type=type; g_levels[n].side=side;
   g_levels[n].price=price; g_levels[n].age=age; g_levels[n].source_time=source;
   g_levels[n].tests=CountLevelTests(price,side,MathMin(age,InpLevelLookback));
   g_levels[n].confluences=1;
   g_levels[n].quality=Clamp(base_quality+MathMin(g_levels[n].tests,3)*5.0,0.0,100.0);
  }

bool PreviousPeriod(const ENUM_TIMEFRAMES tf,MqlRates &bar)
  {
   MqlRates one[]; ArraySetAsSeries(one,true);
   if(CopyRates(_Symbol,tf,1,1,one)!=1) return false;
   bar=one[0]; return bar.time>0 && Positive(bar.high) && Positive(bar.low);
  }

void AddPeriodLevels()
  {
   MqlRates d,w;
   if(PreviousPeriod(PERIOD_D1,d))
     {
      AddLevel(LEVEL_PDH,1,d.high,MathMax(2,iBarShift(_Symbol,g_profile.tf,d.time,false)),d.time,88.0);
      AddLevel(LEVEL_PDL,-1,d.low,MathMax(2,iBarShift(_Symbol,g_profile.tf,d.time,false)),d.time,88.0);
     }
   if(PreviousPeriod(PERIOD_W1,w))
     {
      AddLevel(LEVEL_PWH,1,w.high,MathMax(2,iBarShift(_Symbol,g_profile.tf,w.time,false)),w.time,82.0);
      AddLevel(LEVEL_PWL,-1,w.low,MathMax(2,iBarShift(_Symbol,g_profile.tf,w.time,false)),w.time,82.0);
     }
  }

void AddSessionLevels()
  {
   datetime day=DayStart(g_rates[1].time);
   double high=-DBL_MAX,low=DBL_MAX; int hs=-1,ls=-1;
   for(int i=2;i<ArraySize(g_rates);i++)
     {
      if(g_rates[i].time<day) break;
      if(g_rates[i].high>high) { high=g_rates[i].high; hs=i; }
      if(g_rates[i].low<low) { low=g_rates[i].low; ls=i; }
     }
   if(hs>1) AddLevel(LEVEL_SESSION_HIGH,1,high,hs,g_rates[hs].time,72.0);
   if(ls>1) AddLevel(LEVEL_SESSION_LOW,-1,low,ls,g_rates[ls].time,72.0);
  }

void AddSwingLevels()
  {
   int limit=MathMin(InpLevelLookback,ArraySize(g_rates)-InpSwingStrength-1);
   int hc=0,lc=0; double last_high=0.0,last_low=0.0; int last_hs=0,last_ls=0;
   for(int s=InpSwingStrength+2;s<=limit;s++)
     {
      if(hc<InpMaxLevelsPerSide && IsPivotHigh(s,InpSwingStrength))
        {
         AddLevel(LEVEL_SWING_HIGH,1,g_rates[s].high,s,g_rates[s].time,62.0);
         if(Positive(last_high) && MathAbs(last_high-g_rates[s].high)<=InpEqualToleranceATR*g_atr)
            AddLevel(LEVEL_EQUAL_HIGHS,1,(last_high+g_rates[s].high)/2.0,MathMin(s,last_hs),g_rates[s].time,78.0);
         last_high=g_rates[s].high; last_hs=s; hc++;
        }
      if(lc<InpMaxLevelsPerSide && IsPivotLow(s,InpSwingStrength))
        {
         AddLevel(LEVEL_SWING_LOW,-1,g_rates[s].low,s,g_rates[s].time,62.0);
         if(Positive(last_low) && MathAbs(last_low-g_rates[s].low)<=InpEqualToleranceATR*g_atr)
            AddLevel(LEVEL_EQUAL_LOWS,-1,(last_low+g_rates[s].low)/2.0,MathMin(s,last_ls),g_rates[s].time,78.0);
         last_low=g_rates[s].low; last_ls=s; lc++;
        }
      if(hc>=InpMaxLevelsPerSide && lc>=InpMaxLevelsPerSide) break;
     }
  }

bool BuildLevelMap()
  {
   // AUTHORITATIVE LEVEL MAP:
   // rebuilt from the strategy's closed-bar analysis.  The visual layer must
   // follow this map; it must never freeze a historical snapshot of the lines.
   ArrayResize(g_levels,0);
   AddPeriodLevels(); AddSessionLevels(); AddSwingLevels();
   return ArraySize(g_levels)>0;
  }

bool NearestOppositeLevel(const ENUM_NMX_DIRECTION d,const double entry,double &target)
  {
   target=0.0; double best=DBL_MAX;
   for(int i=0;i<ArraySize(g_levels);i++)
     {
      bool ok=(d==DIR_BUY ? g_levels[i].side>0 && g_levels[i].price>entry :
                            g_levels[i].side<0 && g_levels[i].price<entry);
      if(!ok) continue;
      double distance=MathAbs(g_levels[i].price-entry);
      if(distance<best) { best=distance; target=g_levels[i].price; }
     }
   return Positive(target);
  }

double RejectionQuality(const FlowSnapshot &f,const ENUM_NMX_DIRECTION d)
  {
   double wick=(d==DIR_BUY ? f.lower_wick : f.upper_wick);
   double close=(d==DIR_BUY ? f.clv : 1.0-f.clv);
   return Clamp(0.55*Clamp(wick/MathMax(InpMinRejectionWick,0.01)*70.0,0.0,100.0)+0.45*close*100.0,0.0,100.0);
  }

double CandidateScore(const Candidate &c,const double event_quality,const double structure_quality)
  {
   double level=c.level.quality;
   double flow=DisplacementQuality(c.flow,c.direction);
   double volume=(InpUseRelativeTickVolume ? Clamp(c.flow.relative_volume/1.50*100.0,0.0,100.0) : 50.0);
   double vwap_quality=50.0;
   if(InpUseVWAPContext && Positive(g_vwap))
     {
      bool aligned=(c.setup==NMX_SWEEP_REVERSAL ?
                    (c.direction==DIR_BUY ? c.signal_anchor<=g_vwap : c.signal_anchor>=g_vwap) :
                    (c.direction==DIR_BUY ? c.signal_anchor>=g_vwap : c.signal_anchor<=g_vwap));
      vwap_quality=(aligned ? 75.0 : 35.0);
     }
   return Clamp(0.25*level+0.20*event_quality+0.20*flow+0.25*structure_quality+0.05*volume+0.05*vwap_quality,0.0,100.0);
  }

void ResetLiveScoreTelemetry(const bool reset_log_state=true)
  {
   g_live_score=0.0;
   g_live_score_valid=false;
   g_live_structure_ready=false;
   g_live_prearmed=false;
   if(reset_log_state)
     {
      g_prearm_logged=false;
     }
  }

void ResetCandidateScores()
  {
   ResetLiveScoreTelemetry();
  }

int SecondsToCurrentBarClose()
  {
   datetime bar_open=iTime(_Symbol,g_profile.tf,0);
   int duration=PeriodSeconds(g_profile.tf);
   if(bar_open<=0 || duration<=0) return -1;
   long remaining=(long)(bar_open+duration-TimeTradeServer());
   if(remaining<0) remaining=0;
   return (int)remaining;
  }

void UpdateLiveCandidateScore()
  {
   g_live_score=0.0; g_live_score_valid=false; g_live_structure_ready=false; g_live_prearmed=false;
   if(!InpShowLiveScore || !g_candidate.valid || g_state!=ST_WAIT_STRUCTURE) return;
   FlowSnapshot live_flow; MqlRates live_bar;
   if(!CalculateLiveFlow(live_flow,live_bar)) return;
   double buffer=InpStructureBreakBufferATR*g_candidate.atr;
   double signed_penetration=(g_candidate.direction==DIR_BUY ?
                              live_bar.close-g_candidate.micro_break :
                              g_candidate.micro_break-live_bar.close);
   bool shifted=signed_penetration>buffer;
   g_live_structure_ready=shifted && DirectionalDisplacement(live_flow,g_candidate.direction);
   double penetration=(Positive(g_candidate.atr) ? signed_penetration/g_candidate.atr : 0.0);
   double structure_quality=Clamp(70.0+penetration*35.0,0.0,100.0);
   double event_quality=RejectionQuality(live_flow,g_candidate.direction);
   Candidate projected=g_candidate; projected.flow=live_flow; projected.signal_anchor=live_bar.close;
   g_live_score=CandidateScore(projected,event_quality,structure_quality);
   g_live_score_valid=MathIsValidNumber(g_live_score);
   int remaining=SecondsToCurrentBarClose();
   g_live_prearmed=g_live_score_valid && g_live_structure_ready &&
                     g_live_score>=g_profile.minimum_score && remaining>=0 &&
                     remaining<=MathMax(0,InpLiveProjectionSeconds);
   if(g_live_prearmed && !g_prearm_logged)
     {
      g_prearm_logged=true;
      LogEvent("LIVE_SCORE_PROJECTED_PASS",StringFormat("direction=%s|live_score=%.2f|min_score=%.2f|seconds_to_close=%d|execution_before_close=false",
               DirectionText(g_candidate.direction),g_live_score,g_profile.minimum_score,remaining));
     }
  }

void ClearCandidate(const string reason)
  {
   if(g_candidate.valid) LogEvent("CANDIDATE_CLEARED",StringFormat("setup=%s|reason=%s",SetupText(g_candidate.setup),reason));
   TEL6ResetCandidateIdentity();
   ZeroMemory(g_candidate);
   ResetCandidateScores();
  }

int CandidateAgeBars()
  {
   if(!g_candidate.valid || g_candidate.event_time<=0) return 0;
   int age=iBarShift(_Symbol,g_profile.tf,g_candidate.event_time,false);
   return (age<0 ? 0 : MathMax(0,age-1));
  }

bool CandidatePipelineState()
  {
   return g_state==ST_WAIT_STRUCTURE || g_state==ST_WAIT_RETEST ||
          g_state==ST_SIGNAL_READY || g_state==ST_PREFLIGHT ||
          g_state==ST_ORDER_PENDING;
  }

void BlockFreshCandidate(const ENUM_NMX_STATE state,const string gate,const string reason)
  {
   if(g_candidate.valid) ClearCandidate("BLOCKED_"+gate+"_FRESH_SIGNAL_REQUIRED");
   g_blocking_gate=gate;
   g_state=state;
   g_reason=reason;
   string block_key=gate+"|"+reason;
   if(block_key!=g_last_block_key)
     {
      g_last_block_key=block_key;
      TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteSignalDecision("GLOBAL_BLOCK",reason,tel6_intent,false,"FAIL");
     }
  }

bool SetupModeAllows(const ENUM_NMX_SETUP setup)
  {
   if(g_profile.setup_mode==SETUP_REVERSAL) return setup==NMX_SWEEP_REVERSAL;
   if(g_profile.setup_mode==SETUP_CONTINUATION) return setup==NMX_BREAKOUT_CONTINUATION;
   if(setup==NMX_SWEEP_REVERSAL) return g_regime==REGIME_RANGE;
   if(setup==NMX_BREAKOUT_CONTINUATION)
      return g_regime==REGIME_TREND_UP || g_regime==REGIME_TREND_DOWN;
   return false;
  }

bool DetectNewCandidate()
  {
   FlowSnapshot f; if(!CalculateFlow(1,f)) return false;
   double close=g_rates[1].close;
   for(int i=0;i<ArraySize(g_levels);i++)
     {
      MarketLevel level=g_levels[i];
      if(!level.valid || level.quality<InpMinimumLevelQuality) continue;
      if(MathAbs(close-level.price)>InpMaxLevelDistanceATR*g_atr) continue;
      double sweep=(level.side>0 ? g_rates[1].high-level.price : level.price-g_rates[1].low)/g_atr;
      bool close_inside=(level.side>0 ? close<level.price : close>level.price);
      ENUM_NMX_DIRECTION reversal_dir=(level.side>0 ? DIR_SELL : DIR_BUY);
      double wick=(reversal_dir==DIR_BUY ? f.lower_wick : f.upper_wick);
      bool reversal=sweep>=InpSweepMinATR && sweep<=InpSweepMaxATR && close_inside &&
                    wick>=InpMinRejectionWick && SetupModeAllows(NMX_SWEEP_REVERSAL);
      if(reversal)
        {
         ResetCandidateScores();
         ZeroMemory(g_candidate); g_candidate.valid=true; g_candidate.setup=NMX_SWEEP_REVERSAL;
         g_candidate.direction=reversal_dir; g_candidate.level=level; g_candidate.event_time=g_rates[1].time;
         g_candidate.state_time=g_rates[1].time; g_candidate.atr=g_atr; g_candidate.signal_anchor=close;
         g_candidate.extreme=(reversal_dir==DIR_BUY ? g_rates[1].low : g_rates[1].high);
         g_candidate.micro_break=(reversal_dir==DIR_BUY ? MathMax(g_rates[2].high,g_rates[3].high) :
                                                          MathMin(g_rates[2].low,g_rates[3].low));
         g_candidate.retest_level=g_candidate.micro_break; g_candidate.flow=f;
         NearestOppositeLevel(reversal_dir,close,g_candidate.opposite_target);
         g_state=ST_WAIT_STRUCTURE; g_reason="SWEEP_DETECTED";
         TEL6EnsureCandidateIdentity();
         { TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteSignalDecision("CANDIDATE_CREATED","SWEEP_DETECTED",tel6_intent,false,"N/A"); }
         LogEvent("EVENT_DETECTED",StringFormat("setup=REVERSAL|direction=%s|level=%s|price=%.10f|sweep_atr=%.4f|wick=%.3f|clv=%.3f",
                  DirectionText(reversal_dir),LevelText(level.type),level.price,sweep,wick,f.clv));
         return true;
        }
      double break_distance=(level.side>0 ? close-level.price : level.price-close)/g_atr;
      ENUM_NMX_DIRECTION continuation_dir=(level.side>0 ? DIR_BUY : DIR_SELL);
      bool continuation=break_distance>=InpBreakoutBufferATR &&
                        DirectionalDisplacement(f,continuation_dir) && SetupModeAllows(NMX_BREAKOUT_CONTINUATION);
      if(continuation)
        {
         ResetCandidateScores();
         ZeroMemory(g_candidate); g_candidate.valid=true; g_candidate.setup=NMX_BREAKOUT_CONTINUATION;
         g_candidate.direction=continuation_dir; g_candidate.level=level; g_candidate.event_time=g_rates[1].time;
         g_candidate.state_time=g_rates[1].time; g_candidate.atr=g_atr; g_candidate.signal_anchor=close;
         g_candidate.extreme=(continuation_dir==DIR_BUY ? g_rates[1].low : g_rates[1].high);
         g_candidate.micro_break=level.price; g_candidate.retest_level=level.price; g_candidate.flow=f;
         NearestOppositeLevel(continuation_dir,close,g_candidate.opposite_target);
         double event_quality=Clamp(55.0+break_distance*40.0,0.0,100.0);
         g_candidate.score=CandidateScore(g_candidate,event_quality,75.0);
         TEL6EnsureCandidateIdentity();
         if(g_candidate.score<g_profile.minimum_score)
           {
            { TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteSignalDecision("CANDIDATE_REJECTED","SCORE_TOO_LOW",tel6_intent,false,"N/A"); }
            LogEvent("CANDIDATE_REJECTED",StringFormat("reason=SCORE_TOO_LOW|score=%.2f",g_candidate.score));
            ClearCandidate("SCORE_TOO_LOW"); g_state=ST_COOLDOWN; g_reason="SCORE_TOO_LOW"; return false;
           }
         g_state=(g_profile.entry_mode==ENTRY_RETEST ? ST_WAIT_RETEST : ST_SIGNAL_READY);
         g_reason=(g_state==ST_WAIT_RETEST ? "BREAKOUT_ACCEPTED_WAIT_RETEST" : "BREAKOUT_ACCEPTED");
         { TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteSignalDecision("CANDIDATE_CREATED",g_reason,tel6_intent,false,"N/A"); }
         LogEvent("EVENT_DETECTED",StringFormat("setup=CONTINUATION|direction=%s|level=%s|price=%.10f|break_atr=%.4f|score=%.2f",
                  DirectionText(continuation_dir),LevelText(level.type),level.price,break_distance,g_candidate.score));
         return true;
        }
     }
   return false;
  }

bool CandidateInvalidated()
  {
   if(!g_candidate.valid) return true;
   double buffer=InpRetestInvalidationATR*g_candidate.atr;
   if(g_candidate.setup==NMX_SWEEP_REVERSAL)
     {
      if(g_candidate.direction==DIR_BUY && g_rates[1].low<g_candidate.extreme-buffer) return true;
      if(g_candidate.direction==DIR_SELL && g_rates[1].high>g_candidate.extreme+buffer) return true;
     }
   else
     {
      if(g_candidate.direction==DIR_BUY && g_rates[1].close<g_candidate.level.price-buffer) return true;
      if(g_candidate.direction==DIR_SELL && g_rates[1].close>g_candidate.level.price+buffer) return true;
     }
   return false;
  }

void StartCooldown(const int bars)
  {
   g_cooldown_bars=MathMax(0,bars);
   g_cooldown_anchor_bar=iTime(_Symbol,g_profile.tf,0);
  }

void RejectCandidate(const string reason)
  {
   g_reason=reason; g_state=ST_COOLDOWN; StartCooldown(InpCooldownAfterRejectBars);
   { TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteSignalDecision("CANDIDATE_REJECTED",reason,tel6_intent,false,"FAIL"); }
   LogEvent("CANDIDATE_REJECTED",StringFormat("setup=%s|direction=%s|reason=%s|bars=%d|score=%.2f",
            SetupText(g_candidate.setup),DirectionText(g_candidate.direction),reason,g_candidate.bars_waited,g_candidate.score));
   ClearCandidate(reason);
  }

void ProcessStructure()
  {
   if(!g_candidate.valid) return;
   bool was_prearmed=g_prearm_logged;
   int age=iBarShift(_Symbol,g_profile.tf,g_candidate.event_time,false);
   g_candidate.bars_waited=MathMax(0,age-1);
   if(g_candidate.bars_waited>g_profile.max_structure_bars) { RejectCandidate("NO_STRUCTURE_SHIFT"); return; }
   if(CandidateInvalidated()) { RejectCandidate("SETUP_INVALIDATED"); return; }
   FlowSnapshot f; if(!CalculateFlow(1,f)) return;
   double buffer=InpStructureBreakBufferATR*g_candidate.atr;
   bool shifted=(g_candidate.direction==DIR_BUY ? g_rates[1].close>g_candidate.micro_break+buffer :
                                                  g_rates[1].close<g_candidate.micro_break-buffer);
   if(!shifted || !DirectionalDisplacement(f,g_candidate.direction))
     {
      if(was_prearmed)
         LogEvent("LIVE_SCORE_REJECTED_AT_CLOSE",StringFormat("direction=%s|reason=STRUCTURE_NOT_CONFIRMED|closed_time=%s",
                  DirectionText(g_candidate.direction),TimeToString(g_rates[1].time,TIME_DATE|TIME_SECONDS)));
      ResetLiveScoreTelemetry();
      g_reason="WAITING_STRUCTURE_SHIFT"; return;
     }
   g_candidate.flow=f; g_candidate.signal_anchor=g_rates[1].close;
   double penetration=MathAbs(g_rates[1].close-g_candidate.micro_break)/g_candidate.atr;
   double event_quality=RejectionQuality(f,g_candidate.direction);
   double structure_quality=Clamp(70.0+penetration*35.0,0.0,100.0);
   g_candidate.score=CandidateScore(g_candidate,event_quality,structure_quality);
   ResetLiveScoreTelemetry();
   LogEvent("STRUCTURE_SHIFT",StringFormat("direction=%s|level=%.10f|close=%.10f|score=%.2f",
            DirectionText(g_candidate.direction),g_candidate.micro_break,g_rates[1].close,g_candidate.score));
   if(was_prearmed)
      LogEvent(g_candidate.score>=g_profile.minimum_score ? "LIVE_SCORE_CONFIRMED_AT_CLOSE" : "LIVE_SCORE_REJECTED_AT_CLOSE",
               StringFormat("direction=%s|closed_score=%.2f|min_score=%.2f|closed_time=%s",
               DirectionText(g_candidate.direction),g_candidate.score,g_profile.minimum_score,
               TimeToString(g_rates[1].time,TIME_DATE|TIME_SECONDS)));
   if(g_candidate.score<g_profile.minimum_score) { RejectCandidate("SCORE_TOO_LOW"); return; }
   if(g_profile.entry_mode==ENTRY_RETEST)
     {
      g_candidate.retest_level=g_candidate.micro_break;
      g_candidate.state_time=g_rates[1].time; g_state=ST_WAIT_RETEST; g_reason="WAITING_RETEST";
     }
   else
     {
      g_candidate.state_time=g_rates[1].time;
      g_state=ST_SIGNAL_READY; g_reason="SIGNAL_READY";
     }
  }

void ProcessRetest()
  {
   if(!g_candidate.valid) return;
   int age=iBarShift(_Symbol,g_profile.tf,g_candidate.state_time,false);
   g_candidate.bars_waited=MathMax(0,age-1);
   if(g_candidate.bars_waited>g_profile.max_retest_bars) { RejectCandidate("RETEST_EXPIRED"); return; }
   if(CandidateInvalidated()) { RejectCandidate("RETEST_INVALIDATED"); return; }
   double tolerance=InpRetestToleranceATR*g_candidate.atr;
   bool touched=(g_rates[1].low<=g_candidate.retest_level+tolerance &&
                 g_rates[1].high>=g_candidate.retest_level-tolerance);
   FlowSnapshot f; if(!CalculateFlow(1,f)) return;
   bool held=(g_candidate.direction==DIR_BUY ? g_rates[1].close>=g_candidate.retest_level :
                                               g_rates[1].close<=g_candidate.retest_level);
   bool confirmation=(g_candidate.direction==DIR_BUY ? f.clv>=InpRetestConfirmCLV : f.clv<=1.0-InpRetestConfirmCLV);
   if(touched && held && confirmation)
      {
       g_candidate.flow=f; g_candidate.signal_anchor=g_rates[1].close;
       g_candidate.state_time=g_rates[1].time;
       g_state=ST_SIGNAL_READY; g_reason="RETEST_CONFIRMED";
      LogEvent("RETEST_CONFIRMED",StringFormat("direction=%s|level=%.10f|close=%.10f|bars=%d",
               DirectionText(g_candidate.direction),g_candidate.retest_level,g_rates[1].close,g_candidate.bars_waited));
     }
   else g_reason="WAITING_RETEST";
  }

void AppendConfigurationIssue(string &detail,const string issue)
  {
   if(detail!="") detail+=" | ";
   detail+=issue;
  }

bool EvaluateConfiguration(string &reason,string &detail)
  {
   reason=""; detail="";
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double hard_money=(Positive(equity) && Positive(InpHardMaxRiskPercent) ?
                      equity*InpHardMaxRiskPercent/100.0 : 0.0);

   if(InpRiskMode==RISK_FIXED_LOT && !Positive(InpFixedLot))
      AppendConfigurationIssue(detail,"LOTE FIXO INVALIDO");
   if(InpRiskMode==RISK_PERCENT_EQUITY && !Positive(InpRiskPercent))
      AppendConfigurationIssue(detail,"RISCO PERCENTUAL INVALIDO");
   if(InpRiskCapMode!=RISK_CAP_OFF && !Positive(InpHardMaxRiskPercent))
      AppendConfigurationIssue(detail,"HARD MAX DEVE SER MAIOR QUE ZERO");
   if((InpStopMode==STOP_MONEY || InpStopMode==STOP_STRUCTURE_CAPPED_BY_MONEY) && !Positive(InpStopMoney))
      AppendConfigurationIssue(detail,"STOP MONEY INVALIDO");
   if(InpProtectionMode==PROTECTION_DELAYED &&
      (InpDelayedStopM1Minutes<=0 || InpDelayedStopM5Minutes<=0 || InpDelayedStopM30Minutes<=0))
      AppendConfigurationIssue(detail,"TEMPO DE STOP ATRASADO INVALIDO");
   if((InpTargetMode==TARGET_MONEY || InpTargetMode==TARGET_MONEY_THEN_TRAILING) && !Positive(InpTargetMoney))
      AppendConfigurationIssue(detail,"TARGET MONEY INVALIDO");

   // STOP_MONEY with fixed lot requests an exact monetary loss.  It cannot be
   // reconciled silently with a lower hard percentage cap: one of the inputs
   // must be changed explicitly by the operator.
   if(HardRiskEnforcedAtEntry() && InpRiskMode==RISK_FIXED_LOT && InpStopMode==STOP_MONEY &&
      Positive(InpStopMoney) && Positive(hard_money) && InpStopMoney>hard_money+0.01)
      AppendConfigurationIssue(detail,StringFormat("SL $%.2f > HARD $%.2f (%.2f%%)",
                                                    InpStopMoney,hard_money,InpHardMaxRiskPercent));

   if(InpTargetMode==TARGET_TRAILING_ONLY || InpTargetMode==TARGET_MONEY_THEN_TRAILING)
     {
      if(!InpUseTrailing) AppendConfigurationIssue(detail,"MODO TARGET EXIGE TRAILING");
      if(InpTrailingMode==TRAIL_MONEY)
        {
         if(!Positive(InpTrailingActivationMoney)) AppendConfigurationIssue(detail,"ATIVACAO TRAIL MONEY INVALIDA");
         if(!Positive(InpTrailingStepMoney)) AppendConfigurationIssue(detail,"PASSO TRAIL MONEY INVALIDO");
         if(!(InpTrailRatio>0.0 && InpTrailRatio<1.0)) AppendConfigurationIssue(detail,"RAZAO DO TRAIL DEVE FICAR ENTRE 0 E 1");
         if(InpTrailExponent<0.0 || InpTrailExponent>2.0) AppendConfigurationIssue(detail,"EXPOENTE DO TRAIL DEVE FICAR ENTRE 0 E 2");
         if(InpTargetMode==TARGET_MONEY_THEN_TRAILING && Positive(InpTargetMoney) &&
            InpTrailingActivationMoney>=InpTargetMoney)
            AppendConfigurationIssue(detail,StringFormat("TRAIL $%.2f NAO ATIVA ANTES DO TP $%.2f",
                                                          InpTrailingActivationMoney,InpTargetMoney));
        }
     }
   if(InpUseFloatingBreaker && !Positive(InpFloatingLossPositionMoney) && !Positive(InpFloatingLossTotalMoney))
      AppendConfigurationIssue(detail,"DISJUNTOR LIGADO SEM LIMITE POSITIVO");
   if(InpCooldownBars<0 || InpCooldownAfterRejectBars<0) AppendConfigurationIssue(detail,"COOLDOWN NEGATIVO");
   if(!(InpRetestConfirmCLV>0.5 && InpRetestConfirmCLV<1.0)) AppendConfigurationIssue(detail,"CLV DE CONFIRMACAO DO RETESTE DEVE FICAR ENTRE 0.5 E 1");
   if(InpUseDailyProfitTarget && !Positive(InpDailyProfitTargetMoney))
      AppendConfigurationIssue(detail,"META DIARIA MONEY INVALIDA");
   if(InpUseDailyLossMoney && !Positive(InpDailyLossMoney))
      AppendConfigurationIssue(detail,"STOP DIARIO MONEY INVALIDO");
   if(InpUseAdaptiveSpread)
     {
      if(InpSpreadLearningWindow<20) AppendConfigurationIssue(detail,"JANELA DO SPREAD DEVE TER AO MENOS 20 AMOSTRAS");
      if(InpSpreadMinimumSamples<10 || InpSpreadMinimumSamples>InpSpreadLearningWindow)
         AppendConfigurationIssue(detail,"AMOSTRAS MINIMAS DO SPREAD INVALIDAS");
      if(InpSpreadPercentile<50.0 || InpSpreadPercentile>95.0)
         AppendConfigurationIssue(detail,"PERCENTIL DO SPREAD DEVE FICAR ENTRE 50 E 95");
      if(InpSpreadSafetyMultiplier<1.0)
         AppendConfigurationIssue(detail,"FOLGA DO SPREAD DEVE SER MAIOR OU IGUAL A 1");
      if(!Positive(InpSpreadMinimumATRLimit) || InpSpreadMaximumATRLimit<InpSpreadMinimumATRLimit)
         AppendConfigurationIssue(detail,"LIMITES ADAPTATIVOS DE SPREAD INVALIDOS");
      if(InpSpreadWarmupATRLimit<InpSpreadMinimumATRLimit || InpSpreadWarmupATRLimit>InpSpreadMaximumATRLimit)
         AppendConfigurationIssue(detail,"LIMITE INICIAL DO SPREAD FORA DA FAIXA");
     }

   if(detail!="") { reason="CONFIG_INVALIDA"; return false; }
   reason="CONFIG_OK"; return true;
  }

void RefreshConfigurationHealth(const bool emit_log)
  {
   string reason="",detail="";
   bool blocked=!EvaluateConfiguration(reason,detail);
   bool changed=(blocked!=g_config_blocked || reason!=g_config_reason || detail!=g_config_detail);
   g_config_blocked=blocked; g_config_reason=reason; g_config_detail=detail;
   if(blocked)
     {
      g_reason=reason;
      if(changed && emit_log) LogEvent("CONFIGURATION_BLOCKED",StringFormat("reason=%s|detail=%s",reason,detail));
      if(changed && !(bool)MQLInfoInteger(MQL_TESTER)) Alert("NEXUS GUARD PRO: CONFIGURACAO INVALIDA - ENTRADAS BLOQUEADAS | ",detail);
     }
   else if(changed)
     {
      if(g_reason=="CONFIG_INVALIDA") g_reason="CONFIG_OK";
      if(emit_log) LogEvent("CONFIGURATION_READY",StringFormat("risk_safety_state=%s",RiskSafetyStateText()));
     }
  }

void RememberExecutionGate(const string reason,const TradeIntent &intent)
  {
   g_last_gate_reason=reason; g_last_gate_time=TimeTradeServer();
   if(reason=="HARD_MAX_RISK_EXCEEDED")
      g_last_gate_detail=StringFormat("RISCO $%.2f (%.2f%%) > HARD $%.2f (%.2f%%)",
                                     intent.effective_risk_money,intent.effective_risk_percent,
                                     intent.hard_max_risk_money,InpHardMaxRiskPercent);
   else g_last_gate_detail=reason;
  }

string OperationalDetailText()
  {
   if(g_config_blocked) return g_config_detail;
   if(g_last_gate_time>0 && TimeTradeServer()-g_last_gate_time<=24*60*60)
      return StringFormat("ULTIMO BLOQUEIO: %s",g_last_gate_detail);
   return g_reason;
  }

double RiskBudgetMoney()
  {
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpRiskMode==RISK_PERCENT_EQUITY)
     {
      double percentage_budget=equity*g_profile.risk_percent/100.0;
      if(InpStopMode==STOP_MONEY || InpStopMode==STOP_STRUCTURE_CAPPED_BY_MONEY)
         return MathMin(percentage_budget,MathMax(0.0,InpStopMoney));
      return percentage_budget;
     }
   if(InpStopMode==STOP_MONEY || InpStopMode==STOP_STRUCTURE_CAPPED_BY_MONEY)
      return MathMax(0.0,InpStopMoney);
   return 0.0;
  }

bool ProfitAtPrice(const ENUM_ORDER_TYPE type,const double volume,const double entry,const double exit,double &result)
  {
   result=0.0; ResetLastError();
   return OrderCalcProfit(type,_Symbol,volume,entry,exit,result) && MathIsValidNumber(result);
  }

void ResetMoneyStopDiagnostics(const ENUM_ORDER_TYPE type,const double volume,const double entry,const double money)
  {
   ZeroMemory(g_money_stop_diag); g_money_stop_diag.attempted=true; g_money_stop_diag.type=type;
   g_money_stop_diag.volume=volume; g_money_stop_diag.entry=entry; g_money_stop_diag.requested_money=money;
  }

void LogMoneyStopDiagnostics(const string final_result)
  {
   LogEvent("MONEY_STOP_SOLVER",StringFormat(
      "RiskMode=%s|StopMode=%s|Volume=%.4f|Entry=%.10f|ConfiguredStopMoney=%.2f|AuthoritativeStopMoney=%.2f|TickSize=%.10f|Point=%.10f|Digits=%d|VolumeMin=%.4f|VolumeStep=%.4f|ProbePrice=%.10f|ProbeDistanceTicks=%I64d|OrderCalcProfitBool=%s|ProbePnL=%.8f|GetLastError=%d|BracketLow=%I64d|BracketHigh=%I64d|Iterations=%d|CalculatedStopPrice=%.10f|ValidatedLossMoney=%.8f|FinalResult=%s|FailureReason=%s",
      EnumToString(InpRiskMode),EnumToString(InpStopMode),g_money_stop_diag.volume,g_money_stop_diag.entry,
      InpStopMoney,g_money_stop_diag.requested_money,g_symbol.tick_size,g_symbol.point,g_symbol.digits,
      g_symbol.volume_min,g_symbol.volume_step,g_money_stop_diag.probe_price,g_money_stop_diag.probe_ticks,
      BoolText(g_money_stop_diag.probe_calc_ok),g_money_stop_diag.probe_pnl,g_money_stop_diag.last_error,
      g_money_stop_diag.bracket_low_ticks,g_money_stop_diag.bracket_high_ticks,g_money_stop_diag.iterations,
      g_money_stop_diag.calculated_stop,g_money_stop_diag.validated_loss,final_result,g_money_stop_diag.failure_reason));
  }

bool SolveStopPriceForMoney(const ENUM_ORDER_TYPE type,const double volume,const double entry,const double money,double &price)
  {
   price=0.0; ResetMoneyStopDiagnostics(type,volume,entry,money);
   if(!Positive(volume) || !Positive(entry) || !Positive(money) || !Positive(g_symbol.tick_size))
     { g_money_stop_diag.failure_reason="INVALID_INPUT"; LogMoneyStopDiagnostics("FAILED"); return false; }

   const bool buy=(type==ORDER_TYPE_BUY);
   long low_ticks=0,high_ticks=1;
   bool bracket=false;
   double pnl=0.0;
   for(int i=0;i<60;i++)
     {
      double raw=(buy ? entry-high_ticks*g_symbol.tick_size : entry+high_ticks*g_symbol.tick_size);
      if(raw<=0.0) { g_money_stop_diag.failure_reason="PRICE_NON_POSITIVE"; break; }
      double candidate=NormalizePriceSide(raw,!buy);
      ResetLastError(); bool ok=ProfitAtPrice(type,volume,entry,candidate,pnl); int le=GetLastError();
      g_money_stop_diag.probe_price=candidate; g_money_stop_diag.probe_ticks=high_ticks;
      g_money_stop_diag.probe_calc_ok=ok; g_money_stop_diag.probe_pnl=pnl; g_money_stop_diag.last_error=le; g_money_stop_diag.iterations++;
      if(ok && pnl<0.0 && MathAbs(pnl)+1e-8>=money)
        { bracket=true; break; }
      if(ok && pnl<0.0) low_ticks=high_ticks;
      if(high_ticks>1000000000/2) { g_money_stop_diag.failure_reason="BRACKET_LIMIT"; break; }
      high_ticks*=2;
     }
   if(!bracket)
     { if(g_money_stop_diag.failure_reason=="") g_money_stop_diag.failure_reason="STOP_MONEY_BRACKET_NOT_FOUND"; LogMoneyStopDiagnostics("FAILED"); return false; }

   g_money_stop_diag.bracket_low_ticks=low_ticks;
   g_money_stop_diag.bracket_high_ticks=high_ticks;
   while(high_ticks-low_ticks>1 && g_money_stop_diag.iterations<100)
     {
      long mid=low_ticks+(high_ticks-low_ticks)/2;
      double raw=(buy ? entry-mid*g_symbol.tick_size : entry+mid*g_symbol.tick_size);
      double candidate=NormalizePriceSide(raw,!buy);
      ResetLastError(); bool ok=ProfitAtPrice(type,volume,entry,candidate,pnl); int le=GetLastError();
      g_money_stop_diag.probe_price=candidate; g_money_stop_diag.probe_ticks=mid;
      g_money_stop_diag.probe_calc_ok=ok; g_money_stop_diag.probe_pnl=pnl; g_money_stop_diag.last_error=le; g_money_stop_diag.iterations++;
      if(!ok)
        { g_money_stop_diag.failure_reason="ORDER_CALC_PROFIT_FAILED_REFINEMENT"; LogMoneyStopDiagnostics("FAILED"); return false; }
      if(pnl<0.0 && MathAbs(pnl)+1e-8>=money) high_ticks=mid; else low_ticks=mid;
     }

   double raw=(buy ? entry-high_ticks*g_symbol.tick_size : entry+high_ticks*g_symbol.tick_size);
   double final_price=NormalizePriceSide(raw,!buy);
   ResetLastError(); bool final_ok=ProfitAtPrice(type,volume,entry,final_price,pnl); int final_err=GetLastError();
   g_money_stop_diag.probe_price=final_price; g_money_stop_diag.probe_ticks=high_ticks;
   g_money_stop_diag.probe_calc_ok=final_ok; g_money_stop_diag.probe_pnl=pnl; g_money_stop_diag.last_error=final_err;
   g_money_stop_diag.calculated_stop=final_price; g_money_stop_diag.validated_loss=(final_ok && pnl<0.0 ? MathAbs(pnl) : 0.0);
   if(!final_ok || pnl>=0.0 || g_money_stop_diag.validated_loss+1e-8<money || !Positive(final_price))
     { g_money_stop_diag.failure_reason="FINAL_VALIDATION_FAILED"; LogMoneyStopDiagnostics("FAILED"); return false; }
   price=final_price; g_money_stop_diag.success=true; g_money_stop_diag.failure_reason=""; LogMoneyStopDiagnostics("SUCCESS"); return true;
  }


void ResetMoneyTargetDiagnostics(const ENUM_ORDER_TYPE type,const double volume,const double entry,const double money)
  {
   ZeroMemory(g_money_target_diag);
   g_money_target_diag.attempted=true;
   g_money_target_diag.type=type;
   g_money_target_diag.volume=volume;
   g_money_target_diag.entry=entry;
   g_money_target_diag.configured_money=InpTargetMoney;
   g_money_target_diag.authoritative_money=money;
  }

void LogMoneyTargetDiagnostics(const string final_result)
  {
   LogEvent("MONEY_TARGET_SOLVER",StringFormat(
      "Direction=%s|Volume=%.4f|EntryPrice=%.10f|ConfiguredTargetMoney=%.2f|AuthoritativeTargetMoney=%.2f|TickSize=%.10f|Point=%.10f|Digits=%d|VolumeMin=%.4f|VolumeStep=%.4f|ProbePrice=%.10f|ProbeDistanceTicks=%I64d|OrderCalcProfitBool=%s|ProbePnL=%.8f|GetLastError=%d|BracketLow=%I64d|BracketHigh=%I64d|Iterations=%d|CalculatedTargetPrice=%.10f|ValidatedProfitMoney=%.8f|ToleranceMoney=%.8f|FinalResult=%s|FailureReason=%s",
      g_money_target_diag.type==ORDER_TYPE_BUY ? "BUY" : (g_money_target_diag.type==ORDER_TYPE_SELL ? "SELL" : "UNKNOWN"),
      g_money_target_diag.volume,g_money_target_diag.entry,g_money_target_diag.configured_money,
      g_money_target_diag.authoritative_money,g_symbol.tick_size,g_symbol.point,g_symbol.digits,
      g_symbol.volume_min,g_symbol.volume_step,g_money_target_diag.probe_price,g_money_target_diag.probe_ticks,
      BoolText(g_money_target_diag.probe_calc_ok),g_money_target_diag.probe_pnl,g_money_target_diag.last_error,
      g_money_target_diag.bracket_low_ticks,g_money_target_diag.bracket_high_ticks,g_money_target_diag.iterations,
      g_money_target_diag.calculated_target,g_money_target_diag.validated_profit,g_money_target_diag.tolerance_money,
      final_result,g_money_target_diag.failure_reason));
  }

bool SolveTargetPriceForMoney(const ENUM_ORDER_TYPE type,const double volume,const double entry,const double money,double &price)
  {
   price=0.0;
   ResetMoneyTargetDiagnostics(type,volume,entry,money);

   if(!Positive(money))
     { g_money_target_diag.failure_reason="INVALID_TARGET_MONEY"; LogMoneyTargetDiagnostics("FAILED"); return false; }
   if(!Positive(volume))
     { g_money_target_diag.failure_reason="INVALID_VOLUME"; LogMoneyTargetDiagnostics("FAILED"); return false; }
   if(!Positive(entry))
     { g_money_target_diag.failure_reason="INVALID_ENTRY_PRICE"; LogMoneyTargetDiagnostics("FAILED"); return false; }
   if(!g_symbol.valid || !Positive(g_symbol.tick_size) || g_symbol.digits<0)
     { g_money_target_diag.failure_reason="SYMBOL_PROPERTIES_UNAVAILABLE"; LogMoneyTargetDiagnostics("FAILED"); return false; }
   if(type!=ORDER_TYPE_BUY && type!=ORDER_TYPE_SELL)
     { g_money_target_diag.failure_reason="TARGET_DIRECTION_INVALID"; LogMoneyTargetDiagnostics("FAILED"); return false; }

   const bool buy=(type==ORDER_TYPE_BUY);
   long low_ticks=0,high_ticks=1;
   bool bracket=false;
   double pnl=0.0,low_pnl=0.0,high_pnl=0.0;

   for(int i=0;i<60;i++)
     {
      double raw=(buy ? entry+high_ticks*g_symbol.tick_size : entry-high_ticks*g_symbol.tick_size);
      if(raw<=0.0) { g_money_target_diag.failure_reason="TARGET_DIRECTION_INVALID"; break; }

      double candidate=NormalizePriceSide(raw,buy);
      if(!Positive(candidate) || (buy && candidate<=entry) || (!buy && candidate>=entry))
        { g_money_target_diag.failure_reason="TARGET_NORMALIZATION_FAILED"; break; }

      ResetLastError();
      bool ok=ProfitAtPrice(type,volume,entry,candidate,pnl);
      int le=GetLastError();
      g_money_target_diag.probe_price=candidate;
      g_money_target_diag.probe_ticks=high_ticks;
      g_money_target_diag.probe_calc_ok=ok;
      g_money_target_diag.probe_pnl=pnl;
      g_money_target_diag.last_error=le;
      g_money_target_diag.iterations++;

      if(!ok || !MathIsValidNumber(pnl))
        { g_money_target_diag.failure_reason="ORDERCALCPROFIT_FAILED"; break; }

      if(pnl>0.0 && pnl+1e-8>=money)
        { bracket=true; high_pnl=pnl; break; }

      if(pnl>0.0) { low_ticks=high_ticks; low_pnl=pnl; }
      if(high_ticks>1000000000/2)
        { g_money_target_diag.failure_reason="BRACKET_NOT_FOUND"; break; }
      high_ticks*=2;
     }

   if(!bracket)
     {
      if(g_money_target_diag.failure_reason=="") g_money_target_diag.failure_reason="BRACKET_NOT_FOUND";
      LogMoneyTargetDiagnostics("FAILED");
      return false;
     }

   g_money_target_diag.bracket_low_ticks=low_ticks;
   g_money_target_diag.bracket_high_ticks=high_ticks;

   while(high_ticks-low_ticks>1 && g_money_target_diag.iterations<100)
     {
      long mid=low_ticks+(high_ticks-low_ticks)/2;
      double raw=(buy ? entry+mid*g_symbol.tick_size : entry-mid*g_symbol.tick_size);
      double candidate=NormalizePriceSide(raw,buy);
      if(!Positive(candidate) || (buy && candidate<=entry) || (!buy && candidate>=entry))
        {
         g_money_target_diag.failure_reason="TARGET_NORMALIZATION_FAILED";
         LogMoneyTargetDiagnostics("FAILED");
         return false;
        }

      ResetLastError();
      bool ok=ProfitAtPrice(type,volume,entry,candidate,pnl);
      int le=GetLastError();
      g_money_target_diag.probe_price=candidate;
      g_money_target_diag.probe_ticks=mid;
      g_money_target_diag.probe_calc_ok=ok;
      g_money_target_diag.probe_pnl=pnl;
      g_money_target_diag.last_error=le;
      g_money_target_diag.iterations++;

      if(!ok || !MathIsValidNumber(pnl))
        {
         g_money_target_diag.failure_reason="ORDERCALCPROFIT_FAILED";
         LogMoneyTargetDiagnostics("FAILED");
         return false;
        }

      if(pnl>0.0 && pnl+1e-8>=money)
        { high_ticks=mid; high_pnl=pnl; }
      else
        { low_ticks=mid; low_pnl=MathMax(0.0,pnl); }
     }

   if(high_ticks-low_ticks>1)
     {
      g_money_target_diag.failure_reason="SOLVER_ITERATION_LIMIT";
      LogMoneyTargetDiagnostics("FAILED");
      return false;
     }

   double raw=(buy ? entry+high_ticks*g_symbol.tick_size : entry-high_ticks*g_symbol.tick_size);
   double final_price=NormalizePriceSide(raw,buy);
   if(!Positive(final_price) || (buy && final_price<=entry) || (!buy && final_price>=entry))
     {
      g_money_target_diag.failure_reason="TARGET_DIRECTION_INVALID";
      LogMoneyTargetDiagnostics("FAILED");
      return false;
     }

   ResetLastError();
   bool final_ok=ProfitAtPrice(type,volume,entry,final_price,pnl);
   int final_err=GetLastError();
   g_money_target_diag.probe_price=final_price;
   g_money_target_diag.probe_ticks=high_ticks;
   g_money_target_diag.probe_calc_ok=final_ok;
   g_money_target_diag.probe_pnl=pnl;
   g_money_target_diag.last_error=final_err;
   g_money_target_diag.calculated_target=final_price;
   g_money_target_diag.validated_profit=(final_ok && pnl>0.0 ? pnl : 0.0);
   g_money_target_diag.tolerance_money=MathMax(0.01,MathAbs(high_pnl-low_pnl)+1e-8);

   if(!final_ok || !MathIsValidNumber(pnl))
     {
      g_money_target_diag.failure_reason="ORDERCALCPROFIT_FAILED";
      LogMoneyTargetDiagnostics("FAILED");
      return false;
     }

   if(g_money_target_diag.validated_profit+1e-8<money ||
      g_money_target_diag.validated_profit>money+g_money_target_diag.tolerance_money+1e-8)
     {
      g_money_target_diag.failure_reason="TARGET_PROFIT_OUTSIDE_TOLERANCE";
      LogMoneyTargetDiagnostics("FAILED");
      return false;
     }

   price=final_price;
   g_money_target_diag.success=true;
   g_money_target_diag.failure_reason="";
   LogMoneyTargetDiagnostics("SUCCESS");
   return true;
  }

bool PriceForMoney(const ENUM_ORDER_TYPE type,const double volume,const double entry,const double money,const bool favorable,double &price)
  {
   price=0.0; if(!Positive(volume) || !Positive(entry) || !MathIsValidNumber(money)) return false;
   double probe=(type==ORDER_TYPE_BUY ? entry+g_symbol.tick_size : entry-g_symbol.tick_size);
   if(!favorable) probe=(type==ORDER_TYPE_BUY ? entry-g_symbol.tick_size : entry+g_symbol.tick_size);
   double per_tick=0.0;
   if(!ProfitAtPrice(type,volume,entry,probe,per_tick) || MathAbs(per_tick)<=0.0) return false;
   double ticks=MathCeil(MathAbs(money)/MathAbs(per_tick)-1e-10);
   ticks=MathMax(1.0,ticks);
   double sign=(type==ORDER_TYPE_BUY ? 1.0 : -1.0);
   if(!favorable) sign=-sign;
   price=NormalizePriceSide(entry+sign*ticks*g_symbol.tick_size,sign>0.0);
   return Positive(price);
  }

bool SizeForStop(const ENUM_ORDER_TYPE type,const double entry,const double stop,const double budget,double &calculated,double &executable,double &effective_loss,string &reason)
  {
   calculated=0.0; executable=0.0; effective_loss=0.0;
   double reference=NormalizeVolumeDown(MathMin(1.0,g_symbol.volume_max));
   if(!Positive(reference)) reference=g_symbol.volume_min;
   double loss=0.0;
   if(!ProfitAtPrice(type,reference,entry,stop,loss) || MathAbs(loss)<=0.0)
     { reason="SIZING_ORDER_CALC_PROFIT_FAILED"; return false; }
   double loss_per_lot=MathAbs(loss)/reference;
   calculated=(InpRiskMode==RISK_FIXED_LOT ? InpFixedLot : budget/loss_per_lot);
   executable=NormalizeVolumeDown(calculated);
   if(!Positive(executable)) { reason="MIN_VOLUME_EXCEEDS_MONEY_RISK"; return false; }
   if(!ProfitAtPrice(type,executable,entry,stop,loss)) { reason="EFFECTIVE_RISK_CALC_FAILED"; return false; }
   effective_loss=MathAbs(loss);
   if(Positive(budget) && effective_loss>budget+MathMax(0.01,budget*0.01))
     { reason="NORMALIZED_VOLUME_EXCEEDS_RISK"; executable=0.0; return false; }
   return true;
  }

bool TechnicalStop(const Candidate &c,const double entry,double &stop)
  {
   double buffer=MathMax(InpStopBufferATR*c.atr,InpStopBufferTicks*g_symbol.tick_size);
   if(InpStopMode==STOP_ATR)
      stop=(c.direction==DIR_BUY ? entry-InpStopATR*c.atr : entry+InpStopATR*c.atr);
   else
      stop=(c.direction==DIR_BUY ? c.extreme-buffer : c.extreme+buffer);
   stop=NormalizePriceSide(stop,c.direction==DIR_SELL);
   return (c.direction==DIR_BUY ? stop<entry : stop>entry) && Positive(stop);
  }

bool CalculateIntent(const Candidate &c,TradeIntent &intent,string &reason)
  {
   ZeroMemory(intent); MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick) || !Positive(tick.ask) || !Positive(tick.bid))
     { reason="INVALID_LIVE_PRICE"; return false; }
   intent.direction=c.direction; intent.setup=c.setup; intent.signal_anchor=c.signal_anchor;
   intent.entry=NormalizePrice(c.direction==DIR_BUY ? tick.ask : tick.bid);
   intent.drift_atr=(Positive(c.atr) ? MathAbs(intent.entry-c.signal_anchor)/c.atr : DBL_MAX);
   if(!MathIsValidNumber(intent.drift_atr) || intent.drift_atr>InpMaxEntryDriftATRRatio)
     { reason="ENTRY_DRIFT_TOO_HIGH"; return false; }
   double technical_stop=0.0;
   if(!TechnicalStop(c,intent.entry,technical_stop)) { reason="INVALID_TECHNICAL_STOP"; return false; }
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double budget=RiskBudgetMoney();
   intent.requested_stop_money=InpStopMoney;
   intent.hard_max_risk_money=(Positive(equity) ? equity*InpHardMaxRiskPercent/100.0 : 0.0);
   if(InpRiskMode==RISK_PERCENT_EQUITY && InpStopMode!=STOP_MONEY && InpStopMode!=STOP_STRUCTURE_CAPPED_BY_MONEY)
      budget=AccountInfoDouble(ACCOUNT_EQUITY)*g_profile.risk_percent/100.0;
   if(!Positive(budget) && InpRiskMode==RISK_PERCENT_EQUITY) { reason="INVALID_RISK_BUDGET"; return false; }
   ENUM_ORDER_TYPE type=(c.direction==DIR_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);

   // First size against the structural/ATR stop. Pure money-stop mode then
   // converts its money cap into a broker-valid stop for the normalized lot.
   double calculated=0.0,volume=0.0,effective=0.0;
   if(InpStopMode==STOP_MONEY && InpRiskMode==RISK_FIXED_LOT)
     {
      calculated=InpFixedLot; volume=NormalizeVolumeDown(calculated);
      if(!Positive(volume)) { reason="INVALID_FIXED_VOLUME"; return false; }
     }
   else if(!SizeForStop(type,intent.entry,technical_stop,budget,calculated,volume,effective,reason)) return false;
   intent.calculated_volume=calculated; intent.volume=volume; intent.stop=technical_stop;
   if(InpStopMode==STOP_MONEY)
     {
      // In percentage mode the percentage budget may be tighter than the
      // requested money stop.  The smaller amount is authoritative; otherwise
      // selecting STOP_MONEY silently ignored InpRiskPercent.
      double effective_stop_money=(InpRiskMode==RISK_PERCENT_EQUITY ? budget : InpStopMoney);
      if(!SolveStopPriceForMoney(type,volume,intent.entry,effective_stop_money,intent.stop))
        { reason="STOP_MONEY_SOLVER_FAILED"; return false; }
      double money_loss=0.0;
      if(!ProfitAtPrice(type,volume,intent.entry,intent.stop,money_loss))
        { reason="STOP_MONEY_POSTVALIDATION_FAILED"; return false; }
      effective=MathAbs(money_loss);
     }
   intent.risk_money=budget; intent.effective_risk_money=effective;
   intent.effective_risk_percent=(Positive(equity) ? effective/equity*100.0 : 100.0);
   if(HardRiskEnforcedAtEntry() && intent.effective_risk_percent>InpHardMaxRiskPercent+1e-8)
     { reason="HARD_MAX_RISK_EXCEEDED"; return false; }

   double stop_distance=MathAbs(intent.entry-intent.stop);
   double r_target=(c.direction==DIR_BUY ? intent.entry+InpTargetR*stop_distance : intent.entry-InpTargetR*stop_distance);
   if(InpTargetMode==TARGET_NONE || InpTargetMode==TARGET_TRAILING_ONLY) intent.target=0.0;
   else if(InpTargetMode==TARGET_FIXED_R) intent.target=r_target;
   else if(InpTargetMode==TARGET_MONEY || InpTargetMode==TARGET_MONEY_THEN_TRAILING)
     {
      if(!SolveTargetPriceForMoney(type,volume,intent.entry,InpTargetMoney,intent.target))
        {
         reason="TARGET_MONEY_SOLVER_FAILED_"+g_money_target_diag.failure_reason;
         return false;
        }
     }
   else if(InpTargetMode==TARGET_OPPOSITE_LEVEL)
     {
      if(!Positive(c.opposite_target)) { reason="NO_OPPOSITE_LEVEL_TARGET"; return false; }
      intent.target=c.opposite_target;
     }
   else
     {
      if(Positive(c.opposite_target))
         intent.target=(c.direction==DIR_BUY ? MathMin(r_target,c.opposite_target) : MathMax(r_target,c.opposite_target));
      else intent.target=r_target;
     }
   if(Positive(intent.target))
     {
      intent.target=NormalizePriceSide(intent.target,c.direction==DIR_BUY);
      if(c.direction==DIR_BUY && intent.target<=intent.entry) { reason="INVALID_BUY_TARGET"; return false; }
      if(c.direction==DIR_SELL && intent.target>=intent.entry) { reason="INVALID_SELL_TARGET"; return false; }
      intent.expected_r=MathAbs(intent.target-intent.entry)/stop_distance;
      // MONEY_THEN_TRAILING intentionally permits a small initial broker TP:
      // when the configured trailing activates before that TP, it removes the
      // TP and manages the runner. Other target modes must satisfy fixed R:R.
      if(intent.expected_r<InpMinimumExpectedR && InpTargetMode!=TARGET_MONEY_THEN_TRAILING)
        { reason="RR_TOO_LOW"; return false; }
      if(!ProfitAtPrice(type,volume,intent.entry,intent.target,intent.expected_profit) || intent.expected_profit<=0.0)
        { reason="TARGET_PROFIT_ESTIMATE_FAILED"; return false; }
     }
   else
     {
      intent.expected_r=0.0;
      intent.expected_profit=0.0;
     }
   intent.tag=StringFormat("NMX_%s_%s_%s",TimeframeShort(g_profile.tf),
                           c.setup==NMX_SWEEP_REVERSAL ? "REV" : "CONT",
                           c.direction==DIR_BUY ? "B" : "S");
   intent.valid=true; reason="INTENT_READY"; return true;
  }

bool StopsRespectBroker(const TradeIntent &i,string &reason)
  {
   double minimum=(double)MathMax(g_symbol.stops_level,g_symbol.freeze_level)*g_symbol.point;
   if(InitialBrokerStopEnabled() && MathAbs(i.entry-i.stop)+1e-12<minimum)
     { reason="STOP_BELOW_BROKER_MINIMUM"; return false; }
   if(Positive(i.target) && MathAbs(i.target-i.entry)+1e-12<minimum)
     { reason="TARGET_BELOW_BROKER_MINIMUM"; return false; }
   return true;
  }





































bool ImportanceBlocks(const ENUM_CALENDAR_EVENT_IMPORTANCE importance)
  {
   if(InpNewsImportance==NEWS_HIGH_ONLY) return importance==CALENDAR_IMPORTANCE_HIGH;
   if(InpNewsImportance==NEWS_MODERATE_OR_HIGHER)
      return importance==CALENDAR_IMPORTANCE_MODERATE || importance==CALENDAR_IMPORTANCE_HIGH;
   return importance==CALENDAR_IMPORTANCE_LOW || importance==CALENDAR_IMPORTANCE_MODERATE || importance==CALENDAR_IMPORTANCE_HIGH;
  }

bool CurrencyNews(const string currency,const datetime from,const datetime to,bool &unavailable,string &description,datetime &nearest)
  {
   unavailable=false; description=""; nearest=0;
   if(currency=="" || currency=="XAU" || currency=="XAG") return false;
   MqlCalendarValue values[]; ResetLastError();
   int count=CalendarValueHistory(values,from,to,NULL,currency);
   if(count<0) { unavailable=true; description=StringFormat("%s ERROR %d",currency,GetLastError()); return false; }
   datetime now=TimeTradeServer();
   for(int i=0;i<count;i++)
     {
      MqlCalendarEvent event;
      if(!CalendarEventById(values[i].event_id,event)) { unavailable=true; continue; }
      if(!ImportanceBlocks(event.importance)) continue;
      if(nearest==0 || MathAbs((long)(values[i].time-now))<MathAbs((long)(nearest-now)))
        { nearest=values[i].time; description=StringFormat("%s %s",currency,event.name); }
     }
   return nearest>0;
  }

void RelevantCurrencies(string &a,string &b)
  {
   a=g_symbol.base_currency; b=g_symbol.profit_currency;
   string symbol=_Symbol; StringToUpper(symbol);
   if(InpXAUUsesUSDNews && (StringFind(symbol,"XAU")>=0 || StringFind(symbol,"GOLD")>=0))
     { a="USD"; b=""; }
  }

bool CheckNews(string &reason)
  {
   reason="";
   if(!InpUseNewsFilter) { g_news_status="DISABLED"; return true; }
   datetime now=TimeTradeServer();
   datetime from=now-InpNewsMinutesAfter*60;
   datetime to=now+InpNewsMinutesBefore*60;
   string a,b; RelevantCurrencies(a,b);
   bool ua=false,ub=false; string da="",db=""; datetime ta=0,tb=0;
   bool ba=CurrencyNews(a,from,to,ua,da,ta);
   bool bb=false; if(b!="" && b!=a) bb=CurrencyNews(b,from,to,ub,db,tb);
   g_next_news_time=0; g_next_news_name="";
   if(ba || bb)
     {
      if(ba && (!bb || MathAbs((long)(ta-now))<=MathAbs((long)(tb-now))))
        { g_next_news_time=ta; g_next_news_name=da; }
      else { g_next_news_time=tb; g_next_news_name=db; }
      g_news_status=(g_next_news_time>=now ? "PRE-BLACKOUT" : "POST-EVENT");
      reason="NEWS_BLACKOUT"; return false;
     }
   if(ua || ub)
     {
      bool tester_bypass=((bool)MQLInfoInteger(MQL_TESTER) && InpTesterAllowWithoutCalendar);
      g_news_status=(tester_bypass ? "TESTER_CALENDAR_BYPASS" : "CALENDAR_UNAVAILABLE");
      // Historical tests often do not expose the broker economic calendar.
      // Bypass only inside Strategy Tester and keep FAIL_CLOSED intact on demo/real charts.
      if(InpNewsFailMode==NEWS_FAIL_CLOSED && !tester_bypass)
        { reason="CALENDAR_UNAVAILABLE"; return false; }
     }
   else g_news_status="CLEAR";
   // Separate, wider query supplies the next-event countdown for the panel.
   datetime future_to=now+24*60*60; bool ufa=false,ufb=false; string dfa="",dfb=""; datetime tfa=0,tfb=0;
   bool fa=CurrencyNews(a,now,future_to,ufa,dfa,tfa);
   bool fb=false; if(b!="" && b!=a) fb=CurrencyNews(b,now,future_to,ufb,dfb,tfb);
   if(fa || fb)
     {
      if(fa && (!fb || tfa<=tfb)) { g_next_news_time=tfa; g_next_news_name=dfa; }
      else { g_next_news_time=tfb; g_next_news_name=dfb; }
     }
   return true;
  }

int CountOwnPositions()
  {
   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i); if(ticket==0) continue;
      if(IsNexusMagic(PositionGetInteger(POSITION_MAGIC))) count++;
     }
   return count;
  }

bool HasOwnPositionForSymbol(const string symbol)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i); if(ticket==0) continue;
      if(!IsNexusMagic(PositionGetInteger(POSITION_MAGIC))) continue;
      if(PositionGetString(POSITION_SYMBOL)==symbol) return true;
     }
   return false;
  }

bool CurrencyExposureAllowed(string &reason)
  {
   string a,b; RelevantCurrencies(a,b); int count_a=0,count_b=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i); if(ticket==0 || !IsNexusMagic(PositionGetInteger(POSITION_MAGIC))) continue;
      string symbol=PositionGetString(POSITION_SYMBOL);
      string base=SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);
      string profit=SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT);
      if(a!="" && (base==a || profit==a)) count_a++;
      if(b!="" && (base==b || profit==b)) count_b++;
     }
   if((a!="" && count_a>=InpMaxCurrencyExposures) || (b!="" && count_b>=InpMaxCurrencyExposures))
     { reason="CORRELATED_CURRENCY_EXPOSURE_LIMIT"; return false; }
   return true;
  }

bool PositionOwnerCached(const ulong pid,bool &owned)
  {
   for(int i=ArraySize(g_owner_pids)-1;i>=0;i--)
      if(g_owner_pids[i]==pid) { owned=g_owner_flags[i]; return true; }
   owned=false; return false;
  }

// Uma posicao pertence ao Nexus quando o deal de ENTRADA tem magic Nexus. O deal de saida
// de um fechamento manual/stop-out pode vir com magic 0 e nao pode ficar fora do risco diario.
// ATENCAO: altera a selecao de historico (HistorySelectByPosition).
bool PositionOwnedByNexus(const ulong pid)
  {
   bool owned=false;
   if(pid==0) return false;
   if(PositionOwnerCached(pid,owned)) return owned;
   if(HistorySelectByPosition(pid))
     {
      for(int i=0;i<HistoryDealsTotal();i++)
        {
         ulong deal=HistoryDealGetTicket(i); if(deal==0) continue;
         if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal,DEAL_ENTRY)==DEAL_ENTRY_IN &&
            IsNexusMagic(HistoryDealGetInteger(deal,DEAL_MAGIC)))
           { owned=true; break; }
        }
     }
   int n=ArraySize(g_owner_pids);
   if(n>=1024) { ArrayResize(g_owner_pids,0); ArrayResize(g_owner_flags,0); n=0; }
   ArrayResize(g_owner_pids,n+1); ArrayResize(g_owner_flags,n+1);
   g_owner_pids[n]=pid; g_owner_flags[n]=owned;
   return owned;
  }

void CalculateHistoryStats()
  {
   ZeroMemory(g_stats);
   datetime now=TimeTradeServer(),from=DayStart(now);
   string start_key=FamilyStateKey("DAY_START");
   string equity_key=FamilyStateKey("DAY_EQUITY");
   string account_peak_key=FamilyStateKey("PEAK_EQUITY");
   string magic_peak_key=FamilyStateKey("PEAK_EQUITY_NEXUS_MAGIC");
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);

   string last_equity_key=FamilyStateKey("LAST_EQUITY");
   string flow_key=FamilyStateKey("BALANCE_FLOW_APPLIED");
   double last_equity=(GlobalVariableCheck(last_equity_key) ? GlobalVariableGet(last_equity_key) : 0.0);
   bool equity_jump=(Positive(last_equity) && Positive(equity) && MathAbs(equity-last_equity)/last_equity>0.20);
   GlobalVariableSet(last_equity_key,equity);
   bool new_day=(!GlobalVariableCheck(start_key) || (datetime)(long)GlobalVariableGet(start_key)!=from);
   if(equity_jump && !new_day)
      LogEvent("BASELINE_REBASED_EQUITY_JUMP",StringFormat("last_equity=%.2f|equity=%.2f|reason=SALDO_ALTEROU_SEM_NEGOCIO",last_equity,equity));
   if(new_day || equity_jump)
     {
      GlobalVariableSet(start_key,(double)from);
      GlobalVariableSet(equity_key,equity);
      GlobalVariableSet(account_peak_key,equity);
      GlobalVariableSet(magic_peak_key,equity);
      GlobalVariableSet(flow_key,-DBL_MAX);
     }

   g_stats.start_equity=GlobalVariableGet(equity_key);
   if(!Positive(g_stats.start_equity)) g_stats.start_equity=equity;

   // Preserve the legacy account-equity guard path exactly when ACCOUNT is selected.
   double account_peak=(GlobalVariableCheck(account_peak_key) ? GlobalVariableGet(account_peak_key) : equity);
   if(equity>account_peak)
     {
      account_peak=equity;
      GlobalVariableSet(account_peak_key,equity);
     }

   if(!HistorySelect(from,now))
     {
      if(InpEquityGuardScope==EQUITY_GUARD_NEXUS_MAGIC)
        {
         g_stats.blocked=true;
         g_stats.reason="NEXUS_STATS_UNAVAILABLE";
        }
      else
        {
         g_stats.peak_equity=account_peak;
         g_stats.daily_loss_percent=(g_stats.start_equity>0.0 ? MathMax(0.0,(g_stats.start_equity-equity)/g_stats.start_equity*100.0) : 100.0);
         g_stats.drawdown_percent=(account_peak>0.0 ? MathMax(0.0,(account_peak-equity)/account_peak*100.0) : 100.0);
        }
      return;
     }

   // Passo 1: depositos/saques do dia (rebase do baseline) e saidas sem magic Nexus.
   ulong foreign_pids[]; double balance_flow=0.0;
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong deal=HistoryDealGetTicket(i); if(deal==0) continue;
      if((ENUM_DEAL_TYPE)HistoryDealGetInteger(deal,DEAL_TYPE)==DEAL_TYPE_BALANCE)
        { balance_flow+=HistoryDealGetDouble(deal,DEAL_PROFIT); continue; }
      if(IsNexusMagic(HistoryDealGetInteger(deal,DEAL_MAGIC))) continue;
      ENUM_DEAL_ENTRY probe_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal,DEAL_ENTRY);
      if(probe_entry!=DEAL_ENTRY_OUT && probe_entry!=DEAL_ENTRY_OUT_BY && probe_entry!=DEAL_ENTRY_INOUT) continue;
      ulong probe_pid=(ulong)HistoryDealGetInteger(deal,DEAL_POSITION_ID);
      bool probe_owned=false;
      if(PositionOwnerCached(probe_pid,probe_owned)) continue;
      bool listed=false;
      for(int k=0;k<ArraySize(foreign_pids);k++) if(foreign_pids[k]==probe_pid) { listed=true; break; }
      if(!listed) { int fn=ArraySize(foreign_pids); ArrayResize(foreign_pids,fn+1); foreign_pids[fn]=probe_pid; }
     }
   for(int k=0;k<ArraySize(foreign_pids);k++) PositionOwnedByNexus(foreign_pids[k]);
   if(ArraySize(foreign_pids)>0 && !HistorySelect(from,now))
     { g_stats.blocked=true; g_stats.reason="NEXUS_STATS_UNAVAILABLE"; return; }

   double applied_flow=(GlobalVariableCheck(flow_key) ? GlobalVariableGet(flow_key) : -DBL_MAX);
   if(applied_flow<=-DBL_MAX/2.0) GlobalVariableSet(flow_key,balance_flow);
   else if(MathAbs(balance_flow-applied_flow)>0.005)
     {
      double delta=balance_flow-applied_flow;
      GlobalVariableSet(equity_key,GlobalVariableGet(equity_key)+delta);
      GlobalVariableSet(account_peak_key,GlobalVariableGet(account_peak_key)+delta);
      GlobalVariableSet(magic_peak_key,GlobalVariableGet(magic_peak_key)+delta);
      GlobalVariableSet(flow_key,balance_flow);
      g_stats.start_equity+=delta; account_peak+=delta;
      LogEvent("BASELINE_BALANCE_FLOW",StringFormat("delta=%.2f|day_flow=%.2f",delta,balance_flow));
     }

   ulong position_ids[]; double pnls[]; datetime closes[]; bool closed[];
   for(int i=0;i<HistoryDealsTotal();i++)
     {
      ulong deal=HistoryDealGetTicket(i); if(deal==0) continue;
      if(!IsNexusMagic(HistoryDealGetInteger(deal,DEAL_MAGIC)))
        {
         bool deal_owned=false;
         if(!(PositionOwnerCached((ulong)HistoryDealGetInteger(deal,DEAL_POSITION_ID),deal_owned) && deal_owned)) continue;
        }
      ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal,DEAL_ENTRY);
      double profit=HistoryDealGetDouble(deal,DEAL_PROFIT);
      double swap=HistoryDealGetDouble(deal,DEAL_SWAP);
      double commission=HistoryDealGetDouble(deal,DEAL_COMMISSION);
      double fee=HistoryDealGetDouble(deal,DEAL_FEE);
      g_stats.gross+=profit; g_stats.costs-=swap+commission+fee; g_stats.net+=profit+swap+commission+fee;
      ulong pid=(ulong)HistoryDealGetInteger(deal,DEAL_POSITION_ID); int idx=-1;
      for(int n=0;n<ArraySize(position_ids);n++) if(position_ids[n]==pid) { idx=n; break; }
      if(idx<0)
        {
         idx=ArraySize(position_ids); ArrayResize(position_ids,idx+1); ArrayResize(pnls,idx+1);
         ArrayResize(closes,idx+1); ArrayResize(closed,idx+1);
         position_ids[idx]=pid; pnls[idx]=0.0; closes[idx]=0; closed[idx]=false;
        }
      pnls[idx]+=profit+swap+commission+fee;
      if(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY || entry==DEAL_ENTRY_INOUT)
        {
         closed[idx]=true;
         closes[idx]=(datetime)MathMax((long)closes[idx],HistoryDealGetInteger(deal,DEAL_TIME));
        }
     }

   g_stats.trades=0;
   for(int i=0;i<ArraySize(pnls);i++)
     {
      if(!closed[i]) continue;
      g_stats.trades++;
      if(pnls[i]>0.005)
        {
         g_stats.wins++;
         g_stats.realized_profit+=pnls[i];
        }
      else if(pnls[i]<-0.005)
        {
         g_stats.losses++;
         g_stats.realized_loss+=MathAbs(pnls[i]);
        }
      else g_stats.breakeven++;
     }

   bool used[]; ArrayResize(used,ArraySize(pnls)); ArrayInitialize(used,false);
   for(int n=0;n<g_stats.trades;n++)
     {
      int latest=-1; datetime latest_time=0;
      for(int i=0;i<ArraySize(pnls);i++)
         if(closed[i] && !used[i] && (latest<0 || closes[i]>latest_time))
           { latest=i; latest_time=closes[i]; }
      if(latest<0) break; used[latest]=true;
      if(pnls[latest]<-0.005) g_stats.consecutive_losses++; else break;
     }

   if(InpEquityGuardScope==EQUITY_GUARD_NEXUS_MAGIC)
     {
      // Virtual Nexus equity isolates this EA family from P/L produced by other
      // EAs/manual trades on the same account.  The denominator remains the
      // account equity captured at the daily baseline.
      double nexus_day_net=g_stats.net+NexusOwnFloatingNet();
      double nexus_virtual_equity=g_stats.start_equity+nexus_day_net;
      double magic_peak=(GlobalVariableCheck(magic_peak_key) ? GlobalVariableGet(magic_peak_key) : g_stats.start_equity);
      if(!Positive(magic_peak) || magic_peak<g_stats.start_equity) magic_peak=g_stats.start_equity;
      if(nexus_virtual_equity>magic_peak)
        {
         magic_peak=nexus_virtual_equity;
         GlobalVariableSet(magic_peak_key,magic_peak);
        }
      g_stats.peak_equity=magic_peak;
      g_stats.daily_loss_percent=(g_stats.start_equity>0.0 ? MathMax(0.0,-nexus_day_net/g_stats.start_equity*100.0) : 100.0);
      g_stats.drawdown_percent=(magic_peak>0.0 ? MathMax(0.0,(magic_peak-nexus_virtual_equity)/magic_peak*100.0) : 100.0);
     }
   else
     {
      g_stats.peak_equity=account_peak;
      g_stats.daily_loss_percent=(g_stats.start_equity>0.0 ? MathMax(0.0,(g_stats.start_equity-equity)/g_stats.start_equity*100.0) : 100.0);
      g_stats.drawdown_percent=(account_peak>0.0 ? MathMax(0.0,(account_peak-equity)/account_peak*100.0) : 100.0);
     }

   g_stats.blocked=false; g_stats.reason="";
   if(InpUseDailyProfitTarget && g_stats.net>=InpDailyProfitTargetMoney)
     { g_stats.blocked=true; g_stats.reason="DAILY_PROFIT_TARGET"; }
   else if(InpUseDailyLossMoney && g_stats.net<=-InpDailyLossMoney)
     { g_stats.blocked=true; g_stats.reason="DAILY_LOSS_MONEY"; }
   else if(g_stats.daily_loss_percent>=InpMaxDailyLossPercent) { g_stats.blocked=true; g_stats.reason="MAX_DAILY_LOSS"; }
   else if(g_stats.drawdown_percent>=InpMaxDrawdownPercent) { g_stats.blocked=true; g_stats.reason="MAX_EQUITY_DRAWDOWN"; }
   else if(g_stats.trades>=InpMaxTradesPerDay) { g_stats.blocked=true; g_stats.reason="MAX_TRADES_PER_DAY"; }
   else if(g_stats.consecutive_losses>=InpMaxConsecutiveLosses) { g_stats.blocked=true; g_stats.reason="MAX_CONSECUTIVE_LOSSES"; }
  }

bool MarketOpen()
  {
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick) || tick.time<=0 || !Positive(tick.bid) || !Positive(tick.ask)) return false;
   int freshness=MathMax(120,PeriodSeconds(g_profile.tf)*2);
   return (long)(TimeTradeServer()-tick.time)<=freshness;
  }

bool SpreadAllowed()
  {
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick) || !Positive(g_atr)) return false;
   double spread=tick.ask-tick.bid;
   g_last_spread_points=spread/g_symbol.point; g_last_spread_atr=spread/g_atr;
   ObserveAdaptiveSpread(tick);
   double effective_limit=EffectiveSpreadATRLimit();
   if(InpMaxSpreadPoints>0.0 && g_last_spread_points>InpMaxSpreadPoints) return false;
   return g_last_spread_atr<=effective_limit;
  }

bool Preflight(const TradeIntent &intent,MqlTradeRequest &request,MqlTradeCheckResult &check,string &reason)
  {
   g_tel6_preflight_ordercheck_executed=false; g_tel6_preflight_ordercheck_bool=false;
   g_state=ST_PREFLIGHT; LogEvent("PREFLIGHT_START",StringFormat("direction=%s|entry=%.10f|stop=%.10f|target=%.10f|volume=%.4f",
             DirectionText(intent.direction),intent.entry,intent.stop,intent.target,intent.volume));
   RefreshConfigurationHealth(false);
   if(g_config_blocked) { reason=g_config_reason; return false; }
   if(!g_runtime_trading_enabled) { reason="RUNTIME_TRADING_DISABLED"; return false; }
   if(g_entries_paused) { reason="MANUAL_ENTRY_PAUSE"; return false; }
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)) { reason="TERMINAL_DISCONNECTED"; return false; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     { reason="TRADING_PERMISSION_DISABLED"; return false; }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) || !AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     { reason="ACCOUNT_EXPERT_TRADE_DISABLED"; return false; }
   if(!MarketOpen()) { reason="MARKET_CLOSED_OR_STALE_TICK"; return false; }
   if(!SpreadAllowed()) { reason="SPREAD_TOO_WIDE_FOR_ATR"; return false; }
   if(g_stats.blocked) { reason=g_stats.reason; return false; }
   if(InpRequireFullMTFAlignment && !FullMTFAligned(intent.direction))
     { reason="MTF_FULL_ALIGNMENT_REQUIRED"; return false; }
   if(CountOwnPositions()>=InpMaxOpenPositions) { reason="MAX_OPEN_POSITIONS"; return false; }
   if(HasOwnPositionForSymbol(_Symbol)) { reason="SYMBOL_POSITION_ALREADY_OPEN"; return false; }
   if(!CurrencyExposureAllowed(reason)) return false;
   if(!CheckNews(reason)) return false;
   if(!StopsRespectBroker(intent,reason)) return false;
   ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   if(mode==SYMBOL_TRADE_MODE_DISABLED || mode==SYMBOL_TRADE_MODE_CLOSEONLY)
     { reason="SYMBOL_TRADE_MODE_BLOCK"; return false; }
   if(mode==SYMBOL_TRADE_MODE_LONGONLY && intent.direction==DIR_SELL) { reason="SYMBOL_LONG_ONLY"; return false; }
   if(mode==SYMBOL_TRADE_MODE_SHORTONLY && intent.direction==DIR_BUY) { reason="SYMBOL_SHORT_ONLY"; return false; }
   ZeroMemory(request); ZeroMemory(check);
   request.action=TRADE_ACTION_DEAL; request.magic=(ulong)g_magic; request.symbol=_Symbol;
   request.volume=intent.volume; request.type=(intent.direction==DIR_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   request.price=intent.entry;
   request.sl=(InitialBrokerStopEnabled() ? intent.stop : 0.0);
   request.tp=intent.target;
   request.deviation=(ulong)MathMax(0,InpMaxDeviationPoints); request.type_filling=FillingMode(); request.type_time=ORDER_TIME_GTC;
   request.comment=intent.tag;
   ResetLastError();
   g_tel6_preflight_ordercheck_executed=true;
   g_tel6_preflight_ordercheck_bool=OrderCheck(request,check);
   if(!g_tel6_preflight_ordercheck_bool) { reason=StringFormat("ORDER_CHECK_CALL_FAILED_%d",GetLastError()); return false; }
   LogEvent("ORDER_CHECK_RESULT",StringFormat("retcode=%u|comment=%s|balance=%.2f|equity=%.2f|projected_profit=%.2f|margin=%.2f|margin_free=%.2f|margin_level=%.2f|action=%d|order_type=%d|filling=%d|volume=%.4f|price=%.10f|sl=%.10f|tp=%.10f|last_error=%d",
            check.retcode,check.comment,check.balance,check.equity,check.profit,check.margin,
            check.margin_free,check.margin_level,(int)request.action,(int)request.type,(int)request.type_filling,
            request.volume,request.price,request.sl,request.tp,GetLastError()));
   // MqlTradeCheckResult is not MqlTradeResult: the official OrderCheck example
   // reports retcode=0 for a successful check. The boolean return above proves
   // that the check call itself succeeded; OrderSend still supplies the final
   // broker/tester execution retcode and remains fail-closed.
   bool check_accepted=(check.retcode==0 || check.retcode==TRADE_RETCODE_DONE ||
                        check.retcode==TRADE_RETCODE_PLACED);
   if(!check_accepted)
     { reason=StringFormat("ORDER_CHECK_REJECTED_%u",check.retcode); return false; }
   if(check.margin_level>0.0 && check.margin_level<InpMinimumMarginLevel)
     { reason="PROJECTED_MARGIN_LEVEL_TOO_LOW"; return false; }
   reason="EXECUTION_APPROVED"; return true;
  }

bool AcceptedRetcode(const uint code)
  { return code==TRADE_RETCODE_DONE || code==TRADE_RETCODE_DONE_PARTIAL || code==TRADE_RETCODE_PLACED; }





bool ExecuteCandidate()
  {
   if(!g_candidate.valid) return false;
   NewDecisionID();
   TEL6EnsureSignalIdentity();
   g_tel6_intent_id=TEL6NewID("INT");
   TradeIntent intent; ZeroMemory(intent); string reason="";
   if(!CalculateIntent(g_candidate,intent,reason))
     {
      g_reason=reason; RememberExecutionGate(reason,intent);
      TEL6UpdateOutcomeIntent(intent);
      TEL6WriteSignalDecision("INTENT_REJECTED",reason,intent,false,"FAIL");
      TEL6WriteRiskState("INTENT_REJECTED",intent,false,true);
      MqlTradeRequest tel_req; MqlTradeCheckResult tel_check; MqlTradeResult tel_res;
      ZeroMemory(tel_req); ZeroMemory(tel_check); ZeroMemory(tel_res);
      TEL6WriteExecution("INTENT","REJECTED",intent,false,tel_req,false,false,tel_check,false,false,tel_res,reason);
      TEL6WriteSignalMarker("TECHNICAL_SIGNAL_BLOCKED",intent,false,"INTENT_REJECTED","N/A");
      LogEvent("INTENT_REJECTED",StringFormat("reason=%s|calculated_volume=%.4f|executable_volume=null|ConfiguredStopMoney=%.2f|AuthoritativeStopMoney=%.2f|CalculatedEffectiveLoss=%.2f|risk_budget_money=%.2f|effective_risk_percent=%.4f|hard_max_risk_money=%.2f|hard_max_risk_percent=%.4f",
               reason,intent.calculated_volume,InpStopMoney,intent.requested_stop_money,intent.effective_risk_money,intent.risk_money,
               intent.effective_risk_percent,intent.hard_max_risk_money,InpHardMaxRiskPercent));
      ClearCandidate(reason); g_state=ST_COOLDOWN; return false;
     }
   g_current_intent_id=NewIntentID();
   TEL6UpdateOutcomeIntent(intent);
   TEL6WriteSignalDecision("INTENT_READY","INTENT_READY",intent,true,"N/A");
   TEL6WriteRiskState("INTENT_READY",intent,true,true);

   MqlTradeRequest request; MqlTradeCheckResult check; MqlTradeResult result;
   ZeroMemory(request); ZeroMemory(check); ZeroMemory(result);
   if(!Preflight(intent,request,check,reason))
     {
      g_reason=reason; RememberExecutionGate(reason,intent);
      TEL6WriteSignalDecision("PREFLIGHT_REJECTED",reason,intent,true,"FAIL");
      TEL6WriteExecution("PREFLIGHT","REJECTED",intent,true,request,
                         g_tel6_preflight_ordercheck_executed,g_tel6_preflight_ordercheck_bool,check,
                         false,false,result,reason);
      TEL6WriteRiskState("PREFLIGHT_REJECTED",intent,true,true);
      TEL6WriteSignalMarker("TECHNICAL_SIGNAL_BLOCKED",intent,true,"PREFLIGHT_REJECTED","N/A");
      LogEvent("PREFLIGHT_REJECTED",StringFormat("reason=%s|spread_points=%.1f|spread_atr=%.4f|spread_limit_atr=%.4f|spread_baseline_atr=%.4f|spread_samples=%d|spread_mode=%s|calculated_volume=%.4f|executable_volume=null|order_check_executed=%s",
               reason,g_last_spread_points,g_last_spread_atr,g_effective_spread_atr_limit,
               g_adaptive_spread_baseline,g_spread_sample_count,SpreadLearningText(),intent.calculated_volume,
               BoolText(g_tel6_preflight_ordercheck_executed)));
      ClearCandidate(reason); g_state=ST_COOLDOWN; return false;
     }

   TEL6WriteSignalDecision("PREFLIGHT_APPROVED","EXECUTION_APPROVED",intent,true,"PASS");
   TEL6WriteExecution("PREFLIGHT","APPROVED",intent,true,request,
                      g_tel6_preflight_ordercheck_executed,g_tel6_preflight_ordercheck_bool,check,
                      false,false,result,"EXECUTION_APPROVED");
   g_last_gate_reason=""; g_last_gate_detail=""; g_last_gate_time=0;
   LogEvent("INTENT_CREATED",StringFormat("signal_anchor=%.10f|executable_entry_price=%.10f|planned_stop=%.10f|broker_stop_at_entry=%.10f|target=%.10f|target_mode=%s|protection_mode=%s|hard_risk_enforced_at_entry=%s|expected_gross_profit=%.2f|expected_r=%.3f|calculated_volume=%.4f|executable_volume=%.4f",
            intent.signal_anchor,intent.entry,intent.stop,InitialBrokerStopEnabled() ? intent.stop : 0.0,
            intent.target,EnumToString(InpTargetMode),ProtectionModeText(),BoolText(HardRiskEnforcedAtEntry()),
            intent.expected_profit,intent.expected_r,intent.calculated_volume,intent.volume));
   g_pending_reference_stop=intent.stop;
   g_pending_reference_risk=MathAbs(intent.entry-intent.stop);
   TEL6RememberPendingTradeLink();
   g_state=ST_ORDER_PENDING; ResetLastError();
   bool sent=OrderSend(request,result); bool accepted=sent && AcceptedRetcode(result.retcode);
   if(!accepted) TEL6ClearPendingTradeLink();
   TEL6WriteSignalDecision(accepted ? "ORDER_ACCEPTED" : "ORDER_REJECTED",
                           accepted ? "ORDER_ACCEPTED" : StringFormat("ORDER_REJECTED_%u",result.retcode),intent,true,
                           accepted ? "PASS" : "FAIL");
   TEL6WriteExecution("ORDER_SEND",accepted ? "ACCEPTED" : "REJECTED",intent,true,request,
                      true,true,check,true,sent,result,accepted ? "ORDER_ACCEPTED" : "ORDER_REJECTED");
   TEL6WriteSignalMarker(accepted ? "VALID_EXECUTED" : "TECHNICAL_SIGNAL_BLOCKED",intent,true,
                         accepted ? "ORDER_ACCEPTED" : "ORDER_REJECTED",accepted ? "PENDING" : "N/A");
   LogEvent("ORDER_RESULT",StringFormat("sent=%s|accepted=%s|retcode=%u|order=%I64u|deal=%I64u|price=%.10f|comment=%s|last_error=%d",
            BoolText(sent),BoolText(accepted),result.retcode,result.order,result.deal,result.price,result.comment,GetLastError()));
   g_last_trade_bar=g_rates[0].time; StartCooldown(InpCooldownBars);
   if(accepted)
     {
      g_reason="ORDER_ACCEPTED"; g_state=(result.deal>0 ? ST_IN_POSITION : ST_ORDER_PENDING);
      StoreInitialRiskForNewPositions();
      ClearCandidate(""); return true;
     }
   g_pending_reference_stop=0.0; g_pending_reference_risk=0.0;
   g_reason=StringFormat("ORDER_REJECTED_%u",result.retcode); ClearCandidate(g_reason); g_state=ST_COOLDOWN; return false;
  }

bool LoadPosition(const ulong ticket,PositionInfoNMX &p)
  {
   ZeroMemory(p); if(!PositionSelectByTicket(ticket)) return false;
   long magic=PositionGetInteger(POSITION_MAGIC);
   if(PositionGetString(POSITION_SYMBOL)!=_Symbol || !IsNexusMagic(magic)) return false;
   p.valid=true; p.ticket=ticket; p.magic=magic;
   p.comment=PositionGetString(POSITION_COMMENT);
   p.origin_tf=PositionOriginTimeframe(magic,p.comment);
   double stored_origin=ReadPositionState(p,"ORIGIN_TF",(double)p.origin_tf);
   ENUM_TIMEFRAMES restored_origin=(ENUM_TIMEFRAMES)(int)stored_origin;
   if(restored_origin==PERIOD_M1 || restored_origin==PERIOD_M5 || restored_origin==PERIOD_M30)
      p.origin_tf=restored_origin;
   else WritePositionState(p,"ORIGIN_TF",(double)p.origin_tf);
   p.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   p.identifier=(ulong)PositionGetInteger(POSITION_IDENTIFIER);
   p.volume=PositionGetDouble(POSITION_VOLUME); p.open_price=PositionGetDouble(POSITION_PRICE_OPEN);
   p.stop=PositionGetDouble(POSITION_SL); p.target=PositionGetDouble(POSITION_TP);
   p.profit=PositionGetDouble(POSITION_PROFIT); p.swap=PositionGetDouble(POSITION_SWAP);
   p.open_time=(datetime)PositionGetInteger(POSITION_TIME); return true;
  }

double InitialRiskDistance(const PositionInfoNMX &p)
  {
   double stored=ReadPositionState(p,"RISK",0.0);
   if(Positive(stored)) return stored;
   double inferred=MathAbs(p.open_price-p.stop);
   if(Positive(inferred)) { WritePositionState(p,"RISK",inferred); return inferred; }
   return 0.0;
  }

double PositionR(const PositionInfoNMX &p,const double risk)
  {
   if(!Positive(risk)) return 0.0; MqlTick tick; if(!SymbolInfoTick(_Symbol,tick)) return 0.0;
   return (p.type==POSITION_TYPE_BUY ? (tick.bid-p.open_price)/risk : (p.open_price-tick.ask)/risk);
  }

bool StopImproves(const PositionInfoNMX &p,const double stop)
  {
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick) || !Positive(stop)) return false;
   double minimum=(double)MathMax(g_symbol.stops_level,g_symbol.freeze_level)*g_symbol.point;
   if(p.type==POSITION_TYPE_BUY)
     {
      if(stop>=tick.bid-minimum) return false;
      if(Positive(p.stop) && stop<=p.stop+g_symbol.tick_size*0.25) return false;
     }
   else
     {
      if(stop<=tick.ask+minimum) return false;
      if(Positive(p.stop) && stop>=p.stop-g_symbol.tick_size*0.25) return false;
     }
   return true;
  }

bool ModifyPosition(const PositionInfoNMX &p,const double raw_stop,const double raw_target,const string reason)
  {
   double stop=NormalizePriceSide(raw_stop,p.type==POSITION_TYPE_SELL);
   double target=(Positive(raw_target) ? NormalizePrice(raw_target) : 0.0);
   if(GetTickCount64()<g_modify_block_until_ms) return false;
   if(!StopImproves(p,stop)) return false;
   MqlTradeRequest req; MqlTradeResult res; MqlTradeCheckResult check;
   ZeroMemory(req); ZeroMemory(res); ZeroMemory(check);
   req.action=TRADE_ACTION_SLTP; req.magic=(ulong)p.magic; req.position=p.ticket; req.symbol=_Symbol;
   req.sl=stop; req.tp=target;
   TradeIntent tel6_intent; ZeroMemory(tel6_intent);
   bool checked=OrderCheck(req,check);
   if(!checked)
     {
      TEL6WriteExecution("POSITION_MODIFY_CHECK","REJECTED",tel6_intent,false,req,true,false,check,false,false,res,reason,p.identifier);
      TEL6WriteProfitManagement("MODIFY_REJECTED",p,stop,target,reason,check.retcode);
      LogEvent("TRAIL_UPDATE_REJECTED",StringFormat("ticket=%I64u|reason=%s|check=%u",p.ticket,reason,check.retcode));
      return false;
     }
   bool sent=OrderSend(req,res); bool accepted=sent && (res.retcode==TRADE_RETCODE_DONE || res.retcode==TRADE_RETCODE_NO_CHANGES);
   if(!accepted)
      g_modify_block_until_ms=GetTickCount64()+(res.retcode==TRADE_RETCODE_POSITION_CLOSED ? 5000 : 2000);
   TEL6WriteExecution("POSITION_MODIFY",accepted ? "ACCEPTED" : "REJECTED",tel6_intent,false,req,true,true,check,true,sent,res,reason,p.identifier);
   TEL6WriteProfitManagement(accepted ? "MODIFY_ACCEPTED" : "MODIFY_REJECTED",p,stop,target,reason,res.retcode);
   LogEvent(accepted ? "POSITION_MODIFIED" : "TRAIL_UPDATE_REJECTED",
            StringFormat("ticket=%I64u|reason=%s|old_sl=%.10f|new_sl=%.10f|old_tp=%.10f|new_tp=%.10f|retcode=%u",
            p.ticket,reason,p.stop,stop,p.target,target,res.retcode));
   return accepted;
  }

bool ClosePosition(const PositionInfoNMX &p,const string reason)
  {
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick)) return false;
   MqlTradeRequest req; MqlTradeResult res; MqlTradeCheckResult check;
   ZeroMemory(req); ZeroMemory(res); ZeroMemory(check);
   req.action=TRADE_ACTION_DEAL; req.magic=(ulong)p.magic; req.position=p.ticket; req.symbol=_Symbol;
   req.volume=p.volume; req.type=(p.type==POSITION_TYPE_BUY ? ORDER_TYPE_SELL : ORDER_TYPE_BUY);
   req.price=(p.type==POSITION_TYPE_BUY ? tick.bid : tick.ask); req.deviation=(ulong)MathMax(0,InpMaxDeviationPoints);
   req.type_filling=FillingMode(); req.type_time=ORDER_TIME_GTC; req.comment="NMX_"+reason;
   TradeIntent tel6_intent; ZeroMemory(tel6_intent);
   bool checked=OrderCheck(req,check);
   if(!checked)
     {
      TEL6WriteExecution("POSITION_CLOSE_CHECK","REJECTED",tel6_intent,false,req,true,false,check,false,false,res,reason,p.identifier);
      TEL6WriteProfitManagement("CLOSE_REJECTED",p,p.stop,p.target,reason,check.retcode);
      LogEvent("POSITION_CLOSE_REJECTED",StringFormat("reason=%s|check=%u",reason,check.retcode));
      return false;
     }
   bool sent=OrderSend(req,res); bool accepted=sent && AcceptedRetcode(res.retcode);
   TEL6WriteExecution("POSITION_CLOSE",accepted ? "ACCEPTED" : "REJECTED",tel6_intent,false,req,true,true,check,true,sent,res,reason,p.identifier);
   TEL6WriteProfitManagement(accepted ? "CLOSE_SENT" : "CLOSE_REJECTED",p,p.stop,p.target,reason,res.retcode);
   LogEvent(accepted ? "POSITION_CLOSE_SENT" : "POSITION_CLOSE_REJECTED",StringFormat("ticket=%I64u|reason=%s|retcode=%u",p.ticket,reason,res.retcode));
   return accepted;
  }

double ATRForTimeframe(const ENUM_TIMEFRAMES tf)
  {
   if(tf==g_profile.tf && Positive(g_atr)) return g_atr;
   for(int i=0;i<3;i++)
      if(g_mtf[i].valid && g_mtf[i].timeframe==tf && Positive(g_mtf[i].atr)) return g_mtf[i].atr;
   MqlRates bars[]; ArraySetAsSeries(bars,true);
   int period=MathMax(2,InpATRPeriod);
   if(CopyRates(_Symbol,tf,0,period+2,bars)<period+2) return 0.0;
   double total=0.0;
   for(int i=1;i<=period;i++)
     {
      double previous=bars[i+1].close;
      total+=MathMax(bars[i].high-bars[i].low,
                     MathMax(MathAbs(bars[i].high-previous),MathAbs(bars[i].low-previous)));
     }
   return total/period;
  }

bool IsPivotLowInRates(const MqlRates &bars[],const int shift,const int strength)
  {
   if(shift-strength<0 || shift+strength>=ArraySize(bars)) return false;
   for(int j=1;j<=strength;j++)
      if(bars[shift].low>=bars[shift-j].low || bars[shift].low>bars[shift+j].low) return false;
   return true;
  }

bool IsPivotHighInRates(const MqlRates &bars[],const int shift,const int strength)
  {
   if(shift-strength<0 || shift+strength>=ArraySize(bars)) return false;
   for(int j=1;j<=strength;j++)
      if(bars[shift].high<=bars[shift-j].high || bars[shift].high<bars[shift+j].high) return false;
   return true;
  }

bool StructureTrailingStop(const PositionInfoNMX &p,double &stop)
  {
   stop=0.0; int strength=MathMax(1,InpSwingStrength);
   MqlRates bars[]; ArraySetAsSeries(bars,true);
   if(CopyRates(_Symbol,p.origin_tf,0,90,bars)<strength*2+10) return false;
   double atr=ATRForTimeframe(p.origin_tf); if(!Positive(atr)) return false;
   if(p.type==POSITION_TYPE_BUY)
     {
      for(int i=strength+1;i<MathMin(80,ArraySize(bars)-strength);i++)
         if(IsPivotLowInRates(bars,i,strength)) { stop=bars[i].low-InpStopBufferATR*atr; return true; }
     }
   else
     {
      for(int i=strength+1;i<MathMin(80,ArraySize(bars)-strength);i++)
         if(IsPivotHighInRates(bars,i,strength)) { stop=bars[i].high+InpStopBufferATR*atr; return true; }
     }
   return false;
  }

int MaxBarsInTradeForTimeframe(const ENUM_TIMEFRAMES tf)
  {
   if(InpProfileMode==PROFILE_MANUAL && tf==g_profile.tf) return InpManualMaxBarsInTrade;
   if(tf==PERIOD_M1) return 20;
   if(tf==PERIOD_M5) return 36;
   if(tf==PERIOD_M30) return 24;
   return InpManualMaxBarsInTrade;
  }


double PositionPaidCosts(const ulong identifier)
  {
   // Comissao/fee so mudam quando entra um deal; evita HistorySelectByPosition a cada tick.
   ulong now=GetTickCount64();
   if(g_costs_cache_pid==identifier && g_costs_cache_ms>0 && now-g_costs_cache_ms<10000) return g_costs_cache_value;
   double paid=0.0;
   if(HistorySelectByPosition(identifier))
     {
      for(int i=0;i<HistoryDealsTotal();i++)
        {
         ulong deal=HistoryDealGetTicket(i); if(deal==0) continue;
         paid+=HistoryDealGetDouble(deal,DEAL_COMMISSION)+HistoryDealGetDouble(deal,DEAL_FEE);
        }
     }
   g_costs_cache_pid=identifier; g_costs_cache_value=paid; g_costs_cache_ms=now;
   return paid;
  }

bool PositionCostModel(const PositionInfoNMX &p,double &estimated_costs)
  {
   estimated_costs=0.0;
   double paid_costs=PositionPaidCosts(p.identifier);
   estimated_costs=(paid_costs<0.0 ? paid_costs*2.0 : paid_costs);
   return true;
  }


void ResetMoneyTrailLockDiagnostics(const PositionInfoNMX &p,const double desired_floor)
  {
   ZeroMemory(g_money_trail_lock_diag);
   g_money_trail_lock_diag.attempted=true;
   g_money_trail_lock_diag.requested_floor=desired_floor;
   g_money_trail_lock_diag.swap=p.swap;
  }

void LogMoneyTrailLockDiagnostics(const PositionInfoNMX &p,const string final_result)
  {
   LogEvent("MONEY_TRAIL_LOCK_SOLVER",StringFormat(
      "Position=%I64u|Direction=%s|Volume=%.4f|EntryPrice=%.10f|RequestedNetFloor=%.2f|GrossRequired=%.8f|EstimatedCosts=%.8f|Swap=%.8f|TickSize=%.10f|ProbePrice=%.10f|ProbeDistanceTicks=%I64d|OrderCalcProfitBool=%s|ProbeGrossPnL=%.8f|GetLastError=%d|BracketLow=%I64d|BracketHigh=%I64d|Iterations=%d|CalculatedSL=%.10f|GrossProfitAtSL=%.8f|ExpectedNetFloor=%.8f|ToleranceMoney=%.8f|FinalResult=%s|FailureReason=%s",
      p.identifier,p.type==POSITION_TYPE_BUY ? "BUY" : "SELL",p.volume,p.open_price,
      g_money_trail_lock_diag.requested_floor,g_money_trail_lock_diag.gross_required,
      g_money_trail_lock_diag.estimated_costs,g_money_trail_lock_diag.swap,g_symbol.tick_size,
      g_money_trail_lock_diag.probe_price,g_money_trail_lock_diag.probe_ticks,
      BoolText(g_money_trail_lock_diag.probe_calc_ok),g_money_trail_lock_diag.probe_gross,
      g_money_trail_lock_diag.last_error,g_money_trail_lock_diag.bracket_low_ticks,
      g_money_trail_lock_diag.bracket_high_ticks,g_money_trail_lock_diag.iterations,
      g_money_trail_lock_diag.calculated_stop,g_money_trail_lock_diag.gross_profit_at_sl,
      g_money_trail_lock_diag.expected_net_floor,g_money_trail_lock_diag.tolerance_money,
      final_result,g_money_trail_lock_diag.failure_reason));
  }

bool SolveMoneyTrailLockPrice(const PositionInfoNMX &p,const double desired_net_floor,double &stop)
  {
   stop=0.0;
   ResetMoneyTrailLockDiagnostics(p,desired_net_floor);

   if(!Positive(desired_net_floor) || !Positive(p.volume) || !Positive(p.open_price) ||
      !g_symbol.valid || !Positive(g_symbol.tick_size))
     {
      g_money_trail_lock_diag.failure_reason="INVALID_INPUT";
      LogMoneyTrailLockDiagnostics(p,"FAILED");
      return false;
     }

   double estimated_costs=0.0;
   PositionCostModel(p,estimated_costs);
   double required_gross=desired_net_floor-p.swap-estimated_costs;
   g_money_trail_lock_diag.estimated_costs=estimated_costs;
   g_money_trail_lock_diag.gross_required=required_gross;
   if(!Positive(required_gross))
     {
      g_money_trail_lock_diag.failure_reason="INVALID_REQUIRED_GROSS";
      LogMoneyTrailLockDiagnostics(p,"FAILED");
      return false;
     }

   ENUM_ORDER_TYPE type=(p.type==POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   const bool buy=(type==ORDER_TYPE_BUY);
   long low_ticks=0,high_ticks=1;
   double low_gross=0.0,high_gross=0.0,gross=0.0;
   bool bracket=false;

   for(int i=0;i<60;i++)
     {
      double raw=(buy ? p.open_price+high_ticks*g_symbol.tick_size :
                        p.open_price-high_ticks*g_symbol.tick_size);
      if(raw<=0.0) { g_money_trail_lock_diag.failure_reason="BRACKET_NOT_FOUND"; break; }
      double candidate=NormalizePriceSide(raw,buy);
      if(!Positive(candidate) || (buy && candidate<=p.open_price) || (!buy && candidate>=p.open_price))
        { g_money_trail_lock_diag.failure_reason="LOCK_NORMALIZATION_FAILED"; break; }

      ResetLastError();
      bool ok=ProfitAtPrice(type,p.volume,p.open_price,candidate,gross);
      int le=GetLastError();
      g_money_trail_lock_diag.probe_price=candidate;
      g_money_trail_lock_diag.probe_ticks=high_ticks;
      g_money_trail_lock_diag.probe_calc_ok=ok;
      g_money_trail_lock_diag.probe_gross=gross;
      g_money_trail_lock_diag.last_error=le;
      g_money_trail_lock_diag.iterations++;

      if(!ok || !MathIsValidNumber(gross))
        { g_money_trail_lock_diag.failure_reason="ORDERCALCPROFIT_FAILED"; break; }

      if(gross>0.0 && gross+1e-8>=required_gross)
        { bracket=true; high_gross=gross; break; }

      if(gross>0.0) { low_ticks=high_ticks; low_gross=gross; }
      if(high_ticks>1000000000/2)
        { g_money_trail_lock_diag.failure_reason="BRACKET_NOT_FOUND"; break; }
      high_ticks*=2;
     }

   if(!bracket)
     {
      if(g_money_trail_lock_diag.failure_reason=="") g_money_trail_lock_diag.failure_reason="BRACKET_NOT_FOUND";
      LogMoneyTrailLockDiagnostics(p,"FAILED");
      return false;
     }

   g_money_trail_lock_diag.bracket_low_ticks=low_ticks;
   g_money_trail_lock_diag.bracket_high_ticks=high_ticks;

   while(high_ticks-low_ticks>1 && g_money_trail_lock_diag.iterations<100)
     {
      long mid=low_ticks+(high_ticks-low_ticks)/2;
      double raw=(buy ? p.open_price+mid*g_symbol.tick_size :
                        p.open_price-mid*g_symbol.tick_size);
      double candidate=NormalizePriceSide(raw,buy);
      ResetLastError();
      bool ok=ProfitAtPrice(type,p.volume,p.open_price,candidate,gross);
      int le=GetLastError();
      g_money_trail_lock_diag.probe_price=candidate;
      g_money_trail_lock_diag.probe_ticks=mid;
      g_money_trail_lock_diag.probe_calc_ok=ok;
      g_money_trail_lock_diag.probe_gross=gross;
      g_money_trail_lock_diag.last_error=le;
      g_money_trail_lock_diag.iterations++;

      if(!ok || !MathIsValidNumber(gross))
        {
         g_money_trail_lock_diag.failure_reason="ORDERCALCPROFIT_FAILED";
         LogMoneyTrailLockDiagnostics(p,"FAILED");
         return false;
        }

      if(gross>0.0 && gross+1e-8>=required_gross)
        { high_ticks=mid; high_gross=gross; }
      else
        { low_ticks=mid; low_gross=MathMax(0.0,gross); }
     }

   if(high_ticks-low_ticks>1)
     {
      g_money_trail_lock_diag.failure_reason="SOLVER_ITERATION_LIMIT";
      LogMoneyTrailLockDiagnostics(p,"FAILED");
      return false;
     }

   double raw=(buy ? p.open_price+high_ticks*g_symbol.tick_size :
                     p.open_price-high_ticks*g_symbol.tick_size);
   double final_price=NormalizePriceSide(raw,buy);
   ResetLastError();
   bool final_ok=ProfitAtPrice(type,p.volume,p.open_price,final_price,gross);
   int final_err=GetLastError();

   g_money_trail_lock_diag.probe_price=final_price;
   g_money_trail_lock_diag.probe_ticks=high_ticks;
   g_money_trail_lock_diag.probe_calc_ok=final_ok;
   g_money_trail_lock_diag.probe_gross=gross;
   g_money_trail_lock_diag.last_error=final_err;
   g_money_trail_lock_diag.calculated_stop=final_price;
   g_money_trail_lock_diag.gross_profit_at_sl=(final_ok ? gross : 0.0);
   g_money_trail_lock_diag.expected_net_floor=(final_ok ? gross+p.swap+estimated_costs : 0.0);
   g_money_trail_lock_diag.tolerance_money=MathMax(0.01,MathAbs(high_gross-low_gross)+1e-8);

   if(!final_ok || !MathIsValidNumber(gross))
     {
      g_money_trail_lock_diag.failure_reason="ORDERCALCPROFIT_FAILED";
      LogMoneyTrailLockDiagnostics(p,"FAILED");
      return false;
     }

   if(g_money_trail_lock_diag.expected_net_floor+1e-8<desired_net_floor ||
      g_money_trail_lock_diag.expected_net_floor>desired_net_floor+g_money_trail_lock_diag.tolerance_money+1e-8)
     {
      g_money_trail_lock_diag.failure_reason="NET_FLOOR_OUTSIDE_TOLERANCE";
      LogMoneyTrailLockDiagnostics(p,"FAILED");
      return false;
     }

   stop=final_price;
   g_money_trail_lock_diag.success=true;
   g_money_trail_lock_diag.failure_reason="";
   LogMoneyTrailLockDiagnostics(p,"SUCCESS");
   return true;
  }








double PositionNetEstimate(const PositionInfoNMX &p)
  {
   double paid_costs=PositionPaidCosts(p.identifier);
   return p.profit+p.swap+paid_costs;
  }

bool PlannedStopForPosition(const PositionInfoNMX &p,double &stop)
  {
   stop=ReadPositionState(p,"PLANNED_SL",0.0);
   if(Positive(stop)) return true;
   if(Positive(p.stop))
     {
      stop=p.stop;
      WritePositionState(p,"PLANNED_SL",stop);
      return true;
     }
   if(InpStopMode==STOP_MONEY && Positive(InpStopMoney))
     {
      ENUM_ORDER_TYPE type=(p.type==POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
      if(SolveStopPriceForMoney(type,p.volume,p.open_price,InpStopMoney,stop) && Positive(stop))
        {
         WritePositionState(p,"PLANNED_SL",stop);
         return true;
        }
     }
   return false;
  }

bool PlannedStopAlreadyBreached(const PositionInfoNMX &p,const double stop)
  {
   MqlTick tick; if(!SymbolInfoTick(_Symbol,tick)) return false;
   if(p.type==POSITION_TYPE_BUY) return tick.bid<=stop;
   return tick.ask>=stop;
  }

void ResetNegativeTimer(const PositionInfoNMX &p,const string event_name,const double current_profit)
  {
   datetime negative_since=(datetime)(long)ReadPositionState(p,"NEGATIVE_SINCE",0.0);
   if(negative_since<=0) return;
   long elapsed=MathMax(0,(long)(TimeTradeServer()-negative_since));
   WritePositionState(p,"NEGATIVE_SINCE",0.0);
   WritePositionState(p,"NEGATIVE_LAST_SEEN",0.0);
   WritePositionState(p,"NEGATIVE_LOG_BUCKET",-1.0);
   LogEvent(event_name,StringFormat("ticket=%I64u|origin_tf=%s|elapsed_seconds=%d|net_profit=%.2f",
            p.ticket,TimeframeShort(p.origin_tf),elapsed,current_profit));
  }

void ManageDelayedProtection(const PositionInfoNMX &p,const double current_profit,const bool trail_active)
  {
   if(trail_active || InpProtectionMode==PROTECTION_IMMEDIATE) return;
   if(InpProtectionMode==PROTECTION_NONE)
     {
      if(!Positive(p.stop) && ReadPositionState(p,"UNPROTECTED_LOGGED",0.0)<0.5)
        {
         WritePositionState(p,"UNPROTECTED_LOGGED",1.0);
         LogEvent("POSITION_UNPROTECTED",StringFormat("ticket=%I64u|origin_tf=%s|risk_limit_guaranteed=false",
                  p.ticket,TimeframeShort(p.origin_tf)));
        }
      return;
     }

   if(Positive(p.stop))
     {
      WritePositionState(p,"DELAYED_STOP_ACTIVE",1.0);
      return;
     }

   datetime now=TimeTradeServer();
   datetime negative_since=(datetime)(long)ReadPositionState(p,"NEGATIVE_SINCE",0.0);
   datetime last_seen=(datetime)(long)ReadPositionState(p,"NEGATIVE_LAST_SEEN",0.0);
   if(current_profit>=-0.005)
     {
      if(InpResetNegativeTimerOnRecovery)
         ResetNegativeTimer(p,"NEGATIVE_TIMER_RESET_RECOVERY",current_profit);
      return;
     }

   long monitoring_gap=(last_seen>0 ? (long)(now-last_seen) : 0);
   long maximum_gap=MathMax(30,MathMax(1,InpTimerSeconds)*4);
   if(negative_since>0 && monitoring_gap>maximum_gap)
     {
      ResetNegativeTimer(p,"NEGATIVE_TIMER_RESET_MONITOR_GAP",current_profit);
      negative_since=0;
     }
   if(negative_since<=0)
     {
      negative_since=now;
      WritePositionState(p,"NEGATIVE_SINCE",(double)negative_since);
      WritePositionState(p,"NEGATIVE_LOG_BUCKET",0.0);
      LogEvent("NEGATIVE_TIMER_STARTED",StringFormat("ticket=%I64u|origin_tf=%s|delay_minutes=%d|net_profit=%.2f",
               p.ticket,TimeframeShort(p.origin_tf),DelayedStopMinutes(p.origin_tf),current_profit));
     }
   WritePositionState(p,"NEGATIVE_LAST_SEEN",(double)now);

   long elapsed=MathMax(0,(long)(now-negative_since));
   long required=(long)DelayedStopMinutes(p.origin_tf)*60;
   int bucket=(int)(elapsed/60);
   int last_bucket=(int)ReadPositionState(p,"NEGATIVE_LOG_BUCKET",-1.0);
   if(bucket>last_bucket)
     {
      WritePositionState(p,"NEGATIVE_LOG_BUCKET",(double)bucket);
      LogEvent("NEGATIVE_TIMER_PROGRESS",StringFormat("ticket=%I64u|origin_tf=%s|elapsed_seconds=%d|required_seconds=%d|remaining_seconds=%d|net_profit=%.2f",
               p.ticket,TimeframeShort(p.origin_tf),elapsed,required,MathMax(0,required-elapsed),current_profit));
     }
   if(elapsed<required) return;

   double planned_stop=0.0;
   if(!PlannedStopForPosition(p,planned_stop))
     {
      LogEvent("DELAYED_STOP_REJECTED",StringFormat("ticket=%I64u|reason=PLANNED_STOP_UNAVAILABLE",p.ticket));
      return;
     }
   if(PlannedStopAlreadyBreached(p,planned_stop))
     {
      if(ReadPositionState(p,"DELAYED_BREACH_LOGGED",0.0)<0.5)
        {
         WritePositionState(p,"DELAYED_BREACH_LOGGED",1.0);
         LogEvent("DELAYED_STOP_ALREADY_BREACHED",StringFormat("ticket=%I64u|planned_sl=%.10f|net_profit=%.2f|action=MARKET_CLOSE",
                  p.ticket,planned_stop,current_profit));
        }
      ClosePosition(p,"DELAYED_STOP_ALREADY_BREACHED");
      return;
     }
   bool modified=ModifyPosition(p,planned_stop,p.target,"DELAYED_STOP_ACTIVATION");
   if(modified)
     {
      WritePositionState(p,"DELAYED_STOP_ACTIVE",1.0);
      LogEvent("DELAYED_STOP_ACTIVATED",StringFormat("ticket=%I64u|origin_tf=%s|elapsed_seconds=%d|broker_sl=%.10f|net_profit=%.2f",
               p.ticket,TimeframeShort(p.origin_tf),elapsed,planned_stop,current_profit));
     }
  }

//+------------------------------------------------------------------+
//| Trailing monetario PieceTrend                                    |
//| D = ratio x A x max(pico/A,1)^expoente ; piso = pico - D         |
//| O trailing arma quando o PICO liquido >= A e o TP e removido.    |
//+------------------------------------------------------------------+
double TrailDistanceMoney(const double peak)
  {
   double a=InpTrailingActivationMoney;
   if(!Positive(a)) return 0.0;
   return InpTrailRatio*a*MathPow(MathMax(peak/a,1.0),InpTrailExponent);
  }

double TrailFloorMoney(const double peak)
  { return peak-TrailDistanceMoney(peak); }


bool FloatingBreakerTrip(const string scope,const PositionInfoNMX &p,const double net,const double limit)
  {
   bool first=(g_breaker_reason=="" || !g_entries_paused);
   if(first)
     {
      g_breaker_reason=StringFormat("FLOATING_BREAKER_%s",scope);
      LogEvent("FLOATING_BREAKER_TRIPPED",StringFormat("scope=%s|ticket=%I64u|net_floating=%.2f|limit=%.2f|action=%s",
               scope,p.ticket,net,limit,EnumToString(InpFloatingBreakerAction)));
      if(!(bool)MQLInfoInteger(MQL_TESTER))
         Alert("NEXUS GUARD PRO: DISJUNTOR DE PERDA FLUTUANTE (",scope,") | P/L ",DoubleToString(net,2)," | LIMITE ",DoubleToString(limit,2));
     }
   if(InpFloatingBreakerAction>=BREAKER_PAUSE_ENTRIES)
     { g_entries_paused=true; g_reason=g_breaker_reason; }
   if(InpFloatingBreakerAction==BREAKER_CLOSE_AND_PAUSE)
      return ClosePosition(p,"FLOATING_BREAKER");
   return false;
  }

void ManagePosition(const PositionInfoNMX &p,const bool new_bar)
  {
   double risk=InitialRiskDistance(p); double current_r=PositionR(p,risk);
   bool trail_active=ReadPositionState(p,"TRAIL",0.0)>0.5;
   double current_profit=PositionNetEstimate(p);
   double peak=ReadPositionState(p,"PEAK",current_profit);
   if(current_profit>peak)
     {
      peak=current_profit;
      WritePositionState(p,"PEAK",peak);
     }
   double trough=ReadPositionState(p,"TROUGH",current_profit);
   if(current_profit<trough) { trough=current_profit; WritePositionState(p,"TROUGH",trough); }

   if(InpUseFloatingBreaker && Positive(InpFloatingLossPositionMoney) && current_profit<=-InpFloatingLossPositionMoney)
      if(FloatingBreakerTrip("POSITION",p,current_profit,InpFloatingLossPositionMoney)) return;

   ManageDelayedProtection(p,current_profit,trail_active);

   if(InpUseBreakEven && current_r>=InpBreakEvenTriggerR)
     {
      double be=(p.type==POSITION_TYPE_BUY ? p.open_price+InpBreakEvenOffsetTicks*g_symbol.tick_size :
                                             p.open_price-InpBreakEvenOffsetTicks*g_symbol.tick_size);
      ModifyPosition(p,be,p.target,"BREAK_EVEN");
     }

   if(InpUseTrailing)
     {
      bool activate=false;
      if(InpTrailingMode==TRAIL_MONEY) activate=(peak>=InpTrailingActivationMoney);
      else if(InpTrailingMode==TRAIL_POINTS)
        {
         MqlTick tick; if(SymbolInfoTick(_Symbol,tick))
           {
            double favorable=(p.type==POSITION_TYPE_BUY ? tick.bid-p.open_price : p.open_price-tick.ask);
            activate=favorable/g_symbol.point>=InpTrailingActivationPoints;
           }
        }
      else activate=current_r>=InpTrailingActivationATR;
      if(activate && !trail_active && ReadPositionState(p,"TRAIL_THRESHOLD_LOGGED",0.0)<0.5)
        {
         WritePositionState(p,"TRAIL_THRESHOLD_LOGGED",1.0);
         LogEvent("TRAIL_THRESHOLD_REACHED",StringFormat("ticket=%I64u|origin_tf=%s|mode=%s|net_profit=%.2f|broker_sl_before=%.10f",
                  p.ticket,TimeframeShort(p.origin_tf),EnumToString(InpTrailingMode),current_profit,p.stop));
        }
      bool manage_trailing=trail_active || activate;
      if(manage_trailing)
        {
         double proposed=0.0; bool have=false; bool persist_money_lock=false;
         double pending_money_lock=0.0; MqlTick tick;
         if(InpTrailingMode==TRAIL_MONEY)
           {
            double floor_money=TrailFloorMoney(peak);
            double last_lock=ReadPositionState(p,"LOCK",-DBL_MAX);
            bool broker_has_floor=(Positive(p.stop) && last_lock>-DBL_MAX/2.0 && last_lock>=floor_money-1e-8);
            if(floor_money>=last_lock+InpTrailingStepMoney-1e-8)
              {
               have=SolveMoneyTrailLockPrice(p,floor_money,proposed);
               if(have) { persist_money_lock=true; pending_money_lock=floor_money; }
              }
            // O preco ja cruzou o piso e nenhum SL do broker o protege: encerra a mercado.
            if(!broker_has_floor && current_profit<=floor_money-0.01)
              {
               ClosePosition(p,"TRAIL_FLOOR_BREACHED");
               return;
              }
           }
         else if(InpTrailingMode==TRAIL_POINTS && SymbolInfoTick(_Symbol,tick))
           {
            proposed=(p.type==POSITION_TYPE_BUY ? tick.bid-InpTrailingDistancePoints*g_symbol.point :
                                                  tick.ask+InpTrailingDistancePoints*g_symbol.point); have=true;
           }
         else if(InpTrailingMode==TRAIL_ATR && SymbolInfoTick(_Symbol,tick))
           {
            double origin_atr=ATRForTimeframe(p.origin_tf);
            if(Positive(origin_atr))
              { proposed=(p.type==POSITION_TYPE_BUY ? tick.bid-InpTrailingDistanceATR*origin_atr : tick.ask+InpTrailingDistanceATR*origin_atr); have=true; }
           }
         else if(InpTrailingMode==TRAIL_STRUCTURE) have=StructureTrailingStop(p,proposed);
         if(have && Positive(p.stop))
           {
            double required_step=0.0;
            if(InpTrailingMode==TRAIL_POINTS) required_step=InpTrailingStepPoints*g_symbol.point;
            else if(InpTrailingMode==TRAIL_ATR) required_step=InpTrailingStepATR*ATRForTimeframe(p.origin_tf);
            if(required_step>0.0 && MathAbs(proposed-p.stop)<required_step) have=false;
           }
          double next_target=p.target;
          if(InpTargetMode==TARGET_MONEY_THEN_TRAILING) next_target=0.0;
          if(have)
            {
             bool modified=ModifyPosition(p,proposed,next_target,"TRAIL_"+EnumToString(InpTrailingMode));
             // Never advance the persisted lock before the broker accepts the
             // SL/TP change. Otherwise a transient rejection suppresses the
             // retry and can leave the original TP/SL unmanaged.
             if(modified)
               {
                if(persist_money_lock) WritePositionState(p,"LOCK",pending_money_lock);
                if(!trail_active)
                  {
                   WritePositionState(p,"TRAIL",1.0);
                   trail_active=true;
                   LogEvent("TRAIL_PROTECTION_ACTIVE",StringFormat("ticket=%I64u|origin_tf=%s|net_profit=%.2f|original_sl=%.10f|trailing_sl=%.10f|original_tp=%.10f|tp_after=%.10f|result=PROFIT_PROTECTED",
                            p.ticket,TimeframeShort(p.origin_tf),current_profit,p.stop,proposed,p.target,next_target));
                  }
               }
            }
         }
     }

   if(InpUseTimeStop && (new_bar || p.origin_tf!=g_profile.tf))
     {
      int bars=iBarShift(_Symbol,p.origin_tf,p.open_time,false);
      int maximum=MaxBarsInTradeForTimeframe(p.origin_tf);
      if(bars>=maximum) ClosePosition(p,"TIME_STOP");
     }
   TEL6MaybeWriteProfitState(p,new_bar ? "NEW_BAR" : "STATE_CHANGE",new_bar);
  }

int ManagePositions(const bool new_bar)
  {
   int count=0;
   double breaker_total=0.0; bool breaker_total_hit=false;
   if(InpUseFloatingBreaker && Positive(InpFloatingLossTotalMoney))
     {
      breaker_total=NexusOwnFloatingNet();
      breaker_total_hit=(breaker_total<=-InpFloatingLossTotalMoney);
     }
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i); if(ticket==0) continue;
      PositionInfoNMX p; if(!LoadPosition(ticket,p)) continue;
      count++;
      if(breaker_total_hit && FloatingBreakerTrip("TOTAL",p,breaker_total,InpFloatingLossTotalMoney)) continue;
      ManagePosition(p,new_bar);
     }
   if(count>0) g_state=ST_IN_POSITION;
   return count;
  }

void StoreInitialRiskForNewPositions()
  {
   bool consumed_pending=false;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i); if(ticket==0) continue;
      PositionInfoNMX p; if(!LoadPosition(ticket,p)) continue;
      if(!HasPositionState(p,"ORIGIN_TF")) WritePositionState(p,"ORIGIN_TF",(double)p.origin_tf);
      double planned=ReadPositionState(p,"PLANNED_SL",0.0);
      if(!Positive(planned))
        {
         if(Positive(p.stop)) planned=p.stop;
         else if(Positive(g_pending_reference_stop))
           {
            planned=g_pending_reference_stop;
            consumed_pending=true;
           }
         else if(InpStopMode==STOP_MONEY && Positive(InpStopMoney))
           {
            ENUM_ORDER_TYPE type=(p.type==POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
            SolveStopPriceForMoney(type,p.volume,p.open_price,InpStopMoney,planned);
           }
         if(Positive(planned)) WritePositionState(p,"PLANNED_SL",planned);
        }
      if(!HasPositionState(p,"RISK"))
        {
         double risk=(Positive(g_pending_reference_risk) && consumed_pending ?
                      g_pending_reference_risk : MathAbs(p.open_price-planned));
         if(Positive(risk)) WritePositionState(p,"RISK",risk);
        }
      if(!HasPositionState(p,"OPEN_AUDITED"))
        {
         WritePositionState(p,"OPEN_AUDITED",1.0);
         TEL6BindTradeLink(p.identifier);
         TEL6MaybeWriteProfitState(p,"POSITION_OPENED",true);
         LogEvent(Positive(p.stop) ? "POSITION_OPENED_WITH_SL" : "POSITION_OPENED_WITHOUT_SL",
                  StringFormat("ticket=%I64u|origin_tf=%s|protection_mode=%s|broker_sl=%.10f|planned_sl=%.10f|delay_minutes=%d",
                  p.ticket,TimeframeShort(p.origin_tf),ProtectionModeText(),p.stop,planned,DelayedStopMinutes(p.origin_tf)));
        }
     }
   if(consumed_pending)
     { g_pending_reference_stop=0.0; g_pending_reference_risk=0.0; }
  }

string O(const string suffix)
  { return g_prefix+"PNL_"+suffix; }

string L(const int index)
  { return g_prefix+StringFormat("LVL_%d",index); }

//+------------------------------------------------------------------+
//| PAINEL - design system NEXUS PRO                                  |
//| - coordenadas em px logicos (96 dpi) x fator de DPI x escala      |
//| - todos os objetos ancorados em CORNER_LEFT_UPPER; a origem do    |
//|   painel e calculada para qualquer canto do grafico               |
//| - texto medido com TextGetSize (sem estimativa de largura)        |
//| - cache por assinatura: so reescreve o objeto que mudou           |
//+------------------------------------------------------------------+
struct UiCacheEntry
  {
   string id;
   string sig;
  };

UiCacheEntry g_ui_cache[];
string g_ui_touched[];
bool g_ui_dirty=false;
int g_ui_origin_x=0;
int g_ui_origin_y=0;

const int UI_PANEL_W=468;
const int UI_PANEL_MIN_W=300;
const string UI_FONT="Segoe UI";
const string UI_FONT_BOLD="Segoe UI Semibold";
const string UI_FONT_NUM="Consolas";

int NativePanelYOffset()
  {
   // The MT5 one-click trading widget is native terminal UI, not a chart
   // object. No OBJPROP_ZORDER can draw over it, so reserve its top-left area.
   if(!InpAvoidNativeOneClickOverlay || InpPanelCorner!=CORNER_LEFT_UPPER) return 0;
   if(InpPanelX>=205 || !((bool)ChartGetInteger(0,CHART_SHOW_ONE_CLICK))) return 0;
   return MathMax(0,InpNativeTopOverlayHeight);
  }

double UiPercent()
  { return Clamp((double)InpPanelScalePercent,70.0,160.0)/100.0; }

double UiDpiFactor()
  {
   double dpi=(double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   if(dpi<72.0 || dpi>384.0) dpi=96.0;
   return dpi/96.0;
  }

int U(const int logical)
  { return (int)MathRound(logical*UiDpiFactor()*UiPercent()); }

int UiPt(const int points)
  { return MathMax(6,(int)MathRound(points*UiPercent())); }

int UiTextWidthPx(const string text,const string font,const int points)
  {
   TextSetFont(font,-(UiPt(points)*10));
   uint w=0,h=0;
   TextGetSize(text,w,h);
   return (int)w;
  }

int UiTextWidthLogical(const string text,const string font,const int points)
  { return (int)MathCeil(UiTextWidthPx(text,font,points)/(UiDpiFactor()*UiPercent())); }

string UiFit(const string text,const int max_logical,const string font,const int points)
  {
   int max_px=U(max_logical);
   if(max_px<=0) return "";
   if(UiTextWidthPx(text,font,points)<=max_px) return text;
   int lo=0,hi=StringLen(text);
   while(lo<hi)
     {
      int mid=(lo+hi+1)/2;
      if(UiTextWidthPx(StringSubstr(text,0,mid)+"...",font,points)<=max_px) lo=mid; else hi=mid-1;
     }
   return StringSubstr(text,0,lo)+"...";
  }

int UiLineH(const int points)
  { return (int)MathRound(points*1.75); }

int UiCacheIndex(const string id)
  {
   for(int i=ArraySize(g_ui_cache)-1;i>=0;i--) if(g_ui_cache[i].id==id) return i;
   return -1;
  }

// true when the object is missing or its signature changed (and must be rewritten)
bool UiStale(const string id,const string sig)
  {
   int n=ArraySize(g_ui_touched); ArrayResize(g_ui_touched,n+1); g_ui_touched[n]=id;
   int i=UiCacheIndex(id);
   if(i<0)
     {
      i=ArraySize(g_ui_cache); ArrayResize(g_ui_cache,i+1);
      g_ui_cache[i].id=id; g_ui_cache[i].sig="";
     }
   if(g_ui_cache[i].sig==sig && ObjectFind(0,O(id))>=0) return false;
   g_ui_cache[i].sig=sig; g_ui_dirty=true;
   return true;
  }

bool UiEnsure(const string id,const ENUM_OBJECT type)
  {
   string name=O(id);
   if(ObjectFind(0,name)>=0)
     {
      if((ENUM_OBJECT)ObjectGetInteger(0,name,OBJPROP_TYPE)==type) return true;
      ObjectDelete(0,name);
     }
   ResetLastError();
   if(!ObjectCreate(0,name,type,0,0,0))
     {
      if(g_last_panel_layout_error!=id)
        {
         g_last_panel_layout_error=id;
         LogEvent("PANEL_LAYOUT_ERROR",StringFormat("element=%s|scale=%d|error=%d",id,InpPanelScalePercent,GetLastError()));
        }
      return false;
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   return true;
  }

void UiRect(const string id,const int x,const int y,const int w,const int h,const color fill,const color border)
  {
   string sig=StringFormat("R|%d|%d|%d|%d|%d|%d|%d|%d",x,y,w,h,(int)fill,(int)border,g_ui_origin_x,g_ui_origin_y);
   if(!UiStale(id,sig)) return;
   if(!UiEnsure(id,OBJ_RECTANGLE_LABEL)) return;
   string name=O(id);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,g_ui_origin_x+U(x));
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,g_ui_origin_y+U(y));
   ObjectSetInteger(0,name,OBJPROP_XSIZE,MathMax(1,U(w)));
   ObjectSetInteger(0,name,OBJPROP_YSIZE,MathMax(1,U(h)));
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,fill);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,InpPanelZOrder);
  }

// align: 0 = left (x is the left edge), 1 = right (x is the right edge), 2 = center (x is the center)
void UiText(const string id,const int x,const int y,const string text,const color c,const int points=8,
            const string font="Segoe UI",const int max_w=0,const int align=0)
  {
   string sig=StringFormat("T|%d|%d|%d|%d|%d|%s|%d|%d|%d|%d|%d|%s",x,y,(int)c,points,max_w,font,align,g_ui_origin_x,g_ui_origin_y,
                           InpPanelScalePercent,(int)TerminalInfoInteger(TERMINAL_SCREEN_DPI),text);
   if(!UiStale(id,sig)) return;
   if(!UiEnsure(id,OBJ_LABEL)) return;
   string name=O(id);
   string shown=(max_w>0 ? UiFit(text,max_w,font,points) : text);
   ENUM_ANCHOR_POINT anchor=(align==1 ? ANCHOR_RIGHT_UPPER : (align==2 ? ANCHOR_UPPER : ANCHOR_LEFT_UPPER));
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,g_ui_origin_x+U(x));
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,g_ui_origin_y+U(y));
   ObjectSetInteger(0,name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,UiPt(points));
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetString(0,name,OBJPROP_TEXT,shown);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,(shown!=text ? text : "\n"));
   ObjectSetInteger(0,name,OBJPROP_ZORDER,InpPanelZOrder+10);
  }

void UiButton(const string id,const int x,const int y,const int w,const int h,const string text,const string short_text,
              const color fill,const color fg)
  {
   string sig=StringFormat("B|%d|%d|%d|%d|%d|%d|%d|%d|%d|%s|%s",x,y,w,h,(int)fill,(int)fg,g_ui_origin_x,g_ui_origin_y,InpPanelScalePercent,text,short_text);
   if(!UiStale(id,sig)) return;
   if(!UiEnsure(id,OBJ_BUTTON)) return;
   string name=O(id);
   string shown=text;
   if(UiTextWidthPx(shown,UI_FONT_BOLD,8)>U(w-10)) shown=short_text;
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,g_ui_origin_x+U(x));
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,g_ui_origin_y+U(y));
   ObjectSetInteger(0,name,OBJPROP_XSIZE,U(w));
   ObjectSetInteger(0,name,OBJPROP_YSIZE,U(h));
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,fill);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,C_BORDER);
   ObjectSetInteger(0,name,OBJPROP_COLOR,fg);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,UiPt(8));
   ObjectSetString(0,name,OBJPROP_FONT,UI_FONT_BOLD);
   ObjectSetString(0,name,OBJPROP_TEXT,UiFit(shown,w-10,UI_FONT_BOLD,8));
   ObjectSetInteger(0,name,OBJPROP_STATE,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,InpPanelZOrder+20);
  }

void UiChip(const string id,const int x,const int y,const int w,const int h,const string text,const color fill,const color fg,const int points=7)
  {
   UiRect(id+"_B",x,y,w,h,fill,fill);
   UiText(id+"_T",x+w/2,y+MathMax(0,(h-UiLineH(points))/2),text,fg,points,UI_FONT_BOLD,w-4,2);
  }

void UiBar(const string id,const int x,const int y,const int w,const int h,const double fraction,const color fill,const color track)
  {
   UiRect(id+"_K",x,y,w,h,track,track);
   int fw=(int)MathRound(w*Clamp(fraction,0.0,1.0));
   UiRect(id+"_F",x,y,MathMax(1,fw),h,(fw>0 ? fill : track),(fw>0 ? fill : track));
  }

void UiKV(const string id,const int x,const int y,const int w,const string label,const string value,const color vc,const int points=8)
  {
   UiText(id+"_L",x,y+1,label,C_MUTED,7,UI_FONT,0,0);
   int lw=UiTextWidthLogical(label,UI_FONT,7)+8;
   UiText(id+"_V",x+w,y,value,vc,points,UI_FONT_NUM,MathMax(20,w-lw),1);
  }

void UiCard(const string id,const int x,const int y,const int w,const int h,const string title)
  {
   UiRect(id,x,y,w,h,C_BLOCK,C_BORDER);
   UiText(id+"_H",x+10,y+5,title,C_BLUE,7,UI_FONT_BOLD,w-20,0);
  }

void UiSweep()
  {
   string prefix=g_prefix+"PNL_";
   for(int n=ObjectsTotal(0,0,-1)-1;n>=0;n--)
     {
      string obj=ObjectName(0,n,0,-1);
      if(StringFind(obj,prefix)!=0) continue;
      string id=StringSubstr(obj,StringLen(prefix));
      bool keep=false;
      for(int i=ArraySize(g_ui_touched)-1;i>=0;i--) if(g_ui_touched[i]==id) { keep=true; break; }
      if(!keep) { ObjectDelete(0,obj); g_ui_dirty=true; }
     }
  }

void UiPlaceOrigin(const int logical_w,const int logical_h)
  {
   int pw=U(logical_w),ph=U(logical_h);
   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   int mx=U(InpPanelX),my=U(InpPanelY);
   bool right=(InpPanelCorner==CORNER_RIGHT_UPPER || InpPanelCorner==CORNER_RIGHT_LOWER);
   bool lower=(InpPanelCorner==CORNER_LEFT_LOWER || InpPanelCorner==CORNER_RIGHT_LOWER);
   g_ui_origin_x=(right ? cw-pw-mx : mx);
   g_ui_origin_y=(lower ? ch-ph-my : my+NativePanelYOffset());
   if(g_ui_origin_x<0) g_ui_origin_x=0;
   if(g_ui_origin_y<0) g_ui_origin_y=0;
  }

color StateColor()
  {
   if(g_state==ST_BLOCKED) return C_RED;
   if(g_state==ST_PAUSED) return C_YELLOW;
   if(g_state==ST_IN_POSITION) return C_GREEN;
   if(g_state==ST_SIGNAL_READY || g_state==ST_PREFLIGHT) return C_CYAN;
   if(g_state==ST_WAIT_STRUCTURE || g_state==ST_WAIT_RETEST) return C_YELLOW;
   return C_TEXT;
  }


string NewsCountdown()
  {
   if(g_next_news_time<=0) return "";
   long seconds=(long)(g_next_news_time-TimeTradeServer());
   bool future=(seconds>=0); if(seconds<0) seconds=-seconds;
   return StringFormat("%s %02d:%02d:%02d",future ? "EM" : "HA",
                       (int)(seconds/3600),(int)((seconds%3600)/60),(int)(seconds%60));
  }

bool NewsBlocksNow()
  {
   if(!InpUseNewsFilter) return false;
   if(g_news_status=="PRE-BLACKOUT" || g_news_status=="POST-EVENT") return true;
   return g_news_status=="CALENDAR_UNAVAILABLE" && InpNewsFailMode==NEWS_FAIL_CLOSED;
  }


bool NewsWarningNow()
  {
   if(!InpUseNewsFilter || g_next_news_time<=TimeTradeServer()) return false;
   long seconds=(long)(g_next_news_time-TimeTradeServer());
   return seconds<=MathMax(0,InpNewsWarningMinutes)*60;
  }

string NewsPanelText()
  {
   if(!InpUseNewsFilter) return "NOTICIAS: FILTRO DESATIVADO";
   if(g_news_status=="PRE-BLACKOUT")
      return StringFormat("NOTICIAS: PAUSADO PRE-EVENTO | %s | %s",g_next_news_name,NewsCountdown());
   if(g_news_status=="POST-EVENT")
      return StringFormat("NOTICIAS: PAUSADO POS-EVENTO | %s | %s",g_next_news_name,NewsCountdown());
   if(g_news_status=="CALENDAR_UNAVAILABLE")
      return InpNewsFailMode==NEWS_FAIL_CLOSED ? "NOTICIAS: PAUSADO | CALENDARIO INDISPONIVEL" :
                                                "NOTICIAS: ALERTA | CALENDARIO INDISPONIVEL / FAIL-OPEN";
   if(g_news_status=="TESTER_CALENDAR_BYPASS")
      return "NOTICIAS: TESTER | CALENDARIO INDISPONIVEL / BYPASS AUDITADO";
   if(NewsWarningNow())
      return StringFormat("NOTICIAS: ATENCAO PROXIMA | %s | %s",g_next_news_name,NewsCountdown());
   if(g_next_news_time>0)
      return StringFormat("NOTICIAS: PROXIMA | %s | %s",g_next_news_name,NewsCountdown());
   return "NOTICIAS: CALENDARIO LIVRE";
  }


string DirectionPT(const ENUM_NMX_DIRECTION direction)
  {
   if(direction==DIR_BUY) return "COMPRA";
   if(direction==DIR_SELL) return "VENDA";
   return "NEUTRA";
  }

string TrendDirectionPT(const ENUM_NMX_DIRECTION direction)
  {
   if(direction==DIR_BUY) return "ALTA";
   if(direction==DIR_SELL) return "BAIXA";
   return "NEUTRA";
  }

string BiasText(const int index)
  {
   if(index<0 || index>2 || !g_mtf[index].valid) return "SEM DADOS";
   if(g_mtf[index].confirmed) return TrendDirectionPT(g_mtf[index].direction);
   if(g_mtf[index].regime==REGIME_RANGE) return "LATERAL";
   if(g_mtf[index].direction==DIR_BUY) return "ALTA?";
   if(g_mtf[index].direction==DIR_SELL) return "BAIXA?";
   return "NEUTRA";
  }

color BiasColor(const int index)
  {
   if(index<0 || index>2 || !g_mtf[index].valid) return C_MUTED;
   if(!g_mtf[index].confirmed) return g_mtf[index].regime==REGIME_RANGE ? C_MUTED : C_YELLOW;
   return g_mtf[index].direction==DIR_BUY ? C_GREEN : C_RED;
  }

string MTFAlignmentText()
  {
   int aligned=0; ENUM_NMX_DIRECTION consensus=MTFConsensusDirection(aligned);
   if(aligned==3) return StringFormat("3/3 %s TOTAL",TrendDirectionPT(consensus));
   if(aligned==2) return StringFormat("2/3 %s PARCIAL",TrendDirectionPT(consensus));
   int buys=0,sells=0;
   for(int i=0;i<3;i++) if(g_mtf[i].valid && g_mtf[i].confirmed)
     { if(g_mtf[i].direction==DIR_BUY) buys++; else if(g_mtf[i].direction==DIR_SELL) sells++; }
   if(buys>0 && sells>0) return "DIVERGENTE ALTA/BAIXA";
   return "SEM CONSENSO";
  }

bool CurrentPosition(PositionInfoNMX &p)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     { ulong ticket=PositionGetTicket(i); if(ticket>0 && LoadPosition(ticket,p)) return true; }
   ZeroMemory(p); return false;
  }

string DailyBlockText()
  {
   if(g_stats.reason=="DAILY_PROFIT_TARGET") return "PAUSADO | META DIARIA ATINGIDA";
   if(g_stats.reason=="DAILY_LOSS_MONEY" || g_stats.reason=="MAX_DAILY_LOSS") return "PAUSADO | STOP DIARIO ATINGIDO";
   if(g_stats.reason=="MAX_EQUITY_DRAWDOWN") return "PAUSADO | DRAWDOWN MAXIMO";
   if(g_stats.reason=="NEXUS_STATS_UNAVAILABLE") return "PAUSADO | STATS NEXUS INDISPONIVEL";
   if(g_stats.reason=="MAX_TRADES_PER_DAY") return "PAUSADO | LIMITE DE TRADES";
   if(g_stats.reason=="MAX_CONSECUTIVE_LOSSES") return "PAUSADO | PERDAS CONSECUTIVAS";
   return "PAUSADO | LIMITE DE RISCO";
  }

string MotorStatusText()
  {
   PositionInfoNMX position;
    if(CurrentPosition(position))
      return StringFormat("%s | %s %s ABERTA EM GESTAO",g_runtime_trading_enabled ? "ATIVO" : "DESATIVADO",
                           position.type==POSITION_TYPE_BUY ? "COMPRA" : "VENDA",TimeframeShort(position.origin_tf));
   if(g_config_blocked) return "PAUSADO | CONFIGURACAO INVALIDA";
   if(g_stats.blocked) return DailyBlockText();
   if(g_entries_paused) return "PAUSADO MANUALMENTE";
   if(NewsBlocksNow()) return g_news_status=="CALENDAR_UNAVAILABLE" ? "PAUSADO | CALENDARIO INDISPONIVEL" : "PAUSADO POR NOTICIA";

   if(g_candidate.valid)
     {
      string side=DirectionPT(g_candidate.direction);
      string prefix=(g_runtime_trading_enabled ? "ATIVO" : "DESATIVADO");
      if(g_state==ST_WAIT_STRUCTURE && g_live_prearmed)
         return StringFormat("%s | %s | SCORE LIVE PASSA | FECHA %ds",prefix,side,SecondsToCurrentBarClose());
      if(g_state==ST_WAIT_STRUCTURE) return StringFormat("%s | POSSIVEL %s | AGUARDA ESTRUTURA",prefix,side);
      if(g_state==ST_WAIT_RETEST) return StringFormat("%s | POSSIVEL %s | AGUARDA RETESTE",prefix,side);
      if(g_state==ST_SIGNAL_READY) return StringFormat("%s | %s PRONTA",prefix,side);
      if(g_state==ST_PREFLIGHT) return StringFormat("%s | VALIDANDO EXECUCAO",side);
      if(g_state==ST_ORDER_PENDING) return StringFormat("%s ENVIADA | AGUARDA CORRETORA",side);
     }

   int aligned=0; ENUM_NMX_DIRECTION consensus=MTFConsensusDirection(aligned);
   if(!g_runtime_trading_enabled && consensus!=DIR_NONE)
      return StringFormat("DESATIVADO | MODO ANALISE | VIES %s %d/3",DirectionPT(consensus),aligned);
   if(!g_runtime_trading_enabled) return "DESATIVADO | MODO ANALISE";
   if(consensus!=DIR_NONE) return StringFormat("ATIVO | AGUARDANDO %s | CONTEXTO %d/3",DirectionPT(consensus),aligned);
   return "ATIVO | AGUARDANDO | SEM CONSENSO MTF";
  }

color MotorStatusColor()
  {
   if(!g_runtime_trading_enabled) return C_RED;
   PositionInfoNMX position; if(CurrentPosition(position)) return C_GREEN;
   if(g_config_blocked) return C_RED;
   if(g_stats.blocked || NewsBlocksNow()) return C_RED;
   if(g_entries_paused) return C_YELLOW;
   if(g_candidate.valid && (g_state==ST_SIGNAL_READY || g_state==ST_PREFLIGHT)) return C_CYAN;
   if(g_candidate.valid) return C_YELLOW;
   int aligned=0; ENUM_NMX_DIRECTION consensus=MTFConsensusDirection(aligned);
   if(consensus==DIR_BUY) return C_GREEN;
   if(consensus==DIR_SELL) return C_RED;
   return C_TEXT;
  }

string ExecutionStatusText()
  { return g_runtime_trading_enabled ? "EXECUCAO ATIVA" : "EXECUCAO DESATIVADA"; }

color ExecutionStatusColor()
  { return g_runtime_trading_enabled ? C_GREEN : C_RED; }

string ShortDuration(const long seconds)
  {
   long safe=MathMax(0,seconds);
   long hours=safe/3600;
   long minutes=(safe%3600)/60;
   long secs=safe%60;
   if(hours>0) return StringFormat("%02d:%02d:%02d",(int)hours,(int)minutes,(int)secs);
   return StringFormat("%02d:%02d",(int)minutes,(int)secs);
  }

string PositionProtectionText(const PositionInfoNMX &p)
  {
   bool trail_active=ReadPositionState(p,"TRAIL",0.0)>0.5;
   if(trail_active)
      return StringFormat("TRAILING PROTEGE LUCRO | SL MOVEL %.*f",g_symbol.digits,p.stop);
   if(InpProtectionMode==PROTECTION_NONE)
      return "SEM STOP INICIAL | RISCO NAO LIMITADO";
   if(InpProtectionMode==PROTECTION_IMMEDIATE)
      return StringFormat("STOP IMEDIATO | SL BROKER %.*f",g_symbol.digits,p.stop);
   if(Positive(p.stop))
      return StringFormat("STOP ATRASADO ATIVO | SL %.*f",g_symbol.digits,p.stop);
   datetime since=(datetime)(long)ReadPositionState(p,"NEGATIVE_SINCE",0.0);
   if(since<=0) return StringFormat("STOP ATRASADO | AGUARDA NEGATIVO | %d MIN",DelayedStopMinutes(p.origin_tf));
   long required=(long)DelayedStopMinutes(p.origin_tf)*60;
   long elapsed=MathMax(0,(long)(TimeTradeServer()-since));
   return StringFormat("STOP ATIVA EM %s | NEGATIVO %s",ShortDuration(required-elapsed),ShortDuration(elapsed));
  }

string PositionDevelopmentState(const PositionInfoNMX &p,const double current_profit,const double peak)
  {
   if(ReadPositionState(p,"TRAIL",0.0)>0.5) return "LUCRO PROTEGIDO";
   if(InpUseTrailing && InpTrailingMode==TRAIL_MONEY && peak>=InpTrailingActivationMoney-0.005)
      return "GATILHO ATINGIDO / PROTECAO PENDENTE";
   if(current_profit<-0.005)
      return (peak>0.005 ? "REACAO FALHOU / SEM CONTINUIDADE" : "SEM CONTINUIDADE");
   if(current_profit>0.005) return "REACAO ABAIXO DO GATILHO";
   return "SEM DESLOCAMENTO";
  }


color PositionDevelopmentColor(const PositionInfoNMX &p,const double current_profit)
  {
   if(ReadPositionState(p,"TRAIL",0.0)>0.5) return C_GREEN;
   if(current_profit<-0.005) return C_RED;
   if(current_profit>0.005) return C_YELLOW;
   return C_TEXT;
  }

string PositionTrailProgressText(const PositionInfoNMX &p,const double current_profit)
  {
   double peak=ReadPositionState(p,"PEAK",current_profit);
   if(!InpUseTrailing) return "TRAIL DESLIGADO";
   if(ReadPositionState(p,"TRAIL",0.0)>0.5)
     {
      if(InpTrailingMode==TRAIL_MONEY)
         return StringFormat("TRAIL ATIVO | PISO %.2f | RECUO %.2f | PICO %.2f",TrailFloorMoney(peak),TrailDistanceMoney(peak),peak);
      return PositionProtectionText(p);
     }
   if(InpTrailingMode!=TRAIL_MONEY) return "TRAIL AGUARDA GATILHO | "+(Positive(p.stop) ? "STOP ATIVO" : "STOP PENDENTE");
   return StringFormat("TRAIL ARMA EM PICO %.2f | PICO %.2f | FALTA %.2f",InpTrailingActivationMoney,peak,
                       MathMax(0.0,InpTrailingActivationMoney-peak));
  }


color PositionProtectionColor(const PositionInfoNMX &p)
  {
   if(ReadPositionState(p,"TRAIL",0.0)>0.5) return C_GREEN;
   if(InpProtectionMode==PROTECTION_NONE && !Positive(p.stop)) return C_RED;
   if(InpProtectionMode==PROTECTION_DELAYED && !Positive(p.stop)) return C_YELLOW;
   return C_TEXT;
  }


string NearestLevelText()
  {
   if(ArraySize(g_levels)==0 || ArraySize(g_rates)<2 || !Positive(g_atr)) return "--";
   double best=DBL_MAX; int idx=-1;
   for(int i=0;i<ArraySize(g_levels);i++)
     {
      double d=MathAbs(g_levels[i].price-g_rates[1].close);
      if(d<best) { best=d; idx=i; }
     }
   if(idx<0) return "--";
   return StringFormat("%s %.2f ATR",LevelText(g_levels[idx].type),best/g_atr);
  }

string ScorePipelineText()
  {
   if(g_candidate.valid && g_state==ST_WAIT_STRUCTURE)
      return (g_live_score_valid ? StringFormat("L%.0f/F--",g_live_score) : "L--/F--");
   if(g_candidate.valid && g_candidate.score>0.0) return StringFormat("F%.0f",g_candidate.score);
   return "--";
  }

string StructurePipelineText()
  {
   if(g_candidate.valid && g_state==ST_WAIT_STRUCTURE)
      return g_live_prearmed ? "L-OK" : (g_live_structure_ready ? "LIVE" : "--");
   return (g_state>=ST_WAIT_RETEST && g_candidate.valid ? "OK" : "--");
  }

string CandidatePanelText()
  {
   if(!g_candidate.valid) return "SETUP -- | DIRECAO -- | SCORE --";
   if(g_state==ST_WAIT_STRUCTURE)
      return StringFormat("%s | %s | LIVE %s | FECH --%s",SetupText(g_candidate.setup),
                          DirectionText(g_candidate.direction),
                          g_live_score_valid ? DoubleToString(g_live_score,0) : "--",
                          g_live_prearmed ? " | PROJ PASSA" : "");
   return StringFormat("%s | %s | FECH %.0f/100",SetupText(g_candidate.setup),
                       DirectionText(g_candidate.direction),g_candidate.score);
  }

string PipelineText()
  {
   string liq=(ArraySize(g_levels)>0 ? "OK" : "--");
   string evt=(g_candidate.valid ? "OK" : "--");
   string flow=(g_candidate.valid && g_candidate.flow.valid ? "OK" : "--");
   string str=StructurePipelineText();
   string score=ScorePipelineText();
   string ret=(g_profile.entry_mode==ENTRY_CONFIRMATION ? "N/A" : (g_state==ST_WAIT_RETEST ? "..." : (g_state>ST_WAIT_RETEST ? "OK" : "--")));
   string pre=(g_state==ST_PREFLIGHT ? "..." : (g_state>=ST_ORDER_PENDING ? "OK" : "--"));
   string ord=(g_state==ST_IN_POSITION ? "OK" : "--");
   return StringFormat("LIQ %s | EVT %s | FLOW %s | STR %s | SCR %s | RET %s | PRE %s | ORD %s",liq,evt,flow,str,score,ret,pre,ord);
  }

void DeletePanel()
  {
   ObjectsDeleteAll(0,g_prefix);
   g_rendered_panel_mode=-1;
   ChartRedraw();
  }

void DeleteClearMenuObjects()
  {
   ObjectDelete(0,O("BTN_CACHE"));
   ObjectDelete(0,O("BTN_EAOBJ"));
   ObjectDelete(0,O("BTN_CHART"));
   ObjectDelete(0,O("BTN_CANCEL"));
  }

ENUM_LINE_STYLE LevelLineStyle(const ENUM_NMX_LEVEL_TYPE type)
  {
   if(type==LEVEL_PDH || type==LEVEL_PDL) return STYLE_SOLID;
   if(type==LEVEL_PWH || type==LEVEL_PWL) return STYLE_DASH;
   if(type==LEVEL_SESSION_HIGH || type==LEVEL_SESSION_LOW) return STYLE_DASHDOT;
   if(type==LEVEL_EQUAL_HIGHS || type==LEVEL_EQUAL_LOWS) return STYLE_DASHDOTDOT;
   return STYLE_DOT;
  }

string LevelRoleText(const MarketLevel &level)
  {
   string side=(level.side>0 ? "LIQUIDEZ ACIMA / POSSIVEL ALVO OU REACAO" :
                              "LIQUIDEZ ABAIXO / POSSIVEL ALVO OU REACAO");
   return StringFormat("%s | %s | QUAL %.0f | TESTES %d | CONFL %d",
                       LevelText(level.type),side,level.quality,level.tests,level.confluences);
  }

bool DrawLevelLines()
  {
   // Visual-only reconciliation.  Level lines are independent from the panel:
   // hiding/minimizing/rebuilding the panel must never remove liquidity levels.
   if(ArraySize(g_rates)<2 || ArraySize(g_levels)<=0) return false;

   bool selected[]; ArrayResize(selected,ArraySize(g_levels)); ArrayInitialize(selected,false);
   int drawn=0;

   // Keep the same semantic selection used by the baseline: nearest 12 levels.
   while(drawn<12)
     {
      int idx=-1; double best=DBL_MAX;
      for(int i=0;i<ArraySize(g_levels);i++)
        {
         if(selected[i] || !g_levels[i].valid) continue;
         double d=MathAbs(g_levels[i].price-g_rates[1].close);
         if(d<best) { best=d; idx=i; }
        }
      if(idx<0) break;
      selected[idx]=true;
      drawn++;
     }

   bool changed=false;
   for(int i=0;i<ArraySize(g_levels);i++)
     {
      if(!selected[i]) continue;
      string name=L(i);
      if(ObjectFind(0,name)<0)
        {
         ResetLastError();
         if(!ObjectCreate(0,name,OBJ_HLINE,0,0,g_levels[i].price))
           {
            LogEvent("LEVEL_LINE_CREATE_FAILED",StringFormat("name=%s|index=%d|price=%.10f|error=%d",
                     name,i,g_levels[i].price,GetLastError()));
            continue;
           }
         changed=true;
        }

      double old_price=ObjectGetDouble(0,name,OBJPROP_PRICE);
      if(MathAbs(old_price-g_levels[i].price) > MathMax(g_symbol.tick_size*0.25,1e-12))
        {
         ObjectSetDouble(0,name,OBJPROP_PRICE,g_levels[i].price);
         changed=true;
        }

      color c=(g_levels[i].side>0 ? C_RED : C_CYAN);
      ObjectSetInteger(0,name,OBJPROP_COLOR,c);
      ObjectSetInteger(0,name,OBJPROP_STYLE,LevelLineStyle(g_levels[i].type));
      ObjectSetInteger(0,name,OBJPROP_WIDTH,g_levels[i].quality>=85.0 ? 2 : 1);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,5);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetString(0,name,OBJPROP_TEXT,LevelRoleText(g_levels[i]));
      ObjectSetString(0,name,OBJPROP_TOOLTIP,LevelRoleText(g_levels[i]));
     }

   // Delete only obsolete Nexus level-line objects. Never wipe all lines first.
   string lvl_prefix=g_prefix+"LVL_";
   for(int n=ObjectsTotal(0,0,-1)-1;n>=0;n--)
     {
      string obj=ObjectName(0,n,0,-1);
      if(StringFind(obj,lvl_prefix)!=0) continue;
      bool keep=false;
      for(int i=0;i<ArraySize(g_levels);i++)
        {
         if(selected[i] && obj==L(i)) { keep=true; break; }
        }
      if(!keep)
        {
         if(ObjectDelete(0,obj)) changed=true;
        }
     }
   return changed;
  }

ulong g_planned_loss_ticket=0;
double g_planned_loss_value=0.0;

double PlannedLossMoney(const PositionInfoNMX &p)
  {
   if(g_planned_loss_ticket==p.ticket) return g_planned_loss_value;
   double stop=0.0,pnl=0.0;
   double loss=0.0;
   if(PlannedStopForPosition(p,stop))
     {
      ENUM_ORDER_TYPE type=(p.type==POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
      if(ProfitAtPrice(type,p.volume,p.open_price,stop,pnl)) loss=MathAbs(pnl);
     }
   g_planned_loss_ticket=p.ticket; g_planned_loss_value=loss;
   return loss;
  }

double BreakevenWinRatePercent()
  {
   double ref_stop=((InpStopMode==STOP_MONEY || InpStopMode==STOP_STRUCTURE_CAPPED_BY_MONEY) ? InpStopMoney : 0.0);
   double ref_target=((InpTargetMode==TARGET_MONEY || InpTargetMode==TARGET_MONEY_THEN_TRAILING) ? InpTargetMoney : 0.0);
   if(!Positive(ref_stop) || !Positive(ref_target)) return 0.0;
   return ref_stop/(ref_stop+ref_target)*100.0;
  }

bool PipelineStateAfterRetest()
  { return g_state==ST_SIGNAL_READY || g_state==ST_PREFLIGHT || g_state==ST_ORDER_PENDING || g_state==ST_IN_POSITION; }

// st: 0 = inativo, 1 = em andamento, 2 = confirmado
void PipelineSteps(string &labels[],int &st[])
  {
   ArrayResize(labels,8); ArrayResize(st,8);
   labels[0]="LIQ"; st[0]=(ArraySize(g_levels)>0 ? 2 : 0);
   labels[1]="EVT"; st[1]=(g_candidate.valid ? 2 : 0);
   labels[2]="FLOW"; st[2]=(g_candidate.valid && g_candidate.flow.valid ? 2 : 0);
   string structure=StructurePipelineText();
   labels[3]="STR"; st[3]=((structure=="OK" || structure=="L-OK") ? 2 : (structure=="LIVE" ? 1 : 0));
   labels[4]="SCR --"; st[4]=0;
   if(g_candidate.valid && g_state==ST_WAIT_STRUCTURE && g_live_score_valid)
     { labels[4]=StringFormat("SCR L%.0f",g_live_score); st[4]=(g_live_score>=g_profile.minimum_score ? 2 : 1); }
   else if(g_candidate.valid && g_candidate.score>0.0)
     { labels[4]=StringFormat("SCR %.0f",g_candidate.score); st[4]=(g_candidate.score>=g_profile.minimum_score ? 2 : 0); }
   labels[5]="RET";
   if(g_profile.entry_mode==ENTRY_CONFIRMATION) { labels[5]="RET n/a"; st[5]=0; }
   else st[5]=(g_state==ST_WAIT_RETEST ? 1 : (g_candidate.valid && PipelineStateAfterRetest() ? 2 : 0));
   labels[6]="PRE"; st[6]=(g_state==ST_PREFLIGHT ? 1 : ((g_state==ST_ORDER_PENDING || g_state==ST_IN_POSITION) ? 2 : 0));
   labels[7]="ORD"; st[7]=(g_state==ST_IN_POSITION ? 2 : (g_state==ST_ORDER_PENDING ? 1 : 0));
  }

void RenderLiveScoreOnly()
  {
   if(!InpShowPanel || g_panel_mode!=PANEL_EXPANDED) return;
   ulong now=GetTickCount64();
   if(now-g_last_live_render_ms<(ulong)MathMax(100,InpLiveScoreRefreshMs)) return;
   g_last_live_render_ms=now;
   PositionInfoNMX position;
   if((g_candidate.valid && g_state==ST_WAIT_STRUCTURE) || CurrentPosition(position)) BuildPanel();
  }

int PanelContentHeight(const bool has_position)
  {
   int h=8+46+6+52+6+124+6+(has_position ? 128 : 96)+6+78+6+130+6+18+6+32+8;
   if(g_clear_menu) h+=38;
   return h;
  }

void BuildPanel()
  {
   if(!InpShowPanel) return;
   int mode=(int)g_panel_mode;
   int render_sig=(int)InpPanelCorner*1000000+InpPanelScalePercent*1000+(int)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   if(g_rendered_panel_mode!=mode || g_last_panel_scale!=render_sig)
     {
      ObjectsDeleteAll(0,g_prefix+"PNL_");
      ArrayResize(g_ui_cache,0);
      if(g_panel_layout_logged)
         LogEvent("PANEL_OBJECT_REBUILT",StringFormat("mode=%d|scale=%d|dpi=%d",mode,InpPanelScalePercent,(int)TerminalInfoInteger(TERMINAL_SCREEN_DPI)));
      g_rendered_panel_mode=mode; g_last_panel_scale=render_sig;
     }
   if(!g_panel_layout_logged)
     {
      g_panel_layout_logged=true;
      LogEvent("PANEL_LAYOUT_INIT",StringFormat("width=%d|scale=%d|dpi=%d|ui_factor=%.3f",UI_PANEL_W,InpPanelScalePercent,
               (int)TerminalInfoInteger(TERMINAL_SCREEN_DPI),UiDpiFactor()*UiPercent()));
     }
   ArrayResize(g_ui_touched,0);
   g_ui_dirty=false;

   // ---- cabecalho (estado global) -----------------------------------------
   string chip_text="ATIVO"; color chip_color=C_GREEN;
   if(!g_runtime_trading_enabled) { chip_text="DESATIVADO"; chip_color=C_RED; }
   else if(g_entries_paused) { chip_text="PAUSADO"; chip_color=C_YELLOW; }

   if(g_panel_mode==PANEL_MINIMIZED)
     {
      UiPlaceOrigin(UI_PANEL_MIN_W,38);
      UiRect("MIN_BG",0,0,UI_PANEL_MIN_W,38,C_BG,C_BORDER);
      UiText("MIN_TITLE",12,10,"NEXUS GUARD PRO",C_TEXT,9,UI_FONT_BOLD,150);
      UiChip("MIN_CHIP",172,9,92,20,chip_text,chip_color,C_BG);
      UiButton("BTN_MAX",UI_PANEL_MIN_W-36,6,28,26,"+","+",C_BLOCK,C_CYAN);
      UiSweep();
      if(g_ui_dirty) ChartRedraw();
      return;
     }

   PositionInfoNMX p; bool has_pos=CurrentPosition(p);
   int ph=PanelContentHeight(has_pos);
   UiPlaceOrigin(UI_PANEL_W,ph);
   const int X=8, W=UI_PANEL_W-16, CX=18, CW=UI_PANEL_W-36;
   const int HALF=(CW-12)/2, RX=CX+HALF+12;

   UiRect("BG",0,0,UI_PANEL_W,ph,C_BG,C_BORDER);
   UiText("TITLE",14,9,"NEXUS GUARD PRO",C_TEXT,11,UI_FONT_BOLD,230);
   UiText("SUB",14,29,StringFormat("%s | %s | %s | %s | magic %I64d",_Symbol,TimeframeShort(g_profile.tf),g_profile.name,AccountModeText(),g_magic),C_MUTED,7,UI_FONT,300);
   UiChip("HDR_CHIP",UI_PANEL_W-8-26-8-98,12,98,22,chip_text,chip_color,C_BG,8);
   UiButton("BTN_MIN",UI_PANEL_W-8-26,10,26,26,"-","-",C_BLOCK,C_CYAN);

   // ---- decisao: por que opera / nao opera ----------------------------------
   int y=60;
   color sev=MotorStatusColor();
   UiRect("WHY",X,y,W,52,C_BLOCK,C_BORDER);
   UiRect("WHY_A",X,y,4,52,sev,sev);
   UiText("WHY_1",20,y+6,MotorStatusText(),sev,10,UI_FONT_BOLD,CW-4);
   UiText("WHY_2",20,y+25,OperationalDetailText(),(g_config_blocked || g_breaker_reason!="") ? C_RED : C_TEXT,8,UI_FONT,CW-4);
   UiText("WHY_3",20,y+38,StringFormat("interno: %s | %s",StateText(g_state),g_reason),C_MUTED,7,UI_FONT,CW-4);

   // ---- risco e dia ---------------------------------------------------------
   y+=58;
   UiCard("RISK",X,y,W,124,"RISCO E DIA");
   double floating=NexusOwnFloatingNet();
   double loss_use=(Positive(InpMaxDailyLossPercent) ? g_stats.daily_loss_percent/InpMaxDailyLossPercent : 0.0);
   UiKV("K_NET",CX,y+22,HALF,"P/L DIA",StringFormat("%+.2f",g_stats.net),g_stats.net>=0.0 ? C_GREEN : C_RED,9);
   UiKV("K_GL",CX,y+39,HALF,"GANHO / PERDA",StringFormat("%.2f / %.2f",g_stats.realized_profit,g_stats.realized_loss),g_stats.realized_loss>0.005 ? C_YELLOW : C_TEXT);
   UiKV("K_TR",CX,y+56,HALF,"TRADES / W-L-BE",StringFormat("%d / %d-%d-%d",g_stats.trades,g_stats.wins,g_stats.losses,g_stats.breakeven),C_TEXT);
   UiKV("K_SEQ",CX,y+73,HALF,"PERDAS SEGUIDAS",StringFormat("%d / %d",g_stats.consecutive_losses,InpMaxConsecutiveLosses),
        g_stats.consecutive_losses>=InpMaxConsecutiveLosses-1 && g_stats.consecutive_losses>0 ? C_YELLOW : C_TEXT);
   UiKV("K_DL",RX,y+22,HALF,"PERDA DIA / LIMITE",StringFormat("%.2f%% / %.2f%%",g_stats.daily_loss_percent,InpMaxDailyLossPercent),loss_use>=0.8 ? C_RED : (loss_use>=0.5 ? C_YELLOW : C_TEXT));
   UiKV("K_DD",RX,y+39,HALF,"DRAWDOWN "+(InpEquityGuardScope==EQUITY_GUARD_NEXUS_MAGIC ? "NEXUS" : "CONTA"),
        StringFormat("%.2f%% / %.2f%%",g_stats.drawdown_percent,InpMaxDrawdownPercent),g_stats.drawdown_percent>=InpMaxDrawdownPercent*0.8 ? C_RED : C_TEXT);
   UiKV("K_FL",RX,y+56,HALF,"FLUTUANTE NEXUS",
        StringFormat("%+.2f / %s",floating,InpUseFloatingBreaker && Positive(InpFloatingLossTotalMoney) ? StringFormat("-%.0f",InpFloatingLossTotalMoney) : "SEM LIMITE"),
        floating<-0.005 ? ((InpUseFloatingBreaker && Positive(InpFloatingLossTotalMoney) && -floating>=InpFloatingLossTotalMoney*0.7) ? C_RED : C_YELLOW) : C_TEXT);
   if(InpUseDailyProfitTarget)
      UiKV("K_4",RX,y+73,HALF,"META DIA",StringFormat("%.2f / %.2f",g_stats.net,InpDailyProfitTargetMoney),g_stats.net>=InpDailyProfitTargetMoney ? C_GREEN : C_TEXT);
   else
     {
      double be=BreakevenWinRatePercent();
      UiKV("K_4",RX,y+73,HALF,"WR EQUILIBRIO",(be>0.0 ? StringFormat("%.1f%%",be) : "--"),be>=90.0 ? C_YELLOW : C_TEXT);
     }
   UiBar("B_DL",CX,y+94,HALF,5,loss_use,loss_use>=0.8 ? C_RED : (loss_use>=0.5 ? C_YELLOW : C_GREEN),C_BORDER);
   double brk_use=((InpUseFloatingBreaker && Positive(InpFloatingLossTotalMoney) && floating<0.0) ? -floating/InpFloatingLossTotalMoney : 0.0);
   UiBar("B_BR",RX,y+94,HALF,5,brk_use,brk_use>=0.7 ? C_RED : C_YELLOW,C_BORDER);
   UiText("B_DL_T",CX,y+102,"uso do limite diario",C_MUTED,7,UI_FONT,HALF);
   UiText("B_BR_T",RX,y+102,InpUseFloatingBreaker ? "uso do disjuntor flutuante" : "DISJUNTOR DE PERDA FLUTUANTE: DESLIGADO",
          InpUseFloatingBreaker ? C_MUTED : (InpProtectionMode!=PROTECTION_IMMEDIATE ? C_YELLOW : C_MUTED),7,UI_FONT,HALF);
   UiText("B_SAFE",CX,y+113,RiskSafetyStateText(),RiskSafetyStateText()=="BASELINE SEGURO" ? C_GREEN : C_YELLOW,7,UI_FONT,CW);

   // ---- posicao / candidato -------------------------------------------------
   y+=130;
   if(has_pos)
     {
      UiCard("POS",X,y,W,128,"POSICAO");
      double risk=InitialRiskDistance(p); double r=PositionR(p,risk); double net_position=PositionNetEstimate(p);
      double peak=ReadPositionState(p,"PEAK",net_position); double trough=ReadPositionState(p,"TROUGH",net_position);
      long duration=MathMax(0,(long)(TimeTradeServer()-p.open_time));
      bool buy=(p.type==POSITION_TYPE_BUY);
      color pl_color=(net_position>0.005 ? C_GREEN : (net_position<-0.005 ? C_RED : C_TEXT));
      UiChip("POS_SIDE",CX,y+21,46,17,buy ? "BUY" : "SELL",buy ? C_GREEN : C_RED,C_BG,7);
      UiText("POS_ID",CX+54,y+22,StringFormat("%.2f @ %.*f",p.volume,g_symbol.digits,p.open_price),C_TEXT,9,UI_FONT_NUM,HALF-54);
      UiText("POS_PL",CX,y+42,StringFormat("%+.2f",net_position),pl_color,16,UI_FONT_NUM,HALF);
      UiText("POS_ST",CX,y+70,PositionDevelopmentState(p,net_position,peak),PositionDevelopmentColor(p,net_position),7,UI_FONT_BOLD,HALF);
      UiKV("P_T",RX,y+22,HALF,"TEMPO",ShortDuration(duration),C_TEXT);
      UiKV("P_MAX",RX,y+39,HALF,"MAX (MFE)",StringFormat("%+.2f",peak),C_TEXT);
      double planned=PlannedLossMoney(p);
      UiKV("P_MIN",RX,y+56,HALF,"MIN (MAE)",StringFormat("%+.2f%s",trough,(planned>0.0 && trough<0.0 && -trough>planned*1.05) ? StringFormat("  %.1fx plan.",-trough/planned) : ""),
           (planned>0.0 && -trough>planned*1.05) ? C_RED : C_TEXT);
      UiKV("P_R",RX,y+73,HALF,"R | SL | TP",StringFormat("%.2f | %s | %s",r,Positive(p.stop) ? DoubleToString(p.stop,g_symbol.digits) : "SEM SL",
           Positive(p.target) ? DoubleToString(p.target,g_symbol.digits) : "OFF"),Positive(p.stop) ? C_TEXT : C_YELLOW,7);
      double act=InpTrailingActivationMoney;
      bool trail_on=(ReadPositionState(p,"TRAIL",0.0)>0.5);
      UiBar("POS_TB",CX,y+90,CW,5,(InpUseTrailing && InpTrailingMode==TRAIL_MONEY && Positive(act)) ? peak/act : 0.0,trail_on ? C_GREEN : C_YELLOW,C_BORDER);
      UiText("POS_TR",CX,y+98,PositionTrailProgressText(p,net_position),PositionProtectionColor(p),7,UI_FONT,CW);
      string warn="";
      if(!Positive(p.stop))
        {
         warn=InpUseFloatingBreaker ? "SEM SL NO BROKER | DISJUNTOR DE PERDA FLUTUANTE ATIVO" :
              "SEM SL NO BROKER | SEM DISJUNTOR: PERDA ABERTA NAO LIMITADA";
         UiText("POS_W",CX,y+111,warn,InpUseFloatingBreaker ? C_YELLOW : C_RED,7,UI_FONT_BOLD,CW);
        }
      else UiText("POS_W",CX,y+111,PositionProtectionText(p),C_MUTED,7,UI_FONT,CW);
      y+=134;
     }
   else
     {
      UiCard("POS",X,y,W,96,"CANDIDATO / CONFIGURACAO");
      UiText("POS_ID",CX,y+21,"SEM POSICAO ABERTA",C_TEXT,9,UI_FONT_BOLD,CW);
      UiText("POS_C1",CX,y+40,CandidatePanelText(),g_live_structure_ready ? C_CYAN : C_TEXT,8,UI_FONT,CW);
      string cfg=(InpRiskMode==RISK_FIXED_LOT ? StringFormat("LOTE FIXO %.2f",InpFixedLot) : StringFormat("RISCO $%.2f",RiskBudgetMoney()));
      cfg+=StringFormat(" | TP $%.2f | TRAIL $%.2f x%.2f^%.2f | STOP REF $%.2f",InpTargetMoney,InpTrailingActivationMoney,InpTrailRatio,InpTrailExponent,InpStopMoney);
      UiText("POS_C2",CX,y+58,cfg,C_MUTED,7,UI_FONT_NUM,CW);
      UiText("POS_C3",CX,y+74,StringFormat("%s | cooldown %d/%d barras | magic %I64d",ProtectionModeText(),InpCooldownBars,InpCooldownAfterRejectBars,g_magic),
             InpProtectionMode==PROTECTION_IMMEDIATE ? C_MUTED : C_YELLOW,7,UI_FONT,CW);
      y+=102;
     }

   // ---- sinal / pipeline ----------------------------------------------------
   UiCard("SIG",X,y,W,78,"SINAL / PIPELINE");
   string step_name[]; int step_state[];
   PipelineSteps(step_name,step_state);
   int chip_w=(CW-7*4)/8;
   for(int i=0;i<8;i++)
     {
      color fill=(step_state[i]==2 ? C_GREEN : (step_state[i]==1 ? C_YELLOW : C_BORDER));
      color fg=(step_state[i]==0 ? C_MUTED : C_BG);
      UiChip(StringFormat("PIPE%d",i),CX+i*(chip_w+4),y+20,chip_w,18,step_name[i],fill,fg,7);
     }
   UiText("SIG_C",CX,y+43,CandidatePanelText(),g_live_structure_ready ? C_CYAN : C_TEXT,8,UI_FONT,CW);
   double score_value=(g_candidate.valid ? (g_state==ST_WAIT_STRUCTURE && g_live_score_valid ? g_live_score : g_candidate.score) : 0.0);
   UiBar("SIG_B",CX,y+63,CW-60,6,score_value/100.0,score_value>=g_profile.minimum_score ? C_GREEN : C_YELLOW,C_BORDER);
   UiRect("SIG_M",CX+(int)MathRound((CW-60)*Clamp(g_profile.minimum_score/100.0,0.0,1.0)),y+60,2,12,C_TEXT,C_TEXT);
   UiText("SIG_N",CX+CW,y+60,StringFormat("min %.0f",g_profile.minimum_score),C_MUTED,7,UI_FONT_NUM,56,1);

   // ---- mercado e contexto --------------------------------------------------
   y+=84;
   UiCard("MKT",X,y,W,130,"MERCADO E CONTEXTO");
   double spread_limit=EffectiveSpreadATRLimit();
   UiKV("M_REG",CX,y+22,HALF,"REGIME",RegimeText(g_regime),C_CYAN);
   UiKV("M_ER",CX,y+39,HALF,"ER / MOVIMENTO",StringFormat("%.3f / %.2f ATR",g_regime_efficiency,g_regime_move_atr),C_TEXT);
   UiKV("M_ATR",CX,y+56,HALF,"ATR",StringFormat("%s (%.2fx)",DoubleToString(g_atr,g_symbol.digits),g_atr_ratio),C_TEXT);
   UiKV("M_SPR",CX,y+73,HALF,"SPREAD / LIMITE",StringFormat("%.0f pts | %.3f / %.3f",g_last_spread_points,g_last_spread_atr,spread_limit),g_last_spread_atr<=spread_limit ? C_TEXT : C_RED,7);
   UiKV("M_LVL",RX,y+22,HALF,"NIVEL MAIS PROXIMO",NearestLevelText(),C_TEXT);
   UiKV("M_MTF",RX,y+39,HALF,"ALINHAMENTO MTF",MTFAlignmentText()+(InpRequireFullMTFAlignment ? " [FILTRO]" : ""),C_TEXT,7);
   UiKV("M_SPL",RX,y+56,HALF,"SPREAD APRENDIZADO",SpreadLearningText(),C_MUTED,7);
   UiKV("M_NWS",RX,y+73,HALF,"CALENDARIO",g_news_status,NewsBlocksNow() ? C_RED : (NewsWarningNow() ? C_YELLOW : C_GREEN),7);
   int mtf_w=(CW-2*6)/3;
   string mtf_name[3]={"M1","M5","M30"};
   for(int i=0;i<3;i++)
     {
      color bc=BiasColor(i);
      string txt=(i<2 ? StringFormat("%s %s ER %.2f",mtf_name[i],BiasText(i),g_mtf[i].efficiency) : StringFormat("%s %s",mtf_name[i],BiasText(i)));
      UiRect(StringFormat("MTF%d_B",i),CX+i*(mtf_w+6),y+92,mtf_w,18,C_BG,bc);
      UiText(StringFormat("MTF%d_T",i),CX+i*(mtf_w+6)+mtf_w/2,y+95,txt,bc,7,UI_FONT_BOLD,mtf_w-6,2);
     }
   UiText("M_NEWS",CX,y+114,NewsPanelText(),NewsBlocksNow() ? C_RED : (NewsWarningNow() ? C_YELLOW : C_MUTED),7,UI_FONT,CW);

   // ---- telemetria ----------------------------------------------------------
   y+=136;
   UiText("TEL",CX,y+2,StringFormat("build %s | run %s | cfg %s | CSV %s | evento: %s",NMX_BUILD_ID,ShortRunID(),g_config_hash,g_telemetry_ok ? "OK" : "ERRO",g_last_event),
          g_telemetry_ok ? C_MUTED : C_RED,7,UI_FONT,CW);

   // ---- comandos ------------------------------------------------------------
   y+=24;
   if(g_clear_menu)
     {
      int mw=(CW-3*6)/4;
      UiButton("BTN_CACHE",CX,y,mw,28,"CACHE","CACHE",C_BLOCK,C_TEXT);
      UiButton("BTN_EAOBJ",CX+(mw+6),y,mw,28,"OBJETOS EA","OBJ EA",C_BLOCK,C_TEXT);
      UiButton("BTN_CHART",CX+2*(mw+6),y,mw,28,TimeLocal()<=g_clear_armed_until ? "CONFIRMAR" : "GRAFICO TODO",TimeLocal()<=g_clear_armed_until ? "CONFIRMAR" : "GRAFICO",C_RED,C_TEXT);
      UiButton("BTN_CANCEL",CX+3*(mw+6),y,mw,28,"CANCELAR","CANCELAR",C_BLOCK,C_TEXT);
      y+=38;
     }
   int bw=(CW-3*6)/4;
   UiButton("BTN_EXPORT",CX,y,bw,32,"EXPORTAR CSV","EXPORTAR",C'31,86,144',C_TEXT);
   UiButton("BTN_CLEAR",CX+(bw+6),y,bw,32,g_clear_menu ? "FECHAR" : "LIMPAR","LIMPAR",C_BLOCK,C_TEXT);
   UiButton("BTN_PAUSE",CX+2*(bw+6),y,bw,32,g_entries_paused ? "RETOMAR" : "PAUSAR ENTRADAS","PAUSAR",g_entries_paused ? C_RED : C_BLOCK,C_TEXT);
   bool arming=(TimeLocal()<=g_power_armed_until);
   string power_text=(g_runtime_trading_enabled ? "DESATIVAR EA" : (arming ? StringFormat("CONFIRMAR %s",AccountModeText()) : "ATIVAR EA"));
   string power_short=(g_runtime_trading_enabled ? "DESATIVAR" : (arming ? "CONFIRMAR" : "ATIVAR"));
   color power_bg=(g_runtime_trading_enabled ? C_GREEN : (arming ? C_RED : C'31,86,144'));
   UiButton("BTN_POWER",CX+3*(bw+6),y,bw,32,power_text,power_short,power_bg,g_runtime_trading_enabled ? C_BG : C_TEXT);

   UiSweep();
   if(g_ui_dirty) ChartRedraw();
  }


string SnapshotName()
  {
   MqlDateTime p; TimeToStruct(TimeLocal(),p);
   string prefix="NEXUS_GUARD_PRO";
   return CSVRelativeFolder()+"\\"+StringFormat("%s_Snapshot_%s_%s_%04d%02d%02d_%02d%02d%02d.csv",
                       CSVSafeToken(prefix),CSVSafeToken(_Symbol),CSVSafeToken(TimeframeShort(g_profile.tf)),
                       p.year,p.mon,p.day,p.hour,p.min,p.sec);
  }

void ExportSnapshot()
  {
   g_last_action="EXPORT_CSV"; g_last_action_result="REQUESTED";
   LogEvent("MANUAL_EXPORT_REQUESTED",StringFormat("folder=%s",CSVFolderText()));
   string name=SnapshotName();
   int flags=FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ;
   if(InpCSVInCommonFolder) flags|=FILE_COMMON;
   int h=FileOpen(name,flags,';');
   if(h==INVALID_HANDLE) { g_last_action_result="FAILED"; LogEvent("EXPORT_FAILED",StringFormat("error=%d",GetLastError())); return; }
   FileWrite(h,"field","value");
   FileWrite(h,"ea_name",NMX_EA_NAME); FileWrite(h,"release",NMX_RELEASE); FileWrite(h,"version",NMX_VERSION);
   FileWrite(h,"run_id",g_run_id); FileWrite(h,"magic_family",g_magic); FileWrite(h,"account_mode",AccountModeText());
   FileWrite(h,"symbol",_Symbol); FileWrite(h,"asset_class",g_symbol.asset_class); FileWrite(h,"timeframe",EnumToString(g_profile.tf));
   FileWrite(h,"profile",g_profile.name); FileWrite(h,"state",StateText(g_state)); FileWrite(h,"reason",g_reason);
   FileWrite(h,"blocking_gate",g_blocking_gate); FileWrite(h,"last_event",g_last_event);
   FileWrite(h,"last_event_reason",g_last_event_reason); FileWrite(h,"last_action",g_last_action);
   FileWrite(h,"last_action_result",g_last_action_result);
   FileWrite(h,"regime",RegimeText(g_regime)); FileWrite(h,"atr",g_atr); FileWrite(h,"spread_points",g_last_spread_points);
   FileWrite(h,"spread_atr",g_last_spread_atr); FileWrite(h,"news_status",g_news_status); FileWrite(h,"next_news",g_next_news_name);
   FileWrite(h,"motor_status",MotorStatusText()); FileWrite(h,"mtf_m1",BiasText(0)); FileWrite(h,"mtf_m1_er",g_mtf[0].efficiency);
   FileWrite(h,"runtime_trading_enabled",BoolText(g_runtime_trading_enabled));
   FileWrite(h,"timeframe_switch_state_restored",BoolText(g_switch_state_restored));
   FileWrite(h,"risk_mode",EnumToString(InpRiskMode)); FileWrite(h,"fixed_lot",InpFixedLot);
   FileWrite(h,"risk_cap_mode",RiskCapModeText()); FileWrite(h,"hard_max_risk_percent",InpHardMaxRiskPercent);
   FileWrite(h,"stop_mode",EnumToString(InpStopMode)); FileWrite(h,"stop_money",InpStopMoney);
   FileWrite(h,"target_mode",EnumToString(InpTargetMode)); FileWrite(h,"target_money",InpTargetMoney);
   FileWrite(h,"mtf_m5",BiasText(1)); FileWrite(h,"mtf_m5_er",g_mtf[1].efficiency);
   FileWrite(h,"mtf_m30",BiasText(2)); FileWrite(h,"mtf_m30_er",g_mtf[2].efficiency);
   FileWrite(h,"mtf_alignment",MTFAlignmentText()); FileWrite(h,"mtf_filter_required",BoolText(InpRequireFullMTFAlignment));
   FileWrite(h,"digits",g_symbol.digits); FileWrite(h,"point",g_symbol.point); FileWrite(h,"tick_size",g_symbol.tick_size);
   FileWrite(h,"tick_value",g_symbol.tick_value); FileWrite(h,"contract_size",g_symbol.contract_size);
   FileWrite(h,"volume_min",g_symbol.volume_min); FileWrite(h,"volume_step",g_symbol.volume_step);
   FileWrite(h,"daily_net",g_stats.net); FileWrite(h,"daily_realized_profit",g_stats.realized_profit);
   FileWrite(h,"daily_realized_loss",g_stats.realized_loss); FileWrite(h,"daily_costs",g_stats.costs);
   FileWrite(h,"account_daily_loss_percent",g_stats.daily_loss_percent);
   FileWrite(h,"account_peak_drawdown_percent",g_stats.drawdown_percent);
   FileWrite(h,"trades",g_stats.trades);
   FileWrite(h,"wins",g_stats.wins); FileWrite(h,"losses",g_stats.losses);
   FileWrite(h,"candidate_score_closed",g_candidate.valid ? g_candidate.score : 0.0);
   FileWrite(h,"candidate_score_live",g_live_score_valid ? g_live_score : 0.0);
   FileWrite(h,"live_structure_ready",BoolText(g_live_structure_ready));
   FileWrite(h,"live_score_projected_pass",BoolText(g_live_prearmed));
   FileWrite(h,"seconds_to_bar_close",SecondsToCurrentBarClose());
   PositionInfoNMX position;
   if(CurrentPosition(position))
     {
       FileWrite(h,"position_ticket",position.ticket); FileWrite(h,"position_magic",position.magic);
       FileWrite(h,"position_origin_tf",TimeframeShort(position.origin_tf));
       double net_position=PositionNetEstimate(position);
       FileWrite(h,"position_duration_seconds",MathMax(0,(long)(TimeTradeServer()-position.open_time)));
       FileWrite(h,"position_mfe_estimate",ReadPositionState(position,"PEAK",net_position));
       FileWrite(h,"position_mae_estimate",ReadPositionState(position,"TROUGH",net_position));
       FileWrite(h,"position_development",PositionDevelopmentState(position,net_position,
                 ReadPositionState(position,"PEAK",net_position)));
     }
   FileFlush(h); ulong size=FileSize(h); FileClose(h);
   if(size<=0) { g_last_action_result="EMPTY"; LogEvent("EXPORT_FILE_EMPTY",StringFormat("folder=%s|file=%s",CSVFolderText(),name)); }
   else
     {
      g_last_export_file=name; g_last_action_result="SUCCESS";
      LogEvent("EXPORT_SUCCESS",StringFormat("folder=%s|file=%s|bytes=%I64u",CSVFolderText(),name,size));
     }
  }

void ClearVisualCache()
  {
   ResetLiveScoreTelemetry();
   g_last_action="CLEAR_PANEL_CACHE"; g_last_action_result="SUCCESS"; g_clear_menu=false;
   LogEvent("PANEL_CACHE_CLEARED",""); BuildPanel();
  }

void HandlePanelClick(const string object_name)
  {
   if(ObjectFind(0,object_name)>=0 && StringFind(object_name,O("BTN_"))==0) ObjectSetInteger(0,object_name,OBJPROP_STATE,false);
   if(object_name==O("BTN_MIN")) { g_panel_mode=PANEL_MINIMIZED; LogEvent("PANEL_MODE_CHANGED","mode=MINIMIZED"); BuildPanel(); return; }
   if(object_name==O("BTN_MAX")) { g_panel_mode=PANEL_EXPANDED; LogEvent("PANEL_MODE_CHANGED","mode=EXPANDED"); BuildPanel(); return; }
   if(object_name==O("BTN_EXPORT")) { ExportSnapshot(); BuildPanel(); return; }
   if(object_name==O("BTN_PAUSE"))
     {
      g_entries_paused=!g_entries_paused; g_reason=(g_entries_paused ? "MANUAL_ENTRY_PAUSE" : "ENTRIES_RESUMED");
      LogEvent(g_entries_paused ? "ENTRIES_PAUSED" : "ENTRIES_RESUMED",""); BuildPanel(); return;
     }
   if(object_name==O("BTN_POWER"))
     {
      if(g_runtime_trading_enabled)
        {
         g_runtime_trading_enabled=false; g_power_armed_until=0;
         g_reason="RUNTIME_TRADING_DISABLED_BY_PANEL";
         LogEvent("RUNTIME_TRADING_DISABLED",StringFormat("account_mode=%s",AccountModeText()));
         BuildPanel(); return;
        }
      if(TimeLocal()>g_power_armed_until)
        {
         g_power_armed_until=TimeLocal()+5;
         g_reason=StringFormat("CONFIRM_RUNTIME_ACTIVATION_%s",AccountModeText());
         BuildPanel(); return;
        }
      g_runtime_trading_enabled=true; g_power_armed_until=0; g_entries_paused=false;
      ClearCandidate("RUNTIME_ACTIVATION_REQUIRES_FRESH_SIGNAL");
      g_state=ST_WAIT_EVENT; g_reason="RUNTIME_TRADING_ENABLED_BY_PANEL";
      LogEvent("RUNTIME_TRADING_ENABLED",StringFormat("account_mode=%s|fresh_signal_required=true",AccountModeText()));
      BuildPanel(); return;
     }
   if(object_name==O("BTN_CLEAR")) { g_clear_menu=!g_clear_menu; BuildPanel(); return; }
   if(object_name==O("BTN_CANCEL")) { g_clear_menu=false; g_clear_armed_until=0; BuildPanel(); return; }
   if(object_name==O("BTN_CACHE")) { ClearVisualCache(); return; }
   if(object_name==O("BTN_EAOBJ"))
     {
      DeletePanel(); g_reason="EA_OBJECTS_CLEARED"; LogEvent("EA_OBJECTS_CLEARED","");
      BuildPanel(); DrawLevelLines(); ChartRedraw(); return;
     }
   if(object_name==O("BTN_CHART"))
     {
      if(TimeLocal()>g_clear_armed_until)
        { g_clear_armed_until=TimeLocal()+5; g_reason="CONFIRM_FULL_CHART_CLEAR"; BuildPanel(); return; }
      ObjectsDeleteAll(0); g_clear_armed_until=0; g_clear_menu=false;
      g_rendered_panel_mode=-1;
      g_reason="FULL_CHART_CLEAR_CONFIRMED"; LogEvent("FULL_CHART_CLEAR_CONFIRMED","");
      BuildPanel(); DrawLevelLines(); ChartRedraw(); return;
     }
  }

void ExecuteOrDisplayCandidate()
  {
   if(!g_candidate.valid || g_state!=ST_SIGNAL_READY) return;
   TEL6EnsureSignalIdentity();

   if(g_runtime_trading_enabled)
     {
      // Snapshot no ponto exato em que o sinal tecnico ficou pronto. O intent
      // operacional real sera calculado e anexado logo depois em ExecuteCandidate.
      TradeIntent tel6_empty; ZeroMemory(tel6_empty);
      TEL6WriteSignalDecision("SIGNAL_READY",g_reason,tel6_empty,false,"N/A");
      TEL6WriteOpportunitySnapshot("READY_FOR_EXECUTION",tel6_empty,false,g_reason);
      ExecuteCandidate();
      return;
     }

   // ANALYSIS_ONLY permanece estritamente observacional: TEL6 nao chama
   // CalculateIntent fora do caminho original do EA. Assim a camada de
   // telemetria nao executa solvers nem produz side-effects que o baseline
   // baseline anterior nao produziria neste estado. O outcome ainda acompanha preco/MFE/MAE
   // a partir da oportunidade, mas campos dependentes de intent ficam N/A/zero.
   TradeIntent tel6_intent; ZeroMemory(tel6_intent);
   bool tel6_have_intent=false;
   TEL6WriteSignalDecision("SIGNAL_READY",g_reason,tel6_intent,false,"N/A");
   TEL6WriteOpportunitySnapshot("ANALYSIS_ONLY",tel6_intent,false,g_reason);

   int age=iBarShift(_Symbol,g_profile.tf,g_candidate.state_time,false);
   if(age>1)
     {
      ClearCandidate("ANALYSIS_SIGNAL_EXPIRED");
      g_state=ST_WAIT_EVENT;
      g_reason="ANALYSIS_SIGNAL_EXPIRED";
      return;
     }
   g_reason="SIGNAL_READY_ANALYSIS_ONLY";
   TEL6WriteSignalMarker("TECHNICAL_SIGNAL_ANALYSIS_ONLY",tel6_intent,tel6_have_intent,"NOT_EXECUTED","N/A");
  }

void ProcessNewBar()
  {
   if(!LoadRatesAndATR()) { BlockFreshCandidate(ST_BLOCKED,"DATA",g_reason); BuildPanel(); return; }
   CalculateRegime(); CalculateVWAP(1,g_vwap); BuildLevelMap(); if(DrawLevelLines()) ChartRedraw(); UpdateMTFContext();
   CalculateHistoryStats();
   int positions=ManagePositions(true);
   if(positions>0) { g_blocking_gate=""; g_state=ST_IN_POSITION; g_reason="POSITION_MANAGEMENT"; BuildPanel(); return; }
   RefreshConfigurationHealth(true);
   if(g_config_blocked) { BlockFreshCandidate(ST_BLOCKED,"CONFIGURATION",g_config_reason); BuildPanel(); return; }
   if(g_entries_paused) { BlockFreshCandidate(ST_PAUSED,"MANUAL_PAUSE","MANUAL_ENTRY_PAUSE"); BuildPanel(); return; }
   if(g_regime==REGIME_INSUFFICIENT_DATA || g_regime==REGIME_EVENT_SHOCK)
     { BlockFreshCandidate(ST_BLOCKED,"REGIME",RegimeText(g_regime)); BuildPanel(); return; }
   if(g_stats.blocked) { BlockFreshCandidate(ST_BLOCKED,"DAILY_RISK",g_stats.reason); BuildPanel(); return; }
   string news_reason="";
   if(!CheckNews(news_reason)) { BlockFreshCandidate(ST_BLOCKED,"NEWS",news_reason); BuildPanel(); return; }
   g_blocking_gate=""; g_last_block_key="";

   // A candidate may only exist inside its own pipeline states.  R6.3 could
   // leave a candidate latched while ST_BLOCKED; after the blocker ended no
   // stage processed it and no fresh event could be detected.
   if(g_candidate.valid && !CandidatePipelineState())
     {
      ClearCandidate("PIPELINE_STATE_MISMATCH_FRESH_SIGNAL_REQUIRED");
      g_state=ST_WAIT_EVENT; g_reason="WAITING_FRESH_MARKET_EVENT";
     }

   if(g_state==ST_COOLDOWN)
     {
      int age=(g_cooldown_anchor_bar>0 ? iBarShift(_Symbol,g_profile.tf,g_cooldown_anchor_bar,false) : 1000000);
      if(age<g_cooldown_bars) { g_reason="COOLDOWN"; BuildPanel(); return; }
      g_state=ST_WAIT_EVENT; g_reason="COOLDOWN_COMPLETE";
     }
   if(g_candidate.valid)
     {
      if(g_state==ST_WAIT_STRUCTURE) ProcessStructure();
      else if(g_state==ST_WAIT_RETEST) ProcessRetest();
      if(g_state==ST_SIGNAL_READY) ExecuteOrDisplayCandidate();
     }
   else
     {
      g_state=ST_WAIT_EVENT; g_reason="WAITING_MARKET_EVENT";
      DetectNewCandidate();
      if(g_state==ST_SIGNAL_READY) ExecuteOrDisplayCandidate();
     }
   BuildPanel();
  }

int OnInit()
  {
   string reason="";
   if(!ConfigureProfile(reason)) { PrintFormat("NGP|INIT_FAILED|%s",reason); return INIT_PARAMETERS_INCORRECT; }
   g_audit_sequence=0; g_telemetry_sequence=0; g_decision_sequence=0; g_intent_sequence=0;
   ArrayResize(g_spread_samples_atr,MathMax(20,InpSpreadLearningWindow));
   ArrayInitialize(g_spread_samples_atr,0.0);
   g_spread_sample_count=0; g_spread_sample_cursor=0; g_last_spread_sample_ms=0;
   g_adaptive_spread_baseline=0.0; g_effective_spread_atr_limit=0.0;
   ZeroMemory(g_candidate);
   ResetCandidateScores();
   g_blocking_gate=""; g_last_event=""; g_last_event_reason="";
   g_last_action=""; g_last_action_result="";
   g_run_id=StringFormat("RUN_%I64d_%08X",(long)TimeLocal(),FNV1a32(StringFormat("%I64d|%I64d|%s|%I64d",AccountInfoInteger(ACCOUNT_LOGIN),ChartID(),_Symbol,(long)TimeLocal())));
   g_last_audit_snapshot=0;
   g_runtime_trading_enabled=InpTradingEnabled;
   g_entries_paused=false; g_power_armed_until=0;
   g_switch_state_restored=RestoreTimeframeSwitchState();
   g_prefix=StringFormat("NGP_%I64d_%I64d_",g_magic,ChartID());
   if(!LoadSymbolModel(reason)) { PrintFormat("NGP|INIT_FAILED|%s",reason); return INIT_FAILED; }
   // Business-configuration conflicts remain visible in the panel instead of
   // aborting OnInit and making the EA appear dead.
   RefreshConfigurationHealth(false);
   g_atr_handle=iATR(_Symbol,g_profile.tf,InpATRPeriod);
   if(g_atr_handle==INVALID_HANDLE) { PrintFormat("NGP|INIT_FAILED|ATR_HANDLE_%d",GetLastError()); return INIT_FAILED; }
   g_panel_mode=(GlobalVariableCheck(StateKey("PANEL_MODE")) ?
                 (ENUM_NMX_PANEL_MODE)(int)GlobalVariableGet(StateKey("PANEL_MODE")) : PANEL_EXPANDED);
   string panel_scale_key=StateKey("PANEL_SCALE");
   int previous_panel_scale=-1;
   bool panel_scale_changed=false;
   if(GlobalVariableCheck(panel_scale_key))
     {
      previous_panel_scale=(int)GlobalVariableGet(panel_scale_key);
      panel_scale_changed=(previous_panel_scale!=InpPanelScalePercent);
     }
   GlobalVariableSet(panel_scale_key,(double)InpPanelScalePercent);
   int timer_seconds=MathMax(1,InpTimerSeconds);
   if((bool)MQLInfoInteger(MQL_TESTER)) timer_seconds=MathMax(60,timer_seconds);
   EventSetTimer(timer_seconds);
   TEL6Initialize();
   g_state=ST_INITIALIZING; g_reason="INITIALIZING";
   if(LoadRatesAndATR())
     {
      g_last_bar=iTime(_Symbol,g_profile.tf,0); CalculateRegime(); CalculateVWAP(1,g_vwap); BuildLevelMap(); UpdateMTFContext();
      CalculateHistoryStats(); CheckNews(reason); StoreInitialRiskForNewPositions();
      g_state=(HasOwnPositionForSymbol(_Symbol) ? ST_IN_POSITION :
               (g_config_blocked ? ST_BLOCKED : (g_entries_paused ? ST_PAUSED : ST_WAIT_EVENT)));
      g_reason=(g_config_blocked ? g_config_reason :
                (g_switch_state_restored ? "TIMEFRAME_SWITCH_STATE_RESTORED" : "READY"));
     }
   else { g_state=ST_BLOCKED; }
   g_config_hash=TEL6Hash8(TEL6StrategyConfigCanonical());
   TEL6WriteMarketState("INIT",true); TEL6SyncObjectStates();
   { TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteRiskState("INIT",tel6_intent,false,true); }
   if(panel_scale_changed)
      LogEvent("PANEL_SCALE_CHANGED",StringFormat("from=%d|to=%d",previous_panel_scale,InpPanelScalePercent));
   LogEvent("INIT",StringFormat("product=NEXUS GUARD PRO|version=%s|build=%s|release=%s|config_hash=%s|risk_safety=%s|profile=%s|tf=%s|setup=%s|entry=%s|asset_class=%s|digits=%d|point=%.10f|tick_size=%.10f|tick_value=%.10f|contract_size=%.4f|volume_min=%.4f|volume_step=%.4f|account_mode=%s|input_trading_enabled=%s|runtime_trading_enabled=%s|paused=%s|switch_state_restored=%s|stable_magic=%I64d|legacy_magic_compat=true|mtf_filter=%s|risk_mode=%s|fixed_lot=%.4f|risk_percent=%.4f|hard_max_risk_percent=%.4f|stop_mode=%s|stop_money=%.2f|protection_mode=%s|hard_risk_enforced_at_entry=%s|delay_m1=%d|delay_m5=%d|delay_m30=%d|target_mode=%s|target_money=%.2f|trailing_mode=%s|trailing_activation_money=%.2f|trail_ratio=%.2f|trail_exponent=%.2f|trailing_step_money=%.2f|news_fail_mode=%s|tester_calendar_bypass_enabled=%s|csv_folder=%s|csv_prefix=%s|config_blocked=%s|config_detail=%s",
              NMX_VERSION,NMX_BUILD_ID,NMX_RELEASE,g_config_hash,RiskSafetyStateText(),g_profile.name,EnumToString(g_profile.tf),EnumToString(g_profile.setup_mode),EnumToString(g_profile.entry_mode),
              g_symbol.asset_class,g_symbol.digits,g_symbol.point,g_symbol.tick_size,g_symbol.tick_value,
              g_symbol.contract_size,g_symbol.volume_min,g_symbol.volume_step,AccountModeText(),BoolText(InpTradingEnabled),
              BoolText(g_runtime_trading_enabled),BoolText(g_entries_paused),BoolText(g_switch_state_restored),g_magic,
              BoolText(InpRequireFullMTFAlignment),EnumToString(InpRiskMode),InpFixedLot,InpRiskPercent,
              InpHardMaxRiskPercent,EnumToString(InpStopMode),InpStopMoney,ProtectionModeText(),
              BoolText(HardRiskEnforcedAtEntry()),InpDelayedStopM1Minutes,InpDelayedStopM5Minutes,InpDelayedStopM30Minutes,
              EnumToString(InpTargetMode),InpTargetMoney,
               EnumToString(InpTrailingMode),InpTrailingActivationMoney,InpTrailRatio,
               InpTrailExponent,InpTrailingStepMoney,
               EnumToString(InpNewsFailMode),BoolText(InpTesterAllowWithoutCalendar),
               CSVFolderText(),InpCSVPrefix,
               BoolText(g_config_blocked),g_config_detail));
   {
      double ref_stop=((InpStopMode==STOP_MONEY || InpStopMode==STOP_STRUCTURE_CAPPED_BY_MONEY) ? InpStopMoney : 0.0);
      double ref_target=((InpTargetMode==TARGET_MONEY || InpTargetMode==TARGET_MONEY_THEN_TRAILING) ? InpTargetMoney : 0.0);
      double breakeven_wr=((Positive(ref_stop) && Positive(ref_target)) ? ref_stop/(ref_stop+ref_target)*100.0 : 0.0);
      LogEvent("RISK_PROFILE",StringFormat("protection=%s|stop_money_ref=%.2f|target_money_ref=%.2f|breakeven_win_rate=%.1f%%|floating_breaker=%s|breaker_position=%.2f|breaker_total=%.2f|breaker_action=%s|loss_limit_without_broker_stop=%s",
               ProtectionModeText(),ref_stop,ref_target,breakeven_wr,BoolText(InpUseFloatingBreaker),InpFloatingLossPositionMoney,InpFloatingLossTotalMoney,
               EnumToString(InpFloatingBreakerAction),BoolText(InpProtectionMode!=PROTECTION_IMMEDIATE && !InpUseFloatingBreaker)));
   }
   LogEvent("EQUITY_GUARD_AUTHORITY",StringFormat("scope=%s|max_daily_loss_percent=%.2f|max_drawdown_percent=%.2f|daily_loss_percent=%.4f|drawdown_percent=%.4f",
            EquityGuardScopeText(),InpMaxDailyLossPercent,InpMaxDrawdownPercent,g_stats.daily_loss_percent,g_stats.drawdown_percent));
   if(g_config_blocked) LogEvent("CONFIGURATION_BLOCKED",StringFormat("reason=%s|detail=%s",g_config_reason,g_config_detail));
   BuildPanel(); DrawLevelLines(); ChartRedraw(); return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   if(reason==REASON_CHARTCHANGE) SaveTimeframeSwitchState();
   GlobalVariableSet(StateKey("PANEL_MODE"),(double)g_panel_mode);
   TEL6WriteCandleSnapshot();
   for(int i=0;i<ArraySize(g_tel6_outcomes);i++) if(g_tel6_outcomes[i].active) TEL6FinalizeOutcome(i,"DEINIT_CHECKPOINT",false);
   LogEvent("DEINIT",StringFormat("reason=%d",reason));
   EventKillTimer(); if(g_atr_handle!=INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   DeletePanel();
  }

void OnTick()
  {
   bool new_bar=IsNewBar();
   int positions=ManagePositions(false);
   if(positions>0) StoreInitialRiskForNewPositions();
   if(new_bar)
     {
      ProcessNewBar();
      TEL6WriteCandleSnapshot();
      TEL6WriteMarketState("NEW_BAR",true);
      TEL6SyncObjectStates();
      TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteRiskState("NEW_BAR",tel6_intent,false,false);
     }
   UpdateLiveCandidateScore();
   RenderLiveScoreOnly();
   TEL6UpdateOutcomes();
   TEL6WriteMomentState();
   TEL6WriteIntrabar();
  }

void OnTimer()
  {
   string news_reason="";
   if(TimeTradeServer()-g_last_news_check>=60)
     { CheckNews(news_reason); g_last_news_check=TimeTradeServer(); }
   if(TimeTradeServer()-g_last_mtf_update>=MathMax(5,InpMTFRefreshSeconds)) UpdateMTFContext();
   CalculateHistoryStats(); SpreadAllowed();
   RefreshConfigurationHealth(true);
   if(g_config_blocked && !HasOwnPositionForSymbol(_Symbol))
      BlockFreshCandidate(ST_BLOCKED,"CONFIGURATION",g_config_reason);
   UpdateLiveCandidateScore();
   if(g_clear_armed_until>0 && TimeLocal()>g_clear_armed_until) g_clear_armed_until=0;
   if(g_power_armed_until>0 && TimeLocal()>g_power_armed_until)
     { g_power_armed_until=0; if(StringFind(g_reason,"CONFIRM_RUNTIME_ACTIVATION_")==0) g_reason="RUNTIME_ACTIVATION_CANCELLED"; }
   TEL6WriteMarketState("TIMER",false);
   { TradeIntent tel6_intent; ZeroMemory(tel6_intent); TEL6WriteRiskState("TIMER",tel6_intent,false,false); }
   TEL6WriteMomentState();
   BuildPanel();
   if(DrawLevelLines()) ChartRedraw();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK) { HandlePanelClick(sparam); return; }
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      long w=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS); long h=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      if(w!=g_last_chart_width || h!=g_last_chart_height)
        {
         g_last_chart_width=w; g_last_chart_height=h;
         LogEvent("PANEL_OBJECT_REBUILT",StringFormat("reason=CHART_CHANGE|width=%I64d|height=%I64d|scale=%d",w,h,InpPanelScalePercent));
         BuildPanel();
         if(DrawLevelLines()) ChartRedraw();
        }
     }
  }

bool PositionIdentifierIsOpen(const ulong identifier)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i); if(ticket==0) continue;
      if((ulong)PositionGetInteger(POSITION_IDENTIFIER)==identifier) return true;
     }
   return false;
  }

bool ClaimDealTelemetry(const ulong deal_ticket)
  {
   // Every EA instance receives the same terminal trade transaction.  A
   // terminal-global atomic claim guarantees one Journal/Audit/Trades record
   // per broker deal even when Nexus is attached to M1, M5 and M30 charts.
   string key=StringFormat("NGPDL.%I64d.%I64d.%I64u",AccountInfoInteger(ACCOUNT_LOGIN),InpMagicNumber,deal_ticket);
   if(!GlobalVariableCheck(key)) GlobalVariableTemp(key);
   double owner=(double)ChartID();
   if(owner==0.0) owner=1.0;
   return GlobalVariableSetOnCondition(key,owner,0.0);
  }

bool ClosedPositionNetResult(const ulong identifier,double &net,double &gross,double &costs)
  {
   net=0.0; gross=0.0; costs=0.0;
   if(!HistorySelectByPosition(identifier)) return false;
   int total=HistoryDealsTotal();
   if(total<=0) return false;
   for(int i=0;i<total;i++)
     {
      ulong deal=HistoryDealGetTicket(i); if(deal==0) continue;
      double profit=HistoryDealGetDouble(deal,DEAL_PROFIT);
      double swap=HistoryDealGetDouble(deal,DEAL_SWAP);
      double commission=HistoryDealGetDouble(deal,DEAL_COMMISSION);
      double fee=HistoryDealGetDouble(deal,DEAL_FEE);
      gross+=profit;
      costs+=swap+commission+fee;
      net+=profit+swap+commission+fee;
     }
   return true;
  }

string ResultClass(const double net)
  {
   if(net>0.005) return "PROFIT";
   if(net<-0.005) return "LOSS";
   return "BREAKEVEN";
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD || trans.deal==0) return;
   if(!HistoryDealSelect(trans.deal)) return;
   long magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
   string symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
   ulong tx_position_id=(ulong)HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);
   g_costs_cache_pid=0;
   if(symbol!=_Symbol) return;
   if(!IsNexusMagic(magic))
     {
      // Fechamento manual/stop-out: o deal de saida pode vir sem magic.
      if(!PositionOwnedByNexus(tx_position_id)) return;
      if(!HistoryDealSelect(trans.deal)) return;
     }
   if(!ClaimDealTelemetry(trans.deal)) return;

   ulong position_id=(ulong)HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);
   ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
   ENUM_DEAL_TYPE deal_type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
   ENUM_DEAL_REASON deal_reason=(ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal,DEAL_REASON);
   double volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
   double price=HistoryDealGetDouble(trans.deal,DEAL_PRICE);
   double profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
   double commission=HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
   double swap=HistoryDealGetDouble(trans.deal,DEAL_SWAP);
   double fee=HistoryDealGetDouble(trans.deal,DEAL_FEE);
   TEL6BindTradeLink(position_id);
   PositionInfoNMX tel6_position; ZeroMemory(tel6_position);
   bool tel6_have_position=(trans.position>0 && LoadPosition(trans.position,tel6_position));

   LogEvent("DEAL",StringFormat("deal=%I64u|position=%I64u|entry=%s|type=%s|reason=%s|volume=%.4f|price=%.10f|profit=%.2f|commission=%.2f|swap=%.2f|fee=%.2f",
            trans.deal,position_id,EnumToString(entry),EnumToString(deal_type),EnumToString(deal_reason),
            volume,price,profit,commission,swap,fee));
   TEL6WriteTradeLifecycle("DEAL",position_id,trans.position,trans.order,trans.deal,entry,deal_type,deal_reason,
                           volume,price,profit,commission,swap,fee,0.0,"",tel6_position,tel6_have_position);

   bool exit_deal=(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY || entry==DEAL_ENTRY_INOUT);
   if(exit_deal)
     {
      if(PositionIdentifierIsOpen(position_id))
        {
         LogEvent("POSITION_PARTIAL_CLOSE",StringFormat("position=%I64u|deal=%I64u|reason=%s|deal_net=%.2f",
                  position_id,trans.deal,EnumToString(deal_reason),profit+commission+swap+fee));
         TEL6WriteTradeLifecycle("POSITION_PARTIAL_CLOSE",position_id,trans.position,trans.order,trans.deal,entry,deal_type,deal_reason,
                                 volume,price,profit,commission,swap,fee,0.0,"PARTIAL",tel6_position,tel6_have_position);
        }
      else
        {
          double position_net=0.0,position_gross=0.0,position_costs=0.0;
          if(ClosedPositionNetResult(position_id,position_net,position_gross,position_costs))
            {
             string final_result=ResultClass(position_net);
             LogEvent("POSITION_CLOSED",StringFormat("position=%I64u|deal=%I64u|exit_reason=%s|result=%s|net_profit=%.2f|gross_profit=%.2f|costs=%.2f|classification_uses_net_result=true",
                      position_id,trans.deal,EnumToString(deal_reason),final_result,
                      position_net,position_gross,position_costs));
             if(InpCooldownBars>0)
               { StartCooldown(InpCooldownBars); g_state=ST_COOLDOWN; g_reason="COOLDOWN_AFTER_TRADE"; }
             if(deal_reason==DEAL_REASON_CLIENT || deal_reason==DEAL_REASON_MOBILE || deal_reason==DEAL_REASON_WEB || !IsNexusMagic(magic))
                LogEvent("POSITION_CLOSED_EXTERNALLY",StringFormat("position=%I64u|reason=%s|net_profit=%.2f|counted_in_daily_stats=true",position_id,EnumToString(deal_reason),position_net));
             TEL6WriteTradeLifecycle("POSITION_CLOSED",position_id,trans.position,trans.order,trans.deal,entry,deal_type,deal_reason,
                                     volume,price,profit,commission,swap,fee,position_net,final_result,tel6_position,false);
            }
          else
            {
             LogEvent("POSITION_CLOSE_RESULT_UNAVAILABLE",StringFormat("position=%I64u|deal=%I64u|exit_reason=%s",
                     position_id,trans.deal,EnumToString(deal_reason)));
             TEL6WriteTradeLifecycle("POSITION_CLOSE_RESULT_UNAVAILABLE",position_id,trans.position,trans.order,trans.deal,entry,deal_type,deal_reason,
                                     volume,price,profit,commission,swap,fee,0.0,"UNAVAILABLE",tel6_position,false);
            }
        }
     }
   StoreInitialRiskForNewPositions(); CalculateHistoryStats();
   TradeIntent tel6_empty_intent; ZeroMemory(tel6_empty_intent); TEL6WriteRiskState("TRADE_TRANSACTION",tel6_empty_intent,false,true);
   BuildPanel();
  }
