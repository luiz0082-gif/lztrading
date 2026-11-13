import sys,re,os,time; sys.path.insert(0,'.')
from vp_run import *
P=os.path.expandvars(r'%APPDATA%\MetaQuotes\Terminal\698B86206820B42976F30D28CAC50412\MQL5\Presets\VantagePulse_B3_v107_LOTE1_STOP80_TP240.set')
def kv(path):
    d={}
    for l in read16(path).splitlines():
        m=re.match(r'^(Inp\w+)=([^|\r\n]*)',l)
        if m: d[m.group(1)]=m.group(2).strip()
    return d
for lab,extra in (('painel+CSV DESLIGADOS (como eu rodo)',{'InpEnableCSV':'false','InpShowPanel':'false'}),('painel+CSV LIGADOS (como voce roda)',{})):
    ov=kv(P); ov.update(extra); ov['ExecutionMode']='12'
    r=None
    for k in range(3):
        r=run('VantagePulse_B3_v1.07',ov,'2026.10.13','2026.10.20',deposit=700)
        if r: break
        time.sleep(8)
    print('%-40s ops %d liquido %.0f | por dia %s'%(lab,r['trades'],r['net'],{k[5:]:round(v) for k,v in sorted(r['days'].items())}),flush=True)
print('FIM10',flush=True)
