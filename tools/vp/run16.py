import sys,time; sys.path.insert(0,'.')
import run12
from run12 import *
def hr(label,**kw):
    o=dict(base); o.update({k:str(v) for k,v in kw.items()})
    r=None
    for k in range(3):
        r=run(run12.E,o,'2026.10.13','2026.11.12',deposit=700)
        if r: break
        time.sleep(8)
    print('=====',label,'| liquido %.0f ops %d'%(r['net'],r['trades']),flush=True)
    for h in sorted(r['hours']):
        n,t,w=r['hours'][h]; print('  %sh  liquido %9.0f  ops %5d  acerto %2.0f%%  por op %6.1f'%(h,n,t,100*w/t,n/t),flush=True)
hr('1 CONTRATO, stop 80, alvo 240',InpStopType=1,InpStopPoints=80,InpTakeProfitPoints=240)
hr('ESCADA 1-10, stop 80, alvo 240',InpStopType=1,InpStopPoints=80,InpTakeProfitPoints=240,InpLadderEnable='true')
print('FIM3',flush=True)
