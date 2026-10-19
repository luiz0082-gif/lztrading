# Padrões intraday dos pares (sem XAUUSD e BTCUSD) — entrada no horário, saída no alvo ou às 23:30 do servidor, sem stop

**Regra:** entra na abertura da vela M15 do horário (hora do servidor), fecha quando o preço faz o alvo a favor ou às **23:30** do servidor (fechamento da vela 23:15). Sem stop; 1 operação por dia útil. **Os alvos são proporcionais à volatilidade de cada par** (25%, 50%, 100% e 200% do ATR M15, mais 300 pontos); o `ATR M15` e os alvos testados estão no topo de cada ativo. 300 pts em FX = 30 pips. Londres = servidor−2h; NY = servidor−7h. Custo = spread medido nos ticks; comissão e slippage não incluídos.

## Como ler

- `pct_alvo` = % dos dias em que o alvo foi atingido; `pct_base_val` = % que **qualquer** horário atinge no mesmo período (para ver quanto a condição melhora). `perda_media_sem_alvo` = resultado médio dos dias em que o alvo NÃO foi atingido (medido em todos os horários); `pct_necessario_p_empatar` = % de acerto necessário para empatar com essa perda; `ev_estresse_pts` = expectativa por operação usando o limite inferior 95% da taxa de acerto; `media_real_pts` = média efetivamente obtida; `pior_dia_pts` e `mae_medio/p90` = o risco sem stop (quanto o preço anda contra você).
- Cada condição é comparada com o resto **do mesmo mês** (remove tendência e regime) e é testada contra um placebo (resultados deslocados no tempo).
- `ambos os lados` = a mesma condição também funciona na direção oposta: é uma condição de **volatilidade** (dia que anda muito), não de direção. Famílias com `month=` ou `dom_w=` foram removidas da lista (poucas amostras por mês, 2 a 3 anos).
- `melhores_horas` = horas do servidor (entrada em qualquer vela M15 dentro da hora) em que a condição, além de valer, tem taxa de acerto acima da média do próprio padrão e resultado médio positivo (n ≥ 25 por hora); `dias_por_ano` = quantos dias do ano a condição aparece; `entradas_por_dia` = quantas velas M15 do mesmo dia a satisfazem (cada vela é uma entrada separada nos números). Para operar, escolha UMA entrada por dia dentro de `melhores_horas`.
- Filtros da lista B: pelo menos 60 dias distintos com o sinal (as entradas do mesmo dia não são independentes), n ≥ 250, taxa de acerto na validação ≥ 8 pontos percentuais acima da base, positivo em todos os anos, média real > 0 e duas metades da validação positivas.


---

## USDJPY

ATR M15 mediano = 99 pts; alvos testados: [25, 50, 100, 200, 300] pts

**Horários puros que passaram:** 17 (placebo: média 12.0, máx 33). Não se distingue do acaso.

**Horário + condição:** 99,680 hipóteses; confirmadas na validação **4,432**; placebo: confirmadas média 16.0, máximo 75.

### A. Horários puros

_Não se distingue do acaso; listado só para conferência._

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | 01:30–01:45 | 23:30 | 709 | 64.2 | 60.6 | 299.1 | -227.9 | 43.2 | 91.4 | 3.7 | -3,951.8 | 499.8 | 1,245.4 | 300.0 | 2/3 | 19/34 | 2 |
| COMPRA | 200 | 01:15–01:45 | 23:30 | 709 | 75.7 | 72.5 | 199.1 | -260.6 | 56.7 | 72.5 | 12.7 | -3,428.8 | 405.1 | 1,065.6 | 165.0 | 2/3 | 22/34 | 3 |
| COMPRA | 200 | 04:15–04:30 | 02:30 | 710 | 75.6 | 72.3 | 199.2 | -260.6 | 56.7 | 72.0 | 12.0 | -3,081.8 | 376.6 | 979.4 | 225.0 | 2/3 | 22/34 | 2 |
| COMPRA | 200 | 03:15 | 01:15 | 710 | 73.9 | 70.6 | 199.0 | -260.6 | 56.7 | 63.8 | 5.2 | -3,484.0 | 394.3 | 1,069.1 | 150.0 | 2/3 | 18/34 | 1 |
| COMPRA | 100 | 04:15–04:30 | 02:15 | 710 | 88.2 | 85.6 | 99.2 | -297.6 | 75.0 | 42.0 | 12.9 | -2,832.8 | 252.9 | 722.8 | 75.0 | 3/3 | 18/34 | 2 |
| COMPRA | 100 | 09:15 | 07:15 | 710 | 87.6 | 85.0 | 99.0 | -297.6 | 75.0 | 39.4 | 10.9 | -4,154.0 | 242.5 | 588.6 | 60.0 | 2/3 | 24/34 | 1 |
| COMPRA | 100 | 02:00–02:15 | 00:15 | 710 | 87.3 | 84.7 | 99.0 | -297.6 | 75.0 | 38.2 | 4.2 | -2,189.0 | 283.1 | 872.8 | 60.0 | 2/3 | 18/34 | 2 |
| COMPRA | 50 | 04:15 | 02:15 | 710 | 94.1 | 92.1 | 49.2 | -318.9 | 86.6 | 20.1 | 2.3 | -2,832.8 | 171.9 | 435.2 | 30.0 | 2/3 | 20/34 | 1 |
| COMPRA | 50 | 03:15 | 01:15 | 710 | 93.9 | 91.9 | 49.0 | -318.9 | 86.7 | 19.3 | 1.5 | -3,180.0 | 192.5 | 529.6 | 15.0 | 2/3 | 20/34 | 1 |
| COMPRA | 25 | 05:15 | 03:15 | 710 | 97.9 | 96.5 | 24.1 | -346.3 | 93.5 | 11.3 | 6.2 | -2,557.9 | 99.2 | 222.4 | 15.0 | 3/3 | 26/34 | 1 |
| VENDA | 25 | 12:00 | 10:00 | 711 | 96.2 | 94.5 | 24.1 | -328.2 | 93.2 | 4.8 | 4.1 | -2,377.2 | 94.7 | 217.0 | 15.0 | 2/3 | 22/34 | 1 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| COMPRA | 300 | 01:30–01:45 | 2024:+39; 2025:-29; 2026:+3 | seg=60%(142) ter=66%(143) qua=64%(140) qui=67%(141) sex=64%(143) |
| COMPRA | 200 | 01:15–01:45 | 2024:+42; 2025:-33; 2026:+35 | seg=70%(142) ter=80%(143) qua=79%(140) qui=76%(141) sex=74%(143) |
| COMPRA | 200 | 04:15–04:30 | 2024:-6; 2025:+8; 2026:+38 | seg=75%(142) ter=75%(143) qua=77%(141) qui=79%(141) sex=72%(143) |
| COMPRA | 200 | 03:15 | 2024:+42; 2025:-39; 2026:+17 | seg=73%(142) ter=73%(143) qua=72%(141) qui=78%(141) sex=74%(143) |
| COMPRA | 100 | 04:15–04:30 | 2024:+26; 2025:+2; 2026:+11 | seg=87%(142) ter=89%(143) qua=88%(141) qui=92%(141) sex=85%(143) |
| COMPRA | 100 | 09:15 | 2024:-3; 2025:+30; 2026:+5 | seg=90%(142) ter=87%(143) qua=89%(141) qui=89%(141) sex=83%(143) |
| COMPRA | 100 | 02:00–02:15 | 2024:-4; 2025:+1; 2026:+18 | seg=85%(142) ter=89%(143) qua=87%(141) qui=89%(141) sex=87%(143) |
| COMPRA | 50 | 04:15 | 2024:+10; 2025:+1; 2026:-5 | seg=94%(142) ter=96%(143) qua=93%(141) qui=95%(141) sex=93%(143) |
| COMPRA | 50 | 03:15 | 2024:+11; 2025:-13; 2026:+8 | seg=92%(142) ter=97%(143) qua=94%(141) qui=91%(141) sex=94%(143) |
| COMPRA | 25 | 05:15 | 2024:+4; 2025:+9; 2026:+5 | seg=99%(142) ter=99%(143) qua=99%(141) qui=99%(141) sex=94%(143) |
| VENDA | 25 | 12:00 | 2024:-2; 2025:+6; 2026:+10 | seg=95%(143) ter=97%(143) qua=96%(141) qui=96%(141) sex=97%(143) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- COMPRA 01:30 alvo 300: 10-07 +299*; 10-08 +299*; 10-09 +299*; 10-12 +299*; 10-13 -276; 10-14 +299*; 10-15 -130; 10-16 -88
- COMPRA 01:30 alvo 200: 10-07 +199*; 10-08 +199*; 10-09 +199*; 10-12 +199*; 10-13 -276; 10-14 +199*; 10-15 -130; 10-16 +199*
- COMPRA 04:30 alvo 200: 10-07 -334; 10-08 +199*; 10-09 +199*; 10-12 +199*; 10-13 -117; 10-14 +199*; 10-15 +199*; 10-16 +199*
- COMPRA 03:15 alvo 200: 10-07 -403; 10-08 +199*; 10-09 +199*; 10-12 +199*; 10-13 -184; 10-14 +199*; 10-15 +199*; 10-16 -186
- COMPRA 04:15 alvo 100: 10-07 -446; 10-08 +99*; 10-09 +99*; 10-12 +99*; 10-13 -60; 10-14 +99*; 10-15 +99*; 10-16 +99*
- COMPRA 09:15 alvo 100: 10-07 -317; 10-08 +99*; 10-09 +99*; 10-12 +99*; 10-13 +99*; 10-14 +99*; 10-15 +99*; 10-16 +99*

### B. Horário + condição

