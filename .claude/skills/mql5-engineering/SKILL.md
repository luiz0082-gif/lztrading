---
name: mql5-engineering
description: Use for creating, modifying, debugging, compiling, auditing, or reviewing MQL5 Expert Advisors, indicators, scripts, and reusable Include libraries in LZ Trading.
---
# MQL5 Engineering

Read `CLAUDE.md` and `docs/ARQUITETURA.md` first.

## Mandatory
- Work with real MQL5 APIs.
- Deliver complete compilable files when code is requested.
- Trace every dependency.
- Preserve existing behavior unless the request changes it.
- Normalize price by tick size and volume by broker volume step.
- Check trade permissions, symbol mode, filling, stops level, margin and trade retcodes.
- Distinguish tester behavior from live execution.
- Never hide broker rejection.
- Operator profile: the user does NOT trade with Stop Loss. Always implement the SL input but keep it disabled by default (`InpUseStopLoss=false`); never enable it by default. Compensate with monetary limits, daily limit, circuit breaker and exposure telemetry.

## EA flow
Prefer:
`OnInit → validate → data → state → protections → management → signal → execution → telemetry`.

Open-position protection must not depend on a fresh entry signal.

## Debugging
When an EA does not trade, diagnose in this order:
1. terminal/account permissions;
2. symbol/trading mode;
3. data availability;
4. session/timezone;
5. signal conditions;
6. risk/volume/margin;
7. broker stops/filling;
8. trade retcode.

Do not "loosen" strategy filters before proving the signal actually exists.

## Changes
For a localized bug, make a localized change. Do not rewrite an EA merely because the code is imperfect.