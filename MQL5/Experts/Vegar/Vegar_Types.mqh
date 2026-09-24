#ifndef __VEGAR_TYPES_MQH__
#define __VEGAR_TYPES_MQH__

#define VEGAR_PRODUCT_NAME          "VEGAR"
#define VEGAR_EA_VERSION            "1.01.0"
#define VEGAR_MQL_VERSION           "1.01"
#define VEGAR_SCHEMA_VERSION        2100
#define VEGAR_BUILD_ID              "VEGAR-1.01.0-RC9"
#define VEGAR_DEFAULT_MAGIC         26091701
#define VEGAR_TELEMETRY_SCHEMA      "2100"
#define VEGAR_COMMENT_PREFIX        "VEGAR"
#define VEGAR_MAX_ZONES             256
#define VEGAR_MAX_OWNED_POSITION_IDS 32
#define VEGAR_MAX_REPLAY_JOBS       64
#define VEGAR_MAX_SIGNAL_MARKERS     512
#define VEGAR_PERSISTENCE_SCHEMA     2100

// Runtime ownership registry. Position IDs are only admitted from explicit VEGAR
// evidence (VEGAR deal comment or identity-matched operational persistence).
long gVegarOwnedPositionIDs[];

// Runtime context identity is declared here because zones/channels are created before CSV module inclusion.
string gVegarRunID="";
string gVegarInstanceID="";

// Self-test execution authority. A critical failure never stops market observation,
// CSV or UI, but it blocks every new order until the EA is reinitialized with a
// passing critical test battery.
bool gVegarSelfTestsCompleted=false;
bool gVegarCriticalSelfTestFailed=false;
int  gVegarSelfTestsRun=0;
int  gVegarSelfTestsPassed=0;
int  gVegarSelfTestsFailed=0;
int  gVegarSelfTestsCriticalFailed=0;
int  gVegarPipelineTestsRun=0;
int  gVegarPipelineTestsPassed=0;
int  gVegarPipelineTestsFailed=0;
int  gVegarPipelineTestsCriticalFailed=0;

bool Vegar_OwnershipHasPositionID(const long position_id)
  {
   if(position_id<=0) return false;
   for(int i=0;i<ArraySize(gVegarOwnedPositionIDs);i++)
      if(gVegarOwnedPositionIDs[i]==position_id) return true;
   return false;
  }

void Vegar_OwnershipRegisterPositionID(const long position_id)
  {
   if(position_id<=0 || Vegar_OwnershipHasPositionID(position_id)) return;
   int n=ArraySize(gVegarOwnedPositionIDs);
   if(n>=VEGAR_MAX_OWNED_POSITION_IDS)
     {
      for(int i=1;i<n;i++) gVegarOwnedPositionIDs[i-1]=gVegarOwnedPositionIDs[i];
      gVegarOwnedPositionIDs[n-1]=position_id;
      return;
     }
   ArrayResize(gVegarOwnedPositionIDs,n+1);
   gVegarOwnedPositionIDs[n]=position_id;
  }

void Vegar_OwnershipResetRegistry()
  {
   ArrayResize(gVegarOwnedPositionIDs,0);
  }

// ------------------------- ENUMS -----------------------------------------
enum ENUM_VEGAR_ENVIRONMENT
  {
   VEGAR_ENV_TESTER=0,
   VEGAR_ENV_DEMO,
   VEGAR_ENV_REAL,
   VEGAR_ENV_UNSUPPORTED
  };

enum ENUM_VEGAR_ENGINE_STATE
  {
   VEGAR_ENGINE_ACTIVE=0,
   VEGAR_ENGINE_PAUSED,
   VEGAR_ENGINE_ERROR
  };

enum ENUM_VEGAR_EXECUTION_STATE
  {
   VEGAR_EXECUTION_ENABLED=0,
   VEGAR_EXECUTION_BLOCKED_CONFIGURATION,
   VEGAR_EXECUTION_BLOCKED_SESSION,
   VEGAR_EXECUTION_BLOCKED_NEWS,
   VEGAR_EXECUTION_BLOCKED_SPREAD,
   VEGAR_EXECUTION_BLOCKED_RISK,
   VEGAR_EXECUTION_BLOCKED_DAILY_LIMIT,
   VEGAR_EXECUTION_BLOCKED_POSITION,
   VEGAR_EXECUTION_BLOCKED_MARKET,
   VEGAR_EXECUTION_BLOCKED_EXECUTION,
   VEGAR_EXECUTION_BLOCKED_DATA,
   VEGAR_EXECUTION_BLOCKED_ACCOUNT,
   VEGAR_EXECUTION_BLOCKED_SELF_TEST,
   VEGAR_EXECUTION_BLOCKED_RECOVERY,
   VEGAR_EXECUTION_BLOCKED_OWNERSHIP,
   VEGAR_EXECUTION_ERROR
  };

enum ENUM_VEGAR_PROFIT_MODE
  {
   VEGAR_PROFIT_TAKE_PROFIT=0,
   VEGAR_PROFIT_RUNNER=1,
   VEGAR_PROFIT_TAKE_PROFIT_E_RUNNER=2
  };

enum ENUM_VEGAR_CONFIG_VALIDITY
  {
   VEGAR_CONFIG_VALID=0,
   VEGAR_CONFIG_INVALID=1
  };

enum ENUM_VEGAR_TEST_CRITICALITY
  {
   VEGAR_TEST_NON_CRITICAL=0,
   VEGAR_TEST_CRITICAL=1
  };

enum ENUM_VEGAR_BIAS
  {
   VEGAR_BIAS_NONE=0,
   VEGAR_BIAS_BUYER=1,
   VEGAR_BIAS_SELLER=-1
  };

enum ENUM_VEGAR_LIQUIDITY_SIDE
  {
   VEGAR_LIQ_NONE=0,
   VEGAR_LIQ_BUY_SIDE=1,
   VEGAR_LIQ_SELL_SIDE=-1
  };

enum ENUM_VEGAR_ZONE_TYPE
  {
   VEGAR_ZONE_UNKNOWN=0,
   VEGAR_ZONE_H4_SWING_HIGH,
   VEGAR_ZONE_H4_SWING_LOW,
   VEGAR_ZONE_M15_SWING_HIGH,
   VEGAR_ZONE_M15_SWING_LOW,
   VEGAR_ZONE_EXEC_SWING_HIGH,
   VEGAR_ZONE_EXEC_SWING_LOW,
   VEGAR_ZONE_EQUAL_HIGH,
   VEGAR_ZONE_EQUAL_LOW,
   VEGAR_ZONE_PDH,
   VEGAR_ZONE_PDL,
   VEGAR_ZONE_PWH,
   VEGAR_ZONE_PWL,
   VEGAR_ZONE_COMPOSITE
  };

