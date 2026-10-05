---
name: data-analysis
description: Use when analyzing MT5 logs, CSV telemetry, trade histories, backtest reports, optimization outputs, market-behavior datasets, or comparing EA runs.
---
# Trading Data Analysis

Read `docs/ANALISE-DADOS.md` and `docs/TELEMETRIA.md`.

## First inspect
- schema;
- timezone;
- EA/version;
- symbol;
- timeframe;
- row count;
- missing fields;
- duplicates;
- timestamp gaps.

## Reconstruct
When possible reconstruct:
`SIGNAL → ORDER_SEND → OPEN → MODIFY → CLOSE`.

Separate strategy quality from execution quality and management quality.

## Report
Distinguish:
- facts;
- inferences;
- hypotheses.

Analyze not only profit:
- expectancy;
- drawdown;
- PF;
- win/loss distribution;
- MFE/MAE;
- duration;
- costs;
- slippage;
- rejection rate;
- block reasons;
- concentration.

Never claim a bug merely because an unusual result exists.