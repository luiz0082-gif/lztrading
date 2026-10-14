//+------------------------------------------------------------------+
//|                                           MicroMomentum_v240.mq5 |
//|                         Micro-Momentum Tick Scalper  v2.40       |
//|   Telemetria total em CSV (append-only) + Painel HUD futurista   |
//+------------------------------------------------------------------+
#property copyright   "MicroMomentum v2.40"
#property version     "2.40"
#property description "Scalper de micro-momentum em ticks. TP e SL independentes (SL opcional)."
#property description "v2.10: anti-preso (escape no zero a zero) + contexto de tendencia leve."
#property description "v2.20: filtros de entrada, pullback virtual, escape anti-slippage, telemetria MAE-tempo."
#property description "v2.40: ordem pendente REAL (limit no recuo ou stop na continuacao), cancelada em ms se o movimento mudar."
#property description "Telemetria CSV append-only por sessao. Painel HUD com controles."

#include <Trade\Trade.mqh>

#define EA_VERSION "2.40.2"
#define BUF_CAP    4096

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum ENUM_EXIT_MODE
{
   EXIT_OFF    = 0, // Desligado
   EXIT_POINTS = 1, // Em pontos
   EXIT_MONEY  = 2  // Em dinheiro ($)
};

enum ENUM_DIR_MODE
{
   DIR_BOTH = 0, // Compra e Venda
   DIR_BUY  = 1, // Somente Compra
   DIR_SELL = 2  // Somente Venda
};

enum ENUM_PEND_MODE
{
   PEND_LIMIT = 0, // LIMIT: espera o recuo do impulso (preco melhor, sem slippage)
   PEND_STOP  = 1  // STOP: confirma a continuacao (entra so se o movimento seguir)
};

enum ENUM_EA_STATE
{
   ST_INIT = 0,
   ST_SCANNING,
   ST_IN_POSITION,
   ST_COOLDOWN,
   ST_BLOCK_CANDLE,
   ST_BLOCK_SPREAD,
   ST_BLOCK_GOAL,
   ST_BLOCK_STOP,
   ST_BLOCK_LOSSES,
   ST_BLOCK_SESSION,
   ST_BLOCK_TRADING,
   ST_PAUSED
};

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== Momentum (Entrada) ==="
input double         InpLotSize               = 0.10;      // Volume (lote)
input ENUM_DIR_MODE  InpDirMode               = DIR_BOTH;  // Direcao permitida
input int            InpMinPointsDisplacement = 30;        // Impulso minimo (pontos)
input int            InpMaxMilliseconds       = 1000;      // Janela do impulso (ms)
input int            InpMinTicksInWindow      = 4;         // Minimo de ticks na janela
input double         InpMaxPullbackPct        = 35.0;      // Pullback maximo dentro do impulso (%)
input double         InpMinDispToSpread       = 1.5;       // Impulso >= N x spread (0 = desliga)
input int            InpCooldownMs            = 1000;      // Pausa apos entrada/saida (ms)
input int            InpMaxTradesPerCandle    = 4;         // Max. entradas por vela M1
input int            InpMaxOpenPositions      = 1;         // Max. posicoes abertas simultaneas
input bool           InpAllowHedge            = false;     // Permitir posicao oposta (hedge)

input group "=== Take Profit (independente) ==="
input ENUM_EXIT_MODE InpTPMode                = EXIT_MONEY; // Modo do Take Profit
input double         InpTPMoney               = 2.00;      // TP em dinheiro ($ liquido)
input int            InpTPPoints              = 40;        // TP em pontos

input group "=== Stop Loss (opcional, independente) ==="
input ENUM_EXIT_MODE InpSLMode                = EXIT_OFF;  // Modo do Stop Loss
input double         InpSLMoney               = 10.00;     // SL em dinheiro ($)
input int            InpSLPoints              = 500;       // SL em pontos
input bool           InpServerSideStops       = true;      // Enviar SL/TP tambem ao servidor

input group "=== Saidas Adicionais ==="
input bool           InpRecoilEnable          = true;      // Sair por recuo (recoil) com lucro
input int            InpRecoilPoints          = 10;        // Recuo desde o extremo (pontos)
input double         InpRecoilMinProfit       = 0.00;      // Lucro liquido minimo p/ recoil ($)
input int            InpMaxHoldSec            = 0;         // Tempo maximo (s, 0 = off). So fecha no zero a zero ou lucro, nunca no negativo

input group "=== Anti-preso (reacao: sai no zero a zero) ==="
input int            InpEscapeSec             = 8;         // Apos N s, ativa o escape (0 = off)
input int            InpCTEscapeSec           = 4;         // Idem, para entrada contra-tendencia (0 = usa o normal)
input double         InpEscapeArmMoney        = 0.30;      // So arma se o liquido ja chegou a -$ (MAE)
input double         InpEscapeMinMoney        = 0.00;      // Sai quando liquido >= este valor ($)

input group "=== Contexto de Tendencia (leve, nao bloqueia) ==="
input bool           InpTrendEnable           = true;      // Detectar tendencia M1
input int            InpTrendBars             = 10;        // Velas M1 fechadas analisadas (+ bid atual)
input double         InpTrendMinER            = 0.35;      // Eficiencia minima p/ considerar tendencia (0..1)
input double         InpCTImpulseMult         = 1.5;       // Contra-tendencia exige impulso x N

input group "=== v2.20 Filtros de entrada (0 / vazio = desligado) ==="
input int            InpMaxImpulsePts         = 0;         // Teto de impulso (pts): acima disso nao entra (anti-pico)
input string         InpBlockWindows          = "";        // Janelas sem entrada, hora do servidor: "HH:MM-HH:MM;HH:MM-HH:MM"
input double         InpStackGateMoney        = 0.0;       // Nao empilha se alguma posicao aberta estiver pior que -$ (liquido)
input int            InpStackMinGapMs         = 0;         // Intervalo minimo entre entradas com posicao aberta (ms)

input group "=== v2.20 Entrada por micro-pullback (ordem virtual, sem pendente) ==="
input bool           InpPullbackEntry         = false;     // Esperar recuo do impulso antes de entrar
input double         InpPullbackPct           = 30.0;      // Entra quando recuar N% do impulso desde o extremo
input double         InpPullbackInvalidPct    = 70.0;      // Cancela se recuar mais que N% (impulso morreu)
input int            InpPullbackWaitMs        = 1500;      // Cancela se nao recuar em N ms

input group "=== v2.20 Anti-slippage (reacao, sai no zero a zero) ==="
input int            InpSlipHighPts           = 0;         // Slippage de entrada >= N pts marca a posicao (0 = off)
input int            InpSlipEscapeSec         = 3;         // Escape mais cedo (s) para posicao marcada; exige InpEscapeSec > 0

input group "=== v2.40 Ordem pendente real (substitui a entrada a mercado) ==="
input bool           InpPendEnable            = false;     // Entrar por ordem pendente real
input ENUM_PEND_MODE InpPendMode              = PEND_LIMIT; // Tipo da pendente
input double         InpPendLimitPct          = 30.0;      // LIMIT: recuo de N% do impulso a partir do preco atual
input int            InpPendMinOffsetPts      = 8;         // LIMIT: recuo minimo (pts)
input int            InpPendStopPts           = 10;        // STOP: distancia alem do preco atual (pts)
input int            InpPendTtlMs             = 1500;      // Cancela se nao preencher em N ms
input int            InpPendCancelPts         = 40;        // LIMIT: cancela se o preco fugir N pts alem do extremo | STOP: cancela se recuar N pts do extremo
input int            InpPendRearmMs           = 300;       // Intervalo minimo entre duas pendentes (ms)
input int            InpPendSafetyExpirySec   = 180;       // Expiracao de seguranca no servidor (s; 0 = GTC). O cancelamento real e do EA

input group "=== Risco & Filtros ==="
input int            InpMaxSpreadPoints       = 30;        // Spread maximo (pontos)
input bool           InpDailyGoalEnable       = true;      // Ativar meta diaria
input double         InpDailyGoalMoney        = 15.0;      // Meta diaria ($)
input bool           InpDailyStopEnable       = true;      // Ativar stop diario
input double         InpDailyStopMoney        = 50.0;      // Perda diaria maxima ($, valor positivo)
input bool           InpCloseOnDailyLimit     = true;      // Fechar posicoes ao bater meta/stop
input int            InpMaxConsecLosses       = 0;         // Pausar apos N perdas seguidas (0 = off)
input int            InpPauseMinutes          = 15;        // Duracao da pausa (min)
input bool           InpSessionEnable         = false;     // Filtrar por horario (servidor)
input int            InpSessionStartHour      = 1;         // Hora inicial
input int            InpSessionEndHour        = 23;        // Hora final
input int            InpDeviationPoints       = 20;        // Desvio maximo (pontos)
input int            InpRetries               = 1;         // Tentativas extras (requote)

input group "=== Telemetria CSV ==="
input bool           InpEnableTelemetry       = true;      // Gravar telemetria
input bool           InpLogEveryTick          = true;      // Gravar TODOS os ticks
input int            InpMaxFileMB             = 64;        // Rotacionar arquivo ao passar de (MB)
input int            InpFlushMs               = 500;       // Flush periodico (ms)
input string         InpTelemetryRoot         = "MicroMomentum"; // Pasta raiz (MQL5\Files\)

input group "=== Painel & Grafico ==="
input bool           InpShowPanel             = true;      // Mostrar painel HUD
input int            InpPanelX                = 12;        // Painel X
input int            InpPanelY                = 24;        // Painel Y
input bool           InpApplyTheme            = true;      // Aplicar tema escuro no grafico
input bool           InpDrawMarks             = true;      // Marcar entradas/saidas no grafico

input group "=== Sistema ==="
input ulong          InpMagicNumber           = 1001;      // Magic Number

//+------------------------------------------------------------------+
//| Estruturas                                                       |
//+------------------------------------------------------------------+
struct SSig
{
   int      dir;      // +1 compra, -1 venda, 0 nada
   double   up;       // alta (pts) do minimo da janela ate o bid atual
   double   dn;       // queda (pts) do maximo da janela ate o bid atual
   int      n;        // ticks na janela
   long     span;     // duracao real coberta (ms)
   string   note;     // motivo/diagnostico
};

struct SPos
{
   ulong    ticket;
   long     type;
   double   volume;
   double   open_price;
   long     open_msc;
   double   extreme;
   double   cur;
   double   net;
   double   pts;
   double   peak_net, trough_net;
   double   peak_pts, trough_pts;
   double   sl, tp;
   double   comm;       // comissao/fee dos deals de entrada (historico)
   bool     seen;
   ulong    last_close_try;
   string   exit_reason;
   double   e_up, e_dn, e_spread, e_slip;
   int      e_n;
   ulong    e_lat;
   bool     ct;         // entrada contra a tendencia M1
   long     mae_ms;     // ms desde a abertura ate o pior ponto (pts)
   double   p1, p3, p5; // pts em ~1s/3s/5s apos a abertura (DBL_MAX = nao amostrado)
   double   e_imp;      // impulso (pts) na direcao da entrada
   double   e_pbwait, e_pbret; // espera (ms) e recuo (%) quando entrou por pullback (DBL_MAX = n/a)
   bool     slip_high;  // slippage de entrada >= InpSlipHighPts
};

//+------------------------------------------------------------------+
//| Classe CSV: append-only, rotacao por tamanho, nunca sobrescreve   |
//+------------------------------------------------------------------+
long g_max_bytes = 64 * 1024 * 1024;

class CCsv
{
public:
   string name, header, folder;
   int    h;
   long   rows, bytes;
   int    part;
   bool   crit;

   CCsv() { h = INVALID_HANDLE; rows = 0; bytes = 0; part = 1; crit = false; }

   bool Open(const string dir, const string nm, const string hdr, const bool critical)
   {
      folder = dir; name = nm; header = hdr; crit = critical; part = 1;
      return Reopen();
   }

