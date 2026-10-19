#!/usr/bin/env python3
"""MBA full per-symbol research report (descriptive + mining with out-of-sample validation, placebo and a realistic cost model).

  python tools/mba/mba_report.py --live "<.../LIVE>" --name XAUUSD --out docs/relatorios/mba/ativos/XAUUSD

Cost model (bid-based bars): a LONG pays the spread at ENTRY (buys at ask, sells at bid); a SHORT pays the spread at EXIT (sells at bid,
buys back at ask). Entry spread = bar spread of the event candle. Exit spread = bar spread of the M5 candle at the exit time when it exists,
otherwise the median spread of that time of day. This avoids the v1 mistake of charging the entry-bar spread to shorts (rollover artefacts).
"""
import argparse, glob, math, os, sys, time
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mba_mine as m

sys.stdout.reconfigure(encoding="utf-8")
TFMIN = {"M5": 5, "M15": 15, "M30": 30, "H1": 60}
EXTRA_CAT = ["month", "dom_w", "dow_slot", "streak", "streak_prev"]
PRE_ALLOWED = {"slot_hhmm", "day_of_week", "hour", "session", "month", "dom_w", "dow_slot", "structure_before", "news_state", "streak_prev", "gap", "ALL",
               "mtf_M1", "mtf_M5", "mtf_M15", "mtf_M30", "mtf_H1", "mtf_H4", "mtf_D1", "mtf_W1", "news_min_to_next_high", "news_min_since_last_high",
               "p1", "p2", "pcum3", "pcum10", "range_atr_prev", "atr_ratio_prev"}
EXTRA_NUM = ["p1", "p2", "cum3", "cum10", "range_atr_prev", "atr_ratio", "cost_atr", "ret_bar_atr", "pcum3", "pcum10", "atr_ratio_prev"]
CAND_COLS = ["event_key", "server_time", "utc_time", "open", "high", "low", "close", "atr", "range_atr", "tick_volume", "tick_count", "tick_data_ok",
             "spread_avg_points", "bar_spread_points", "ohlc_vs_ticks", "ohlc_dev_points", "gap_bars", "direction", "schema_version"]


def md_table(df, floatfmt=2):
    if df is None or len(df) == 0:
        return "_(sem linhas)_\n"
    cols = list(df.columns)
    out = ["| " + " | ".join(str(c) for c in cols) + " |", "|" + "|".join("---" for _ in cols) + "|"]
    arrs = {c: df[c].tolist() for c in cols}
    for k in range(len(df)):
        cells = []
        for c in cols:
            v = arrs[c][k]
            if isinstance(v, (bool, np.bool_)):
                cells.append("sim" if v else "nao")
            elif isinstance(v, (int, np.integer)):
                cells.append(f"{int(v):,}")
            elif isinstance(v, (float, np.floating)):
                cells.append("" if not np.isfinite(v) else (f"{int(v):,}" if float(v).is_integer() and abs(v) >= 1 and c in ("n", "n_desc", "n_val", "hora_utc", "dia(0=seg)") else f"{v:,.{floatfmt}f}"))
            else:
                cells.append(str(v))
        out.append("| " + " | ".join(cells) + " |")
    return "\n".join(out) + "\n"


def norm_cdf_p(t):
    return math.erfc(abs(t) / math.sqrt(2))


def read_spec(live):
    fs = glob.glob(os.path.join(live, "META", "symbol_spec_part*.csv"))
    if not fs:
        return {}
    d = pd.read_csv(fs[0])
    return d.iloc[-1].to_dict()


def load_candles(live, tf):
    d = m.read_parts(os.path.join(live, "CANDLES"), f"candles_{tf}", CAND_COLS)
    if len(d) == 0:
        return d
    d = d.drop_duplicates("event_key")
    d["t"] = pd.to_datetime(d["server_time"], format="%Y.%m.%d %H:%M:%S")
    d["u"] = pd.to_datetime(d["utc_time"], format="%Y.%m.%d %H:%M:%S", errors="coerce")
    d = d.sort_values("t").reset_index(drop=True)
    # The EA writes atr/range with only 2 decimals (0.00 for 5-digit FX), so ATR(14) is recomputed from the OHLC columns (full precision).
    prev = d["close"].shift(1)
    tr = np.maximum.reduce([(d["high"] - d["low"]).to_numpy(), (d["high"] - prev).abs().fillna(0).to_numpy(), (d["low"] - prev).abs().fillna(0).to_numpy()])
    d["atr"] = pd.Series(tr).rolling(14, min_periods=14).mean().to_numpy()
    return d


# --------------------------------------------------------------------------------------------------------------------------- mining data
def ny_off_hours(u):
    """US Eastern offset (-4 during US DST, -5 otherwise) for UTC timestamps; DST: 2nd Sunday of March 07:00 UTC .. 1st Sunday of November 06:00 UTC."""
    uu = pd.to_datetime(pd.Series(u).reset_index(drop=True))
    out = np.full(len(uu), -5.0)
    for y in uu.dt.year.dropna().unique():
        d = pd.Timestamp(int(y), 3, 1)
        start = d + pd.Timedelta(days=(6 - d.weekday()) % 7 + 7, hours=7)
        n = pd.Timestamp(int(y), 11, 1)
        end = n + pd.Timedelta(days=(6 - n.weekday()) % 7, hours=6)
        out[((uu >= start) & (uu < end)).to_numpy()] = -4.0
    return out


