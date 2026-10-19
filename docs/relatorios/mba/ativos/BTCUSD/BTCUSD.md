# BTCUSD — relatório completo MBA (gerado em 2026-10-17 01:57)

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
| M5 | ret | 106,757 | 205,958 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 5.0 |
| M15 | ret | 68,201 | 214,935 | 2 | 0 | 0.5 | 0.0 | 0 | 10.0 | 5.8 |
| M30 | ret | 34,040 | 186,568 | 0 | 0 | 0.0 | 0.0 | 0 | 9.0 | 3.2 |
| H1 | ret | 32,635 | 188,414 | 3 | 0 | 0.0 | 0.0 | 0 | 16.0 | 2.8 |
| M5 | hit | 106,757 | 617,238 | 19 | 1 | 18.7 | 1.2 | 2 | 7.0 | 6.7 |
| M15 | hit | 68,201 | 641,046 | 0 | 0 | 0.2 | 0.0 | 0 | 2.0 | 2.0 |
| M30 | hit | 34,040 | 556,242 | 0 | 0 | 0.2 | 0.0 | 0 | 6.0 | 0.8 |
| H1 | hit | 32,635 | 559,188 | 0 | 0 | 0.2 | 0.0 | 0 | 1.0 | 0.8 |


## 6.1 Modo `ret`

### M5 — modo `ret`

