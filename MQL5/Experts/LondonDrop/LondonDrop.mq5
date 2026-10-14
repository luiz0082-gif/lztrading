//+------------------------------------------------------------------+
//| LondonDrop.mq5                                                   |
//| Ouro: operacao unica por dia no relogio de Londres (10:20).      |
//| Tese (hipotese em teste): o ouro tende a cair no candle M5 das   |
//| 10:25 de Londres (docs/relatorios/RELATORIO-MBA-ANALISE-COMPLETA).|
//| Sem stop loss por padrao. Saida por tempo (23:30 servidor),      |
//| meta em dinheiro e trailing no estilo PieceTrend.                |
//| EA DE TESTE: validar em demo antes de qualquer uso real.         |
//+------------------------------------------------------------------+
#property strict
#property version   "1.02"
#property description "LondonDrop - venda/compra unica por dia no horario de Londres, sem SL por padrao."
#include <Trade\Trade.mqh>

#define LD_NAME      "LondonDrop"
#define LD_VERSION   "1.02"
#define LD_SCHEMA    "LD1"
#define LD_FOLDER    "LondonDrop\\"
#define LD_PREFIX    "LD_PNL_"

enum LD_DIRECTION   { LD_SELL=0, LD_BUY=1 };
enum LD_CLOCK       { LD_CLOCK_LONDON=0, LD_CLOCK_SERVER=1, LD_CLOCK_UTC=2 };
enum LD_SERVER_RULE { LD_RULE_NYCLOSE=0, LD_RULE_TIMEGMT=1 };
enum LD_LOT_MODE    { LD_LOT_FIXED=0, LD_LOT_BY_TARGET=1 };
enum LD_TP_MODE     { LD_TP_MONEY=0, LD_TP_POINTS=1 };

//====================================================================
// INPUTS
//====================================================================
input group "══════ 01 | IDENTIFICAÇÃO ══════"
input bool          InpEnableTrading        = true;        // Habilitar ordens (false = so monitora e grava telemetria)
input long          InpMagicNumber          = 0;           // Magic (0 = automatico por simbolo/instancia)
input int           InpInstanceID           = 1;           // Numero da instancia (entra no magic automatico)
input string        InpOrderComment         = "LondonDrop";// Comentario das ordens

input group "══════ 02 | SÍMBOLO ══════"
input bool          InpRequireGoldSymbol    = true;        // Exigir simbolo de ouro (nome contem XAU ou GOLD)

input group "══════ 03 | ESTRATÉGIA / SINAL ══════"
input LD_DIRECTION  InpDirection            = LD_SELL;     // Direcao da operacao (SELL = tese testada; BUY = opcional, sem suporte nos dados)
input LD_CLOCK      InpEntryClock           = LD_CLOCK_LONDON; // Relogio do horario de entrada (LONDRES recomendado)
input int           InpEntryHour            = 10;          // Hora de entrada (0-23) no relogio escolhido
input int           InpEntryMinute          = 20;          // Minuto de entrada (0-59) no relogio escolhido
input int           InpEntryWindowSeconds   = 120;         // Janela de entrada apos o horario (segundos); fora dela o dia e perdido
input bool          InpTradeMonday          = true;        // Operar segunda
input bool          InpTradeTuesday         = true;        // Operar terca
input bool          InpTradeWednesday       = true;        // Operar quarta
input bool          InpTradeThursday        = true;        // Operar quinta
input bool          InpTradeFriday          = true;        // Operar sexta
input string        InpSkipDates            = "";          // Datas a pular (data de Londres, AAAA.MM.DD separadas por virgula; feriados)

input group "══════ 04 | FILTROS ══════"
input bool          InpUseSpreadFilter      = true;        // Bloquear se o spread estiver alto
input double        InpMaxSpreadPoints      = 25.0;        // Spread maximo na entrada (pontos)
input bool          InpUseTickAgeFilter     = true;        // Bloquear se o ultimo tick estiver velho
input int           InpMaxTickAgeSeconds    = 15;          // Idade maxima do ultimo tick (segundos)
input bool          InpUseNewsFilter        = true;        // Bloquear se houver noticia importante perto da entrada (calendario do MT5)
input string        InpNewsCurrency         = "USD";       // Moeda do calendario
input int           InpNewsMinImportance    = 3;           // Importancia minima (1 baixa, 2 media, 3 alta)
input int           InpNewsMinutesBefore    = 10;          // Janela antes da entrada (minutos)
input int           InpNewsMinutesAfter     = 10;          // Janela depois da entrada (minutos)
input bool          InpNewsBlockOnError     = false;       // Bloquear a entrada se o calendario estiver indisponivel

input group "══════ 05 | HORÁRIOS E SESSÕES ══════"
input LD_SERVER_RULE InpServerRule          = LD_RULE_NYCLOSE; // Conversao servidor->UTC (NYCLOSE: UTC+3 no verao dos EUA, UTC+2 no resto; TIMEGMT: usa o relogio do PC)
input bool          InpUseNoEntryBeforeExit = true;        // Nao entrar perto da saida por tempo
input int           InpNoEntryMinutesBeforeExit = 60;      // Minutos antes da saida por tempo em que nao se entra

input group "══════ 06 | EXECUÇÃO ══════"
input int           InpDeviationPoints      = 30;          // Desvio maximo do preco (pontos)
input int           InpMaxRetries           = 3;           // Tentativas de envio/fechamento
input int           InpRetryDelayMs         = 300;         // Espera entre tentativas (ms)

input group "══════ 07 | GESTÃO DE RISCO ══════"
input LD_LOT_MODE   InpLotMode              = LD_LOT_FIXED;// Modo do lote (FIXED = lote fixo; BY_TARGET = lote que rende a meta em dinheiro em N pontos)
input double        InpLotFixed             = 0.01;        // Lote fixo
input int           InpLotTargetPoints      = 500;         // BY_TARGET: pontos que devem render a meta em dinheiro (usa a meta do setor 09)
input double        InpLotMax               = 0.10;        // Lote maximo permitido (trava de seguranca)
input double        InpMinFreeMarginAfterPct= 50.0;        // Margem livre minima apos a ordem (% da margem livre atual)
input bool          InpUseEmergencyClose    = true;        // Fechar a mercado se a perda flutuante passar do limite (virtual, so com terminal conectado; NAO e stop no servidor)
input double        InpEmergencyLossMoney   = 15.0;        // Perda flutuante que aciona a emergencia (moeda da conta; 15 = 1500 pts em 0,01 lote)
input bool          InpUseWeeklyLossLimit   = true;        // Parar de entrar se a perda da semana passar do limite
input double        InpWeeklyLossLimitMoney = 50.0;        // Perda semanal maxima (moeda da conta)
input bool          InpUseCircuitBreaker    = true;        // Circuit breaker: pausa apos perdas consecutivas ou drawdown
input int           InpCBConsecutiveLossDays= 3;           // Dias seguidos com perda que acionam a pausa
input bool          InpCBUseDrawdown        = true;        // Acionar tambem por drawdown acumulado
input double        InpCBDrawdownMoney      = 60.0;        // Drawdown acumulado que aciona a pausa (moeda da conta)
input int           InpCBPauseDays          = 2;           // Dias de pausa depois do acionamento

input group "══════ 08 | STOP LOSS (desativado) ══════"
input bool          InpUseStopLoss          = false;       // Stop loss no servidor (DESATIVADO por padrao)
input double        InpStopLossMoney        = 30.0;        // Distancia do stop em dinheiro (se ativado)
input bool          InpUseDisasterStop      = false;       // Stop de desastre no servidor: seguro contra queda do terminal/VPS (DESATIVADO)
input double        InpDisasterStopMoney    = 100.0;       // Distancia do stop de desastre em dinheiro (se ativado)

input group "══════ 09 | PROFIT / ALVO ══════"
input bool          InpUseTakeProfit        = true;        // Usar take profit (enviado ao servidor)
input LD_TP_MODE    InpTPMode               = LD_TP_MONEY; // Como definir o alvo (MONEY ou POINTS)
input double        InpTakeProfitMoney      = 5.0;         // Alvo em dinheiro por operacao (moeda da conta)
input int           InpTakeProfitPoints     = 500;         // Alvo em pontos (se TPMode = POINTS)
input bool          InpUseDailyTarget       = true;        // Parar de operar no dia ao atingir a meta diaria
input double        InpDailyTargetMoney     = 5.0;         // Meta diaria em dinheiro (moeda da conta)
input bool          InpUseEndOfDayExit      = true;        // Saida obrigatoria por tempo (relogio do servidor)
input int           InpExitHourServer       = 23;          // Hora da saida (servidor)
input int           InpExitMinuteServer     = 30;          // Minuto da saida (servidor)
input bool          InpUseMaxHold           = false;       // Saida por tempo maximo de posicao (opcional)
input int           InpMaxHoldMinutes       = 60;          // Tempo maximo de posicao (minutos)

input group "══════ 10 | GERENCIAMENTO DE POSIÇÃO ══════"
input bool          InpUseTrailing          = false;       // Usar trailing (estilo PieceTrend). DESLIGADO: trailing curto fechava ganhos em centavos (13/10/2026)
input bool          InpTrailActivationInPoints = true;     // Ativacao em pontos (true) ou em dinheiro (false)
input int           InpTrailActivationPoints= 150;         // Ativacao do trailing em pontos de lucro maximo
input double        InpTrailActivationMoney = 1.5;         // Ativacao do trailing em dinheiro (se ativacao em dinheiro)
input double        InpTrailRatio           = 0.60;        // Distancia inicial = ratio x ativacao (PieceTrend: 0.60)
input double        InpTrailExponent        = 0.82;        // Expoente de crescimento da distancia (PieceTrend: 0.82)
input bool          InpTrailOnServer        = true;        // Trailing como SL no servidor (false = virtual, so com terminal conectado)
input int           InpTrailMinStepPoints   = 10;          // Passo minimo para mover o stop do trailing (pontos)
input bool          InpTPRemovedOnTrail     = true;        // Retirar o TP quando o trailing ativa (PieceTrend)

