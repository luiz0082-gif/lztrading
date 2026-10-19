# Padrões intraday — entrada no horário (servidor), saída no alvo ou às 23:30 (servidor), sem stop

**Regra testada:** entra na abertura da vela M15 do horário indicado; fecha quando o preço atinge **+100, +200, +300 ou +500 pontos** a favor, ou às **23:30** do servidor (fechamento da vela 23:15) se o alvo não foi atingido. Sem stop. 1 operação por dia útil por horário. Londres = servidor−2h; NY = servidor−7h. Custo = spread medido nos ticks (comissão e slippage não incluídos).

## Leia antes: o que este tipo de padrão realmente é

- Com alvo pequeno e **sem stop**, quase todo horário bate o alvo em 85–99% dos dias. A diferença entre horários é pequena; o que domina é a **tendência do período** (ouro em alta forte em 2024-2026: comprar quase em qualquer hora funcionou).
- O risco está na cauda: nos poucos dias em que o alvo **não** é atingido, a perda média é de muitas vezes o alvo (ouro: **−1.530 pts** em média, pior dia **−17.707 a −28.771 pts**), e o preço anda contra você em média **400 a 1.200 pts** antes de sair (p90: 1.000 a 3.000). Por isso cada linha traz `perda_media_sem_alvo`, `pct_necessario_p_empatar`, `pior_dia_pts` e `mae_medio/p90`.
- `ev_estresse_pts` = (limite inferior 95% da taxa de acerto) × ganho + (1−limite) × perda média nos dias sem alvo. É a expectativa por operação supondo o pior plausível para a taxa de acerto. Só aparecem padrões com `ev_estresse` > 0 **e** média real > 0 na descoberta e na validação.
- **Teste contra o acaso:** os horários puros do **XAUUSD** (32 contra no máximo 6 no placebo) estão acima do acaso; **USDJPY** está no limite (21 contra máximo 18); NZDUSD, USDCHF, AUDUSD, US30 e DXY não se distinguem do acaso. Os padrões **com condição** (seção B de cada ativo) **não passam**: o filtro aceita mais padrões com os dados embaralhados do que com os reais, porque os dias vêm em regimes de tendência e as condições (mês, estrutura, sequência de velas) acompanham o regime. Trate-os como pistas, não como evidência.

**BTCUSD:** descartado a pedido.


---

## XAUUSD

Horários puros que passaram: **32** (placebo: média 0.8, máx 6). Acima do acaso.

