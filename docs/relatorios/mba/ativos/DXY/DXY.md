# DXY — relatório completo MBA (gerado em 2026-10-17 02:06)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | Raw Trading Ltd |
| servidor | ICMarketsSC-Demo |
| simbolo | DXY_Z6 |
| descricao | US Dollar Index -December 26 CFD |
| digitos | 3 |
| ponto | 0.00100 |
| tick_size | 0.00100 |
| tick_value | 0.10000 |
| contrato | 100.00000 |
| lote_min | 1.00000 |
| swap_long | 0.00000 |
| swap_short | 0.00000 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-09-10 16:56 | 2026-10-16 23:58 | 362 | 788,049 | 0 | 35,485 | 35,485 | 1,541 |
| M5 | 94,349 | 2025-05-15 04:50 | 2026-10-16 23:50 | 383 | 657 | 0 | 7,106 | 7,106 | 311 |
| M15 | 46,126 | 2024-09-10 22:15 | 2026-10-16 23:30 | 547 | 343 | 0 | 2,369 | 2,369 | 104 |
| M30 | 23,061 | 2024-09-11 07:00 | 2026-10-16 23:00 | 544 | 171 | 0 | 1,185 | 1,185 | 53 |
| H1 | 11,529 | 2024-09-11 18:00 | 2026-10-16 22:00 | 541 | 85 | 0 | 593 | 593 | 27 |
| H4 | 3,218 | 2024-09-16 12:00 | 2026-10-16 16:00 | 114 | 21 | 0 | 165 | 165 | 8 |
| D1 | 519 | 2024-10-11 00:00 | 2026-10-15 00:00 | 109 | 3 | 0 | 27 | 27 | 2 |
| W1 | 86 | 2025-02-16 00:00 | 2026-10-04 00:00 | 0 | 0 | 0 | 5 | 5 | 1 |
| MN1 | 2 | 2026-08-01 00:00 | 2026-09-01 00:00 | 0 | 0 | 0 | 1 | 1 | 1 |

Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).

## 3. Custo e microestrutura (base M5)

Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.

| hora_utc | spread_med | spread_p90 | spread_max | range_med_pts | atr_med_pts | ticks_vol_med | n | spread_ticks_med | pct_barras_spread0 | custo_sobre_ATR |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 30.00 | 30.00 | 30.00 | 20.00 | 21.00 | 42.00 | 3,576 | 30.00 | 0.00 | 1.43 |
| 1 | 30.00 | 30.00 | 30.00 | 22.00 | 22.29 | 44.00 | 4,406 | 30.00 | 0.00 | 1.35 |
| 2 | 30.00 | 30.00 | 30.00 | 17.00 | 20.93 | 34.00 | 4,416 | 30.00 | 0.00 | 1.43 |
| 3 | 30.00 | 30.00 | 30.00 | 15.00 | 17.00 | 29.00 | 4,416 | 30.00 | 0.00 | 1.76 |
| 4 | 30.00 | 30.00 | 30.00 | 15.00 | 15.29 | 26.00 | 4,416 | 30.00 | 0.00 | 1.96 |
| 5 | 30.00 | 30.00 | 30.00 | 15.00 | 15.71 | 32.00 | 4,416 | 30.00 | 0.00 | 1.91 |
| 6 | 30.00 | 30.00 | 30.00 | 25.00 | 22.07 | 52.00 | 4,422 | 30.00 | 0.00 | 1.36 |
| 7 | 30.00 | 30.00 | 30.00 | 30.00 | 28.29 | 62.00 | 4,425 | 30.00 | 0.00 | 1.06 |
| 8 | 30.00 | 30.00 | 30.00 | 28.00 | 30.71 | 62.00 | 4,428 | 30.00 | 0.00 | 0.98 |
| 9 | 30.00 | 30.00 | 30.00 | 25.00 | 28.00 | 54.00 | 4,440 | 30.00 | 0.00 | 1.07 |
| 10 | 30.00 | 30.00 | 30.00 | 22.00 | 24.79 | 48.00 | 4,439 | 30.00 | 0.00 | 1.21 |
| 11 | 30.00 | 30.00 | 30.00 | 25.00 | 23.86 | 52.00 | 4,440 | 30.00 | 0.00 | 1.26 |
| 12 | 30.00 | 30.00 | 30.00 | 30.00 | 29.07 | 66.00 | 4,439 | 30.00 | 0.00 | 1.03 |
| 13 | 30.00 | 30.00 | 30.00 | 35.00 | 36.07 | 82.00 | 4,429 | 30.00 | 0.00 | 0.83 |
| 14 | 30.00 | 30.00 | 30.00 | 38.00 | 40.64 | 89.00 | 4,428 | 30.00 | 0.00 | 0.74 |
| 15 | 30.00 | 30.00 | 30.00 | 35.00 | 39.07 | 78.00 | 4,417 | 30.00 | 0.00 | 0.77 |
| 16 | 30.00 | 30.00 | 30.00 | 25.00 | 32.64 | 59.00 | 4,415 | 30.00 | 0.00 | 0.92 |
| 17 | 30.00 | 30.00 | 30.00 | 22.00 | 26.21 | 48.00 | 4,392 | 30.00 | 0.00 | 1.14 |
| 18 | 30.00 | 30.00 | 30.00 | 20.00 | 22.71 | 43.00 | 4,354 | 30.00 | 0.00 | 1.32 |
| 19 | 30.00 | 30.00 | 30.00 | 17.00 | 19.50 | 37.00 | 4,331 | 30.00 | 0.00 | 1.54 |
| 20 | 30.00 | 30.00 | 30.00 | 15.00 | 16.50 | 26.00 | 4,331 | 30.00 | 0.00 | 1.82 |
| 21 | 30.00 | 30.00 | 40.00 | 13.00 | 15.36 | 22.00 | 1,013 | 30.00 | 0.00 | 1.95 |
| 22 | 30.00 | 30.00 | 30.00 | 20.00 | 25.64 | 31.00 | 671 | 30.00 | 0.00 | 1.17 |
| 23 | 30.00 | 30.00 | 30.00 | 18.00 | 19.43 | 28.00 | 889 | 30.00 | 0.00 | 1.54 |

