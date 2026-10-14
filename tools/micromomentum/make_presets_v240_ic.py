"""Preset da v2.40 (ordem pendente real) para teste A/B na IC contra a v2.30 estilo v2.00 (magic 1031).

Mesmos parametros do preset v230_IC_estilo200 (lote 0,01, 6 posicoes, 2 por vela, TP US$1,20, sem ESCAPE),
trocando so a forma de entrar: pendente LIMIT em vez de ordem a mercado. Spread max 10 (valor em uso na IC).
Uso (raiz do repositorio):  python tools/micromomentum/make_presets_v240_ic.py
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


v230 = dict(read(D + "MicroMomentum_v230_IC_estilo200.set"))
v240_keys = [k for k, _ in read(D + "MicroMomentum_v240_IC.set")]
over = {
    "InpMinTicksInWindow": "4",
    "InpMaxSpreadPoints": "10",
    "InpPendEnable": "true", "InpPendMode": "0", "InpPendLimitPct": "30.0", "InpPendMinOffsetPts": "8",
    "InpPendStopPts": "10", "InpPendTtlMs": "1500", "InpPendCancelPts": "40", "InpPendRearmMs": "300",
    "InpMagicNumber": "1041",
}
items = []
for k in v240_keys:
    if k in over:
        items.append((k, over[k]))
    elif k in v230:
        items.append((k, v230[k]))
    else:
        raise SystemExit("chave sem valor: " + k)
write(D + "MicroMomentum_v240_IC_estilo200.set",
      ["MicroMomentum v2.40 - preset IC estilo v2.00 com ORDEM PENDENTE (teste A/B contra o magic 1031)",
       "Igual ao v230_IC_estilo200 (lote 0.01, 6 posicoes, 2 por vela, TP US$1.20, sem ESCAPE, sem stop, sem hedge),",
       "mas a entrada e uma pendente LIMIT (recuo de 30% do impulso, minimo 8 pts, TTL 1500 ms, cancela se fugir 40 pts).",
       "Spread max 10. Magic 1041. Rodar em OUTRO grafico do mesmo simbolo, para nao misturar com o magic 1031."],
      items)
print(len(items), "chaves")
