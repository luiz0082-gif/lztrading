# LZ Design System — Painel HUD (v2.0)

Implementação: `MQL5/Include/LZ/LZPanel.mqh` (classe `CLZPanel`). Complementa `docs/PAINEL.md` (hierarquia e regras); aqui estão os tokens e componentes. Primeiro uso: `HFT_RETAIL` v2.6.

## Princípios
Fundo quase preto azulado, ciano como marca, verde/vermelho só para resultado, âmbar para bloqueio, dourado para meta. Monoespaçado (Consolas) nos dados, Segoe UI Semibold no título. Sem animação e sem piscar: objetos são reaproveitados por nome.

## Tokens de cor
| Token | Valor | Uso |
|---|---|---|
| `LZ_BG` / `LZ_SURFACE` / `LZ_SURFACE2` | 7,11,20 / 12,18,32 / 18,27,48 | fundo / base / elevado |
| `LZ_LINE` | 32,46,76 | hairlines, trilho de barra |
| `LZ_ACCENT` / `LZ_ACCENT_DIM` | 0,224,255 / 0,96,120 | marca, foco |
| `LZ_PROFIT` / `LZ_LOSS` | 0,255,157 / 255,59,107 | lucro-ok / perda-erro |
| `LZ_WARN` / `LZ_GOLD` / `LZ_INFO` | 255,184,0 / 255,214,10 / 125,145,255 | bloqueio / meta / posição |
| `LZ_TEXT` / `LZ_MUTED` | 226,234,248 / 112,130,162 | texto / rótulos |

Espaçamento: `LZ_PAD` 12, `LZ_ROW` 17. Largura padrão 400 px.

## Componentes
`Header` (título, subtítulo, chip de estado, botão `-`/`+`), `Strip` (linha de decisão: ARMADO / BLOQUEIO / POSICAO / META / PARADO), `Section`, `KV`, `KV2`, `Bar` (marcas em 25/50/75 %), `Gap`. Ciclo: `Begin()` → componentes → `End()`. Em `OnChartEvent`: `if(panel.OnEvent(id, sparam)) redesenhar;`.

## Regras de uso
- Ordem das seções: estado → decisão → mercado → posição → risco → desempenho → telemetria.
- A `Strip` é obrigatória e sempre visível: responde "por que opera / não opera".
- Cor de lucro/perda só para P&L; ausência de proteção (ex.: `SEM SL`) em âmbar.
- Minimizado mostra só o header; o botão existe nos dois estados e o estado persiste em `GlobalVariable` (`<prefixo>min`).
- Termos iguais entre EAs: RISCO, POSICAO, BLOQUEIO, TELEMETRIA.

## Limites
Não testado visualmente em gráfico real (só compilado). Larguras de texto usam 7 px/caractere (Consolas 9) como aproximação; ajuste `LZ_CHAR_W` se o chip de estado ficar apertado em DPI alto.

## v2.0 (aditivo; a API v1 não mudou)
Primeiro uso: `VEGAR` (`Vegar_Panel.mqh`). Arquivo continua ASCII-only.

| Componente | Uso |
|---|---|
| `HeaderEx(title, sub, chip1, c1, chip2, c2, clock, accent)` | título 14pt, dois chips (motor / online), relógio, faixa de acento na cor da decisão |
| `StripHero(label, text, clr)` | faixa de decisão tingida, texto 11pt; substitui `Strip` quando a decisão é o foco |
| `Hero(label, value, clr, side, sideClr)` | número grande (ex.: floating) |
| `Steps(labels[], states[], n)` | pipeline segmentado: `LZ_STEP_PENDING/ACTIVE/DONE/FAILED` (concluída=ciano, ativa=azul, falha=vermelho) |
| `ChipBegin / ChipFlow / ChipEnd` | chips com quebra de linha automática |
| `Button(id, x, y, w, h, text, accent, pressed, filled)` | botão com acento; sobrevive ao redesenho |
| `SetScale(pct)`, `SetOpacity(pct)`, `SetMinButtonId(id)`, `SetMinimized(b)` | configuração após `Init` |

Tokens novos: `LZ_SELL` (vendedor, laranja), `LZ_FONT_HEAD` (Bahnschrift SemiBold; o Windows substitui se faltar), `LZ_Mix(a,b,alpha)` para tons apagados de borda/fundo.

Limites: não validado visualmente em gráfico real; escala e opacidade respeitam os inputs `InpEscalaPainelPct` / `InpOpacidadePainelPercent` do Vegar.
