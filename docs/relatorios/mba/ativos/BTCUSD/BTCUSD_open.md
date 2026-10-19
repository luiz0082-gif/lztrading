# BTCUSD — relatório completo MBA (gerado em 2026-10-17 02:27)

## 1. Identificação

| campo | valor |
|---|---|
| corretora | First Prudential Markets Limited |
| servidor | FPMarketsSC-Demo |
| simbolo | BTCUSD |
| descricao | Bitcoin vs US Dollar |
| digitos | 2 |
| ponto | 0.01000 |
| tick_size | 0.01000 |
| tick_value | 0.01000 |
| contrato | 1.00000 |
| lote_min | 0.01000 |
| swap_long | -20.00000 |
| swap_short | -2.00000 |
| moeda | USD |
| comissao_declarada | 0.00000 |

## 2. Dados, cobertura e qualidade

| TF | candles | inicio | fim | gaps | maior_gap_barras | dup | com_ticks | ohlc_conferidos | ohlc_diff |
|---|---|---|---|---|---|---|---|---|---|
| M1 | 200,001 | 2024-01-22 00:27 | 2026-10-16 23:58 | 43 | 1,159,992 | 0 | 123,605 | 123,605 | 0 |
| M5 | 106,928 | 2025-05-15 03:15 | 2026-10-16 23:50 | 82 | 699 | 0 | 24,723 | 24,723 | 0 |
| M15 | 68,368 | 2024-01-22 05:30 | 2026-10-16 23:30 | 150 | 233 | 0 | 8,243 | 8,243 | 0 |
| M30 | 34,177 | 2024-01-22 11:00 | 2026-10-16 23:00 | 147 | 116 | 0 | 4,122 | 4,122 | 0 |
| H1 | 34,140 | 2021-04-27 00:00 | 2026-10-16 22:00 | 288 | 96 | 0 | 2,061 | 2,061 | 0 |
| H4 | 10,313 | 2020-03-04 20:00 | 2026-10-16 16:00 | 347 | 24 | 0 | 514 | 514 | 0 |
| D1 | 1,700 | 2020-04-01 00:00 | 2026-10-15 00:00 | 343 | 4 | 0 | 84 | 84 | 0 |
| W1 | 323 | 2020-08-02 00:00 | 2026-10-04 00:00 | 0 | 0 | 0 | 16 | 16 | 0 |
| MN1 | 57 | 2022-01-01 00:00 | 2026-09-01 00:00 | 0 | 0 | 0 | 3 | 3 | 0 |

Gaps = barras ausentes dentro da série (fins de semana, feriados e pausas diárias contam). `ohlc_diff` = candles da corretora que diferem do reconstruído pelos ticks (tolerância 1 ponto).

## 3. Custo e microestrutura (base M5)

Hora UTC (convertida pela regra de horário de verão da data de cada vela). `spread_med`/`spread_p90` = campo gravado nas barras (inclui zeros espúrios em contas ECN); `spread_ticks_med` = spread medido nos ticks (últimos ~120 dias); `custo_sobre_ATR` = spread dos ticks (ou da barra se não houver) / ATR mediano: acima de ~0,3 operar esse horário em prazos curtos é praticamente impossível.

| hora_utc | spread_med | spread_p90 | spread_max | range_med_pts | atr_med_pts | ticks_vol_med | n | spread_ticks_med | pct_barras_spread0 | custo_sobre_ATR |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 1,600.00 | 1,900.00 | 4,850.00 | 13,800.00 | 13,550.00 | 865.00 | 4,449 | 1,393.83 | 0.00 | 0.10 |
| 1 | 1,600.00 | 1,909.50 | 6,630.00 | 14,137.00 | 15,262.32 | 909.00 | 4,452 | 1,471.53 | 0.00 | 0.10 |
| 2 | 1,600.00 | 1,900.00 | 5,830.00 | 12,930.00 | 14,758.04 | 832.00 | 4,452 | 1,552.66 | 0.00 | 0.11 |
| 3 | 1,600.00 | 1,900.00 | 4,480.00 | 11,295.50 | 13,196.43 | 718.50 | 4,452 | 1,352.63 | 0.00 | 0.10 |
| 4 | 1,600.00 | 1,910.00 | 6,430.00 | 10,565.00 | 11,734.61 | 660.00 | 4,452 | 1,462.98 | 0.00 | 0.12 |
| 5 | 1,600.00 | 1,910.00 | 5,630.00 | 10,844.50 | 11,451.32 | 655.50 | 4,446 | 1,597.41 | 0.00 | 0.14 |
| 6 | 1,600.00 | 1,910.00 | 4,630.00 | 10,600.00 | 11,475.00 | 703.50 | 4,452 | 1,603.83 | 0.00 | 0.14 |
| 7 | 1,600.00 | 1,900.00 | 5,870.00 | 11,000.00 | 11,485.71 | 743.00 | 4,461 | 1,596.87 | 0.00 | 0.14 |
| 8 | 1,600.00 | 1,905.40 | 9,310.00 | 11,882.00 | 12,300.86 | 783.00 | 4,464 | 1,632.72 | 0.00 | 0.13 |
| 9 | 1,600.00 | 1,910.00 | 6,400.00 | 11,000.00 | 12,465.36 | 745.00 | 4,464 | 1,638.19 | 0.00 | 0.13 |
| 10 | 1,600.00 | 1,920.00 | 3,920.00 | 10,660.00 | 11,886.43 | 692.00 | 4,464 | 1,625.64 | 0.00 | 0.14 |
| 11 | 1,600.00 | 1,910.00 | 7,800.00 | 10,730.00 | 11,414.07 | 690.50 | 4,464 | 1,627.59 | 0.00 | 0.14 |
| 12 | 1,600.00 | 1,900.00 | 6,120.00 | 13,125.00 | 12,736.11 | 843.50 | 4,464 | 1,660.56 | 0.00 | 0.13 |
| 13 | 1,600.00 | 2,046.00 | 10,840.00 | 18,337.00 | 16,233.93 | 1,102.00 | 4,455 | 1,810.93 | 0.00 | 0.11 |
| 14 | 1,600.00 | 1,979.00 | 4,180.00 | 23,200.00 | 23,533.93 | 1,529.00 | 4,462 | 1,762.59 | 0.00 | 0.07 |
| 15 | 1,600.00 | 1,920.00 | 6,030.00 | 21,100.00 | 24,684.29 | 1,453.00 | 4,464 | 1,727.72 | 0.00 | 0.07 |
| 16 | 1,600.00 | 1,925.00 | 6,870.00 | 18,188.50 | 20,873.75 | 1,286.00 | 4,464 | 1,680.76 | 0.00 | 0.08 |
| 17 | 1,600.00 | 1,925.00 | 5,940.00 | 16,700.00 | 18,809.11 | 1,176.50 | 4,464 | 1,651.84 | 0.02 | 0.09 |
| 18 | 1,600.00 | 1,920.00 | 11,770.00 | 15,100.00 | 17,440.18 | 1,054.50 | 4,464 | 1,644.38 | 0.00 | 0.09 |
| 19 | 1,600.00 | 1,921.00 | 6,110.00 | 14,500.00 | 16,007.14 | 952.00 | 4,461 | 1,624.95 | 0.00 | 0.10 |
| 20 | 1,600.00 | 1,920.00 | 8,460.00 | 12,900.00 | 15,165.00 | 769.00 | 4,463 | 1,633.33 | 0.00 | 0.11 |
| 21 | 1,600.00 | 2,150.00 | 8,070.00 | 11,360.00 | 14,322.86 | 463.00 | 4,429 | 1,609.90 | 0.00 | 0.11 |
| 22 | 1,600.00 | 1,960.00 | 6,680.00 | 12,740.00 | 13,631.43 | 618.00 | 4,427 | 1,617.68 | 0.00 | 0.12 |
| 23 | 1,600.00 | 1,920.00 | 5,290.00 | 11,650.00 | 13,295.00 | 693.00 | 4,439 | 1,390.12 | 0.00 | 0.10 |

