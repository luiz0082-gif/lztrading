# USDCHF — investigação de alcance, horário e repetição

## A. Qualidade e cobertura dos dados

| tf | first | last | trading_days | bars | gaps_gt_bar | gaps_gt15m | max_gap_min | pct_tick_spread | spread_med | spread_p90 | bad_ohlc | dup_time |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 2026-04-06 19:53:00 | 2026-10-16 23:55:00 | 140 | 200000 | 22 | 2 | 123 | 61.7 | 0.7 | 3.0 | 0 | 0 |
| M5 | 2025-05-15 03:25:00 | 2026-10-16 23:50:00 | 370 | 106442 | 9 | 3 | 125 | 23.2 | 2.0 | 3.0 | 0 | 0 |
| M15 | 2024-01-22 05:30:00 | 2026-10-16 23:30:00 | 711 | 68213 | 3 | 3 | 120 | 12.1 | 1.9 | 3.0 | 0 | 0 |


Ponto MT5 = 1e-05, tick size = 1e-05, tick value = 1.213268 (USD por tick por lote), contrato = 100000.0. Barras de BID. Custo = spread medido nos ticks (perfil por faixa de 30 min do servidor onde não há tick) + swap; comissão não declarada pela corretora (não incluída).


**Limitação:** o M1 deste ativo só cobre ~mar/abr–out/2026 (≈140–158 dias, um único regime). Resultados de M1 são exploratórios; a confirmação vem de M5 (mai/2025→) e M15 (jan/2024→).


## C. Distâncias percorridas (operação executável, líquida de spread)


**M15, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 67760 | 65.5 | 60.2 | 59.9-60.6 | 0.0 | 30.0 | 17.7 | 63.1 | 38.1 | 57.2 | 9.2 | 44.2 |
| 25 | SELL | 67760 | 65.3 | 60.6 | 60.2-61.0 | 0.0 | 30.0 | 18.2 | 68.7 | 37.4 | 58.1 | 9.8 | 43.6 |
| 50 | BUY | 67760 | 40.3 | 36.6 | 36.3-37.0 | 15.0 | 45.0 | 17.9 | 67.0 | 30.6 | 40.8 | 1.7 | 43.9 |
| 50 | SELL | 67760 | 41.3 | 37.6 | 37.2-38.0 | 15.0 | 45.0 | 18.8 | 71.8 | 30.9 | 40.7 | 2.2 | 44.5 |
| 100 | BUY | 67760 | 15.0 | 13.6 | 13.3-13.8 | 30.0 | 45.0 | 19.6 | 80.9 | 12.7 | 20.1 | 0.3 | 38.9 |
| 100 | SELL | 67760 | 17.1 | 15.0 | 14.7-15.2 | 30.0 | 45.0 | 19.9 | 79.0 | 14.1 | 18.2 | 0.3 | 44.0 |
| 150 | BUY | 67760 | 6.1 | 5.6 | 5.4-5.7 | 30.0 | 45.0 | 22.6 | 94.9 | 5.3 | 9.2 | 0.1 | 37.0 |
| 150 | SELL | 67760 | 7.6 | 6.5 | 6.4-6.7 | 30.0 | 45.0 | 21.9 | 85.8 | 6.3 | 7.4 | 0.1 | 46.5 |
| 200 | BUY | 67760 | 2.8 | 2.6 | 2.5-2.7 | 30.0 | 45.0 | 25.9 | 109.7 | 2.5 | 4.4 | 0.0 | 36.4 |
| 200 | SELL | 67760 | 3.8 | 3.2 | 3.1-3.4 | 30.0 | 45.0 | 22.8 | 87.9 | 3.2 | 3.2 | 0.0 | 49.7 |
| 300 | BUY | 67760 | 0.9 | 0.8 | 0.8-0.9 | 30.0 | 45.0 | 30.9 | 138.4 | 0.8 | 1.2 | 0.0 | 41.4 |
| 300 | SELL | 67760 | 1.1 | 1.0 | 0.9-1.1 | 30.0 | 45.0 | 25.9 | 94.1 | 1.0 | 0.9 | 0.0 | 50.9 |


**M15, janela 240 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 66563 | 83.2 | 79.5 | 79.2-79.8 | 15.0 | 120.0 | 24.9 | 108.3 | 40.1 | 59.9 | 9.3 | 44.2 |
| 25 | SELL | 66563 | 84.6 | 81.2 | 80.9-81.5 | 15.0 | 120.0 | 26.6 | 108.9 | 39.3 | 60.7 | 10.2 | 43.8 |
| 50 | BUY | 66563 | 67.2 | 63.6 | 63.3-64.0 | 45.0 | 165.0 | 29.9 | 117.8 | 42.4 | 55.3 | 1.9 | 44.2 |
| 50 | SELL | 66563 | 70.6 | 66.2 | 65.8-66.6 | 45.0 | 165.0 | 31.9 | 115.8 | 42.8 | 55.1 | 2.9 | 45.0 |
| 100 | BUY | 66563 | 41.3 | 38.8 | 38.4-39.1 | 75.0 | 195.0 | 34.2 | 125.9 | 32.7 | 45.1 | 0.6 | 42.3 |
| 100 | SELL | 66563 | 46.6 | 41.6 | 41.2-42.0 | 75.0 | 195.0 | 36.7 | 123.8 | 35.2 | 42.1 | 0.7 | 46.0 |
| 150 | BUY | 66563 | 24.9 | 23.4 | 23.1-23.8 | 105.0 | 210.0 | 36.2 | 131.9 | 21.7 | 30.0 | 0.2 | 42.1 |
| 150 | SELL | 66563 | 29.2 | 25.5 | 25.2-25.9 | 105.0 | 195.0 | 36.8 | 126.9 | 23.8 | 25.8 | 0.2 | 48.2 |
| 200 | BUY | 66563 | 14.9 | 14.0 | 13.8-14.3 | 120.0 | 210.0 | 38.2 | 143.9 | 13.4 | 18.9 | 0.1 | 41.5 |
| 200 | SELL | 66563 | 18.3 | 16.1 | 15.8-16.3 | 120.0 | 210.0 | 37.8 | 131.0 | 15.6 | 15.1 | 0.1 | 50.8 |
| 300 | BUY | 66563 | 6.0 | 5.7 | 5.5-5.9 | 135.0 | 210.0 | 45.4 | 161.6 | 5.6 | 7.9 | 0.0 | 41.7 |
| 300 | SELL | 66563 | 7.8 | 7.2 | 7.0-7.4 | 135.0 | 210.0 | 37.9 | 139.9 | 7.1 | 6.1 | 0.0 | 54.0 |
| 400 | BUY | 66563 | 2.8 | 2.7 | 2.6-2.8 | 135.0 | 210.0 | 51.7 | 178.6 | 2.6 | 3.6 | 0.0 | 42.7 |
| 400 | SELL | 66563 | 3.5 | 3.4 | 3.3-3.5 | 135.0 | 210.0 | 39.7 | 147.9 | 3.4 | 2.8 | 0.0 | 54.6 |
| 500 | BUY | 66563 | 1.5 | 1.5 | 1.4-1.6 | 135.0 | 210.0 | 53.0 | 186.9 | 1.4 | 1.8 | 0.0 | 44.5 |
| 500 | SELL | 66563 | 1.8 | 1.7 | 1.6-1.8 | 150.0 | 210.0 | 43.9 | 165.1 | 1.7 | 1.5 | 0.0 | 53.0 |
| 600 | BUY | 66563 | 0.8 | 0.8 | 0.7-0.8 | 150.0 | 210.0 | 62.7 | 187.2 | 0.8 | 1.0 | 0.0 | 43.0 |
| 600 | SELL | 66563 | 1.0 | 1.0 | 0.9-1.1 | 150.0 | 210.0 | 43.9 | 163.3 | 1.0 | 0.8 | 0.0 | 55.7 |


