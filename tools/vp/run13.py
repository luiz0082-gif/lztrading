import sys; sys.path.insert(0,'.')
from run12 import *
go('N4) stop 100 pts, tempo no lucro 40 s, 1 ctr',InpTimeExitSeconds=40)
go('N5) stop 100 pts, tempo no lucro 60 s, 1 ctr',InpTimeExitSeconds=60)
go('N6) stop 150 pts, tempo no lucro 25 s, 1 ctr',InpStopPoints=150)
go('L1) ESCADA 1-10, stop 100 pts, tempo no lucro 25 s',InpLadderEnable='true')
go('L2) ESCADA 1-10, stop R$150 (posicao inteira), tempo no lucro 25 s',InpLadderEnable='true',InpStopType=2,InpStopMoney=150)
go('L3) ESCADA 1-10, stop R$300 (posicao inteira), tempo no lucro 25 s',InpLadderEnable='true',InpStopType=2,InpStopMoney=300)
