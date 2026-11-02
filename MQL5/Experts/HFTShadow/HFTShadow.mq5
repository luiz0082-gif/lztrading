//+------------------------------------------------------------------+
//| HFTShadow.mq5 — laboratório de ticks em MODO SOMBRA              |
//| NÃO ENVIA ORDENS. Detecta sinais de fluxo de ticks, simula       |
//| entradas/saídas virtuais (ask/bid + atraso) e grava CSV.         |
//| Objetivo: acumular evidência fora da amostra (ver                |
//| docs/HFT-M1-ESTUDO-2026-10-23.md). Hipótese NÃO provada.         |
//+------------------------------------------------------------------+
#property copyright "LZ Trading"
#property version   "1.02"
#property description "Modo sombra: sem ordens. Registra sinais de ticks e resultado virtual (ask/bid + atraso)."
#property strict

#define HS_VERSION "1.02"
#define HS_SCHEMA  "HS1"
#define NSIG 5
#define NL   4
#define NH   4
#define RB   65536

//--- 01 -------------------------------------------------------------
input group "══════ 01 | IDENTIFICAÇÃO ══════"
input string InpInstance      = "A";        // Rótulo da instância (aparece no CSV)

//--- 02 -------------------------------------------------------------
input group "══════ 02 | SÍMBOLO ══════"
input string InpSymbolFilter  = "";         // Exige este texto no nome do símbolo ("" = qualquer)

//--- 03 -------------------------------------------------------------
input group "══════ 03 | SINAIS DE TICKS ══════"
input bool   InpSigMom250     = true;       // Sinal momentum 250 ms
input double InpThrMom250     = 0.73;       // Limiar |Δmid| em preço (XAUUSD IC: q99,5 do treino 05–15/10/2026)
input bool   InpSigMom1000    = true;       // Sinal momentum 1 s
input double InpThrMom1000    = 1.21;       // Limiar |Δmid| em preço
input bool   InpSigMom5000    = true;       // Sinal momentum 5 s
input double InpThrMom5000    = 2.355;      // Limiar |Δmid| em preço
input bool   InpSigImb10      = true;       // Sinal desequilíbrio de ticks (últimos 10)
input double InpThrImb10      = 1.00;       // Limiar |(altas−baixas)/10| (1,0 = 10 ticks seguidos; 0,9 disparava ~4.500x/dia)
input bool   InpSigImb30      = true;       // Sinal desequilíbrio de ticks (últimos 30)
input double InpThrImb30      = 0.733;      // Limiar |(altas−baixas)/30|
input int    InpCooldownMs    = 2000;       // Intervalo mínimo entre sinais de momentum (ms)
input int    InpCooldownImbMs = 10000;      // Intervalo mínimo entre sinais de desequilíbrio (ms)

//--- 04 -------------------------------------------------------------
input group "══════ 04 | FILTROS ══════"
input double InpMaxSpreadPts  = 15.0;       // Spread máximo na entrada (pontos)
input int    InpMaxStaleMs    = 3000;       // Idade máxima do tick usado como preço virtual (ms)
input int    InpWarmupTicks   = 300;        // Ticks mínimos no buffer antes de gerar sinais
input int    InpMaxPending    = 4096;       // Capacidade da fila de sinais aguardando resultado
input int    InpMaxCatchupMs  = 10000;      // Ao (re)iniciar/reconectar, só ingere ticks dos últimos N ms (evita reprocessar histórico)

//--- 05 -------------------------------------------------------------
input group "══════ 05 | HORÁRIOS (relógio do servidor) ══════"
input bool   InpBlockRollover = true;       // Bloquear sinais na janela de rolagem/pausa
input int    InpBlockStartMin = 1410;       // Início do bloqueio (minuto do dia; 1410 = 23:30)
input int    InpBlockEndMin   = 75;         // Fim do bloqueio (minuto do dia; 75 = 01:15)

//--- 12 -------------------------------------------------------------
input group "══════ 12 | PAINEL ══════"
input bool   InpShowPanel     = true;       // Mostrar painel
input int    InpPanelX        = 10;         // Posição X (px)
input int    InpPanelY        = 25;         // Posição Y (px)

//--- 13 -------------------------------------------------------------
input group "══════ 13 | TELEMETRIA / CSV ══════"
input bool   InpWriteCsv      = true;       // Gravar CSV de sinais, heartbeat e eventos
input int    InpFlushSec      = 5;          // Descarga do buffer de sinais no disco (s)
input int    InpHeartbeatSec  = 60;         // Intervalo do heartbeat (s)

