//+------------------------------------------------------------------+
//| VantagePulse_TickAudit.mq5                                       |
//| Auditoria de ticks reais x barras M1 por dia (somente leitura).  |
//| Nao envia ordens. Escreve MQL5\Files\VP_tick_audit.csv           |
//| Reproduz a causa do aviso "real ticks discarded" do tester:      |
//| compara a maxima/minima/volume de cada barra M1 com as           |
//| reconstruidas a partir dos ticks do proprio terminal.            |
//+------------------------------------------------------------------+
#property copyright "LZ Trading"
#property version   "1.00"
#property script_show_inputs

input string InpSymbol   = "WINZ26";
input string InpFrom     = "2026.10.13";
input string InpTo       = "2026.11.12";   // exclusivo
input int    InpSessionStartMin = 9*60;      // 09:00 servidor
input int    InpSessionEndMin   = 18*60;     // 18:00 servidor
input bool   InpExitTerminal = false;        // fecha o terminal ao terminar (usado pelo runner)

void OnStart()
{
   datetime d0 = StringToTime(InpFrom), d1 = StringToTime(InpTo);
   int h = FileOpen("VP_tick_audit.csv", FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(h == INVALID_HANDLE) { Print("VP_TickAudit: nao abriu CSV, erro=", GetLastError()); if(InpExitTerminal) TerminalClose(1); return; }
   FileWrite(h, "date", "weekday", "ticks", "ticks_last_gt0", "ticks_flag_buy_sell", "bars_m1", "bars_with_ticks",
             "bars_high_mismatch", "bars_low_mismatch", "bars_volume_mismatch", "bars_any_mismatch", "pct_bars_mismatch",
             "ticks_per_min_avg", "max_gap_s", "first_tick", "last_tick", "price_mode_used");
   SymbolSelect(InpSymbol, true);
   for(datetime d = d0; d < d1; d += 86400)
   {
      MqlDateTime dt; TimeToStruct(d, dt);
      if(dt.day_of_week == 0 || dt.day_of_week == 6) continue;
      datetime a = d + InpSessionStartMin*60, b = d + InpSessionEndMin*60;
      MqlRates rates[];
      int nb = CopyRates(InpSymbol, PERIOD_M1, a, b, rates);
      MqlTick ticks[];
      ulong ma = (ulong)a*1000, mb = (ulong)b*1000;
      int nt = CopyTicksRange(InpSymbol, ticks, COPY_TICKS_ALL, ma, mb);
      if(nb <= 0 || nt <= 0)
      {
         FileWrite(h, TimeToString(d, TIME_DATE), dt.day_of_week, MathMax(nt,0), 0, 0, MathMax(nb,0), 0, 0, 0, 0, 0, 0.0, 0.0, 0, "", "", "sem dados");
         continue;
      }
      int with_last = 0, with_flags = 0;
      for(int i=0;i<nt;i++)
      {
         if(ticks[i].last > 0.0) with_last++;
         if((ticks[i].flags & (TICK_FLAG_BUY|TICK_FLAG_SELL)) != 0) with_flags++;
      }
      // reconstroi por minuto: usa LAST quando o tick tem LAST (modo do grafico em B3), senao BID
      int bars_with = 0, mis_h = 0, mis_l = 0, mis_v = 0, mis_any = 0;
      int j = 0; double max_gap = 0.0; ulong prev_msc = 0;
      for(int k=0;k<nb;k++)
      {
         ulong t0 = (ulong)rates[k].time*1000, t1 = t0 + 60000;
         double hi = -1e18, lo = 1e18; int cnt = 0;
         while(j < nt && (ulong)ticks[j].time_msc < t0) j++;
         int jj = j;
         while(jj < nt && (ulong)ticks[jj].time_msc < t1)
         {
            double p = (ticks[jj].last > 0.0) ? ticks[jj].last : ticks[jj].bid;
            if(p > hi) hi = p;
            if(p < lo) lo = p;
            cnt++; jj++;
         }
         if(cnt > 0)
         {
            bars_with++;
            bool mh = (MathAbs(hi - rates[k].high) > 1e-9);
            bool ml = (MathAbs(lo - rates[k].low) > 1e-9);
            bool mv = ((long)cnt != (long)rates[k].tick_volume);
            if(mh) mis_h++;
            if(ml) mis_l++;
            if(mv) mis_v++;
            if(mh || ml || mv) mis_any++;
         }
      }
      for(int i=0;i<nt;i++)
      {
         if(prev_msc > 0) { double g = (double)(ticks[i].time_msc - prev_msc)/1000.0; if(g > max_gap) max_gap = g; }
         prev_msc = ticks[i].time_msc;
      }
      FileWrite(h, TimeToString(d, TIME_DATE), dt.day_of_week, nt, with_last, with_flags, nb, bars_with, mis_h, mis_l, mis_v, mis_any,
                (bars_with > 0 ? DoubleToString(100.0*mis_any/bars_with, 1) : "0"),
                DoubleToString((double)nt/MathMax(1, nb), 1), DoubleToString(max_gap, 1),
                TimeToString((datetime)(ticks[0].time_msc/1000), TIME_SECONDS), TimeToString((datetime)(ticks[nt-1].time_msc/1000), TIME_SECONDS),
                "last_ou_bid");
      FileFlush(h);
   }
   FileClose(h);
   Print("VP_TickAudit: concluido");
   if(InpExitTerminal) TerminalClose(0);
}
