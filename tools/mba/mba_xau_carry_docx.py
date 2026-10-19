#!/usr/bin/env python3
"""Builds a Word (.docx) with ALL the MBA tables (no third-party libraries: raw OOXML via zipfile).

  python tools/mba/mba_docx.py docs/relatorios/XAUUSD-MANTER-APOS-2330-2026-10-18.docx
"""
import os, re, sys, zipfile
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/XAUUSD-MANTER-APOS-2330-2026-10-18.docx"
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


# ---- XAUUSD: o que acontece se a posição for mantida depois das 23:30 ----
OD = "docs/relatorios/mba/xau_horarios/"
CF = pd.read_csv(OD + "carry_falhas.csv")
CE = pd.read_csv(OD + "carry_exposicao.csv")
COMBOS = [("01:00", 200), ("01:00", 300), ("01:00", 400), ("01:15", 300), ("01:15", 400), ("06:00", 200), ("09:45", 200), ("12:00", 300), ("12:15", 300), ("18:30", 200)]
CF["ano"] = pd.to_datetime(CF.data).dt.year


def lbl(s, t):
    return f"{s} · alvo {t}"


def d8(x):
    return pd.to_datetime(x).strftime("%d/%m/%y")


para("XAUUSD — e se a posição for mantida depois das 23:30?", style="Title", after=120)
para("Compra, 10 horários estáveis · Raw Trading (IC Markets) · M15 · 23/01/2024 a 16/10/2026 · horários do servidor", after=120)

h1("1. Regra e como ler")
for t in [
    "Universo: as operações que NÃO bateram o alvo até as 23:30 (498 no total nos 10 horários). Em vez de fechar às 23:30, a posição segue aberta, sem stop, até o alvo ser atingido ou os dados acabarem em 16/10/2026.",
    "O alvo é o mesmo de antes: entrada + alvo + 20 pts de spread no fechamento. 'Horas após 23:30' é contado do início da vela das 23:30 até a vela em que o alvo foi tocado.",
    "'Drawdown até o alvo' (MAE) = o quanto o preço andou contra a posição, em pts, desde a entrada até o alvo (ou até hoje, para as que seguem abertas). 1 ponto = 0,01 de preço; 1 lote = 100 onças.",
    "Swap, comissão e slippage NÃO estão incluídos. Veja a seção 6.",
    "Tudo é retrospectivo e vale para o período 2024 a 2026, em que o ouro subiu na maior parte do tempo.",
]:
    bullet(t)

h1("2. Quantas bateram depois das 23:30 (acumulado)")
rows = []
for s, t in COMBOS:
    x = CF[(CF.slot == s) & (CF.alvo == t)]
    h = x.horas_apos_2330
    def c(lim):
        n = int((h <= lim).sum()); return f"{n} ({100 * n / len(x):.0f}%)"
    rows.append([lbl(s, t), fmt(len(x)), c(3), c(6), c(12), c(24), c(48), c(120), c(240), f"{int(x.bateu_dps.sum())} ({100 * x.bateu_dps.mean():.0f}%)", fmt((~x.bateu_dps).sum()), fmt(x.horas_apos_2330.median(), 1)])
table(["Horário · alvo", "Sem alvo às 23:30", "Até 3h", "Até 6h", "Até 12h", "Até 24h", "Até 48h", "Até 5 dias", "Até 10 dias", "Bateram depois (total)", "Nunca bateram", "Mediana (horas)"], rows, weights=[4, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3], sz=12, align_right_from=1)
note("'Nunca bateram' = ainda abertas em 16/10/2026. Das 9 que nunca bateram, 8 entraram entre agosto e setembro de 2026 (menos de 60 dias de espera) e 1 entrou em 21/04/2026 (06:00 · alvo 200, aberta há 178 dias).")

h1("3. Em que faixa de tempo bateram (não acumulado)")
O = pd.read_csv(OD + "carry_faixas.csv")
cols = ["até 1h", "1–3h", "3–6h", "6–12h", "12–24h", "1–2 dias", "2–5 dias", "5–10 dias", "10–30 dias", ">30 dias", "nunca (até 16/10/26)"]
rows = [[lbl(r_["slot"], r_["alvo"]), fmt(r_["falhas"])] + [fmt(r_[c]) for c in cols] for _, r_ in O.iterrows()]
table(["Horário · alvo", "Falhas"] + cols, rows, weights=[4, 2] + [2.5] * 11, sz=12, align_right_from=1)
note("Cada operação aparece em uma única faixa: a do momento em que o alvo foi tocado.")

h1("4. O que se sofre enquanto se espera (drawdown até o alvo)")
rows = []
for s, t in COMBOS:
    x = CF[(CF.slot == s) & (CF.alvo == t)]
    b = x[x.bateu_dps]
    rows.append([lbl(s, t), fmt(b.mae_ate_alvo.median()), fmt(b.mae_ate_alvo.quantile(0.25)), fmt(b.mae_ate_alvo.quantile(0.10)), fmt(b.mae_ate_alvo.min()),
                 fmt(b.dias_corridos.median(), 1), fmt(b.dias_corridos.quantile(0.9), 1), fmt(b.dias_corridos.max(), 0)])
table(["Horário · alvo", "Drawdown mediano", "Pior 25%", "Pior 10%", "Pior caso", "Dias até o alvo (mediana)", "Dias (90%)", "Dias (máximo)"], rows, weights=[4, 3, 3, 3, 3, 3, 3, 3], sz=13, align_right_from=1)
para("Por ano de entrada (todos os horários juntos):", bold=True, sz=18, after=40)
rows = []
for a, x in CF.groupby("ano"):
    b = x[x.bateu_dps]
    rows.append([str(a), fmt(len(x)), fmt(b.horas_apos_2330.median(), 0), fmt(b.mae_ate_alvo.median()), fmt(b.mae_ate_alvo.quantile(0.10)), fmt((~x.bateu_dps).sum())])
