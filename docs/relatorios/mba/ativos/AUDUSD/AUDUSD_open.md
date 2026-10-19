# AUDUSD — relatório completo MBA (gerado em 2026-10-17 02:27)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | First Prudential Markets Limited |
| servidor | FPMarketsSC-Demo |
| simbolo | AUDUSD |
| descricao | Australian Dollar vs US Dollar |
| digitos | 5 |
| ponto | 0.00001 |
| tick_size | 0.00001 |
| tick_value | 1.00000 |
| contrato | 100,000.00000 |
| lote_min | 0.01000 |
| swap_long | -0.37000 |
| swap_short | -2.68000 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-01-22 00:27 | 2026-10-16 23:58 | 232 | 1,160,518 | 0 | 123,607 | 123,607 | 0 |
| M5 | 106,505 | 2025-05-15 03:15 | 2026-10-16 23:50 | 80 | 576 | 0 | 24,749 | 24,749 | 0 |
| M15 | 68,224 | 2024-01-22 05:30 | 2026-10-16 23:30 | 149 | 195 | 0 | 8,249 | 8,249 | 0 |
| M30 | 34,103 | 2024-01-22 11:00 | 2026-10-16 23:00 | 148 | 97 | 0 | 4,124 | 4,124 | 0 |
| H1 | 34,104 | 2021-04-27 00:00 | 2026-10-16 22:00 | 289 | 96 | 0 | 2,061 | 2,061 | 0 |
| H4 | 15,528 | 2016-10-24 20:00 | 2026-10-16 16:00 | 528 | 24 | 0 | 514 | 514 | 0 |
| D1 | 2,569 | 2016-11-21 00:00 | 2026-10-15 00:00 | 524 | 4 | 0 | 84 | 84 | 0 |
| W1 | 498 | 2017-03-26 00:00 | 2026-10-04 00:00 | 0 | 0 | 0 | 16 | 16 | 0 |
| MN1 | 97 | 2018-09-01 00:00 | 2026-09-01 00:00 | 0 | 0 | 0 | 3 | 3 | 0 |

Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).

## 3. Custo e microestrutura (base M5)

Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.