   bool Reopen()
   {
      string fn = folder + "\\" + name + (part > 1 ? "_p" + StringFormat("%03d", part) : "") + ".csv";
      h = FileOpen(fn, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
      if(h == INVALID_HANDLE)
      {
         Print("[MMX] FileOpen falhou: ", fn, " err=", GetLastError());
         return false;
      }
      FileSeek(h, 0, SEEK_END);
      bytes = (long)FileSize(h);
      if(bytes == 0) Raw(header);
      return true;
   }

   void Raw(const string line)
   {
      uint n = FileWriteString(h, line + "\r\n");
      bytes += (long)n;
      rows++;
   }

   void Write(const string line)
   {
      if(h == INVALID_HANDLE) return;
      Raw(line);
      if(crit) FileFlush(h);
      if(bytes > g_max_bytes)
      {
         FileClose(h);
         h = INVALID_HANDLE;
         part++;
         Reopen();
      }
   }

   void Flush() { if(h != INVALID_HANDLE) FileFlush(h); }

   void Close()
   {
      if(h != INVALID_HANDLE) { FileFlush(h); FileClose(h); h = INVALID_HANDLE; }
   }
};

//+------------------------------------------------------------------+
//| Cabecalhos dos CSVs                                              |
//+------------------------------------------------------------------+
const string PFX_H = "seq,t_server,t_local,mono_us";

const string H_TICKS  = PFX_H + ",tick_msc,dt_ms,bid,ask,last,volume,flags,spread_pts,win_ticks,win_span_ms,up_pts,dn_pts,cand_dir,note,state,block_reason,own_pos,float_net,daily_pl";
const string H_BARS   = PFX_H + ",bar_time,open,high,low,close,tick_volume,spread,real_volume";
const string H_SIGS   = PFX_H + ",dir,action,reason,up_pts,dn_pts,win_ticks,win_span_ms,spread_pts,bid,ask,thr_pts,window_ms,trend_dir,trend_er";
const string H_ORDERS = PFX_H + ",action,dir,volume,req_price,sl,tp,attempt,ok,retcode,retcode_desc,fill_price,slip_pts,deal,order,latency_us,bid,ask,spread_pts,comment";
const string H_TRANS  = PFX_H + ",mine,type,order,deal,position,symbol,order_type,order_state,deal_type,price,sl,tp,volume,req_retcode,req_comment";
const string H_POS    = PFX_H + ",ticket,dir,volume,open_price,cur_price,pts,net,peak_net,trough_net,peak_pts,trough_pts,extreme,pull_from_extreme_pts,hold_ms,sl,tp";
const string H_TRADES = PFX_H + ",ticket,dir,volume,open_time,open_price,close_time,close_price,pts,profit,commission,swap,fee,net,hold_ms,mfe_pts,mae_pts,mfe_money,mae_money,exit_reason,entry_up_pts,entry_dn_pts,entry_ticks,entry_spread,entry_slip_pts,entry_latency_us,sl,tp,counter_trend,mae_ms,pts_1s,pts_3s,pts_5s,entry_impulse_pts,pb_wait_ms,pb_retrace_pct,slip_high";
const string H_ACCT   = PFX_H + ",balance,equity,margin,free_margin,margin_level,profit,daily_real,daily_float,daily_pl,trades_today,wins_today,losses_today,ping_us,connected,ticks_per_s";
const string H_EVENTS = PFX_H + ",level,code,message,state";
const string H_CHART  = PFX_H + ",event,lparam,dparam,sparam,chart_w,chart_h,first_bar,bars_visible,price_min,price_max,scale";
const string H_PARAMS = PFX_H + ",key,value";

//+------------------------------------------------------------------+
//| Globais                                                          |
//+------------------------------------------------------------------+
CTrade        m_trade;
MqlTick       g_tick;
MqlTick       g_prev_tick;

// buffer circular de ticks
double        g_bid[BUF_CAP];
long          g_msc[BUF_CAP];
int           g_head  = -1;
int           g_count = 0;

// estado
ENUM_EA_STATE g_state   = ST_INIT;
string        g_reason  = "";
SSig          g_sig;
double        g_point   = 0.0;
double        g_spread  = 0.0;
bool          g_paused  = false;
bool          g_close_all_req = false;
bool          g_minimized = false;

long          g_cooldown_until = 0;
datetime      g_bar_time = 0;
int           g_trades_candle = 0;
datetime      g_pause_until = 0;
int           g_consec_losses = 0;
long          g_last_skip_ms = 0;
string        g_last_skip = "";

// tendencia M1 (contexto)
int           g_trend_dir = 0;
double        g_trend_er  = 0.0;
ulong         g_t_trend   = 0;

// posicoes
SPos          g_pos[];
int           g_own_count = 0, g_own_buy = 0, g_own_sell = 0;
double        g_float = 0.0;

// contexto de entrada aguardando o registro da posicao
bool          g_ctx_valid = false;
ulong         g_ctx_ms = 0;
SSig          g_ctx_sig;
double        g_ctx_spread = 0, g_ctx_slip = 0;
ulong         g_ctx_lat = 0;
bool          g_ctx_ct = false;
double        g_ctx_imp = DBL_MAX, g_ctx_pbwait = DBL_MAX, g_ctx_pbret = DBL_MAX;
long          g_last_entry_msc = 0;

// v2.40: ordem pendente real (no maximo uma por vez)
bool          g_pend_on = false;
ulong         g_pend_ticket = 0;
int           g_pend_dir = 0;
double        g_pend_price = 0, g_pend_vol = 0, g_pend_ext = 0, g_pend_ext0 = 0, g_pend_spread = 0;
long          g_pend_t0 = 0, g_pend_next_ms = 0;
ulong         g_pend_lat = 0;
bool          g_pend_ct = false;
SSig          g_pend_sig;
bool          g_pend_gtc = false;   // a corretora recusou expiracao: usar GTC

// v2.20: pullback virtual
bool          g_pb_on = false;
int           g_pb_dir = 0;
long          g_pb_t0 = 0;
double        g_pb_ext = 0, g_pb_base = 0;
SSig          g_pb_sig;
double        g_pb_fire_wait = DBL_MAX, g_pb_fire_pct = DBL_MAX;

// v2.20: janelas sem entrada (minutos do dia, hora do servidor)
int           g_win_n = 0;
int           g_win_s[];
int           g_win_e[];

// diario
datetime      g_day0 = 0;
double        g_daily_real = 0, g_daily_pl = 0;
bool          g_block_goal = false, g_block_stop = false;
int           g_d_n = 0, g_d_w = 0, g_d_l = 0;
double        g_d_gp = 0, g_d_gl = 0;

// tempos / contadores
ulong         g_t_panel = 0, g_t_flush = 0, g_t_acct = 0, g_t_daily = 0, g_t_rate = 0;
ulong         g_tick_count = 0, g_tc_prev = 0;
double        g_tick_rate = 0.0;
ulong         g_seq = 0;
string        g_env_sig = "";

// telemetria
string        g_session = "", g_day_tag = "", g_dir = "";
string        g_last_event = "INIT", g_last_event_msg = "";
CCsv          c_ticks, c_bars, c_sigs, c_orders, c_trans, c_pos, c_trades, c_acct, c_events, c_chart, c_params;

// painel
string        g_ui_all[];
string        g_ui_det[];
int           g_pw = 376;

const color C_BG    = C'6,10,20';
const color C_PANEL = C'12,18,34';
const color C_LINE  = C'28,42,70';
const color C_CYAN  = C'0,229,255';
const color C_GREEN = C'0,255,156';
const color C_RED   = C'255,59,107';
const color C_AMBER = C'255,184,0';
const color C_MAG   = C'214,74,255';
const color C_TXT   = C'214,226,245';
const color C_DIM   = C'110,128,160';

//+------------------------------------------------------------------+
//| Utilitarios                                                      |
//+------------------------------------------------------------------+
string StateName(const ENUM_EA_STATE s)
{
   switch(s)
   {
      case ST_INIT:          return "INIT";
      case ST_SCANNING:      return "SCANNING";
      case ST_IN_POSITION:   return "IN_POSITION";
      case ST_COOLDOWN:      return "COOLDOWN";
      case ST_BLOCK_CANDLE:  return "BLOCK_CANDLE";
      case ST_BLOCK_SPREAD:  return "BLOCK_SPREAD";
      case ST_BLOCK_GOAL:    return "BLOCK_GOAL";
      case ST_BLOCK_STOP:    return "BLOCK_STOP";
      case ST_BLOCK_LOSSES:  return "BLOCK_LOSSES";
      case ST_BLOCK_SESSION: return "BLOCK_SESSION";
      case ST_BLOCK_TRADING: return "BLOCK_TRADING";
      case ST_PAUSED:        return "PAUSED";
   }
   return "?";
}

string TsMs(const long msc)
{
   datetime t = (datetime)(msc / 1000);
   return TimeToString(t, TIME_DATE | TIME_SECONDS) + "." + StringFormat("%03d", (int)(msc % 1000));
}

long NowMsc()
{
   long srv = (long)TimeTradeServer() * 1000;
   return (g_tick.time_msc > srv) ? g_tick.time_msc : srv;
}

string Pfx()
{
   g_seq++;
   return IntegerToString((long)g_seq) + "," + TsMs(NowMsc()) + "," +
          TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS) + "," +
          IntegerToString((long)GetMicrosecondCount());
}

string Q(string s)
{
   StringReplace(s, "\"", "'");
   StringReplace(s, "\r", " ");
   StringReplace(s, "\n", " ");
   return "\"" + s + "\"";
}

string D(const double v, const int dig) { return DoubleToString(v, dig); }
string Sg(const double v)               { return (v >= 0 ? "+" : "") + DoubleToString(v, 2); }
string I(const long v)                  { return IntegerToString(v); }
string OptD(const double v, const int dig) { return (v == DBL_MAX) ? "" : DoubleToString(v, dig); }

datetime DayStart(const datetime t)
{
   MqlDateTime d;
   TimeToStruct(t, d);
   d.hour = 0; d.min = 0; d.sec = 0;
   return StructToTime(d);
}

double NormVol(double v)
{
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(st <= 0) st = mn;
   if(st <= 0) return 0;
   v = MathFloor(v / st + 1e-9) * st;
   v = MathMax(mn, MathMin(mx, v));
   int vd = (int)MathMax(0, MathRound(-MathLog10(st)));
   return NormalizeDouble(v, vd);
}

double TickValue()
{
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
   if(tv <= 0) tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   return tv;
}

// dinheiro -> distancia de preco
double MoneyToDist(const double money, const double vol)
{
   double tv = TickValue();
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tv <= 0 || ts <= 0 || vol <= 0) return 0;
   return money / (vol * tv / ts);
}

// pontos -> dinheiro
double PtsToMoney(const double pts, const double vol)
{
   double tv = TickValue();
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) return 0;
   return pts * g_point / ts * tv * vol;
}

string ExitDesc(const ENUM_EXIT_MODE m, const double pts, const double money, const double vol)
{
   if(m == EXIT_OFF) return "OFF";
   if(m == EXIT_POINTS) return D(pts, 0) + " pts (~$" + D(PtsToMoney(pts, vol), 2) + ")";
   return "$" + D(money, 2) + " (~" + D(MoneyToDist(money, vol) / g_point, 0) + " pts)";
}

bool TradingAllowed(string &why)
{
   why = "";
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) { why = "AlgoTrading do terminal DESLIGADO"; return false; }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))           { why = "Trading do EA desabilitado nas propriedades"; return false; }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))   { why = "Conta sem permissao de trade"; return false; }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))    { why = "Conta nao permite EAs"; return false; }
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))     { why = "Terminal desconectado"; return false; }
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) { why = "Simbolo nao esta em modo FULL"; return false; }
   return true;
}

//+------------------------------------------------------------------+
//| Telemetria: abrir / fechar / logs                                |
//+------------------------------------------------------------------+
void TelOpen()
{
   g_max_bytes = (long)MathMax(4, InpMaxFileMB) * 1024 * 1024;
   MqlDateTime d;
   TimeToStruct(TimeTradeServer(), d);
   g_day_tag = StringFormat("%04d%02d%02d", d.year, d.mon, d.day);

   string p1 = InpTelemetryRoot;
   string p2 = p1 + "\\" + _Symbol + "_" + IntegerToString((long)InpMagicNumber);
   string p3 = p2 + "\\" + g_day_tag;
   string p4 = p3 + "\\" + g_session;
   FolderCreate(p1);
   FolderCreate(p2);
   FolderCreate(p3);
   FolderCreate(p4);
   g_dir = p4;

   c_events.Open(g_dir, "events",       H_EVENTS, true);
   c_params.Open(g_dir, "params",       H_PARAMS, true);
   c_orders.Open(g_dir, "orders",       H_ORDERS, true);
   c_trades.Open(g_dir, "trades",       H_TRADES, true);
   c_trans.Open(g_dir,  "transactions", H_TRANS,  true);
   c_sigs.Open(g_dir,   "signals",      H_SIGS,   true);
   c_bars.Open(g_dir,   "bars",         H_BARS,   true);
   c_chart.Open(g_dir,  "chart",        H_CHART,  true);
   c_acct.Open(g_dir,   "account",      H_ACCT,   false);
   c_pos.Open(g_dir,    "positions",    H_POS,    false);
   c_ticks.Open(g_dir,  "ticks",        H_TICKS,  false);
}

void TelClose()
{
   c_ticks.Close(); c_bars.Close(); c_sigs.Close(); c_orders.Close(); c_trans.Close();
   c_pos.Close(); c_trades.Close(); c_acct.Close(); c_events.Close(); c_chart.Close(); c_params.Close();
}

void TelFlush()
{
   c_ticks.Flush(); c_bars.Flush(); c_sigs.Flush(); c_orders.Flush(); c_trans.Flush();
   c_pos.Flush(); c_trades.Flush(); c_acct.Flush(); c_events.Flush(); c_chart.Flush(); c_params.Flush();
}

long TelRows()
{
   return c_ticks.rows + c_bars.rows + c_sigs.rows + c_orders.rows + c_trans.rows + c_pos.rows +
          c_trades.rows + c_acct.rows + c_events.rows + c_chart.rows + c_params.rows;
}

long TelBytes()
{
   return c_ticks.bytes + c_bars.bytes + c_sigs.bytes + c_orders.bytes + c_trans.bytes + c_pos.bytes +
          c_trades.bytes + c_acct.bytes + c_events.bytes + c_chart.bytes + c_params.bytes;
}

void LogEvent(const string level, const string code, const string msg)
{
   g_last_event = code;
   g_last_event_msg = msg;
   Print("[MMX] ", level, " ", code, " | ", msg);
   if(!InpEnableTelemetry) return;
   c_events.Write(Pfx() + "," + level + "," + code + "," + Q(msg) + "," + StateName(g_state));
}

void LogParam(const string k, const string v)
{
   if(!InpEnableTelemetry) return;
   c_params.Write(Pfx() + "," + Q(k) + "," + Q(v));
}

void LogTick(const SSig &s)
{
   if(!InpEnableTelemetry || !InpLogEveryTick) return;
   long dt = (g_prev_tick.time_msc > 0) ? (g_tick.time_msc - g_prev_tick.time_msc) : 0;
   c_ticks.Write(Pfx() + "," + I(g_tick.time_msc) + "," + I(dt) + "," + D(g_tick.bid, _Digits) + "," +
                 D(g_tick.ask, _Digits) + "," + D(g_tick.last, _Digits) + "," + I((long)g_tick.volume) + "," +
                 I((long)g_tick.flags) + "," + D(g_spread, 0) + "," + I(s.n) + "," + I(s.span) + "," +
                 D(s.up, 1) + "," + D(s.dn, 1) + "," + I(s.dir) + "," + s.note + "," + StateName(g_state) + "," +
                 Q(g_reason) + "," + I(g_own_count) + "," + D(g_float, 2) + "," + D(g_daily_pl, 2));
}

void LogSignal(const SSig &s, const string action, const string reason)
{
   if(!InpEnableTelemetry) return;
   c_sigs.Write(Pfx() + "," + I(s.dir) + "," + action + "," + Q(reason) + "," + D(s.up, 1) + "," + D(s.dn, 1) + "," +
                I(s.n) + "," + I(s.span) + "," + D(g_spread, 0) + "," + D(g_tick.bid, _Digits) + "," +
                D(g_tick.ask, _Digits) + "," + I(InpMinPointsDisplacement) + "," + I(InpMaxMilliseconds) + "," +
                I(g_trend_dir) + "," + D(g_trend_er, 3));
}

void LogOrder(const string action, const int dir, const double vol, const double req, const double sl, const double tp,
              const int attempt, const bool ok, const ulong lat_us, const string cmt)
{
   if(!InpEnableTelemetry) return;
   double fp = m_trade.ResultPrice();
   double slip = (fp > 0) ? ((dir > 0) ? (fp - req) / g_point : (req - fp) / g_point) : 0;
   c_orders.Write(Pfx() + "," + action + "," + I(dir) + "," + D(vol, 2) + "," + D(req, _Digits) + "," +
                  D(sl, _Digits) + "," + D(tp, _Digits) + "," + I(attempt) + "," + (ok ? "1" : "0") + "," +
                  I((long)m_trade.ResultRetcode()) + "," + Q(m_trade.ResultRetcodeDescription()) + "," +
                  D(fp, _Digits) + "," + D(slip, 1) + "," + I((long)m_trade.ResultDeal()) + "," +
                  I((long)m_trade.ResultOrder()) + "," + I((long)lat_us) + "," + D(g_tick.bid, _Digits) + "," +
                  D(g_tick.ask, _Digits) + "," + D(g_spread, 0) + "," + Q(cmt + " | " + m_trade.ResultComment()));
}

