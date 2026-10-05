---
name: strategy-lab
description: Use when designing, formalizing, comparing, testing, or challenging a trading strategy, including price action, indicator, session, structure, flow, breakout, momentum, mean reversion, or statistical ideas.
---
# Strategy Lab

Read `docs/ESTRATEGIAS.md` and `docs/BACKTEST.md`.

## Separate four things
1. observation;
2. hypothesis;
3. mechanism;
4. tested evidence.

Never present a hypothesis as a discovered edge.

## Formalize
Define mathematically:
- data;
- timeframe;
- state;
- signal;
- trigger;
- invalidation;
- entry;
- exit;
- risk;
- costs;
- no-trade conditions.

Subjective words must become measurable rules.

## Challenge the thesis
Always ask:
- What would falsify it?
- What is the placebo?
- Could this be trend exposure?
- Could it be volatility exposure?
- Is the result caused by one regime?
- Is the cost larger than the edge?
- Did parameter selection consume the sample?

## Robustness
Prefer parameter regions over a single optimum. Check periods, regimes, sessions and costs.

Do not recommend live deployment based only on a profitable backtest.