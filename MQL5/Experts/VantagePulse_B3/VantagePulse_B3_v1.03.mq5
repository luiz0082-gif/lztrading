//+------------------------------------------------------------------+
//|                                      VantagePulse_B3_v1.02.mq5   |
//| Adaptive tick microstructure / momentum-quality scalper for B3 futures    |
//| Native MQL5. No DLL, Python, Web API, external model or martingale|
//+------------------------------------------------------------------+
#property copyright "VantagePulse Quantitative Systems"
#property version   "1.03"
#property strict
#property description "Tick-driven B3 strategy using directional quality, regime context and optional reported trade-side flags."
#property description "Fixed volume, server-side hard stop, adaptive profit exit, session and daily risk controls."

#include <Trade/Trade.mqh>

#define VP_VERSION "1.03"
#define VP_BUFFER_CAPACITY 4096

//------------------------------- Inputs -----------------------------
input group "=== IDENTIDADE E EXECUCAO ==="
input ulong  InpMagicNumber             = 6112026; // Magic exclusivo
input double InpLots                    = 1.0;     // Volume fixo; sem progressao automatica
input bool   InpAllowBuy                = true;    // Permitir compras
input bool   InpAllowSell               = true;    // Permitir vendas
input int    InpDeviationPoints         = 10;      // Desvio em SYMBOL_POINT (nao no ponto customizado)
input int    InpMaxSpreadPoints         = 15;      // Spread maximo em pontos de indice (WIN: tipicamente 1-3 ticks)
input double InpPointSize               = 0.0;     // 0=auto: WIN/WDO usam 1.0; demais usam SYMBOL_POINT

input group "=== TICK INTELLIGENCE ==="
input int    InpFastWindowMs            = 500;     // Janela rapida
input int    InpMidWindowMs             = 1500;    // Janela de contexto
input int    InpSlowWindowMs            = 4000;    // Janela de regime
input int    InpMinFastTicks            = 4;       // Minimo de atualizacoes na janela rapida
input int    InpMinMidTicks             = 8;      // Minimo de atualizacoes na janela intermediaria
input double InpMinFastMovePoints       = 5.0;    // Deslocamento direcional minimo na janela rapida
input double InpMinMidMovePoints        = 12.0;    // Escala de referencia para o contexto intermediario no score
input double InpMinFastEfficiency       = 0.25;    // |deslocamento| / caminho, 0..1
input double InpMinDirectionalConsistency = 0.52;  // Fracao de alteracoes alinhadas ao sentido do movimento
input double InpMinSignalScore         = 52.0;    // Score minimo para entrada, 0..100
input double InpMaxMidCounterMovePts    = 10.0;    // Permite recuo moderado no contexto intermediario
input double InpMaxSlowCounterMovePts   = 25.0;    // Bloqueia entrada se contexto lento contradiz alem deste valor
input bool   InpUseReportedTradeFlags   = true;    // Usa flags BUY/SELL do tick quando o broker as fornece

input group "=== CONTROLE DE FREQUENCIA ==="
input int    InpCooldownMs              = 600;     // Pausa entre entradas
input int    InpMaxEntriesPerMinute     = 8;       // Limite de entradas por minuto do servidor
input int    InpMinEntryGapMs           = 500;     // Intervalo minimo absoluto entre entradas

input group "=== SAIDA E PROTECAO DA POSICAO ==="
input double InpHardStopPoints          = 100.0;   // Stop real enviado a corretora; 0 e proibido nesta versao
input double InpTakeProfitPoints        = 0.0;     // TP fixo opcional; 0=desligado, trailing/saidas assumem a gestao
input double InpTrailArmPoints          = 35.0;    // Arma trailing quando o pico de lucro atinge N pontos
input double InpTrailDistancePoints    = 15.0;    // Distancia fixa minima desde o pico
input double InpTrailPeakPercent       = 40.0;    // Distancia percentual do pico; usa o maior entre fixa e percentual
input bool   InpUseOppositeSignalExit   = true;    // Sair em sinal oposto forte quando houver lucro minimo
input double InpOppositeExitScore      = 78.0;    // Score contrario para disparar saida
input double InpOppositeExitMinPoints  = 5.0;     // Lucro minimo em pontos para saida por sinal oposto
input int    InpMaxHoldingSeconds       = 25;      // Tempo maximo de posicao; 0=desligado
input int    InpCloseRetryMs            = 500;     // Intervalo entre tentativas de fechamento
input int    InpPlacedOrderTimeoutMs    = 2000;    // Cancela ordem de mercado que permaneceu apenas colocada

input group "=== REGIME E FILTROS DE MERCADO ==="
input double InpMinMidRegimeEfficiency  = 0.08;    // Bloqueia contexto extremamente lateral
input double InpMinSlowRegimeEfficiency = 0.05;    // Bloqueia ausencia de deslocamento estrutural
input bool   InpBlockLowActivity        = true;    // Exige amostra minima de ticks

input group "=== MODO DOS STOPS (v1.03) ==="
input bool   InpVirtualStops            = false;   // false=SL/TP enviados ao servidor (padrao v1.02); true=SL/TP virtuais (EA fecha a mercado). Use true no tester da Clear: stops de servidor sao acionados a preco falso. Virtual NAO protege se o terminal/VPS cair.

input group "=== SESSAO B3 (HORA DO SERVIDOR) ==="
input bool   InpUseSessionFilter        = true;    // Filtrar entradas por horario
input int    InpSessionStartHour        = 9;       // Inicio hora servidor
input int    InpSessionStartMinute      = 10;      // Inicio minuto servidor
input int    InpSessionEndHour          = 17;      // Fim exclusivo hora servidor
input int    InpSessionEndMinute        = 30;      // Fim exclusivo minuto servidor
input bool   InpForceEndOfDayClose      = true;    // Fechar posicao ao atingir horario limite
input int    InpEodHour                 = 17;      // Hora do fechamento
input int    InpEodMinute               = 40;      // Minuto do fechamento

input group "=== RISCO DIARIO (MOEDA DA CONTA) ==="
input double InpDailyLossLimitMoney     = 300.0;   // Bloqueia e fecha ao atingir perda liquida; 0=desligado
input double InpDailyProfitLimitMoney   = 0.0;     // Bloqueia e fecha ao atingir lucro liquido; 0=desligado
input bool   InpIncludeFloatingInDaily  = true;    // Inclui P/L flutuante proprio no limite diario

