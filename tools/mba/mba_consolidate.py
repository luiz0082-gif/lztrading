#!/usr/bin/env python3
"""Consolidates the per-symbol MBA reports (tools/mba/mba_report.py output) into one comparative document."""
import glob, os, re, sys
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mba_report import md_table

ROOT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/mba/ativos"
OUT = sys.argv[2] if len(sys.argv) > 2 else "docs/relatorios/RELATORIO-MBA-8-PARES-2026-10-16.md"
syms = sorted(d for d in os.listdir(ROOT) if os.path.isdir(os.path.join(ROOT, d)) and os.path.exists(os.path.join(ROOT, d, f"{d}.md")))
L = []; P = L.append


def readall(s, base):
    out = []
    for suf in ("", "_open"):
        fp = os.path.join(ROOT, s, f"{base}{suf}.csv")
        if os.path.exists(fp):
            out.append(pd.read_csv(fp))
    return pd.concat(out, ignore_index=True) if out else pd.DataFrame()


def categoria(r):
    t = str(r["condicao"])
    if "SUNDAY" in t or "gap=Y" in t:
        return "1 abertura de semana (domingo/gap)"
    if r["modo"] == "hit" and (r["n_val"] < 150 or r["pct_pos_B"] >= 97):
        return "2 hit sem perdedores observados / amostra pequena (cauda invisivel)"
    if "FRIDAY" in t:
        return "3 sexta (proximo ao fechamento semanal)"
    return "4 demais"