Famílias que passam nos filtros: **153**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | session=ASIA & mtf_H4=BREAK_DOWN | 03h-04h; 07h; 10h | 61 | 24.2 | 15.5 | direcional | 948 | 70.9 | 69.8 | 38.9 | -227.9 | 43.2 | 130.0 | 31.8 | -3,050.9 | 540.6 | 1,336.3 | 165.0 | sim | 3/3 | 21/28 | 1 |
| COMPRA | 300 | session=ASIA & mtf_W1=BEARISH | 03h-06h | 145 | 55.8 | 32.0 | direcional | 4,640 | 69.2 | 55.6 | 38.9 | -227.9 | 43.2 | 129.5 | 42.6 | -4,260.0 | 455.5 | 1,139.0 | 240.0 | sim | 3/3 | 7/11 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 04h | 193 | 70.8 | 4.0 | direcional | 772 | 70.2 | 67.8 | 38.9 | -227.9 | 43.2 | 124.7 | 44.7 | -3,081.8 | 466.0 | 1,251.9 | 300.0 | sim | 3/3 | 22/33 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 02h | 208 | 76.4 | 4.0 | direcional | 832 | 69.7 | 70.7 | 38.9 | -227.9 | 43.2 | 122.5 | 33.7 | -2,282.0 | 519.4 | 1,295.7 | 180.0 | sim | 3/3 | 24/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 03h | 208 | 76.4 | 4.0 | direcional | 832 | 69.1 | 69.2 | 38.9 | -227.9 | 43.3 | 119.3 | 50.8 | -2,181.0 | 501.9 | 1,189.5 | 270.0 | sim | 3/3 | 25/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=6 | 06h | 193 | 70.8 | 4.0 | direcional | 772 | 69.2 | 68.5 | 38.9 | -227.9 | 43.2 | 119.0 | 47.3 | -2,996.9 | 451.0 | 1,189.6 | 262.5 | sim | 3/3 | 20/33 | 1 |
| COMPRA | 300 | session=OFF_SESSION & mtf_H1=BEARISH |  | 275 | 101.5 | 7.0 | direcional | 1,917 | 70.3 | 66.0 | 38.9 | -227.9 | 44.8 | 118.8 | 13.9 | -3,120.0 | 514.0 | 1,410.4 | 240.0 | sim | 3/3 | 19/34 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_since_last_high=Q3 | 01h-05h; 07h | 108 | 42.9 | 18.1 | direcional | 1,960 | 68.6 | 55.1 | 38.9 | -227.9 | 43.9 | 117.6 | 47.5 | -2,515.0 | 474.2 | 1,260.3 | 225.0 | sim | 3/3 | 12/20 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_since_last_high=Q4 | 04h-09h | 103 | 40.9 | 20.7 | direcional | 2,127 | 67.2 | 53.5 | 38.9 | -227.9 | 43.2 | 115.7 | 64.4 | -2,244.0 | 434.9 | 1,057.4 | 210.0 | sim | 3/3 | 15/19 | 1 |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q4 | 03h | 181 | 66.9 | 2.2 | direcional | 401 | 73.6 | 70.1 | 37.3 | -296.0 | 49.7 | 114.8 | 63.3 | -1,972.2 | 370.3 | 1,077.0 | 225.0 | sim | 3/3 | 19/32 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=5 | 05h | 193 | 70.8 | 4.0 | direcional | 772 | 68.3 | 65.2 | 38.9 | -227.9 | 43.2 | 114.1 | 42.5 | -3,038.9 | 454.1 | 1,259.1 | 285.0 | sim | 3/3 | 22/33 | 1 |
| COMPRA | 300 | hour_srv=2 & p1=Q1 | 02h | 487 | 178.4 | 1.5 | direcional | 727 | 68.4 | 62.7 | 38.9 | -227.9 | 43.2 | 114.0 | 39.9 | -3,388.0 | 477.1 | 1,172.2 | 270.0 | sim | 3/3 | 24/34 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=4 | 04h | 181 | 71.6 | 4.0 | direcional | 724 | 68.2 | 61.8 | 38.9 | -227.9 | 43.2 | 113.4 | 38.3 | -2,099.8 | 475.9 | 1,255.5 | 285.0 | sim | 3/3 | 16/21 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=7 | 07h | 181 | 71.6 | 4.0 | direcional | 724 | 68.2 | 60.9 | 38.9 | -227.9 | 43.2 | 113.3 | 60.5 | -3,050.9 | 451.3 | 1,144.7 | 240.0 | sim | 3/3 | 17/21 | 1 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=8 | 08h | 181 | 71.6 | 4.0 | direcional | 724 | 67.7 | 60.9 | 38.9 | -227.9 | 43.2 | 110.3 | 61.9 | -3,012.0 | 435.0 | 1,107.4 | 195.0 | sim | 3/3 | 16/21 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| COMPRA | 300 | session=ASIA & mtf_H4=BREAK_DOWN | 03h:52x 81% +37 | 04h:140x 74% +33 | 05h:140x 67% +12 | 06h:140x 70% +57 | 07h:140x 74% +61 | 08h:120x 64% -47 | 09h:120x 71% +30 | 10h:84x 74% +102 |
| COMPRA | 300 | session=ASIA & mtf_W1=BEARISH | 03h:580x 70% +10 | 04h:580x 71% +30 | 05h:580x 72% +45 | 06h:580x 70% +61 | 07h:580x 67% +51 | 08h:580x 68% +38 | 09h:580x 67% +36 | 10h:580x 69% +70 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 04h:772x 70% +45 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 02h:832x 70% +34 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 03h:832x 69% +51 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=6 | 06h:772x 69% +47 |
| COMPRA | 300 | session=OFF_SESSION & mtf_H1=BEARISH | 00h:313x 74% -55 | 01h:1016x 69% +9 | 02h:588x 70% +59 |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_since_last_high=Q3 | 00h:164x 72% -22 | 01h:261x 74% +39 | 02h:283x 74% +59 | 03h:310x 73% +32 | 04h:301x 73% +86 | 05h:202x 69% +37 | 06h:138x 67% +62 | 07h:128x 70% +106 | 08h:48x 62% +69 | 09h:17x 65% +149 | 22h:25x 0% +2 | 23h:50x 0% -3 |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_since_last_high=Q4 | 03h:34x 65% +20 | 04h:84x 70% +67 | 05h:202x 75% +101 | 06h:266x 71% +76 | 07h:276x 71% +78 | 08h:339x 70% +97 | 09h:311x 70% +97 | 10h:234x 66% +43 | 11h:151x 54% -8 | 12h:129x 53% -3 | 13h:68x 51% -43 | 14h:27x 44% -14 |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q4 | 03h:401x 74% +63 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=5 | 05h:772x 68% +42 |
| COMPRA | 300 | hour_srv=2 & p1=Q1 | 02h:727x 68% +40 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=4 | 04h:724x 68% +38 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=7 | 07h:724x 68% +61 |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=8 | 08h:724x 68% +62 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| COMPRA | 300 | session=ASIA & mtf_H4=BREAK_DOWN | 2024-02-29 | 2026-09-08 | 2024:+18; 2025:+14; 2026:+89 | seg=61%(236) ter=72%(112) qua=67%(212) qui=70%(260) sex=94%(128) |
| COMPRA | 300 | session=ASIA & mtf_W1=BEARISH | 2024-03-11 | 2026-10-16 | 2024:+89; 2025:+13; 2026:+56 | seg=70%(928) ter=57%(928) qua=80%(928) qui=71%(928) sex=68%(928) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 2024-01-24 | 2026-10-16 | 2024:+40; 2025:+36; 2026:+68 | seg=75%(152) ter=70%(172) qua=66%(156) qui=81%(128) sex=62%(164) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 2024-01-25 | 2026-10-16 | 2024:+11; 2025:+18; 2026:+106 | seg=57%(168) ter=75%(184) qua=71%(164) qui=76%(136) sex=70%(180) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 2024-01-25 | 2026-10-16 | 2024:+58; 2025:+6; 2026:+144 | seg=65%(168) ter=70%(184) qua=70%(164) qui=74%(136) sex=68%(180) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=6 | 2024-01-24 | 2026-10-16 | 2024:+1; 2025:+67; 2026:+76 | seg=66%(152) ter=59%(172) qua=72%(156) qui=85%(128) sex=68%(164) |
| COMPRA | 300 | session=OFF_SESSION & mtf_H1=BEARISH | 2024-01-23 | 2026-10-09 | 2024:+9; 2025:+21; 2026:+9 | seg=63%(374) ter=69%(315) qua=71%(440) qui=74%(371) sex=74%(417) |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_since_last_high=Q3 | 2024-03-13 | 2026-09-18 | 2024:+67; 2025:+35; 2026:+43 | ter=78%(170) qua=65%(490) qui=70%(678) sex=68%(616) |
| COMPRA | 300 | mtf_D1=BEARISH & news_min_since_last_high=Q4 | 2024-03-13 | 2026-09-18 | 2024:+88; 2025:+45; 2026:+68 | ter=59%(189) qua=72%(489) qui=68%(714) sex=66%(735) |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q4 | 2024-01-31 | 2026-10-15 | 2024:+52; 2025:+73; 2026:+61 | seg=71%(161) ter=79%(47) qua=66%(53) qui=80%(75) sex=75%(65) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=5 | 2024-01-24 | 2026-10-16 | 2024:+18; 2025:+50; 2026:+64 | seg=68%(152) ter=64%(172) qua=65%(156) qui=81%(128) sex=66%(164) |
| COMPRA | 300 | hour_srv=2 & p1=Q1 | 2024-01-23 | 2026-10-16 | 2024:+47; 2025:+11; 2026:+75 | seg=64%(134) ter=66%(137) qua=68%(144) qui=72%(153) sex=70%(159) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=4 | 2024-03-12 | 2026-09-21 | 2024:+66; 2025:+3; 2026:+64 | seg=65%(140) ter=74%(140) qua=64%(160) qui=69%(144) sex=70%(140) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=7 | 2024-03-12 | 2026-09-21 | 2024:+120; 2025:+7; 2026:+78 | seg=64%(140) ter=69%(140) qua=69%(160) qui=69%(144) sex=70%(140) |
| COMPRA | 300 | mtf_D1=BEARISH & hour_srv=8 | 2024-03-12 | 2026-09-21 | 2024:+90; 2025:+17; 2026:+101 | seg=68%(140) ter=64%(140) qua=69%(160) qui=67%(144) sex=71%(140) |


---

## NZDUSD

ATR M15 mediano = 44 pts; alvos testados: [10, 20, 45, 90, 300] pts

**Horários puros que passaram:** 5 (placebo: média 4.0, máx 10). Não se distingue do acaso.

**Horário + condição:** 98,680 hipóteses; confirmadas na validação **3,165**; placebo: confirmadas média 3.8, máximo 6.

### A. Horários puros

_Não se distingue do acaso; listado só para conferência._

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 90 | 10:30 | 08:30 | 711 | 71.2 | 67.7 | 86.6 | -135.0 | 60.9 | 15.1 | 2.1 | -864.5 | 138.8 | 361.0 | 180.0 | 2/3 | 22/34 | 1 |
| VENDA | 45 | 09:45 | 07:45 | 711 | 85.9 | 83.2 | 41.7 | -147.4 | 78.0 | 9.9 | 0.4 | -820.5 | 101.7 | 287.0 | 45.0 | 1/3 | 19/34 | 1 |
| COMPRA | 45 | 13:00 | 11:00 | 711 | 84.0 | 81.1 | 41.7 | -142.9 | 77.4 | 6.8 | 0.7 | -1,088.3 | 97.5 | 257.0 | 90.0 | 2/3 | 19/34 | 1 |
| COMPRA | 45 | 12:15 | 10:15 | 711 | 83.8 | 80.9 | 41.7 | -142.9 | 77.4 | 6.5 | 1.2 | -878.3 | 95.5 | 257.0 | 90.0 | 2/3 | 21/34 | 1 |
| COMPRA | 20 | 11:45 | 09:45 | 711 | 93.2 | 91.2 | 16.7 | -150.3 | 90.0 | 2.0 | 1.1 | -630.2 | 64.1 | 173.0 | 30.0 | 2/3 | 19/34 | 1 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| VENDA | 90 | 10:30 | 2024:+7; 2025:+2; 2026:-4 | seg=69%(143) ter=72%(143) qua=77%(141) qui=72%(141) sex=66%(143) |
| VENDA | 45 | 09:45 | 2024:+8; 2025:-2; 2026:-6 | seg=83%(143) ter=87%(143) qua=91%(141) qui=86%(141) sex=83%(143) |
| COMPRA | 45 | 13:00 | 2024:-3; 2025:+3; 2026:+2 | seg=78%(143) ter=83%(143) qua=84%(141) qui=85%(141) sex=90%(143) |
| COMPRA | 45 | 12:15 | 2024:+2; 2025:-4; 2026:+7 | seg=79%(143) ter=85%(143) qua=84%(141) qui=83%(141) sex=88%(143) |
| COMPRA | 20 | 11:45 | 2024:+0; 2025:-1; 2026:+5 | seg=89%(143) ter=95%(143) qua=96%(141) qui=93%(141) sex=94%(143) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- VENDA 10:30 alvo 90: 10-07 +87*; 10-08 +87*; 10-09 +87*; 10-12 +87*; 10-13 -126; 10-14 +87*; 10-15 +87*; 10-16 +87*
- VENDA 09:45 alvo 45: 10-07 +42*; 10-08 +42*; 10-09 +42*; 10-12 +42*; 10-13 -164; 10-14 +42*; 10-15 +42*; 10-16 +42*
- COMPRA 13:00 alvo 45: 10-07 -59; 10-08 +42*; 10-09 +42*; 10-12 -133; 10-13 +42*; 10-14 -282; 10-15 +42*; 10-16 +42*
- COMPRA 12:15 alvo 45: 10-07 -60; 10-08 +42*; 10-09 +42*; 10-12 -168; 10-13 +42*; 10-14 -268; 10-15 +42*; 10-16 -204
- COMPRA 11:45 alvo 20: 10-07 +17*; 10-08 +17*; 10-09 +17*; 10-12 -151; 10-13 +17*; 10-14 -303; 10-15 +17*; 10-16 +17*

### B. Horário + condição

