#!/usr/bin/env python3
"""Reach study, analysis layer (reads the outputs of mba_reach_load.py and mba_reach.py).

Per symbol / timeframe / window W:
  C  distances      : % of entries whose executable BUY / SELL reaches k points inside W, time to reach, adverse excursion before reaching,
                       race against an adverse limit of k (win / loss / same-bar indeterminate / neither)
  B  clock scan     : the same for EVERY clock slot (server time; slot = bar size: M1 = minute, M5 = 5 min, M15 = 15 min), BUY and SELL apart
  E  direction      : y = +1 if gross price reaches +k before -k, -1 if -k first, 0 if neither / same bar. Tested per slot AFTER removing the
                       day's mean (so a trending day does not make every slot look bullish). Discovery = first 60% of days, validation = last 40%.
                       Multiple testing: Benjamini-Hochberg on discovery + day-wise sign-flip permutation (max |t| -> family-wise threshold, and
                       "how many slots would pass discovery+validation by chance").
  G  executable EV  : BUY/SELL at the slot, exit at +k (net of spread) or at the adverse limit A (A = k, 2k, or none = exit at window end).
                       Same-bar target+limit counted as a LOSS (conservative). Placebo = slot labels shuffled inside each day.
Coarser clocks (15 min, hour, weekday x hour) are scanned with the same machinery (more observations per cell, fewer tests).

  python tools/mba/mba_reach_analyze.py --cache <m1cache> --reach <reach_cache> --out docs/relatorios/mba/reach --sym XAUUSD --tf M5 --W 60 240
"""
import argparse, json, math, os, sys
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
NOHIT = 32767
SPLIT = 0.6


def norm_p(t):
    return math.erfc(abs(t) / math.sqrt(2))


def bh_mask(p, q=0.05):
    p = np.asarray(p, float); ok = np.isfinite(p)
    out = np.zeros(len(p), bool)
    if ok.sum() == 0:
        return out
    pv = p[ok]; o = np.argsort(pv); m = len(pv)
    thr = q * np.arange(1, m + 1) / m
    passed = pv[o] <= thr
    if passed.any():
        kmax = np.max(np.nonzero(passed)[0])
        sel = np.zeros(m, bool); sel[o[:kmax + 1]] = True
        out[np.nonzero(ok)[0]] = sel
    return out


def wilson(h, n, z=1.96):
    if n == 0:
        return (np.nan, np.nan)
    p = h / n; d = 1 + z * z / n; c = p + z * z / (2 * n); r = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return ((c - r) / d, (c + r) / d)


def grp_stats(key, nkeys, x, mask):
    """n, mean, sd, t for x grouped by key (only rows in mask, NaN ignored)."""
    m = mask & np.isfinite(x)
    n = np.bincount(key[m], minlength=nkeys).astype(float)
    s = np.bincount(key[m], weights=x[m], minlength=nkeys)
    s2 = np.bincount(key[m], weights=x[m] ** 2, minlength=nkeys)
    with np.errstate(invalid="ignore", divide="ignore"):
        mu = s / n; var = (s2 - n * mu ** 2) / (n - 1); sd = np.sqrt(np.maximum(var, 0)); t = mu / (sd / np.sqrt(n))
    return n, mu, sd, t


