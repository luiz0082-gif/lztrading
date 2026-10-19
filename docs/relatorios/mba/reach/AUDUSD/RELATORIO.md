# AUDUSD — investigação de alcance, horário e repetição

## A. Qualidade e cobertura dos dados

| tf | first | last | trading_days | bars | gaps_gt_bar | gaps_gt15m | max_gap_min | pct_tick_spread | spread_med | spread_p90 | bad_ohlc | dup_time |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 2026-04-06 22:26:00 | 2026-10-16 23:58:00 | 140 | 200000 | 204 | 0 | 7 | 61.8 | 13.5 | 15.0 | 0 | 0 |
| M5 | 2025-05-15 03:15:00 | 2026-10-16 23:50:00 | 370 | 106505 | 4 | 1 | 60 | 23.2 | 13.0 | 14.6 | 0 | 0 |
| M15 | 2024-01-22 05:30:00 | 2026-10-16 23:30:00 | 712 | 68224 | 3 | 3 | 105 | 12.1 | 12.0 | 14.0 | 0 | 0 |


Ponto MT5 = 1e-05, tick size = 1e-05, tick value = 1.0 (USD por tick por lote), contrato = 100000.0. Barras de BID. Custo = spread medido nos ticks (perfil por faixa de 30 min do servidor onde não há tick) + swap; comissão não declarada pela corretora (não incluída).


**Limitação:** o M1 deste ativo só cobre ~mar/abr–out/2026 (≈140–158 dias, um único regime). Resultados de M1 são exploratórios; a confirmação vem de M5 (mai/2025→) e M15 (jan/2024→).


## C. Distâncias percorridas (operação executável, líquida de spread)


**M15, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 67775 | 65.4 | 47.8 | 47.4-48.2 | 15.0 | 45.0 | 28.7 | 70.5 | 19.9 | 77.7 | 8.8 | 22.4 |
| 25 | SELL | 67775 | 65.4 | 48.0 | 47.6-48.3 | 15.0 | 45.0 | 29.2 | 69.6 | 19.5 | 78.2 | 9.0 | 22.0 |
| 50 | BUY | 67775 | 39.2 | 28.0 | 27.7-28.4 | 15.0 | 45.0 | 28.7 | 73.8 | 21.9 | 52.9 | 1.2 | 29.8 |
| 50 | SELL | 67775 | 40.4 | 28.6 | 28.3-29.0 | 15.0 | 45.0 | 28.8 | 72.8 | 22.2 | 53.3 | 1.4 | 30.0 |
| 100 | BUY | 67775 | 13.5 | 9.9 | 9.7-10.1 | 30.0 | 45.0 | 29.6 | 83.6 | 9.3 | 20.1 | 0.2 | 31.8 |
| 100 | SELL | 67775 | 14.5 | 10.4 | 10.2-10.6 | 30.0 | 45.0 | 29.6 | 80.3 | 9.8 | 19.1 | 0.2 | 34.1 |
| 150 | BUY | 67775 | 5.2 | 4.1 | 3.9-4.2 | 30.0 | 45.0 | 32.6 | 98.6 | 3.9 | 7.5 | 0.1 | 34.3 |
| 150 | SELL | 67775 | 5.6 | 4.3 | 4.1-4.4 | 30.0 | 45.0 | 31.4 | 87.9 | 4.1 | 6.8 | 0.1 | 38.0 |
| 200 | BUY | 67775 | 2.4 | 2.0 | 1.9-2.1 | 30.0 | 45.0 | 34.6 | 107.8 | 1.9 | 3.1 | 0.0 | 38.3 |
| 200 | SELL | 67775 | 2.5 | 2.1 | 2.0-2.2 | 30.0 | 45.0 | 33.5 | 98.9 | 2.0 | 3.0 | 0.0 | 40.2 |


