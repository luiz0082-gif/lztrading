# AUDUSD — padrões intraday: alvo ou saída às 23:30 (hora do servidor)

Dados: M15 de 2024-01-22 a 2026-10-16 (712 dias; descoberta até 2025-09-11, validação depois). Entrada na abertura da vela M15 do horário; sai no **alvo** (+100/200/300/500 pontos) ou às **23:30** do servidor (fechamento da vela 23:15). **Sem stop.** Custo: spread medido nos ticks (compra paga na entrada, venda na saída). Comissão e slippage não incluídos.

ATR M15 mediano = 47 pts; alvos testados: [10, 25, 45, 95, 300] pts

**Como ler o risco sem stop.** `pct_alvo` = % dos dias em que o alvo foi atingido antes das 23:30. `ganho_dia_alvo` = resultado líquido médio nesses dias (≈ alvo − custo). `perda_media_sem_alvo` = resultado médio nos dias em que o alvo NÃO foi atingido, calculado no conjunto inteiro de dias daquele lado/alvo (amostra grande da cauda). `pct_necessario_p_empatar` = % de acerto necessário para a conta empatar com essa perda média. `pct_alvo_min95` = limite inferior (95%) da taxa de acerto do padrão. `ev_estresse_pts` = pct_alvo_min95 × ganho + (1−pct_alvo_min95) × perda_media_sem_alvo: expectativa em pontos por operação **supondo o pior plausível para a taxa de acerto**. `mae_medio/p90` = quanto o preço andou CONTRA você antes de sair (média e pior 10% dos dias). Um padrão só é listado se `ev_estresse_pts` > 0 **e** a média realmente obtida (`media_real_pts`) for > 0 na descoberta e na validação, e a taxa de acerto for significativamente maior que a média dos horários.

## A. Horários puros (só o relógio)

Padrões que passaram: **0**; placebo: média 0.0, máximo 0. Não se distingue do acaso.

**Nenhum horário puro passou.**


## B. Horário + condição (variáveis conhecidas ANTES da abertura da vela)

Hipóteses testadas: **97,320**; passaram no BH na descoberta: **3,646**; confirmadas na validação: **3,307**; placebo: BH média 576.5 (máx 1078), confirmadas média 34.7 (máx 133).

Famílias distintas que passam (hit rate acima da média dos horários na validação e `ev_estresse` > 0 nas duas metades do tempo): **267** (BH na descoberta: 144).

