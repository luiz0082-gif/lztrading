"""Cria presets da v2.30 que reproduzem a configuracao v2.00 do dia 2026-09-30 (IC, +US$101,88).

Fonte dos valores: params.csv das sessoes A/S083946, S112532 e S162348 (identicas entre si).
Uso (raiz do repositorio):  python tools/micromomentum/make_presets_estilo200.py
"""
D = "MQL5/Experts/MicroMomentum/presets/"


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


# v2.00 de 30/09: lote 0,01; TP US$1,20; 6 posicoes; 2 entradas por vela; sem ESCAPE; sem filtro de tendencia
base_over = {
    "InpLotSize": "0.01", "InpMinPointsDisplacement": "30", "InpMaxMilliseconds": "1000",
    "InpMaxPullbackPct": "35.0", "InpMinDispToSpread": "1.5", "InpCooldownMs": "1000",
    "InpMaxTradesPerCandle": "2", "InpMaxOpenPositions": "6", "InpAllowHedge": "false",
    "InpTPMode": "2", "InpTPMoney": "1.20", "InpSLMode": "0",
    "InpRecoilEnable": "true", "InpRecoilPoints": "100", "InpRecoilMinProfit": "0.45",
    "InpEscapeSec": "0", "InpCTEscapeSec": "0", "InpTrendEnable": "false",
    "InpDailyGoalEnable": "true", "InpDailyGoalMoney": "100.0", "InpDailyStopEnable": "false",
    "InpCloseOnDailyLimit": "false", "InpMaxConsecLosses": "0",
    "InpDeviationPoints": "20", "InpRetries": "1",
    "InpMaxImpulsePts": "0", "InpBlockWindows": "", "InpStackGateMoney": "0.0", "InpStackMinGapMs": "0",
    "InpPullbackEntry": "false", "InpSlipHighPts": "0", "InpEarlyEnable": "false",
    "InpMagicNumber": "1031",
}
broker = {
    "IC": {"InpMinTicksInWindow": "4", "InpMaxSpreadPoints": "8"},
    "FP": {"InpMinTicksInWindow": "3", "InpMaxSpreadPoints": "14"},
}
desc = {
    "IC": "IC Markets: valores originais da v2.00 (4 ticks, spread max 8)",
    "FP": "FP Markets: ticks minimo 3 (a janela tem no maximo 4) e spread max 14 (spread normal 9-14 pts)",
}
for br, ov in broker.items():
    items = read(D + "MicroMomentum_v230_IC.set")
    vals = dict(items)
    vals.update(base_over)
    vals.update(ov)
    out = [(k, vals[k]) for k, _ in items]
    write(D + "MicroMomentum_v230_" + br + "_estilo200.set",
          ["MicroMomentum v2.30 - preset estilo v2.00 (replica a configuracao de 2026-09-30) - " + br,
           desc[br] + ".",
           "Lote 0.01, TP US$1.20 liquido, ate 6 posicoes, 2 entradas por vela, SEM ESCAPE, SEM stop, SEM hedge.",
           "Meta diaria US$100 (em 30/09 a meta foi 45, depois 80, depois 100). Magic 1031 para separar dos dados da v2.30 com reacao."],
          out)
    print(br, len(out), "chaves")
