# US30 — relatório completo MBA (gerado em 2026-10-17 02:30)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | Raw Trading Ltd |
| servidor | ICMarketsSC-Demo |
| simbolo | US30 |
| descricao | US Wall Street 30 Index |
| digitos | 2 |
| ponto | 0.01000 |
| tick_size | 0.01000 |
| tick_value | 0.01000 |
| contrato | 1.00000 |
| lote_min | 0.10000 |
| swap_long | -12.42400 |
| swap_short | -0.15700 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-01-22 01:22 | 2026-10-16 23:58 | 209 | 1,144,477 | 0 | 117,751 | 117,751 | 1 |
| M5 | 101,153 | 2025-05-15 03:15 | 2026-10-16 23:50 | 377 | 681 | 0 | 23,560 | 23,560 | 1 |
| M15 | 64,708 | 2024-01-22 06:30 | 2026-10-16 23:30 | 713 | 292 | 0 | 7,854 | 7,854 | 0 |
| M30 | 32,355 | 2024-01-22 12:00 | 2026-10-16 23:00 | 711 | 146 | 0 | 3,927 | 3,927 | 0 |
| H1 | 32,366 | 2021-04-27 01:00 | 2026-10-16 22:00 | 1,406 | 73 | 0 | 1,963 | 1,963 | 0 |
| H4 | 15,381 | 2016-10-24 20:00 | 2026-10-16 16:00 | 593 | 18 | 0 | 511 | 511 | 0 |
| D1 | 2,557 | 2016-11-21 00:00 | 2026-10-15 00:00 | 524 | 3 | 0 | 84 | 84 | 0 |
| W1 | 498 | 2017-03-26 00:00 | 2026-10-04 00:00 | 0 | 0 | 0 | 16 | 16 | 0 |
| MN1 | 97 | 2018-09-01 00:00 | 2026-09-01 00:00 | 0 | 0 | 0 | 3 | 3 | 0 |

Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).

## 3. Custo e microestrutura (base M5)

Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.

| hora_utc | spread_med | spread_p90 | spread_max | range_med_pts | atr_med_pts | ticks_vol_med | n | spread_ticks_med | pct_barras_spread0 | custo_sobre_ATR |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 120.00 | 120.00 | 170.00 | 1,700.00 | 1,661.79 | 277.00 | 4,437 | 120.00 | 0.00 | 0.07 |
| 1 | 120.00 | 120.00 | 170.00 | 1,500.00 | 1,657.14 | 244.50 | 4,440 | 120.00 | 0.02 | 0.07 |
| 2 | 120.00 | 120.00 | 170.00 | 1,180.00 | 1,428.57 | 170.00 | 4,440 | 120.00 | 0.00 | 0.08 |
| 3 | 120.00 | 120.00 | 170.00 | 1,050.00 | 1,160.71 | 140.00 | 4,432 | 120.00 | 0.02 | 0.10 |
| 4 | 120.00 | 120.00 | 170.00 | 950.00 | 1,071.43 | 117.00 | 4,428 | 120.00 | 0.00 | 0.11 |
| 5 | 120.00 | 120.00 | 170.00 | 1,200.00 | 1,135.71 | 160.00 | 4,415 | 120.00 | 0.02 | 0.11 |
| 6 | 120.00 | 120.00 | 170.00 | 1,600.00 | 1,492.86 | 224.00 | 4,415 | 120.00 | 0.05 | 0.08 |
| 7 | 120.00 | 120.00 | 170.00 | 2,000.00 | 1,917.86 | 321.00 | 4,426 | 120.00 | 0.02 | 0.06 |
| 8 | 120.00 | 120.00 | 170.00 | 2,100.00 | 2,210.71 | 360.00 | 4,428 | 120.00 | 0.02 | 0.05 |
| 9 | 120.00 | 120.00 | 170.00 | 1,750.00 | 2,007.14 | 273.00 | 4,424 | 120.00 | 0.02 | 0.06 |
| 10 | 120.00 | 120.00 | 170.00 | 1,750.00 | 1,914.29 | 249.00 | 4,428 | 120.00 | 0.02 | 0.06 |
| 11 | 120.00 | 120.00 | 170.00 | 2,000.00 | 2,066.07 | 288.00 | 4,428 | 120.00 | 0.20 | 0.06 |
| 12 | 120.00 | 120.00 | 170.00 | 2,400.00 | 2,375.00 | 390.00 | 4,428 | 120.00 | 0.16 | 0.05 |
| 13 | 120.00 | 120.00 | 170.00 | 3,900.00 | 3,342.86 | 719.00 | 4,413 | 120.00 | 5.08 | 0.04 |
| 14 | 70.00 | 120.00 | 170.00 | 5,100.00 | 5,731.43 | 1,123.00 | 4,421 | 70.00 | 3.66 | 0.01 |
| 15 | 70.00 | 70.00 | 110.00 | 4,300.00 | 5,176.07 | 1,040.50 | 4,428 | 70.00 | 1.63 | 0.01 |
| 16 | 70.00 | 70.00 | 100.00 | 3,600.00 | 4,104.29 | 880.00 | 4,427 | 70.00 | 0.95 | 0.02 |
| 17 | 70.00 | 70.00 | 100.00 | 3,200.00 | 3,569.29 | 799.00 | 4,323 | 70.00 | 0.81 | 0.02 |
| 18 | 70.00 | 70.00 | 100.00 | 3,000.00 | 3,232.14 | 760.00 | 4,266 | 70.00 | 0.94 | 0.02 |
| 19 | 70.00 | 70.00 | 100.00 | 3,200.00 | 3,060.71 | 815.00 | 4,260 | 70.00 | 1.10 | 0.02 |
| 20 | 70.00 | 70.00 | 110.00 | 1,900.00 | 2,978.57 | 263.00 | 4,259 | 70.00 | 0.49 | 0.02 |
| 21 | 70.00 | 70.00 | 100.00 | 1,600.00 | 3,171.43 | 222.00 | 996 |  | 0.20 | 0.02 |
| 22 | 120.00 | 120.00 | 332.00 | 1,400.00 | 1,736.43 | 117.00 | 3,363 | 120.00 | 0.09 | 0.07 |
| 23 | 120.00 | 120.00 | 170.00 | 1,300.00 | 1,457.14 | 128.00 | 4,428 | 120.00 | 0.02 | 0.08 |