input group "=== TELEMETRIA E PAINEL ==="
input bool   InpEnableCSV               = true;    // CSV de eventos em MQL5/Files
input int    InpFlushIntervalMs         = 1000;    // Flush de telemetria
input bool   InpShowPanel               = true;    // Exibir painel textual no grafico
input bool   InpVerboseBlocks           = true;    // Registrar motivos de bloqueio
input int    InpDiagnosticEveryMs       = 1000;    // Registrar metricas e filtros periodicamente

//------------------------------- Types ------------------------------
struct SWindowStats
{
   double net_points;
   double path_points;
   double efficiency;
   double agreement;
   double quote_imbalance;
   double trade_imbalance;
   int    ticks;
   int    price_changes;
   int    trade_samples;
   long   span_ms;
};

//------------------------------- Globals ----------------------------
CTrade  g_trade;
MqlTick g_tick; // snapshot do tick corrente, compartilhado pelos motores e telemetria
MqlTick g_tick_buffer[VP_BUFFER_CAPACITY];
int     g_head = -1;
int     g_count = 0;
double  g_point_unit = 0.0;
double  g_buy_score = 0.0;
double  g_sell_score = 0.0;
int     g_signal_direction = 0;
string  g_regime = "AGUARDANDO";
string  g_last_block = "";
string  g_last_filter_reason = "inicializando";
string  g_last_event = "INICIALIZANDO";

int     g_log_handle = INVALID_HANDLE;
string  g_log_filename = "";
ulong   g_last_flush_ms = 0;
ulong   g_last_entry_tick_ms = 0;
ulong   g_last_close_attempt_ms = 0;
ulong   g_pending_order_ticket = 0;
ulong   g_pending_order_started_ms = 0;
ulong   g_pending_cancel_attempt_ms = 0;
ulong   g_last_daily_refresh_ms = 0;
ulong   g_last_panel_ms = 0;
ulong   g_last_diagnostic_ms = 0;
datetime g_entry_minute_bucket = 0;
int     g_entries_this_minute = 0;

ulong   g_position_ticket = 0;
double  g_position_peak_points = 0.0;
bool    g_position_tracking_initialized = false;

int     g_day_key = 0;
datetime g_day_start = 0;
double  g_daily_closed = 0.0;
double  g_daily_floating = 0.0;
double  g_daily_net = 0.0;
bool    g_daily_loss_locked = false;
bool    g_daily_profit_locked = false;

//------------------------------- Helpers ----------------------------
// v1.03: relogio da logica de frequencia (cooldown, intervalo entre entradas, retry de fechamento,
// timeout de ordem). Usa o horario do TICK (ms), nao o relogio do PC: no Strategy Tester o relogio
// do PC corre muito mais rapido que o mercado e distorcia cooldown/frequencia (resultado irreprodutivel).
ulong NowMs()
{
   if(g_tick.time_msc > 0) return (ulong)g_tick.time_msc;
   return GetTickCount64();
}

double Clamp(const double x, const double lo, const double hi)
{
   return MathMax(lo, MathMin(hi, x));
}

string DirectionName(const int dir)
{
   if(dir > 0) return "BUY";
   if(dir < 0) return "SELL";
   return "NEUTRAL";
}

string Number(const double value, const int digits=2)
{
   return DoubleToString(value, digits);
}

double PointUnit()
{
   if(InpPointSize > 0.0) return InpPointSize;
   string sym = _Symbol;
   StringToUpper(sym);
   if(StringFind(sym, "WIN") == 0 || StringFind(sym, "WDO") == 0)
      return 1.0;
   return _Point;
}

double TickSizePrice()
{
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0.0) ts = _Point;
   return ts;
}

double NormalizePriceToTick(const double price)
{
   double ts = TickSizePrice();
   double rounded = MathRound(price / ts) * ts;
   return NormalizeDouble(rounded, _Digits);
}

int VolumeDigits(const double step)
{
   for(int d=0; d<=8; d++)
      if(MathAbs(step - NormalizeDouble(step, d)) < 1e-10) return d;
   return 8;
}

double NormalizeTradeVolume(const double requested)
{
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(vmin <= 0.0 || vmax <= 0.0 || step <= 0.0 || requested < vmin)
      return 0.0;
   double v = MathFloor(requested / step + 1e-9) * step;
   if(v < vmin) return 0.0;
   if(v > vmax) v = MathFloor(vmax / step + 1e-9) * step;
   return NormalizeDouble(v, VolumeDigits(step));
}

void LogRow(const string event_name,
            const string detail,
            const int direction=0,
            const double score=0.0,
            const double value1=0.0,
            const double value2=0.0)
{
   g_last_event = event_name;
   Print("[VantagePulse] ", event_name, " | ", detail);
   if(!InpEnableCSV || g_log_handle == INVALID_HANDLE) return;

   FileWrite(g_log_handle,
             TimeToString(TimeTradeServer(), TIME_DATE|TIME_SECONDS),
             (long)g_tick.time_msc,
             event_name,
             detail,
             DirectionName(direction),
             DoubleToString(score, 2),
             DoubleToString(g_tick.bid, _Digits),
             DoubleToString(g_tick.ask, _Digits),
             DoubleToString((g_tick.ask-g_tick.bid)/g_point_unit, 2),
             DoubleToString(value1, 2),
             DoubleToString(value2, 2),
             DoubleToString(g_daily_net, 2));
}

void OpenTelemetry()
{
   if(!InpEnableCSV) return;
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   g_log_filename = "VantagePulse_" + _Symbol + "_" +
                    StringFormat("%04d%02d%02d", dt.year, dt.mon, dt.day) + ".csv";
   g_log_handle = FileOpen(g_log_filename,
                           FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE,
                           ',');
   if(g_log_handle == INVALID_HANDLE)
   {
      Print("[VantagePulse] CSV indisponivel. Erro=", GetLastError());
      return;
   }
   if(FileSize(g_log_handle) == 0)
      FileWrite(g_log_handle, "server_time", "tick_time_msc", "event", "detail", "direction", "score",
                "bid", "ask", "spread_points", "value1", "value2", "daily_net");
   FileSeek(g_log_handle, 0, SEEK_END);
   FileFlush(g_log_handle);
}

void FlushTelemetry()
{
   if(g_log_handle == INVALID_HANDLE) return;
   ulong now = GetTickCount64();
   if(now - g_last_flush_ms >= (ulong)MathMax(100, InpFlushIntervalMs))
   {
      FileFlush(g_log_handle);
      g_last_flush_ms = now;
   }
}

