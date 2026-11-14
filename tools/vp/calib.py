"""Calibragem em janelas curtas (<=5 dias) na plataforma do usuario, simbolo WINZ26_R (100% ticks reais).
Uso: python calib.py <arquivo_de_fila.py> ; a fila define CONFIGS = [(rotulo, overrides)], WIN=(a,b), SYM."""
import sys, os, json, time, importlib.util
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import userplat as U

def main(queue_path, out_path):
    spec = importlib.util.spec_from_file_location('q', queue_path); q = importlib.util.module_from_spec(spec); spec.loader.exec_module(q)
    U.close_terminal()
    try:
        for i, (label, over) in enumerate(q.CONFIGS):
            t = dict(expert='VantagePulse_B3_v1.08.ex5', symbol=getattr(q, 'SYM', 'WINZ26_R'), a=q.WIN[0], b=q.WIN[1],
                     deposit=getattr(q, 'DEP', 700), preset='VP_USER_BASE.set', over=over)
            r = U.run_test(i + 1, t)
            line = '%-34s %s' % (label, U.fmt(r))
            print(line, flush=True)
            rec = dict(label=label, over=over, win=q.WIN, sym=t['symbol'], res=None if not r else dict(
                trades=r['trades'], net=r['net'], pf=r['pf'], minbal=r['minbal'], dd=r['dd'], win=r['win'], days=r['days'], manifest=r.get('manifest')))
            open(out_path, 'a', encoding='utf-8').write(json.dumps(rec) + '\n')
    finally:
        U.reopen(); print('FIM', flush=True)

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
