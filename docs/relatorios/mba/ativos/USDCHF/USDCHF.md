# USDCHF — relatório completo MBA (gerado em 2026-10-17 01:38)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | Raw Trading Ltd |
| servidor | ICMarketsSC-Demo |
| simbolo | USDCHF |
| descricao | US Dollar vs Swiss Franc |
| digitos | 5 |
| ponto | 0.00001 |
| tick_size | 0.00001 |
| tick_value | 1.21327 |
| contrato | 100,000.00000 |
| lote_min | 0.01000 |
| swap_long | 6.18400 |
| swap_short | -13.10000 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-01-22 00:22 | 2026-10-16 23:55 | 162 | 1,160,370 | 0 | 123,453 | 123,453 | 1 |
| M5 | 106,442 | 2025-05-15 03:25 | 2026-10-16 23:50 | 86 | 577 | 0 | 24,715 | 24,715 | 1 |
| M15 | 68,213 | 2024-01-22 05:30 | 2026-10-16 23:30 | 150 | 192 | 0 | 8,241 | 8,241 | 1 |
| M30 | 34,097 | 2024-01-22 11:00 | 2026-10-16 23:00 | 149 | 96 | 0 | 4,120 | 4,120 | 1 |
| H1 | 34,112 | 2021-04-27 00:00 | 2026-10-16 22:00 | 292 | 72 | 0 | 2,060 | 2,060 | 0 |
| H4 | 15,532 | 2016-10-24 20:00 | 2026-10-16 16:00 | 529 | 18 | 0 | 514 | 514 | 0 |
| D1 | 2,569 | 2016-11-21 00:00 | 2026-10-15 00:00 | 524 | 3 | 0 | 84 | 84 | 0 |
| W1 | 498 | 2017-03-26 00:00 | 2026-10-04 00:00 | 0 | 0 | 0 | 16 | 16 | 0 |
| MN1 | 97 | 2018-09-01 00:00 | 2026-09-01 00:00 | 0 | 0 | 0 | 3 | 3 | 0 |

Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).

## 3. Custo e microestrutura (base M5)

Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.

| hora_utc | spread_med | spread_p90 | spread_max | range_med_pts | atr_med_pts | ticks_vol_med | n | spread_ticks_med | pct_barras_spread0 | custo_sobre_ATR |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 2.00 | 2.00 | 6.00 | 21.00 | 18.71 | 168.00 | 4,435 | 1.92 | 39.66 | 0.10 |
| 1 | 2.00 | 2.00 | 6.00 | 22.00 | 22.57 | 176.00 | 4,440 | 1.21 | 46.06 | 0.05 |
| 2 | 1.00 | 2.00 | 6.00 | 17.00 | 20.71 | 130.00 | 4,440 | 1.12 | 46.91 | 0.05 |
| 3 | 1.00 | 2.00 | 6.00 | 15.00 | 17.29 | 111.00 | 4,440 | 1.08 | 47.16 | 0.06 |
| 4 | 1.00 | 2.00 | 6.00 | 14.00 | 15.50 | 99.00 | 4,440 | 1.31 | 45.68 | 0.08 |
| 5 | 2.00 | 2.00 | 6.00 | 17.00 | 16.21 | 119.00 | 4,427 | 1.86 | 42.38 | 0.11 |
| 6 | 2.00 | 2.00 | 4.00 | 26.00 | 22.86 | 180.00 | 4,427 | 1.90 | 42.53 | 0.08 |
| 7 | 1.00 | 2.00 | 4.00 | 32.00 | 30.36 | 227.00 | 4,438 | 1.76 | 44.93 | 0.06 |
| 8 | 1.00 | 2.00 | 3.00 | 31.00 | 33.82 | 230.00 | 4,440 | 1.67 | 46.06 | 0.05 |
| 9 | 1.00 | 2.00 | 4.00 | 28.00 | 31.14 | 199.00 | 4,436 | 1.56 | 45.94 | 0.05 |
| 10 | 1.00 | 2.00 | 3.00 | 25.00 | 27.64 | 179.00 | 4,440 | 1.59 | 46.40 | 0.06 |
| 11 | 2.00 | 2.00 | 5.00 | 27.00 | 26.71 | 184.00 | 4,440 | 1.86 | 43.87 | 0.07 |
| 12 | 2.00 | 2.00 | 6.00 | 33.00 | 31.86 | 242.00 | 4,440 | 1.90 | 42.14 | 0.06 |
| 13 | 2.00 | 2.00 | 5.00 | 39.00 | 38.00 | 302.00 | 4,430 | 1.87 | 43.50 | 0.05 |
| 14 | 2.00 | 2.00 | 7.00 | 41.00 | 42.93 | 338.00 | 4,433 | 1.73 | 44.96 | 0.04 |
| 15 | 1.00 | 2.00 | 4.00 | 36.00 | 41.79 | 285.50 | 4,440 | 1.45 | 44.91 | 0.03 |
| 16 | 2.00 | 2.00 | 4.00 | 28.00 | 33.93 | 212.00 | 4,439 | 1.88 | 43.46 | 0.06 |
| 17 | 2.00 | 2.00 | 5.00 | 23.00 | 26.71 | 172.00 | 4,440 | 1.76 | 43.83 | 0.07 |
| 18 | 2.00 | 2.00 | 6.00 | 20.00 | 22.64 | 156.00 | 4,440 | 1.83 | 44.05 | 0.08 |
| 19 | 2.00 | 2.00 | 13.00 | 18.00 | 19.93 | 125.00 | 4,440 | 1.81 | 43.78 | 0.09 |
| 20 | 2.00 | 10.00 | 200.00 | 15.00 | 17.14 | 79.00 | 4,439 | 2.15 | 30.16 | 0.13 |
| 21 | 86.00 | 191.00 | 450.00 | 19.00 | 25.79 | 34.00 | 4,411 | 98.34 | 0.09 | 3.81 |
| 22 | 2.00 | 100.00 | 300.00 | 15.00 | 28.29 | 66.00 | 4,419 | 1.85 | 31.61 | 0.07 |
| 23 | 2.00 | 2.00 | 156.00 | 13.00 | 16.21 | 81.00 | 4,428 | 1.85 | 38.78 | 0.11 |

Spread geral (mediana M5): **2.0 pts**, p90 2.0, máx 450. ATR mediano M5: **25.8 pts**. Razão spread/ATR: **0.08**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 512 | 615.52 | 79.37 | 384.43 | 59.57 | 4.67 |
| ter | 515 | 632.70 | 39.29 | 408.32 | 55.15 | 2.18 |
| qua | 513 | 667.95 | 44.78 | 421.29 | 57.70 | 2.41 |
| qui | 515 | 710.81 | -4.44 | 513.63 | 53.59 | -0.20 |
| sex | 514 | 647.31 | 0.84 | 404.15 | 52.72 | 0.05 |

Autocorrelação do retorno diário (lags 1-5): +0.017, +0.007, -0.033, +0.009, +0.006 (banda ±0.039). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.095, +0.096, +0.038.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 1,422 | 0 | -0.007 | -0.506 | nao |
| 1,422 | 1 | 0.006 | 0.523 | nao |
| 1,422 | 2 | -0.002 | -0.182 | nao |
| 1,422 | 3 | 0.007 | 0.689 | nao |
| 1,422 | 4 | 0.033 | 3.038 | sim |
| 1,422 | 5 | -0.009 | -0.620 | nao |
| 1,421 | 6 | 0.010 | 0.449 | nao |
| 1,422 | 7 | -0.031 | -1.065 | nao |
| 1,422 | 8 | -0.003 | -0.130 | nao |
| 1,421 | 9 | 0.019 | 0.842 | nao |
| 1,421 | 10 | 0.032 | 1.635 | nao |
| 1,421 | 11 | 0.041 | 1.996 | nao |
| 1,421 | 12 | -0.013 | -0.420 | nao |
| 1,421 | 13 | -0.072 | -2.544 | nao |
| 1,422 | 14 | -0.014 | -0.543 | nao |
| 1,422 | 15 | 0.049 | 2.251 | nao |
| 1,422 | 16 | 0.017 | 1.061 | nao |
| 1,422 | 17 | 0.002 | 0.169 | nao |
| 1,422 | 18 | -0.004 | -0.281 | nao |
| 1,420 | 19 | -0.008 | -0.649 | nao |
| 1,419 | 20 | -0.041 | -4.538 | sim |
| 1,419 | 21 | -0.016 | -1.357 | nao |
| 1,420 | 22 | 0.270 | 21.746 | sim |
| 1,422 | 23 | 0.099 | 9.553 | sim |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 6,776 | 0 | 0.013 | 1.627 | nao |
| 6,859 | 1 | 0.015 | 1.774 | nao |
| 6,816 | 2 | 0.007 | 0.767 | nao |
| 6,815 | 3 | 0.013 | 1.464 | nao |
| 6,089 | 4 | -0.004 | -0.386 | nao |
| 757 | 6 | 0.283 | 13.455 | sim |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,597 | 1 | 0.028 | 2.029 | nao |
| 2,424 | 2 | 0.018 | 1.271 | nao |
| 2,645 | 3 | 0.024 | 1.790 | nao |
| 2,664 | 4 | 0.016 | 1.149 | nao |
| 3,168 | 5 | 0.003 | 0.205 | nao |
| 3,098 | 6 | 0.022 | 1.665 | nao |
| 3,189 | 7 | 0.003 | 0.232 | nao |
| 3,171 | 8 | 0.016 | 1.215 | nao |
| 3,117 | 9 | 0.032 | 2.647 | nao |
| 2,927 | 10 | 0.019 | 1.476 | nao |
| 2,564 | 11 | 0.001 | 0.097 | nao |
| 2,548 | 12 | 0.000 | 0.019 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 121 combinações testadas):

| dia(0=seg) | hora_utc | n | ret_medio_ATR | std | t |
|---|---|---|---|---|---|
| 6 | 22 | 280 | 0.480 | 0.591 | 13.577 |
| 0 | 22 | 286 | 0.258 | 0.431 | 10.119 |
| 3 | 22 | 286 | 0.223 | 0.384 | 9.807 |
| 1 | 22 | 284 | 0.231 | 0.443 | 8.766 |
| 2 | 22 | 284 | 0.161 | 0.399 | 6.802 |
| 1 | 23 | 284 | 0.120 | 0.334 | 6.051 |
| 6 | 23 | 282 | 0.161 | 0.474 | 5.700 |
| 3 | 23 | 286 | 0.082 | 0.334 | 4.142 |
| 6 | 21 | 195 | 0.177 | 0.623 | 3.969 |
| 0 | 23 | 286 | 0.085 | 0.384 | 3.738 |
| 4 | 20 | 283 | -0.072 | 0.383 | -3.139 |
| 2 | 21 | 284 | -0.065 | 0.358 | -3.073 |

Autocorrelação do retorno H1, lags 1-10: -0.017, -0.003, +0.004, +0.007, +0.002, -0.004, +0.005, +0.001, -0.003, -0.002 (banda ±0.011). |retorno|: +0.179, +0.107, +0.024, -0.129, +0.194 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 257 | -0.058 | -0.924 | 45.136 |
| barra < -2 ATR | 321 | -0.008 | -0.131 | 48.910 |
| barra > +1 ATR | 2,263 | -0.029 | -1.544 | 47.857 |
| barra < -1 ATR | 2,138 | 0.024 | 1.155 | 51.263 |
| gap (barra ausente antes) | 292 | 0.501 | 14.045 | 82.877 |