**M1, janela 60 min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; `t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).


| k_pts | side | n | gross_reach_pct | net_reach_pct | ci95 | t_med_min | t_p90_min | mae_before_med | mae_before_p90 | race_win_pct | race_loss_pct | race_samebar_pct | race_win_of_determined_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | BUY | 198198 | 63.6 | 57.7 | 57.5-57.9 | 14.0 | 44.0 | 12.8 | 47.5 | 42.2 | 52.2 | 0.1 | 44.8 |
| 25 | SELL | 198198 | 61.6 | 56.3 | 56.1-56.5 | 13.0 | 44.0 | 13.5 | 51.0 | 40.0 | 54.4 | 0.8 | 42.8 |
| 50 | BUY | 198198 | 37.0 | 32.6 | 32.4-32.8 | 25.0 | 51.0 | 14.4 | 52.1 | 29.1 | 37.1 | 0.1 | 44.0 |
| 50 | SELL | 198198 | 36.2 | 32.1 | 31.9-32.3 | 23.5 | 50.0 | 15.5 | 58.3 | 27.8 | 38.4 | 0.6 | 42.4 |
| 100 | BUY | 198198 | 11.2 | 9.7 | 9.6-9.8 | 35.0 | 55.0 | 15.2 | 61.8 | 9.3 | 17.0 | 0.0 | 35.3 |
| 100 | SELL | 198198 | 13.8 | 11.5 | 11.3-11.6 | 32.0 | 54.0 | 17.6 | 64.7 | 11.0 | 14.7 | 0.1 | 43.1 |
| 150 | BUY | 198198 | 3.6 | 3.0 | 3.0-3.1 | 39.0 | 56.0 | 16.7 | 83.0 | 3.0 | 7.8 | 0.0 | 27.5 |
| 150 | SELL | 198198 | 6.3 | 4.8 | 4.8-4.9 | 36.0 | 55.0 | 18.0 | 68.4 | 4.8 | 4.9 | 0.0 | 49.3 |
| 200 | BUY | 198198 | 1.3 | 1.1 | 1.0-1.1 | 37.0 | 56.0 | 21.9 | 119.6 | 1.1 | 3.6 | 0.0 | 22.6 |
| 200 | SELL | 198198 | 3.1 | 2.2 | 2.2-2.3 | 38.0 | 55.0 | 18.0 | 68.8 | 2.2 | 1.8 | 0.0 | 55.7 |


## B. Varredura por horário (servidor)


% de entradas (M15, janela 60 min) que alcançaram a distância, por hora do servidor:


| hour | BUY ≥100 | BUY ≥300 | SELL ≥100 | SELL ≥300 |
|---|---|---|---|---|
| 0 | 5.3 | 0.5 | 5.4 | 0.1 |
| 1 | 11.1 | 0.6 | 4.5 | 0.3 |
| 2 | 5.3 | 0.4 | 7.8 | 0.5 |
| 3 | 7.8 | 0.1 | 10.2 | 0.5 |
| 4 | 6.9 | 0.3 | 6.2 | 0.3 |
| 5 | 4.2 | 0.2 | 4.3 | 0.2 |
| 6 | 2.6 | 0.0 | 4.1 | 0.4 |
| 7 | 3.5 | 0.1 | 5.8 | 0.2 |
| 8 | 9.6 | 0.5 | 11.9 | 0.5 |
| 9 | 20.4 | 1.4 | 22.4 | 1.2 |
| 10 | 22.4 | 1.5 | 25.2 | 1.6 |
| 11 | 18.8 | 0.7 | 19.7 | 1.0 |
| 12 | 14.8 | 0.5 | 14.7 | 0.7 |
| 13 | 13.5 | 0.3 | 14.2 | 0.7 |
| 14 | 21.8 | 1.2 | 23.3 | 1.9 |
| 15 | 30.3 | 3.5 | 34.8 | 4.3 |
| 16 | 33.9 | 2.1 | 35.4 | 3.0 |
| 17 | 33.4 | 2.1 | 32.3 | 2.2 |
| 18 | 21.4 | 1.0 | 18.6 | 0.6 |
| 19 | 11.9 | 0.4 | 13.8 | 0.4 |
| 20 | 9.1 | 0.7 | 11.1 | 0.7 |
| 21 | 8.3 | 1.2 | 9.8 | 0.9 |
| 22 | 5.2 | 0.5 | 6.0 | 0.4 |
| 23 | 2.8 | 0.0 | 18.6 | 0.8 |


Minuto a minuto (M1, janela 60 min, k = 100 pts; tabela completa em `B_varredura_relogio_M1_W60.csv.gz` com todos os minutos e limiares). Maiores e menores taxas de alcance:


Maior alcance (BUY):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 17:09 | 139 | 49 | 35.2 | 40 | 28.8 | 33.8 | 29.5 | 35.0 | 22.6 |
| 17:07 | 139 | 48 | 34.5 | 41 | 29.5 | 32.4 | 28.1 | 37.0 | 28.1 |
| 17:13 | 139 | 47 | 33.8 | 36 | 25.9 | 31.6 | 26.6 | 34.0 | 20.7 |
| 17:23 | 139 | 47 | 33.8 | 33 | 23.7 | 34.5 | 24.5 | 34.0 | 26.7 |
| 17:25 | 139 | 47 | 33.8 | 36 | 25.9 | 33.8 | 23.7 | 31.0 | 21.8 |
| 17:30 | 139 | 46 | 33.1 | 37 | 26.6 | 30.9 | 25.2 | 26.0 | 24.2 |
| 17:35 | 139 | 46 | 33.1 | 34 | 24.5 | 31.6 | 23.7 | 27.5 | 22.5 |
| 17:14 | 139 | 46 | 33.1 | 35 | 25.2 | 33.1 | 24.5 | 31.0 | 26.0 |
| 17:27 | 139 | 46 | 33.1 | 35 | 25.2 | 32.4 | 24.5 | 31.5 | 23.9 |
| 17:08 | 139 | 45 | 32.4 | 41 | 29.5 | 33.1 | 27.3 | 33.0 | 24.6 |


Maior alcance (SELL):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 16:56 | 139 | 38 | 27.3 | 50 | 36.0 | 28.8 | 32.4 | 31.5 | 17.0 |
| 16:55 | 139 | 41 | 29.5 | 49 | 35.2 | 28.8 | 33.8 | 31.0 | 24.6 |
| 16:59 | 139 | 39 | 28.1 | 48 | 34.5 | 25.2 | 33.1 | 37.0 | 29.4 |
| 16:54 | 139 | 39 | 28.1 | 47 | 33.8 | 28.8 | 33.1 | 37.0 | 25.9 |
| 16:58 | 139 | 40 | 28.8 | 47 | 33.8 | 27.3 | 30.9 | 34.0 | 21.0 |
| 16:57 | 139 | 39 | 28.1 | 47 | 33.8 | 27.3 | 31.6 | 36.0 | 22.9 |
| 17:01 | 139 | 39 | 28.1 | 46 | 33.1 | 28.1 | 33.1 | 35.0 | 25.4 |
| 17:00 | 139 | 41 | 29.5 | 46 | 33.1 | 27.3 | 31.6 | 39.0 | 25.0 |
| 16:21 | 139 | 36 | 25.9 | 45 | 32.4 | 23.7 | 30.9 | 28.0 | 15.6 |
| 16:20 | 139 | 32 | 23.0 | 45 | 32.4 | 20.9 | 32.4 | 29.0 | 17.1 |


Menor alcance (mercado parado):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med |
|---|---|---|---|---|---|---|---|---|---|
| 23:38 | 112 | 0 | 0.0 | 24 | 21.4 | 0.9 | 74.1 |  |  |
| 01:45 | 139 | 0 | 0.0 | 3 | 2.2 | 0.7 | 2.2 |  |  |
| 01:42 | 139 | 0 | 0.0 | 3 | 2.2 | 0.0 | 2.2 |  |  |
| 01:33 | 139 | 0 | 0.0 | 3 | 2.2 | 0.0 | 2.2 |  |  |
| 01:38 | 139 | 0 | 0.0 | 3 | 2.2 | 0.0 | 2.2 |  |  |


Maior assimetria BUY−SELL (só descritivo; o teste de direção está na seção E):

| clock | n | buy_hits | buy_pct | sell_hits | sell_pct | up_first_pct | down_first_pct | buy_t_med_min | buy_mae_med | buy_menos_sell |
|---|---|---|---|---|---|---|---|---|---|---|
| 23:58 | 110 | 1 | 0.9 | 27 | 24.6 | 0.9 | 71.8 | 2.0 | 102.0 | -23.6 |
| 23:26 | 112 | 1 | 0.9 | 27 | 24.1 | 0.9 | 75.0 | 33.0 | 70.2 | -23.2 |
| 23:08 | 112 | 1 | 0.9 | 26 | 23.2 | 0.9 | 66.1 | 17.0 | 4.6 | -22.3 |
| 23:21 | 112 | 1 | 0.9 | 26 | 23.2 | 0.9 | 67.9 | 38.0 | 58.2 | -22.3 |
| 23:17 | 112 | 1 | 0.9 | 26 | 23.2 | 0.9 | 67.0 | 42.0 | 70.2 | -22.3 |
| 23:27 | 112 | 1 | 0.9 | 26 | 23.2 | 0.9 | 75.9 | 32.0 | 78.2 | -22.3 |
| 23:28 | 112 | 1 | 0.9 | 26 | 23.2 | 0.9 | 75.0 | 31.0 | 69.2 | -22.3 |
| 23:55 | 110 | 1 | 0.9 | 25 | 22.7 | 0.9 | 74.5 | 5.0 | 91.0 | -21.8 |
| 23:57 | 110 | 1 | 0.9 | 25 | 22.7 | 0.9 | 74.5 | 3.0 | 89.0 | -21.8 |
| 23:48 | 110 | 0 | 0.0 | 24 | 21.8 | 0.9 | 74.5 |  |  | -21.8 |


## E. Direção (BUY vs SELL) por horário — teste contra o próprio dia

y = +1 se o preço anda +k antes de −k, −1 no contrário. Tira-se a média do dia (dias de tendência não contam como sinal) e testa-se cada horário. Descoberta 60% / validação 40% cronológicos; BH na descoberta; placebo = troca aleatória de sinal por dia (200×).


| tf | W | clock | dir_tests | dir_validated | dir_fwer_and_val | dir_placebo_mean | dir_placebo_max |
|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 480.00 | 45.00 | 38.00 | 0.04 | 2.00 |
| M1 | 60 | hour | 120.00 | 15.00 | 13.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 7,195.00 | 705.00 | 593.00 | 0.30 | 15.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |
| M1 | 240 | 15m | 768.00 | 74.00 | 59.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 192.00 | 20.00 | 18.00 | 0.00 | 0.00 |
| M1 | 240 | slot | 11,512.00 | 1,040.00 | 658.00 | 0.00 | 0.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |
| M15 | 60 | hour | 144.00 | 15.00 | 13.00 | 0.01 | 1.00 |
| M15 | 60 | slot | 576.00 | 42.00 | 34.00 | 0.01 | 1.00 |
| M15 | 60 | wd_hour | 720.00 | 36.00 | 24.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 216.00 | 27.00 | 23.00 | 0.01 | 1.00 |
| M15 | 240 | slot | 864.00 | 85.00 | 75.00 | 0.01 | 1.00 |
| M15 | 240 | wd_hour | 1,062.00 | 70.00 | 39.00 | 0.00 | 0.00 |
| M5 | 60 | 15m | 480.00 | 45.00 | 34.00 | 0.01 | 1.00 |
| M5 | 60 | hour | 120.00 | 16.00 | 10.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 1,440.00 | 120.00 | 85.00 | 0.01 | 1.00 |
| M5 | 60 | wd_hour | 600.00 | 28.00 | 20.00 | 0.00 | 0.00 |
| M5 | 240 | 15m | 768.00 | 87.00 | 76.00 | 0.00 | 0.00 |
| M5 | 240 | hour | 192.00 | 21.00 | 20.00 | 0.00 | 0.00 |
| M5 | 240 | slot | 2,304.00 | 243.00 | 208.00 | 0.00 | 0.00 |
| M5 | 240 | wd_hour | 944.00 | 61.00 | 33.00 | 0.01 | 1.00 |


Horários validados (descoberta + validação):

| arquivo | clock | direction | ks | n_dias | sobe_antes | cai_antes | t_desc | t_val | fwer |
|---|---|---|---|---|---|---|---|---|---|
| slot_M1_W60 | 23:39 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 75.89 | 37.36 | 27.28 | True |
| slot_M15_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150,200,300 | 563 | 0.98 | 54.44 | 33.88 | 31.02 | True |
| slot_M1_W60 | 23:43 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 71.82 | 31.76 | 22.62 | True |
| slot_M1_W60 | 23:44 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.91 | 71.82 | 31.76 | 15.76 | True |
| slot_M1_W60 | 23:41 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.91 | 71.82 | 31.76 | 17.02 | True |
| slot_M1_W60 | 23:40 | SELL (cai k antes) | 25,50,100,150,200 | 111 | 0.90 | 72.07 | 31.40 | 16.10 | True |
| slot_M1_W60 | 23:51 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 70.91 | 30.63 | 27.03 | True |
| slot_M1_W60 | 23:52 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 71.82 | 30.63 | 27.03 | True |
| slot_M1_W60 | 23:53 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 72.73 | 30.63 | 27.03 | True |
| slot_M1_W60 | 23:50 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 73.64 | 30.63 | 38.00 | True |
| slot_M1_W60 | 23:54 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 73.64 | 30.63 | 27.03 | True |
| 15m_M1_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.91 | 80.91 | 29.92 | 35.53 | True |
| slot_M15_W240 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 563 | 4.97 | 76.02 | 29.63 | 23.22 | True |
| slot_M1_W60 | 23:38 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.00 | 74.11 | 28.40 | 27.28 | True |
| slot_M1_W60 | 23:58 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 71.82 | 27.98 | 38.00 | True |
| slot_M1_W60 | 23:56 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 73.64 | 27.98 | 38.00 | True |
| slot_M1_W60 | 23:46 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 74.55 | 27.98 | 38.00 | True |
| slot_M1_W60 | 23:55 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 74.55 | 27.98 | 31.91 | True |
| slot_M1_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 74.55 | 27.98 | 38.00 | True |
| slot_M1_W60 | 23:47 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.00 | 74.55 | 27.98 | 38.00 | True |
| 15m_M1_W60 | 23:30 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.89 | 81.25 | 27.57 | 21.68 | True |
| slot_M1_W240 | 23:55 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.89 | 76.79 | 27.52 | 30.35 | True |
| slot_M1_W240 | 23:56 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 1.79 | 75.89 | 27.52 | 18.39 | True |
| 15m_M1_W240 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 2.68 | 82.14 | 26.13 | 17.86 | True |
| slot_M1_W60 | 23:42 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.91 | 71.82 | 25.46 | 17.02 | True |
| slot_M1_W240 | 23:58 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 1.79 | 74.11 | 25.29 | 18.39 | True |
| hour_M15_W240 | 23h | SELL (cai k antes) | 25,50,100,150,200 | 563 | 4.62 | 68.03 | 25.25 | 25.45 | True |
| slot_M5_W60 | 23:55 | SELL (cai k antes) | 25,50,100,150,200 | 292 | 1.37 | 71.58 | 24.77 | 36.98 | True |
| slot_M1_W60 | 23:36 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 0.89 | 75.00 | 24.57 | 15.87 | True |
| 15m_M5_W60 | 23:45 | SELL (cai k antes) | 25,50,100,150,200 | 292 | 2.06 | 76.03 | 24.14 | 38.90 | True |
| slot_M1_W60 | 23:57 | SELL (cai k antes) | 25,50,100,150,200 | 110 | 0.91 | 74.55 | 23.57 | 38.00 | True |
| 15m_M5_W60 | 23:30 | SELL (cai k antes) | 25,50,100,150,200 | 292 | 2.40 | 77.06 | 23.50 | 25.98 | True |
| slot_M1_W240 | 23:52 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 2.68 | 75.00 | 23.44 | 16.07 | True |
| slot_M1_W240 | 23:50 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 1.79 | 77.68 | 23.44 | 18.39 | True |
| slot_M1_W240 | 23:51 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 2.68 | 76.79 | 23.44 | 16.07 | True |
| slot_M1_W240 | 23:54 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 2.68 | 75.89 | 23.44 | 17.26 | True |
| slot_M1_W240 | 23:53 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 2.68 | 75.89 | 23.44 | 16.07 | True |
| slot_M1_W240 | 23:57 | SELL (cai k antes) | 25,50,100,150,200 | 112 | 1.79 | 76.79 | 23.44 | 18.39 | True |
| slot_M15_W60 | 23:30 | SELL (cai k antes) | 25,50,100,150,200,300 | 563 | 1.15 | 53.73 | 23.24 | 25.53 | True |
| slot_M5_W60 | 23:40 | SELL (cai k antes) | 25,50,100,150,200 | 292 | 2.40 | 71.58 | 23.07 | 26.85 | True |


## G. Operação executável por horário (alvo k, limite k / 2k / sem limite; custo e swap incluídos)

| tf | W | clock | ev_tests | ev_validated | ev_validated_bh | ev_clocks | ev_placebo_mean | ev_placebo_max |
|---|---|---|---|---|---|---|---|---|
| M1 | 60 | 15m | 2,880.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | hour | 720.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 60 | slot | 43,170.00 | 15.00 | 15.00 | 1.00 | 0.00 | 0.00 |
| M1 | 60 | wd_hour |  |  |  |  |  |  |
| M1 | 240 | 15m | 4,608.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | hour | 1,152.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M1 | 240 | slot | 69,072.00 | 29.00 | 16.00 | 6.00 | 6.50 | 19.00 |
| M1 | 240 | wd_hour |  |  |  |  |  |  |
| M15 | 60 | hour | 864.00 | 15.00 | 15.00 | 1.00 | 0.00 | 0.00 |
| M15 | 60 | slot | 3,456.00 | 18.00 | 18.00 | 1.00 | 0.00 | 0.00 |
| M15 | 60 | wd_hour | 4,320.00 | 13.00 | 11.00 | 1.00 | 0.00 | 0.00 |
| M15 | 240 | hour | 1,248.00 | 1.00 | 0.00 | 1.00 | 0.00 | 0.00 |
| M15 | 240 | slot | 4,992.00 | 29.00 | 28.00 | 4.00 | 0.00 | 0.00 |
| M15 | 240 | wd_hour | 6,136.00 | 3.00 | 1.00 | 3.00 | 0.05 | 1.00 |
| M5 | 60 | 15m | 2,880.00 | 15.00 | 15.00 | 1.00 | 0.00 | 0.00 |
| M5 | 60 | hour | 720.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 60 | slot | 8,640.00 | 15.00 | 15.00 | 1.00 | 0.00 | 0.00 |
| M5 | 60 | wd_hour | 3,600.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| M5 | 240 | 15m | 4,608.00 | 46.00 | 46.00 | 9.00 | 0.00 | 0.00 |
| M5 | 240 | hour | 1,152.00 | 6.00 | 6.00 | 2.00 | 0.00 | 0.00 |
| M5 | 240 | slot | 13,824.00 | 92.00 | 88.00 | 27.00 | 0.10 | 1.00 |
| M5 | 240 | wd_hour | 5,664.00 | 13.00 | 9.00 | 7.00 | 0.00 | 0.00 |


Combinações validadas (descoberta t≥3 e validação t≥1,645, média líquida > 0 nos dois períodos, com perdas na validação). `confirmado_em` = outro timeframe com o mesmo lado a ±10 min; `rolagem` = entrada ou janela tocando 23:00–01:15 do servidor (cotações de bid distorcidas pelo spread da rolagem):


| tf | W | clock | side | k_pts | adverse | n_days | win_pct | ev_pts | ev_disc | t_disc | ev_val | t_val | years_pos | bh_disc | confirmed_in | rolagem |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M15 | 60 | 01:00 | BUY | 50 | sem | 709 | 63.9 | 31.2 | 27.8 | 15.9 | 36.3 | 23.8 | 3/3 | True | M1,M5 | True |
| M15 | 240 | 01:00 | BUY | 50 | sem | 709 | 84.2 | 31.7 | 27.4 | 9.0 | 38.3 | 17.6 | 3/3 | True | M1,M5 | True |
| M5 | 60 | 01:00 | BUY | 50 | sem | 368 | 74.7 | 36.8 | 40.4 | 24.1 | 31.2 | 12.5 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 01:00 | BUY | 50 | sem | 368 | 88.9 | 36.8 | 37.6 | 11.7 | 35.5 | 10.9 | 2/2 | True | M1,M15 | True |
| M5 | 240 | 23:35 | SELL | 25 | sem | 292 | 99.0 | 10.8 | 12.6 | 10.2 | 8.1 | 6.2 | 2/2 | True | M15 | True |
| M1 | 240 | 12:38 | SELL | 25 | sem | 139 | 94.2 | 17.5 | 16.7 | 3.9 | 18.8 | 5.9 | 1/1 | True | nan | False |
| M1 | 60 | 01:00 | BUY | 50 | sem | 139 | 58.3 | 28.2 | 31.4 | 9.0 | 23.5 | 5.5 | 1/1 | True | M15,M5 | True |
| M15 | 240 | 23:30 | SELL | 25 | sem | 563 | 94.3 | 6.8 | 5.9 | 4.5 | 8.2 | 5.2 | 3/3 | True | M5 | True |
| M15 | 240 | 23:15 | SELL | 25 | sem | 563 | 92.9 | 6.9 | 6.1 | 3.4 | 8.0 | 4.9 | 2/3 | True | M5 | True |
| M5 | 240 | 23:40 | SELL | 25 | sem | 292 | 98.3 | 9.1 | 10.7 | 7.6 | 6.6 | 4.7 | 2/2 | True | M15 | True |
| M5 | 240 | 22:20 | SELL | 50 | sem | 292 | 80.8 | 18.5 | 20.0 | 5.7 | 16.3 | 4.3 | 2/2 | True | nan | True |
| M5 | 240 | 22:30 | SELL | 50 | sem | 292 | 82.5 | 21.8 | 25.6 | 9.4 | 16.2 | 4.2 | 2/2 | True | nan | True |
| M5 | 240 | 23:25 | SELL | 50 | sem | 292 | 85.6 | 17.3 | 19.0 | 3.9 | 14.8 | 3.9 | 2/2 | True | M15 | True |
| M5 | 240 | 23:20 | SELL | 50 | sem | 292 | 86.6 | 20.2 | 23.9 | 8.3 | 14.8 | 3.9 | 2/2 | True | M15 | True |
| M5 | 240 | 22:25 | SELL | 50 | sem | 292 | 79.5 | 17.1 | 18.7 | 4.6 | 14.8 | 3.8 | 2/2 | True | nan | True |
| M1 | 240 | 01:00 | BUY | 50 | sem | 139 | 82.0 | 32.6 | 37.4 | 10.1 | 25.6 | 3.6 | 1/1 | True | M15,M5 | True |
| M5 | 240 | 23:30 | SELL | 50 | sem | 292 | 86.6 | 18.3 | 21.4 | 4.8 | 13.7 | 3.6 | 2/2 | True | M15 | True |
| M5 | 240 | 22:55 | SELL | 50 | sem | 292 | 82.5 | 21.0 | 26.2 | 10.8 | 13.1 | 3.6 | 2/2 | True | nan | True |
| M5 | 240 | 23:50 | SELL | 50 | sem | 292 | 84.9 | 17.1 | 19.2 | 6.6 | 13.8 | 3.6 | 2/2 | True | M15 | True |
| M15 | 240 | 23:45 | SELL | 50 | sem | 563 | 77.8 | 9.6 | 8.0 | 3.0 | 12.0 | 3.4 | 2/3 | False | M5 | True |
| M1 | 240 | 04:20 | BUY | 25 | sem | 139 | 87.0 | 13.0 | 11.5 | 3.0 | 15.3 | 3.4 | 1/1 | False | nan | False |
| M5 | 240 | 23:00 | SELL | 50 | sem | 292 | 85.3 | 22.8 | 29.4 | 14.2 | 12.9 | 3.3 | 2/2 | True | nan | True |
| M5 | 240 | 22:45 | SELL | 50 | sem | 292 | 80.1 | 19.1 | 23.4 | 8.5 | 12.6 | 3.1 | 2/2 | True | nan | True |
| M5 | 240 | 22:15 | SELL | 50 | sem | 292 | 79.1 | 16.2 | 18.6 | 4.8 | 12.8 | 3.0 | 2/2 | True | nan | True |
| M5 | 240 | 23:55 | SELL | 25 | sem | 292 | 96.9 | 6.3 | 7.7 | 5.1 | 4.2 | 2.8 | 2/2 | True | M15 | True |
| M5 | 240 | 22:50 | SELL | 50 | sem | 292 | 80.8 | 20.4 | 26.6 | 11.1 | 11.1 | 2.7 | 2/2 | True | nan | True |
| M5 | 240 | 23:45 | SELL | 50 | sem | 292 | 84.9 | 15.7 | 18.8 | 5.0 | 11.0 | 2.7 | 2/2 | True | M15 | True |
| M5 | 240 | 23:10 | SELL | 100 | sem | 292 | 55.1 | 24.8 | 30.1 | 4.6 | 16.9 | 2.6 | 2/2 | True | M15 | True |
| M5 | 240 | 22:35 | SELL | 50 | sem | 292 | 79.8 | 19.3 | 25.1 | 9.4 | 10.7 | 2.6 | 2/2 | True | nan | True |
| M5 | 240 | 23:15 | SELL | 100 | sem | 292 | 56.5 | 26.6 | 33.4 | 5.2 | 16.4 | 2.6 | 2/2 | True | M15 | True |
| M5 | 240 | 23:05 | SELL | 100 | sem | 292 | 52.7 | 23.5 | 29.0 | 4.6 | 15.3 | 2.4 | 2/2 | True | M15 | True |
| M5 | 240 | 22:10 | SELL | 50 | sem | 292 | 78.8 | 15.0 | 18.4 | 4.8 | 9.9 | 2.1 | 2/2 | True | nan | True |
| M1 | 240 | 04:22 | BUY | 25 | sem | 139 | 85.6 | 11.5 | 11.9 | 3.1 | 11.0 | 2.0 | 1/1 | False | nan | False |
| M5 | 240 | 21:35 | SELL | 50 | sem | 292 | 78.1 | 13.2 | 14.9 | 3.0 | 10.7 | 2.0 | 2/2 | False | nan | True |
| M5 | 240 | 22:00 | SELL | 50 | sem | 292 | 78.4 | 16.1 | 20.0 | 5.4 | 10.4 | 2.0 | 2/2 | True | nan | True |
| M5 | 240 | 21:55 | SELL | 50 | sem | 292 | 78.8 | 14.7 | 17.9 | 4.4 | 9.9 | 1.8 | 2/2 | True | nan | True |
| M1 | 240 | 04:23 | BUY | 25 | sem | 139 | 84.2 | 11.1 | 11.8 | 3.3 | 9.9 | 1.8 | 1/1 | False | nan | False |
| M1 | 240 | 16:26 | SELL | 25 | sem | 139 | 92.1 | 13.9 | 15.5 | 3.2 | 11.6 | 1.8 | 1/1 | False | nan | False |
| M5 | 240 | 22:05 | SELL | 50 | sem | 292 | 78.8 | 16.1 | 21.1 | 5.8 | 8.5 | 1.8 | 2/2 | True | nan | True |
| M5 | 240 | 22:40 | SELL | 50 | sem | 292 | 80.1 | 17.4 | 23.8 | 8.7 | 7.7 | 1.7 | 2/2 | True | nan | True |


## D. Padrões estruturais (condição × hora/sessão, além do efeito do relógio)

| tf | W | k_tested | tests | validated | race | ev_buy | ev_sell | placebo_mean | placebo_max |
|---|---|---|---|---|---|---|---|---|---|
| M15 | 60 | 50,100 | 25806 | 22 | 22 | 0 | 0 | 4.00 | 7 |
| M15 | 240 | 100,150 | 25680 | 22 | 21 | 0 | 1 | 6.38 | 33 |
| M5 | 60 | 50,100 | 25158 | 26 | 26 | 0 | 0 | 9.38 | 26 |
| M5 | 240 | 100,150 | 25044 | 33 | 32 | 0 | 1 | 7.75 | 18 |


`D_estruturais_M15_W240.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 100 | race | dopen=Q1(bem abaixo) & hora=00h | 107 | 39 | 0.46 | 6.03 | 0.49 | 6.11 | 0.79 |
| 150 | race | weekday=SEX & hora=21h | 142 | 85 | 0.24 | 5.85 | 0.28 | 5.29 | 0.02 |
| 150 | race | tickvol=normal & weekday=SEX & Tarde(20-24) | 218 | 57 | 0.25 | 5.32 | 0.20 | 3.40 | -0.01 |
| 150 | race | streak=1 alta & weekday=SEX & Tarde(20-24) | 185 | 77 | 0.27 | 5.24 | 0.23 | 4.27 | 0.00 |
| 150 | EV_SELL_Ak | weekday=SEX & hora=21h | 142 | 85 | 44.90 | 5.11 | 38.74 | 4.06 | 0.62 |
| 150 | race | spread=normal & weekday=SEX & Tarde(20-24) | 711 | 85 | 0.21 | 5.02 | 0.22 | 4.51 | 0.00 |
| 100 | race | ret4=Q1(caiu+) & hora=00h | 1408 | 324 | 0.18 | 4.79 | 0.28 | 7.74 | 0.55 |
| 150 | race | extreme=normal & weekday=SEX & Tarde(20-24) | 682 | 84 | 0.20 | 4.79 | 0.22 | 4.69 | 0.01 |
| 100 | race | brk=rompeu_min_fechou_fora & hora=00h | 289 | 138 | 0.29 | 4.60 | 0.25 | 3.07 | 0.51 |
| 150 | race | weekday=SEX & hora=20h | 572 | 85 | 0.20 | 4.50 | 0.20 | 4.12 | -0.00 |
| 150 | race | brk=dentro & weekday=SEX & Tarde(20-24) | 620 | 85 | 0.19 | 4.39 | 0.22 | 4.53 | 0.00 |
| 150 | race | prevday=dia_ant_alta & weekday=SEX & Tarde(20-24) | 370 | 44 | 0.23 | 4.32 | 0.25 | 3.40 | 0.03 |
| 150 | race | streak=1 baixa & weekday=SEX & Tarde(20-24) | 178 | 76 | 0.25 | 4.28 | 0.21 | 3.88 | 0.00 |
| 150 | race | streak=2 altas & weekday=SEX & Tarde(20-24) | 81 | 47 | 0.24 | 4.27 | 0.28 | 3.99 | 0.06 |
| 150 | race | prev1=alta & weekday=SEX & Tarde(20-24) | 277 | 79 | 0.23 | 4.26 | 0.21 | 4.28 | -0.01 |
| 100 | race | brk=rompeu_min_fechou_fora & tickvol=alto & Tarde(20-24) | 173 | 70 | 0.36 | 4.12 | 0.35 | 3.01 | -0.09 |
| 150 | race | dopen=Q1(bem abaixo) & hora=00h | 107 | 39 | 0.34 | 4.11 | 0.32 | 3.32 | 0.52 |
| 100 | race | prev1=forte_baixa & hora=00h | 650 | 260 | 0.18 | 4.05 | 0.25 | 5.42 | 0.48 |
| 150 | race | ret4=Q2 & weekday=SEX & Tarde(20-24) | 162 | 56 | 0.25 | 4.02 | 0.20 | 2.80 | -0.02 |
| 150 | race | compress=comprimido & weekday=SEX & Tarde(20-24) | 442 | 75 | 0.20 | 3.97 | 0.26 | 4.54 | 0.03 |