input group "══════ 11 | LIMITES DIÁRIOS ══════"
input int           InpMaxTradesPerDay      = 1;           // Operacoes maximas por dia (servidor)
input bool          InpUseDailyLossLimit    = true;        // Bloquear novas entradas se a perda do dia passar do limite
input double        InpDailyLossLimitMoney  = 25.0;        // Perda diaria maxima (moeda da conta)
input bool          InpDailyLossClosePosition = false;     // Fechar tambem a posicao aberta ao atingir o limite diario

input group "══════ 12 | PAINEL ══════"
input bool          InpShowPanel            = true;        // Mostrar painel
input int           InpPanelX               = 12;          // Posicao X do painel (pixels)
input int           InpPanelY               = 24;          // Posicao Y do painel (pixels)
input bool          InpPanelStartMinimized  = false;       // Iniciar minimizado

input group "══════ 13 | TELEMETRIA / CSV / LOGS ══════"
input bool          InpWriteCSV             = true;        // Gravar CSV (MQL5\\Files\\LondonDrop\\)
input int           InpHeartbeatSeconds     = 300;         // Intervalo do heartbeat no CSV (segundos; 0 = desligado)
input bool          InpPrintToExperts       = true;        // Imprimir eventos no log Experts

input group "══════ 14 | AVANÇADO / DIAGNÓSTICO ══════"
input bool          InpDebug                = false;       // Debug detalhado no log

//====================================================================
// GLOBALS
//====================================================================
CTrade   g_trade;
long     g_magic=0;
string   g_runId="";
int      g_eventSeq=0;
datetime g_startTime=0;

// day state (server day)
long     g_dayKey=-1;
bool     g_dayDecided=false;       // decision already taken today (entered or skipped)
string   g_dayDecision="WAITING";
string   g_dayReason="";
string   g_lastBlockReason="";
string   g_lastBlockLogged="";
int      g_tradesToday=0;
double   g_dayStartBalance=0.0;
bool     g_dayRowWritten=false;
string   g_dayExitReason="";
double   g_dayMaxAdverse=0.0;

// pause / CB
bool     g_paused=false;
datetime g_cbPauseUntil=0;
datetime g_cbResetTime=0;
string   g_cbState="OK";
datetime g_lastCbEval=0;

// position state
bool     g_hasPos=false;
ulong    g_posTicket=0;
ulong    g_posId=0;
int      g_posDir=0;               // +1 buy, -1 sell
double   g_posVolume=0.0;
double   g_posEntry=0.0;
datetime g_posOpenTime=0;
double   g_posSL0=0.0, g_posTP0=0.0;
double   g_maxProfit=0.0, g_minProfit=0.0;
double   g_mfePts=0.0, g_maePts=0.0;
double   g_hwm=0.0;                // best price for the position (min ask for sell, max bid for buy)
bool     g_trailActive=false;
double   g_trailStop=0.0;
double   g_trailDistMoney=0.0;
double   g_lockedMoney=0.0;
double   g_entrySpread=0.0;
string   g_pendingExit="";
long     g_tradeSeq=0;
ulong    g_lastRowPosId=0;
datetime g_missingSince=0;
string   g_tradeId="";
double   g_plannedTPMoney=0.0;
int      g_plannedTPPoints=0;
datetime g_lastCloseTry=0;
bool     g_stopsLevelWarned=false;

// telemetry
datetime g_lastHeartbeat=0;
string   g_lastEvent="INIT";
string   g_lastRetcode="";
int      g_lastLatencyMs=0;
string   g_lastReasonText="";
datetime g_lastPanelUpdate=0;
bool     g_panelMinimized=false;
string   g_skipDates[];

void EventLog(string type,string severity,string reason,string detail,long retcode,string retDesc);
bool ClosePositionNow(string reason);

//====================================================================
// SMALL UTILITIES
//====================================================================
string Money(double v) { return DoubleToString(v,2); }

string San(string s)
  {
   StringReplace(s,";",",");
   StringReplace(s,"\r"," ");
   StringReplace(s,"\n"," ");
   return s;
  }

string Bool(bool b) { return b?"true":"false"; }

uint HashFNV1a(string s)
  {
   uint hash=2166136261;
   int n=StringLen(s);
   for(int i=0;i<n;i++)
     {
      hash^=(uint)StringGetCharacter(s,i);
      hash*=16777619;
     }
   return hash;
  }

long CalculateMagic()
  {
   if(InpMagicNumber>0) return InpMagicNumber;
   uint h=HashFNV1a(LD_NAME+"|"+_Symbol+"|"+IntegerToString(InpInstanceID)+"|LD-20261013");
   return (long)(710000000+(h%250000000));
  }

string DirName(int d) { return d>0?"BUY":(d<0?"SELL":"NONE"); }

//====================================================================
// TIME: server -> UTC -> London
//====================================================================
datetime NthSunday(int year,int month,int n)      // n=1.. : n-th Sunday at 00:00 (server/utc naive)
  {
   MqlDateTime d; d.year=year;d.mon=month;d.day=1;d.hour=0;d.min=0;d.sec=0;
   datetime t=StructToTime(d); MqlDateTime w; TimeToStruct(t,w);
   int first=1+((7-w.day_of_week)%7);
   d.day=first+7*(n-1);
   return StructToTime(d);
  }

datetime LastSundayAt(int year,int month,int hour)  // month with 31 days (Mar, Oct)
  {
   MqlDateTime d; d.year=year;d.mon=month;d.day=31;d.hour=0;d.min=0;d.sec=0;
   datetime t=StructToTime(d); MqlDateTime w; TimeToStruct(t,w);
   d.day=31-w.day_of_week; d.hour=hour;
   return StructToTime(d);
  }

bool USDST(datetime serverTime)
  {
   MqlDateTime d; TimeToStruct(serverTime,d);
   datetime start=NthSunday(d.year,3,2);
   datetime end=NthSunday(d.year,11,1);
   return (serverTime>=start && serverTime<end);
  }

bool EUDST(datetime utc)
  {
   MqlDateTime d; TimeToStruct(utc,d);
   datetime start=LastSundayAt(d.year,3,1);
   datetime end=LastSundayAt(d.year,10,1);
   return (utc>=start && utc<end);
  }

datetime ServerToUTC(datetime server)
  {
   if(InpServerRule==LD_RULE_TIMEGMT)
     {
      long off=(long)(TimeTradeServer()-TimeGMT());
      off=(long)(MathRound((double)off/900.0)*900.0);
      return server-(datetime)off;
     }
   return server-(datetime)(USDST(server)?10800:7200);
  }

datetime UTCToLondon(datetime utc) { return utc+(datetime)(EUDST(utc)?3600:0); }

datetime ClockNow(LD_CLOCK c,datetime server)
  {
   datetime utc=ServerToUTC(server);
   if(c==LD_CLOCK_SERVER) return server;
   if(c==LD_CLOCK_UTC) return utc;
   return UTCToLondon(utc);
  }

datetime LondonNow() { return UTCToLondon(ServerToUTC(TimeTradeServer())); }
long     DayKey(datetime server) { return (long)(server/86400); }
datetime DayStart(datetime server) { return (datetime)((server/86400)*86400); }
datetime WeekStart(datetime server)
  {
   MqlDateTime d; TimeToStruct(server,d);
   int back=(d.day_of_week+6)%7;             // Monday = 0
   return DayStart(server)-(datetime)back*86400;
  }

string TimeStr(datetime t) { return TimeToString(t,TIME_DATE|TIME_SECONDS); }

//====================================================================
// CSV
//====================================================================
string MonthTag() { MqlDateTime d; TimeToStruct(TimeTradeServer(),d); return StringFormat("%04d-%02d",d.year,d.mon); }
string EventsFile()    { return LD_FOLDER+LD_NAME+"_events_"+MonthTag()+".csv"; }
string TradesFile()    { return LD_FOLDER+LD_NAME+"_trades_"+MonthTag()+".csv"; }
string DailyFile()     { return LD_FOLDER+LD_NAME+"_daily_"+MonthTag()+".csv"; }
string DecisionsFile() { return LD_FOLDER+LD_NAME+"_decisions_"+MonthTag()+".csv"; }

string Pre() { return LD_SCHEMA+";"+LD_VERSION+";"+g_runId+";"; }

string EventsHeader()
  {
   return "schema_version;ea_version;run_id;timestamp_server;timestamp_utc;london_time;symbol;magic;event_id;event_type;severity;state;direction;reason_code;reason_detail;bid;ask;spread_points;balance;equity;free_margin;daily_pnl;week_pnl;position_volume;position_price;position_sl;position_tp;position_profit;max_profit;trail_active;trail_stop;retcode;retcode_description;latency_ms";
  }
string TradesHeader()
  {
   return "schema_version;ea_version;run_id;trade_id;symbol;magic;direction;entry_time_server;entry_time_london;exit_time_server;duration_sec;volume;entry_price;exit_price;initial_sl;initial_tp;final_sl;final_tp;gross_profit;commission;swap;net_profit;money_per_point_lot;planned_tp_money;planned_tp_points;mfe_money;mae_money;mfe_points;mae_points;trail_activated;exit_reason;entry_spread_points;day_of_week";
  }
string DailyHeader()
  {
   return "schema_version;ea_version;run_id;date_server;symbol;magic;start_balance;end_balance;net_profit;trades;decision;reason;exit_reason;max_adverse_money;daily_target;daily_loss_limit;week_pnl;cb_state;paused";
  }
string DecisionsHeader()
  {
   return "schema_version;ea_version;run_id;decision_id;timestamp_server;london_time;symbol;magic;direction;decision;reason_code;reason_detail;bid;ask;spread_points;volume;tp_money;order_sent;trade_id";
  }

void CsvAppend(string file,string header,string line)
  {
   if(!InpWriteCSV) return;
   FolderCreate(LD_FOLDER);
   int h=FileOpen(file,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(h==INVALID_HANDLE) { if(InpPrintToExperts) Print(LD_NAME,": cannot open ",file," err=",GetLastError()); return; }
   if(FileSize(h)==0) FileWriteString(h,header+"\r\n");
   FileSeek(h,0,SEEK_END);
   FileWriteString(h,line+"\r\n");
   FileClose(h);
  }

//====================================================================
// MONEY / VOLUME HELPERS
//====================================================================
double NormalizeVolume(double volume)
  {
   double minv=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxv=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step<=0.0) step=minv;
   volume=MathMin(volume,maxv);
   double v=MathFloor(volume/step+1e-10)*step;
   if(v<minv) return 0.0;
   int digits=0; double s=step;
   while(digits<8 && MathAbs(s-MathRound(s))>1e-8) { s*=10.0; digits++; }
   return NormalizeDouble(v,digits);
  }