void LogPosRow(const int k)
{
   if(!InpEnableTelemetry) return;
   double pull = (g_pos[k].type == POSITION_TYPE_BUY) ? (g_pos[k].extreme - g_pos[k].cur) / g_point
                                                       : (g_pos[k].cur - g_pos[k].extreme) / g_point;
   c_pos.Write(Pfx() + "," + I((long)g_pos[k].ticket) + "," + (g_pos[k].type == POSITION_TYPE_BUY ? "1" : "-1") + "," +
               D(g_pos[k].volume, 2) + "," + D(g_pos[k].open_price, _Digits) + "," + D(g_pos[k].cur, _Digits) + "," +
               D(g_pos[k].pts, 1) + "," + D(g_pos[k].net, 2) + "," + D(g_pos[k].peak_net, 2) + "," +
               D(g_pos[k].trough_net, 2) + "," + D(g_pos[k].peak_pts, 1) + "," + D(g_pos[k].trough_pts, 1) + "," +
               D(g_pos[k].extreme, _Digits) + "," + D(pull, 1) + "," + I(g_tick.time_msc - g_pos[k].open_msc) + "," +
               D(g_pos[k].sl, _Digits) + "," + D(g_pos[k].tp, _Digits));
}

void LogAccount()
{
   if(!InpEnableTelemetry) return;
   c_acct.Write(Pfx() + "," + D(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "," + D(AccountInfoDouble(ACCOUNT_EQUITY), 2) + "," +
                D(AccountInfoDouble(ACCOUNT_MARGIN), 2) + "," + D(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2) + "," +
                D(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2) + "," + D(AccountInfoDouble(ACCOUNT_PROFIT), 2) + "," +
                D(g_daily_real, 2) + "," + D(g_float, 2) + "," + D(g_daily_pl, 2) + "," + I(g_d_n) + "," + I(g_d_w) + "," +
                I(g_d_l) + "," + I(TerminalInfoInteger(TERMINAL_PING_LAST)) + "," +
                (TerminalInfoInteger(TERMINAL_CONNECTED) ? "1" : "0") + "," + D(g_tick_rate, 1));
}

void LogBar(const MqlRates &r)
{
   if(!InpEnableTelemetry) return;
   c_bars.Write(Pfx() + "," + TimeToString(r.time, TIME_DATE | TIME_SECONDS) + "," + D(r.open, _Digits) + "," +
                D(r.high, _Digits) + "," + D(r.low, _Digits) + "," + D(r.close, _Digits) + "," + I(r.tick_volume) + "," +
                I(r.spread) + "," + I(r.real_volume));
}

string ChartEvName(const int id)
{
   switch(id)
   {
      case CHARTEVENT_KEYDOWN:        return "KEYDOWN";
      case CHARTEVENT_MOUSE_MOVE:     return "MOUSE_MOVE";
      case CHARTEVENT_OBJECT_CREATE:  return "OBJECT_CREATE";
      case CHARTEVENT_OBJECT_CHANGE:  return "OBJECT_CHANGE";
      case CHARTEVENT_OBJECT_DELETE:  return "OBJECT_DELETE";
      case CHARTEVENT_CLICK:          return "CLICK";
      case CHARTEVENT_OBJECT_CLICK:   return "OBJECT_CLICK";
      case CHARTEVENT_OBJECT_DRAG:    return "OBJECT_DRAG";
      case CHARTEVENT_OBJECT_ENDEDIT: return "OBJECT_ENDEDIT";
      case CHARTEVENT_CHART_CHANGE:   return "CHART_CHANGE";
   }
   if(id >= CHARTEVENT_CUSTOM) return "CUSTOM+" + IntegerToString(id - CHARTEVENT_CUSTOM);
   return "ID_" + IntegerToString(id);
}

string ReasonText(const int r)
{
   switch(r)
   {
      case REASON_PROGRAM:     return "PROGRAM (ExpertRemove)";
      case REASON_REMOVE:      return "REMOVE (EA removido do grafico)";
      case REASON_RECOMPILE:   return "RECOMPILE";
      case REASON_CHARTCHANGE: return "CHARTCHANGE (simbolo/periodo)";
      case REASON_CHARTCLOSE:  return "CHARTCLOSE";
      case REASON_PARAMETERS:  return "PARAMETERS (inputs alterados)";
      case REASON_ACCOUNT:     return "ACCOUNT (troca de conta/reconexao)";
      case REASON_TEMPLATE:    return "TEMPLATE";
      case REASON_INITFAILED:  return "INITFAILED";
      case REASON_CLOSE:       return "CLOSE (terminal fechado)";
   }
   return "REASON_" + IntegerToString(r);
}

//+------------------------------------------------------------------+
//| Buffer de ticks + analise do impulso                             |
//+------------------------------------------------------------------+
void BufPush(const MqlTick &t)
{
   g_head = (g_head + 1) % BUF_CAP;
   g_bid[g_head] = t.bid;
   g_msc[g_head] = t.time_msc;
   if(g_count < BUF_CAP) g_count++;
}

void Analyze(SSig &s)
{
   s.dir = 0; s.up = 0; s.dn = 0; s.n = 0; s.span = 0; s.note = "";
   if(g_count < 2 || g_head < 0) { s.note = "buffer"; return; }

   double bid_now = g_bid[g_head];
   long   now     = g_msc[g_head];
   double lo = bid_now, hi = bid_now;
   long   t_old = now;
   int    n = 0;

   for(int i = 0; i < g_count; i++)
   {
      int idx = (g_head - i + BUF_CAP) % BUF_CAP;
      if(now - g_msc[idx] > InpMaxMilliseconds) break;
      if(g_bid[idx] < lo) lo = g_bid[idx];
      if(g_bid[idx] > hi) hi = g_bid[idx];
      t_old = g_msc[idx];
      n++;
   }

   s.up   = (bid_now - lo) / g_point;
   s.dn   = (hi - bid_now) / g_point;
   s.n    = n;
   s.span = now - t_old;

   if(n < InpMinTicksInWindow) { s.note = "poucos_ticks"; return; }

   double thr = (double)InpMinPointsDisplacement;
   bool buy  = (s.up >= thr && s.dn <= s.up * InpMaxPullbackPct / 100.0);
   bool sell = (s.dn >= thr && s.up <= s.dn * InpMaxPullbackPct / 100.0);
   if(buy && sell) { buy = (s.up >= s.dn); sell = !buy; }

   if(!buy && !sell)
   {
      s.note = (s.up >= thr || s.dn >= thr) ? "pullback_excedido" : "sem_impulso";
      return;
   }

   double mv = buy ? s.up : s.dn;
   if(InpMinDispToSpread > 0 && mv < InpMinDispToSpread * g_spread) { s.note = "fraco_vs_spread"; return; }

   s.dir  = buy ? 1 : -1;
   s.note = "SINAL";
}

//+------------------------------------------------------------------+
//| Contexto de tendencia M1 (Efficiency Ratio, ponta viva no bid)   |
//| ER = |liquido| / caminho percorrido. 0 = lateral, 1 = tendencia   |
//+------------------------------------------------------------------+
void TrendUpdate()
{
   g_trend_dir = 0;
   g_trend_er  = 0;
   if(!InpTrendEnable) return;

   int n = MathMax(3, InpTrendBars);
   double c[];
   if(CopyClose(_Symbol, PERIOD_M1, 1, n, c) != n) return;   // c[0] = mais antiga fechada

   // ponta viva: o bid atual entra como ultimo ponto, entao a tendencia reage
   // DENTRO da vela, sem esperar o fechamento dela
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(bid <= 0) return;

   double net = bid - c[0], path = 0;
   for(int i = 1; i < n; i++) path += MathAbs(c[i] - c[i - 1]);
   path += MathAbs(bid - c[n - 1]);

   g_trend_er = (path > 0) ? MathAbs(net) / path : 0;
   if(g_trend_er >= InpTrendMinER) g_trend_dir = (net > 0) ? 1 : -1;
}

//+------------------------------------------------------------------+
//| Estado                                                           |
//+------------------------------------------------------------------+
ENUM_EA_STATE ComputeState(string &why)
{
   why = "";
   if(g_paused) { why = "pausa manual (painel)"; return ST_PAUSED; }

   string pw;
   if(!TradingAllowed(pw)) { why = pw; return ST_BLOCK_TRADING; }

   if(g_block_goal) { why = "meta diaria atingida"; return ST_BLOCK_GOAL; }
   if(g_block_stop) { why = "stop diario atingido"; return ST_BLOCK_STOP; }

   if(InpMaxConsecLosses > 0 && TimeCurrent() < g_pause_until)
   {
      why = "pausa por perdas seguidas ate " + TimeToString(g_pause_until, TIME_SECONDS);
      return ST_BLOCK_LOSSES;
   }

   if(InpSessionEnable)
   {
      MqlDateTime d;
      TimeToStruct(TimeTradeServer(), d);
      if(d.hour < InpSessionStartHour || d.hour >= InpSessionEndHour)
      {
         why = "fora do horario " + IntegerToString(InpSessionStartHour) + "-" + IntegerToString(InpSessionEndHour) + "h";
         return ST_BLOCK_SESSION;
      }
   }

   if(g_own_count >= InpMaxOpenPositions) { why = "limite de posicoes abertas"; return ST_IN_POSITION; }
   if(g_tick.time_msc < g_cooldown_until) { why = "cooldown " + I(g_cooldown_until - g_tick.time_msc) + "ms"; return ST_COOLDOWN; }
   if(g_trades_candle >= InpMaxTradesPerCandle) { why = "limite de entradas na vela M1"; return ST_BLOCK_CANDLE; }
   if(g_spread > InpMaxSpreadPoints) { why = "spread " + D(g_spread, 0) + " > " + I(InpMaxSpreadPoints); return ST_BLOCK_SPREAD; }

   return ST_SCANNING;
}

//+------------------------------------------------------------------+
//| Stops do servidor                                                |
//+------------------------------------------------------------------+
void BuildStops(const int dir, const double price, const double vol, double &sl, double &tp)
{
   sl = 0; tp = 0;
   if(!InpServerSideStops) return;

   double tpd = 0, sld = 0;
   if(InpTPMode == EXIT_POINTS)      tpd = InpTPPoints * g_point;
   else if(InpTPMode == EXIT_MONEY)  tpd = MoneyToDist(InpTPMoney, vol);
   if(InpSLMode == EXIT_POINTS)      sld = InpSLPoints * g_point;
   else if(InpSLMode == EXIT_MONEY)  sld = MoneyToDist(InpSLMoney, vol);

   double lvl = MathMax((double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL),
                        (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL)) * g_point;
   double bid = g_tick.bid, ask = g_tick.ask;

   if(dir > 0)
   {
      if(tpd > 0) tp = MathMax(price + tpd, bid + lvl + g_point);
      if(sld > 0) sl = MathMin(price - sld, bid - lvl - g_point);
   }
   else
   {
      if(tpd > 0) tp = MathMin(price - tpd, ask - lvl - g_point);
      if(sld > 0) sl = MathMax(price + sld, ask + lvl + g_point);
   }
   if(tp > 0) tp = NormalizeDouble(tp, _Digits);
   if(sl > 0) sl = NormalizeDouble(sl, _Digits);
}

bool MarginOK(const int dir, const double vol)
{
   double m = 0;
   ENUM_ORDER_TYPE ot = (dir > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double price = (dir > 0) ? g_tick.ask : g_tick.bid;
   if(!OrderCalcMargin(ot, _Symbol, vol, price, m)) return true;
   return (m <= AccountInfoDouble(ACCOUNT_MARGIN_FREE));
}

//+------------------------------------------------------------------+
//| Envio de ordem a mercado                                         |
//+------------------------------------------------------------------+
bool SendMarket(const int dir, const double vol, const SSig &s)
{
   bool use_stops = true;
   for(int a = 0; a <= InpRetries + 1; a++)
   {
      if(!SymbolInfoTick(_Symbol, g_tick)) break;
      g_spread = (g_tick.ask - g_tick.bid) / g_point;
      double price = (dir > 0) ? g_tick.ask : g_tick.bid;
      double sl = 0, tp = 0;
      if(use_stops) BuildStops(dir, price, vol, sl, tp);

      ulong t0 = GetMicrosecondCount();
      bool sent = (dir > 0) ? m_trade.Buy(vol, _Symbol, price, sl, tp, "MMX_BUY")
                            : m_trade.Sell(vol, _Symbol, price, sl, tp, "MMX_SELL");
      ulong lat = GetMicrosecondCount() - t0;
      uint  rc  = m_trade.ResultRetcode();
      bool  done = (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL || rc == TRADE_RETCODE_PLACED);

      LogOrder("OPEN", dir, vol, price, sl, tp, a, done, lat, sent ? "sent" : "send_failed");

      if(done)
      {
         double fp = m_trade.ResultPrice();
         g_ctx_valid  = true;
         g_ctx_ms     = GetTickCount64();
         g_ctx_sig    = s;
         g_ctx_spread = g_spread;
         g_ctx_slip   = (fp > 0) ? ((dir > 0) ? (fp - price) / g_point : (price - fp) / g_point) : 0;
         g_ctx_lat    = lat;
         g_ctx_imp    = (dir > 0) ? s.up : s.dn;
         g_ctx_pbwait = g_pb_fire_wait;
         g_ctx_pbret  = g_pb_fire_pct;
         LogEvent("INFO", "ENTRY_FILLED", (dir > 0 ? "BUY " : "SELL ") + D(vol, 2) + " @ " + D(fp > 0 ? fp : price, _Digits) +
                  " up=" + D(s.up, 1) + " dn=" + D(s.dn, 1) + " ticks=" + I(s.n) + " lat_us=" + I((long)lat) +
                  (g_ctx_ct ? " [CONTRA-TENDENCIA]" : ""));
         return true;
      }

      LogEvent("ERROR", "ENTRY_REJECTED", "retcode=" + I((long)rc) + " " + m_trade.ResultRetcodeDescription() +
               " attempt=" + I(a) + " err=" + I(GetLastError()));

      if(rc == TRADE_RETCODE_INVALID_STOPS && use_stops) { use_stops = false; continue; }
      if(rc == TRADE_RETCODE_REQUOTE || rc == TRADE_RETCODE_PRICE_CHANGED || rc == TRADE_RETCODE_PRICE_OFF) continue;
      break;
   }
   return false;
}

//--- janelas sem entrada: "HH:MM-HH:MM;HH:MM-HH:MM" (hora do servidor; fim exclusivo; aceita virada de dia)
bool ParseWindows()
{
   g_win_n = 0;
   ArrayResize(g_win_s, 0);
   ArrayResize(g_win_e, 0);
   string txt = InpBlockWindows;
   StringTrimLeft(txt); StringTrimRight(txt);
   if(txt == "") return true;

   string parts[];
   int n = StringSplit(txt, ';', parts);
   for(int i = 0; i < n; i++)
   {
      StringTrimLeft(parts[i]); StringTrimRight(parts[i]);
      if(parts[i] == "") continue;
      string hh[];
      if(StringSplit(parts[i], '-', hh) != 2) return false;
      string a[], b[];
      if(StringSplit(hh[0], ':', a) != 2 || StringSplit(hh[1], ':', b) != 2) return false;
      int s0 = (int)StringToInteger(a[0]) * 60 + (int)StringToInteger(a[1]);
      int e0 = (int)StringToInteger(b[0]) * 60 + (int)StringToInteger(b[1]);
      if(s0 < 0 || s0 > 1439 || e0 < 0 || e0 > 1439 || s0 == e0) return false;
      ArrayResize(g_win_s, g_win_n + 1);
      ArrayResize(g_win_e, g_win_n + 1);
      g_win_s[g_win_n] = s0;
      g_win_e[g_win_n] = e0;
      g_win_n++;
   }
   return true;
}

bool InBlockWindow()
{
   if(g_win_n == 0) return false;
   MqlDateTime d;
   TimeToStruct(TimeTradeServer(), d);
   int m = d.hour * 60 + d.min;
   for(int i = 0; i < g_win_n; i++)
   {
      if(g_win_s[i] < g_win_e[i]) { if(m >= g_win_s[i] && m < g_win_e[i]) return true; }
      else                        { if(m >= g_win_s[i] || m < g_win_e[i]) return true; }
   }
   return false;
}

void PendPlace(const SSig &s, const double vol);

void TryEntry(const SSig &s)
{
   string skip = "";
   if(InpDirMode == DIR_BUY && s.dir < 0)       skip = "modo_somente_compra";
   else if(InpDirMode == DIR_SELL && s.dir > 0) skip = "modo_somente_venda";
   else if(!InpAllowHedge && ((s.dir > 0 && g_own_sell > 0) || (s.dir < 0 && g_own_buy > 0))) skip = "posicao_oposta_aberta";

   double vol = NormVol(InpLotSize);
   if(skip == "" && vol <= 0) skip = "volume_invalido";
   if(skip == "" && !MarginOK(s.dir, vol)) skip = "margem_insuficiente";

   // contra a tendencia M1: nao bloqueia, apenas exige impulso maior
   bool ct = (InpTrendEnable && g_trend_dir != 0 && s.dir == -g_trend_dir);
   if(skip == "" && ct)
   {
      double mv = (s.dir > 0) ? s.up : s.dn;
      if(mv < InpMinPointsDisplacement * InpCTImpulseMult) skip = "contra_tendencia_fraco";
   }
   // v2.20: filtros de entrada (todos desligados por padrao)
   double mvv = (s.dir > 0) ? s.up : s.dn;
   if(skip == "" && InpMaxImpulsePts > 0 && mvv > InpMaxImpulsePts) skip = "impulso_excessivo";
   if(skip == "" && InBlockWindow()) skip = "janela_bloqueada";
   if(skip == "" && InpStackGateMoney > 0)
   {
      for(int q = 0; q < ArraySize(g_pos); q++)
         if(g_pos[q].seen && g_pos[q].net <= -InpStackGateMoney) { skip = "pilha_posicao_negativa"; break; }
   }
   if(skip == "" && InpStackMinGapMs > 0 && g_own_count > 0 && g_last_entry_msc > 0 &&
      g_tick.time_msc - g_last_entry_msc < InpStackMinGapMs) skip = "pilha_intervalo";
   g_ctx_ct = ct;

   if(skip != "")
   {
      if(skip != g_last_skip || g_tick.time_msc - g_last_skip_ms > 500)
      {
         LogSignal(s, "SKIP", skip);
         g_last_skip = skip;
         g_last_skip_ms = g_tick.time_msc;
      }
      return;
   }

   if(InpPendEnable) { PendPlace(s, vol); return; }

   LogSignal(s, "ENTER", ct ? "ok_contra_tendencia" : "ok");
   if(SendMarket(s.dir, vol, s))
   {
      g_trades_candle++;
      g_last_entry_msc = g_tick.time_msc;
      g_cooldown_until = g_tick.time_msc + InpCooldownMs;
      SyncPositions();
   }
   else
   {
      g_cooldown_until = g_tick.time_msc + MathMax(InpCooldownMs, 1000);
   }
}

//+------------------------------------------------------------------+
//| v2.20: entrada por micro-pullback (ordem virtual)                |
//| Em vez de entrar no fim do impulso, arma e espera recuar N% do   |
//| impulso. Cancela se recuar demais ou se o tempo acabar.          |
//+------------------------------------------------------------------+
void PbCancel(const string why)
{
   if(!g_pb_on) return;
   LogSignal(g_pb_sig, "SKIP", why);
   g_pb_on = false;
}

void PullbackStep()
{
   if(g_pb_on)
   {
      if(g_state != ST_SCANNING) { PbCancel("pullback_cancelado_estado"); return; }

      double bid = g_tick.bid;
      if(g_pb_dir > 0) { if(bid > g_pb_ext) g_pb_ext = bid; }
      else             { if(bid < g_pb_ext) g_pb_ext = bid; }

      double range = (g_pb_dir > 0) ? (g_pb_ext - g_pb_base) : (g_pb_base - g_pb_ext);
      double retr  = (g_pb_dir > 0) ? (g_pb_ext - bid)       : (bid - g_pb_ext);
      double pct   = (range > 0) ? retr / range * 100.0 : 0.0;
      long   el    = g_tick.time_msc - g_pb_t0;

      if(pct > InpPullbackInvalidPct) { PbCancel("pullback_invalidado"); return; }
      if(el > InpPullbackWaitMs)      { PbCancel("pullback_expirou");    return; }
      if(pct >= InpPullbackPct)
      {
         SSig s = g_pb_sig;
         s.dir = g_pb_dir;
         g_pb_on = false;
         g_pb_fire_wait = (double)el;
         g_pb_fire_pct  = pct;
         TryEntry(s);
         g_pb_fire_wait = DBL_MAX;
         g_pb_fire_pct  = DBL_MAX;
      }
      return;
   }

   if(g_state == ST_SCANNING && g_sig.dir != 0)
   {
      g_pb_on   = true;
      g_pb_dir  = g_sig.dir;
      g_pb_t0   = g_tick.time_msc;
      g_pb_sig  = g_sig;
      g_pb_ext  = g_tick.bid;
      g_pb_base = (g_sig.dir > 0) ? g_tick.bid - g_sig.up * g_point : g_tick.bid + g_sig.dn * g_point;
      LogSignal(g_sig, "WAIT", "aguarda_pullback");
   }
}

//+------------------------------------------------------------------+
//| v2.40: ordem pendente real                                       |
//| LIMIT: ordem no preco do recuo esperado (preenche no preco da    |
//|        ordem ou melhor, sem slippage de entrada).                |
//| STOP : ordem alem do preco atual; so executa se o movimento      |
//|        continuar.                                                |
//| A ordem fica no servidor; o EA cancela em ms se o movimento      |
//| mudar (TTL, fuga, recuo, sinal oposto, bloqueio).                |
//+------------------------------------------------------------------+
double PendTickRound(const double price)
{
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) ts = g_point;
   return NormalizeDouble(MathRound(price / ts) * ts, _Digits);
}

void PendPlace(const SSig &s, const double vol)
{
   if(g_pend_on) return;

   int    dir = s.dir;
   double pt  = g_point;
   double ask = g_tick.ask, bid = g_tick.bid;
   double lvl = MathMax((double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL),
                        (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL)) * pt;
   double imp = (dir > 0) ? s.up : s.dn;
   double price = 0;
   ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY_LIMIT;

   if(InpPendMode == PEND_LIMIT)
   {
      double off = MathMax((double)InpPendMinOffsetPts, imp * InpPendLimitPct / 100.0) * pt;
      if(dir > 0) { price = MathMin(ask - off, ask - lvl - pt); ot = ORDER_TYPE_BUY_LIMIT; }
      else        { price = MathMax(bid + off, bid + lvl + pt); ot = ORDER_TYPE_SELL_LIMIT; }
   }
   else
   {
      double off = (double)InpPendStopPts * pt;
      if(dir > 0) { price = MathMax(ask + off, ask + lvl + pt); ot = ORDER_TYPE_BUY_STOP; }
      else        { price = MathMin(bid - off, bid - lvl - pt); ot = ORDER_TYPE_SELL_STOP; }
   }
   price = PendTickRound(price);

   // TP/SL do servidor ancorados no preco da ordem
   double tp = 0, sl = 0, tpd = 0, sld = 0;
   if(InpServerSideStops)
   {
      if(InpTPMode == EXIT_POINTS)      tpd = InpTPPoints * pt;
      else if(InpTPMode == EXIT_MONEY)  tpd = MoneyToDist(InpTPMoney, vol);
      if(InpSLMode == EXIT_POINTS)      sld = InpSLPoints * pt;
      else if(InpSLMode == EXIT_MONEY)  sld = MoneyToDist(InpSLMoney, vol);
      if(dir > 0) { if(tpd > 0) tp = price + tpd; if(sld > 0) sl = price - sld; }
      else        { if(tpd > 0) tp = price - tpd; if(sld > 0) sl = price + sld; }
      if(tp > 0) tp = PendTickRound(tp);
      if(sl > 0) sl = PendTickRound(sl);
   }

   // expiracao no servidor so como rede de seguranca (o cancelamento real e do EA, em ms).
   // Corretoras exigem folga minima: o padrao e 180 s; se recusar (10022) cai para GTC e o EA limpa as pendentes proprias.
   ENUM_ORDER_TYPE_TIME tt = ORDER_TIME_GTC;
   datetime exp = 0;
   if(!g_pend_gtc && InpPendSafetyExpirySec > 0 &&
      (SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_MODE) & SYMBOL_EXPIRATION_SPECIFIED) != 0)
   {
      tt  = ORDER_TIME_SPECIFIED;
      exp = TimeTradeServer() + (datetime)InpPendSafetyExpirySec;
   }

   LogSignal(s, "WAIT", InpPendMode == PEND_LIMIT ? "pendente_limit" : "pendente_stop");

   ENUM_ORDER_TYPE_FILLING fills[3] = { ORDER_FILLING_RETURN, ORDER_FILLING_IOC, ORDER_FILLING_FOK };
   bool done = false;
   uint rc = 0;
   ulong lat = 0;
   for(int f = 0; f < 3; f++)
   {
      m_trade.SetTypeFilling(fills[f]);
      for(int rp = 0; rp < 2; rp++)
      {
         ulong t0 = GetMicrosecondCount();
         bool sent = false;
         switch(ot)
         {
            case ORDER_TYPE_BUY_LIMIT:  sent = m_trade.BuyLimit(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PBUY");  break;
            case ORDER_TYPE_SELL_LIMIT: sent = m_trade.SellLimit(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PSELL"); break;
            case ORDER_TYPE_BUY_STOP:   sent = m_trade.BuyStop(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PBUY");   break;
            default:                    sent = m_trade.SellStop(vol, price, _Symbol, sl, tp, tt, exp, "MMX_PSELL");  break;
         }
         lat = GetMicrosecondCount() - t0;
         rc  = m_trade.ResultRetcode();
         done = (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_PLACED);
         LogOrder("PEND_OPEN", dir, vol, price, sl, tp, f, done, lat,
                  EnumToString(ot) + " fill=" + EnumToString(fills[f]) + " tt=" + EnumToString(tt) + (sent ? "" : " send_failed"));
         if(done) break;
         if(rc == TRADE_RETCODE_INVALID_EXPIRATION && tt != ORDER_TIME_GTC)
         {
            tt = ORDER_TIME_GTC; exp = 0; g_pend_gtc = true;
            LogEvent("WARN", "PEND_EXPIRY_FALLBACK", "corretora recusou a expiracao (10022); usando GTC. O EA cancela e limpa as pendentes proprias.");
            continue;   // repete o mesmo preenchimento sem expiracao
         }
         break;
      }
      if(done || rc != TRADE_RETCODE_INVALID_FILL) break;   // so tenta outro filling se o erro for de filling
   }
   m_trade.SetTypeFillingBySymbol(_Symbol);

   if(!done)
   {
      LogEvent("ERROR", "PEND_REJECTED", "retcode=" + I((long)rc) + " " + m_trade.ResultRetcodeDescription() +
               " tipo=" + EnumToString(ot) + " preco=" + D(price, _Digits));
      g_pend_next_ms = g_tick.time_msc + MathMax(InpPendRearmMs, 1000);
      return;
   }

   g_pend_on     = true;
   g_pend_ticket = m_trade.ResultOrder();
   g_pend_dir    = dir;
   g_pend_price  = price;
   g_pend_vol    = vol;
   g_pend_t0     = g_tick.time_msc;
   g_pend_ext    = bid;
   g_pend_ext0   = bid;
   g_pend_lat    = lat;
   g_pend_spread = g_spread;
   g_pend_ct     = g_ctx_ct;
   g_pend_sig    = s;
   LogEvent("INFO", "PEND_PLACED", "ticket=" + I((long)g_pend_ticket) + " " + EnumToString(ot) + " @ " + D(price, _Digits) +
            " tp=" + D(tp, _Digits) + " ttl=" + I(InpPendTtlMs) + "ms lat_us=" + I((long)lat));
}

//--- apaga pendentes proprias (simbolo + magic): ao ligar (sobras de queda) e ao desligar o EA
void PendCleanup(const string why)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong tk = OrderGetTicket(i);
      if(tk == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC) != (long)InpMagicNumber) continue;
      long ty = OrderGetInteger(ORDER_TYPE);
      if(ty != ORDER_TYPE_BUY_LIMIT && ty != ORDER_TYPE_SELL_LIMIT && ty != ORDER_TYPE_BUY_STOP && ty != ORDER_TYPE_SELL_STOP) continue;
      bool ok = m_trade.OrderDelete(tk);
      LogEvent("INFO", "PEND_CLEANUP", "ticket=" + I((long)tk) + " motivo=" + why + " ok=" + (ok ? "1" : "0") +
               " retcode=" + I((long)m_trade.ResultRetcode()));
   }
   g_pend_on = false;
}

