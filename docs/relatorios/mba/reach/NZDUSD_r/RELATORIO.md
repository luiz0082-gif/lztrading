# NZDUSD_r — investigação de alcance, horário e repetição

## A. Qualidade e cobertura dos dados

| tf | first | last | trading_days | bars | gaps_gt_bar | gaps_gt15m | max_gap_min | pct_tick_spread | spread_med | spread_p90 | bad_ohlc | dup_time |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 2026-04-06 22:38:00 | 2026-10-16 23:58:00 | 140 | 200000 | 160 | 0 | 5 | 61.8 | 3.3 | 5.3 | 0 | 0 |
| M5 | 2025-05-15 03:25:00 | 2026-10-16 23:50:00 | 370 | 106504 | 2 | 1 | 60 | 23.2 | 2.0 | 4.6 | 0 | 0 |
| M15 | 2024-01-22 05:30:00 | 2026-10-16 23:30:00 | 712 | 68224 | 3 | 3 | 90 | 12.1 | 1.0 | 4.0 | 0 | 0 |


Ponto MT5 = 1e-05, tick size = 1e-05, tick value = 1.0 (USD por tick por lote), contrato = 100000.0. Barras de BID. Custo = spread medido nos ticks (perfil por faixa de 30 min do servidor onde não há tick) + swap; comissão não declarada pela corretora (não incluída).


**Limitação:** o M1 deste ativo só cobre ~mar/abr–out/2026 (≈140–158 dias, um único regime). Resultados de M1 são exploratórios; a confirmação vem de M5 (mai/2025→) e M15 (jan/2024→).


## C. Distâncias percorridas (operação executável, líquida de spread)


**M15, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 67775 | 63.3 | 55.5 | 55.1-55.8 | 0.0 | 30.0 | 17.3 | 54.1 | 36.0 | 60.2 | 6.0 | 39.9 |
| 25 | SELL | 67775 | 63.9 | 56.8 | 56.4-57.2 | 15.0 | 45.0 | 17.8 | 57.3 | 36.4 | 59.8 | 6.6 | 40.7 |
| 50 | BUY | 67775 | 36.5 | 31.6 | 31.3-32.0 | 15.0 | 45.0 | 16.9 | 55.4 | 27.8 | 41.1 | 0.9 | 40.9 |
| 50 | SELL | 67775 | 37.7 | 32.9 | 32.5-33.2 | 15.0 | 45.0 | 17.3 | 61.2 | 28.3 | 40.7 | 1.7 | 42.0 |
| 100 | BUY | 67775 | 11.4 | 9.9 | 9.7-10.1 | 30.0 | 45.0 | 17.4 | 65.2 | 9.4 | 15.0 | 0.2 | 38.9 |
| 100 | SELL | 67775 | 12.8 | 10.5 | 10.3-10.8 | 30.0 | 45.0 | 18.2 | 70.4 | 10.0 | 14.5 | 0.3 | 41.3 |
| 150 | BUY | 67775 | 4.0 | 3.5 | 3.4-3.7 | 30.0 | 45.0 | 20.0 | 87.3 | 3.4 | 5.8 | 0.1 | 37.5 |
| 150 | SELL | 67775 | 5.0 | 3.7 | 3.6-3.9 | 30.0 | 45.0 | 19.4 | 89.2 | 3.6 | 5.0 | 0.1 | 42.2 |
| 200 | BUY | 67775 | 1.8 | 1.6 | 1.5-1.7 | 30.0 | 45.0 | 23.1 | 98.5 | 1.6 | 2.6 | 0.0 | 37.9 |
| 200 | SELL | 67775 | 2.0 | 1.6 | 1.5-1.7 | 30.0 | 45.0 | 23.4 | 110.3 | 1.6 | 2.1 | 0.0 | 43.1 |


**M15, janela 240 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 66606 | 82.0 | 77.2 | 76.9-77.5 | 15.0 | 135.0 | 25.8 | 99.3 | 37.5 | 62.4 | 6.2 | 40.1 |
| 25 | SELL | 66606 | 83.9 | 79.3 | 79.0-79.6 | 15.0 | 135.0 | 26.4 | 98.2 | 38.0 | 62.0 | 7.0 | 40.9 |
| 50 | BUY | 66606 | 65.0 | 60.5 | 60.1-60.9 | 45.0 | 165.0 | 30.9 | 107.2 | 40.3 | 57.9 | 1.2 | 41.5 |
| 50 | SELL | 66606 | 69.0 | 63.7 | 63.3-64.0 | 45.0 | 165.0 | 32.1 | 104.3 | 41.9 | 56.5 | 2.8 | 43.8 |
| 100 | BUY | 66606 | 38.2 | 35.2 | 34.8-35.6 | 90.0 | 195.0 | 33.0 | 112.3 | 30.8 | 43.3 | 0.6 | 41.9 |
| 100 | SELL | 66606 | 42.9 | 37.6 | 37.3-38.0 | 90.0 | 195.0 | 33.5 | 107.2 | 33.2 | 41.1 | 0.8 | 45.2 |
| 150 | BUY | 66606 | 21.1 | 19.5 | 19.2-19.8 | 120.0 | 210.0 | 32.6 | 118.5 | 18.3 | 26.3 | 0.2 | 41.2 |
| 150 | SELL | 66606 | 25.0 | 20.8 | 20.5-21.1 | 120.0 | 210.0 | 32.6 | 112.2 | 19.8 | 23.0 | 0.3 | 46.5 |
| 200 | BUY | 66606 | 11.9 | 11.0 | 10.7-11.2 | 135.0 | 210.0 | 32.4 | 125.2 | 10.6 | 14.9 | 0.1 | 41.7 |
| 200 | SELL | 66606 | 13.9 | 11.6 | 11.3-11.8 | 135.0 | 210.0 | 33.3 | 116.5 | 11.2 | 12.7 | 0.1 | 47.1 |
| 300 | BUY | 66606 | 4.2 | 4.0 | 3.8-4.1 | 150.0 | 210.0 | 35.4 | 130.7 | 3.9 | 4.8 | 0.0 | 45.0 |
| 300 | SELL | 66606 | 4.6 | 4.1 | 3.9-4.2 | 135.0 | 210.0 | 38.5 | 133.2 | 4.0 | 4.4 | 0.0 | 47.8 |
| 400 | BUY | 66606 | 1.6 | 1.5 | 1.4-1.6 | 150.0 | 225.0 | 35.5 | 126.7 | 1.5 | 2.0 | 0.0 | 42.9 |
| 400 | SELL | 66606 | 1.9 | 1.6 | 1.6-1.8 | 150.0 | 210.0 | 40.5 | 144.2 | 1.6 | 1.7 | 0.0 | 49.0 |


