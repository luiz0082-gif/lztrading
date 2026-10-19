#!/usr/bin/env python3
"""Builds a Word (.docx) with ALL the MBA tables (no third-party libraries: raw OOXML via zipfile).

  python tools/mba/mba_docx.py docs/relatorios/XBRUSD-TABELA-COMPLETA-2026-10-18.docx
"""
import os, re, sys, zipfile
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/XBRUSD-TABELA-COMPLETA-2026-10-18.docx"
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


# ---- XBRUSD: varredura intraday completa (alvo ou 23:30, sem stop) ----
OD = "docs/relatorios/mba/scan_all/"
ALL = pd.read_csv(OD + "XBRUSD_todos.csv")
Z = np.load(OD + "XBRUSD_raw.npz", allow_pickle=True)
RAWR = Z["RES"]; RAWH = Z["HIT"]; DATES = pd.to_datetime(Z["dates"]); SLOTS = list(Z["slots"]); TGS = list(Z["targets"])
COLS = ["Servidor", "Lado", "Alvo (pts)", "Dias", "% alvo", "Wilson 95%", "% desc.", "% valid.", "Média/dia", "Méd. desc.", "Méd. valid.", "Dias s/ alvo", "Perda média s/ alvo", "Pior dia", "MAE médio", "% p/ empatar", "Min. mediana", "Anos 24/25/26"]
W = [5, 5, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 5, 5, 5, 6]


def hm_add(hm, h):
    t = (int(hm[:2]) * 60 + int(hm[3:]) + int(h * 60)) % 1440
    return f"{t // 60:02d}:{t % 60:02d}"


def rowx(x):
    return [x.slot, x.lado, fmt(x.alvo), fmt(x.n), fmt(x.pct, 1, True), fmt(x.wilson, 1, True), fmt(x.pct_desc, 1, True), fmt(x.pct_val, 1, True),
            fmt(x.media), fmt(x.media_desc), fmt(x.media_val), fmt(x.n_sem_alvo), fmt(x.perda_media), fmt(x.pior), fmt(x.mae_medio), fmt(x.nec, 1, True), fmt(x.min_med), x.anos]


def tabx(df, sz=12):
    table(COLS, [rowx(x) for x in df.itertuples()], weights=W, sz=sz, align_right_from=2)


PASS = ALL[(ALL.media_desc > 0) & (ALL.media_val > 0) & ALL.todos_anos_pos]
ROB = PASS[PASS.wilson > PASS.nec].sort_values("media", ascending=False)
DOIS = ALL[(ALL.media_desc > 0) & (ALL.media_val > 0)]

para("XBRUSD (Brent) — padrões intraday por horário (alvo ou 23:30, sem stop)", style="Title", after=120)
para("Tabela completa · Raw Trading (IC Markets) · M15 · 23/01/2024 a 16/10/2026 (687 dias úteis) · horários do servidor", after=120)

h1("1. Regra e como ler")
for t in [
    "Entrada na abertura da vela M15 do horário (hora do servidor). Sai quando o preço atinge o alvo a favor ou às 23:30 do servidor (fechamento da vela 23:15). Sem stop; 1 operação por dia útil por horário. Cada combinação é horário x lado x alvo.",
    "Varredura: 88 horários (00:00 a 22:00, de 15 em 15 min) x 2 lados x 6 alvos (100, 150, 200, 300, 400 e 500 pts) = 1.056 combinações; 924 com dados suficientes. 1 ponto = 0,001 de preço = US$ 0,10 por lote (contrato de 100 barris). O ATR M15 mediano do Brent é de 185 pts.",
    "Custo: spread medido nos ticks (o Brent na IC tem spread constante de 10 pts = 1 centavo, ou US$ 1,00 por lote). A compra paga o spread na entrada e a venda paga no fechamento. COMISSÃO NÃO ESTÁ INCLUÍDA (o MBA não conseguiu ler a comissão da conta); veja a seção 4. Slippage e swap também não.",
    "% alvo = % dos dias em que o alvo foi atingido. Wilson 95% = limite inferior estatístico dessa taxa. % desc. / % valid. = taxa nos primeiros 60% dos dias (até 10/09/2025) e nos últimos 40%.",
    "Média/dia = resultado médio por operação em pts (já com o spread). Dias s/ alvo = dias em que o alvo não foi atingido e a operação fechou às 23:30; Perda média s/ alvo = resultado médio desses dias.",
    "% p/ empatar = taxa de acerto necessária para a média zerar, dada a perda média dos dias sem alvo. Se Wilson 95% > % p/ empatar, o horário tem lucro mesmo no cenário estatístico pessimista.",
    "MAE médio = quanto o preço andou contra a posição até o fechamento. Min. mediana = tempo mediano até o alvo. Anos 24/25/26 = sinal da média em cada ano.",
]:
    bullet(t)

