#!/usr/bin/env python3
"""Intraday time-slot patterns, in SERVER time, for manual chart validation.

For every symbol: entry at the OPEN of a candle slot (server HH:MM), side long/short, holding time = the candle itself or the candle plus 15/30/60/120 min.
For each (timeframe, slot, side, holding time) over all days: n, % of days the direction was right, % net-profitable, % with net >= 100/200/300/500 pts,
% that TOUCHED +300 pts in the favourable direction, mean/median net points, discovery vs validation (60/40 chronological), years/months positive,
weekday split, cost with the same tick-based spread model as mba_report.py. A pattern is listed only if it passes discovery AND validation; a
time-shift placebo reports how many such patterns pure chance would produce.

  python tools/mba/mba_slots.py --live "<.../LIVE>" --name USDJPY --out docs/relatorios/mba/padroes
"""
import argparse, glob, math, os, sys, time
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mba_mine as m
import mba_report as r

sys.stdout.reconfigure(encoding="utf-8")
TFS = {"M1": 1, "M5": 5, "M15": 15, "M30": 30, "H1": 60}
EXTRA = [0, 15, 30, 60, 120]            # minutes after the candle close (0 = hold only the candle)
THR = [100, 200, 300, 500]


def cost_model(live):
    base = r.load_candles(live, "M5")
    s5 = None
    prof = pd.Series(np.nan, index=range(96))
    if len(base):
        s5 = base.set_index("t")["bar_spread_points"].astype(float); s5 = s5[~s5.index.duplicated()]
        tb = base[base["tick_data_ok"].astype(str).str.upper() == "TRUE"]
        if len(tb) >= 500:
            src = pd.Series(tb["spread_avg_points"].to_numpy(float)); sl = r.slot30(tb["u"])
        else:
            src = pd.Series(base["bar_spread_points"].to_numpy(float)); sl = r.slot30(base["u"])
        gb = src.groupby(sl); med, cnt = gb.median().reindex(range(96)), gb.size().reindex(range(96)).fillna(0)
        wk = med.iloc[:48].interpolate(limit_direction="both")
        sun = med.iloc[48:].where(cnt.iloc[48:] >= 5)
        prof = pd.concat([wk, sun.fillna(pd.Series(wk.values, index=range(48, 96)))])
    return s5, prof


def load(live, tf, point, s5, prof):
    cd = r.load_candles(live, tf)
    if len(cd) == 0:
        return None
    ft = m.read_parts(os.path.join(live, "FORWARD_TIME"), f"forward_time_{tf}",
                      ["event_key", "horizon_min", "complete", "future_return_points", "max_up_points", "max_down_points", "schema_version"])
    if len(ft) == 0:
        return None
    hs = [h for h in EXTRA if h > 0]
    ft = ft[(ft["complete"].astype(str).str.upper() == "TRUE") & ft["horizon_min"].isin(hs)].drop_duplicates(["event_key", "horizon_min"])
    cd = cd.set_index("event_key")
    n_ev = cd.index
    piv = lambda col: ft.pivot(index="event_key", columns="horizon_min", values=col).reindex(index=n_ev, columns=hs)
    RP, UP, DN = piv("future_return_points").to_numpy(float), piv("max_up_points").to_numpy(float), piv("max_down_points").to_numpy(float)
    ok_close = (cd["close"].notna() & cd["open"].notna()).to_numpy()
    own = ((cd["close"] - cd["open"]) / point).to_numpy(float)
    up_own = ((cd["high"] - cd["open"]) / point).to_numpy(float)
    dn_own = ((cd["open"] - cd["low"]) / point).to_numpy(float)
    tfm = TFS[tf]
    n = len(cd)
    # per holding option k: gross return from the open, favourable excursion from the open, cost (long: entry; short: exit)
    G = np.full((n, len(EXTRA)), np.nan); MU = np.full_like(G, np.nan); MD = np.full_like(G, np.nan)
    CLg = np.full_like(G, np.nan); CSg = np.full_like(G, np.nan)
    pf = lambda uu: prof.reindex(r.slot30(uu)).to_numpy(float)
    prev_sp = cd["bar_spread_points"].astype(float).shift(1).to_numpy(float)
    ent = np.fmax(prev_sp, pf(cd["u"]))
    for k, h in enumerate(EXTRA):
        if h == 0:
            G[:, k] = own; MU[:, k] = up_own; MD[:, k] = dn_own
            x = np.fmax(cd["bar_spread_points"].astype(float).to_numpy(float), pf(cd["u"] + pd.to_timedelta(tfm, unit="m")))
        else:
            j = hs.index(h)
            G[:, k] = own + RP[:, j]
            MU[:, k] = np.fmax(up_own, own + UP[:, j]); MD[:, k] = np.fmax(dn_own, -own + DN[:, j])
            key = cd["t"] + pd.to_timedelta(tfm + h - 5, unit="m")
            sb = s5.reindex(key).to_numpy(float) if s5 is not None else np.full(n, np.nan)
            x = np.fmax(sb, pf(cd["u"] + pd.to_timedelta(tfm + h, unit="m")))
        CLg[:, k] = ent; CSg[:, k] = x
    df = pd.DataFrame({"t": cd["t"].to_numpy(), "u": cd["u"].to_numpy()})
    df["slot"] = cd["t"].dt.strftime("%H:%M").to_numpy()
    df["dow"] = cd["t"].dt.dayofweek.to_numpy()
    df["ok"] = ok_close & np.isfinite(own)
    return df, G, MU, MD, CLg, CSg


