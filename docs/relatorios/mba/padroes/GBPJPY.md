# GBPJPY — padrões por horário (hora do servidor), para validar no gráfico

Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.

| tf | eventos | inicio | fim | testes | passaram | placebo_media | placebo_max |
|---|---|---|---|---|---|---|---|
| M5 | 106,202 | 2025-05-15 | 2026-10-16 | 2,880 | 6 | 1.2 | 11 |
| M15 | 68,213 | 2024-01-22 | 2026-10-16 | 960 | 1 | 0.9 | 3 |
| M30 | 34,097 | 2024-01-22 | 2026-10-16 | 480 | 0 | 0.0 | 0 |
| H1 | 34,093 | 2021-04-27 | 2026-10-16 | 240 | 4 | 0.0 | 0 |

`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.

## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)

`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).

| janela | lado | tf | entrada_servidor | londres | ny | dur_min | n | pct_acerto_bruto | pct_liquido_pos | pct_liq_ge_100 | pct_liq_ge_200 | pct_liq_ge_300 | pct_liq_ge_500 | pct_toca_300 | media_liq_pts | mediana_liq_pts | custo_medio_pts | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 23:00–01:00 | VENDA | H1 | 23:00 | 21:00 | 16:00 | 120 | 1,044 | 72.0 | 54.2 | 24.0 | 10.2 | 5.0 | 2.4 | 19.8 | 29.5 | 11.2 | 52.4 | 1 |
| 20:55–23:30 | COMPRA | M5 | 21:10 | 19:10 | 14:10 | 125 | 367 | 64.3 | 62.9 | 32.2 | 12.8 | 3.3 | 0.5 | 7.9 | 38.3 | 36.6 | 6.5 | 10 |

## Estabilidade (para conferir no gráfico)

| janela | lado | tf | entrada_servidor | dur_min | n | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | anos_pos | meses_pos | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 23:00–01:00 | VENDA | H1 | 23:00 | 120 | 1,044 | 2021-06-07 | 2026-10-15 | 3.01 | 2.34 | 29.42 | 29.61 | 5/6 | 43/65 | 2021:+3; 2022:-22; 2023:+50; 2024:+68; 2025:+27; 2026:+29 | seg=49%(220) ter=46%(226) qua=63%(238) qui=46%(223) sex=75%(137) |
| 20:55–23:30 | COMPRA | M5 | 21:10 | 125 | 367 | 2025-05-16 | 2026-10-15 | 4.73 | 1.73 | 47.73 | 24.15 | 2/2 | 15/18 | 2025:+43; 2026:+35 | seg=65%(74) ter=59%(74) qua=70%(74) qui=60%(72) sex=60%(73) |


## Como validar no gráfico

1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. 3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).


_(tempo 48s)_