Distribuição do retorno H1 em ATR: média +0.0152, desvio 0.711, assimetria -0.06, curtose 4.9; barras |ret|>2 ATR: 1.70%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 1.8 pts, máxima 174.2 pts no slot NY 17:00 de domingo; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | 105,987 | 206,976 | 1,081 | 721 | 42.2 | 7.8 | 17 | 76.0 | 23.3 |
| M15 | ret | 67,894 | 221,197 | 2,020 | 1,747 | 15.2 | 3.8 | 23 | 94.0 | 12.3 |
| M30 | ret | 33,888 | 190,690 | 2,051 | 1,864 | 70.8 | 5.8 | 26 | 98.0 | 6.3 |
| H1 | ret | 33,052 | 191,781 | 5,627 | 4,298 | 0.2 | 0.0 | 0 | 100.0 | 7.2 |
| M5 | hit | 105,987 | 617,868 | 4 | 0 | 14.8 | 0.5 | 2 | 7.0 | 2.8 |
| M15 | hit | 67,894 | 658,596 | 0 | 0 | 0.0 | 0.0 | 0 | 6.0 | 1.5 |
| M30 | hit | 33,888 | 567,384 | 0 | 0 | 0.0 | 0.0 | 0 | 9.0 | 2.2 |
| H1 | hit | 33,052 | 568,368 | 62 | 5 | 0.0 | 0.0 | 0 | 10.0 | 1.3 |


## 6.1 Modo `ret`

### M5 — modo `ret`

- eventos: 105,987 (2025-05-15 a 2026-10-16); descoberta 63,305 (até 2026-03-23), validação 42,395 (a partir de 2026-03-24)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 206,976**; passaram no BH (q=5%) na descoberta: **1,081**; confirmadas na validação: **721**
- melhores N da descoberta que repetem na validação: top 100: 76.0%, top 1000: 66.9%, top 10000: 35.3%
- **placebo** (6 deslocamentos): top 100: 23.3% (máx 45.0%), top 1000: 13.8% (máx 26.8%), top 10000: 7.7% (máx 11.1%); BH: média 42.2 (máx 141); confirmadas: média 7.8 (máx 17)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,305 | -0.008 | -2.587 | -0.215 |
| 15min bruto | 62,854 | 0.000 | 0.013 | 0.003 |
| 30min bruto | 62,179 | 0.019 | 1.043 | 0.490 |
| 60min bruto | 60,838 | 0.064 | 1.697 | 1.642 |
| 120min bruto | 58,162 | 0.062 | 0.790 | 1.608 |
| 240min bruto | 52,848 | 0.051 | 0.294 | 1.326 |

**M5/ret: famílias distintas validadas: 2945; com líquido positivo e significativo na validação (custo realista): 42.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=7 & price_position_monthly_open=Q2 | 240min | COMPRA | 208 | 872 | 2.09 | nao | 2.49 | 1 | 49.53 | 39.83 | 39.83 | 11.58 | 1.06 | 11.25 | 75.57 | 2/2 | 2/2 | 1.85 | 77.80 | 9.70 |
| hour=13 & mtf_W1=BEARISH | 60min | VENDA | 1,776 | 250 | -2.52 | nao | -2.84 | 1 | 49.70 | 47.84 | 47.97 | 9.44 | -5.96 | 10.63 | 68.80 | 2/2 | 10/12 | 52.41 | 43.54 | 1.72 |
| month=3 & session_high_distance_atr=Q1 | 120min | COMPRA | 549 | 176 | 2.02 | nao | 2.14 | 1 | 46.44 | 37.07 | 37.07 | 7.27 | -1.75 | 7.59 | 71.02 | 1/1 | 1/1 | 16.72 | 57.42 | 9.38 |
| mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | 60min | VENDA | 268 | 66 | -2.29 | nao | -2.33 | 1 | 46.55 | 45.22 | 45.07 | 7.21 | -5.96 | 8.10 | 74.24 | 2/2 | 6/7 | 14.24 | 75.90 | 1.47 |
| news_state=EVENTS_2_AROUND_60M & month=3 | 60min | COMPRA | 192 | 97 | 2.44 | nao | 2.18 | 1 | 40.16 | 38.01 | 38.01 | 6.91 | -3.11 | 7.44 | 73.20 | 1/1 | 1/1 | 17.89 | 57.73 | 2.15 |
| price_position_weekly_open=Q4 & prev_day_low_distance_atr=Q3 | 60min | COMPRA | 2,930 | 2,496 | 2.12 | nao | 2.96 | 1 | 18.16 | 10.48 | 10.48 | 6.74 | -3.11 | 9.07 | 56.77 | 2/2 | 12/18 | 4.89 | 16.07 | 7.68 |
| news_state=EVENTS_2_AROUND_60M & month=3 | 120min | COMPRA | 185 | 97 | 2.03 | nao | 1.68 | 1 | 51.89 | 49.74 | 49.74 | 6.08 | -1.75 | 6.27 | 76.29 | 1/1 | 1/1 | 24.52 | 74.44 | 2.15 |
| mtf_D1=BEARISH & prev_day_low_distance_atr=Q2 | 120min | COMPRA | 4,451 | 926 | 2.10 | nao | 2.17 | 1 | 34.58 | 20.38 | 20.38 | 5.75 | -1.75 | 6.33 | 57.88 | 1/2 | 7/15 | 6.97 | 33.78 | 14.21 |
| day_of_week=WEDNESDAY & hour=7 | 60min | COMPRA | 528 | 359 | 2.08 | nao | 2.31 | 1 | 20.68 | 18.90 | 18.90 | 5.73 | -3.11 | 6.68 | 66.02 | 2/2 | 14/18 | 2.18 | 35.53 | 1.77 |
| mtf_H4=RANGE & prev_day_low_distance_atr=Q3 | 60min | COMPRA | 2,946 | 1,495 | 2.02 | nao | 2.00 | 1 | 15.49 | 8.70 | 8.70 | 5.21 | -3.11 | 7.17 | 54.45 | 1/2 | 9/18 | 4.39 | 13.01 | 6.79 |
| mtf_M15=BULLISH & prev_day_low_distance_atr=Q2 | 60min | COMPRA | 3,239 | 1,343 | 2.03 | nao | 2.20 | 1 | 17.48 | 10.97 | 10.97 | 4.98 | -3.11 | 6.52 | 55.99 | 2/2 | 12/18 | 14.83 | 7.12 | 6.51 |
| mtf_D1=BEARISH & prev_day_low_distance_atr=Q3 | 60min | COMPRA | 5,258 | 1,512 | 2.44 | nao | 2.48 | 1 | 15.20 | 7.55 | 7.55 | 4.93 | -3.11 | 7.03 | 56.35 | 1/2 | 12/14 | 2.96 | 12.14 | 7.65 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 30min | VENDA | 223 | 110 | -2.74 | nao | -2.22 | 1 | 32.05 | 30.17 | 30.23 | 4.86 | -6.46 | 5.88 | 70.00 | 2/2 | 11/14 | 18.54 | 41.92 | 1.82 |
| mtf_H1=BULLISH & price_position_daily_open=Q1 | 60min | COMPRA | 687 | 332 | 2.09 | nao | 3.32 | 1 | 48.39 | 16.79 | 16.79 | 4.16 | -3.11 | 4.94 | 56.93 | 1/2 | 12/18 | 14.24 | 19.35 | 31.60 |
| hour=13 & mtf_W1=BEARISH | 30min | VENDA | 1,776 | 256 | -2.23 | nao | -1.98 | 1 | 20.39 | 18.54 | 18.59 | 4.15 | -6.46 | 5.60 | 56.25 | 2/2 | 9/12 | 27.88 | 9.29 | 1.80 |
| news_state=EVENTS_2_AROUND_60M & month=3 | 30min | COMPRA | 192 | 97 | 2.26 | nao | 2.19 | 1 | 19.81 | 17.66 | 17.66 | 3.79 | -5.11 | 4.87 | 69.07 | 1/1 | 1/1 | 12.47 | 22.75 | 2.15 |
| price_position_daily_open=Q3 & prev_day_low_distance_atr=Q3 | 60min | COMPRA | 2,586 | 1,950 | 2.03 | nao | 1.80 | 1 | 11.34 | 5.26 | 5.26 | 3.66 | -3.11 | 5.92 | 55.44 | 1/2 | 11/18 | 1.19 | 9.34 | 6.08 |
| hour=9 & price_position_monthly_open=Q3 | 30min | COMPRA | 570 | 327 | 2.09 | nao | 1.77 | 1 | 10.20 | 8.62 | 8.62 | 3.58 | -5.11 | 5.70 | 54.13 | 2/2 | 13/16 | 3.31 | 13.91 | 1.58 |
| hour=9 & mtf_H1=RANGE | 30min | COMPRA | 768 | 540 | 2.31 | nao | 1.81 | 1 | 7.77 | 6.19 | 6.19 | 3.45 | -5.11 | 6.31 | 55.74 | 2/2 | 11/18 | 2.89 | 9.49 | 1.58 |
| day_of_week=WEDNESDAY & hour=7 | 30min | COMPRA | 528 | 359 | 2.71 | nao | 2.12 | 1 | 10.14 | 8.37 | 8.37 | 3.28 | -5.11 | 5.30 | 61.84 | 2/2 | 14/18 | 0.22 | 16.47 | 1.77 |
| mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | 30min | VENDA | 268 | 66 | -2.45 | nao | -1.71 | 1 | 16.14 | 14.81 | 14.73 | 3.23 | -6.46 | 4.61 | 65.15 | 2/2 | 5/7 | 4.67 | 24.78 | 1.41 |
| hour=9 & price_position_monthly_open=Q3 | 15min | COMPRA | 571 | 327 | 2.06 | nao | 2.24 | 1 | 7.01 | 5.43 | 5.43 | 3.23 | -6.12 | 6.85 | 52.60 | 2/2 | 11/16 | 1.58 | 9.27 | 1.58 |
| news_state=EVENTS_3_AROUND_60M & price_position_weekly_open=Q2 | 15min | VENDA | 208 | 118 | -2.15 | nao | -2.34 | 1 | 18.94 | 17.12 | 17.15 | 3.18 | -6.58 | 4.38 | 66.10 | 2/2 | 10/13 | 26.30 | 7.99 | 1.80 |
| mtf_D1=BEARISH & previous_high_distance_atr=Q1 | 60min | COMPRA | 4,498 | 1,036 | 2.59 | nao | 2.57 | 1 | 19.80 | 5.76 | 5.76 | 3.07 | -3.11 | 4.77 | 56.76 | 0/2 | 9/15 | 5.61 | 5.90 | 14.04 |
| price_position_daily_open=Q5 & cost_atr=Q5 | 60min | VENDA | 741 | 581 | -2.47 | nao | -2.65 | 1 | 16.04 | 7.03 | 5.72 | 3.06 | -5.96 | 6.22 | 52.32 | 2/2 | 9/17 | 10.08 | 1.39 | 10.32 |

### M15 — modo `ret`

