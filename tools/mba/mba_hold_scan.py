#!/usr/bin/env python3
"""Varredura 'ESPERA O ALVO': abre no horário (abertura da vela M15) e fica aberto ATÉ BATER +k pontos líquidos, sem horário de saída,
sem stop. Janela de observação até 5 dias de pregão (92 velas M15/dia); horizonte principal = 1 dia (24 h). Mede por horário do servidor × lado × alvo:
  - % que bateu o alvo em 1, 5 e 20 dias de pregão (entradas sem 20 dias de seguimento ficam de fora);
  - tempo até o alvo (mediana, p90), em horas;
  - excursão CONTRA antes do alvo (mediana, p90, pior) = quanto fica no vermelho no caminho;
  - swap acumulado nas noites em que ficou aberta (pts por noite da especificação do símbolo; triplo na quarta; US30 na sexta);
  - resultado médio por operação a 1 dia: bateu o alvo -> k + swap; não bateu -> marca a mercado ao fim de 1 dia (spread de saída + swap).
Descoberta = 60% iniciais, validação = 40% finais; aprovado = média>0 nos dois, t>=2,5 / 1,65, todos os anos positivos;
placebo = horários embaralhados dentro de cada dia (50x). Excluídas as velas de 23:00 a 01:15 (rolagem).

  python tools/mba/mba_hold_scan.py --cache <m1cache> --specs symbol_specs.json --out <dir> --syms XAUUSD
"""
import argparse, json, math, os, sys
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mba_intraday_scan import tval, approve

sys.stdout.reconfigure(encoding="utf-8")
SYMS = ["XAUUSD", "XAGUSD", "US30", "DXY_Z6", "USDJPY", "EURJPY", "GBPJPY", "USDCHF", "AUDUSD", "NZDUSD_r"]
KS = {"XAUUSD": [300, 600, 1000, 2000], "XAGUSD": [300, 600, 1000], "US30": [1000, 3000, 5000, 10000], "DXY_Z6": [100, 200, 300]}
KS_FX = [100, 200, 300, 500]
BPD = 92                      # velas M15 por dia de pregão
HZ = {"1d": 1 * BPD, "5d": 5 * BPD}


def swap_info(specs, sym, pt):
    sp = json.load(open(specs)).get(sym, {})
    mode = int(float(sp.get("swap_mode", 0) or 0)); tv = float(sp.get("tick_value", 0) or 0); ts = float(sp.get("tick_size", pt) or pt)
    conv = 1.0 if mode == 1 else ((ts / pt) / tv if mode in (3, 4) and tv > 0 else 0.0)
    return {"buy": float(sp.get("swap_long", 0) or 0) * conv, "sell": float(sp.get("swap_short", 0) or 0) * conv}, (4 if sym == "US30" else 2)


