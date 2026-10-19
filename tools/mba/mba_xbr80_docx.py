#!/usr/bin/env python3
"""Builds a Word (.docx) with ALL the MBA tables (no third-party libraries: raw OOXML via zipfile).

  python tools/mba/mba_docx.py docs/relatorios/XBRUSD-ALVO-80-2026-10-18.docx
"""
import os, re, sys, zipfile
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/XBRUSD-ALVO-80-2026-10-18.docx"
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


# ---- XBRUSD: só as combinações com alvo atingido em 80% ou mais dos dias ----
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


H80 = ALL[ALL.pct >= 80]
POS = H80[(H80.media_desc > 0) & (H80.media_val > 0)].sort_values("media", ascending=False)
ANOS = POS[POS.todos_anos_pos]
ROB = ANOS[ANOS.wilson > ANOS.nec]

para("XBRUSD (Brent) — combinações com alvo atingido em 80% ou mais dos dias", style="Title", after=120)
para("Filtro sobre a varredura completa · Raw Trading (IC Markets) · M15 · 23/01/2024 a 16/10/2026 (687 dias úteis) · horários do servidor · alvo ou 23:30, sem stop", after=120)

h1("1. Como o filtro foi feito")
for t in [
    "Partimos das 924 combinações horário x lado x alvo da varredura completa do XBRUSD e ficamos com as que atingiram o alvo em 80% ou mais dos dias (coluna % alvo). Deram 386 combinações, todas com alvos de 100 a 300 pts (os alvos de 400 e 500 pts nunca chegam a 80%).",
    "Dessas 386, só 76 têm média por dia positiva no período todo, 22 são positivas na descoberta (primeiros 60% dos dias) E na validação (últimos 40%), 6 também são positivas em cada um dos 3 anos, e 2 são robustas (o limite inferior Wilson 95% da taxa de acerto é maior que o % necessário para empatar).",
    "A lista principal (seção 2) mostra as 22 positivas nos dois trechos. Combinações com 80%+ de acerto mas média negativa ficam de fora porque acertar muito não compensa a perda dos dias sem alvo (sem stop, essa perda é de -500 a -1.400 pts por dia).",
    "Custo: spread de 10 pts medido nos ticks (a compra paga na entrada; a venda, no fechamento). Comissão, slippage e swap NÃO incluídos. 1 pt = 0,001 de preço = US$ 0,10 por lote.",
    "% alvo = % dos dias em que o alvo foi atingido até as 23:30. Wilson 95% = limite inferior estatístico dessa taxa. Perda média s/ alvo = resultado médio dos dias em que o alvo não foi atingido (fechamento às 23:30). % p/ empatar = taxa de acerto necessária para a média zerar.",
]:
    bullet(t)

h1("2. As 22 combinações com 80%+ de acerto e média positiva nos dois trechos")
note("Ordenadas por média/dia. Marcadas na coluna 'Anos' com +++ as positivas em todos os anos. As 6 que passam também no filtro dos 3 anos estão na seção 3.")
tabx(POS)

h1("3. As mais sólidas: 80%+ de acerto e positivas em todos os anos (6)")
tabx(ANOS)
para("Entre estas, só 2 são robustas no teste mais duro (Wilson 95% > % necessário para empatar): " + "; ".join(f"{r_.slot} {r_.lado.lower()} alvo {r_.alvo}" for r_ in ROB.itertuples()) + ".", after=80)
note("A margem entre Wilson 95% e % p/ empatar é de 0,3 a 0,4 ponto percentual nessas duas, quase nada. As outras quatro têm Wilson abaixo do % necessário, ou seja, no cenário pessimista elas não pagam a perda dos dias sem alvo.")

h1("4. Quanto cada uma das 6 perde nos dias sem alvo")
rows = []
for r_ in ANOS.itertuples():
    s = SLOTS.index(r_.slot); ti = TGS.index(r_.alvo); sd = 0 if r_.lado == "COMPRA" else 1
    x = pd.Series(RAWR[:, s, sd, ti], index=DATES); h = pd.Series(RAWH[:, s, sd, ti], index=DATES)
    f = x[(~h) & x.notna()]
    rows.append([f"{r_.slot} {r_.lado.lower()} · {r_.alvo}", fmt(len(f)), fmt(f.mean()), fmt(f.median()), fmt(f.quantile(0.1)), fmt(f.min()), fmt((f > -r_.alvo).sum()) if False else fmt(100 * (f > 0).mean(), 0, True), fmt(r_.alvo), fmt(abs(f.mean()) / r_.alvo, 1)])