| hora_utc | spread_med | spread_p90 | spread_max | range_med_pts | atr_med_pts | ticks_vol_med | n | spread_ticks_med | pct_barras_spread0 | custo_sobre_ATR |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 13.00 | 14.00 | 15.00 | 25.00 | 21.36 | 125.00 | 4,437 | 13.80 | 0.00 | 0.65 |
| 1 | 13.00 | 14.00 | 15.00 | 29.00 | 28.29 | 150.00 | 4,439 | 13.82 | 0.00 | 0.49 |
| 2 | 13.00 | 14.00 | 15.00 | 24.00 | 28.71 | 120.00 | 4,439 | 13.75 | 0.00 | 0.48 |
| 3 | 13.00 | 14.00 | 15.00 | 21.00 | 23.64 | 99.00 | 4,440 | 13.77 | 0.00 | 0.58 |
| 4 | 13.00 | 14.00 | 15.00 | 18.00 | 20.57 | 86.00 | 4,440 | 13.70 | 0.00 | 0.67 |
| 5 | 13.00 | 14.00 | 15.00 | 21.00 | 20.21 | 104.00 | 4,440 | 13.72 | 0.00 | 0.68 |
| 6 | 13.00 | 14.00 | 15.00 | 27.00 | 25.29 | 147.00 | 4,440 | 13.71 | 0.00 | 0.54 |
| 7 | 13.00 | 13.00 | 15.00 | 28.00 | 28.79 | 163.00 | 4,440 | 13.65 | 0.00 | 0.47 |
| 8 | 13.00 | 13.00 | 15.00 | 27.00 | 29.86 | 159.00 | 4,440 | 13.68 | 0.00 | 0.46 |
| 9 | 13.00 | 13.00 | 18.00 | 23.00 | 26.64 | 134.00 | 4,440 | 13.61 | 0.00 | 0.51 |
| 10 | 13.00 | 13.00 | 15.00 | 21.00 | 23.00 | 120.00 | 4,440 | 13.66 | 0.00 | 0.59 |
| 11 | 13.00 | 13.00 | 15.00 | 22.00 | 22.43 | 126.00 | 4,440 | 13.64 | 0.00 | 0.61 |
| 12 | 13.00 | 13.00 | 15.00 | 28.00 | 26.29 | 167.00 | 4,440 | 13.70 | 0.00 | 0.52 |
| 13 | 13.00 | 13.00 | 15.00 | 34.00 | 33.14 | 222.00 | 4,431 | 13.61 | 0.00 | 0.41 |
| 14 | 13.00 | 13.00 | 15.00 | 38.00 | 39.21 | 257.00 | 4,438 | 13.55 | 0.00 | 0.35 |
| 15 | 13.00 | 13.00 | 17.00 | 32.00 | 38.21 | 217.00 | 4,440 | 13.55 | 0.00 | 0.35 |
| 16 | 13.00 | 14.00 | 17.00 | 25.00 | 30.00 | 162.00 | 4,440 | 13.61 | 0.00 | 0.45 |
| 17 | 13.00 | 14.00 | 19.00 | 20.00 | 23.86 | 136.00 | 4,440 | 13.64 | 0.00 | 0.57 |
| 18 | 13.00 | 14.00 | 17.00 | 19.00 | 20.71 | 123.00 | 4,440 | 13.68 | 0.00 | 0.66 |
| 19 | 13.00 | 14.00 | 24.00 | 16.00 | 17.79 | 112.00 | 4,438 | 13.60 | 0.00 | 0.76 |
| 20 | 13.00 | 15.00 | 201.00 | 13.00 | 15.43 | 77.00 | 4,439 | 14.29 | 0.00 | 0.93 |
| 21 | 30.00 | 66.30 | 297.00 | 21.00 | 25.00 | 45.00 | 4,428 | 66.29 | 0.00 | 2.65 |
| 22 | 14.00 | 29.00 | 126.00 | 14.00 | 22.79 | 61.00 | 4,428 | 15.22 | 0.00 | 0.67 |
| 23 | 13.00 | 14.00 | 43.00 | 15.00 | 15.29 | 66.00 | 4,428 | 14.15 | 0.00 | 0.93 |

Spread geral (mediana M5): **13.0 pts**, p90 14.0, máx 297. ATR mediano M5: **25.3 pts**. Razão spread/ATR: **0.51**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 512 | 586.00 | 75.56 | 360.30 | 55.86 | 4.75 |
| ter | 514 | 642.67 | 5.78 | 398.83 | 50.58 | 0.33 |
| qua | 513 | 692.47 | 20.30 | 453.04 | 53.22 | 1.01 |
| qui | 515 | 685.49 | -10.45 | 434.82 | 49.13 | -0.55 |
| sex | 514 | 650.79 | -20.23 | 450.06 | 49.81 | -1.02 |
| sab | 1 | 107.00 | -28.00 |  | 0.00 |  |

