# XAUUSD — relatório completo MBA (gerado em 2026-10-17 01:38)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | Raw Trading Ltd |
| servidor | ICMarketsSC-Demo |
| simbolo | XAUUSD |
| descricao | Gold vs US Dollar |
| digitos | 2 |
| ponto | 0.01000 |
| tick_size | 0.01000 |
| tick_value | 1.00000 |
| contrato | 100.00000 |
| lote_min | 0.01000 |
| swap_long | -55.48400 |
| swap_short | 38.82200 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-01-22 01:22 | 2026-10-16 23:55 | 157 | 1,143,538 | 0 | 117,687 | 117,687 | 1 |
| M5 | 101,305 | 2025-05-15 03:10 | 2026-10-16 23:50 | 376 | 876 | 0 | 23,572 | 23,572 | 1 |
| M15 | 64,846 | 2024-01-22 06:30 | 2026-10-16 23:30 | 710 | 292 | 0 | 7,859 | 7,859 | 1 |
| M30 | 32,415 | 2024-01-22 12:00 | 2026-10-16 23:00 | 709 | 146 | 0 | 3,930 | 3,930 | 0 |
| H1 | 32,430 | 2021-04-27 01:00 | 2026-10-16 22:00 | 1,416 | 73 | 0 | 1,965 | 1,965 | 0 |
| H4 | 15,432 | 2016-10-24 20:00 | 2026-10-16 16:00 | 543 | 18 | 0 | 512 | 512 | 0 |
| D1 | 2,555 | 2016-11-21 00:00 | 2026-10-15 00:00 | 524 | 3 | 0 | 84 | 84 | 0 |
| W1 | 498 | 2017-03-26 00:00 | 2026-10-04 00:00 | 0 | 0 | 0 | 16 | 16 | 0 |
| MN1 | 97 | 2018-09-01 00:00 | 2026-09-01 00:00 | 0 | 0 | 0 | 3 | 3 | 0 |

Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).

## 3. Custo e microestrutura (base M5)

Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.

| hora_utc | spread_med | spread_p90 | spread_max | range_med_pts | atr_med_pts | ticks_vol_med | n | spread_ticks_med | pct_barras_spread0 | custo_sobre_ATR |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 5.00 | 8.00 | 13.00 | 413.00 | 400.68 | 856.50 | 4,426 | 9.25 | 3.12 | 0.02 |
| 1 | 5.00 | 8.00 | 16.00 | 517.50 | 528.64 | 1,166.50 | 4,428 | 9.07 | 4.54 | 0.02 |
| 2 | 5.00 | 7.00 | 12.00 | 400.00 | 491.39 | 958.00 | 4,428 | 8.98 | 2.80 | 0.02 |
| 3 | 5.00 | 7.00 | 12.00 | 318.00 | 407.07 | 787.50 | 4,428 | 8.82 | 1.94 | 0.02 |
| 4 | 5.00 | 7.00 | 14.00 | 261.00 | 310.64 | 617.00 | 4,428 | 8.94 | 1.20 | 0.03 |
| 5 | 5.00 | 8.00 | 12.00 | 370.00 | 336.00 | 863.00 | 4,415 | 9.27 | 2.60 | 0.03 |
| 6 | 5.00 | 8.00 | 12.00 | 387.00 | 439.00 | 987.00 | 4,415 | 8.27 | 3.28 | 0.02 |
| 7 | 5.00 | 8.00 | 12.00 | 381.00 | 409.89 | 887.00 | 4,426 | 8.28 | 3.16 | 0.02 |
| 8 | 5.00 | 7.00 | 12.00 | 369.00 | 402.86 | 899.00 | 4,423 | 8.11 | 3.69 | 0.02 |
| 9 | 5.00 | 7.00 | 12.00 | 341.00 | 378.89 | 835.00 | 4,424 | 8.05 | 3.71 | 0.02 |
| 10 | 5.00 | 7.00 | 11.00 | 319.00 | 356.11 | 772.00 | 4,428 | 8.10 | 3.59 | 0.02 |
| 11 | 5.00 | 7.00 | 12.00 | 338.50 | 349.79 | 797.50 | 4,428 | 7.97 | 3.43 | 0.02 |
| 12 | 5.00 | 8.00 | 12.00 | 459.00 | 425.61 | 1,044.00 | 4,428 | 8.03 | 5.87 | 0.02 |
| 13 | 5.00 | 8.00 | 14.00 | 603.00 | 569.93 | 1,333.00 | 4,420 | 8.03 | 9.86 | 0.01 |
| 14 | 5.00 | 7.00 | 14.00 | 620.00 | 684.00 | 1,431.00 | 4,421 | 7.72 | 8.98 | 0.01 |
| 15 | 5.00 | 7.00 | 12.00 | 504.00 | 638.25 | 1,390.00 | 4,428 | 7.75 | 7.34 | 0.01 |
| 16 | 5.00 | 7.00 | 12.00 | 393.00 | 502.21 | 1,231.00 | 4,427 | 8.32 | 5.33 | 0.02 |
| 17 | 5.00 | 7.00 | 11.00 | 345.00 | 415.25 | 1,100.00 | 4,392 | 8.07 | 3.55 | 0.02 |
| 18 | 5.00 | 7.00 | 12.00 | 316.00 | 367.21 | 1,021.00 | 4,359 | 8.14 | 3.53 | 0.02 |
| 19 | 5.00 | 8.00 | 13.00 | 312.00 | 344.79 | 966.00 | 4,299 | 8.40 | 2.95 | 0.02 |
| 20 | 5.00 | 40.00 | 60.00 | 239.00 | 303.43 | 591.00 | 4,271 | 8.53 | 2.11 | 0.03 |
| 21 | 6.00 | 40.00 | 123.00 | 280.00 | 401.89 | 384.50 | 996 |  | 2.31 | 0.01 |
| 22 | 5.00 | 8.00 | 50.00 | 265.00 | 276.00 | 539.00 | 3,351 | 9.28 | 1.76 | 0.03 |
| 23 | 5.00 | 7.00 | 50.00 | 305.00 | 308.71 | 570.00 | 4,416 | 9.24 | 2.63 | 0.03 |

Spread geral (mediana M5): **5.0 pts**, p90 8.0, máx 123. ATR mediano M5: **407.4 pts**. Razão spread/ATR: **0.01**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 509 | 3,326.15 | 46.07 | 2,843.38 | 51.28 | 0.37 |
| ter | 515 | 3,315.73 | 62.81 | 3,211.58 | 54.95 | 0.44 |
| qua | 513 | 3,374.47 | 165.09 | 3,006.56 | 53.41 | 1.24 |
| qui | 515 | 3,454.13 | 73.01 | 2,842.62 | 52.82 | 0.58 |
| sex | 503 | 3,518.04 | 129.52 | 3,570.05 | 56.86 | 0.81 |

Autocorrelação do retorno diário (lags 1-5): -0.002, -0.094, +0.005, +0.013, +0.055 (banda ±0.040). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.379, +0.403, +0.381.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 1,415 | 0 | 0.009 | 0.641 | nao |
| 1,415 | 1 | 0.043 | 2.234 | nao |
| 1,415 | 2 | 0.032 | 2.294 | nao |
| 1,415 | 3 | -0.004 | -0.341 | nao |
| 1,415 | 4 | -0.014 | -1.202 | nao |
| 1,415 | 5 | 0.003 | 0.177 | nao |
| 1,414 | 6 | 0.041 | 2.057 | nao |
| 1,415 | 7 | 0.001 | 0.041 | nao |
| 1,415 | 8 | -0.011 | -0.530 | nao |
| 1,414 | 9 | 0.027 | 1.523 | nao |
| 1,414 | 10 | 0.003 | 0.154 | nao |
| 1,414 | 11 | 0.032 | 1.799 | nao |
| 1,414 | 12 | 0.009 | 0.304 | nao |
| 1,414 | 13 | 0.006 | 0.188 | nao |
| 1,415 | 14 | 0.016 | 0.573 | nao |
| 1,415 | 15 | -0.014 | -0.625 | nao |
| 1,415 | 16 | 0.028 | 1.687 | nao |
| 1,409 | 17 | -0.015 | -1.105 | nao |
| 1,409 | 18 | 0.017 | 1.121 | nao |
| 1,386 | 19 | -0.003 | -0.231 | nao |
| 1,369 | 20 | 0.006 | 0.576 | nao |
| 419 | 21 | 0.016 | 1.095 | nao |
| 974 | 22 | 0.033 | 2.305 | nao |
| 1,415 | 23 | 0.047 | 4.198 | sim |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 6,410 | 0 | 0.004 | 0.489 | nao |
| 6,571 | 1 | 0.008 | 0.859 | nao |
| 6,527 | 2 | 0.019 | 2.072 | nao |
| 6,506 | 3 | 0.013 | 1.458 | nao |
| 5,940 | 4 | 0.021 | 2.162 | nao |
| 476 | 6 | 0.009 | 0.313 | nao |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,454 | 1 | 0.033 | 2.371 | nao |
| 2,313 | 2 | 0.016 | 1.136 | nao |
| 2,512 | 3 | 0.031 | 2.269 | nao |
| 2,461 | 4 | 0.006 | 0.471 | nao |
| 3,022 | 5 | 0.005 | 0.371 | nao |
| 2,956 | 6 | -0.029 | -2.227 | nao |
| 3,039 | 7 | 0.012 | 0.963 | nao |
| 3,038 | 8 | 0.016 | 1.281 | nao |
| 2,974 | 9 | -0.003 | -0.258 | nao |
| 2,805 | 10 | 0.026 | 1.990 | nao |
| 2,436 | 11 | 0.029 | 2.061 | nao |
| 2,420 | 12 | 0.017 | 1.218 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 120 combinações testadas):

| dia(0=seg) | hora_utc | n | ret_medio_ATR | std | t |
|---|---|---|---|---|---|
| 4 | 21 | 83 | 0.150 | 0.301 | 4.546 |
| 2 | 22 | 196 | 0.105 | 0.391 | 3.771 |
| 2 | 23 | 284 | 0.078 | 0.403 | 3.266 |

Autocorrelação do retorno H1, lags 1-10: -0.013, -0.002, +0.001, +0.011, -0.001, -0.000, -0.003, +0.004, +0.002, +0.004 (banda ±0.011). |retorno|: +0.170, +0.084, -0.000, -0.106, +0.115 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 279 | 0.005 | 0.068 | 51.613 |
| barra < -2 ATR | 273 | 0.028 | 0.430 | 53.846 |
| barra > +1 ATR | 2,018 | 0.014 | 0.684 | 50.099 |
| barra < -1 ATR | 1,908 | 0.050 | 2.411 | 52.673 |
| gap (barra ausente antes) | 1,416 | 0.016 | 1.418 | 51.766 |

Distribuição do retorno H1 em ATR: média +0.0125, desvio 0.699, assimetria -0.05, curtose 4.5; barras |ret|>2 ATR: 1.70%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 8.4 pts, máxima 40.0 pts no slot NY 16:30; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | 100,835 | 198,897 | 1 | 0 | 0.0 | 0.0 | 0 | 2.0 | 4.3 |
| M15 | ret | 64,772 | 208,245 | 1 | 0 | 1.7 | 0.0 | 0 | 8.0 | 15.3 |
| M30 | ret | 32,361 | 177,376 | 9 | 2 | 1.2 | 0.0 | 0 | 19.0 | 8.8 |
| H1 | ret | 31,777 | 184,266 | 97 | 18 | 0.0 | 0.0 | 0 | 18.0 | 5.0 |
| M5 | hit | 100,835 | 593,040 | 25 | 0 | 21.7 | 2.7 | 6 | 6.0 | 6.0 |
| M15 | hit | 64,772 | 620,034 | 0 | 0 | 0.5 | 0.0 | 0 | 2.0 | 3.0 |
| M30 | hit | 32,361 | 527,718 | 0 | 0 | 0.2 | 0.0 | 0 | 16.0 | 1.3 |
| H1 | hit | 31,777 | 546,858 | 0 | 0 | 0.2 | 0.0 | 0 | 4.0 | 3.8 |


