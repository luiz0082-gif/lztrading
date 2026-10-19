# USDCHF — relatório completo MBA (gerado em 2026-10-17 02:27)

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
| M5 | open | 105,987 | 70,159 | 679 | 450 | 25.5 | 4.7 | 13 | 76.0 | 15.0 |
| M15 | open | 67,894 | 79,660 | 1,652 | 1,439 | 16.5 | 7.0 | 42 | 100.0 | 15.3 |
| M30 | open | 33,888 | 62,715 | 1,593 | 1,474 | 22.5 | 5.2 | 28 | 100.0 | 14.2 |
| H1 | open | 33,052 | 61,856 | 2,273 | 2,073 | 2.0 | 0.2 | 1 | 100.0 | 13.3 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 105,987 (2025-05-15 a 2026-10-16); descoberta 63,305 (até 2026-03-23), validação 42,395 (a partir de 2026-03-24)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 70,159**; passaram no BH (q=5%) na descoberta: **679**; confirmadas na validação: **450**
- melhores N da descoberta que repetem na validação: top 100: 76.0%, top 1000: 59.5%, top 10000: 20.5%
- **placebo** (6 deslocamentos): top 100: 15.0% (máx 36.0%), top 1000: 10.6% (máx 18.8%), top 10000: 6.0% (máx 7.6%); BH: média 25.5 (máx 41); confirmadas: média 4.7 (máx 13)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,292 | 0.001 | 0.395 | 0.028 |
| 10min bruto | 63,292 | -0.007 | -1.209 | -0.187 |
| 20min bruto | 62,841 | 0.002 | 0.166 | 0.050 |
| 35min bruto | 62,166 | 0.020 | 0.977 | 0.528 |
| 65min bruto | 60,825 | 0.065 | 1.611 | 1.673 |
| 125min bruto | 58,149 | 0.064 | 0.783 | 1.650 |
| 245min bruto | 52,835 | 0.053 | 0.297 | 1.360 |

