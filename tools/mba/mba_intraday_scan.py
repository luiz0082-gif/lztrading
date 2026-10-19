#!/usr/bin/env python3
"""Varredura intraday de TODOS os horários: entrada na abertura de cada barra entre 01:00 e 22:30 do servidor (dia de pregão do
servidor: abre 01:00, fecha 23:59), saída no alvo +k líquido ou às 23:30 do servidor (30 min antes do fechamento), sem stop.
Barras de BID: compra no ask (abertura + spread), venda recompra no ask de cada barra (mínima + spread daquela barra).

Para cada ativo × horário × lado × alvo: % de dias que alcançou o alvo antes das 23:30, minutos até o alvo, quanto andou contra
antes, resultado médio por operação (alvo ou saída às 23:30), descoberta (60% iniciais dos dias) × validação (40% finais), por ano.
Um horário é APROVADO se: média > 0 nos dois períodos, t ≥ 2,5 na descoberta e ≥ 1,65 na validação, todos os anos positivos.
PLACEBO: os horários são embaralhados dentro de cada dia (mantém a tendência e a volatilidade do dia, destrói o horário) 50 vezes;
se o número de aprovados reais não supera o placebo, o "horário" não acrescenta nada à tendência do período.
Também calcula o EXCESSO: resultado do horário menos a média de todos os horários do mesmo dia.

  python tools/mba/mba_intraday_scan.py --cache <m1cache> --out docs/relatorios/mba/intraday --tf M5
"""
import argparse, math, os, sys
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
SYMS = ["XAUUSD", "XAGUSD", "US30", "DXY_Z6", "USDJPY", "EURJPY", "GBPJPY", "USDCHF", "AUDUSD", "NZDUSD_r"]
KS = {"XAUUSD": [100, 200, 300, 500, 1000], "US30": [500, 1000, 2000, 3000, 5000], "XAGUSD": [100, 200, 300, 500],
      "DXY_Z6": [50, 100, 200]}
KS_FX = [50, 100, 200, 300]
EXIT_SRV = 23 * 60 + 30


def build(cache, sym, tf, ks, start, end):
    z = np.load(os.path.join(cache, f"{sym}_{tf}.npz"))
    t, ldn = z["t"], z["ldn"]; o, h, l, c = z["o"], z["h"], z["l"], z["c"]; pt = float(z["point"])
    spr = z["spr"].astype(float); tok = z["tok"].astype(bool)
    s30 = (t % 1440) // 30
    if tok.sum() >= 500:
        prof = pd.Series(spr[tok]).groupby(s30[tok]).median().reindex(range(48)).fillna(np.nanmedian(spr[tok])).to_numpy()
        spr = np.where(tok & np.isfinite(spr), spr, prof[s30])
    spr = np.where(np.isfinite(spr), spr, np.nanmedian(spr))
    day = t // 1440; mod = t % 1440; wd = (day + 3) % 7
    last = {}
    for d_, i in zip(day[mod < EXIT_SRV], np.nonzero(mod < EXIT_SRV)[0]):
        last[d_] = i
    rows = []
    for i in np.nonzero((wd < 5) & (mod >= start) & (mod <= end))[0]:
        j = last.get(day[i])
        if j is None or j <= i or mod[j] < EXIT_SRV - 60:          # dia sem dados até perto das 23:30
            continue
        H, L, S = h[i:j + 1], l[i:j + 1], spr[i:j + 1]
        fb = np.maximum.accumulate((H - o[i]) / pt - spr[i]); ab = np.maximum.accumulate((o[i] - L) / pt + spr[i])
        fs = np.maximum.accumulate((o[i] - L) / pt - S); as_ = np.maximum.accumulate((H - o[i]) / pt + S)
        eb = (c[j] - o[i]) / pt - spr[i]; es = (o[i] - c[j]) / pt - spr[j]
        r = [int(day[i]), int(mod[i]), int(ldn[i] % 1440), eb, es, fb[-1], fs[-1], ab[-1], as_[-1]]
        for k in ks:
            for f, a, e in ((fb, ab, eb), (fs, as_, es)):
                w = np.searchsorted(f, k)                      # f é não-decrescente: primeiro índice com f >= k
                if w < len(f):
                    r += [1, float(t[i + w] - t[i]), float(a[w]), float(k)]
                else:
                    r += [0, np.nan, np.nan, e]
        rows.append(r)
    cols = ["day", "mod", "lmod", "end_buy", "end_sell", "mfe_buy", "mfe_sell", "mae_buy", "mae_sell"]
    for k in ks:
        for s in ("buy", "sell"):
            cols += [f"{s}_hit{k}", f"{s}_t{k}", f"{s}_mae{k}", f"{s}_pl{k}"]
    return pd.DataFrame(rows, columns=cols), pt


def tval(x):
    x = x[np.isfinite(x)]
    return x.mean() / (x.std(ddof=1) / math.sqrt(len(x))) if len(x) > 5 and x.std() > 0 else np.nan


