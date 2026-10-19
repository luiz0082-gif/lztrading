#!/usr/bin/env python3
"""MBA pattern mining with out-of-sample validation and a time-shift placebo.

  python tools/mba/mba_mine.py --live "<.../LIVE>" --out docs/relatorios/mba/mine_DXY.md

Universe: events of M5/M15/M30/H1 (schema 3) x horizons of FORWARD_TIME (minutes, measured on M1 bars).
Hypothesis for each cell (feature A = a  AND  feature B = b, singles included): mean forward return in ATR units != 0.
  * chronological split: first 60% = discovery, last 40% = validation, 1 day embargo between them
  * t-statistics use an effective sample size n*min(1, tf_minutes/horizon) (overlapping forward windows are not independent)
  * Benjamini-Hochberg (q=0.05) over ALL cells tested in discovery
  * a cell is "validated" if the sign repeats in validation with one-sided p<0.05
  * PLACEBO: the same pipeline on forward returns circularly shifted by a random lag (features and returns decoupled).
    Anything the real data does not beat the placebo by is chance.
Costs: net points = side * return_points - cost_points (bar spread + declared commission) for the validated cells.
"""
import argparse, glob, math, os, sys, time
import numpy as np
sys.stdout.reconfigure(encoding="utf-8")
import pandas as pd

TFS = {"M5": 5, "M15": 15, "M30": 30, "H1": 60}
HZ = [5, 15, 30, 60, 120, 240]
EV_COLS = ["event_key", "server_time", "slot_hhmm", "day_of_week", "hour", "session", "direction", "body_pct", "upper_wick_pct", "lower_wick_pct",
           "close_position", "range_atr", "volume_ratio", "tick_density_ratio", "spread_avg_points", "pattern", "structure_before", "structure_at_close",
           "volatility_state", "price_position_daily_open", "price_position_weekly_open", "price_position_monthly_open", "previous_high_distance_atr",
           "previous_low_distance_atr", "prev_day_high_distance_atr", "prev_day_low_distance_atr", "session_high_distance_atr", "session_low_distance_atr",
           "swing_high_distance_atr", "swing_low_distance_atr", "mtf_M1", "mtf_M5", "mtf_M15", "mtf_M30", "mtf_H1", "mtf_H4", "mtf_D1", "mtf_W1",
           "news_state", "news_high_events_60m", "news_min_to_next_high", "news_min_since_last_high", "gap_bars", "schema_version"]
CAT = ["slot_hhmm", "day_of_week", "hour", "session", "direction", "structure_before", "structure_at_close", "volatility_state", "mtf_M1", "mtf_M5",
       "mtf_M15", "mtf_M30", "mtf_H1", "mtf_H4", "mtf_D1", "mtf_W1", "news_state"]
NUM = ["body_pct", "upper_wick_pct", "lower_wick_pct", "close_position", "range_atr", "volume_ratio", "tick_density_ratio", "spread_avg_points",
       "price_position_daily_open", "price_position_weekly_open", "price_position_monthly_open", "previous_high_distance_atr", "previous_low_distance_atr",
       "prev_day_high_distance_atr", "prev_day_low_distance_atr", "session_high_distance_atr", "session_low_distance_atr", "swing_high_distance_atr",
       "swing_low_distance_atr", "news_min_to_next_high", "news_min_since_last_high"]
HIT_HZ = [15, 60, 240]
HIT_TGT = [("a050", 0.5), ("a100", 1.0), ("a200", 2.0)]
HIT_TGT_K = [(tg, k) for tg, k in HIT_TGT]
HIT_SERIES = [(side, tg, k, h) for side in (1, -1) for tg, k in HIT_TGT for h in HIT_HZ]   # long/short x ATR target x horizon (min)
PATTERNS = ["DOJI", "HAMMER", "INVERTED_HAMMER", "SHOOTING_STAR", "HANGING_MAN", "BULLISH_ENGULFING", "BEARISH_ENGULFING", "INSIDE_BAR", "OUTSIDE_BAR",
            "PIN_BAR", "MARUBOZU", "HARAMI", "TWEEZER_TOP", "TWEEZER_BOTTOM", "MORNING_STAR_3BAR", "EVENING_STAR_3BAR"]