void CloseTelemetry()
{
   if(g_log_handle != INVALID_HANDLE)
   {
      FileFlush(g_log_handle);
      FileClose(g_log_handle);
      g_log_handle = INVALID_HANDLE;
   }
}

//------------------------------- Tick buffer ------------------------
void PushTick(const MqlTick &tick)
{
   if(tick.bid <= 0.0 || tick.ask <= 0.0 || tick.ask < tick.bid) return;
   if(g_count > 0)
   {
      long previous_msc = g_tick_buffer[g_head].time_msc;
      if(tick.time_msc < previous_msc) return; // ignora evento fora de ordem
   }
   g_head = (g_head + 1) % VP_BUFFER_CAPACITY;
   g_tick_buffer[g_head] = tick;
   if(g_count < VP_BUFFER_CAPACITY) g_count++;
}

void ResetWindow(SWindowStats &w)
{
   w.net_points = 0.0;
   w.path_points = 0.0;
   w.efficiency = 0.0;
   w.agreement = 0.0;
   w.quote_imbalance = 0.0;
   w.trade_imbalance = 0.0;
   w.ticks = 0;
   w.price_changes = 0;
   w.trade_samples = 0;
   w.span_ms = 0;
}

// Estatistica de trajetoria. Quote imbalance e persistencia de mudanca de mid,
// nao e fluxo agressor. Trade imbalance so usa flags/precos de negocio observados.
void BuildWindowStats(const int window_ms, SWindowStats &w)
{
   ResetWindow(w);
   if(g_count < 2 || g_head < 0) return;

   long now_msc = g_tick_buffer[g_head].time_msc;
   double current_mid = (g_tick_buffer[g_head].bid + g_tick_buffer[g_head].ask) * 0.5;
   double oldest_mid = current_mid;
   long oldest_msc = now_msc;
   double path_price = 0.0;
   int aligned = 0;
   int opposed = 0;
   int q_buy = 0;
   int q_sell = 0;
   double trade_buy_volume = 0.0;
   double trade_sell_volume = 0.0;
   double tolerance = TickSizePrice() * 0.10;

   for(int i=0; i<g_count; i++)
   {
      int idx = (g_head - i + VP_BUFFER_CAPACITY) % VP_BUFFER_CAPACITY;
      MqlTick cur = g_tick_buffer[idx];
      long age = now_msc - cur.time_msc;
      if(age < 0) continue;
      if(age > window_ms && i > 0) break;

      w.ticks++;
      double mid = (cur.bid + cur.ask) * 0.5;
      oldest_mid = mid;
      oldest_msc = cur.time_msc;

      if(InpUseReportedTradeFlags)
      {
         int side = 0;
         bool flag_buy = ((cur.flags & TICK_FLAG_BUY) != 0);
         bool flag_sell = ((cur.flags & TICK_FLAG_SELL) != 0);
         bool flag_last = ((cur.flags & TICK_FLAG_LAST) != 0);
         if(flag_buy && !flag_sell) side = 1;
         else if(flag_sell && !flag_buy) side = -1;
         else if(flag_last && cur.last > 0.0)
         {
            if(cur.last >= cur.ask - tolerance) side = 1;
            else if(cur.last <= cur.bid + tolerance) side = -1;
         }

         if(side != 0)
         {
            double vol = cur.volume_real;
            if(vol <= 0.0) vol = (double)cur.volume;
            if(vol <= 0.0) vol = 1.0;
            if(side > 0) trade_buy_volume += vol;
            else trade_sell_volume += vol;
            w.trade_samples++;
         }
      }

      if(i + 1 < g_count)
      {
         int older_idx = (idx - 1 + VP_BUFFER_CAPACITY) % VP_BUFFER_CAPACITY;
         MqlTick older = g_tick_buffer[older_idx];
         if(now_msc - older.time_msc <= window_ms)
         {
            double older_mid = (older.bid + older.ask) * 0.5;
            double delta = mid - older_mid;
            path_price += MathAbs(delta);
            if(delta > tolerance)
            {
               q_buy++;
               aligned++;
               w.price_changes++;
            }
            else if(delta < -tolerance)
            {
               q_sell++;
               opposed++;
               w.price_changes++;
            }
         }
      }
   }

   w.span_ms = (long)MathMax(0, now_msc - oldest_msc);
   w.net_points = (current_mid - oldest_mid) / g_point_unit;
   w.path_points = path_price / g_point_unit;
   if(w.path_points > 0.0) w.efficiency = Clamp(MathAbs(w.net_points) / w.path_points, 0.0, 1.0);
   int directional_total = aligned + opposed;
   if(directional_total > 0)
   {
      int direction_aligned = (w.net_points >= 0.0) ? aligned : opposed;
      w.agreement = (double)direction_aligned / (double)directional_total;
      w.quote_imbalance = (double)(q_buy - q_sell) / (double)directional_total;
   }
   double total_trade_volume = trade_buy_volume + trade_sell_volume;
   if(total_trade_volume > 0.0)
      w.trade_imbalance = (trade_buy_volume - trade_sell_volume) / total_trade_volume;
}

double SpeedPointsPerMs(const SWindowStats &w)
{
   if(w.span_ms <= 0) return 0.0;
   return MathAbs(w.net_points) / (double)w.span_ms;
}

double DirectionAgreement(const SWindowStats &w, const int direction)
{
   // quote_imbalance = (ticks de cotacao para cima - para baixo) / total.
   // Converte para a fracao de mudancas alinhadas com a direcao avaliada.
   return Clamp((1.0 + direction*w.quote_imbalance) * 0.5, 0.0, 1.0);
}