def approve(P, D, isdesc, years):
    """P: dias × horários (resultado). Retorna máscara de horários aprovados."""
    out = []
    for s in range(P.shape[1]):
        x = P[:, s]
        d, v = x[isdesc], x[~isdesc]
        md, mv = np.nanmean(d), np.nanmean(v)
        ok = md > 0 and mv > 0 and tval(d) >= 2.5 and tval(v) >= 1.65
        if ok:
            ys = pd.Series(x).groupby(years).mean()
            ok = bool((ys > 0).all())
        out.append(ok)
    return np.array(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", required=True); ap.add_argument("--out", required=True); ap.add_argument("--tf", default="M5")
    ap.add_argument("--syms", nargs="*", default=SYMS); ap.add_argument("--placebos", type=int, default=50)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    rng = np.random.default_rng(5)
    rows, summ = [], []
    for sym in a.syms:
        ks = KS.get(sym, KS_FX)
        df, pt = build(a.cache, sym, a.tf, ks, 60, 22 * 60 + 30)
        days = np.sort(df["day"].unique()); slots = np.sort(df["mod"].unique())
        di = np.searchsorted(days, df["day"]); si = np.searchsorted(slots, df["mod"])
        cut = days[int(len(days) * 0.6)]
        isdesc = days < cut
        years = days.astype("datetime64[D]").astype("datetime64[Y]").astype(int) + 1970
        lmed = df.groupby("mod")["lmod"].agg(lambda s: s.mode().iat[0]).reindex(slots).to_numpy()
        for side in ("buy", "sell"):
            for k in ks:
                P = np.full((len(days), len(slots)), np.nan); P[di, si] = df[f"{side}_pl{k}"].to_numpy()
                Hh = np.full_like(P, np.nan); Hh[di, si] = df[f"{side}_hit{k}"].to_numpy()
                T = np.full_like(P, np.nan); T[di, si] = df[f"{side}_t{k}"].to_numpy()
                M = np.full_like(P, np.nan); M[di, si] = df[f"{side}_mae{k}"].to_numpy()
                EX = P - np.nanmean(P, axis=1, keepdims=True)
                ok = approve(P, None, isdesc, years)
                plc = []
                for _ in range(a.placebos):
                    Q = P.copy()
                    for r_ in range(Q.shape[0]):
                        m = np.isfinite(Q[r_]); Q[r_, m] = rng.permutation(Q[r_, m])
                    plc.append(int(approve(Q, None, isdesc, years).sum()))
                summ.append(dict(ativo=sym, tf=a.tf, lado=side.upper(), alvo_pts=k, horarios=len(slots), aprovados=int(ok.sum()),
                                 placebo_media=float(np.mean(plc)), placebo_p95=float(np.percentile(plc, 95)), placebo_max=int(max(plc)),
                                 media_todos_horarios=float(np.nanmean(P)), alcance_todos_pct=float(100 * np.nanmean(Hh))))
                for s in range(len(slots)):
                    x = P[:, s]; f = np.isfinite(x)
                    if f.sum() < 30:
                        continue
                    ys = pd.Series(x[f]).groupby(years[f]).mean()
                    rows.append(dict(ativo=sym, tf=a.tf, servidor=f"{slots[s] // 60:02d}:{slots[s] % 60:02d}",
                                     londres=f"{lmed[s] // 60:02d}:{lmed[s] % 60:02d}", lado=side.upper(), alvo_pts=k, dias=int(f.sum()),
                                     pct_alcance=100 * np.nanmean(Hh[:, s]), min_ate_alvo_med=np.nanmedian(T[:, s]),
                                     contra_antes_med=np.nanmedian(M[:, s]), contra_antes_p90=np.nanpercentile(M[:, s], 90) if np.isfinite(M[:, s]).any() else np.nan,
                                     media_pts=np.nanmean(x), mediana_pts=np.nanmedian(x), pct_dias_lucro=100 * np.nanmean(x[f] > 0),
                                     pior_pts=np.nanmin(x), excesso_vs_dia=np.nanmean(EX[:, s]),
                                     media_desc=np.nanmean(x[isdesc]), t_desc=tval(x[isdesc]), media_val=np.nanmean(x[~isdesc]), t_val=tval(x[~isdesc]),
                                     anos="; ".join(f"{y}:{v:+.0f}" for y, v in ys.items()), aprovado=bool(ok[s])))
        print(sym, a.tf, "ok", flush=True)
    pd.DataFrame(rows).to_csv(os.path.join(a.out, f"intraday_todos_horarios_{a.tf}.csv.gz"), index=False, float_format="%.2f")
    pd.DataFrame(summ).to_csv(os.path.join(a.out, f"intraday_resumo_placebo_{a.tf}.csv"), index=False, float_format="%.2f")


if __name__ == "__main__":
    main()