**M1, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 198484 | 59.1 | 51.0 | 50.8-51.2 | 16.0 | 46.0 | 14.9 | 47.0 | 36.1 | 58.7 | 0.1 | 38.2 |
| 25 | SELL | 198484 | 62.8 | 55.2 | 55.0-55.4 | 16.0 | 46.0 | 14.6 | 45.3 | 39.6 | 55.0 | 0.3 | 42.0 |
| 50 | BUY | 198484 | 32.2 | 27.1 | 26.9-27.3 | 27.0 | 52.0 | 15.3 | 47.5 | 24.6 | 39.0 | 0.1 | 38.8 |
| 50 | SELL | 198484 | 35.3 | 29.3 | 29.1-29.5 | 28.0 | 52.0 | 15.1 | 49.3 | 26.5 | 36.9 | 0.3 | 42.0 |
| 100 | BUY | 198484 | 9.2 | 7.6 | 7.5-7.7 | 36.0 | 55.0 | 15.7 | 54.0 | 7.4 | 13.3 | 0.0 | 35.8 |
| 100 | SELL | 198484 | 10.6 | 7.9 | 7.8-8.0 | 37.0 | 55.0 | 16.2 | 70.3 | 7.5 | 13.3 | 0.2 | 36.4 |
| 150 | BUY | 198484 | 3.1 | 2.6 | 2.6-2.7 | 39.0 | 55.0 | 18.4 | 69.0 | 2.6 | 5.4 | 0.0 | 32.5 |
| 150 | SELL | 198484 | 4.2 | 2.6 | 2.6-2.7 | 38.0 | 56.0 | 20.3 | 101.0 | 2.6 | 5.1 | 0.0 | 33.9 |
| 200 | BUY | 198484 | 1.3 | 1.1 | 1.0-1.1 | 37.0 | 55.0 | 20.5 | 76.2 | 1.1 | 2.4 | 0.0 | 30.7 |
| 200 | SELL | 198484 | 1.8 | 1.1 | 1.1-1.2 | 36.0 | 55.0 | 37.3 | 123.1 | 1.1 | 2.2 | 0.0 | 34.1 |


## B. Varredura por horário (servidor)


% de entradas (M15, janela 60 min) que alcançaram a distância, por hora do servidor:


| hour | BUY ≥100 | SELL ≥100 |
|---|---|---|
| 0 | 3.6 | 5.2 |
| 1 | 6.8 | 5.2 |
| 2 | 9.1 | 8.6 |
| 3 | 13.7 | 13.9 |
| 4 | 13.4 | 12.8 |
| 5 | 9.0 | 8.4 |
| 6 | 5.2 | 6.0 |
| 7 | 4.5 | 5.8 |
| 8 | 8.7 | 8.1 |
| 9 | 12.4 | 12.8 |
| 10 | 12.2 | 14.0 |
| 11 | 9.3 | 9.0 |
| 12 | 6.0 | 5.8 |
| 13 | 6.2 | 5.3 |
| 14 | 11.8 | 12.1 |
| 15 | 23.6 | 20.3 |
| 16 | 23.6 | 24.1 |
| 17 | 20.5 | 22.8 |
| 18 | 10.2 | 12.6 |
| 19 | 7.2 | 8.5 |
| 20 | 7.0 | 7.5 |
| 21 | 5.9 | 6.0 |
| 22 | 3.6 | 3.9 |
| 23 | 2.8 | 14.8 |


Minuto a minuto (M1, janela 60 min, k = 100 pts; tabela completa em `B_varredura_relogio_M1_W60.csv.gz` com todos os minutos e limiares). Maiores e menores taxas de alcance:


Maior alcance (BUY):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 16:55 | 139 | 31 | 22.3 | 23 | 16.6 | 23.0 | 15.8 | 24.0 | 21.3 |
| 15:11 | 139 | 31 | 22.3 | 20 | 14.4 | 22.3 | 14.4 | 31.0 | 16.3 |
| 16:46 | 139 | 31 | 22.3 | 22 | 15.8 | 22.3 | 17.3 | 32.0 | 28.1 |
| 16:17 | 139 | 31 | 22.3 | 15 | 10.8 | 23.0 | 11.5 | 31.0 | 15.1 |
| 15:10 | 139 | 30 | 21.6 | 20 | 14.4 | 22.3 | 15.8 | 29.0 | 15.3 |
| 16:19 | 139 | 30 | 21.6 | 16 | 11.5 | 21.6 | 10.1 | 28.0 | 12.8 |
| 16:33 | 139 | 30 | 21.6 | 21 | 15.1 | 22.3 | 15.8 | 32.0 | 29.5 |
| 15:12 | 139 | 30 | 21.6 | 19 | 13.7 | 23.7 | 15.1 | 30.5 | 21.4 |
| 14:37 | 139 | 30 | 21.6 | 21 | 15.1 | 22.3 | 15.1 | 44.5 | 21.6 |
| 16:57 | 139 | 29 | 20.9 | 22 | 15.8 | 21.6 | 16.6 | 26.0 | 19.3 |