def build(cache, specs, sym, ks):
    z = np.load(os.path.join(cache, f"{sym}_M15.npz"))
    t = z["t"]; o, h, l, c = z["o"], z["h"], z["l"], z["c"]; pt = float(z["point"])
    spr = z["spr"].astype(float); tok = z["tok"].astype(bool); n = len(t)
    s30 = (t % 1440) // 30
    if tok.sum() >= 500:
        prof = pd.Series(spr[tok]).groupby(s30[tok]).median().reindex(range(48)).fillna(np.nanmedian(spr[tok])).to_numpy()
        spr = np.where(tok & np.isfinite(spr), spr, prof[s30])
    spr = np.where(np.isfinite(spr), spr, np.nanmedian(spr))
    day = t // 1440; mod = t % 1440; wd = (day + 3) % 7
    sw, tri = swap_info(specs, sym, pt)
    d0 = int(day.min()); nd = int(day.max()) - d0 + 2
    dd = np.arange(nd) + d0; wdd = (dd + 3) % 7
    wgt = np.where(wdd < 5, np.where(wdd == tri, 3, 1), 0).astype(float)
    cum = np.concatenate([[0.0], np.cumsum(wgt)])                       # cum[x] = soma dos pesos dos dias d0..d0+x-1
    def nights(i, j):                                                     # noites com a posição aberta entre barras i e j
        return cum[np.clip(day[j] - d0, 0, nd)] - cum[np.clip(day[i] - d0, 0, nd)]
    NB = HZ["5d"]
    idx = np.nonzero((wd < 5) & (mod >= 75) & (mod <= 1365) & (np.arange(n) + NB < n))[0]
    K = np.array(ks, float); nk = len(K)
    out = {s: dict(w=np.full((len(idx), nk), -1, np.int64), mae=np.full((len(idx), nk), np.nan)) for s in ("buy", "sell")}
    mtm = {s: {hn: np.empty(len(idx)) for hn in HZ} for s in ("buy", "sell")}
    mfl = {s: {hn: np.empty(len(idx)) for hn in HZ} for s in ("buy", "sell")}
    for r, i in enumerate(idx):
        sl = slice(i, i + NB + 1)
        H_, L_, S_ = h[sl], l[sl], spr[sl]
        fb = np.maximum.accumulate((H_ - o[i]) / pt - spr[i]); ab = np.maximum.accumulate((o[i] - L_) / pt + spr[i])
        fs = np.maximum.accumulate((o[i] - L_) / pt - S_); as_ = np.maximum.accumulate((H_ - o[i]) / pt + S_)
        for s, f, a in (("buy", fb, ab), ("sell", fs, as_)):
            w = np.searchsorted(f, K)
            ok = w < len(f)
            out[s]["w"][r, ok] = w[ok]; out[s]["mae"][r, ok] = a[w[ok]]
            for hn, nb in HZ.items():
                mfl[s][hn][r] = a[nb]
                mtm[s][hn][r] = ((c[i + nb] - o[i]) / pt - spr[i]) if s == "buy" else ((o[i] - c[i + nb]) / pt - spr[i + nb])
    return dict(idx=idx, K=K, t=t, day=day, mod=mod, nights=nights, swap=sw, out=out, mtm=mtm, mfl=mfl, pt=pt)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", required=True); ap.add_argument("--specs", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--syms", nargs="*", default=SYMS); ap.add_argument("--placebos", type=int, default=50)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    rng = np.random.default_rng(9)
    rows, summ = [], []
    for sym in a.syms:
        ks = KS.get(sym, KS_FX)
        B = build(a.cache, a.specs, sym, ks)
        idx, t, day, mod = B["idx"], B["t"], B["day"], B["mod"]
        days = np.sort(np.unique(day[idx])); slots = np.sort(np.unique(mod[idx]))
        di = np.searchsorted(days, day[idx]); si = np.searchsorted(slots, mod[idx])
        isdesc = days < days[int(len(days) * 0.6)]
        years = days.astype("datetime64[D]").astype("datetime64[Y]").astype(int) + 1970
        ldn_off = 2 * 60                                                    # Londres = servidor - 2h (exceto 26-30/10)
        for s in ("buy", "sell"):
            for ki, k in enumerate(ks):
                w = B["out"][s]["w"][:, ki]; mae = B["out"][s]["mae"][:, ki]
                hit = w >= 0
                tex = np.where(hit, idx + np.maximum(w, 0), idx)
                th_min = np.where(hit, t[np.minimum(tex, len(t) - 1)] - t[idx], np.nan)
                swn = B["swap"][s]
                ev = {}
                for hn, nb in HZ.items():
                    hit_h = hit & (w <= nb)
                    exit_i = np.where(hit_h, tex, idx + nb)
                    pnl = np.where(hit_h, k, B["mtm"][s][hn]) + swn * B["nights"](idx, exit_i)
                    ev[hn] = (pnl, hit_h)
                P = {}
                for hn in HZ:
                    M = np.full((len(days), len(slots)), np.nan); M[di, si] = ev[hn][0]; P[hn] = M
                Hh = {hn: np.full((len(days), len(slots)), np.nan) for hn in HZ}
                for hn in HZ:
                    Hh[hn][di, si] = ev[hn][1]
                ok20 = approve(P["1d"], None, isdesc, years)
                plc = []
                for _ in range(a.placebos):
                    Q = P["1d"].copy()
                    for r_ in range(Q.shape[0]):
                        m = np.isfinite(Q[r_]); Q[r_, m] = rng.permutation(Q[r_, m])
                    plc.append(int(approve(Q, None, isdesc, years).sum()))
                summ.append(dict(ativo=sym, lado=s.upper(), alvo_pts=int(k), horarios=len(slots), aprovados=int(ok20.sum()),
                                 placebo_media=float(np.mean(plc)), placebo_p95=float(np.percentile(plc, 95)), placebo_max=int(max(plc)),
                                 pct_1d=float(100 * np.nanmean(Hh["1d"])), pct_5d=float(100 * np.nanmean(Hh["5d"])),
                                 horas_mediana=float(np.nanmedian(th_min) / 60), horas_p90=float(np.nanpercentile(th_min, 90) / 60),
                                 contra_med=float(np.nanmedian(mae)), contra_p90=float(np.nanpercentile(mae, 90)), contra_max=float(np.nanmax(mae)),
                                 pior_flutuante_1d=float(np.nanmax(B["mfl"][s]["1d"])), media_todos_1d=float(np.nanmean(P["1d"])),
                                 swap_pts_noite=swn))
                for q in range(len(slots)):
                    msk = si == q
                    if msk.sum() < 40:
                        continue
                    x = P["1d"][:, q]; f = np.isfinite(x)
                    ys = pd.Series(x[f]).groupby(years[f]).mean()
                    rows.append(dict(ativo=sym, servidor=f"{slots[q] // 60:02d}:{slots[q] % 60:02d}",
                                     londres=f"{((slots[q] - ldn_off) % 1440) // 60:02d}:{((slots[q] - ldn_off) % 1440) % 60:02d}",
                                     lado=s.upper(), alvo_pts=int(k), dias=int(f.sum()),
                                     pct_1d=100 * np.nanmean(Hh["1d"][:, q]), pct_5d=100 * np.nanmean(Hh["5d"][:, q]),
                                     horas_med=np.nanmedian(th_min[msk]) / 60, horas_p90=np.nanpercentile(th_min[msk], 90) / 60 if np.isfinite(th_min[msk]).any() else np.nan,
                                     contra_med=np.nanmedian(mae[msk]), contra_p90=np.nanpercentile(mae[msk], 90) if np.isfinite(mae[msk]).any() else np.nan,
                                     contra_max=np.nanmax(mae[msk]) if np.isfinite(mae[msk]).any() else np.nan,
                                     media_5d=np.nanmean(P["5d"][:, q]), media_1d=np.nanmean(x), mediana_1d=np.nanmedian(x),
                                     pior_1d=np.nanmin(x), t_desc=tval(x[isdesc]), t_val=tval(x[~isdesc]),
                                     media_desc=np.nanmean(x[isdesc]), media_val=np.nanmean(x[~isdesc]),
                                     anos="; ".join(f"{y}:{v:+.0f}" for y, v in ys.items()), aprovado=bool(ok20[q])))
        print(sym, "ok", flush=True)
    pd.DataFrame(rows).to_csv(os.path.join(a.out, "hold_todos_horarios.csv.gz"), index=False, float_format="%.2f")
    pd.DataFrame(summ).to_csv(os.path.join(a.out, "hold_resumo_placebo.csv"), index=False, float_format="%.2f")


if __name__ == "__main__":
    main()