**M15, janela 240 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 66606 | 83.5 | 72.8 | 72.5-73.1 | 30.0 | 150.0 | 40.1 | 113.5 | 20.8 | 79.2 | 8.9 | 22.9 |
| 25 | SELL | 66606 | 84.4 | 72.9 | 72.6-73.3 | 30.0 | 150.0 | 40.7 | 108.5 | 20.4 | 79.6 | 9.2 | 22.4 |
| 50 | BUY | 66606 | 67.3 | 57.5 | 57.2-57.9 | 60.0 | 180.0 | 44.5 | 119.6 | 32.1 | 66.5 | 1.4 | 33.0 |
| 50 | SELL | 66606 | 69.6 | 57.9 | 57.5-58.3 | 60.0 | 180.0 | 44.9 | 114.4 | 31.8 | 67.0 | 1.7 | 32.8 |
| 100 | BUY | 66606 | 41.1 | 34.6 | 34.3-35.0 | 90.0 | 195.0 | 45.8 | 128.2 | 28.7 | 48.0 | 0.5 | 37.6 |
| 100 | SELL | 66606 | 43.1 | 34.9 | 34.6-35.3 | 90.0 | 195.0 | 46.9 | 121.8 | 29.4 | 46.5 | 0.5 | 39.1 |
| 150 | BUY | 66606 | 24.1 | 20.3 | 20.0-20.6 | 120.0 | 210.0 | 46.9 | 136.5 | 18.7 | 29.1 | 0.2 | 39.3 |
| 150 | SELL | 66606 | 25.4 | 21.2 | 20.9-21.5 | 120.0 | 210.0 | 46.8 | 127.8 | 19.8 | 27.4 | 0.2 | 42.0 |
| 200 | BUY | 66606 | 14.2 | 12.1 | 11.8-12.3 | 120.0 | 210.0 | 48.6 | 144.6 | 11.5 | 17.4 | 0.1 | 39.8 |
| 200 | SELL | 66606 | 15.2 | 13.0 | 12.7-13.2 | 135.0 | 210.0 | 47.6 | 135.8 | 12.4 | 16.1 | 0.1 | 43.5 |
| 300 | BUY | 66606 | 5.5 | 4.8 | 4.6-4.9 | 135.0 | 210.0 | 50.7 | 153.2 | 4.7 | 6.5 | 0.0 | 42.0 |
| 300 | SELL | 66606 | 5.7 | 5.0 | 4.9-5.2 | 135.0 | 210.0 | 49.6 | 153.8 | 4.9 | 6.1 | 0.0 | 44.4 |
| 400 | BUY | 66606 | 2.4 | 2.1 | 2.0-2.2 | 150.0 | 210.0 | 53.7 | 170.6 | 2.1 | 2.7 | 0.0 | 44.0 |
| 400 | SELL | 66606 | 2.4 | 2.1 | 2.0-2.3 | 135.0 | 210.0 | 55.8 | 188.0 | 2.1 | 2.7 | 0.0 | 44.2 |
| 500 | BUY | 66606 | 1.1 | 0.9 | 0.9-1.0 | 150.0 | 210.0 | 53.8 | 175.8 | 0.9 | 1.3 | 0.0 | 40.6 |
| 500 | SELL | 66606 | 1.2 | 1.1 | 1.0-1.2 | 150.0 | 225.0 | 57.9 | 199.3 | 1.1 | 1.1 | 0.0 | 47.8 |


**M1, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 198416 | 61.1 | 42.0 | 41.8-42.3 | 20.0 | 48.0 | 26.2 | 60.4 | 19.8 | 76.9 | 0.1 | 20.5 |
| 25 | SELL | 198416 | 63.2 | 44.4 | 44.2-44.6 | 20.0 | 49.0 | 26.0 | 59.4 | 21.0 | 75.5 | 0.4 | 21.9 |
| 50 | BUY | 198416 | 34.2 | 23.2 | 23.1-23.4 | 28.0 | 52.0 | 26.8 | 62.6 | 19.3 | 50.3 | 0.1 | 27.8 |
| 50 | SELL | 198416 | 37.1 | 24.6 | 24.4-24.7 | 28.0 | 53.0 | 26.6 | 61.9 | 20.6 | 48.6 | 0.2 | 29.8 |
| 100 | BUY | 198416 | 10.3 | 7.4 | 7.3-7.5 | 36.0 | 55.0 | 28.7 | 72.6 | 7.1 | 17.6 | 0.0 | 28.7 |
| 100 | SELL | 198416 | 12.1 | 7.6 | 7.5-7.7 | 36.0 | 55.0 | 27.7 | 71.0 | 7.3 | 16.6 | 0.0 | 30.7 |
| 150 | BUY | 198416 | 3.7 | 2.8 | 2.7-2.8 | 37.0 | 55.0 | 30.8 | 79.8 | 2.7 | 6.1 | 0.0 | 30.6 |
| 150 | SELL | 198416 | 4.3 | 2.7 | 2.6-2.8 | 38.0 | 56.0 | 29.7 | 81.6 | 2.6 | 5.6 | 0.0 | 32.1 |
| 200 | BUY | 198416 | 1.6 | 1.2 | 1.2-1.2 | 37.0 | 55.0 | 32.1 | 81.6 | 1.2 | 2.2 | 0.0 | 34.9 |
| 200 | SELL | 198416 | 1.6 | 1.2 | 1.2-1.3 | 39.0 | 56.0 | 30.8 | 91.8 | 1.2 | 2.1 | 0.0 | 36.0 |


## B. Varredura por horário (servidor)


% de entradas (M15, janela 60 min) que alcançaram a distância, por hora do servidor:


| hour | BUY ≥100 | SELL ≥100 |
|---|---|---|
| 0 | 2.0 | 2.6 |
| 1 | 4.4 | 3.6 |
| 2 | 8.7 | 8.9 |
| 3 | 13.1 | 13.2 |
| 4 | 14.3 | 13.9 |
| 5 | 8.8 | 9.0 |
| 6 | 5.7 | 6.0 |
| 7 | 5.3 | 6.5 |
| 8 | 9.1 | 8.8 |
| 9 | 12.4 | 12.8 |
| 10 | 12.1 | 13.4 |
| 11 | 8.7 | 8.9 |
| 12 | 5.7 | 6.3 |
| 13 | 6.5 | 6.2 |
| 14 | 11.5 | 11.7 |
| 15 | 23.0 | 20.2 |
| 16 | 23.4 | 26.3 |
| 17 | 22.3 | 23.3 |
| 18 | 11.5 | 13.6 |
| 19 | 8.7 | 9.5 |
| 20 | 7.5 | 8.5 |
| 21 | 6.5 | 7.3 |
| 22 | 3.8 | 4.7 |
| 23 | 1.9 | 3.1 |


