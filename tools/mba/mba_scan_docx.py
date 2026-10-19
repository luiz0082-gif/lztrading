#!/usr/bin/env python3
"""Builds a Word (.docx) with ALL the MBA tables (no third-party libraries: raw OOXML via zipfile).

  python tools/mba/mba_docx.py docs/relatorios/SCAN.docx
"""
import os, re, sys, zipfile
import numpy as np
SYM = os.environ["MBA_SYM"]
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/SCAN.docx"
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


# ---- varredura intraday completa de um ativo (corpo genérico; SYM vem do ambiente) ----
import json as _json
OD = "docs/relatorios/mba/scan_all/"
ALL = pd.read_csv(OD + f"{SYM}_todos.csv")
SUM = _json.load(open(OD + f"{SYM}_resumo.json"))
Z = np.load(OD + f"{SYM}_raw.npz", allow_pickle=True)
RAWR = Z["RES"]; RAWH = Z["HIT"]; DATES = pd.to_datetime(Z["dates"]); SLOTS = list(Z["slots"]); TGS = list(Z["targets"])
PTV = SUM["point"]; SPR = SUM["spread"]
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


def series(r_):
    s = SLOTS.index(r_.slot); ti = TGS.index(r_.alvo); sd = 0 if r_.lado == "COMPRA" else 1
    return pd.Series(RAWR[:, s, sd, ti], index=DATES), pd.Series(RAWH[:, s, sd, ti], index=DATES)


DOIS = ALL[(ALL.media_desc > 0) & (ALL.media_val > 0)]
PASS = DOIS[DOIS.todos_anos_pos]
ROB = PASS[PASS.wilson > PASS.nec].sort_values("media", ascending=False)
H80 = ALL[ALL.pct >= 80]
P80 = H80[(H80.media_desc > 0) & (H80.media_val > 0)].sort_values("media", ascending=False)
A80 = P80[P80.todos_anos_pos]
R80 = A80[A80.wilson > A80.nec]
USD_PT = SUM.get('usd_pt', PTV * 100)            # US$ por ponto por lote
CONTR = SUM.get('contract', 100.0); UNID = {'XTIUSD': 'barris', 'XBRUSD': 'barris', 'XAGUSD': 'onças', 'XAUUSD': 'onças'}.get(SYM, '')
DESC = {"XTIUSD": "WTI, petróleo americano", "XBRUSD": "Brent", "XAGUSD": "prata", "USTEC": "Nasdaq 100", "US500": "S&P 500", "US30": "Dow Jones", "DE40": "DAX"}.get(SYM, SYM)

para(f"{SYM} ({DESC}) — padrões intraday por horário (alvo ou 23:30, sem stop)", style="Title", after=120)
para(f"Tabela completa · Raw Trading (IC Markets) · M15 · {pd.to_datetime(SUM['ini']).strftime('%d/%m/%Y')} a {pd.to_datetime(SUM['fim']).strftime('%d/%m/%Y')} ({SUM['dias']} dias úteis) · horários do servidor", after=120)

