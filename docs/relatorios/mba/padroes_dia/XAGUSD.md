# XAGUSD — padrões intraday: alvo ou saída às 23:30 (hora do servidor)

Dados: M15 de 2024-01-22 a 2026-10-16 (708 dias; descoberta até 2025-09-11, validação depois). Entrada na abertura da vela M15 do horário; sai no **alvo** (+100/200/300/500 pontos) ou às **23:30** do servidor (fechamento da vela 23:15). **Sem stop.** Custo: spread medido nos ticks (compra paga na entrada, venda na saída). Comissão e slippage não incluídos.

ATR M15 mediano = 101 pts; alvos testados: [25, 50, 100, 200, 300] pts

**Como ler o risco sem stop.** `pct_alvo` = % dos dias em que o alvo foi atingido antes das 23:30. `ganho_dia_alvo` = resultado líquido médio nesses dias (≈ alvo − custo). `perda_media_sem_alvo` = resultado médio nos dias em que o alvo NÃO foi atingido, calculado no conjunto inteiro de dias daquele lado/alvo (amostra grande da cauda). `pct_necessario_p_empatar` = % de acerto necessário para a conta empatar com essa perda média. `pct_alvo_min95` = limite inferior (95%) da taxa de acerto do padrão. `ev_estresse_pts` = pct_alvo_min95 × ganho + (1−pct_alvo_min95) × perda_media_sem_alvo: expectativa em pontos por operação **supondo o pior plausível para a taxa de acerto**. `mae_medio/p90` = quanto o preço andou CONTRA você antes de sair (média e pior 10% dos dias). Um padrão só é listado se `ev_estresse_pts` > 0 **e** a média realmente obtida (`media_real_pts`) for > 0 na descoberta e na validação, e a taxa de acerto for significativamente maior que a média dos horários.

## A. Horários puros (só o relógio)

Padrões que passaram: **0**; placebo: média 0.1, máximo 1. Não se distingue do acaso.

**Nenhum horário puro passou.**


## B. Horário + condição (variáveis conhecidas ANTES da abertura da vela)

Hipóteses testadas: **97,290**; passaram no BH na descoberta: **5,858**; confirmadas na validação: **2,023**; placebo: BH média 28.7 (máx 102), confirmadas média 2.2 (máx 5).

Famílias distintas que passam (hit rate acima da média dos horários na validação e `ev_estresse` > 0 nas duas metades do tempo): **30** (BH na descoberta: 23).

