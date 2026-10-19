# XAGUSD — padrões por horário (hora do servidor), para validar no gráfico

Entrada na **abertura** da vela do horário indicado (hora do servidor MT5 = UTC+3 no verão dos EUA / UTC+2 no inverno = Nova York+7h; Londres = servidor−2h). Saída `dur_min` minutos depois. Custo = spread medido nos ticks (perfil por horário). **Comissão e slippage não estão incluídos.** Só entram padrões que passaram na descoberta (primeiros 60% do tempo, t líquido ≥ 2,0) **e** na validação (últimos 40%, t líquido ≥ 1,645, mesmo sinal). 1 operação por dia útil.

| tf | eventos | inicio | fim | testes | passaram | placebo_media | placebo_max |
|---|---|---|---|---|---|---|---|
| M5 | 101,037 | 2025-05-15 | 2026-10-16 | 2,760 | 1 | 0.0 | 0 |
| M15 | 64,835 | 2024-01-22 | 2026-10-16 | 920 | 0 | 0.0 | 0 |
| M30 | 32,411 | 2024-01-22 | 2026-10-16 | 460 | 0 | 0.0 | 0 |
| H1 | 32,409 | 2021-04-27 | 2026-10-16 | 230 | 0 | 0.0 | 0 |

`passaram` = padrões que cumpriram os critérios. `placebo_media/max` = quantos o mesmo filtro aceita quando o retorno é deslocado aleatoriamente no tempo (o que é puro acaso). Se `passaram` não é bem maior que o placebo, o tipo de padrão daquele timeframe não é confiável.

## Janelas de horário (uma linha por janela; a linha mostra a variante de melhor validação)

`pct_acerto_bruto` = % das vezes o preço andou a seu favor até a saída (antes do custo); `pct_liquido_pos` = % que fechou no lucro depois do custo; `pct_liq_ge_X` = % que fechou com **lucro líquido ≥ X pontos**; `pct_toca_300` = % que em algum momento chegou a **+300 pontos a favor** durante a operação (mesmo que depois devolva).

| janela | lado | tf | entrada_servidor | londres | ny | dur_min | n | pct_acerto_bruto | pct_liquido_pos | pct_liq_ge_100 | pct_liq_ge_200 | pct_liq_ge_300 | pct_liq_ge_500 | pct_toca_300 | media_liq_pts | mediana_liq_pts | custo_medio_pts | variantes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01:20–03:25 | COMPRA | M5 | 01:20 | 23:20 | 18:20 | 125 | 362 | 56.4 | 47.5 | 33.7 | 24.9 | 18.8 | 13.3 | 36.7 | 96.1 | -8.2 | 28.6 | 1 |

## Estabilidade (para conferir no gráfico)

| janela | lado | tf | entrada_servidor | dur_min | n | primeiro | ultimo | t_desc | t_val | liq_desc | liq_val | anos_pos | meses_pos | por_ano | dias_acerto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01:20–03:25 | COMPRA | M5 | 01:20 | 125 | 362 | 2025-05-16 | 2026-10-16 | 2.03 | 1.73 | 117.54 | 64.35 | 1/2 | 11/18 | 2025:-2; 2026:+172 | seg=62%(71) ter=40%(73) qua=53%(73) qui=51%(72) sex=32%(73) |


## Como validar no gráfico

1. No MT5, abra o timeframe da coluna `tf`. 2. Use as datas dos arquivos `*_ocorrencias_<TF>.csv` (hora do servidor): vá até a data, marque a vela de `entrada_servidor` e veja onde o preço está `dur_min` minutos depois. 3. Conte quantas vezes foi a favor. Compare com `pct_acerto_bruto`. 4. Para anotar o próximo dia, o horário de entrada é o da coluna `entrada_servidor` (hora do servidor).


_(tempo 42s)_
