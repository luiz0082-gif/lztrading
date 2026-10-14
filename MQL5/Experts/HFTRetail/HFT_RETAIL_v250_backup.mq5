//+------------------------------------------------------------------+
//|                                             HFT_RETAIL.mq5       |
//|     HFT Retail v2.5 - correcoes de execucao, risco e telemetria  |
//| v2.5: TP/SL em dinheiro fecha de fato; kill switch vigia posicao |
//| aberta e fecha; sessao em GMT real; motivo de bloqueio visivel;  |
//| CSV schema v25 (hora do servidor, trades completos, sem spam).   |
//| Logica do sinal (ensemble) NAO foi alterada.                     |
//+------------------------------------------------------------------+
#property copyright "HFT Retail v2.5"
#property version   "2.50"
#define EA_VERSION  "v2.5"
#define CSV_SCHEMA  "v25"
#property strict

#include <Trade/Trade.mqh>

//==================================================================
// ENUMS
//==================================================================
enum ENUM_EA_STATE
{
   STATE_INIT, STATE_GATE, STATE_IDLE, STATE_ENTERING,
   STATE_IN_POSITION, STATE_EXITING, STATE_DAILY_TARGET_HIT,
   STATE_KILL_SWITCH, STATE_ERROR
};
enum ENUM_TREND { TREND_UP, TREND_DOWN, TREND_SIDE };
enum ENUM_SIG   { SIG_NONE, SIG_BUY, SIG_SELL };
enum ENUM_LOGFILE
{
   LF_EVENTS, LF_TICKS, LF_DECISIONS, LF_ORDERS, LF_FILLS,
   LF_PANEL,  LF_METRICS, LF_GATE, LF_DOM, LF_TRADES, LF_COUNT
};

//==================================================================
// INPUTS  (todos em português)
//==================================================================
input group "═══ Geral ═══"
input long   InpMagic               = 20260929;   // Número Mágico (ID único do EA)

input group "═══ Símbolos ═══"
input string InpSymbols             = "XAUUSD";   // Símbolos separados por ;

input group "═══ Validação Inicial (Gate) ═══"
input bool   InpUseGate             = true;       // Ativar amostragem inicial do símbolo
input bool   InpGateStrictMode      = false;      // Modo estrito: reprova símbolo e bloqueia
input int    InpGateSeconds         = 30;         // Duração da amostragem (segundos)
input double InpGateMaxAvgSpread    = 50.0;       // Spread médio máximo (pontos)
input int    InpGateMinTicks        = 10;         // Mínimo de ticks na amostragem

input group "═══ Sessão (hora GMT real, via TimeGMT) ═══"
input bool   InpTradeLondon         = true;       // Operar Londres (08-13 GMT)
input bool   InpTradeNY             = true;       // Operar Nova York (13-21 GMT)
input bool   InpTradeAsia           = false;      // Operar Ásia (01-08 GMT)
input bool   InpBlockRollover       = true;       // Bloquear rollover (22-01 GMT)

input group "═══ Estratégia / Ensemble ═══"
input double InpMinConfidence       = 0.50;       // Confiança mínima para entrar
input int    InpOFIWindow           = 20;         // Janela do OFI (ticks)
input double InpOFIThreshold        = 0.15;       // Limiar do OFI
input double InpW_OFI               = 0.45;       // Peso da estratégia OFI
input double InpW_MeanRev           = 0.25;       // Peso da Reversão à Média
input double InpW_Momentum          = 0.30;       // Peso do Momentum
input double InpMaxSpreadPoints     = 50.0;       // Spread máximo para operar (pontos)

input group "═══ DINHEIRO — Take Profit e Metas ═══"
input double InpTP_MoneyPerTrade    = 5.00;       // Take Profit por operação (moeda da conta)
input bool   InpTP_UsePointsInstead = false;      // Usar TP em pontos em vez de moeda da conta
input double InpTP_PointsPerTrade   = 0;          // TP em pontos (se acima)
input double InpDailyTargetMoney    = 50.00;      // Meta diária de lucro (moeda da conta)
input bool   InpBlockOnDailyTarget  = true;       // Bloquear entradas ao bater meta

input group "═══ RISCO (opcional) ═══"
input bool   InpUseStopLoss         = false;      // Ativar Stop Loss
input double InpSL_MoneyPerTrade    = 3.00;       // SL por operação (moeda da conta)
input bool   InpSL_UsePoints        = false;      // Usar SL em pontos em vez de moeda da conta
input double InpSL_PointsPerTrade   = 0;          // SL em pontos (se acima)
input bool   InpUseMaxDailyLoss     = false;      // Ativar limite de perda diária
input double InpMaxDailyLossMoney   = 30.00;      // Perda diária máxima (moeda da conta)
input bool   InpUseMaxTradesPerDay  = false;      // Ativar limite de operações/dia
input int    InpMaxTradesPerDay     = 100;        // Máximo de operações por dia
input bool   InpUseKillSwitch       = true;       // Ativar Kill Switch
input double InpKillSwitchDrawdownPct = 5.0;      // Drawdown para Kill Switch (%)
input bool   InpKillSwitchClosePos  = true;       // Kill Switch fecha as posições abertas

input group "═══ Execução ═══"
input double InpFixedLots           = 0.01;       // Lote fixo
input int    InpSlippagePoints      = 5;          // Slippage máximo (pontos)
input int    InpOrderRetryMax       = 2;          // Tentativas extras (só em requote/preço mudou)

input group "═══ Painel ═══"
input bool   InpShowPanel           = true;       // Exibir painel
input int    InpPanelX              = 12;         // Posição X (pixels)
input int    InpPanelY              = 22;         // Posição Y (pixels)
input int    InpPanelRefreshMs      = 250;        // Refresh do painel (ms)

input group "═══ Telemetria CSV ═══"
input bool   InpLogLocal            = true;       // Gravar em MQL5/Files (recomendado)
input bool   InpLogTicks            = false;      // Registrar cada tick (alto volume)
input bool   InpLogDOM              = false;      // Registrar o book (DOM) - volume alto, imbalance quase sempre 0 na IC
input int    InpFlushMs             = 500;        // Frequência de gravação dos CSVs (ms)
input int    InpSnapshotSec         = 5;          // Intervalo do panel_state/metrics (s); também grava ao mudar

//==================================================================
// PALETA
//==================================================================
#define CLR_BG        C'6,10,22'
#define CLR_BG2       C'10,16,32'
#define CLR_CARD      C'12,20,38'
#define CLR_BORDER    C'0,180,220'
#define CLR_ACCENT    C'0,229,255'
#define CLR_ACCENT_D  C'0,110,140'
#define CLR_PROFIT    C'0,255,150'
#define CLR_LOSS      C'255,70,100'
#define CLR_WARN      C'255,190,60'
#define CLR_GOLD      C'255,215,0'
#define CLR_TEXT      C'220,230,245'
#define CLR_TEXT_DIM  C'130,148,175'

//==================================================================
// UNICODE
//==================================================================
string U(const int code) { return ShortToString((ushort)code); }
string SYM_UP()      { return U(0x25B2); }
string SYM_DOWN()    { return U(0x25BC); }
string SYM_FLAT()    { return U(0x25CF); }
string SYM_BLOCK_F() { return U(0x2593); }
string SYM_BLOCK_E() { return U(0x2591); }
string SYM_CHECK()   { return U(0x2713); }
string SYM_CROSS()   { return U(0x2717); }

