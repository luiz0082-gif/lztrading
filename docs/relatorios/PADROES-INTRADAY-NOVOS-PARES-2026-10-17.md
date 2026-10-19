# Padrões intraday — entrada no horário, saída no alvo ou às 23:30 do servidor, sem stop

**Regra:** entra na abertura da vela M15 do horário (hora do servidor), fecha quando o preço faz o alvo a favor ou às **23:30** do servidor (fechamento da vela 23:15). Sem stop; 1 operação por dia útil. **Os alvos são proporcionais à volatilidade de cada par** (25%, 50%, 100% e 200% do ATR M15, mais 300 pontos); o `ATR M15` e os alvos testados estão no topo de cada ativo. 300 pts em FX = 30 pips. Londres = servidor−2h; NY = servidor−7h. Custo = spread medido nos ticks; comissão e slippage não incluídos.

## Como ler

- `pct_alvo` = % dos dias em que o alvo foi atingido; `pct_base_val` = % que **qualquer** horário atinge no mesmo período (para ver quanto a condição melhora). `perda_media_sem_alvo` = resultado médio dos dias em que o alvo NÃO foi atingido (medido em todos os horários); `pct_necessario_p_empatar` = % de acerto necessário para empatar com essa perda; `ev_estresse_pts` = expectativa por operação usando o limite inferior 95% da taxa de acerto; `media_real_pts` = média efetivamente obtida; `pior_dia_pts` e `mae_medio/p90` = o risco sem stop (quanto o preço anda contra você).
- Cada condição é comparada com o resto **do mesmo mês** (remove tendência e regime) e é testada contra um placebo (resultados deslocados no tempo).
- `ambos os lados` = a mesma condição também funciona na direção oposta: é uma condição de **volatilidade** (dia que anda muito), não de direção. Famílias com `month=` ou `dom_w=` foram removidas da lista (poucas amostras por mês, 2 a 3 anos).
- `melhores_horas` = horas do servidor (entrada em qualquer vela M15 dentro da hora) em que a condição, além de valer, tem taxa de acerto acima da média do próprio padrão e resultado médio positivo (n ≥ 25 por hora); `dias_por_ano` = quantos dias do ano a condição aparece; `entradas_por_dia` = quantas velas M15 do mesmo dia a satisfazem (cada vela é uma entrada separada nos números). Para operar, escolha UMA entrada por dia dentro de `melhores_horas`.
- Filtros da lista B: pelo menos 60 dias distintos com o sinal (as entradas do mesmo dia não são independentes), n ≥ 250, taxa de acerto na validação ≥ 8 pontos percentuais acima da base, positivo em todos os anos, média real > 0 e duas metades da validação positivas.


---

## XAGUSD

ATR M15 mediano = 101 pts; alvos testados: [25, 50, 100, 200, 300] pts

**Horários puros que passaram:** 0 (placebo: média 0.1, máx 1). Não se distingue do acaso.

**Horário + condição:** 97,290 hipóteses; confirmadas na validação **2,023**; placebo: confirmadas média 2.2, máximo 5.

### A. Horários puros

**Nenhum horário puro passou nos critérios.**


### B. Horário + condição

Famílias que passam nos filtros: **5**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 200 | mtf_M30=BULLISH & news_min_to_next_high=Q3 | 05h-08h | 314 | 115.4 | 9.4 | direcional | 2,943 | 77.7 | 91.3 | 78.7 | -338.4 | 65.8 | 53.4 | 35.9 | -6,457.6 | 375.1 | 910.6 | 210.0 | sim | 3/3 | 21/34 | 1 |
| COMPRA | 300 | mtf_W1=BREAK_UP & hour_srv=4 | 04h | 103 | 56.8 | 4.0 | direcional | 412 | 78.6 | 86.7 | 70.9 | -322.1 | 53.9 | 122.4 | 87.3 | -4,258.0 | 454.5 | 1,117.7 | 165.0 | nao | 3/3 | 8/9 | 1 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=5 | 05h | 103 | 56.8 | 4.0 | direcional | 412 | 89.1 | 94.9 | 78.7 | -338.4 | 65.7 | 103.2 | 79.6 | -8,557.2 | 352.4 | 790.3 | 150.0 | nao | 3/3 | 6/9 | 1 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=6 | 06h | 103 | 56.8 | 4.0 | direcional | 409 | 86.6 | 91.3 | 78.7 | -338.4 | 65.4 | 90.5 | 57.9 | -8,267.0 | 371.3 | 871.8 | 135.0 | nao | 3/3 | 6/9 | 1 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=4 | 04h | 103 | 56.8 | 4.0 | direcional | 412 | 86.9 | 92.2 | 78.7 | -338.4 | 65.9 | 89.3 | 53.7 | -4,258.0 | 388.8 | 917.7 | 75.0 | nao | 3/3 | 7/9 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| COMPRA | 200 | mtf_M30=BULLISH & news_min_to_next_high=Q3 | 04h:287x 70% +1 | 05h:501x 79% +48 | 06h:632x 80% +43 | 07h:707x 83% +58 | 08h:392x 81% +68 | 09h:231x 73% -21 | 10h:74x 76% -77 | 11h:23x 74% -166 | 12h:17x 82% -145 | 18h:15x 47% +84 | 19h:20x 45% +112 |
| COMPRA | 300 | mtf_W1=BREAK_UP & hour_srv=4 | 04h:412x 79% +87 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=5 | 05h:412x 89% +80 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=6 | 06h:409x 87% +58 |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=4 | 04h:412x 87% +54 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| COMPRA | 200 | mtf_M30=BULLISH & news_min_to_next_high=Q3 | 2024-01-25 | 2026-10-15 | 2024:+29; 2025:+42; 2026:+36 | seg=73%(301) ter=71%(540) qua=82%(783) qui=74%(836) sex=87%(483) |
| COMPRA | 300 | mtf_W1=BREAK_UP & hour_srv=4 | 2024-04-08 | 2026-01-30 | 2024:+61; 2025:+66; 2026:+273 | seg=100%(84) ter=60%(84) qua=70%(84) qui=76%(76) sex=87%(84) |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=5 | 2024-04-08 | 2026-01-30 | 2024:+54; 2025:+72; 2026:+176 | seg=95%(84) ter=86%(84) qua=86%(84) qui=87%(76) sex=92%(84) |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=6 | 2024-04-08 | 2026-01-30 | 2024:+10; 2025:+53; 2026:+177 | seg=82%(84) ter=85%(81) qua=82%(84) qui=88%(76) sex=95%(84) |
| COMPRA | 200 | mtf_W1=BREAK_UP & hour_srv=4 | 2024-04-08 | 2026-01-30 | 2024:+59; 2025:+34; 2026:+173 | seg=100%(84) ter=71%(84) qua=85%(84) qui=83%(76) sex=95%(84) |


