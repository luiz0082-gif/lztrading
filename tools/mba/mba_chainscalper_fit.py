#!/usr/bin/env python3
"""Proxy do gatilho do ChainScalper no M1 do XAUUSD (IC): tendência EMA9/34 + ATR14/ATR100 >= 0.85 + rompimento da máx/mín das 3 últimas barras.
Mede por hora do servidor: quantos gatilhos, quanto o preço continua (degraus de 40 pts) e quanto volta contra. NÃO é backtest do EA."""
import sys, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r
sys.stdout.reconfigure(encoding='utf-8')
R = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/Raw_Trading_Ltd/XAUUSD/LIVE"
PT = 0.01; SP = 9; STEP = 40; W = 10
d = r.load_candles(R, 'M1').sort_values('t').reset_index(drop=True)
d = d[d.t >= '2026-03-26'].reset_index(drop=True)
d['gap'] = d.t.diff().dt.total_seconds().fillna(60) > 300      # quebra de sessão
d['seg'] = d.gap.cumsum()
out = []
for seg, g in d.groupby('seg'):
    g = g.reset_index(drop=True)
    if len(g) < 200: continue
    c = g.close; tr = np.maximum(g.high - g.low, np.maximum((g.high - c.shift()).abs(), (g.low - c.shift()).abs()))
    atr14 = tr.rolling(14).mean(); atr100 = tr.rolling(100).mean()
    e9 = c.ewm(span=9, adjust=False).mean(); e34 = c.ewm(span=34, adjust=False).mean()
    up = (e9 > e34) & (c > e34) & (e34 > e34.shift(5)); dn = (e9 < e34) & (c < e34) & (e34 < e34.shift(5))
    gate = (atr14 >= 4 * SP * PT) & (atr14 / atr100 >= 0.85)
    H = g.high.values; L = g.low.values; C = c.values; t = g.t.values
    for i in range(110, len(g) - W - 1):
        if not gate.iloc[i - 1]: continue
        hh = H[i - 3:i].max(); ll = L[i - 3:i].min()
        for side, ok, lvl, brk in ((1, up.iloc[i - 1], hh, H[i] > hh), (-1, dn.iloc[i - 1], ll, L[i] < ll)):
            if not (ok and brk): continue
            if abs(lvl - C[i - 1]) > 0.6 * atr14.iloc[i - 1] * 1.0 + 1e9: continue
            fut_h = H[i + 1:i + 1 + W]; fut_l = L[i + 1:i + 1 + W]
            if side == 1: mfe = (fut_h.max() - lvl) / PT; mae = (lvl - fut_l.min()) / PT; path_up = np.maximum.accumulate((fut_h - lvl) / PT); path_dn = np.maximum.accumulate((lvl - fut_l) / PT)
            else: mfe = (lvl - fut_l.min()) / PT; mae = (fut_h.max() - lvl) / PT; path_up = np.maximum.accumulate((lvl - fut_l) / PT); path_dn = np.maximum.accumulate((fut_h - lvl) / PT)
            # continuação limpa: atinge +2 degraus antes de voltar -STEP
            k2 = np.argmax(path_up >= 2 * STEP) if (path_up >= 2 * STEP).any() else 99
            kb = np.argmax(path_dn >= STEP) if (path_dn >= STEP).any() else 99
            out.append((pd.Timestamp(t[i]), pd.Timestamp(t[i]).hour, side, mfe, mae, k2 < kb, mfe >= STEP, mfe >= 3 * STEP, mae >= 2 * STEP))
O = pd.DataFrame(out, columns=['t', 'h', 'side', 'mfe', 'mae', 'limpa2', 'mfe40', 'mfe120', 'mae80'])
nd = d.t.dt.normalize().nunique()
G = O.groupby('h').agg(gatilhos=('side', 'size'), mfe_med=('mfe', 'median'), mae_med=('mae', 'median'), p_mfe40=('mfe40', 'mean'), p_mfe120=('mfe120', 'mean'), p_limpa2=('limpa2', 'mean'), p_mae80=('mae80', 'mean'))
G['gatilhos_por_dia'] = G.gatilhos / nd
G[['p_mfe40', 'p_mfe120', 'p_limpa2', 'p_mae80']] *= 100
G['mfe_sobre_mae'] = G.mfe_med / G.mae_med
G.to_csv('docs/relatorios/mba/xau_horarios/chainscalper_fit_horas.csv')
pd.set_option('display.width', 250)
print(f'{nd} dias M1; gatilhos {len(O)}'); print(G.round(1).to_string())
print('\nTotal: P(mfe>=40)', round(100 * O.mfe40.mean(), 1), 'P(limpa2)', round(100 * O.limpa2.mean(), 1))