h1("1. Regra e como ler")
for t in [
    "Entrada na abertura da vela M15 do horário (hora do servidor). Sai quando o preço atinge o alvo a favor ou às 23:30 do servidor (fechamento da vela 23:15). Sem stop; 1 operação por dia útil por horário. Cada combinação é horário x lado x alvo.",
    f"Varredura: horários de 15 em 15 min (00:00 a 22:00) x 2 lados x {len(TGS)} alvos ({', '.join(str(x) for x in TGS)} pts); {SUM['combos']} combinações com dados suficientes. 1 ponto = {fmt(PTV, 3)} de preço = US$ {fmt(USD_PT, 2)} por lote" + (f" (contrato de {fmt(CONTR)} {UNID})" if UNID else "") + f". Alvos em preço: " + ", ".join(f"{t} pts = {fmt(t * PTV, 2)}" for t in TGS) + f". O ATR M15 mediano é de {fmt(SUM['atr'])} pts.",
    f"Custo: spread medido nos ticks ({fmt(SPR)} pts = US$ {fmt(SPR * USD_PT, 2)} por lote, constante ao longo do dia). A compra paga o spread na entrada e a venda paga no fechamento. COMISSÃO NÃO ESTÁ INCLUÍDA (o MBA não consegue ler a comissão da conta); veja a seção 5. Slippage e swap também não.",
    "% alvo = % dos dias em que o alvo foi atingido. Wilson 95% = limite inferior estatístico dessa taxa. % desc. / % valid. = taxa nos primeiros 60% dos dias e nos últimos 40% (validação cronológica).",
    "Média/dia = resultado médio por operação em pts (já com o spread). Dias s/ alvo = dias em que o alvo não foi atingido e a operação fechou às 23:30; Perda média s/ alvo = resultado médio desses dias.",
    "% p/ empatar = taxa de acerto necessária para a média zerar, dada a perda média dos dias sem alvo. Se Wilson 95% > % p/ empatar, o horário tem lucro mesmo no cenário estatístico pessimista.",
    "MAE médio = quanto o preço andou contra a posição até o fechamento. Min. mediana = tempo mediano até o alvo. Anos 24/25/26 = sinal da média em cada ano.",
]:
    bullet(t)

h1("2. Resumo do que a varredura encontrou")
rows = [
    ["Combinações testadas", fmt(len(ALL))],
    ["Média > 0 no período todo", f"{int((ALL.media > 0).sum())} ({100 * (ALL.media > 0).mean():.0f}%)"],
    ["Média > 0 na descoberta E na validação", fmt(len(DOIS))],
    ["... e também positivas em cada um dos 3 anos", fmt(len(PASS))],
    ["... e com Wilson 95% > % necessário para empatar (robustas)", fmt(len(ROB))],
    ["Dessas robustas, quantas são COMPRA / VENDA", f"{int((ROB.lado == 'COMPRA').sum())} / {int((ROB.lado == 'VENDA').sum())}"],
    [f"Placebo ({SUM['placebos']} rodadas, horários embaralhados dentro do dia): robustas por acaso", f"média {fmt(SUM['pr_med'], 1)}; máximo {SUM['pr_max']}"],
    ["Placebo: positivas nos 2 trechos e nos 3 anos por acaso", f"média {fmt(SUM['pl_med'], 1)}; máximo {SUM['pl_max']} (real: {SUM['real']})"],
    ["Com alvo atingido em 80% ou mais dos dias", fmt(len(H80))],
    ["... dessas, positivas nos 2 trechos / também nos 3 anos / robustas", f"{len(P80)} / {len(A80)} / {len(R80)}"],
]
table(["Indicador", "Valor"], rows, weights=[10, 5], sz=16)
note(f"Leitura: as combinações robustas reais ({len(ROB)}) comparadas com o placebo (média {fmt(SUM['pr_med'], 1)}, máximo {SUM['pr_max']}) mostram se há sinal acima do acaso: " + ("há, " if len(ROB) > SUM['pr_max'] else "não há diferença clara, ") + "mas o tamanho do ganho por operação é pequeno (seção 5).")

h1(f"3. As {len(ROB)} combinações mais robustas")
note("Filtro: média > 0 na descoberta e na validação, positivas em todos os anos, e Wilson 95% maior que o % necessário para empatar. Ordenadas por média/dia. Horários vizinhos não são amostras independentes.")
tabx(ROB)

h1("4. Só as combinações com alvo atingido em 80% ou mais dos dias")
for t in [
    f"Partindo das {len(ALL)} combinações: {len(H80)} atingem o alvo em 80%+ dos dias (todas com alvos de {min(H80.alvo) if len(H80) else '-'} a {max(H80.alvo) if len(H80) else '-'} pts). Dessas, {int((H80.media > 0).sum())} têm média positiva, {len(P80)} são positivas nos dois trechos, {len(A80)} também nos 3 anos e {len(R80)} são robustas.",
    "Acertar 80% ou mais não basta: sem stop, os dias sem alvo perdem várias vezes o alvo. Por isso a lista abaixo exige média positiva nos dois trechos.",
]:
    bullet(t)
