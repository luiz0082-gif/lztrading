# USDJPY — relatório completo MBA (gerado em 2026-10-17 01:38)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | Raw Trading Ltd |
| servidor | ICMarketsSC-Demo |
| simbolo | USDJPY |
| descricao | US Dollar vs Japanese Yen |
| digitos | 3 |
| ponto | 0.00100 |
| tick_size | 0.00100 |
| tick_value | 0.63299 |
| contrato | 100,000.00000 |
| lote_min | 0.01000 |
| swap_long | 8.27500 |
| swap_short | -17.06800 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-01-22 00:22 | 2026-10-16 23:55 | 160 | 1,160,354 | 0 | 123,442 | 123,442 | 1 |
| M5 | 106,442 | 2025-05-15 03:15 | 2026-10-16 23:50 | 86 | 579 | 0 | 24,714 | 24,714 | 1 |
| M15 | 68,212 | 2024-01-22 05:30 | 2026-10-16 23:30 | 150 | 193 | 0 | 8,240 | 8,240 | 0 |
| M30 | 34,097 | 2024-01-22 11:00 | 2026-10-16 23:00 | 149 | 96 | 0 | 4,121 | 4,121 | 0 |
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
| 0 | 0.00 | 1.00 | 3.00 | 62.00 | 54.46 | 322.00 | 4,437 | 1.03 | 86.41 | 0.02 |
| 1 | 0.00 | 0.00 | 2.00 | 56.00 | 67.43 | 311.00 | 4,440 | 0.77 | 96.51 | 0.01 |
| 2 | 0.00 | 0.00 | 2.00 | 43.00 | 54.57 | 227.00 | 4,440 | 0.86 | 97.16 | 0.02 |
| 3 | 0.00 | 0.00 | 3.00 | 36.00 | 42.93 | 193.50 | 4,440 | 0.85 | 95.97 | 0.02 |
| 4 | 0.00 | 0.00 | 3.00 | 36.00 | 40.36 | 192.00 | 4,440 | 0.91 | 95.18 | 0.02 |
| 5 | 0.00 | 0.00 | 3.00 | 40.00 | 42.21 | 222.00 | 4,427 | 0.96 | 93.36 | 0.02 |
| 6 | 0.00 | 1.00 | 3.00 | 53.00 | 51.57 | 306.00 | 4,427 | 1.01 | 84.66 | 0.02 |
| 7 | 0.00 | 0.00 | 3.00 | 58.00 | 60.71 | 358.00 | 4,438 | 1.01 | 90.49 | 0.02 |
| 8 | 0.00 | 0.00 | 3.00 | 54.00 | 62.36 | 359.00 | 4,440 | 0.96 | 92.68 | 0.02 |
| 9 | 0.00 | 0.00 | 3.00 | 47.00 | 55.50 | 316.00 | 4,436 | 0.95 | 94.34 | 0.02 |
| 10 | 0.00 | 0.00 | 3.00 | 40.00 | 47.00 | 279.00 | 4,440 | 0.95 | 93.54 | 0.02 |
| 11 | 0.00 | 0.00 | 3.00 | 42.00 | 43.71 | 294.00 | 4,440 | 1.00 | 91.44 | 0.02 |
| 12 | 0.00 | 1.00 | 4.00 | 53.00 | 52.50 | 377.00 | 4,440 | 1.01 | 88.81 | 0.02 |
| 13 | 0.00 | 0.00 | 3.00 | 62.00 | 63.29 | 458.00 | 4,430 | 1.02 | 90.72 | 0.02 |
| 14 | 0.00 | 0.00 | 3.00 | 66.00 | 71.79 | 496.00 | 4,433 | 0.98 | 92.62 | 0.01 |
| 15 | 0.00 | 0.00 | 3.00 | 57.00 | 69.50 | 431.00 | 4,440 | 0.89 | 94.75 | 0.01 |
| 16 | 0.00 | 1.00 | 3.00 | 45.00 | 57.71 | 312.00 | 4,439 | 1.04 | 89.77 | 0.02 |
| 17 | 0.00 | 0.00 | 3.00 | 38.00 | 45.50 | 249.00 | 4,440 | 1.05 | 90.36 | 0.02 |
| 18 | 0.00 | 0.00 | 3.00 | 35.00 | 39.29 | 227.00 | 4,440 | 1.05 | 90.07 | 0.03 |
| 19 | 0.00 | 0.00 | 10.00 | 31.00 | 35.07 | 201.00 | 4,440 | 1.06 | 91.35 | 0.03 |
| 20 | 0.00 | 10.00 | 70.00 | 26.00 | 31.64 | 140.00 | 4,439 | 1.20 | 69.50 | 0.04 |
| 21 | 66.00 | 105.00 | 170.00 | 23.00 | 30.46 | 38.00 | 4,410 | 65.92 | 15.01 | 2.16 |
| 22 | 0.00 | 66.00 | 170.00 | 28.00 | 32.93 | 86.00 | 4,418 | 0.83 | 73.92 | 0.03 |
| 23 | 0.00 | 0.00 | 70.00 | 37.00 | 34.43 | 137.00 | 4,428 | 0.96 | 92.23 | 0.03 |

Spread geral (mediana M5): **0.0 pts**, p90 1.0, máx 170. ATR mediano M5: **47.9 pts**. Razão spread/ATR: **0.00**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 512 | 922.22 | 133.15 | 609.84 | 62.50 | 4.94 |
| ter | 515 | 948.46 | 73.83 | 669.41 | 57.28 | 2.50 |
| qua | 513 | 1,037.83 | 76.35 | 747.48 | 55.36 | 2.31 |
| qui | 515 | 1,060.84 | -52.71 | 817.29 | 50.29 | -1.46 |
| sex | 514 | 1,034.64 | -3.87 | 760.83 | 51.36 | -0.12 |

Autocorrelação do retorno diário (lags 1-5): -0.022, -0.004, -0.036, +0.022, -0.011 (banda ±0.039). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.201, +0.176, +0.185.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 1,422 | 0 | 0.015 | 0.660 | nao |
| 1,422 | 1 | -0.034 | -1.816 | nao |
| 1,422 | 2 | 0.048 | 2.959 | sim |
| 1,422 | 3 | -0.002 | -0.121 | nao |
| 1,422 | 4 | 0.027 | 1.733 | nao |
| 1,422 | 5 | 0.028 | 1.672 | nao |
| 1,421 | 6 | 0.023 | 1.094 | nao |
| 1,422 | 7 | 0.020 | 0.866 | nao |
| 1,422 | 8 | 0.018 | 0.828 | nao |
| 1,421 | 9 | 0.041 | 2.443 | nao |
| 1,421 | 10 | -0.000 | -0.005 | nao |
| 1,421 | 11 | 0.024 | 1.518 | nao |
| 1,421 | 12 | 0.020 | 0.698 | nao |
| 1,421 | 13 | -0.029 | -1.124 | nao |
| 1,422 | 14 | 0.021 | 0.853 | nao |
| 1,422 | 15 | 0.058 | 2.898 | sim |
| 1,422 | 16 | 0.037 | 2.687 | sim |
| 1,422 | 17 | 0.010 | 0.762 | nao |
| 1,422 | 18 | 0.011 | 0.723 | nao |
| 1,420 | 19 | 0.039 | 3.208 | sim |
| 1,419 | 20 | 0.031 | 3.022 | sim |
| 1,419 | 21 | -0.009 | -0.957 | nao |
| 1,420 | 22 | 0.122 | 9.837 | sim |
| 1,422 | 23 | 0.033 | 2.228 | nao |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 6,776 | 0 | 0.025 | 3.411 | sim |
| 6,859 | 1 | 0.030 | 3.599 | sim |
| 6,816 | 2 | 0.020 | 2.300 | sim |
| 6,815 | 3 | 0.007 | 0.792 | nao |
| 6,089 | 4 | 0.012 | 1.245 | nao |
| 757 | 6 | 0.203 | 9.801 | sim |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,597 | 1 | 0.019 | 1.410 | nao |
| 2,424 | 2 | 0.018 | 1.318 | nao |
| 2,645 | 3 | 0.032 | 2.528 | sim |
| 2,664 | 4 | 0.038 | 2.867 | sim |
| 3,168 | 5 | 0.022 | 1.817 | nao |
| 3,098 | 6 | 0.052 | 4.236 | sim |
| 3,189 | 7 | -0.001 | -0.095 | nao |
| 3,171 | 8 | 0.020 | 1.669 | nao |
| 3,117 | 9 | 0.029 | 2.335 | sim |
| 2,927 | 10 | 0.043 | 3.501 | sim |
| 2,564 | 11 | -0.018 | -1.302 | nao |
| 2,548 | 12 | 0.017 | 1.252 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 121 combinações testadas):

| dia(0=seg) | hora_utc | n | ret_medio_ATR | std | t |
|---|---|---|---|---|---|
| 6 | 22 | 280 | 0.383 | 0.591 | 10.857 |
| 2 | 21 | 284 | -0.105 | 0.335 | -5.293 |
| 1 | 22 | 284 | 0.097 | 0.427 | 3.830 |
| 6 | 23 | 282 | 0.118 | 0.539 | 3.664 |
| 0 | 15 | 282 | 0.141 | 0.692 | 3.415 |
| 0 | 22 | 286 | 0.079 | 0.424 | 3.139 |
| 2 | 19 | 284 | 0.119 | 0.666 | 3.019 |

Autocorrelação do retorno H1, lags 1-10: +0.014, +0.006, +0.004, +0.009, +0.006, -0.003, +0.008, +0.012, +0.008, +0.000 (banda ±0.011). |retorno|: +0.122, +0.054, -0.007, -0.063, +0.109 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 192 | 0.104 | 1.697 | 53.125 |
| barra < -2 ATR | 271 | -0.101 | -1.508 | 49.446 |
| barra > +1 ATR | 1,990 | 0.038 | 2.246 | 51.206 |
| barra < -1 ATR | 1,875 | -0.004 | -0.214 | 53.227 |
| gap (barra ausente antes) | 292 | 0.422 | 11.188 | 76.370 |

Distribuição do retorno H1 em ATR: média +0.0230, desvio 0.685, assimetria -0.44, curtose 7.2; barras |ret|>2 ATR: 1.36%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 1.0 pts, máxima 94.5 pts no slot NY 17:00 de domingo; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | 105,989 | 209,902 | 14 | 8 | 0.2 | 0.0 | 0 | 56.0 | 9.3 |
| M15 | ret | 68,019 | 220,756 | 147 | 93 | 0.0 | 0.0 | 0 | 67.0 | 8.2 |
| M30 | ret | 33,970 | 190,467 | 212 | 126 | 0.2 | 0.0 | 0 | 64.0 | 8.0 |
| H1 | ret | 33,106 | 194,150 | 3,399 | 1,660 | 150.5 | 54.3 | 136 | 100.0 | 44.8 |
| M5 | hit | 105,989 | 626,514 | 8 | 0 | 9.7 | 0.3 | 2 | 5.0 | 3.8 |
| M15 | hit | 68,019 | 657,186 | 56 | 15 | 0.0 | 0.0 | 0 | 24.0 | 2.5 |
| M30 | hit | 33,970 | 566,952 | 3 | 2 | 0.3 | 0.0 | 0 | 9.0 | 3.8 |
| H1 | hit | 33,106 | 576,252 | 121 | 16 | 0.0 | 0.0 | 0 | 10.0 | 3.5 |


## 6.1 Modo `ret`

### M5 — modo `ret`

