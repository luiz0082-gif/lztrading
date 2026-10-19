# Padrões por horário (hora do servidor) — ficha para anotar e validar no gráfico

**Como ler.** `entrada` = hora do servidor MT5 em que abre a vela de entrada; `londres` = servidor−2h; `ny` = servidor−7h. A operação dura `dur` minutos e sai no preço de lá. 1 operação por dia útil. `acerto` = % das vezes em que o preço terminou a favor (antes do custo). `lucro liq.` = % que fechou no lucro depois do spread. `≥100` e `≥300` = % que fechou com **lucro líquido** de pelo menos 100 / 300 pontos. `toca 300` = % que em algum momento chegou a +300 pontos a favor (mesmo devolvendo depois). Pontos são os do MT5 de cada ativo (XAUUSD: 300 pts = US$ 3,00; USDJPY: 300 pts = 0,300 ienes = 30 pips; EURs/AUD/NZD/CHF: 300 pts = 30 pips).

**Critérios:** o padrão tem que ter sido positivo líquido e significativo na **descoberta** (primeiros 60% do tempo, t ≥ 2,0) e **de novo na validação** (últimos 40%, t ≥ 1,645), mesmo sinal. Mesmo assim, em ~900-2.900 horários testados por timeframe, alguns passam por acaso: a coluna `placebo` diz quantos o mesmo filtro aceita com o retorno embaralhado no tempo. **Padrão de um timeframe só é confiável se `passaram` > `placebo_max`.** Comissão e slippage não estão incluídos.

**BTCUSD:** descartado a pedido (a mineração não achou nada).


---

## XAUUSD

Teste de confiabilidade por timeframe:

| tf | padroes_que_passaram | placebo_max | placebo_media | confiavel |
|---|---|---|---|---|
| M5 | 3.0 | 1.0 | 0.1 | SIM |
| M15 | 1.0 | 2.0 | 0.4 | nao distinguivel do acaso |
| M30 | 0.0 | 3.0 | 0.6 | nao distinguivel do acaso |
| H1 | 6.0 | 0.0 | 0.0 | SIM |


**Fichas (marque no gráfico):**

| lado | entrada | londres | ny | dur | tf | n | acerto% | lucro_liq% | ≥100pts% | ≥300pts% | toca_300% | media_pts | mediana_pts | custo_pts | anos_pos | meses_pos | confiavel |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 12:25 | 10:25 | 05:25 | 5 | M5 | 368 | 68.8 | 67.1 | 48.9 | 19.0 | 30.7 | 95.6 | 93.6 | 7.9 | 2/2 | 16/18 | SIM |
| COMPRA | 01:00 | 23:00 | 18:00 | 120 | H1 | 1,399 | 55.0 | 54.0 | 36.7 | 20.4 | 40.0 | 93.5 | 22.7 | 9.4 | 5/6 | 46/67 | SIM |
| COMPRA | 23:00 | 21:00 | 16:00 | 180 | H1 | 759 | 56.7 | 55.9 | 45.1 | 30.6 | 58.6 | 214.0 | 59.9 | 7.2 | 4/4 | 32/37 | SIM |
| COMPRA | 12:00 | 10:00 | 05:00 | 15 | M15 | 708 | 57.5 | 56.4 | 37.0 | 15.3 | 32.9 | 42.6 | 31.8 | 8.2 | 3/3 | 25/34 | nao distinguivel do acaso |


**Estabilidade e dias da semana:**