`D_estruturais_M15_W60.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 50 | race | dopen=Q1(bem abaixo) & hora=00h | 104 | 39 | 0.53 | 7.82 | 0.57 | 7.43 | 0.84 |
| 100 | race | dopen=Q1(bem abaixo) & hora=00h | 104 | 39 | 0.47 | 6.23 | 0.59 | 6.86 | 0.76 |
| 100 | race | brk=rompeu_min_fechou_fora & hora=00h | 289 | 138 | 0.27 | 5.76 | 0.26 | 4.04 | 0.35 |
| 50 | race | ret4=Q1(caiu+) & hora=00h | 1416 | 325 | 0.18 | 5.74 | 0.14 | 3.97 | 0.34 |
| 50 | race | pdpos=abaixo_PDL & hora=00h | 194 | 63 | 0.46 | 5.23 | 0.34 | 3.77 | 0.42 |
| 50 | race | brk=rompeu_min_fechou_fora & hora=00h | 289 | 138 | 0.32 | 5.22 | 0.15 | 1.94 | 0.32 |
| 100 | race | ret4=Q1(caiu+) & hora=00h | 1416 | 325 | 0.14 | 5.19 | 0.18 | 5.97 | 0.30 |
| 100 | race | prev1=forte_baixa & hora=00h | 650 | 260 | 0.15 | 4.72 | 0.20 | 5.32 | 0.26 |
| 100 | race | ret4=Q1(caiu+) & compress=expandido & Asia(00-09) | 2664 | 370 | 0.09 | 4.67 | 0.09 | 3.99 | 0.16 |
| 100 | race | dopen=Q2 & brk=rompeu_min_fechou_fora & Asia(00-09) | 385 | 144 | 0.19 | 4.67 | 0.12 | 2.45 | 0.15 |
| 100 | race | pdpos=abaixo_PDL & hora=00h | 194 | 63 | 0.37 | 4.61 | 0.32 | 4.16 | 0.38 |
| 100 | race | weekday=SEG & hora=00h | 568 | 85 | 0.25 | 4.58 | 0.42 | 6.33 | 0.49 |
| 50 | race | weekday=SEG & hora=00h | 568 | 85 | 0.22 | 4.51 | 0.14 | 2.53 | 0.26 |
| 100 | race | prevday=dia_ant_alta & weekday=SEG & Asia(00-09) | 2910 | 47 | 0.05 | 4.23 | 0.06 | 3.59 | 0.07 |
| 50 | race | ret4=Q1(caiu+) & dopen=Q2 & Asia(00-09) | 2013 | 329 | 0.11 | 4.07 | 0.13 | 4.06 | 0.24 |
| 50 | race | ret4=Q1(caiu+) & compress=expandido & Asia(00-09) | 2664 | 370 | 0.10 | 3.95 | 0.10 | 3.36 | 0.22 |
| 100 | race | tickvol=baixo & weekday=SEG & Asia(00-09) | 1377 | 83 | 0.06 | 3.94 | 0.10 | 3.03 | 0.13 |
| 50 | race | ret4=Q3 & hora=00h | 401 | 194 | -0.19 | -3.94 | -0.34 | -5.55 | -0.40 |
| 100 | race | weekday=TER & hora=00h | 572 | 86 | -0.11 | -3.93 | -0.07 | -1.95 | -0.00 |
| 50 | race | prev1=forte_baixa & hora=00h | 650 | 260 | 0.15 | 3.84 | 0.16 | 3.74 | 0.28 |


`D_estruturais_M5_W240.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 150 | race | compress=expandido & extreme=extremo_alta & Tarde(20-24) | 226 | 32 | -0.37 | -5.62 | -0.25 | -2.18 | -0.60 |
| 100 | race | dopen=Q1(bem abaixo) & hora=00h | 295 | 52 | 0.38 | 4.94 | 0.20 | 2.13 | 0.65 |
| 100 | race | streak=2 baixas & weekday=SEX & Tarde(20-24) | 123 | 42 | 0.46 | 4.65 | 0.29 | 2.99 | 0.02 |
| 150 | race | weekday=SEX & hora=21h | 224 | 45 | 0.33 | 4.63 | 0.31 | 4.86 | -0.01 |
| 150 | race | tickvol=normal & weekday=SEX & Tarde(20-24) | 383 | 37 | 0.26 | 4.52 | 0.24 | 3.42 | -0.01 |
| 150 | race | extreme=extremo_alta & spread=normal & Tarde(20-24) | 359 | 49 | -0.32 | -4.49 | -0.24 | -2.33 | -0.59 |
| 100 | race | prev1=baixa & weekday=SEX & Tarde(20-24) | 325 | 45 | 0.37 | 4.14 | 0.30 | 3.40 | 0.03 |
| 100 | race | spread=normal & weekday=SEX & Tarde(20-24) | 1097 | 45 | 0.34 | 4.03 | 0.29 | 3.51 | 0.02 |
| 100 | race | pdpos=acima_PDH & tickvol=normal & Tarde(20-24) | 1374 | 56 | -0.20 | -4.01 | -0.13 | -1.89 | -0.63 |
| 100 | race | extreme=normal & weekday=SEX & Tarde(20-24) | 1060 | 45 | 0.34 | 3.97 | 0.27 | 3.27 | 0.01 |
| 150 | race | ret4=Q5(subiu+) & extreme=extremo_alta & Tarde(20-24) | 212 | 38 | -0.30 | -3.96 | -0.26 | -2.34 | -0.60 |
| 150 | race | prev1=forte_baixa & weekday=SEX & Tarde(20-24) | 192 | 44 | 0.31 | 3.96 | 0.22 | 3.67 | -0.03 |
| 150 | race | prev1=baixa & weekday=SEX & Tarde(20-24) | 325 | 45 | 0.27 | 3.95 | 0.25 | 3.41 | -0.01 |
| 150 | race | ret4=Q5(subiu+) & weekday=QUI & Tarde(20-24) | 667 | 43 | -0.23 | -3.93 | -0.24 | -3.15 | -0.60 |
| 150 | race | streak=2 baixas & weekday=SEX & Tarde(20-24) | 123 | 42 | 0.31 | 3.88 | 0.24 | 3.07 | -0.02 |
| 150 | race | prev1=forte_alta & hora=00h | 736 | 208 | -0.15 | -3.87 | -0.13 | -2.70 | 0.16 |
| 100 | race | weekday=SEX & hora=20h | 900 | 45 | 0.34 | 3.85 | 0.29 | 3.63 | 0.04 |
| 100 | race | brk=rompeu_max_fechou_fora & tickvol=baixo & Tarde(20-24) | 212 | 63 | -0.22 | -3.82 | -0.23 | -2.59 | -0.61 |
| 100 | race | ret4=Q1(caiu+) & hora=00h | 1607 | 219 | 0.15 | 3.77 | 0.09 | 1.89 | 0.43 |
| 150 | race | ret4=Q5(subiu+) & hora=00h | 564 | 146 | -0.21 | -3.76 | -0.17 | -2.72 | 0.15 |