Minuto a minuto (M1, janela 60 min, k = 100 pts; tabela completa em `B_varredura_relogio_M1_W60.csv.gz` com todos os minutos e limiares). Maiores e menores taxas de alcance:


Maior alcance (BUY):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 15:08 | 139 | 33 | 23.7 | 21 | 15.1 | 23.0 | 20.9 | 27.0 | 33.7 |
| 15:04 | 139 | 32 | 23.0 | 21 | 15.1 | 24.5 | 19.4 | 30.5 | 33.2 |
| 16:19 | 139 | 32 | 23.0 | 20 | 14.4 | 26.6 | 18.0 | 29.5 | 31.2 |
| 16:58 | 139 | 32 | 23.0 | 25 | 18.0 | 26.6 | 20.9 | 25.5 | 31.6 |
| 16:20 | 139 | 32 | 23.0 | 22 | 15.8 | 25.2 | 20.9 | 29.5 | 29.5 |
| 15:41 | 139 | 31 | 22.3 | 17 | 12.2 | 27.3 | 15.1 | 41.0 | 31.3 |
| 16:23 | 139 | 31 | 22.3 | 21 | 15.1 | 25.2 | 21.6 | 31.0 | 28.6 |
| 15:50 | 139 | 31 | 22.3 | 25 | 18.0 | 26.6 | 20.9 | 42.0 | 30.2 |
| 15:11 | 139 | 31 | 22.3 | 21 | 15.1 | 21.6 | 20.1 | 26.0 | 41.4 |
| 16:46 | 139 | 31 | 22.3 | 25 | 18.0 | 22.3 | 21.6 | 30.0 | 28.6 |


Maior alcance (SELL):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 17:25 | 139 | 23 | 16.6 | 32 | 23.0 | 19.4 | 28.1 | 30.0 | 34.5 |
| 17:24 | 139 | 21 | 15.1 | 32 | 23.0 | 21.6 | 25.9 | 32.0 | 38.5 |
| 17:28 | 139 | 23 | 16.6 | 32 | 23.0 | 20.1 | 27.3 | 30.0 | 24.7 |
| 17:29 | 139 | 22 | 15.8 | 31 | 22.3 | 20.1 | 25.9 | 29.0 | 25.2 |
| 17:13 | 139 | 26 | 18.7 | 31 | 22.3 | 20.9 | 27.3 | 39.5 | 22.9 |
| 17:35 | 139 | 21 | 15.1 | 30 | 21.6 | 20.9 | 26.6 | 30.0 | 33.3 |
| 17:27 | 139 | 24 | 17.3 | 30 | 21.6 | 18.7 | 28.8 | 30.5 | 27.8 |
| 17:10 | 139 | 23 | 16.6 | 30 | 21.6 | 21.6 | 25.9 | 32.0 | 26.7 |
| 17:23 | 139 | 25 | 18.0 | 29 | 20.9 | 21.6 | 28.1 | 32.0 | 28.5 |
| 17:38 | 139 | 22 | 15.8 | 29 | 20.9 | 20.9 | 25.9 | 26.5 | 28.0 |


Menor alcance (mercado parado):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 23:59 | 110 | 0 | 0.0 | 7 | 6.4 | 0.0 | 59.1 |  |  |
| 23:58 | 110 | 0 | 0.0 | 8 | 7.3 | 0.0 | 60.0 |  |  |
| 23:57 | 110 | 0 | 0.0 | 7 | 6.4 | 0.0 | 59.1 |  |  |
| 05:32 | 139 | 0 | 0.0 | 12 | 8.6 | 6.5 | 9.3 |  |  |
| 23:40 | 112 | 0 | 0.0 | 10 | 8.9 | 0.0 | 60.7 |  |  |


Maior assimetria BUY−SELL (só descritivo; o teste de direção está na seção E):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med | buy_menos_sell |
|---|---|---|---|---|---|---|---|---|---|---|
| 23:06 | 139 | 2 | 1.4 | 19 | 13.7 | 1.4 | 53.2 | 28.5 | 47.6 | -12.2 |
| 23:03 | 140 | 1 | 0.7 | 18 | 12.9 | 1.4 | 50.7 | 6.0 | 32.9 | -12.1 |
| 23:04 | 140 | 2 | 1.4 | 18 | 12.9 | 1.4 | 53.6 | 30.5 | 50.9 | -11.4 |
| 23:05 | 140 | 1 | 0.7 | 17 | 12.1 | 1.4 | 55.0 | 4.0 | 39.9 | -11.4 |
| 23:02 | 140 | 1 | 0.7 | 17 | 12.1 | 1.4 | 50.7 | 7.0 | 30.9 | -11.4 |
| 23:24 | 111 | 1 | 0.9 | 13 | 11.7 | 0.9 | 57.7 | 36.0 | 58.7 | -10.8 |
| 23:25 | 112 | 1 | 0.9 | 13 | 11.6 | 0.9 | 58.0 | 35.0 | 46.8 | -10.7 |
| 23:23 | 112 | 1 | 0.9 | 13 | 11.6 | 0.9 | 58.0 | 37.0 | 59.5 | -10.7 |
| 15:41 | 139 | 31 | 22.3 | 17 | 12.2 | 27.3 | 15.1 | 41.0 | 31.3 | 10.1 |
| 14:41 | 139 | 30 | 21.6 | 16 | 11.5 | 23.0 | 15.1 | 47.5 | 35.6 | 10.1 |


