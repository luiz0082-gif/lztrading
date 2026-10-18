---
name: data-analysis
description: Use for MT5 logs, CSV telemetry, trade histories, backtest reports, optimization outputs, and comparing EA runs outside a dedicated MarketBehaviorAnalyzer (MBA) research task. For MBA datasets, pattern discovery, clock-time scans, or point-reachability studies, use mba-research instead.
---
# Trading Data Analysis

For any MarketBehaviorAnalyzer-specific investigation, defer to .claude/skills/mba-research/SKILL.md and do not use this generic workflow as the sole analysis protocol.

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