`D_estruturais_M5_W60.csv` — validados:

| k_pts | outcome | cond | n_entries | days_disc | excess_disc | t_disc | excess_val | t_val | raw_val |
|---|---|---|---|---|---|---|---|---|---|
| 50 | race | dopen=Q1(bem abaixo) & hora=00h | 284 | 52 | 0.63 | 12.98 | 0.51 | 5.72 | 0.74 |
| 50 | race | extreme=extremo_baixa & hora=00h | 374 | 78 | 0.51 | 6.80 | 0.52 | 4.90 | 0.72 |
| 50 | race | prev1=forte_baixa & hora=00h | 885 | 213 | 0.22 | 6.01 | 0.20 | 4.13 | 0.29 |
| 100 | race | dopen=Q1(bem abaixo) & hora=00h | 284 | 52 | 0.49 | 5.99 | 0.27 | 3.16 | 0.52 |
| 50 | race | dopen=Q3 & hora=00h | 855 | 120 | -0.40 | -5.96 | -0.19 | -1.81 | -0.07 |
| 50 | race | prev1=baixa & extreme=extremo_baixa & Asia(00-09) | 294 | 80 | 0.38 | 5.80 | 0.23 | 2.83 | 0.29 |
| 100 | race | ret4=Q1(caiu+) & hora=00h | 1610 | 219 | 0.15 | 5.48 | 0.07 | 1.92 | 0.21 |
| 50 | race | extreme=extremo_baixa & prevday=dia_ant_alta & Asia(00-09) | 640 | 82 | 0.28 | 5.35 | 0.17 | 1.79 | 0.26 |
| 50 | race | extreme=extremo_baixa & spread=normal & Asia(00-09) | 947 | 141 | 0.25 | 5.32 | 0.16 | 1.94 | 0.23 |
| 50 | race | compress=expandido & extreme=extremo_baixa & Asia(00-09) | 857 | 128 | 0.28 | 5.17 | 0.20 | 2.12 | 0.27 |
| 50 | race | streak=2 baixas & extreme=extremo_baixa & Asia(00-09) | 165 | 75 | 0.35 | 5.10 | 0.24 | 2.15 | 0.30 |
| 50 | race | brk=dentro & extreme=extremo_baixa & Asia(00-09) | 500 | 96 | 0.31 | 5.10 | 0.30 | 3.65 | 0.42 |
| 50 | race | ret4=Q1(caiu+) & hora=00h | 1610 | 219 | 0.18 | 4.81 | 0.21 | 4.58 | 0.26 |
| 50 | race | extreme=extremo_baixa & weekday=SEG & Asia(00-09) | 343 | 39 | 0.41 | 4.80 | 0.32 | 2.76 | 0.39 |
| 100 | race | brk=rompeu_max_fechou_fora & hora=23h | 167 | 63 | -0.19 | -4.69 | -0.12 | -1.99 | -0.65 |
| 100 | race | extreme=extremo_baixa & hora=00h | 374 | 78 | 0.38 | 4.58 | 0.39 | 3.66 | 0.63 |
| 50 | race | brk=rompeu_min_fechou_fora & hora=00h | 408 | 177 | 0.26 | 4.57 | 0.18 | 2.18 | 0.23 |
| 50 | race | streak=3+ baixas & hora=00h | 345 | 124 | 0.25 | 3.96 | 0.21 | 2.56 | 0.25 |
| 50 | race | streak=2 baixas & hora=00h | 523 | 197 | 0.20 | 3.94 | 0.20 | 3.44 | 0.29 |
| 100 | race | weekday=SEG & hora=00h | 886 | 45 | 0.30 | 3.93 | 0.24 | 2.38 | 0.42 |


