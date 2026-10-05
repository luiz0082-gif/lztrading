---
name: ea-panel
description: Use when designing, implementing, fixing, or reviewing an MQL5 EA operational panel, HUD, dashboard, chart objects, buttons, minimize/restore behavior, or visual telemetry.
---
# EA Panel

Read `docs/PAINEL.md`.

## Purpose
The panel is operational. It must quickly answer:
- What is the EA seeing?
- What did it decide?
- Why?
- What is open?
- How much is at risk?

## Priority
State → Decision → Risk → Management → Telemetry.

## Rules
- Reuse the project's visual system.
- Do not create decorative widgets without operational value.
- Minimized state must retain a reliable restore control.
- Buttons must survive redraw/resize/minimize.
- Critical information cannot depend on hover.
- Do not make an EA's semantics identical to another EA just because the panels look similar.
- Market lines/zones must correspond to actual strategy logic.