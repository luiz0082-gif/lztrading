# DXY_Z6 — investigação de alcance, horário e repetição

## A. Qualidade e cobertura dos dados

| tf | first | last | trading_days | bars | gaps_gt_bar | gaps_gt15m | max_gap_min | pct_tick_spread | spread_med | spread_p90 | bad_ohlc | dup_time |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 2026-03-11 23:06:00 | 2026-10-16 23:58:00 | 158 | 200000 | 330 | 127 | 721 | 17.7 | 30.0 | 30.0 | 0 | 0 |
| M5 | 2025-05-15 04:50:00 | 2026-10-16 23:50:00 | 370 | 94349 | 308 | 299 | 1820 | 7.5 | 30.0 | 30.0 | 0 | 0 |
| M15 | 2024-09-10 22:15:00 | 2026-10-16 23:30:00 | 543 | 46126 | 437 | 437 | 1830 | 5.1 | 30.0 | 30.0 | 0 | 0 |


Ponto MT5 = 0.001, tick size = 0.001, tick value = 0.1 (USD por tick por lote), contrato = 100.0. Barras de BID. Custo = spread medido nos ticks (perfil por faixa de 30 min do servidor onde não há tick) + swap; comissão não declarada pela corretora (não incluída).


**Limitação:** o M1 deste ativo só cobre ~mar/abr–out/2026 (≈140–158 dias, um único regime). Resultados de M1 são exploratórios; a confirmação vem de M5 (mai/2025→) e M15 (jan/2024→).


## C. Distâncias percorridas (operação executável, líquida de spread)


**M15, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 44487 | 68.5 | 39.5 | 39.1-40.0 | 15.0 | 45.0 | 45.0 | 90.0 | 0.0 | 100.0 | 13.8 | 0.0 |
| 25 | SELL | 44487 | 67.0 | 38.5 | 38.1-39.0 | 15.0 | 45.0 | 45.0 | 93.0 | 0.0 | 100.0 | 13.7 | 0.0 |
| 50 | BUY | 44487 | 43.4 | 24.3 | 23.9-24.7 | 15.0 | 45.0 | 45.0 | 95.0 | 13.2 | 71.4 | 2.0 | 16.0 |
| 50 | SELL | 44487 | 42.3 | 24.1 | 23.7-24.5 | 15.0 | 45.0 | 47.0 | 98.0 | 12.8 | 72.9 | 2.1 | 15.3 |
| 100 | BUY | 44487 | 16.5 | 9.4 | 9.1-9.7 | 30.0 | 45.0 | 48.0 | 105.0 | 8.3 | 28.7 | 0.2 | 22.6 |
| 100 | SELL | 44487 | 17.0 | 10.4 | 10.1-10.7 | 30.0 | 45.0 | 48.0 | 107.4 | 9.1 | 29.3 | 0.3 | 23.9 |
| 150 | BUY | 44487 | 6.7 | 4.2 | 4.0-4.4 | 30.0 | 45.0 | 50.0 | 118.0 | 3.9 | 12.2 | 0.1 | 24.5 |
| 150 | SELL | 44487 | 7.7 | 5.0 | 4.8-5.2 | 30.0 | 45.0 | 50.0 | 113.0 | 4.8 | 11.3 | 0.1 | 30.0 |
| 200 | BUY | 44487 | 3.1 | 2.1 | 2.0-2.3 | 30.0 | 45.0 | 52.0 | 125.0 | 2.1 | 5.8 | 0.0 | 26.4 |
| 200 | SELL | 44487 | 3.8 | 2.7 | 2.6-2.9 | 30.0 | 45.0 | 50.0 | 118.0 | 2.7 | 4.8 | 0.0 | 35.8 |
| 300 | BUY | 44487 | 1.0 | 0.7 | 0.7-0.8 | 30.0 | 45.0 | 58.0 | 153.0 | 0.7 | 1.7 | 0.0 | 29.7 |
| 300 | SELL | 44487 | 1.2 | 0.9 | 0.8-1.0 | 30.0 | 45.0 | 53.0 | 135.0 | 0.9 | 1.3 | 0.0 | 40.1 |


