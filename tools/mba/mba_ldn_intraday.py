#!/usr/bin/env python3
"""Intraday por horário de LONDRES: entrada na abertura da barra cuja hora de Londres = HH:MM, saída às 23:30 do servidor
(30 min antes do fechamento; o dia do servidor abre às 01:00). Mede, para BUY e SELL executáveis (barras de bid; compra no ask,
venda recompra no ask da barra), se o preço alcança +k pontos líquidos ANTES das 23:30, quanto andou contra antes, quanto tempo
levou e o resultado se ficar até 23:30. Compara o horário pedido com todos os horários de Londres de 07:00 a 14:00 (de 5 em 5 min),
nos mesmos dias. Descoberta = 60% iniciais dos dias, validação = 40% finais.

  python tools/mba/mba_ldn_intraday.py --cache <m1cache> --out docs/relatorios/mba/ldn1025 --tf M5
"""
import argparse, math, os, sys
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
SYMS = ["XAUUSD", "XAGUSD", "US30", "DXY_Z6", "USDJPY", "EURJPY", "GBPJPY", "USDCHF", "AUDUSD", "NZDUSD_r"]
EXIT_SRV = 23 * 60 + 30


def run(cache, sym, tf, ks):
    z = np.load(os.path.join(cache, f"{sym}_{tf}.npz"))
    t, ldn = z["t"], z["ldn"]; o, h, l, c = z["o"], z["h"], z["l"], z["c"]; pt = float(z["point"])
    spr = z["spr"].astype(float); tok = z["tok"].astype(bool)
    slot = (t % 1440) // 30
    if tok.sum() >= 500:                                  # perfil de spread por faixa de 30 min (ticks) onde não há tick
        prof = pd.Series(spr[tok]).groupby(slot[tok]).median().reindex(range(48))
        prof = prof.fillna(np.nanmedian(spr[tok])).to_numpy()
        spr = np.where(tok & np.isfinite(spr), spr, prof[slot])
    spr = np.where(np.isfinite(spr), spr, np.nanmedian(spr))
    day = t // 1440; mod = t % 1440; lmod = ldn % 1440; wd = (day + 3) % 7
    rows = []
    starts = np.nonzero((wd < 5) & (lmod >= 7 * 60) & (lmod <= 14 * 60) & (lmod % 5 == 0) & (mod < EXIT_SRV - 30))[0]
    # índice do fim do dia (última barra com hora do servidor < 23:30 no mesmo dia)
    d_end = {}
    ok = mod < EXIT_SRV
    for d_, i in zip(day[ok], np.nonzero(ok)[0]):
        d_end[d_] = i
    for i in starts:
        j = d_end.get(day[i])
        if j is None or j <= i or mod[j] < EXIT_SRV - 3 * 60:      # dia sem dados até perto das 23:30 → fora
            continue
        H, L, S = h[i:j + 1], l[i:j + 1], spr[i:j + 1]
        upb = np.maximum.accumulate((H - o[i]) / pt - spr[i])          # BUY: sai no bid
        dnb = np.maximum.accumulate((o[i] - L) / pt + spr[i])          # BUY: contra
        ups = np.maximum.accumulate((o[i] - L) / pt - S)               # SELL: recompra no ask
        dns = np.maximum.accumulate((H - o[i]) / pt + S)               # SELL: contra
        end_b = (c[j] - o[i]) / pt - spr[i]; end_s = (o[i] - c[j]) / pt - spr[j]
        r = dict(day=int(day[i]), ldn=f"{lmod[i] // 60:02d}:{lmod[i] % 60:02d}", srv=f"{mod[i] // 60:02d}:{mod[i] % 60:02d}",
                 end_buy=end_b, end_sell=end_s, mfe_buy=upb[-1], mfe_sell=ups[-1], mae_buy=dnb[-1], mae_sell=dns[-1], spr=spr[i])
        for k in ks:
            for side, fav, adv in (("buy", upb, dnb), ("sell", ups, dns)):
                w = np.nonzero(fav >= k)[0]
                if len(w):
                    r[f"{side}_hit{k}"] = 1; r[f"{side}_t{k}"] = int(t[i + w[0]] - t[i]); r[f"{side}_mae{k}"] = float(adv[w[0]])
                    r[f"{side}_pl{k}"] = float(k)
                else:
                    r[f"{side}_hit{k}"] = 0; r[f"{side}_t{k}"] = np.nan; r[f"{side}_mae{k}"] = np.nan
                    r[f"{side}_pl{k}"] = end_b if side == "buy" else end_s
        rows.append(r)
    return pd.DataFrame(rows), pt