def slot30(u):
    """30-minute slot (0..47) of the New-York clock: spread behaviour (rollover at 17:00 NY) follows NY time, not UTC."""
    uu = pd.to_datetime(pd.Series(u).reset_index(drop=True))
    ny = uu + pd.to_timedelta(ny_off_hours(uu), unit="h")
    return (ny.dt.hour * 2 + ny.dt.minute // 30 + 48 * (ny.dt.dayofweek == 6)).to_numpy()      # +48 = Sunday (week-open liquidity is different)


def build_mining_frame(live, tf, point, s5, prof):
    ev = m.read_parts(os.path.join(live, "EVENTS"), f"events_{tf}", m.EV_COLS).drop_duplicates("event_key")
    cd = load_candles(live, tf)
    if len(ev) == 0 or len(cd) == 0:
        return None
    ft = m.read_parts(os.path.join(live, "FORWARD_TIME"), f"forward_time_{tf}",
                      ["event_key", "horizon_min", "complete", "future_return_points", "future_return_atr"] +
                      [f"hit_{d}_{tg}_min" for tg, _ in m.HIT_TGT for d in ("up", "dn")] + ["schema_version"])
    if len(ft) == 0:
        return None
    ft = ft[(ft["complete"].astype(str).str.upper() == "TRUE") & ft["horizon_min"].isin(m.HZ)].drop_duplicates(["event_key", "horizon_min"])
    ev = ev.set_index("event_key").join(cd.set_index("event_key")[["t", "u", "open", "close", "atr", "range_atr", "bar_spread_points", "tick_count"]], how="inner", rsuffix="_c")
    ev = ev.sort_values("t")
    # ---- derived features (all known at the close of the event candle)
    atr_pts = ev["atr"] / point
    ev["atr_pts"] = atr_pts
    ev["ret_bar_atr"] = (ev["close"] - ev["open"]) / ev["atr"]
    ev["p1"] = ev["ret_bar_atr"].shift(1); ev["p2"] = ev["ret_bar_atr"].shift(2)
    ev["cum3"] = ev["ret_bar_atr"].rolling(3).sum(); ev["cum10"] = ev["ret_bar_atr"].rolling(10).sum()
    ev["range_atr_prev"] = ev["range_atr_c"].shift(1) if "range_atr_c" in ev else ev["range_atr"].shift(1)
    ev["atr_ratio"] = ev["atr"] / ev["atr"].rolling(500, min_periods=100).median()
    dirn = np.sign(ev["close"] - ev["open"]).to_numpy()
    st = np.zeros(len(ev), int); run = 0
    for i, d in enumerate(dirn):
        run = (run + 1 if i > 0 and d == dirn[i - 1] and d != 0 else 1)
        st[i] = min(run, 6) * (1 if d >= 0 else -1)
    ev["streak"] = pd.Series(st, index=ev.index).astype(str)
    ev["streak_prev"] = ev["streak"].shift(1)
    ev["pcum3"] = ev["ret_bar_atr"].shift(1).rolling(3).sum(); ev["pcum10"] = ev["ret_bar_atr"].shift(1).rolling(10).sum()
    ev["atr_ratio_prev"] = ev["atr_ratio"].shift(1)
    ev["month"] = ev["t"].dt.month.astype(str)
    ev["dom_w"] = pd.cut(ev["t"].dt.day, [0, 7, 14, 21, 31], labels=["d01_07", "d08_14", "d15_21", "d22_31"]).astype(str)
    ev["dow_slot"] = ev["day_of_week"].astype(str) + "|" + ev["slot_hhmm"].astype(str)
    # ---- cost model. The recorded bar spread is unreliable (0 in most bars of ECN accounts and below the tick spread elsewhere), so every
    # spread used is max(bar spread, median TICK-measured spread of that New-York half-hour slot). Long pays at entry, short pays at exit.
    n = len(ev)
    tfm = TFMIN[tf]
    pf = lambda uu: prof.reindex(slot30(uu)).to_numpy(float)
    spr_bar = ev["bar_spread_points"].astype(float).to_numpy()
    ent = np.fmax(spr_bar, pf(ev["u"] + pd.to_timedelta(tfm, unit="m")))
    ev["cost_atr"] = ent / atr_pts.to_numpy(float)
    CL = np.repeat(ent[:, None], len(m.HZ), 1)
    CS = np.zeros((n, len(m.HZ)))
    for j, h in enumerate(m.HZ):
        key = ev["t"] + pd.to_timedelta(tfm + h - 5, unit="m")                 # M5 candle that ends at the exit
        sb = s5.reindex(key).to_numpy(float) if s5 is not None else np.full(n, np.nan)
        CS[:, j] = np.fmax(sb, pf(ev["u"] + pd.to_timedelta(tfm + h, unit="m")))
    # ---- forward matrices
    piv = lambda col: ft.pivot(index="event_key", columns="horizon_min", values=col).reindex(index=ev.index, columns=m.HZ)
    RA, RP = piv("future_return_atr").to_numpy(float), piv("future_return_points").to_numpy(float)
    ok = np.isfinite(RA).any(1)
    # ---- hit-mode payoffs (target exit, no stop; time exit otherwise), net of cost, in ATR units.
    # A short that hits its target pays the spread AT THE MOMENT of the hit (not at the end of the horizon): this removes the rollover artefact.
    PAY = []
    for side, tg, k, h in m.HIT_SERIES:
        sub = ft[ft["horizon_min"] == h].drop_duplicates("event_key").set_index("event_key").reindex(ev.index)
        hm = pd.to_numeric(sub[f"hit_{'up' if side > 0 else 'dn'}_{tg}_min"], errors="coerce").to_numpy(float)
        hit = np.isfinite(hm)
        ra = sub["future_return_atr"].to_numpy(float)
        j = m.HZ.index(h)
        if side > 0:
            cost = CL[:, j]
        else:
            td = pd.to_timedelta(np.where(hit, hm, 0) + tfm - 1, unit="m")
            keyt = (ev["t"] + td).dt.floor("5min")
            sb = s5.reindex(keyt).to_numpy(float) if s5 is not None else np.full(n, np.nan)
            c_tau = np.fmax(sb, pf(ev["u"] + td))
            cost = np.where(hit, c_tau, CS[:, j])
        pay = np.where(hit, k, side * ra) - cost / atr_pts.to_numpy(float)
        pay[~np.isfinite(ra)] = np.nan
        PAY.append(pay)
    PAY = np.stack(PAY, 1)
    ev = ev[ok]
    keep = np.nonzero(ok)[0]
    return ev, RA[keep], RP[keep], CL[keep], CS[keep], PAY[keep]


# ------------------------------------------------------------------------------------------------------------------------- descriptive
def descriptive(live, name, point, lines, outdir):
    P = lines.append
    P("## 2. Dados, cobertura e qualidade\n")
    rows = []
    cache = {}
    for tf in ["M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"]:
        d = load_candles(live, tf)
        if len(d) == 0:
            continue
        cache[tf] = d
        sec = {"M1": 60, "M5": 300, "M15": 900, "M30": 1800, "H1": 3600, "H4": 14400, "D1": 86400, "W1": 604800}.get(tf)
        gaps = 0; big = 0
        if sec:
            df = d["t"].diff().dt.total_seconds().dropna()
            miss = (df / sec - 1).round()
            gaps = int((miss > 0).sum()); big = int(miss.max()) if len(miss) else 0
        oc = d["ohlc_vs_ticks"].value_counts()
        chk = int(oc.get("OK", 0) + oc.get("DIFF", 0))
        rows.append(dict(TF=tf, candles=len(d), inicio=str(d["t"].iloc[0])[:16], fim=str(d["t"].iloc[-1])[:16], gaps=gaps, maior_gap_barras=big,
                         dup=int(d["event_key"].duplicated().sum()), com_ticks=int((d["tick_data_ok"].astype(str).str.upper() == "TRUE").sum()),
                         ohlc_conferidos=chk, ohlc_diff=int(oc.get("DIFF", 0))))
    cov = pd.DataFrame(rows)
    cov.to_csv(os.path.join(outdir, "cobertura.csv"), index=False)
    P(md_table(cov))
    P("Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).\n")
    base = cache.get("M5") if "M5" in cache else cache.get("M15")
    btf = "M5" if "M5" in cache else "M15"
    P(f"## 3. Custo e microestrutura (base {btf})\n")
    if base is not None:
        b = base.copy()
        b["h"] = b["u"].dt.hour
        b["spread"] = b["bar_spread_points"].astype(float)
        b["rng_pts"] = (b["high"] - b["low"]) / point
        b["atr_pts"] = b["atr"] / point
        g = b.groupby("h").agg(spread_med=("spread", "median"), spread_p90=("spread", lambda x: x.quantile(.9)), spread_max=("spread", "max"),
                               range_med_pts=("rng_pts", "median"), atr_med_pts=("atr_pts", "median"), ticks_vol_med=("tick_volume", "median"), n=("spread", "size")).reset_index()
        tk = b[b["tick_data_ok"].astype(str).str.upper() == "TRUE"]
        g["spread_ticks_med"] = g["h"].map(tk.groupby("h")["spread_avg_points"].median()) if len(tk) else np.nan
        g["pct_barras_spread0"] = g["h"].map(b.groupby("h")["spread"].apply(lambda x: (x == 0).mean() * 100))
        g["custo_sobre_ATR"] = g["spread_ticks_med"].fillna(g["spread_med"]) / g["atr_med_pts"]
        g = g.rename(columns={"h": "hora_utc"})
        g.to_csv(os.path.join(outdir, "perfil_hora_utc.csv"), index=False)
        P("Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.\n")
        P(md_table(g))
        P(f"Spread geral (mediana {btf}): **{b['spread'].median():.1f} pts**, p90 {b['spread'].quantile(.9):.1f}, máx {b['spread'].max():.0f}. ATR mediano {btf}: **{b['atr_pts'].median():.1f} pts**. Razão spread/ATR: **{b['spread'].median()/b['atr_pts'].median():.2f}**.\n")
    # day-of-week & D1
    d1 = cache.get("D1")
    if d1 is not None and len(d1) > 100:
        x = d1.copy(); x["dow"] = x["t"].dt.dayofweek
        x["rng"] = (x["high"] - x["low"]) / point; x["ret"] = (x["close"] - x["open"]) / point
        P("## 4. Comportamento diário (D1)\n")
        g = x.groupby("dow").agg(dias=("rng", "size"), range_medio_pts=("rng", "mean"), ret_medio_pts=("ret", "mean"), ret_desvio=("ret", "std"), pct_alta=("ret", lambda s: (s > 0).mean() * 100)).reset_index()
        g["dow"] = g["dow"].map({0: "seg", 1: "ter", 2: "qua", 3: "qui", 4: "sex", 5: "sab", 6: "dom"})
        g["t_ret"] = g["ret_medio_pts"] / (g["ret_desvio"] / np.sqrt(g["dias"]))
        P(md_table(g))
        r = x["ret"] / x["ret"].std()
        ac = [r.autocorr(l) for l in range(1, 6)]
        P(f"Autocorrelação do retorno diário (lags 1-5): {', '.join(f'{v:+.3f}' for v in ac)} (banda ±{2/np.sqrt(len(r)):.3f}). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): "
          f"{x['ret'].abs().autocorr(1):+.3f}, {x['ret'].abs().autocorr(5):+.3f}, {x['ret'].abs().autocorr(10):+.3f}.\n")
    return cache


def hour_profiles(cache, point, lines, outdir):
    """mean next-hour return (ATR) by hour/dow/month on H1 candles; non-overlapping so plain t-stats are valid."""
    P = lines.append
    h1 = cache.get("H1")
    if h1 is None or len(h1) < 2000:
        return
    x = h1.copy().reset_index(drop=True)
    x["ret"] = (x["close"] - x["open"]) / x["atr"].replace(0, np.nan)
    x["h"] = x["u"].dt.hour; x["dow"] = x["u"].dt.dayofweek; x["month"] = x["u"].dt.month
    P("## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)\n")
    for col, nm in [("h", "hora UTC"), ("dow", "dia da semana (0=seg, UTC)"), ("month", "mês")]:
        g = x.groupby(col)["ret"].agg(["size", "mean", "std"]).reset_index()
        g["t"] = g["mean"] / (g["std"] / np.sqrt(g["size"]))
        g["p"] = g["t"].map(norm_cdf_p)
        order = g["p"].sort_values().index; mm = len(g)
        g["bh"] = False
        thr = [(k + 1) / mm * 0.05 for k in range(mm)]
        okk = [k for k, i in enumerate(order) if g.loc[i, "p"] <= thr[k]]
        if okk:
            for i in order[: max(okk) + 1]:
                g.loc[i, "bh"] = True
        g = g.rename(columns={"size": "n", "mean": "ret_medio_ATR", "std": "desvio"})
        g.to_csv(os.path.join(outdir, f"relogio_h1_{col}.csv"), index=False)
        P(f"**Por {nm}:**\n")
        P(md_table(g[["n", col, "ret_medio_ATR", "t", "bh"]].rename(columns={col: nm}), 3))
    # hour x dow t-stat grid, flag |t|>3
    g = x.groupby(["dow", "h"])["ret"].agg(["size", "mean", "std"]).reset_index()
    g["t"] = g["mean"] / (g["std"] / np.sqrt(g["size"]))
    big = g[(g["t"].abs() > 3) & (g["size"] >= 50)].sort_values("t", key=lambda s: -s.abs())
    P("**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são %d combinações testadas):\n" % len(g))
    P(md_table(big.rename(columns={"dow": "dia(0=seg)", "h": "hora_utc", "size": "n", "mean": "ret_medio_ATR"}).head(30), 3))
    # autocorr of bar returns H1
    r = x["ret"].dropna()
    ac = [r.autocorr(l) for l in range(1, 11)]
    P("Autocorrelação do retorno H1, lags 1-10: " + ", ".join(f"{v:+.3f}" for v in ac) + f" (banda ±{2/np.sqrt(len(r)):.3f}). |retorno|: " +
      ", ".join(f"{r.abs().autocorr(l):+.3f}" for l in (1, 2, 5, 10, 24)) + " (lags 1,2,5,10,24).\n")
    # follow-through after large bars
    x["next"] = x["ret"].shift(-1)
    rows = []
    for nm, cond in [("barra > +2 ATR", x["ret"] > 2), ("barra < -2 ATR", x["ret"] < -2), ("barra > +1 ATR", x["ret"] > 1), ("barra < -1 ATR", x["ret"] < -1),
                     ("gap (barra ausente antes)", x["gap_bars"].fillna(0) > 0)]:
        s = x.loc[cond, "next"].dropna()
        if len(s) >= 30:
            rows.append(dict(condicao=nm, n=len(s), ret_prox_vela_ATR=s.mean(), t=s.mean() / (s.std() / np.sqrt(len(s))), pct_alta=(s > 0).mean() * 100))
    P("**Continuação/reversão depois de barras grandes (H1):**\n")
    P(md_table(pd.DataFrame(rows), 3))
    # volatility clustering / news
    x["abs"] = x["ret"].abs()
    P(f"Distribuição do retorno H1 em ATR: média {r.mean():+.4f}, desvio {r.std():.3f}, assimetria {r.skew():+.2f}, curtose {r.kurt():.1f}; barras |ret|>2 ATR: {(r.abs()>2).mean()*100:.2f}%.\n")


# --------------------------------------------------------------------------------------------------------------------------------- mining
def cell_label(i, j, ia, ib, names, labels):
    la = f"{names[i]}={labels[names[i]][ia]}"
    return la if names[j] == "ALL" else la + f" & {names[j]}={labels[names[j]][ib]}"


def families(res, feats, names, labels, mode, SER, RA, RP, CL, CS, PAY, ev, di, vi, tf, t_bh=float("inf"), HLAB=None, cap=6000):
    gross = mode in ("ret", "open")
    """collapse identical event sets; economics with the realistic cost model; temporal stability."""
    td, tv = res["td"], res["tv"]
    sgn = np.sign(res["md"]) if gross else np.ones(len(td))
    cand = np.nonzero((sgn * td > 2.0) & (sgn * tv > 1.645))[0]
    cand = cand[np.argsort(-np.abs(td[cand]))][:cap]
    fam = {}
    for g in cand:
        i, j = divmod(int(res["pair"][g]), 1000)
        cb_n = int(feats[names[j]].max()) + 1
        ia, ib = divmod(int(res["cell"][g]), cb_n)
        hh = int(res["h"][g])
        mask = (feats[names[i]] == ia) & (feats[names[j]] == ib)
        key = (hh, hash(np.packbits(mask).tobytes()))
        nconds = 1 if names[j] == "ALL" else 2
        cur = fam.get(key)
        if cur is None or nconds < cur["nconds"] or (nconds == cur["nconds"] and abs(td[g]) > abs(cur["td"])):
            alts = (cur["alts"] + 1) if cur else 1
            fam[key] = dict(g=int(g), i=i, j=j, ia=ia, ib=ib, hh=hh, nconds=nconds, td=float(td[g]), alts=alts, mask=mask)
        else:
            cur["alts"] += 1
    rows = []
    for f in fam.values():
        g, hh, mask = f["g"], f["hh"], f["mask"]
        side = (1 if res["md"][g] > 0 else -1) if gross else SER[hh][0]
        jh = hh if gross else m.HZ.index(SER[hh][3])
        if gross:
            gross_pts = side * RP[:, hh]
            cost = CL[:, hh] if side > 0 else CS[:, hh]
            net_pts = gross_pts - cost
            netA = gross_pts - CL[:, hh]
            unit = net_pts
        else:
            unit = PAY[:, hh] * ev["atr_pts"].to_numpy(float)
            netA = unit; gross_pts = np.full_like(unit, np.nan); net_pts = unit
        sel = mask & np.isfinite(net_pts)
        v = np.zeros(len(mask), bool); v[vi] = True
        d_ = np.zeros(len(mask), bool); d_[di] = True
        sv = sel & v; sd = sel & d_
        if sv.sum() < 30:
            continue
        x = net_pts[sv]
        tnet = x.mean() / (x.std() / math.sqrt(len(x))) if x.std() > 0 else 0.0
        allv = v & np.isfinite(net_pts)
        xr = net_pts[allv & ~mask]
        base_val = float(np.nanmean(net_pts[allv])) if allv.sum() else np.nan
        if len(xr) > 30 and len(x) > 30 and (x.var(ddof=1) > 0 or xr.var(ddof=1) > 0):
            tdel = (x.mean() - xr.mean()) / math.sqrt(x.var(ddof=1) / len(x) + xr.var(ddof=1) / len(xr))
        else:
            tdel = 0.0
        yr = ev["t"].dt.year.to_numpy()
        yrs = [float(np.nanmean(net_pts[sel & (yr == y)])) for y in np.unique(yr[sel]) if (sel & (yr == y)).sum() >= 15]
        mon = ev["t"].dt.to_period("M").astype(str).to_numpy()
        ms = [float(np.nanmean(net_pts[sel & (mon == q)])) for q in np.unique(mon[sel]) if (sel & (mon == q)).sum() >= 5]
        half = np.nonzero(sv)[0]; h1_, h2_ = half[: len(half) // 2], half[len(half) // 2:]
        rows.append(dict(tf=tf, modo=mode, condicao=cell_label(f["i"], f["j"], f["ia"], f["ib"], names, labels), serie=(f"{HLAB[hh]}min" if gross else
                         f"{'C' if SER[hh][0] > 0 else 'V'} alvo {dict(m.HIT_TGT_K)[SER[hh][1]]}ATR ate {SER[hh][3]}min"),
                         lado=("COMPRA" if side > 0 else "VENDA"), n_desc=int(sd.sum()), n_val=int(sv.sum()), t_desc=f["td"], passou_BH=bool(abs(f["td"]) >= t_bh), t_val=float(res["tv"][g]), n_formas_equivalentes=f["alts"],
                         bruto_pts_val=float(np.nanmean(gross_pts[sv])) if gross else np.nan, liq_A_pts_val=float(np.nanmean(netA[sv])),
                         liq_B_pts_val=float(x.mean()), t_liq_B=float(tnet), base_B_pts_val=base_val, delta_B_pts=float(x.mean() - xr.mean()) if len(xr) else np.nan, t_delta=float(tdel), pct_pos_B=float((x > 0).mean() * 100), anos_pos=f"{sum(a > 0 for a in yrs)}/{len(yrs)}",
                         meses_pos=f"{sum(a > 0 for a in ms)}/{len(ms)}", metade1_B=float(net_pts[h1_].mean()) if len(h1_) else np.nan, metade2_B=float(net_pts[h2_].mean()) if len(h2_) else np.nan,
                         custo_medio_pts=float(np.nanmean((CL[:, jh] if side > 0 else CS[:, jh])[sv]))))
    return pd.DataFrame(rows)


def mine_tf(live, name, tf, point, s5, prof, mode, placebos, rng, lines, outdir, min_n):
    P = lines.append
    built = build_mining_frame(live, tf, point, s5, prof)
    if built is None:
        P(f"### {tf} / {mode}: sem dados de FORWARD_TIME/eventos\n"); return None
    ev, RA, RP, CL, CS, PAY = built
    n = len(ev)
    if n < 2000:
        P(f"### {tf} / {mode}: poucos eventos ({n})\n"); return None
    t_split = ev["t"].iloc[int(n * 0.6)]
    di = np.nonzero((ev["t"] < t_split - pd.Timedelta(days=1)).to_numpy())[0]
    vi = np.nonzero((ev["t"] >= t_split).to_numpy())[0]
    m.CAT = list(dict.fromkeys(m.CAT + EXTRA_CAT)); m.NUM = list(dict.fromkeys(m.NUM + [c for c in EXTRA_NUM if c in ev.columns]))
    feats, labels = m.build_features(ev, len(di))
    names = list(feats.keys())
    gross = mode in ("ret", "open")
    HLAB = list(m.HZ)
    if mode == "open":
        # entry at the OPEN of the event candle: the series are (own candle) and (own candle + forward h). Only variables known before the open are allowed.
        tfm = TFMIN[tf]
        own_a = ev["ret_bar_atr"].to_numpy(float); own_p = ((ev["close"] - ev["open"]) / point).to_numpy(float)
        RA = np.column_stack([own_a, own_a[:, None] + RA]); RP = np.column_stack([own_p, own_p[:, None] + RP])
        ent_o = np.fmax(ev["bar_spread_points"].astype(float).shift(1).to_numpy(float), prof.reindex(slot30(ev["u"])).to_numpy(float))
        CL = np.repeat(ent_o[:, None], RA.shape[1], 1)
        CS = np.column_stack([CL[:, 0] * 0 + np.fmax(ev["bar_spread_points"].astype(float).to_numpy(float), prof.reindex(slot30(ev["u"] + pd.to_timedelta(tfm, unit="m"))).to_numpy(float)), CS])
        HLAB = [tfm] + [tfm + h for h in m.HZ]
        keep_f = [k for k in names if k in PRE_ALLOWED]
        feats = {k: feats[k] for k in keep_f}; names = list(feats.keys())
    if gross:
        Ymat = RA; SER = [("ret", h) for h in HLAB]; f = np.array([min(1.0, TFMIN[tf] / h) for h in HLAB])
    else:
        Ymat = PAY; SER = m.HIT_SERIES; f = np.array([min(1.0, TFMIN[tf] / h) for s, tg, k, h in m.HIT_SERIES])
    V = np.isfinite(Ymat).astype(float); Y = np.nan_to_num(Ymat)
    P(f"### {tf} — modo `{mode}`\n")
    P(f"- eventos: {n:,} ({str(ev['t'].iloc[0])[:10]} a {str(ev['t'].iloc[-1])[:10]}); descoberta {len(di):,} (até {str(t_split - pd.Timedelta(days=1))[:10]}), validação {len(vi):,} (a partir de {str(t_split)[:10]})")
    P(f"- variáveis: {len(names) - 1}; séries por variável/par: {Ymat.shape[1]}")
    res = m.run_pipeline(feats, Y[di], V[di], Y[vi], V[vi], di, vi, f, names, min_n, max(40, min_n // 3))
    if mode == "hit":
        res["td"] = np.where(res["td"] > 0, res["td"], 0.0)
    top, nbh, mtot, val, order = m.summarize(res)
    P(f"- **hipóteses testadas: {mtot:,}**; passaram no BH (q=5%) na descoberta: **{nbh:,}**; confirmadas na validação: **{val:,}**")
    P("- melhores N da descoberta que repetem na validação: " + ", ".join(f"top {k}: {100 * v:.1f}%" for k, v in top.items()))
    pl = {k: [] for k in top}; pl_bh = []; pl_val = []
    for _ in range(placebos):
        lag = int(rng.integers(3000, max(3001, n - 3000)))
        Yp = np.roll(Y, lag, 0); Vp = np.roll(V, lag, 0)
        rp = m.run_pipeline(feats, Yp[di], Vp[di], Yp[vi], Vp[vi], di, vi, f, names, min_n, max(40, min_n // 3))
        if mode == "hit":
            rp["td"] = np.where(rp["td"] > 0, rp["td"], 0.0)
        tp, nb, _, vv, _ = m.summarize(rp)
        for kk in top: pl[kk].append(tp[kk])
        pl_bh.append(nb); pl_val.append(vv)
    P(f"- **placebo** ({placebos} deslocamentos): " + ", ".join(f"top {k}: {100 * np.mean(v):.1f}% (máx {100 * np.max(v):.1f}%)" for k, v in pl.items()) +
      f"; BH: média {np.mean(pl_bh):.1f} (máx {np.max(pl_bh)}); confirmadas: média {np.mean(pl_val):.1f} (máx {np.max(pl_val)})\n")
    # univariate scan (all variables, all values) -> csv
    uni = np.nonzero(np.array([names[int(p) // 1000] == "ALL" or names[int(p) % 1000] == "ALL" for p in res["pair"]]))[0]
    rows = []
    for g in uni:
        i, j = divmod(int(res["pair"][g]), 1000)
        if names[j] != "ALL":
            continue
        cb_n = 1; ia = int(res["cell"][g]); hh = int(res["h"][g])
        rows.append(dict(tf=tf, modo=mode, variavel=names[i], valor=labels[names[i]][ia], serie=(HLAB[hh] if gross else str(SER[hh])), n_desc=int(res["nd"][g]),
                         t_desc=res["td"][g], n_val=int(res["nv"][g]), t_val=res["tv"][g]))
    pd.DataFrame(rows).to_csv(os.path.join(outdir, f"univariada_{tf}_{mode}.csv"), index=False)
    t_bh = float(np.sort(np.abs(res["td"]))[::-1][nbh - 1]) if nbh > 0 else float("inf")
    ia_ = names.index("ALL")
    unc = []
    medatr = float(np.nanmedian(ev["atr_pts"]))
    for g in np.nonzero((res["pair"] == ia_ * 1000 + ia_))[0]:
        hh = int(res["h"][g])
        unc.append(dict(serie=(f"{HLAB[hh]}min bruto" if gross else f"{'C' if SER[hh][0] > 0 else 'V'} alvo {dict(m.HIT_TGT_K)[SER[hh][1]]}ATR/{SER[hh][3]}min liquido"),
                        n=int(res["nd"][g]), medio_ATR_desc=float(res["md"][g]), t_desc=float(res["td"][g]) if gross else float("nan"),
                        medio_pts_aprox=float(res["md"][g]) * medatr))
    if unc:
        P("Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:\n")
        P(md_table(pd.DataFrame(unc), 3))
    fam = families(res, feats, names, labels, mode, SER, RA, RP, CL, CS, PAY, ev, di, vi, tf, t_bh, HLAB)
    fam.to_csv(os.path.join(outdir, f"familias_{tf}_{mode}.csv"), index=False)
    return dict(tf=tf, mode=mode, n=n, tests=mtot, bh=nbh, val=val, top=top, pl=pl, pl_bh=pl_bh, pl_val=pl_val, fam=fam)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--live", required=True); ap.add_argument("--name", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--placebos", type=int, default=6); ap.add_argument("--min-n", type=int, default=120)
    ap.add_argument("--tfs", default="M5,M15,M30,H1")
    ap.add_argument("--modes", default="ret,hit"); ap.add_argument("--tag", default="")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    t0 = time.time()
    L = []; P = L.append
    spec = read_spec(a.live)
    point = float(spec.get("point", 0.00001))
    P(f"# {a.name} — relatório completo MBA (gerado em {pd.Timestamp.now():%Y-%m-%d %H:%M})\n")
    P("## 1. Identificação\n")
    P(md_table(pd.DataFrame([dict(corretora=spec.get("broker"), servidor=spec.get("server"), simbolo=spec.get("symbol"), descricao=spec.get("description"),
                                 digitos=spec.get("digits"), ponto=point, tick_size=spec.get("tick_size"), tick_value=spec.get("tick_value"), contrato=spec.get("contract_size"),
                                 lote_min=spec.get("volume_min"), swap_long=spec.get("swap_long"), swap_short=spec.get("swap_short"), moeda=spec.get("account_currency"),
                                 comissao_declarada=spec.get("commission_per_lot_declared"))]).T.reset_index().rename(columns={"index": "campo", 0: "valor"}), 5))
    cache = descriptive(a.live, a.name, point, L, a.out)
    hour_profiles(cache, point, L, a.out)
    # spread tables for the cost model
    base = cache.get("M5") if "M5" in cache else cache.get("M15")
    s5 = None
    prof = pd.Series(np.nan, index=range(96))
    if base is not None:
        if "M5" in cache:
            s5 = base.set_index("t")["bar_spread_points"].astype(float)
            s5 = s5[~s5.index.duplicated()]
        tb = base[base["tick_data_ok"].astype(str).str.upper() == "TRUE"]
        if len(tb) >= 500:
            src = pd.Series(tb["spread_avg_points"].to_numpy(float)); sl = slot30(tb["u"]); how = "spread medido nos ticks (últimos ~120 dias)"
        else:
            src = pd.Series(base["bar_spread_points"].to_numpy(float)); sl = slot30(base["u"]); how = "spread gravado na barra (sem ticks suficientes)"
        gb = src.groupby(sl)
        med, cnt = gb.median().reindex(range(96)), gb.size().reindex(range(96)).fillna(0)
        wk = med.iloc[:48].interpolate(limit_direction="both")
        sun = med.iloc[48:].where(cnt.iloc[48:] >= 5)
        prof = pd.concat([wk, sun.fillna(wk.set_axis(range(48, 96)) if False else pd.Series(wk.values, index=range(48, 96)))])
        pd.DataFrame({"slot30_NY": range(96), "dia": ["seg-sex"] * 48 + ["domingo"] * 48, "hora_NY": [f"{(k % 48) // 2:02d}:{(k % 2) * 30:02d}" for k in range(96)], "spread_mediano_pts": prof.values, "n_obs": cnt.values}).to_csv(os.path.join(a.out, "perfil_spread_NY.csv"), index=False)
        P(f"**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do {how}; custo usado = max(spread da barra, esse perfil). "
          f"Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral {prof.median():.1f} pts, máxima {prof.max():.1f} pts no slot NY {(int(prof.idxmax()) % 48) // 2:02d}:{(int(prof.idxmax()) % 2) * 30:02d}{" de domingo" if int(prof.idxmax()) >= 48 else ""}; domingos têm perfil próprio).\n")
    P("## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)\n")
    P("Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) "
      "testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), "
      "líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. "
      "Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).\n")
    rng = np.random.default_rng(11)
    summ = []
    allfam = []
    for mode in a.modes.split(","):
        P(f"## 6.{ {'ret': 1, 'hit': 2, 'open': 3}[mode] } Modo `{mode}`\n")
        for tf in a.tfs.split(","):
            r = mine_tf(a.live, a.name, tf, point, s5, prof, mode, a.placebos, rng, L, a.out, a.min_n)
            if r is None: continue
            summ.append(dict(tf=tf, modo=mode, eventos=r["n"], hipoteses=r["tests"], passou_BH=r["bh"], confirmadas=r["val"],
                             placebo_BH_media=float(np.mean(r["pl_bh"])), placebo_conf_media=float(np.mean(r["pl_val"])), placebo_conf_max=int(np.max(r["pl_val"])),
                             top100_repete_pct=100 * r["top"][100], placebo_top100_pct=100 * float(np.mean(r["pl"][100]))))
            f = r["fam"]
            if len(f):
                allfam.append(f)
                viable = f[(f["liq_B_pts_val"] > 0) & (f["t_liq_B"] > 1.645) & (f["t_delta"] > 1.645)].sort_values("t_liq_B", ascending=False)
                P(f"**{tf}/{mode}: famílias distintas validadas: {len(f)}; com líquido positivo e significativo na validação (custo realista): {len(viable)}.**\n")
                show = viable.head(25) if len(viable) else f.sort_values("t_val", ascending=False).head(15)
                P(("Famílias viáveis (ordenadas por t líquido):\n" if len(viable) else "Nenhuma viável; melhores famílias validadas (líquido NEGATIVO ou insignificante):\n"))
                P(md_table(show[["condicao", "serie", "lado", "n_desc", "n_val", "t_desc", "passou_BH", "t_val", "n_formas_equivalentes", "bruto_pts_val", "liq_A_pts_val", "liq_B_pts_val", "t_liq_B", "base_B_pts_val", "t_delta",
                                 "pct_pos_B", "anos_pos", "meses_pos", "metade1_B", "metade2_B", "custo_medio_pts"]], 2))
            else:
                P(f"**{tf}/{mode}: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**\n")
    s = pd.DataFrame(summ)
    s.to_csv(os.path.join(a.out, f"resumo_mineracao{a.tag}.csv"), index=False)
    # insert summary after the heading of section 6
    idx = next(i for i, l in enumerate(L) if l.startswith("## 6. Mineração"))
    L.insert(idx + 2, "**Resumo da mineração**\n\n" + md_table(s, 1) + "\n")
    if allfam:
        pd.concat(allfam).to_csv(os.path.join(a.out, f"familias_todas{a.tag}.csv"), index=False)
    P("## 7. Veredito automático do ativo\n")
    if allfam:
        F = pd.concat(allfam)
        via = F[(F["liq_B_pts_val"] > 0) & (F["t_liq_B"] > 1.645) & (F["t_delta"] > 1.645)]
        viaBH = via[via["passou_BH"]]
        stable = viaBH[(viaBH["metade1_B"] > 0) & (viaBH["metade2_B"] > 0)]
        P(f"- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **{len(F)}**")
        P(f"- com líquido positivo e t>1,645 na validação, custo realista: **{len(via)}**; dessas, sobreviveram ao BH: **{len(viaBH)}**; e positivas nas duas metades da validação: **{len(stable)}**")
        if len(stable):
            P("- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):\n")
            P(md_table(stable.sort_values("t_liq_B", ascending=False).head(20)[["tf", "modo", "condicao", "serie", "lado", "n_val", "liq_B_pts_val", "base_B_pts_val", "t_delta", "t_liq_B", "pct_pos_B", "anos_pos", "meses_pos"]], 2))
        else:
            P("- **Nenhuma família passa em todos os filtros (BH + validação + líquido positivo com custo realista + estabilidade nas duas metades).**")
    else:
        P("- nenhuma família validada.")
    P("\n## 8. Anexos (CSV na mesma pasta)\n")
    P("`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).\n")
    P(f"\n_(tempo de geração {time.time() - t0:.0f}s)_\n")
    open(os.path.join(a.out, f"{a.name}{a.tag}.md"), "w", encoding="utf-8").write("\n".join(L))
    print("OK", a.name, f"{time.time() - t0:.0f}s")


if __name__ == "__main__":
    sys.exit(main())


def build_event_frame(live, tf, point, grid=1):
    """Pre-open features of the events of `tf` without the (huge) FORWARD_TIME. Derived columns are computed on the FULL candle series and only then
    the events are filtered to a time grid (minute % grid == 0), so that p1/p2/streak/atr_ratio keep their meaning."""
    import glob as _g
    cd = load_candles(live, tf)
    if len(cd) == 0:
        return None
    cd = cd.reset_index(drop=True)
    cd["ret_bar_atr"] = (cd["close"] - cd["open"]) / cd["atr"]
    cd["p1"] = cd["ret_bar_atr"].shift(1); cd["p2"] = cd["ret_bar_atr"].shift(2)
    cd["cum3"] = cd["ret_bar_atr"].rolling(3).sum(); cd["cum10"] = cd["ret_bar_atr"].rolling(10).sum()
    cd["pcum3"] = cd["ret_bar_atr"].shift(1).rolling(3).sum(); cd["pcum10"] = cd["ret_bar_atr"].shift(1).rolling(10).sum()
    cd["range_atr_prev"] = cd["range_atr"].shift(1)
    cd["atr_ratio"] = cd["atr"] / cd["atr"].rolling(500, min_periods=100).median()
    cd["atr_ratio_prev"] = cd["atr_ratio"].shift(1)
    dirn = np.sign(cd["close"] - cd["open"]).to_numpy()
    st = np.zeros(len(cd), int); run = 0
    for i, d in enumerate(dirn):
        run = (run + 1 if i > 0 and d == dirn[i - 1] and d != 0 else 1)
        st[i] = min(run, 6) * (1 if d >= 0 else -1)
    cd["streak"] = pd.Series(st).astype(str); cd["streak_prev"] = cd["streak"].shift(1)
    cd["atr_pts"] = cd["atr"] / point
    keep = ["event_key", "t", "u", "atr_pts", "ret_bar_atr", "p1", "p2", "cum3", "cum10", "pcum3", "pcum10", "range_atr_prev", "atr_ratio", "atr_ratio_prev", "streak", "streak_prev", "bar_spread_points"]
    cdk = cd[keep].set_index("event_key")
    cols = list(m.EV_COLS) + ["minute"]
    parts = []
    for fn in sorted(_g.glob(os.path.join(live, "EVENTS", f"events_{tf}_part*.csv"))):
        for ch in pd.read_csv(fn, usecols=lambda c: c in cols, chunksize=250000, low_memory=False):
            if "schema_version" in ch.columns:
                ch = ch[ch["schema_version"].astype(str) == "3"]
            if grid > 1:
                ch = ch[(pd.to_numeric(ch["minute"], errors="coerce") % grid) == 0]
            parts.append(ch)
    if not parts:
        return None
    ev = pd.concat(parts, ignore_index=True).drop_duplicates("event_key").set_index("event_key")
    ev = ev.join(cdk, how="inner")
    ev["cost_atr"] = ev["bar_spread_points"].astype(float) / ev["atr_pts"]
    ev["month"] = ev["t"].dt.month.astype(str)
    ev["dom_w"] = pd.cut(ev["t"].dt.day, [0, 7, 14, 21, 31], labels=["d01_07", "d08_14", "d15_21", "d22_31"]).astype(str)
    ev["dow_slot"] = ev["day_of_week"].astype(str) + "|" + ev["slot_hhmm"].astype(str)
    return ev.sort_values("t")