- eventos: 67,894 (2024-01-22 a 2026-10-16); descoberta 40,640 (até 2025-09-11), validação 27,158 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 221,197**; passaram no BH (q=5%) na descoberta: **2,020**; confirmadas na validação: **1,747**
- melhores N da descoberta que repetem na validação: top 100: 94.0%, top 1000: 93.4%, top 10000: 53.7%
- **placebo** (6 deslocamentos): top 100: 12.3% (máx 33.0%), top 1000: 8.0% (máx 14.7%), top 10000: 5.5% (máx 7.6%); BH: média 15.2 (máx 91); confirmadas: média 3.8 (máx 23)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 40,640 | 0.002 | 0.853 | 0.122 |
| 15min bruto | 39,999 | 0.001 | 0.369 | 0.073 |
| 30min bruto | 39,443 | 0.011 | 1.404 | 0.557 |
| 60min bruto | 38,447 | 0.030 | 1.811 | 1.492 |
| 120min bruto | 36,571 | 0.042 | 1.174 | 2.049 |
| 240min bruto | 32,988 | 0.032 | 0.406 | 1.576 |

**M15/ret: famílias distintas validadas: 5702; com líquido positivo e significativo na validação (custo realista): 43.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | 240min | VENDA | 194 | 149 | -2.08 | nao | -2.37 | 1 | 78.57 | 70.07 | 76.44 | 8.30 | -8.60 | 9.21 | 78.52 | 3/3 | 4/4 | 46.81 | 105.68 | 2.13 |
| price_position_weekly_open=Q5 & price_position_monthly_open=Q2 | 120min | VENDA | 780 | 46 | -2.31 | nao | -2.55 | 1 | 61.48 | 59.70 | 59.42 | 7.15 | -6.51 | 7.84 | 89.13 | 3/3 | 7/8 | 61.65 | 57.19 | 2.06 |
| price_position_weekly_open=Q5 & price_position_monthly_open=Q2 | 60min | VENDA | 831 | 46 | -2.52 | nao | -3.14 | 1 | 42.02 | 40.24 | 40.13 | 5.56 | -5.82 | 6.29 | 84.78 | 3/3 | 7/8 | 36.13 | 44.13 | 1.89 |
| day_of_week=MONDAY & month=7 | 120min | COMPRA | 781 | 351 | 2.15 | nao | 1.98 | 1 | 31.16 | 24.59 | 24.59 | 5.53 | -3.06 | 6.23 | 56.98 | 3/3 | 3/3 | 23.57 | 25.60 | 6.57 |
| mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | 120min | VENDA | 230 | 157 | -2.45 | nao | -2.20 | 1 | 39.39 | 31.22 | 37.27 | 5.11 | -6.51 | 6.00 | 68.79 | 3/3 | 4/4 | 18.22 | 56.07 | 2.13 |
| month=8 & price_position_weekly_open=Q5 | 240min | VENDA | 431 | 228 | -2.18 | nao | -1.82 | 1 | 34.08 | 26.44 | 31.97 | 4.55 | -8.60 | 5.76 | 58.77 | 3/3 | 3/3 | 38.28 | 25.67 | 2.11 |
| price_position_weekly_open=Q5 & price_position_monthly_open=Q2 | 30min | VENDA | 858 | 46 | -2.64 | nao | -2.90 | 1 | 28.09 | 26.31 | 26.26 | 3.44 | -6.67 | 4.27 | 63.04 | 2/3 | 7/8 | 20.00 | 32.52 | 1.82 |
| session=LONDON & price_position_daily_open=Q1 | 60min | VENDA | 2,009 | 815 | -2.48 | nao | -2.01 | 1 | 13.84 | 12.02 | 11.98 | 3.39 | -5.82 | 5.15 | 54.60 | 3/3 | 24/34 | 10.85 | 13.12 | 1.85 |
| month=3 & prev_day_high_distance_atr=Q2 | 120min | COMPRA | 714 | 391 | 2.27 | nao | 1.84 | 1 | 25.06 | 16.72 | 16.72 | 3.37 | -3.06 | 4.01 | 54.22 | 3/3 | 3/3 | 11.90 | 21.52 | 8.34 |
| slot_hhmm=00:30 & dom_w=d22_31 | 15min | VENDA | 133 | 87 | -2.34 | nao | -3.95 | 1 | 9.41 | 7.63 | 7.66 | 3.35 | -6.96 | 6.34 | 64.37 | 3/3 | 22/33 | 7.11 | 8.20 | 1.75 |
| month=3 & news_min_since_last_high=Q3 | 120min | COMPRA | 451 | 206 | 2.21 | nao | 1.92 | 1 | 27.29 | 16.31 | 16.31 | 3.17 | -3.06 | 3.75 | 56.80 | 2/3 | 2/3 | 28.58 | 4.05 | 10.98 |
| slot_hhmm=00:30 & mtf_M15=BULLISH | 15min | VENDA | 130 | 111 | -2.10 | nao | -3.88 | 2 | 8.94 | 7.18 | 7.23 | 3.16 | -6.96 | 6.16 | 59.46 | 3/3 | 14/22 | 10.14 | 4.38 | 1.70 |
| price_position_monthly_open=Q1 & news_min_since_last_high=Q3 | 120min | COMPRA | 849 | 246 | 2.14 | nao | 1.88 | 1 | 35.38 | 18.58 | 18.58 | 2.95 | -3.06 | 3.45 | 49.59 | 2/3 | 8/12 | 46.39 | -9.22 | 16.80 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 60min | VENDA | 181 | 74 | -2.43 | nao | -1.80 | 1 | 38.77 | 36.88 | 36.94 | 2.68 | -5.82 | 3.08 | 63.51 | 3/3 | 19/25 | 25.48 | 48.39 | 1.83 |
| slot_hhmm=00:30 & structure_at_close=BULLISH | 15min | VENDA | 154 | 108 | -2.31 | nao | -3.44 | 1 | 7.71 | 5.95 | 5.98 | 2.61 | -6.96 | 5.60 | 58.33 | 3/3 | 16/25 | 5.59 | 6.37 | 1.74 |
| slot_hhmm=00:30 & volatility_state=LOW | 15min | VENDA | 153 | 114 | -2.63 | nao | -3.75 | 1 | 7.54 | 5.71 | 5.65 | 2.61 | -6.96 | 5.77 | 59.65 | 3/3 | 21/30 | 9.93 | 1.37 | 1.89 |
| mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | 60min | VENDA | 242 | 164 | -2.42 | nao | -1.92 | 1 | 16.93 | 9.02 | 13.02 | 2.49 | -5.82 | 3.59 | 63.41 | 3/3 | 4/4 | 5.21 | 20.82 | 3.91 |
| slot_hhmm=00:30 & news_min_since_last_high=Q3 | 15min | VENDA | 177 | 109 | -2.62 | nao | -2.79 | 1 | 7.40 | 5.56 | 5.59 | 2.30 | -6.96 | 5.12 | 59.63 | 3/3 | 22/33 | 12.16 | -0.86 | 1.81 |
| previous_low_distance_atr=Q3 & prev_day_high_distance_atr=Q3 | 120min | COMPRA | 1,665 | 985 | 2.09 | nao | 1.73 | 1 | 16.87 | 7.10 | 7.10 | 2.23 | -3.06 | 3.25 | 49.34 | 2/3 | 17/34 | -3.40 | 17.58 | 9.77 |
| hour=22 & price_position_monthly_open=Q5 | 60min | COMPRA | 265 | 165 | 3.17 | nao | 2.77 | 1 | 13.83 | 6.27 | 6.27 | 2.22 | -4.27 | 3.70 | 58.18 | 1/3 | 5/11 | 4.08 | 8.43 | 7.56 |
| slot_hhmm=09:30 & mtf_D1=BEARISH | 15min | COMPRA | 157 | 68 | 2.97 | nao | 2.53 | 1 | 10.43 | 8.60 | 8.60 | 2.22 | -6.97 | 3.99 | 60.29 | 3/3 | 13/18 | 15.25 | 1.96 | 1.82 |
| price_position_weekly_open=Q5 & price_position_monthly_open=Q2 | 15min | VENDA | 873 | 46 | -2.65 | nao | -2.73 | 1 | 12.72 | 10.94 | 10.92 | 2.18 | -6.96 | 3.53 | 63.04 | 2/3 | 4/8 | 5.74 | 16.10 | 1.80 |
| session=LONDON & price_position_daily_open=Q1 | 30min | VENDA | 2,009 | 823 | -2.70 | nao | -2.23 | 1 | 6.95 | 5.13 | 5.11 | 2.04 | -6.67 | 4.82 | 50.55 | 3/3 | 22/34 | 5.30 | 4.92 | 1.84 |
| dom_w=d08_14 & atr_ratio=Q5 | 60min | COMPRA | 1,569 | 1,021 | 2.17 | nao | 1.97 | 1 | 10.48 | 5.06 | 5.06 | 2.01 | -4.27 | 3.80 | 53.48 | 2/3 | 20/33 | 0.65 | 9.47 | 5.42 |
| month=3 & prev_day_high_distance_atr=Q2 | 60min | COMPRA | 753 | 409 | 2.17 | nao | 2.02 | 1 | 15.28 | 7.23 | 7.23 | 2.00 | -4.27 | 3.20 | 52.08 | 3/3 | 3/3 | 6.35 | 8.10 | 8.05 |

### M30 — modo `ret`

- eventos: 33,888 (2024-01-22 a 2026-10-16); descoberta 20,284 (até 2025-09-11), validação 13,556 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 190,690**; passaram no BH (q=5%) na descoberta: **2,051**; confirmadas na validação: **1,864**
- melhores N da descoberta que repetem na validação: top 100: 98.0%, top 1000: 95.1%, top 10000: 53.3%
- **placebo** (6 deslocamentos): top 100: 6.3% (máx 23.0%), top 1000: 7.2% (máx 12.0%), top 10000: 6.3% (máx 7.8%); BH: média 70.8 (máx 263); confirmadas: média 5.8 (máx 26)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 20,284 | 0.004 | 1.215 | 0.298 |
| 15min bruto | 20,170 | 0.006 | 1.404 | 0.455 |
| 30min bruto | 19,692 | 0.005 | 0.927 | 0.383 |
| 60min bruto | 19,197 | 0.018 | 1.510 | 1.281 |
| 120min bruto | 18,258 | 0.027 | 1.064 | 1.911 |
| 240min bruto | 16,460 | 0.018 | 0.329 | 1.330 |

