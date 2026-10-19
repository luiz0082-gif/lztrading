#!/usr/bin/env python3
"""Reach study, structural layer: does an observable condition at the entry bar change what happens next, BEYOND the clock effect?

Entry = open of every bar (Mon-Fri, full window). Conditions use only bars that are CLOSED before the entry (no look-ahead):
  prev1     last closed bar: strong down / down / up / strong up (body vs ATR14 of closed bars, |body| > 0.5 ATR = strong)
  ret4      return of the last 4 closed bars in ATR, quintiles (cut points from the discovery period)
  streak    consecutive same-colour closed bars (signed, capped at 3)
  compress  range of the last 8 closed bars / ATR14, terciles (compressed / normal / expanded)
  pdpos     entry price vs previous server day: above PDH / upper half / lower half / below PDL
  dopen     distance from the server-day open in ATR, quintiles
  brk       last closed bar vs the 20 bars before it: broke high & closed outside / broke high & failed / same for low / inside
  extreme   |return of last 16 closed bars| above the discovery 95th percentile (up / down / normal)
  spread    spread of the last closed bar vs the median of its clock slot (high if > 1.5x)
  tickvol   tick volume of the last closed bar vs the median of its clock slot, terciles
  prevday   previous server day closed up / down
  weekday
Cells: condition level x server hour, and pairs of conditions x session (01-09 / 09-15 / 15-20 / 20-24 server).
Outcomes (window W): race (gross +k before -k), EV of BUY and SELL with adverse limit k (net of spread and swap).
Statistic: outcome MINUS the discovery mean of the same clock slot (removes the clock effect), averaged per day, t over days.
Discovery = first 60% of days, validation = last 40%. BH on discovery. Placebo: the outcome series is taken from another day
(same slot, shifted by S days), which keeps every distribution and destroys the link condition -> outcome.
Also writes "I" regularities: session-to-session continuation, previous day -> today, Monday gap fill.

  python tools/mba/mba_reach_struct.py --cache <m1cache> --reach <reach_cache> --out docs/relatorios/mba/reach --sym XAUUSD --tf M15 --W 240
"""
import argparse, itertools, json, math, os, sys
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mba_reach_analyze import Data, NOHIT, SPLIT, bh_mask, norm_p, grp_stats

sys.stdout.reconfigure(encoding="utf-8")
SESS = np.array([0] * 9 + [1] * 6 + [2] * 5 + [3] * 4)      # server hour -> session (00-08 Asia, 09-14 London, 15-19 NY, 20-23 late)
SESS_LAB = ["Asia(00-09)", "Londres(09-15)", "NY(15-20)", "Tarde(20-24)"]


def rolling_prev(x, n, fn):
    s = pd.Series(x).shift(1)
    return getattr(s.rolling(n, min_periods=n), fn)().to_numpy()


def qbins(x, disc, nb):
    edges = np.nanquantile(x[disc], np.linspace(0, 1, nb + 1)[1:-1])
    b = np.searchsorted(edges, x, side="right").astype(float); b[~np.isfinite(x)] = np.nan
    return b


