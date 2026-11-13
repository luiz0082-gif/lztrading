# CSVs de telemetria do VantagePulse B3

Colunas: `server_time, tick_time_msc, event, detail, direction, score, bid, ask, spread_points, value1, value2, daily_net`.
Eventos úteis: `ENTRY_CONFIRMED` (latency_us no detail), `EXIT_SENT` (motivo, pts, pico), `DEAL_TRANSACTION` (profit/comissão), `ENTRY_BLOCK`, `SIGNAL_DIAG`.

| Arquivo | Origem |
|---|---|
| `ao_vivo_demo_WINZ26_20261113.csv` | EA v1.05 rodando AO VIVO na conta demo Clear em 13/11/2026 (base do diagnóstico: 0 de 163 operações atingiram o alvo). |
| `tester_plataforma_usuario_v107_STOP80_13out-02nov.csv` | Teste feito NA PLATAFORMA DO USUÁRIO (preset v107_LOTE1_STOP80_TP240, 13/10–02/11): +R$ 43.639, 9/14 dias positivos. Resultado de referência válido. |
| `tester_plataforma_usuario_agente3001_13nov_1509.csv` | Teste do usuário em 13/11 15:09 (agente 3001). Parâmetros: ver `tester_ini/`. |
| `tester_harness_meu_ultimo_teste_base_incompleta.csv` | Último teste no harness do Claude (`C:\ClearMM_Tester`), cuja base de ticks de outubro estava incompleta; resultados desse harness estão superestimados. Mantido só para comparação. |
