"""Presets 'protegido + janelas': igual ao protegido, com janelas sem entrada nas horas 01h e 04h do SERVIDOR.

InpBlockWindows e lido em HORA DO SERVIDOR. Nos CSVs t_server - t_local = +6 h (IC e FP), entao:
    servidor 01:00-02:00 = local 19:00-20:00 (dia anterior)
    servidor 04:00-05:00 = local 22:00-23:00 (dia anterior)
O offset pode mudar quando o servidor trocar de horario de verao: conferir t_server - t_local depois da mudanca.

Uso (raiz do repositorio):  python tools/micromomentum/make_presets_janelas.py
"""
import os
import shutil

D = "MQL5/Experts/MicroMomentum/presets/"
IC = r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\010E047102812FC0C18890992854220E\MQL5\Presets"
FP = r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\5194A13C185A318E8062DFAE26191AE3\MQL5\Presets"
WIN = "01:00-02:00;04:00-05:00"


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


jobs = [("v230", "MicroMomentum_v230_IC_protegido.set", "MicroMomentum_v230_IC_protegido_janelas.set", "1034", "v2.30 (mercado)"),
        ("v240", "MicroMomentum_v240_IC_protegido.set", "MicroMomentum_v240_IC_protegido_janelas.set", "1044", "v2.40.1 (pendente LIMIT)")]
for ver, src, dst, magic, name in jobs:
    over = {"InpBlockWindows": WIN, "InpMagicNumber": magic}
    items = [(k, over.get(k, v)) for k, v in read(D + src)]
    write(D + dst,
          ["MicroMomentum " + name + " - preset PROTEGIDO + JANELAS (IC) - magic " + magic,
           "Igual ao protegido (3 posicoes, porteira -US$5, stop diario US$30 so bloqueia entradas), mais janelas sem entrada.",
           "InpBlockWindows = " + WIN + " em HORA DO SERVIDOR.",
           "Horario LOCAL (servidor - 6 h nos CSVs): 19:00-20:00 e 22:00-23:00. Conferir o offset apos mudanca de horario de verao.",
           "Posicoes ja abertas continuam sendo gerenciadas; so as novas entradas sao bloqueadas."],
          items)
    for d in ([IC, FP] if ver == "v240" else [IC]):
        if os.path.isdir(d):
            shutil.copy(D + dst, d)
    print(dst, len(items), "chaves")
