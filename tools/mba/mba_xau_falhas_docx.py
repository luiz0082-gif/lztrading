#!/usr/bin/env python3
"""Builds a Word (.docx) with ALL the MBA tables (no third-party libraries: raw OOXML via zipfile).

  python tools/mba/mba_docx.py docs/relatorios/XAUUSD-DIAS-SEM-ALVO-2026-10-18.docx
"""
import os, re, sys, zipfile
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "docs/relatorios/XAUUSD-DIAS-SEM-ALVO-2026-10-18.docx"
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


# ---- XAUUSD: catálogo de dias sem alvo (corpo do documento) ----
OD = "docs/relatorios/mba/xau_horarios/"
DA = pd.read_pickle(OD + "falhas_todos.pkl")
SQ = pd.read_csv(OD + "falhas_sequencia.csv")
FA = DA[~DA.hit].copy()
COMBOS = [("01:00", 200), ("01:00", 300), ("01:00", 400), ("01:15", 300), ("01:15", 400), ("06:00", 200), ("09:45", 200), ("12:00", 300), ("12:15", 300), ("18:30", 200)]
CEN = sorted(FA.cen.unique())
CEN_SHORT = {c: c[0] for c in CEN}


def lbl(s, t):
    return f"{s} · alvo {t}"


def d8(x):
    return x.strftime("%d/%m/%y")


para("XAUUSD — o que já aconteceu nos dias sem alvo", style="Title", after=120)
para("Compra, alvo ou 23:30 sem stop · Raw Trading (IC Markets) · M15 · 23/01/2024 a 16/10/2026 (682 dias úteis) · horários do servidor · só os 10 horários estáveis da tabela XAUUSD", after=120)

h1("1. Como usar")
for t in [
    "Cada linha responde: 'esse horário já falhou N vezes em 682 dias; quando falhou, foi de qual jeito?'. Assim você entra sabendo que o cenário já aconteceu.",
    "Falha = o alvo não foi atingido e a operação fechou às 23:30 (sem stop). Resultado em pts, já com 20 pts de spread.",
    "Cenário (como a queda aconteceu, em ordem de prioridade): A = o preço caiu 1.000 pts ou mais nas 2 primeiras horas após a entrada; B = a pior vela de 15 min foi de -800 pts ou mais e havia notícia USD de importância alta na janela de ±30 min; C = idem, mas sem notícia no calendário; D = queda gradual, sem vela forte.",
    "Quase bateu = o preço chegou a pelo menos 2/3 do alvo e depois reverteu. É independente do cenário.",
    "Notícias: só o calendário econômico dos EUA coletado pelo MBA (importância alta). Geopolítica e comentários fora da agenda não estão nos dados.",
    "Tudo é retrospectivo. Nada aqui garante que o que não aconteceu até hoje não vá acontecer.",
]:
    bullet(t)

h1("2. Quantas vezes falhou e como as falhas se distribuem")
rows = []
for s, t in COMBOS:
    q = SQ[(SQ.slot == s) & (SQ.alvo == t)].iloc[0]
    f = FA[(FA.slot == s) & (FA.alvo == t)]
    rows.append([lbl(s, t), fmt(q.falhas), fmt(q.dias), f"1 a cada {fmt(q.uma_a_cada, 1)}", fmt(q.perda_media), fmt(q.pior), fmt(q.reposicao, 1),
                 fmt(q.p_base, 1, True), fmt(q.p_falha_dia_seguinte, 1, True), fmt(q.max_seguidas), fmt(q.n_pares_consecutivos), fmt(q.intervalo_mediano, 0), fmt(q.intervalo_min),
                 f"{int(f.quase.sum())} ({100 * f.quase.mean():.0f}%)", fmt((f.prata <= -2).sum())])
table(["Horário · alvo", "Falhas", "Dias", "Frequência", "Perda média", "Pior dia", "Acertos p/ pagar 1 falha", "% falha (base)", "% falha no dia útil seguinte a uma falha", "Máx. falhas seguidas", "Vezes com 2+ seguidas", "Dias úteis entre falhas (mediana)", "Menor intervalo", "Quase bateu", "Prata caiu 2%+ no dia"],
      rows, weights=[5, 3, 3, 4, 4, 4, 4, 3, 5, 3, 3, 4, 3, 4, 3], sz=12, align_right_from=1)
note("'Acertos p/ pagar 1 falha' = quantos acertos do alvo são necessários para cobrir a perda média de uma falha. A falha no dia seguinte a uma falha é parecida com a base (exceto 18:30), ou seja, falhar hoje não aumenta a chance de falhar amanhã: as falhas não vêm em sequência, mas já houve falhas em dias úteis seguidos (até 3 no 01:15 e até 4 no 18:30).")