def stats_for(df, G, MU, MD, CL, CS, tf, split_idx, thr_disc=2.0, thr_val=1.645, min_n=120, shift=0):
    rows = []
    n = len(df)
    order = np.arange(n)
    if shift:
        G = np.roll(G, shift, 0); MU = np.roll(MU, shift, 0); MD = np.roll(MD, shift, 0); CL = np.roll(CL, shift, 0); CS = np.roll(CS, shift, 0)
    is_d = order < split_idx
    slots = df["slot"].to_numpy()
    for slot in np.unique(slots):
        sm = (slots == slot) & df["ok"].to_numpy()
        if sm.sum() < min_n:
            continue
        for k, h in enumerate(EXTRA):
            g = G[sm, k]
            valid = np.isfinite(g)
            if valid.sum() < min_n:
                continue
            for side in (1, -1):
                gross = side * g
                cost = CL[sm, k] if side > 0 else CS[sm, k]
                net = gross - cost
                ok = np.isfinite(net)
                if ok.sum() < min_n:
                    continue
                d = is_d[sm] & ok; v = (~is_d[sm]) & ok
                if d.sum() < 40 or v.sum() < 30:
                    continue
                def tt(x):
                    return float(x.mean() / (x.std(ddof=1) / math.sqrt(len(x)))) if len(x) > 2 and x.std(ddof=1) > 0 else 0.0
                td, tv = tt(net[d]), tt(net[v])
                if not (td >= thr_disc and tv >= thr_val and net[d].mean() > 0 and net[v].mean() > 0):
                    continue
                mfe = (MU if side > 0 else MD)[sm, k]
                rows.append(dict(tf=tf, slot=slot, lado="COMPRA" if side > 0 else "VENDA", k=k, extra=h, dur=TFS[tf] + h, n=int(ok.sum()), n_desc=int(d.sum()), n_val=int(v.sum()),
                                 t_desc=td, t_val=tv, idx=np.nonzero(sm)[0][ok], net=net[ok], gross=gross[ok], mfe=mfe[ok], cost=cost[ok], side=side,
                                 m_desc=float(net[d].mean()), m_val=float(net[v].mean())))
    return rows


