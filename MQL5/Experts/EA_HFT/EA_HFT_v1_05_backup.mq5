//+------------------------------------------------------------------+
//|                                                  EA_HFT_XAU.mq5  |
//|                                                  versão 1.05     |
//+------------------------------------------------------------------+
#property copyright "EA HFT XAU"
#property version   "1.05"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

//--- Inputs ---------------------------------------------------------
input group "=== Geral ==="
input double InpLote             = 0.01;
input long   InpMagico           = 20241101;
input int    InpSlippage         = 50;

input group "=== Grid ==="
input int    InpNfavor           = 3;
input int    InpNcontra          = 2;
input double InpKdist            = 1.0;
input double InpMFavForte        = 0.5;
input double InpMFavFraca        = 0.8;
input double InpMFavMuitoFraca   = 1.0;
input double InpMCtrForte        = 2.0;
input double InpMCtrFraca        = 1.5;
input double InpMCtrMuitoFraca   = 1.2;
input double InpEscFav           = 0.15;
input double InpEscCtr           = 0.20;
input double InpAjusteSpreadBarato = 0.85;
input double InpMultiEstouro     = 1.30;
input double InpMultiRecuo       = 0.70;
input double InpDriftRecenterATR = 1.0;

input group "=== Score ==="
input double InpScoreForte       = 0.60;
input double InpScoreFraca       = 0.40;

input group "=== TP / Trailing ==="
input double InpLucroPorOrdem    = 0.50;
input double InpFTPAltaVol       = 0.4;
input double InpFTPNormVol       = 0.6;
input double InpFTPBaixaVol      = 0.8;
input double InpTrailAtivPct     = 0.5;
input double InpTrailRecuoPct    = 0.25;

input group "=== Metas Diarias ==="
input double InpMetaLucroDiaria  = 10.0;
input double InpPerdaMaxDiaria   = 10.0;

input group "=== Filtros ==="
input double InpSpreadMaxPreco   = 0.50;
input int    InpTickThrottleMs   = 200;

input group "=== Trava Global ==="
input bool   InpTravaAtiva       = false;
input double InpTravaDDPct       = 5.0;
input int    InpTravaMaxOrdens   = 5;
input int    InpCooldownTravaMin = 15;

input group "=== Sessao ==="
input bool   InpUsarSessao       = false;
input int    InpSessaoIniHora    = 8;
input int    InpSessaoFimHora    = 18;

input group "=== News ==="
input bool   InpFiltroNews       = true;
input double InpNewsATRMult      = 3.0;
input int    InpNewsPausaSeg     = 60;

//--- Estado ---------------------------------------------------------
enum EEstadoGrid { EST_ESTAVEL, EST_ESTOUROU_UP, EST_ESTOUROU_DN, EST_RECUO, EST_PAUSA };

struct SPosInfo
{
   ulong  ticket;
   double tp_dist;
   double preco_open;
   double peak;
   bool   trail_ativo;
};

CTrade      trade;
CSymbolInfo sym;

double g_ponto, g_tick_size, g_valor_por_ponto;
int    g_digitos;

double g_atr_med = 0, g_atr_atual = 0;

double g_spread_buf[100];
int    g_spread_idx = 0, g_spread_count = 0;
double g_spread_med = 0;

EEstadoGrid g_estado = EST_ESTAVEL;
datetime    g_trava_ate = 0;
datetime    g_news_pausa_ate = 0;

double   g_score_ultimo = 0;
int      g_dir_ultimo   = 1;
int      g_sinal_recuo  = 0;

datetime g_ultima_vela_m1 = 0;
uint     g_ultimo_check_ms = 0;

datetime g_dia_atual   = 0;
bool     g_meta_batida = false;
double   g_pl_dia      = 0;

double      g_anchor_mid    = 0;
double      g_anchor_D_fav  = 0;
double      g_anchor_D_ctr  = 0;
int         g_dir_pendentes = 0;
EEstadoGrid g_estado_pendentes = EST_ESTAVEL;
bool        g_anchor_valido = false;

string  g_diag = "";
SPosInfo g_pos_info[];

//==================================================================//
//                    PAINEL — DESIGN SYSTEM                         //
//==================================================================//
#define PFX   "HFX_"
#define PX     12
#define PY     20
#define PW    300
#define PH    300