//==================================================================
// LOG HUB — gravação em tempo real
//==================================================================
class CLogHub
{
private:
   string m_name[LF_COUNT];
   string m_header[LF_COUNT];
   string m_buf[LF_COUNT];
   int    m_lines[LF_COUNT];
   string m_dir;
   ulong  m_last_flush_ms;
   int    m_flags;

public:
   void Init()
   {
      m_dir = "";
      m_last_flush_ms = 0;
      m_flags = InpLogLocal ? 0 : FILE_COMMON;
      for(int i = 0; i < LF_COUNT; i++) { m_buf[i] = ""; m_lines[i] = 0; }

      m_name[LF_EVENTS]    = "events.csv";
      m_name[LF_TICKS]     = "ticks.csv";
      m_name[LF_DECISIONS] = "decisions.csv";
      m_name[LF_ORDERS]    = "orders.csv";
      m_name[LF_FILLS]     = "fills.csv";
      m_name[LF_PANEL]     = "panel_state.csv";
      m_name[LF_METRICS]   = "metrics.csv";
      m_name[LF_GATE]      = "gate.csv";
      m_name[LF_DOM]       = "dom.csv";
      m_name[LF_TRADES]    = "trades.csv";

      m_header[LF_EVENTS]    = "ts_ms;event;from;to;reason";
      m_header[LF_TICKS]     = "ts_ms;symbol;bid;ask;spread_pt;ofi;trend;imb";
      m_header[LF_DECISIONS] = "ts_ms;symbol;side;conf;approved;reason";
      m_header[LF_ORDERS]    = "ts_ms;symbol;side;lots;price;sl;tp;attempt;retcode;ticket;comment";
      m_header[LF_FILLS]     = "ts_ms;symbol;ticket;side;lots;net_money;pts;daily_money;daily_pts";
      m_header[LF_PANEL]     = "ts_ms;state;symbols;wins;losses;hit;daily_money;weekly;monthly;annual;loss_total;trades";
      m_header[LF_METRICS]   = "ts_ms;wins;losses;total;hit;daily;weekly;monthly;annual;loss_total";
      m_header[LF_GATE]      = "ts_ms;symbol;passed;avg_spread;ticks";
      m_header[LF_DOM]       = "ts_ms;symbol;bid_vol;ask_vol;imbalance";
      m_header[LF_TRADES]    = "ts_ms;symbol;side;lots;entry_time;entry_price;exit_price;money;pts;win;duration_s;exit_reason";
   }

   // Toda linha ganha 'time_server' (hora do servidor) como 1a coluna.
   // Pasta com versao do schema: logs antigos (v2.4) ficam intactos em HFT_Logs\<data>.
   string DayDir() { return "HFT_Logs\\" + CSV_SCHEMA + "\\" + m_dir; }

   void RollIfNeeded()
   {
      MqlDateTime t; TimeToStruct(TimeCurrent(), t);
      string today = StringFormat("%04d-%02d-%02d", t.year, t.mon, t.day);
      if(m_dir == today) return;

      FlushAll();

      string subs[3];
      subs[0] = "HFT_Logs";
      subs[1] = "HFT_Logs\\" + CSV_SCHEMA;
      subs[2] = "HFT_Logs\\" + CSV_SCHEMA + "\\" + today;
      for(int k = 0; k < 3; k++)
      {
         ResetLastError();
         if(!FolderCreate(subs[k], m_flags) && GetLastError() != 5010)
            Print("[HFT] ERRO FolderCreate ", subs[k], " (err=", GetLastError(), ")");
      }

      m_dir = today;
   }

   void Append(ENUM_LOGFILE f, string line)
   {
      RollIfNeeded();
      m_buf[f] += TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + ";" + line + "\r\n";
      m_lines[f]++;
   }

   void FlushOne(ENUM_LOGFILE f)
   {
      if(m_lines[f] == 0 || m_dir == "") return;
      string path = DayDir() + "\\" + m_name[f];
      int flags = FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | m_flags |
                  FILE_SHARE_READ | FILE_SHARE_WRITE;
      int h = FileOpen(path, flags);
      if(h == INVALID_HANDLE)
      {
         Print("[HFT] ERRO FileOpen ", path, " (err=", GetLastError(), ")");
         return;
      }
      if(FileSize(h) == 0) FileWriteString(h, "time_server;" + m_header[f] + "\r\n");
      FileSeek(h, 0, SEEK_END);
      FileWriteString(h, m_buf[f]);
      FileClose(h);
      m_buf[f] = "";
      m_lines[f] = 0;
   }

   void FlushAll()
   {
      for(int i = 0; i < LF_COUNT; i++) FlushOne((ENUM_LOGFILE)i);
      m_last_flush_ms = GetTickCount64();
   }

   void MaybeFlush()
   {
      if(GetTickCount64() - m_last_flush_ms >= (ulong)InpFlushMs)
         FlushAll();
   }

   void ReportPath()
   {
      if(InpLogLocal)
         Print("[HFT] CSVs em: <terminal>\\MQL5\\Files\\HFT_Logs\\", CSV_SCHEMA, "\\<data>\\");
      else
         Print("[HFT] CSVs em: <AppData>\\MetaQuotes\\Terminal\\Common\\Files\\HFT_Logs\\", CSV_SCHEMA, "\\<data>\\");
   }
};

CLogHub g_log;

//==================================================================
// CONTEXTO POR SIMBOLO
//==================================================================
#define TICK_BUF 256

class CSymbolContext
{
public:
   string  sym;
   double  point, tick_value, tick_size;
   int     digits;
   double  prices[TICK_BUF];
   int     idx, count;
   double  ofi;
   ENUM_TREND trend;
   double  trend_strength;
   int     last_dir_streak;
   bool    dom_ok;
   double  dom_bid_vol, dom_ask_vol, dom_imb;
   ulong   ticket;
   double  entry_price;
   int     entry_type;
   double  tp_price, sl_price, tp_money, sl_money;
   double  pending_lots;
   datetime entry_time;
   string  exit_reason;
   ulong   close_req_ms;
   bool     gate_passed, gate_done;
   datetime gate_start;
   double   gate_spread_sum;
   int      gate_samples;
   double   gate_avg_spread;
   int     wins, losses;
   double  daily_money, daily_points;

   void Init(string s)
   {
      sym = s;
      point = SymbolInfoDouble(sym, SYMBOL_POINT);
      tick_value = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
      tick_size  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
      digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      idx = 0; count = 0;
      ofi = 0; trend = TREND_SIDE; trend_strength = 0; last_dir_streak = 0;
      dom_ok = false; dom_bid_vol = dom_ask_vol = dom_imb = 0;
      ticket = 0; entry_price = 0; entry_type = -1;
      tp_price = sl_price = tp_money = sl_money = 0;
      pending_lots = 0;
      entry_time = 0; exit_reason = ""; close_req_ms = 0;
      gate_passed = !InpUseGate;
      gate_done = !InpUseGate;
      gate_start = TimeCurrent();
      gate_spread_sum = 0; gate_samples = 0; gate_avg_spread = 0;
      wins = 0; losses = 0; daily_money = 0; daily_points = 0;
   }

   double MidPrice(int back = 0)
   {
      int i = (idx - 1 - back + TICK_BUF * 2) % TICK_BUF;
      return prices[i];
   }

   void PushMid(double mid)
   {
      prices[idx] = mid;
      idx = (idx + 1) % TICK_BUF;
      if(count < TICK_BUF) count++;
   }

   double MoneyPerPoint(double lots)
   {
      if(tick_size <= 0 || point <= 0 || tick_value <= 0) return 0;
      return tick_value * (point / tick_size) * lots;
   }
   double MoneyToPoints(double lots, double m) { double v = MoneyPerPoint(lots); return v > 0 ? m / v : 0; }
   double PointsToMoney(double lots, double p) { return MoneyPerPoint(lots) * p; }

   void UpdateFeatures()
   {
      MqlTick tk; if(!SymbolInfoTick(sym, tk)) return;
      double mid = (tk.bid + tk.ask) * 0.5;

      if(count > 0)
      {
         double prev = MidPrice(0);
         double n = (mid - prev) / (point * 2.0);
         if(n >  1) n =  1;
         if(n < -1) n = -1;
         ofi = ofi * 0.80 + n * 0.20;
         if(mid > prev)       last_dir_streak = (last_dir_streak > 0) ? last_dir_streak + 1 : 1;
         else if(mid < prev)  last_dir_streak = (last_dir_streak < 0) ? last_dir_streak - 1 : -1;
         else                 last_dir_streak = 0;
      }
      PushMid(mid);

      if(!gate_done)
      {
         double sp = (tk.ask - tk.bid) / point;
         gate_spread_sum += sp;
         gate_samples++;
         if(TimeCurrent() - gate_start >= InpGateSeconds)
         {
            gate_avg_spread = (gate_samples > 0) ? gate_spread_sum / gate_samples : 0;
            bool pass = (gate_samples >= InpGateMinTicks) &&
                        (gate_avg_spread <= InpGateMaxAvgSpread);
            // modo aviso: aceita mesmo se falhar, mas registra
            gate_passed = pass || !InpGateStrictMode;
            gate_done = true;
            g_log.Append(LF_GATE, StringFormat("%I64d;%s;%s;%.2f;%d",
               GetTickCount64(), sym,
               pass ? "PASS" : (InpGateStrictMode ? "FAIL" : "WARN"),
               gate_avg_spread, gate_samples));
            g_log.Append(LF_EVENTS, StringFormat("%I64d;GATE_DONE;-;%s;avg=%.2f ticks=%d pass=%s",
               GetTickCount64(), sym, gate_avg_spread, gate_samples,
               pass ? "sim" : "nao"));
         }
      }
   }