h1("2. Resumo do que a varredura encontrou")
n_all = len(ALL)
rows = [
    ["Combinações testadas", fmt(n_all)],
    ["Média > 0 no período todo", f"{int((ALL.media > 0).sum())} ({100 * (ALL.media > 0).mean():.0f}%)"],
    ["Média > 0 na descoberta E na validação", fmt(len(DOIS))],
    ["... e também positivas em cada um dos 3 anos", fmt(len(PASS))],
    ["... e com Wilson 95% > % necessário para empatar (robustas)", fmt(len(ROB))],
    ["Dessas robustas, quantas são COMPRA / VENDA", f"{int((ROB.lado == 'COMPRA').sum())} / {int((ROB.lado == 'VENDA').sum())}"],
    ["Placebo (horários embaralhados dentro do dia, 40 rodadas): robustas por acaso", "média 14,3; máximo 27"],
    ["Placebo: positivas nos 2 trechos e nos 3 anos por acaso", "média 35,5; máximo 55 (real: 51)"],
]
table(["Indicador", "Valor"], rows, weights=[10, 5], sz=16)
note("Leitura: o número de combinações 'boas' (51) não se distingue do acaso (placebo médio 35, máximo 55). Com o filtro mais exigente (Wilson > % para empatar) há 30 robustas contra 14 em média no placebo (máximo 27 em 40 rodadas), então há um sinal acima do acaso, mas só no lado da compra, em horários da tarde e da noite.")

h1("3. As 30 combinações mais robustas (todas COMPRA)")
note("Filtro: média > 0 na descoberta e na validação, positivas em todos os anos, e Wilson 95% maior que o % necessário para empatar. Ordenadas por média/dia. Os horários próximos (17:15 a 21:30) são vizinhos e não são amostras independentes.")
tabx(ROB)

h1("4. Comissão: o que sobra do resultado")
rows = []
for com in (0, 10, 20, 30, 50, 70):
    x = ROB
    rows.append([fmt(com) + " pts" + (" (US$ " + fmt(com * 0.1, 2) + " por lote)"), fmt(((x.media_desc - com > 0) & (x.media_val - com > 0)).sum()), fmt(((x.media - com) > 0).sum()), fmt((x.media - com).max()), fmt((x.media - com).median())])
table(["Comissão por operação", "Robustas que seguem positivas nos 2 trechos", "Robustas com média > 0", "Melhor média/dia", "Mediana das médias"], rows, weights=[5, 5, 4, 3, 3], sz=15, align_right_from=1)
note("A comissão real da conta não foi lida pelo MBA. Em contas Raw ela costuma ser cobrada por lote e por lado; confira a sua. A média das robustas é de só 10 a 60 pts por dia (US$ 1 a 6 por lote), então uma comissão de 30 a 70 pts elimina a maior parte do resultado.")

h1("5. Estabilidade das 8 melhores")
top = ROB.head(8)
rows = []
for r_ in top.itertuples():
    s = SLOTS.index(r_.slot); ti = TGS.index(r_.alvo); sd = 0
    x = pd.Series(RAWR[:, s, sd, ti], index=DATES).dropna()
    ya = x.groupby(x.index.year).mean()
    sem = x[~x.index.to_period("M").isin(x.groupby(x.index.to_period("M")).mean().nlargest(3).index)].mean()
    wd = x.groupby(x.index.dayofweek).mean()
    q = x.groupby(x.index.to_period("Q")).mean()
    rows.append([f"{r_.slot} · {r_.alvo}", fmt(x.mean()), fmt(ya.get(2024)), fmt(ya.get(2025)), fmt(ya.get(2026)), fmt(sem), f"{int((q > 0).sum())}/{len(q)}", " ".join(fmt(wd[i]) for i in range(5))])
table(["Horário · alvo (COMPRA)", "Média/dia", "2024", "2025", "2026", "Média sem os 3 melhores meses", "Trimestres positivos", "Média seg · ter · qua · qui · sex"], rows, weights=[4, 3, 3, 3, 3, 4, 3, 7], sz=14, align_right_from=1)
note("Os ganhos se concentram em 2026 (nos primeiros trimestres de 2026 as médias passam de +200 pts); em 2024 e 2025 as médias são próximas de zero. O padrão é dependente de regime.")