### A. Horários puros (ordenados por expectativa estressada)

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 500 | 01:00–01:15 | 23:15 | 706 | 89.2 | 86.7 | 490.4 | -1,489.7 | 75.2 | 227.7 | 89.1 | -17,707.3 | 1,203.7 | 3,179.5 | 135.0 | 2/3 | 25/34 | 2 |
| COMPRA | 300 | 01:00–01:15 | 23:15 | 706 | 94.6 | 92.7 | 290.4 | -1,530.5 | 84.1 | 157.4 | 99.7 | -17,707.3 | 817.2 | 2,032.0 | 75.0 | 3/3 | 27/34 | 2 |
| COMPRA | 500 | 06:00 | 04:00 | 707 | 85.7 | 82.9 | 491.0 | -1,489.7 | 75.2 | 153.1 | 55.0 | -18,482.0 | 1,167.3 | 2,933.0 | 120.0 | 3/3 | 20/34 | 1 |
| COMPRA | 500 | 09:00 | 07:00 | 707 | 85.6 | 82.8 | 491.4 | -1,489.7 | 75.2 | 150.5 | 49.6 | -12,029.4 | 1,181.6 | 3,208.4 | 75.0 | 2/3 | 23/34 | 1 |
| COMPRA | 500 | 09:30 | 07:30 | 707 | 85.3 | 82.5 | 491.9 | -1,489.7 | 75.2 | 144.9 | 65.2 | -13,347.1 | 1,193.3 | 3,251.4 | 75.0 | 2/3 | 22/34 | 1 |
| COMPRA | 300 | 06:00–06:15 | 04:15 | 707 | 93.9 | 91.9 | 291.0 | -1,530.5 | 84.0 | 143.6 | 80.8 | -20,709.9 | 814.2 | 1,969.4 | 60.0 | 2/3 | 26/34 | 2 |
| COMPRA | 500 | 12:00 | 10:00 | 708 | 85.0 | 82.2 | 491.8 | -1,489.7 | 75.2 | 139.3 | 81.3 | -15,125.2 | 1,119.2 | 2,806.4 | 90.0 | 3/3 | 22/34 | 1 |
| COMPRA | 200 | 01:00–01:15 | 23:00 | 706 | 97.5 | 96.0 | 174.0 | -1,534.1 | 89.8 | 105.8 | 50.9 | -16,094.0 | 720.8 | 1,652.5 | 15.0 | 3/3 | 27/34 | 2 |
| COMPRA | 300 | 12:00–12:45 | 10:30 | 708 | 91.7 | 89.4 | 292.1 | -1,530.5 | 84.0 | 98.9 | 69.6 | -18,727.9 | 824.7 | 2,093.7 | 45.0 | 3/3 | 26/34 | 4 |
| COMPRA | 200 | 06:00–06:15 | 04:15 | 707 | 95.9 | 94.2 | 190.9 | -1,534.1 | 88.9 | 90.4 | 46.1 | -20,709.9 | 644.7 | 1,478.6 | 30.0 | 2/3 | 26/34 | 2 |
| COMPRA | 300 | 09:30 | 07:30 | 707 | 91.1 | 88.8 | 291.9 | -1,530.5 | 84.0 | 87.1 | 18.3 | -13,347.1 | 927.8 | 2,465.6 | 45.0 | 2/3 | 23/34 | 1 |
| COMPRA | 300 | 09:00 | 07:00 | 707 | 90.9 | 88.6 | 291.4 | -1,530.5 | 84.0 | 83.8 | 23.7 | -11,415.4 | 918.6 | 2,236.8 | 30.0 | 1/3 | 23/34 | 1 |
| COMPRA | 200 | 09:45 | 07:45 | 707 | 95.0 | 93.2 | 191.9 | -1,534.1 | 88.9 | 74.4 | 86.6 | -10,888.1 | 592.8 | 1,372.2 | 30.0 | 3/3 | 27/34 | 1 |
| COMPRA | 200 | 12:00–12:30 | 10:15 | 707 | 95.0 | 93.2 | 191.8 | -1,534.1 | 88.9 | 74.3 | 58.6 | -13,961.2 | 690.5 | 1,547.6 | 30.0 | 3/3 | 25/34 | 3 |
| COMPRA | 100 | 01:15 | 23:15 | 706 | 98.9 | 97.8 | 90.4 | -1,569.0 | 94.6 | 53.6 | 42.8 | -8,898.3 | 442.3 | 1,073.5 | 15.0 | 3/3 | 29/34 | 1 |
| COMPRA | 200 | 11:15 | 09:15 | 708 | 93.9 | 91.9 | 191.6 | -1,534.1 | 88.9 | 52.1 | 14.7 | -11,037.4 | 711.8 | 1,776.6 | 30.0 | 2/3 | 19/34 | 1 |
| COMPRA | 100 | 02:45 | 00:45 | 707 | 98.7 | 97.6 | 90.6 | -1,569.0 | 94.5 | 50.7 | 18.3 | -11,820.2 | 516.5 | 1,156.8 | 15.0 | 2/3 | 27/34 | 1 |
| COMPRA | 100 | 08:45 | 06:45 | 707 | 98.2 | 96.9 | 90.6 | -1,569.0 | 94.5 | 38.8 | 43.1 | -8,904.2 | 487.6 | 1,130.6 | 15.0 | 3/3 | 26/34 | 1 |
| COMPRA | 100 | 06:00–06:15 | 04:15 | 707 | 98.0 | 96.7 | 90.9 | -1,569.0 | 94.5 | 36.2 | 30.5 | -8,272.0 | 435.7 | 1,007.4 | 15.0 | 3/3 | 28/34 | 2 |
| COMPRA | 100 | 12:30 | 10:30 | 708 | 97.6 | 96.2 | 92.1 | -1,569.0 | 94.5 | 28.8 | 22.3 | -18,727.9 | 494.3 | 972.4 | 15.0 | 2/3 | 26/34 | 1 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| COMPRA | 500 | 01:00–01:15 | 2024:+111; 2025:+173; 2026:-43 | seg=85%(142) ter=89%(143) qua=91%(140) qui=89%(141) sex=93%(140) |
| COMPRA | 300 | 01:00–01:15 | 2024:+117; 2025:+135; 2026:+35 | seg=93%(142) ter=95%(143) qua=96%(140) qui=94%(141) sex=96%(140) |
| COMPRA | 500 | 06:00 | 2024:+106; 2025:+31; 2026:+24 | seg=83%(142) ter=87%(143) qua=84%(141) qui=87%(141) sex=88%(140) |
| COMPRA | 500 | 09:00 | 2024:+39; 2025:+124; 2026:-32 | seg=78%(142) ter=87%(143) qua=90%(141) qui=87%(141) sex=85%(140) |
| COMPRA | 500 | 09:30 | 2024:+56; 2025:+157; 2026:-40 | seg=77%(142) ter=88%(143) qua=88%(141) qui=87%(141) sex=87%(140) |
| COMPRA | 300 | 06:00–06:15 | 2024:+122; 2025:+139; 2026:-41 | seg=92%(142) ter=93%(143) qua=96%(141) qui=94%(141) sex=95%(140) |
| COMPRA | 500 | 12:00 | 2024:+61; 2025:+4; 2026:+203 | seg=80%(143) ter=90%(143) qua=83%(141) qui=86%(141) sex=86%(140) |
| COMPRA | 200 | 01:00–01:15 | 2024:+78; 2025:+55; 2026:+13 | seg=96%(142) ter=98%(143) qua=98%(140) qui=98%(141) sex=98%(140) |
| COMPRA | 300 | 12:00–12:45 | 2024:+39; 2025:+114; 2026:+50 | seg=89%(143) ter=95%(143) qua=88%(141) qui=93%(141) sex=94%(140) |
| COMPRA | 200 | 06:00–06:15 | 2024:+71; 2025:+88; 2026:-36 | seg=94%(142) ter=96%(143) qua=97%(141) qui=95%(141) sex=97%(140) |
| COMPRA | 300 | 09:30 | 2024:+32; 2025:+56; 2026:-46 | seg=84%(142) ter=92%(143) qua=93%(141) qui=93%(141) sex=94%(140) |
| COMPRA | 300 | 09:00 | 2024:-2; 2025:+118; 2026:-65 | seg=83%(142) ter=92%(143) qua=94%(141) qui=94%(141) sex=92%(140) |
| COMPRA | 200 | 09:45 | 2024:+52; 2025:+113; 2026:+95 | seg=92%(142) ter=94%(143) qua=97%(141) qui=96%(141) sex=97%(140) |
| COMPRA | 200 | 12:00–12:30 | 2024:+35; 2025:+62; 2026:+82 | seg=91%(142) ter=97%(143) qua=93%(141) qui=97%(141) sex=97%(140) |
| COMPRA | 100 | 01:15 | 2024:+37; 2025:+65; 2026:+22 | seg=99%(142) ter=99%(143) qua=99%(140) qui=99%(141) sex=99%(140) |
| COMPRA | 200 | 11:15 | 2024:+8; 2025:+42; 2026:-11 | seg=94%(143) ter=92%(143) qua=92%(141) qui=95%(141) sex=97%(140) |
| COMPRA | 100 | 02:45 | 2024:+17; 2025:+43; 2026:-12 | seg=98%(142) ter=99%(143) qua=99%(141) qui=99%(141) sex=98%(140) |
| COMPRA | 100 | 08:45 | 2024:+20; 2025:+28; 2026:+91 | seg=97%(142) ter=99%(143) qua=99%(141) qui=98%(141) sex=98%(140) |
| COMPRA | 100 | 06:00–06:15 | 2024:+37; 2025:+30; 2026:+23 | seg=97%(142) ter=98%(143) qua=99%(141) qui=98%(141) sex=99%(140) |
| COMPRA | 100 | 12:30 | 2024:+17; 2025:+71; 2026:-33 | seg=95%(143) ter=98%(143) qua=99%(141) qui=97%(141) sex=99%(140) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- COMPRA 01:15 alvo 500: 10-07 -5424; 10-08 +491*; 10-09 +491*; 10-12 +491*; 10-13 +491*; 10-14 +491*; 10-15 +491*; 10-16 +491*
- COMPRA 01:15 alvo 300: 10-07 +291*; 10-08 +291*; 10-09 +291*; 10-12 +291*; 10-13 +291*; 10-14 +291*; 10-15 +291*; 10-16 +291*
- COMPRA 06:00 alvo 500: 10-07 +491*; 10-08 +491*; 10-09 +491*; 10-12 -3397; 10-13 +491*; 10-14 -6753; 10-15 +491*; 10-16 +491*
- COMPRA 09:00 alvo 500: 10-07 +492*; 10-08 +492*; 10-09 +492*; 10-12 -2045; 10-13 -3340; 10-14 +492*; 10-15 +492*; 10-16 +492*
- COMPRA 09:30 alvo 500: 10-07 +492*; 10-08 +492*; 10-09 +492*; 10-12 -1271; 10-13 +492*; 10-14 +492*; 10-15 +492*; 10-16 +492*
- COMPRA 06:15 alvo 300: 10-07 +291*; 10-08 +291*; 10-09 +291*; 10-12 +291*; 10-13 +291*; 10-14 -6752; 10-15 +291*; 10-16 +291*

### B. Horário + condição (pistas; NÃO passam no placebo)