//--- 14 -------------------------------------------------------------
input group "══════ 14 | AVANÇADO ══════"
input bool   InpDebug         = false;      // Log detalhado no Experts

//--- estado --------------------------------------------------------
const int    g_L[NL]  = {0,100,300,1000};          // atraso de execução simulado (ms)
const int    g_H[NH]  = {1000,3000,10000,30000};   // tempo de permanência simulado (ms)
const string g_sn[NSIG]= {"mom250","mom1000","mom5000","imb10","imb30"};

long   g_tm[RB]; double g_bid[RB]; double g_ask[RB];
long   g_n=0;                       // total de ticks ingeridos
long   g_lastMsc=0; int g_lastCnt=0;
int    g_sgn[30]; int g_sgnPos=0; long g_sgnN=0;   // sinais de variação dos últimos 30 ticks
double g_thr[NSIG]; bool g_en[NSIG];
long   g_lastFire[NSIG];

struct Pend { long id; int sig; int sgn; long t0; double bid0; double ask0; double val; double thr; double spr; int rate; long ping; };
Pend   g_p[]; int g_np=0; long g_nextId=1; long g_dropped=0;

double g_stN[NSIG]; double g_stFollow[NSIG]; double g_stFade[NSIG]; double g_stWin[NSIG];
long   g_fired[NSIG];
string g_sbuf=""; datetime g_lastFlush=0; datetime g_lastHb=0; datetime g_lastPanel=0;
long   g_tickInHb=0; long g_maxGapMs=0; long g_prevMsc=0;
string g_state="INICIANDO"; string g_block="";
bool   g_min=false;

//+------------------------------------------------------------------+
long TickMs(){ MqlTick t; if(SymbolInfoTick(_Symbol,t)) return t.time_msc; return 0; }

string MsToStr(long m)
{
   datetime s=(datetime)(m/1000);
   return TimeToString(s,TIME_DATE|TIME_SECONDS)+"."+StringFormat("%03d",(int)(m%1000));
}

string Fx(double v,int d=5){ return DoubleToString(v,d); }

