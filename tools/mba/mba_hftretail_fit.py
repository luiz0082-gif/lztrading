#!/usr/bin/env python3
"""XAUUSD M1 (IC): proxy do HFT_RETAIL (scalper de TP fixo ~70 pts, sem SL): entrando em cada minuto, nos dois lados,
quanto tempo leva para bater +TP e quanto o preço anda contra antes. Por hora do servidor. NÃO é backtest do EA (a direção real do EA não entra)."""
import sys, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r
sys.stdout.reconfigure(encoding='utf-8')
R = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/Raw_Trading_Ltd/XAUUSD/LIVE"
PT = 0.01; TP = float(sys.argv[1]) if len(sys.argv) > 1 else 70; SP = 9; WIN = 480       # janela maxima: 8 h
d = r.load_candles(R, 'M1').sort_values('t').reset_index(drop=True); d = d[d.t >= '2026-03-26'].reset_index(drop=True)
d['gap'] = d.t.diff().dt.total_seconds().fillna(60) > 300; d['seg'] = d.gap.cumsum()
out = []
for seg, g in d.groupby('seg'):
    if len(g) < 120: continue
    o = g.open.values; h = g.high.values; l = g.low.values; hr = g.t.dt.hour.values; n = len(g)
    for i in range(n - 1):
        j1 = min(n, i + WIN)
        for side in (1, -1):
            if side == 1:
                thr = o[i] + (SP + TP) * PT; ok = h[i:j1] >= thr
            else:
                thr = o[i] - TP * PT + SP * PT; ok = (l[i:j1] + SP * PT) <= o[i] - TP * PT
            if ok.any():
                k = int(ok.argmax()); mins = k + 1
                adv = (o[i] - l[i:i + k + 1].min()) / PT if side == 1 else (h[i:i + k + 1].max() - o[i]) / PT
                out.append((hr[i], side, mins, max(adv, 0), True))
            else:
                adv = (o[i] - l[i:j1].min()) / PT if side == 1 else (h[i:j1].max() - o[i]) / PT
                out.append((hr[i], side, np.nan, max(adv, 0), False))
O = pd.DataFrame(out, columns=['h', 'side', 'min', 'adv', 'hit'])
G = O.groupby('h').agg(n=('hit', 'size'), hit8h=('hit', 'mean'), t_med=('min', 'median'),
                       p_1m=('min', lambda s: (s <= 1).sum()), p_5m=('min', lambda s: (s <= 5).sum()), p_30m=('min', lambda s: (s <= 30).sum()), p_120m=('min', lambda s: (s <= 120).sum()),
                       adv_med=('adv', 'median'), adv_p90=('adv', lambda s: s.quantile(.9)))
for c in ('p_1m', 'p_5m', 'p_30m', 'p_120m'): G[c] = 100 * G[c] / G.n
G['hit8h'] *= 100
G['preso_2h'] = 100 - G.p_120m
G.to_csv('docs/relatorios/mba/xau_horarios/hftretail_fit_horas.csv')
pd.set_option('display.width', 250); print(f'TP {TP:.0f} pts | spread {SP} | entradas {len(O)}'); print(G.round(1).to_string())