Spread geral (mediana M5): **30.0 pts**, p90 30.0, máx 40. ATR mediano M5: **24.6 pts**. Razão spread/ATR: **1.22**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 105 | 602.89 | -44.40 | 416.12 | 46.67 | -1.09 |
| ter | 105 | 553.11 | -32.00 | 372.84 | 50.48 | -0.88 |
| qua | 103 | 624.32 | 69.71 | 405.03 | 58.25 | 1.75 |
| qui | 103 | 632.62 | -35.92 | 461.47 | 55.34 | -0.79 |
| sex | 103 | 581.07 | -5.27 | 362.99 | 50.49 | -0.15 |

Autocorrelação do retorno diário (lags 1-5): +0.002, +0.010, -0.027, -0.072, +0.037 (banda ±0.088). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.094, +0.020, +0.101.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 401 | 0 | -0.083 | -2.974 | nao |
| 539 | 1 | 0.039 | 1.834 | nao |
| 539 | 2 | -0.003 | -0.145 | nao |
| 539 | 3 | 0.023 | 1.358 | nao |
| 539 | 4 | 0.002 | 0.128 | nao |
| 539 | 5 | 0.001 | 0.071 | nao |
| 540 | 6 | -0.036 | -1.211 | nao |
| 540 | 7 | 0.052 | 1.328 | nao |
| 540 | 8 | -0.071 | -1.999 | nao |
| 541 | 9 | 0.045 | 1.431 | nao |
| 540 | 10 | 0.024 | 0.850 | nao |
| 540 | 11 | 0.010 | 0.302 | nao |
| 540 | 12 | -0.003 | -0.055 | nao |
| 540 | 13 | -0.068 | -1.583 | nao |
| 539 | 14 | -0.021 | -0.531 | nao |
| 540 | 15 | 0.077 | 2.182 | nao |
| 539 | 16 | 0.051 | 1.840 | nao |
| 537 | 17 | -0.010 | -0.455 | nao |
| 538 | 18 | 0.025 | 0.887 | nao |
| 530 | 19 | 0.023 | 1.021 | nao |
| 529 | 20 | -0.017 | -0.892 | nao |
| 175 | 21 | -0.065 | -2.512 | nao |
| 75 | 22 | 0.120 | 1.837 | nao |
| 110 | 23 | 0.030 | 0.549 | nao |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,328 | 0 | -0.012 | -0.897 | nao |
| 2,287 | 1 | -0.003 | -0.222 | nao |
| 2,250 | 2 | 0.037 | 2.392 | nao |
| 2,248 | 3 | -0.003 | -0.234 | nao |
| 2,234 | 4 | -0.003 | -0.212 | nao |
| 182 | 6 | 0.068 | 1.602 | nao |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 919 | 1 | -0.022 | -0.931 | nao |
| 856 | 2 | -0.006 | -0.274 | nao |
| 923 | 3 | -0.017 | -0.765 | nao |
| 905 | 4 | -0.033 | -1.525 | nao |
| 919 | 5 | 0.009 | 0.421 | nao |
| 920 | 6 | 0.003 | 0.135 | nao |
| 980 | 7 | 0.036 | 1.567 | nao |
| 902 | 8 | -0.008 | -0.319 | nao |
| 1,225 | 9 | 0.009 | 0.447 | nao |
| 1,240 | 10 | 0.049 | 2.482 | nao |
| 870 | 11 | 0.002 | 0.088 | nao |
| 870 | 12 | 0.004 | 0.188 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 115 combinações testadas):