enum ENUM_VEGAR_ZONE_STATE
  {
   VEGAR_ZONE_CREATED=0,
   VEGAR_ZONE_ACTIVE,
   VEGAR_ZONE_APPROACH,
   VEGAR_ZONE_TOUCHED,
   VEGAR_ZONE_SWEPT,
   VEGAR_ZONE_INVALIDATED,
   VEGAR_ZONE_EXPIRED
  };

enum ENUM_VEGAR_STRENGTH_CLASS
  {
   VEGAR_STRENGTH_MUITO_FRACA=1,
   VEGAR_STRENGTH_FRACA=2,
   VEGAR_STRENGTH_MEDIA=3,
   VEGAR_STRENGTH_FORTE=4,
   VEGAR_STRENGTH_EXTREMA=5
  };

enum ENUM_VEGAR_CHANNEL_DIRECTION
  {
   VEGAR_CHANNEL_NEUTRAL=0,
   VEGAR_CHANNEL_BUYER=1,
   VEGAR_CHANNEL_SELLER=-1
  };

enum ENUM_VEGAR_M15_CONTEXT
  {
   VEGAR_M15_UNKNOWN=0,
   VEGAR_M15_TREND_UP,
   VEGAR_M15_TREND_DOWN,
   VEGAR_M15_RANGE,
   VEGAR_M15_TRANSITION
  };

enum ENUM_VEGAR_FLOW_CLASS
  {
   VEGAR_FLOW_VENDEDOR_FORTE=-2,
   VEGAR_FLOW_VENDEDOR=-1,
   VEGAR_FLOW_NEUTRO=0,
   VEGAR_FLOW_COMPRADOR=1,
   VEGAR_FLOW_COMPRADOR_FORTE=2,
   VEGAR_FLOW_BUYER_ABSORBED=3,
   VEGAR_FLOW_SELLER_ABSORBED=4
  };

enum ENUM_VEGAR_SETUP_STATE
  {
   VEGAR_SETUP_IDLE=0,
   VEGAR_SETUP_LIQUIDITY_APPROACH,
   VEGAR_SETUP_SWEEP_CONFIRMED,
   VEGAR_SETUP_WAITING_MSS,
   VEGAR_SETUP_MSS_CONFIRMED,
   VEGAR_SETUP_WAITING_DISPLACEMENT,
   VEGAR_SETUP_DISPLACEMENT_CONFIRMED,
   VEGAR_SETUP_ENTRY_ZONE_CREATED,
   VEGAR_SETUP_WAITING_RETEST,
   VEGAR_SETUP_RETEST_CONFIRMED,
   VEGAR_SETUP_ENTRY_INTENT,
   VEGAR_SETUP_PREFLIGHT,
   VEGAR_SETUP_ORDER_REQUEST,
   VEGAR_SETUP_POSITION_OPEN,
   VEGAR_SETUP_POSITION_MANAGEMENT,
   VEGAR_SETUP_POSITION_CLOSED,
   VEGAR_SETUP_BLOCKED,
   VEGAR_SETUP_INVALIDATED_STATE,
   VEGAR_SETUP_EXPIRED,
   VEGAR_SETUP_ERROR
  };

enum ENUM_VEGAR_RETEST_TYPE
  {
   VEGAR_RETEST_NONE=0,
   VEGAR_RETEST_FVG=1,
   VEGAR_RETEST_ORDER_BLOCK=2
  };

enum ENUM_VEGAR_NEWS_STATE
  {
   VEGAR_NEWS_DISABLED=0,
   VEGAR_NEWS_CLEAR,
   VEGAR_NEWS_BLOCKED,
   VEGAR_NEWS_UNAVAILABLE
  };

enum ENUM_VEGAR_REASON_CODE
  {
   VEGAR_REASON_NONE=0,
   DATA_NOT_READY,
   DATA_NOT_SYNCHRONIZED,
   TIMEFRAME_NOT_ALLOWED,
   SESSION_BLOCKED,
   NEWS_HIGH_IMPACT,
   NEWS_DATA_UNAVAILABLE,
   DAILY_TARGET_REACHED,
   DAILY_LOSS_REACHED,
   MAX_TRADES_REACHED,
   LOSS_STREAK_LOCK,
   M15_RANGE_BLOCK,
   M15_DIRECTION_CONFLICT,
   NO_ACTIVE_ZONE,
   ZONE_TOO_WEAK,
   SWEEP_NOT_CONFIRMED,
   SWEEP_TOO_DEEP,
   MSS_NOT_CONFIRMED,
   DISPLACEMENT_NOT_CONFIRMED,
   NO_FVG_OR_OB,
   RETEST_EXPIRED,
   RETEST_NOT_CONFIRMED,
   M5_CONFIRM_CONFLICT,
   STOP_MONEY_EXCEEDED,
   TARGET_SPACE_INSUFFICIENT,
   SPREAD_TOO_HIGH,
   POSITION_EXISTS,
   NETTING_EXTERNAL_POSITION,
   LOT_INVALID,
   MARGIN_TOO_LOW,
   PRICE_INVALID,
   STOPS_INVALID,
   FREEZE_LEVEL_BLOCK,
   MARKET_CLOSED,
   TRADING_DISABLED,
   AUTOTRADING_DISABLED,
   ORDER_CHECK_REJECTED,
   ORDER_SEND_REJECTED,
   DUPLICATE_INTENT,
   STALE_INTENT,
   SETUP_ABORTED_BY_REINIT,
   CSV_WRITE_ERROR,
   CONFIG_STOP_MONEY_UNSET,
   CONFIG_OPERATION_TARGET_INVALID,
   CONFIG_TAKE_PROFIT_INVALID,
   CONFIG_DAILY_TARGET_INVALID,
   CONFIG_RUNNER_INVALID,
   CONFIG_PROFIT_EXIT_UNSET,
   CONFIG_PROFIT_MODE_CONFLICT,
   ECONOMIC_TARGET_UNAVAILABLE,
   DUPLICATE_INSTANCE,
   COMMISSION_MODEL_UNDEFINED,
   ZONE_BREAKOUT,
   SETUP_INVALIDATED_REASON,
   CONFIG_INVALID_GENERAL,
   ORDER_REQUEST_NOT_ALLOWED,
   POSITION_OWNERSHIP_AMBIGUOUS,
   REPLAY_WAITING_HORIZON,
   ACCOUNT_MODE_UNSUPPORTED,
   ENVIRONMENT_DETECTION_FAILED,
   EXECUTION_BLOCKED_CONFIGURATION,
   EXECUTION_BLOCKED_ACCOUNT,
   ENGINE_PAUSED,
   CONFIG_SESSION_INVALID,
   SELF_TEST_FAILED,
   CROSS_SYMBOL_ENTITY_REJECTED,
   REPLAY_SYMBOL_UNAVAILABLE,
   NO_VALID_OPPOSITE_ZONE,
   BLOCKED_RECOVERY,
   BLOCKED_OWNERSHIP_AMBIGUOUS,
   RECOVERY_PROTECTION_UNCERTAIN,
   OBSERVATION_ONLY,
   CSV_SCHEMA_HEADER_MISMATCH,
   INTERNAL_ERROR,
   DAILY_RISK_BUDGET_INSUFFICIENT
  };


