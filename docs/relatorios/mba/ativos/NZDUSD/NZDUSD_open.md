# NZDUSD — relatório completo MBA (gerado em 2026-10-17 02:27)

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
| M5 | open | 106,047 | 72,050 | 105 | 73 | 0.2 | 0.0 | 0 | 68.0 | 5.2 |
| M15 | open | 67,132 | 78,201 | 1,297 | 849 | 1.5 | 0.0 | 0 | 87.0 | 11.7 |
| M30 | open | 33,093 | 61,364 | 1,270 | 904 | 3.8 | 0.3 | 1 | 94.0 | 18.7 |
| H1 | open | 31,456 | 60,826 | 1,997 | 1,752 | 7.8 | 1.0 | 4 | 100.0 | 13.5 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 106,047 (2025-05-15 a 2026-10-16); descoberta 63,340 (até 2026-03-24), validação 42,419 (a partir de 2026-03-25)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 72,050**; passaram no BH (q=5%) na descoberta: **105**; confirmadas na validação: **73**
- melhores N da descoberta que repetem na validação: top 100: 68.0%, top 1000: 37.2%, top 10000: 14.8%
- **placebo** (6 deslocamentos): top 100: 5.2% (máx 10.0%), top 1000: 4.3% (máx 7.2%), top 10000: 3.1% (máx 4.2%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,327 | -0.001 | -0.298 | -0.020 |
| 10min bruto | 63,327 | -0.000 | -0.003 | -0.000 |
| 20min bruto | 62,994 | 0.004 | 0.347 | 0.095 |
| 35min bruto | 62,512 | 0.007 | 0.332 | 0.163 |
| 65min bruto | 61,561 | 0.011 | 0.275 | 0.261 |
| 125min bruto | 59,686 | -0.004 | -0.050 | -0.098 |
| 245min bruto | 55,981 | -0.043 | -0.256 | -1.025 |

**M5/open: famílias distintas validadas: 483; com líquido positivo e significativo na validação (custo realista): 22.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hour=13 & news_min_to_next_high=Q1 | 65min | COMPRA | 1,346 | 760 | 2.45 | nao | 1.86 | 1 | 19.82 | 16.55 | 16.55 | 5.28 | -6.10 | 7.31 | 57.89 | 2/2 | 12/18 | 19.94 | 13.16 | 3.26 |
| session=LONDON_NY_OVERLAP & news_min_to_next_high=Q1 | 65min | COMPRA | 3,505 | 1,606 | 2.52 | nao | 1.84 | 1 | 12.48 | 9.26 | 9.26 | 4.54 | -6.10 | 7.73 | 51.93 | 2/2 | 12/18 | 14.48 | 4.03 | 3.23 |
| hour=22 & mtf_W1=BULLISH | 65min | COMPRA | 1,040 | 216 | 3.08 | nao | 1.75 | 1 | 23.68 | 15.94 | 15.94 | 4.46 | -6.10 | 6.16 | 65.28 | 1/2 | 5/8 | 5.38 | 26.51 | 7.74 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 35min | COMPRA | 223 | 111 | 2.78 | nao | 1.96 | 1 | 27.53 | 24.27 | 24.27 | 4.27 | -6.20 | 5.35 | 64.86 | 2/2 | 11/14 | 23.00 | 25.51 | 3.27 |
| hour=22 & mtf_M15=BEARISH | 65min | COMPRA | 1,053 | 774 | 2.17 | nao | 1.95 | 1 | 16.19 | 7.54 | 7.54 | 4.16 | -6.10 | 7.54 | 51.29 | 0/2 | 8/18 | 9.45 | 5.63 | 8.65 |
| hour=22 & mtf_M15=BEARISH | 35min | COMPRA | 1,053 | 777 | 2.88 | nao | 3.29 | 1 | 13.81 | 5.16 | 5.16 | 3.60 | -6.20 | 7.97 | 50.84 | 0/2 | 8/18 | 7.38 | 2.94 | 8.65 |
| hour=22 & mtf_W1=BULLISH | 35min | COMPRA | 1,044 | 216 | 3.89 | nao | 2.27 | 1 | 18.76 | 11.02 | 11.02 | 3.40 | -6.20 | 5.31 | 58.33 | 1/2 | 4/8 | 6.15 | 15.89 | 7.74 |
| session=OFF_SESSION & atr_ratio_prev=Q5 | 65min | COMPRA | 1,754 | 1,141 | 2.90 | nao | 2.24 | 1 | 16.60 | 7.91 | 7.91 | 3.39 | -6.10 | 6.12 | 50.57 | 0/2 | 9/18 | 15.08 | 0.76 | 8.69 |
| hour=22 & atr_ratio_prev=Q5 | 65min | COMPRA | 1,248 | 1,035 | 3.51 | nao | 2.10 | 1 | 17.35 | 8.16 | 8.16 | 3.34 | -6.10 | 5.93 | 49.37 | 0/2 | 9/18 | 15.41 | 0.92 | 9.19 |
| mtf_D1=BEARISH & news_state=EVENTS_4_AROUND_60M | 35min | VENDA | 564 | 335 | -2.09 | nao | -2.08 | 1 | 23.25 | 18.57 | 13.30 | 3.32 | -6.10 | 4.86 | 51.34 | 2/2 | 8/14 | 23.11 | 3.55 | 9.95 |
| hour=22 & news_min_since_last_high=Q2 | 20min | COMPRA | 676 | 237 | 2.26 | nao | 3.50 | 1 | 12.61 | 4.50 | 4.50 | 2.67 | -6.39 | 6.45 | 57.38 | 0/2 | 9/18 | 2.14 | 6.83 | 8.11 |
| hour=22 & pcum10=Q1 | 35min | COMPRA | 355 | 43 | 4.00 | sim | 1.73 | 1 | 17.40 | 10.28 | 10.28 | 2.50 | -6.20 | 3.96 | 58.14 | 0/2 | 2/10 | 28.15 | -6.78 | 7.12 |
| news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 20min | COMPRA | 223 | 111 | 2.61 | nao | 1.83 | 1 | 14.10 | 10.83 | 10.83 | 2.49 | -6.39 | 3.95 | 56.76 | 2/2 | 11/14 | 8.37 | 13.26 | 3.27 |
| hour=22 & mtf_D1=BULLISH | 65min | COMPRA | 636 | 580 | 2.22 | nao | 1.73 | 1 | 13.46 | 5.88 | 5.88 | 2.46 | -6.10 | 5.04 | 54.14 | 0/2 | 7/11 | 18.12 | -6.37 | 7.58 |
| hour=22 & mtf_H1=BULLISH | 35min | COMPRA | 948 | 564 | 4.37 | sim | 1.84 | 1 | 14.53 | 7.08 | 7.08 | 2.43 | -6.20 | 4.60 | 42.55 | 0/2 | 7/18 | 21.93 | -7.76 | 7.45 |
| hour=22 & atr_ratio_prev=Q5 | 35min | COMPRA | 1,248 | 1,043 | 4.10 | sim | 3.11 | 1 | 13.22 | 4.03 | 4.03 | 2.36 | -6.20 | 6.07 | 47.36 | 0/2 | 7/18 | 8.18 | -0.11 | 9.19 |
| hour=22 & pcum10=Q1 | 20min | COMPRA | 355 | 43 | 4.10 | sim | 2.44 | 1 | 14.44 | 7.32 | 7.32 | 2.13 | -6.39 | 3.94 | 58.14 | 0/2 | 2/10 | 21.39 | -6.10 | 7.12 |
| session=OFF_SESSION & atr_ratio_prev=Q5 | 35min | COMPRA | 1,754 | 1,149 | 4.06 | sim | 2.93 | 1 | 12.03 | 3.34 | 3.34 | 2.04 | -6.20 | 5.93 | 47.43 | 0/2 | 8/18 | 7.45 | -0.76 | 8.70 |
| session=LONDON_NY_OVERLAP & news_min_to_next_high=Q1 | 35min | COMPRA | 3,505 | 1,606 | 2.27 | nao | 1.68 | 1 | 6.17 | 2.94 | 2.94 | 1.97 | -6.20 | 6.27 | 49.75 | 2/2 | 10/18 | 4.92 | 0.96 | 3.23 |
| hour=22 & structure_before=BEARISH | 35min | COMPRA | 804 | 183 | 5.12 | sim | 2.64 | 2 | 20.76 | 5.14 | 5.14 | 1.95 | -6.20 | 4.28 | 57.92 | 0/2 | 11/18 | 7.94 | 2.38 | 15.62 |
| hour=22 & dom_w=d08_14 | 20min | COMPRA | 600 | 417 | 2.10 | nao | 2.93 | 1 | 11.60 | 3.87 | 3.87 | 1.77 | -6.39 | 4.73 | 48.20 | 0/2 | 5/17 | 8.03 | -0.28 | 7.73 |
| hour=22 & mtf_D1=BULLISH | 35min | COMPRA | 636 | 588 | 2.51 | nao | 2.29 | 1 | 10.77 | 3.16 | 3.16 | 1.73 | -6.20 | 5.15 | 47.45 | 0/2 | 5/11 | 10.45 | -4.14 | 7.62 |

### M15 — modo `open`

- eventos: 67,132 (2024-01-22 a 2026-10-16); descoberta 40,184 (até 2025-09-15), validação 26,853 (a partir de 2025-09-16)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 78,201**; passaram no BH (q=5%) na descoberta: **1,297**; confirmadas na validação: **849**
- melhores N da descoberta que repetem na validação: top 100: 87.0%, top 1000: 70.1%, top 10000: 22.9%
- **placebo** (6 deslocamentos): top 100: 11.7% (máx 21.0%), top 1000: 9.1% (máx 13.9%), top 10000: 6.5% (máx 8.1%); BH: média 1.5 (máx 7); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 40,171 | 0.013 | 3.655 | 0.553 |
| 20min bruto | 40,171 | 0.020 | 3.993 | 0.886 |
| 30min bruto | 39,384 | 0.019 | 2.551 | 0.836 |
| 45min bruto | 38,430 | 0.022 | 1.899 | 0.981 |
| 75min bruto | 36,677 | 0.024 | 1.147 | 1.060 |
| 135min bruto | 33,753 | 0.018 | 0.428 | 0.772 |
| 255min bruto | 29,879 | -0.003 | -0.037 | -0.137 |

**M15/open: famílias distintas validadas: 1535; com líquido positivo e significativo na validação (custo realista): 18.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | 135min | COMPRA | 374 | 376 | 2.07 | nao | 1.96 | 1 | 26.65 | 19.80 | 19.80 | 4.18 | -6.24 | 5.52 | 55.32 | 2/3 | 7/9 | 28.67 | 10.93 | 6.85 |
| slot_hhmm=14:00 & mtf_H4=BULLISH | 30min | COMPRA | 129 | 85 | 2.13 | nao | 3.07 | 1 | 24.88 | 21.65 | 21.65 | 3.73 | -6.32 | 4.80 | 64.71 | 3/3 | 19/23 | 14.59 | 28.56 | 3.23 |
| day_of_week=SUNDAY & session=OFF_SESSION | 135min | COMPRA | 671 | 448 | 2.07 | nao | 2.39 | 1 | 36.26 | 13.53 | 13.53 | 3.22 | -6.24 | 4.74 | 55.36 | 2/3 | 19/34 | 19.56 | 7.50 | 22.73 |
| hour=13 & news_state=EVENTS_2_AROUND_60M | 45min | COMPRA | 178 | 125 | 2.39 | nao | 1.97 | 1 | 18.14 | 14.87 | 14.87 | 2.62 | -6.15 | 3.70 | 56.80 | 3/3 | 18/27 | 12.93 | 16.77 | 3.27 |
| slot_hhmm=23:00 & streak_prev=-1 | 20min | COMPRA | 136 | 83 | 2.89 | nao | 4.04 | 1 | 17.28 | 9.41 | 9.41 | 2.56 | -5.97 | 4.16 | 66.27 | 2/3 | 16/25 | 14.33 | 4.61 | 7.87 |
| mtf_D1=BEARISH & month=3 | 135min | VENDA | 565 | 1,593 | -2.16 | nao | -2.12 | 1 | 15.42 | 8.62 | 9.37 | 2.55 | -6.00 | 4.40 | 53.92 | 2/2 | 2/2 | 10.62 | 8.11 | 6.05 |
| slot_hhmm=23:00 & streak_prev=-1 | 15min | COMPRA | 136 | 83 | 2.31 | nao | 4.62 | 1 | 17.06 | 9.19 | 9.19 | 2.49 | -6.38 | 4.20 | 63.86 | 2/3 | 12/25 | 15.31 | 3.23 | 7.87 |
| hour=22 & month=4 | 20min | COMPRA | 176 | 88 | 2.56 | nao | 3.54 | 1 | 25.39 | 16.49 | 16.49 | 2.36 | -5.97 | 3.21 | 54.55 | 2/3 | 2/3 | 14.69 | 18.28 | 8.90 |
| session=OFF_SESSION & month=4 | 20min | COMPRA | 352 | 176 | 2.13 | nao | 3.28 | 1 | 15.03 | 8.71 | 8.71 | 2.23 | -5.97 | 3.77 | 50.57 | 1/3 | 1/3 | 9.96 | 7.46 | 6.31 |
| slot_hhmm=14:15 & mtf_H4=BULLISH | 15min | COMPRA | 130 | 85 | 4.12 | sim | 3.17 | 1 | 12.02 | 8.79 | 8.79 | 2.19 | -6.38 | 3.77 | 62.35 | 3/3 | 19/24 | 6.25 | 11.26 | 3.24 |
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | 75min | COMPRA | 416 | 380 | 2.17 | nao | 1.96 | 1 | 14.57 | 7.74 | 7.74 | 2.09 | -5.99 | 3.74 | 53.68 | 2/3 | 7/9 | 13.32 | 2.16 | 6.83 |
| slot_hhmm=23:00 & streak_prev=-1 | 30min | COMPRA | 135 | 83 | 2.49 | nao | 2.75 | 1 | 15.63 | 7.76 | 7.76 | 2.08 | -6.32 | 3.76 | 66.27 | 3/3 | 15/25 | 11.09 | 4.51 | 7.87 |
| hour=10 & news_min_since_last_high=Q4 | 45min | VENDA | 193 | 113 | -2.76 | nao | -1.90 | 1 | 11.81 | 8.53 | 8.54 | 2.02 | -6.50 | 3.54 | 60.18 | 3/3 | 22/28 | 14.46 | 2.71 | 3.27 |
| slot_hhmm=14:45 & mtf_M15=BEARISH | 15min | COMPRA | 121 | 85 | 2.03 | nao | 2.80 | 2 | 10.13 | 6.94 | 6.94 | 1.91 | -6.38 | 3.65 | 56.47 | 2/3 | 15/22 | 10.97 | 3.00 | 3.19 |
| slot_hhmm=09:45 & atr_ratio_prev=Q3 | 20min | VENDA | 122 | 91 | -2.18 | nao | -2.39 | 1 | 9.18 | 5.93 | 5.89 | 1.83 | -7.25 | 4.06 | 50.55 | 3/3 | 15/27 | 4.13 | 7.61 | 3.29 |
| slot_hhmm=14:15 & mtf_H4=BULLISH | 20min | COMPRA | 130 | 85 | 3.44 | sim | 1.96 | 1 | 11.93 | 8.69 | 8.69 | 1.82 | -5.97 | 3.06 | 52.94 | 3/3 | 21/24 | 7.85 | 9.52 | 3.24 |
| slot_hhmm=23:00 & mtf_W1=BULLISH | 20min | COMPRA | 149 | 45 | 2.13 | nao | 3.14 | 1 | 16.82 | 7.94 | 7.94 | 1.75 | -5.97 | 3.04 | 68.89 | 2/3 | 8/15 | 21.88 | -5.39 | 8.88 |
| hour=10 & news_min_since_last_high=Q4 | 30min | VENDA | 193 | 113 | -2.94 | nao | -2.03 | 1 | 8.90 | 5.63 | 5.63 | 1.74 | -6.75 | 3.80 | 58.41 | 3/3 | 21/28 | 10.24 | 1.10 | 3.27 |

### M30 — modo `open`

- eventos: 33,093 (2024-01-22 a 2026-10-16); descoberta 19,808 (até 2025-09-18), validação 13,238 (a partir de 2025-09-19)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 61,364**; passaram no BH (q=5%) na descoberta: **1,270**; confirmadas na validação: **904**
- melhores N da descoberta que repetem na validação: top 100: 94.0%, top 1000: 77.1%, top 10000: 21.2%
- **placebo** (6 deslocamentos): top 100: 18.7% (máx 24.0%), top 1000: 13.8% (máx 15.7%), top 10000: 9.2% (máx 10.3%); BH: média 3.8 (máx 18); confirmadas: média 0.3 (máx 1)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 19,795 | 0.015 | 3.040 | 0.951 |
| 35min bruto | 19,795 | 0.023 | 3.560 | 1.438 |
| 45min bruto | 19,734 | 0.026 | 3.179 | 1.642 |
| 60min bruto | 19,019 | 0.019 | 1.788 | 1.223 |
| 90min bruto | 18,177 | 0.019 | 1.131 | 1.234 |
| 150min bruto | 16,835 | 0.012 | 0.401 | 0.788 |
| 270min bruto | 14,919 | -0.001 | -0.023 | -0.090 |

**M30/open: famílias distintas validadas: 1407; com líquido positivo e significativo na validação (custo realista): 20.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| slot_hhmm=14:00 & mtf_H4=BULLISH | 30min | COMPRA | 133 | 83 | 3.24 | nao | 4.19 | 1 | 25.02 | 21.80 | 21.80 | 3.68 | -5.85 | 4.66 | 65.06 | 3/3 | 19/24 | 16.46 | 27.01 | 3.23 |
| slot_hhmm=14:00 & mtf_H4=BULLISH | 35min | COMPRA | 133 | 83 | 2.97 | nao | 3.67 | 1 | 25.73 | 22.51 | 22.51 | 3.54 | -5.18 | 4.34 | 63.86 | 3/3 | 20/24 | 22.02 | 22.98 | 3.23 |
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | 150min | COMPRA | 185 | 188 | 2.01 | nao | 1.83 | 1 | 30.56 | 23.66 | 23.66 | 3.39 | -5.69 | 4.23 | 55.85 | 2/3 | 8/9 | 34.11 | 13.21 | 6.91 |
| slot_hhmm=14:00 & news_min_to_next_high=Q1 | 35min | COMPRA | 207 | 128 | 2.16 | nao | 3.42 | 1 | 20.04 | 16.81 | 16.81 | 3.13 | -5.18 | 4.10 | 60.16 | 2/3 | 23/33 | 14.59 | 19.03 | 3.23 |
| day_of_week=SUNDAY & session=OFF_SESSION | 150min | COMPRA | 339 | 224 | 2.12 | nao | 2.29 | 1 | 43.66 | 19.30 | 19.30 | 3.02 | -5.69 | 3.93 | 54.02 | 2/3 | 19/33 | 27.58 | 11.02 | 24.36 |
| mtf_H4=BREAK_UP & mtf_W1=BEARISH | 270min | COMPRA | 270 | 369 | 2.61 | nao | 1.69 | 1 | 25.07 | 19.50 | 19.50 | 2.97 | -6.15 | 3.96 | 53.12 | 3/3 | 7/13 | -5.85 | 44.72 | 5.57 |
| slot_hhmm=14:00 & mtf_H4=BULLISH | 45min | COMPRA | 133 | 83 | 2.69 | nao | 2.51 | 1 | 24.61 | 21.39 | 21.39 | 2.94 | -5.09 | 3.63 | 59.04 | 3/3 | 17/24 | 22.38 | 20.41 | 3.23 |
| slot_hhmm=14:00 & mtf_W1=BULLISH | 30min | COMPRA | 150 | 45 | 2.04 | nao | 3.33 | 1 | 31.67 | 28.44 | 28.44 | 2.82 | -5.85 | 3.37 | 68.89 | 2/3 | 9/15 | 5.96 | 49.93 | 3.23 |
| month=5 & news_min_to_next_high=Q1 | 45min | COMPRA | 247 | 113 | 2.41 | nao | 2.60 | 1 | 16.62 | 13.35 | 13.35 | 2.30 | -5.09 | 3.17 | 57.52 | 3/3 | 3/3 | 8.54 | 18.09 | 3.27 |
| hour=14 & news_min_to_next_high=Q1 | 30min | COMPRA | 367 | 232 | 2.38 | nao | 3.00 | 1 | 11.53 | 8.31 | 8.31 | 2.15 | -5.85 | 3.70 | 52.59 | 2/3 | 23/34 | 6.38 | 10.25 | 3.22 |
| mtf_D1=BREAK_DOWN & dom_w=d01_07 | 90min | COMPRA | 205 | 190 | 2.11 | nao | 1.74 | 1 | 18.57 | 11.68 | 11.68 | 2.09 | -5.59 | 3.11 | 55.79 | 2/3 | 7/9 | 18.27 | 5.09 | 6.88 |
| month=5 & news_min_to_next_high=Q1 | 35min | COMPRA | 247 | 113 | 2.03 | nao | 2.67 | 1 | 14.10 | 10.83 | 10.83 | 2.09 | -5.18 | 3.09 | 54.87 | 2/3 | 2/3 | 6.52 | 15.07 | 3.27 |
| session=OFF_SESSION & month=4 | 45min | COMPRA | 176 | 88 | 2.43 | nao | 2.14 | 1 | 26.33 | 18.94 | 18.94 | 2.01 | -5.09 | 2.54 | 60.23 | 2/3 | 2/3 | 22.48 | 15.40 | 7.39 |
| mtf_D1=BEARISH & month=3 | 150min | VENDA | 276 | 797 | -2.06 | nao | -2.11 | 1 | 17.23 | 10.41 | 10.82 | 1.99 | -7.14 | 3.48 | 53.58 | 2/2 | 2/2 | 12.29 | 9.35 | 6.41 |
| day_of_week=TUESDAY & hour=0 | 35min | VENDA | 174 | 112 | -2.28 | nao | -2.60 | 1 | 12.51 | 8.98 | 9.02 | 1.97 | -7.65 | 3.64 | 58.04 | 3/3 | 20/32 | 7.13 | 10.90 | 3.49 |
| session=OFF_SESSION & month=4 | 35min | COMPRA | 176 | 88 | 2.52 | nao | 2.64 | 1 | 24.26 | 16.87 | 16.87 | 1.96 | -5.18 | 2.56 | 61.36 | 2/3 | 2/3 | 18.62 | 15.13 | 7.39 |
| news_min_to_next_high=Q4 & news_min_since_last_high=Q2 | 270min | COMPRA | 459 | 346 | 2.30 | nao | 1.76 | 1 | 43.24 | 13.66 | 13.66 | 1.73 | -6.15 | 2.55 | 54.91 | 3/3 | 21/34 | -0.38 | 27.70 | 29.58 |
| mtf_H1=BREAK_DOWN & news_min_since_last_high=Q5 | 35min | COMPRA | 148 | 88 | 2.08 | nao | 2.07 | 1 | 14.88 | 11.60 | 11.60 | 1.72 | -5.18 | 2.49 | 59.09 | 3/3 | 12/24 | 14.64 | 8.56 | 3.28 |
| mtf_D1=BULLISH & news_min_to_next_high=Q1 | 35min | COMPRA | 692 | 452 | 2.78 | nao | 3.01 | 1 | 8.69 | 5.07 | 5.07 | 1.69 | -5.18 | 3.49 | 50.22 | 3/3 | 13/21 | 0.81 | 9.34 | 3.61 |
| day_of_week=SUNDAY & mtf_H1=BULLISH | 150min | COMPRA | 150 | 82 | 3.13 | nao | 2.54 | 1 | 62.99 | 15.38 | 15.38 | 1.65 | -5.69 | 2.26 | 51.22 | 3/3 | 13/21 | 19.07 | 11.69 | 47.61 |

### H1 — modo `open`

- eventos: 31,456 (2021-06-01 a 2026-10-16); descoberta 18,851 (até 2024-09-03), validação 12,583 (a partir de 2024-09-04)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 60,826**; passaram no BH (q=5%) na descoberta: **1,997**; confirmadas na validação: **1,752**
- melhores N da descoberta que repetem na validação: top 100: 100.0%, top 1000: 97.0%, top 10000: 34.9%
- **placebo** (6 deslocamentos): top 100: 13.5% (máx 19.0%), top 1000: 12.7% (máx 16.3%), top 10000: 8.9% (máx 11.0%); BH: média 7.8 (máx 36); confirmadas: média 1.0 (máx 4)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 18,851 | 0.010 | 1.967 | 1.073 |
| 65min bruto | 18,851 | 0.015 | 2.671 | 1.640 |
| 75min bruto | 18,718 | 0.016 | 2.415 | 1.723 |
| 90min bruto | 18,641 | 0.017 | 2.202 | 1.861 |
| 120min bruto | 17,553 | 0.014 | 1.279 | 1.547 |
| 180min bruto | 16,374 | 0.009 | 0.504 | 0.980 |
| 300min bruto | 14,472 | -0.005 | -0.140 | -0.502 |

**H1/open: famílias distintas validadas: 1741; com líquido positivo e significativo na validação (custo realista): 40.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=SUNDAY & mtf_H1=BULLISH | 180min | COMPRA | 152 | 82 | 3.24 | sim | 4.57 | 2 | 90.84 | 36.03 | 36.03 | 3.16 | -6.19 | 3.69 | 62.20 | 5/6 | 7/17 | 49.20 | 22.87 | 54.81 |
| session=OFF_SESSION & month=7 | 65min | COMPRA | 174 | 92 | 2.25 | nao | 3.85 | 1 | 25.22 | 14.79 | 14.79 | 2.64 | -5.19 | 3.54 | 60.87 | 5/6 | 5/6 | 19.62 | 9.96 | 10.43 |
| day_of_week=FRIDAY & month=4 | 180min | VENDA | 205 | 149 | -3.22 | sim | -1.67 | 1 | 46.16 | 42.61 | 39.99 | 2.61 | -7.94 | 3.15 | 53.69 | 5/5 | 5/5 | 78.53 | 1.97 | 6.17 |
| session=OFF_SESSION & range_atr_prev=Q5 | 65min | COMPRA | 238 | 377 | 5.71 | sim | 7.66 | 1 | 28.02 | 9.82 | 9.82 | 2.55 | -5.19 | 3.95 | 57.29 | 4/6 | 30/49 | 9.13 | 10.50 | 18.20 |
| session=OFF_SESSION & range_atr_prev=Q5 | 75min | COMPRA | 237 | 376 | 4.76 | sim | 6.80 | 1 | 27.55 | 9.54 | 9.54 | 2.41 | -4.45 | 3.58 | 57.98 | 4/6 | 33/49 | 7.61 | 11.47 | 18.01 |
| session=OFF_SESSION & month=7 | 75min | COMPRA | 172 | 92 | 2.18 | nao | 3.29 | 1 | 25.42 | 15.00 | 15.00 | 2.41 | -4.45 | 3.10 | 56.52 | 5/6 | 5/6 | 14.33 | 15.66 | 10.43 |
| session=OFF_SESSION & mtf_W1=BULLISH | 65min | COMPRA | 286 | 280 | 8.27 | sim | 6.62 | 1 | 25.38 | 8.78 | 8.78 | 2.41 | -5.19 | 3.84 | 58.93 | 1/5 | 10/21 | 14.44 | 3.11 | 16.60 |
| session=OFF_SESSION & range_atr_prev=Q5 | 90min | COMPRA | 237 | 376 | 3.89 | sim | 5.90 | 1 | 27.61 | 9.61 | 9.61 | 2.27 | -4.42 | 3.35 | 55.59 | 4/6 | 31/49 | 9.06 | 10.15 | 18.01 |
| day_of_week=SUNDAY & streak_prev=1 | 180min | COMPRA | 127 | 92 | 2.44 | nao | 3.17 | 1 | 59.28 | 25.27 | 25.27 | 2.23 | -6.19 | 2.77 | 60.87 | 4/6 | 11/13 | 33.56 | 16.99 | 34.01 |
| slot_hhmm=22:00 & mtf_W1=BULLISH | 90min | COMPRA | 141 | 137 | 6.07 | sim | 5.90 | 2 | 41.57 | 12.98 | 12.98 | 2.22 | -4.42 | 2.97 | 59.12 | 1/5 | 8/20 | 23.32 | 2.79 | 28.59 |
| session=OFF_SESSION & mtf_W1=BULLISH | 90min | COMPRA | 283 | 277 | 5.34 | sim | 4.60 | 1 | 26.58 | 9.86 | 9.86 | 2.21 | -4.42 | 3.22 | 57.40 | 2/5 | 10/21 | 13.31 | 6.44 | 16.71 |
| slot_hhmm=15:00 & pcum3=Q2 | 75min | VENDA | 127 | 103 | -2.18 | nao | -1.81 | 2 | 22.48 | 19.31 | 19.29 | 2.16 | -8.27 | 3.08 | 60.19 | 6/6 | 15/22 | 7.79 | 30.57 | 3.18 |
| hour=9 & range_atr_prev=Q5 | 75min | VENDA | 293 | 118 | -2.08 | nao | -2.39 | 2 | 15.04 | 11.73 | 11.75 | 2.13 | -8.27 | 3.61 | 55.93 | 6/6 | 29/46 | 13.25 | 10.25 | 3.29 |
| hour=22 & mtf_W1=BULLISH | 65min | COMPRA | 143 | 140 | 6.96 | sim | 6.96 | 2 | 39.44 | 11.34 | 11.34 | 2.06 | -5.19 | 3.01 | 62.86 | 1/5 | 7/20 | 22.95 | -0.27 | 28.10 |
| session=OFF_SESSION & mtf_W1=BULLISH | 75min | COMPRA | 284 | 279 | 6.35 | sim | 5.22 | 1 | 24.99 | 8.35 | 8.35 | 2.04 | -4.45 | 3.15 | 55.91 | 2/5 | 11/21 | 11.82 | 4.90 | 16.64 |
| session=OFF_SESSION & range_atr_prev=Q5 | 60min | COMPRA | 238 | 377 | 5.05 | sim | 8.02 | 1 | 25.60 | 7.40 | 7.40 | 2.04 | -6.14 | 3.79 | 57.29 | 4/6 | 31/49 | 6.22 | 8.57 | 18.20 |
| day_of_week=FRIDAY & month=4 | 120min | VENDA | 221 | 157 | -3.21 | sim | -1.72 | 1 | 29.98 | 26.38 | 23.94 | 2.02 | -7.83 | 2.70 | 53.50 | 5/5 | 5/5 | 47.25 | 0.92 | 6.04 |
| news_min_to_next_high=Q4 & news_min_since_last_high=Q2 | 75min | COMPRA | 146 | 354 | 2.24 | nao | 4.81 | 1 | 20.90 | 8.90 | 8.90 | 1.99 | -4.45 | 3.03 | 54.80 | 4/4 | 23/36 | 7.50 | 10.30 | 12.01 |
| mtf_D1=BULLISH & news_min_to_next_high=Q1 | 120min | COMPRA | 179 | 455 | 2.52 | nao | 2.36 | 1 | 14.43 | 10.94 | 10.94 | 1.99 | -6.09 | 3.17 | 55.16 | 4/4 | 16/23 | 10.11 | 11.77 | 3.49 |
| hour=13 & pcum3=Q2 | 65min | COMPRA | 160 | 116 | 2.01 | nao | 2.45 | 2 | 17.58 | 14.30 | 14.30 | 1.99 | -5.19 | 2.71 | 56.03 | 6/6 | 16/26 | 7.92 | 20.69 | 3.27 |
| hour=11 & range_atr_prev=Q2 | 90min | VENDA | 225 | 177 | -2.05 | nao | -2.16 | 2 | 14.08 | 10.83 | 10.75 | 1.98 | -7.77 | 3.42 | 60.45 | 6/6 | 31/50 | 17.60 | 3.97 | 3.33 |
| hour=22 & mtf_W1=BULLISH | 75min | COMPRA | 142 | 139 | 6.57 | sim | 6.29 | 2 | 38.87 | 10.61 | 10.61 | 1.97 | -4.45 | 2.79 | 58.99 | 1/5 | 8/20 | 19.84 | 1.50 | 28.26 |
| mtf_D1=BULLISH & news_min_to_next_high=Q1 | 180min | COMPRA | 147 | 450 | 2.26 | nao | 1.90 | 1 | 16.09 | 12.60 | 12.60 | 1.90 | -6.19 | 2.90 | 54.00 | 4/4 | 17/23 | 17.34 | 7.87 | 3.49 |
| day_of_week=FRIDAY & month=4 | 90min | VENDA | 241 | 161 | -3.05 | nao | -1.69 | 1 | 23.64 | 20.01 | 19.28 | 1.89 | -7.77 | 2.67 | 54.66 | 5/5 | 5/5 | 37.52 | 1.26 | 4.36 |
| slot_hhmm=23:00 & mtf_D1=BULLISH | 65min | COMPRA | 255 | 152 | 3.81 | sim | 3.24 | 2 | 15.93 | 9.17 | 9.17 | 1.86 | -5.19 | 2.91 | 60.53 | 4/6 | 21/39 | 5.34 | 12.99 | 6.76 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **5166**
- com líquido positivo e t>1,645 na validação, custo realista: **100**; dessas, sobreviveram ao BH: **29**; e positivas nas duas metades da validação: **22**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H1 | open | day_of_week=SUNDAY & mtf_H1=BULLISH | 180min | COMPRA | 82 | 36.03 | -6.19 | 3.69 | 3.16 | 62.20 | 5/6 | 7/17 |
| H1 | open | day_of_week=FRIDAY & month=4 | 180min | VENDA | 149 | 39.99 | -7.94 | 3.15 | 2.61 | 53.69 | 5/5 | 5/5 |
| H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 65min | COMPRA | 377 | 9.82 | -5.19 | 3.95 | 2.55 | 57.29 | 4/6 | 30/49 |
| H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 75min | COMPRA | 376 | 9.54 | -4.45 | 3.58 | 2.41 | 57.98 | 4/6 | 33/49 |
| H1 | open | session=OFF_SESSION & mtf_W1=BULLISH | 65min | COMPRA | 280 | 8.78 | -5.19 | 3.84 | 2.41 | 58.93 | 1/5 | 10/21 |
| H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 90min | COMPRA | 376 | 9.61 | -4.42 | 3.35 | 2.27 | 55.59 | 4/6 | 31/49 |
| H1 | open | slot_hhmm=22:00 & mtf_W1=BULLISH | 90min | COMPRA | 137 | 12.98 | -4.42 | 2.97 | 2.22 | 59.12 | 1/5 | 8/20 |
| H1 | open | session=OFF_SESSION & mtf_W1=BULLISH | 90min | COMPRA | 277 | 9.86 | -4.42 | 3.22 | 2.21 | 57.40 | 2/5 | 10/21 |
| M15 | open | slot_hhmm=14:15 & mtf_H4=BULLISH | 15min | COMPRA | 85 | 8.79 | -6.38 | 3.77 | 2.19 | 62.35 | 3/3 | 19/24 |
| H1 | open | session=OFF_SESSION & mtf_W1=BULLISH | 75min | COMPRA | 279 | 8.35 | -4.45 | 3.15 | 2.04 | 55.91 | 2/5 | 11/21 |
| H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 60min | COMPRA | 377 | 7.40 | -6.14 | 3.79 | 2.04 | 57.29 | 4/6 | 31/49 |
| H1 | open | day_of_week=FRIDAY & month=4 | 120min | VENDA | 157 | 23.94 | -7.83 | 2.70 | 2.02 | 53.50 | 5/5 | 5/5 |
| H1 | open | hour=22 & mtf_W1=BULLISH | 75min | COMPRA | 139 | 10.61 | -4.45 | 2.79 | 1.97 | 58.99 | 1/5 | 8/20 |
| M5 | open | hour=22 & structure_before=BEARISH | 35min | COMPRA | 183 | 5.14 | -6.20 | 4.28 | 1.95 | 57.92 | 0/2 | 11/18 |
| H1 | open | slot_hhmm=23:00 & mtf_D1=BULLISH | 65min | COMPRA | 152 | 9.17 | -5.19 | 2.91 | 1.86 | 60.53 | 4/6 | 21/39 |
| H1 | open | mtf_W1=BEARISH & month=5 | 75min | COMPRA | 233 | 8.94 | -4.45 | 2.79 | 1.86 | 52.79 | 4/4 | 4/4 |
| H1 | open | mtf_W1=BEARISH & month=5 | 90min | COMPRA | 233 | 10.00 | -4.42 | 2.68 | 1.85 | 49.36 | 4/4 | 4/4 |
| H1 | open | slot_hhmm=22:00 & range_atr_prev=Q5 | 75min | COMPRA | 249 | 9.29 | -4.45 | 2.72 | 1.83 | 56.63 | 3/6 | 20/30 |
| M15 | open | slot_hhmm=14:15 & mtf_H4=BULLISH | 20min | COMPRA | 85 | 8.69 | -5.97 | 3.06 | 1.82 | 52.94 | 3/3 | 21/24 |
| H1 | open | day_of_week=SUNDAY & structure_before=BULLISH | 120min | COMPRA | 82 | 16.69 | -6.09 | 2.35 | 1.73 | 50.00 | 5/6 | 7/18 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 465s)_