double ScoreDirection(const int direction,
                      const SWindowStats &fast,
                      const SWindowStats &mid,
                      const SWindowStats &slow)
{
   if(direction == 0) return 0.0;

   double fast_move = direction * fast.net_points;
   double mid_move  = direction * mid.net_points;
   double slow_move = direction * slow.net_points;

   // Escalas suaves: os limites minimos nao precisam, sozinhos, gerar score alto.
   double amp_score       = Clamp(fast_move / MathMax(1.0, InpMinFastMovePoints*3.0), 0.0, 1.0);
   double context_score   = Clamp((mid_move + InpMaxMidCounterMovePts) /
                                  MathMax(1.0, InpMinMidMovePoints + InpMaxMidCounterMovePts), 0.0, 1.0);
   double eff_score       = Clamp((fast.efficiency - 0.10) / 0.65, 0.0, 1.0);
   double mid_eff_score   = Clamp((mid.efficiency - 0.05) / 0.45, 0.0, 1.0);

   // A consistencia de cotacoes aparece uma unica vez em cada janela.
   double fast_agreement  = DirectionAgreement(fast, direction);
   double mid_agreement   = DirectionAgreement(mid, direction);
   double agreement_score = Clamp((fast_agreement - 0.45) / 0.45, 0.0, 1.0);
   double persistence_score = Clamp((mid_agreement - 0.40) / 0.50, 0.0, 1.0);

   double slow_score = Clamp(1.0 + slow_move / MathMax(1.0, InpMaxSlowCounterMovePts), 0.0, 1.0);

   double fast_directional_speed = (fast.span_ms > 0) ? fast_move/(double)fast.span_ms : 0.0;
   double mid_directional_speed  = (mid.span_ms > 0) ? mid_move/(double)mid.span_ms : 0.0;
   double reference_speed = MathMax(0.002, MathAbs(mid_directional_speed));
   double acceleration_ratio = fast_directional_speed / reference_speed;
   double acceleration_score = Clamp((acceleration_ratio - 0.65) / 1.35, 0.0, 1.0);

   double activity_score = Clamp((double)fast.ticks / (double)MathMax(1, InpMinFastTicks*3), 0.0, 1.0);

   // Pesos somam 100. Nao ha um segundo peso para quote_imbalance,
   // que antes duplicava a mesma informacao de consistencia direcional.
   double weighted = 20.0*amp_score + 10.0*context_score + 12.0*eff_score +
                     8.0*mid_eff_score + 18.0*agreement_score +
                     10.0*persistence_score + 8.0*slow_score +
                     8.0*acceleration_score + 6.0*activity_score;
   double weight_total = 100.0;

   // Fluxo de negocios so entra quando o feed realmente fornece amostras validas.
   if(fast.trade_samples >= 3)
   {
      double trade_score = Clamp((direction*fast.trade_imbalance + 1.0)*0.5, 0.0, 1.0);
      weighted += 10.0*trade_score;
      weight_total += 10.0;
   }
   return Clamp(weighted/weight_total*100.0, 0.0, 100.0);
}

bool DirectionPassesFilters(const int direction,
                            const SWindowStats &fast,
                            const SWindowStats &mid,
                            const SWindowStats &slow,
                            const double score,
                            string &reason)
{
   reason = "";
   if(InpBlockLowActivity && (fast.ticks < InpMinFastTicks || mid.ticks < InpMinMidTicks))
   { reason = "atividade insuficiente"; return false; }

   double fast_move = direction*fast.net_points;
   double mid_move  = direction*mid.net_points;
   double slow_move = direction*slow.net_points;
   double directional_agreement = DirectionAgreement(fast, direction);

   if(fast_move < InpMinFastMovePoints)
   { reason = "impulso rapido abaixo do minimo"; return false; }
   if(fast.efficiency < InpMinFastEfficiency)
   { reason = "eficiencia rapida insuficiente"; return false; }
   if(directional_agreement < InpMinDirectionalConsistency)
   { reason = "consistencia direcional insuficiente"; return false; }
   if(mid_move < -InpMaxMidCounterMovePts)
   { reason = "contexto intermediario contrario"; return false; }
   if(mid.efficiency < InpMinMidRegimeEfficiency)
   { reason = "regime intermediario sem eficiencia"; return false; }
   if(slow.efficiency < InpMinSlowRegimeEfficiency)
   { reason = "regime lento sem eficiencia"; return false; }
   if(slow_move < -InpMaxSlowCounterMovePts)
   { reason = "contexto lento contrario"; return false; }
   if(score < InpMinSignalScore)
   { reason = "score abaixo do minimo"; return false; }
   return true;
}

void CalculateSignals(SWindowStats &fast, SWindowStats &mid, SWindowStats &slow)
{
   BuildWindowStats(InpFastWindowMs, fast);
   BuildWindowStats(InpMidWindowMs, mid);
   BuildWindowStats(InpSlowWindowMs, slow);

   g_buy_score = ScoreDirection(1, fast, mid, slow);
   g_sell_score = ScoreDirection(-1, fast, mid, slow);
   g_signal_direction = 0;

   if(mid.efficiency < InpMinMidRegimeEfficiency || slow.efficiency < InpMinSlowRegimeEfficiency)
      g_regime = "LATERAL/BAIXA EFICIENCIA";
   else if(fast.efficiency >= 0.60 && MathAbs(fast.net_points) >= InpMinFastMovePoints)
      g_regime = "IMPULSIVO";
   else if(mid.efficiency >= 0.30)
      g_regime = "DIRECIONAL";
   else
      g_regime = "TRANSICAO";

   string buy_reason, sell_reason;
   bool buy_ok = DirectionPassesFilters(1, fast, mid, slow, g_buy_score, buy_reason);
   bool sell_ok = DirectionPassesFilters(-1, fast, mid, slow, g_sell_score, sell_reason);

   if(buy_ok && sell_ok)
      g_signal_direction = (g_buy_score >= g_sell_score) ? 1 : -1;
   else if(buy_ok)
      g_signal_direction = 1;
   else if(sell_ok)
      g_signal_direction = -1;

   if(g_signal_direction > 0) g_last_filter_reason = "BUY QUALIFICADO";
   else if(g_signal_direction < 0) g_last_filter_reason = "SELL QUALIFICADO";
   else g_last_filter_reason = "BUY: "+buy_reason+" | SELL: "+sell_reason;
}

