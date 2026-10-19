//+------------------------------------------------------------------+
//|                                             HFT_RETAIL.mq5       |
//|     HFT Retail v2.70 - v2.64 + SINAL DE TENDENCIA CORRIGIDO     |
//| v2.72: sessao em JANELAS de horario (relogio do servidor por    |
//| padrao): A 04-06 e B 15-18, escolhidas pelos logs (302 trades)  |
//| e pelo M1 do ouro; sem entradas novas nos minutos finais; opcao |
//| de fechar a posicao no fim da janela (DESLIGADA: nao muda a     |
//| regra "sem fechamento forcado"); painel com hora LOCAL, janela, |
//| tempo restante e textos que quebram linha. Modo antigo (blocos  |
//| GMT) continua em InpSessionMode. Logica do sinal NAO mudou.     |
//| v2.71: filtro de atividade (mercado parado) desligavel; adota a  |
//| posicao aberta ao recarregar o EA; trades.csv (schema v26) com   |
//| MAE/MFE em pontos, faixa e spread na entrada; entrada/duracao    |
//| lidas do historico (corrige linhas inconsistentes); alerta de    |
//| posicao presa (so aviso, NAO fecha); PARAMS no CSV de eventos.   |
//| Sem SL e sem fechamento forcado.                                 |
//| v2.70: a regressao da micro-tendencia estava INVERTIDA (x=0 era |
//| o tick mais novo): alta virava BAIXA e vice-versa, e o voto de  |
//| momentum entrava contra o movimento. Corrigido (x cronologico). |
//| Magic novo (20261007), aggregates e CSV separados da v2.64 para |
//| rodar lado a lado e comparar. Nada mais do ensemble mudou.      |
//| v2.5: TP/SL em dinheiro fecha de fato; kill switch vigia posicao |
//| aberta e fecha; sessao em GMT real; motivo de bloqueio visivel;  |
//| CSV schema v25 (hora do servidor, trades completos, sem spam).   |
//| Logica do sinal (ensemble) NAO foi alterada.                     |
//+------------------------------------------------------------------+
#property copyright "HFT Retail v2.70"
#property version   "2.72"
#define EA_VERSION  "v2.72"
#define CSV_SCHEMA  "v26"
#define PANEL_W     480      // largura do painel (px)
#property strict

#include <Trade/Trade.mqh>
#include <LZ/LZPanel.mqh>

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
enum ENUM_SESSION_MODE  { SESSAO_JANELAS = 0, SESSAO_BLOCOS_GMT = 1 };         // como a sessao e definida
enum ENUM_SESSION_CLOCK { SESSION_CLOCK_SERVER = 0, SESSION_CLOCK_GMT = 1 };   // relogio das janelas
enum ENUM_LOGFILE
{
   LF_EVENTS, LF_TICKS, LF_DECISIONS, LF_ORDERS, LF_FILLS,
   LF_PANEL,  LF_METRICS, LF_GATE, LF_DOM, LF_TRADES, LF_COUNT
};

//==================================================================
// INPUTS  (todos em português)
//==================================================================
input group "═══ Geral ═══"
input long   InpMagic               = 20261007;   // Número Mágico (ID único do EA)

input group "═══ Símbolos ═══"
input string InpSymbols             = "XAUUSD";   // Símbolos separados por ;

input group "═══ Validação Inicial (Gate) ═══"
input bool   InpUseGate             = true;       // Ativar amostragem inicial do símbolo
input bool   InpGateStrictMode      = false;      // Modo estrito: reprova símbolo e bloqueia
input int    InpGateSeconds         = 30;         // Duração da amostragem (segundos)
input double InpGateMaxAvgSpread    = 50.0;       // Spread médio máximo (pontos)
input int    InpGateMinTicks        = 10;         // Mínimo de ticks na amostragem

input group "═══ Sessão: janelas de horário (v2.72) ═══"
input ENUM_SESSION_MODE  InpSessionMode = SESSAO_JANELAS;      // JANELAS (A/B abaixo) ou BLOCOS_GMT (modo antigo, grupo seguinte)
input ENUM_SESSION_CLOCK InpSessionClock = SESSION_CLOCK_SERVER; // Relogio das janelas: hora do SERVIDOR (padrao) ou GMT
input bool   InpUseWindowA          = true;       // [true/false] Janela A (abertura asiatica: melhor faixa nos logs)
input int    InpWindowAStartHour    = 4;          // Janela A: inicio (hora cheia, inclusive 0..23) - lida se a janela estiver true
input int    InpWindowAEndHour      = 6;          // Janela A: fim (hora cheia, exclusive 0..24; inicio > fim cruza a meia-noite)
input bool   InpUseWindowB          = true;       // [true/false] Janela B (abertura/dados dos EUA: alvo rapido, risco de contra-movimento)
input int    InpWindowBStartHour    = 15;         // Janela B: inicio (hora cheia, inclusive 0..23) - lida se a janela estiver true
input int    InpWindowBEndHour      = 18;         // Janela B: fim (hora cheia, exclusive 0..24)
input bool   InpUseNoNewBeforeEnd   = true;       // [true/false] Sem entradas novas nos minutos finais da janela
input int    InpNoNewMinBeforeEnd   = 5;          // Minutos finais sem entrada nova - lido se true
input bool   InpUseFlattenAtEnd     = false;      // [true/false] No FIM da janela fecha a posicao aberta a mercado (realiza lucro OU perda; padrao false = so o TP fecha)

input group "═══ Sessão: blocos GMT (só no modo BLOCOS_GMT) ═══"
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
input double InpMaxSpreadPctOfTP    = 0.0;        // Spread máx. como % do TP em pontos (0 = desligado). Alinha o filtro ao alvo

input group "═══ Filtro de Atividade (mercado parado) ═══"
input bool   InpUseActivityFilter   = true;       // [true/false] Só entra se o mercado estiver se mexendo (parado = preso por horas)
input int    InpActWindowSec        = 120;        // Janela da faixa (s), 10..1800
input double InpActMinRangePts      = 150.0;      // Faixa mínima (máx-mín do preço na janela, pontos) - lida se true

input group "═══ Alerta de Posição Presa (só aviso, não fecha nada) ═══"
input int    InpStuckAlertSec       = 300;        // Avisa quando a posição passa de x s aberta...
input double InpStuckAlertPts       = 1000.0;     // ...e está no prejuízo de pelo menos x pontos

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

input group "═══ Contexto M15 (SÓ PAINEL - não altera entradas) ═══"
input int    InpM15Bars             = 8;          // Velas M15 fechadas usadas na direção
input double InpM15MinER            = 0.35;       // Eficiência mínima p/ ALTA/BAIXA (senão LATERAL)