**M30/ret: famílias distintas validadas: 5556; com líquido positivo e significativo na validação (custo realista): 74.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=MONDAY & month=7 | 240min | COMPRA | 354 | 159 | 2.42 | nao | 2.30 | 1 | 62.17 | 54.55 | 54.55 | 5.49 | -1.37 | 5.63 | 63.52 | 3/3 | 3/3 | 47.87 | 61.15 | 7.62 |
| mtf_D1=BREAK_UP & cum10=Q5 | 120min | VENDA | 223 | 264 | -2.07 | nao | -2.43 | 1 | 29.80 | 19.99 | 27.90 | 4.49 | -6.97 | 5.66 | 56.44 | 3/3 | 13/15 | 43.78 | 12.02 | 1.90 |
| day_of_week=TUESDAY & prev_day_low_distance_atr=Q3 | 120min | COMPRA | 722 | 528 | 2.24 | nao | 3.10 | 1 | 21.36 | 14.90 | 14.90 | 3.98 | -2.85 | 4.79 | 59.09 | 3/3 | 27/34 | 11.10 | 18.71 | 6.46 |
| day_of_week=MONDAY & month=7 | 120min | COMPRA | 390 | 175 | 2.67 | nao | 2.27 | 1 | 31.79 | 24.71 | 24.71 | 3.85 | -2.85 | 4.29 | 58.29 | 3/3 | 3/3 | 23.15 | 26.24 | 7.09 |
| month=8 & price_position_weekly_open=Q5 | 240min | VENDA | 211 | 114 | -2.27 | nao | -1.81 | 1 | 38.10 | 29.06 | 35.96 | 3.56 | -9.09 | 4.44 | 58.77 | 3/3 | 3/3 | 42.82 | 29.11 | 2.13 |
| prev_day_low_distance_atr=Q5 & news_min_to_next_high=Q1 | 120min | VENDA | 308 | 281 | -2.16 | nao | -1.80 | 1 | 25.75 | 23.88 | 23.88 | 3.14 | -6.97 | 4.12 | 56.94 | 3/3 | 19/31 | -5.71 | 53.26 | 1.87 |
| prev_day_low_distance_atr=Q5 & news_min_since_last_high=Q5 | 60min | VENDA | 527 | 415 | -2.09 | nao | -2.45 | 1 | 12.48 | 10.67 | 10.65 | 2.91 | -6.21 | 4.69 | 53.98 | 3/3 | 23/31 | 8.91 | 12.37 | 1.83 |
| session=LONDON & prev_day_low_distance_atr=Q5 | 120min | VENDA | 861 | 656 | -2.03 | nao | -1.86 | 1 | 14.38 | 12.58 | 12.51 | 2.83 | -6.97 | 4.54 | 54.27 | 2/3 | 24/33 | -2.07 | 27.09 | 1.87 |
| prev_day_low_distance_atr=Q5 & cum10=Q5 | 120min | VENDA | 1,147 | 869 | -2.45 | nao | -1.98 | 1 | 11.72 | 8.70 | 9.76 | 2.80 | -6.97 | 4.98 | 53.51 | 3/3 | 25/33 | 6.61 | 12.89 | 1.97 |
| prev_day_low_distance_atr=Q2 & session_high_distance_atr=Q4 | 120min | COMPRA | 598 | 300 | 2.10 | nao | 2.05 | 1 | 20.72 | 14.04 | 14.04 | 2.79 | -2.85 | 3.38 | 57.00 | 3/3 | 25/34 | 6.55 | 21.53 | 6.68 |
| news_state=EVENTS_4_AROUND_60M & session_high_distance_atr=Q3 | 5min | VENDA | 134 | 86 | -2.32 | nao | -4.30 | 1 | 36.67 | 18.01 | 17.80 | 2.78 | -6.29 | 3.77 | 58.14 | 3/3 | 15/26 | 24.54 | 11.06 | 18.88 |
| day_of_week=FRIDAY & news_state=EVENTS_4_AROUND_60M | 60min | VENDA | 226 | 167 | -2.02 | nao | -2.22 | 1 | 26.10 | 7.78 | 22.96 | 2.76 | -6.21 | 3.54 | 52.69 | 3/3 | 25/30 | 36.70 | 9.38 | 3.14 |
| day_of_week=FRIDAY & news_state=EVENTS_4_AROUND_60M | 5min | VENDA | 369 | 246 | -3.44 | nao | -4.96 | 1 | 26.54 | 12.24 | 12.20 | 2.76 | -6.29 | 4.25 | 49.59 | 3/3 | 22/33 | 16.14 | 8.26 | 14.34 |
| price_position_daily_open=Q5 & news_min_since_last_high=Q5 | 120min | VENDA | 583 | 328 | -2.28 | nao | -1.90 | 1 | 17.53 | 15.69 | 15.64 | 2.70 | -6.97 | 3.95 | 56.10 | 3/3 | 21/31 | 18.53 | 12.75 | 1.89 |
| swing_low_distance_atr=Q5 & cum3=Q1 | 60min | COMPRA | 188 | 150 | 2.52 | nao | 3.03 | 1 | 21.30 | 15.27 | 15.27 | 2.65 | -4.82 | 3.49 | 60.67 | 3/3 | 23/32 | 16.35 | 14.18 | 6.03 |
| structure_before=BREAK_UP & prev_day_low_distance_atr=Q5 | 60min | VENDA | 426 | 345 | -2.47 | nao | -2.32 | 2 | 14.14 | 10.97 | 10.78 | 2.63 | -6.21 | 4.20 | 53.04 | 3/3 | 25/32 | 12.47 | 9.09 | 3.37 |
| session=LONDON & price_position_daily_open=Q1 | 60min | VENDA | 993 | 401 | -2.45 | nao | -1.98 | 1 | 14.68 | 12.87 | 12.82 | 2.54 | -6.21 | 3.85 | 54.61 | 3/3 | 24/34 | 13.00 | 12.65 | 1.86 |
| hour=22 & price_position_monthly_open=Q5 | 60min | COMPRA | 137 | 83 | 3.10 | nao | 3.26 | 1 | 16.05 | 9.71 | 9.71 | 2.51 | -4.82 | 3.71 | 62.65 | 1/2 | 5/11 | 7.50 | 11.86 | 6.34 |
| price_position_monthly_open=Q1 & news_min_since_last_high=Q3 | 120min | COMPRA | 452 | 134 | 2.17 | nao | 1.93 | 1 | 35.31 | 20.43 | 20.43 | 2.48 | -2.85 | 2.83 | 49.25 | 3/3 | 10/12 | 50.09 | -9.23 | 14.88 |
| price_position_daily_open=Q3 & previous_high_distance_atr=Q3 | 60min | COMPRA | 947 | 756 | 2.05 | nao | 2.97 | 1 | 10.40 | 5.02 | 5.02 | 2.47 | -4.82 | 4.87 | 53.97 | 2/3 | 22/34 | 4.05 | 5.98 | 5.39 |
| previous_low_distance_atr=Q3 | 120min | COMPRA | 3,649 | 2,321 | 2.34 | nao | 2.82 | 1 | 11.60 | 5.00 | 5.00 | 2.45 | -2.85 | 4.22 | 53.17 | 3/3 | 22/34 | 5.20 | 4.80 | 6.60 |
| price_position_weekly_open=Q4 & news_min_since_last_high=Q4 | 60min | COMPRA | 393 | 398 | 2.03 | nao | 2.16 | 1 | 9.40 | 7.73 | 7.73 | 2.44 | -4.82 | 3.98 | 55.28 | 3/3 | 21/32 | 9.00 | 6.47 | 1.67 |
| previous_low_distance_atr=Q3 & swing_low_distance_atr=Q4 | 120min | COMPRA | 2,013 | 1,360 | 2.24 | nao | 1.91 | 1 | 10.40 | 6.40 | 6.40 | 2.43 | -2.85 | 3.69 | 54.63 | 3/3 | 23/34 | 9.05 | 3.74 | 4.00 |
| mtf_D1=BREAK_UP & cum10=Q5 | 60min | VENDA | 231 | 270 | -2.39 | nao | -2.15 | 1 | 14.50 | 4.86 | 12.03 | 2.41 | -6.21 | 3.70 | 51.85 | 3/3 | 14/15 | 13.24 | 10.81 | 2.47 |
| prev_day_low_distance_atr=Q5 & news_min_to_next_high=Q1 | 60min | VENDA | 310 | 283 | -2.15 | nao | -2.12 | 1 | 14.49 | 12.63 | 12.64 | 2.38 | -6.21 | 3.60 | 55.12 | 3/3 | 22/31 | -0.22 | 25.41 | 1.85 |

### H1 — modo `ret`