   void UpdateTrend()
   {
      int n = MathMin(count, 100);
      if(n < 10) { trend = TREND_SIDE; trend_strength = 0; return; }
      double sx=0, sy=0, sxy=0, sxx=0;
      for(int i = 0; i < n; i++)
      {
         double y = MidPrice(i);
         sx += i; sy += y; sxy += i * y; sxx += i * i;
      }
      double den = n * sxx - sx * sx;
      if(MathAbs(den) < 1e-12) { trend = TREND_SIDE; return; }
      double slope = (n * sxy - sx * sy) / den;
      double thr = point * 0.3;
      if(slope >  thr) { trend = TREND_UP;   trend_strength = MathMin(1.0,  slope / (point*2)); }
      else if(slope < -thr) { trend = TREND_DOWN; trend_strength = MathMin(1.0, -slope / (point*2)); }
      else { trend = TREND_SIDE; trend_strength = 0; }
   }

   double PositionPnLMoney()
   {
      if(ticket == 0 || !PositionSelectByTicket(ticket)) return 0;
      if(PositionGetString(POSITION_SYMBOL) != sym) return 0;
      return PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
};

//==================================================================
// ULTIMAS OPERACOES
//==================================================================
struct STradeRec
{
   datetime time;
   string   sym;
   string   side;
   double   money;
   double   points;
   bool     win;
};

STradeRec g_recent[6];
int       g_recent_n = 0;

void PushRecent(string sym, string side, double money, double pts, bool win)
{
   for(int i = MathMin(g_recent_n, 5); i > 0; i--) g_recent[i] = g_recent[i-1];
   g_recent[0].time = TimeCurrent();
   g_recent[0].sym = sym;
   g_recent[0].side = side;
   g_recent[0].money = money;
   g_recent[0].points = pts;
   g_recent[0].win = win;
   if(g_recent_n < 6) g_recent_n++;
}

//==================================================================
// GLOBAIS
//==================================================================
ENUM_EA_STATE   g_state = STATE_INIT;
CTrade          g_trade;
CSymbolContext  g_syms[];
int             g_nsym = 0;
string          g_primary = "";

double g_daily_money = 0, g_daily_points = 0;
double g_weekly_money = 0, g_monthly_money = 0, g_annual_money = 0, g_total_loss_money = 0;
int    g_wins = 0, g_losses = 0, g_trades_today = 0;
datetime g_day_stamp = 0;
double   g_daily_target = 0;

#define PANEL_W   500
#define PANEL_H   620
#define PANEL_PFX "HFTv2_"

//==================================================================
// UTILS
//==================================================================
double NormVol(string sym, double lots)
{
   double mn = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double st = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   lots = MathMax(mn, MathMin(mx, lots));
   return NormalizeDouble(MathRound(lots / st) * st, 2);
}

// Sessao em GMT real (TimeGMT). Na v2.4 usava a hora do servidor (IC ~ GMT+2/+3),
// o que deslocava as janelas e bloqueava o EA em horarios que o usuario julgava abertos.
bool IsSessionAllowed(string &reason)
{
   MqlDateTime t; TimeToStruct(TimeGMT(), t);
   int h = t.hour;
   if(InpBlockRollover && (h >= 22 || h < 1)) { reason = "sessao: rollover (22-01 GMT)"; return false; }
   if(h >= 8  && h < 13 && InpTradeLondon) return true;
   if(h >= 13 && h < 21 && InpTradeNY)     return true;
   if(h >= 1  && h < 8  && InpTradeAsia)   return true;
   reason = StringFormat("sessao: %02dh GMT fora das janelas ativas", h);
   return false;
}

string g_ccy = "";   // moeda da conta (painel)
string g_block_reason = "";      // motivo atual de nao operar (painel + CSV)
string g_block_logged = "";      // ultimo motivo ja gravado (evita spam)

void SetBlock(string reason)
{
   g_block_reason = reason;
   if(reason == g_block_logged) return;
   g_block_logged = reason;
   g_log.Append(LF_DECISIONS, StringFormat("%I64d;-;NENHUM;0;false;%s",
      GetTickCount64(), reason == "" ? "liberado" : reason));
}

string StateToStr(ENUM_EA_STATE s)
{
   switch(s)
   {
      case STATE_INIT:             return "INICIANDO";
      case STATE_GATE:             return "VALIDANDO";
      case STATE_IDLE:             return "OCIOSO";
      case STATE_ENTERING:         return "ENTRANDO";
      case STATE_IN_POSITION:      return "EM POSICAO";
      case STATE_EXITING:          return "SAINDO";
      case STATE_DAILY_TARGET_HIT: return "META ATINGIDA";
      case STATE_KILL_SWITCH:      return "PARADA";
      case STATE_ERROR:            return "ERRO";
   }
   return "?";
}
color StateColor(ENUM_EA_STATE s)
{
   switch(s)
   {
      case STATE_IDLE:             return CLR_ACCENT;
      case STATE_GATE:             return CLR_WARN;
      case STATE_IN_POSITION:      return CLR_PROFIT;
      case STATE_ENTERING:         return CLR_WARN;
      case STATE_EXITING:          return CLR_WARN;
      case STATE_DAILY_TARGET_HIT: return CLR_GOLD;
      case STATE_KILL_SWITCH:      return CLR_LOSS;
      case STATE_ERROR:            return CLR_LOSS;
   }
   return CLR_TEXT;
}
string TrendToStr(ENUM_TREND t)
{
   if(t == TREND_UP)   return "ALTA";
   if(t == TREND_DOWN) return "BAIXA";
   return "LATERAL";
}
string TrendArrow(ENUM_TREND t)
{
   if(t == TREND_UP)   return SYM_UP();
   if(t == TREND_DOWN) return SYM_DOWN();
   return SYM_FLAT();
}
color TrendColor(ENUM_TREND t)
{
   if(t == TREND_UP)   return CLR_PROFIT;
   if(t == TREND_DOWN) return CLR_LOSS;
   return CLR_TEXT_DIM;
}
string SigToStr(ENUM_SIG s)
{
   if(s == SIG_BUY)  return "COMPRA";
   if(s == SIG_SELL) return "VENDA";
   return "NENHUM";
}

void LogEvent(string type, string from, string to, string reason)
{
   g_log.Append(LF_EVENTS, StringFormat("%I64d;%s;%s;%s;%s",
      GetTickCount64(), type, from, to, reason));
}

//==================================================================
// PERSISTENCE
//==================================================================
#define AGG_VERSION "v4"
string AggFile() { return "HFT_Logs\\aggregates.csv"; }

void HardResetAggregates()
{
   g_day_stamp        = TimeCurrent();
   g_daily_money      = 0;
   g_daily_points     = 0;
   g_trades_today     = 0;
   g_weekly_money     = 0;
   g_monthly_money    = 0;
   g_annual_money     = 0;
   g_total_loss_money = 0;
   g_wins             = 0;
   g_losses           = 0;
   g_daily_target     = InpDailyTargetMoney;
}

void DeleteAggregatesFile()
{
   if(FileIsExist(AggFile(), FILE_COMMON)) FileDelete(AggFile(), FILE_COMMON);
   if(FileIsExist(AggFile(), 0))           FileDelete(AggFile(), 0);
}

bool LoadAggregates()
{
   int flags = InpLogLocal ? 0 : FILE_COMMON;
   int h = FileOpen(AggFile(), FILE_READ|FILE_CSV|FILE_ANSI|flags, ';');
   if(h == INVALID_HANDLE) return false;

   string f[11];
   int idx = 0;
   while(!FileIsEnding(h) && idx < 11) f[idx++] = FileReadString(h);
   FileClose(h);

   if(idx < 11 || f[0] != AGG_VERSION)
   {
      Print("[HFT] aggregates incompativel/curto (v='", (idx>0?f[0]:"?"),
            "' campos=", idx, "). Deletando.");
      DeleteAggregatesFile();
      return false;
   }

   datetime ds = (datetime)StringToInteger(f[1]);
   double  dm  = StringToDouble(f[2]);
   double  dp  = StringToDouble(f[3]);
   int     tt  = (int)StringToInteger(f[4]);
   double  wk  = StringToDouble(f[5]);
   double  mo  = StringToDouble(f[6]);
   double  an  = StringToDouble(f[7]);
   double  tl  = StringToDouble(f[8]);
   int     wi  = (int)StringToInteger(f[9]);
   int     lo  = (int)StringToInteger(f[10]);

   bool bad = false;
   if(ds < D'2020.01.01' || ds > D'2100.01.01') bad = true;
   if(MathAbs(dm) > 1e7 || MathAbs(wk) > 1e8 || MathAbs(mo) > 1e8 || MathAbs(an) > 1e8) bad = true;
   if(tl < 0 || tl > 1e8) bad = true;
   if(tt < 0 || tt > 100000) bad = true;
   if(wi < 0 || wi > 100000) bad = true;
   if(lo < 0 || lo > 100000) bad = true;

   if(bad)
   {
      Print("[HFT] aggregates fora do range. Deletando.");
      DeleteAggregatesFile();
      return false;
   }

   g_day_stamp = ds; g_daily_money = dm; g_daily_points = dp;
   g_trades_today = tt; g_weekly_money = wk; g_monthly_money = mo;
   g_annual_money = an; g_total_loss_money = tl; g_wins = wi; g_losses = lo;
   Print("[HFT] aggregates carregados: dia=", TimeToString(ds, TIME_DATE),
         " wins=", wi, " losses=", lo, " daily=", dm);
   return true;
}

void SaveAggregates()
{
   int flags = InpLogLocal ? 0 : FILE_COMMON;
   int h = FileOpen(AggFile(), FILE_WRITE|FILE_CSV|FILE_ANSI|flags, ';');
   if(h == INVALID_HANDLE) return;
   FileWrite(h, AGG_VERSION);
   FileWrite(h, IntegerToString((long)g_day_stamp));
   FileWrite(h, DoubleToString(g_daily_money, 2));
   FileWrite(h, DoubleToString(g_daily_points, 1));
   FileWrite(h, IntegerToString(g_trades_today));
   FileWrite(h, DoubleToString(g_weekly_money, 2));
   FileWrite(h, DoubleToString(g_monthly_money, 2));
   FileWrite(h, DoubleToString(g_annual_money, 2));
   FileWrite(h, DoubleToString(g_total_loss_money, 2));
   FileWrite(h, IntegerToString(g_wins));
   FileWrite(h, IntegerToString(g_losses));
   FileClose(h);
}

void ResetPeriodsIfNeeded()
{
   MqlDateTime now; TimeToStruct(TimeCurrent(), now);
   MqlDateTime ds;  TimeToStruct(g_day_stamp, ds);
   bool new_day = (g_day_stamp == 0) ||
                  (now.day != ds.day || now.mon != ds.mon || now.year != ds.year);
   if(!new_day) return;

   if(g_day_stamp != 0)
      LogEvent("DAY_ROLLOVER", StateToStr(g_state), "OCIOSO",
         StringFormat("de %04d-%02d-%02d", ds.year, ds.mon, ds.day));

   g_daily_money = 0; g_daily_points = 0; g_trades_today = 0;
   g_wins = 0; g_losses = 0;

   g_day_stamp = TimeCurrent();
   g_daily_target = InpDailyTargetMoney;

   for(int i = 0; i < g_nsym; i++)
   {
      g_syms[i].daily_money = 0; g_syms[i].daily_points = 0;
      g_syms[i].wins = 0; g_syms[i].losses = 0;
   }

   if(g_state == STATE_DAILY_TARGET_HIT) g_state = STATE_IDLE;
   if(now.mon != ds.mon)   g_monthly_money = 0;
   if(now.year != ds.year) g_annual_money  = 0;
   if(now.day_of_week == 1 && ds.day_of_week != 1) g_weekly_money = 0;
   SaveAggregates();
}

//==================================================================
// ENSEMBLE
//==================================================================
ENUM_SIG EnsembleVote(CSymbolContext &ctx, double &confidence)
{
   confidence = 0;
   if(ctx.count < InpOFIWindow) return SIG_NONE;

   double buy_score = 0, sell_score = 0;

   double ofi_abs = MathAbs(ctx.ofi);
   if(ofi_abs > InpOFIThreshold)
   {
      double str = MathMin(1.0, ofi_abs / 0.6);
      if(ctx.ofi > 0) buy_score  += InpW_OFI * str;
      else            sell_score += InpW_OFI * str;
   }

   if(MathAbs(ctx.last_dir_streak) >= 3)
   {
      double str = MathMin(1.0, MathAbs(ctx.last_dir_streak) / 6.0);
      if(ctx.last_dir_streak > 0) sell_score += InpW_MeanRev * str;
      else                        buy_score  += InpW_MeanRev * str;
   }

   if(ctx.trend == TREND_UP && ctx.last_dir_streak >= 2)
      buy_score  += InpW_Momentum * MathMax(0.3, ctx.trend_strength);
   if(ctx.trend == TREND_DOWN && ctx.last_dir_streak <= -2)
      sell_score += InpW_Momentum * MathMax(0.3, ctx.trend_strength);

   double total = buy_score + sell_score;
   if(total <= 0) return SIG_NONE;

   ENUM_SIG side = (buy_score >= sell_score) ? SIG_BUY : SIG_SELL;
   double win_score = MathMax(buy_score, sell_score);
   confidence = win_score / total;
   if(confidence < InpMinConfidence) return SIG_NONE;
   return side;
}

//==================================================================
// PANEL HELPERS
//==================================================================
void PRect(string name, int x, int y, int w, int h, color bg, color border, int bw = 1)
{
   string obj = PANEL_PFX + name;
   if(ObjectFind(0, obj) < 0)
   {
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, obj, OBJPROP_BACK, false);
      ObjectSetInteger(0, obj, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   }
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, obj, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, border);
   ObjectSetInteger(0, obj, OBJPROP_WIDTH, bw);
}
void PLabel(string name, int x, int y, string txt, color clr, int size = 9, string font = "Consolas")
{
   string obj = PANEL_PFX + name;
   if(ObjectFind(0, obj) < 0)
   {
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, obj, OBJPROP_BACK, false);
   }
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, obj, OBJPROP_FONT, font);
   ObjectSetString(0, obj, OBJPROP_TEXT, txt);
}
void PLine(string name, int x, int y, int w, color clr)
{
   PRect(name, x, y, w, 1, clr, clr, 1);
}
void RemovePanel() { ObjectsDeleteAll(0, PANEL_PFX); }