// Cores do design system
color CLR_BG      = C'10,16,26';      // fundo principal
color CLR_BG_HDR  = C'16,26,42';      // header
color CLR_ACCENT  = C'0,200,240';     // ciano principal
color CLR_TEXT    = C'228,238,252';   // texto primário
color CLR_MUTED   = C'126,148,180';   // texto secundário
color CLR_GREEN   = C'0,220,140';
color CLR_RED     = C'255,72,96';
color CLR_YELLOW  = C'255,196,60';
color CLR_PURPLE  = C'172,128,255';
color CLR_BORDER  = C'30,46,68';

//+------------------------------------------------------------------+
//| Helpers do painel                                                |
//+------------------------------------------------------------------+
void P_Rect(string name, int x, int y, int w, int h, color bg, color brd)
{
   string n = PFX + name;
   if(ObjectFind(0, n) < 0)
      ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, n, OBJPROP_COLOR, brd);
   ObjectSetInteger(0, n, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, n, OBJPROP_ZORDER, 100);
}

void P_Lbl(string name, int x, int y, string txt, color clr, int size, string font)
{
   string n = PFX + name;
   if(ObjectFind(0, n) < 0)
      ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, size);
   ObjectSetString (0, n, OBJPROP_FONT, font);
   ObjectSetString (0, n, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, n, OBJPROP_ZORDER, 110);
}

//+------------------------------------------------------------------+
//| Bloco visual: título de seção                                    |
//+------------------------------------------------------------------+
void P_Section(int y, string title, color accent)
{
   P_Rect("sd_" + title, PX + 14, y + 4, 3, 8, accent, accent);
   P_Lbl ("st_" + title, PX + 24, y + 1, title, CLR_TEXT, 8, "Segoe UI Semibold");
}

//+------------------------------------------------------------------+
//| Linha com dois pares label/valor lado a lado                     |
//+------------------------------------------------------------------+
void P_Row2(int y, string l1, string v1, color c1,
                   string l2, string v2, color c2)
{
   string k = IntegerToString(y);
   P_Lbl("l1_" + k, PX + 18,  y + 1, l1, CLR_MUTED, 8, "Segoe UI");
   P_Lbl("v1_" + k, PX + 96,  y,     v1, c1,        9, "Consolas");
   P_Lbl("l2_" + k, PX + 186, y + 1, l2, CLR_MUTED, 8, "Segoe UI");
   P_Lbl("v2_" + k, PX + 244, y,     v2, c2,        9, "Consolas");
}

//+------------------------------------------------------------------+
//| Cores por estado                                                 |
//+------------------------------------------------------------------+
color EstadoCor(EEstadoGrid e)
{
   switch(e)
   {
      case EST_ESTAVEL:     return CLR_ACCENT;
      case EST_ESTOUROU_UP: return CLR_GREEN;
      case EST_ESTOUROU_DN: return CLR_RED;
      case EST_RECUO:       return CLR_YELLOW;
      case EST_PAUSA:       return CLR_MUTED;
   }
   return CLR_MUTED;
}

color ScoreCor(double s)
{
   if(s >= 0.60) return CLR_GREEN;
   if(s >= 0.40) return CLR_YELLOW;
   return CLR_MUTED;
}

