#!/usr/bin/env python3
"""Builds a Word (.docx) with ALL the MBA tables (no third-party libraries: raw OOXML via zipfile).

  python tools/mba/mba_docx.py docs/relatorios/XAUUSD-TABELA-COMPLETA-2026-10-18.docx
"""
import os, re, sys, zipfile
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/XAUUSD-TABELA-COMPLETA-2026-10-18.docx"
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


# ---- conteúdo XAUUSD (inserido entre os helpers e o empacotamento de mba_docx.py) ----
RAW = pd.read_pickle("docs/relatorios/mba/xau_horarios/raw.pkl")
ALL = pd.read_csv("docs/relatorios/mba/xau_horarios/xau_horarios_todos.csv")
COLS = ["Servidor", "Lado", "Alvo", "Dias", "% alvo", "Wilson 95%", "% desc.", "% valid.", "Média/dia", "Méd. desc.", "Méd. valid.", "Dias s/ alvo", "Perda média s/ alvo", "Pior dia", "MAE médio", "% p/ empatar", "Min. mediana", "Anos 24/25/26"]
W = [5, 5, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 5, 5, 5, 6]


def hm_add(hm, h):
    t = (int(hm[:2]) * 60 + int(hm[3:]) + int(h * 60)) % 1440
    return f"{t // 60:02d}:{t % 60:02d}"


def rowx(x):
    return [x.slot, "COMPRA" if x.lado == "C" else "VENDA", fmt(x.alvo), fmt(x.n), fmt(x.pct, 1, True), fmt(x.wilson, 1, True), fmt(x.pct_desc, 1, True), fmt(x.pct_val, 1, True),
            fmt(x.media), fmt(x.media_desc), fmt(x.media_val), fmt(x.n_sem_alvo), fmt(x.perda_media), fmt(x.pior), fmt(x.mae_medio), fmt(x.nec, 1, True), fmt(x.min_med), x.anos_pos]


def tabx(df, sz=12):
    rows = [rowx(x) for x in df.itertuples()]
    table(COLS, rows, weights=W, sz=sz, align_right_from=2)


para("XAUUSD — padrões intraday por horário (alvo ou 23:30, sem stop)", style="Title", after=120)
para("Tabela completa · Raw Trading (IC Markets) · M15 · 23/01/2024 a 16/10/2026 (682 dias úteis) · horários do servidor", after=120)
h1("1. Regra e como ler")
for t in [
    "Entrada na abertura da vela M15 do horário (hora do servidor). Sai quando o preço atinge o alvo a favor ou às 23:30 do servidor (fechamento da vela 23:15). Sem stop; 1 operação por dia útil por horário.",
    "Custo: 20 pts de spread no fechamento (compra fecha no bid, venda fecha no ask). Comissão, slippage e swap NÃO incluídos. 1 ponto = 0,01 de preço.",
    "Varredura: 88 horários (00:00 a 22:00, de 15 em 15 min) x 2 lados x 4 alvos (200, 300, 400, 500 pts) = 680 combinações.",
    "% alvo = % dos dias em que o alvo foi atingido. Wilson 95% = limite inferior estatístico dessa taxa. % desc. / % valid. = taxa na descoberta (primeiros 60% dos dias, até 10/09/2025) e na validação (últimos 40%).",
    "Média/dia = resultado médio por operação (pts, já com spread). Dias s/ alvo = dias em que o alvo não foi atingido e a operação fechou às 23:30; Perda média s/ alvo = resultado médio desses dias.",
    "% p/ empatar = taxa de acerto necessária para a média zerar, dada a perda média dos dias sem alvo. Se % alvo < % p/ empatar, o padrão perde dinheiro.",
    "MAE médio = quanto o preço andou contra a posição, em média, até o alvo/23:30 (risco sem stop). Min. mediana = tempo mediano até bater o alvo.",
    "Anos 24/25/26: sinal da média em cada ano (+ ou -).",
]:
    bullet(t)

