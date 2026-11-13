import sys,re,os,time; sys.path.insert(0,'.')
from vp_run import *
P=os.path.expandvars(r'%APPDATA%\MetaQuotes\Terminal\698B86206820B42976F30D28CAC50412\MQL5\Presets')
def kv(path):
    d={}
    for l in read16(path).splitlines():
        m=re.match(r'^(Inp\w+)=([^|\r\n]*)',l)
        if m: d[m.group(1)]=m.group(2).strip()
    return d
for name in ('v106_LOTE1_DINHEIRO_R20','v106_ESCADA1a10_STOP100'):
    ov=kv(os.path.join(P,'VantagePulse_B3_'+name+'.set')); ov.update({'InpEnableCSV':'false','InpShowPanel':'false','ExecutionMode':'12'})
    r=None
    for k in range(3):
        r=run('VantagePulse_B3_v1.06',ov,'2026.10.13','2026.11.04',deposit=700)
        if r: break
        time.sleep(8)
    d=r['days']; print('%-28s dias positivos %d/%d | pior dia %.0f | saldo minimo %.0f'%(name,sum(1 for v in d.values() if v>0),len(d),min(d.values()),r['minbal']),flush=True)
print('FIM8',flush=True)