//+------------------------------------------------------------------+
//| Desenha / atualiza o painel                                      |
//+------------------------------------------------------------------+
void P_Draw(double spread_preco)
{
   // Contagens
   int n_ord = 0, n_pos = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong tk = OrderGetTicket(i);
      if(tk == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC) != InpMagico) continue;
      n_ord++;
   }
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagico) continue;
      n_pos++;
   }

   // ===== Base =====
   P_Rect("bg",  PX, PY, PW, PH, CLR_BG, CLR_BORDER);
   P_Rect("hdr", PX, PY, PW, 36, CLR_BG_HDR, CLR_BG_HDR);
   P_Rect("acc", PX, PY, 3, PH, CLR_ACCENT, CLR_ACCENT);
   P_Rect("hdiv", PX, PY + 36, PW, 1, CLR_BORDER, CLR_BORDER);

   // ===== Header =====
   color sc = EstadoCor(g_estado);
   P_Lbl("title", PX + 16, PY + 8, "HFT XAU", CLR_TEXT, 11, "Segoe UI Semibold");
   P_Lbl("ver",   PX + PW - 66, PY + 11, "v1.05", CLR_MUTED, 8, "Consolas");
   // status dot em duas camadas (efeito de glow sutil)
   P_Rect("dot_out", PX + PW - 26, PY + 14, 10, 10, CLR_BG_HDR, sc);
   P_Rect("dot_in",  PX + PW - 24, PY + 16,  6,  6, sc, sc);

   // ===== STATUS =====
   int y = PY + 48;
   P_Section(y, "STATUS", CLR_ACCENT);  y += 22;

   P_Row2(y,
      "Estado", EstadoStr(g_estado), sc,
      "Gate",   (g_diag == "" ? "OK" : g_diag),
                (g_diag == "" ? CLR_GREEN : CLR_YELLOW));
   y += 18;

   P_Row2(y,
      "Score", DoubleToString(g_score_ultimo, 3), ScoreCor(g_score_ultimo),
      "Dir",   (g_dir_ultimo > 0 ? "ALTA" : "BAIXA"),
                (g_dir_ultimo > 0 ? CLR_GREEN : CLR_RED));
   y += 24;

   // ===== MERCADO =====
   P_Section(y, "MERCADO", CLR_PURPLE);  y += 22;

   double vol = VolRelativa();
   P_Row2(y,
      "ATR med", DoubleToString(g_atr_med, 5), CLR_TEXT,
      "Vol rel", DoubleToString(vol, 2),
                 (vol > 1.5 ? CLR_YELLOW : (vol < 0.7 ? CLR_PURPLE : CLR_TEXT)));
   y += 18;

   P_Row2(y,
      "Spread", DoubleToString(spread_preco, 3) + " USD",
                (spread_preco > InpSpreadMaxPreco ? CLR_RED : CLR_GREEN),
      "Max",    DoubleToString(InpSpreadMaxPreco, 2), CLR_MUTED);
   y += 24;

   // ===== GRID =====
   P_Section(y, "GRID", CLR_GREEN);  y += 22;

   P_Row2(y,
      "Ancora", DoubleToString(g_anchor_mid, 2), CLR_TEXT,
      "D fav",  DoubleToString(g_anchor_D_fav, 4), CLR_MUTED);
   y += 18;

   P_Row2(y,
      "D ctr",  DoubleToString(g_anchor_D_ctr, 4), CLR_MUTED,
      "Est gr", EstadoStr(g_estado_pendentes), CLR_TEXT);
   y += 18;

   P_Row2(y,
      "Pend",   IntegerToString(n_ord), CLR_ACCENT,
      "Pos",    IntegerToString(n_pos), (n_pos > 0 ? CLR_YELLOW : CLR_MUTED));
   y += 24;

   // ===== P&L =====
   P_Section(y, "P&L  DIA", CLR_YELLOW);  y += 22;

   color plClr = (g_pl_dia >= 0 ? CLR_GREEN : CLR_RED);
   string plStr = (g_pl_dia >= 0 ? "+" : "") + DoubleToString(g_pl_dia, 2) + " USD";
   string metaStr = DoubleToString(InpMetaLucroDiaria, 0) + " / " +
                    DoubleToString(InpPerdaMaxDiaria, 0);

   P_Row2(y,
      "Result", plStr, plClr,
      "Meta",   metaStr, CLR_MUTED);
}

//+------------------------------------------------------------------+
//| Limpa todos os objetos do painel                                 |
//+------------------------------------------------------------------+
void P_Clear()
{
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
}

