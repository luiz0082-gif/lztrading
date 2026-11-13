import sys,time; sys.path.insert(0,'.')
exec(open('run4.py').read().split("A,B=")[0])
E='VantagePulse_B3_v1.06'
A,B='2026.10.13','2026.11.04'
fix={'ExecutionMode':'11','InpUseHardStop':'true','InpHardStopPoints':'100','InpUseMoneyStop':'false','InpMoneyStopAmount':'150','InpUseTakeProfit':'true','InpUseTrailing':'true','InpUseDailyLossLimit':'false','InpUseSpreadFilter':'true','InpShowPanel':'false','InpEnableCSV':'false','InpTrailArmPoints':'40','InpTrailDistancePoints':'10','InpTrailPeakPercent':'40','InpLadderEnable':'false','InpUseTimeProfitExit':'false','InpTimeProfitSeconds':'8','InpTimeProfitMinPoints':'5','InpUseMaxHolding':'true'}
def go(lab,**kw):
    o=dict(base); o.update(fix); o.update({k:str(v) for k,v in kw.items()})
    r=None
    for k in range(3):
        r=run(E,o,A,B,deposit=700)
        if r: break
        time.sleep(8)
    show(lab,r)
    if r:
        d=r['days']; print('   pts/op %.1f | dias %d positivos %d | pior dia %.0f'%(r['net']/max(1,r['trades'])/0.2,len(d),sum(1 for v in d.values() if v>0),min(d.values())),flush=True)
go('A) v1.06 com tudo novo DESLIGADO, 1 ctr (ref v1.05: 8497 ops, +56766)')
go('B) tempo no positivo 8s + hold 25s, 1 ctr',InpUseTimeProfitExit='true')
go('C) tempo no positivo 8s, SEM hold maximo, 1 ctr',InpUseTimeProfitExit='true',InpUseMaxHolding='false')
go('D) C com escada 1-10',InpUseTimeProfitExit='true',InpUseMaxHolding='false',InpLadderEnable='true')
go('E) stop em DINHEIRO R$150 (sem stop em pontos) + tempo positivo, sem hold, escada 1-10',InpUseHardStop='false',InpUseMoneyStop='true',InpUseTimeProfitExit='true',InpUseMaxHolding='false',InpLadderEnable='true')