Hipóteses 76,720; BH na descoberta 2,883; confirmadas 850; **placebo**: BH média 8440.5 (máx 19586), confirmadas média 6.0 (máx 14).

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 500 | month=1 & news_min_to_next_high=Q3 | 666 | 92.9 | 97.2 | 84.2 | -1,489.7 | 75.2 | 307.5 | 271.8 | -35,651.0 | 943.3 | 1,832.0 | 120.0 | 3/3 | 3/3 | 1 |
| COMPRA | 500 | mtf_D1=BEARISH & news_min_since_last_high=Q4 | 1,744 | 90.9 | 91.5 | 84.2 | -1,489.7 | 75.2 | 282.1 | 132.7 | -11,622.0 | 1,139.9 | 2,497.8 | 60.0 | 3/3 | 14/21 | 1 |
| COMPRA | 500 | session=OFF_SESSION & news_min_since_last_high=Q2 | 818 | 91.4 | 97.2 | 84.2 | -1,489.7 | 75.3 | 276.3 | 244.6 | -21,732.3 | 904.7 | 2,261.3 | 105.0 | 3/3 | 26/34 | 1 |
| VENDA | 500 | session=ASIA & atr_ratio_prev=Q5 | 2,119 | 90.4 | 92.2 | 84.5 | -1,498.1 | 75.3 | 273.2 | 65.1 | -22,176.0 | 1,354.1 | 3,764.0 | 45.0 | 3/3 | 20/34 | 1 |
| COMPRA | 500 | mtf_M30=BEARISH & hour_srv=3 | 856 | 90.8 | 95.9 | 84.2 | -1,489.7 | 75.2 | 265.8 | 100.7 | -14,269.3 | 1,149.1 | 3,177.5 | 60.0 | 2/3 | 26/34 | 1 |
| COMPRA | 500 | month=1 & news_min_since_last_high=Q4 | 560 | 91.1 | 98.1 | 84.2 | -1,489.7 | 75.2 | 262.0 | 282.5 | -35,651.0 | 878.4 | 1,931.6 | 90.0 | 3/3 | 3/3 | 1 |
| COMPRA | 500 | session=ASIA & month=1 | 1,614 | 89.8 | 97.0 | 84.2 | -1,489.7 | 75.2 | 258.4 | 185.7 | -53,233.5 | 1,004.0 | 2,026.2 | 105.0 | 3/3 | 3/3 | 1 |
| COMPRA | 500 | session=OFF_SESSION & p1=Q1 | 837 | 90.3 | 94.6 | 84.2 | -1,489.7 | 75.3 | 254.0 | 58.4 | -17,087.3 | 1,246.4 | 3,171.0 | 90.0 | 2/3 | 24/34 | 1 |
| COMPRA | 500 | session=OFF_SESSION & dom_w=d08_14 | 1,135 | 90.0 | 98.7 | 84.2 | -1,489.7 | 75.3 | 253.9 | 145.7 | -17,824.3 | 1,001.9 | 2,448.0 | 90.0 | 3/3 | 24/33 | 1 |
| COMPRA | 500 | dom_w=d08_14 & news_min_to_next_high=Q3 | 1,870 | 89.5 | 92.7 | 84.2 | -1,489.7 | 75.2 | 253.2 | 135.7 | -13,986.1 | 1,111.2 | 2,740.4 | 105.0 | 3/3 | 26/33 | 1 |
| COMPRA | 500 | mtf_M1=RANGE & hour_srv=1 | 650 | 90.3 | 96.6 | 84.2 | -1,489.7 | 75.4 | 245.0 | 99.9 | -20,438.2 | 1,169.4 | 2,679.9 | 135.0 | 2/3 | 21/33 | 1 |
| COMPRA | 500 | session=OFF_SESSION & pcum3=Q1 | 790 | 89.7 | 94.6 | 84.2 | -1,489.7 | 75.3 | 239.7 | 26.0 | -20,069.2 | 1,342.3 | 3,890.7 | 90.0 | 2/3 | 23/33 | 1 |
| COMPRA | 500 | dom_w=d08_14 & hour_srv=1 | 660 | 89.8 | 98.5 | 84.2 | -1,489.7 | 75.4 | 235.3 | 139.5 | -17,824.3 | 1,008.7 | 2,470.9 | 105.0 | 2/3 | 22/33 | 1 |
| COMPRA | 500 | session=OFF_SESSION & news_min_to_next_high=Q4 | 3,106 | 88.3 | 94.7 | 84.2 | -1,489.7 | 75.3 | 233.7 | 38.5 | -22,022.3 | 1,252.9 | 3,552.0 | 105.0 | 2/3 | 23/34 | 1 |
| COMPRA | 500 | session=ASIA & dom_w=d01_07 | 5,183 | 87.8 | 93.0 | 84.2 | -1,489.7 | 75.2 | 231.7 | 72.4 | -28,771.1 | 1,300.1 | 3,081.0 | 75.0 | 2/3 | 20/33 | 1 |


---

## USDJPY

Horários puros que passaram: **21** (placebo: média 8.1, máx 18). Acima do acaso.

