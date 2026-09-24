//+------------------------------------------------------------------+
//|                                                OuroAbertura.mq5  |
//|  "OuroAbertura" — rompimento da faixa de abertura no XAUUSD      |
//|                                                                  |
//|  Duas sessões por dia, no máximo 3 entradas:                     |
//|    LONDRES : faixa 08:00-08:15 (Londres), entradas até 10:30,    |
//|              sai tudo às 12:00                                   |
//|    NOVA YORK: faixa 08:30-08:45 (NY), entradas até 10:30,        |
//|              sai tudo às 11:30                                   |
//|                                                                  |
//|  Rompeu a máxima da faixa -> compra; rompeu a mínima -> vende.   |
//|  Stop no outro lado da faixa, alvo 1,5R, breakeven em 1R.        |
//|  Se o 1º trade da sessão for stopado, a ordem do lado oposto     |
//|  continua valendo (rompimento falso vira reversão). Se ganhar    |
//|  ou sair no zero, a sessão acaba.                                |
//|                                                                  |
//|  Meta diária (US$): atingiu -> fecha tudo e para no dia.         |
//|  Perda diária (US$): OBRIGATÓRIA. Atingiu -> fecha e para.       |
//|  Risco por trade = perda diária / 2 (dois stops cheios = fim).   |
//+------------------------------------------------------------------+
#property copyright "lztrading"
#property version   "1.00"
#property description "Rompimento da faixa de abertura (Londres e NY) no XAUUSD."
#property description "Máx. 3 entradas/dia, meta e perda diária em US$. Perda diária é obrigatória."

#include <Trade/Trade.mqh>
#include <DolarFix/FixClock.mqh>

#define SES_LONDON 0
#define SES_NY     1
#define ST_IDLE    0   // aguardando a faixa
#define ST_ARMED   1   // ordens pendentes colocadas / sessão em andamento
#define ST_DONE    2   // sessão encerrada no dia

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== Meta e limite diário (US$) ==="
input double InpDailyTarget     = 12.0; // Meta diária em US$ (atingiu -> fecha tudo e para no dia)
input double InpDailyMaxLoss    = 0.0;  // Perda máxima diária em US$ (OBRIGATÓRIO > 0)
input int    InpMaxTradesPerDay = 3;    // Máximo de entradas por dia
input double InpMaxRiskPctTrade = 1.0;  // Teto de risco por trade (% do equity), protege conta pequena

input group "=== Relógio do servidor (CONFIRA NO LOG) ==="
input int             InpServerGMTOffset = 2;          // Offset GMT do servidor no INVERNO
input ENUM_SERVER_DST InpServerDST       = SRV_DST_US; // Regra de DST do servidor

input group "=== Sessão de Londres (hora de Londres) ==="
input bool InpLonOn        = true; // Operar Londres
input int  InpLonStartH    = 8;    // Início da faixa (hora)
input int  InpLonStartM    = 0;    // Início da faixa (min)
input int  InpLonRangeMin  = 15;   // Duração da faixa (min)
input int  InpLonEntryEndH = 10;   // Fim das entradas (hora)
input int  InpLonEntryEndM = 30;   // Fim das entradas (min)
input int  InpLonExitH     = 12;   // Saída forçada (hora)
input int  InpLonExitM     = 0;    // Saída forçada (min)

input group "=== Sessão de Nova York (hora de NY) ==="
input bool InpNYOn         = true; // Operar Nova York
input int  InpNYStartH     = 8;    // Início da faixa (hora) — após dados das 8:30
input int  InpNYStartM     = 30;   // Início da faixa (min)
input int  InpNYRangeMin   = 15;   // Duração da faixa (min)
input int  InpNYEntryEndH  = 10;   // Fim das entradas (hora)
input int  InpNYEntryEndM  = 30;   // Fim das entradas (min)
input int  InpNYExitH      = 11;   // Saída forçada (hora)
input int  InpNYExitM      = 30;   // Saída forçada (min)

