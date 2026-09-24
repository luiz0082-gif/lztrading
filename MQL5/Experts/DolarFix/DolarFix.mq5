//+------------------------------------------------------------------+
//|                                                    DolarFix.mq5  |
//|  "DolarFix" — o dólar em volta do fixing WM/Reuters (16:00 LDN)  |
//|                                                                  |
//|  Tese (Krohn, Mueller & Whelan, Journal of Finance 2024,         |
//|  "Foreign Exchange Fixings and Returns Around the Clock"):       |
//|  o dólar tende a SE VALORIZAR nas horas antes dos grandes        |
//|  fixings e a SE DESVALORIZAR depois, com efeito maior no fim     |
//|  do mês. Mecanismo: demanda concentrada de USD que precisa ser   |
//|  executada NO fixing (hedge cambial de fundos, rebalanceamento,  |
//|  benchmarks) e intermediários com balanço limitado cobrando      |
//|  para carregar esse estoque.                                     |
//|                                                                  |
//|  O EA opera o DÓLAR, não um par: abre uma cesta de pares com     |
//|  USD, com risco igual por par (paridade de volatilidade).        |
//|    Perna PRÉ : compra USD 14:00 -> 15:55 Londres                  |
//|    Perna PÓS : vende  USD 16:05 -> 20:00 Londres                  |
//|  Nunca passa do rollover (22:00 Londres): zero swap.             |
//|                                                                  |
//|  ANTES de ligar: rode o script FixProfile e confirme o padrão    |
//|  nos dados da SUA corretora.                                     |
//+------------------------------------------------------------------+
#property copyright "lztrading"
#property version   "1.00"
#property description "Cesta de USD em volta do fixing WM/R das 16:00 de Londres."
#property description "Rode o script FixProfile antes. Anexe a UM gráfico só (ex.: EURUSD)."

#include <Trade/Trade.mqh>
#include <DolarFix/FixClock.mqh>

#define LEG_PRE  0
#define LEG_POST 1

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== Relógio: servidor -> Londres (CONFIRA NO LOG) ==="
input int             InpServerGMTOffset = 2;          // Offset GMT do servidor no INVERNO (horas)
input ENUM_SERVER_DST InpServerDST       = SRV_DST_US; // Regra de DST do servidor

input group "=== Cesta ==="
input string InpSymbols     = "EURUSD,GBPUSD,AUDUSD,NZDUSD,USDJPY,USDCHF,USDCAD"; // Pares com USD
input string InpSuffix      = "";     // Sufixo da corretora (ex.: ".r", "m")
input bool   InpIncludeGold = false;  // Incluir XAUUSD como perna anti-dólar (HIPÓTESE, ver README)
input string InpGoldSymbol  = "XAUUSD"; // Nome do ouro (sem sufixo)

input group "=== Janelas (hora de Londres) — FIXAS pela tese ==="
input bool InpPreEnabled   = true;  // Perna PRÉ-fixing (compra USD)
input int  InpPreStartH    = 14;    // PRÉ: início hora
input int  InpPreStartM    = 0;     // PRÉ: início minuto
input int  InpPreEndH      = 15;    // PRÉ: fim hora (sai ANTES da janela do fixing)
input int  InpPreEndM      = 55;    // PRÉ: fim minuto
input bool InpPostEnabled  = true;  // Perna PÓS-fixing (vende USD)
input int  InpPostStartH   = 16;    // PÓS: início hora
input int  InpPostStartM   = 5;     // PÓS: início minuto (depois da janela 15:57:30-16:02:30)
input int  InpPostEndH     = 20;    // PÓS: fim hora (antes do rollover das 22:00)
input int  InpPostEndM     = 0;     // PÓS: fim minuto
input int  InpEntryWindow  = 10;    // Janela máx. p/ abrir após o início (min)
input bool InpMonthEndOnly = false; // Operar SÓ no último dia útil do mês
input double InpMonthEndMult = 1.5; // Multiplicador de risco no último dia útil do mês

input group "=== Risco ==="
input double InpRiskPerLeg   = 0.60; // Risco TOTAL da cesta por perna (% do equity), dividido entre os pares
input double InpStopATRMult  = 3.0;  // Stop catastrófico = k × ATR(H1,24) × sqrt(horas da perna)
input double InpMaxSpreadBps = 2.0;  // Pula o par se spread > X bps (1 bp = 0,01%)