table(["Horário · alvo", "Dias sem alvo", "Perda média", "Mediana", "Pior 10%", "Pior dia", "Dias sem alvo que fecharam no lucro", "Ganho no acerto (pts)", "Acertos para pagar 1 falha"], rows, weights=[5, 3, 3, 3, 3, 3, 4, 3, 3], sz=14, align_right_from=1)
note("'Acertos para pagar 1 falha' = quantos acertos do alvo cobrem a perda média de um dia sem alvo. Com 85 a 93% de acerto, a conta fecha com folga pequena: é o motivo de a média por dia ficar entre +8 e +45 pts.")
for r_ in ANOS.itertuples():
    s = SLOTS.index(r_.slot); ti = TGS.index(r_.alvo); sd = 0 if r_.lado == "COMPRA" else 1
    x = pd.Series(RAWR[:, s, sd, ti], index=DATES); h = pd.Series(RAWH[:, s, sd, ti], index=DATES)
    f = x[(~h) & x.notna()]
    h3(f"{r_.slot} {r_.lado.lower()} · alvo {r_.alvo} · {len(f)} dias sem alvo")
    para("; ".join(f"{d.strftime('%d/%m/%y')} ({v:+,.0f})".replace(",", ".") for d, v in f.items()), sz=15, after=60)

h1("5. Estabilidade das 6")
rows = []
for r_ in ANOS.itertuples():
    s = SLOTS.index(r_.slot); ti = TGS.index(r_.alvo); sd = 0 if r_.lado == "COMPRA" else 1
    x = pd.Series(RAWR[:, s, sd, ti], index=DATES).dropna()
    ya = x.groupby(x.index.year).mean(); q = x.groupby(x.index.to_period("Q")).mean()
    sem = x[~x.index.to_period("M").isin(x.groupby(x.index.to_period("M")).mean().nlargest(3).index)].mean()
    wd = x.groupby(x.index.dayofweek).mean()
    rows.append([f"{r_.slot} {r_.lado.lower()} · {r_.alvo}", fmt(x.mean()), fmt(ya.get(2024)), fmt(ya.get(2025)), fmt(ya.get(2026)), fmt(sem), f"{int((q > 0).sum())}/{len(q)}", " ".join(fmt(wd[i]) for i in range(5))])
table(["Horário · alvo", "Média/dia", "2024", "2025", "2026", "Média sem os 3 melhores meses", "Trimestres positivos", "Média seg · ter · qua · qui · sex"], rows, weights=[5, 3, 3, 3, 3, 4, 3, 7], sz=14, align_right_from=1)

h1("6. Comissão: o que sobra")
rows = []
for com in (0, 10, 20, 30, 50, 70):
    rows.append([f"{com} pts (US$ {com * 0.1:.2f} por lote)".replace(".", ","), fmt(((POS.media - com) > 0).sum()), fmt(((ANOS.media - com) > 0).sum()), fmt((POS.media - com).max()), fmt((POS.media - com).median())])
table(["Comissão por operação", "Das 22: média > 0", "Das 6: média > 0", "Melhor média/dia (22)", "Mediana (22)"], rows, weights=[5, 3, 3, 3, 3], sz=15, align_right_from=1)
note("As médias são de +2 a +45 pts por dia (US$ 0,20 a 4,50 por lote). Uma comissão de 20 a 30 pts por operação elimina a maior parte delas; confira a comissão real da sua conta. Só a combinação 12:00 compra alvo 300 (+45) sobrevive a 30 pts.")

h1("7. Conversão de horários (exemplo)")
note("Servidor = UTC+3 durante o horário de verão dos EUA (segunda semana de março a primeira semana de novembro) e UTC+2 no resto do ano. Local = Brasília (UTC-3): servidor -6h no verão dos EUA e -5h no inverno. Londres = servidor -2h o ano todo. NY = servidor -7h. A mudança do servidor para UTC+2 em 2026 é em 01/11/2026.")
ex = sorted(set(ANOS.slot) | {"23:30"})
table(["Servidor", "Brasília (servidor UTC+3, mar-nov)", "Brasília (servidor UTC+2, nov-mar)", "Londres", "Nova York"],
      [[s, hm_add(s, -6), hm_add(s, -5), hm_add(s, -2), hm_add(s, -7)] for s in ex], weights=[3, 4, 4, 3, 3], sz=16, align_right_from=1)

h1("8. Limites e avisos")
for t in [
    "Resultado retrospectivo (2024 a 2026), sem comissão, slippage e swap. O spread de 10 pts foi medido em só 2 semanas de ticks brutos; no histórico o spread real pode ter sido maior.",
    "Foram testadas 924 combinações. No placebo (horários embaralhados dentro do dia) a média de combinações que passam o filtro dos 3 anos é de 35 contra 51 reais, então parte dos achados é acaso. O filtro Wilson reduz isso, mas não elimina.",
    "Sem stop: dias sem alvo perdem em média -500 a -1.400 pts e o pior dia das 6 mais sólidas vai de -2.800 a -7.300 pts, vários múltiplos do alvo de 100 a 300 pts.",
    "Os 80% de acerto valem para o período todo; na validação (últimos 40% dos dias) alguns subiram e outros caíram, veja % desc. e % valid.",
    "Dados completos: docs/relatorios/mba/scan_all/XBRUSD_todos.csv (924 linhas).",
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
<w:ftr {NS}><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t xml:space="preserve">XBRUSD — alvo 80%+ · página </w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'''

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
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>XBRUSD — alvo 80%+</dc:title><dc:creator>MarketBehaviorAnalyzer</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-10-18T12:00:00Z</dcterms:created></cp:coreProperties>'''

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
