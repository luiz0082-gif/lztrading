import sys,time; sys.path.insert(0,'.')
exec(open('run4.py').read().split("A,B=")[0])
E='VantagePulse_B3_v1.05'
A,B='2026.10.13','2026.11.04'
fix={'ExecutionMode':'11','InpUseHardStop':'true','InpUseTakeProfit':'true','InpUseTrailing':'true','InpUseMaxHolding':'true','InpUseDailyLossLimit':'false','InpUseSpreadFilter':'true','InpShowPanel':'false','InpEnableCSV':'false','InpTrailArmPoints':'40','InpTrailDistancePoints':'10','InpTrailPeakPercent':'40'}
for sl,lab in (('100','stop 100 pts'),('150','stop 150 pts'),('750','stop 750 pts (= R$150 com 1 contrato)')):
    o=dict(base); o.update(fix); o['InpHardStopPoints']=sl; o['InpLadderEnable']='true'; o['InpLadderLevels']='10'; o['InpLadderStep']='1.0'
    r=None
    for k in range(3):
        r=run(E,o,A,B,deposit=700)
        if r: break
        time.sleep(8)
    show(lab,r)
    if r:
        d=r['days']; print('   pts/op %.1f | dias %d positivos %d | pior dia %.0f'%(r['net']/max(1,r['trades'])/0.2,len(d),sum(1 for v in d.values() if v>0),min(d.values())),flush=True)
