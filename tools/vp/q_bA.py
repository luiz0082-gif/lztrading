WIN = ('2026.10.16', '2026.10.23')
DEP = 50000
L = {'InpLadderEnable': 'false', 'InpStopType': '0'}
def c(lbl, **k): d = dict(L); d.update({a: str(b) for a, b in k.items()}); return (lbl, d)
CONFIGS = [
 c('sem stop'),
 c('sem stop+fast80', InpMinFastMovePoints=80),
 c('sem stop+tempo60', InpTimeExitSeconds=60),
 c('sem stop+sem tempo', InpUseTimeExit='false'),
 c('sem stop+TP400', InpTakeProfitPoints=400),
 c('sem stop+fast80+score85', InpMinFastMovePoints=80, InpMinSignalScore=85),
 c('sem stop+sem trailing', InpUseTrailing='false'),
 c('sem stop+fast80+tempo60', InpMinFastMovePoints=80, InpTimeExitSeconds=60),
]