P("# MBA — varredura completa dos 8 pares (comparativo)\n")
P(f"Ativos: {', '.join(syms)}. Cada ativo tem seu relatório detalhado em `docs/relatorios/mba/ativos/<ATIVO>/<ATIVO>.md` (modos `ret` e `hit`) e `<ATIVO>_open.md` (modo `open`), com os CSV de apoio na mesma pasta.\n")
P("""## 0. Leia primeiro (conclusões desta rodada, escritas após ler os resultados)

**Escopo:** XAUUSD (IC), AUDUSD, BTCUSD, NZDUSD, US30, USDCHF, USDJPY e DXY (os 8 que sobraram; o XAUUSD da FP ficou fora a pedido). Três modos de mineração (`ret`, `hit` e `open`), 4 timeframes (M5-H1), 53-70 variáveis em pares, 6 horizontes ou séries por variável, descoberta/validação cronológicas, BH, placebo, custo por spread medido nos ticks com perfil de domingo, vantagem exigida contra a média de todas as velas e sensibilidade a comissão.

**1. O custo decide quase tudo.** Spread dos ticks dividido pelo ATR M5: XAUUSD 0,02; US30 0,04; USDJPY 0,07; BTCUSD 0,11; USDCHF 0,22; NZDUSD 0,26; AUDUSD 0,63; DXY 1,19. AUDUSD (FP) e DXY têm spread de mesma ordem que o movimento de 5 minutos: nada para operar no curto prazo, e foi isso que a mineração mostrou (AUDUSD: 5 candidatas, todas de abertura de domingo; DXY: 0).

**2. O spread gravado na barra engana.** Nas contas ECN o campo é 0 em 87% das barras do USDJPY e 41% do USDCHF, e fica abaixo do spread real nos demais. Uma primeira versão deste relatório usava esse campo e produziu candidatas falsas (principalmente vendas na rolagem). O custo foi refeito com o spread medido nos ticks (mediana por slot de 30 min do relógio de Nova York, domingo à parte).

**3. Há muita estrutura de relógio, mas a maior parte está na rolagem diária e na abertura de domingo.** Pares de FX têm retornos médios altamente significativos nas velas de 20-23 UTC (por exemplo H1 das 22 UTC: AUDUSD +0,15 ATR t=13,5; NZDUSD +0,19 t=13,5; USDCHF +0,27 t=21,7) e no domingo. Isso é o preço de Bid se movendo com o spread alargado/normalizando; comprar a esse preço custa o spread do momento. Por isso milhares de células "confirmadas" no bruto viram poucas famílias com líquido positivo, e as que sobram nessa faixa merecem desconfiança extra.

**4. O método funciona onde há sinal.** Como teste de controle, o modo `open` reencontrou **de forma independente** o seu padrão do ouro: vender a abertura do candle M5 das 09:25 UTC (10:25 de Londres no verão), com cerca de +152 pontos líquidos por operação na validação, positivo nos dois anos e em 15 de 18 meses (veja `XAUUSD_open.md`). Ele aparece como exploratório (não passa no BH porque a amostra do M5 são só 17 meses e o corte de múltiplos testes é severo), não como "reprovado".

**5. Candidatas mais limpas (categoria 4, vantagem contra a média, BH, duas metades positivas, líquido positivo), por ativo** (detalhe na seção 5):
- **XAUUSD:** 6, todas **compra** (o ouro subiu muito no período; a vantagem sobre a média das velas é moderada, t entre 1,7 e 2,8), com +50 a +150 pontos líquidos por operação; sobrevivem a uma comissão de US$ 7/lote (7 pontos). Mais a venda das 09:25 UTC como exploratória.
- **USDJPY:** 29 depois de comissão hipotética de US$ 7 (11 pontos). A mais robusta: venda após vela baixista das 23:00 UTC (H1, 5 min), +6,6 pontos após comissão, 6 de 6 anos; a compra das 09:30 UTC (M15) fica em +1,4 após comissão, marginal. Efeitos de sessão Asia (+6 pontos por 15 min) morrem na comissão.
- **USDCHF e NZDUSD:** compras às 21-22 UTC (rolagem) e vendas às 20 UTC; ficam positivas após comissão só por 2 a 15 pontos e estão na zona suspeita de artefato do Bid.
- **US30:** venda das 23:00 UTC por 5 min (H1), +217 a +408 pontos (2 a 4 pontos do índice) por operação, 6 de 6 anos, sem comissão. Execução às 23:00 UTC (19:00 NY, fora do horário cash) é incerta.
- **BTCUSD:** nenhuma (a única candidata é `hit` sem perdedores observados). **AUDUSD:** só abertura de domingo. **DXY:** nenhuma.

**6. Sobre sem stop:** o modo `hit` assume o seu perfil. Alvos pequenos sem stop acertam quase sempre, e a amostra de 2 a 5 anos quase não contém a perda rara e grande; por isso as candidatas `hit` com poucos perdedores ficam na categoria 2, fora da lista limpa.

**7. Dados e ferramentas.** O M1 dos candles ficou incompleto por um bug do EA (`InpMaxCatchupBars` pulava o histórico; corrigido na v1.23.1, mas é preciso reiniciar e reconstruir o M1). Esta rodada usou eventos M5/M15/M30/H1 e mediu o futuro nas barras M1 que o terminal já tem; **eventos M1 não foram minerados**. Todos os resultados são retrospectivos; nada foi testado com execução real ou em dados novos.

""")
P("## 1. Como ler\n")
P("- **Descoberta/validação:** primeiros 60% do tempo para procurar, últimos 40% (com 1 dia de intervalo) para confirmar. O corte é cronológico.\n"
  "- **BH:** correção de múltiplos testes (Benjamini-Hochberg, q=5%) sobre todas as células testadas na descoberta.\n"
  "- **Placebo:** o mesmo procedimento com o retorno deslocado aleatoriamente no tempo (6x por timeframe). O que o placebo também produz é acaso.\n"
  "- **Custo realista (v3):** o spread gravado na barra é zero em grande parte das barras de contas ECN e fica abaixo do spread real; por isso o custo é `max(spread da barra, mediana do spread medido nos ticks no mesmo slot de 30 min do relógio de Nova York)`, com perfil próprio para domingo. Compra paga o spread na entrada; venda paga na saída (no modo `hit`, no instante em que o alvo é atingido).\n"
  "- **Modo `ret`:** entra no FECHAMENTO do candle-evento; retorno bruto em horizonte fixo (5-240 min). **Modo `hit`:** idem, com alvo de 0,5/1/2 ATR **sem stop** e saída por tempo (15/60/240 min). **Modo `open`:** entra na ABERTURA do candle-evento e mede o próprio candle e o que vem depois; só usa variáveis conhecidas antes da abertura (é o formato do padrão das 10:25 de Londres no ouro).\n"
  "- **Família:** conjunto de condições que seleciona exatamente as mesmas velas é contado uma vez (`n_formas_equivalentes`).\n"
  "- **Candidata:** família com BH na descoberta, mesmo sinal na validação, líquido positivo e t>1,645 na validação com custo realista, **diferença significativa (t>1,645) contra o resultado médio de todas as velas** (elimina deriva/tendência do ativo) e líquido positivo nas duas metades da validação.\n"
  "- **Categorias das candidatas:** (1) abertura de semana, onde a execução real é a menos confiável; (2) `hit` sem perdedores observados, em que o risco de cauda sem stop não aparece na amostra; (3) sexta, perto do fechamento semanal; (4) demais.\n")

