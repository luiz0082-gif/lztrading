# USDJPY — relatório completo MBA (gerado em 2026-10-17 02:27)

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
| M5 | open | 105,989 | 73,060 | 47 | 25 | 0.3 | 0.2 | 1 | 55.0 | 14.7 |
| M15 | open | 68,019 | 80,155 | 124 | 96 | 0.3 | 0.0 | 0 | 76.0 | 16.3 |
| M30 | open | 33,970 | 63,105 | 135 | 114 | 0.0 | 0.0 | 0 | 88.0 | 9.5 |
| H1 | open | 33,106 | 63,067 | 716 | 466 | 4.2 | 0.7 | 3 | 97.0 | 22.7 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 105,989 (2025-05-15 a 2026-10-16); descoberta 63,306 (até 2026-03-23), validação 42,396 (a partir de 2026-03-24)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 73,060**; passaram no BH (q=5%) na descoberta: **47**; confirmadas na validação: **25**
- melhores N da descoberta que repetem na validação: top 100: 55.0%, top 1000: 37.6%, top 10000: 17.9%
- **placebo** (6 deslocamentos): top 100: 14.7% (máx 20.0%), top 1000: 11.9% (máx 15.4%), top 10000: 8.2% (máx 10.3%); BH: média 0.3 (máx 2); confirmadas: média 0.2 (máx 1)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,293 | 0.008 | 2.877 | 0.377 |
| 10min bruto | 63,293 | 0.010 | 1.688 | 0.486 |
| 20min bruto | 62,847 | 0.027 | 2.255 | 1.317 |
| 35min bruto | 62,178 | 0.055 | 2.489 | 2.625 |
| 65min bruto | 60,844 | 0.107 | 2.484 | 5.131 |
| 125min bruto | 58,180 | 0.144 | 1.597 | 6.902 |
| 245min bruto | 52,884 | 0.218 | 1.112 | 10.457 |

