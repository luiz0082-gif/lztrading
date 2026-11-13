"""Presets v1.05 e v1.06: gerados dos valores EXATOS dos testes e VERIFICADOS rodando o proprio arquivo.
So copia para as pastas de entrega se o resultado do arquivo bater com o que foi informado (tolerancia 2%)."""
import os, re, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vp_run import *

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
EXP = os.path.join(ROOT, 'MQL5', 'Experts', 'VantagePulse_B3')
TERM = os.path.join(os.environ['APPDATA'], 'MetaQuotes', 'Terminal', '698B86206820B42976F30D28CAC50412', 'MQL5')
DESTS = [os.path.join(EXP, 'presets'), os.path.join(TERM, 'Profiles', 'Tester'), os.path.join(TERM, 'Presets')]

BASE = {'InpVirtualStops': 'true', 'InpEnableCSV': 'false', 'InpShowPanel': 'false', 'InpVerboseBlocks': 'false', 'InpDiagnosticEveryMs': '0',
        'InpFastWindowMs': '1000', 'InpMidWindowMs': '3000', 'InpSlowWindowMs': '8000', 'InpMinFastMovePoints': '20', 'InpMinMidMovePoints': '32',
        'InpMaxHoldingSeconds': '25', 'InpTakeProfitPoints': '160', 'InpTrailArmPoints': '150', 'InpMinFastEfficiency': '0.12',
        'InpMinDirectionalConsistency': '0.50', 'InpMinSignalScore': '34', 'InpMinMidRegimeEfficiency': '0.0', 'InpMinSlowRegimeEfficiency': '0.0',
        'InpCooldownMs': '200', 'InpMinEntryGapMs': '200', 'InpMaxEntriesPerMinute': '20', 'InpLots': '1.0', 'InpLadderEnable': 'false',
        'InpLadderLevels': '10', 'InpLadderStep': '1.0', 'InpDailyLossLimitMoney': '0', 'InpIncludeFloatingInDaily': 'false'}
FIX105 = {'InpUseHardStop': 'true', 'InpUseTakeProfit': 'true', 'InpUseTrailing': 'true', 'InpUseMaxHolding': 'true', 'InpUseDailyLossLimit': 'false',
          'InpUseSpreadFilter': 'true', 'InpTrailArmPoints': '40', 'InpTrailDistancePoints': '10', 'InpTrailPeakPercent': '40'}
FIX106 = dict(FIX105, InpHardStopPoints='100', InpUseMoneyStop='false', InpMoneyStopAmount='150', InpUseTimeProfitExit='false',
              InpTimeProfitSeconds='8', InpTimeProfitMinPoints='5')

# (versao, nome, base+fix, overrides, ExecutionMode do teste original, esperado (ops, liquido))
CASES = [
 ('1.05', 'LOTE1_STOP100',   FIX105, dict(InpHardStopPoints='100', InpLadderEnable='false'), '11', (8497, 56766)),
 ('1.05', 'LOTE1_STOP150',   FIX105, dict(InpHardStopPoints='150', InpLadderEnable='false'), '11', (8123, 50600)),
 ('1.05', 'ESCADA1a10_STOP100', FIX105, dict(InpHardStopPoints='100', InpLadderEnable='true'), '11', (8497, 314997)),
 ('1.05', 'ESCADA1a10_STOP150', FIX105, dict(InpHardStopPoints='150', InpLadderEnable='true'), '11', (8123, 279809)),
 ('1.06', 'LOTE1_STOP100',   FIX106, dict(InpLadderEnable='false'), '12', (8497, 56766)),
 ('1.06', 'LOTE1_DINHEIRO_R20', FIX106, dict(InpUseHardStop='false', InpUseMoneyStop='true', InpMoneyStopAmount='20', InpLadderEnable='false'), '12', (8497, 56766)),
 ('1.06', 'ESCADA1a10_STOP100', FIX106, dict(InpLadderEnable='true'), '12', (8497, 314997)),
]

def defaults(ver):
    src = open(os.path.join(EXP, 'VantagePulse_B3_v%s.mq5' % ver), encoding='utf-8-sig').read(); d = {}
    for m in re.finditer(r'^input\s+[\w]+\s+(Inp\w+)\s*=\s*([^;]+);', src, flags=re.M): d[m.group(1)] = m.group(2).strip()
    return d

def effective(ver, fix, ov):
    d = defaults(ver)
    for l in read16(TPL).splitlines():
        m = re.match(r'^(Inp\w+)=([^|\r\n]*)', l)
        if m and m.group(1) in d: d[m.group(1)] = m.group(2).strip()
    for src in (BASE, fix, ov):
        for k, v in src.items():
            if k in d: d[k] = str(v)
            elif k.startswith('Inp'): raise KeyError('%s nao existe na v%s' % (k, ver))
    return d

def kv(path):
    d = {}
    for l in read16(path).splitlines():
        m = re.match(r'^(Inp\w+)=([^|\r\n]*)', l)
        if m: d[m.group(1)] = m.group(2).strip()
    return d

if __name__ == '__main__':
    tmp = os.path.join(EXP, 'presets_tmp'); os.makedirs(tmp, exist_ok=True)
    allok = True
    for ver, name, fix, ov, em, (eo, en) in CASES:
        d = effective(ver, fix, ov)
        d['InpShowPanel'] = 'true'; d['InpEnableCSV'] = 'true'
        fn = 'VantagePulse_B3_v%s_%s.set' % (ver.replace('.', ''), name)
        txt = '; VantagePulse B3 v%s - %s | valores EXATOS do teste (13/10-03/11/2026, R$700, latencia %s ms) | esperado: %d ops, liquido ~R$ %d\r\n' % (ver, name, em, eo, en)
        txt += '\r\n'.join(k + '=' + v for k, v in d.items()) + '\r\n'
        p = os.path.join(tmp, fn); open(p, 'wb').write(b'\xff\xfe' + txt.encode('utf-16-le'))
        run_ov = kv(p); run_ov.update({'InpEnableCSV': 'false', 'InpShowPanel': 'false', 'ExecutionMode': em})
        r = None
        for k in range(3):
            r = run('VantagePulse_B3_v' + ver, run_ov, '2026.10.13', '2026.11.04', deposit=700)
            if r: break
            time.sleep(8)
        ok = bool(r) and abs(r['trades'] - eo) <= max(5, 0.02 * eo) and abs(r['net'] - en) <= 0.02 * abs(en)
        print('%-44s arquivo: ops %s liquido %s | informado: ops %d liquido %d | %s' % (fn, r and r['trades'], r and round(r['net']), eo, en, 'IGUAL' if ok else 'DIFERENTE'), flush=True)
        if ok:
            for dst in DESTS:
                os.makedirs(dst, exist_ok=True)
                open(os.path.join(dst, fn), 'wb').write(open(p, 'rb').read())
        else:
            allok = False
    print('FIM7', 'todos verificados' if allok else 'HA DIFERENCAS', flush=True)