Maior alcance (SELL):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 23:39 | 112 | 1 | 0.9 | 27 | 24.1 | 0.0 | 67.9 | 22.0 | 442.5 |
| 23:36 | 112 | 1 | 0.9 | 27 | 24.1 | 0.0 | 67.9 | 25.0 | 450.5 |
| 23:30 | 112 | 1 | 0.9 | 27 | 24.1 | 0.9 | 67.0 | 31.0 | 442.5 |
| 23:26 | 112 | 1 | 0.9 | 27 | 24.1 | 0.9 | 67.9 | 35.0 | 436.1 |
| 23:27 | 112 | 2 | 1.8 | 27 | 24.1 | 0.9 | 67.0 | 41.0 | 241.8 |
| 23:28 | 112 | 2 | 1.8 | 27 | 24.1 | 0.9 | 67.0 | 40.0 | 245.4 |
| 23:32 | 112 | 2 | 1.8 | 27 | 24.1 | 0.9 | 67.0 | 36.0 | 249.5 |
| 23:06 | 139 | 1 | 0.7 | 33 | 23.7 | 0.7 | 61.1 | 3.0 | 30.1 |
| 23:05 | 140 | 1 | 0.7 | 33 | 23.6 | 0.7 | 59.3 | 4.0 | 30.1 |
| 23:40 | 112 | 1 | 0.9 | 26 | 23.2 | 0.0 | 68.8 | 21.0 | 445.5 |


Menor alcance (mercado parado):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 23:59 | 112 | 0 | 0.0 | 25 | 22.3 | 0.9 | 73.2 |  |  |
| 23:12 | 112 | 0 | 0.0 | 25 | 22.3 | 0.9 | 68.8 |  |  |
| 23:11 | 112 | 0 | 0.0 | 26 | 23.2 | 0.9 | 69.6 |  |  |
| 23:52 | 112 | 0 | 0.0 | 25 | 22.3 | 0.0 | 71.4 |  |  |
| 23:51 | 112 | 0 | 0.0 | 22 | 19.6 | 0.0 | 71.4 |  |  |


Maior assimetria BUY−SELL (só descritivo; o teste de direção está na seção E):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med | buy_menos_sell |
|---|---|---|---|---|---|---|---|---|---|---|
| 23:26 | 112 | 1 | 0.9 | 27 | 24.1 | 0.9 | 67.9 | 35.0 | 436.1 | -23.2 |
| 23:39 | 112 | 1 | 0.9 | 27 | 24.1 | 0.0 | 67.9 | 22.0 | 442.5 | -23.2 |
| 23:30 | 112 | 1 | 0.9 | 27 | 24.1 | 0.9 | 67.0 | 31.0 | 442.5 | -23.2 |
| 23:36 | 112 | 1 | 0.9 | 27 | 24.1 | 0.0 | 67.9 | 25.0 | 450.5 | -23.2 |
| 23:11 | 112 | 0 | 0.0 | 26 | 23.2 | 0.9 | 69.6 |  |  | -23.2 |
| 23:06 | 139 | 1 | 0.7 | 33 | 23.7 | 0.7 | 61.1 | 3.0 | 30.1 | -23.0 |
| 23:05 | 140 | 1 | 0.7 | 33 | 23.6 | 0.7 | 59.3 | 4.0 | 30.1 | -22.9 |
| 23:59 | 112 | 0 | 0.0 | 25 | 22.3 | 0.9 | 73.2 |  |  | -22.3 |
| 23:24 | 112 | 1 | 0.9 | 26 | 23.2 | 0.9 | 67.9 | 37.0 | 440.1 | -22.3 |
| 23:52 | 112 | 0 | 0.0 | 25 | 22.3 | 0.0 | 71.4 |  |  | -22.3 |


## E. Direção (BUY vs SELL) por horário — teste contra o próprio dia

y = +1 se o preço anda +k antes de −k, −1 no contrário. Tira-se a média do dia (dias de tendência não contam como sinal) e testa-se cada horário. Descoberta 60% / validação 40% cronológicos; BH na descoberta; placebo = troca aleatória de sinal por dia (200×).


| tf | W | clock | dir_tests | dir_validated | dir_fwer_and_val | dir_placebo_mean | dir_placebo_max |
|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 480.00 | 20.00 | 20.00 | 0.00 | 0.00 |
| M1 | 60 | hour | 120.00 | 5.00 | 5.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 7,200.00 | 308.00 | 297.00 | 0.00 | 0.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |
| M1 | 240 | 15m | 672.00 | 73.00 | 62.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 168.00 | 19.00 | 17.00 | 0.00 | 0.00 |
| M1 | 240 | slot | 10,080.00 | 945.00 | 805.00 | 0.00 | 0.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |
| M15 | 60 | hour | 120.00 | 9.00 | 9.00 | 0.00 | 0.00 |
| M15 | 60 | slot | 480.00 | 26.00 | 23.00 | 0.01 | 1.00 |
| M15 | 60 | wd_hour | 600.00 | 17.00 | 12.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 168.00 | 19.00 | 14.00 | 0.00 | 0.00 |
| M15 | 240 | slot | 672.00 | 67.00 | 48.00 | 0.01 | 1.00 |
| M15 | 240 | wd_hour | 826.00 | 36.00 | 18.00 | 0.00 | 0.00 |
| M5 | 60 | 15m | 480.00 | 35.00 | 25.00 | 0.00 | 0.00 |
| M5 | 60 | hour | 120.00 | 10.00 | 8.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 1,440.00 | 90.00 | 61.00 | 0.00 | 0.00 |
| M5 | 60 | wd_hour | 600.00 | 24.00 | 19.00 | 0.01 | 1.00 |
| M5 | 240 | 15m | 672.00 | 84.00 | 75.00 | 0.01 | 2.00 |
| M5 | 240 | hour | 168.00 | 22.00 | 19.00 | 0.02 | 3.00 |
| M5 | 240 | slot | 2,016.00 | 234.00 | 204.00 | 0.02 | 3.00 |
| M5 | 240 | wd_hour | 826.00 | 61.00 | 37.00 | 0.01 | 1.00 |