### Famílias (exclui domingo/gap/sexta), ordenadas por expectativa estressada

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | z_val | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | mtf_D1=BREAK_UP & month=5 | 282 | 59.6 | 48.9 | 21.2 | 53.8 | 286.3 | -99.9 | 25.9 | 107.7 | 194.8 | -229.8 | 95.7 | 225.9 | 540.0 | 6.8 | sim | 3/3 | 3/3 | 1 |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q3 | 817 | 52.1 | 59.8 | 19.5 | 48.7 | 286.2 | -93.1 | 24.5 | 91.7 | 50.4 | -662.7 | 209.2 | 521.2 | 600.0 | 13.3 | sim | 2/3 | 2/3 | 1 |
| VENDA | 300 | month=2 & news_min_to_next_high=Q4 | 757 | 52.0 | 62.3 | 21.2 | 48.5 | 286.3 | -99.9 | 25.9 | 87.3 | 49.8 | -1,063.8 | 211.3 | 457.0 | 765.0 | 9.4 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 300 | mtf_H1=BEARISH & month=4 | 1,685 | 47.7 | 46.3 | 19.5 | 45.3 | 280.0 | -93.1 | 25.0 | 76.1 | 70.9 | -2,824.0 | 188.4 | 421.6 | 435.0 | 7.0 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 300 | session=OFF_SESSION & mtf_D1=BREAK_DOWN | 303 | 50.5 | 45.5 | 19.5 | 44.9 | 275.6 | -93.1 | 25.3 | 72.4 | 52.1 | -473.9 | 209.2 | 439.4 | 705.0 | 7.6 | sim | 2/3 | 11/16 | 1 |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q2 | 791 | 46.4 | 52.5 | 19.5 | 42.9 | 286.3 | -93.1 | 24.5 | 69.8 | 61.3 | -726.7 | 172.2 | 436.0 | 390.0 | 10.2 | nao | 2/3 | 2/3 | 1 |
| VENDA | 300 | session=ASIA & news_min_since_last_high=Q2 | 609 | 47.8 | 53.1 | 21.2 | 43.8 | 286.3 | -99.9 | 25.9 | 69.4 | 33.3 | -1,143.8 | 247.4 | 556.8 | 585.0 | 12.5 | sim | 2/3 | 20/29 | 1 |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q4 | 745 | 48.2 | 43.9 | 19.5 | 44.6 | 270.1 | -93.1 | 25.6 | 68.9 | 50.6 | -908.9 | 190.1 | 469.6 | 825.0 | 6.5 | sim | 3/3 | 3/3 | 1 |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=1 | 704 | 46.6 | 44.6 | 19.5 | 42.9 | 282.3 | -93.1 | 24.8 | 68.1 | 24.7 | -3,018.7 | 262.9 | 580.4 | 757.5 | 8.2 | sim | 2/3 | 18/28 | 1 |
| VENDA | 300 | month=3 & news_min_since_last_high=Q3 | 672 | 47.2 | 72.8 | 21.2 | 43.4 | 286.3 | -99.9 | 25.9 | 67.8 | 47.2 | -705.8 | 223.2 | 524.8 | 495.0 | 9.6 | nao | 2/3 | 2/3 | 1 |
| COMPRA | 300 | session=OFF_SESSION & mtf_D1=RANGE | 1,405 | 45.9 | 45.1 | 19.5 | 43.3 | 277.8 | -93.1 | 25.1 | 67.6 | 19.6 | -3,018.7 | 261.8 | 584.0 | 765.0 | 11.9 | sim | 2/3 | 17/28 | 1 |
| COMPRA | 300 | mtf_M5=BEARISH & hour_srv=1 | 645 | 46.4 | 51.4 | 19.5 | 42.5 | 279.8 | -93.1 | 25.0 | 65.5 | 48.4 | -1,125.7 | 222.2 | 506.2 | 645.0 | 11.0 | sim | 2/3 | 26/34 | 1 |
| COMPRA | 300 | mtf_D1=RANGE & news_min_to_next_high=Q4 | 1,980 | 44.7 | 51.3 | 19.5 | 42.6 | 273.0 | -93.1 | 25.4 | 62.7 | 22.5 | -3,055.7 | 238.3 | 546.1 | 765.0 | 15.1 | sim | 2/3 | 16/26 | 1 |
| VENDA | 300 | month=3 & atr_ratio_prev=Q1 | 1,199 | 44.7 | 61.8 | 21.2 | 41.9 | 286.3 | -99.9 | 25.9 | 62.0 | 44.3 | -934.0 | 206.8 | 541.2 | 457.5 | 9.1 | nao | 2/3 | 2/3 | 1 |
| VENDA | 300 | day_of_week=THURSDAY & month=3 | 1,130 | 44.6 | 69.7 | 21.2 | 41.7 | 286.3 | -99.9 | 25.9 | 61.3 | 88.1 | -872.8 | 150.8 | 358.1 | 322.5 | 11.5 | nao | 3/3 | 3/3 | 1 |
| VENDA | 300 | mtf_H4=BREAK_UP & news_min_since_last_high=Q4 | 479 | 46.1 | 46.3 | 21.2 | 41.7 | 286.2 | -99.9 | 25.9 | 61.2 | 93.5 | -801.8 | 167.9 | 366.0 | 495.0 | 9.6 | sim | 3/3 | 18/24 | 1 |
| COMPRA | 300 | month=5 & news_min_since_last_high=Q4 | 818 | 44.0 | 44.0 | 19.5 | 40.6 | 286.3 | -93.1 | 24.5 | 61.1 | 6.5 | -692.8 | 216.1 | 440.2 | 510.0 | 6.7 | nao | 2/3 | 2/3 | 1 |
| COMPRA | 300 | session=OFF_SESSION & atr_ratio_prev=Q5 | 500 | 46.4 | 41.0 | 19.5 | 42.1 | 272.7 | -93.1 | 25.5 | 60.8 | 53.3 | -991.9 | 253.0 | 595.4 | 487.5 | 8.6 | sim | 2/3 | 17/28 | 1 |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=2 | 703 | 44.2 | 43.1 | 19.5 | 40.6 | 285.8 | -93.1 | 24.6 | 60.7 | 22.0 | -2,968.2 | 264.3 | 590.8 | 735.0 | 7.7 | sim | 2/3 | 17/28 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & month=5 | 1,570 | 42.9 | 55.7 | 19.5 | 40.5 | 282.4 | -93.1 | 24.8 | 59.0 | 69.2 | -713.7 | 155.4 | 402.1 | 420.0 | 13.9 | nao | 3/3 | 3/3 | 1 |
| VENDA | 300 | session=OFF_SESSION & month=10 | 463 | 45.6 | 38.9 | 21.2 | 41.1 | 286.3 | -99.9 | 25.9 | 58.8 | 65.1 | -349.8 | 187.9 | 356.6 | 855.0 | 6.8 | nao | 3/3 | 3/3 | 1 |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=3 | 703 | 43.2 | 39.2 | 19.5 | 39.6 | 286.1 | -93.1 | 24.6 | 57.2 | 23.1 | -3,022.0 | 253.7 | 556.4 | 645.0 | 6.3 | sim | 2/3 | 16/28 | 1 |
| COMPRA | 300 | session=ASIA & month=5 | 2,111 | 41.4 | 42.1 | 19.5 | 39.4 | 286.2 | -93.1 | 24.5 | 56.2 | 13.6 | -870.0 | 219.9 | 520.0 | 540.0 | 9.7 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 300 | mtf_M5=BEARISH & slot_srv=01:00 | 316 | 45.6 | 46.0 | 19.5 | 40.2 | 275.4 | -93.1 | 25.3 | 54.9 | 48.6 | -926.0 | 209.9 | 506.0 | 690.0 | 7.0 | nao | 3/3 | 24/32 | 1 |
| COMPRA | 300 | mtf_M15=BEARISH & hour_srv=1 | 1,120 | 41.4 | 37.6 | 19.5 | 38.6 | 281.4 | -93.1 | 24.9 | 51.4 | 21.6 | -2,998.0 | 245.8 | 527.1 | 675.0 | 9.9 | sim | 3/3 | 25/34 | 2 |
| COMPRA | 300 | session=OFF_SESSION & month=1 | 400 | 46.0 | 50.6 | 19.5 | 41.2 | 256.0 | -93.1 | 26.7 | 50.7 | 31.5 | -921.7 | 216.3 | 459.2 | 637.5 | 6.9 | nao | 3/3 | 3/3 | 1 |
| COMPRA | 300 | mtf_D1=RANGE & news_min_to_next_high=Q3 | 2,221 | 39.8 | 44.8 | 19.5 | 37.7 | 286.2 | -93.1 | 24.5 | 50.0 | 14.4 | -3,022.0 | 247.0 | 540.0 | 570.0 | 12.4 | sim | 2/3 | 15/26 | 1 |
| COMPRA | 300 | hour_srv=2 & pcum10=Q2 | 458 | 42.1 | 39.9 | 19.5 | 37.7 | 285.7 | -93.1 | 24.6 | 49.7 | 6.1 | -2,912.1 | 264.6 | 538.8 | 720.0 | 6.7 | nao | 2/3 | 20/34 | 1 |
| VENDA | 300 | mtf_H1=BREAK_UP & news_min_to_next_high=Q3 | 539 | 42.7 | 48.7 | 21.2 | 38.6 | 286.3 | -99.9 | 25.9 | 49.0 | 39.4 | -691.8 | 212.3 | 479.0 | 600.0 | 10.6 | nao | 3/3 | 21/31 | 1 |
| VENDA | 300 | mtf_H4=BREAK_UP & news_min_since_last_high=Q3 | 417 | 43.2 | 33.3 | 21.2 | 38.5 | 286.3 | -99.9 | 25.9 | 48.8 | 75.1 | -836.8 | 186.3 | 405.4 | 690.0 | 5.1 | sim | 2/3 | 13/20 | 1 |
| COMPRA | 300 | dom_w=d01_07 & news_min_to_next_high=Q3 | 2,525 | 39.0 | 34.0 | 19.5 | 37.2 | 286.2 | -93.1 | 24.5 | 47.9 | 9.2 | -3,022.0 | 257.0 | 556.6 | 532.5 | 10.5 | sim | 2/3 | 21/33 | 1 |
| COMPRA | 300 | session=OFF_SESSION & mtf_M15=BEARISH | 2,118 | 40.3 | 36.5 | 19.5 | 38.2 | 275.8 | -93.1 | 25.2 | 47.8 | 7.8 | -2,998.0 | 250.3 | 525.3 | 645.0 | 12.9 | sim | 2/3 | 20/34 | 2 |
| COMPRA | 300 | session=OFF_SESSION & mtf_H1=BEARISH | 2,347 | 40.1 | 33.9 | 19.5 | 38.2 | 276.0 | -93.1 | 25.2 | 47.8 | 13.3 | -1,206.7 | 237.6 | 531.4 | 675.0 | 10.7 | sim | 2/3 | 21/34 | 1 |
| VENDA | 300 | mtf_H1=BREAK_UP & news_min_since_last_high=Q3 | 369 | 43.1 | 36.5 | 21.2 | 38.1 | 286.3 | -99.9 | 25.9 | 47.4 | 45.0 | -691.8 | 225.9 | 539.4 | 615.0 | 4.9 | nao | 2/3 | 20/30 | 1 |
| COMPRA | 300 | hour_srv=1 & pcum10=Q2 | 529 | 41.6 | 37.8 | 19.5 | 37.5 | 281.8 | -93.1 | 24.8 | 47.3 | 28.7 | -940.0 | 233.1 | 491.6 | 675.0 | 6.5 | nao | 3/3 | 25/34 | 1 |
| VENDA | 300 | mtf_W1=BREAK_UP & news_min_to_next_high=Q3 | 623 | 41.9 | 42.7 | 21.2 | 38.1 | 286.3 | -99.9 | 25.9 | 47.2 | 50.3 | -992.8 | 191.9 | 375.0 | 645.0 | 10.8 | nao | 2/3 | 6/8 | 1 |
| COMPRA | 300 | mtf_M15=BEARISH & hour_srv=2 | 939 | 40.0 | 36.6 | 19.5 | 37.0 | 285.6 | -93.1 | 24.6 | 46.8 | 10.6 | -2,968.2 | 257.7 | 516.2 | 645.0 | 8.4 | sim | 2/3 | 20/34 | 2 |
| COMPRA | 300 | mtf_M30=BEARISH & hour_srv=1 | 1,192 | 39.9 | 36.1 | 19.5 | 37.2 | 281.5 | -93.1 | 24.9 | 46.2 | 7.8 | -3,018.7 | 258.7 | 569.9 | 727.5 | 9.2 | sim | 2/3 | 19/34 | 1 |
| COMPRA | 300 | structure_before=BEARISH & hour_srv=3 | 709 | 40.2 | 39.7 | 19.5 | 36.7 | 286.1 | -93.1 | 24.6 | 45.9 | 20.6 | -1,082.8 | 243.4 | 527.2 | 675.0 | 8.1 | nao | 2/3 | 22/34 | 2 |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=4 | 704 | 40.2 | 38.2 | 19.5 | 36.6 | 286.1 | -93.1 | 24.6 | 45.8 | 13.8 | -2,958.0 | 252.0 | 564.6 | 690.0 | 6.0 | sim | 2/3 | 15/28 | 1 |


