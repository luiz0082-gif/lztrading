"""Simulacao de 'fechar e inverter' (stop-and-reverse) sobre trades reais da IC, com ticks reais.

Para cada trade com caminho (positions.csv) e ticks (ticks.csv): se a posicao chegar a -X pts em ate T s,
fecha ali (com latencia LAT ms) e abre a oposta no tick seguinte; a oposta fica ate o TP em dinheiro do trade
ou ate H minutos (marcacao a mercado no fim). Compara com o resultado real do trade original.

Uso: python tools/micromomentum/flip_sim.py
"""
import glob
import os

import numpy as np
import pandas as pd

import analyze as a

S = ("C:/Users/luiz_/AppData/Local/Temp/claude/C--Users-luiz--OneDrive--rea-de-Trabalho-Luiz-EA---INDICADOR-"
     "EA-MT5-lztrading/2f150bae-5eb7-4604-9d20-40be44752205/scratchpad/")
t = pd.read_pickle(S + "t2.pkl")
t = t[t.plat == "A"].copy()

p = a.load("positions", usecols=["ticket", "hold_ms", "pts"])
for c in ["ticket", "hold_ms", "pts"]:
    p[c] = pd.to_numeric(p[c])
p = p[p.plat == "A"].sort_values(["ticket", "hold_ms"])
paths = {k: (g.hold_ms.values, g.pts.values) for k, g in p.groupby("ticket")}

tk = {}
for f in glob.glob(os.path.join(a.ROOTS["A"], "*", "*", "*", "ticks*.csv")):
    sess = f.split(os.sep)[-2]
    d = pd.read_csv(f, usecols=["tick_msc", "bid", "ask"], low_memory=False).apply(pd.to_numeric, errors="coerce").dropna()
    tk.setdefault(sess, []).append(d)
tkd = {}
for s, v in tk.items():
    d = pd.concat(v).drop_duplicates("tick_msc").sort_values("tick_msc")
    if len(d) > 5000:
        tkd[s] = (d.tick_msc.values.astype("int64"), d.bid.values, d.ask.values)
print("sessoes com ticks:", len(tkd))

t["open_ms"] = ((a.ts(t.open_time) - pd.Timestamp("1970-01-01")).dt.total_seconds() * 1000).astype("int64")
t["usd_pt"] = (t.profit / t.pts.replace(0, np.nan)).abs()

LAT = 400
rows = []
for X in [20, 30, 45, 60]:
    for T in [3000, 10000]:
        for H in [10, 30]:
            n = orig = flip = tpw = 0
            for _, r in t.iterrows():
                if r.ticket not in paths or r.sess not in tkd:
                    continue
                h, pt = paths[r.ticket]
                idx = np.where((h <= T) & (pt <= -X))[0]
                if len(idx) == 0:
                    continue
                ms, bid, ask = tkd[r.sess]
                tf = r.open_ms + h[idx[0]] + LAT
                j = np.searchsorted(ms, tf)
                if j >= len(ms) - 1:
                    continue
                upp = r.usd_pt if r.usd_pt == r.usd_pt and r.usd_pt > 0 else 0.02
                vol_f = r.volume / 0.02
                comm = 0.16 * vol_f
                buy = r.dir == 1
                # fecha a original no tick j: compra fecha no bid, venda fecha no ask
                close_px = bid[j] if buy else ask[j]
                open_px = r.open_price
                loss = ((close_px - open_px) if buy else (open_px - close_px)) / 0.01 * upp - comm
                # abre a oposta no mesmo tick: oposta de compra e venda
                if buy:   # original compra -> oposta VENDA abre no bid, fecha no ask
                    epx = bid[j]
                    tp_px = epx - 1.2 / upp * 0.01
                    end = np.searchsorted(ms, ms[j] + H * 60000)
                    seg = ask[j:end + 1]
                    hit = np.where(seg <= tp_px)[0]
                    last = seg[-1] if len(seg) else epx
                    res = (1.2 if len(hit) else (epx - last) / 0.01 * upp) - comm
                else:     # original venda -> oposta COMPRA abre no ask, fecha no bid
                    epx = ask[j]
                    tp_px = epx + 1.2 / upp * 0.01
                    end = np.searchsorted(ms, ms[j] + H * 60000)
                    seg = bid[j:end + 1]
                    hit = np.where(seg >= tp_px)[0]
                    last = seg[-1] if len(seg) else epx
                    res = (1.2 if len(hit) else (last - epx) / 0.01 * upp) - comm
                n += 1
                orig += r.net
                flip += loss + res
                tpw += 1 if len(hit) else 0
            rows.append(dict(X_pts=X, T_s=T / 1000, H_min=H, n=n, net_orig=round(orig, 2), net_flip=round(flip, 2),
                             delta=round(flip - orig, 2), oposta_bate_TP=tpw))
print(pd.DataFrame(rows).to_string(index=False))
