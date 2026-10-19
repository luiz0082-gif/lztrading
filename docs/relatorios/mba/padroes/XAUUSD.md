# XAUUSD — padrões por horário (hora do servidor), para validar no gráfico

Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.

| tf | eventos | inicio | fim | testes | passaram | placebo_media | placebo_max |
|---|---|---|---|---|---|---|---|
| M5 | 101,305 | 2025-05-15 | 2026-10-16 | 2,760 | 3 | 0.1 | 1 |
| M15 | 64,846 | 2024-01-22 | 2026-10-16 | 920 | 1 | 0.4 | 2 |
| M30 | 32,415 | 2024-01-22 | 2026-10-16 | 460 | 0 | 0.6 | 3 |
| H1 | 32,430 | 2021-04-27 | 2026-10-16 | 230 | 6 | 0.0 | 0 |

`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.

## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)

`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).

| janela | lado | tf | entrada_servidor | londres | ny | dur_min | n | pct_acerto_bruto | pct_liquido_pos | pct_liq_ge_100 | pct_liq_ge_200 | pct_liq_ge_300 | pct_liq_ge_500 | pct_toca_300 | media_liq_pts | mediana_liq_pts | custo_medio_pts | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 12:15–12:40 | VENDA | M5 | 12:25 | 10:25 | 05:25 | 5 | 368 | 68.8 | 67.1 | 48.9 | 30.4 | 19.0 | 6.5 | 30.7 | 95.6 | 93.6 | 7.9 | 3 |
| 01:00–03:00 | COMPRA | H1 | 01:00 | 23:00 | 18:00 | 120 | 1,399 | 55.0 | 54.0 | 36.7 | 25.9 | 20.4 | 14.1 | 40.0 | 93.5 | 22.7 | 9.4 | 2 |
| 23:00–02:00 | COMPRA | H1 | 23:00 | 21:00 | 16:00 | 180 | 759 | 56.7 | 55.9 | 45.1 | 36.5 | 30.6 | 22.7 | 58.6 | 214.0 | 59.9 | 7.2 | 4 |
| 12:00–12:15 | COMPRA | M15 | 12:00 | 10:00 | 05:00 | 15 | 708 | 57.5 | 56.4 | 37.0 | 25.1 | 15.3 | 7.3 | 32.9 | 42.6 | 31.8 | 8.2 | 1 |

## Estabilidade (para conferir no gráfico)

| janela | lado | tf | entrada_servidor | dur_min | n | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | anos_pos | meses_pos | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 12:15–12:40 | VENDA | M5 | 12:25 | 5 | 368 | 2025-05-15 | 2026-10-16 | 3.05 | 6.61 | 58.06 | 152.07 | 2/2 | 16/18 | 2025:+61; 2026:+123 | seg=66%(73) ter=72%(74) qua=65%(74) qui=63%(73) sex=70%(74) |
| 01:00–03:00 | COMPRA | H1 | 01:00 | 120 | 1,399 | 2021-04-27 | 2026-10-16 | 2.61 | 2.83 | 25.11 | 194.25 | 5/6 | 46/67 | 2021:+8; 2022:-13; 2023:+69; 2024:+43; 2025:+182; 2026:+280 | seg=47%(277) ter=54%(283) qua=51%(281) qui=63%(279) sex=55%(279) |
| 23:00–02:00 | COMPRA | H1 | 23:00 | 180 | 759 | 2023-08-07 | 2026-09-02 | 4.27 | 2.63 | 112.17 | 262.01 | 4/4 | 32/37 | 2023:+100; 2024:+107; 2025:+146; 2026:+539 | seg=57%(147) ter=49%(157) qua=66%(157) qui=57%(150) sex=49%(148) |
| 12:00–12:15 | COMPRA | M15 | 12:00 | 15 | 708 | 2024-01-22 | 2026-10-16 | 2.26 | 2.07 | 25.50 | 68.34 | 3/3 | 25/34 | 2024:+23; 2025:+26; 2026:+87 | seg=56%(143) ter=56%(143) qua=50%(141) qui=63%(141) sex=56%(140) |


## Como validar no gráfico

1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. 3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).


_(tempo 54s)_