bool PendHardBlock()
{
   return (g_state == ST_PAUSED || g_state == ST_BLOCK_TRADING || g_state == ST_BLOCK_GOAL ||
           g_state == ST_BLOCK_STOP || g_state == ST_BLOCK_LOSSES || g_state == ST_BLOCK_SESSION);
}

void PendManage()
{
   if(!g_pend_on) return;
   long age = g_tick.time_msc - g_pend_t0;

   if(!OrderSelect(g_pend_ticket))
   {
      // sumiu do servidor: preenchida, cancelada ou expirada
      string st = "desconhecido";
      long os = -1;
      if(HistoryOrderSelect(g_pend_ticket))
      {
         os = HistoryOrderGetInteger(g_pend_ticket, ORDER_STATE);
         st = EnumToString((ENUM_ORDER_STATE)os);
      }
      if(os == ORDER_STATE_FILLED && age < InpPendTtlMs + 5000) return;   // aguarda a posicao aparecer (AddPos limpa)
      LogEvent("INFO", "PEND_GONE", "ticket=" + I((long)g_pend_ticket) + " estado=" + st + " apos " + I(age) + "ms");
      g_pend_on = false;
      g_ctx_valid = false;
      g_pend_next_ms = g_tick.time_msc + InpPendRearmMs;
      return;
   }

   double bid = g_tick.bid;
   if(g_pend_dir > 0) { if(bid > g_pend_ext) g_pend_ext = bid; }
   else               { if(bid < g_pend_ext) g_pend_ext = bid; }

   string why = "";
   if(age >= InpPendTtlMs)                     why = "pend_ttl";
   else if(PendHardBlock())                    why = "pend_estado";
   else if(g_own_count >= InpMaxOpenPositions) why = "pend_limite_posicoes";
   else if(g_sig.dir == -g_pend_dir)           why = "pend_sinal_oposto";
   else if(InpPendMode == PEND_LIMIT)
   {
      double away = (g_pend_dir > 0) ? (g_pend_ext - g_pend_ext0) : (g_pend_ext0 - g_pend_ext);
      if(away / g_point >= InpPendCancelPts)   why = "pend_fugiu";
   }
   else
   {
      double rec = (g_pend_dir > 0) ? (g_pend_ext - bid) : (bid - g_pend_ext);
      if(rec / g_point >= InpPendCancelPts)    why = "pend_recuou";
   }
   if(why == "") return;

   ulong t0 = GetMicrosecondCount();
   m_trade.OrderDelete(g_pend_ticket);
   ulong lat = GetMicrosecondCount() - t0;
   uint rc = m_trade.ResultRetcode();
   bool done = (rc == TRADE_RETCODE_DONE);
   LogOrder("PEND_CANCEL", g_pend_dir, g_pend_vol, g_pend_price, 0, 0, 0, done, lat, why + " age=" + I(age) + "ms");
   LogSignal(g_pend_sig, "SKIP", why);
   if(done)
   {
      g_pend_on = false;
      g_ctx_valid = false;
      g_pend_next_ms = g_tick.time_msc + InpPendRearmMs;
   }
   // se falhou (ordem ja executada/removida) a proxima passada resolve pelo OrderSelect/AddPos
}