para(f"4.1 {len(P80)} combinações com 80%+ de acerto e média positiva nos dois trechos", bold=True, sz=18, after=40)
if len(P80):
    tabx(P80)
para(f"4.2 As mais sólidas: 80%+ de acerto e positivas em todos os anos ({len(A80)})", bold=True, sz=18, after=40)
if len(A80):
    tabx(A80)
    para("Robustas entre elas: " + ("; ".join(f"{r_.slot} {r_.lado.lower()} alvo {r_.alvo}" for r_ in R80.itertuples()) if len(R80) else "nenhuma") + ".", after=60)
    para("Dias sem alvo e perda:", bold=True, sz=18, after=40)
    rows = []
    for r_ in A80.itertuples():
        x, h = series(r_); f = x[(~h) & x.notna()]
        rows.append([f"{r_.slot} {r_.lado.lower()} · {r_.alvo}", fmt(len(f)), fmt(f.mean()), fmt(f.quantile(0.1)), fmt(f.min()), fmt(100 * (f > 0).mean(), 0, True), fmt(abs(f.mean()) / r_.alvo, 1)])
    table(["Horário · alvo", "Dias sem alvo", "Perda média", "Pior 10%", "Pior dia", "Dias sem alvo que fecharam no lucro", "Acertos para pagar 1 falha"], rows, weights=[5, 3, 3, 3, 3, 5, 4], sz=14, align_right_from=1)
    for r_ in A80.itertuples():
        x, h = series(r_); f = x[(~h) & x.notna()]
        h3(f"{r_.slot} {r_.lado.lower()} · alvo {r_.alvo} · {len(f)} dias sem alvo")
        para("; ".join(f"{d.strftime('%d/%m/%y')} ({v:+,.0f})".replace(",", ".") for d, v in f.items()), sz=15, after=60)
else:
    para("Nenhuma combinação com 80%+ e positiva em todos os anos.", after=60)

h1("5. Estabilidade das 8 melhores robustas e efeito da comissão")
rows = []
for r_ in ROB.head(8).itertuples():
    x, _ = series(r_); x = x.dropna()
    ya = x.groupby(x.index.year).mean(); q = x.groupby(x.index.to_period("Q")).mean()
    sem = x[~x.index.to_period("M").isin(x.groupby(x.index.to_period("M")).mean().nlargest(3).index)].mean()
    wd = x.groupby(x.index.dayofweek).mean()
    rows.append([f"{r_.slot} {r_.lado.lower()} · {r_.alvo}", fmt(x.mean()), fmt(ya.get(2024)), fmt(ya.get(2025)), fmt(ya.get(2026)), fmt(sem), f"{int((q > 0).sum())}/{len(q)}", " ".join(fmt(wd[i]) for i in range(5))])
if rows:
    table(["Horário · alvo", "Média/dia", "2024", "2025", "2026", "Média sem os 3 melhores meses", "Trimestres positivos", "Média seg · ter · qua · qui · sex"], rows, weights=[5, 3, 3, 3, 3, 4, 3, 7], sz=14, align_right_from=1)
rows = []
for com in (0, 10, 20, 30, 50, 70):
    rows.append([f"{com} pts (US$ {fmt(com * USD_PT, 2)} por lote)", fmt(((ROB.media_desc - com > 0) & (ROB.media_val - com > 0)).sum()), fmt(((ROB.media - com) > 0).sum()), fmt((ROB.media - com).max()) if len(ROB) else "", fmt((ROB.media - com).median()) if len(ROB) else ""])