input group "═══ Painel (LZ Design System) ═══"
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
// PALETA - aliases do LZ Design System (Include/LZ/LZPanel.mqh)
//==================================================================
#define CLR_ACCENT    LZ_ACCENT
#define CLR_PROFIT    LZ_PROFIT
#define CLR_LOSS      LZ_LOSS
#define CLR_WARN      LZ_WARN
#define CLR_GOLD      LZ_GOLD
#define CLR_TEXT      LZ_TEXT
#define CLR_TEXT_DIM  LZ_MUTED

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
      m_header[LF_TRADES]    = "ts_ms;symbol;side;lots;entry_time;entry_price;exit_price;money;pts;win;duration_s;exit_reason;mae_pts;mfe_pts;range_entry_pts;spread_entry_pts";
   }

   // Toda linha ganha 'time_server' (hora do servidor) como 1a coluna.
   // Pasta com versao do schema: logs antigos (v2.4) ficam intactos em HFT_Logs\<data>.
   string Root()   { return "HFT_Logs\\" + CSV_SCHEMA + "_m" + IntegerToString(InpMagic); }
   string DayDir() { return Root() + "\\" + m_dir; }

   void RollIfNeeded()
   {
      MqlDateTime t; TimeToStruct(TimeCurrent(), t);
      string today = StringFormat("%04d-%02d-%02d", t.year, t.mon, t.day);
      if(m_dir == today) return;

      FlushAll();

      string subs[3];
      subs[0] = "HFT_Logs";
      subs[1] = Root();
      subs[2] = Root() + "\\" + today;
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
         Print("[HFT] CSVs em: <terminal>\\MQL5\\Files\\HFT_Logs\\", CSV_SCHEMA, "_m", IntegerToString(InpMagic), "\\<data>\\");
      else
         Print("[HFT] CSVs em: <AppData>\\MetaQuotes\\Terminal\\Common\\Files\\HFT_Logs\\", CSV_SCHEMA, "_m", IntegerToString(InpMagic), "\\<data>\\");
   }
};

CLogHub g_log;

//==================================================================
// CONTEXTO POR SIMBOLO
//==================================================================
#define TICK_BUF 256
#define ACT_BUCKETS 1800

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
   // v2.71: atividade, excursao da posicao e alerta de presa
   double   sec_hi[ACT_BUCKETS], sec_lo[ACT_BUCKETS];
   datetime sec_t[ACT_BUCKETS];
   datetime first_tick_t;
   double   mae_pts, mfe_pts, cur_pts, range_entry, spread_entry;
   long     age_s;
   ulong    last_status_ms;

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
      ArrayInitialize(sec_hi, 0); ArrayInitialize(sec_lo, 0); ArrayInitialize(sec_t, 0);
      first_tick_t = 0;
      ResetExcursion();
      range_entry = 0; spread_entry = 0; last_status_ms = 0;
   }

   void ResetExcursion() { mae_pts = 0; mfe_pts = 0; cur_pts = 0; age_s = 0; }

   // faixa (maxima - minima do preco medio) dos ultimos 'win' segundos, em pontos
   double RangePts(int win, datetime now, bool &ready)
   {
      win = (int)MathMax(10, MathMin(win, ACT_BUCKETS - 1));
      double hi = -1e18, lo = 1e18;
      datetime t0 = now - win;
      for(int k = 0; k < ACT_BUCKETS; k++)
      {
         if(sec_t[k] == 0 || sec_t[k] < t0 || sec_t[k] > now) continue;
         if(sec_hi[k] > hi) hi = sec_hi[k];
         if(sec_lo[k] < lo) lo = sec_lo[k];
      }
      ready = (first_tick_t != 0 && now - first_tick_t >= win);
      return (hi >= lo && point > 0) ? (hi - lo) / point : 0;
   }

   void UpdateActivity(datetime t, double mid)
   {
      if(first_tick_t == 0) first_tick_t = t;
      int k = (int)(t % ACT_BUCKETS);
      if(sec_t[k] != t) { sec_t[k] = t; sec_hi[k] = mid; sec_lo[k] = mid; }
      else { if(mid > sec_hi[k]) sec_hi[k] = mid; if(mid < sec_lo[k]) sec_lo[k] = mid; }
   }

   // excursao da posicao aberta (MAE/MFE em pontos) + alerta de presa (so aviso)
   void TrackPosition()
   {
      if(ticket == 0 || !PositionSelectByTicket(ticket)) return;
      if(PositionGetString(POSITION_SYMBOL) != sym) return;
      MqlTick tk; if(!SymbolInfoTick(sym, tk) || point <= 0) return;
      bool buy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      double po = PositionGetDouble(POSITION_PRICE_OPEN);
      cur_pts = buy ? (tk.bid - po) / point : (po - tk.ask) / point;
      if(cur_pts < mae_pts) mae_pts = cur_pts;
      if(cur_pts > mfe_pts) mfe_pts = cur_pts;
      age_s = (long)(TimeCurrent() - (datetime)PositionGetInteger(POSITION_TIME));
      if(InpStuckAlertSec > 0 && age_s >= InpStuckAlertSec && cur_pts <= -InpStuckAlertPts &&
         GetTickCount64() - last_status_ms >= 60000)
      {
         last_status_ms = GetTickCount64();
         g_log.Append(LF_EVENTS, StringFormat("%I64d;POS_PRESA;-;%s;ticket=%I64u lado=%s idade=%I64ds flut=%.0fpts (%.2f) pior=%.0fpts melhor=%.0fpts",
            GetTickCount64(), sym, ticket, buy ? "COMPRA" : "VENDA", age_s, cur_pts,
            PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP), mae_pts, mfe_pts));
      }
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
      UpdateActivity(tk.time, mid);

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
         // MidPrice(i) = i ticks ATRAS. x precisa ser cronologico (antigo=0 ... novo=n-1);
         // na v2.64 x=i fazia slope>0 significar "preco caindo" (tendencia invertida).
         double x = (double)(n - 1 - i);
         double y = MidPrice(i);
         sx += x; sy += y; sxy += x * y; sxx += x * x;
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

CLZPanel g_panel;

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

// Sessao. Modo JANELAS (padrao v2.72): janelas A/B em hora cheia, no relogio do servidor (ou GMT).
// Modo BLOCOS_GMT: regra antiga (Londres/NY/Asia/rollover em GMT real via TimeGMT).
datetime ClockNow() { return (InpSessionClock == SESSION_CLOCK_GMT) ? TimeGMT() : TimeCurrent(); }

int ClockMinuteOfDay()
{
   MqlDateTime d; TimeToStruct(ClockNow(), d);
   return d.hour * 60 + d.min;
}

