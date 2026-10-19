# NZDUSD — relatório completo MBA (gerado em 2026-10-17 01:38)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | First Prudential Markets Limited |
| servidor | FPMarketsSC-Demo |
| simbolo | NZDUSD.r |
| descricao | New Zealand Dollar vs US Dollar |
| digitos | 5 |
| ponto | 0.00001 |
| tick_size | 0.00001 |
| tick_value | 1.00000 |
| contrato | 100,000.00000 |
| lote_min | 0.01000 |
| swap_long | -4.54000 |
| swap_short | 0.46000 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-01-22 00:25 | 2026-10-16 23:58 | 210 | 1,160,532 | 0 | 123,576 | 123,576 | 0 |
| M5 | 106,504 | 2025-05-15 03:25 | 2026-10-16 23:50 | 78 | 577 | 0 | 24,746 | 24,746 | 0 |
| M15 | 68,224 | 2024-01-22 05:30 | 2026-10-16 23:30 | 149 | 196 | 0 | 8,248 | 8,248 | 0 |
| M30 | 34,102 | 2024-01-22 11:00 | 2026-10-16 23:00 | 148 | 98 | 0 | 4,123 | 4,123 | 0 |
| H1 | 33,575 | 2021-05-26 23:00 | 2026-10-16 22:00 | 286 | 96 | 0 | 2,061 | 2,061 | 0 |
| H4 | 8,377 | 2021-05-31 20:00 | 2026-10-16 16:00 | 284 | 24 | 0 | 514 | 514 | 0 |
| D1 | 1,377 | 2021-06-28 00:00 | 2026-10-15 00:00 | 280 | 4 | 0 | 84 | 84 | 0 |
| W1 | 258 | 2021-10-31 00:00 | 2026-10-04 00:00 | 0 | 0 | 0 | 16 | 16 | 0 |
| MN1 | 42 | 2023-04-01 00:00 | 2026-09-01 00:00 | 0 | 0 | 0 | 3 | 3 | 0 |

Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).

## 3. Custo e microestrutura (base M5)

Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.

| hora_utc | spread_med | spread_p90 | spread_max | range_med_pts | atr_med_pts | ticks_vol_med | n | spread_ticks_med | pct_barras_spread0 | custo_sobre_ATR |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 2.00 | 3.00 | 5.00 | 23.00 | 20.50 | 137.00 | 4,435 | 3.46 | 4.08 | 0.17 |
| 1 | 2.00 | 3.00 | 5.00 | 27.00 | 26.29 | 155.00 | 4,440 | 3.46 | 4.30 | 0.13 |
| 2 | 2.00 | 3.00 | 23.00 | 22.00 | 26.29 | 124.00 | 4,440 | 3.47 | 8.51 | 0.13 |
| 3 | 2.00 | 3.00 | 4.00 | 19.00 | 21.93 | 106.00 | 4,440 | 3.48 | 10.52 | 0.16 |
| 4 | 1.00 | 3.00 | 7.00 | 17.00 | 19.29 | 92.00 | 4,440 | 3.50 | 11.53 | 0.18 |
| 5 | 2.00 | 3.00 | 4.00 | 19.00 | 18.71 | 110.00 | 4,440 | 3.50 | 8.49 | 0.19 |
| 6 | 2.00 | 3.00 | 4.00 | 24.00 | 22.93 | 148.00 | 4,440 | 3.38 | 8.72 | 0.15 |
| 7 | 2.00 | 3.00 | 4.00 | 26.00 | 26.71 | 162.00 | 4,440 | 3.30 | 9.32 | 0.12 |
| 8 | 2.00 | 3.00 | 4.00 | 26.00 | 27.71 | 152.00 | 4,440 | 3.29 | 11.24 | 0.12 |
| 9 | 1.00 | 3.00 | 21.00 | 22.00 | 25.07 | 135.00 | 4,440 | 3.27 | 13.27 | 0.13 |
| 10 | 1.00 | 3.00 | 28.00 | 20.00 | 21.79 | 119.00 | 4,440 | 3.29 | 15.23 | 0.15 |
| 11 | 1.00 | 3.00 | 4.00 | 21.00 | 21.29 | 126.00 | 4,440 | 3.28 | 15.90 | 0.15 |
| 12 | 1.00 | 3.00 | 43.00 | 26.00 | 24.71 | 167.00 | 4,440 | 3.29 | 10.00 | 0.13 |
| 13 | 2.00 | 3.00 | 5.00 | 31.00 | 30.43 | 219.00 | 4,431 | 3.26 | 6.16 | 0.11 |
| 14 | 2.00 | 3.00 | 28.00 | 33.00 | 34.79 | 240.00 | 4,438 | 3.19 | 5.02 | 0.09 |
| 15 | 2.00 | 3.00 | 5.00 | 29.00 | 33.79 | 204.00 | 4,440 | 3.19 | 9.68 | 0.09 |
| 16 | 2.00 | 3.00 | 6.00 | 22.00 | 27.14 | 156.00 | 4,440 | 3.21 | 8.38 | 0.12 |
| 17 | 2.00 | 3.00 | 5.00 | 19.00 | 21.71 | 125.00 | 4,440 | 3.51 | 13.51 | 0.16 |
| 18 | 2.00 | 3.00 | 6.00 | 17.00 | 18.93 | 105.00 | 4,440 | 4.04 | 15.02 | 0.21 |
| 19 | 2.00 | 3.00 | 28.00 | 15.00 | 16.71 | 80.00 | 4,438 | 4.78 | 16.47 | 0.29 |
| 20 | 2.00 | 5.00 | 229.00 | 13.00 | 14.93 | 62.00 | 4,439 | 5.59 | 13.13 | 0.37 |
| 21 | 18.00 | 77.00 | 554.00 | 28.00 | 32.21 | 55.00 | 4,427 | 69.13 | 0.16 | 2.15 |
| 22 | 3.00 | 21.00 | 350.00 | 16.00 | 32.07 | 68.00 | 4,428 | 5.28 | 4.34 | 0.16 |
| 23 | 2.00 | 3.00 | 112.00 | 15.00 | 16.64 | 74.00 | 4,428 | 3.71 | 8.15 | 0.22 |

Spread geral (mediana M5): **2.0 pts**, p90 3.0, máx 554. ATR mediano M5: **23.9 pts**. Razão spread/ATR: **0.08**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 274 | 569.81 | 67.48 | 351.24 | 56.20 | 3.18 |
| ter | 276 | 614.82 | 11.94 | 362.80 | 51.45 | 0.55 |
| qua | 275 | 680.43 | 38.32 | 413.08 | 53.45 | 1.54 |
| qui | 275 | 648.36 | 27.41 | 393.83 | 53.45 | 1.15 |
| sex | 276 | 636.02 | -8.78 | 436.53 | 52.90 | -0.33 |
| sab | 1 | 146.00 | -86.00 |  | 0.00 |  |

Autocorrelação do retorno diário (lags 1-5): +0.017, -0.033, +0.018, +0.049, +0.023 (banda ±0.054). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.077, +0.051, +0.079.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 1,399 | 0 | -0.024 | -1.352 | nao |
| 1,398 | 1 | 0.017 | 0.880 | nao |
| 1,399 | 2 | 0.013 | 0.714 | nao |
| 1,399 | 3 | -0.026 | -1.700 | nao |
| 1,399 | 4 | -0.015 | -1.085 | nao |
| 1,399 | 5 | -0.026 | -1.728 | nao |
| 1,399 | 6 | 0.020 | 1.104 | nao |
| 1,399 | 7 | 0.000 | 0.010 | nao |
| 1,399 | 8 | 0.005 | 0.251 | nao |
| 1,399 | 9 | -0.016 | -0.940 | nao |
| 1,399 | 10 | -0.026 | -1.712 | nao |
| 1,399 | 11 | -0.012 | -0.699 | nao |
| 1,399 | 12 | -0.018 | -0.674 | nao |
| 1,399 | 13 | 0.022 | 0.846 | nao |
| 1,399 | 14 | 0.010 | 0.419 | nao |
| 1,399 | 15 | -0.026 | -1.243 | nao |
| 1,399 | 16 | -0.028 | -1.965 | nao |
| 1,399 | 17 | -0.000 | -0.029 | nao |
| 1,399 | 18 | 0.003 | 0.165 | nao |
| 1,399 | 19 | 0.024 | 1.722 | nao |
| 1,399 | 20 | -0.103 | -8.903 | sim |
| 1,399 | 21 | 0.160 | 11.060 | sim |
| 1,399 | 22 | 0.187 | 13.531 | sim |
| 1,399 | 23 | 0.045 | 3.633 | sim |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 6,676 | 0 | 0.017 | 2.245 | sim |
| 6,718 | 1 | 0.006 | 0.688 | nao |
| 6,699 | 2 | 0.006 | 0.686 | nao |
| 6,724 | 3 | 0.007 | 0.909 | nao |
| 6,012 | 4 | -0.021 | -2.390 | sim |
| 746 | 6 | 0.206 | 9.812 | sim |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,598 | 1 | 0.013 | 0.966 | nao |
| 2,424 | 2 | 0.013 | 0.992 | nao |
| 2,646 | 3 | 0.004 | 0.286 | nao |
| 2,568 | 4 | 0.006 | 0.452 | nao |
| 2,737 | 5 | 0.027 | 2.095 | nao |
| 3,099 | 6 | -0.008 | -0.668 | nao |
| 3,189 | 7 | 0.004 | 0.293 | nao |
| 3,171 | 8 | 0.020 | 1.667 | nao |
| 3,117 | 9 | -0.004 | -0.352 | nao |
| 2,927 | 10 | 0.004 | 0.339 | nao |
| 2,564 | 11 | 0.017 | 1.308 | nao |
| 2,535 | 12 | 0.004 | 0.344 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 121 combinações testadas):