Famílias que passam nos filtros: **114**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | session=OFF_SESSION & pcum10=Q4 | 00h | 498 | 183.2 | 2.7 | direcional | 1,352 | 36.0 | 36.7 | 17.3 | -71.3 | 19.4 | 51.9 | 22.5 | -975.5 | 224.6 | 480.8 | 675.0 | sim | 3/3 | 22/34 | 1 |
| VENDA | 90 | day_of_week=MONDAY & session=OFF_SESSION | 01h-02h | 143 | 52.5 | 7.9 | direcional | 1,131 | 86.3 | 85.0 | 57.3 | -135.0 | 61.4 | 50.1 | 31.0 | -872.5 | 126.3 | 367.0 | 165.0 | sim | 3/3 | 25/34 | 1 |
| VENDA | 90 | day_of_week=MONDAY & hour_srv=1 | 01h | 143 | 52.5 | 4.0 | direcional | 566 | 86.4 | 84.8 | 57.3 | -135.0 | 60.9 | 49.6 | 32.8 | -872.5 | 127.2 | 370.0 | 180.0 | sim | 3/3 | 27/34 | 1 |
| COMPRA | 300 | news_min_to_next_high=Q3 & atr_ratio_prev=Q4 | 04h-05h; 08h-09h | 283 | 104.0 | 6.0 | direcional | 1,690 | 35.4 | 34.2 | 15.7 | -74.2 | 20.0 | 48.7 | 34.6 | -759.5 | 194.7 | 425.2 | 600.0 | sim | 3/3 | 21/34 | 1 |
| VENDA | 300 | mtf_M15=BULLISH & hour_srv=3 | 03h | 374 | 137.0 | 2.4 | direcional | 883 | 35.7 | 34.2 | 17.3 | -71.3 | 19.4 | 48.5 | 10.1 | -929.5 | 228.8 | 493.8 | 720.0 | sim | 3/3 | 20/34 | 2 |
| VENDA | 300 | session=OFF_SESSION & mtf_M15=RANGE | 02h | 493 | 181.5 | 3.1 | direcional | 1,526 | 34.7 | 34.8 | 17.3 | -71.3 | 19.4 | 47.5 | 10.9 | -1,027.5 | 228.3 | 502.0 | 735.0 | sim | 3/3 | 22/34 | 2 |
| VENDA | 300 | mtf_W1=RANGE & hour_srv=2 | 02h | 219 | 84.9 | 4.0 | direcional | 874 | 34.0 | 34.6 | 17.3 | -71.3 | 19.4 | 42.4 | 14.7 | -904.5 | 223.2 | 482.7 | 660.0 | sim | 3/3 | 11/21 | 1 |
| VENDA | 90 | day_of_week=MONDAY & hour_srv=2 | 02h | 142 | 52.5 | 4.0 | direcional | 565 | 82.8 | 81.2 | 57.3 | -135.0 | 60.9 | 41.1 | 21.5 | -865.5 | 134.6 | 360.6 | 150.0 | sim | 3/3 | 24/34 | 1 |
| VENDA | 300 | news_min_to_next_high=Q4 & atr_ratio_prev=Q1 | 00h-04h | 361 | 132.8 | 7.7 | direcional | 2,771 | 32.2 | 31.5 | 17.3 | -71.3 | 19.4 | 40.5 | 12.0 | -1,043.5 | 207.2 | 486.0 | 780.0 | sim | 3/3 | 15/34 | 1 |
| VENDA | 300 | mtf_W1=BULLISH & news_min_to_next_high=Q2 | 08h-10h | 133 | 58.7 | 18.5 | direcional | 2,461 | 31.7 | 41.7 | 17.3 | -71.3 | 19.4 | 38.5 | 22.7 | -905.5 | 200.2 | 443.0 | 390.0 | sim | 3/3 | 10/16 | 1 |
| COMPRA | 300 | session=ASIA & atr_ratio_prev=Q4 | 04h-05h; 08h-09h | 530 | 194.2 | 7.5 | direcional | 3,973 | 31.0 | 30.2 | 15.7 | -74.2 | 20.0 | 35.6 | 15.6 | -989.5 | 202.0 | 430.8 | 570.0 | sim | 3/3 | 20/34 | 1 |
| VENDA | 90 | hour_srv=1 & pcum10=Q4 | 01h | 338 | 124.3 | 2.0 | direcional | 665 | 80.2 | 81.2 | 57.3 | -135.0 | 61.0 | 35.4 | 18.3 | -975.5 | 150.5 | 391.0 | 195.0 | sim | 3/3 | 25/34 | 1 |
| VENDA | 90 | structure_before=RANGE & hour_srv=2 | 02h | 389 | 142.8 | 2.2 | direcional | 866 | 79.0 | 78.6 | 57.3 | -135.0 | 61.0 | 33.6 | 10.1 | -895.5 | 150.2 | 397.5 | 165.0 | sim | 3/3 | 23/34 | 2 |
| COMPRA | 90 | news_min_to_next_high=Q3 & atr_ratio_prev=Q4 | 04h; 07h-09h | 283 | 104.0 | 6.0 | direcional | 1,690 | 77.4 | 75.6 | 55.6 | -132.8 | 60.6 | 32.4 | 11.9 | -759.5 | 139.5 | 350.2 | 195.0 | sim | 3/3 | 25/34 | 1 |
| VENDA | 90 | mtf_H4=BEARISH & hour_srv=2 | 02h | 245 | 90.8 | 4.0 | direcional | 978 | 77.9 | 77.1 | 57.3 | -135.0 | 60.9 | 31.6 | 9.6 | -904.5 | 152.7 | 397.3 | 165.0 | sim | 3/3 | 20/34 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| VENDA | 300 | session=OFF_SESSION & pcum10=Q4 | 00h:190x 42% +37 | 01h:665x 35% +20 | 02h:497x 35% +20 |
| VENDA | 90 | day_of_week=MONDAY & session=OFF_SESSION | 00h:168x 84% +16 | 01h:566x 86% +33 | 02h:397x 87% +35 |
| VENDA | 90 | day_of_week=MONDAY & hour_srv=1 | 01h:566x 86% +33 |
| COMPRA | 300 | news_min_to_next_high=Q3 & atr_ratio_prev=Q4 | 03h:68x 26% -105 | 04h:148x 43% +65 | 05h:357x 44% +59 | 06h:493x 33% +22 | 07h:371x 32% +24 | 08h:122x 39% +72 | 09h:60x 38% +104 | 10h:22x 18% -10 |
| VENDA | 300 | mtf_M15=BULLISH & hour_srv=3 | 03h:883x 36% +10 |
| VENDA | 300 | session=OFF_SESSION & mtf_M15=RANGE | 00h:182x 26% -21 | 01h:712x 33% +5 | 02h:632x 38% +27 |
| VENDA | 300 | mtf_W1=RANGE & hour_srv=2 | 02h:874x 34% +15 |
| VENDA | 90 | day_of_week=MONDAY & hour_srv=2 | 02h:565x 83% +22 |
| VENDA | 300 | news_min_to_next_high=Q4 & atr_ratio_prev=Q1 | 00h:594x 38% +12 | 01h:573x 37% +15 | 02h:609x 36% +14 | 03h:384x 37% +24 | 04h:240x 33% +9 | 05h:29x 24% +51 | 22h:101x 0% -5 | 23h:198x 0% -6 |
| VENDA | 300 | mtf_W1=BULLISH & news_min_to_next_high=Q2 | 08h:247x 46% +62 | 09h:390x 42% +41 | 10h:490x 35% +34 | 11h:520x 30% +24 | 12h:400x 24% +3 | 13h:225x 18% -22 | 14h:76x 12% +3 | 15h:27x 15% -15 | 16h:40x 22% -33 |
| COMPRA | 300 | session=ASIA & atr_ratio_prev=Q4 | 02h:133x 28% +33 | 03h:533x 29% -9 | 04h:427x 36% +39 | 05h:642x 34% +15 | 06h:754x 28% +2 | 07h:551x 28% +8 | 08h:318x 33% +32 | 09h:297x 37% +50 | 10h:318x 28% +17 |
| VENDA | 90 | hour_srv=1 & pcum10=Q4 | 01h:665x 80% +18 |
| VENDA | 90 | structure_before=RANGE & hour_srv=2 | 02h:866x 79% +10 |
| COMPRA | 90 | news_min_to_next_high=Q3 & atr_ratio_prev=Q4 | 03h:68x 71% -35 | 04h:148x 78% +21 | 05h:357x 77% +5 | 06h:493x 77% +5 | 07h:371x 81% +19 | 08h:122x 80% +37 | 09h:60x 85% +50 | 10h:22x 73% +35 |
| VENDA | 90 | mtf_H4=BEARISH & hour_srv=2 | 02h:978x 78% +10 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| VENDA | 300 | session=OFF_SESSION & pcum10=Q4 | 2024-01-25 | 2026-10-14 | 2024:+8; 2025:+41; 2026:+17 | seg=24%(199) ter=33%(263) qua=37%(273) qui=40%(326) sex=42%(291) |
| VENDA | 90 | day_of_week=MONDAY & session=OFF_SESSION | 2024-01-23 | 2026-10-13 | 2024:+17; 2025:+49; 2026:+26 | ter=86%(1131) |
| VENDA | 90 | day_of_week=MONDAY & hour_srv=1 | 2024-01-23 | 2026-10-13 | 2024:+22; 2025:+49; 2026:+26 | ter=86%(566) |
| COMPRA | 300 | news_min_to_next_high=Q3 & atr_ratio_prev=Q4 | 2024-01-24 | 2026-10-14 | 2024:+28; 2025:+51; 2026:+23 | seg=23%(192) ter=24%(365) qua=44%(404) qui=33%(482) sex=53%(247) |
| VENDA | 300 | mtf_M15=BULLISH & hour_srv=3 | 2024-01-23 | 2026-10-16 | 2024:+13; 2025:+3; 2026:+15 | seg=31%(191) ter=36%(140) qua=34%(166) qui=43%(201) sex=34%(185) |
| VENDA | 300 | session=OFF_SESSION & mtf_M15=RANGE | 2024-01-26 | 2026-10-14 | 2024:+17; 2025:+6; 2026:+10 | seg=24%(293) ter=29%(319) qua=45%(356) qui=38%(277) sex=36%(281) |
| VENDA | 300 | mtf_W1=RANGE & hour_srv=2 | 2024-03-18 | 2026-10-16 | 2024:+10; 2025:+5; 2026:+23 | seg=31%(176) ter=29%(174) qua=44%(176) qui=32%(172) sex=34%(176) |
| VENDA | 90 | day_of_week=MONDAY & hour_srv=2 | 2024-01-29 | 2026-10-13 | 2024:+9; 2025:+31; 2026:+24 | seg=73%(168) ter=87%(397) |
| VENDA | 300 | news_min_to_next_high=Q4 & atr_ratio_prev=Q1 | 2024-01-25 | 2026-10-14 | 2024:+1; 2025:+1; 2026:+52 | seg=18%(90) ter=26%(715) qua=33%(870) qui=36%(660) sex=39%(436) |
| VENDA | 300 | mtf_W1=BULLISH & news_min_to_next_high=Q2 | 2024-01-24 | 2026-05-01 | 2024:+5; 2025:+21; 2026:+52 | seg=18%(162) ter=27%(485) qua=34%(674) qui=41%(726) sex=21%(414) |
| COMPRA | 300 | session=ASIA & atr_ratio_prev=Q4 | 2024-01-23 | 2026-10-16 | 2024:+13; 2025:+8; 2026:+31 | seg=27%(962) ter=25%(786) qua=43%(699) qui=29%(826) sex=34%(700) |
| VENDA | 90 | hour_srv=1 & pcum10=Q4 | 2024-01-25 | 2026-10-14 | 2024:+12; 2025:+24; 2026:+19 | seg=74%(93) ter=89%(140) qua=80%(131) qui=81%(157) sex=75%(144) |
| VENDA | 90 | structure_before=RANGE & hour_srv=2 | 2024-01-23 | 2026-10-14 | 2024:+8; 2025:+13; 2026:+9 | seg=64%(132) ter=83%(174) qua=82%(207) qui=80%(173) sex=82%(180) |
| COMPRA | 90 | news_min_to_next_high=Q3 & atr_ratio_prev=Q4 | 2024-01-24 | 2026-10-14 | 2024:+7; 2025:+19; 2026:+10 | seg=69%(192) ter=78%(365) qua=74%(404) qui=77%(482) sex=90%(247) |
| VENDA | 90 | mtf_H4=BEARISH & hour_srv=2 | 2024-01-24 | 2026-10-06 | 2024:+9; 2025:+15; 2026:+4 | seg=70%(200) ter=85%(199) qua=81%(208) qui=84%(175) sex=69%(196) |


---

## USDCHF

ATR M15 mediano = 49 pts; alvos testados: [10, 25, 50, 100, 300] pts

**Horários puros que passaram:** 5 (placebo: média 8.8, máx 13). Não se distingue do acaso.

**Horário + condição:** 100,330 hipóteses; confirmadas na validação **3,317**; placebo: confirmadas média 15.2, máximo 38.

### A. Horários puros

