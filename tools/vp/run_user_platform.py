"""Roda 2 testes NA PLATAFORMA DO USUARIO (Clear instalado, pasta de dados dele), com o preset entregue:
1) sem modo visual; 2) com modo visual. Le os relatorios e imprime dias/liquido. Reabre o terminal no fim."""
import os, re, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vp_run import parse, write16

EXE = r"C:\Program Files\Clear Investimentos MT5 Terminal\terminal64.exe"
DATA = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Terminal', '698B86206820B42976F30D28CAC50412')
PRESET = 'VantagePulse_B3_v107_LOTE1_STOP80_TP240.set'

def one(name, visual):
    ini = ('[Tester]\r\nExpert=VantagePulse_B3_v1.07.ex5\r\nExpertParameters=%s\r\nSymbol=WINZ26\r\nPeriod=M1\r\nModel=4\r\n'
           'ExecutionMode=12\r\nOptimization=0\r\nFromDate=2026.10.13\r\nToDate=2026.11.02\r\nForwardMode=0\r\nDeposit=700\r\n'
           'Currency=BRL\r\nLeverage=100\r\nVisual=%d\r\nReport=%s\r\nReplaceReport=1\r\nShutdownTerminal=1\r\n') % (PRESET, visual, name)
    ip = os.path.join(DATA, name + '.ini'); write16(ip, ini)
    rep = os.path.join(DATA, name + '.htm')
    if os.path.exists(rep): os.remove(rep)
    t0 = time.time()
    p = subprocess.Popen([EXE, '/config:' + ip])
    t_rep = None
    while p.poll() is None:
        time.sleep(3)
        if os.path.exists(rep) and t_rep is None: t_rep = time.time()
        if t_rep and time.time() - t_rep > 30: p.kill(); break
        if time.time() - t0 > 5400: p.kill(); break
    if not os.path.exists(rep):
        print(name, 'SEM RELATORIO (%.0fs)' % (time.time() - t0), flush=True); return
    r = parse(rep, 700)
    d = r['days']
    print('%s: ops %d liquido %.0f PF %.2f | dias positivos %d/%d | por dia %s (%.0fs)' % (
        name, r['trades'], r['net'], r['pf'], sum(1 for v in d.values() if v > 0), len(d),
        {k[5:]: round(v) for k, v in sorted(d.items())}, time.time() - t0), flush=True)

if __name__ == '__main__':
    one('VP_TESTE1_SEM_VISUAL', 0)
    one('VP_TESTE2_COM_VISUAL', 1)
    subprocess.Popen([EXE])   # reabre o terminal do usuario normalmente (perfil e EAs do grafico voltam)
    print('FIM11 terminal reaberto', flush=True)