### Estabilidade

| lado | alvo_pts | condicao | primeiro | ultimo | pct_alvo_h1 | pct_alvo_h2 | por_ano | dias_semana |
|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | mtf_D1=BREAK_UP & month=5 | 2024-05-16 | 2026-05-07 | 36.2 | 61.7 | 2024:+90; 2025:+271; 2026:+223 | qua=93%(94) qui=43%(188) |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q3 | 2024-05-01 | 2026-05-29 | 54.9 | 64.7 | 2024:+117; 2025:-97; 2026:+142 | seg=32%(38) ter=38%(152) qua=50%(190) qui=45%(266) sex=83%(171) |
| VENDA | 300 | month=2 & news_min_to_next_high=Q4 | 2024-02-01 | 2026-02-27 | 69.7 | 54.9 | 2024:+69; 2025:-7; 2026:+92 | seg=64%(76) ter=42%(129) qua=48%(180) qui=50%(217) sex=61%(155) |
| COMPRA | 300 | mtf_H1=BEARISH & month=4 | 2024-04-01 | 2026-04-30 | 71.8 | 21.0 | 2024:-18; 2025:+94; 2026:+120 | seg=67%(263) ter=30%(389) qua=51%(250) qui=73%(413) sex=23%(370) |
| COMPRA | 300 | session=OFF_SESSION & mtf_D1=BREAK_DOWN | 2024-02-06 | 2026-10-02 | 57.1 | 33.9 | 2024:-5; 2025:+230; 2026:+18 | seg=50%(64) ter=60%(40) qua=50%(48) qui=44%(95) sex=55%(56) |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q2 | 2024-05-01 | 2026-05-29 | 35.9 | 69.0 | 2024:+136; 2025:-73; 2026:+131 | seg=0%(36) ter=36%(149) qua=50%(182) qui=38%(263) sex=76%(161) |
| VENDA | 300 | session=ASIA & news_min_since_last_high=Q2 | 2024-02-01 | 2026-10-09 | 47.8 | 58.4 | 2024:-12; 2025:+93; 2026:+30 | seg=83%(36) ter=34%(44) qua=26%(102) qui=55%(297) sex=42%(130) |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q4 | 2024-05-01 | 2026-05-29 | 40.7 | 47.2 | 2024:+66; 2025:+5; 2026:+85 | seg=43%(53) ter=33%(139) qua=43%(216) qui=46%(204) sex=78%(133) |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=1 | 2024-02-21 | 2026-09-18 | 36.3 | 52.9 | 2024:-8; 2025:+36; 2026:+56 | seg=59%(152) ter=45%(136) qua=58%(120) qui=43%(148) sex=29%(148) |
| VENDA | 300 | month=3 & news_min_since_last_high=Q3 | 2024-03-01 | 2026-03-31 | 77.7 | 68.0 | 2024:-19; 2025:+28; 2026:+146 | ter=43%(90) qua=0%(113) qui=71%(239) sex=48%(227) |
| COMPRA | 300 | session=OFF_SESSION & mtf_D1=RANGE | 2024-02-21 | 2026-09-18 | 37.3 | 52.9 | 2024:-11; 2025:+29; 2026:+54 | seg=59%(304) ter=44%(272) qua=57%(239) qui=41%(296) sex=29%(294) |
| COMPRA | 300 | mtf_M5=BEARISH & hour_srv=1 | 2024-01-23 | 2026-10-14 | 53.2 | 49.5 | 2024:-5; 2025:+71; 2026:+89 | seg=47%(158) ter=44%(124) qua=44%(117) qui=52%(115) sex=45%(131) |
| COMPRA | 300 | mtf_D1=RANGE & news_min_to_next_high=Q4 | 2024-02-22 | 2026-09-17 | 46.6 | 55.9 | 2024:-20; 2025:+31; 2026:+92 | seg=47%(258) ter=46%(384) qua=51%(531) qui=42%(485) sex=35%(322) |
| VENDA | 300 | month=3 & atr_ratio_prev=Q1 | 2024-03-01 | 2026-03-31 | 55.7 | 67.8 | 2024:-2; 2025:+43; 2026:+80 | seg=14%(194) ter=33%(211) qua=39%(267) qui=87%(199) sex=49%(328) |
| VENDA | 300 | day_of_week=THURSDAY & month=3 | 2024-03-01 | 2026-03-27 | 73.4 | 66.0 | 2024:+48; 2025:+58; 2026:+158 | qui=45%(993) sex=44%(137) |
| VENDA | 300 | mtf_H4=BREAK_UP & news_min_since_last_high=Q4 | 2024-03-08 | 2026-10-14 | 19.3 | 73.4 | 2024:+86; 2025:+42; 2026:+189 | ter=13%(15) qua=57%(180) qui=49%(206) sex=13%(69) |
| COMPRA | 300 | month=5 & news_min_since_last_high=Q4 | 2024-05-01 | 2026-05-29 | 54.8 | 33.3 | 2024:+108; 2025:-96; 2026:+17 | seg=0%(42) ter=50%(42) qua=43%(189) qui=29%(231) sex=60%(314) |
| COMPRA | 300 | session=OFF_SESSION & atr_ratio_prev=Q5 | 2024-02-01 | 2026-10-12 | 49.7 | 32.3 | 2024:-68; 2025:+121; 2026:+52 | seg=37%(243) ter=46%(35) qua=67%(45) qui=55%(137) sex=50%(40) |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=2 | 2024-02-21 | 2026-09-18 | 33.3 | 52.9 | 2024:-8; 2025:+32; 2026:+54 | seg=57%(152) ter=46%(136) qua=55%(119) qui=38%(148) sex=28%(148) |
| COMPRA | 300 | mtf_H4=BEARISH & month=5 | 2024-05-01 | 2026-05-28 | 29.8 | 81.5 | 2024:+66; 2025:+46; 2026:+112 | seg=50%(253) ter=33%(158) qua=45%(314) qui=50%(472) sex=31%(373) |
| VENDA | 300 | session=OFF_SESSION & month=10 | 2024-10-01 | 2026-10-16 | 45.7 | 32.1 | 2024:+118; 2025:+44; 2026:+4 | seg=32%(80) ter=55%(87) qua=41%(96) qui=63%(104) sex=33%(96) |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=3 | 2024-02-21 | 2026-09-18 | 25.5 | 52.9 | 2024:-2; 2025:+25; 2026:+66 | seg=52%(152) ter=48%(136) qua=57%(120) qui=36%(147) sex=26%(148) |
| COMPRA | 300 | session=ASIA & month=5 | 2024-05-01 | 2026-05-29 | 38.7 | 45.5 | 2024:+69; 2025:-65; 2026:+36 | seg=36%(384) ter=26%(384) qua=40%(416) qui=44%(448) sex=57%(479) |
| COMPRA | 300 | mtf_M5=BEARISH & slot_srv=01:00 | 2024-01-29 | 2026-10-14 | 41.9 | 50.0 | 2024:+30; 2025:+48; 2026:+69 | seg=54%(72) ter=41%(59) qua=44%(55) qui=44%(64) sex=44%(66) |
| COMPRA | 300 | mtf_M15=BEARISH & hour_srv=1 | 2024-01-23 | 2026-10-14 | 43.0 | 32.2 | 2024:+9; 2025:+30; 2026:+23 | seg=47%(252) ter=32%(220) qua=47%(189) qui=49%(214) sex=33%(245) |
| COMPRA | 300 | session=OFF_SESSION & month=1 | 2024-01-23 | 2026-01-30 | 32.1 | 69.0 | 2024:+62; 2025:+1; 2026:+53 | seg=61%(72) ter=45%(80) qua=40%(80) qui=50%(80) sex=36%(88) |
| COMPRA | 300 | mtf_D1=RANGE & news_min_to_next_high=Q3 | 2024-02-22 | 2026-09-17 | 28.4 | 61.3 | 2024:-17; 2025:+14; 2026:+94 | seg=52%(256) ter=39%(418) qua=52%(532) qui=36%(616) sex=22%(399) |
| COMPRA | 300 | hour_srv=2 & pcum10=Q2 | 2024-01-25 | 2026-10-16 | 48.9 | 30.9 | 2024:+7; 2025:+23; 2026:-13 | seg=40%(67) ter=44%(109) qua=38%(93) qui=57%(90) sex=32%(99) |
| VENDA | 300 | mtf_H1=BREAK_UP & news_min_to_next_high=Q3 | 2024-02-02 | 2026-10-14 | 30.5 | 66.9 | 2024:+9; 2025:+19; 2026:+113 | seg=73%(22) ter=10%(69) qua=42%(195) qui=56%(180) sex=36%(73) |
| VENDA | 300 | mtf_H4=BREAK_UP & news_min_since_last_high=Q3 | 2024-03-21 | 2026-08-27 | 29.2 | 37.4 | 2024:+211; 2025:+75; 2026:-39 | seg=86%(22) ter=33%(42) qua=40%(78) qui=43%(202) sex=41%(73) |
| COMPRA | 300 | dom_w=d01_07 & news_min_to_next_high=Q3 | 2024-02-01 | 2026-10-07 | 29.8 | 38.2 | 2024:-9; 2025:+29; 2026:+7 | seg=42%(389) ter=38%(437) qua=50%(597) qui=35%(551) sex=30%(551) |
| COMPRA | 300 | session=OFF_SESSION & mtf_M15=BEARISH | 2024-01-23 | 2026-10-14 | 40.6 | 32.3 | 2024:-5; 2025:+8; 2026:+20 | seg=43%(472) ter=35%(424) qua=44%(358) qui=49%(417) sex=31%(447) |
| COMPRA | 300 | session=OFF_SESSION & mtf_H1=BEARISH | 2024-01-23 | 2026-10-16 | 28.2 | 39.6 | 2024:-7; 2025:+18; 2026:+36 | seg=45%(440) ter=33%(478) qua=37%(415) qui=44%(500) sex=41%(514) |
| VENDA | 300 | mtf_H1=BREAK_UP & news_min_since_last_high=Q3 | 2024-02-02 | 2026-10-14 | 34.9 | 38.1 | 2024:+90; 2025:+41; 2026:-10 | ter=24%(34) qua=34%(116) qui=51%(146) sex=49%(68) |
| COMPRA | 300 | hour_srv=1 & pcum10=Q2 | 2024-01-23 | 2026-10-14 | 55.0 | 20.7 | 2024:+27; 2025:+47; 2026:+15 | seg=38%(105) ter=38%(78) qua=45%(117) qui=50%(111) sex=35%(118) |
| VENDA | 300 | mtf_W1=BREAK_UP & news_min_to_next_high=Q3 | 2024-07-09 | 2026-05-14 | 28.3 | 56.9 | 2024:+92; 2025:+123; 2026:-27 | seg=15%(114) ter=22%(171) qua=49%(129) qui=80%(133) sex=50%(76) |
| COMPRA | 300 | mtf_M15=BEARISH & hour_srv=2 | 2024-01-25 | 2026-10-14 | 42.7 | 30.5 | 2024:+8; 2025:-2; 2026:+26 | seg=37%(199) ter=40%(219) qua=45%(157) qui=49%(188) sex=30%(176) |
| COMPRA | 300 | mtf_M30=BEARISH & hour_srv=1 | 2024-01-23 | 2026-10-13 | 38.3 | 34.0 | 2024:-2; 2025:+6; 2026:+19 | seg=44%(254) ter=33%(247) qua=38%(191) qui=45%(236) sex=39%(264) |
| COMPRA | 300 | structure_before=BEARISH & hour_srv=3 | 2024-01-25 | 2026-10-13 | 40.1 | 39.2 | 2024:-10; 2025:+53; 2026:+19 | seg=32%(138) ter=42%(176) qua=39%(148) qui=50%(121) sex=39%(126) |
| COMPRA | 300 | mtf_D1=RANGE & hour_srv=4 | 2024-02-21 | 2026-09-18 | 21.6 | 54.9 | 2024:-18; 2025:+16; 2026:+72 | seg=50%(152) ter=48%(136) qua=52%(120) qui=35%(148) sex=19%(148) |