Horários validados (descoberta + validação):

| arquivo | clock | direction | ks | n_dias | sobe_antes | cai_antes | t_desc | t_val | fwer |
|---|---|---|---|---|---|---|---|---|---|
| slot_M1_W60 | 23:56 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 74.11 | 38.06 | 20.87 | True |
| slot_M1_W240 | 23:56 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 3.57 | 76.79 | 36.98 | 18.98 | True |
| 15m_M5_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 0.34 | 82.94 | 36.27 | 34.69 | True |
| slot_M5_W60 | 23:50 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 0.34 | 81.23 | 35.75 | 34.14 | True |
| slot_M5_W60 | 23:55 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 0.68 | 81.91 | 32.50 | 32.50 | True |
| slot_M5_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 0.34 | 80.55 | 32.46 | 25.63 | True |
| slot_M5_W60 | 23:40 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 0.68 | 80.55 | 30.65 | 22.71 | True |
| slot_M5_W240 | 23:50 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 4.44 | 82.59 | 30.37 | 33.16 | True |
| 15m_M5_W240 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 3.75 | 83.96 | 29.99 | 33.73 | True |
| slot_M5_W60 | 23:25 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 1.02 | 73.04 | 29.40 | 14.79 | True |
| 15m_M5_W60 | 23:30 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 1.02 | 80.55 | 29.22 | 21.43 | True |
| 15m_M5_W60 | 23:15 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 1.36 | 70.99 | 29.22 | 15.98 | True |
| slot_M5_W60 | 23:20 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 1.71 | 67.92 | 27.63 | 14.91 | True |
| slot_M5_W60 | 23:35 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 1.02 | 79.52 | 27.51 | 19.43 | True |
| slot_M5_W240 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 4.44 | 82.59 | 27.50 | 22.72 | True |
| slot_M5_W60 | 23:30 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 1.36 | 72.70 | 26.43 | 16.89 | True |
| slot_M1_W60 | 23:52 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 71.43 | 26.42 | 21.16 | True |
| slot_M5_W60 | 23:10 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 2.05 | 70.31 | 25.79 | 15.76 | True |
| 15m_M1_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 76.79 | 25.78 | 21.45 | True |
| slot_M5_W240 | 23:55 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 3.75 | 83.96 | 25.62 | 31.80 | True |
| slot_M1_W240 | 23:52 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 3.57 | 73.21 | 25.44 | 18.98 | True |
| slot_M5_W60 | 23:15 | SELL (cai k antes) | 25,50,100,150,200 | 293 | 1.36 | 68.26 | 25.39 | 15.91 | True |
| 15m_M1_W240 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 4.46 | 75.00 | 24.88 | 18.04 | True |
| slot_M1_W60 | 23:53 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 71.43 | 24.59 | 21.16 | True |
| slot_M1_W60 | 23:55 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 72.32 | 24.59 | 19.43 | True |
| slot_M1_W60 | 23:58 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 73.21 | 24.44 | 20.87 | True |
| hour_M1_W60 | 23h | SELL (cai k antes) | 25,50,100,150,200 | 140 | 0.00 | 70.71 | 24.23 | 13.27 | True |
| slot_M1_W240 | 23:58 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 3.57 | 75.89 | 23.64 | 18.99 | True |
| slot_M1_W60 | 23:48 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 68.75 | 23.41 | 13.91 | True |
| slot_M1_W60 | 23:49 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 70.54 | 23.41 | 21.16 | True |
| slot_M1_W240 | 23:53 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 2.68 | 73.21 | 23.37 | 18.98 | True |
| slot_M1_W60 | 23:51 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 71.43 | 22.91 | 21.16 | True |
| slot_M1_W60 | 23:57 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 72.32 | 22.55 | 20.87 | True |
| hour_M5_W60 | 23h | SELL (cai k antes) | 25,50,100,150,200 | 370 | 1.08 | 73.24 | 22.43 | 24.14 | True |
| slot_M1_W60 | 23:59 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.89 | 73.21 | 22.16 | 25.56 | True |
| slot_M1_W240 | 23:57 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 3.57 | 74.11 | 22.14 | 18.98 | True |
| slot_M1_W60 | 23:47 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 67.86 | 21.92 | 13.89 | True |
| slot_M1_W240 | 23:59 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 4.46 | 75.00 | 21.75 | 18.99 | True |
| hour_M5_W240 | 23h | SELL (cai k antes) | 25,50,100,150,200 | 293 | 6.49 | 81.57 | 21.40 | 18.11 | True |
| slot_M1_W60 | 23:35 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 67.86 | 21.38 | 7.49 | True |


## G. Operação executável por horário (alvo k, limite k / 2k / sem limite; custo e swap incluídos)

| tf | W | clock | ev_tests | ev_validated | ev_validated_bh | ev_clocks | ev_placebo_mean | ev_placebo_max |
|---|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 2,880.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | hour | 720.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 43,200.00 | 2.00 | 2.00 | 1.00 | 0.00 | 0.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |  |
| M1 | 240 | 15m | 4,032.00 | 5.00 | 5.00 | 5.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 1,008.00 | 1.00 | 1.00 | 1.00 | 0.00 | 0.00 |
| M1 | 240 | slot | 60,480.00 | 54.00 | 42.00 | 54.00 | 0.40 | 1.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |  |
| M15 | 60 | hour | 720.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 60 | slot | 2,880.00 | 12.00 | 12.00 | 1.00 | 0.00 | 0.00 |
| M15 | 60 | wd_hour | 3,600.00 | 12.00 | 12.00 | 1.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 1,008.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | slot | 4,032.00 | 3.00 | 0.00 | 2.00 | 0.00 | 0.00 |
| M15 | 240 | wd_hour | 4,956.00 | 3.00 | 1.00 | 2.00 | 0.00 | 0.00 |
| M5 | 60 | 15m | 2,880.00 | 3.00 | 3.00 | 2.00 | 0.00 | 0.00 |
| M5 | 60 | hour | 720.00 | 2.00 | 2.00 | 1.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 8,640.00 | 24.00 | 23.00 | 7.00 | 0.00 | 0.00 |
| M5 | 60 | wd_hour | 3,600.00 | 13.00 | 12.00 | 2.00 | 0.00 | 0.00 |
| M5 | 240 | 15m | 4,032.00 | 16.00 | 15.00 | 8.00 | 0.00 | 0.00 |
| M5 | 240 | hour | 1,008.00 | 6.00 | 4.00 | 3.00 | 0.00 | 0.00 |
| M5 | 240 | slot | 12,096.00 | 48.00 | 45.00 | 26.00 | 0.00 | 0.00 |
| M5 | 240 | wd_hour | 4,956.00 | 25.00 | 15.00 | 8.00 | 0.00 | 0.00 |


