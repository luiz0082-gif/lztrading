"""Robustez da familia BURST-contra (fade de rajadas de atividade) nos 20 dias reais (14/10-11/11):
vizinhanca de parametros, resultado por dia, hora do dia e custo de equilibrio. Nada novo e escolhido aqui."""
import glob, sys
import numpy as np
sys.path.insert(0, '.')
from study1 import load_day, signals, trade, stats

files = sorted(glob.glob(r'C:\VP_data\VP_ticks_*.bin'))
days = [load_day(f) for f in files]
print('dias:', len(days))
print('\nVIZINHANCA (todos os 20 dias; pts liquidos do spread por operacao; t) | BURST contra')
print('   N  thr   H |   ops   pts/op     t | dias positivos | R$/contrato (antes de corretagem)')
for N in (5, 10, 20):
    for thr in (3, 4, 6):
        for H in (15, 30, 60):
            res = []; per = []
            for d in days:
                x = trade(d, signals(d, 'BURST', N, thr), H, -1); res.append(x); per.append(x.sum() if len(x) else 0.0)
            a = np.concatenate(res); n, m, t = stats(a)
            print('%4d %4s %3d | %6d %+8.2f %6.1f | %2d/20 | %+6.2f' % (N, thr, H, n, m, t, sum(p > 0 for p in per), 0.2 * m))
print('\nPOR DIA (N=10, thr=4, H=30): pts por operacao e n')
for d in days:
    x = trade(d, signals(d, 'BURST', 10, 4), 30, -1)
    print('  %s ops %3d  pts/op %+7.1f' % (d['name'], len(x), x.mean() if len(x) else 0))
print('\nPOR HORA (N=10, thr=4, H=30), todos os dias')
by = {}
for d in days:
    sig = signals(d, 'BURST', 10, 4)
    bid, ask = d['bid'], d['ask']; s1 = d['s1'] - 31; nxt = -1
    for i in np.nonzero(sig[:s1] != 0)[0]:
        if i < d['s0'] or i < nxt: continue
        dirn = -int(sig[i])
        if np.isnan(bid[i + 1]) or np.isnan(bid[i + 31]): continue
        r = (bid[i + 31] - ask[i + 1]) if dirn > 0 else (bid[i + 1] - ask[i + 31])
        by.setdefault(i // 3600, []).append(r); nxt = i + 31
for h in sorted(by):
    x = np.array(by[h]); print('  %02dh ops %4d  pts/op %+7.2f' % (h, len(x), x.mean()))