enum ENUM_VEGAR_ZONE_ROLE
  {
   VEGAR_ZONE_ROLE_OPERATIONAL=0,
   VEGAR_ZONE_ROLE_OBSERVATION=1
  };

enum ENUM_VEGAR_GATE_STATE
  {
   VEGAR_GATE_NOT_EVALUATED=0,
   VEGAR_GATE_PASS,
   VEGAR_GATE_FAIL,
   VEGAR_GATE_NOT_APPLICABLE
  };

enum ENUM_VEGAR_MARKER_CLASS
  {
   VEGAR_MARKER_NONE=0,
   VEGAR_MARKER_VALID_BUY,
   VEGAR_MARKER_VALID_SELL,
   VEGAR_MARKER_BLOCKED_BUY,
   VEGAR_MARKER_BLOCKED_SELL,
   VEGAR_MARKER_OBSERVATION_BUY,
   VEGAR_MARKER_OBSERVATION_SELL
  };

enum ENUM_VEGAR_SETUP_FAMILY
  {
   VEGAR_SETUP_FAMILY_STRUCTURAL_REVERSAL=0,
   VEGAR_SETUP_FAMILY_MICRO_CONTINUATION_OBSERVATION,
   VEGAR_SETUP_FAMILY_MICRO_CONTINUATION
  };

enum ENUM_VEGAR_APPROACH_MODE
  {
   VEGAR_APPROACH_NONE=0,
   VEGAR_APPROACH_LIVE,
   VEGAR_APPROACH_CLOSED_BAR,
   VEGAR_APPROACH_BOTH
  };

enum ENUM_VEGAR_CANDIDATE_STATE
  {
   VEGAR_CANDIDATE_NONE=0,
   VEGAR_CANDIDATE_APPROACH,
   VEGAR_CANDIDATE_PROMOTED,
   VEGAR_CANDIDATE_EXPIRED
  };

enum ENUM_VEGAR_OWNERSHIP_STATE
  {
   VEGAR_OWNERSHIP_NOT_VEGAR=0,
   VEGAR_OWNERSHIP_CONFIRMED,
   VEGAR_OWNERSHIP_AMBIGUOUS
  };

enum ENUM_VEGAR_CHANNEL_GEOMETRY
  {
   VEGAR_CHANNEL_GEOMETRY_NEUTRAL=0,
   VEGAR_CHANNEL_GEOMETRY_TREND,
   VEGAR_CHANNEL_GEOMETRY_COMPRESSION,
   VEGAR_CHANNEL_GEOMETRY_EXPANSION,
   VEGAR_CHANNEL_GEOMETRY_MIXED
  };

// ------------------------- STRUCTS ---------------------------------------
struct SVegarSymbolMeta
  {
   string symbol;
   string base_currency;
   string profit_currency;
   string account_currency;
   int digits;
   double point;
   double tick_size;
   double tick_value;
   double contract_size;
   double volume_min;
   double volume_max;
   double volume_step;
   int stops_level_points;
   int freeze_level_points;
   long filling_flags;
   bool valid;
  };

struct SVegarZone
  {
   string id;
   string account;
   string server;
   string symbol;
   ENUM_TIMEFRAMES execution_tf;
   long magic;
   string instance_id;
   string run_id;
   ENUM_VEGAR_ZONE_ROLE role;
   ENUM_VEGAR_ZONE_TYPE type;
   ENUM_TIMEFRAMES source_tf;
   ENUM_VEGAR_LIQUIDITY_SIDE liquidity_side;
   ENUM_VEGAR_BIAS operational_bias;
   ENUM_VEGAR_ZONE_STATE state;
   datetime source_time;
   datetime confirmed_time;
   datetime last_changed;
   double low;
   double high;
   double mid;
   double width;
   double source_atr;
   int source_count;
   string source_ids;
   string source_types;
   string source_tfs;
   string source_times;
   string source_confirmed_times;
   string source_atrs;
   ENUM_VEGAR_ZONE_TYPE primary_source_type;
   ENUM_TIMEFRAMES primary_source_tf;
   int touch_count;
   int touch_episode_count;
   datetime last_touch_time;
   int bars_since_last_touch;
   double historical_reaction_atr;
   double reaction_atr_3bars;
   double reaction_atr_5bars;
   double reaction_atr_10bars;
   double maximum_reaction_atr;
   int time_to_reaction_1atr_sec;
   int time_to_reaction_2atr_sec;
   double strength_score;
   ENUM_VEGAR_STRENGTH_CLASS strength_class;
   bool focus;
   bool valid;
  };

struct SVegarChannel
  {
   string id;
   string account;
   string server;
   string symbol;
   ENUM_TIMEFRAMES execution_tf;
   long magic;
   string instance_id;
   string run_id;
   ENUM_TIMEFRAMES tf;
   ENUM_VEGAR_CHANNEL_DIRECTION direction;
   ENUM_VEGAR_CHANNEL_GEOMETRY geometry_class;
   datetime anchor1_time;
   datetime anchor2_time;
   double anchor1_price;
   double anchor2_price;
   double slope_price_per_bar;
   double offset_price;
   double current_upper_rail;
   double current_mid_rail;
   double current_lower_rail;
   double channel_width_price;
   double channel_width_atr;
   double current_price_position_percent;
   double distance_upper_rail_atr;
   double distance_lower_rail_atr;
   double strength_score;
   ENUM_VEGAR_STRENGTH_CLASS strength_class;
   double efficiency_ratio;
   double slope_atr_per_bar;
   double respect_fraction;
   int coherent_confirmations;
   double structure_score_component;
   double slope_score_component;
   double er_score_component;
   double respect_score_component;
   datetime created_time;
   datetime last_changed;
   bool superseded;
   bool valid;
  };