### Famílias (exclui domingo/gap/sexta), ordenadas por expectativa estressada

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | z_val | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | month=10 & news_min_since_last_high=Q3 | 592 | 81.8 | 84.0 | 70.9 | 78.4 | 274.8 | -322.1 | 54.0 | 146.2 | 46.1 | -3,675.6 | 452.2 | 1,054.7 | 255.0 | 10.6 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 300 | mtf_W1=BREAK_UP & hour_srv=4 | 412 | 78.6 | 86.7 | 70.9 | 74.4 | 275.0 | -322.1 | 53.9 | 122.4 | 87.3 | -4,258.0 | 454.5 | 1,117.7 | 165.0 | 6.3 | nao | 3/3 | 8/9 | 1 |
| COMPRA | 300 | session=OFF_SESSION & dom_w=d08_14 | 1,095 | 75.1 | 97.7 | 70.9 | 72.4 | 272.4 | -322.1 | 54.2 | 108.4 | 113.2 | -3,675.6 | 384.1 | 859.6 | 270.0 | 12.7 | sim | 3/3 | 24/33 | 1 |
| COMPRA | 300 | month=9 & news_min_since_last_high=Q3 | 637 | 75.2 | 73.8 | 70.9 | 71.7 | 275.2 | -322.1 | 53.9 | 106.2 | 75.4 | -4,111.9 | 351.4 | 952.0 | 345.0 | 5.8 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=5 | 412 | 89.1 | 94.9 | 78.7 | 85.7 | 176.9 | -338.4 | 65.7 | 103.2 | 79.6 | -8,557.2 | 352.4 | 790.3 | 150.0 | 7.0 | nao | 3/3 | 6/9 | 1 |
| COMPRA | 300 | month=9 & news_min_to_next_high=Q3 | 712 | 73.0 | 75.4 | 70.9 | 69.7 | 276.9 | -322.1 | 53.8 | 95.2 | 65.9 | -2,850.0 | 393.7 | 871.6 | 315.0 | 6.6 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 200 | mtf_M30=BEARISH & mtf_D1=BREAK_DOWN | 489 | 87.7 | 95.5 | 78.7 | 84.5 | 174.5 | -338.4 | 66.0 | 95.1 | 68.8 | -5,198.1 | 378.1 | 835.4 | 75.0 | 7.2 | sim | 3/3 | 12/13 | 1 |
| COMPRA | 300 | dom_w=d08_14 & hour_srv=4 | 660 | 73.2 | 90.9 | 70.9 | 69.7 | 275.0 | -322.1 | 53.9 | 93.9 | 64.7 | -5,082.5 | 409.9 | 822.4 | 270.0 | 7.2 | sim | 3/3 | 26/33 | 1 |
| COMPRA | 300 | dom_w=d01_07 & hour_srv=4 | 648 | 73.0 | 89.7 | 70.9 | 69.4 | 275.4 | -322.1 | 53.9 | 92.9 | 27.2 | -13,797.0 | 511.3 | 1,133.3 | 270.0 | 6.6 | sim | 3/3 | 22/33 | 1 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=6 | 409 | 86.6 | 91.3 | 78.7 | 82.9 | 178.9 | -338.4 | 65.4 | 90.5 | 57.9 | -8,267.0 | 371.3 | 871.8 | 135.0 | 5.5 | nao | 3/3 | 6/9 | 1 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=4 | 412 | 86.9 | 92.2 | 78.7 | 83.3 | 175.1 | -338.4 | 65.9 | 89.3 | 53.7 | -4,258.0 | 388.8 | 917.7 | 75.0 | 5.9 | nao | 3/3 | 7/9 | 1 |
| COMPRA | 200 | month=9 & news_min_to_next_high=Q3 | 712 | 85.7 | 87.2 | 78.7 | 82.9 | 177.0 | -338.4 | 65.7 | 88.9 | 51.8 | -2,850.0 | 334.0 | 765.7 | 255.0 | 8.2 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=4 & dom_w=d08_14 | 1,350 | 70.7 | 83.8 | 70.9 | 68.3 | 275.1 | -322.1 | 53.9 | 85.5 | 137.1 | -3,277.3 | 314.2 | 632.1 | 165.0 | 5.1 | sim | 3/3 | 3/3 | 1 |
| COMPRA | 200 | mtf_W1=BREAK_UP & news_min_to_next_high=Q3 | 1,079 | 84.3 | 89.5 | 78.7 | 82.0 | 175.2 | -338.4 | 65.9 | 83.0 | 13.3 | -27,386.0 | 518.5 | 1,190.0 | 150.0 | 7.4 | nao | 2/3 | 5/9 | 1 |
| COMPRA | 300 | dom_w=d01_07 & news_min_to_next_high=Q3 | 2,243 | 69.4 | 85.2 | 70.9 | 67.4 | 276.0 | -322.1 | 53.9 | 81.2 | 24.5 | -6,457.6 | 477.0 | 1,222.8 | 315.0 | 8.4 | sim | 3/3 | 23/33 | 1 |
| COMPRA | 300 | month=9 & news_min_since_last_high=Q5 | 636 | 70.4 | 71.0 | 70.9 | 66.8 | 275.1 | -322.1 | 53.9 | 76.7 | 56.9 | -2,871.3 | 368.4 | 877.0 | 165.0 | 4.9 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 200 | dom_w=d08_14 & hour_srv=1 | 638 | 83.5 | 99.2 | 78.7 | 80.5 | 174.0 | -338.4 | 66.0 | 73.9 | 82.3 | -3,675.6 | 320.1 | 808.6 | 210.0 | 8.0 | sim | 3/3 | 25/33 | 1 |
| COMPRA | 200 | month=9 & news_min_since_last_high=Q3 | 637 | 83.4 | 81.6 | 78.7 | 80.3 | 175.1 | -338.4 | 65.9 | 73.8 | 66.3 | -2,879.0 | 273.1 | 633.4 | 270.0 | 5.4 | sim | 3/3 | 3/3 | 1 |
| COMPRA | 200 | session=OFF_SESSION & dom_w=d08_14 | 1,095 | 82.9 | 99.5 | 78.7 | 80.6 | 172.7 | -338.4 | 66.2 | 73.4 | 79.1 | -3,675.6 | 315.4 | 794.2 | 195.0 | 11.0 | sim | 3/3 | 25/33 | 1 |
| VENDA | 300 | month=11 & news_min_since_last_high=Q4 | 360 | 72.2 | 84.4 | 72.1 | 67.4 | 271.8 | -342.6 | 55.8 | 71.4 | 41.9 | -1,420.6 | 346.4 | 989.5 | 195.0 | 6.8 | nao | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=10 & news_min_to_next_high=Q3 | 576 | 71.2 | 76.6 | 72.1 | 67.4 | 270.2 | -342.6 | 55.9 | 70.2 | 65.9 | -1,546.6 | 453.7 | 1,078.5 | 255.0 | 6.0 | nao | 3/3 | 3/3 | 1 |
| COMPRA | 200 | structure_before=BEARISH & hour_srv=1 | 893 | 81.9 | 93.9 | 78.7 | 79.2 | 175.3 | -338.4 | 65.9 | 68.4 | 19.2 | -7,928.5 | 389.5 | 904.8 | 180.0 | 7.9 | sim | 2/3 | 20/34 | 2 |
| COMPRA | 200 | month=9 & news_min_since_last_high=Q5 | 636 | 82.1 | 80.9 | 78.7 | 78.9 | 175.1 | -338.4 | 65.9 | 66.8 | 47.9 | -2,871.3 | 301.9 | 689.0 | 120.0 | 5.3 | sim | 2/3 | 2/3 | 1 |
| COMPRA | 200 | dom_w=d08_14 & hour_srv=4 | 660 | 81.5 | 94.3 | 78.7 | 78.4 | 175.1 | -338.4 | 65.9 | 64.0 | 39.9 | -5,082.5 | 343.4 | 741.4 | 120.0 | 6.3 | sim | 2/3 | 24/33 | 1 |
| COMPRA | 200 | session=OFF_SESSION & pcum3=Q1 | 681 | 80.9 | 92.4 | 78.7 | 77.8 | 173.3 | -338.4 | 66.1 | 59.7 | 19.5 | -4,865.6 | 390.1 | 931.0 | 135.0 | 6.0 | sim | 2/3 | 21/33 | 1 |
| COMPRA | 200 | mtf_M30=BULLISH & news_min_to_next_high=Q3 | 2,943 | 77.7 | 91.3 | 78.7 | 76.1 | 176.2 | -338.4 | 65.8 | 53.4 | 35.9 | -6,457.6 | 375.1 | 910.6 | 210.0 | 9.7 | sim | 3/3 | 21/34 | 1 |
| COMPRA | 100 | mtf_H1=BEARISH & mtf_D1=BREAK_DOWN | 759 | 93.3 | 99.2 | 88.1 | 91.3 | 74.7 | -360.8 | 82.9 | 36.7 | 45.2 | -1,942.8 | 241.5 | 627.8 | 45.0 | 7.6 | sim | 3/3 | 11/13 | 1 |
| VENDA | 100 | mtf_D1=BREAK_UP & news_min_to_next_high=Q3 | 756 | 92.9 | 96.2 | 88.8 | 90.8 | 72.3 | -367.2 | 83.6 | 31.8 | 9.7 | -4,892.6 | 280.6 | 587.5 | 60.0 | 6.7 | sim | 2/3 | 12/16 | 1 |
| COMPRA | 100 | structure_before=BEARISH & hour_srv=1 | 893 | 91.6 | 97.8 | 88.1 | 89.6 | 75.4 | -360.8 | 82.7 | 30.0 | 5.8 | -7,928.5 | 266.2 | 687.4 | 120.0 | 6.4 | sim | 2/3 | 20/34 | 2 |
| COMPRA | 100 | mtf_M30=BULLISH & news_min_to_next_high=Q3 | 2,943 | 89.4 | 95.8 | 88.1 | 88.3 | 76.2 | -360.8 | 82.6 | 24.9 | 12.6 | -6,457.6 | 254.1 | 673.4 | 90.0 | 7.4 | sim | 3/3 | 21/34 | 1 |


