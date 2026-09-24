//+------------------------------------------------------------------+
//|                                                FluxoForcado.mq5  |
//|  "Fluxo Forçado" — momentum intradiário de fechamento (US500)    |
//|                                                                  |
//|  Tese: nos últimos ~30 min do pregão à vista de NY, fluxos que   |
//|  NÃO são discricionários (rebalanceamento de ETFs alavancados,   |
//|  hedge de gamma dos dealers de opções, ordens MOC de fundos)     |
//|  empurram o preço na MESMA direção do movimento do dia.          |
//|  O EA pega carona nesse fluxo: entra às 15:30 NY na direção do   |
//|  retorno do dia (se ele for grande o bastante) e sai às 15:58.   |
//|                                                                  |
//|  Referências: Gao, Han, Li & Zhou (2018, JFE) "Market Intraday   |
//|  Momentum"; Baltussen, Da, Lammers & Martens (2021, JFE)         |
//|  "Hedging demand and market intraday momentum".                  |
//|                                                                  |
//|  Uma operação por dia, nunca dorme posicionado (zero swap).      |
//+------------------------------------------------------------------+
#property copyright "lztrading"
#property version   "1.00"
#property description "Momentum de fechamento guiado por fluxo forçado (LETF + gamma + MOC)."
#property description "Entrada 15:30 NY, saída 15:58 NY. Uma operação por dia. Sem overnight."

#include <Trade/Trade.mqh>

