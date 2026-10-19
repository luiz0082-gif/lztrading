# DXY — padrões intraday: alvo ou saída às 23:30 (hora do servidor)

Dados: M15 de 2024-09-10 a 2026-10-16 (543 dias; descoberta até 2025-12-15, validação depois). Entrada na abertura da vela M15 do horário; sai no **alvo** (+100/200/300/500 pontos) ou às **23:30** do servidor (fechamento da vela 23:15). **Sem stop.** Custo: spread medido nos ticks (compra paga na entrada, venda na saída). Comissão e slippage não incluídos.

ATR M15 mediano = 50 pts; alvos testados: [10, 25, 50, 100, 300] pts

**Como ler o risco sem stop.** `pct_alvo` = % dos dias em que o alvo foi atingido antes das 23:30. `ganho_dia_alvo` = resultado líquido médio nesses dias (≈ alvo − custo). `perda_media_sem_alvo` = resultado médio nos dias em que o alvo NÃO foi atingido, calculado no conjunto inteiro de dias daquele lado/alvo (amostra grande da cauda). `pct_necessario_p_empatar` = % de acerto necessário para a conta empatar com essa perda média. `pct_alvo_min95` = limite inferior (95%) da taxa de acerto do padrão. `ev_estresse_pts` = pct_alvo_min95 × ganho + (1−pct_alvo_min95) × perda_media_sem_alvo: expectativa em pontos por operação **supondo o pior plausível para a taxa de acerto**. `mae_medio/p90` = quanto o preço andou CONTRA você antes de sair (média e pior 10% dos dias). Um padrão só é listado se `ev_estresse_pts` > 0 **e** a média realmente obtida (`media_real_pts`) for > 0 na descoberta e na validação, e a taxa de acerto for significativamente maior que a média dos horários.

## A. Horários puros (só o relógio)

Padrões que passaram: **0**; placebo: média 0.0, máximo 0. Não se distingue do acaso.

**Nenhum horário puro passou.**


## B. Horário + condição (variáveis conhecidas ANTES da abertura da vela)

Hipóteses testadas: **80,590**; passaram no BH na descoberta: **1,887**; confirmadas na validação: **1,671**; placebo: BH média 12.8 (máx 22), confirmadas média 4.0 (máx 9).

Famílias distintas que passam (hit rate acima da média dos horários na validação e `ev_estresse` > 0 nas duas metades do tempo): **51** (BH na descoberta: 16).

