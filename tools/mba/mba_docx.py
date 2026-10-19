#!/usr/bin/env python3
"""Builds a Word (.docx) with ALL the MBA tables (no third-party libraries: raw OOXML via zipfile).

  python tools/mba/mba_docx.py docs/relatorios/MBA-TABELAS-2026-10-18.docx
"""
import os, re, sys, zipfile
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/MBA-TABELAS-2026-10-18.docx"
D15 = "docs/relatorios/mba/padroes_dia"
DS = "docs/relatorios/mba/padroes"
DM1 = "docs/relatorios/mba/padroes_m1"
PAGE_W, PAGE_H, MARG = 16838, 11906, 567            # A4 landscape, 1 cm margins
CONTENT_W = PAGE_W - 2 * MARG


# ------------------------------------------------------------------------------------------------ formatting
def fmt(v, d=0, pct=False):
    if v is None or (isinstance(v, float) and not np.isfinite(v)):
        return ""
    if isinstance(v, str):
        return v
    s = f"{v:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return s + ("%" if pct else "")


def esc(s):
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


# ------------------------------------------------------------------------------------------------ OOXML helpers
BODY = []


def run(text, bold=False, italic=False, sz=None, color=None):
    rpr = ""
    if bold: rpr += "<w:b/>"
    if italic: rpr += "<w:i/>"
    if color: rpr += f'<w:color w:val="{color}"/>'
    if sz: rpr += f'<w:sz w:val="{sz}"/><w:szCs w:val="{sz}"/>'
    return f'<w:r>{"<w:rPr>" + rpr + "</w:rPr>" if rpr else ""}<w:t xml:space="preserve">{esc(text)}</w:t></w:r>'


def para(text="", style=None, bold=False, italic=False, sz=None, align=None, after=80, before=0, runs=None, keep_next=False, color=None):
    ppr = ""
    if style: ppr += f'<w:pStyle w:val="{style}"/>'
    if keep_next: ppr += "<w:keepNext/>"
    ppr += f'<w:spacing w:before="{before}" w:after="{after}"/>'
    if align: ppr += f'<w:jc w:val="{align}"/>'
    content = runs if runs is not None else run(text, bold, italic, sz, color)
    BODY.append(f"<w:p><w:pPr>{ppr}</w:pPr>{content}</w:p>")


def h1(t): para(t, style="Heading1", keep_next=True, after=120, before=240)
def h2(t): para(t, style="Heading2", keep_next=True, after=80, before=200)
def h3(t): para(t, style="Heading3", keep_next=True, after=60, before=140)
def note(t): para(t, italic=True, sz=16, color="595959", after=100)
def bullet(t): para("•  " + t, after=40)


def page_break():
    BODY.append('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')