input group "=== Regras do trade — FIXAS, não otimize ==="
input double InpTP_R         = 1.5;  // Alvo em múltiplos do risco (R)
input double InpBE_R         = 1.0;  // Move stop p/ entrada ao atingir X R
input double InpRangeMinATR  = 0.3;  // Faixa mínima (× ATR H1): menor = ruído
input double InpRangeMaxATR  = 1.5;  // Faixa máxima (× ATR H1): maior = movimento já aconteceu
input double InpMaxSpreadFrac= 0.15; // Spread máx. como fração do risco R

input group "=== Proteção da conta ==="
input double InpMaxDDPercent = 10.0; // Desliga o EA se equity cair X% do pico

input group "=== Execução ==="
input ulong InpMagic        = 26092500; // Magic base (Londres = base, NY = base+1)
input int   InpDeviationPts = 50;       // Desvio máximo (pontos)

//+------------------------------------------------------------------+
//| Globais                                                          |
//+------------------------------------------------------------------+
struct SessionCfg
  {
   bool   on;
   int    tz;          // SES_LONDON usa relógio de Londres, SES_NY relógio de NY
   int    startMin;
   int    rangeMin;
   int    entryEndMin;
   int    exitMin;
   string name;
  };

CTrade     g_trade;
SessionCfg g_s[2];
int        g_state[2]    = {ST_IDLE, ST_IDLE};
datetime   g_stateDay[2] = {0, 0};
datetime   g_day      = 0;      // dia do servidor corrente
bool       g_dayDone  = false;  // meta ou perda do dia atingida
bool       g_killed   = false;
string     g_gvPeak, g_gvKill;

//+------------------------------------------------------------------+
//| Relógio por sessão                                               |
//+------------------------------------------------------------------+
datetime LocalNow(const int s)
  {
   return g_s[s].tz == SES_LONDON ? ClkServerToLondon(TimeCurrent()) : ClkServerToNY(TimeCurrent());
  }

datetime LocalToServer(const int s, const datetime local)
  {
   return g_s[s].tz == SES_LONDON ? ClkLondonToServer(local) : ClkNYToServer(local);
  }

ulong SesMagic(const int s) { return InpMagic + (ulong)s; }
bool  IsOurMagic(const ulong m) { return m == SesMagic(SES_LONDON) || m == SesMagic(SES_NY); }

//+------------------------------------------------------------------+
//| Utilidades de risco                                              |
//+------------------------------------------------------------------+
double ATR_H1(const int n)
  {
   MqlRates r[];
   ArraySetAsSeries(r, true);
   if(CopyRates(_Symbol, PERIOD_H1, 1, n + 1, r) < n + 1)
      return 0.0;
   double sum = 0.0;
   for(int i = 0; i < n; i++)
      sum += MathMax(r[i].high, r[i + 1].close) - MathMin(r[i].low, r[i + 1].close);
   return sum / n;
  }

// Quanto se perde com 1 lote se o preço andar 'dist' contra
double LossPerLot(const double dist)
  {
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue <= 0.0)
      tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize <= 0.0 || tickValue <= 0.0)
      return 0.0;
   return dist / tickSize * tickValue;
  }

double LotsForRisk(const double riskMoney, const double dist)
  {
   double lpl  = LossPerLot(dist);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(lpl <= 0.0 || step <= 0.0 || riskMoney <= 0.0)
      return 0.0;
   double lots = MathFloor(riskMoney / lpl / step) * step;
   if(lots < vmin)
      return 0.0;                // NUNCA arredonda o risco para cima
   return MathMin(lots, vmax);
  }

double RiskPerTrade()
  {
   double byDay    = InpDailyMaxLoss / 2.0;  // dois stops cheios encerram o dia
   double byEquity = AccountInfoDouble(ACCOUNT_EQUITY) * InpMaxRiskPctTrade / 100.0;
   return MathMin(byDay, byEquity);
  }

double NormPrice(const double p)
  {
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0.0)
      return NormalizeDouble(p, _Digits);
   return NormalizeDouble(MathRound(p / ts) * ts, _Digits);
  }

//+------------------------------------------------------------------+
//| Posições, ordens e histórico                                     |
//+------------------------------------------------------------------+
double DealNet(const ulong d)
  {
   return HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) +
          HistoryDealGetDouble(d, DEAL_COMMISSION) + HistoryDealGetDouble(d, DEAL_FEE);
  }

