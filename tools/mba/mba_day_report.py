#!/usr/bin/env python3
"""Builds the intraday (target or 23:30) document for the non-gold pairs from tools/mba/mba_day.py outputs."""
import os, re, sys
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mba_report import md_table

D = os.environ.get("MBA_DIR", "docs/relatorios/mba/padroes_dia")
TAG = os.environ.get("MBA_TAG", "")
OUT = os.environ.get("MBA_OUT", "docs/relatorios/PADROES-INTRADAY-PARES-ATE-2330-MBA-2026-10-17.md")
ORDER = os.environ.get("MBA_ORDER", "USDJPY,NZDUSD,USDCHF,AUDUSD,US30,DXY").split(",")
NL = "\n"
L = []
P = L.append

P("# Padrões intraday — entrada no horário, saída no alvo ou às 23:30 do servidor, sem stop" + NL)
P("**Regra:** entra na abertura da vela M15 do horário (hora do servidor), fecha quando o preço faz o alvo a favor ou às **23:30** do servidor (fechamento da vela 23:15). Sem stop; 1 operação por dia útil. "
  "**Os alvos são proporcionais à volatilidade de cada par** (25%, 50%, 100% e 200% do ATR M15, mais 300 pontos); o `ATR M15` e os alvos testados estão no topo de cada ativo. 300 pts em FX = 30 pips. "
  "Londres = servidor−2h; NY = servidor−7h. Custo = spread medido nos ticks; comissão e slippage não incluídos." + NL)
P("## Como ler" + NL)
P("- `pct_alvo` = % dos dias em que o alvo foi atingido; `pct_base_val` = % que **qualquer** horário atinge no mesmo período (para ver quanto a condição melhora). "
  "`perda_media_sem_alvo` = resultado médio dos dias em que o alvo NÃO foi atingido (medido em todos os horários); `pct_necessario_p_empatar` = % de acerto necessário para empatar com essa perda; "
  "`ev_estresse_pts` = expectativa por operação usando o limite inferior 95% da taxa de acerto; `media_real_pts` = média efetivamente obtida; `pior_dia_pts` e `mae_medio/p90` = o risco sem stop (quanto o preço anda contra você).")
P("- Cada condição é comparada com o resto **do mesmo mês** (remove tendência e regime) e é testada contra um placebo (resultados deslocados no tempo).")
P("- `ambos os lados` = a mesma condição também funciona na direção oposta: é uma condição de **volatilidade** (dia que anda muito), não de direção. Famílias com `month=` ou `dom_w=` foram removidas da lista (poucas amostras por mês, 2 a 3 anos).")
P("- `melhores_horas` = horas do servidor (entrada em qualquer vela M15 dentro da hora) em que a condição, além de valer, tem taxa de acerto acima da média do próprio padrão e resultado médio positivo (n ≥ 25 por hora); `dias_por_ano` = quantos dias do ano a condição aparece; `entradas_por_dia` = quantas velas M15 do mesmo dia a satisfazem (cada vela é uma entrada separada nos números). Para operar, escolha UMA entrada por dia dentro de `melhores_horas`.")
P("- Filtros da lista B: pelo menos 60 dias distintos com o sinal (as entradas do mesmo dia não são independentes), n ≥ 250, taxa de acerto na validação ≥ 8 pontos percentuais acima da base, positivo em todos os anos, média real > 0 e duas metades da validação positivas." + NL)

