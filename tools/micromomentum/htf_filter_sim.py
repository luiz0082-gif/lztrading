"""Filtro de tendencia maior (M5/M15...) para entradas de micro-momentum: ajuda?

Mede, na IC, o desfecho de cada sinal (ENTER e SKIP por posicao oposta, por serem estatisticamente equivalentes)
conforme o alinhamento com a direcao do preco nos ultimos L minutos (calculada so com barras M1 fechadas ate o
instante do sinal; sem look-ahead). Desfecho: TP de 60 pts em ate 30 min com ticks reais, sem stop.
Tambem cruza com os trades reais (net).

Uso: python tools/micromomentum/htf_filter_sim.py
"""
import glob
import os

import numpy as np
import pandas as pd

import analyze as a

LAT = 400
TP_PTS = 60
H_MIN = 30
LOOK = [15, 30, 60, 120, 240]
MINMOVE = [0, 100, 250]          # |variacao| minima em pts para considerar tendencia

# ---- barras M1 da IC (todas as sessoes), serie unica por bar_time
b = a.load("bars", usecols=["bar_time", "close"])
b = b[b.plat == "A"].copy()
b["bt"] = pd.to_datetime(b.bar_time, format="%Y.%m.%d %H:%M:%S", errors="coerce")
b["close"] = pd.to_numeric(b.close)
b = b.dropna(subset=["bt"]).drop_duplicates("bt").sort_values("bt")[["bt", "close"]].reset_index(drop=True)
print("barras M1:", len(b), b.bt.min(), "->", b.bt.max())

# ---- ticks por sessao
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
sg = sg[(sg.action == "ENTER") | ((sg.action == "SKIP") & (sg.reason == "posicao_oposta_aberta"))].copy()
sg["dir"] = pd.to_numeric(sg["dir"])
sg["t"] = a.ts(sg.t_server)
sg["ms"] = ((sg.t - pd.Timestamp("1970-01-01")).dt.total_seconds() * 1000).astype("int64")


def outcome(r):
    ms, bid, ask = tk[r.sess]
    j = np.searchsorted(ms, r.ms + LAT)
    if j >= len(ms) - 1:
        return pd.Series(dict(hit=np.nan, fast=np.nan, mae=np.nan))
    end = np.searchsorted(ms, ms[j] + H_MIN * 60000)
    if r["dir"] > 0:
        epx = ask[j]
        fav = (bid[j:end + 1] - epx) / 0.01
    else:
        epx = bid[j]
        fav = (epx - ask[j:end + 1]) / 0.01
    hit = np.where(fav >= TP_PTS)[0]
    upto = fav[:hit[0] + 1] if len(hit) else fav
    t5 = np.searchsorted(ms[j:end + 1], ms[j] + 5000)
    return pd.Series(dict(hit=float(len(hit) > 0), fast=float(fav[:max(t5, 1)].min() <= -40), mae=float(upto.min())))


sg = pd.concat([sg.reset_index(drop=True), sg.apply(outcome, axis=1).reset_index(drop=True)], axis=1).dropna(subset=["hit"])
print("sinais com desfecho:", len(sg))

# ---- tendencia por lookback (sem look-ahead: usa barra fechada anterior ao minuto do sinal)
sg["m"] = sg.t.dt.floor("min") - pd.Timedelta(minutes=1)
bi = b.set_index("bt").close
for L in LOOK:
    now = bi.reindex(sg.m.values, method="nearest", tolerance=pd.Timedelta(minutes=2)).values
    old = bi.reindex((sg.m - pd.Timedelta(minutes=L)).values, method="nearest", tolerance=pd.Timedelta(minutes=2)).values
    sg[f"d{L}"] = (now - old) / 0.01

rows = []
for L in LOOK:
    for mm in MINMOVE:
        x = sg.dropna(subset=[f"d{L}"]).copy()
        trend = np.where(x[f"d{L}"].abs() >= mm, np.sign(x[f"d{L}"]), 0)
        x["al"] = np.where(trend == 0, "sem_tendencia", np.where(trend == x["dir"], "a_favor", "contra"))
        for g, d in x.groupby("al"):
            rows.append(dict(lookback_min=L, min_move_pts=mm, grupo=g, n=len(d), acerta_TP=round(d.hit.mean(), 3),
                             contra_rapido=round(d.fast.mean(), 3), cauda_500=round((d.mae <= -500).mean(), 3)))
R = pd.DataFrame(rows)
pd.set_option("display.width", 250, "display.max_rows", 200)
print(R.to_string(index=False))

# ---- trades reais cruzados
t = pd.read_pickle(os.environ.get("T2PKL", "")) if os.environ.get("T2PKL") else None
if t is not None:
    t = t[t.plat == "A"].copy()
    t["m"] = t.ot.dt.floor("min") - pd.Timedelta(minutes=1)
    rows = []
    for L in [30, 60, 120]:
        now = bi.reindex(t.m.values, method="nearest", tolerance=pd.Timedelta(minutes=2)).values
        old = bi.reindex((t.m - pd.Timedelta(minutes=L)).values, method="nearest", tolerance=pd.Timedelta(minutes=2)).values
        d = (now - old) / 0.01
        al = np.where(np.isnan(d), "sem_dado", np.where(np.sign(d) == t["dir"], "a_favor", "contra"))
        for g in ["a_favor", "contra"]:
            m = al == g
            rows.append(dict(lookback_min=L, grupo=g, n=int(m.sum()), net_total=round(t.net[m].sum(), 2),
                             net_medio=round(t.net[m].mean(), 3), win=round((t.net[m] > 0).mean(), 3),
                             mae_p10_pts=round(t.mae_pts[m].quantile(.1), 0)))
    print("\nTRADES REAIS (IC):")
    print(pd.DataFrame(rows).to_string(index=False))