Spread geral (mediana M5): **120.0 pts**, p90 120.0, máx 332. ATR mediano M5: **2232.1 pts**. Razão spread/ATR: **0.05**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 509 | 42,519.37 | 3,790.56 | 32,076.55 | 56.39 | 2.67 |
| ter | 515 | 43,348.41 | 68.99 | 29,802.92 | 49.90 | 0.05 |
| qua | 513 | 44,414.08 | 1,676.89 | 34,718.26 | 54.19 | 1.09 |
| qui | 515 | 45,829.64 | -43.27 | 33,636.76 | 53.40 | -0.03 |
| sex | 505 | 44,658.63 | 1,316.05 | 34,425.52 | 55.84 | 0.86 |

Autocorrelação do retorno diário (lags 1-5): -0.099, +0.053, -0.040, -0.047, +0.044 (banda ±0.040). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.319, +0.212, +0.209.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 1,416 | 0 | -0.017 | -1.589 | nao |
| 1,416 | 1 | -0.005 | -0.519 | nao |
| 1,416 | 2 | 0.002 | 0.337 | nao |
| 1,416 | 3 | -0.007 | -1.027 | nao |
| 1,415 | 4 | 0.009 | 1.323 | nao |
| 1,415 | 5 | 0.002 | 0.262 | nao |
| 1,414 | 6 | -0.004 | -0.294 | nao |
| 1,415 | 7 | -0.016 | -0.854 | nao |
| 1,415 | 8 | 0.032 | 1.636 | nao |
| 1,414 | 9 | 0.007 | 0.360 | nao |
| 1,414 | 10 | 0.025 | 1.262 | nao |
| 1,414 | 11 | -0.004 | -0.181 | nao |
| 1,414 | 12 | -0.010 | -0.328 | nao |
| 1,415 | 13 | 0.060 | 1.405 | nao |
| 1,415 | 14 | 0.004 | 0.090 | nao |
| 1,414 | 15 | 0.021 | 0.662 | nao |
| 1,414 | 16 | 0.018 | 0.762 | nao |
| 1,391 | 17 | -0.016 | -0.749 | nao |
| 1,374 | 18 | 0.028 | 1.293 | nao |
| 1,365 | 19 | 0.006 | 0.266 | nao |
| 1,364 | 20 | 0.001 | 0.033 | nao |
| 426 | 21 | 0.013 | 0.772 | nao |
| 978 | 22 | -0.008 | -0.642 | nao |
| 1,416 | 23 | -0.015 | -1.678 | nao |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 6,365 | 0 | 0.017 | 1.907 | nao |
| 6,571 | 1 | -0.006 | -0.602 | nao |
| 6,523 | 2 | -0.003 | -0.261 | nao |
| 6,488 | 3 | 0.006 | 0.621 | nao |
| 5,943 | 4 | 0.013 | 1.238 | nao |
| 476 | 6 | -0.014 | -0.714 | nao |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,437 | 1 | 0.008 | 0.506 | nao |
| 2,303 | 2 | -0.020 | -1.132 | nao |
| 2,515 | 3 | -0.001 | -0.085 | nao |
| 2,478 | 4 | -0.008 | -0.491 | nao |
| 3,015 | 5 | 0.003 | 0.208 | nao |
| 2,948 | 6 | 0.013 | 0.906 | nao |
| 3,025 | 7 | 0.023 | 1.633 | nao |
| 3,039 | 8 | 0.009 | 0.661 | nao |
| 2,964 | 9 | -0.030 | -2.072 | nao |
| 2,806 | 10 | 0.023 | 1.592 | nao |
| 2,415 | 11 | 0.037 | 2.307 | nao |
| 2,421 | 12 | 0.002 | 0.105 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 120 combinações testadas):

_(sem linhas)_

Autocorrelação do retorno H1, lags 1-10: +0.009, -0.006, -0.003, -0.005, +0.005, -0.001, +0.005, -0.001, -0.001, +0.003 (banda ±0.011). |retorno|: +0.258, +0.173, +0.038, -0.208, +0.226 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 490 | 0.026 | 0.487 | 50.204 |
| barra < -2 ATR | 535 | -0.038 | -0.699 | 51.776 |
| barra > +1 ATR | 2,380 | 0.016 | 0.716 | 50.252 |
| barra < -1 ATR | 2,450 | -0.039 | -1.714 | 50.490 |
| gap (barra ausente antes) | 1,406 | -0.010 | -1.115 | 49.075 |