| lado | entrada_servidor | dur_min | tf | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|
| VENDA | 12:25 | 5 | M5 | 2025-05-15 | 2026-10-16 | 3.05 | 6.61 | 58.06 | 152.07 | 2025:+61; 2026:+123 | seg=66%(73) ter=72%(74) qua=65%(74) qui=63%(73) sex=70%(74) |
| COMPRA | 01:00 | 120 | H1 | 2021-04-27 | 2026-10-16 | 2.61 | 2.83 | 25.11 | 194.25 | 2021:+8; 2022:-13; 2023:+69; 2024:+43; 2025:+182; 2026:+280 | seg=47%(277) ter=54%(283) qua=51%(281) qui=63%(279) sex=55%(279) |
| COMPRA | 23:00 | 180 | H1 | 2023-08-07 | 2026-09-02 | 4.27 | 2.63 | 112.17 | 262.01 | 2023:+100; 2024:+107; 2025:+146; 2026:+539 | seg=57%(147) ter=49%(157) qua=66%(157) qui=57%(150) sex=49%(148) |
| COMPRA | 12:00 | 15 | M15 | 2024-01-22 | 2026-10-16 | 2.26 | 2.07 | 25.50 | 68.34 | 2024:+23; 2025:+26; 2026:+87 | seg=56%(143) ter=56%(143) qua=50%(141) qui=63%(141) sex=56%(140) |


**Últimas 12 ocorrências de cada ficha (hora do servidor → resultado líquido em pontos):**

- VENDA 12:25 (5 min, M5): 10-01 12:25 +102; 10-02 12:25 -170; 10-05 12:25 +174; 10-06 12:25 -80; 10-07 12:25 +83; 10-08 12:25 -144; 10-09 12:25 +148; 10-12 12:25 -37; 10-13 12:25 +180; 10-14 12:25 +95; 10-15 12:25 -172; 10-16 12:25 +381
- COMPRA 01:00 (120 min, H1): 10-01 01:00 -425; 10-02 01:00 +496; 10-05 01:00 +439; 10-06 01:00 -812; 10-07 01:00 -167; 10-08 01:00 -639; 10-09 01:00 +938; 10-12 01:00 -228; 10-13 01:00 -364; 10-14 01:00 -720; 10-15 01:00 +693; 10-16 01:00 -1547
- COMPRA 23:00 (180 min, H1): 08-18 23:00 -1261; 08-19 23:00 +47; 08-20 23:00 -248; 08-21 23:00 +713; 08-24 23:00 +2802; 08-25 23:00 -1223; 08-26 23:00 +2938; 08-27 23:00 -1489; 08-28 23:00 -9; 08-31 23:00 -107; 09-01 23:00 -267; 09-02 23:00 -558
- COMPRA 12:00 (15 min, M15): 10-01 12:00 +752; 10-02 12:00 +200; 10-05 12:00 -27; 10-06 12:00 -549; 10-07 12:00 -14; 10-08 12:00 -123; 10-09 12:00 -211; 10-12 12:00 +444; 10-13 12:00 +32; 10-14 12:00 +79; 10-15 12:00 +613; 10-16 12:00 +212

---

## USDJPY

Teste de confiabilidade por timeframe:

| tf | padroes_que_passaram | placebo_max | placebo_media | confiavel |
|---|---|---|---|---|
| M5 | 20.0 | 27.0 | 4.2 | nao distinguivel do acaso |
| M15 | 9.0 | 8.0 | 3.1 | SIM |
| M30 | 1.0 | 1.0 | 0.1 | nao distinguivel do acaso |
| H1 | 5.0 | 3.0 | 0.7 | SIM |


**Fichas (marque no gráfico):**

| lado | entrada | londres | ny | dur | tf | n | acerto% | lucro_liq% | ≥100pts% | ≥300pts% | toca_300% | media_pts | mediana_pts | custo_pts | anos_pos | meses_pos | confiavel |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 12:45 | 10:45 | 05:45 | 15 | M15 | 711 | 59.2 | 59.2 | 7.0 | 0.0 | 0.0 | 12.5 | 10.0 | 1.0 | 3/3 | 27/34 | SIM |
| VENDA | 23:00 | 21:00 | 16:00 | 120 | H1 | 952 | 69.0 | 56.9 | 16.3 | 3.2 | 5.7 | 23.6 | 10.0 | 21.3 | 4/6 | 40/64 | SIM |
| COMPRA | 05:45 | 03:45 | 22:45 | 15 | M15 | 711 | 58.2 | 58.2 | 6.0 | 0.4 | 0.7 | 10.2 | 8.2 | 0.9 | 3/3 | 22/34 | SIM |
| COMPRA | 22:55 | 20:55 | 15:55 | 5 | M5 | 370 | 62.2 | 61.1 | 1.4 | 0.0 | 0.0 | 10.1 | 8.4 | 1.1 | 2/2 | 18/18 | nao distinguivel do acaso |
| COMPRA | 01:10 | 23:10 | 18:10 | 5 | M5 | 368 | 56.5 | 56.5 | 0.8 | 0.0 | 0.0 | 5.1 | 4.7 | 0.8 | 2/2 | 16/18 | nao distinguivel do acaso |