Spread geral (mediana M5): **1600.0 pts**, p90 1920.0, máx 11770. ATR mediano M5: **14352.9 pts**. Razão spread/ATR: **0.11**.

## 4. Comportamento diário (D1)

| dow | dias | range_medio_pts | ret_medio_pts | ret_desvio | pct_alta | t_ret |
|---|---|---|---|---|---|---|
| seg | 338 | 260,983.30 | 18,023.41 | 186,253.89 | 53.85 | 1.78 |
| ter | 340 | 234,673.10 | -6,417.23 | 163,755.53 | 50.88 | -0.72 |
| qua | 340 | 238,803.81 | 22,717.07 | 166,300.67 | 51.76 | 2.52 |
| qui | 342 | 229,278.27 | -18,397.69 | 158,465.10 | 47.66 | -2.15 |
| sex | 339 | 244,843.27 | 3,730.39 | 172,359.58 | 48.38 | 0.40 |
| sab | 1 | 86,138.00 | -38,923.00 |  | 0.00 |  |

Autocorrelação do retorno diário (lags 1-5): -0.029, -0.008, +0.042, +0.005, +0.045 (banda ±0.049). Autocorrelação do |retorno| (agrupamento de volatilidade, lags 1,5,10): +0.257, +0.230, +0.200.

## 5. Efeitos de relógio na vela H1 (retorno da própria vela em ATR; não sobreposto)

**Por hora UTC:**

| n | hora UTC | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 1,422 | 0 | -0.007 | -0.437 | nao |
| 1,421 | 1 | -0.017 | -1.051 | nao |
| 1,422 | 2 | -0.004 | -0.294 | nao |
| 1,422 | 3 | -0.010 | -0.700 | nao |
| 1,422 | 4 | 0.017 | 1.378 | nao |
| 1,422 | 5 | 0.001 | 0.081 | nao |
| 1,422 | 6 | 0.007 | 0.529 | nao |
| 1,423 | 7 | -0.009 | -0.595 | nao |
| 1,423 | 8 | 0.033 | 1.956 | nao |
| 1,423 | 9 | 0.004 | 0.243 | nao |
| 1,423 | 10 | 0.019 | 1.256 | nao |
| 1,423 | 11 | 0.011 | 0.672 | nao |
| 1,423 | 12 | -0.002 | -0.121 | nao |
| 1,423 | 13 | -0.049 | -2.001 | nao |
| 1,423 | 14 | -0.012 | -0.397 | nao |
| 1,423 | 15 | 0.001 | 0.019 | nao |
| 1,423 | 16 | -0.024 | -1.237 | nao |
| 1,423 | 17 | 0.023 | 1.158 | nao |
| 1,423 | 18 | -0.001 | -0.034 | nao |
| 1,423 | 19 | -0.001 | -0.045 | nao |
| 1,422 | 20 | 0.020 | 1.252 | nao |
| 1,422 | 21 | 0.038 | 2.573 | nao |
| 1,422 | 22 | 0.043 | 2.873 | nao |
| 1,422 | 23 | -0.012 | -0.895 | nao |

**Por dia da semana (0=seg, UTC):**

| n | dia da semana (0=seg, UTC) | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 6,768 | 0 | 0.009 | 1.160 | nao |
| 6,838 | 1 | -0.002 | -0.232 | nao |
| 6,819 | 2 | 0.017 | 2.005 | nao |
| 6,864 | 3 | -0.014 | -1.766 | nao |
| 6,096 | 4 | 0.000 | 0.051 | nao |
| 755 | 6 | 0.035 | 1.562 | nao |

**Por mês:**

| n | mês | ret_medio_ATR | t | bh |
|---|---|---|---|---|
| 2,620 | 1 | 0.016 | 1.161 | nao |
| 2,424 | 2 | 0.010 | 0.724 | nao |
| 2,646 | 3 | 0.003 | 0.225 | nao |
| 2,664 | 4 | 0.007 | 0.587 | nao |
| 3,158 | 5 | -0.010 | -0.892 | nao |
| 3,099 | 6 | -0.021 | -1.769 | nao |
| 3,189 | 7 | 0.007 | 0.595 | nao |
| 3,171 | 8 | -0.001 | -0.102 | nao |
| 3,117 | 9 | 0.008 | 0.649 | nao |
| 2,927 | 10 | 0.018 | 1.451 | nao |
| 2,564 | 11 | 0.002 | 0.133 | nao |
| 2,561 | 12 | 0.001 | 0.057 | nao |

**Combinações dia da semana × hora com |t|>3 (n≥50)**, sem correção de múltiplos testes (são 121 combinações testadas):

| dia(0=seg) | hora_utc | n | ret_medio_ATR | std | t |
|---|---|---|---|---|---|
| 3 | 13 | 286 | -0.178 | 0.930 | -3.228 |

Autocorrelação do retorno H1, lags 1-10: +0.008, +0.002, -0.003, +0.012, +0.006, +0.001, -0.003, +0.009, +0.007, -0.001 (banda ±0.011). |retorno|: +0.130, +0.054, -0.008, -0.068, +0.088 (lags 1,2,5,10,24).

**Continuação/reversão depois de barras grandes (H1):**