def table(header, rows, weights=None, sz=14, align_right_from=None, fills=None):
    """header: list[str]; rows: list[list[str]]; weights: relative column widths; fills: dict {(r,c): hexcolor}."""
    n = len(header)
    if weights is None:
        weights = [max(len(str(header[i])) * 0.6, np.mean([len(str(r[i])) for r in rows]) if rows else 4, 4) for i in range(n)]
    tot = float(sum(weights))
    widths = [max(380, int(CONTENT_W * w / tot)) for w in weights]
    diff = CONTENT_W - sum(widths)
    widths[-1] += diff
    grid = "".join(f'<w:gridCol w:w="{w}"/>' for w in widths)

    def cell(text, w, head=False, fill=None, right=False, bold=False):
        shd = f'<w:shd w:val="clear" w:color="auto" w:fill="{fill}"/>' if fill else ""
        jc = '<w:jc w:val="right"/>' if right else ('<w:jc w:val="center"/>' if head else "")
        r = run(text, bold=head or bold, sz=sz)
        return (f'<w:tc><w:tcPr><w:tcW w:w="{w}" w:type="dxa"/>{shd}<w:vAlign w:val="center"/></w:tcPr>'
                f'<w:p><w:pPr><w:spacing w:before="20" w:after="20"/>{jc}</w:pPr>{r}</w:p></w:tc>')

    out = ['<w:tbl><w:tblPr><w:tblW w:w="%d" w:type="dxa"/><w:tblLayout w:type="fixed"/>' % CONTENT_W,
           '<w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="A6A6A6"/><w:left w:val="single" w:sz="4" w:space="0" w:color="A6A6A6"/>'
           '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="A6A6A6"/><w:right w:val="single" w:sz="4" w:space="0" w:color="A6A6A6"/>'
           '<w:insideH w:val="single" w:sz="4" w:space="0" w:color="D9D9D9"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="D9D9D9"/></w:tblBorders>',
           '<w:tblCellMar><w:left w:w="50" w:type="dxa"/><w:right w:w="50" w:type="dxa"/></w:tblCellMar></w:tblPr>',
           f"<w:tblGrid>{grid}</w:tblGrid>"]
    out.append('<w:tr><w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>' + "".join(cell(h, widths[i], head=True, fill="1F3864") .replace("<w:b/>", "<w:b/><w:color w:val=\"FFFFFF\"/>", 1) for i, h in enumerate(header)) + "</w:tr>")
    for ri, r in enumerate(rows):
        cells = []
        for ci in range(n):
            txt = r[ci] if ci < len(r) else ""
            f = (fills or {}).get((ri, ci)) or ("F2F2F2" if ri % 2 else None)
            right = align_right_from is not None and ci >= align_right_from
            cells.append(cell(txt, widths[ci], fill=f, right=right))
        out.append('<w:tr><w:trPr><w:cantSplit/></w:trPr>' + "".join(cells) + "</w:tr>")
    out.append("</w:tbl>")
    BODY.append("".join(out))
    BODY.append('<w:p><w:pPr><w:spacing w:before="0" w:after="60"/></w:pPr></w:p>')


# ------------------------------------------------------------------------------------------------ data helpers
def readcsv(path):
    return pd.read_csv(path) if os.path.exists(path) else None


def clock_table(df, top=10):
    if df is None or len(df) == 0:
        return None
    df = df.sort_values("ev_estresse_pts", ascending=False).head(top)
    hdr = ["Lado", "Alvo (pts)", "Entrada (servidor)", "Londres", "n", "% alvo", "Ganho no alvo", "Perda média sem alvo", "% p/ empatar", "EV estressado", "Média real", "Pior dia", "Contra médio", "Min até alvo", "Anos +"]
    rows = []
    for _, x in df.iterrows():
        rows.append([x["lado"], fmt(x["alvo_pts"]), str(x["janela_entrada"]), str(x.get("londres", "")), fmt(x["n"]), fmt(x["pct_alvo"], 1, True), fmt(x["ganho_dia_alvo"]), fmt(x["perda_media_sem_alvo"]),
                     fmt(x["pct_necessario_p_empatar"], 0, True), fmt(x["ev_estresse_pts"]), fmt(x["media_real_pts"]), fmt(x["pior_dia_pts"]), fmt(x["mae_medio_pts"]), fmt(x["min_ate_alvo"]), str(x["anos_pos"])])
    return hdr, rows, [5, 5, 9, 6, 4, 5, 6, 7, 5, 6, 6, 7, 6, 5, 4]


def cond_table(df, top=10):
    if df is None or len(df) == 0 or "dias_com_sinal" not in df.columns:
        return None
    c0 = df[df["cat"] == "demais"].copy()
    ok = c0["anos_pos"].map(lambda v: v.split("/")[0] == v.split("/")[1])
    c = c0[~c0["condicao"].str.contains("month=|dom_w=") & (c0["n"] >= 250) & (c0["dias_com_sinal"] >= 60) & ((c0["pct_alvo_val"] - c0["pct_base_val"]) >= 8) & ok & (c0["media_real_pts"] > 0)]
    if len(c) == 0:
        return "nenhuma", None, None
    c = c.sort_values(["passou_BH", "ev_estresse_pts"], ascending=[False, False]).head(top)
    hdr = ["Lado", "Alvo (pts)", "Condição (conhecida antes da abertura)", "Horas de entrada (servidor)", "Dias c/ sinal", "% alvo", "% base", "Perda média sem alvo", "Média real", "Pior dia", "Contra médio", "Min até alvo", "BH", "Anos +"]
    rows = []
    for _, x in c.iterrows():
        rows.append([x["lado"], fmt(x["alvo_pts"]), str(x["condicao"]), str(x["melhores_horas"]) if isinstance(x["melhores_horas"], str) else "—", fmt(x["dias_com_sinal"]), fmt(x["pct_alvo"], 1, True),
                     fmt(x["pct_base_val"], 1, True), fmt(x["perda_media_sem_alvo"]), fmt(x["media_real_pts"]), fmt(x["pior_dia_pts"]), fmt(x["mae_medio_pts"]), fmt(x["min_ate_alvo"]), "sim" if x["passou_BH"] else "não", str(x["anos_pos"])])
    return hdr, rows, [4, 4, 16, 9, 4, 4, 4, 6, 5, 6, 5, 5, 3, 4]