_Não se distingue do acaso; listado só para conferência._

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 50 | 06:30 | 04:30 | 711 | 88.6 | 86.1 | 48.4 | -178.4 | 78.6 | 16.8 | 1.5 | -1,393.9 | 126.6 | 362.0 | 157.5 | 2/3 | 22/34 | 1 |
| COMPRA | 25 | 04:15 | 02:15 | 710 | 95.8 | 94.0 | 23.2 | -187.2 | 89.0 | 10.7 | 1.0 | -1,515.0 | 80.4 | 200.2 | 30.0 | 1/3 | 21/34 | 1 |
| VENDA | 25 | 02:45 | 00:45 | 710 | 94.4 | 92.4 | 23.0 | -180.5 | 88.7 | 7.6 | 1.5 | -935.0 | 81.9 | 238.0 | 45.0 | 2/3 | 19/34 | 1 |
| VENDA | 25 | 08:45 | 06:45 | 710 | 93.8 | 91.8 | 23.0 | -180.5 | 88.7 | 6.2 | 2.3 | -931.0 | 72.2 | 207.1 | 30.0 | 2/3 | 20/34 | 1 |
| VENDA | 10 | 03:45 | 01:45 | 710 | 98.3 | 97.1 | 8.4 | -188.0 | 95.7 | 2.7 | 2.0 | -907.0 | 40.7 | 88.1 | 15.0 | 2/3 | 24/34 | 1 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| COMPRA | 50 | 06:30 | 2024:+4; 2025:-2; 2026:+3 | seg=84%(143) ter=89%(143) qua=91%(141) qui=91%(141) sex=88%(143) |
| COMPRA | 25 | 04:15 | 2024:-1; 2025:+4; 2026:-0 | seg=96%(142) ter=97%(143) qua=96%(141) qui=98%(141) sex=93%(143) |
| VENDA | 25 | 02:45 | 2024:+2; 2025:+5; 2026:-3 | seg=98%(142) ter=92%(143) qua=91%(141) qui=94%(141) sex=96%(143) |
| VENDA | 25 | 08:45 | 2024:-7; 2025:+10; 2026:+3 | seg=95%(142) ter=92%(143) qua=92%(141) qui=93%(141) sex=97%(143) |
| VENDA | 10 | 03:45 | 2024:+3; 2025:-2; 2026:+5 | seg=100%(142) ter=97%(143) qua=98%(141) qui=99%(141) sex=98%(143) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- COMPRA 06:30 alvo 50: 10-07 +49*; 10-08 +49*; 10-09 +49*; 10-12 +49*; 10-13 -54; 10-14 +49*; 10-15 +49*; 10-16 +49*
- COMPRA 04:15 alvo 25: 10-07 +24*; 10-08 +24*; 10-09 +24*; 10-12 +23*; 10-13 +24*; 10-14 +24*; 10-15 +24*; 10-16 +24*
- VENDA 02:45 alvo 25: 10-07 +23*; 10-08 +24*; 10-09 +23*; 10-12 +23*; 10-13 +24*; 10-14 +23*; 10-15 +23*; 10-16 +24*
- VENDA 08:45 alvo 25: 10-07 +23*; 10-08 +23*; 10-09 +23*; 10-12 +23*; 10-13 +23*; 10-14 -302; 10-15 +23*; 10-16 +23*
- VENDA 03:45 alvo 10: 10-07 +8*; 10-08 +9*; 10-09 +9*; 10-12 +8*; 10-13 +9*; 10-14 +9*; 10-15 +9*; 10-16 +9*

### B. Horário + condição

Famílias que passam nos filtros: **93**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | mtf_M30=BREAK_DOWN & news_min_since_last_high=Q4 | 10h-11h | 110 | 40.4 | 3.6 | direcional | 393 | 56.0 | 48.7 | 19.8 | -113.8 | 27.6 | 96.4 | 73.3 | -1,059.0 | 229.0 | 542.6 | 307.5 | sim | 3/3 | 18/30 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 02h | 233 | 85.9 | 4.0 | direcional | 931 | 42.1 | 35.8 | 21.6 | -98.8 | 24.9 | 55.8 | 19.6 | -1,602.0 | 277.7 | 644.0 | 742.5 | sim | 3/3 | 24/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 03h | 233 | 85.9 | 4.0 | direcional | 932 | 41.5 | 36.1 | 21.6 | -98.8 | 24.9 | 53.5 | 20.4 | -1,598.1 | 273.7 | 628.0 | 720.0 | sim | 3/3 | 25/34 | 1 |
| VENDA | 300 | mtf_M15=BEARISH & news_min_since_last_high=Q4 | 04h-05h; 08h; 10h; 12h | 278 | 102.0 | 8.1 | direcional | 2,242 | 41.2 | 38.4 | 19.8 | -113.8 | 27.6 | 47.6 | 27.0 | -1,080.0 | 239.7 | 546.9 | 360.0 | sim | 3/3 | 20/34 | 2 |
| COMPRA | 100 | day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 03h-07h | 131 | 48.1 | 18.7 | direcional | 2,453 | 82.0 | 85.7 | 60.4 | -164.4 | 62.6 | 46.9 | 23.3 | -1,414.0 | 179.0 | 475.6 | 255.0 | sim | 3/3 | 24/34 | 1 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 04h | 226 | 83.0 | 4.0 | direcional | 904 | 38.9 | 35.2 | 21.6 | -98.8 | 24.9 | 43.4 | 21.5 | -1,574.0 | 257.1 | 602.1 | 660.0 | sim | 3/3 | 23/34 | 1 |
| VENDA | 300 | session=LONDON & mtf_M30=BREAK_DOWN | 10h-11h | 246 | 90.0 | 4.0 | direcional | 990 | 40.5 | 35.7 | 19.8 | -113.8 | 27.6 | 40.6 | 32.8 | -1,878.0 | 197.6 | 414.2 | 210.0 | sim | 3/3 | 20/34 | 1 |
| COMPRA | 100 | mtf_M30=BULLISH & news_min_since_last_high=Q4 | 05h-07h; 14h | 264 | 96.9 | 10.6 | ambos os lados | 2,805 | 79.4 | 79.0 | 60.4 | -164.4 | 62.6 | 39.9 | 21.3 | -1,622.1 | 163.0 | 415.6 | 210.0 | sim | 3/3 | 22/34 | 1 |
| COMPRA | 100 | mtf_M15=RANGE & hour_srv=2 | 02h | 412 | 150.9 | 2.5 | direcional | 1,037 | 80.2 | 79.9 | 60.4 | -164.4 | 62.7 | 39.4 | 9.3 | -1,521.0 | 172.2 | 482.6 | 405.0 | sim | 3/3 | 23/34 | 2 |
| COMPRA | 300 | day_of_week=THURSDAY & mtf_H4=BEARISH | 03h-15h | 107 | 39.3 | 35.8 | direcional | 3,830 | 36.8 | 32.2 | 21.6 | -98.8 | 25.2 | 39.4 | 29.1 | -2,080.0 | 192.7 | 461.0 | 465.0 | sim | 3/3 | 19/33 | 1 |
| COMPRA | 100 | hour_srv=6 & news_min_since_last_high=Q4 | 06h | 278 | 102.2 | 3.9 | direcional | 1,071 | 79.4 | 79.7 | 60.4 | -164.4 | 62.5 | 37.6 | 10.5 | -1,655.0 | 184.7 | 492.0 | 255.0 | sim | 3/3 | 19/34 | 1 |
| COMPRA | 100 | mtf_M15=BULLISH & hour_srv=5 | 05h | 423 | 155.1 | 3.0 | direcional | 1,255 | 79.0 | 78.6 | 60.4 | -164.4 | 62.6 | 37.2 | 18.7 | -1,072.0 | 169.9 | 455.6 | 315.0 | sim | 3/3 | 21/34 | 2 |
| VENDA | 100 | mtf_H4=RANGE & news_min_since_last_high=Q4 | 04h-05h; 13h | 134 | 49.3 | 15.3 | direcional | 2,044 | 78.8 | 76.2 | 56.7 | -167.5 | 63.0 | 37.1 | 25.2 | -1,346.0 | 158.7 | 363.4 | 210.0 | sim | 3/3 | 23/34 | 1 |
| COMPRA | 100 | structure_before=BULLISH & news_min_since_last_high=Q4 | 05h-08h | 324 | 119.8 | 9.4 | direcional | 3,030 | 78.1 | 78.2 | 60.4 | -164.4 | 62.6 | 36.6 | 15.7 | -2,915.0 | 173.3 | 434.0 | 225.0 | sim | 3/3 | 21/34 | 2 |
| COMPRA | 100 | news_min_since_last_high=Q4 & atr_ratio_prev=Q1 | 05h-09h | 313 | 115.1 | 11.4 | direcional | 3,582 | 77.9 | 76.4 | 60.4 | -164.4 | 62.6 | 36.3 | 16.4 | -1,614.0 | 175.9 | 497.0 | 210.0 | sim | 3/3 | 20/34 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| VENDA | 300 | mtf_M30=BREAK_DOWN & news_min_since_last_high=Q4 | 06h:38x 47% +50 | 07h:36x 44% -5 | 08h:39x 41% +19 | 09h:63x 56% -9 | 10h:69x 64% +155 | 11h:56x 62% +175 | 12h:39x 51% +55 | 13h:20x 70% +74 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 02h:931x 42% +20 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 03h:932x 42% +20 |
| VENDA | 300 | mtf_M15=BEARISH & news_min_since_last_high=Q4 | 03h:16x 44% -17 | 04h:43x 63% +93 | 05h:180x 44% +3 | 06h:332x 37% -19 | 07h:304x 39% +37 | 08h:380x 42% +35 | 09h:317x 39% +8 | 10h:238x 45% +44 | 11h:156x 41% +41 | 12h:122x 48% +99 | 13h:72x 39% +28 | 14h:40x 42% -7 |
| COMPRA | 100 | day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 03h:147x 89% +54 | 04h:256x 84% +43 | 05h:407x 85% +35 | 06h:499x 82% +21 | 07h:493x 84% +23 | 08h:325x 82% +12 | 09h:229x 78% -3 | 10h:62x 69% -16 |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 04h:904x 39% +22 |
| VENDA | 300 | session=LONDON & mtf_M30=BREAK_DOWN | 10h:62x 69% +153 | 11h:262x 44% +55 | 12h:208x 39% +33 | 13h:172x 40% +40 | 14h:160x 35% -16 | 15h:126x 29% -19 |
| COMPRA | 100 | mtf_M30=BULLISH & news_min_since_last_high=Q4 | 03h:36x 69% -32 | 04h:75x 71% +5 | 05h:218x 89% +56 | 06h:399x 85% +45 | 07h:431x 81% +30 | 08h:518x 79% +30 | 09h:429x 79% +13 | 10h:275x 75% -9 | 11h:147x 74% +3 | 12h:135x 70% -28 | 13h:90x 71% +0 | 14h:39x 85% +46 |
| COMPRA | 100 | mtf_M15=RANGE & hour_srv=2 | 02h:1037x 80% +9 |
| COMPRA | 300 | day_of_week=THURSDAY & mtf_H4=BEARISH | 00h:161x 41% -86 | 01h:164x 37% -43 | 02h:172x 48% -16 | 03h:156x 60% +89 | 04h:168x 61% +118 | 05h:168x 62% +113 | 06h:168x 61% +115 | 07h:168x 58% +111 | 08h:188x 51% +48 | 09h:188x 53% +61 | 10h:188x 49% +65 | 11h:188x 46% +64 | 12h:164x 40% +10 | 13h:164x 42% +19 | 14h:164x 40% +13 | 15h:164x 38% +39 | 16h:156x 23% +8 | 17h:156x 13% -20 | 18h:156x 5% -18 | 19h:156x 0% -7 | 20h:136x 0% -22 | 21h:134x 0% -22 | 22h:135x 0% -11 | 23h:68x 0% -8 |
| COMPRA | 100 | hour_srv=6 & news_min_since_last_high=Q4 | 06h:1071x 79% +10 |
| COMPRA | 100 | mtf_M15=BULLISH & hour_srv=5 | 05h:1255x 79% +19 |
| VENDA | 100 | mtf_H4=RANGE & news_min_since_last_high=Q4 | 03h:42x 79% +36 | 04h:90x 79% +35 | 05h:228x 82% +28 | 06h:268x 79% +23 | 07h:278x 78% +16 | 08h:323x 79% +27 | 09h:306x 78% +27 | 10h:212x 78% +14 | 11h:120x 75% +9 | 12h:84x 74% +25 | 13h:48x 85% +63 | 14h:22x 91% +86 |
| COMPRA | 100 | structure_before=BULLISH & news_min_since_last_high=Q4 | 03h:68x 66% -10 | 04h:158x 70% +1 | 05h:397x 85% +33 | 06h:399x 82% +40 | 07h:454x 82% +37 | 08h:490x 79% +25 | 09h:354x 78% -0 | 10h:280x 74% -28 | 11h:142x 71% -7 | 12h:148x 66% -28 | 13h:88x 70% +24 | 14h:42x 74% -5 |
| COMPRA | 100 | news_min_since_last_high=Q4 & atr_ratio_prev=Q1 | 03h:26x 62% -60 | 04h:150x 71% -4 | 05h:392x 79% +18 | 06h:460x 81% +25 | 07h:672x 78% +18 | 08h:943x 78% +18 | 09h:712x 79% +21 | 10h:190x 75% +13 | 11h:25x 52% -74 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| VENDA | 300 | mtf_M30=BREAK_DOWN & news_min_since_last_high=Q4 | 2024-01-26 | 2026-10-16 | 2024:+32; 2025:+122; 2026:+44 | ter=45%(22) qua=53%(66) qui=60%(197) sex=52%(108) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=2 | 2024-01-25 | 2026-10-12 | 2024:+6; 2025:+14; 2026:+48 | seg=31%(212) ter=39%(232) qua=51%(167) qui=58%(156) sex=37%(164) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=3 | 2024-01-25 | 2026-10-12 | 2024:+3; 2025:+17; 2026:+48 | seg=33%(212) ter=36%(232) qua=51%(168) qui=60%(156) sex=35%(164) |
| VENDA | 300 | mtf_M15=BEARISH & news_min_since_last_high=Q4 | 2024-01-25 | 2026-10-16 | 2024:+12; 2025:+55; 2026:+12 | seg=0%(16) ter=32%(224) qua=43%(506) qui=39%(758) sex=46%(738) |
| COMPRA | 100 | day_of_week=WEDNESDAY & news_min_to_next_high=Q3 | 2024-01-24 | 2026-10-14 | 2024:+7; 2025:+29; 2026:+34 | qua=82%(2453) |
| COMPRA | 300 | mtf_H4=BEARISH & hour_srv=4 | 2024-01-25 | 2026-10-16 | 2024:+9; 2025:+9; 2026:+59 | seg=28%(196) ter=32%(212) qua=48%(172) qui=61%(168) sex=28%(156) |
| VENDA | 300 | session=LONDON & mtf_M30=BREAK_DOWN | 2024-01-22 | 2026-10-16 | 2024:+27; 2025:+50; 2026:+13 | seg=20%(176) ter=40%(190) qua=52%(162) qui=54%(240) sex=34%(222) |
| COMPRA | 100 | mtf_M30=BULLISH & news_min_since_last_high=Q4 | 2024-01-25 | 2026-10-16 | 2024:+28; 2025:+31; 2026:+3 | seg=88%(16) ter=76%(320) qua=88%(644) qui=84%(834) sex=71%(991) |
| COMPRA | 100 | mtf_M15=RANGE & hour_srv=2 | 2024-01-23 | 2026-10-16 | 2024:+7; 2025:+10; 2026:+11 | seg=76%(208) ter=83%(223) qua=87%(214) qui=81%(172) sex=73%(220) |
| COMPRA | 300 | day_of_week=THURSDAY & mtf_H4=BEARISH | 2024-01-25 | 2026-10-15 | 2024:+9; 2025:+19; 2026:+87 | qui=36%(3401) sex=40%(429) |
| COMPRA | 100 | hour_srv=6 & news_min_since_last_high=Q4 | 2024-01-25 | 2026-10-15 | 2024:+13; 2025:+4; 2026:+15 | ter=74%(144) qua=88%(296) qui=83%(260) sex=72%(367) |
| COMPRA | 100 | mtf_M15=BULLISH & hour_srv=5 | 2024-01-24 | 2026-10-16 | 2024:+20; 2025:+3; 2026:+36 | seg=71%(251) ter=81%(260) qua=83%(271) qui=85%(208) sex=76%(265) |
| VENDA | 100 | mtf_H4=RANGE & news_min_since_last_high=Q4 | 2024-01-26 | 2026-10-15 | 2024:+6; 2025:+46; 2026:+19 | seg=68%(22) ter=63%(289) qua=85%(515) qui=87%(517) sex=75%(701) |
| COMPRA | 100 | structure_before=BULLISH & news_min_since_last_high=Q4 | 2024-01-25 | 2026-10-09 | 2024:+13; 2025:+20; 2026:+13 | seg=95%(21) ter=77%(332) qua=85%(653) qui=82%(933) sex=70%(1091) |
| COMPRA | 100 | news_min_since_last_high=Q4 & atr_ratio_prev=Q1 | 2024-01-25 | 2026-10-14 | 2024:+22; 2025:+11; 2026:+16 | ter=75%(412) qua=87%(942) qui=84%(979) sex=68%(1247) |


