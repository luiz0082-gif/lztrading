#ifndef __VEGAR_NEWS_MQH__
#define __VEGAR_NEWS_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"
#include "Vegar_Data.mqh"

struct SVegarImportedNewsEvent
  {
   datetime time_utc;
   string currency;
   int importance;
   string name;
  };

class INewsProvider
  {
public:
   virtual bool Refresh(SVegarNewsStatus &status)=0;
   virtual string ProviderName()=0;
  };

SVegarImportedNewsEvent gVegarImportedNews[];
bool gVegarTesterNewsLoaded=false;
SVegarNewsStatus gVegarNewsStatus;

bool Vegar_IsMetalSymbol()
  {
   string base=gVegarSymbol.base_currency;
   if(base=="XAU" || base=="XAG") return true;
   string s=_Symbol; StringToUpper(s);
   return (StringFind(s,"XAU")>=0 || StringFind(s,"XAG")>=0);
  }

void Vegar_NewsWindows(int &before_min,int &after_min)
  {
   before_min=InpMinutosAntes; after_min=InpMinutosDepois;
   if(InpPerfilAutomaticoMetais && Vegar_IsMetalSymbol())
     {
      before_min=InpMetaisMinutosAntes;
      after_min=InpMetaisMinutosDepois;
     }
  }

int Vegar_AppendImportedNews(const datetime t,const string currency,const int importance,const string name)
  {
   int n=ArraySize(gVegarImportedNews);
   ArrayResize(gVegarImportedNews,n+1);
   gVegarImportedNews[n].time_utc=t;
   gVegarImportedNews[n].currency=currency;
   gVegarImportedNews[n].importance=importance;
   gVegarImportedNews[n].name=name;
   return n;
  }

bool Vegar_LoadTesterNewsFile()
  {
   ArrayResize(gVegarImportedNews,0);
   int h=FileOpen(InpTesterNewsFile,FILE_READ|FILE_CSV|FILE_ANSI|FILE_SHARE_READ,',');
   if(h==INVALID_HANDLE) { gVegarTesterNewsLoaded=false; return false; }
   bool first=true;
   while(!FileIsEnding(h))
     {
      string ts=FileReadString(h);
      if(FileIsEnding(h) && ts=="") break;
      string cur=FileReadString(h);
      string imp=FileReadString(h);
      string name=FileReadString(h);
      if(first)
        {
         first=false;
         string u=ts; StringToUpper(u);
         if(StringFind(u,"TIME")>=0 || StringFind(u,"DATE")>=0) continue;
        }
      datetime t=0;
      long numeric=(long)StringToInteger(ts);
      if(numeric>1000000000) t=(datetime)numeric;
      else t=StringToTime(ts);
      int importance=(int)StringToInteger(imp);
      if(t>0 && cur!="") Vegar_AppendImportedNews(t,cur,importance,name);
     }
   FileClose(h);
   gVegarTesterNewsLoaded=(ArraySize(gVegarImportedNews)>0);
   return gVegarTesterNewsLoaded;
  }

class CTesterNewsProvider : public INewsProvider
  {
public:
   virtual string ProviderName() { return "TESTER_IMPORTED"; }
   virtual bool Refresh(SVegarNewsStatus &status)
     {
      ZeroMemory(status); status.provider=ProviderName();
      if(!InpAtivarFiltroNoticias) { status.state=VEGAR_NEWS_DISABLED; status.valid=true; return true; }
      if(!gVegarTesterNewsLoaded && !Vegar_LoadTesterNewsFile())
        { status.state=VEGAR_NEWS_UNAVAILABLE; status.valid=false; return false; }
      datetime server=TimeCurrent();
      datetime utc=server-Vegar_CurrentServerUtcOffsetSeconds();
      int before=0,after=0; Vegar_NewsWindows(before,after);
      string c1=gVegarSymbol.base_currency,c2=gVegarSymbol.profit_currency;
      if(Vegar_IsMetalSymbol()) { c1="USD"; c2=""; }
      status.state=VEGAR_NEWS_CLEAR; status.valid=true; status.seconds_to_event=2147483647;
      for(int i=0;i<ArraySize(gVegarImportedNews);i++)
        {
         if(gVegarImportedNews[i].importance<InpImpactoMinimo) continue;
         if(gVegarImportedNews[i].currency!=c1 && (c2=="" || gVegarImportedNews[i].currency!=c2)) continue;
         int delta=(int)(gVegarImportedNews[i].time_utc-utc);
         if(MathAbs(delta)<MathAbs(status.seconds_to_event))
           {
            status.currency=gVegarImportedNews[i].currency; status.event_name=gVegarImportedNews[i].name;
            status.importance=gVegarImportedNews[i].importance; status.event_time=gVegarImportedNews[i].time_utc; status.seconds_to_event=delta;
           }
         if(delta<=before*60 && delta>=-after*60)
           {
            status.state=VEGAR_NEWS_BLOCKED; return true;
           }
        }
      return true;
     }
  };

