"""Na PLATAFORMA DO USUARIO: (A) auditoria de ticks por dia (script dentro do terminal) e (B) v1.08 com o preset de referencia
(deve reproduzir 11.142 ops / +R$ 43.639 da v1.07). Fecha o terminal antes e reabre no final."""
import os, shutil, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vp_run import parse, write16

EXE = r"C:\Program Files\Clear Investimentos MT5 Terminal\terminal64.exe"
DATA = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Terminal', '698B86206820B42976F30D28CAC50412')
TST = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Tester', '698B86206820B42976F30D28CAC50412')
OUT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'MQL5', 'Experts', 'VantagePulse_B3', 'auditoria'))
os.makedirs(OUT, exist_ok=True)

def stage_a():
    csv = os.path.join(DATA, 'MQL5', 'Files', 'VP_tick_audit.csv')
    if os.path.exists(csv): os.remove(csv)
    ini = os.path.join(DATA, 'VP_audit.ini')
    write16(ini, '[StartUp]\r\nScript=VantagePulse_TickAudit\r\nScriptParameters=VP_audit_run.set\r\nSymbol=WINZ26\r\nPeriod=M1\r\n')
    t0 = time.time(); p = subprocess.Popen([EXE, '/config:' + ini]); last = None
    while p.poll() is None:
        time.sleep(5)
        if time.time() - t0 > 1500: p.kill(); break
        if os.path.exists(csv):
            sz = os.path.getsize(csv)
            if last is not None and sz == last and time.time() - t0 > 30 and time.time() - os.path.getmtime(csv) > 40:
                p.kill(); break
            last = sz
    ok = os.path.exists(csv)
    if ok: shutil.copy(csv, os.path.join(OUT, 'VP_tick_audit_13out-11nov.csv'))
    print('A) auditoria de ticks:', 'CSV gerado (%.0fs)' % (time.time() - t0) if ok else 'SEM CSV', flush=True)

def stage_b():
    name = 'VP_V108_REF'
    ini = ('[Tester]\r\nExpert=VantagePulse_B3_v1.08.ex5\r\nExpertParameters=VantagePulse_B3_v108_LOTE1_STOP80_TP240.set\r\nSymbol=WINZ26\r\nPeriod=M1\r\n'
           'Model=4\r\nExecutionMode=12\r\nOptimization=0\r\nFromDate=2026.10.13\r\nToDate=2026.11.02\r\nForwardMode=0\r\nDeposit=700\r\n'
           'Currency=BRL\r\nLeverage=100\r\nVisual=0\r\nReport=%s\r\nReplaceReport=1\r\nShutdownTerminal=1\r\n') % name
    ip = os.path.join(DATA, name + '.ini'); write16(ip, ini)
    rep = os.path.join(DATA, name + '.htm')
    if os.path.exists(rep): os.remove(rep)
    t0 = time.time(); p = subprocess.Popen([EXE, '/config:' + ip]); t_rep = None
    while p.poll() is None:
        time.sleep(3)
        if os.path.exists(rep) and t_rep is None: t_rep = time.time()
        if t_rep and time.time() - t_rep > 30: p.kill(); break
        if time.time() - t0 > 3000: p.kill(); break
    if not os.path.exists(rep): print('B) v1.08: SEM RELATORIO', flush=True); return
    shutil.copy(rep, os.path.join(OUT, 'relatorio_v108_ref_13out-02nov.htm'))
    r = parse(rep, 700); d = r['days']
    print('B) v1.08 referencia: ops %d liquido %.0f PF %.2f | dias positivos %d/%d | %s (%.0fs)' % (
        r['trades'], r['net'], r['pf'], sum(1 for v in d.values() if v > 0), len(d), {k[5:]: round(v) for k, v in sorted(d.items())}, time.time() - t0), flush=True)
    print('   referencia v1.07 na mesma plataforma: ops 11142 liquido 43639 PF 1.73 | dias positivos 9/14', flush=True)
    # CSV da v1.08 gravado pelo agente do tester
    best = None
    for root, _, files in os.walk(TST):
        for f in files:
            if f.startswith('VantagePulse_WINZ26_') and f.endswith('.csv'):
                q = os.path.join(root, f)
                if best is None or os.path.getmtime(q) > os.path.getmtime(best): best = q
    if best: shutil.copy(best, os.path.join(OUT, 'tester_v108_ref_13out-02nov.csv')); print('   CSV v1.08 copiado', os.path.getsize(best), 'bytes', flush=True)
    for ext in ('.htm', '.png', '-holding.png', '-hst.png', '-mfemae.png', '.ini'):
        q = os.path.join(DATA, name + ext)
        if os.path.exists(q):
            try: os.remove(q)
            except OSError: pass

if __name__ == '__main__':
    stage_a()
    stage_b()
    for f in ('VP_audit.ini',):
        q = os.path.join(DATA, f)
        if os.path.exists(q): os.remove(q)
    q = os.path.join(DATA, 'MQL5', 'Presets', 'VP_audit_run.set')
    if os.path.exists(q): os.remove(q)
    subprocess.Popen([EXE])
    print('FIM13 terminal reaberto', flush=True)