**M5/open: famílias distintas validadas: 1020; com líquido positivo e significativo na validação (custo realista): 27.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hour=13 & mtf_W1=BEARISH | 65min | VENDA | 1,776 | 250 | -2.46 | nao | -2.79 | 1 | 51.39 | 49.53 | 49.67 | 9.85 | -6.22 | 11.10 | 71.20 | 2/2 | 10/12 | 56.71 | 42.62 | 1.72 |
| mtf_M30=BEARISH & month=3 | 245min | COMPRA | 1,055 | 162 | 2.06 | nao | 1.66 | 1 | 87.69 | 79.62 | 79.62 | 9.49 | 1.20 | 9.32 | 80.25 | 1/1 | 1/1 | 113.73 | 45.51 | 8.07 |
| mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | 65min | VENDA | 268 | 66 | -2.34 | nao | -2.36 | 1 | 50.73 | 49.41 | 49.25 | 7.67 | -6.22 | 8.58 | 77.27 | 2/2 | 6/7 | 17.21 | 81.30 | 1.47 |
| news_state=EVENTS_2_AROUND_60M & month=3 | 65min | COMPRA | 192 | 97 | 2.35 | nao | 2.19 | 1 | 44.49 | 41.93 | 41.93 | 7.34 | -2.98 | 7.83 | 73.20 | 1/1 | 1/1 | 18.53 | 64.84 | 2.57 |
| news_state=EVENTS_2_AROUND_60M & month=3 | 125min | COMPRA | 185 | 97 | 2.01 | nao | 1.75 | 1 | 56.22 | 53.65 | 53.65 | 6.92 | -1.63 | 7.09 | 80.41 | 1/1 | 1/1 | 25.15 | 81.56 | 2.57 |
| day_of_week=WEDNESDAY & hour=7 | 65min | COMPRA | 528 | 359 | 2.09 | nao | 2.30 | 1 | 22.11 | 20.33 | 20.33 | 6.00 | -2.98 | 6.89 | 67.97 | 2/2 | 14/18 | 2.15 | 38.41 | 1.78 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 35min | VENDA | 223 | 110 | -2.59 | nao | -2.16 | 1 | 35.80 | 33.93 | 33.98 | 4.84 | -6.71 | 5.77 | 70.00 | 2/2 | 11/14 | 17.21 | 50.75 | 1.82 |
| news_state=EVENTS_2_AROUND_60M & month=3 | 35min | COMPRA | 192 | 97 | 2.00 | nao | 2.26 | 1 | 24.14 | 21.57 | 21.57 | 4.64 | -4.97 | 5.68 | 71.13 | 1/1 | 1/1 | 13.11 | 29.86 | 2.57 |
| hour=13 & mtf_W1=BEARISH | 35min | VENDA | 1,776 | 256 | -2.13 | nao | -1.91 | 1 | 22.25 | 20.39 | 20.45 | 4.32 | -6.71 | 5.75 | 56.64 | 2/2 | 9/12 | 31.78 | 9.11 | 1.80 |
| news_state=EVENTS_4_AROUND_60M & pcum10=Q1 | 35min | COMPRA | 258 | 218 | 2.12 | nao | 1.69 | 1 | 25.78 | 23.89 | 23.89 | 4.25 | -4.97 | 5.14 | 61.01 | 2/2 | 13/18 | 5.74 | 42.05 | 1.89 |
| mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | 35min | VENDA | 268 | 66 | -2.60 | nao | -1.82 | 1 | 20.32 | 19.01 | 18.91 | 3.92 | -6.71 | 5.27 | 66.67 | 2/2 | 5/7 | 7.64 | 30.17 | 1.41 |
| hour=9 & mtf_H1=RANGE | 35min | COMPRA | 768 | 540 | 2.26 | nao | 1.84 | 1 | 9.34 | 7.76 | 7.76 | 3.90 | -4.97 | 6.41 | 55.56 | 2/2 | 12/18 | 3.98 | 11.55 | 1.58 |
| day_of_week=WEDNESDAY & hour=7 | 35min | COMPRA | 528 | 359 | 2.66 | nao | 2.16 | 1 | 11.58 | 9.80 | 9.80 | 3.67 | -4.97 | 5.54 | 61.00 | 2/2 | 15/18 | 0.19 | 19.35 | 1.78 |
| hour=9 & mtf_H1=RANGE | 20min | COMPRA | 768 | 540 | 2.46 | nao | 2.09 | 1 | 6.36 | 4.78 | 4.78 | 3.16 | -5.94 | 7.10 | 53.89 | 2/2 | 13/18 | 2.05 | 7.52 | 1.58 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 20min | VENDA | 223 | 110 | -2.21 | nao | -1.90 | 1 | 18.26 | 16.39 | 16.42 | 3.04 | -6.84 | 4.29 | 60.91 | 2/2 | 11/14 | 2.95 | 29.88 | 1.85 |
| slot_hhmm=12:05 | 5min | COMPRA | 221 | 148 | 4.28 | sim | 4.33 | 3 | 7.30 | 5.36 | 5.36 | 2.93 | -6.71 | 6.57 | 62.16 | 2/2 | 13/18 | 5.87 | 4.85 | 1.95 |
| slot_hhmm=12:05 & news_min_to_next_high=Q1 | 5min | COMPRA | 121 | 100 | 4.20 | sim | 3.96 | 1 | 7.44 | 5.49 | 5.49 | 2.59 | -6.71 | 5.72 | 63.00 | 2/2 | 12/17 | 7.60 | 3.39 | 1.95 |
| slot_hhmm=12:10 & news_min_to_next_high=Q1 | 5min | VENDA | 121 | 100 | -2.46 | nao | -3.29 | 1 | 8.16 | 6.19 | 6.19 | 2.57 | -7.15 | 5.51 | 59.00 | 2/2 | 11/17 | 9.44 | 2.95 | 1.97 |
| day_of_week=WEDNESDAY & hour=7 | 20min | COMPRA | 528 | 359 | 2.55 | nao | 2.19 | 1 | 7.04 | 5.26 | 5.26 | 2.47 | -5.94 | 5.27 | 59.89 | 2/2 | 15/18 | -0.14 | 10.62 | 1.78 |
| mtf_M15=RANGE & pcum10=Q1 | 65min | COMPRA | 3,416 | 2,343 | 2.06 | nao | 2.43 | 1 | 14.01 | 4.01 | 4.01 | 2.41 | -2.98 | 4.35 | 50.49 | 1/2 | 8/18 | 0.12 | 7.88 | 10.00 |
| session=LONDON & mtf_H1=RANGE | 20min | COMPRA | 3,792 | 2,347 | 2.57 | nao | 1.90 | 1 | 3.75 | 2.03 | 2.03 | 2.27 | -5.94 | 9.14 | 52.54 | 2/2 | 10/18 | 0.79 | 3.27 | 1.72 |
| mtf_D1=BEARISH & news_min_to_next_high=Q4 | 245min | COMPRA | 2,651 | 655 | 2.21 | nao | 1.90 | 1 | 38.97 | 6.48 | 6.48 | 2.06 | 1.20 | 1.65 | 55.27 | 1/2 | 6/14 | -6.02 | 18.94 | 32.50 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 10min | VENDA | 223 | 110 | -2.02 | nao | -2.02 | 1 | 9.12 | 7.25 | 7.24 | 2.02 | -6.96 | 3.94 | 56.36 | 2/2 | 11/14 | -1.37 | 15.86 | 1.87 |
| hour=18 & news_min_since_last_high=Q1 | 20min | COMPRA | 727 | 236 | 2.09 | nao | 1.84 | 1 | 10.93 | 9.06 | 9.06 | 1.98 | -5.94 | 3.28 | 55.93 | 2/2 | 14/18 | 7.05 | 11.07 | 1.87 |
| hour=14 & mtf_W1=BEARISH | 10min | VENDA | 1,776 | 268 | -2.79 | nao | -1.84 | 1 | 7.15 | 5.40 | 5.46 | 1.80 | -6.96 | 4.09 | 55.22 | 2/2 | 9/12 | 0.46 | 10.45 | 1.70 |

### M15 — modo `open`