//==================================================================//
//                            CICLO DE VIDA                          //
//==================================================================//
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagico);
   trade.SetDeviationInPoints(InpSlippage);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetAsyncMode(false);

   if(!sym.Name(_Symbol)) return INIT_FAILED;
   sym.RefreshRates();

   g_digitos   = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   g_ponto     = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   g_tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(g_tick_size <= 0) g_tick_size = g_ponto;

   double tick_val = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tick_val <= 0) tick_val = 0.01;
   g_valor_por_ponto = tick_val * (g_ponto / g_tick_size);

   ArrayInitialize(g_spread_buf, 0);
   ArrayResize(g_pos_info, 0);

   AtualizarATR();
   AtualizarSpread((sym.Ask() - sym.Bid()) / g_ponto);

   MqlRates r[];
   int total = CopyRates(_Symbol, PERIOD_M1, 0, 3, r);
   if(total >= 2) g_ultima_vela_m1 = r[total-2].time;

   g_dia_atual = DiaAtual();
   CalcularSinal();

   // Remove objetos antigos e desenha painel vazio
   P_Clear();
   P_Draw(sym.Ask() - sym.Bid());

   PrintFormat("EA HFT XAU v1.05 OK | Ponto=%.5f Dig=%d TickVal=%.4f ValPonto=%.4f | ATRmed=%.5f | Score=%.3f Dir=%d",
               g_ponto, g_digitos, tick_val, g_valor_por_ponto,
               g_atr_med, g_score_ultimo, g_dir_ultimo);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   P_Clear();
}

//+------------------------------------------------------------------+
datetime DiaAtual()
{
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   return StructToTime(dt);
}

double PLDoDia()
{
   if(!HistorySelect(g_dia_atual, TimeCurrent())) return 0;
   double lucro = 0;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong tk = HistoryDealGetTicket(i);
      if(tk == 0) continue;
      if(HistoryDealGetString(tk, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(tk, DEAL_MAGIC) != InpMagico) continue;
      if(HistoryDealGetInteger(tk, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      lucro += HistoryDealGetDouble(tk, DEAL_PROFIT)
             + HistoryDealGetDouble(tk, DEAL_SWAP)
             + HistoryDealGetDouble(tk, DEAL_COMMISSION);
   }
   return lucro;
}

void FecharTudo(string motivo)
{
   Print("FECHAR TUDO: ", motivo);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagico) continue;
      trade.PositionClose(tk);
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong tk = OrderGetTicket(i);
      if(tk == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC) != InpMagico) continue;
      trade.OrderDelete(tk);
   }
   ArrayResize(g_pos_info, 0);
   g_anchor_valido = false;
}

void FecharPendentes()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong tk = OrderGetTicket(i);
      if(tk == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC) != InpMagico) continue;
      ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(ot != ORDER_TYPE_BUY_STOP && ot != ORDER_TYPE_SELL_STOP) continue;
      trade.OrderDelete(tk);
   }
}

//+------------------------------------------------------------------+
void OnTick()
{
   sym.RefreshRates();
   double bid = sym.Bid();
   double ask = sym.Ask();
   if(bid <= 0 || ask <= 0) return;

   double mid           = (bid + ask) * 0.5;
   double spread_pontos = (ask - bid) / g_ponto;
   double spread_preco  = ask - bid;

   AtualizarSpread(spread_pontos);
   AtualizarATR();

   ProcessarOrdensAbertas(bid, ask);

   uint agora = GetTickCount();
   if(agora - g_ultimo_check_ms < (uint)InpTickThrottleMs)
   {
      P_Draw(spread_preco);
      return;
   }
   g_ultimo_check_ms = agora;

   datetime hoje = DiaAtual();
   if(hoje != g_dia_atual) { g_dia_atual = hoje; g_meta_batida = false; }
   g_pl_dia = PLDoDia();

   string motivo = "";

   if(InpMetaLucroDiaria > 0 && g_pl_dia >= InpMetaLucroDiaria)
   {
      if(!g_meta_batida) { g_meta_batida = true; FecharTudo("META_LUCRO " + DoubleToString(g_pl_dia,2)); }
      motivo = "META_LUCRO_BATIDA";
   }
   else if(InpPerdaMaxDiaria > 0 && g_pl_dia <= -InpPerdaMaxDiaria)
   {
      if(!g_meta_batida) { g_meta_batida = true; FecharTudo("META_PERDA " + DoubleToString(g_pl_dia,2)); }
      motivo = "META_PERDA_BATIDA";
   }

   if(motivo == "" && InpUsarSessao && !PassouFiltroSessao()) motivo = "FORA_SESSAO";
   if(motivo == "" && InpTravaAtiva && TimeCurrent() < g_trava_ate)
   { g_estado = EST_PAUSA; motivo = "TRAVA_ATIVA"; }
   if(motivo == "" && !PassouFiltroNews()) motivo = "NEWS_PAUSA";
   if(motivo == "" && spread_preco > InpSpreadMaxPreco) motivo = "SPREAD_ALTO";

   if(motivo == "")
   {
      if(DetectarNovaVela()) CalcularSinal();
      AtualizarEstadoGrid();
      if(g_estado == EST_PAUSA) motivo = "ESTADO_PAUSA";
      else GerenciarPendentes(mid, spread_pontos);
   }

   g_diag = motivo;
   P_Draw(spread_preco);
}