h1("6. Combinações positivas nos dois trechos (91)")
dois = DOIS.sort_values(["lado", "alvo", "media"], ascending=[True, True, False])
for lado in ("COMPRA", "VENDA"):
    d0 = dois[dois.lado == lado]
    if len(d0) == 0:
        para(f"Nenhuma {lado.lower()} é positiva nos dois trechos.", after=60)
    for T in TGS:
        d = d0[d0.alvo == T]
        if len(d):
            h3(f"{lado} · alvo {T} pts · {len(d)} combinações")
            tabx(d)

h1("7. Compra x venda")
base = ALL.groupby(["lado", "alvo"])[["pct", "media"]].mean()
rows = [[l_, fmt(a), fmt(base.loc[(l_, a), "pct"], 1, True), fmt(base.loc[(l_, a), "media"])] for l_ in ("COMPRA", "VENDA") for a in TGS]
table(["Lado", "Alvo (pts)", "% alvo médio (todos os horários)", "Média/dia média (todos os horários)"], rows, weights=[3, 3, 5, 5], sz=14, align_right_from=1)
para("Só 2 vendas passam no filtro (positivas nos dois trechos e em todos os anos): 16:15 e 16:30, ambas com alvo de 100 pts, médias de +13 e +15 pts por dia. Nenhuma é robusta (Wilson 95% abaixo do % necessário para empatar). Apenas 7 das 462 combinações de venda são positivas nos dois trechos, e a média por dia das vendas é negativa em todos os alvos.", after=80)

h1("8. Conversão de horários (exemplo)")
note("Servidor = UTC+3 durante o horário de verão dos EUA (segunda semana de março a primeira semana de novembro) e UTC+2 no resto do ano. Local = Brasília (UTC-3): servidor -6h no verão dos EUA e -5h no inverno. Londres = servidor -2h o ano todo. NY = servidor -7h. A mudança do servidor para UTC+2 em 2026 é em 01/11/2026.")
ex = ["12:00", "17:15", "17:45", "18:00", "19:00", "20:30", "21:15", "21:30", "23:30"]
table(["Servidor", "Brasília (servidor UTC+3, mar-nov)", "Brasília (servidor UTC+2, nov-mar)", "Londres", "Nova York"],
      [[s, hm_add(s, -6), hm_add(s, -5), hm_add(s, -2), hm_add(s, -7)] for s in ex], weights=[3, 4, 4, 3, 3], sz=16, align_right_from=1)
note("17:30 do servidor = 10:30 em Nova York, horário do relatório semanal de estoques de petróleo (EIA, quartas). 21:30 do servidor = 19:30 em Londres, perto do fechamento (settlement) do Brent.")

h1("9. Limites e avisos")
for t in [
    "Resultado retrospectivo (2024 a 2026), sem comissão, slippage e swap. Swap do Brent na IC: compra +159 e venda -260 pontos por lote (valores de uma coleta; a compra recebe, a venda paga).",
    "Spread de 10 pts constante nos ticks recentes (só 2 semanas de ticks brutos disponíveis); no histórico o spread real pode ter sido maior.",
    "Entrada na abertura da vela M15; a execução real dentro da vela pode diferir. A saída por alvo assume execução no preço do alvo.",
    "Muitas combinações testadas: parte dos 'bons' horários é acaso. O placebo e o filtro Wilson reduzem isso, mas não eliminam.",
    "O sinal está concentrado em 2026 e em horários vizinhos da tarde/noite. Não é prova de edge; é uma hipótese para teste fora da amostra (demo).",
    "Os dados completos (924 linhas) estão em docs/relatorios/mba/scan_all/XBRUSD_todos.csv.",
]:
    bullet(t)

page_break()
h1("Anexo — todas as combinações")
note("Ordenadas por horário, lado e alvo.")
for lado in ("COMPRA", "VENDA"):
    h2(lado)
    tabx(ALL[ALL.lado == lado].sort_values(["slot", "alvo"]), sz=11)


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
<w:ftr {NS}><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t xml:space="preserve">XBRUSD — tabela · página </w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'''

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
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>XBRUSD — tabela completa</dc:title><dc:creator>MarketBehaviorAnalyzer</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-10-18T12:00:00Z</dcterms:created></cp:coreProperties>'''

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