**Estabilidade e dias da semana:**

| lado | entrada_servidor | dur_min | tf | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 12:45 | 15 | M15 | 2024-01-22 | 2026-10-16 | 4.78 | 2.42 | 15.66 | 7.82 | 2024:+13; 2025:+17; 2026:+6 | seg=59%(143) ter=60%(143) qua=61%(141) qui=52%(141) sex=63%(143) |
| VENDA | 23:00 | 120 | H1 | 2021-06-10 | 2026-10-15 | 3.03 | 1.95 | 27.25 | 19.50 | 2021:-14; 2022:-23; 2023:+48; 2024:+92; 2025:+12; 2026:+20 | seg=53%(183) ter=54%(193) qua=70%(207) qui=49%(196) sex=58%(173) |
| COMPRA | 05:45 | 15 | M15 | 2024-01-22 | 2026-10-16 | 3.50 | 1.87 | 12.52 | 6.67 | 2024:+19; 2025:+2; 2026:+9 | seg=57%(143) ter=61%(143) qua=61%(141) qui=55%(141) sex=57%(143) |
| COMPRA | 22:55 | 5 | M5 | 2025-05-15 | 2026-10-16 | 5.31 | 2.94 | 12.14 | 7.12 | 2025:+7; 2026:+13 | seg=58%(74) ter=69%(74) qua=53%(74) qui=70%(73) sex=56%(75) |
| COMPRA | 01:10 | 5 | M5 | 2025-05-16 | 2026-10-16 | 2.19 | 2.48 | 4.79 | 5.49 | 2025:+4; 2026:+6 | seg=59%(74) ter=54%(74) qua=64%(73) qui=53%(72) sex=52%(75) |


**Últimas 12 ocorrências de cada ficha (hora do servidor → resultado líquido em pontos):**

- COMPRA 12:45 (15 min, M15): 10-01 12:45 -38; 10-02 12:45 -69; 10-05 12:45 +8; 10-06 12:45 +36; 10-07 12:45 +72; 10-08 12:45 +27; 10-09 12:45 +79; 10-12 12:45 +1; 10-13 12:45 -9; 10-14 12:45 -7; 10-15 12:45 +21; 10-16 12:45 -31
- VENDA 23:00 (120 min, H1): 09-30 23:00 +9; 10-01 23:00 +22; 10-02 23:00 +21; 10-05 23:00 +2; 10-06 23:00 +10; 10-07 23:00 -40; 10-08 23:00 -10; 10-09 23:00 +12; 10-12 23:00 +19; 10-13 23:00 -35; 10-14 23:00 +8; 10-15 23:00 +91
- COMPRA 05:45 (15 min, M15): 10-01 05:45 -46; 10-02 05:45 +12; 10-05 05:45 +159; 10-06 05:45 +30; 10-07 05:45 +1; 10-08 05:45 +125; 10-09 05:45 -14; 10-12 05:45 +61; 10-13 05:45 -30; 10-14 05:45 -57; 10-15 05:45 -55; 10-16 05:45 -47
- COMPRA 22:55 (5 min, M5): 10-01 22:55 +63; 10-02 22:55 -36; 10-05 22:55 -2; 10-06 22:55 +4; 10-07 22:55 +6; 10-08 22:55 +19; 10-09 22:55 +8; 10-12 22:55 +33; 10-13 22:55 +27; 10-14 22:55 +37; 10-15 22:55 -8; 10-16 22:55 -10
- COMPRA 01:10 (5 min, M5): 10-01 01:10 +0; 10-02 01:10 +8; 10-05 01:10 -26; 10-06 01:10 +11; 10-07 01:10 +10; 10-08 01:10 -6; 10-09 01:10 +14; 10-12 01:10 -2; 10-13 01:10 -2; 10-14 01:10 -1; 10-15 01:10 -2; 10-16 01:10 +34

