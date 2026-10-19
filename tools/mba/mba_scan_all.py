#!/usr/bin/env python3
"""Varredura completa de horários (grade M15, hora do servidor) x lado x alvo; saída no alvo ou 23:30, sem stop.
Custo = spread medido nos ticks (perfil por meia hora de NY), cobrado na vela de saída. Validação cronológica 60/40, anos, placebo (embaralha horários dentro do dia).

  python tools/mba/mba_scan_all.py --symbol XBRUSD --targets 100,150,200,300,400,500
"""
import argparse, math, sys, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r, mba_slots as sl
sys.stdout.reconfigure(encoding='utf-8')
ap = argparse.ArgumentParser()
ap.add_argument('--symbol', required=True); ap.add_argument('--targets', required=True); ap.add_argument('--broker', default='Raw_Trading_Ltd')
ap.add_argument('--last-entry', default='22:00'); ap.add_argument('--out', default='docs/relatorios/mba/scan_all/')
ap.add_argument('--placebos', type=int, default=20); ap.add_argument('--min-last', default='23:15', help='última vela mínima do dia (mercados que fecham antes)')
a = ap.parse_args()
TG = [int(x) for x in a.targets.split(',')]
LIVE = f"C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/{a.broker}/{a.symbol}/LIVE"
import os; os.makedirs(a.out, exist_ok=True)
spec = pd.read_csv(LIVE + '/META/symbol_spec_part001.csv').iloc[-1]; PT = float(spec['point'])
s5, prof = sl.cost_model(LIVE)
cd = r.load_candles(LIVE, 'M15'); cd = cd[cd.open.notna()].reset_index(drop=True)
cd['day'] = cd.t.dt.normalize(); cd['hm'] = cd.t.dt.strftime('%H:%M')
pf = prof.reindex(r.slot30(cd['u'])).to_numpy(float); pf = np.where(np.isfinite(pf), pf, np.nanmedian(pf))
cd['sp'] = pf
cd = cd[cd.hm <= '23:15']
days = []; slots = [f"{h:02d}:{m:02d}" for h in range(0, 24) for m in (0, 15, 30, 45) if f"{h:02d}:{m:02d}" <= a.last_entry]
SI = {s: i for i, s in enumerate(slots)}
D = []
for d, g in cd.groupby('day'):
    if d.weekday() >= 5 or len(g) < 60 or g.hm.iloc[-1] < a.min_last: continue
    D.append((d, g))
nd, ns, nt = len(D), len(slots), len(TG)
RES = np.full((nd, ns, 2, nt), np.nan); HIT = np.zeros((nd, ns, 2, nt), bool); MAE = np.full((nd, ns, 2, nt), np.nan); MIN = np.full((nd, ns, 2, nt), np.nan)
for di, (d, g) in enumerate(D):
    hm = g.hm.values; o = g.open.values; h = g.high.values; l = g.low.values; c = g.close.values; sp = g.sp.values * PT; n = len(g)
    for i in range(n):
        if hm[i] > a.last_entry: break
        s = SI[hm[i]]
        for sd in (0, 1):                       # 0 = compra, 1 = venda
            for ti, T in enumerate(TG):
                if sd == 0:
                    ok = h[i:] >= o[i] + sp[i] + T * PT; adv = np.minimum.accumulate(l[i:])
                else:
                    ok = (l[i:] + sp[i:]) <= o[i] - T * PT; adv = np.maximum.accumulate(h[i:])
                if ok.any():
                    j = int(ok.argmax()); RES[di, s, sd, ti] = T; HIT[di, s, sd, ti] = True; MIN[di, s, sd, ti] = 15 * (j + 1)
                    MAE[di, s, sd, ti] = (o[i] - adv[j]) / PT if sd == 0 else (adv[j] - o[i]) / PT
                else:
                    RES[di, s, sd, ti] = ((c[-1] - o[i] - sp[i]) / PT) if sd == 0 else ((o[i] - c[-1] - sp[-1]) / PT)
                    MAE[di, s, sd, ti] = (o[i] - adv[-1]) / PT if sd == 0 else (adv[-1] - o[i]) / PT
dates = np.array([d for d, _ in D]); cut = int(nd * 0.6); yrs = np.array([d.year for d in dates])


def wil(k, n, z=1.96):
    if n == 0: return 0.0
    p = k / n; return (p + z * z / (2 * n) - z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))) / (1 + z * z / n)