- eventos: 67,894 (2024-01-22 a 2026-10-16); descoberta 40,640 (até 2025-09-11), validação 27,158 (a partir de 2025-09-12)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 79,660**; passaram no BH (q=5%) na descoberta: **1,652**; confirmadas na validação: **1,439**
- melhores N da descoberta que repetem na validação: top 100: 100.0%, top 1000: 94.3%, top 10000: 39.9%
- **placebo** (6 deslocamentos): top 100: 15.3% (máx 43.0%), top 1000: 8.5% (máx 17.6%), top 10000: 5.5% (máx 7.7%); BH: média 16.5 (máx 98); confirmadas: média 7.0 (máx 42)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 40,627 | 0.006 | 1.763 | 0.297 |
| 20min bruto | 40,627 | 0.009 | 1.647 | 0.419 |
| 30min bruto | 39,986 | 0.008 | 1.030 | 0.376 |
| 45min bruto | 39,430 | 0.018 | 1.553 | 0.879 |
| 75min bruto | 38,434 | 0.037 | 1.812 | 1.804 |
| 135min bruto | 36,558 | 0.048 | 1.239 | 2.380 |
| 255min bruto | 32,975 | 0.040 | 0.485 | 1.980 |

**M15/open: famílias distintas validadas: 2614; com líquido positivo e significativo na validação (custo realista): 28.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=MONDAY & month=7 | 135min | COMPRA | 781 | 351 | 2.09 | nao | 1.99 | 1 | 35.15 | 28.30 | 28.30 | 5.95 | -2.70 | 6.53 | 59.26 | 3/3 | 3/3 | 27.10 | 29.50 | 6.84 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 75min | VENDA | 181 | 74 | -2.19 | nao | -2.21 | 1 | 55.53 | 53.63 | 53.69 | 3.86 | -6.47 | 4.30 | 68.92 | 3/3 | 19/25 | 42.24 | 65.14 | 1.83 |
| month=5 & news_min_to_next_high=Q1 | 75min | VENDA | 532 | 238 | -2.08 | nao | -1.82 | 1 | 21.83 | 20.05 | 20.04 | 3.58 | -6.47 | 4.75 | 57.98 | 2/3 | 2/3 | 22.64 | 17.44 | 1.79 |
| slot_hhmm=00:45 & dom_w=d22_31 | 15min | VENDA | 133 | 87 | -2.35 | nao | -3.99 | 1 | 9.44 | 7.65 | 7.84 | 3.43 | -7.87 | 6.82 | 65.52 | 3/3 | 22/33 | 7.18 | 8.48 | 1.60 |
| month=3 & news_min_since_last_high=Q3 | 135min | COMPRA | 451 | 206 | 2.24 | nao | 1.97 | 1 | 30.39 | 17.86 | 17.86 | 3.35 | -2.70 | 3.84 | 58.74 | 2/3 | 2/3 | 30.70 | 5.02 | 12.53 |
| month=5 & news_min_to_next_high=Q1 | 45min | VENDA | 532 | 238 | -2.16 | nao | -1.87 | 1 | 13.65 | 11.88 | 11.87 | 2.83 | -7.33 | 4.58 | 57.56 | 2/3 | 2/3 | 13.70 | 10.04 | 1.78 |
| hour=15 & pcum3=Q3 | 30min | COMPRA | 309 | 200 | 2.57 | nao | 1.83 | 1 | 14.69 | 13.05 | 13.05 | 2.81 | -6.56 | 4.24 | 57.00 | 3/3 | 26/33 | 18.45 | 7.64 | 1.65 |
| hour=8 & mtf_H1=BREAK_DOWN | 30min | VENDA | 124 | 56 | -2.42 | nao | -2.05 | 1 | 25.75 | 23.87 | 23.90 | 2.71 | -7.61 | 3.54 | 60.71 | 3/3 | 11/13 | 39.93 | 7.88 | 1.85 |
| slot_hhmm=00:45 & structure_before=BULLISH | 15min | VENDA | 154 | 108 | -2.23 | nao | -3.41 | 2 | 7.68 | 5.91 | 6.12 | 2.66 | -7.87 | 6.04 | 58.33 | 3/3 | 15/25 | 5.62 | 6.62 | 1.56 |
| hour=15 & pcum3=Q3 | 20min | COMPRA | 309 | 200 | 4.02 | sim | 2.28 | 1 | 11.90 | 10.25 | 10.25 | 2.57 | -6.95 | 4.32 | 59.00 | 3/3 | 27/33 | 10.38 | 10.12 | 1.65 |
| dom_w=d08_14 & atr_ratio_prev=Q5 | 75min | COMPRA | 1,570 | 1,020 | 2.17 | nao | 1.90 | 1 | 12.66 | 7.17 | 7.17 | 2.55 | -3.97 | 4.06 | 55.88 | 2/3 | 21/33 | 2.04 | 12.31 | 5.48 |
| slot_hhmm=00:45 & news_min_since_last_high=Q3 | 15min | VENDA | 177 | 109 | -2.27 | nao | -2.80 | 1 | 7.46 | 5.62 | 5.86 | 2.42 | -7.87 | 5.63 | 59.63 | 3/3 | 22/33 | 12.12 | -0.29 | 1.60 |
| slot_hhmm=09:45 & mtf_M5=BULLISH | 15min | COMPRA | 142 | 110 | 2.32 | nao | 2.69 | 1 | 9.25 | 7.54 | 7.54 | 2.36 | -6.87 | 4.49 | 58.18 | 3/3 | 21/31 | 19.00 | -3.92 | 1.72 |
| month=5 & news_min_to_next_high=Q1 | 30min | VENDA | 532 | 238 | -2.14 | nao | -1.98 | 1 | 9.99 | 8.22 | 8.21 | 2.36 | -7.61 | 4.55 | 54.62 | 2/3 | 2/3 | 9.93 | 6.48 | 1.78 |
| hour=15 & pcum3=Q3 | 15min | COMPRA | 309 | 200 | 3.77 | sim | 2.30 | 1 | 10.43 | 8.79 | 8.79 | 2.24 | -6.87 | 4.00 | 57.50 | 3/3 | 22/33 | 11.42 | 6.15 | 1.65 |
| slot_hhmm=09:45 & mtf_D1=BEARISH | 15min | COMPRA | 157 | 68 | 2.95 | nao | 2.50 | 1 | 10.32 | 8.50 | 8.50 | 2.21 | -6.87 | 3.97 | 61.76 | 3/3 | 13/18 | 15.22 | 1.78 | 1.82 |
| news_state=EVENTS_3_AROUND_60M & pcum10=Q2 | 15min | VENDA | 145 | 93 | -2.16 | nao | -2.14 | 1 | 15.29 | 13.38 | 13.40 | 2.16 | -7.87 | 3.42 | 58.06 | 3/3 | 17/25 | 0.25 | 26.27 | 1.89 |
| day_of_week=MONDAY & hour=0 | 20min | VENDA | 340 | 228 | -2.32 | nao | -2.36 | 1 | 8.33 | 6.44 | 6.45 | 2.15 | -7.35 | 4.60 | 53.07 | 3/3 | 22/33 | 10.76 | 2.15 | 1.88 |
| slot_hhmm=00:45 & dom_w=d22_31 | 20min | VENDA | 133 | 87 | -2.13 | nao | -2.20 | 1 | 9.64 | 7.86 | 7.84 | 2.10 | -7.35 | 4.05 | 59.77 | 3/3 | 20/33 | 6.50 | 9.15 | 1.80 |
| hour=8 & mtf_H1=BREAK_DOWN | 20min | VENDA | 124 | 56 | -2.66 | nao | -1.96 | 1 | 16.57 | 14.70 | 14.73 | 2.08 | -7.35 | 3.09 | 64.29 | 3/3 | 11/13 | 27.56 | 1.90 | 1.84 |
| mtf_H1=BREAK_UP & range_atr_prev=Q4 | 20min | VENDA | 512 | 373 | -2.00 | nao | -2.46 | 1 | 8.26 | 6.22 | 5.87 | 2.03 | -7.35 | 4.60 | 51.74 | 3/3 | 22/33 | 5.64 | 6.09 | 2.40 |
| mtf_H1=BULLISH & pcum10=Q1 | 135min | COMPRA | 1,616 | 1,268 | 2.05 | nao | 1.76 | 1 | 14.95 | 5.56 | 5.56 | 1.92 | -2.70 | 2.91 | 51.66 | 2/3 | 19/34 | 6.59 | 4.52 | 9.39 |
| day_of_week=FRIDAY & mtf_M15=BREAK_UP | 20min | VENDA | 415 | 297 | -2.19 | nao | -2.66 | 2 | 8.26 | 6.28 | 5.57 | 1.89 | -7.35 | 4.40 | 53.54 | 3/3 | 25/33 | 13.24 | -2.05 | 2.68 |
| slot_hhmm=01:15 & mtf_M15=BULLISH | 15min | COMPRA | 171 | 120 | 2.55 | nao | 3.03 | 2 | 5.81 | 4.14 | 4.14 | 1.89 | -6.87 | 4.99 | 57.50 | 3/3 | 22/31 | 3.62 | 4.65 | 1.67 |
| slot_hhmm=02:00 & mtf_H1=BEARISH | 15min | VENDA | 156 | 96 | -2.03 | nao | -2.53 | 1 | 6.77 | 5.31 | 5.31 | 1.83 | -7.87 | 4.50 | 51.04 | 3/3 | 21/31 | 3.74 | 6.87 | 1.46 |