### Abertura de semana / gap / sexta (execução menos confiável)

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | z_val | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | day_of_week=SUNDAY & mtf_D1=RANGE | 421 | 62.2 | 69.7 | 19.5 | 57.5 | 259.8 | -93.1 | 26.4 | 109.8 | 108.9 | -614.2 | 179.8 | 574.0 | 720.0 | 11.8 | sim | 3/3 | 15/22 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & mtf_W1=BULLISH | 691 | 52.1 | 66.5 | 19.5 | 48.4 | 259.2 | -93.1 | 26.4 | 77.3 | 47.9 | -719.7 | 211.8 | 577.0 | 615.0 | 15.9 | sim | 2/3 | 14/22 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & atr_ratio_prev=Q1 | 432 | 52.1 | 72.1 | 19.5 | 47.4 | 249.9 | -93.1 | 27.2 | 69.4 | 52.2 | -719.7 | 172.8 | 508.9 | 630.0 | 9.7 | sim | 3/3 | 20/26 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & dom_w=d15_21 | 343 | 50.7 | 58.7 | 19.5 | 45.5 | 256.3 | -93.1 | 26.6 | 65.7 | 74.2 | -587.4 | 139.1 | 323.6 | 660.0 | 11.3 | nao | 2/3 | 21/32 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & dom_w=d08_14 | 353 | 49.6 | 54.7 | 19.5 | 44.4 | 259.1 | -93.1 | 26.4 | 63.2 | 62.2 | -606.2 | 154.6 | 315.8 | 555.0 | 10.3 | nao | 3/3 | 20/33 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & mtf_H1=BEARISH | 584 | 47.3 | 53.0 | 19.5 | 43.2 | 255.2 | -93.1 | 26.7 | 57.5 | 48.1 | -719.7 | 203.8 | 527.4 | 645.0 | 9.8 | sim | 2/3 | 21/31 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & mtf_M15=BEARISH | 626 | 46.2 | 49.6 | 19.5 | 42.3 | 258.5 | -93.1 | 26.5 | 55.6 | 63.6 | -632.0 | 202.9 | 508.5 | 585.0 | 11.5 | sim | 3/3 | 23/34 | 2 |
| COMPRA | 300 | day_of_week=SUNDAY & p1=Q1 | 266 | 47.4 | 52.1 | 19.5 | 41.4 | 247.6 | -93.1 | 27.3 | 48.1 | 51.9 | -659.7 | 178.8 | 468.0 | 585.0 | 8.1 | nao | 2/3 | 21/34 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & mtf_M1=BEARISH | 457 | 45.3 | 46.3 | 19.5 | 40.8 | 252.9 | -93.1 | 26.9 | 48.0 | 50.0 | -600.2 | 188.1 | 507.0 | 600.0 | 8.7 | sim | 2/3 | 22/34 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & pcum10=Q2 | 303 | 47.2 | 44.9 | 19.5 | 41.6 | 245.1 | -93.1 | 27.5 | 47.7 | 56.2 | -719.7 | 175.4 | 401.8 | 555.0 | 7.0 | nao | 2/3 | 20/33 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & mtf_M5=BEARISH | 555 | 45.9 | 45.3 | 19.5 | 41.8 | 242.5 | -93.1 | 27.7 | 47.3 | 43.7 | -528.0 | 198.3 | 516.0 | 555.0 | 9.6 | sim | 2/3 | 16/34 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & pcum10=Q4 | 291 | 45.0 | 48.4 | 19.5 | 39.4 | 262.7 | -93.1 | 26.2 | 47.1 | 47.0 | -582.7 | 203.6 | 511.0 | 600.0 | 5.9 | nao | 2/3 | 19/30 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & mtf_M30=RANGE | 399 | 45.4 | 42.5 | 19.5 | 40.5 | 251.4 | -93.1 | 27.0 | 46.6 | 26.3 | -622.9 | 197.9 | 517.4 | 585.0 | 7.2 | sim | 2/3 | 17/31 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY | 1,517 | 42.1 | 41.3 | 19.5 | 39.6 | 256.7 | -93.1 | 26.6 | 45.4 | 31.2 | -719.7 | 202.3 | 520.6 | 585.0 | 13.1 | sim | 2/3 | 19/34 | 1 |
| COMPRA | 300 | day_of_week=SUNDAY & news_state=NONE_60M | 1,504 | 41.7 | 41.5 | 19.5 | 39.2 | 256.6 | -93.1 | 26.6 | 44.1 | 29.9 | -719.7 | 203.0 | 525.1 | 585.0 | 13.2 | sim | 2/3 | 19/34 | 1 |