struct SVegarFlowSnapshot
  {
   ENUM_TIMEFRAMES tf;
   datetime bar_time;
   double directional_body;
   double close_location_mean;
   double net_progress;
   double expansion;
   double flow_score;
   ENUM_VEGAR_FLOW_CLASS flow_class;
   bool buyer_absorbed;
   bool seller_absorbed;
   bool dual_absorption;
   string observation_flow_class;
   bool decision_authority;
   bool valid;
  };

struct SVegarNewsStatus
  {
   ENUM_VEGAR_NEWS_STATE state;
   string currency;
   string event_name;
   int importance;
   datetime event_time;
   int seconds_to_event;
   string provider;
   bool valid;
  };

struct SVegarSessionStatus
  {
   bool london;
   bool new_york;
   bool allowed;
   string label;
   datetime ny_time;
   datetime server_time;
  };

struct SVegarZoneEventSnapshot
  {
   bool valid;
   string zone_id;
   string symbol;
   ENUM_VEGAR_ZONE_ROLE role;
   ENUM_VEGAR_ZONE_TYPE type;
   ENUM_TIMEFRAMES source_tf;
   ENUM_VEGAR_BIAS bias;
   ENUM_VEGAR_LIQUIDITY_SIDE liquidity_side;
   ENUM_VEGAR_ZONE_STATE pre_state;
   double pre_strength;
   double low;
   double high;
   double mid;
   double source_atr;
   datetime closed_bar_time;
   double closed_bar_open;
   double closed_bar_high;
   double closed_bar_low;
   double closed_bar_close;
   bool approach_observed;
   bool sweep_observed;
   bool sweep_too_deep;
   double sweep_extreme;
   double distance_atr;
   ENUM_VEGAR_ZONE_STATE post_state;
  };

struct SVegarApproachLatch
  {
   bool active;
   string candidate_id;
   string zone_id;
   ENUM_VEGAR_BIAS direction;
   long first_approach_time_msc;
   long last_approach_time_msc;
   double minimum_distance_atr;
   bool touched_zone;
   bool entered_zone;
   datetime current_bar_time;
   int bars_alive;
  };

SVegarApproachLatch gVegarApproachLatch;

struct SVegarOpportunity
  {
   bool active;
   string candidate_id;
   ENUM_VEGAR_CANDIDATE_STATE candidate_state;
   ENUM_VEGAR_SETUP_FAMILY setup_family;
   bool observation_candidate;
   bool technical_signal_ready;
   bool operational_eligible_at_approach;
   ENUM_VEGAR_REASON_CODE approach_block_reason;
   bool operational_approach_armed;
   bool operational_signal_ready;
   bool execution_authorized;
   int failed_gate_count;
   string failed_gates;
   string context_gate;
   string m5_gate;
   string session_gate;
   string news_gate;
   string opposite_liquidity_gate;
   string target_space_gate;
   string spread_gate;
   string stop_gate;
   string daily_target_gate;
   string daily_loss_gate;
   string max_trades_gate;
   string loss_streak_gate;
   string position_gate;
   string ownership_gate;
   string market_gate;
   string trading_permission_gate;
   string margin_gate;
   string stops_level_gate;
   string freeze_level_gate;
   string order_check_gate;
   string risk_gate;
   string preflight_gate;
   string pipeline_state;
   string marker_id;
   string strategy_hash;
   string opportunity_id;
   string snapshot_id;
   string signal_id;
   string setup_id;
   ENUM_VEGAR_SETUP_STATE state;
   ENUM_VEGAR_BIAS direction;
   string focus_zone_id;
   double focus_zone_strength;
   string source_zone_id;
   ENUM_VEGAR_ZONE_ROLE source_zone_role;
   ENUM_VEGAR_ZONE_TYPE source_zone_type;
   ENUM_TIMEFRAMES source_zone_tf;
   ENUM_VEGAR_BIAS source_zone_bias;
   ENUM_VEGAR_LIQUIDITY_SIDE source_zone_liquidity_side;
   ENUM_VEGAR_ZONE_STATE source_zone_pre_state;
   ENUM_VEGAR_ZONE_STATE source_zone_post_state;
   bool source_zone_consumed_by_opportunity;
   double source_zone_low;
   double source_zone_high;
   double source_zone_mid;
   double source_zone_atr;
   ENUM_VEGAR_APPROACH_MODE approach_mode;
   datetime approach_first_time;
   double approach_minimum_distance_atr;
   bool sweep_same_bar_as_approach;
   datetime created_time;
   datetime state_time;
   datetime sweep_time;
   datetime mss_time;
   datetime displacement_time;
   datetime retest_time;
   int bars_since_sweep;
   int bars_since_mss;
   double sweep_extreme;
   double micro_break_level;
   ENUM_VEGAR_RETEST_TYPE retest_type;
   double retest_low;
   double retest_high;
   double retest_mid;
   double hypothetical_entry_bid;
   double hypothetical_entry_ask;
   double technical_stop;
   double technical_stop_money;
   double opposite_liquidity_price;
   double expected_money_opposite;
   // RC8 near-miss telemetry: evidence before any threshold change.
   double mss_required_level;
   double mss_best_observed;
   double mss_distance_missing;
   double displacement_required_range_ratio;
   double displacement_observed_range_ratio;
   double displacement_required_close_location;
   double displacement_observed_close_location;
   ENUM_VEGAR_REASON_CODE last_reason;
   bool intent_emitted;
   bool terminal_recorded;
  };

struct SVegarIntent
  {
   bool valid;
   bool processed;
   string intent_id;
   string opportunity_id;
   string snapshot_id;
   string setup_id;
   string signal_id;
   string focus_zone_id;
   ENUM_VEGAR_BIAS direction;
   datetime signal_bar_time;
   datetime created_time;
   double requested_volume;
   double entry_price;
   double stop_price;
   double take_profit_price;
   double stop_money;
   double economic_target_money;
   string reason_detail;
  };