table(["Ano da entrada", "Falhas", "Mediana (horas após 23:30)", "Drawdown mediano", "Pior 10%", "Ainda abertas"], rows, weights=[3, 3, 4, 4, 4, 3], sz=14, align_right_from=1)
note("2026 tem poucas operações resolvidas por causa das que ainda estão abertas, o que subestima o risco: o drawdown das abertas seria pior se a espera continuasse.")

h1("5. Exposição acumulada (uma entrada por dia, todas mantidas até o alvo)")
rows = [[lbl(r_.slot, r_.alvo), fmt(r_.max_abertas), d8(r_.data_max_abertas), fmt(r_.pior_flut_pts), d8(r_.data_pior_flut), fmt(r_.abertas_no_pior), fmt(r_.abertas_no_fim), fmt(r_.flut_fim_pts)] for r_ in CE.itertuples()]
table(["Horário · alvo", "Máx. posições abertas ao mesmo tempo", "Quando", "Pior flutuante somado (pts)", "Quando", "Posições abertas nesse momento", "Abertas em 16/10/26", "Flutuante delas em 16/10/26"], rows, weights=[4, 4, 3, 4, 3, 4, 3, 4], sz=12, align_right_from=1)
note("Flutuante somado = soma, em pts, das perdas de todas as posições abertas no pior candle (lote igual para todas; usa a mínima de cada vela). Com 1 lote (100 onças), 1 pt vale US$ 1,00, então -79.690 pts equivalem a -US$ 79.690 para as posições somadas.")

h1("6. Custo de esperar: swap")
for t in [
    "A especificação do símbolo na IC (arquivo META do MBA) mostra swap de compra = -55,484 (modo pontos) por noite por lote. Em compra, cada noite em aberto custa cerca de 55 pts; a quarta-feira costuma cobrar 3 noites (regra a confirmar na corretora).",
    "A espera mediana de 2,5 a 3,5 dias (horários da madrugada) equivale a aproximadamente 3 noites: cerca de 165 a 220 pts, quase todo o valor de um alvo de 200 pts.",
    "Nos horários 18:30, 09:45 e 12:xx a espera mediana é menor (12 a 37 horas), com 1 a 2 noites de swap.",
    "O spread no virar do dia (00:00 do servidor) costuma ser maior; isso não foi medido aqui.",
]:
    bullet(t)

h1("7. O que ficou aberto até hoje (16/10/2026)")
nv = CF[~CF.bateu_dps].sort_values("data")
rows = [[lbl(r_.slot, r_.alvo), d8(r_.data), fmt(r_.recente), fmt(r_.mae_ate_alvo), fmt(r_.flutuante_fim)] for r_ in nv.itertuples()]
table(["Horário · alvo", "Data de entrada", "Dias aberta", "Pior drawdown até hoje (pts)", "Flutuante hoje (pts)"], rows, weights=[4, 3, 3, 4, 4], sz=14, align_right_from=1)

h1("8. Conclusões e cuidados")
for t in [
    "Das 498 operações sem alvo às 23:30, 489 (98%) bateram o alvo depois; 9 seguem abertas. Mas só 39% (195 de 498) bateram em até 24 horas, e nos horários da madrugada a mediana é de 2,5 a 3,5 dias.",
    "Esperar converte a perda de -1.100 a -4.100 pts das 23:30 em uma espera com drawdown de -2.000 a -7.000 pts (mediana), -12.000 a -17.000 no pior 10% e -54.000 no pior caso observado.",
    "O resultado de 98% depende do período: o ouro subiu na maior parte de 2024 a 2026. Em um mercado de queda prolongada a posição pode não voltar. Em 2026 já há 8 operações abertas há semanas.",
    "Sem stop, o risco está no tamanho: com várias posições abertas ao mesmo tempo (até 6) o flutuante somado chegou a -79.690 pts (01:00 · 300) e -133.248 pts (06:00 · 200). Dimensione o lote pensando no flutuante somado, não em uma posição.",
    "O swap negativo e o spread do virar do dia reduzem o ganho de manter a posição.",
]:
    bullet(t)

h1("9. Detalhe: quando cada operação sem alvo bateu")
note("Data = dia da entrada. Bateu em = data e hora do servidor em que o alvo foi tocado (vazio = ainda aberta). Horas = horas após 23:30. Dias = dias corridos desde a entrada. Drawdown = pior ponto contra a posição até o alvo (ou até hoje).")
for s, t in COMBOS:
    f = CF[(CF.slot == s) & (CF.alvo == t)].sort_values("data")
    h2(f"{s} · alvo {t} · {len(f)} operações sem alvo às 23:30")
    rows = [[d8(r_.data), (pd.to_datetime(r_.quando).strftime("%d/%m/%y %H:%M") if r_.bateu_dps else "aberta"), fmt(r_.horas_apos_2330, 1), fmt(r_.dias_corridos, 1), fmt(r_.mae_ate_alvo), fmt(r_.flutuante_fim)] for r_ in f.itertuples()]
    table(["Data", "Bateu em", "Horas após 23:30", "Dias corridos", "Drawdown até o alvo (pts)", "Flutuante em 16/10/26"], rows, weights=[3, 4, 3, 3, 4, 4], sz=12, align_right_from=2)


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
<w:ftr {NS}><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t xml:space="preserve">XAUUSD — manter após 23:30 · página </w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'''

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
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>XAUUSD — manter após 23:30</dc:title><dc:creator>MarketBehaviorAnalyzer</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-10-18T12:00:00Z</dcterms:created></cp:coreProperties>'''

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
