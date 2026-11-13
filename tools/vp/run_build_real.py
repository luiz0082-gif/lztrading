import sys, os, shutil, time; sys.path.insert(0,'.')
import userplat as U
OUT=os.path.join(U.ROOT,'MQL5','Experts','VantagePulse_B3','auditoria'); os.makedirs(OUT,exist_ok=True)
U.close_terminal()
t0=time.time()
csv=U.run_script('VantagePulse_BuildRealSymbol',{'InpSource':'WINZ26','InpTarget':'WINZ26_R','InpFrom':'2026.10.13','InpTo':'2026.11.12','InpExitTerminal':'false'},'VP_real_symbol_build.csv',timeout=2400)
print('construcao do simbolo:', 'OK (%.0fs)'%(time.time()-t0) if csv else 'FALHOU', flush=True)
if csv:
    shutil.copy(csv, os.path.join(OUT,'VP_real_symbol_build.csv')); print(open(os.path.join(OUT,'VP_real_symbol_build.csv'),encoding='latin-1').read()[-900:], flush=True)
    r=U.run_test(1,dict(expert='VantagePulse_B3_v1.08.ex5',symbol='WINZ26_R',a='2026.10.13',b='2026.11.02',preset='VantagePulse_B3_v108_LOTE1_STOP80_TP240.set',keep_csv='tester_v108_ref_SIMBOLO_REAL_13out-02nov.csv'),OUT)
    print('v1.08 referencia no simbolo REAL:',U.fmt(r),flush=True)
    if r: print('   por dia:',{k[5:]:round(v) for k,v in sorted(r['days'].items())},flush=True)
    print('   (mesmo teste no simbolo original: ops 11142 | liquido 43639 | dias + 9/14)',flush=True)
U.reopen(); print('FIM14',flush=True)