---

## NZDUSD

Teste de confiabilidade por timeframe:

| tf | padroes_que_passaram | placebo_max | placebo_media | confiavel |
|---|---|---|---|---|
| M5 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| M15 | 0.0 | 1.0 | 0.1 | nao distinguivel do acaso |
| M30 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| H1 | 3.0 | 0.0 | 0.0 | SIM |


**Fichas (marque no gráfico):**

| lado | entrada | londres | ny | dur | tf | n | acerto% | lucro_liq% | ≥100pts% | ≥300pts% | toca_300% | media_pts | mediana_pts | custo_pts | anos_pos | meses_pos | confiavel |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 01:00 | 23:00 | 18:00 | 75 | H1 | 1,384 | 65.9 | 54.3 | 6.7 | 0.4 | 0.9 | 8.0 | 7.0 | 16.6 | 6/6 | 45/65 | SIM |


**Estabilidade e dias da semana:**

| lado | entrada_servidor | dur_min | tf | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 01:00 | 75 | H1 | 2021-06-01 | 2026-10-16 | 3.40 | 2.34 | 8.65 | 6.99 | 2021:+10; 2022:+8; 2023:+12; 2024:+0; 2025:+5; 2026:+14 | seg=53%(276) ter=52%(277) qua=54%(275) qui=56%(278) sex=57%(278) |


**Últimas 12 ocorrências de cada ficha (hora do servidor → resultado líquido em pontos):**

- COMPRA 01:00 (75 min, H1): 10-01 01:00 -13; 10-02 01:00 -44; 10-05 01:00 -30; 10-06 01:00 -40; 10-07 01:00 -1; 10-08 01:00 -7; 10-09 01:00 +10; 10-12 01:00 +51; 10-13 01:00 -22; 10-14 01:00 +21; 10-15 01:00 +68; 10-16 01:00 +1

---

## USDCHF

Teste de confiabilidade por timeframe:

| tf | padroes_que_passaram | placebo_max | placebo_media | confiavel |
|---|---|---|---|---|
| M5 | 3.0 | 3.0 | 0.7 | nao distinguivel do acaso |
| M15 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| M30 | 0.0 | 1.0 | 0.1 | nao distinguivel do acaso |
| H1 | 0.0 | 1.0 | 0.3 | nao distinguivel do acaso |


**Fichas (marque no gráfico):**

| lado | entrada | londres | ny | dur | tf | n | acerto% | lucro_liq% | ≥100pts% | ≥300pts% | toca_300% | media_pts | mediana_pts | custo_pts | anos_pos | meses_pos | confiavel |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 15:05 | 13:05 | 08:05 | 5 | M5 | 370 | 67.6 | 65.7 | 0.3 | 0.0 | 0.0 | 7.5 | 8.1 | 2.0 | 2/2 | 16/18 | nao distinguivel do acaso |
| VENDA | 15:10 | 13:10 | 08:10 | 20 | M5 | 370 | 57.3 | 55.4 | 6.2 | 0.0 | 0.0 | 10.4 | 8.0 | 2.0 | 2/2 | 14/18 | nao distinguivel do acaso |


**Estabilidade e dias da semana:**

| lado | entrada_servidor | dur_min | tf | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|
| COMPRA | 15:05 | 5 | M5 | 2025-05-15 | 2026-10-16 | 4.46 | 2.92 | 8.98 | 5.36 | 2025:+11; 2026:+5 | seg=59%(74) ter=70%(74) qua=66%(74) qui=64%(73) sex=68%(75) |
| VENDA | 15:10 | 20 | M5 | 2025-05-15 | 2026-10-16 | 3.32 | 1.71 | 12.81 | 6.86 | 2025:+13; 2026:+8 | seg=38%(74) ter=53%(74) qua=54%(74) qui=67%(73) sex=65%(75) |