def read_parts(folder, base, usecols):
    out = []
    for fn in sorted(glob.glob(os.path.join(folder, base + "_part*.csv"))):
        d = pd.read_csv(fn, usecols=lambda c: c in usecols, low_memory=False)
        if "schema_version" in d.columns:
            d = d[d["schema_version"].astype(str) == "3"]
        out.append(d)
    return pd.concat(out, ignore_index=True) if out else pd.DataFrame()


def load_tf(live, tf):
    ev = read_parts(os.path.join(live, "EVENTS"), f"events_{tf}", EV_COLS)
    ev = ev.drop_duplicates("event_key")
    ft = read_parts(os.path.join(live, "FORWARD_TIME"), f"forward_time_{tf}",
                    ["event_key", "horizon_min", "complete", "future_return_points", "future_return_atr", "cost_points", "schema_version"] + [f"hit_{d}_{tg}_min" for tg, _ in HIT_TGT for d in ("up", "dn")])
    ft = ft[(ft["complete"].astype(str).str.upper() == "TRUE") & ft["horizon_min"].isin(HZ)]
    ft = ft.drop_duplicates(["event_key", "horizon_min"])
    ret_atr = ft.pivot(index="event_key", columns="horizon_min", values="future_return_atr").reindex(columns=HZ)
    ret_pts = ft.pivot(index="event_key", columns="horizon_min", values="future_return_points").reindex(columns=HZ)
    cost = ft.pivot(index="event_key", columns="horizon_min", values="cost_points").reindex(columns=HZ)
    ev = ev.set_index("event_key").join(ret_atr.add_prefix("ra"), how="inner").join(ret_pts.add_prefix("rp")).join(cost.add_prefix("cp"))
    # ---- target-exit payoffs (no stop): exit at the ATR target if touched inside the horizon, otherwise at the horizon close; net of cost, in ATR units
    atr_pts = (ft[ft["future_return_atr"].abs() > 1e-6].assign(a=lambda d: (d["future_return_points"] / d["future_return_atr"]).abs())
               .groupby("event_key")["a"].median())
    ev = ev.join(atr_pts.rename("atr_pts"))
    for side, tg, k, h in HIT_SERIES:
        sub = ft[ft["horizon_min"] == h].drop_duplicates("event_key").set_index("event_key")
        hit = pd.to_numeric(sub[f"hit_{'up' if side > 0 else 'dn'}_{tg}_min"], errors="coerce")
        ret_atr_h = sub["future_return_atr"]; cost_h = sub["cost_points"]
        pay = np.where(hit.notna(), k, side * ret_atr_h)
        ser = pd.Series(pay, index=sub.index)
        ev["py_%d_%s_%d" % (side, tg, h)] = ser.reindex(ev.index) - cost_h.reindex(ev.index) / ev["atr_pts"]
    ev["t"] = pd.to_datetime(ev["server_time"], format="%Y.%m.%d %H:%M:%S")
    return ev.sort_values("t")