Autocorrelação do retorno diário (lags 1-5): +0.002, -0.003, -0.001, +0.011, -0.011 (banda ±0.039). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.061, +0.060, +0.081.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 1,421 | 0 | -0.048 | -2.623 | sim |
| 1,421 | 1 | 0.046 | 2.264 | nao |
| 1,421 | 2 | 0.018 | 1.032 | nao |
| 1,421 | 3 | -0.018 | -1.111 | nao |
| 1,421 | 4 | -0.004 | -0.233 | nao |
| 1,421 | 5 | -0.020 | -1.202 | nao |
| 1,421 | 6 | 0.034 | 1.689 | nao |
| 1,421 | 7 | 0.004 | 0.201 | nao |
| 1,421 | 8 | -0.008 | -0.414 | nao |
| 1,421 | 9 | -0.013 | -0.767 | nao |
| 1,421 | 10 | -0.026 | -1.729 | nao |
| 1,421 | 11 | -0.010 | -0.660 | nao |
| 1,421 | 12 | -0.004 | -0.138 | nao |
| 1,421 | 13 | 0.020 | 0.799 | nao |
| 1,421 | 14 | 0.017 | 0.686 | nao |
| 1,421 | 15 | -0.027 | -1.237 | nao |
| 1,421 | 16 | -0.025 | -1.699 | nao |
| 1,421 | 17 | 0.006 | 0.473 | nao |
| 1,421 | 18 | 0.010 | 0.577 | nao |
| 1,421 | 19 | 0.002 | 0.172 | nao |
| 1,420 | 20 | -0.107 | -10.244 | sim |
| 1,422 | 21 | 0.113 | 10.002 | sim |
| 1,421 | 22 | 0.150 | 13.521 | sim |
| 1,421 | 23 | 0.035 | 2.926 | sim |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 6,775 | 0 | 0.021 | 2.801 | sim |
| 6,838 | 1 | 0.000 | 0.026 | nao |
| 6,816 | 2 | 0.005 | 0.551 | nao |
| 6,820 | 3 | 0.003 | 0.439 | nao |
| 6,096 | 4 | -0.024 | -2.600 | sim |
| 759 | 6 | 0.204 | 10.059 | sim |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,598 | 1 | 0.008 | 0.624 | nao |
| 2,424 | 2 | 0.010 | 0.767 | nao |
| 2,647 | 3 | 0.005 | 0.362 | nao |
| 2,664 | 4 | 0.005 | 0.361 | nao |
| 3,168 | 5 | 0.011 | 0.902 | nao |
| 3,099 | 6 | -0.006 | -0.506 | nao |
| 3,189 | 7 | 0.002 | 0.184 | nao |
| 3,171 | 8 | 0.018 | 1.532 | nao |
| 3,117 | 9 | 0.001 | 0.044 | nao |
| 2,927 | 10 | -0.001 | -0.041 | nao |
| 2,564 | 11 | 0.008 | 0.574 | nao |
| 2,536 | 12 | 0.014 | 1.049 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 121 combinações testadas):

| dia(0=seg) | hora_utc | n | ret_medio_ATR | std | t |
|---|---|---|---|---|---|
| 4 | 20 | 285 | -0.212 | 0.453 | -7.904 |
| 6 | 21 | 195 | 0.331 | 0.599 | 7.708 |
| 0 | 21 | 283 | 0.195 | 0.440 | 7.455 |
| 4 | 21 | 91 | -0.288 | 0.389 | -7.067 |
| 1 | 22 | 284 | 0.173 | 0.418 | 6.977 |
| 6 | 22 | 282 | 0.225 | 0.543 | 6.958 |
| 3 | 22 | 286 | 0.125 | 0.314 | 6.725 |
| 0 | 22 | 285 | 0.127 | 0.395 | 5.433 |
| 1 | 21 | 285 | 0.107 | 0.343 | 5.263 |
| 0 | 20 | 282 | -0.110 | 0.386 | -4.758 |
| 2 | 22 | 284 | 0.102 | 0.386 | 4.478 |
| 3 | 21 | 284 | 0.077 | 0.316 | 4.125 |
| 3 | 20 | 284 | -0.084 | 0.367 | -3.843 |
| 1 | 20 | 285 | -0.067 | 0.340 | -3.304 |
| 6 | 23 | 282 | 0.094 | 0.521 | 3.027 |

Autocorrelação do retorno H1, lags 1-10: -0.016, -0.003, -0.004, +0.005, +0.013, -0.006, -0.001, -0.006, -0.004, +0.003 (banda ±0.011). |retorno|: +0.104, +0.032, -0.005, -0.062, +0.096 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 180 | -0.022 | -0.317 | 49.444 |
| barra < -2 ATR | 202 | 0.023 | 0.345 | 51.980 |
| barra > +1 ATR | 1,925 | -0.039 | -2.245 | 48.260 |
| barra < -1 ATR | 1,985 | 0.019 | 1.079 | 52.040 |
| gap (barra ausente antes) | 289 | 0.272 | 8.157 | 71.280 |

