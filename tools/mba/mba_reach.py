#!/usr/bin/env python3
"""First-passage engine for the reach study: for EVERY M1 bar as a hypothetical entry at its OPEN, how far / how fast / in which order price
travels within a fixed clock window W (default 60 and 240 min).

Definitions (all in MT5 points of the symbol, point = SYMBOL_POINT; bars are BID):
  gross (price behaviour)   UP_j = max(high[i..i+j]) - open[i]           DN_j = open[i] - min(low[i..i+j])
  executable BUY            entry at ask = open + spread_i ; exit at bid      fav = UP - spread_i           adv = DN + spread_i
  executable SELL           entry at bid = open            ; exit at ask      fav = open - min(low + spr_j)  adv = max(high + spr_j) - open
  t_X[k] = first bar offset j (0 = the entry bar itself) at which X reaches k points; = NOHIT if not reached inside the window.
  When target and adverse limit are first reached in the SAME bar the order is unknown (M1 OHLC) -> the analysis treats it as indeterminate.
Window = bars whose server time is < t_entry + W minutes (clock time: gaps, the daily break and weekends are respected, nothing is assumed
outside the data). Spread_i = tick-measured average spread of the entry bar (bar spread when ticks are missing). Commission not included
(the broker files declare commission_known = FALSE).

  python tools/mba/mba_reach.py --cache <m1cache> --out <reach_cache> [--windows 60 240] [--jobs 4]
"""
import argparse, os, sys, time
from multiprocessing import Pool
import numpy as np
from numpy.lib.stride_tricks import sliding_window_view as swv

sys.stdout.reconfigure(encoding="utf-8")
K = np.array([25, 50, 100, 150, 200, 300, 400, 500, 600, 800, 1000, 1500, 2000, 3000, 5000, 8000, 10000, 15000, 20000, 30000], dtype=np.float32)
NOHIT = np.int16(32767)
CHUNK = 40000


def first_passage(acc, thr_shift=None):
    """acc: running max (rows x W, nondecreasing). Returns int16 rows x len(K): first column where acc >= K (NOHIT if never)."""
    a = acc if thr_shift is None else acc - thr_shift[:, None]
    lev = np.searchsorted(K, a, side="right").astype(np.int16)          # number of thresholds reached at each column
    rows, W = lev.shape
    flat = (np.arange(rows)[:, None] * (len(K) + 1) + lev).ravel()
    cnt = np.bincount(flat, minlength=rows * (len(K) + 1)).reshape(rows, len(K) + 1)
    # columns with level <= q have NOT reached K[q]; acc is monotone, so that count is the first-passage column
    before = np.cumsum(cnt, axis=1)[:, :len(K)]
    return np.where(before >= W, NOHIT, before).astype(np.int16)