def metrics(RES, HIT, MAE, MIN, with_extra=True):
    out = []
    for s in range(ns):
        for sd in (0, 1):
            for ti, T in enumerate(TG):
                x = RES[:, s, sd, ti]; ok = np.isfinite(x)
                if ok.sum() < 300: continue
                hit = HIT[:, s, sd, ti]; xs = x[ok]; hs = hit[ok]; ds = np.where(ok)[0]
                d_ = ds < cut; v_ = ~d_
                if d_.sum() < 100 or v_.sum() < 100: continue
                nh = ~hs; loss = xs[nh].mean() if nh.any() else 0.0
                ypos = all(xs[yrs[ds] == y].mean() > 0 for y in np.unique(yrs[ds]))
                row = dict(slot=slots[s], lado='COMPRA' if sd == 0 else 'VENDA', alvo=T, n=int(ok.sum()), pct=100 * hs.mean(), wilson=100 * wil(int(hs.sum()), len(hs)),
                           pct_desc=100 * hs[d_].mean(), pct_val=100 * hs[v_].mean(), media=xs.mean(), media_desc=xs[d_].mean(), media_val=xs[v_].mean(), todos_anos_pos=ypos)
                if with_extra:
                    mm = MAE[:, s, sd, ti][ok]; mn = MIN[:, s, sd, ti][ok]
                    row.update(n_sem_alvo=int(nh.sum()), perda_media=loss, pior=xs.min(), mae_medio=mm.mean(), mae_p90=np.percentile(mm, 90),
                               nec=100 * (-loss) / (T - loss) if loss < 0 else 0.0, min_med=float(np.nanmedian(mn[hs])) if hs.any() else np.nan,
                               anos=''.join('+' if xs[yrs[ds] == y].mean() > 0 else '-' for y in np.unique(yrs[ds])))
                out.append(row)
    return pd.DataFrame(out)


A = metrics(RES, HIT, MAE, MIN)
A.to_csv(a.out + f'{a.symbol}_todos.csv', index=False)
passf = lambda X: X[(X.media_desc > 0) & (X.media_val > 0) & X.todos_anos_pos]
real = len(passf(A))
# placebo: embaralha os horários dentro de cada dia (mantém lado/alvo juntos)
rng = np.random.default_rng(7); pc = []; pr = []
for k in range(a.placebos):
    P = [np.empty_like(RES), np.empty_like(HIT), np.empty_like(MAE), np.empty_like(MIN)]
    for di in range(nd):
        perm = rng.permutation(ns)
        for arr, src in zip(P, (RES, HIT, MAE, MIN)): arr[di] = src[di][perm]
    Mp = metrics(*P, with_extra=True); pc.append(len(passf(Mp))); pr.append(len(passf(Mp)[passf(Mp).wilson > passf(Mp).nec]))
print(f'{a.symbol}: {nd} dias úteis {dates[0].date()}..{dates[-1].date()} | ponto {PT} | alvos {TG} | combinações {len(A)}')
PA = passf(A); rob = int((PA.wilson > PA.nec).sum())
print(f'passam (média>0 nos 2 trechos e em todos os anos): real {real} | placebo média {np.mean(pc):.1f} máx {max(pc)}')
print(f'robustas (passam E Wilson 95% > % necessário p/ empatar): real {rob} | placebo média {np.mean(pr):.1f} máx {max(pr)} ({pr})')
base = A.groupby(['lado', 'alvo'])[['pct', 'media']].mean().round(1); print(base)
import json
json.dump(dict(symbol=a.symbol, min_last=a.min_last, contract=float(spec['contract_size']), usd_pt=float(spec['tick_value']) * PT / float(spec['tick_size']) if 'tick_size' in spec.index else PT * float(spec['contract_size']), dias=nd, ini=str(dates[0].date()), fim=str(dates[-1].date()), point=PT, spread=float(np.nanmedian(pf)), targets=TG, combos=int(len(A)), real=int(real), pl_med=float(np.mean(pc)), pl_max=int(max(pc)), rob=int(rob), pr_med=float(np.mean(pr)), pr_max=int(max(pr)), placebos=a.placebos, atr=float(np.nanmedian(cd['atr'].to_numpy(float) / PT))), open(a.out + f'{a.symbol}_resumo.json', 'w'))
np.savez_compressed(a.out + f'{a.symbol}_raw.npz', RES=RES, HIT=HIT, MAE=MAE, MIN=MIN, dates=dates.astype('datetime64[D]'), slots=np.array(slots), targets=np.array(TG))
pd.set_option('display.width', 250); pd.set_option('display.max_columns', 30)
cols = ['slot', 'lado', 'alvo', 'n', 'pct', 'wilson', 'pct_desc', 'pct_val', 'media', 'media_desc', 'media_val', 'n_sem_alvo', 'perda_media', 'pior', 'mae_medio', 'nec', 'min_med', 'anos']
P_ = passf(A); P_ = P_[P_.wilson > P_.nec].sort_values('media', ascending=False)
print('--- ROBUSTAS ---')
print(P_[cols].head(40).round(1).to_string(index=False))
print('positivos nos dois trechos:', ((A.media_desc > 0) & (A.media_val > 0)).sum(), '| média>0 total:', (A.media > 0).sum(), '/', len(A))
