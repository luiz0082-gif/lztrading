//+------------------------------------------------------------------+
//|                                                    FixClock.mqh  |
//|  Relógio: horário do servidor da corretora <-> horário de        |
//|  Londres. O fixing WM/Reuters é SEMPRE às 16:00 de Londres,      |
//|  então tudo no DolarFix é medido no relógio de Londres.          |
//+------------------------------------------------------------------+
#ifndef DOLARFIX_FIXCLOCK_MQH
#define DOLARFIX_FIXCLOCK_MQH

//--- Regra de horário de verão do SERVIDOR da corretora
enum ENUM_SERVER_DST
  {
   SRV_DST_NONE = 0, // Sem horário de verão (offset fixo)
   SRV_DST_US   = 1, // Segue horário de verão dos EUA (mais comum: GMT+2/+3)
   SRV_DST_EU   = 2  // Segue horário de verão europeu
  };

// Configurados pelo EA/script em OnInit/OnStart
int             g_clkOffset = 2;           // offset GMT do servidor no inverno
ENUM_SERVER_DST g_clkDST    = SRV_DST_US;  // regra de DST do servidor

datetime ClkMakeDate(const int y, const int m, const int d)
  {
   MqlDateTime s;
   ZeroMemory(s);
   s.year = y; s.mon = m; s.day = d;
   return StructToTime(s);
  }

// n-ésimo domingo do mês
datetime ClkNthSunday(const int y, const int m, const int n)
  {
   MqlDateTime s;
   TimeToStruct(ClkMakeDate(y, m, 1), s);
   int firstSun = 1 + (7 - s.day_of_week) % 7;
   return ClkMakeDate(y, m, firstSun + 7 * (n - 1));
  }

// último domingo do mês
datetime ClkLastSunday(const int y, const int m)
  {
   int ny = (m == 12) ? y + 1 : y;
   int nm = (m == 12) ? 1 : m + 1;
   datetime lastDay = ClkMakeDate(ny, nm, 1) - 86400;
   MqlDateTime s;
   TimeToStruct(lastDay, s);
   return lastDay - s.day_of_week * 86400;
  }

// DST dos EUA (recebe horário de parede americano; ±1h na madrugada da troca é irrelevante aqui)
bool ClkIsUSDST(const datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return (t >= ClkNthSunday(s.year, 3, 2) + 2 * 3600 && t < ClkNthSunday(s.year, 11, 1) + 2 * 3600);
  }

// DST europeu/britânico: último domingo de março 01:00 UTC -> último domingo de outubro 01:00 UTC
bool ClkIsEUDST(const datetime gmt)
  {
   MqlDateTime s;
   TimeToStruct(gmt, s);
   return (gmt >= ClkLastSunday(s.year, 3) + 3600 && gmt < ClkLastSunday(s.year, 10) + 3600);
  }

int ClkServerOffset(const datetime gmt)
  {
   int off = g_clkOffset;
   if(g_clkDST == SRV_DST_US && ClkIsUSDST(gmt - 5 * 3600))
      off += 1;
   if(g_clkDST == SRV_DST_EU && ClkIsEUDST(gmt))
      off += 1;
   return off;
  }

datetime ClkServerToGMT(const datetime srv)
  {
   datetime gmt = srv - g_clkOffset * 3600;     // 1ª aproximação (inverno)
   return srv - ClkServerOffset(gmt) * 3600;
  }

datetime ClkServerToLondon(const datetime srv)
  {
   datetime gmt = ClkServerToGMT(srv);
   return gmt + (ClkIsEUDST(gmt) ? 3600 : 0);
  }

datetime ClkLondonToServer(const datetime lon)
  {
   datetime gmt = lon - (ClkIsEUDST(lon - 3600) ? 3600 : 0);
   return gmt + ClkServerOffset(gmt) * 3600;
  }

datetime ClkDayStart(const datetime t) { return (datetime)((long)t - (long)t % 86400); }

bool ClkIsWeekday(const datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return (s.day_of_week >= 1 && s.day_of_week <= 5);
  }

// Último dia útil (seg-sex) do mês? Não conhece feriados: é o dia do fixing de fim de mês
// na imensa maioria dos meses; nos raros casos de feriado no último dia, erra por 1 dia.
bool ClkIsMonthEnd(const datetime day)
  {
   datetime next = day + 86400;
   while(!ClkIsWeekday(next))
      next += 86400;
   MqlDateTime a, b;
   TimeToStruct(day, a);
   TimeToStruct(next, b);
   return (a.mon != b.mon);
  }

// Sinal do "dólar" num par: +1 se comprar o par = comprar USD, -1 se comprar o par = vender USD,
// 0 se o par não tem USD (cruzamentos/minors).
int ClkUSDSign(const string sym)
  {
   string base   = SymbolInfoString(sym, SYMBOL_CURRENCY_BASE);
   string profit = SymbolInfoString(sym, SYMBOL_CURRENCY_PROFIT);
   if(base == "USD" && profit != "USD")
      return +1;
   if(profit == "USD" && base != "USD")
      return -1;
   return 0;
  }

// Lista "EURUSD,GBPUSD" + sufixo -> array de símbolos válidos (adiciona no Market Watch)
int ClkParseSymbols(const string list, const string suffix, string &out[])
  {
   string parts[];
   int n = StringSplit(list, ',', parts);
   ArrayResize(out, 0);
   for(int i = 0; i < n; i++)
     {
      string s = parts[i];
      StringTrimLeft(s);
      StringTrimRight(s);
      if(s == "")
         continue;
      s += suffix;
      if(!SymbolSelect(s, true))
        {
         PrintFormat("[DF] Símbolo %s não existe nesta corretora. Ignorado.", s);
         continue;
        }
      int k = ArraySize(out);
      ArrayResize(out, k + 1);
      out[k] = s;
     }
   return ArraySize(out);
  }

#endif
//+------------------------------------------------------------------+