//--- Regra de horário de verão do SERVIDOR da corretora
enum ENUM_SERVER_DST
  {
   SRV_DST_NONE = 0, // Sem horário de verão (offset fixo)
   SRV_DST_US   = 1, // Segue horário de verão dos EUA (mais comum: GMT+2/+3)
   SRV_DST_EU   = 2  // Segue horário de verão europeu
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== Relógio: servidor -> Nova York (CONFIRA NO GRÁFICO) ==="
input int             InpServerGMTOffset = 2;          // Offset GMT do servidor no INVERNO (horas)
input ENUM_SERVER_DST InpServerDST       = SRV_DST_US; // Regra de horário de verão do servidor

input group "=== Sinal — valores FIXOS da tese. NÃO otimize. ==="
input int    InpSignalHourNY   = 15;   // Hora NY do sinal/entrada
input int    InpSignalMinuteNY = 30;   // Minuto NY do sinal/entrada
input int    InpExitHourNY     = 15;   // Hora NY da saída por tempo
input int    InpExitMinuteNY   = 58;   // Minuto NY da saída por tempo
input int    InpEntryWindowMin = 5;    // Janela máx. p/ entrar após o sinal (min)
input int    InpLookbackDays   = 20;   // Dias p/ medir a volatilidade "normal"
input double InpThresholdK     = 1.0;  // Mínimo |retorno do dia| em múltiplos da média
input bool   InpPlaceboInvert  = false;// PLACEBO: inverte a direção (só p/ validar no backtest)

input group "=== Risco ==="
input double InpRiskPercent    = 0.50; // Risco por trade (% do equity) até o stop
input double InpStopMult       = 2.5;  // Stop catastrófico em múltiplos do movimento médio dos últimos 28 min
input double InpMaxSpreadFrac  = 0.10; // Spread máx. como fração da distância do stop
input bool   InpOnePerMagic    = true; // Bloqueia 2ª posição do mesmo magic em outro símbolo (US500 x US100 = mesma aposta)

input group "=== Desligamento automático (kill switch) ==="
input bool   InpKillEnabled    = true;  // Ativa kill switch (DESLIGUE no 1º backtest p/ ver a edge crua)
input double InpMaxDDPercent   = 15.0;  // Desliga se equity cair X% do pico
input int    InpKillWindow     = 60;    // Nº de trades da janela estatística
input double InpKillTStat      = -1.5;  // Desliga se t-stat da janela ficar abaixo disto

input group "=== Execução ==="
input ulong  InpMagic          = 20260924; // Magic number
input int    InpDeviationPts   = 30;       // Desvio máximo (pontos)

//+------------------------------------------------------------------+
//| Globais                                                          |
//+------------------------------------------------------------------+
CTrade   g_trade;
datetime g_lastDecisionDay = 0;   // dia NY (00:00) em que já decidimos (operar ou não)
bool     g_killed          = false;
double   g_rets[];                // retornos por trade (fração do saldo), mais antigo primeiro
string   g_gvPeak, g_gvKill;

//+------------------------------------------------------------------+
//| Utilidades de calendário                                         |
//+------------------------------------------------------------------+
datetime MakeDate(const int y, const int m, const int d, const int h = 0)
  {
   MqlDateTime s;
   ZeroMemory(s);
   s.year = y; s.mon = m; s.day = d; s.hour = h;
   return StructToTime(s);
  }

// n-ésimo domingo de um mês (n = 1, 2, ...)
datetime NthSunday(const int y, const int m, const int n)
  {
   MqlDateTime s;
   TimeToStruct(MakeDate(y, m, 1), s);
   int firstSun = 1 + (7 - s.day_of_week) % 7;
   return MakeDate(y, m, firstSun + 7 * (n - 1));
  }

// último domingo de um mês
datetime LastSunday(const int y, const int m)
  {
   int ny = (m == 12) ? y + 1 : y;
   int nm = (m == 12) ? 1 : m + 1;
   datetime lastDay = MakeDate(ny, nm, 1) - 86400;
   MqlDateTime s;
   TimeToStruct(lastDay, s);
   return lastDay - s.day_of_week * 86400;
  }

// Horário de verão dos EUA: 2º domingo de março 02:00 -> 1º domingo de novembro 02:00.
// Recebe um horário "de parede" americano; a imprecisão de 1h na madrugada da troca é irrelevante
// para um EA que só age às 15:30.
bool IsUSDST(const datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   datetime start = NthSunday(s.year, 3, 2) + 2 * 3600;
   datetime end   = NthSunday(s.year, 11, 1) + 2 * 3600;
   return (t >= start && t < end);
  }

// Horário de verão europeu: último domingo de março 01:00 UTC -> último domingo de outubro 01:00 UTC.
bool IsEUDST(const datetime gmt)
  {
   MqlDateTime s;
   TimeToStruct(gmt, s);
   datetime start = LastSunday(s.year, 3) + 3600;
   datetime end   = LastSunday(s.year, 10) + 3600;
   return (gmt >= start && gmt < end);
  }

int ServerOffsetHours(const datetime gmt)
  {
   int off = InpServerGMTOffset;
   if(InpServerDST == SRV_DST_US && IsUSDST(gmt - 5 * 3600))
      off += 1;
   if(InpServerDST == SRV_DST_EU && IsEUDST(gmt))
      off += 1;
   return off;
  }

// NY (hora local) -> horário do servidor
datetime NYToServer(const datetime ny)
  {
   datetime gmt = ny + 5 * 3600 - (IsUSDST(ny) ? 3600 : 0);
   return gmt + ServerOffsetHours(gmt) * 3600;
  }

// Horário do servidor -> NY (hora local)
datetime ServerToNY(const datetime srv)
  {
   // 1ª aproximação com offset de inverno, depois corrige com a regra de DST
   datetime gmt = srv - InpServerGMTOffset * 3600;
   gmt = srv - ServerOffsetHours(gmt) * 3600;
   datetime ny = gmt - 5 * 3600;
   if(IsUSDST(ny))
      ny += 3600;
   return ny;
  }

datetime DayStart(const datetime t) { return (datetime)((long)t - (long)t % 86400); }

bool IsWeekday(const datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return (s.day_of_week >= 1 && s.day_of_week <= 5);
  }

//+------------------------------------------------------------------+
//| Preço "no instante" NY t = fechamento do candle M1 que termina   |
//| em t. Retorna 0 se o candle não existir (feriado, meio pregão,   |
//| buraco de dados). Sem look-ahead: só usa candles fechados.       |
//+------------------------------------------------------------------+
double PriceAtNY(const datetime nyT)
  {
   datetime barOpen = NYToServer(nyT) - 60;
   int shift = iBarShift(_Symbol, PERIOD_M1, barOpen, false);
   if(shift < 0)
      return 0.0;
   datetime bt = iTime(_Symbol, PERIOD_M1, shift);
   if(bt <= 0 || bt > barOpen || barOpen - bt > 3 * 60)
      return 0.0;                     // candle ausente ou velho demais -> dado inválido
   if(bt == barOpen && shift == 0)
      return 0.0;                     // candle ainda em formação -> não usar
   return iClose(_Symbol, PERIOD_M1, shift);
  }

// Fechamento do pregão à vista (16:00 NY) do último dia útil ANTERIOR a nyDay
double PrevCashClose(const datetime nyDay)
  {
   for(int j = 1; j <= 6; j++)
     {
      datetime d = nyDay - j * 86400;
      if(!IsWeekday(d))
         continue;
      double p = PriceAtNY(d + 16 * 3600);
      if(p > 0.0)
         return p;
     }
   return 0.0;
  }

//+------------------------------------------------------------------+
//| Estatísticas dos últimos N pregões:                              |
//|  madDay = média de |ln(P_15:30 / P_fech_anterior)|                |
//|  madEnd = média de |ln(P_15:58 / P_15:30)|                         |
//+------------------------------------------------------------------+
bool HistoryStats(const datetime nyDay, double &madDay, double &madEnd)
  {
   int sigSec = (InpSignalHourNY * 60 + InpSignalMinuteNY) * 60;
   int exSec  = (InpExitHourNY * 60 + InpExitMinuteNY) * 60;
   double sDay = 0.0, sEnd = 0.0;
   int got = 0;
   for(int k = 1; k <= InpLookbackDays * 2 + 15 && got < InpLookbackDays; k++)
     {
      datetime d = nyDay - k * 86400;
      if(!IsWeekday(d))
         continue;
      double pPrev = PrevCashClose(d);
      double pSig  = PriceAtNY(d + sigSec);
      double pEx   = PriceAtNY(d + exSec);
      if(pPrev <= 0.0 || pSig <= 0.0 || pEx <= 0.0)
         continue;
      sDay += MathAbs(MathLog(pSig / pPrev));
      sEnd += MathAbs(MathLog(pEx / pSig));
      got++;
     }
   if(got < (int)MathCeil(InpLookbackDays * 0.75))
      return false;
   madDay = sDay / got;
   madEnd = sEnd / got;
   return (madDay > 0.0 && madEnd > 0.0);
  }

//+------------------------------------------------------------------+
//| Posições                                                         |
//+------------------------------------------------------------------+
bool HasOurPosition(const bool anySymbol)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      if(anySymbol || PositionGetString(POSITION_SYMBOL) == _Symbol)
         return true;
     }
   return false;
  }