void LogSignalDiagnostics(const SWindowStats &fast,
                          const SWindowStats &mid,
                          const SWindowStats &slow)
{
   ulong now = GetTickCount64();
   if(InpDiagnosticEveryMs <= 0 || now-g_last_diagnostic_ms < (ulong)InpDiagnosticEveryMs) return;
   g_last_diagnostic_ms = now;

   double spread_points = (g_point_unit > 0.0) ? (g_tick.ask-g_tick.bid)/g_point_unit : 0.0;
   bool session_ok = SessionAllowed();
   string detail = StringFormat(
      "reason=%s; regime=%s; ticks=%d/%d/%d; span_ms=%I64d/%I64d/%I64d; " +
      "net=%.1f/%.1f/%.1f; eff=%.2f/%.2f/%.2f; agree_buy=%.2f; agree_sell=%.2f; " +
      "score=%.1f/%.1f; spread=%.1f; session=%s; entry_block=%s; server=%s",
      g_last_filter_reason, g_regime,
      fast.ticks, mid.ticks, slow.ticks,
      fast.span_ms, mid.span_ms, slow.span_ms,
      fast.net_points, mid.net_points, slow.net_points,
      fast.efficiency, mid.efficiency, slow.efficiency,
      DirectionAgreement(fast,1), DirectionAgreement(fast,-1),
      g_buy_score, g_sell_score, spread_points,
      (session_ok ? "OK" : "BLOCKED"), g_last_block,
      TimeToString(TimeTradeServer(), TIME_DATE|TIME_SECONDS));
   LogRow("SIGNAL_DIAG", detail, g_signal_direction,
          MathMax(g_buy_score,g_sell_score), fast.net_points, mid.net_points);
}

//------------------------------- Risk & session --------------------
bool IsTradePermitted(string &reason)
{
   reason = "";
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)) { reason="terminal desconectado"; return false; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) { reason="Algo Trading do terminal desligado"; return false; }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) { reason="trading do EA desabilitado"; return false; }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) || !AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
   { reason="conta nao permite Expert Advisors"; return false; }
   long mode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
   if(mode != SYMBOL_TRADE_MODE_FULL) { reason="simbolo nao esta em modo FULL"; return false; }
   return true;
}

bool SessionAllowed()
{
   if(!InpUseSessionFilter) return true;
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   int now_min = dt.hour*60 + dt.min;
   int start_min = InpSessionStartHour*60 + InpSessionStartMinute;
   int end_min = InpSessionEndHour*60 + InpSessionEndMinute;
   if(start_min < end_min) return (now_min >= start_min && now_min < end_min);
   return (now_min >= start_min || now_min < end_min);
}

bool EndOfDayReached()
{
   if(!InpForceEndOfDayClose) return false;
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   return (dt.hour*60 + dt.min >= InpEodHour*60 + InpEodMinute);
}

void RefreshDailyPnl(const bool force=false)
{
   ulong now_tick = NowMs();
   if(!force && now_tick - g_last_daily_refresh_ms < 1000) return;
   g_last_daily_refresh_ms = now_tick;

   datetime now = TimeTradeServer();
   if(now <= 0) now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   int key = dt.year*10000 + dt.mon*100 + dt.day;
   if(key != g_day_key)
   {
      g_day_key = key;
      dt.hour = 0; dt.min = 0; dt.sec = 0;
      g_day_start = StructToTime(dt);
      g_daily_loss_locked = false;
      g_daily_profit_locked = false;
      g_entries_this_minute = 0;
      g_entry_minute_bucket = 0;
      LogRow("NEW_SERVER_DAY", "Reinicializando controles diarios");
   }

   g_daily_closed = 0.0;
   if(HistorySelect(g_day_start, now + 1))
   {
      int deals = HistoryDealsTotal();
      for(int i=0; i<deals; i++)
      {
         ulong deal = HistoryDealGetTicket(i);
         if(deal == 0) continue;
         if(HistoryDealGetString(deal, DEAL_SYMBOL) != _Symbol) continue;
         if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC) != InpMagicNumber) continue;
         g_daily_closed += HistoryDealGetDouble(deal, DEAL_PROFIT) +
                           HistoryDealGetDouble(deal, DEAL_COMMISSION) +
                           HistoryDealGetDouble(deal, DEAL_SWAP) +
                           HistoryDealGetDouble(deal, DEAL_FEE);
      }
   }

   g_daily_floating = 0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      g_daily_floating += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   g_daily_net = g_daily_closed + (InpIncludeFloatingInDaily ? g_daily_floating : 0.0);

   if(InpDailyLossLimitMoney > 0.0 && g_daily_net <= -InpDailyLossLimitMoney)
   {
      if(!g_daily_loss_locked) LogRow("DAILY_LOSS_LOCK", "P/L diario atingiu limite: "+Number(g_daily_net));
      g_daily_loss_locked = true;
   }
   if(InpDailyProfitLimitMoney > 0.0 && g_daily_net >= InpDailyProfitLimitMoney)
   {
      if(!g_daily_profit_locked) LogRow("DAILY_PROFIT_LOCK", "Meta diaria atingida: "+Number(g_daily_net));
      g_daily_profit_locked = true;
   }
}

bool HasForeignPositionOnSymbol()
{
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         return true;
   }
   return false;
}

bool GetOwnPosition(ulong &ticket)
{
   ticket = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong candidate = PositionGetTicket(i);
      if(candidate == 0 || !PositionSelectByTicket(candidate)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      ticket = candidate;
      return true;
   }
   return false;
}

bool MarginAvailable(const int direction, const double volume, string &reason)
{
   reason = "";
   double margin = 0.0;
   ENUM_ORDER_TYPE type = (direction > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double price = (direction > 0) ? g_tick.ask : g_tick.bid;
   ResetLastError();
   if(!OrderCalcMargin(type, _Symbol, volume, price, margin))
   {
      reason = "OrderCalcMargin falhou; entrada bloqueada, erro="+IntegerToString(GetLastError());
      return false; // fail-closed: falha no calculo nunca autoriza a ordem
   }
   double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(margin > free_margin*0.95)
   {
      reason = "margem livre insuficiente; requerida="+Number(margin)+" livre="+Number(free_margin);
      return false;
   }
   return true;
}

void BuildServerStops(const int direction, double &sl, double &tp)
{
   sl = 0.0;
   tp = 0.0;
   if(InpVirtualStops) return; // v1.03: SL/TP virtuais sao tratados em ManageOwnPosition
   double min_stop = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double freeze = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * _Point;
   double min_distance = MathMax(min_stop, freeze) + TickSizePrice();
   double hard_distance = MathMax(InpHardStopPoints*g_point_unit, min_distance);
   double tp_distance = (InpTakeProfitPoints > 0.0) ? MathMax(InpTakeProfitPoints*g_point_unit, min_distance) : 0.0;

   if(direction > 0)
   {
      sl = NormalizePriceToTick(MathMin(g_tick.ask-hard_distance, g_tick.bid-min_distance));
      if(tp_distance > 0.0) tp = NormalizePriceToTick(MathMax(g_tick.ask+tp_distance, g_tick.bid+min_distance));
   }
   else
   {
      sl = NormalizePriceToTick(MathMax(g_tick.bid+hard_distance, g_tick.ask+min_distance));
      if(tp_distance > 0.0) tp = NormalizePriceToTick(MathMin(g_tick.bid-tp_distance, g_tick.ask-min_distance));
   }
}

bool HasOwnActiveOrder()
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagicNumber) continue;
      return true;
   }
   return false;
}