**M15, janela 240 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 40147 | 85.5 | 68.3 | 67.9-68.8 | 30.0 | 150.0 | 58.0 | 135.0 | 0.0 | 100.0 | 14.5 | 0.0 |
| 25 | SELL | 40147 | 83.9 | 66.4 | 66.0-66.9 | 30.0 | 150.0 | 60.0 | 140.0 | 0.0 | 100.0 | 14.3 | 0.0 |
| 50 | BUY | 40147 | 71.0 | 55.1 | 54.6-55.6 | 60.0 | 180.0 | 60.0 | 143.0 | 19.7 | 79.2 | 2.2 | 20.4 |
| 50 | SELL | 40147 | 69.2 | 54.0 | 53.5-54.5 | 60.0 | 180.0 | 63.0 | 150.0 | 18.5 | 80.7 | 2.3 | 19.1 |
| 100 | BUY | 40147 | 46.0 | 35.0 | 34.5-35.4 | 90.0 | 195.0 | 63.0 | 155.0 | 26.1 | 54.4 | 0.5 | 32.7 |
| 100 | SELL | 40147 | 45.6 | 35.3 | 34.8-35.8 | 90.0 | 195.0 | 65.0 | 158.0 | 25.6 | 56.5 | 0.5 | 31.3 |
| 150 | BUY | 40147 | 28.9 | 21.8 | 21.4-22.2 | 120.0 | 210.0 | 65.0 | 163.0 | 19.1 | 37.1 | 0.3 | 34.1 |
| 150 | SELL | 40147 | 29.7 | 23.0 | 22.6-23.5 | 105.0 | 210.0 | 67.0 | 160.0 | 20.2 | 36.8 | 0.2 | 35.6 |
| 200 | BUY | 40147 | 18.0 | 13.7 | 13.3-14.0 | 120.0 | 210.0 | 68.0 | 173.0 | 12.7 | 24.5 | 0.1 | 34.2 |
| 200 | SELL | 40147 | 19.5 | 15.3 | 14.9-15.6 | 120.0 | 210.0 | 68.0 | 160.0 | 14.4 | 23.3 | 0.1 | 38.3 |
| 300 | BUY | 40147 | 7.4 | 5.8 | 5.6-6.1 | 135.0 | 210.0 | 72.0 | 192.0 | 5.6 | 11.1 | 0.0 | 33.6 |
| 300 | SELL | 40147 | 8.9 | 7.0 | 6.8-7.3 | 135.0 | 210.0 | 70.0 | 170.0 | 6.8 | 9.4 | 0.0 | 41.9 |
| 400 | BUY | 40147 | 3.5 | 2.8 | 2.7-3.0 | 150.0 | 210.0 | 78.0 | 215.0 | 2.8 | 5.2 | 0.0 | 34.9 |
| 400 | SELL | 40147 | 4.2 | 3.4 | 3.2-3.6 | 135.0 | 210.0 | 72.0 | 172.9 | 3.4 | 4.3 | 0.0 | 43.6 |
| 500 | BUY | 40147 | 1.8 | 1.5 | 1.4-1.6 | 150.0 | 210.0 | 83.0 | 208.0 | 1.5 | 2.7 | 0.0 | 36.1 |
| 500 | SELL | 40147 | 2.2 | 1.8 | 1.7-2.0 | 150.0 | 210.0 | 73.0 | 175.0 | 1.8 | 2.2 | 0.0 | 45.7 |
| 600 | BUY | 40147 | 0.9 | 0.8 | 0.7-0.9 | 150.0 | 210.0 | 90.0 | 200.0 | 0.8 | 1.5 | 0.0 | 34.4 |
| 600 | SELL | 40147 | 1.3 | 1.1 | 1.0-1.2 | 150.0 | 210.0 | 77.0 | 232.0 | 1.0 | 1.2 | 0.0 | 47.3 |


