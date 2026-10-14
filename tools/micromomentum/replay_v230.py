"""Reproducao tick a tick da v2.30 (preset estilo200) sobre ticks gravados da IC.

Fontes de ticks (IC, XAUUSD, hora do servidor):
  - ticks.csv das sessoes do MicroMomentum com InpLogEveryTick = true (inclui o tempo em que o EA estava
    bloqueado por meta diaria, ou seja, mercado que o EA viu mas nao operou);
  - RAW_TICKS do MarketBehaviorAnalyzer (12/10 23:31 -> 13/10 08:03).
O MBA so tem ticks de ~9 h; o resto do historico dele e M1/agregado, insuficiente para a logica de 1 s do EA.

Modelo (aproximacao, nao e o terminal): janela de impulso 1000 ms, >= 4 ticks, 30 pts, pullback <= 35 %,
impulso >= 1,5 x spread, spread <= 10, cooldown 1000 ms, 2 entradas por vela M1, 6 posicoes, sem hedge,
lote 0,01, TP US$ 1,20 (servidor) com comissao de US$ 0,08 ida e volta, recoil 100 pts com lucro > 0,45,
latencia de 400 ms, slippage de 3 pts contra, sem meta diaria, sem stop. Posicoes sem saida em 6 h ou ate o
fim do trecho de ticks ficam abertas (marcacao a mercado).

Uso: python tools/micromomentum/replay_v230.py
"""
import glob
import os

import numpy as np
import pandas as pd

import analyze as a

PT = 0.01
PAR = dict(minpts=30, win_ms=1000, minticks=4, pull=35.0, dispspread=1.5, maxspread=10, cooldown=1000,
           per_candle=2, maxopen=6, tp=1.20, comm_rt=0.08, lat=400, slip=3, recoil_pts=100, recoil_min=0.45,
           hmax_ms=6 * 3600 * 1000, seg_gap_ms=30000)
MBA_RAW = ("C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/"
           "Raw_Trading_Ltd/XAUUSD/LIVE/RAW_TICKS/raw_ticks_part001.csv")


def load_ticks():
    fr = []
    for f in glob.glob(os.path.join(a.ROOTS["A"], "*", "*", "*", "ticks*.csv")):
        d = pd.read_csv(f, usecols=["tick_msc", "bid", "ask", "up_pts", "dn_pts", "win_ticks"], low_memory=False)
        d = d.apply(pd.to_numeric, errors="coerce").dropna(subset=["tick_msc", "bid", "ask"])
        d["src"] = "MM"
        fr.append(d)
    m = pd.read_csv(MBA_RAW, usecols=["time_msc", "bid", "ask"]).rename(columns={"time_msc": "tick_msc"})
    m["src"] = "MBA"
    fr.append(m)
    t = pd.concat(fr, ignore_index=True)
    t = t.sort_values(["tick_msc", "src"]).drop_duplicates("tick_msc").reset_index(drop=True)
    t["tick_msc"] = t.tick_msc.astype("int64")
    return t


t = load_ticks()
ms = t.tick_msc.values
bid = t.bid.values
ask = t.ask.values
n_t = len(t)
seg = np.concatenate([[0], np.cumsum(np.diff(ms) > PAR["seg_gap_ms"])])
seg_end = np.zeros(n_t, dtype=np.int64)          # indice do ultimo tick de cada trecho
ends = np.where(np.diff(seg) != 0)[0]
bounds = np.concatenate([ends, [n_t - 1]])
starts = np.concatenate([[0], ends + 1])
for s0, e0 in zip(starts, bounds):
    seg_end[s0:e0 + 1] = e0