//==================================================================
// PAINEL
//==================================================================
void DrawPanel()
{
   if(!InpShowPanel) return;
   int X = InpPanelX, Y = InpPanelY;

   PRect("bg",    X, Y, PANEL_W, PANEL_H, CLR_BG, CLR_BORDER);
   PRect("bg_hi", X + 1, Y + 1, PANEL_W - 2, 60, CLR_BG2, CLR_BG2);
   PRect("top",   X, Y, PANEL_W, 3, CLR_ACCENT, CLR_ACCENT);
   PRect("left",  X, Y, 3, PANEL_H, CLR_ACCENT, CLR_ACCENT);
   PRect("bot",   X, Y + PANEL_H - 2, PANEL_W, 2, CLR_ACCENT_D, CLR_ACCENT_D);

   int cx = X + 16;

   PLabel("title", cx, Y + 12, ">> HFT-RETAIL  " + EA_VERSION, CLR_ACCENT, 12);
   PLabel("sub", cx, Y + 30, "scalper de ticks  |  dinheiro & pontos", CLR_TEXT_DIM, 8);

   MqlDateTime nowt; TimeToStruct(TimeLocal(), nowt);
   PLabel("clock", X + PANEL_W - 110, Y + 14,
      StringFormat("%02d:%02d:%02d", nowt.hour, nowt.min, nowt.sec), CLR_ACCENT, 11);

   bool pulse = ((GetTickCount64() / 500) % 2) == 0;
   PLabel("dot",  X + PANEL_W - 30, Y + 12, SYM_FLAT(), pulse ? CLR_PROFIT : C'0,120,80', 14);
   PLabel("live", X + PANEL_W - 110, Y + 30, "AO VIVO", CLR_TEXT_DIM, 8);

   int y = Y + 52;

   // Card 1 — Estado
   PRect("c1", cx - 8, y, PANEL_W - 16, 54, CLR_CARD, CLR_BORDER);
   PLine("c1l", cx - 8, y, 3, CLR_ACCENT);
   PLabel("c1t", cx, y + 6, "ESTADO ATUAL", CLR_TEXT_DIM, 8);
   PLabel("c1v", cx, y + 22, StateToStr(g_state), StateColor(g_state), 14);

   int rx = X + PANEL_W - 200;
   MqlTick tk0; double sp0 = 0;
   if(g_nsym > 0 && SymbolInfoTick(g_syms[0].sym, tk0))
      sp0 = (tk0.ask - tk0.bid) / g_syms[0].point;
   PLabel("c1s", rx, y + 8, StringFormat("SPREAD  %.1f pt", sp0), CLR_TEXT, 9);

   string gate_str = "GATE: --"; color gate_clr = CLR_TEXT_DIM;
   if(g_nsym > 0)
   {
      if(!g_syms[0].gate_done)       { gate_str = "GATE: amostrando"; gate_clr = CLR_WARN; }
      else if(g_syms[0].gate_passed) { gate_str = "GATE: OK";          gate_clr = CLR_PROFIT; }
      else                           { gate_str = "GATE: reprovado";   gate_clr = CLR_LOSS; }
   }
   PLabel("c1g", rx, y + 26, gate_str, gate_clr, 9);
   y += 62;

   // Card 2 — Mercado
   PRect("c2", cx - 8, y, PANEL_W - 16, 54, CLR_CARD, CLR_BORDER);
   PLine("c2l", cx - 8, y, 3, CLR_ACCENT);
   PLabel("c2t", cx, y + 6, "MERCADO", CLR_TEXT_DIM, 8);
   string sym_disp = (g_nsym > 0) ? g_syms[0].sym : "-";
   ENUM_TREND tr = (g_nsym > 0) ? g_syms[0].trend : TREND_SIDE;
   double ofi_v = (g_nsym > 0) ? g_syms[0].ofi : 0;
   double imb_v = (g_nsym > 0) ? g_syms[0].dom_imb : 0;
   PLabel("c2sym", cx, y + 22, sym_disp, CLR_ACCENT, 13);
   PLabel("c2tr", cx + 110, y + 24, TrendArrow(tr) + " " + TrendToStr(tr), TrendColor(tr), 11);
   PLabel("c2of", cx + 240, y + 24, StringFormat("OFI %+.2f", ofi_v),
      (ofi_v >= 0) ? CLR_PROFIT : CLR_LOSS, 9);
   PLabel("c2im", cx + 330, y + 24, StringFormat("IMB %+.2f", imb_v),
      (imb_v >= 0) ? CLR_PROFIT : CLR_LOSS, 9);
   y += 62;

   // Card 3 — Desempenho
   int total = g_wins + g_losses;
   double hit = (total > 0) ? 100.0 * g_wins / total : 0;
   PRect("c3", cx - 8, y, PANEL_W - 16, 54, CLR_CARD, CLR_BORDER);
   PLine("c3l", cx - 8, y, 3, CLR_ACCENT);
   PLabel("c3t", cx, y + 6, "DESEMPENHO (HOJE)", CLR_TEXT_DIM, 8);
   PLabel("c3w", cx, y + 22, StringFormat("VITORIAS  %d", g_wins), CLR_PROFIT, 11);
   PLabel("c3l2", cx + 140, y + 22, StringFormat("DERROTAS  %d", g_losses), CLR_LOSS, 11);
   color hitc = (hit >= 60) ? CLR_PROFIT : (hit >= 40 ? CLR_WARN : CLR_LOSS);
   PLabel("c3h", cx + 270, y + 22, StringFormat("ACERTO  %.1f%%", hit), hitc, 11);
   PLabel("c3n", cx, y + 38, StringFormat("OPERACOES HOJE  %d", total), CLR_TEXT_DIM, 9);
   y += 62;

   // Card 4 — P&L
   PRect("c4", cx - 8, y, PANEL_W - 16, 138, CLR_CARD, CLR_BORDER);
   PLine("c4l", cx - 8, y, 3, CLR_ACCENT);
   PLabel("c4t", cx, y + 6, "P&L LIQUIDO", CLR_TEXT_DIM, 8);
   color dclr = (g_daily_money >= 0) ? CLR_PROFIT : CLR_LOSS;
   PLabel("c4d", cx, y + 24, "DIA", CLR_TEXT_DIM, 9);
   PLabel("c4dv", cx + 90, y + 24, g_ccy + StringFormat(" %+9.2f", g_daily_money), dclr, 11);
   PLabel("c4dp", cx + 280, y + 24, StringFormat("(%+.0f pt)", g_daily_points), dclr, 9);
   PLabel("c4s", cx, y + 46, "SEMANA", CLR_TEXT_DIM, 9);
   PLabel("c4sv", cx + 90, y + 46, g_ccy + StringFormat(" %+9.2f", g_weekly_money),
      (g_weekly_money >= 0) ? CLR_PROFIT : CLR_LOSS, 10);
   PLabel("c4m", cx, y + 66, "MES", CLR_TEXT_DIM, 9);
   PLabel("c4mv", cx + 90, y + 66, g_ccy + StringFormat(" %+9.2f", g_monthly_money),
      (g_monthly_money >= 0) ? CLR_PROFIT : CLR_LOSS, 10);
   PLabel("c4a", cx, y + 86, "ANO", CLR_TEXT_DIM, 9);
   PLabel("c4av", cx + 90, y + 86, g_ccy + StringFormat(" %+9.2f", g_annual_money),
      (g_annual_money >= 0) ? CLR_PROFIT : CLR_LOSS, 10);
   PLabel("c4l2", cx, y + 108, "PERDA LIQ. TOTAL", CLR_TEXT_DIM, 9);
   PLabel("c4lv", cx + 190, y + 108, g_ccy + StringFormat(" %.2f", g_total_loss_money), CLR_LOSS, 10);
   y += 146;

   // Card 5 — Meta
   double tgt = (g_daily_target > 0) ? g_daily_target : InpDailyTargetMoney;
   double pct = (tgt > 0) ? 100.0 * g_daily_money / tgt : 0;
   pct = MathMax(0, MathMin(100, pct));
   PRect("c5", cx - 8, y, PANEL_W - 16, 86, CLR_CARD, CLR_BORDER);
   PLine("c5l", cx - 8, y, 3, CLR_GOLD);
   PLabel("c5t", cx, y + 6, "META DIARIA", CLR_TEXT_DIM, 8);
   PLabel("c5v", cx, y + 22, g_ccy + StringFormat(" %.2f", tgt), CLR_GOLD, 13);
   PLabel("c5p", X + PANEL_W - 130, y + 24, StringFormat("%.0f%%", pct), CLR_GOLD, 12);
   int bar_len = 42, filled = (int)MathRound(pct / 100.0 * bar_len);
   string bar = "";
   for(int i = 0; i < bar_len; i++) bar += (i < filled) ? SYM_BLOCK_F() : SYM_BLOCK_E();
   PLabel("c5b", cx, y + 46, bar, CLR_GOLD, 12);
   PLabel("c5i", cx, y + 68,
      StringFormat("META/TRADE  %s %.2f     RISCO: %s",
         g_ccy, InpTP_MoneyPerTrade, InpUseStopLoss ? "SL ATIVO" : "SL DESLIGADO"), CLR_TEXT, 9);
   y += 94;

   // Card 6 — Últimas
   PRect("c6", cx - 8, y, PANEL_W - 16, 100, CLR_CARD, CLR_BORDER);
   PLine("c6l", cx - 8, y, 3, CLR_ACCENT);
   PLabel("c6t", cx, y + 6, "ULTIMAS OPERACOES", CLR_TEXT_DIM, 8);
   if(g_recent_n == 0)
      PLabel("c6n", cx, y + 34, "aguardando primeira operacao...", CLR_TEXT_DIM, 9);
   else
      for(int i = 0; i < g_recent_n && i < 3; i++)
      {
         color c = g_recent[i].win ? CLR_PROFIT : CLR_LOSS;
         string when = TimeToString(g_recent[i].time, TIME_MINUTES);
         string mark = g_recent[i].win ? SYM_CHECK() : SYM_CROSS();
         PLabel("c6r" + IntegerToString(i), cx, y + 24 + i * 20,
            StringFormat("%s   %s   %-7s   %s %+7.2f  (%+.0f pt)   %s",
               when, g_recent[i].sym, g_recent[i].side, g_ccy,
               g_recent[i].money, g_recent[i].points, mark), c, 9);
      }
   // Linha operacional: por que esta (ou nao) operando
   bool blocked = (g_block_reason != "");
   PLabel("foot", cx, Y + PANEL_H - 20,
      blocked ? ("BLOQUEIO: " + g_block_reason) : "LIBERADO para operar  |  CSV " + CSV_SCHEMA,
      blocked ? CLR_WARN : CLR_PROFIT, 8);
}

