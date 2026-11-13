import sys; sys.path.insert(0,'.')
from vp_run import *
E='VantagePulse_B3_v1.04'
base={'InpVirtualStops':'true','InpEnableCSV':'false','InpShowPanel':'false','InpVerboseBlocks':'false','InpDiagnosticEveryMs':'0',
 'InpFastWindowMs':'1000','InpMidWindowMs':'3000','InpSlowWindowMs':'8000','InpMinFastMovePoints':'20','InpMinMidMovePoints':'32',
 'InpMaxHoldingSeconds':'25','InpTakeProfitPoints':'160','InpTrailArmPoints':'150'}
freq=dict(base); freq.update({'InpMinFastEfficiency':'0.12','InpMinDirectionalConsistency':'0.50','InpMinSignalScore':'34','InpMinMidRegimeEfficiency':'0.0','InpMinSlowRegimeEfficiency':'0.0','InpCooldownMs':'200','InpMinEntryGapMs':'200','InpMaxEntriesPerMinute':'20'})
A,B='2026.10.13','2026.11.12'
show('R0 melhor da bateria 1 (lote 1)',run(E,base,A,B))
show('R1 filtros soltos (lote 1)',run(E,freq,A,B))
l=dict(freq); l.update({'InpLadderEnable':'true','InpLadderLevels':'10','InpLadderStep':'1','InpDailyLossLimitMoney':'0'})
show('R2 filtros soltos + escada 1-10',run(E,l,A,B))
