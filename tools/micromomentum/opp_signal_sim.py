"""Contrafactual: o que teria acontecido se os sinais bloqueados por 'posicao_oposta_aberta' tivessem entrado?

Compara com as entradas reais (ENTER), pelo mesmo metodo: entrada no ask (compra) / bid (venda) no instante do sinal
(+ latencia), TP de 60 pts (US$1,20 em 0,02 lote), sem stop, horizonte H. Mede: acerta o TP, contra rapido, cauda.
Somente IC, sessoes com ticks.

Uso: python tools/micromomentum/opp_signal_sim.py
"""
import glob
import os

import numpy as np
import pandas as pd

import analyze as a

LAT = 400
TP_PTS = 60
H_MIN = 30

tkd = {}
for f in glob.glob(os.path.join(a.ROOTS["A"], "*", "*", "*", "ticks*.csv")):
    sess = f.split(os.sep)[-2]
    d = pd.read_csv(f, usecols=["tick_msc", "bid", "ask"], low_memory=False).apply(pd.to_numeric, errors="coerce").dropna()
    tkd.setdefault(sess, []).append(d)
tk = {}
for s, v in tkd.items():
    d = pd.concat(v).drop_duplicates("tick_msc").sort_values("tick_msc")
    if len(d) > 5000:
        tk[s] = (d.tick_msc.values.astype("int64"), d.bid.values, d.ask.values)

sg = a.load("signals")
sg = sg[(sg.plat == "A") & sg.sess.isin(tk.keys())].copy()
sg["ms"] = ((a.ts(sg.t_server) - pd.Timestamp("1970-01-01")).dt.total_seconds() * 1000).astype("int64")
sg["dir"] = pd.to_numeric(sg["dir"])
sg["up_pts"] = pd.to_numeric(sg.up_pts)
sg["dn_pts"] = pd.to_numeric(sg.dn_pts)
sg["imp"] = np.where(sg["dir"] > 0, sg.up_pts, sg.dn_pts)


def outcome(r):
    ms, bid, ask = tk[r.sess]
    j = np.searchsorted(ms, r.ms + LAT)
    if j >= len(ms) - 1:
        return None
    end = np.searchsorted(ms, ms[j] + H_MIN * 60000)
    if r["dir"] > 0:
        epx = ask[j]
        fav = (bid[j:end + 1] - epx) / 0.01
    else:
        epx = bid[j]
        fav = (epx - ask[j:end + 1]) / 0.01
    hit = np.where(fav >= TP_PTS)[0]
    upto = fav[:hit[0] + 1] if len(hit) else fav
    mae = upto.min()
    t5 = np.searchsorted(ms[j:end + 1], ms[j] + 5000)
    fast = fav[:max(t5, 1)].min() <= -40
    return dict(hit=bool(len(hit)), mae=mae, fast=bool(fast), tp_s=(ms[j + hit[0]] - ms[j]) / 1000 if len(hit) else np.nan)


rows = []
for name, sel in [("ENTER (entradas reais)", sg[sg.action == "ENTER"]),
                  ("SKIP posicao_oposta_aberta", sg[(sg.action == "SKIP") & (sg.reason == "posicao_oposta_aberta")])]:
    res = [outcome(r) for _, r in sel.iterrows()]
    res = [x for x in res if x]
    d = pd.DataFrame(res)
    rows.append(dict(grupo=name, n=len(d), acerta_TP=round(d.hit.mean(), 3), contra_rapido=round(d.fast.mean(), 3),
                     mae_mediano_pts=round(d.mae.median(), 0), mae_p10_pts=round(d.mae.quantile(.1), 0),
                     cauda_500=round((d.mae <= -500).mean(), 3), tp_mediano_s=round(d.tp_s.median(), 0)))
print(pd.DataFrame(rows).to_string(index=False))

# so os skips com impulso forte (>= 45 pts) -- a 'forca' da ideia
sk = sg[(sg.action == "SKIP") & (sg.reason == "posicao_oposta_aberta")]
for thr in [30, 45, 60]:
    d = pd.DataFrame([x for x in (outcome(r) for _, r in sk[sk.imp >= thr].iterrows()) if x])
    print("skip com impulso >=", thr, "n", len(d), "acerta_TP", round(d.hit.mean(), 3), "contra_rapido", round(d.fast.mean(), 3),
          "cauda_500", round((d.mae <= -500).mean(), 3))
