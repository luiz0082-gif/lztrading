#!/usr/bin/env python3
"""Builds the one-page-per-asset chart checklist from the mba_slots.py outputs."""
import glob, os, re, sys
import pandas as pd
import numpy as np

sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mba_report import md_table

D = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/mba/padroes"
OUT = sys.argv[2] if len(sys.argv) > 2 else "docs/relatorios/PADROES-HORARIOS-MBA-2026-10-17.md"
ORDER = ["XAUUSD", "USDJPY", "NZDUSD", "USDCHF", "AUDUSD", "US30", "DXY"]
L = []; P = L.append


def info_table(sym):
    t = open(os.path.join(D, f"{sym}.md"), encoding="utf-8").read().split("\n")
    rows = []
    for l in t:
        c = [x.strip() for x in l.strip().strip("|").split("|")]
        if len(c) == 8 and c[0] in ("M5", "M15", "M30", "H1"):
            rows.append(dict(tf=c[0], passaram=float(c[5].replace(",", "")), placebo_max=float(c[7].replace(",", "")), placebo_media=float(c[6])))
    return pd.DataFrame(rows)


P("# Padrões por horário (hora do servidor) — ficha para anotar e validar no gráfico\n")
P("**Como ler.** `entrada` = hora do servidor MT5 em que abre a vela de entrada; `londres` = servidor−2h; `ny` = servidor−7h. A operação dura `dur` minutos e sai no preço de lá. 1 operação por dia útil. "
  "`acerto` = % das vezes em que o preço terminou a favor (antes do custo). `lucro liq.` = % que fechou no lucro depois do spread. `≥100` e `≥300` = % que fechou com **lucro líquido** de pelo menos 100 / 300 pontos. "
  "`toca 300` = % que em algum momento chegou a +300 pontos a favor (mesmo devolvendo depois). Pontos são os do MT5 de cada ativo (XAUUSD: 300 pts = US$ 3,00; USDJPY: 300 pts = 0,300 ienes = 30 pips; EURs/AUD/NZD/CHF: 300 pts = 30 pips).\n")
P("**Critérios:** o padrão tem que ter sido positivo líquido e significativo na **descoberta** (primeiros 60% do tempo, t ≥ 2,0) e **de novo na validação** (últimos 40%, t ≥ 1,645), mesmo sinal. "
  "Mesmo assim, em ~900-2.900 horários testados por timeframe, alguns passam por acaso: a coluna `placebo` diz quantos o mesmo filtro aceita com o retorno embaralhado no tempo. **Padrão de um timeframe só é confiável se `passaram` > `placebo_max`.** Comissão e slippage não estão incluídos.\n")
P("**BTCUSD:** descartado a pedido (a mineração não achou nada).\n")
summary = []
for sym in ORDER:
    fp = os.path.join(D, f"{sym}_padroes.csv")
    it = info_table(sym) if os.path.exists(os.path.join(D, f"{sym}.md")) else pd.DataFrame()
    P(f"\n---\n\n## {sym}\n")
    if len(it):
        it["confiavel"] = np.where(it["passaram"] > it["placebo_max"], "SIM", "nao distinguivel do acaso")
        P("Teste de confiabilidade por timeframe:\n")
        P(md_table(it.rename(columns={"passaram": "padroes_que_passaram", "placebo_media": "placebo_media", "placebo_max": "placebo_max"}), 1))
    if not os.path.exists(fp):
        P("**Nenhum padrão de horário passou nos critérios.** Não há horário fixo para marcar neste ativo.\n")
        summary.append((sym, "nenhum", ""))
        continue
    d = pd.read_csv(fp)
    d = d.merge(it[["tf", "confiavel"]], on="tf", how="left") if len(it) else d
    d["londres"] = d["entrada_servidor"].map(lambda s: f"{(int(s[:2]) - 2) % 24:02d}:{s[3:]}")
    d["ny"] = d["entrada_servidor"].map(lambda s: f"{(int(s[:2]) - 7) % 24:02d}:{s[3:]}")
    d["_ok"] = (d["confiavel"] == "SIM").astype(int)
    d = d.sort_values(["_ok", "t_val"], ascending=[False, False])
    ficha = d.rename(columns={"entrada_servidor": "entrada", "dur_min": "dur", "pct_acerto_bruto": "acerto%", "pct_liquido_pos": "lucro_liq%", "pct_liq_ge_100": "≥100pts%",
                              "pct_liq_ge_300": "≥300pts%", "pct_toca_300": "toca_300%", "media_liq_pts": "media_pts", "mediana_liq_pts": "mediana_pts", "custo_medio_pts": "custo_pts"})
    P("\n**Fichas (marque no gráfico):**\n")
    P(md_table(ficha[["lado", "entrada", "londres", "ny", "dur", "tf", "n", "acerto%", "lucro_liq%", "≥100pts%", "≥300pts%", "toca_300%", "media_pts", "mediana_pts", "custo_pts", "anos_pos", "meses_pos", "confiavel"]], 1))
    P("\n**Estabilidade e dias da semana:**\n")
    P(md_table(d[["lado", "entrada_servidor", "dur_min", "tf", "primeiro", "ultimo", "t_desc", "t_val", "liq_desc", "liq_val", "por_ano", "dias_acerto"]], 2))
    # last occurrences to check on the chart
    P("\n**Últimas 12 ocorrências de cada ficha (hora do servidor → resultado líquido em pontos):**\n")
    for _, x in d.iterrows():
        fo = os.path.join(D, f"{sym}_ocorrencias_{x['tf']}.csv")
        if not os.path.exists(fo): continue
        o = pd.read_csv(fo)
        o = o[(o["entrada_servidor"] == x["entrada_servidor"]) & (o["lado"] == x["lado"]) & (o["dur_min"] == x["dur_min"])].sort_values("data_hora_servidor").tail(12)
        P(f"- {x['lado']} {x['entrada_servidor']} ({x['dur_min']} min, {x['tf']}): " + "; ".join(f"{a[5:16]} {v:+.0f}" for a, v in zip(o["data_hora_servidor"], o["liquido_pts"])))
    summary.append((sym, f"{len(d)} janela(s)", ", ".join(f"{r.lado} {r.entrada_servidor} {r.dur_min}min" for r in d.itertuples())))
P("\n---\n\n## Resumo rápido\n")
P(md_table(pd.DataFrame(summary, columns=["ativo", "janelas", "quais"]), 1))
P("**Leitura honesta:** só o XAUUSD tem padrões de horário com ganho na escala de centenas de pontos por operação (e que passam no teste contra o acaso). Nos pares de moeda os ganhos médios são de poucos pontos "
  "(USDJPY: 5 a 24 pts; NZDUSD: 8 pts; USDCHF: 7 a 10 pts), então **+300 pontos de lucro líquido quase nunca ocorre** (0 a 3% das vezes); servem como curiosidade para conferir no gráfico, e vários não se distinguem do acaso (veja a coluna `confiavel`). "
  "AUDUSD, US30 e DXY não têm nenhum horário fixo que passe nos critérios. Padrões que dependem de uma condição além do horário (por exemplo, US30 vende às 23:00 UTC depois de vela de alta) estão nos relatórios por ativo, não aqui.\n")
open(OUT, "w", encoding="utf-8").write("\n".join(L))
print("OK", OUT)