### Famílias (exclui domingo/gap/sexta), ordenadas por expectativa estressada

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | z_val | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | mtf_D1=RANGE & month=4 | 917 | 61.5 | 60.5 | 18.7 | 58.3 | 270.0 | -129.1 | 32.3 | 103.6 | 86.6 | -1,227.0 | 173.9 | 482.4 | 292.5 | 16.2 | nao | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=4 & news_min_since_last_high=Q3 | 392 | 62.8 | 56.7 | 18.7 | 57.9 | 270.0 | -129.1 | 32.3 | 101.9 | 91.7 | -1,393.0 | 191.4 | 419.8 | 435.0 | 9.2 | nao | 2/2 | 2/2 | 1 |
| VENDA | 300 | session=ASIA & month=4 | 1,339 | 59.1 | 54.0 | 18.7 | 56.5 | 270.0 | -129.1 | 32.3 | 96.4 | 53.8 | -1,608.0 | 217.0 | 482.6 | 360.0 | 14.4 | sim | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=4 & dom_w=d08_14 | 835 | 59.3 | 58.8 | 18.7 | 55.9 | 270.0 | -129.1 | 32.3 | 94.1 | 93.7 | -1,058.0 | 189.3 | 551.0 | 240.0 | 13.9 | nao | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=4 & news_min_to_next_high=Q3 | 490 | 56.7 | 48.0 | 18.7 | 52.3 | 270.0 | -129.1 | 32.3 | 79.7 | 35.8 | -1,608.0 | 231.5 | 442.3 | 330.0 | 6.6 | nao | 2/2 | 2/2 | 1 |
| COMPRA | 300 | mtf_W1=BREAK_UP & atr_ratio_prev=Q1 | 1,138 | 51.3 | 42.0 | 18.5 | 48.4 | 270.0 | -116.9 | 30.2 | 70.4 | 63.2 | -875.0 | 186.9 | 446.5 | 525.0 | 9.5 | sim | 3/3 | 4/6 | 1 |
| VENDA | 300 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 406 | 53.7 | 52.5 | 18.7 | 48.8 | 270.0 | -129.1 | 32.3 | 65.8 | 61.2 | -1,608.0 | 222.3 | 541.5 | 360.0 | 8.8 | nao | 2/3 | 9/13 | 1 |
| COMPRA | 300 | news_min_since_last_high=Q3 & atr_ratio_prev=Q4 | 413 | 51.3 | 48.9 | 18.5 | 46.5 | 270.0 | -116.9 | 30.2 | 63.1 | 37.7 | -1,662.0 | 240.2 | 566.4 | 510.0 | 10.5 | nao | 3/3 | 14/25 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & atr_ratio_prev=Q1 | 1,711 | 47.1 | 45.8 | 18.5 | 44.8 | 270.0 | -116.9 | 30.2 | 56.3 | 52.2 | -875.0 | 211.1 | 620.0 | 585.0 | 17.7 | sim | 2/3 | 18/26 | 1 |
| VENDA | 300 | day_of_week=TUESDAY & month=3 | 737 | 49.4 | 45.0 | 18.7 | 45.8 | 270.0 | -129.1 | 32.3 | 53.7 | 95.4 | -608.0 | 191.7 | 393.8 | 285.0 | 6.2 | nao | 2/2 | 2/2 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & session=ASIA | 3,310 | 45.0 | 39.8 | 18.5 | 43.3 | 270.0 | -116.9 | 30.2 | 50.8 | 29.8 | -1,478.0 | 250.8 | 613.0 | 615.0 | 20.7 | sim | 2/3 | 17/26 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=3 | 432 | 47.9 | 44.9 | 18.5 | 43.2 | 270.0 | -116.9 | 30.2 | 50.4 | 21.9 | -1,433.0 | 269.9 | 662.0 | 765.0 | 9.2 | nao | 2/3 | 15/26 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=4 | 432 | 47.7 | 43.2 | 18.5 | 43.0 | 270.0 | -116.9 | 30.2 | 49.6 | 27.6 | -1,458.0 | 257.9 | 640.0 | 720.0 | 8.6 | nao | 2/3 | 16/26 | 1 |
| COMPRA | 300 | dom_w=d15_21 & news_min_to_next_high=Q3 | 1,030 | 45.9 | 45.2 | 18.5 | 42.9 | 270.0 | -116.9 | 30.2 | 49.1 | 12.6 | -1,040.0 | 269.7 | 645.0 | 600.0 | 14.7 | sim | 2/3 | 12/26 | 1 |
| VENDA | 300 | session=ASIA & mtf_D1=BREAK_DOWN | 991 | 47.4 | 51.7 | 18.7 | 44.3 | 270.0 | -129.1 | 32.3 | 47.8 | 46.9 | -1,608.0 | 230.8 | 568.0 | 397.5 | 11.5 | nao | 2/3 | 9/13 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 1,710 | 44.9 | 41.1 | 18.5 | 42.6 | 270.0 | -116.9 | 30.2 | 47.8 | 21.3 | -1,475.0 | 253.1 | 602.1 | 555.0 | 15.9 | sim | 2/3 | 16/26 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=5 | 431 | 46.9 | 41.7 | 18.5 | 42.2 | 270.0 | -116.9 | 30.2 | 46.4 | 27.8 | -1,478.0 | 259.7 | 645.0 | 690.0 | 8.1 | nao | 2/3 | 16/26 | 1 |
| COMPRA | 300 | session=ASIA & month=10 | 1,845 | 43.8 | 42.9 | 18.5 | 41.5 | 270.0 | -116.9 | 30.2 | 43.9 | 55.1 | -508.0 | 168.0 | 360.0 | 555.0 | 9.0 | sim | 3/3 | 3/3 | 1 |
| COMPRA | 300 | month=5 & news_min_since_last_high=Q3 | 431 | 45.7 | 42.2 | 18.5 | 41.1 | 270.0 | -116.9 | 30.2 | 42.0 | 44.2 | -860.0 | 250.2 | 683.0 | 615.0 | 9.2 | nao | 2/2 | 2/2 | 1 |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=4 | 440 | 45.5 | 38.8 | 18.5 | 40.9 | 270.0 | -116.9 | 30.2 | 41.2 | 30.1 | -810.0 | 235.0 | 567.1 | 675.0 | 6.9 | nao | 3/3 | 18/26 | 1 |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q3 | 277 | 48.4 | 41.0 | 18.7 | 42.6 | 270.0 | -129.1 | 32.3 | 40.7 | 30.3 | -1,240.0 | 212.1 | 462.0 | 645.0 | 6.3 | nao | 3/3 | 15/24 | 1 |
| COMPRA | 300 | month=10 & atr_ratio_prev=Q1 | 973 | 43.7 | 55.1 | 18.5 | 40.6 | 270.0 | -116.9 | 30.2 | 40.2 | 68.3 | -475.0 | 142.7 | 316.6 | 555.0 | 11.9 | nao | 2/3 | 2/3 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=8 | 430 | 45.1 | 42.9 | 18.5 | 40.5 | 270.0 | -116.9 | 30.2 | 39.7 | 32.4 | -1,278.0 | 244.3 | 597.3 | 480.0 | 8.5 | nao | 2/3 | 17/26 | 1 |
| COMPRA | 300 | dom_w=d15_21 & news_min_since_last_high=Q3 | 926 | 43.6 | 39.1 | 18.5 | 40.5 | 270.0 | -116.9 | 30.2 | 39.7 | 20.9 | -1,040.0 | 243.0 | 497.5 | 630.0 | 10.4 | sim | 1/3 | 16/26 | 1 |
| COMPRA | 300 | hour_srv=5 & atr_ratio_prev=Q1 | 682 | 44.1 | 42.5 | 18.5 | 40.5 | 270.0 | -116.9 | 30.2 | 39.6 | 24.2 | -1,732.0 | 223.5 | 536.8 | 645.0 | 10.1 | nao | 2/3 | 19/26 | 1 |
| VENDA | 300 | mtf_H4=RANGE & news_min_since_last_high=Q4 | 1,111 | 43.9 | 40.1 | 18.7 | 41.0 | 270.0 | -129.1 | 32.3 | 34.7 | 16.3 | -752.0 | 238.4 | 525.0 | 420.0 | 11.8 | sim | 1/3 | 15/25 | 1 |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=9 | 431 | 43.4 | 37.1 | 18.5 | 38.8 | 270.0 | -116.9 | 30.2 | 33.2 | 43.6 | -1,243.0 | 228.4 | 560.0 | 435.0 | 6.5 | nao | 2/3 | 19/26 | 1 |
| COMPRA | 300 | hour_srv=4 & pcum10=Q5 | 365 | 43.0 | 40.8 | 18.5 | 38.0 | 270.0 | -116.9 | 30.2 | 30.3 | 22.0 | -855.0 | 223.6 | 530.4 | 660.0 | 6.7 | nao | 3/3 | 18/26 | 1 |
| VENDA | 100 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 406 | 87.2 | 94.1 | 52.7 | 83.6 | 70.0 | -176.4 | 71.6 | 29.6 | 29.6 | -1,608.0 | 141.9 | 444.0 | 165.0 | 8.8 | nao | 3/3 | 10/13 | 1 |
| VENDA | 100 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q2 | 398 | 86.4 | 88.7 | 52.7 | 82.7 | 70.0 | -176.4 | 71.6 | 27.4 | 20.3 | -1,443.0 | 149.9 | 360.9 | 120.0 | 7.5 | nao | 2/3 | 9/13 | 1 |
| COMPRA | 300 | dom_w=d15_21 & atr_ratio_prev=Q1 | 2,075 | 39.2 | 37.4 | 18.5 | 37.1 | 270.0 | -116.9 | 30.2 | 26.7 | 23.0 | -1,322.0 | 220.2 | 550.0 | 645.0 | 12.3 | sim | 2/3 | 16/25 | 1 |
| VENDA | 300 | news_min_to_next_high=Q3 & atr_ratio_prev=Q3 | 869 | 42.0 | 41.0 | 18.7 | 38.8 | 270.0 | -129.1 | 32.3 | 25.6 | 19.3 | -1,245.0 | 238.4 | 519.4 | 510.0 | 10.7 | nao | 2/3 | 13/26 | 1 |
| COMPRA | 100 | dom_w=d15_21 & news_min_since_last_high=Q4 | 1,038 | 83.6 | 79.4 | 56.8 | 81.2 | 70.0 | -180.0 | 72.0 | 23.1 | 17.9 | -1,130.0 | 158.6 | 352.3 | 202.5 | 10.1 | sim | 2/3 | 21/26 | 1 |
| VENDA | 100 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | 371 | 84.9 | 92.2 | 52.7 | 80.9 | 70.0 | -176.4 | 71.6 | 23.0 | 18.0 | -1,608.0 | 157.2 | 365.0 | 180.0 | 7.5 | nao | 2/2 | 8/11 | 1 |
| COMPRA | 300 | dom_w=d15_21 & news_min_to_next_high=Q1 | 956 | 39.0 | 35.2 | 18.5 | 36.0 | 270.0 | -116.9 | 30.2 | 22.3 | 16.8 | -1,000.0 | 227.1 | 513.0 | 180.0 | 8.0 | nao | 1/3 | 14/26 | 1 |
| VENDA | 100 | session=ASIA & mtf_D1=BREAK_DOWN | 991 | 83.0 | 96.7 | 52.7 | 80.6 | 70.0 | -176.4 | 71.6 | 22.2 | 19.4 | -1,608.0 | 150.2 | 413.0 | 165.0 | 12.6 | nao | 3/3 | 10/13 | 1 |
| COMPRA | 300 | mtf_W1=RANGE & news_min_since_last_high=Q3 | 1,306 | 38.0 | 35.1 | 18.5 | 35.4 | 270.0 | -116.9 | 30.2 | 20.0 | 3.8 | -1,338.0 | 252.6 | 555.0 | 585.0 | 13.2 | nao | 1/3 | 6/12 | 1 |
| COMPRA | 100 | month=3 & atr_ratio_prev=Q1 | 860 | 81.6 | 81.5 | 56.8 | 78.9 | 70.0 | -180.0 | 72.0 | 17.2 | 9.0 | -840.0 | 148.6 | 445.0 | 180.0 | 4.3 | nao | 2/2 | 2/2 | 1 |
| COMPRA | 100 | day_of_week=WEDNESDAY & hour_srv=11 | 432 | 81.9 | 80.7 | 56.8 | 78.0 | 70.0 | -180.0 | 72.0 | 15.1 | 9.7 | -680.0 | 150.4 | 389.8 | 195.0 | 6.5 | nao | 2/3 | 17/26 | 1 |
| COMPRA | 100 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | 371 | 81.4 | 87.8 | 56.8 | 77.1 | 70.0 | -180.0 | 72.0 | 12.8 | 25.9 | -1,470.0 | 183.4 | 400.0 | 180.0 | 6.5 | nao | 2/2 | 9/11 | 1 |


