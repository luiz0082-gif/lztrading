r"""VantagePulse B3: backtest no harness isolado C:\ClearMM_Tester (oculto, 3 nucleos, sem conectar na conta).
Uso (modulo): run(expert, overrides, frm, to, deposit=20000) -> dict de metricas."""
import ctypes, os, re, subprocess, time
T = r"C:\ClearMM_Tester"
TPL = os.path.expandvars(r"%APPDATA%\MetaQuotes\Terminal\698B86206820B42976F30D28CAC50412\MQL5\Profiles\Tester\VantagePulse_B3_v1.02.WINZ26.M1.20261002_20261111.400.ini")
f = lambda s: float(s.replace(" ", "").replace("\xa0", ""))
def read16(p):
    b = open(p, "rb").read(); return b.decode("utf-16" if b[:2] in (b"\xff\xfe", b"\xfe\xff") else "utf-8", errors="ignore")
def write16(p, s): open(p, "wb").write(b"\xff\xfe" + s.encode("utf-16-le"))
def parse(path, deposit):
    t = read16(path); d = []
    for r in re.findall(r"<tr[^>]*>(.*?)</tr>", t[t.find("Ofertas"):], flags=re.S):
        c = [re.sub(r"<[^>]+>", "", x).strip() for x in re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", r, flags=re.S)]
        if len(c) >= 12 and re.match(r"\d{4}\.", c[0]) and c[3] != "balance": d.append(c)
    outs = [c for c in d if c[4] == "out"]
    p = [f(c[10]) + f(c[8]) + f(c[9]) for c in outs]
    w = [x for x in p if x > 0]; l = [x for x in p if x < 0]
    bal = [deposit] + [f(c[11]) for c in d]
    pk = bal[0]; dd = 0
    for v in bal:
        pk = max(pk, v); dd = max(dd, pk - v)
    days = {}
    for c, x in zip(outs, p): days[c[0][:10]] = days.get(c[0][:10], 0) + x
    zero = sum(1 for c in d if c[6] in ("0", "0.0"))
    txt = re.sub(r"<[^>]+>", " ", t); txt = re.sub(r"\s+", " ", txt)
    mh = re.search(r"Tempo m.ximo de dura.{1,3}o da posi.{1,3}o: ([0-9:]+)", txt)
    hours = {}
    for c, x in zip(outs, p):
        h = c[0][11:13]; e = hours.setdefault(h, [0.0, 0, 0]); e[0] += x; e[1] += 1; e[2] += (1 if x > 0 else 0)
    return {"hours": hours, "maxhold": mh.group(1) if mh else "?", "trades": len(p), "net": sum(p), "pf": (sum(w) / -sum(l)) if l else 999, "win": 100 * len(w) / max(1, len(p)),
            "avgw": sum(w) / max(1, len(w)), "avgl": sum(l) / max(1, len(l)), "dd": dd, "minbal": min(bal),
            "days": days, "zero": zero, "reasons": {}}
def run(expert, ov, frm, to, deposit=20000, tag="vp"):
    ini = read16(TPL)
    ini = re.sub(r"(?m)^Expert=.*$", f"Expert={expert}.ex5", ini)
    for k, v in (("FromDate", frm), ("ToDate", to), ("Visual", "0"), ("Deposit", str(deposit))):
        ini = re.sub(rf"(?m)^{k}=.*$", f"{k}={v}", ini)
    ini = re.sub(r"(?m)^;.*\r?\n", "", ini)
    for k, v in ov.items():
        ini, n = re.subn(rf"(?m)^{k}=[^|\r\n]*", f"{k}={v}", ini)
        if n == 0: ini = ini.replace("[TesterInputs]", "[TesterInputs]\r\n" + k + "=" + str(v), 1)
    name = f"{tag}_{os.getpid()}"
    ini = "[Common]\r\nProxyEnable=1\r\nProxyType=0\r\nProxyAddress=127.0.0.1:9\r\n" + ini.replace("[Tester]", f"[Tester]\r\nReport={name}\r\nReplaceReport=1\r\nShutdownTerminal=1", 1)
    ip = os.path.join(T, name + ".ini"); write16(ip, ini); rep = os.path.join(T, name + ".htm")
    if os.path.exists(rep): os.remove(rep)
    si = subprocess.STARTUPINFO(); si.dwFlags |= subprocess.STARTF_USESHOWWINDOW; si.wShowWindow = 0
    p = subprocess.Popen([os.path.join(T, "terminal64.exe"), "/portable", f"/config:{ip}"], startupinfo=si, creationflags=0x00004000 | 0x08000000)
    try: ctypes.windll.kernel32.SetProcessAffinityMask(int(p._handle), 3584)
    except Exception: pass
    t_start = time.time(); t_rep = None
    while p.poll() is None:   # o terminal as vezes trava ao fechar: encerra 15 s depois que o relatorio aparece
        time.sleep(2)
        if os.path.exists(rep) and t_rep is None: t_rep = time.time()
        if t_rep and time.time() - t_rep > 15: p.kill(); break
        if time.time() - t_start > 2400: p.kill(); return None
    try: p.wait(timeout=30)
    except subprocess.TimeoutExpired: p.kill(); return None
    if not os.path.exists(rep): return None
    try: return parse(rep, deposit)
    finally:
        if os.environ.get("VP_KEEP"):
            import shutil; shutil.copy(rep, os.path.join(os.path.dirname(os.path.abspath(__file__)), "last.htm"))
        for ext in (".htm", ".png", "-holding.png", "-hst.png", "-mfemae.png"):
            q = os.path.join(T, name + ext)
            if os.path.exists(q):
                try: os.remove(q)
                except OSError: pass
        try: os.remove(ip)
        except OSError: pass
def show(label, r):
    if not r: print(label, "SEM RELATORIO", flush=True); return
    print(f"{label}: ops {r['trades']} net {r['net']:.0f} PF {r['pf']:.2f} acerto {r['win']:.0f}% medG {r['avgw']:.1f} medP {r['avgl']:.1f} DD {r['dd']:.0f} saldoMin {r['minbal']:.0f} preco0 {r['zero']}", flush=True)