struct SVegarRiskSnapshot
  {
   bool pass;
   ENUM_VEGAR_REASON_CODE reason;
   double volume;
   double technical_stop_price;
   double technical_stop_money;
   double free_margin;
   double margin_level;
   double projected_margin;
   double projected_free_margin;
   double spread_points;
   double spread_ticks;
   double spread_money;
   double spread_target_percent;
   double economic_target_money;
   double expected_money_opposite;
   double daily_result;
   int trades_today;
   int consecutive_losses;
   bool commission_model_incomplete;
   double estimated_round_turn_commission;
   double estimated_fee;
   double estimated_swap;
   double estimated_total_costs;
   double expected_reward_net;
   double daily_loss_limit;
   double realized_loss;
   double open_worst_case_risk;
   double estimated_new_trade_worst_case;
   double daily_remaining_risk;
  };

struct SVegarProfitState
  {
   bool active;
   ulong position_ticket;
   long position_id;
   ENUM_VEGAR_BIAS direction;
   double entry_price;
   double volume;
   double peak_profit_money;
   double protected_profit_money;
   double last_committed_peak;
   bool peak_known;
   bool runner_active;
   datetime last_runner_update;
   string trade_cycle_id;
   string intent_id;
   string opportunity_id;
   string setup_id;
   string focus_zone_id;
   double technical_stop;
   double take_profit;
   double current_profit_money;
   double current_swap_money;
   double current_commission_money;
   double current_fee_money;
   double current_net_profit_money;
   double last_server_sl;
   bool protected_floor_installed;
   bool broker_tp_removed_for_runner;
   bool software_exit_requested;
   string exit_reason;
  };

struct SVegarReplayJob
  {
   bool active;
   bool completed;
   string account;
   string server;
   string symbol;
   ENUM_TIMEFRAMES execution_tf;
   double point;
   double tick_size;
   int digits;
   string account_currency;
   long magic;
   string run_id;
   string instance_id;
   string marker_id;
   string strategy_hash;
   string opportunity_id;
   ENUM_VEGAR_BIAS direction;
   datetime origin_time;
   datetime entry_bar_time;
   double entry_bid;
   double entry_ask;
   double entry_price;
   double stop_price;
   double volume;
   double target_money;
   double opposite_liquidity_price;
   int horizon_bars;
   bool cost_model_incomplete;
  };

struct SVegarObservationCandidate
  {
   bool active;
   string candidate_id;
   ENUM_VEGAR_CANDIDATE_STATE candidate_state;
   ENUM_VEGAR_SETUP_FAMILY setup_family;
   string symbol;
   ENUM_TIMEFRAMES execution_tf;
   ENUM_VEGAR_BIAS direction;
   string zone_id;
   ENUM_VEGAR_ZONE_ROLE zone_role;
   ENUM_TIMEFRAMES zone_tf;
   double zone_strength;
   ENUM_VEGAR_ZONE_STATE source_zone_pre_state;
   ENUM_VEGAR_ZONE_STATE source_zone_post_state;
   ENUM_VEGAR_APPROACH_MODE approach_mode;
   datetime approach_first_time;
   double approach_minimum_distance_atr;
   bool sweep_same_bar_as_approach;
   datetime created_time;
   datetime sweep_time;
   datetime mss_time;
   datetime displacement_time;
   datetime retest_time;
   ENUM_VEGAR_SETUP_STATE state;
   bool operational_eligible_at_approach;
   ENUM_VEGAR_REASON_CODE approach_block_reason;
   bool operational_approach_armed;
   bool technical_signal_ready;
   int bars_since_sweep;
   int bars_since_mss;
   double sweep_extreme;
   double micro_break_level;
   ENUM_VEGAR_RETEST_TYPE retest_type;
   double retest_low;
   double retest_high;
   double retest_mid;
   double hypothetical_entry_bid;
   double hypothetical_entry_ask;
   double technical_stop;
   double technical_stop_money;
   double opposite_liquidity_price;
   double expected_money_opposite;
   // RC8 near-miss telemetry mirrors operational Opportunity evidence.
   double mss_required_level;
   double mss_best_observed;
   double mss_distance_missing;
   double displacement_required_range_ratio;
   double displacement_observed_range_ratio;
   double displacement_required_close_location;
   double displacement_observed_close_location;
   string marker_id;
  };

struct SVegarSignalMarker
  {
   bool active;
   string marker_id;
   string candidate_id;
   ENUM_VEGAR_SETUP_FAMILY setup_family;
   string opportunity_id;
   string setup_id;
   string signal_id;
   string intent_id;
   string symbol;
   ENUM_TIMEFRAMES tf;
   datetime signal_time;
   double signal_price;
   ENUM_VEGAR_BIAS direction;
   ENUM_VEGAR_MARKER_CLASS marker_class;
   bool technical_signal_ready;
   bool operational_eligible_at_approach;
   bool operational_signal_ready;
   bool preflight_passed;
   bool order_send_called;
   bool order_accepted;
   bool deal_confirmed;
   string zone_id;
   ENUM_VEGAR_ZONE_ROLE zone_role;
   bool execution_authorized;
   string context_gate;
   string m5_gate;
   string session_gate;
   string news_gate;
   string target_space_gate;
   string spread_gate;
   string risk_gate;
   string preflight_gate;
   string pipeline_state;
   int failed_gate_count;
   string failed_gates;
   ENUM_VEGAR_REASON_CODE primary_reason;
   ulong order_ticket;
   ulong deal_ticket;
   long position_id;
   string final_state;
  };


struct SVegarExecutionRequest
  {
   bool valid;
   bool frozen;
   string intent_id;
   string opportunity_id;
   string request_hash;
   string canonical;
   datetime frozen_at;
   MqlTradeRequest request;
   bool order_check_called;
   uint order_check_retcode;
   string order_check_comment;
   double technical_stop_price;
   double technical_stop_money;
   double stop_money_final;
   double tp_money_final;
   double estimated_costs;
   double economic_spread_money;
   double expected_reward_net;
  };

struct SVegarExecutionResult
  {
   bool preflight_ok;
   bool order_check_called;
   bool order_send_called;
   bool request_accepted;
   uint order_check_retcode;
   string order_check_comment;
   uint trade_retcode;
   string trade_comment;
   ulong order_ticket;
   ulong deal_ticket;
   double requested_price;
   double fill_price;
   string request_hash;
   bool request_frozen;
   double stop_money_final;
   double tp_money_final;
   double estimated_costs;
   double economic_spread_money;
   double expected_reward_net;
   ENUM_VEGAR_REASON_CODE reason;
  };

struct SVegarRuntimeStats
  {
   ulong sequence;
   int order_send_attempts;
   int intents_created;
   int intents_processed;
   int opportunities_created;
   int opportunities_blocked;
   int opportunities_expired;
   int csv_errors;
   string last_block;
   uint last_trade_retcode;
   string last_trade_comment;
   ulong last_deal_ticket;
   ulong last_position_ticket;
  };