---

## AUDUSD

ATR M15 mediano = 47 pts; alvos testados: [10, 25, 45, 95, 300] pts

**Horários puros que passaram:** 0 (placebo: média 0.0, máx 0). Não se distingue do acaso.

**Horário + condição:** 97,320 hipóteses; confirmadas na validação **3,307**; placebo: confirmadas média 34.7, máximo 133.

### A. Horários puros

**Nenhum horário puro passou nos critérios.**


### B. Horário + condição

Famílias que passam nos filtros: **38**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | mtf_M15=BEARISH & hour_srv=1 | 01h | 404 | 148.3 | 2.8 | direcional | 1,120 | 41.4 | 37.6 | 19.5 | -93.1 | 24.9 | 51.4 | 21.6 | -2,998.0 | 245.8 | 527.1 | 675.0 | sim | 3/3 | 25/34 | 2 |
| COMPRA | 300 | session=OFF_SESSION & pcum10=Q2 | 01h | 423 | 155.0 | 2.5 | direcional | 1,078 | 40.6 | 38.1 | 19.5 | -93.1 | 25.6 | 44.3 | 7.5 | -2,912.1 | 242.5 | 518.0 | 630.0 | sim | 3/3 | 21/34 | 1 |
| COMPRA | 300 | mtf_H1=BEARISH & news_min_to_next_high=Q3 | 03h-06h | 265 | 97.3 | 12.4 | direcional | 3,276 | 37.7 | 38.7 | 19.5 | -93.1 | 24.5 | 43.8 | 23.1 | -2,824.0 | 229.0 | 497.5 | 570.0 | sim | 3/3 | 18/34 | 1 |
| COMPRA | 300 | mtf_M30=BEARISH & hour_srv=3 | 03h | 292 | 107.5 | 3.2 | direcional | 932 | 38.2 | 34.8 | 19.5 | -93.1 | 24.6 | 40.1 | 19.8 | -3,022.0 | 245.5 | 524.9 | 690.0 | sim | 3/3 | 24/34 | 1 |
| VENDA | 300 | session=OFF_SESSION & mtf_M15=BULLISH | 00h-01h | 379 | 139.0 | 4.4 | direcional | 1,681 | 37.7 | 38.2 | 21.2 | -99.9 | 25.9 | 36.7 | 15.2 | -1,060.8 | 243.1 | 492.0 | 675.0 | sim | 3/3 | 20/34 | 2 |
| COMPRA | 300 | mtf_W1=RANGE & news_min_since_last_high=Q3 | 01h-03h; 05h | 115 | 42.7 | 18.8 | direcional | 2,158 | 35.9 | 29.2 | 19.5 | -93.1 | 24.9 | 33.6 | 18.7 | -946.7 | 206.1 | 452.0 | 675.0 | sim | 3/3 | 11/17 | 1 |
| VENDA | 300 | session=ASIA & mtf_H4=BREAK_UP | 04h-07h | 81 | 31.1 | 14.8 | direcional | 1,200 | 37.2 | 36.1 | 21.2 | -99.9 | 25.9 | 33.2 | 41.3 | -772.8 | 193.9 | 430.1 | 585.0 | sim | 3/3 | 21/29 | 1 |
| COMPRA | 95 | mtf_M15=BEARISH & hour_srv=2 | 02h | 347 | 127.6 | 2.7 | direcional | 939 | 81.5 | 78.4 | 59.6 | -149.6 | 64.9 | 32.0 | 11.4 | -2,968.2 | 164.5 | 425.0 | 150.0 | sim | 3/3 | 22/34 | 2 |
| VENDA | 300 | session=ASIA & mtf_H1=BREAK_UP | 03h-04h; 06h; 08h | 177 | 64.8 | 6.9 | direcional | 1,225 | 36.7 | 34.4 | 21.2 | -99.9 | 25.9 | 31.7 | 30.2 | -691.8 | 199.2 | 428.6 | 570.0 | sim | 3/3 | 20/33 | 1 |
| COMPRA | 95 | hour_srv=1 & pcum10=Q2 | 01h | 287 | 105.4 | 1.8 | direcional | 529 | 83.7 | 82.2 | 59.6 | -149.6 | 66.3 | 31.6 | 18.1 | -934.9 | 146.0 | 391.0 | 195.0 | sim | 3/3 | 23/34 | 1 |
| COMPRA | 95 | hour_srv=3 & pcum10=Q2 | 03h | 313 | 114.8 | 1.6 | direcional | 497 | 82.1 | 80.6 | 59.6 | -149.6 | 64.8 | 31.5 | 10.0 | -1,096.8 | 157.1 | 405.8 | 135.0 | sim | 3/3 | 21/34 | 1 |
| COMPRA | 300 | session=ASIA & mtf_H1=BEARISH | 03h-06h | 418 | 153.1 | 18.5 | direcional | 7,719 | 33.5 | 32.5 | 19.5 | -93.1 | 24.6 | 30.1 | 12.0 | -2,824.0 | 229.0 | 495.0 | 540.0 | sim | 3/3 | 18/34 | 1 |
| VENDA | 95 | mtf_H1=RANGE & hour_srv=5 | 05h | 158 | 57.9 | 4.0 | direcional | 632 | 80.2 | 71.3 | 56.4 | -151.9 | 65.1 | 27.5 | 26.9 | -701.8 | 130.7 | 318.7 | 225.0 | sim | 3/3 | 26/34 | 1 |
| COMPRA | 95 | mtf_M5=RANGE & hour_srv=5 | 05h | 375 | 137.4 | 1.5 | direcional | 573 | 79.9 | 78.3 | 59.6 | -149.6 | 64.8 | 26.9 | 7.6 | -1,128.7 | 150.0 | 384.2 | 210.0 | sim | 3/3 | 23/34 | 1 |
| VENDA | 95 | day_of_week=MONDAY & hour_srv=2 | 02h | 142 | 52.5 | 4.0 | direcional | 565 | 80.2 | 77.8 | 56.4 | -151.9 | 65.2 | 26.9 | 13.4 | -773.8 | 148.4 | 395.0 | 150.0 | sim | 3/3 | 23/34 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| COMPRA | 300 | mtf_M15=BEARISH & hour_srv=1 | 01h:1120x 41% +22 |
| COMPRA | 300 | session=OFF_SESSION & pcum10=Q2 | 00h:234x 42% -10 | 01h:529x 42% +29 | 02h:315x 38% -15 |
| COMPRA | 300 | mtf_H1=BEARISH & news_min_to_next_high=Q3 | 03h:265x 50% +49 | 04h:443x 42% +28 | 05h:570x 40% +8 | 06h:619x 41% +35 | 07h:666x 35% +20 | 08h:373x 31% +14 | 09h:181x 35% +32 | 10h:61x 31% -41 | 19h:16x 0% +26 | 20h:20x 0% +17 | 21h:16x 0% -8 |
| COMPRA | 300 | mtf_M30=BEARISH & hour_srv=3 | 03h:932x 38% +20 |
| VENDA | 300 | session=OFF_SESSION & mtf_M15=BULLISH | 00h:268x 43% +37 | 01h:853x 38% +14 | 02h:560x 35% +6 |
| COMPRA | 300 | mtf_W1=RANGE & news_min_since_last_high=Q3 | 00h:177x 39% -41 | 01h:286x 38% +28 | 02h:326x 39% +40 | 03h:339x 39% +46 | 04h:336x 34% +34 | 05h:215x 40% +51 | 06h:149x 36% -4 | 07h:122x 34% -27 | 08h:70x 36% -75 | 09h:26x 19% -219 | 22h:24x 0% -12 | 23h:48x 0% -15 |
| VENDA | 300 | session=ASIA & mtf_H4=BREAK_UP | 02h:36x 33% -18 | 03h:108x 33% +43 | 04h:144x 41% +39 | 05h:144x 42% +37 | 06h:144x 42% +50 | 07h:144x 40% +55 | 08h:180x 36% +63 | 09h:180x 32% +32 | 10h:120x 31% +19 |
| COMPRA | 95 | mtf_M15=BEARISH & hour_srv=2 | 02h:939x 81% +11 |
| VENDA | 300 | session=ASIA & mtf_H1=BREAK_UP | 02h:45x 27% -54 | 03h:128x 45% +18 | 04h:180x 42% +28 | 05h:204x 30% -18 | 06h:204x 40% +30 | 07h:128x 32% +28 | 08h:124x 44% +119 | 09h:112x 35% +44 | 10h:100x 26% +65 |
| COMPRA | 95 | hour_srv=1 & pcum10=Q2 | 01h:529x 84% +18 |
| COMPRA | 95 | hour_srv=3 & pcum10=Q2 | 03h:497x 82% +10 |
| COMPRA | 300 | session=ASIA & mtf_H1=BEARISH | 02h:300x 30% -14 | 03h:1128x 38% +17 | 04h:983x 36% +23 | 05h:912x 37% +5 | 06h:916x 37% +23 | 07h:1004x 33% +13 | 08h:916x 30% +14 | 09h:908x 28% -1 | 10h:652x 29% +7 |
| VENDA | 95 | mtf_H1=RANGE & hour_srv=5 | 05h:632x 80% +27 |
| COMPRA | 95 | mtf_M5=RANGE & hour_srv=5 | 05h:573x 80% +8 |
| VENDA | 95 | day_of_week=MONDAY & hour_srv=2 | 02h:565x 80% +13 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| COMPRA | 300 | mtf_M15=BEARISH & hour_srv=1 | 2024-01-23 | 2026-10-14 | 2024:+9; 2025:+30; 2026:+23 | seg=47%(252) ter=32%(220) qua=47%(189) qui=49%(214) sex=33%(245) |
| COMPRA | 300 | session=OFF_SESSION & pcum10=Q2 | 2024-01-23 | 2026-10-16 | 2024:+6; 2025:+15; 2026:+2 | seg=41%(210) ter=38%(193) qua=42%(221) qui=50%(221) sex=32%(233) |
| COMPRA | 300 | mtf_H1=BEARISH & news_min_to_next_high=Q3 | 2024-01-24 | 2026-10-15 | 2024:+22; 2025:+17; 2026:+30 | seg=38%(316) ter=30%(729) qua=38%(718) qui=42%(944) sex=39%(569) |
| COMPRA | 300 | mtf_M30=BEARISH & hour_srv=3 | 2024-01-25 | 2026-10-13 | 2024:+30; 2025:+20; 2026:+11 | seg=33%(210) ter=35%(192) qua=40%(134) qui=48%(212) sex=35%(184) |
| VENDA | 300 | session=OFF_SESSION & mtf_M15=BULLISH | 2024-01-24 | 2026-10-16 | 2024:+11; 2025:+17; 2026:+19 | seg=24%(274) ter=38%(357) qua=40%(363) qui=46%(346) sex=37%(341) |
| COMPRA | 300 | mtf_W1=RANGE & news_min_since_last_high=Q3 | 2024-02-06 | 2026-10-16 | 2024:+7; 2025:+60; 2026:+8 | seg=0%(19) ter=19%(150) qua=45%(439) qui=35%(809) sex=35%(741) |
| VENDA | 300 | session=ASIA & mtf_H4=BREAK_UP | 2024-03-08 | 2026-10-14 | 2024:+56; 2025:+14; 2026:+64 | seg=18%(232) ter=18%(152) qua=52%(328) qui=47%(348) sex=31%(140) |
| COMPRA | 95 | mtf_M15=BEARISH & hour_srv=2 | 2024-01-25 | 2026-10-14 | 2024:+3; 2025:+11; 2026:+20 | seg=87%(199) ter=77%(219) qua=82%(157) qui=85%(188) sex=77%(176) |
| VENDA | 300 | session=ASIA & mtf_H1=BREAK_UP | 2024-01-23 | 2026-10-16 | 2024:+40; 2025:+26; 2026:+24 | seg=24%(233) ter=28%(180) qua=40%(328) qui=52%(288) sex=33%(196) |
| COMPRA | 95 | hour_srv=1 & pcum10=Q2 | 2024-01-23 | 2026-10-14 | 2024:+23; 2025:+24; 2026:+9 | seg=81%(105) ter=78%(78) qua=84%(117) qui=86%(111) sex=87%(118) |
| COMPRA | 95 | hour_srv=3 & pcum10=Q2 | 2024-01-24 | 2026-10-16 | 2024:+3; 2025:+19; 2026:+7 | seg=81%(94) ter=80%(128) qua=87%(97) qui=84%(86) sex=80%(92) |
| COMPRA | 300 | session=ASIA & mtf_H1=BEARISH | 2024-01-23 | 2026-10-16 | 2024:+4; 2025:+5; 2026:+27 | seg=33%(1500) ter=29%(1672) qua=35%(1359) qui=39%(1576) sex=32%(1612) |
| VENDA | 95 | mtf_H1=RANGE & hour_srv=5 | 2024-01-23 | 2026-10-16 | 2024:+36; 2025:+20; 2026:+25 | seg=81%(120) ter=76%(164) qua=83%(128) qui=85%(112) sex=78%(108) |
| COMPRA | 95 | mtf_M5=RANGE & hour_srv=5 | 2024-01-23 | 2026-10-16 | 2024:+6; 2025:+10; 2026:+6 | seg=77%(125) ter=83%(126) qua=75%(93) qui=81%(126) sex=83%(103) |
| VENDA | 95 | day_of_week=MONDAY & hour_srv=2 | 2024-01-29 | 2026-10-13 | 2024:+24; 2025:+4; 2026:+13 | seg=72%(165) ter=84%(400) |


