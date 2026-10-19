# XAUUSD — relatório completo MBA (gerado em 2026-10-17 02:27)

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
| M5 | open | 100,835 | 66,586 | 4 | 0 | 0.0 | 0.0 | 0 | 12.0 | 6.7 |
| M15 | open | 64,772 | 74,418 | 31 | 4 | 23.3 | 0.0 | 0 | 18.0 | 21.0 |
| M30 | open | 32,361 | 58,683 | 15 | 4 | 11.5 | 0.2 | 1 | 19.0 | 11.2 |
| H1 | open | 31,777 | 60,317 | 12 | 10 | 0.2 | 0.0 | 0 | 53.0 | 8.0 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 100,835 (2025-05-15 a 2026-10-16); descoberta 60,226 (até 2026-03-23), validação 40,334 (a partir de 2026-03-24)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 66,586**; passaram no BH (q=5%) na descoberta: **4**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 12.0%, top 1000: 6.1%, top 10000: 4.4%
- **placebo** (6 deslocamentos): top 100: 6.7% (máx 14.0%), top 1000: 5.3% (máx 9.5%), top 10000: 4.0% (máx 5.6%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 60,213 | 0.009 | 3.390 | 3.754 |
| 10min bruto | 60,213 | 0.018 | 3.218 | 7.491 |
| 20min bruto | 59,760 | 0.030 | 2.546 | 12.152 |
| 35min bruto | 59,083 | 0.049 | 2.336 | 19.957 |
| 65min bruto | 57,738 | 0.091 | 2.252 | 37.110 |
| 125min bruto | 55,050 | 0.172 | 2.044 | 70.250 |
| 245min bruto | 49,712 | 0.320 | 1.711 | 130.612 |

**M5/open: famílias distintas validadas: 91; com líquido positivo e significativo na validação (custo realista): 40.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 245min | COMPRA | 223 | 110 | 2.35 | nao | 1.75 | 1 | 2,190.57 | 2,182.57 | 2,182.57 | 10.41 | -53.07 | 10.62 | 90.91 | 2/2 | 12/14 | 3,023.08 | 1,342.06 | 8.00 |
| month=3 & news_min_to_next_high=Q4 | 125min | COMPRA | 382 | 187 | 2.24 | nao | 1.71 | 1 | 2,525.11 | 2,514.78 | 2,514.78 | 8.65 | -28.36 | 8.76 | 76.47 | 1/1 | 1/1 | 2,312.10 | 2,715.30 | 10.33 |
| mtf_D1=BREAK_DOWN & news_min_since_last_high=Q2 | 125min | COMPRA | 190 | 119 | 2.49 | nao | 1.69 | 1 | 2,239.89 | 2,230.22 | 2,230.22 | 8.63 | -28.36 | 8.73 | 79.83 | 2/2 | 5/5 | 3,847.91 | 639.49 | 9.67 |
| hour=0 & month=3 | 65min | COMPRA | 192 | 60 | 2.15 | nao | 2.04 | 1 | 2,503.97 | 2,494.68 | 2,494.68 | 7.63 | -19.23 | 7.64 | 86.67 | 1/1 | 1/1 | 1,300.69 | 3,688.66 | 9.29 |
| slot_hhmm=09:25 | 5min | VENDA | 219 | 147 | -3.23 | nao | -7.06 | 3 | 159.99 | 151.73 | 152.07 | 6.64 | -8.25 | 6.97 | 70.75 | 2/2 | 15/18 | 173.25 | 131.19 | 7.91 |
| slot_hhmm=09:25 & news_state=NONE_60M | 5min | VENDA | 216 | 143 | -3.28 | nao | -6.96 | 1 | 161.84 | 153.58 | 153.92 | 6.56 | -8.25 | 6.89 | 70.63 | 2/2 | 15/18 | 169.91 | 138.16 | 7.91 |
| hour=6 & mtf_D1=BEARISH | 20min | COMPRA | 312 | 1,032 | 2.01 | nao | 2.72 | 1 | 122.02 | 113.75 | 113.75 | 5.57 | -12.75 | 6.25 | 54.65 | 2/2 | 9/13 | 185.29 | 42.21 | 8.27 |
| slot_hhmm=09:25 | 10min | VENDA | 219 | 147 | -2.03 | nao | -3.73 | 3 | 179.88 | 171.63 | 171.80 | 5.18 | -7.50 | 5.39 | 66.67 | 2/2 | 13/18 | 200.32 | 143.67 | 8.08 |
| slot_hhmm=09:25 & news_state=NONE_60M | 10min | VENDA | 216 | 143 | -2.02 | nao | -3.60 | 1 | 178.04 | 169.79 | 169.95 | 5.01 | -7.50 | 5.21 | 65.73 | 2/2 | 13/18 | 184.52 | 155.58 | 8.09 |
| mtf_M15=BULLISH & pcum10=Q5 | 20min | COMPRA | 4,113 | 2,292 | 2.18 | nao | 2.02 | 1 | 78.98 | 70.13 | 70.13 | 4.09 | -12.75 | 5.00 | 52.14 | 2/2 | 12/18 | 117.66 | 22.60 | 8.85 |
| hour=6 & mtf_H1=BULLISH | 35min | COMPRA | 972 | 576 | 2.01 | nao | 1.79 | 1 | 150.31 | 142.05 | 142.05 | 4.05 | -14.64 | 4.48 | 55.73 | 2/2 | 14/18 | 189.13 | 94.97 | 8.25 |
| mtf_M5=BREAK_DOWN & mtf_W1=BULLISH | 10min | COMPRA | 2,220 | 181 | 2.45 | nao | 2.25 | 2 | 168.75 | 159.30 | 159.30 | 3.60 | -10.81 | 3.85 | 63.54 | 2/2 | 9/12 | 206.16 | 112.95 | 9.45 |
| hour=6 & mtf_D1=BEARISH | 10min | COMPRA | 312 | 1,032 | 2.18 | nao | 2.80 | 1 | 61.23 | 52.96 | 52.96 | 3.46 | -10.81 | 4.20 | 53.29 | 2/2 | 10/13 | 84.69 | 21.23 | 8.27 |
| mtf_W1=BULLISH & pcum10=Q1 | 10min | COMPRA | 9,509 | 823 | 2.00 | nao | 2.39 | 1 | 86.34 | 77.07 | 77.07 | 3.35 | -10.81 | 3.87 | 58.32 | 2/2 | 7/12 | 123.79 | 30.47 | 9.27 |
| hour=6 & mtf_H1=BULLISH | 20min | COMPRA | 972 | 576 | 2.19 | nao | 1.84 | 1 | 97.95 | 89.70 | 89.70 | 3.20 | -12.75 | 3.67 | 53.30 | 2/2 | 15/18 | 157.29 | 22.12 | 8.25 |
| session=ASIA & streak_prev=-6 | 10min | COMPRA | 210 | 174 | 2.29 | nao | 2.46 | 1 | 112.07 | 103.17 | 103.17 | 2.94 | -10.81 | 3.24 | 58.05 | 2/2 | 16/18 | 79.29 | 127.05 | 8.90 |
| mtf_M15=BULLISH & mtf_H1=BREAK_UP | 35min | COMPRA | 3,396 | 1,485 | 2.23 | nao | 1.99 | 1 | 89.41 | 80.79 | 80.79 | 2.68 | -14.64 | 3.24 | 51.78 | 2/2 | 12/18 | 125.19 | 36.46 | 8.61 |
| hour=0 & range_atr_prev=Q5 | 10min | COMPRA | 656 | 618 | 2.09 | nao | 2.21 | 1 | 73.98 | 64.60 | 64.60 | 2.66 | -10.81 | 3.13 | 52.43 | 2/2 | 13/18 | 90.58 | 38.62 | 9.38 |
| hour=1 & month=3 | 5min | COMPRA | 192 | 60 | 2.36 | nao | 2.89 | 1 | 270.68 | 261.62 | 261.62 | 2.61 | -9.99 | 2.69 | 61.67 | 1/1 | 1/1 | 183.90 | 339.35 | 9.06 |
| mtf_W1=BULLISH & pcum10=Q1 | 5min | COMPRA | 9,509 | 823 | 2.51 | nao | 3.00 | 1 | 47.93 | 38.66 | 38.66 | 2.45 | -9.99 | 3.13 | 54.92 | 1/2 | 4/12 | 54.19 | 23.17 | 9.27 |
| streak_prev=-4 & p2=Q1 | 5min | COMPRA | 712 | 528 | 2.50 | nao | 2.60 | 1 | 52.97 | 43.75 | 43.75 | 2.44 | -9.99 | 3.01 | 54.73 | 1/2 | 12/18 | 86.59 | 0.91 | 9.22 |
| mtf_M5=BREAK_DOWN & pcum3=Q1 | 10min | COMPRA | 2,538 | 2,096 | 2.11 | nao | 2.27 | 2 | 44.44 | 35.39 | 35.39 | 2.44 | -10.81 | 3.29 | 53.91 | 2/2 | 13/18 | 37.64 | 33.13 | 9.05 |
| mtf_M5=BREAK_DOWN & news_state=NONE_60M | 10min | COMPRA | 2,252 | 1,849 | 2.08 | nao | 1.94 | 2 | 39.76 | 30.45 | 30.45 | 2.33 | -10.81 | 3.23 | 53.76 | 2/2 | 12/18 | 32.37 | 28.53 | 9.31 |
| p2=Q1 & pcum10=Q1 | 10min | COMPRA | 4,275 | 3,110 | 2.15 | nao | 2.03 | 1 | 33.52 | 24.40 | 24.40 | 2.22 | -10.81 | 3.36 | 52.73 | 2/2 | 10/18 | 21.90 | 26.90 | 9.12 |
| structure_before=BREAK_DOWN & dom_w=d08_14 | 5min | COMPRA | 600 | 540 | 2.52 | nao | 2.63 | 2 | 51.24 | 42.38 | 42.38 | 2.18 | -9.99 | 2.71 | 54.63 | 2/2 | 14/17 | 71.14 | 13.61 | 8.86 |

### M15 — modo `open`

- eventos: 64,772 (2024-01-22 a 2026-10-16); descoberta 38,771 (até 2025-09-10), validação 25,909 (a partir de 2025-09-11)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 74,418**; passaram no BH (q=5%) na descoberta: **31**; confirmadas na validação: **4**
- melhores N da descoberta que repetem na validação: top 100: 18.0%, top 1000: 13.3%, top 10000: 8.8%
- **placebo** (6 deslocamentos): top 100: 21.0% (máx 33.0%), top 1000: 16.9% (máx 22.8%), top 10000: 11.1% (máx 17.0%); BH: média 23.3 (máx 140); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 38,758 | 0.017 | 4.787 | 7.999 |
| 20min bruto | 38,758 | 0.024 | 4.915 | 11.604 |
| 30min bruto | 38,346 | 0.033 | 4.504 | 16.051 |
| 45min bruto | 37,914 | 0.049 | 4.236 | 23.450 |
| 75min bruto | 37,057 | 0.080 | 3.985 | 38.547 |
| 135min bruto | 35,358 | 0.147 | 3.775 | 70.687 |
| 255min bruto | 31,974 | 0.283 | 3.464 | 136.315 |

**M15/open: famílias distintas validadas: 426; com líquido positivo e significativo na validação (custo realista): 184.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=3 & news_min_to_next_high=Q4 | 255min | COMPRA | 436 | 212 | 2.01 | nao | 2.24 | 1 | 2,154.39 | 2,142.08 | 2,142.08 | 9.95 | -53.60 | 10.22 | 71.70 | 3/3 | 3/3 | 1,881.57 | 2,402.60 | 12.30 |
| day_of_week=TUESDAY & month=1 | 255min | COMPRA | 456 | 304 | 2.24 | nao | 2.33 | 1 | 1,285.27 | 1,276.33 | 1,276.33 | 9.85 | -53.60 | 10.24 | 73.36 | 3/3 | 3/3 | 467.50 | 2,085.16 | 8.95 |
| day_of_week=TUESDAY & month=1 | 135min | COMPRA | 504 | 336 | 2.66 | nao | 2.39 | 1 | 746.71 | 737.84 | 737.84 | 7.28 | -17.87 | 7.46 | 66.37 | 3/3 | 3/3 | 263.03 | 1,212.66 | 8.87 |
| day_of_week=TUESDAY & month=1 | 75min | COMPRA | 528 | 352 | 2.72 | nao | 2.73 | 1 | 417.55 | 408.72 | 408.72 | 5.70 | -7.64 | 5.80 | 59.94 | 3/3 | 3/3 | 156.95 | 660.48 | 8.84 |
| day_of_week=MONDAY & mtf_H1=BULLISH | 135min | COMPRA | 2,666 | 1,767 | 2.08 | nao | 2.65 | 1 | 246.53 | 237.35 | 237.35 | 5.56 | -17.87 | 6.01 | 57.67 | 2/3 | 22/33 | 430.28 | 44.65 | 9.17 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 255min | COMPRA | 5,315 | 2,586 | 2.26 | nao | 2.12 | 1 | 302.83 | 293.44 | 293.44 | 5.50 | -53.60 | 6.72 | 56.61 | 3/3 | 18/28 | 384.69 | 202.19 | 9.39 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 135min | COMPRA | 5,910 | 2,921 | 2.11 | nao | 2.50 | 1 | 194.69 | 185.44 | 185.44 | 5.26 | -17.87 | 5.90 | 54.95 | 3/3 | 17/28 | 223.81 | 147.09 | 9.25 |
| news_state=NONE_60M & atr_ratio_prev=Q4 | 45min | COMPRA | 5,532 | 3,678 | 2.33 | nao | 2.71 | 1 | 101.53 | 92.65 | 92.65 | 4.99 | -6.14 | 5.46 | 53.07 | 3/3 | 25/34 | 183.45 | 1.85 | 8.88 |
| day_of_week=MONDAY & mtf_W1=BREAK_UP | 255min | COMPRA | 1,444 | 675 | 2.11 | nao | 2.17 | 1 | 522.44 | 513.20 | 513.20 | 4.70 | -53.60 | 5.24 | 70.81 | 3/3 | 9/12 | 1,123.56 | -95.35 | 9.24 |
| structure_before=BEARISH & atr_ratio_prev=Q4 | 45min | COMPRA | 2,374 | 1,540 | 2.60 | nao | 2.43 | 2 | 149.72 | 141.03 | 141.03 | 4.70 | -6.14 | 4.98 | 54.48 | 3/3 | 25/34 | 201.51 | 80.55 | 8.69 |
| structure_before=BULLISH & mtf_D1=BREAK_UP | 45min | COMPRA | 1,873 | 1,201 | 2.03 | nao | 3.12 | 2 | 175.53 | 166.24 | 166.24 | 4.67 | -6.14 | 4.92 | 57.29 | 3/3 | 14/20 | 77.63 | 254.70 | 9.29 |
| mtf_H1=BULLISH & news_state=NONE_60M | 255min | COMPRA | 10,930 | 6,167 | 2.07 | nao | 1.94 | 1 | 184.49 | 175.08 | 175.08 | 4.67 | -53.60 | 6.90 | 53.06 | 3/3 | 22/34 | 439.86 | -89.62 | 9.41 |
| mtf_H1=BULLISH & news_state=NONE_60M | 135min | COMPRA | 11,590 | 6,591 | 2.18 | nao | 2.30 | 1 | 123.49 | 114.15 | 114.15 | 4.56 | -17.87 | 5.74 | 52.47 | 3/3 | 21/34 | 293.49 | -65.13 | 9.33 |
| dom_w=d01_07 & atr_ratio_prev=Q4 | 45min | COMPRA | 1,811 | 1,124 | 2.19 | nao | 1.98 | 1 | 180.42 | 171.85 | 171.85 | 4.45 | -6.14 | 4.68 | 55.52 | 3/3 | 23/33 | 257.67 | 86.03 | 8.57 |
| mtf_D1=BULLISH & atr_ratio_prev=Q4 | 75min | COMPRA | 3,295 | 1,700 | 2.13 | nao | 2.25 | 1 | 163.64 | 154.98 | 154.98 | 4.39 | -7.64 | 4.67 | 55.18 | 3/3 | 20/28 | 144.47 | 165.48 | 8.67 |
| news_state=NONE_60M & atr_ratio_prev=Q4 | 30min | COMPRA | 5,555 | 3,702 | 2.49 | nao | 2.98 | 1 | 76.28 | 67.41 | 67.41 | 4.38 | -5.86 | 4.91 | 52.51 | 3/3 | 24/34 | 128.63 | 6.19 | 8.87 |
| day_of_week=MONDAY & mtf_W1=BREAK_UP | 135min | COMPRA | 1,596 | 747 | 2.34 | nao | 2.68 | 1 | 309.77 | 300.64 | 300.64 | 4.36 | -17.87 | 4.64 | 64.39 | 3/3 | 9/12 | 610.62 | -8.52 | 9.13 |
| mtf_M15=BULLISH & mtf_W1=BREAK_UP | 45min | COMPRA | 3,145 | 1,719 | 2.65 | nao | 3.12 | 2 | 136.53 | 127.33 | 127.33 | 4.35 | -6.14 | 4.65 | 56.25 | 3/3 | 8/13 | 82.88 | 171.72 | 9.20 |
| day_of_week=TUESDAY & month=1 | 45min | COMPRA | 540 | 360 | 2.71 | nao | 2.65 | 1 | 240.84 | 232.02 | 232.02 | 4.22 | -6.14 | 4.32 | 57.78 | 3/3 | 3/3 | 84.96 | 379.08 | 8.82 |
| mtf_H1=BULLISH | 255min | COMPRA | 12,959 | 7,402 | 2.34 | nao | 1.79 | 1 | 154.84 | 145.55 | 145.55 | 4.15 | -53.60 | 6.70 | 52.40 | 3/3 | 21/34 | 357.31 | -66.21 | 9.29 |
| atr_ratio_prev=Q4 | 45min | COMPRA | 7,643 | 5,213 | 2.54 | nao | 2.37 | 1 | 76.42 | 67.78 | 67.78 | 4.12 | -6.14 | 4.75 | 52.48 | 3/3 | 25/34 | 128.48 | 7.10 | 8.64 |
| news_state=NONE_60M & atr_ratio_prev=Q4 | 20min | COMPRA | 5,582 | 3,725 | 2.42 | nao | 3.78 | 1 | 62.43 | 53.38 | 53.38 | 4.12 | -0.56 | 4.32 | 52.72 | 3/3 | 23/34 | 98.96 | 7.82 | 9.06 |
| day_of_week=FRIDAY & atr_ratio_prev=Q4 | 45min | COMPRA | 1,431 | 918 | 2.09 | nao | 2.65 | 1 | 170.47 | 161.90 | 161.90 | 4.02 | -6.14 | 4.21 | 56.32 | 3/3 | 25/34 | 140.45 | 183.35 | 8.57 |
| mtf_M15=BULLISH & mtf_W1=BREAK_UP | 30min | COMPRA | 3,191 | 1,741 | 2.54 | nao | 3.60 | 2 | 103.97 | 94.79 | 94.79 | 4.01 | -5.86 | 4.34 | 54.74 | 2/3 | 7/13 | 54.51 | 135.04 | 9.17 |
| mtf_W1=BULLISH & atr_ratio_prev=Q4 | 45min | COMPRA | 5,754 | 1,616 | 2.19 | nao | 2.13 | 1 | 138.75 | 130.01 | 130.01 | 4.01 | -6.14 | 4.31 | 54.83 | 3/3 | 20/28 | 100.46 | 159.56 | 8.74 |

### M30 — modo `open`

- eventos: 32,361 (2024-01-22 a 2026-10-16); descoberta 19,370 (até 2025-09-10), validação 12,945 (a partir de 2025-09-11)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 58,683**; passaram no BH (q=5%) na descoberta: **15**; confirmadas na validação: **4**
- melhores N da descoberta que repetem na validação: top 100: 19.0%, top 1000: 12.3%, top 10000: 8.9%
- **placebo** (6 deslocamentos): top 100: 11.2% (máx 17.0%), top 1000: 12.6% (máx 18.3%), top 10000: 10.8% (máx 15.0%); BH: média 11.5 (máx 69); confirmadas: média 0.2 (máx 1)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 19,357 | 0.022 | 4.551 | 15.479 |
| 35min bruto | 19,357 | 0.026 | 4.295 | 18.116 |
| 45min bruto | 19,355 | 0.037 | 4.590 | 25.236 |
| 60min bruto | 18,938 | 0.045 | 4.212 | 31.021 |
| 90min bruto | 18,508 | 0.066 | 3.963 | 45.656 |
| 150min bruto | 17,658 | 0.112 | 3.765 | 77.051 |
| 270min bruto | 15,966 | 0.204 | 3.399 | 141.073 |

**M30/open: famílias distintas validadas: 461; com líquido positivo e significativo na validação (custo realista): 225.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=3 & news_min_to_next_high=Q4 | 270min | COMPRA | 239 | 116 | 2.08 | nao | 2.31 | 1 | 2,178.56 | 2,166.69 | 2,166.69 | 7.34 | -45.90 | 7.50 | 69.83 | 3/3 | 3/3 | 1,982.77 | 2,350.61 | 11.87 |
| day_of_week=TUESDAY & month=1 | 270min | COMPRA | 228 | 152 | 2.28 | nao | 2.41 | 1 | 1,389.47 | 1,380.11 | 1,380.11 | 7.33 | -45.90 | 7.55 | 74.34 | 3/3 | 3/3 | 521.53 | 2,238.69 | 9.35 |
| mtf_H1=BULLISH & atr_ratio_prev=Q2 | 270min | COMPRA | 1,503 | 947 | 2.16 | nao | 2.13 | 1 | 472.54 | 463.34 | 463.34 | 5.66 | -45.90 | 6.27 | 55.44 | 3/3 | 23/34 | 661.54 | 265.55 | 9.21 |
| day_of_week=TUESDAY & month=1 | 150min | COMPRA | 252 | 168 | 2.59 | nao | 2.51 | 1 | 818.55 | 809.32 | 809.32 | 5.54 | -13.74 | 5.62 | 64.29 | 3/3 | 3/3 | 310.35 | 1,308.28 | 9.24 |
| mtf_H1=BULLISH & atr_ratio_prev=Q2 | 150min | COMPRA | 1,535 | 1,022 | 2.39 | nao | 2.40 | 1 | 310.68 | 301.55 | 301.55 | 4.79 | -13.74 | 5.09 | 56.26 | 3/3 | 25/34 | 402.00 | 201.09 | 9.13 |
| mtf_M15=BULLISH & mtf_D1=BREAK_UP | 45min | COMPRA | 977 | 624 | 2.89 | nao | 3.94 | 1 | 217.03 | 207.77 | 207.77 | 4.19 | 8.55 | 4.07 | 57.21 | 3/3 | 13/20 | 162.30 | 253.23 | 9.26 |
| day_of_week=TUESDAY & month=1 | 90min | COMPRA | 264 | 176 | 2.66 | nao | 2.64 | 1 | 494.20 | 485.02 | 485.02 | 4.15 | -3.21 | 4.18 | 61.36 | 3/3 | 3/3 | 190.32 | 779.72 | 9.18 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 270min | COMPRA | 2,666 | 1,300 | 2.23 | nao | 2.12 | 1 | 327.01 | 317.57 | 317.57 | 4.08 | -45.90 | 4.83 | 57.00 | 3/3 | 18/28 | 414.79 | 220.36 | 9.44 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 150min | COMPRA | 2,955 | 1,460 | 2.15 | nao | 2.58 | 1 | 221.23 | 211.93 | 211.93 | 3.96 | -13.74 | 4.33 | 54.79 | 3/3 | 18/28 | 260.20 | 163.66 | 9.30 |
| day_of_week=TUESDAY & month=1 | 45min | COMPRA | 276 | 184 | 2.46 | nao | 3.51 | 1 | 315.18 | 306.06 | 306.06 | 3.94 | 8.55 | 3.82 | 59.78 | 3/3 | 3/3 | 150.67 | 461.44 | 9.12 |
| mtf_M15=BULLISH & mtf_W1=BREAK_UP | 60min | COMPRA | 1,610 | 870 | 2.85 | nao | 3.29 | 1 | 198.28 | 189.01 | 189.01 | 3.88 | -2.22 | 4.02 | 56.21 | 3/3 | 9/13 | 115.57 | 262.46 | 9.26 |
| mtf_M15=BULLISH & mtf_D1=BREAK_UP | 35min | COMPRA | 977 | 624 | 2.07 | nao | 4.12 | 1 | 170.40 | 161.14 | 161.14 | 3.76 | 3.99 | 3.71 | 57.37 | 3/3 | 13/20 | 135.13 | 187.14 | 9.26 |
| mtf_M15=BULLISH & mtf_D1=BREAK_UP | 30min | COMPRA | 977 | 624 | 2.47 | nao | 4.27 | 1 | 153.27 | 144.00 | 144.00 | 3.68 | -6.84 | 3.91 | 57.85 | 3/3 | 14/20 | 105.70 | 182.31 | 9.26 |
| day_of_week=MONDAY & mtf_W1=BREAK_UP | 270min | COMPRA | 722 | 338 | 2.17 | nao | 2.43 | 1 | 597.50 | 588.23 | 588.23 | 3.67 | -45.90 | 3.99 | 72.19 | 3/3 | 8/12 | 1,202.39 | -25.93 | 9.27 |
| mtf_H1=BULLISH & news_state=NONE_60M | 150min | COMPRA | 5,722 | 3,258 | 2.24 | nao | 2.39 | 1 | 146.13 | 136.96 | 136.96 | 3.59 | -13.74 | 4.34 | 53.22 | 3/3 | 21/34 | 343.36 | -69.44 | 9.18 |
| mtf_M15=BULLISH & mtf_D1=BREAK_UP | 60min | COMPRA | 953 | 613 | 2.08 | nao | 2.71 | 1 | 222.09 | 212.79 | 212.79 | 3.55 | -2.22 | 3.65 | 57.59 | 3/3 | 11/20 | 141.84 | 283.51 | 9.30 |
| mtf_M15=BULLISH & mtf_W1=BREAK_UP | 30min | COMPRA | 1,652 | 888 | 2.84 | nao | 4.02 | 1 | 117.82 | 108.60 | 108.60 | 3.55 | -6.84 | 3.82 | 55.29 | 3/3 | 8/13 | 55.64 | 161.56 | 9.22 |
| mtf_H1=BULLISH & news_state=NONE_60M | 270min | COMPRA | 5,439 | 3,075 | 2.00 | nao | 1.98 | 1 | 202.37 | 193.13 | 193.13 | 3.55 | -45.90 | 4.96 | 53.92 | 3/3 | 22/34 | 461.63 | -75.19 | 9.24 |
| news_min_since_last_high=Q2 & range_atr_prev=Q1 | 60min | COMPRA | 1,139 | 529 | 3.25 | nao | 2.26 | 1 | 210.79 | 198.36 | 198.36 | 3.41 | -2.22 | 3.47 | 52.74 | 3/3 | 24/34 | 349.32 | 47.98 | 12.43 |
| mtf_M15=BULLISH & mtf_W1=BREAK_UP | 45min | COMPRA | 1,652 | 888 | 2.96 | nao | 3.65 | 1 | 154.53 | 145.31 | 145.31 | 3.38 | 8.55 | 3.26 | 55.86 | 3/3 | 8/13 | 88.52 | 202.11 | 9.22 |
| news_state=NONE_60M & atr_ratio_prev=Q2 | 270min | COMPRA | 3,276 | 2,174 | 2.12 | nao | 1.65 | 1 | 204.96 | 195.80 | 195.80 | 3.37 | -45.90 | 4.36 | 53.04 | 3/3 | 23/34 | 322.07 | 69.53 | 9.16 |
| day_of_week=TUESDAY & month=1 | 60min | COMPRA | 270 | 180 | 2.63 | nao | 2.58 | 1 | 326.66 | 317.49 | 317.49 | 3.33 | -2.22 | 3.35 | 58.89 | 3/3 | 3/3 | 123.66 | 511.32 | 9.17 |
| mtf_M15=BULLISH & mtf_W1=BREAK_UP | 35min | COMPRA | 1,652 | 888 | 2.97 | nao | 3.71 | 1 | 122.72 | 113.49 | 113.49 | 3.31 | 3.99 | 3.24 | 54.84 | 3/3 | 7/13 | 64.61 | 162.38 | 9.22 |
| day_of_week=MONDAY & mtf_W1=BREAK_UP | 150min | COMPRA | 798 | 374 | 2.26 | nao | 2.97 | 1 | 353.02 | 343.86 | 343.86 | 3.29 | -13.74 | 3.44 | 67.11 | 3/3 | 9/12 | 677.60 | 10.13 | 9.15 |
| mtf_H1=BULLISH & atr_ratio_prev=Q2 | 90min | COMPRA | 1,557 | 1,059 | 2.01 | nao | 2.08 | 1 | 161.35 | 152.25 | 152.25 | 3.23 | -3.21 | 3.34 | 52.03 | 3/3 | 26/34 | 240.97 | 63.70 | 9.10 |

### H1 — modo `open`

- eventos: 31,777 (2021-04-27 a 2026-10-16); descoberta 19,043 (até 2024-08-20), validação 12,711 (a partir de 2024-08-21)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 60,317**; passaram no BH (q=5%) na descoberta: **12**; confirmadas na validação: **10**
- melhores N da descoberta que repetem na validação: top 100: 53.0%, top 1000: 26.2%, top 10000: 14.0%
- **placebo** (6 deslocamentos): top 100: 8.0% (máx 16.0%), top 1000: 8.8% (máx 15.4%), top 10000: 6.2% (máx 11.3%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 19,030 | 0.009 | 1.679 | 4.952 |
| 65min bruto | 19,030 | 0.008 | 1.315 | 4.324 |
| 75min bruto | 19,010 | 0.007 | 1.078 | 4.100 |
| 90min bruto | 18,985 | 0.008 | 0.932 | 4.224 |
| 120min bruto | 18,105 | 0.019 | 1.605 | 10.611 |
| 180min bruto | 17,195 | 0.027 | 1.393 | 15.020 |
| 300min bruto | 15,389 | 0.044 | 1.187 | 24.509 |

**H1/open: famílias distintas validadas: 456; com líquido positivo e significativo na validação (custo realista): 216.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_M15=BULLISH & gap=Y | 75min | COMPRA | 311 | 217 | 3.44 | nao | 4.60 | 1 | 359.75 | 350.39 | 350.39 | 4.03 | 25.31 | 3.75 | 61.75 | 6/6 | 44/60 | 132.67 | 566.11 | 9.36 |
| mtf_M30=BEARISH & news_min_since_last_high=Q2 | 180min | COMPRA | 134 | 325 | 2.25 | nao | 2.40 | 1 | 509.75 | 501.07 | 501.07 | 4.00 | 19.90 | 3.90 | 62.46 | 4/4 | 26/36 | 196.57 | 803.70 | 8.68 |
| mtf_D1=BEARISH & month=11 | 120min | COMPRA | 128 | 326 | 2.14 | nao | 3.33 | 1 | 212.81 | 204.29 | 204.29 | 3.99 | 15.87 | 3.60 | 60.74 | 4/4 | 4/4 | 194.14 | 214.43 | 8.52 |
| atr_ratio_prev=Q5 & gap=Y | 120min | COMPRA | 281 | 129 | 2.15 | nao | 3.42 | 1 | 700.90 | 691.58 | 691.58 | 3.84 | 15.87 | 3.76 | 64.34 | 5/6 | 31/41 | 198.57 | 1,177.00 | 9.32 |
| news_state=NONE_60M & news_min_since_last_high=Q2 | 180min | COMPRA | 273 | 595 | 2.98 | nao | 2.06 | 1 | 281.46 | 272.77 | 272.77 | 3.76 | 19.90 | 3.53 | 57.82 | 4/4 | 30/37 | 168.13 | 377.06 | 8.69 |
| mtf_M15=BULLISH & gap=Y | 65min | COMPRA | 311 | 217 | 3.85 | nao | 4.85 | 1 | 320.47 | 311.11 | 311.11 | 3.75 | 11.92 | 3.63 | 61.75 | 5/6 | 43/60 | 128.65 | 491.89 | 9.36 |
| news_min_since_last_high=Q2 | 180min | COMPRA | 394 | 904 | 2.98 | nao | 2.38 | 1 | 233.70 | 225.10 | 225.10 | 3.69 | 19.90 | 3.45 | 55.97 | 4/4 | 30/37 | 132.55 | 317.66 | 8.60 |
| session=OFF_SESSION & news_min_to_next_high=Q4 | 90min | COMPRA | 213 | 603 | 2.07 | nao | 3.23 | 1 | 199.74 | 190.39 | 190.39 | 3.66 | 16.80 | 3.37 | 57.21 | 4/4 | 27/37 | 77.09 | 303.31 | 9.35 |
| mtf_M15=BULLISH & gap=Y | 90min | COMPRA | 310 | 217 | 3.39 | nao | 3.55 | 1 | 350.59 | 341.23 | 341.23 | 3.52 | 16.80 | 3.36 | 62.21 | 6/6 | 47/60 | 120.36 | 560.08 | 9.36 |
| session=OFF_SESSION & news_min_to_next_high=Q4 | 120min | COMPRA | 213 | 603 | 2.40 | nao | 2.54 | 1 | 221.15 | 211.80 | 211.80 | 3.50 | 15.87 | 3.29 | 56.22 | 4/4 | 28/37 | 72.63 | 350.52 | 9.35 |
| news_min_to_next_high=Q4 & news_min_since_last_high=Q2 | 120min | COMPRA | 145 | 342 | 2.09 | nao | 2.23 | 1 | 256.84 | 248.08 | 248.08 | 3.48 | 15.87 | 3.26 | 57.89 | 4/4 | 29/35 | 129.34 | 366.82 | 8.76 |
| session=OFF_SESSION & mtf_M15=BULLISH | 75min | COMPRA | 533 | 370 | 3.46 | nao | 3.79 | 1 | 231.64 | 222.30 | 222.30 | 3.42 | 25.31 | 3.06 | 58.65 | 5/6 | 45/67 | 69.17 | 375.43 | 9.34 |
| news_min_since_last_high=Q2 & atr_ratio_prev=Q5 | 180min | COMPRA | 159 | 258 | 2.16 | nao | 2.14 | 1 | 487.61 | 478.95 | 478.95 | 3.32 | 19.90 | 3.22 | 58.91 | 4/4 | 21/29 | 262.88 | 695.02 | 8.66 |
| mtf_M15=BULLISH & gap=Y | 60min | COMPRA | 311 | 217 | 2.39 | nao | 5.07 | 1 | 300.01 | 290.65 | 290.65 | 3.32 | 3.07 | 3.31 | 62.67 | 5/6 | 40/60 | 119.61 | 460.12 | 9.36 |
| mtf_M1=BEARISH & news_min_since_last_high=Q2 | 65min | COMPRA | 181 | 495 | 2.45 | nao | 3.39 | 1 | 189.30 | 180.80 | 180.80 | 3.30 | 11.92 | 3.13 | 55.96 | 4/4 | 27/37 | 39.90 | 321.13 | 8.50 |
| session=OFF_SESSION & mtf_M15=BULLISH | 65min | COMPRA | 533 | 370 | 3.79 | nao | 3.91 | 1 | 205.54 | 196.20 | 196.20 | 3.29 | 11.92 | 3.12 | 57.03 | 6/6 | 44/67 | 61.46 | 330.94 | 9.34 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 120min | COMPRA | 2,223 | 1,865 | 2.03 | nao | 3.14 | 2 | 108.46 | 99.90 | 99.90 | 3.24 | 15.87 | 2.77 | 54.26 | 6/6 | 34/56 | 57.19 | 142.58 | 8.56 |
| hour=11 & structure_before=BULLISH | 65min | COMPRA | 311 | 232 | 2.06 | nao | 2.58 | 4 | 188.46 | 180.40 | 180.40 | 3.20 | 11.92 | 2.98 | 56.90 | 4/6 | 39/64 | 99.66 | 261.14 | 8.06 |
| month=6 & atr_ratio_prev=Q2 | 120min | VENDA | 342 | 223 | -2.02 | nao | -2.07 | 1 | 389.32 | 380.80 | 380.74 | 3.19 | -32.95 | 3.49 | 56.95 | 5/6 | 5/6 | -9.72 | 767.72 | 8.58 |
| day_of_week=WEDNESDAY & session=OFF_SESSION | 120min | COMPRA | 287 | 188 | 2.42 | nao | 2.63 | 1 | 350.24 | 340.87 | 340.87 | 3.19 | 15.87 | 3.04 | 63.83 | 5/6 | 34/52 | 170.25 | 511.48 | 9.37 |
| session=OFF_SESSION & mtf_M15=BULLISH | 60min | COMPRA | 533 | 370 | 2.82 | nao | 4.42 | 1 | 195.60 | 186.26 | 186.26 | 3.18 | 3.07 | 3.16 | 57.30 | 5/6 | 41/67 | 72.99 | 299.53 | 9.34 |
| gap=Y | 90min | COMPRA | 848 | 557 | 3.08 | nao | 2.83 | 1 | 214.64 | 205.29 | 205.29 | 3.14 | 16.80 | 2.94 | 56.91 | 5/6 | 39/66 | 63.97 | 346.10 | 9.35 |
| news_min_to_next_high=Q4 & news_min_since_last_high=Q2 | 90min | COMPRA | 145 | 342 | 2.48 | nao | 2.65 | 1 | 212.40 | 203.64 | 203.64 | 3.14 | 16.80 | 2.89 | 59.36 | 4/4 | 27/35 | 100.68 | 306.59 | 8.76 |
| session=OFF_SESSION & gap=Y | 90min | COMPRA | 847 | 556 | 3.07 | nao | 2.82 | 1 | 214.80 | 205.45 | 205.45 | 3.14 | 16.80 | 2.94 | 56.83 | 5/6 | 39/66 | 63.97 | 346.94 | 9.35 |
| session=OFF_SESSION & news_min_to_next_high=Q4 | 75min | COMPRA | 214 | 603 | 2.95 | nao | 3.16 | 1 | 168.48 | 159.13 | 159.13 | 3.14 | 25.31 | 2.68 | 57.38 | 4/4 | 26/37 | 50.58 | 267.33 | 9.35 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **1434**
- com líquido positivo e t>1,645 na validação, custo realista: **665**; dessas, sobreviveram ao BH: **8**; e positivas nas duas metades da validação: **7**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H1 | open | session=OFF_SESSION & gap=Y | 60min | COMPRA | 556 | 170.31 | 3.07 | 2.86 | 2.83 | 56.83 | 5/6 | 40/66 |
| M30 | open | mtf_M15=BULLISH | 45min | COMPRA | 4,513 | 55.00 | 8.55 | 2.74 | 2.81 | 50.30 | 3/3 | 23/34 |
| H1 | open | session=OFF_SESSION & news_min_to_next_high=Q4 | 60min | COMPRA | 603 | 113.11 | 3.07 | 2.35 | 2.37 | 55.06 | 4/4 | 25/37 |
| H1 | open | mtf_M30=BEARISH & gap=Y | 60min | COMPRA | 215 | 180.68 | 3.07 | 1.87 | 1.89 | 58.60 | 5/6 | 47/64 |
| H1 | open | range_atr_prev=Q1 & gap=Y | 60min | COMPRA | 323 | 110.24 | 3.07 | 1.84 | 1.88 | 57.59 | 4/6 | 40/66 |
| H1 | open | news_min_to_next_high=Q4 & gap=Y | 60min | COMPRA | 353 | 125.13 | 3.07 | 1.71 | 1.73 | 56.37 | 4/4 | 25/37 |
| H1 | open | day_of_week=WEDNESDAY & session=OFF_SESSION | 60min | COMPRA | 188 | 147.48 | 3.07 | 1.67 | 1.70 | 60.64 | 6/6 | 38/53 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 222s)_
