#ifndef __VEGAR_TIME_MQH__
#define __VEGAR_TIME_MQH__

#include "Vegar_Types.mqh"
#include "Vegar_Config.mqh"

int Vegar_DayOfWeek(const datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt); return dt.day_of_week;
  }

datetime Vegar_MakeDateTime(const int y,const int mon,const int day,const int hh,const int mm,const int ss=0)
  {
   MqlDateTime dt;
   ZeroMemory(dt);
   dt.year=y; dt.mon=mon; dt.day=day; dt.hour=hh; dt.min=mm; dt.sec=ss;
   return StructToTime(dt);
  }

int Vegar_NthSunday(const int year,const int month,const int nth)
  {
   datetime first=Vegar_MakeDateTime(year,month,1,0,0,0);
   int dow=Vegar_DayOfWeek(first);
   int first_sunday=1+((7-dow)%7);
   return first_sunday+(nth-1)*7;
  }

bool Vegar_IsNewYorkDSTByUTC(const datetime utc_time)
  {
   MqlDateTime u; TimeToStruct(utc_time,u);
   int march_second_sunday=Vegar_NthSunday(u.year,3,2);
   int nov_first_sunday=Vegar_NthSunday(u.year,11,1);
   // US DST: 02:00 local standard = 07:00 UTC start; 02:00 local daylight = 06:00 UTC end.
   datetime start_utc=Vegar_MakeDateTime(u.year,3,march_second_sunday,7,0,0);
   datetime end_utc=Vegar_MakeDateTime(u.year,11,nov_first_sunday,6,0,0);
   return (utc_time>=start_utc && utc_time<end_utc);
  }

datetime Vegar_UTCToNewYork(const datetime utc_time)
  {
   int offset=Vegar_IsNewYorkDSTByUTC(utc_time) ? -4*3600 : -5*3600;
   return utc_time+offset;
  }

int Vegar_CurrentServerUtcOffsetSeconds()
  {
   datetime server=TimeTradeServer();
   datetime utc=TimeGMT();
   if(server<=0 || utc<=0) return 0;
   return (int)(server-utc);
  }

datetime Vegar_ServerToUTC(const datetime server_time)
  {
   return server_time-Vegar_CurrentServerUtcOffsetSeconds();
  }

datetime Vegar_ServerToNewYork(const datetime server_time)
  {
   return Vegar_UTCToNewYork(Vegar_ServerToUTC(server_time));
  }

bool Vegar_MinuteInWindow(const int minute_of_day,const string start_hhmm,const string end_hhmm)
  {
   int a=0,b=0;
   if(!Vegar_ParseHHMM(start_hhmm,a) || !Vegar_ParseHHMM(end_hhmm,b)) return false;
   if(a<=b) return (minute_of_day>=a && minute_of_day<b);
   return (minute_of_day>=a || minute_of_day<b);
  }

SVegarSessionStatus Vegar_CurrentSessionStatus()
  {
   SVegarSessionStatus s; ZeroMemory(s);
   s.server_time=TimeTradeServer();
   if(s.server_time<=0) s.server_time=TimeCurrent();
   s.ny_time=Vegar_ServerToNewYork(s.server_time);
   MqlDateTime dt; TimeToStruct(s.ny_time,dt);
   int mod=dt.hour*60+dt.min;

   bool london_window=(InpOperarLondon && Vegar_MinuteInWindow(mod,InpInicioLondonNY,InpFimLondonNY));
   bool ny_window=(InpOperarNewYork && Vegar_MinuteInWindow(mod,InpInicioNewYorkNY,InpFimNewYorkNY));
   s.london=london_window;
   s.new_york=ny_window;

   if(!InpAtivarFiltroDeSessao)
     {
      // Session filtering OFF means unrestricted trading time. The current
      // London/NY overlap may still be observed in telemetry, but it has no
      // authority to block execution.
      s.allowed=true;
      s.label="LIVRE";
      return s;
     }

   if(!InpOperarLondon && !InpOperarNewYork)
     {
      s.allowed=false;
      s.label="CONFIG_INVALID";
      return s;
     }

   s.allowed=(london_window || ny_window);
   if(london_window && ny_window) s.label="LONDON+NEW_YORK";
   else if(london_window) s.label="LONDON";
   else if(ny_window) s.label="NEW_YORK";
   else s.label="OFF_SESSION";
   return s;
  }

bool Vegar_SessionGateAllowsEntry(ENUM_VEGAR_REASON_CODE &reason,SVegarSessionStatus &status)
  {
   status=Vegar_CurrentSessionStatus();

   if(!InpAtivarFiltroDeSessao)
     {
      reason=VEGAR_REASON_NONE;
      return true;
     }

   if(!InpOperarLondon && !InpOperarNewYork)
     {
      reason=CONFIG_SESSION_INVALID;
      return false;
     }

   if(status.allowed)
     {
      reason=VEGAR_REASON_NONE;
      return true;
     }

   reason=SESSION_BLOCKED;
   return false;
  }

datetime Vegar_NewYorkTradingDayStartServer(const datetime server_now)
  {
   datetime utc=Vegar_ServerToUTC(server_now);
   datetime ny=Vegar_UTCToNewYork(utc);
   MqlDateTime n; TimeToStruct(ny,n);
   datetime ny_midnight=Vegar_MakeDateTime(n.year,n.mon,n.day,0,0,0);
   // Convert NY midnight to UTC using the DST state around local midday of the same date.
   datetime probe_utc=Vegar_MakeDateTime(n.year,n.mon,n.day,12,0,0)+5*3600;
   bool dst=Vegar_IsNewYorkDSTByUTC(probe_utc);
   datetime midnight_utc=ny_midnight+(dst?4*3600:5*3600);
   return midnight_utc+Vegar_CurrentServerUtcOffsetSeconds();
  }

string Vegar_TimeIso(const datetime t)
  {
   if(t<=0) return "";
   return TimeToString(t,TIME_DATE|TIME_SECONDS);
  }

#endif