h1("2. Horários mais estáveis (positivos na descoberta, na validação e em todos os anos)")
note("Filtro: média > 0 nos dois trechos, todos os anos positivos, % alvo ≥ 88%. Dos 680 testes, 133 têm média positiva e 43 são positivos nos dois trechos; só estes 10 passam também no filtro anual. Com 680 testes, parte disso pode ser acaso.")
est = ALL[(ALL.media_desc > 0) & (ALL.media_val > 0) & (~ALL.anos_pos.str.contains("-")) & (ALL.pct >= 88)].sort_values("media", ascending=False)
tabx(est)

h1("3. Todas as combinações positivas nos dois trechos (43)")
dois = ALL[(ALL.media_desc > 0) & (ALL.media_val > 0)].sort_values(["lado", "alvo", "media"], ascending=[True, True, False])
for lado, nome in (("C", "COMPRA"), ("V", "VENDA")):
    d0 = dois[dois.lado == lado]
    if len(d0) == 0:
        para(f"Nenhuma {nome.lower()} é positiva nos dois trechos.", after=60)
    for T in (200, 300, 400, 500):
        d = d0[d0.alvo == T]
        if len(d):
            h3(f"{nome} · alvo {T} pts")
            tabx(d)

h1("4. A venda das 04:20 (o horário que você apontou)")
para("Janela dos últimos 17 meses (M5, 15/05/2025 a 16/10/2026, 369 dias), entrada exata às 04:20, 20 pts de spread:", bold=True, sz=18, after=40)
table(["Alvo", "% alvo", "Bateu / dias", "Min. mediana", "Min. p90", "Dias s/ alvo", "Perda média s/ alvo", "Pior dia", "Média/dia", "MAE médio"],
      [["100", "97,6%", "360/369", "5", "30", "9", "-4.826", "-11.578", "-20", "-593"],
       ["200", "95,7%", "353/369", "5", "83", "16", "-5.079", "-11.578", "-29", "-836"],
       ["300", "94,9%", "350/369", "10", "166", "19", "-5.060", "-11.578", "+24", "-988"],
       ["400", "93,0%", "343/369", "15", "280", "26", "-4.968", "-17.190", "+22", "-1.210"],
       ["500", "89,7%", "331/369", "25", "345", "38", "-4.755", "-18.085", "-41", "-1.464"],
       ["700", "84,0%", "310/369", "40", "377", "59", "-4.238", "-18.085", "-90", "-1.774"],
       ["1000", "79,4%", "293/369", "85", "704", "76", "-4.442", "-18.085", "-121", "-2.230"]], sz=14, align_right_from=1)
para("Dias SEM bater 300 pts nesta janela (resultado em pts às 23:30): 29/05/25 (-7.018), 30/06/25 (-3.512), 11/07/25 (-2.832), 15/08/25 (-247), 01/09/25 (-3.669), 12/09/25 (-315), 06/10/25 (-5.559), 08/10/25 (-5.644), 22/12/25 (-6.817), 05/01/26 (-5.134), 20/01/26 (-9.244), 18/02/26 (-8.508), 10/03/26 (-4.444), 27/03/26 (-11.578), 06/05/26 (-7.516), 15/06/26 (-1.996), 09/09/26 (-2.889), 29/09/26 (-5.189), 09/10/26 (-4.030).", sz=17, after=80)
para("No período todo (682 dias, M15) a mesma venda, alvo 300:", bold=True, sz=18, after=40)
tabx(ALL[(ALL.lado == "V") & (ALL.alvo == 300) & (ALL.slot.isin(["04:00", "04:15", "04:30", "04:45"]))].sort_values("slot"))
note("Conclusão: a venda às 04:20 funciona na janela recente, mas no período de 682 dias bate só 85 a 87% e a média é negativa. Ela depende do regime dos últimos 17 meses.")