- eventos: 33,052 (2021-06-02 a 2026-10-16); descoberta 19,808 (até 2024-08-26), validação 13,221 (a partir de 2024-08-27)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 191,781**; passaram no BH (q=5%) na descoberta: **5,627**; confirmadas na validação: **4,298**
- melhores N da descoberta que repetem na validação: top 100: 100.0%, top 1000: 99.4%, top 10000: 58.9%
- **placebo** (6 deslocamentos): top 100: 7.2% (máx 16.0%), top 1000: 5.5% (máx 8.2%), top 10000: 5.4% (máx 6.4%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 19,808 | -0.003 | -1.486 | -0.357 |
| 15min bruto | 19,542 | -0.004 | -1.150 | -0.401 |
| 30min bruto | 19,251 | -0.006 | -1.344 | -0.625 |
| 60min bruto | 18,188 | 0.001 | 0.224 | 0.164 |
| 120min bruto | 16,999 | 0.005 | 0.381 | 0.600 |
| 240min bruto | 15,015 | 0.013 | 0.411 | 1.464 |

**H1/ret: famílias distintas validadas: 4575; com líquido positivo e significativo na validação (custo realista): 65.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=FRIDAY & ret_bar_atr=Q3 | 5min | VENDA | 685 | 475 | -3.39 | sim | -4.81 | 1 | 12.35 | 6.23 | 6.39 | 3.03 | -4.82 | 5.45 | 49.05 | 5/6 | 38/65 | 4.73 | 8.05 | 5.96 |
| hour=22 & mtf_M15=BULLISH | 60min | COMPRA | 144 | 90 | 5.81 | sim | 8.00 | 2 | 50.02 | 14.99 | 14.99 | 2.97 | -6.02 | 4.13 | 57.78 | 5/5 | 18/22 | 18.81 | 11.16 | 35.04 |
| day_of_week=FRIDAY & volatility_state=VERY_LOW | 5min | VENDA | 573 | 319 | -4.47 | sim | -4.46 | 1 | 14.18 | 6.93 | 7.09 | 2.96 | -4.82 | 5.04 | 49.22 | 4/6 | 36/65 | 2.97 | 11.18 | 7.09 |
| day_of_week=FRIDAY & range_atr=Q1 | 5min | VENDA | 594 | 340 | -4.53 | sim | -4.57 | 1 | 13.58 | 6.45 | 6.61 | 2.91 | -4.82 | 5.11 | 49.41 | 4/6 | 38/65 | 2.82 | 10.40 | 6.97 |
| day_of_week=FRIDAY & cost_atr=Q5 | 5min | VENDA | 564 | 800 | -4.38 | sim | -6.51 | 1 | 15.61 | 5.68 | 5.92 | 2.79 | -4.82 | 5.32 | 50.62 | 4/6 | 34/55 | 3.13 | 8.72 | 9.68 |
| previous_high_distance_atr=Q5 & news_min_since_last_high=Q5 | 30min | VENDA | 129 | 412 | -2.90 | nao | -3.77 | 1 | 10.35 | 8.42 | 8.51 | 2.77 | -5.85 | 4.74 | 56.55 | 4/4 | 28/37 | 8.82 | 8.20 | 1.84 |
| hour=22 & mtf_M15=BULLISH | 30min | COMPRA | 158 | 91 | 6.54 | sim | 8.36 | 2 | 47.85 | 12.96 | 12.96 | 2.76 | -7.16 | 4.26 | 52.75 | 4/5 | 15/24 | 19.61 | 6.46 | 34.88 |
| streak=4 & prev_day_low_distance_atr=Q5 | 5min | VENDA | 207 | 129 | -2.60 | nao | -3.21 | 1 | 11.92 | 9.16 | 9.60 | 2.69 | -4.82 | 4.05 | 54.26 | 6/6 | 23/37 | 11.25 | 7.98 | 2.32 |
| slot_hhmm=20:00 & previous_high_distance_atr=Q5 | 5min | VENDA | 136 | 105 | -7.75 | sim | -7.65 | 2 | 70.83 | 27.42 | 20.63 | 2.68 | -4.82 | 3.32 | 50.48 | 5/6 | 16/23 | 14.79 | 26.36 | 50.20 |
| hour=11 & mtf_H4=BULLISH | 5min | VENDA | 276 | 188 | -2.71 | nao | -3.81 | 2 | 6.13 | 4.10 | 4.16 | 2.63 | -4.82 | 5.62 | 59.04 | 5/6 | 36/53 | 3.56 | 4.76 | 1.97 |
| previous_high_distance_atr=Q5 & news_min_since_last_high=Q5 | 60min | VENDA | 128 | 411 | -4.07 | sim | -3.00 | 1 | 14.65 | 12.72 | 12.81 | 2.60 | -4.93 | 3.68 | 56.45 | 4/4 | 33/37 | 14.41 | 11.21 | 1.84 |
| hour=10 & price_position_daily_open=Q3 | 60min | COMPRA | 126 | 102 | 3.10 | nao | 2.56 | 2 | 20.12 | 18.14 | 18.14 | 2.51 | -6.02 | 3.34 | 58.82 | 6/6 | 14/18 | 24.95 | 11.33 | 1.98 |
| day_of_week=FRIDAY & session=NEW_YORK | 60min | VENDA | 442 | 342 | -4.48 | sim | -2.80 | 1 | 13.62 | -5.53 | 11.73 | 2.42 | -4.93 | 3.49 | 53.22 | 6/6 | 48/65 | 4.73 | 18.73 | 1.89 |
| day_of_week=FRIDAY & cost_atr=Q5 | 15min | VENDA | 551 | 795 | -3.90 | sim | -5.61 | 1 | 14.75 | 5.21 | 5.46 | 2.39 | -5.02 | 4.79 | 51.19 | 5/6 | 35/55 | 2.49 | 8.42 | 9.29 |
| range_atr=Q1 & price_position_weekly_open=Q5 | 60min | VENDA | 627 | 287 | -2.96 | nao | -5.06 | 1 | 18.02 | 7.50 | 8.39 | 2.36 | -4.93 | 3.74 | 56.45 | 6/6 | 36/53 | 11.81 | 4.99 | 9.63 |
| day_of_week=FRIDAY & price_position_daily_open=Q5 | 5min | VENDA | 721 | 402 | -4.57 | sim | -4.19 | 1 | 10.98 | 5.28 | 5.39 | 2.36 | -4.82 | 4.56 | 50.50 | 6/6 | 41/61 | 2.48 | 8.30 | 5.59 |
| volatility_state=VERY_LOW & price_position_weekly_open=Q5 | 60min | VENDA | 596 | 274 | -2.93 | nao | -4.91 | 1 | 18.30 | 7.63 | 8.65 | 2.33 | -4.93 | 3.66 | 56.20 | 6/6 | 35/53 | 10.02 | 7.27 | 9.66 |
| day_of_week=FRIDAY & structure_at_close=BULLISH | 5min | VENDA | 1,193 | 819 | -3.13 | nao | -4.64 | 1 | 7.82 | 3.24 | 3.32 | 2.30 | -4.82 | 5.87 | 49.57 | 5/6 | 37/64 | 1.14 | 5.49 | 4.50 |
| hour=6 & price_position_monthly_open=Q1 | 5min | VENDA | 160 | 75 | -3.10 | nao | -2.35 | 2 | 14.39 | 12.17 | 12.42 | 2.29 | -4.82 | 3.18 | 57.33 | 4/4 | 15/21 | 12.09 | 12.74 | 1.97 |
| day_of_week=FRIDAY & mtf_M15=BULLISH | 5min | VENDA | 1,233 | 813 | -4.59 | sim | -4.66 | 1 | 8.58 | 3.55 | 3.64 | 2.21 | -4.82 | 5.37 | 50.18 | 5/6 | 42/65 | 2.18 | 5.11 | 4.94 |
| prev_day_low_distance_atr=Q5 & session_high_distance_atr=Q5 | 30min | VENDA | 917 | 663 | -4.06 | sim | -3.68 | 1 | 9.24 | 6.50 | 5.44 | 2.19 | -5.85 | 4.67 | 52.04 | 5/6 | 44/65 | 7.21 | 3.68 | 3.80 |
| day_of_week=FRIDAY & body_pct=Q1 | 5min | VENDA | 727 | 497 | -2.59 | nao | -4.06 | 1 | 9.11 | 4.11 | 4.26 | 2.19 | -4.82 | 4.79 | 48.09 | 4/6 | 38/65 | 3.81 | 4.71 | 4.85 |
| slot_hhmm=12:00 & cost_atr=Q5 | 30min | VENDA | 127 | 229 | -2.99 | nao | -2.74 | 2 | 10.04 | 7.96 | 8.06 | 2.15 | -5.85 | 3.73 | 55.02 | 5/5 | 18/32 | 7.49 | 8.63 | 1.98 |
| price_position_daily_open=Q5 & news_min_since_last_high=Q5 | 120min | VENDA | 122 | 376 | -2.86 | nao | -1.76 | 1 | 17.35 | 15.41 | 15.52 | 2.14 | -5.32 | 2.93 | 53.19 | 3/3 | 20/29 | 4.06 | 26.98 | 1.83 |
| slot_hhmm=22:00 & mtf_M15=BULLISH | 15min | COMPRA | 168 | 92 | 7.65 | sim | 8.60 | 2 | 42.72 | 7.84 | 7.84 | 2.14 | -6.61 | 3.92 | 48.91 | 5/6 | 15/27 | 8.84 | 6.85 | 34.87 |

## 6.2 Modo `hit`

### M5 — modo `hit`

- eventos: 105,987 (2025-05-15 a 2026-10-16); descoberta 63,305 (até 2026-03-23), validação 42,395 (a partir de 2026-03-24)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 617,868**; passaram no BH (q=5%) na descoberta: **4**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 7.0%, top 1000: 3.4%, top 10000: 1.3%
- **placebo** (6 deslocamentos): top 100: 2.8% (máx 5.0%), top 1000: 1.8% (máx 4.6%), top 10000: 1.1% (máx 2.6%); BH: média 14.8 (máx 26); confirmadas: média 0.5 (máx 2)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 62,841 | -0.320 |  | -8.249 |
| C alvo 0.5ATR/60min liquido | 60,825 | -0.308 |  | -7.939 |
| C alvo 0.5ATR/240min liquido | 52,835 | -0.336 |  | -8.660 |
| C alvo 1.0ATR/15min liquido | 62,841 | -0.306 |  | -7.882 |
| C alvo 1.0ATR/60min liquido | 60,825 | -0.291 |  | -7.494 |
| C alvo 1.0ATR/240min liquido | 52,835 | -0.333 |  | -8.577 |
| C alvo 2.0ATR/15min liquido | 62,841 | -0.293 |  | -7.560 |
| C alvo 2.0ATR/60min liquido | 60,825 | -0.263 |  | -6.782 |
| C alvo 2.0ATR/240min liquido | 52,835 | -0.307 |  | -7.917 |
| V alvo 0.5ATR/15min liquido | 62,841 | -0.289 |  | -7.449 |
| V alvo 0.5ATR/60min liquido | 60,825 | -0.273 |  | -7.044 |
| V alvo 0.5ATR/240min liquido | 52,835 | -0.297 |  | -7.663 |
| V alvo 1.0ATR/15min liquido | 62,841 | -0.279 |  | -7.206 |
| V alvo 1.0ATR/60min liquido | 60,825 | -0.244 |  | -6.294 |
| V alvo 1.0ATR/240min liquido | 52,835 | -0.265 |  | -6.822 |
| V alvo 2.0ATR/15min liquido | 62,841 | -0.268 |  | -6.908 |
| V alvo 2.0ATR/60min liquido | 60,825 | -0.218 |  | -5.629 |
| V alvo 2.0ATR/240min liquido | 52,835 | -0.248 |  | -6.401 |

**M5/hit: famílias distintas validadas: 10; com líquido positivo e significativo na validação (custo realista): 10.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| news_state=EVENTS_2_AROUND_60M & month=3 | C alvo 0.5ATR ate 60min | COMPRA | 192 | 97 | 2.53 | nao | 2.51 | 1 |  | 12.78 | 12.78 | 9.07 | -6.78 | 13.66 | 92.78 | 1/1 | 1/1 | 10.21 | 15.30 | 2.15 |
| mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | V alvo 0.5ATR ate 60min | VENDA | 268 | 66 | 2.11 | nao | 3.40 | 1 |  | 12.48 | 12.48 | 8.52 | -7.31 | 13.30 | 95.45 | 2/2 | 7/7 | 12.04 | 12.91 | 1.47 |
| news_state=EVENTS_2_AROUND_60M & month=3 | C alvo 2.0ATR ate 240min | COMPRA | 121 | 83 | 2.18 | nao | 2.37 | 1 |  | 56.32 | 56.32 | 8.06 | -2.41 | 8.35 | 97.59 | 1/1 | 1/1 | 67.77 | 45.15 | 2.21 |
| mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | V alvo 2.0ATR ate 60min | VENDA | 268 | 66 | 2.54 | nao | 2.53 | 1 |  | 30.59 | 30.59 | 7.33 | -6.92 | 8.92 | 74.24 | 2/2 | 6/7 | 9.42 | 51.76 | 1.47 |
| news_state=EVENTS_2_AROUND_60M & month=3 | C alvo 2.0ATR ate 60min | COMPRA | 192 | 97 | 2.93 | nao | 2.57 | 1 |  | 34.33 | 34.33 | 7.29 | -3.74 | 8.04 | 76.29 | 1/1 | 1/1 | 22.45 | 45.96 | 2.15 |
| news_state=EVENTS_2_AROUND_60M & month=3 | C alvo 1.0ATR ate 60min | COMPRA | 192 | 97 | 3.24 | nao | 2.66 | 1 |  | 21.31 | 21.31 | 7.10 | -5.39 | 8.84 | 83.51 | 1/1 | 1/1 | 18.71 | 23.86 | 2.15 |
| mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | V alvo 1.0ATR ate 60min | VENDA | 268 | 66 | 2.99 | nao | 2.52 | 1 |  | 18.42 | 18.42 | 6.52 | -7.25 | 9.00 | 80.30 | 2/2 | 7/7 | 10.73 | 26.11 | 1.47 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | V alvo 1.0ATR ate 60min | VENDA | 223 | 110 | 2.15 | nao | 1.69 | 1 |  | 25.46 | 25.46 | 5.18 | -7.25 | 6.64 | 90.00 | 2/2 | 14/14 | 24.23 | 26.69 | 1.74 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | V alvo 2.0ATR ate 15min | VENDA | 223 | 110 | 2.40 | nao | 2.09 | 1 |  | 15.34 | 15.34 | 3.32 | -6.77 | 4.78 | 62.73 | 2/2 | 11/14 | 6.62 | 24.06 | 1.85 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | V alvo 1.0ATR ate 15min | VENDA | 223 | 110 | 2.04 | nao | 1.68 | 1 |  | 10.21 | 10.21 | 2.73 | -7.04 | 4.60 | 65.45 | 2/2 | 11/14 | 5.53 | 14.89 | 1.85 |

### M15 — modo `hit`

- eventos: 67,894 (2024-01-22 a 2026-10-16); descoberta 40,640 (até 2025-09-11), validação 27,158 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 658,596**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 6.0%, top 1000: 3.9%, top 10000: 1.9%
- **placebo** (6 deslocamentos): top 100: 1.5% (máx 5.0%), top 1000: 0.9% (máx 1.1%), top 10000: 0.5% (máx 0.6%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 39,986 | -0.150 |  | -7.369 |
| C alvo 0.5ATR/60min liquido | 38,434 | -0.139 |  | -6.852 |
| C alvo 0.5ATR/240min liquido | 32,975 | -0.156 |  | -7.694 |
| C alvo 1.0ATR/15min liquido | 39,986 | -0.143 |  | -7.024 |
| C alvo 1.0ATR/60min liquido | 38,434 | -0.128 |  | -6.283 |
| C alvo 1.0ATR/240min liquido | 32,975 | -0.158 |  | -7.764 |
| C alvo 2.0ATR/15min liquido | 39,986 | -0.140 |  | -6.910 |
| C alvo 2.0ATR/60min liquido | 38,434 | -0.126 |  | -6.180 |
| C alvo 2.0ATR/240min liquido | 32,975 | -0.179 |  | -8.792 |
| V alvo 0.5ATR/15min liquido | 39,986 | -0.128 |  | -6.305 |
| V alvo 0.5ATR/60min liquido | 38,434 | -0.109 |  | -5.347 |
| V alvo 0.5ATR/240min liquido | 32,975 | -0.107 |  | -5.255 |
| V alvo 1.0ATR/15min liquido | 39,986 | -0.116 |  | -5.690 |
| V alvo 1.0ATR/60min liquido | 38,434 | -0.093 |  | -4.579 |
| V alvo 1.0ATR/240min liquido | 32,975 | -0.085 |  | -4.159 |
| V alvo 2.0ATR/15min liquido | 39,986 | -0.108 |  | -5.331 |
| V alvo 2.0ATR/60min liquido | 38,434 | -0.081 |  | -3.989 |
| V alvo 2.0ATR/240min liquido | 32,975 | -0.059 |  | -2.898 |

**M15/hit: famílias distintas validadas: 22; com líquido positivo e significativo na validação (custo realista): 17.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | V alvo 2.0ATR ate 240min | VENDA | 194 | 149 | 3.38 | nao | 3.26 | 1 |  | 58.49 | 58.49 | 10.79 | -8.46 | 12.26 | 84.56 | 3/3 | 4/4 | 48.68 | 68.17 | 2.13 |
| mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | V alvo 1.0ATR ate 240min | VENDA | 194 | 149 | 3.76 | nao | 2.53 | 1 |  | 31.56 | 31.56 | 8.14 | -8.37 | 10.19 | 87.92 | 3/3 | 4/4 | 29.82 | 33.28 | 2.13 |
| price_position_daily_open=Q5 & news_min_since_last_high=Q5 | V alvo 1.0ATR ate 240min | VENDA | 1,111 | 637 | 2.86 | nao | 1.96 | 1 |  | 19.64 | 19.64 | 5.37 | -8.37 | 7.76 | 81.95 | 3/3 | 28/32 | 18.24 | 21.03 | 1.95 |
| mtf_D1=BEARISH & price_position_weekly_open=Q5 | V alvo 2.0ATR ate 240min | VENDA | 1,587 | 360 | 2.11 | nao | 2.01 | 1 |  | 24.88 | 24.88 | 4.00 | -8.46 | 5.40 | 71.39 | 3/3 | 15/21 | 55.48 | -5.71 | 2.34 |
| slot_hhmm=00:30 & mtf_M5=BULLISH | V alvo 0.5ATR ate 15min | VENDA | 155 | 107 | 2.12 | nao | 4.47 | 1 |  | 6.70 | 6.70 | 3.88 | -7.61 | 8.21 | 70.09 | 3/3 | 22/30 | 6.69 | 6.71 | 1.78 |
| slot_hhmm=00:30 & dom_w=d22_31 | V alvo 0.5ATR ate 15min | VENDA | 133 | 87 | 2.76 | nao | 3.84 | 1 |  | 6.77 | 6.77 | 3.62 | -7.61 | 7.62 | 71.26 | 3/3 | 25/33 | 6.15 | 7.38 | 1.75 |
| price_position_daily_open=Q5 & news_min_since_last_high=Q5 | V alvo 1.0ATR ate 60min | VENDA | 1,145 | 661 | 2.51 | nao | 1.99 | 1 |  | 7.28 | 7.28 | 2.93 | -6.75 | 5.72 | 63.09 | 3/3 | 28/32 | 7.67 | 6.90 | 1.87 |
| slot_hhmm=00:30 & structure_before=BULLISH | V alvo 0.5ATR ate 15min | VENDA | 130 | 111 | 2.15 | nao | 2.83 | 2 |  | 4.47 | 4.47 | 2.65 | -7.61 | 7.09 | 65.77 | 3/3 | 13/22 | 5.25 | 3.71 | 1.70 |
| price_position_daily_open=Q5 & news_min_since_last_high=Q5 | V alvo 2.0ATR ate 60min | VENDA | 1,145 | 661 | 2.65 | nao | 1.82 | 1 |  | 7.83 | 7.83 | 2.55 | -6.20 | 4.64 | 54.92 | 3/3 | 26/32 | 5.83 | 9.83 | 1.87 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | V alvo 2.0ATR ate 60min | VENDA | 181 | 74 | 2.42 | nao | 1.69 | 1 |  | 28.71 | 28.71 | 2.46 | -6.20 | 2.98 | 66.22 | 3/3 | 20/25 | 26.54 | 30.88 | 1.83 |
| slot_hhmm=00:30 & volatility_state=LOW | V alvo 0.5ATR ate 15min | VENDA | 153 | 114 | 2.92 | nao | 2.81 | 1 |  | 4.28 | 4.28 | 2.36 | -7.61 | 6.50 | 66.67 | 3/3 | 20/30 | 7.73 | 0.84 | 1.89 |
| slot_hhmm=09:30 & mtf_D1=BEARISH | C alvo 2.0ATR ate 15min | COMPRA | 157 | 68 | 2.24 | nao | 2.02 | 1 |  | 8.60 | 8.60 | 2.22 | -7.02 | 4.00 | 60.29 | 3/3 | 13/18 | 15.25 | 1.96 | 1.82 |
| slot_hhmm=09:30 & mtf_D1=BEARISH | C alvo 1.0ATR ate 15min | COMPRA | 157 | 68 | 2.33 | nao | 1.97 | 1 |  | 8.15 | 8.15 | 2.17 | -7.39 | 4.11 | 60.29 | 3/3 | 13/18 | 13.96 | 2.35 | 1.82 |
| slot_hhmm=00:30 & mtf_H4=BULLISH | V alvo 0.5ATR ate 15min | VENDA | 149 | 107 | 2.34 | nao | 2.31 | 1 |  | 3.98 | 3.98 | 2.12 | -7.61 | 6.12 | 68.22 | 3/3 | 22/30 | 5.01 | 2.97 | 1.79 |
| slot_hhmm=00:30 & session_high_distance_atr=Q5 | V alvo 0.5ATR ate 15min | VENDA | 145 | 99 | 2.02 | nao | 1.83 | 1 |  | 3.72 | 3.72 | 1.78 | -7.61 | 5.39 | 64.65 | 3/3 | 24/31 | 5.80 | 1.69 | 1.86 |
| hour=8 & mtf_H1=BREAK_DOWN | V alvo 2.0ATR ate 15min | VENDA | 124 | 56 | 2.52 | nao | 1.77 | 1 |  | 11.08 | 11.08 | 1.75 | -6.91 | 2.82 | 60.71 | 3/3 | 9/13 | 17.93 | 4.23 | 1.85 |
| hour=8 & mtf_H1=BREAK_DOWN | V alvo 1.0ATR ate 15min | VENDA | 124 | 56 | 2.06 | nao | 1.70 | 1 |  | 9.95 | 9.95 | 1.72 | -7.26 | 2.95 | 60.71 | 3/3 | 10/13 | 17.35 | 2.55 | 1.85 |

### M30 — modo `hit`

- eventos: 33,888 (2024-01-22 a 2026-10-16); descoberta 20,284 (até 2025-09-11), validação 13,556 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 567,384**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 9.0%, top 1000: 4.3%, top 10000: 1.9%
- **placebo** (6 deslocamentos): top 100: 2.2% (máx 5.0%), top 1000: 0.9% (máx 1.7%), top 10000: 0.6% (máx 0.8%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 20,157 | -0.091 |  | -6.516 |
| C alvo 0.5ATR/60min liquido | 19,184 | -0.088 |  | -6.333 |
| C alvo 0.5ATR/240min liquido | 16,447 | -0.110 |  | -7.930 |
| C alvo 1.0ATR/15min liquido | 20,157 | -0.086 |  | -6.211 |
| C alvo 1.0ATR/60min liquido | 19,184 | -0.080 |  | -5.745 |
| C alvo 1.0ATR/240min liquido | 16,447 | -0.112 |  | -8.089 |
| C alvo 2.0ATR/15min liquido | 20,157 | -0.083 |  | -5.949 |
| C alvo 2.0ATR/60min liquido | 19,184 | -0.079 |  | -5.666 |
| C alvo 2.0ATR/240min liquido | 16,447 | -0.117 |  | -8.448 |
| V alvo 0.5ATR/15min liquido | 20,157 | -0.083 |  | -5.981 |
| V alvo 0.5ATR/60min liquido | 19,184 | -0.064 |  | -4.622 |
| V alvo 0.5ATR/240min liquido | 16,447 | -0.071 |  | -5.071 |
| V alvo 1.0ATR/15min liquido | 20,157 | -0.076 |  | -5.455 |
| V alvo 1.0ATR/60min liquido | 19,184 | -0.056 |  | -3.994 |
| V alvo 1.0ATR/240min liquido | 16,447 | -0.051 |  | -3.694 |
| V alvo 2.0ATR/15min liquido | 20,157 | -0.074 |  | -5.326 |
| V alvo 2.0ATR/60min liquido | 19,184 | -0.052 |  | -3.726 |
| V alvo 2.0ATR/240min liquido | 16,447 | -0.057 |  | -4.065 |

**M30/hit: famílias distintas validadas: 24; com líquido positivo e significativo na validação (custo realista): 19.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| price_position_daily_open=Q5 & news_min_since_last_high=Q5 | V alvo 1.0ATR ate 240min | VENDA | 568 | 317 | 3.18 | nao | 2.56 | 1 |  | 27.56 | 27.56 | 4.86 | -8.70 | 6.46 | 78.23 | 3/3 | 28/31 | 22.66 | 32.43 | 1.93 |
| day_of_week=FRIDAY & previous_low_distance_atr=Q5 | V alvo 1.0ATR ate 240min | VENDA | 516 | 413 | 2.61 | nao | 2.02 | 1 |  | 15.63 | 15.63 | 4.54 | -8.70 | 7.02 | 74.09 | 3/3 | 28/32 | 12.44 | 18.81 | 1.91 |
| price_position_weekly_open=Q5 & prev_day_low_distance_atr=Q5 | V alvo 2.0ATR ate 240min | VENDA | 1,446 | 952 | 2.83 | nao | 1.70 | 1 |  | 11.87 | 11.87 | 3.01 | -8.28 | 5.32 | 60.71 | 3/3 | 29/32 | 0.90 | 22.84 | 1.99 |
| month=8 & price_position_weekly_open=Q5 | V alvo 2.0ATR ate 240min | VENDA | 211 | 114 | 2.26 | nao | 1.92 | 1 |  | 21.51 | 21.51 | 2.93 | -8.28 | 4.03 | 64.91 | 3/3 | 3/3 | 24.97 | 18.06 | 2.13 |
| prev_day_low_distance_atr=Q5 & news_min_since_last_high=Q5 | V alvo 1.0ATR ate 60min | VENDA | 527 | 415 | 2.00 | nao | 2.16 | 1 |  | 8.27 | 8.27 | 2.85 | -6.84 | 5.28 | 59.76 | 3/3 | 24/31 | 8.17 | 8.36 | 1.83 |
| mtf_M30=BREAK_UP & prev_day_low_distance_atr=Q5 | V alvo 2.0ATR ate 60min | VENDA | 426 | 345 | 2.30 | nao | 1.75 | 2 |  | 10.24 | 10.24 | 2.63 | -5.83 | 4.17 | 53.62 | 3/3 | 25/32 | 10.78 | 9.70 | 3.37 |
| day_of_week=FRIDAY & previous_low_distance_atr=Q5 | V alvo 2.0ATR ate 60min | VENDA | 589 | 457 | 2.02 | nao | 2.11 | 1 |  | 7.32 | 7.32 | 2.50 | -5.83 | 4.55 | 54.49 | 3/3 | 23/32 | 5.23 | 9.39 | 1.94 |
| mtf_H1=BREAK_UP & prev_day_low_distance_atr=Q5 | V alvo 2.0ATR ate 60min | VENDA | 453 | 378 | 2.05 | nao | 1.91 | 1 |  | 8.97 | 8.97 | 2.45 | -5.83 | 4.10 | 51.32 | 3/3 | 23/32 | 4.39 | 13.55 | 3.99 |
| month=8 & price_position_weekly_open=Q5 | V alvo 1.0ATR ate 240min | VENDA | 211 | 114 | 2.54 | nao | 1.78 | 1 |  | 13.57 | 13.57 | 2.43 | -8.70 | 3.95 | 71.93 | 3/3 | 3/3 | 14.54 | 12.60 | 2.13 |
| structure_before=BREAK_UP & structure_at_close=BREAK_UP | V alvo 1.0ATR ate 60min | VENDA | 350 | 298 | 2.09 | nao | 1.76 | 2 |  | 8.86 | 8.86 | 2.25 | -6.84 | 4.03 | 59.06 | 3/3 | 27/34 | 9.18 | 8.53 | 2.14 |
| price_position_daily_open=Q5 & prev_day_low_distance_atr=Q5 | V alvo 2.0ATR ate 60min | VENDA | 1,100 | 891 | 2.32 | nao | 1.91 | 1 |  | 5.22 | 5.22 | 2.18 | -5.83 | 4.79 | 50.39 | 3/3 | 25/33 | 0.78 | 9.64 | 7.54 |
| mtf_M15=BREAK_UP & ret_bar_atr=Q5 | V alvo 1.0ATR ate 60min | VENDA | 196 | 170 | 2.18 | nao | 1.86 | 1 |  | 9.23 | 9.23 | 2.02 | -6.84 | 3.52 | 60.59 | 3/3 | 27/33 | 3.66 | 14.79 | 1.88 |
| hour=15 & close_position=Q1 | C alvo 1.0ATR ate 15min | COMPRA | 186 | 117 | 2.89 | nao | 2.59 | 1 |  | 7.93 | 7.93 | 1.94 | -7.20 | 3.70 | 63.25 | 3/3 | 23/31 | 2.60 | 13.17 | 1.83 |
| price_position_daily_open=Q5 & news_min_since_last_high=Q5 | V alvo 1.0ATR ate 60min | VENDA | 588 | 331 | 2.99 | nao | 1.80 | 1 |  | 7.71 | 7.71 | 1.94 | -6.84 | 3.71 | 56.80 | 3/3 | 27/31 | 6.12 | 9.29 | 1.87 |
| slot_hhmm=15:00 & mtf_H1=BULLISH | C alvo 1.0ATR ate 15min | COMPRA | 128 | 94 | 2.05 | nao | 2.10 | 1 |  | 9.37 | 9.37 | 1.92 | -7.20 | 3.39 | 59.57 | 3/3 | 18/25 | 6.74 | 12.00 | 1.72 |
| slot_hhmm=15:00 & mtf_H1=BULLISH | C alvo 0.5ATR ate 15min | COMPRA | 128 | 94 | 2.25 | nao | 2.11 | 1 |  | 8.57 | 8.57 | 1.91 | -8.17 | 3.72 | 60.64 | 3/3 | 19/25 | 5.34 | 11.80 | 1.72 |
| hour=14 & news_state=EVENTS_2_AROUND_60M | C alvo 1.0ATR ate 60min | COMPRA | 138 | 102 | 2.70 | nao | 1.84 | 1 |  | 15.33 | 15.33 | 1.91 | -5.62 | 2.61 | 65.69 | 3/3 | 22/28 | 12.01 | 18.65 | 1.75 |
| hour=15 & close_position=Q1 | C alvo 2.0ATR ate 15min | COMPRA | 186 | 117 | 2.81 | nao | 2.48 | 1 |  | 7.44 | 7.44 | 1.84 | -6.86 | 3.54 | 63.25 | 3/3 | 23/31 | 1.63 | 13.15 | 1.83 |
| hour=15 & price_position_monthly_open=Q5 | C alvo 0.5ATR ate 15min | COMPRA | 181 | 92 | 2.05 | nao | 2.05 | 1 |  | 7.76 | 7.76 | 1.68 | -8.17 | 3.44 | 58.70 | 3/3 | 10/12 | 3.43 | 12.09 | 1.76 |

### H1 — modo `hit`

- eventos: 33,052 (2021-06-02 a 2026-10-16); descoberta 19,808 (até 2024-08-26), validação 13,221 (a partir de 2024-08-27)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 568,368**; passaram no BH (q=5%) na descoberta: **62**; confirmadas na validação: **5**
- melhores N da descoberta que repetem na validação: top 100: 10.0%, top 1000: 3.8%, top 10000: 2.7%
- **placebo** (6 deslocamentos): top 100: 1.3% (máx 3.0%), top 1000: 1.5% (máx 2.5%), top 10000: 1.2% (máx 1.9%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 19,542 | -0.045 |  | -5.092 |
| C alvo 0.5ATR/60min liquido | 18,188 | -0.044 |  | -4.945 |
| C alvo 0.5ATR/240min liquido | 15,015 | -0.045 |  | -5.130 |
| C alvo 1.0ATR/15min liquido | 19,542 | -0.041 |  | -4.698 |
| C alvo 1.0ATR/60min liquido | 18,188 | -0.037 |  | -4.247 |
| C alvo 1.0ATR/240min liquido | 15,015 | -0.039 |  | -4.453 |
| C alvo 2.0ATR/15min liquido | 19,542 | -0.040 |  | -4.592 |
| C alvo 2.0ATR/60min liquido | 18,188 | -0.036 |  | -4.065 |
| C alvo 2.0ATR/240min liquido | 15,015 | -0.036 |  | -4.038 |
| V alvo 0.5ATR/15min liquido | 19,542 | -0.027 |  | -3.069 |
| V alvo 0.5ATR/60min liquido | 18,188 | -0.029 |  | -3.252 |
| V alvo 0.5ATR/240min liquido | 15,015 | -0.041 |  | -4.642 |
| V alvo 1.0ATR/15min liquido | 19,542 | -0.023 |  | -2.581 |
| V alvo 1.0ATR/60min liquido | 18,188 | -0.025 |  | -2.821 |
| V alvo 1.0ATR/240min liquido | 15,015 | -0.043 |  | -4.908 |
| V alvo 2.0ATR/15min liquido | 19,542 | -0.024 |  | -2.697 |
| V alvo 2.0ATR/60min liquido | 18,188 | -0.023 |  | -2.607 |
| V alvo 2.0ATR/240min liquido | 15,015 | -0.051 |  | -5.829 |

**H1/hit: famílias distintas validadas: 95; com líquido positivo e significativo na validação (custo realista): 77.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| volatility_state=EXTREME & pat_BULLISH_ENGULFING=Y | V alvo 0.5ATR ate 60min | VENDA | 320 | 180 | 2.09 | nao | 4.58 | 1 |  | 18.44 | 18.44 | 4.53 | -5.53 | 5.89 | 72.22 | 6/6 | 41/54 | 25.29 | 11.60 | 1.86 |
| previous_high_distance_atr=Q5 & news_min_since_last_high=Q5 | V alvo 0.5ATR ate 60min | VENDA | 128 | 411 | 2.22 | nao | 4.31 | 1 |  | 12.13 | 12.13 | 4.20 | -5.53 | 6.17 | 69.59 | 4/4 | 31/37 | 14.70 | 9.57 | 1.84 |
| price_position_weekly_open=Q5 & cum10=Q5 | V alvo 1.0ATR ate 240min | VENDA | 1,004 | 590 | 2.29 | nao | 2.17 | 1 |  | 21.36 | 21.36 | 3.92 | -5.41 | 5.05 | 64.24 | 5/6 | 47/60 | 32.66 | 10.06 | 1.77 |
| previous_high_distance_atr=Q5 & news_min_since_last_high=Q5 | V alvo 1.0ATR ate 60min | VENDA | 128 | 411 | 3.89 | nao | 3.74 | 1 |  | 14.15 | 14.15 | 3.76 | -4.77 | 5.10 | 60.34 | 4/4 | 32/37 | 13.88 | 14.43 | 1.84 |
| mtf_D1=BEARISH & month=1 | C alvo 1.0ATR ate 240min | COMPRA | 612 | 140 | 2.11 | nao | 1.85 | 1 |  | 32.63 | 32.63 | 3.51 | -4.87 | 4.03 | 69.29 | 5/5 | 5/5 | 24.90 | 40.36 | 8.74 |
| day_of_week=THURSDAY & month=1 | C alvo 2.0ATR ate 240min | COMPRA | 218 | 173 | 2.45 | nao | 1.93 | 1 |  | 32.99 | 32.99 | 3.32 | -4.31 | 3.76 | 56.07 | 5/5 | 5/5 | 48.26 | 17.90 | 7.11 |
| mtf_D1=BEARISH & month=1 | C alvo 2.0ATR ate 240min | COMPRA | 612 | 140 | 2.08 | nao | 1.84 | 1 |  | 39.97 | 39.97 | 3.31 | -4.31 | 3.67 | 57.86 | 5/5 | 5/5 | 46.21 | 33.73 | 8.74 |
| price_position_daily_open=Q5 & price_position_weekly_open=Q5 | V alvo 1.0ATR ate 240min | VENDA | 971 | 496 | 2.37 | nao | 2.18 | 1 |  | 21.72 | 21.72 | 3.30 | -5.41 | 4.23 | 66.33 | 5/6 | 41/54 | 23.51 | 19.92 | 1.84 |
| previous_high_distance_atr=Q5 & news_min_since_last_high=Q5 | V alvo 2.0ATR ate 60min | VENDA | 128 | 411 | 3.86 | nao | 3.17 | 1 |  | 13.29 | 13.29 | 3.12 | -4.46 | 4.23 | 56.93 | 4/4 | 33/37 | 13.37 | 13.22 | 1.84 |
| prev_day_low_distance_atr=Q5 & session_high_distance_atr=Q5 | V alvo 1.0ATR ate 60min | VENDA | 883 | 631 | 2.05 | nao | 2.49 | 1 |  | 9.42 | 9.42 | 3.11 | -4.77 | 4.79 | 54.83 | 5/6 | 48/65 | 15.80 | 3.05 | 2.80 |
| volatility_state=EXTREME & pat_DOJI=Y | C alvo 0.5ATR ate 60min | COMPRA | 140 | 66 | 2.71 | nao | 3.17 | 1 |  | 16.46 | 16.46 | 2.91 | -7.15 | 4.13 | 66.67 | 6/6 | 10/14 | 30.12 | 2.79 | 21.07 |
| range_atr=Q1 & price_position_weekly_open=Q5 | V alvo 2.0ATR ate 60min | VENDA | 627 | 287 | 2.20 | nao | 3.00 | 1 |  | 9.99 | 9.99 | 2.82 | -4.46 | 4.07 | 57.14 | 6/6 | 37/53 | 11.91 | 8.08 | 9.63 |
| volatility_state=VERY_LOW & price_position_weekly_open=Q5 | V alvo 2.0ATR ate 60min | VENDA | 596 | 274 | 2.21 | nao | 2.94 | 1 |  | 10.32 | 10.32 | 2.79 | -4.46 | 4.00 | 56.93 | 6/6 | 36/53 | 10.63 | 10.02 | 9.66 |
| structure_at_close=BREAK_UP & streak=4 | V alvo 0.5ATR ate 60min | VENDA | 145 | 105 | 2.08 | nao | 2.40 | 1 |  | 15.25 | 15.25 | 2.72 | -5.53 | 3.69 | 67.62 | 6/6 | 15/22 | 20.08 | 10.51 | 1.81 |
| prev_day_low_distance_atr=Q5 & swing_high_distance_atr=Q5 | V alvo 1.0ATR ate 60min | VENDA | 1,642 | 1,089 | 2.19 | nao | 2.65 | 1 |  | 6.34 | 6.34 | 2.71 | -4.77 | 4.96 | 56.11 | 6/6 | 47/65 | 6.94 | 5.74 | 3.82 |
| hour=6 & previous_low_distance_atr=Q2 | V alvo 0.5ATR ate 15min | VENDA | 139 | 79 | 2.93 | nao | 3.10 | 2 |  | 12.85 | 12.85 | 2.69 | -5.09 | 3.75 | 65.82 | 5/6 | 14/16 | 21.31 | 4.61 | 1.99 |
| streak=4 & prev_day_low_distance_atr=Q5 | V alvo 1.0ATR ate 60min | VENDA | 201 | 123 | 2.34 | nao | 2.17 | 1 |  | 17.30 | 17.30 | 2.69 | -4.77 | 3.43 | 60.98 | 6/6 | 23/36 | 24.22 | 10.50 | 1.79 |
| streak=4 & cum10=Q5 | V alvo 0.5ATR ate 60min | VENDA | 261 | 174 | 2.81 | nao | 2.77 | 1 |  | 11.60 | 11.60 | 2.68 | -5.53 | 3.96 | 63.79 | 6/6 | 32/50 | 12.09 | 11.11 | 1.82 |
| range_atr=Q1 & price_position_weekly_open=Q5 | V alvo 1.0ATR ate 60min | VENDA | 627 | 287 | 2.07 | nao | 2.62 | 1 |  | 8.13 | 8.13 | 2.63 | -4.77 | 4.16 | 58.54 | 6/6 | 36/53 | 12.29 | 4.00 | 9.63 |
| volatility_state=VERY_LOW & price_position_weekly_open=Q5 | V alvo 1.0ATR ate 60min | VENDA | 596 | 274 | 2.08 | nao | 2.56 | 1 |  | 8.37 | 8.37 | 2.60 | -4.77 | 4.07 | 58.39 | 6/6 | 34/53 | 11.78 | 4.97 | 9.66 |
| price_position_weekly_open=Q5 & swing_high_distance_atr=Q5 | V alvo 1.0ATR ate 60min | VENDA | 1,305 | 771 | 2.41 | nao | 2.86 | 1 |  | 7.42 | 7.42 | 2.59 | -4.77 | 4.39 | 55.38 | 5/6 | 43/61 | 12.53 | 2.33 | 4.46 |
| lower_wick_pct=Q4 & price_position_daily_open=Q5 | V alvo 2.0ATR ate 60min | VENDA | 735 | 429 | 2.20 | nao | 2.33 | 1 |  | 10.46 | 10.46 | 2.51 | -4.46 | 3.64 | 55.01 | 6/6 | 42/63 | 15.02 | 5.92 | 6.82 |
| prev_day_low_distance_atr=Q5 & cum10=Q5 | V alvo 1.0ATR ate 60min | VENDA | 1,556 | 993 | 2.12 | nao | 2.33 | 1 |  | 6.27 | 6.27 | 2.50 | -4.77 | 4.59 | 56.19 | 5/6 | 48/65 | 7.30 | 5.24 | 4.71 |
| prev_day_high_distance_atr=Q5 & session_high_distance_atr=Q5 | V alvo 1.0ATR ate 60min | VENDA | 1,028 | 749 | 2.07 | nao | 2.47 | 1 |  | 6.83 | 6.83 | 2.45 | -4.77 | 4.28 | 54.47 | 6/6 | 45/65 | 10.48 | 3.18 | 3.31 |
| hour=10 & price_position_daily_open=Q3 | C alvo 2.0ATR ate 60min | COMPRA | 126 | 102 | 2.75 | nao | 2.21 | 2 |  | 16.67 | 16.67 | 2.45 | -6.31 | 3.36 | 58.82 | 6/6 | 14/18 | 22.01 | 11.33 | 1.98 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **18929**
- com líquido positivo e t>1,645 na validação, custo realista: **347**; dessas, sobreviveram ao BH: **37**; e positivas nas duas metades da validação: **36**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H1 | ret | day_of_week=FRIDAY & ret_bar_atr=Q3 | 5min | VENDA | 475 | 6.39 | -4.82 | 5.45 | 3.03 | 49.05 | 5/6 | 38/65 |
| H1 | ret | hour=22 & mtf_M15=BULLISH | 60min | COMPRA | 90 | 14.99 | -6.02 | 4.13 | 2.97 | 57.78 | 5/5 | 18/22 |
| H1 | ret | day_of_week=FRIDAY & volatility_state=VERY_LOW | 5min | VENDA | 319 | 7.09 | -4.82 | 5.04 | 2.96 | 49.22 | 4/6 | 36/65 |
| H1 | ret | day_of_week=FRIDAY & range_atr=Q1 | 5min | VENDA | 340 | 6.61 | -4.82 | 5.11 | 2.91 | 49.41 | 4/6 | 38/65 |
| M5 | ret | slot_hhmm=12:00 | 5min | COMPRA | 148 | 5.31 | -6.79 | 6.59 | 2.90 | 62.84 | 2/2 | 13/18 |
| H1 | ret | day_of_week=FRIDAY & cost_atr=Q5 | 5min | VENDA | 800 | 5.92 | -4.82 | 5.32 | 2.79 | 50.62 | 4/6 | 34/55 |
| H1 | ret | hour=22 & mtf_M15=BULLISH | 30min | COMPRA | 91 | 12.96 | -7.16 | 4.26 | 2.76 | 52.75 | 4/5 | 15/24 |
| H1 | ret | slot_hhmm=20:00 & previous_high_distance_atr=Q5 | 5min | VENDA | 105 | 20.63 | -4.82 | 3.32 | 2.68 | 50.48 | 5/6 | 16/23 |
| H1 | ret | previous_high_distance_atr=Q5 & news_min_since_last_high=Q5 | 60min | VENDA | 411 | 12.81 | -4.93 | 3.68 | 2.60 | 56.45 | 4/4 | 33/37 |
| M5 | ret | slot_hhmm=12:00 & news_min_to_next_high=Q1 | 5min | COMPRA | 100 | 5.48 | -6.79 | 5.75 | 2.58 | 64.00 | 2/2 | 12/17 |
| H1 | ret | day_of_week=FRIDAY & session=NEW_YORK | 60min | VENDA | 342 | 11.73 | -4.93 | 3.49 | 2.42 | 53.22 | 6/6 | 48/65 |
| H1 | ret | day_of_week=FRIDAY & cost_atr=Q5 | 15min | VENDA | 795 | 5.46 | -5.02 | 4.79 | 2.39 | 51.19 | 5/6 | 35/55 |
| H1 | ret | day_of_week=FRIDAY & price_position_daily_open=Q5 | 5min | VENDA | 402 | 5.39 | -4.82 | 4.56 | 2.36 | 50.50 | 6/6 | 41/61 |
| H1 | ret | day_of_week=FRIDAY & mtf_M15=BULLISH | 5min | VENDA | 813 | 3.64 | -4.82 | 5.37 | 2.21 | 50.18 | 5/6 | 42/65 |
| H1 | ret | prev_day_low_distance_atr=Q5 & session_high_distance_atr=Q5 | 30min | VENDA | 663 | 5.44 | -5.85 | 4.67 | 2.19 | 52.04 | 5/6 | 44/65 |
| H1 | ret | slot_hhmm=22:00 & mtf_M15=BULLISH | 15min | COMPRA | 92 | 7.84 | -6.61 | 3.92 | 2.14 | 48.91 | 5/6 | 15/27 |
| H1 | ret | day_of_week=FRIDAY & volatility_state=VERY_LOW | 15min | VENDA | 317 | 4.73 | -5.02 | 4.33 | 2.09 | 48.26 | 5/6 | 37/65 |
| H1 | ret | day_of_week=FRIDAY & session=NEW_YORK | 5min | VENDA | 459 | 7.15 | -4.82 | 3.60 | 2.08 | 49.67 | 4/6 | 34/65 |
| H1 | ret | day_of_week=FRIDAY & session_high_distance_atr=Q4 | 5min | VENDA | 387 | 5.35 | -4.82 | 4.03 | 2.08 | 49.87 | 6/6 | 45/64 |
| H1 | ret | prev_day_low_distance_atr=Q5 & session_low_distance_atr=Q5 | 30min | VENDA | 723 | 5.05 | -5.85 | 4.61 | 2.07 | 53.11 | 6/6 | 45/65 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 2717s)_
