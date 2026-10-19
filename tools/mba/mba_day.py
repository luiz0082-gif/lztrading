#!/usr/bin/env python3
"""Intraday patterns: enter at a server-time slot, exit at the profit TARGET (100/200/300/500 pts) or, at the latest, at 23:30 server time. No stop.

With a small target and no stop, almost every entry "wins" 95-99% of the days and loses a lot on the few days the target is missed. A t-test on the
mean is meaningless there (variance ~0, tail unobserved). So this script tests the HIT RATE against the pooled hit rate of the same series and
computes a STRESSED expectancy:
    EV_stress = p_low * G + (1 - p_low) * L_miss
with p_low = 95% Wilson lower bound of the cell's hit rate, G = mean net result on hit days, L_miss = mean net result on the days the target was
missed, POOLED over all slots (a much larger sample of tail days than any single cell has). A pattern needs EV_stress > 0 in discovery AND validation.

Path: M15 candles. Cost: long pays the entry spread, short pays the exit spread (tick-based profile by New-York half-hour, Sunday apart).
  python tools/mba/mba_day.py --live "<.../LIVE>" --name XAUUSD --out docs/relatorios/mba/padroes_dia
"""
import argparse, math, os, sys, time
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mba_mine as m
import mba_report as r
import mba_slots as sl

sys.stdout.reconfigure(encoding="utf-8")
XL = [100, 200, 300, 500]
END_MIN = 23 * 60 + 30
STEP = 15                      # minutes per entry candle; set in main() from --tf
SERIES = [(side, X) for X in XL for side in (1, -1)]        # replaced in main() by per-symbol targets (in place)


def wilson_low(k, n, z=1.96):
    if n <= 0:
        return 0.0
    p = k / n
    den = 1 + z * z / n
    c = p + z * z / (2 * n)
    d = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return max(0.0, (c - d) / den)


def day_outcomes(cd, point, s5, prof, step=15):
    n = len(cd)
    tod = (cd["t"].dt.hour * 60 + cd["t"].dt.minute).to_numpy()
    day = cd["t"].dt.normalize().to_numpy()
    O, H, L, C = (cd[c].to_numpy(float) for c in ("open", "high", "low", "close"))
    sp_prev = cd["bar_spread_points"].astype(float).shift(1).to_numpy(float)
    pf = lambda uu: prof.reindex(r.slot30(uu)).to_numpy(float)
    ent = np.fmax(sp_prev, pf(cd["u"]))
    NET = np.full((n, len(SERIES)), np.nan); HIT = np.zeros((n, len(SERIES)), bool); MAE = np.full_like(NET, np.nan); EXM = np.full_like(NET, np.nan)
    EXI = np.full((n, len(SERIES)), -1, int)
    ok_day = tod < END_MIN
    s = pd.Series(np.arange(n)[ok_day]).groupby(day[ok_day]).apply(lambda x: x.to_numpy())
    for idx in s.values:
        mm = len(idx)
        if mm < 8:
            continue
        o, h, l, c = O[idx], H[idx], L[idx], C[idx]
        last = mm - 1
        up = (h[None, :] - o[:, None]) / point
        dn = (o[:, None] - l[None, :]) / point
        kk = np.arange(mm)
        valid = kk[None, :] >= kk[:, None]
        for si, (side, X) in enumerate(SERIES):
            fav, adv = (up, dn) if side > 0 else (dn, up)
            hit = (fav >= X) & valid
            any_ = hit.any(1); k = hit.argmax(1)
            ex = np.where(any_, k, last)
            gross = np.where(any_, X, side * (c[last] - o) / point)
            within = valid & (kk[None, :] <= ex[:, None])
            mae = np.where(within, adv, -np.inf).max(1)
            NET[idx, si] = gross; HIT[idx, si] = any_; MAE[idx, si] = np.maximum(mae, 0)
            EXM[idx, si] = tod[idx[ex]] + step - tod[idx]
            EXI[idx, si] = idx[ex]
    for si, (side, X) in enumerate(SERIES):
        m_ok = np.isfinite(NET[:, si])
        if side > 0:
            cost = ent
        else:
            ei = EXI[:, si]; ok = ei >= 0
            tx = cd["t"].to_numpy()[np.where(ok, ei, 0)]; ux = cd["u"].to_numpy()[np.where(ok, ei, 0)]
            key = (pd.to_datetime(tx) + pd.to_timedelta(step - 1, unit="m")).floor("5min")
            sb = s5.reindex(key).to_numpy(float) if s5 is not None else np.full(n, np.nan)
            cost = np.fmax(sb, pf(pd.to_datetime(ux) + pd.to_timedelta(step, unit="m")))
        NET[:, si] = np.where(m_ok, NET[:, si] - cost, np.nan)
    return NET, HIT, MAE, EXM