bool CalcProfitForMove(int direction,double volume,double fromPrice,double toPrice,double &profit)
  {
   ENUM_ORDER_TYPE type=(direction>0?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
   ResetLastError();
   return OrderCalcProfit(type,_Symbol,volume,fromPrice,toPrice,profit);
  }

double MoneyForPriceDistance(int direction,double volume,double fromPrice,double distance)
  {
   if(distance<=0.0 || volume<=0.0) return 0.0;
   double to=(direction>0?fromPrice+distance:fromPrice-distance);
   double p=0.0;
   if(!CalcProfitForMove(direction,volume,fromPrice,to,p)) return 0.0;
   return MathAbs(p);
  }

bool PriceDistanceForMoney(int direction,double volume,double fromPrice,double money,double &distance)
  {
   distance=0.0;
   if(money<=0.0 || volume<=0.0 || fromPrice<=0.0) return false;
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick<=0.0) tick=_Point;
   double lo=0.0,hi=tick*10.0;
   for(int i=0;i<60;i++)
     {
      if(MoneyForPriceDistance(direction,volume,fromPrice,hi)>=money) break;
      hi*=2.0;
      if(hi>fromPrice*0.5) break;
     }
   if(MoneyForPriceDistance(direction,volume,fromPrice,hi)<money) return false;
   for(int i=0;i<60;i++)
     {
      double mid=0.5*(lo+hi);
      if(MoneyForPriceDistance(direction,volume,fromPrice,mid)>=money) hi=mid; else lo=mid;
     }
   distance=hi;
   return true;
  }

double MoneyPerPointPerLot(int direction,double refPrice)
  {
   if(refPrice<=0.0) refPrice=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double p=0.0;
   double to=(direction>0?refPrice+_Point*100.0:refPrice-_Point*100.0);
   if(!CalcProfitForMove(direction,1.0,refPrice,to,p)) return 0.0;
   return MathAbs(p)/100.0;
  }

double SpreadPoints()
  {
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID),ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   if(bid<=0.0 || ask<=0.0) return 0.0;
   return (ask-bid)/_Point;
  }

//====================================================================
// ACCOUNTING (closed deals of this EA)
//====================================================================
double ClosedPnL(datetime from,datetime to,int &count)
  {
   count=0;
   if(!HistorySelect(from,to)) return 0.0;
   double sum=0.0;
   int n=HistoryDealsTotal();
   for(int i=0;i<n;i++)
     {
      ulong t=HistoryDealGetTicket(i);
      if(t==0) continue;
      if((long)HistoryDealGetInteger(t,DEAL_MAGIC)!=g_magic) continue;
      if(HistoryDealGetString(t,DEAL_SYMBOL)!=_Symbol) continue;
      long entry=HistoryDealGetInteger(t,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT && entry!=DEAL_ENTRY_OUT_BY) continue;
      sum+=HistoryDealGetDouble(t,DEAL_PROFIT)+HistoryDealGetDouble(t,DEAL_SWAP)+HistoryDealGetDouble(t,DEAL_COMMISSION)+HistoryDealGetDouble(t,DEAL_FEE);
      count++;
     }
   return sum;
  }

double FloatingPnL()
  {
   if(!g_hasPos) return 0.0;
   if(!PositionSelectByTicket(g_posTicket)) return 0.0;
   return PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
  }

double DayPnL()   { int c; datetime s=DayStart(TimeTradeServer()); return ClosedPnL(s,s+86400-1,c)+FloatingPnL(); }
double WeekPnL()  { int c; datetime s=WeekStart(TimeTradeServer()); return ClosedPnL(s,TimeTradeServer()+60,c)+FloatingPnL(); }
int    TradesToday(){ int c; datetime s=DayStart(TimeTradeServer()); ClosedPnL(s,s+86400-1,c); if(g_hasPos && g_posOpenTime>=s) c++; return c; }

// Circuit breaker evaluation over the closed trades after g_cbResetTime
void EvaluateCircuitBreaker()
  {
   g_cbState="OK";
   datetime now=TimeTradeServer();
   if(!InpUseCircuitBreaker) { g_cbState="OFF"; return; }
   if(g_cbPauseUntil>now) { g_cbState="PAUSED until "+TimeToString(g_cbPauseUntil,TIME_DATE); return; }
   datetime from=(g_cbResetTime>0?g_cbResetTime:now-(datetime)180*86400);
   if(!HistorySelect(from,now+60)) return;
   int n=HistoryDealsTotal();
   // per-day sums (server day) in chronological order
   long keys[]; double sums[]; int nk=0;
   double cum=0.0,peak=0.0,dd=0.0;
   for(int i=0;i<n;i++)
     {
      ulong t=HistoryDealGetTicket(i);
      if(t==0) continue;
      if((long)HistoryDealGetInteger(t,DEAL_MAGIC)!=g_magic) continue;
      if(HistoryDealGetString(t,DEAL_SYMBOL)!=_Symbol) continue;
      long entry=HistoryDealGetInteger(t,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT && entry!=DEAL_ENTRY_OUT_BY) continue;
      double v=HistoryDealGetDouble(t,DEAL_PROFIT)+HistoryDealGetDouble(t,DEAL_SWAP)+HistoryDealGetDouble(t,DEAL_COMMISSION)+HistoryDealGetDouble(t,DEAL_FEE);
      long k=DayKey((datetime)HistoryDealGetInteger(t,DEAL_TIME));
      if(nk==0 || keys[nk-1]!=k) { ArrayResize(keys,nk+1); ArrayResize(sums,nk+1); keys[nk]=k; sums[nk]=0.0; nk++; }
      sums[nk-1]+=v;
      cum+=v; peak=MathMax(peak,cum); dd=MathMax(dd,peak-cum);
     }
   int consec=0;
   for(int i=nk-1;i>=0;i--) { if(sums[i]<0.0) consec++; else break; }
   bool trig=false; string why="";
   if(InpCBConsecutiveLossDays>0 && consec>=InpCBConsecutiveLossDays) { trig=true; why=StringFormat("CONSECUTIVE_LOSS_DAYS=%d",consec); }
   if(!trig && InpCBUseDrawdown && InpCBDrawdownMoney>0.0 && dd>=InpCBDrawdownMoney) { trig=true; why=StringFormat("DRAWDOWN=%.2f",dd); }
   if(trig)
     {
      g_cbResetTime=now;
      g_cbPauseUntil=DayStart(now)+(datetime)(MathMax(1,InpCBPauseDays)+1)*86400;
      GlobalVariableSet(LD_NAME+"_"+IntegerToString(g_magic)+"_CB_UNTIL",(double)g_cbPauseUntil);
      GlobalVariableSet(LD_NAME+"_"+IntegerToString(g_magic)+"_CB_RESET",(double)g_cbResetTime);
      g_cbState="PAUSED until "+TimeToString(g_cbPauseUntil,TIME_DATE);
      EventLog("RISK","WARNING","CIRCUIT_BREAKER",why,0,"");
     }
  }

//====================================================================
// EVENT LOG
//====================================================================
void EventLog(string type,string severity,string reason,string detail,long retcode,string retDesc)
  {
   g_eventSeq++;
   g_lastEvent=type+(reason!=""?" "+reason:"");
   datetime srv=TimeTradeServer();
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID),ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double posProfit=g_hasPos?FloatingPnL():0.0;
   double sl=0,tp=0,price=0;
   if(g_hasPos && PositionSelectByTicket(g_posTicket)) { sl=PositionGetDouble(POSITION_SL); tp=PositionGetDouble(POSITION_TP); price=PositionGetDouble(POSITION_PRICE_OPEN); }
   string state=g_hasPos?"IN_POSITION":(g_paused?"PAUSED":g_dayDecision);
   string line=Pre()+TimeStr(srv)+";"+TimeStr(ServerToUTC(srv))+";"+TimeStr(UTCToLondon(ServerToUTC(srv)))+";"+_Symbol+";"+IntegerToString(g_magic)+";"+
               IntegerToString(g_eventSeq)+";"+type+";"+severity+";"+state+";"+DirName(InpDirection==LD_SELL?-1:1)+";"+reason+";"+San(detail)+";"+
               DoubleToString(bid,_Digits)+";"+DoubleToString(ask,_Digits)+";"+DoubleToString(SpreadPoints(),1)+";"+
               DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+";"+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+";"+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2)+";"+
               DoubleToString(DayPnL(),2)+";"+DoubleToString(WeekPnL(),2)+";"+DoubleToString(g_posVolume,2)+";"+DoubleToString(price,_Digits)+";"+DoubleToString(sl,_Digits)+";"+DoubleToString(tp,_Digits)+";"+
               DoubleToString(posProfit,2)+";"+DoubleToString(g_maxProfit,2)+";"+Bool(g_trailActive)+";"+DoubleToString(g_trailStop,_Digits)+";"+
               IntegerToString(retcode)+";"+San(retDesc)+";"+IntegerToString(g_lastLatencyMs);
   CsvAppend(EventsFile(),EventsHeader(),line);
   if(InpPrintToExperts && (severity!="INFO" || InpDebug || type=="POSITION_OPEN" || type=="POSITION_CLOSE" || type=="INIT" || type=="DECISION"))
      Print(LD_NAME," ",type," ",severity," ",reason," ",detail);
  }

