//+------------------------------------------------------------------+
//| ListSymbols.mq5                                                  |
//| Lists EVERY symbol the connected server offers (not only Market  |
//| Watch) with the fields needed to choose what to collect.         |
//| Output: Common\Files\ListSymbols_<server>.csv                    |
//| Non-trading. Run once on any chart (drag the script onto it).    |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property description "Writes all server symbols (path, description, spread, contract, trade mode) to a CSV in the Common Files folder."
#property script_show_inputs

input bool InpOnlyTradable = false;   // true = skip symbols with trade mode DISABLED

string Q(string s)
  {
   StringReplace(s,"\"","'");
   return "\""+s+"\"";
  }

int OnStart()
  {
   string server=AccountInfoString(ACCOUNT_SERVER);
   string company=AccountInfoString(ACCOUNT_COMPANY);
   StringReplace(server," ","_");
   string fn="ListSymbols_"+server+".csv";
   int h=FileOpen(fn,FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON,0,CP_UTF8);
   if(h==INVALID_HANDLE)
     {
      Print("ListSymbols: cannot open ",fn," error ",GetLastError());
      return 1;
     }
   FileWriteString(h,"symbol,path,description,base_currency,profit_currency,digits,point,spread_points,spread_float,contract_size,tick_size,tick_value,volume_min,volume_step,trade_mode,calc_mode,in_market_watch,session_deals_trading_hint\r\n");
   int total=SymbolsTotal(false);
   int written=0;
   for(int i=0;i<total;i++)
     {
      string s=SymbolName(i,false);
      if(StringLen(s)==0) continue;
      long tm=SymbolInfoInteger(s,SYMBOL_TRADE_MODE);
      if(InpOnlyTradable && tm==SYMBOL_TRADE_MODE_DISABLED) continue;
      bool inmw=(bool)SymbolInfoInteger(s,SYMBOL_SELECT);
      string line=Q(s)+","+Q(SymbolInfoString(s,SYMBOL_PATH))+","+Q(SymbolInfoString(s,SYMBOL_DESCRIPTION))+","+
                  Q(SymbolInfoString(s,SYMBOL_CURRENCY_BASE))+","+Q(SymbolInfoString(s,SYMBOL_CURRENCY_PROFIT))+","+
                  IntegerToString((int)SymbolInfoInteger(s,SYMBOL_DIGITS))+","+DoubleToString(SymbolInfoDouble(s,SYMBOL_POINT),8)+","+
                  IntegerToString((int)SymbolInfoInteger(s,SYMBOL_SPREAD))+","+(SymbolInfoInteger(s,SYMBOL_SPREAD_FLOAT)?"TRUE":"FALSE")+","+
                  DoubleToString(SymbolInfoDouble(s,SYMBOL_TRADE_CONTRACT_SIZE),4)+","+DoubleToString(SymbolInfoDouble(s,SYMBOL_TRADE_TICK_SIZE),8)+","+
                  DoubleToString(SymbolInfoDouble(s,SYMBOL_TRADE_TICK_VALUE),6)+","+DoubleToString(SymbolInfoDouble(s,SYMBOL_VOLUME_MIN),4)+","+
                  DoubleToString(SymbolInfoDouble(s,SYMBOL_VOLUME_STEP),4)+","+IntegerToString((int)tm)+","+IntegerToString((int)SymbolInfoInteger(s,SYMBOL_TRADE_CALC_MODE))+","+
                  (inmw?"TRUE":"FALSE")+","+Q(company);
      FileWriteString(h,line+"\r\n");
      written++;
     }
   FileClose(h);
   PrintFormat("ListSymbols: %d of %d symbols written to Common\\Files\\%s",written,total,fn);
   Comment(StringFormat("ListSymbols: %d symbols -> Common\\Files\\%s",written,fn));
   return 0;
  }
