import sys; sys.path.insert(0,'.')
import run12
from run12 import *
run12.A,run12.B='2026.10.13','2026.11.12'
print('--- COMBINACOES (30 dias) ---',flush=True)
go('1ctr-g) stop 80 pts + TP 240, tempo-lucro 25 s',InpStopType=1,InpStopPoints=80,InpTakeProfitPoints=240)
go('1ctr-h) stop 60 pts + TP 240, tempo-lucro 25 s',InpStopType=1,InpStopPoints=60,InpTakeProfitPoints=240)
L=dict(InpLadderEnable='true')
go('esc-g) stop 80 pts + TP 240, tempo-lucro 25 s',InpStopType=1,InpStopPoints=80,InpTakeProfitPoints=240,**L)
go('esc-h) stop 60 pts + TP 240, tempo-lucro 25 s',InpStopType=1,InpStopPoints=60,InpTakeProfitPoints=240,**L)
print('FIM2',flush=True)
