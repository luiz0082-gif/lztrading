"""Presets da v2.50 e da v2.60 (horarios permitidos), IC e FP, mais instalacao e compilacao nos dois terminais.

Janelas permitidas em UTC (base TB_UTC; nao muda com o horario de verao do servidor):
    07:00-09:00 UTC = 04:00-06:00 local (UTC-3) = 10:00-12:00 servidor (hoje UTC+3)
    14:00-16:00 UTC = 11:00-13:00 local        = 17:00-19:00 servidor
    17:00-18:00 UTC = 14:00-15:00 local        = 20:00-21:00 servidor
    19:00-21:00 UTC = 16:00-18:00 local        = 22:00-24:00 servidor
Base dos presets: o 'protegido' (3 posicoes, porteira -US$ 5, stop diario US$ 30 que so bloqueia entradas).

Uso (raiz do repositorio):  python tools/micromomentum/make_presets_windows.py
"""
import os
import shutil
import subprocess

D = "MQL5/Experts/MicroMomentum/"
P = D + "presets/"
WIN = "07:00-09:00;14:00-16:00;17:00-18:00;19:00-21:00"
TERM = {
    "IC": dict(mql=r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\010E047102812FC0C18890992854220E\MQL5",
               ed=r"C:\Program Files\MetaTrader 5 IC Markets Global\MetaEditor64.exe"),
    "FP": dict(mql=r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\5194A13C185A318E8062DFAE26191AE3\MQL5",
               ed=r"C:\Program Files\FP Markets MT5 Terminal\MetaEditor64.exe"),
}
VERS = [("v250", "MicroMomentum_v230_IC_protegido.set", "1050", "v2.50 (mercado + reacao precoce)"),
        ("v260", "MicroMomentum_v240_IC_protegido.set", "1060", "v2.60 (pendente LIMIT)")]
BROKER = {"IC": {"InpMinTicksInWindow": "4", "InpMaxSpreadPoints": "10"},
          "FP": {"InpMinTicksInWindow": "3", "InpMaxSpreadPoints": "14"}}


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


for ver, base, magic, name in VERS:
    for br, bo in BROKER.items():
        items = read(P + base)
        over = dict(bo)
        over["InpMagicNumber"] = magic
        items = [(k, over.get(k, v)) for k, v in items]
        # novos inputs: depois de InpBlockWindows, fora das chaves ja existentes
        new = [("InpAllowWindowsEnable", "true"), ("InpAllowTimeBase", "0"), ("InpAllowWindows", WIN)]
        out = []
        for k, v in items:
            out.append((k, v))
            if k == "InpBlockWindows":
                out += new
        dst = "MicroMomentum_%s_%s_janelas_permitidas.set" % (ver, br)
        write(P + dst,
              ["MicroMomentum %s - JANELAS PERMITIDAS - %s - magic %s" % (name, br, magic),
               "So abre novas entradas dentro das janelas (UTC): " + WIN,
               "Em horario LOCAL (UTC-3): 04:00-06:00, 11:00-13:00, 14:00-15:00, 16:00-18:00.",
               "Em horario do SERVIDOR hoje (UTC+3, ate 01/11): 10:00-12:00, 17:00-19:00, 20:00-21:00, 22:00-24:00.",
               "Base protegida: 3 posicoes, porteira -US$ 5, stop diario US$ 30 que so bloqueia entradas. Sem stop por posicao.",
               "Fora das janelas: estado BLOCK_SESSION; pendentes canceladas; posicoes abertas continuam gerenciadas."],
              out)
        print(dst, len(out), "chaves")

# instalar e compilar os dois EAs nos dois terminais
for br, t in TERM.items():
    for ver in ("v250", "v260"):
        dst = os.path.join(t["mql"], "Experts", "MicroMomentum_%s.mq5" % ver)
        shutil.copy(D + "MicroMomentum_%s.mq5" % ver, dst)
        log = os.path.join(os.environ.get("TEMP", "."), "mm_%s_%s.log" % (ver, br))
        subprocess.run([t["ed"], "/compile:" + dst, "/log:" + log], check=False)
        res = ""
        if os.path.exists(log):
            txt = open(log, "rb").read().decode("utf-16", errors="replace")
            res = [l for l in txt.splitlines() if "Result" in l or "error" in l.lower()][:3]
        print(br, ver, res)
    for f in os.listdir(P):
        if f.endswith("_%s_janelas_permitidas.set" % br):
            shutil.copy(P + f, os.path.join(t["mql"], "Presets", f))