## F. Distância × tempo e devolução

Das entradas que chegaram a +k (M15, janela 240 min), quantas terminaram a janela no prejuízo (o alvo foi tocado e devolvido):

| k_pts | side | hits | ended_negative_pct | ended_below_half_k_pct |
|---|---|---|---|---|
| 25 | BUY | 52938 | 40.0 | 45.1 |
| 25 | SELL | 54036 | 43.0 | 48.1 |
| 50 | BUY | 42364 | 31.0 | 39.8 |
| 50 | SELL | 44070 | 34.3 | 43.9 |
| 100 | BUY | 25801 | 18.6 | 30.5 |
| 100 | SELL | 27703 | 21.3 | 35.8 |
| 150 | BUY | 15601 | 11.6 | 24.0 |
| 150 | SELL | 16999 | 13.6 | 28.4 |
| 200 | BUY | 9339 | 7.7 | 19.4 |
| 200 | SELL | 10693 | 9.0 | 23.0 |
| 300 | BUY | 3810 | 4.8 | 14.0 |
| 300 | SELL | 4814 | 5.2 | 17.3 |
| 400 | BUY | 1790 | 3.9 | 11.3 |
| 400 | SELL | 2260 | 4.7 | 15.0 |
| 500 | BUY | 970 | 3.8 | 10.9 |
| 500 | SELL | 1149 | 3.3 | 12.8 |
| 600 | BUY | 513 | 3.3 | 7.8 |
| 600 | SELL | 661 | 1.7 | 10.7 |