**M1, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 191469 | 64.6 | 32.6 | 32.4-32.8 | 26.0 | 51.0 | 42.0 | 75.0 | 0.0 | 100.0 | 0.1 | 0.0 |
| 25 | SELL | 191469 | 61.2 | 31.1 | 30.9-31.3 | 25.0 | 51.0 | 43.0 | 80.0 | 0.0 | 100.0 | 0.2 | 0.0 |
| 50 | BUY | 191469 | 36.8 | 17.6 | 17.5-17.8 | 32.0 | 53.0 | 42.0 | 80.0 | 11.1 | 67.1 | 0.0 | 14.2 |
| 50 | SELL | 191469 | 34.8 | 17.9 | 17.7-18.0 | 30.0 | 53.0 | 45.0 | 83.0 | 10.7 | 70.4 | 0.1 | 13.2 |
| 100 | BUY | 191469 | 10.8 | 5.5 | 5.4-5.6 | 36.0 | 55.0 | 45.0 | 90.0 | 5.0 | 22.0 | 0.0 | 18.6 |
| 100 | SELL | 191469 | 12.0 | 7.3 | 7.2-7.4 | 35.0 | 54.0 | 45.0 | 90.0 | 6.7 | 22.4 | 0.0 | 23.2 |
| 150 | BUY | 191469 | 3.6 | 2.1 | 2.0-2.2 | 38.0 | 55.0 | 47.0 | 108.0 | 2.0 | 8.4 | 0.0 | 19.2 |
| 150 | SELL | 191469 | 5.4 | 3.6 | 3.5-3.6 | 36.0 | 55.0 | 45.0 | 93.0 | 3.5 | 6.8 | 0.0 | 34.1 |
| 200 | BUY | 191469 | 1.5 | 0.9 | 0.9-1.0 | 41.0 | 57.0 | 50.0 | 135.0 | 0.9 | 4.1 | 0.0 | 18.0 |
| 200 | SELL | 191469 | 2.7 | 1.9 | 1.9-2.0 | 36.0 | 55.0 | 45.0 | 95.0 | 1.9 | 2.5 | 0.0 | 43.7 |


## B. Varredura por horário (servidor)


% de entradas (M15, janela 60 min) que alcançaram a distância, por hora do servidor:


| hour | BUY ≥100 | BUY ≥300 | SELL ≥100 | SELL ≥300 |
|---|---|---|---|---|
| 1 | 6.0 | 0.2 | 10.6 | 0.7 |
| 2 | 4.8 | 0.7 | 11.9 | 0.2 |
| 3 | 5.4 | 0.2 | 7.0 | 0.5 |
| 4 | 4.4 | 0.3 | 5.0 | 0.2 |
| 5 | 2.4 | 0.2 | 3.1 | 0.2 |
| 6 | 1.4 | 0.0 | 3.0 | 0.2 |
| 7 | 2.6 | 0.2 | 3.8 | 0.2 |
| 8 | 5.1 | 0.3 | 8.1 | 0.2 |
| 9 | 12.4 | 0.4 | 13.2 | 0.7 |
| 10 | 12.9 | 1.2 | 14.8 | 1.2 |
| 11 | 7.8 | 0.2 | 10.3 | 0.7 |
| 12 | 6.5 | 0.3 | 7.4 | 0.7 |
| 13 | 6.9 | 0.5 | 8.6 | 0.7 |
| 14 | 13.0 | 0.6 | 14.8 | 1.4 |
| 15 | 21.8 | 2.9 | 23.3 | 4.5 |
| 16 | 22.4 | 1.8 | 23.1 | 2.4 |
| 17 | 23.7 | 1.3 | 22.1 | 1.3 |
| 18 | 15.8 | 1.1 | 12.2 | 0.7 |
| 19 | 9.0 | 0.5 | 9.1 | 0.2 |
| 20 | 7.1 | 1.1 | 8.0 | 0.8 |
| 21 | 6.2 | 1.3 | 7.5 | 0.8 |
| 22 | 4.6 | 0.4 | 4.1 | 0.7 |
| 23 | 1.7 | 0.2 | 4.1 | 0.6 |


Minuto a minuto (M1, janela 60 min, k = 100 pts; tabela completa em `B_varredura_relogio_M1_W60.csv.gz` com todos os minutos e limiares). Maiores e menores taxas de alcance:


Maior alcance (BUY):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 17:47 | 156 | 31 | 19.9 | 17 | 10.9 | 26.9 | 21.8 | 30.0 | 50.0 |
| 17:52 | 156 | 31 | 19.9 | 16 | 10.3 | 29.5 | 18.6 | 39.0 | 47.0 |
| 17:39 | 156 | 31 | 19.9 | 22 | 14.1 | 27.6 | 21.8 | 28.0 | 52.0 |
| 17:51 | 156 | 30 | 19.2 | 17 | 10.9 | 28.9 | 19.2 | 33.5 | 46.0 |
| 17:32 | 156 | 30 | 19.2 | 21 | 13.5 | 27.6 | 20.5 | 31.0 | 47.0 |
| 17:38 | 156 | 30 | 19.2 | 20 | 12.8 | 27.6 | 19.2 | 27.5 | 50.0 |
| 17:49 | 156 | 30 | 19.2 | 19 | 12.2 | 27.6 | 20.5 | 35.0 | 44.5 |
| 17:54 | 156 | 29 | 18.6 | 16 | 10.3 | 30.8 | 16.7 | 42.0 | 45.0 |
| 17:48 | 156 | 29 | 18.6 | 16 | 10.3 | 28.2 | 23.1 | 33.0 | 48.0 |
| 17:35 | 156 | 29 | 18.6 | 19 | 12.2 | 30.1 | 19.9 | 27.0 | 48.0 |


Maior alcance (SELL):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 16:20 | 157 | 14 | 8.9 | 32 | 20.4 | 15.3 | 28.0 | 31.5 | 45.0 |
| 16:18 | 157 | 17 | 10.8 | 32 | 20.4 | 15.3 | 30.6 | 33.0 | 48.0 |
| 16:19 | 157 | 17 | 10.8 | 32 | 20.4 | 15.9 | 27.4 | 33.0 | 48.0 |
| 02:55 | 31 | 1 | 3.2 | 6 | 19.4 | 3.2 | 19.4 | 45.0 | 90.0 |
| 02:58 | 31 | 1 | 3.2 | 6 | 19.4 | 3.2 | 19.4 | 42.0 | 90.0 |
| 02:47 | 31 | 1 | 3.2 | 6 | 19.4 | 3.2 | 22.6 | 49.0 | 60.0 |
| 02:48 | 31 | 1 | 3.2 | 6 | 19.4 | 3.2 | 19.4 | 48.0 | 65.0 |
| 02:59 | 31 | 1 | 3.2 | 6 | 19.4 | 3.2 | 19.4 | 38.0 | 83.0 |
| 02:49 | 31 | 1 | 3.2 | 6 | 19.4 | 3.2 | 22.6 | 47.0 | 58.0 |
| 02:50 | 31 | 1 | 3.2 | 6 | 19.4 | 3.2 | 19.4 | 46.0 | 65.0 |


Menor alcance (mercado parado):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 01:19 | 31 | 0 | 0.0 | 0 | 0.0 | 0.0 | 6.5 |  |  |
| 01:20 | 31 | 0 | 0.0 | 2 | 6.5 | 0.0 | 6.5 |  |  |
| 01:21 | 31 | 0 | 0.0 | 0 | 0.0 | 0.0 | 6.5 |  |  |
| 01:22 | 31 | 0 | 0.0 | 1 | 3.2 | 0.0 | 6.5 |  |  |
| 01:39 | 31 | 0 | 0.0 | 0 | 0.0 | 0.0 | 0.0 |  |  |


Maior assimetria BUY−SELL (só descritivo; o teste de direção está na seção E):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med | buy_menos_sell |
|---|---|---|---|---|---|---|---|---|---|---|
| 02:32 | 31 | 0 | 0.0 | 5 | 16.1 | 0.0 | 22.6 |  |  | -16.1 |
| 02:30 | 31 | 0 | 0.0 | 5 | 16.1 | 0.0 | 22.6 |  |  | -16.1 |
| 02:31 | 31 | 0 | 0.0 | 5 | 16.1 | 0.0 | 22.6 |  |  | -16.1 |
| 02:35 | 31 | 0 | 0.0 | 5 | 16.1 | 0.0 | 22.6 |  |  | -16.1 |
| 02:34 | 31 | 0 | 0.0 | 5 | 16.1 | 0.0 | 22.6 |  |  | -16.1 |
| 02:33 | 31 | 0 | 0.0 | 5 | 16.1 | 0.0 | 22.6 |  |  | -16.1 |
| 02:40 | 31 | 0 | 0.0 | 5 | 16.1 | 3.2 | 25.8 |  |  | -16.1 |
| 02:36 | 31 | 0 | 0.0 | 5 | 16.1 | 0.0 | 22.6 |  |  | -16.1 |
| 02:37 | 31 | 0 | 0.0 | 5 | 16.1 | 3.2 | 22.6 |  |  | -16.1 |
| 02:39 | 31 | 0 | 0.0 | 5 | 16.1 | 3.2 | 25.8 |  |  | -16.1 |