Combinações validadas (descoberta t≥3 e validação t≥1,645, média líquida > 0 nos dois períodos, com perdas na validação). `confirmado_em` = outro timeframe com o mesmo lado a ±10 min; `rolagem` = entrada ou janela tocando 23:00–01:15 do servidor (cotações de bid distorcidas pelo spread da rolagem):


| tf | W | clock | side | k_pts | adverse | n_days | win_pct | ev_pts | ev_disc | t_disc | ev_val | t_val | years_pos | bh_disc | confirmed_in | rolagem |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M15 | 240 | 23:45 | SELL | 50 | sem | 564 | 73.6 | 21.4 | 12.0 | 3.1 | 35.5 | 13.3 | 3/3 | False | M1,M5 | True |
| M5 | 240 | 23:55 | SELL | 25 | sem | 293 | 93.5 | 19.6 | 19.2 | 8.6 | 20.1 | 10.5 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 23:50 | SELL | 25 | sem | 293 | 94.2 | 19.6 | 19.1 | 8.0 | 20.4 | 10.4 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 23:40 | SELL | 25 | sem | 293 | 94.2 | 18.9 | 18.3 | 7.0 | 19.8 | 9.3 | 2/2 | True | M1,M15 | True |
| M5 | 60 | 23:00 | SELL | 100 | k | 370 | 6.2 | 17.0 | 8.9 | 3.1 | 29.2 | 8.4 | 2/2 | False | M1,M15 | True |
| M5 | 240 | 23:35 | SELL | 25 | sem | 293 | 92.8 | 18.0 | 17.4 | 6.8 | 18.8 | 8.3 | 2/2 | True | M1,M15 | True |
| M15 | 240 | 23:00 | SELL | 50 | sem | 564 | 65.1 | 17.3 | 10.2 | 3.1 | 27.9 | 8.2 | 3/3 | False | M1,M5 | True |
| M5 | 60 | 23:50 | SELL | 25 | sem | 293 | 87.7 | 16.3 | 15.9 | 7.4 | 17.0 | 8.1 | 2/2 | True | M1,M15 | True |
| M1 | 240 | 23:40 | SELL | 25 | sem | 112 | 90.2 | 17.0 | 15.7 | 3.2 | 18.9 | 7.7 | 1/1 | False | M15,M5 | True |
| M5 | 240 | 23:10 | SELL | 25 | sem | 293 | 90.8 | 16.5 | 15.4 | 5.5 | 18.2 | 7.1 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 23:20 | SELL | 25 | sem | 293 | 90.1 | 16.5 | 15.9 | 6.1 | 17.4 | 7.0 | 2/2 | True | M1 | True |
| M5 | 240 | 23:30 | SELL | 25 | sem | 293 | 93.5 | 18.8 | 19.5 | 8.5 | 17.8 | 6.7 | 2/2 | True | M1 | True |
| M5 | 60 | 23:55 | SELL | 25 | sem | 293 | 86.3 | 15.0 | 14.5 | 6.3 | 15.7 | 6.6 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 23:15 | SELL | 25 | sem | 293 | 89.8 | 15.8 | 14.8 | 4.9 | 17.4 | 6.4 | 2/2 | True | M1 | True |
| M1 | 240 | 23:02 | SELL | 25 | sem | 112 | 91.1 | 18.2 | 18.6 | 4.0 | 17.6 | 6.2 | 1/1 | True | M15,M5 | True |
| M5 | 240 | 23:45 | SELL | 25 | sem | 293 | 93.9 | 18.4 | 19.3 | 8.0 | 17.1 | 6.0 | 2/2 | True | M1,M15 | True |
| M1 | 240 | 23:37 | SELL | 25 | sem | 112 | 90.2 | 16.6 | 15.8 | 3.2 | 18.0 | 6.0 | 1/1 | False | M15,M5 | True |
| M1 | 240 | 23:07 | SELL | 25 | sem | 112 | 91.1 | 17.4 | 17.8 | 3.4 | 16.9 | 5.6 | 1/1 | True | M15,M5 | True |
| M5 | 240 | 22:50 | SELL | 25 | sem | 293 | 89.4 | 17.0 | 17.8 | 8.4 | 16.0 | 5.5 | 2/2 | True | M1,M15 | True |
| M5 | 60 | 23:40 | SELL | 25 | sem | 293 | 85.3 | 14.3 | 14.6 | 6.2 | 13.8 | 5.5 | 2/2 | True | M1,M15 | True |
| M1 | 240 | 23:00 | SELL | 25 | sem | 112 | 88.4 | 16.3 | 16.2 | 3.3 | 16.5 | 5.4 | 1/1 | True | M15,M5 | True |
| M5 | 240 | 21:15 | SELL | 50 | sem | 293 | 68.9 | 18.7 | 16.6 | 3.5 | 21.7 | 5.3 | 2/2 | True | nan | True |
| M15 | 60 | 01:00 | BUY | 50 | k | 710 | 34.1 | 9.2 | 7.8 | 4.1 | 11.3 | 5.2 | 3/3 | True | M5 | True |
| M5 | 60 | 23:45 | SELL | 25 | sem | 293 | 84.6 | 14.2 | 15.0 | 6.9 | 12.9 | 5.2 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 23:00 | SELL | 50 | sem | 293 | 77.5 | 28.4 | 31.2 | 8.8 | 24.3 | 5.1 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 21:40 | SELL | 25 | sem | 293 | 85.7 | 12.2 | 11.7 | 3.5 | 13.1 | 5.0 | 2/2 | True | nan | True |
| M5 | 240 | 22:25 | SELL | 25 | sem | 293 | 89.8 | 16.0 | 17.2 | 6.8 | 14.2 | 5.0 | 2/2 | True | M1 | True |
| M1 | 240 | 23:38 | SELL | 25 | sem | 112 | 89.3 | 15.8 | 15.4 | 3.0 | 16.3 | 5.0 | 1/1 | False | M15,M5 | True |
| M1 | 240 | 23:08 | SELL | 25 | sem | 112 | 90.2 | 17.1 | 18.0 | 3.5 | 15.8 | 4.8 | 1/1 | True | M15,M5 | True |
| M5 | 240 | 22:20 | SELL | 25 | sem | 293 | 88.7 | 15.3 | 16.4 | 6.1 | 13.8 | 4.8 | 2/2 | True | M1 | True |
| M1 | 240 | 23:58 | SELL | 25 | sem | 112 | 94.6 | 22.0 | 25.2 | 510.3 | 17.0 | 4.8 | 1/1 | True | M5 | True |
| M1 | 240 | 23:04 | SELL | 25 | sem | 112 | 90.2 | 17.5 | 18.6 | 3.9 | 15.9 | 4.7 | 1/1 | True | M15,M5 | True |
| M1 | 240 | 23:36 | SELL | 25 | sem | 112 | 89.3 | 16.1 | 16.1 | 3.4 | 16.0 | 4.7 | 1/1 | True | M15,M5 | True |
| M5 | 240 | 22:55 | SELL | 50 | sem | 293 | 76.5 | 27.1 | 29.8 | 8.3 | 23.0 | 4.7 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 22:35 | SELL | 25 | sem | 293 | 88.0 | 14.9 | 15.7 | 6.0 | 13.8 | 4.7 | 2/2 | True | M1 | True |
| M5 | 60 | 01:00 | BUY | 25 | sem | 369 | 70.5 | 9.4 | 9.2 | 3.9 | 9.8 | 4.6 | 2/2 | True | M15 | True |
| M5 | 240 | 21:25 | SELL | 25 | sem | 293 | 85.0 | 11.2 | 10.4 | 3.2 | 12.4 | 4.4 | 2/2 | False | nan | True |
| M1 | 240 | 23:54 | SELL | 25 | sem | 112 | 90.2 | 16.1 | 16.5 | 3.0 | 15.6 | 4.4 | 1/1 | False | M15,M5 | True |
| M5 | 240 | 23:05 | SELL | 50 | sem | 293 | 79.2 | 29.7 | 34.4 | 10.0 | 22.7 | 4.4 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 23:25 | SELL | 25 | sem | 293 | 91.8 | 17.5 | 19.4 | 9.2 | 14.7 | 4.4 | 2/2 | True | M1 | True |