def tstat(x):
    x = np.asarray(x, float); x = x[np.isfinite(x)]
    return x.mean() / (x.std(ddof=1) / math.sqrt(len(x))) if len(x) > 2 and x.std() > 0 else np.nan


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", required=True); ap.add_argument("--out", required=True); ap.add_argument("--tf", default="M5")
    ap.add_argument("--hhmm", default="10:25"); ap.add_argument("--syms", nargs="*", default=SYMS)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    allrows, detail = [], []
    for sym in a.syms:
        if not os.path.exists(os.path.join(a.cache, f"{sym}_{a.tf}.npz")):
            continue
        ks = [500, 1000, 2000, 3000, 5000] if sym == "US30" else [100, 200, 300, 500]
        df, pt = run(a.cache, sym, a.tf, ks)
        days = np.sort(df["day"].unique()); cut = days[int(len(days) * 0.6)]
        df["periodo"] = np.where(df["day"] < cut, "desc", "val")
        df["ano"] = (df["day"].to_numpy().astype("datetime64[D]").astype("datetime64[Y]").astype(int) + 1970)
        for (lh), g in df.groupby("ldn"):
            for side in ("buy", "sell"):
                for k in ks:
                    pl = g[f"{side}_pl{k}"]
                    allrows.append(dict(ativo=sym, tf=a.tf, londres=lh, servidor_tipico=g["srv"].mode().iat[0], lado=side.upper(), alvo_pts=k,
                                        dias=len(g), alcancou=int(g[f"{side}_hit{k}"].sum()), pct_alcance=100 * g[f"{side}_hit{k}"].mean(),
                                        pct_desc=100 * g.loc[g.periodo == "desc", f"{side}_hit{k}"].mean(),
                                        pct_val=100 * g.loc[g.periodo == "val", f"{side}_hit{k}"].mean(),
                                        min_ate_alvo_med=g[f"{side}_t{k}"].median(), contra_antes_med=g[f"{side}_mae{k}"].median(),
                                        contra_antes_p90=g[f"{side}_mae{k}"].quantile(0.9),
                                        media_pts=pl.mean(), media_desc=pl[g.periodo == "desc"].mean(), media_val=pl[g.periodo == "val"].mean(),
                                        t_desc=tstat(pl[g.periodo == "desc"]), t_val=tstat(pl[g.periodo == "val"]),
                                        pior_pts=pl.min(), pct_dias_lucro=100 * (pl > 0).mean(),
                                        por_ano="; ".join(f"{y}: {100 * gg[f'{side}_hit{k}'].mean():.0f}% / {gg[f'{side}_pl{k}'].mean():+.0f}" for y, gg in g.groupby("ano"))))
        sel = df[df["ldn"] == a.hhmm].copy(); sel["ativo"] = sym
        detail.append(sel)
        print(sym, a.tf, "dias", len(sel), flush=True)
    R = pd.DataFrame(allrows)
    R.to_csv(os.path.join(a.out, f"ldn_intraday_todos_horarios_{a.tf}.csv"), index=False, float_format="%.2f")
    pd.concat(detail).to_csv(os.path.join(a.out, f"ldn_{a.hhmm.replace(':', '')}_dia_a_dia_{a.tf}.csv"), index=False, float_format="%.2f")


if __name__ == "__main__":
    main()
