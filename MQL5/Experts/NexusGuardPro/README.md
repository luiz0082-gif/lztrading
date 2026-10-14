# Nexus Guard Pro

EA unificado a partir de Nexus Matrix R6.4.1 (TEL6 FIX1) e Nexus Guard Pro 1.076. Base de código: Guard 1.076.
Arquivo: `Nexus_Guard_Pro.mq5` (um único arquivo, sem includes). Compilado com MetaEditor: **0 erros, 0 warnings**.
**Não foi testado em execução** (nem demo, nem Strategy Tester). Ver "Não verificado".

Análise que originou as mudanças: `docs/relatorios/RELATORIO-NEXUS-2026-10-06.md`.

## Motor (inalterado)
Setups SWEEP_REVERSAL / BREAKOUT_CONTINUATION em vela fechada, mapa de níveis, score, regime, perfis M1/M5/M30, preflight com `OrderCheck`, spread adaptativo, calendário MQL5, solvers monetários por `OrderCalcProfit`, proteção imediata/atrasada/nenhuma, stop opcional.

## Removido
- Notícias externas (FED/BLS/BEA/GDELT/Kitco, `WebRequest`, CSVs `NEWS_*`). Mantido o calendário do MQL5.
- Modo Runner (`TARGET_MONEY_THEN_RUNNER`) e seus estados.
- CSVs legados Audit, Candles, Trades, Execution, PositionManagement, RiskState, RunConfig (duplicavam o TEL). Fica o `JOURNAL` (log humano) + família TEL.
- Inputs: `InpTrailingMinimumLockMoney`, `InpTrailingDistanceMoney`, `InpTEL6WriteLegacyCSVs`, `InpEnableAuditCSV`, `InpEnableCandleCSV`, `InpAuditSnapshotSeconds`, `InpTesterAuditSnapshotSeconds`, `InpAuditLiveScoreStep`, grupos de notícias externas.

## Trailing monetário (lei do PieceTrend) — `TRAIL_MONEY`
Arma quando o **pico líquido** ≥ `InpTrailingActivationMoney` (A) e remove o TP.
`D = InpTrailRatio × A × max(pico/A, 1)^InpTrailExponent` (0,60 e 0,82 por padrão) e `piso = pico − D`.
O SL do broker só avança (passo mínimo `InpTrailingStepMoney`). Se o preço cruzar o piso sem SL do broker protegendo, fecha a mercado (`TRAIL_FLOOR_BREACHED`). Os modos POINTS/ATR/STRUCTURE continuam disponíveis.

## Correções
| Achado | Mudança |
|---|---|
| Fechamento manual/stop-out fora das estatísticas | Posição é do Nexus se o deal de **entrada** tem magic Nexus (`PositionOwnedByNexus`); vale para stats diárias, perdas consecutivas e telemetria (`POSITION_CLOSED_EXTERNALLY`) |
| Cooldown inoperante | `InpCooldownBars` conta após encerrar posição; `InpCooldownAfterRejectBars` (0 = comportamento anterior) após candidato rejeitado |
| Sem limite de perda aberta | Disjuntor opcional `InpUseFloatingBreaker` (por posição e total; alerta / pausa / fecha+pausa). **Desligado por padrão** |
| Baseline diário com saldo alterado | Rebase por depósito/saque (`DEAL_TYPE_BALANCE`) e por salto de equity >20% sem negócio |
| `PROFIT_MANAGEMENT` a cada tick | Amostragem `InpTEL6ProfitSampleSeconds` / `InpTEL6ProfitSampleMoney` + mudança de SL/TP/lock/trail |
| Spam `GLOBAL_BLOCK` | Grava só quando muda gate/motivo |
| Config inválida silenciosa | `Alert()` ao mudar a configuração bloqueada |
| `DurationSeconds` sempre 0 | Calculado do histórico no `POSITION_CLOSED` |
| `HistorySelectByPosition` por tick | Cache de custos (10 s; invalidado em transação) |
| Retcode 10029/10036 em modify | Backoff de 2 s / 5 s |
| CLV do reteste fixo | `InpRetestConfirmCLV` (0,55 = comportamento anterior) |
| Risco sem stop invisível | Evento `RISK_PROFILE` no INIT (WR de equilíbrio, disjuntor); MAE/plano no painel |

## Telemetria (schema 7)
Pasta: `MQL5\Files\NEXUS_GUARD_PRO\<SÍMBOLO>\`. Arquivos `NEXUS_GUARD_PRO_<ASSUNTO>_S7_<dia>_<símbolo>_<tf>_<hash>_<run>_PARTnnn.csv`.
Colunas de notícias externas e Runner saíram, logo schema 6 → 7 (arquivos S6 não são reaproveitados).

## Painel
Reescrito: px lógicos × DPI (`TERMINAL_SCREEN_DPI`) × escala; texto medido com `TextGetSize`; origem calculada para qualquer canto; cache por diferença; faixa "por que não opera" no topo; blocos Risco/Dia, Posição, Sinal/Pipeline (chips), Mercado/MTF, Telemetria e comandos. **Não foi visto renderizado.**

## Presets (`presets/*.set`, UTF-16, carregar em Entradas > Carregar)
- `Nexus_Guard_Pro_M1_SemSL.set`: lote fixo 0,01, TP $5, trail ativa em $4 (passo $0,30), meta diária $15, sem TimeStop.
- `Nexus_Guard_Pro_M5_SemSL.set`: risco 0,25% (limitado a $15 pelo stop de referência), TP $5, trail ativa em $4,50 (passo $0,80), TimeStop 36 barras.
- Ambos: `InpProtectionMode=PROTECTION_NONE` (SL configurado em `InpStopMoney`, **não enviado ao broker**), disjuntor de perda flutuante configurado e **desligado**, `InpTradingEnabled=false`, mesmo magic (um trade por símbolo entre os dois).

## Perfis de referência (antes dos presets)
- **A "Scalp sem SL"**: M1, `RISK_FIXED_LOT`, `STOP_MONEY` de referência, `InpProtectionMode=PROTECTION_NONE` ou `DELAYED`, `InpTargetMoney`/`InpTrailingActivationMoney` pequenos, **`InpUseFloatingBreaker=true`**.
- **B "Risco controlado"**: M5, `RISK_PERCENT_EQUITY`, `STOP_STRUCTURE_CAPPED_BY_MONEY`, `PROTECTION_IMMEDIATE`, `InpUseTimeStop=true`.

## Não verificado
Execução em demo, Strategy Tester, o painel no seu monitor (DPI/escala), o trailing PieceTrend em trades reais, o disjuntor, o rebase de baseline e a resolução de dono de posição no fechamento manual. `InpTradingEnabled=false` por padrão.