### Estabilidade

| lado | alvo_pts | condicao | primeiro | ultimo | pct_alvo_h1 | pct_alvo_h2 | por_ano | dias_semana |
|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | mtf_D1=RANGE & month=4 | 2025-04-02 | 2026-04-30 | 58.6 | 62.4 | 2025:+26; 2026:+137 | seg=63%(180) ter=42%(163) qua=67%(246) qui=67%(246) sex=62%(82) |
| VENDA | 300 | month=4 & news_min_since_last_high=Q3 | 2025-04-01 | 2026-04-30 | 78.5 | 35.2 | 2025:+128; 2026:+62 | ter=42%(33) qua=45%(80) qui=66%(184) sex=78%(95) |
| VENDA | 300 | session=ASIA & month=4 | 2025-04-01 | 2026-04-30 | 72.1 | 35.9 | 2025:+37; 2026:+71 | seg=78%(256) ter=34%(286) qua=52%(318) qui=62%(288) sex=79%(191) |
| VENDA | 300 | month=4 & dom_w=d08_14 | 2025-04-08 | 2026-04-14 | 65.4 | 52.2 | 2025:+63; 2026:+125 | seg=62%(180) ter=42%(163) qua=52%(164) qui=77%(164) sex=63%(164) |
| VENDA | 300 | month=4 & news_min_to_next_high=Q3 | 2025-04-01 | 2026-04-30 | 82.8 | 13.3 | 2025:+44; 2026:+29 | seg=100%(17) ter=35%(100) qua=54%(169) qui=63%(153) sex=76%(51) |
| COMPRA | 300 | mtf_W1=BREAK_UP & atr_ratio_prev=Q1 | 2024-10-07 | 2026-10-14 | 23.7 | 60.4 | 2024:+81; 2025:+104; 2026:+10 | seg=57%(221) ter=35%(154) qua=69%(285) qui=40%(244) sex=47%(234) |
| VENDA | 300 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 2024-09-17 | 2026-08-20 | 74.6 | 30.5 | 2024:-294; 2025:+83; 2026:+60 | seg=82%(34) ter=80%(84) qua=31%(118) qui=28%(68) sex=66%(102) |
| COMPRA | 300 | news_min_since_last_high=Q3 & atr_ratio_prev=Q4 | 2024-09-13 | 2026-10-16 | 54.0 | 43.7 | 2024:+42; 2025:+25; 2026:+53 | seg=86%(22) ter=38%(37) qua=59%(41) qui=54%(160) sex=44%(153) |
| COMPRA | 300 | day_of_week=WEDNESDAY & atr_ratio_prev=Q1 | 2024-09-18 | 2026-10-14 | 49.0 | 42.6 | 2024:+117; 2025:-34; 2026:+131 | qua=47%(1711) |
| VENDA | 300 | day_of_week=TUESDAY & month=3 | 2025-03-04 | 2026-03-31 | 34.8 | 55.1 | 2025:+134; 2026:+65 | ter=49%(737) |
| COMPRA | 300 | day_of_week=WEDNESDAY & session=ASIA | 2024-09-11 | 2026-10-14 | 46.4 | 33.3 | 2024:+144; 2025:-20; 2026:+52 | qua=45%(3310) |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=3 | 2024-09-11 | 2026-10-14 | 50.0 | 39.8 | 2024:+126; 2025:-25; 2026:+44 | qua=48%(432) |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=4 | 2024-09-11 | 2026-10-14 | 50.0 | 36.4 | 2024:+142; 2025:-17; 2026:+42 | qua=48%(432) |
| COMPRA | 300 | dom_w=d15_21 & news_min_to_next_high=Q3 | 2024-09-17 | 2026-10-15 | 40.6 | 49.8 | 2024:+58; 2025:-6; 2026:+15 | seg=0%(17) ter=50%(117) qua=52%(356) qui=52%(423) sex=8%(117) |
| VENDA | 300 | session=ASIA & mtf_D1=BREAK_DOWN | 2024-09-16 | 2026-08-20 | 74.3 | 29.2 | 2024:-61; 2025:+52; 2026:+63 | seg=49%(191) ter=70%(215) qua=32%(215) qui=27%(116) sex=50%(254) |
| COMPRA | 300 | day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 2024-09-11 | 2026-10-14 | 48.3 | 33.9 | 2024:+137; 2025:-39; 2026:+54 | qua=45%(1710) |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=5 | 2024-09-11 | 2026-10-14 | 49.4 | 34.1 | 2024:+132; 2025:-15; 2026:+44 | qua=47%(431) |
| COMPRA | 300 | session=ASIA & month=10 | 2024-10-01 | 2026-10-16 | 41.1 | 44.7 | 2024:+85; 2025:+49; 2026:+11 | seg=51%(317) ter=36%(350) qua=57%(383) qui=46%(414) sex=29%(381) |
| COMPRA | 300 | month=5 & news_min_since_last_high=Q3 | 2025-05-01 | 2026-05-29 | 35.5 | 48.9 | 2025:+10; 2026:+89 | seg=50%(24) ter=47%(30) qua=52%(98) qui=72%(135) sex=16%(144) |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=4 | 2024-09-11 | 2026-10-15 | 41.2 | 36.2 | 2024:+27; 2025:+13; 2026:+61 | seg=44%(128) ter=33%(72) qua=64%(92) qui=44%(84) sex=38%(64) |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q3 | 2024-09-13 | 2026-10-16 | 37.7 | 44.3 | 2024:+114; 2025:+10; 2026:+23 | seg=41%(66) ter=49%(43) qua=38%(47) qui=54%(65) sex=59%(56) |
| COMPRA | 300 | month=10 & atr_ratio_prev=Q1 | 2024-10-01 | 2026-10-14 | 41.5 | 68.6 | 2024:+117; 2025:-4; 2026:+82 | seg=51%(186) ter=31%(154) qua=61%(218) qui=36%(190) sex=36%(225) |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=8 | 2024-09-11 | 2026-10-14 | 50.6 | 35.2 | 2024:+137; 2025:-28; 2026:+71 | qua=45%(430) |
| COMPRA | 300 | dom_w=d15_21 & news_min_since_last_high=Q3 | 2024-09-17 | 2026-10-16 | 38.4 | 39.8 | 2024:-18; 2025:+58; 2026:-9 | ter=0%(18) qua=37%(108) qui=51%(466) sex=38%(332) |
| COMPRA | 300 | hour_srv=5 & atr_ratio_prev=Q1 | 2024-09-16 | 2026-10-14 | 37.1 | 47.9 | 2024:+87; 2025:-46; 2026:+63 | seg=35%(124) ter=34%(151) qua=54%(151) qui=48%(128) sex=49%(128) |
| VENDA | 300 | mtf_H4=RANGE & news_min_since_last_high=Q4 | 2024-09-12 | 2026-10-14 | 41.4 | 38.8 | 2024:-69; 2025:+70; 2026:-2 | ter=25%(132) qua=56%(334) qui=42%(342) sex=41%(303) |
| COMPRA | 300 | day_of_week=WEDNESDAY & hour_srv=9 | 2024-09-11 | 2026-10-14 | 47.1 | 27.3 | 2024:+150; 2025:-12; 2026:+75 | qua=43%(431) |
| COMPRA | 300 | hour_srv=4 & pcum10=Q5 | 2024-09-12 | 2026-10-07 | 38.4 | 43.2 | 2024:+11; 2025:+18; 2026:+30 | seg=46%(52) ter=39%(106) qua=54%(63) qui=48%(65) sex=34%(79) |
| VENDA | 100 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 2024-09-17 | 2026-08-20 | 94.9 | 93.2 | 2024:+70; 2025:+24; 2026:+39 | seg=100%(34) ter=100%(84) qua=69%(118) qui=100%(68) sex=85%(102) |
| VENDA | 100 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q2 | 2024-09-17 | 2026-08-20 | 91.2 | 86.2 | 2024:-188; 2025:+31; 2026:+24 | seg=97%(32) ter=82%(80) qua=86%(121) qui=73%(64) sex=95%(101) |
| COMPRA | 300 | dom_w=d15_21 & atr_ratio_prev=Q1 | 2024-09-16 | 2026-09-21 | 35.6 | 39.1 | 2024:+105; 2025:-28; 2026:+49 | seg=16%(514) ter=40%(431) qua=67%(483) qui=40%(299) sex=33%(348) |
| VENDA | 300 | news_min_to_next_high=Q3 & atr_ratio_prev=Q3 | 2024-09-24 | 2026-10-13 | 37.2 | 44.8 | 2024:-38; 2025:+18; 2026:+32 | seg=53%(70) ter=33%(128) qua=46%(267) qui=40%(279) sex=42%(125) |
| COMPRA | 100 | dom_w=d15_21 & news_min_since_last_high=Q4 | 2024-09-18 | 2026-10-16 | 74.4 | 84.3 | 2024:-11; 2025:+40; 2026:+2 | ter=83%(18) qua=94%(180) qui=89%(414) sex=74%(426) |
| VENDA | 100 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | 2025-02-21 | 2026-08-20 | 84.4 | 100.0 | 2025:+12; 2026:+35 | ter=100%(54) qua=75%(89) qui=77%(66) sex=88%(162) |
| COMPRA | 300 | dom_w=d15_21 & news_min_to_next_high=Q1 | 2024-09-17 | 2026-10-15 | 30.4 | 40.0 | 2024:+139; 2025:-17; 2026:-2 | seg=0%(11) ter=58%(77) qua=54%(410) qui=25%(375) sex=14%(83) |
| VENDA | 100 | session=ASIA & mtf_D1=BREAK_DOWN | 2024-09-16 | 2026-08-20 | 100.0 | 93.4 | 2024:+61; 2025:+6; 2026:+60 | seg=84%(191) ter=93%(215) qua=70%(215) qui=98%(116) sex=78%(254) |
| COMPRA | 300 | mtf_W1=RANGE & news_min_since_last_high=Q3 | 2024-11-06 | 2026-10-02 | 41.8 | 28.4 | 2024:-52; 2025:+44; 2026:-8 | ter=34%(114) qua=48%(292) qui=31%(533) sex=42%(365) |
| COMPRA | 100 | month=3 & atr_ratio_prev=Q1 | 2025-03-03 | 2026-03-31 | 75.8 | 87.2 | 2025:+1; 2026:+16 | seg=73%(186) ter=74%(158) qua=94%(183) qui=80%(146) sex=86%(187) |
| COMPRA | 100 | day_of_week=WEDNESDAY & hour_srv=11 | 2024-09-11 | 2026-10-14 | 79.5 | 81.8 | 2024:+31; 2025:-4; 2026:+19 | qua=82%(432) |
| COMPRA | 100 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | 2025-02-21 | 2026-08-20 | 88.9 | 86.7 | 2025:+26; 2026:+24 | ter=91%(54) qua=97%(89) qui=67%(66) sex=76%(162) |


