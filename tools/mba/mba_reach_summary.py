#!/usr/bin/env python3
"""Reach study, consolidation: test counts vs placebo per symbol/timeframe/window/clock granularity, cross-timeframe confirmation of
clock patterns, and a full "ficha" (decision table) for each surviving candidate.

  python tools/mba/mba_reach_summary.py --cache <m1cache> --reach <reach_cache> --logs <dir with an_*.log / st_*.log> --out docs/relatorios/mba/reach
"""
import argparse, ast, glob, json, os, re, sys
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mba_reach_analyze import Data, NOHIT, SPLIT, wilson

sys.stdout.reconfigure(encoding="utf-8")
SYMS = ["XAUUSD", "XAGUSD", "US30", "DXY_Z6", "USDJPY", "EURJPY", "GBPJPY", "USDCHF", "AUDUSD", "NZDUSD_r"]
M1_LONG = {"XAGUSD", "EURJPY", "GBPJPY"}          # M1 history since 2024-01; the others only since Mar/Apr 2026


def parse_logs(logdir):
    rows, srows = [], []
    for fn in glob.glob(os.path.join(logdir, "an_*.log")):
        for ln in open(fn, encoding="utf-8"):
            m = re.match(r"^(\S+) (M\d+)_W(\d+) (\S+) (\{.*?\}) (\{.*\})\s*$", ln)
            if not m:
                continue
            d1, d2 = ast.literal_eval(m.group(5)), ast.literal_eval(m.group(6))
            rows.append(dict(symbol=m.group(1), tf=m.group(2), W=int(m.group(3)), clock=m.group(4),
                             dir_tests=d1.get("tests"), dir_validated=d1.get("validated"), dir_fwer_and_val=d1.get("fwer_and_val"),
                             dir_placebo_mean=d1.get("placebo_validated_mean"), dir_placebo_max=d1.get("placebo_validated_max"),
                             ev_tests=d2.get("tests"), ev_validated=d2.get("validated"), ev_validated_bh=d2.get("validated_and_bh"),
                             ev_clocks=d2.get("validated_clocks"), ev_placebo_mean=d2.get("placebo_mean"), ev_placebo_max=d2.get("placebo_max")))
    for fn in glob.glob(os.path.join(logdir, "st_*.log")):
        m = re.match(r"st_(.+)_(M\d+)_(\d+)\.log", os.path.basename(fn))
        last = [ln for ln in open(fn, encoding="utf-8") if ln.startswith("{")]
        if m and last:
            d = ast.literal_eval(last[-1].strip())
            srows.append(dict(symbol=m.group(1), tf=m.group(2), W=int(m.group(3)), tests=d["tests"], validated=d["validated"],
                              race=d["validated_by_outcome"].get("race", 0), ev_buy=d["validated_by_outcome"].get("EV_BUY_Ak", 0),
                              ev_sell=d["validated_by_outcome"].get("EV_SELL_Ak", 0), placebo_mean=d["placebo_mean"], placebo_max=d["placebo_max"],
                              k_tested=",".join(map(str, d["k_tested"]))))
    return pd.DataFrame(rows), pd.DataFrame(srows)


def to_min(clock):
    h, m = clock.split(":"); return int(h) * 60 + int(m)


def candidates(out):
    """EV clock patterns (exact slot) validated in discovery+validation, with losses in validation, confirmed in >= 2 timeframes
    (same side, entry within +-10 min) -- M1 of the short-history symbols counts only as exploratory support."""
    rows = []
    for sym in SYMS:
        for f in glob.glob(os.path.join(out, sym, "G_ev_slot_*.csv.gz")):
            tf, W = re.search(r"_(M\d+)_W(\d+)", f).groups()
            d = pd.read_csv(f)
            d = d[d["validated"] & np.isfinite(d["t_val"]) & (d["ev_val"] > 0)]
            if len(d) == 0:
                continue
            d = d.assign(symbol=sym, tf=tf, W=int(W), minute=d["clock"].map(to_min))
            rows.append(d)
    if not rows:
        return pd.DataFrame()
    A = pd.concat(rows, ignore_index=True)
    A["long_history"] = (A["tf"] != "M1") | A["symbol"].isin(M1_LONG)
    conf = []
    for i, r in A.iterrows():
        o = A[(A.symbol == r.symbol) & (A.side == r.side) & (A.tf != r.tf) & ((A.minute - r.minute).abs() <= 10)]
        conf.append(",".join(sorted(set(o.tf))))
    A["confirmed_in"] = conf
    # rollover zone: entry 23:00-01:15 server or a window that runs past 00:00 (bid quotes distorted by the rollover spread, swap charged)
    A["rolagem"] = (A["minute"] >= 23 * 60) | (A["minute"] < 75) | (A["minute"] + A["W"] > 1440)
    return A


