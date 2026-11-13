# encerra o terminal do harness que ficou travado depois de salvar o relatorio (so processos de C:\ClearMM_Tester)
while ($true) {
  Start-Sleep 10
  $h = Get-ChildItem 'C:\ClearMM_Tester' -Filter 'vp_*.htm' -ErrorAction SilentlyContinue | Where-Object { ((Get-Date) - $_.LastWriteTime).TotalSeconds -gt 25 }
  if ($h) { Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -like 'C:\ClearMM_Tester*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } }
}