Distribuição do retorno H1 em ATR: média +0.0060, desvio 0.673, assimetria -0.03, curtose 4.4; barras |ret|>2 ATR: 1.12%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 13.7 pts, máxima 86.7 pts no slot NY 17:00 de domingo; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | open | 106,118 | 72,814 | 369 | 174 | 0.3 | 0.0 | 0 | 55.0 | 6.3 |
| M15 | open | 67,820 | 80,115 | 633 | 554 | 0.0 | 0.0 | 0 | 95.0 | 8.3 |
| M30 | open | 33,761 | 62,887 | 776 | 687 | 0.3 | 0.0 | 0 | 96.0 | 8.5 |
| H1 | open | 32,824 | 64,251 | 1,767 | 1,616 | 0.0 | 0.0 | 0 | 100.0 | 6.7 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 106,118 (2025-05-15 a 2026-10-16); descoberta 63,382 (até 2026-03-23), validação 42,448 (a partir de 2026-03-24)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 72,814**; passaram no BH (q=5%) na descoberta: **369**; confirmadas na validação: **174**
- melhores N da descoberta que repetem na validação: top 100: 55.0%, top 1000: 42.2%, top 10000: 16.3%
- **placebo** (6 deslocamentos): top 100: 6.3% (máx 12.0%), top 1000: 5.5% (máx 6.5%), top 10000: 4.0% (máx 4.6%); BH: média 0.3 (máx 2); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,369 | 0.007 | 2.520 | 0.175 |
| 10min bruto | 63,369 | 0.009 | 1.556 | 0.230 |
| 20min bruto | 63,117 | 0.018 | 1.544 | 0.460 |
| 35min bruto | 62,776 | 0.031 | 1.491 | 0.788 |
| 65min bruto | 62,117 | 0.060 | 1.483 | 1.515 |
| 125min bruto | 60,830 | 0.113 | 1.402 | 2.867 |
| 245min bruto | 58,305 | 0.208 | 1.258 | 5.260 |

**M5/open: famílias distintas validadas: 747; com líquido positivo e significativo na validação (custo realista): 3.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H1=BREAK_DOWN & mtf_D1=RANGE | 65min | COMPRA | 756 | 96 | 2.35 | nao | 1.89 | 1 | 45.52 | 31.38 | 31.38 | 5.07 | -14.84 | 7.43 | 67.71 | 2/2 | 9/12 | 10.10 | 52.66 | 14.14 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 35min | COMPRA | 223 | 111 | 2.78 | nao | 1.88 | 1 | 30.05 | 16.43 | 16.43 | 2.34 | -15.23 | 4.50 | 60.36 | 2/2 | 10/14 | 9.67 | 23.06 | 13.63 |
| hour=21 & mtf_H1=BULLISH | 125min | COMPRA | 912 | 491 | 2.62 | nao | 3.06 | 1 | 81.84 | 12.54 | 12.54 | 1.89 | -14.28 | 4.08 | 38.90 | 0/2 | 1/18 | 41.89 | -16.69 | 69.29 |

### M15 — modo `open`