### A. Horários puros (ordenados por expectativa estressada)

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 500 | 01:15–01:30 | 23:15 | 709 | 46.3 | 42.6 | 499.1 | -166.8 | 25.0 | 117.0 | 13.8 | -3,921.8 | 585.2 | 1,404.2 | 547.5 | 2/3 | 20/34 | 2 |
| COMPRA | 500 | 02:45–03:15 | 01:15 | 710 | 44.5 | 40.9 | 499.0 | -166.8 | 25.0 | 105.5 | 26.3 | -3,764.0 | 560.0 | 1,300.6 | 495.0 | 2/3 | 21/34 | 3 |
| COMPRA | 500 | 02:00 | 00:00 | 710 | 43.8 | 40.2 | 499.1 | -166.8 | 25.0 | 100.9 | 1.4 | -3,891.9 | 595.3 | 1,417.5 | 510.0 | 1/3 | 20/34 | 1 |
| COMPRA | 500 | 04:15 | 02:15 | 710 | 43.1 | 39.5 | 499.2 | -166.8 | 25.0 | 96.3 | 21.5 | -3,938.8 | 541.1 | 1,280.3 | 472.5 | 3/3 | 21/34 | 1 |
| COMPRA | 300 | 01:30–01:45 | 23:30 | 709 | 64.2 | 60.6 | 299.1 | -227.9 | 43.2 | 91.4 | 3.7 | -3,951.8 | 499.8 | 1,245.4 | 300.0 | 2/3 | 19/34 | 2 |
| COMPRA | 500 | 04:45 | 02:45 | 710 | 41.3 | 37.7 | 499.2 | -166.8 | 25.0 | 84.3 | 18.0 | -3,979.8 | 533.1 | 1,244.9 | 465.0 | 3/3 | 22/34 | 1 |
| COMPRA | 200 | 01:15–01:45 | 23:30 | 709 | 75.7 | 72.5 | 199.1 | -260.6 | 56.7 | 72.5 | 12.7 | -3,428.8 | 405.1 | 1,065.6 | 165.0 | 2/3 | 22/34 | 3 |
| COMPRA | 200 | 04:15–04:30 | 02:30 | 710 | 75.6 | 72.3 | 199.2 | -260.6 | 56.7 | 72.0 | 12.0 | -3,081.8 | 376.6 | 979.4 | 225.0 | 2/3 | 22/34 | 2 |
| COMPRA | 200 | 03:15 | 01:15 | 710 | 73.9 | 70.6 | 199.0 | -260.6 | 56.7 | 63.8 | 5.2 | -3,484.0 | 394.3 | 1,069.1 | 150.0 | 2/3 | 18/34 | 1 |
| COMPRA | 100 | 04:15–04:30 | 02:15 | 710 | 88.2 | 85.6 | 99.2 | -297.6 | 75.0 | 42.0 | 12.9 | -2,832.8 | 252.9 | 722.8 | 75.0 | 3/3 | 18/34 | 2 |
| COMPRA | 100 | 09:15 | 07:15 | 710 | 87.6 | 85.0 | 99.0 | -297.6 | 75.0 | 39.4 | 10.9 | -4,154.0 | 242.5 | 588.6 | 60.0 | 2/3 | 24/34 | 1 |
| COMPRA | 100 | 02:00–02:15 | 00:15 | 710 | 87.3 | 84.7 | 99.0 | -297.6 | 75.0 | 38.2 | 4.2 | -2,189.0 | 283.1 | 872.8 | 60.0 | 2/3 | 18/34 | 2 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| COMPRA | 500 | 01:15–01:30 | 2024:+59; 2025:-34; 2026:+20 | seg=39%(142) ter=47%(143) qua=49%(140) qui=48%(141) sex=48%(143) |
| COMPRA | 500 | 02:45–03:15 | 2024:+46; 2025:-19; 2026:+61 | seg=38%(142) ter=44%(143) qua=48%(141) qui=49%(141) sex=44%(143) |
| COMPRA | 500 | 02:00 | 2024:+44; 2025:-35; 2026:-3 | seg=36%(142) ter=45%(143) qua=48%(141) qui=45%(141) sex=45%(143) |
| COMPRA | 500 | 04:15 | 2024:+29; 2025:+2; 2026:+37 | seg=39%(142) ter=39%(143) qua=45%(141) qui=50%(141) sex=41%(143) |
| COMPRA | 300 | 01:30–01:45 | 2024:+39; 2025:-29; 2026:+3 | seg=60%(142) ter=66%(143) qua=64%(140) qui=67%(141) sex=64%(143) |
| COMPRA | 500 | 04:45 | 2024:+18; 2025:+0; 2026:+40 | seg=38%(142) ter=37%(143) qua=48%(141) qui=43%(141) sex=40%(143) |
| COMPRA | 200 | 01:15–01:45 | 2024:+42; 2025:-33; 2026:+35 | seg=70%(142) ter=80%(143) qua=79%(140) qui=76%(141) sex=74%(143) |
| COMPRA | 200 | 04:15–04:30 | 2024:-6; 2025:+8; 2026:+38 | seg=75%(142) ter=75%(143) qua=77%(141) qui=79%(141) sex=72%(143) |
| COMPRA | 200 | 03:15 | 2024:+42; 2025:-39; 2026:+17 | seg=73%(142) ter=73%(143) qua=72%(141) qui=78%(141) sex=74%(143) |
| COMPRA | 100 | 04:15–04:30 | 2024:+26; 2025:+2; 2026:+11 | seg=87%(142) ter=89%(143) qua=88%(141) qui=92%(141) sex=85%(143) |
| COMPRA | 100 | 09:15 | 2024:-3; 2025:+30; 2026:+5 | seg=90%(142) ter=87%(143) qua=89%(141) qui=89%(141) sex=83%(143) |
| COMPRA | 100 | 02:00–02:15 | 2024:-4; 2025:+1; 2026:+18 | seg=85%(142) ter=89%(143) qua=87%(141) qui=89%(141) sex=87%(143) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- COMPRA 01:15 alvo 500: 10-07 -106; 10-08 -93; 10-09 +499*; 10-12 +352; 10-13 -276; 10-14 +499*; 10-15 -200; 10-16 -55
- COMPRA 03:15 alvo 500: 10-07 -403; 10-08 +5; 10-09 +205; 10-12 +499*; 10-13 -184; 10-14 +499*; 10-15 +246; 10-16 -186
- COMPRA 02:00 alvo 500: 10-07 -128; 10-08 -91; 10-09 +499*; 10-12 +339; 10-13 -316; 10-14 +499*; 10-15 +13; 10-16 -103
- COMPRA 04:15 alvo 500: 10-07 -446; 10-08 +499*; 10-09 +499*; 10-12 +499*; 10-13 -60; 10-14 -157; 10-15 +499*; 10-16 -148
- COMPRA 01:30 alvo 300: 10-07 +299*; 10-08 +299*; 10-09 +299*; 10-12 +299*; 10-13 -276; 10-14 +299*; 10-15 -130; 10-16 -88
- COMPRA 04:45 alvo 500: 10-07 -267; 10-08 +499*; 10-09 +499*; 10-12 +499*; 10-13 -20; 10-14 +499*; 10-15 +499*; 10-16 -161

### B. Horário + condição (pistas; NÃO passam no placebo)