## E. Direção (BUY vs SELL) por horário — teste contra o próprio dia

y = +1 se o preço anda +k antes de −k, −1 no contrário. Tira-se a média do dia (dias de tendência não contam como sinal) e testa-se cada horário. Descoberta 60% / validação 40% cronológicos; BH na descoberta; placebo = troca aleatória de sinal por dia (200×).


| tf | W | clock | dir_tests | dir_validated | dir_fwer_and_val | dir_placebo_mean | dir_placebo_max |
|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 480.00 | 17.00 | 16.00 | 0.00 | 0.00 |
| M1 | 60 | hour | 120.00 | 5.00 | 5.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 7,200.00 | 251.00 | 226.00 | 0.00 | 0.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |
| M1 | 240 | 15m | 672.00 | 48.00 | 43.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 168.00 | 14.00 | 13.00 | 0.00 | 0.00 |
| M1 | 240 | slot | 10,080.00 | 657.00 | 389.00 | 0.00 | 0.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |
| M15 | 60 | hour | 120.00 | 8.00 | 8.00 | 0.01 | 1.00 |
| M15 | 60 | slot | 480.00 | 20.00 | 18.00 | 0.00 | 0.00 |
| M15 | 60 | wd_hour | 600.00 | 16.00 | 9.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 192.00 | 10.00 | 10.00 | 0.01 | 1.00 |
| M15 | 240 | slot | 768.00 | 34.00 | 24.00 | 0.00 | 0.00 |
| M15 | 240 | wd_hour | 944.00 | 22.00 | 12.00 | 0.00 | 0.00 |
| M5 | 60 | 15m | 480.00 | 23.00 | 20.00 | 0.00 | 0.00 |
| M5 | 60 | hour | 120.00 | 8.00 | 6.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 1,440.00 | 57.00 | 46.00 | 0.00 | 0.00 |
| M5 | 60 | wd_hour | 600.00 | 16.00 | 15.00 | 0.01 | 1.00 |
| M5 | 240 | 15m | 768.00 | 49.00 | 42.00 | 0.00 | 0.00 |
| M5 | 240 | hour | 192.00 | 13.00 | 12.00 | 0.00 | 0.00 |
| M5 | 240 | slot | 2,304.00 | 136.00 | 94.00 | 0.00 | 0.00 |
| M5 | 240 | wd_hour | 944.00 | 18.00 | 15.00 | 0.01 | 1.00 |


Horários validados (descoberta + validação):

