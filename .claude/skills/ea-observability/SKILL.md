---
name: ea-observability
description: Use when designing or reviewing telemetry, CSV schemas, logs, diagnostics, event tracking, circuit breakers, or operational visibility for an MQL5 system.
---
# EA Observability

Read `docs/TELEMETRIA.md`.

## Required questions
A production EA should answer:
- Why did it enter?
- Why did it not enter?
- What was the risk?
- What changed the stop?
- Why did it close?
- Did the broker accept or reject the order?
- What state was the EA in?

## Event model
Use explicit events such as:
INIT, MARKET_STATE, SIGNAL, BLOCK, ORDER_SEND, ORDER_REJECTED, POSITION_OPEN, POSITION_MODIFY, POSITION_CLOSE, RISK, ERROR.

## CSV
Keep CORE fields stable. Add strategy-specific fields separately when possible. Version incompatible schema changes.

Telemetry must observe the strategy, not silently change it.

## Diagnostics
Prefer actionable reasons over generic messages like ERROR or BLOCKED.