### Abertura de semana / gap / sexta (execução menos confiável)

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | z_val | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | day_of_week=SUNDAY & mtf_D1=BEARISH | 254 | 61.8 | 46.5 | 18.7 | 55.7 | 270.0 | -129.1 | 32.3 | 93.2 | 58.9 | -768.0 | 203.5 | 513.0 | 630.0 | 7.0 | sim | 2/2 | 9/17 | 2 |
| VENDA | 100 | day_of_week=FRIDAY & news_min_to_next_high=Q3 | 1,012 | 84.4 | 82.4 | 52.7 | 82.0 | 70.0 | -176.4 | 71.6 | 25.7 | 6.7 | -1,608.0 | 133.8 | 336.8 | 180.0 | 11.7 | sim | 3/3 | 17/25 | 1 |
| VENDA | 300 | day_of_week=FRIDAY & news_min_since_last_high=Q3 | 1,547 | 41.0 | 39.9 | 18.7 | 38.6 | 270.0 | -129.1 | 32.3 | 25.1 | 13.9 | -1,393.0 | 219.6 | 488.8 | 570.0 | 13.7 | sim | 2/3 | 14/26 | 1 |
| VENDA | 100 | day_of_week=FRIDAY & news_min_to_next_high=Q2 | 967 | 83.9 | 84.8 | 52.7 | 81.4 | 70.0 | -176.4 | 71.6 | 24.2 | 13.9 | -1,443.0 | 145.2 | 330.8 | 180.0 | 12.3 | sim | 2/3 | 16/25 | 1 |
| VENDA | 100 | day_of_week=FRIDAY & hour_srv=11 | 428 | 79.2 | 80.2 | 52.7 | 75.1 | 70.0 | -176.4 | 71.6 | 8.7 | 9.9 | -877.0 | 147.7 | 320.9 | 240.0 | 7.3 | nao | 2/3 | 17/26 | 1 |