input group "=== Desligamento automático ==="
input bool   InpKillEnabled  = true;  // Ativa kill switch (DESLIGUE no 1º backtest)
input double InpMaxDDPercent = 12.0;  // Desliga se equity cair X% do pico
input int    InpKillWindow   = 100;   // Nº de pernas na janela estatística
input double InpKillTStat    = -1.5;  // Desliga se t-stat da janela ficar abaixo disto

input group "=== Execução ==="
input ulong InpMagic        = 26092400; // Magic base (PRÉ = base, PÓS = base+1)
input int   InpDeviationPts = 20;       // Desvio máximo (pontos)
input bool  InpPlaceboInvert = false;   // PLACEBO: inverte as duas pernas (só p/ validar)

//+------------------------------------------------------------------+
//| Globais                                                          |
//+------------------------------------------------------------------+
CTrade   g_trade;
string   g_syms[];
int      g_sign[];                 // +1: comprar par = comprar USD; -1: comprar par = vender USD
datetime g_openDay[2]     = {0, 0};
datetime g_recordedDay[2] = {0, 0};
bool     g_killed = false;
double   g_rets[];                 // retorno por PERNA (cesta inteira), mais antigo primeiro
string   g_gvPeak, g_gvKill;

//+------------------------------------------------------------------+
ulong LegMagic(const int leg) { return InpMagic + (ulong)leg; }
int   LegStart(const int leg) { return leg == LEG_PRE ? InpPreStartH * 60 + InpPreStartM : InpPostStartH * 60 + InpPostStartM; }
int   LegEnd(const int leg)   { return leg == LEG_PRE ? InpPreEndH * 60 + InpPreEndM     : InpPostEndH * 60 + InpPostEndM; }
bool  LegOn(const int leg)    { return leg == LEG_PRE ? InpPreEnabled : InpPostEnabled; }
// Direção em USD: PRÉ compra dólar (+1), PÓS vende dólar (-1)
int   LegUSDDir(const int leg)
  {
   int d = (leg == LEG_PRE) ? +1 : -1;
   return InpPlaceboInvert ? -d : d;
  }

//+------------------------------------------------------------------+
//| ATR(H1, n) calculado na mão (serve para qualquer símbolo)        |
//+------------------------------------------------------------------+
double ATR_H1(const string sym, const int n)
  {
   MqlRates r[];
   ArraySetAsSeries(r, true);
   if(CopyRates(sym, PERIOD_H1, 1, n + 1, r) < n + 1)
      return 0.0;
   double s = 0.0;
   for(int i = 0; i < n; i++)
      s += MathMax(r[i].high, r[i + 1].close) - MathMin(r[i].low, r[i + 1].close);
   return s / n;
  }

double LotsForRisk(const string sym, const double riskMoney, const double stopDist)
  {
   double tickSize  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue <= 0.0)
      tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   if(tickSize <= 0.0 || tickValue <= 0.0 || step <= 0.0 || stopDist <= 0.0 || riskMoney <= 0.0)
      return 0.0;
   double lots = MathFloor(riskMoney / (stopDist / tickSize * tickValue) / step) * step;
   if(lots < vmin)
      return 0.0;                 // nunca arredonda para cima o risco
   return MathMin(lots, vmax);
  }

//+------------------------------------------------------------------+
//| Posições / histórico                                             |
//+------------------------------------------------------------------+
int CountLeg(const int leg)
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(PositionGetTicket(i) > 0 && (ulong)PositionGetInteger(POSITION_MAGIC) == LegMagic(leg))
         n++;
   return n;
  }

void CloseLeg(const int leg, const string why)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || (ulong)PositionGetInteger(POSITION_MAGIC) != LegMagic(leg))
         continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      if(!g_trade.PositionClose(ticket))
         PrintFormat("[DF] ERRO ao fechar %s #%I64u (%s): %d %s", sym, ticket, why,
                     g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
     }
  }

double DealNet(const ulong d)
  {
   return HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) +
          HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
  }

// Houve entrada desta perna hoje (dia de Londres)? Protege contra reinício.
bool LegEnteredToday(const int leg, const datetime lonDay)
  {
   if(!HistorySelect(ClkLondonToServer(lonDay), TimeCurrent() + 60))
      return false;
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d > 0 && (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == LegMagic(leg) &&
         HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_IN)
         return true;
     }
   return false;
  }