// ------------------------- HELPERS ---------------------------------------
string Vegar_EnvironmentText(const ENUM_VEGAR_ENVIRONMENT v)
  {
   if(v==VEGAR_ENV_TESTER) return "TESTER";
   if(v==VEGAR_ENV_DEMO) return "DEMO";
   if(v==VEGAR_ENV_REAL) return "REAL";
   return "UNSUPPORTED";
  }

string Vegar_EngineStateText(const ENUM_VEGAR_ENGINE_STATE v)
  {
   if(v==VEGAR_ENGINE_ACTIVE) return "ATIVO";
   if(v==VEGAR_ENGINE_PAUSED) return "PAUSADO";
   return "ERRO";
  }

string Vegar_ExecutionStateText(const ENUM_VEGAR_EXECUTION_STATE v)
  {
   if(v==VEGAR_EXECUTION_ENABLED) return "LIBERADA";
   if(v==VEGAR_EXECUTION_BLOCKED_CONFIGURATION) return "BLOQUEADA/CONFIG";
   if(v==VEGAR_EXECUTION_BLOCKED_SESSION) return "BLOQUEADA/SESSAO";
   if(v==VEGAR_EXECUTION_BLOCKED_NEWS) return "BLOQUEADA/NEWS";
   if(v==VEGAR_EXECUTION_BLOCKED_SPREAD) return "BLOQUEADA/SPREAD";
   if(v==VEGAR_EXECUTION_BLOCKED_RISK) return "BLOQUEADA/RISCO";
   if(v==VEGAR_EXECUTION_BLOCKED_DAILY_LIMIT) return "BLOQUEADA/LIMITE";
   if(v==VEGAR_EXECUTION_BLOCKED_POSITION) return "BLOQUEADA/POSICAO";
   if(v==VEGAR_EXECUTION_BLOCKED_MARKET) return "BLOQUEADA/MERCADO";
   if(v==VEGAR_EXECUTION_BLOCKED_EXECUTION) return "BLOQUEADA/EXECUCAO";
   if(v==VEGAR_EXECUTION_BLOCKED_DATA) return "BLOQUEADA/DADOS";
   if(v==VEGAR_EXECUTION_BLOCKED_ACCOUNT) return "BLOQUEADA/CONTA";
   if(v==VEGAR_EXECUTION_BLOCKED_SELF_TEST) return "BLOQUEADA/SELF-TEST";
   if(v==VEGAR_EXECUTION_BLOCKED_RECOVERY) return "BLOQUEADA/RECOVERY";
   if(v==VEGAR_EXECUTION_BLOCKED_OWNERSHIP) return "BLOQUEADA/OWNERSHIP";
   return "ERRO";
  }

string Vegar_BiasText(const ENUM_VEGAR_BIAS v)
  {
   if(v==VEGAR_BIAS_BUYER) return "BUYER";
   if(v==VEGAR_BIAS_SELLER) return "SELLER";
   return "NONE";
  }

string Vegar_ZoneStateText(const ENUM_VEGAR_ZONE_STATE v)
  {
   switch(v)
     {
      case VEGAR_ZONE_CREATED: return "CREATED";
      case VEGAR_ZONE_ACTIVE: return "ACTIVE";
      case VEGAR_ZONE_APPROACH: return "APPROACH";
      case VEGAR_ZONE_TOUCHED: return "TOUCHED";
      case VEGAR_ZONE_SWEPT: return "SWEPT";
      case VEGAR_ZONE_INVALIDATED: return "INVALIDATED";
      case VEGAR_ZONE_EXPIRED: return "EXPIRED";
     }
   return "UNKNOWN";
  }

string Vegar_StrengthClassText(const ENUM_VEGAR_STRENGTH_CLASS c)
  {
   switch(c)
     {
      case VEGAR_STRENGTH_MUITO_FRACA: return "MUITO_FRACA";
      case VEGAR_STRENGTH_FRACA: return "FRACA";
      case VEGAR_STRENGTH_MEDIA: return "MEDIA";
      case VEGAR_STRENGTH_FORTE: return "FORTE";
      case VEGAR_STRENGTH_EXTREMA: return "EXTREMA";
     }
   return "MUITO_FRACA";
  }

ENUM_VEGAR_STRENGTH_CLASS Vegar_StrengthClass(const double score)
  {
   if(score>=80.0) return VEGAR_STRENGTH_EXTREMA;
   if(score>=60.0) return VEGAR_STRENGTH_FORTE;
   if(score>=40.0) return VEGAR_STRENGTH_MEDIA;
   if(score>=20.0) return VEGAR_STRENGTH_FRACA;
   return VEGAR_STRENGTH_MUITO_FRACA;
  }

string Vegar_ChannelText(const ENUM_VEGAR_CHANNEL_DIRECTION d)
  {
   if(d==VEGAR_CHANNEL_BUYER) return "BUYER";
   if(d==VEGAR_CHANNEL_SELLER) return "SELLER";
   return "NEUTRAL";
  }

string Vegar_M15ContextText(const ENUM_VEGAR_M15_CONTEXT c)
  {
   switch(c)
     {
      case VEGAR_M15_TREND_UP: return "TREND_UP";
      case VEGAR_M15_TREND_DOWN: return "TREND_DOWN";
      case VEGAR_M15_RANGE: return "RANGE";
      case VEGAR_M15_TRANSITION: return "TRANSITION";
      default: return "UNKNOWN";
     }
  }

string Vegar_FlowClassText(const ENUM_VEGAR_FLOW_CLASS c)
  {
   switch(c)
     {
      case VEGAR_FLOW_COMPRADOR_FORTE: return "COMPRADOR_FORTE";
      case VEGAR_FLOW_COMPRADOR: return "COMPRADOR";
      case VEGAR_FLOW_NEUTRO: return "NEUTRO";
      case VEGAR_FLOW_VENDEDOR: return "VENDEDOR";
      case VEGAR_FLOW_VENDEDOR_FORTE: return "VENDEDOR_FORTE";
      case VEGAR_FLOW_BUYER_ABSORBED: return "BUYER_ABSORBED";
      case VEGAR_FLOW_SELLER_ABSORBED: return "SELLER_ABSORBED";
     }
   return "NEUTRO";
  }