void CloseOurPositions(const string why)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(g_trade.PositionClose(ticket))
         PrintFormat("[FF] Fechada #%I64u (%s)", ticket, why);
      else
         PrintFormat("[FF] ERRO ao fechar #%I64u (%s): %d %s", ticket, why,
                     g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
     }
  }

// Já houve entrada deste EA/símbolo hoje (protege contra reinício do terminal)?
bool EnteredToday(const datetime nyDay)
  {
   datetime srvFrom = NYToServer(nyDay);
   if(!HistorySelect(srvFrom, TimeCurrent() + 60))
      return false;
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0)
         continue;
      if((ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == InpMagic &&
         HistoryDealGetString(d, DEAL_SYMBOL) == _Symbol &&
         HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_IN)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Kill switch                                                      |
//+------------------------------------------------------------------+
void PushReturn(const double r)
  {
   int n = ArraySize(g_rets);
   if(n >= InpKillWindow && n > 0)
     {
      for(int i = 1; i < n; i++)               // descarta o mais antigo
         g_rets[i - 1] = g_rets[i];
      g_rets[n - 1] = r;
     }
   else
     {
      ArrayResize(g_rets, n + 1);
      g_rets[n] = r;
     }
  }

// Reconstrói retornos por trade a partir do histórico (reinício do terminal).
// Anda do saldo atual para trás: saldo_antes = saldo_depois - resultado_do_deal.
void RebuildReturns()
  {
   ArrayResize(g_rets, 0);
   if(!HistorySelect(0, TimeCurrent() + 60))
      return;
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double tmp[];
   int cnt = 0;
   for(int i = HistoryDealsTotal() - 1; i >= 0 && cnt < InpKillWindow; i--)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0)
         continue;
      double net = HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) +
                   HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
      bool ours = ((ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == InpMagic &&
                   HistoryDealGetString(d, DEAL_SYMBOL) == _Symbol &&
                   HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_OUT);
      double before = bal - net;
      if(ours && before > 0.0)
        {
         ArrayResize(tmp, cnt + 1);
         tmp[cnt++] = net / before;
        }
      bal = before;
     }
   // tmp está do mais novo para o mais antigo -> inverter
   for(int i = cnt - 1; i >= 0; i--)
      PushReturn(tmp[i]);
  }