def fixed_table(df, top=10):
    if df is None or len(df) == 0:
        return None
    df = df.head(top)
    hdr = ["Janela de entrada", "Lado", "TF", "Entrada", "Duração (min)", "n", "% acerto bruto", "% lucro líquido", "% ≥100 pts", "% ≥300 pts", "% toca +300", "Média líq.", "Mediana líq.", "Custo médio", "Anos +", "Meses +"]
    rows = []
    for _, x in df.iterrows():
        rows.append([str(x["janela"]), x["lado"], str(x["tf"]), str(x["entrada_servidor"]), fmt(x["dur_min"]), fmt(x["n"]), fmt(x["pct_acerto_bruto"], 1, True), fmt(x["pct_liquido_pos"], 1, True),
                     fmt(x["pct_liq_ge_100"], 1, True), fmt(x["pct_liq_ge_300"], 1, True), fmt(x["pct_toca_300"], 1, True), fmt(x["media_liq_pts"]), fmt(x["mediana_liq_pts"]), fmt(x["custo_medio_pts"]), str(x["anos_pos"]), str(x["meses_pos"])])
    return hdr, rows, [8, 5, 3, 5, 5, 4, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4]


def md_numbers(path):
    if not os.path.exists(path):
        return None
    md = open(path, encoding="utf-8").read()
    r = {}
    m = re.search(r"Padrões que passaram: \*\*(\d+)\*\*; placebo: média ([\d.]+), máximo (\d+)", md)
    if m: r["clock"] = (int(m.group(1)), float(m.group(2)), int(m.group(3)))
    m = re.search(r"Hipóteses testadas: \*\*([\d,]+)\*\*; passaram no BH na descoberta: \*\*([\d,]+)\*\*; confirmadas na validação: \*\*([\d,]+)\*\*; placebo: BH média ([\d.]+) \(máx (\d+)\), confirmadas média ([\d.]+) \(máx (\d+)\)", md)
    if m: r["cond"] = tuple(float(x.replace(",", "")) for x in m.groups())
    m = re.search(r"ATR M15 mediano = (\d+) pts; alvos testados: \[([^\]]+)\]", md)
    if m: r["atr"] = (m.group(1), m.group(2))
    return r


# ================================================================================================ DOCUMENT
ORDER = ["XAUUSD", "XAGUSD", "USDJPY", "EURJPY", "GBPJPY", "USDCHF", "NZDUSD", "AUDUSD", "DXY", "US30", "DE40", "USTEC", "US500", "XTIUSD", "XBRUSD"]
M1_SYMS = ["DE40", "US500", "USTEC", "XAGUSD", "XBRUSD", "XTIUSD"]

para("MarketBehaviorAnalyzer — todas as tabelas", style="Title", after=60)
para("Padrões intraday por ativo: entrada no horário (hora do servidor), saída no alvo ou, no máximo, às 23:30 do servidor, sem stop", sz=22, after=120)
para("Gerado em 18/10/2026. Dados de 2024-01 a 2026-10 (708 dias). Resultados retrospectivos; comissão, slippage e swap não incluídos. Londres = servidor − 2 h; Nova York = servidor − 7 h.", italic=True, sz=18, color="595959", after=160)