//+------------------------------------------------------------------+
void AtualizarSpread(double sp)
{
   g_spread_buf[g_spread_idx] = sp;
   g_spread_idx = (g_spread_idx + 1) % 100;
   if(g_spread_count < 100) g_spread_count++;
   double soma = 0;
   for(int i = 0; i < g_spread_count; i++) soma += g_spread_buf[i];
   g_spread_med = (g_spread_count > 0) ? soma / g_spread_count : sp;
}

void AtualizarATR()
{
   MqlRates r[];
   int n = CopyRates(_Symbol, PERIOD_M1, 1, 25, r);
   if(n < 21) return;
   double buf[20];
   for(int i = 0; i < 20; i++)
   {
      double tr = MathMax(r[i].high - r[i].low,
                  MathMax(MathAbs(r[i].high - r[i+1].close),
                          MathAbs(r[i].low  - r[i+1].close)));
      buf[i] = tr;
   }
   g_atr_atual = buf[0];
   ArraySort(buf);
   g_atr_med = (buf[9] + buf[10]) * 0.5;
}

double VolRelativa()
{
   if(g_atr_med <= 0) return 1.0;
   return g_atr_atual / g_atr_med;
}

bool DetectarNovaVela()
{
   MqlRates r[];
   int n = CopyRates(_Symbol, PERIOD_M1, 0, 3, r);
   if(n < 2) return false;
   datetime t = r[n-2].time;
   if(t != g_ultima_vela_m1) { g_ultima_vela_m1 = t; return true; }
   return false;
}

void CalcularSinal()
{
   MqlRates r[];
   int n = CopyRates(_Symbol, PERIOD_M1, 1, 22, r);
   if(n < 21) { g_sinal_recuo = 0; return; }

   double O = r[0].open, H = r[0].high, L = r[0].low, C = r[0].close;
   long   V = r[0].tick_volume;
   double range = H - L;
   if(range <= 0) { g_sinal_recuo = 0; return; }

   double body  = MathAbs(C - O);
   double ratio = body / range;

   double soma = 0;
   for(int k = 1; k <= 20; k++) soma += (double)r[k].tick_volume;
   double Vmed = soma / 20.0;

   double comp_ratio = ratio;
   double comp_body  = MathMin(body / MathMax(g_atr_med, g_ponto), 1.5) / 1.5;
   double comp_vol   = MathMin((double)V / MathMax(Vmed, 1.0), 2.0) / 2.0;
   double comp_dir   = ratio;
   g_score_ultimo = 0.40*comp_ratio + 0.30*comp_body + 0.20*comp_vol + 0.10*comp_dir;

   if(C > O)      g_dir_ultimo = 1;
   else if(C < O) g_dir_ultimo = -1;

   g_sinal_recuo = 0;
   double upper = H - MathMax(O, C);
   double lower = MathMin(O, C) - L;
   if(range > 1.5 * g_atr_med)
   {
      if(lower > 0.5 * range) g_sinal_recuo = 1;
      if(upper > 0.5 * range) g_sinal_recuo = -1;
   }
}

bool PassouFiltroSessao()
{
   if(!InpUsarSessao) return true;
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   int h = dt.hour;
   if(InpSessaoIniHora <= InpSessaoFimHora)
      return (h >= InpSessaoIniHora && h < InpSessaoFimHora);
   return (h >= InpSessaoIniHora || h < InpSessaoFimHora);
}

bool PassouFiltroNews()
{
   if(!InpFiltroNews) return true;
   if(TimeCurrent() < g_news_pausa_ate) return false;
   if(g_atr_med > 0 && g_atr_atual > InpNewsATRMult * g_atr_med)
   { g_news_pausa_ate = TimeCurrent() + InpNewsPausaSeg; return false; }
   return true;
}