void EntryFlow()
{
   if(InpPendEnable)
   {
      PendManage();
      if(!g_pend_on && g_state == ST_SCANNING && g_sig.dir != 0 && g_tick.time_msc >= g_pend_next_ms) TryEntry(g_sig);
      return;
   }
   if(!InpPullbackEntry)
   {
      if(g_state == ST_SCANNING && g_sig.dir != 0) TryEntry(g_sig);
      return;
   }
   if(g_pb_on && g_sig.dir == -g_pb_dir) PbCancel("pullback_sinal_oposto");
   PullbackStep();
}

//+------------------------------------------------------------------+
//| Posicoes                                                         |
//+------------------------------------------------------------------+
int FindPos(const ulong ticket)
{
   for(int i = 0; i < ArraySize(g_pos); i++)
      if(g_pos[i].ticket == ticket) return i;
   return -1;
}

void PosInit(SPos &p)
{
   p.ticket = 0; p.type = 0; p.volume = 0; p.open_price = 0; p.open_msc = 0;
   p.extreme = 0; p.cur = 0; p.net = 0; p.pts = 0;
   p.peak_net = -DBL_MAX; p.trough_net = DBL_MAX; p.peak_pts = -DBL_MAX; p.trough_pts = DBL_MAX;
   p.sl = 0; p.tp = 0; p.comm = 0; p.seen = true; p.last_close_try = 0; p.exit_reason = "";
   p.e_up = 0; p.e_dn = 0; p.e_spread = 0; p.e_slip = 0; p.e_n = 0; p.e_lat = 0;
   p.ct = false;
   p.mae_ms = -1; p.p1 = DBL_MAX; p.p3 = DBL_MAX; p.p5 = DBL_MAX;
   p.e_imp = DBL_MAX; p.e_pbwait = DBL_MAX; p.e_pbret = DBL_MAX; p.slip_high = false;
}

void DrawMark(const string nm, const long msc, const double price, const ENUM_OBJECT type, const color c)
{
   if(!InpDrawMarks) return;
   string name = "MMX_M_" + nm;
   if(ObjectFind(0, name) >= 0) return;
   if(ObjectCreate(0, name, type, 0, (datetime)(msc / 1000), price))
   {
      ObjectSetInteger(0, name, OBJPROP_COLOR, c);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
}

//--- comissao/fee acumulada dos deals da posicao (substitui POSITION_COMMISSION, obsoleto)
double DealsCommission(const ulong pos_ticket)
{
   double c = 0;
   if(!HistorySelectByPosition(pos_ticket)) return 0;
   int n = HistoryDealsTotal();
   for(int i = 0; i < n; i++)
   {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      c += HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
   }
   return c;
}

int AddPos(const ulong tk)
{
   int k = ArraySize(g_pos);
   ArrayResize(g_pos, k + 1);
   PosInit(g_pos[k]);
   g_pos[k].ticket     = tk;
   g_pos[k].type       = PositionGetInteger(POSITION_TYPE);
   g_pos[k].volume     = PositionGetDouble(POSITION_VOLUME);
   g_pos[k].open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   g_pos[k].open_msc   = PositionGetInteger(POSITION_TIME_MSC);
   g_pos[k].sl         = PositionGetDouble(POSITION_SL);
   g_pos[k].tp         = PositionGetDouble(POSITION_TP);
   g_pos[k].extreme    = (g_pos[k].type == POSITION_TYPE_BUY) ? g_tick.bid : g_tick.ask;
   g_pos[k].comm       = DealsCommission(tk);

   if(g_pend_on && (ulong)PositionGetInteger(POSITION_IDENTIFIER) == g_pend_ticket)
   {
      bool pbuy = (g_pos[k].type == POSITION_TYPE_BUY);
      g_pos[k].e_up = g_pend_sig.up; g_pos[k].e_dn = g_pend_sig.dn; g_pos[k].e_n = g_pend_sig.n;
      g_pos[k].e_spread = g_pend_spread;
      g_pos[k].e_slip = pbuy ? (g_pos[k].open_price - g_pend_price) / g_point : (g_pend_price - g_pos[k].open_price) / g_point;
      g_pos[k].e_lat = g_pend_lat;
      g_pos[k].ct = g_pend_ct;
      g_pos[k].e_imp = pbuy ? g_pend_sig.up : g_pend_sig.dn;
      g_pos[k].e_pbwait = (double)(g_pos[k].open_msc - g_pend_t0);   // pb_wait_ms = espera ate o preenchimento
      g_pos[k].slip_high = (InpSlipHighPts > 0 && g_pos[k].e_slip >= InpSlipHighPts);
      g_trades_candle++;
      g_last_entry_msc = g_tick.time_msc;
      g_cooldown_until = g_tick.time_msc + InpCooldownMs;
      LogEvent("INFO", "PEND_FILLED", "ticket=" + I((long)tk) + " preco_ordem=" + D(g_pend_price, _Digits) +
               " preenchido=" + D(g_pos[k].open_price, _Digits) + " slip_pts=" + D(g_pos[k].e_slip, 1) +
               " espera_ms=" + I((long)g_pos[k].e_pbwait));
      g_pend_on = false;
      g_ctx_valid = false;
   }
   else if(g_ctx_valid && GetTickCount64() - g_ctx_ms < 5000)
   {
      g_pos[k].e_up = g_ctx_sig.up; g_pos[k].e_dn = g_ctx_sig.dn; g_pos[k].e_n = g_ctx_sig.n;
      g_pos[k].e_spread = g_ctx_spread; g_pos[k].e_slip = g_ctx_slip; g_pos[k].e_lat = g_ctx_lat;
      g_pos[k].ct = g_ctx_ct;
      g_pos[k].e_imp = g_ctx_imp; g_pos[k].e_pbwait = g_ctx_pbwait; g_pos[k].e_pbret = g_ctx_pbret;
      g_pos[k].slip_high = (InpSlipHighPts > 0 && g_ctx_slip >= InpSlipHighPts);
      g_ctx_valid = false;
   }

   bool buy = (g_pos[k].type == POSITION_TYPE_BUY);
   LogEvent("INFO", "POSITION_OPENED", "ticket=" + I((long)tk) + (buy ? " BUY " : " SELL ") + D(g_pos[k].volume, 2) +
            " @ " + D(g_pos[k].open_price, _Digits) + " sl=" + D(g_pos[k].sl, _Digits) + " tp=" + D(g_pos[k].tp, _Digits) +
            (g_pos[k].ct ? " CT" : ""));
   DrawMark(I((long)tk) + "_E", g_pos[k].open_msc, g_pos[k].open_price, buy ? OBJ_ARROW_BUY : OBJ_ARROW_SELL, buy ? C_GREEN : C_RED);
   return k;
}

void SyncPositions()
{
   for(int k = 0; k < ArraySize(g_pos); k++) g_pos[k].seen = false;
   g_own_count = 0; g_own_buy = 0; g_own_sell = 0; g_float = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;

      int k = FindPos(tk);
      if(k < 0) k = AddPos(tk);
      g_pos[k].seen = true;

      long type = PositionGetInteger(POSITION_TYPE);
      double net = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + g_pos[k].comm;
      double cur = (type == POSITION_TYPE_BUY) ? g_tick.bid : g_tick.ask;

      g_pos[k].type = type;
      g_pos[k].volume = PositionGetDouble(POSITION_VOLUME);
      g_pos[k].sl = PositionGetDouble(POSITION_SL);
      g_pos[k].tp = PositionGetDouble(POSITION_TP);
      g_pos[k].cur = cur;
      g_pos[k].net = net;
      g_pos[k].pts = (type == POSITION_TYPE_BUY) ? (cur - g_pos[k].open_price) / g_point : (g_pos[k].open_price - cur) / g_point;

      if(type == POSITION_TYPE_BUY) { if(cur > g_pos[k].extreme) g_pos[k].extreme = cur; g_own_buy++; }
      else                          { if(cur < g_pos[k].extreme) g_pos[k].extreme = cur; g_own_sell++; }

      if(net > g_pos[k].peak_net) g_pos[k].peak_net = net;
      if(net < g_pos[k].trough_net) g_pos[k].trough_net = net;
      if(g_pos[k].pts > g_pos[k].peak_pts) g_pos[k].peak_pts = g_pos[k].pts;
      if(g_pos[k].pts < g_pos[k].trough_pts)
      {
         g_pos[k].trough_pts = g_pos[k].pts;
         g_pos[k].mae_ms = g_tick.time_msc - g_pos[k].open_msc;
      }
      long age = g_tick.time_msc - g_pos[k].open_msc;
      if(g_pos[k].p1 == DBL_MAX && age >= 1000 && age <= 3000) g_pos[k].p1 = g_pos[k].pts;
      if(g_pos[k].p3 == DBL_MAX && age >= 3000 && age <= 5000) g_pos[k].p3 = g_pos[k].pts;
      if(g_pos[k].p5 == DBL_MAX && age >= 5000 && age <= 7000) g_pos[k].p5 = g_pos[k].pts;

      g_own_count++;
      g_float += net;
   }

   for(int k = ArraySize(g_pos) - 1; k >= 0; k--)
   {
      if(g_pos[k].seen) continue;
      OnPositionClosed(k);
      int n = ArraySize(g_pos);
      for(int j = k; j < n - 1; j++) g_pos[j] = g_pos[j + 1];
      ArrayResize(g_pos, n - 1);
   }

   for(int k = 0; k < ArraySize(g_pos); k++) LogPosRow(k);
   if(g_own_count == 0) g_close_all_req = false;
}

string DealReasonText(const long r)
{
   switch((int)r)
   {
      case DEAL_REASON_SL:       return "SL_SERVIDOR";
      case DEAL_REASON_TP:       return "TP_SERVIDOR";
      case DEAL_REASON_SO:       return "STOP_OUT";
      case DEAL_REASON_CLIENT:   return "MANUAL_TERMINAL";
      case DEAL_REASON_MOBILE:   return "MANUAL_MOBILE";
      case DEAL_REASON_WEB:      return "MANUAL_WEB";
      case DEAL_REASON_EXPERT:   return "EA";
      case DEAL_REASON_ROLLOVER: return "ROLLOVER";
   }
   return "OUTRO_" + IntegerToString((int)r);
}

void OnPositionClosed(const int k)
{
   SPos p = g_pos[k];
   double profit = 0, comm = 0, swap = 0, fee = 0, cprice = 0;
   long   cmsc = 0, creason = -1;
   bool   found = false;

   if(HistorySelectByPosition(p.ticket))
   {
      int n = HistoryDealsTotal();
      for(int i = 0; i < n; i++)
      {
         ulong d = HistoryDealGetTicket(i);
         if(d == 0) continue;
         profit += HistoryDealGetDouble(d, DEAL_PROFIT);
         comm   += HistoryDealGetDouble(d, DEAL_COMMISSION);
         swap   += HistoryDealGetDouble(d, DEAL_SWAP);
         fee    += HistoryDealGetDouble(d, DEAL_FEE);
         long en = HistoryDealGetInteger(d, DEAL_ENTRY);
         if(en == DEAL_ENTRY_OUT || en == DEAL_ENTRY_INOUT || en == DEAL_ENTRY_OUT_BY)
         {
            cprice  = HistoryDealGetDouble(d, DEAL_PRICE);
            cmsc    = HistoryDealGetInteger(d, DEAL_TIME_MSC);
            creason = HistoryDealGetInteger(d, DEAL_REASON);
            found   = true;
         }
      }
   }

   double net;
   string why = p.exit_reason;
   if(found)
   {
      net = profit + comm + swap + fee;
      if(why == "") why = DealReasonText(creason);
   }
   else
   {
      net = p.net; cprice = p.cur; cmsc = g_tick.time_msc;
      if(why == "") why = "DESCONHECIDO_hist_pendente";
   }

   bool buy = (p.type == POSITION_TYPE_BUY);
   double pts = buy ? (cprice - p.open_price) / g_point : (p.open_price - cprice) / g_point;
   double peak_net = (p.peak_net == -DBL_MAX) ? 0 : p.peak_net;
   double tr_net   = (p.trough_net == DBL_MAX) ? 0 : p.trough_net;
   double peak_pts = (p.peak_pts == -DBL_MAX) ? 0 : p.peak_pts;
   double tr_pts   = (p.trough_pts == DBL_MAX) ? 0 : p.trough_pts;

   if(InpEnableTelemetry)
   {
      c_trades.Write(Pfx() + "," + I((long)p.ticket) + "," + (buy ? "1" : "-1") + "," + D(p.volume, 2) + "," +
                     TsMs(p.open_msc) + "," + D(p.open_price, _Digits) + "," + TsMs(cmsc) + "," + D(cprice, _Digits) + "," +
                     D(pts, 1) + "," + D(profit, 2) + "," + D(comm, 2) + "," + D(swap, 2) + "," + D(fee, 2) + "," + D(net, 2) + "," +
                     I(cmsc - p.open_msc) + "," + D(peak_pts, 1) + "," + D(tr_pts, 1) + "," + D(peak_net, 2) + "," + D(tr_net, 2) + "," +
                     Q(why) + "," + D(p.e_up, 1) + "," + D(p.e_dn, 1) + "," + I(p.e_n) + "," + D(p.e_spread, 0) + "," +
                     D(p.e_slip, 1) + "," + I((long)p.e_lat) + "," + D(p.sl, _Digits) + "," + D(p.tp, _Digits) + "," +
                     (p.ct ? "1" : "0") + "," + (p.mae_ms >= 0 ? I(p.mae_ms) : "") + "," + OptD(p.p1, 1) + "," + OptD(p.p3, 1) + "," +
                     OptD(p.p5, 1) + "," + OptD(p.e_imp, 1) + "," + OptD(p.e_pbwait, 0) + "," + OptD(p.e_pbret, 1) + "," +
                     (p.slip_high ? "1" : "0"));
   }

   LogEvent("INFO", "POSITION_CLOSED", "ticket=" + I((long)p.ticket) + " " + why + " pts=" + D(pts, 1) + " net=" + Sg(net) +
            " hold_ms=" + I(cmsc - p.open_msc));
   DrawMark(I((long)p.ticket) + "_X", cmsc, cprice, OBJ_ARROW_CHECK, net >= 0 ? C_CYAN : C_AMBER);

   if(net < 0) g_consec_losses++; else g_consec_losses = 0;
   if(InpMaxConsecLosses > 0 && g_consec_losses >= InpMaxConsecLosses)
   {
      g_pause_until = TimeCurrent() + InpPauseMinutes * 60;
      LogEvent("WARN", "LOSS_STREAK_PAUSE", I(g_consec_losses) + " perdas seguidas. Pausa de " + I(InpPauseMinutes) + " min");
      g_consec_losses = 0;
   }

   g_cooldown_until = g_tick.time_msc + InpCooldownMs;
   DailyRefresh(true);
}