//==================================================================
// TRADE
//==================================================================
double NormPrice(CSymbolContext &ctx, double p)
{
   if(ctx.tick_size > 0) p = MathRound(p / ctx.tick_size) * ctx.tick_size;
   return NormalizeDouble(p, ctx.digits);
}

void ComputeTPandSL(CSymbolContext &ctx, int type, double price, double lots,
                    double &tp, double &sl, double &tpm, double &slm)
{
   tp = 0; sl = 0; tpm = 0; slm = 0;
   double tp_pts = 0;
   if(InpTP_UsePointsInstead && InpTP_PointsPerTrade > 0)
   { tp_pts = InpTP_PointsPerTrade; tpm = ctx.PointsToMoney(lots, tp_pts); }
   else if(InpTP_MoneyPerTrade > 0)
   { tpm = InpTP_MoneyPerTrade; tp_pts = ctx.MoneyToPoints(lots, tpm); }
   if(tp_pts > 0)
      tp = NormPrice(ctx, (type == ORDER_TYPE_BUY) ? price + tp_pts * ctx.point : price - tp_pts * ctx.point);

   if(InpUseStopLoss)
   {
      double sl_pts = 0;
      if(InpSL_UsePoints && InpSL_PointsPerTrade > 0)
      { sl_pts = InpSL_PointsPerTrade; slm = ctx.PointsToMoney(lots, sl_pts); }
      else if(InpSL_MoneyPerTrade > 0)
      { slm = InpSL_MoneyPerTrade; sl_pts = ctx.MoneyToPoints(lots, slm); }
      if(sl_pts > 0)
         sl = NormPrice(ctx, (type == ORDER_TYPE_BUY) ? price - sl_pts * ctx.point : price + sl_pts * ctx.point);
   }
}