| arquivo | clock | direction | ks | n_dias | sobe_antes | cai_antes | t_desc | t_val | fwer |
|---|---|---|---|---|---|---|---|---|---|
| 15m_M5_W60 | 23:45 | SELL (cai k antes) | 25,50,100 | 293 | 1.36 | 92.83 | 41.69 | 21.46 | True |
| slot_M5_W60 | 23:55 | SELL (cai k antes) | 25,50,100 | 293 | 1.02 | 90.44 | 36.95 | 22.96 | True |
| slot_M5_W60 | 23:45 | SELL (cai k antes) | 25,50,100 | 293 | 1.36 | 89.76 | 33.80 | 21.03 | True |
| slot_M5_W60 | 23:50 | SELL (cai k antes) | 25,50,100 | 293 | 1.71 | 89.76 | 33.39 | 18.44 | True |
| 15m_M5_W240 | 23:45 | SELL (cai k antes) | 25,50,100 | 293 | 5.80 | 93.52 | 29.25 | 19.95 | True |
| slot_M5_W60 | 23:40 | SELL (cai k antes) | 25,50,100 | 293 | 2.05 | 85.67 | 27.39 | 20.29 | True |
| slot_M5_W240 | 23:55 | SELL (cai k antes) | 25,50,100 | 293 | 6.49 | 92.49 | 25.53 | 22.61 | True |
| hour_M5_W60 | 23h | SELL (cai k antes) | 25,50,100 | 370 | 4.87 | 79.19 | 24.57 | 21.90 | True |
| slot_M5_W240 | 23:45 | SELL (cai k antes) | 25,50,100 | 293 | 8.53 | 90.10 | 24.55 | 15.31 | True |
| 15m_M5_W60 | 23:30 | SELL (cai k antes) | 25,50,100 | 293 | 4.78 | 86.69 | 24.49 | 21.41 | True |
| slot_M5_W240 | 23:50 | SELL (cai k antes) | 25,50,100 | 293 | 6.83 | 91.81 | 24.24 | 17.16 | True |
| hour_M5_W240 | 23h | SELL (cai k antes) | 25,50,100 | 293 | 11.60 | 84.30 | 21.27 | 14.53 | True |
| slot_M5_W60 | 23:35 | SELL (cai k antes) | 25,50,100 | 293 | 3.41 | 84.98 | 21.18 | 21.62 | True |
| 15m_M5_W60 | 23:15 | SELL (cai k antes) | 25,50,100 | 293 | 6.14 | 74.06 | 20.87 | 17.44 | True |
| slot_M5_W60 | 23:25 | SELL (cai k antes) | 25,50,100,150 | 293 | 2.90 | 58.19 | 20.83 | 16.12 | True |
| slot_M5_W60 | 23:30 | SELL (cai k antes) | 25,50,100 | 293 | 5.46 | 77.13 | 19.06 | 16.24 | True |
| slot_M15_W60 | 23:45 | SELL (cai k antes) | 25,50,100 | 564 | 3.55 | 75.71 | 18.96 | 31.93 | True |
| hour_M1_W60 | 23h | SELL (cai k antes) | 25,50,100,150 | 140 | 2.14 | 78.93 | 18.50 | 16.29 | True |
| slot_M5_W240 | 23:40 | SELL (cai k antes) | 25,50,100 | 293 | 10.92 | 86.01 | 18.46 | 13.43 | True |
| slot_M5_W60 | 23:20 | SELL (cai k antes) | 25,50,100 | 293 | 4.78 | 71.67 | 18.38 | 17.31 | True |
| wd_hour_M5_W240 | SEG 23h | SELL (cai k antes) | 25,50,100 | 74 | 6.76 | 91.89 | 18.21 | 9.30 | True |
| slot_M1_W60 | 23:59 | SELL (cai k antes) | 25,50,100,150 | 110 | 0.00 | 75.45 | 17.91 | 49.97 | True |
| slot_M1_W60 | 23:56 | SELL (cai k antes) | 25,50,100,150 | 110 | 0.00 | 75.00 | 17.91 | 49.97 | True |
| slot_M1_W60 | 23:58 | SELL (cai k antes) | 25,50,100,150 | 110 | 0.00 | 75.45 | 17.91 | 49.97 | True |
| 15m_M5_W240 | 23:30 | SELL (cai k antes) | 25,50,100 | 293 | 11.60 | 87.03 | 17.73 | 14.19 | True |
| slot_M1_W60 | 23:57 | SELL (cai k antes) | 25,50,100,150 | 110 | 0.00 | 74.55 | 16.89 | 49.97 | True |
| slot_M5_W60 | 23:10 | SELL (cai k antes) | 25,50,100 | 293 | 6.83 | 69.97 | 16.70 | 14.24 | True |
| wd_hour_M5_W60 | SEG 23h | SELL (cai k antes) | 25,50,100 | 74 | 2.70 | 91.89 | 16.70 | 15.02 | True |
| slot_M5_W60 | 23:15 | SELL (cai k antes) | 25,50,100 | 293 | 7.17 | 72.36 | 16.62 | 13.82 | True |
| slot_M5_W240 | 23:25 | SELL (cai k antes) | 25,50,100 | 293 | 11.26 | 74.06 | 16.36 | 10.63 | True |
| slot_M5_W240 | 23:35 | SELL (cai k antes) | 25,50,100 | 293 | 11.26 | 85.32 | 16.04 | 14.51 | True |
| slot_M1_W60 | 23:23 | SELL (cai k antes) | 25,50,100,150 | 112 | 1.34 | 68.30 | 15.78 | 11.73 | True |
| slot_M1_W60 | 23:35 | SELL (cai k antes) | 25,50,100,150 | 112 | 1.34 | 74.11 | 15.61 | 12.90 | True |
| slot_M1_W60 | 23:34 | SELL (cai k antes) | 25,50,100,150 | 112 | 1.79 | 74.11 | 15.60 | 12.90 | True |
| slot_M1_W60 | 23:36 | SELL (cai k antes) | 25,50,100,150 | 112 | 1.79 | 73.66 | 15.53 | 16.80 | True |
| 15m_M5_W240 | 23:15 | SELL (cai k antes) | 25,50,100 | 293 | 11.60 | 74.06 | 15.49 | 12.52 | True |
| wd_hour_M5_W240 | QUA 23h | SELL (cai k antes) | 25,50 | 72 | 10.42 | 86.81 | 15.38 | 6.76 | True |
| hour_M15_W60 | 23h | SELL (cai k antes) | 25,50,100 | 709 | 8.18 | 64.46 | 15.28 | 24.54 | True |
| 15m_M1_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150 | 110 | 0.45 | 78.18 | 15.12 | 35.79 | True |
| slot_M5_W240 | 23:30 | SELL (cai k antes) | 25,50,100 | 293 | 11.95 | 77.47 | 15.02 | 11.86 | True |