Hipóteses 79,744; BH na descoberta 8,029; confirmadas 6,299; **placebo**: BH média 224.8 (máx 525), confirmadas média 44.2 (máx 93).

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 500 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | 378 | 79.1 | 68.3 | 21.3 | -259.6 | 34.2 | 307.2 | 336.1 | -1,619.2 | 457.0 | 1,041.6 | 315.0 | 3/3 | 10/12 | 1 |
| COMPRA | 500 | mtf_H4=BREAK_DOWN & mtf_D1=BREAK_DOWN | 282 | 74.5 | 72.3 | 20.8 | -166.8 | 25.2 | 289.8 | 271.0 | -1,480.8 | 511.8 | 1,164.4 | 210.0 | 3/3 | 7/7 | 1 |
| COMPRA | 500 | session=OFF_SESSION & mtf_D1=BREAK_DOWN | 232 | 71.6 | 70.8 | 20.8 | -166.8 | 25.8 | 255.6 | 140.7 | -2,792.8 | 756.7 | 1,758.9 | 150.0 | 2/3 | 12/15 | 1 |
| VENDA | 300 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q4 | 378 | 92.9 | 92.9 | 37.3 | -296.0 | 49.7 | 238.3 | 260.5 | -1,095.2 | 357.1 | 825.6 | 255.0 | 3/3 | 12/12 | 1 |
| COMPRA | 500 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q3 | 349 | 66.8 | 84.7 | 20.8 | -166.8 | 25.5 | 237.0 | 141.3 | -3,081.8 | 596.2 | 1,636.4 | 315.0 | 2/3 | 9/12 | 1 |
| VENDA | 500 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q4 | 366 | 70.2 | 68.4 | 21.3 | -259.6 | 34.2 | 236.1 | 225.0 | -1,977.2 | 539.5 | 1,274.0 | 315.0 | 3/3 | 9/13 | 1 |
| VENDA | 500 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q2 | 382 | 69.9 | 59.3 | 21.3 | -259.6 | 34.2 | 234.4 | 154.7 | -2,073.2 | 502.9 | 1,276.7 | 240.0 | 2/3 | 9/12 | 1 |
| COMPRA | 500 | session=ASIA & mtf_W1=BREAK_DOWN | 640 | 63.3 | 70.6 | 20.8 | -166.8 | 25.0 | 229.2 | 243.7 | -1,287.8 | 465.4 | 993.1 | 315.0 | 3/3 | 3/4 | 1 |
| COMPRA | 500 | day_of_week=WEDNESDAY & mtf_W1=BREAK_DOWN | 376 | 63.3 | 80.9 | 20.8 | -166.8 | 25.1 | 220.1 | 186.9 | -1,081.0 | 581.6 | 1,281.5 | 315.0 | 2/3 | 3/4 | 1 |
| COMPRA | 500 | mtf_H1=BEARISH & mtf_D1=BREAK_DOWN | 1,110 | 60.5 | 51.7 | 20.8 | -166.8 | 25.3 | 212.5 | 87.1 | -3,081.8 | 623.4 | 1,698.3 | 210.0 | 2/3 | 13/15 | 1 |
| VENDA | 500 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q3 | 349 | 65.9 | 65.8 | 21.3 | -259.6 | 34.2 | 201.5 | 238.0 | -1,056.2 | 599.2 | 1,293.0 | 510.0 | 3/3 | 10/12 | 1 |
| VENDA | 500 | mtf_H1=BREAK_DOWN & news_min_to_next_high=Q4 | 276 | 66.3 | 64.2 | 21.3 | -259.6 | 34.2 | 199.7 | 119.1 | -1,871.2 | 456.6 | 1,355.5 | 225.0 | 3/3 | 15/22 | 1 |
| VENDA | 500 | session=OFF_SESSION & mtf_D1=BREAK_DOWN | 232 | 66.8 | 77.8 | 21.3 | -259.6 | 34.2 | 199.5 | 133.8 | -1,977.2 | 687.2 | 1,472.4 | 195.0 | 3/3 | 11/15 | 1 |
| COMPRA | 300 | mtf_D1=BREAK_DOWN & news_min_since_last_high=Q3 | 349 | 86.0 | 91.9 | 38.9 | -227.9 | 44.1 | 195.4 | 177.1 | -3,081.8 | 411.9 | 1,346.6 | 135.0 | 3/3 | 12/12 | 1 |
| VENDA | 300 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 399 | 86.2 | 75.7 | 37.3 | -296.0 | 49.7 | 194.8 | 161.9 | -1,858.2 | 402.0 | 838.0 | 210.0 | 3/3 | 10/12 | 1 |


---

## NZDUSD

Horários puros que passaram: **9** (placebo: média 3.2, máx 10). Não se distingue do acaso.

### A. Horários puros (ordenados por expectativa estressada)

| lado | alvo_pts | janela_entrada | londres | n | pct_alvo | pct_alvo_min95 | ganho_dia_alvo | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 100 | 06:15 | 04:15 | 711 | 70.2 | 66.7 | 96.6 | -131.8 | 57.7 | 20.6 | 2.4 | -816.5 | 156.9 | 411.0 | 240.0 | 2/3 | 19/34 | 1 |
| VENDA | 100 | 09:45–10:00 | 07:45 | 711 | 68.5 | 65.0 | 96.5 | -131.8 | 57.7 | 16.6 | 1.8 | -820.5 | 154.2 | 389.0 | 165.0 | 1/3 | 20/34 | 2 |
| VENDA | 100 | 10:30–10:45 | 08:30 | 711 | 68.4 | 64.8 | 96.5 | -131.8 | 57.7 | 16.3 | 3.2 | -864.5 | 143.9 | 372.0 | 195.0 | 2/3 | 22/34 | 2 |
| VENDA | 200 | 08:30 | 06:30 | 711 | 42.1 | 38.5 | 196.5 | -98.8 | 33.5 | 14.8 | 2.2 | -1,078.5 | 194.6 | 428.0 | 435.0 | 3/3 | 18/34 | 1 |
| VENDA | 200 | 09:30–09:45 | 07:45 | 711 | 41.4 | 37.8 | 196.5 | -98.8 | 33.5 | 12.8 | 2.6 | -845.5 | 185.7 | 411.0 | 360.0 | 2/3 | 18/34 | 2 |
| COMPRA | 100 | 10:45 | 08:45 | 711 | 64.7 | 61.1 | 96.7 | -130.1 | 57.4 | 8.5 | 0.7 | -1,125.3 | 150.2 | 343.0 | 210.0 | 2/3 | 18/34 | 1 |


| lado | alvo_pts | janela_entrada | por_ano | dias_semana |
|---|---|---|---|---|
| VENDA | 100 | 06:15 | 2024:+0; 2025:+8; 2026:-2 | seg=69%(143) ter=71%(143) qua=70%(141) qui=78%(141) sex=64%(143) |
| VENDA | 100 | 09:45–10:00 | 2024:+12; 2025:-0; 2026:-7 | seg=65%(143) ter=69%(143) qua=70%(141) qui=74%(141) sex=64%(143) |
| VENDA | 100 | 10:30–10:45 | 2024:+8; 2025:+4; 2026:-3 | seg=62%(143) ter=69%(143) qua=75%(141) qui=72%(141) sex=63%(143) |
| VENDA | 200 | 08:30 | 2024:+4; 2025:+1; 2026:+2 | seg=38%(143) ter=41%(143) qua=43%(141) qui=51%(141) sex=37%(143) |
| VENDA | 200 | 09:30–09:45 | 2024:+8; 2025:-1; 2026:+1 | seg=35%(143) ter=38%(143) qua=46%(141) qui=48%(141) sex=39%(143) |
| COMPRA | 100 | 10:45 | 2024:+3; 2025:+2; 2026:-3 | seg=62%(143) ter=64%(143) qua=67%(141) qui=67%(141) sex=64%(143) |


**Últimas 8 ocorrências das 6 primeiras (data → líquido pts; * = bateu o alvo):**