void Kill(const string why)
  {
   if(g_killed)
      return;
   g_killed = true;
   GlobalVariableSet(g_gvKill, 1.0);
   CloseOurPositions("kill switch");
   string msg = StringFormat("[FF] EA DESLIGADO em %s: %s. Para religar: apague a variável global '%s' (F3) "
                             "e reavalie a estratégia ANTES.", _Symbol, why, g_gvKill);
   Print(msg);
   if(!MQLInfoInteger(MQL_TESTER))
      Alert(msg);
  }

void CheckKillSwitch()
  {
   if(!InpKillEnabled || g_killed)
      return;
   // 1) Drawdown do pico de equity
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   double peak = GlobalVariableCheck(g_gvPeak) ? GlobalVariableGet(g_gvPeak) : eq;
   if(eq > peak)
      peak = eq;
   GlobalVariableSet(g_gvPeak, peak);
   if(peak > 0.0 && (peak - eq) / peak * 100.0 >= InpMaxDDPercent)
     {
      Kill(StringFormat("drawdown %.1f%% >= %.1f%%", (peak - eq) / peak * 100.0, InpMaxDDPercent));
      return;
     }
   // 2) Evidência estatística de que a edge morreu
   int n = ArraySize(g_rets);
   if(n < InpKillWindow || n < 2)
      return;
   double m = 0.0, v = 0.0;
   for(int i = 0; i < n; i++)
      m += g_rets[i];
   m /= n;
   for(int i = 0; i < n; i++)
      v += (g_rets[i] - m) * (g_rets[i] - m);
   v /= (n - 1);
   if(v <= 0.0)
      return;
   double t = m / MathSqrt(v / n);
   if(t < InpKillTStat)
      Kill(StringFormat("t-stat dos últimos %d trades = %.2f < %.2f", n, t, InpKillTStat));
  }

//+------------------------------------------------------------------+
//| Tamanho de posição: arrisca InpRiskPercent do equity até o stop  |
//+------------------------------------------------------------------+
double LotsForRisk(const double stopDist)
  {
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue <= 0.0)
      tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(tickSize <= 0.0 || tickValue <= 0.0 || step <= 0.0 || stopDist <= 0.0)
      return 0.0;
   double riskMoney   = AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskPercent / 100.0;
   double lossPerLot  = stopDist / tickSize * tickValue;
   double lots        = MathFloor(riskMoney / lossPerLot / step) * step;
   if(lots < vmin)
      return 0.0;              // não arredonda PARA CIMA: preferimos não operar a arriscar mais
   return MathMin(lots, vmax);
  }