## 6.1 Modo `ret`

### M5 — modo `ret`

- eventos: 100,835 (2025-05-15 a 2026-10-16); descoberta 60,226 (até 2026-03-23), validação 40,334 (a partir de 2026-03-24)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 198,897**; passaram no BH (q=5%) na descoberta: **1**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 2.0%, top 1000: 6.3%, top 10000: 4.4%
- **placebo** (6 deslocamentos): top 100: 4.3% (máx 6.0%), top 1000: 4.5% (máx 6.2%), top 10000: 4.4% (máx 6.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 60,226 | 0.009 | 3.094 | 3.736 |
| 15min bruto | 59,773 | 0.021 | 2.320 | 8.457 |
| 30min bruto | 59,096 | 0.039 | 2.166 | 16.045 |
| 60min bruto | 57,751 | 0.080 | 2.127 | 32.596 |
| 120min bruto | 55,063 | 0.160 | 1.970 | 65.399 |
| 240min bruto | 49,725 | 0.306 | 1.664 | 124.897 |

**M5/ret: famílias distintas validadas: 211; com líquido positivo e significativo na validação (custo realista): 66.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 240min | COMPRA | 223 | 110 | 2.30 | nao | 1.78 | 1 | 2,148.64 | 2,140.64 | 2,140.64 | 10.56 | -53.64 | 10.79 | 89.09 | 2/2 | 12/14 | 2,889.95 | 1,391.32 | 8.00 |
| mtf_D1=BREAK_DOWN & news_min_since_last_high=Q2 | 120min | COMPRA | 190 | 119 | 2.52 | nao | 1.72 | 1 | 2,228.47 | 2,219.33 | 2,219.33 | 8.62 | -28.10 | 8.71 | 77.31 | 2/2 | 5/5 | 3,871.37 | 594.83 | 9.14 |
| month=3 & news_min_to_next_high=Q4 | 120min | COMPRA | 382 | 187 | 2.19 | nao | 1.71 | 1 | 2,431.68 | 2,422.02 | 2,422.02 | 8.50 | -28.10 | 8.61 | 75.40 | 1/1 | 1/1 | 2,182.66 | 2,658.83 | 9.66 |
| hour=0 & month=3 | 60min | COMPRA | 192 | 60 | 2.28 | nao | 2.14 | 1 | 2,430.52 | 2,421.25 | 2,421.25 | 7.81 | -18.87 | 7.82 | 86.67 | 1/1 | 1/1 | 1,169.36 | 3,673.15 | 9.26 |
| slot_hhmm=09:20 | 5min | VENDA | 219 | 147 | -3.18 | nao | -6.86 | 3 | 159.13 | 150.87 | 151.22 | 6.59 | -8.37 | 6.93 | 70.07 | 2/2 | 15/18 | 170.97 | 131.73 | 7.91 |
| slot_hhmm=09:20 & news_state=NONE_60M | 5min | VENDA | 216 | 143 | -3.23 | nao | -6.75 | 1 | 160.72 | 152.46 | 152.81 | 6.51 | -8.37 | 6.84 | 69.93 | 2/2 | 15/18 | 167.66 | 138.16 | 7.91 |
| previous_high_distance_atr=Q1 & news_min_to_next_high=Q1 | 30min | COMPRA | 1,417 | 975 | 2.12 | nao | 2.11 | 1 | 187.94 | 179.83 | 179.83 | 4.64 | -13.93 | 5.08 | 59.28 | 2/2 | 16/18 | 244.87 | 114.91 | 8.11 |
| swing_high_distance_atr=Q1 & news_min_to_next_high=Q1 | 30min | COMPRA | 1,547 | 1,108 | 2.02 | nao | 2.13 | 1 | 180.21 | 172.10 | 172.10 | 4.58 | -13.93 | 5.05 | 56.86 | 2/2 | 14/18 | 222.08 | 122.12 | 8.11 |
| slot_hhmm=09:20 & direction=BEARISH | 5min | VENDA | 120 | 86 | -2.98 | nao | -4.99 | 1 | 132.10 | 123.84 | 124.19 | 4.41 | -8.37 | 4.68 | 66.28 | 2/2 | 15/18 | 162.55 | 85.84 | 7.91 |
| hour=9 & cum3=Q4 | 15min | VENDA | 499 | 382 | -2.08 | nao | -2.66 | 1 | 106.33 | 98.25 | 98.25 | 4.36 | -5.97 | 4.61 | 58.12 | 2/2 | 15/18 | 122.38 | 74.12 | 8.08 |
| hour=6 & mtf_D1=BEARISH | 15min | COMPRA | 312 | 1,032 | 2.14 | nao | 2.51 | 1 | 86.28 | 78.02 | 78.02 | 4.35 | -12.13 | 5.07 | 53.29 | 2/2 | 9/13 | 132.66 | 23.37 | 8.27 |
| hour=11 & price_position_daily_open=Q2 | 15min | COMPRA | 394 | 180 | 2.32 | nao | 1.92 | 1 | 172.82 | 164.83 | 164.83 | 4.00 | -12.13 | 4.29 | 56.11 | 2/2 | 12/17 | 264.35 | 65.31 | 7.99 |
| mtf_M15=BULLISH & cum10=Q5 | 15min | COMPRA | 4,099 | 2,246 | 2.61 | nao | 1.91 | 1 | 61.30 | 52.42 | 52.42 | 3.60 | -12.13 | 4.57 | 50.36 | 2/2 | 14/18 | 85.46 | 19.38 | 8.88 |
| mtf_D1=BREAK_UP & cost_atr=Q4 | 15min | COMPRA | 2,087 | 93 | 2.15 | nao | 2.18 | 1 | 191.98 | 182.85 | 182.85 | 3.54 | -12.13 | 3.75 | 67.74 | 2/2 | 6/8 | 192.63 | 173.28 | 9.13 |
| hour=11 & structure_before=BEARISH | 30min | COMPRA | 974 | 454 | 2.05 | nao | 1.84 | 2 | 146.14 | 138.13 | 138.13 | 3.25 | -13.93 | 3.59 | 57.27 | 2/2 | 14/18 | 176.82 | 99.43 | 8.01 |
| session_high_distance_atr=Q2 & pat_BEARISH_ENGULFING=Y | 5min | VENDA | 1,138 | 847 | -2.00 | nao | -4.53 | 1 | 51.18 | 42.30 | 42.13 | 3.11 | -8.37 | 3.77 | 53.13 | 2/2 | 13/18 | 37.84 | 46.42 | 9.05 |
| previous_high_distance_atr=Q1 & news_min_to_next_high=Q1 | 15min | COMPRA | 1,417 | 977 | 2.14 | nao | 2.26 | 1 | 91.31 | 83.19 | 83.19 | 3.08 | -12.13 | 3.59 | 57.01 | 2/2 | 16/18 | 108.58 | 57.86 | 8.11 |
| mtf_M15=BULLISH & mtf_H1=BREAK_UP | 30min | COMPRA | 3,396 | 1,485 | 2.41 | nao | 2.26 | 1 | 92.08 | 83.55 | 83.55 | 3.08 | -13.93 | 3.67 | 51.38 | 2/2 | 12/18 | 121.91 | 45.23 | 8.54 |
| prev_day_low_distance_atr=Q4 & atr_ratio=Q5 | 15min | COMPRA | 1,821 | 734 | 2.12 | nao | 2.04 | 1 | 98.41 | 90.22 | 90.22 | 2.92 | -12.13 | 3.36 | 53.00 | 2/2 | 11/18 | 19.35 | 161.08 | 8.19 |
| news_state=EVENTS_5_AROUND_60M & prev_day_high_distance_atr=Q4 | 15min | COMPRA | 242 | 64 | 2.06 | nao | 1.71 | 1 | 409.66 | 401.67 | 401.67 | 2.84 | -12.13 | 2.91 | 62.50 | 2/2 | 9/13 | 414.19 | 389.15 | 7.98 |
| hour=11 & session_high_distance_atr=Q1 | 15min | COMPRA | 765 | 435 | 2.25 | nao | 2.07 | 1 | 88.75 | 80.73 | 80.73 | 2.83 | -12.13 | 3.27 | 59.31 | 2/2 | 15/18 | 136.32 | 25.39 | 8.02 |
| swing_high_distance_atr=Q1 & news_min_to_next_high=Q1 | 15min | COMPRA | 1,547 | 1,111 | 2.23 | nao | 1.86 | 1 | 79.83 | 71.72 | 71.72 | 2.67 | -12.13 | 3.18 | 55.18 | 2/2 | 14/18 | 78.73 | 64.72 | 8.11 |
| slot_hhmm=08:50 & direction=BEARISH | 5min | VENDA | 121 | 79 | -2.34 | nao | -2.48 | 1 | 83.23 | 75.34 | 75.00 | 2.60 | -8.37 | 2.87 | 62.03 | 1/2 | 12/18 | 125.83 | 25.44 | 8.23 |
| swing_low_distance_atr=Q2 & pat_MARUBOZU=Y | 5min | VENDA | 323 | 203 | -2.09 | nao | -3.42 | 1 | 79.00 | 69.78 | 69.44 | 2.57 | -8.37 | 2.88 | 55.67 | 1/2 | 12/18 | 53.84 | 84.90 | 9.55 |
| mtf_D1=RANGE & pat_INVERTED_HAMMER=Y | 5min | COMPRA | 631 | 335 | 2.41 | nao | 3.22 | 1 | 54.24 | 44.94 | 44.94 | 2.52 | -9.94 | 3.08 | 54.33 | 2/2 | 7/12 | 69.26 | 20.77 | 9.30 |

### M15 — modo `ret`

- eventos: 64,772 (2024-01-22 a 2026-10-16); descoberta 38,771 (até 2025-09-10), validação 25,909 (a partir de 2025-09-11)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 208,245**; passaram no BH (q=5%) na descoberta: **1**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 8.0%, top 1000: 9.8%, top 10000: 8.4%
- **placebo** (6 deslocamentos): top 100: 15.3% (máx 25.0%), top 1000: 13.7% (máx 18.6%), top 10000: 11.1% (máx 13.7%); BH: média 1.7 (máx 9); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 38,771 | 0.007 | 3.085 | 3.615 |
| 15min bruto | 38,359 | 0.017 | 4.270 | 7.989 |
| 30min bruto | 37,927 | 0.032 | 3.989 | 15.227 |
| 60min bruto | 37,070 | 0.063 | 3.818 | 30.312 |
| 120min bruto | 35,371 | 0.129 | 3.667 | 62.162 |
| 240min bruto | 31,987 | 0.265 | 3.422 | 127.977 |

**M15/ret: famílias distintas validadas: 882; com líquido positivo e significativo na validação (custo realista): 331.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=TUESDAY & month=1 | 240min | COMPRA | 456 | 304 | 2.19 | nao | 2.34 | 1 | 1,223.16 | 1,214.39 | 1,214.39 | 9.46 | -55.87 | 9.88 | 72.70 | 3/3 | 3/3 | 433.41 | 1,995.37 | 8.78 |
| month=3 & news_min_to_next_high=Q4 | 240min | COMPRA | 436 | 212 | 2.04 | nao | 2.11 | 1 | 1,915.72 | 1,905.06 | 1,905.06 | 9.06 | -55.87 | 9.34 | 71.70 | 3/3 | 3/3 | 1,675.82 | 2,134.29 | 10.66 |
| day_of_week=TUESDAY & month=1 | 120min | COMPRA | 504 | 336 | 2.52 | nao | 2.43 | 1 | 688.20 | 679.48 | 679.48 | 6.91 | -19.42 | 7.12 | 63.69 | 3/3 | 3/3 | 238.45 | 1,120.51 | 8.71 |
| day_of_week=TUESDAY & month=1 | 60min | COMPRA | 528 | 352 | 2.60 | nao | 2.86 | 1 | 352.27 | 343.57 | 343.57 | 5.34 | -9.47 | 5.48 | 61.08 | 3/3 | 3/3 | 134.93 | 552.21 | 8.70 |
| previous_low_distance_atr=Q2 & atr_ratio=Q4 | 60min | COMPRA | 1,556 | 957 | 2.18 | nao | 2.51 | 1 | 248.04 | 239.50 | 239.50 | 5.32 | -9.47 | 5.59 | 56.64 | 3/3 | 27/34 | 417.11 | 62.25 | 8.54 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 240min | COMPRA | 5,315 | 2,586 | 2.30 | nao | 2.07 | 1 | 269.09 | 260.13 | 260.13 | 5.07 | -55.87 | 6.36 | 56.42 | 3/3 | 17/28 | 348.23 | 172.04 | 8.95 |
| news_state=NONE_60M & atr_ratio=Q4 | 60min | COMPRA | 5,521 | 3,622 | 2.04 | nao | 2.49 | 1 | 117.51 | 108.79 | 108.79 | 5.07 | -9.47 | 5.65 | 53.73 | 3/3 | 24/34 | 216.96 | 0.63 | 8.71 |
| mtf_D1=BULLISH & prev_day_high_distance_atr=Q5 | 240min | COMPRA | 2,355 | 1,381 | 2.10 | nao | 2.02 | 1 | 359.09 | 350.12 | 350.12 | 5.01 | -55.87 | 5.91 | 61.40 | 3/3 | 15/25 | 379.77 | 320.52 | 8.97 |
| day_of_week=MONDAY & mtf_H1=BULLISH | 120min | COMPRA | 2,666 | 1,767 | 2.14 | nao | 2.52 | 1 | 205.57 | 196.78 | 196.78 | 4.81 | -19.42 | 5.32 | 57.61 | 2/3 | 23/33 | 367.65 | 26.11 | 8.79 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 120min | COMPRA | 5,910 | 2,921 | 2.15 | nao | 2.41 | 1 | 163.31 | 154.44 | 154.44 | 4.66 | -19.42 | 5.35 | 55.08 | 3/3 | 17/28 | 187.08 | 121.82 | 8.86 |
| dom_w=d01_07 & atr_ratio=Q4 | 60min | COMPRA | 1,785 | 1,116 | 2.15 | nao | 1.70 | 1 | 209.95 | 201.40 | 201.40 | 4.50 | -9.47 | 4.79 | 53.94 | 3/3 | 24/33 | 319.54 | 83.26 | 8.55 |
| atr_ratio=Q4 | 60min | COMPRA | 7,551 | 5,155 | 2.09 | nao | 2.18 | 1 | 93.00 | 84.47 | 84.47 | 4.48 | -9.47 | 5.26 | 52.53 | 3/3 | 22/34 | 164.15 | 4.82 | 8.53 |
| day_of_week=MONDAY & mtf_W1=BREAK_UP | 240min | COMPRA | 1,444 | 675 | 2.11 | nao | 2.17 | 1 | 477.59 | 468.72 | 468.72 | 4.45 | -55.87 | 5.03 | 70.22 | 3/3 | 9/12 | 1,050.07 | -110.91 | 8.86 |
| mtf_H1=BULLISH & news_state=NONE_60M | 240min | COMPRA | 10,930 | 6,167 | 2.08 | nao | 1.92 | 1 | 168.56 | 159.60 | 159.60 | 4.37 | -55.87 | 6.69 | 53.19 | 3/3 | 22/34 | 402.63 | -83.36 | 8.97 |
| volume_ratio=Q1 & news_min_to_next_high=Q4 | 60min | COMPRA | 1,760 | 863 | 2.13 | nao | 2.20 | 1 | 171.37 | 158.18 | 158.18 | 4.36 | -9.47 | 4.58 | 55.27 | 3/3 | 23/34 | 238.73 | 77.80 | 13.19 |
| mtf_H1=BULLISH & news_state=NONE_60M | 120min | COMPRA | 11,590 | 6,591 | 2.20 | nao | 2.32 | 1 | 110.57 | 101.65 | 101.65 | 4.28 | -19.42 | 5.55 | 52.72 | 3/3 | 22/34 | 257.06 | -53.70 | 8.92 |
| news_state=NONE_60M & atr_ratio=Q4 | 30min | COMPRA | 5,577 | 3,669 | 2.63 | nao | 2.77 | 1 | 73.22 | 64.52 | 64.52 | 4.19 | -7.59 | 4.82 | 52.60 | 3/3 | 26/34 | 126.01 | 3.07 | 8.70 |
| mtf_D1=BULLISH & prev_day_high_distance_atr=Q5 | 120min | COMPRA | 2,745 | 1,618 | 2.65 | nao | 2.40 | 1 | 191.14 | 182.29 | 182.29 | 4.15 | -19.42 | 4.63 | 57.17 | 3/3 | 15/25 | 174.10 | 190.48 | 8.85 |
| direction=BEARISH & atr_ratio=Q4 | 30min | COMPRA | 3,709 | 2,516 | 2.05 | nao | 2.72 | 1 | 89.63 | 81.10 | 81.10 | 4.13 | -7.59 | 4.65 | 53.90 | 3/3 | 27/34 | 124.16 | 38.04 | 8.53 |
| day_of_week=MONDAY & mtf_W1=BREAK_UP | 120min | COMPRA | 1,596 | 747 | 2.39 | nao | 2.70 | 1 | 274.39 | 265.59 | 265.59 | 4.13 | -19.42 | 4.45 | 63.86 | 2/3 | 8/12 | 542.31 | -10.38 | 8.79 |
| day_of_week=FRIDAY & price_position_daily_open=Q4 | 120min | COMPRA | 1,236 | 502 | 2.55 | nao | 1.89 | 1 | 345.20 | 336.35 | 336.35 | 3.86 | -19.42 | 4.11 | 57.57 | 3/3 | 24/33 | 302.22 | 370.47 | 8.86 |
| mtf_D1=BULLISH & atr_ratio=Q4 | 60min | COMPRA | 3,306 | 1,699 | 2.16 | nao | 2.07 | 1 | 130.70 | 122.17 | 122.17 | 3.86 | -9.47 | 4.21 | 54.44 | 3/3 | 20/28 | 118.71 | 125.62 | 8.53 |
| mtf_H1=BULLISH | 240min | COMPRA | 12,959 | 7,402 | 2.34 | nao | 1.74 | 1 | 139.45 | 130.56 | 130.56 | 3.83 | -55.87 | 6.46 | 52.53 | 3/3 | 21/34 | 333.19 | -72.07 | 8.89 |
| hour=8 & close_position=Q1 | 5min | COMPRA | 364 | 255 | 2.38 | nao | 4.33 | 1 | 107.29 | 99.13 | 99.13 | 3.81 | -1.71 | 3.88 | 56.86 | 3/3 | 25/34 | 132.92 | 65.61 | 8.16 |
| dom_w=d01_07 & atr_ratio=Q4 | 30min | COMPRA | 1,807 | 1,127 | 2.63 | nao | 2.07 | 1 | 130.48 | 121.94 | 121.94 | 3.78 | -7.59 | 4.09 | 53.77 | 3/3 | 21/33 | 168.22 | 75.75 | 8.54 |

### M30 — modo `ret`

- eventos: 32,361 (2024-01-22 a 2026-10-16); descoberta 19,370 (até 2025-09-10), validação 12,945 (a partir de 2025-09-11)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 177,376**; passaram no BH (q=5%) na descoberta: **9**; confirmadas na validação: **2**
- melhores N da descoberta que repetem na validação: top 100: 19.0%, top 1000: 15.7%, top 10000: 11.2%
- **placebo** (6 deslocamentos): top 100: 8.8% (máx 16.0%), top 1000: 9.5% (máx 15.8%), top 10000: 9.3% (máx 12.8%); BH: média 1.2 (máx 4); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 19,370 | 0.004 | 1.371 | 2.535 |
| 15min bruto | 19,368 | 0.014 | 3.389 | 9.713 |
| 30min bruto | 18,951 | 0.022 | 3.970 | 15.284 |
| 60min bruto | 18,521 | 0.043 | 3.740 | 29.793 |
| 120min bruto | 17,671 | 0.088 | 3.617 | 60.778 |
| 240min bruto | 15,979 | 0.180 | 3.316 | 124.351 |

**M30/ret: famílias distintas validadas: 1158; com líquido positivo e significativo na validação (custo realista): 515.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=TUESDAY & month=1 | 240min | COMPRA | 228 | 152 | 2.17 | nao | 2.39 | 1 | 1,247.85 | 1,238.80 | 1,238.80 | 6.75 | -51.21 | 7.01 | 73.68 | 3/3 | 3/3 | 438.84 | 2,038.76 | 9.05 |
| month=3 & news_min_to_next_high=Q4 | 240min | COMPRA | 239 | 116 | 2.09 | nao | 2.00 | 1 | 1,743.59 | 1,732.63 | 1,732.63 | 6.08 | -51.21 | 6.27 | 65.52 | 3/3 | 3/3 | 1,537.17 | 1,928.09 | 10.96 |
| mtf_H1=BULLISH & atr_ratio=Q2 | 240min | COMPRA | 1,470 | 941 | 2.16 | nao | 2.18 | 1 | 427.03 | 418.00 | 418.00 | 5.47 | -51.21 | 6.18 | 55.47 | 3/3 | 24/34 | 646.70 | 189.79 | 9.02 |
| day_of_week=TUESDAY & month=1 | 120min | COMPRA | 252 | 168 | 2.38 | nao | 2.56 | 1 | 700.73 | 691.77 | 691.77 | 4.95 | -16.24 | 5.06 | 66.07 | 3/3 | 3/3 | 262.02 | 1,121.51 | 8.96 |
| structure_at_close=RANGE & price_position_daily_open=Q3 | 120min | COMPRA | 1,120 | 259 | 2.05 | nao | 2.04 | 1 | 443.61 | 434.93 | 434.93 | 4.25 | -16.24 | 4.41 | 55.60 | 3/3 | 28/34 | 477.98 | 392.21 | 8.69 |
| mtf_H1=BULLISH & atr_ratio=Q2 | 120min | COMPRA | 1,502 | 1,018 | 2.44 | nao | 2.28 | 1 | 236.46 | 227.50 | 227.50 | 4.03 | -16.24 | 4.38 | 55.40 | 3/3 | 26/34 | 322.94 | 132.07 | 8.95 |
| price_position_daily_open=Q3 | 120min | COMPRA | 3,722 | 794 | 2.42 | nao | 1.70 | 1 | 252.02 | 243.14 | 243.14 | 3.91 | -16.24 | 4.20 | 54.03 | 3/3 | 27/34 | 377.33 | 108.95 | 8.88 |
| day_of_week=FRIDAY & atr_ratio=Q3 | 15min | COMPRA | 653 | 497 | 2.55 | nao | 4.16 | 1 | 146.71 | 137.29 | 137.29 | 3.91 | 5.78 | 3.79 | 54.93 | 3/3 | 22/33 | 202.65 | 72.19 | 9.42 |
| structure_at_close=RANGE & mtf_M15=BULLISH | 15min | COMPRA | 1,211 | 787 | 2.36 | nao | 3.69 | 1 | 108.64 | 99.27 | 99.27 | 3.70 | 5.78 | 3.54 | 54.76 | 2/3 | 23/34 | 121.56 | 77.04 | 9.37 |
| mtf_H4=BREAK_UP & prev_day_high_distance_atr=Q5 | 120min | COMPRA | 1,300 | 773 | 2.07 | nao | 1.80 | 1 | 234.42 | 225.41 | 225.41 | 3.70 | -16.24 | 3.98 | 54.59 | 3/3 | 21/33 | 92.53 | 357.94 | 9.01 |
| prev_day_high_distance_atr=Q5 & cum3=Q1 | 60min | COMPRA | 339 | 232 | 2.54 | nao | 2.53 | 1 | 331.52 | 322.84 | 322.84 | 3.66 | -5.42 | 3.73 | 61.21 | 3/3 | 25/31 | 493.39 | 152.29 | 8.68 |
| volatility_state=NORMAL & lower_wick_pct=Q2 | 15min | COMPRA | 1,168 | 834 | 2.82 | nao | 2.67 | 1 | 103.14 | 94.19 | 94.19 | 3.61 | 5.78 | 3.44 | 53.60 | 3/3 | 26/34 | 147.90 | 40.48 | 8.95 |
| day_of_week=TUESDAY & month=1 | 60min | COMPRA | 264 | 176 | 2.43 | nao | 2.77 | 1 | 356.14 | 347.21 | 347.21 | 3.58 | -5.42 | 3.64 | 59.66 | 3/3 | 3/3 | 143.78 | 550.64 | 8.93 |
| swing_high_distance_atr=Q5 & range_atr_prev=Q3 | 15min | COMPRA | 751 | 499 | 2.49 | nao | 3.28 | 1 | 147.00 | 138.01 | 138.01 | 3.55 | 5.78 | 3.46 | 53.51 | 3/3 | 22/34 | 117.37 | 158.57 | 8.98 |
| mtf_D1=BULLISH & prev_day_high_distance_atr=Q5 | 240min | COMPRA | 1,178 | 690 | 2.17 | nao | 1.85 | 1 | 362.05 | 352.93 | 352.93 | 3.54 | -51.21 | 4.12 | 61.01 | 3/3 | 15/25 | 378.42 | 327.45 | 9.12 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 240min | COMPRA | 2,666 | 1,300 | 2.32 | nao | 2.03 | 1 | 256.93 | 247.84 | 247.84 | 3.43 | -51.21 | 4.27 | 56.00 | 3/3 | 17/28 | 340.49 | 155.19 | 9.10 |
| news_min_since_last_high=Q2 & range_atr_prev=Q1 | 30min | COMPRA | 1,139 | 529 | 3.87 | nao | 3.38 | 1 | 159.66 | 148.69 | 148.69 | 3.42 | -4.70 | 3.57 | 53.31 | 3/3 | 25/34 | 253.87 | 43.91 | 10.97 |
| day_of_week=MONDAY & mtf_W1=BREAK_UP | 240min | COMPRA | 722 | 338 | 2.20 | nao | 2.42 | 1 | 512.33 | 503.34 | 503.34 | 3.37 | -51.21 | 3.74 | 69.53 | 3/3 | 9/12 | 1,052.45 | -45.77 | 8.99 |
| close_position=Q4 & previous_low_distance_atr=Q4 | 15min | COMPRA | 835 | 561 | 2.50 | nao | 3.21 | 1 | 114.40 | 104.85 | 104.85 | 3.36 | 5.78 | 3.21 | 52.41 | 2/3 | 22/34 | 40.34 | 169.13 | 9.55 |
| structure_at_close=BULLISH & range_atr_prev=Q3 | 15min | COMPRA | 1,482 | 977 | 2.09 | nao | 3.46 | 1 | 80.14 | 71.14 | 71.14 | 3.32 | 5.78 | 3.06 | 54.96 | 2/3 | 22/34 | 59.92 | 82.35 | 9.00 |
| prev_day_high_distance_atr=Q5 & cum3=Q1 | 15min | COMPRA | 348 | 246 | 3.07 | nao | 3.50 | 1 | 187.77 | 178.24 | 178.24 | 3.29 | 5.78 | 3.20 | 62.60 | 3/3 | 23/31 | 218.63 | 137.84 | 9.53 |
| slot_hhmm=20:30 & news_min_since_last_high=Q2 | 5min | COMPRA | 206 | 112 | 3.09 | nao | 2.76 | 1 | 222.28 | 201.39 | 201.39 | 3.27 | 1.35 | 3.25 | 61.61 | 3/3 | 17/31 | 108.22 | 294.56 | 20.89 |
| range_atr=Q5 & cost_atr=Q3 | 30min | COMPRA | 846 | 40 | 2.25 | nao | 3.23 | 1 | 249.45 | 239.54 | 239.54 | 3.26 | -4.70 | 3.26 | 67.50 | 2/2 | 12/22 | 205.16 | 273.91 | 9.91 |
| mtf_D1=BREAK_UP & range_atr_prev=Q5 | 30min | COMPRA | 545 | 325 | 2.30 | nao | 2.66 | 1 | 265.49 | 257.07 | 257.07 | 3.25 | -4.70 | 3.36 | 57.54 | 2/3 | 15/20 | 81.13 | 431.93 | 8.42 |
| swing_low_distance_atr=Q4 & atr_ratio=Q3 | 15min | COMPRA | 794 | 551 | 2.33 | nao | 3.56 | 1 | 104.76 | 95.31 | 95.31 | 3.22 | 5.78 | 3.04 | 54.99 | 3/3 | 22/34 | 170.44 | 20.44 | 9.45 |

### H1 — modo `ret`

- eventos: 31,777 (2021-04-27 a 2026-10-16); descoberta 19,043 (até 2024-08-20), validação 12,711 (a partir de 2024-08-21)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 184,266**; passaram no BH (q=5%) na descoberta: **97**; confirmadas na validação: **18**
- melhores N da descoberta que repetem na validação: top 100: 18.0%, top 1000: 10.6%, top 10000: 9.6%
- **placebo** (6 deslocamentos): top 100: 5.0% (máx 10.0%), top 1000: 4.8% (máx 7.8%), top 10000: 5.1% (máx 7.8%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 19,043 | -0.001 | -0.570 | -0.623 |
| 15min bruto | 19,023 | -0.002 | -0.520 | -0.872 |
| 30min bruto | 18,998 | -0.001 | -0.324 | -0.727 |
| 60min bruto | 18,118 | 0.009 | 1.387 | 4.910 |
| 120min bruto | 17,208 | 0.018 | 1.302 | 9.888 |
| 240min bruto | 15,402 | 0.032 | 1.059 | 18.129 |

**H1/ret: famílias distintas validadas: 721; com líquido positivo e significativo na validação (custo realista): 261.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=WEDNESDAY & cost_atr=Q5 | 60min | COMPRA | 870 | 55 | 2.03 | nao | 3.44 | 1 | 147.60 | 121.10 | 121.10 | 4.20 | 4.95 | 3.73 | 69.09 | 5/5 | 26/37 | 77.09 | 163.53 | 26.50 |
| news_state=NONE_60M & cost_atr=Q3 | 240min | COMPRA | 606 | 370 | 2.54 | nao | 2.19 | 1 | 231.78 | 220.61 | 220.61 | 3.68 | 4.74 | 3.44 | 57.84 | 4/4 | 17/22 | 68.74 | 372.49 | 11.17 |
| price_position_weekly_open=Q2 & price_position_monthly_open=Q3 | 240min | COMPRA | 428 | 144 | 2.51 | nao | 2.15 | 1 | 303.72 | 294.33 | 294.33 | 3.60 | 4.74 | 3.43 | 61.81 | 4/5 | 15/19 | 182.33 | 406.32 | 9.40 |
| news_state=NONE_60M & news_min_since_last_high=Q2 | 120min | COMPRA | 273 | 595 | 2.10 | nao | 2.56 | 1 | 230.55 | 215.11 | 215.11 | 3.59 | 7.36 | 3.52 | 54.79 | 4/4 | 25/37 | 133.64 | 296.31 | 15.43 |
| swing_high_distance_atr=Q1 & cost_atr=Q5 | 60min | COMPRA | 635 | 40 | 2.18 | nao | 4.70 | 1 | 170.03 | 142.47 | 142.47 | 3.58 | 4.95 | 3.29 | 72.50 | 4/5 | 23/35 | 99.64 | 185.31 | 27.55 |
| price_position_daily_open=Q3 | 60min | COMPRA | 3,706 | 783 | 2.46 | nao | 3.64 | 1 | 109.53 | 100.14 | 100.14 | 3.57 | 4.95 | 3.32 | 53.51 | 5/6 | 38/65 | 13.11 | 186.95 | 9.39 |
| news_min_since_last_high=Q2 | 120min | COMPRA | 394 | 904 | 2.70 | nao | 3.06 | 1 | 198.21 | 183.47 | 183.47 | 3.56 | 7.36 | 3.51 | 54.31 | 4/4 | 29/37 | 99.60 | 267.34 | 14.74 |
| price_position_daily_open=Q3 & cost_atr=Q2 | 60min | COMPRA | 616 | 141 | 2.60 | nao | 3.79 | 1 | 105.45 | 96.20 | 96.20 | 3.55 | 4.95 | 3.12 | 56.74 | 5/5 | 30/44 | 95.74 | 96.65 | 9.25 |
| dom_w=d08_14 & cost_atr=Q4 | 240min | COMPRA | 792 | 46 | 2.07 | nao | 1.80 | 1 | 670.72 | 656.14 | 656.14 | 3.51 | 4.74 | 3.43 | 73.91 | 5/5 | 23/38 | 521.75 | 790.53 | 14.58 |
| mtf_M30=BEARISH & streak=3 | 5min | COMPRA | 307 | 217 | 2.30 | nao | 3.07 | 1 | 108.88 | 99.64 | 99.64 | 3.49 | -0.53 | 3.53 | 58.99 | 4/6 | 37/60 | 5.38 | 193.03 | 9.25 |
| streak=-3 & lower_wick_pct=Q1 | 15min | COMPRA | 191 | 126 | 2.35 | nao | 2.86 | 1 | 213.78 | 203.81 | 203.81 | 3.49 | 12.74 | 3.27 | 60.32 | 5/6 | 19/35 | 50.29 | 357.32 | 9.97 |
| day_of_week=WEDNESDAY & cost_atr=Q5 | 5min | COMPRA | 876 | 55 | 2.92 | nao | 3.64 | 1 | 91.27 | 64.77 | 64.77 | 3.49 | -0.53 | 3.42 | 60.00 | 3/5 | 21/37 | 5.87 | 121.57 | 26.50 |
| mtf_M30=BEARISH & news_min_since_last_high=Q2 | 120min | COMPRA | 134 | 325 | 2.17 | nao | 2.79 | 1 | 363.67 | 349.51 | 349.51 | 3.47 | 7.36 | 3.44 | 59.38 | 4/4 | 29/36 | 102.04 | 595.46 | 14.17 |
| prev_day_low_distance_atr=Q4 & p2=Q4 | 60min | COMPRA | 784 | 529 | 2.51 | nao | 2.99 | 1 | 149.08 | 139.32 | 139.32 | 3.35 | 4.95 | 3.25 | 53.69 | 6/6 | 42/66 | 81.37 | 197.04 | 9.76 |
| price_position_daily_open=Q3 & session_high_distance_atr=Q1 | 60min | COMPRA | 280 | 65 | 2.08 | nao | 3.56 | 1 | 314.09 | 305.30 | 305.30 | 3.34 | 4.95 | 3.25 | 64.62 | 5/5 | 20/33 | 183.13 | 423.77 | 8.79 |
| price_position_weekly_open=Q5 & news_min_since_last_high=Q2 | 60min | COMPRA | 193 | 536 | 2.51 | nao | 3.50 | 1 | 187.04 | 173.67 | 173.67 | 3.28 | 4.95 | 3.25 | 54.66 | 4/4 | 26/34 | 52.91 | 294.42 | 13.37 |
| volume_ratio=Q1 & news_min_since_last_high=Q2 | 5min | COMPRA | 232 | 419 | 3.19 | nao | 4.53 | 1 | 117.00 | 96.97 | 96.97 | 3.28 | -0.53 | 3.38 | 55.61 | 3/4 | 26/37 | 20.57 | 173.00 | 20.04 |
| direction=BEARISH & news_min_since_last_high=Q2 | 120min | COMPRA | 156 | 439 | 2.59 | nao | 2.75 | 1 | 212.90 | 197.35 | 197.35 | 3.23 | 7.36 | 3.11 | 55.58 | 4/4 | 31/37 | 128.06 | 266.33 | 15.55 |
| volume_ratio=Q1 & news_min_since_last_high=Q2 | 30min | COMPRA | 229 | 419 | 3.31 | nao | 3.91 | 1 | 143.86 | 123.82 | 123.82 | 3.22 | 3.90 | 3.14 | 54.42 | 4/4 | 25/37 | 27.81 | 219.38 | 20.04 |
| streak=-3 & lower_wick_pct=Q1 | 30min | COMPRA | 191 | 126 | 2.09 | nao | 2.72 | 1 | 242.63 | 232.66 | 232.66 | 3.20 | 3.90 | 3.15 | 61.90 | 5/6 | 23/35 | 65.85 | 399.46 | 9.97 |
| dom_w=d08_14 & cost_atr=Q4 | 120min | COMPRA | 846 | 46 | 2.34 | nao | 1.87 | 1 | 299.07 | 284.49 | 284.49 | 3.07 | 7.36 | 2.92 | 67.39 | 5/5 | 25/38 | 237.18 | 331.79 | 14.58 |
| session=LONDON & price_position_daily_open=Q3 | 60min | COMPRA | 591 | 123 | 2.08 | nao | 3.45 | 1 | 264.33 | 256.19 | 256.19 | 3.04 | 4.95 | 2.97 | 60.98 | 6/6 | 34/49 | 98.20 | 411.63 | 8.14 |
| direction=BEARISH & prev_day_low_distance_atr=Q4 | 120min | COMPRA | 1,540 | 1,076 | 2.20 | nao | 2.03 | 1 | 132.39 | 122.57 | 122.57 | 3.02 | 7.36 | 2.87 | 53.44 | 5/6 | 41/67 | 43.33 | 201.80 | 9.83 |
| day_of_week=FRIDAY & cum10=Q2 | 15min | COMPRA | 637 | 401 | 2.39 | nao | 3.19 | 1 | 114.32 | 104.62 | 104.62 | 3.02 | 12.74 | 2.68 | 54.86 | 6/6 | 43/66 | 27.63 | 181.22 | 9.71 |
| session=NEW_YORK & streak=-1 | 5min | COMPRA | 756 | 616 | 2.23 | nao | 4.53 | 1 | 70.12 | 56.17 | 56.17 | 3.00 | -0.53 | 3.10 | 52.60 | 4/6 | 38/66 | 41.27 | 71.08 | 13.95 |

## 6.2 Modo `hit`

### M5 — modo `hit`

- eventos: 100,835 (2025-05-15 a 2026-10-16); descoberta 60,226 (até 2026-03-23), validação 40,334 (a partir de 2026-03-24)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 593,040**; passaram no BH (q=5%) na descoberta: **25**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 6.0%, top 1000: 2.2%, top 10000: 2.0%
- **placebo** (6 deslocamentos): top 100: 6.0% (máx 10.0%), top 1000: 2.2% (máx 2.8%), top 10000: 1.4% (máx 1.8%); BH: média 21.7 (máx 44); confirmadas: média 2.7 (máx 6)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 59,760 | -0.039 |  | -16.103 |
| C alvo 0.5ATR/60min liquido | 57,738 | -0.032 |  | -13.173 |
| C alvo 0.5ATR/240min liquido | 49,712 | -0.020 |  | -8.125 |
| C alvo 1.0ATR/15min liquido | 59,760 | -0.032 |  | -12.871 |
| C alvo 1.0ATR/60min liquido | 57,738 | -0.027 |  | -11.118 |
| C alvo 1.0ATR/240min liquido | 49,712 | -0.008 |  | -3.377 |
| C alvo 2.0ATR/15min liquido | 59,760 | -0.019 |  | -7.553 |
| C alvo 2.0ATR/60min liquido | 57,738 | -0.001 |  | -0.398 |
| C alvo 2.0ATR/240min liquido | 49,712 | 0.007 |  | 2.959 |
| V alvo 0.5ATR/15min liquido | 59,760 | -0.053 |  | -21.660 |
| V alvo 0.5ATR/60min liquido | 57,738 | -0.073 |  | -29.961 |
| V alvo 0.5ATR/240min liquido | 49,712 | -0.109 |  | -44.552 |
| V alvo 1.0ATR/15min liquido | 59,760 | -0.053 |  | -21.739 |
| V alvo 1.0ATR/60min liquido | 57,738 | -0.087 |  | -35.571 |
| V alvo 1.0ATR/240min liquido | 49,712 | -0.164 |  | -66.898 |
| V alvo 2.0ATR/15min liquido | 59,760 | -0.048 |  | -19.571 |
| V alvo 2.0ATR/60min liquido | 57,738 | -0.081 |  | -32.998 |
| V alvo 2.0ATR/240min liquido | 49,712 | -0.222 |  | -90.633 |

**M5/hit: famílias distintas validadas: 21; com líquido positivo e significativo na validação (custo realista): 21.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hour=4 & mtf_M30=BREAK_UP | C alvo 0.5ATR ate 240min | COMPRA | 222 | 84 | 2.56 | nao | 124.94 | 1 |  | 171.39 | 171.39 | 45.68 | -27.20 | 28.96 | 100.00 | 2/2 | 15/15 | 179.63 | 163.15 | 8.99 |
| hour=0 & month=3 | C alvo 0.5ATR ate 240min | COMPRA | 192 | 60 | 2.26 | nao | 239.63 | 1 |  | 531.81 | 531.81 | 33.06 | -27.20 | 32.55 | 100.00 | 1/1 | 1/1 | 523.59 | 540.04 | 9.26 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | C alvo 1.0ATR ate 240min | COMPRA | 223 | 110 | 3.83 | nao | 323.71 | 1 |  | 609.60 | 609.60 | 31.25 | -37.59 | 30.84 | 100.00 | 2/2 | 13/14 | 661.69 | 557.50 | 8.00 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | C alvo 0.5ATR ate 240min | COMPRA | 223 | 110 | 3.74 | nao | 159.50 | 1 |  | 300.80 | 300.80 | 30.84 | -27.20 | 28.97 | 100.00 | 2/2 | 14/14 | 326.82 | 274.77 | 8.00 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | C alvo 2.0ATR ate 240min | COMPRA | 223 | 110 | 4.58 | nao | 4.32 | 1 |  | 1,149.00 | 1,149.00 | 21.59 | -59.83 | 22.30 | 96.36 | 2/2 | 14/14 | 1,331.43 | 966.57 | 8.00 |
| month=5 & news_min_to_next_high=Q1 | C alvo 2.0ATR ate 240min | COMPRA | 365 | 694 | 2.38 | nao | 1.73 | 1 |  | 590.05 | 590.05 | 12.42 | -59.83 | 13.67 | 80.84 | 2/2 | 2/2 | 625.54 | 554.56 | 8.11 |
| month=8 & news_min_since_last_high=Q5 | C alvo 2.0ATR ate 240min | COMPRA | 827 | 675 | 2.06 | nao | 1.85 | 1 |  | 461.06 | 461.06 | 12.27 | -59.83 | 13.66 | 84.00 | 2/2 | 2/2 | 640.72 | 281.92 | 8.09 |
| month=3 & news_min_to_next_high=Q4 | C alvo 2.0ATR ate 240min | COMPRA | 377 | 182 | 3.76 | nao | 1.66 | 1 |  | 1,559.03 | 1,559.03 | 11.70 | -59.83 | 12.15 | 87.91 | 1/1 | 1/1 | 1,203.27 | 1,914.78 | 9.71 |
| month=8 & news_min_since_last_high=Q5 | C alvo 1.0ATR ate 240min | COMPRA | 827 | 675 | 2.02 | nao | 1.76 | 1 |  | 273.19 | 273.19 | 11.67 | -37.59 | 12.85 | 92.74 | 2/2 | 2/2 | 339.28 | 207.30 | 8.09 |
| day_of_week=WEDNESDAY & month=3 | V alvo 2.0ATR ate 240min | VENDA | 684 | 164 | 2.08 | nao | 1.89 | 1 |  | 1,055.09 | 1,055.09 | 10.69 | 36.94 | 10.27 | 82.32 | 1/1 | 1/1 | 855.10 | 1,255.09 | 9.57 |
| hour=0 & month=3 | C alvo 2.0ATR ate 60min | COMPRA | 192 | 60 | 2.49 | nao | 2.55 | 1 |  | 1,452.66 | 1,452.66 | 9.56 | -34.93 | 9.72 | 86.67 | 1/1 | 1/1 | 1,047.58 | 1,857.75 | 9.26 |
| hour=11 & previous_high_distance_atr=Q1 | C alvo 2.0ATR ate 60min | COMPRA | 505 | 259 | 2.14 | nao | 2.29 | 1 |  | 435.71 | 435.71 | 7.97 | -34.93 | 8.60 | 74.90 | 2/2 | 15/18 | 529.36 | 342.78 | 8.05 |
| previous_high_distance_atr=Q1 & news_min_to_next_high=Q1 | C alvo 2.0ATR ate 60min | COMPRA | 1,417 | 971 | 2.27 | nao | 2.14 | 1 |  | 283.77 | 283.77 | 6.84 | -34.93 | 7.80 | 65.40 | 2/2 | 16/18 | 330.75 | 236.88 | 8.11 |
| mtf_D1=BREAK_DOWN & news_min_since_last_high=Q2 | C alvo 2.0ATR ate 60min | COMPRA | 226 | 143 | 3.15 | nao | 1.74 | 1 |  | 527.44 | 527.44 | 5.91 | -34.93 | 6.29 | 70.63 | 2/2 | 5/5 | 742.04 | 315.82 | 9.04 |
| mtf_D1=BREAK_DOWN & news_min_since_last_high=Q2 | C alvo 1.0ATR ate 60min | COMPRA | 226 | 143 | 2.82 | nao | 1.67 | 1 |  | 339.45 | 339.45 | 5.69 | -28.84 | 6.16 | 80.42 | 2/2 | 5/5 | 412.69 | 267.23 | 9.04 |
| day_of_week=SUNDAY & month=9 | V alvo 1.0ATR ate 60min | VENDA | 120 | 96 | 2.40 | nao | 1.77 | 1 |  | 187.95 | 187.95 | 5.51 | 0.22 | 5.43 | 83.33 | 2/2 | 2/2 | 94.19 | 281.71 | 9.27 |
| hour=4 & mtf_M30=BREAK_UP | C alvo 0.5ATR ate 60min | COMPRA | 222 | 84 | 3.93 | nao | 1.89 | 1 |  | 105.73 | 105.73 | 4.36 | -24.59 | 5.29 | 92.86 | 2/2 | 15/15 | 140.46 | 70.99 | 8.99 |
| news_state=EVENTS_4_AROUND_60M & month=9 | V alvo 2.0ATR ate 15min | VENDA | 209 | 194 | 2.06 | nao | 1.75 | 1 |  | 212.00 | 212.00 | 3.89 | -5.52 | 3.99 | 60.31 | 2/2 | 2/2 | 341.48 | 82.51 | 11.40 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | C alvo 1.0ATR ate 15min | COMPRA | 223 | 110 | 2.27 | nao | 1.68 | 1 |  | 210.72 | 210.72 | 3.70 | -19.77 | 4.04 | 69.09 | 2/2 | 11/14 | 400.04 | 21.40 | 8.00 |
| session=ASIA & streak=-6 | C alvo 2.0ATR ate 15min | COMPRA | 209 | 173 | 2.01 | nao | 2.15 | 1 |  | 138.83 | 138.83 | 3.40 | -17.51 | 3.82 | 58.96 | 2/2 | 16/18 | 101.79 | 175.45 | 8.89 |
| hour=18 & month=10 | C alvo 1.0ATR ate 15min | COMPRA | 276 | 132 | 2.08 | nao | 1.69 | 1 |  | 73.82 | 73.82 | 3.16 | -19.77 | 3.98 | 62.12 | 2/2 | 2/2 | 59.65 | 87.99 | 8.25 |

### M15 — modo `hit`

- eventos: 64,772 (2024-01-22 a 2026-10-16); descoberta 38,771 (até 2025-09-10), validação 25,909 (a partir de 2025-09-11)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 620,034**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 2.0%, top 1000: 4.0%, top 10000: 2.9%
- **placebo** (6 deslocamentos): top 100: 3.0% (máx 5.0%), top 1000: 2.7% (máx 5.0%), top 10000: 1.9% (máx 3.1%); BH: média 0.5 (máx 2); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 38,346 | -0.031 |  | -14.823 |
| C alvo 0.5ATR/60min liquido | 37,057 | -0.021 |  | -10.099 |
| C alvo 0.5ATR/240min liquido | 31,974 | 0.012 |  | 5.939 |
| C alvo 1.0ATR/15min liquido | 38,346 | -0.025 |  | -11.837 |
| C alvo 1.0ATR/60min liquido | 37,057 | -0.007 |  | -3.610 |
| C alvo 1.0ATR/240min liquido | 31,974 | 0.051 |  | 24.738 |
| C alvo 2.0ATR/15min liquido | 38,346 | -0.019 |  | -9.399 |
| C alvo 2.0ATR/60min liquido | 37,057 | 0.011 |  | 5.525 |
| C alvo 2.0ATR/240min liquido | 31,974 | 0.108 |  | 52.231 |
| V alvo 0.5ATR/15min liquido | 38,346 | -0.050 |  | -24.122 |
| V alvo 0.5ATR/60min liquido | 37,057 | -0.074 |  | -35.901 |
| V alvo 0.5ATR/240min liquido | 31,974 | -0.114 |  | -54.749 |
| V alvo 1.0ATR/15min liquido | 38,346 | -0.051 |  | -24.556 |
| V alvo 1.0ATR/60min liquido | 37,057 | -0.084 |  | -40.720 |
| V alvo 1.0ATR/240min liquido | 31,974 | -0.158 |  | -75.970 |
| V alvo 2.0ATR/15min liquido | 38,346 | -0.051 |  | -24.393 |
| V alvo 2.0ATR/60min liquido | 37,057 | -0.092 |  | -44.435 |
| V alvo 2.0ATR/240min liquido | 31,974 | -0.206 |  | -99.213 |

**M15/hit: famílias distintas validadas: 41; com líquido positivo e significativo na validação (custo realista): 31.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=3 & news_min_to_next_high=Q4 | C alvo 2.0ATR ate 240min | COMPRA | 436 | 212 | 2.19 | nao | 3.00 | 1 |  | 1,693.00 | 1,693.00 | 11.11 | -71.40 | 11.57 | 78.77 | 3/3 | 3/3 | 1,625.89 | 1,760.11 | 10.66 |
| mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | V alvo 1.0ATR ate 240min | VENDA | 120 | 100 | 2.10 | nao | 2.69 | 1 |  | 1,142.00 | 1,142.00 | 9.63 | -14.32 | 9.68 | 84.00 | 3/3 | 6/7 | 1,519.02 | 764.98 | 8.13 |
| month=3 & news_min_to_next_high=Q4 | C alvo 1.0ATR ate 240min | COMPRA | 436 | 212 | 2.45 | nao | 2.91 | 1 |  | 973.04 | 973.04 | 9.48 | -57.23 | 10.00 | 86.32 | 3/3 | 3/3 | 953.67 | 992.42 | 10.66 |
| mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | V alvo 2.0ATR ate 240min | VENDA | 120 | 100 | 2.09 | nao | 2.69 | 1 |  | 1,976.31 | 1,976.31 | 9.21 | 7.47 | 9.14 | 81.00 | 3/3 | 6/7 | 3,059.72 | 892.90 | 8.13 |
| day_of_week=TUESDAY & month=1 | C alvo 2.0ATR ate 240min | COMPRA | 456 | 304 | 3.05 | nao | 2.21 | 1 |  | 719.67 | 719.67 | 8.84 | -71.40 | 9.58 | 75.33 | 3/3 | 3/3 | 230.61 | 1,208.74 | 8.78 |
| day_of_week=TUESDAY & month=1 | C alvo 1.0ATR ate 240min | COMPRA | 456 | 304 | 2.52 | nao | 2.11 | 1 |  | 493.27 | 493.27 | 8.54 | -57.23 | 9.32 | 84.21 | 3/3 | 3/3 | 222.25 | 764.28 | 8.78 |
| mtf_H1=BULLISH & dom_w=d08_14 | C alvo 2.0ATR ate 240min | COMPRA | 3,066 | 1,748 | 2.17 | nao | 1.66 | 1 |  | 236.44 | 236.44 | 5.61 | -71.40 | 7.17 | 62.81 | 3/3 | 21/33 | 578.41 | -105.53 | 8.91 |
| day_of_week=TUESDAY & month=1 | C alvo 2.0ATR ate 60min | COMPRA | 528 | 352 | 2.50 | nao | 2.60 | 1 |  | 264.73 | 264.73 | 4.98 | -18.17 | 5.29 | 61.08 | 3/3 | 3/3 | 101.04 | 428.42 | 8.70 |
| prev_day_low_distance_atr=Q2 & news_min_since_last_high=Q2 | C alvo 2.0ATR ate 60min | COMPRA | 646 | 524 | 2.04 | nao | 1.79 | 1 |  | 247.35 | 247.35 | 4.61 | -18.17 | 4.96 | 54.96 | 3/3 | 23/34 | 276.29 | 218.40 | 8.96 |
| day_of_week=TUESDAY & month=1 | C alvo 1.0ATR ate 60min | COMPRA | 528 | 352 | 2.17 | nao | 2.29 | 1 |  | 191.40 | 191.40 | 4.46 | -29.64 | 5.11 | 65.34 | 2/3 | 2/3 | 80.02 | 302.77 | 8.70 |
| month=10 & price_position_daily_open=Q3 | C alvo 1.0ATR ate 60min | COMPRA | 394 | 243 | 2.09 | nao | 1.78 | 1 |  | 205.53 | 205.53 | 4.21 | -29.64 | 4.77 | 69.55 | 3/3 | 3/3 | 246.60 | 164.79 | 8.72 |
| news_state=EVENTS_2_AROUND_60M & swing_high_distance_atr=Q1 | C alvo 0.5ATR ate 60min | COMPRA | 459 | 281 | 2.07 | nao | 1.66 | 1 |  | 282.47 | 282.47 | 4.19 | -29.92 | 4.64 | 76.87 | 2/3 | 26/34 | 421.67 | 144.25 | 8.03 |
| news_state=EVENTS_2_AROUND_60M & previous_high_distance_atr=Q2 | C alvo 0.5ATR ate 60min | COMPRA | 418 | 295 | 2.22 | nao | 1.70 | 1 |  | 214.94 | 214.94 | 3.73 | -29.92 | 4.26 | 75.93 | 3/3 | 24/34 | 268.59 | 161.65 | 8.01 |
| slot_hhmm=09:45 & dom_w=d22_31 | C alvo 1.0ATR ate 15min | COMPRA | 133 | 87 | 2.33 | nao | 2.40 | 1 |  | 168.26 | 168.26 | 3.20 | -14.78 | 3.46 | 63.22 | 3/3 | 28/33 | 223.88 | 113.91 | 8.23 |
| slot_hhmm=09:45 & dom_w=d22_31 | C alvo 2.0ATR ate 15min | COMPRA | 133 | 87 | 2.34 | nao | 2.36 | 1 |  | 166.37 | 166.37 | 3.16 | -10.31 | 3.33 | 63.22 | 3/3 | 28/33 | 227.58 | 106.56 | 8.23 |
| month=1 & session_high_distance_atr=Q1 | C alvo 2.0ATR ate 60min | COMPRA | 432 | 224 | 2.16 | nao | 1.69 | 1 |  | 615.60 | 615.60 | 3.03 | -18.17 | 3.14 | 61.16 | 3/3 | 3/3 | -68.29 | 1,299.49 | 8.88 |
| day_of_week=FRIDAY & month=8 | C alvo 1.0ATR ate 240min | COMPRA | 680 | 272 | 2.02 | nao | 1.89 | 1 |  | 283.22 | 283.22 | 2.90 | -57.23 | 3.48 | 81.99 | 3/3 | 3/3 | 369.72 | 196.73 | 8.86 |
| slot_hhmm=08:45 & atr_ratio=Q3 | C alvo 0.5ATR ate 15min | COMPRA | 128 | 97 | 2.47 | nao | 2.61 | 1 |  | 105.05 | 105.05 | 2.66 | -16.88 | 3.07 | 64.95 | 3/3 | 16/25 | 117.66 | 92.69 | 8.27 |
| mtf_D1=BULLISH & prev_day_high_distance_atr=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 2,948 | 1,746 | 2.39 | nao | 2.10 | 1 |  | 72.52 | 72.52 | 2.60 | -18.17 | 3.27 | 54.75 | 3/3 | 17/25 | 82.13 | 62.92 | 8.82 |
| month=1 & ret_bar_atr=Q5 | C alvo 1.0ATR ate 15min | COMPRA | 535 | 405 | 2.09 | nao | 1.72 | 1 |  | 124.81 | 124.81 | 2.58 | -14.78 | 2.92 | 55.80 | 3/3 | 3/3 | 14.94 | 234.13 | 9.26 |
| slot_hhmm=09:45 & volume_ratio=Q3 | C alvo 1.0ATR ate 15min | COMPRA | 166 | 103 | 2.16 | nao | 1.69 | 1 |  | 116.36 | 116.36 | 2.33 | -14.78 | 2.61 | 59.22 | 3/3 | 22/28 | 136.36 | 96.74 | 8.19 |
| slot_hhmm=09:45 & volume_ratio=Q3 | C alvo 2.0ATR ate 15min | COMPRA | 166 | 103 | 2.36 | nao | 1.65 | 1 |  | 117.13 | 117.13 | 2.30 | -10.31 | 2.49 | 59.22 | 3/3 | 22/28 | 136.89 | 97.75 | 8.19 |
| slot_hhmm=14:45 & prev_day_low_distance_atr=Q1 | V alvo 1.0ATR ate 15min | VENDA | 128 | 97 | 2.31 | nao | 1.91 | 1 |  | 197.74 | 197.74 | 1.83 | -13.06 | 1.94 | 61.86 | 3/3 | 18/28 | 180.37 | 214.76 | 7.85 |
| slot_hhmm=16:15 & mtf_W1=BULLISH | C alvo 2.0ATR ate 15min | COMPRA | 327 | 104 | 2.16 | nao | 2.18 | 1 |  | 154.64 | 154.64 | 1.79 | -10.31 | 1.90 | 55.77 | 3/3 | 20/28 | 79.93 | 229.35 | 7.75 |
| mtf_H1=BREAK_DOWN & previous_low_distance_atr=Q3 | C alvo 1.0ATR ate 15min | COMPRA | 181 | 149 | 2.53 | nao | 2.00 | 1 |  | 160.50 | 160.50 | 1.78 | -14.78 | 1.95 | 59.73 | 3/3 | 22/31 | 273.60 | 48.90 | 9.19 |

### M30 — modo `hit`

- eventos: 32,361 (2024-01-22 a 2026-10-16); descoberta 19,370 (até 2025-09-10), validação 12,945 (a partir de 2025-09-11)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 527,718**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 16.0%, top 1000: 6.2%, top 10000: 4.0%
- **placebo** (6 deslocamentos): top 100: 1.3% (máx 5.0%), top 1000: 1.4% (máx 2.2%), top 10000: 1.6% (máx 2.2%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 19,355 | -0.017 |  | -12.012 |
| C alvo 0.5ATR/60min liquido | 18,508 | -0.012 |  | -8.490 |
| C alvo 0.5ATR/240min liquido | 15,966 | 0.019 |  | 12.936 |
| C alvo 1.0ATR/15min liquido | 19,355 | -0.013 |  | -8.985 |
| C alvo 1.0ATR/60min liquido | 18,508 | 0.001 |  | 0.407 |
| C alvo 1.0ATR/240min liquido | 15,966 | 0.059 |  | 40.854 |
| C alvo 2.0ATR/15min liquido | 19,355 | -0.011 |  | -7.335 |
| C alvo 2.0ATR/60min liquido | 18,508 | 0.013 |  | 9.263 |
| C alvo 2.0ATR/240min liquido | 15,966 | 0.100 |  | 68.730 |
| V alvo 0.5ATR/15min liquido | 19,355 | -0.036 |  | -24.817 |
| V alvo 0.5ATR/60min liquido | 18,508 | -0.058 |  | -40.303 |
| V alvo 0.5ATR/240min liquido | 15,966 | -0.088 |  | -60.564 |
| V alvo 1.0ATR/15min liquido | 19,355 | -0.038 |  | -25.989 |
| V alvo 1.0ATR/60min liquido | 18,508 | -0.067 |  | -45.970 |
| V alvo 1.0ATR/240min liquido | 15,966 | -0.132 |  | -91.090 |
| V alvo 2.0ATR/15min liquido | 19,355 | -0.037 |  | -25.599 |
| V alvo 2.0ATR/60min liquido | 18,508 | -0.065 |  | -44.925 |
| V alvo 2.0ATR/240min liquido | 15,966 | -0.161 |  | -111.090 |

**M30/hit: famílias distintas validadas: 121; com líquido positivo e significativo na validação (custo realista): 77.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=3 & news_min_to_next_high=Q4 | C alvo 1.0ATR ate 240min | COMPRA | 239 | 116 | 2.01 | nao | 2.81 | 1 |  | 1,229.52 | 1,229.52 | 7.18 | -52.31 | 7.46 | 77.59 | 3/3 | 3/3 | 1,161.13 | 1,297.92 | 10.96 |
| day_of_week=TUESDAY & month=1 | C alvo 2.0ATR ate 240min | COMPRA | 228 | 152 | 2.54 | nao | 2.45 | 1 |  | 884.25 | 884.25 | 6.85 | -76.73 | 7.35 | 75.66 | 3/3 | 3/3 | 403.88 | 1,364.62 | 9.05 |
| month=3 & news_min_to_next_high=Q4 | C alvo 2.0ATR ate 240min | COMPRA | 239 | 116 | 2.24 | nao | 2.07 | 1 |  | 1,619.94 | 1,619.94 | 6.32 | -76.73 | 6.62 | 65.52 | 3/3 | 3/3 | 1,648.37 | 1,591.50 | 10.96 |
| day_of_week=TUESDAY & month=1 | C alvo 1.0ATR ate 240min | COMPRA | 228 | 152 | 2.77 | nao | 2.07 | 1 |  | 575.04 | 575.04 | 5.91 | -52.31 | 6.32 | 78.95 | 3/3 | 3/3 | 260.30 | 889.78 | 9.05 |
| month=3 & news_min_to_next_high=Q4 | C alvo 0.5ATR ate 240min | COMPRA | 239 | 116 | 2.13 | nao | 2.40 | 1 |  | 626.74 | 626.74 | 5.38 | -43.27 | 5.72 | 87.07 | 3/3 | 3/3 | 649.56 | 603.92 | 10.96 |
| day_of_week=TUESDAY & month=1 | C alvo 0.5ATR ate 240min | COMPRA | 228 | 152 | 2.50 | nao | 1.74 | 1 |  | 365.42 | 365.42 | 5.18 | -43.27 | 5.65 | 88.82 | 3/3 | 3/3 | 205.83 | 525.00 | 9.05 |
| mtf_H1=BULLISH & dom_w=d08_14 | C alvo 1.0ATR ate 240min | COMPRA | 1,538 | 876 | 2.08 | nao | 1.78 | 1 |  | 256.39 | 256.39 | 4.77 | -52.31 | 5.63 | 69.86 | 3/3 | 23/33 | 553.11 | -40.33 | 9.05 |
| prev_day_high_distance_atr=Q5 & cum3=Q1 | C alvo 1.0ATR ate 60min | COMPRA | 339 | 232 | 2.72 | nao | 3.23 | 1 |  | 399.25 | 399.25 | 4.75 | -17.71 | 4.97 | 64.66 | 3/3 | 24/31 | 558.95 | 239.55 | 8.68 |
| month=3 & price_position_daily_open=Q2 | C alvo 0.5ATR ate 60min | COMPRA | 453 | 69 | 2.04 | nao | 3.65 | 1 |  | 585.40 | 585.40 | 4.36 | -26.05 | 4.52 | 79.71 | 3/3 | 3/3 | 306.22 | 856.60 | 9.15 |
| slot_hhmm=20:30 & news_state=NONE_60M | C alvo 0.5ATR ate 60min | COMPRA | 217 | 121 | 2.26 | nao | 2.97 | 1 |  | 302.57 | 302.57 | 4.32 | -26.05 | 4.65 | 77.69 | 3/3 | 17/22 | 299.72 | 305.39 | 29.77 |
| month=1 & dom_w=d15_21 | C alvo 0.5ATR ate 240min | COMPRA | 186 | 186 | 2.06 | nao | 1.94 | 1 |  | 293.65 | 293.65 | 4.07 | -43.27 | 4.58 | 86.56 | 2/2 | 2/2 | 263.36 | 323.94 | 8.95 |
| prev_day_high_distance_atr=Q5 & cum3=Q1 | C alvo 1.0ATR ate 15min | COMPRA | 348 | 246 | 2.31 | nao | 4.02 | 1 |  | 211.67 | 211.67 | 4.07 | 0.80 | 4.08 | 63.01 | 2/3 | 21/31 | 282.00 | 141.34 | 9.53 |
| month=3 & price_position_daily_open=Q2 | C alvo 1.0ATR ate 60min | COMPRA | 453 | 69 | 2.44 | nao | 3.29 | 1 |  | 624.15 | 624.15 | 3.69 | -17.71 | 3.78 | 72.46 | 3/3 | 3/3 | 598.52 | 649.05 | 9.15 |
| day_of_week=TUESDAY & month=1 | C alvo 2.0ATR ate 60min | COMPRA | 264 | 176 | 2.07 | nao | 2.72 | 1 |  | 318.82 | 318.82 | 3.67 | -11.49 | 3.79 | 59.66 | 3/3 | 3/3 | 147.64 | 490.00 | 8.93 |
| session=NEW_YORK & news_min_to_next_high=Q4 | C alvo 0.5ATR ate 60min | COMPRA | 191 | 113 | 3.80 | nao | 3.45 | 1 |  | 341.29 | 341.29 | 3.65 | -26.05 | 3.92 | 76.99 | 3/3 | 25/30 | 438.40 | 245.89 | 28.26 |
| prev_day_high_distance_atr=Q5 & cum3=Q1 | C alvo 2.0ATR ate 60min | COMPRA | 339 | 232 | 2.33 | nao | 2.43 | 1 |  | 318.66 | 318.66 | 3.64 | -11.49 | 3.78 | 61.21 | 3/3 | 24/31 | 475.09 | 162.24 | 8.68 |
| month=8 & previous_low_distance_atr=Q1 | C alvo 1.0ATR ate 240min | COMPRA | 364 | 167 | 2.57 | nao | 1.67 | 1 |  | 367.15 | 367.15 | 3.59 | -52.31 | 4.04 | 72.46 | 3/3 | 3/3 | 382.17 | 352.32 | 9.06 |
| hour=20 & news_state=NONE_60M | C alvo 0.5ATR ate 60min | COMPRA | 250 | 148 | 2.21 | nao | 2.78 | 1 |  | 247.01 | 247.01 | 3.53 | -26.05 | 3.87 | 72.30 | 3/3 | 21/29 | 173.91 | 320.12 | 25.89 |
| mtf_H4=BREAK_UP & prev_day_high_distance_atr=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 1,410 | 822 | 2.07 | nao | 2.27 | 1 |  | 135.36 | 135.36 | 3.43 | -17.71 | 3.89 | 58.15 | 3/3 | 22/33 | 73.60 | 197.12 | 8.97 |
| hour=20 & news_min_to_next_high=Q4 | C alvo 0.5ATR ate 60min | COMPRA | 129 | 70 | 3.58 | nao | 2.73 | 1 |  | 287.72 | 287.72 | 3.29 | -26.05 | 3.55 | 75.71 | 3/3 | 20/22 | 255.60 | 319.84 | 29.77 |
| slot_hhmm=20:30 & news_min_to_next_high=Q4 | C alvo 0.5ATR ate 60min | COMPRA | 129 | 70 | 3.58 | nao | 2.73 | 1 |  | 287.72 | 287.72 | 3.29 | -26.05 | 3.55 | 75.71 | 3/3 | 20/22 | 255.60 | 319.84 | 29.77 |
| prev_day_high_distance_atr=Q5 & cum3=Q1 | C alvo 2.0ATR ate 15min | COMPRA | 348 | 246 | 2.48 | nao | 3.27 | 1 |  | 178.24 | 178.24 | 3.29 | 3.35 | 3.25 | 62.60 | 2/3 | 22/31 | 218.63 | 137.84 | 9.53 |
| mtf_H1=RANGE & price_position_daily_open=Q3 | C alvo 2.0ATR ate 60min | COMPRA | 929 | 219 | 2.53 | nao | 1.68 | 1 |  | 232.59 | 232.59 | 3.21 | -11.49 | 3.35 | 54.34 | 3/3 | 26/34 | 123.30 | 340.89 | 8.80 |
| slot_hhmm=09:30 & dom_w=d22_31 | C alvo 2.0ATR ate 15min | COMPRA | 132 | 87 | 2.26 | nao | 2.53 | 1 |  | 166.34 | 166.34 | 3.16 | 3.35 | 3.06 | 63.22 | 3/3 | 28/33 | 227.60 | 106.48 | 8.22 |
| slot_hhmm=09:30 & dom_w=d22_31 | C alvo 1.0ATR ate 15min | COMPRA | 132 | 87 | 2.20 | nao | 2.53 | 1 |  | 164.34 | 164.34 | 3.15 | 0.80 | 3.11 | 63.22 | 3/3 | 28/33 | 231.73 | 98.49 | 8.22 |

### H1 — modo `hit`

- eventos: 31,777 (2021-04-27 a 2026-10-16); descoberta 19,043 (até 2024-08-20), validação 12,711 (a partir de 2024-08-21)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 546,858**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 4.0%, top 1000: 6.9%, top 10000: 3.9%
- **placebo** (6 deslocamentos): top 100: 3.8% (máx 7.0%), top 1000: 2.6% (máx 6.0%), top 10000: 2.3% (máx 4.2%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 19,010 | -0.026 |  | -14.440 |
| C alvo 0.5ATR/60min liquido | 18,105 | -0.024 |  | -13.416 |
| C alvo 0.5ATR/240min liquido | 15,389 | -0.018 |  | -9.864 |
| C alvo 1.0ATR/15min liquido | 19,010 | -0.024 |  | -13.642 |
| C alvo 1.0ATR/60min liquido | 18,105 | -0.018 |  | -10.359 |
| C alvo 1.0ATR/240min liquido | 15,389 | -0.007 |  | -4.201 |
| C alvo 2.0ATR/15min liquido | 19,010 | -0.024 |  | -13.287 |
| C alvo 2.0ATR/60min liquido | 18,105 | -0.019 |  | -10.537 |
| C alvo 2.0ATR/240min liquido | 15,389 | -0.008 |  | -4.746 |
| V alvo 0.5ATR/15min liquido | 19,010 | -0.021 |  | -11.520 |
| V alvo 0.5ATR/60min liquido | 18,105 | -0.029 |  | -16.346 |
| V alvo 0.5ATR/240min liquido | 15,389 | -0.036 |  | -20.215 |
| V alvo 1.0ATR/15min liquido | 19,010 | -0.021 |  | -11.575 |
| V alvo 1.0ATR/60min liquido | 18,105 | -0.030 |  | -16.666 |
| V alvo 1.0ATR/240min liquido | 15,389 | -0.042 |  | -23.425 |
| V alvo 2.0ATR/15min liquido | 19,010 | -0.019 |  | -10.932 |
| V alvo 2.0ATR/60min liquido | 18,105 | -0.028 |  | -15.560 |
| V alvo 2.0ATR/240min liquido | 15,389 | -0.040 |  | -22.640 |

**H1/hit: famílias distintas validadas: 90; com líquido positivo e significativo na validação (custo realista): 72.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| structure_at_close=BULLISH & dom_w=d08_14 | C alvo 2.0ATR ate 240min | COMPRA | 1,312 | 946 | 2.31 | nao | 2.56 | 1 |  | 267.84 | 267.84 | 4.81 | -15.12 | 5.11 | 58.99 | 5/6 | 39/66 | 186.96 | 348.71 | 9.79 |
| price_position_weekly_open=Q2 & price_position_monthly_open=Q3 | C alvo 2.0ATR ate 240min | COMPRA | 428 | 144 | 2.02 | nao | 2.60 | 1 |  | 343.14 | 343.14 | 4.28 | -15.12 | 4.33 | 65.28 | 4/5 | 13/19 | 224.85 | 461.43 | 9.40 |
| session_low_distance_atr=Q1 & swing_low_distance_atr=Q5 | C alvo 0.5ATR ate 240min | COMPRA | 182 | 90 | 2.10 | nao | 2.83 | 1 |  | 363.10 | 363.10 | 4.12 | -23.93 | 4.33 | 83.33 | 6/6 | 22/24 | 341.79 | 384.41 | 9.25 |
| volume_ratio=Q1 & news_min_since_last_high=Q2 | C alvo 0.5ATR ate 240min | COMPRA | 192 | 382 | 2.62 | nao | 2.25 | 1 |  | 214.40 | 214.40 | 4.11 | -23.93 | 4.49 | 76.44 | 4/4 | 28/37 | 144.09 | 284.71 | 21.24 |
| volatility_state=VERY_LOW & news_min_since_last_high=Q2 | C alvo 0.5ATR ate 240min | COMPRA | 150 | 216 | 2.24 | nao | 2.17 | 1 |  | 249.24 | 249.24 | 3.67 | -23.93 | 3.97 | 77.31 | 4/4 | 25/31 | 171.01 | 327.47 | 22.54 |
| streak=3 & price_position_daily_open=Q3 | C alvo 1.0ATR ate 60min | COMPRA | 220 | 47 | 2.26 | nao | 3.47 | 1 |  | 190.61 | 190.61 | 3.56 | -6.62 | 3.58 | 68.09 | 5/5 | 24/32 | 123.30 | 255.12 | 8.86 |
| range_atr=Q5 & price_position_daily_open=Q3 | C alvo 1.0ATR ate 60min | COMPRA | 461 | 85 | 2.07 | nao | 3.68 | 1 |  | 292.50 | 292.50 | 3.29 | -6.62 | 3.34 | 70.59 | 5/5 | 32/46 | 150.87 | 430.84 | 8.60 |
| price_position_weekly_open=Q5 & news_min_since_last_high=Q2 | C alvo 2.0ATR ate 60min | COMPRA | 193 | 536 | 2.02 | nao | 3.00 | 1 |  | 154.83 | 154.83 | 3.22 | 0.62 | 3.26 | 54.66 | 4/4 | 26/34 | 53.13 | 256.53 | 13.37 |
| news_state=NONE_60M & cost_atr=Q3 | C alvo 1.0ATR ate 240min | COMPRA | 606 | 370 | 2.33 | nao | 1.95 | 1 |  | 117.26 | 117.26 | 3.20 | -18.24 | 3.30 | 69.46 | 4/4 | 17/22 | 62.94 | 171.58 | 11.17 |
| session=NEW_YORK & structure_before=BREAK_UP | C alvo 0.5ATR ate 60min | COMPRA | 128 | 118 | 3.25 | nao | 3.04 | 2 |  | 230.71 | 230.71 | 3.16 | -9.70 | 3.28 | 61.02 | 6/6 | 16/22 | 128.18 | 333.23 | 15.49 |
| structure_before=RANGE & price_position_daily_open=Q3 | C alvo 1.0ATR ate 60min | COMPRA | 889 | 186 | 2.57 | nao | 2.25 | 2 |  | 153.98 | 153.98 | 3.07 | -6.62 | 3.16 | 58.60 | 6/6 | 37/56 | 48.21 | 259.75 | 9.56 |
| news_state=NONE_60M & cost_atr=Q3 | C alvo 2.0ATR ate 240min | COMPRA | 606 | 370 | 2.83 | nao | 1.86 | 1 |  | 138.45 | 138.45 | 3.01 | -15.12 | 3.07 | 60.54 | 4/4 | 17/22 | 64.65 | 212.25 | 11.17 |
| streak=3 & price_position_daily_open=Q3 | C alvo 2.0ATR ate 60min | COMPRA | 220 | 47 | 2.40 | nao | 3.28 | 1 |  | 239.26 | 239.26 | 2.98 | 0.62 | 2.93 | 68.09 | 5/5 | 22/32 | 120.24 | 353.33 | 8.86 |
| news_min_since_last_high=Q2 | C alvo 0.5ATR ate 240min | COMPRA | 277 | 605 | 2.11 | nao | 2.24 | 1 |  | 177.82 | 177.82 | 2.94 | -23.93 | 3.40 | 75.04 | 4/4 | 25/37 | 124.18 | 231.28 | 17.84 |
| volume_ratio=Q1 & news_min_since_last_high=Q2 | C alvo 1.0ATR ate 60min | COMPRA | 201 | 395 | 2.99 | nao | 3.40 | 1 |  | 127.14 | 127.14 | 2.92 | -6.62 | 3.07 | 55.19 | 4/4 | 26/37 | 85.52 | 168.55 | 20.81 |
| close_position=Q1 & previous_high_distance_atr=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 248 | 201 | 2.24 | nao | 3.73 | 1 |  | 128.84 | 128.84 | 2.88 | -9.70 | 3.06 | 61.19 | 5/6 | 36/50 | 136.20 | 121.55 | 10.06 |
| close_position=Q1 & previous_high_distance_atr=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 248 | 201 | 2.38 | nao | 3.77 | 1 |  | 151.07 | 151.07 | 2.87 | -6.62 | 2.97 | 57.21 | 5/6 | 36/50 | 159.93 | 142.29 | 10.06 |
| slot_hhmm=20:00 & structure_at_close=BEARISH | C alvo 0.5ATR ate 15min | COMPRA | 167 | 178 | 3.10 | nao | 3.39 | 2 |  | 129.44 | 129.44 | 2.85 | 6.56 | 2.71 | 61.24 | 5/5 | 34/42 | 19.46 | 239.42 | 23.41 |
| month=12 & volume_ratio=Q1 | C alvo 2.0ATR ate 60min | COMPRA | 240 | 108 | 2.54 | nao | 2.51 | 1 |  | 151.52 | 151.52 | 2.85 | 0.62 | 2.79 | 60.19 | 5/5 | 5/5 | 95.66 | 207.38 | 17.16 |
| volume_ratio=Q1 & news_min_since_last_high=Q2 | C alvo 2.0ATR ate 60min | COMPRA | 201 | 395 | 2.83 | nao | 3.04 | 1 |  | 130.46 | 130.46 | 2.83 | 0.62 | 2.82 | 54.18 | 4/4 | 25/37 | 75.78 | 184.87 | 20.81 |
| mtf_D1=BEARISH & month=11 | C alvo 0.5ATR ate 60min | COMPRA | 128 | 326 | 2.22 | nao | 2.73 | 1 |  | 80.66 | 80.66 | 2.81 | -9.70 | 3.04 | 65.64 | 4/4 | 4/4 | 60.93 | 100.39 | 9.38 |
| mtf_D1=BEARISH & month=11 | C alvo 1.0ATR ate 60min | COMPRA | 128 | 326 | 2.48 | nao | 2.95 | 1 |  | 93.80 | 93.80 | 2.80 | -6.62 | 2.92 | 61.35 | 4/4 | 4/4 | 97.96 | 89.64 | 9.38 |
| month=12 & volume_ratio=Q1 | C alvo 0.5ATR ate 60min | COMPRA | 240 | 108 | 2.18 | nao | 2.36 | 1 |  | 112.16 | 112.16 | 2.77 | -9.70 | 2.94 | 62.96 | 5/5 | 5/5 | 59.21 | 165.10 | 17.16 |
| session=LONDON_NY_OVERLAP & price_position_daily_open=Q3 | C alvo 1.0ATR ate 60min | COMPRA | 358 | 76 | 2.37 | nao | 2.60 | 1 |  | 252.74 | 252.74 | 2.76 | -6.62 | 2.81 | 61.84 | 6/6 | 25/38 | 109.02 | 396.45 | 8.20 |
| volume_ratio=Q1 & news_min_since_last_high=Q2 | C alvo 1.0ATR ate 240min | COMPRA | 192 | 382 | 2.19 | nao | 1.67 | 1 |  | 213.75 | 213.75 | 2.76 | -18.24 | 2.99 | 60.21 | 4/4 | 27/37 | 226.34 | 201.15 | 21.24 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **3245**
- com líquido positivo e t>1,645 na validação, custo realista: **1374**; dessas, sobreviveram ao BH: **5**; e positivas nas duas metades da validação: **3**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H1 | ret | volume_ratio=Q1 & news_min_since_last_high=Q2 | 60min | COMPRA | 395 | 149.40 | 4.95 | 2.75 | 2.83 | 54.18 | 4/4 | 26/37 |
| H1 | ret | hour=20 & structure_at_close=BEARISH | 15min | COMPRA | 178 | 117.96 | 12.74 | 1.95 | 2.17 | 60.11 | 5/5 | 34/42 |
| M30 | ret | session=NEW_YORK & news_min_to_next_high=Q4 | 5min | COMPRA | 272 | 81.15 | 1.35 | 2.12 | 2.13 | 52.57 | 2/3 | 18/34 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 1156s)_