- eventos: 105,989 (2025-05-15 a 2026-10-16); descoberta 63,306 (até 2026-03-23), validação 42,396 (a partir de 2026-03-24)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 209,902**; passaram no BH (q=5%) na descoberta: **14**; confirmadas na validação: **8**
- melhores N da descoberta que repetem na validação: top 100: 56.0%, top 1000: 41.9%, top 10000: 21.2%
- **placebo** (6 deslocamentos): top 100: 9.3% (máx 13.0%), top 1000: 7.6% (máx 9.5%), top 10000: 6.0% (máx 7.4%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,306 | 0.002 | 0.663 | 0.104 |
| 15min bruto | 62,860 | 0.019 | 2.040 | 0.924 |
| 30min bruto | 62,191 | 0.047 | 2.419 | 2.232 |
| 60min bruto | 60,857 | 0.100 | 2.484 | 4.794 |
| 120min bruto | 58,193 | 0.137 | 1.574 | 6.580 |
| 240min bruto | 52,897 | 0.212 | 1.097 | 10.152 |

**M5/ret: famílias distintas validadas: 1126; com líquido positivo e significativo na validação (custo realista): 150.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H1=BULLISH & price_position_monthly_open=Q2 | 240min | COMPRA | 3,685 | 2,511 | 2.06 | nao | 2.07 | 1 | 58.55 | 53.85 | 53.85 | 14.54 | -4.49 | 15.27 | 60.53 | 2/2 | 12/18 | 39.38 | 68.32 | 4.70 |
| day_of_week=FRIDAY & month=3 | 240min | COMPRA | 624 | 204 | 2.22 | nao | 1.84 | 1 | 161.42 | 160.15 | 160.15 | 12.85 | -4.49 | 13.13 | 79.41 | 1/1 | 1/1 | 130.30 | 189.99 | 1.27 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 120min | COMPRA | 3,964 | 2,388 | 2.18 | nao | 3.59 | 1 | 32.07 | 30.86 | 30.86 | 12.38 | -1.92 | 12.69 | 63.99 | 2/2 | 13/14 | 16.90 | 44.82 | 1.21 |
| news_min_to_next_high=Q5 | 120min | COMPRA | 6,855 | 4,767 | 2.41 | nao | 3.33 | 1 | 27.74 | 26.41 | 26.41 | 12.30 | -1.92 | 13.07 | 62.14 | 2/2 | 17/18 | 27.15 | 25.67 | 1.33 |
| mtf_H1=BULLISH & price_position_monthly_open=Q2 | 120min | COMPRA | 4,018 | 2,655 | 2.44 | nao | 2.42 | 1 | 36.28 | 31.78 | 31.78 | 12.24 | -1.92 | 12.70 | 59.06 | 2/2 | 13/18 | 29.30 | 34.25 | 4.50 |
| mtf_D1=BEARISH & prev_day_low_distance_atr=Q3 | 120min | COMPRA | 2,477 | 1,869 | 2.22 | nao | 2.45 | 1 | 55.01 | 51.37 | 51.37 | 11.82 | -1.92 | 12.46 | 65.44 | 2/2 | 10/10 | 43.53 | 59.21 | 3.63 |
| news_min_to_next_high=Q5 & news_min_since_last_high=Q1 | 120min | COMPRA | 2,547 | 2,042 | 2.04 | nao | 2.53 | 1 | 38.78 | 37.77 | 37.77 | 11.32 | -1.92 | 11.87 | 63.27 | 2/2 | 15/18 | 30.68 | 44.86 | 1.01 |
| news_min_to_next_high=Q5 | 60min | COMPRA | 7,802 | 5,193 | 2.36 | nao | 3.07 | 1 | 15.76 | 14.45 | 14.45 | 8.88 | -1.92 | 10.22 | 57.83 | 2/2 | 16/18 | 14.95 | 13.95 | 1.31 |
| mtf_D1=BEARISH & prev_day_low_distance_atr=Q3 | 60min | COMPRA | 2,567 | 1,921 | 2.92 | nao | 2.91 | 1 | 30.76 | 27.19 | 27.19 | 8.83 | -1.92 | 9.61 | 62.42 | 2/2 | 10/10 | 23.37 | 31.01 | 3.57 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 60min | COMPRA | 4,619 | 2,606 | 2.40 | nao | 3.40 | 1 | 17.06 | 15.86 | 15.86 | 8.65 | -1.92 | 9.48 | 59.21 | 2/2 | 12/14 | 9.92 | 21.81 | 1.19 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 120min | COMPRA | 1,200 | 839 | 2.41 | nao | 1.91 | 1 | 54.33 | 48.21 | 48.21 | 8.18 | -1.92 | 8.54 | 63.65 | 2/2 | 11/14 | 20.60 | 75.76 | 6.11 |
| mtf_M15=BEARISH & news_min_to_next_high=Q5 | 120min | COMPRA | 2,264 | 1,132 | 2.11 | nao | 1.93 | 1 | 45.37 | 43.49 | 43.49 | 7.76 | -1.92 | 8.18 | 66.52 | 2/2 | 13/18 | 34.98 | 52.00 | 1.88 |
| previous_high_distance_atr=Q1 & news_min_to_next_high=Q5 | 120min | COMPRA | 1,426 | 538 | 2.29 | nao | 1.72 | 1 | 67.99 | 66.14 | 66.14 | 7.71 | -1.92 | 7.98 | 72.12 | 2/2 | 16/18 | 75.08 | 57.21 | 1.85 |
| swing_high_distance_atr=Q1 & news_min_to_next_high=Q5 | 120min | COMPRA | 1,313 | 665 | 2.12 | nao | 1.86 | 1 | 54.58 | 52.60 | 52.60 | 7.70 | -1.92 | 8.01 | 70.08 | 2/2 | 16/18 | 57.70 | 47.51 | 1.98 |
| mtf_H1=BULLISH & price_position_monthly_open=Q2 | 60min | COMPRA | 4,231 | 2,772 | 2.54 | nao | 2.40 | 1 | 18.53 | 14.17 | 14.17 | 7.63 | -1.92 | 8.51 | 55.16 | 2/2 | 12/18 | 13.66 | 14.68 | 4.36 |
| session=NEW_YORK & news_min_to_next_high=Q5 | 120min | COMPRA | 3,258 | 2,036 | 2.03 | nao | 2.01 | 1 | 24.43 | 22.65 | 22.65 | 7.34 | -1.92 | 7.86 | 60.66 | 2/2 | 16/18 | 24.83 | 20.47 | 1.78 |
| news_min_to_next_high=Q5 & cost_atr=Q5 | 60min | COMPRA | 1,823 | 2,341 | 2.62 | nao | 2.47 | 1 | 11.81 | 10.11 | 10.11 | 7.18 | -1.92 | 7.86 | 57.37 | 2/2 | 14/18 | 9.56 | 10.66 | 1.70 |
| mtf_D1=BEARISH & price_position_weekly_open=Q3 | 60min | COMPRA | 2,378 | 2,415 | 2.14 | nao | 1.78 | 1 | 21.49 | 14.53 | 14.53 | 6.92 | -1.92 | 7.77 | 55.20 | 2/2 | 8/10 | 30.55 | -1.48 | 6.96 |
| price_position_daily_open=Q4 & price_position_monthly_open=Q2 | 30min | COMPRA | 3,319 | 1,851 | 2.03 | nao | 2.49 | 1 | 14.60 | 12.68 | 12.68 | 6.86 | -3.29 | 8.66 | 55.38 | 2/2 | 13/18 | 12.58 | 12.77 | 1.93 |
| session=LONDON_NY_OVERLAP & news_state=NONE_60M | 60min | COMPRA | 4,490 | 3,111 | 2.21 | nao | 2.83 | 1 | 17.47 | 16.48 | 16.48 | 6.84 | -1.92 | 7.84 | 58.79 | 2/2 | 13/18 | 18.05 | 14.91 | 0.99 |
| day_of_week=SUNDAY & session=NEW_YORK | 120min | COMPRA | 323 | 345 | 2.80 | nao | 3.77 | 2 | 150.72 | 43.36 | 43.36 | 6.77 | -1.92 | 7.02 | 61.45 | 2/2 | 11/14 | 50.15 | 36.62 | 107.36 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 60min | COMPRA | 1,612 | 1,237 | 2.24 | nao | 1.70 | 1 | 20.14 | 19.10 | 19.10 | 6.63 | -1.92 | 7.25 | 58.53 | 1/2 | 13/18 | 32.85 | 5.37 | 1.04 |
| price_position_daily_open=Q3 & price_position_weekly_open=Q3 | 60min | COMPRA | 3,688 | 5,564 | 3.14 | nao | 3.68 | 1 | 17.17 | 7.31 | 7.31 | 6.26 | -1.92 | 7.34 | 55.88 | 2/2 | 13/18 | 5.95 | 8.68 | 9.86 |
| price_position_weekly_open=Q3 & price_position_monthly_open=Q2 | 30min | COMPRA | 3,284 | 2,206 | 2.08 | nao | 3.92 | 1 | 18.30 | 10.98 | 10.98 | 6.04 | -3.29 | 7.92 | 56.07 | 1/2 | 8/16 | 0.84 | 21.13 | 7.31 |
| hour=21 & session_high_distance_atr=Q5 | 120min | COMPRA | 178 | 197 | 2.07 | nao | 2.94 | 1 | 154.25 | 51.59 | 51.59 | 5.92 | -1.92 | 6.10 | 64.97 | 2/2 | 10/14 | 59.21 | 44.05 | 102.66 |

### M15 — modo `ret`

- eventos: 68,019 (2024-01-22 a 2026-10-16); descoberta 40,715 (até 2025-09-11), validação 27,208 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 220,756**; passaram no BH (q=5%) na descoberta: **147**; confirmadas na validação: **93**
- melhores N da descoberta que repetem na validação: top 100: 67.0%, top 1000: 41.8%, top 10000: 21.5%
- **placebo** (6 deslocamentos): top 100: 8.2% (máx 13.0%), top 1000: 6.5% (máx 10.4%), top 10000: 5.7% (máx 7.1%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 40,715 | -0.003 | -0.966 | -0.274 |
| 15min bruto | 40,144 | 0.002 | 0.370 | 0.161 |
| 30min bruto | 39,626 | 0.010 | 1.083 | 0.959 |
| 60min bruto | 38,710 | 0.023 | 1.231 | 2.296 |
| 120min bruto | 36,984 | 0.030 | 0.757 | 2.978 |
| 240min bruto | 33,560 | 0.064 | 0.739 | 6.349 |

**M15/ret: famílias distintas validadas: 1516; com líquido positivo e significativo na validação (custo realista): 227.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 120min | COMPRA | 923 | 591 | 2.47 | nao | 2.83 | 1 | 41.75 | 40.09 | 40.09 | 7.26 | 0.80 | 7.05 | 69.54 | 3/3 | 27/33 | 74.60 | 5.69 | 1.67 |
| prev_day_low_distance_atr=Q3 & atr_ratio=Q5 | 120min | COMPRA | 1,383 | 941 | 2.02 | nao | 2.83 | 1 | 50.30 | 47.52 | 47.52 | 7.22 | 0.80 | 7.21 | 63.44 | 3/3 | 22/34 | 53.55 | 41.50 | 2.78 |
| news_min_to_next_high=Q5 | 120min | COMPRA | 4,279 | 2,778 | 2.56 | nao | 3.75 | 1 | 26.02 | 21.02 | 21.02 | 7.07 | 0.80 | 6.83 | 58.71 | 2/3 | 26/34 | 21.13 | 20.91 | 5.00 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 60min | COMPRA | 1,166 | 750 | 2.75 | nao | 3.72 | 1 | 26.08 | 24.54 | 24.54 | 6.82 | -1.02 | 7.06 | 62.40 | 3/3 | 27/34 | 37.84 | 11.24 | 1.54 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 120min | COMPRA | 651 | 615 | 2.01 | nao | 2.84 | 1 | 60.00 | 54.32 | 54.32 | 6.82 | 0.80 | 6.78 | 62.28 | 3/3 | 19/24 | 70.75 | 37.96 | 5.68 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 120min | COMPRA | 1,488 | 1,772 | 2.50 | nao | 3.43 | 1 | 28.04 | 22.51 | 22.51 | 6.27 | 0.80 | 6.03 | 58.24 | 3/3 | 18/22 | 24.86 | 20.16 | 5.53 |
| month=12 & prev_day_high_distance_atr=Q5 | 120min | COMPRA | 474 | 388 | 2.03 | nao | 1.81 | 1 | 56.79 | 54.84 | 54.84 | 5.82 | 0.80 | 5.76 | 58.76 | 2/2 | 2/2 | 55.52 | 54.17 | 1.95 |
| news_min_to_next_high=Q5 & cum3=Q1 | 60min | COMPRA | 822 | 514 | 2.04 | nao | 4.11 | 1 | 35.06 | 28.83 | 28.83 | 5.76 | -1.02 | 5.97 | 64.01 | 3/3 | 27/34 | 27.95 | 29.72 | 6.23 |
| price_position_weekly_open=Q2 & news_min_to_next_high=Q5 | 120min | COMPRA | 903 | 594 | 2.28 | nao | 2.09 | 1 | 40.38 | 35.19 | 35.19 | 5.74 | 0.80 | 5.59 | 60.27 | 3/3 | 24/32 | 3.97 | 66.40 | 5.20 |
| news_min_to_next_high=Q5 | 60min | COMPRA | 5,168 | 3,357 | 3.06 | nao | 4.56 | 1 | 15.64 | 11.32 | 11.32 | 5.64 | -1.02 | 6.26 | 56.78 | 2/3 | 26/34 | 10.98 | 11.65 | 4.32 |
| direction=BEARISH & news_min_to_next_high=Q5 | 60min | COMPRA | 2,451 | 1,533 | 2.60 | nao | 3.88 | 1 | 21.89 | 16.70 | 16.70 | 5.56 | -1.02 | 5.95 | 59.49 | 3/3 | 25/34 | 16.71 | 16.69 | 5.19 |
| day_of_week=WEDNESDAY & hour=18 | 60min | COMPRA | 333 | 228 | 2.38 | nao | 2.94 | 1 | 54.21 | 53.16 | 53.16 | 5.45 | -1.02 | 5.56 | 65.35 | 3/3 | 26/34 | 70.91 | 35.41 | 1.05 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 60min | COMPRA | 1,789 | 2,137 | 3.06 | nao | 4.29 | 1 | 16.54 | 11.77 | 11.77 | 5.01 | -1.02 | 5.44 | 56.76 | 3/3 | 18/22 | 12.85 | 10.69 | 4.77 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 60min | COMPRA | 699 | 651 | 2.77 | nao | 3.14 | 1 | 32.52 | 27.10 | 27.10 | 5.00 | -1.02 | 5.24 | 57.45 | 3/3 | 19/24 | 37.64 | 16.58 | 5.42 |
| volume_ratio=Q5 & news_min_to_next_high=Q5 | 60min | COMPRA | 361 | 225 | 2.30 | nao | 2.30 | 1 | 53.71 | 52.16 | 52.16 | 4.99 | -1.02 | 5.10 | 64.00 | 3/3 | 29/32 | 39.92 | 64.30 | 1.55 |
| mtf_M30=BULLISH & dom_w=d15_21 | 120min | COMPRA | 2,867 | 2,258 | 2.05 | nao | 2.05 | 1 | 25.51 | 20.17 | 20.17 | 4.94 | 0.80 | 4.91 | 54.38 | 3/3 | 22/33 | 30.57 | 9.78 | 5.34 |
| mtf_D1=BEARISH & prev_day_low_distance_atr=Q3 | 60min | COMPRA | 2,549 | 975 | 2.00 | nao | 2.52 | 1 | 28.50 | 23.66 | 23.66 | 4.86 | -1.02 | 5.16 | 57.54 | 3/3 | 18/21 | 32.66 | 14.68 | 4.83 |
| day_of_week=SUNDAY & hour=21 | 120min | COMPRA | 214 | 155 | 2.14 | nao | 4.44 | 2 | 149.74 | 51.65 | 51.65 | 4.75 | 0.80 | 4.66 | 61.94 | 2/3 | 15/24 | 77.12 | 26.51 | 98.09 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 30min | COMPRA | 1,206 | 778 | 2.80 | nao | 3.80 | 1 | 13.57 | 12.05 | 12.05 | 4.75 | -3.12 | 5.95 | 56.43 | 3/3 | 27/34 | 18.03 | 6.07 | 1.52 |
| mtf_D1=BEARISH & news_min_to_next_high=Q5 | 60min | COMPRA | 1,485 | 687 | 2.19 | nao | 2.73 | 1 | 22.68 | 19.69 | 19.69 | 4.74 | -1.02 | 4.98 | 57.93 | 2/3 | 17/20 | 17.89 | 21.49 | 2.99 |
| day_of_week=SUNDAY & session=NEW_YORK | 60min | COMPRA | 214 | 155 | 4.28 | sim | 7.25 | 2 | 145.19 | 47.10 | 47.10 | 4.56 | -1.02 | 4.65 | 61.29 | 2/3 | 16/24 | 70.56 | 23.95 | 98.09 |
| month=6 & dom_w=d15_21 | 120min | COMPRA | 862 | 430 | 2.42 | nao | 1.70 | 1 | 30.75 | 25.98 | 25.98 | 4.51 | 0.80 | 4.32 | 53.95 | 3/3 | 3/3 | 7.07 | 44.90 | 4.77 |
| slot_hhmm=09:30 & mtf_D1=BULLISH | 15min | COMPRA | 157 | 137 | 3.74 | nao | 4.57 | 1 | 19.38 | 18.43 | 18.43 | 4.47 | -4.22 | 5.47 | 63.50 | 3/3 | 23/24 | 25.65 | 11.31 | 0.95 |
| price_position_weekly_open=Q2 & news_min_to_next_high=Q5 | 60min | COMPRA | 1,096 | 711 | 2.69 | nao | 2.60 | 1 | 22.14 | 17.62 | 17.62 | 4.24 | -1.02 | 4.49 | 56.54 | 3/3 | 24/32 | 0.88 | 34.32 | 4.52 |
| news_min_to_next_high=Q5 & atr_ratio=Q4 | 60min | COMPRA | 1,219 | 846 | 2.19 | nao | 2.56 | 1 | 18.46 | 16.25 | 16.25 | 4.13 | -1.02 | 4.40 | 55.56 | 3/3 | 28/34 | 22.97 | 9.53 | 2.21 |

### M30 — modo `ret`

- eventos: 33,970 (2024-01-22 a 2026-10-16); descoberta 20,334 (até 2025-09-11), validação 13,588 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 190,467**; passaram no BH (q=5%) na descoberta: **212**; confirmadas na validação: **126**
- melhores N da descoberta que repetem na validação: top 100: 64.0%, top 1000: 42.0%, top 10000: 23.4%
- **placebo** (6 deslocamentos): top 100: 8.0% (máx 23.0%), top 1000: 8.5% (máx 14.0%), top 10000: 8.0% (máx 8.9%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 20,334 | -0.009 | -2.675 | -1.256 |
| 15min bruto | 20,259 | -0.015 | -3.106 | -2.179 |
| 30min bruto | 19,782 | 0.004 | 0.586 | 0.518 |
| 60min bruto | 19,319 | 0.012 | 0.916 | 1.680 |
| 120min bruto | 18,455 | 0.020 | 0.733 | 2.869 |
| 240min bruto | 16,743 | 0.041 | 0.684 | 6.006 |

**M30/ret: famílias distintas validadas: 2187; com líquido positivo e significativo na validação (custo realista): 310.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| price_position_monthly_open=Q3 & news_min_to_next_high=Q5 | 120min | COMPRA | 428 | 459 | 2.15 | nao | 4.71 | 1 | 54.78 | 46.91 | 46.91 | 7.63 | 0.33 | 7.47 | 65.58 | 3/3 | 22/31 | 33.41 | 60.34 | 7.87 |
| mtf_M15=BULLISH & dom_w=d15_21 | 120min | COMPRA | 1,408 | 1,094 | 2.32 | nao | 2.47 | 1 | 28.74 | 23.63 | 23.63 | 4.41 | 0.33 | 4.45 | 54.57 | 3/3 | 23/33 | 27.02 | 20.24 | 5.11 |
| price_position_weekly_open=Q2 & news_min_to_next_high=Q5 | 120min | COMPRA | 419 | 281 | 2.33 | nao | 2.62 | 1 | 45.11 | 38.29 | 38.29 | 4.38 | 0.33 | 4.33 | 62.63 | 3/3 | 22/31 | 9.49 | 66.88 | 6.82 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 120min | COMPRA | 398 | 255 | 2.22 | nao | 2.48 | 1 | 38.72 | 36.70 | 36.70 | 4.30 | 0.33 | 4.23 | 69.80 | 3/3 | 26/33 | 74.09 | -0.39 | 2.02 |
| month=6 & dom_w=d15_21 | 240min | COMPRA | 391 | 191 | 2.41 | nao | 1.66 | 1 | 58.12 | 52.16 | 52.16 | 4.20 | 1.83 | 4.00 | 60.21 | 3/3 | 3/3 | 17.49 | 86.47 | 5.96 |
| session=ASIA & prev_day_low_distance_atr=Q3 | 120min | COMPRA | 1,434 | 1,066 | 2.34 | nao | 1.69 | 1 | 26.17 | 25.25 | 25.25 | 4.19 | 0.33 | 4.28 | 56.47 | 3/3 | 27/34 | 39.24 | 11.26 | 0.92 |
| news_min_to_next_high=Q5 | 120min | COMPRA | 1,970 | 1,295 | 2.38 | nao | 3.52 | 1 | 24.78 | 18.02 | 18.02 | 4.14 | 0.33 | 4.08 | 58.46 | 2/3 | 26/34 | 19.92 | 16.12 | 6.76 |
| session=ASIA & session_high_distance_atr=Q3 | 120min | COMPRA | 1,139 | 771 | 2.25 | nao | 1.83 | 1 | 28.71 | 27.79 | 27.79 | 4.08 | 0.33 | 4.12 | 60.18 | 3/3 | 25/34 | 38.24 | 17.37 | 0.91 |
| mtf_W1=BREAK_UP & news_min_to_next_high=Q3 | 120min | COMPRA | 162 | 256 | 2.08 | nao | 1.97 | 1 | 38.82 | 37.91 | 37.91 | 3.98 | 0.33 | 3.94 | 62.11 | 3/3 | 6/10 | 62.55 | 13.28 | 0.91 |
| month=12 & prev_day_high_distance_atr=Q5 | 120min | COMPRA | 234 | 193 | 2.08 | nao | 1.68 | 1 | 55.95 | 53.01 | 53.01 | 3.88 | 0.33 | 3.87 | 56.99 | 2/2 | 2/2 | 54.20 | 51.84 | 2.93 |
| previous_high_distance_atr=Q4 & prev_day_low_distance_atr=Q2 | 60min | COMPRA | 660 | 393 | 2.12 | nao | 3.03 | 1 | 31.77 | 26.80 | 26.80 | 3.88 | -1.96 | 4.21 | 57.76 | 3/3 | 25/34 | 40.58 | 13.09 | 4.97 |
| swing_low_distance_atr=Q3 & news_min_to_next_high=Q5 | 120min | COMPRA | 341 | 282 | 2.28 | nao | 2.44 | 1 | 35.12 | 28.22 | 28.22 | 3.82 | 0.33 | 3.73 | 62.41 | 3/3 | 23/33 | 3.88 | 52.57 | 6.90 |
| hour=19 & swing_high_distance_atr=Q2 | 30min | COMPRA | 131 | 82 | 2.20 | nao | 3.47 | 1 | 27.93 | 26.87 | 26.87 | 3.60 | -4.07 | 4.11 | 68.29 | 3/3 | 19/26 | 21.19 | 32.54 | 1.06 |
| hour=9 & cost_atr=Q2 | 5min | VENDA | 195 | 71 | -3.68 | nao | -3.65 | 1 | 21.55 | 20.61 | 20.59 | 3.55 | -3.30 | 4.10 | 70.42 | 3/3 | 18/21 | 23.03 | 18.22 | 0.96 |
| hour=0 & structure_at_close=BULLISH | 5min | COMPRA | 224 | 196 | 2.41 | nao | 3.74 | 1 | 11.94 | 10.99 | 10.99 | 3.54 | -6.17 | 5.53 | 59.18 | 3/3 | 24/33 | 15.16 | 6.82 | 0.95 |
| mtf_M30=BULLISH & volume_ratio=Q5 | 30min | COMPRA | 1,181 | 817 | 2.50 | nao | 3.48 | 2 | 14.66 | 13.71 | 13.71 | 3.52 | -4.07 | 4.72 | 52.51 | 3/3 | 26/34 | 18.66 | 8.77 | 0.96 |
| day_of_week=WEDNESDAY & hour=18 | 60min | COMPRA | 166 | 114 | 2.37 | nao | 2.86 | 1 | 48.89 | 47.85 | 47.85 | 3.50 | -1.96 | 3.65 | 64.91 | 3/3 | 24/32 | 59.71 | 35.99 | 1.05 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 120min | COMPRA | 689 | 831 | 2.51 | nao | 3.10 | 1 | 25.79 | 18.27 | 18.27 | 3.49 | 0.33 | 3.42 | 57.64 | 3/3 | 18/22 | 19.11 | 17.43 | 7.52 |
| structure_at_close=BULLISH & volume_ratio=Q5 | 60min | COMPRA | 1,085 | 745 | 2.08 | nao | 2.62 | 1 | 20.91 | 19.95 | 19.95 | 3.49 | -1.96 | 3.95 | 54.36 | 3/3 | 22/34 | 27.51 | 12.41 | 0.95 |
| slot_hhmm=18:30 & direction=BEARISH | 60min | COMPRA | 224 | 126 | 2.09 | nao | 2.61 | 1 | 35.20 | 34.16 | 34.16 | 3.45 | -1.96 | 3.64 | 67.46 | 3/3 | 25/33 | 17.07 | 51.25 | 1.04 |
| prev_day_low_distance_atr=Q4 & atr_ratio=Q1 | 240min | COMPRA | 959 | 717 | 2.05 | nao | 1.78 | 1 | 33.50 | 27.43 | 27.43 | 3.40 | 1.83 | 3.16 | 54.81 | 3/3 | 23/34 | 2.53 | 52.26 | 6.08 |
| volume_ratio=Q5 & previous_low_distance_atr=Q5 | 120min | COMPRA | 637 | 438 | 2.06 | nao | 1.73 | 1 | 32.05 | 31.10 | 31.10 | 3.39 | 0.33 | 3.39 | 57.08 | 3/3 | 24/33 | 30.12 | 32.08 | 0.95 |
| structure_at_close=BULLISH & session_high_distance_atr=Q3 | 120min | COMPRA | 1,619 | 1,170 | 2.33 | nao | 2.09 | 1 | 24.63 | 18.53 | 18.53 | 3.37 | 0.33 | 3.42 | 55.73 | 3/3 | 25/34 | 27.25 | 9.82 | 6.10 |
| mtf_M15=BULLISH & session_high_distance_atr=Q3 | 120min | COMPRA | 1,484 | 1,010 | 2.03 | nao | 2.13 | 1 | 25.78 | 18.78 | 18.78 | 3.35 | 0.33 | 3.36 | 57.03 | 3/3 | 24/34 | 27.52 | 10.04 | 7.00 |
| direction=BEARISH & news_min_to_next_high=Q5 | 60min | COMPRA | 1,193 | 720 | 2.18 | nao | 3.64 | 1 | 21.14 | 14.52 | 14.52 | 3.33 | -1.96 | 3.81 | 58.61 | 3/3 | 23/34 | 11.36 | 17.68 | 6.62 |

### H1 — modo `ret`

- eventos: 33,106 (2021-06-07 a 2026-10-16); descoberta 19,839 (até 2024-08-26), validação 13,243 (a partir de 2024-08-27)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 194,150**; passaram no BH (q=5%) na descoberta: **3,399**; confirmadas na validação: **1,660**
- melhores N da descoberta que repetem na validação: top 100: 100.0%, top 1000: 75.6%, top 10000: 33.4%
- **placebo** (6 deslocamentos): top 100: 44.8% (máx 58.0%), top 1000: 31.3% (máx 42.4%), top 10000: 19.7% (máx 25.4%); BH: média 150.5 (máx 408); confirmadas: média 54.3 (máx 136)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 19,839 | -0.015 | -7.174 | -3.037 |
| 15min bruto | 19,780 | -0.015 | -4.667 | -2.948 |
| 30min bruto | 19,710 | -0.006 | -1.546 | -1.237 |
| 60min bruto | 18,822 | 0.013 | 2.176 | 2.706 |
| 120min bruto | 17,911 | 0.029 | 2.196 | 5.876 |
| 240min bruto | 16,135 | 0.063 | 2.100 | 12.703 |

**H1/ret: famílias distintas validadas: 4765; com líquido positivo e significativo na validação (custo realista): 893.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| previous_low_distance_atr=Q3 & atr_ratio=Q1 | 120min | COMPRA | 823 | 518 | 2.17 | nao | 4.63 | 1 | 55.64 | 50.57 | 50.57 | 5.50 | -0.45 | 5.60 | 60.81 | 6/6 | 39/58 | 71.70 | 29.43 | 5.07 |
| day_of_week=FRIDAY & month=6 | 240min | COMPRA | 257 | 133 | 2.50 | nao | 2.46 | 1 | 103.81 | 99.08 | 99.08 | 5.34 | 0.84 | 5.24 | 63.16 | 6/6 | 6/6 | 182.42 | 16.98 | 4.73 |
| session=ASIA & atr_ratio=Q1 | 240min | COMPRA | 1,886 | 1,046 | 2.36 | nao | 2.55 | 1 | 41.26 | 40.30 | 40.30 | 4.95 | 0.84 | 4.86 | 56.88 | 6/6 | 39/65 | 66.85 | 13.76 | 0.96 |
| swing_high_distance_atr=Q5 & atr_ratio=Q1 | 240min | COMPRA | 751 | 526 | 2.05 | nao | 2.68 | 1 | 61.45 | 58.90 | 58.90 | 4.88 | 0.84 | 4.83 | 58.56 | 5/6 | 37/56 | 81.31 | 36.49 | 2.55 |
| price_position_monthly_open=Q5 & atr_ratio=Q1 | 240min | COMPRA | 702 | 419 | 2.25 | nao | 2.43 | 1 | 63.59 | 60.08 | 60.08 | 4.66 | 0.84 | 4.60 | 57.76 | 5/5 | 16/20 | 75.94 | 44.29 | 3.51 |
| hour=2 & volume_ratio=Q2 | 5min | VENDA | 381 | 270 | -2.71 | nao | -4.12 | 2 | 13.24 | 12.36 | 12.37 | 4.63 | -1.60 | 5.19 | 59.63 | 5/6 | 44/64 | 21.45 | 3.29 | 0.87 |
| session_low_distance_atr=Q5 & cost_atr=Q4 | 240min | COMPRA | 609 | 278 | 2.14 | nao | 2.13 | 1 | 58.93 | 57.94 | 57.94 | 4.24 | 0.84 | 4.14 | 60.07 | 5/6 | 35/50 | 97.28 | 18.60 | 0.99 |
| hour=2 & news_state=NONE_60M | 5min | VENDA | 211 | 550 | -2.82 | nao | -4.30 | 2 | 9.00 | 8.11 | 8.12 | 4.22 | -1.60 | 5.02 | 56.00 | 3/4 | 30/37 | 13.00 | 3.24 | 0.88 |
| hour=23 & swing_low_distance_atr=Q1 | 5min | VENDA | 126 | 93 | -2.80 | nao | -3.90 | 2 | 39.39 | 38.39 | 38.38 | 4.21 | -1.60 | 4.38 | 64.52 | 4/6 | 15/19 | 48.15 | 28.81 | 1.01 |
| hour=2 | 5min | VENDA | 838 | 554 | -2.79 | nao | -4.17 | 5 | 8.77 | 7.88 | 7.89 | 4.10 | -1.60 | 4.90 | 55.78 | 6/6 | 45/65 | 13.03 | 2.74 | 0.88 |
| mtf_W1=BULLISH & month=6 | 240min | COMPRA | 1,143 | 320 | 2.15 | nao | 1.95 | 1 | 38.36 | 31.78 | 31.78 | 3.94 | 0.84 | 3.60 | 60.31 | 5/5 | 5/5 | 22.93 | 40.62 | 6.58 |
| news_min_to_next_high=Q3 & atr_ratio=Q1 | 240min | COMPRA | 217 | 480 | 2.19 | nao | 2.07 | 1 | 49.96 | 49.00 | 49.00 | 3.92 | 0.84 | 3.87 | 57.08 | 4/4 | 24/35 | 66.10 | 31.90 | 0.96 |
| dow_slot=SUNDAY|23:00 | 5min | VENDA | 166 | 111 | -4.50 | sim | -3.99 | 7 | 34.66 | 33.66 | 33.63 | 3.90 | -1.60 | 4.10 | 63.96 | 6/6 | 17/21 | 42.74 | 24.69 | 1.03 |
| price_position_weekly_open=Q2 & gap=Y | 30min | COMPRA | 124 | 81 | 8.03 | sim | 8.80 | 1 | 124.07 | 58.94 | 58.94 | 3.78 | -5.70 | 4.14 | 66.67 | 6/6 | 9/10 | 32.33 | 84.90 | 65.13 |
| mtf_H1=BULLISH & prev_day_low_distance_atr=Q2 | 120min | COMPRA | 586 | 410 | 2.29 | nao | 4.42 | 2 | 53.09 | 44.05 | 44.05 | 3.78 | -0.45 | 3.87 | 62.20 | 6/6 | 46/63 | 25.94 | 62.17 | 9.04 |
| price_position_monthly_open=Q5 & atr_ratio=Q1 | 120min | COMPRA | 741 | 443 | 2.26 | nao | 2.97 | 1 | 35.61 | 32.23 | 32.23 | 3.75 | -0.45 | 3.80 | 56.88 | 5/5 | 16/20 | 32.05 | 32.42 | 3.38 |
| day_of_week=SUNDAY & cost_atr=Q5 | 30min | COMPRA | 164 | 115 | 6.24 | sim | 8.69 | 1 | 113.01 | 51.37 | 51.37 | 3.74 | -5.70 | 4.16 | 63.48 | 5/6 | 17/20 | 55.49 | 47.33 | 61.63 |
| cost_atr=Q5 & gap=Y | 30min | COMPRA | 143 | 111 | 7.36 | sim | 9.17 | 1 | 118.74 | 52.87 | 52.87 | 3.71 | -5.70 | 4.11 | 64.86 | 5/6 | 14/17 | 46.44 | 59.20 | 65.86 |
| hour=18 & structure_at_close=RANGE | 60min | COMPRA | 146 | 113 | 2.27 | nao | 3.98 | 2 | 36.91 | 35.87 | 35.87 | 3.70 | -3.16 | 3.99 | 62.83 | 6/6 | 19/27 | 31.19 | 40.47 | 1.04 |
| day_of_week=MONDAY & atr_ratio=Q1 | 120min | COMPRA | 757 | 462 | 2.14 | nao | 3.24 | 1 | 36.40 | 29.10 | 29.10 | 3.69 | -0.45 | 3.73 | 54.33 | 5/6 | 36/51 | 48.72 | 9.48 | 7.31 |
| slot_hhmm=23:00 & direction=BEARISH | 5min | VENDA | 383 | 249 | -3.33 | sim | -3.69 | 2 | 18.75 | 17.73 | 17.68 | 3.66 | -1.60 | 4.03 | 61.04 | 6/6 | 45/61 | 21.94 | 13.46 | 1.06 |
| mtf_M1=BULLISH & upper_wick_pct=Q5 | 5min | VENDA | 1,432 | 997 | -3.45 | sim | -5.61 | 1 | 10.69 | 4.97 | 6.56 | 3.65 | -1.60 | 4.63 | 52.66 | 4/6 | 40/65 | 11.53 | 1.61 | 4.12 |
| slot_hhmm=22:00 & prev_day_high_distance_atr=Q4 | 30min | COMPRA | 284 | 173 | 2.16 | nao | 5.00 | 2 | 34.16 | 23.45 | 23.45 | 3.65 | -5.70 | 4.51 | 54.91 | 6/6 | 34/55 | 40.16 | 6.93 | 10.71 |
| session=LONDON & news_state=NONE_60M | 5min | VENDA | 1,009 | 2,517 | -3.06 | nao | -5.06 | 1 | 4.55 | 3.56 | 3.55 | 3.58 | -1.60 | 5.24 | 52.96 | 4/4 | 25/37 | 5.29 | 1.81 | 1.00 |
| news_min_since_last_high=Q5 & range_atr_prev=Q2 | 30min | VENDA | 140 | 342 | -2.67 | nao | -3.37 | 1 | 29.72 | 28.54 | 28.52 | 3.56 | -3.20 | 4.02 | 55.26 | 4/4 | 29/36 | 36.43 | 20.62 | 1.19 |

## 6.2 Modo `hit`

### M5 — modo `hit`

- eventos: 105,989 (2025-05-15 a 2026-10-16); descoberta 63,306 (até 2026-03-23), validação 42,396 (a partir de 2026-03-24)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 626,514**; passaram no BH (q=5%) na descoberta: **8**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 5.0%, top 1000: 3.2%, top 10000: 2.9%
- **placebo** (6 deslocamentos): top 100: 3.8% (máx 8.0%), top 1000: 2.6% (máx 3.9%), top 10000: 1.6% (máx 2.3%); BH: média 9.7 (máx 22); confirmadas: média 0.3 (máx 2)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 62,847 | -0.138 |  | -6.622 |
| C alvo 0.5ATR/60min liquido | 60,844 | -0.129 |  | -6.169 |
| C alvo 0.5ATR/240min liquido | 52,884 | -0.148 |  | -7.090 |
| C alvo 1.0ATR/15min liquido | 62,847 | -0.123 |  | -5.881 |
| C alvo 1.0ATR/60min liquido | 60,844 | -0.105 |  | -5.053 |
| C alvo 1.0ATR/240min liquido | 52,884 | -0.132 |  | -6.334 |
| C alvo 2.0ATR/15min liquido | 62,847 | -0.113 |  | -5.397 |
| C alvo 2.0ATR/60min liquido | 60,844 | -0.072 |  | -3.428 |
| C alvo 2.0ATR/240min liquido | 52,884 | -0.117 |  | -5.623 |
| V alvo 0.5ATR/15min liquido | 62,847 | -0.148 |  | -7.113 |
| V alvo 0.5ATR/60min liquido | 60,844 | -0.164 |  | -7.843 |
| V alvo 0.5ATR/240min liquido | 52,884 | -0.185 |  | -8.847 |
| V alvo 1.0ATR/15min liquido | 62,847 | -0.136 |  | -6.510 |
| V alvo 1.0ATR/60min liquido | 60,844 | -0.153 |  | -7.326 |
| V alvo 1.0ATR/240min liquido | 52,884 | -0.195 |  | -9.327 |
| V alvo 2.0ATR/15min liquido | 62,847 | -0.129 |  | -6.197 |
| V alvo 2.0ATR/60min liquido | 60,844 | -0.146 |  | -6.976 |
| V alvo 2.0ATR/240min liquido | 52,884 | -0.205 |  | -9.825 |

**M5/hit: famílias distintas validadas: 17; com líquido positivo e significativo na validação (custo realista): 16.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| news_state=EVENTS_3_AROUND_60M & price_position_monthly_open=Q5 | V alvo 1.0ATR ate 60min | VENDA | 344 | 53 | 2.76 | nao | 7.75 | 1 |  | 41.96 | 41.96 | 13.04 | -7.47 | 15.11 | 96.23 | 2/2 | 8/8 | 50.59 | 33.66 | 0.95 |
| news_state=EVENTS_3_AROUND_60M & price_position_monthly_open=Q5 | V alvo 0.5ATR ate 60min | VENDA | 344 | 53 | 2.31 | nao | 7.12 | 1 |  | 20.61 | 20.61 | 12.95 | -6.72 | 16.68 | 98.11 | 2/2 | 8/8 | 25.21 | 16.18 | 0.95 |
| day_of_week=FRIDAY & month=3 | C alvo 2.0ATR ate 240min | COMPRA | 624 | 204 | 2.74 | nao | 1.96 | 1 |  | 58.38 | 58.38 | 12.83 | -5.89 | 13.59 | 85.29 | 1/1 | 1/1 | 33.39 | 83.38 | 1.27 |
| mtf_D1=BEARISH & prev_day_low_distance_atr=Q3 | C alvo 2.0ATR ate 60min | COMPRA | 2,567 | 1,921 | 2.24 | nao | 2.45 | 1 |  | 23.96 | 23.96 | 9.46 | -2.49 | 10.54 | 65.59 | 2/2 | 10/10 | 23.07 | 24.85 | 3.57 |
| mtf_M15=RANGE & mtf_H4=BREAK_DOWN | C alvo 0.5ATR ate 60min | COMPRA | 448 | 109 | 2.01 | nao | 2.49 | 1 |  | 27.84 | 27.84 | 8.79 | -4.65 | 10.12 | 91.74 | 2/2 | 13/14 | 29.87 | 25.85 | 2.16 |
| hour=19 & news_min_to_next_high=Q4 | C alvo 2.0ATR ate 60min | COMPRA | 561 | 671 | 2.23 | nao | 1.86 | 1 |  | 16.21 | 16.21 | 5.55 | -2.49 | 6.32 | 65.87 | 2/2 | 12/14 | 6.71 | 25.67 | 1.09 |
| hour=19 & news_min_to_next_high=Q4 | C alvo 2.0ATR ate 15min | COMPRA | 612 | 732 | 2.29 | nao | 2.41 | 1 |  | 5.94 | 5.94 | 3.73 | -4.18 | 6.29 | 54.92 | 2/2 | 12/14 | 3.05 | 8.83 | 1.09 |
| hour=14 & mtf_W1=BEARISH | C alvo 2.0ATR ate 15min | COMPRA | 504 | 240 | 2.13 | nao | 2.02 | 1 |  | 22.47 | 22.47 | 3.70 | -4.18 | 4.40 | 59.58 | 2/2 | 5/5 | 31.61 | 13.32 | 1.01 |
| hour=18 & mtf_M30=BEARISH | C alvo 2.0ATR ate 15min | COMPRA | 996 | 456 | 2.09 | nao | 2.39 | 1 |  | 8.64 | 8.64 | 3.59 | -4.18 | 5.31 | 54.82 | 2/2 | 14/18 | 9.52 | 7.76 | 1.08 |
| day_of_week=FRIDAY & mtf_M30=BREAK_DOWN | C alvo 1.0ATR ate 15min | COMPRA | 501 | 273 | 2.07 | nao | 1.90 | 1 |  | 20.51 | 20.51 | 3.39 | -4.77 | 4.19 | 65.57 | 2/2 | 15/18 | 28.59 | 12.48 | 1.29 |
| mtf_H4=BREAK_DOWN & dom_w=d15_21 | C alvo 2.0ATR ate 60min | COMPRA | 540 | 84 | 2.27 | nao | 1.76 | 1 |  | 41.58 | 41.58 | 3.29 | -2.49 | 3.46 | 71.43 | 2/2 | 6/7 | 64.85 | 18.30 | 1.85 |
| hour=9 & price_position_weekly_open=Q3 | C alvo 2.0ATR ate 15min | COMPRA | 534 | 441 | 2.79 | nao | 2.87 | 1 |  | 5.10 | 5.10 | 2.93 | -4.18 | 5.27 | 60.09 | 2/2 | 15/17 | 4.25 | 5.95 | 0.99 |
| hour=18 & price_position_daily_open=Q3 | C alvo 1.0ATR ate 15min | COMPRA | 272 | 316 | 2.20 | nao | 1.98 | 1 |  | 5.86 | 5.86 | 2.91 | -4.77 | 5.23 | 62.03 | 2/2 | 13/15 | 11.48 | 0.24 | 1.07 |
| hour=11 & mtf_M30=BREAK_UP | V alvo 0.5ATR ate 15min | VENDA | 210 | 66 | 2.71 | nao | 1.82 | 1 |  | 6.98 | 6.98 | 2.87 | -6.21 | 5.36 | 83.33 | 2/2 | 15/17 | 7.12 | 6.85 | 1.02 |
| hour=0 & mtf_M15=BREAK_UP | C alvo 1.0ATR ate 15min | COMPRA | 294 | 168 | 2.31 | nao | 1.79 | 1 |  | 9.13 | 9.13 | 2.58 | -4.77 | 3.92 | 61.90 | 2/2 | 11/17 | 6.92 | 11.34 | 1.10 |
| hour=9 & price_position_weekly_open=Q3 | C alvo 1.0ATR ate 15min | COMPRA | 534 | 441 | 2.75 | nao | 2.93 | 1 |  | 3.93 | 3.93 | 2.58 | -4.77 | 5.63 | 62.36 | 2/2 | 13/17 | 4.60 | 3.26 | 0.99 |

### M15 — modo `hit`

- eventos: 68,019 (2024-01-22 a 2026-10-16); descoberta 40,715 (até 2025-09-11), validação 27,208 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 657,186**; passaram no BH (q=5%) na descoberta: **56**; confirmadas na validação: **15**
- melhores N da descoberta que repetem na validação: top 100: 24.0%, top 1000: 13.3%, top 10000: 5.3%
- **placebo** (6 deslocamentos): top 100: 2.5% (máx 7.0%), top 1000: 1.9% (máx 3.1%), top 10000: 1.2% (máx 1.7%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 40,131 | -0.066 |  | -6.565 |
| C alvo 0.5ATR/60min liquido | 38,697 | -0.060 |  | -5.927 |
| C alvo 0.5ATR/240min liquido | 33,547 | -0.087 |  | -8.577 |
| C alvo 1.0ATR/15min liquido | 40,131 | -0.062 |  | -6.102 |
| C alvo 1.0ATR/60min liquido | 38,697 | -0.052 |  | -5.155 |
| C alvo 1.0ATR/240min liquido | 33,547 | -0.096 |  | -9.553 |
| C alvo 2.0ATR/15min liquido | 40,131 | -0.058 |  | -5.763 |
| C alvo 2.0ATR/60min liquido | 38,697 | -0.051 |  | -5.042 |
| C alvo 2.0ATR/240min liquido | 33,547 | -0.107 |  | -10.565 |
| V alvo 0.5ATR/15min liquido | 40,131 | -0.059 |  | -5.832 |
| V alvo 0.5ATR/60min liquido | 38,697 | -0.059 |  | -5.821 |
| V alvo 0.5ATR/240min liquido | 33,547 | -0.074 |  | -7.345 |
| V alvo 1.0ATR/15min liquido | 40,131 | -0.053 |  | -5.286 |
| V alvo 1.0ATR/60min liquido | 38,697 | -0.055 |  | -5.466 |
| V alvo 1.0ATR/240min liquido | 33,547 | -0.092 |  | -9.087 |
| V alvo 2.0ATR/15min liquido | 40,131 | -0.047 |  | -4.692 |
| V alvo 2.0ATR/60min liquido | 38,697 | -0.052 |  | -5.110 |
| V alvo 2.0ATR/240min liquido | 33,547 | -0.093 |  | -9.238 |

**M15/hit: famílias distintas validadas: 212; com líquido positivo e significativo na validação (custo realista): 159.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=4 & news_min_to_next_high=Q3 | C alvo 2.0ATR ate 240min | COMPRA | 551 | 292 | 2.20 | nao | 1.67 | 1 |  | 53.12 | 53.12 | 7.01 | 0.37 | 6.85 | 66.78 | 2/3 | 2/3 | 39.89 | 66.34 | 0.89 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 1,166 | 750 | 2.78 | nao | 3.38 | 1 |  | 23.87 | 23.87 | 6.76 | -1.49 | 7.15 | 62.40 | 3/3 | 28/34 | 37.00 | 10.74 | 1.54 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 1,166 | 750 | 3.22 | nao | 3.20 | 1 |  | 20.09 | 20.09 | 6.41 | -2.62 | 7.21 | 64.40 | 3/3 | 27/34 | 29.48 | 10.70 | 1.54 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 1,166 | 750 | 2.36 | nao | 2.96 | 1 |  | 14.96 | 14.96 | 6.36 | -4.69 | 8.23 | 73.87 | 3/3 | 26/34 | 20.34 | 9.59 | 1.54 |
| day_of_week=WEDNESDAY & hour=18 | C alvo 1.0ATR ate 60min | COMPRA | 333 | 228 | 2.67 | nao | 3.10 | 1 |  | 32.35 | 32.35 | 5.99 | -2.62 | 6.44 | 69.30 | 3/3 | 28/34 | 47.46 | 17.23 | 1.05 |
| day_of_week=WEDNESDAY & hour=18 | C alvo 2.0ATR ate 60min | COMPRA | 333 | 228 | 2.26 | nao | 3.16 | 1 |  | 40.74 | 40.74 | 5.89 | -1.49 | 6.09 | 66.23 | 3/3 | 27/34 | 56.15 | 25.32 | 1.05 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 1,789 | 2,137 | 2.12 | nao | 2.85 | 1 |  | 11.83 | 11.83 | 5.18 | -1.49 | 5.85 | 57.42 | 3/3 | 18/22 | 13.54 | 10.13 | 4.77 |
| slot_hhmm=09:30 & mtf_D1=BULLISH | C alvo 0.5ATR ate 15min | COMPRA | 157 | 137 | 3.27 | nao | 4.88 | 1 |  | 15.42 | 15.42 | 5.14 | -5.52 | 6.92 | 67.88 | 3/3 | 23/24 | 24.21 | 6.76 | 0.95 |
| volume_ratio=Q5 & news_min_to_next_high=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 361 | 225 | 2.42 | nao | 2.22 | 1 |  | 50.01 | 50.01 | 5.12 | -1.49 | 5.28 | 65.78 | 3/3 | 28/32 | 45.46 | 54.53 | 1.55 |
| day_of_week=WEDNESDAY & hour=18 | C alvo 0.5ATR ate 60min | COMPRA | 333 | 228 | 2.02 | nao | 2.49 | 1 |  | 19.30 | 19.30 | 5.08 | -4.69 | 6.26 | 76.75 | 3/3 | 29/34 | 27.96 | 10.64 | 1.05 |
| volume_ratio=Q5 & news_min_to_next_high=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 361 | 225 | 3.21 | nao | 1.92 | 1 |  | 39.27 | 39.27 | 5.00 | -2.62 | 5.34 | 70.22 | 3/3 | 30/32 | 40.10 | 38.45 | 1.55 |
| price_position_weekly_open=Q2 & news_min_to_next_high=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 1,096 | 711 | 2.10 | nao | 2.30 | 1 |  | 20.16 | 20.16 | 4.88 | -1.49 | 5.26 | 57.38 | 3/3 | 25/32 | 3.62 | 36.66 | 4.52 |
| hour=14 & news_min_to_next_high=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 464 | 295 | 2.53 | nao | 2.53 | 1 |  | 28.46 | 28.46 | 4.70 | -2.62 | 5.14 | 66.44 | 3/3 | 26/30 | 21.60 | 35.28 | 0.95 |
| slot_hhmm=09:30 & mtf_D1=BULLISH | C alvo 1.0ATR ate 15min | COMPRA | 157 | 137 | 3.62 | nao | 4.46 | 1 |  | 16.76 | 16.76 | 4.66 | -4.77 | 5.96 | 63.50 | 3/3 | 23/24 | 24.97 | 8.66 | 0.95 |
| slot_hhmm=09:30 & mtf_D1=BULLISH | C alvo 2.0ATR ate 15min | COMPRA | 157 | 137 | 3.57 | nao | 4.40 | 1 |  | 17.78 | 17.78 | 4.61 | -4.39 | 5.71 | 63.50 | 3/3 | 23/24 | 25.65 | 10.03 | 0.95 |
| session=LONDON_NY_OVERLAP & month=5 | C alvo 2.0ATR ate 60min | COMPRA | 720 | 328 | 2.30 | nao | 1.86 | 1 |  | 23.04 | 23.04 | 4.47 | -1.49 | 4.74 | 61.28 | 3/3 | 3/3 | 53.18 | -7.10 | 0.99 |
| slot_hhmm=09:30 & mtf_M1=BULLISH | C alvo 0.5ATR ate 15min | COMPRA | 154 | 101 | 2.05 | nao | 4.63 | 1 |  | 15.85 | 15.85 | 4.42 | -5.52 | 5.92 | 64.36 | 3/3 | 22/31 | 20.27 | 11.51 | 0.96 |
| hour=19 & cum10=Q1 | C alvo 1.0ATR ate 60min | COMPRA | 182 | 104 | 3.11 | nao | 2.97 | 1 |  | 34.57 | 34.57 | 4.00 | -2.62 | 4.28 | 75.00 | 3/3 | 23/26 | 25.21 | 43.93 | 1.07 |
| hour=19 & swing_high_distance_atr=Q1 | C alvo 2.0ATR ate 60min | COMPRA | 221 | 117 | 2.70 | nao | 2.32 | 1 |  | 36.57 | 36.57 | 3.98 | -1.49 | 4.13 | 67.52 | 3/3 | 24/32 | 27.42 | 45.56 | 1.14 |
| session=LONDON_NY_OVERLAP & news_min_to_next_high=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 2,065 | 1,303 | 2.00 | nao | 2.46 | 1 |  | 12.56 | 12.56 | 3.85 | -1.49 | 4.36 | 56.10 | 2/3 | 23/34 | 6.24 | 18.87 | 0.97 |
| hour=14 & news_min_to_next_high=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 464 | 295 | 2.99 | nao | 1.79 | 1 |  | 27.47 | 27.47 | 3.80 | -1.49 | 4.01 | 57.29 | 3/3 | 23/30 | 22.44 | 32.47 | 0.95 |
| slot_hhmm=09:30 & mtf_M1=BULLISH | C alvo 1.0ATR ate 15min | COMPRA | 154 | 101 | 2.58 | nao | 3.84 | 1 |  | 16.63 | 16.63 | 3.77 | -4.77 | 4.82 | 59.41 | 3/3 | 23/31 | 21.29 | 12.07 | 0.96 |
| hour=19 & dom_w=d15_21 | C alvo 2.0ATR ate 60min | COMPRA | 307 | 215 | 2.20 | nao | 2.04 | 1 |  | 23.62 | 23.62 | 3.74 | -1.49 | 3.96 | 63.72 | 3/3 | 26/32 | 26.45 | 20.82 | 1.06 |
| slot_hhmm=09:30 & mtf_M1=BULLISH | C alvo 2.0ATR ate 15min | COMPRA | 154 | 101 | 2.42 | nao | 3.75 | 1 |  | 16.27 | 16.27 | 3.72 | -4.39 | 4.70 | 59.41 | 3/3 | 22/31 | 21.32 | 11.33 | 0.96 |
| hour=19 & cum10=Q1 | C alvo 0.5ATR ate 60min | COMPRA | 182 | 104 | 2.89 | nao | 2.87 | 1 |  | 23.65 | 23.65 | 3.71 | -4.69 | 4.42 | 82.69 | 3/3 | 20/26 | 22.33 | 24.98 | 1.07 |

### M30 — modo `hit`

- eventos: 33,970 (2024-01-22 a 2026-10-16); descoberta 20,334 (até 2025-09-11), validação 13,588 (a partir de 2025-09-12)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 566,952**; passaram no BH (q=5%) na descoberta: **3**; confirmadas na validação: **2**
- melhores N da descoberta que repetem na validação: top 100: 9.0%, top 1000: 9.4%, top 10000: 5.5%
- **placebo** (6 deslocamentos): top 100: 3.8% (máx 7.0%), top 1000: 2.8% (máx 5.4%), top 10000: 2.0% (máx 2.7%); BH: média 0.3 (máx 2); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 20,246 | -0.056 |  | -8.107 |
| C alvo 0.5ATR/60min liquido | 19,306 | -0.045 |  | -6.616 |
| C alvo 0.5ATR/240min liquido | 16,730 | -0.078 |  | -11.307 |
| C alvo 1.0ATR/15min liquido | 20,246 | -0.054 |  | -7.853 |
| C alvo 1.0ATR/60min liquido | 19,306 | -0.033 |  | -4.849 |
| C alvo 1.0ATR/240min liquido | 16,730 | -0.069 |  | -10.011 |
| C alvo 2.0ATR/15min liquido | 20,246 | -0.051 |  | -7.395 |
| C alvo 2.0ATR/60min liquido | 19,306 | -0.029 |  | -4.224 |
| C alvo 2.0ATR/240min liquido | 16,730 | -0.059 |  | -8.651 |
| V alvo 0.5ATR/15min liquido | 20,246 | -0.025 |  | -3.682 |
| V alvo 0.5ATR/60min liquido | 19,306 | -0.033 |  | -4.783 |
| V alvo 0.5ATR/240min liquido | 16,730 | -0.056 |  | -8.174 |
| V alvo 1.0ATR/15min liquido | 20,246 | -0.019 |  | -2.767 |
| V alvo 1.0ATR/60min liquido | 19,306 | -0.028 |  | -4.082 |
| V alvo 1.0ATR/240min liquido | 16,730 | -0.051 |  | -7.471 |
| V alvo 2.0ATR/15min liquido | 20,246 | -0.016 |  | -2.272 |
| V alvo 2.0ATR/60min liquido | 19,306 | -0.027 |  | -3.872 |
| V alvo 2.0ATR/240min liquido | 16,730 | -0.069 |  | -10.011 |

**M30/hit: famílias distintas validadas: 225; com líquido positivo e significativo na validação (custo realista): 160.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=4 & news_min_to_next_high=Q3 | C alvo 0.5ATR ate 240min | COMPRA | 290 | 153 | 2.44 | nao | 3.62 | 1 |  | 32.11 | 32.11 | 7.60 | -6.88 | 8.47 | 88.24 | 3/3 | 3/3 | 24.72 | 39.40 | 0.89 |
| month=12 & prev_day_low_distance_atr=Q4 | C alvo 1.0ATR ate 240min | COMPRA | 198 | 132 | 2.20 | nao | 2.20 | 1 |  | 64.99 | 64.99 | 6.59 | -1.05 | 6.57 | 85.61 | 2/2 | 2/2 | 70.25 | 59.73 | 5.29 |
| month=4 & news_min_to_next_high=Q3 | C alvo 1.0ATR ate 240min | COMPRA | 290 | 153 | 2.24 | nao | 2.07 | 1 |  | 46.41 | 46.41 | 6.17 | -1.05 | 6.09 | 75.82 | 3/3 | 3/3 | 38.78 | 53.93 | 0.89 |
| mtf_D1=BREAK_UP & atr_ratio=Q2 | V alvo 2.0ATR ate 240min | VENDA | 274 | 214 | 2.38 | nao | 2.11 | 1 |  | 54.74 | 54.74 | 4.80 | -10.43 | 5.70 | 67.76 | 3/3 | 19/19 | 52.98 | 56.50 | 1.05 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 541 | 347 | 2.33 | nao | 3.19 | 1 |  | 18.68 | 18.68 | 4.49 | -4.32 | 5.49 | 68.01 | 3/3 | 28/33 | 28.94 | 8.47 | 1.76 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 541 | 347 | 2.85 | nao | 3.15 | 1 |  | 21.17 | 21.17 | 4.19 | -2.63 | 4.70 | 62.25 | 3/3 | 28/33 | 33.80 | 8.61 | 1.76 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 541 | 347 | 2.04 | nao | 3.01 | 1 |  | 22.10 | 22.10 | 4.09 | -2.14 | 4.47 | 61.67 | 3/3 | 27/33 | 37.63 | 6.66 | 1.76 |
| day_of_week=WEDNESDAY & hour=18 | C alvo 2.0ATR ate 60min | COMPRA | 166 | 114 | 2.24 | nao | 3.13 | 1 |  | 42.84 | 42.84 | 3.84 | -2.14 | 4.02 | 65.79 | 3/3 | 24/32 | 56.98 | 28.70 | 1.05 |
| day_of_week=WEDNESDAY & hour=18 | C alvo 1.0ATR ate 60min | COMPRA | 166 | 114 | 2.08 | nao | 3.34 | 1 |  | 34.98 | 34.98 | 3.74 | -2.63 | 4.01 | 67.54 | 3/3 | 24/32 | 46.43 | 23.54 | 1.05 |
| day_of_week=WEDNESDAY & hour=18 | C alvo 0.5ATR ate 60min | COMPRA | 166 | 114 | 2.99 | nao | 3.14 | 1 |  | 26.16 | 26.16 | 3.69 | -4.32 | 4.27 | 71.05 | 3/3 | 26/32 | 41.12 | 11.20 | 1.05 |
| news_state=EVENTS_2_AROUND_60M & session_low_distance_atr=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 143 | 103 | 2.08 | nao | 2.40 | 1 |  | 24.73 | 24.73 | 3.55 | -4.32 | 4.14 | 71.84 | 3/3 | 21/25 | 26.65 | 22.86 | 0.99 |
| price_position_weekly_open=Q2 & news_min_to_next_high=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 525 | 343 | 2.45 | nao | 2.63 | 1 |  | 18.80 | 18.80 | 3.50 | -2.63 | 3.98 | 58.89 | 3/3 | 24/31 | 6.61 | 30.92 | 5.78 |
| slot_hhmm=18:30 & direction=BEARISH | C alvo 2.0ATR ate 60min | COMPRA | 224 | 126 | 2.05 | nao | 2.51 | 1 |  | 34.14 | 34.14 | 3.45 | -2.14 | 3.66 | 67.46 | 3/3 | 25/33 | 17.07 | 51.20 | 1.04 |
| hour=14 & news_min_to_next_high=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 195 | 122 | 2.19 | nao | 1.68 | 1 |  | 25.57 | 25.57 | 3.36 | -4.32 | 3.91 | 71.31 | 3/3 | 20/24 | 24.60 | 26.54 | 0.91 |
| slot_hhmm=18:30 & direction=BEARISH | C alvo 1.0ATR ate 60min | COMPRA | 224 | 126 | 2.15 | nao | 2.46 | 1 |  | 29.62 | 29.62 | 3.35 | -2.63 | 3.64 | 67.46 | 3/3 | 24/33 | 15.85 | 43.40 | 1.04 |
| volume_ratio=Q5 & news_min_to_next_high=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 237 | 138 | 2.68 | nao | 2.24 | 1 |  | 26.96 | 26.96 | 3.35 | -4.32 | 3.88 | 73.19 | 3/3 | 27/31 | 31.75 | 22.16 | 0.95 |
| session=LONDON_NY_OVERLAP & month=5 | C alvo 1.0ATR ate 60min | COMPRA | 360 | 164 | 2.24 | nao | 1.88 | 1 |  | 22.55 | 22.55 | 3.34 | -2.63 | 3.71 | 62.20 | 2/3 | 2/3 | 46.61 | -1.51 | 0.99 |
| hour=19 & dom_w=d15_21 | C alvo 1.0ATR ate 60min | COMPRA | 120 | 85 | 2.36 | nao | 2.35 | 1 |  | 29.84 | 29.84 | 3.20 | -2.63 | 3.45 | 67.06 | 3/3 | 27/32 | 30.77 | 28.93 | 1.07 |
| range_atr=Q5 & news_min_to_next_high=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 239 | 193 | 2.30 | nao | 2.07 | 1 |  | 20.02 | 20.02 | 3.17 | -4.32 | 3.85 | 69.43 | 3/3 | 28/32 | 10.49 | 29.45 | 4.20 |
| news_min_to_next_high=Q5 & range_atr_prev=Q5 | C alvo 0.5ATR ate 60min | COMPRA | 322 | 226 | 2.10 | nao | 2.39 | 1 |  | 19.91 | 19.91 | 3.09 | -4.32 | 3.77 | 72.57 | 3/3 | 26/33 | 23.20 | 16.61 | 2.43 |
| news_min_to_next_high=Q2 & atr_ratio=Q3 | V alvo 2.0ATR ate 15min | VENDA | 619 | 293 | 2.37 | nao | 3.37 | 1 |  | 12.58 | 12.58 | 3.08 | -3.83 | 4.04 | 58.02 | 3/3 | 27/34 | 11.01 | 14.13 | 1.28 |
| slot_hhmm=18:30 & session_low_distance_atr=Q1 | C alvo 1.0ATR ate 60min | COMPRA | 132 | 63 | 2.03 | nao | 2.64 | 1 |  | 36.48 | 36.48 | 3.00 | -2.63 | 3.19 | 69.84 | 3/3 | 18/23 | 9.38 | 62.74 | 1.04 |
| mtf_D1=BREAK_UP & cost_atr=Q4 | V alvo 1.0ATR ate 15min | VENDA | 402 | 395 | 2.02 | nao | 3.05 | 1 |  | 9.15 | 9.15 | 2.98 | -4.31 | 4.42 | 55.19 | 3/3 | 14/19 | 8.02 | 10.28 | 0.97 |
| hour=18 & close_position=Q2 | C alvo 1.0ATR ate 60min | COMPRA | 156 | 103 | 2.17 | nao | 2.10 | 1 |  | 26.72 | 26.72 | 2.95 | -2.63 | 3.22 | 62.14 | 3/3 | 24/32 | 25.48 | 27.94 | 1.05 |
| hour=19 & dom_w=d15_21 | C alvo 2.0ATR ate 60min | COMPRA | 120 | 85 | 2.34 | nao | 2.14 | 1 |  | 31.14 | 31.14 | 2.93 | -2.14 | 3.11 | 65.88 | 3/3 | 27/32 | 36.40 | 26.01 | 1.07 |

### H1 — modo `hit`

- eventos: 33,106 (2021-06-07 a 2026-10-16); descoberta 19,839 (até 2024-08-26), validação 13,243 (a partir de 2024-08-27)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 576,252**; passaram no BH (q=5%) na descoberta: **121**; confirmadas na validação: **16**
- melhores N da descoberta que repetem na validação: top 100: 10.0%, top 1000: 9.8%, top 10000: 8.7%
- **placebo** (6 deslocamentos): top 100: 3.5% (máx 9.0%), top 1000: 3.0% (máx 4.6%), top 10000: 2.9% (máx 3.5%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 19,780 | -0.035 |  | -7.045 |
| C alvo 0.5ATR/60min liquido | 18,822 | -0.021 |  | -4.318 |
| C alvo 0.5ATR/240min liquido | 16,135 | -0.031 |  | -6.159 |
| C alvo 1.0ATR/15min liquido | 19,780 | -0.034 |  | -6.761 |
| C alvo 1.0ATR/60min liquido | 18,822 | -0.011 |  | -2.278 |
| C alvo 1.0ATR/240min liquido | 16,135 | -0.012 |  | -2.382 |
| C alvo 2.0ATR/15min liquido | 19,780 | -0.033 |  | -6.666 |
| C alvo 2.0ATR/60min liquido | 18,822 | -0.007 |  | -1.405 |
| C alvo 2.0ATR/240min liquido | 16,135 | 0.013 |  | 2.665 |
| V alvo 0.5ATR/15min liquido | 19,780 | -0.006 |  | -1.269 |
| V alvo 0.5ATR/60min liquido | 18,822 | -0.019 |  | -3.876 |
| V alvo 0.5ATR/240min liquido | 16,135 | -0.052 |  | -10.566 |
| V alvo 1.0ATR/15min liquido | 19,780 | -0.004 |  | -0.777 |
| V alvo 1.0ATR/60min liquido | 18,822 | -0.020 |  | -4.052 |
| V alvo 1.0ATR/240min liquido | 16,135 | -0.069 |  | -13.889 |
| V alvo 2.0ATR/15min liquido | 19,780 | -0.003 |  | -0.527 |
| V alvo 2.0ATR/60min liquido | 18,822 | -0.023 |  | -4.635 |
| V alvo 2.0ATR/240min liquido | 16,135 | -0.087 |  | -17.543 |

**H1/hit: famílias distintas validadas: 591; com líquido positivo e significativo na validação (custo realista): 439.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| prev_day_high_distance_atr=Q3 & prev_day_low_distance_atr=Q5 | V alvo 1.0ATR ate 240min | VENDA | 319 | 217 | 2.59 | nao | 2.56 | 1 |  | 83.59 | 83.59 | 7.10 | -5.91 | 7.53 | 70.05 | 6/6 | 32/41 | 124.84 | 42.73 | 0.99 |
| day_of_week=FRIDAY & month=6 | C alvo 2.0ATR ate 240min | COMPRA | 257 | 133 | 2.22 | nao | 2.50 | 1 |  | 87.64 | 87.64 | 5.29 | -2.34 | 5.37 | 63.16 | 5/6 | 5/6 | 170.13 | 6.39 | 4.73 |
| price_position_monthly_open=Q5 & atr_ratio=Q1 | C alvo 2.0ATR ate 240min | COMPRA | 702 | 419 | 2.09 | nao | 2.29 | 1 |  | 53.38 | 53.38 | 4.76 | -2.34 | 4.94 | 58.95 | 4/5 | 16/20 | 78.61 | 28.28 | 3.51 |
| session=ASIA & atr_ratio=Q1 | C alvo 2.0ATR ate 240min | COMPRA | 1,886 | 1,046 | 2.30 | nao | 1.99 | 1 |  | 28.70 | 28.70 | 4.10 | -2.34 | 4.37 | 57.46 | 6/6 | 41/65 | 45.63 | 11.77 | 0.96 |
| price_position_monthly_open=Q5 & atr_ratio=Q1 | C alvo 1.0ATR ate 240min | COMPRA | 702 | 419 | 2.13 | nao | 1.95 | 1 |  | 36.57 | 36.57 | 4.05 | -3.72 | 4.40 | 66.11 | 5/5 | 18/20 | 50.64 | 22.57 | 3.51 |
| dom_w=d15_21 & session_low_distance_atr=Q5 | C alvo 2.0ATR ate 240min | COMPRA | 667 | 390 | 2.05 | nao | 2.23 | 1 |  | 55.15 | 55.15 | 3.87 | -2.34 | 4.07 | 59.74 | 6/6 | 47/64 | 36.55 | 73.76 | 4.54 |
| hour=18 & structure_before=BULLISH | C alvo 0.5ATR ate 60min | COMPRA | 343 | 223 | 2.53 | nao | 3.72 | 4 |  | 19.97 | 19.97 | 3.74 | -4.78 | 4.56 | 61.88 | 5/6 | 46/64 | 14.01 | 25.88 | 1.04 |
| hour=18 & structure_at_close=RANGE | C alvo 2.0ATR ate 60min | COMPRA | 146 | 113 | 2.07 | nao | 3.86 | 2 |  | 35.87 | 35.87 | 3.70 | -3.91 | 4.07 | 62.83 | 6/6 | 19/27 | 31.19 | 40.47 | 1.04 |
| cost_atr=Q5 & gap=Y | C alvo 1.0ATR ate 60min | COMPRA | 142 | 111 | 5.62 | sim | 3.92 | 1 |  | 54.49 | 54.49 | 3.67 | -3.98 | 3.93 | 72.97 | 6/6 | 14/17 | 56.72 | 52.30 | 65.86 |
| hour=18 & structure_at_close=RANGE | C alvo 1.0ATR ate 60min | COMPRA | 146 | 113 | 2.27 | nao | 3.86 | 2 |  | 32.93 | 32.93 | 3.63 | -3.98 | 4.03 | 62.83 | 6/6 | 19/27 | 30.96 | 34.87 | 1.04 |
| cost_atr=Q5 & gap=Y | C alvo 2.0ATR ate 60min | COMPRA | 142 | 111 | 5.24 | sim | 3.82 | 1 |  | 63.73 | 63.73 | 3.61 | -3.91 | 3.83 | 65.77 | 6/6 | 14/17 | 70.67 | 56.91 | 65.86 |
| slot_hhmm=18:00 & structure_at_close=RANGE | C alvo 0.5ATR ate 60min | COMPRA | 146 | 113 | 2.28 | nao | 3.83 | 2 |  | 27.30 | 27.30 | 3.60 | -4.78 | 4.18 | 63.72 | 6/6 | 20/27 | 32.21 | 22.47 | 1.04 |
| session=ASIA & mtf_M30=BREAK_DOWN | V alvo 0.5ATR ate 15min | VENDA | 285 | 260 | 2.01 | nao | 4.08 | 1 |  | 20.42 | 20.42 | 3.60 | -2.73 | 4.11 | 62.69 | 6/6 | 36/51 | 19.35 | 21.49 | 0.93 |
| price_position_weekly_open=Q2 & gap=Y | C alvo 2.0ATR ate 15min | COMPRA | 125 | 81 | 3.90 | nao | 3.63 | 1 |  | 49.68 | 49.68 | 3.55 | -6.61 | 4.01 | 62.96 | 6/6 | 7/10 | 38.03 | 61.04 | 65.13 |
| session=ASIA & structure_at_close=BREAK_DOWN | V alvo 2.0ATR ate 15min | VENDA | 244 | 234 | 2.73 | nao | 4.20 | 1 |  | 28.47 | 28.47 | 3.47 | -2.07 | 3.76 | 60.26 | 6/6 | 31/42 | 18.51 | 38.42 | 0.93 |
| day_of_week=SUNDAY & cost_atr=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 163 | 115 | 4.58 | sim | 3.45 | 1 |  | 49.99 | 49.99 | 3.46 | -3.98 | 3.73 | 71.30 | 6/6 | 16/20 | 61.63 | 38.56 | 61.63 |
| price_position_weekly_open=Q2 & gap=Y | C alvo 1.0ATR ate 60min | COMPRA | 124 | 81 | 7.11 | sim | 3.40 | 1 |  | 58.17 | 58.17 | 3.45 | -3.98 | 3.67 | 74.07 | 6/6 | 9/10 | 34.89 | 80.87 | 65.13 |
| price_position_weekly_open=Q2 & gap=Y | C alvo 2.0ATR ate 60min | COMPRA | 124 | 81 | 6.54 | sim | 3.52 | 1 |  | 67.97 | 67.97 | 3.44 | -3.91 | 3.63 | 69.14 | 6/6 | 8/10 | 49.66 | 85.84 | 65.13 |
| session=ASIA & structure_at_close=BREAK_DOWN | V alvo 0.5ATR ate 15min | VENDA | 244 | 234 | 2.09 | nao | 4.08 | 1 |  | 23.27 | 23.27 | 3.44 | -2.73 | 3.88 | 63.68 | 6/6 | 28/42 | 13.74 | 32.80 | 0.93 |
| session=ASIA & previous_low_distance_atr=Q1 | V alvo 2.0ATR ate 15min | VENDA | 1,087 | 860 | 2.84 | nao | 4.26 | 1 |  | 12.94 | 12.94 | 3.39 | -2.07 | 4.11 | 54.77 | 6/6 | 45/64 | 10.24 | 15.65 | 0.93 |
| day_of_week=SUNDAY & cost_atr=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 163 | 115 | 4.28 | nao | 3.44 | 1 |  | 56.38 | 56.38 | 3.38 | -3.91 | 3.61 | 65.22 | 6/6 | 14/20 | 71.49 | 41.53 | 61.63 |
| session=ASIA & structure_at_close=BREAK_DOWN | V alvo 1.0ATR ate 15min | VENDA | 244 | 234 | 2.97 | nao | 4.17 | 1 |  | 25.59 | 25.59 | 3.36 | -2.50 | 3.73 | 60.68 | 6/6 | 31/42 | 17.68 | 33.50 | 0.93 |
| session=LONDON & volume_ratio=Q4 | V alvo 2.0ATR ate 15min | VENDA | 1,564 | 1,053 | 2.21 | nao | 3.45 | 1 |  | 8.55 | 8.55 | 3.34 | -2.07 | 4.26 | 53.75 | 5/6 | 46/65 | 14.84 | 2.28 | 0.99 |
| mtf_M5=BREAK_DOWN & atr_ratio=Q2 | V alvo 0.5ATR ate 15min | VENDA | 166 | 134 | 2.07 | nao | 3.30 | 1 |  | 19.89 | 19.89 | 3.32 | -2.73 | 3.77 | 62.69 | 5/6 | 20/29 | 28.47 | 11.32 | 3.53 |
| session=LONDON & session_high_distance_atr=Q3 | V alvo 0.5ATR ate 15min | VENDA | 635 | 417 | 2.09 | nao | 2.86 | 1 |  | 10.46 | 10.46 | 3.32 | -2.73 | 4.19 | 53.48 | 6/6 | 43/65 | 18.53 | 2.42 | 0.99 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **10639**
- com líquido positivo e t>1,645 na validação, custo realista: **2354**; dessas, sobreviveram ao BH: **148**; e positivas nas duas metades da validação: **132**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M15 | ret | day_of_week=SUNDAY & session=NEW_YORK | 60min | COMPRA | 155 | 47.10 | -1.02 | 4.65 | 4.56 | 61.29 | 2/3 | 16/24 |
| H1 | ret | dow_slot=SUNDAY|23:00 | 5min | VENDA | 111 | 33.63 | -1.60 | 4.10 | 3.90 | 63.96 | 6/6 | 17/21 |
| H1 | ret | price_position_weekly_open=Q2 & gap=Y | 30min | COMPRA | 81 | 58.94 | -5.70 | 4.14 | 3.78 | 66.67 | 6/6 | 9/10 |
| H1 | ret | day_of_week=SUNDAY & cost_atr=Q5 | 30min | COMPRA | 115 | 51.37 | -5.70 | 4.16 | 3.74 | 63.48 | 5/6 | 17/20 |
| H1 | ret | cost_atr=Q5 & gap=Y | 30min | COMPRA | 111 | 52.87 | -5.70 | 4.11 | 3.71 | 64.86 | 5/6 | 14/17 |
| H1 | hit | cost_atr=Q5 & gap=Y | C alvo 1.0ATR ate 60min | COMPRA | 111 | 54.49 | -3.98 | 3.93 | 3.67 | 72.97 | 6/6 | 14/17 |
| H1 | ret | slot_hhmm=23:00 & direction=BEARISH | 5min | VENDA | 249 | 17.68 | -1.60 | 4.03 | 3.66 | 61.04 | 6/6 | 45/61 |
| H1 | ret | mtf_M1=BULLISH & upper_wick_pct=Q5 | 5min | VENDA | 997 | 6.56 | -1.60 | 4.63 | 3.65 | 52.66 | 4/6 | 40/65 |
| H1 | hit | cost_atr=Q5 & gap=Y | C alvo 2.0ATR ate 60min | COMPRA | 111 | 63.73 | -3.91 | 3.83 | 3.61 | 65.77 | 6/6 | 14/17 |
| H1 | ret | day_of_week=SUNDAY & gap=Y | 30min | COMPRA | 111 | 51.79 | -5.70 | 3.91 | 3.52 | 63.96 | 6/6 | 16/20 |
| H1 | hit | day_of_week=SUNDAY & cost_atr=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 115 | 49.99 | -3.98 | 3.73 | 3.46 | 71.30 | 6/6 | 16/20 |
| H1 | hit | price_position_weekly_open=Q2 & gap=Y | C alvo 1.0ATR ate 60min | COMPRA | 81 | 58.17 | -3.98 | 3.67 | 3.45 | 74.07 | 6/6 | 9/10 |
| H1 | hit | price_position_weekly_open=Q2 & gap=Y | C alvo 2.0ATR ate 60min | COMPRA | 81 | 67.97 | -3.91 | 3.63 | 3.44 | 69.14 | 6/6 | 8/10 |
| H1 | ret | price_position_weekly_open=Q2 & gap=Y | 15min | COMPRA | 81 | 45.83 | -6.37 | 3.77 | 3.32 | 62.96 | 6/6 | 7/10 |
| H1 | ret | gap=Y | 30min | COMPRA | 117 | 46.96 | -5.70 | 3.71 | 3.30 | 63.25 | 6/6 | 21/25 |
| H1 | ret | volume_ratio=Q1 & gap=Y | 30min | COMPRA | 114 | 47.44 | -5.70 | 3.66 | 3.27 | 63.16 | 6/6 | 18/22 |
| H1 | ret | cost_atr=Q5 & gap=Y | 60min | COMPRA | 111 | 56.06 | -3.16 | 3.43 | 3.24 | 63.06 | 6/6 | 14/17 |
| H1 | ret | session=ASIA & direction=BEARISH | 15min | VENDA | 2,126 | 6.61 | -2.17 | 4.57 | 3.16 | 51.74 | 6/6 | 49/65 |
| H1 | ret | session=ASIA & swing_low_distance_atr=Q1 | 15min | VENDA | 1,085 | 9.98 | -2.17 | 3.94 | 3.08 | 54.01 | 6/6 | 46/65 |
| H1 | hit | volume_ratio=Q1 & gap=Y | C alvo 2.0ATR ate 60min | COMPRA | 114 | 54.57 | -3.91 | 3.24 | 3.02 | 64.04 | 6/6 | 17/22 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 1956s)_