void AtualizarEstadoGrid()
{
   if(g_estado == EST_PAUSA)
   {
      if(!InpTravaAtiva || TimeCurrent() >= g_trava_ate) g_estado = EST_ESTAVEL;
      else return;
   }
   if(g_sinal_recuo != 0) { g_estado = EST_RECUO; return; }

   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagico) continue;
      datetime t = (datetime)PositionGetInteger(POSITION_TIME);
      if(TimeCurrent() - t < 60)
      {
         ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(pt == POSITION_TYPE_BUY)  { g_estado = EST_ESTOUROU_UP; return; }
         if(pt == POSITION_TYPE_SELL) { g_estado = EST_ESTOUROU_DN; return; }
      }
   }
   g_estado = EST_ESTAVEL;
}

double StopsLevelPrice()
{
   long pts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   return (double)pts * g_ponto;
}

double NormalizarPreco(double p)
{
   double ts = g_tick_size;
   if(ts <= 0) ts = g_ponto;
   return NormalizeDouble(MathRound(p / ts) * ts, g_digitos);
}

//+------------------------------------------------------------------+
//| Grid ancorado                                                    |
//+------------------------------------------------------------------+
void GerenciarPendentes(double mid, double spread_pontos)
{
   if(g_atr_med <= 0) return;

   double m_fav, m_ctr;
   if(g_score_ultimo >= InpScoreForte)      { m_fav = InpMFavForte;      m_ctr = InpMCtrForte; }
   else if(g_score_ultimo >= InpScoreFraca) { m_fav = InpMFavFraca;      m_ctr = InpMCtrFraca; }
   else                                     { m_fav = InpMFavMuitoFraca; m_ctr = InpMCtrMuitoFraca; }

   double ajuste = 1.0;
   if(g_spread_med > 0 && spread_pontos < g_spread_med * 0.8) ajuste = InpAjusteSpreadBarato;

   double mult_ctr_estado = 1.0;
   if(g_estado == EST_ESTOUROU_UP || g_estado == EST_ESTOUROU_DN) mult_ctr_estado = InpMultiEstouro;
   else if(g_estado == EST_RECUO)                                  mult_ctr_estado = InpMultiRecuo;

   double D_fav = g_atr_med * InpKdist * m_fav * ajuste;
   double D_ctr = g_atr_med * InpKdist * m_ctr * ajuste * mult_ctr_estado;

   double d_min = MathMax(3 * (sym.Ask() - sym.Bid()), 5 * g_ponto);
   if(D_fav < d_min) D_fav = d_min;
   if(D_ctr < d_min) D_ctr = d_min;

   bool reancorar = false;
   if(!g_anchor_valido)                                       reancorar = true;
   if(g_dir_ultimo != g_dir_pendentes)                        reancorar = true;
   if(g_estado != g_estado_pendentes)                         reancorar = true;
   if(g_anchor_valido && g_atr_med > 0 &&
      MathAbs(mid - g_anchor_mid) > InpDriftRecenterATR * g_atr_med)
                                                              reancorar = true;

   if(reancorar)
   {
      FecharPendentes();
      g_anchor_mid       = mid;
      g_anchor_D_fav     = D_fav;
      g_anchor_D_ctr     = D_ctr;
      g_dir_pendentes    = g_dir_ultimo;
      g_estado_pendentes = g_estado;
      g_anchor_valido    = true;
   }

   ENUM_ORDER_TYPE tipo_fav, tipo_ctr;
   if(g_dir_ultimo >= 0) { tipo_fav = ORDER_TYPE_BUY_STOP;  tipo_ctr = ORDER_TYPE_SELL_STOP; }
   else                  { tipo_fav = ORDER_TYPE_SELL_STOP; tipo_ctr = ORDER_TYPE_BUY_STOP;  }

   int n_bs = 0, n_ss = 0, n_pb = 0, n_ps = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong tk = OrderGetTicket(i);
      if(tk == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC) != InpMagico) continue;
      ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(ot == ORDER_TYPE_BUY_STOP)  n_bs++;
      if(ot == ORDER_TYPE_SELL_STOP) n_ss++;
   }
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagico) continue;
      ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(pt == POSITION_TYPE_BUY)  n_pb++;
      if(pt == POSITION_TYPE_SELL) n_ps++;
   }

   int exist_fav = (tipo_fav == ORDER_TYPE_BUY_STOP) ? (n_bs + n_pb) : (n_ss + n_ps);
   int exist_ctr = (tipo_ctr == ORDER_TYPE_BUY_STOP) ? (n_bs + n_pb) : (n_ss + n_ps);

   double min_d = StopsLevelPrice();
   if(min_d <= 0) min_d = 2 * g_tick_size;

   for(int k = exist_fav; k < InpNfavor; k++)
   {
      double dist  = g_anchor_D_fav * (1.0 + InpEscFav * k);
      double preco = (tipo_fav == ORDER_TYPE_BUY_STOP) ? g_anchor_mid + dist
                                                       : g_anchor_mid - dist;
      if(tipo_fav == ORDER_TYPE_BUY_STOP  && preco < sym.Ask() + min_d) continue;
      if(tipo_fav == ORDER_TYPE_SELL_STOP && preco > sym.Bid() - min_d) continue;
      preco = NormalizarPreco(preco);

      if(!trade.OrderOpen(_Symbol, tipo_fav, InpLote, 0.0, preco, 0.0, 0.0,
                          ORDER_TIME_GTC, 0, "HF_FAV_" + IntegerToString(k+1)))
      {
         PrintFormat("Falha FAV k=%d preco=%.5f ret=%d %s",
                     k, preco, trade.ResultRetcode(), trade.ResultRetcodeDescription());
      }
   }

   for(int k = exist_ctr; k < InpNcontra; k++)
   {
      double dist  = g_anchor_D_ctr * (1.0 + InpEscCtr * k);
      double preco = (tipo_ctr == ORDER_TYPE_BUY_STOP) ? g_anchor_mid + dist
                                                       : g_anchor_mid - dist;
      if(tipo_ctr == ORDER_TYPE_BUY_STOP  && preco < sym.Ask() + min_d) continue;
      if(tipo_ctr == ORDER_TYPE_SELL_STOP && preco > sym.Bid() - min_d) continue;
      preco = NormalizarPreco(preco);

      if(!trade.OrderOpen(_Symbol, tipo_ctr, InpLote, 0.0, preco, 0.0, 0.0,
                          ORDER_TIME_GTC, 0, "HF_CTR_" + IntegerToString(k+1)))
      {
         PrintFormat("Falha CTR k=%d preco=%.5f ret=%d %s",
                     k, preco, trade.ResultRetcode(), trade.ResultRetcodeDescription());
      }
   }
}

