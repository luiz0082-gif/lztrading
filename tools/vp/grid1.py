import sys, itertools, json, time; sys.path.insert(0,'.')
from vp_run import *
E='VantagePulse_B3_v1.03'
base={'InpVirtualStops':'true','InpEnableCSV':'false','InpShowPanel':'false','InpVerboseBlocks':'false','InpDiagnosticEveryMs':'0'}
wins={'curta':{'InpFastWindowMs':'350','InpMidWindowMs':'1200','InpSlowWindowMs':'3000'},
      'longa':{'InpFastWindowMs':'1000','InpMidWindowMs':'3000','InpSlowWindowMs':'8000'}}
res=[]
t0=time.time()
for w,mv,hold,tp in itertools.product(('curta','longa'),(5,20,40,60),(25,90),(80,160)):
    ov=dict(base); ov.update(wins[w]); ov.update({'InpMinFastMovePoints':str(mv),'InpMinMidMovePoints':str(max(8,mv*1.6)),'InpMaxHoldingSeconds':str(hold),'InpTakeProfitPoints':str(tp),'InpTrailArmPoints':str(tp-10)})
    r=run(E,ov,'2026.10.13','2026.11.01')
    lab=f'{w} mv{mv} hold{hold} tp{tp}'
    if r:
        pts=r['net']/max(1,r['trades'])/0.2
        print(f"{lab}: ops {r['trades']} net {r['net']:.0f} pts/op {pts:.1f} PF {r['pf']:.2f} acerto {r['win']:.0f}% DD {r['dd']:.0f} ({time.time()-t0:.0f}s)", flush=True)
        res.append((lab,r['trades'],r['net'],pts,r['pf']))
    else: print(lab,'SEM RELATORIO',flush=True)
json.dump(res,open('grid1.json','w'))