def run_symbol(args):
    sym, cache, out, windows = args
    z = np.load(os.path.join(cache, f"{sym}.npz"))
    t, o, h, l, c, spr = z["t"], z["o"], z["h"], z["l"], z["c"], z["spr"]
    pt = float(z["point"]); bm = int(z["barmin"])
    # Cost: tick-measured spread of the bar when ticks exist; otherwise the median tick-measured spread of the same 30-min server slot
    # (rates.spread is 0/fixed on ECN feeds, so old bars without ticks would look free). Fallback: bar spread.
    tok = z["tok"].astype(bool)
    spr = np.where(np.isfinite(spr) & (spr >= 0), spr, np.nan)
    slot = (t % 1440) // 30
    if tok.sum() >= 500:
        prof = np.full(48, np.nan)
        for s_ in range(48):
            v = spr[tok & (slot == s_)]
            if len(v) >= 20:
                prof[s_] = np.median(v)
        prof = np.where(np.isnan(prof), np.nanmedian(spr[tok]), prof)
        spr = np.where(tok & np.isfinite(spr), spr, prof[slot])
    spr = np.where(np.isnan(spr), np.nanmedian(spr), spr).astype(np.float32)
    N = len(t)
    t0 = time.time()
    for Wmin in windows:
        W = Wmin // bm                                   # columns (bars) in the window; the clock limit is Wmin minutes
        pad = W - 1
        tp = np.concatenate([t, np.full(pad, t[-1] + 10 ** 7)])
        hp = np.concatenate([h, np.full(pad, np.nan)]); lp = np.concatenate([l, np.full(pad, np.nan)])
        cp = np.concatenate([c, np.full(pad, np.nan)]); sp = np.concatenate([spr, np.full(pad, np.nan, np.float32)])
        res = {k: np.empty((N, len(K)), np.int16) for k in ("up", "dn", "bf", "ba", "sf", "sa")}
        mae_b = np.empty((N, len(K)), np.float32); mae_s = np.empty((N, len(K)), np.float32)
        mfe_up = np.empty(N, np.float32); mfe_dn = np.empty(N, np.float32); ret_end = np.empty(N, np.float32)
        ncols = np.empty(N, np.int16)
        for s in range(0, N, CHUNK):
            e = min(N, s + CHUNK)
            T = swv(tp, W)[s:e]; valid = (T - t[s:e, None]) < Wmin
            ncols[s:e] = valid.sum(1)
            o0 = o[s:e, None]
            H = np.where(valid, swv(hp, W)[s:e], -np.inf); L = np.where(valid, swv(lp, W)[s:e], np.inf)
            S = np.where(valid, swv(sp, W)[s:e], 0)
            UP = np.maximum.accumulate(((H - o0) / pt).astype(np.float32), axis=1)
            DN = np.maximum.accumulate(((o0 - L) / pt).astype(np.float32), axis=1)
            SF = np.maximum.accumulate(((o0 - L) / pt - S).astype(np.float32), axis=1)
            SA = np.maximum.accumulate(((H - o0) / pt + S).astype(np.float32), axis=1)
            si = spr[s:e]
            res["up"][s:e] = first_passage(UP); res["dn"][s:e] = first_passage(DN)
            res["bf"][s:e] = first_passage(UP, si); res["ba"][s:e] = first_passage(DN, -si)
            res["sf"][s:e] = first_passage(SF); res["sa"][s:e] = first_passage(SA)
            # adverse excursion accumulated up to (and including) the bar where the target is first reached; NaN when not reached
            idx_b = np.minimum(res["bf"][s:e], W - 1).astype(np.int64); idx_s = np.minimum(res["sf"][s:e], W - 1).astype(np.int64)
            mb = np.take_along_axis(DN, idx_b, 1) + si[:, None]; ms = np.take_along_axis(SA, idx_s, 1)
            mae_b[s:e] = np.where(res["bf"][s:e] == NOHIT, np.nan, mb); mae_s[s:e] = np.where(res["sf"][s:e] == NOHIT, np.nan, ms)
            mfe_up[s:e] = UP[:, -1]; mfe_dn[s:e] = DN[:, -1]
            last = ncols[s:e].astype(np.int64) - 1
            ce = np.take_along_axis(swv(cp, W)[s:e], last[:, None], 1)[:, 0]
            ret_end[s:e] = (ce - o[s:e]) / pt
        np.savez(os.path.join(out, f"{sym}_W{Wmin}.npz"), **res, mae_b=mae_b, mae_s=mae_s, mfe_up=mfe_up, mfe_dn=mfe_dn, ret_end=ret_end,
                 ncols=ncols, spr=spr, K=K, W=W, Wmin=Wmin, barmin=bm)
        print(f"{sym} W={Wmin}min N={N} {time.time() - t0:.0f}s", flush=True)
    return sym


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--windows", type=int, nargs="+", default=[60, 240]); ap.add_argument("--jobs", type=int, default=4)
    ap.add_argument("--symbols", nargs="*")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    syms = a.symbols or sorted(f[:-4] for f in os.listdir(a.cache) if f.endswith(".npz"))
    with Pool(a.jobs) as p:
        for s in p.imap_unordered(run_symbol, [(s, a.cache, a.out, a.windows) for s in syms]):
            print("done", s, flush=True)


if __name__ == "__main__":
    main()