//+------------------------------------------------------------------+
void ProcessarOrdensAbertas(double bid, double ask)
{
   SincronizarPosicoes();

   for(int i = 0; i < ArraySize(g_pos_info); i++)
   {
      ulong tk = g_pos_info[i].ticket;
      if(!PositionSelectByTicket(tk)) continue;

      ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double preco_open = PositionGetDouble(POSITION_PRICE_OPEN);
      double tp = PositionGetDouble(POSITION_TP);
      double sl = PositionGetDouble(POSITION_SL);

      double preco_atual = (pt == POSITION_TYPE_BUY) ? bid : ask;
      double tp_dist = g_pos_info[i].tp_dist;
      if(tp_dist <= 0) continue;

      double lucro_pts = (pt == POSITION_TYPE_BUY) ? (preco_atual - preco_open)
                                                   : (preco_open - preco_atual);
      double ativacao = tp_dist * InpTrailAtivPct;

      if(!g_pos_info[i].trail_ativo && lucro_pts >= ativacao)
      {
         g_pos_info[i].trail_ativo = true;
         g_pos_info[i].peak = preco_atual;
      }

      if(g_pos_info[i].trail_ativo)
      {
         if(pt == POSITION_TYPE_BUY  && preco_atual > g_pos_info[i].peak) g_pos_info[i].peak = preco_atual;
         if(pt == POSITION_TYPE_SELL && preco_atual < g_pos_info[i].peak) g_pos_info[i].peak = preco_atual;

         double recuo   = tp_dist * InpTrailRecuoPct;
         double novo_sl = (pt == POSITION_TYPE_BUY) ? g_pos_info[i].peak - recuo
                                                    : g_pos_info[i].peak + recuo;

         if(pt == POSITION_TYPE_BUY)
         { double piso = preco_open + g_tick_size; if(novo_sl < piso) novo_sl = piso; }
         else
         { double teto = preco_open - g_tick_size; if(novo_sl > teto) novo_sl = teto; }

         novo_sl = NormalizarPreco(novo_sl);

         if(pt == POSITION_TYPE_BUY  && (sl <= 0 || novo_sl > sl + g_tick_size))
            trade.PositionModify(tk, novo_sl, tp);
         else if(pt == POSITION_TYPE_SELL && (sl <= 0 || novo_sl < sl - g_tick_size))
            trade.PositionModify(tk, novo_sl, tp);
      }
   }

   if(InpTravaAtiva) VerificarTrava();
}