bool HasPosition(const int s)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(PositionGetTicket(i) > 0 && (ulong)PositionGetInteger(POSITION_MAGIC) == SesMagic(s) &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
         return true;
   return false;
  }

int CountPendings(const int s)
  {
   int n = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(t > 0 && (ulong)OrderGetInteger(ORDER_MAGIC) == SesMagic(s) && OrderGetString(ORDER_SYMBOL) == _Symbol)
         n++;
     }
   return n;
  }

void DeletePendings(const int s)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(t > 0 && (ulong)OrderGetInteger(ORDER_MAGIC) == SesMagic(s) && OrderGetString(ORDER_SYMBOL) == _Symbol)
         g_trade.OrderDelete(t);
     }
  }

void ClosePositions(const int s, const string why)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || (ulong)PositionGetInteger(POSITION_MAGIC) != SesMagic(s) ||
         PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(g_trade.PositionClose(t))
         PrintFormat("[OA] %s: posição #%I64u fechada (%s)", g_s[s].name, t, why);
     }
  }

void CloseEverything(const string why)
  {
   for(int s = 0; s < 2; s++)
     {
      DeletePendings(s);
      ClosePositions(s, why);
     }
  }

// Resultado do dia (servidor): fechado + flutuante das posições abertas deste EA
double DayPnL(const datetime srvDay)
  {
   double pnl = 0.0;
   if(HistorySelect(srvDay, TimeCurrent() + 60))
      for(int i = 0; i < HistoryDealsTotal(); i++)
        {
         ulong d = HistoryDealGetTicket(i);
         if(d > 0 && IsOurMagic((ulong)HistoryDealGetInteger(d, DEAL_MAGIC)) &&
            HistoryDealGetString(d, DEAL_SYMBOL) == _Symbol)
            pnl += DealNet(d);
        }
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(PositionGetTicket(i) > 0 && IsOurMagic((ulong)PositionGetInteger(POSITION_MAGIC)) &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
         pnl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   return pnl;
  }

// Entradas desde 'from' (servidor). s = -1 conta as duas sessões.
int EntriesSince(const datetime from, const int s)
  {
   int n = 0;
   if(!HistorySelect(from, TimeCurrent() + 60))
      return 0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0 || HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN ||
         HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol)
         continue;
      ulong m = (ulong)HistoryDealGetInteger(d, DEAL_MAGIC);
      if((s < 0 && IsOurMagic(m)) || (s >= 0 && m == SesMagic(s)))
         n++;
     }
   return n;
  }

// Resultado líquido da última saída da sessão desde 'from'
bool LastExitNet(const int s, const datetime from, double &net)
  {
   if(!HistorySelect(from, TimeCurrent() + 60))
      return false;
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d > 0 && (ulong)HistoryDealGetInteger(d, DEAL_MAGIC) == SesMagic(s) &&
         HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_OUT &&
         HistoryDealGetString(d, DEAL_SYMBOL) == _Symbol)
        {
         net = DealNet(d);
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Breakeven: R é recuperado do alvo (TP = entrada ± TP_R × R)      |
//+------------------------------------------------------------------+
void ManageBreakeven(const int s)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || (ulong)PositionGetInteger(POSITION_MAGIC) != SesMagic(s) ||
         PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl   = PositionGetDouble(POSITION_SL);
      double tp   = PositionGetDouble(POSITION_TP);
      if(tp <= 0.0)
         continue;
      double R = MathAbs(tp - open) / InpTP_R;
      bool   isBuy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      double px = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      bool alreadyBE = isBuy ? (sl >= open) : (sl > 0.0 && sl <= open);
      if(alreadyBE)
         continue;
      double gain = isBuy ? px - open : open - px;
      if(gain >= InpBE_R * R)
        {
         if(g_trade.PositionModify(t, NormPrice(open), tp))
            PrintFormat("[OA] %s: stop no zero a zero (+%.1fR)", g_s[s].name, gain / R);
        }
     }
  }