| dia(0=seg) | hora_utc | n | ret_medio_ATR | std | t |
|---|---|---|---|---|---|
| 6 | 21 | 190 | 0.347 | 0.555 | 8.618 |
| 3 | 22 | 282 | 0.168 | 0.404 | 6.991 |
| 1 | 21 | 280 | 0.208 | 0.516 | 6.738 |
| 0 | 21 | 278 | 0.233 | 0.582 | 6.677 |
| 1 | 22 | 279 | 0.194 | 0.513 | 6.325 |
| 4 | 20 | 281 | -0.159 | 0.438 | -6.073 |
| 0 | 22 | 280 | 0.190 | 0.536 | 5.934 |
| 4 | 21 | 91 | -0.272 | 0.437 | -5.931 |
| 6 | 22 | 278 | 0.216 | 0.622 | 5.802 |
| 2 | 22 | 280 | 0.168 | 0.495 | 5.691 |
| 0 | 20 | 278 | -0.115 | 0.433 | -4.417 |
| 3 | 21 | 280 | 0.118 | 0.499 | 3.943 |
| 1 | 20 | 280 | -0.082 | 0.394 | -3.483 |
| 2 | 21 | 280 | 0.098 | 0.506 | 3.235 |
| 6 | 23 | 278 | 0.098 | 0.509 | 3.220 |
| 3 | 20 | 280 | -0.078 | 0.436 | -3.011 |

Autocorrelação do retorno H1, lags 1-10: -0.011, -0.002, -0.001, +0.009, +0.016, -0.008, +0.005, -0.005, -0.004, +0.005 (banda ±0.011). |retorno|: +0.084, +0.031, +0.003, -0.052, +0.085 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 191 | -0.069 | -0.995 | 49.738 |
| barra < -2 ATR | 169 | 0.024 | 0.355 | 49.112 |
| barra > +1 ATR | 1,837 | -0.002 | -0.117 | 50.572 |
| barra < -1 ATR | 1,815 | 0.014 | 0.806 | 50.964 |
| gap (barra ausente antes) | 286 | 0.278 | 8.090 | 67.832 |

Distribuição do retorno H1 em ATR: média +0.0079, desvio 0.663, assimetria -0.05, curtose 4.2; barras |ret|>2 ATR: 1.07%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 3.4 pts, máxima 121.4 pts no slot NY 17:00 de domingo; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | 106,047 | 210,558 | 222 | 123 | 0.0 | 0.0 | 0 | 56.0 | 5.5 |
| M15 | ret | 67,132 | 218,176 | 724 | 387 | 0.0 | 0.0 | 0 | 69.0 | 11.0 |
| M30 | ret | 33,093 | 187,319 | 630 | 381 | 2.2 | 0.2 | 1 | 69.0 | 9.2 |
| H1 | ret | 31,456 | 188,271 | 2,082 | 1,508 | 1.7 | 0.0 | 0 | 98.0 | 9.7 |
| M5 | hit | 106,047 | 630,414 | 13 | 0 | 7.8 | 0.0 | 0 | 1.0 | 3.5 |
| M15 | hit | 67,132 | 647,910 | 4 | 0 | 0.2 | 0.0 | 0 | 4.0 | 3.2 |
| M30 | hit | 33,093 | 555,810 | 2 | 0 | 0.0 | 0.0 | 0 | 2.0 | 1.3 |
| H1 | hit | 31,456 | 557,178 | 12 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.8 |


## 6.1 Modo `ret`

### M5 — modo `ret`