void WriteFile(const string kind,const string header,const string line)
{
   if(!InpWriteCsv) return;
   MqlDateTime dt; TimeToStruct(TimeCurrent(),dt);
   string fn=StringFormat("HFTShadow\\HFTShadow_%s_%04d-%02d.csv",kind,dt.year,dt.mon);
   int h=FileOpen(fn,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(h==INVALID_HANDLE){ Print("HFTShadow: erro abrindo ",fn," err=",GetLastError()); return; }
   if(FileSize(h)==0) FileWriteString(h,header+"\r\n");
   FileSeek(h,0,SEEK_END); FileWriteString(h,line+"\r\n"); FileClose(h);
}

string SigHeader()
{
   string s="schema;version;instance;event_id;time_server;time_msc;symbol;signal;sign;value;thr;bid;ask;spread_pts;rate500;ping_us;hour;minute;dow;valid;mfe30_up;mfe30_dn";
   for(int l=0;l<NL;l++) for(int h=0;h<NH;h++) s+=StringFormat(";ln_L%d_H%d;sn_L%d_H%d",g_L[l],g_H[h]/1000,g_L[l],g_H[h]/1000);
   return s;
}

void Event(const string kind,const string msg)
{
   string line=HS_SCHEMA+";"+HS_VERSION+";"+InpInstance+";"+MsToStr(TickMs())+";"+kind+";"+msg;
   WriteFile("events","schema;version;instance;time_server;kind;message",line);
   Print("HFTShadow [",kind,"] ",msg);
}

//--- buffer de ticks ------------------------------------------------
long LoIdx(){ return (g_n>RB)? g_n-RB : 0; }

long LastIdxAtOrBefore(long tms)
{
   long lo=LoIdx(), hi=g_n-1; if(hi<lo) return -1;
   if(g_tm[(int)(lo%RB)]>tms) return -1;
   while(lo<hi){ long mid=(lo+hi+1)/2; if(g_tm[(int)(mid%RB)]<=tms) lo=mid; else hi=mid-1; }
   return lo;
}

void Append(const MqlTick &tk)
{
   int p=(int)(g_n%RB);
   double prevMid=0; if(g_n>0){ int q=(int)((g_n-1)%RB); prevMid=(g_bid[q]+g_ask[q])/2.0; }
   g_tm[p]=tk.time_msc; g_bid[p]=tk.bid; g_ask[p]=tk.ask; g_n++;
   double mid=(tk.bid+tk.ask)/2.0; int sg=(g_n>1)? (mid>prevMid?1:(mid<prevMid?-1:0)) : 0;
   g_sgn[g_sgnPos]=sg; g_sgnPos=(g_sgnPos+1)%30; g_sgnN++;
   g_tickInHb++; if(g_prevMsc>0 && tk.time_msc-g_prevMsc>g_maxGapMs) g_maxGapMs=tk.time_msc-g_prevMsc; g_prevMsc=tk.time_msc;
}

double ImbN(int k)
{
   if(g_sgnN<k) return 0; int s=0;
   for(int i=1;i<=k;i++){ int pos=(g_sgnPos-i+30*2)%30; s+=g_sgn[pos]; }
   return (double)s/k;
}

bool InBlock(long msc)
{
   if(!InpBlockRollover) return false;
   int sod=(int)((msc/1000)%86400)/60;
   if(InpBlockStartMin>InpBlockEndMin) return (sod>=InpBlockStartMin || sod<InpBlockEndMin);
   return (sod>=InpBlockStartMin && sod<InpBlockEndMin);
}

//--- sinais -------------------------------------------------------------
void TryFire(int sig,double val,long msc,double bid,double ask)
{
   if(!g_en[sig]) return;
   if(MathAbs(val)<g_thr[sig]) return;
   int cd=(sig>=3)? InpCooldownImbMs : InpCooldownMs;
   if(msc-g_lastFire[sig]<cd) return;
   double sp=(ask-bid)/_Point;
   if(sp>InpMaxSpreadPts){ g_block="SPREAD_ALTO"; return; }
   if(InBlock(msc)){ g_block="ROLAGEM"; return; }
   g_lastFire[sig]=msc; g_fired[sig]++;
   if(g_np>=ArraySize(g_p)){ g_dropped++; if(g_dropped==1 || g_dropped%100==0) Event("DROP","fila de pendentes cheia ("+(string)g_np+") sinal="+g_sn[sig]+" descartados="+(string)g_dropped); return; }
   int i0=(int)LastIdxAtOrBefore(msc-500); int rate=(i0>=0)? (int)(g_n-1-i0) : 0;
   Pend p; p.id=g_nextId++; p.sig=sig; p.sgn=(val>0)?1:-1; p.t0=msc; p.bid0=bid; p.ask0=ask; p.val=val; p.thr=g_thr[sig]; p.spr=sp; p.rate=rate;
   p.ping=TerminalInfoInteger(TERMINAL_PING_LAST);
   g_p[g_np++]=p;
   if(InpDebug) Print("HFTShadow sinal ",g_sn[sig]," ",(p.sgn>0?"UP":"DOWN")," val=",DoubleToString(val,3)," spr=",DoubleToString(sp,1));
}

void Evaluate(long msc,double bid,double ask)
{
   if(g_n<InpWarmupTicks) return;
   double mid=(bid+ask)/2.0; g_block="";
   long Ws[3]={250,1000,5000};
   for(int w=0;w<3;w++)
   {
      if(!g_en[w]) continue;
      long j=LastIdxAtOrBefore(msc-Ws[w]); if(j<0) continue;
      int q=(int)(j%RB); if(msc-Ws[w]-g_tm[q]>InpMaxStaleMs) continue;   // referência velha demais
      double m0=(g_bid[q]+g_ask[q])/2.0;
      TryFire(w,mid-m0,msc,bid,ask);
   }
   TryFire(3,ImbN(10),msc,bid,ask);
   TryFire(4,ImbN(30),msc,bid,ask);
}

//--- resolução de sinais pendentes ------------------------------------------
void Resolve(const Pend &p)
{
   double ln[NL][NH], sn[NL][NH]; bool valid=true; double up=0,dn=0;
   double mid0=(p.bid0+p.ask0)/2.0;
   for(int l=0;l<NL;l++)
   {
      long te=p.t0+g_L[l]; long ei=LastIdxAtOrBefore(te);
      if(ei<0 || ei<LoIdx() || te-g_tm[(int)(ei%RB)]>InpMaxStaleMs){ valid=false; for(int h=0;h<NH;h++){ln[l][h]=0;sn[l][h]=0;} continue; }
      int e=(int)(ei%RB);
      for(int h=0;h<NH;h++)
      {
         long tx=te+g_H[h]; long xi=LastIdxAtOrBefore(tx);
         if(xi<0 || xi<ei || tx-g_tm[(int)(xi%RB)]>InpMaxStaleMs){ valid=false; ln[l][h]=0; sn[l][h]=0; continue; }
         int x=(int)(xi%RB);
         ln[l][h]=g_bid[x]-g_ask[e];     // compra: entra no ask, sai no bid
         sn[l][h]=g_bid[e]-g_ask[x];     // venda: entra no bid, sai no ask
      }
   }
   long a=LastIdxAtOrBefore(p.t0), b=LastIdxAtOrBefore(p.t0+30000);
   if(a>=0 && b>=a && a>=LoIdx())
      for(long k=a;k<=b;k++){ int q=(int)(k%RB); double m=(g_bid[q]+g_ask[q])/2.0-mid0; if(m>up) up=m; if(m<dn) dn=m; }
   // estatística ao vivo (referência: atraso 300 ms, 10 s)
   if(valid)
   {
      double lf=ln[2][2], sf=sn[2][2];
      double follow=(p.sgn>0)? lf : sf;  double fade=(p.sgn>0)? sf : lf;
      g_stN[p.sig]+=1; g_stFollow[p.sig]+=follow; g_stFade[p.sig]+=fade; if(follow>0) g_stWin[p.sig]+=1;
   }
   MqlDateTime dt; TimeToStruct((datetime)(p.t0/1000),dt);
   string s=HS_SCHEMA+";"+HS_VERSION+";"+InpInstance+";"+(string)p.id+";"+MsToStr(p.t0)+";"+(string)p.t0+";"+_Symbol+";"+g_sn[p.sig]+";"+(string)p.sgn+";"+Fx(p.val,4)+";"+Fx(p.thr,4)+";"+Fx(p.bid0)+";"+Fx(p.ask0)+";"+Fx(p.spr,1)+";"+(string)p.rate+";"+(string)p.ping+";"+(string)dt.hour+";"+(string)dt.min+";"+(string)dt.day_of_week+";"+(valid?"1":"0")+";"+Fx(up)+";"+Fx(dn);
   for(int l=0;l<NL;l++) for(int h=0;h<NH;h++) s+=";"+Fx(ln[l][h])+";"+Fx(sn[l][h]);
   g_sbuf+=s+"\r\n";
}

void ResolveDue(long newestMsc)
{
   long need=g_L[NL-1]+g_H[NH-1]+500;
   int w=0;
   for(int i=0;i<g_np;i++)
   {
      if(newestMsc>=g_p[i].t0+need) { Resolve(g_p[i]); }
      else { if(w!=i) g_p[w]=g_p[i]; w++; }
   }
   g_np=w;
}

void FlushSignals(bool force)
{
   if(StringLen(g_sbuf)==0) return;
   if(!force && TimeLocal()-g_lastFlush<InpFlushSec) return;
   g_lastFlush=TimeLocal();
   if(InpWriteCsv)
   {
      MqlDateTime dt; TimeToStruct(TimeCurrent(),dt);
      string fn=StringFormat("HFTShadow\\HFTShadow_signals_%04d-%02d.csv",dt.year,dt.mon);
      int h=FileOpen(fn,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
      if(h==INVALID_HANDLE){ Print("HFTShadow: erro abrindo ",fn," err=",GetLastError()); return; }
      if(FileSize(h)==0) FileWriteString(h,SigHeader()+"\r\n");
      FileSeek(h,0,SEEK_END); FileWriteString(h,g_sbuf); FileClose(h);
   }
   g_sbuf="";
}

//--- ingestão de ticks --------------------------------------------------------
void ResetStream(const string why)
{
   g_n=0; g_sgnN=0; g_sgnPos=0; g_np=0; g_lastMsc=0; g_lastCnt=0; g_prevMsc=0;
   for(int i=0;i<NSIG;i++) g_lastFire[i]=0;
   Event("STREAM_RESET",why);
}

void Poll()
{
   MqlTick arr[];
   long nowMs=(long)TimeTradeServer()*1000;                 // relógio do servidor (não depende do último tick em cache)
   long floorMs=nowMs-InpMaxCatchupMs;
   // cursor muito antigo (reinício/reconexão/mercado fechado): descarta o passado e recomeça do presente
   if(g_lastMsc>0 && g_lastMsc<nowMs-60000 && g_n>0) ResetStream("cursor antigo ("+MsToStr(g_lastMsc)+"); recomeçando de "+MsToStr(floorMs));
   ulong from=(g_lastMsc>0)? (ulong)g_lastMsc : (ulong)MathMax(0,floorMs);
   int n=CopyTicksRange(_Symbol,arr,COPY_TICKS_INFO,from,0);
   if(n<=0) return;
   if(n>200000){ ResetStream("lote de "+(string)n+" ticks; ingerindo só os últimos "+(string)InpMaxCatchupMs+" ms"); from=(ulong)MathMax(0,arr[n-1].time_msc-InpMaxCatchupMs); n=CopyTicksRange(_Symbol,arr,COPY_TICKS_INFO,from,0); if(n<=0) return; }
   long lm=g_lastMsc; int lc=g_lastCnt; int seen=0;
   for(int i=0;i<n;i++)
   {
      long m=arr[i].time_msc;
      if(g_lastMsc==0 && lm==0 && m<floorMs) continue;       // 1º lote: ignora ticks anteriores à janela de catch-up
      if(m<lm) continue;
      if(arr[i].bid<=0 || arr[i].ask<=0 || arr[i].ask<arr[i].bid) continue;
      if(m==lm){ seen++; if(seen<=lc) continue; lc++; }
      else { lm=m; lc=1; seen=1; }
      Append(arr[i]);
      Evaluate(m,arr[i].bid,arr[i].ask);
   }
   g_lastMsc=lm; g_lastCnt=lc;
   if(g_n>0) ResolveDue(g_lastMsc);
   g_state="RECEBENDO TICKS";
}

//--- heartbeat -------------------------------------------------------------------
void Heartbeat()
{
   double sp=0; if(g_n>0){ int q=(int)((g_n-1)%RB); sp=(g_ask[q]-g_bid[q])/_Point; }
   double tps=(double)g_tickInHb/MathMax(1,InpHeartbeatSec);
   string line=HS_SCHEMA+";"+HS_VERSION+";"+InpInstance+";"+MsToStr(TickMs())+";"+_Symbol+";"+DoubleToString(tps,2)+";"+DoubleToString(sp,1)+";"+(string)TerminalInfoInteger(TERMINAL_PING_LAST)+";"+(string)g_maxGapMs+";"+(string)g_np+";"+(string)g_dropped+";"+(string)g_n+";"+(string)(bool)TerminalInfoInteger(TERMINAL_CONNECTED)+";"+(string)(bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
   WriteFile("heartbeat","schema;version;instance;time_server;symbol;ticks_per_s;spread_pts;ping_us;max_gap_ms;pending;dropped;ticks_total;connected;trade_allowed",line);
   g_tickInHb=0; g_maxGapMs=0;
}

//--- painel --------------------------------------------------------------------------
void Lbl(const string name,const string txt,int y,color c=clrWhite)
{
   string o="HS_"+name;
   if(ObjectFind(0,o)<0)
   {
      ObjectCreate(0,o,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,o,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,o,OBJPROP_FONTSIZE,9);
      ObjectSetString(0,o,OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,o,OBJPROP_SELECTABLE,false);
   }
   ObjectSetInteger(0,o,OBJPROP_XDISTANCE,InpPanelX);
   ObjectSetInteger(0,o,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,o,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,o,OBJPROP_COLOR,c);
}

void Panel()
{
   if(!InpShowPanel) return;
   int y=InpPanelY, dy=15;
   Lbl("t","HFTShadow v"+HS_VERSION+"  [MODO SOMBRA - sem ordens]",y,clrGold); y+=dy;
   if(g_min){ ChartRedraw(); return; }
   double sp=0; if(g_n>0){ int q=(int)((g_n-1)%RB); sp=(g_ask[q]-g_bid[q])/_Point; }
   Lbl("s","Estado: "+g_state+"  | bloqueio: "+(g_block==""?"-":g_block),y,clrWhite); y+=dy;
   Lbl("m","Ticks: "+(string)g_n+"  spread: "+DoubleToString(sp,1)+" pts  ping: "+(string)TerminalInfoInteger(TERMINAL_PING_LAST)+" us",y); y+=dy;
   Lbl("p","Pendentes: "+(string)g_np+"  descartados: "+(string)g_dropped,y); y+=dy;
   Lbl("h","Sinal     disp.   n   seguir(US$/oz)  fade   acerto  [atraso 300ms, 10s]",y,clrSilver); y+=dy;
   for(int s=0;s<NSIG;s++)
   {
      double n=g_stN[s]; string a=(n>0)? DoubleToString(100.0*g_stWin[s]/n,0)+"%" : "-";
      string t=StringFormat("%-8s %5d %5d  %8.3f   %8.3f  %s",g_sn[s],(int)g_fired[s],(int)n,(n>0?g_stFollow[s]/n:0.0),(n>0?g_stFade[s]/n:0.0),a);
      Lbl("r"+(string)s,t,y,(n>=30 && g_stFollow[s]/n>0)?clrLime:clrWhite); y+=dy;
   }
   Lbl("c","CSV: MQL5\\Files\\HFTShadow\\  (signals/heartbeat/events)",y,clrSilver);
   ChartRedraw();
}

//+------------------------------------------------------------------+
int OnInit()
{
   if(StringLen(InpSymbolFilter)>0 && StringFind(_Symbol,InpSymbolFilter)<0)
   { Alert("HFTShadow: símbolo ",_Symbol," não contém '",InpSymbolFilter,"'."); return INIT_PARAMETERS_INCORRECT; }
   if(!SymbolSelect(_Symbol,true)) { Print("HFTShadow: SymbolSelect falhou ",_Symbol); return INIT_FAILED; }
   ArrayResize(g_p,MathMax(512,InpMaxPending)); g_np=0;
   g_en[0]=InpSigMom250; g_en[1]=InpSigMom1000; g_en[2]=InpSigMom5000; g_en[3]=InpSigImb10; g_en[4]=InpSigImb30;
   g_thr[0]=InpThrMom250; g_thr[1]=InpThrMom1000; g_thr[2]=InpThrMom5000; g_thr[3]=InpThrImb10; g_thr[4]=InpThrImb30;
   for(int i=0;i<NSIG;i++){ g_lastFire[i]=0; g_stN[i]=0; g_stFollow[i]=0; g_stFade[i]=0; g_stWin[i]=0; g_fired[i]=0; }
   ArrayInitialize(g_sgn,0);
   g_lastFlush=TimeLocal(); g_lastHb=TimeLocal(); g_lastPanel=0;
   EventSetMillisecondTimer(50);
   string pr="INIT v"+HS_VERSION+" symbol="+_Symbol+" digits="+(string)_Digits+" point="+DoubleToString(_Point,_Digits)
     +" | 03 sinais mom250="+(string)InpSigMom250+"/"+DoubleToString(InpThrMom250,3)+" mom1000="+(string)InpSigMom1000+"/"+DoubleToString(InpThrMom1000,3)
     +" mom5000="+(string)InpSigMom5000+"/"+DoubleToString(InpThrMom5000,3)+" imb10="+(string)InpSigImb10+"/"+DoubleToString(InpThrImb10,3)
     +" imb30="+(string)InpSigImb30+"/"+DoubleToString(InpThrImb30,3)+" catchup="+(string)InpMaxCatchupMs+" cooldown="+(string)InpCooldownMs+"/imb="+(string)InpCooldownImbMs+" maxPending="+(string)InpMaxPending
     +" | 04 maxSpread="+DoubleToString(InpMaxSpreadPts,1)+" maxStale="+(string)InpMaxStaleMs+" warmup="+(string)InpWarmupTicks
     +" | 05 rolagem="+(string)InpBlockRollover+" "+(string)InpBlockStartMin+"-"+(string)InpBlockEndMin
     +" | 13 csv="+(string)InpWriteCsv+" flush="+(string)InpFlushSec+"s hb="+(string)InpHeartbeatSec+"s | conta="+(string)AccountInfoInteger(ACCOUNT_LOGIN)
     +" server="+AccountInfoString(ACCOUNT_SERVER)+" | NAO ENVIA ORDENS";
   Event("INIT",pr);
   Panel();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer(); FlushSignals(true);
   Event("DEINIT","reason="+(string)reason+" ticks="+(string)g_n+" pendentes_perdidos="+(string)g_np);
   ObjectsDeleteAll(0,"HS_");
}

void OnTick(){ Poll(); FlushSignals(false); }

void OnTimer()
{
   Poll(); FlushSignals(false);
   if(TimeLocal()-g_lastHb>=InpHeartbeatSec){ g_lastHb=TimeLocal(); Heartbeat(); }
   if(TimeLocal()-g_lastPanel>=1){ g_lastPanel=TimeLocal(); Panel(); }
}
//+------------------------------------------------------------------+