## I. Outras regularidades

Hora do servidor em que se formou a máxima / mínima do dia (% dos dias, M15):

| hora | pct_dias_max_do_dia | pct_dias_min_do_dia |
|---|---|---|
| 0 | 3.9 | 35.0 |
| 1 | 6.0 | 1.7 |
| 2 | 3.0 | 0.3 |
| 3 | 3.9 | 1.4 |
| 4 | 2.2 | 1.7 |
| 5 | 2.1 | 1.0 |
| 6 | 0.7 | 0.3 |
| 7 | 1.7 | 0.4 |
| 8 | 2.0 | 0.8 |
| 9 | 4.5 | 4.1 |
| 10 | 5.6 | 2.4 |
| 11 | 4.1 | 2.7 |
| 12 | 3.1 | 1.7 |
| 13 | 2.4 | 2.0 |
| 14 | 3.1 | 1.8 |
| 15 | 7.0 | 6.8 |
| 16 | 5.8 | 4.5 |
| 17 | 8.3 | 7.6 |
| 18 | 6.6 | 3.5 |
| 19 | 3.7 | 3.5 |
| 20 | 3.4 | 3.1 |
| 21 | 4.8 | 3.4 |
| 22 | 5.2 | 3.9 |
| 23 | 6.9 | 6.5 |