- VENDA 06:15 alvo 100: 10-07 +97*; 10-08 +97*; 10-09 +97*; 10-12 +97*; 10-13 -218; 10-14 +97*; 10-15 +96*; 10-16 -120
- VENDA 09:45 alvo 100: 10-07 +97*; 10-08 +97*; 10-09 +97*; 10-12 +97*; 10-13 -164; 10-14 +97*; 10-15 +97*; 10-16 +96*
- VENDA 10:30 alvo 100: 10-07 +97*; 10-08 +97*; 10-09 +97*; 10-12 +97*; 10-13 -126; 10-14 +97*; 10-15 +97*; 10-16 +97*
- VENDA 08:30 alvo 200: 10-07 +28; 10-08 +197*; 10-09 +197*; 10-12 +166; 10-13 -216; 10-14 +197*; 10-15 +197*; 10-16 -16
- VENDA 09:45 alvo 200: 10-07 +197*; 10-08 -36; 10-09 +4; 10-12 +197*; 10-13 -164; 10-14 +197*; 10-15 -80; 10-16 +8
- COMPRA 10:45 alvo 100: 10-07 -70; 10-08 +97*; 10-09 +7; 10-12 -174; 10-13 +97*; 10-14 -314; 10-15 +30; 10-16 +97*

### B. Horário + condição (pistas; NÃO passam no placebo)

Hipóteses 78,944; BH na descoberta 3,979; confirmadas 3,259; **placebo**: BH média 144.7 (máx 454), confirmadas média 15.7 (máx 30).

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 300 | session=OFF_SESSION & month=4 | 528 | 52.1 | 44.9 | 15.7 | -74.2 | 20.3 | 100.8 | 26.1 | -2,138.6 | 268.0 | 580.1 | 525.0 | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=4 & hour_srv=1 | 264 | 53.0 | 51.1 | 15.7 | -74.2 | 20.5 | 95.8 | 26.9 | -2,138.6 | 267.2 | 569.4 | 517.5 | 2/3 | 2/3 | 1 |
| VENDA | 500 | month=3 & news_min_since_last_high=Q3 | 671 | 27.4 | 52.2 | 5.4 | -35.2 | 6.6 | 93.4 | 97.4 | -626.5 | 202.2 | 474.0 | 765.0 | 3/3 | 3/3 | 1 |
| COMPRA | 300 | month=4 & hour_srv=2 | 264 | 51.1 | 38.6 | 15.7 | -74.2 | 20.0 | 93.0 | 25.3 | -2,129.7 | 268.8 | 585.0 | 540.0 | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=4 & dom_w=d08_14 | 1,396 | 48.1 | 50.9 | 15.7 | -74.2 | 20.3 | 91.8 | 50.0 | -1,054.3 | 190.9 | 518.5 | 300.0 | 2/3 | 2/3 | 1 |
| VENDA | 300 | mtf_D1=RANGE & month=10 | 654 | 47.6 | 45.7 | 17.3 | -71.3 | 19.4 | 89.6 | 124.0 | -257.5 | 103.1 | 216.0 | 480.0 | 2/2 | 2/2 | 1 |
| COMPRA | 300 | month=4 & hour_srv=3 | 264 | 47.7 | 38.6 | 15.7 | -74.2 | 20.0 | 80.7 | 19.0 | -2,154.4 | 259.1 | 570.0 | 472.5 | 2/3 | 2/3 | 1 |
| COMPRA | 500 | month=4 & dom_w=d08_14 | 1,396 | 24.1 | 20.0 | 4.2 | -36.6 | 7.0 | 78.3 | 73.5 | -1,054.3 | 203.4 | 592.5 | 435.0 | 2/3 | 2/3 | 1 |
| VENDA | 300 | month=3 & news_min_since_last_high=Q3 | 671 | 44.1 | 65.7 | 17.3 | -71.3 | 19.4 | 77.4 | 52.8 | -626.5 | 201.0 | 474.0 | 555.0 | 3/3 | 3/3 | 1 |
| COMPRA | 200 | month=4 & dom_w=d08_14 | 1,396 | 62.6 | 65.5 | 29.2 | -101.3 | 34.5 | 74.8 | 35.5 | -1,054.3 | 170.8 | 430.5 | 225.0 | 2/3 | 2/3 | 1 |
| COMPRA | 500 | session=OFF_SESSION & month=4 | 528 | 24.2 | 22.2 | 4.2 | -36.6 | 7.0 | 72.7 | 55.1 | -2,138.6 | 273.1 | 580.1 | 562.5 | 2/3 | 2/3 | 1 |
| COMPRA | 200 | month=5 & news_min_to_next_high=Q3 | 774 | 61.9 | 67.5 | 29.2 | -101.3 | 34.0 | 72.7 | 33.5 | -731.5 | 183.9 | 443.8 | 495.0 | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q4 | 750 | 44.9 | 41.0 | 15.7 | -74.2 | 21.0 | 72.3 | 58.6 | -839.4 | 170.7 | 390.2 | 690.0 | 2/3 | 2/3 | 1 |
| COMPRA | 500 | month=4 & hour_srv=1 | 264 | 25.8 | 26.1 | 4.2 | -36.6 | 7.0 | 71.8 | 59.5 | -2,138.6 | 273.3 | 569.4 | 742.5 | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=5 & hour_srv=3 | 264 | 45.1 | 40.5 | 15.7 | -74.2 | 20.0 | 71.1 | 43.8 | -765.4 | 204.0 | 445.1 | 645.0 | 3/3 | 3/3 | 1 |


---

## USDCHF

Horários puros que passaram: **0** (placebo: média 2.9, máx 6). Não se distingue do acaso.

**Nenhum horário puro passou nos critérios.**


### B. Horário + condição (pistas; NÃO passam no placebo)