---

## EURJPY

ATR M15 mediano = 105 pts; alvos testados: [25, 50, 105, 210, 300] pts

**Horários puros que passaram:** 42 (placebo: média 23.4, máx 33). Acima do acaso.

**Horário + condição:** 100,120 hipóteses; confirmadas na validação **5,680**; placebo: confirmadas média 76.0, máximo 193.

### A. Horários puros

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | 02:00–02:15 | 00:15 | 710 | 67.5 | 63.9 | 293.4 | -225.1 | 43.4 | 106.4 | 26.9 | -3,514.4 | 468.1 | 1,188.1 | 360.0 | 2/3 | 25/34 | 2 |
| COMPRA | 300 | 03:00–03:15 | 01:15 | 710 | 67.6 | 64.1 | 291.9 | -225.1 | 43.5 | 106.1 | 36.2 | -3,343.0 | 445.9 | 1,123.8 | 375.0 | 2/3 | 22/34 | 2 |
| COMPRA | 300 | 06:00–07:15 | 04:30 | 711 | 64.8 | 61.3 | 295.2 | -225.1 | 43.3 | 93.6 | 17.7 | -3,362.7 | 453.3 | 1,071.0 | 270.0 | 2/3 | 21/34 | 6 |
| COMPRA | 300 | 07:45–08:00 | 05:45 | 711 | 64.4 | 60.8 | 294.0 | -225.1 | 43.4 | 90.7 | 27.8 | -3,369.9 | 426.0 | 1,053.0 | 202.5 | 2/3 | 23/34 | 2 |
| COMPRA | 300 | 05:30 | 03:30 | 711 | 62.9 | 59.3 | 295.1 | -225.1 | 43.3 | 83.1 | 5.5 | -3,375.0 | 467.8 | 1,118.0 | 315.0 | 2/3 | 22/34 | 1 |
| COMPRA | 210 | 01:15 | 23:15 | 709 | 76.6 | 73.3 | 204.4 | -250.9 | 55.1 | 83.0 | 34.3 | -3,552.1 | 386.2 | 1,010.8 | 180.0 | 2/3 | 25/34 | 1 |
| COMPRA | 210 | 06:15 | 04:15 | 711 | 75.9 | 72.7 | 204.9 | -250.9 | 55.0 | 80.3 | 12.4 | -3,402.2 | 385.0 | 934.0 | 225.0 | 2/3 | 21/34 | 1 |
| COMPRA | 300 | 09:45–10:00 | 07:45 | 710 | 62.1 | 58.5 | 294.5 | -225.1 | 43.3 | 78.8 | 11.1 | -3,715.4 | 427.9 | 1,015.5 | 150.0 | 2/3 | 20/34 | 2 |
| COMPRA | 210 | 02:45 | 00:45 | 710 | 75.6 | 72.3 | 202.1 | -250.9 | 55.4 | 76.9 | 2.1 | -3,452.9 | 418.7 | 1,174.5 | 195.0 | 1/3 | 19/34 | 1 |
| COMPRA | 210 | 07:00 | 05:00 | 711 | 75.1 | 71.8 | 204.3 | -250.9 | 55.1 | 75.9 | 13.7 | -2,612.7 | 385.3 | 942.0 | 195.0 | 2/3 | 20/34 | 1 |
| COMPRA | 210 | 09:00–09:15 | 07:15 | 710 | 74.5 | 71.2 | 204.3 | -250.9 | 55.1 | 73.1 | 9.7 | -4,429.6 | 370.1 | 958.2 | 105.0 | 1/3 | 17/34 | 2 |
| COMPRA | 210 | 08:00–08:15 | 06:00 | 711 | 73.8 | 70.5 | 204.2 | -250.9 | 55.1 | 69.9 | 16.7 | -2,604.8 | 371.6 | 963.0 | 150.0 | 2/3 | 20/34 | 2 |
| COMPRA | 210 | 09:45 | 07:45 | 710 | 73.4 | 70.0 | 204.5 | -250.9 | 55.1 | 68.0 | 6.9 | -3,715.4 | 373.5 | 957.6 | 90.0 | 2/3 | 20/34 | 1 |
| COMPRA | 210 | 10:15–10:30 | 08:15 | 711 | 72.2 | 68.7 | 204.3 | -250.9 | 55.1 | 62.1 | 20.6 | -3,759.6 | 349.8 | 916.0 | 90.0 | 3/3 | 22/34 | 2 |
| COMPRA | 300 | 11:15 | 09:15 | 711 | 57.4 | 53.7 | 295.6 | -225.1 | 43.2 | 54.6 | 16.3 | -3,442.3 | 400.3 | 972.0 | 225.0 | 2/3 | 22/34 | 1 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| COMPRA | 300 | 02:00–02:15 | 2024:+44; 2025:+40; 2026:-9 | seg=70%(142) ter=69%(143) qua=64%(141) qui=67%(141) sex=69%(143) |
| COMPRA | 300 | 03:00–03:15 | 2024:+80; 2025:+31; 2026:-9 | seg=65%(142) ter=69%(143) qua=66%(141) qui=67%(141) sex=72%(143) |
| COMPRA | 300 | 06:00–07:15 | 2024:+26; 2025:+37; 2026:-16 | seg=64%(143) ter=64%(143) qua=66%(141) qui=65%(141) sex=66%(143) |
| COMPRA | 300 | 07:45–08:00 | 2024:+23; 2025:+64; 2026:-12 | seg=63%(143) ter=66%(143) qua=67%(141) qui=61%(141) sex=65%(143) |
| COMPRA | 300 | 05:30 | 2024:+14; 2025:+19; 2026:-21 | seg=60%(143) ter=63%(143) qua=64%(141) qui=64%(141) sex=64%(143) |
| COMPRA | 210 | 01:15 | 2024:+70; 2025:+34; 2026:-8 | seg=76%(142) ter=75%(143) qua=77%(140) qui=77%(141) sex=78%(143) |
| COMPRA | 210 | 06:15 | 2024:+22; 2025:+21; 2026:-9 | seg=74%(143) ter=73%(143) qua=73%(141) qui=79%(141) sex=80%(143) |
| COMPRA | 300 | 09:45–10:00 | 2024:+5; 2025:+29; 2026:-3 | seg=63%(142) ter=60%(143) qua=60%(141) qui=63%(141) sex=64%(143) |
| COMPRA | 210 | 02:45 | 2024:+28; 2025:-7; 2026:-17 | seg=75%(142) ter=78%(143) qua=74%(141) qui=74%(141) sex=78%(143) |
| COMPRA | 210 | 07:00 | 2024:+24; 2025:+22; 2026:-8 | seg=73%(143) ter=73%(143) qua=78%(141) qui=74%(141) sex=77%(143) |
| COMPRA | 210 | 09:00–09:15 | 2024:-10; 2025:+42; 2026:-7 | seg=73%(142) ter=77%(143) qua=76%(141) qui=71%(141) sex=76%(143) |
| COMPRA | 210 | 08:00–08:15 | 2024:+18; 2025:+43; 2026:-17 | seg=71%(143) ter=73%(143) qua=79%(141) qui=68%(141) sex=78%(143) |
| COMPRA | 210 | 09:45 | 2024:+15; 2025:+14; 2026:-11 | seg=74%(142) ter=72%(143) qua=75%(141) qui=70%(141) sex=76%(143) |
| COMPRA | 210 | 10:15–10:30 | 2024:+16; 2025:+36; 2026:+6 | seg=71%(143) ter=69%(143) qua=74%(141) qui=73%(141) sex=74%(143) |
| COMPRA | 300 | 11:15 | 2024:+15; 2025:+34; 2026:-4 | seg=55%(143) ter=57%(143) qua=63%(141) qui=55%(141) sex=57%(143) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- COMPRA 02:15 alvo 300: 10-07 -1162; 10-08 +294*; 10-09 +294*; 10-12 +294*; 10-13 +292*; 10-14 -725; 10-15 +294*; 10-16 +294*
- COMPRA 03:15 alvo 300: 10-07 -1336; 10-08 +292*; 10-09 +292*; 10-12 -326; 10-13 +292*; 10-14 -792; 10-15 +292*; 10-16 +292*
- COMPRA 06:30 alvo 300: 10-07 -1060; 10-08 -155; 10-09 +295*; 10-12 -402; 10-13 +295*; 10-14 -766; 10-15 +295*; 10-16 +295*
- COMPRA 07:45 alvo 300: 10-07 -969; 10-08 -204; 10-09 +294*; 10-12 -490; 10-13 +294*; 10-14 -759; 10-15 +167; 10-16 +294*
- COMPRA 05:30 alvo 300: 10-07 -1035; 10-08 +295*; 10-09 +295*; 10-12 -418; 10-13 +295*; 10-14 -896; 10-15 +295*; 10-16 +295*
- COMPRA 01:15 alvo 210: 10-07 +205*; 10-08 +205*; 10-09 +205*; 10-12 +204*; 10-13 +205*; 10-14 +205*; 10-15 +205*; 10-16 +205*

