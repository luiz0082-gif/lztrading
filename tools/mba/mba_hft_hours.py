#!/usr/bin/env python3
"""XAUUSD: horários com movimento para EAs HFT/scalping de recuo (impulso >= 100 pts, recuo até ~80 pts).
Zigzag por dia (reversão mínima REV pts) sobre M1 (ordem intra-vela por direção da vela); métricas por hora do servidor."""
import sys, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r
sys.stdout.reconfigure(encoding='utf-8')
R = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/Raw_Trading_Ltd/XAUUSD/LIVE"
PT = 0.01
TF = sys.argv[1] if len(sys.argv) > 1 else 'M1'
REV = 40          # reversão mínima para registrar um recuo (pts)
IMP = 100         # impulso mínimo (pts)
d = r.load_candles(R, TF).sort_values('t').reset_index(drop=True)
d = d[d.open.notna() & (d.t >= '2025-05-15' if TF == 'M5' else d.t >= '2026-01-01')].reset_index(drop=True)
d['day'] = d.t.dt.normalize(); d['h'] = d.t.dt.hour
# spread medido nos ticks (média por vela), por hora do servidor
sp = d.groupby('h').spread_avg_points.median() if 'spread_avg_points' in d else None

legs = []   # (dia, hora do fim, tamanho, direção)
for day, g in d.groupby('day'):
    if len(g) < 200 and TF == 'M1': continue
    pts = []
    for t, o, h, l, c in zip(g.t.values, g.open.values, g.high.values, g.low.values, g.close.values):
        if c >= o: pts += [(t, l), (t, h)]
        else: pts += [(t, h), (t, l)]
    # zigzag
    piv_p = pts[0][1]; piv_t = pts[0][0]; ext_p = piv_p; ext_t = piv_t; dirn = 0
    for t, p in pts[1:]:
        if dirn >= 0 and p > ext_p: ext_p, ext_t = p, t
        elif dirn <= 0 and p < ext_p: ext_p, ext_t = p, t
        if dirn == 0:
            if p - piv_p >= REV * PT: dirn = 1; ext_p, ext_t = p, t
            elif piv_p - p >= REV * PT: dirn = -1; ext_p, ext_t = p, t
            continue
        if dirn == 1 and ext_p - p >= REV * PT:
            legs.append((day, pd.Timestamp(ext_t).hour, (ext_p - piv_p) / PT, 1)); piv_p, piv_t = ext_p, ext_t; ext_p, ext_t = p, t; dirn = -1
        elif dirn == -1 and p - ext_p >= REV * PT:
            legs.append((day, pd.Timestamp(ext_t).hour, (piv_p - ext_p) / PT, -1)); piv_p, piv_t = ext_p, ext_t; ext_p, ext_t = p, t; dirn = 1
L = pd.DataFrame(legs, columns=['day', 'h', 'size', 'dir'])
L['idx'] = L.groupby('day').cumcount()
L['next'] = L.groupby('day')['size'].shift(-1)       # recuo após um impulso = próxima perna
L['next2'] = L.groupby('day')['size'].shift(-2)
imp = L[L['size'] >= IMP].copy()
imp['pull'] = imp['next']
imp['cont'] = (imp['next2'] > imp['pull']) & imp['next2'].notna()      # após o recuo, o preço superou o fim do impulso
ndays = d.groupby('day').ngroups
rows = []
for h in range(24):
    gh = d[d.h == h]; nd = gh.day.nunique()
    if nd < 20: continue
    rng = gh.groupby('day').apply(lambda x: (x.high.max() - x.low.min()) / PT)
    path = gh.groupby('day').apply(lambda x: ((x.high - x.low) / PT).sum())
    ih = imp[imp.h == h]
    pulls = ih.pull.dropna()
    rows.append(dict(hora=f'{h:02d}:00', dias=nd, range_med=rng.median(), range_p25=rng.quantile(.25), range_p90=rng.quantile(.9),
                     impulsos_100_por_dia=len(ih) / nd, impulsos_100_por_hora_ativa=len(ih) / nd, recuo_medio=pulls.mean(), recuo_mediana=pulls.median(),
                     pct_recuo_40_80=100 * ((pulls >= 40) & (pulls <= 80)).mean() if len(pulls) else np.nan, pct_recuo_ate_100=100 * (pulls <= 100).mean() if len(pulls) else np.nan,
                     pct_continua=100 * ih.cont.mean() if len(ih) else np.nan, spread=sp.get(h, np.nan) if sp is not None else np.nan))
H = pd.DataFrame(rows)
H['range_por_spread'] = H.range_med / H.spread
H.to_csv(f'docs/relatorios/mba/xau_horarios/hft_horas_{TF}.csv', index=False)
pd.set_option('display.width', 250)
print(f'{TF}: {ndays} dias {d.t.min()} .. {d.t.max()} | pernas {len(L)} | impulsos>=100 {len(imp)}')
print(H.round(1).to_string(index=False))
