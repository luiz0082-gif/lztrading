"""Saida por 'estagnacao no lucro': se o liquido ficar numa faixa positiva (ex.: +0,40 a +0,90) por N s, fecha.

Opcionalmente so quando ha >= K posicoes abertas (do EA, mesma plataforma) naquele instante.
Usa o caminho real de cada trade (positions.csv). O liquido de positions.csv inclui so a comissao de entrada;
na saida soma-se a outra metade (comissao_total/2). Compara com o resultado real do trade.

Uso: python tools/micromomentum/stall_exit_sim.py
"""
import numpy as np
import pandas as pd

import analyze as a

S = ("C:/Users/luiz_/AppData/Local/Temp/claude/C--Users-luiz--OneDrive--rea-de-Trabalho-Luiz-EA---INDICADOR-"
     "EA-MT5-lztrading/2f150bae-5eb7-4604-9d20-40be44752205/scratchpad/")
t = pd.read_pickle(S + "t2.pkl")
p = a.load("positions", usecols=["t_server", "ticket", "hold_ms", "net"])
for c in ["ticket", "hold_ms", "net"]:
    p[c] = pd.to_numeric(p[c])
p["s"] = a.ts(p.t_server).dt.floor("s")
p = p.sort_values(["plat", "ticket", "hold_ms"])

# concorrencia por plataforma e segundo (posicoes distintas com registro naquele segundo)
conc = p.groupby(["plat", "s"]).ticket.nunique().rename("conc")
p = p.join(conc, on=["plat", "s"])

paths = {k: (g.hold_ms.values, g.net.values, g.conc.values) for k, g in p.groupby(["plat", "ticket"])}
t = t.set_index(["plat", "ticket"])


def run(lo, hi, win_ms, kmin):
    n = 0
    real = sim = 0.0
    lost_tp = 0
    for k, r in t.iterrows():
        if k not in paths:
            continue
        h, nt, cc = paths[k]
        trig = None
        j0 = 0
        for i in range(len(h)):
            if not (lo <= nt[i] <= hi):
                j0 = i + 1
                continue
            if j0 <= i and h[i] - h[j0] >= win_ms - 500 and cc[i] >= kmin:
                trig = i
                break
        if trig is None:
            continue
        n += 1
        real += r.net
        sim += nt[trig] + r.commission / 2.0
        if str(r.exit_reason).startswith("TP"):
            lost_tp += 1
    return dict(faixa=f"{lo:.2f}-{hi:.2f}", estagna_s=win_ms / 1000, min_abertas=kmin, n=n, net_real=round(real, 2),
                net_sim=round(sim, 2), delta=round(sim - real, 2), eram_TP=lost_tp)


rows = []
for lo, hi in [(0.40, 0.80), (0.50, 0.90), (0.30, 0.70)]:
    for win in [5000, 10000]:
        for k in [1, 3, 4]:
            rows.append(run(lo, hi, win, k))
pd.set_option("display.width", 250, "display.max_rows", 100)
print(pd.DataFrame(rows).to_string(index=False))
