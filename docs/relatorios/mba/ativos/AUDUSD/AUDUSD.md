# AUDUSD — relatório completo MBA (gerado em 2026-10-17 01:38)

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
| M5 | ret | 106,118 | 210,310 | 442 | 209 | 0.0 | 0.0 | 0 | 33.0 | 4.2 |
| M15 | ret | 67,820 | 221,592 | 198 | 152 | 0.0 | 0.0 | 0 | 74.0 | 7.0 |
| M30 | ret | 33,761 | 191,066 | 289 | 214 | 0.0 | 0.0 | 0 | 80.0 | 5.0 |
| H1 | ret | 32,824 | 195,752 | 1,493 | 1,074 | 0.0 | 0.0 | 0 | 96.0 | 7.0 |
| M5 | hit | 106,118 | 629,874 | 1 | 0 | 1.5 | 0.0 | 0 | 1.0 | 1.3 |
| M15 | hit | 67,820 | 661,254 | 3 | 0 | 0.0 | 0.0 | 0 | 0.0 | 1.0 |
| M30 | hit | 33,761 | 569,964 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.3 |
| H1 | hit | 32,824 | 583,080 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.2 |


## 6.1 Modo `ret`

### M5 — modo `ret`

- eventos: 106,118 (2025-05-15 a 2026-10-16); descoberta 63,382 (até 2026-03-23), validação 42,448 (a partir de 2026-03-24)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 210,310**; passaram no BH (q=5%) na descoberta: **442**; confirmadas na validação: **209**
- melhores N da descoberta que repetem na validação: top 100: 33.0%, top 1000: 41.5%, top 10000: 20.7%
- **placebo** (6 deslocamentos): top 100: 4.2% (máx 6.0%), top 1000: 4.6% (máx 7.6%), top 10000: 3.8% (máx 4.5%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,382 | 0.002 | 0.702 | 0.055 |
| 15min bruto | 63,130 | 0.011 | 1.253 | 0.289 |
| 30min bruto | 62,789 | 0.024 | 1.309 | 0.603 |
| 60min bruto | 62,130 | 0.053 | 1.407 | 1.341 |
| 120min bruto | 60,843 | 0.106 | 1.356 | 2.681 |
| 240min bruto | 58,318 | 0.200 | 1.230 | 5.056 |

**M5/ret: famílias distintas validadas: 1515; com líquido positivo e significativo na validação (custo realista): 7.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=RANGE & price_position_weekly_open=Q4 | 120min | COMPRA | 3,232 | 505 | 2.19 | nao | 2.83 | 1 | 43.42 | 28.39 | 28.39 | 8.30 | -14.33 | 12.51 | 63.37 | 1/2 | 8/13 | 32.91 | 23.88 | 15.03 |
| mtf_H1=BREAK_DOWN & mtf_D1=RANGE | 60min | COMPRA | 756 | 96 | 2.39 | nao | 1.92 | 1 | 41.64 | 27.67 | 27.67 | 4.75 | -14.88 | 7.27 | 65.62 | 2/2 | 9/12 | 7.84 | 47.50 | 13.96 |
| day_of_week=SUNDAY & price_position_monthly_open=Q5 | 60min | COMPRA | 191 | 169 | 2.05 | nao | 2.66 | 1 | 47.54 | 16.15 | 16.15 | 3.72 | -14.88 | 7.13 | 53.25 | 1/2 | 2/8 | 30.72 | 1.75 | 31.39 |
| mtf_D1=RANGE & price_position_monthly_open=Q3 | 60min | COMPRA | 3,694 | 222 | 2.21 | nao | 1.89 | 1 | 34.09 | 15.31 | 15.31 | 2.87 | -14.88 | 5.67 | 54.05 | 0/2 | 3/9 | -8.46 | 39.08 | 18.78 |
| mtf_D1=RANGE & price_position_weekly_open=Q4 | 60min | COMPRA | 3,301 | 529 | 2.04 | nao | 2.66 | 1 | 20.08 | 5.11 | 5.11 | 2.23 | -14.88 | 8.73 | 49.72 | 1/2 | 4/13 | 5.63 | 4.59 | 14.97 |
| hour=21 & mtf_H1=BULLISH | 120min | COMPRA | 912 | 491 | 2.65 | nao | 3.02 | 1 | 78.13 | 13.40 | 13.40 | 2.03 | -14.33 | 4.24 | 39.71 | 0/2 | 2/18 | 44.20 | -17.28 | 64.73 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 30min | COMPRA | 223 | 111 | 2.79 | nao | 1.90 | 1 | 26.13 | 12.50 | 12.50 | 1.98 | -15.27 | 4.38 | 57.66 | 2/2 | 9/14 | 7.13 | 17.78 | 13.62 |

### M15 — modo `ret`

- eventos: 67,820 (2024-01-22 a 2026-10-16); descoberta 40,596 (até 2025-09-11), validação 27,128 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 221,592**; passaram no BH (q=5%) na descoberta: **198**; confirmadas na validação: **152**
- melhores N da descoberta que repetem na validação: top 100: 74.0%, top 1000: 59.0%, top 10000: 23.6%
- **placebo** (6 deslocamentos): top 100: 7.0% (máx 12.0%), top 1000: 5.5% (máx 6.6%), top 10000: 4.7% (máx 5.7%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 40,596 | 0.003 | 1.002 | 0.130 |
| 15min bruto | 40,422 | 0.003 | 0.762 | 0.140 |
| 30min bruto | 40,068 | 0.006 | 0.791 | 0.294 |
| 60min bruto | 39,401 | 0.010 | 0.634 | 0.489 |
| 120min bruto | 38,135 | 0.009 | 0.261 | 0.418 |
| 240min bruto | 35,657 | -0.006 | -0.077 | -0.261 |

**M15/ret: famílias distintas validadas: 1838; com líquido positivo e significativo na validação (custo realista): 11.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & news_state=NONE_60M | 240min | COMPRA | 884 | 580 | 2.41 | nao | 2.17 | 1 | 50.33 | 18.97 | 18.97 | 3.39 | -12.19 | 5.62 | 54.66 | 3/3 | 17/34 | 41.70 | -3.77 | 31.37 |
| day_of_week=SUNDAY | 240min | COMPRA | 895 | 582 | 2.45 | nao | 2.16 | 1 | 50.10 | 18.79 | 18.79 | 3.37 | -12.19 | 5.60 | 54.47 | 3/3 | 17/34 | 42.16 | -4.58 | 31.31 |
| day_of_week=SUNDAY & mtf_M5=BEARISH | 240min | COMPRA | 310 | 226 | 2.10 | nao | 1.67 | 1 | 69.44 | 30.57 | 30.57 | 3.32 | -12.19 | 4.66 | 60.62 | 3/3 | 22/34 | 36.68 | 24.46 | 38.87 |
| session=LONDON_NY_OVERLAP & mtf_D1=BREAK_UP | 120min | VENDA | 240 | 384 | -2.55 | nao | -1.89 | 1 | 39.41 | 25.80 | 25.66 | 2.96 | -17.28 | 5.01 | 53.91 | 3/3 | 13/18 | -25.64 | 76.96 | 13.75 |
| session=LONDON_NY_OVERLAP & mtf_D1=RANGE | 120min | COMPRA | 1,961 | 810 | 3.01 | nao | 1.79 | 1 | 25.57 | 11.94 | 11.94 | 2.72 | -13.85 | 6.00 | 52.10 | 3/3 | 18/28 | 8.50 | 15.39 | 13.62 |
| day_of_week=SUNDAY & session=OFF_SESSION | 120min | COMPRA | 677 | 448 | 2.45 | nao | 2.25 | 1 | 33.58 | 11.51 | 11.51 | 2.37 | -13.85 | 5.26 | 56.47 | 2/3 | 21/34 | 18.88 | 4.14 | 22.07 |
| day_of_week=SUNDAY & mtf_M15=BEARISH | 120min | COMPRA | 346 | 268 | 2.00 | nao | 1.88 | 2 | 43.06 | 15.74 | 15.74 | 2.26 | -13.85 | 4.26 | 58.96 | 1/3 | 18/31 | 32.76 | -1.28 | 27.32 |
| day_of_week=MONDAY & session=OFF_SESSION | 120min | VENDA | 669 | 453 | -2.17 | nao | -1.94 | 1 | 22.06 | 1.84 | 8.16 | 2.07 | -17.28 | 6.46 | 52.76 | 3/3 | 18/34 | 1.51 | 14.77 | 13.90 |
| day_of_week=MONDAY & hour=23 | 60min | VENDA | 343 | 228 | -2.02 | nao | -2.49 | 1 | 22.22 | 7.91 | 8.31 | 2.05 | -16.35 | 6.09 | 53.07 | 2/3 | 18/34 | 7.64 | 8.98 | 13.91 |
| day_of_week=SUNDAY & previous_low_distance_atr=Q4 | 120min | COMPRA | 235 | 195 | 2.26 | nao | 1.90 | 1 | 39.29 | 14.11 | 14.11 | 2.02 | -13.85 | 4.01 | 58.46 | 3/3 | 18/32 | 41.38 | -12.87 | 25.18 |
| day_of_week=SUNDAY & mtf_H4=RANGE | 120min | COMPRA | 162 | 95 | 3.43 | nao | 1.69 | 1 | 49.29 | 17.55 | 17.55 | 1.88 | -13.85 | 3.36 | 61.05 | 2/3 | 17/21 | 11.45 | 23.52 | 31.75 |

### M30 — modo `ret`

- eventos: 33,761 (2024-01-22 a 2026-10-16); descoberta 20,208 (até 2025-09-11), validação 13,505 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 191,066**; passaram no BH (q=5%) na descoberta: **289**; confirmadas na validação: **214**
- melhores N da descoberta que repetem na validação: top 100: 80.0%, top 1000: 56.4%, top 10000: 17.9%
- **placebo** (6 deslocamentos): top 100: 5.0% (máx 10.0%), top 1000: 5.4% (máx 7.9%), top 10000: 4.7% (máx 5.8%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 20,208 | 0.003 | 0.922 | 0.202 |
| 15min bruto | 20,168 | 0.009 | 2.044 | 0.604 |
| 30min bruto | 20,035 | 0.003 | 0.510 | 0.190 |
| 60min bruto | 19,701 | 0.004 | 0.377 | 0.288 |
| 120min bruto | 19,070 | 0.000 | 0.004 | 0.006 |
| 240min bruto | 17,833 | -0.016 | -0.327 | -1.100 |

**M30/ret: famílias distintas validadas: 1452; com líquido positivo e significativo na validação (custo realista): 10.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & news_state=NONE_60M | 240min | COMPRA | 449 | 295 | 2.23 | nao | 2.17 | 1 | 48.99 | 23.21 | 23.21 | 2.89 | -12.08 | 4.43 | 57.29 | 3/3 | 17/33 | 45.61 | 0.96 | 25.78 |
| day_of_week=SUNDAY | 240min | COMPRA | 455 | 296 | 2.26 | nao | 2.17 | 1 | 48.83 | 23.09 | 23.09 | 2.89 | -12.08 | 4.43 | 57.09 | 3/3 | 17/33 | 47.35 | -1.17 | 25.74 |
| mtf_D1=RANGE & atr_ratio=Q1 | 240min | COMPRA | 1,173 | 512 | 2.48 | nao | 2.34 | 1 | 33.05 | 16.93 | 16.93 | 2.87 | -12.08 | 5.00 | 56.25 | 3/3 | 17/26 | 22.16 | 11.70 | 16.12 |
| day_of_week=SUNDAY & session=OFF_SESSION | 120min | COMPRA | 340 | 224 | 2.40 | nao | 2.42 | 1 | 35.52 | 16.30 | 16.30 | 2.31 | -13.86 | 4.30 | 57.14 | 3/3 | 20/33 | 24.91 | 7.69 | 19.22 |
| month=4 & price_position_daily_open=Q4 | 120min | COMPRA | 375 | 181 | 2.60 | nao | 1.71 | 1 | 34.73 | 20.07 | 20.07 | 2.07 | -13.86 | 3.52 | 50.83 | 3/3 | 3/3 | 18.89 | 21.24 | 14.66 |
| day_of_week=SUNDAY & mtf_M5=BEARISH | 120min | COMPRA | 162 | 100 | 2.26 | nao | 1.72 | 1 | 42.64 | 22.09 | 22.09 | 1.96 | -13.86 | 3.18 | 57.00 | 2/3 | 15/28 | 32.69 | 11.50 | 20.55 |
| session=LONDON_NY_OVERLAP & mtf_D1=BREAK_UP | 120min | VENDA | 120 | 192 | -2.58 | nao | -1.95 | 1 | 37.72 | 24.12 | 23.96 | 1.92 | -17.47 | 3.36 | 54.17 | 3/3 | 14/18 | -23.86 | 71.79 | 13.75 |
| day_of_week=SUNDAY & structure_at_close=BULLISH | 120min | COMPRA | 121 | 72 | 2.17 | nao | 2.41 | 1 | 38.06 | 16.52 | 16.52 | 1.92 | -13.86 | 3.51 | 59.72 | 3/3 | 13/21 | 32.57 | 0.46 | 21.54 |
| day_of_week=SUNDAY & volume_ratio=Q1 | 240min | COMPRA | 346 | 185 | 2.28 | nao | 1.79 | 1 | 47.46 | 17.07 | 17.07 | 1.87 | -12.08 | 3.20 | 56.76 | 3/3 | 20/33 | 50.50 | -16.01 | 30.39 |
| session=LONDON_NY_OVERLAP & mtf_D1=RANGE | 120min | COMPRA | 981 | 405 | 2.97 | nao | 1.81 | 1 | 24.12 | 10.51 | 10.51 | 1.74 | -13.86 | 4.11 | 52.84 | 3/3 | 17/28 | 7.95 | 13.06 | 13.61 |

### H1 — modo `ret`

- eventos: 32,824 (2021-06-04 a 2026-10-16); descoberta 19,671 (até 2024-08-21), validação 13,130 (a partir de 2024-08-22)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 195,752**; passaram no BH (q=5%) na descoberta: **1,493**; confirmadas na validação: **1,074**
- melhores N da descoberta que repetem na validação: top 100: 96.0%, top 1000: 79.9%, top 10000: 30.3%
- **placebo** (6 deslocamentos): top 100: 7.0% (máx 14.0%), top 1000: 6.4% (máx 8.7%), top 10000: 6.0% (máx 6.8%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 19,671 | 0.000 | 0.121 | 0.027 |
| 15min bruto | 19,468 | 0.002 | 0.666 | 0.215 |
| 30min bruto | 19,367 | 0.003 | 0.876 | 0.368 |
| 60min bruto | 19,135 | -0.002 | -0.322 | -0.205 |
| 120min bruto | 18,433 | -0.006 | -0.518 | -0.688 |
| 240min bruto | 17,051 | -0.010 | -0.411 | -1.174 |

**H1/ret: famílias distintas validadas: 2333; com líquido positivo e significativo na validação (custo realista): 3.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & mtf_M15=RANGE | 15min | COMPRA | 121 | 73 | 3.60 | sim | 5.42 | 1 | 29.89 | 11.44 | 11.44 | 2.01 | -14.02 | 4.45 | 60.27 | 3/6 | 6/11 | 12.67 | 10.24 | 18.45 |
| previous_high_distance_atr=Q4 & news_min_to_next_high=Q1 | 120min | COMPRA | 164 | 366 | 2.02 | nao | 2.35 | 1 | 32.61 | 19.01 | 19.01 | 2.00 | -14.75 | 3.64 | 51.64 | 4/4 | 22/37 | 29.86 | 8.15 | 13.61 |
| day_of_week=SUNDAY & range_atr_prev=Q1 | 30min | COMPRA | 201 | 60 | 2.98 | nao | 5.08 | 1 | 32.92 | 12.89 | 12.89 | 1.68 | -14.08 | 3.49 | 55.00 | 4/6 | 9/24 | 11.74 | 14.03 | 20.03 |

## 6.2 Modo `hit`

### M5 — modo `hit`

- eventos: 106,118 (2025-05-15 a 2026-10-16); descoberta 63,382 (até 2026-03-23), validação 42,448 (a partir de 2026-03-24)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 629,874**; passaram no BH (q=5%) na descoberta: **1**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 1.0%, top 1000: 1.8%, top 10000: 0.3%
- **placebo** (6 deslocamentos): top 100: 1.3% (máx 3.0%), top 1000: 0.6% (máx 1.1%), top 10000: 0.1% (máx 0.2%); BH: média 1.5 (máx 3); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 63,117 | -0.693 |  | -17.516 |
| C alvo 0.5ATR/60min liquido | 62,117 | -0.679 |  | -17.181 |
| C alvo 0.5ATR/240min liquido | 58,305 | -0.632 |  | -15.971 |
| C alvo 1.0ATR/15min liquido | 63,117 | -0.679 |  | -17.179 |
| C alvo 1.0ATR/60min liquido | 62,117 | -0.667 |  | -16.860 |
| C alvo 1.0ATR/240min liquido | 58,305 | -0.594 |  | -15.008 |
| C alvo 2.0ATR/15min liquido | 63,117 | -0.670 |  | -16.929 |
| C alvo 2.0ATR/60min liquido | 62,117 | -0.651 |  | -16.455 |
| C alvo 2.0ATR/240min liquido | 58,305 | -0.531 |  | -13.432 |
| V alvo 0.5ATR/15min liquido | 63,117 | -0.693 |  | -17.531 |
| V alvo 0.5ATR/60min liquido | 62,117 | -0.697 |  | -17.632 |
| V alvo 0.5ATR/240min liquido | 58,305 | -0.709 |  | -17.920 |
| V alvo 1.0ATR/15min liquido | 63,117 | -0.684 |  | -17.303 |
| V alvo 1.0ATR/60min liquido | 62,117 | -0.697 |  | -17.627 |
| V alvo 1.0ATR/240min liquido | 58,305 | -0.703 |  | -17.774 |
| V alvo 2.0ATR/15min liquido | 63,117 | -0.682 |  | -17.256 |
| V alvo 2.0ATR/60min liquido | 62,117 | -0.702 |  | -17.739 |
| V alvo 2.0ATR/240min liquido | 58,305 | -0.714 |  | -18.054 |

**M5/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

### M15 — modo `hit`

- eventos: 67,820 (2024-01-22 a 2026-10-16); descoberta 40,596 (até 2025-09-11), validação 27,128 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 661,254**; passaram no BH (q=5%) na descoberta: **3**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 0.3%, top 10000: 0.1%
- **placebo** (6 deslocamentos): top 100: 1.0% (máx 2.0%), top 1000: 0.3% (máx 0.6%), top 10000: 0.0% (máx 0.1%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 40,409 | -0.369 |  | -17.252 |
| C alvo 0.5ATR/60min liquido | 39,388 | -0.360 |  | -16.838 |
| C alvo 0.5ATR/240min liquido | 35,644 | -0.368 |  | -17.188 |
| C alvo 1.0ATR/15min liquido | 40,409 | -0.366 |  | -17.077 |
| C alvo 1.0ATR/60min liquido | 39,388 | -0.358 |  | -16.713 |
| C alvo 1.0ATR/240min liquido | 35,644 | -0.366 |  | -17.120 |
| C alvo 2.0ATR/15min liquido | 40,409 | -0.362 |  | -16.921 |
| C alvo 2.0ATR/60min liquido | 39,388 | -0.358 |  | -16.746 |
| C alvo 2.0ATR/240min liquido | 35,644 | -0.367 |  | -17.167 |
| V alvo 0.5ATR/15min liquido | 40,409 | -0.373 |  | -17.436 |
| V alvo 0.5ATR/60min liquido | 39,388 | -0.365 |  | -17.050 |
| V alvo 0.5ATR/240min liquido | 35,644 | -0.378 |  | -17.665 |
| V alvo 1.0ATR/15min liquido | 40,409 | -0.364 |  | -17.003 |
| V alvo 1.0ATR/60min liquido | 39,388 | -0.363 |  | -16.974 |
| V alvo 1.0ATR/240min liquido | 35,644 | -0.375 |  | -17.523 |
| V alvo 2.0ATR/15min liquido | 40,409 | -0.359 |  | -16.790 |
| V alvo 2.0ATR/60min liquido | 39,388 | -0.363 |  | -16.939 |
| V alvo 2.0ATR/240min liquido | 35,644 | -0.387 |  | -18.074 |

**M15/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

### M30 — modo `hit`

- eventos: 33,761 (2024-01-22 a 2026-10-16); descoberta 20,208 (até 2025-09-11), validação 13,505 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 569,964**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 0.3%, top 10000: 0.1%
- **placebo** (6 deslocamentos): top 100: 0.3% (máx 1.0%), top 1000: 0.2% (máx 0.3%), top 10000: 0.1% (máx 0.1%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 20,155 | -0.236 |  | -16.061 |
| C alvo 0.5ATR/60min liquido | 19,688 | -0.237 |  | -16.087 |
| C alvo 0.5ATR/240min liquido | 17,820 | -0.246 |  | -16.708 |
| C alvo 1.0ATR/15min liquido | 20,155 | -0.230 |  | -15.653 |
| C alvo 1.0ATR/60min liquido | 19,688 | -0.235 |  | -15.939 |
| C alvo 1.0ATR/240min liquido | 17,820 | -0.242 |  | -16.460 |
| C alvo 2.0ATR/15min liquido | 20,155 | -0.227 |  | -15.425 |
| C alvo 2.0ATR/60min liquido | 19,688 | -0.231 |  | -15.686 |
| C alvo 2.0ATR/240min liquido | 17,820 | -0.239 |  | -16.230 |
| V alvo 0.5ATR/15min liquido | 20,155 | -0.244 |  | -16.576 |
| V alvo 0.5ATR/60min liquido | 19,688 | -0.246 |  | -16.700 |
| V alvo 0.5ATR/240min liquido | 17,820 | -0.247 |  | -16.788 |
| V alvo 1.0ATR/15min liquido | 20,155 | -0.239 |  | -16.247 |
| V alvo 1.0ATR/60min liquido | 19,688 | -0.242 |  | -16.408 |
| V alvo 1.0ATR/240min liquido | 17,820 | -0.258 |  | -17.536 |
| V alvo 2.0ATR/15min liquido | 20,155 | -0.240 |  | -16.274 |
| V alvo 2.0ATR/60min liquido | 19,688 | -0.240 |  | -16.272 |
| V alvo 2.0ATR/240min liquido | 17,820 | -0.250 |  | -16.956 |

**M30/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

### H1 — modo `hit`

- eventos: 32,824 (2021-06-04 a 2026-10-16); descoberta 19,671 (até 2024-08-21), validação 13,130 (a partir de 2024-08-22)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 583,080**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 0.1%, top 10000: 0.2%
- **placebo** (6 deslocamentos): top 100: 0.2% (máx 1.0%), top 1000: 0.0% (máx 0.1%), top 10000: 0.0% (máx 0.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 19,468 | -0.125 |  | -14.399 |
| C alvo 0.5ATR/60min liquido | 19,135 | -0.126 |  | -14.559 |
| C alvo 0.5ATR/240min liquido | 17,051 | -0.128 |  | -14.774 |
| C alvo 1.0ATR/15min liquido | 19,468 | -0.123 |  | -14.157 |
| C alvo 1.0ATR/60min liquido | 19,135 | -0.125 |  | -14.447 |
| C alvo 1.0ATR/240min liquido | 17,051 | -0.135 |  | -15.509 |
| C alvo 2.0ATR/15min liquido | 19,468 | -0.122 |  | -14.072 |
| C alvo 2.0ATR/60min liquido | 19,135 | -0.126 |  | -14.542 |
| C alvo 2.0ATR/240min liquido | 17,051 | -0.139 |  | -15.968 |
| V alvo 0.5ATR/15min liquido | 19,468 | -0.127 |  | -14.596 |
| V alvo 0.5ATR/60min liquido | 19,135 | -0.135 |  | -15.580 |
| V alvo 0.5ATR/240min liquido | 17,051 | -0.136 |  | -15.661 |
| V alvo 1.0ATR/15min liquido | 19,468 | -0.125 |  | -14.393 |
| V alvo 1.0ATR/60min liquido | 19,135 | -0.132 |  | -15.165 |
| V alvo 1.0ATR/240min liquido | 17,051 | -0.132 |  | -15.153 |
| V alvo 2.0ATR/15min liquido | 19,468 | -0.124 |  | -14.324 |
| V alvo 2.0ATR/60min liquido | 19,135 | -0.129 |  | -14.868 |
| V alvo 2.0ATR/240min liquido | 17,051 | -0.136 |  | -15.607 |

**H1/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **7138**
- com líquido positivo e t>1,645 na validação, custo realista: **31**; dessas, sobreviveram ao BH: **1**; e positivas nas duas metades da validação: **1**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H1 | ret | day_of_week=SUNDAY & mtf_M15=RANGE | 15min | COMPRA | 73 | 11.44 | -14.02 | 4.45 | 2.01 | 60.27 | 3/6 | 6/11 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 1690s)_