| dia(0=seg) | hora_utc | n | ret_medio_ATR | std | t |
|---|---|---|---|---|---|
| 0 | 0 | 109 | -0.238 | 0.597 | -4.158 |

Autocorrelação do retorno H1, lags 1-10: -0.009, -0.007, -0.010, +0.007, +0.024, -0.014, -0.002, +0.013, -0.002, +0.011 (banda ±0.019). |retorno|: +0.110, +0.062, +0.001, -0.112, +0.028 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 65 | -0.125 | -1.114 | 44.615 |
| barra < -2 ATR | 81 | 0.161 | 1.838 | 61.728 |
| barra > +1 ATR | 643 | -0.028 | -0.887 | 48.989 |
| barra < -1 ATR | 694 | -0.029 | -0.937 | 49.135 |
| gap (barra ausente antes) | 540 | 0.008 | 0.343 | 49.815 |

Distribuição do retorno H1 em ATR: média +0.0040, desvio 0.690, assimetria -0.03, curtose 6.7; barras |ret|>2 ATR: 1.27%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 30.0 pts, máxima 30.0 pts no slot NY 00:00; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | 93,895 | 196,863 | 0 | 0 | 0.0 | 0.0 | 0 | 20.0 | 2.8 |
| M15 | ret | 45,952 | 191,443 | 0 | 0 | 0.0 | 0.0 | 0 | 8.0 | 2.7 |
| M30 | ret | 22,984 | 164,218 | 0 | 0 | 0.0 | 0.0 | 0 | 11.0 | 3.7 |
| H1 | ret | 11,498 | 116,724 | 0 | 0 | 0.0 | 0.0 | 0 | 8.0 | 4.3 |
| M5 | hit | 93,895 | 586,110 | 0 | 0 | 0.0 | 0.0 | 0 | 2.0 | 0.2 |
| M15 | hit | 45,952 | 569,502 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.3 |
| M30 | hit | 22,984 | 486,186 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.5 |
| H1 | hit | 11,498 | 345,264 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.0 |


## 6.1 Modo `ret`

### M5 — modo `ret`