// Resultado líquido da perna hoje (todas as saídas, inclusive stops) como fração do saldo anterior
bool LegResultToday(const int leg, const datetime lonDay, double &ret)
  {
   if(!HistorySelect(ClkLondonToServer(lonDay), TimeCurrent() + 60))
      return false;
   double net = 0.0;
   int outs = 0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d > 0 && (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == LegMagic(leg) &&
         HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_OUT)
        {
         net += DealNet(d);
         outs++;
        }
     }
   double before = AccountInfoDouble(ACCOUNT_BALANCE) - net;
   if(outs == 0 || before <= 0.0)
      return false;
   ret = net / before;
   return true;
  }

//+------------------------------------------------------------------+
//| Kill switch                                                      |
//+------------------------------------------------------------------+
void PushReturn(const double r)
  {
   int n = ArraySize(g_rets);
   if(n >= InpKillWindow && n > 0)
     {
      for(int i = 1; i < n; i++)
         g_rets[i - 1] = g_rets[i];
      g_rets[n - 1] = r;
     }
   else
     {
      ArrayResize(g_rets, n + 1);
      g_rets[n] = r;
     }
  }

// Reconstrói o histórico de retornos por perna após reinício do terminal.
// Anda do saldo atual para trás; agrupa saídas por (perna, dia de Londres).
void RebuildReturns()
  {
   ArrayResize(g_rets, 0);
   if(!HistorySelect(0, TimeCurrent() + 60))
      return;
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   long   keys[];
   double nets[], bases[];
   int    ng = 0;
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0)
         continue;
      double net = DealNet(d);
      double before = bal - net;
      ulong  mg = (ulong)HistoryDealGetInteger(d, DEAL_MAGIC);
      if((mg == LegMagic(LEG_PRE) || mg == LegMagic(LEG_POST)) &&
         HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_OUT)
        {
         datetime lonDay = ClkDayStart(ClkServerToLondon((datetime)HistoryDealGetInteger(d, DEAL_TIME)));
         long key = (long)lonDay * 2 + (long)(mg - InpMagic);
         if(ng > 0 && keys[ng - 1] == key)
           {
            nets[ng - 1] += net;
            bases[ng - 1] = before;       // saldo antes da saída mais antiga do grupo
           }
         else
           {
            if(ng >= InpKillWindow)
               break;
            ArrayResize(keys, ng + 1);
            ArrayResize(nets, ng + 1);
            ArrayResize(bases, ng + 1);
            keys[ng] = key; nets[ng] = net; bases[ng] = before;
            ng++;
           }
        }
      bal = before;
     }
   for(int g = ng - 1; g >= 0; g--)
      if(bases[g] > 0.0)
         PushReturn(nets[g] / bases[g]);
  }

void Kill(const string why)
  {
   if(g_killed)
      return;
   g_killed = true;
   GlobalVariableSet(g_gvKill, 1.0);
   CloseLeg(LEG_PRE, "kill");
   CloseLeg(LEG_POST, "kill");
   string msg = StringFormat("[DF] EA DESLIGADO: %s. Para religar apague a variável global '%s' (F3) — "
                             "depois de entender o motivo.", why, g_gvKill);
   Print(msg);
   if(!MQLInfoInteger(MQL_TESTER))
      Alert(msg);
  }

void CheckKillSwitch()
  {
   if(!InpKillEnabled || g_killed)
      return;
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
   if(v > 0.0 && m / MathSqrt(v / n) < InpKillTStat)
      Kill(StringFormat("t-stat das últimas %d pernas = %.2f < %.2f", n, m / MathSqrt(v / n), InpKillTStat));
  }