## G. Operação executável por horário (alvo k, limite k / 2k / sem limite; custo e swap incluídos)

| tf | W | clock | ev_tests | ev_validated | ev_validated_bh | ev_clocks | ev_placebo_mean | ev_placebo_max |
|---|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 2,880.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | hour | 720.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 43,200.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |  |
| M1 | 240 | 15m | 4,032.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 1,008.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | slot | 60,480.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |  |
| M15 | 60 | hour | 720.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 60 | slot | 2,880.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 60 | wd_hour | 3,600.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 1,152.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | slot | 4,608.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | wd_hour | 5,664.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | 15m | 2,880.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | hour | 720.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 8,640.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | wd_hour | 3,600.00 | 12.00 | 12.00 | 1.00 | 0.00 | 0.00 |
| M5 | 240 | 15m | 4,608.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | hour | 1,152.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | slot | 13,824.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | wd_hour | 5,664.00 | 3.00 | 0.00 | 1.00 | 0.00 | 0.00 |


## D. Padrões estruturais (condição × hora/sessão, além do efeito do relógio)

| tf | W | k_tested | tests | validated | race | ev_buy | ev_sell | placebo_mean | placebo_max |
|---|---|---|---|---|---|---|---|---|---|
| M15 | 60 | 50,100 | 25644 | 1 | 1 | 0 | 0 | 4.62 | 9 |
| M15 | 240 | 100,150 | 25560 | 34 | 0 | 0 | 34 | 24.62 | 35 |
| M5 | 60 | 50,100 | 25218 | 4 | 2 | 0 | 2 | 7.25 | 16 |
| M5 | 240 | 100,150 | 25074 | 33 | 4 | 0 | 29 | 61.38 | 181 |


`D_estruturais_M15_W240.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 150 | EV_SELL_Ak | streak=2 baixas & weekday=SEX & Tarde(20-24) | 83 | 47 | 59.46 | 6.48 | 55.54 | 3.37 | 24.27 |
| 150 | EV_SELL_Ak | prev1=baixa & weekday=SEX & Tarde(20-24) | 280 | 78 | 51.99 | 6.36 | 66.34 | 5.78 | 35.34 |
| 100 | EV_SELL_Ak | prev1=baixa & weekday=SEX & Tarde(20-24) | 280 | 78 | 43.99 | 6.04 | 53.98 | 5.42 | 26.41 |
| 150 | EV_SELL_Ak | tickvol=baixo & weekday=SEX & Tarde(20-24) | 312 | 42 | 57.77 | 5.81 | 74.66 | 7.96 | 42.26 |
| 150 | EV_SELL_Ak | spread=normal & weekday=SEX & Tarde(20-24) | 713 | 84 | 42.38 | 5.66 | 73.27 | 7.42 | 40.43 |
| 150 | EV_SELL_Ak | weekday=SEX & hora=20h | 568 | 84 | 43.14 | 5.58 | 71.43 | 6.99 | 39.37 |
| 150 | EV_SELL_Ak | brk=dentro & weekday=SEX & Tarde(20-24) | 619 | 82 | 44.09 | 5.49 | 75.13 | 7.39 | 42.40 |
| 150 | EV_SELL_Ak | extreme=normal & weekday=SEX & Tarde(20-24) | 663 | 82 | 41.02 | 5.37 | 69.70 | 7.01 | 36.88 |
| 100 | EV_SELL_Ak | streak=3+ baixas & weekday=SEX & Tarde(20-24) | 110 | 35 | 50.91 | 5.26 | 61.22 | 5.45 | 33.53 |
| 150 | EV_SELL_Ak | weekday=SEX & hora=21h | 144 | 84 | 41.40 | 5.21 | 80.77 | 7.91 | 44.75 |
| 100 | EV_SELL_Ak | weekday=SEX & hora=20h | 568 | 84 | 34.35 | 5.21 | 48.22 | 5.34 | 21.67 |
| 150 | EV_SELL_Ak | streak=3+ baixas & weekday=SEX & Tarde(20-24) | 110 | 35 | 64.69 | 5.13 | 66.36 | 4.97 | 34.12 |
| 100 | EV_SELL_Ak | spread=normal & weekday=SEX & Tarde(20-24) | 713 | 84 | 33.16 | 5.01 | 50.97 | 5.79 | 22.88 |
| 100 | EV_SELL_Ak | brk=dentro & weekday=SEX & Tarde(20-24) | 619 | 82 | 34.95 | 5.00 | 55.03 | 6.06 | 27.07 |
| 100 | EV_SELL_Ak | streak=2 baixas & weekday=SEX & Tarde(20-24) | 83 | 47 | 45.36 | 4.98 | 40.84 | 2.68 | 12.85 |
| 150 | EV_SELL_Ak | compress=comprimido & weekday=SEX & Tarde(20-24) | 446 | 74 | 42.40 | 4.95 | 74.10 | 7.06 | 41.05 |
| 100 | EV_SELL_Ak | extreme=normal & weekday=SEX & Tarde(20-24) | 663 | 82 | 32.34 | 4.73 | 49.76 | 5.54 | 21.70 |
| 100 | EV_SELL_Ak | tickvol=baixo & weekday=SEX & Tarde(20-24) | 312 | 42 | 46.21 | 4.54 | 60.43 | 6.19 | 32.75 |
| 150 | EV_SELL_Ak | prevday=dia_ant_alta & weekday=SEX & Tarde(20-24) | 350 | 46 | 44.84 | 4.41 | 82.81 | 5.24 | 49.96 |
| 150 | EV_SELL_Ak | tickvol=normal & weekday=SEX & Tarde(20-24) | 193 | 53 | 45.22 | 4.34 | 65.59 | 2.35 | 32.50 |


`D_estruturais_M15_W60.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 50 | race | prev1=forte_baixa & hora=00h | 492 | 197 | 0.24 | 5.03 | 0.24 | 4.95 | 0.33 |