- eventos: 93,895 (2025-05-15 a 2026-10-16); descoberta 56,085 (até 2026-03-23), validação 37,558 (a partir de 2026-03-24)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 196,863**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 20.0%, top 1000: 8.4%, top 10000: 6.0%
- **placebo** (6 deslocamentos): top 100: 2.8% (máx 5.0%), top 1000: 3.4% (máx 4.6%), top 10000: 3.4% (máx 4.4%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 56,085 | -0.000 | -0.046 | -0.004 |
| 15min bruto | 55,324 | -0.000 | -0.002 | -0.001 |
| 30min bruto | 54,255 | 0.002 | 0.101 | 0.051 |
| 60min bruto | 52,280 | 0.006 | 0.130 | 0.136 |
| 120min bruto | 48,692 | 0.010 | 0.110 | 0.251 |
| 240min bruto | 42,148 | -0.002 | -0.007 | -0.038 |

**M5/ret: famílias distintas validadas: 148; com líquido positivo e significativo na validação (custo realista): 2.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 120min | VENDA | 223 | 111 | -2.23 | nao | -1.86 | 1 | 92.92 | 62.92 | 62.92 | 5.42 | -31.47 | 8.12 | 65.77 | 2/2 | 11/14 | 91.02 | 35.32 | 30.00 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 60min | VENDA | 223 | 111 | -2.58 | nao | -2.26 | 1 | 60.30 | 30.30 | 30.30 | 3.55 | -30.83 | 7.14 | 56.76 | 2/2 | 8/14 | 32.62 | 28.02 | 30.00 |

### M15 — modo `ret`

- eventos: 45,952 (2024-09-10 a 2026-10-16); descoberta 27,500 (até 2025-12-14), validação 18,381 (a partir de 2025-12-15)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 191,443**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 8.0%, top 1000: 7.0%, top 10000: 7.0%
- **placebo** (6 deslocamentos): top 100: 2.7% (máx 5.0%), top 1000: 4.0% (máx 5.3%), top 10000: 4.2% (máx 4.9%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 27,500 | 0.000 | 0.112 | 0.020 |
| 15min bruto | 27,383 | -0.000 | -0.078 | -0.020 |
| 30min bruto | 26,919 | -0.002 | -0.234 | -0.116 |
| 60min bruto | 26,052 | -0.006 | -0.307 | -0.310 |
| 120min bruto | 24,438 | -0.016 | -0.379 | -0.819 |
| 240min bruto | 21,400 | -0.030 | -0.308 | -1.496 |

**M15/ret: famílias distintas validadas: 265; com líquido positivo e significativo na validação (custo realista): 0.**

Nenhuma viável; melhores famílias validadas (líquido NEGATIVO ou insignificante):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| close_position=Q1 & swing_high_distance_atr=Q4 | 15min | COMPRA | 735 | 501 | 2.63 | nao | 3.73 | 1 | 4.29 | -25.71 | -25.71 | -17.75 | -29.80 | 2.84 | 13.17 | 0/3 | 0/26 | -25.59 | -25.82 | 30.00 |
| session=NEW_YORK & direction=BEARISH | 15min | COMPRA | 2,669 | 1,581 | 2.17 | nao | 3.63 | 1 | 3.50 | -26.50 | -26.50 | -21.27 | -29.80 | 2.82 | 13.79 | 0/3 | 0/26 | -25.81 | -27.19 | 30.00 |
| session=NEW_YORK & direction=BEARISH | 5min | COMPRA | 2,687 | 1,615 | 2.14 | nao | 3.42 | 1 | 2.76 | -27.24 | -27.24 | -28.71 | -30.12 | 3.26 | 7.18 | 0/3 | 0/26 | -26.71 | -27.77 | 30.00 |
| close_position=Q1 & previous_low_distance_atr=Q4 | 15min | COMPRA | 879 | 588 | 2.28 | nao | 3.23 | 1 | 4.43 | -25.57 | -25.57 | -19.19 | -29.80 | 3.19 | 14.97 | 0/3 | 0/26 | -25.81 | -25.34 | 30.00 |
| hour=15 & range_atr=Q1 | 5min | COMPRA | 241 | 160 | 2.35 | nao | 3.17 | 1 | 5.28 | -24.73 | -24.73 | -13.28 | -30.12 | 2.90 | 8.12 | 0/3 | 0/22 | -22.98 | -26.48 | 30.00 |
| close_position=Q1 & swing_high_distance_atr=Q4 | 5min | COMPRA | 741 | 510 | 2.42 | nao | 3.06 | 1 | 2.05 | -27.95 | -27.95 | -31.56 | -30.12 | 2.46 | 6.27 | 0/3 | 0/26 | -27.23 | -28.66 | 30.00 |
| news_min_to_next_high=Q5 & ret_bar_atr=Q2 | 15min | COMPRA | 812 | 499 | 2.27 | nao | 3.01 | 1 | 4.35 | -25.65 | -25.65 | -16.73 | -29.80 | 2.73 | 15.23 | 0/3 | 0/26 | -25.62 | -25.68 | 30.00 |
| upper_wick_pct=Q5 & lower_wick_pct=Q1 | 15min | COMPRA | 1,467 | 1,004 | 2.25 | nao | 2.88 | 1 | 3.27 | -26.73 | -26.73 | -24.90 | -29.80 | 2.91 | 13.65 | 0/3 | 0/26 | -25.94 | -27.52 | 30.00 |
| session=NEW_YORK & ret_bar_atr=Q2 | 15min | COMPRA | 1,294 | 760 | 2.74 | nao | 2.87 | 1 | 3.14 | -26.86 | -26.86 | -18.27 | -29.80 | 2.04 | 12.89 | 0/3 | 0/26 | -25.80 | -27.92 | 30.00 |
| swing_high_distance_atr=Q4 & p1=Q5 | 15min | COMPRA | 1,307 | 881 | 2.41 | nao | 2.83 | 1 | 2.77 | -27.23 | -27.23 | -23.35 | -29.80 | 2.24 | 15.66 | 0/3 | 0/26 | -27.94 | -26.53 | 30.00 |
| lower_wick_pct=Q1 & previous_low_distance_atr=Q4 | 15min | COMPRA | 1,180 | 834 | 2.89 | nao | 2.78 | 1 | 3.18 | -26.82 | -26.82 | -21.45 | -29.80 | 2.43 | 12.95 | 0/3 | 0/26 | -24.57 | -29.07 | 30.00 |
| direction=BEARISH & volume_ratio=Q1 | 15min | COMPRA | 2,604 | 1,710 | 2.00 | nao | 2.77 | 1 | 2.31 | -27.69 | -27.69 | -34.15 | -29.80 | 2.67 | 9.94 | 0/3 | 0/26 | -27.15 | -28.24 | 30.00 |
| session_high_distance_atr=Q1 & news_min_since_last_high=Q2 | 15min | COMPRA | 465 | 256 | 2.31 | nao | 2.76 | 1 | 11.54 | -18.46 | -18.46 | -4.36 | -29.80 | 2.70 | 19.92 | 0/3 | 3/26 | -17.51 | -19.41 | 30.00 |
| hour=15 & mtf_W1=BREAK_UP | 15min | COMPRA | 180 | 80 | 2.09 | nao | 2.67 | 1 | 8.14 | -21.86 | -21.86 | -6.00 | -29.80 | 2.17 | 26.25 | 0/3 | 0/6 | -26.10 | -17.62 | 30.00 |
| price_position_weekly_open=Q5 & swing_low_distance_atr=Q1 | 15min | COMPRA | 717 | 322 | 2.45 | nao | 2.67 | 1 | 9.27 | -20.73 | -20.73 | -6.71 | -29.80 | 2.97 | 18.63 | 0/3 | 2/20 | -12.07 | -29.39 | 30.00 |

### M30 — modo `ret`

- eventos: 22,984 (2024-09-11 a 2026-10-16); descoberta 13,751 (até 2025-12-14), validação 9,194 (a partir de 2025-12-15)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 164,218**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 11.0%, top 1000: 9.3%, top 10000: 8.6%
- **placebo** (6 deslocamentos): top 100: 3.7% (máx 8.0%), top 1000: 4.2% (máx 5.3%), top 10000: 4.3% (máx 5.3%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 13,751 | -0.004 | -1.072 | -0.313 |
| 15min bruto | 13,683 | -0.007 | -1.242 | -0.486 |
| 30min bruto | 13,608 | 0.001 | 0.085 | 0.043 |
| 60min bruto | 13,170 | 0.001 | 0.081 | 0.083 |
| 120min bruto | 12,363 | 0.002 | 0.053 | 0.115 |
| 240min bruto | 10,837 | 0.002 | 0.024 | 0.119 |

**M30/ret: famílias distintas validadas: 468; com líquido positivo e significativo na validação (custo realista): 1.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=10 & cost_atr=Q5 | 240min | COMPRA | 626 | 137 | 2.04 | nao | 2.46 | 1 | 109.09 | 79.09 | 79.09 | 4.96 | -28.02 | 6.78 | 68.61 | 2/3 | 2/3 | 88.06 | 70.25 | 30.00 |

### H1 — modo `ret`

- eventos: 11,498 (2024-09-11 a 2026-10-16); descoberta 6,877 (até 2025-12-15), validação 4,600 (a partir de 2025-12-16)
- variáveis: 65; séries por variável/par: 6
- **hipóteses testadas: 116,724**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 8.0%, top 1000: 7.6%, top 10000: 6.9%
- **placebo** (6 deslocamentos): top 100: 4.3% (máx 7.0%), top 1000: 3.9% (máx 4.8%), top 10000: 4.5% (máx 5.1%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 6,877 | -0.003 | -0.804 | -0.350 |
| 15min bruto | 6,847 | -0.010 | -1.777 | -1.056 |
| 30min bruto | 6,800 | -0.010 | -1.444 | -1.115 |
| 60min bruto | 6,732 | 0.004 | 0.421 | 0.452 |
| 120min bruto | 6,323 | 0.006 | 0.281 | 0.630 |
| 240min bruto | 5,549 | 0.006 | 0.128 | 0.637 |

**H1/ret: famílias distintas validadas: 347; com líquido positivo e significativo na validação (custo realista): 0.**

Nenhuma viável; melhores famílias validadas (líquido NEGATIVO ou insignificante):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| swing_low_distance_atr=Q4 & range_atr_prev=Q5 | 60min | COMPRA | 253 | 200 | 2.01 | nao | 4.06 | 1 | 16.63 | -13.37 | -13.37 | -2.61 | -29.19 | 3.14 | 37.00 | 0/3 | 7/26 | -13.00 | -13.74 | 30.00 |
| close_position=Q1 & news_min_since_last_high=Q2 | 5min | COMPRA | 160 | 113 | 3.22 | nao | 3.78 | 1 | 15.39 | -14.61 | -14.61 | -2.88 | -30.35 | 3.15 | 18.58 | 0/3 | 5/24 | -8.11 | -21.00 | 30.00 |
| swing_high_distance_atr=Q4 & atr_ratio=Q1 | 60min | COMPRA | 300 | 183 | 2.19 | nao | 3.68 | 1 | 16.27 | -13.73 | -13.73 | -3.27 | -29.19 | 3.69 | 34.43 | 0/3 | 1/22 | -9.71 | -17.70 | 30.00 |
| dom_w=d01_07 & news_min_since_last_high=Q1 | 30min | COMPRA | 223 | 139 | 2.39 | nao | 3.59 | 1 | 15.40 | -14.60 | -14.60 | -3.26 | -29.88 | 3.44 | 33.81 | 1/3 | 5/25 | -13.96 | -15.24 | 30.00 |
| news_state=NONE_60M & body_pct=Q2 | 60min | COMPRA | 1,020 | 618 | 2.06 | nao | 3.41 | 1 | 8.51 | -21.49 | -21.49 | -7.90 | -29.19 | 2.98 | 30.26 | 0/3 | 0/26 | -22.84 | -20.14 | 30.00 |
| swing_low_distance_atr=Q2 & pat_INSIDE_BAR=Y | 60min | COMPRA | 145 | 107 | 2.33 | nao | 3.34 | 1 | 17.89 | -12.11 | -12.11 | -2.05 | -29.19 | 2.89 | 41.12 | 0/3 | 7/26 | -14.42 | -9.85 | 30.00 |
| day_of_week=WEDNESDAY & body_pct=Q2 | 60min | COMPRA | 262 | 172 | 2.78 | nao | 3.33 | 1 | 23.05 | -6.95 | -6.95 | -1.01 | -29.19 | 3.31 | 36.05 | 0/3 | 7/26 | -8.15 | -5.74 | 30.00 |
| prev_day_low_distance_atr=Q3 & cost_atr=Q5 | 60min | COMPRA | 310 | 324 | 2.55 | nao | 3.26 | 1 | 12.11 | -17.89 | -17.89 | -4.58 | -29.19 | 2.98 | 35.80 | 0/3 | 3/21 | -18.18 | -17.59 | 30.00 |
| body_pct=Q2 & cum10=Q3 | 60min | COMPRA | 288 | 151 | 2.12 | nao | 3.18 | 1 | 14.16 | -15.84 | -15.84 | -3.22 | -29.19 | 2.72 | 34.44 | 0/3 | 4/26 | -13.92 | -17.74 | 30.00 |
| prev_day_low_distance_atr=Q2 & session_high_distance_atr=Q5 | 30min | COMPRA | 155 | 112 | 2.16 | nao | 3.14 | 1 | 14.49 | -15.51 | -15.51 | -3.22 | -29.88 | 3.00 | 25.00 | 0/3 | 2/23 | -5.23 | -25.79 | 30.00 |
| session=LONDON_NY_OVERLAP & pat_INSIDE_BAR=Y | 60min | COMPRA | 199 | 112 | 2.39 | nao | 3.12 | 1 | 19.28 | -10.72 | -10.72 | -1.63 | -29.19 | 2.82 | 42.86 | 0/3 | 7/26 | -8.16 | -13.29 | 30.00 |
| structure_at_close=RANGE & month=12 | 60min | COMPRA | 142 | 53 | 3.10 | nao | 3.09 | 1 | 18.92 | -11.08 | -11.08 | -1.90 | -29.19 | 3.06 | 37.74 | 0/2 | 0/2 | -19.27 | -3.19 | 30.00 |
| structure_at_close=RANGE & month=12 | 30min | COMPRA | 147 | 54 | 2.04 | nao | 3.08 | 1 | 16.15 | -13.85 | -13.85 | -2.66 | -29.88 | 3.05 | 31.48 | 0/2 | 0/2 | -16.93 | -10.78 | 30.00 |
| upper_wick_pct=Q3 & prev_day_low_distance_atr=Q3 | 60min | COMPRA | 289 | 165 | 2.37 | nao | 3.08 | 1 | 16.59 | -13.41 | -13.41 | -2.47 | -29.19 | 2.95 | 36.36 | 0/3 | 4/26 | -9.39 | -17.37 | 30.00 |
| previous_high_distance_atr=Q4 & news_min_to_next_high=Q5 | 60min | COMPRA | 185 | 116 | 2.54 | nao | 3.03 | 1 | 12.60 | -17.40 | -17.40 | -3.15 | -29.19 | 2.14 | 37.93 | 0/3 | 4/25 | -10.05 | -24.74 | 30.00 |

## 6.2 Modo `hit`

### M5 — modo `hit`

- eventos: 93,895 (2025-05-15 a 2026-10-16); descoberta 56,085 (até 2026-03-23), validação 37,558 (a partir de 2026-03-24)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 586,110**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 2.0%, top 1000: 0.2%, top 10000: 0.0%
- **placebo** (6 deslocamentos): top 100: 0.2% (máx 1.0%), top 1000: 0.0% (máx 0.1%), top 10000: 0.0% (máx 0.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 55,311 | -1.240 |  | -30.651 |
| C alvo 0.5ATR/60min liquido | 52,267 | -1.206 |  | -29.813 |
| C alvo 0.5ATR/240min liquido | 42,135 | -1.159 |  | -28.636 |
| C alvo 1.0ATR/15min liquido | 55,311 | -1.225 |  | -30.277 |
| C alvo 1.0ATR/60min liquido | 52,267 | -1.195 |  | -29.538 |
| C alvo 1.0ATR/240min liquido | 42,135 | -1.144 |  | -28.267 |
| C alvo 2.0ATR/15min liquido | 55,311 | -1.213 |  | -29.969 |
| C alvo 2.0ATR/60min liquido | 52,267 | -1.181 |  | -29.184 |
| C alvo 2.0ATR/240min liquido | 42,135 | -1.099 |  | -27.167 |
| V alvo 0.5ATR/15min liquido | 55,311 | -1.248 |  | -30.849 |
| V alvo 0.5ATR/60min liquido | 52,267 | -1.231 |  | -30.434 |
| V alvo 0.5ATR/240min liquido | 42,135 | -1.208 |  | -29.867 |
| V alvo 1.0ATR/15min liquido | 55,311 | -1.239 |  | -30.627 |
| V alvo 1.0ATR/60min liquido | 52,267 | -1.234 |  | -30.506 |
| V alvo 1.0ATR/240min liquido | 42,135 | -1.214 |  | -29.996 |
| V alvo 2.0ATR/15min liquido | 55,311 | -1.223 |  | -30.225 |
| V alvo 2.0ATR/60min liquido | 52,267 | -1.219 |  | -30.116 |
| V alvo 2.0ATR/240min liquido | 42,135 | -1.221 |  | -30.177 |

**M5/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

### M15 — modo `hit`

- eventos: 45,952 (2024-09-10 a 2026-10-16); descoberta 27,500 (até 2025-12-14), validação 18,381 (a partir de 2025-12-15)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 569,502**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 0.0%, top 10000: 0.0%
- **placebo** (6 deslocamentos): top 100: 0.3% (máx 1.0%), top 1000: 0.1% (máx 0.3%), top 10000: 0.0% (máx 0.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 27,370 | -0.608 |  | -30.205 |
| C alvo 0.5ATR/60min liquido | 26,042 | -0.603 |  | -29.966 |
| C alvo 0.5ATR/240min liquido | 21,393 | -0.603 |  | -29.984 |
| C alvo 1.0ATR/15min liquido | 27,370 | -0.598 |  | -29.713 |
| C alvo 1.0ATR/60min liquido | 26,042 | -0.593 |  | -29.471 |
| C alvo 1.0ATR/240min liquido | 21,393 | -0.590 |  | -29.334 |
| C alvo 2.0ATR/15min liquido | 27,370 | -0.594 |  | -29.508 |
| C alvo 2.0ATR/60min liquido | 26,042 | -0.595 |  | -29.578 |
| C alvo 2.0ATR/240min liquido | 21,393 | -0.628 |  | -31.198 |
| V alvo 0.5ATR/15min liquido | 27,370 | -0.609 |  | -30.281 |
| V alvo 0.5ATR/60min liquido | 26,042 | -0.609 |  | -30.286 |
| V alvo 0.5ATR/240min liquido | 21,393 | -0.609 |  | -30.281 |
| V alvo 1.0ATR/15min liquido | 27,370 | -0.599 |  | -29.776 |
| V alvo 1.0ATR/60min liquido | 26,042 | -0.604 |  | -30.011 |
| V alvo 1.0ATR/240min liquido | 21,393 | -0.604 |  | -30.052 |
| V alvo 2.0ATR/15min liquido | 27,370 | -0.590 |  | -29.356 |
| V alvo 2.0ATR/60min liquido | 26,042 | -0.587 |  | -29.198 |
| V alvo 2.0ATR/240min liquido | 21,393 | -0.593 |  | -29.474 |

**M15/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

### M30 — modo `hit`

- eventos: 22,984 (2024-09-11 a 2026-10-16); descoberta 13,751 (até 2025-12-14), validação 9,194 (a partir de 2025-12-15)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 486,186**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 0.0%, top 10000: 0.0%
- **placebo** (6 deslocamentos): top 100: 0.5% (máx 1.0%), top 1000: 0.1% (máx 0.1%), top 10000: 0.0% (máx 0.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 13,670 | -0.409 |  | -29.966 |
| C alvo 0.5ATR/60min liquido | 13,157 | -0.403 |  | -29.565 |
| C alvo 0.5ATR/240min liquido | 10,824 | -0.416 |  | -30.472 |
| C alvo 1.0ATR/15min liquido | 13,670 | -0.406 |  | -29.763 |
| C alvo 1.0ATR/60min liquido | 13,157 | -0.404 |  | -29.637 |
| C alvo 1.0ATR/240min liquido | 10,824 | -0.422 |  | -30.948 |
| C alvo 2.0ATR/15min liquido | 13,670 | -0.404 |  | -29.641 |
| C alvo 2.0ATR/60min liquido | 13,157 | -0.400 |  | -29.302 |
| C alvo 2.0ATR/240min liquido | 10,824 | -0.434 |  | -31.801 |
| V alvo 0.5ATR/15min liquido | 13,670 | -0.404 |  | -29.593 |
| V alvo 0.5ATR/60min liquido | 13,157 | -0.416 |  | -30.478 |
| V alvo 0.5ATR/240min liquido | 10,824 | -0.426 |  | -31.255 |
| V alvo 1.0ATR/15min liquido | 13,670 | -0.391 |  | -28.683 |
| V alvo 1.0ATR/60min liquido | 13,157 | -0.403 |  | -29.508 |
| V alvo 1.0ATR/240min liquido | 10,824 | -0.407 |  | -29.831 |
| V alvo 2.0ATR/15min liquido | 13,670 | -0.389 |  | -28.505 |
| V alvo 2.0ATR/60min liquido | 13,157 | -0.399 |  | -29.276 |
| V alvo 2.0ATR/240min liquido | 10,824 | -0.421 |  | -30.829 |

**M30/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

### H1 — modo `hit`

- eventos: 11,498 (2024-09-11 a 2026-10-16); descoberta 6,877 (até 2025-12-15), validação 4,600 (a partir de 2025-12-16)
- variáveis: 65; séries por variável/par: 18
- **hipóteses testadas: 345,264**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 0.0%, top 10000: 0.0%
- **placebo** (6 deslocamentos): top 100: 0.0% (máx 0.0%), top 1000: 0.0% (máx 0.0%), top 10000: 0.0% (máx 0.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 6,834 | -0.277 |  | -29.692 |
| C alvo 0.5ATR/60min liquido | 6,719 | -0.268 |  | -28.702 |
| C alvo 0.5ATR/240min liquido | 5,539 | -0.273 |  | -29.317 |
| C alvo 1.0ATR/15min liquido | 6,834 | -0.278 |  | -29.808 |
| C alvo 1.0ATR/60min liquido | 6,719 | -0.271 |  | -29.032 |
| C alvo 1.0ATR/240min liquido | 5,539 | -0.283 |  | -30.306 |
| C alvo 2.0ATR/15min liquido | 6,834 | -0.276 |  | -29.553 |
| C alvo 2.0ATR/60min liquido | 6,719 | -0.264 |  | -28.355 |
| C alvo 2.0ATR/240min liquido | 5,539 | -0.280 |  | -29.986 |
| V alvo 0.5ATR/15min liquido | 6,834 | -0.264 |  | -28.279 |
| V alvo 0.5ATR/60min liquido | 6,719 | -0.274 |  | -29.419 |
| V alvo 0.5ATR/240min liquido | 5,539 | -0.271 |  | -29.035 |
| V alvo 1.0ATR/15min liquido | 6,834 | -0.257 |  | -27.606 |
| V alvo 1.0ATR/60min liquido | 6,719 | -0.272 |  | -29.112 |
| V alvo 1.0ATR/240min liquido | 5,539 | -0.266 |  | -28.499 |
| V alvo 2.0ATR/15min liquido | 6,834 | -0.255 |  | -27.303 |
| V alvo 2.0ATR/60min liquido | 6,719 | -0.269 |  | -28.864 |
| V alvo 2.0ATR/240min liquido | 5,539 | -0.274 |  | -29.380 |

**H1/hit: nenhuma família passou nos filtros (|t|>2 na descoberta e repetição na validação).**

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **1228**
- com líquido positivo e t>1,645 na validação, custo realista: **3**; dessas, sobreviveram ao BH: **0**; e positivas nas duas metades da validação: **0**
- **Nenhuma família passa em todos os filtros (BH + validação + líquido positivo com custo realista + estabilidade nas duas metades).**

## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 884s)_