string Vegar_SetupStateText(const ENUM_VEGAR_SETUP_STATE s)
  {
   switch(s)
     {
      case VEGAR_SETUP_IDLE: return "IDLE";
      case VEGAR_SETUP_LIQUIDITY_APPROACH: return "LIQUIDITY_APPROACH";
      case VEGAR_SETUP_SWEEP_CONFIRMED: return "SWEEP_CONFIRMED";
      case VEGAR_SETUP_WAITING_MSS: return "WAITING_MSS";
      case VEGAR_SETUP_MSS_CONFIRMED: return "MSS_CONFIRMED";
      case VEGAR_SETUP_WAITING_DISPLACEMENT: return "WAITING_DISPLACEMENT";
      case VEGAR_SETUP_DISPLACEMENT_CONFIRMED: return "DISPLACEMENT_CONFIRMED";
      case VEGAR_SETUP_ENTRY_ZONE_CREATED: return "ENTRY_ZONE_CREATED";
      case VEGAR_SETUP_WAITING_RETEST: return "WAITING_RETEST";
      case VEGAR_SETUP_RETEST_CONFIRMED: return "RETEST_CONFIRMED";
      case VEGAR_SETUP_ENTRY_INTENT: return "ENTRY_INTENT";
      case VEGAR_SETUP_PREFLIGHT: return "PREFLIGHT";
      case VEGAR_SETUP_ORDER_REQUEST: return "ORDER_REQUEST";
      case VEGAR_SETUP_POSITION_OPEN: return "POSITION_OPEN";
      case VEGAR_SETUP_POSITION_MANAGEMENT: return "POSITION_MANAGEMENT";
      case VEGAR_SETUP_POSITION_CLOSED: return "POSITION_CLOSED";
      case VEGAR_SETUP_BLOCKED: return "BLOCKED";
      case VEGAR_SETUP_INVALIDATED_STATE: return "INVALIDATED";
      case VEGAR_SETUP_EXPIRED: return "EXPIRED";
      case VEGAR_SETUP_ERROR: return "ERROR";
     }
   return "ERROR";
  }

string Vegar_ReasonText(const ENUM_VEGAR_REASON_CODE r)
  {
   switch(r)
     {
      case VEGAR_REASON_NONE: return "NONE";
      case DATA_NOT_READY: return "DATA_NOT_READY";
      case DATA_NOT_SYNCHRONIZED: return "DATA_NOT_SYNCHRONIZED";
      case TIMEFRAME_NOT_ALLOWED: return "TIMEFRAME_NOT_ALLOWED";
      case SESSION_BLOCKED: return "SESSION_BLOCKED";
      case NEWS_HIGH_IMPACT: return "NEWS_HIGH_IMPACT";
      case NEWS_DATA_UNAVAILABLE: return "NEWS_DATA_UNAVAILABLE";
      case DAILY_TARGET_REACHED: return "DAILY_TARGET_REACHED";
      case DAILY_LOSS_REACHED: return "DAILY_LOSS_REACHED";
      case DAILY_RISK_BUDGET_INSUFFICIENT: return "DAILY_RISK_BUDGET_INSUFFICIENT";
      case MAX_TRADES_REACHED: return "MAX_TRADES_REACHED";
      case LOSS_STREAK_LOCK: return "LOSS_STREAK_LOCK";
      case M15_RANGE_BLOCK: return "M15_RANGE_BLOCK";
      case M15_DIRECTION_CONFLICT: return "M15_DIRECTION_CONFLICT";
      case NO_ACTIVE_ZONE: return "NO_ACTIVE_ZONE";
      case ZONE_TOO_WEAK: return "ZONE_TOO_WEAK";
      case SWEEP_NOT_CONFIRMED: return "SWEEP_NOT_CONFIRMED";
      case SWEEP_TOO_DEEP: return "SWEEP_TOO_DEEP";
      case MSS_NOT_CONFIRMED: return "MSS_NOT_CONFIRMED";
      case DISPLACEMENT_NOT_CONFIRMED: return "DISPLACEMENT_NOT_CONFIRMED";
      case NO_FVG_OR_OB: return "NO_FVG_OR_OB";
      case RETEST_EXPIRED: return "RETEST_EXPIRED";
      case RETEST_NOT_CONFIRMED: return "RETEST_NOT_CONFIRMED";
      case M5_CONFIRM_CONFLICT: return "M5_CONFIRM_CONFLICT";
      case STOP_MONEY_EXCEEDED: return "STOP_MONEY_EXCEEDED";
      case TARGET_SPACE_INSUFFICIENT: return "TARGET_SPACE_INSUFFICIENT";
      case SPREAD_TOO_HIGH: return "SPREAD_TOO_HIGH";
      case POSITION_EXISTS: return "POSITION_EXISTS";
      case NETTING_EXTERNAL_POSITION: return "NETTING_EXTERNAL_POSITION";
      case LOT_INVALID: return "LOT_INVALID";
      case MARGIN_TOO_LOW: return "MARGIN_TOO_LOW";
      case PRICE_INVALID: return "PRICE_INVALID";
      case STOPS_INVALID: return "STOPS_INVALID";
      case FREEZE_LEVEL_BLOCK: return "FREEZE_LEVEL_BLOCK";
      case MARKET_CLOSED: return "MARKET_CLOSED";
      case TRADING_DISABLED: return "TRADING_DISABLED";
      case AUTOTRADING_DISABLED: return "AUTOTRADING_DISABLED";
      case ORDER_CHECK_REJECTED: return "ORDER_CHECK_REJECTED";
      case ORDER_SEND_REJECTED: return "ORDER_SEND_REJECTED";
      case DUPLICATE_INTENT: return "DUPLICATE_INTENT";
      case STALE_INTENT: return "STALE_INTENT";
      case SETUP_ABORTED_BY_REINIT: return "SETUP_ABORTED_BY_REINIT";
      case CSV_WRITE_ERROR: return "CSV_WRITE_ERROR";
      case CONFIG_STOP_MONEY_UNSET: return "CONFIG_STOP_MONEY_UNSET";
      case CONFIG_OPERATION_TARGET_INVALID: return "CONFIG_OPERATION_TARGET_INVALID";
      case CONFIG_TAKE_PROFIT_INVALID: return "CONFIG_TAKE_PROFIT_INVALID";
      case CONFIG_DAILY_TARGET_INVALID: return "CONFIG_DAILY_TARGET_INVALID";
      case CONFIG_RUNNER_INVALID: return "CONFIG_RUNNER_INVALID";
      case CONFIG_PROFIT_EXIT_UNSET: return "CONFIG_PROFIT_EXIT_UNSET";
      case CONFIG_PROFIT_MODE_CONFLICT: return "CONFIG_PROFIT_MODE_CONFLICT";
      case ECONOMIC_TARGET_UNAVAILABLE: return "ECONOMIC_TARGET_UNAVAILABLE";
      case DUPLICATE_INSTANCE: return "DUPLICATE_INSTANCE";
      case COMMISSION_MODEL_UNDEFINED: return "COMMISSION_MODEL_UNDEFINED";
      case ZONE_BREAKOUT: return "ZONE_BREAKOUT";
      case SETUP_INVALIDATED_REASON: return "SETUP_INVALIDATED";
      case CONFIG_INVALID_GENERAL: return "CONFIG_INVALID_GENERAL";
      case ORDER_REQUEST_NOT_ALLOWED: return "ORDER_REQUEST_NOT_ALLOWED";
      case POSITION_OWNERSHIP_AMBIGUOUS: return "POSITION_OWNERSHIP_AMBIGUOUS";
      case REPLAY_WAITING_HORIZON: return "REPLAY_WAITING_HORIZON";
      case ACCOUNT_MODE_UNSUPPORTED: return "ACCOUNT_MODE_UNSUPPORTED";
      case ENVIRONMENT_DETECTION_FAILED: return "ENVIRONMENT_DETECTION_FAILED";
      case EXECUTION_BLOCKED_CONFIGURATION: return "EXECUTION_BLOCKED_CONFIGURATION";
      case EXECUTION_BLOCKED_ACCOUNT: return "EXECUTION_BLOCKED_ACCOUNT";
      case ENGINE_PAUSED: return "ENGINE_PAUSED";
      case CONFIG_SESSION_INVALID: return "CONFIG_SESSION_INVALID";
      case SELF_TEST_FAILED: return "SELF_TEST_FAILED";
      case CROSS_SYMBOL_ENTITY_REJECTED: return "CROSS_SYMBOL_ENTITY_REJECTED";
      case REPLAY_SYMBOL_UNAVAILABLE: return "REPLAY_SYMBOL_UNAVAILABLE";
      case NO_VALID_OPPOSITE_ZONE: return "NO_VALID_OPPOSITE_ZONE";
      case BLOCKED_RECOVERY: return "BLOCKED_RECOVERY";
      case BLOCKED_OWNERSHIP_AMBIGUOUS: return "BLOCKED_OWNERSHIP_AMBIGUOUS";
      case RECOVERY_PROTECTION_UNCERTAIN: return "RECOVERY_PROTECTION_UNCERTAIN";
      case OBSERVATION_ONLY: return "OBSERVATION_ONLY";
      case CSV_SCHEMA_HEADER_MISMATCH: return "CSV_SCHEMA_HEADER_MISMATCH";
      case INTERNAL_ERROR: return "INTERNAL_ERROR";
      default: return "INTERNAL_ERROR";
     }
  }

