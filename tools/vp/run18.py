import sys,re,os,time; sys.path.insert(0,'.')
import run12
from vp_run import *
E=run12.E
def kv(path):
    t=open(path,'rb').read().decode('utf-16'); d={}
    for l in t.splitlines():
        m=re.match(r'^(Inp\w+)=([^|\r\n]*)',l)
        if m: d[m.group(1)]=m.group(2).strip()
    return d
P=os.path.expandvars(r'%APPDATA%\MetaQuotes\Terminal\698B86206820B42976F30D28CAC50412\MQL5\Presets')
def go(name):
    ov=kv(os.path.join(P,'VantagePulse_B3_v107_'+name+'.set')); ov.update({'InpEnableCSV':'false','InpShowPanel':'false','ExecutionMode':'12'})
    r=None
    for k in range(3):
        r=run(E,ov,'2026.10.13','2026.11.02',deposit=700)
        if r: break
        time.sleep(8)
    show('ARQUIVO '+name,r)
    if r: d=r['days']; print('   dias positivos %d/%d | liquido por dia: %s'%(sum(1 for v in d.values() if v>0),len(d),{k[5:]:round(v) for k,v in sorted(d.items())}),flush=True)
go('LOTE1_STOP80_TP240'); go('ESCADA1a10_STOP80_TP240')
print('FIM5',flush=True)