h1("Como ler")
for t in [
    "Hora = hora do servidor do MT5 (UTC+3 no verão dos EUA, UTC+2 no inverno).",
    "Alvo (pts): lucro-alvo em pontos do ativo. Os alvos são proporcionais à volatilidade de cada ativo (25%, 50%, 100% e 200% do ATR M15, mais 300 pontos).",
    "% alvo: % dos dias em que o preço atingiu o alvo antes das 23:30. % base: % que qualquer horário atinge o mesmo alvo no mesmo período.",
    "Ganho no alvo: resultado líquido médio nos dias em que bateu o alvo. Perda média sem alvo: resultado médio nos dias em que o alvo NÃO foi atingido (medida em todos os horários do mesmo lado e alvo; amostra grande da cauda).",
    "% p/ empatar: taxa de acerto necessária para a conta empatar com essa perda média. EV estressado: expectativa por operação usando o limite inferior de 95% da taxa de acerto.",
    "Média real: média efetivamente obtida. Pior dia: pior resultado de um único dia, sem stop. Contra médio (MAE): quanto o preço andou contra a posição, em média, antes de sair.",
    "BH: sobreviveu à correção de múltiplos testes (Benjamini-Hochberg) na descoberta. Anos +: anos com média positiva / anos testados.",
    "Descoberta = primeiros 60% do tempo; validação = últimos 40%. Placebo = o mesmo procedimento com os resultados deslocados aleatoriamente no tempo: um padrão só é confiável se aparecer bem mais vezes que no placebo.",
    "Confiança: A = acima do acaso e consistente nos anos; B = pista para conferir no gráfico; C = sem evidência ou dominado por viés de alta/custo.",
]:
    bullet(t)

# ---------------------------------------------------------------------------------- 1. Resumo
h1("1. Tabela-resumo por ativo")
summary = [
    ("XAUUSD (ouro)", "0,02", "32 vs. 6 → acima", "Venda 12:25 (M5, 5 min); compras 01:00–01:15 (alvo 500) e 23:00 (3 h)", "69% · +96 pts; 89% (alvo 500) · +89", "−17.707", "A (cauda grande)"),
    ("XAGUSD (prata)", "0,21", "0 vs. 1 → nada", "Nenhum. O 12:25 do ouro na prata: 54,5% (ouro 68,8%)", "condição não melhora (78% vs 79%)", "−6.458", "C"),
    ("USDJPY", "0,07", "17 vs. 33 → acaso", "Compra 03–04h, 07h, 10h com H4 rompendo para baixo, alvo 300", "71% (39%) · +32", "−3.051", "B"),
    ("EURJPY", "n/d", "42 vs. 33 → marginal", "Compra 03–06h com H4 em baixa e notícia distante, alvo 300", "72% (40%) · +60", "−3.042", "B"),
    ("GBPJPY", "n/d", "71 vs. 71 → acaso", "Compra 03–06h (Ásia) com semanal em baixa; 07h com D1 em baixa", "81% (51%) · +71; 80% · +123", "−5.691", "B"),
    ("USDCHF", "0,22", "5 vs. 13 → acaso", "Venda 10–11h após rompimento de baixa no M30, alvo 300", "56% (20%) · +73", "−1.059", "B−"),
    ("NZDUSD", "0,26", "5 vs. 10 → acaso", "Venda às segundas 01–02h, alvo 90", "86% (57%) · +31", "−873", "B−"),
    ("AUDUSD", "0,63", "0 vs. 0 → nada", "Fraco: compra 01h com M15 em baixa, alvo 300", "41% (20%) · +22", "−2.998", "C (spread alto)"),
    ("DXY", "1,19", "0 vs. 0 → nada", "Fraco: compra 03–07h com semanal rompendo para cima", "51% (18%) · +63", "−875", "C (spread 30 pts > ATR)"),
    ("US30", "0,05", "28 vs. 3 → acima", "Só compras com alvos enormes (7.525 pts), 01–16h", "81% (73%) · +597", "−129.580", "C (viés de alta)"),
    ("DE40 (DAX)", "0,05", "55 vs. 32 → acima", "Compra 09:00 por 45 min (M30): 51% fecha ≥ 300 pts líquidos, média +503 pts, 3/3 anos", "79% · +530 (intraday)", "−143.160", "B+"),
    ("USTEC (Nasdaq)", "0,055", "27 vs. 3 → acima", "Compras 01:15–02:15; vendas condicionais (segunda 01h, quinta 05–07h)", "81% (73%) · +726", "−146.320", "C (viés de alta)"),
    ("US500 (S&P)", "0,15", "32 vs. 2 → acima", "Compras 01:15–03:00", "81% (72%) · +130", "−21.635", "C (viés de alta)"),
    ("XTIUSD (WTI)", "0,16", "16 vs. 4 → acima", "Venda 02h com semanal em alta, alvo 370", "86% (68%) · +44", "−5.030", "B"),
    ("XBRUSD (Brent)", "0,08", "33 vs. 0 → acima", "Venda 05–09h (Ásia) com ATR anterior alto, alvo 370", "88% (67%) · +92", "−9.490", "B"),
    ("BTCUSD", "0,11", "—", "Nada (descartado)", "—", "—", "C"),
]
fills = {}
for i, r in enumerate(summary):
    k = r[6][0]
    fills[(i, 6)] = {"A": "C6E0B4", "B": "FFE699", "C": "D9D9D9"}.get(k, None)
