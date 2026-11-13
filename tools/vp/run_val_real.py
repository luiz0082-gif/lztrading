import sys, os, time; sys.path.insert(0,'.')
import userplat as U
OUT=os.path.join(U.ROOT,'MQL5','Experts','VantagePulse_B3','auditoria')
U.close_terminal()
try:
    r=U.run_test(1,dict(expert='VantagePulse_B3_v1.08.ex5',symbol='WINZ26_R',a='2026.10.13',b='2026.11.02',preset='VantagePulse_B3_v108_LOTE1_STOP80_TP240.set',keep_csv='tester_v108_ref_SIMBOLO_REAL_13out-02nov.csv'),OUT)
    print('v1.08 referencia no simbolo REAL (WINZ26_R):',U.fmt(r),flush=True)
    if r: print('   por dia:',{k[5:]:round(v) for k,v in sorted(r['days'].items())},flush=True)
    print('   mesmo teste no simbolo original: ops 11142 | liquido 43639 | dias + 9/14',flush=True)
finally:
    U.reopen(); print('FIM15',flush=True)
