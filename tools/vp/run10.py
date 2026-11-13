import sys,time; sys.path.insert(0,'.')
src=open('run9.py').read().split("go('A)")[0]
exec(src)
go('F) positivo apos 25s; se negativo espera voltar ate 90s, 1 ctr',InpUseTimeProfitExit='true',InpTimeProfitSeconds=25,InpUseMaxHolding='true',InpMaxHoldingSeconds=90)
go('G) positivo apos 15s; se negativo espera voltar ate 90s, 1 ctr',InpUseTimeProfitExit='true',InpTimeProfitSeconds=15,InpUseMaxHolding='true',InpMaxHoldingSeconds=90)
