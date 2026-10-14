"""Preset v2.30 para a conta Real pequena (US$ 103): meta diaria 15, lote minimo, no maximo 2 posicoes.

Base: v230_IC_estilo200. Mudancas: MaxOpen 2 (cabe na margem mesmo em alavancagem 1:100), meta 15, magic 1032.
SEM stop e SEM limite de perda diaria (escolha do usuario); esses dois pontos ficam explicitos no cabecalho.
Uso (raiz do repositorio):  python tools/micromomentum/make_preset_real.py
"""
D = "MQL5/Experts/MicroMomentum/presets/"


def read(path):
    out = []
    for line in open(path, "rb").read().decode("utf-16").splitlines():
        if line and not line.startswith(";"):
            k, v = line.split("=", 1)
            out.append((k, v))
    return out


items = read(D + "MicroMomentum_v230_IC_estilo200.set")
over = {"InpMaxOpenPositions": "2", "InpDailyGoalMoney": "15.0", "InpMaxSpreadPoints": "10", "InpMagicNumber": "1032"}
items = [(k, over.get(k, v)) for k, v in items]
header = ["MicroMomentum v2.30 - preset REAL (conta pequena, ~US$ 103) - meta diaria US$ 15",
          "Lote 0.01 (minimo), no maximo 2 posicoes (2 x 0,01 = ~US$ 83 de margem em 1:100), 2 entradas por vela, TP US$ 1.20.",
          "SEM stop por posicao e SEM stop diario (InpDailyStopEnable=false). Meta 10: troque InpDailyGoalMoney para 10.",
          "NAO testado em conta real. Magic 1032."]
txt = "\r\n".join(["; " + h for h in header] + [k + "=" + v for k, v in items]) + "\r\n"
open(D + "MicroMomentum_v230_REAL_meta15.set", "wb").write(b"\xff\xfe" + txt.encode("utf-16-le"))
print(len(items), "chaves")
