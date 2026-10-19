# USDJPY — padrões por horário (hora do servidor), para validar no gráfico

Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.

| tf | eventos | inicio | fim | testes | passaram | placebo_media | placebo_max |
|---|---|---|---|---|---|---|---|
| M5 | 106,442 | 2025-05-15 | 2026-10-16 | 2,880 | 20 | 4.2 | 27 |
| M15 | 68,212 | 2024-01-22 | 2026-10-16 | 960 | 9 | 3.1 | 8 |
| M30 | 34,097 | 2024-01-22 | 2026-10-16 | 480 | 1 | 0.1 | 1 |
| H1 | 34,112 | 2021-04-27 | 2026-10-16 | 240 | 5 | 0.7 | 3 |

`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.

## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)

`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).

| janela | lado | tf | entrada_servidor | londres | ny | dur_min | n | pct_acerto_bruto | pct_liquido_pos | pct_liq_ge_100 | pct_liq_ge_200 | pct_liq_ge_300 | pct_liq_ge_500 | pct_toca_300 | media_liq_pts | mediana_liq_pts | custo_medio_pts | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 18:00–23:40 | COMPRA | M5 | 22:55 | 20:55 | 15:55 | 5 | 370 | 62.2 | 61.1 | 1.4 | 0.3 | 0.0 | 0.0 | 0.0 | 10.1 | 8.4 | 1.1 | 23 |
| 01:10–01:15 | COMPRA | M5 | 01:10 | 23:10 | 18:10 | 5 | 368 | 56.5 | 56.5 | 0.8 | 0.0 | 0.0 | 0.0 | 0.0 | 5.1 | 4.7 | 0.8 | 1 |
| 11:45–13:20 | COMPRA | M15 | 12:45 | 10:45 | 05:45 | 15 | 711 | 59.2 | 59.2 | 7.0 | 0.8 | 0.0 | 0.0 | 0.0 | 12.5 | 10.0 | 1.0 | 9 |
| 23:00–01:00 | VENDA | H1 | 23:00 | 21:00 | 16:00 | 120 | 952 | 69.0 | 56.9 | 16.3 | 5.8 | 3.2 | 1.4 | 5.7 | 23.6 | 10.0 | 21.3 | 1 |
| 05:45–06:00 | COMPRA | M15 | 05:45 | 03:45 | 22:45 | 15 | 711 | 58.2 | 58.2 | 6.0 | 1.5 | 0.4 | 0.0 | 0.7 | 10.2 | 8.2 | 0.9 | 1 |

## Estabilidade (para conferir no gráfico)

| janela | lado | tf | entrada_servidor | dur_min | n | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | anos_pos | meses_pos | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 18:00–23:40 | COMPRA | M5 | 22:55 | 5 | 370 | 2025-05-15 | 2026-10-16 | 5.31 | 2.94 | 12.14 | 7.12 | 2/2 | 18/18 | 2025:+7; 2026:+13 | seg=58%(74) ter=69%(74) qua=53%(74) qui=70%(73) sex=56%(75) |
| 01:10–01:15 | COMPRA | M5 | 01:10 | 5 | 368 | 2025-05-16 | 2026-10-16 | 2.19 | 2.48 | 4.79 | 5.49 | 2/2 | 16/18 | 2025:+4; 2026:+6 | seg=59%(74) ter=54%(74) qua=64%(73) qui=53%(72) sex=52%(75) |
| 11:45–13:20 | COMPRA | M15 | 12:45 | 15 | 711 | 2024-01-22 | 2026-10-16 | 4.78 | 2.42 | 15.66 | 7.82 | 3/3 | 27/34 | 2024:+13; 2025:+17; 2026:+6 | seg=59%(143) ter=60%(143) qua=61%(141) qui=52%(141) sex=63%(143) |
| 23:00–01:00 | VENDA | H1 | 23:00 | 120 | 952 | 2021-06-10 | 2026-10-15 | 3.03 | 1.95 | 27.25 | 19.50 | 4/6 | 40/64 | 2021:-14; 2022:-23; 2023:+48; 2024:+92; 2025:+12; 2026:+20 | seg=53%(183) ter=54%(193) qua=70%(207) qui=49%(196) sex=58%(173) |
| 05:45–06:00 | COMPRA | M15 | 05:45 | 15 | 711 | 2024-01-22 | 2026-10-16 | 3.50 | 1.87 | 12.52 | 6.67 | 3/3 | 22/34 | 2024:+19; 2025:+2; 2026:+9 | seg=57%(143) ter=61%(143) qua=61%(141) qui=55%(141) sex=57%(143) |


## Como validar no gráfico

1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. 3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).


_(tempo 58s)_