def build_features(ev, n_disc):
    """integer codes per feature (-1 = missing); numeric features binned in quintiles of the DISCOVERY part only."""
    feats, labels = {}, {}
    for c in CAT:
        cat = ev[c].astype(str).where(ev[c].notna(), np.nan)
        cat = cat.where(~cat.isin(["UNKNOWN", "nan"]), np.nan)
        codes, uniq = pd.factorize(cat)
        feats[c] = codes.astype(np.int32); labels[c] = list(uniq)
    for c in NUM:
        v = pd.to_numeric(ev[c], errors="coerce").to_numpy(float)
        edges = np.nanquantile(v[:n_disc], [.2, .4, .6, .8]) if np.isfinite(v[:n_disc]).sum() > 100 else None
        if edges is None or len(np.unique(edges)) < 3:
            continue
        code = np.digitize(v, edges).astype(np.int32)
        code[~np.isfinite(v)] = -1
        feats[c] = code; labels[c] = [f"Q{i + 1}" for i in range(5)]
    pat = ev["pattern"].fillna("")
    for p in PATTERNS:
        has = pat.str.contains(p, regex=False).to_numpy()
        feats["pat_" + p] = np.where(has, 0, -1).astype(np.int32); labels["pat_" + p] = ["Y"]
    feats["gap"] = np.where(pd.to_numeric(ev["gap_bars"], errors="coerce").fillna(0).to_numpy() > 0, 0, -1).astype(np.int32); labels["gap"] = ["Y"]
    feats["ALL"] = np.zeros(len(ev), np.int32); labels["ALL"] = ["*"]
    keep = [k for k in feats if len(labels[k]) > 0 and (feats[k] >= 0).sum() > 200]
    return {k: feats[k] for k in keep}, {k: labels[k] for k in keep}


def sums(code, ncell, Y, V):
    n = np.stack([np.bincount(code, weights=V[:, j], minlength=ncell) for j in range(Y.shape[1])], 1)
    s = np.stack([np.bincount(code, weights=Y[:, j], minlength=ncell) for j in range(Y.shape[1])], 1)
    q = np.stack([np.bincount(code, weights=Y[:, j] ** 2, minlength=ncell) for j in range(Y.shape[1])], 1)
    return n, s, q


VAR_FLOOR = None      # optional per-series variance floor (shape (S,)); used for binary hit rates, where a cell with 100% hits has zero sample variance


def tstat(n, s, q, f, min_n):
    with np.errstate(all="ignore"):
        m = s / n
        var = q / n - m ** 2
        if VAR_FLOOR is not None:
            var = np.maximum(var, VAR_FLOOR[None, :])
        t = m / np.sqrt(var / (n * f))
    ok = (n >= min_n) & np.isfinite(t) & (var > 1e-12)
    return m, np.where(ok, t, 0.0), ok


def run_pipeline(feats, Yd, Vd, Yv, Vv, di, vi, f, names, min_n_d, min_n_v):
    """returns arrays over all tested cells: pair index, cell, h index, t_disc, m_disc, n_disc, t_val, n_val"""
    P, C, Hh, TD, MD, ND, TV, NV = ([] for _ in range(8))
    for a in range(len(names)):
        for b in range(a, len(names)):
            if a == b and names[a] != "ALL":
                continue
            fa, fb = feats[names[a]], feats[names[b]]
            ca_n = int(fa.max()) + 1; cb_n = int(fb.max()) + 1
            ncell = ca_n * cb_n
            ok_d = (fa[di] >= 0) & (fb[di] >= 0); ok_v = (fa[vi] >= 0) & (fb[vi] >= 0)
            if ok_d.sum() < min_n_d: continue
            cd = (fa[di][ok_d].astype(np.int64) * cb_n + fb[di][ok_d]); cv = (fa[vi][ok_v].astype(np.int64) * cb_n + fb[vi][ok_v])
            n, s, q = sums(cd, ncell, Yd[ok_d], Vd[ok_d]); md, td, okd = tstat(n, s, q, f, min_n_d)
            n2, s2, q2 = sums(cv, ncell, Yv[ok_v], Vv[ok_v]); mv, tv, okv = tstat(n2, s2, q2, f, min_n_v)
            cells, hs = np.nonzero(okd & okv)
            if len(cells) == 0: continue
            P.append(np.full(len(cells), a * 1000 + b, np.int32)); C.append(cells.astype(np.int32)); Hh.append(hs.astype(np.int8))
            TD.append(td[cells, hs]); MD.append(md[cells, hs]); ND.append(n[cells, hs]); TV.append(tv[cells, hs]); NV.append(n2[cells, hs])
    cat = lambda L, dt: np.concatenate(L).astype(dt) if L else np.zeros(0, dt)
    return dict(pair=cat(P, np.int32), cell=cat(C, np.int32), h=cat(Hh, np.int8), td=cat(TD, float), md=cat(MD, float), nd=cat(ND, float),
                tv=cat(TV, float), nv=cat(NV, float))


