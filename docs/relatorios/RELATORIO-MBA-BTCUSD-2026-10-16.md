# Relatório MBA — BTCUSD (Raw Trading Ltd) — 2026-10-16

Status: pesquisa. Nenhuma estratégia lucrativa provada. Dados: M1 203k, M5 149k, M15 96k, M30 48k, H1 48k candles (2021→2026), schema v2.

## Resultado
**Classe C/D: nenhum padrão direcional operável após custos.**

1. **Varredura** (39.717 testes, 5 TFs, 65/35 por tempo, Wilson, BH): para a direção do candle atual (`bull`) só 1 validado (esperado ao acaso ≈ 5%). Os ~2.500 "validados" estão em alvos de candle seguinte, e dependem quase todos de `close_position` (fechou na mínima → próximo sobe; fechou na máxima → próximo desce), um efeito de reversão/microestrutura de barras de bid.
2. **Custo**: M1 cp<0,2 → retorno seguinte +0,52 bps (treino), +0,13 bps (validação); spread 0,7–1,7 bps. M5 +0,39 bps na validação vs spread 1,3; M15 some (−0,05). Edge < custo e em queda. Não operável.
3. **Candle de 00:00 do servidor (17:00 NY)**: H1 +8,4 bps (t=7,2), 2021–2025 positivo todos os anos (+7 a +15 bps), mas **2026 ≈ 0** (H1: +0,1, H2: −0,2). Parte do efeito é o gap de rollover (−3,6 bps) e barra de bid. Hipótese não verificada: mudança de regime ou fim da anomalia. **Não usar** sem nova evidência em 2026.
4. Spread mediano normal ≈ 1,8 bps; custo ida e volta realista > o edge de qualquer padrão acima.

## Limites
Sem tick-level, sem swap/funding, sem comissão. Dados de 2026 são o teste fora da amostra mais relevante e invalidam o padrão do 00:00.

## Critério de falsificação para retomar
Só reabrir se o efeito 00:00 voltar com média > +3 bps por ≥ 3 meses seguidos em dado novo, ou se um padrão tiver média líquida > 0 em validação com spread real.

CSV: `docs/relatorios/mba/btc_scan_validados_top200.csv`.