// diferenca (min) entre a hora LOCAL do PC e o relogio das janelas, arredondada a 30 min (absorve atraso de tick)
int ClockToLocalMin()
{
   double m = (double)(TimeLocal() - ClockNow()) / 60.0;
   return (int)(MathRound(m / 30.0) * 30.0);
}

string HHMM(const int minutes)
{
   int t = ((minutes % 1440) + 1440) % 1440;
   return StringFormat("%02d:%02d", t / 60, t % 60);
}

string DurTxt(const int minutes)
{
   if(minutes >= 60) return StringFormat("%dh%02d", minutes / 60, minutes % 60);
   return StringFormat("%d min", minutes);
}

// janela w (0 = A, 1 = B): ligada, inicio e fim em minutos do dia
bool WindowCfg(const int w, int &ws, int &we)
{
   bool on = (w == 0) ? InpUseWindowA : InpUseWindowB;
   ws = ((w == 0) ? InpWindowAStartHour : InpWindowBStartHour) * 60;
   we = ((w == 0) ? InpWindowAEndHour   : InpWindowBEndHour)   * 60;
   return on;
}

// minutos ate o fim da janela em que estamos (-1 = fora de qualquer janela)
int WindowMinutesLeft(string &name)
{
   name = "";
   int t = ClockMinuteOfDay(), best = -1;
   for(int w = 0; w < 2; w++)
   {
      int ws, we;
      if(!WindowCfg(w, ws, we)) continue;
      bool inside = (ws < we) ? (t >= ws && t < we) : (t >= ws || t < we);
      if(!inside) continue;
      int left = (ws < we) ? (we - t) : ((t >= ws) ? (1440 - t + we) : (we - t));
      if(left > best) { best = left; name = (w == 0) ? "A" : "B"; }
   }
   return best;
}

// minutos ate a proxima abertura de janela (usado fora das janelas)
int MinutesToNextWindow(string &name)
{
   name = "";
   int t = ClockMinuteOfDay(), best = 100000;
   for(int w = 0; w < 2; w++)
   {
      int ws, we;
      if(!WindowCfg(w, ws, we)) continue;
      int dd = ((ws - t) % 1440 + 1440) % 1440;
      if(dd == 0) dd = 1440;
      if(dd < best) { best = dd; name = (w == 0) ? "A" : "B"; }
   }
   return best;
}

bool InWindowsNow()
{
   string n;
   return (WindowMinutesLeft(n) >= 0);
}

// ultimos minutos da janela: sem entradas novas
bool SessionEnding()
{
   if(InpSessionMode != SESSAO_JANELAS || !InpUseNoNewBeforeEnd) return false;
   string n;
   int left = WindowMinutesLeft(n);
   return (left >= 0 && left <= InpNoNewMinBeforeEnd);
}

// fim da janela com a opcao de fechar ligada
bool FlattenDue()
{
   return (InpSessionMode == SESSAO_JANELAS && InpUseFlattenAtEnd && !InWindowsNow());
}

string SessionWindowsText()
{
   string r = "";
   if(InpUseWindowA) r += StringFormat("A %02d-%02d", InpWindowAStartHour, InpWindowAEndHour);
   if(InpUseWindowB) r += (r != "" ? ", " : "") + StringFormat("B %02d-%02d", InpWindowBStartHour, InpWindowBEndHour);
   if(r == "") r = "nenhuma";
   return r + (InpSessionClock == SESSION_CLOCK_GMT ? " GMT" : " srv");
}

// valida as janelas; "" = ok
string SessionValidate()
{
   if(InpSessionMode != SESSAO_JANELAS) return "";
   if(!InpUseWindowA && !InpUseWindowB) return "modo JANELAS exige ao menos uma janela ligada (A ou B)";
   if(InpUseWindowA && (InpWindowAStartHour < 0 || InpWindowAStartHour > 23 || InpWindowAEndHour < 0 || InpWindowAEndHour > 24 || InpWindowAStartHour == InpWindowAEndHour))
      return "janela A: inicio 0..23, fim 0..24 e inicio diferente do fim";
   if(InpUseWindowB && (InpWindowBStartHour < 0 || InpWindowBStartHour > 23 || InpWindowBEndHour < 0 || InpWindowBEndHour > 24 || InpWindowBStartHour == InpWindowBEndHour))
      return "janela B: inicio 0..23, fim 0..24 e inicio diferente do fim";
   if(InpUseNoNewBeforeEnd && InpNoNewMinBeforeEnd <= 0) return "sem entradas no fim da janela, ligado, exige InpNoNewMinBeforeEnd > 0";
   return "";
}