### B. Horário + condição

Famílias que passam nos filtros: **226**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | mtf_H4=BEARISH & news_min_to_next_high=Q3 | 03h-06h | 165 | 60.6 | 16.3 | direcional | 2,697 | 72.2 | 66.2 | 40.1 | -225.1 | 43.3 | 140.9 | 60.5 | -3,041.9 | 438.4 | 1,237.2 | 255.0 | sim | 3/3 | 25/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 02h | 217 | 79.7 | 4.0 | direcional | 868 | 73.5 | 67.9 | 40.1 | -225.1 | 43.5 | 139.6 | 69.9 | -2,968.9 | 480.6 | 1,257.6 | 270.0 | sim | 3/3 | 26/34 | 1 |
| VENDA | 300 | mtf_W1=BEARISH & hour_srv=3 | 03h | 125 | 59.0 | 4.0 | direcional | 500 | 77.2 | 62.5 | 35.7 | -296.8 | 50.2 | 136.9 | 73.1 | -2,251.0 | 436.0 | 962.5 | 270.0 | sim | 3/3 | 6/9 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=6 | 06h | 209 | 76.7 | 4.0 | direcional | 836 | 72.1 | 62.2 | 40.1 | -225.1 | 43.3 | 133.8 | 63.3 | -2,074.2 | 435.9 | 1,199.0 | 255.0 | sim | 3/3 | 26/34 | 1 |
| COMPRA | 300 | session=ASIA & mtf_H4=BEARISH | 02h-07h | 270 | 99.1 | 25.3 | direcional | 6,818 | 70.0 | 63.2 | 40.1 | -225.1 | 43.3 | 133.0 | 48.9 | -3,234.8 | 446.8 | 1,190.3 | 240.0 | sim | 3/3 | 25/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 03h | 217 | 79.7 | 4.0 | direcional | 868 | 72.2 | 64.9 | 40.1 | -225.1 | 43.5 | 132.7 | 69.2 | -3,041.9 | 459.7 | 1,192.5 | 300.0 | sim | 3/3 | 27/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=5 | 05h | 209 | 76.7 | 4.0 | direcional | 836 | 71.3 | 64.7 | 40.1 | -225.1 | 43.3 | 129.3 | 44.8 | -2,547.0 | 461.2 | 1,308.0 | 300.0 | sim | 3/3 | 25/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 04h | 209 | 76.7 | 4.0 | direcional | 836 | 71.1 | 64.7 | 40.1 | -225.1 | 43.2 | 128.7 | 43.2 | -2,837.1 | 462.4 | 1,219.0 | 330.0 | sim | 3/3 | 24/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=7 | 07h | 209 | 76.7 | 4.0 | direcional | 836 | 71.3 | 63.8 | 40.1 | -225.1 | 43.4 | 128.7 | 56.9 | -1,925.9 | 425.9 | 1,181.0 | 195.0 | sim | 3/3 | 25/34 | 1 |
| COMPRA | 300 | mtf_M5=BEARISH & hour_srv=2 | 02h | 333 | 122.5 | 1.9 | direcional | 644 | 71.9 | 62.4 | 40.1 | -225.1 | 43.5 | 128.6 | 66.6 | -3,452.9 | 465.3 | 1,179.7 | 300.0 | sim | 3/3 | 25/34 | 1 |
| VENDA | 300 | mtf_W1=BEARISH & hour_srv=1 | 01h | 125 | 59.0 | 4.0 | direcional | 499 | 75.8 | 65.0 | 35.7 | -296.8 | 50.2 | 127.4 | 36.1 | -2,993.0 | 486.5 | 1,197.6 | 195.0 | sim | 3/3 | 7/9 | 1 |
| COMPRA | 300 | hour_srv=2 & atr_ratio_prev=Q3 | 02h | 207 | 76.2 | 2.4 | direcional | 499 | 71.3 | 66.7 | 40.1 | -225.1 | 43.5 | 123.1 | 96.5 | -1,768.1 | 425.3 | 972.6 | 405.0 | sim | 3/3 | 27/33 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=3 | 03h | 159 | 59.1 | 4.0 | direcional | 636 | 70.9 | 58.5 | 40.1 | -225.1 | 43.5 | 122.9 | 71.3 | -1,979.0 | 458.0 | 1,148.5 | 315.0 | sim | 3/3 | 17/22 | 1 |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=1 | 01h | 121 | 45.4 | 4.0 | direcional | 484 | 73.3 | 67.5 | 40.1 | -225.1 | 44.9 | 121.8 | 74.7 | -2,230.9 | 391.0 | 1,038.4 | 315.0 | sim | 3/3 | 21/31 | 1 |
| COMPRA | 300 | session=ASIA & mtf_D1=BEARISH | 02h-07h | 159 | 59.1 | 31.9 | direcional | 5,080 | 68.0 | 56.0 | 40.1 | -225.1 | 43.3 | 121.5 | 39.1 | -3,281.7 | 466.4 | 1,174.2 | 225.0 | sim | 3/3 | 16/22 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| COMPRA | 300 | mtf_H4=BEARISH & news_min_to_next_high=Q3 | 03h:171x 82% +129 | 04h:346x 78% +98 | 05h:470x 75% +75 | 06h:532x 74% +66 | 07h:537x 71% +50 | 08h:346x 67% +11 | 09h:170x 68% +21 | 10h:64x 70% +58 | 11h:19x 68% +136 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 02h:868x 74% +70 |
| VENDA | 300 | mtf_W1=BEARISH & hour_srv=3 | 03h:500x 77% +73 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=6 | 06h:836x 72% +63 |
| COMPRA | 300 | session=ASIA & mtf_H4=BEARISH | 02h:304x 72% +21 | 03h:868x 72% +69 | 04h:836x 71% +43 | 05h:836x 71% +45 | 06h:836x 72% +63 | 07h:836x 71% +57 | 08h:863x 67% +37 | 09h:863x 68% +42 | 10h:576x 65% +42 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 03h:868x 72% +69 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=5 | 05h:836x 71% +45 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 04h:836x 71% +43 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=7 | 07h:836x 71% +57 |
| COMPRA | 300 | mtf_M5=BEARISH & hour_srv=2 | 02h:644x 72% +67 |
| VENDA | 300 | mtf_W1=BEARISH & hour_srv=1 | 01h:499x 76% +36 |
| COMPRA | 300 | hour_srv=2 & atr_ratio_prev=Q3 | 02h:499x 71% +96 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=3 | 03h:636x 71% +71 |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=1 | 01h:484x 73% +75 |
| COMPRA | 300 | session=ASIA & mtf_D1=BEARISH | 02h:216x 73% +0 | 03h:636x 71% +71 | 04h:636x 71% +58 | 05h:636x 69% +53 | 06h:636x 68% +52 | 07h:636x 69% +55 | 08h:632x 67% +35 | 09h:632x 64% -2 | 10h:420x 62% -16 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| COMPRA | 300 | mtf_H4=BEARISH & news_min_to_next_high=Q3 | 2024-01-24 | 2026-10-15 | 2024:+100; 2025:+39; 2026:+37 | seg=63%(213) ter=69%(639) qua=70%(720) qui=82%(594) sex=71%(531) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 2024-01-24 | 2026-10-15 | 2024:+64; 2025:+117; 2026:+21 | seg=78%(172) ter=81%(200) qua=62%(152) qui=76%(140) sex=69%(204) |
| VENDA | 300 | mtf_W1=BEARISH & hour_srv=3 | 2024-09-02 | 2026-10-16 | 2024:+119; 2025:+44; 2026:+3 | seg=80%(100) ter=78%(100) qua=73%(100) qui=79%(100) sex=76%(100) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=6 | 2024-01-24 | 2026-10-15 | 2024:+92; 2025:+63; 2026:+28 | seg=68%(164) ter=73%(184) qua=68%(160) qui=85%(140) sex=69%(188) |
| COMPRA | 300 | session=ASIA & mtf_H4=BEARISH | 2024-01-24 | 2026-10-15 | 2024:+65; 2025:+57; 2026:+20 | seg=68%(1388) ter=73%(1480) qua=64%(1270) qui=78%(1144) sex=67%(1536) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 2024-01-24 | 2026-10-15 | 2024:+88; 2025:+104; 2026:+6 | seg=73%(172) ter=78%(200) qua=64%(152) qui=73%(140) sex=71%(204) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=5 | 2024-01-24 | 2026-10-15 | 2024:+80; 2025:+23; 2026:+27 | seg=68%(164) ter=76%(184) qua=62%(160) qui=86%(140) sex=66%(188) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 2024-01-24 | 2026-10-15 | 2024:+83; 2025:+24; 2026:+16 | seg=71%(164) ter=75%(184) qua=60%(160) qui=86%(140) sex=65%(188) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=7 | 2024-01-24 | 2026-10-15 | 2024:+42; 2025:+86; 2026:+40 | seg=70%(164) ter=72%(184) qua=68%(160) qui=81%(140) sex=67%(188) |
| COMPRA | 300 | mtf_M5=BEARISH & hour_srv=2 | 2024-01-24 | 2026-10-13 | 2024:+79; 2025:+63; 2026:+49 | seg=75%(107) ter=74%(133) qua=74%(109) qui=65%(164) sex=75%(131) |
| VENDA | 300 | mtf_W1=BEARISH & hour_srv=1 | 2024-09-02 | 2026-10-16 | 2024:+52; 2025:+36; 2026:+1 | seg=69%(100) ter=86%(100) qua=71%(100) qui=69%(100) sex=84%(99) |
| COMPRA | 300 | hour_srv=2 & atr_ratio_prev=Q3 | 2024-01-24 | 2026-10-12 | 2024:+70; 2025:+100; 2026:+112 | seg=66%(149) ter=66%(87) qua=66%(68) qui=80%(105) sex=80%(90) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=3 | 2024-02-07 | 2026-10-16 | 2024:+88; 2025:+110; 2026:+37 | seg=74%(108) ter=73%(120) qua=64%(136) qui=73%(140) sex=71%(132) |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=1 | 2024-01-24 | 2026-09-24 | 2024:+168; 2025:+38; 2026:+41 | seg=61%(112) ter=81%(108) qua=65%(96) qui=79%(104) sex=88%(64) |
| COMPRA | 300 | session=ASIA & mtf_D1=BEARISH | 2024-02-07 | 2026-10-16 | 2024:+67; 2025:+62; 2026:+4 | seg=68%(856) ter=67%(960) qua=67%(1088) qui=67%(1120) sex=71%(1056) |