### M30 — modo `open`

- eventos: 33,888 (2024-01-22 a 2026-10-16); descoberta 20,284 (até 2025-09-11), validação 13,556 (a partir de 2025-09-12)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 62,715**; passaram no BH (q=5%) na descoberta: **1,593**; confirmadas na validação: **1,474**
- melhores N da descoberta que repetem na validação: top 100: 100.0%, top 1000: 97.4%, top 10000: 39.7%
- **placebo** (6 deslocamentos): top 100: 14.2% (máx 44.0%), top 1000: 10.7% (máx 17.6%), top 10000: 7.9% (máx 11.6%); BH: média 22.5 (máx 62); confirmadas: média 5.2 (máx 28)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 20,271 | 0.010 | 2.097 | 0.735 |
| 35min bruto | 20,271 | 0.014 | 2.215 | 1.027 |
| 45min bruto | 20,157 | 0.017 | 2.082 | 1.214 |
| 60min bruto | 19,679 | 0.015 | 1.448 | 1.112 |
| 90min bruto | 19,184 | 0.028 | 1.685 | 2.044 |
| 150min bruto | 18,245 | 0.037 | 1.240 | 2.695 |
| 270min bruto | 16,447 | 0.031 | 0.494 | 2.208 |

**M30/open: famílias distintas validadas: 2457; com líquido positivo e significativo na validação (custo realista): 25.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=MONDAY & month=7 | 270min | COMPRA | 354 | 159 | 2.31 | nao | 2.26 | 1 | 70.33 | 62.12 | 62.12 | 5.81 | -0.83 | 5.90 | 67.30 | 3/3 | 3/3 | 55.93 | 68.23 | 8.21 |
| day_of_week=MONDAY & month=7 | 150min | COMPRA | 390 | 175 | 2.52 | nao | 2.29 | 1 | 39.92 | 32.29 | 32.29 | 4.47 | -2.26 | 4.79 | 59.43 | 3/3 | 3/3 | 30.96 | 33.62 | 7.63 |
| day_of_week=MONDAY & month=7 | 90min | COMPRA | 412 | 183 | 2.16 | nao | 2.29 | 1 | 25.25 | 17.88 | 17.88 | 3.22 | -4.26 | 3.99 | 56.83 | 3/3 | 3/3 | 17.45 | 18.31 | 7.37 |
| mtf_D1=BREAK_UP & pcum10=Q5 | 90min | VENDA | 233 | 276 | -2.47 | nao | -2.11 | 1 | 20.34 | 9.03 | 17.83 | 3.10 | -7.47 | 4.44 | 52.17 | 3/3 | 15/16 | 24.15 | 11.52 | 2.50 |
| hour=15 & mtf_H1=BULLISH | 45min | COMPRA | 256 | 188 | 2.17 | nao | 2.51 | 1 | 18.33 | 16.64 | 16.64 | 2.84 | -6.04 | 3.90 | 59.57 | 3/3 | 22/32 | 19.38 | 13.89 | 1.69 |
| slot_hhmm=14:30 & mtf_M1=BULLISH | 30min | VENDA | 151 | 87 | -2.05 | nao | -2.69 | 1 | 18.10 | 16.23 | 16.43 | 2.64 | -8.73 | 4.04 | 56.32 | 3/3 | 19/29 | 13.77 | 19.04 | 1.67 |
| day_of_week=FRIDAY & mtf_M30=BREAK_UP | 35min | VENDA | 202 | 139 | -2.28 | nao | -3.00 | 2 | 15.88 | 14.01 | 13.04 | 2.61 | -7.50 | 4.11 | 57.55 | 3/3 | 22/30 | 17.78 | 8.36 | 2.85 |
| day_of_week=FRIDAY & news_state=EVENTS_4_AROUND_60M | 35min | VENDA | 369 | 246 | -2.87 | nao | -4.25 | 1 | 28.50 | 25.36 | 14.16 | 2.58 | -7.50 | 3.99 | 45.53 | 2/3 | 23/33 | 20.10 | 8.23 | 14.34 |
| slot_hhmm=13:00 & news_min_to_next_high=Q1 | 30min | VENDA | 196 | 119 | -2.46 | nao | -2.97 | 1 | 14.62 | 12.74 | 12.67 | 2.37 | -8.73 | 4.01 | 53.78 | 3/3 | 23/32 | 10.85 | 14.46 | 1.95 |
| month=3 & news_min_since_last_high=Q3 | 150min | COMPRA | 240 | 109 | 2.10 | nao | 1.73 | 1 | 29.19 | 17.28 | 17.28 | 2.35 | -2.26 | 2.64 | 56.88 | 3/3 | 3/3 | 30.53 | 4.28 | 11.91 |
| hour=7 & pcum3=Q3 | 35min | COMPRA | 130 | 78 | 2.23 | nao | 2.59 | 1 | 16.44 | 14.53 | 14.53 | 2.26 | -7.06 | 3.34 | 61.54 | 3/3 | 17/27 | 18.07 | 10.99 | 1.91 |
| hour=1 & pcum10=Q4 | 30min | COMPRA | 238 | 150 | 2.15 | nao | 2.68 | 1 | 8.18 | 6.60 | 6.60 | 2.19 | -6.77 | 4.41 | 60.67 | 3/3 | 23/33 | 6.39 | 6.81 | 1.58 |
| mtf_M30=RANGE & news_min_since_last_high=Q5 | 30min | COMPRA | 563 | 386 | 2.24 | nao | 2.34 | 2 | 8.83 | 7.00 | 7.00 | 2.09 | -6.77 | 4.19 | 55.44 | 3/3 | 21/34 | 5.13 | 8.87 | 1.83 |
| mtf_H1=BULLISH & news_min_to_next_high=Q5 | 150min | COMPRA | 618 | 525 | 2.23 | nao | 2.60 | 1 | 20.17 | 8.89 | 8.89 | 2.03 | -2.26 | 2.58 | 57.14 | 2/3 | 26/34 | 1.27 | 16.48 | 11.27 |
| streak_prev=3 & news_min_to_next_high=Q1 | 30min | VENDA | 155 | 98 | -2.63 | nao | -2.05 | 1 | 17.89 | 16.01 | 16.01 | 2.01 | -8.73 | 3.10 | 57.14 | 3/3 | 19/29 | 3.10 | 28.91 | 1.88 |
| mtf_M15=BREAK_UP & streak_prev=4 | 30min | VENDA | 135 | 102 | -2.72 | nao | -3.04 | 1 | 12.35 | 10.45 | 9.65 | 1.96 | -8.73 | 3.72 | 58.82 | 3/3 | 22/30 | 8.00 | 11.29 | 2.71 |
| hour=15 & mtf_D1=BULLISH | 35min | COMPRA | 288 | 192 | 2.16 | nao | 2.17 | 1 | 10.54 | 8.93 | 8.93 | 1.89 | -7.06 | 3.41 | 56.25 | 3/3 | 14/24 | 3.91 | 13.95 | 1.61 |
| hour=15 & mtf_D1=BULLISH | 45min | COMPRA | 288 | 192 | 2.57 | nao | 1.90 | 1 | 11.64 | 10.03 | 10.03 | 1.88 | -6.04 | 3.03 | 55.73 | 3/3 | 14/24 | 7.15 | 12.91 | 1.61 |
| hour=19 & pcum10=Q4 | 45min | VENDA | 176 | 116 | -2.13 | nao | -1.78 | 1 | 10.26 | 8.38 | 8.42 | 1.87 | -8.24 | 3.68 | 53.45 | 3/3 | 23/30 | 16.57 | 0.27 | 1.84 |
| slot_hhmm=01:00 & mtf_M30=BULLISH | 30min | COMPRA | 131 | 101 | 2.45 | nao | 2.76 | 2 | 7.93 | 6.28 | 6.28 | 1.81 | -6.77 | 3.74 | 51.49 | 3/3 | 21/29 | 9.70 | 2.93 | 1.65 |
| slot_hhmm=23:00 & p2=Q5 | 60min | COMPRA | 212 | 139 | 2.35 | nao | 2.06 | 1 | 11.32 | 5.34 | 5.34 | 1.79 | -6.21 | 3.82 | 54.68 | 2/3 | 16/28 | 9.02 | 1.71 | 5.99 |
| day_of_week=FRIDAY & hour=20 | 35min | VENDA | 139 | 113 | -3.91 | sim | -3.96 | 1 | 42.67 | 38.11 | 14.76 | 1.79 | -7.50 | 2.70 | 42.48 | 2/3 | 21/30 | 1.32 | 27.96 | 27.92 |
| day_of_week=FRIDAY & session=NEW_YORK | 35min | VENDA | 687 | 486 | -3.43 | sim | -4.53 | 1 | 16.05 | 13.24 | 5.23 | 1.76 | -7.50 | 4.37 | 46.30 | 3/3 | 18/34 | 7.23 | 3.23 | 10.82 |
| mtf_H1=BEARISH & atr_ratio_prev=Q4 | 150min | COMPRA | 1,042 | 756 | 2.14 | nao | 2.00 | 1 | 20.93 | 7.55 | 7.55 | 1.71 | -2.26 | 2.30 | 54.23 | 2/3 | 22/34 | 0.19 | 14.91 | 13.38 |
| month=5 & news_min_to_next_high=Q1 | 30min | VENDA | 249 | 113 | -2.03 | nao | -1.97 | 1 | 10.42 | 8.63 | 8.63 | 1.67 | -8.73 | 3.36 | 50.44 | 3/3 | 3/3 | 8.10 | 9.14 | 1.79 |

