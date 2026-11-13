import sys; sys.path.insert(0,'.')
from vp_run import *
E='VantagePulse_B3_v1.04'
base={'InpVirtualStops':'true','InpEnableCSV':'false','InpShowPanel':'false','InpVerboseBlocks':'false','InpDiagnosticEveryMs':'0',
 'InpFastWindowMs':'1000','InpMidWindowMs':'3000','InpSlowWindowMs':'8000','InpMinFastMovePoints':'20','InpMinMidMovePoints':'32',
 'InpMaxHoldingSeconds':'25','InpTakeProfitPoints':'160','InpTrailArmPoints':'150','InpMinFastEfficiency':'0.12','InpMinDirectionalConsistency':'0.50',
 'InpMinSignalScore':'34','InpMinMidRegimeEfficiency':'0.0','InpMinSlowRegimeEfficiency':'0.0','InpCooldownMs':'200','InpMinEntryGapMs':'200',
 'InpMaxEntriesPerMinute':'20','ExecutionMode':'12','InpLots':'1.0','InpLadderEnable':'false','InpLadderLevels':'10','InpLadderStep':'1.0',
 'InpDailyLossLimitMoney':'0','InpIncludeFloatingInDaily':'false'}
A,B='2026.10.13','2026.11.12'
def pr(l,r):
    show(l,r)
    if r:
        d=r['days']; print('   pts/op %.1f | dias %d, positivos %d, pior dia %.0f, melhor dia %.0f' % (r['net']/max(1,r['trades'])/0.2, len(d), sum(1 for v in d.values() if v>0), min(d.values()), max(d.values())), flush=True)
o=dict(base); pr('1) lote 1 FIXO, R$20k',run(E,o,A,B))
o=dict(base); o['InpLadderEnable']='true'; pr('2) escada 1-10, R$700, sem limite diario',run(E,o,A,B,deposit=700))
o=dict(base); o['InpLadderEnable']='true'; o['InpDailyLossLimitMoney']='300'; pr('3) escada 1-10, R$700, limite diario R$300',run(E,o,A,B,deposit=700))