def ficha(cache, reach, specs, sym, tf, W, clock, side, k, adverse):
    D = Data(cache, reach, sym, tf, W, specs)
    q = int(np.nonzero(D.K == k)[0][0])
    A = {"k": q, "2k": D.q2.get(q), "sem": None}[adverse]
    x, win, amb = D.ev(q, side, A)
    m = D.elig & (D.mod == to_min(clock))
    idx = np.nonzero(m)[0]
    f = (D.bf if side == "BUY" else D.sf)[idx, q].astype(int)
    a = (D.ba if side == "BUY" else D.sa)[idx, A].astype(int) if A is not None else np.full(len(idx), NOHIT)
    lose = (a <= f) & (a != NOHIT)
    tmo = ~win[idx] & ~lose
    tt = D.t[np.minimum(idx + np.where(f == NOHIT, 0, f), len(D.t) - 1)] - D.t[idx]
    mae = (D.mae_b if side == "BUY" else D.mae_s)[idx, q]
    xs = x[idx]
    disc = D.disc[idx]
    yrs = D.year[idx]; mon = D.month[idx]
    by_year = pd.Series(xs).groupby(yrs).agg(["size", "mean"])
    by_mon = pd.Series(xs).groupby(mon).mean()
    by_wd = pd.Series(win[idx]).groupby(D.wd[idx]).agg(["size", "mean"])
    streak = mx = 0
    for v in xs:
        streak = streak + 1 if v < 0 else 0; mx = max(mx, streak)
    hit = f != NOHIT
    lo, hi = wilson(win[idx].sum(), len(idx))
    last = [f"{str(np.datetime64(int(D.t[i]), 'm'))[:10]} {xs[j]:+.0f}" for j, i in enumerate(idx[-10:], start=len(idx) - 10)]
    return dict(Ativo=sym, Timeframe=f"{tf} (janela {W} min)", Horario=f"{clock} servidor", Direcao=side,
                Condicao=f"entrada na abertura da barra {clock}; alvo +{k} pts líquido; limite adverso {'nenhum (sai no fim da janela)' if A is None else str(int(D.K[A])) + ' pts'}",
                Distancia_alvo=f"{k} pts MT5 (point={D.pt})", Ocorrencias=len(idx), Sucessos=int(win[idx].sum()),
                Taxa_alcance=f"{100 * win[idx].mean():.1f}% (IC95 {100 * lo:.1f}-{100 * hi:.1f}); limite primeiro {100 * lose.mean():.1f}%; mesma barra {100 * amb[idx].mean():.1f}%; nenhum {100 * tmo.mean():.1f}%",
                Excursao_adversa=f"antes do alvo: mediana {np.nanmedian(mae):.0f}, p90 {np.nanpercentile(mae[hit], 90) if hit.any() else np.nan:.0f} pts",
                Tempo_ate_meta=f"mediana {np.median(tt[hit]) if hit.any() else np.nan:.0f} min, p90 {np.percentile(tt[hit], 90) if hit.any() else np.nan:.0f} min",
                Custo_estimado=f"spread mediano {np.median(D.spr[idx]):.1f} pts + swap {D.swap[side]:+.1f} pts/noite se atravessar 00:00; comissão não incluída",
                Resultado=f"média {xs.mean():+.1f} pts/op (descoberta {xs[disc].mean():+.1f}, validação {xs[~disc].mean():+.1f}); pior op {xs.min():+.0f}; maior sequência de perdas {mx}",
                Estabilidade=f"anos: {'; '.join(f'{int(y)}: {r['mean']:+.0f} (n={int(r['size'])})' for y, r in by_year.iterrows())}; meses positivos {int((by_mon > 0).sum())}/{len(by_mon)}; acerto por dia SEG..SEX: {' '.join(f'{100 * r['mean']:.0f}%' for _, r in by_wd.iterrows())}",
                Ultimas=", ".join(last))


