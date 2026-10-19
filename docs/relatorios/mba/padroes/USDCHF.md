# USDCHF — padrões por horário (hora do servidor), para validar no gráfico

Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.

| tf | eventos | inicio | fim | testes | passaram | placebo_media | placebo_max |
|---|---|---|---|---|---|---|---|
| M5 | 106,442 | 2025-05-15 | 2026-10-16 | 2,880 | 3 | 0.7 | 3 |
| M15 | 68,213 | 2024-01-22 | 2026-10-16 | 960 | 0 | 0.0 | 0 |
| M30 | 34,097 | 2024-01-22 | 2026-10-16 | 480 | 0 | 0.1 | 1 |
| H1 | 34,112 | 2021-04-27 | 2026-10-16 | 240 | 0 | 0.3 | 1 |

`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.

## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)

`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).

| janela | lado | tf | entrada_servidor | londres | ny | dur_min | n | pct_acerto_bruto | pct_liquido_pos | pct_liq_ge_100 | pct_liq_ge_200 | pct_liq_ge_300 | pct_liq_ge_500 | pct_toca_300 | media_liq_pts | mediana_liq_pts | custo_medio_pts | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 15:05–15:10 | COMPRA | M5 | 15:05 | 13:05 | 08:05 | 5 | 370 | 67.6 | 65.7 | 0.3 | 0.0 | 0.0 | 0.0 | 0.0 | 7.5 | 8.1 | 2.0 | 1 |
| 15:10–15:30 | VENDA | M5 | 15:10 | 13:10 | 08:10 | 20 | 370 | 57.3 | 55.4 | 6.2 | 0.5 | 0.0 | 0.0 | 0.0 | 10.4 | 8.0 | 2.0 | 2 |

## Estabilidade (para conferir no gráfico)

| janela | lado | tf | entrada_servidor | dur_min | n | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | anos_pos | meses_pos | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 15:05–15:10 | COMPRA | M5 | 15:05 | 5 | 370 | 2025-05-15 | 2026-10-16 | 4.46 | 2.92 | 8.98 | 5.36 | 2/2 | 16/18 | 2025:+11; 2026:+5 | seg=59%(74) ter=70%(74) qua=66%(74) qui=64%(73) sex=68%(75) |
| 15:10–15:30 | VENDA | M5 | 15:10 | 20 | 370 | 2025-05-15 | 2026-10-16 | 3.32 | 1.71 | 12.81 | 6.86 | 2/2 | 14/18 | 2025:+13; 2026:+8 | seg=38%(74) ter=53%(74) qua=54%(74) qui=67%(73) sex=65%(75) |


## Como validar no gráfico

1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. 3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).


_(tempo 57s)_