def pattern_row(pr, df):
    net, gross, mfe, cost, idx = pr["net"], pr["gross"], pr["mfe"], pr["cost"], pr["idx"]
    t = pd.to_datetime(df["t"].to_numpy()[idx])
    yr = t.year
    ys = pd.Series(net).groupby(yr).agg(["mean", "size"])
    ys = ys[ys["size"] >= 15]
    mo = pd.Series(net).groupby(t.to_period("M")).agg(["mean", "size"]); mo = mo[mo["size"] >= 3]
    dw = pd.Series(net > 0).groupby(df["dow"].to_numpy()[idx]).agg(["mean", "size"])
    out = dict(tf=pr["tf"], entrada_servidor=pr["slot"], dur_min=pr["dur"], lado=pr["lado"], n=pr["n"],
               pct_acerto_bruto=100 * float((gross > 0).mean()), pct_liquido_pos=100 * float((net > 0).mean()),
               pct_liq_ge_100=100 * float((net >= 100).mean()), pct_liq_ge_200=100 * float((net >= 200).mean()), pct_liq_ge_300=100 * float((net >= 300).mean()), pct_liq_ge_500=100 * float((net >= 500).mean()),
               pct_toca_300=100 * float((mfe >= 300).mean()), media_liq_pts=float(net.mean()), mediana_liq_pts=float(np.median(net)), custo_medio_pts=float(cost.mean()),
               media_bruta_pts=float(gross.mean()), t_desc=pr["t_desc"], t_val=pr["t_val"], liq_desc=pr["m_desc"], liq_val=pr["m_val"], n_val=pr["n_val"],
               anos_pos=f"{int((ys['mean'] > 0).sum())}/{len(ys)}", meses_pos=f"{int((mo['mean'] > 0).sum())}/{len(mo)}",
               por_ano="; ".join(f"{int(a)}:{v:+.0f}" for a, v in ys["mean"].items()),
               dias_acerto=" ".join(f"{['seg','ter','qua','qui','sex','sab','dom'][int(a)]}={100*v:.0f}%({int(c)})" for a, (v, c) in dw.iterrows() if c >= 10),
               primeiro=str(t.min())[:10], ultimo=str(t.max())[:10])
    return out


def merge_windows(rows):
    """merge overlapping entry..exit windows of the same side (keep the member with the best validation t)."""
    def mins(hhmm):
        h, mm = hhmm.split(":"); return int(h) * 60 + int(mm)
    for x in rows:
        x["_a"] = mins(x["entrada_servidor"]); x["_b"] = x["_a"] + x["dur_min"]
    out = []
    for side in ("COMPRA", "VENDA"):
        L = sorted([x for x in rows if x["lado"] == side], key=lambda z: z["_a"])
        cur = None
        for x in L:
            if cur is not None and x["_a"] <= cur["_b"]:
                cur["_members"].append(x); cur["_b"] = max(cur["_b"], x["_b"])
            else:
                if cur: out.append(cur)
                cur = dict(x); cur["_members"] = [x]
        if cur: out.append(cur)
    res = []
    for c in out:
        best = max(c["_members"], key=lambda z: (z["t_val"] + z["t_desc"]))
        b = dict(best)
        b["janela"] = f"{c['_members'][0]['entrada_servidor']}–{c['_b'] // 60 % 24:02d}:{c['_b'] % 60:02d}"
        b["variantes"] = len(c["_members"])
        res.append(b)
    return sorted(res, key=lambda z: (z["lado"], z["entrada_servidor"]))


def hhmm_shift(hhmm, minutes):
    h, mm = hhmm.split(":"); v = (int(h) * 60 + int(mm) + minutes) % 1440
    return f"{v // 60:02d}:{v % 60:02d}"


