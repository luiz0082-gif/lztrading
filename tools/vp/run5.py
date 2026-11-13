import sys,time; sys.path.insert(0,'.')
exec(open('run4.py').read().split("A,B=")[0])
A,B='2026.10.13','2026.11.12'
for sl in ('100','150'):
    for lad in ('false','true'):
        o=dict(base); o['ExecutionMode']='11'; o['InpHardStopPoints']=sl; o['InpLadderEnable']=lad
        r=None
        for k in range(3):
            r=run(E,o,A,B,deposit=700)
            if r: break
            time.sleep(8)
        lab=f"stop {sl} pts, {'COM escada 1-10' if lad=='true' else 'SEM escada (1 ctr)'}, R$700"
        show(lab,r)
        if r:
            d=r['days']; print('   dias %d, positivos %d, pior dia %.0f, melhor dia %.0f' % (len(d),sum(1 for v in d.values() if v>0),min(d.values()),max(d.values())),flush=True)