- eventos: 106,047 (2025-05-15 a 2026-10-16); descoberta 63,340 (até 2026-03-24), validação 42,419 (a partir de 2026-03-25)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 210,558**; passaram no BH (q=5%) na descoberta: **222**; confirmadas na validação: **123**
- melhores N da descoberta que repetem na validação: top 100: 56.0%, top 1000: 44.6%, top 10000: 19.9%
- **placebo** (6 deslocamentos): top 100: 5.5% (máx 13.0%), top 1000: 4.2% (máx 7.0%), top 10000: 3.4% (máx 4.4%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,340 | 0.001 | 0.275 | 0.020 |
| 15min bruto | 63,007 | 0.005 | 0.513 | 0.109 |
| 30min bruto | 62,525 | 0.007 | 0.404 | 0.173 |
| 60min bruto | 61,574 | 0.011 | 0.303 | 0.269 |
| 120min bruto | 59,699 | -0.004 | -0.046 | -0.086 |
| 240min bruto | 55,994 | -0.042 | -0.258 | -1.013 |

**M5/ret: famílias distintas validadas: 1234; com líquido positivo e significativo na validação (custo realista): 24.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hour=13 & news_min_to_next_high=Q1 | 60min | COMPRA | 1,346 | 760 | 2.61 | nao | 1.90 | 1 | 19.01 | 15.75 | 15.75 | 5.21 | -6.12 | 7.33 | 59.34 | 2/2 | 13/18 | 19.92 | 11.58 | 3.26 |
| session=OFF_SESSION & prev_day_low_distance_atr=Q1 | 60min | COMPRA | 700 | 345 | 2.38 | nao | 1.66 | 1 | 17.31 | 12.19 | 12.19 | 4.82 | -6.12 | 7.24 | 57.97 | 1/2 | 9/18 | 18.53 | 5.90 | 5.12 |
| session=LONDON_NY_OVERLAP & news_min_to_next_high=Q1 | 60min | COMPRA | 3,505 | 1,606 | 2.59 | nao | 1.88 | 1 | 11.80 | 8.58 | 8.58 | 4.37 | -6.12 | 7.69 | 52.24 | 2/2 | 12/18 | 13.50 | 3.66 | 3.23 |
| news_state=EVENTS_4_AROUND_60M & price_position_monthly_open=Q1 | 30min | VENDA | 397 | 445 | -2.04 | nao | -2.40 | 1 | 20.49 | 16.55 | 13.80 | 4.18 | -5.87 | 6.00 | 53.48 | 1/2 | 5/8 | 4.36 | 23.21 | 6.69 |
| mtf_W1=BREAK_DOWN & prev_day_low_distance_atr=Q2 | 60min | COMPRA | 555 | 490 | 2.14 | nao | 2.20 | 1 | 22.49 | 12.66 | 12.66 | 4.16 | -6.12 | 6.21 | 55.10 | 2/2 | 5/6 | 27.34 | -2.02 | 9.83 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 30min | COMPRA | 223 | 111 | 2.80 | nao | 1.99 | 1 | 24.34 | 21.08 | 21.08 | 4.04 | -6.22 | 5.21 | 61.26 | 2/2 | 11/14 | 20.59 | 21.57 | 3.26 |
| hour=22 & mtf_M15=BEARISH | 30min | COMPRA | 1,053 | 777 | 2.58 | nao | 2.99 | 1 | 10.10 | 4.63 | 4.63 | 3.53 | -6.22 | 8.30 | 49.94 | 0/2 | 9/18 | 7.47 | 1.79 | 5.48 |
| session=NEW_YORK & news_state=EVENTS_4_AROUND_60M | 60min | VENDA | 597 | 518 | -2.11 | nao | -2.01 | 1 | 26.53 | 21.89 | 12.17 | 3.49 | -5.33 | 5.05 | 47.10 | 1/2 | 8/17 | 15.17 | 9.17 | 14.36 |
| hour=22 & previous_high_distance_atr=Q1 | 30min | COMPRA | 181 | 81 | 2.94 | nao | 1.83 | 1 | 16.44 | 11.33 | 11.33 | 3.41 | -6.22 | 5.25 | 66.67 | 0/2 | 5/12 | 20.15 | 2.73 | 5.11 |
| hour=22 & mtf_W1=BULLISH | 30min | COMPRA | 1,044 | 216 | 3.69 | nao | 2.14 | 1 | 14.87 | 9.65 | 9.65 | 3.24 | -6.22 | 5.33 | 58.33 | 1/2 | 3/8 | 5.65 | 13.66 | 5.21 |
| news_state=EVENTS_4_AROUND_60M | 60min | VENDA | 1,326 | 1,087 | -2.06 | nao | -1.95 | 1 | 16.27 | 12.29 | 7.67 | 3.20 | -5.33 | 5.53 | 47.56 | 1/2 | 11/18 | 2.15 | 13.18 | 8.60 |
| hour=22 & atr_ratio=Q5 | 60min | COMPRA | 1,221 | 926 | 3.69 | nao | 1.71 | 1 | 13.72 | 7.99 | 7.99 | 3.19 | -6.12 | 5.72 | 49.14 | 0/2 | 9/18 | 16.35 | -0.37 | 5.73 |
| session=OFF_SESSION & atr_ratio=Q5 | 60min | COMPRA | 1,662 | 1,009 | 3.09 | nao | 1.88 | 1 | 13.24 | 7.68 | 7.68 | 3.16 | -6.12 | 5.78 | 50.45 | 0/2 | 8/18 | 15.56 | -0.19 | 5.57 |
| mtf_D1=BEARISH & news_state=EVENTS_4_AROUND_60M | 30min | VENDA | 564 | 335 | -2.19 | nao | -2.13 | 1 | 20.66 | 15.71 | 10.71 | 2.91 | -5.87 | 4.53 | 48.06 | 1/2 | 8/14 | 20.28 | 1.20 | 9.95 |
| hour=16 & price_position_daily_open=Q2 | 30min | COMPRA | 368 | 212 | 2.77 | nao | 1.65 | 1 | 12.53 | 9.26 | 9.26 | 2.64 | -6.22 | 4.41 | 56.13 | 2/2 | 15/18 | 9.13 | 9.40 | 3.27 |
| hour=22 & previous_high_distance_atr=Q1 | 15min | COMPRA | 181 | 81 | 4.14 | sim | 3.03 | 1 | 11.62 | 6.51 | 6.51 | 2.53 | -6.42 | 5.00 | 53.09 | 0/2 | 5/12 | 9.98 | 3.12 | 5.11 |
| mtf_W1=BREAK_DOWN & prev_day_low_distance_atr=Q2 | 30min | COMPRA | 555 | 496 | 2.27 | nao | 2.56 | 1 | 17.32 | 6.90 | 6.90 | 2.50 | -6.22 | 4.79 | 54.03 | 1/2 | 3/6 | 16.17 | -2.37 | 10.42 |
| hour=22 & cum10=Q1 | 30min | COMPRA | 331 | 47 | 3.70 | nao | 1.72 | 1 | 14.87 | 9.66 | 9.66 | 2.47 | -6.22 | 4.02 | 61.70 | 0/2 | 2/11 | 27.04 | -6.99 | 5.21 |
| hour=22 & price_position_monthly_open=Q4 | 30min | COMPRA | 541 | 193 | 2.62 | nao | 1.86 | 1 | 13.45 | 8.10 | 8.10 | 2.33 | -6.22 | 4.12 | 54.92 | 0/2 | 7/13 | 13.60 | 2.65 | 5.35 |
| news_state=EVENTS_4_AROUND_60M & price_position_weekly_open=Q1 | 30min | VENDA | 443 | 506 | -2.00 | nao | -2.18 | 1 | 14.56 | 9.83 | 5.70 | 2.16 | -5.87 | 4.42 | 50.59 | 2/2 | 7/17 | -6.03 | 17.44 | 8.85 |
| hour=22 & price_position_daily_open=Q4 | 30min | COMPRA | 484 | 624 | 2.45 | nao | 2.08 | 1 | 9.50 | 4.22 | 4.22 | 2.13 | -6.22 | 5.32 | 51.12 | 1/2 | 6/18 | 10.92 | -2.48 | 5.28 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 15min | COMPRA | 223 | 111 | 2.69 | nao | 1.85 | 1 | 10.91 | 7.65 | 7.65 | 2.03 | -6.42 | 3.73 | 51.35 | 2/2 | 11/14 | 5.95 | 9.32 | 3.26 |
| hour=22 & atr_ratio=Q5 | 30min | COMPRA | 1,221 | 934 | 4.07 | sim | 2.38 | 1 | 8.87 | 3.14 | 3.14 | 1.88 | -6.22 | 5.69 | 46.47 | 0/2 | 5/18 | 8.05 | -1.77 | 5.73 |
| hour=22 & cum10=Q1 | 15min | COMPRA | 331 | 47 | 4.01 | nao | 2.40 | 1 | 9.81 | 4.60 | 4.60 | 1.73 | -6.42 | 4.09 | 53.19 | 0/2 | 2/11 | 13.26 | -3.70 | 5.21 |

### M15 — modo `ret`

- eventos: 67,132 (2024-01-22 a 2026-10-16); descoberta 40,184 (até 2025-09-15), validação 26,853 (a partir de 2025-09-16)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 218,176**; passaram no BH (q=5%) na descoberta: **724**; confirmadas na validação: **387**
- melhores N da descoberta que repetem na validação: top 100: 69.0%, top 1000: 51.2%, top 10000: 21.2%
- **placebo** (6 deslocamentos): top 100: 11.0% (máx 31.0%), top 1000: 8.2% (máx 10.7%), top 10000: 6.3% (máx 7.3%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 40,184 | 0.008 | 2.784 | 0.332 |
| 15min bruto | 39,397 | 0.007 | 1.640 | 0.286 |
| 30min bruto | 38,443 | 0.010 | 1.241 | 0.446 |
| 60min bruto | 36,690 | 0.012 | 0.709 | 0.540 |
| 120min bruto | 33,766 | 0.006 | 0.150 | 0.245 |
| 240min bruto | 29,892 | -0.018 | -0.226 | -0.802 |

**M15/ret: famílias distintas validadas: 1803; com líquido positivo e significativo na validação (custo realista): 21.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H4=BEARISH & month=10 | 240min | VENDA | 967 | 758 | -2.01 | nao | -1.90 | 1 | 36.56 | 30.78 | 32.39 | 6.49 | -4.95 | 7.61 | 54.75 | 3/3 | 3/3 | 49.92 | 14.87 | 4.17 |
| day_of_week=MONDAY & session=OFF_SESSION | 120min | VENDA | 632 | 445 | -2.05 | nao | -1.88 | 1 | 19.09 | 7.20 | 15.60 | 3.85 | -5.43 | 5.22 | 60.67 | 3/3 | 22/34 | 10.46 | 20.72 | 3.49 |
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | 120min | COMPRA | 374 | 376 | 2.07 | nao | 1.94 | 1 | 22.88 | 16.34 | 16.34 | 3.68 | -6.25 | 5.11 | 56.91 | 2/3 | 7/9 | 24.42 | 8.26 | 6.54 |
| slot_hhmm=13:45 & mtf_H4=BULLISH | 30min | COMPRA | 129 | 86 | 2.15 | nao | 2.74 | 1 | 23.66 | 20.43 | 20.43 | 3.45 | -6.16 | 4.48 | 60.47 | 3/3 | 21/24 | 16.24 | 24.63 | 3.23 |
| hour=10 & session_high_distance_atr=Q1 | 60min | COMPRA | 245 | 169 | 2.31 | nao | 1.87 | 1 | 29.01 | 25.66 | 25.66 | 3.20 | -6.01 | 3.96 | 60.36 | 3/3 | 24/33 | 19.47 | 31.77 | 3.35 |
| hour=6 & price_position_daily_open=Q1 | 30min | COMPRA | 307 | 184 | 2.19 | nao | 2.49 | 1 | 13.16 | 9.77 | 9.77 | 2.66 | -6.16 | 4.34 | 58.70 | 3/3 | 21/31 | 11.57 | 7.96 | 3.40 |
| slot_hhmm=22:45 & streak=-1 | 15min | COMPRA | 131 | 83 | 2.11 | nao | 4.55 | 1 | 17.46 | 9.59 | 9.59 | 2.60 | -6.33 | 4.29 | 62.65 | 2/3 | 12/25 | 15.55 | 3.77 | 7.87 |
| hour=13 & news_state=EVENTS_2_AROUND_60M | 30min | COMPRA | 178 | 125 | 2.79 | nao | 2.16 | 1 | 15.09 | 11.84 | 11.84 | 2.45 | -6.16 | 3.73 | 58.40 | 3/3 | 20/27 | 12.08 | 11.61 | 3.25 |
| slot_hhmm=22:45 & cost_atr=Q5 | 15min | COMPRA | 237 | 107 | 2.87 | nao | 6.05 | 1 | 19.98 | 8.09 | 8.09 | 2.34 | -6.33 | 4.16 | 56.07 | 2/3 | 10/20 | 9.95 | 6.26 | 11.90 |
| mtf_D1=BEARISH & month=3 | 120min | VENDA | 565 | 1,593 | -2.20 | nao | -2.10 | 1 | 14.14 | 7.62 | 8.09 | 2.31 | -5.43 | 4.07 | 53.99 | 2/2 | 2/2 | 9.32 | 6.85 | 6.05 |
| hour=5 & price_position_monthly_open=Q3 | 30min | VENDA | 366 | 187 | -2.05 | nao | -2.56 | 1 | 9.93 | 6.44 | 6.47 | 2.27 | -5.97 | 4.36 | 56.68 | 3/3 | 18/26 | 8.51 | 4.45 | 3.46 |
| mtf_H1=BEARISH & price_position_monthly_open=Q3 | 60min | VENDA | 2,219 | 1,361 | -2.05 | nao | -2.52 | 1 | 9.27 | 2.02 | 4.15 | 2.24 | -5.63 | 5.43 | 50.40 | 3/3 | 20/32 | 3.96 | 4.34 | 5.12 |
| slot_hhmm=14:00 & mtf_H4=BULLISH | 15min | COMPRA | 129 | 85 | 3.91 | sim | 3.16 | 1 | 12.11 | 8.87 | 8.87 | 2.21 | -6.33 | 3.77 | 63.53 | 3/3 | 18/23 | 6.32 | 11.35 | 3.24 |
| slot_hhmm=22:45 & streak=-1 | 30min | COMPRA | 130 | 83 | 2.33 | nao | 2.82 | 1 | 16.02 | 8.16 | 8.16 | 2.19 | -6.16 | 3.82 | 63.86 | 3/3 | 14/25 | 11.33 | 5.06 | 7.87 |
| slot_hhmm=22:45 & streak=-1 | 5min | COMPRA | 134 | 83 | 3.91 | sim | 5.05 | 1 | 12.92 | 5.05 | 5.05 | 2.10 | -6.00 | 4.57 | 59.04 | 2/3 | 13/25 | 9.33 | 0.87 | 7.87 |
| slot_hhmm=18:15 & mtf_W1=BULLISH | 5min | COMPRA | 150 | 45 | 3.36 | nao | 2.85 | 1 | 11.04 | 7.28 | 7.28 | 2.09 | -6.00 | 3.78 | 64.44 | 2/3 | 9/15 | 7.60 | 6.98 | 3.76 |
| hour=10 & session_high_distance_atr=Q1 | 30min | COMPRA | 245 | 169 | 2.67 | nao | 1.96 | 1 | 15.67 | 12.32 | 12.32 | 2.01 | -6.16 | 3.03 | 55.62 | 3/3 | 20/33 | 2.23 | 22.29 | 3.35 |
| day_of_week=SUNDAY & close_position=Q2 | 60min | COMPRA | 158 | 120 | 2.27 | nao | 2.59 | 1 | 39.62 | 14.26 | 14.26 | 1.99 | -6.01 | 2.83 | 52.50 | 1/3 | 14/29 | 16.27 | 12.26 | 25.35 |
| slot_hhmm=14:30 & news_min_to_next_high=Q5 | 30min | VENDA | 127 | 83 | -2.03 | nao | -1.70 | 1 | 16.17 | 12.99 | 12.99 | 1.96 | -5.97 | 2.85 | 57.83 | 3/3 | 17/23 | 19.91 | 6.23 | 3.18 |
| slot_hhmm=14:30 & structure_at_close=BEARISH | 15min | COMPRA | 121 | 85 | 2.13 | nao | 2.76 | 1 | 10.07 | 6.88 | 6.88 | 1.89 | -6.33 | 3.61 | 57.65 | 2/3 | 15/22 | 10.95 | 2.90 | 3.19 |
| news_state=EVENTS_3_AROUND_60M & lower_wick_pct=Q3 | 15min | COMPRA | 151 | 112 | 2.20 | nao | 2.62 | 1 | 9.70 | 6.28 | 6.28 | 1.76 | -6.33 | 3.53 | 49.11 | 3/3 | 21/28 | 7.50 | 5.06 | 3.41 |

### M30 — modo `ret`

- eventos: 33,093 (2024-01-22 a 2026-10-16); descoberta 19,808 (até 2025-09-18), validação 13,238 (a partir de 2025-09-19)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 187,319**; passaram no BH (q=5%) na descoberta: **630**; confirmadas na validação: **381**
- melhores N da descoberta que repetem na validação: top 100: 69.0%, top 1000: 52.4%, top 10000: 18.9%
- **placebo** (6 deslocamentos): top 100: 9.2% (máx 14.0%), top 1000: 7.6% (máx 10.6%), top 10000: 7.3% (máx 10.0%); BH: média 2.2 (máx 10); confirmadas: média 0.2 (máx 1)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 19,808 | 0.008 | 2.376 | 0.481 |
| 15min bruto | 19,747 | 0.011 | 2.488 | 0.698 |
| 30min bruto | 19,032 | 0.005 | 0.815 | 0.295 |
| 60min bruto | 18,190 | 0.005 | 0.401 | 0.304 |
| 120min bruto | 16,848 | -0.003 | -0.100 | -0.161 |
| 240min bruto | 14,928 | -0.021 | -0.371 | -1.314 |

**M30/ret: famílias distintas validadas: 1691; com líquido positivo e significativo na validação (custo realista): 24.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H4=BEARISH & month=10 | 240min | VENDA | 480 | 377 | -2.01 | nao | -1.85 | 1 | 37.35 | 32.31 | 32.83 | 4.61 | -5.68 | 5.50 | 55.17 | 3/3 | 3/3 | 50.79 | 14.96 | 4.52 |
| slot_hhmm=13:30 & mtf_H4=BULLISH | 30min | COMPRA | 132 | 84 | 3.18 | nao | 3.70 | 1 | 23.75 | 20.52 | 20.52 | 3.39 | -5.94 | 4.37 | 60.71 | 3/3 | 21/24 | 15.89 | 25.15 | 3.23 |
| day_of_week=MONDAY & session=OFF_SESSION | 120min | VENDA | 323 | 223 | -2.14 | nao | -1.88 | 1 | 20.35 | 12.08 | 16.87 | 2.95 | -5.95 | 4.01 | 60.09 | 3/3 | 22/34 | 9.93 | 23.76 | 3.48 |
| slot_hhmm=13:30 & mtf_W1=BULLISH | 30min | COMPRA | 148 | 45 | 2.01 | nao | 3.32 | 1 | 31.51 | 28.28 | 28.28 | 2.82 | -5.94 | 3.39 | 68.89 | 2/3 | 9/15 | 5.37 | 50.19 | 3.23 |
| hour=6 & price_position_daily_open=Q1 | 30min | COMPRA | 157 | 85 | 2.39 | nao | 3.56 | 1 | 16.72 | 13.34 | 13.34 | 2.74 | -5.94 | 3.95 | 64.71 | 3/3 | 23/29 | 17.38 | 9.39 | 3.38 |
| day_of_week=SUNDAY & direction=BEARISH | 60min | COMPRA | 179 | 131 | 2.46 | nao | 3.39 | 1 | 34.38 | 17.83 | 17.83 | 2.64 | -5.70 | 3.50 | 51.91 | 3/3 | 16/32 | 20.10 | 15.59 | 16.55 |
| hour=13 & mtf_H4=BULLISH | 60min | COMPRA | 263 | 168 | 2.20 | nao | 1.98 | 1 | 18.22 | 14.96 | 14.96 | 2.53 | -5.70 | 3.51 | 56.55 | 3/3 | 18/29 | 18.03 | 11.90 | 3.26 |
| mtf_H4=BREAK_UP & mtf_W1=BEARISH | 240min | COMPRA | 270 | 369 | 2.56 | nao | 1.73 | 1 | 21.38 | 15.10 | 15.10 | 2.51 | -6.25 | 3.59 | 52.57 | 3/3 | 7/13 | -6.53 | 36.62 | 6.28 |
| slot_hhmm=22:30 & cost_atr=Q5 | 15min | COMPRA | 247 | 151 | 2.75 | nao | 5.54 | 1 | 15.01 | 6.12 | 6.12 | 2.33 | -5.19 | 4.32 | 54.97 | 2/3 | 13/30 | 5.12 | 7.09 | 8.89 |
| slot_hhmm=14:00 & mtf_M5=BULLISH | 30min | VENDA | 146 | 96 | -2.23 | nao | -2.54 | 1 | 16.64 | 13.44 | 13.47 | 2.24 | -6.09 | 3.26 | 55.21 | 3/3 | 20/31 | 19.38 | 7.56 | 3.16 |
| day_of_week=SUNDAY & price_position_weekly_open=Q3 | 120min | COMPRA | 377 | 224 | 2.17 | nao | 2.42 | 1 | 35.66 | 12.38 | 12.38 | 2.11 | -5.78 | 3.12 | 56.25 | 2/3 | 16/33 | 22.57 | 2.18 | 23.28 |
| slot_hhmm=21:30 & range_atr_prev=Q5 | 60min | COMPRA | 165 | 171 | 4.09 | sim | 4.56 | 1 | 29.02 | 11.68 | 11.68 | 2.10 | -5.70 | 3.13 | 60.82 | 3/3 | 17/21 | 11.59 | 11.78 | 17.33 |
| slot_hhmm=18:00 & mtf_W1=BULLISH | 5min | COMPRA | 150 | 45 | 3.14 | nao | 2.97 | 1 | 11.04 | 7.28 | 7.28 | 2.09 | -5.32 | 3.58 | 64.44 | 2/3 | 9/15 | 7.60 | 6.98 | 3.76 |
| day_of_week=SUNDAY & news_state=NONE_60M | 120min | COMPRA | 436 | 294 | 2.42 | nao | 2.56 | 1 | 32.18 | 10.78 | 10.78 | 2.07 | -5.78 | 3.21 | 54.76 | 2/3 | 18/33 | 22.09 | -0.53 | 21.40 |
| mtf_W1=BREAK_UP & swing_high_distance_atr=Q1 | 60min | COMPRA | 122 | 44 | 2.01 | nao | 2.09 | 1 | 35.23 | 26.27 | 26.27 | 2.06 | -5.70 | 2.49 | 63.64 | 2/2 | 4/4 | 43.23 | 9.31 | 8.96 |
| day_of_week=SUNDAY | 120min | COMPRA | 442 | 295 | 2.56 | nao | 2.53 | 1 | 31.85 | 10.51 | 10.51 | 2.02 | -5.78 | 3.17 | 54.58 | 2/3 | 18/33 | 22.09 | -0.99 | 21.34 |
| mtf_H1=BREAK_DOWN & mtf_D1=BULLISH | 60min | COMPRA | 273 | 152 | 2.13 | nao | 2.91 | 1 | 21.42 | 11.95 | 11.95 | 1.99 | -5.70 | 2.95 | 55.92 | 3/3 | 11/19 | 13.77 | 10.14 | 9.47 |
| slot_hhmm=22:30 & mtf_M15=BEARISH | 30min | COMPRA | 160 | 117 | 2.99 | nao | 4.56 | 1 | 12.11 | 5.10 | 5.10 | 1.87 | -5.94 | 4.03 | 59.83 | 2/3 | 18/32 | 7.31 | 2.93 | 7.01 |
| slot_hhmm=21:30 & range_atr_prev=Q5 | 15min | COMPRA | 172 | 172 | 6.80 | sim | 9.33 | 1 | 22.78 | 5.50 | 5.50 | 1.86 | -5.19 | 3.63 | 58.14 | 2/3 | 16/23 | -0.28 | 11.28 | 17.28 |
| slot_hhmm=22:30 & mtf_M15=BEARISH | 15min | COMPRA | 161 | 117 | 2.68 | nao | 4.37 | 1 | 12.35 | 5.34 | 5.34 | 1.86 | -5.19 | 3.66 | 53.85 | 2/3 | 19/32 | 8.39 | 2.34 | 7.01 |
| slot_hhmm=22:30 & cost_atr=Q5 | 30min | COMPRA | 245 | 151 | 2.62 | nao | 4.81 | 1 | 14.12 | 5.23 | 5.23 | 1.83 | -5.94 | 3.91 | 56.95 | 2/3 | 14/30 | 4.23 | 6.21 | 8.89 |
| slot_hhmm=22:30 & cost_atr=Q5 | 5min | COMPRA | 254 | 151 | 3.68 | nao | 5.47 | 1 | 12.83 | 3.94 | 3.94 | 1.80 | -5.32 | 4.22 | 50.33 | 1/3 | 9/30 | 1.87 | 5.99 | 8.89 |
| mtf_D1=BEARISH & month=3 | 120min | VENDA | 276 | 797 | -2.09 | nao | -2.08 | 1 | 14.64 | 8.37 | 8.23 | 1.67 | -5.95 | 3.03 | 53.70 | 2/2 | 2/2 | 9.78 | 6.67 | 6.41 |
| hour=3 & price_position_daily_open=Q1 | 30min | VENDA | 123 | 68 | -2.21 | nao | -2.03 | 1 | 10.13 | 6.65 | 6.64 | 1.66 | -6.09 | 3.16 | 57.35 | 3/3 | 14/21 | 2.36 | 10.91 | 3.50 |

### H1 — modo `ret`

- eventos: 31,456 (2021-06-01 a 2026-10-16); descoberta 18,851 (até 2024-09-03), validação 12,583 (a partir de 2024-09-04)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 188,271**; passaram no BH (q=5%) na descoberta: **2,082**; confirmadas na validação: **1,508**
- melhores N da descoberta que repetem na validação: top 100: 98.0%, top 1000: 83.2%, top 10000: 33.7%
- **placebo** (6 deslocamentos): top 100: 9.7% (máx 13.0%), top 1000: 10.2% (máx 14.4%), top 10000: 9.3% (máx 10.7%); BH: média 1.7 (máx 10); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 18,851 | 0.005 | 2.482 | 0.567 |
| 15min bruto | 18,718 | 0.005 | 1.601 | 0.524 |
| 30min bruto | 18,641 | 0.006 | 1.532 | 0.643 |
| 60min bruto | 17,553 | 0.001 | 0.156 | 0.100 |
| 120min bruto | 16,374 | -0.004 | -0.291 | -0.393 |
| 240min bruto | 14,472 | -0.017 | -0.639 | -1.888 |

**H1/ret: famílias distintas validadas: 2760; com líquido positivo e significativo na validação (custo realista): 104.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & structure_at_close=BULLISH | 120min | COMPRA | 145 | 90 | 2.04 | nao | 4.07 | 1 | 48.34 | 38.69 | 38.69 | 4.43 | -5.21 | 5.01 | 64.44 | 5/6 | 12/17 | 63.97 | 13.40 | 9.66 |
| day_of_week=SUNDAY & mtf_M15=RANGE | 15min | COMPRA | 124 | 70 | 2.98 | nao | 4.78 | 1 | 32.81 | 21.49 | 21.49 | 3.46 | -3.47 | 4.00 | 61.43 | 5/6 | 5/10 | 28.04 | 14.95 | 11.32 |
| day_of_week=SUNDAY & mtf_D1=BULLISH | 15min | COMPRA | 130 | 84 | 3.43 | nao | 5.38 | 1 | 29.80 | 16.02 | 16.02 | 3.34 | -3.47 | 4.06 | 67.86 | 5/6 | 15/21 | 10.98 | 21.06 | 13.78 |
| day_of_week=SUNDAY & mtf_M15=RANGE | 30min | COMPRA | 123 | 70 | 3.25 | nao | 4.57 | 1 | 31.70 | 20.38 | 20.38 | 3.28 | -3.48 | 3.82 | 57.14 | 6/6 | 7/10 | 29.44 | 11.32 | 11.32 |
| day_of_week=SUNDAY & session=OFF_SESSION | 15min | COMPRA | 332 | 220 | 2.67 | nao | 5.49 | 1 | 15.80 | 9.74 | 9.74 | 3.27 | -3.47 | 4.47 | 57.73 | 5/6 | 37/64 | 8.15 | 11.33 | 6.06 |
| day_of_week=SUNDAY & mtf_D1=BULLISH | 30min | COMPRA | 130 | 84 | 2.39 | nao | 5.36 | 1 | 32.69 | 18.91 | 18.91 | 3.22 | -3.48 | 3.81 | 58.33 | 4/6 | 16/21 | 14.67 | 23.15 | 13.78 |
| day_of_week=SUNDAY & mtf_H4=RANGE | 30min | COMPRA | 127 | 75 | 2.02 | nao | 5.12 | 1 | 31.23 | 19.19 | 19.19 | 3.21 | -3.48 | 3.78 | 61.33 | 4/6 | 10/18 | 19.99 | 18.41 | 12.04 |
| structure_before=BEARISH & price_position_monthly_open=Q3 | 240min | VENDA | 1,004 | 704 | -2.10 | nao | -2.24 | 2 | 23.90 | 18.76 | 18.12 | 3.14 | -5.95 | 4.33 | 53.98 | 6/6 | 41/61 | 19.04 | 17.19 | 5.78 |
| day_of_week=SUNDAY & structure_at_close=BULLISH | 60min | COMPRA | 146 | 90 | 3.35 | nao | 4.54 | 1 | 30.28 | 20.62 | 20.62 | 3.10 | -5.09 | 3.86 | 54.44 | 5/6 | 11/18 | 27.88 | 13.36 | 9.66 |
| day_of_week=SUNDAY & mtf_D1=BULLISH | 5min | COMPRA | 130 | 84 | 2.96 | nao | 6.46 | 1 | 25.62 | 11.84 | 11.84 | 3.08 | -4.26 | 4.17 | 57.14 | 3/6 | 13/21 | 6.41 | 17.27 | 13.78 |
| price_position_monthly_open=Q1 & cum10=Q5 | 240min | VENDA | 348 | 206 | -2.12 | nao | -1.75 | 1 | 29.31 | 25.02 | 24.97 | 3.07 | -5.95 | 3.81 | 58.25 | 5/6 | 14/21 | 19.26 | 30.67 | 4.34 |
| session=OFF_SESSION & mtf_D1=BULLISH | 5min | COMPRA | 510 | 302 | 6.61 | sim | 6.12 | 1 | 9.61 | 4.49 | 4.49 | 3.05 | -4.26 | 5.97 | 55.96 | 4/6 | 31/45 | 3.96 | 5.01 | 5.12 |
| dow_slot=SUNDAY|22:00 | 15min | COMPRA | 166 | 110 | 3.73 | sim | 4.80 | 7 | 20.57 | 12.04 | 12.04 | 2.89 | -3.47 | 3.72 | 60.00 | 6/6 | 11/20 | 9.97 | 14.10 | 8.54 |
| session=OFF_SESSION & prev_day_low_distance_atr=Q1 | 5min | COMPRA | 138 | 87 | 2.73 | nao | 4.11 | 1 | 17.34 | 11.89 | 11.89 | 2.86 | -4.26 | 3.88 | 58.62 | 5/6 | 9/19 | 13.57 | 10.24 | 5.46 |
| day_of_week=SUNDAY & price_position_weekly_open=Q3 | 30min | COMPRA | 358 | 229 | 3.90 | sim | 6.49 | 1 | 21.26 | 9.16 | 9.16 | 2.80 | -3.48 | 3.88 | 52.84 | 5/6 | 33/60 | 7.01 | 11.29 | 12.10 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q4 | 60min | COMPRA | 135 | 82 | 2.68 | nao | 4.05 | 1 | 27.71 | 18.56 | 18.56 | 2.71 | -5.09 | 3.44 | 52.44 | 4/6 | 8/18 | 22.09 | 15.03 | 9.15 |
| day_of_week=SUNDAY & direction=BEARISH | 15min | COMPRA | 163 | 110 | 3.79 | sim | 4.73 | 1 | 21.25 | 12.03 | 12.03 | 2.69 | -3.47 | 3.47 | 60.00 | 6/6 | 19/29 | 13.46 | 10.60 | 9.22 |
| day_of_week=SUNDAY & mtf_H1=BULLISH | 60min | COMPRA | 153 | 82 | 3.02 | nao | 4.17 | 2 | 29.44 | 19.21 | 19.21 | 2.68 | -5.09 | 3.37 | 52.44 | 5/6 | 10/18 | 23.93 | 14.49 | 10.23 |
| day_of_week=SUNDAY & session=OFF_SESSION | 30min | COMPRA | 331 | 220 | 2.87 | nao | 4.49 | 1 | 14.83 | 8.77 | 8.77 | 2.67 | -3.48 | 3.76 | 53.64 | 5/6 | 35/64 | 6.33 | 11.21 | 6.06 |
| slot_hhmm=21:00 & prev_day_high_distance_atr=Q4 | 60min | COMPRA | 181 | 115 | 4.81 | sim | 7.52 | 2 | 34.70 | 12.92 | 12.92 | 2.66 | -5.09 | 3.70 | 66.09 | 5/6 | 26/35 | 20.36 | 5.62 | 21.78 |
| volatility_state=EXTREME & pat_PIN_BAR=Y | 30min | COMPRA | 189 | 215 | 2.04 | nao | 5.51 | 1 | 21.10 | 9.87 | 9.87 | 2.65 | -3.48 | 3.61 | 59.53 | 3/6 | 27/41 | 19.50 | 0.33 | 11.23 |
| day_of_week=SUNDAY & structure_at_close=BULLISH | 30min | COMPRA | 147 | 90 | 4.51 | sim | 4.40 | 1 | 23.27 | 13.61 | 13.61 | 2.61 | -3.48 | 3.27 | 53.33 | 5/6 | 8/18 | 15.95 | 11.27 | 9.66 |
| day_of_week=SUNDAY & structure_before=BULLISH | 5min | COMPRA | 157 | 82 | 3.76 | sim | 4.75 | 2 | 20.54 | 10.31 | 10.31 | 2.60 | -4.26 | 3.67 | 54.88 | 4/6 | 10/19 | 8.30 | 12.32 | 10.23 |
| slot_hhmm=22:00 & previous_low_distance_atr=Q1 | 5min | COMPRA | 167 | 71 | 3.77 | sim | 4.26 | 2 | 18.83 | 9.97 | 9.97 | 2.56 | -4.26 | 3.64 | 49.30 | 5/6 | 13/23 | 8.44 | 11.44 | 8.87 |
| volatility_state=EXTREME & body_pct=Q1 | 60min | COMPRA | 152 | 180 | 2.32 | nao | 4.62 | 1 | 26.94 | 15.55 | 15.55 | 2.55 | -5.09 | 3.41 | 57.78 | 5/6 | 20/30 | 16.09 | 15.01 | 11.39 |

## 6.2 Modo `hit`

### M5 — modo `hit`

- eventos: 106,047 (2025-05-15 a 2026-10-16); descoberta 63,340 (até 2026-03-24), validação 42,419 (a partir de 2026-03-25)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 630,414**; passaram no BH (q=5%) na descoberta: **13**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 1.0%, top 1000: 2.0%, top 10000: 0.9%
- **placebo** (6 deslocamentos): top 100: 3.5% (máx 7.0%), top 1000: 1.4% (máx 2.2%), top 10000: 0.6% (máx 0.9%); BH: média 7.8 (máx 15); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 62,994 | -0.270 |  | -6.481 |
| C alvo 0.5ATR/60min liquido | 61,561 | -0.273 |  | -6.545 |
| C alvo 0.5ATR/240min liquido | 55,981 | -0.260 |  | -6.235 |
| C alvo 1.0ATR/15min liquido | 62,994 | -0.263 |  | -6.306 |
| C alvo 1.0ATR/60min liquido | 61,561 | -0.275 |  | -6.602 |
| C alvo 1.0ATR/240min liquido | 55,981 | -0.266 |  | -6.389 |
| C alvo 2.0ATR/15min liquido | 62,994 | -0.251 |  | -6.030 |
| C alvo 2.0ATR/60min liquido | 61,561 | -0.260 |  | -6.230 |
| C alvo 2.0ATR/240min liquido | 55,981 | -0.250 |  | -5.994 |
| V alvo 0.5ATR/15min liquido | 62,994 | -0.260 |  | -6.233 |
| V alvo 0.5ATR/60min liquido | 61,561 | -0.257 |  | -6.174 |
| V alvo 0.5ATR/240min liquido | 55,981 | -0.254 |  | -6.097 |
| V alvo 1.0ATR/15min liquido | 62,994 | -0.244 |  | -5.865 |
| V alvo 1.0ATR/60min liquido | 61,561 | -0.241 |  | -5.787 |
| V alvo 1.0ATR/240min liquido | 55,981 | -0.217 |  | -5.210 |
| V alvo 2.0ATR/15min liquido | 62,994 | -0.241 |  | -5.774 |
| V alvo 2.0ATR/60min liquido | 61,561 | -0.231 |  | -5.538 |
| V alvo 2.0ATR/240min liquido | 55,981 | -0.197 |  | -4.736 |

**M5/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

### M15 — modo `hit`

- eventos: 67,132 (2024-01-22 a 2026-10-16); descoberta 40,184 (até 2025-09-15), validação 26,853 (a partir de 2025-09-16)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 647,910**; passaram no BH (q=5%) na descoberta: **4**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 4.0%, top 1000: 1.5%, top 10000: 0.6%
- **placebo** (6 deslocamentos): top 100: 3.2% (máx 6.0%), top 1000: 1.5% (máx 3.0%), top 10000: 0.5% (máx 0.9%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 39,384 | -0.150 |  | -6.605 |
| C alvo 0.5ATR/60min liquido | 36,677 | -0.151 |  | -6.615 |
| C alvo 0.5ATR/240min liquido | 29,879 | -0.162 |  | -7.119 |
| C alvo 1.0ATR/15min liquido | 39,384 | -0.146 |  | -6.408 |
| C alvo 1.0ATR/60min liquido | 36,677 | -0.150 |  | -6.579 |
| C alvo 1.0ATR/240min liquido | 29,879 | -0.161 |  | -7.082 |
| C alvo 2.0ATR/15min liquido | 39,384 | -0.142 |  | -6.258 |
| C alvo 2.0ATR/60min liquido | 36,677 | -0.139 |  | -6.123 |
| C alvo 2.0ATR/240min liquido | 29,879 | -0.168 |  | -7.372 |
| V alvo 0.5ATR/15min liquido | 39,384 | -0.141 |  | -6.205 |
| V alvo 0.5ATR/60min liquido | 36,677 | -0.138 |  | -6.065 |
| V alvo 0.5ATR/240min liquido | 29,879 | -0.143 |  | -6.278 |
| V alvo 1.0ATR/15min liquido | 39,384 | -0.132 |  | -5.810 |
| V alvo 1.0ATR/60min liquido | 36,677 | -0.123 |  | -5.422 |
| V alvo 1.0ATR/240min liquido | 29,879 | -0.141 |  | -6.177 |
| V alvo 2.0ATR/15min liquido | 39,384 | -0.129 |  | -5.653 |
| V alvo 2.0ATR/60min liquido | 36,677 | -0.116 |  | -5.104 |
| V alvo 2.0ATR/240min liquido | 29,879 | -0.146 |  | -6.410 |

**M15/hit: famílias distintas validadas: 5; com líquido positivo e significativo na validação (custo realista): 5.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 2.0ATR ate 240min | COMPRA | 316 | 368 | 2.42 | nao | 2.38 | 1 |  | 44.99 | 44.99 | 10.03 | -7.26 | 11.67 | 69.29 | 3/3 | 8/9 | 64.81 | 25.17 | 6.60 |
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 1.0ATR ate 240min | COMPRA | 316 | 368 | 2.02 | nao | 2.10 | 1 |  | 27.78 | 27.78 | 8.96 | -6.87 | 11.14 | 79.35 | 3/3 | 8/9 | 41.68 | 13.89 | 6.60 |
| mtf_D1=BREAK_DOWN & prev_day_high_distance_atr=Q5 | V alvo 2.0ATR ate 240min | VENDA | 139 | 51 | 3.08 | nao | 1.77 | 1 |  | 39.91 | 39.91 | 7.68 | -3.79 | 8.28 | 90.20 | 2/2 | 6/6 | 29.56 | 49.86 | 3.76 |
| slot_hhmm=14:00 & mtf_H4=BULLISH | C alvo 1.0ATR ate 15min | COMPRA | 129 | 85 | 2.90 | nao | 2.16 | 1 |  | 8.52 | 8.52 | 2.21 | -6.52 | 3.88 | 63.53 | 3/3 | 19/23 | 4.94 | 12.02 | 3.24 |
| slot_hhmm=14:00 & mtf_H4=BULLISH | C alvo 2.0ATR ate 15min | COMPRA | 129 | 85 | 2.84 | nao | 2.15 | 1 |  | 8.78 | 8.78 | 2.20 | -6.43 | 3.79 | 63.53 | 3/3 | 18/23 | 6.28 | 11.22 | 3.24 |

### M30 — modo `hit`

- eventos: 33,093 (2024-01-22 a 2026-10-16); descoberta 19,808 (até 2025-09-18), validação 13,238 (a partir de 2025-09-19)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 555,810**; passaram no BH (q=5%) na descoberta: **2**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 2.0%, top 1000: 0.8%, top 10000: 0.6%
- **placebo** (6 deslocamentos): top 100: 1.3% (máx 3.0%), top 1000: 1.0% (máx 2.0%), top 10000: 0.4% (máx 0.7%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 19,734 | -0.082 |  | -5.205 |
| C alvo 0.5ATR/60min liquido | 18,177 | -0.088 |  | -5.594 |
| C alvo 0.5ATR/240min liquido | 14,919 | -0.095 |  | -6.090 |
| C alvo 1.0ATR/15min liquido | 19,734 | -0.075 |  | -4.760 |
| C alvo 1.0ATR/60min liquido | 18,177 | -0.082 |  | -5.232 |
| C alvo 1.0ATR/240min liquido | 14,919 | -0.083 |  | -5.293 |
| C alvo 2.0ATR/15min liquido | 19,734 | -0.072 |  | -4.570 |
| C alvo 2.0ATR/60min liquido | 18,177 | -0.078 |  | -4.974 |
| C alvo 2.0ATR/240min liquido | 14,919 | -0.108 |  | -6.912 |
| V alvo 0.5ATR/15min liquido | 19,734 | -0.092 |  | -5.857 |
| V alvo 0.5ATR/60min liquido | 18,177 | -0.083 |  | -5.326 |
| V alvo 0.5ATR/240min liquido | 14,919 | -0.089 |  | -5.673 |
| V alvo 1.0ATR/15min liquido | 19,734 | -0.089 |  | -5.686 |
| V alvo 1.0ATR/60min liquido | 18,177 | -0.079 |  | -5.020 |
| V alvo 1.0ATR/240min liquido | 14,919 | -0.103 |  | -6.588 |
| V alvo 2.0ATR/15min liquido | 19,734 | -0.089 |  | -5.681 |
| V alvo 2.0ATR/60min liquido | 18,177 | -0.073 |  | -4.682 |
| V alvo 2.0ATR/240min liquido | 14,919 | -0.075 |  | -4.800 |

**M30/hit: famílias distintas validadas: 2; com líquido positivo e significativo na validação (custo realista): 2.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 1.0ATR ate 240min | COMPRA | 157 | 184 | 2.67 | nao | 2.27 | 1 |  | 36.71 | 36.71 | 7.03 | -6.65 | 8.29 | 71.74 | 3/3 | 9/9 | 53.46 | 19.95 | 6.33 |
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 2.0ATR ate 240min | COMPRA | 157 | 184 | 2.37 | nao | 2.13 | 1 |  | 51.43 | 51.43 | 6.78 | -6.39 | 7.64 | 64.67 | 3/3 | 8/9 | 77.52 | 25.35 | 6.33 |

### H1 — modo `hit`

- eventos: 31,456 (2021-06-01 a 2026-10-16); descoberta 18,851 (até 2024-09-03), validação 12,583 (a partir de 2024-09-04)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 557,178**; passaram no BH (q=5%) na descoberta: **12**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 1.7%, top 10000: 1.3%
- **placebo** (6 deslocamentos): top 100: 0.8% (máx 2.0%), top 1000: 0.8% (máx 0.9%), top 10000: 0.8% (máx 1.1%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 18,718 | -0.037 |  | -4.094 |
| C alvo 0.5ATR/60min liquido | 17,553 | -0.038 |  | -4.195 |
| C alvo 0.5ATR/240min liquido | 14,472 | -0.037 |  | -4.002 |
| C alvo 1.0ATR/15min liquido | 18,718 | -0.035 |  | -3.810 |
| C alvo 1.0ATR/60min liquido | 17,553 | -0.036 |  | -3.937 |
| C alvo 1.0ATR/240min liquido | 14,472 | -0.041 |  | -4.540 |
| C alvo 2.0ATR/15min liquido | 18,718 | -0.033 |  | -3.665 |
| C alvo 2.0ATR/60min liquido | 17,553 | -0.037 |  | -4.016 |
| C alvo 2.0ATR/240min liquido | 14,472 | -0.055 |  | -6.021 |
| V alvo 0.5ATR/15min liquido | 18,718 | -0.040 |  | -4.425 |
| V alvo 0.5ATR/60min liquido | 17,553 | -0.043 |  | -4.667 |
| V alvo 0.5ATR/240min liquido | 14,472 | -0.038 |  | -4.138 |
| V alvo 1.0ATR/15min liquido | 18,718 | -0.037 |  | -4.085 |
| V alvo 1.0ATR/60min liquido | 17,553 | -0.037 |  | -4.025 |
| V alvo 1.0ATR/240min liquido | 14,472 | -0.021 |  | -2.302 |
| V alvo 2.0ATR/15min liquido | 18,718 | -0.038 |  | -4.134 |
| V alvo 2.0ATR/60min liquido | 17,553 | -0.039 |  | -4.296 |
| V alvo 2.0ATR/240min liquido | 14,472 | -0.024 |  | -2.585 |

**H1/hit: famílias distintas validadas: 12; com líquido positivo e significativo na validação (custo realista): 9.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| price_position_monthly_open=Q1 & cum10=Q5 | V alvo 2.0ATR ate 240min | VENDA | 348 | 206 | 2.22 | nao | 1.82 | 1 |  | 30.17 | 30.17 | 3.67 | -4.95 | 4.29 | 59.71 | 6/6 | 15/21 | 24.43 | 35.92 | 4.34 |
| range_atr=Q5 & pat_DOJI=Y | C alvo 1.0ATR ate 60min | COMPRA | 224 | 194 | 2.11 | nao | 2.20 | 1 |  | 13.68 | 13.68 | 3.05 | -4.89 | 4.15 | 59.28 | 6/6 | 30/46 | 15.66 | 11.69 | 10.12 |
| day_of_week=SUNDAY & structure_at_close=BULLISH | C alvo 2.0ATR ate 15min | COMPRA | 147 | 90 | 2.67 | nao | 3.05 | 1 |  | 12.17 | 12.17 | 2.46 | -3.51 | 3.16 | 61.11 | 6/6 | 11/18 | 12.30 | 12.03 | 9.66 |
| day_of_week=SUNDAY & structure_at_close=BULLISH | C alvo 1.0ATR ate 15min | COMPRA | 147 | 90 | 2.61 | nao | 2.94 | 1 |  | 11.14 | 11.14 | 2.32 | -3.55 | 3.06 | 61.11 | 6/6 | 11/18 | 10.84 | 11.44 | 9.66 |
| structure_at_close=BULLISH & mtf_D1=BREAK_DOWN | V alvo 1.0ATR ate 240min | VENDA | 203 | 189 | 2.61 | nao | 1.66 | 1 |  | 18.56 | 18.56 | 2.26 | -6.13 | 3.03 | 66.14 | 5/6 | 21/27 | 37.79 | -0.46 | 7.73 |
| slot_hhmm=14:00 & prev_day_low_distance_atr=Q3 | V alvo 2.0ATR ate 60min | VENDA | 136 | 93 | 2.46 | nao | 1.95 | 2 |  | 20.48 | 20.48 | 2.11 | -5.99 | 2.73 | 53.76 | 6/6 | 14/19 | 11.27 | 29.50 | 3.19 |
| dow_slot=SUNDAY|22:00 & volume_ratio=Q1 | C alvo 0.5ATR ate 15min | COMPRA | 135 | 44 | 2.07 | nao | 1.68 | 1 |  | 10.42 | 10.42 | 1.84 | -3.87 | 2.50 | 61.36 | 5/5 | 3/5 | 8.28 | 12.55 | 12.75 |
| slot_hhmm=14:00 & prev_day_low_distance_atr=Q3 | V alvo 1.0ATR ate 60min | VENDA | 136 | 93 | 2.09 | nao | 1.68 | 2 |  | 14.63 | 14.63 | 1.81 | -5.98 | 2.55 | 55.91 | 6/6 | 13/19 | 9.58 | 19.57 | 3.19 |
| hour=21 & mtf_W1=RANGE | C alvo 2.0ATR ate 60min | COMPRA | 170 | 129 | 2.10 | nao | 2.18 | 2 |  | 7.90 | 7.90 | 1.65 | -5.19 | 2.73 | 62.79 | 5/6 | 23/27 | -4.02 | 19.65 | 18.50 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **7507**
- com líquido positivo e t>1,645 na validação, custo realista: **189**; dessas, sobreviveram ao BH: **49**; e positivas nas duas metades da validação: **46**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H1 | ret | session=OFF_SESSION & mtf_D1=BULLISH | 5min | COMPRA | 302 | 4.49 | -4.26 | 5.97 | 3.05 | 55.96 | 4/6 | 31/45 |
| H1 | ret | dow_slot=SUNDAY|22:00 | 15min | COMPRA | 110 | 12.04 | -3.47 | 3.72 | 2.89 | 60.00 | 6/6 | 11/20 |
| H1 | ret | day_of_week=SUNDAY & price_position_weekly_open=Q3 | 30min | COMPRA | 229 | 9.16 | -3.48 | 3.88 | 2.80 | 52.84 | 5/6 | 33/60 |
| H1 | ret | day_of_week=SUNDAY & direction=BEARISH | 15min | COMPRA | 110 | 12.03 | -3.47 | 3.47 | 2.69 | 60.00 | 6/6 | 19/29 |
| H1 | ret | slot_hhmm=21:00 & prev_day_high_distance_atr=Q4 | 60min | COMPRA | 115 | 12.92 | -5.09 | 3.70 | 2.66 | 66.09 | 5/6 | 26/35 |
| H1 | ret | day_of_week=SUNDAY & structure_at_close=BULLISH | 30min | COMPRA | 90 | 13.61 | -3.48 | 3.27 | 2.61 | 53.33 | 5/6 | 8/18 |
| H1 | ret | day_of_week=SUNDAY & structure_before=BULLISH | 5min | COMPRA | 82 | 10.31 | -4.26 | 3.67 | 2.60 | 54.88 | 4/6 | 10/19 |
| H1 | ret | slot_hhmm=22:00 & previous_low_distance_atr=Q1 | 5min | COMPRA | 71 | 9.97 | -4.26 | 3.64 | 2.56 | 49.30 | 5/6 | 13/23 |
| M5 | ret | hour=22 & previous_high_distance_atr=Q1 | 15min | COMPRA | 81 | 6.51 | -6.42 | 5.00 | 2.53 | 53.09 | 0/2 | 5/12 |
| H1 | ret | session=OFF_SESSION & price_position_monthly_open=Q4 | 5min | COMPRA | 199 | 4.03 | -4.26 | 5.06 | 2.46 | 57.29 | 4/6 | 18/38 |
| H1 | ret | day_of_week=SUNDAY & mtf_H1=BULLISH | 15min | COMPRA | 82 | 14.05 | -3.47 | 3.07 | 2.46 | 59.76 | 6/6 | 8/18 |
| H1 | ret | day_of_week=SUNDAY & structure_at_close=BULLISH | 15min | COMPRA | 90 | 12.17 | -3.47 | 3.16 | 2.46 | 61.11 | 6/6 | 11/18 |
| H1 | ret | day_of_week=SUNDAY | 30min | COMPRA | 293 | 7.25 | -3.48 | 3.61 | 2.41 | 52.56 | 5/6 | 35/65 |
| H1 | ret | day_of_week=SUNDAY & structure_at_close=BULLISH | 5min | COMPRA | 90 | 7.78 | -4.26 | 3.70 | 2.40 | 53.33 | 4/6 | 10/18 |
| H1 | ret | hour=21 & prev_day_high_distance_atr=Q4 | 30min | COMPRA | 117 | 9.40 | -3.48 | 3.27 | 2.39 | 68.38 | 5/6 | 30/35 |
| H1 | ret | day_of_week=SUNDAY | 15min | COMPRA | 293 | 6.90 | -3.47 | 3.64 | 2.39 | 57.00 | 5/6 | 36/65 |
| H1 | ret | day_of_week=SUNDAY & direction=BEARISH | 30min | COMPRA | 110 | 12.22 | -3.48 | 3.03 | 2.36 | 53.64 | 6/6 | 17/28 |
| H1 | ret | hour=22 & mtf_M15=RANGE | 15min | COMPRA | 120 | 8.18 | -3.47 | 3.30 | 2.32 | 52.50 | 4/6 | 18/30 |
| H1 | ret | hour=22 & atr_ratio=Q4 | 30min | COMPRA | 100 | 7.03 | -3.48 | 3.42 | 2.31 | 57.00 | 6/6 | 13/25 |
| H1 | ret | day_of_week=SUNDAY & mtf_H1=BULLISH | 30min | COMPRA | 82 | 12.86 | -3.48 | 2.91 | 2.30 | 53.66 | 5/6 | 7/18 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 1687s)_