**M5/open: famílias distintas validadas: 585; com líquido positivo e significativo na validação (custo realista): 92.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=FRIDAY & month=3 | 245min | COMPRA | 624 | 204 | 2.25 | nao | 1.83 | 1 | 163.22 | 162.21 | 162.21 | 13.02 | -4.48 | 13.30 | 80.39 | 1/1 | 1/1 | 131.81 | 192.60 | 1.01 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 125min | COMPRA | 3,964 | 2,388 | 2.15 | nao | 3.62 | 1 | 33.39 | 32.34 | 32.34 | 12.73 | -1.87 | 12.98 | 64.74 | 2/2 | 13/14 | 18.04 | 46.64 | 1.05 |
| news_min_to_next_high=Q5 | 125min | COMPRA | 6,855 | 4,767 | 2.38 | nao | 3.35 | 1 | 28.57 | 27.35 | 27.35 | 12.44 | -1.87 | 13.17 | 62.49 | 2/2 | 17/18 | 28.54 | 26.15 | 1.22 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 65min | COMPRA | 4,619 | 2,606 | 2.32 | nao | 3.43 | 1 | 18.40 | 17.35 | 17.35 | 9.17 | -1.80 | 9.88 | 59.59 | 2/2 | 12/14 | 11.12 | 23.57 | 1.05 |
| news_min_to_next_high=Q5 | 65min | COMPRA | 7,802 | 5,193 | 2.28 | nao | 3.09 | 1 | 16.63 | 15.42 | 15.42 | 9.09 | -1.80 | 10.33 | 58.08 | 2/2 | 16/18 | 16.33 | 14.52 | 1.21 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 125min | COMPRA | 1,200 | 839 | 2.42 | nao | 1.95 | 1 | 56.97 | 50.64 | 50.64 | 8.49 | -1.87 | 8.83 | 63.29 | 2/2 | 11/14 | 21.25 | 79.97 | 6.32 |
| mtf_M15=BEARISH & news_min_to_next_high=Q5 | 125min | COMPRA | 2,264 | 1,132 | 2.06 | nao | 1.95 | 1 | 47.02 | 45.27 | 45.27 | 7.92 | -1.87 | 8.33 | 67.14 | 2/2 | 13/18 | 37.38 | 53.17 | 1.75 |
| session=NEW_YORK & news_min_to_next_high=Q5 | 125min | COMPRA | 3,258 | 2,036 | 2.03 | nao | 2.03 | 1 | 24.85 | 23.35 | 23.35 | 7.49 | -1.87 | 7.98 | 61.25 | 2/2 | 16/18 | 26.57 | 20.14 | 1.49 |
| day_of_week=SUNDAY & session=NEW_YORK | 125min | COMPRA | 323 | 345 | 2.77 | nao | 3.69 | 2 | 153.57 | 45.24 | 45.24 | 6.91 | -1.87 | 7.14 | 64.35 | 2/2 | 11/14 | 50.15 | 40.37 | 108.32 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 65min | COMPRA | 1,612 | 1,237 | 2.20 | nao | 1.73 | 1 | 21.72 | 20.69 | 20.69 | 6.89 | -1.80 | 7.46 | 58.85 | 1/2 | 13/18 | 35.88 | 5.52 | 1.03 |
| hour=18 & mtf_W1=BULLISH | 35min | COMPRA | 1,476 | 888 | 2.02 | nao | 2.29 | 1 | 16.48 | 15.39 | 15.39 | 6.27 | -3.16 | 7.51 | 57.09 | 2/2 | 13/14 | 15.38 | 15.40 | 1.09 |
| session=LONDON_NY_OVERLAP & news_state=NONE_60M | 65min | COMPRA | 4,490 | 3,111 | 2.17 | nao | 2.80 | 1 | 17.78 | 16.79 | 16.79 | 6.15 | -1.80 | 7.05 | 58.79 | 2/2 | 12/18 | 19.22 | 14.36 | 0.99 |
| hour=19 & news_min_to_next_high=Q4 | 35min | COMPRA | 612 | 732 | 2.96 | nao | 2.68 | 1 | 14.68 | 13.59 | 13.59 | 5.69 | -3.16 | 6.92 | 62.16 | 2/2 | 11/14 | 4.69 | 22.49 | 1.09 |
| hour=19 & news_min_to_next_high=Q4 | 65min | COMPRA | 561 | 671 | 2.12 | nao | 1.96 | 1 | 18.91 | 17.82 | 17.82 | 5.62 | -1.80 | 6.09 | 64.83 | 2/2 | 11/14 | 5.13 | 30.48 | 1.09 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 35min | COMPRA | 1,636 | 1,237 | 2.01 | nao | 1.94 | 1 | 13.66 | 12.63 | 12.63 | 5.46 | -3.16 | 6.82 | 55.38 | 1/2 | 12/18 | 20.81 | 4.46 | 1.03 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 65min | COMPRA | 1,320 | 875 | 3.15 | nao | 2.31 | 1 | 29.51 | 23.41 | 23.41 | 5.31 | -1.80 | 5.75 | 58.63 | 2/2 | 11/14 | 10.41 | 36.38 | 6.11 |
| session=NEW_YORK & mtf_D1=RANGE | 65min | COMPRA | 3,070 | 1,176 | 2.27 | nao | 3.12 | 1 | 33.75 | 13.90 | 13.90 | 5.07 | -1.80 | 5.65 | 52.47 | 1/2 | 9/13 | 11.04 | 16.77 | 19.85 |
| hour=18 & dom_w=d15_21 | 35min | COMPRA | 660 | 372 | 2.14 | nao | 1.68 | 1 | 28.86 | 27.78 | 27.78 | 5.04 | -3.16 | 5.62 | 54.57 | 2/2 | 14/18 | 30.81 | 24.75 | 1.08 |
| day_of_week=SUNDAY & session=NEW_YORK | 65min | COMPRA | 323 | 345 | 4.30 | sim | 5.09 | 2 | 142.39 | 34.07 | 34.07 | 4.95 | -1.80 | 5.21 | 62.32 | 2/2 | 8/14 | 39.49 | 28.68 | 108.32 |
| news_state=EVENTS_4_AROUND_60M & news_min_to_next_high=Q5 | 35min | COMPRA | 140 | 51 | 2.28 | nao | 1.75 | 1 | 81.47 | 80.46 | 80.46 | 4.94 | -3.16 | 5.08 | 78.43 | 2/2 | 9/12 | 84.40 | 76.67 | 1.01 |
| hour=19 & news_min_to_next_high=Q4 | 20min | COMPRA | 612 | 732 | 2.86 | nao | 3.04 | 1 | 9.97 | 8.88 | 8.88 | 4.77 | -3.88 | 6.79 | 58.20 | 2/2 | 12/14 | 4.73 | 13.03 | 1.09 |
| hour=19 & mtf_M15=BEARISH | 35min | COMPRA | 889 | 342 | 3.38 | nao | 2.10 | 1 | 25.71 | 24.64 | 24.64 | 4.65 | -3.16 | 5.25 | 66.96 | 2/2 | 14/18 | -0.29 | 49.56 | 1.07 |
| session=NEW_YORK & mtf_H1=BEARISH | 65min | COMPRA | 3,471 | 1,581 | 2.35 | nao | 3.88 | 1 | 43.22 | 20.22 | 20.22 | 4.64 | -1.80 | 5.17 | 56.42 | 2/2 | 10/18 | 25.85 | 14.60 | 23.00 |
| hour=18 & dom_w=d15_21 | 20min | COMPRA | 660 | 372 | 2.21 | nao | 2.13 | 1 | 18.77 | 17.68 | 17.68 | 4.62 | -3.88 | 5.64 | 55.65 | 2/2 | 13/18 | 17.20 | 18.17 | 1.08 |
| mtf_H4=BREAK_DOWN & dom_w=d15_21 | 65min | COMPRA | 540 | 84 | 2.16 | nao | 1.81 | 1 | 75.08 | 73.84 | 73.84 | 4.53 | -1.80 | 4.62 | 69.05 | 2/2 | 6/7 | 114.16 | 33.52 | 1.24 |

### M15 — modo `open`