string Vegar_TFText(const ENUM_TIMEFRAMES tf)
  {
   if(tf==PERIOD_M1) return "M1";
   if(tf==PERIOD_M5) return "M5";
   if(tf==PERIOD_M15) return "M15";
   if(tf==PERIOD_H4) return "H4";
   return EnumToString(tf);
  }

double Vegar_Clamp(const double v,const double lo,const double hi)
  {
   if(v<lo) return lo;
   if(v>hi) return hi;
   return v;
  }

string Vegar_SanitizeFileToken(string s)
  {
   StringReplace(s,"/","_"); StringReplace(s,"\\","_"); StringReplace(s,":","_");
   StringReplace(s," ","_"); StringReplace(s,".","_");
   return s;
  }

string Vegar_ZoneRoleText(const ENUM_VEGAR_ZONE_ROLE r)
  { return (r==VEGAR_ZONE_ROLE_OBSERVATION ? "OBSERVATION" : "OPERATIONAL"); }

string Vegar_GateStateText(const ENUM_VEGAR_GATE_STATE s)
  {
   if(s==VEGAR_GATE_PASS) return "PASS";
   if(s==VEGAR_GATE_FAIL) return "FAIL";
   if(s==VEGAR_GATE_NOT_APPLICABLE) return "NOT_APPLICABLE";
   return "NOT_EVALUATED";
  }

string Vegar_ChannelGeometryText(const ENUM_VEGAR_CHANNEL_GEOMETRY g)
  {
   if(g==VEGAR_CHANNEL_GEOMETRY_TREND) return "TREND";
   if(g==VEGAR_CHANNEL_GEOMETRY_COMPRESSION) return "COMPRESSION";
   if(g==VEGAR_CHANNEL_GEOMETRY_EXPANSION) return "EXPANSION";
   if(g==VEGAR_CHANNEL_GEOMETRY_MIXED) return "MIXED";
   return "NEUTRAL";
  }

string Vegar_MarkerClassText(const ENUM_VEGAR_MARKER_CLASS c)
  {
   if(c==VEGAR_MARKER_VALID_BUY) return "VALID_BUY";
   if(c==VEGAR_MARKER_VALID_SELL) return "VALID_SELL";
   if(c==VEGAR_MARKER_BLOCKED_BUY) return "BLOCKED_BUY";
   if(c==VEGAR_MARKER_BLOCKED_SELL) return "BLOCKED_SELL";
   if(c==VEGAR_MARKER_OBSERVATION_BUY) return "OBS_BUY";
   if(c==VEGAR_MARKER_OBSERVATION_SELL) return "OBS_SELL";
   return "NONE";
  }


string Vegar_SetupFamilyText(const ENUM_VEGAR_SETUP_FAMILY f)
  {
   if(f==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION_OBSERVATION) return "MICRO_CONTINUATION_OBSERVATION";
   if(f==VEGAR_SETUP_FAMILY_MICRO_CONTINUATION) return "MICRO_CONTINUATION";
   return "STRUCTURAL_REVERSAL";
  }

string Vegar_ApproachModeText(const ENUM_VEGAR_APPROACH_MODE m)
  {
   if(m==VEGAR_APPROACH_LIVE) return "LIVE";
   if(m==VEGAR_APPROACH_CLOSED_BAR) return "CLOSED_BAR";
   if(m==VEGAR_APPROACH_BOTH) return "BOTH";
   return "NONE";
  }

string Vegar_CandidateStateText(const ENUM_VEGAR_CANDIDATE_STATE s)
  {
   if(s==VEGAR_CANDIDATE_APPROACH) return "APPROACH";
   if(s==VEGAR_CANDIDATE_PROMOTED) return "PROMOTED";
   if(s==VEGAR_CANDIDATE_EXPIRED) return "EXPIRED";
   return "NONE";
  }

#endif
