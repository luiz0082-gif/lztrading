"""Gera TODOS os presets do VantagePulse (v1.05, v1.06, v1.07) em um unico lote:
1) apaga todos os VantagePulse_B3_v10*.set das 3 pastas de entrega;
2) gera cada .set dos valores EXATOS dos testes;
3) roda o PROPRIO ARQUIVO no harness e compara com o resultado informado (tolerancia 2%);
4) so entao copia para as pastas (mesmo lote, mesmos horarios)."""
import glob, os, re, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_presets as m7
import make_presets_old as mo
from vp_run import *

DESTS = mo.DESTS
CASES = []
for ver, name, fix, ov, em, (eo, en) in mo.CASES:
    CASES.append(dict(ver=ver, name=name, d=mo.effective(ver, fix, ov), em=em, a='2026.10.13', b='2026.11.04', eo=eo, en=en,
                      desc='13/10-03/11/2026 (15 pregoes)'))
V107 = {'LOTE1_STOP60_TP240': (9349, 77023), 'ESCADA1a10_STOP60_TP240': (9349, 437498),
        'LOTE1_STOP80_TP240': (9003, 69990), 'ESCADA1a10_STOP80_TP240': (9003, 377657),
        'LOTE1_STOP100_TP160': (9528, 51225), 'ESCADA1a10_STOP100_TP160': (9528, 271958)}
for name, ov in m7.CFG.items():
    eo, en = V107[name]
    CASES.append(dict(ver='1.07', name=name, d=m7.effective(ov), em='12', a='2026.10.13', b='2026.11.12', eo=eo, en=en,
                      desc='13/10-11/11/2026 (30 dias, 21 pregoes)'))

def kv(path):
    d = {}
    for l in read16(path).splitlines():
        mm = re.match(r'^(Inp\w+)=([^|\r\n]*)', l)
        if mm: d[mm.group(1)] = mm.group(2).strip()
    return d

if __name__ == '__main__':
    # 1) apaga tudo do VantagePulse (presets) nas 3 pastas
    gone = []
    for base in DESTS:
        for p in glob.glob(os.path.join(base, 'VantagePulse_B3_*.set')):
            os.remove(p); gone.append(os.path.basename(p))
    print('apagados %d arquivos (%d nomes distintos)' % (len(gone), len(set(gone))), flush=True)
    tmp = os.path.join(mo.EXP, 'presets_tmp'); os.makedirs(tmp, exist_ok=True)
    ok_files = []
    for c in CASES:
        ver, name = c['ver'], c['name']
        d = dict(c['d']); d['InpShowPanel'] = 'true'; d['InpEnableCSV'] = 'true'
        fn = 'VantagePulse_B3_v%s_%s.set' % (ver.replace('.', ''), name)
        txt = '; VantagePulse B3 v%s - %s | valores EXATOS do teste: %s, R$700, latencia %s ms | esperado ~%d ops, liquido ~R$ %d\r\n' % (ver, name, c['desc'], c['em'], c['eo'], c['en'])
        txt += '\r\n'.join(k + '=' + v for k, v in d.items()) + '\r\n'
        p = os.path.join(tmp, fn); open(p, 'wb').write(b'\xff\xfe' + txt.encode('utf-16-le'))
        ov = kv(p); ov.update({'InpEnableCSV': 'false', 'InpShowPanel': 'false', 'ExecutionMode': c['em']})
        r = None
        for k in range(3):
            r = run('VantagePulse_B3_v' + ver, ov, c['a'], c['b'], deposit=700)
            if r: break
            time.sleep(8)
        ok = bool(r) and abs(r['trades'] - c['eo']) <= max(5, 0.02 * c['eo']) and abs(r['net'] - c['en']) <= 0.02 * abs(c['en'])
        dd = r['days'] if r else {}
        print('%-44s arquivo: ops %s liquido %s | informado: ops %d liquido %d | dias positivos %d/%d (pior dia %s) | %s' % (
            fn, r and r['trades'], r and round(r['net']), c['eo'], c['en'], sum(1 for v in dd.values() if v > 0), len(dd),
            round(min(dd.values())) if dd else '-', 'IGUAL' if ok else 'DIFERENTE'), flush=True)
        if ok: ok_files.append((fn, p))
    # 4) copia o lote verificado (mesmo instante)
    for dst in DESTS:
        os.makedirs(dst, exist_ok=True)
        for fn, p in ok_files:
            open(os.path.join(dst, fn), 'wb').write(open(p, 'rb').read())
    for fn, p in ok_files: os.remove(p)
    os.rmdir(tmp)
    print('FIM9 copiados %d de %d' % (len(ok_files), len(CASES)), flush=True)