def md_table(df, fmt=1):
    return r.md_table(df, fmt)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--live", required=True); ap.add_argument("--name", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--placebos", type=int, default=12)
    ap.add_argument("--tfs", default="M5,M15,M30,H1")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    t0 = time.time()
    spec = r.read_spec(a.live); point = float(spec.get("point", 0.00001))
    s5, prof = cost_model(a.live)
    rng = np.random.default_rng(5)
    allrows, plc = [], {tf: [] for tf in TFS}
    info = []
    for tf in a.tfs.split(","):
        ld = load(a.live, tf, point, s5, prof)
        if ld is None:
            continue
        df, G, MU, MD, CL, CS = ld
        n = len(df)
        if n < 3000:
            continue
        split = int(n * 0.6)
        rows = stats_for(df, G, MU, MD, CL, CS, tf, split)
        for p in rows:
            allrows.append(pattern_row(p, df))
            allrows[-1]["_ids"] = (tf, p["slot"], p["k"], p["side"])
        for _ in range(a.placebos):
            plc[tf].append(len(stats_for(df, G, MU, MD, CL, CS, tf, split, shift=int(rng.integers(2000, n - 2000)))))
        info.append(dict(tf=tf, eventos=n, inicio=str(pd.to_datetime(df["t"]).min())[:10], fim=str(pd.to_datetime(df["t"]).max())[:10],
                         testes=int(df["slot"].nunique() * len(EXTRA) * 2), passaram=len(rows), placebo_media=float(np.mean(plc[tf])), placebo_max=int(np.max(plc[tf]))))
        # occurrence dates for the best patterns of this TF
        top = sorted(rows, key=lambda z: -(z["t_val"] + z["t_desc"]))[:25]
        occ = []
        for p in top:
            tt = pd.to_datetime(df["t"].to_numpy()[p["idx"]])
            for ti, nv, gv in zip(tt, p["net"], p["gross"]):
                occ.append(dict(tf=tf, entrada_servidor=p["slot"], lado=p["lado"], dur_min=p["dur"], data_hora_servidor=str(ti)[:16], bruto_pts=round(float(gv), 1), liquido_pts=round(float(nv), 1)))
        if occ:
            pd.DataFrame(occ).to_csv(os.path.join(a.out, f"{a.name}_ocorrencias_{tf}.csv"), index=False)
    L = []; P = L.append
    P(f"# {a.name} — padrões por horário (hora do servidor), para validar no gráfico\n")
    P("Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). "
      "Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** "
      "Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.\n")
    P(md_table(pd.DataFrame(info), 1))
    P("`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.\n")
    if not allrows:
        P("**Nenhum padrão de horário passou nos critérios para este ativo.**\n")
    else:
        merged = merge_windows(allrows)
        D = pd.DataFrame(merged)
        D["londres"] = D["entrada_servidor"].map(lambda s: hhmm_shift(s, -120)); D["ny"] = D["entrada_servidor"].map(lambda s: hhmm_shift(s, -420))
        D = D.sort_values("t_val", ascending=False)
        cols1 = ["janela", "lado", "tf", "entrada_servidor", "londres", "ny", "dur_min", "n", "pct_acerto_bruto", "pct_liquido_pos", "pct_liq_ge_100", "pct_liq_ge_200", "pct_liq_ge_300",
                 "pct_liq_ge_500", "pct_toca_300", "media_liq_pts", "mediana_liq_pts", "custo_medio_pts", "variantes"]
        P("## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)\n")
        P("`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).\n")
        P(md_table(D[cols1], 1))
        P("## Estabilidade (para conferir no gráfico)\n")
        P(md_table(D[["janela", "lado", "tf", "entrada_servidor", "dur_min", "n", "primeiro", "ultimo", "t_desc", "t_val", "liq_desc", "liq_val", "anos_pos", "meses_pos", "por_ano", "dias_acerto"]], 2))
        D.drop(columns=[c for c in D.columns if c.startswith("_")]).to_csv(os.path.join(a.out, f"{a.name}_padroes.csv"), index=False)
    P("\n## Como validar no gráfico\n")
    P("1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. "
      "3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).\n")
    P(f"\n_(tempo {time.time() - t0:.0f}s)_\n")
    open(os.path.join(a.out, f"{a.name}.md"), "w", encoding="utf-8").write("\n".join(L))
    print("OK", a.name, f"{time.time() - t0:.0f}s", info)


if __name__ == "__main__":
    sys.exit(main())