Hipóteses 80,264; BH na descoberta 5,497; confirmadas 3,997; **placebo**: BH média 234.2 (máx 623), confirmadas média 46.3 (máx 93).

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 500 | mtf_H4=BREAK_DOWN & mtf_W1=BREAK_DOWN | 298 | 53.7 | 37.2 | 7.4 | -73.0 | 12.8 | 201.2 | 95.6 | -1,892.0 | 386.6 | 950.3 | 247.5 | 3/3 | 5/5 | 1 |
| COMPRA | 500 | mtf_W1=BREAK_DOWN & news_min_to_next_high=Q3 | 418 | 44.7 | 30.9 | 7.1 | -53.0 | 9.6 | 167.7 | 45.8 | -2,963.0 | 426.4 | 895.3 | 570.0 | 2/3 | 3/6 | 1 |
| VENDA | 300 | mtf_H4=BREAK_DOWN & mtf_W1=BREAK_DOWN | 298 | 68.5 | 69.2 | 19.8 | -113.8 | 27.6 | 145.5 | 43.7 | -1,892.0 | 357.5 | 911.5 | 202.5 | 3/3 | 4/5 | 1 |
| VENDA | 300 | mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | 282 | 68.1 | 54.3 | 19.8 | -113.8 | 27.6 | 143.4 | 95.0 | -886.0 | 225.8 | 599.0 | 270.0 | 2/3 | 10/13 | 1 |
| VENDA | 500 | mtf_D1=BREAK_DOWN & mtf_W1=BREAK_DOWN | 846 | 38.5 | 36.5 | 7.4 | -73.0 | 12.8 | 128.6 | 151.9 | -867.0 | 275.5 | 730.0 | 270.0 | 3/3 | 4/4 | 1 |
| VENDA | 300 | mtf_H1=BREAK_DOWN & news_min_since_last_high=Q4 | 279 | 62.0 | 53.3 | 19.8 | -113.8 | 27.6 | 117.6 | 122.0 | -831.0 | 210.9 | 507.0 | 330.0 | 3/3 | 17/25 | 1 |
| COMPRA | 500 | day_of_week=MONDAY & mtf_W1=BREAK_DOWN | 658 | 34.0 | 28.2 | 7.1 | -53.0 | 9.7 | 113.7 | 68.6 | -1,624.7 | 347.5 | 795.1 | 390.0 | 3/3 | 4/6 | 1 |
| VENDA | 300 | mtf_H4=BREAK_DOWN & news_min_to_next_high=Q3 | 385 | 60.0 | 49.2 | 19.8 | -113.8 | 27.6 | 112.9 | 68.9 | -1,732.0 | 269.2 | 638.4 | 435.0 | 3/3 | 11/18 | 1 |
| COMPRA | 500 | mtf_H1=BEARISH & mtf_W1=BREAK_DOWN | 1,194 | 32.8 | 18.2 | 7.1 | -53.0 | 9.8 | 111.2 | 52.8 | -1,713.0 | 322.1 | 769.0 | 427.5 | 3/3 | 4/6 | 1 |
| VENDA | 500 | month=4 & dom_w=d08_14 | 1,408 | 34.5 | 22.3 | 7.4 | -73.0 | 12.8 | 110.2 | 71.1 | -1,892.0 | 267.7 | 720.3 | 345.0 | 2/3 | 2/3 | 1 |
| COMPRA | 500 | day_of_week=WEDNESDAY & mtf_W1=BREAK_DOWN | 657 | 33.3 | 26.1 | 7.1 | -53.0 | 9.8 | 109.0 | 55.7 | -3,209.8 | 274.1 | 558.2 | 450.0 | 2/3 | 3/5 | 1 |
| COMPRA | 500 | mtf_W1=BREAK_DOWN & atr_ratio_prev=Q3 | 583 | 32.6 | 29.8 | 7.1 | -53.0 | 9.7 | 105.4 | 44.3 | -3,096.0 | 293.8 | 832.8 | 330.0 | 2/3 | 4/6 | 1 |
| VENDA | 300 | day_of_week=TUESDAY & mtf_W1=BREAK_DOWN | 658 | 55.9 | 77.1 | 19.8 | -113.8 | 27.6 | 100.8 | 94.7 | -1,141.0 | 216.2 | 540.8 | 270.0 | 3/3 | 5/5 | 1 |
| VENDA | 300 | mtf_D1=BREAK_DOWN & mtf_W1=BREAK_DOWN | 846 | 55.4 | 56.0 | 19.8 | -113.8 | 27.6 | 100.6 | 117.3 | -867.0 | 247.1 | 654.5 | 195.0 | 3/3 | 4/4 | 1 |
| VENDA | 300 | session=ASIA & mtf_H4=BREAK_DOWN | 816 | 55.4 | 44.6 | 19.8 | -113.8 | 27.6 | 100.3 | 29.9 | -1,732.0 | 292.1 | 667.0 | 390.0 | 2/3 | 15/27 | 1 |


---

## AUDUSD

Horários puros que passaram: **0** (placebo: média 0.0, máx 0). Não se distingue do acaso.

**Nenhum horário puro passou nos critérios.**


### B. Horário + condição (pistas; NÃO passam no placebo)

Hipóteses 77,856; BH na descoberta 4,599; confirmadas 3,807; **placebo**: BH média 688.8 (máx 1105), confirmadas média 79.0 (máx 169).

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 500 | month=4 & hour_srv=0 | 257 | 40.5 | 54.7 | 6.8 | -51.7 | 10.8 | 114.0 | 58.5 | -3,055.7 | 298.2 | 640.2 | 735.0 | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=4 & hour_srv=3 | 264 | 60.2 | 51.1 | 19.5 | -93.1 | 24.6 | 112.5 | 23.2 | -3,022.0 | 284.0 | 567.9 | 510.0 | 2/3 | 2/3 | 1 |
| VENDA | 200 | mtf_D1=BREAK_UP & month=5 | 282 | 80.5 | 85.1 | 33.7 | -126.7 | 40.5 | 109.6 | 148.4 | -229.8 | 95.2 | 225.9 | 345.0 | 3/3 | 3/3 | 1 |
| COMPRA | 500 | month=4 & hour_srv=1 | 264 | 35.6 | 43.2 | 6.8 | -51.7 | 9.7 | 107.9 | 92.2 | -3,018.7 | 303.8 | 595.8 | 720.0 | 2/3 | 2/3 | 1 |
| VENDA | 300 | mtf_D1=BREAK_UP & month=5 | 282 | 59.6 | 48.9 | 21.2 | -99.9 | 25.9 | 107.7 | 194.8 | -229.8 | 95.7 | 225.9 | 540.0 | 3/3 | 3/3 | 1 |
| COMPRA | 500 | session=OFF_SESSION & month=4 | 528 | 33.7 | 38.6 | 6.8 | -51.7 | 9.7 | 107.4 | 85.9 | -3,018.7 | 304.6 | 588.8 | 780.0 | 2/3 | 2/3 | 1 |
| COMPRA | 500 | month=4 & dom_w=d08_14 | 1,409 | 31.2 | 34.5 | 6.8 | -51.7 | 9.7 | 101.9 | 66.5 | -1,307.6 | 254.4 | 723.0 | 420.0 | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=4 & hour_srv=4 | 264 | 57.2 | 47.7 | 19.5 | -93.1 | 24.6 | 100.9 | 28.7 | -2,958.0 | 267.4 | 534.4 | 555.0 | 2/3 | 2/3 | 1 |
| VENDA | 500 | month=3 & news_min_since_last_high=Q3 | 672 | 31.4 | 58.7 | 7.7 | -60.5 | 11.1 | 92.6 | 70.2 | -705.8 | 237.3 | 559.6 | 630.0 | 3/3 | 3/3 | 1 |
| COMPRA | 300 | month=5 & news_min_to_next_high=Q3 | 817 | 52.1 | 59.8 | 19.5 | -93.1 | 24.5 | 91.7 | 50.4 | -662.7 | 209.2 | 521.2 | 600.0 | 2/3 | 2/3 | 1 |
| COMPRA | 500 | month=4 & hour_srv=2 | 264 | 31.8 | 34.1 | 6.8 | -51.7 | 9.6 | 90.6 | 79.6 | -2,968.2 | 305.4 | 572.6 | 787.5 | 2/3 | 2/3 | 1 |
| COMPRA | 300 | month=4 & hour_srv=6 | 264 | 53.8 | 52.3 | 19.5 | -93.1 | 24.6 | 88.0 | 41.9 | -2,429.7 | 253.0 | 578.7 | 450.0 | 2/3 | 2/3 | 1 |
| VENDA | 300 | month=2 & news_min_to_next_high=Q4 | 757 | 52.0 | 62.3 | 21.2 | -99.9 | 25.9 | 87.3 | 49.8 | -1,063.8 | 211.3 | 457.0 | 765.0 | 2/3 | 2/3 | 1 |
| VENDA | 500 | day_of_week=THURSDAY & month=3 | 1,130 | 28.5 | 50.5 | 7.7 | -60.5 | 11.1 | 81.3 | 109.3 | -872.8 | 170.1 | 418.1 | 525.0 | 3/3 | 3/3 | 1 |
| COMPRA | 500 | month=4 & hour_srv=3 | 264 | 29.9 | 33.0 | 6.8 | -51.7 | 9.6 | 81.2 | 63.4 | -3,022.0 | 297.3 | 567.9 | 825.0 | 2/3 | 2/3 | 1 |