para("Comissão por operação (aplicada às robustas):", bold=True, sz=18, after=40)
table(["Comissão", "Robustas positivas nos 2 trechos", "Robustas com média > 0", "Melhor média/dia", "Mediana das médias"], rows, weights=[5, 5, 4, 3, 3], sz=15, align_right_from=1)
note(f"A comissão real da conta não foi lida pelo MBA; confira a sua. A média das robustas é de {fmt(ROB.media.min())} a {fmt(ROB.media.max())} pts por dia (US$ {fmt(ROB.media.min() * USD_PT, 1)} a {fmt(ROB.media.max() * USD_PT, 1)} por lote). Uma comissão de 30 a 70 pts elimina a maior parte do resultado." if len(ROB) else "")

h1("6. Combinações positivas nos dois trechos")
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
nv = DOIS[DOIS.lado == "VENDA"]
para(f"Vendas positivas nos dois trechos: {len(nv)} de {int((ALL.lado == 'VENDA').sum())}; vendas robustas: {int((ROB.lado == 'VENDA').sum())}.", after=80)

h1("8. Conversão de horários (exemplo)")
note("Servidor = UTC+3 durante o horário de verão dos EUA (segunda semana de março a primeira semana de novembro) e UTC+2 no resto do ano. Local = Brasília (UTC-3): servidor -6h no verão dos EUA e -5h no inverno. Londres = servidor -2h o ano todo. NY = servidor -7h. A mudança do servidor para UTC+2 em 2026 é em 01/11/2026.")
ex = sorted(set(ROB.head(10).slot) | set(A80.slot) | {"23:30"})
table(["Servidor", "Brasília (servidor UTC+3, mar-nov)", "Brasília (servidor UTC+2, nov-mar)", "Londres", "Nova York"],
      [[s, hm_add(s, -6), hm_add(s, -5), hm_add(s, -2), hm_add(s, -7)] for s in ex], weights=[3, 4, 4, 3, 3], sz=16, align_right_from=1)
note("Referências: 15:30 do servidor = 08:30 em Nova York (dados dos EUA); 16:30 = 09:30 (abertura das ações dos EUA); 10:00 e 17:00 do servidor = 03:00 e 10:00 em Nova York; 17:30 = 10:30 em Nova York (estoques de petróleo, quartas); 17:00 do servidor = 10:00 em Nova York; 18:00 do servidor = 16:00 em Londres (fixing de metais da tarde, 15:00 em Londres = 17:00 do servidor).")

h1("9. Limites e avisos")
for t in [
    f"Resultado retrospectivo, sem comissão, slippage e swap. O spread de {fmt(SPR)} pts foi medido nos ticks recentes (só cerca de 2 semanas de ticks brutos disponíveis); no histórico o spread real pode ter sido maior.",
    ("Mercado com fechamento antes das 23:30: nos dias em que a última vela é anterior a 23:15, a operação sai no fechamento da última vela do dia (a partir de " + SUM.get("min_last", "23:15") + "). Dias com sessão mais curta que isso foram descartados." if SUM.get("min_last", "23:15") != "23:15" else "Saída às 23:30 do servidor em todos os dias."),
    "Entrada na abertura da vela M15; a execução real dentro da vela pode diferir. A saída por alvo assume execução no preço do alvo.",
    f"Foram testadas {len(ALL)} combinações. O placebo e o filtro Wilson reduzem o risco de achados ao acaso, mas não o eliminam.",
    "Sem stop: os dias sem alvo perdem várias vezes o valor do alvo. A espera depois das 23:30 não foi analisada.",
    f"Os dados completos ({len(ALL)} linhas) estão em docs/relatorios/mba/scan_all/{SYM}_todos.csv.",
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
<w:ftr {NS}><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t xml:space="preserve">tabela de padrões · página </w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'''

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
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>Tabela completa</dc:title><dc:creator>MarketBehaviorAnalyzer</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-10-18T12:00:00Z</dcterms:created></cp:coreProperties>'''

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