table(["Ativo", "Custo (spread ÷ ATR M5)", "Horários puros vs. acaso", "Padrão mais promissor (hora do servidor)", "Acerto (base) · média real", "Pior dia (pts)", "Confiança"],
      [list(r) for r in summary], weights=[7, 5, 8, 26, 12, 6, 7], sz=15, fills=fills)
note("Horários puros vs. acaso = quantos horários passaram nos critérios contra o máximo que o teste com dados embaralhados aprova. 'n/d' = os dados brutos saíram da pasta; a análise foi feita antes. As colunas de acerto mostram '% alvo (% base) · média real em pontos'.")

# ---------------------------------------------------------------------------------- 2. Cobertura e custo
h1("2. Cobertura de dados e custo")
rs = readcsv("docs/relatorios/mba/resumo_por_ativo.csv")
if rs is not None:
    rows = []
    for _, x in rs.iterrows():
        rows.append([x["ativo"], fmt(x["spread_ticks_pts"], 1) if np.isfinite(x["spread_ticks_pts"]) else "n/d", fmt(x["ATR_M5_pts"], 1) if np.isfinite(x["ATR_M5_pts"]) else "n/d",
                     fmt(x["custo_sobre_ATR"], 2) if np.isfinite(x["custo_sobre_ATR"]) else "n/d", str(x["horarios_puros_vs_acaso"]), str(x["passa_acaso"])])
    table(["Ativo", "Spread dos ticks (pts)", "ATR M5 mediano (pts)", "Custo ÷ ATR", "Horários puros que passaram (placebo máx.)", "Acima do acaso?"], rows, weights=[6, 6, 6, 5, 12, 5], sz=15, align_right_from=1)
note("Custo ÷ ATR até ~0,1 é barato; acima de ~0,3 o custo come o movimento típico de minutos.")
h2("Cobertura do M1 (backfill)")
table(["Ativo", "Velas M1", "Período", "Situação"],
      [["DE40", "935.229", "2024-01-22 a 2026-10-16", "completo"], ["US500", "966.827", "2024-01-22 a 2026-10-16", "completo"], ["USTEC", "970.036", "2024-01-22 a 2026-10-16", "completo"],
       ["XAGUSD", "971.049", "2024-01-22 a 2026-10-16", "completo"], ["XBRUSD", "900.611", "2024-01-22 a 2026-10-16", "completo"], ["XTIUSD", "962.793", "2024-01-22 a 2026-10-16", "completo"],
       ["XAUUSD", "200.001", "~2026-03 a 2026-10", "incompleto (EA com o bug antigo; reconstruir)"], ["US30", "200.001", "~2026-03 a 2026-10", "incompleto (EA com o bug antigo; reconstruir)"],
       ["USDJPY, EURJPY, GBPJPY, USDCHF, NZDUSD, AUDUSD, DXY, BTCUSD", "—", "—", "pastas de dados não estão mais em Common\\Files (M5–D1 analisados antes)"]],
      weights=[16, 7, 12, 22], sz=15)