def features(D):
    o, h, l, c, tv, spr = D.o, D.h, D.l, D.c, D.tv, D.spr
    N = len(o)
    prev_c = np.concatenate([[np.nan], c[:-1]])
    tr = np.maximum.reduce([h - l, np.abs(h - prev_c), np.abs(l - prev_c)])
    atr = rolling_prev(tr, 14, "mean")
    F, L = {}, {}
    body1 = np.concatenate([[np.nan], (c - o)[:-1]]) / atr
    F["prev1"] = np.select([body1 < -0.5, body1 < 0, body1 < 0.5, body1 >= 0.5], [0, 1, 2, 3], np.nan); F["prev1"][~np.isfinite(body1)] = np.nan
    L["prev1"] = ["forte_baixa", "baixa", "alta", "forte_alta"]
    r4 = (prev_c - np.concatenate([[np.nan] * 4, o[:-4]])) / atr
    F["ret4"] = qbins(r4, D.disc, 5); L["ret4"] = ["Q1(caiu+)", "Q2", "Q3", "Q4", "Q5(subiu+)"]
    col = np.sign(c - o)
    st = np.zeros(N)
    for i in range(1, N):
        p = col[i - 1]
        st[i] = (st[i - 1] + p if np.sign(st[i - 1]) == p and p != 0 else p) if p != 0 else 0
    st = np.clip(st, -3, 3)
    F["streak"] = np.select([st <= -3, st == -2, st == -1, st == 1, st == 2, st >= 3], [0, 1, 2, 3, 4, 5], np.nan)
    L["streak"] = ["3+ baixas", "2 baixas", "1 baixa", "1 alta", "2 altas", "3+ altas"]
    rg8 = (rolling_prev(h, 8, "max") - rolling_prev(l, 8, "min")) / atr
    F["compress"] = qbins(rg8, D.disc, 3); L["compress"] = ["comprimido", "normal", "expandido"]
    day = D.t // 1440
    dfd = pd.DataFrame(dict(day=day, h=h, l=l, o=o, c=c)).groupby("day").agg(H=("h", "max"), L=("l", "min"), O=("o", "first"), C=("c", "last"))
    prevH = dfd["H"].shift(1).reindex(day).to_numpy(); prevL = dfd["L"].shift(1).reindex(day).to_numpy()
    mid = (prevH + prevL) / 2
    F["pdpos"] = np.select([o > prevH, o >= mid, o >= prevL, o < prevL], [0, 1, 2, 3], np.nan); F["pdpos"][~np.isfinite(prevH)] = np.nan
    L["pdpos"] = ["acima_PDH", "metade_sup", "metade_inf", "abaixo_PDL"]
    dopen = dfd["O"].reindex(day).to_numpy()
    F["dopen"] = qbins((o - dopen) / atr, D.disc, 5); L["dopen"] = ["Q1(bem abaixo)", "Q2", "Q3", "Q4", "Q5(bem acima)"]
    hi20 = pd.Series(h).shift(2).rolling(20, min_periods=20).max().to_numpy(); lo20 = pd.Series(l).shift(2).rolling(20, min_periods=20).min().to_numpy()
    h1, l1 = np.concatenate([[np.nan], h[:-1]]), np.concatenate([[np.nan], l[:-1]])
    F["brk"] = np.select([(h1 > hi20) & (prev_c > hi20), (h1 > hi20), (l1 < lo20) & (prev_c < lo20), (l1 < lo20)], [0, 1, 2, 3], 4)
    F["brk"] = F["brk"].astype(float); F["brk"][~np.isfinite(hi20)] = np.nan
    L["brk"] = ["rompeu_max_fechou_fora", "rompeu_max_falhou", "rompeu_min_fechou_fora", "rompeu_min_falhou", "dentro"]
    r16 = (prev_c - np.concatenate([[np.nan] * 16, o[:-16]])) / atr
    thr = np.nanquantile(np.abs(r16[D.disc]), 0.95)
    F["extreme"] = np.select([r16 > thr, r16 < -thr], [0, 1], 2).astype(float); F["extreme"][~np.isfinite(r16)] = np.nan
    L["extreme"] = ["extremo_alta", "extremo_baixa", "normal"]
    slot = D.mod // D.bm
    s1 = np.concatenate([[np.nan], spr[:-1]]); t1 = np.concatenate([[np.nan], tv[:-1]])
    medS = pd.Series(s1[D.disc]).groupby(slot[D.disc]).median().reindex(range(1440 // D.bm)).to_numpy()[slot]
    F["spread"] = np.where(s1 > 1.5 * medS, 1.0, 0.0); F["spread"][~np.isfinite(s1)] = np.nan; L["spread"] = ["normal", "alto(>1.5x)"]
    medT = pd.Series(t1[D.disc]).groupby(slot[D.disc]).median().reindex(range(1440 // D.bm)).to_numpy()[slot]
    F["tickvol"] = qbins(t1 / medT, D.disc, 3); L["tickvol"] = ["baixo", "normal", "alto"]
    pdir = np.sign(dfd["C"] - dfd["O"]).shift(1).reindex(day).to_numpy()
    F["prevday"] = np.where(pdir > 0, 1.0, np.where(pdir < 0, 0.0, np.nan)); L["prevday"] = ["dia_ant_baixa", "dia_ant_alta"]
    F["weekday"] = D.wd.astype(float); L["weekday"] = ["SEG", "TER", "QUA", "QUI", "SEX", "SAB", "DOM"]
    return F, L


def cluster_stats(ck, dd_s, dd_n, nc):
    """per-ENTRY mean with day-clustered standard error. Inputs are per (day, cell) sums/counts.
    (A per-day average would leak the future: the number of signals in a day depends on what price does after the first one.)"""
    N = np.bincount(ck, weights=dd_n, minlength=nc); S = np.bincount(ck, weights=dd_s, minlength=nc)
    G = np.bincount(ck, minlength=nc).astype(float)
    with np.errstate(invalid="ignore", divide="ignore"):
        mu = S / N
        R = dd_s - dd_n * mu[ck]
        var = np.bincount(ck, weights=R ** 2, minlength=nc) / N ** 2 * G / (G - 1)
        t = mu / np.sqrt(var)
    return G, mu, t


def evaluate(D, cells, excess, ok_mask, disc_day):
    """cells: int array (-1 = none). Returns per-cell disc/val stats: n days, per-entry mean excess, day-clustered t."""
    m = ok_mask & (cells >= 0) & np.isfinite(excess) & (D.dayidx >= 0)
    nc = int(cells.max()) + 1
    dk = D.dayidx[m].astype(np.int64) * nc + cells[m]
    s = np.bincount(dk, weights=excess[m], minlength=D.nd * nc); n = np.bincount(dk, minlength=D.nd * nc)
    idx = np.nonzero(n)[0]; ck = (idx % nc).astype(int); dd = (idx // nc).astype(int)
    isd = disc_day[dd]
    nD, muD, tD = cluster_stats(ck[isd], s[idx][isd], n[idx][isd], nc); nV, muV, tV = cluster_stats(ck[~isd], s[idx][~isd], n[idx][~isd], nc)
    nE = np.bincount(cells[m], minlength=nc)
    return nD, muD, tD, nV, muV, tV, nE


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", required=True); ap.add_argument("--reach", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--sym", required=True); ap.add_argument("--tf", required=True); ap.add_argument("--W", type=int, default=240)
    ap.add_argument("--specs", default=None); ap.add_argument("--shifts", type=int, nargs="+", default=[17, 29, 41, 53, 67, 79, 97, 113])
    a = ap.parse_args()
    od = os.path.join(a.out, a.sym); os.makedirs(od, exist_ok=True)
    D = Data(a.cache, a.reach, a.sym, a.tf, a.W, a.specs)
    F, L = features(D)
    names = list(F)
    disc_day = D.days < D.days[int(D.nd * SPLIT)]
    hour = D.mod // 60; sess = SESS[hour]
    # ---- cell definitions
    cells_def = []          # (label, cell array)
    for f in names:
        x = F[f]; ok = np.isfinite(x)
        lv = np.where(ok, x, 0).astype(int)
        c = np.where(ok, lv * 24 + hour, -1)
        cells_def.append((f, "hour", c, lambda i, f=f: f"{f}={L[f][i // 24]} & hora={i % 24:02d}h"))
    for f, g in itertools.combinations(names, 2):
        x, y = F[f], F[g]; ok = np.isfinite(x) & np.isfinite(y)
        ny = len(L[g])
        c = np.where(ok, (np.where(ok, x, 0).astype(int) * ny + np.where(ok, y, 0).astype(int)) * 4 + sess, -1)
        cells_def.append((f + "*" + g, "sess", c, lambda i, f=f, g=g, ny=ny: f"{f}={L[f][(i // 4) // ny]} & {g}={L[g][(i // 4) % ny]} & {SESS_LAB[i % 4]}"))
    # ---- outcomes: thresholds with ~50% and ~25% gross reach
    e = D.elig
    reach = np.array([max((D.up[e, q] != NOHIT).mean(), (D.dn[e, q] != NOHIT).mean()) for q in range(len(D.K))])
    qsel = sorted({int(np.argmin(np.abs(reach - 0.5))), int(np.argmin(np.abs(reach - 0.25)))})
    slot = (D.mod // D.bm).astype(int); nsl = 1440 // D.bm
    # (day, slot) -> entry index map for the placebo shift
    M = np.full((D.nd, nsl), -1, np.int64)
    okm = e & (D.dayidx >= 0); M[D.dayidx[okm], slot[okm]] = np.nonzero(okm)[0]
    rows, plc_counts = [], {s: 0 for s in a.shifts}
    for q in qsel:
        k = int(D.K[q])
        y, _ = D.race(q)
        outs = [("race", y), ("EV_BUY_Ak", D.ev(q, "BUY", q)[0]), ("EV_SELL_Ak", D.ev(q, "SELL", q)[0])]
        for oname, x in outs:
            sm = pd.Series(x[D.disc]).groupby(slot[D.disc]).mean().reindex(range(nsl)).to_numpy()
            ex = x - sm[slot]
            variants = [("real", ex, x)]
            for sft in a.shifts:
                j = M[(D.dayidx + sft) % D.nd, slot]; j = np.where(D.dayidx >= 0, j, -1)
                xs = np.where(j >= 0, x[np.maximum(j, 0)], np.nan)
                variants.append((sft, xs - sm[slot], xs))
            for vname, exv, raw in variants:
                for fname, kind, c, labf in cells_def:
                    nD, muD, tD, nV, muV, tV, nE = evaluate(D, c, exv, e, disc_day)
                    good = (nD >= 30) & (nV >= 20)
                    if vname != "real":
                        p = np.where(good, [norm_p(t) if np.isfinite(t) else np.nan for t in tD], np.nan)
                        bh = bh_mask(p) & good
                        val = bh & (np.sign(tV) == np.sign(tD)) & (np.abs(tV) >= 1.645)
                        if oname.startswith("EV"):
                            val &= muD > 0
                        plc_counts[vname] += int(val.sum())
                        continue
                    _, rawD, _, _, rawV, _, _ = evaluate(D, c, raw, e, disc_day)
                    for i in np.nonzero(good)[0]:
                        rows.append(dict(k_pts=k, outcome=oname, family=fname, kind=kind, cond=labf(i), n_entries=int(nE[i]), days_disc=int(nD[i]),
                                         days_val=int(nV[i]), excess_disc=muD[i], t_disc=tD[i], excess_val=muV[i], t_val=tV[i],
                                         raw_disc=rawD[i], raw_val=rawV[i], p_disc=norm_p(tD[i]) if np.isfinite(tD[i]) else np.nan))
        print(a.sym, a.tf, a.W, "k", k, "rows", len(rows), flush=True)
    df = pd.DataFrame(rows)
    # BH per (k, outcome) family of tests; EV only on positive excess
    df["bh_disc"] = False
    for (k, oname), g in df.groupby(["k_pts", "outcome"]):
        p = g["p_disc"].to_numpy()
        if oname.startswith("EV"):
            p = np.where(g["excess_disc"] > 0, p, np.nan)
        df.loc[g.index, "bh_disc"] = bh_mask(p)
    df["validated"] = df["bh_disc"] & (np.sign(df["t_val"]) == np.sign(df["t_disc"])) & (df["t_val"].abs() >= 1.645)
    df.loc[df["outcome"].str.startswith("EV"), "validated"] &= (df["raw_val"] > 0) & (df["raw_disc"] > 0)
    tag = f"{a.tf}_W{a.W}"
    df[df["validated"] | (df["t_disc"].abs() >= 3.5)].sort_values("t_disc", key=np.abs, ascending=False).to_csv(
        os.path.join(od, f"D_estruturais_{tag}.csv"), index=False, float_format="%.3f")
    info = dict(tests=len(df), bh_disc=int(df["bh_disc"].sum()), validated=int(df["validated"].sum()),
                validated_by_outcome=df[df["validated"]].groupby("outcome").size().to_dict(),
                placebo_validated=plc_counts, placebo_mean=float(np.mean(list(plc_counts.values()))), placebo_max=int(max(plc_counts.values())),
                k_tested=[int(D.K[q]) for q in qsel])
    print(info, flush=True)
    # ---- I: continuation regularities (server-day sessions)
    day = D.t // 1440
    d = pd.DataFrame(dict(day=day, hour=hour, o=D.o, c=D.c, wd=D.wd))
    d = d[d.wd < 5]
    def seg(h0, h1):
        g = d[(d.hour >= h0) & (d.hour < h1)].groupby("day")
        return (g["c"].last() - g["o"].first()) / D.pt
    segs = {"Asia(01-09)": seg(0, 9), "Londres(09-15)": seg(9, 15), "NY(15-20)": seg(15, 20), "Tarde(20-24)": seg(20, 24), "Dia": seg(0, 24)}
    cont = []
    pairs = [("Asia(01-09)", "Londres(09-15)"), ("Londres(09-15)", "NY(15-20)"), ("Asia(01-09)", "NY(15-20)"), ("NY(15-20)", "Tarde(20-24)")]
    for A_, B_ in pairs:
        j = pd.concat([segs[A_], segs[B_]], axis=1, keys=["a", "b"]).dropna()
        j = j[(j.a != 0) & (j.b != 0)]
        cut = D.days[int(D.nd * SPLIT)]
        for per, jj in (("descoberta", j[j.index < cut]), ("validacao", j[j.index >= cut])):
            same = (np.sign(jj.a) == np.sign(jj.b)).mean(); n = len(jj)
            cont.append(dict(de=A_, para=B_, periodo=per, dias=n, mesmo_sinal_pct=100 * same, z=(same - 0.5) / math.sqrt(0.25 / n) if n else np.nan,
                             corr=jj.a.corr(jj.b)))
    dd = segs["Dia"]; j = pd.concat([dd.shift(1), dd], axis=1, keys=["a", "b"]).dropna(); j = j[(j.a != 0) & (j.b != 0)]
    cut = D.days[int(D.nd * SPLIT)]
    for per, jj in (("descoberta", j[j.index < cut]), ("validacao", j[j.index >= cut])):
        same = (np.sign(jj.a) == np.sign(jj.b)).mean(); n = len(jj)
        cont.append(dict(de="Dia anterior", para="Dia", periodo=per, dias=n, mesmo_sinal_pct=100 * same, z=(same - 0.5) / math.sqrt(0.25 / n), corr=jj.a.corr(jj.b)))
    pd.DataFrame(cont).to_csv(os.path.join(od, f"I_continuidade_{a.tf}.csv"), index=False, float_format="%.3f")
    # Monday gap: first bar of Monday vs Friday last close; filled = price trades back to Friday close the same day
    dd = pd.DataFrame(dict(day=day, wd=D.wd, o=D.o, h=D.h, l=D.l, c=D.c))
    g = dd.groupby("day").agg(wd=("wd", "first"), O=("o", "first"), H=("h", "max"), L=("l", "min"), C=("c", "last"))
    g["prevC"] = g["C"].shift(1); g = g[g.wd == 0].dropna()
    g["gap_pts"] = (g.O - g.prevC) / D.pt
    g["filled"] = np.where(g.gap_pts > 0, g.L <= g.prevC, g.H >= g.prevC)
    gq = g[g.gap_pts.abs() >= 5 * max(np.nanmedian(D.spr[e]), 1)]
    gap = dict(mondays=len(g), gaps_relevantes=len(gq), gap_med_abs=float(gq.gap_pts.abs().median()) if len(gq) else None,
               fechou_no_dia_pct=float(100 * gq.filled.mean()) if len(gq) else None)
    info["monday_gap"] = gap
    p = os.path.join(od, "resumo_estrutural.json")
    old = json.load(open(p)) if os.path.exists(p) else {}
    old[tag] = info
    json.dump(old, open(p, "w"), indent=1, default=float)


if __name__ == "__main__":
    main()