void DecisionLog(string decision,string reason,string detail,double volume,double tpMoney,bool orderSent,string tradeId)
  {
   datetime srv=TimeTradeServer();
   string id=StringFormat("D%s_%s",TimeToString(srv,TIME_DATE),IntegerToString((long)g_magic));
   string line=Pre()+id+";"+TimeStr(srv)+";"+TimeStr(UTCToLondon(ServerToUTC(srv)))+";"+_Symbol+";"+IntegerToString(g_magic)+";"+DirName(InpDirection==LD_SELL?-1:1)+";"+
               decision+";"+reason+";"+San(detail)+";"+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits)+";"+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits)+";"+
               DoubleToString(SpreadPoints(),1)+";"+DoubleToString(volume,2)+";"+DoubleToString(tpMoney,2)+";"+Bool(orderSent)+";"+tradeId;
   CsvAppend(DecisionsFile(),DecisionsHeader(),line);
   EventLog("DECISION","INFO",decision+":"+reason,detail,0,"");
  }

//====================================================================
// POSITION BOOKKEEPING
//====================================================================
bool SelectOurPosition()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC)!=g_magic) continue;
      g_posTicket=ticket;
      return true;
     }
   return false;
  }

bool TradeOk()
  {
   uint rc=g_trade.ResultRetcode();
   return (rc==TRADE_RETCODE_DONE || rc==TRADE_RETCODE_DONE_PARTIAL || rc==TRADE_RETCODE_PLACED || rc==TRADE_RETCODE_NO_CHANGES);
  }

void ResetPositionState()
  {
   g_hasPos=false; g_posTicket=0; g_posId=0; g_posDir=0; g_posVolume=0; g_posEntry=0; g_posOpenTime=0;
   g_maxProfit=0; g_minProfit=0; g_mfePts=0; g_maePts=0; g_hwm=0; g_trailActive=false; g_trailStop=0; g_trailDistMoney=0; g_lockedMoney=0;
   g_posSL0=0; g_posTP0=0; g_pendingExit=""; g_stopsLevelWarned=false;
  }

void AdoptPosition()
  {
   if(!SelectOurPosition()) { return; }
   g_hasPos=true;
   g_posId=(ulong)PositionGetInteger(POSITION_IDENTIFIER);
   g_posDir=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY?1:-1);
   g_posVolume=PositionGetDouble(POSITION_VOLUME);
   g_posEntry=PositionGetDouble(POSITION_PRICE_OPEN);
   g_posOpenTime=(datetime)PositionGetInteger(POSITION_TIME);
   g_posSL0=PositionGetDouble(POSITION_SL);
   g_posTP0=PositionGetDouble(POSITION_TP);
   double sl=PositionGetDouble(POSITION_SL);
   // an SL on the profit side of the entry can only be our trailing stop
   if(sl>0.0 && ((g_posDir<0 && sl<g_posEntry) || (g_posDir>0 && sl>g_posEntry))) { g_trailActive=true; g_trailStop=sl; }
   if(g_hwm<=0.0) g_hwm=(g_posDir>0?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   double p=PositionGetDouble(POSITION_PROFIT);
   g_maxProfit=MathMax(g_maxProfit,p); g_minProfit=MathMin(g_minProfit,p);
   if(g_tradeId=="") { g_tradeSeq++; g_tradeId=StringFormat("T%I64d_%s",g_magic,TimeToString(g_posOpenTime,TIME_DATE|TIME_MINUTES)); }
  }

//====================================================================
// ORDERS
//====================================================================
bool ClosePositionNow(string reason)
  {
   if(!SelectOurPosition()) return false;
   datetime now=TimeTradeServer();
   if(g_lastCloseTry==now) return false;           // at most one attempt per second
   g_lastCloseTry=now;
   g_pendingExit=reason;
   for(int a=0;a<MathMax(1,InpMaxRetries);a++)
     {
      ResetLastError();
      ulong t0=GetTickCount64();
      bool ok=g_trade.PositionClose(g_posTicket,(ulong)InpDeviationPoints);
      g_lastLatencyMs=(int)(GetTickCount64()-t0);
      if(ok && TradeOk()) { EventLog("POSITION_CLOSE_REQUESTED","INFO",reason,"close accepted",g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription()); return true; }
      EventLog("ORDER_REJECTED","ERROR","CLOSE_FAILED",StringFormat("attempt=%d reason=%s err=%d",a+1,reason,GetLastError()),g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription());
      if(!SelectOurPosition()) return true;
      Sleep(InpRetryDelayMs);
     }
   g_pendingExit="";
   return false;
  }

bool ModifyStops(double sl,double tp)
  {
   if(!SelectOurPosition()) return false;
   ResetLastError();
   bool ok=g_trade.PositionModify(g_posTicket,sl,tp);
   if(!ok || !TradeOk())
     {
      EventLog("ORDER_REJECTED","WARNING","MODIFY_FAILED",StringFormat("sl=%.2f tp=%.2f err=%d",sl,tp,GetLastError()),g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription());
      return false;
     }
   return true;
  }

double TPMoneyPlanned(double volume,double refPrice)
  {
   if(InpTPMode==LD_TP_MONEY) return InpTakeProfitMoney;
   return MoneyForPriceDistance(-1,volume,refPrice,InpTakeProfitPoints*_Point);
  }

double ChooseLot(double refPrice,string &detail)
  {
   double lot=InpLotFixed;
   detail="fixed";
   if(InpLotMode==LD_LOT_BY_TARGET)
     {
      double mpp=MoneyPerPointPerLot(-1,refPrice);                  // money per point per 1.0 lot
      double target=(InpTPMode==LD_TP_MONEY?InpTakeProfitMoney:0.0);
      if(InpTPMode==LD_TP_POINTS) { detail="BY_TARGET needs TPMode=MONEY"; return 0.0; }
      if(mpp<=0.0 || InpLotTargetPoints<=0 || target<=0.0) { detail="BY_TARGET invalid inputs"; return 0.0; }
      lot=target/(mpp*InpLotTargetPoints);
      detail=StringFormat("by_target money=%.2f points=%d money_per_point_lot=%.4f",target,InpLotTargetPoints,mpp);
     }
   lot=MathMin(lot,InpLotMax);
   return NormalizeVolume(lot);
  }

//====================================================================
// ENTRY GATES
//====================================================================
bool IsSkipDate(datetime london)
  {
   string d=TimeToString(london,TIME_DATE);
   for(int i=0;i<ArraySize(g_skipDates);i++) if(g_skipDates[i]==d) return true;
   return false;
  }

bool WeekdayAllowed(datetime t)
  {
   MqlDateTime d; TimeToStruct(t,d);
   switch(d.day_of_week)
     {
      case 1: return InpTradeMonday;
      case 2: return InpTradeTuesday;
      case 3: return InpTradeWednesday;
      case 4: return InpTradeThursday;
      case 5: return InpTradeFriday;
     }
   return false;
  }

bool NewsBlock(datetime server,string &detail)
  {
   detail="";
   if(!InpUseNewsFilter) return false;
   MqlCalendarValue v[];
   ResetLastError();
   int n=CalendarValueHistory(v,server-(datetime)InpNewsMinutesBefore*60,server+(datetime)InpNewsMinutesAfter*60,NULL,InpNewsCurrency);
   if(n<0)
     {
      detail="calendar unavailable err="+IntegerToString(GetLastError());
      EventLog("WARNING","WARNING","NEWS_CALENDAR_UNAVAILABLE",detail,0,"");
      return InpNewsBlockOnError;
     }
   for(int i=0;i<n;i++)
     {
      MqlCalendarEvent ev;
      if(!CalendarEventById(v[i].event_id,ev)) continue;
      if((int)ev.importance>=InpNewsMinImportance)
        {
         detail=StringFormat("%s at %s importance=%d",ev.name,TimeToString(v[i].time,TIME_DATE|TIME_MINUTES),(int)ev.importance);
         return true;
        }
     }
   return false;
  }

// returns "" when the entry is allowed
string EntryBlockReason(datetime server,double volume,string &detail)
  {
   detail="";
   datetime london=UTCToLondon(ServerToUTC(server));
   if(!InpEnableTrading) return "TRADING_DISABLED_INPUT";
   if(g_paused) return "PAUSED_MANUAL";
   if(GlobalVariableCheck(LD_NAME+"_"+IntegerToString(g_magic)+"_KILL") && GlobalVariableGet(LD_NAME+"_"+IntegerToString(g_magic)+"_KILL")>0.5) return "KILL_SWITCH";
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return "ALGO_TRADING_DISABLED_TERMINAL";
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return "ALGO_TRADING_DISABLED_EA";
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) || !AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) return "ACCOUNT_TRADING_NOT_ALLOWED";
   if(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL) return "SYMBOL_TRADE_MODE";
   if(!WeekdayAllowed(london)) return "WEEKDAY_NOT_ALLOWED";
   if(IsSkipDate(london)) return "SKIP_DATE";
   if(g_hasPos) return "POSITION_ALREADY_OPEN";
   if(TradesToday()>=InpMaxTradesPerDay) return "MAX_TRADES_PER_DAY";
   if(InpUseCircuitBreaker)
     {
      EvaluateCircuitBreaker();
      if(g_cbPauseUntil>server) { detail=g_cbState; return "CIRCUIT_BREAKER"; }
     }
   if(InpUseWeeklyLossLimit && WeekPnL()<=-MathAbs(InpWeeklyLossLimitMoney)) { detail=StringFormat("week=%.2f",WeekPnL()); return "WEEKLY_LOSS_LIMIT"; }
   if(InpUseDailyLossLimit && DayPnL()<=-MathAbs(InpDailyLossLimitMoney)) { detail=StringFormat("day=%.2f",DayPnL()); return "DAILY_LOSS_LIMIT"; }
   if(InpUseDailyTarget)
     {
      int c; datetime s=DayStart(server);
      double closed=ClosedPnL(s,s+86400-1,c);
      if(closed>=InpDailyTargetMoney) { detail=StringFormat("day=%.2f",closed); return "DAILY_TARGET_REACHED"; }
     }
   if(InpUseEndOfDayExit && InpUseNoEntryBeforeExit)
     {
      MqlDateTime d; TimeToStruct(server,d);
      int nowMin=d.hour*60+d.min, exitMin=InpExitHourServer*60+InpExitMinuteServer;
      if(nowMin>=exitMin-InpNoEntryMinutesBeforeExit) { detail=StringFormat("server %02d:%02d exit %02d:%02d",d.hour,d.min,InpExitHourServer,InpExitMinuteServer); return "TOO_CLOSE_TO_EXIT"; }
     }
   if(InpUseSpreadFilter && SpreadPoints()>InpMaxSpreadPoints) { detail=StringFormat("spread=%.1f max=%.1f",SpreadPoints(),InpMaxSpreadPoints); return "SPREAD_HIGH"; }
   if(InpUseTickAgeFilter)
     {
      long age=(long)(server-(datetime)SymbolInfoInteger(_Symbol,SYMBOL_TIME));
      if(age>InpMaxTickAgeSeconds) { detail=StringFormat("tick_age=%d",(int)age); return "TICK_STALE"; }
     }
   if(volume<=0.0) { detail="volume=0"; return "VOLUME_INVALID"; }
   // margin
   ENUM_ORDER_TYPE type=(InpDirection==LD_SELL?ORDER_TYPE_SELL:ORDER_TYPE_BUY);
   double price=(InpDirection==LD_SELL?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   double margin=0.0;
   if(!OrderCalcMargin(type,_Symbol,volume,price,margin)) { detail="margin calc failed"; return "MARGIN_CALC_FAILED"; }
   double freeM=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(margin>freeM*(1.0-InpMinFreeMarginAfterPct/100.0)) { detail=StringFormat("margin=%.2f free=%.2f",margin,freeM); return "NO_MARGIN"; }
   string nd;
   if(NewsBlock(server,nd)) { detail=nd; return "NEWS_NEAR"; }
   return "";
  }