## D. Padrões estruturais (condição × hora/sessão, além do efeito do relógio)

| tf | W | k_tested | tests | validated | race | ev_buy | ev_sell | placebo_mean | placebo_max |
|---|---|---|---|---|---|---|---|---|---|
| M15 | 60 | 50,100 | 25794 | 1 | 1 | 0 | 0 | 16.00 | 59 |
| M15 | 240 | 100,150 | 25686 | 28 | 0 | 0 | 28 | 127.75 | 437 |
| M5 | 60 | 50,100 | 25302 | 8 | 7 | 0 | 1 | 3.12 | 12 |
| M5 | 240 | 100,150 | 25188 | 24 | 11 | 0 | 13 | 4.38 | 14 |


`D_estruturais_M15_W240.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 150 | EV_SELL_Ak | tickvol=normal & weekday=SEX & Tarde(20-24) | 212 | 55 | 55.04 | 6.22 | 54.15 | 3.12 | 28.03 |
| 150 | EV_SELL_Ak | tickvol=baixo & weekday=SEX & Tarde(20-24) | 292 | 52 | 50.59 | 5.75 | 54.54 | 5.66 | 27.45 |
| 150 | EV_SELL_Ak | streak=2 baixas & weekday=SEX & Tarde(20-24) | 88 | 53 | 52.67 | 5.62 | 56.56 | 3.55 | 32.81 |
| 150 | EV_SELL_Ak | weekday=SEX & hora=20h | 568 | 84 | 42.84 | 5.54 | 59.75 | 6.51 | 33.34 |
| 100 | EV_SELL_Ak | weekday=SEX & hora=20h | 568 | 84 | 35.41 | 5.42 | 39.51 | 4.95 | 21.40 |
| 100 | EV_SELL_Ak | spread=normal & weekday=SEX & Tarde(20-24) | 705 | 84 | 35.59 | 5.38 | 40.56 | 5.16 | 21.55 |
| 100 | EV_SELL_Ak | brk=dentro & weekday=SEX & Tarde(20-24) | 598 | 83 | 37.31 | 5.38 | 43.36 | 5.31 | 24.50 |
| 100 | EV_SELL_Ak | tickvol=baixo & weekday=SEX & Tarde(20-24) | 292 | 52 | 43.75 | 5.35 | 33.26 | 3.53 | 14.08 |
| 100 | EV_SELL_Ak | extreme=normal & weekday=SEX & Tarde(20-24) | 667 | 82 | 36.38 | 5.29 | 39.62 | 5.17 | 20.73 |
| 100 | EV_SELL_Ak | ret4=Q2 & weekday=SEX & Tarde(20-24) | 149 | 53 | 46.99 | 5.28 | 31.04 | 2.58 | 12.43 |
| 150 | EV_SELL_Ak | prev1=baixa & weekday=SEX & Tarde(20-24) | 271 | 78 | 44.06 | 5.24 | 57.65 | 5.80 | 32.60 |
| 150 | EV_SELL_Ak | spread=normal & weekday=SEX & Tarde(20-24) | 705 | 84 | 41.12 | 5.13 | 62.11 | 6.83 | 35.09 |
| 150 | EV_SELL_Ak | brk=dentro & weekday=SEX & Tarde(20-24) | 598 | 83 | 43.21 | 5.11 | 62.04 | 6.39 | 35.34 |
| 150 | EV_SELL_Ak | ret4=Q2 & weekday=SEX & Tarde(20-24) | 149 | 53 | 51.14 | 5.06 | 52.99 | 3.43 | 26.40 |
| 100 | EV_SELL_Ak | prev1=baixa & weekday=SEX & Tarde(20-24) | 271 | 78 | 35.51 | 4.99 | 40.29 | 5.10 | 22.23 |
| 100 | EV_SELL_Ak | tickvol=normal & weekday=SEX & Tarde(20-24) | 212 | 55 | 41.13 | 4.99 | 38.88 | 2.87 | 20.80 |
| 100 | EV_SELL_Ak | prevday=dia_ant_alta & weekday=SEX & Tarde(20-24) | 374 | 47 | 39.93 | 4.91 | 37.01 | 3.02 | 18.03 |
| 150 | EV_SELL_Ak | extreme=normal & weekday=SEX & Tarde(20-24) | 667 | 82 | 41.04 | 4.89 | 58.40 | 6.85 | 31.56 |
| 150 | EV_SELL_Ak | prevday=dia_ant_alta & weekday=SEX & Tarde(20-24) | 374 | 47 | 46.71 | 4.85 | 58.53 | 4.22 | 31.58 |
| 150 | EV_SELL_Ak | compress=comprimido & weekday=SEX & Tarde(20-24) | 415 | 70 | 41.58 | 4.84 | 63.82 | 6.36 | 37.06 |


`D_estruturais_M15_W60.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 50 | race | ret4=Q1(caiu+) & hora=00h | 838 | 212 | 0.22 | 5.01 | 0.20 | 5.04 | 0.36 |


