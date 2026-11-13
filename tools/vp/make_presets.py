"""Gera os .set da v1.07 a partir dos valores EXATOS usados nos testes (ini do usuario + run12.base + overrides).
Nada fica no padrao do codigo por acidente: toda chave Inp* do EA vai explicita no arquivo."""
import os, re, sys, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import run12
from vp_run import TPL, read16

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SRC = os.path.join(ROOT, 'MQL5', 'Experts', 'VantagePulse_B3', 'VantagePulse_B3_v1.07.mq5')
TERM = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Terminal', '698B86206820B42976F30D28CAC50412', 'MQL5')

def defaults():
    src = open(SRC, encoding='utf-8-sig').read(); d = {}
    for m in re.finditer(r'^input\s+[\w]+\s+(Inp\w+)\s*=\s*([^;]+);', src, flags=re.M):
        v = m.group(2).strip()
        if v in ('VP_STOP_OFF',): v = '0'
        d[m.group(1)] = v
    return d

def effective(overrides):
    """defaults do EA < ini do usuario (v1.02) < run12.base < overrides  (= o que os testes rodaram)."""
    d = defaults()
    for l in read16(TPL).splitlines():
        m = re.match(r'^(Inp\w+)=([^|\r\n]*)', l)
        if m and m.group(1) in d: d[m.group(1)] = m.group(2).strip()
    for k, v in run12.base.items():
        if k in d: d[k] = str(v)
    for k, v in overrides.items():
        assert k in d, k
        d[k] = str(v)
    # painel e CSV ligados no preset de uso (nao afetam a logica; nos testes ficam desligados por velocidade)
    d['InpShowPanel'] = 'true'; d['InpEnableCSV'] = 'true'
    return d

CFG = {
 'LOTE1_STOP80_TP240':        dict(InpStopType=1, InpStopPoints=80,  InpTakeProfitPoints=240, InpLadderEnable='false'),
 'LOTE1_STOP60_TP240':        dict(InpStopType=1, InpStopPoints=60,  InpTakeProfitPoints=240, InpLadderEnable='false'),
 'ESCADA1a10_STOP80_TP240':   dict(InpStopType=1, InpStopPoints=80,  InpTakeProfitPoints=240, InpLadderEnable='true'),
 'ESCADA1a10_STOP60_TP240':   dict(InpStopType=1, InpStopPoints=60,  InpTakeProfitPoints=240, InpLadderEnable='true'),
 'LOTE1_STOP100_TP160':       dict(InpStopType=1, InpStopPoints=100, InpTakeProfitPoints=160, InpLadderEnable='false'),
 'ESCADA1a10_STOP100_TP160':  dict(InpStopType=1, InpStopPoints=100, InpTakeProfitPoints=160, InpLadderEnable='true'),
}

if __name__ == '__main__':
    # remove presets antigos que NAO correspondiam ao testado (gerados por mim; v105/v106 e v107 antigos)
    removed = []
    for base in (os.path.join(ROOT, 'MQL5', 'Experts', 'VantagePulse_B3', 'presets'), os.path.join(TERM, 'Profiles', 'Tester'), os.path.join(TERM, 'Presets')):
        for p in glob.glob(os.path.join(base, 'VantagePulse_B3_v10[567]_*.set')):
            os.remove(p); removed.append(os.path.basename(p))
    for name, ov in CFG.items():
        d = effective(ov)
        fn = 'VantagePulse_B3_v107_' + name + '.set'
        txt = '; VantagePulse B3 v1.07 - ' + name + ' | gerado dos valores EXATOS dos testes (30 dias, 13/10-11/11/2026)\r\n' + '\r\n'.join(k + '=' + v for k, v in d.items()) + '\r\n'
        for base in (os.path.join(ROOT, 'MQL5', 'Experts', 'VantagePulse_B3', 'presets'), os.path.join(TERM, 'Profiles', 'Tester'), os.path.join(TERM, 'Presets')):
            os.makedirs(base, exist_ok=True)
            open(os.path.join(base, fn), 'wb').write(b'\xff\xfe' + txt.encode('utf-16-le'))
    print('removidos:', sorted(set(removed)))
    print('gerados:', ['VantagePulse_B3_v107_' + n + '.set' for n in CFG])