---

## US30

ATR M15 mediano = 3763 pts; alvos testados: [300, 940, 1880, 3765, 7525] pts

**Horários puros que passaram:** 28 (placebo: média 0.8, máx 3). Acima do acaso.

**Horário + condição:** 98,910 hipóteses; confirmadas na validação **320**; placebo: confirmadas média 0.0, máximo 0.

### A. Horários puros

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 7,525 | 02:15 | 00:15 | 708 | 81.5 | 78.5 | 7,398.9 | -18,311.5 | 71.2 | 1,863.3 | 596.7 | -129,580.0 | 15,512.7 | 41,890.0 | 555.0 | 3/3 | 21/34 | 1 |
| COMPRA | 7,525 | 03:15–03:45 | 01:30 | 708 | 81.5 | 78.5 | 7,398.8 | -18,311.5 | 71.2 | 1,863.2 | 479.0 | -236,540.0 | 15,620.6 | 42,827.0 | 525.0 | 2/3 | 21/34 | 3 |
| COMPRA | 7,525 | 04:45 | 02:45 | 708 | 80.6 | 77.6 | 7,399.1 | -18,311.5 | 71.2 | 1,634.2 | 502.7 | -229,490.0 | 15,264.8 | 40,960.5 | 465.0 | 3/3 | 20/34 | 1 |
| COMPRA | 7,525 | 01:30–01:45 | 23:30 | 707 | 80.3 | 77.2 | 7,394.7 | -18,311.5 | 71.2 | 1,546.3 | 583.7 | -88,310.0 | 15,511.3 | 42,616.0 | 585.0 | 3/3 | 19/34 | 2 |
| COMPRA | 7,525 | 14:15–14:30 | 12:15 | 708 | 79.1 | 75.9 | 7,404.6 | -18,311.5 | 71.2 | 1,219.3 | 232.2 | -116,890.0 | 14,582.4 | 38,929.0 | 135.0 | 2/3 | 20/34 | 2 |
| COMPRA | 7,525 | 13:45 | 11:45 | 708 | 78.7 | 75.5 | 7,404.6 | -18,311.5 | 71.2 | 1,105.3 | 235.9 | -117,390.0 | 14,265.2 | 39,333.0 | 150.0 | 2/3 | 20/34 | 1 |
| COMPRA | 7,525 | 15:15–16:15 | 13:15 | 708 | 78.7 | 75.5 | 7,404.4 | -18,311.5 | 71.2 | 1,105.1 | 919.2 | -99,940.0 | 13,985.5 | 36,538.0 | 90.0 | 3/3 | 23/34 | 5 |
| VENDA | 3,765 | 09:45 | 07:45 | 707 | 90.5 | 88.1 | 3,651.8 | -20,121.8 | 84.6 | 832.3 | 237.2 | -123,950.0 | 9,733.1 | 27,362.0 | 90.0 | 1/3 | 22/34 | 1 |
| VENDA | 3,765 | 04:15–04:30 | 02:15 | 708 | 90.3 | 87.8 | 3,651.2 | -20,121.8 | 84.6 | 762.2 | 176.5 | -113,625.0 | 10,167.4 | 31,870.5 | 300.0 | 2/3 | 19/34 | 2 |
| COMPRA | 3,765 | 05:45 | 03:45 | 707 | 90.1 | 87.7 | 3,639.6 | -20,248.8 | 84.8 | 695.6 | 265.1 | -92,000.0 | 10,395.0 | 29,426.0 | 255.0 | 2/3 | 22/34 | 1 |
| COMPRA | 3,765 | 01:15 | 23:15 | 707 | 90.1 | 87.7 | 3,637.0 | -20,248.8 | 84.8 | 693.3 | 268.2 | -72,240.0 | 10,540.3 | 32,134.0 | 180.0 | 2/3 | 19/34 | 1 |
| COMPRA | 3,765 | 04:30 | 02:30 | 708 | 90.0 | 87.5 | 3,639.4 | -20,248.8 | 84.8 | 662.7 | 220.1 | -93,450.0 | 9,779.8 | 26,287.0 | 285.0 | 2/3 | 18/34 | 1 |
| COMPRA | 3,765 | 16:00 | 14:00 | 709 | 89.8 | 87.4 | 3,644.0 | -20,248.8 | 84.7 | 634.1 | 1,055.9 | -86,110.0 | 8,910.3 | 23,818.0 | 45.0 | 3/3 | 27/34 | 1 |
| COMPRA | 3,765 | 01:45 | 23:45 | 708 | 89.8 | 87.4 | 3,637.6 | -20,248.8 | 84.8 | 624.3 | 308.0 | -75,560.0 | 10,442.1 | 31,189.0 | 195.0 | 2/3 | 20/34 | 1 |
| COMPRA | 3,765 | 02:15 | 00:15 | 708 | 89.7 | 87.2 | 3,639.1 | -20,248.8 | 84.8 | 588.8 | 179.6 | -81,380.0 | 10,340.8 | 31,253.0 | 180.0 | 2/3 | 16/34 | 1 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| COMPRA | 7,525 | 02:15 | 2024:+374; 2025:+350; 2026:+1171 | seg=80%(142) ter=76%(143) qua=87%(141) qui=83%(141) sex=82%(141) |
| COMPRA | 7,525 | 03:15–03:45 | 2024:+1083; 2025:-296; 2026:+735 | seg=79%(142) ter=78%(143) qua=86%(141) qui=83%(141) sex=82%(141) |
| COMPRA | 7,525 | 04:45 | 2024:+611; 2025:+262; 2026:+676 | seg=75%(142) ter=79%(143) qua=84%(141) qui=85%(141) sex=79%(141) |
| COMPRA | 7,525 | 01:30–01:45 | 2024:+455; 2025:+75; 2026:+1376 | seg=77%(142) ter=76%(143) qua=86%(140) qui=83%(141) sex=79%(141) |
| COMPRA | 7,525 | 14:15–14:30 | 2024:+1329; 2025:-715; 2026:+110 | seg=75%(143) ter=80%(143) qua=82%(141) qui=76%(141) sex=83%(140) |
| COMPRA | 7,525 | 13:45 | 2024:+549; 2025:-248; 2026:+468 | seg=76%(143) ter=77%(143) qua=84%(141) qui=77%(141) sex=79%(140) |
| COMPRA | 7,525 | 15:15–16:15 | 2024:+1198; 2025:+1027; 2026:+454 | seg=75%(143) ter=80%(143) qua=79%(141) qui=77%(141) sex=82%(140) |
| VENDA | 3,765 | 09:45 | 2024:+820; 2025:-104; 2026:-31 | seg=87%(142) ter=92%(143) qua=91%(141) qui=90%(141) sex=92%(140) |
| VENDA | 3,765 | 04:15–04:30 | 2024:+347; 2025:+407; 2026:-314 | seg=85%(142) ter=95%(143) qua=92%(141) qui=91%(141) sex=88%(141) |
| COMPRA | 3,765 | 05:45 | 2024:-57; 2025:+420; 2026:+453 | seg=91%(142) ter=90%(143) qua=90%(141) qui=90%(141) sex=89%(140) |
| COMPRA | 3,765 | 01:15 | 2024:+21; 2025:+721; 2026:-8 | seg=89%(142) ter=87%(143) qua=92%(140) qui=91%(141) sex=91%(141) |
| COMPRA | 3,765 | 04:30 | 2024:-296; 2025:+611; 2026:+342 | seg=87%(142) ter=91%(143) qua=90%(141) qui=93%(141) sex=89%(141) |
| COMPRA | 3,765 | 16:00 | 2024:+883; 2025:+1409; 2026:+819 | seg=88%(143) ter=87%(143) qua=90%(141) qui=93%(141) sex=91%(141) |
| COMPRA | 3,765 | 01:45 | 2024:-86; 2025:+592; 2026:+420 | seg=90%(142) ter=87%(143) qua=92%(141) qui=91%(141) sex=89%(141) |
| COMPRA | 3,765 | 02:15 | 2024:-188; 2025:+178; 2026:+616 | seg=87%(142) ter=90%(143) qua=91%(141) qui=90%(141) sex=89%(141) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- COMPRA 02:15 alvo 7525: 10-07 -41190; 10-08 +7405*; 10-09 +7405*; 10-12 +7405*; 10-13 +7405*; 10-14 +7405*; 10-15 +7405*; 10-16 +7405*
- COMPRA 03:30 alvo 7525: 10-07 -37640; 10-08 +7405*; 10-09 +7405*; 10-12 +7405*; 10-13 +7405*; 10-14 +7405*; 10-15 +7405*; 10-16 +7405*
- COMPRA 04:45 alvo 7525: 10-07 -36140; 10-08 +7405*; 10-09 +7405*; 10-12 +7405*; 10-13 +7405*; 10-14 +7405*; 10-15 +7405*; 10-16 +7405*
- COMPRA 01:30 alvo 7525: 10-07 -41040; 10-08 +7405*; 10-09 +7405*; 10-12 +7405*; 10-13 +7405*; 10-14 +7405*; 10-15 +7405*; 10-16 +7405*
- COMPRA 14:15 alvo 7525: 10-07 -10590; 10-08 +7405*; 10-09 +7405*; 10-12 +7405*; 10-13 +7405*; 10-14 +7405*; 10-15 +7405*; 10-16 +7405*
- COMPRA 13:45 alvo 7525: 10-07 -13890; 10-08 +7405*; 10-09 +7405*; 10-12 +7405*; 10-13 +7405*; 10-14 +7405*; 10-15 +7405*; 10-16 +7405*

