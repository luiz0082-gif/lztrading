//+------------------------------------------------------------------+
//| VantagePulse_ExportTicks.mq5                                     |
//| Exporta os ticks REAIS (bid, ask, last, volume, flags) por dia   |
//| para arquivos binarios MQL5\Files\VP_ticks_AAAAMMDD.bin.         |
//| Registro de 32 bytes: int64 time_msc, int32 bid, ask, last, vol, |
//| uint32 flags, int32 pad. Precos em pontos inteiros (WIN).        |
//| Somente leitura de dados; nao envia ordens.                      |
//+------------------------------------------------------------------+
#property copyright "LZ Trading"
#property version   "1.00"
#property script_show_inputs

input string InpSymbol = "WINZ26";
input string InpFrom   = "2026.10.14";
input string InpTo     = "2026.11.12";   // exclusivo
input int    InpStartMin = 8*60 + 30;
input int    InpEndMin   = 18*60 + 30;
input bool   InpExitTerminal = false;

struct VPRec { long t; int bid; int ask; int last; int vol; uint flags; int pad; };

void OnStart()
{
   int h = FileOpen("VP_export_ticks.csv", FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   FileWrite(h, "date", "ticks", "bytes");
   SymbolSelect(InpSymbol, true);
   datetime d0 = StringToTime(InpFrom), d1 = StringToTime(InpTo);
   long total = 0;
   for(datetime d = d0; d < d1; d += 86400)
   {
      MqlDateTime dt; TimeToStruct(d, dt);
      if(dt.day_of_week == 0 || dt.day_of_week == 6) continue;
      ulong ma = (ulong)(d + InpStartMin*60) * 1000, mb = (ulong)(d + InpEndMin*60) * 1000;
      MqlTick ticks[];
      int n = CopyTicksRange(InpSymbol, ticks, COPY_TICKS_ALL, ma, mb);
      if(n <= 0) continue;
      VPRec rec[];
      ArrayResize(rec, n);
      for(int i = 0; i < n; i++)
      {
         rec[i].t = (long)ticks[i].time_msc;
         rec[i].bid = (int)MathRound(ticks[i].bid);
         rec[i].ask = (int)MathRound(ticks[i].ask);
         rec[i].last = (int)MathRound(ticks[i].last);
         rec[i].vol = (int)MathMin((ulong)2000000000, ticks[i].volume);
         rec[i].flags = ticks[i].flags;
         rec[i].pad = 0;
      }
      string fn = "VP_ticks_" + TimeToString(d, TIME_DATE) + ".bin";
      StringReplace(fn, ".", "");
      fn = "VP_ticks_" + StringFormat("%04d%02d%02d", dt.year, dt.mon, dt.day) + ".bin";
      int f = FileOpen(fn, FILE_WRITE|FILE_BIN);
      if(f != INVALID_HANDLE)
      {
         FileWriteArray(f, rec, 0, n);
         FileClose(f);
         FileWrite(h, StringFormat("%04d-%02d-%02d", dt.year, dt.mon, dt.day), n, n * 32);
         FileFlush(h);
         total += n;
      }
      ArrayFree(ticks); ArrayFree(rec);
   }
   FileWrite(h, "TOTAL", total, total * 32);
   FileClose(h);
   Print("VP_ExportTicks: concluido, total=", total);
   if(InpExitTerminal) TerminalClose(0);
}