//+------------------------------------------------------------------+
//| Mede a faixa e coloca as duas ordens pendentes                   |
//| Retorna 1 = armado, 0 = sem trade hoje nesta sessão, -1 = tentar |
//+------------------------------------------------------------------+
int ArmSession(const int s, const datetime localDay)
  {
   datetime rs = LocalToServer(s, localDay + g_s[s].startMin * 60);
   datetime re = rs + g_s[s].rangeMin * 60;

   MqlRates r[];
   int got = CopyRates(_Symbol, PERIOD_M1, rs, re - 60, r);
   if(got < (int)(g_s[s].rangeMin * 0.7))
      return (TimeCurrent() - re > 300) ? 0 : -1;   // sem dado (feriado?) -> desiste após 5 min

   double hi = r[0].high, lo = r[0].low;
   for(int i = 1; i < got; i++)
     {
      hi = MathMax(hi, r[i].high);
      lo = MathMin(lo, r[i].low);
     }
   double range = hi - lo;
   double atr   = ATR_H1(24);
   if(atr <= 0.0)
      return -1;
   if(range < InpRangeMinATR * atr || range > InpRangeMaxATR * atr)
     {
      PrintFormat("[OA] %s: faixa %.2f fora do intervalo [%.2f ; %.2f]. Sem trade nesta sessão.",
                  g_s[s].name, range, InpRangeMinATR * atr, InpRangeMaxATR * atr);
      return 0;
     }

   MqlTick tk;
   if(!SymbolInfoTick(_Symbol, tk))
      return -1;
   double spread = tk.ask - tk.bid;
   double buf    = MathMax(2.0 * spread, 0.05 * range);
   double R      = range + 2.0 * buf;          // entrada máx+buf, stop mín-buf (e vice-versa)
   if(spread > InpMaxSpreadFrac * R)
     {
      PrintFormat("[OA] %s: spread %.2f alto para R %.2f. Aguardando.", g_s[s].name, spread, R);
      return -1;
     }

   double risk = RiskPerTrade();
   double lots = LotsForRisk(risk, R);
   if(lots <= 0.0)
     {
      PrintFormat("[OA] %s: 0,01 lote arriscaria US$ %.2f, acima do permitido (US$ %.2f). Sem trade.",
                  g_s[s].name, LossPerLot(R) * SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), risk);
      return 0;
     }

   double minDist = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + 2) * _Point;
   double buyPx   = NormPrice(hi + buf);
   double sellPx  = NormPrice(lo - buf);
   int placed = 0;
   g_trade.SetExpertMagicNumber(SesMagic(s));

   if(buyPx > tk.ask + minDist)
     {
      if(g_trade.BuyStop(lots, buyPx, _Symbol, NormPrice(buyPx - R), NormPrice(buyPx + InpTP_R * R),
                         ORDER_TIME_GTC, 0, "OA " + g_s[s].name + " C"))
         placed++;
     }
   if(sellPx < tk.bid - minDist)
     {
      if(g_trade.SellStop(lots, sellPx, _Symbol, NormPrice(sellPx + R), NormPrice(sellPx - InpTP_R * R),
                          ORDER_TIME_GTC, 0, "OA " + g_s[s].name + " V"))
         placed++;
     }
   if(placed == 0)
     {
      PrintFormat("[OA] %s: preço já fora da faixa ao armar. Sem trade.", g_s[s].name);
      return 0;
     }
   PrintFormat("[OA] %s armado: faixa %.2f-%.2f | compra %.2f / venda %.2f | %.2f lotes | risco US$ %.2f",
               g_s[s].name, lo, hi, buyPx, sellPx, lots, LossPerLot(R) * lots);
   return 1;
  }