| condicao | n | ret_prox_vela_ATR | t | pct_alta |
|---|---|---|---|---|
| barra > +2 ATR | 275 | 0.123 | 1.823 | 52.000 |
| barra < -2 ATR | 265 | -0.053 | -0.952 | 51.698 |
| barra > +1 ATR | 1,773 | 0.029 | 1.358 | 47.941 |
| barra < -1 ATR | 1,783 | 0.004 | 0.204 | 55.076 |
| gap (barra ausente antes) | 288 | 0.053 | 1.201 | 51.389 |

Distribuição do retorno H1 em ATR: média +0.0028, desvio 0.667, assimetria +0.00, curtose 5.1; barras |ret|>2 ATR: 1.58%.

**Modelo de custo:** spread por slot de 30 min do relógio de Nova York = mediana do spread medido nos ticks (últimos ~120 dias); custo usado = max(spread da barra, esse perfil). Compra paga na entrada; venda paga na saída (no instante em que o alvo é atingido, no modo `hit`). Perfil completo em `perfil_spread_NY.csv` (mediana geral 1623.7 pts, máxima 1973.8 pts no slot NY 09:30; domingos têm perfil próprio).

## 6. Mineração de padrões (descoberta 60% / validação 40% / placebo / BH / custo realista)

Método: para cada par de variáveis (53-70 variáveis categóricas, em quintis, padrões de candle, estrutura multi-timeframe, notícias, níveis, atraso de barras, retornos defasados, calendário) testa-se se o retorno futuro (em ATR) difere de zero. `ret` = retorno bruto em horizonte fixo (5-240 min); `hit` = saída por alvo (0,5/1/2 ATR) **sem stop**, com saída por tempo (15/60/240 min), líquido de custo. Estatística t com amostra efetiva n·min(1, tf/horizonte). BH sobre todas as células da descoberta. Validação: mesmo sinal e p<0,05 unilateral. Placebo: o mesmo procedimento com o retorno deslocado aleatoriamente no tempo. Custo: compra paga o spread da entrada, venda paga o spread estimado da saída (ver topo).

**Resumo da mineração**

| tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|
| M5 | open | 106,757 | 72,035 | 0 | 0 | 0.0 | 0.0 | 0 | 1.0 | 7.0 |
| M15 | open | 68,201 | 77,571 | 0 | 0 | 0.2 | 0.0 | 0 | 13.0 | 5.0 |
| M30 | open | 34,040 | 61,500 | 0 | 0 | 0.0 | 0.0 | 0 | 8.0 | 4.2 |
| H1 | open | 32,635 | 62,579 | 2 | 0 | 0.0 | 0.0 | 0 | 17.0 | 4.2 |


## 6.3 Modo `open`

### M5 — modo `open`

