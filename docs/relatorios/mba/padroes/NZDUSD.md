# NZDUSD — padrões por horário (hora do servidor), para validar no gráfico

Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.

| tf | eventos | inicio | fim | testes | passaram | placebo_media | placebo_max |
|---|---|---|---|---|---|---|---|
| M5 | 106,504 | 2025-05-15 | 2026-10-16 | 2,880 | 0 | 0.0 | 0 |
| M15 | 68,224 | 2024-01-22 | 2026-10-16 | 960 | 0 | 0.1 | 1 |
| M30 | 34,102 | 2024-01-22 | 2026-10-16 | 480 | 0 | 0.0 | 0 |
| H1 | 33,575 | 2021-05-26 | 2026-10-16 | 240 | 3 | 0.0 | 0 |

`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.

## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)

`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).

| janela | lado | tf | entrada_servidor | londres | ny | dur_min | n | pct_acerto_bruto | pct_liquido_pos | pct_liq_ge_100 | pct_liq_ge_200 | pct_liq_ge_300 | pct_liq_ge_500 | pct_toca_300 | media_liq_pts | mediana_liq_pts | custo_medio_pts | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01:00–02:30 | COMPRA | H1 | 01:00 | 23:00 | 18:00 | 75 | 1,384 | 65.9 | 54.3 | 6.7 | 1.3 | 0.4 | 0.1 | 0.9 | 8.0 | 7.0 | 16.6 | 3 |

## Estabilidade (para conferir no gráfico)

| janela | lado | tf | entrada_servidor | dur_min | n | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | anos_pos | meses_pos | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01:00–02:30 | COMPRA | H1 | 01:00 | 75 | 1,384 | 2021-06-01 | 2026-10-16 | 3.40 | 2.34 | 8.65 | 6.99 | 6/6 | 45/65 | 2021:+10; 2022:+8; 2023:+12; 2024:+0; 2025:+5; 2026:+14 | seg=53%(276) ter=52%(277) qua=54%(275) qui=56%(278) sex=57%(278) |


## Como validar no gráfico

1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. 3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).


_(tempo 59s)_