//====================================================================
// ENTRY
//====================================================================
bool SendEntry(double volume,string &failReason)
  {
   failReason="";
   int dir=(InpDirection==LD_SELL?-1:1);
   double refPrice=(dir<0?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   // protective levels computed from the expected entry price
   double sl=0.0,tp=0.0;
   double slMoney=0.0;
   if(InpUseStopLoss) slMoney=InpStopLossMoney;
   if(InpUseDisasterStop && InpDisasterStopMoney>0.0) slMoney=(slMoney>0.0?MathMin(slMoney,InpDisasterStopMoney):InpDisasterStopMoney);
   double dist=0.0;
   if(slMoney>0.0 && PriceDistanceForMoney(dir,volume,refPrice,slMoney,dist)) sl=NormalizeDouble(dir<0?refPrice+dist:refPrice-dist,_Digits);
   g_plannedTPMoney=TPMoneyPlanned(volume,refPrice);
   if(InpUseTakeProfit && g_plannedTPMoney>0.0 && PriceDistanceForMoney(dir,volume,refPrice,g_plannedTPMoney,dist))
     {
      tp=NormalizeDouble(dir<0?refPrice-dist:refPrice+dist,_Digits);
      g_plannedTPPoints=(int)MathRound(dist/_Point);
     }
   g_trade.SetExpertMagicNumber((ulong)g_magic);
   g_trade.SetDeviationInPoints((ulong)InpDeviationPoints);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   bool ok=false;
   for(int a=0;a<MathMax(1,InpMaxRetries);a++)
     {
      ResetLastError();
      ulong t0=GetTickCount64();
      if(dir<0) ok=g_trade.Sell(volume,_Symbol,0.0,sl,tp,InpOrderComment);
      else      ok=g_trade.Buy(volume,_Symbol,0.0,sl,tp,InpOrderComment);
      g_lastLatencyMs=(int)(GetTickCount64()-t0);
      g_lastRetcode=IntegerToString(g_trade.ResultRetcode());
      EventLog("ORDER_SEND",(ok&&TradeOk())?"INFO":"ERROR","ATTEMPT_"+IntegerToString(a+1),
               StringFormat("dir=%s vol=%.2f ref=%.2f sl=%.2f tp=%.2f",DirName(dir),volume,refPrice,sl,tp),g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription());
      if(ok && TradeOk()) break;
      ok=false;
      uint rc=g_trade.ResultRetcode();
      bool retryable=(rc==TRADE_RETCODE_REQUOTE || rc==TRADE_RETCODE_PRICE_CHANGED || rc==TRADE_RETCODE_PRICE_OFF || rc==TRADE_RETCODE_TIMEOUT || rc==TRADE_RETCODE_CONNECTION);
      if(!retryable) break;
      Sleep(InpRetryDelayMs);
     }
   if(!ok) { failReason="ORDER_REJECTED_"+IntegerToString(g_trade.ResultRetcode()); return false; }
   return true;
  }

void AfterFillSetup(double volume)
  {
   ResetPositionState();
   if(!SelectOurPosition()) { EventLog("ERROR","ERROR","POSITION_NOT_FOUND_AFTER_FILL","order accepted but position not visible",0,""); return; }
   AdoptPosition();
   g_tradeId=StringFormat("T%I64d_%s",g_magic,TimeToString(g_posOpenTime,TIME_DATE|TIME_MINUTES));
   g_entrySpread=SpreadPoints();
   g_tradesToday++;
   // make the planned TP exact from the real fill price
   if(InpUseTakeProfit && g_plannedTPMoney>0.0)
     {
      double dist=0.0;
      if(PriceDistanceForMoney(g_posDir,g_posVolume,g_posEntry,g_plannedTPMoney,dist))
        {
         double tp=NormalizeDouble(g_posDir<0?g_posEntry-dist:g_posEntry+dist,_Digits);
         double curTp=PositionGetDouble(POSITION_TP);
         if(MathAbs(tp-curTp)>=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)) { if(ModifyStops(PositionGetDouble(POSITION_SL),tp)) g_posTP0=tp; }
         g_plannedTPPoints=(int)MathRound(dist/_Point);
        }
     }
   g_dayDecided=true; g_dayDecision="ENTERED"; g_dayReason="";
   EventLog("POSITION_OPEN","INFO","ENTRY",StringFormat("dir=%s vol=%.2f price=%.2f tp=%.2f tp_money=%.2f tp_points=%d",DirName(g_posDir),g_posVolume,g_posEntry,g_posTP0,g_plannedTPMoney,g_plannedTPPoints),g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription());
  }

