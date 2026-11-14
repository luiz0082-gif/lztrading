WIN = ('2026.10.14', '2026.11.12')
DEP = 50000
L = {'InpLadderEnable': 'false', 'InpStopType': '0'}
CONFIGS = [('MES sem stop+tempo60', dict(L, InpTimeExitSeconds='60')),
           ('MES sem stop+sem tempo', dict(L, InpUseTimeExit='false'))]