- eventos: 68,019 (2024-01-22 a 2026-10-16); descoberta 40,715 (até 2025-09-11), validação 27,208 (a partir de 2025-09-12)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 80,155**; passaram no BH (q=5%) na descoberta: **124**; confirmadas na validação: **96**
- melhores N da descoberta que repetem na validação: top 100: 76.0%, top 1000: 50.5%, top 10000: 21.9%
- **placebo** (6 deslocamentos): top 100: 16.3% (máx 39.0%), top 1000: 10.6% (máx 17.9%), top 10000: 7.1% (máx 9.8%); BH: média 0.3 (máx 2); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 40,702 | 0.008 | 2.326 | 0.800 |
| 20min bruto | 40,702 | 0.005 | 1.023 | 0.526 |
| 30min bruto | 40,131 | 0.009 | 1.176 | 0.924 |
| 45min bruto | 39,613 | 0.018 | 1.434 | 1.781 |
| 75min bruto | 38,697 | 0.030 | 1.324 | 2.956 |
| 135min bruto | 36,971 | 0.037 | 0.844 | 3.649 |
| 255min bruto | 33,547 | 0.071 | 0.778 | 7.023 |

**M15/open: famílias distintas validadas: 966; com líquido positivo e significativo na validação (custo realista): 160.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 75min | COMPRA | 1,166 | 750 | 2.69 | nao | 3.90 | 1 | 34.60 | 33.13 | 33.13 | 8.12 | -0.49 | 8.20 | 65.47 | 3/3 | 28/34 | 49.90 | 16.35 | 1.47 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 135min | COMPRA | 923 | 591 | 2.27 | nao | 2.92 | 1 | 49.01 | 47.42 | 47.42 | 8.02 | 1.25 | 7.75 | 70.05 | 3/3 | 28/33 | 85.77 | 9.21 | 1.59 |
| news_min_to_next_high=Q5 | 135min | COMPRA | 4,279 | 2,778 | 2.53 | nao | 3.79 | 1 | 29.31 | 24.95 | 24.95 | 7.87 | 1.25 | 7.52 | 59.72 | 2/3 | 27/34 | 25.29 | 24.60 | 4.36 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 135min | COMPRA | 651 | 615 | 2.13 | nao | 2.91 | 1 | 69.05 | 63.16 | 63.16 | 7.44 | 1.25 | 7.36 | 62.76 | 3/3 | 19/24 | 83.67 | 42.71 | 5.90 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 135min | COMPRA | 1,488 | 1,772 | 2.46 | nao | 3.45 | 1 | 32.01 | 27.21 | 27.21 | 7.20 | 1.25 | 6.84 | 59.37 | 3/3 | 18/22 | 29.38 | 25.04 | 4.79 |
| news_min_to_next_high=Q5 | 75min | COMPRA | 5,168 | 3,357 | 2.89 | nao | 4.48 | 1 | 18.97 | 15.18 | 15.18 | 6.74 | -0.49 | 7.10 | 58.50 | 2/3 | 28/34 | 14.64 | 15.71 | 3.79 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 45min | COMPRA | 1,206 | 778 | 2.57 | nao | 4.18 | 1 | 22.34 | 20.88 | 20.88 | 6.66 | -2.48 | 7.41 | 60.80 | 3/3 | 26/34 | 30.29 | 11.47 | 1.46 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 75min | COMPRA | 1,789 | 2,137 | 2.94 | nao | 4.19 | 1 | 20.16 | 16.00 | 16.00 | 6.14 | -0.49 | 6.33 | 58.54 | 3/3 | 19/22 | 16.85 | 15.15 | 4.16 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 75min | COMPRA | 699 | 651 | 2.89 | nao | 3.23 | 1 | 41.12 | 35.49 | 35.49 | 5.87 | -0.49 | 6.01 | 59.14 | 3/3 | 19/24 | 49.41 | 21.60 | 5.63 |
| mtf_D1=BEARISH & news_min_to_next_high=Q5 | 75min | COMPRA | 1,485 | 687 | 2.03 | nao | 2.70 | 1 | 29.25 | 26.60 | 26.60 | 5.60 | -0.49 | 5.71 | 60.70 | 2/3 | 17/20 | 22.67 | 30.52 | 2.65 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 30min | COMPRA | 1,226 | 792 | 2.49 | nao | 4.27 | 1 | 15.56 | 14.11 | 14.11 | 5.43 | -3.49 | 6.75 | 56.69 | 3/3 | 25/34 | 19.33 | 8.89 | 1.45 |
| news_min_to_next_high=Q5 & atr_ratio_prev=Q4 | 75min | COMPRA | 1,271 | 869 | 2.10 | nao | 2.68 | 1 | 23.35 | 21.42 | 21.42 | 4.98 | -0.49 | 5.11 | 58.46 | 3/3 | 28/34 | 32.33 | 10.53 | 1.93 |
| mtf_H4=BREAK_UP & atr_ratio_prev=Q5 | 75min | COMPRA | 859 | 509 | 2.16 | nao | 2.30 | 1 | 37.52 | 34.60 | 34.60 | 4.67 | -0.49 | 4.78 | 59.72 | 3/3 | 19/30 | 58.10 | 11.19 | 2.92 |
| day_of_week=SUNDAY & session=NEW_YORK | 75min | COMPRA | 214 | 155 | 3.57 | nao | 6.37 | 2 | 151.61 | 48.81 | 48.81 | 4.63 | -0.49 | 4.67 | 65.81 | 2/3 | 15/24 | 70.05 | 27.84 | 102.80 |
| mtf_H1=RANGE & mtf_H4=BULLISH | 75min | COMPRA | 3,481 | 3,033 | 2.08 | nao | 2.20 | 1 | 14.67 | 11.04 | 11.04 | 4.62 | -0.49 | 4.93 | 52.59 | 3/3 | 22/34 | 14.98 | 7.09 | 3.63 |
| mtf_H1=RANGE | 75min | COMPRA | 8,093 | 5,833 | 2.55 | nao | 2.65 | 1 | 12.52 | 8.65 | 8.65 | 4.59 | -0.49 | 5.22 | 53.11 | 3/3 | 24/34 | 13.14 | 4.16 | 3.88 |
| slot_hhmm=09:45 & mtf_D1=BULLISH | 15min | COMPRA | 157 | 137 | 3.81 | nao | 4.67 | 1 | 19.41 | 18.46 | 18.46 | 4.48 | -4.12 | 5.45 | 63.50 | 3/3 | 23/24 | 25.65 | 11.37 | 0.95 |
| hour=19 & mtf_M5=BEARISH | 45min | COMPRA | 564 | 288 | 2.09 | nao | 3.26 | 1 | 23.29 | 22.23 | 22.23 | 4.43 | -2.48 | 4.90 | 65.62 | 3/3 | 27/33 | 9.16 | 35.30 | 1.06 |
| hour=19 & mtf_M15=BEARISH | 30min | COMPRA | 563 | 280 | 3.34 | nao | 3.74 | 2 | 21.30 | 20.25 | 20.25 | 4.34 | -3.49 | 5.08 | 66.43 | 3/3 | 26/34 | 16.49 | 24.00 | 1.06 |
| hour=19 & mtf_M5=BEARISH | 30min | COMPRA | 564 | 289 | 2.22 | nao | 3.79 | 1 | 18.65 | 17.59 | 17.59 | 4.26 | -3.49 | 5.08 | 64.71 | 3/3 | 24/33 | 6.47 | 28.62 | 1.06 |
| hour=19 & mtf_M15=BEARISH | 45min | COMPRA | 563 | 279 | 2.16 | nao | 3.51 | 2 | 26.06 | 25.00 | 25.00 | 4.22 | -2.48 | 4.64 | 68.46 | 3/3 | 25/34 | 21.19 | 28.78 | 1.06 |
| session=NEW_YORK & mtf_W1=BULLISH | 135min | COMPRA | 1,621 | 2,072 | 2.30 | nao | 3.40 | 1 | 32.90 | 15.84 | 15.84 | 4.20 | 1.25 | 3.90 | 54.25 | 3/3 | 15/22 | 22.43 | 9.26 | 17.06 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 45min | COMPRA | 723 | 669 | 3.15 | nao | 3.26 | 1 | 25.61 | 20.11 | 20.11 | 4.19 | -2.48 | 4.75 | 54.11 | 3/3 | 20/24 | 29.97 | 10.27 | 5.51 |
| day_of_week=THURSDAY & dom_w=d15_21 | 255min | COMPRA | 1,495 | 1,120 | 2.04 | nao | 1.73 | 1 | 40.18 | 35.06 | 35.06 | 3.98 | 2.79 | 3.74 | 61.07 | 3/3 | 23/33 | -26.30 | 96.42 | 5.12 |
| session=LONDON_NY_OVERLAP & news_min_to_next_high=Q5 | 75min | COMPRA | 2,065 | 1,303 | 2.21 | nao | 2.55 | 1 | 16.11 | 15.15 | 15.15 | 3.98 | -0.49 | 4.15 | 57.41 | 2/3 | 23/34 | 5.46 | 24.81 | 0.97 |