**Últimas 10 ocorrências das 12 primeiras (data/hora do servidor → líquido em pontos; * = bateu o alvo):**

- VENDA alvo 300 | mtf_D1=BREAK_UP & month=5: 05-07 21:00 +148; 05-07 21:15 +140; 05-07 21:30 +122; 05-07 21:45 +60; 05-07 22:00 +107; 05-07 22:15 +99; 05-07 22:30 +32; 05-07 22:45 +69; 05-07 23:00 -48; 05-07 23:15 +12
- COMPRA alvo 300 | month=5 & news_min_to_next_high=Q3: 05-29 06:45 +286*; 05-29 07:00 +286*; 05-29 07:15 +286*; 05-29 07:30 +286*; 05-29 07:45 +286*; 05-29 08:00 +286*; 05-29 08:15 +286*; 05-29 08:30 +286*; 05-29 08:45 +286*; 05-29 09:00 +286*
- VENDA alvo 300 | month=2 & news_min_to_next_high=Q4: 02-27 01:45 -141; 02-27 02:00 -131; 02-27 02:15 -97; 02-27 02:30 -93; 02-27 02:45 -167; 02-27 03:00 -172; 02-27 03:15 -102; 02-27 03:30 -116; 02-27 03:45 -120; 02-27 04:00 -114
- COMPRA alvo 300 | mtf_H1=BEARISH & month=4: 04-30 08:30 +286*; 04-30 08:45 +286*; 04-30 09:00 +286*; 04-30 09:15 +286*; 04-30 09:30 +286*; 04-30 09:45 +286*; 04-30 10:00 +286*; 04-30 10:15 +286*; 04-30 10:30 +286*; 04-30 10:45 +286*
- COMPRA alvo 300 | session=OFF_SESSION & mtf_D1=BREAK_DOWN: 10-01 02:30 -174; 10-01 02:45 -173; 10-02 01:00 +265*; 10-02 01:15 +284*; 10-02 01:30 +285*; 10-02 01:45 +285*; 10-02 02:00 +286*; 10-02 02:15 +286*; 10-02 02:30 +286*; 10-02 02:45 +286*
- COMPRA alvo 300 | month=5 & news_min_to_next_high=Q2: 05-29 11:15 +286*; 05-29 11:30 +286*; 05-29 11:45 +286*; 05-29 12:00 +286*; 05-29 12:15 +286*; 05-29 12:30 +286*; 05-29 12:45 +286*; 05-29 13:00 +286*; 05-29 13:15 +286*; 05-29 13:30 +286*
- VENDA alvo 300 | session=ASIA & news_min_since_last_high=Q2: 09-11 03:00 -156; 09-17 03:00 -244; 09-17 03:15 -241; 09-17 03:30 -228; 09-17 03:45 -183; 09-17 04:00 -243; 09-17 04:15 -177; 09-17 04:30 -178; 10-08 03:00 +10; 10-09 03:00 -290
- COMPRA alvo 300 | month=5 & news_min_to_next_high=Q4: 05-29 02:00 +286*; 05-29 02:15 +286*; 05-29 02:30 +286*; 05-29 02:45 +286*; 05-29 03:00 +286*; 05-29 03:15 +286*; 05-29 03:30 +286*; 05-29 03:45 +286*; 05-29 04:00 +286*; 05-29 04:15 +286*
- COMPRA alvo 300 | mtf_D1=RANGE & hour_srv=1: 09-16 01:30 -464; 09-16 01:45 -456; 09-17 01:00 +271*; 09-17 01:15 +284*; 09-17 01:30 +285*; 09-17 01:45 +285*; 09-18 01:00 +153; 09-18 01:15 +151; 09-18 01:30 +152; 09-18 01:45 +145
- VENDA alvo 300 | month=3 & news_min_since_last_high=Q3: 03-31 03:00 -573; 03-31 03:15 -665; 03-31 03:30 -601; 03-31 03:45 -520; 03-31 04:00 -460; 03-31 04:15 -465; 03-31 04:30 +286*; 03-31 04:45 +286*; 03-31 05:00 +286*; 03-31 05:15 -376
- COMPRA alvo 300 | session=OFF_SESSION & mtf_D1=RANGE: 09-17 02:30 +286*; 09-17 02:45 +286*; 09-18 01:00 +153; 09-18 01:15 +151; 09-18 01:30 +152; 09-18 01:45 +145; 09-18 02:00 +156; 09-18 02:15 +148; 09-18 02:30 +153; 09-18 02:45 +110
- COMPRA alvo 300 | mtf_M5=BEARISH & hour_srv=1: 09-17 01:00 +271*; 09-17 01:15 +284*; 09-18 01:00 +153; 09-18 01:15 +151; 09-24 01:00 -308; 09-28 01:00 -30; 09-28 01:30 +18; 10-02 01:00 +265*; 10-02 01:15 +284*; 10-14 01:00 +266*

_(tempo 83s)_