### H1 — modo `open`

- eventos: 33,052 (2021-06-02 a 2026-10-16); descoberta 19,808 (até 2024-08-26), validação 13,221 (a partir de 2024-08-27)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 61,856**; passaram no BH (q=5%) na descoberta: **2,273**; confirmadas na validação: **2,073**
- melhores N da descoberta que repetem na validação: top 100: 100.0%, top 1000: 100.0%, top 10000: 40.2%
- **placebo** (6 deslocamentos): top 100: 13.3% (máx 24.0%), top 1000: 9.0% (máx 12.0%), top 10000: 6.6% (máx 9.0%); BH: média 2.0 (máx 6); confirmadas: média 0.2 (máx 1)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 19,808 | 0.014 | 2.598 | 1.546 |
| 65min bruto | 19,808 | 0.010 | 1.796 | 1.189 |
| 75min bruto | 19,542 | 0.009 | 1.398 | 1.074 |
| 90min bruto | 19,251 | 0.007 | 0.813 | 0.753 |
| 120min bruto | 18,188 | 0.014 | 1.152 | 1.577 |
| 180min bruto | 16,999 | 0.020 | 1.005 | 2.256 |
| 300min bruto | 15,015 | 0.027 | 0.711 | 3.067 |

**H1/open: famílias distintas validadas: 1908; com líquido positivo e significativo na validação (custo realista): 50.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H4=BEARISH & dom_w=d01_07 | 300min | COMPRA | 1,060 | 776 | 2.30 | nao | 2.70 | 1 | 47.49 | 36.03 | 36.03 | 4.72 | -3.24 | 5.38 | 59.54 | 6/6 | 43/59 | 20.33 | 51.72 | 11.46 |
| mtf_H4=BEARISH & dom_w=d01_07 | 180min | COMPRA | 1,186 | 848 | 2.29 | nao | 3.07 | 1 | 29.87 | 19.21 | 19.21 | 3.40 | -3.16 | 4.14 | 55.42 | 6/6 | 43/60 | 10.22 | 28.21 | 10.66 |
| mtf_D1=BEARISH & month=1 | 300min | COMPRA | 612 | 140 | 2.51 | nao | 2.04 | 1 | 55.05 | 45.58 | 45.58 | 3.37 | -3.24 | 3.61 | 60.00 | 5/5 | 5/5 | 49.77 | 41.39 | 9.47 |
| day_of_week=THURSDAY & month=1 | 300min | COMPRA | 218 | 173 | 2.27 | nao | 1.82 | 1 | 42.43 | 34.30 | 34.30 | 2.95 | -3.24 | 3.23 | 55.49 | 5/5 | 5/5 | 54.59 | 14.25 | 8.13 |
| slot_hhmm=10:00 & atr_ratio_prev=Q3 | 120min | COMPRA | 125 | 109 | 2.01 | nao | 2.00 | 2 | 27.55 | 25.72 | 25.72 | 2.77 | -5.54 | 3.36 | 62.39 | 5/6 | 14/19 | 21.85 | 29.52 | 1.83 |
| structure_before=BREAK_UP & dom_w=d22_31 | 75min | VENDA | 351 | 233 | -2.08 | nao | -3.14 | 2 | 22.21 | 19.70 | 17.05 | 2.70 | -7.01 | 3.84 | 57.08 | 6/6 | 39/52 | 17.69 | 16.42 | 5.16 |
| session=LONDON_NY_OVERLAP & news_min_since_last_high=Q5 | 120min | VENDA | 157 | 374 | -2.18 | nao | -2.09 | 1 | 22.21 | 20.22 | 20.37 | 2.65 | -6.93 | 3.62 | 54.01 | 4/4 | 22/30 | 21.07 | 19.68 | 1.83 |
| day_of_week=FRIDAY & session=NEW_YORK | 120min | VENDA | 442 | 342 | -2.87 | nao | -2.12 | 1 | 17.83 | 15.87 | 15.95 | 2.60 | -6.93 | 3.77 | 57.31 | 6/6 | 45/65 | 9.66 | 22.24 | 1.89 |
| structure_before=BREAK_UP & dom_w=d22_31 | 90min | VENDA | 350 | 233 | -2.45 | nao | -2.92 | 2 | 23.73 | 21.22 | 17.03 | 2.51 | -7.85 | 3.69 | 57.08 | 6/6 | 38/52 | 13.23 | 20.79 | 6.71 |
| structure_before=BREAK_UP & dom_w=d22_31 | 65min | VENDA | 351 | 233 | -2.28 | nao | -3.33 | 2 | 19.61 | 17.10 | 15.03 | 2.49 | -6.77 | 3.64 | 54.51 | 6/6 | 38/52 | 16.01 | 14.05 | 4.58 |
| mtf_M5=BREAK_UP & p1=Q5 | 65min | VENDA | 857 | 571 | -2.41 | nao | -3.20 | 1 | 14.22 | 12.07 | 9.65 | 2.41 | -6.77 | 4.19 | 51.84 | 5/6 | 43/65 | 8.74 | 10.57 | 4.56 |
| mtf_M30=BREAK_UP & p2=Q5 | 90min | VENDA | 510 | 310 | -2.19 | nao | -2.37 | 1 | 16.16 | 14.05 | 13.75 | 2.36 | -7.85 | 3.75 | 55.48 | 6/6 | 40/64 | 1.99 | 25.51 | 2.41 |
| news_min_to_next_high=Q1 & news_min_since_last_high=Q5 | 90min | VENDA | 279 | 695 | -2.28 | nao | -2.04 | 1 | 14.63 | 12.66 | 12.70 | 2.35 | -7.85 | 3.96 | 52.09 | 4/4 | 27/37 | 21.02 | 4.40 | 1.93 |
| mtf_D1=BEARISH & month=1 | 180min | COMPRA | 689 | 154 | 2.48 | nao | 2.06 | 1 | 32.21 | 23.40 | 23.40 | 2.30 | -3.16 | 2.62 | 56.49 | 5/5 | 5/5 | 25.61 | 21.18 | 8.82 |
| mtf_M30=BREAK_UP & p2=Q5 | 65min | VENDA | 513 | 311 | -2.25 | nao | -2.76 | 1 | 13.03 | 10.92 | 10.79 | 2.17 | -6.77 | 3.56 | 55.31 | 6/6 | 44/64 | 3.80 | 17.74 | 2.24 |
| mtf_M5=BREAK_UP & p1=Q5 | 75min | VENDA | 853 | 569 | -2.35 | nao | -2.63 | 1 | 13.26 | 11.11 | 9.22 | 2.16 | -7.01 | 3.89 | 50.62 | 6/6 | 43/65 | 11.52 | 6.92 | 4.04 |
| day_of_week=FRIDAY & session=NEW_YORK | 65min | VENDA | 625 | 459 | -4.94 | sim | -5.15 | 1 | 25.12 | 23.07 | 9.74 | 2.14 | -6.77 | 3.70 | 53.81 | 5/6 | 40/65 | 1.89 | 17.55 | 15.38 |
| session=LONDON_NY_OVERLAP & news_min_since_last_high=Q5 | 90min | VENDA | 157 | 374 | -2.06 | nao | -2.18 | 1 | 17.33 | 15.34 | 15.44 | 2.13 | -7.85 | 3.28 | 50.53 | 3/4 | 18/30 | 14.60 | 16.27 | 1.89 |
| mtf_M1=BREAK_DOWN & mtf_M5=BREAK_DOWN | 90min | COMPRA | 447 | 294 | 2.19 | nao | 4.23 | 1 | 31.32 | 12.67 | 12.67 | 2.13 | -6.60 | 3.26 | 51.02 | 5/6 | 41/64 | 3.62 | 21.72 | 18.65 |
| hour=20 & pcum10=Q5 | 65min | VENDA | 155 | 116 | -6.24 | sim | -7.35 | 2 | 76.70 | 74.83 | 20.96 | 2.12 | -6.77 | 2.81 | 46.55 | 3/6 | 12/22 | 35.09 | 6.83 | 55.73 |
| hour=23 & mtf_M15=RANGE | 65min | COMPRA | 244 | 199 | 2.85 | nao | 4.81 | 2 | 24.25 | 9.03 | 9.03 | 2.11 | -6.67 | 3.65 | 56.28 | 3/6 | 31/55 | 12.49 | 5.61 | 15.21 |
| day_of_week=FRIDAY & p1=Q4 | 75min | VENDA | 673 | 487 | -2.25 | nao | -2.75 | 1 | 14.56 | 12.60 | 9.74 | 2.10 | -7.01 | 3.68 | 50.31 | 6/6 | 43/65 | 15.22 | 4.27 | 4.82 |
| dom_w=d22_31 & range_atr_prev=Q1 | 180min | COMPRA | 841 | 498 | 2.33 | nao | 3.02 | 1 | 24.93 | 9.60 | 9.60 | 2.09 | -3.16 | 2.78 | 50.40 | 3/6 | 30/64 | 11.23 | 7.98 | 15.33 |
| slot_hhmm=23:00 & mtf_M15=RANGE | 60min | COMPRA | 244 | 199 | 3.76 | sim | 5.37 | 2 | 23.50 | 8.28 | 8.28 | 2.04 | -6.25 | 3.56 | 51.76 | 3/6 | 34/55 | 14.54 | 2.09 | 15.21 |
| mtf_M1=BREAK_DOWN & p1=Q1 | 90min | COMPRA | 472 | 300 | 2.21 | nao | 3.02 | 1 | 24.96 | 12.94 | 12.94 | 2.04 | -6.60 | 3.11 | 52.33 | 6/6 | 44/64 | 13.55 | 12.33 | 12.03 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **7999**
- com líquido positivo e t>1,645 na validação, custo realista: **130**; dessas, sobreviveram ao BH: **12**; e positivas nas duas metades da validação: **12**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | open | slot_hhmm=12:05 | 5min | COMPRA | 148 | 5.36 | -6.71 | 6.57 | 2.93 | 62.16 | 2/2 | 13/18 |
| M5 | open | slot_hhmm=12:05 & news_min_to_next_high=Q1 | 5min | COMPRA | 100 | 5.49 | -6.71 | 5.72 | 2.59 | 63.00 | 2/2 | 12/17 |
| M15 | open | hour=15 & pcum3=Q3 | 20min | COMPRA | 200 | 10.25 | -6.95 | 4.32 | 2.57 | 59.00 | 3/3 | 27/33 |
| M15 | open | hour=15 & pcum3=Q3 | 15min | COMPRA | 200 | 8.79 | -6.87 | 4.00 | 2.24 | 57.50 | 3/3 | 22/33 |
| H1 | open | day_of_week=FRIDAY & session=NEW_YORK | 65min | VENDA | 459 | 9.74 | -6.77 | 3.70 | 2.14 | 53.81 | 5/6 | 40/65 |
| H1 | open | hour=20 & pcum10=Q5 | 65min | VENDA | 116 | 20.96 | -6.77 | 2.81 | 2.12 | 46.55 | 3/6 | 12/22 |
| H1 | open | slot_hhmm=23:00 & mtf_M15=RANGE | 60min | COMPRA | 199 | 8.28 | -6.25 | 3.56 | 2.04 | 51.76 | 3/6 | 34/55 |
| H1 | open | hour=20 & mtf_M30=BULLISH | 65min | VENDA | 207 | 13.37 | -6.77 | 2.88 | 1.90 | 48.79 | 4/6 | 27/49 |
| H1 | open | hour=20 & mtf_M15=BULLISH | 65min | VENDA | 190 | 13.20 | -6.77 | 2.74 | 1.80 | 50.53 | 4/6 | 17/43 |
| M30 | open | day_of_week=FRIDAY & hour=20 | 35min | VENDA | 113 | 14.76 | -7.50 | 2.70 | 1.79 | 42.48 | 2/3 | 21/30 |
| M30 | open | day_of_week=FRIDAY & session=NEW_YORK | 35min | VENDA | 486 | 5.23 | -7.50 | 4.37 | 1.76 | 46.30 | 3/3 | 18/34 |
| H1 | open | mtf_M30=BREAK_UP & pcum10=Q5 | 65min | VENDA | 534 | 6.64 | -6.77 | 3.50 | 1.70 | 55.81 | 6/6 | 43/65 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 646s)_