def monday_gap(cache, sym):
    """Monday gap (week open vs Friday close) closed during Monday vs a baseline: on Tue-Fri, how often does price travel the same
    distance from the day open in the same direction (toward where the previous close would be)?"""
    z = np.load(os.path.join(cache, f"{sym}_M15.npz")); pt = float(z["point"])
    t = z["t"]; day = t // 1440; wd = (day + 3) % 7
    d = pd.DataFrame(dict(day=day, wd=wd, o=z["o"], h=z["h"], l=z["l"], c=z["c"])).groupby("day").agg(
        wd=("wd", "first"), O=("o", "first"), H=("h", "max"), L=("l", "min"), C=("c", "last"))
    d["prevC"] = d["C"].shift(1); d = d.dropna()
    mon = d[d.wd == 0].copy(); oth = d[(d.wd > 0) & (d.wd < 5)]
    mon["gap"] = (mon.O - mon.prevC) / pt
    sp = float(np.nanmedian(z["spr"]))
    mon = mon[mon.gap.abs() >= 5 * max(sp, 1)]
    if len(mon) == 0:
        return {}
    mon["filled"] = np.where(mon.gap > 0, mon.L <= mon.prevC, mon.H >= mon.prevC)
    dn_room = ((oth.O - oth.L) / pt).to_numpy(); up_room = ((oth.H - oth.O) / pt).to_numpy()
    base = np.mean([(dn_room >= g).mean() if g > 0 else (up_room >= -g).mean() for g in mon.gap])
    big = mon[mon.gap.abs() >= mon.gap.abs().median()]
    base_big = np.mean([(dn_room >= g).mean() if g > 0 else (up_room >= -g).mean() for g in big.gap])
    return dict(segundas=len(mon), gap_mediano_pts=float(mon.gap.abs().median()), gap_fechou_pct=float(100 * mon.filled.mean()),
                base_outros_dias_pct=float(100 * base), gaps_grandes=len(big), gap_grande_fechou_pct=float(100 * big.filled.mean()),
                base_gaps_grandes_pct=float(100 * base_big), gap_alta_pct=float(100 * (mon.gap > 0).mean()))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", required=True); ap.add_argument("--reach", required=True); ap.add_argument("--logs", required=True)
    ap.add_argument("--out", required=True); ap.add_argument("--specs", required=True)
    a = ap.parse_args()
    T, ST = parse_logs(a.logs)
    T.sort_values(["symbol", "tf", "W", "clock"]).to_csv(os.path.join(a.out, "H_contagem_vs_placebo_relogio.csv"), index=False)
    ST.sort_values(["symbol", "tf", "W"]).to_csv(os.path.join(a.out, "H_contagem_vs_placebo_estrutural.csv"), index=False)
    C = candidates(a.out)
    C.to_csv(os.path.join(a.out, "H_candidatos_ev_relogio.csv"), index=False, float_format="%.2f")
    G = pd.DataFrame([dict(symbol=s, **monday_gap(a.cache, s)) for s in SYMS])
    G.to_csv(os.path.join(a.out, "I_gap_segunda.csv"), index=False, float_format="%.1f")
    print(G.to_string())
    print(T.to_string()); print(ST.to_string())
    if len(C):
        yp = C["years_pos"].str.split("/", expand=True).astype(int)
        C["all_years_pos"] = yp[0] == yp[1]
        strong = C[C["long_history"] & (C["confirmed_in"] != "") & C["all_years_pos"]].copy()
        strong["cluster"] = strong["minute"] // 15
        best = strong.sort_values("t_val", ascending=False).groupby(["symbol", "side", "rolagem", "cluster"]).head(1)
        best = pd.concat([best[~best["rolagem"]].head(20), best[best["rolagem"]].head(8)])
        F = []
        for _, r in best.iterrows():
            f = ficha(a.cache, a.reach, a.specs, r.symbol, r.tf, int(r.W), r.clock, r.side, int(r.k_pts), r.adverse)
            f["Validacao"] = (f"descoberta t={r.t_disc:.1f}, validação t={r.t_val:.1f} (corte {r.tf}); BH {'sim' if r.bh_disc else 'não'}; "
                              f"confirmado em {r.confirmed_in}")
            f["Rolagem"] = "SIM — bid distorcido/swap" if r.rolagem else "não"
            f["Confianca"] = ("insuficiente (zona de rolagem)" if r.rolagem else
                              "forte" if (r.bh_disc and r.t_val >= 3 and r.tf == "M15") else "limitada")
            F.append(f); print(f["Ativo"], f["Horario"], f["Direcao"], f["Resultado"], flush=True)
        pd.DataFrame(F).to_csv(os.path.join(a.out, "H_fichas_candidatos.csv"), index=False)


if __name__ == "__main__":
    main()
