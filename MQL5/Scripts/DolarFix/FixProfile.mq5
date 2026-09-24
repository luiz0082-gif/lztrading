//+------------------------------------------------------------------+
//|                                                  FixProfile.mq5  |
//|  DIAGNÓSTICO — rode ANTES de ligar o EA DolarFix.                |
//|                                                                  |
//|  Mede, com os dados da SUA corretora, o retorno médio de uma     |
//|  cesta de dólar (USD contra EUR, GBP, AUD, NZD, JPY, CHF, CAD)   |
//|  em cada janela de 30 min do dia de Londres, separando dias      |
//|  normais e o último dia útil do mês.                             |
//|                                                                  |
//|  Se a tese estiver certa, você verá o dólar SUBINDO nas horas    |
//|  antes das 16:00 de Londres (fixing WM/R) e CAINDO depois.       |
//|  Se não vir isso, NÃO ligue o EA.                                |
//|                                                                  |
//|  Saída: aba Experts + arquivo MQL5/Files/FixProfile.csv          |
//+------------------------------------------------------------------+
#property copyright "lztrading"
#property version   "1.00"
#property script_show_inputs

#include <DolarFix/FixClock.mqh>

input string          InpSymbols   = "EURUSD,GBPUSD,AUDUSD,NZDUSD,USDJPY,USDCHF,USDCAD"; // Cesta de dólar
input string          InpSuffix    = "";          // Sufixo da corretora (ex.: ".r", "m")
input int             InpGMTOffset = 2;           // Offset GMT do servidor no INVERNO
input ENUM_SERVER_DST InpDST       = SRV_DST_US;  // Regra de DST do servidor
input datetime        InpFrom      = D'2016.01.01'; // Início (use só a METADE ANTIGA dos dados)
input datetime        InpTo        = D'2021.01.01'; // Fim    (a outra metade é o seu fora-da-amostra)

#define SLOTS 48