void ManagePendingEntryOrder()
{
   if(g_pending_order_ticket == 0) return;

   if(OrderSelect(g_pending_order_ticket))
   {
      ulong now = NowMs();
      if(now - g_pending_order_started_ms >= (ulong)MathMax(250, InpPlacedOrderTimeoutMs) &&
         now - g_pending_cancel_attempt_ms >= 500)
      {
         g_pending_cancel_attempt_ms = now;
         bool deleted = g_trade.OrderDelete(g_pending_order_ticket);
         uint rc = g_trade.ResultRetcode();
         LogRow(deleted ? "PENDING_ORDER_CANCEL_SENT" : "PENDING_ORDER_CANCEL_FAILED",
                "ticket="+(string)g_pending_order_ticket+" retcode="+(string)rc+" "+g_trade.ResultRetcodeDescription());
      }
      return;
   }

   ulong old_ticket = g_pending_order_ticket;
   if(HistoryOrderSelect(old_ticket))
   {
      long state = HistoryOrderGetInteger(old_ticket, ORDER_STATE);
      LogRow("PENDING_ORDER_RESOLVED", "ticket="+(string)old_ticket+" state="+(string)state);
   }
   else
      LogRow("PENDING_ORDER_NOT_ACTIVE", "ticket="+(string)old_ticket+" nao consta em ordens ativas/historico selecionavel");

   g_pending_order_ticket = 0;
   g_pending_order_started_ms = 0;
   g_pending_cancel_attempt_ms = 0;
}

void CancelOwnOrdersOnDeinit()
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagicNumber) continue;
      bool deleted = g_trade.OrderDelete(ticket);
      LogRow(deleted ? "DEINIT_ORDER_CANCEL_SENT" : "DEINIT_ORDER_CANCEL_FAILED",
             "ticket="+(string)ticket+" retcode="+(string)g_trade.ResultRetcode());
   }
}

//------------------------------- Position management ----------------
bool ClosePositionTicket(const ulong ticket, const string reason)
{
   ulong now = NowMs();
   if(now - g_last_close_attempt_ms < (ulong)MathMax(100, InpCloseRetryMs)) return false;
   g_last_close_attempt_ms = now;

   bool sent = g_trade.PositionClose(ticket, (ulong)MathMax(0, InpDeviationPoints));
   uint rc = g_trade.ResultRetcode();
   bool done = (sent && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL));
   if(done)
   {
      g_last_entry_tick_ms = NowMs(); // impede reentrada imediata apos encerrar uma posicao
      LogRow("EXIT_SENT", reason+" | retcode="+(string)rc, 0, 0.0, g_trade.ResultPrice(), g_trade.ResultVolume());
   }
   else
      LogRow("EXIT_FAILED", reason+" | retcode="+(string)rc+" | "+g_trade.ResultRetcodeDescription());
   return done;
}

void ManageOwnPosition(const double opposite_score)
{
   ulong ticket = 0;
   if(!GetOwnPosition(ticket))
   {
      g_position_ticket = 0;
      g_position_tracking_initialized = false;
      return;
   }
   if(!PositionSelectByTicket(ticket)) return;

   long type = PositionGetInteger(POSITION_TYPE);
   int direction = (type == POSITION_TYPE_BUY) ? 1 : -1;
   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   long open_time_msc = PositionGetInteger(POSITION_TIME_MSC);
   double exit_price = (direction > 0) ? g_tick.bid : g_tick.ask;
   double current_points = direction * (exit_price-open_price) / g_point_unit;
   long hold_ms = (long)g_tick.time_msc - open_time_msc;

   if(!g_position_tracking_initialized || g_position_ticket != ticket)
   {
      g_position_ticket = ticket;
      g_position_peak_points = MathMax(0.0, current_points);
      g_position_tracking_initialized = true;
      LogRow("POSITION_DISCOVERED", "Posicao propria identificada apos inicializacao/reconexao", direction, 0.0, current_points, hold_ms);
   }
   if(current_points > g_position_peak_points) g_position_peak_points = current_points;

   string exit_reason = "";
   if(g_daily_loss_locked) exit_reason = "LIMITE_PERDA_DIARIA";
   else if(g_daily_profit_locked) exit_reason = "META_DIARIA";
   else if(EndOfDayReached()) exit_reason = "FIM_DIA";
   else if(InpVirtualStops && current_points <= -InpHardStopPoints) exit_reason = "STOP_VIRTUAL";
   else if(InpVirtualStops && InpTakeProfitPoints > 0.0 && current_points >= InpTakeProfitPoints) exit_reason = "TP_VIRTUAL";
   else if(InpMaxHoldingSeconds > 0 && hold_ms >= (long)InpMaxHoldingSeconds*1000) exit_reason = "TEMPO_MAXIMO";
   else if(InpTrailArmPoints > 0.0 && g_position_peak_points >= InpTrailArmPoints)
   {
      double pullback = g_position_peak_points - current_points;
      double required_pullback = InpTrailDistancePoints;
      if(InpTrailPeakPercent > 0.0)
         required_pullback = MathMax(required_pullback, g_position_peak_points*InpTrailPeakPercent/100.0);
      if(pullback >= required_pullback) exit_reason = "TRAILING_PICO";
   }

   if(exit_reason == "" && InpUseOppositeSignalExit && opposite_score >= InpOppositeExitScore &&
      current_points >= InpOppositeExitMinPoints)
      exit_reason = "SINAL_OPOSITO_FORTE";

   if(exit_reason != "")
      ClosePositionTicket(ticket, exit_reason+" | pts="+Number(current_points)+" pico="+Number(g_position_peak_points));
}