//+------------------------------------------------------------------+
//| Proteção de conta                                                |
//+------------------------------------------------------------------+
void CheckDrawdown()
  {
   if(g_killed)
      return;
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   double peak = GlobalVariableCheck(g_gvPeak) ? GlobalVariableGet(g_gvPeak) : eq;
   if(eq > peak)
      peak = eq;
   GlobalVariableSet(g_gvPeak, peak);
   if(peak > 0.0 && (peak - eq) / peak * 100.0 >= InpMaxDDPercent)
     {
      g_killed = true;
      GlobalVariableSet(g_gvKill, 1.0);
      CloseEverything("proteção de drawdown");
      string msg = StringFormat("[OA] EA DESLIGADO: equity caiu %.1f%% do pico. Apague a variável global '%s' "
                                "para religar — depois de revisar.", (peak - eq) / peak * 100.0, g_gvKill);
      Print(msg);
      if(!MQLInfoInteger(MQL_TESTER))
         Alert(msg);
     }
  }

//+------------------------------------------------------------------+
//| Loop principal                                                   |
//+------------------------------------------------------------------+
void Process()
  {
   datetime srvDay = ClkDayStart(TimeCurrent());
   if(srvDay != g_day)
     {
      g_day = srvDay;
      g_dayDone = false;
     }

   CheckDrawdown();

   //--- Meta / perda do dia
   double pnl = DayPnL(srvDay);
   if(!g_dayDone && (pnl >= InpDailyTarget || pnl <= -InpDailyMaxLoss))
     {
      g_dayDone = true;
      CloseEverything(pnl >= InpDailyTarget ? "meta do dia" : "perda máxima do dia");
      PrintFormat("[OA] Dia encerrado: resultado US$ %.2f (%s).", pnl,
                  pnl >= InpDailyTarget ? "META ATINGIDA" : "PERDA MÁXIMA");
     }

   int tradesToday = EntriesSince(srvDay, -1);

   for(int s = 0; s < 2; s++)
     {
      if(!g_s[s].on)
         continue;
      datetime loc  = LocalNow(s);
      datetime lday = ClkDayStart(loc);
      int      mod  = (int)((loc - lday) / 60);

      if(g_stateDay[s] != lday)
        {
         g_stateDay[s] = lday;
         g_state[s] = ST_IDLE;
        }

      //--- Saída forçada da sessão
      if(mod >= g_s[s].exitMin)
        {
         DeletePendings(s);
         if(HasPosition(s))
            ClosePositions(s, "fim da sessão");
         g_state[s] = ST_DONE;
         continue;
        }
      //--- Fim da janela de entradas: tira ordens pendentes, mantém posição aberta
      if(mod >= g_s[s].entryEndMin && CountPendings(s) > 0)
         DeletePendings(s);

      if(g_dayDone || g_killed)
        {
         DeletePendings(s);
         continue;
        }

      ManageBreakeven(s);

      //--- Sessão em andamento
      if(g_state[s] == ST_ARMED)
        {
         bool pos  = HasPosition(s);
         int  pend = CountPendings(s);
         if(tradesToday >= InpMaxTradesPerDay && pend > 0)
            DeletePendings(s);
         if(!pos && pend < 2)
           {
            // Algum trade já aconteceu e fechou. Ganhou ou saiu no zero -> sessão acabou.
            // Perdeu -> deixa a ordem do lado oposto (reversão do rompimento falso).
            // Obs.: se só uma ordem foi colocada e ainda não disparou, had=false e nada muda.
            double last = 0.0;
            bool   had  = LastExitNet(s, LocalToServer(s, lday), last);
            // Saída no zero a zero rende um pouco negativo (comissão/spread): só conta como
            // "perdeu" se levou mais da metade do risco.
            bool lost = had && last < -0.5 * RiskPerTrade();
            if(pend == 0 || (had && !lost) || tradesToday >= InpMaxTradesPerDay)
              {
               DeletePendings(s);
               g_state[s] = ST_DONE;
              }
           }
         continue;
        }

      //--- Armar a sessão: logo após a faixa, dentro da janela de entradas
      if(g_state[s] == ST_IDLE && ClkIsWeekday(lday) &&
         mod >= g_s[s].startMin + g_s[s].rangeMin && mod < g_s[s].entryEndMin)
        {
         // Reinício do terminal no meio da sessão: não duplica ordens
         if(HasPosition(s) || CountPendings(s) > 0 || EntriesSince(LocalToServer(s, lday), s) > 0)
           {
            g_state[s] = ST_ARMED;
            continue;
           }
         if(tradesToday >= InpMaxTradesPerDay)
           {
            g_state[s] = ST_DONE;
            continue;
           }
         int res = ArmSession(s, lday);
         if(res == 1)
            g_state[s] = ST_ARMED;
         else if(res == 0)
            g_state[s] = ST_DONE;
        }
     }
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   g_clkOffset = InpServerGMTOffset;
   g_clkDST    = InpServerDST;

   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpDailyMaxLoss <= 0.0)
     {
      Alert("[OA] Defina a PERDA MÁXIMA DIÁRIA (InpDailyMaxLoss) antes de ligar. Sem ela o EA não opera.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpDailyTarget <= 0.0)
      return INIT_PARAMETERS_INCORRECT;
   if(InpDailyMaxLoss > eq * 0.05)
     {
      Alert(StringFormat("[OA] Perda diária US$ %.2f é mais de 5%% da conta (US$ %.2f). Recusando.", InpDailyMaxLoss, eq));
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpDailyTarget > eq * 0.01)
      PrintFormat("[OA] AVISO: meta de US$ %.2f é %.1f%% da conta por dia. Isso não é sustentável.",
                  InpDailyTarget, InpDailyTarget / eq * 100.0);
   if(StringFind(_Symbol, "XAU") < 0)
      PrintFormat("[OA] AVISO: este EA foi desenhado para XAUUSD, não para %s.", _Symbol);

   g_s[SES_LONDON].on          = InpLonOn;
   g_s[SES_LONDON].tz          = SES_LONDON;
   g_s[SES_LONDON].startMin    = InpLonStartH * 60 + InpLonStartM;
   g_s[SES_LONDON].rangeMin    = InpLonRangeMin;
   g_s[SES_LONDON].entryEndMin = InpLonEntryEndH * 60 + InpLonEntryEndM;
   g_s[SES_LONDON].exitMin     = InpLonExitH * 60 + InpLonExitM;
   g_s[SES_LONDON].name        = "Londres";

   g_s[SES_NY].on          = InpNYOn;
   g_s[SES_NY].tz          = SES_NY;
   g_s[SES_NY].startMin    = InpNYStartH * 60 + InpNYStartM;
   g_s[SES_NY].rangeMin    = InpNYRangeMin;
   g_s[SES_NY].entryEndMin = InpNYEntryEndH * 60 + InpNYEntryEndM;
   g_s[SES_NY].exitMin     = InpNYExitH * 60 + InpNYExitM;
   g_s[SES_NY].name        = "NovaYork";

   for(int s = 0; s < 2; s++)
      if(g_s[s].startMin + g_s[s].rangeMin >= g_s[s].entryEndMin || g_s[s].entryEndMin > g_s[s].exitMin ||
         g_s[s].rangeMin < 5)
        {
         PrintFormat("[OA] Horários inválidos na sessão %s.", g_s[s].name);
         return INIT_PARAMETERS_INCORRECT;
        }

   g_trade.SetDeviationInPoints(InpDeviationPts);
   g_trade.SetTypeFillingBySymbol(_Symbol);

   g_gvPeak = StringFormat("OA_%I64u_peak", InpMagic);
   g_gvKill = StringFormat("OA_%I64u_killed", InpMagic);
   g_killed = GlobalVariableCheck(g_gvKill) && GlobalVariableGet(g_gvKill) > 0.0;
   if(g_killed)
      PrintFormat("[OA] EA DESLIGADO pela proteção de drawdown (variável global %s).", g_gvKill);

   datetime srv = TimeCurrent();
   PrintFormat("[OA] Servidor %s | Londres %s | NY %s | risco por trade US$ %.2f | meta US$ %.2f | perda máx US$ %.2f",
               TimeToString(srv, TIME_MINUTES), TimeToString(ClkServerToLondon(srv), TIME_MINUTES),
               TimeToString(ClkServerToNY(srv), TIME_MINUTES), RiskPerTrade(), InpDailyTarget, InpDailyMaxLoss);

   EventSetTimer(5);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason) { EventKillTimer(); }
void OnTick()  { Process(); }
void OnTimer() { Process(); }
//+------------------------------------------------------------------+