//+------------------------------------------------------------------+
//| Abre a cesta de uma perna                                        |
//+------------------------------------------------------------------+
// true = decisão tomada (abriu ou decidiu não abrir); false = tentar de novo
bool OpenLeg(const int leg, const bool monthEnd)
  {
   double hours = (LegEnd(leg) - LegStart(leg)) / 60.0;
   int    usdDir = LegUSDDir(leg);
   int    n = ArraySize(g_syms);

   // 1) Filtra pares tradeáveis agora (dados + spread)
   bool   ok[];
   double stopD[];
   ArrayResize(ok, n);
   ArrayResize(stopD, n);
   int active = 0;
   for(int s = 0; s < n; s++)
     {
      ok[s] = false;
      MqlTick tk;
      if(!SymbolInfoTick(g_syms[s], tk) || tk.bid <= 0.0 || tk.ask <= 0.0)
         continue;
      double spreadBps = (tk.ask - tk.bid) / ((tk.ask + tk.bid) / 2.0) * 1e4;
      if(spreadBps > InpMaxSpreadBps)
        {
         PrintFormat("[DF] %s spread %.2f bps > %.2f: fora desta perna.", g_syms[s], spreadBps, InpMaxSpreadBps);
         continue;
        }
      double atr = ATR_H1(g_syms[s], 24);
      if(atr <= 0.0)
         continue;
      double tickSize = SymbolInfoDouble(g_syms[s], SYMBOL_TRADE_TICK_SIZE);
      double d = InpStopATRMult * atr * MathSqrt(MathMax(hours, 1.0));
      d = MathMax(d, (SymbolInfoInteger(g_syms[s], SYMBOL_TRADE_STOPS_LEVEL) + 5) * SymbolInfoDouble(g_syms[s], SYMBOL_POINT));
      stopD[s] = MathCeil(d / tickSize) * tickSize;
      ok[s] = true;
      active++;
     }
   if(active < 3)
     {
      PrintFormat("[DF] Só %d pares aptos: cesta pequena demais, não é mais uma aposta no dólar. Pulando.", active);
      return (active > 0);   // se nenhum tem cotação, tenta de novo; se 1-2, desiste do dia
     }

   // 2) Risco dividido igualmente entre os pares (paridade de volatilidade via stop em ATR)
   double riskMoney = AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskPerLeg / 100.0 * (monthEnd ? InpMonthEndMult : 1.0);
   double perSym    = riskMoney / active;

   g_trade.SetExpertMagicNumber(LegMagic(leg));
   int opened = 0;
   for(int s = 0; s < n; s++)
     {
      if(!ok[s])
         continue;
      string sym = g_syms[s];
      double lots = LotsForRisk(sym, perSym, stopD[s]);
      if(lots <= 0.0)
        {
         PrintFormat("[DF] %s: lote abaixo do mínimo para %.2f de risco. Conta pequena para esta cesta.", sym, perSym);
         continue;
        }
      int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      MqlTick tk;
      if(!SymbolInfoTick(sym, tk))
         continue;
      bool buyPair = (usdDir * g_sign[s] > 0);
      string cmt = (leg == LEG_PRE ? "DF pre" : "DF pos");
      if(monthEnd)
         cmt += " ME";
      g_trade.SetTypeFillingBySymbol(sym);
      bool res;
      if(buyPair)
         res = g_trade.Buy(lots, sym, 0.0, NormalizeDouble(tk.ask - stopD[s], digits), 0.0, cmt);
      else
         res = g_trade.Sell(lots, sym, 0.0, NormalizeDouble(tk.bid + stopD[s], digits), 0.0, cmt);
      if(res && (g_trade.ResultRetcode() == TRADE_RETCODE_DONE || g_trade.ResultRetcode() == TRADE_RETCODE_PLACED))
         opened++;
      else
         PrintFormat("[DF] %s falhou: %d %s", sym, g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
     }
   PrintFormat("[DF] Perna %s aberta: %s USD em %d/%d pares | risco total %.2f%%%s",
               (leg == LEG_PRE ? "PRÉ" : "PÓS"), (usdDir > 0 ? "COMPRA" : "VENDE"), opened, active,
               InpRiskPerLeg * (monthEnd ? InpMonthEndMult : 1.0), (monthEnd ? " (fim de mês)" : ""));
   return true;
  }

//+------------------------------------------------------------------+
//| Loop principal (timer + ticks)                                   |
//+------------------------------------------------------------------+
void Process()
  {
   datetime lon = ClkServerToLondon(TimeCurrent());
   datetime day = ClkDayStart(lon);
   int      mod = (int)((lon - day) / 60);

   CheckKillSwitch();

   for(int leg = LEG_PRE; leg <= LEG_POST; leg++)
     {
      int st = LegStart(leg), en = LegEnd(leg);

      //--- Saída por tempo (ou posição esquecida de outro dia)
      if(CountLeg(leg) > 0 && (mod >= en || mod < st || g_openDay[leg] != day))
         CloseLeg(leg, "tempo");

      //--- Registra o resultado da perna (inclui pernas encerradas por stop)
      if(mod >= en && g_openDay[leg] == day && g_recordedDay[leg] != day && CountLeg(leg) == 0)
        {
         double r;
         if(LegResultToday(leg, day, r))
           {
            PushReturn(r);
            PrintFormat("[DF] Perna %s de hoje: %+.3f%% do saldo", (leg == LEG_PRE ? "PRÉ" : "PÓS"), r * 100.0);
           }
         g_recordedDay[leg] = day;
        }

      //--- Entrada
      if(g_killed || !LegOn(leg) || !ClkIsWeekday(day))
         continue;
      if(mod < st || mod >= st + InpEntryWindow || mod >= en)
         continue;
      if(g_openDay[leg] == day)
         continue;
      bool monthEnd = ClkIsMonthEnd(day);
      if(InpMonthEndOnly && !monthEnd)
         continue;
      if(CountLeg(leg) > 0 || LegEnteredToday(leg, day))
        {
         g_openDay[leg] = day;
         continue;
        }
      if(OpenLeg(leg, monthEnd))
         g_openDay[leg] = day;
     }
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   g_clkOffset = InpServerGMTOffset;
   g_clkDST    = InpServerDST;

   if(InpRiskPerLeg <= 0.0 || InpRiskPerLeg > 3.0 || InpMonthEndMult < 1.0 || InpMonthEndMult > 3.0)
     {
      Print("[DF] Risco fora dos limites (0-3% por perna, multiplicador 1-3). Recusando iniciar.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(LegEnd(LEG_PRE) <= LegStart(LEG_PRE) || LegEnd(LEG_POST) <= LegStart(LEG_POST) ||
      LegEnd(LEG_POST) > 21 * 60 + 30)
     {
      Print("[DF] Janelas inválidas (fim <= início, ou PÓS passando de 21:30 Londres, perto do rollover).");
      return INIT_PARAMETERS_INCORRECT;
     }

   string list = InpSymbols;
   if(InpIncludeGold)
      list += "," + InpGoldSymbol;
   int n = ClkParseSymbols(list, InpSuffix, g_syms);
   ArrayResize(g_sign, n);
   int k = 0;
   for(int i = 0; i < n; i++)
     {
      int sg = ClkUSDSign(g_syms[i]);
      if(sg == 0)
        {
         PrintFormat("[DF] %s não tem USD: não expressa a tese, ignorado.", g_syms[i]);
         continue;
        }
      g_syms[k] = g_syms[i];
      g_sign[k] = sg;
      k++;
     }
   ArrayResize(g_syms, k);
   ArrayResize(g_sign, k);
   if(k < 3)
     {
      Print("[DF] Menos de 3 pares com USD. Confira nomes/sufixo.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_trade.SetDeviationInPoints(InpDeviationPts);

   g_gvPeak = StringFormat("DF_%I64u_peak", InpMagic);
   g_gvKill = StringFormat("DF_%I64u_killed", InpMagic);
   g_killed = InpKillEnabled && GlobalVariableCheck(g_gvKill) && GlobalVariableGet(g_gvKill) > 0.0;
   if(g_killed)
      PrintFormat("[DF] EA DESLIGADO pelo kill switch (variável global %s).", g_gvKill);

   RebuildReturns();

   // Recupera estado de pernas já abertas hoje (reinício no meio da janela)
   datetime lonNow = ClkServerToLondon(TimeCurrent());
   for(int leg = LEG_PRE; leg <= LEG_POST; leg++)
      if(CountLeg(leg) > 0 || LegEnteredToday(leg, ClkDayStart(lonNow)))
         g_openDay[leg] = ClkDayStart(lonNow);

   // Diagnóstico do relógio: o fixing das 16:00 Londres precisa cair na hora que você espera no servidor
   PrintFormat("[DF] Servidor %s => Londres %s | 16:00 Londres hoje = %s no servidor | cesta: %d pares",
               TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES),
               TimeToString(lonNow, TIME_DATE | TIME_MINUTES),
               TimeToString(ClkLondonToServer(ClkDayStart(lonNow) + 16 * 3600), TIME_MINUTES), k);

   EventSetTimer(5);   // multi-símbolo: não depende de ticks do gráfico
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason) { EventKillTimer(); }
void OnTick()  { Process(); }
void OnTimer() { Process(); }
//+------------------------------------------------------------------+