`D_estruturais_M5_W240.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 150 | race | prev1=alta & weekday=SEX & Tarde(20-24) | 367 | 44 | 0.28 | 7.17 | 0.16 | 2.34 | -0.18 |
| 150 | race | streak=2 altas & weekday=SEX & Tarde(20-24) | 129 | 40 | 0.32 | 6.79 | 0.20 | 2.49 | -0.16 |
| 150 | race | compress=comprimido & weekday=SEX & Tarde(20-24) | 440 | 42 | 0.31 | 5.98 | 0.23 | 4.39 | -0.10 |
| 150 | race | weekday=SEX & hora=21h | 224 | 45 | 0.33 | 5.82 | 0.20 | 2.63 | -0.20 |
| 150 | race | tickvol=normal & weekday=SEX & Tarde(20-24) | 307 | 35 | 0.32 | 5.57 | 0.16 | 1.84 | -0.19 |
| 150 | race | brk=dentro & weekday=SEX & Tarde(20-24) | 877 | 45 | 0.29 | 5.49 | 0.14 | 1.92 | -0.21 |
| 150 | EV_SELL_Ak | streak=1 baixa & weekday=SEX & Tarde(20-24) | 282 | 45 | 51.72 | 5.41 | 48.29 | 3.48 | 34.06 |
| 150 | race | streak=1 baixa & weekday=SEX & Tarde(20-24) | 282 | 45 | 0.26 | 5.11 | 0.13 | 1.65 | -0.24 |
| 150 | EV_SELL_Ak | prev1=alta & weekday=SEX & Tarde(20-24) | 367 | 44 | 47.32 | 4.98 | 40.97 | 2.81 | 26.91 |
| 150 | EV_SELL_Ak | ret4=Q5(subiu+) & weekday=SEX & Tarde(20-24) | 184 | 35 | 57.62 | 4.83 | 36.35 | 2.04 | 22.65 |
| 150 | EV_SELL_Ak | ret4=Q4 & weekday=SEX & Tarde(20-24) | 221 | 44 | 54.44 | 4.76 | 38.66 | 2.45 | 25.23 |
| 100 | race | prev1=forte_baixa & hora=00h | 793 | 205 | 0.21 | 4.60 | 0.31 | 5.17 | 0.31 |
| 150 | race | ret4=Q3 & weekday=SEX & Tarde(20-24) | 240 | 43 | 0.29 | 4.52 | 0.15 | 2.20 | -0.18 |
| 150 | EV_SELL_Ak | extreme=normal & weekday=SEX & Tarde(20-24) | 1046 | 45 | 44.95 | 4.39 | 48.01 | 3.36 | 34.76 |
| 150 | EV_SELL_Ak | spread=normal & weekday=SEX & Tarde(20-24) | 1107 | 45 | 43.73 | 4.38 | 45.69 | 3.20 | 32.36 |
| 150 | EV_SELL_Ak | weekday=SEX & hora=20h | 900 | 45 | 44.68 | 4.34 | 45.33 | 3.17 | 31.01 |
| 150 | EV_SELL_Ak | streak=1 alta & weekday=SEX & Tarde(20-24) | 283 | 45 | 44.61 | 4.27 | 47.76 | 3.46 | 34.73 |
| 150 | EV_SELL_Ak | streak=2 altas & weekday=SEX & Tarde(20-24) | 129 | 40 | 39.97 | 4.26 | 31.58 | 1.81 | 16.68 |
| 150 | EV_SELL_Ak | prev1=forte_alta & weekday=SEX & Tarde(20-24) | 194 | 45 | 45.56 | 4.25 | 43.51 | 2.61 | 31.17 |
| 150 | EV_SELL_Ak | brk=dentro & weekday=SEX & Tarde(20-24) | 877 | 45 | 42.81 | 4.17 | 42.52 | 3.00 | 29.25 |


`D_estruturais_M5_W60.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 50 | race | ret4=Q1(caiu+) & hora=00h | 1013 | 200 | 0.22 | 5.77 | 0.47 | 9.59 | 0.43 |
| 50 | EV_SELL_Ak | weekday=SEX & hora=23h | 149 | 45 | 25.76 | 4.78 | 15.09 | 1.99 | 11.09 |
| 50 | race | prev1=forte_baixa & hora=00h | 793 | 205 | 0.20 | 4.74 | 0.42 | 8.30 | 0.30 |
| 50 | race | brk=rompeu_max_fechou_fora & hora=00h | 65 | 32 | -0.51 | -4.22 | -0.58 | -3.26 | -0.50 |
| 50 | race | ret4=Q5(subiu+) & hora=00h | 684 | 166 | -0.23 | -4.19 | -0.44 | -6.78 | -0.24 |
| 50 | race | dopen=Q2 & hora=00h | 2060 | 221 | 0.15 | 4.08 | 0.34 | 5.26 | 0.34 |
| 50 | race | brk=rompeu_max_falhou & hora=00h | 175 | 61 | -0.36 | -4.04 | -0.41 | -4.46 | -0.33 |
| 50 | race | dopen=Q3 & hora=00h | 2114 | 188 | -0.17 | -3.91 | -0.27 | -4.72 | -0.09 |