**Últimas 12 ocorrências de cada ficha (hora do servidor → resultado líquido em pontos):**

- COMPRA 15:05 (5 min, M5): 10-01 15:05 +7; 10-02 15:05 +37; 10-05 15:05 -9; 10-06 15:05 +29; 10-07 15:05 +50; 10-08 15:05 -17; 10-09 15:05 +1; 10-12 15:05 -8; 10-13 15:05 -9; 10-14 15:05 +22; 10-15 15:05 +4; 10-16 15:05 +50
- VENDA 15:10 (20 min, M5): 10-01 15:10 -17; 10-02 15:10 +6; 10-05 15:10 +32; 10-06 15:10 -64; 10-07 15:10 -36; 10-08 15:10 +49; 10-09 15:10 +7; 10-12 15:10 -33; 10-13 15:10 +11; 10-14 15:10 +29; 10-15 15:10 -25; 10-16 15:10 +3

---

## AUDUSD

Teste de confiabilidade por timeframe:

| tf | padroes_que_passaram | placebo_max | placebo_media | confiavel |
|---|---|---|---|---|
| M5 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| M15 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| M30 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| H1 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |

**Nenhum padrão de horário passou nos critérios.** Não há horário fixo para marcar neste ativo.


---

## US30

Teste de confiabilidade por timeframe:

| tf | padroes_que_passaram | placebo_max | placebo_media | confiavel |
|---|---|---|---|---|
| M5 | 0.0 | 1.0 | 0.2 | nao distinguivel do acaso |
| M15 | 0.0 | 1.0 | 0.2 | nao distinguivel do acaso |
| M30 | 0.0 | 4.0 | 0.4 | nao distinguivel do acaso |
| H1 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |

**Nenhum padrão de horário passou nos critérios.** Não há horário fixo para marcar neste ativo.


---

## DXY

Teste de confiabilidade por timeframe:

| tf | padroes_que_passaram | placebo_max | placebo_media | confiavel |
|---|---|---|---|---|
| M5 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| M15 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| M30 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |
| H1 | 0.0 | 0.0 | 0.0 | nao distinguivel do acaso |

**Nenhum padrão de horário passou nos critérios.** Não há horário fixo para marcar neste ativo.


---

## Resumo rápido

| ativo | janelas | quais |
|---|---|---|
| XAUUSD | 4 janela(s) | VENDA 12:25 5min, COMPRA 01:00 120min, COMPRA 23:00 180min, COMPRA 12:00 15min |
| USDJPY | 5 janela(s) | COMPRA 12:45 15min, VENDA 23:00 120min, COMPRA 05:45 15min, COMPRA 22:55 5min, COMPRA 01:10 5min |
| NZDUSD | 1 janela(s) | COMPRA 01:00 75min |
| USDCHF | 2 janela(s) | COMPRA 15:05 5min, VENDA 15:10 20min |
| AUDUSD | nenhum |  |
| US30 | nenhum |  |
| DXY | nenhum |  |

**Leitura honesta:** só o XAUUSD tem padrões de horário com ganho na escala de centenas de pontos por operação (e que passam no teste contra o acaso). Nos pares de moeda os ganhos médios são de poucos pontos (USDJPY: 5 a 24 pts; NZDUSD: 8 pts; USDCHF: 7 a 10 pts), então **+300 pontos de lucro líquido quase nunca ocorre** (0 a 3% das vezes); servem como curiosidade para conferir no gráfico, e vários não se distinguem do acaso (veja a coluna `confiavel`). AUDUSD, US30 e DXY não têm nenhum horário fixo que passe nos critérios. Padrões que dependem de uma condição além do horário (por exemplo, US30 vende às 23:00 UTC depois de vela de alta) estão nos relatórios por ativo, não aqui.