### B. Horário + condição

Famílias que passam nos filtros: **72**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 7,525 | mtf_H4=RANGE & atr_ratio_prev=Q2 | 01h; 05h-08h; 10h; 12h; 14h-16h | 242 | 88.8 | 13.3 | direcional | 3,209 | 83.0 | 83.6 | 73.0 | -18,311.5 | 71.2 | 2,699.9 | 2,203.4 | -91,050.0 | 14,923.4 | 41,450.0 | 270.0 | sim | 3/3 | 21/34 | 1 |
| COMPRA | 7,525 | mtf_H1=RANGE & atr_ratio_prev=Q2 | 01h-02h; 05h-10h; 15h | 365 | 134.0 | 7.0 | direcional | 2,566 | 82.3 | 83.1 | 73.0 | -18,311.5 | 71.2 | 2,472.1 | 1,496.8 | -90,230.0 | 12,966.1 | 35,722.5 | 210.0 | sim | 3/3 | 23/34 | 1 |
| COMPRA | 7,525 | session=LONDON & mtf_M15=BULLISH | 11h; 13h-14h | 570 | 208.6 | 8.4 | direcional | 4,794 | 81.6 | 85.1 | 73.0 | -18,311.5 | 71.2 | 2,379.4 | 1,236.0 | -127,810.0 | 13,987.2 | 36,984.0 | 165.0 | sim | 3/3 | 24/34 | 2 |
| COMPRA | 7,525 | session=ASIA & mtf_M30=RANGE | 04h; 06h; 10h | 548 | 200.8 | 7.8 | direcional | 4,251 | 80.9 | 83.2 | 73.0 | -18,311.5 | 71.2 | 2,185.3 | 764.7 | -232,410.0 | 15,185.5 | 42,665.0 | 375.0 | sim | 3/3 | 23/34 | 1 |
| COMPRA | 7,525 | mtf_H4=BEARISH & mtf_W1=RANGE | 01h-16h | 69 | 27.6 | 58.1 | direcional | 4,007 | 80.6 | 81.6 | 73.0 | -18,311.5 | 71.2 | 2,097.7 | 1,862.5 | -116,830.0 | 13,291.9 | 36,774.0 | 135.0 | sim | 3/3 | 11/14 | 1 |
| VENDA | 7,525 | session=OFF_SESSION & mtf_H1=BULLISH | 02h | 305 | 111.7 | 6.3 | ambos os lados | 1,917 | 81.6 | 83.6 | 72.3 | -18,984.1 | 71.9 | 2,081.1 | 847.6 | -67,620.0 | 14,332.2 | 40,892.0 | 585.0 | sim | 3/3 | 18/34 | 1 |
| VENDA | 7,525 | news_min_since_last_high=Q3 & atr_ratio_prev=Q1 | 06h-09h | 237 | 87.3 | 9.3 | direcional | 2,214 | 81.0 | 82.4 | 72.3 | -18,984.1 | 71.9 | 1,964.4 | 1,169.0 | -124,870.0 | 13,261.5 | 37,792.5 | 435.0 | sim | 3/3 | 19/34 | 1 |
| COMPRA | 7,525 | session=LONDON & mtf_D1=BULLISH | 13h; 15h | 345 | 133.2 | 20.0 | direcional | 6,894 | 79.4 | 84.1 | 73.0 | -18,311.5 | 71.2 | 1,861.2 | 1,770.4 | -81,800.0 | 12,734.2 | 34,255.0 | 165.0 | sim | 3/3 | 22/29 | 1 |
| VENDA | 7,525 | mtf_H4=BULLISH & news_min_since_last_high=Q3 | 04h-09h | 175 | 64.8 | 15.5 | direcional | 2,721 | 79.4 | 81.3 | 72.3 | -18,984.1 | 71.9 | 1,573.1 | 1,034.8 | -118,640.0 | 13,087.9 | 37,520.0 | 465.0 | sim | 3/3 | 19/34 | 1 |
| VENDA | 3,765 | mtf_H4=BULLISH & news_min_to_next_high=Q3 | 04h; 07h-08h | 206 | 75.7 | 15.4 | direcional | 3,173 | 91.2 | 93.6 | 84.8 | -20,121.8 | 84.6 | 1,315.3 | 1,027.6 | -76,490.0 | 9,249.8 | 26,590.0 | 210.0 | sim | 3/3 | 25/34 | 1 |
| COMPRA | 7,525 | mtf_D1=RANGE & atr_ratio_prev=Q2 | 03h; 05h-09h; 11h-14h | 119 | 45.6 | 20.6 | direcional | 2,449 | 84.6 | 90.9 | 73.0 | -18,311.5 | 71.2 | 3,052.8 | 2,528.2 | -127,660.0 | 12,165.7 | 32,100.0 | 240.0 | nao | 3/3 | 20/28 | 1 |
| VENDA | 7,525 | mtf_D1=RANGE & news_min_to_next_high=Q2 | 11h-14h | 82 | 31.4 | 18.5 | direcional | 1,521 | 84.8 | 89.5 | 72.3 | -18,984.1 | 71.9 | 2,911.9 | 2,039.1 | -97,540.0 | 13,165.7 | 34,100.0 | 195.0 | nao | 3/3 | 19/27 | 1 |
| COMPRA | 7,525 | mtf_H4=RANGE & news_min_since_last_high=Q5 | 09h; 12h-16h | 105 | 38.6 | 14.7 | direcional | 1,542 | 83.7 | 85.9 | 73.0 | -18,311.5 | 71.2 | 2,708.5 | 1,108.7 | -83,520.0 | 15,224.4 | 42,766.0 | 135.0 | nao | 3/3 | 22/33 | 1 |
| COMPRA | 7,525 | session=OFF_SESSION & pcum3=Q2 | 02h | 545 | 199.7 | 2.3 | direcional | 1,236 | 83.8 | 86.1 | 73.0 | -18,311.5 | 71.2 | 2,685.4 | 1,631.1 | -233,621.0 | 14,368.5 | 39,272.5 | 555.0 | nao | 3/3 | 24/34 | 1 |
| COMPRA | 7,525 | mtf_H4=RANGE & news_min_to_next_high=Q1 | 12h-16h | 152 | 55.9 | 12.1 | direcional | 1,839 | 83.4 | 83.4 | 73.0 | -18,311.5 | 71.2 | 2,682.2 | 2,137.9 | -107,270.0 | 12,902.0 | 35,630.0 | 75.0 | nao | 3/3 | 25/34 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| COMPRA | 7,525 | mtf_H4=RANGE & atr_ratio_prev=Q2 | 01h:41x 85% +157 | 02h:171x 81% +693 | 03h:297x 81% +568 | 04h:287x 82% +1142 | 05h:264x 88% +3935 | 06h:255x 84% +2374 | 07h:200x 86% +2655 | 08h:151x 85% +2309 | 09h:202x 82% +1094 | 10h:264x 84% +3138 | 11h:274x 79% +2822 | 12h:182x 85% +2260 | 13h:173x 82% +1303 | 14h:204x 85% +3002 | 15h:155x 85% +3910 | 16h:69x 86% +3411 |
| COMPRA | 7,525 | mtf_H1=RANGE & atr_ratio_prev=Q2 | 01h:26x 96% +6018 | 02h:96x 89% +3883 | 03h:158x 75% -758 | 04h:131x 70% -2967 | 05h:190x 84% +739 | 06h:148x 86% +3653 | 07h:138x 96% +5652 | 08h:124x 93% +4519 | 09h:102x 91% +3138 | 10h:204x 84% +1680 | 11h:224x 81% +73 | 12h:201x 82% -312 | 13h:219x 78% -699 | 14h:247x 82% +1377 | 15h:226x 83% +3380 | 16h:99x 82% +2896 |
| COMPRA | 7,525 | session=LONDON & mtf_M15=BULLISH | 10h:216x 80% -167 | 11h:896x 82% +444 | 12h:1024x 81% +1205 | 13h:1014x 83% +2038 | 14h:963x 82% +995 | 15h:681x 81% +1915 |
| COMPRA | 7,525 | session=ASIA & mtf_M30=RANGE | 02h:142x 75% -3183 | 03h:474x 82% -340 | 04h:536x 84% +1426 | 05h:519x 81% +1011 | 06h:494x 82% +1842 | 07h:432x 80% +670 | 08h:510x 80% +1476 | 09h:608x 79% +478 | 10h:536x 82% +620 |
| COMPRA | 7,525 | mtf_H4=BEARISH & mtf_W1=RANGE | 01h:163x 85% +1381 | 02h:163x 90% +3092 | 03h:164x 87% +2284 | 04h:180x 94% +4971 | 05h:180x 91% +4106 | 06h:180x 91% +3378 | 07h:180x 93% +4036 | 08h:196x 88% +1641 | 09h:196x 91% +1937 | 10h:196x 90% +1481 | 11h:196x 86% +957 | 12h:184x 85% +1549 | 13h:184x 82% +188 | 14h:184x 83% +843 | 15h:184x 83% +1110 | 16h:170x 88% +3009 | 17h:168x 80% +2081 | 18h:168x 78% +1492 | 19h:168x 74% +1000 | 20h:172x 67% +1206 | 21h:172x 56% +600 | 22h:172x 44% -267 | 23h:86x 5% -217 |
| VENDA | 7,525 | session=OFF_SESSION & mtf_H1=BULLISH | 01h:1142x 81% +722 | 02h:773x 82% +1017 |
| VENDA | 7,525 | news_min_since_last_high=Q3 & atr_ratio_prev=Q1 | 02h:37x 76% +1975 | 03h:317x 74% -2646 | 04h:507x 80% -63 | 05h:487x 80% +1123 | 06h:299x 82% +2930 | 07h:268x 87% +3266 | 08h:213x 88% +3744 | 09h:73x 89% +4461 |
| COMPRA | 7,525 | session=LONDON & mtf_D1=BULLISH | 10h:444x 79% +1847 | 11h:1379x 78% +1287 | 12h:1378x 79% +1651 | 13h:1379x 80% +1997 | 14h:1380x 79% +1650 | 15h:934x 81% +2467 |
| VENDA | 7,525 | mtf_H4=BULLISH & news_min_since_last_high=Q3 | 01h:366x 78% -989 | 02h:392x 80% -301 | 03h:442x 81% -272 | 04h:480x 84% +2154 | 05h:390x 85% +2887 | 06h:205x 86% +4234 | 07h:149x 89% +3997 | 08h:100x 81% +1365 | 09h:42x 83% +1536 | 22h:31x 13% -2794 | 23h:62x 0% -940 |
| VENDA | 3,765 | mtf_H4=BULLISH & news_min_to_next_high=Q3 | 04h:334x 93% +1450 | 05h:526x 90% +855 | 06h:686x 90% +684 | 07h:706x 93% +1800 | 08h:477x 91% +574 | 09h:263x 90% +195 | 10h:74x 89% +777 | 11h:22x 73% -3019 | 18h:15x 73% +2843 | 19h:16x 69% +1924 |
| COMPRA | 7,525 | mtf_D1=RANGE & atr_ratio_prev=Q2 | 01h:44x 84% +3943 | 02h:129x 84% +4003 | 03h:176x 85% +2285 | 04h:179x 75% -909 | 05h:164x 85% +1786 | 06h:162x 88% +4108 | 07h:147x 90% +2738 | 08h:119x 87% +909 | 09h:145x 86% +1813 | 10h:246x 83% -890 | 11h:230x 90% +3439 | 12h:160x 91% +5118 | 13h:143x 90% +4016 | 14h:167x 88% +4050 | 15h:148x 80% +3891 | 16h:64x 78% +4450 |
| VENDA | 7,525 | mtf_D1=RANGE & news_min_to_next_high=Q2 | 08h:123x 76% -1411 | 09h:214x 82% +548 | 10h:291x 84% +2544 | 11h:318x 86% +3132 | 12h:281x 86% +2862 | 13h:148x 90% +3490 | 14h:69x 94% +4597 | 15h:18x 94% +4667 | 16h:21x 76% -5993 |
| COMPRA | 7,525 | mtf_H4=RANGE & news_min_since_last_high=Q5 | 09h:35x 89% +1382 | 10h:89x 82% -1487 | 11h:169x 75% -5073 | 12h:226x 85% +753 | 13h:246x 87% +2168 | 14h:274x 85% +1851 | 15h:261x 85% +2519 | 16h:128x 90% +4922 | 17h:53x 79% +2559 | 18h:24x 67% -2360 | 19h:16x 50% -2708 |
| COMPRA | 7,525 | session=OFF_SESSION & pcum3=Q2 | 01h:734x 83% +1658 | 02h:501x 85% +1580 |
| COMPRA | 7,525 | mtf_H4=RANGE & news_min_to_next_high=Q1 | 03h:16x 100% +7405 | 12h:43x 91% +2064 | 13h:185x 92% +3466 | 14h:330x 88% +3521 | 15h:373x 85% +2643 | 16h:305x 86% +3101 | 17h:209x 82% +187 | 18h:137x 74% -434 | 19h:104x 68% -1340 | 20h:68x 62% -264 | 21h:28x 71% -1653 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| COMPRA | 7,525 | mtf_H4=RANGE & atr_ratio_prev=Q2 | 2024-01-25 | 2026-10-16 | 2024:+2348; 2025:+2388; 2026:+1923 | seg=77%(672) ter=77%(664) qua=85%(558) qui=87%(666) sex=90%(649) |
| COMPRA | 7,525 | mtf_H1=RANGE & atr_ratio_prev=Q2 | 2024-01-23 | 2026-10-14 | 2024:+2434; 2025:+1241; 2026:+950 | seg=86%(548) ter=76%(430) qua=88%(530) qui=80%(579) sex=81%(479) |
| COMPRA | 7,525 | session=LONDON & mtf_M15=BULLISH | 2024-01-22 | 2026-10-16 | 2024:+2179; 2025:+40; 2026:+1584 | seg=79%(1086) ter=81%(907) qua=86%(963) qui=79%(909) sex=83%(929) |
| COMPRA | 7,525 | session=ASIA & mtf_M30=RANGE | 2024-01-22 | 2026-10-15 | 2024:+967; 2025:+1032; 2026:+222 | seg=81%(852) ter=77%(929) qua=85%(872) qui=81%(770) sex=82%(828) |
| COMPRA | 7,525 | mtf_H4=BEARISH & mtf_W1=RANGE | 2024-04-15 | 2026-10-15 | 2024:+4345; 2025:+874; 2026:+1576 | seg=86%(964) ter=82%(636) qua=83%(529) qui=74%(836) sex=79%(1042) |
| VENDA | 7,525 | session=OFF_SESSION & mtf_H1=BULLISH | 2024-01-23 | 2026-10-16 | 2024:+814; 2025:+493; 2026:+1286 | seg=79%(368) ter=88%(428) qua=80%(395) qui=78%(343) sex=81%(383) |
| VENDA | 7,525 | news_min_since_last_high=Q3 & atr_ratio_prev=Q1 | 2024-01-26 | 2026-10-14 | 2024:+492; 2025:+1596; 2026:+1656 | seg=79%(24) ter=84%(201) qua=79%(500) qui=83%(883) sex=79%(606) |
| COMPRA | 7,525 | session=LONDON & mtf_D1=BULLISH | 2024-01-24 | 2026-08-27 | 2024:+1259; 2025:+1125; 2026:+3299 | seg=69%(1335) ter=78%(1439) qua=83%(1360) qui=81%(1440) sex=85%(1320) |
| VENDA | 7,525 | mtf_H4=BULLISH & news_min_since_last_high=Q3 | 2024-01-31 | 2026-10-14 | 2024:+20; 2025:+1534; 2026:+1580 | seg=100%(35) ter=81%(330) qua=77%(593) qui=77%(1030) sex=82%(733) |
| VENDA | 3,765 | mtf_H4=BULLISH & news_min_to_next_high=Q3 | 2024-01-24 | 2026-10-14 | 2024:+1401; 2025:+46; 2026:+1798 | seg=86%(243) ter=89%(762) qua=95%(953) qui=89%(833) sex=96%(382) |
| COMPRA | 7,525 | mtf_D1=RANGE & atr_ratio_prev=Q2 | 2024-03-06 | 2026-10-16 | 2024:+2697; 2025:+1130; 2026:+4631 | seg=90%(423) ter=79%(368) qua=86%(687) qui=78%(519) sex=88%(452) |
| VENDA | 7,525 | mtf_D1=RANGE & news_min_to_next_high=Q2 | 2024-03-06 | 2026-10-15 | 2024:+224; 2025:+3795; 2026:+1640 | seg=97%(65) ter=91%(199) qua=89%(478) qui=82%(491) sex=75%(288) |
| COMPRA | 7,525 | mtf_H4=RANGE & news_min_since_last_high=Q5 | 2024-01-26 | 2026-10-15 | 2024:+1464; 2025:+333; 2026:+1422 | seg=21%(19) ter=68%(218) qua=88%(325) qui=84%(391) sex=88%(589) |
| COMPRA | 7,525 | session=OFF_SESSION & pcum3=Q2 | 2024-01-23 | 2026-10-16 | 2024:+1225; 2025:+1577; 2026:+2158 | seg=84%(255) ter=79%(288) qua=87%(250) qui=86%(208) sex=85%(235) |
| COMPRA | 7,525 | mtf_H4=RANGE & news_min_to_next_high=Q1 | 2024-01-26 | 2026-10-15 | 2024:+3099; 2025:+705; 2026:+2323 | seg=77%(151) ter=78%(311) qua=81%(668) qui=86%(510) sex=97%(199) |