## F. Distância × tempo e devolução

Das entradas que chegaram a +k (M15, janela 240 min), quantas terminaram a janela no prejuízo (o alvo foi tocado e devolvido):

| k_pts | side | hits | ended_negative_pct | ended_below_half_k_pct |
|---|---|---|---|---|
| 25 | BUY | 51411 | 39.9 | 45.1 |
| 25 | SELL | 52843 | 40.9 | 46.0 |
| 50 | BUY | 40296 | 29.5 | 39.1 |
| 50 | SELL | 42408 | 31.4 | 41.2 |
| 100 | BUY | 23449 | 15.3 | 28.1 |
| 100 | SELL | 25068 | 17.3 | 31.6 |
| 150 | BUY | 12970 | 8.4 | 20.1 |
| 150 | SELL | 13860 | 10.9 | 24.4 |
| 200 | BUY | 7308 | 6.1 | 15.8 |
| 200 | SELL | 7709 | 7.7 | 19.6 |
| 300 | BUY | 2633 | 4.7 | 13.5 |
| 300 | SELL | 2706 | 5.4 | 16.7 |
| 400 | BUY | 983 | 3.4 | 12.3 |
| 400 | SELL | 1101 | 3.6 | 14.5 |


## I. Outras regularidades

Hora do servidor em que se formou a máxima / mínima do dia (% dos dias, M15):

| hora | pct_dias_max_do_dia | pct_dias_min_do_dia |
|---|---|---|
| 0 | 5.5 | 30.9 |
| 1 | 6.0 | 1.7 |
| 2 | 4.4 | 2.0 |
| 3 | 7.0 | 3.4 |
| 4 | 5.9 | 3.7 |
| 5 | 4.4 | 2.2 |
| 6 | 2.0 | 1.3 |
| 7 | 1.8 | 1.3 |
| 8 | 1.3 | 1.6 |
| 9 | 4.2 | 1.7 |
| 10 | 3.1 | 2.4 |
| 11 | 3.0 | 2.0 |
| 12 | 1.7 | 2.0 |
| 13 | 2.2 | 2.2 |
| 14 | 2.0 | 1.3 |
| 15 | 6.6 | 5.3 |
| 16 | 6.2 | 3.5 |
| 17 | 6.2 | 4.9 |
| 18 | 4.4 | 3.9 |
| 19 | 3.4 | 4.9 |
| 20 | 2.8 | 2.8 |
| 21 | 4.2 | 3.2 |
| 22 | 4.6 | 4.8 |
| 23 | 7.2 | 7.0 |


Continuidade entre sessões (mesmo sinal do movimento; 50% = sem relação):

| de | para | periodo | dias | mesmo_sinal_pct | z | corr |
|---|---|---|---|---|---|---|
| Asia(01-09) | Londres(09-15) | descoberta | 425 | 52.71 | 1.12 | 0.07 |
| Asia(01-09) | Londres(09-15) | validacao | 284 | 48.24 | -0.59 | -0.05 |
| Londres(09-15) | NY(15-20) | descoberta | 423 | 48.70 | -0.54 | -0.02 |
| Londres(09-15) | NY(15-20) | validacao | 285 | 52.63 | 0.89 | 0.10 |
| Asia(01-09) | NY(15-20) | descoberta | 422 | 49.05 | -0.39 | 0.02 |
| Asia(01-09) | NY(15-20) | validacao | 284 | 50.35 | 0.12 | 0.04 |
| NY(15-20) | Tarde(20-24) | descoberta | 419 | 51.55 | 0.64 | 0.01 |
| NY(15-20) | Tarde(20-24) | validacao | 284 | 53.87 | 1.30 | 0.02 |
| Dia anterior | Dia | descoberta | 423 | 49.17 | -0.34 | -0.02 |
| Dia anterior | Dia | validacao | 283 | 49.82 | -0.06 | -0.01 |


Gap de segunda-feira (abertura da semana vs fechamento de sexta) fechado no mesmo dia, comparado com a chance de o preço andar a mesma distância nos outros dias:

| symbol | segundas | gap_mediano_pts | gap_fechou_pct | base_outros_dias_pct | gaps_grandes | gap_grande_fechou_pct | base_gaps_grandes_pct | gap_alta_pct |
|---|---|---|---|---|---|---|---|---|
| NZDUSD_r | 136 | 64.0 | 89.7 | 81.7 | 68 | 83.8 | 68.5 | 30.1 |
