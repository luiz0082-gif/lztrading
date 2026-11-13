import sys, os, time; sys.path.insert(0,'.')
import userplat as U
OUT=os.path.join(U.ROOT,'MQL5','Experts','VantagePulse_B3','auditoria')
U.close_terminal()
try:
    t=dict(expert='VantagePulse_B3_v1.08.ex5',symbol='WINZ26_R',a='2026.10.14',b='2026.11.12',deposit=50000,preset='VantagePulse_B3_v108_LOTE1_STOP80_TP240.set',keep_csv='real_v108_base_14out-11nov_dep50k.csv')
    r=U.run_test(1,t,OUT)
    print('BASE no simbolo REAL, v1.08 STOP80/TP240, 1 ctr, deposito R$50k, 14/10-11/11:',U.fmt(r),flush=True)
    if r: print('   por dia:',{k[5:]:round(v) for k,v in sorted(r['days'].items())},flush=True)
finally:
    U.reopen(); print('FIM16',flush=True)