**Últimas 10 ocorrências das 12 primeiras (data/hora do servidor → líquido em pontos; * = bateu o alvo):**

- VENDA alvo 300 | mtf_D1=RANGE & month=4: 04-30 21:00 +42; 04-30 21:15 +30; 04-30 21:30 -10; 04-30 21:45 -60; 04-30 22:00 -53; 04-30 22:15 -93; 04-30 22:30 -45; 04-30 22:45 -63; 04-30 23:00 -20; 04-30 23:15 -18
- VENDA alvo 300 | month=4 & news_min_since_last_high=Q3: 04-30 08:30 +270*; 04-30 08:45 +270*; 04-30 09:00 +270*; 04-30 09:15 +270*; 04-30 09:30 +270*; 04-30 09:45 +270*; 04-30 10:00 +270*; 04-30 10:15 +270*; 04-30 10:30 +270*; 04-30 10:45 +270*
- VENDA alvo 300 | session=ASIA & month=4: 04-30 08:30 +270*; 04-30 08:45 +270*; 04-30 09:00 +270*; 04-30 09:15 +270*; 04-30 09:30 +270*; 04-30 09:45 +270*; 04-30 10:00 +270*; 04-30 10:15 +270*; 04-30 10:30 +270*; 04-30 10:45 +270*
- VENDA alvo 300 | month=4 & dom_w=d08_14: 04-14 21:00 -50; 04-14 21:15 -48; 04-14 21:30 -5; 04-14 21:45 +0; 04-14 22:00 -10; 04-14 22:15 -5; 04-14 22:30 -5; 04-14 22:45 +0; 04-14 23:00 +0; 04-14 23:15 -20
- VENDA alvo 300 | month=4 & news_min_to_next_high=Q3: 04-30 06:30 +270*; 04-30 06:45 +270*; 04-30 07:00 +270*; 04-30 07:15 +270*; 04-30 07:30 +270*; 04-30 07:45 +270*; 04-30 08:00 +270*; 04-30 08:15 +270*; 04-30 08:30 +270*; 04-30 08:45 +270*
- COMPRA alvo 300 | mtf_W1=BREAK_UP & atr_ratio_prev=Q1: 10-14 08:00 +270*; 10-14 08:15 +270*; 10-14 08:30 +270*; 10-14 08:45 +270*; 10-14 09:00 +270*; 10-14 09:15 +270*; 10-14 09:30 +270*; 10-14 09:45 +270*; 10-14 10:00 +270*; 10-14 10:15 +270*
- VENDA alvo 300 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3: 08-20 06:30 -97; 08-20 06:45 -102; 08-20 07:00 -117; 08-20 07:15 -125; 08-20 07:30 -102; 08-20 07:45 -85; 08-20 08:00 -62; 08-20 08:15 -67; 08-20 08:30 +270*; 08-20 08:45 +270*
- COMPRA alvo 300 | news_min_since_last_high=Q3 & atr_ratio_prev=Q4: 09-24 06:45 +145; 09-25 03:15 -315; 10-02 03:00 -115; 10-15 00:00 -507; 10-15 03:00 -212; 10-16 07:15 -158; 10-16 07:30 -113; 10-16 07:45 -120; 10-16 08:00 -123; 10-16 08:15 -153
- COMPRA alvo 300 | day_of_week=WEDNESDAY & atr_ratio_prev=Q1: 10-14 08:00 +270*; 10-14 08:15 +270*; 10-14 08:30 +270*; 10-14 08:45 +270*; 10-14 09:00 +270*; 10-14 09:15 +270*; 10-14 09:30 +270*; 10-14 09:45 +270*; 10-14 10:00 +270*; 10-14 10:15 +270*
- VENDA alvo 300 | day_of_week=TUESDAY & month=3: 03-31 21:00 +107; 03-31 21:15 +30; 03-31 21:30 +30; 03-31 21:45 +55; 03-31 22:00 +80; 03-31 22:15 +92; 03-31 22:30 +85; 03-31 22:45 +15; 03-31 23:00 -45; 03-31 23:15 -43
- COMPRA alvo 300 | day_of_week=WEDNESDAY & session=ASIA: 10-14 08:30 +270*; 10-14 08:45 +270*; 10-14 09:00 +270*; 10-14 09:15 +270*; 10-14 09:30 +270*; 10-14 09:45 +270*; 10-14 10:00 +270*; 10-14 10:15 +270*; 10-14 10:30 +270*; 10-14 10:45 +270*
- COMPRA alvo 300 | day_of_week=WEDNESDAY & hour_srv=3: 09-30 03:30 +32; 09-30 03:45 +35; 10-07 03:00 +270*; 10-07 03:15 +270*; 10-07 03:30 +270*; 10-07 03:45 +270*; 10-14 03:00 +270*; 10-14 03:15 +270*; 10-14 03:30 +270*; 10-14 03:45 +270*

_(tempo 54s)_