void SincronizarPosicoes()
{
   int total = ArraySize(g_pos_info);
   for(int i = total - 1; i >= 0; i--)
   {
      if(!PositionSelectByTicket(g_pos_info[i].ticket))
      {
         for(int j = i; j < total - 1; j++) g_pos_info[j] = g_pos_info[j+1];
         ArrayResize(g_pos_info, total - 1);
         total--;
      }
   }

   int tot_pos = PositionsTotal();
   for(int i = 0; i < tot_pos; i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagico) continue;

      bool existe = false;
      for(int j = 0; j < ArraySize(g_pos_info); j++)
         if(g_pos_info[j].ticket == tk) { existe = true; break; }
      if(existe) continue;

      double vol_rel = VolRelativa();
      double f_tp = (vol_rel > 1.5) ? InpFTPAltaVol
                  : (vol_rel >= 0.7) ? InpFTPNormVol
                                     : InpFTPBaixaVol;
      double tp_dist = g_atr_atual * f_tp;
      if(tp_dist <= 0) tp_dist = 100 * g_ponto;

      if(g_valor_por_ponto > 0 && InpLote > 0 && InpLucroPorOrdem > 0)
      {
         double tp_min = (InpLucroPorOrdem / g_valor_por_ponto / InpLote) * g_ponto;
         if(tp_dist < tp_min) tp_dist = tp_min;
      }

      ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double preco_open = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl_atual = PositionGetDouble(POSITION_SL);
      double tp_atual = PositionGetDouble(POSITION_TP);

      double tp_preco = (pt == POSITION_TYPE_BUY) ? NormalizarPreco(preco_open + tp_dist)
                                                  : NormalizarPreco(preco_open - tp_dist);

      if(tp_atual <= 0)
      {
         if(!trade.PositionModify(tk, sl_atual, tp_preco))
            PrintFormat("Falha TP tk=%I64u ret=%d", tk, trade.ResultRetcode());
      }

      SPosInfo info;
      info.ticket = tk;
      info.tp_dist = tp_dist;
      info.preco_open = preco_open;
      info.peak = preco_open;
      info.trail_ativo = false;

      int n = ArraySize(g_pos_info);
      ArrayResize(g_pos_info, n+1);
      g_pos_info[n] = info;
   }
}

void VerificarTrava()
{
   if(!InpTravaAtiva) return;

   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dd = (balance > 0) ? (equity - balance) / balance * 100.0 : 0.0;

   int cont = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagico) continue;
      cont++;
   }

   bool dispara = false;
   if(dd <= -InpTravaDDPct)     { Print("TRAVA DD ", dd); dispara = true; }
   if(cont > InpTravaMaxOrdens) { Print("TRAVA Ordens ", cont); dispara = true; }
   if(!dispara) return;

   FecharTudo("TRAVA GLOBAL");
   g_estado = EST_PAUSA;
   g_trava_ate = TimeCurrent() + InpCooldownTravaMin * 60;
}

//+------------------------------------------------------------------+
string EstadoStr(EEstadoGrid e)
{
   switch(e)
   {
      case EST_ESTAVEL:     return "ESTAVEL";
      case EST_ESTOUROU_UP: return "ESTOUROU+";
      case EST_ESTOUROU_DN: return "ESTOUROU-";
      case EST_RECUO:       return "RECUO";
      case EST_PAUSA:       return "PAUSA";
   }
   return "?";
}
//+------------------------------------------------------------------+