class Data:
    def __init__(self, cache, reach, sym, tf, Wmin, specs=None):
        z = np.load(os.path.join(cache, f"{sym}_{tf}.npz")); r = np.load(os.path.join(reach, f"{sym}_{tf}_W{Wmin}.npz"))
        self.sym, self.tf, self.Wmin = sym, tf, Wmin
        self.bm = int(z["barmin"]); self.pt = float(z["point"])
        t = z["t"]; self.t = t
        day = t // 1440; self.mod = (t % 1440).astype(int); self.wd = ((day + 3) % 7).astype(int)     # 0 = Monday
        self.o, self.h, self.l, self.c, self.tv = z["o"], z["h"], z["l"], z["c"], z["tv"]
        self.K = r["K"].astype(float)
        for k in ("up", "dn", "bf", "ba", "sf", "sa", "mae_b", "mae_s", "mfe_up", "mfe_dn", "ret_end", "ncols", "spr"):
            setattr(self, k, r[k])
        span = self.ncols.astype(int) * self.bm
        self.elig = (self.wd < 5) & ((span >= 0.9 * Wmin) | ((Wmin >= 240) & (span >= Wmin - 70)))
        udays = np.unique(day[self.elig])
        self.days = udays; self.dayidx = np.searchsorted(udays, day); self.dayidx[~np.isin(day, udays)] = -1
        self.nd = len(udays); cut = udays[int(len(udays) * SPLIT)]
        self.disc = self.elig & (day < cut); self.val = self.elig & (day >= cut)
        self.cut_date = str(np.datetime64(int(cut), "D"))
        self.first, self.last = str(np.datetime64(int(udays[0]), "D")), str(np.datetime64(int(udays[-1]), "D"))
        self.year = (day.astype("datetime64[D]").astype("datetime64[Y]").astype(int) + 1970)
        self.month = day.astype("datetime64[D]").astype("datetime64[M]").astype(int)
        e = self.elig
        rate = np.maximum((self.up[e] != NOHIT).mean(0), (self.dn[e] != NOHIT).mean(0))
        self.qs = [q for q in range(len(self.K)) if 0.01 <= rate[q] <= 0.97]
        # swap in points per lot per night (swap_mode 1 = points; 3/4 = money in USD -> points via tick value); triple on the Wednesday
        # rollover (FX/metals) or Friday (indices). Charged when the position is still open at server 00:00.
        sp = json.load(open(specs)).get(sym, {}) if specs and os.path.exists(specs) else {}
        mode = int(float(sp.get("swap_mode", 0) or 0)); tvl = float(sp.get("tick_value", 0) or 0); tsz = float(sp.get("tick_size", self.pt) or self.pt)
        conv = 1.0 if mode == 1 else ((tsz / self.pt) / tvl if mode in (3, 4) and tvl > 0 else 0.0)
        self.swap = {"BUY": float(sp.get("swap_long", 0) or 0) * conv, "SELL": float(sp.get("swap_short", 0) or 0) * conv}
        self.triple_wd = 4 if sym in ("US30",) else 2
        self.swap_mode = mode
        self.q2 = {q: int(np.nonzero(self.K == 2 * self.K[q])[0][0]) if (2 * self.K[q]) in self.K else None for q in self.qs}

    # ------------------------------------------------------------------ outcomes for one threshold index q
    def race(self, q):
        u, d = self.up[:, q].astype(int), self.dn[:, q].astype(int)
        y = np.where(u < d, 1.0, np.where(d < u, -1.0, 0.0))
        amb = (u == d) & (u != NOHIT)
        return y, amb

    def swap_cost(self, exit_off):
        """swap (points, signed as P&L) for each entry given the bar offset of its exit."""
        N = len(self.t); j = np.minimum(np.arange(N) + exit_off, N - 1)
        nights = (self.t[j] // 1440) - (self.t // 1440)
        mult = np.where(self.wd == self.triple_wd, 3, 1)
        return nights, mult

    def ev(self, q, side, A, with_swap=True):
        """net points per trade. A: None (no stop: exit at target or window end) or threshold index of the adverse limit."""
        k = self.K[q]
        f = (self.bf if side == "BUY" else self.sf)[:, q].astype(int)
        last = self.ncols.astype(int) - 1
        # time exit: BUY sells at the bid close; SELL buys back at the ASK = bid close + spread of the EXIT bar (rollover spreads matter)
        spr_exit = self.spr[np.minimum(np.arange(len(last)) + last, len(last) - 1)]
        end = (self.ret_end - self.spr) if side == "BUY" else (-self.ret_end - spr_exit)
        if A is None:
            win = f != NOHIT; amb = np.zeros(len(f), bool)
            x = np.where(win, k, end); ex = np.where(win, f, last)
        else:
            a = (self.ba if side == "BUY" else self.sa)[:, A].astype(int)
            win = f < a
            loss = (a <= f) & (a != NOHIT)
            amb = (a == f) & (a != NOHIT)
            x = np.where(win, k, np.where(loss, -self.K[A], end)); ex = np.where(win, f, np.where(loss, a, last))
        if with_swap and self.swap[side] != 0:
            nights, mult = self.swap_cost(ex)
            x = x + np.where(nights > 0, self.swap[side] * mult, 0.0)
        return x, win, amb

    def daymean(self, x):
        m = self.elig & np.isfinite(x)
        s = np.bincount(self.dayidx[m], weights=x[m], minlength=self.nd); n = np.bincount(self.dayidx[m], minlength=self.nd)
        mu = np.where(n > 0, s / np.maximum(n, 1), 0.0)
        return np.where(self.dayidx >= 0, mu[np.maximum(self.dayidx, 0)], 0.0)


def fmt_slot(s, width):
    m = s * width
    return f"{m // 60:02d}:{m % 60:02d}"


# ====================================================================== C: distances
def report_distances(D):
    rows, hour_rows, wd_rows = [], [], []
    e = D.elig
    for q in D.qs:
        k = D.K[q]
        for side in ("BUY", "SELL"):
            f = (D.bf if side == "BUY" else D.sf)[e, q].astype(int); hit = f != NOHIT
            mae = (D.mae_b if side == "BUY" else D.mae_s)[e, q]
            g = (D.up if side == "BUY" else D.dn)[e, q] != NOHIT
            _, win, amb = D.ev(q, side, q, with_swap=False)
            a = (D.ba if side == "BUY" else D.sa)[e, q].astype(int)
            loss = (a <= f) & (a != NOHIT)
            ii = np.nonzero(e)[0][hit]; tm = (D.t[np.minimum(ii + f[hit], len(D.t) - 1)] - D.t[ii]).astype(float)
            lo, hi = wilson(hit.sum(), len(hit))
            rows.append(dict(k_pts=int(k), side=side, n=int(e.sum()), days=D.nd, gross_reach_pct=100 * g.mean(), net_reach_pct=100 * hit.mean(),
                             ci95=f"{100 * lo:.1f}-{100 * hi:.1f}", t_med_min=np.median(tm) if len(tm) else np.nan,
                             t_p75_min=np.percentile(tm, 75) if len(tm) else np.nan, t_p90_min=np.percentile(tm, 90) if len(tm) else np.nan,
                             mae_before_med=np.nanmedian(mae) if hit.any() else np.nan, mae_before_p90=np.nanpercentile(mae[hit], 90) if hit.any() else np.nan,
                             race_win_pct=100 * win[e].mean(), race_loss_pct=100 * loss.mean(), race_samebar_pct=100 * amb[e].mean(),
                             race_win_of_determined_pct=100 * win[e].sum() / max(win[e].sum() + loss.sum() - amb[e].sum(), 1),
                             race_neither_pct=100 * (1 - win[e].mean() - loss.mean())))
            hrs = (D.mod[e] // 60)
            n = np.bincount(hrs, minlength=24); hh = np.bincount(hrs, weights=hit, minlength=24)
            for H in range(24):
                if n[H]:
                    hour_rows.append(dict(k_pts=int(k), side=side, hour=H, n=int(n[H]), reach_pct=100 * hh[H] / n[H]))
            wdv = D.wd[e]; n = np.bincount(wdv, minlength=5); hh = np.bincount(wdv, weights=hit, minlength=5)
            for w in range(5):
                wd_rows.append(dict(k_pts=int(k), side=side, weekday=w, n=int(n[w]), reach_pct=100 * hh[w] / max(n[w], 1)))
    return pd.DataFrame(rows), pd.DataFrame(hour_rows), pd.DataFrame(wd_rows)


# ====================================================================== B/E/G: clock scans
def clock_keys(D, gran):
    if gran == "slot":
        w = D.bm; key = D.mod // w; nk = 1440 // w; lab = [fmt_slot(s, w) for s in range(nk)]
    elif gran == "15m":
        w = 15; key = D.mod // w; nk = 96; lab = [fmt_slot(s, w) for s in range(nk)]
    elif gran == "hour":
        key = D.mod // 60; nk = 24; lab = [f"{h:02d}h" for h in range(24)]
    elif gran == "wd_hour":
        key = D.wd * 24 + D.mod // 60; nk = 7 * 24; lab = [f"{'SEG TER QUA QUI SEX SAB DOM'.split()[i // 24]} {i % 24:02d}h" for i in range(nk)]
    return key.astype(int), nk, lab


def collapse_day(D, key, nk, x, mask):
    """for coarser clocks (several entries per day per cell): average per (day, cell) so each day counts once."""
    m = mask & np.isfinite(x) & (D.dayidx >= 0)
    dk = D.dayidx[m].astype(np.int64) * nk + key[m]
    s = np.bincount(dk, weights=x[m], minlength=D.nd * nk); n = np.bincount(dk, minlength=D.nd * nk)
    ok = n > 0
    idx = np.nonzero(ok)[0]
    return (idx % nk).astype(int), (idx // nk).astype(int), s[ok] / n[ok]


def scan_direction(D, gran, perms=200, seed=7):
    key, nk, lab = clock_keys(D, gran)
    rng = np.random.default_rng(seed)
    disc_day = D.days < D.days[int(D.nd * SPLIT)]
    rows, Ys = [], []
    for q in D.qs:
        y, _ = D.race(q)
        ydm = y - D.daymean(y)
        ck, dd, v = collapse_day(D, key, nk, ydm, D.elig)
        Ys.append((q, ck, dd, v))
        isd = disc_day[dd]
        nD, muD, sdD, tD = grp_stats(ck, nk, v, isd); nV, muV, sdV, tV = grp_stats(ck, nk, v, ~isd)
        # raw (not demeaned) up-first / down-first counts, full sample
        cr, dr, vr = collapse_day(D, key, nk, y, D.elig)
        up = np.bincount(cr, weights=(vr > 0), minlength=nk); dn = np.bincount(cr, weights=(vr < 0), minlength=nk); nn = np.bincount(cr, minlength=nk)
        for s in range(nk):
            if nD[s] >= 20 and nV[s] >= 15:
                rows.append(dict(k_pts=int(D.K[q]), clock=lab[s], n_days=int(nn[s]), up_first_pct=100 * up[s] / nn[s], down_first_pct=100 * dn[s] / nn[s],
                                 excess_disc=muD[s], t_disc=tD[s], excess_val=muV[s], t_val=tV[s], p_disc=norm_p(tD[s]) if np.isfinite(tD[s]) else np.nan))
    df = pd.DataFrame(rows)
    if len(df) == 0:
        return df, {}
    df["bh_disc"] = bh_mask(df["p_disc"].to_numpy())
    df["validated"] = df["bh_disc"] & (np.sign(df["t_val"]) == np.sign(df["t_disc"])) & (df["t_val"].abs() >= 1.645)
    df["direction"] = np.where(df["t_disc"] > 0, "BUY (sobe k antes)", "SELL (cai k antes)")
    # sign-flip permutation: per day random sign on the demeaned outcome (same flip for all slots/k of the day)
    maxt, npass = [], []
    for _ in range(perms):
        sg = rng.choice([-1.0, 1.0], D.nd)
        tds, tvs = [], []
        for q, ck, dd, v in Ys:
            vv = v * sg[dd]; isd = disc_day[dd]
            nD, _, _, tD = grp_stats(ck, nk, vv, isd); nV, _, _, tV = grp_stats(ck, nk, vv, ~isd)
            ok = (nD >= 20) & (nV >= 15)
            tds.append(tD[ok]); tvs.append(tV[ok])
        tds = np.concatenate(tds); tvs = np.concatenate(tvs)
        maxt.append(np.nanmax(np.abs(tds)))
        bh = bh_mask(np.array([norm_p(x) if np.isfinite(x) else np.nan for x in tds]))
        npass.append(int((bh & (np.sign(tvs) == np.sign(tds)) & (np.abs(tvs) >= 1.645)).sum()))
    thr = float(np.percentile(maxt, 95))
    df["fwer_disc"] = df["t_disc"].abs() >= thr
    info = dict(tests=len(df), bh_disc=int(df["bh_disc"].sum()), validated=int(df["validated"].sum()), fwer_t=thr,
                fwer_disc=int(df["fwer_disc"].sum()), fwer_and_val=int((df["fwer_disc"] & df["validated"]).sum()),
                placebo_validated_mean=float(np.mean(npass)), placebo_validated_p95=float(np.percentile(npass, 95)), placebo_validated_max=int(np.max(npass)))
    return df, info


def scan_ev(D, gran, perms=20, seed=11):
    key, nk, lab = clock_keys(D, gran)
    rng = np.random.default_rng(seed)
    disc_day = D.days < D.days[int(D.nd * SPLIT)]
    combos = []
    for q in D.qs:
        for side in ("BUY", "SELL"):
            for an, A in (("k", q), ("2k", D.q2[q]), ("sem", None)):
                if an == "2k" and A is None:
                    continue
                x, win, amb = D.ev(q, side, A)
                combos.append((q, side, an, x, win, amb))
    # day-wise slot shuffles for the placebo (identical across combos)
    order = D.dayidx  # entries are time sorted, hence grouped by day
    shuffles = []
    for _ in range(perms):
        o = np.lexsort((rng.random(len(key)), D.dayidx)); kp = np.empty_like(key); kp[o] = key[np.lexsort((np.arange(len(key)), D.dayidx))]
        shuffles.append(kp)
    rows, plc = [], np.zeros(perms)
    for q, side, an, x, win, amb in combos:
        ck, dd, v = collapse_day(D, key, nk, x, D.elig); isd = disc_day[dd]
        nD, muD, sdD, tD = grp_stats(ck, nk, v, isd); nV, muV, sdV, tV = grp_stats(ck, nk, v, ~isd)
        cw, dw, vw = collapse_day(D, key, nk, win.astype(float), D.elig); wr = np.bincount(cw, weights=vw, minlength=nk) / np.maximum(np.bincount(cw, minlength=nk), 1)
        nA = np.bincount(ck, minlength=nk); mA = np.bincount(ck, weights=v, minlength=nk) / np.maximum(nA, 1)
        yrs = D.year[D.elig & np.isfinite(x)]; kk = key[D.elig & np.isfinite(x)]; xx = x[D.elig & np.isfinite(x)]
        for s in range(nk):
            if nD[s] >= 20 and nV[s] >= 15:
                ms = kk == s
                ys = pd.Series(xx[ms]).groupby(yrs[ms]).mean()
                rows.append(dict(k_pts=int(D.K[q]), side=side, adverse=an, clock=lab[s], n_days=int(nA[s]), win_pct=100 * wr[s], ev_pts=mA[s],
                                 ev_disc=muD[s], t_disc=tD[s], ev_val=muV[s], t_val=tV[s], years_pos=f"{int((ys > 0).sum())}/{len(ys)}",
                                 p_disc=norm_p(tD[s]) if np.isfinite(tD[s]) else np.nan))
        for i, kp in enumerate(shuffles):
            ck2, dd2, v2 = collapse_day(D, kp, nk, x, D.elig); isd2 = disc_day[dd2]
            nD2, muD2, _, tD2 = grp_stats(ck2, nk, v2, isd2); nV2, muV2, _, tV2 = grp_stats(ck2, nk, v2, ~isd2)
            ok = (nD2 >= 20) & (nV2 >= 15) & (muD2 > 0) & (tD2 >= 3.0) & (muV2 > 0) & (tV2 >= 1.645)
            plc[i] += ok.sum()
    df = pd.DataFrame(rows)
    if len(df) == 0:
        return df, {}
    df["bh_disc"] = bh_mask(np.where(df["ev_disc"] > 0, df["p_disc"], np.nan))
    df["validated"] = (df["ev_disc"] > 0) & (df["t_disc"] >= 3.0) & (df["ev_val"] > 0) & (df["t_val"] >= 1.645)
    info = dict(tests=len(df), validated=int(df["validated"].sum()), validated_and_bh=int((df["validated"] & df["bh_disc"]).sum()),
                validated_clocks=int(df.loc[df["validated"], ["clock", "side"]].drop_duplicates().shape[0]),
                placebo_mean=float(plc.mean()), placebo_max=int(plc.max()))
    return df, info


# ====================================================================== I: other descriptive regularities
def daily_extremes(D):
    """server hour in which the day's high and low were made (Mon-Fri)."""
    day = D.t // 1440; wd = D.wd
    m = wd < 5
    df = pd.DataFrame(dict(day=day[m], hour=D.mod[m] // 60, h=D.h[m], l=D.l[m]))
    ih = df.groupby("day")["h"].idxmax(); il = df.groupby("day")["l"].idxmin()
    hh = df.loc[ih, "hour"].value_counts(normalize=True).sort_index() * 100
    ll = df.loc[il, "hour"].value_counts(normalize=True).sort_index() * 100
    return pd.DataFrame(dict(pct_dias_max_do_dia=hh, pct_dias_min_do_dia=ll)).fillna(0).reindex(range(24), fill_value=0)


def give_back(D):
    """of the entries that reached +k (net), how many ended the window below the entry price."""
    rows = []
    e = D.elig
    for q in D.qs:
        for side in ("BUY", "SELL"):
            f = (D.bf if side == "BUY" else D.sf)[e, q] != NOHIT
            last = D.ncols.astype(int) - 1
            spx = D.spr[np.minimum(np.arange(len(last)) + last, len(last) - 1)]
            end = ((D.ret_end - D.spr) if side == "BUY" else (-D.ret_end - spx))[e]
            if f.sum() > 30:
                rows.append(dict(k_pts=int(D.K[q]), side=side, hits=int(f.sum()), ended_negative_pct=100 * (end[f] < 0).mean(),
                                 ended_below_half_k_pct=100 * (end[f] < D.K[q] / 2).mean()))
    return pd.DataFrame(rows)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", required=True); ap.add_argument("--reach", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--sym", required=True); ap.add_argument("--tf", required=True); ap.add_argument("--W", type=int, nargs="+", default=[60, 240])
    ap.add_argument("--perms", type=int, default=200); ap.add_argument("--specs", default=None)
    a = ap.parse_args()
    od = os.path.join(a.out, a.sym); os.makedirs(od, exist_ok=True)
    summ = {}
    for W in a.W:
        D = Data(a.cache, a.reach, a.sym, a.tf, W, a.specs)
        tag = f"{a.tf}_W{W}"
        S = dict(first=D.first, last=D.last, days=D.nd, cut=D.cut_date, entries=int(D.elig.sum()), excluded=int((~D.elig & (D.wd < 5)).sum()),
                 K=[int(D.K[q]) for q in D.qs], point=D.pt, spread_med=float(np.nanmedian(D.spr[D.elig])), swap_pts=D.swap, swap_mode=D.swap_mode)
        dist, hrs, wds = report_distances(D)
        dist.to_csv(os.path.join(od, f"C_distancias_{tag}.csv"), index=False, float_format="%.2f")
        hrs.to_csv(os.path.join(od, f"C_alcance_por_hora_{tag}.csv"), index=False, float_format="%.2f")
        wds.to_csv(os.path.join(od, f"C_alcance_por_dia_semana_{tag}.csv"), index=False, float_format="%.2f")
        # minute-by-minute (slot) reach table, BUY and SELL apart -- Report B
        key, nk, lab = clock_keys(D, "slot")
        rows = []
        e = D.elig
        for q in D.qs:
            fb = (D.bf[:, q] != NOHIT).astype(float); fs = (D.sf[:, q] != NOHIT).astype(float)
            n = np.bincount(key[e], minlength=nk)
            hb = np.bincount(key[e], weights=fb[e], minlength=nk); hs = np.bincount(key[e], weights=fs[e], minlength=nk)
            y, amb = D.race(q)
            upf = np.bincount(key[e], weights=(y[e] > 0), minlength=nk); dnf = np.bincount(key[e], weights=(y[e] < 0), minlength=nk)
            tb = pd.Series(np.where(D.bf[e, q] != NOHIT, D.bf[e, q] * D.bm, np.nan)).groupby(key[e]).median().reindex(range(nk))
            ts = pd.Series(np.where(D.sf[e, q] != NOHIT, D.sf[e, q] * D.bm, np.nan)).groupby(key[e]).median().reindex(range(nk))
            mb = pd.Series(D.mae_b[e, q]).groupby(key[e]).median().reindex(range(nk)); ms = pd.Series(D.mae_s[e, q]).groupby(key[e]).median().reindex(range(nk))
            for s in range(nk):
                if n[s]:
                    rows.append(dict(clock=lab[s], k_pts=int(D.K[q]), n=int(n[s]), buy_hits=int(hb[s]), buy_pct=100 * hb[s] / n[s], sell_hits=int(hs[s]),
                                     sell_pct=100 * hs[s] / n[s], up_first_pct=100 * upf[s] / n[s], down_first_pct=100 * dnf[s] / n[s],
                                     buy_t_med_min=tb[s], sell_t_med_min=ts[s], buy_mae_med=mb[s], sell_mae_med=ms[s]))
        pd.DataFrame(rows).to_csv(os.path.join(od, f"B_varredura_relogio_{tag}.csv.gz"), index=False, float_format="%.2f")
        S["B_rows"] = len(rows)
        for gran in (["slot", "15m", "hour", "wd_hour"] if D.bm < 15 else ["slot", "hour", "wd_hour"]):
            if gran == "15m" and D.bm == 15:
                continue
            dfd, inf = scan_direction(D, gran, perms=a.perms)
            dfd.to_csv(os.path.join(od, f"E_direcao_{gran}_{tag}.csv"), index=False, float_format="%.3f")
            dfe, inf2 = scan_ev(D, gran, perms=10 if gran == "slot" else 20)
            dfe.to_csv(os.path.join(od, f"G_ev_{gran}_{tag}.csv.gz"), index=False, float_format="%.2f")
            S[f"dir_{gran}"] = inf; S[f"ev_{gran}"] = inf2
            print(a.sym, tag, gran, inf, inf2, flush=True)
        daily_extremes(D).to_csv(os.path.join(od, f"I_hora_max_min_dia_{a.tf}.csv"), float_format="%.2f")
        give_back(D).to_csv(os.path.join(od, f"F_devolucao_apos_alvo_{tag}.csv"), index=False, float_format="%.2f")
        summ[tag] = S
    p = os.path.join(od, "resumo.json")
    old = json.load(open(p)) if os.path.exists(p) else {}
    old.update(summ)
    json.dump(old, open(p, "w"), indent=1, default=float)


if __name__ == "__main__":
    main()