void ClosePos(const int k, const string reason)
{
   ulong now = GetTickCount64();
   if(now - g_pos[k].last_close_try < 250) return;
   g_pos[k].last_close_try = now;
   g_pos[k].exit_reason = reason;

   ulong t0 = GetMicrosecondCount();
   bool ok = m_trade.PositionClose(g_pos[k].ticket, InpDeviationPoints);
   ulong lat = GetMicrosecondCount() - t0;
   uint rc = m_trade.ResultRetcode();
   bool done = (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL);
   int dir = (g_pos[k].type == POSITION_TYPE_BUY) ? 1 : -1;
   double req = (dir > 0) ? g_tick.bid : g_tick.ask;

   LogOrder("CLOSE", dir, g_pos[k].volume, req, 0, 0, 0, done, lat, reason + (ok ? "" : " send_failed"));
   if(!done)
      LogEvent("ERROR", "CLOSE_FAILED", "ticket=" + I((long)g_pos[k].ticket) + " motivo=" + reason + " retcode=" + I((long)rc) +
               " " + m_trade.ResultRetcodeDescription());
}

void ManageExits()
{
   bool force_close = ((g_block_goal || g_block_stop) && InpCloseOnDailyLimit);

   for(int k = ArraySize(g_pos) - 1; k >= 0; k--)
   {
      string why = "";
      double net = g_pos[k].net, pts = g_pos[k].pts;
      bool buy = (g_pos[k].type == POSITION_TYPE_BUY);
      long hold = g_tick.time_msc - g_pos[k].open_msc;

      if(force_close)             why = g_block_goal ? "META_DIARIA" : "STOP_DIARIO";
      else if(g_close_all_req)    why = "FECHAR_TUDO_PAINEL";

      if(why == "" && InpTPMode == EXIT_MONEY  && net >= InpTPMoney)    why = "TP_MONEY";
      if(why == "" && InpTPMode == EXIT_POINTS && pts >= InpTPPoints)   why = "TP_POINTS";
      if(why == "" && InpSLMode == EXIT_MONEY  && net <= -InpSLMoney)   why = "SL_MONEY";
      if(why == "" && InpSLMode == EXIT_POINTS && pts <= -InpSLPoints)  why = "SL_POINTS";

      if(why == "" && InpRecoilEnable && net > InpRecoilMinProfit)
      {
         double pull = buy ? (g_pos[k].extreme - g_pos[k].cur) / g_point : (g_pos[k].cur - g_pos[k].extreme) / g_point;
         if(pull >= InpRecoilPoints) why = "RECOIL";
      }

      // ANTI-PRESO: a posicao foi pro negativo e voltou ao zero a zero -> sai na hora.
      // Nunca fecha no negativo: so reage quando o preco devolve o que tirou.
      if(why == "" && InpEscapeSec > 0)
      {
         int esc = (g_pos[k].ct && InpCTEscapeSec > 0) ? InpCTEscapeSec : InpEscapeSec;
         bool slip_fast = (g_pos[k].slip_high && InpSlipEscapeSec > 0 && InpSlipEscapeSec < esc);
         if(slip_fast) esc = InpSlipEscapeSec;
         if(hold >= (long)esc * 1000 && g_pos[k].trough_net <= -InpEscapeArmMoney && net >= InpEscapeMinMoney)
            why = slip_fast ? "ESCAPE_SLIP" : (g_pos[k].ct ? "ESCAPE_CT" : "ESCAPE");
      }

      // tempo maximo (opcional): tambem so fecha no zero a zero ou lucro
      if(why == "" && InpMaxHoldSec > 0 && hold >= (long)InpMaxHoldSec * 1000 && net >= InpEscapeMinMoney)
         why = "TEMPO_MAX";

      if(why != "") ClosePos(k, why);
   }
}

//+------------------------------------------------------------------+
//| Resultado diario                                                 |
//+------------------------------------------------------------------+
void DailyRefresh(const bool force)
{
   ulong now = GetTickCount64();
   if(!force && now - g_t_daily < 500) return;
   g_t_daily = now;

   datetime d0 = DayStart(TimeTradeServer());
   if(d0 != g_day0)
   {
      if(g_day0 != 0) LogEvent("INFO", "NEW_DAY", "Novo dia de trading. Metas e bloqueios reiniciados");
      g_day0 = d0;
      g_block_goal = false;
      g_block_stop = false;
      g_consec_losses = 0;
   }

   double real = 0, gp = 0, gl = 0;
   int n = 0, w = 0, l = 0;
   if(HistorySelect(d0, TimeCurrent() + 3600))
   {
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
      {
         ulong t = HistoryDealGetTicket(i);
         if(t == 0) continue;
         if(HistoryDealGetString(t, DEAL_SYMBOL) != _Symbol) continue;
         if(HistoryDealGetInteger(t, DEAL_MAGIC) != (long)InpMagicNumber) continue;
         long typ = HistoryDealGetInteger(t, DEAL_TYPE);
         if(typ != DEAL_TYPE_BUY && typ != DEAL_TYPE_SELL) continue;

         double v = HistoryDealGetDouble(t, DEAL_PROFIT) + HistoryDealGetDouble(t, DEAL_COMMISSION) +
                    HistoryDealGetDouble(t, DEAL_SWAP) + HistoryDealGetDouble(t, DEAL_FEE);
         real += v;
         long en = HistoryDealGetInteger(t, DEAL_ENTRY);
         if(en == DEAL_ENTRY_OUT || en == DEAL_ENTRY_INOUT || en == DEAL_ENTRY_OUT_BY)
         {
            n++;
            if(v > 0) { w++; gp += v; } else { l++; gl += -v; }
         }
      }
   }
   g_daily_real = real;
   g_daily_pl   = real + g_float;
   g_d_n = n; g_d_w = w; g_d_l = l; g_d_gp = gp; g_d_gl = gl;

   if(InpDailyGoalEnable && !g_block_goal && g_daily_pl >= InpDailyGoalMoney)
   {
      g_block_goal = true;
      LogEvent("WARN", "DAILY_GOAL_HIT", "P/L diario " + Sg(g_daily_pl) + " >= meta " + D(InpDailyGoalMoney, 2));
   }
   if(InpDailyStopEnable && !g_block_stop && g_daily_pl <= -MathAbs(InpDailyStopMoney))
   {
      g_block_stop = true;
      LogEvent("WARN", "DAILY_STOP_HIT", "P/L diario " + Sg(g_daily_pl) + " <= stop -" + D(MathAbs(InpDailyStopMoney), 2));
   }
}

//+------------------------------------------------------------------+
//| Nova vela / ambiente                                             |
//+------------------------------------------------------------------+
void NewBarCheck()
{
   datetime t = iTime(_Symbol, PERIOD_M1, 0);
   if(t == 0 || t == g_bar_time) return;
   if(g_bar_time != 0)
   {
      MqlRates r[];
      if(CopyRates(_Symbol, PERIOD_M1, 1, 1, r) == 1) LogBar(r[0]);
   }
   g_bar_time = t;
   g_trades_candle = 0;
   TrendUpdate();
   LogEvent("INFO", "NEW_BAR", "M1 " + TimeToString(t, TIME_DATE | TIME_SECONDS) +
            " trend=" + I(g_trend_dir) + " er=" + D(g_trend_er, 2));
}

void WatchEnv()
{
   string sig = StringFormat("%d%d%d%d", (int)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED), (int)MQLInfoInteger(MQL_TRADE_ALLOWED),
                             (int)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED), (int)TerminalInfoInteger(TERMINAL_CONNECTED));
   if(sig != g_env_sig)
   {
      if(g_env_sig != "")
         LogEvent("WARN", "ENV_CHANGE", "algo_terminal/algo_ea/conta/conectado: " + g_env_sig + " -> " + sig);
      g_env_sig = sig;
   }
}

void RotateDayIfNeeded()
{
   if(!InpEnableTelemetry) return;
   MqlDateTime d;
   TimeToStruct(TimeTradeServer(), d);
   string day = StringFormat("%04d%02d%02d", d.year, d.mon, d.day);
   if(day == g_day_tag) return;
   LogEvent("INFO", "TELEMETRY_ROTATE_DAY", "Novo dia " + day + ". Pasta anterior preservada: " + g_dir);
   TelClose();
   TelOpen();
   LogEvent("INFO", "TELEMETRY_ROTATED", "Nova pasta: " + g_dir);
}

//+------------------------------------------------------------------+
//| Tema do grafico (com backup/restauracao)                         |
//+------------------------------------------------------------------+
int g_theme_props[] = { CHART_COLOR_BACKGROUND, CHART_COLOR_FOREGROUND, CHART_COLOR_GRID, CHART_COLOR_CHART_UP,
                        CHART_COLOR_CHART_DOWN, CHART_COLOR_CHART_LINE, CHART_COLOR_CANDLE_BULL, CHART_COLOR_CANDLE_BEAR,
                        CHART_COLOR_BID, CHART_COLOR_ASK, CHART_SHOW_GRID };

void ThemeApply()
{
   long vals[11];
   vals[0]  = C'5,8,16';    vals[1]  = C'150,170,200'; vals[2]  = C'16,24,40';
   vals[3]  = C'0,229,170'; vals[4]  = C'255,59,107';  vals[5]  = C'0,229,255';
   vals[6]  = C'0,229,170'; vals[7]  = C'255,59,107';  vals[8]  = C'0,229,255';
   vals[9]  = C'255,184,0'; vals[10] = 0;
   for(int i = 0; i < 11; i++)
   {
      string key = "MMX_BK_" + IntegerToString(ChartID()) + "_" + IntegerToString(i);
      if(!GlobalVariableCheck(key)) GlobalVariableSet(key, (double)ChartGetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)g_theme_props[i]));
      ChartSetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)g_theme_props[i], vals[i]);
   }
}

void ThemeRestore()
{
   for(int i = 0; i < 11; i++)
   {
      string key = "MMX_BK_" + IntegerToString(ChartID()) + "_" + IntegerToString(i);
      if(GlobalVariableCheck(key))
      {
         ChartSetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)g_theme_props[i], (long)GlobalVariableGet(key));
         GlobalVariableDel(key);
      }
   }
}

//+------------------------------------------------------------------+
//| PAINEL HUD                                                       |
//+------------------------------------------------------------------+
void UiReg(const string n, const bool detail)
{
   int k = ArraySize(g_ui_all);
   ArrayResize(g_ui_all, k + 1);
   g_ui_all[k] = n;
   if(detail)
   {
      k = ArraySize(g_ui_det);
      ArrayResize(g_ui_det, k + 1);
      g_ui_det[k] = n;
   }
}

void UiRect(const string n, const int x, const int y, const int w, const int h, const color bg, const color border, const bool detail = true)
{
   ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, InpPanelX + x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, InpPanelY + y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, n, OBJPROP_COLOR, border);
   ObjectSetInteger(0, n, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   UiReg(n, detail);
}

void UiLabel(const string n, const int x, const int y, const string t, const color c, const int fs,
             const string font = "Consolas", const ENUM_ANCHOR_POINT anc = ANCHOR_LEFT_UPPER, const bool detail = true)
{
   ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_ANCHOR, anc);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, InpPanelX + x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, InpPanelY + y);
   ObjectSetString(0, n, OBJPROP_TEXT, t);
   ObjectSetString(0, n, OBJPROP_FONT, font);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   UiReg(n, detail);
}

void UiButton(const string n, const int x, const int y, const int w, const int h, const string t, const color fg, const color border)
{
   ObjectCreate(0, n, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, InpPanelX + x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, InpPanelY + y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetString(0, n, OBJPROP_TEXT, t);
   ObjectSetString(0, n, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, n, OBJPROP_COLOR, fg);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, C_PANEL);
   ObjectSetInteger(0, n, OBJPROP_BORDER_COLOR, border);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, n, OBJPROP_ZORDER, 10);
   UiReg(n, false);
}

void UiText(const string n, const string t, const color c = clrNONE)
{
   if(ObjectGetString(0, n, OBJPROP_TEXT) != t) ObjectSetString(0, n, OBJPROP_TEXT, t);
   if(c != clrNONE && (color)ObjectGetInteger(0, n, OBJPROP_COLOR) != c) ObjectSetInteger(0, n, OBJPROP_COLOR, c);
}

void UiBar(const string n, const double frac, const color c, const int maxw)
{
   int w = (int)MathRound(MathMax(0.0, MathMin(1.0, frac)) * maxw);
   if(w < 1) w = 1;
   if((int)ObjectGetInteger(0, n, OBJPROP_XSIZE) != w) ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   if((color)ObjectGetInteger(0, n, OBJPROP_BGCOLOR) != c)
   {
      ObjectSetInteger(0, n, OBJPROP_BGCOLOR, c);
      ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   }
}

void UiDivider(const string n, const int y)
{
   UiRect(n, 10, y, g_pw - 20, 1, C_LINE, C_LINE);
}

void UiRow(const string key, const int y, const string label)
{
   UiLabel("MMX_L_" + key, 14, y, label, C_DIM, 9);
   UiLabel("MMX_V_" + key, 88, y, "-", C_TXT, 9);
}

void UiBarRow(const string key, const int y, const string label)
{
   UiRow(key, y, label);
   UiRect("MMX_T_" + key, 226, y + 5, g_pw - 240, 6, C_PANEL, C_LINE);
   UiRect("MMX_F_" + key, 226, y + 5, 1, 6, C_CYAN, C_CYAN);
}

