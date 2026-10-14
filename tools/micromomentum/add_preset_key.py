"""Adiciona InpPendSafetyExpirySec=180 aos presets da v2.40 (apos InpPendRearmMs) e copia para os terminais."""
import glob
import os
import shutil

D = "MQL5/Experts/MicroMomentum/presets/"
DEST = [r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\010E047102812FC0C18890992854220E\MQL5\Presets",
        r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\5194A13C185A318E8062DFAE26191AE3\MQL5\Presets"]
for f in glob.glob(D + "MicroMomentum_v240_*.set"):
    lines = open(f, "rb").read().decode("utf-16").splitlines()
    if any(l.startswith("InpPendSafetyExpirySec=") for l in lines):
        continue
    out = []
    for l in lines:
        out.append(l)
        if l.startswith("InpPendRearmMs="):
            out.append("InpPendSafetyExpirySec=180")
    open(f, "wb").write(b"\xff\xfe" + ("\r\n".join(out) + "\r\n").encode("utf-16-le"))
    for d in DEST:
        if os.path.isdir(d):
            shutil.copy(f, d)
    print("atualizado", os.path.basename(f))