Distribuição do retorno H1 em ATR: média +0.0052, desvio 0.792, assimetria -0.15, curtose 6.0; barras |ret|>2 ATR: 3.17%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 120.0 pts, máxima 120.0 pts no slot NY 00:00; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | open | 100,931 | 72,195 | 0 | 0 | 0.0 | 0.0 | 0 | 5.0 | 3.7 |
| M15 | open | 64,600 | 77,642 | 0 | 0 | 0.0 | 0.0 | 0 | 4.0 | 5.8 |
| M30 | open | 32,298 | 61,589 | 0 | 0 | 0.0 | 0.0 | 0 | 6.0 | 5.3 |
| H1 | open | 32,283 | 61,399 | 0 | 0 | 0.0 | 0.0 | 0 | 22.0 | 5.7 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 100,931 (2025-05-15 a 2026-10-16); descoberta 60,282 (até 2026-03-24), validação 40,373 (a partir de 2026-03-25)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 72,195**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 5.0%, top 1000: 5.0%, top 10000: 3.8%
- **placebo** (6 deslocamentos): top 100: 3.7% (máx 10.0%), top 1000: 3.9% (máx 7.9%), top 10000: 3.3% (máx 4.4%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 60,269 | 0.001 | 0.242 | 1.500 |
| 10min bruto | 60,269 | 0.002 | 0.304 | 4.061 |
| 20min bruto | 59,660 | 0.004 | 0.311 | 8.693 |
| 35min bruto | 58,800 | 0.007 | 0.294 | 15.013 |
| 65min bruto | 57,148 | 0.012 | 0.259 | 26.518 |
| 125min bruto | 54,011 | 0.052 | 0.523 | 117.238 |
| 245min bruto | 47,905 | 0.178 | 0.711 | 398.430 |

**M5/open: famílias distintas validadas: 47; com líquido positivo e significativo na validação (custo realista): 23.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=FRIDAY & month=3 | 245min | VENDA | 627 | 205 | -2.22 | nao | -2.17 | 1 | 21,397.90 | 21,287.88 | 21,299.51 | 18.39 | -834.97 | 19.12 | 81.95 | 1/1 | 1/1 | 11,989.31 | 30,519.31 | 98.40 |
| day_of_week=FRIDAY & month=3 | 125min | VENDA | 699 | 229 | -2.13 | nao | -2.23 | 1 | 10,940.61 | 10,834.78 | 10,839.95 | 14.37 | -457.75 | 14.99 | 78.60 | 1/1 | 1/1 | 5,587.46 | 16,046.77 | 100.66 |
| mtf_W1=BEARISH & news_min_since_last_high=Q2 | 125min | COMPRA | 171 | 295 | 2.11 | nao | 1.72 | 1 | 4,809.02 | 4,728.34 | 4,728.34 | 8.83 | 247.99 | 8.37 | 66.10 | 2/2 | 2/2 | 3,589.93 | 5,859.05 | 80.68 |
| mtf_W1=BEARISH & news_min_since_last_high=Q2 | 65min | COMPRA | 219 | 367 | 2.34 | nao | 2.19 | 1 | 3,317.33 | 3,238.75 | 3,238.75 | 7.74 | 73.41 | 7.58 | 68.94 | 2/2 | 2/2 | 3,022.35 | 3,453.97 | 78.58 |
| month=3 & news_min_since_last_high=Q5 | 65min | VENDA | 394 | 198 | -2.92 | nao | -1.67 | 1 | 2,775.20 | 2,655.80 | 2,659.36 | 4.85 | -282.38 | 5.36 | 66.67 | 1/1 | 1/1 | 5,249.28 | 69.44 | 115.84 |
| mtf_D1=RANGE & news_min_since_last_high=Q3 | 35min | COMPRA | 1,494 | 563 | 2.05 | nao | 1.99 | 1 | 1,228.31 | 1,109.82 | 1,109.82 | 4.17 | -14.69 | 4.25 | 57.90 | 2/2 | 10/14 | 2,047.86 | 175.11 | 118.49 |
| hour=11 & mtf_D1=RANGE | 20min | COMPRA | 528 | 228 | 2.18 | nao | 1.70 | 1 | 1,272.59 | 1,152.59 | 1,152.59 | 3.34 | -54.97 | 3.50 | 52.63 | 2/2 | 11/15 | 569.47 | 1,735.70 | 120.00 |
| hour=1 & mtf_H4=BREAK_UP | 20min | COMPRA | 168 | 84 | 2.60 | nao | 1.73 | 1 | 963.69 | 843.69 | 843.69 | 3.12 | -54.97 | 3.30 | 60.71 | 2/2 | 12/16 | 1,280.00 | 407.38 | 120.00 |
| mtf_D1=BULLISH & news_min_to_next_high=Q1 | 35min | COMPRA | 4,603 | 2,476 | 2.30 | nao | 1.72 | 1 | 595.74 | 486.00 | 486.00 | 3.07 | -14.69 | 3.31 | 54.20 | 2/2 | 10/15 | 862.28 | 109.73 | 109.74 |
| month=3 & news_min_since_last_high=Q5 | 35min | VENDA | 394 | 198 | -2.82 | nao | -1.70 | 1 | 1,536.97 | 1,417.56 | 1,419.22 | 3.06 | -193.93 | 3.48 | 66.67 | 1/1 | 1/1 | 3,190.10 | -351.66 | 117.75 |
| mtf_D1=BREAK_DOWN & news_min_since_last_high=Q2 | 35min | COMPRA | 124 | 299 | 2.05 | nao | 1.97 | 1 | 967.19 | 880.13 | 880.13 | 3.04 | -14.69 | 3.09 | 55.52 | 2/2 | 4/4 | 14.23 | 1,740.27 | 87.06 |
| month=9 & news_min_since_last_high=Q2 | 35min | COMPRA | 669 | 626 | 2.04 | nao | 1.67 | 1 | 670.02 | 591.79 | 591.79 | 2.80 | -14.69 | 2.88 | 53.19 | 2/2 | 2/2 | 492.01 | 691.57 | 78.23 |
| mtf_H4=BREAK_UP & atr_ratio_prev=Q1 | 20min | COMPRA | 627 | 639 | 2.34 | nao | 1.72 | 1 | 324.69 | 204.69 | 204.69 | 2.79 | -54.97 | 3.41 | 54.46 | 2/2 | 10/16 | 402.60 | 7.41 | 120.00 |
| session=ASIA & mtf_H4=BREAK_UP | 20min | COMPRA | 1,015 | 744 | 2.95 | nao | 1.86 | 1 | 338.23 | 218.23 | 218.23 | 2.57 | -54.97 | 3.15 | 54.97 | 2/2 | 12/16 | 365.73 | 70.73 | 120.00 |
| hour=1 & mtf_H4=BREAK_UP | 10min | COMPRA | 168 | 84 | 2.63 | nao | 2.05 | 1 | 613.69 | 493.69 | 493.69 | 2.46 | -81.68 | 2.84 | 54.76 | 2/2 | 13/16 | 637.14 | 350.24 | 120.00 |
| day_of_week=SUNDAY & p1=Q1 | 10min | COMPRA | 133 | 119 | 2.60 | nao | 1.79 | 1 | 762.27 | 642.27 | 642.27 | 2.37 | -81.68 | 2.66 | 56.30 | 2/2 | 14/18 | 1,036.10 | 255.00 | 120.00 |
| mtf_W1=BREAK_UP & atr_ratio_prev=Q5 | 10min | VENDA | 3,193 | 774 | -2.14 | nao | -1.74 | 1 | 442.92 | 366.41 | 367.56 | 2.20 | -126.68 | 3.00 | 54.01 | 2/2 | 9/12 | 302.28 | 432.83 | 75.36 |
| hour=14 & range_atr_prev=Q5 | 5min | COMPRA | 830 | 197 | 2.08 | nao | 1.74 | 1 | 817.26 | 747.22 | 747.22 | 2.03 | -95.76 | 2.29 | 53.81 | 2/2 | 12/18 | 1,274.25 | 225.52 | 70.04 |
| slot_hhmm=15:20 & mtf_W1=BULLISH | 5min | COMPRA | 123 | 65 | 2.36 | nao | 2.02 | 1 | 962.46 | 892.46 | 892.46 | 1.96 | -95.76 | 2.16 | 60.00 | 2/2 | 9/13 | 1,866.87 | -52.42 | 70.00 |
| month=3 & news_min_since_last_high=Q5 | 20min | VENDA | 394 | 198 | -2.87 | nao | -1.73 | 1 | 904.60 | 785.19 | 786.09 | 1.96 | -153.46 | 2.34 | 61.11 | 1/1 | 1/1 | 1,950.20 | -378.02 | 118.51 |
| mtf_D1=BULLISH & news_min_to_next_high=Q1 | 20min | COMPRA | 4,612 | 2,476 | 2.33 | nao | 1.77 | 1 | 330.60 | 220.86 | 220.86 | 1.79 | -54.97 | 2.33 | 51.78 | 2/2 | 11/15 | 430.02 | 11.70 | 109.74 |
| mtf_W1=BEARISH & news_min_since_last_high=Q2 | 5min | COMPRA | 255 | 416 | 2.34 | nao | 1.85 | 1 | 269.11 | 191.54 | 191.54 | 1.71 | -95.76 | 2.58 | 50.96 | 2/2 | 2/2 | 188.65 | 194.42 | 77.57 |
| slot_hhmm=09:10 & mtf_D1=BULLISH | 5min | COMPRA | 128 | 70 | 2.26 | nao | 2.81 | 1 | 441.43 | 321.43 | 321.43 | 1.70 | -95.76 | 2.18 | 55.71 | 2/2 | 11/15 | 90.00 | 552.86 | 120.00 |

### M15 — modo `open`

- eventos: 64,600 (2024-01-22 a 2026-10-16); descoberta 38,668 (até 2025-09-10), validação 25,840 (a partir de 2025-09-11)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 77,642**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 4.0%, top 1000: 4.7%, top 10000: 4.2%
- **placebo** (6 deslocamentos): top 100: 5.8% (máx 15.0%), top 1000: 4.9% (máx 6.7%), top 10000: 4.2% (máx 5.3%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 38,655 | 0.004 | 0.947 | 13.228 |
| 20min bruto | 38,655 | 0.005 | 0.996 | 20.135 |
| 30min bruto | 38,521 | 0.007 | 0.843 | 25.393 |
| 45min bruto | 38,015 | 0.009 | 0.723 | 34.297 |
| 75min bruto | 37,033 | 0.013 | 0.596 | 50.556 |
| 135min bruto | 35,132 | 0.018 | 0.401 | 68.779 |
| 255min bruto | 31,395 | 0.019 | 0.184 | 71.244 |

**M15/open: famílias distintas validadas: 76; com líquido positivo e significativo na validação (custo realista): 35.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=RANGE & month=6 | 255min | COMPRA | 507 | 77 | 2.21 | nao | 1.68 | 1 | 18,794.29 | 18,683.23 | 18,683.23 | 7.27 | 330.44 | 7.12 | 77.92 | 3/3 | 3/3 | 18,287.89 | 19,068.44 | 111.05 |
| mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 75min | COMPRA | 170 | 119 | 2.13 | nao | 2.82 | 1 | 2,426.47 | 2,306.47 | 2,306.47 | 5.76 | -5.81 | 5.72 | 66.39 | 3/3 | 9/10 | 2,958.81 | 1,665.00 | 120.00 |
| day_of_week=MONDAY & session=OFF_SESSION | 75min | VENDA | 557 | 366 | -2.29 | nao | -2.58 | 1 | 1,349.54 | 1,229.54 | 1,229.40 | 5.01 | -204.85 | 5.75 | 62.84 | 3/3 | 26/34 | 1,042.84 | 1,415.96 | 120.14 |
| day_of_week=MONDAY & session=OFF_SESSION | 45min | VENDA | 568 | 373 | -2.59 | nao | -3.20 | 1 | 931.88 | 811.61 | 811.47 | 4.88 | -156.29 | 5.69 | 59.79 | 2/3 | 26/34 | 772.31 | 850.43 | 120.40 |
| day_of_week=MONDAY & session=OFF_SESSION | 30min | VENDA | 577 | 378 | -2.78 | nao | -3.02 | 1 | 586.24 | 465.85 | 465.71 | 3.54 | -135.18 | 4.45 | 56.61 | 2/3 | 22/34 | 456.83 | 474.60 | 120.53 |
| day_of_week=MONDAY & session=OFF_SESSION | 20min | VENDA | 589 | 381 | -2.89 | nao | -3.49 | 1 | 517.93 | 397.53 | 397.40 | 3.36 | -139.74 | 4.45 | 55.64 | 3/3 | 22/34 | 365.11 | 429.53 | 120.52 |
| day_of_week=THURSDAY & news_state=EVENTS_4_AROUND_60M | 45min | VENDA | 192 | 100 | -2.39 | nao | -1.65 | 1 | 3,684.80 | 3,572.58 | 3,579.75 | 2.87 | -156.29 | 2.99 | 53.00 | 3/3 | 16/23 | 5,992.98 | 1,166.52 | 105.05 |
| mtf_W1=RANGE & news_min_to_next_high=Q3 | 75min | COMPRA | 977 | 641 | 2.36 | nao | 1.89 | 1 | 642.12 | 522.12 | 522.12 | 2.84 | -5.81 | 2.80 | 56.16 | 3/3 | 11/15 | -192.19 | 1,234.21 | 120.00 |
| day_of_week=THURSDAY & news_state=EVENTS_4_AROUND_60M | 20min | VENDA | 192 | 100 | -2.36 | nao | -2.10 | 1 | 2,000.00 | 1,887.78 | 1,891.91 | 2.67 | -139.74 | 2.86 | 51.00 | 3/3 | 15/23 | 2,528.56 | 1,255.26 | 108.09 |
| day_of_week=MONDAY & hour=22 | 45min | VENDA | 232 | 149 | -2.24 | nao | -1.81 | 1 | 838.72 | 718.72 | 718.72 | 2.62 | -156.29 | 3.16 | 57.05 | 2/3 | 20/24 | 750.54 | 687.33 | 120.00 |
| day_of_week=THURSDAY & news_state=EVENTS_4_AROUND_60M | 30min | VENDA | 192 | 100 | -2.41 | nao | -1.78 | 1 | 2,408.30 | 2,296.08 | 2,300.75 | 2.54 | -135.18 | 2.68 | 54.00 | 3/3 | 16/23 | 3,516.38 | 1,085.13 | 107.55 |
| mtf_H4=RANGE & mtf_W1=BEARISH | 20min | COMPRA | 887 | 187 | 2.13 | nao | 2.58 | 1 | 828.66 | 719.78 | 719.78 | 2.48 | -70.10 | 2.71 | 59.89 | 3/3 | 5/5 | 469.02 | 967.86 | 108.89 |
| hour=2 & pcum3=Q5 | 20min | VENDA | 308 | 172 | -2.14 | nao | -2.31 | 1 | 535.76 | 415.47 | 415.47 | 2.46 | -139.74 | 3.25 | 51.16 | 2/3 | 21/33 | 520.81 | 310.12 | 120.29 |
| mtf_D1=RANGE & mtf_W1=RANGE | 135min | COMPRA | 663 | 585 | 2.31 | nao | 1.78 | 1 | 1,470.07 | 1,362.31 | 1,362.31 | 2.41 | 106.92 | 2.25 | 60.34 | 3/3 | 5/5 | 3,504.92 | -772.99 | 107.76 |
| slot_hhmm=14:15 & mtf_H1=RANGE | 20min | COMPRA | 133 | 81 | 2.36 | nao | 1.85 | 1 | 2,549.75 | 2,461.82 | 2,461.82 | 2.40 | -70.10 | 2.46 | 58.02 | 3/3 | 20/27 | 3,803.98 | 1,152.39 | 87.93 |
| mtf_H1=RANGE & mtf_H4=BULLISH | 45min | COMPRA | 3,629 | 1,974 | 2.30 | nao | 2.21 | 1 | 492.26 | 386.52 | 386.52 | 2.39 | -53.85 | 2.83 | 50.76 | 3/3 | 19/34 | 351.14 | 421.90 | 105.74 |
| mtf_W1=RANGE & news_min_to_next_high=Q3 | 45min | COMPRA | 986 | 643 | 2.16 | nao | 2.08 | 1 | 419.44 | 299.44 | 299.44 | 2.24 | -53.85 | 2.56 | 53.50 | 3/3 | 10/15 | -204.74 | 802.05 | 120.00 |
| mtf_M1=RANGE & mtf_H4=RANGE | 20min | COMPRA | 1,669 | 1,529 | 2.10 | nao | 1.95 | 1 | 367.40 | 262.54 | 262.54 | 2.18 | -70.10 | 2.84 | 52.19 | 3/3 | 20/34 | 197.24 | 327.76 | 104.86 |
| day_of_week=MONDAY & mtf_W1=BEARISH | 20min | COMPRA | 903 | 184 | 2.20 | nao | 2.29 | 1 | 825.16 | 720.80 | 720.80 | 2.18 | -70.10 | 2.39 | 61.41 | 3/3 | 4/5 | 363.69 | 1,077.92 | 104.36 |
| day_of_week=MONDAY & hour=22 | 30min | VENDA | 238 | 152 | -2.51 | nao | -1.95 | 1 | 620.26 | 500.26 | 500.26 | 2.17 | -135.18 | 2.73 | 55.92 | 3/3 | 17/24 | 484.87 | 515.66 | 120.00 |
| day_of_week=MONDAY & mtf_D1=BREAK_DOWN | 20min | COMPRA | 452 | 252 | 2.26 | nao | 2.74 | 1 | 1,110.56 | 1,007.69 | 1,007.69 | 2.16 | -70.10 | 2.32 | 57.14 | 2/3 | 7/9 | 711.18 | 1,304.19 | 102.87 |
| day_of_week=TUESDAY & news_min_since_last_high=Q2 | 20min | COMPRA | 855 | 566 | 2.15 | nao | 2.41 | 1 | 489.33 | 410.25 | 410.25 | 2.13 | -70.10 | 2.51 | 54.06 | 2/3 | 22/34 | 271.77 | 548.73 | 79.08 |
| day_of_week=MONDAY & hour=22 | 20min | VENDA | 245 | 153 | -2.19 | nao | -2.03 | 1 | 541.24 | 421.24 | 421.24 | 2.02 | -139.74 | 2.66 | 52.29 | 2/3 | 14/24 | 328.95 | 512.34 | 120.00 |
| hour=16 & pcum3=Q5 | 20min | COMPRA | 349 | 210 | 2.14 | nao | 1.98 | 1 | 854.95 | 784.10 | 784.10 | 1.99 | -70.10 | 2.17 | 58.10 | 3/3 | 21/34 | 1,265.14 | 303.05 | 70.86 |
| day_of_week=THURSDAY & news_state=EVENTS_4_AROUND_60M | 15min | VENDA | 192 | 100 | -2.36 | nao | -1.76 | 1 | 1,192.80 | 1,080.58 | 1,082.76 | 1.95 | -118.47 | 2.16 | 52.00 | 3/3 | 16/23 | 1,483.78 | 681.73 | 110.04 |

### M30 — modo `open`

- eventos: 32,298 (2024-01-22 a 2026-10-16); descoberta 19,332 (até 2025-09-11), validação 12,920 (a partir de 2025-09-12)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 61,589**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 6.0%, top 1000: 5.8%, top 10000: 4.2%
- **placebo** (6 deslocamentos): top 100: 5.3% (máx 9.0%), top 1000: 4.8% (máx 7.2%), top 10000: 3.7% (máx 5.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 19,319 | 0.003 | 0.597 | 18.581 |
| 35min bruto | 19,319 | 0.007 | 1.039 | 41.422 |
| 45min bruto | 19,286 | 0.010 | 1.161 | 59.360 |
| 60min bruto | 19,177 | 0.007 | 0.556 | 37.643 |
| 90min bruto | 18,683 | 0.008 | 0.408 | 44.216 |
| 150min bruto | 17,731 | 0.007 | 0.210 | 42.452 |
| 270min bruto | 15,862 | 0.006 | 0.077 | 34.597 |

**M30/open: famílias distintas validadas: 70; com líquido positivo e significativo na validação (custo realista): 31.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=MONDAY & session=OFF_SESSION | 60min | VENDA | 285 | 187 | -2.68 | nao | -3.26 | 1 | 1,212.03 | 1,092.03 | 1,091.76 | 4.19 | -168.06 | 4.71 | 64.71 | 2/3 | 27/33 | 984.52 | 1,197.87 | 120.27 |
| day_of_week=MONDAY & session=OFF_SESSION | 90min | VENDA | 280 | 184 | -2.36 | nao | -2.54 | 1 | 1,581.03 | 1,461.03 | 1,461.03 | 3.90 | -211.64 | 4.39 | 60.87 | 3/3 | 27/33 | 1,196.41 | 1,725.65 | 120.00 |
| day_of_week=MONDAY & session=OFF_SESSION | 45min | VENDA | 290 | 190 | -3.55 | nao | -3.22 | 1 | 1,041.47 | 921.21 | 920.95 | 3.84 | -149.93 | 4.36 | 56.84 | 2/3 | 25/33 | 969.68 | 872.21 | 120.53 |
| day_of_week=MONDAY & session=OFF_SESSION | 35min | VENDA | 295 | 192 | -3.57 | nao | -3.02 | 1 | 821.25 | 700.99 | 700.73 | 3.17 | -152.65 | 3.77 | 60.42 | 3/3 | 24/33 | 734.37 | 667.08 | 120.52 |
| day_of_week=MONDAY & hour=23 | 45min | VENDA | 169 | 113 | -2.50 | nao | -2.44 | 1 | 1,020.09 | 899.65 | 899.20 | 3.12 | -149.93 | 3.56 | 59.29 | 3/3 | 20/32 | 1,035.36 | 765.44 | 120.88 |
| mtf_M15=BULLISH & atr_ratio_prev=Q2 | 45min | COMPRA | 1,400 | 1,050 | 2.17 | nao | 2.45 | 1 | 572.87 | 453.73 | 453.73 | 2.60 | -59.86 | 2.97 | 53.43 | 3/3 | 20/34 | 195.31 | 712.15 | 119.13 |
| day_of_week=MONDAY & hour=23 | 35min | VENDA | 172 | 114 | -2.71 | nao | -2.17 | 1 | 757.63 | 637.19 | 636.75 | 2.44 | -152.65 | 2.96 | 63.16 | 3/3 | 22/32 | 857.19 | 416.32 | 120.88 |
| day_of_week=MONDAY & mtf_D1=BREAK_DOWN | 35min | COMPRA | 226 | 126 | 2.34 | nao | 2.81 | 1 | 2,194.92 | 2,091.59 | 2,091.59 | 2.37 | -57.18 | 2.44 | 62.70 | 2/3 | 6/7 | 1,901.27 | 2,281.90 | 103.33 |
| day_of_week=MONDAY & hour=22 | 45min | VENDA | 121 | 77 | -2.58 | nao | -2.11 | 1 | 1,072.86 | 952.86 | 952.86 | 2.30 | -149.93 | 2.63 | 53.25 | 2/3 | 15/23 | 966.05 | 940.00 | 120.00 |
| month=11 & atr_ratio_prev=Q5 | 90min | COMPRA | 150 | 144 | 2.65 | nao | 1.70 | 1 | 2,539.24 | 2,452.57 | 2,452.57 | 2.29 | 0.78 | 2.30 | 65.28 | 2/2 | 2/2 | 2,575.83 | 2,329.30 | 86.67 |
| mtf_D1=RANGE & month=6 | 45min | COMPRA | 306 | 46 | 2.76 | nao | 1.78 | 1 | 3,888.26 | 3,783.48 | 3,783.48 | 2.27 | -59.86 | 2.28 | 67.39 | 3/3 | 3/3 | 3,221.30 | 4,345.65 | 104.78 |
| day_of_week=MONDAY & mtf_W1=BEARISH | 35min | COMPRA | 451 | 92 | 2.00 | nao | 1.95 | 1 | 1,473.91 | 1,369.13 | 1,369.13 | 2.26 | -57.18 | 2.35 | 64.13 | 3/3 | 4/5 | 1,015.00 | 1,723.26 | 104.78 |
| mtf_H1=RANGE & mtf_H4=BULLISH | 60min | COMPRA | 1,830 | 994 | 2.31 | nao | 2.05 | 1 | 687.47 | 581.42 | 581.42 | 2.22 | -42.10 | 2.48 | 51.81 | 3/3 | 19/34 | 519.79 | 643.06 | 106.05 |
| mtf_H4=RANGE & mtf_W1=BEARISH | 35min | COMPRA | 444 | 94 | 2.10 | nao | 1.94 | 1 | 1,311.49 | 1,202.13 | 1,202.13 | 2.21 | -57.18 | 2.31 | 64.89 | 3/3 | 5/5 | 809.57 | 1,594.68 | 109.36 |
| mtf_M1=BREAK_DOWN & mtf_D1=RANGE | 45min | COMPRA | 240 | 124 | 2.77 | nao | 1.67 | 1 | 2,116.77 | 2,016.53 | 2,016.53 | 2.15 | -59.86 | 2.22 | 58.06 | 3/3 | 18/25 | 2,483.06 | 1,550.00 | 100.24 |
| mtf_W1=RANGE & news_min_to_next_high=Q3 | 90min | COMPRA | 504 | 334 | 2.12 | nao | 1.65 | 1 | 718.41 | 598.41 | 598.41 | 2.10 | 0.78 | 2.04 | 55.99 | 3/3 | 11/15 | -85.57 | 1,282.40 | 120.00 |
| slot_hhmm=23:30 & mtf_H1=BULLISH | 35min | VENDA | 162 | 115 | -2.28 | nao | -2.31 | 1 | 682.96 | 562.52 | 562.52 | 2.09 | -152.65 | 2.60 | 58.26 | 3/3 | 20/33 | 812.81 | 316.55 | 120.43 |
| day_of_week=MONDAY & hour=22 | 35min | VENDA | 123 | 78 | -2.33 | nao | -2.11 | 1 | 914.23 | 794.23 | 794.23 | 2.04 | -152.65 | 2.41 | 56.41 | 2/3 | 14/23 | 683.08 | 905.38 | 120.00 |
| day_of_week=MONDAY & session=OFF_SESSION | 30min | VENDA | 295 | 192 | -3.17 | nao | -2.52 | 1 | 494.84 | 374.58 | 374.32 | 1.98 | -132.04 | 2.62 | 59.38 | 3/3 | 22/33 | 302.08 | 446.56 | 120.52 |
| p2=Q1 & pcum3=Q4 | 30min | COMPRA | 321 | 184 | 2.53 | nao | 2.16 | 1 | 1,045.16 | 942.43 | 942.43 | 1.95 | -78.59 | 2.13 | 54.89 | 3/3 | 26/34 | 1,074.00 | 810.87 | 102.73 |
| mtf_H1=RANGE & month=2 | 45min | COMPRA | 387 | 208 | 2.39 | nao | 2.27 | 1 | 1,232.50 | 1,124.90 | 1,124.90 | 1.94 | -59.86 | 2.06 | 53.85 | 3/3 | 3/3 | 1,020.56 | 1,229.23 | 107.60 |
| hour=20 & p2=Q4 | 30min | VENDA | 191 | 104 | -2.75 | nao | -1.75 | 1 | 931.63 | 861.35 | 858.30 | 1.93 | -132.04 | 2.22 | 54.81 | 3/3 | 20/30 | 1,968.65 | -252.05 | 73.33 |
| mtf_M1=RANGE & mtf_H4=RANGE | 30min | COMPRA | 811 | 766 | 2.41 | nao | 2.12 | 1 | 476.51 | 372.36 | 372.36 | 1.90 | -78.59 | 2.36 | 51.83 | 3/3 | 23/34 | 307.18 | 437.54 | 104.15 |
| mtf_M1=RANGE & mtf_H4=RANGE | 35min | COMPRA | 811 | 766 | 2.51 | nao | 1.66 | 1 | 534.15 | 430.00 | 430.00 | 1.87 | -57.18 | 2.18 | 55.74 | 3/3 | 21/34 | 563.18 | 296.81 | 104.15 |
| mtf_H4=BEARISH & news_min_since_last_high=Q5 | 60min | COMPRA | 808 | 482 | 2.29 | nao | 1.77 | 1 | 984.32 | 868.34 | 868.34 | 1.86 | -42.10 | 2.00 | 55.19 | 3/3 | 25/34 | 1,411.65 | 325.02 | 115.98 |

### H1 — modo `open`

- eventos: 32,283 (2021-04-27 a 2026-10-16); descoberta 19,346 (até 2024-08-07), validação 12,914 (a partir de 2024-08-08)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 61,399**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 22.0%, top 1000: 8.3%, top 10000: 3.9%
- **placebo** (6 deslocamentos): top 100: 5.7% (máx 20.0%), top 1000: 4.3% (máx 7.3%), top 10000: 3.9% (máx 4.7%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 19,333 | 0.003 | 0.486 | 22.426 |
| 65min bruto | 19,333 | -0.004 | -0.702 | -36.103 |
| 75min bruto | 19,298 | -0.006 | -0.881 | -51.818 |
| 90min bruto | 19,153 | -0.003 | -0.305 | -21.538 |
| 120min bruto | 19,008 | 0.006 | 0.495 | 50.953 |
| 180min bruto | 18,009 | 0.009 | 0.414 | 70.297 |
| 300min bruto | 16,095 | 0.020 | 0.496 | 159.611 |

**H1/open: famílias distintas validadas: 87; com líquido positivo e significativo na validação (custo realista): 50.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=TUESDAY & month=9 | 300min | VENDA | 226 | 266 | -2.83 | nao | -2.26 | 1 | 4,461.99 | 4,350.26 | 4,361.66 | 5.06 | -615.14 | 5.77 | 59.77 | 6/6 | 6/6 | 3,656.01 | 5,067.32 | 100.33 |
| mtf_H4=BULLISH & month=2 | 300min | VENDA | 336 | 229 | -2.00 | nao | -1.78 | 1 | 5,172.47 | 5,051.95 | 5,072.99 | 4.37 | -615.14 | 4.93 | 55.02 | 5/5 | 5/5 | 3,190.23 | 6,939.39 | 99.48 |
| day_of_week=TUESDAY & month=9 | 180min | VENDA | 255 | 296 | -2.92 | nao | -1.93 | 1 | 2,438.81 | 2,330.98 | 2,336.83 | 3.38 | -408.30 | 3.98 | 56.42 | 6/6 | 6/6 | 1,914.05 | 2,759.61 | 101.98 |
| mtf_W1=RANGE & news_min_to_next_high=Q3 | 75min | COMPRA | 158 | 299 | 2.50 | nao | 3.65 | 1 | 879.93 | 758.19 | 758.19 | 3.05 | 43.66 | 2.77 | 58.86 | 4/4 | 12/18 | 780.54 | 736.00 | 121.74 |
| mtf_D1=BREAK_UP & mtf_W1=BREAK_UP | 65min | VENDA | 435 | 387 | -2.06 | nao | -2.31 | 1 | 1,025.77 | 918.04 | 922.13 | 2.83 | -227.43 | 3.52 | 54.01 | 5/6 | 16/18 | 591.86 | 1,250.70 | 103.64 |
| hour=20 & streak_prev=-1 | 120min | COMPRA | 190 | 130 | 2.29 | nao | 1.72 | 2 | 2,116.75 | 2,045.90 | 2,045.90 | 2.53 | 83.68 | 2.42 | 57.69 | 6/6 | 25/30 | 1,133.03 | 2,958.77 | 70.85 |
| day_of_week=TUESDAY & month=9 | 120min | VENDA | 270 | 313 | -2.95 | nao | -1.75 | 1 | 1,494.26 | 1,388.32 | 1,391.30 | 2.52 | -295.68 | 3.07 | 55.27 | 6/6 | 6/6 | 1,099.51 | 1,681.23 | 102.96 |
| mtf_W1=RANGE & news_min_to_next_high=Q3 | 65min | COMPRA | 158 | 299 | 2.42 | nao | 3.13 | 1 | 669.60 | 547.86 | 547.86 | 2.43 | 15.39 | 2.26 | 57.19 | 4/4 | 14/18 | 474.23 | 621.00 | 121.74 |
| hour=20 & streak_prev=-1 | 90min | COMPRA | 205 | 140 | 2.80 | nao | 1.93 | 2 | 1,902.84 | 1,832.05 | 1,832.05 | 2.42 | 32.22 | 2.37 | 57.86 | 6/6 | 28/37 | 1,035.10 | 2,629.00 | 70.79 |
| mtf_W1=RANGE & news_min_to_next_high=Q3 | 90min | COMPRA | 157 | 299 | 2.34 | nao | 2.59 | 1 | 799.13 | 677.39 | 677.39 | 2.39 | 32.22 | 2.21 | 57.19 | 4/4 | 13/18 | 592.89 | 761.33 | 121.74 |
| mtf_M15=BULLISH & news_min_to_next_high=Q3 | 60min | COMPRA | 234 | 563 | 2.51 | nao | 2.24 | 1 | 478.13 | 353.66 | 353.66 | 2.37 | -17.25 | 2.30 | 52.04 | 3/4 | 27/37 | 429.28 | 278.30 | 124.48 |
| slot_hhmm=20:00 & dom_w=d22_31 | 75min | COMPRA | 250 | 163 | 2.01 | nao | 1.94 | 2 | 1,874.44 | 1,803.71 | 1,803.71 | 2.32 | 43.66 | 2.27 | 55.21 | 5/6 | 41/62 | 1,217.33 | 2,382.93 | 70.74 |
| mtf_M5=RANGE & news_min_to_next_high=Q1 | 90min | COMPRA | 151 | 358 | 2.86 | nao | 2.10 | 1 | 2,381.86 | 2,279.78 | 2,279.78 | 2.31 | 32.22 | 2.33 | 55.03 | 4/4 | 24/37 | 2,704.15 | 1,855.41 | 102.07 |
| mtf_M5=RANGE & month=7 | 65min | COMPRA | 404 | 233 | 2.16 | nao | 2.24 | 1 | 1,129.40 | 1,023.78 | 1,023.78 | 2.24 | 15.39 | 2.21 | 54.51 | 6/6 | 6/6 | 175.08 | 1,865.21 | 105.62 |
| hour=23 & p2=Q1 | 75min | VENDA | 121 | 97 | -2.21 | nao | -2.58 | 2 | 1,473.09 | 1,351.65 | 1,352.06 | 2.24 | -255.69 | 2.64 | 54.64 | 5/6 | 14/17 | 1,571.88 | 1,136.73 | 121.03 |
| mtf_D1=BULLISH & dom_w=d22_31 | 90min | COMPRA | 2,210 | 1,869 | 2.05 | nao | 1.83 | 1 | 529.29 | 420.95 | 420.95 | 2.22 | 32.22 | 2.10 | 54.25 | 5/6 | 31/41 | 690.29 | 151.89 | 108.34 |
| mtf_M5=RANGE & news_min_to_next_high=Q1 | 75min | COMPRA | 151 | 358 | 2.77 | nao | 2.20 | 1 | 1,733.39 | 1,631.32 | 1,631.32 | 2.21 | 43.66 | 2.19 | 55.59 | 4/4 | 26/37 | 1,423.26 | 1,839.38 | 102.07 |
| hour=20 & streak_prev=-1 | 75min | COMPRA | 211 | 141 | 2.86 | nao | 1.86 | 2 | 1,726.68 | 1,655.90 | 1,655.90 | 2.20 | 43.66 | 2.14 | 55.32 | 6/6 | 27/39 | 615.17 | 2,681.97 | 70.78 |
| mtf_M5=RANGE & news_min_to_next_high=Q1 | 120min | COMPRA | 150 | 358 | 2.97 | nao | 1.69 | 1 | 2,710.68 | 2,608.61 | 2,608.61 | 2.17 | 83.68 | 2.15 | 52.51 | 4/4 | 26/37 | 2,936.17 | 2,281.06 | 102.07 |
| slot_hhmm=23:00 & structure_before=BULLISH | 65min | VENDA | 351 | 213 | -3.99 | nao | -2.92 | 4 | 729.25 | 602.01 | 609.01 | 2.17 | -227.43 | 2.90 | 58.69 | 6/6 | 41/65 | 684.06 | 534.67 | 120.23 |
| mtf_M5=RANGE & news_min_to_next_high=Q1 | 65min | COMPRA | 151 | 358 | 2.83 | nao | 2.46 | 1 | 1,722.71 | 1,620.64 | 1,620.64 | 2.14 | 15.39 | 2.17 | 55.31 | 4/4 | 23/37 | 1,350.44 | 1,890.83 | 102.07 |
| mtf_M5=RANGE & mtf_M30=RANGE | 65min | COMPRA | 679 | 447 | 2.03 | nao | 2.22 | 1 | 1,188.50 | 1,081.38 | 1,081.38 | 2.14 | 15.39 | 2.15 | 52.57 | 5/6 | 42/67 | 1,593.75 | 571.29 | 107.12 |
| hour=23 & pcum10=Q5 | 75min | VENDA | 255 | 169 | -3.10 | nao | -2.00 | 2 | 727.99 | 606.20 | 607.69 | 2.08 | -255.69 | 2.86 | 54.44 | 6/6 | 35/54 | 558.10 | 656.71 | 120.30 |
| day_of_week=MONDAY & mtf_H4=RANGE | 75min | COMPRA | 845 | 627 | 2.98 | nao | 1.82 | 1 | 735.80 | 627.56 | 627.56 | 2.07 | 43.66 | 1.95 | 51.67 | 4/6 | 33/59 | 424.26 | 830.22 | 108.23 |
| slot_hhmm=00:00 & mtf_H4=RANGE | 90min | VENDA | 201 | 141 | -2.24 | nao | -1.87 | 2 | 1,121.10 | 995.63 | 1,000.74 | 2.06 | -244.23 | 2.54 | 53.90 | 6/6 | 31/43 | -67.64 | 2,054.08 | 120.35 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **280**
- com líquido positivo e t>1,645 na validação, custo realista: **139**; dessas, sobreviveram ao BH: **0**; e positivas nas duas metades da validação: **0**
- **Nenhuma família passa em todos os filtros (BH + validação + líquido positivo com custo realista + estabilidade nas duas metades).**

## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 125s)_