h1("3. Cenários: quantas vezes cada um já aconteceu")
rows = []
for s, t in COMBOS:
    f = FA[(FA.slot == s) & (FA.alvo == t)]
    rows.append([lbl(s, t), fmt(len(f))] + [fmt((f.cen == c).sum()) for c in CEN] + [fmt(f[f.cen == c].res.mean()) if (f.cen == c).any() else "" for c in CEN[:1]])
hdr = ["Horário · alvo", "Falhas"] + [c for c in CEN] + ["Perda média de A"]
table(hdr, rows, weights=[4, 2, 4, 4, 4, 4, 3], sz=12, align_right_from=1)
para("Perda média e pior caso por cenário (todos os 10 horários juntos, 498 falhas; datas repetidas entre horários contam em cada horário):", bold=True, sz=18, after=40)
rows = []
for c in CEN:
    x = FA[FA.cen == c]
    rows.append([c, fmt(len(x)), fmt(x.res.mean()), fmt(x.res.median()), fmt(x.res.min()), fmt(x.mfe.mean()), fmt(x.mae.mean()), fmt(100 * x.quase.mean(), 0, True), fmt(x.h_ate_min.median(), 1)])
table(["Cenário", "Ocorrências", "Resultado médio", "Mediana", "Pior", "Máxima a favor (média)", "MAE médio", "Quase bateu", "Horas até a mínima (mediana)"], rows, weights=[8, 3, 3, 3, 3, 3, 3, 3, 3], sz=13, align_right_from=1)
para("Os 5 piores dias de cada horário (data, resultado, cenário):", bold=True, sz=18, after=40)
rows = []
for s, t in COMBOS:
    f = FA[(FA.slot == s) & (FA.alvo == t)].sort_values("res").head(5)
    rows.append([lbl(s, t), "; ".join(f"{d8(r_.data)} ({fmt(r_.res)}, {r_.cen[0]})" for r_ in f.itertuples())])
table(["Horário · alvo", "Piores dias: data (resultado, cenário)"], rows, weights=[3, 14], sz=13)

h1("4. Em que ponto do dia a falha já aparece (checkpoints)")
note("Só entram as operações ainda abertas no checkpoint (o alvo ainda não foi atingido). 'Posição' = resultado marcado a mercado naquele momento. Serve para saber, enquanto a operação está aberta, quantas vezes situações parecidas terminaram sem alvo.")
rows = []
for s, t in COMBOS:
    if s >= "14:30":
        continue
    x = DA[(DA.slot == s) & (DA.alvo == t) & (DA.bateu_antes15 == False)]
    row = [lbl(s, t), fmt(len(x))]
    for lo, hi in ((-1e9, -2000), (-2000, -1000), (-1000, 0), (0, 1e9)):
        y = x[(x.pos15 > lo) & (x.pos15 <= hi)]
        row.append(f"{len(y)} ops · {int((~y.hit).sum())} sem alvo ({100 * (~y.hit).mean():.0f}%)" if len(y) else "0")
    rows.append(row)
para("Checkpoint às 15:00 do servidor (abertura dos EUA), posição na vela das 14:45:", bold=True, sz=18, after=40)
table(["Horário · alvo", "Ops abertas às 15:00", "Abaixo de -2.000", "-2.000 a -1.000", "-1.000 a 0", "Acima de 0"], rows, weights=[4, 3, 5, 5, 5, 4], sz=13, align_right_from=1)
rows = []
for s, t in COMBOS:
    x = DA[(DA.slot == s) & (DA.alvo == t) & DA.pos3h.notna()]
    row = [lbl(s, t), fmt(len(x))]
    for lo, hi in ((-1e9, -1500), (-1500, -500), (-500, 0), (0, 1e9)):
        y = x[(x.pos3h > lo) & (x.pos3h <= hi)]
        row.append(f"{len(y)} ops · {int((~y.hit).sum())} sem alvo ({100 * (~y.hit).mean():.0f}%)" if len(y) else "0")
    rows.append(row)
para("Checkpoint 3 horas após a entrada:", bold=True, sz=18, after=40)
table(["Horário · alvo", "Ops abertas após 3h", "Abaixo de -1.500", "-1.500 a -500", "-500 a 0", "Acima de 0"], rows, weights=[4, 3, 5, 5, 5, 4], sz=13, align_right_from=1)