//------------------------------- Entry engine -----------------------
bool EntryConditions(string &reason, const SWindowStats &fast, const SWindowStats &mid, const SWindowStats &slow)
{
   reason = "";
   if(g_signal_direction == 0) { reason="sem sinal qualificado"; return false; }
   if(g_signal_direction > 0 && !InpAllowBuy) { reason="compra desabilitada"; return false; }
   if(g_signal_direction < 0 && !InpAllowSell) { reason="venda desabilitada"; return false; }

   string trade_reason;
   if(!IsTradePermitted(trade_reason)) { reason=trade_reason; return false; }
   if(!SessionAllowed()) { reason="fora da sessao permitida (hora servidor)"; return false; }
   if(EndOfDayReached()) { reason="horario de fechamento atingido"; return false; }
   if(g_daily_loss_locked) { reason="bloqueio de perda diaria"; return false; }
   if(g_daily_profit_locked) { reason="bloqueio de meta diaria"; return false; }

   double spread_points = (g_tick.ask-g_tick.bid)/g_point_unit;
   if(spread_points > InpMaxSpreadPoints) { reason="spread acima do limite"; return false; }
   if(HasForeignPositionOnSymbol()) { reason="existe posicao de outro magic/operador neste simbolo"; return false; }
   if(HasOwnActiveOrder()) { reason="existe ordem propria ainda ativa/aguardando execucao"; return false; }

   ulong own_ticket=0;
   if(GetOwnPosition(own_ticket)) { reason="ja existe posicao propria aberta"; return false; }

   ulong now = NowMs();
   if(now - g_last_entry_tick_ms < (ulong)MathMax(InpCooldownMs, InpMinEntryGapMs))
   { reason="cooldown entre entradas"; return false; }

   datetime server_now = TimeTradeServer();
   datetime minute_bucket = (datetime)((long)server_now/60*60);
   if(minute_bucket != g_entry_minute_bucket)
   {
      g_entry_minute_bucket = minute_bucket;
      g_entries_this_minute = 0;
   }
   if(InpMaxEntriesPerMinute > 0 && g_entries_this_minute >= InpMaxEntriesPerMinute)
   { reason="limite de entradas por minuto"; return false; }

   if(fast.efficiency < InpMinFastEfficiency || DirectionAgreement(fast, g_signal_direction) < InpMinDirectionalConsistency)
   { reason="qualidade da trajetoria insuficiente"; return false; }
   if(mid.efficiency < InpMinMidRegimeEfficiency || slow.efficiency < InpMinSlowRegimeEfficiency)
   { reason="regime sem eficiencia minima"; return false; }
   return true;
}

bool SendEntry(const int direction)
{
   double volume = NormalizeTradeVolume(InpLots);
   if(volume <= 0.0)
   {
      LogRow("ENTRY_BLOCK", "Volume solicitado fora dos limites/step do simbolo", direction, 0.0, InpLots, 0.0);
      return false;
   }

   string margin_reason;
   if(!MarginAvailable(direction, volume, margin_reason))
   {
      LogRow("ENTRY_BLOCK", margin_reason, direction, (direction>0?g_buy_score:g_sell_score));
      return false;
   }

   double sl=0.0, tp=0.0;
   BuildServerStops(direction, sl, tp);
   bool sent = false;
   ulong start_us = GetMicrosecondCount();
   if(direction > 0)
      sent = g_trade.Buy(volume, _Symbol, 0.0, sl, tp, "VantagePulse B3 BUY");
   else
      sent = g_trade.Sell(volume, _Symbol, 0.0, sl, tp, "VantagePulse B3 SELL");
   ulong latency_us = GetMicrosecondCount() - start_us;
   uint rc = g_trade.ResultRetcode();
   ulong deal_ticket = g_trade.ResultDeal();
   ulong order_ticket = g_trade.ResultOrder();
   bool retcode_done = (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL);
   bool confirmed = sent && retcode_done && deal_ticket > 0;

   if(confirmed)
   {
      g_last_entry_tick_ms = NowMs();
      g_entries_this_minute++;
      if(order_ticket > 0 && OrderSelect(order_ticket))
      {
         g_pending_order_ticket = order_ticket; // possivel saldo nao executado apos fill parcial
         g_pending_order_started_ms = NowMs();
         g_pending_cancel_attempt_ms = 0;
      }
      double score = (direction > 0) ? g_buy_score : g_sell_score;
      LogRow("ENTRY_CONFIRMED", "deal="+(string)deal_ticket+" ordem="+(string)order_ticket+
             " latency_us="+(string)latency_us+" retcode="+(string)rc,
             direction, score, g_trade.ResultPrice(), g_trade.ResultVolume());
      return true;
   }

   // PLACED significa ordem colocada, nao fill. Monitoramos e cancelamos se ficar ativa.
   if(sent && rc == TRADE_RETCODE_PLACED && order_ticket > 0)
   {
      g_pending_order_ticket = order_ticket;
      g_pending_order_started_ms = NowMs();
      g_pending_cancel_attempt_ms = 0;
      g_last_entry_tick_ms = NowMs();
      LogRow("ENTRY_ORDER_PLACED", "ticket="+(string)order_ticket+" aguardando fill; timeout_ms="+
             (string)InpPlacedOrderTimeoutMs+" latency_us="+(string)latency_us,
             direction, (direction > 0 ? g_buy_score : g_sell_score), g_trade.ResultPrice(), g_trade.ResultVolume());
      return false;
   }

   LogRow("ENTRY_NOT_CONFIRMED", "sent="+(string)sent+" deal="+(string)deal_ticket+
          " retcode="+(string)rc+" "+g_trade.ResultRetcodeDescription()+" latency_us="+(string)latency_us,
          direction, (direction > 0 ? g_buy_score : g_sell_score), g_trade.ResultPrice(), g_trade.ResultVolume());
   g_last_entry_tick_ms = NowMs(); // evita repeticao imediata apos resposta ambigua
   return false;
}

