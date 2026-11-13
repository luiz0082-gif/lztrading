import sys; sys.path.insert(0,'.')
from vp_run import *
E='VantagePulse_B3_v1.04'
base={'InpVirtualStops':'true','InpEnableCSV':'false','InpShowPanel':'false','InpVerboseBlocks':'false','InpDiagnosticEveryMs':'0',
 'InpFastWindowMs':'1000','InpMidWindowMs':'3000','InpSlowWindowMs':'8000','InpMinFastMovePoints':'20','InpMinMidMovePoints':'32',
 'InpMaxHoldingSeconds':'25','InpTakeProfitPoints':'160','InpTrailArmPoints':'150','InpMinFastEfficiency':'0.12','InpMinDirectionalConsistency':'0.50',
 'InpMinSignalScore':'34','InpMinMidRegimeEfficiency':'0.0','InpMinSlowRegimeEfficiency':'0.0','InpCooldownMs':'200','InpMinEntryGapMs':'200',
 'InpMaxEntriesPerMinute':'20','InpDailyLossLimitMoney':'0'}
A,B='2026.10.13','2026.11.12'
def pr(l,r):
    show(l,r)
    if r: print('   pts/op (lote medio): %.1f | dias %d positivos %d' % (r['net']/max(1,r['trades'])/0.2, len(r['days']), sum(1 for v in r['days'].values() if v>0)), flush=True)
for em in ('0','12','60'):
    o=dict(base); o['ExecutionMode']=em
    pr(f'lote1 fixo, atraso {em}ms',run(E,o,A,B))
l=dict(base); l.update({'InpLadderEnable':'true','ExecutionMode':'12'})
pr('escada 1-10, atraso 12ms',run(E,l,A,B))
