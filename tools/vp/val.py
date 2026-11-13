import sys,re,os,time; sys.path.insert(0,'.')
from vp_run import *
P=os.path.expandvars(r'%APPDATA%\MetaQuotes\Terminal\698B86206820B42976F30D28CAC50412\MQL5\Presets\VantagePulse_B3_v107_LOTE1_STOP80_TP240.set')
ov={}
for l in read16(P).splitlines():
    m=re.match(r'^(Inp\w+)=([^|\r\n]*)',l)
    if m: ov[m.group(1)]=m.group(2).strip()
ov.update({'InpEnableCSV':'false','InpShowPanel':'false','ExecutionMode':'12'})
r=None
for k in range(3):
    r=run('VantagePulse_B3_v1.07',ov,'2026.10.13','2026.11.02',deposit=700)
    if r: break
    time.sleep(8)
d=r['days']
print('HARNESS c/ base do usuario: ops %d liquido %.0f | dias positivos %d/%d | %s'%(r['trades'],r['net'],sum(1 for v in d.values() if v>0),len(d),{k[5:]:round(v) for k,v in sorted(d.items())}),flush=True)
print('PLATAFORMA DO USUARIO:      ops 11142 liquido 43639 | dias positivos 9/14')