- eventos: 67,820 (2024-01-22 a 2026-10-16); descoberta 40,596 (até 2025-09-11), validação 27,128 (a partir de 2025-09-12)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 80,115**; passaram no BH (q=5%) na descoberta: **633**; confirmadas na validação: **554**
- melhores N da descoberta que repetem na validação: top 100: 95.0%, top 1000: 79.5%, top 10000: 28.1%
- **placebo** (6 deslocamentos): top 100: 8.3% (máx 14.0%), top 1000: 7.6% (máx 10.3%), top 10000: 6.1% (máx 7.8%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 40,583 | 0.008 | 2.437 | 0.392 |
| 20min bruto | 40,583 | 0.011 | 2.200 | 0.523 |
| 30min bruto | 40,409 | 0.011 | 1.555 | 0.534 |
| 45min bruto | 40,055 | 0.015 | 1.280 | 0.682 |
| 75min bruto | 39,388 | 0.019 | 0.935 | 0.873 |
| 135min bruto | 38,122 | 0.018 | 0.464 | 0.820 |
| 255min bruto | 35,644 | 0.004 | 0.047 | 0.169 |

**M15/open: famílias distintas validadas: 1619; com líquido positivo e significativo na validação (custo realista): 15.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & news_state=NONE_60M | 255min | COMPRA | 884 | 580 | 2.56 | nao | 2.43 | 1 | 59.21 | 20.96 | 20.96 | 3.64 | -11.91 | 5.77 | 55.86 | 3/3 | 18/34 | 43.21 | -1.29 | 38.24 |
| day_of_week=SUNDAY | 255min | COMPRA | 895 | 582 | 2.60 | nao | 2.43 | 1 | 58.90 | 20.74 | 20.74 | 3.62 | -11.91 | 5.74 | 55.67 | 3/3 | 18/34 | 43.78 | -2.30 | 38.16 |
| session=LONDON_NY_OVERLAP & mtf_D1=RANGE | 135min | COMPRA | 1,961 | 810 | 2.88 | nao | 1.87 | 1 | 30.44 | 16.83 | 16.83 | 3.58 | -13.57 | 6.59 | 54.81 | 3/3 | 18/28 | 12.71 | 20.94 | 13.62 |
| session=LONDON_NY_OVERLAP & mtf_D1=BREAK_UP | 135min | VENDA | 240 | 384 | -2.54 | nao | -1.82 | 1 | 43.24 | 29.62 | 29.49 | 3.28 | -17.88 | 5.32 | 55.47 | 3/3 | 14/18 | -26.94 | 85.92 | 13.75 |
| day_of_week=SUNDAY & mtf_M5=BEARISH | 255min | COMPRA | 310 | 226 | 2.25 | nao | 1.88 | 1 | 81.81 | 30.51 | 30.51 | 3.24 | -11.91 | 4.51 | 61.95 | 3/3 | 21/34 | 35.83 | 25.20 | 51.30 |
| day_of_week=SUNDAY & atr_ratio_prev=Q1 | 255min | COMPRA | 361 | 51 | 2.05 | nao | 1.65 | 1 | 111.00 | 45.60 | 45.60 | 2.93 | -11.91 | 3.66 | 72.55 | 3/3 | 15/23 | 54.43 | 37.12 | 65.40 |
| day_of_week=SUNDAY & session=OFF_SESSION | 135min | COMPRA | 677 | 448 | 2.56 | nao | 2.40 | 1 | 39.26 | 12.93 | 12.93 | 2.54 | -13.57 | 5.25 | 58.26 | 2/3 | 20/34 | 21.52 | 4.34 | 26.33 |
| day_of_week=SUNDAY & mtf_H4=RANGE | 135min | COMPRA | 162 | 95 | 3.35 | nao | 1.97 | 1 | 62.02 | 23.04 | 23.04 | 2.52 | -13.57 | 3.99 | 64.21 | 2/3 | 16/21 | 17.33 | 28.62 | 38.99 |
| mtf_H1=BREAK_DOWN & mtf_D1=BULLISH | 75min | COMPRA | 713 | 478 | 2.12 | nao | 2.38 | 1 | 27.74 | 11.50 | 11.50 | 2.41 | -14.45 | 5.50 | 55.65 | 2/3 | 12/26 | 20.21 | 2.79 | 16.24 |
| day_of_week=SUNDAY & p1=Q1 | 135min | COMPRA | 161 | 89 | 2.14 | nao | 2.38 | 1 | 85.44 | 29.12 | 29.12 | 2.27 | -13.57 | 3.31 | 60.67 | 3/3 | 19/30 | 10.96 | 46.88 | 56.31 |
| day_of_week=SUNDAY & atr_ratio_prev=Q1 | 135min | COMPRA | 361 | 51 | 2.45 | nao | 2.45 | 1 | 92.82 | 27.43 | 27.43 | 2.04 | -13.57 | 3.01 | 66.67 | 1/3 | 9/23 | 15.83 | 38.58 | 65.40 |
| day_of_week=SUNDAY & structure_before=BEARISH | 135min | COMPRA | 346 | 268 | 2.13 | nao | 1.92 | 2 | 48.96 | 14.37 | 14.37 | 1.93 | -13.57 | 3.77 | 60.45 | 1/3 | 18/31 | 29.74 | -1.00 | 34.59 |
| day_of_week=SUNDAY & p1=Q1 | 75min | COMPRA | 161 | 90 | 2.85 | nao | 3.56 | 1 | 76.48 | 19.83 | 19.83 | 1.79 | -14.45 | 3.09 | 53.33 | 1/3 | 13/30 | -1.52 | 41.17 | 56.65 |
| day_of_week=SUNDAY & mtf_H4=RANGE | 75min | COMPRA | 162 | 99 | 3.58 | sim | 3.00 | 1 | 56.32 | 15.79 | 15.79 | 1.79 | -14.45 | 3.41 | 55.56 | 1/3 | 8/21 | 23.41 | 8.32 | 40.54 |
| session=LONDON_NY_OVERLAP & mtf_D1=RANGE | 75min | COMPRA | 1,978 | 816 | 2.85 | nao | 2.23 | 1 | 20.12 | 6.51 | 6.51 | 1.74 | -14.45 | 5.72 | 50.98 | 2/3 | 17/28 | 0.23 | 12.79 | 13.62 |

### M30 — modo `open`

- eventos: 33,761 (2024-01-22 a 2026-10-16); descoberta 20,208 (até 2025-09-11), validação 13,505 (a partir de 2025-09-12)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 62,887**; passaram no BH (q=5%) na descoberta: **776**; confirmadas na validação: **687**
- melhores N da descoberta que repetem na validação: top 100: 96.0%, top 1000: 82.7%, top 10000: 24.2%
- **placebo** (6 deslocamentos): top 100: 8.5% (máx 14.0%), top 1000: 7.3% (máx 9.4%), top 10000: 5.9% (máx 7.7%); BH: média 0.3 (máx 2); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 20,195 | 0.009 | 1.898 | 0.625 |
| 35min bruto | 20,195 | 0.012 | 1.938 | 0.831 |
| 45min bruto | 20,155 | 0.018 | 2.240 | 1.221 |
| 60min bruto | 20,022 | 0.012 | 1.141 | 0.805 |
| 90min bruto | 19,688 | 0.013 | 0.815 | 0.899 |
| 150min bruto | 19,057 | 0.010 | 0.335 | 0.645 |
| 270min bruto | 17,820 | -0.006 | -0.106 | -0.396 |

**M30/open: famílias distintas validadas: 1483; com líquido positivo e significativo na validação (custo realista): 16.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & news_state=NONE_60M | 270min | COMPRA | 449 | 295 | 2.56 | nao | 2.61 | 1 | 67.10 | 27.92 | 27.92 | 3.29 | -11.47 | 4.68 | 57.29 | 3/3 | 17/33 | 49.18 | 6.81 | 39.18 |
| day_of_week=SUNDAY | 270min | COMPRA | 455 | 296 | 2.59 | nao | 2.61 | 1 | 66.80 | 27.71 | 27.71 | 3.27 | -11.47 | 4.67 | 57.09 | 3/3 | 17/33 | 50.13 | 5.28 | 39.09 |
| mtf_D1=RANGE & atr_ratio_prev=Q1 | 270min | COMPRA | 1,186 | 511 | 2.49 | nao | 2.25 | 1 | 35.78 | 19.40 | 19.40 | 3.06 | -11.47 | 4.95 | 54.99 | 3/3 | 16/26 | 22.26 | 16.55 | 16.38 |
| session=LONDON_NY_OVERLAP & mtf_D1=RANGE | 150min | COMPRA | 981 | 405 | 2.71 | nao | 1.95 | 1 | 33.76 | 20.15 | 20.15 | 2.92 | -13.24 | 4.93 | 55.56 | 3/3 | 18/28 | 15.82 | 24.47 | 13.60 |
| day_of_week=SUNDAY & mtf_M5=BEARISH | 270min | COMPRA | 162 | 100 | 2.30 | nao | 1.70 | 1 | 83.38 | 41.51 | 41.51 | 2.72 | -11.47 | 3.47 | 60.00 | 3/3 | 19/28 | 36.11 | 46.92 | 41.87 |
| day_of_week=SUNDAY & session=OFF_SESSION | 150min | COMPRA | 340 | 224 | 2.64 | nao | 2.55 | 1 | 46.68 | 19.84 | 19.84 | 2.58 | -13.24 | 4.33 | 58.04 | 3/3 | 20/33 | 30.30 | 9.38 | 26.84 |
| day_of_week=SUNDAY & mtf_H4=BULLISH | 150min | COMPRA | 172 | 103 | 2.10 | nao | 2.58 | 1 | 64.76 | 26.24 | 26.24 | 2.40 | -13.24 | 3.61 | 59.22 | 2/3 | 11/24 | 53.12 | -0.12 | 38.52 |
| session=LONDON_NY_OVERLAP & mtf_D1=BREAK_UP | 150min | VENDA | 120 | 192 | -2.58 | nao | -1.84 | 1 | 45.24 | 31.64 | 31.48 | 2.37 | -18.71 | 3.82 | 56.77 | 3/3 | 14/18 | -26.87 | 89.84 | 13.75 |
| day_of_week=SUNDAY & mtf_H1=BULLISH | 270min | COMPRA | 146 | 94 | 2.81 | nao | 1.85 | 1 | 66.73 | 26.42 | 26.42 | 2.16 | -11.47 | 3.08 | 58.51 | 3/3 | 17/21 | 39.51 | 13.33 | 40.31 |
| slot_hhmm=15:00 & mtf_D1=BEARISH | 45min | VENDA | 128 | 78 | -2.10 | nao | -2.42 | 1 | 34.59 | 21.03 | 21.03 | 2.04 | -17.36 | 3.72 | 62.82 | 3/3 | 13/18 | 22.00 | 20.07 | 13.56 |
| session=LONDON_NY_OVERLAP & mtf_D1=RANGE | 90min | COMPRA | 989 | 408 | 2.73 | nao | 2.40 | 1 | 25.06 | 11.46 | 11.46 | 2.04 | -14.19 | 4.65 | 53.43 | 2/3 | 18/28 | 4.37 | 18.55 | 13.60 |
| day_of_week=SUNDAY & mtf_M15=BEARISH | 150min | COMPRA | 184 | 140 | 2.33 | nao | 2.07 | 1 | 56.23 | 21.94 | 21.94 | 1.98 | -13.24 | 3.18 | 62.86 | 2/3 | 17/28 | 38.02 | 5.86 | 34.29 |
| day_of_week=SUNDAY & mtf_H1=BULLISH | 150min | COMPRA | 149 | 94 | 3.37 | nao | 2.93 | 1 | 57.60 | 17.28 | 17.28 | 1.96 | -13.24 | 3.44 | 58.51 | 3/3 | 13/21 | 6.30 | 28.27 | 40.31 |
| day_of_week=SUNDAY | 150min | COMPRA | 458 | 296 | 3.66 | sim | 3.33 | 1 | 50.99 | 11.90 | 11.90 | 1.78 | -13.24 | 3.80 | 55.74 | 2/3 | 16/33 | 22.41 | 1.38 | 39.09 |
| day_of_week=SUNDAY & news_state=NONE_60M | 150min | COMPRA | 452 | 295 | 3.58 | sim | 3.32 | 1 | 51.06 | 11.89 | 11.89 | 1.77 | -13.24 | 3.78 | 55.59 | 2/3 | 16/33 | 22.22 | 1.62 | 39.18 |
| day_of_week=SUNDAY & structure_before=BULLISH | 90min | COMPRA | 121 | 68 | 2.94 | nao | 3.10 | 2 | 47.25 | 13.82 | 13.82 | 1.77 | -14.19 | 3.57 | 54.41 | 1/3 | 8/17 | 19.29 | 8.34 | 33.43 |

### H1 — modo `open`

- eventos: 32,824 (2021-06-04 a 2026-10-16); descoberta 19,671 (até 2024-08-21), validação 13,130 (a partir de 2024-08-22)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 64,251**; passaram no BH (q=5%) na descoberta: **1,767**; confirmadas na validação: **1,616**
- melhores N da descoberta que repetem na validação: top 100: 100.0%, top 1000: 97.6%, top 10000: 31.8%
- **placebo** (6 deslocamentos): top 100: 6.7% (máx 16.0%), top 1000: 5.8% (máx 6.7%), top 10000: 5.2% (máx 6.3%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 19,671 | 0.005 | 1.043 | 0.583 |
| 65min bruto | 19,671 | 0.005 | 0.976 | 0.610 |
| 75min bruto | 19,468 | 0.008 | 1.333 | 0.969 |
| 90min bruto | 19,367 | 0.010 | 1.392 | 1.201 |
| 120min bruto | 19,135 | 0.006 | 0.560 | 0.678 |
| 180min bruto | 18,433 | 0.003 | 0.158 | 0.303 |
| 300min bruto | 17,051 | -0.001 | -0.036 | -0.127 |

**H1/open: famílias distintas validadas: 1401; com líquido positivo e significativo na validação (custo realista): 9.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & mtf_H1=BULLISH | 180min | COMPRA | 140 | 88 | 2.70 | nao | 3.87 | 2 | 69.00 | 24.15 | 24.15 | 2.30 | -14.33 | 3.65 | 59.09 | 4/6 | 10/17 | 18.42 | 29.89 | 44.85 |
| day_of_week=SUNDAY & mtf_H4=RANGE | 180min | COMPRA | 124 | 52 | 2.44 | nao | 3.45 | 1 | 74.21 | 27.74 | 27.74 | 2.29 | -14.33 | 3.44 | 59.62 | 3/6 | 8/15 | 15.36 | 40.11 | 46.48 |
| day_of_week=SUNDAY | 180min | COMPRA | 436 | 298 | 2.34 | nao | 5.08 | 1 | 60.60 | 15.09 | 15.09 | 2.12 | -14.33 | 4.16 | 54.70 | 3/6 | 30/65 | 4.62 | 25.57 | 45.51 |
| day_of_week=SUNDAY & mtf_D1=BULLISH | 90min | COMPRA | 124 | 98 | 3.58 | sim | 5.75 | 1 | 63.65 | 18.42 | 18.42 | 2.12 | -13.63 | 3.68 | 63.27 | 1/5 | 12/23 | 3.02 | 33.82 | 45.24 |
| day_of_week=SUNDAY & mtf_M1=BEARISH | 300min | COMPRA | 136 | 94 | 2.06 | nao | 2.07 | 1 | 74.40 | 30.17 | 30.17 | 1.99 | -13.77 | 2.89 | 57.45 | 5/6 | 10/19 | 10.72 | 49.62 | 44.24 |
| day_of_week=SUNDAY & mtf_D1=BULLISH | 75min | COMPRA | 124 | 98 | 4.18 | sim | 6.72 | 1 | 62.12 | 16.89 | 16.89 | 1.97 | -13.52 | 3.53 | 61.22 | 1/5 | 14/23 | -0.27 | 34.04 | 45.24 |
| gap=Y | 300min | COMPRA | 164 | 115 | 2.06 | nao | 3.41 | 1 | 112.38 | 25.93 | 25.93 | 1.71 | -13.77 | 2.62 | 54.78 | 3/6 | 15/21 | -3.22 | 54.58 | 86.45 |
| day_of_week=SUNDAY & mtf_H4=RANGE | 120min | COMPRA | 127 | 53 | 3.57 | sim | 4.09 | 1 | 68.66 | 21.42 | 21.42 | 1.70 | -14.80 | 2.85 | 58.49 | 4/6 | 7/17 | -4.06 | 45.97 | 47.24 |
| day_of_week=SUNDAY & pcum3=Q2 | 180min | COMPRA | 125 | 81 | 2.22 | nao | 3.40 | 1 | 83.02 | 24.13 | 24.13 | 1.65 | -14.33 | 2.62 | 58.02 | 2/6 | 5/13 | 4.09 | 43.68 | 58.90 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **5250**
- com líquido positivo e t>1,645 na validação, custo realista: **43**; dessas, sobreviveram ao BH: **6**; e positivas nas duas metades da validação: **4**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H1 | open | day_of_week=SUNDAY & mtf_D1=BULLISH | 90min | COMPRA | 98 | 18.42 | -13.63 | 3.68 | 2.12 | 63.27 | 1/5 | 12/23 |
| M15 | open | day_of_week=SUNDAY & mtf_H4=RANGE | 75min | COMPRA | 99 | 15.79 | -14.45 | 3.41 | 1.79 | 55.56 | 1/3 | 8/21 |
| M30 | open | day_of_week=SUNDAY | 150min | COMPRA | 296 | 11.90 | -13.24 | 3.80 | 1.78 | 55.74 | 2/3 | 16/33 |
| M30 | open | day_of_week=SUNDAY & news_state=NONE_60M | 150min | COMPRA | 295 | 11.89 | -13.24 | 3.78 | 1.77 | 55.59 | 2/3 | 16/33 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 490s)_