---

## US30

Horários puros que passaram: **0** (placebo: média 0.0, máx 0). Não se distingue do acaso.

**Nenhum horário puro passou nos critérios.**


### B. Horário + condição (pistas; NÃO passam no placebo)

Hipóteses 79,128; BH na descoberta 0; confirmadas 0; **placebo**: BH média 0.0 (máx 0), confirmadas média 0.0 (máx 0).

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 500 | session=ASIA & atr_ratio_prev=Q2 | 7,324 | 99.0 | 99.2 | 97.8 | -22,341.2 | 98.3 | 102.9 | 63.4 | -131,600.0 | 2,668.8 | 4,945.5 | 15.0 | 2/3 | 23/34 | 1 |


---

## DXY

Horários puros que passaram: **0** (placebo: média 0.0, máx 0). Não se distingue do acaso.

**Nenhum horário puro passou nos critérios.**


### B. Horário + condição (pistas; NÃO passam no placebo)

Hipóteses 64,472; BH na descoberta 3,114; confirmadas 2,252; **placebo**: BH média 180.0 (máx 359), confirmadas média 52.0 (máx 72).

| lado | alvo_pts | condicao | n | pct_alvo | pct_alvo_val | pct_base_val | perda_media_sem_alvo | pct_necessario_p_empatar | ev_estresse_pts | media_real_pts | pior_dia_pts | mae_medio_pts | mae_p90_pts | min_ate_alvo | anos_pos | meses_pos | formas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 300 | mtf_D1=RANGE & month=4 | 917 | 61.5 | 60.5 | 18.7 | -129.1 | 32.3 | 103.6 | 86.6 | -1,227.0 | 173.9 | 482.4 | 292.5 | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=4 & news_min_since_last_high=Q3 | 392 | 62.8 | 56.7 | 18.7 | -129.1 | 32.3 | 101.9 | 91.7 | -1,393.0 | 191.4 | 419.8 | 435.0 | 2/2 | 2/2 | 1 |
| VENDA | 300 | session=ASIA & month=4 | 1,339 | 59.1 | 54.0 | 18.7 | -129.1 | 32.3 | 96.4 | 53.8 | -1,608.0 | 217.0 | 482.6 | 360.0 | 2/2 | 2/2 | 1 |
| VENDA | 500 | month=4 & news_min_since_last_high=Q3 | 392 | 38.3 | 31.2 | 7.2 | -92.7 | 16.5 | 96.3 | 107.2 | -1,393.0 | 239.0 | 482.9 | 420.0 | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=4 & dom_w=d08_14 | 835 | 59.3 | 58.8 | 18.7 | -129.1 | 32.3 | 94.1 | 93.7 | -1,058.0 | 189.3 | 551.0 | 240.0 | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=4 & atr_ratio_prev=Q1 | 753 | 56.0 | 56.5 | 18.7 | -129.1 | 32.3 | 80.3 | 89.8 | -887.0 | 157.0 | 399.4 | 450.0 | 2/2 | 2/2 | 1 |
| VENDA | 300 | month=4 & news_min_to_next_high=Q3 | 490 | 56.7 | 48.0 | 18.7 | -129.1 | 32.3 | 79.7 | 35.8 | -1,608.0 | 231.5 | 442.3 | 330.0 | 2/2 | 2/2 | 1 |
| COMPRA | 300 | mtf_W1=BREAK_UP & atr_ratio_prev=Q1 | 1,138 | 51.3 | 42.0 | 18.5 | -116.9 | 30.2 | 70.4 | 63.2 | -875.0 | 186.9 | 446.5 | 525.0 | 3/3 | 4/6 | 1 |
| VENDA | 200 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 406 | 73.4 | 75.4 | 31.3 | -153.6 | 47.5 | 69.3 | 56.9 | -1,608.0 | 189.9 | 482.5 | 270.0 | 2/3 | 10/13 | 1 |
| VENDA | 200 | session=ASIA & month=4 | 1,339 | 70.8 | 63.9 | 31.3 | -153.6 | 47.5 | 67.4 | 34.8 | -1,608.0 | 190.7 | 440.4 | 255.0 | 2/2 | 2/2 | 1 |
| VENDA | 300 | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q3 | 406 | 53.7 | 52.5 | 18.7 | -129.1 | 32.3 | 65.8 | 61.2 | -1,608.0 | 222.3 | 541.5 | 360.0 | 2/3 | 9/13 | 1 |
| VENDA | 500 | month=4 & dom_w=d08_14 | 835 | 31.1 | 25.7 | 7.2 | -92.7 | 16.5 | 65.4 | 77.5 | -1,058.0 | 244.5 | 674.8 | 337.5 | 2/2 | 2/2 | 1 |
| VENDA | 200 | mtf_D1=RANGE & month=4 | 917 | 70.4 | 67.1 | 31.3 | -153.6 | 47.5 | 64.5 | 60.0 | -1,227.0 | 151.0 | 433.8 | 180.0 | 2/2 | 2/2 | 1 |
| COMPRA | 300 | news_min_since_last_high=Q3 & atr_ratio_prev=Q4 | 413 | 51.3 | 48.9 | 18.5 | -116.9 | 30.2 | 63.1 | 37.7 | -1,662.0 | 240.2 | 566.4 | 510.0 | 3/3 | 14/25 | 1 |
| VENDA | 200 | month=4 & dom_w=d08_14 | 835 | 69.7 | 65.9 | 31.3 | -153.6 | 47.5 | 61.6 | 64.9 | -1,058.0 | 164.0 | 498.0 | 150.0 | 2/2 | 2/2 | 1 |


---

## Limites

- Caminho do preço medido em candles M15 (alvo atingido se a máxima/mínima da vela alcança o preço); a ordem dentro da vela não importa para alvo único sem stop. - Período: 2024-01 a 2026-10 (708 dias); validação = últimos 40%. Ouro, FX e índices no mesmo regime de tendência. - A perda dos dias sem alvo usa o fechamento das 23:30; se você carregar a posição para o dia seguinte, a perda não está aqui. - Custos reais (comissão, slippage, swap de carregar) não incluídos.