def pooled(NET, HIT, valid_rows):
    """pooled hit rate and mean net result on missed-target days, per series."""
    p0 = np.zeros(len(SERIES)); lm = np.zeros(len(SERIES))
    for si, (side, X) in enumerate(SERIES):
        v = valid_rows & np.isfinite(NET[:, si])
        p0[si] = HIT[v, si].mean() if v.any() else 0.0
        miss = v & ~HIT[:, si]
        lm[si] = NET[miss, si].mean() if miss.any() else -10.0 * X
    return p0, lm


def ev_stress(k, n, G, lmiss):
    pl = wilson_low(k, n)
    return pl * G + (1 - pl) * lmiss, pl


def scan_clock(df, NET, HIT, split_day, p0d, p0v, LM, HDM, shift=0, min_n=200):
    if shift:
        NET, HIT, HDM = np.roll(NET, shift, 0), np.roll(HIT, shift, 0), np.roll(HDM, shift, 0)
    rows = []
    slots = df["slot"].to_numpy(); isd = df["day"].to_numpy() < split_day
    for sv in np.unique(slots):
        sm = slots == sv
        for si, (side, X) in enumerate(SERIES):
            net = NET[sm, si]; hit = HIT[sm, si]; ok = np.isfinite(net)
            if ok.sum() < min_n:
                continue
            d = isd[sm] & ok; v = (~isd[sm]) & ok
            if d.sum() < 100 or v.sum() < 60:
                continue
            res = []
            for mk, p0 in ((d, p0d[si]), (v, p0v[si])):
                nn = int(mk.sum()); kk = int(hit[mk].sum()); p = kk / nn
                z = float(HDM[sm, si][mk].mean()) / math.sqrt(max(p0 * (1 - p0), 1e-9) / nn)
                G = float(net[mk & hit].mean()) if (mk & hit).any() else 0.0
                ev, pl = ev_stress(kk, nn, G, LM[si])
                res.append((z, ev, p))
            (zd, evd, pd_), (zv, evv, pv_) = res
            if zd >= 2.0 and zv >= 1.645 and evd > 0 and evv > 0 and net[d].mean() > 0 and net[v].mean() > 0:
                rows.append((sv, si, np.nonzero(sm)[0][ok], zd, zv))
    return rows