`D_estruturais_M5_W240.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 150 | EV_SELL_Ak | compress=comprimido & weekday=SEX & Tarde(20-24) | 483 | 42 | 68.22 | 5.40 | 72.15 | 6.10 | 44.76 |
| 150 | EV_SELL_Ak | streak=1 baixa & weekday=SEX & Tarde(20-24) | 281 | 45 | 59.60 | 5.22 | 86.38 | 7.09 | 57.78 |
| 100 | EV_SELL_Ak | compress=comprimido & weekday=SEX & Tarde(20-24) | 483 | 42 | 51.28 | 5.19 | 44.94 | 3.35 | 21.15 |
| 100 | race | brk=rompeu_max_fechou_fora & hora=23h | 143 | 53 | -0.34 | -5.16 | -0.36 | -2.41 | -0.61 |
| 150 | EV_SELL_Ak | prev1=alta & weekday=SEX & Tarde(20-24) | 362 | 45 | 54.44 | 5.04 | 74.63 | 5.79 | 48.27 |
| 150 | EV_SELL_Ak | extreme=normal & weekday=SEX & Tarde(20-24) | 1049 | 45 | 55.99 | 4.86 | 77.05 | 6.49 | 49.94 |
| 150 | EV_SELL_Ak | ret4=Q4 & weekday=SEX & Tarde(20-24) | 225 | 38 | 56.37 | 4.75 | 81.44 | 5.28 | 55.24 |
| 150 | EV_SELL_Ak | spread=normal & weekday=SEX & Tarde(20-24) | 1124 | 45 | 53.70 | 4.75 | 76.38 | 6.64 | 49.18 |
| 150 | EV_SELL_Ak | brk=dentro & weekday=SEX & Tarde(20-24) | 877 | 45 | 55.71 | 4.66 | 79.71 | 6.90 | 52.50 |
| 150 | EV_SELL_Ak | prev1=baixa & weekday=SEX & Tarde(20-24) | 339 | 44 | 63.91 | 4.66 | 78.41 | 7.47 | 50.82 |
| 100 | EV_SELL_Ak | streak=1 baixa & weekday=SEX & Tarde(20-24) | 281 | 45 | 44.48 | 4.58 | 49.93 | 3.50 | 25.57 |
| 150 | EV_SELL_Ak | weekday=SEX & hora=20h | 900 | 45 | 53.75 | 4.54 | 77.96 | 6.56 | 49.83 |
| 150 | EV_SELL_Ak | weekday=SEX & hora=21h | 224 | 45 | 53.52 | 4.46 | 69.99 | 5.77 | 46.55 |
| 100 | EV_SELL_Ak | weekday=SEX & hora=21h | 224 | 45 | 43.62 | 4.38 | 40.25 | 3.08 | 18.11 |
| 150 | EV_SELL_Ak | streak=1 alta & weekday=SEX & Tarde(20-24) | 286 | 45 | 52.07 | 4.32 | 79.76 | 6.41 | 53.62 |
| 100 | EV_SELL_Ak | spread=normal & weekday=SEX & Tarde(20-24) | 1124 | 45 | 39.54 | 4.29 | 44.59 | 3.47 | 20.94 |
| 100 | race | brk=rompeu_max_falhou & hora=23h | 162 | 63 | -0.31 | -4.27 | -0.53 | -5.89 | -0.78 |
| 100 | EV_SELL_Ak | prev1=baixa & weekday=SEX & Tarde(20-24) | 339 | 44 | 43.08 | 4.27 | 56.48 | 4.70 | 32.56 |
| 100 | EV_SELL_Ak | extreme=normal & weekday=SEX & Tarde(20-24) | 1049 | 45 | 40.38 | 4.22 | 44.52 | 3.38 | 20.92 |
| 100 | race | compress=expandido & extreme=extremo_alta & Tarde(20-24) | 217 | 42 | -0.34 | -4.14 | -0.47 | -4.10 | -0.70 |


`D_estruturais_M5_W60.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 50 | race | ret4=Q1(caiu+) & hora=00h | 1081 | 203 | 0.25 | 7.73 | 0.14 | 3.12 | 0.42 |
| 100 | EV_SELL_Ak | weekday=SEX & hora=23h | 149 | 45 | 50.92 | 7.46 | 42.09 | 3.79 | 29.17 |
| 100 | race | extreme=extremo_baixa & hora=00h | 196 | 42 | 0.39 | 4.89 | 0.46 | 5.18 | 0.56 |
| 50 | EV_SELL_Ak | weekday=SEX & hora=23h | 149 | 45 | 28.50 | 4.81 | 33.43 | 4.47 | 19.25 |