- eventos: 106,757 (2025-05-15 a 2026-10-16); descoberta 63,784 (até 2026-03-22), validação 42,703 (a partir de 2026-03-23)
- variáveis: 64; séries por variável/par: 6
- **hipóteses testadas: 205,958**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 0.0%, top 1000: 4.3%, top 10000: 5.1%
- **placebo** (6 deslocamentos): top 100: 5.0% (máx 7.0%), top 1000: 5.0% (máx 5.7%), top 10000: 3.8% (máx 4.4%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 63,784 | -0.001 | -0.441 | -18.245 |
| 15min bruto | 63,619 | -0.007 | -0.822 | -101.007 |
| 30min bruto | 63,379 | -0.017 | -1.001 | -248.158 |
| 60min bruto | 62,902 | -0.042 | -1.167 | -598.798 |
| 120min bruto | 61,995 | -0.094 | -1.231 | -1,350.762 |
| 240min bruto | 60,259 | -0.215 | -1.301 | -3,091.871 |

**M5/ret: famílias distintas validadas: 157; com líquido positivo e significativo na validação (custo realista): 27.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=BEARISH & month=7 | 240min | COMPRA | 288 | 1,393 | 2.06 | nao | 2.70 | 1 | 25,729.08 | 24,104.14 | 24,104.14 | 18.35 | -1,725.07 | 19.77 | 65.90 | 2/2 | 2/2 | 20,190.11 | 28,012.55 | 1,624.94 |
| mtf_D1=BEARISH & month=7 | 120min | COMPRA | 288 | 1,417 | 2.07 | nao | 2.68 | 1 | 12,974.00 | 11,348.73 | 11,348.73 | 11.44 | -1,775.38 | 13.35 | 60.62 | 2/2 | 2/2 | 8,862.17 | 13,831.80 | 1,625.27 |
| mtf_D1=BULLISH & mtf_W1=BULLISH | 240min | VENDA | 6,672 | 1,956 | -2.39 | nao | -1.98 | 1 | 15,807.31 | 13,768.70 | 13,786.86 | 10.15 | -1,858.67 | 11.77 | 57.92 | 2/2 | 5/6 | 16,734.36 | 10,839.35 | 2,020.45 |
| month=7 & price_position_weekly_open=Q1 | 120min | COMPRA | 227 | 64 | 2.05 | nao | 1.85 | 1 | 22,072.11 | 20,494.04 | 20,494.04 | 9.49 | -1,775.38 | 10.19 | 89.06 | 2/2 | 2/2 | 9,822.02 | 31,166.06 | 1,578.07 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | 60min | COMPRA | 342 | 312 | 2.29 | nao | 2.25 | 1 | 16,861.55 | 15,056.71 | 15,056.71 | 6.29 | -1,732.66 | 7.03 | 66.35 | 2/2 | 14/14 | 21,587.48 | 8,525.94 | 1,804.84 |
| month=7 & price_position_weekly_open=Q1 | 60min | COMPRA | 237 | 64 | 2.52 | nao | 1.94 | 1 | 12,404.22 | 10,826.15 | 10,826.15 | 6.06 | -1,732.66 | 6.96 | 79.69 | 2/2 | 2/2 | 7,809.83 | 13,842.47 | 1,578.07 |
| price_position_weekly_open=Q1 & prev_day_low_distance_atr=Q3 | 60min | VENDA | 1,903 | 488 | -2.15 | nao | -1.67 | 1 | 10,887.20 | 9,181.63 | 9,195.45 | 5.92 | -1,854.86 | 7.15 | 55.94 | 2/2 | 9/13 | 2,391.28 | 15,999.61 | 1,691.76 |
| mtf_D1=BULLISH & mtf_W1=BULLISH | 120min | VENDA | 6,792 | 1,992 | -2.17 | nao | -1.77 | 1 | 7,509.14 | 5,471.96 | 5,482.82 | 5.46 | -1,810.29 | 7.43 | 52.86 | 2/2 | 5/6 | 6,258.91 | 4,706.72 | 2,026.32 |
| day_of_week=MONDAY & news_min_to_next_high=Q4 | 120min | VENDA | 1,490 | 989 | -2.07 | nao | -1.70 | 1 | 8,803.26 | 7,156.34 | 7,171.69 | 4.83 | -1,810.29 | 6.13 | 62.59 | 2/2 | 12/18 | -3,131.67 | 17,454.23 | 1,631.57 |
| mtf_H1=BEARISH & atr_ratio=Q1 | 120min | VENDA | 3,834 | 2,548 | -2.14 | nao | -1.72 | 1 | 5,252.44 | 3,520.39 | 3,505.36 | 4.61 | -1,810.29 | 7.13 | 53.14 | 2/2 | 12/18 | 2,417.24 | 4,593.49 | 1,747.08 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | 30min | COMPRA | 342 | 312 | 2.23 | nao | 2.11 | 1 | 8,428.70 | 6,623.86 | 6,623.86 | 4.16 | -1,756.13 | 5.28 | 58.65 | 2/2 | 12/14 | 9,950.43 | 3,297.29 | 1,804.84 |
| mtf_D1=BREAK_DOWN & atr_ratio=Q4 | 15min | VENDA | 824 | 439 | -2.37 | nao | -3.33 | 1 | 6,205.01 | 4,499.97 | 4,470.31 | 3.68 | -1,826.31 | 5.22 | 59.45 | 2/2 | 6/8 | 5,095.56 | 3,847.91 | 1,734.70 |
| mtf_D1=BEARISH & month=7 | 30min | COMPRA | 288 | 1,435 | 2.03 | nao | 2.68 | 1 | 3,336.84 | 1,711.42 | 1,711.42 | 3.49 | -1,756.13 | 7.13 | 50.52 | 2/2 | 2/2 | 942.60 | 2,479.18 | 1,625.42 |
| hour=15 & prev_day_low_distance_atr=Q4 | 30min | COMPRA | 373 | 278 | 2.09 | nao | 1.73 | 1 | 9,089.33 | 7,201.49 | 7,201.49 | 3.49 | -1,756.13 | 4.35 | 56.47 | 2/2 | 14/18 | 3,685.04 | 10,717.94 | 1,887.85 |
| day_of_week=SUNDAY & structure_at_close=BULLISH | 30min | COMPRA | 611 | 477 | 2.02 | nao | 1.77 | 1 | 6,201.10 | 4,277.91 | 4,277.91 | 3.29 | -1,756.13 | 4.67 | 52.20 | 2/2 | 13/18 | 8,805.25 | -230.48 | 1,923.19 |
| day_of_week=SUNDAY & mtf_M5=BULLISH | 30min | COMPRA | 612 | 474 | 2.17 | nao | 1.72 | 2 | 5,997.68 | 4,066.67 | 4,066.67 | 3.07 | -1,756.13 | 4.43 | 53.16 | 2/2 | 13/18 | 8,233.69 | -100.36 | 1,931.01 |
| session=NEW_YORK & previous_low_distance_atr=Q1 | 30min | COMPRA | 2,320 | 1,392 | 2.41 | nao | 2.71 | 1 | 3,630.53 | 1,816.56 | 1,816.56 | 3.07 | -1,756.13 | 6.13 | 54.38 | 2/2 | 15/18 | 1,489.70 | 2,143.42 | 1,813.96 |
| hour=20 & swing_low_distance_atr=Q1 | 15min | COMPRA | 491 | 221 | 2.49 | nao | 2.47 | 1 | 5,513.96 | 3,751.06 | 3,751.06 | 3.07 | -1,761.76 | 4.52 | 57.01 | 2/2 | 11/17 | 4,392.96 | 3,114.95 | 1,762.90 |
| hour=18 & cum10=Q5 | 15min | VENDA | 468 | 280 | -2.01 | nao | -3.22 | 1 | 3,791.45 | 1,900.18 | 1,917.48 | 2.55 | -1,826.31 | 4.97 | 55.00 | 2/2 | 13/18 | 1,680.89 | 2,154.07 | 1,873.97 |
| day_of_week=SUNDAY & prev_day_low_distance_atr=Q3 | 15min | COMPRA | 375 | 360 | 2.18 | nao | 2.16 | 1 | 4,371.40 | 2,457.92 | 2,457.92 | 2.49 | -1,761.76 | 4.28 | 51.39 | 2/2 | 12/18 | 5,008.94 | -93.10 | 1,913.48 |
| hour=15 & prev_day_low_distance_atr=Q4 | 15min | COMPRA | 373 | 278 | 2.06 | nao | 2.06 | 1 | 5,511.28 | 3,623.43 | 3,623.43 | 2.38 | -1,761.76 | 3.55 | 52.52 | 2/2 | 11/18 | 907.52 | 6,339.34 | 1,887.85 |
| hour=20 & previous_low_distance_atr=Q1 | 15min | COMPRA | 512 | 221 | 2.17 | nao | 2.17 | 1 | 4,268.98 | 2,456.57 | 2,456.57 | 2.17 | -1,761.76 | 3.73 | 53.39 | 2/2 | 11/17 | 1,432.90 | 3,471.01 | 1,812.41 |
| mtf_M30=BREAK_UP & dom_w=d01_07 | 15min | COMPRA | 844 | 454 | 2.11 | nao | 2.22 | 1 | 3,387.94 | 1,627.51 | 1,627.51 | 1.86 | -1,761.76 | 3.89 | 48.02 | 2/2 | 10/16 | 591.70 | 2,663.32 | 1,760.43 |
| hour=15 & cum10=Q5 | 15min | COMPRA | 536 | 379 | 2.15 | nao | 1.93 | 1 | 4,308.30 | 2,399.08 | 2,399.08 | 1.81 | -1,761.76 | 3.17 | 43.80 | 2/2 | 11/18 | 797.12 | 3,992.61 | 1,909.22 |
| hour=20 & swing_low_distance_atr=Q1 | 5min | COMPRA | 497 | 232 | 2.29 | nao | 3.58 | 1 | 3,401.21 | 1,639.11 | 1,639.11 | 1.80 | -1,774.15 | 3.76 | 46.98 | 2/2 | 8/17 | 2,278.40 | 999.82 | 1,762.10 |

### M15 — modo `ret`

- eventos: 68,201 (2024-01-22 a 2026-10-16); descoberta 40,824 (até 2025-09-11), validação 27,281 (a partir de 2025-09-12)
- variáveis: 62; séries por variável/par: 6
- **hipóteses testadas: 214,935**; passaram no BH (q=5%) na descoberta: **2**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 10.0%, top 1000: 6.8%, top 10000: 6.2%
- **placebo** (6 deslocamentos): top 100: 5.8% (máx 7.0%), top 1000: 5.1% (máx 6.8%), top 10000: 4.4% (máx 5.3%); BH: média 0.5 (máx 2); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 40,824 | -0.000 | -0.152 | -9.299 |
| 15min bruto | 40,473 | 0.007 | 2.064 | 200.476 |
| 30min bruto | 40,113 | 0.014 | 1.857 | 366.068 |
| 60min bruto | 39,400 | 0.025 | 1.631 | 661.103 |
| 120min bruto | 37,986 | 0.046 | 1.433 | 1,228.738 |
| 240min bruto | 35,189 | 0.093 | 1.325 | 2,492.496 |

**M15/ret: famílias distintas validadas: 434; com líquido positivo e significativo na validação (custo realista): 31.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| prev_day_low_distance_atr=Q5 & atr_ratio=Q5 | 240min | COMPRA | 701 | 460 | 2.12 | nao | 2.04 | 1 | 32,802.38 | 30,824.50 | 30,824.50 | 7.66 | -4,156.24 | 8.77 | 60.22 | 3/3 | 15/27 | 19,584.24 | 42,064.76 | 1,977.88 |
| prev_day_low_distance_atr=Q5 & atr_ratio=Q5 | 120min | COMPRA | 809 | 482 | 2.26 | nao | 2.44 | 1 | 19,123.37 | 17,144.08 | 17,144.08 | 6.20 | -2,869.26 | 7.30 | 58.71 | 3/3 | 16/27 | 10,061.88 | 24,226.28 | 1,979.29 |
| mtf_H4=BREAK_UP & news_min_to_next_high=Q3 | 120min | VENDA | 312 | 99 | -2.15 | nao | -2.14 | 1 | 15,921.41 | 14,319.41 | 14,247.62 | 5.02 | -552.52 | 5.17 | 69.70 | 3/3 | 16/21 | 17,101.62 | 11,450.69 | 1,673.80 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | 120min | COMPRA | 220 | 138 | 2.21 | nao | 2.00 | 1 | 33,504.87 | 31,768.74 | 31,768.74 | 4.99 | -2,869.26 | 5.44 | 69.57 | 3/3 | 17/23 | 50,240.10 | 13,297.39 | 1,736.13 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | 60min | COMPRA | 220 | 138 | 2.92 | nao | 2.68 | 1 | 21,648.57 | 19,912.44 | 19,912.44 | 4.57 | -2,205.46 | 5.08 | 68.12 | 3/3 | 20/23 | 29,160.53 | 10,664.34 | 1,736.13 |
| mtf_H4=BREAK_UP & news_min_to_next_high=Q3 | 60min | VENDA | 312 | 99 | -2.12 | nao | -2.64 | 1 | 9,106.52 | 7,504.51 | 7,481.29 | 3.79 | -1,217.72 | 4.36 | 66.67 | 3/3 | 16/21 | 10,416.07 | 4,605.21 | 1,625.22 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 120min | COMPRA | 1,415 | 1,025 | 2.48 | nao | 1.86 | 1 | 6,094.32 | 4,483.78 | 4,483.78 | 3.71 | -2,869.26 | 6.04 | 54.05 | 3/3 | 22/34 | 5,835.76 | 3,134.43 | 1,610.55 |
| hour=21 & previous_low_distance_atr=Q5 | 60min | COMPRA | 245 | 236 | 2.29 | nao | 2.31 | 1 | 12,463.89 | 10,718.73 | 10,718.73 | 3.62 | -2,205.46 | 4.38 | 55.93 | 3/3 | 21/29 | 15,699.06 | 5,738.39 | 1,745.16 |
| price_position_daily_open=Q5 & prev_day_low_distance_atr=Q5 | 120min | COMPRA | 3,118 | 1,768 | 2.20 | nao | 1.71 | 1 | 6,666.36 | 4,927.21 | 4,927.21 | 3.55 | -2,869.26 | 5.81 | 50.62 | 3/3 | 20/34 | -182.89 | 10,037.30 | 1,739.15 |
| hour=20 & prev_day_low_distance_atr=Q1 | 30min | COMPRA | 349 | 369 | 2.26 | nao | 2.00 | 1 | 6,639.08 | 4,943.82 | 4,943.82 | 3.01 | -1,926.74 | 4.21 | 52.03 | 3/3 | 24/34 | 10,340.08 | -423.26 | 1,695.26 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | 30min | COMPRA | 220 | 138 | 2.97 | nao | 2.52 | 1 | 9,415.93 | 7,679.80 | 7,679.80 | 2.73 | -1,926.74 | 3.42 | 59.42 | 3/3 | 19/23 | 10,458.23 | 4,901.37 | 1,736.13 |
| hour=20 & mtf_M30=BEARISH | 30min | COMPRA | 413 | 397 | 2.35 | nao | 2.17 | 1 | 5,442.80 | 3,727.79 | 3,727.79 | 2.50 | -1,926.74 | 3.81 | 52.39 | 3/3 | 24/34 | 6,693.68 | 776.81 | 1,715.01 |
| price_position_daily_open=Q5 & price_position_weekly_open=Q1 | 60min | COMPRA | 716 | 395 | 2.16 | nao | 2.02 | 1 | 8,968.97 | 7,323.85 | 7,323.85 | 2.43 | -2,205.46 | 3.19 | 57.97 | 3/3 | 13/20 | 1,579.22 | 13,039.47 | 1,645.12 |
| mtf_M30=BULLISH & atr_ratio=Q5 | 120min | COMPRA | 2,304 | 1,633 | 2.39 | nao | 1.80 | 1 | 5,356.72 | 3,576.87 | 3,576.87 | 2.33 | -2,869.26 | 4.36 | 51.93 | 3/3 | 19/34 | 1,307.06 | 5,843.89 | 1,779.86 |
| slot_hhmm=21:45 & structure_before=BULLISH | 15min | COMPRA | 140 | 105 | 2.22 | nao | 2.84 | 2 | 8,964.24 | 7,227.15 | 7,227.15 | 2.30 | -1,791.13 | 2.87 | 57.14 | 2/3 | 20/30 | 9,972.91 | 4,533.20 | 1,737.09 |
| month=6 & atr_ratio=Q4 | 30min | VENDA | 726 | 371 | -2.09 | nao | -2.31 | 1 | 5,192.04 | 3,544.46 | 3,520.10 | 2.25 | -1,496.34 | 3.22 | 53.10 | 2/3 | 2/3 | 4,430.57 | 2,614.53 | 1,671.93 |
| hour=20 & previous_high_distance_atr=Q1 | 30min | COMPRA | 258 | 244 | 2.06 | nao | 2.11 | 1 | 6,849.16 | 5,184.80 | 5,184.80 | 2.21 | -1,926.74 | 3.04 | 56.56 | 3/3 | 23/32 | 7,059.22 | 3,310.37 | 1,664.36 |
| slot_hhmm=21:45 & structure_at_close=BULLISH | 15min | COMPRA | 149 | 99 | 2.27 | nao | 2.70 | 1 | 9,120.61 | 7,378.22 | 7,378.22 | 2.19 | -1,791.13 | 2.71 | 56.57 | 3/3 | 18/29 | 9,981.78 | 4,826.73 | 1,742.38 |
| slot_hhmm=07:45 & mtf_H4=BULLISH | 30min | COMPRA | 177 | 91 | 2.29 | nao | 2.39 | 1 | 7,253.32 | 5,541.63 | 5,541.63 | 2.18 | -1,926.74 | 2.92 | 58.24 | 3/3 | 21/29 | 2,072.76 | 8,935.09 | 1,711.69 |
| hour=21 & mtf_D1=BEARISH | 30min | COMPRA | 392 | 349 | 2.65 | nao | 1.67 | 1 | 5,294.51 | 3,660.30 | 3,660.30 | 2.13 | -1,926.74 | 3.27 | 51.86 | 3/3 | 17/23 | 6,305.96 | 1,029.76 | 1,634.21 |
| hour=20 & prev_day_high_distance_atr=Q1 | 30min | COMPRA | 246 | 330 | 3.00 | nao | 1.79 | 1 | 5,081.16 | 3,355.59 | 3,355.59 | 2.07 | -1,926.74 | 3.28 | 50.30 | 3/3 | 23/31 | 8,579.27 | -1,868.09 | 1,725.57 |
| streak=-4 & range_atr_prev=Q4 | 15min | COMPRA | 220 | 155 | 2.02 | nao | 2.78 | 1 | 4,640.08 | 2,940.71 | 2,940.71 | 2.04 | -1,791.13 | 3.28 | 58.06 | 3/3 | 20/33 | 3,799.10 | 2,093.33 | 1,699.37 |
| hour=15 & session_low_distance_atr=Q5 | 30min | COMPRA | 339 | 221 | 2.13 | nao | 2.07 | 1 | 8,525.20 | 6,684.26 | 6,684.26 | 2.04 | -1,926.74 | 2.63 | 54.75 | 3/3 | 18/32 | 10,547.10 | 2,856.22 | 1,840.94 |
| price_position_daily_open=Q5 & prev_day_low_distance_atr=Q5 | 60min | COMPRA | 3,337 | 1,806 | 2.07 | nao | 1.98 | 1 | 3,726.05 | 1,987.76 | 1,987.76 | 2.02 | -2,205.46 | 4.41 | 49.72 | 2/3 | 16/34 | -1,027.64 | 5,003.16 | 1,738.28 |
| hour=20 & session_high_distance_atr=Q1 | 15min | COMPRA | 308 | 238 | 2.41 | nao | 3.12 | 1 | 5,342.34 | 3,644.02 | 3,644.02 | 1.99 | -1,791.13 | 2.99 | 55.04 | 3/3 | 24/34 | 2,464.73 | 4,823.30 | 1,698.33 |

### M30 — modo `ret`

- eventos: 34,040 (2024-01-22 a 2026-10-16); descoberta 20,410 (até 2025-09-14), validação 13,616 (a partir de 2025-09-15)
- variáveis: 62; séries por variável/par: 6
- **hipóteses testadas: 186,568**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 9.0%, top 1000: 6.2%, top 10000: 6.4%
- **placebo** (6 deslocamentos): top 100: 3.2% (máx 4.0%), top 1000: 4.5% (máx 6.8%), top 10000: 4.7% (máx 5.3%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 20,410 | 0.001 | 0.254 | 24.152 |
| 15min bruto | 20,393 | 0.004 | 1.127 | 165.293 |
| 30min bruto | 20,055 | 0.010 | 1.916 | 392.937 |
| 60min bruto | 19,697 | 0.017 | 1.581 | 657.864 |
| 120min bruto | 18,987 | 0.030 | 1.366 | 1,187.236 |
| 240min bruto | 17,586 | 0.063 | 1.293 | 2,454.743 |

**M30/ret: famílias distintas validadas: 372; com líquido positivo e significativo na validação (custo realista): 63.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| day_of_week=THURSDAY & prev_day_high_distance_atr=Q3 | 240min | VENDA | 882 | 474 | -2.09 | nao | -2.00 | 1 | 27,563.72 | 25,939.87 | 25,903.03 | 6.55 | 686.30 | 6.50 | 58.02 | 3/3 | 22/34 | 48,605.53 | 3,200.53 | 1,660.69 |
| mtf_H4=BREAK_UP & news_min_to_next_high=Q3 | 120min | VENDA | 160 | 51 | -2.06 | nao | -2.57 | 1 | 18,603.82 | 16,982.15 | 16,876.46 | 3.95 | -604.46 | 4.03 | 68.63 | 3/3 | 14/19 | 19,224.88 | 14,618.37 | 1,727.36 |
| price_position_weekly_open=Q4 & atr_ratio=Q1 | 120min | VENDA | 970 | 633 | -2.26 | nao | -1.91 | 1 | 9,385.71 | 7,767.03 | 7,701.85 | 3.80 | -604.46 | 4.16 | 53.71 | 3/3 | 22/30 | 13,223.50 | 2,197.62 | 1,683.86 |
| day_of_week=THURSDAY & prev_day_high_distance_atr=Q3 | 60min | VENDA | 985 | 489 | -2.19 | nao | -2.79 | 1 | 7,717.45 | 6,089.83 | 6,061.38 | 3.41 | -1,256.06 | 4.18 | 53.78 | 3/3 | 21/34 | 12,152.20 | -4.58 | 1,656.07 |
| hour=20 & prev_day_low_distance_atr=Q1 | 60min | COMPRA | 136 | 182 | 2.58 | nao | 1.83 | 1 | 12,135.59 | 10,442.09 | 10,442.09 | 3.31 | -2,155.23 | 4.01 | 54.95 | 3/3 | 19/25 | 21,501.39 | -617.21 | 1,693.51 |
| hour=20 & swing_low_distance_atr=Q1 | 15min | COMPRA | 148 | 82 | 2.15 | nao | 3.12 | 1 | 11,379.54 | 9,746.16 | 9,746.16 | 3.12 | -1,793.59 | 3.69 | 59.76 | 3/3 | 19/22 | 10,955.45 | 8,536.88 | 1,633.37 |
| mtf_W1=BEARISH & prev_day_low_distance_atr=Q4 | 240min | COMPRA | 527 | 1,249 | 2.19 | nao | 1.73 | 1 | 8,513.17 | 6,904.99 | 6,904.99 | 3.11 | -4,096.92 | 5.17 | 53.56 | 2/3 | 12/15 | 3,377.94 | 10,426.40 | 1,608.18 |
| hour=20 & structure_at_close=BEARISH | 60min | COMPRA | 158 | 189 | 2.17 | nao | 2.21 | 1 | 10,578.79 | 8,884.84 | 8,884.84 | 3.09 | -2,155.23 | 3.86 | 55.03 | 3/3 | 21/28 | 14,723.92 | 3,107.23 | 1,693.95 |
| hour=20 & previous_low_distance_atr=Q1 | 15min | COMPRA | 193 | 110 | 2.14 | nao | 3.62 | 1 | 8,841.69 | 7,186.18 | 7,186.18 | 2.97 | -1,793.59 | 3.71 | 61.82 | 3/3 | 22/30 | 6,408.15 | 7,964.22 | 1,655.51 |
| hour=20 & previous_high_distance_atr=Q1 | 15min | COMPRA | 137 | 110 | 2.06 | nao | 2.95 | 1 | 10,461.45 | 8,730.04 | 8,730.04 | 2.95 | -1,793.59 | 3.56 | 59.09 | 3/3 | 19/25 | 7,927.96 | 9,532.12 | 1,731.41 |
| mtf_H4=BREAK_UP & news_min_to_next_high=Q3 | 60min | VENDA | 160 | 51 | -2.34 | nao | -2.90 | 1 | 11,852.84 | 10,231.17 | 10,176.32 | 2.95 | -1,256.06 | 3.27 | 66.67 | 3/3 | 15/19 | 13,259.19 | 7,212.01 | 1,676.53 |
| hour=20 & structure_before=BEARISH | 60min | COMPRA | 158 | 187 | 2.24 | nao | 1.78 | 2 | 10,489.44 | 8,784.02 | 8,784.02 | 2.93 | -2,155.23 | 3.66 | 54.01 | 3/3 | 23/29 | 15,333.91 | 2,303.82 | 1,705.41 |
| hour=20 & cum3=Q1 | 15min | COMPRA | 145 | 58 | 2.08 | nao | 2.87 | 1 | 12,437.98 | 10,798.44 | 10,798.44 | 2.70 | -1,793.59 | 3.13 | 60.34 | 3/3 | 14/21 | 13,078.68 | 8,518.20 | 1,639.54 |
| hour=20 & prev_day_low_distance_atr=Q1 | 30min | COMPRA | 169 | 197 | 2.22 | nao | 2.58 | 1 | 7,768.09 | 6,072.24 | 6,072.24 | 2.57 | -1,860.01 | 3.38 | 49.24 | 3/3 | 21/29 | 10,891.39 | 1,301.77 | 1,695.85 |
| hour=20 & prev_day_low_distance_atr=Q1 | 15min | COMPRA | 245 | 201 | 2.42 | nao | 2.55 | 1 | 6,549.93 | 4,855.47 | 4,855.47 | 2.57 | -1,793.59 | 3.54 | 53.23 | 3/3 | 22/33 | 9,256.26 | 498.25 | 1,694.46 |
| day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 120min | COMPRA | 742 | 540 | 2.53 | nao | 1.83 | 1 | 5,946.54 | 4,343.45 | 4,343.45 | 2.56 | -2,805.45 | 4.19 | 52.78 | 3/3 | 19/34 | 7,552.71 | 1,134.19 | 1,603.09 |
| hour=20 & ret_bar_atr=Q1 | 15min | COMPRA | 125 | 55 | 2.10 | nao | 2.32 | 1 | 12,118.29 | 10,407.84 | 10,407.84 | 2.46 | -1,793.59 | 2.87 | 56.36 | 3/3 | 15/22 | 14,747.75 | 6,222.94 | 1,710.45 |
| session=NEW_YORK & session_low_distance_atr=Q1 | 15min | COMPRA | 748 | 490 | 2.98 | nao | 3.68 | 1 | 4,608.90 | 2,885.55 | 2,885.55 | 2.46 | -1,793.59 | 4.08 | 55.92 | 3/3 | 23/34 | 3,814.53 | 1,956.57 | 1,723.35 |
| hour=20 & mtf_M5=BEARISH | 15min | COMPRA | 243 | 168 | 2.32 | nao | 3.41 | 1 | 6,484.58 | 4,797.14 | 4,797.14 | 2.41 | -1,793.59 | 3.32 | 54.17 | 3/3 | 23/33 | 3,051.39 | 6,542.89 | 1,687.44 |
| hour=20 & cum10=Q1 | 15min | COMPRA | 160 | 96 | 2.85 | nao | 2.84 | 1 | 9,325.56 | 7,674.83 | 7,674.83 | 2.31 | -1,793.59 | 2.85 | 55.21 | 3/3 | 21/27 | 4,393.52 | 10,956.14 | 1,650.73 |
| mtf_H4=BULLISH & previous_low_distance_atr=Q5 | 60min | COMPRA | 1,325 | 507 | 2.03 | nao | 2.18 | 1 | 6,650.62 | 4,954.28 | 4,954.28 | 2.29 | -2,155.23 | 3.37 | 50.49 | 2/3 | 21/34 | 4,396.56 | 5,509.80 | 1,696.34 |
| slot_hhmm=07:30 & mtf_H1=BULLISH | 30min | COMPRA | 171 | 107 | 2.95 | nao | 2.65 | 1 | 7,908.58 | 6,210.80 | 6,210.80 | 2.22 | -1,860.01 | 2.88 | 56.07 | 3/3 | 22/32 | 2,244.46 | 10,103.69 | 1,697.78 |
| session=NEW_YORK & session_low_distance_atr=Q1 | 30min | COMPRA | 707 | 488 | 2.20 | nao | 3.22 | 1 | 4,983.35 | 3,259.59 | 3,259.59 | 2.21 | -1,860.01 | 3.54 | 53.48 | 2/3 | 24/34 | 5,100.73 | 1,418.45 | 1,723.76 |
| slot_hhmm=07:30 & mtf_H4=BULLISH | 30min | COMPRA | 178 | 91 | 3.42 | nao | 3.33 | 1 | 7,253.32 | 5,568.69 | 5,568.69 | 2.19 | -1,860.01 | 2.91 | 58.24 | 3/3 | 21/29 | 2,076.72 | 8,984.75 | 1,684.63 |
| hour=20 & structure_at_close=BEARISH | 30min | COMPRA | 198 | 207 | 2.16 | nao | 2.84 | 1 | 6,757.15 | 5,044.61 | 5,044.61 | 2.18 | -1,860.01 | 3.01 | 54.59 | 3/3 | 21/30 | 4,424.08 | 5,659.17 | 1,712.54 |

### H1 — modo `ret`

- eventos: 32,635 (2021-06-07 a 2026-10-16); descoberta 19,557 (até 2024-09-10), validação 13,054 (a partir de 2024-09-11)
- variáveis: 63; séries por variável/par: 6
- **hipóteses testadas: 188,414**; passaram no BH (q=5%) na descoberta: **3**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 16.0%, top 1000: 13.4%, top 10000: 9.8%
- **placebo** (6 deslocamentos): top 100: 2.8% (máx 5.0%), top 1000: 4.7% (máx 6.8%), top 10000: 4.5% (máx 6.4%); BH: média 0.0 (máx 0); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| 5min bruto | 19,557 | -0.001 | -0.782 | -58.125 |
| 15min bruto | 19,539 | -0.001 | -0.431 | -51.112 |
| 30min bruto | 19,520 | 0.002 | 0.638 | 106.903 |
| 60min bruto | 18,634 | -0.000 | -0.010 | -2.503 |
| 120min bruto | 17,735 | -0.005 | -0.383 | -203.554 |
| 240min bruto | 15,961 | -0.012 | -0.448 | -521.172 |

**H1/ret: famílias distintas validadas: 797; com líquido positivo e significativo na validação (custo realista): 116.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hour=7 & price_position_daily_open=Q5 | 30min | COMPRA | 152 | 191 | 2.29 | nao | 4.88 | 2 | 9,203.76 | 7,543.46 | 7,543.46 | 3.66 | -1,037.68 | 4.17 | 61.26 | 4/6 | 27/40 | 8,340.57 | 6,754.65 | 1,660.30 |
| mtf_W1=BEARISH & month=6 | 240min | VENDA | 475 | 234 | -2.63 | nao | -2.08 | 1 | 19,599.55 | 17,944.42 | 17,891.95 | 3.64 | -2,686.95 | 4.20 | 61.54 | 3/3 | 3/3 | 41,824.19 | -6,040.30 | 1,707.60 |
| mtf_H4=BULLISH & atr_ratio=Q5 | 240min | COMPRA | 1,200 | 600 | 2.40 | nao | 2.05 | 1 | 19,021.40 | 17,347.10 | 17,347.10 | 3.63 | -665.43 | 3.91 | 55.83 | 6/6 | 28/45 | 30,825.21 | 3,869.00 | 1,674.29 |
| atr_ratio=Q5 | 240min | COMPRA | 3,175 | 2,166 | 2.26 | nao | 2.16 | 1 | 10,539.66 | 8,876.87 | 8,876.87 | 3.54 | -665.43 | 4.39 | 53.74 | 5/6 | 35/65 | 19,025.60 | -1,271.85 | 1,662.78 |
| direction=BEARISH & atr_ratio=Q5 | 240min | COMPRA | 1,480 | 1,040 | 2.24 | nao | 1.84 | 1 | 13,759.32 | 12,097.26 | 12,097.26 | 3.43 | -665.43 | 3.85 | 56.92 | 5/6 | 40/64 | 24,053.11 | 141.41 | 1,662.06 |
| body_pct=Q4 & close_position=Q1 | 15min | COMPRA | 849 | 592 | 2.86 | nao | 4.12 | 1 | 5,293.98 | 3,634.52 | 3,634.52 | 3.35 | -1,032.80 | 4.41 | 55.74 | 4/6 | 37/65 | 4,672.26 | 2,596.78 | 1,659.46 |
| structure_before=BULLISH & atr_ratio=Q5 | 240min | COMPRA | 1,222 | 676 | 2.84 | nao | 2.21 | 2 | 15,570.56 | 13,898.44 | 13,898.44 | 3.20 | -665.43 | 3.48 | 53.40 | 6/6 | 33/53 | 19,214.34 | 8,582.54 | 1,672.12 |
| session_high_distance_atr=Q2 & atr_ratio=Q5 | 60min | COMPRA | 504 | 288 | 2.03 | nao | 3.43 | 1 | 12,310.08 | 10,641.09 | 10,641.09 | 3.17 | -1,331.56 | 3.62 | 57.99 | 4/6 | 28/46 | 16,726.94 | 4,555.23 | 1,668.99 |
| mtf_W1=BEARISH & prev_day_low_distance_atr=Q4 | 120min | COMPRA | 1,299 | 930 | 2.01 | nao | 2.83 | 1 | 7,057.12 | 5,446.12 | 5,446.12 | 2.99 | -1,189.85 | 3.72 | 52.26 | 4/6 | 22/33 | 4,580.90 | 6,311.34 | 1,611.00 |
| close_position=Q5 & swing_high_distance_atr=Q1 | 120min | VENDA | 476 | 392 | -2.34 | nao | -2.98 | 1 | 10,310.20 | 8,632.73 | 8,631.91 | 2.87 | -2,155.26 | 3.62 | 55.61 | 6/6 | 40/64 | 11,785.06 | 5,478.75 | 1,678.30 |
| hour=22 & swing_high_distance_atr=Q1 | 60min | VENDA | 177 | 116 | -2.74 | nao | -2.71 | 2 | 12,957.24 | 11,340.07 | 11,375.80 | 2.82 | -2,014.15 | 3.32 | 55.17 | 5/6 | 20/31 | 19,053.47 | 3,698.14 | 1,581.44 |
| structure_at_close=BULLISH & atr_ratio=Q5 | 240min | COMPRA | 1,234 | 692 | 2.99 | nao | 1.98 | 1 | 13,721.32 | 12,052.59 | 12,052.59 | 2.75 | -665.43 | 3.02 | 52.02 | 5/6 | 30/54 | 17,113.86 | 6,991.33 | 1,668.73 |
| structure_at_close=BULLISH & news_min_since_last_high=Q1 | 120min | COMPRA | 158 | 401 | 2.12 | nao | 2.17 | 1 | 11,831.51 | 10,122.34 | 10,122.34 | 2.70 | -1,189.85 | 3.07 | 54.11 | 3/4 | 21/36 | 26,461.70 | -6,135.73 | 1,709.17 |
| range_atr=Q5 & volume_ratio=Q4 | 60min | COMPRA | 944 | 572 | 2.79 | nao | 2.83 | 1 | 8,583.70 | 6,922.96 | 6,922.96 | 2.69 | -1,331.56 | 3.31 | 54.90 | 4/6 | 36/65 | 6,486.96 | 7,358.96 | 1,660.74 |
| slot_hhmm=07:00 & price_position_daily_open=Q5 | 60min | COMPRA | 151 | 190 | 2.79 | nao | 3.40 | 2 | 10,022.06 | 8,361.55 | 8,361.55 | 2.67 | -1,331.56 | 3.11 | 54.21 | 5/6 | 25/40 | 8,673.71 | 8,049.39 | 1,660.50 |
| volume_ratio=Q4 & cost_atr=Q1 | 15min | COMPRA | 809 | 1,527 | 2.01 | nao | 4.78 | 1 | 3,603.76 | 1,976.01 | 1,976.01 | 2.60 | -1,032.80 | 4.29 | 50.82 | 3/5 | 26/44 | 2,238.39 | 1,713.98 | 1,627.75 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | 30min | COMPRA | 125 | 79 | 2.21 | nao | 3.30 | 1 | 13,438.65 | 11,751.97 | 11,751.97 | 2.58 | -1,037.68 | 2.80 | 60.76 | 4/6 | 14/17 | 17,559.38 | 6,089.75 | 1,686.67 |
| close_position=Q1 & price_position_daily_open=Q5 | 30min | COMPRA | 545 | 698 | 4.12 | nao | 3.84 | 1 | 5,389.28 | 3,749.41 | 3,749.41 | 2.56 | -1,037.68 | 3.38 | 57.45 | 4/6 | 38/59 | 4,654.99 | 2,843.83 | 1,639.87 |
| close_position=Q1 & volume_ratio=Q4 | 60min | COMPRA | 737 | 504 | 2.54 | nao | 3.33 | 1 | 7,456.66 | 5,801.61 | 5,801.61 | 2.54 | -1,331.56 | 3.20 | 54.17 | 4/6 | 38/65 | 6,463.00 | 5,140.22 | 1,655.05 |
| hour=7 & price_position_daily_open=Q5 | 15min | COMPRA | 152 | 191 | 2.59 | nao | 3.64 | 2 | 5,488.70 | 3,828.40 | 3,828.40 | 2.47 | -1,032.80 | 3.15 | 55.50 | 5/6 | 23/40 | 5,313.17 | 2,359.08 | 1,660.30 |
| price_position_daily_open=Q5 & ret_bar_atr=Q1 | 30min | COMPRA | 452 | 568 | 2.64 | nao | 3.52 | 1 | 5,171.64 | 3,496.03 | 3,496.03 | 2.47 | -1,037.68 | 3.27 | 56.69 | 4/6 | 32/57 | 5,662.06 | 1,329.99 | 1,675.61 |
| close_position=Q1 & price_position_daily_open=Q5 | 60min | COMPRA | 512 | 671 | 2.09 | nao | 3.87 | 1 | 6,008.66 | 4,369.01 | 4,369.01 | 2.43 | -1,331.56 | 3.25 | 54.10 | 5/6 | 35/58 | 5,044.35 | 3,695.67 | 1,639.65 |
| mtf_H4=RANGE & streak=3 | 60min | VENDA | 253 | 178 | -2.20 | nao | -3.16 | 1 | 11,040.86 | 9,393.01 | 9,390.60 | 2.41 | -2,014.15 | 2.94 | 62.36 | 5/6 | 31/48 | 17,853.76 | 927.44 | 1,650.26 |
| volume_ratio=Q4 & pat_INVERTED_HAMMER=Y | 60min | COMPRA | 151 | 84 | 2.12 | nao | 3.39 | 1 | 19,056.38 | 17,424.99 | 17,424.99 | 2.41 | -1,331.56 | 2.59 | 58.33 | 5/6 | 17/23 | 16,689.28 | 18,160.70 | 1,631.39 |
| close_position=Q1 & price_position_daily_open=Q5 | 15min | COMPRA | 545 | 698 | 2.75 | nao | 3.96 | 1 | 4,141.08 | 2,501.21 | 2,501.21 | 2.39 | -1,032.80 | 3.49 | 54.73 | 4/6 | 34/59 | 2,807.51 | 2,194.91 | 1,639.87 |

## 6.2 Modo `hit`

### M5 — modo `hit`

- eventos: 106,757 (2025-05-15 a 2026-10-16); descoberta 63,784 (até 2026-03-22), validação 42,703 (a partir de 2026-03-23)
- variáveis: 64; séries por variável/par: 18
- **hipóteses testadas: 617,238**; passaram no BH (q=5%) na descoberta: **19**; confirmadas na validação: **1**
- melhores N da descoberta que repetem na validação: top 100: 7.0%, top 1000: 4.1%, top 10000: 1.7%
- **placebo** (6 deslocamentos): top 100: 6.7% (máx 10.0%), top 1000: 2.6% (máx 3.9%), top 10000: 1.2% (máx 1.6%); BH: média 18.7 (máx 29); confirmadas: média 1.2 (máx 2)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 63,606 | -0.129 |  | -1,857.250 |
| C alvo 0.5ATR/60min liquido | 62,889 | -0.137 |  | -1,966.288 |
| C alvo 0.5ATR/240min liquido | 60,246 | -0.174 |  | -2,503.546 |
| C alvo 1.0ATR/15min liquido | 63,606 | -0.127 |  | -1,825.399 |
| C alvo 1.0ATR/60min liquido | 62,889 | -0.145 |  | -2,081.779 |
| C alvo 1.0ATR/240min liquido | 60,246 | -0.219 |  | -3,144.140 |
| C alvo 2.0ATR/15min liquido | 63,606 | -0.122 |  | -1,755.741 |
| C alvo 2.0ATR/60min liquido | 62,889 | -0.158 |  | -2,273.843 |
| C alvo 2.0ATR/240min liquido | 60,246 | -0.276 |  | -3,967.991 |
| V alvo 0.5ATR/15min liquido | 63,606 | -0.098 |  | -1,403.670 |
| V alvo 0.5ATR/60min liquido | 62,889 | -0.089 |  | -1,271.405 |
| V alvo 0.5ATR/240min liquido | 60,246 | -0.076 |  | -1,089.822 |
| V alvo 1.0ATR/15min liquido | 63,606 | -0.095 |  | -1,370.164 |
| V alvo 1.0ATR/60min liquido | 62,889 | -0.071 |  | -1,013.158 |
| V alvo 1.0ATR/240min liquido | 60,246 | -0.049 |  | -697.064 |
| V alvo 2.0ATR/15min liquido | 63,606 | -0.098 |  | -1,402.901 |
| V alvo 2.0ATR/60min liquido | 62,889 | -0.058 |  | -834.608 |
| V alvo 2.0ATR/240min liquido | 60,246 | -0.007 |  | -98.170 |

**M5/hit: famílias distintas validadas: 14; com líquido positivo e significativo na validação (custo realista): 14.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_D1=BREAK_DOWN & news_min_to_next_high=Q4 | V alvo 1.0ATR ate 240min | VENDA | 213 | 270 | 3.10 | nao | 10.91 | 1 |  | 13,847.10 | 13,847.10 | 32.86 | -1,541.97 | 33.77 | 98.89 | 2/2 | 7/7 | 10,653.73 | 17,040.47 | 1,627.85 |
| price_position_weekly_open=Q1 & price_position_monthly_open=Q5 | C alvo 1.0ATR ate 240min | COMPRA | 355 | 288 | 2.27 | nao | 6.76 | 1 |  | 11,012.70 | 11,012.70 | 32.29 | -2,021.70 | 34.62 | 98.96 | 2/2 | 3/3 | 13,552.17 | 8,473.22 | 1,635.80 |
| session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 2.0ATR ate 240min | VENDA | 129 | 115 | 2.06 | nao | 31.70 | 1 |  | 18,241.93 | 18,241.93 | 31.38 | -902.18 | 30.60 | 100.00 | 2/2 | 12/12 | 18,789.93 | 17,703.38 | 1,715.07 |
| session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 1.0ATR ate 240min | VENDA | 129 | 115 | 2.46 | nao | 14.31 | 1 |  | 8,214.57 | 8,214.57 | 29.11 | -1,541.97 | 29.20 | 100.00 | 2/2 | 12/12 | 8,568.46 | 7,866.78 | 1,715.07 |
| mtf_D1=BREAK_DOWN & news_min_to_next_high=Q4 | V alvo 2.0ATR ate 240min | VENDA | 213 | 270 | 3.79 | nao | 5.25 | 1 |  | 26,517.61 | 26,517.61 | 25.82 | -902.18 | 26.18 | 95.93 | 2/2 | 7/7 | 22,565.74 | 30,469.49 | 1,627.85 |
| session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 0.5ATR ate 240min | VENDA | 129 | 115 | 14.19 | sim | 5.35 | 1 |  | 3,200.25 | 3,200.25 | 23.75 | -1,780.03 | 26.18 | 100.00 | 2/2 | 12/12 | 3,446.10 | 2,958.63 | 1,715.07 |
| month=7 & price_position_weekly_open=Q1 | C alvo 1.0ATR ate 240min | COMPRA | 208 | 64 | 3.07 | nao | 27.04 | 1 |  | 8,370.75 | 8,370.75 | 20.88 | -2,021.70 | 23.87 | 100.00 | 2/2 | 2/2 | 7,562.92 | 9,178.57 | 1,578.07 |
| month=7 & price_position_weekly_open=Q1 | C alvo 0.5ATR ate 240min | COMPRA | 208 | 64 | 3.30 | nao | 10.77 | 1 |  | 3,396.34 | 3,396.34 | 17.30 | -2,091.03 | 23.58 | 100.00 | 2/2 | 2/2 | 2,965.75 | 3,826.93 | 1,578.07 |
| month=7 & price_position_weekly_open=Q1 | C alvo 0.5ATR ate 60min | COMPRA | 237 | 64 | 2.28 | nao | 7.73 | 1 |  | 3,254.80 | 3,254.80 | 14.47 | -2,212.83 | 22.61 | 98.44 | 2/2 | 2/2 | 2,776.64 | 3,732.96 | 1,578.07 |
| month=7 & price_position_weekly_open=Q1 | C alvo 1.0ATR ate 60min | COMPRA | 237 | 64 | 3.52 | nao | 2.94 | 1 |  | 6,919.92 | 6,919.92 | 9.50 | -2,313.58 | 12.46 | 93.75 | 2/2 | 2/2 | 6,423.37 | 7,416.47 | 1,578.07 |
| hour=6 & mtf_H4=BREAK_DOWN | C alvo 2.0ATR ate 60min | COMPRA | 144 | 48 | 2.35 | nao | 2.11 | 1 |  | 11,847.78 | 11,847.78 | 8.88 | -2,175.64 | 10.36 | 87.50 | 2/2 | 10/11 | 13,192.54 | 10,503.03 | 1,654.75 |
| session=LONDON & price_position_daily_open=Q1 | V alvo 2.0ATR ate 240min | VENDA | 2,796 | 1,068 | 2.06 | nao | 1.68 | 1 |  | 8,675.85 | 8,675.85 | 7.67 | -902.18 | 8.51 | 84.83 | 2/2 | 14/18 | 10,352.03 | 6,999.67 | 1,926.64 |
| month=7 & price_position_weekly_open=Q1 | C alvo 2.0ATR ate 60min | COMPRA | 237 | 64 | 3.21 | nao | 2.09 | 1 |  | 9,805.68 | 9,805.68 | 7.17 | -2,175.64 | 8.66 | 82.81 | 2/2 | 2/2 | 8,917.76 | 10,693.61 | 1,578.07 |
| price_position_weekly_open=Q1 & price_position_monthly_open=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 420 | 288 | 2.18 | nao | 1.66 | 1 |  | 5,062.45 | 5,062.45 | 6.38 | -2,313.58 | 9.25 | 79.17 | 2/2 | 3/3 | 7,856.53 | 2,268.36 | 1,635.80 |

### M15 — modo `hit`

- eventos: 68,201 (2024-01-22 a 2026-10-16); descoberta 40,824 (até 2025-09-11), validação 27,281 (a partir de 2025-09-12)
- variáveis: 62; séries por variável/par: 18
- **hipóteses testadas: 641,046**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 2.0%, top 1000: 1.7%, top 10000: 1.1%
- **placebo** (6 deslocamentos): top 100: 2.0% (máx 8.0%), top 1000: 1.0% (máx 1.5%), top 10000: 0.6% (máx 0.8%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 40,460 | -0.068 |  | -1,818.645 |
| C alvo 0.5ATR/60min liquido | 39,387 | -0.067 |  | -1,803.419 |
| C alvo 0.5ATR/240min liquido | 35,176 | -0.072 |  | -1,941.873 |
| C alvo 1.0ATR/15min liquido | 40,460 | -0.065 |  | -1,750.264 |
| C alvo 1.0ATR/60min liquido | 39,387 | -0.067 |  | -1,788.842 |
| C alvo 1.0ATR/240min liquido | 35,176 | -0.065 |  | -1,736.503 |
| C alvo 2.0ATR/15min liquido | 40,460 | -0.060 |  | -1,616.473 |
| C alvo 2.0ATR/60min liquido | 39,387 | -0.060 |  | -1,611.093 |
| C alvo 2.0ATR/240min liquido | 35,176 | -0.048 |  | -1,291.255 |
| V alvo 0.5ATR/15min liquido | 40,460 | -0.068 |  | -1,825.526 |
| V alvo 0.5ATR/60min liquido | 39,387 | -0.080 |  | -2,136.871 |
| V alvo 0.5ATR/240min liquido | 35,176 | -0.120 |  | -3,221.838 |
| V alvo 1.0ATR/15min liquido | 40,460 | -0.070 |  | -1,885.026 |
| V alvo 1.0ATR/60min liquido | 39,387 | -0.083 |  | -2,213.436 |
| V alvo 1.0ATR/240min liquido | 35,176 | -0.137 |  | -3,683.910 |
| V alvo 2.0ATR/15min liquido | 40,460 | -0.070 |  | -1,883.336 |
| V alvo 2.0ATR/60min liquido | 39,387 | -0.086 |  | -2,310.185 |
| V alvo 2.0ATR/240min liquido | 35,176 | -0.157 |  | -4,220.362 |

**M15/hit: famílias distintas validadas: 4; com líquido positivo e significativo na validação (custo realista): 4.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| prev_day_low_distance_atr=Q5 & atr_ratio=Q5 | C alvo 2.0ATR ate 240min | COMPRA | 701 | 460 | 2.14 | nao | 2.10 | 1 |  | 21,477.82 | 21,477.82 | 7.99 | -3,340.65 | 9.28 | 64.78 | 3/3 | 17/27 | 17,887.11 | 25,068.53 | 1,977.88 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 220 | 138 | 3.10 | nao | 2.52 | 1 |  | 15,066.47 | 15,066.47 | 4.25 | -2,233.36 | 4.88 | 70.29 | 3/3 | 19/23 | 23,436.31 | 6,696.62 | 1,736.13 |
| hour=21 & previous_low_distance_atr=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 245 | 236 | 2.14 | nao | 1.96 | 1 |  | 7,744.03 | 7,744.03 | 3.24 | -2,233.36 | 4.19 | 58.47 | 3/3 | 21/29 | 10,020.16 | 5,467.91 | 1,745.16 |
| day_of_week=SUNDAY & prev_day_high_distance_atr=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 220 | 138 | 2.52 | nao | 1.71 | 1 |  | 7,640.81 | 7,640.81 | 2.75 | -2,523.12 | 3.66 | 74.64 | 3/3 | 18/23 | 12,468.35 | 2,813.27 | 1,736.13 |

### M30 — modo `hit`

- eventos: 34,040 (2024-01-22 a 2026-10-16); descoberta 20,410 (até 2025-09-14), validação 13,616 (a partir de 2025-09-15)
- variáveis: 62; séries por variável/par: 18
- **hipóteses testadas: 556,242**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 6.0%, top 1000: 2.2%, top 10000: 1.1%
- **placebo** (6 deslocamentos): top 100: 0.8% (máx 3.0%), top 1000: 0.8% (máx 1.1%), top 10000: 0.6% (máx 0.7%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 20,380 | -0.046 |  | -1,777.576 |
| C alvo 0.5ATR/60min liquido | 19,684 | -0.043 |  | -1,672.086 |
| C alvo 0.5ATR/240min liquido | 17,573 | -0.042 |  | -1,626.666 |
| C alvo 1.0ATR/15min liquido | 20,380 | -0.043 |  | -1,674.160 |
| C alvo 1.0ATR/60min liquido | 19,684 | -0.044 |  | -1,725.331 |
| C alvo 1.0ATR/240min liquido | 17,573 | -0.036 |  | -1,417.171 |
| C alvo 2.0ATR/15min liquido | 20,380 | -0.041 |  | -1,618.188 |
| C alvo 2.0ATR/60min liquido | 19,684 | -0.037 |  | -1,446.239 |
| C alvo 2.0ATR/240min liquido | 17,573 | -0.019 |  | -735.444 |
| V alvo 0.5ATR/15min liquido | 20,380 | -0.045 |  | -1,751.471 |
| V alvo 0.5ATR/60min liquido | 19,684 | -0.055 |  | -2,130.813 |
| V alvo 0.5ATR/240min liquido | 17,573 | -0.089 |  | -3,462.104 |
| V alvo 1.0ATR/15min liquido | 20,380 | -0.046 |  | -1,803.911 |
| V alvo 1.0ATR/60min liquido | 19,684 | -0.061 |  | -2,371.362 |
| V alvo 1.0ATR/240min liquido | 17,573 | -0.098 |  | -3,806.153 |
| V alvo 2.0ATR/15min liquido | 20,380 | -0.047 |  | -1,831.493 |
| V alvo 2.0ATR/60min liquido | 19,684 | -0.060 |  | -2,346.831 |
| V alvo 2.0ATR/240min liquido | 17,573 | -0.111 |  | -4,321.961 |

**M30/hit: famílias distintas validadas: 9; com líquido positivo e significativo na validação (custo realista): 7.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hour=15 & previous_high_distance_atr=Q1 | V alvo 0.5ATR ate 60min | VENDA | 156 | 147 | 2.97 | nao | 1.79 | 1 |  | 6,447.96 | 6,447.96 | 3.10 | -1,289.49 | 3.72 | 73.47 | 3/3 | 24/32 | 12,981.51 | 2.71 | 1,855.73 |
| hour=15 & cum10=Q1 | V alvo 0.5ATR ate 60min | VENDA | 228 | 193 | 3.57 | nao | 1.74 | 1 |  | 5,925.35 | 5,925.35 | 3.05 | -1,289.49 | 3.73 | 74.09 | 3/3 | 25/33 | 11,067.22 | 836.49 | 1,811.94 |
| hour=15 & swing_high_distance_atr=Q1 | V alvo 0.5ATR ate 60min | VENDA | 229 | 171 | 3.60 | nao | 1.81 | 1 |  | 5,977.27 | 5,977.27 | 2.98 | -1,289.49 | 3.63 | 72.51 | 3/3 | 26/32 | 11,119.94 | 894.40 | 1,850.00 |
| day_of_week=SUNDAY & previous_high_distance_atr=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 124 | 85 | 2.88 | nao | 2.31 | 1 |  | 12,653.99 | 12,653.99 | 2.91 | -2,430.27 | 3.47 | 68.24 | 3/3 | 19/21 | 20,921.39 | 4,578.85 | 1,769.52 |
| hour=20 & cum10=Q1 | C alvo 2.0ATR ate 15min | COMPRA | 160 | 96 | 2.42 | nao | 2.43 | 1 |  | 6,551.20 | 6,551.20 | 2.23 | -1,829.39 | 2.85 | 55.21 | 3/3 | 21/27 | 4,393.52 | 8,708.88 | 1,650.73 |
| hour=20 & cum10=Q1 | C alvo 1.0ATR ate 15min | COMPRA | 160 | 96 | 2.10 | nao | 2.31 | 1 |  | 5,383.43 | 5,383.43 | 2.02 | -1,910.82 | 2.73 | 55.21 | 3/3 | 21/27 | 4,591.08 | 6,175.77 | 1,650.73 |
| day_of_week=SUNDAY & previous_high_distance_atr=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 124 | 85 | 2.47 | nao | 1.78 | 1 |  | 9,990.38 | 9,990.38 | 1.99 | -2,249.65 | 2.43 | 58.82 | 3/3 | 18/21 | 14,899.03 | 5,195.87 | 1,769.52 |

### H1 — modo `hit`

- eventos: 32,635 (2021-06-07 a 2026-10-16); descoberta 19,557 (até 2024-09-10), validação 13,054 (a partir de 2024-09-11)
- variáveis: 63; séries por variável/par: 18
- **hipóteses testadas: 559,188**; passaram no BH (q=5%) na descoberta: **0**; confirmadas na validação: **0**
- melhores N da descoberta que repetem na validação: top 100: 1.0%, top 1000: 2.6%, top 10000: 1.8%
- **placebo** (6 deslocamentos): top 100: 0.8% (máx 3.0%), top 1000: 0.5% (máx 0.7%), top 10000: 0.3% (máx 0.7%); BH: média 0.2 (máx 1); confirmadas: média 0.0 (máx 0)

Expectativa **incondicional** (todas as velas, sem filtro) na descoberta:

| serie | n | medio_ATR_desc | t_desc | medio_pts_aprox |
|---|---|---|---|---|
| C alvo 0.5ATR/15min liquido | 19,539 | -0.071 |  | -3,192.542 |
| C alvo 0.5ATR/60min liquido | 18,634 | -0.076 |  | -3,394.448 |
| C alvo 0.5ATR/240min liquido | 15,961 | -0.095 |  | -4,253.920 |
| C alvo 1.0ATR/15min liquido | 19,539 | -0.072 |  | -3,225.966 |
| C alvo 1.0ATR/60min liquido | 18,634 | -0.078 |  | -3,503.408 |
| C alvo 1.0ATR/240min liquido | 15,961 | -0.108 |  | -4,868.091 |
| C alvo 2.0ATR/15min liquido | 19,539 | -0.071 |  | -3,183.279 |
| C alvo 2.0ATR/60min liquido | 18,634 | -0.073 |  | -3,297.008 |
| C alvo 2.0ATR/240min liquido | 15,961 | -0.108 |  | -4,855.131 |
| V alvo 0.5ATR/15min liquido | 19,539 | -0.065 |  | -2,935.127 |
| V alvo 0.5ATR/60min liquido | 18,634 | -0.069 |  | -3,115.137 |
| V alvo 0.5ATR/240min liquido | 15,961 | -0.080 |  | -3,576.834 |
| V alvo 1.0ATR/15min liquido | 19,539 | -0.069 |  | -3,082.632 |
| V alvo 1.0ATR/60min liquido | 18,634 | -0.074 |  | -3,306.921 |
| V alvo 1.0ATR/240min liquido | 15,961 | -0.079 |  | -3,560.389 |
| V alvo 2.0ATR/15min liquido | 19,539 | -0.068 |  | -3,047.718 |
| V alvo 2.0ATR/60min liquido | 18,634 | -0.070 |  | -3,120.485 |
| V alvo 2.0ATR/240min liquido | 15,961 | -0.070 |  | -3,143.420 |

**H1/hit: famílias distintas validadas: 7; com líquido positivo e significativo na validação (custo realista): 7.**

Famílias viáveis (ordenadas por t líquido):

| condicao | serie | lado | n_desc | n_val | t_desc | passou_BH | t_val | n_formas_equivalentes | bruto_pts_val | liq_A_pts_val | liq_B_pts_val | t_liq_B | base_B_pts_val | t_delta | pct_pos_B | anos_pos | meses_pos | metade1_B | metade2_B | custo_medio_pts |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mtf_W1=BEARISH & month=6 | V alvo 2.0ATR ate 240min | VENDA | 475 | 234 | 2.28 | nao | 2.28 | 1 |  | 21,463.86 | 21,463.86 | 4.50 | -2,279.28 | 5.00 | 63.25 | 3/3 | 3/3 | 49,278.12 | -6,350.41 | 1,707.60 |
| news_state=NONE_60M & swing_high_distance_atr=Q1 | V alvo 1.0ATR ate 240min | VENDA | 640 | 1,904 | 2.06 | nao | 2.17 | 1 |  | 5,183.96 | 5,183.96 | 3.04 | -2,537.87 | 4.92 | 57.67 | 4/4 | 25/37 | 2,032.01 | 8,335.92 | 1,695.20 |
| hour=7 & price_position_daily_open=Q5 | C alvo 2.0ATR ate 60min | COMPRA | 151 | 190 | 2.04 | nao | 2.79 | 2 |  | 6,902.79 | 6,902.79 | 2.61 | -1,466.48 | 3.17 | 54.21 | 5/6 | 26/40 | 9,126.95 | 4,678.64 | 1,660.50 |
| mtf_H1=BULLISH & atr_ratio=Q5 | C alvo 2.0ATR ate 240min | COMPRA | 1,222 | 676 | 2.02 | nao | 1.72 | 2 |  | 10,225.75 | 10,225.75 | 2.60 | -1,157.83 | 3.01 | 53.55 | 6/6 | 33/53 | 14,727.25 | 5,724.26 | 1,672.12 |
| month=3 & pat_BULLISH_ENGULFING=Y | C alvo 0.5ATR ate 60min | COMPRA | 132 | 79 | 2.00 | nao | 2.67 | 1 |  | 9,778.19 | 9,778.19 | 2.59 | -1,831.86 | 3.06 | 67.09 | 5/5 | 5/5 | 11,002.49 | 8,584.49 | 1,611.65 |
| news_state=NONE_60M & swing_high_distance_atr=Q1 | V alvo 0.5ATR ate 240min | VENDA | 640 | 1,904 | 2.46 | nao | 2.06 | 1 |  | 3,278.94 | 3,278.94 | 2.42 | -2,418.58 | 4.54 | 72.48 | 4/4 | 27/37 | 1,572.25 | 4,985.64 | 1,695.20 |
| slot_hhmm=15:00 & lower_wick_pct=Q4 | V alvo 0.5ATR ate 60min | VENDA | 164 | 109 | 2.07 | nao | 1.72 | 2 |  | 5,917.58 | 5,917.58 | 1.72 | -2,083.39 | 2.32 | 68.81 | 6/6 | 17/30 | 9,656.28 | 2,246.86 | 1,740.44 |

## 7. Veredito automático do ativo

- famílias distintas validadas (|t|>2 na descoberta, mesmo sinal na validação): **1794**
- com líquido positivo e t>1,645 na validação, custo realista: **269**; dessas, sobreviveram ao BH: **1**; e positivas nas duas metades da validação: **1**
- **Candidatas que passam todos os filtros** (ainda precisam de teste futuro/out-of-sample real antes de qualquer capital):

| tf | modo | condicao | serie | lado | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | hit | session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 0.5ATR ate 240min | VENDA | 115 | 3,200.25 | -1,780.03 | 26.18 | 23.75 | 100.00 | 2/2 | 12/12 |


## 8. Anexos (CSV na mesma pasta)

`cobertura.csv`, `perfil_hora_utc.csv`, `relogio_h1_*.csv`, `resumo_mineracao.csv`, `familias_todas.csv`, `familias_<TF>_<modo>.csv`, `univariada_<TF>_<modo>.csv` (todas as variáveis x valores x horizontes: n, t descoberta, t validação).


_(tempo de geração 1283s)_