Continuidade entre sessões (mesmo sinal do movimento; 50% = sem relação):

| de | para | periodo | dias | mesmo_sinal_pct | z | corr |
|---|---|---|---|---|---|---|
| Asia(01-09) | Londres(09-15) | descoberta | 426 | 52.35 | 0.97 | 0.10 |
| Asia(01-09) | Londres(09-15) | validacao | 282 | 45.74 | -1.43 | -0.06 |
| Londres(09-15) | NY(15-20) | descoberta | 425 | 47.06 | -1.21 | 0.10 |
| Londres(09-15) | NY(15-20) | validacao | 284 | 52.47 | 0.83 | 0.07 |
| Asia(01-09) | NY(15-20) | descoberta | 425 | 51.53 | 0.63 | -0.02 |
| Asia(01-09) | NY(15-20) | validacao | 283 | 52.30 | 0.77 | 0.04 |
| NY(15-20) | Tarde(20-24) | descoberta | 423 | 51.77 | 0.73 | 0.07 |
| NY(15-20) | Tarde(20-24) | validacao | 282 | 51.77 | 0.59 | 0.09 |
| Dia anterior | Dia | descoberta | 425 | 50.12 | 0.05 | -0.06 |
| Dia anterior | Dia | validacao | 285 | 52.63 | 0.89 | -0.05 |


Gap de segunda-feira (abertura da semana vs fechamento de sexta) fechado no mesmo dia, comparado com a chance de o preço andar a mesma distância nos outros dias:

| symbol | segundas | gap_mediano_pts | gap_fechou_pct | base_outros_dias_pct | gaps_grandes | gap_grande_fechou_pct | base_gaps_grandes_pct | gap_alta_pct |
|---|---|---|---|---|---|---|---|---|
| USDCHF | 140 | 121.0 | 90.7 | 76.1 | 70 | 84.3 | 61.7 | 18.6 |
