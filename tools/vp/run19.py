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
esperado={'LOTE1_STOP60_TP240':(9349,77023),'ESCADA1a10_STOP60_TP240':(9349,437498),'LOTE1_STOP100_TP160':(9528,51225),'ESCADA1a10_STOP100_TP160':(9528,271958)}
for name,(eo,en) in esperado.items():
    ov=kv(os.path.join(P,'VantagePulse_B3_v107_'+name+'.set')); ov.update({'InpEnableCSV':'false','InpShowPanel':'false'})
    r=None
    for k in range(3):
        r=run(E,ov,'2026.10.13','2026.11.12',deposit=700)
        if r: break
        time.sleep(8)
    ok = r and r['trades']==eo and abs(r['net']-en)<=0.02*abs(en)
    print('%-28s arquivo: ops %s net %s | apresentado antes: ops %d net %d | %s'%(name,r and r['trades'],r and round(r['net']),eo,en,'IGUAL' if ok else 'DIFERENTE'),flush=True)
print('FIM6',flush=True)
