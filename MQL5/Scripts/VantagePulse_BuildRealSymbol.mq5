//+------------------------------------------------------------------+
//| VantagePulse_BuildRealSymbol.mq5                                 |
//| Cria um simbolo customizado (copia do original) e grava nele os  |
//| ticks REAIS do proprio terminal, dia a dia. O tester passa a     |
//| usar 100% desses ticks (sem descartar nem gerar ticks sinteticos)|
//| Nao envia ordens. Resultado: MQL5\Files\VP_real_symbol_build.csv |
//+------------------------------------------------------------------+
#property copyright "LZ Trading"
#property version   "1.00"
#property script_show_inputs

input string InpSource   = "WINZ26";
input string InpTarget   = "WINZ26_R";
input string InpFrom     = "2026.10.13";
input string InpTo       = "2026.11.12";   // exclusivo
input int    InpStartMin = 8*60 + 30;       // 08:30 servidor
input int    InpEndMin   = 18*60 + 30;      // 18:30 servidor
input bool   InpExitTerminal = false;

void Finish(const int code) { if(InpExitTerminal) TerminalClose(code); }

void OnStart()
{
   int h = FileOpen("VP_real_symbol_build.csv", FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(h == INVALID_HANDLE) { Finish(1); return; }
   FileWrite(h, "date", "ticks_origem", "ticks_gravados", "erro");
   SymbolSelect(InpSource, true);
   bool exists = SymbolSelect(InpTarget, true);
   if(!exists)
   {
      ResetLastError();
      if(!CustomSymbolCreate(InpTarget, "Custom\\VantagePulse", InpSource))
      { FileWrite(h, "CRIAR_SIMBOLO", 0, 0, GetLastError()); FileClose(h); Finish(2); return; }
   }
   datetime d0 = StringToTime(InpFrom), d1 = StringToTime(InpTo);
   long total_src = 0, total_new = 0;
   for(datetime d = d0; d < d1; d += 86400)
   {
      MqlDateTime dt; TimeToStruct(d, dt);
      if(dt.day_of_week == 0 || dt.day_of_week == 6) continue;
      ulong ma = (ulong)(d + InpStartMin*60) * 1000, mb = (ulong)(d + InpEndMin*60) * 1000;
      MqlTick ticks[];
      ResetLastError();
      int n = CopyTicksRange(InpSource, ticks, COPY_TICKS_ALL, ma, mb);
      if(n <= 0) { FileWrite(h, TimeToString(d, TIME_DATE), 0, 0, GetLastError()); continue; }
      ResetLastError();
      int added = CustomTicksReplace(InpTarget, (long)ma, (long)mb, ticks);
      FileWrite(h, TimeToString(d, TIME_DATE), n, added, (added < 0 ? GetLastError() : 0));
      FileFlush(h);
      total_src += n; if(added > 0) total_new += added;
      ArrayFree(ticks);
   }
   FileWrite(h, "TOTAL", total_src, total_new, 0);
   FileClose(h);
   SymbolSelect(InpTarget, true);
   Print("VP_BuildRealSymbol: concluido, ticks origem=", total_src, " gravados=", total_new);
   Finish(0);
}