def describe(df, NET, HIT, MAE, EXM, idx, si, LM):
    net, hit, mae, exm = NET[idx, si], HIT[idx, si], MAE[idx, si], EXM[idx, si]
    t = pd.to_datetime(df["t"].to_numpy()[idx])
    ys = pd.Series(net).groupby(t.year).agg(["mean", "size"]); ys = ys[ys["size"] >= 15]
    mo = pd.Series(net).groupby(t.to_period("M")).agg(["mean", "size"]); mo = mo[mo["size"] >= 3]
    dw = pd.Series(hit).groupby(t.dayofweek).agg(["mean", "size"])
    k, nn = int(hit.sum()), len(hit)
    G = float(net[hit].mean()) if hit.any() else 0.0
    ev, pl = ev_stress(k, nn, G, LM[si])
    be = abs(LM[si]) / (G + abs(LM[si])) if (G + abs(LM[si])) > 0 else np.nan
    return dict(n=nn, pct_alvo=100 * k / nn, pct_alvo_min95=100 * pl, ganho_dia_alvo=G, perda_media_sem_alvo=float(LM[si]), pct_necessario_p_empatar=100 * be, ev_estresse_pts=ev,
                media_real_pts=float(net.mean()), mediana_pts=float(np.median(net)), pct_dias_lucro=100 * float((net > 0).mean()), pior_dia_pts=float(net.min()),
                mae_medio_pts=float(np.nanmean(mae)), mae_p90_pts=float(np.nanpercentile(mae, 90)), min_ate_alvo=float(np.nanmedian(exm[hit])) if hit.any() else np.nan,
                anos_pos=f"{int((ys['mean'] > 0).sum())}/{len(ys)}", meses_pos=f"{int((mo['mean'] > 0).sum())}/{len(mo)}",
                por_ano=("; ".join(f"{int(a)}:{v:+.0f}" for a, v in ys["mean"].items())),
                dias_semana=" ".join(f"{['seg','ter','qua','qui','sex'][int(a)]}={100*v:.0f}%({int(c)})" for a, (v, c) in dw.iterrows() if c >= 10 and a < 5),
                primeiro=str(t.min())[:10], ultimo=str(t.max())[:10])


def merge_adjacent(rows):
    def mins(s_): return int(s_[:2]) * 60 + int(s_[3:])
    out = []
    for si in sorted(set(x["si"] for x in rows)):
        L = sorted([x for x in rows if x["si"] == si], key=lambda z: mins(z["entrada"]))
        cur = None
        for x in L:
            if cur is not None and mins(x["entrada"]) - cur["_last"] <= STEP:
                cur["_m"].append(x); cur["_last"] = mins(x["entrada"])
            else:
                if cur: out.append(cur)
                cur = dict(x); cur["_m"] = [x]; cur["_last"] = mins(x["entrada"])
        if cur: out.append(cur)
    res = []
    for c in out:
        best = max(c["_m"], key=lambda z: z["z_val"] + z["z_desc"])
        b = dict(best); b["janela_entrada"] = f"{c['_m'][0]['entrada']}–{c['_m'][-1]['entrada']}" if len(c["_m"]) > 1 else c["_m"][0]["entrada"]; b["variantes"] = len(c["_m"])
        res.append(b)
    return res


