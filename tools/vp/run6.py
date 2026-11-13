import sys,time; sys.path.insert(0,'.')
exec(open('run4.py').read().split("A,B=")[0])
E='VantagePulse_B3_v1.05'
A,B='2026.10.13','2026.11.12'
fix={'ExecutionMode':'11','InpUseHardStop':'true','InpUseTakeProfit':'true','InpUseTrailing':'true','InpUseMaxHolding':'true','InpUseDailyLossLimit':'false','InpUseSpreadFilter':'true','InpHardStopPoints':'100','InpShowPanel':'false','InpEnableCSV':'false'}
for arm,dist,pct in ((40,10,40),(60,10,40),(40,10,25),(80,10,50)):
    o=dict(base); o.update(fix); o.update({'InpTrailArmPoints':str(arm),'InpTrailDistancePoints':str(dist),'InpTrailPeakPercent':str(pct)})
    r=None
    for k in range(3):
        r=run(E,o,A,B,deposit=700)
        if r: break
        time.sleep(8)
    show(f'recuo: arma {arm} pts, dist {dist}, {pct}% do pico',r)
    if r:
        d=r['days']; oc=sum(v for k,v in d.items() if k<'2026.11'); nv=sum(v for k,v in d.items() if k>='2026.11')
        print('   pts/op %.1f | out %.0f | nov %.0f | dias positivos %d/%d'%(r['net']/max(1,r['trades'])/0.2,oc,nv,sum(1 for v in d.values() if v>0),len(d)),flush=True)