//+------------------------------------------------------------------+
//| Decisão de entrada (roda 1x por dia, às 15:30 NY)                |
//+------------------------------------------------------------------+
// Retorna true se a decisão do dia foi tomada (operou ou decidiu não operar).
// Retorna false se faltou dado e vale tentar de novo no próximo tick.
bool TryEntry(const datetime nyDay)
  {
   int sigSec = (InpSignalHourNY * 60 + InpSignalMinuteNY) * 60;

   double pPrev = PrevCashClose(nyDay);
   double pSig  = PriceAtNY(nyDay + sigSec);
   if(pPrev <= 0.0 || pSig <= 0.0)
      return false;

   double madDay, madEnd;
   if(!HistoryStats(nyDay, madDay, madEnd))
      return false;

   double r = MathLog(pSig / pPrev);
   if(MathAbs(r) < InpThresholdK * madDay)
     {
      PrintFormat("[FF] %s sem sinal: |r|=%.3f%% < %.2f x %.3f%%",
                  TimeToString(nyDay, TIME_DATE), MathAbs(r) * 100, InpThresholdK, madDay * 100);
      return true;
     }

   if(InpOnePerMagic && HasOurPosition(true))
     {
      Print("[FF] Já existe posição deste magic em outro símbolo: mesma aposta, pulando.");
      return true;
     }

   MqlTick tk;
   if(!SymbolInfoTick(_Symbol, tk) || tk.bid <= 0.0 || tk.ask <= 0.0)
      return false;

   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double stopDist = InpStopMult * madEnd * pSig;
   double spread   = tk.ask - tk.bid;
   double minStop  = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + 5) * _Point;
   stopDist = MathMax(stopDist, MathMax(minStop, 10.0 * spread));
   stopDist = MathCeil(stopDist / tickSize) * tickSize;

   if(spread > InpMaxSpreadFrac * stopDist)
     {
      PrintFormat("[FF] Spread %.2f > %.0f%% do stop %.2f. Tentando no próximo tick.",
                  spread, InpMaxSpreadFrac * 100, stopDist);
      return false;             // o spread pode normalizar dentro da janela
     }

   double lots = LotsForRisk(stopDist);
   if(lots <= 0.0)
     {
      Print("[FF] Lote calculado abaixo do mínimo da corretora. Conta pequena demais para este risco.");
      return true;
     }

   bool ok;
   string cmt = StringFormat("FF r=%.2f%%", r * 100);
   bool goLong = (r > 0);
   if(InpPlaceboInvert)
      goLong = !goLong;
   if(goLong)
     {
      double sl = NormalizeDouble(MathFloor((tk.ask - stopDist) / tickSize) * tickSize, _Digits);
      ok = g_trade.Buy(lots, _Symbol, 0.0, sl, 0.0, cmt);
     }
   else
     {
      double sl = NormalizeDouble(MathCeil((tk.bid + stopDist) / tickSize) * tickSize, _Digits);
      ok = g_trade.Sell(lots, _Symbol, 0.0, sl, 0.0, cmt);
     }

   if(ok && (g_trade.ResultRetcode() == TRADE_RETCODE_DONE || g_trade.ResultRetcode() == TRADE_RETCODE_PLACED))
     {
      PrintFormat("[FF] %s %s %.2f lotes | r_dia=%.3f%% (limiar %.3f%%) | stop=%.2f",
                  (goLong ? "COMPRA" : "VENDA"), _Symbol, lots, r * 100, InpThresholdK * madDay * 100, stopDist);
      return true;
     }
   PrintFormat("[FF] Falha no envio: %d %s", g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
   return false;
  }

