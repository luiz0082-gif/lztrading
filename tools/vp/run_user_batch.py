"""Bateria de testes NA PLATAFORMA DO USUARIO (Clear instalado, pasta de dados dele), usando os PRESETS que estao
na pasta Profiles\\Tester dele. Fecha o terminal antes, roda sem modo visual, reabre no final.
Imprime: ops, liquido, PF, dias positivos, pior dia, saldo minimo e a qualidade dos ticks (dias/minutos descartados)."""
import os, re, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vp_run import parse, write16

EXE = r"C:\Program Files\Clear Investimentos MT5 Terminal\terminal64.exe"
DATA = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Terminal', '698B86206820B42976F30D28CAC50412')
AGLOG = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Tester', '698B86206820B42976F30D28CAC50412')
A, B = '2026.10.13', '2026.11.12'
TESTS = [
    ('VantagePulse_B3_v1.07.ex5', 'VantagePulse_B3_v107_LOTE1_STOP100_TP160.set'),
    ('VantagePulse_B3_v1.07.ex5', 'VantagePulse_B3_v107_LOTE1_STOP80_TP240.set'),
    ('VantagePulse_B3_v1.07.ex5', 'VantagePulse_B3_v107_LOTE1_STOP60_TP240.set'),
    ('VantagePulse_B3_v1.05.ex5', 'VantagePulse_B3_v105_LOTE1_STOP100.set'),
    ('VantagePulse_B3_v1.07.ex5', 'VantagePulse_B3_v107_ESCADA1a10_STOP100_TP160.set'),
    ('VantagePulse_B3_v1.07.ex5', 'VantagePulse_B3_v107_ESCADA1a10_STOP80_TP240.set'),
    ('VantagePulse_B3_v1.07.ex5', 'VantagePulse_B3_v107_ESCADA1a10_STOP60_TP240.set'),
    ('VantagePulse_B3_v1.05.ex5', 'VantagePulse_B3_v105_ESCADA1a10_STOP100.set'),
]

def ticks_quality():
    logs = []
    for root, _, files in os.walk(AGLOG):
        for f in files:
            if f.endswith('.log') and 'Agent' in root: logs.append(os.path.join(root, f))
    if not logs: return '?'
    t = open(max(logs, key=os.path.getmtime), 'rb').read().decode('utf-16', errors='ignore')
    a = re.findall(r'real ticks discarded for (\d+) minutes of (\d+) total', t)
    b = re.findall(r'real ticks discarded for (\d+) whole days', t)
    return 'ticks reais descartados: %s min de %s, %s dias inteiros' % (a[-1][0] if a else '0', a[-1][1] if a else '?', b[-1] if b else '0')

def one(i, expert, preset):
    name = 'VP_PLAT_%02d' % i
    ini = ('[Tester]\r\nExpert=%s\r\nExpertParameters=%s\r\nSymbol=WINZ26\r\nPeriod=M1\r\nModel=4\r\nExecutionMode=12\r\n'
           'Optimization=0\r\nFromDate=%s\r\nToDate=%s\r\nForwardMode=0\r\nDeposit=700\r\nCurrency=BRL\r\nLeverage=100\r\n'
           'Visual=0\r\nReport=%s\r\nReplaceReport=1\r\nShutdownTerminal=1\r\n') % (expert, preset, A, B, name)
    ip = os.path.join(DATA, name + '.ini'); write16(ip, ini)
    rep = os.path.join(DATA, name + '.htm')
    if os.path.exists(rep): os.remove(rep)
    t0 = time.time(); p = subprocess.Popen([EXE, '/config:' + ip]); t_rep = None
    while p.poll() is None:
        time.sleep(3)
        if os.path.exists(rep) and t_rep is None: t_rep = time.time()
        if t_rep and time.time() - t_rep > 30: p.kill(); break
        if time.time() - t0 > 3600: p.kill(); break
    if not os.path.exists(rep):
        print('%-52s SEM RELATORIO' % preset, flush=True); return
    r = parse(rep, 700); d = r['days']
    print('%-52s ops %5d | liquido %9.0f | PF %.2f | dias positivos %2d/%2d | pior dia %7.0f | saldo min %6.0f | queda max %6.0f | %s (%.0fs)' % (
        preset, r['trades'], r['net'], r['pf'], sum(1 for v in d.values() if v > 0), len(d), min(d.values()) if d else 0,
        r['minbal'], r['dd'], ticks_quality(), time.time() - t0), flush=True)
    print('   por dia: %s' % {k[5:]: round(v) for k, v in sorted(d.items())}, flush=True)
    for ext in ('.htm', '.png', '-holding.png', '-hst.png', '-mfemae.png', '.ini'):
        q = os.path.join(DATA, name + ext)
        if os.path.exists(q):
            try: os.remove(q)
            except OSError: pass

if __name__ == '__main__':
    print('PLATAFORMA DO USUARIO | %s a %s (ToDate %s) | R$700 | 12 ms | sem visual' % (A, '11/11', B), flush=True)
    for i, (e, s) in enumerate(TESTS, 1): one(i, e, s)
    subprocess.Popen([EXE])
    print('FIM12 terminal reaberto', flush=True)