void EvaluateEntry()
  {
   if(g_hasPos || g_dayDecided) return;
   datetime server=TimeTradeServer();
   datetime clk=ClockNow(InpEntryClock,server);
   // The entry time lives on the chosen clock (e.g. London) but the trading day rolls on the SERVER clock.
   // Convert the entry time to a server time-of-day using the current clock offset, then compare on the
   // server clock. (Comparing on the chosen clock wrongly marked every day as "window missed" right after
   // the server midnight, when London is still at 22:00/23:00 of the previous date.)
   long offsetSec=(long)clk-(long)server;                       // clock minus server, seconds
   int entrySod=InpEntryHour*3600+InpEntryMinute*60;
   int entryServerSod=(int)((((long)entrySod-offsetSec)%86400+86400)%86400);
   int sod=(int)(server%86400);
   if(sod<entryServerSod) { g_dayDecision="WAITING"; return; }
   if(sod>entryServerSod+InpEntryWindowSeconds)
     {
      // window passed without an entry
      string r=(g_lastBlockReason!=""?g_lastBlockReason:"MISSED_WINDOW");
      g_dayDecided=true; g_dayDecision="SKIPPED"; g_dayReason=r;
      DecisionLog("SKIP",r,"entry window closed",0,0,false,"");
      return;
     }
   if(!WeekdayAllowed(UTCToLondon(ServerToUTC(server))))   // non-trading weekday: decide once, silently
     {
      g_dayDecided=true; g_dayDecision="SKIPPED"; g_dayReason="WEEKDAY_NOT_ALLOWED";
      DecisionLog("SKIP","WEEKDAY_NOT_ALLOWED","",0,0,false,"");
      return;
     }
   double refPrice=(InpDirection==LD_SELL?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   string ldetail; double volume=ChooseLot(refPrice,ldetail);
   string detail;
   string reason=EntryBlockReason(server,volume,detail);
   if(reason!="")
     {
      g_lastBlockReason=reason; g_dayReason=reason; g_dayDecision="BLOCKED";
      if(reason!=g_lastBlockLogged) { g_lastBlockLogged=reason; EventLog("BLOCK","INFO",reason,detail,0,""); }
      // permanent blocks end the day immediately
      if(reason=="WEEKDAY_NOT_ALLOWED" || reason=="SKIP_DATE" || reason=="MAX_TRADES_PER_DAY" || reason=="DAILY_TARGET_REACHED" || reason=="DAILY_LOSS_LIMIT" || reason=="WEEKLY_LOSS_LIMIT" || reason=="CIRCUIT_BREAKER" || reason=="TRADING_DISABLED_INPUT" || reason=="KILL_SWITCH" || reason=="TOO_CLOSE_TO_EXIT" || reason=="NEWS_NEAR")
        { g_dayDecided=true; g_dayDecision="SKIPPED"; DecisionLog("SKIP",reason,detail,volume,0,false,""); }
      return;
     }
   string fail;
   if(!SendEntry(volume,fail))
     {
      g_lastBlockReason=fail; g_dayReason=fail; g_dayDecision="BLOCKED";
      if(fail!=g_lastBlockLogged) { g_lastBlockLogged=fail; EventLog("BLOCK","ERROR",fail,"order not accepted",g_trade.ResultRetcode(),g_trade.ResultRetcodeDescription()); }
      return;
     }
   AfterFillSetup(volume);
   DecisionLog("ENTER","ENTRY_WINDOW",ldetail,g_posVolume,g_plannedTPMoney,true,g_tradeId);
  }

//====================================================================
// TRAILING (PieceTrend rule: D = ratio*A*(max/A)^exp, in money)
//====================================================================
double TrailActivationMoney()
  {
   if(!InpTrailActivationInPoints) return InpTrailActivationMoney;
   double mpp=MoneyPerPointPerLot(g_posDir,g_posEntry);
   return InpTrailActivationPoints*mpp*g_posVolume;
  }

void ApplyTrailing()
  {
   if(!g_hasPos || !InpUseTrailing) return;
   if(!PositionSelectByTicket(g_posTicket)) return;
   double profit=PositionGetDouble(POSITION_PROFIT);
   double price=(g_posDir>0?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));   // price at which the position would close
   if(price<=0.0) return;
   if(g_hwm<=0.0) g_hwm=price;
   if(g_posDir>0) g_hwm=MathMax(g_hwm,price); else g_hwm=MathMin(g_hwm,price);
   if(profit>g_maxProfit) g_maxProfit=profit;
   if(profit<g_minProfit) g_minProfit=profit;
   double A=TrailActivationMoney();
   if(A<=0.0 || g_maxProfit<A) return;
   if(!g_trailActive)
     {
      g_trailActive=true;
      if(InpTPRemovedOnTrail && PositionGetDouble(POSITION_TP)>0.0 && InpTrailOnServer)
        { if(ModifyStops(PositionGetDouble(POSITION_SL),0.0)) EventLog("POSITION_MODIFY","INFO","TP_REMOVED","trail active: TP becomes runner",0,""); }
      EventLog("RISK","INFO","TRAIL_ACTIVATED",StringFormat("max_profit=%.2f activation=%.2f",g_maxProfit,A),0,"");
     }
   double D=InpTrailRatio*A*MathPow(MathMax(g_maxProfit/A,1.0),InpTrailExponent);
   g_trailDistMoney=D;
   double distPrice=0.0;
   if(!PriceDistanceForMoney(g_posDir,g_posVolume,g_hwm,D,distPrice)) return;
   double cand=NormalizeDouble(g_posDir>0?g_hwm-distPrice:g_hwm+distPrice,_Digits);
   double stepPrice=InpTrailMinStepPoints*_Point;
   double existing=(InpTrailOnServer?PositionGetDouble(POSITION_SL):g_trailStop);
   bool better=(existing<=0.0) || (g_posDir>0?cand>existing+stepPrice:cand<existing-stepPrice);
   if(!better) return;
   if(InpTrailOnServer)
     {
      // respect the broker minimum distance
      double lvl=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
      double ref=(g_posDir>0?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
      bool distOk=(g_posDir>0?(ref-cand)>=lvl:(cand-ref)>=lvl);
      if(!distOk) { if(!g_stopsLevelWarned) { g_stopsLevelWarned=true; EventLog("WARNING","WARNING","TRAIL_STOPS_LEVEL","trail stop too close to price; waiting",0,""); } return; }
      if(ModifyStops(cand,PositionGetDouble(POSITION_TP)))
        {
         g_trailStop=cand;
         double d=MathAbs(cand-g_posEntry);
         g_lockedMoney=MoneyForPriceDistance(g_posDir,g_posVolume,g_posEntry,d)*(((g_posDir<0 && cand<g_posEntry) || (g_posDir>0 && cand>g_posEntry))?1.0:-1.0);
         EventLog("POSITION_MODIFY","INFO","TRAIL_MOVED",StringFormat("stop=%.2f dist_money=%.2f locked=%.2f",cand,D,g_lockedMoney),0,"");
        }
     }
   else
     {
      g_trailStop=cand;
      EventLog("POSITION_MODIFY","INFO","TRAIL_VIRTUAL_MOVED",StringFormat("stop=%.2f dist_money=%.2f",cand,D),0,"");
     }
  }

void CheckVirtualTrail()
  {
   if(!g_hasPos || !InpUseTrailing || InpTrailOnServer || !g_trailActive || g_trailStop<=0.0) return;
   double price=(g_posDir>0?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   bool hit=(g_posDir>0?price<=g_trailStop:price>=g_trailStop);
   if(hit) ClosePositionNow("TRAIL");
  }

//====================================================================
// POSITION MANAGEMENT (time exits, emergency, limits)
//====================================================================
void ManagePosition()
  {
   if(!g_hasPos) return;
   if(!SelectOurPosition()) return;
   datetime server=TimeTradeServer();
   double profit=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
   double price=(g_posDir>0?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   if(g_posDir<0) { g_mfePts=MathMax(g_mfePts,(g_posEntry-price)/_Point); g_maePts=MathMax(g_maePts,(price-g_posEntry)/_Point); }
   else           { g_mfePts=MathMax(g_mfePts,(price-g_posEntry)/_Point); g_maePts=MathMax(g_maePts,(g_posEntry-price)/_Point); }
   g_dayMaxAdverse=MathMax(g_dayMaxAdverse,-g_minProfit);
   // 1) emergency (floating loss in money)
   if(InpUseEmergencyClose && InpEmergencyLossMoney>0.0 && profit<=-MathAbs(InpEmergencyLossMoney))
     { EventLog("RISK","WARNING","EMERGENCY_CLOSE",StringFormat("profit=%.2f limit=%.2f",profit,InpEmergencyLossMoney),0,""); ClosePositionNow("EMERGENCY"); return; }
   // 2) daily loss limit closing the position (optional)
   if(InpUseDailyLossLimit && InpDailyLossClosePosition && DayPnL()<=-MathAbs(InpDailyLossLimitMoney))
     { EventLog("RISK","WARNING","DAILY_LOSS_CLOSE",StringFormat("day=%.2f",DayPnL()),0,""); ClosePositionNow("DAILY_LOSS"); return; }
   // 3) kill switch with open position
   if(GlobalVariableCheck(LD_NAME+"_"+IntegerToString(g_magic)+"_KILL") && GlobalVariableGet(LD_NAME+"_"+IntegerToString(g_magic)+"_KILL")>1.5)
     { ClosePositionNow("KILL_SWITCH"); return; }
   // 4) max hold
   if(InpUseMaxHold && InpMaxHoldMinutes>0 && (server-g_posOpenTime)>=(datetime)InpMaxHoldMinutes*60)
     { ClosePositionNow("TIME_EXIT"); return; }
   // 5) end-of-day exit (server clock)
   if(InpUseEndOfDayExit)
     {
      MqlDateTime d; TimeToStruct(server,d);
      int nowMin=d.hour*60+d.min, exitMin=InpExitHourServer*60+InpExitMinuteServer;
      bool openedToday=(DayKey(g_posOpenTime)==DayKey(server));
      if(nowMin>=exitMin || !openedToday)          // also closes anything left from a previous day
        { ClosePositionNow("TIME_EXIT"); return; }
     }
   CheckVirtualTrail();
  }

//====================================================================
// TRADE TRANSACTIONS: write the trade row when the position closes
//====================================================================
void WriteTradeRow(ulong dealTicket)
  {
   ulong posId=(ulong)HistoryDealGetInteger(dealTicket,DEAL_POSITION_ID);
   if(posId==g_lastRowPosId) return;                 // already written (transaction event + fallback)
   if(!HistorySelectByPosition(posId)) return;
   g_lastRowPosId=posId;
   int n=HistoryDealsTotal();
   double gross=0,comm=0,swap=0,fee=0,volume=0,entryPrice=0,exitPrice=0;
   datetime tin=0,tout=0; long dtype=0; long reason=0;
   for(int i=0;i<n;i++)
     {
      ulong t=HistoryDealGetTicket(i);
      if(t==0) continue;
      long en=HistoryDealGetInteger(t,DEAL_ENTRY);
      gross+=HistoryDealGetDouble(t,DEAL_PROFIT); comm+=HistoryDealGetDouble(t,DEAL_COMMISSION); swap+=HistoryDealGetDouble(t,DEAL_SWAP); fee+=HistoryDealGetDouble(t,DEAL_FEE);
      if(en==DEAL_ENTRY_IN) { tin=(datetime)HistoryDealGetInteger(t,DEAL_TIME); entryPrice=HistoryDealGetDouble(t,DEAL_PRICE); volume=HistoryDealGetDouble(t,DEAL_VOLUME); dtype=HistoryDealGetInteger(t,DEAL_TYPE); }
      else { tout=(datetime)HistoryDealGetInteger(t,DEAL_TIME); exitPrice=HistoryDealGetDouble(t,DEAL_PRICE); reason=HistoryDealGetInteger(t,DEAL_REASON); }
     }
   double net=gross+comm+swap+fee;
   string exitReason=g_pendingExit;
   if(exitReason=="")
     {
      if(reason==DEAL_REASON_TP) exitReason="TP";
      else if(reason==DEAL_REASON_SL) exitReason=(g_trailActive?"TRAIL":"SL");
      else if(reason==DEAL_REASON_SO) exitReason="STOP_OUT";
      else if(reason==DEAL_REASON_CLIENT || reason==DEAL_REASON_MOBILE || reason==DEAL_REASON_WEB) exitReason="MANUAL";
      else exitReason="UNKNOWN";
     }
   int dir=(dtype==DEAL_TYPE_BUY?1:-1);
   double mpp=MoneyPerPointPerLot(dir,entryPrice);
   double mfeMoney=g_maxProfit, maeMoney=g_minProfit;
   MqlDateTime dd; TimeToStruct(tin,dd);
   string line=Pre()+g_tradeId+";"+_Symbol+";"+IntegerToString(g_magic)+";"+DirName(dir)+";"+TimeStr(tin)+";"+TimeStr(UTCToLondon(ServerToUTC(tin)))+";"+TimeStr(tout)+";"+IntegerToString((long)(tout-tin))+";"+
               DoubleToString(volume,2)+";"+DoubleToString(entryPrice,_Digits)+";"+DoubleToString(exitPrice,_Digits)+";"+DoubleToString(g_posSL0,_Digits)+";"+DoubleToString(g_posTP0,_Digits)+";"+
               DoubleToString(g_trailStop,_Digits)+";"+DoubleToString(0.0,_Digits)+";"+DoubleToString(gross,2)+";"+DoubleToString(comm,2)+";"+DoubleToString(swap,2)+";"+DoubleToString(net,2)+";"+
               DoubleToString(mpp,4)+";"+DoubleToString(g_plannedTPMoney,2)+";"+IntegerToString(g_plannedTPPoints)+";"+DoubleToString(mfeMoney,2)+";"+DoubleToString(maeMoney,2)+";"+
               DoubleToString(g_mfePts,1)+";"+DoubleToString(g_maePts,1)+";"+Bool(g_trailActive)+";"+exitReason+";"+DoubleToString(g_entrySpread,1)+";"+IntegerToString(dd.day_of_week);
   CsvAppend(TradesFile(),TradesHeader(),line);
   g_dayExitReason=exitReason;
   EventLog("POSITION_CLOSE","INFO",exitReason,StringFormat("net=%.2f gross=%.2f comm=%.2f swap=%.2f price=%.2f duration=%ds max_profit=%.2f",net,gross,comm,swap,exitPrice,(int)(tout-tin),mfeMoney),0,"");
   g_dayDecision=(g_dayDecision=="ENTERED"?"CLOSED":g_dayDecision);
   ResetPositionState();
   g_tradeId="";
   g_lastCbEval=0;
   EvaluateCircuitBreaker();
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD) return;
   ulong deal=trans.deal;
   if(deal==0) return;
   if(!HistoryDealSelect(deal)) return;
   if((long)HistoryDealGetInteger(deal,DEAL_MAGIC)!=g_magic) return;
   if(HistoryDealGetString(deal,DEAL_SYMBOL)!=_Symbol) return;
   long entry=HistoryDealGetInteger(deal,DEAL_ENTRY);
   if(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY)
     {
      if(!SelectOurPosition()) WriteTradeRow(deal);       // fully closed
     }
  }

//====================================================================
// DAY ROLL
//====================================================================
void WriteDailyRow(long closedKey)
  {
   datetime dayStart=(datetime)(closedKey*86400);
   int c; double net=ClosedPnL(dayStart,dayStart+86400-1,c);
   double endBal=AccountInfoDouble(ACCOUNT_BALANCE);
   string line=Pre()+TimeToString(dayStart,TIME_DATE)+";"+_Symbol+";"+IntegerToString(g_magic)+";"+DoubleToString(g_dayStartBalance,2)+";"+DoubleToString(endBal,2)+";"+DoubleToString(net,2)+";"+IntegerToString(c)+";"+
               g_dayDecision+";"+g_dayReason+";"+g_dayExitReason+";"+DoubleToString(g_dayMaxAdverse,2)+";"+DoubleToString(InpUseDailyTarget?InpDailyTargetMoney:0.0,2)+";"+DoubleToString(InpUseDailyLossLimit?InpDailyLossLimitMoney:0.0,2)+";"+
               DoubleToString(WeekPnL(),2)+";"+g_cbState+";"+Bool(g_paused);
   CsvAppend(DailyFile(),DailyHeader(),line);
  }

void RollDayIfNeeded()
  {
   datetime server=TimeTradeServer();
   long key=DayKey(server);
   if(key==g_dayKey) return;
   if(g_dayKey>=0) WriteDailyRow(g_dayKey);
   g_dayKey=key;
   g_dayDecided=false; g_dayDecision="WAITING"; g_dayReason=""; g_lastBlockReason=""; g_lastBlockLogged="";
   g_dayExitReason=""; g_dayMaxAdverse=0.0; g_tradesToday=TradesToday();
   g_dayStartBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   EventLog("DAY_RESET","INFO","NEW_DAY",StringFormat("server_date=%s london=%s",TimeToString(server,TIME_DATE),TimeStr(UTCToLondon(ServerToUTC(server)))),0,"");
   if(g_hasPos && DayKey(g_posOpenTime)==key) g_dayDecided=true;       // restarted with a position opened today
  }

//====================================================================
// PANEL
//====================================================================
string PN(string n) { return LD_PREFIX+n; }

void PanelLabel(string name,int x,int y,string text,color clr,int size=9,bool bold=false)
  {
   string o=PN(name);
   if(ObjectFind(0,o)<0)
     {
      ObjectCreate(0,o,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,o,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,o,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,o,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,o,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,o,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,o,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,o,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,o,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,o,OBJPROP_FONT,bold?"Consolas Bold":"Consolas");
   ObjectSetString(0,o,OBJPROP_TEXT,text);
  }

void PanelButton(string name,int x,int y,int w,int h,string text,color bg)
  {
   string o=PN(name);
   if(ObjectFind(0,o)<0)
     {
      ObjectCreate(0,o,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,o,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,o,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,o,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,o,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,o,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,o,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,o,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,o,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,o,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,o,OBJPROP_FONTSIZE,8);
   ObjectSetString(0,o,OBJPROP_TEXT,text);
  }

void PanelBox(int x,int y,int w,int h)
  {
   string o=PN("BG");
   if(ObjectFind(0,o)<0)
     {
      ObjectCreate(0,o,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,o,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,o,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,o,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,o,OBJPROP_BORDER_TYPE,BORDER_FLAT);
     }
   ObjectSetInteger(0,o,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,o,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,o,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,o,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,o,OBJPROP_BGCOLOR,C'18,22,30');
   ObjectSetInteger(0,o,OBJPROP_COLOR,C'60,70,90');
  }

void PanelDeleteAll() { ObjectsDeleteAll(0,LD_PREFIX); }

string StateText()
  {
   if(g_hasPos) return "EM POSICAO";
   if(g_paused) return "PAUSADO (manual)";
   if(g_cbPauseUntil>TimeTradeServer() && InpUseCircuitBreaker) return "CIRCUIT BREAKER";
   if(!InpEnableTrading) return "SO MONITORA";
   if(g_dayDecided && g_dayDecision=="SKIPPED") return "DIA PULADO: "+g_dayReason;
   if(g_dayDecision=="CLOSED") return "DIA ENCERRADO";
   if(g_dayDecision=="BLOCKED") return "BLOQUEADO: "+g_dayReason;
   return "AGUARDANDO HORARIO";
  }

void PanelUpdate()
  {
   if(!InpShowPanel) { PanelDeleteAll(); return; }
   int x=InpPanelX,y=InpPanelY;
   datetime server=TimeTradeServer(); datetime utc=ServerToUTC(server); datetime ldn=UTCToLondon(utc);
   color dim=C'140,150,170', txt=C'230,235,245', good=C'80,200,120', warn=C'240,190,70', bad=C'240,90,90', acc=C'110,170,255';
   if(g_panelMinimized)
     {
      PanelBox(x,y,250,26);
      PanelLabel("H",x+8,y+5,"LONDONDROP  "+StateText(),acc,8,true);
      PanelButton("BTN_MIN",x+222,y+3,22,20,"+",C'45,55,75');
      // hide the rest
      string names[]={"L1","L2","L3","L4","L5","L6","L7","L8","BTN_PAUSE","BTN_CLOSE","BTN_CB"};
      for(int i=0;i<ArraySize(names);i++) ObjectDelete(0,PN(names[i]));
      ChartRedraw(0); return;
     }
   PanelBox(x,y,390,206);
   PanelLabel("H",x+8,y+6,StringFormat("LONDONDROP v%s | %s | %s",LD_VERSION,_Symbol,InpEnableTrading?"DEMO/TESTE":"MONITOR"),acc,9,true);
   PanelButton("BTN_MIN",x+362,y+4,22,20,"-",C'45,55,75');
   color sc=(g_hasPos?acc:(StringFind(StateText(),"BLOQ")>=0||StringFind(StateText(),"PULADO")>=0||g_paused?warn:good));
   PanelLabel("L1",x+8,y+28,"ESTADO  "+StateText(),sc,9,true);
   string clk=(InpEntryClock==LD_CLOCK_LONDON?"Londres":(InpEntryClock==LD_CLOCK_SERVER?"Servidor":"UTC"));
   PanelLabel("L2",x+8,y+46,StringFormat("Londres %s | Serv %s | Entrada %02d:%02d %s %s",TimeToString(ldn,TIME_SECONDS),TimeToString(server,TIME_SECONDS),InpEntryHour,InpEntryMinute,clk,InpDirection==LD_SELL?"SELL":"BUY"),txt,8);
   string pos="Sem posicao";
   color pc=dim;
   if(g_hasPos)
     {
      double fp=FloatingPnL();
      pos=StringFormat("%s %.2f @ %.2f | P/L %s | Max %s",DirName(g_posDir),g_posVolume,g_posEntry,Money(fp),Money(g_maxProfit));
      pc=(fp>=0?good:bad);
     }
   PanelLabel("L3",x+8,y+66,"POSICAO  "+pos,pc,8);
   string tp=(InpUseTakeProfit?StringFormat("TP %s (%d pts)",Money(g_plannedTPMoney>0?g_plannedTPMoney:InpTakeProfitMoney),g_plannedTPPoints):"TP off");
   string tr=(InpUseTrailing?(g_trailActive?StringFormat("Trail ATIVO trava %s",Money(g_lockedMoney)):StringFormat("Trail arma em %s",Money(g_hasPos?TrailActivationMoney():(InpTrailActivationInPoints?InpTrailActivationPoints*MoneyPerPointPerLot(-1,SymbolInfoDouble(_Symbol,SYMBOL_BID))*InpLotFixed:InpTrailActivationMoney)))):"Trail off");
   PanelLabel("L4",x+8,y+84,StringFormat("GESTAO  %s | %s | SL %s | Saida %02d:%02d srv",tp,tr,(InpUseStopLoss||InpUseDisasterStop)?"ON":"OFF",InpExitHourServer,InpExitMinuteServer),txt,8);
   double dp=DayPnL(),wp=WeekPnL();
   PanelLabel("L5",x+8,y+104,StringFormat("RISCO   Dia %s (meta %s, lim -%s) | Semana %s (lim -%s)",Money(dp),InpUseDailyTarget?Money(InpDailyTargetMoney):"-",InpUseDailyLossLimit?Money(InpDailyLossLimitMoney):"-",Money(wp),InpUseWeeklyLossLimit?Money(InpWeeklyLossLimitMoney):"-"),(dp>=0?good:bad),8);
   PanelLabel("L6",x+8,y+122,StringFormat("CB %s | Trades hoje %d/%d | Lote %.2f",g_cbState,TradesToday(),InpMaxTradesPerDay,g_hasPos?g_posVolume:InpLotFixed),txt,8);
   PanelLabel("L7",x+8,y+142,StringFormat("TELEMETRIA Spread %.1f | %s | %s",SpreadPoints(),g_lastEvent,g_lastRetcode),dim,8);
   PanelLabel("L8",x+8,y+160,StringFormat("Hoje: %s %s",g_dayDecision,g_dayReason),dim,8);
   PanelButton("BTN_PAUSE",x+8,y+180,110,20,g_paused?"RETOMAR":"PAUSAR ENTRADAS",g_paused?C'30,110,60':C'110,80,20');
   PanelButton("BTN_CLOSE",x+124,y+180,100,20,"FECHAR AGORA",C'130,40,40');
   PanelButton("BTN_CB",x+230,y+180,110,20,"RESETAR CB",C'45,55,75');
   ChartRedraw(0);
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK) return;
   if(StringFind(sparam,LD_PREFIX)!=0) return;
   if(sparam==PN("BTN_MIN")) { g_panelMinimized=!g_panelMinimized; ObjectSetInteger(0,sparam,OBJPROP_STATE,false); PanelDeleteAll(); PanelUpdate(); return; }
   if(sparam==PN("BTN_PAUSE"))
     {
      g_paused=!g_paused; ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      GlobalVariableSet(LD_NAME+"_"+IntegerToString(g_magic)+"_PAUSED",g_paused?1.0:0.0);
      EventLog("RISK","INFO",g_paused?"PAUSED_MANUAL":"RESUMED",g_paused?"entries paused from panel":"entries resumed from panel",0,"");
      PanelUpdate(); return;
     }
   if(sparam==PN("BTN_CLOSE"))
     {
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      if(g_hasPos) { EventLog("RISK","WARNING","MANUAL_CLOSE_BUTTON","close requested from panel",0,""); g_lastCloseTry=0; ClosePositionNow("MANUAL"); }
      return;
     }
   if(sparam==PN("BTN_CB"))
     {
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      g_cbPauseUntil=0; g_cbResetTime=TimeTradeServer(); g_cbState="OK";
      GlobalVariableSet(LD_NAME+"_"+IntegerToString(g_magic)+"_CB_UNTIL",0.0);
      GlobalVariableSet(LD_NAME+"_"+IntegerToString(g_magic)+"_CB_RESET",(double)g_cbResetTime);
      EventLog("RISK","INFO","CIRCUIT_BREAKER_RESET","reset from panel",0,"");
      PanelUpdate(); return;
     }
  }

//====================================================================
// LIFECYCLE
//====================================================================
void ParseSkipDates()
  {
   ArrayResize(g_skipDates,0);
   if(StringLen(InpSkipDates)==0) return;
   string parts[];
   int n=StringSplit(InpSkipDates,',',parts);
   for(int i=0;i<n;i++)
     {
      string s=parts[i]; StringTrimLeft(s); StringTrimRight(s);
      if(StringLen(s)==0) continue;
      int k=ArraySize(g_skipDates); ArrayResize(g_skipDates,k+1); g_skipDates[k]=s;
     }
  }

void PrintParams()
  {
   if(!InpPrintToExperts) return;
   Print(LD_NAME," v",LD_VERSION," INIT magic=",g_magic," symbol=",_Symbol," digits=",_Digits," point=",DoubleToString(_Point,_Digits));
   Print("[03 SINAL] dir=",EnumToString(InpDirection)," clock=",EnumToString(InpEntryClock)," entry=",InpEntryHour,":",InpEntryMinute," window=",InpEntryWindowSeconds,"s");
   Print("[04 FILTROS] spread=",InpUseSpreadFilter,"/",InpMaxSpreadPoints," tickage=",InpUseTickAgeFilter,"/",InpMaxTickAgeSeconds," news=",InpUseNewsFilter,"/",InpNewsCurrency,"/imp>=",InpNewsMinImportance,"/",InpNewsMinutesBefore,"-",InpNewsMinutesAfter,"min");
   Print("[05 HORARIOS] serverRule=",EnumToString(InpServerRule)," exit=",InpUseEndOfDayExit,"@",InpExitHourServer,":",InpExitMinuteServer," maxhold=",InpUseMaxHold,"/",InpMaxHoldMinutes);
   Print("[07 RISCO] lotMode=",EnumToString(InpLotMode)," lot=",InpLotFixed," lotMax=",InpLotMax," emergency=",InpUseEmergencyClose,"/",InpEmergencyLossMoney," weekly=",InpUseWeeklyLossLimit,"/",InpWeeklyLossLimitMoney," CB=",InpUseCircuitBreaker,"/",InpCBConsecutiveLossDays,"d/dd",InpCBDrawdownMoney);
   Print("[08 STOP] SL=",InpUseStopLoss,"/",InpStopLossMoney," disaster=",InpUseDisasterStop,"/",InpDisasterStopMoney);
   Print("[09 PROFIT] TP=",InpUseTakeProfit,"/",EnumToString(InpTPMode),"/",InpTakeProfitMoney,"$/",InpTakeProfitPoints,"pts dailyTarget=",InpUseDailyTarget,"/",InpDailyTargetMoney);
   Print("[10 POSICAO] trail=",InpUseTrailing," act=",(InpTrailActivationInPoints?IntegerToString(InpTrailActivationPoints)+"pts":DoubleToString(InpTrailActivationMoney,2)+"$")," ratio=",InpTrailRatio," exp=",InpTrailExponent," server=",InpTrailOnServer);
   Print("[11 LIMITES] maxTrades=",InpMaxTradesPerDay," dailyLoss=",InpUseDailyLossLimit,"/",InpDailyLossLimitMoney," closePos=",InpDailyLossClosePosition);
  }

int OnInit()
  {
   g_magic=CalculateMagic();
   g_runId=StringFormat("LD_%s_%s",_Symbol,TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   g_startTime=TimeTradeServer();
   if(InpRequireGoldSymbol)
     {
      string s=_Symbol; StringToUpper(s);
      if(StringFind(s,"XAU")<0 && StringFind(s,"GOLD")<0) { Print(LD_NAME,": symbol ",_Symbol," is not gold. Set InpRequireGoldSymbol=false to override."); return INIT_PARAMETERS_INCORRECT; }
     }
   if(InpEntryHour<0 || InpEntryHour>23 || InpEntryMinute<0 || InpEntryMinute>59) return INIT_PARAMETERS_INCORRECT;
   if(InpExitHourServer<0 || InpExitHourServer>23 || InpExitMinuteServer<0 || InpExitMinuteServer>59) return INIT_PARAMETERS_INCORRECT;
   if(InpUseTrailing && InpTrailRatio<=0.0) return INIT_PARAMETERS_INCORRECT;
   if(InpLotFixed<=0.0 || InpLotMax<=0.0) return INIT_PARAMETERS_INCORRECT;
   g_trade.SetExpertMagicNumber((ulong)g_magic);
   g_trade.SetAsyncMode(false);
   ParseSkipDates();
   // persistent flags
   string gp=LD_NAME+"_"+IntegerToString(g_magic);
   g_paused=(GlobalVariableCheck(gp+"_PAUSED") && GlobalVariableGet(gp+"_PAUSED")>0.5);
   g_cbPauseUntil=(GlobalVariableCheck(gp+"_CB_UNTIL")?(datetime)GlobalVariableGet(gp+"_CB_UNTIL"):0);
   g_cbResetTime=(GlobalVariableCheck(gp+"_CB_RESET")?(datetime)GlobalVariableGet(gp+"_CB_RESET"):0);
   g_panelMinimized=InpPanelStartMinimized;
   if(!MQLInfoInteger(MQL_TESTER)) EventSetTimer(1);
   AdoptPosition();
   RollDayIfNeeded();
   EvaluateCircuitBreaker();
   PrintParams();
   EventLog("INIT","INFO","STARTED",StringFormat("version=%s magic=%I64d tester=%s digits=%d point=%s stops_level=%d spread=%.1f lot_min=%.2f lot_step=%.2f",LD_VERSION,g_magic,Bool((bool)MQLInfoInteger(MQL_TESTER)),_Digits,DoubleToString(_Point,_Digits),(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL),SpreadPoints(),SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)),0,"");
   if(g_hasPos) EventLog("POSITION_OPEN","WARNING","ADOPTED","position found at start; management resumed",0,"");
   PanelUpdate();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   EventLog("DEINIT","INFO","STOPPED",StringFormat("reason=%d has_position=%s",reason,Bool(g_hasPos)),0,"");
   if(reason!=REASON_CHARTCHANGE) PanelDeleteAll();
  }

void Heartbeat()
  {
   if(InpHeartbeatSeconds<=0) return;
   datetime now=TimeTradeServer();
   if(g_lastHeartbeat>0 && now-g_lastHeartbeat<InpHeartbeatSeconds) return;
   g_lastHeartbeat=now;
   EventLog("HEARTBEAT","INFO","ALIVE",StringFormat("state=%s connected=%s trade_allowed=%s",StateText(),Bool((bool)TerminalInfoInteger(TERMINAL_CONNECTED)),Bool((bool)MQLInfoInteger(MQL_TRADE_ALLOWED))),0,"");
  }

void Step()
  {
   RollDayIfNeeded();
   if(!g_hasPos && SelectOurPosition()) AdoptPosition();     // external/restart
   if(g_hasPos && !SelectOurPosition())
     {
      // position is gone: make sure the trade row exists (fallback for a missed transaction event)
      if(g_lastRowPosId!=g_posId)
        {
         bool found=false;
         if(HistorySelectByPosition(g_posId))
           {
            for(int i=HistoryDealsTotal()-1;i>=0;i--)
              {
               ulong t=HistoryDealGetTicket(i);
               if(t!=0 && HistoryDealGetInteger(t,DEAL_ENTRY)!=DEAL_ENTRY_IN) { WriteTradeRow(t); found=true; break; }
              }
           }
         if(!found)
           {
            if(g_missingSince==0) g_missingSince=TimeTradeServer();
            if(TimeTradeServer()-g_missingSince<10) return;
            EventLog("ERROR","ERROR","CLOSE_DEAL_NOT_FOUND","position vanished without a deal in history",0,"");
            ResetPositionState();
           }
        }
      g_missingSince=0;
     }
   ManagePosition();
   ApplyTrailing();
   EvaluateEntry();
  }

void OnTick()
  {
   Step();
  }

void OnTimer()
  {
   Step();
   Heartbeat();
   datetime now=TimeLocal();
   if(g_lastPanelUpdate!=now) { g_lastPanelUpdate=now; PanelUpdate(); }
  }