void PanelBuild()
{
   ArrayResize(g_ui_all, 0);
   ArrayResize(g_ui_det, 0);
   int H = 512;

   UiRect("MMX_BG", 0, 0, g_pw, H, C_BG, C_CYAN, false);
   UiRect("MMX_ACC", 0, 0, g_pw, 3, C_CYAN, C_CYAN, false);
   UiLabel("MMX_TITLE", 14, 10, "◢ MICRO MOMENTUM", C_CYAN, 13, "Segoe UI Semibold", ANCHOR_LEFT_UPPER, false);
   UiLabel("MMX_VER", g_pw - 14, 14, "v" + EA_VERSION, C_DIM, 9, "Consolas", ANCHOR_RIGHT_UPPER, false);
   UiLabel("MMX_SUB", 14, 36, _Symbol + " · " + EnumToString((ENUM_TIMEFRAMES)_Period) + " · #" + IntegerToString((long)InpMagicNumber), C_DIM, 9, "Consolas", ANCHOR_LEFT_UPPER, false);
   UiLabel("MMX_STATUS", g_pw - 14, 36, "● INICIANDO", C_AMBER, 9, "Consolas", ANCHOR_RIGHT_UPPER, false);

   UiDivider("MMX_D1", 56);
   UiLabel("MMX_S1", 14, 62, "▍MOTOR", C_CYAN, 8);
   UiRow("ST", 80, "ESTADO");
   UiLabel("MMX_V_WHY", g_pw - 14, 82, "", C_DIM, 8, "Consolas", ANCHOR_RIGHT_UPPER);
   UiBarRow("SP", 100, "SPREAD");
   UiBarRow("UP", 120, "▲ ALTA");
   UiBarRow("DN", 140, "▼ QUEDA");
   UiRow("TK", 160, "TICKS");
   UiDivider("MMX_D2", 182);

   UiLabel("MMX_S2", 14, 188, "▍POSIÇÃO", C_CYAN, 8);
   UiLabel("MMX_P1", 14, 206, "-", C_TXT, 9);
   UiLabel("MMX_P2", 14, 226, "-", C_TXT, 9);
   UiLabel("MMX_P3", 14, 246, "-", C_DIM, 8);
   UiDivider("MMX_D3", 268);

   UiLabel("MMX_S3", 14, 274, "▍SESSÃO & RISCO  ·  LUCRO DO DIA LÍQUIDO (FECHADO)", C_CYAN, 8);
   UiLabel("MMX_PL", 14, 292, "$ 0.00", C_TXT, 16, "Segoe UI Semibold");
   UiLabel("MMX_LIM", g_pw - 14, 298, "", C_DIM, 8, "Consolas", ANCHOR_RIGHT_UPPER);
   UiRect("MMX_RT", 14, 324, g_pw - 28, 8, C_PANEL, C_LINE);
   UiRect("MMX_RF", g_pw / 2, 324, 1, 8, C_GREEN, C_GREEN);
   UiRect("MMX_RC", g_pw / 2 - 1, 321, 2, 14, C_DIM, C_DIM);
   UiLabel("MMX_R1", 14, 340, "-", C_TXT, 9);
   UiLabel("MMX_R2", 14, 360, "-", C_DIM, 8);
   UiDivider("MMX_D4", 382);

   UiLabel("MMX_S4", 14, 388, "▍TELEMETRIA", C_CYAN, 8);
   UiLabel("MMX_E1", 14, 406, "-", C_TXT, 9);
   UiLabel("MMX_E2", 14, 426, "-", C_DIM, 8);
   UiLabel("MMX_E3", 14, 444, "-", C_DIM, 8);
   UiDivider("MMX_D5", 466);

   UiButton("MMX_BTN_PAUSE", 14, 476, 110, 26, "▮▮ PAUSAR", C_AMBER, C_AMBER);
   UiButton("MMX_BTN_CLOSE", 132, 476, 130, 26, "✕ FECHAR TUDO", C_RED, C_RED);
   UiButton("MMX_BTN_MIN", 270, 476, 92, 26, "▾ MINIMIZAR", C_CYAN, C_CYAN);
}

void PanelLayout()
{
   // minimizado: apenas cabecalho + botoes
   for(int i = 0; i < ArraySize(g_ui_det); i++)
      ObjectSetInteger(0, g_ui_det[i], OBJPROP_TIMEFRAMES, g_minimized ? OBJ_NO_PERIODS : OBJ_ALL_PERIODS);

   int by = g_minimized ? 60 : 476;
   ObjectSetInteger(0, "MMX_BTN_PAUSE", OBJPROP_YDISTANCE, InpPanelY + by);
   ObjectSetInteger(0, "MMX_BTN_CLOSE", OBJPROP_YDISTANCE, InpPanelY + by);
   ObjectSetInteger(0, "MMX_BTN_MIN", OBJPROP_YDISTANCE, InpPanelY + by);
   ObjectSetInteger(0, "MMX_BG", OBJPROP_YSIZE, g_minimized ? 96 : 512);
   UiText("MMX_BTN_MIN", g_minimized ? "▴ EXPANDIR" : "▾ MINIMIZAR");
}

void PanelDelete()
{
   for(int i = 0; i < ArraySize(g_ui_all); i++) ObjectDelete(0, g_ui_all[i]);
}

color StateColor(const ENUM_EA_STATE s)
{
   switch(s)
   {
      case ST_SCANNING:      return C_GREEN;
      case ST_IN_POSITION:   return C_CYAN;
      case ST_COOLDOWN:      return C_AMBER;
      case ST_BLOCK_CANDLE:  return C_AMBER;
      case ST_BLOCK_SPREAD:  return C_AMBER;
      case ST_PAUSED:        return C_MAG;
      case ST_INIT:          return C_DIM;
   }
   return C_RED;
}

string Clip(const string s, const int n)
{
   if(StringLen(s) <= n) return s;
   return StringSubstr(s, 0, n - 1) + "…";
}

void PanelUpdate()
{
   if(!InpShowPanel) return;

   //--- status pill
   string pill; color pc;
   if(g_paused)                                   { pill = "■ PAUSADO";    pc = C_MAG; }
   else if(g_state == ST_BLOCK_TRADING)           { pill = "✖ SEM PERMISSÃO"; pc = C_RED; }
   else if(g_state >= ST_BLOCK_GOAL && g_state <= ST_BLOCK_SESSION) { pill = "✖ BLOQUEADO"; pc = C_RED; }
   else if(g_own_count > 0)                       { pill = "◆ EM POSIÇÃO"; pc = C_CYAN; }
   else                                           { pill = "● OPERANDO";   pc = C_GREEN; }
   UiText("MMX_STATUS", pill, pc);
   UiText("MMX_BTN_PAUSE", g_paused ? "▶ RETOMAR" : "▮▮ PAUSAR", g_paused ? C_GREEN : C_AMBER);

   if(!g_minimized)
   {
      //--- motor
      UiText("MMX_V_ST", StateName(g_state), StateColor(g_state));
      UiText("MMX_V_WHY", Clip(g_reason, 30), C_DIM);

      double sp_frac = (InpMaxSpreadPoints > 0) ? g_spread / InpMaxSpreadPoints : 0;
      UiText("MMX_V_SP", D(g_spread, 0) + " / " + I(InpMaxSpreadPoints), sp_frac > 1.0 ? C_RED : C_TXT);
      UiBar("MMX_F_SP", sp_frac, sp_frac > 1.0 ? C_RED : (sp_frac > 0.7 ? C_AMBER : C_GREEN), g_pw - 240);

      double thr = MathMax(1, InpMinPointsDisplacement);
      bool sb = (g_sig.dir > 0), ss = (g_sig.dir < 0);
      UiText("MMX_V_UP", D(g_sig.up, 0) + " / " + D(thr, 0), sb ? C_GREEN : C_TXT);
      UiBar("MMX_F_UP", g_sig.up / thr, sb ? C_GREEN : C_CYAN, g_pw - 240);
      UiText("MMX_V_DN", D(g_sig.dn, 0) + " / " + D(thr, 0), ss ? C_RED : C_TXT);
      UiBar("MMX_F_DN", g_sig.dn / thr, ss ? C_RED : C_MAG, g_pw - 240);
      string tr = (g_trend_dir > 0) ? "▲" : (g_trend_dir < 0 ? "▼" : "—");
      UiText("MMX_V_TK", I(g_sig.n) + " tk · " + D(g_tick_rate, 0) + " t/s · TR " + tr + " " + D(g_trend_er, 2) + " · " + Clip(g_sig.note, 14), C_TXT);

      //--- posicao
      double vol = NormVol(InpLotSize);
      if(g_own_count == 0)
      {
         UiText("MMX_P1", "SEM POSIÇÃO ABERTA", C_DIM);
         UiText("MMX_P2", "Aguardando impulso de " + I(InpMinPointsDisplacement) + " pts em " + I(InpMaxMilliseconds) + " ms", C_DIM);
      }
      else
      {
         int k = 0;
         for(int i = 1; i < ArraySize(g_pos); i++) if(MathAbs(g_pos[i].net) > MathAbs(g_pos[k].net)) k = i;
         bool buy = (g_pos[k].type == POSITION_TYPE_BUY);
         string extra = (g_own_count > 1) ? "  (+" + I(g_own_count - 1) + ")" : "";
         UiText("MMX_P1", (buy ? "▲ BUY " : "▼ SELL ") + D(g_pos[k].volume, 2) + " @ " + D(g_pos[k].open_price, _Digits) +
                (g_pos[k].ct ? "  [CT]" : "") + extra, buy ? C_GREEN : C_RED);
         double pk = (g_pos[k].peak_net == -DBL_MAX) ? 0 : g_pos[k].peak_net;
         double trn = (g_pos[k].trough_net == DBL_MAX) ? 0 : g_pos[k].trough_net;
         UiText("MMX_P2", "P/L " + Sg(g_pos[k].net) + " · " + D(g_pos[k].pts, 0) + " pts · MFE " + Sg(pk) + " · MAE " + Sg(trn),
                g_pos[k].net >= 0 ? C_GREEN : C_RED);
      }
      UiText("MMX_P3", "TP " + ExitDesc(InpTPMode, InpTPPoints, InpTPMoney, vol) + "  ·  SL " +
             ExitDesc(InpSLMode, InpSLPoints, InpSLMoney, vol) + "  ·  RECOIL " + (InpRecoilEnable ? I(InpRecoilPoints) : "OFF") +
             "  ·  ESC " + (InpEscapeSec > 0 ? I(InpEscapeSec) + "s" : "OFF"), C_DIM);

      //--- sessao: lucro do dia LIQUIDO e FECHADO (fixo). A meta/stop continuam usando g_daily_pl (com flutuante)
      double dpl = g_daily_real;
      UiText("MMX_PL", "$ " + Sg(dpl), dpl >= 0 ? C_GREEN : C_RED);
      string lim = "META " + (InpDailyGoalEnable ? "+" + D(InpDailyGoalMoney, 2) : "OFF") + "  STOP " +
                   (InpDailyStopEnable ? "-" + D(MathAbs(InpDailyStopMoney), 2) : "OFF");
      UiText("MMX_LIM", lim, C_DIM);

      double goal = (InpDailyGoalEnable && InpDailyGoalMoney > 0) ? InpDailyGoalMoney : 10.0;
      double stp  = (InpDailyStopEnable && MathAbs(InpDailyStopMoney) > 0) ? MathAbs(InpDailyStopMoney) : 10.0;
      int half = (g_pw - 28) / 2;
      int cx = InpPanelX + 14 + half;
      if(dpl >= 0)
      {
         int w = (int)MathMax(1, MathMin(1.0, dpl / goal) * half);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_XDISTANCE, cx);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_XSIZE, w);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_BGCOLOR, C_GREEN);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_COLOR, C_GREEN);
      }
      else
      {
         int w = (int)MathMax(1, MathMin(1.0, -dpl / stp) * half);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_XDISTANCE, cx - w);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_XSIZE, w);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_BGCOLOR, C_RED);
         ObjectSetInteger(0, "MMX_RF", OBJPROP_COLOR, C_RED);
      }

      double pf = (g_d_gl > 0) ? g_d_gp / g_d_gl : (g_d_gp > 0 ? 99.0 : 0.0);
      double hit = (g_d_n > 0) ? 100.0 * g_d_w / g_d_n : 0.0;
      UiText("MMX_R1", "TRADES " + I(g_d_n) + " · W " + I(g_d_w) + " · L " + I(g_d_l) + " · HIT " + D(hit, 0) + "% · PF " + D(pf, 2), C_TXT);
      UiText("MMX_R2", "SEQ.PERDAS " + I(g_consec_losses) + (InpMaxConsecLosses > 0 ? "/" + I(InpMaxConsecLosses) : "") +
             " · VELA " + I(g_trades_candle) + "/" + I(InpMaxTradesPerCandle) + " · ABERTAS " + I(g_own_count) + "/" + I(InpMaxOpenPositions) +
             " · PING " + D(TerminalInfoInteger(TERMINAL_PING_LAST) / 1000.0, 0) + "ms", C_DIM);

      //--- telemetria
      if(InpEnableTelemetry)
         UiText("MMX_E1", "● REC  " + I(TelRows()) + " linhas · " + D(TelBytes() / 1048576.0, 2) + " MB · 11 arquivos", C_GREEN);
      else
         UiText("MMX_E1", "○ TELEMETRIA DESLIGADA", C_AMBER);
      UiText("MMX_E2", "› " + Clip(g_last_event + " · " + g_last_event_msg, 52), C_DIM);
      string path = InpEnableTelemetry ? g_dir : "-";
      if(StringLen(path) > 50) path = "…" + StringSubstr(path, StringLen(path) - 49);
      UiText("MMX_E3", path, C_DIM);
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Manutencao periodica                                             |
//+------------------------------------------------------------------+
void Housekeeping()
{
   ulong now = GetTickCount64();

   if(now - g_t_rate >= 1000)
   {
      double dt = (double)(now - g_t_rate) / 1000.0;
      g_tick_rate = (double)(g_tick_count - g_tc_prev) / dt;
      g_tc_prev = g_tick_count;
      g_t_rate = now;
   }
   if(now - g_t_trend >= 250) { g_t_trend = now; TrendUpdate(); }
   if(now - g_t_panel >= 200) { g_t_panel = now; PanelUpdate(); }
   if(now - g_t_flush >= (ulong)MathMax(50, InpFlushMs)) { g_t_flush = now; if(InpEnableTelemetry) TelFlush(); }
   if(now - g_t_acct >= 1000)
   {
      g_t_acct = now;
      WatchEnv();
      RotateDayIfNeeded();
      LogAccount();
   }
}