## E. Direção (BUY vs SELL) por horário — teste contra o próprio dia

y = +1 se o preço anda +k antes de −k, −1 no contrário. Tira-se a média do dia (dias de tendência não contam como sinal) e testa-se cada horário. Descoberta 60% / validação 40% cronológicos; BH na descoberta; placebo = troca aleatória de sinal por dia (200×).


| tf | W | clock | dir_tests | dir_validated | dir_fwer_and_val | dir_placebo_mean | dir_placebo_max |
|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 405.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | hour | 105.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 6,035.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |
| M1 | 240 | 15m | 584.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 152.00 | 0.00 | 0.00 | 0.02 | 1.00 |
| M1 | 240 | slot | 8,728.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |
| M15 | 60 | hour | 138.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 60 | slot | 534.00 | 0.00 | 0.00 | 0.02 | 2.00 |
| M15 | 60 | wd_hour | 642.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 189.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | slot | 729.00 | 0.00 | 0.00 | 0.01 | 1.00 |
| M15 | 240 | wd_hour | 873.00 | 0.00 | 0.00 | 0.01 | 1.00 |
| M5 | 60 | 15m | 445.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | hour | 115.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 1,330.00 | 1.00 | 1.00 | 0.01 | 1.00 |
| M5 | 60 | wd_hour | 535.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | 15m | 648.00 | 0.00 | 0.00 | 0.01 | 1.00 |
| M5 | 240 | hour | 168.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | slot | 1,944.00 | 1.00 | 1.00 | 0.00 | 0.00 |
| M5 | 240 | wd_hour | 776.00 | 0.00 | 0.00 | 0.01 | 2.00 |


Horários validados (descoberta + validação):

| arquivo | clock | direction | ks | n_dias | sobe_antes | cai_antes | t_desc | t_val | fwer |
|---|---|---|---|---|---|---|---|---|---|
| slot_M5_W240 | 01:00 | BUY (sobe k antes) | 25 | 73 | 65.75 | 19.18 | 4.47 | 2.43 | True |
| slot_M5_W60 | 01:00 | BUY (sobe k antes) | 25 | 73 | 65.75 | 17.81 | 4.43 | 2.66 | True |


## G. Operação executável por horário (alvo k, limite k / 2k / sem limite; custo e swap incluídos)

| tf | W | clock | ev_tests | ev_validated | ev_validated_bh | ev_clocks | ev_placebo_mean | ev_placebo_max |
|---|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 2,430.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | hour | 630.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 36,210.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |  |
| M1 | 240 | 15m | 3,504.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 912.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | slot | 52,368.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |  |
| M15 | 60 | hour | 828.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 60 | slot | 3,204.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 60 | wd_hour | 3,852.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 1,092.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | slot | 4,212.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M15 | 240 | wd_hour | 5,044.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | 15m | 2,670.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | hour | 690.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 7,980.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | wd_hour | 3,210.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | 15m | 3,888.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | hour | 1,008.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | slot | 11,664.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | wd_hour | 4,656.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |


## D. Padrões estruturais (condição × hora/sessão, além do efeito do relógio)

| tf | W | k_tested | tests | validated | race | ev_buy | ev_sell | placebo_mean | placebo_max |
|---|---|---|---|---|---|---|---|---|---|
| M15 | 60 | 50,100 | 24042 | 0 | 0 | 0 | 0 | 0.50 | 2 |
| M15 | 240 | 100,150 | 22584 | 0 | 0 | 0 | 0 | 0.50 | 2 |
| M5 | 60 | 50,100 | 24468 | 0 | 0 | 0 | 0 | 2.25 | 13 |
| M5 | 240 | 100,150 | 23094 | 0 | 0 | 0 | 0 | 3.88 | 16 |


## F. Distância × tempo e devolução

Das entradas que chegaram a +k (M15, janela 240 min), quantas terminaram a janela no prejuízo (o alvo foi tocado e devolvido):