bool PreTradeChecks(CSymbolContext &ctx, ENUM_ORDER_TYPE type, double price, double lots,
                    double sl, double tp, string &why)
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
   { why = "trading desligado (AutoTrading/EA)"; return false; }
   if(SymbolInfoInteger(ctx.sym, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
   { why = "modo de negociacao do simbolo != FULL"; return false; }

   double min_dist = (double)SymbolInfoInteger(ctx.sym, SYMBOL_TRADE_STOPS_LEVEL) * ctx.point;
   if(tp > 0 && MathAbs(tp - price) < min_dist) { why = "TP dentro do stops level"; return false; }
   if(sl > 0 && MathAbs(sl - price) < min_dist) { why = "SL dentro do stops level"; return false; }

   double margin = 0;
   if(OrderCalcMargin(type, ctx.sym, lots, price, margin) &&
      margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   { why = "margem livre insuficiente"; return false; }
   return true;
}

bool OpenTrade(CSymbolContext &ctx, ENUM_SIG sig)
{
   ENUM_ORDER_TYPE type = (sig == SIG_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double lots = NormVol(ctx.sym, InpFixedLots);

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(InpSlippagePoints);
   g_trade.SetTypeFillingBySymbol(ctx.sym);

   bool ok = false;
   double price = 0;
   for(int i = 0; i <= InpOrderRetryMax && !ok; i++)
   {
      // preco, TP e SL sao refeitos a cada tentativa (requote muda o preco)
      MqlTick tk; if(!SymbolInfoTick(ctx.sym, tk)) return false;
      price = (sig == SIG_BUY) ? tk.ask : tk.bid;
      ComputeTPandSL(ctx, (int)type, price, lots,
                     ctx.tp_price, ctx.sl_price, ctx.tp_money, ctx.sl_money);

      string why;
      if(!PreTradeChecks(ctx, type, price, lots, ctx.sl_price, ctx.tp_price, why))
      {
         g_log.Append(LF_ORDERS, StringFormat("%I64d;%s;%s;%.2f;%.*f;%.*f;%.*f;%d;PRECHECK;0;%s",
            GetTickCount64(), ctx.sym, SigToStr(sig), lots, ctx.digits, price,
            ctx.digits, ctx.sl_price, ctx.digits, ctx.tp_price, i + 1, why));
         LogEvent("ORDER_BLOCKED", "ENTRANDO", "OCIOSO", ctx.sym + ": " + why);
         return false;
      }

      if(type == ORDER_TYPE_BUY)
         ok = g_trade.Buy(lots, ctx.sym, 0, ctx.sl_price, ctx.tp_price, "HFT");
      else
         ok = g_trade.Sell(lots, ctx.sym, 0, ctx.sl_price, ctx.tp_price, "HFT");

      uint rc = g_trade.ResultRetcode();
      g_log.Append(LF_ORDERS, StringFormat("%I64d;%s;%s;%.2f;%.*f;%.*f;%.*f;%d;%u;%I64u;%s",
         GetTickCount64(), ctx.sym, SigToStr(sig), lots, ctx.digits, price,
         ctx.digits, ctx.sl_price, ctx.digits, ctx.tp_price, i + 1, rc,
         g_trade.ResultOrder(), g_trade.ResultRetcodeDescription()));

      // so repete em erros de preco; qualquer outro retcode (margem, mercado fechado...) encerra
      bool retryable = (rc == TRADE_RETCODE_REQUOTE || rc == TRADE_RETCODE_PRICE_CHANGED ||
                        rc == TRADE_RETCODE_PRICE_OFF);
      if(!ok && !retryable) break;
      if(!ok && i < InpOrderRetryMax) Sleep(50);
   }

   if(ok)
   {
      ctx.ticket = g_trade.ResultOrder();
      ctx.entry_type = (int)type;
      ctx.entry_price = g_trade.ResultPrice();
      ctx.entry_time = TimeCurrent();
      ctx.exit_reason = "TP/SL servidor";
      ctx.pending_lots = lots;
      LogEvent("ORDER_SENT", "ENTRANDO", "EM POSICAO",
         StringFormat("%s lots=%.2f price=%.*f sl=%.*f tp=%.*f", ctx.sym, lots,
            ctx.digits, ctx.entry_price, ctx.digits, ctx.sl_price, ctx.digits, ctx.tp_price));
      return true;
   }
   LogEvent("ORDER_FAILED", "ENTRANDO", "OCIOSO",
      ctx.sym + ": " + g_trade.ResultRetcodeDescription());
   return false;
}

// v2.4: o chamador zerava ctx.ticket ANTES de chamar esta funcao, que retornava
// imediatamente (ticket==0): o TP/SL em dinheiro nunca fechava nada por software.
// Agora o ticket so e liberado aqui, depois do pedido de fechamento.
bool CloseSymbol(CSymbolContext &ctx, string reason)
{
   if(ctx.ticket == 0) return false;
   if(!PositionSelectByTicket(ctx.ticket)) { ctx.ticket = 0; return false; }
   // pedido de fechamento ja enviado ha pouco: espera o DEAL em vez de reenviar a cada tick
   if(ctx.close_req_ms != 0 && GetTickCount64() - ctx.close_req_ms < 500) return true;
   ctx.close_req_ms = GetTickCount64();
   ctx.exit_reason = reason;
   bool ok = g_trade.PositionClose(ctx.ticket, InpSlippagePoints);
   LogEvent(ok ? "POSITION_CLOSE" : "CLOSE_FAILED", "SAINDO", "OCIOSO",
      ctx.sym + ": " + reason + " rc=" + IntegerToString((int)g_trade.ResultRetcode()));
   // ticket permanece ate o DEAL de saida chegar em OnTradeTransaction; se falhou, tenta de novo no proximo tick
   return ok;
}

//==================================================================
// RISCO
//==================================================================
bool RiskAllowEntry(string &reason)
{
   if(InpUseMaxDailyLoss && g_daily_money <= -InpMaxDailyLossMoney)
   { reason = "perda diaria maxima"; return false; }
   if(InpUseMaxTradesPerDay && g_trades_today >= InpMaxTradesPerDay)
   { reason = "max operacoes/dia"; return false; }
   return true;
}

// v2.4 so avaliava o kill switch na busca de entrada (estado OCIOSO): com posicao
// aberta ele nunca disparava e, quando disparava, nao fechava nada. Agora e checado
// a todo tick, em qualquer estado, e fecha as posicoes se InpKillSwitchClosePos.
double CurrentDrawdownPct()
{
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double bl = AccountInfoDouble(ACCOUNT_BALANCE);
   return (bl > 0) ? 100.0 * (bl - eq) / bl : 0;
}

void KillSwitchTick()
{
   if(!InpUseKillSwitch) return;
   if(g_state != STATE_KILL_SWITCH)
   {
      double dd = CurrentDrawdownPct();
      if(dd < InpKillSwitchDrawdownPct) return;
      string from = StateToStr(g_state);
      g_state = STATE_KILL_SWITCH;
      LogEvent("KILL_SWITCH", from, StateToStr(g_state),
         StringFormat("dd=%.2f%% limite=%.2f%% fecha_posicoes=%s", dd, InpKillSwitchDrawdownPct,
            InpKillSwitchClosePos ? "sim" : "nao"));
      Print("[HFT] KILL SWITCH: drawdown ", DoubleToString(dd, 2), "% - EA parado ate reiniciar.");
   }
   if(InpKillSwitchClosePos)
      for(int i = 0; i < g_nsym; i++)
         if(g_syms[i].ticket != 0) CloseSymbol(g_syms[i], "KILL_SWITCH");
}

bool DailyTargetAllowEntry(string &reason)
{
   if(!InpBlockOnDailyTarget) return true;
   double tgt = (g_daily_target > 0) ? g_daily_target : InpDailyTargetMoney;
   if(tgt > 0 && g_daily_money >= tgt) { reason = "meta diaria batida"; return false; }
   return true;
}

//==================================================================
// DOM
//==================================================================
void UpdateDOM(CSymbolContext &ctx)
{
   MqlBookInfo book[];
   if(!MarketBookGet(ctx.sym, book)) return;
   int n = ArraySize(book);
   if(n <= 0) return;
   double bv = 0, av = 0;
   for(int i = 0; i < n; i++)
   {
      if(book[i].type == BOOK_TYPE_SELL) av += book[i].volume_real;
      else if(book[i].type == BOOK_TYPE_BUY) bv += book[i].volume_real;
   }
   ctx.dom_bid_vol = bv; ctx.dom_ask_vol = av;
   ctx.dom_imb = (bv + av > 0) ? (bv - av) / (bv + av) : 0;
   ctx.dom_ok = true;
   if(InpLogDOM)
      g_log.Append(LF_DOM, StringFormat("%I64d;%s;%.2f;%.2f;%.3f",
         GetTickCount64(), ctx.sym, bv, av, ctx.dom_imb));
}

//==================================================================
// LIFECYCLE
//==================================================================
int OnInit()
{
   g_log.Init();
   HardResetAggregates();

   g_ccy = AccountInfoString(ACCOUNT_CURRENCY);

   // 1) cria pastas de logs IMEDIATAMENTE (HFT_Logs\v25\<data>)
   g_log.RollIfNeeded();

   // 2) parse símbolos
   string parts[];
   int np = StringSplit(InpSymbols, ';', parts);
   if(np <= 0) { Print("Nenhum simbolo."); return INIT_FAILED; }

   ArrayResize(g_syms, np);
   g_nsym = 0;
   for(int i = 0; i < np; i++)
   {
      string s = parts[i];
      StringTrimLeft(s); StringTrimRight(s);
      if(StringLen(s) == 0) continue;
      if(!SymbolSelect(s, true)) { Print("Falha ao selecionar ", s); continue; }
      g_syms[g_nsym].Init(s);
      g_nsym++;
   }
   ArrayResize(g_syms, g_nsym);
   if(g_nsym == 0) { Print("Nenhum simbolo valido."); return INIT_FAILED; }
   g_primary = g_syms[0].sym;

   for(int i = 0; i < g_nsym; i++)
      if(!MarketBookAdd(g_syms[i].sym))
         Print("[HFT] MarketBookAdd falhou para ", g_syms[i].sym, " (sem DOM; imbalance = 0)");

   if(g_nsym > 1)
      Print("[HFT] AVISO: OnTick so recebe ticks do simbolo do grafico. ",
            "Com varios simbolos, os demais so atualizam no tick do principal. Prefira 1 simbolo.");

   bool loaded = LoadAggregates();
   if(!loaded) SaveAggregates();
   ResetPeriodsIfNeeded();

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(InpSlippagePoints);

   EventSetMillisecondTimer(InpPanelRefreshMs);

   g_state = InpUseGate ? STATE_GATE : STATE_IDLE;

   g_log.ReportPath();
   LogEvent("INIT", "NENHUM", StateToStr(g_state),
      StringFormat("ver=%s schema=%s magic=%I64d symbols=%s gate=%s strict=%s ccy=%s "
                   "tp=%.2f sl=%s(%.2f) kill=%s(%.1f%%,close=%s) lots=%.2f sessao=L%d/NY%d/AS%d/rollBlock%d "
                   "server_gmt_offset_s=%d",
         EA_VERSION, CSV_SCHEMA, InpMagic, InpSymbols, InpUseGate ? "on" : "off",
         InpGateStrictMode ? "on" : "off", g_ccy,
         InpTP_MoneyPerTrade, InpUseStopLoss ? "on" : "off", InpSL_MoneyPerTrade,
         InpUseKillSwitch ? "on" : "off", InpKillSwitchDrawdownPct, InpKillSwitchClosePos ? "sim" : "nao",
         InpFixedLots, InpTradeLondon, InpTradeNY, InpTradeAsia, InpBlockRollover,
         (int)(TimeCurrent() - TimeGMT())));
   if(!InpUseStopLoss)
      Print("[HFT] AVISO: Stop Loss DESLIGADO. Protecao = kill switch por drawdown",
            InpKillSwitchClosePos ? " (fecha posicoes)." : " (so bloqueia entradas).");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   g_log.FlushAll();
   SaveAggregates();
   LogEvent("DEINIT", StateToStr(g_state), "NENHUM", IntegerToString(reason));
   for(int i = 0; i < g_nsym; i++) MarketBookRelease(g_syms[i].sym);
   RemovePanel();
   EventKillTimer();
}

void OnBookEvent(const string &symbol)
{
   for(int i = 0; i < g_nsym; i++)
      if(g_syms[i].sym == symbol) { UpdateDOM(g_syms[i]); return; }
}

void OnTick()
{
   ResetPeriodsIfNeeded();

   for(int i = 0; i < g_nsym; i++)
   {
      g_syms[i].UpdateFeatures();
      g_syms[i].UpdateTrend();
   }

   KillSwitchTick();

   // Gate global
   if(g_state == STATE_GATE)
   {
      SetBlock("gate: amostrando spread/ticks");
      bool all_done = true;
      for(int i = 0; i < g_nsym; i++)
         if(!g_syms[i].gate_done) { all_done = false; break; }

      if(all_done)
      {
         bool any_pass = false;
         for(int i = 0; i < g_nsym; i++)
            if(g_syms[i].gate_passed) { any_pass = true; break; }

         if(any_pass)
            g_state = STATE_IDLE;
         else if(InpGateStrictMode)
         {
            g_state = STATE_ERROR;
            Print("[HFT] Gate estrito: todos os simbolos reprovados. ",
                  "Aumente InpGateMaxAvgSpread ou desative InpGateStrictMode.");
         }
         else
            g_state = STATE_IDLE;

         LogEvent("GATE_GLOBAL", "VALIDANDO", StateToStr(g_state),
            any_pass ? "pelo menos 1 simbolo aprovado" : "modo aviso (nao estrito)");
      }
      return;
   }

   // Gestão de posições
   for(int i = 0; i < g_nsym; i++)
   {
      if(g_syms[i].ticket == 0) continue;
      if(!PositionSelectByTicket(g_syms[i].ticket)) { g_syms[i].ticket = 0; continue; }
      if(PositionGetString(POSITION_SYMBOL) != g_syms[i].sym) { g_syms[i].ticket = 0; continue; }

      double pnl = g_syms[i].PositionPnLMoney();
      if(g_syms[i].tp_money > 0 && pnl >= g_syms[i].tp_money)
      { if(CloseSymbol(g_syms[i], "TP_MONEY")) g_state = STATE_EXITING; continue; }
      if(InpUseStopLoss && g_syms[i].sl_money > 0 && pnl <= -g_syms[i].sl_money)
      { if(CloseSymbol(g_syms[i], "SL_MONEY")) g_state = STATE_EXITING; continue; }
   }

   string reason = "";
   if(g_state == STATE_IN_POSITION || g_state == STATE_EXITING || g_state == STATE_ENTERING)
   { SetBlock("posicao aberta (aguardando saida)"); return; }
   if(g_state == STATE_KILL_SWITCH)
   { SetBlock("kill switch (drawdown) - reinicie o EA"); return; }
   if(g_state == STATE_ERROR)
   { SetBlock("erro: gate estrito reprovou todos os simbolos"); return; }
   if(g_state == STATE_DAILY_TARGET_HIT)
   { SetBlock("meta diaria batida"); return; }
   if(g_state != STATE_IDLE) return;

   if(!IsSessionAllowed(reason)) { SetBlock(reason); return; }

   if(!DailyTargetAllowEntry(reason))
   {
      g_state = STATE_DAILY_TARGET_HIT;
      SetBlock(reason);
      return;
   }
   if(!RiskAllowEntry(reason))
   {
      SetBlock(reason);
      return;
   }
   string loop_block = "";   // so grava ao fim do loop (evita alternar a cada tick)

   // Procura entrada
   for(int i = 0; i < g_nsym; i++)
   {
      if(!g_syms[i].gate_passed || g_syms[i].ticket != 0) continue;

      MqlTick tk;
      if(!SymbolInfoTick(g_syms[i].sym, tk)) continue;
      double sp = (tk.ask - tk.bid) / g_syms[i].point;
      if(sp > InpMaxSpreadPoints)
      { loop_block = "spread acima do maximo"; continue; }

      double conf = 0;
      ENUM_SIG sig = EnsembleVote(g_syms[i], conf);
      if(sig == SIG_NONE) continue;

      g_log.Append(LF_DECISIONS, StringFormat("%I64d;%s;%s;%.3f;true;aprovado",
         GetTickCount64(), g_syms[i].sym, SigToStr(sig), conf));

      SetBlock("");
      g_state = STATE_ENTERING;
      if(OpenTrade(g_syms[i], sig)) g_state = STATE_IN_POSITION;
      else                          g_state = STATE_IDLE;
      return;
   }
   SetBlock(loop_block);   // "" = liberado, aguardando sinal
}

void OnTimer()
{
   ResetPeriodsIfNeeded();

   if(g_daily_target != InpDailyTargetMoney)
   {
      double old = g_daily_target;
      g_daily_target = InpDailyTargetMoney;
      if(g_state == STATE_DAILY_TARGET_HIT && g_daily_money < g_daily_target)
      {
         g_state = STATE_IDLE;
         LogEvent("META_OVERRIDE", "META ATINGIDA", "OCIOSO",
            StringFormat("old=%.2f new=%.2f", old, g_daily_target));
      }
   }

   for(int i = 0; i < g_nsym; i++)
   {
      if(InpLogTicks)
      {
         MqlTick tk; if(SymbolInfoTick(g_syms[i].sym, tk))
         {
            double sp = (tk.ask - tk.bid) / g_syms[i].point;
            g_log.Append(LF_TICKS, StringFormat("%I64d;%s;%.5f;%.5f;%.1f;%.3f;%d;%.3f",
               GetTickCount64(), g_syms[i].sym, tk.bid, tk.ask, sp,
               g_syms[i].ofi, (int)g_syms[i].trend, g_syms[i].dom_imb));
         }
      }
   }

   int total = g_wins + g_losses;
   double hit = (total > 0) ? 100.0 * g_wins / total : 0;

   // panel_state/metrics: so quando algo muda ou a cada InpSnapshotSec (v2.4 gravava a cada 250 ms)
   static string snap_sig = "";
   static ulong  snap_ms  = 0;
   string sig_now = StringFormat("%d|%d|%d|%.2f|%.2f|%.2f|%.2f|%s", (int)g_state, g_wins, g_losses,
                                 g_daily_money, g_weekly_money, g_monthly_money, g_total_loss_money,
                                 g_block_reason);
   bool snap_due = (sig_now != snap_sig) ||
                   (GetTickCount64() - snap_ms >= (ulong)MathMax(1, InpSnapshotSec) * 1000);
   if(snap_due)
   {
   snap_sig = sig_now;
   snap_ms  = GetTickCount64();
   g_log.Append(LF_PANEL, StringFormat("%I64d;%s;%d;%d;%d;%.1f;%.2f;%.2f;%.2f;%.2f;%.2f;%d",
      GetTickCount64(), StateToStr(g_state), g_nsym, g_wins, g_losses, hit,
      g_daily_money, g_weekly_money, g_monthly_money, g_annual_money,
      g_total_loss_money, total));
   g_log.Append(LF_METRICS, StringFormat("%I64d;%d;%d;%d;%.1f;%.2f;%.2f;%.2f;%.2f;%.2f",
      GetTickCount64(), g_wins, g_losses, total, hit,
      g_daily_money, g_weekly_money, g_monthly_money,
      g_annual_money, g_total_loss_money));
   }

   g_log.MaybeFlush();
   DrawPanel();
}

//==================================================================
// TRADE TRANSACTION
//==================================================================
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &req,
                        const MqlTradeResult &res)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   ulong deal = trans.deal;
   if(deal == 0) return;
   if(!HistoryDealSelect(deal)) return;

   long magic = HistoryDealGetInteger(deal, DEAL_MAGIC);
   if(magic != InpMagic) return;

   long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_INOUT) return;

   string d_sym = HistoryDealGetString(deal, DEAL_SYMBOL);
   int si = -1;
   for(int i = 0; i < g_nsym; i++)
      if(g_syms[i].sym == d_sym) { si = i; break; }
   if(si < 0) return;

   double profit = HistoryDealGetDouble(deal, DEAL_PROFIT);
   double swap   = HistoryDealGetDouble(deal, DEAL_SWAP);
   double comm   = HistoryDealGetDouble(deal, DEAL_COMMISSION);
   double net    = profit + swap + comm;

   double price_out = HistoryDealGetDouble(deal, DEAL_PRICE);
   double pts = 0;
   if(g_syms[si].entry_price > 0)
      pts = (g_syms[si].entry_type == (int)ORDER_TYPE_BUY)
            ? (price_out - g_syms[si].entry_price) / g_syms[si].point
            : (g_syms[si].entry_price - price_out) / g_syms[si].point;

   g_daily_money   += net;
   g_daily_points  += pts;
   g_weekly_money  += net;
   g_monthly_money += net;
   g_annual_money  += net;
   g_trades_today++;
   g_syms[si].daily_money   += net;
   g_syms[si].daily_points  += pts;

   bool win = (net >= 0);
   if(win) { g_wins++; g_syms[si].wins++; }
   else    { g_losses++; g_syms[si].losses++; g_total_loss_money += MathAbs(net); }

   string side_str = (g_syms[si].entry_type == (int)ORDER_TYPE_BUY) ? "COMPRA" : "VENDA";
   PushRecent(g_syms[si].sym, side_str, net, pts, win);

   g_log.Append(LF_FILLS, StringFormat("%I64d;%s;%I64u;%s;%.2f;%.2f;%.1f;%.2f;%.1f",
      GetTickCount64(), g_syms[si].sym, deal, side_str, g_syms[si].pending_lots,
      net, pts, g_syms[si].daily_money, g_syms[si].daily_points));

   // motivo real da saida: o EA marca quando fecha por software; senao usa DEAL_REASON do servidor
   string why = g_syms[si].exit_reason;
   if(why == "" || why == "TP/SL servidor")
   {
      long dr = HistoryDealGetInteger(deal, DEAL_REASON);
      if(dr == DEAL_REASON_TP)       why = "TP_SERVIDOR";
      else if(dr == DEAL_REASON_SL)  why = "SL_SERVIDOR";
      else if(dr == DEAL_REASON_SO)  why = "STOP_OUT";
      else if(dr == DEAL_REASON_CLIENT || dr == DEAL_REASON_MOBILE || dr == DEAL_REASON_WEB)
                                     why = "MANUAL";
      else                           why = "OUTRO_" + IntegerToString((int)dr);
   }
   long dur = (g_syms[si].entry_time > 0) ? (long)(TimeCurrent() - g_syms[si].entry_time) : -1;
   g_log.Append(LF_TRADES, StringFormat("%I64d;%s;%s;%.2f;%s;%.*f;%.*f;%.2f;%.1f;%s;%I64d;%s",
      GetTickCount64(), g_syms[si].sym, side_str, g_syms[si].pending_lots,
      g_syms[si].entry_time > 0 ? TimeToString(g_syms[si].entry_time, TIME_DATE | TIME_SECONDS) : "",
      g_syms[si].digits, g_syms[si].entry_price, g_syms[si].digits, price_out,
      net, pts, win ? "WIN" : "LOSS", dur, why));

   SaveAggregates();

   g_syms[si].ticket = 0;
   g_syms[si].entry_price = 0;
   g_syms[si].entry_type = -1;
   g_syms[si].pending_lots = 0;
   g_syms[si].entry_time = 0;
   g_syms[si].exit_reason = "";
   g_syms[si].close_req_ms = 0;

   if(g_state == STATE_KILL_SWITCH) return;   // kill switch nao e desfeito por um fechamento

   if(InpBlockOnDailyTarget && g_daily_target > 0 && g_daily_money >= g_daily_target)
   {
      g_state = STATE_DAILY_TARGET_HIT;
      LogEvent("META_ATINGIDA", "EM POSICAO", "META ATINGIDA",
         StringFormat("net=%.2f target=%.2f", g_daily_money, g_daily_target));
      return;
   }

   bool any_open = false;
   for(int i = 0; i < g_nsym; i++)
      if(g_syms[i].ticket != 0) { any_open = true; break; }
   if(!any_open) g_state = STATE_IDLE;
}
//+------------------------------------------------------------------+