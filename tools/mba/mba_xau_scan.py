#!/usr/bin/env python3
"""XAUUSD: varre todo horário de entrada (M15, hora do servidor) x lado x alvo; saída no alvo ou 23:30, sem stop."""
import sys, math, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r
sys.stdout.reconfigure(encoding='utf-8')
B = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/Raw_Trading_Ltd/XAUUSD/LIVE"
PT = 0.01; SP = 20; TARGETS = (200, 300, 400, 500)
m = r.load_candles(B, 'M15').set_index('t').sort_index(); m = m[m.open.notna()]
m['d'] = m.index.normalize(); m['hm'] = m.index.strftime('%H:%M')
rows = []   # (date, slot, side, T, hit, res, minutes, mae)
for d, g in m.groupby('d'):
    if d.weekday() >= 5: continue
    g = g[g.hm <= '23:15']
    if len(g) < 85 or g.hm.iloc[0] > '01:15' : continue
    hm = g.hm.values; o = g.open.values; h = g.high.values; l = g.low.values; fin = g.close.values[-1]
    n = len(g)
    for i in range(n):
        if hm[i] > '22:00': break
        for side in ('V', 'C'):
            if side == 'V':
                run = np.minimum.accumulate(l[i:]); adv = np.maximum.accumulate(h[i:])
            else:
                run = np.maximum.accumulate(h[i:]); adv = np.minimum.accumulate(l[i:])
            for T in TARGETS:
                if side == 'V': ok = run + SP*PT <= o[i] - T*PT
                else: ok = run - SP*PT >= o[i] + T*PT
                if ok.any():
                    j = int(ok.argmax()); res = T; mins = 15*(j+1)
                    mae = (o[i]-adv[j])/PT if side == 'V' else (adv[j]-o[i])/PT
                else:
                    res = ((o[i]-fin)/PT - SP) if side == 'V' else ((fin-o[i])/PT - SP); mins = np.nan
                    mae = (o[i]-adv[-1])/PT if side == 'V' else (adv[-1]-o[i])/PT
                rows.append((d, hm[i], side, T, ok.any(), res, mins, mae))
df = pd.DataFrame(rows, columns=['d','slot','side','T','hit','res','min','mae'])
df.to_pickle('docs/relatorios/mba/xau_horarios/raw.pkl')
days = sorted(df.d.unique()); cut = days[int(len(days)*0.6)]
print('dias', len(days), days[0].date(), days[-1].date(), 'corte validação', cut.date())
def wil(k, n, z=1.96):
    if n == 0: return 0
    p = k/n; return (p + z*z/(2*n) - z*math.sqrt(p*(1-p)/n + z*z/(4*n*n)))/(1+z*z/n)
out = []
for (slot, side, T), x in df.groupby(['slot','side','T']):
    a = x[x.d < cut]; v = x[x.d >= cut]
    nh = x[~x.hit]
    loss = nh.res.mean() if len(nh) else 0
    out.append(dict(slot=slot, lado=side, alvo=T, n=len(x), pct=100*x.hit.mean(), wilson=100*wil(x.hit.sum(), len(x)),
        pct_desc=100*a.hit.mean(), pct_val=100*v.hit.mean(), media=x.res.mean(), media_desc=a.res.mean(), media_val=v.res.mean(),
        n_sem_alvo=len(nh), perda_media=loss, pior=x.res.min(), mae_medio=x.mae.mean(),
        nec=100*(-loss)/(T-loss) if loss < 0 else 0, min_med=x['min'].median(),
        anos_pos=''.join('+' if y.res.mean() > 0 else '-' for _, y in x.groupby(x.d.dt.year))))
o = pd.DataFrame(out); o.to_csv('docs/relatorios/mba/xau_horarios/xau_horarios_todos.csv', index=False)
print(len(o), 'combinações')
base = o.groupby(['lado','alvo'])[['pct','media']].mean(); print(base.round(1))