---

## GBPJPY

ATR M15 mediano = 132 pts; alvos testados: [35, 65, 130, 265, 300] pts

**Horários puros que passaram:** 71 (placebo: média 33.5, máx 71). Não se distingue do acaso.

**Horário + condição:** 100,540 hipóteses; confirmadas na validação **5,016**; placebo: confirmadas média 163.5, máximo 685.

### A. Horários puros

_Não se distingue do acaso; listado só para conferência._

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | 03:15–03:30 | 01:15 | 710 | 74.4 | 71.0 | 293.4 | -311.7 | 51.5 | 118.1 | 39.6 | -3,603.5 | 496.5 | 1,279.0 | 315.0 | 3/3 | 25/34 | 2 |
| COMPRA | 300 | 02:45 | 00:45 | 710 | 73.8 | 70.4 | 293.2 | -311.7 | 51.5 | 114.5 | 25.4 | -3,806.6 | 537.7 | 1,382.2 | 330.0 | 2/3 | 23/34 | 1 |
| COMPRA | 300 | 01:15 | 23:15 | 709 | 73.8 | 70.4 | 291.1 | -311.7 | 51.7 | 112.7 | 21.5 | -3,697.3 | 529.5 | 1,371.8 | 270.0 | 2/3 | 22/34 | 1 |
| COMPRA | 300 | 05:45–08:15 | 05:45 | 711 | 72.7 | 69.3 | 293.7 | -311.7 | 51.5 | 108.0 | 41.8 | -3,638.3 | 458.7 | 1,115.0 | 165.0 | 3/3 | 24/34 | 11 |
| COMPRA | 265 | 06:30–08:15 | 06:00 | 711 | 76.7 | 73.4 | 258.6 | -323.1 | 55.5 | 103.9 | 45.0 | -3,712.4 | 428.9 | 1,113.0 | 135.0 | 3/3 | 25/34 | 8 |
| COMPRA | 265 | 03:15–03:30 | 01:30 | 710 | 76.6 | 73.4 | 258.4 | -323.1 | 55.6 | 103.6 | 41.1 | -3,651.6 | 472.7 | 1,185.6 | 300.0 | 2/3 | 24/34 | 2 |
| COMPRA | 300 | 08:45–09:15 | 07:15 | 710 | 71.4 | 68.0 | 293.6 | -311.7 | 51.5 | 99.8 | 31.7 | -5,422.4 | 465.8 | 1,212.7 | 120.0 | 3/3 | 23/34 | 3 |
| COMPRA | 265 | 08:45–09:15 | 07:00 | 710 | 75.2 | 71.9 | 258.6 | -323.1 | 55.5 | 95.2 | 35.1 | -5,535.4 | 455.7 | 1,133.3 | 120.0 | 3/3 | 21/34 | 3 |
| COMPRA | 300 | 10:45–12:30 | 08:45 | 711 | 68.4 | 64.8 | 293.7 | -311.7 | 51.5 | 80.8 | 23.2 | -3,642.3 | 456.8 | 1,172.0 | 135.0 | 2/3 | 22/34 | 8 |
| COMPRA | 300 | 10:00 | 08:00 | 711 | 68.4 | 64.8 | 293.5 | -311.7 | 51.5 | 80.7 | 17.8 | -3,386.5 | 480.3 | 1,205.0 | 120.0 | 2/3 | 21/34 | 1 |
| COMPRA | 265 | 10:45–11:45 | 08:45 | 711 | 71.9 | 68.5 | 258.7 | -323.1 | 55.5 | 75.1 | 28.0 | -3,578.3 | 426.3 | 1,136.0 | 120.0 | 2/3 | 22/34 | 5 |
| COMPRA | 265 | 12:15–12:45 | 10:15 | 710 | 70.0 | 66.5 | 258.7 | -323.1 | 55.5 | 64.0 | 38.7 | -3,899.3 | 404.1 | 984.2 | 165.0 | 3/3 | 24/34 | 3 |
| COMPRA | 130 | 09:15–09:30 | 07:15 | 710 | 88.3 | 85.7 | 123.6 | -366.5 | 74.8 | 53.7 | 17.4 | -5,422.4 | 305.5 | 785.6 | 45.0 | 3/3 | 21/34 | 2 |
| COMPRA | 300 | 13:00 | 11:00 | 711 | 62.3 | 58.7 | 293.6 | -311.7 | 51.5 | 43.6 | 12.6 | -3,753.3 | 464.1 | 1,154.0 | 165.0 | 3/3 | 21/34 | 1 |
| COMPRA | 130 | 11:15–12:30 | 09:15 | 711 | 86.1 | 83.3 | 123.6 | -366.5 | 74.8 | 41.9 | 18.9 | -2,943.4 | 284.4 | 827.0 | 45.0 | 2/3 | 23/34 | 6 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| COMPRA | 300 | 03:15–03:30 | 2024:+104; 2025:+2; 2026:+9 | seg=73%(142) ter=70%(143) qua=74%(141) qui=75%(141) sex=79%(143) |
| COMPRA | 300 | 02:45 | 2024:+72; 2025:+3; 2026:-2 | seg=74%(142) ter=73%(143) qua=74%(141) qui=72%(141) sex=77%(143) |
| COMPRA | 300 | 01:15 | 2024:+54; 2025:+19; 2026:-14 | seg=76%(142) ter=72%(143) qua=71%(140) qui=71%(141) sex=78%(143) |
| COMPRA | 300 | 05:45–08:15 | 2024:+41; 2025:+63; 2026:+17 | seg=76%(143) ter=73%(143) qua=72%(141) qui=71%(141) sex=72%(143) |
| COMPRA | 265 | 06:30–08:15 | 2024:+42; 2025:+75; 2026:+11 | seg=78%(143) ter=78%(143) qua=76%(141) qui=76%(141) sex=76%(143) |
| COMPRA | 265 | 03:15–03:30 | 2024:+97; 2025:+23; 2026:-2 | seg=75%(142) ter=75%(143) qua=77%(141) qui=76%(141) sex=80%(143) |
| COMPRA | 300 | 08:45–09:15 | 2024:+15; 2025:+46; 2026:+34 | seg=73%(142) ter=70%(143) qua=70%(141) qui=72%(141) sex=72%(143) |
| COMPRA | 265 | 08:45–09:15 | 2024:+18; 2025:+67; 2026:+15 | seg=75%(142) ter=78%(143) qua=74%(141) qui=76%(141) sex=74%(143) |
| COMPRA | 300 | 10:45–12:30 | 2024:+30; 2025:+59; 2026:-29 | seg=73%(143) ter=66%(143) qua=70%(141) qui=66%(141) sex=68%(143) |
| COMPRA | 300 | 10:00 | 2024:+9; 2025:+40; 2026:-0 | seg=73%(143) ter=64%(143) qua=67%(141) qui=67%(141) sex=71%(143) |
| COMPRA | 265 | 10:45–11:45 | 2024:+32; 2025:+64; 2026:-22 | seg=75%(143) ter=69%(143) qua=73%(141) qui=70%(141) sex=72%(143) |
| COMPRA | 265 | 12:15–12:45 | 2024:+46; 2025:+25; 2026:+47 | seg=73%(142) ter=69%(143) qua=71%(141) qui=62%(141) sex=75%(143) |
| COMPRA | 130 | 09:15–09:30 | 2024:+1; 2025:+31; 2026:+20 | seg=88%(142) ter=92%(143) qua=88%(141) qui=87%(141) sex=87%(143) |
| COMPRA | 300 | 13:00 | 2024:+25; 2025:+9; 2026:+3 | seg=69%(143) ter=57%(143) qua=65%(141) qui=60%(141) sex=62%(143) |
| COMPRA | 130 | 11:15–12:30 | 2024:+37; 2025:+24; 2026:-8 | seg=85%(143) ter=85%(143) qua=89%(141) qui=87%(141) sex=83%(143) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- COMPRA 03:15 alvo 300: 10-07 -1364; 10-08 +294*; 10-09 +294*; 10-12 +294*; 10-13 +294*; 10-14 +294*; 10-15 +294*; 10-16 +294*
- COMPRA 02:45 alvo 300: 10-07 -1131; 10-08 +293*; 10-09 +293*; 10-12 +294*; 10-13 +293*; 10-14 +293*; 10-15 +293*; 10-16 +293*
- COMPRA 01:15 alvo 300: 10-07 -1115; 10-08 +293*; 10-09 +293*; 10-12 +292*; 10-13 +293*; 10-14 +293*; 10-15 +293*; 10-16 +293*
- COMPRA 07:45 alvo 300: 10-07 -1042; 10-08 +294*; 10-09 +294*; 10-12 -181; 10-13 +294*; 10-14 -1200; 10-15 +294*; 10-16 +294*
- COMPRA 08:00 alvo 265: 10-07 -1075; 10-08 +259*; 10-09 +259*; 10-12 +259*; 10-13 +259*; 10-14 +259*; 10-15 +259*; 10-16 +259*
- COMPRA 03:30 alvo 265: 10-07 -1349; 10-08 +258*; 10-09 +258*; 10-12 +258*; 10-13 +258*; 10-14 +258*; 10-15 +258*; 10-16 +258*

