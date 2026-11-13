"""BURST-contra com preco do ULTIMO NEGOCIO (last) e custo fixo de spread (COST pts por operacao): funciona nas duas bases
(WINZ26 com bid/ask e WIN$N so com last). Hipotese e parametros FIXOS (pre-registrados): N=10, thr=4, H=30, contra.
Mesma regra de aceite: media>0, t>=2 e >=55% dos dias positivos. Parte 1: reconferir no periodo de escolha (14/10-11/11).
Parte 2: fora da amostra (WIN$N, 01/06-13/10)."""
import glob, os, sys
import numpy as np
sys.path.insert(0, '.')
from study1 import DT, signals, trade, stats

COST = 5.5   # spread de ida e volta em pontos (medido: 5,35 em 14/10-11/11)

def load_last(path):
    a = np.fromfile(path, dtype=DT)
    day0 = (a['t'][0] // 86400000) * 86400000
    sec = ((a['t'] - day0) // 1000).astype(np.int64); S = 18 * 3600 + 1800
    valid = (a['last'] > 0)
    vidx = np.maximum.accumulate(np.where(valid, np.arange(len(a)), -1))
    idx = np.searchsorted(sec, np.arange(S + 1), side='right') - 1
    idx = np.where(idx >= 0, vidx[np.clip(idx, 0, None)], -1); ok = idx >= 0; idx = np.clip(idx, 0, None)
    p = a['last'][idx].astype(np.float64); p[~ok] = np.nan
    n = np.bincount(sec, minlength=S + 1)[:S + 1].astype(np.float64)
    nanv = np.zeros(S + 1)
    return dict(bid=p, ask=p.copy(), last=p, n=n, buy=nanv, sell=nanv, s0=9 * 3600 + 600, s1=17 * 3600 + 1800, name=os.path.basename(path)[9:17])

def evaluate(days, N=10, thr=4, H=30, mode=-1, label=''):
    res = []; per = []
    for d in days:
        x = trade(d, signals(d, 'BURST', N, thr), H, mode) - COST if True else None
        res.append(x); per.append(x.sum() if len(x) else 0.0)
    nd = sum(1 for r in res if len(r)); a = np.concatenate([r for r in res if len(r)])
    n, m, t = stats(a); pos = sum(p > 0 for p in per)
    return res, per, (n, m, t), pos, nd

def report(days, title):
    print('\n' + title)
    res, per, (n, m, t), pos, nd = evaluate(days)
    print('  PRINCIPAL N=10 thr=4 H=30 contra: ops %d | pts/op %+.2f | t %.2f | dias + %d/%d (%.0f%%) | R$/ctr %+.2f' % (n, m, t, pos, nd, 100 * pos / nd, 0.2 * m))
    ok = m > 0 and t >= 2 and pos / nd >= 0.55
    print('  ACEITE (media>0, t>=2, >=55%% dias +): %s' % ('ATENDIDO' if ok else 'NAO ATENDIDO'))
    mo = {}
    for d, r in zip(days, res):
        if len(r): mo.setdefault(d['name'][:6], []).append(r)
    for k in sorted(mo):
        x = np.concatenate(mo[k]); s = stats(x); print('    mes %s: ops %4d  pts/op %+7.2f  t %5.1f' % (k, s[0], s[1], s[2]))
    s_ = evaluate(days, mode=+1)[2]; print('  controle SEGUINDO a rajada: pts/op %+.2f (t %.1f)' % (s_[1], s_[2]))
    rng = np.random.default_rng(11); rr = []
    for d, r in zip(days, res):
        k = len(r)
        if not k: continue
        S = np.arange(d['s0'], d['s1'] - 32, 31); pick = rng.choice(S, size=min(k, len(S)), replace=False)
        sig = np.zeros(len(d['bid']), dtype=int); sig[pick] = rng.choice([-1, 1], size=len(pick))
        rr.append(trade(d, sig, 30, 1) - COST)
    rr = np.concatenate(rr); print('  controle ALEATORIO (mesma contagem): pts/op %+.2f (= custo do spread)' % rr.mean())
    print('  vizinhos (informativos):  N thr H -> pts/op (t) dias+')
    for N, thr, H in ((5, 4, 30), (5, 4, 60), (10, 4, 60), (20, 4, 30), (20, 4, 60), (10, 6, 30), (10, 3, 60)):
        r2, p2, s2, pos2, nd2 = evaluate(days, N, thr, H)
        print('      %2d %s %3d -> %+7.2f (t %4.1f)  ops %5d  dias+ %d/%d' % (N, thr, H, s2[1], s2[2], s2[0], pos2, nd2))
    return m, t, pos / nd

if __name__ == '__main__':
    ins = [load_last(f) for f in sorted(glob.glob(r'C:\VP_data\VP_ticks_*.bin'))]
    report(ins, 'PARTE 1: periodo de escolha, WINZ26 14/10-11/11 (preco = last)')
    oos = [load_last(f) for f in sorted(glob.glob(r'C:\VP_data_oos\VP_ticks_*.bin'))]
    print('\nOOS: %d dias, %s a %s' % (len(oos), oos[0]['name'], oos[-1]['name']))
    report(oos, 'PARTE 2: FORA DA AMOSTRA, WIN$N 01/06-13/10 (preco = last)')