h1("5. Ideias de proteção testadas com os mesmos dados")
note("São hipóteses para você avaliar. O corte foi escolhido olhando os resultados, então precisa de teste fora da amostra. Nenhuma é stop de preço: são saídas por horário/invalidação lógica, compatíveis com operar sem stop.")
para("5.1 Fechar às 15:00 se a posição estiver abaixo de -1.000 pts", bold=True, sz=18, after=40)
rows = []
for s, t in COMBOS:
    if s >= "14:30":
        continue
    x = DA[(DA.slot == s) & (DA.alvo == t)].sort_values("data").reset_index(drop=True)
    new = x.res.copy()
    trig = (x.pos15 <= -1000) & x.pos15.notna()
    new[trig] = x.pos15[trig]
    h = x.index < int(len(x) * 0.6)
    rows.append([lbl(s, t), fmt(trig.sum()), fmt(int((x.hit & trig).sum())), fmt(x.res.mean()), fmt(new.mean()), fmt(x.res[h].mean()), fmt(new[h].mean()), fmt(x.res[~h].mean()), fmt(new[~h].mean()), fmt(x.res.min()), fmt(new.min())])
table(["Horário · alvo", "Acionada", "Dessas, bateriam alvo depois", "Média/dia sem a regra", "Média/dia com a regra", "Descoberta sem", "Descoberta com", "Validação sem", "Validação com", "Pior dia sem", "Pior dia com"], rows, weights=[4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4], sz=13, align_right_from=1)
note("A regra reduz o pior dia onde a queda se acumula depois das 15:00, mas não evita dias em que a queda já foi grande antes (a saída ocorre pela posição naquele instante, com o spread).")
para("5.2 Pausar depois de uma falha", bold=True, sz=18, after=40)
para("Não há evidência de que ajude: a probabilidade de falhar no dia útil seguinte a uma falha é igual ou próxima da base (coluna da seção 2). Só o 18:30 mostra repetição (19,8% contra 11,9%).", after=60)
para("5.3 Tamanho da exposição", bold=True, sz=18, after=40)
para("Cada falha custa em média 2.500 a 4.100 pts (1.100 no 18:30) e o pior dia chega a -10.900 a -17.700. 'Acertos p/ pagar 1 falha' (seção 2) mostra o tamanho do buraco: 6 a 21 acertos por falha. Dimensione o lote para suportar o pior dia observado e uma sequência de falhas próximas (a janela de 10 dias úteis com 2 ou mais falhas ocorreu muitas vezes), não só a média.", after=60)
para("5.4 O que os dados NÃO permitem prever", bold=True, sz=18, after=40)
para("Em cerca de 90% das falhas a pior vela não tem notícia de importância alta no calendário (só cerca de 10% caem no cenário B). Evitar dias de dado econômico elimina poucas falhas.", after=60)

h1("6. Todos os dias sem alvo por horário")
note("Colunas: Dia = dia da semana; Res. = resultado final em pts; Máx. a favor = o quanto chegou a subir antes de reverter; Quase = chegou a 2/3 do alvo; Mínima = hora da mínima do dia; Pior vela = maior queda numa vela de 15 min e hora; Notícia = evento USD de importância alta na janela de ±30 min da pior vela; Prata = variação da prata da entrada até 23:15; Cen. = cenário A, B, C ou D.")
for s, t in COMBOS:
    f = FA[(FA.slot == s) & (FA.alvo == t)].sort_values("data")
    h2(f"{s} · alvo {t} · {len(f)} dias sem alvo")
    rows = [[d8(r_.data), r_.dia, fmt(r_.res), fmt(r_.mfe), "sim" if r_.quase else "", fmt(r_.mae), r_.hora_min, f"{fmt(r_.pior_vela)} às {r_.hora_pior_vela}", r_.news3, fmt(r_.prata, 1, True), r_.cen[0]] for r_ in f.itertuples()]
    table(["Data", "Dia", "Res.", "Máx. a favor", "Quase", "MAE", "Mínima", "Pior vela", "Notícia", "Prata", "Cen."], rows, weights=[3, 2, 3, 3, 2, 3, 3, 5, 8, 3, 2], sz=11, align_right_from=None)

h1("7. Limites e avisos")
for t in [
    "Spread fixo de 20 pts; comissão, slippage e swap não incluídos. Entrada na abertura da vela M15.",
    "Os dias sem alvo de horários próximos (01:00 e 01:15) são quase os mesmos: não são amostras independentes.",
    "Os cenários são descritivos; não são causas comprovadas. A relação com notícias é de coincidência de horário.",
    "Dados completos: docs/relatorios/mba/xau_horarios/falhas_dias_sem_alvo_10_horarios.csv e falhas_sequencia.csv.",
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
<w:ftr {NS}><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t xml:space="preserve">XAUUSD — dias sem alvo · página </w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'''

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
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>XAUUSD — dias sem alvo</dc:title><dc:creator>MarketBehaviorAnalyzer</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-10-18T12:00:00Z</dcterms:created></cp:coreProperties>'''

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