### Estabilidade

| lado | alvo_pts | condicao | primeiro | ultimo | pct_alvo_h1 | pct_alvo_h2 | por_ano | dias_semana |
|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | month=10 & news_min_since_last_high=Q3 | 2024-10-01 | 2026-10-16 | 86.6 | 81.4 | 2024:+52; 2025:+160; 2026:-124 | seg=100%(18) ter=100%(39) qua=74%(112) qui=83%(214) sex=79%(209) |
| COMPRA | 300 | mtf_W1=BREAK_UP & hour_srv=4 | 2024-04-08 | 2026-01-30 | 84.4 | 89.1 | 2024:+61; 2025:+66; 2026:+273 | seg=100%(84) ter=60%(84) qua=70%(84) qui=76%(76) sex=87%(84) |
| COMPRA | 300 | session=OFF_SESSION & dom_w=d08_14 | 2024-02-08 | 2026-10-14 | 98.6 | 96.8 | 2024:+38; 2025:+92; 2026:+209 | seg=75%(219) ter=64%(219) qua=74%(220) qui=84%(225) sex=79%(212) |
| COMPRA | 300 | month=9 & news_min_since_last_high=Q3 | 2024-09-04 | 2026-09-30 | 78.0 | 69.5 | 2024:+134; 2025:+108; 2026:-13 | ter=65%(23) qua=60%(134) qui=81%(248) sex=79%(232) |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=5 | 2024-04-08 | 2026-01-30 | 96.1 | 93.8 | 2024:+54; 2025:+72; 2026:+176 | seg=95%(84) ter=86%(84) qua=86%(84) qui=87%(76) sex=92%(84) |
| COMPRA | 300 | month=9 & news_min_to_next_high=Q3 | 2024-09-03 | 2026-09-30 | 70.6 | 80.2 | 2024:+115; 2025:+114; 2026:-31 | seg=0%(17) ter=51%(153) qua=70%(220) qui=86%(204) sex=96%(118) |
| COMPRA | 200 | mtf_M30=BEARISH & mtf_D1=BREAK_DOWN | 2024-01-23 | 2026-10-15 | 90.9 | 100.0 | 2024:+122; 2025:+158; 2026:+28 | seg=91%(76) ter=92%(110) qua=100%(46) qui=83%(118) sex=83%(139) |
| COMPRA | 300 | dom_w=d08_14 & hour_srv=4 | 2024-02-08 | 2026-10-14 | 93.2 | 88.6 | 2024:+60; 2025:+116; 2026:+8 | seg=78%(132) ter=61%(132) qua=70%(132) qui=78%(132) sex=79%(132) |
| COMPRA | 300 | dom_w=d01_07 & hour_srv=4 | 2024-02-01 | 2026-10-07 | 89.7 | 89.7 | 2024:+19; 2025:+54; 2026:+4 | seg=78%(132) ter=73%(132) qua=79%(128) qui=59%(128) sex=76%(128) |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=6 | 2024-04-08 | 2026-01-30 | 93.7 | 89.0 | 2024:+10; 2025:+53; 2026:+177 | seg=82%(84) ter=85%(81) qua=82%(84) qui=88%(76) sex=95%(84) |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=4 | 2024-04-08 | 2026-01-30 | 91.4 | 93.0 | 2024:+59; 2025:+34; 2026:+173 | seg=100%(84) ter=71%(84) qua=85%(84) qui=83%(76) sex=95%(84) |
| COMPRA | 200 | month=9 & news_min_to_next_high=Q3 | 2024-09-03 | 2026-09-30 | 87.2 | 87.2 | 2024:+81; 2025:+110; 2026:-36 | seg=24%(17) ter=69%(153) qua=88%(220) qui=93%(204) sex=99%(118) |
| COMPRA | 300 | month=4 & dom_w=d08_14 | 2024-04-08 | 2026-04-14 | 83.6 | 84.0 | 2024:+147; 2025:+155; 2026:+109 | seg=54%(270) ter=69%(270) qua=79%(270) qui=75%(270) sex=77%(270) |
| COMPRA | 200 | mtf_W1=BREAK_UP & news_min_to_next_high=Q3 | 2024-04-10 | 2026-01-30 | 83.7 | 95.3 | 2024:+11; 2025:+63; 2026:-299 | seg=94%(78) ter=78%(202) qua=80%(323) qui=84%(306) sex=96%(170) |
| COMPRA | 300 | dom_w=d01_07 & news_min_to_next_high=Q3 | 2024-02-01 | 2026-10-07 | 84.4 | 85.9 | 2024:+14; 2025:+11; 2026:+53 | seg=77%(349) ter=68%(391) qua=72%(535) qui=59%(493) sex=73%(475) |
| COMPRA | 300 | month=9 & news_min_since_last_high=Q5 | 2024-09-04 | 2026-09-30 | 68.8 | 73.1 | 2024:+114; 2025:+143; 2026:-105 | ter=74%(27) qua=85%(191) qui=66%(152) sex=62%(266) |
| COMPRA | 200 | dom_w=d08_14 & hour_srv=1 | 2024-02-08 | 2026-10-14 | 99.2 | 99.2 | 2024:+32; 2025:+66; 2026:+153 | seg=84%(128) ter=75%(128) qua=83%(127) qui=90%(130) sex=86%(125) |
| COMPRA | 200 | month=9 & news_min_since_last_high=Q3 | 2024-09-04 | 2026-09-30 | 83.2 | 79.9 | 2024:+130; 2025:+47; 2026:+24 | ter=70%(23) qua=70%(134) qui=86%(248) sex=90%(232) |
| COMPRA | 200 | session=OFF_SESSION & dom_w=d08_14 | 2024-02-08 | 2026-10-14 | 99.5 | 99.5 | 2024:+24; 2025:+52; 2026:+161 | seg=84%(219) ter=72%(219) qua=82%(220) qui=89%(225) sex=88%(212) |
| VENDA | 300 | month=11 & news_min_since_last_high=Q4 | 2024-11-01 | 2025-11-27 | 100.0 | 68.8 | 2024:+22; 2025:+67 | ter=100%(20) qua=70%(60) qui=68%(160) sex=74%(120) |
| VENDA | 300 | month=10 & news_min_to_next_high=Q3 | 2024-10-01 | 2026-10-15 | 67.5 | 85.8 | 2024:+39; 2025:+9; 2026:+198 | seg=41%(17) ter=60%(83) qua=80%(170) qui=71%(187) sex=71%(119) |
| COMPRA | 200 | structure_before=BEARISH & hour_srv=1 | 2024-01-23 | 2026-10-14 | 96.1 | 91.7 | 2024:+19; 2025:-10; 2026:+44 | seg=84%(184) ter=84%(137) qua=86%(181) qui=79%(224) sex=77%(167) |
| COMPRA | 200 | month=9 & news_min_since_last_high=Q5 | 2024-09-04 | 2026-09-30 | 80.0 | 81.9 | 2024:+116; 2025:+94; 2026:-82 | ter=81%(27) qua=97%(191) qui=75%(152) sex=76%(266) |
| COMPRA | 200 | dom_w=d08_14 & hour_srv=4 | 2024-02-08 | 2026-10-14 | 95.5 | 93.2 | 2024:+50; 2025:+72; 2026:-10 | seg=81%(132) ter=80%(132) qua=80%(132) qui=83%(132) sex=85%(132) |
| COMPRA | 200 | session=OFF_SESSION & pcum3=Q1 | 2024-02-05 | 2026-10-16 | 96.7 | 88.2 | 2024:-30; 2025:+38; 2026:+45 | seg=79%(188) ter=77%(154) qua=81%(135) qui=90%(104) sex=81%(100) |
| COMPRA | 200 | mtf_M30=BULLISH & news_min_to_next_high=Q3 | 2024-01-25 | 2026-10-15 | 92.4 | 90.1 | 2024:+29; 2025:+42; 2026:+36 | seg=73%(301) ter=71%(540) qua=82%(783) qui=74%(836) sex=87%(483) |
| COMPRA | 100 | mtf_H1=BEARISH & mtf_D1=BREAK_DOWN | 2024-01-23 | 2026-10-15 | 98.5 | 100.0 | 2024:+26; 2025:+43; 2026:+62 | seg=99%(72) ter=89%(182) qua=100%(64) qui=88%(202) sex=98%(239) |
| VENDA | 100 | mtf_D1=BREAK_UP & news_min_to_next_high=Q3 | 2024-03-05 | 2026-08-20 | 93.3 | 99.0 | 2024:+27; 2025:-7; 2026:+29 | seg=98%(61) ter=93%(202) qua=90%(204) qui=98%(204) sex=84%(85) |
| COMPRA | 100 | structure_before=BEARISH & hour_srv=1 | 2024-01-23 | 2026-10-14 | 99.5 | 96.1 | 2024:+4; 2025:+16; 2026:-1 | seg=89%(184) ter=93%(137) qua=96%(181) qui=90%(224) sex=90%(167) |
| COMPRA | 100 | mtf_M30=BULLISH & news_min_to_next_high=Q3 | 2024-01-25 | 2026-10-15 | 96.9 | 94.7 | 2024:+18; 2025:+14; 2026:+5 | seg=85%(301) ter=89%(540) qua=92%(783) qui=87%(836) sex=92%(483) |