//------------------------------- UI and lifecycle -------------------
void UpdatePanel(const SWindowStats &fast, const SWindowStats &mid)
{
   if(!InpShowPanel) return;
   ulong now = GetTickCount64();
   if(now - g_last_panel_ms < 150) return;
   g_last_panel_ms = now;

   ulong own_ticket=0;
   string pos_text = "SEM POSICAO";
   if(GetOwnPosition(own_ticket) && PositionSelectByTicket(own_ticket))
   {
      long type = PositionGetInteger(POSITION_TYPE);
      double p = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      pos_text = DirectionName(type==POSITION_TYPE_BUY?1:-1)+" #"+(string)own_ticket+" | P/L "+Number(p);
   }
   double spread = (g_tick.ask-g_tick.bid)/g_point_unit;
   Comment("VANTAGE PULSE B3 v", VP_VERSION,
           "\n", _Symbol, " | Regime: ", g_regime,
           " | Sinal: ", DirectionName(g_signal_direction),
           "\nScore BUY ", Number(g_buy_score,1), " / SELL ", Number(g_sell_score,1),
           " | Spread ", Number(spread,1), " pts",
           "\nFast ", fast.ticks, " ticks | net ", Number(fast.net_points,1), " pts | Eff ", Number(fast.efficiency,2),
           "\nMid ", mid.ticks, " ticks | net ", Number(mid.net_points,1), " pts | Eff ", Number(mid.efficiency,2),
           "\nFiltro: ", g_last_filter_reason,
           "\n", pos_text,
           "\nP/L diario ", Number(g_daily_net), " | Trades/min ", g_entries_this_minute,
           "\nUltimo evento: ", g_last_event,
           "\nBloqueio: ", g_last_block);
}

bool ValidateInputs()
{
   if(InpLots <= 0.0 || InpMagicNumber == 0) return false;
   if(InpFastWindowMs < 50 || InpMidWindowMs <= InpFastWindowMs || InpSlowWindowMs <= InpMidWindowMs) return false;
   if(InpMinFastTicks < 2 || InpMinMidTicks < InpMinFastTicks) return false;
   if(InpMinFastMovePoints <= 0.0 || InpMinMidMovePoints <= 0.0 || InpHardStopPoints <= 0.0 ||
      InpMaxMidCounterMovePts < 0.0 || InpMaxSlowCounterMovePts < 0.0) return false;
   if(InpMinFastEfficiency < 0.0 || InpMinFastEfficiency > 1.0 ||
      InpMinDirectionalConsistency < 0.0 || InpMinDirectionalConsistency > 1.0) return false;
   if(InpMinSignalScore < 0.0 || InpMinSignalScore > 100.0) return false;
   if(InpTrailDistancePoints < 0.0 || InpTrailPeakPercent < 0.0) return false;
   if(InpSessionStartHour<0 || InpSessionStartHour>23 || InpSessionEndHour<0 || InpSessionEndHour>23 ||
      InpSessionStartMinute<0 || InpSessionStartMinute>59 || InpSessionEndMinute<0 || InpSessionEndMinute>59) return false;
   if(InpEodHour<0 || InpEodHour>23 || InpEodMinute<0 || InpEodMinute>59) return false;
   if(InpMaxSpreadPoints <= 0 || InpDeviationPoints < 0 || InpMaxHoldingSeconds < 0 ||
      InpPlacedOrderTimeoutMs < 250 || InpDiagnosticEveryMs < 0) return false;
   return true;
}

int OnInit()
{
   if(!ValidateInputs())
   {
      Print("[VantagePulse] Inputs invalidos. Revise janelas, limites e stop obrigatorio.");
      return INIT_PARAMETERS_INCORRECT;
   }

   g_point_unit = PointUnit();
   if(g_point_unit <= 0.0) return INIT_FAILED;
   if(!SymbolSelect(_Symbol, true)) return INIT_FAILED;

   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints((ulong)InpDeviationPoints);
   if(!g_trade.SetTypeFillingBySymbol(_Symbol))
   {
      Print("[VantagePulse] Nao foi possivel determinar o modo de preenchimento do simbolo.");
      return INIT_FAILED;
   }
   g_trade.SetAsyncMode(false);
   g_trade.SetMarginMode();
   g_trade.LogLevel(LOG_LEVEL_ERRORS);

   OpenTelemetry();
   RefreshDailyPnl(true);
   string reason;
   bool allowed = IsTradePermitted(reason);
   LogRow("INITIALIZED", "VantagePulse B3 v"+VP_VERSION+" point_unit="+Number(g_point_unit,4)+
          " tick_size="+Number(TickSizePrice(),_Digits)+" trade_allowed="+(string)allowed+" "+reason);

   EventSetMillisecondTimer(250);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   CancelOwnOrdersOnDeinit();
   LogRow("DEINITIALIZED", "reason="+(string)reason);
   CloseTelemetry();
   Comment("");
}

void OnTick()
{
   if(!SymbolInfoTick(_Symbol, g_tick)) return;
   if(g_tick.bid <= 0.0 || g_tick.ask <= 0.0 || g_tick.ask < g_tick.bid) return;
   PushTick(g_tick);

   SWindowStats fast, mid, slow;
   CalculateSignals(fast, mid, slow);
   RefreshDailyPnl(false);
   ManagePendingEntryOrder();

   ulong own_ticket=0;
   bool has_own = GetOwnPosition(own_ticket);
   double opposing_score = 0.0;
   if(has_own && PositionSelectByTicket(own_ticket))
   {
      long type = PositionGetInteger(POSITION_TYPE);
      opposing_score = (type == POSITION_TYPE_BUY) ? g_sell_score : g_buy_score;
   }
   ManageOwnPosition(opposing_score);

   string block_reason;
   if(g_signal_direction != 0)
   {
      if(EntryConditions(block_reason, fast, mid, slow))
      {
         g_last_block = "";
         SendEntry(g_signal_direction);
      }
      else
      {
         if(block_reason != g_last_block)
         {
            if(InpVerboseBlocks) LogRow("ENTRY_BLOCK", block_reason, g_signal_direction,
                                        (g_signal_direction>0?g_buy_score:g_sell_score));
            g_last_block = block_reason;
         }
      }
   }
   else
   {
      g_last_block = "sem sinal qualificado";
   }

   LogSignalDiagnostics(fast, mid, slow);
   UpdatePanel(fast, mid);
   FlushTelemetry();
}

void OnTimer()
{
   RefreshDailyPnl(false);
   FlushTelemetry();
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD || trans.deal == 0) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol) return;
   if((ulong)HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != InpMagicNumber) return;

   long entry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
   double commission = HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
   double fee = HistoryDealGetDouble(trans.deal, DEAL_FEE);
   double swap = HistoryDealGetDouble(trans.deal, DEAL_SWAP);
   LogRow("DEAL_TRANSACTION", "deal="+(string)trans.deal+" entry="+(string)entry+
          " profit="+Number(profit)+" commission="+Number(commission)+" fee="+Number(fee)+" swap="+Number(swap),
          0, 0.0, trans.price, trans.volume);
}
//+------------------------------------------------------------------+
