import sys, os, shutil, glob, time; sys.path.insert(0,'.')
import userplat as U
U.close_terminal()
try:
    t0=time.time()
    csv=U.run_script('VantagePulse_ExportTicks',{'InpSymbol':'WINZ26','InpFrom':'2026.10.14','InpTo':'2026.11.12','InpExitTerminal':'false'},'VP_export_ticks.csv',timeout=3000)
    print('exportacao:','OK (%.0fs)'%(time.time()-t0) if csv else 'FALHOU',flush=True)
    files=glob.glob(os.path.join(U.DATA,'MQL5','Files','VP_ticks_*.bin'))
    for f in files: shutil.move(f, os.path.join('C:\VP_data',os.path.basename(f)))
    if csv: shutil.copy(csv, os.path.join('C:\VP_data','VP_export_ticks.csv'))
    print('arquivos movidos para C:\VP_data:',len(files),flush=True)
finally:
    U.reopen(); print('FIM17',flush=True)