**Últimas 10 ocorrências das 12 primeiras (data/hora do servidor → líquido em pontos; * = bateu o alvo):**

- COMPRA alvo 300 | month=10 & news_min_since_last_high=Q3: 10-16 05:00 +280*; 10-16 05:15 +280*; 10-16 05:30 +276*; 10-16 05:45 +276*; 10-16 06:00 -776; 10-16 06:15 -835; 10-16 06:30 +280*; 10-16 06:45 +280*; 10-16 07:00 -921; 10-16 07:15 -791
- COMPRA alvo 300 | mtf_W1=BREAK_UP & hour_srv=4: 01-28 04:30 +278*; 01-28 04:45 +278*; 01-29 04:00 +272*; 01-29 04:15 +272*; 01-29 04:30 +278*; 01-29 04:45 +278*; 01-30 04:00 +268*; 01-30 04:15 +243*; 01-30 04:30 +241*; 01-30 04:45 +268*
- COMPRA alvo 300 | session=OFF_SESSION & dom_w=d08_14: 10-13 02:30 +271*; 10-13 02:45 +271*; 10-14 01:00 -3676; 10-14 01:15 -3590; 10-14 01:30 -3604; 10-14 01:45 -3575; 10-14 02:00 -3587; 10-14 02:15 +273*; 10-14 02:30 +271*; 10-14 02:45 +271*
- COMPRA alvo 300 | month=9 & news_min_since_last_high=Q3: 09-30 03:00 -1188; 09-30 03:15 -1097; 09-30 03:30 -1005; 09-30 03:45 -1029; 09-30 04:00 -943; 09-30 04:15 +272*; 09-30 04:30 +280*; 09-30 04:45 +280*; 09-30 05:00 +280*; 09-30 05:15 +280*
- COMPRA alvo 200 | mtf_W1=BREAK_UP & hour_srv=5: 01-28 05:30 +176*; 01-28 05:45 +176*; 01-29 05:00 +178*; 01-29 05:15 +178*; 01-29 05:30 +176*; 01-29 05:45 +176*; 01-30 05:00 +168*; 01-30 05:15 +168*; 01-30 05:30 +168*; 01-30 05:45 +168*
- COMPRA alvo 300 | month=9 & news_min_to_next_high=Q3: 09-30 05:30 +276*; 09-30 05:45 +276*; 09-30 06:00 +280*; 09-30 06:15 +280*; 09-30 06:30 +280*; 09-30 06:45 +280*; 09-30 07:00 +278*; 09-30 07:15 +278*; 09-30 07:30 +279*; 09-30 07:45 +279*
- COMPRA alvo 200 | mtf_M30=BEARISH & mtf_D1=BREAK_DOWN: 10-15 01:00 +176*; 10-15 01:15 +176*; 10-15 01:30 +179*; 10-15 01:45 +179*; 10-15 02:00 +173*; 10-15 02:15 +173*; 10-15 02:30 +171*; 10-15 02:45 +171*; 10-15 03:00 +165*; 10-15 03:15 +165*
- COMPRA alvo 300 | dom_w=d08_14 & hour_srv=4: 10-12 04:30 -994; 10-12 04:45 -831; 10-13 04:00 +272*; 10-13 04:15 +272*; 10-13 04:30 +280*; 10-13 04:45 +280*; 10-14 04:00 +272*; 10-14 04:15 +272*; 10-14 04:30 -3665; 10-14 04:45 +280*
- COMPRA alvo 300 | dom_w=d01_07 & hour_srv=4: 10-05 04:30 +280*; 10-05 04:45 +280*; 10-06 04:00 +272*; 10-06 04:15 +272*; 10-06 04:30 +280*; 10-06 04:45 +280*; 10-07 04:00 -1423; 10-07 04:15 -1372; 10-07 04:30 -1331; 10-07 04:45 -1344
- COMPRA alvo 200 | mtf_W1=BREAK_UP & hour_srv=6: 01-28 06:30 +178*; 01-28 06:45 +178*; 01-29 06:00 +177*; 01-29 06:15 +178*; 01-29 06:30 +178*; 01-29 06:45 +178*; 01-30 06:00 +168*; 01-30 06:15 +168*; 01-30 06:30 +168*; 01-30 06:45 +169*
- COMPRA alvo 200 | mtf_W1=BREAK_UP & hour_srv=4: 01-28 04:30 +178*; 01-28 04:45 +178*; 01-29 04:00 +172*; 01-29 04:15 +172*; 01-29 04:30 +178*; 01-29 04:45 +178*; 01-30 04:00 +168*; 01-30 04:15 +143*; 01-30 04:30 +141*; 01-30 04:45 +168*
- COMPRA alvo 200 | month=9 & news_min_to_next_high=Q3: 09-30 05:30 +176*; 09-30 05:45 +176*; 09-30 06:00 +180*; 09-30 06:15 +180*; 09-30 06:30 +180*; 09-30 06:45 +180*; 09-30 07:00 +178*; 09-30 07:15 +178*; 09-30 07:30 +179*; 09-30 07:45 +179*

_(tempo 56s)_
