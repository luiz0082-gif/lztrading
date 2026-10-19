# DXY — relatório completo MBA (gerado em 2026-10-17 02:31)

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
| M5 | open | 93,895 | 66,078 | 3 | 0 | 0.0 | 0.0 | 0 | 26.0 | 3.2 |
| M15 | open | 45,952 | 59,683 | 0 | 0 | 0.0 | 0.0 | 0 | 2.0 | 3.0 |
| M30 | open | 22,984 | 48,810 | 0 | 0 | 0.0 | 0.0 | 0 | 4.0 | 3.2 |
| H1 | open | 11,498 | 29,872 | 0 | 0 | 0.0 | 0.0 | 0 | 12.0 | 0.3 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 93,895 (2025-05-15 a 2026-10-16); descoberta 56,085 (até 2026-03-23), validação 37,558 (a partir de 2026-03-24)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 66,078**; passaram no BH (q=5%) na descoberta: **3**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 26.0%, top 1000: 7.4%, top 10000: 4.5%
- **placebo** (6 deslocamentos): top 100: 3.2% (máx 5.0%), top 1000: 4.2% (máx 6.4%), top 10000: 3.4% (máx 4.7%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 56,072 | 0.001 | 0.343 | 0.025 |
| 10min bruto | 56,072 | 0.001 | 0.132 | 0.021 |
| 20min bruto | 55,311 | 0.002 | 0.129 | 0.041 |
| 35min bruto | 54,242 | 0.004 | 0.157 | 0.090 |
| 65min bruto | 52,267 | 0.008 | 0.170 | 0.190 |
| 125min bruto | 48,679 | 0.012 | 0.123 | 0.292 |
| 245min bruto | 42,135 | -0.000 | -0.000 | -0.001 |

**M5/open: famílias distintas validadas: 57; com líquido positivo e significativo na validação (custo realista): 3.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 125min | VENDA | 223 | 111 | -2.24 | nao | -1.92 | 1 | 96.54 | 66.54 | 66.54 | 5.77 | -31.52 | 8.49 | 71.17 | 2/2 | 11/14 | 92.64 | 40.91 | 30.00 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 65min | VENDA | 223 | 111 | -2.57 | nao | -2.41 | 1 | 63.92 | 33.92 | 33.92 | 3.94 | -30.94 | 7.52 | 58.56 | 2/2 | 11/14 | 34.24 | 33.61 | 30.00 |
| mtf_W1=RANGE & news_min_since_last_high=Q1 | 125min | COMPRA | 1,366 | 1,768 | 2.02 | nao | 2.61 | 1 | 34.99 | 4.99 | 4.99 | 1.83 | -28.48 | 12.70 | 51.81 | 1/2 | 6/10 | -15.00 | 24.99 | 30.00 |

### M15 — modo `open`

- eventos: 45,952 (2024-09-10 a 2026-10-16); descoberta 27,500 (até 2025-12-14), validação 18,381 (a partir de 2025-12-15)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 59,683**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 2.0%, top 1000: 4.6%, top 10000: 4.3%
- **placebo** (6 deslocamentos): top 100: 3.0% (máx 8.0%), top 1000: 4.5% (máx 6.6%), top 10000: 3.4% (máx 4.0%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 27,487 | -0.003 | -0.732 | -0.151 |
| 20min bruto | 27,487 | -0.003 | -0.414 | -0.130 |
| 30min bruto | 27,370 | -0.003 | -0.352 | -0.161 |
| 45min bruto | 26,907 | -0.005 | -0.356 | -0.251 |
| 75min bruto | 26,042 | -0.008 | -0.337 | -0.412 |
| 135min bruto | 24,431 | -0.019 | -0.390 | -0.931 |
| 255min bruto | 21,393 | -0.031 | -0.303 | -1.547 |

**M15/open: famílias distintas validadas: 42; com líquido positivo e significativo na validação (custo realista): 0.**

Nenhuma viável; melhores famílias validadas (líquido NEGATIVO ou insignificante):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hour=18 & news_min_since_last_high=Q1 | 15min | COMPRA | 300 | 170 | 2.44 | nao | 2.81 | 1 | 9.56 | -20.44 | -20.44 | -6.04 | -29.79 | 2.77 | 22.35 | 0/3 | 3/26 | -21.91 | -18.98 | 30.00 |
| slot_hhmm=01:15 & atr_ratio_prev=Q1 | 15min | COMPRA | 124 | 60 | 2.59 | nao | 2.65 | 1 | 4.93 | -25.07 | -25.07 | -10.40 | -29.79 | 1.94 | 8.33 | 0/3 | 1/23 | -22.77 | -27.37 | 30.00 |
| hour=18 & news_min_since_last_high=Q1 | 20min | COMPRA | 300 | 170 | 2.60 | nao | 2.51 | 1 | 11.41 | -18.59 | -18.59 | -4.48 | -29.91 | 2.74 | 25.88 | 0/3 | 6/26 | -23.38 | -13.80 | 30.00 |
| hour=1 & p2=Q1 | 15min | COMPRA | 309 | 164 | 2.50 | nao | 2.45 | 1 | 5.10 | -24.90 | -24.90 | -12.78 | -29.79 | 2.50 | 15.24 | 0/3 | 0/26 | -24.88 | -24.91 | 30.00 |
| hour=15 & pcum3=Q4 | 20min | COMPRA | 257 | 180 | 2.33 | nao | 2.36 | 1 | 10.69 | -19.31 | -19.31 | -5.17 | -29.91 | 2.85 | 31.11 | 0/3 | 3/26 | -23.13 | -15.49 | 30.00 |
| mtf_H1=RANGE & month=12 | 15min | COMPRA | 604 | 227 | 2.29 | nao | 2.36 | 1 | 4.28 | -25.72 | -25.72 | -14.64 | -29.79 | 2.31 | 16.74 | 0/2 | 0/2 | -27.23 | -24.23 | 30.00 |
| hour=15 & pcum10=Q4 | 15min | COMPRA | 226 | 151 | 2.02 | nao | 2.34 | 1 | 8.98 | -21.02 | -21.02 | -5.93 | -29.79 | 2.48 | 23.84 | 0/3 | 3/26 | -17.53 | -24.46 | 30.00 |
| mtf_H1=RANGE & month=12 | 30min | COMPRA | 600 | 226 | 2.11 | nao | 2.26 | 1 | 8.02 | -21.98 | -21.98 | -8.96 | -29.59 | 3.09 | 26.55 | 0/2 | 0/2 | -25.47 | -18.49 | 30.00 |
| hour=3 & dom_w=d22_31 | 15min | COMPRA | 393 | 265 | 2.71 | nao | 2.22 | 1 | 2.70 | -27.30 | -27.30 | -22.18 | -29.79 | 2.00 | 8.68 | 0/3 | 0/25 | -28.30 | -26.30 | 30.00 |
| hour=18 & news_min_since_last_high=Q1 | 30min | COMPRA | 300 | 170 | 2.51 | nao | 2.22 | 1 | 15.59 | -14.41 | -14.41 | -2.79 | -29.59 | 2.95 | 32.35 | 0/3 | 10/26 | -18.71 | -10.11 | 30.00 |
| slot_hhmm=01:45 & news_min_since_last_high=Q3 | 15min | COMPRA | 149 | 113 | 2.16 | nao | 2.13 | 1 | 6.89 | -23.11 | -23.11 | -8.88 | -29.79 | 2.56 | 19.47 | 0/3 | 0/26 | -21.86 | -24.33 | 30.00 |
| mtf_D1=BEARISH & news_min_since_last_high=Q3 | 45min | COMPRA | 1,062 | 584 | 2.25 | nao | 2.07 | 1 | 5.20 | -24.80 | -24.80 | -14.78 | -29.43 | 2.73 | 23.80 | 0/3 | 0/19 | -24.74 | -24.87 | 30.00 |
| hour=15 & pcum3=Q4 | 15min | COMPRA | 257 | 180 | 2.16 | nao | 2.03 | 1 | 7.46 | -22.54 | -22.54 | -7.07 | -29.79 | 2.28 | 25.56 | 0/3 | 1/26 | -23.71 | -21.38 | 30.00 |
| session=LONDON & month=7 | 15min | COMPRA | 460 | 460 | 3.08 | nao | 2.02 | 1 | 2.51 | -27.49 | -27.49 | -12.62 | -29.79 | 1.07 | 18.48 | 0/2 | 0/2 | -30.33 | -24.66 | 30.00 |
| structure_before=BREAK_DOWN & pcum10=Q1 | 15min | COMPRA | 1,324 | 745 | 2.06 | nao | 1.96 | 2 | 2.32 | -27.68 | -27.68 | -16.14 | -29.79 | 1.26 | 23.76 | 0/3 | 0/26 | -27.20 | -28.15 | 30.00 |

### M30 — modo `open`

- eventos: 22,984 (2024-09-11 a 2026-10-16); descoberta 13,751 (até 2025-12-14), validação 9,194 (a partir de 2025-12-15)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 48,810**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 4.0%, top 1000: 6.5%, top 10000: 5.0%
- **placebo** (6 deslocamentos): top 100: 3.2% (máx 5.0%), top 1000: 4.1% (máx 5.7%), top 10000: 3.4% (máx 4.6%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 13,738 | -0.002 | -0.367 | -0.157 |
| 35min bruto | 13,738 | -0.006 | -0.834 | -0.467 |
| 45min bruto | 13,670 | -0.008 | -0.852 | -0.604 |
| 60min bruto | 13,595 | -0.001 | -0.077 | -0.072 |
| 90min bruto | 13,157 | -0.001 | -0.037 | -0.055 |
| 150min bruto | 12,350 | -0.002 | -0.060 | -0.159 |
| 270min bruto | 10,824 | -0.004 | -0.051 | -0.282 |

**M30/open: famílias distintas validadas: 68; com líquido positivo e significativo na validação (custo realista): 1.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| month=10 & atr_ratio_prev=Q1 | 270min | COMPRA | 312 | 76 | 2.04 | nao | 2.21 | 1 | 151.33 | 121.33 | 121.33 | 5.27 | -27.98 | 6.49 | 77.63 | 3/3 | 3/3 | 77.13 | 165.53 | 30.00 |

### H1 — modo `open`

- eventos: 11,498 (2024-09-11 a 2026-10-16); descoberta 6,877 (até 2025-12-15), validação 4,600 (a partir de 2025-12-16)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 29,872**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 12.0%, top 1000: 9.0%, top 10000: 6.1%
- **placebo** (6 deslocamentos): top 100: 0.3% (máx 1.0%), top 1000: 2.5% (máx 3.6%), top 10000: 2.8% (máx 3.4%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 6,864 | -0.001 | -0.147 | -0.131 |
| 65min bruto | 6,864 | -0.005 | -0.475 | -0.495 |
| 75min bruto | 6,834 | -0.011 | -0.955 | -1.148 |
| 90min bruto | 6,787 | -0.011 | -0.847 | -1.230 |
| 120min bruto | 6,719 | 0.003 | 0.178 | 0.353 |
| 180min bruto | 6,311 | 0.003 | 0.084 | 0.269 |
| 300min bruto | 5,539 | 0.002 | 0.040 | 0.243 |

**H1/open: famílias distintas validadas: 57; com líquido positivo e significativo na validação (custo realista): 0.**

Nenhuma viável; melhores famílias validadas (líquido NEGATIVO ou insignificante):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H1=RANGE & month=12 | 90min | COMPRA | 149 | 54 | 2.21 | nao | 3.10 | 2 | 32.48 | 2.48 | 2.48 | 0.31 | -29.15 | 3.85 | 46.30 | 0/2 | 0/2 | -5.56 | 10.52 | 30.00 |
| mtf_H1=RANGE & month=12 | 60min | COMPRA | 152 | 55 | 3.17 | nao | 3.07 | 2 | 18.64 | -11.36 | -11.36 | -2.04 | -29.08 | 3.12 | 38.18 | 0/2 | 0/2 | -15.48 | -7.39 | 30.00 |
| mtf_H1=RANGE & month=12 | 75min | COMPRA | 152 | 55 | 2.42 | nao | 2.88 | 2 | 23.07 | -6.93 | -6.93 | -1.01 | -29.28 | 3.20 | 41.82 | 0/2 | 0/2 | -18.15 | 3.89 | 30.00 |
| mtf_D1=BULLISH & pcum10=Q3 | 60min | COMPRA | 402 | 348 | 2.08 | nao | 2.65 | 1 | 8.52 | -21.48 | -21.48 | -6.17 | -29.08 | 2.24 | 30.46 | 0/3 | 0/18 | -14.60 | -28.37 | 30.00 |
| streak_prev=-2 & p1=Q2 | 65min | COMPRA | 340 | 225 | 2.89 | nao | 2.62 | 1 | 10.08 | -19.92 | -19.92 | -4.19 | -29.42 | 2.03 | 36.44 | 0/3 | 3/26 | -20.19 | -19.66 | 30.00 |
| structure_before=RANGE & month=12 | 65min | COMPRA | 152 | 55 | 3.18 | nao | 2.62 | 2 | 17.45 | -12.55 | -12.55 | -2.08 | -29.42 | 2.75 | 40.00 | 0/2 | 0/2 | -21.70 | -3.71 | 30.00 |
| dom_w=d01_07 & news_min_since_last_high=Q1 | 90min | COMPRA | 223 | 139 | 2.04 | nao | 2.60 | 1 | 23.63 | -6.37 | -6.37 | -0.76 | -29.15 | 2.77 | 48.92 | 2/3 | 13/25 | -7.45 | -5.31 | 30.00 |
| streak_prev=-2 & p1=Q2 | 75min | COMPRA | 337 | 222 | 2.30 | nao | 2.60 | 1 | 11.30 | -18.70 | -18.70 | -3.81 | -29.28 | 2.19 | 39.64 | 0/3 | 4/26 | -18.20 | -19.21 | 30.00 |
| mtf_D1=BULLISH & pcum10=Q3 | 65min | COMPRA | 402 | 348 | 2.20 | nao | 2.55 | 1 | 9.08 | -20.92 | -20.92 | -5.53 | -29.42 | 2.31 | 32.18 | 0/3 | 1/18 | -15.23 | -26.61 | 30.00 |
| structure_before=RANGE & month=12 | 120min | COMPRA | 145 | 51 | 2.11 | nao | 2.50 | 2 | 33.90 | 3.90 | 3.90 | 0.44 | -28.43 | 3.59 | 49.02 | 0/2 | 0/2 | -5.12 | 12.58 | 30.00 |
| day_of_week=WEDNESDAY & p1=Q2 | 65min | COMPRA | 229 | 177 | 2.30 | nao | 2.47 | 1 | 15.58 | -14.42 | -14.42 | -2.38 | -29.42 | 2.52 | 36.72 | 0/3 | 7/26 | -11.36 | -17.45 | 30.00 |
| day_of_week=WEDNESDAY & range_atr_prev=Q3 | 60min | COMPRA | 244 | 179 | 2.45 | nao | 2.41 | 1 | 11.21 | -18.79 | -18.79 | -4.13 | -29.08 | 2.28 | 32.40 | 0/3 | 4/26 | -11.67 | -25.82 | 30.00 |
| day_of_week=MONDAY & pcum10=Q3 | 65min | COMPRA | 300 | 155 | 2.36 | nao | 2.36 | 1 | 13.68 | -16.32 | -16.32 | -3.00 | -29.42 | 2.43 | 32.90 | 1/3 | 7/26 | -10.53 | -22.04 | 30.00 |
| mtf_M30=RANGE & p1=Q4 | 60min | COMPRA | 307 | 171 | 2.26 | nao | 2.36 | 1 | 10.08 | -19.92 | -19.92 | -3.79 | -29.08 | 1.77 | 38.01 | 0/3 | 2/26 | -19.16 | -20.67 | 30.00 |
| mtf_M30=BEARISH & pcum10=Q3 | 60min | COMPRA | 370 | 205 | 2.53 | nao | 2.30 | 1 | 10.64 | -19.36 | -19.36 | -5.42 | -29.08 | 2.71 | 31.71 | 0/3 | 2/26 | -12.87 | -25.78 | 30.00 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **224**
- com líquido positivo e t>1,645 na validação, custo realista: **4**; dessas, sobreviveram ao BH: **0**; e positivas nas duas metades da validação: **0**
- **Nenhuma família passa em todos os filtros (BH + validação + líquido positivo com custo realista + estabilidade nas duas metades).**

## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 88s)_