### M30 — modo `open`

- eventos: 33,970 (2024-01-22 a 2026-10-16); descoberta 20,334 (até 2025-09-11), validação 13,588 (a partir de 2025-09-12)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 63,105**; passaram no BH (q=5%) na descoberta: **135**; confirmadas na validação: **114**
- melhores N da descoberta que repetem na validação: top 100: 88.0%, top 1000: 52.2%, top 10000: 19.0%
- **placebo** (6 deslocamentos): top 100: 9.5% (máx 14.0%), top 1000: 8.5% (máx 10.4%), top 10000: 6.8% (máx 8.5%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 20,321 | 0.010 | 2.101 | 1.494 |
| 35min bruto | 20,321 | 0.002 | 0.244 | 0.228 |
| 45min bruto | 20,246 | -0.005 | -0.539 | -0.666 |
| 60min bruto | 19,769 | 0.014 | 1.244 | 2.015 |
| 90min bruto | 19,306 | 0.021 | 1.178 | 3.056 |
| 150min bruto | 18,442 | 0.029 | 0.909 | 4.290 |
| 270min bruto | 16,730 | 0.052 | 0.778 | 7.544 |

**M30/open: famílias distintas validadas: 796; com líquido positivo e significativo na validação (custo realista): 130.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 90min | COMPRA | 541 | 347 | 2.02 | nao | 3.62 | 1 | 38.20 | 36.58 | 36.58 | 5.64 | -1.05 | 5.76 | 67.44 | 3/3 | 27/33 | 59.61 | 13.68 | 1.62 |
| news_min_to_next_high=Q5 | 150min | COMPRA | 1,970 | 1,295 | 2.38 | nao | 3.61 | 1 | 31.44 | 26.27 | 26.27 | 5.51 | 1.02 | 5.30 | 59.15 | 2/3 | 26/34 | 29.01 | 23.53 | 5.17 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 60min | COMPRA | 558 | 359 | 2.68 | nao | 3.83 | 1 | 27.45 | 25.84 | 25.84 | 4.98 | -2.86 | 5.50 | 62.67 | 3/3 | 27/34 | 41.19 | 10.58 | 1.60 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 150min | COMPRA | 689 | 831 | 2.41 | nao | 3.26 | 1 | 33.56 | 27.86 | 27.86 | 4.90 | 1.02 | 4.69 | 58.97 | 3/3 | 17/22 | 28.78 | 26.93 | 5.70 |
| news_min_to_next_high=Q5 | 90min | COMPRA | 2,476 | 1,621 | 2.65 | nao | 4.14 | 1 | 21.16 | 16.82 | 16.82 | 4.87 | -1.05 | 5.25 | 57.74 | 2/3 | 27/34 | 17.14 | 16.49 | 4.34 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 90min | COMPRA | 349 | 325 | 2.66 | nao | 3.27 | 1 | 49.96 | 43.54 | 43.54 | 4.63 | -1.05 | 4.78 | 59.08 | 3/3 | 19/24 | 59.25 | 27.92 | 6.42 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 45min | COMPRA | 578 | 373 | 2.74 | nao | 3.83 | 1 | 20.83 | 19.25 | 19.25 | 4.32 | -4.26 | 5.24 | 60.32 | 3/3 | 26/34 | 27.58 | 10.96 | 1.58 |
| mtf_W1=BULLISH & news_min_to_next_high=Q5 | 90min | COMPRA | 859 | 1,032 | 2.79 | nao | 3.85 | 1 | 22.14 | 17.35 | 17.35 | 4.32 | -1.05 | 4.57 | 57.66 | 3/3 | 18/22 | 18.50 | 16.19 | 4.80 |
| mtf_H1=RANGE | 90min | COMPRA | 4,042 | 2,917 | 2.03 | nao | 2.99 | 1 | 16.37 | 11.85 | 11.85 | 4.08 | -1.05 | 4.78 | 54.03 | 3/3 | 25/34 | 17.62 | 6.09 | 4.52 |
| mtf_W1=BREAK_UP & news_min_to_next_high=Q3 | 150min | COMPRA | 162 | 256 | 2.10 | nao | 1.74 | 1 | 44.48 | 43.58 | 43.58 | 3.96 | 1.02 | 3.86 | 63.67 | 3/3 | 6/10 | 73.51 | 13.65 | 0.90 |
| session=LONDON_NY_OVERLAP & news_min_to_next_high=Q5 | 90min | COMPRA | 977 | 617 | 2.24 | nao | 2.70 | 1 | 21.52 | 20.55 | 20.55 | 3.71 | -1.05 | 3.91 | 56.73 | 2/3 | 24/34 | 9.35 | 31.72 | 0.96 |
| hour=19 & mtf_M1=BEARISH | 60min | COMPRA | 258 | 152 | 2.49 | nao | 3.85 | 1 | 26.98 | 25.92 | 25.92 | 3.69 | -2.86 | 4.06 | 71.71 | 3/3 | 26/32 | 19.27 | 32.58 | 1.06 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 35min | COMPRA | 578 | 373 | 2.42 | nao | 3.55 | 1 | 16.35 | 14.77 | 14.77 | 3.57 | -4.85 | 4.73 | 58.71 | 3/3 | 26/34 | 22.52 | 7.06 | 1.58 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q5 | 30min | COMPRA | 578 | 373 | 2.09 | nao | 3.98 | 1 | 14.73 | 13.15 | 13.15 | 3.56 | -3.98 | 4.63 | 56.84 | 3/3 | 27/34 | 19.07 | 7.26 | 1.58 |
| mtf_H4=BREAK_UP & pcum10=Q5 | 90min | COMPRA | 868 | 676 | 2.69 | nao | 2.48 | 1 | 24.24 | 20.45 | 20.45 | 3.51 | -1.05 | 3.74 | 55.33 | 3/3 | 25/33 | 29.61 | 11.29 | 3.79 |
| mtf_H4=BREAK_UP & atr_ratio_prev=Q5 | 90min | COMPRA | 396 | 235 | 2.04 | nao | 2.03 | 1 | 45.97 | 43.73 | 43.73 | 3.48 | -1.05 | 3.59 | 58.72 | 3/3 | 18/26 | 48.20 | 39.29 | 2.24 |
| news_min_to_next_high=Q5 & range_atr_prev=Q5 | 90min | COMPRA | 322 | 226 | 2.32 | nao | 2.22 | 1 | 40.78 | 38.09 | 38.09 | 3.48 | -1.05 | 3.59 | 61.06 | 3/3 | 26/33 | 25.05 | 51.13 | 2.69 |
| mtf_H4=BREAK_UP & dom_w=d15_21 | 60min | COMPRA | 361 | 334 | 3.08 | nao | 3.21 | 1 | 32.80 | 26.52 | 26.52 | 3.44 | -2.86 | 3.85 | 57.78 | 3/3 | 21/24 | 38.96 | 14.09 | 6.27 |
| hour=19 & mtf_M1=BEARISH | 45min | COMPRA | 258 | 152 | 2.71 | nao | 3.54 | 1 | 23.28 | 22.23 | 22.23 | 3.37 | -4.26 | 3.98 | 68.42 | 3/3 | 29/32 | 15.93 | 28.52 | 1.06 |
| news_min_to_next_high=Q5 | 60min | COMPRA | 2,611 | 1,712 | 2.55 | nao | 3.93 | 1 | 13.63 | 9.45 | 9.45 | 3.36 | -2.86 | 4.48 | 55.72 | 2/3 | 26/34 | 7.62 | 11.28 | 4.18 |
| slot_hhmm=14:30 & news_min_to_next_high=Q5 | 45min | COMPRA | 130 | 84 | 2.04 | nao | 2.73 | 1 | 41.26 | 40.26 | 40.26 | 3.35 | -4.26 | 3.69 | 64.29 | 3/3 | 16/24 | 34.37 | 46.15 | 1.00 |
| month=6 & dom_w=d15_21 | 150min | COMPRA | 431 | 215 | 2.37 | nao | 1.71 | 1 | 36.54 | 30.78 | 30.78 | 3.28 | 1.02 | 3.13 | 53.49 | 3/3 | 3/3 | 6.47 | 54.86 | 5.76 |
| dom_w=d15_21 & atr_ratio_prev=Q5 | 150min | COMPRA | 669 | 448 | 2.15 | nao | 1.90 | 1 | 42.85 | 38.13 | 38.13 | 3.21 | 1.02 | 3.19 | 55.80 | 3/3 | 16/25 | 26.29 | 49.97 | 4.72 |
| session=LONDON_NY_OVERLAP & news_min_to_next_high=Q5 | 60min | COMPRA | 978 | 618 | 2.30 | nao | 2.76 | 1 | 16.19 | 15.23 | 15.23 | 3.18 | -2.86 | 3.81 | 56.31 | 2/3 | 22/34 | 6.30 | 24.15 | 0.96 |
| hour=19 & news_state=NONE_60M | 60min | COMPRA | 472 | 306 | 2.18 | nao | 2.43 | 1 | 17.26 | 16.20 | 16.20 | 3.15 | -2.86 | 3.67 | 63.07 | 3/3 | 24/34 | 12.26 | 20.14 | 1.06 |

### H1 — modo `open`

- eventos: 33,106 (2021-06-07 a 2026-10-16); descoberta 19,839 (até 2024-08-26), validação 13,243 (a partir de 2024-08-27)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 63,067**; passaram no BH (q=5%) na descoberta: **716**; confirmadas na validação: **466**
- melhores N da descoberta que repetem na validação: top 100: 97.0%, top 1000: 57.0%, top 10000: 20.4%
- **placebo** (6 deslocamentos): top 100: 22.7% (máx 35.0%), top 1000: 14.6% (máx 19.2%), top 10000: 9.4% (máx 10.9%); BH: média 4.2 (máx 13); confirmadas: média 0.7 (máx 3)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 19,839 | 0.025 | 5.011 | 5.000 |
| 65min bruto | 19,839 | 0.010 | 1.733 | 1.963 |
| 75min bruto | 19,780 | 0.010 | 1.506 | 2.011 |
| 90min bruto | 19,710 | 0.018 | 2.344 | 3.709 |
| 120min bruto | 18,822 | 0.038 | 3.284 | 7.624 |
| 180min bruto | 17,911 | 0.055 | 2.938 | 11.189 |
| 300min bruto | 16,135 | 0.090 | 2.481 | 18.134 |

**H1/open: famílias distintas validadas: 920; com líquido positivo e significativo na validação (custo realista): 161.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=FRIDAY & month=6 | 300min | COMPRA | 257 | 133 | 2.55 | nao | 2.48 | 1 | 129.26 | 128.30 | 128.30 | 6.10 | 0.79 | 6.00 | 63.91 | 6/6 | 6/6 | 236.02 | 22.20 | 0.95 |
| session=ASIA & atr_ratio_prev=Q1 | 300min | COMPRA | 1,750 | 1,015 | 2.24 | nao | 2.21 | 1 | 45.56 | 44.60 | 44.60 | 4.68 | 0.79 | 4.63 | 55.86 | 6/6 | 41/65 | 74.08 | 15.18 | 0.96 |
| mtf_W1=BULLISH & month=6 | 300min | COMPRA | 1,143 | 320 | 2.18 | nao | 2.02 | 1 | 46.84 | 39.68 | 39.68 | 4.61 | 0.79 | 4.20 | 60.62 | 5/5 | 5/5 | 28.40 | 50.95 | 7.16 |
| day_of_week=FRIDAY & month=6 | 180min | COMPRA | 289 | 150 | 2.53 | nao | 2.20 | 1 | 69.31 | 68.35 | 68.35 | 4.36 | 0.13 | 4.32 | 58.00 | 6/6 | 6/6 | 128.48 | 8.22 | 0.96 |
| session=ASIA & atr_ratio_prev=Q1 | 180min | COMPRA | 1,770 | 1,016 | 2.55 | nao | 2.21 | 1 | 29.20 | 28.24 | 28.24 | 3.86 | 0.13 | 3.88 | 55.51 | 6/6 | 40/65 | 47.83 | 8.64 | 0.96 |
| mtf_W1=BULLISH & month=3 | 300min | COMPRA | 378 | 294 | 2.04 | nao | 2.11 | 1 | 68.72 | 61.85 | 61.85 | 3.78 | 0.79 | 3.72 | 60.54 | 3/3 | 3/3 | 59.52 | 64.18 | 6.86 |
| slot_hhmm=19:00 & mtf_H1=RANGE | 60min | COMPRA | 146 | 114 | 2.30 | nao | 3.96 | 4 | 36.48 | 35.43 | 35.43 | 3.70 | -3.28 | 4.01 | 62.28 | 6/6 | 20/28 | 30.37 | 40.49 | 1.06 |
| mtf_M15=BULLISH | 180min | COMPRA | 6,659 | 4,187 | 2.62 | nao | 3.39 | 1 | 21.85 | 15.82 | 15.82 | 3.37 | 0.13 | 4.08 | 53.19 | 6/6 | 37/65 | 22.27 | 9.37 | 6.03 |
| mtf_M30=BULLISH & mtf_D1=BULLISH | 180min | COMPRA | 3,112 | 1,718 | 2.56 | nao | 2.69 | 1 | 25.62 | 19.43 | 19.43 | 3.27 | 0.13 | 3.35 | 55.06 | 6/6 | 33/57 | 31.07 | 7.80 | 6.18 |
| slot_hhmm=19:00 & structure_before=RANGE | 65min | COMPRA | 146 | 114 | 2.25 | nao | 3.24 | 4 | 33.19 | 32.14 | 32.14 | 3.22 | -5.17 | 3.71 | 63.16 | 6/6 | 18/28 | 21.23 | 43.05 | 1.06 |
| mtf_H1=BULLISH & mtf_D1=BULLISH | 300min | COMPRA | 2,782 | 1,500 | 2.74 | nao | 2.27 | 2 | 35.18 | 27.02 | 27.02 | 3.15 | 0.79 | 3.16 | 53.47 | 6/6 | 34/57 | 30.10 | 23.93 | 8.16 |
| mtf_W1=BULLISH & month=6 | 180min | COMPRA | 1,273 | 361 | 2.43 | nao | 1.99 | 1 | 27.12 | 20.66 | 20.66 | 3.11 | 0.13 | 2.91 | 57.34 | 5/5 | 5/5 | 16.15 | 25.14 | 6.47 |
| hour=19 & pcum3=Q1 | 75min | COMPRA | 139 | 90 | 2.09 | nao | 3.16 | 2 | 68.94 | 67.88 | 67.88 | 3.10 | -4.68 | 3.30 | 61.11 | 6/6 | 17/21 | 56.16 | 79.61 | 1.06 |
| session=ASIA & atr_ratio_prev=Q1 | 120min | COMPRA | 1,783 | 1,018 | 2.58 | nao | 2.17 | 1 | 19.54 | 18.58 | 18.58 | 3.05 | -2.26 | 3.46 | 53.24 | 6/6 | 45/65 | 30.84 | 6.32 | 0.96 |
| session=LONDON & mtf_M15=BULLISH | 120min | COMPRA | 1,581 | 1,041 | 2.59 | nao | 2.65 | 1 | 24.64 | 23.65 | 23.65 | 3.02 | -2.26 | 3.45 | 54.08 | 6/6 | 43/65 | 42.34 | 5.01 | 0.99 |
| day_of_week=FRIDAY & month=6 | 120min | COMPRA | 305 | 159 | 2.32 | nao | 1.78 | 1 | 40.37 | 39.41 | 39.41 | 3.00 | -2.26 | 3.16 | 56.60 | 5/6 | 5/6 | 82.40 | -3.05 | 0.97 |
| mtf_M30=BULLISH & dom_w=d15_21 | 180min | COMPRA | 1,609 | 953 | 2.01 | nao | 2.50 | 1 | 34.58 | 27.62 | 27.62 | 3.00 | 0.13 | 3.08 | 53.52 | 5/6 | 37/65 | 16.02 | 39.19 | 6.97 |
| mtf_W1=BULLISH & month=3 | 180min | COMPRA | 416 | 326 | 2.28 | nao | 2.35 | 1 | 43.56 | 37.27 | 37.27 | 2.96 | 0.13 | 2.95 | 60.74 | 3/3 | 3/3 | 35.35 | 39.19 | 6.29 |
| slot_hhmm=19:00 & pcum3=Q1 | 65min | COMPRA | 139 | 90 | 3.35 | nao | 2.94 | 2 | 60.31 | 59.25 | 59.25 | 2.94 | -5.17 | 3.19 | 58.89 | 6/6 | 16/21 | 56.96 | 61.54 | 1.06 |
| mtf_M15=BULLISH & mtf_D1=BULLISH | 300min | COMPRA | 2,718 | 1,457 | 2.23 | nao | 1.68 | 1 | 32.58 | 26.29 | 26.29 | 2.94 | 0.79 | 2.96 | 56.07 | 5/6 | 30/58 | 45.52 | 7.09 | 6.29 |
| news_min_to_next_high=Q3 & atr_ratio_prev=Q1 | 180min | COMPRA | 197 | 423 | 2.34 | nao | 1.78 | 1 | 34.61 | 33.68 | 33.68 | 2.93 | 0.13 | 2.93 | 58.87 | 4/4 | 25/35 | 43.82 | 23.59 | 0.93 |
| dow_slot=WEDNESDAY|21:00 | 180min | VENDA | 151 | 104 | -2.01 | nao | -1.77 | 7 | 62.16 | 15.21 | 61.16 | 2.93 | -7.19 | 3.26 | 64.42 | 4/6 | 11/19 | 94.76 | 27.56 | 1.01 |
| news_min_to_next_high=Q1 & news_min_since_last_high=Q5 | 90min | VENDA | 279 | 694 | -2.48 | nao | -2.09 | 1 | 34.16 | 33.16 | 33.14 | 2.93 | -5.53 | 3.56 | 54.18 | 4/4 | 25/37 | 43.12 | 23.16 | 1.02 |
| mtf_M15=BULLISH | 300min | COMPRA | 5,917 | 3,726 | 2.13 | nao | 2.28 | 1 | 25.90 | 19.25 | 19.25 | 2.91 | 0.79 | 3.40 | 54.72 | 6/6 | 41/65 | 23.99 | 14.52 | 6.64 |
| dow_slot=SUNDAY|22:00 | 90min | COMPRA | 163 | 111 | 7.06 | sim | 5.79 | 7 | 124.33 | 50.90 | 50.90 | 2.88 | -4.03 | 3.10 | 62.16 | 6/6 | 14/19 | 44.71 | 56.97 | 73.44 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **3267**
- com líquido positivo e t>1,645 na validação, custo realista: **543**; dessas, sobreviveram ao BH: **29**; e positivas nas duas metades da validação: **29**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | open | day_of_week=SUNDAY & session=NEW_YORK | 65min | COMPRA | 345 | 34.07 | -1.80 | 5.21 | 4.95 | 62.32 | 2/2 | 8/14 |
| M15 | open | slot_hhmm=09:45 | 15min | COMPRA | 284 | 12.48 | -4.12 | 3.89 | 2.92 | 61.97 | 3/3 | 30/34 |
| H1 | open | dow_slot=SUNDAY|22:00 | 90min | COMPRA | 111 | 50.90 | -4.03 | 3.10 | 2.88 | 62.16 | 6/6 | 14/19 |
| M15 | open | slot_hhmm=09:45 & news_state=NONE_60M | 15min | COMPRA | 278 | 12.49 | -4.12 | 3.82 | 2.86 | 61.87 | 3/3 | 30/34 |
| M15 | open | hour=19 & structure_before=BEARISH | 15min | COMPRA | 280 | 8.96 | -4.12 | 3.89 | 2.67 | 57.50 | 3/3 | 24/34 |
| H1 | open | dow_slot=SUNDAY|22:00 | 120min | COMPRA | 111 | 51.69 | -2.26 | 2.75 | 2.64 | 63.06 | 6/6 | 13/19 |
| M15 | open | slot_hhmm=19:45 & news_state=NONE_60M | 15min | COMPRA | 168 | 7.50 | -4.12 | 3.76 | 2.45 | 55.95 | 3/3 | 27/33 |
| M15 | open | slot_hhmm=09:45 & mtf_H4=BULLISH | 15min | COMPRA | 111 | 11.63 | -4.12 | 3.20 | 2.37 | 58.56 | 3/3 | 27/30 |
| H1 | open | slot_hhmm=16:00 & p2=Q5 | 60min | COMPRA | 161 | 24.79 | -3.28 | 2.63 | 2.33 | 59.01 | 5/6 | 37/52 |
| H1 | open | day_of_week=SUNDAY & mtf_W1=BULLISH | 120min | COMPRA | 127 | 44.59 | -2.26 | 2.26 | 2.15 | 63.78 | 6/6 | 29/41 |
| H1 | open | day_of_week=SUNDAY & mtf_W1=BULLISH | 90min | COMPRA | 127 | 39.68 | -4.03 | 2.36 | 2.14 | 59.06 | 6/6 | 26/41 |
| H1 | open | structure_before=BULLISH & mtf_D1=BULLISH | 180min | COMPRA | 1,669 | 12.28 | 0.13 | 2.10 | 2.07 | 53.15 | 6/6 | 33/57 |
| M30 | open | mtf_H4=BREAK_UP & pcum10=Q5 | 35min | COMPRA | 701 | 7.63 | -4.85 | 3.43 | 2.07 | 52.07 | 3/3 | 22/33 |
| H1 | open | day_of_week=SUNDAY & gap=Y | 90min | COMPRA | 111 | 41.10 | -4.03 | 2.25 | 2.05 | 60.36 | 4/6 | 11/20 |
| H1 | open | day_of_week=SUNDAY & mtf_W1=BULLISH | 75min | COMPRA | 127 | 36.06 | -4.68 | 2.26 | 2.00 | 57.48 | 6/6 | 27/41 |
| H1 | open | gap=Y | 90min | COMPRA | 117 | 38.40 | -4.03 | 2.21 | 2.00 | 59.83 | 4/6 | 16/25 |
| H1 | open | dow_slot=SUNDAY|22:00 | 75min | COMPRA | 111 | 35.86 | -4.68 | 2.23 | 1.98 | 60.36 | 6/6 | 12/19 |
| H1 | open | session=LONDON & mtf_M15=BULLISH | 60min | COMPRA | 1,044 | 10.27 | -3.28 | 2.66 | 1.94 | 52.87 | 5/6 | 46/65 |
| H1 | open | day_of_week=SUNDAY & streak_prev=1 | 90min | COMPRA | 89 | 49.08 | -4.03 | 2.09 | 1.93 | 59.55 | 5/6 | 7/12 |
| H1 | open | mtf_M1=BREAK_DOWN & pcum10=Q4 | 65min | COMPRA | 134 | 28.63 | -5.17 | 2.25 | 1.90 | 55.97 | 5/6 | 25/31 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 375s)_