# ------------------------------------------------------------------ coverage and cost
rows = []
for s in syms:
    cov = pd.read_csv(os.path.join(ROOT, s, "cobertura.csv"))
    pp = os.path.join(ROOT, s, "perfil_hora_utc.csv")
    prof = pd.read_csv(pp) if os.path.exists(pp) else None
    r = dict(ativo=s)
    for tf in ("M5", "H1", "D1"):
        x = cov[cov["TF"] == tf]
        if len(x):
            r[f"{tf}_candles"] = int(x["candles"].iloc[0]); r[f"{tf}_inicio"] = x["inicio"].iloc[0][:10]
    if prof is not None and len(prof):
        w = prof["n"]
        col = "spread_ticks_med" if "spread_ticks_med" in prof and prof["spread_ticks_med"].notna().any() else "spread_med"
        r["spread_ticks_pts"] = float(np.average(prof[col].fillna(prof["spread_med"]), weights=w)); r["ATR_M5_pts"] = float(np.average(prof["atr_med_pts"], weights=w))
        r["spread/ATR"] = r["spread_ticks_pts"] / r["ATR_M5_pts"] if r["ATR_M5_pts"] else np.nan
        if "pct_barras_spread0" in prof: r["%barras_spread=0"] = float(np.average(prof["pct_barras_spread0"], weights=w))
        r["pior_hora_utc"] = int(prof.loc[prof["custo_sobre_ATR"].idxmax(), "hora_utc"]); r["pior_spread/ATR"] = float(prof["custo_sobre_ATR"].max())
        r["melhor_hora_utc"] = int(prof.loc[prof["custo_sobre_ATR"].idxmin(), "hora_utc"]); r["melhor_spread/ATR"] = float(prof["custo_sobre_ATR"].min())
    rows.append(r)
cc = pd.DataFrame(rows)
P("## 2. Cobertura e custo por ativo\n")
P(md_table(cc, 2))
P("`spread/ATR` perto de 0,1 é operável em prazos de minutos; acima de ~0,3 o custo come o movimento típico. `%barras_spread=0` mostra o quanto o campo gravado na barra é inútil para custo.\n")

# ------------------------------------------------------------------ mining summary
rs = []
for s in syms:
    d = readall(s, "resumo_mineracao")
    if len(d): d.insert(0, "ativo", s); rs.append(d)
