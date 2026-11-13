import sys, os, shutil, glob, time; sys.path.insert(0,'.')
import userplat as U
U.close_terminal()
try:
    t0=time.time()
    csv=U.run_script('VantagePulse_ExportTicks',{'InpSymbol':'WIN$N','InpFrom':'2026.06.01','InpTo':'2026.10.14','InpExitTerminal':'false'},'VP_export_ticks.csv',timeout=5400)
    print('exportacao OOS (WIN$N 01/06-13/10):','OK (%.0fs)'%(time.time()-t0) if csv else 'FALHOU/INCOMPLETA',flush=True)
    files=glob.glob(os.path.join(U.DATA,'MQL5','Files','VP_ticks_*.bin'))
    for f in files: shutil.move(f, os.path.join(r'C:\VP_data_oos',os.path.basename(f)))
    q=os.path.join(U.DATA,'MQL5','Files','VP_export_ticks.csv')
    if os.path.exists(q): shutil.copy(q, r'C:\VP_data_oos\VP_export_ticks.csv')
    print('arquivos movidos:',len(files),flush=True)
finally:
    U.reopen(); print('FIM18',flush=True)