//+------------------------------------------------------------------+
//| Loop principal                                                   |
//+------------------------------------------------------------------+
void Process()
  {
   datetime ny    = ServerToNY(TimeCurrent());
   datetime nyDay = DayStart(ny);
   int      mod   = (int)((ny - nyDay) / 60);  // minuto do dia em NY
   int      sig   = InpSignalHourNY * 60 + InpSignalMinuteNY;
   int      ex    = InpExitHourNY * 60 + InpExitMinuteNY;

   CheckKillSwitch();

   //--- Saída por tempo: horário de saída OU posição esquecida de outro dia
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic || PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      datetime openDay = DayStart(ServerToNY((datetime)PositionGetInteger(POSITION_TIME)));
      if(mod >= ex || openDay != nyDay)
        {
         if(g_trade.PositionClose(ticket))
            PrintFormat("[FF] Saída por tempo #%I64u", ticket);
        }
     }

   //--- Entrada
   if(g_killed || !IsWeekday(nyDay))
      return;
   if(mod < sig || mod >= sig + InpEntryWindowMin || mod >= ex)
      return;
   if(g_lastDecisionDay == nyDay)
      return;
   if(HasOurPosition(false) || EnteredToday(nyDay))
     {
      g_lastDecisionDay = nyDay;
      return;
     }
   if(TryEntry(nyDay))
      g_lastDecisionDay = nyDay;
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpRiskPercent <= 0.0 || InpRiskPercent > 3.0)
     {
      Print("[FF] InpRiskPercent fora de 0-3%. Recusando iniciar.");
      return INIT_PARAMETERS_INCORRECT;
     }
   int sig = InpSignalHourNY * 60 + InpSignalMinuteNY;
   int ex  = InpExitHourNY * 60 + InpExitMinuteNY;
   if(ex <= sig || ex > 16 * 60 || InpLookbackDays < 5 || InpThresholdK < 0.0 || InpStopMult <= 0.0)
      return INIT_PARAMETERS_INCORRECT;

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(InpDeviationPts);
   g_trade.SetTypeFillingBySymbol(_Symbol);

   g_gvPeak = StringFormat("FF_%I64u_%s_peak", InpMagic, _Symbol);
   g_gvKill = StringFormat("FF_%I64u_%s_killed", InpMagic, _Symbol);
   g_killed = InpKillEnabled && GlobalVariableCheck(g_gvKill) && GlobalVariableGet(g_gvKill) > 0.0;
   if(g_killed)
      PrintFormat("[FF] EA está DESLIGADO pelo kill switch (variável global %s).", g_gvKill);

   RebuildReturns();

   // Diagnóstico do relógio: confira que a abertura de NY (09:30) cai no candle com pico de volume.
   datetime srv = TimeCurrent();
   PrintFormat("[FF] Servidor %s  =>  Nova York %s  | 09:30 NY hoje = %s no servidor",
               TimeToString(srv, TIME_DATE | TIME_MINUTES),
               TimeToString(ServerToNY(srv), TIME_DATE | TIME_MINUTES),
               TimeToString(NYToServer(DayStart(ServerToNY(srv)) + 9 * 3600 + 30 * 60), TIME_MINUTES));

   EventSetTimer(15);   // garante a saída por tempo mesmo sem ticks
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason) { EventKillTimer(); }
void OnTick()  { Process(); }
void OnTimer() { Process(); }

//+------------------------------------------------------------------+
//| Registra o retorno de cada trade fechado para o kill switch      |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD || trans.deal == 0)
      return;
   if(!HistoryDealSelect(trans.deal))
      return;
   if((ulong)HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != InpMagic)
      return;
   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol)
      return;
   if(HistoryDealGetInteger(trans.deal, DEAL_ENTRY) != DEAL_ENTRY_OUT)
      return;
   double net = HistoryDealGetDouble(trans.deal, DEAL_PROFIT) + HistoryDealGetDouble(trans.deal, DEAL_SWAP) +
                HistoryDealGetDouble(trans.deal, DEAL_COMMISSION) + HistoryDealGetDouble(trans.deal, DEAL_FEE);
   double before = AccountInfoDouble(ACCOUNT_BALANCE) - net;
   if(before > 0.0)
      PushReturn(net / before);
  }
//+------------------------------------------------------------------+