R = pd.concat(rs, ignore_index=True)
P("## 3. Mineração: quanto passa além do placebo\n")
P("`confirmadas` = células que passaram no BH na descoberta e repetiram o sinal na validação (podem ser muitas por serem a mesma coisa descrita de formas diferentes; veja as famílias). `placebo_conf_max` = o máximo que o placebo produziu.\n")
P(md_table(R, 1))
tot = R.groupby("modo").agg(hipoteses=("hipoteses", "sum"), passou_BH=("passou_BH", "sum"), confirmadas=("confirmadas", "sum"), placebo_max_soma=("placebo_conf_max", "sum")).reset_index()
P("Totais por modo:\n")
P(md_table(tot, 0))

# ------------------------------------------------------------------ families / candidates
fam = []
for s in syms:
    f = readall(s, "familias_todas")
    if len(f): f.insert(0, "ativo", s); fam.append(f)
F = pd.concat(fam, ignore_index=True) if fam else pd.DataFrame()
P("## 4. Famílias validadas por ativo\n")
if len(F):
    F["viavel_B"] = (F["liq_B_pts_val"] > 0) & (F["t_liq_B"] > 1.645) & (F["t_delta"] > 1.645)
    F["candidata"] = F["viavel_B"] & F["passou_BH"] & (F["metade1_B"] > 0) & (F["metade2_B"] > 0)
    F["cat"] = F.apply(categoria, axis=1)
    g = F.groupby("ativo").agg(familias_validadas=("condicao", "size"), liquido_positivo=("viavel_B", "sum"), candidatas=("candidata", "sum")).reset_index()
    cs = F[F["candidata"]].groupby(["ativo", "cat"]).size().unstack(fill_value=0).reset_index()
    P(md_table(g, 0))
    P("Candidatas por categoria:\n")
    P(md_table(cs, 0) if len(cs) else "_nenhuma_\n")
    # ---- commission sensitivity: USD 7.00 round-turn per lot (typical Raw/ECN account) converted to points with each symbol's own tick value
    COMM = 7.0
    jobs = {}
    jp = os.environ.get("MBA_JOBS", "C:/Users/luiz_/AppData/Local/Temp/rep/jobs.txt")
    base_dir = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer"
    if os.path.exists(jp):
        for line in open(jp):
            q = line.split()
            if len(q) == 2: jobs[q[1]] = f"{base_dir}/{q[0]}/LIVE"
    from mba_report import read_spec
    cp = {}
    for s_, lv in jobs.items():
        sp = read_spec(lv)
        try:
            vpp = float(sp["tick_value"]) * float(sp["point"]) / float(sp["tick_size"])
            cp[s_] = COMM / vpp if vpp > 0 else np.nan
        except Exception:
            cp[s_] = np.nan
    for s_ in ("BTCUSD", "US30", "DXY"):
        cp[s_] = 0.0          # indices/crypto CFDs are normally spread-only: no commission assumed
    F["comissao_RT_pts_7usd"] = F["ativo"].map(cp)
    F["liq_apos_comissao"] = F["liq_B_pts_val"] - F["comissao_RT_pts_7usd"]
    cand = F[F["candidata"]].sort_values("t_liq_B", ascending=False)
    os.makedirs(os.path.join(os.path.dirname(OUT), "mba"), exist_ok=True)
    cand.to_csv(os.path.join(os.path.dirname(OUT), "mba", "candidatas_todas.csv"), index=False)
    F.to_csv(os.path.join(os.path.dirname(OUT), "mba", "familias_todas_ativos.csv"), index=False)
    cols = ["ativo", "tf", "modo", "condicao", "serie", "lado", "n_val", "bruto_pts_val", "liq_B_pts_val", "base_B_pts_val", "t_delta", "t_liq_B", "pct_pos_B", "anos_pos", "meses_pos", "custo_medio_pts", "comissao_RT_pts_7usd", "liq_apos_comissao", "n_formas_equivalentes"]
    P("## 5. Candidatas da categoria 4 (demais) — as mais limpas\n")
    P("Cada linha é uma família distinta. Ainda é evidência **retrospectiva**: o próximo passo seria acompanhar semanas de dados novos (forward) antes de qualquer decisão.\n")
    c4 = cand[cand["cat"] == "4 demais"]
    P(md_table(c4[cols].head(150), 2) if len(c4) else "_Nenhuma candidata na categoria 4._\n")
    P("## 6. Candidatas das categorias 1-3 (usar com cautela)\n")
    for k in sorted(cand["cat"].unique()):
        if k == "4 demais": continue
        x = cand[cand["cat"] == k]
        P(f"### {k} — {len(x)} famílias (as 15 melhores)\n")
        P(md_table(x[cols].head(15), 2))
    # ---- clock replication across symbols
    P("## 7. Repetição entre ativos (mesma condição em mais de um ativo com líquido positivo)\n")
    def key(c):
        return re.sub(r"\s+", " ", str(c).split(" & ")[0].strip())
    F["chave"] = F["condicao"].map(key) + " | " + F["lado"]
    rep = F[F["viavel_B"]].groupby("chave").agg(ativos=("ativo", lambda x: ",".join(sorted(set(x)))), n_ativos=("ativo", "nunique"), liq_medio=("liq_B_pts_val", "mean")).reset_index()
    rep = rep[rep["n_ativos"] >= 2].sort_values(["n_ativos", "liq_medio"], ascending=False)
    P(md_table(rep.head(60), 2) if len(rep) else "_Nenhuma condição aparece com líquido positivo em 2 ou mais ativos._\n")
    P("## 8. Melhores famílias com líquido positivo por ativo (inclui as que não passaram no BH, exploratórias)\n")
    for s in syms:
        x = F[(F["ativo"] == s) & F["viavel_B"]].sort_values("t_liq_B", ascending=False).head(12)
        P(f"### {s}\n")
        P(md_table(x[["tf", "modo", "condicao", "serie", "lado", "passou_BH", "cat", "n_val", "liq_B_pts_val", "base_B_pts_val", "t_delta", "t_liq_B", "pct_pos_B", "anos_pos", "meses_pos"]], 2) if len(x) else "_Nenhuma com líquido positivo, t>1,645 e vantagem sobre a média das velas._\n")