h1("5. Compra x venda e regime")
sub = []
for nome, a, b in (("23/01/2024 a 14/05/2025", None, "2025-05-15"), ("15/05/2025 a 16/10/2026", "2025-05-15", None)):
    x = RAW[RAW["T"] == 300]
    if a:
        x = x[x.d >= a]
    if b:
        x = x[x.d < b]
    g = x[x.slot < "12:00"].groupby(["slot", "side"]).hit.mean().reset_index()
    sub.append([nome, fmt(x.d.nunique()), fmt(100 * g[g.side == "V"].hit.mean(), 1, True), fmt(100 * g[g.side == "C"].hit.mean(), 1, True)])
table(["Período", "Dias", "% alvo médio VENDA (entradas 00-12h, alvo 300)", "% alvo médio COMPRA (entradas 00-12h, alvo 300)"], sub, weights=[4, 2, 5, 5], sz=14, align_right_from=1)
note("A compra bate mais que a venda em quase todo horário porque o ouro subiu muito no período. Parte da vantagem da compra pode ser a tendência de alta e não o horário.")

h1("6. Dias sem alvo dos melhores horários (para conferir no gráfico)")
for slot, lado, T in (("01:00", "C", 300), ("01:15", "C", 300), ("01:00", "C", 200), ("09:45", "C", 200)):
    base = RAW[(RAW.slot == slot) & (RAW.side == lado) & (RAW["T"] == T)]
    x = base[~base.hit]
    h3(f"{slot} {'COMPRA' if lado == 'C' else 'VENDA'} · alvo {T} pts · {len(x)} dias sem alvo de {len(base)}")
    para("; ".join(f"{d.strftime('%d/%m/%y')} ({v:+,.0f})".replace(",", ".") for d, v in zip(x.d, x.res)), sz=16, after=60)

h1("7. Conversão de horários (exemplo)")
note("Servidor = UTC+3 durante o horário de verão dos EUA (segunda semana de março a primeira semana de novembro) e UTC+2 no resto do ano. Local = Brasília (UTC-3, sem horário de verão): servidor -6h no verão dos EUA e -5h no inverno. Londres = servidor -2h o ano todo (nas 2 a 3 semanas em que EUA e Europa mudam em datas diferentes, a diferença é de 1h). NY = servidor -7h. Em 2026 a mudança do servidor para UTC+2 é em 01/11/2026.")
ex = ["01:00", "01:15", "04:20", "06:00", "09:45", "11:45", "12:00", "14:00", "23:30"]
table(["Servidor", "Brasília (servidor UTC+3, mar-nov)", "Brasília (servidor UTC+2, nov-mar)", "Londres", "Nova York"],
      [[s, hm_add(s, -6), hm_add(s, -5), hm_add(s, -2), hm_add(s, -7)] for s in ex], weights=[3, 4, 4, 3, 3], sz=16, align_right_from=1)

h1("8. Limites e avisos")
for t in [
    "Resultado retrospectivo (2024 a 2026), sem comissão, slippage e swap; spread fixo de 20 pts (o spread real varia por horário e é maior na abertura asiática).",
    "Sem stop: um dia sem alvo perde em média 2.500 a 5.000 pts e o pior dia chega a -10.900 a -18.100 pts. O ganho de cada acerto é só o alvo (200 a 500 pts).",
    "Entrada na abertura da vela M15: a execução real dentro da vela pode diferir. A saída por alvo assume execução no preço do alvo.",
    "680 combinações testadas: parte dos 'bons' horários é acaso. Validação = últimos 40% dos dias (de 11/09/2025 a 16/10/2026), fora da amostra de descoberta, mas é um único período e o ouro estava em alta.",
    "Os dados completos (680 linhas) estão em docs/relatorios/mba/xau_horarios/xau_horarios_todos.csv.",
]:
    bullet(t)

page_break()
h1("Anexo — todas as 680 combinações")
note("Ordenadas por horário, lado e alvo.")
for lado, nome in (("C", "COMPRA"), ("V", "VENDA")):
    h2(nome)
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
<w:ftr {NS}><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t xml:space="preserve">XAUUSD — tabela · página </w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'''

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
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>XAUUSD — tabela completa</dc:title><dc:creator>MarketBehaviorAnalyzer</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-10-18T12:00:00Z</dcterms:created></cp:coreProperties>'''

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