class CLiveNewsProvider : public INewsProvider
  {
private:
   bool QueryCurrency(const string currency,const datetime from,const datetime to,SVegarNewsStatus &best,bool &anyData)
     {
      if(currency=="") return true;
      MqlCalendarValue values[];
      ResetLastError();
      int n=CalendarValueHistory(values,from,to,NULL,currency);
      if(n<0) return false;
      anyData=true;
      datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
      int before=0,after=0; Vegar_NewsWindows(before,after);
      for(int i=0;i<n;i++)
        {
         MqlCalendarEvent ev;
         if(!CalendarEventById(values[i].event_id,ev)) continue;
         int importance=(int)ev.importance;
         if(importance<InpImpactoMinimo) continue;
         int delta=(int)(values[i].time-now);
         if(best.event_time==0 || MathAbs(delta)<MathAbs(best.seconds_to_event))
           {
            best.currency=currency; best.event_name=ev.name; best.importance=importance;
            best.event_time=values[i].time; best.seconds_to_event=delta;
           }
         if(delta<=before*60 && delta>=-after*60) best.state=VEGAR_NEWS_BLOCKED;
        }
      return true;
     }
public:
   virtual string ProviderName() { return "MT5_ECONOMIC_CALENDAR"; }
   virtual bool Refresh(SVegarNewsStatus &status)
     {
      ZeroMemory(status); status.provider=ProviderName();
      if(!InpAtivarFiltroNoticias) { status.state=VEGAR_NEWS_DISABLED; status.valid=true; return true; }
      datetime now=TimeTradeServer(); if(now<=0) now=TimeCurrent();
      int before=0,after=0; Vegar_NewsWindows(before,after);
      datetime from=now-after*60-86400;
      datetime to=now+before*60+86400;
      status.state=VEGAR_NEWS_CLEAR; status.seconds_to_event=2147483647;
      bool anyData=false;
      string c1=gVegarSymbol.base_currency,c2=gVegarSymbol.profit_currency;
      if(Vegar_IsMetalSymbol()) { c1="USD"; c2=""; }
      bool ok1=QueryCurrency(c1,from,to,status,anyData);
      bool ok2=QueryCurrency(c2,from,to,status,anyData);
      if(!ok1 || !ok2 || !anyData)
        {
         status.state=VEGAR_NEWS_UNAVAILABLE; status.valid=false; return false;
        }
      status.valid=true; return true;
     }
  };

CTesterNewsProvider gVegarTesterNewsProvider;
CLiveNewsProvider gVegarLiveNewsProvider;

bool Vegar_UpdateNews()
  {
   bool tester=(bool)MQLInfoInteger(MQL_TESTER);
   if(tester) return gVegarTesterNewsProvider.Refresh(gVegarNewsStatus);
   return gVegarLiveNewsProvider.Refresh(gVegarNewsStatus);
  }

bool Vegar_NewsAllowsEntry(ENUM_VEGAR_REASON_CODE &reason)
  {
   if(!InpAtivarFiltroNoticias) { reason=VEGAR_REASON_NONE; return true; }
   if(gVegarNewsStatus.state==VEGAR_NEWS_BLOCKED) { reason=NEWS_HIGH_IMPACT; return false; }
   if(gVegarNewsStatus.state==VEGAR_NEWS_UNAVAILABLE) { reason=NEWS_DATA_UNAVAILABLE; return false; }
   reason=VEGAR_REASON_NONE; return true;
  }

#endif