else:
    P("_Sem famílias._\n")

P("## 9. Limites e avisos\n")
P("- **Dados:** os candles M1 ficaram incompletos por um teto do código (`InpMaxCatchupBars`, corrigido na v1.23.1; requer reiniciar o EA e reconstruir); por isso a mineração usa eventos M5/M15/M30/H1 e mede o futuro nas barras M1 que o terminal tem (FORWARD_TIME). Eventos M1 não foram minerados.\n"
  "- **XAUUSD da FP** ficou fora (EA parou; usado o XAUUSD da IC). **DXY_Z6** é contrato com vencimento (rolagem não tratada).\n"
  "- **Custo:** spread estimado por perfil de ticks dos últimos ~120 dias (mediana por slot); não inclui slippage, requotes, comissão (declarada 0) nem swap. Em abertura de semana, rolagem e notícias o spread real pode ser muito maior.\n"
  "- **Sem stop:** os modos `hit` assumem o perfil do operador (sem SL). Perdas raras e grandes podem não estar na amostra; veja a categoria 2.\n"
  "- **Validação:** uma janela cronológica única (40% finais) e ativos correlacionados (AUDUSD/NZDUSD, USDCHF/USDJPY): achar a mesma coisa em pares correlacionados não é replicação independente.\n"
  "- **Overlap:** janelas futuras se sobrepõem; a estatística usa amostra efetiva n·min(1, tf/horizonte), ainda assim aproximada.\n"
  "- **Não é prova de lucro:** é triagem com controle de falso positivo, em dados históricos de 1,5 a 5 anos, sem execução real.\n")
open(OUT, "w", encoding="utf-8").write("\n".join(L))
print("OK", OUT, len(L))