- eventos: 106,757 (2025-05-15 a 2026-10-16); descoberta 63,784 (até 2026-03-22), validação 42,703 (a partir de 2026-03-23)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 72,035**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 1.0%, top 1000: 5.2%, top 10000: 4.7%
- **placebo** (6 deslocamentos): top 100: 7.0% (máx 11.0%), top 1000: 4.6% (máx 8.4%), top 10000: 3.3% (máx 4.2%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,771 | -0.002 | -0.737 | -27.365 |
| 10min bruto | 63,771 | -0.003 | -0.571 | -44.989 |
| 20min bruto | 63,606 | -0.009 | -0.814 | -130.134 |
| 35min bruto | 63,366 | -0.019 | -0.963 | -274.675 |
| 65min bruto | 62,889 | -0.043 | -1.122 | -618.726 |
| 125min bruto | 61,982 | -0.095 | -1.196 | -1,359.083 |
| 245min bruto | 60,246 | -0.216 | -1.281 | -3,096.362 |

**M5/open: famílias distintas validadas: 73; com líquido positivo e significativo na validação (custo realista): 13.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=BEARISH & month=7 | 245min | COMPRA | 288 | 1,393 | 2.07 | nao | 2.70 | 1 | 26,239.11 | 24,614.20 | 24,614.20 | 18.63 | -1,694.37 | 20.01 | 65.54 | 2/2 | 2/2 | 20,626.02 | 28,596.65 | 1,624.91 |
| mtf_D1=BEARISH & month=7 | 125min | COMPRA | 288 | 1,417 | 2.06 | nao | 2.66 | 1 | 13,482.40 | 11,857.14 | 11,857.14 | 11.73 | -1,757.69 | 13.59 | 60.76 | 2/2 | 2/2 | 9,296.77 | 14,413.89 | 1,625.26 |
| mtf_D1=BULLISH & mtf_W1=BULLISH | 245min | VENDA | 6,672 | 1,956 | -2.38 | nao | -1.97 | 1 | 16,077.70 | 14,039.01 | 14,057.25 | 10.29 | -1,889.41 | 11.92 | 58.33 | 2/2 | 5/6 | 17,032.44 | 11,082.05 | 2,020.45 |
| mtf_D1=BULLISH & mtf_W1=BULLISH | 125min | VENDA | 6,792 | 1,992 | -2.15 | nao | -1.74 | 1 | 7,782.62 | 5,745.35 | 5,756.30 | 5.60 | -1,828.01 | 7.56 | 52.71 | 2/2 | 5/6 | 6,529.50 | 4,983.10 | 2,026.32 |
| day_of_week=MONDAY & news_min_to_next_high=Q4 | 125min | VENDA | 1,490 | 989 | -2.03 | nao | -1.69 | 1 | 9,027.17 | 7,376.74 | 7,395.60 | 4.88 | -1,828.01 | 6.16 | 62.59 | 2/2 | 12/18 | -3,251.06 | 18,020.75 | 1,631.57 |
| mtf_H1=BEARISH & atr_ratio_prev=Q1 | 125min | VENDA | 3,838 | 2,560 | -2.12 | nao | -1.71 | 1 | 5,398.84 | 3,667.35 | 3,648.29 | 4.71 | -1,828.01 | 7.21 | 52.50 | 2/2 | 12/18 | 2,479.68 | 4,816.90 | 1,750.55 |
| mtf_D1=BREAK_DOWN & atr_ratio_prev=Q4 | 20min | VENDA | 828 | 439 | -2.11 | nao | -3.18 | 1 | 7,855.83 | 6,150.79 | 6,114.28 | 4.40 | -1,846.76 | 5.78 | 60.59 | 2/2 | 6/8 | 6,491.57 | 5,738.70 | 1,741.55 |
| mtf_D1=BEARISH & month=7 | 35min | COMPRA | 288 | 1,435 | 2.01 | nao | 2.62 | 1 | 3,866.96 | 2,241.54 | 2,241.54 | 4.22 | -1,734.91 | 7.55 | 51.85 | 2/2 | 2/2 | 1,387.11 | 3,094.78 | 1,625.42 |
| day_of_week=SUNDAY & structure_before=BULLISH | 35min | COMPRA | 612 | 474 | 2.13 | nao | 1.73 | 2 | 7,146.65 | 5,218.51 | 5,218.51 | 3.69 | -1,734.91 | 4.95 | 54.85 | 2/2 | 12/18 | 10,152.03 | 284.98 | 1,928.14 |
| hour=18 & pcum10=Q5 | 20min | VENDA | 476 | 292 | -2.04 | nao | -2.90 | 1 | 4,462.57 | 2,564.95 | 2,569.85 | 2.96 | -1,846.76 | 5.09 | 58.90 | 2/2 | 13/18 | 2,546.59 | 2,593.11 | 1,892.72 |
| mtf_D1=BREAK_DOWN & atr_ratio_prev=Q4 | 10min | VENDA | 829 | 439 | -2.24 | nao | -3.54 | 1 | 4,364.20 | 2,659.16 | 2,636.35 | 2.61 | -1,835.42 | 4.46 | 57.86 | 2/2 | 6/8 | 3,485.74 | 1,790.82 | 1,727.85 |
| mtf_M30=BREAK_UP & dom_w=d01_07 | 20min | COMPRA | 844 | 454 | 2.02 | nao | 2.02 | 1 | 4,157.49 | 2,397.24 | 2,397.24 | 2.39 | -1,741.42 | 4.14 | 51.10 | 2/2 | 10/16 | 1,147.73 | 3,646.75 | 1,760.25 |
| hour=18 & month=5 | 20min | VENDA | 144 | 252 | -2.62 | nao | -2.10 | 1 | 3,780.12 | 1,819.39 | 1,805.02 | 1.95 | -1,846.76 | 3.93 | 54.37 | 2/2 | 2/2 | 498.19 | 3,111.85 | 1,975.10 |

### M15 — modo `open`

- eventos: 68,201 (2024-01-22 a 2026-10-16); descoberta 40,824 (até 2025-09-11), validação 27,281 (a partir de 2025-09-12)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 77,571**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 13.0%, top 1000: 5.6%, top 10000: 4.4%
- **placebo** (6 deslocamentos): top 100: 5.0% (máx 12.0%), top 1000: 4.9% (máx 7.4%), top 10000: 3.9% (máx 4.5%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 15min bruto | 40,811 | 0.007 | 2.279 | 198.869 |
| 20min bruto | 40,811 | 0.007 | 1.530 | 189.525 |
| 30min bruto | 40,460 | 0.015 | 2.125 | 394.897 |
| 45min bruto | 40,100 | 0.021 | 1.929 | 552.242 |
| 75min bruto | 39,387 | 0.033 | 1.763 | 874.361 |
| 135min bruto | 37,973 | 0.054 | 1.528 | 1,453.942 |
| 255min bruto | 35,176 | 0.102 | 1.381 | 2,738.595 |

**M15/open: famílias distintas validadas: 115; com líquido positivo e significativo na validação (custo realista): 26.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H4=BREAK_UP & news_min_to_next_high=Q3 | 135min | VENDA | 312 | 99 | -2.08 | nao | -2.13 | 1 | 18,058.99 | 16,460.71 | 16,385.19 | 5.35 | -428.83 | 5.44 | 71.72 | 3/3 | 16/21 | 21,407.74 | 11,463.09 | 1,673.80 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 135min | COMPRA | 1,415 | 1,025 | 2.44 | nao | 1.84 | 1 | 6,816.79 | 5,208.11 | 5,208.11 | 4.05 | -2,993.36 | 6.34 | 54.83 | 3/3 | 24/34 | 6,350.82 | 4,067.63 | 1,608.67 |
| mtf_H4=BULLISH & month=7 | 255min | VENDA | 1,329 | 658 | -2.00 | nao | -1.66 | 1 | 9,507.99 | 7,924.75 | 7,914.77 | 4.00 | 839.03 | 3.54 | 58.97 | 3/3 | 3/3 | 3,464.83 | 12,364.70 | 1,593.22 |
| day_of_week=SUNDAY & mtf_M5=BULLISH | 45min | COMPRA | 362 | 281 | 2.31 | nao | 2.72 | 1 | 10,665.46 | 8,843.60 | 8,843.60 | 3.83 | -2,053.60 | 4.74 | 60.50 | 3/3 | 23/33 | 10,125.83 | 7,570.45 | 1,821.86 |
| hour=20 & mtf_M30=BEARISH | 45min | COMPRA | 413 | 397 | 2.17 | nao | 2.51 | 1 | 7,624.75 | 5,910.06 | 5,910.06 | 3.36 | -2,053.60 | 4.56 | 54.91 | 3/3 | 25/34 | 7,958.27 | 3,872.14 | 1,714.69 |
| month=6 & atr_ratio_prev=Q4 | 45min | VENDA | 727 | 371 | -2.09 | nao | -2.28 | 1 | 7,495.32 | 5,847.75 | 5,824.58 | 3.07 | -1,369.93 | 3.81 | 54.99 | 2/3 | 2/3 | 6,628.43 | 5,025.05 | 1,670.75 |
| mtf_M30=BULLISH & atr_ratio_prev=Q5 | 135min | COMPRA | 2,369 | 1,669 | 2.47 | nao | 1.86 | 1 | 5,993.40 | 4,215.57 | 4,215.57 | 2.75 | -2,993.36 | 4.86 | 51.47 | 3/3 | 20/34 | 1,267.79 | 7,159.82 | 1,777.83 |
| hour=20 & mtf_M30=BEARISH | 30min | COMPRA | 493 | 414 | 2.44 | nao | 2.71 | 1 | 5,737.88 | 4,014.86 | 4,014.86 | 2.66 | -1,917.99 | 3.97 | 54.59 | 3/3 | 25/34 | 4,517.76 | 3,511.96 | 1,723.03 |
| mtf_H4=RANGE & dom_w=d22_31 | 75min | VENDA | 2,526 | 2,101 | -2.23 | nao | -2.00 | 1 | 4,134.71 | 2,443.62 | 2,412.78 | 2.62 | -1,082.37 | 3.91 | 50.50 | 2/3 | 25/33 | 3,126.42 | 1,699.81 | 1,721.93 |
| hour=8 & mtf_H4=BULLISH | 30min | COMPRA | 707 | 364 | 2.00 | nao | 2.56 | 1 | 5,635.55 | 3,946.42 | 3,946.42 | 2.61 | -1,917.99 | 3.90 | 52.20 | 3/3 | 16/33 | 4,173.53 | 3,719.32 | 1,689.13 |
| hour=20 & mtf_H1=BEARISH | 45min | COMPRA | 402 | 438 | 2.16 | nao | 1.72 | 1 | 5,986.17 | 4,271.83 | 4,271.83 | 2.46 | -2,053.60 | 3.66 | 50.46 | 3/3 | 26/33 | 9,205.69 | -662.04 | 1,714.34 |
| month=6 & atr_ratio_prev=Q4 | 30min | VENDA | 740 | 371 | -2.06 | nao | -2.41 | 1 | 5,223.41 | 3,575.83 | 3,551.48 | 2.27 | -1,505.67 | 3.25 | 53.64 | 2/3 | 2/3 | 4,453.76 | 2,654.05 | 1,671.93 |
| day_of_week=SUNDAY & mtf_M5=BULLISH | 30min | COMPRA | 362 | 281 | 2.32 | nao | 2.49 | 1 | 6,111.04 | 4,289.18 | 4,289.18 | 2.27 | -1,917.99 | 3.30 | 54.45 | 3/3 | 21/33 | 3,661.00 | 4,912.90 | 1,821.86 |
| slot_hhmm=08:00 & mtf_H4=BULLISH | 30min | COMPRA | 177 | 91 | 2.28 | nao | 2.53 | 1 | 7,192.66 | 5,480.97 | 5,480.97 | 2.15 | -1,917.99 | 2.89 | 58.24 | 3/3 | 21/29 | 2,018.76 | 8,867.91 | 1,711.69 |
| slot_hhmm=08:00 & mtf_M1=BEARISH | 30min | COMPRA | 178 | 100 | 2.17 | nao | 2.06 | 1 | 6,524.97 | 4,820.37 | 4,820.37 | 2.11 | -1,917.99 | 2.94 | 58.00 | 3/3 | 22/29 | 6,808.51 | 2,832.23 | 1,704.60 |
| slot_hhmm=22:00 & mtf_M30=BULLISH | 15min | COMPRA | 160 | 107 | 3.63 | nao | 2.44 | 1 | 6,651.59 | 4,912.14 | 4,912.14 | 2.07 | -1,828.25 | 2.83 | 52.34 | 3/3 | 21/31 | 8,516.84 | 1,374.21 | 1,739.44 |
| hour=15 & mtf_M30=RANGE | 20min | VENDA | 394 | 230 | -2.36 | nao | -2.17 | 1 | 6,476.41 | 4,716.46 | 4,719.56 | 2.04 | -1,471.46 | 2.68 | 50.87 | 3/3 | 20/34 | 9,569.47 | -130.35 | 1,756.85 |
| slot_hhmm=22:00 & mtf_H1=BULLISH | 15min | COMPRA | 156 | 92 | 2.90 | nao | 2.41 | 1 | 7,089.55 | 5,330.27 | 5,330.27 | 2.02 | -1,828.25 | 2.71 | 53.26 | 3/3 | 19/29 | 9,335.94 | 1,324.60 | 1,759.28 |
| hour=21 & pcum10=Q1 | 20min | COMPRA | 301 | 124 | 2.25 | nao | 2.82 | 1 | 6,737.68 | 5,096.88 | 5,096.88 | 2.01 | -1,955.16 | 2.78 | 55.65 | 3/3 | 23/31 | 7,484.73 | 2,709.03 | 1,640.80 |
| slot_hhmm=22:00 & structure_before=BULLISH | 15min | COMPRA | 164 | 101 | 3.85 | nao | 2.59 | 2 | 8,203.38 | 6,444.23 | 6,444.23 | 2.00 | -1,828.25 | 2.56 | 54.46 | 3/3 | 19/30 | 7,649.78 | 5,262.33 | 1,759.14 |
| hour=20 & mtf_H1=BEARISH | 30min | COMPRA | 484 | 454 | 2.33 | nao | 2.06 | 1 | 4,777.67 | 3,058.52 | 3,058.52 | 1.98 | -1,917.99 | 3.25 | 49.56 | 2/3 | 26/33 | 6,074.87 | 42.17 | 1,719.14 |
| hour=21 & mtf_D1=BEARISH | 30min | COMPRA | 424 | 361 | 2.67 | nao | 1.67 | 1 | 4,829.55 | 3,194.43 | 3,194.43 | 1.96 | -1,917.99 | 3.16 | 51.80 | 3/3 | 18/25 | 5,607.71 | 794.49 | 1,635.12 |
| slot_hhmm=22:00 & structure_before=BULLISH | 20min | COMPRA | 164 | 101 | 2.45 | nao | 1.89 | 2 | 7,305.08 | 5,545.94 | 5,545.94 | 1.82 | -1,955.16 | 2.45 | 50.50 | 3/3 | 21/30 | 5,265.42 | 5,820.96 | 1,759.14 |
| hour=20 & mtf_M30=BEARISH | 20min | COMPRA | 581 | 421 | 2.53 | nao | 2.65 | 1 | 4,104.77 | 2,383.45 | 2,383.45 | 1.72 | -1,955.16 | 3.16 | 52.49 | 3/3 | 20/34 | 1,615.28 | 3,147.99 | 1,721.32 |
| slot_hhmm=21:00 & mtf_M15=BEARISH | 15min | COMPRA | 131 | 99 | 3.26 | nao | 2.65 | 2 | 4,527.63 | 2,795.13 | 2,795.13 | 1.69 | -1,828.25 | 2.78 | 55.56 | 3/3 | 20/33 | 6,433.05 | -770.04 | 1,732.50 |

### M30 — modo `open`

- eventos: 34,040 (2024-01-22 a 2026-10-16); descoberta 20,410 (até 2025-09-14), validação 13,616 (a partir de 2025-09-15)
- variáveis: 26; séries por variável/par: 7
- **hipóteses testadas: 61,500**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 8.0%, top 1000: 6.9%, top 10000: 3.8%
- **placebo** (6 deslocamentos): top 100: 4.2% (máx 9.0%), top 1000: 4.3% (máx 6.6%), top 10000: 3.9% (máx 4.8%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 30min bruto | 20,397 | 0.010 | 2.154 | 392.743 |
| 35min bruto | 20,397 | 0.011 | 1.874 | 415.479 |
| 45min bruto | 20,380 | 0.014 | 1.916 | 547.817 |
| 60min bruto | 20,042 | 0.020 | 1.957 | 761.238 |
| 90min bruto | 19,684 | 0.028 | 1.839 | 1,109.536 |
| 150min bruto | 18,974 | 0.042 | 1.522 | 1,618.667 |
| 270min bruto | 17,573 | 0.075 | 1.386 | 2,918.804 |

**M30/open: famílias distintas validadas: 100; com líquido positivo e significativo na validação (custo realista): 34.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_H4=BREAK_UP & news_min_to_next_high=Q3 | 90min | VENDA | 160 | 51 | -2.10 | nao | -2.89 | 1 | 17,153.24 | 15,541.68 | 15,476.71 | 3.77 | -959.39 | 3.96 | 72.55 | 3/3 | 15/19 | 21,351.19 | 9,828.17 | 1,676.53 |
| hour=20 & mtf_M30=BEARISH | 90min | COMPRA | 158 | 187 | 2.34 | nao | 2.17 | 2 | 14,416.85 | 12,714.35 | 12,714.35 | 3.54 | -2,452.67 | 4.24 | 62.03 | 3/3 | 23/29 | 17,147.61 | 8,328.25 | 1,702.50 |
| mtf_D1=BEARISH & month=1 | 150min | COMPRA | 521 | 65 | 2.00 | nao | 2.21 | 1 | 18,063.23 | 16,433.94 | 16,433.94 | 3.13 | -3,090.44 | 3.68 | 69.23 | 3/3 | 3/3 | 11,620.62 | 21,101.40 | 1,629.30 |
| hour=20 & mtf_M30=BEARISH | 60min | COMPRA | 196 | 204 | 2.10 | nao | 2.63 | 2 | 10,407.89 | 8,691.11 | 8,691.11 | 2.90 | -2,136.74 | 3.63 | 55.88 | 3/3 | 21/31 | 6,928.81 | 10,453.40 | 1,716.78 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 150min | COMPRA | 742 | 540 | 2.38 | nao | 1.68 | 1 | 6,852.18 | 5,250.63 | 5,250.63 | 2.79 | -3,090.44 | 4.40 | 53.89 | 3/3 | 22/34 | 8,368.16 | 2,133.10 | 1,601.55 |
| hour=20 & structure_before=BEARISH | 45min | COMPRA | 276 | 210 | 2.96 | nao | 2.82 | 2 | 9,057.98 | 7,343.40 | 7,343.40 | 2.76 | -2,059.65 | 3.56 | 56.67 | 3/3 | 25/34 | 4,883.44 | 9,803.36 | 1,714.58 |
| hour=20 & pcum10=Q1 | 45min | COMPRA | 174 | 117 | 2.69 | nao | 3.07 | 1 | 11,885.90 | 10,221.53 | 10,221.53 | 2.56 | -2,059.65 | 3.08 | 58.12 | 3/3 | 22/28 | 4,563.52 | 15,783.65 | 1,664.36 |
| day_of_week=SUNDAY & mtf_M5=BULLISH | 60min | COMPRA | 176 | 146 | 2.02 | nao | 1.74 | 1 | 11,019.16 | 9,197.87 | 9,197.87 | 2.47 | -2,136.74 | 3.05 | 60.27 | 3/3 | 19/28 | 9,253.80 | 9,141.93 | 1,821.30 |
| hour=20 & mtf_H1=BEARISH | 45min | COMPRA | 270 | 230 | 2.55 | nao | 2.29 | 1 | 8,526.88 | 6,815.12 | 6,815.12 | 2.44 | -2,059.65 | 3.21 | 54.35 | 3/3 | 28/33 | 11,282.87 | 2,347.38 | 1,711.76 |
| hour=20 & mtf_H1=BEARISH | 60min | COMPRA | 188 | 224 | 2.02 | nao | 2.00 | 1 | 8,853.39 | 7,139.71 | 7,139.71 | 2.39 | -2,136.74 | 3.13 | 50.00 | 2/3 | 23/30 | 12,437.99 | 1,841.42 | 1,713.69 |
| slot_hhmm=20:00 & mtf_M30=BEARISH | 45min | COMPRA | 145 | 102 | 2.30 | nao | 3.05 | 2 | 8,952.48 | 7,234.03 | 7,234.03 | 2.38 | -2,059.65 | 3.05 | 57.84 | 3/3 | 24/32 | 5,286.24 | 9,181.82 | 1,718.45 |
| hour=8 & mtf_H4=BULLISH | 45min | COMPRA | 355 | 182 | 2.06 | nao | 2.26 | 1 | 8,195.25 | 6,520.99 | 6,520.99 | 2.33 | -2,059.65 | 3.07 | 57.14 | 3/3 | 17/33 | 5,575.50 | 7,466.49 | 1,674.25 |
| slot_hhmm=08:00 & mtf_H4=BULLISH | 45min | COMPRA | 177 | 91 | 2.12 | nao | 2.46 | 1 | 10,318.15 | 8,633.53 | 8,633.53 | 2.30 | -2,059.65 | 2.84 | 61.54 | 3/3 | 20/29 | 4,204.05 | 12,966.71 | 1,684.63 |
| hour=21 & mtf_D1=BEARISH | 35min | COMPRA | 224 | 184 | 3.21 | nao | 2.58 | 1 | 7,608.84 | 5,983.24 | 5,983.24 | 2.30 | -2,219.30 | 3.16 | 56.52 | 3/3 | 16/21 | 10,465.43 | 1,501.05 | 1,625.60 |
| hour=21 & mtf_D1=BEARISH | 45min | COMPRA | 224 | 184 | 2.60 | nao | 1.94 | 1 | 8,346.49 | 6,720.90 | 6,720.90 | 2.25 | -2,059.65 | 2.96 | 55.43 | 3/3 | 15/21 | 10,040.26 | 3,401.54 | 1,625.60 |
| slot_hhmm=08:00 & mtf_H4=BULLISH | 35min | COMPRA | 178 | 91 | 2.73 | nao | 3.01 | 1 | 7,923.70 | 6,239.08 | 6,239.08 | 2.23 | -2,219.30 | 3.02 | 61.54 | 3/3 | 18/29 | 1,956.50 | 10,428.56 | 1,684.63 |
| mtf_D1=BEARISH & month=1 | 45min | COMPRA | 572 | 91 | 2.16 | nao | 2.36 | 1 | 7,148.46 | 5,529.35 | 5,529.35 | 2.19 | -2,059.65 | 2.99 | 58.24 | 3/3 | 3/3 | 1,149.07 | 9,814.41 | 1,619.11 |
| slot_hhmm=08:00 & mtf_H4=BULLISH | 30min | COMPRA | 178 | 91 | 3.43 | nao | 3.43 | 1 | 7,192.66 | 5,508.03 | 5,508.03 | 2.16 | -1,968.27 | 2.93 | 58.24 | 3/3 | 21/29 | 2,022.72 | 8,917.58 | 1,684.63 |
| slot_hhmm=08:00 & mtf_M1=BEARISH | 30min | COMPRA | 179 | 100 | 3.14 | nao | 2.80 | 1 | 6,524.97 | 4,845.53 | 4,845.53 | 2.12 | -1,968.27 | 2.98 | 58.00 | 3/3 | 22/29 | 6,813.35 | 2,877.72 | 1,679.44 |
| hour=8 & mtf_H4=BULLISH | 30min | COMPRA | 356 | 182 | 2.36 | nao | 2.91 | 1 | 6,332.98 | 4,658.72 | 4,658.72 | 2.08 | -1,968.27 | 2.97 | 52.75 | 3/3 | 18/33 | 3,239.15 | 6,078.30 | 1,674.25 |
| mtf_D1=BEARISH & month=1 | 90min | COMPRA | 547 | 78 | 2.06 | nao | 1.76 | 1 | 9,357.82 | 7,737.49 | 7,737.49 | 2.01 | -2,452.67 | 2.63 | 57.69 | 3/3 | 3/3 | 3,645.90 | 11,829.07 | 1,620.33 |
| slot_hhmm=20:00 & mtf_M30=BEARISH | 30min | COMPRA | 145 | 102 | 2.52 | nao | 3.11 | 2 | 6,776.30 | 5,057.85 | 5,057.85 | 1.96 | -1,968.27 | 2.71 | 58.82 | 3/3 | 26/32 | 3,282.51 | 6,833.19 | 1,718.45 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 90min | COMPRA | 749 | 540 | 2.22 | nao | 1.80 | 1 | 4,496.48 | 2,894.93 | 2,894.93 | 1.91 | -2,452.67 | 3.53 | 53.15 | 3/3 | 21/34 | 4,051.86 | 1,738.00 | 1,601.55 |
| slot_hhmm=08:00 & mtf_M30=BULLISH | 35min | COMPRA | 150 | 99 | 2.52 | nao | 2.21 | 2 | 6,871.56 | 5,189.11 | 5,189.11 | 1.90 | -2,219.30 | 2.70 | 56.57 | 3/3 | 23/32 | 2,642.29 | 7,685.00 | 1,682.44 |
| hour=21 & pcum10=Q1 | 30min | COMPRA | 144 | 75 | 3.41 | nao | 2.74 | 1 | 7,575.84 | 5,939.10 | 5,939.10 | 1.84 | -1,968.27 | 2.44 | 64.00 | 3/3 | 15/19 | 11,845.35 | 188.27 | 1,636.74 |

### H1 — modo `open`

- eventos: 32,635 (2021-06-07 a 2026-10-16); descoberta 19,557 (até 2024-09-10), validação 13,054 (a partir de 2024-09-11)
- variáveis: 27; séries por variável/par: 7
- **hipóteses testadas: 62,579**; passaram no BH (q=5%) na descoberta: **2**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 17.0%, top 1000: 12.8%, top 10000: 6.4%
- **placebo** (6 deslocamentos): top 100: 4.2% (máx 10.0%), top 1000: 4.0% (máx 6.5%), top 10000: 3.9% (máx 6.9%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 60min bruto | 19,557 | 0.004 | 0.741 | 159.322 |
| 65min bruto | 19,557 | 0.002 | 0.422 | 101.197 |
| 75min bruto | 19,539 | 0.002 | 0.383 | 106.753 |
| 90min bruto | 19,520 | 0.006 | 0.767 | 259.414 |
| 120min bruto | 18,634 | 0.003 | 0.323 | 155.159 |
| 180min bruto | 17,735 | -0.001 | -0.078 | -60.059 |
| 300min bruto | 15,961 | -0.009 | -0.295 | -417.442 |

**H1/open: famílias distintas validadas: 148; com líquido positivo e significativo na validação (custo realista): 60.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| atr_ratio_prev=Q5 | 300min | COMPRA | 3,244 | 2,170 | 2.24 | nao | 2.13 | 1 | 13,112.19 | 11,448.00 | 11,448.00 | 4.14 | -200.38 | 4.85 | 55.39 | 5/6 | 39/65 | 24,246.59 | -1,350.59 | 1,664.19 |
| mtf_W1=BEARISH & month=6 | 300min | VENDA | 475 | 234 | -2.57 | nao | -2.14 | 1 | 23,503.68 | 21,850.39 | 21,796.07 | 4.06 | -3,153.08 | 4.66 | 61.97 | 3/3 | 3/3 | 51,190.56 | -7,598.42 | 1,707.60 |
| slot_hhmm=21:00 & mtf_M1=BEARISH | 90min | COMPRA | 197 | 163 | 3.40 | nao | 3.01 | 2 | 18,779.67 | 17,083.37 | 17,083.37 | 3.88 | -807.25 | 4.08 | 58.90 | 5/6 | 34/45 | 22,722.91 | 11,512.61 | 1,696.30 |
| hour=21 & mtf_M1=BEARISH | 120min | COMPRA | 197 | 163 | 3.22 | nao | 2.43 | 2 | 19,901.48 | 18,205.18 | 18,205.18 | 3.73 | -993.58 | 3.94 | 59.51 | 6/6 | 35/45 | 23,316.09 | 13,156.59 | 1,696.30 |
| mtf_H4=BULLISH & atr_ratio_prev=Q5 | 300min | COMPRA | 1,231 | 603 | 2.22 | nao | 1.84 | 1 | 20,724.31 | 19,047.49 | 19,047.49 | 3.57 | -200.38 | 3.73 | 56.72 | 6/6 | 25/45 | 34,015.36 | 4,129.19 | 1,676.82 |
| hour=21 & mtf_M1=BEARISH | 75min | COMPRA | 198 | 163 | 3.70 | nao | 3.15 | 2 | 16,332.66 | 14,636.36 | 14,636.36 | 3.54 | -826.75 | 3.76 | 55.83 | 6/6 | 33/45 | 19,567.01 | 9,765.84 | 1,696.30 |
| structure_before=BULLISH & atr_ratio_prev=Q5 | 300min | COMPRA | 1,269 | 693 | 2.98 | nao | 1.87 | 2 | 16,011.95 | 14,342.61 | 14,342.61 | 3.03 | -200.38 | 3.19 | 52.96 | 6/6 | 33/54 | 21,838.45 | 6,868.37 | 1,669.34 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 180min | COMPRA | 191 | 461 | 2.05 | nao | 2.06 | 1 | 8,726.77 | 7,112.86 | 7,112.86 | 3.00 | -798.58 | 3.30 | 54.23 | 4/4 | 23/37 | 8,274.38 | 5,956.36 | 1,613.91 |
| slot_hhmm=21:00 & atr_ratio_prev=Q4 | 120min | COMPRA | 154 | 152 | 2.63 | nao | 2.00 | 2 | 18,350.13 | 16,654.55 | 16,654.55 | 2.90 | -993.58 | 3.09 | 55.26 | 5/6 | 19/34 | 16,133.81 | 17,175.29 | 1,695.58 |
| slot_hhmm=21:00 & mtf_D1=BEARISH | 90min | COMPRA | 229 | 149 | 2.62 | nao | 2.21 | 2 | 13,060.36 | 11,395.05 | 11,395.05 | 2.86 | -807.25 | 3.07 | 54.36 | 5/6 | 24/34 | 12,422.08 | 10,381.72 | 1,665.31 |
| hour=21 & mtf_D1=BEARISH | 120min | COMPRA | 227 | 149 | 2.17 | nao | 1.93 | 2 | 15,330.39 | 13,665.08 | 13,665.08 | 2.85 | -993.58 | 3.06 | 55.03 | 6/6 | 22/34 | 16,307.40 | 11,057.99 | 1,665.31 |
| slot_hhmm=21:00 & mtf_D1=BEARISH | 65min | COMPRA | 231 | 149 | 2.80 | nao | 2.68 | 2 | 12,237.40 | 10,572.09 | 10,572.09 | 2.81 | -1,416.49 | 3.19 | 57.05 | 5/6 | 23/34 | 12,163.89 | 9,001.52 | 1,665.31 |
| hour=21 & pcum10=Q1 | 60min | COMPRA | 158 | 151 | 2.67 | nao | 3.14 | 2 | 11,170.07 | 9,467.95 | 9,467.95 | 2.79 | -1,460.08 | 3.22 | 58.28 | 4/6 | 30/40 | 11,985.91 | 6,983.12 | 1,702.12 |
| hour=21 & mtf_D1=BEARISH | 75min | COMPRA | 231 | 149 | 2.98 | nao | 2.47 | 2 | 12,813.81 | 11,148.50 | 11,148.50 | 2.79 | -826.75 | 3.00 | 53.69 | 6/6 | 25/34 | 11,755.16 | 10,549.92 | 1,665.31 |
| hour=21 & mtf_M1=BEARISH | 65min | COMPRA | 199 | 163 | 3.42 | nao | 2.76 | 2 | 12,815.28 | 11,118.98 | 11,118.98 | 2.71 | -1,416.49 | 3.07 | 57.67 | 5/6 | 31/45 | 15,366.20 | 6,923.55 | 1,696.30 |
| atr_ratio_prev=Q5 | 180min | COMPRA | 3,541 | 2,276 | 2.45 | nao | 2.13 | 1 | 7,473.60 | 5,805.40 | 5,805.40 | 2.70 | -798.58 | 3.55 | 53.95 | 5/6 | 34/65 | 12,450.01 | -839.21 | 1,668.20 |
| hour=21 & pcum10=Q1 | 120min | COMPRA | 156 | 151 | 2.06 | nao | 1.72 | 2 | 15,963.56 | 14,261.44 | 14,261.44 | 2.68 | -993.58 | 2.87 | 61.59 | 4/6 | 29/40 | 23,989.64 | 4,661.24 | 1,702.12 |
| hour=8 & streak_prev=-1 | 75min | COMPRA | 222 | 134 | 2.20 | nao | 2.40 | 2 | 11,355.50 | 9,707.56 | 9,707.56 | 2.59 | -826.75 | 2.81 | 55.22 | 5/6 | 26/44 | 18,880.84 | 534.28 | 1,647.94 |
| mtf_W1=BEARISH & month=6 | 180min | VENDA | 525 | 238 | -2.69 | nao | -1.99 | 1 | 13,273.51 | 11,613.44 | 11,570.43 | 2.57 | -2,548.23 | 3.15 | 60.08 | 3/3 | 3/3 | 29,740.26 | -6,599.40 | 1,703.08 |
| hour=8 & streak_prev=-1 | 120min | COMPRA | 222 | 134 | 2.06 | nao | 1.90 | 2 | 12,654.52 | 11,006.58 | 11,006.58 | 2.54 | -993.58 | 2.76 | 58.21 | 6/6 | 29/44 | 20,562.71 | 1,450.46 | 1,647.94 |
| slot_hhmm=21:00 & p2=Q1 | 120min | COMPRA | 131 | 96 | 2.19 | nao | 1.82 | 2 | 15,028.74 | 13,349.95 | 13,349.95 | 2.46 | -993.58 | 2.64 | 59.38 | 4/6 | 19/25 | 19,411.07 | 7,288.84 | 1,678.79 |
| news_state=NONE_60M & atr_ratio_prev=Q5 | 180min | COMPRA | 1,037 | 1,926 | 2.55 | nao | 1.95 | 1 | 7,196.56 | 5,543.16 | 5,543.16 | 2.46 | -798.58 | 3.16 | 54.10 | 4/4 | 23/37 | 12,406.98 | -1,320.65 | 1,653.40 |
| day_of_week=WEDNESDAY & mtf_W1=BREAK_UP | 90min | COMPRA | 322 | 144 | 2.04 | nao | 2.61 | 1 | 15,175.55 | 13,505.24 | 13,505.24 | 2.45 | -807.25 | 2.60 | 63.19 | 4/5 | 8/12 | 15,532.59 | 11,477.90 | 1,670.31 |
| slot_hhmm=21:00 & mtf_M1=BEARISH | 60min | COMPRA | 199 | 163 | 3.04 | nao | 2.60 | 2 | 10,389.48 | 8,693.18 | 8,693.18 | 2.40 | -1,460.08 | 2.81 | 53.37 | 4/6 | 32/45 | 13,271.65 | 4,170.55 | 1,696.30 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 120min | COMPRA | 192 | 464 | 2.01 | nao | 2.29 | 1 | 6,227.48 | 4,613.66 | 4,613.66 | 2.37 | -993.58 | 2.85 | 54.74 | 4/4 | 22/37 | 5,190.87 | 4,036.45 | 1,613.83 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **436**
- com líquido positivo e t>1,645 na validação, custo realista: **133**; dessas, sobreviveram ao BH: **0**; e positivas nas duas metades da validação: **0**
- **Nenhuma família passa em todos os filtros (BH + validação + líquido positivo com custo realista + estabilidade nas duas metades).**

## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 167s)_
