"""Presets 'protegido' da v2.30 e da v2.40.1 (IC): so parametros, nenhuma mudanca de codigo.

Protecoes ja existentes no codigo, ligadas:
  - porteira de empilhamento (InpStackGateMoney): sem nova entrada se alguma posicao aberta estiver pior que -US$ 5
  - limite de posicoes: 3 por EA (dois EAs somam no maximo 6, em vez de 12)
  - stop diario como circuit breaker de ENTRADAS (InpDailyStopEnable, sem fechar posicoes):
    P/L do dia (realizado + flutuante do magic) <= -US$ 30 bloqueia novas entradas
NAO inclui stop por posicao. NAO existem no codigo: filtro de tendencia de 60 min, teto agregado entre magics diferentes.

Uso (raiz do repositorio):  python tools/micromomentum/make_presets_protegido.py
"""
import os
import shutil

D = "MQL5/Experts/MicroMomentum/presets/"
IC = r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\010E047102812FC0C18890992854220E\MQL5\Presets"
FP = r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\5194A13C185A318E8062DFAE26191AE3\MQL5\Presets"


def read(path):
    out = []
    for line in open(path, "rb").read().decode("utf-16").splitlines():
        if line and not line.startswith(";"):
            k, v = line.split("=", 1)
            out.append((k, v))
    return out


def write(path, header, items):
    txt = "\r\n".join(["; " + h for h in header] + [k + "=" + v for k, v in items]) + "\r\n"
    open(path, "wb").write(b"\xff\xfe" + txt.encode("utf-16-le"))


common = {"InpMaxOpenPositions": "3", "InpStackGateMoney": "5.0",
          "InpDailyStopEnable": "true", "InpDailyStopMoney": "30.0", "InpCloseOnDailyLimit": "false",
          "InpMaxSpreadPoints": "10"}
jobs = [("v230", "MicroMomentum_v230_IC_estilo200.set", "MicroMomentum_v230_IC_protegido.set", "1033", "v2.30 (mercado)"),
        ("v240", "MicroMomentum_v240_IC_estilo200.set", "MicroMomentum_v240_IC_protegido.set", "1043", "v2.40.1 (pendente LIMIT)")]
for ver, src, dst, magic, name in jobs:
    items = read(D + src)
    over = dict(common)
    over["InpMagicNumber"] = magic
    items = [(k, over.get(k, v)) for k, v in items]
    write(D + dst,
          ["MicroMomentum " + name + " - preset PROTEGIDO (IC) - magic " + magic,
           "Mesmo estilo do estilo200 (lote 0.01, TP US$1.20, sem ESCAPE), com 3 posicoes por EA e porteira de empilhamento -US$ 5.",
           "Stop diario US$ 30 so BLOQUEIA novas entradas (nao fecha posicoes): P/L do dia = realizado + flutuante do magic.",
           "Sem stop por posicao. Nao ha teto agregado entre magics diferentes: dois EAs somam ate 6 posicoes."],
          items)
    for d in ([IC, FP] if ver == "v240" else [IC]):
        if os.path.isdir(d):
            shutil.copy(D + dst, d)
    print(dst, len(items), "chaves")