### B. Horário + condição

Famílias que passam nos filtros: **277**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | session=ASIA & mtf_W1=BEARISH | 03h-06h | 115 | 54.8 | 32.0 | direcional | 3,680 | 80.5 | 74.2 | 51.0 | -311.7 | 51.5 | 167.7 | 70.7 | -5,690.6 | 511.9 | 1,347.1 | 150.0 | sim | 3/3 | 6/9 | 1 |
| COMPRA | 300 | mtf_W1=BEARISH & news_min_since_last_high=Q3 | 01h-06h | 62 | 29.6 | 18.5 | direcional | 1,150 | 84.3 | 93.0 | 51.0 | -311.7 | 53.6 | 165.0 | 81.0 | -2,529.0 | 480.4 | 1,311.3 | 210.0 | sim | 3/3 | 7/9 | 1 |
| COMPRA | 265 | session=ASIA & mtf_W1=BEARISH | 03h-08h | 115 | 54.8 | 32.0 | direcional | 3,680 | 82.8 | 77.3 | 55.4 | -323.1 | 55.5 | 151.1 | 62.2 | -5,690.6 | 481.1 | 1,287.1 | 135.0 | sim | 3/3 | 6/9 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=7 | 07h | 145 | 56.0 | 4.0 | direcional | 580 | 79.5 | 69.6 | 51.0 | -311.7 | 51.5 | 148.5 | 123.3 | -3,689.3 | 412.6 | 1,073.3 | 165.0 | sim | 3/3 | 17/22 | 1 |
| COMPRA | 300 | session=ASIA & mtf_D1=BEARISH | 03h-08h | 145 | 56.0 | 31.9 | direcional | 4,632 | 77.2 | 69.4 | 51.0 | -311.7 | 51.5 | 148.3 | 95.9 | -3,689.3 | 457.3 | 1,207.9 | 180.0 | sim | 3/3 | 15/22 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_to_next_high=Q3 | 06h-09h | 90 | 34.8 | 19.1 | direcional | 1,718 | 77.6 | 65.0 | 51.0 | -311.7 | 51.5 | 145.7 | 106.9 | -3,689.3 | 453.3 | 1,181.7 | 180.0 | sim | 3/3 | 14/19 | 1 |
| COMPRA | 265 | mtf_W1=BEARISH & news_min_since_last_high=Q3 | 01h-07h | 62 | 29.6 | 18.5 | direcional | 1,150 | 85.7 | 93.6 | 55.4 | -323.1 | 57.9 | 142.5 | 69.5 | -2,529.0 | 450.0 | 1,265.1 | 165.0 | sim | 3/3 | 7/9 | 1 |
| COMPRA | 300 | hour_srv=4 & pcum3=Q3 | 04h | 365 | 133.9 | 1.3 | direcional | 482 | 78.8 | 71.0 | 51.0 | -311.7 | 51.5 | 142.2 | 108.9 | -3,384.3 | 400.0 | 986.4 | 300.0 | sim | 3/3 | 27/34 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=5 | 05h | 145 | 56.0 | 4.0 | direcional | 580 | 78.4 | 68.5 | 51.0 | -311.7 | 51.5 | 141.9 | 117.5 | -2,448.2 | 443.5 | 1,144.4 | 255.0 | sim | 3/3 | 18/22 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=6 | 06h | 145 | 56.0 | 4.0 | direcional | 580 | 78.1 | 67.3 | 51.0 | -311.7 | 51.5 | 139.7 | 121.1 | -2,320.3 | 438.4 | 1,131.8 | 210.0 | sim | 3/3 | 17/22 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=4 | 04h | 145 | 56.0 | 4.0 | direcional | 580 | 77.9 | 68.8 | 51.0 | -311.7 | 51.5 | 138.6 | 110.8 | -2,588.2 | 460.8 | 1,210.6 | 270.0 | sim | 3/3 | 18/22 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=8 | 08h | 144 | 55.7 | 4.0 | direcional | 576 | 78.0 | 68.8 | 51.0 | -311.7 | 51.5 | 138.5 | 118.8 | -3,604.6 | 433.7 | 1,076.0 | 135.0 | sim | 3/3 | 17/22 | 1 |
| COMPRA | 265 | mtf_D1=BEARISH & hour_srv=7 | 07h | 145 | 56.0 | 4.0 | direcional | 580 | 82.6 | 72.7 | 55.4 | -323.1 | 55.5 | 138.2 | 114.3 | -3,689.3 | 384.9 | 1,038.4 | 150.0 | sim | 3/3 | 17/22 | 1 |
| COMPRA | 265 | session=ASIA & mtf_D1=BEARISH | 03h-08h | 145 | 56.0 | 31.9 | direcional | 4,632 | 80.0 | 72.7 | 55.4 | -323.1 | 55.5 | 135.5 | 85.8 | -3,689.3 | 431.2 | 1,165.4 | 150.0 | sim | 3/3 | 15/22 | 1 |
| COMPRA | 265 | mtf_D1=BEARISH & hour_srv=8 | 08h | 144 | 55.7 | 4.0 | direcional | 576 | 81.8 | 73.8 | 55.4 | -323.1 | 55.6 | 132.9 | 117.1 | -3,604.6 | 400.6 | 1,051.5 | 120.0 | sim | 3/3 | 18/22 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| COMPRA | 300 | session=ASIA & mtf_W1=BEARISH | 02h:120x 72% -65 | 03h:460x 83% +108 | 04h:460x 83% +99 | 05h:460x 83% +105 | 06h:460x 83% +117 | 07h:460x 80% +76 | 08h:460x 80% +33 | 09h:460x 78% +13 | 10h:340x 74% +42 |
| COMPRA | 300 | mtf_W1=BEARISH & news_min_since_last_high=Q3 | 00h:88x 95% -18 | 01h:149x 90% +108 | 02h:171x 88% +85 | 03h:196x 87% +103 | 04h:203x 86% +95 | 05h:130x 85% +80 | 06h:80x 85% +139 | 07h:68x 82% +79 | 08h:22x 82% -96 | 23h:26x 0% -23 |
| COMPRA | 265 | session=ASIA & mtf_W1=BEARISH | 02h:120x 75% -58 | 03h:460x 85% +93 | 04h:460x 83% +80 | 05h:460x 84% +91 | 06h:460x 85% +100 | 07h:460x 85% +86 | 08h:460x 83% +36 | 09h:460x 81% +8 | 10h:340x 76% +27 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=7 | 07h:580x 79% +123 |
| COMPRA | 300 | session=ASIA & mtf_D1=BEARISH | 02h:208x 78% -35 | 03h:580x 77% +84 | 04h:580x 78% +111 | 05h:580x 78% +117 | 06h:580x 78% +121 | 07h:580x 79% +123 | 08h:576x 78% +119 | 09h:576x 75% +77 | 10h:372x 72% +42 |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_to_next_high=Q3 | 03h:122x 77% +101 | 04h:231x 77% +113 | 05h:308x 77% +116 | 06h:357x 78% +125 | 07h:357x 79% +117 | 08h:194x 82% +163 | 09h:99x 82% +122 | 10h:31x 68% -62 |
| COMPRA | 265 | mtf_W1=BEARISH & news_min_since_last_high=Q3 | 00h:88x 95% -52 | 01h:149x 91% +77 | 02h:171x 88% +64 | 03h:196x 88% +89 | 04h:203x 86% +78 | 05h:130x 87% +81 | 06h:80x 86% +118 | 07h:68x 88% +93 | 08h:22x 95% +133 | 23h:26x 0% -23 |
| COMPRA | 300 | hour_srv=4 & pcum3=Q3 | 04h:482x 79% +109 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=5 | 05h:580x 78% +117 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=6 | 06h:580x 78% +121 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=4 | 04h:580x 78% +111 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=8 | 08h:576x 78% +119 |
| COMPRA | 265 | mtf_D1=BEARISH & hour_srv=7 | 07h:580x 83% +114 |
| COMPRA | 265 | session=ASIA & mtf_D1=BEARISH | 02h:208x 79% -46 | 03h:580x 80% +74 | 04h:580x 80% +96 | 05h:580x 80% +110 | 06h:580x 81% +103 | 07h:580x 83% +114 | 08h:576x 82% +117 | 09h:576x 78% +69 | 10h:372x 75% +29 |
| COMPRA | 265 | mtf_D1=BEARISH & hour_srv=8 | 08h:576x 82% +117 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| COMPRA | 300 | session=ASIA & mtf_W1=BEARISH | 2024-09-09 | 2026-10-16 | 2024:+94; 2025:+67; 2026:+24 | seg=83%(736) ter=80%(736) qua=80%(736) qui=79%(736) sex=80%(736) |
| COMPRA | 300 | mtf_W1=BEARISH & news_min_since_last_high=Q3 | 2024-09-12 | 2026-10-16 | 2024:+115; 2025:+27; 2026:+200 | ter=83%(93) qua=83%(226) qui=84%(400) sex=86%(428) |
| COMPRA | 265 | session=ASIA & mtf_W1=BEARISH | 2024-09-09 | 2026-10-16 | 2024:+78; 2025:+59; 2026:+33 | seg=85%(736) ter=83%(736) qua=82%(736) qui=82%(736) sex=82%(736) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=7 | 2024-03-14 | 2026-10-15 | 2024:+152; 2025:+174; 2026:+65 | seg=90%(116) ter=70%(116) qua=79%(108) qui=79%(128) sex=80%(112) |
| COMPRA | 300 | session=ASIA & mtf_D1=BEARISH | 2024-03-14 | 2026-10-15 | 2024:+97; 2025:+125; 2026:+71 | seg=87%(920) ter=70%(928) qua=74%(864) qui=77%(1024) sex=77%(896) |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_to_next_high=Q3 | 2024-03-14 | 2026-10-15 | 2024:+117; 2025:+185; 2026:+40 | seg=100%(76) ter=72%(304) qua=74%(483) qui=80%(589) sex=78%(266) |
| COMPRA | 265 | mtf_W1=BEARISH & news_min_since_last_high=Q3 | 2024-09-12 | 2026-10-16 | 2024:+107; 2025:+17; 2026:+175 | ter=85%(93) qua=84%(226) qui=85%(400) sex=88%(428) |
| COMPRA | 300 | hour_srv=4 & pcum3=Q3 | 2024-01-24 | 2026-10-16 | 2024:+189; 2025:+81; 2026:+34 | seg=78%(105) ter=76%(99) qua=76%(105) qui=83%(84) sex=82%(89) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=5 | 2024-03-14 | 2026-10-15 | 2024:+202; 2025:+130; 2026:+57 | seg=85%(116) ter=75%(116) qua=74%(108) qui=82%(128) sex=75%(112) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=6 | 2024-03-14 | 2026-10-15 | 2024:+207; 2025:+146; 2026:+49 | seg=90%(116) ter=67%(116) qua=78%(108) qui=78%(128) sex=78%(112) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=4 | 2024-03-14 | 2026-10-15 | 2024:+160; 2025:+132; 2026:+64 | seg=82%(116) ter=78%(116) qua=73%(108) qui=84%(128) sex=72%(112) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=8 | 2024-03-14 | 2026-10-15 | 2024:+116; 2025:+178; 2026:+71 | seg=85%(112) ter=73%(116) qua=79%(108) qui=71%(128) sex=83%(112) |
| COMPRA | 265 | mtf_D1=BEARISH & hour_srv=7 | 2024-03-14 | 2026-10-15 | 2024:+143; 2025:+155; 2026:+64 | seg=91%(116) ter=72%(116) qua=82%(108) qui=82%(128) sex=85%(112) |
| COMPRA | 265 | session=ASIA & mtf_D1=BEARISH | 2024-03-14 | 2026-10-15 | 2024:+88; 2025:+109; 2026:+65 | seg=88%(920) ter=73%(928) qua=77%(864) qui=81%(1024) sex=80%(896) |
| COMPRA | 265 | mtf_D1=BEARISH & hour_srv=8 | 2024-03-14 | 2026-10-15 | 2024:+111; 2025:+160; 2026:+85 | seg=88%(112) ter=76%(116) qua=83%(108) qui=78%(128) sex=84%(112) |


---

## Resumo

| ativo | tipo | resultado |
|---|---|---|
| XAGUSD | horários puros | 0 |
| XAGUSD | horário + condição | 5 famílias nos filtros |
| EURJPY | horários puros | 42 (placebo máx 33) |
| EURJPY | horário + condição | 226 famílias nos filtros |
| GBPJPY | horários puros | 71 (placebo máx 71) |
| GBPJPY | horário + condição | 277 famílias nos filtros |

## Limites

- Caminho do preço medido em candles M15. Período 2024-01 a 2026-10 (708 dias); validação = últimos 40%. - A perda dos dias sem alvo usa o fechamento das 23:30; carregar a posição para o dia seguinte não está incluído. - Comissão, slippage e swap não incluídos. - Condições de volatilidade (`ambos os lados`) não dizem a direção: dependem de você escolher o lado, e o risco sem stop está nas colunas de perda.