//+------------------------------------------------------------------+
//| Init / Deinit                                                    |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
   string err = "";
   if(InpLotSize <= 0)                 err = "Volume invalido";
   if(InpMinPointsDisplacement <= 0)   err = "Impulso minimo deve ser > 0";
   if(InpMaxMilliseconds <= 0)         err = "Janela deve ser > 0 ms";
   if(InpMaxOpenPositions < 1)         err = "Max. posicoes deve ser >= 1";
   if(InpMaxPullbackPct < 0)           err = "Pullback nao pode ser negativo";
   if(InpCTImpulseMult < 1.0)          err = "Multiplicador contra-tendencia deve ser >= 1";
   if(InpMaxImpulsePts < 0 || (InpMaxImpulsePts > 0 && InpMaxImpulsePts < InpMinPointsDisplacement))
                                       err = "Teto de impulso deve ser 0 (off) ou >= impulso minimo";
   if(InpStackGateMoney < 0 || InpStackMinGapMs < 0) err = "Porteira de empilhamento nao pode ser negativa";
   if(InpPullbackPct <= 0 || InpPullbackPct >= 100 || InpPullbackInvalidPct <= InpPullbackPct || InpPullbackInvalidPct > 100)
                                       err = "Pullback: 0 < pct < invalido <= 100";
   if(InpPullbackWaitMs <= 0)          err = "Pullback: espera deve ser > 0 ms";
   if(InpSlipHighPts < 0 || InpSlipEscapeSec < 0) err = "Anti-slippage nao pode ser negativo";
   if(!ParseWindows())                 err = "InpBlockWindows invalido (use HH:MM-HH:MM;HH:MM-HH:MM)";
   if(InpPendLimitPct <= 0 || InpPendLimitPct >= 100 || InpPendMinOffsetPts < 0 || InpPendStopPts <= 0)
                                       err = "Pendente: pct em (0,100), recuo minimo >= 0, distancia stop > 0";
   if(InpPendTtlMs <= 0 || InpPendCancelPts <= 0 || InpPendRearmMs < 0) err = "Pendente: TTL e cancelamento devem ser > 0";
   if(err != "") { Print("[MMX] INPUT INVALIDO: ", err); return false; }
   return true;
}

void LogInit()
{
   LogParam("ea", "MicroMomentum v" + EA_VERSION);
   LogParam("terminal_build", I(TerminalInfoInteger(TERMINAL_BUILD)));
   LogParam("account_login", I(AccountInfoInteger(ACCOUNT_LOGIN)));
   LogParam("account_server", AccountInfoString(ACCOUNT_SERVER));
   LogParam("account_currency", AccountInfoString(ACCOUNT_CURRENCY));
   LogParam("account_leverage", I(AccountInfoInteger(ACCOUNT_LEVERAGE)));
   LogParam("account_margin_mode", I(AccountInfoInteger(ACCOUNT_MARGIN_MODE)) + " (0=netting,2=hedging)");
   LogParam("symbol", _Symbol);
   LogParam("period", EnumToString((ENUM_TIMEFRAMES)_Period));
   LogParam("digits", I(_Digits));
   LogParam("point", DoubleToString(_Point, 8));
   LogParam("contract_size", D(SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE), 2));
   LogParam("tick_size", DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), 8));
   LogParam("tick_value", DoubleToString(TickValue(), 8));
   LogParam("volume_min", D(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), 4));
   LogParam("volume_max", D(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX), 2));
   LogParam("volume_step", D(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP), 4));
   LogParam("stops_level_pts", I(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)));
   LogParam("freeze_level_pts", I(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL)));
   LogParam("filling_mode_flags", I(SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE)));
   LogParam("trade_mode", I(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)));
   LogParam("spread_now_pts", I(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD)));

   double vol = NormVol(InpLotSize);
   LogParam("lot_effective", D(vol, 2));
   LogParam("tp_effective", ExitDesc(InpTPMode, InpTPPoints, InpTPMoney, vol));
   LogParam("sl_effective", ExitDesc(InpSLMode, InpSLPoints, InpSLMoney, vol));

   LogParam("InpDirMode", EnumToString(InpDirMode));
   LogParam("InpMinPointsDisplacement", I(InpMinPointsDisplacement));
   LogParam("InpMaxMilliseconds", I(InpMaxMilliseconds));
   LogParam("InpMinTicksInWindow", I(InpMinTicksInWindow));
   LogParam("InpMaxPullbackPct", D(InpMaxPullbackPct, 1));
   LogParam("InpMinDispToSpread", D(InpMinDispToSpread, 2));
   LogParam("InpCooldownMs", I(InpCooldownMs));
   LogParam("InpMaxTradesPerCandle", I(InpMaxTradesPerCandle));
   LogParam("InpMaxOpenPositions", I(InpMaxOpenPositions));
   LogParam("InpAllowHedge", (string)InpAllowHedge);
   LogParam("InpTPMode", EnumToString(InpTPMode));
   LogParam("InpTPMoney", D(InpTPMoney, 2));
   LogParam("InpTPPoints", I(InpTPPoints));
   LogParam("InpSLMode", EnumToString(InpSLMode));
   LogParam("InpSLMoney", D(InpSLMoney, 2));
   LogParam("InpSLPoints", I(InpSLPoints));
   LogParam("InpServerSideStops", (string)InpServerSideStops);
   LogParam("InpRecoilEnable", (string)InpRecoilEnable);
   LogParam("InpRecoilPoints", I(InpRecoilPoints));
   LogParam("InpRecoilMinProfit", D(InpRecoilMinProfit, 2));
   LogParam("InpMaxHoldSec", I(InpMaxHoldSec));
   LogParam("InpEscapeSec", I(InpEscapeSec));
   LogParam("InpCTEscapeSec", I(InpCTEscapeSec));
   LogParam("InpEscapeArmMoney", D(InpEscapeArmMoney, 2));
   LogParam("InpEscapeMinMoney", D(InpEscapeMinMoney, 2));
   LogParam("InpTrendEnable", (string)InpTrendEnable);
   LogParam("InpTrendBars", I(InpTrendBars));
   LogParam("InpTrendMinER", D(InpTrendMinER, 2));
   LogParam("InpCTImpulseMult", D(InpCTImpulseMult, 2));
   LogParam("InpMaxSpreadPoints", I(InpMaxSpreadPoints));
   LogParam("InpDailyGoalEnable", (string)InpDailyGoalEnable);
   LogParam("InpDailyGoalMoney", D(InpDailyGoalMoney, 2));
   LogParam("InpDailyStopEnable", (string)InpDailyStopEnable);
   LogParam("InpDailyStopMoney", D(InpDailyStopMoney, 2));
   LogParam("InpCloseOnDailyLimit", (string)InpCloseOnDailyLimit);
   LogParam("InpMaxConsecLosses", I(InpMaxConsecLosses));
   LogParam("InpPauseMinutes", I(InpPauseMinutes));
   LogParam("InpSessionEnable", (string)InpSessionEnable);
   LogParam("InpSessionHours", I(InpSessionStartHour) + "-" + I(InpSessionEndHour));
   LogParam("InpDeviationPoints", I(InpDeviationPoints));
   LogParam("InpRetries", I(InpRetries));
   LogParam("InpMaxImpulsePts", I(InpMaxImpulsePts));
   LogParam("InpBlockWindows", InpBlockWindows);
   LogParam("InpStackGateMoney", D(InpStackGateMoney, 2));
   LogParam("InpStackMinGapMs", I(InpStackMinGapMs));
   LogParam("InpPullbackEntry", (string)InpPullbackEntry);
   LogParam("InpPullbackPct", D(InpPullbackPct, 1));
   LogParam("InpPullbackInvalidPct", D(InpPullbackInvalidPct, 1));
   LogParam("InpPullbackWaitMs", I(InpPullbackWaitMs));
   LogParam("InpSlipHighPts", I(InpSlipHighPts));
   LogParam("InpSlipEscapeSec", I(InpSlipEscapeSec));
   LogParam("InpPendEnable", (string)InpPendEnable);
   LogParam("InpPendMode", EnumToString(InpPendMode));
   LogParam("InpPendLimitPct", D(InpPendLimitPct, 1));
   LogParam("InpPendMinOffsetPts", I(InpPendMinOffsetPts));
   LogParam("InpPendStopPts", I(InpPendStopPts));
   LogParam("InpPendTtlMs", I(InpPendTtlMs));
   LogParam("InpPendCancelPts", I(InpPendCancelPts));
   LogParam("InpPendRearmMs", I(InpPendRearmMs));
   LogParam("InpPendSafetyExpirySec", I(InpPendSafetyExpirySec));
   if(InpPendEnable && InpPullbackEntry) LogEvent("WARN", "PULLBACK_IGNORADO", "InpPullbackEntry ignorado: a ordem pendente tem prioridade");
   LogParam("expiration_mode_flags", I(SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_MODE)));
   LogParam("trade_exemode", I(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_EXEMODE)));
   LogParam("InpMagicNumber", I((long)InpMagicNumber));
   LogParam("InpLogEveryTick", (string)InpLogEveryTick);
   LogParam("InpMaxFileMB", I(InpMaxFileMB));
   LogParam("telemetry_dir", g_dir);
}

int OnInit()
{
   if(!ValidateInputs()) return INIT_PARAMETERS_INCORRECT;

   g_point = _Point;
   if(g_point <= 0) return INIT_FAILED;
   SymbolSelect(_Symbol, true);

   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetDeviationInPoints(InpDeviationPoints);
   m_trade.SetTypeFillingBySymbol(_Symbol);
   m_trade.SetMarginMode();
   m_trade.SetAsyncMode(false);
   m_trade.LogLevel(LOG_LEVEL_ERRORS);

   ArrayResize(g_pos, 0);
   g_head = -1; g_count = 0;
   g_sig.dir = 0; g_sig.up = 0; g_sig.dn = 0; g_sig.n = 0; g_sig.span = 0; g_sig.note = "init";
   ZeroMemory(g_tick);
   ZeroMemory(g_prev_tick);
   SymbolInfoTick(_Symbol, g_tick);
   g_spread = (g_tick.ask - g_tick.bid) / g_point;

   MqlDateTime l;
   TimeToStruct(TimeLocal(), l);
   g_session = StringFormat("S%02d%02d%02d", l.hour, l.min, l.sec);

   if(InpEnableTelemetry) TelOpen();

   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);
   if(InpApplyTheme) ThemeApply();

   LogEvent("INFO", "EA_STARTED", "MicroMomentum v" + EA_VERSION + " iniciado em " + _Symbol);
   LogInit();

   string pw;
   if(!TradingAllowed(pw)) LogEvent("WARN", "TRADING_NOT_ALLOWED", pw + " -> NENHUMA ORDEM SERA ENVIADA ate corrigir");

   g_t_panel = g_t_flush = g_t_acct = g_t_daily = g_t_rate = GetTickCount64();
   g_env_sig = "";
   WatchEnv();
   TrendUpdate();
   DailyRefresh(true);
   SyncPositions();
   if(InpPendEnable) PendCleanup("inicio");

   if(InpShowPanel) { PanelBuild(); PanelLayout(); }
   PanelUpdate();

   EventSetMillisecondTimer(100);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   if(InpPendEnable) PendCleanup("fim");
   LogEvent("INFO", "EA_STOPPED", ReasonText(reason) + " | ticks=" + I((long)g_tick_count) + " | posicoes abertas=" + I(g_own_count));
   if(InpEnableTelemetry) TelClose();
   PanelDelete();
   if(InpApplyTheme && (reason == REASON_REMOVE || reason == REASON_PROGRAM || reason == REASON_CLOSE)) ThemeRestore();
   Comment("");
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void OnTick()
{
   g_prev_tick = g_tick;
   if(!SymbolInfoTick(_Symbol, g_tick))
   {
      LogEvent("ERROR", "TICK_FAIL", "SymbolInfoTick falhou err=" + I(GetLastError()));
      return;
   }
   if(g_tick.bid <= 0 || g_tick.ask <= 0) return;

   g_tick_count++;
   g_spread = (g_tick.ask - g_tick.bid) / g_point;
   BufPush(g_tick);

   NewBarCheck();
   SyncPositions();
   DailyRefresh(false);
   ManageExits();

   Analyze(g_sig);

   ENUM_EA_STATE ns = ComputeState(g_reason);
   if(ns != g_state)
   {
      LogEvent("INFO", "STATE_CHANGE", StateName(g_state) + " -> " + StateName(ns) + " | " + g_reason);
      g_state = ns;
   }

   EntryFlow();

   LogTick(g_sig);
   Housekeeping();
}

void OnTimer()
{
   Housekeeping();
}

//+------------------------------------------------------------------+
//| Transacoes de trade                                              |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
   if(!InpEnableTelemetry) return;
   if(trans.symbol != "" && trans.symbol != _Symbol) return;

   bool mine = (trans.position > 0 && FindPos(trans.position) >= 0);
   if(trans.type == TRADE_TRANSACTION_REQUEST && request.magic == InpMagicNumber) mine = true;

   c_trans.Write(Pfx() + "," + (mine ? "1" : "0") + "," + EnumToString(trans.type) + "," + I((long)trans.order) + "," +
                 I((long)trans.deal) + "," + I((long)trans.position) + "," + trans.symbol + "," +
                 EnumToString(trans.order_type) + "," + EnumToString(trans.order_state) + "," + EnumToString(trans.deal_type) + "," +
                 D(trans.price, _Digits) + "," + D(trans.price_sl, _Digits) + "," + D(trans.price_tp, _Digits) + "," +
                 D(trans.volume, 2) + "," + I((long)result.retcode) + "," + Q(result.comment));
}

//+------------------------------------------------------------------+
//| Eventos do grafico e botoes                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(InpEnableTelemetry)
   {
      string geo = ",,,,,,";
      if(id == CHARTEVENT_CHART_CHANGE)
      {
         geo = I(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS)) + "," + I(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) + "," +
               I(ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR)) + "," + I(ChartGetInteger(0, CHART_VISIBLE_BARS)) + "," +
               D(ChartGetDouble(0, CHART_PRICE_MIN), _Digits) + "," + D(ChartGetDouble(0, CHART_PRICE_MAX), _Digits) + "," +
               I(ChartGetInteger(0, CHART_SCALE));
      }
      c_chart.Write(Pfx() + "," + ChartEvName(id) + "," + I(lparam) + "," + D(dparam, 4) + "," + Q(sparam) + "," + geo);
   }

   if(id != CHARTEVENT_OBJECT_CLICK) return;

   if(sparam == "MMX_BTN_PAUSE")
   {
      g_paused = !g_paused;
      LogEvent("INFO", "PANEL_PAUSE", g_paused ? "EA pausado pelo painel" : "EA retomado pelo painel");
   }
   else if(sparam == "MMX_BTN_CLOSE")
   {
      g_close_all_req = true;
      LogEvent("WARN", "PANEL_CLOSE_ALL", "Fechar tudo solicitado pelo painel");
   }
   else if(sparam == "MMX_BTN_MIN")
   {
      g_minimized = !g_minimized;
      PanelLayout();
      LogEvent("INFO", "PANEL_MINIMIZE", g_minimized ? "Painel minimizado" : "Painel expandido");
   }
   else return;

   ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
   PanelUpdate();
}
//+------------------------------------------------------------------+