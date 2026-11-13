"""Roda testes NA PLATAFORMA DO USUARIO (terminal Clear instalado). Fecha o terminal uma vez, roda a fila, reabre.
Cada teste: expert, simbolo, periodo, preset base + overrides (gravados num .set temporario na pasta Presets do usuario)."""
import os, re, shutil, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vp_run import parse, write16, read16

EXE = r"C:\Program Files\Clear Investimentos MT5 Terminal\terminal64.exe"
DATA = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Terminal', '698B86206820B42976F30D28CAC50412')
PRESETS = os.path.join(DATA, 'MQL5', 'Presets')
PROFILES = os.path.join(DATA, 'MQL5', 'Profiles', 'Tester')
TST = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Tester', '698B86206820B42976F30D28CAC50412')
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))

def close_terminal():
    import ctypes
    out = subprocess.run(['powershell', '-NoProfile', '-Command',
        "$p=Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object { $_.Path -like 'C:\\Program Files\\Clear Investimentos MT5 Terminal\\*' }; "
        "foreach($x in $p){ [void]$x.CloseMainWindow(); if(-not $x.WaitForExit(40000)){ Stop-Process -Id $x.Id -Force } }; Start-Sleep 3"],
        capture_output=True, text=True)
    return out.returncode

def reopen():
    subprocess.Popen([EXE])

def kv(path):
    d = {}
    for l in read16(path).splitlines():
        m = re.match(r'^(Inp\w+)=([^|\r\n]*)', l)
        if m: d[m.group(1)] = m.group(2).strip()
    return d

def write_set(name, base_preset, overrides):
    d = kv(os.path.join(PRESETS, base_preset)); d.update({k: str(v) for k, v in overrides.items()})
    txt = '; temporario\r\n' + '\r\n'.join(k + '=' + v for k, v in d.items()) + '\r\n'
    for dst in (PRESETS, PROFILES):   # o tester procura o .set em Profiles\Tester
        open(os.path.join(dst, name + '.set'), 'wb').write(b'\xff\xfe' + txt.encode('utf-16-le'))
    return d

def newest_csv():
    best = None
    for root, _, files in os.walk(TST):
        for f in files:
            if f.startswith('VantagePulse_') and f.endswith('.csv'):
                q = os.path.join(root, f)
                if best is None or os.path.getmtime(q) > os.path.getmtime(best): best = q
    return best

def run_script(script, params, csv_name, done_marker='TOTAL', timeout=3000):
    """Roda um script MQL5 no terminal (StartUp) e espera o CSV de saida ficar completo."""
    csv = os.path.join(DATA, 'MQL5', 'Files', csv_name)
    if os.path.exists(csv): os.remove(csv)
    pset = os.path.join(PRESETS, 'VP_script_run.set')
    write16(pset, ''.join('%s=%s\r\n' % (k, v) for k, v in params.items()))
    ini = os.path.join(DATA, 'VP_script.ini')
    write16(ini, '[StartUp]\r\nScript=%s\r\nScriptParameters=VP_script_run.set\r\nSymbol=WINZ26\r\nPeriod=M1\r\n' % script)
    t0 = time.time(); p = subprocess.Popen([EXE, '/config:' + ini]); ok = False
    while p.poll() is None:
        time.sleep(5)
        if time.time() - t0 > timeout: p.kill(); break
        try:
            if os.path.exists(csv) and done_marker in read16(csv) and time.time() - os.path.getmtime(csv) > 10:
                time.sleep(10); p.kill(); ok = True; break
        except (PermissionError, OSError):
            pass   # arquivo ainda aberto pelo script
    for q in (pset, ini):
        if os.path.exists(q): os.remove(q)
    try: ok = ok or (os.path.exists(csv) and done_marker in read16(csv))
    except (PermissionError, OSError): pass
    return csv if ok else None

