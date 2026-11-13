import sys,time; sys.path.insert(0,'.')
from vp_run import *
E='VantagePulse_B3_v1.07'
base={'InpEnableCSV':'false','InpShowPanel':'false','InpVerboseBlocks':'false','InpDiagnosticEveryMs':'0','InpVirtualStops':'true',
 'InpFastWindowMs':'1000','InpMidWindowMs':'3000','InpSlowWindowMs':'8000','InpMinFastMovePoints':'20','InpMinMidMovePoints':'32',
 'InpMinFastEfficiency':'0.12','InpMinDirectionalConsistency':'0.50','InpMinSignalScore':'34','InpMinMidRegimeEfficiency':'0.0','InpMinSlowRegimeEfficiency':'0.0',
 'InpCooldownMs':'200','InpMinEntryGapMs':'200','InpMaxEntriesPerMinute':'20','ExecutionMode':'12','InpUseTakeProfit':'true','InpTakeProfitPoints':'160',
 'InpUseTrailing':'true','InpTrailArmPoints':'40','InpTrailDistancePoints':'10','InpTrailPeakPercent':'40','InpUseDailyLossLimit':'false','InpUseSpreadFilter':'true',
 'InpLots':'1.0','InpLadderEnable':'false','InpLadderLevels':'10','InpLadderStep':'1.0','InpStopType':'1','InpStopPoints':'100','InpStopMoney':'150',
 'InpUseTimeExit':'true','InpTimeExitSeconds':'25','InpTimeExitMinPoints':'5.0'}
A,B='2026.10.13','2026.11.04'
def go(lab,**kw):
    o=dict(base); o.update({k:str(v) for k,v in kw.items()})
    r=None
    for k in range(3):
        r=run(E,o,A,B,deposit=700)
        if r: break
        time.sleep(8)
    show(lab,r)
    if r:
        d=r['days']; print('   pts/op %.1f | dias %d positivos %d | pior dia %.0f | maior posicao aberta %s'%(r['net']/max(1,r['trades'])/0.2,len(d),sum(1 for v in d.values() if v>0),min(d.values()),r.get('maxhold','?')),flush=True)
if __name__=='__main__':
    go('N1) stop 100 pts, tempo no lucro 25 s, 1 ctr',InpTimeExitSeconds=25)
    go('N2) stop 100 pts, tempo no lucro 10 s, 1 ctr',InpTimeExitSeconds=10)
    go('N3) stop 100 pts, tempo no lucro 5 s, 1 ctr',InpTimeExitSeconds=5)