print("ticks:", n_t, "| trechos:", len(starts), "| fontes:", t.src.value_counts().to_dict())
cov_h = (pd.Series(1, index=pd.to_datetime(ms // 60000 * 60000, unit="ms")).groupby(level=0).size().index)
cov = pd.Series(1, index=cov_h).groupby(cov_h.hour).sum() / 60.0     # horas de dados por hora do servidor
print("horas de dados no total: %.1f" % (len(cov_h) / 60.0))

# ---- janela de impulso (igual a Analyze() do EA)
s = pd.Series(bid, index=pd.to_datetime(ms, unit="ms"))
r = s.rolling("%dms" % (PAR["win_ms"] + 1))
lo, hi, cnt = r.min().values, r.max().values, r.count().values
up = (bid - lo) / PT
dn = (hi - bid) / PT
spread = (ask - bid) / PT

# calibracao contra o que o EA gravou
rec = t[t.src == "MM"].dropna(subset=["up_pts", "dn_pts", "win_ticks"])
idx = rec.index.values
ok_up = np.abs(up[idx] - rec.up_pts.values) <= 1.01
ok_dn = np.abs(dn[idx] - rec.dn_pts.values) <= 1.01
ok_n = np.abs(cnt[idx] - rec.win_ticks.values) <= 1
print("calibracao da janela vs gravado pelo EA (%d ticks): up %.1f%% | dn %.1f%% | n_ticks %.1f%%" %
      (len(idx), ok_up.mean() * 100, ok_dn.mean() * 100, ok_n.mean() * 100))

buy = (up >= PAR["minpts"]) & (dn <= up * PAR["pull"] / 100.0)
sell = (dn >= PAR["minpts"]) & (up <= dn * PAR["pull"] / 100.0)
both = buy & sell
buy_b = np.where(both, up >= dn, buy)
sell_b = np.where(both, ~(up >= dn), sell)
mv = np.where(buy_b, up, dn)
sig = (cnt >= PAR["minticks"]) & (buy_b | sell_b) & (mv >= PAR["dispspread"] * spread) & (spread <= PAR["maxspread"])
dirv = np.where(buy_b, 1, -1)
cand = np.where(sig)[0]
print("ticks com sinal valido (spread ok):", len(cand))


def resolve(j, d, entry):
    """Caminho da posicao a partir do tick j. Retorna (resultado, indice_saida, net, mae_pts, censurada)."""
    end_t = ms[j] + PAR["hmax_ms"]
    k_hi = min(seg_end[j], int(np.searchsorted(ms, end_t, side="right")) - 1)
    ext = 0.0
    mae = 0.0
    k0 = j
    for size in (4000, 20000, 100000, 10 ** 9):
        k1 = min(k0 + size, k_hi + 1)
        if k0 >= k1:
            break
        fav = (bid[k0:k1] - entry) if d > 0 else (entry - ask[k0:k1])
        ext_arr = np.maximum.accumulate(np.maximum(fav, ext))
        tp_hit = np.where(fav >= PAR["tp"])[0]
        cond = ((ext_arr - fav) >= PAR["recoil_pts"] * PT) & ((fav - 0.5 * PAR["comm_rt"]) > PAR["recoil_min"])
        rc_hit = np.where(cond)[0]
        first = None
        if len(tp_hit):
            first = ("TP", tp_hit[0])
        if len(rc_hit) and (first is None or rc_hit[0] < first[1]):
            first = ("RECOIL", rc_hit[0])
        upto = (first[1] + 1) if first else len(fav)
        mae = min(mae, float(fav[:upto].min()) / PT)
        if first:
            net = (PAR["tp"] if first[0] == "TP" else float(fav[first[1]])) - PAR["comm_rt"]
            return first[0], k0 + first[1], net, mae, False
        ext = float(ext_arr[-1])
        k0 = k1
    last = k_hi
    fav_last = (bid[last] - entry) if d > 0 else (entry - ask[last])
    censurada = (ms[last] - ms[j]) < PAR["hmax_ms"] and seg_end[j] == last
    return "OPEN", last, float(fav_last) - PAR["comm_rt"], mae, bool(censurada)


opens = []        # (fecha_ms, dir)
closes = []       # instantes de fechamento recentes (cooldown)
candle = {}
rows = []
cool = 0
for i in cand:
    tt = int(ms[i])
    if tt < cool:
        continue
    closes = [c for c in closes if c + PAR["cooldown"] > tt]
    if closes:
        continue
    opens = [o for o in opens if o[0] > tt]
    if len(opens) >= PAR["maxopen"]:
        continue
    d = int(dirv[i])
    if any(o[1] != d for o in opens):
        continue
    mn = tt // 60000
    if candle.get(mn, 0) >= PAR["per_candle"]:
        continue
    j = int(np.searchsorted(ms, tt + PAR["lat"]))
    if j >= n_t or seg[j] != seg[i] or ms[j] - (tt + PAR["lat"]) > 5000:
        continue
    entry = ask[j] + PAR["slip"] * PT if d > 0 else bid[j] - PAR["slip"] * PT
    res, k, net, mae, cens = resolve(j, d, entry)
    candle[mn] = candle.get(mn, 0) + 1
    cool = tt + PAR["cooldown"]
    close_ms = int(ms[k])
    opens.append((close_ms, d))
    if res != "OPEN":
        closes.append(close_ms)
    rows.append(dict(t=tt, hora_srv=int(pd.Timestamp(tt, unit="ms").hour), dir=d, res=res, net=net, mae=mae,
                     hold_s=(close_ms - int(ms[j])) / 1000.0, cens=cens, entry=entry))
R = pd.DataFrame(rows)
R["dia"] = pd.to_datetime(R.t, unit="ms").dt.date.astype(str)
R.to_csv(os.path.join(os.path.dirname(__file__), "..", "..", "docs", "relatorios", "mba", "replay_v230_trades.csv"), index=False)
print("entradas simuladas:", len(R), "| censuradas (trecho acabou cedo):", int(R.cens.sum()))
V = R[~R.cens].copy()
V["tp"] = V.res.isin(["TP", "RECOIL"])
V["deep"] = V.mae <= -500
V["preso"] = V.res == "OPEN"

g = V.groupby("hora_srv").agg(entradas=("net", "size"), tp=("tp", "mean"), preso=("preso", "mean"), deep=("deep", "mean"),
                              net=("net", "sum"), net_medio=("net", "mean"), mae_p10=("mae", lambda x: x.quantile(.1)))
g["horas_dados"] = cov.reindex(g.index).values
g["entradas_por_h"] = g.entradas / g.horas_dados
g["net_por_h"] = g.net / g.horas_dados
g["hora_local"] = (g.index - 6) % 24
pd.set_option("display.width", 250, "display.max_rows", 100)
print(g.round(2).to_string())
g.round(3).to_csv(os.path.join(os.path.dirname(__file__), "..", "..", "docs", "relatorios", "mba", "replay_v230_por_hora.csv"))
print("\nTOTAL: entradas", len(V), "| net %.1f | TP %.1f%% | presas %.1f%% | profundas %.1f%%" %
      (V.net.sum(), V.tp.mean() * 100, V.preso.mean() * 100, V.deep.mean() * 100))
print(V.groupby("dia").agg(entradas=("net", "size"), net=("net", "sum"), preso=("preso", "sum"), deep=("deep", "sum")).round(1))