---

## DXY

ATR M15 mediano = 50 pts; alvos testados: [10, 25, 50, 100, 300] pts

**Horários puros que passaram:** 0 (placebo: média 0.0, máx 0). Não se distingue do acaso.

**Horário + condição:** 80,590 hipóteses; confirmadas na validação **1,671**; placebo: confirmadas média 4.0, máximo 9.

### A. Horários puros

**Nenhum horário puro passou nos critérios.**


### B. Horário + condição

Famílias que passam nos filtros: **5**; mostradas as 15 primeiras (BH primeiro, depois expectativa estressada).

| lado | alvo_pts | condicao | melhores_horas | dias_com_sinal | dias_por_ano | entradas_por_dia | ambos | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | passou_BH | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | mtf_W1=BREAK_UP & atr_ratio_prev=Q1 | 03h-07h | 60 | 29.7 | 19.0 | direcional | 1,138 | 51.3 | 42.0 | 18.5 | -116.9 | 30.2 | 70.4 | 63.2 | -875.0 | 186.9 | 446.5 | 525.0 | sim | 3/3 | 4/6 | 1 |
| COMPRA | 300 | news_min_since_last_high=Q3 & atr_ratio_prev=Q4 | 03h-04h; 07h | 88 | 42.1 | 4.7 | direcional | 413 | 51.3 | 48.9 | 18.5 | -116.9 | 30.2 | 63.1 | 37.7 | -1,662.0 | 240.2 | 566.4 | 510.0 | nao | 3/3 | 14/25 | 1 |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=4 | 04h | 110 | 52.6 | 4.0 | direcional | 440 | 45.5 | 38.8 | 18.5 | -116.9 | 30.2 | 41.2 | 30.1 | -810.0 | 235.0 | 567.1 | 675.0 | nao | 3/3 | 18/26 | 1 |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q3 | 03h | 113 | 54.1 | 2.5 | direcional | 277 | 48.4 | 41.0 | 18.7 | -129.1 | 32.3 | 40.7 | 30.3 | -1,240.0 | 212.1 | 462.0 | 645.0 | nao | 3/3 | 15/24 | 1 |
| COMPRA | 300 | hour_srv=4 & pcum10=Q5 | 04h | 139 | 67.2 | 2.6 | direcional | 365 | 43.0 | 40.8 | 18.5 | -116.9 | 30.2 | 30.3 | 22.0 | -855.0 | 223.6 | 530.4 | 660.0 | nao | 3/3 | 18/26 | 1 |


**Em que horas do servidor o padrão dispara (hora: nº de entradas, % que bate o alvo, resultado médio em pts):**

| lado | alvo_pts | condicao | horas_entrada |
|---|---|---|---|
| COMPRA | 300 | mtf_W1=BREAK_UP & atr_ratio_prev=Q1 | 01h:17x 76% +201 | 02h:21x 81% +203 | 03h:112x 64% +95 | 04h:117x 64% +89 | 05h:102x 75% +139 | 06h:92x 67% +128 | 07h:158x 52% +52 | 08h:201x 45% +24 | 09h:165x 42% +19 | 10h:50x 48% +95 | 21h:16x 0% -45 | 22h:37x 0% -41 | 23h:31x 0% -33 |
| COMPRA | 300 | news_min_since_last_high=Q3 & atr_ratio_prev=Q4 | 03h:67x 54% +53 | 04h:65x 52% +44 | 05h:78x 50% -8 | 06h:77x 48% +13 | 07h:30x 60% +90 | 09h:15x 27% -80 | 10h:18x 67% +58 |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=4 | 04h:440x 45% +30 |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q3 | 03h:277x 48% +30 |
| COMPRA | 300 | hour_srv=4 & pcum10=Q5 | 04h:365x 43% +22 |


| lado | alvo_pts | condicao | primeiro | ultimo | por_ano | dias_semana |
|---|---|---|---|---|---|---|
| COMPRA | 300 | mtf_W1=BREAK_UP & atr_ratio_prev=Q1 | 2024-10-07 | 2026-10-14 | 2024:+81; 2025:+104; 2026:+10 | seg=57%(221) ter=35%(154) qua=69%(285) qui=40%(244) sex=47%(234) |
| COMPRA | 300 | news_min_since_last_high=Q3 & atr_ratio_prev=Q4 | 2024-09-13 | 2026-10-16 | 2024:+42; 2025:+25; 2026:+53 | seg=86%(22) ter=38%(37) qua=59%(41) qui=54%(160) sex=44%(153) |
| COMPRA | 300 | mtf_H1=RANGE & hour_srv=4 | 2024-09-11 | 2026-10-15 | 2024:+27; 2025:+13; 2026:+61 | seg=44%(128) ter=33%(72) qua=64%(92) qui=44%(84) sex=38%(64) |
| VENDA | 300 | hour_srv=3 & atr_ratio_prev=Q3 | 2024-09-13 | 2026-10-16 | 2024:+114; 2025:+10; 2026:+23 | seg=41%(66) ter=49%(43) qua=38%(47) qui=54%(65) sex=59%(56) |
| COMPRA | 300 | hour_srv=4 & pcum10=Q5 | 2024-09-12 | 2026-10-07 | 2024:+11; 2025:+18; 2026:+30 | seg=46%(52) ter=39%(106) qua=54%(63) qui=48%(65) sex=34%(79) |


---

## Resumo

| ativo | tipo | resultado |
|---|---|---|
| USDJPY | horários puros | 17 (placebo máx 33) |
| USDJPY | horário + condição | 153 famílias nos filtros |
| NZDUSD | horários puros | 5 (placebo máx 10) |
| NZDUSD | horário + condição | 114 famílias nos filtros |
| USDCHF | horários puros | 5 (placebo máx 13) |
| USDCHF | horário + condição | 93 famílias nos filtros |
| AUDUSD | horários puros | 0 |
| AUDUSD | horário + condição | 38 famílias nos filtros |
| US30 | horários puros | 28 (placebo máx 3) |
| US30 | horário + condição | 72 famílias nos filtros |
| DXY | horários puros | 0 |
| DXY | horário + condição | 5 famílias nos filtros |

## Limites

- Caminho do preço medido em candles M15. Período 2024-01 a 2026-10 (708 dias); validação = últimos 40%. - A perda dos dias sem alvo usa o fechamento das 23:30; carregar a posição para o dia seguinte não está incluído. - Comissão, slippage e swap não incluídos. - Condições de volatilidade (`ambos os lados`) não dizem a direção: dependem de você escolher o lado, e o risco sem stop está nas colunas de perda.