# ---------------------------------------------------------------------------------- 3. Teste contra o acaso
h1("3. Teste contra o acaso (placebo)")
rows = []
for s in ORDER:
    a = md_numbers(f"{D15}/{s}.md")
    b = md_numbers(f"{DM1}/{s}_m1.md")
    rr = [s]
    if a:
        c = a.get("clock"); k = a.get("cond")
        rr += [f"{c[0]} (placebo média {c[1]:.1f} / máx {c[2]})" if c else "", f"{fmt(k[2])} (placebo média {fmt(k[5], 1)} / máx {fmt(k[6])})" if k else ""]
    else:
        rr += ["", ""]
    if b:
        c = b.get("clock"); k = b.get("cond")
        rr += [f"{fmt(c[0])} (placebo média {c[1]:.1f} / máx {c[2]})" if c else "", f"{fmt(k[2])} (placebo média {fmt(k[5], 1)} / máx {fmt(k[6])})" if k else ""]
    else:
        rr += ["—", "—"]
    rows.append(rr)
table(["Ativo", "Horários puros — M15", "Horário + condição confirmadas — M15", "Horários puros — M1", "Horário + condição confirmadas — M1"], rows, weights=[5, 11, 13, 11, 13], sz=15)
note("Horário + condição: nº de células que passaram no BH na descoberta e repetiram o sinal na validação. Em M1 o placebo também aprova bastante coisa por acaso: trate as famílias como pistas.")

# ---------------------------------------------------------------------------------- 4. Por ativo
h1("4. Tabelas por ativo")
para("Para cada ativo: (a) horários puros no formato alvo ou 23:30; (b) horário + condição; (c) duração fixa (entra e sai X minutos depois); (d) as mesmas tabelas em M1 quando o backfill está completo.", after=120)
for s in ORDER:
    h2(s)
    a = md_numbers(f"{D15}/{s}.md")
    if a and "atr" in a:
        para(f"ATR M15 mediano = {a['atr'][0]} pts. Alvos testados: [{a['atr'][1]}] pts.", sz=18, after=60)
    # (a)
    t = clock_table(readcsv(f"{D15}/{s}_horarios.csv"))
    h3(f"{s} — (a) Horários puros, alvo ou 23:30 (M15)")
    if t:
        table(t[0], t[1], weights=t[2], sz=13, align_right_from=4)
    else:
        para("Nenhum horário puro passou nos critérios.", italic=True, after=80)
    # (b)
    h3(f"{s} — (b) Horário + condição (M15)")
    cf = readcsv(f"{D15}/{s}_condicionais.csv")
    t = cond_table(cf)
    if t is None:
        para("Sem dados comparáveis (análise anterior à inclusão das horas de entrada).", italic=True, after=80)
    elif t[0] == "nenhuma":
        para("Nenhuma família passou nos filtros (≥ 60 dias distintos, n ≥ 250, ≥ 8 p.p. acima da base, positiva todos os anos, média real > 0).", italic=True, after=80)
    else:
        table(t[0], t[1], weights=t[2], sz=13, align_right_from=4)
    # (c)
    t = fixed_table(readcsv(f"{DS}/{s}_padroes.csv"))
    h3(f"{s} — (c) Duração fixa (M5 a H1)")
    if t:
        table(t[0], t[1], weights=t[2], sz=13, align_right_from=5)
    else:
        para("Nenhuma janela de duração fixa passou nos critérios (ou não analisada).", italic=True, after=80)
    # (d)
    if s in M1_SYMS:
        h3(f"{s} — (d) M1 (entradas minuto a minuto)")
        t = clock_table(readcsv(f"{DM1}/{s}_m1_horarios.csv"))
        if t:
            para("Horários puros em M1:", bold=True, sz=18, after=40)
            table(t[0], t[1], weights=t[2], sz=13, align_right_from=4)
        else:
            para("Horários puros em M1: nenhum passou.", italic=True, after=60)
        t = cond_table(readcsv(f"{DM1}/{s}_m1_condicionais.csv"))
        if t and t[0] != "nenhuma":
            para("Horário + condição em M1:", bold=True, sz=18, after=40)
            table(t[0], t[1], weights=t[2], sz=13, align_right_from=4)
        else:
            para("Horário + condição em M1: nenhuma família passou nos filtros.", italic=True, after=60)
        t = fixed_table(readcsv(f"{DM1}/{s}_padroes.csv"))
        if t:
            para("Duração fixa em M1:", bold=True, sz=18, after=40)
            table(t[0], t[1], weights=t[2], sz=13, align_right_from=5)
        else:
            para("Duração fixa em M1: nenhum padrão passou.", italic=True, after=60)
