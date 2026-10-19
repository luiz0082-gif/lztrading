# EURJPY — padrões por horário (hora do servidor), para validar no gráfico

Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.

| tf | eventos | inicio | fim | testes | passaram | placebo_media | placebo_max |
|---|---|---|---|---|---|---|---|
| M5 | 106,214 | 2025-05-15 | 2026-10-16 | 2,880 | 7 | 2.2 | 13 |
| M15 | 68,213 | 2024-01-22 | 2026-10-16 | 960 | 2 | 0.7 | 3 |
| M30 | 34,097 | 2024-01-22 | 2026-10-16 | 480 | 0 | 0.0 | 0 |
| H1 | 34,093 | 2021-04-27 | 2026-10-16 | 240 | 0 | 0.0 | 0 |

`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.

## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)

`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).

| janela | lado | tf | entrada_servidor | londres | ny | dur_min | n | pct_acerto_bruto | pct_liquido_pos | pct_liq_ge_100 | pct_liq_ge_200 | pct_liq_ge_300 | pct_liq_ge_500 | pct_toca_300 | media_liq_pts | mediana_liq_pts | custo_medio_pts | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 20:55–23:15 | COMPRA | M5 | 21:10 | 19:10 | 14:10 | 125 | 366 | 62.0 | 59.8 | 22.7 | 6.3 | 1.6 | 0.5 | 3.8 | 31.0 | 22.3 | 5.5 | 8 |
| 14:25–15:30 | VENDA | M5 | 14:25 | 12:25 | 07:25 | 65 | 369 | 55.6 | 54.5 | 28.2 | 9.8 | 3.3 | 0.5 | 7.3 | 24.4 | 15.6 | 4.6 | 1 |

## Estabilidade (para conferir no gráfico)

| janela | lado | tf | entrada_servidor | dur_min | n | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | anos_pos | meses_pos | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 20:55–23:15 | COMPRA | M5 | 21:10 | 125 | 366 | 2025-05-16 | 2026-10-15 | 5.01 | 2.05 | 36.84 | 22.42 | 2/2 | 16/18 | 2025:+32; 2026:+31 | seg=65%(74) ter=54%(74) qua=67%(73) qui=57%(72) sex=56%(73) |
| 14:25–15:30 | VENDA | M5 | 14:25 | 65 | 369 | 2025-05-16 | 2026-10-16 | 2.70 | 1.79 | 27.49 | 19.87 | 2/2 | 13/18 | 2025:+34; 2026:+17 | seg=46%(74) ter=54%(74) qua=53%(74) qui=57%(72) sex=63%(75) |


## Como validar no gráfico

1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. 3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).


_(tempo 49s)_