summary = []
for s in ORDER:
    P(NL + "---" + NL + NL + f"## {s}" + NL)
    md = open(os.path.join(D, f"{s}{TAG}.md"), encoding="utf-8").read()
    ma = re.search(r"ATR M15 mediano = [^\n]+", md)
    if ma:
        P(ma.group(0) + NL)
    mm = re.search(r"Padrões que passaram: \*\*(\d+)\*\*; placebo: média ([\d.]+), máximo (\d+)\. ([^\n]+)", md)
    clock_ok = False
    if mm:
        P(f"**Horários puros que passaram:** {mm.group(1)} (placebo: média {mm.group(2)}, máx {mm.group(3)}). {mm.group(4)}" + NL)
        clock_ok = int(mm.group(1)) > int(mm.group(3))
    mc = re.search(r"Hipóteses testadas: \*\*([\d,]+)\*\*; passaram no BH na descoberta: \*\*([\d,]+)\*\*; confirmadas na validação: \*\*([\d,]+)\*\*; placebo: BH média ([\d.]+) \(máx (\d+)\), confirmadas média ([\d.]+) \(máx (\d+)\)", md)
    if mc:
        P(f"**Horário + condição:** {mc.group(1)} hipóteses; confirmadas na validação **{mc.group(3)}**; placebo: confirmadas média {mc.group(6)}, máximo {mc.group(7)}." + NL)
    fh = os.path.join(D, f"{s}{TAG}_horarios.csv")
    P("### A. Horários puros" + NL)
    if os.path.exists(fh):
        h = pd.read_csv(fh).sort_values("ev_estresse_pts", ascending=False)
        if not clock_ok:
            P("_Não se distingue do acaso; listado só para conferência._" + NL)
        cols = ["lado", "alvo_pts", "janela_entrada", "londres", "n", "pct_alvo", "pct_alvo_min95", "ganho_dia_alvo", "perda_media_sem_alvo", "pct_necessario_p_empatar", "ev_estresse_pts", "media_real_pts", "pior_dia_pts", "mae_medio_pts", "mae_p90_pts", "min_ate_alvo", "anos_pos", "meses_pos", "variantes"]
        P(md_table(h[cols].head(15), 1))
        P(NL + md_table(h[["lado", "alvo_pts", "janela_entrada", "por_ano", "dias_semana"]].head(15), 1))
        fo = os.path.join(D, f"{s}{TAG}_ocorrencias_horarios.csv")
        if os.path.exists(fo):
            o = pd.read_csv(fo)
            P(NL + "**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**" + NL)
            for _, x in h.head(6).iterrows():
                e = o[(o["entrada"] == x["entrada"]) & (o["lado"] == x["lado"]) & (o["alvo_pts"] == x["alvo_pts"])].tail(8)
                P(f"- {x['lado']} {x['entrada']} alvo {x['alvo_pts']}: " + "; ".join(f"{d[5:]} {v:+.0f}{'*' if b else ''}" for d, v, b in zip(e["data_servidor"], e["resultado_liquido_pts"], e["bateu_alvo"])))
        summary.append((s, "horários puros", f"{mm.group(1)} (placebo máx {mm.group(3)})" if mm else ""))
    else:
        P("**Nenhum horário puro passou nos critérios.**" + NL)
        summary.append((s, "horários puros", "0"))
    fc = os.path.join(D, f"{s}{TAG}_condicionais.csv")
    P(NL + "### B. Horário + condição" + NL)
    if os.path.exists(fc):
        c0 = pd.read_csv(fc)
        c0 = c0[c0["cat"] == "demais"].copy()
        keys = c0.groupby(["condicao", "alvo_pts"])["lado"].nunique()
        c0["ambos"] = [("ambos os lados" if keys.get((x, y), 1) > 1 else "direcional") for x, y in zip(c0["condicao"], c0["alvo_pts"])]
        yrs_ok = c0["anos_pos"].map(lambda v: v.split("/")[0] == v.split("/")[1])
        c = c0[~c0["condicao"].str.contains("month=|dom_w=") & (c0["n"] >= 250) & (c0["dias_com_sinal"] >= 60) & ((c0["pct_alvo_val"] - c0["pct_base_val"]) >= 8) & yrs_ok & (c0["media_real_pts"] > 0)].copy()
        c = c.sort_values(["passou_BH", "ev_estresse_pts"], ascending=[False, False])
        P(f"Famílias que passam nos filtros: **{len(c)}**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada)." + NL)
        if len(c):
            cols = ["lado", "alvo_pts", "condicao", "melhores_horas", "dias_com_sinal", "dias_por_ano", "entradas_por_dia", "ambos", "n", "pct_alvo", "pct_alvo_val", "pct_base_val", "perda_media_sem_alvo", "pct_necessario_p_empatar", "ev_estresse_pts", "media_real_pts", "pior_dia_pts", "mae_medio_pts", "mae_p90_pts", "min_ate_alvo", "passou_BH", "anos_pos", "meses_pos", "formas"]
            P(md_table(c[cols].head(15), 1))
            P(NL + "**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**" + NL)
            P(md_table(c[["lado", "alvo_pts", "condicao", "horas_entrada"]].head(15), 1))
            P(NL + md_table(c[["lado", "alvo_pts", "condicao", "primeiro", "ultimo", "por_ano", "dias_semana"]].head(15), 1))
        summary.append((s, "horário + condição", f"{len(c)} famílias nos filtros"))
    else:
        P("_Nenhuma família._" + NL)
        summary.append((s, "horário + condição", "0"))

P(NL + "---" + NL + NL + "## Resumo" + NL)
P(md_table(pd.DataFrame(summary, columns=["ativo", "tipo", "resultado"]), 1))
P("## Limites" + NL)
P("- Caminho do preço medido em candles M15. Período 2024-01 a 2026-10 (708 dias); validação = últimos 40%. "
  "- A perda dos dias sem alvo usa o fechamento das 23:30; carregar a posição para o dia seguinte não está incluído. "
  "- Comissão, slippage e swap não incluídos. "
  "- Condições de volatilidade (`ambos os lados`) não dizem a direção: dependem de você escolher o lado, e o risco sem stop está nas colunas de perda." + NL)
open(OUT, "w", encoding="utf-8").write(NL.join(L))
print("OK", OUT)