## F. Distância × tempo e devolução

Das entradas que chegaram a +k (M15, janela 240 min), quantas terminaram a janela no prejuízo (o alvo foi tocado e devolvido):

| k_pts | side | hits | ended_negative_pct | ended_below_half_k_pct |
|---|---|---|---|---|
| 25 | BUY | 48493 | 39.8 | 45.2 |
| 25 | SELL | 48579 | 42.0 | 47.2 |
| 50 | BUY | 38334 | 29.9 | 39.1 |
| 50 | SELL | 38549 | 32.2 | 41.7 |
| 100 | BUY | 23059 | 16.3 | 28.6 |
| 100 | SELL | 23263 | 18.5 | 31.8 |
| 150 | BUY | 13545 | 10.4 | 22.3 |
| 150 | SELL | 14137 | 11.8 | 25.0 |
| 200 | BUY | 8053 | 7.9 | 18.4 |
| 200 | SELL | 8638 | 8.8 | 21.0 |
| 300 | BUY | 3175 | 5.4 | 14.1 |
| 300 | SELL | 3342 | 6.0 | 15.0 |
| 400 | BUY | 1418 | 5.4 | 13.8 |
| 400 | SELL | 1434 | 3.8 | 11.0 |
| 500 | BUY | 615 | 5.2 | 14.8 |
| 500 | SELL | 717 | 3.1 | 8.9 |


## I. Outras regularidades

Hora do servidor em que se formou a máxima / mínima do dia (% dos dias, M15):

| hora | pct_dias_max_do_dia | pct_dias_min_do_dia |
|---|---|---|
| 0 | 2.8 | 23.2 |
| 1 | 5.2 | 1.3 |
| 2 | 3.7 | 2.2 |
| 3 | 8.2 | 4.4 |
| 4 | 4.5 | 3.7 |
| 5 | 4.1 | 3.5 |
| 6 | 2.1 | 2.7 |
| 7 | 2.2 | 1.7 |
| 8 | 2.0 | 2.2 |
| 9 | 4.1 | 1.8 |
| 10 | 3.4 | 2.7 |
| 11 | 2.5 | 1.8 |
| 12 | 1.4 | 2.0 |
| 13 | 2.4 | 1.7 |
| 14 | 1.7 | 2.2 |
| 15 | 6.3 | 4.6 |
| 16 | 6.2 | 4.1 |
| 17 | 9.0 | 6.8 |
| 18 | 6.5 | 4.2 |
| 19 | 3.0 | 5.3 |
| 20 | 3.9 | 3.7 |
| 21 | 4.2 | 4.4 |
| 22 | 4.4 | 4.6 |
| 23 | 6.3 | 5.2 |


Continuidade entre sessões (mesmo sinal do movimento; 50% = sem relação):

| de | para | periodo | dias | mesmo_sinal_pct | z | corr |
|---|---|---|---|---|---|---|
| Asia(01-09) | Londres(09-15) | descoberta | 426 | 49.77 | -0.10 | 0.04 |
| Asia(01-09) | Londres(09-15) | validacao | 283 | 47.00 | -1.01 | -0.11 |
| Londres(09-15) | NY(15-20) | descoberta | 426 | 49.53 | -0.19 | 0.04 |
| Londres(09-15) | NY(15-20) | validacao | 284 | 54.93 | 1.66 | 0.08 |
| Asia(01-09) | NY(15-20) | descoberta | 426 | 50.94 | 0.39 | -0.01 |
| Asia(01-09) | NY(15-20) | validacao | 284 | 49.65 | -0.12 | 0.04 |
| NY(15-20) | Tarde(20-24) | descoberta | 425 | 49.88 | -0.05 | -0.03 |
| NY(15-20) | Tarde(20-24) | validacao | 284 | 44.72 | -1.78 | -0.06 |
| Dia anterior | Dia | descoberta | 425 | 48.00 | -0.82 | -0.09 |
| Dia anterior | Dia | validacao | 285 | 42.46 | -2.55 | -0.06 |


Gap de segunda-feira (abertura da semana vs fechamento de sexta) fechado no mesmo dia, comparado com a chance de o preço andar a mesma distância nos outros dias:

| symbol | segundas | gap_mediano_pts | gap_fechou_pct | base_outros_dias_pct | gaps_grandes | gap_grande_fechou_pct | base_gaps_grandes_pct | gap_alta_pct |
|---|---|---|---|---|---|---|---|---|
| AUDUSD | 75 | 124.0 | 86.7 | 67.1 | 38 | 84.2 | 50.5 | 25.3 |