def bh_count(t, q=0.05):
    a = np.sort(np.abs(t))[::-1]
    m = len(a); K = min(m, 400000)
    p = np.array([math.erfc(x / math.sqrt(2)) for x in a[:K]])
    thr = (np.arange(1, K + 1) / m) * q
    ok = np.nonzero(p <= thr)[0]
    return (ok[-1] + 1) if len(ok) else 0, m


def summarize(res, tops=(100, 1000, 10000)):
    td, tv = res["td"], res["tv"]
    order = np.argsort(-np.abs(td))
    sgn = np.sign(td)
    out = {}
    for N in tops:
        idx = order[:N]
        out[N] = float(np.mean((sgn[idx] * tv[idx]) > 1.645)) if len(idx) else float("nan")
    nbh, m = bh_count(td)
    sel = order[:nbh]
    val = int(np.sum((sgn[sel] * tv[sel]) > 1.645)) if nbh else 0
    return out, nbh, m, val, order


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--live", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--placebos", type=int, default=8); ap.add_argument("--min-n", type=int, default=120)
    ap.add_argument("--tfs", default="M5,M15,M30,H1")
    ap.add_argument("--mode", default="ret", choices=["ret", "hit"])
    a = ap.parse_args()
    lines = []; P = lambda s="": (lines.append(s), print(s, flush=True))
    P(f"# Mineração MBA — {a.live}\n")
    rng = np.random.default_rng(7)
    all_top = []
    for tf in a.tfs.split(","):
        t0 = time.time()
        ev = load_tf(a.live, tf)
        n = len(ev)
        if n < 2000:
            P(f"## {tf}: poucos eventos ({n}), ignorado\n"); continue
        t_split = ev["t"].iloc[int(n * 0.6)]
        di = np.nonzero((ev["t"] < t_split - pd.Timedelta(days=1)).to_numpy())[0]
        vi = np.nonzero((ev["t"] >= t_split).to_numpy())[0]
        feats, labels = build_features(ev, len(di))
        names = list(feats.keys())
        if a.mode == "ret":
            RA = ev[[f"ra{h}" for h in HZ]].to_numpy(float); RP = ev[[f"rp{h}" for h in HZ]].to_numpy(float); CP = ev[[f"cp{h}" for h in HZ]].to_numpy(float)
            f = np.array([min(1.0, TFS[tf] / h) for h in HZ]); SER = [("ret", h) for h in HZ]
        else:
            RA = ev[[f"py_{s}_{tg}_{h}" for s, tg, k, h in HIT_SERIES]].to_numpy(float)
            f = np.array([min(1.0, TFS[tf] / h) for s, tg, k, h in HIT_SERIES]); SER = HIT_SERIES
            RP = RA * ev["atr_pts"].to_numpy(float)[:, None]; CP = np.zeros_like(RA)   # net payoff in points (cost already inside)
        V = np.isfinite(RA).astype(float); Y = np.nan_to_num(RA)
        NS = RA.shape[1]
        P(f"## {tf}\n")
        P(f"- eventos com horizontes completos: {n:,} ({ev['t'].iloc[0]:%Y-%m-%d} a {ev['t'].iloc[-1]:%Y-%m-%d}); descoberta {len(di):,}, validação {len(vi):,}, corte {t_split:%Y-%m-%d}")
        P(f"- variáveis: {len(names)-1} (categóricas, quintis, padrões) → pares testados em {NS} séries ({'horizontes' if a.mode=='ret' else 'lado x alvo ATR x horizonte, saída por alvo sem stop'})")
        res = run_pipeline(feats, Y[di], V[di], Y[vi], V[vi], di, vi, f, names, a.min_n, max(40, a.min_n // 3))
        if a.mode == "hit": res["td"] = np.where(res["td"] > 0, res["td"], 0.0)   # only positive net expectancy matters
        top, nbh, m, val, order = summarize(res)
        P(f"- **hipóteses testadas (células com amostra mínima): {m:,}**")
        P(f"- passaram no BH (q=5%) na descoberta: **{nbh:,}**; destas, confirmaram na validação (mesmo sinal, p<0,05 unilateral): **{val:,}**")
        P(f"- das N melhores (|t| da descoberta), % que confirmam na validação: " + ", ".join(f"top {k}: {100*v:.1f}%" for k, v in top.items()))
        pl = {k: [] for k in top}; pl_bh = []; pl_val = []
        for k in range(a.placebos):
            lag = int(rng.integers(3000, max(3001, n - 3000)))
            Yp = np.roll(Y, lag, axis=0); Vp = np.roll(V, lag, axis=0)
            rp = run_pipeline(feats, Yp[di], Vp[di], Yp[vi], Vp[vi], di, vi, f, names, a.min_n, max(40, a.min_n // 3))
            if a.mode == "hit": rp["td"] = np.where(rp["td"] > 0, rp["td"], 0.0)
            tp, nb, _, vv, _ = summarize(rp)
            for kk in top: pl[kk].append(tp[kk])
            pl_bh.append(nb); pl_val.append(vv)
        P(f"- **PLACEBO** ({a.placebos} deslocamentos aleatórios do retorno): " + ", ".join(f"top {k}: {100*np.mean(v):.1f}% (máx {100*np.max(v):.1f}%)" for k, v in pl.items()) +
          f"; BH na descoberta: média {np.mean(pl_bh):.1f} (máx {np.max(pl_bh)}); confirmadas: média {np.mean(pl_val):.1f} (máx {np.max(pl_val)})")
        # best validated cells (economics)
        sgn = np.sign(res["td"]); good = np.nonzero((sgn * res["tv"] > 1.645))[0]
        good = good[np.argsort(-np.abs(res["td"][good]))][:15]
        if nbh == 0:
            P("- Nenhuma célula passou na correção de múltiplos testes na descoberta.")
        P("\n| par de condições | horizonte | n desc/val | t desc | t val | lado | líquido médio na validação (pts) | custo médio (pts) |\n|---|---|---|---|---|---|---|---|")
        for g in good:
            i, j = divmod(int(res["pair"][g]), 1000); cb_n = int(feats[names[j]].max()) + 1
            ia, ib = divmod(int(res["cell"][g]), cb_n); hh = int(res["h"][g])
            side = (1 if res["md"][g] > 0 else -1) if a.mode == "ret" else SER[hh][0]
            msk = (feats[names[i]][vi] == ia) & (feats[names[j]][vi] == ib) & np.isfinite(RP[vi, hh])
            net = (side * RP[vi, hh][msk] - CP[vi, hh][msk]) if a.mode == "ret" else RP[vi, hh][msk]
            la = f"{names[i]}={labels[names[i]][ia]}" + ("" if names[j] == "ALL" else f" & {names[j]}={labels[names[j]][ib]}")
            P(f"| {la} | {(str(HZ[hh]) + ' min') if a.mode == 'ret' else ('alvo %sxATR, ate %d min' % (dict(HIT_TGT_K)[SER[hh][1]], SER[hh][3]))} | {int(res['nd'][g])}/{int(res['nv'][g])} | {res['td'][g]:.2f} | {res['tv'][g]:.2f} | {'COMPRA' if side>0 else 'VENDA'} | {net.mean():.2f} | {CP[vi, hh][msk].mean():.2f} |")
        P(f"\n_(tempo {time.time()-t0:.0f}s)_\n")
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    open(a.out, "w", encoding="utf-8").write("\n".join(lines))


if __name__ == "__main__":
    sys.exit(main())