def cell_label(fm, names, labels):
    la = f"{names[fm['i']]}={labels[names[fm['i']]][fm['ia']]}"
    return la if names[fm["j"]] == "ALL" else la + f" & {names[fm['j']]}={labels[names[fm['j']]][fm['ib']]}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--live", required=True); ap.add_argument("--name", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--placebos", type=int, default=12)
    ap.add_argument("--tf", default="M15", choices=["M1", "M5", "M15"]); ap.add_argument("--grid", type=int, default=1, help="entry grid (minutes) of the CONDITIONAL part")
    ap.add_argument("--tag", default="")
    a = ap.parse_args()
    global STEP
    STEP = {"M1": 1, "M5": 5, "M15": 15}[a.tf]
    os.makedirs(a.out, exist_ok=True)
    t0 = time.time()
    spec = r.read_spec(a.live); point = float(spec.get("point", 0.00001))
    s5, prof = sl.cost_model(a.live)
    cd = r.load_candles(a.live, a.tf)
    cd = cd[cd["open"].notna()].reset_index(drop=True)
    c15 = r.load_candles(a.live, "M15")
    atr15 = float(np.nanmedian(c15["atr"].to_numpy(float) / point))
    xs = sorted(set([max(5, int(round(atr15 * k / 5.0) * 5)) for k in (0.25, 0.5, 1, 2)] + [300]))
    SERIES[:] = [(side, X) for X in xs for side in (1, -1)]
    NET, HIT, MAE, EXM = day_outcomes(cd, point, s5, prof, step=STEP)
    df = pd.DataFrame({"t": cd["t"], "day": cd["t"].dt.normalize(), "slot": cd["t"].dt.strftime("%H:%M"), "dow": cd["t"].dt.dayofweek})
    days = np.sort(df["day"].unique()); split_day = days[int(len(days) * 0.6)]
    isd = (df["day"].to_numpy() < split_day)
    p0d, _ = pooled(NET, HIT, isd); p0v, _ = pooled(NET, HIT, ~isd)
    # hit indicator minus the mean hit rate of the SAME calendar month (all slots): removes trend regimes / drift from the comparison
    mon = df["t"].dt.to_period("M").astype(str).to_numpy()
    HDM = np.zeros(HIT.shape)
    for si_ in range(len(SERIES)):
        v_ = np.isfinite(NET[:, si_])
        ser = pd.Series(np.where(v_, HIT[:, si_].astype(float), np.nan))
        HDM[:, si_] = np.nan_to_num((ser - ser.groupby(mon).transform("mean")).to_numpy())
    P_ATR = f"ATR M15 mediano = {atr15:.0f} pts; alvos testados: {xs} pts"
    _, LM = pooled(NET, HIT, np.ones(len(df), bool))
    L = []; P = L.append
    P(f"# {a.name} — padrões intraday: alvo ou saída às 23:30 (hora do servidor)\n")
    P(f"Dados: {a.tf} de {str(df['t'].min())[:10]} a {str(df['t'].max())[:10]} ({len(days)} dias; descoberta até {str(pd.Timestamp(split_day))[:10]}, validação depois). Entrada na abertura da vela {a.tf} do horário (caminho do preço em {a.tf}); sai no **alvo** (+100/200/300/500 pontos) ou às **23:30** do servidor (fechamento da vela 23:15). **Sem stop.** "
      "Custo: spread medido nos ticks (compra paga na entrada, venda na saída). Comissão e slippage não incluídos.\n")
    P(P_ATR + "\n")
    P("**Como ler o risco sem stop.** `pct_alvo` = % dos dias em que o alvo foi atingido antes das 23:30. `ganho_dia_alvo` = resultado líquido médio nesses dias (≈ alvo − custo). `perda_media_sem_alvo` = resultado médio nos dias em que o alvo NÃO foi atingido, calculado no conjunto inteiro de dias daquele lado/alvo (amostra grande da cauda). "
      "`pct_necessario_p_empatar` = % de acerto necessário para a conta empatar com essa perda média. `pct_alvo_min95` = limite inferior (95%) da taxa de acerto do padrão. `ev_estresse_pts` = pct_alvo_min95 × ganho + (1−pct_alvo_min95) × perda_media_sem_alvo: expectativa em pontos por operação **supondo o pior plausível para a taxa de acerto**. "
      "`mae_medio/p90` = quanto o preço andou CONTRA você antes de sair (média e pior 10% dos dias). Um padrão só é listado se `ev_estresse_pts` > 0 **e** a média realmente obtida (`media_real_pts`) for > 0 na descoberta e na validação, e a taxa de acerto for significativamente maior que a média dos horários.\n")
    # ---------------- A. clock only
    rows = scan_clock(df, NET, HIT, split_day, p0d, p0v, LM, HDM)
    pl = [len(scan_clock(df, NET, HIT, split_day, p0d, p0v, LM, HDM, shift=int(np.random.default_rng(k).integers(2000, len(df) - 2000)))) for k in range(a.placebos)]
    P("## A. Horários puros (só o relógio)\n")
    P(f"Padrões que passaram: **{len(rows)}**; placebo: média {np.mean(pl):.1f}, máximo {int(np.max(pl))}. {'Acima do acaso.' if len(rows) > np.max(pl) else 'Não se distingue do acaso.'}\n")
    clock = []
    for sv, si, idx, zd, zv in rows:
        side, X = SERIES[si]
        d = describe(df, NET, HIT, MAE, EXM, idx, si, LM)
        d.update(entrada=sv, si=si, lado="COMPRA" if side > 0 else "VENDA", alvo_pts=X, z_desc=zd, z_val=zv)
        clock.append(d)
    cols_a = ["lado", "alvo_pts", "janela_entrada", "londres", "n", "pct_alvo", "pct_alvo_min95", "ganho_dia_alvo", "perda_media_sem_alvo", "pct_necessario_p_empatar", "ev_estresse_pts", "media_real_pts", "pior_dia_pts", "mae_medio_pts", "mae_p90_pts", "min_ate_alvo", "z_desc", "z_val", "anos_pos", "meses_pos", "variantes"]
    if clock:
        W = pd.DataFrame(merge_adjacent(clock))
        W["londres"] = W["entrada"].map(lambda s_: f"{(int(s_[:2]) - 2) % 24:02d}:{s_[3:]}")
        W = W.sort_values("z_val", ascending=False)
        P(r.md_table(W[cols_a], 1))
        P("\n" + r.md_table(W[["lado", "alvo_pts", "entrada", "primeiro", "ultimo", "por_ano", "dias_semana"]], 1))
        W.drop(columns=[c for c in W.columns if c.startswith("_")]).to_csv(os.path.join(a.out, f"{a.name}{a.tag}_horarios.csv"), index=False)
        occ = []
        for x in sorted(clock, key=lambda z: -(z["z_val"] + z["z_desc"]))[:30]:
            sm = np.nonzero((df["slot"].to_numpy() == x["entrada"]) & np.isfinite(NET[:, x["si"]]))[0]
            for i in sm:
                occ.append(dict(entrada=x["entrada"], lado=x["lado"], alvo_pts=x["alvo_pts"], data_servidor=str(df["t"].iloc[i])[:10], bateu_alvo=bool(HIT[i, x["si"]]), resultado_liquido_pts=round(float(NET[i, x["si"]]), 1),
                                contra_max_pts=round(float(MAE[i, x["si"]]), 1), saida_min=int(EXM[i, x["si"]])))
        pd.DataFrame(occ).to_csv(os.path.join(a.out, f"{a.name}{a.tag}_ocorrencias_horarios.csv"), index=False)
        P("\n**Últimas 10 ocorrências (data → líquido em pontos; * = bateu o alvo):**\n")
        for x in sorted(clock, key=lambda z: -(z["z_val"] + z["z_desc"]))[:12]:
            sm = np.nonzero((df["slot"].to_numpy() == x["entrada"]) & np.isfinite(NET[:, x["si"]]))[0][-10:]
            P(f"- {x['lado']} {x['entrada']} alvo {x['alvo_pts']}: " + "; ".join(f"{str(df['t'].iloc[i])[5:10]} {NET[i, x['si']]:+.0f}{'*' if HIT[i, x['si']] else ''}" for i in sm))
    else:
        P("**Nenhum horário puro passou.**\n")
    # ---------------- B. conditional
    P("\n## B. Horário + condição (variáveis conhecidas ANTES da abertura da vela)\n")
    ev = r.build_event_frame(a.live, a.tf, point, grid=a.grid)
    if ev is None:
        P("_sem dados de eventos_\n")
    else:
        P(f"Entradas condicionais em grade de {a.grid} min sobre eventos {a.tf} ({len(ev):,} eventos).\n")
        key_to_row = pd.Series(np.arange(len(cd)), index=cd["event_key"])
        pos = key_to_row.reindex(ev.index).to_numpy()
        okrow = np.isfinite(pos)
        ev = ev[okrow]; pos = pos[okrow].astype(int)
        NETe, HITe = NET[pos], HIT[pos]
        valid = np.isfinite(NETe)
        ev["slot_srv"] = ev["t"].dt.strftime("%H:%M"); ev["hour_srv"] = ev["t"].dt.hour.astype(str); ev["dow_slot_srv"] = ev["t"].dt.dayofweek.astype(str) + "|" + ev["slot_srv"]
        n = len(ev)
        t_split = ev["t"].iloc[int(n * 0.6)]
        di = np.nonzero((ev["t"] < t_split - pd.Timedelta(days=1)).to_numpy())[0]; vi = np.nonzero((ev["t"] >= t_split).to_numpy())[0]
        m.CAT = list(dict.fromkeys(m.CAT + r.EXTRA_CAT + ["slot_srv", "hour_srv", "dow_slot_srv"])); m.NUM = list(dict.fromkeys(m.NUM + [c for c in r.EXTRA_NUM if c in ev.columns]))
        feats, labels = m.build_features(ev, len(di))
        allowed = (r.PRE_ALLOWED - {"slot_hhmm", "hour", "dow_slot"}) | {"slot_srv", "hour_srv", "dow_slot_srv"}
        feats = {k: v for k, v in feats.items() if k in allowed}; names = list(feats.keys())
        pd_ev = np.array([HITe[di][valid[di][:, k], k].mean() for k in range(len(SERIES))]); pv_ev = np.array([HITe[vi][valid[vi][:, k], k].mean() for k in range(len(SERIES))])
        HDMe = HDM[pos]
        Yd = np.where(valid, HDMe, 0.0); Yv = np.where(valid, HDMe, 0.0)
        Vv = valid.astype(float)
        f = np.full(len(SERIES), 0.15)
        m.VAR_FLOOR = np.maximum(pd_ev * (1 - pd_ev), 1e-4)
        res = m.run_pipeline(feats, Yd[di], Vv[di], Yv[vi], Vv[vi], di, vi, f, names, 150, 60)
        res["td"] = np.where(res["td"] > 0, res["td"], 0.0)
        top, nbh, mtot, val, order = m.summarize(res)
        pl_b, pl_v = [], []
        rng = np.random.default_rng(3)
        for _ in range(6):
            lag = int(rng.integers(2000, max(2001, n - 2000)))
            Ydp, Yvp, Vp = np.roll(Yd, lag, 0), np.roll(Yv, lag, 0), np.roll(Vv, lag, 0)
            rp = m.run_pipeline(feats, Ydp[di], Vp[di], Yvp[vi], Vp[vi], di, vi, f, names, 150, 60)
            rp["td"] = np.where(rp["td"] > 0, rp["td"], 0.0)
            _, nb, _, vv, _ = m.summarize(rp); pl_b.append(nb); pl_v.append(vv)
        m.VAR_FLOOR = None
        P(f"Hipóteses testadas: **{mtot:,}**; passaram no BH na descoberta: **{nbh:,}**; confirmadas na validação: **{val:,}**; placebo: BH média {np.mean(pl_b):.1f} (máx {int(np.max(pl_b))}), confirmadas média {np.mean(pl_v):.1f} (máx {int(np.max(pl_v))}).\n")
        cand = np.nonzero((res["td"] > 2.0) & (res["tv"] > 1.645))[0]
        cand = cand[np.argsort(-res["td"][cand])][:6000]
        fam = {}
        for g in cand:
            i, j = divmod(int(res["pair"][g]), 1000); cb_n = int(feats[names[j]].max()) + 1
            ia, ib = divmod(int(res["cell"][g]), cb_n); si = int(res["h"][g])
            mask = (feats[names[i]] == ia) & (feats[names[j]] == ib)
            kf = (si, hash(np.packbits(mask).tobytes()))
            nc = 1 if names[j] == "ALL" else 2
            cur = fam.get(kf)
            if cur is None or nc < cur["nc"] or (nc == cur["nc"] and res["td"][g] > cur["td"]):
                fam[kf] = dict(g=int(g), i=i, j=j, ia=ia, ib=ib, si=si, nc=nc, td=float(res["td"][g]), alts=(cur["alts"] + 1) if cur else 1, mask=mask)
            else:
                cur["alts"] += 1
        vmask = np.zeros(n, bool); vmask[vi] = True; dmask = np.zeros(n, bool); dmask[di] = True
        bh_thr = np.sort(res["td"])[::-1][nbh - 1] if nbh > 0 else 1e9
        frows = []
        for fm in fam.values():
            si = fm["si"]; mask = fm["mask"]
            sel = mask & valid[:, si]
            sd, sv_ = sel & dmask, sel & vmask
            if sd.sum() < 60 or sv_.sum() < 40:
                continue
            gs = []
            for mk in (sd, sv_):
                nn = int(mk.sum()); kk = int(HITe[mk, si].sum())
                G = float(NETe[mk & HITe[:, si], si].mean()) if (mk & HITe[:, si]).any() else 0.0
                gs.append(ev_stress(kk, nn, G, LM[si])[0])
            if not (gs[0] > 0 and gs[1] > 0 and NETe[sd, si].mean() > 0 and NETe[sv_, si].mean() > 0):
                continue
            idx_all = pos[np.nonzero(sel)[0]]
            dd = describe(df, NET, HIT, MAE, EXM, idx_all, si, LM)
            # ---- WHEN does it fire: entry hours (server time) of this family, with hit rate and mean result per hour
            tsel = pd.to_datetime(ev["t"].to_numpy()[sel])
            gh = pd.DataFrame({"h": tsel.hour, "d": tsel.normalize(), "hit": HITe[sel, si], "net": NETe[sel, si]})
            byh = gh.groupby("h").agg(n=("hit", "size"), hit=("hit", "mean"), net=("net", "mean"))
            byh = byh[byh["n"] >= 15]
            horas_txt = " | ".join(f"{int(h):02d}h:{int(rr.n)}x {100*rr.hit:.0f}% {rr.net:+.0f}" for h, rr in byh.iterrows())
            good_h = [int(h) for h, rr in byh.iterrows() if rr.hit >= gh["hit"].mean() and rr.net > 0 and rr.n >= 25]
            rngs = []
            for h in good_h:
                if rngs and h == rngs[-1][1] + 1: rngs[-1][1] = h
                else: rngs.append([h, h])
            melhores = "; ".join(f"{a_:02d}h" if a_ == b_ else f"{a_:02d}h-{b_:02d}h" for a_, b_ in rngs)
            ndias = int(gh["d"].nunique()); anos = max(1.0, (gh["d"].max() - gh["d"].min()).days / 365.25)
            side, X = SERIES[si]
            hv = HITe[sv_, si]
            z_v = float(HDMe[sv_, si].mean()) / math.sqrt(max(pv_ev[si] * (1 - pv_ev[si]), 1e-9) / len(hv))
            halves = np.nonzero(sv_)[0]; h1, h2 = halves[: len(halves) // 2], halves[len(halves) // 2:]
            frows.append(dict(lado="COMPRA" if side > 0 else "VENDA", alvo_pts=X, condicao=cell_label(fm, names, labels), n=dd["n"], n_val=int(sv_.sum()), pct_alvo=dd["pct_alvo"], pct_alvo_val=100 * float(hv.mean()),
                              pct_base_val=100 * pv_ev[si], pct_alvo_min95=dd["pct_alvo_min95"], ganho_dia_alvo=dd["ganho_dia_alvo"], perda_media_sem_alvo=dd["perda_media_sem_alvo"],
                              pct_necessario_p_empatar=dd["pct_necessario_p_empatar"], ev_estresse_pts=dd["ev_estresse_pts"], ev_estresse_desc=gs[0], ev_estresse_val=gs[1], media_real_pts=dd["media_real_pts"],
                              pior_dia_pts=dd["pior_dia_pts"], mae_medio_pts=dd["mae_medio_pts"], mae_p90_pts=dd["mae_p90_pts"], min_ate_alvo=dd["min_ate_alvo"], z_desc=fm["td"], z_val=float(z_v),
                              passou_BH=bool(fm["td"] >= bh_thr), anos_pos=dd["anos_pos"], meses_pos=dd["meses_pos"], pct_alvo_h1=100 * float(HITe[halves[: len(halves) // 2], si].mean()) if len(h1) else np.nan,
                              pct_alvo_h2=100 * float(HITe[h2, si].mean()) if len(h2) else np.nan, formas=fm["alts"], primeiro=dd["primeiro"], ultimo=dd["ultimo"], por_ano=dd["por_ano"],
                              dias_semana=dd["dias_semana"], melhores_horas=melhores, horas_entrada=horas_txt, dias_com_sinal=ndias, dias_por_ano=ndias / anos, entradas_por_dia=len(gh) / max(ndias, 1), _mask=mask, _si=si))
        F = pd.DataFrame(frows)
        if len(F):
            good = F[(F["z_val"] > 1.645)].copy()
            good["cat"] = good["condicao"].map(lambda t_: "domingo/gap" if ("SUNDAY" in t_ or "dow_slot_srv=6" in t_ or "gap=Y" in t_) else ("sexta" if ("FRIDAY" in t_ or "dow_slot_srv=4" in t_) else "demais"))
            P(f"Famílias distintas que passam (hit rate acima da média dos horários na validação e `ev_estresse` > 0 nas duas metades do tempo): **{len(good)}** (BH na descoberta: {int(good['passou_BH'].sum())}).\n")
            cols = ["lado", "alvo_pts", "condicao", "n", "pct_alvo", "pct_alvo_val", "pct_base_val", "pct_alvo_min95", "ganho_dia_alvo", "perda_media_sem_alvo", "pct_necessario_p_empatar", "ev_estresse_pts", "media_real_pts", "pior_dia_pts", "mae_medio_pts", "mae_p90_pts", "min_ate_alvo", "z_val", "passou_BH", "anos_pos", "meses_pos", "formas"]
            gg = good[good["cat"] == "demais"].sort_values("ev_estresse_pts", ascending=False)
            P("### Famílias (exclui domingo/gap/sexta), ordenadas por expectativa estressada\n")
            P(r.md_table(gg[cols].head(40), 1))
            P("\n### Estabilidade\n")
            P(r.md_table(gg[["lado", "alvo_pts", "condicao", "primeiro", "ultimo", "pct_alvo_h1", "pct_alvo_h2", "por_ano", "dias_semana"]].head(40), 1))
            gs_ = good[good["cat"] != "demais"].sort_values("ev_estresse_pts", ascending=False)
            if len(gs_):
                P("\n### Abertura de semana / gap / sexta (execução menos confiável)\n")
                P(r.md_table(gs_[cols].head(15), 1))
            good.drop(columns=["_mask", "_si"]).to_csv(os.path.join(a.out, f"{a.name}{a.tag}_condicionais.csv"), index=False)
            occ = []
            for _, x in gg.head(15).iterrows():
                sel = np.nonzero(x["_mask"] & valid[:, x["_si"]])[0]
                for k in sel:
                    occ.append(dict(lado=x["lado"], alvo_pts=x["alvo_pts"], condicao=x["condicao"], data_servidor=str(ev["t"].iloc[k])[:16], bateu_alvo=bool(HITe[k, x["_si"]]), resultado_pts=round(float(NETe[k, x["_si"]]), 1)))
            pd.DataFrame(occ).to_csv(os.path.join(a.out, f"{a.name}{a.tag}_ocorrencias_condicionais.csv"), index=False)
            P("\n**Últimas 10 ocorrências das 12 primeiras (data/hora do servidor → líquido em pontos; * = bateu o alvo):**\n")
            for _, x in gg.head(12).iterrows():
                sel = np.nonzero(x["_mask"] & valid[:, x["_si"]])[0][-10:]
                P(f"- {x['lado']} alvo {x['alvo_pts']} | {x['condicao']}: " + "; ".join(f"{str(ev['t'].iloc[k])[5:16]} {NETe[k, x['_si']]:+.0f}{'*' if HITe[k, x['_si']] else ''}" for k in sel))
        else:
            P("**Nenhuma família passou.**\n")
    P(f"\n_(tempo {time.time() - t0:.0f}s)_\n")
    open(os.path.join(a.out, f"{a.name}{a.tag}.md"), "w", encoding="utf-8").write("\n".join(L))
    print("OK", a.name, f"{time.time() - t0:.0f}s")


if __name__ == "__main__":
    sys.exit(main())
