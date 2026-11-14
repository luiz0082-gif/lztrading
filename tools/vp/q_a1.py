WIN = ('2026.10.16', '2026.10.23')
DEP = 50000
L = {'InpLadderEnable': 'false'}
def c(lbl, **k): d = dict(L); d.update({a: str(b) for a, b in k.items()}); return (lbl, d)
CONFIGS = [
 c('ref 1ctr (ladder off)'),
 c('TP80', InpTakeProfitPoints=80),
 c('TP400', InpTakeProfitPoints=400),
 c('stop 100pts', InpStopType=1, InpStopPoints=100),
 c('stop 300pts', InpStopType=1, InpStopPoints=300),
 c('sem stop', InpStopType=0),
 c('sem tempo', InpUseTimeExit='false'),
 c('tempo 60s', InpTimeExitSeconds=60),
 c('sem trailing', InpUseTrailing='false'),
 c('sem saida oposta', InpUseOppositeSignalExit='false'),
 c('score 85', InpMinSignalScore=85),
 c('fast move 80', InpMinFastMovePoints=80),
 c('cooldown 3000', InpCooldownMs=3000),
 c('max 3/min', InpMaxEntriesPerMinute=3),
]