h2("BTCUSD")
para("Descartado a pedido: a mineração não encontrou padrão operável após custos.", after=80)

# ---------------------------------------------------------------------------------- 5. Limites
h1("5. Limites e avisos")
for t in [
    "Todos os resultados são retrospectivos (2024 a 2026) e sem comissão, slippage e swap; o spread usado é o medido nos ticks.",
    "Sem stop: a perda dos dias em que o alvo não é atingido pode ser várias vezes o ganho do alvo. O pior dia e o MAE de cada linha mostram essa cauda.",
    "A perda dos dias sem alvo usa o fechamento das 23:30; carregar a posição para o dia seguinte não está incluído.",
    "Índices (US30, USTEC, US500, DE40): quase só compras, por causa da alta do período; o 'padrão' é a tendência, não o horário.",
    "Ativos correlacionados (USDJPY, EURJPY, GBPJPY) não são confirmações independentes entre si.",
    "Padrões com condição passam no placebo, mas as condições acompanham regimes de tendência: são pistas para conferir no gráfico, não provas.",
    "As tabelas completas por ativo, com as datas de cada ocorrência, estão nos CSV de docs/relatorios/mba/ (padroes_dia, padroes, padroes_m1).",
]:
    bullet(t)

# ================================================================================================ package
NS = ('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"')
sect = (f'<w:sectPr><w:footerReference w:type="default" r:id="rId3"/><w:pgSz w:w="{PAGE_W}" w:h="{PAGE_H}" w:orient="landscape"/>'
        f'<w:pgMar w:top="{MARG}" w:right="{MARG}" w:bottom="{MARG + 200}" w:left="{MARG}" w:header="300" w:footer="300" w:gutter="0"/></w:sectPr>')
document = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document {NS}><w:body>{"".join(BODY)}{sect}</w:body></w:document>'

styles = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles {NS}>
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial" w:eastAsia="Arial"/><w:sz w:val="19"/><w:szCs w:val="19"/><w:lang w:val="pt-BR"/></w:rPr></w:rPrDefault>
<w:pPrDefault><w:pPr><w:spacing w:after="80" w:line="252" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:rPr><w:b/><w:color w:val="1F3864"/><w:sz w:val="44"/><w:szCs w:val="44"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:color w:val="1F3864"/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:color w:val="2F5496"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:color w:val="404040"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
</w:styles>'''

footer = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr {NS}><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t xml:space="preserve">MBA — tabelas · página </w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'''

ctypes = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/>
<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
<Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>
<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/></Types>'''
rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/></Relationships>'''
docrels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>'''
settings = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:settings {NS}><w:zoom w:percent="100"/><w:defaultTabStop w:val="720"/><w:compat><w:compatSetting w:name="compatibilityMode" w:uri="http://schemas.microsoft.com/office/word" w:val="15"/></w:compat></w:settings>'
core = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>MBA — todas as tabelas</dc:title><dc:creator>MarketBehaviorAnalyzer</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-10-18T12:00:00Z</dcterms:created></cp:coreProperties>'''

os.makedirs(os.path.dirname(os.path.abspath(OUT)), exist_ok=True)
with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", ctypes)
    z.writestr("_rels/.rels", rels)
    z.writestr("word/document.xml", document)
    z.writestr("word/styles.xml", styles)
    z.writestr("word/settings.xml", settings)
    z.writestr("word/footer1.xml", footer)
    z.writestr("word/_rels/document.xml.rels", docrels)
    z.writestr("docProps/core.xml", core)
print("OK", OUT, f"{os.path.getsize(OUT) / 1024:.0f} KB")