| k_pts | side | hits | ended_negative_pct | ended_below_half_k_pct |
|---|---|---|---|---|
| 25 | BUY | 27434 | 39.8 | 45.2 |
| 25 | SELL | 26664 | 41.3 | 46.3 |
| 50 | BUY | 22110 | 31.2 | 39.9 |
| 50 | SELL | 21675 | 32.8 | 41.1 |
| 100 | BUY | 14038 | 20.1 | 32.0 |
| 100 | SELL | 14169 | 20.6 | 33.3 |
| 150 | BUY | 8739 | 13.3 | 25.7 |
| 150 | SELL | 9251 | 13.9 | 26.8 |
| 200 | BUY | 5481 | 9.5 | 21.7 |
| 200 | SELL | 6138 | 9.8 | 23.4 |
| 300 | BUY | 2336 | 5.4 | 15.0 |
| 300 | SELL | 2809 | 7.3 | 18.2 |
| 400 | BUY | 1131 | 4.6 | 12.2 |
| 400 | SELL | 1372 | 5.5 | 15.4 |
| 500 | BUY | 611 | 2.5 | 11.8 |
| 500 | SELL | 740 | 4.6 | 15.0 |
| 600 | BUY | 311 | 0.6 | 8.4 |
| 600 | SELL | 421 | 2.9 | 15.2 |


## I. Outras regularidades

Hora do servidor em que se formou a máxima / mínima do dia (% dos dias, M15):

| hora | pct_dias_max_do_dia | pct_dias_min_do_dia |
|---|---|---|
| 0 | 0.2 | 0.0 |
| 1 | 4.2 | 2.0 |
| 2 | 1.1 | 0.4 |
| 3 | 10.1 | 11.2 |
| 4 | 3.7 | 6.3 |
| 5 | 2.6 | 3.0 |
| 6 | 0.7 | 1.7 |
| 7 | 2.6 | 1.1 |
| 8 | 2.6 | 3.5 |
| 9 | 3.7 | 4.8 |
| 10 | 5.3 | 3.7 |
| 11 | 2.6 | 3.9 |
| 12 | 1.5 | 3.1 |
| 13 | 2.8 | 3.1 |
| 14 | 3.9 | 1.5 |
| 15 | 7.0 | 9.8 |
| 16 | 6.5 | 5.7 |
| 17 | 7.2 | 7.5 |
| 18 | 5.7 | 4.6 |
| 19 | 5.0 | 5.2 |
| 20 | 3.1 | 3.9 |
| 21 | 6.5 | 5.0 |
| 22 | 4.4 | 4.0 |
| 23 | 7.2 | 5.2 |


Continuidade entre sessões (mesmo sinal do movimento; 50% = sem relação):

| de | para | periodo | dias | mesmo_sinal_pct | z | corr |
|---|---|---|---|---|---|---|
| Asia(01-09) | Londres(09-15) | descoberta | 320 | 49.06 | -0.34 | 0.03 |
| Asia(01-09) | Londres(09-15) | validacao | 217 | 51.15 | 0.34 | 0.00 |
| Londres(09-15) | NY(15-20) | descoberta | 320 | 49.38 | -0.22 | 0.02 |
| Londres(09-15) | NY(15-20) | validacao | 216 | 51.39 | 0.41 | 0.07 |
| Asia(01-09) | NY(15-20) | descoberta | 320 | 50.62 | 0.22 | -0.04 |
| Asia(01-09) | NY(15-20) | validacao | 215 | 46.98 | -0.89 | -0.01 |
| NY(15-20) | Tarde(20-24) | descoberta | 317 | 47.00 | -1.07 | 0.05 |
| NY(15-20) | Tarde(20-24) | validacao | 211 | 46.92 | -0.90 | 0.05 |
| Dia anterior | Dia | descoberta | 320 | 50.62 | 0.22 | 0.01 |
| Dia anterior | Dia | validacao | 212 | 46.23 | -1.10 | -0.03 |


Gap de segunda-feira (abertura da semana vs fechamento de sexta) fechado no mesmo dia, comparado com a chance de o preço andar a mesma distância nos outros dias:

| symbol | segundas | gap_mediano_pts | gap_fechou_pct | base_outros_dias_pct | gaps_grandes | gap_grande_fechou_pct | base_gaps_grandes_pct | gap_alta_pct |
|---|---|---|---|---|---|---|---|---|
| DXY_Z6 | 18 | 267.0 | 44.4 | 38.8 | 9 | 44.4 | 23.1 | 61.1 |