//+------------------------------------------------------------------+
void OnStart()
  {
   g_clkOffset = InpGMTOffset;
   g_clkDST    = InpDST;

   string syms[];
   int ns = ClkParseSymbols(InpSymbols, InpSuffix, syms);
   if(ns < 2)
     {
      Print("[FP] Preciso de pelo menos 2 pares com USD.");
      return;
     }

   //--- Carrega M30 de todos os símbolos
   int sign[];
   ArrayResize(sign, ns);
   // Guardamos tempos e fechamentos em arrays "achatados": offset[s] .. offset[s]+cnt[s]-1
   datetime allT[];
   double   allC[];
   int      offs[], cnts[];
   ArrayResize(offs, ns);
   ArrayResize(cnts, ns);
   int total = 0;
   for(int s = 0; s < ns; s++)
     {
      sign[s] = ClkUSDSign(syms[s]);
      MqlRates rr[];
      int got = CopyRates(syms[s], PERIOD_M30, InpFrom, InpTo, rr);
      if(got <= 0 || sign[s] == 0)
        {
         PrintFormat("[FP] %s: sem dados M30 (%d) ou sem USD. Abra o gráfico M30 dele e role para trás para baixar histórico.",
                     syms[s], got);
         cnts[s] = 0;
         offs[s] = total;
         continue;
        }
      offs[s] = total;
      cnts[s] = got;
      ArrayResize(allT, total + got);
      ArrayResize(allC, total + got);
      for(int i = 0; i < got; i++)
        {
         allT[total + i] = rr[i].time;
         allC[total + i] = rr[i].close;
        }
      total += got;
      PrintFormat("[FP] %s: %d barras M30 (sinal USD %+d)", syms[s], got, sign[s]);
     }

   //--- Referência de tempo: o símbolo com mais barras
   int ref = 0;
   for(int s = 1; s < ns; s++)
      if(cnts[s] > cnts[ref])
         ref = s;
   if(cnts[ref] < 1000)
     {
      Print("[FP] Histórico insuficiente.");
      return;
     }

   // acumuladores [0]=dias normais, [1]=fim de mês
   double sum[2][SLOTS], sq[2][SLOTS];
   int    cnt[2][SLOTS];
   ArrayInitialize(sum, 0.0);
   ArrayInitialize(sq, 0.0);
   ArrayInitialize(cnt, 0);

   int cursor[];
   ArrayResize(cursor, ns);
   for(int s = 0; s < ns; s++)
      cursor[s] = 1;

   for(int i = 1; i < cnts[ref]; i++)
     {
      datetime tt = allT[offs[ref] + i];
      double basket = 0.0;
      int used = 0;
      for(int s = 0; s < ns; s++)
        {
         if(cnts[s] < 2)
            continue;
         // avança o cursor do símbolo s até o tempo tt (arrays ordenados)
         int j = cursor[s];
         while(j < cnts[s] - 1 && allT[offs[s] + j] < tt)
            j++;
         cursor[s] = j;
         if(allT[offs[s] + j] != tt || allT[offs[s] + j - 1] != tt - 1800)
            continue;
         double c1 = allC[offs[s] + j], c0 = allC[offs[s] + j - 1];
         if(c0 <= 0.0 || c1 <= 0.0)
            continue;
         basket += sign[s] * MathLog(c1 / c0);
         used++;
        }
      if(used < MathMax(2, ns - 2))
         continue;
      basket /= used;                              // retorno do "dólar" nesta meia hora
      datetime lon  = ClkServerToLondon(tt);       // tt = abertura da barra
      datetime day  = ClkDayStart(lon);
      if(!ClkIsWeekday(day))
         continue;
      int slot = (int)((lon - day) / 1800);
      if(slot < 0 || slot >= SLOTS)
         continue;
      int g = ClkIsMonthEnd(day) ? 1 : 0;
      sum[g][slot] += basket;
      sq[g][slot]  += basket * basket;
      cnt[g][slot]++;
     }

   //--- Relatório
   int fh = FileOpen("FixProfile.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
   if(fh != INVALID_HANDLE)
      FileWrite(fh, "slot_londres", "normal_media_bps", "normal_t", "normal_n", "normal_acum_bps",
                "fimdemes_media_bps", "fimdemes_t", "fimdemes_n", "fimdemes_acum_bps");
   Print("[FP] Retorno médio do DÓLAR por meia hora (hora de Londres, abertura da barra). + = dólar sobe");
   Print("[FP] slot  | normal: média bps (t)  acum | fim de mês: média bps (t)  acum");
   double acc[2] = {0.0, 0.0};
   for(int k = 0; k < SLOTS; k++)
     {
      double m[2], tst[2];
      for(int g = 0; g < 2; g++)
        {
         m[g] = 0.0; tst[g] = 0.0;
         if(cnt[g][k] > 1)
           {
            m[g] = sum[g][k] / cnt[g][k];
            double var = (sq[g][k] - cnt[g][k] * m[g] * m[g]) / (cnt[g][k] - 1);
            if(var > 0.0)
               tst[g] = m[g] / MathSqrt(var / cnt[g][k]);
           }
         acc[g] += m[g];
        }
      string hhmm = StringFormat("%02d:%02d", k / 2, (k % 2) * 30);
      PrintFormat("[FP] %s | %+6.2f (%+5.2f) %+7.2f | %+6.2f (%+5.2f) %+7.2f%s",
                  hhmm, m[0] * 1e4, tst[0], acc[0] * 1e4, m[1] * 1e4, tst[1], acc[1] * 1e4,
                  (k == 32 ? "   <== 16:00 fixing WM/R" : ""));
      if(fh != INVALID_HANDLE)
         FileWrite(fh, hhmm, DoubleToString(m[0] * 1e4, 3), DoubleToString(tst[0], 2), cnt[0][k],
                   DoubleToString(acc[0] * 1e4, 3), DoubleToString(m[1] * 1e4, 3), DoubleToString(tst[1], 2),
                   cnt[1][k], DoubleToString(acc[1] * 1e4, 3));
     }
   if(fh != INVALID_HANDLE)
      FileClose(fh);

   //--- Custo atual de referência
   Print("[FP] Spread AGORA por par (compare com as médias acima; custo de ida+volta ≈ spread + comissão):");
   for(int s = 0; s < ns; s++)
     {
      double b = SymbolInfoDouble(syms[s], SYMBOL_BID), a = SymbolInfoDouble(syms[s], SYMBOL_ASK);
      if(b > 0.0 && a > 0.0)
         PrintFormat("[FP]   %s: %.2f bps", syms[s], (a - b) / ((a + b) / 2.0) * 1e4);
     }
   Print("[FP] Arquivo salvo em MQL5/Files/FixProfile.csv");
  }
//+------------------------------------------------------------------+