bool IsSessionAllowed(string &reason)
{
   if(InpSessionMode == SESSAO_JANELAS)
   {
      if(!InWindowsNow()) { reason = "sessao: fora das janelas (" + SessionWindowsText() + ")"; return false; }
      if(SessionEnding())
      { reason = StringFormat("sessao: ultimos %d min da janela, sem entradas novas", InpNoNewMinBeforeEnd); return false; }
      return true;
   }
   // modo antigo: blocos em GMT real
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
string AggFile() { return "HFT_Logs\\aggregates_" + IntegerToString(InpMagic) + ".csv"; }

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
// PAINEL (LZ Design System) - estado > decisao > posicao > risco > telemetria
//==================================================================
double CurrentDrawdownPct();   // definida na secao RISCO

// Direção do M15 SOMENTE para exibição. Serie cronologica: N fechamentos M15 + preco atual.
// ER (eficiencia) = |deslocamento liquido| / soma dos movimentos; baixa = vai e volta (lateral).
ENUM_TREND g_m15_dir = TREND_SIDE;
double     g_m15_er = 0, g_m15_move = 0;
bool       g_m15_ok = false;

void UpdateM15()
{
   if(g_nsym <= 0) { g_m15_ok = false; return; }
   string s = g_syms[0].sym;
   int n = MathMax(3, InpM15Bars);
   double c[];
   ArraySetAsSeries(c, true);                       // c[0] = ultima vela fechada
   if(CopyClose(s, PERIOD_M15, 1, n, c) != n) { g_m15_ok = false; return; }
   MqlTick tk; if(!SymbolInfoTick(s, tk)) { g_m15_ok = false; return; }
   double mid = (tk.bid + tk.ask) * 0.5;

   double prev = c[n - 1], path = 0;
   for(int i = n - 2; i >= 0; i--) { path += MathAbs(c[i] - prev); prev = c[i]; }
   path += MathAbs(mid - prev);
   double net = mid - c[n - 1];

   g_m15_er = (path > 0) ? MathAbs(net) / path : 0;
   g_m15_move = net / g_syms[0].point;
   if(g_m15_er >= InpM15MinER) g_m15_dir = (net > 0) ? TREND_UP : TREND_DOWN;
   else                        g_m15_dir = TREND_SIDE;
   g_m15_ok = true;
}

// faixa de decisao com quebra de linha por palavras: nada fica cortado
// capacidade (chars) = largura da faixa - recuo do texto (depende do rotulo) - folga, a 7 px por char
void StripWrap(const string label, const string text, const color clr)
{
   int cap = (PANEL_W - 12 - 6 - (StringLen(label) + 1) * 6 - 14) / 7;
   if(cap < 12) cap = 12;
   string pad = "";
   for(int i = 0; i < StringLen(label); i++) pad += " ";
   string rest = text;
   bool first = true;
   while(StringLen(rest) > 0)
   {
      string line = rest;
      if(StringLen(rest) > cap)
      {
         int cut = cap;
         while(cut > 0 && StringGetCharacter(rest, cut) != 32) cut--;
         if(cut <= 0) cut = cap;
         line = StringSubstr(rest, 0, cut);
         rest = StringSubstr(rest, cut);
         while(StringLen(rest) > 0 && StringGetCharacter(rest, 0) == 32) rest = StringSubstr(rest, 1);
      }
      else rest = "";
      g_panel.Strip(first ? label : pad, line, clr);
      first = false;
   }
}

void DrawPanel()
{
   if(!InpShowPanel) return;

   string sym = (g_nsym > 0) ? g_syms[0].sym : "-";
   double sp = 0;
   MqlTick tk0;
   if(g_nsym > 0 && SymbolInfoTick(sym, tk0)) sp = (tk0.ask - tk0.bid) / g_syms[0].point;

   g_panel.Begin();
   g_panel.Header("LZ TRADING  //  HFT RETAIL " + EA_VERSION,
      StringFormat("%s  spread %.1f pt  dia %s %+.2f", sym, sp, g_ccy, g_daily_money),
      StateToStr(g_state), StateColor(g_state));

   if(g_panel.Expanded())
   {
      // --- DECISAO: por que opera / nao opera (informacao critica, sempre visivel)
      if(g_state == STATE_KILL_SWITCH || g_state == STATE_ERROR)
         StripWrap("PARADO", g_block_reason, LZ_LOSS);
      else if(g_state == STATE_DAILY_TARGET_HIT)
         StripWrap("META", g_block_reason, LZ_GOLD);
      else if(g_state == STATE_IN_POSITION || g_state == STATE_EXITING || g_state == STATE_ENTERING)
         StripWrap("POSICAO", g_block_reason, LZ_INFO);
      else if(g_block_reason != "")
         StripWrap("BLOQUEIO", g_block_reason, LZ_WARN);
      else
         g_panel.Strip("ARMADO", "liberado, aguardando sinal", LZ_PROFIT);

      // --- alerta: posicao aberta fora da janela
      if(InpSessionMode == SESSAO_JANELAS && !InWindowsNow())
         for(int i = 0; i < g_nsym; i++)
            if(g_syms[i].ticket != 0 && PositionSelectByTicket(g_syms[i].ticket))
            {
               double fp = g_syms[i].PositionPnLMoney();
               StripWrap("ATENCAO", StringFormat("posicao aberta FORA da janela, flutuante %s %+.2f%s", g_ccy, fp,
                         InpUseFlattenAtEnd ? " - fechando agora" : " - fechamento no fim DESLIGADO (segue ate o TP)"),
                         InpUseFlattenAtEnd ? LZ_WARN : LZ_LOSS);
               break;
            }

      // --- HORARIO
      g_panel.Section("HORARIO");
      MqlDateTime hs, hl;
      TimeToStruct(TimeCurrent(), hs); TimeToStruct(TimeLocal(), hl);
      g_panel.KV2("HORA LOCAL", StringFormat("%02d:%02d:%02d", hl.hour, hl.min, hl.sec), LZ_ACCENT,
                  "SERVIDOR", StringFormat("%02d:%02d:%02d", hs.hour, hs.min, hs.sec), LZ_TEXT);
      if(InpSessionMode == SESSAO_JANELAS)
      {
         int toLoc = ClockToLocalMin();
         string wn = "";
         int wleft = WindowMinutesLeft(wn);
         if(wleft >= 0)
            g_panel.KV("JANELA", StringFormat("DENTRO (%s)  faltam %s", wn, DurTxt(wleft)), SessionEnding() ? LZ_WARN : LZ_PROFIT);
         else
         {
            string nn = "";
            int mn = MinutesToNextWindow(nn);
            g_panel.KV("JANELA", StringFormat("FORA  proxima %s em %s", nn, DurTxt(mn)), LZ_MUTED);
         }
         for(int w = 0; w < 2; w++)
         {
            int ws, we;
            if(!WindowCfg(w, ws, we)) continue;
            g_panel.KV(w == 0 ? "JANELA A" : "JANELA B",
                       StringFormat("%s-%s %s | %s-%s loc", HHMM(ws), HHMM(we), InpSessionClock == SESSION_CLOCK_GMT ? "GMT" : "srv", HHMM(ws + toLoc), HHMM(we + toLoc)), LZ_TEXT);
         }
         g_panel.KV2("FIM DA JANELA", InpUseFlattenAtEnd ? "FECHA POSICAO" : "SO O TP FECHA", InpUseFlattenAtEnd ? LZ_WARN : LZ_TEXT,
                     "SEM NOVAS", InpUseNoNewBeforeEnd ? StringFormat("ult. %d min", InpNoNewMinBeforeEnd) : "OFF", LZ_TEXT);
      }
      else
         g_panel.KV("SESSAO", StringFormat("blocos GMT: L%d NY%d AS%d roll%d", InpTradeLondon, InpTradeNY, InpTradeAsia, InpBlockRollover), LZ_TEXT);

      // --- MERCADO
      ENUM_TREND tr = (g_nsym > 0) ? g_syms[0].trend : TREND_SIDE;
      double ofi_v = (g_nsym > 0) ? g_syms[0].ofi : 0;
      double imb_v = (g_nsym > 0) ? g_syms[0].dom_imb : 0;
      string gate_str = "--"; color gate_clr = LZ_MUTED;
      if(g_nsym > 0)
      {
         if(!g_syms[0].gate_done)       { gate_str = "AMOSTRANDO"; gate_clr = LZ_WARN; }
         else if(g_syms[0].gate_passed) { gate_str = "OK";         gate_clr = LZ_PROFIT; }
         else                           { gate_str = "REPROVADO";  gate_clr = LZ_LOSS; }
      }
      g_panel.Section("MERCADO");
      g_panel.KV2("MICRO TICKS", TrendArrow(tr) + " " + TrendToStr(tr), TrendColor(tr),
                  "OFI", StringFormat("%+.2f", ofi_v), (ofi_v >= 0) ? LZ_PROFIT : LZ_LOSS);
      if(g_m15_ok)
         g_panel.KV2("M15", TrendArrow(g_m15_dir) + " " + TrendToStr(g_m15_dir), TrendColor(g_m15_dir),
                     "ER / MOVE", StringFormat("%.2f / %+.0f pt", g_m15_er, g_m15_move), LZ_TEXT);
      else
         g_panel.KV("M15", "sem dados", LZ_MUTED);
      g_panel.KV2("IMB DOM", StringFormat("%+.2f", imb_v), (imb_v >= 0) ? LZ_PROFIT : LZ_LOSS,
                  "GATE", gate_str, gate_clr);
      if(g_nsym > 0)
      {
         bool a_ok = false;
         double a_rg = g_syms[0].RangePts(InpActWindowSec, TimeCurrent(), a_ok);
         if(!InpUseActivityFilter)
            g_panel.KV("ATIVIDADE", StringFormat("faixa %ds = %.0f pt (filtro OFF)", InpActWindowSec, a_rg), LZ_MUTED);
         else if(!a_ok)
            g_panel.KV("ATIVIDADE", "aquecendo a janela", LZ_WARN);
         else
            g_panel.KV("ATIVIDADE", StringFormat("faixa %ds = %.0f / min %.0f pt", InpActWindowSec, a_rg, InpActMinRangePts),
                       a_rg >= InpActMinRangePts ? LZ_PROFIT : LZ_WARN);
      }

      // --- POSICAO
      int oi = -1;
      for(int i = 0; i < g_nsym; i++)
         if(g_syms[i].ticket != 0 && PositionSelectByTicket(g_syms[i].ticket)) { oi = i; break; }
      g_panel.Section("POSICAO");
      if(oi >= 0)
      {
         bool buy = (g_syms[oi].entry_type == (int)ORDER_TYPE_BUY);
         double pnl = g_syms[oi].PositionPnLMoney();
         g_panel.KV2("LADO", buy ? "COMPRA" : "VENDA", buy ? LZ_PROFIT : LZ_LOSS,
                     "VOLUME", StringFormat("%.2f", g_syms[oi].pending_lots), LZ_TEXT);
         g_panel.KV2("P&L", StringFormat("%s %+.2f", g_ccy, pnl), (pnl >= 0) ? LZ_PROFIT : LZ_LOSS,
                     "TP", StringFormat("%s %.2f", g_ccy, g_syms[oi].tp_money), LZ_GOLD);
         bool presa = (InpStuckAlertSec > 0 && g_syms[oi].age_s >= InpStuckAlertSec && g_syms[oi].cur_pts <= -InpStuckAlertPts);
         g_panel.KV2("FLUTUANTE", StringFormat("%+.0f pt", g_syms[oi].cur_pts), g_syms[oi].cur_pts >= 0 ? LZ_PROFIT : (presa ? LZ_LOSS : LZ_WARN),
                     "PIOR (MAE)", StringFormat("%+.0f pt", g_syms[oi].mae_pts), g_syms[oi].mae_pts <= -InpStuckAlertPts ? LZ_LOSS : LZ_TEXT);
         long ag = g_syms[oi].age_s;
         g_panel.KV2("TEMPO ABERTA", ag >= 3600 ? StringFormat("%dh%02dm", (int)(ag / 3600), (int)((ag % 3600) / 60))
                                                : StringFormat("%dm%02ds", (int)(ag / 60), (int)(ag % 60)), presa ? LZ_LOSS : LZ_TEXT,
                     "STATUS", presa ? "PRESA" : "normal", presa ? LZ_LOSS : LZ_MUTED);
      }
      else
         g_panel.KV("ABERTA", "flat", LZ_MUTED);

      // --- RISCO
      double tgt = (g_daily_target > 0) ? g_daily_target : InpDailyTargetMoney;
      double pct = (tgt > 0) ? 100.0 * g_daily_money / tgt : 0;
      double dd  = CurrentDrawdownPct();
      color  ddc = !InpUseKillSwitch ? LZ_MUTED :
                   (dd >= InpKillSwitchDrawdownPct * 0.5 ? LZ_WARN : LZ_TEXT);
      g_panel.Section("RISCO");
      g_panel.Bar("META DO DIA", StringFormat("%s %+.2f / %.2f", g_ccy, g_daily_money, tgt),
                  pct, (g_daily_money >= 0) ? LZ_GOLD : LZ_LOSS);
      g_panel.KV2("DD DO EA", StringFormat("%.2f%%", dd), ddc,
                  "KILL SWITCH", InpUseKillSwitch ? StringFormat("%.1f%%", InpKillSwitchDrawdownPct) : "OFF",
                  InpUseKillSwitch ? LZ_TEXT : LZ_WARN);
      g_panel.KV2("STOP LOSS", InpUseStopLoss ? StringFormat("%s %.2f", g_ccy, InpSL_MoneyPerTrade) : "SEM SL",
                  InpUseStopLoss ? LZ_TEXT : LZ_WARN,
                  "PERDA MAX/DIA", InpUseMaxDailyLoss ? StringFormat("%s %.2f", g_ccy, InpMaxDailyLossMoney) : "OFF",
                  InpUseMaxDailyLoss ? LZ_TEXT : LZ_MUTED);

      // --- DESEMPENHO
      int total = g_wins + g_losses;
      double hit = (total > 0) ? 100.0 * g_wins / total : 0;
      color hitc = (total == 0) ? LZ_MUTED : (hit >= 60 ? LZ_PROFIT : (hit >= 40 ? LZ_WARN : LZ_LOSS));
      g_panel.Section("DESEMPENHO HOJE");
      g_panel.KV2("W / L", StringFormat("%d / %d", g_wins, g_losses), LZ_TEXT,
                  "ACERTO", StringFormat("%.1f%%", hit), hitc);
      g_panel.KV2("SEMANA", StringFormat("%+.2f", g_weekly_money), (g_weekly_money >= 0) ? LZ_PROFIT : LZ_LOSS,
                  "MES", StringFormat("%+.2f", g_monthly_money), (g_monthly_money >= 0) ? LZ_PROFIT : LZ_LOSS);

      // --- TELEMETRIA
      g_panel.Section("TELEMETRIA");
      if(g_recent_n > 0)
         g_panel.KV("ULTIMO TRADE",
            StringFormat("%s %s %s %+.2f", TimeToString(g_recent[0].time, TIME_MINUTES),
               g_recent[0].sym, g_recent[0].side, g_recent[0].money),
            g_recent[0].win ? LZ_PROFIT : LZ_LOSS);
      else
         g_panel.KV("ULTIMO TRADE", "nenhum ainda", LZ_MUTED);
      g_panel.KV2("CSV", CSV_SCHEMA, LZ_TEXT,
                  "SERVIDOR", TimeToString(TimeCurrent(), TIME_SECONDS), LZ_ACCENT);
   }
   g_panel.End();
}

//==================================================================
// TRADE
//==================================================================
// TP em pontos efetivo (mesma regra do ComputeTPandSL), para alinhar filtros ao alvo
double TpPoints(CSymbolContext &ctx)
{
   if(InpTP_UsePointsInstead && InpTP_PointsPerTrade > 0) return InpTP_PointsPerTrade;
   if(InpTP_MoneyPerTrade > 0) return ctx.MoneyToPoints(NormVol(ctx.sym, InpFixedLots), InpTP_MoneyPerTrade);
   return 0;
}

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

// TP/SL sao calculados sobre a cotacao; o fill sai alguns pontos diferente (ouro rapido).
// Recalcula sobre o preco real de entrada e corrige no servidor. Falhou? Mantem o original
// (o TP em dinheiro por software continua valendo).
void ReanchorToFill(CSymbolContext &ctx, ENUM_ORDER_TYPE type, double lots)
{
   if(ctx.entry_price <= 0) return;
   double tp = 0, sl = 0, tpm = 0, slm = 0;
   ComputeTPandSL(ctx, (int)type, ctx.entry_price, lots, tp, sl, tpm, slm);
   if(MathAbs(tp - ctx.tp_price) < ctx.point * 0.5 && MathAbs(sl - ctx.sl_price) < ctx.point * 0.5) return;

   // respeita stops level contra o preco atual de fechamento
   MqlTick tk; if(!SymbolInfoTick(ctx.sym, tk)) return;
   double close_px = (type == ORDER_TYPE_BUY) ? tk.bid : tk.ask;
   double min_dist = (double)SymbolInfoInteger(ctx.sym, SYMBOL_TRADE_STOPS_LEVEL) * ctx.point;
   if(tp > 0 && MathAbs(tp - close_px) < min_dist) return;
   if(sl > 0 && MathAbs(sl - close_px) < min_dist) return;

   if(g_trade.PositionModify(ctx.ticket, sl, tp))
   {
      LogEvent("TP_REANCORADO", "EM POSICAO", "EM POSICAO",
         StringFormat("%s fill=%.*f tp %.*f->%.*f sl %.*f->%.*f", ctx.sym, ctx.digits, ctx.entry_price,
            ctx.digits, ctx.tp_price, ctx.digits, tp, ctx.digits, ctx.sl_price, ctx.digits, sl));
      ctx.tp_price = tp; ctx.sl_price = sl;
   }
   else
      LogEvent("TP_REANCORAR_FALHOU", "EM POSICAO", "EM POSICAO",
         ctx.sym + ": rc=" + IntegerToString((int)g_trade.ResultRetcode()) + " mantido TP da cotacao");
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
      ctx.ResetExcursion();
      ReanchorToFill(ctx, type, lots);
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
   string prev_reason = ctx.exit_reason;
   ctx.exit_reason = reason;
   bool ok = g_trade.PositionClose(ctx.ticket, InpSlippagePoints);
   uint rc = g_trade.ResultRetcode();
   if(ok)
   {
      LogEvent("POSITION_CLOSE", "SAINDO", "OCIOSO", ctx.sym + ": " + reason + " rc=" + IntegerToString((int)rc));
      return true;   // ticket permanece ate o DEAL de saida chegar em OnTradeTransaction
   }
   // falhou: o motivo NAO vale (v2.5 gravava TP_MONEY mesmo quando quem fechou era o TP do servidor)
   ctx.exit_reason = prev_reason;
   // 10029 = posicao congelada (perto do TP/SL do servidor); 10036 = ja fechada. O servidor esta agindo: nao e erro.
   if(rc == TRADE_RETCODE_FROZEN || rc == TRADE_RETCODE_POSITION_CLOSED)
   {
      LogEvent("CLOSE_DEFERRED", "SAINDO", "OCIOSO",
         ctx.sym + ": " + reason + " adiado, servidor ja agindo rc=" + IntegerToString((int)rc));
      return true;
   }
   LogEvent("CLOSE_FAILED", "SAINDO", "OCIOSO",
      ctx.sym + ": " + reason + " rc=" + IntegerToString((int)rc) + " " + g_trade.ResultRetcodeDescription());
   ctx.close_req_ms = 0;   // erro real: tenta de novo no proximo tick
   return false;
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
// Flutuante SO das posicoes deste EA (magic + simbolos configurados). A conta pode ter
// posicoes de outros EAs/manuais: usar equity da conta fazia o kill switch reagir ao que nao e nosso.
double OwnFloatingMoney()
{
   double sum = 0;
   for(int k = PositionsTotal() - 1; k >= 0; k--)
   {
      ulong tk = PositionGetTicket(k);
      if(tk == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      sum += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return sum;
}

// Drawdown do EA = perda flutuante propria / saldo (0 quando ha lucro flutuante)
double CurrentDrawdownPct()
{
   double bl = AccountInfoDouble(ACCOUNT_BALANCE);
   double fl = OwnFloatingMoney();
   return (bl > 0 && fl < 0) ? 100.0 * (-fl) / bl : 0;
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
   string sess_err = SessionValidate();
   if(sess_err != "") { Print("[HFT] ", sess_err); return INIT_FAILED; }

   g_ccy = AccountInfoString(ACCOUNT_CURRENCY);
   g_panel.Init("LZP_HFT" + IntegerToString(InpMagic) + "_", InpPanelX, InpPanelY, PANEL_W);

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

   // v2.71: posicao ja aberta deste magic (EA recarregado) e adotada; sem isso o EA abria outra por cima
   // e a saida da antiga entrava no CSV sem entrada/lote
   bool adotou = false;
   for(int i = 0; i < g_nsym; i++)
   {
      for(int k = PositionsTotal() - 1; k >= 0; k--)
      {
         ulong pt = PositionGetTicket(k);
         if(pt == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != g_syms[i].sym || PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
         g_syms[i].ticket       = pt;
         g_syms[i].entry_price  = PositionGetDouble(POSITION_PRICE_OPEN);
         g_syms[i].entry_type   = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? (int)ORDER_TYPE_BUY : (int)ORDER_TYPE_SELL;
         g_syms[i].entry_time   = (datetime)PositionGetInteger(POSITION_TIME);
         g_syms[i].pending_lots = PositionGetDouble(POSITION_VOLUME);
         g_syms[i].tp_price     = PositionGetDouble(POSITION_TP);
         g_syms[i].sl_price     = PositionGetDouble(POSITION_SL);
         g_syms[i].tp_money     = (InpTP_UsePointsInstead && InpTP_PointsPerTrade > 0)
                                  ? g_syms[i].PointsToMoney(g_syms[i].pending_lots, InpTP_PointsPerTrade) : InpTP_MoneyPerTrade;
         g_syms[i].exit_reason  = "TP/SL servidor";
         g_syms[i].ResetExcursion();
         adotou = true;
         LogEvent("POS_ADOTADA", "-", g_syms[i].sym,
            StringFormat("ticket=%I64u lado=%s preco=%.*f lote=%.2f tp=%.*f (EA recarregado com posicao aberta)", pt,
               g_syms[i].entry_type == (int)ORDER_TYPE_BUY ? "COMPRA" : "VENDA", g_syms[i].digits, g_syms[i].entry_price,
               g_syms[i].pending_lots, g_syms[i].digits, g_syms[i].tp_price));
         break;
      }
   }
   if(adotou && !InpUseGate) g_state = STATE_IN_POSITION;

   g_log.ReportPath();
   LogEvent("INIT", "NENHUM", StateToStr(g_state),
      StringFormat("ver=%s schema=%s magic=%I64d symbols=%s gate=%s strict=%s ccy=%s "
                   "tp=%.2f meta=%.2f maxloss=%s(%.2f) sl=%s(%.2f) kill=%s(%.1f%%,close=%s) lots=%.2f sessao=L%d/NY%d/AS%d/rollBlock%d "
                   "server_gmt_offset_s=%d",
         EA_VERSION, CSV_SCHEMA, InpMagic, InpSymbols, InpUseGate ? "on" : "off",
         InpGateStrictMode ? "on" : "off", g_ccy,
         InpTP_MoneyPerTrade, InpDailyTargetMoney, InpUseMaxDailyLoss ? "on" : "off", InpMaxDailyLossMoney,
         InpUseStopLoss ? "on" : "off", InpSL_MoneyPerTrade,
         InpUseKillSwitch ? "on" : "off", InpKillSwitchDrawdownPct, InpKillSwitchClosePos ? "sim" : "nao",
         InpFixedLots, InpTradeLondon, InpTradeNY, InpTradeAsia, InpBlockRollover,
         (int)(TimeCurrent() - TimeGMT())));
   LogEvent("SESSAO", "-", "-",
      StringFormat("modo=%s relogio=%s janelas=%s semNovas=%s(%d min) fechaNoFim=%s deslocamentoLocal=%+d min",
         InpSessionMode == SESSAO_JANELAS ? "janelas" : "blocos_gmt", InpSessionClock == SESSION_CLOCK_GMT ? "gmt" : "servidor",
         InpSessionMode == SESSAO_JANELAS ? SessionWindowsText() : "-", InpUseNoNewBeforeEnd ? "on" : "off", InpNoNewMinBeforeEnd,
         InpUseFlattenAtEnd ? "on" : "off", ClockToLocalMin()));
   // inputs efetivos no CSV (sem isso nao da para saber com qual preset cada rodada operou)
   LogEvent("PARAMS", "-", "-",
      StringFormat("tp=%.2f(%s) meta=%.2f bloqMeta=%s maxloss=%s(%.2f) sl=%s(%.2f) kill=%s(%.1f%%,close=%s) lote=%.2f "
                   "conf=%.2f ofiJan=%d ofiLim=%.2f wOFI=%.2f wMR=%.2f wMom=%.2f spreadMax=%.1f spreadPctTP=%.1f "
                   "ativ=%s(%ds,%.0fpt) alertaPresa=%ds/%.0fpt sessao=L%d/NY%d/AS%d/roll%d gate=%s/%ds/%.1fpt",
         InpTP_MoneyPerTrade, InpTP_UsePointsInstead ? "pts" : "moeda", InpDailyTargetMoney, InpBlockOnDailyTarget ? "on" : "off",
         InpUseMaxDailyLoss ? "on" : "off", InpMaxDailyLossMoney, InpUseStopLoss ? "on" : "off", InpSL_MoneyPerTrade,
         InpUseKillSwitch ? "on" : "off", InpKillSwitchDrawdownPct, InpKillSwitchClosePos ? "sim" : "nao", InpFixedLots,
         InpMinConfidence, InpOFIWindow, InpOFIThreshold, InpW_OFI, InpW_MeanRev, InpW_Momentum, InpMaxSpreadPoints, InpMaxSpreadPctOfTP,
         InpUseActivityFilter ? "on" : "off", InpActWindowSec, InpActMinRangePts, InpStuckAlertSec, InpStuckAlertPts,
         InpTradeLondon, InpTradeNY, InpTradeAsia, InpBlockRollover, InpUseGate ? "on" : "off", InpGateSeconds, InpGateMaxAvgSpread));
   for(int i = 0; i < g_nsym; i++)
   {
      double tpp = TpPoints(g_syms[i]);
      if(tpp <= 0) continue;
      double eff = InpMaxSpreadPoints;
      if(InpMaxSpreadPctOfTP > 0) eff = MathMin(eff, tpp * InpMaxSpreadPctOfTP / 100.0);
      LogEvent("ALINHAMENTO", "-", g_syms[i].sym,
         StringFormat("tp=%.0fpt spread_max_input=%.1fpt spread_max_efetivo=%.1fpt (%.0f%% do TP) gate_avg_max=%.1fpt",
            tpp, InpMaxSpreadPoints, eff, 100.0 * eff / tpp, InpGateMaxAvgSpread));
      if(InpMaxSpreadPoints > tpp * 0.30 && InpMaxSpreadPctOfTP <= 0)
         Print("[HFT] AVISO: spread maximo (", DoubleToString(InpMaxSpreadPoints, 1), " pt) > 30% do TP (",
               DoubleToString(tpp, 0), " pt). Considere InpMaxSpreadPctOfTP.");
   }
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
   g_panel.Destroy();
   EventKillTimer();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(g_panel.OnEvent(id, sparam)) DrawPanel();
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

      g_syms[i].TrackPosition();
      double pnl = g_syms[i].PositionPnLMoney();
      if(g_syms[i].tp_money > 0 && pnl >= g_syms[i].tp_money)
      { if(CloseSymbol(g_syms[i], "TP_MONEY")) g_state = STATE_EXITING; continue; }
      if(InpUseStopLoss && g_syms[i].sl_money > 0 && pnl <= -g_syms[i].sl_money)
      { if(CloseSymbol(g_syms[i], "SL_MONEY")) g_state = STATE_EXITING; continue; }
      // v2.72: fim da janela com InpUseFlattenAtEnd ligado: fecha a mercado (nao e stop de perda: tambem realiza lucro aberto)
      if(FlattenDue())
      {
         static ulong flat_ticket = 0;
         if(flat_ticket != g_syms[i].ticket)
         {
            flat_ticket = g_syms[i].ticket;
            LogEvent("SESSION_FLATTEN", "EM POSICAO", "SAINDO",
               StringFormat("%s: fim da janela (%s), fecha ticket %I64u, flutuante %+.2f", g_syms[i].sym, SessionWindowsText(), g_syms[i].ticket, pnl));
         }
         if(CloseSymbol(g_syms[i], "SESSION_CLOSE")) g_state = STATE_EXITING;
         continue;
      }
   }

   // posicao adotada ao recarregar o EA (ou aberta fora do fluxo): o estado precisa refletir isso
   if(g_state == STATE_IDLE)
      for(int i = 0; i < g_nsym; i++)
         if(g_syms[i].ticket != 0) { g_state = STATE_IN_POSITION; break; }

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
      if(InpMaxSpreadPctOfTP > 0)
      {
         double tpp = TpPoints(g_syms[i]);
         if(tpp > 0 && 100.0 * sp / tpp > InpMaxSpreadPctOfTP)
         { loop_block = "spread alto vs TP"; continue; }
      }

      bool act_ready = false;
      double act_rng = g_syms[i].RangePts(InpActWindowSec, tk.time, act_ready);
      if(InpUseActivityFilter)
      {
         if(!act_ready)
         { loop_block = "atividade: aquecendo a janela de " + IntegerToString(InpActWindowSec) + " s"; continue; }
         if(act_rng < InpActMinRangePts)
         { loop_block = StringFormat("mercado parado: faixa %ds = %.0f < %.0f pt", InpActWindowSec, act_rng, InpActMinRangePts); continue; }
      }

      double conf = 0;
      ENUM_SIG sig = EnsembleVote(g_syms[i], conf);
      if(sig == SIG_NONE) continue;
      g_syms[i].range_entry = act_rng;
      g_syms[i].spread_entry = sp;

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

   static ulong m15_ms = 0;
   if(GetTickCount64() - m15_ms >= 1000) { m15_ms = GetTickCount64(); UpdateM15(); }

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
   datetime t_out   = (datetime)HistoryDealGetInteger(deal, DEAL_TIME);
   long deal_reason = HistoryDealGetInteger(deal, DEAL_REASON);
   ulong pid        = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);

   // v2.71: entrada lida do HISTORICO da posicao (o contexto do EA ficava velho/vazio apos recarga
   // ou troca de posicao e gerava linhas com entrada errada, lote 0 e duracao -1)
   double   e_price = 0, e_vol = 0;
   datetime e_time = 0;
   int      e_type = -1;
   bool     e_ok = false;
   if(pid > 0 && HistorySelectByPosition(pid))
   {
      int nd = HistoryDealsTotal();
      for(int k = 0; k < nd; k++)
      {
         ulong dk = HistoryDealGetTicket(k);
         if(dk == 0 || HistoryDealGetInteger(dk, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
         e_price = HistoryDealGetDouble(dk, DEAL_PRICE);
         e_time  = (datetime)HistoryDealGetInteger(dk, DEAL_TIME);
         e_vol   = HistoryDealGetDouble(dk, DEAL_VOLUME);
         e_type  = (HistoryDealGetInteger(dk, DEAL_TYPE) == DEAL_TYPE_BUY) ? (int)ORDER_TYPE_BUY : (int)ORDER_TYPE_SELL;
         e_ok = true;
         break;
      }
   }
   if(!e_ok)
   {
      e_price = g_syms[si].entry_price; e_time = g_syms[si].entry_time;
      e_vol = g_syms[si].pending_lots;  e_type = g_syms[si].entry_type;
   }
   double pts = 0;
   if(e_price > 0 && e_type >= 0)
      pts = (e_type == (int)ORDER_TYPE_BUY)
            ? (price_out - e_price) / g_syms[si].point
            : (e_price - price_out) / g_syms[si].point;

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

   string side_str = (e_type == (int)ORDER_TYPE_BUY) ? "COMPRA" : (e_type == (int)ORDER_TYPE_SELL ? "VENDA" : "?");
   PushRecent(g_syms[si].sym, side_str, net, pts, win);

   g_log.Append(LF_FILLS, StringFormat("%I64d;%s;%I64u;%s;%.2f;%.2f;%.1f;%.2f;%.1f",
      GetTickCount64(), g_syms[si].sym, deal, side_str, e_vol,
      net, pts, g_syms[si].daily_money, g_syms[si].daily_points));

   // motivo real da saida: o EA marca quando fecha por software; senao usa DEAL_REASON do servidor
   string why = g_syms[si].exit_reason;
   if(why == "" || why == "TP/SL servidor")
   {
      long dr = deal_reason;
      if(dr == DEAL_REASON_TP)       why = "TP_SERVIDOR";
      else if(dr == DEAL_REASON_SL)  why = "SL_SERVIDOR";
      else if(dr == DEAL_REASON_SO)  why = "STOP_OUT";
      else if(dr == DEAL_REASON_CLIENT || dr == DEAL_REASON_MOBILE || dr == DEAL_REASON_WEB)
                                     why = "MANUAL";
      else                           why = "OUTRO_" + IntegerToString((int)dr);
   }
   long dur = (e_time > 0) ? (long)(t_out - e_time) : -1;
   // excursao final: considera tambem o preco de saida
   double mae = MathMin(g_syms[si].mae_pts, pts), mfe = MathMax(g_syms[si].mfe_pts, pts);
   g_log.Append(LF_TRADES, StringFormat("%I64d;%s;%s;%.2f;%s;%.*f;%.*f;%.2f;%.1f;%s;%I64d;%s;%.0f;%.0f;%.0f;%.1f",
      GetTickCount64(), g_syms[si].sym, side_str, e_vol,
      e_time > 0 ? TimeToString(e_time, TIME_DATE | TIME_SECONDS) : "",
      g_syms[si].digits, e_price, g_syms[si].digits, price_out,
      net, pts, win ? "WIN" : "LOSS", dur, why, mae, mfe,
      g_syms[si].range_entry, g_syms[si].spread_entry));

   SaveAggregates();

   g_syms[si].ticket = 0;
   g_syms[si].entry_price = 0;
   g_syms[si].entry_type = -1;
   g_syms[si].pending_lots = 0;
   g_syms[si].entry_time = 0;
   g_syms[si].exit_reason = "";
   g_syms[si].close_req_ms = 0;
   g_syms[si].ResetExcursion();
   g_syms[si].range_entry = 0; g_syms[si].spread_entry = 0;

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