# tools/vp: ferramentas e logs dos testes do VantagePulse B3

Scripts (Python) que rodam backtests do VantagePulse no tester do MT5 e geram os presets. Os arquivos `*.out` são as saídas brutas de cada rodada de teste, mantidas como registro.

**ATENÇÃO (13/11/2026): os resultados dos `*.out` foram obtidos num harness (`C:\ClearMM_Tester`) cuja base de ticks de outubro/2026 estava incompleta (~3 MB a menos que a do tester do usuário). São resultados SUPERESTIMADOS**, principalmente em 16–22/10. O resultado válido de referência é o do tester do usuário: preset `v107_LOTE1_STOP80_TP240`, 13/10–02/11, +R$ 43.639, 9/14 dias positivos (ver `docs/VantagePulse_B3.md`).

- `vp_run.py`: executa um backtest (ini + overrides) e extrai métricas do relatório.
- `make_presets*.py`: geram os `.set` a partir dos valores exatos dos testes e verificam rodando o próprio arquivo.
- `run_user_platform.py`: roda 2 testes na plataforma real do usuário (fecha e reabre o Clear).
- `run*.py` / `grid*.py` / `base*.py`: baterias de teste usadas ao longo do trabalho.
- `watchdog.ps1`: encerra o terminal do harness que trava ao fechar.

Antes de qualquer teste novo: copiar a base de ticks do tester do usuário (`%APPDATA%\MetaQuotes\Tester\<hash>\bases\...`) para o harness e validar que um preset dá o mesmo resultado nos dois ambientes.