def run_test(i, t, outdir=None):
    """t: dict(expert, symbol, a, b, preset, over, deposit, exec, label, keep_csv)"""
    name = 'VP_UP_%03d' % i
    for root, _, files in os.walk(TST):   # o CSV do EA e gravado em modo append: limpa para nao misturar rodadas
        for f in files:
            if f.startswith('VantagePulse_') and f.endswith('.csv'):
                try: os.remove(os.path.join(root, f))
                except OSError: pass
    intended = write_set(name + '_set', t['preset'], t.get('over', {}))
    ini = ('[Tester]\r\nExpert=%s\r\nExpertParameters=%s\r\nSymbol=%s\r\nPeriod=M1\r\nModel=4\r\nExecutionMode=%s\r\nOptimization=0\r\n'
           'FromDate=%s\r\nToDate=%s\r\nForwardMode=0\r\nDeposit=%s\r\nCurrency=BRL\r\nLeverage=100\r\nVisual=0\r\nReport=%s\r\nReplaceReport=1\r\nShutdownTerminal=1\r\n') % (
        t['expert'], name + '_set.set', t.get('symbol', 'WINZ26'), t.get('exec', 12), t['a'], t['b'], t.get('deposit', 700), name)
    ip = os.path.join(DATA, name + '.ini'); write16(ip, ini)
    rep = os.path.join(DATA, name + '.htm')
    if os.path.exists(rep): os.remove(rep)
    t0 = time.time(); p = subprocess.Popen([EXE, '/config:' + ip]); t_rep = None
    while p.poll() is None:
        time.sleep(3)
        if os.path.exists(rep) and t_rep is None: t_rep = time.time()
        if t_rep and time.time() - t_rep > 30: p.kill(); break
        if time.time() - t0 > 7200: p.kill(); break
    res = None
    if os.path.exists(rep):
        res = parse(rep, t.get('deposit', 700)); res['secs'] = time.time() - t0
        res['manifest'] = check_manifest(intended)
        if t.get('keep_csv') and outdir:
            c = newest_csv()
            if c: shutil.copy(c, os.path.join(outdir, t['keep_csv']))
    for ext in ('.htm', '.png', '-holding.png', '-hst.png', '-mfemae.png', '.ini'):
        q = os.path.join(DATA, name + ext)
        if os.path.exists(q):
            try: os.remove(q)
            except OSError: pass
    for dst in (PRESETS, PROFILES):
        q = os.path.join(dst, name + '_set.set')
        if os.path.exists(q):
            try: os.remove(q)
            except OSError: pass
    return res

def check_manifest(intended):
    c = newest_csv()
    if not c: return 'SEM CSV (nao verificado)'
    import csv
    man = None
    for row in csv.reader(open(c, encoding='latin-1')):
        if len(row) >= 4 and row[2] == 'MANIFEST': man = row[3]; break
    if not man: return 'SEM MANIFEST (nao verificado)'
    got = dict(re.findall(r'(Inp\w+)=([^;]*);', man)); bad = []
    for k, v in intended.items():
        if k in ('InpShowPanel', 'InpEnableCSV') or k not in got: continue
        try: same = abs(float(got[k]) - float(v)) < 1e-9
        except ValueError: same = got[k].strip().lower() == v.strip().lower()
        if not same: bad.append('%s: queria %s, rodou %s' % (k, v, got[k]))
    return 'OK' if not bad else 'DIVERGE: ' + '; '.join(bad[:6])

def fmt(r):
    if not r: return 'SEM RELATORIO'
    d = r['days']
    return 'ops %5d | liquido %9.0f | PF %.2f | dias + %2d/%2d | pior dia %7.0f | saldo min %6.0f | queda max %7.0f | acerto %.0f%% | %.0fs' % (
        r['trades'], r['net'], r['pf'], sum(1 for v in d.values() if v > 0), len(d), min(d.values()) if d else 0, r['minbal'], r['dd'], r['win'], r.get('secs', 0)) + ' | manifesto ' + str(r.get('manifest', '?'))
