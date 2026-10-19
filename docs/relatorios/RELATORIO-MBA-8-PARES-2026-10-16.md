# MBA — varredura completa dos 8 pares (comparativo)

Ativos: AUDUSD, BTCUSD, DXY, NZDUSD, US30, USDCHF, USDJPY, XAUUSD. Cada ativo tem seu relatório detalhado em `docs/relatorios/mba/ativos/<ATIVO>/<ATIVO>.md` (modos `ret` e `hit`) e `<ATIVO>_open.md` (modo `open`), com os CSV de apoio na mesma pasta.

## 0. Leia primeiro (conclusões desta rodada, escritas após ler os resultados)

**Escopo:** XAUUSD (IC), AUDUSD, BTCUSD, NZDUSD, US30, USDCHF, USDJPY e DXY (os 8 que sobraram; o XAUUSD da FP ficou fora a pedido). Três modos de mineração (`ret`, `hit` e `open`), 4 timeframes (M5-H1), 53-70 variáveis em pares, 6 horizontes ou séries por variável, descoberta/validação cronológicas, BH, placebo, custo por spread medido nos ticks com perfil de domingo, vantagem exigida contra a média de todas as velas e sensibilidade a comissão.

**1. O custo decide quase tudo.** Spread dos ticks dividido pelo ATR M5: XAUUSD 0,02; US30 0,04; USDJPY 0,07; BTCUSD 0,11; USDCHF 0,22; NZDUSD 0,26; AUDUSD 0,63; DXY 1,19. AUDUSD (FP) e DXY têm spread de mesma ordem que o movimento de 5 minutos: nada para operar no curto prazo, e foi isso que a mineração mostrou (AUDUSD: 5 candidatas, todas de abertura de domingo; DXY: 0).

**2. O spread gravado na barra engana.** Nas contas ECN o campo é 0 em 87% das barras do USDJPY e 41% do USDCHF, e fica abaixo do spread real nos demais. Uma primeira versão deste relatório usava esse campo e produziu candidatas falsas (principalmente vendas na rolagem). O custo foi refeito com o spread medido nos ticks (mediana por slot de 30 min do relógio de Nova York, domingo à parte).

**3. Há muita estrutura de relógio, mas a maior parte está na rolagem diária e na abertura de domingo.** Pares de FX têm retornos médios altamente significativos nas velas de 20-23 UTC (por exemplo H1 das 22 UTC: AUDUSD +0,15 ATR t=13,5; NZDUSD +0,19 t=13,5; USDCHF +0,27 t=21,7) e no domingo. Isso é o preço de Bid se movendo com o spread alargado/normalizando; comprar a esse preço custa o spread do momento. Por isso milhares de células "confirmadas" no bruto viram poucas famílias com líquido positivo, e as que sobram nessa faixa merecem desconfiança extra.

**4. O método funciona onde há sinal.** Como teste de controle, o modo `open` reencontrou **de forma independente** o seu padrão do ouro: vender a abertura do candle M5 das 09:25 UTC (10:25 de Londres no verão), com cerca de +152 pontos líquidos por operação na validação, positivo nos dois anos e em 15 de 18 meses (veja `XAUUSD_open.md`). Ele aparece como exploratório (não passa no BH porque a amostra do M5 são só 17 meses e o corte de múltiplos testes é severo), não como "reprovado".

**5. Candidatas mais limpas (categoria 4, vantagem contra a média, BH, duas metades positivas, líquido positivo), por ativo** (detalhe na seção 5):
- **XAUUSD:** 6, todas **compra** (o ouro subiu muito no período; a vantagem sobre a média das velas é moderada, t entre 1,7 e 2,8), com +50 a +150 pontos líquidos por operação; sobrevivem a uma comissão de US$ 7/lote (7 pontos). Mais a venda das 09:25 UTC como exploratória.
- **USDJPY:** 29 depois de comissão hipotética de US$ 7 (11 pontos). A mais robusta: venda após vela baixista das 23:00 UTC (H1, 5 min), +6,6 pontos após comissão, 6 de 6 anos; a compra das 09:30 UTC (M15) fica em +1,4 após comissão, marginal. Efeitos de sessão Asia (+6 pontos por 15 min) morrem na comissão.
- **USDCHF e NZDUSD:** compras às 21-22 UTC (rolagem) e vendas às 20 UTC; ficam positivas após comissão só por 2 a 15 pontos e estão na zona suspeita de artefato do Bid.
- **US30:** venda das 23:00 UTC por 5 min (H1), +217 a +408 pontos (2 a 4 pontos do índice) por operação, 6 de 6 anos, sem comissão. Execução às 23:00 UTC (19:00 NY, fora do horário cash) é incerta.
- **BTCUSD:** nenhuma (a única candidata é `hit` sem perdedores observados). **AUDUSD:** só abertura de domingo. **DXY:** nenhuma.

**6. Sobre sem stop:** o modo `hit` assume o seu perfil. Alvos pequenos sem stop acertam quase sempre, e a amostra de 2 a 5 anos quase não contém a perda rara e grande; por isso as candidatas `hit` com poucos perdedores ficam na categoria 2, fora da lista limpa.

**7. Dados e ferramentas.** O M1 dos candles ficou incompleto por um bug do EA (`InpMaxCatchupBars` pulava o histórico; corrigido na v1.23.1, mas é preciso reiniciar e reconstruir o M1). Esta rodada usou eventos M5/M15/M30/H1 e mediu o futuro nas barras M1 que o terminal já tem; **eventos M1 não foram minerados**. Todos os resultados são retrospectivos; nada foi testado com execução real ou em dados novos.


## 1. Como ler

- **Descoberta/validação:** primeiros 60% do tempo para procurar, últimos 40% (com 1 dia de intervalo) para confirmar. O corte é cronológico.
- **BH:** correção de múltiplos testes (Benjamini-Hochberg, q=5%) sobre todas as células testadas na descoberta.
- **Placebo:** o mesmo procedimento com o retorno deslocado aleatoriamente no tempo (6x por timeframe). O que o placebo também produz é acaso.
- **Custo realista (v3):** o spread gravado na barra é zero em grande parte das barras de contas ECN e fica abaixo do spread real; por isso o custo é `max(spread da barra, mediana do spread medido nos ticks no mesmo slot de 30 min do relógio de Nova York)`, com perfil próprio para domingo. Compra paga o spread na entrada; venda paga na saída (no modo `hit`, no instante em que o alvo é atingido).
- **Modo `ret`:** entra no FECHAMENTO do candle-evento; retorno bruto em horizonte fixo (5-240 min). **Modo `hit`:** idem, com alvo de 0,5/1/2 ATR **sem stop** e saída por tempo (15/60/240 min). **Modo `open`:** entra na ABERTURA do candle-evento e mede o próprio candle e o que vem depois; só usa variáveis conhecidas antes da abertura (é o formato do padrão das 10:25 de Londres no ouro).
- **Família:** conjunto de condições que seleciona exatamente as mesmas velas é contado uma vez (`n_formas_equivalentes`).
- **Candidata:** família com BH na descoberta, mesmo sinal na validação, líquido positivo e t>1,645 na validação com custo realista, **diferença significativa (t>1,645) contra o resultado médio de todas as velas** (elimina deriva/tendência do ativo) e líquido positivo nas duas metades da validação.
- **Categorias das candidatas:** (1) abertura de semana, onde a execução real é a menos confiável; (2) `hit` sem perdedores observados, em que o risco de cauda sem stop não aparece na amostra; (3) sexta, perto do fechamento semanal; (4) demais.

## 2. Cobertura e custo por ativo

| ativo | M5_candles | M5_inicio | H1_candles | H1_inicio | D1_candles | D1_inicio | spread_ticks_pts | ATR_M5_pts | spread/ATR | %barras_spread=0 | pior_hora_utc | pior_spread/ATR | melhor_hora_utc | melhor_spread/ATR |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| AUDUSD | 106,505 | 2025-05-15 | 34,104 | 2021-04-27 | 2,569 | 2016-11-21 | 15.97 | 25.27 | 0.63 | 0.00 | 21 | 2.65 | 14 | 0.35 |
| BTCUSD | 106,928 | 2025-05-15 | 34,140 | 2021-04-27 | 1,700 | 2020-04-01 | 1,598.88 | 14,907.18 | 0.11 | 0.00 | 11 | 0.14 | 15 | 0.07 |
| DXY | 94,349 | 2025-05-15 | 11,529 | 2024-09-11 | 519 | 2024-10-11 | 30.00 | 25.25 | 1.19 | 0.00 | 4 | 1.96 | 14 | 0.74 |
| NZDUSD | 106,504 | 2025-05-15 | 33,575 | 2021-05-26 | 1,377 | 2021-06-28 | 6.36 | 24.27 | 0.26 | 9.63 | 21 | 2.15 | 14 | 0.09 |
| US30 | 101,153 | 2025-05-15 | 32,366 | 2021-04-27 | 2,557 | 2016-11-21 | 104.49 | 2,465.96 | 0.04 | 0.67 | 4 | 0.11 | 14 | 0.01 |
| USDCHF | 106,442 | 2025-05-15 | 34,112 | 2021-04-27 | 2,569 | 2016-11-21 | 5.70 | 26.20 | 0.22 | 41.21 | 21 | 3.81 | 15 | 0.03 |
| USDJPY | 106,442 | 2025-05-15 | 34,112 | 2021-04-27 | 2,569 | 2016-11-21 | 3.66 | 49.46 | 0.07 | 87.14 | 21 | 2.16 | 1 | 0.01 |
| XAUUSD | 101,305 | 2025-05-15 | 32,430 | 2021-04-27 | 2,555 | 2016-11-21 | 8.43 | 421.06 | 0.02 | 3.97 | 22 | 0.03 | 14 | 0.01 |

`spread/ATR` perto de 0,1 é operável em prazos de minutos; acima de ~0,3 o custo come o movimento típico. `%barras_spread=0` mostra o quanto o campo gravado na barra é inútil para custo.

## 3. Mineração: quanto passa além do placebo

`confirmadas` = células que passaram no BH na descoberta e repetiram o sinal na validação (podem ser muitas por serem a mesma coisa descrita de formas diferentes; veja as famílias). `placebo_conf_max` = o máximo que o placebo produziu.

| ativo | tf | modo | eventos | hipoteses | passou_BH | confirmadas | placebo_BH_media | placebo_conf_media | placebo_conf_max | top100_repete_pct | placebo_top100_pct |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AUDUSD | M5 | ret | 106,118 | 210,310 | 442 | 209 | 0.0 | 0.0 | 0 | 33.0 | 4.2 |
| AUDUSD | M15 | ret | 67,820 | 221,592 | 198 | 152 | 0.0 | 0.0 | 0 | 74.0 | 7.0 |
| AUDUSD | M30 | ret | 33,761 | 191,066 | 289 | 214 | 0.0 | 0.0 | 0 | 80.0 | 5.0 |
| AUDUSD | H1 | ret | 32,824 | 195,752 | 1,493 | 1,074 | 0.0 | 0.0 | 0 | 96.0 | 7.0 |
| AUDUSD | M5 | hit | 106,118 | 629,874 | 1 | 0 | 1.5 | 0.0 | 0 | 1.0 | 1.3 |
| AUDUSD | M15 | hit | 67,820 | 661,254 | 3 | 0 | 0.0 | 0.0 | 0 | 0.0 | 1.0 |
| AUDUSD | M30 | hit | 33,761 | 569,964 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.3 |
| AUDUSD | H1 | hit | 32,824 | 583,080 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.2 |
| AUDUSD | M5 | open | 106,118 | 72,814 | 369 | 174 | 0.3 | 0.0 | 0 | 55.0 | 6.3 |
| AUDUSD | M15 | open | 67,820 | 80,115 | 633 | 554 | 0.0 | 0.0 | 0 | 95.0 | 8.3 |
| AUDUSD | M30 | open | 33,761 | 62,887 | 776 | 687 | 0.3 | 0.0 | 0 | 96.0 | 8.5 |
| AUDUSD | H1 | open | 32,824 | 64,251 | 1,767 | 1,616 | 0.0 | 0.0 | 0 | 100.0 | 6.7 |
| BTCUSD | M5 | ret | 106,757 | 205,958 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 5.0 |
| BTCUSD | M15 | ret | 68,201 | 214,935 | 2 | 0 | 0.5 | 0.0 | 0 | 10.0 | 5.8 |
| BTCUSD | M30 | ret | 34,040 | 186,568 | 0 | 0 | 0.0 | 0.0 | 0 | 9.0 | 3.2 |
| BTCUSD | H1 | ret | 32,635 | 188,414 | 3 | 0 | 0.0 | 0.0 | 0 | 16.0 | 2.8 |
| BTCUSD | M5 | hit | 106,757 | 617,238 | 19 | 1 | 18.7 | 1.2 | 2 | 7.0 | 6.7 |
| BTCUSD | M15 | hit | 68,201 | 641,046 | 0 | 0 | 0.2 | 0.0 | 0 | 2.0 | 2.0 |
| BTCUSD | M30 | hit | 34,040 | 556,242 | 0 | 0 | 0.2 | 0.0 | 0 | 6.0 | 0.8 |
| BTCUSD | H1 | hit | 32,635 | 559,188 | 0 | 0 | 0.2 | 0.0 | 0 | 1.0 | 0.8 |
| BTCUSD | M5 | open | 106,757 | 72,035 | 0 | 0 | 0.0 | 0.0 | 0 | 1.0 | 7.0 |
| BTCUSD | M15 | open | 68,201 | 77,571 | 0 | 0 | 0.2 | 0.0 | 0 | 13.0 | 5.0 |
| BTCUSD | M30 | open | 34,040 | 61,500 | 0 | 0 | 0.0 | 0.0 | 0 | 8.0 | 4.2 |
| BTCUSD | H1 | open | 32,635 | 62,579 | 2 | 0 | 0.0 | 0.0 | 0 | 17.0 | 4.2 |
| DXY | M5 | ret | 93,895 | 196,863 | 0 | 0 | 0.0 | 0.0 | 0 | 20.0 | 2.8 |
| DXY | M15 | ret | 45,952 | 191,443 | 0 | 0 | 0.0 | 0.0 | 0 | 8.0 | 2.7 |
| DXY | M30 | ret | 22,984 | 164,218 | 0 | 0 | 0.0 | 0.0 | 0 | 11.0 | 3.7 |
| DXY | H1 | ret | 11,498 | 116,724 | 0 | 0 | 0.0 | 0.0 | 0 | 8.0 | 4.3 |
| DXY | M5 | hit | 93,895 | 586,110 | 0 | 0 | 0.0 | 0.0 | 0 | 2.0 | 0.2 |
| DXY | M15 | hit | 45,952 | 569,502 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.3 |
| DXY | M30 | hit | 22,984 | 486,186 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.5 |
| DXY | H1 | hit | 11,498 | 345,264 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.0 |
| DXY | M5 | open | 93,895 | 66,078 | 3 | 0 | 0.0 | 0.0 | 0 | 26.0 | 3.2 |
| DXY | M15 | open | 45,952 | 59,683 | 0 | 0 | 0.0 | 0.0 | 0 | 2.0 | 3.0 |
| DXY | M30 | open | 22,984 | 48,810 | 0 | 0 | 0.0 | 0.0 | 0 | 4.0 | 3.2 |
| DXY | H1 | open | 11,498 | 29,872 | 0 | 0 | 0.0 | 0.0 | 0 | 12.0 | 0.3 |
| NZDUSD | M5 | ret | 106,047 | 210,558 | 222 | 123 | 0.0 | 0.0 | 0 | 56.0 | 5.5 |
| NZDUSD | M15 | ret | 67,132 | 218,176 | 724 | 387 | 0.0 | 0.0 | 0 | 69.0 | 11.0 |
| NZDUSD | M30 | ret | 33,093 | 187,319 | 630 | 381 | 2.2 | 0.2 | 1 | 69.0 | 9.2 |
| NZDUSD | H1 | ret | 31,456 | 188,271 | 2,082 | 1,508 | 1.7 | 0.0 | 0 | 98.0 | 9.7 |
| NZDUSD | M5 | hit | 106,047 | 630,414 | 13 | 0 | 7.8 | 0.0 | 0 | 1.0 | 3.5 |
| NZDUSD | M15 | hit | 67,132 | 647,910 | 4 | 0 | 0.2 | 0.0 | 0 | 4.0 | 3.2 |
| NZDUSD | M30 | hit | 33,093 | 555,810 | 2 | 0 | 0.0 | 0.0 | 0 | 2.0 | 1.3 |
| NZDUSD | H1 | hit | 31,456 | 557,178 | 12 | 0 | 0.0 | 0.0 | 0 | 0.0 | 0.8 |
| NZDUSD | M5 | open | 106,047 | 72,050 | 105 | 73 | 0.2 | 0.0 | 0 | 68.0 | 5.2 |
| NZDUSD | M15 | open | 67,132 | 78,201 | 1,297 | 849 | 1.5 | 0.0 | 0 | 87.0 | 11.7 |
| NZDUSD | M30 | open | 33,093 | 61,364 | 1,270 | 904 | 3.8 | 0.3 | 1 | 94.0 | 18.7 |
| NZDUSD | H1 | open | 31,456 | 60,826 | 1,997 | 1,752 | 7.8 | 1.0 | 4 | 100.0 | 13.5 |
| US30 | M5 | ret | 100,931 | 206,632 | 0 | 0 | 0.0 | 0.0 | 0 | 3.0 | 4.8 |
| US30 | M15 | ret | 64,600 | 215,277 | 0 | 0 | 0.0 | 0.0 | 0 | 9.0 | 6.5 |
| US30 | M30 | ret | 32,298 | 186,330 | 0 | 0 | 0.2 | 0.0 | 0 | 4.0 | 5.3 |
| US30 | H1 | ret | 32,283 | 188,303 | 151 | 15 | 0.2 | 0.0 | 0 | 11.0 | 10.0 |
| US30 | M5 | hit | 100,931 | 615,240 | 44 | 9 | 37.3 | 2.8 | 5 | 12.0 | 7.5 |
| US30 | M15 | hit | 64,600 | 641,046 | 2 | 0 | 1.5 | 0.0 | 0 | 1.0 | 2.5 |
| US30 | M30 | hit | 32,298 | 554,178 | 0 | 0 | 0.0 | 0.0 | 0 | 0.0 | 2.5 |
| US30 | H1 | hit | 32,283 | 560,958 | 0 | 0 | 0.0 | 0.0 | 0 | 2.0 | 2.3 |
| US30 | M5 | open | 100,931 | 72,195 | 0 | 0 | 0.0 | 0.0 | 0 | 5.0 | 3.7 |
| US30 | M15 | open | 64,600 | 77,642 | 0 | 0 | 0.0 | 0.0 | 0 | 4.0 | 5.8 |
| US30 | M30 | open | 32,298 | 61,589 | 0 | 0 | 0.0 | 0.0 | 0 | 6.0 | 5.3 |
| US30 | H1 | open | 32,283 | 61,399 | 0 | 0 | 0.0 | 0.0 | 0 | 22.0 | 5.7 |
| USDCHF | M5 | ret | 105,987 | 206,976 | 1,081 | 721 | 42.2 | 7.8 | 17 | 76.0 | 23.3 |
| USDCHF | M15 | ret | 67,894 | 221,197 | 2,020 | 1,747 | 15.2 | 3.8 | 23 | 94.0 | 12.3 |
| USDCHF | M30 | ret | 33,888 | 190,690 | 2,051 | 1,864 | 70.8 | 5.8 | 26 | 98.0 | 6.3 |
| USDCHF | H1 | ret | 33,052 | 191,781 | 5,627 | 4,298 | 0.2 | 0.0 | 0 | 100.0 | 7.2 |
| USDCHF | M5 | hit | 105,987 | 617,868 | 4 | 0 | 14.8 | 0.5 | 2 | 7.0 | 2.8 |
| USDCHF | M15 | hit | 67,894 | 658,596 | 0 | 0 | 0.0 | 0.0 | 0 | 6.0 | 1.5 |
| USDCHF | M30 | hit | 33,888 | 567,384 | 0 | 0 | 0.0 | 0.0 | 0 | 9.0 | 2.2 |
| USDCHF | H1 | hit | 33,052 | 568,368 | 62 | 5 | 0.0 | 0.0 | 0 | 10.0 | 1.3 |
| USDCHF | M5 | open | 105,987 | 70,159 | 679 | 450 | 25.5 | 4.7 | 13 | 76.0 | 15.0 |
| USDCHF | M15 | open | 67,894 | 79,660 | 1,652 | 1,439 | 16.5 | 7.0 | 42 | 100.0 | 15.3 |
| USDCHF | M30 | open | 33,888 | 62,715 | 1,593 | 1,474 | 22.5 | 5.2 | 28 | 100.0 | 14.2 |
| USDCHF | H1 | open | 33,052 | 61,856 | 2,273 | 2,073 | 2.0 | 0.2 | 1 | 100.0 | 13.3 |
| USDJPY | M5 | ret | 105,989 | 209,902 | 14 | 8 | 0.2 | 0.0 | 0 | 56.0 | 9.3 |
| USDJPY | M15 | ret | 68,019 | 220,756 | 147 | 93 | 0.0 | 0.0 | 0 | 67.0 | 8.2 |
| USDJPY | M30 | ret | 33,970 | 190,467 | 212 | 126 | 0.2 | 0.0 | 0 | 64.0 | 8.0 |
| USDJPY | H1 | ret | 33,106 | 194,150 | 3,399 | 1,660 | 150.5 | 54.3 | 136 | 100.0 | 44.8 |
| USDJPY | M5 | hit | 105,989 | 626,514 | 8 | 0 | 9.7 | 0.3 | 2 | 5.0 | 3.8 |
| USDJPY | M15 | hit | 68,019 | 657,186 | 56 | 15 | 0.0 | 0.0 | 0 | 24.0 | 2.5 |
| USDJPY | M30 | hit | 33,970 | 566,952 | 3 | 2 | 0.3 | 0.0 | 0 | 9.0 | 3.8 |
| USDJPY | H1 | hit | 33,106 | 576,252 | 121 | 16 | 0.0 | 0.0 | 0 | 10.0 | 3.5 |
| USDJPY | M5 | open | 105,989 | 73,060 | 47 | 25 | 0.3 | 0.2 | 1 | 55.0 | 14.7 |
| USDJPY | M15 | open | 68,019 | 80,155 | 124 | 96 | 0.3 | 0.0 | 0 | 76.0 | 16.3 |
| USDJPY | M30 | open | 33,970 | 63,105 | 135 | 114 | 0.0 | 0.0 | 0 | 88.0 | 9.5 |
| USDJPY | H1 | open | 33,106 | 63,067 | 716 | 466 | 4.2 | 0.7 | 3 | 97.0 | 22.7 |
| XAUUSD | M5 | ret | 100,835 | 198,897 | 1 | 0 | 0.0 | 0.0 | 0 | 2.0 | 4.3 |
| XAUUSD | M15 | ret | 64,772 | 208,245 | 1 | 0 | 1.7 | 0.0 | 0 | 8.0 | 15.3 |
| XAUUSD | M30 | ret | 32,361 | 177,376 | 9 | 2 | 1.2 | 0.0 | 0 | 19.0 | 8.8 |
| XAUUSD | H1 | ret | 31,777 | 184,266 | 97 | 18 | 0.0 | 0.0 | 0 | 18.0 | 5.0 |
| XAUUSD | M5 | hit | 100,835 | 593,040 | 25 | 0 | 21.7 | 2.7 | 6 | 6.0 | 6.0 |
| XAUUSD | M15 | hit | 64,772 | 620,034 | 0 | 0 | 0.5 | 0.0 | 0 | 2.0 | 3.0 |
| XAUUSD | M30 | hit | 32,361 | 527,718 | 0 | 0 | 0.2 | 0.0 | 0 | 16.0 | 1.3 |
| XAUUSD | H1 | hit | 31,777 | 546,858 | 0 | 0 | 0.2 | 0.0 | 0 | 4.0 | 3.8 |
| XAUUSD | M5 | open | 100,835 | 66,586 | 4 | 0 | 0.0 | 0.0 | 0 | 12.0 | 6.7 |
| XAUUSD | M15 | open | 64,772 | 74,418 | 31 | 4 | 23.3 | 0.0 | 0 | 18.0 | 21.0 |
| XAUUSD | M30 | open | 32,361 | 58,683 | 15 | 4 | 11.5 | 0.2 | 1 | 19.0 | 11.2 |
| XAUUSD | H1 | open | 31,777 | 60,317 | 12 | 10 | 0.2 | 0.0 | 0 | 53.0 | 8.0 |

Totais por modo:

| modo | hipoteses | passou_BH | confirmadas | placebo_max_soma |
|---|---|---|---|---|
| hit | 18,694,452 | 379 | 48 | 17 |
| open | 2,117,242 | 15,500 | 12,764 | 94 |
| ret | 6,279,412 | 20,895 | 14,600 | 203 |

## 4. Famílias validadas por ativo

| ativo | familias_validadas | liquido_positivo | candidatas |
|---|---|---|---|
| AUDUSD | 12,388 | 74 | 5 |
| BTCUSD | 2,230 | 402 | 1 |
| DXY | 1,452 | 7 | 0 |
| NZDUSD | 12,673 | 289 | 68 |
| US30 | 1,666 | 581 | 12 |
| USDCHF | 26,928 | 477 | 48 |
| USDJPY | 13,906 | 2,897 | 161 |
| XAUUSD | 4,679 | 2,039 | 10 |

Candidatas por categoria:

| ativo | 1 abertura de semana (domingo/gap) | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 3 sexta (proximo ao fechamento semanal) | 4 demais |
|---|---|---|---|---|
| AUDUSD | 5 | 0 | 0 | 0 |
| BTCUSD | 0 | 1 | 0 | 0 |
| NZDUSD | 27 | 0 | 2 | 39 |
| US30 | 0 | 9 | 0 | 3 |
| USDCHF | 0 | 0 | 20 | 28 |
| USDJPY | 53 | 3 | 6 | 99 |
| XAUUSD | 4 | 0 | 0 | 6 |

## 5. Candidatas da categoria 4 (demais) — as mais limpas

Cada linha é uma família distinta. Ainda é evidência **retrospectiva**: o próximo passo seria acompanhar semanas de dados novos (forward) antes de qualquer decisão.

| ativo | tf | modo | condicao | serie | lado | n_val | bruto_pts_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos | custo_medio_pts | comissao_RT_pts_7usd | liq_apos_comissao | n_formas_equivalentes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| USDJPY | H1 | ret | slot_hhmm=23:00 & direction=BEARISH | 5min | VENDA | 249 | 18.75 | 17.68 | -1.60 | 4.03 | 3.66 | 61.04 | 6/6 | 45/61 | 1.06 | 11.06 | 6.63 | 2 |
| USDJPY | H1 | ret | mtf_M1=BULLISH & upper_wick_pct=Q5 | 5min | VENDA | 997 | 10.69 | 6.56 | -1.60 | 4.63 | 3.65 | 52.66 | 4/6 | 40/65 | 4.12 | 11.06 | -4.50 | 1 |
| USDJPY | H1 | ret | session=ASIA & direction=BEARISH | 15min | VENDA | 2,126 | 7.54 | 6.61 | -2.17 | 4.57 | 3.16 | 51.74 | 6/6 | 49/65 | 0.93 | 11.06 | -4.45 | 1 |
| USDJPY | H1 | ret | session=ASIA & swing_low_distance_atr=Q1 | 15min | VENDA | 1,085 | 10.91 | 9.98 | -2.17 | 3.94 | 3.08 | 54.01 | 6/6 | 46/65 | 0.93 | 11.06 | -1.08 | 1 |
| NZDUSD | H1 | ret | session=OFF_SESSION & mtf_D1=BULLISH | 5min | COMPRA | 302 | 9.61 | 4.49 | -4.26 | 5.97 | 3.05 | 55.96 | 4/6 | 31/45 | 5.12 | 7.00 | -2.51 | 1 |
| USDJPY | H1 | ret | slot_hhmm=02:00 & volatility_state=LOW | 5min | VENDA | 224 | 9.28 | 8.41 | -1.60 | 3.51 | 2.98 | 54.46 | 5/6 | 43/62 | 0.87 | 11.06 | -2.64 | 2 |
| USDCHF | H1 | ret | hour=22 & mtf_M15=BULLISH | 60min | COMPRA | 90 | 50.02 | 14.99 | -6.02 | 4.13 | 2.97 | 57.78 | 5/5 | 18/22 | 35.04 | 5.77 | 9.22 | 2 |
| USDJPY | H1 | ret | hour=16 & swing_high_distance_atr=Q5 | 5min | VENDA | 133 | 10.04 | 8.96 | -1.60 | 3.41 | 2.93 | 55.64 | 6/6 | 32/42 | 1.07 | 11.06 | -2.09 | 2 |
| USDCHF | M5 | open | slot_hhmm=12:05 | 5min | COMPRA | 148 | 7.30 | 5.36 | -6.71 | 6.57 | 2.93 | 62.16 | 2/2 | 13/18 | 1.95 | 5.77 | -0.41 | 3 |
| USDJPY | M15 | open | slot_hhmm=09:45 | 15min | COMPRA | 284 | 13.43 | 12.48 | -4.12 | 3.89 | 2.92 | 61.97 | 3/3 | 30/34 | 0.95 | 11.06 | 1.42 | 3 |
| USDJPY | M15 | ret | slot_hhmm=09:30 | 15min | COMPRA | 284 | 13.38 | 12.43 | -4.22 | 3.90 | 2.91 | 61.97 | 3/3 | 31/34 | 0.95 | 11.06 | 1.37 | 3 |
| USDCHF | M5 | ret | slot_hhmm=12:00 | 5min | COMPRA | 148 | 7.26 | 5.31 | -6.79 | 6.59 | 2.90 | 62.84 | 2/2 | 13/18 | 1.95 | 5.77 | -0.46 | 3 |
| USDJPY | M15 | hit | slot_hhmm=09:30 | C alvo 2.0ATR ate 15min | COMPRA | 284 |  | 12.12 | -4.39 | 3.92 | 2.87 | 61.97 | 3/3 | 31/34 | 0.95 | 11.06 | 1.06 | 3 |
| USDJPY | M15 | open | slot_hhmm=09:45 & news_state=NONE_60M | 15min | COMPRA | 278 | 13.44 | 12.49 | -4.12 | 3.82 | 2.86 | 61.87 | 3/3 | 30/34 | 0.95 | 11.06 | 1.43 | 1 |
| XAUUSD | H1 | ret | volume_ratio=Q1 & news_min_since_last_high=Q2 | 60min | COMPRA | 395 | 170.22 | 149.40 | 4.95 | 2.75 | 2.83 | 54.18 | 4/4 | 26/37 | 20.81 | 7.00 | 142.40 | 1 |
| USDJPY | M15 | ret | slot_hhmm=09:30 & news_state=NONE_60M | 15min | COMPRA | 277 | 13.35 | 12.39 | -4.22 | 3.80 | 2.83 | 61.73 | 3/3 | 30/34 | 0.95 | 11.06 | 1.34 | 1 |
| USDJPY | M15 | hit | slot_hhmm=09:30 | C alvo 1.0ATR ate 15min | COMPRA | 284 |  | 11.68 | -4.77 | 3.98 | 2.81 | 61.97 | 3/3 | 31/34 | 0.95 | 11.06 | 0.62 | 3 |
| XAUUSD | M30 | open | mtf_M15=BULLISH | 45min | COMPRA | 4,513 | 64.06 | 55.00 | 8.55 | 2.74 | 2.81 | 50.30 | 3/3 | 23/34 | 9.06 | 7.00 | 48.00 | 1 |
| USDJPY | M15 | hit | slot_hhmm=09:30 & news_state=NONE_60M | C alvo 2.0ATR ate 15min | COMPRA | 277 |  | 12.07 | -4.39 | 3.82 | 2.79 | 61.73 | 3/3 | 30/34 | 0.95 | 11.06 | 1.02 | 1 |
| USDJPY | H1 | ret | hour=23 | 5min | VENDA | 554 | 11.01 | 9.96 | -1.60 | 3.31 | 2.78 | 52.35 | 6/6 | 46/65 | 1.05 | 11.06 | -1.10 | 5 |
| USDCHF | H1 | ret | hour=22 & mtf_M15=BULLISH | 30min | COMPRA | 91 | 47.85 | 12.96 | -7.16 | 4.26 | 2.76 | 52.75 | 4/5 | 15/24 | 34.88 | 5.77 | 7.19 | 2 |
| USDJPY | M15 | hit | slot_hhmm=09:30 & news_state=NONE_60M | C alvo 1.0ATR ate 15min | COMPRA | 277 |  | 11.62 | -4.77 | 3.87 | 2.73 | 61.73 | 3/3 | 30/34 | 0.95 | 11.06 | 0.56 | 1 |
| USDJPY | H1 | ret | session=LONDON & ret_bar_atr=Q2 | 5min | VENDA | 555 | 6.31 | 5.31 | -1.60 | 3.48 | 2.69 | 53.33 | 5/6 | 42/65 | 1.00 | 11.06 | -5.75 | 1 |
| USDCHF | H1 | ret | slot_hhmm=20:00 & previous_high_distance_atr=Q5 | 5min | VENDA | 105 | 70.83 | 20.63 | -4.82 | 3.32 | 2.68 | 50.48 | 5/6 | 16/23 | 50.20 | 5.77 | 14.86 | 2 |
| USDJPY | M15 | open | hour=19 & structure_before=BEARISH | 15min | COMPRA | 280 | 10.02 | 8.96 | -4.12 | 3.89 | 2.67 | 57.50 | 3/3 | 24/34 | 1.06 | 11.06 | -2.10 | 2 |
| USDJPY | M30 | ret | news_min_to_next_high=Q2 & p1=Q1 | 15min | VENDA | 388 | 12.13 | 11.11 | -3.86 | 3.64 | 2.67 | 52.58 | 3/3 | 27/34 | 1.02 | 11.06 | 0.06 | 1 |
| NZDUSD | H1 | ret | slot_hhmm=21:00 & prev_day_high_distance_atr=Q4 | 60min | COMPRA | 115 | 34.70 | 12.92 | -5.09 | 3.70 | 2.66 | 66.09 | 5/6 | 26/35 | 21.78 | 7.00 | 5.92 | 2 |
| USDJPY | M15 | ret | slot_hhmm=19:30 & news_state=NONE_60M | 15min | COMPRA | 160 | 8.91 | 7.83 | -4.22 | 4.02 | 2.64 | 55.62 | 3/3 | 25/33 | 1.08 | 11.06 | -3.23 | 1 |
| USDJPY | H1 | ret | session=ASIA & swing_low_distance_atr=Q1 | 5min | VENDA | 1,085 | 6.24 | 5.30 | -1.60 | 3.57 | 2.64 | 51.80 | 6/6 | 48/65 | 0.94 | 11.06 | -5.76 | 1 |
| USDJPY | H1 | ret | session=ASIA & direction=BEARISH | 5min | VENDA | 2,126 | 4.39 | 3.44 | -1.60 | 4.10 | 2.64 | 49.91 | 6/6 | 50/65 | 0.95 | 11.06 | -7.62 | 1 |
| USDJPY | M30 | ret | session=ASIA & previous_low_distance_atr=Q1 | 15min | VENDA | 850 | 10.52 | 9.58 | -3.86 | 3.86 | 2.63 | 54.12 | 3/3 | 25/34 | 0.94 | 11.06 | -1.48 | 1 |
| USDCHF | H1 | ret | previous_high_distance_atr=Q5 & news_min_since_last_high=Q5 | 60min | VENDA | 411 | 14.65 | 12.81 | -4.93 | 3.68 | 2.60 | 56.45 | 4/4 | 33/37 | 1.84 | 5.77 | 7.04 | 1 |
| USDCHF | M5 | open | slot_hhmm=12:05 & news_min_to_next_high=Q1 | 5min | COMPRA | 100 | 7.44 | 5.49 | -6.71 | 5.72 | 2.59 | 63.00 | 2/2 | 12/17 | 1.95 | 5.77 | -0.28 | 1 |
| USDCHF | M5 | ret | slot_hhmm=12:00 & news_min_to_next_high=Q1 | 5min | COMPRA | 100 | 7.43 | 5.48 | -6.79 | 5.75 | 2.58 | 64.00 | 2/2 | 12/17 | 1.95 | 5.77 | -0.29 | 1 |
| USDCHF | M15 | open | hour=15 & pcum3=Q3 | 20min | COMPRA | 200 | 11.90 | 10.25 | -6.95 | 4.32 | 2.57 | 59.00 | 3/3 | 27/33 | 1.65 | 5.77 | 4.48 | 1 |
| USDJPY | H1 | ret | price_position_monthly_open=Q4 & cost_atr=Q3 | 120min | COMPRA | 893 | 19.72 | 18.75 | -0.45 | 2.69 | 2.56 | 53.75 | 6/6 | 31/47 | 0.97 | 11.06 | 7.69 | 1 |
| NZDUSD | H1 | ret | slot_hhmm=22:00 & previous_low_distance_atr=Q1 | 5min | COMPRA | 71 | 18.83 | 9.97 | -4.26 | 3.64 | 2.56 | 49.30 | 5/6 | 13/23 | 8.87 | 7.00 | 2.97 | 2 |
| NZDUSD | H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 65min | COMPRA | 377 | 28.02 | 9.82 | -5.19 | 3.95 | 2.55 | 57.29 | 4/6 | 30/49 | 18.20 | 7.00 | 2.82 | 1 |
| USDJPY | H1 | ret | slot_hhmm=23:00 & mtf_D1=BULLISH | 5min | VENDA | 216 | 13.45 | 12.40 | -1.60 | 2.90 | 2.55 | 55.09 | 5/6 | 36/48 | 1.05 | 11.06 | 1.34 | 2 |
| USDJPY | H1 | ret | session=ASIA & price_position_daily_open=Q1 | 5min | VENDA | 946 | 6.96 | 6.01 | -1.60 | 3.34 | 2.54 | 53.38 | 6/6 | 41/60 | 0.95 | 11.06 | -5.05 | 1 |
| NZDUSD | M5 | ret | hour=22 & previous_high_distance_atr=Q1 | 15min | COMPRA | 81 | 11.62 | 6.51 | -6.42 | 5.00 | 2.53 | 53.09 | 0/2 | 5/12 | 5.11 | 7.00 | -0.49 | 1 |
| USDJPY | H1 | ret | slot_hhmm=02:00 & body_pct=Q1 | 5min | VENDA | 118 | 11.54 | 10.67 | -1.60 | 2.88 | 2.52 | 58.47 | 6/6 | 24/31 | 0.87 | 11.06 | -0.39 | 2 |
| USDJPY | H1 | ret | session=ASIA & previous_low_distance_atr=Q1 | 5min | VENDA | 860 | 6.77 | 5.83 | -1.60 | 3.28 | 2.49 | 51.40 | 6/6 | 43/64 | 0.94 | 11.06 | -5.23 | 1 |
| USDJPY | H1 | ret | slot_hhmm=15:00 & p1=Q5 | 60min | COMPRA | 161 | 27.68 | 26.66 | -3.16 | 2.78 | 2.49 | 59.63 | 5/6 | 38/52 | 1.03 | 11.06 | 15.60 | 2 |
| USDJPY | H1 | ret | session=ASIA & session_high_distance_atr=Q1 | 5min | VENDA | 1,206 | 5.65 | 4.67 | -1.60 | 3.47 | 2.48 | 51.16 | 6/6 | 48/65 | 0.98 | 11.06 | -6.39 | 1 |
| NZDUSD | H1 | ret | session=OFF_SESSION & price_position_monthly_open=Q4 | 5min | COMPRA | 199 | 9.36 | 4.03 | -4.26 | 5.06 | 2.46 | 57.29 | 4/6 | 18/38 | 5.32 | 7.00 | -2.97 | 1 |
| USDJPY | H1 | ret | session_high_distance_atr=Q1 & p1=Q1 | 15min | VENDA | 1,011 | 10.42 | 8.49 | -2.17 | 3.23 | 2.45 | 52.03 | 6/6 | 44/65 | 1.93 | 11.06 | -2.57 | 1 |
| USDJPY | M15 | open | slot_hhmm=19:45 & news_state=NONE_60M | 15min | COMPRA | 168 | 8.58 | 7.50 | -4.12 | 3.76 | 2.45 | 55.95 | 3/3 | 27/33 | 1.08 | 11.06 | -3.56 | 1 |
| NZDUSD | H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 75min | COMPRA | 376 | 27.55 | 9.54 | -4.45 | 3.58 | 2.41 | 57.98 | 4/6 | 33/49 | 18.01 | 7.00 | 2.54 | 1 |
| NZDUSD | H1 | open | session=OFF_SESSION & mtf_W1=BULLISH | 65min | COMPRA | 280 | 25.38 | 8.78 | -5.19 | 3.84 | 2.41 | 58.93 | 1/5 | 10/21 | 16.60 | 7.00 | 1.78 | 1 |
| NZDUSD | H1 | ret | hour=21 & prev_day_high_distance_atr=Q4 | 30min | COMPRA | 117 | 31.23 | 9.40 | -3.48 | 3.27 | 2.39 | 68.38 | 5/6 | 30/35 | 21.83 | 7.00 | 2.40 | 2 |
| USDJPY | M15 | open | slot_hhmm=09:45 & mtf_H4=BULLISH | 15min | COMPRA | 111 | 12.59 | 11.63 | -4.12 | 3.20 | 2.37 | 58.56 | 3/3 | 27/30 | 0.96 | 11.06 | 0.57 | 1 |
| XAUUSD | H1 | open | session=OFF_SESSION & news_min_to_next_high=Q4 | 60min | COMPRA | 603 | 122.45 | 113.11 | 3.07 | 2.35 | 2.37 | 55.06 | 4/4 | 25/37 | 9.35 | 7.00 | 106.11 | 1 |
| USDJPY | H1 | ret | session=LONDON_NY_OVERLAP & structure_at_close=BULLISH | 5min | VENDA | 719 | 7.48 | 6.48 | -1.60 | 3.03 | 2.36 | 51.60 | 6/6 | 45/65 | 1.01 | 11.06 | -4.58 | 1 |
| USDJPY | H1 | ret | direction=BEARISH & cost_atr=Q3 | 5min | VENDA | 1,442 | 4.50 | 3.47 | -1.60 | 3.51 | 2.33 | 50.55 | 5/6 | 43/63 | 1.02 | 11.06 | -7.59 | 1 |
| USDJPY | H1 | open | slot_hhmm=16:00 & p2=Q5 | 60min | COMPRA | 161 | 25.82 | 24.79 | -3.28 | 2.63 | 2.33 | 59.01 | 5/6 | 37/52 | 1.03 | 11.06 | 13.74 | 2 |
| NZDUSD | H1 | ret | hour=22 & mtf_M15=RANGE | 15min | COMPRA | 120 | 16.32 | 8.18 | -3.47 | 3.30 | 2.32 | 52.50 | 4/6 | 18/30 | 8.14 | 7.00 | 1.18 | 2 |
| NZDUSD | H1 | ret | hour=22 & atr_ratio=Q4 | 30min | COMPRA | 100 | 14.85 | 7.03 | -3.48 | 3.42 | 2.31 | 57.00 | 6/6 | 13/25 | 7.82 | 7.00 | 0.03 | 2 |
| USDJPY | H1 | ret | upper_wick_pct=Q3 & news_min_since_last_high=Q5 | 30min | VENDA | 352 | 17.47 | 16.47 | -3.20 | 2.76 | 2.28 | 53.69 | 4/4 | 26/36 | 1.00 | 11.06 | 5.41 | 1 |
| NZDUSD | H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 90min | COMPRA | 376 | 27.61 | 9.61 | -4.42 | 3.35 | 2.27 | 55.59 | 4/6 | 31/49 | 18.01 | 7.00 | 2.61 | 1 |
| USDJPY | M15 | hit | slot_hhmm=09:30 | C alvo 0.5ATR ate 15min | COMPRA | 284 |  | 8.63 | -5.52 | 3.71 | 2.26 | 64.44 | 3/3 | 28/34 | 0.95 | 11.06 | -2.43 | 3 |
| USDCHF | M15 | open | hour=15 & pcum3=Q3 | 15min | COMPRA | 200 | 10.43 | 8.79 | -6.87 | 4.00 | 2.24 | 57.50 | 3/3 | 22/33 | 1.65 | 5.77 | 3.02 | 1 |
| NZDUSD | H1 | ret | body_pct=Q1 & range_atr=Q5 | 30min | COMPRA | 366 | 16.49 | 6.92 | -3.48 | 3.41 | 2.23 | 55.19 | 5/6 | 33/64 | 9.57 | 7.00 | -0.08 | 1 |
| USDJPY | H1 | ret | prev_day_high_distance_atr=Q5 & cum10=Q4 | 5min | VENDA | 605 | 9.20 | 4.37 | -1.60 | 3.03 | 2.22 | 52.89 | 5/6 | 37/63 | 4.83 | 11.06 | -6.69 | 1 |
| NZDUSD | H1 | open | slot_hhmm=22:00 & mtf_W1=BULLISH | 90min | COMPRA | 137 | 41.57 | 12.98 | -4.42 | 2.97 | 2.22 | 59.12 | 1/5 | 8/20 | 28.59 | 7.00 | 5.98 | 2 |
| NZDUSD | H1 | open | session=OFF_SESSION & mtf_W1=BULLISH | 90min | COMPRA | 277 | 26.58 | 9.86 | -4.42 | 3.22 | 2.21 | 57.40 | 2/5 | 10/21 | 16.71 | 7.00 | 2.86 | 1 |
| USDJPY | H1 | ret | dom_w=d22_31 & cost_atr=Q3 | 5min | VENDA | 940 | 5.18 | 4.17 | -1.60 | 3.12 | 2.21 | 50.96 | 5/6 | 36/57 | 1.01 | 11.06 | -6.89 | 1 |
| NZDUSD | M15 | ret | slot_hhmm=14:00 & mtf_H4=BULLISH | 15min | COMPRA | 85 | 12.11 | 8.87 | -6.33 | 3.77 | 2.21 | 63.53 | 3/3 | 18/23 | 3.24 | 7.00 | 1.87 | 1 |
| USDJPY | H1 | ret | volume_ratio=Q4 & pat_EVENING_STAR_3BAR=Y | 5min | VENDA | 306 | 9.45 | 8.05 | -1.60 | 2.67 | 2.21 | 53.92 | 5/6 | 42/65 | 1.41 | 11.06 | -3.01 | 1 |
| NZDUSD | M15 | open | slot_hhmm=14:15 & mtf_H4=BULLISH | 15min | COMPRA | 85 | 12.02 | 8.79 | -6.38 | 3.77 | 2.19 | 62.35 | 3/3 | 19/24 | 3.24 | 7.00 | 1.79 | 1 |
| USDCHF | H1 | ret | prev_day_low_distance_atr=Q5 & session_high_distance_atr=Q5 | 30min | VENDA | 663 | 9.24 | 5.44 | -5.85 | 4.67 | 2.19 | 52.04 | 5/6 | 44/65 | 3.80 | 5.77 | -0.33 | 1 |
| XAUUSD | H1 | ret | hour=20 & structure_at_close=BEARISH | 15min | COMPRA | 178 | 141.37 | 117.96 | 12.74 | 1.95 | 2.17 | 60.11 | 5/5 | 34/42 | 23.41 | 7.00 | 110.96 | 2 |
| USDJPY | H1 | ret | hour=16 & cum10=Q5 | 5min | VENDA | 126 | 8.10 | 7.01 | -1.60 | 2.63 | 2.17 | 56.35 | 6/6 | 29/41 | 1.09 | 11.06 | -4.05 | 2 |
| USDJPY | M30 | ret | hour=9 & mtf_W1=BEARISH | 5min | VENDA | 40 | 13.25 | 12.23 | -3.30 | 2.72 | 2.17 | 65.00 | 3/3 | 9/11 | 1.02 | 11.06 | 1.17 | 1 |
| NZDUSD | H1 | ret | slot_hhmm=22:00 & mtf_D1=BULLISH | 5min | COMPRA | 150 | 10.77 | 4.05 | -4.26 | 4.43 | 2.17 | 52.00 | 4/6 | 21/39 | 6.72 | 7.00 | -2.95 | 2 |
| USDJPY | H1 | ret | session_high_distance_atr=Q5 & swing_low_distance_atr=Q3 | 5min | VENDA | 376 | 11.16 | 6.33 | -1.60 | 2.71 | 2.15 | 53.19 | 6/6 | 40/64 | 4.83 | 11.06 | -4.73 | 1 |
| USDCHF | H1 | ret | slot_hhmm=22:00 & mtf_M15=BULLISH | 15min | COMPRA | 92 | 42.72 | 7.84 | -6.61 | 3.92 | 2.14 | 48.91 | 5/6 | 15/27 | 34.87 | 5.77 | 2.07 | 2 |
| USDJPY | H1 | ret | session=ASIA & mtf_D1=BREAK_UP | 5min | VENDA | 384 | 5.84 | 4.90 | -1.60 | 2.81 | 2.13 | 50.00 | 6/6 | 34/45 | 0.94 | 11.06 | -6.16 | 1 |
| XAUUSD | M30 | ret | session=NEW_YORK & news_min_to_next_high=Q4 | 5min | COMPRA | 272 | 106.97 | 81.15 | 1.35 | 2.12 | 2.13 | 52.57 | 2/3 | 18/34 | 25.82 | 7.00 | 74.15 | 1 |
| USDCHF | H1 | open | hour=20 & pcum10=Q5 | 65min | VENDA | 116 | 76.70 | 20.96 | -6.77 | 2.81 | 2.12 | 46.55 | 3/6 | 12/22 | 55.73 | 5.77 | 15.19 | 2 |
| USDJPY | M15 | hit | slot_hhmm=09:30 & news_state=NONE_60M | C alvo 0.5ATR ate 15min | COMPRA | 277 |  | 8.28 | -5.52 | 3.54 | 2.12 | 64.26 | 3/3 | 28/34 | 0.95 | 11.06 | -2.78 | 1 |
| US30 | H1 | ret | hour=23 & structure_before=BULLISH | 5min | VENDA | 213 | 417.44 | 297.21 | -136.78 | 3.06 | 2.11 | 53.52 | 6/6 | 41/65 | 120.23 | 0.00 | 297.21 | 4 |
| USDJPY | H1 | ret | session=ASIA & previous_high_distance_atr=Q1 | 5min | VENDA | 943 | 5.88 | 4.92 | -1.60 | 2.90 | 2.11 | 51.64 | 6/6 | 46/65 | 0.95 | 11.06 | -6.14 | 1 |
| USDJPY | H1 | ret | session=ASIA & mtf_H1=BREAK_DOWN | 5min | VENDA | 238 | 11.86 | 10.92 | -1.60 | 2.44 | 2.11 | 52.10 | 6/6 | 29/43 | 0.94 | 11.06 | -0.14 | 2 |
| NZDUSD | H1 | ret | slot_hhmm=22:00 & mtf_M5=RANGE | 5min | COMPRA | 170 | 8.60 | 3.13 | -4.26 | 4.93 | 2.11 | 52.35 | 3/6 | 22/50 | 5.47 | 7.00 | -3.87 | 2 |
| NZDUSD | M15 | ret | slot_hhmm=22:45 & streak=-1 | 5min | COMPRA | 83 | 12.92 | 5.05 | -6.00 | 4.57 | 2.10 | 59.04 | 2/3 | 13/25 | 7.87 | 7.00 | -1.95 | 1 |
| NZDUSD | M30 | ret | slot_hhmm=21:30 & range_atr_prev=Q5 | 60min | COMPRA | 171 | 29.02 | 11.68 | -5.70 | 3.13 | 2.10 | 60.82 | 3/3 | 17/21 | 17.33 | 7.00 | 4.68 | 1 |
| USDJPY | H1 | ret | mtf_M1=BULLISH & volume_ratio=Q2 | 5min | VENDA | 954 | 5.34 | 3.15 | -1.60 | 3.11 | 2.08 | 52.20 | 6/6 | 41/65 | 2.19 | 11.06 | -7.91 | 1 |
| USDJPY | H1 | ret | mtf_H4=BULLISH & mtf_D1=BREAK_UP | 5min | VENDA | 848 | 6.73 | 3.76 | -1.60 | 2.98 | 2.07 | 50.24 | 4/6 | 30/44 | 2.96 | 11.06 | -7.30 | 1 |
| USDJPY | H1 | open | structure_before=BULLISH & mtf_D1=BULLISH | 180min | COMPRA | 1,669 | 19.72 | 12.28 | 0.13 | 2.10 | 2.07 | 53.15 | 6/6 | 33/57 | 7.44 | 11.06 | 1.22 | 2 |
| USDCHF | H1 | ret | prev_day_low_distance_atr=Q5 & session_low_distance_atr=Q5 | 30min | VENDA | 723 | 9.30 | 5.05 | -5.85 | 4.61 | 2.07 | 53.11 | 6/6 | 45/65 | 4.25 | 5.77 | -0.72 | 1 |
| USDJPY | M30 | open | mtf_H4=BREAK_UP & pcum10=Q5 | 35min | COMPRA | 701 | 11.32 | 7.63 | -4.85 | 3.43 | 2.07 | 52.07 | 3/3 | 22/33 | 3.69 | 11.06 | -3.43 | 1 |
| USDJPY | H1 | ret | hour=16 & prev_day_high_distance_atr=Q5 | 5min | VENDA | 145 | 7.82 | 6.74 | -1.60 | 2.52 | 2.06 | 53.79 | 6/6 | 36/47 | 1.08 | 11.06 | -4.32 | 2 |
| USDJPY | H1 | ret | mtf_M15=BULLISH & lower_wick_pct=Q1 | 60min | COMPRA | 956 | 16.90 | 11.27 | -3.16 | 2.71 | 2.05 | 53.66 | 6/6 | 48/65 | 5.64 | 11.06 | 0.21 | 1 |
| USDJPY | H1 | ret | session=ASIA & cum3=Q1 | 5min | VENDA | 1,077 | 5.07 | 4.13 | -1.60 | 2.95 | 2.05 | 50.14 | 6/6 | 46/65 | 0.95 | 11.06 | -6.93 | 1 |
| NZDUSD | H1 | open | session=OFF_SESSION & mtf_W1=BULLISH | 75min | COMPRA | 279 | 24.99 | 8.35 | -4.45 | 3.15 | 2.04 | 55.91 | 2/5 | 11/21 | 16.64 | 7.00 | 1.35 | 1 |
| NZDUSD | H1 | open | session=OFF_SESSION & range_atr_prev=Q5 | 60min | COMPRA | 377 | 25.60 | 7.40 | -6.14 | 3.79 | 2.04 | 57.29 | 4/6 | 31/49 | 18.20 | 7.00 | 0.40 | 1 |
| USDJPY | M15 | ret | slot_hhmm=19:30 & structure_before=BEARISH | 15min | COMPRA | 72 | 14.33 | 13.26 | -4.22 | 2.67 | 2.04 | 62.50 | 3/3 | 21/26 | 1.08 | 11.06 | 2.20 | 2 |
| USDCHF | H1 | open | slot_hhmm=23:00 & mtf_M15=RANGE | 60min | COMPRA | 199 | 23.50 | 8.28 | -6.25 | 3.56 | 2.04 | 51.76 | 3/6 | 34/55 | 15.21 | 5.77 | 2.51 | 2 |
| USDJPY | H1 | ret | direction=BEARISH & session_high_distance_atr=Q1 | 15min | VENDA | 1,583 | 7.56 | 5.83 | -2.17 | 3.02 | 2.03 | 51.23 | 6/6 | 45/65 | 1.73 | 11.06 | -5.23 | 1 |
| USDJPY | H1 | ret | session=ASIA & ret_bar_atr=Q1 | 5min | VENDA | 1,074 | 5.17 | 4.21 | -1.60 | 2.91 | 2.03 | 49.63 | 6/6 | 51/65 | 0.96 | 11.06 | -6.84 | 1 |
| USDJPY | H1 | ret | mtf_W1=BULLISH & session_high_distance_atr=Q1 | 5min | VENDA | 904 | 7.13 | 5.12 | -1.60 | 2.77 | 2.02 | 52.10 | 5/6 | 29/48 | 2.02 | 11.06 | -5.94 | 1 |
| USDJPY | H1 | ret | session_high_distance_atr=Q1 & session_low_distance_atr=Q2 | 15min | VENDA | 425 | 11.85 | 9.11 | -2.17 | 2.54 | 2.02 | 54.12 | 6/6 | 43/63 | 2.74 | 11.06 | -1.95 | 1 |
| USDJPY | H1 | ret | prev_day_low_distance_atr=Q5 & session_low_distance_atr=Q4 | 5min | VENDA | 450 | 10.01 | 4.49 | -1.60 | 2.72 | 2.02 | 52.67 | 5/6 | 36/60 | 5.52 | 11.06 | -6.57 | 1 |
| NZDUSD | H1 | ret | hour=22 & mtf_H4=RANGE | 5min | COMPRA | 133 | 10.51 | 4.02 | -4.26 | 4.11 | 2.00 | 53.38 | 5/6 | 22/38 | 6.49 | 7.00 | -2.98 | 2 |
| NZDUSD | H1 | ret | hour=22 & price_position_monthly_open=Q3 | 15min | COMPRA | 127 | 13.21 | 6.01 | -3.47 | 3.14 | 1.99 | 55.91 | 5/6 | 19/29 | 7.20 | 7.00 | -0.99 | 2 |
| USDCHF | H1 | ret | slot_hhmm=22:00 & swing_high_distance_atr=Q3 | 60min | COMPRA | 140 | 24.71 | 7.74 | -6.02 | 3.48 | 1.98 | 55.00 | 5/6 | 26/41 | 16.97 | 5.77 | 1.97 | 2 |
| USDJPY | M30 | ret | session=ASIA & swing_high_distance_atr=Q1 | 15min | VENDA | 821 | 8.58 | 7.64 | -3.86 | 3.11 | 1.98 | 52.50 | 3/3 | 28/34 | 0.94 | 11.06 | -3.42 | 1 |
| NZDUSD | H1 | open | hour=22 & mtf_W1=BULLISH | 75min | COMPRA | 139 | 38.87 | 10.61 | -4.45 | 2.79 | 1.97 | 58.99 | 1/5 | 8/20 | 28.26 | 7.00 | 3.61 | 2 |
| USDJPY | H1 | ret | prev_day_low_distance_atr=Q4 & ret_bar_atr=Q5 | 60min | COMPRA | 658 | 14.16 | 12.45 | -3.16 | 2.51 | 1.96 | 53.50 | 6/6 | 45/65 | 1.71 | 11.06 | 1.39 | 1 |
| USDJPY | H1 | ret | hour=0 & swing_low_distance_atr=Q1 | 15min | VENDA | 143 | 20.89 | 20.02 | -2.17 | 2.18 | 1.96 | 55.24 | 6/6 | 24/33 | 0.87 | 11.06 | 8.96 | 2 |
| US30 | H1 | ret | hour=23 & structure_at_close=BULLISH | 5min | VENDA | 220 | 336.86 | 216.64 | -136.78 | 3.11 | 1.95 | 52.73 | 6/6 | 40/65 | 120.23 | 0.00 | 216.64 | 2 |
| NZDUSD | M5 | open | hour=22 & structure_before=BEARISH | 35min | COMPRA | 183 | 20.76 | 5.14 | -6.20 | 4.28 | 1.95 | 57.92 | 0/2 | 11/18 | 15.62 | 7.00 | -1.86 | 2 |
| USDJPY | H1 | open | session=LONDON & mtf_M15=BULLISH | 60min | COMPRA | 1,044 | 11.27 | 10.27 | -3.28 | 2.66 | 1.94 | 52.87 | 5/6 | 46/65 | 0.99 | 11.06 | -0.78 | 1 |
| NZDUSD | H1 | ret | hour=22 & atr_ratio=Q4 | 15min | COMPRA | 100 | 13.89 | 6.07 | -3.47 | 3.03 | 1.94 | 58.00 | 6/6 | 14/25 | 7.82 | 7.00 | -0.93 | 2 |
| USDJPY | H1 | ret | mtf_D1=BREAK_UP & dom_w=d22_31 | 5min | VENDA | 311 | 9.02 | 5.63 | -1.60 | 2.48 | 1.93 | 52.09 | 5/6 | 19/24 | 3.40 | 11.06 | -5.43 | 1 |
| USDJPY | H1 | ret | session=ASIA & cum3=Q1 | 15min | VENDA | 1,077 | 7.25 | 6.32 | -2.17 | 2.72 | 1.92 | 51.25 | 6/6 | 43/65 | 0.93 | 11.06 | -4.74 | 1 |
| USDJPY | H1 | ret | session=ASIA & swing_high_distance_atr=Q1 | 5min | VENDA | 962 | 5.35 | 4.39 | -1.60 | 2.73 | 1.92 | 51.35 | 6/6 | 42/65 | 0.96 | 11.06 | -6.67 | 1 |
| USDJPY | H1 | ret | hour=2 & mtf_M5=BULLISH | 5min | VENDA | 166 | 6.90 | 6.03 | -1.60 | 2.40 | 1.91 | 54.82 | 6/6 | 39/58 | 0.87 | 11.06 | -5.03 | 2 |
| USDCHF | H1 | ret | hour=22 & previous_high_distance_atr=Q4 | 60min | COMPRA | 141 | 26.84 | 9.11 | -6.02 | 3.15 | 1.91 | 54.61 | 6/6 | 28/38 | 17.74 | 5.77 | 3.34 | 2 |
| USDJPY | H1 | ret | direction=BEARISH & session_high_distance_atr=Q1 | 5min | VENDA | 1,585 | 5.59 | 3.80 | -1.60 | 2.93 | 1.90 | 50.54 | 5/6 | 46/65 | 1.79 | 11.06 | -7.26 | 1 |
| USDJPY | H1 | open | mtf_M1=BREAK_DOWN & pcum10=Q4 | 65min | COMPRA | 134 | 35.81 | 28.63 | -5.17 | 2.25 | 1.90 | 55.97 | 5/6 | 25/31 | 7.18 | 11.06 | 17.57 | 1 |
| USDJPY | H1 | open | mtf_M1=BREAK_DOWN & pcum10=Q4 | 60min | COMPRA | 134 | 35.37 | 28.19 | -3.28 | 2.12 | 1.90 | 58.96 | 5/6 | 23/31 | 7.18 | 11.06 | 17.13 | 1 |
| USDCHF | H1 | open | hour=20 & mtf_M30=BULLISH | 65min | VENDA | 207 | 69.71 | 13.37 | -6.77 | 2.88 | 1.90 | 48.79 | 4/6 | 27/49 | 56.34 | 5.77 | 7.61 | 2 |
| NZDUSD | H1 | ret | session=OFF_SESSION & p2=Q4 | 15min | COMPRA | 205 | 10.80 | 5.02 | -3.47 | 3.20 | 1.89 | 53.17 | 6/6 | 37/60 | 5.77 | 7.00 | -1.98 | 1 |
| USDCHF | H1 | ret | price_position_weekly_open=Q5 & pat_TWEEZER_BOTTOM=Y | 5min | VENDA | 174 | 12.58 | 5.02 | -4.82 | 3.71 | 1.88 | 48.28 | 4/6 | 26/42 | 7.56 | 5.77 | -0.75 | 1 |
| USDCHF | M15 | ret | hour=15 & cum3=Q3 | 15min | COMPRA | 203 | 8.26 | 6.51 | -6.97 | 3.88 | 1.87 | 55.67 | 3/3 | 24/34 | 1.75 | 5.77 | 0.75 | 1 |
| USDJPY | H1 | ret | price_position_monthly_open=Q4 & cost_atr=Q3 | 60min | COMPRA | 943 | 10.48 | 9.51 | -3.16 | 2.55 | 1.87 | 54.93 | 6/6 | 32/47 | 0.97 | 11.06 | -1.55 | 1 |
| NZDUSD | H1 | open | slot_hhmm=23:00 & mtf_D1=BULLISH | 65min | COMPRA | 152 | 15.93 | 9.17 | -5.19 | 2.91 | 1.86 | 60.53 | 4/6 | 21/39 | 6.76 | 7.00 | 2.17 | 2 |
| NZDUSD | H1 | open | mtf_W1=BEARISH & month=5 | 75min | COMPRA | 233 | 16.89 | 8.94 | -4.45 | 2.79 | 1.86 | 52.79 | 4/4 | 4/4 | 7.95 | 7.00 | 1.94 | 1 |
| USDJPY | H1 | ret | session_low_distance_atr=Q5 & cost_atr=Q4 | 60min | COMPRA | 294 | 14.07 | 13.08 | -3.16 | 2.29 | 1.85 | 54.42 | 5/6 | 35/50 | 0.99 | 11.06 | 2.02 | 1 |
| NZDUSD | H1 | open | mtf_W1=BEARISH & month=5 | 90min | COMPRA | 233 | 17.94 | 10.00 | -4.42 | 2.68 | 1.85 | 49.36 | 4/4 | 4/4 | 7.95 | 7.00 | 3.00 | 1 |
| USDCHF | M30 | ret | hour=15 & close_position=Q1 | 15min | COMPRA | 117 | 9.26 | 7.44 | -6.76 | 3.52 | 1.84 | 63.25 | 3/3 | 23/31 | 1.83 | 5.77 | 1.67 | 1 |
| USDJPY | H1 | ret | slot_hhmm=02:00 & p1=Q5 | 5min | VENDA | 118 | 8.65 | 7.78 | -1.60 | 2.19 | 1.83 | 53.39 | 5/6 | 20/31 | 0.87 | 11.06 | -3.28 | 2 |
| NZDUSD | H1 | open | slot_hhmm=22:00 & range_atr_prev=Q5 | 75min | COMPRA | 249 | 30.74 | 9.29 | -4.45 | 2.72 | 1.83 | 56.63 | 3/6 | 20/30 | 21.45 | 7.00 | 2.29 | 2 |
| USDJPY | M30 | open | mtf_H4=BREAK_UP & pcum10=Q5 | 30min | COMPRA | 701 | 9.69 | 6.00 | -3.98 | 3.08 | 1.82 | 53.07 | 3/3 | 25/33 | 3.69 | 11.06 | -5.06 | 1 |
| USDJPY | M15 | open | slot_hhmm=19:45 & structure_before=BEARISH | 15min | COMPRA | 65 | 13.89 | 12.81 | -4.12 | 2.39 | 1.82 | 63.08 | 3/3 | 22/26 | 1.08 | 11.06 | 1.76 | 2 |
| NZDUSD | M15 | open | slot_hhmm=14:15 & mtf_H4=BULLISH | 20min | COMPRA | 85 | 11.93 | 8.69 | -5.97 | 3.06 | 1.82 | 52.94 | 3/3 | 21/24 | 3.24 | 7.00 | 1.69 | 1 |
| USDJPY | H1 | ret | session=LONDON_NY_OVERLAP & price_position_daily_open=Q5 | 5min | VENDA | 704 | 5.33 | 4.33 | -1.60 | 2.54 | 1.82 | 53.12 | 6/6 | 47/65 | 0.99 | 11.06 | -6.72 | 1 |
| USDCHF | H1 | hit | session=NEW_YORK & session_low_distance_atr=Q4 | V alvo 2.0ATR ate 60min | VENDA | 193 |  | 10.81 | -4.46 | 2.58 | 1.81 | 49.22 | 6/6 | 29/43 | 25.21 | 5.77 | 5.05 | 1 |
| USDJPY | H1 | ret | mtf_D1=BREAK_UP & swing_high_distance_atr=Q4 | 5min | VENDA | 193 | 10.41 | 6.69 | -1.60 | 2.24 | 1.81 | 50.26 | 6/6 | 26/36 | 3.72 | 11.06 | -4.37 | 1 |
| US30 | H1 | ret | hour=23 & price_position_weekly_open=Q3 | 5min | VENDA | 122 | 528.65 | 408.24 | -136.78 | 2.41 | 1.81 | 56.56 | 6/6 | 30/44 | 120.41 | 0.00 | 408.24 | 2 |
| USDJPY | M30 | ret | session=LONDON & news_state=NONE_60M | 5min | VENDA | 2,452 | 2.48 | 1.50 | -3.30 | 5.89 | 1.81 | 50.73 | 3/3 | 26/34 | 0.99 | 11.06 | -9.56 | 1 |
| USDCHF | H1 | open | hour=20 & mtf_M15=BULLISH | 65min | VENDA | 190 | 71.86 | 13.20 | -6.77 | 2.74 | 1.80 | 50.53 | 4/6 | 17/43 | 58.66 | 5.77 | 7.43 | 2 |
| USDJPY | H1 | ret | session_high_distance_atr=Q1 | 15min | VENDA | 2,118 | 6.26 | 4.28 | -2.17 | 3.02 | 1.80 | 50.99 | 6/6 | 41/65 | 1.98 | 11.06 | -6.78 | 1 |
| USDJPY | H1 | ret | dom_w=d22_31 & pat_TWEEZER_BOTTOM=Y | 5min | VENDA | 164 | 10.07 | 6.78 | -1.60 | 2.19 | 1.77 | 56.10 | 4/6 | 25/44 | 3.29 | 11.06 | -4.28 | 1 |
| USDJPY | M30 | open | hour=19 & pcum10=Q1 | 30min | COMPRA | 63 | 20.71 | 19.66 | -3.98 | 2.11 | 1.77 | 60.32 | 3/3 | 17/24 | 1.05 | 11.06 | 8.60 | 1 |
| USDJPY | H1 | ret | session_high_distance_atr=Q1 | 5min | VENDA | 2,120 | 4.85 | 2.85 | -1.60 | 3.05 | 1.76 | 50.66 | 4/6 | 44/65 | 2.00 | 11.06 | -8.21 | 1 |
| USDJPY | H1 | ret | session=ASIA & close_position=Q2 | 5min | VENDA | 874 | 4.57 | 3.63 | -1.60 | 2.60 | 1.76 | 49.54 | 6/6 | 43/65 | 0.95 | 11.06 | -7.43 | 1 |
| USDJPY | H1 | ret | news_state=NONE_60M & swing_high_distance_atr=Q1 | 15min | VENDA | 2,007 | 7.10 | 4.46 | -2.17 | 2.91 | 1.76 | 50.02 | 3/4 | 26/37 | 2.64 | 11.06 | -6.60 | 1 |

## 6. Candidatas das categorias 1-3 (usar com cautela)

### 1 abertura de semana (domingo/gap) — 89 famílias (as 15 melhores)

| ativo | tf | modo | condicao | serie | lado | n_val | bruto_pts_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos | custo_medio_pts | comissao_RT_pts_7usd | liq_apos_comissao | n_formas_equivalentes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| USDJPY | M5 | open | day_of_week=SUNDAY & session=NEW_YORK | 65min | COMPRA | 345 | 142.39 | 34.07 | -1.80 | 5.21 | 4.95 | 62.32 | 2/2 | 8/14 | 108.32 | 11.06 | 23.02 | 2 |
| USDJPY | M15 | ret | day_of_week=SUNDAY & session=NEW_YORK | 60min | COMPRA | 155 | 145.19 | 47.10 | -1.02 | 4.65 | 4.56 | 61.29 | 2/3 | 16/24 | 98.09 | 11.06 | 36.05 | 2 |
| USDJPY | H1 | ret | dow_slot=SUNDAY|23:00 | 5min | VENDA | 111 | 34.66 | 33.63 | -1.60 | 4.10 | 3.90 | 63.96 | 6/6 | 17/21 | 1.03 | 11.06 | 22.57 | 7 |
| USDJPY | H1 | ret | price_position_weekly_open=Q2 & gap=Y | 30min | COMPRA | 81 | 124.07 | 58.94 | -5.70 | 4.14 | 3.78 | 66.67 | 6/6 | 9/10 | 65.13 | 11.06 | 47.88 | 1 |
| USDJPY | H1 | ret | day_of_week=SUNDAY & cost_atr=Q5 | 30min | COMPRA | 115 | 113.01 | 51.37 | -5.70 | 4.16 | 3.74 | 63.48 | 5/6 | 17/20 | 61.63 | 11.06 | 40.32 | 1 |
| USDJPY | H1 | ret | cost_atr=Q5 & gap=Y | 30min | COMPRA | 111 | 118.74 | 52.87 | -5.70 | 4.11 | 3.71 | 64.86 | 5/6 | 14/17 | 65.86 | 11.06 | 41.82 | 1 |
| USDJPY | H1 | hit | cost_atr=Q5 & gap=Y | C alvo 1.0ATR ate 60min | COMPRA | 111 |  | 54.49 | -3.98 | 3.93 | 3.67 | 72.97 | 6/6 | 14/17 | 65.86 | 11.06 | 43.43 | 1 |
| USDJPY | H1 | hit | cost_atr=Q5 & gap=Y | C alvo 2.0ATR ate 60min | COMPRA | 111 |  | 63.73 | -3.91 | 3.83 | 3.61 | 65.77 | 6/6 | 14/17 | 65.86 | 11.06 | 52.67 | 1 |
| USDJPY | H1 | ret | day_of_week=SUNDAY & gap=Y | 30min | COMPRA | 111 | 115.60 | 51.79 | -5.70 | 3.91 | 3.52 | 63.96 | 6/6 | 16/20 | 63.81 | 11.06 | 40.73 | 1 |
| USDJPY | H1 | hit | day_of_week=SUNDAY & cost_atr=Q5 | C alvo 1.0ATR ate 60min | COMPRA | 115 |  | 49.99 | -3.98 | 3.73 | 3.46 | 71.30 | 6/6 | 16/20 | 61.63 | 11.06 | 38.93 | 1 |
| USDJPY | H1 | hit | price_position_weekly_open=Q2 & gap=Y | C alvo 1.0ATR ate 60min | COMPRA | 81 |  | 58.17 | -3.98 | 3.67 | 3.45 | 74.07 | 6/6 | 9/10 | 65.13 | 11.06 | 47.11 | 1 |
| USDJPY | H1 | hit | price_position_weekly_open=Q2 & gap=Y | C alvo 2.0ATR ate 60min | COMPRA | 81 |  | 67.97 | -3.91 | 3.63 | 3.44 | 69.14 | 6/6 | 8/10 | 65.13 | 11.06 | 56.92 | 1 |
| USDJPY | H1 | ret | price_position_weekly_open=Q2 & gap=Y | 15min | COMPRA | 81 | 110.96 | 45.83 | -6.37 | 3.77 | 3.32 | 62.96 | 6/6 | 7/10 | 65.13 | 11.06 | 34.77 | 1 |
| USDJPY | H1 | ret | gap=Y | 30min | COMPRA | 117 | 109.49 | 46.96 | -5.70 | 3.71 | 3.30 | 63.25 | 6/6 | 21/25 | 62.53 | 11.06 | 35.90 | 1 |
| USDJPY | H1 | ret | volume_ratio=Q1 & gap=Y | 30min | COMPRA | 114 | 110.45 | 47.44 | -5.70 | 3.66 | 3.27 | 63.16 | 6/6 | 18/22 | 63.01 | 11.06 | 36.38 | 1 |

### 2 hit sem perdedores observados / amostra pequena (cauda invisivel) — 13 famílias (as 15 melhores)

| ativo | tf | modo | condicao | serie | lado | n_val | bruto_pts_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos | custo_medio_pts | comissao_RT_pts_7usd | liq_apos_comissao | n_formas_equivalentes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| US30 | M5 | hit | hour=11 & atr_ratio=Q1 | C alvo 1.0ATR ate 240min | COMPRA | 40 |  | 1,452.59 | -80.75 | 24.70 | 35.40 | 100.00 | 2/2 | 10/10 | 120.00 | 0.00 | 1,452.59 | 1 |
| US30 | M5 | hit | hour=11 & atr_ratio=Q1 | C alvo 0.5ATR ate 240min | COMPRA | 40 |  | 666.29 | -125.01 | 19.71 | 32.47 | 100.00 | 2/2 | 10/10 | 120.00 | 0.00 | 666.29 | 1 |
| US30 | M5 | hit | news_min_to_next_high=Q1 & atr_ratio=Q1 | C alvo 0.5ATR ate 240min | COMPRA | 73 |  | 790.27 | -125.01 | 21.65 | 32.25 | 100.00 | 2/2 | 12/12 | 120.00 | 0.00 | 790.27 | 1 |
| US30 | M5 | hit | hour=10 & atr_ratio=Q1 | C alvo 1.0ATR ate 240min | COMPRA | 84 |  | 1,450.92 | -80.75 | 23.64 | 32.03 | 100.00 | 2/2 | 13/13 | 120.00 | 0.00 | 1,450.92 | 1 |
| US30 | M5 | hit | mtf_W1=BEARISH & prev_day_low_distance_atr=Q1 | C alvo 1.0ATR ate 240min | COMPRA | 376 |  | 3,419.57 | -80.75 | 29.14 | 30.51 | 99.20 | 2/2 | 2/2 | 109.09 | 0.00 | 3,419.57 | 1 |
| US30 | M5 | hit | mtf_W1=BEARISH & prev_day_low_distance_atr=Q1 | C alvo 0.5ATR ate 240min | COMPRA | 376 |  | 1,713.69 | -125.01 | 27.55 | 29.63 | 100.00 | 2/2 | 2/2 | 109.09 | 0.00 | 1,713.69 | 1 |
| US30 | M5 | hit | hour=10 & atr_ratio=Q1 | C alvo 0.5ATR ate 240min | COMPRA | 84 |  | 665.46 | -125.01 | 19.19 | 29.38 | 100.00 | 2/2 | 13/13 | 120.00 | 0.00 | 665.46 | 1 |
| US30 | M5 | hit | mtf_D1=BREAK_DOWN & prev_day_low_distance_atr=Q5 | C alvo 0.5ATR ate 240min | COMPRA | 107 |  | 683.08 | -125.01 | 18.94 | 27.07 | 100.00 | 2/2 | 3/3 | 119.38 | 0.00 | 683.08 | 1 |
| US30 | M5 | hit | hour=13 & month=3 | V alvo 0.5ATR ate 240min | VENDA | 48 |  | 2,572.83 | -292.70 | 26.76 | 25.65 | 100.00 | 1/1 | 1/1 | 70.00 | 0.00 | 2,572.83 | 1 |
| BTCUSD | M5 | hit | session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 0.5ATR ate 240min | VENDA | 115 |  | 3,200.25 | -1,780.03 | 26.18 | 23.75 | 100.00 | 2/2 | 12/12 | 1,715.07 | 0.00 | 3,200.25 | 1 |
| USDJPY | M30 | hit | slot_hhmm=09:30 & mtf_H4=BULLISH | V alvo 0.5ATR ate 15min | VENDA | 111 |  | 8.86 | -4.56 | 3.14 | 2.09 | 56.76 | 3/3 | 26/30 | 0.97 | 11.06 | -2.20 | 1 |
| USDJPY | M15 | hit | slot_hhmm=09:45 & mtf_H4=BULLISH | V alvo 0.5ATR ate 15min | VENDA | 111 |  | 8.40 | -6.02 | 3.56 | 2.08 | 57.66 | 3/3 | 26/30 | 0.97 | 11.06 | -2.65 | 1 |
| USDJPY | M30 | hit | slot_hhmm=09:30 & mtf_H4=BULLISH | V alvo 1.0ATR ate 15min | VENDA | 111 |  | 9.37 | -4.31 | 2.69 | 1.85 | 54.95 | 3/3 | 27/30 | 0.97 | 11.06 | -1.69 | 1 |

### 3 sexta (proximo ao fechamento semanal) — 28 famílias (as 15 melhores)

| ativo | tf | modo | condicao | serie | lado | n_val | bruto_pts_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos | custo_medio_pts | comissao_RT_pts_7usd | liq_apos_comissao | n_formas_equivalentes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| USDCHF | H1 | ret | day_of_week=FRIDAY & ret_bar_atr=Q3 | 5min | VENDA | 475 | 12.35 | 6.39 | -4.82 | 5.45 | 3.03 | 49.05 | 5/6 | 38/65 | 5.96 | 5.77 | 0.62 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & volatility_state=VERY_LOW | 5min | VENDA | 319 | 14.18 | 7.09 | -4.82 | 5.04 | 2.96 | 49.22 | 4/6 | 36/65 | 7.09 | 5.77 | 1.32 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & range_atr=Q1 | 5min | VENDA | 340 | 13.58 | 6.61 | -4.82 | 5.11 | 2.91 | 49.41 | 4/6 | 38/65 | 6.97 | 5.77 | 0.84 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & cost_atr=Q5 | 5min | VENDA | 800 | 15.61 | 5.92 | -4.82 | 5.32 | 2.79 | 50.62 | 4/6 | 34/55 | 9.68 | 5.77 | 0.15 | 1 |
| NZDUSD | H1 | open | day_of_week=FRIDAY & month=4 | 180min | VENDA | 149 | 46.16 | 39.99 | -7.94 | 3.15 | 2.61 | 53.69 | 5/5 | 5/5 | 6.17 | 7.00 | 32.99 | 1 |
| USDJPY | H1 | ret | day_of_week=FRIDAY & p2=Q2 | 15min | VENDA | 447 | 15.04 | 11.24 | -2.17 | 3.12 | 2.57 | 53.69 | 5/6 | 41/65 | 3.80 | 11.06 | 0.18 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & session=NEW_YORK | 60min | VENDA | 342 | 13.62 | 11.73 | -4.93 | 3.49 | 2.42 | 53.22 | 6/6 | 48/65 | 1.89 | 5.77 | 5.96 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & cost_atr=Q5 | 15min | VENDA | 795 | 14.75 | 5.46 | -5.02 | 4.79 | 2.39 | 51.19 | 5/6 | 35/55 | 9.29 | 5.77 | -0.31 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & price_position_daily_open=Q5 | 5min | VENDA | 402 | 10.98 | 5.39 | -4.82 | 4.56 | 2.36 | 50.50 | 6/6 | 41/61 | 5.59 | 5.77 | -0.38 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & mtf_M15=BULLISH | 5min | VENDA | 813 | 8.58 | 3.64 | -4.82 | 5.37 | 2.21 | 50.18 | 5/6 | 42/65 | 4.94 | 5.77 | -2.13 | 1 |
| USDCHF | H1 | open | day_of_week=FRIDAY & session=NEW_YORK | 65min | VENDA | 459 | 25.12 | 9.74 | -6.77 | 3.70 | 2.14 | 53.81 | 5/6 | 40/65 | 15.38 | 5.77 | 3.97 | 1 |
| USDJPY | H1 | ret | day_of_week=FRIDAY & mtf_D1=BREAK_UP | 5min | VENDA | 272 | 11.38 | 8.55 | -1.60 | 2.52 | 2.11 | 56.99 | 6/6 | 19/25 | 2.83 | 11.06 | -2.51 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & volatility_state=VERY_LOW | 15min | VENDA | 317 | 11.42 | 4.73 | -5.02 | 4.33 | 2.09 | 48.26 | 5/6 | 37/65 | 6.69 | 5.77 | -1.04 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & session=NEW_YORK | 5min | VENDA | 459 | 22.53 | 7.15 | -4.82 | 3.60 | 2.08 | 49.67 | 4/6 | 34/65 | 15.38 | 5.77 | 1.38 | 1 |
| USDCHF | H1 | ret | day_of_week=FRIDAY & session_high_distance_atr=Q4 | 5min | VENDA | 387 | 11.39 | 5.35 | -4.82 | 4.03 | 2.08 | 49.87 | 6/6 | 45/64 | 6.04 | 5.77 | -0.42 | 1 |

## 7. Repetição entre ativos (mesma condição em mais de um ativo com líquido positivo)

| chave | ativos | n_ativos | liq_medio |
|---|---|---|---|
| day_of_week=MONDAY | VENDA | AUDUSD,BTCUSD,NZDUSD,US30,USDCHF,USDJPY | 6 | 838.43 |
| mtf_M1=BREAK_DOWN | COMPRA | BTCUSD,NZDUSD,US30,USDCHF,USDJPY,XAUUSD | 6 | 532.99 |
| session=LONDON_NY_OVERLAP | COMPRA | AUDUSD,NZDUSD,US30,USDCHF,USDJPY,XAUUSD | 6 | 171.04 |
| hour=22 | COMPRA | BTCUSD,NZDUSD,US30,USDCHF,USDJPY,XAUUSD | 6 | 143.72 |
| hour=21 | COMPRA | AUDUSD,BTCUSD,NZDUSD,USDJPY,XAUUSD | 5 | 3,498.84 |
| mtf_D1=BEARISH | COMPRA | BTCUSD,NZDUSD,USDCHF,USDJPY,XAUUSD | 5 | 2,144.88 |
| close_position=Q5 | VENDA | BTCUSD,US30,USDCHF,USDJPY,XAUUSD | 5 | 1,831.80 |
| mtf_D1=RANGE | COMPRA | AUDUSD,BTCUSD,US30,USDJPY,XAUUSD | 5 | 1,809.50 |
| slot_hhmm=22:00 | COMPRA | BTCUSD,NZDUSD,USDCHF,USDJPY,XAUUSD | 5 | 1,459.82 |
| day_of_week=SUNDAY | COMPRA | AUDUSD,BTCUSD,NZDUSD,US30,USDJPY | 5 | 1,139.76 |
| day_of_week=WEDNESDAY | COMPRA | BTCUSD,US30,USDCHF,USDJPY,XAUUSD | 5 | 948.62 |
| day_of_week=MONDAY | COMPRA | BTCUSD,US30,USDCHF,USDJPY,XAUUSD | 5 | 844.45 |
| range_atr=Q5 | COMPRA | BTCUSD,NZDUSD,US30,USDJPY,XAUUSD | 5 | 614.18 |
| hour=10 | COMPRA | NZDUSD,US30,USDCHF,USDJPY,XAUUSD | 5 | 416.18 |
| day_of_week=THURSDAY | COMPRA | BTCUSD,US30,USDCHF,USDJPY,XAUUSD | 5 | 408.44 |
| volatility_state=EXTREME | COMPRA | BTCUSD,NZDUSD,USDCHF,USDJPY,XAUUSD | 5 | 289.78 |
| mtf_H4=BREAK_UP | COMPRA | BTCUSD,NZDUSD,US30,USDJPY,XAUUSD | 5 | 222.28 |
| news_state=EVENTS_4_AROUND_60M | VENDA | NZDUSD,US30,USDCHF,USDJPY,XAUUSD | 5 | 142.72 |
| month=7 | COMPRA | BTCUSD,US30,USDCHF,XAUUSD | 4 | 6,413.25 |
| slot_hhmm=20:00 | COMPRA | BTCUSD,US30,USDCHF,XAUUSD | 4 | 1,815.20 |
| mtf_M5=BREAK_DOWN | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 1,799.17 |
| mtf_H1=BREAK_UP | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 1,694.87 |
| slot_hhmm=15:00 | VENDA | AUDUSD,BTCUSD,NZDUSD,US30 | 4 | 1,610.99 |
| price_position_daily_open=Q5 | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 1,597.53 |
| hour=7 | COMPRA | BTCUSD,US30,USDCHF,USDJPY | 4 | 1,560.63 |
| day_of_week=TUESDAY | VENDA | NZDUSD,US30,USDCHF,XAUUSD | 4 | 1,308.94 |
| price_position_weekly_open=Q1 | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 935.18 |
| hour=6 | COMPRA | BTCUSD,NZDUSD,USDJPY,XAUUSD | 4 | 850.53 |
| day_of_week=FRIDAY | VENDA | NZDUSD,US30,USDCHF,USDJPY | 4 | 806.84 |
| dom_w=d08_14 | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 761.14 |
| lower_wick_pct=Q1 | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 740.38 |
| mtf_D1=BREAK_DOWN | COMPRA | NZDUSD,US30,USDCHF,XAUUSD | 4 | 732.22 |
| previous_low_distance_atr=Q5 | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 722.92 |
| structure_at_close=BULLISH | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 673.47 |
| session_low_distance_atr=Q1 | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 628.07 |
| mtf_H4=BEARISH | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 617.96 |
| direction=BEARISH | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 565.21 |
| hour=15 | COMPRA | BTCUSD,US30,USDCHF,USDJPY | 4 | 554.53 |
| mtf_W1=BREAK_UP | COMPRA | BTCUSD,NZDUSD,USDJPY,XAUUSD | 4 | 540.18 |
| slot_hhmm=12:00 | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 514.42 |
| price_position_weekly_open=Q3 | COMPRA | BTCUSD,NZDUSD,USDJPY,XAUUSD | 4 | 500.18 |
| session=OFF_SESSION | VENDA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 417.70 |
| slot_hhmm=23:30 | VENDA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 400.49 |
| range_atr=Q3 | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 356.19 |
| session=NEW_YORK | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 345.93 |
| day_of_week=TUESDAY | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 338.29 |
| mtf_H4=RANGE | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 331.66 |
| mtf_H1=BULLISH | COMPRA | BTCUSD,USDCHF,USDJPY,XAUUSD | 4 | 323.70 |
| mtf_M15=RANGE | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 301.21 |
| slot_hhmm=23:00 | VENDA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 288.33 |
| month=8 | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 280.16 |
| hour=1 | COMPRA | US30,USDCHF,USDJPY,XAUUSD | 4 | 277.58 |
| price_position_weekly_open=Q4 | COMPRA | BTCUSD,USDCHF,USDJPY,XAUUSD | 4 | 264.03 |
| mtf_M30=BULLISH | COMPRA | BTCUSD,USDCHF,USDJPY,XAUUSD | 4 | 237.59 |
| upper_wick_pct=Q5 | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 235.12 |
| previous_high_distance_atr=Q4 | COMPRA | AUDUSD,BTCUSD,USDJPY,XAUUSD | 4 | 228.83 |
| price_position_daily_open=Q1 | VENDA | US30,USDCHF,USDJPY,XAUUSD | 4 | 213.62 |
| news_state=NONE_60M | COMPRA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 209.85 |
| session=LONDON_NY_OVERLAP | VENDA | AUDUSD,US30,USDCHF,USDJPY | 4 | 205.50 |
| hour=2 | VENDA | BTCUSD,US30,USDJPY,XAUUSD | 4 | 183.89 |

## 8. Melhores famílias com líquido positivo por ativo (inclui as que não passaram no BH, exploratórias)

### AUDUSD

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | mtf_D1=RANGE & price_position_weekly_open=Q4 | 120min | COMPRA | nao | 4 demais | 505 | 28.39 | -14.33 | 12.51 | 8.30 | 63.37 | 1/2 | 8/13 |
| M5 | open | mtf_H1=BREAK_DOWN & mtf_D1=RANGE | 65min | COMPRA | nao | 4 demais | 96 | 31.38 | -14.84 | 7.43 | 5.07 | 67.71 | 2/2 | 9/12 |
| M5 | ret | mtf_H1=BREAK_DOWN & mtf_D1=RANGE | 60min | COMPRA | nao | 4 demais | 96 | 27.67 | -14.88 | 7.27 | 4.75 | 65.62 | 2/2 | 9/12 |
| M5 | ret | day_of_week=SUNDAY & price_position_monthly_open=Q5 | 60min | COMPRA | nao | 1 abertura de semana (domingo/gap) | 169 | 16.15 | -14.88 | 7.13 | 3.72 | 53.25 | 1/2 | 2/8 |
| M15 | open | day_of_week=SUNDAY & news_state=NONE_60M | 255min | COMPRA | nao | 1 abertura de semana (domingo/gap) | 580 | 20.96 | -11.91 | 5.77 | 3.64 | 55.86 | 3/3 | 18/34 |
| M15 | open | day_of_week=SUNDAY | 255min | COMPRA | nao | 1 abertura de semana (domingo/gap) | 582 | 20.74 | -11.91 | 5.74 | 3.62 | 55.67 | 3/3 | 18/34 |
| M15 | open | session=LONDON_NY_OVERLAP & mtf_D1=RANGE | 135min | COMPRA | nao | 4 demais | 810 | 16.83 | -13.57 | 6.59 | 3.58 | 54.81 | 3/3 | 18/28 |
| M15 | ret | day_of_week=SUNDAY & news_state=NONE_60M | 240min | COMPRA | nao | 1 abertura de semana (domingo/gap) | 580 | 18.97 | -12.19 | 5.62 | 3.39 | 54.66 | 3/3 | 17/34 |
| M15 | ret | day_of_week=SUNDAY | 240min | COMPRA | nao | 1 abertura de semana (domingo/gap) | 582 | 18.79 | -12.19 | 5.60 | 3.37 | 54.47 | 3/3 | 17/34 |
| M15 | ret | day_of_week=SUNDAY & mtf_M5=BEARISH | 240min | COMPRA | nao | 1 abertura de semana (domingo/gap) | 226 | 30.57 | -12.19 | 4.66 | 3.32 | 60.62 | 3/3 | 22/34 |
| M30 | open | day_of_week=SUNDAY & news_state=NONE_60M | 270min | COMPRA | nao | 1 abertura de semana (domingo/gap) | 295 | 27.92 | -11.47 | 4.68 | 3.29 | 57.29 | 3/3 | 17/33 |
| M15 | open | session=LONDON_NY_OVERLAP & mtf_D1=BREAK_UP | 135min | VENDA | nao | 4 demais | 384 | 29.49 | -17.88 | 5.32 | 3.28 | 55.47 | 3/3 | 14/18 |

### BTCUSD

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | hit | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q4 | V alvo 1.0ATR ate 240min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 270 | 13,847.10 | -1,541.97 | 33.77 | 32.86 | 98.89 | 2/2 | 7/7 |
| M5 | hit | price_position_weekly_open=Q1 & price_position_monthly_open=Q5 | C alvo 1.0ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 288 | 11,012.70 | -2,021.70 | 34.62 | 32.29 | 98.96 | 2/2 | 3/3 |
| M5 | hit | session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 2.0ATR ate 240min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 115 | 18,241.93 | -902.18 | 30.60 | 31.38 | 100.00 | 2/2 | 12/12 |
| M5 | hit | session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 1.0ATR ate 240min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 115 | 8,214.57 | -1,541.97 | 29.20 | 29.11 | 100.00 | 2/2 | 12/12 |
| M5 | hit | mtf_D1=BREAK_DOWN & news_min_to_next_high=Q4 | V alvo 2.0ATR ate 240min | VENDA | nao | 4 demais | 270 | 26,517.61 | -902.18 | 26.18 | 25.82 | 95.93 | 2/2 | 7/7 |
| M5 | hit | session=LONDON & news_state=EVENTS_5_AROUND_60M | V alvo 0.5ATR ate 240min | VENDA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 115 | 3,200.25 | -1,780.03 | 26.18 | 23.75 | 100.00 | 2/2 | 12/12 |
| M5 | hit | month=7 & price_position_weekly_open=Q1 | C alvo 1.0ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 64 | 8,370.75 | -2,021.70 | 23.87 | 20.88 | 100.00 | 2/2 | 2/2 |
| M5 | open | mtf_D1=BEARISH & month=7 | 245min | COMPRA | nao | 4 demais | 1,393 | 24,614.20 | -1,694.37 | 20.01 | 18.63 | 65.54 | 2/2 | 2/2 |
| M5 | ret | mtf_D1=BEARISH & month=7 | 240min | COMPRA | nao | 4 demais | 1,393 | 24,104.14 | -1,725.07 | 19.77 | 18.35 | 65.90 | 2/2 | 2/2 |
| M5 | hit | month=7 & price_position_weekly_open=Q1 | C alvo 0.5ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 64 | 3,396.34 | -2,091.03 | 23.58 | 17.30 | 100.00 | 2/2 | 2/2 |
| M5 | hit | month=7 & price_position_weekly_open=Q1 | C alvo 0.5ATR ate 60min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 64 | 3,254.80 | -2,212.83 | 22.61 | 14.47 | 98.44 | 2/2 | 2/2 |
| M5 | open | mtf_D1=BEARISH & month=7 | 125min | COMPRA | nao | 4 demais | 1,417 | 11,857.14 | -1,757.69 | 13.59 | 11.73 | 60.76 | 2/2 | 2/2 |

### DXY

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | open | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 125min | VENDA | nao | 4 demais | 111 | 66.54 | -31.52 | 8.49 | 5.77 | 71.17 | 2/2 | 11/14 |
| M5 | ret | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 120min | VENDA | nao | 4 demais | 111 | 62.92 | -31.47 | 8.12 | 5.42 | 65.77 | 2/2 | 11/14 |
| M30 | open | month=10 & atr_ratio_prev=Q1 | 270min | COMPRA | nao | 4 demais | 76 | 121.33 | -27.98 | 6.49 | 5.27 | 77.63 | 3/3 | 3/3 |
| M30 | ret | month=10 & cost_atr=Q5 | 240min | COMPRA | nao | 4 demais | 137 | 79.09 | -28.02 | 6.78 | 4.96 | 68.61 | 2/3 | 2/3 |
| M5 | open | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 65min | VENDA | nao | 4 demais | 111 | 33.92 | -30.94 | 7.52 | 3.94 | 58.56 | 2/2 | 11/14 |
| M5 | ret | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 60min | VENDA | nao | 4 demais | 111 | 30.30 | -30.83 | 7.14 | 3.55 | 56.76 | 2/2 | 8/14 |
| M5 | open | mtf_W1=RANGE & news_min_since_last_high=Q1 | 125min | COMPRA | nao | 4 demais | 1,768 | 4.99 | -28.48 | 12.70 | 1.83 | 51.81 | 1/2 | 6/10 |

### NZDUSD

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M15 | hit | mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 2.0ATR ate 240min | COMPRA | nao | 4 demais | 368 | 44.99 | -7.26 | 11.67 | 10.03 | 69.29 | 3/3 | 8/9 |
| M15 | hit | mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 1.0ATR ate 240min | COMPRA | nao | 4 demais | 368 | 27.78 | -6.87 | 11.14 | 8.96 | 79.35 | 3/3 | 8/9 |
| M15 | hit | mtf_D1=BREAK_DOWN & prev_day_high_distance_atr=Q5 | V alvo 2.0ATR ate 240min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 51 | 39.91 | -3.79 | 8.28 | 7.68 | 90.20 | 2/2 | 6/6 |
| M30 | hit | mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 1.0ATR ate 240min | COMPRA | nao | 4 demais | 184 | 36.71 | -6.65 | 8.29 | 7.03 | 71.74 | 3/3 | 9/9 |
| M30 | hit | mtf_D1=BREAK_DOWN & dom_w=d01_07 | C alvo 2.0ATR ate 240min | COMPRA | nao | 4 demais | 184 | 51.43 | -6.39 | 7.64 | 6.78 | 64.67 | 3/3 | 8/9 |
| M15 | ret | mtf_H4=BEARISH & month=10 | 240min | VENDA | nao | 4 demais | 758 | 32.39 | -4.95 | 7.61 | 6.49 | 54.75 | 3/3 | 3/3 |
| M5 | open | hour=13 & news_min_to_next_high=Q1 | 65min | COMPRA | nao | 4 demais | 760 | 16.55 | -6.10 | 7.31 | 5.28 | 57.89 | 2/2 | 12/18 |
| M5 | ret | hour=13 & news_min_to_next_high=Q1 | 60min | COMPRA | nao | 4 demais | 760 | 15.75 | -6.12 | 7.33 | 5.21 | 59.34 | 2/2 | 13/18 |
| M5 | ret | session=OFF_SESSION & prev_day_low_distance_atr=Q1 | 60min | COMPRA | nao | 4 demais | 345 | 12.19 | -6.12 | 7.24 | 4.82 | 57.97 | 1/2 | 9/18 |
| M30 | ret | mtf_H4=BEARISH & month=10 | 240min | VENDA | nao | 4 demais | 377 | 32.83 | -5.68 | 5.50 | 4.61 | 55.17 | 3/3 | 3/3 |
| M5 | open | session=LONDON_NY_OVERLAP & news_min_to_next_high=Q1 | 65min | COMPRA | nao | 4 demais | 1,606 | 9.26 | -6.10 | 7.73 | 4.54 | 51.93 | 2/2 | 12/18 |
| M5 | open | hour=22 & mtf_W1=BULLISH | 65min | COMPRA | nao | 4 demais | 216 | 15.94 | -6.10 | 6.16 | 4.46 | 65.28 | 1/2 | 5/8 |

### US30

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | hit | mtf_H4=BREAK_DOWN & news_min_since_last_high=Q5 | C alvo 0.5ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 167 | 1,640.11 | -125.01 | 44.49 | 82.49 | 100.00 | 2/2 | 6/6 |
| M5 | hit | hour=11 & atr_ratio=Q1 | C alvo 1.0ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 40 | 1,452.59 | -80.75 | 24.70 | 35.40 | 100.00 | 2/2 | 10/10 |
| M5 | hit | hour=11 & atr_ratio=Q1 | C alvo 0.5ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 40 | 666.29 | -125.01 | 19.71 | 32.47 | 100.00 | 2/2 | 10/10 |
| M5 | hit | news_min_to_next_high=Q1 & atr_ratio=Q1 | C alvo 0.5ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 73 | 790.27 | -125.01 | 21.65 | 32.25 | 100.00 | 2/2 | 12/12 |
| M5 | hit | hour=10 & atr_ratio=Q1 | C alvo 1.0ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 84 | 1,450.92 | -80.75 | 23.64 | 32.03 | 100.00 | 2/2 | 13/13 |
| M5 | hit | mtf_W1=BEARISH & prev_day_low_distance_atr=Q1 | C alvo 2.0ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 376 | 6,727.42 | 148.81 | 29.62 | 31.12 | 98.40 | 2/2 | 2/2 |
| M5 | hit | mtf_W1=BEARISH & prev_day_low_distance_atr=Q1 | C alvo 1.0ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 376 | 3,419.57 | -80.75 | 29.14 | 30.51 | 99.20 | 2/2 | 2/2 |
| M5 | hit | mtf_W1=BEARISH & prev_day_low_distance_atr=Q1 | C alvo 0.5ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 376 | 1,713.69 | -125.01 | 27.55 | 29.63 | 100.00 | 2/2 | 2/2 |
| M5 | hit | hour=10 & atr_ratio=Q1 | C alvo 0.5ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 84 | 665.46 | -125.01 | 19.19 | 29.38 | 100.00 | 2/2 | 13/13 |
| M5 | hit | mtf_D1=BREAK_DOWN & prev_day_low_distance_atr=Q5 | C alvo 0.5ATR ate 240min | COMPRA | sim | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 107 | 683.08 | -125.01 | 18.94 | 27.07 | 100.00 | 2/2 | 3/3 |
| M5 | hit | session=LONDON & atr_ratio=Q1 | C alvo 1.0ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 214 | 1,416.38 | -80.75 | 21.32 | 26.65 | 99.53 | 2/2 | 12/13 |
| M5 | hit | hour=13 & month=3 | V alvo 1.0ATR ate 240min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 48 | 5,234.26 | -325.25 | 26.79 | 26.11 | 100.00 | 1/1 | 1/1 |

### USDCHF

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | month=7 & price_position_monthly_open=Q2 | 240min | COMPRA | nao | 4 demais | 872 | 39.83 | 1.06 | 11.25 | 11.58 | 75.57 | 2/2 | 2/2 |
| M15 | hit | mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | V alvo 2.0ATR ate 240min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 149 | 58.49 | -8.46 | 12.26 | 10.79 | 84.56 | 3/3 | 4/4 |
| M5 | open | hour=13 & mtf_W1=BEARISH | 65min | VENDA | nao | 4 demais | 250 | 49.67 | -6.22 | 11.10 | 9.85 | 71.20 | 2/2 | 10/12 |
| M5 | open | mtf_M30=BEARISH & month=3 | 245min | COMPRA | nao | 4 demais | 162 | 79.62 | 1.20 | 9.32 | 9.49 | 80.25 | 1/1 | 1/1 |
| M5 | ret | hour=13 & mtf_W1=BEARISH | 60min | VENDA | nao | 4 demais | 250 | 47.97 | -5.96 | 10.63 | 9.44 | 68.80 | 2/2 | 10/12 |
| M5 | hit | news_state=EVENTS_2_AROUND_60M & month=3 | C alvo 0.5ATR ate 60min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 97 | 12.78 | -6.78 | 13.66 | 9.07 | 92.78 | 1/1 | 1/1 |
| M5 | hit | mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | V alvo 0.5ATR ate 60min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 66 | 12.48 | -7.31 | 13.30 | 8.52 | 95.45 | 2/2 | 7/7 |
| M15 | ret | mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | 240min | VENDA | nao | 4 demais | 149 | 76.44 | -8.60 | 9.21 | 8.30 | 78.52 | 3/3 | 4/4 |
| M15 | hit | mtf_W1=BREAK_DOWN & price_position_weekly_open=Q5 | V alvo 1.0ATR ate 240min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 149 | 31.56 | -8.37 | 10.19 | 8.14 | 87.92 | 3/3 | 4/4 |
| M5 | hit | news_state=EVENTS_2_AROUND_60M & month=3 | C alvo 2.0ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 83 | 56.32 | -2.41 | 8.35 | 8.06 | 97.59 | 1/1 | 1/1 |
| M5 | open | mtf_H4=BREAK_DOWN & news_min_since_last_high=Q4 | 65min | VENDA | nao | 4 demais | 66 | 49.25 | -6.22 | 8.58 | 7.67 | 77.27 | 2/2 | 6/7 |
| M5 | open | news_state=EVENTS_2_AROUND_60M & month=3 | 65min | COMPRA | nao | 4 demais | 97 | 41.93 | -2.98 | 7.83 | 7.34 | 73.20 | 1/1 | 1/1 |

### USDJPY

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | ret | mtf_H1=BULLISH & price_position_monthly_open=Q2 | 240min | COMPRA | nao | 4 demais | 2,511 | 53.85 | -4.49 | 15.27 | 14.54 | 60.53 | 2/2 | 12/18 |
| M5 | hit | news_state=EVENTS_3_AROUND_60M & price_position_monthly_open=Q5 | V alvo 1.0ATR ate 60min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 53 | 41.96 | -7.47 | 15.11 | 13.04 | 96.23 | 2/2 | 8/8 |
| M5 | open | day_of_week=FRIDAY & month=3 | 245min | COMPRA | nao | 3 sexta (proximo ao fechamento semanal) | 204 | 162.21 | -4.48 | 13.30 | 13.02 | 80.39 | 1/1 | 1/1 |
| M5 | hit | news_state=EVENTS_3_AROUND_60M & price_position_monthly_open=Q5 | V alvo 0.5ATR ate 60min | VENDA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 53 | 20.61 | -6.72 | 16.68 | 12.95 | 98.11 | 2/2 | 8/8 |
| M5 | ret | day_of_week=FRIDAY & month=3 | 240min | COMPRA | nao | 3 sexta (proximo ao fechamento semanal) | 204 | 160.15 | -4.49 | 13.13 | 12.85 | 79.41 | 1/1 | 1/1 |
| M5 | hit | day_of_week=FRIDAY & month=3 | C alvo 2.0ATR ate 240min | COMPRA | nao | 3 sexta (proximo ao fechamento semanal) | 204 | 58.38 | -5.89 | 13.59 | 12.83 | 85.29 | 1/1 | 1/1 |
| M5 | open | mtf_W1=BULLISH & news_min_to_next_high=Q5 | 125min | COMPRA | nao | 4 demais | 2,388 | 32.34 | -1.87 | 12.98 | 12.73 | 64.74 | 2/2 | 13/14 |
| M5 | open | news_min_to_next_high=Q5 | 125min | COMPRA | nao | 4 demais | 4,767 | 27.35 | -1.87 | 13.17 | 12.44 | 62.49 | 2/2 | 17/18 |
| M5 | ret | mtf_W1=BULLISH & news_min_to_next_high=Q5 | 120min | COMPRA | nao | 4 demais | 2,388 | 30.86 | -1.92 | 12.69 | 12.38 | 63.99 | 2/2 | 13/14 |
| M5 | ret | news_min_to_next_high=Q5 | 120min | COMPRA | nao | 4 demais | 4,767 | 26.41 | -1.92 | 13.07 | 12.30 | 62.14 | 2/2 | 17/18 |
| M5 | ret | mtf_H1=BULLISH & price_position_monthly_open=Q2 | 120min | COMPRA | nao | 4 demais | 2,655 | 31.78 | -1.92 | 12.70 | 12.24 | 59.06 | 2/2 | 13/18 |
| M5 | ret | mtf_D1=BEARISH & prev_day_low_distance_atr=Q3 | 120min | COMPRA | nao | 4 demais | 1,869 | 51.37 | -1.92 | 12.46 | 11.82 | 65.44 | 2/2 | 10/10 |

### XAUUSD

| tf | modo | condicao | serie | lado | passou_BH | cat | n_val | liq_B_pts_val | base_B_pts_val | t_delta | t_liq_B | pct_pos_B | anos_pos | meses_pos |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M5 | hit | hour=4 & mtf_M30=BREAK_UP | C alvo 0.5ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 84 | 171.39 | -27.20 | 28.96 | 45.68 | 100.00 | 2/2 | 15/15 |
| M5 | hit | hour=0 & month=3 | C alvo 0.5ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 60 | 531.81 | -27.20 | 32.55 | 33.06 | 100.00 | 1/1 | 1/1 |
| M5 | hit | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | C alvo 1.0ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 110 | 609.60 | -37.59 | 30.84 | 31.25 | 100.00 | 2/2 | 13/14 |
| M5 | hit | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | C alvo 0.5ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 110 | 300.80 | -27.20 | 28.97 | 30.84 | 100.00 | 2/2 | 14/14 |
| M5 | hit | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | C alvo 2.0ATR ate 240min | COMPRA | nao | 2 hit sem perdedores observados / amostra pequena (cauda invisivel) | 110 | 1,149.00 | -59.83 | 22.30 | 21.59 | 96.36 | 2/2 | 14/14 |
| M5 | hit | month=5 & news_min_to_next_high=Q1 | C alvo 2.0ATR ate 240min | COMPRA | nao | 4 demais | 694 | 590.05 | -59.83 | 13.67 | 12.42 | 80.84 | 2/2 | 2/2 |
| M5 | hit | month=8 & news_min_since_last_high=Q5 | C alvo 2.0ATR ate 240min | COMPRA | nao | 4 demais | 675 | 461.06 | -59.83 | 13.66 | 12.27 | 84.00 | 2/2 | 2/2 |
| M5 | hit | month=3 & news_min_to_next_high=Q4 | C alvo 2.0ATR ate 240min | COMPRA | nao | 4 demais | 182 | 1,559.03 | -59.83 | 12.15 | 11.70 | 87.91 | 1/1 | 1/1 |
| M5 | hit | month=8 & news_min_since_last_high=Q5 | C alvo 1.0ATR ate 240min | COMPRA | nao | 4 demais | 675 | 273.19 | -37.59 | 12.85 | 11.67 | 92.74 | 2/2 | 2/2 |
| M15 | hit | month=3 & news_min_to_next_high=Q4 | C alvo 2.0ATR ate 240min | COMPRA | nao | 4 demais | 212 | 1,693.00 | -71.40 | 11.57 | 11.11 | 78.77 | 3/3 | 3/3 |
| M5 | hit | day_of_week=WEDNESDAY & month=3 | V alvo 2.0ATR ate 240min | VENDA | nao | 4 demais | 164 | 1,055.09 | 36.94 | 10.27 | 10.69 | 82.32 | 1/1 | 1/1 |
| M5 | ret | news_state=EVENTS_5_AROUND_60M & dom_w=d22_31 | 240min | COMPRA | nao | 4 demais | 110 | 2,140.64 | -53.64 | 10.79 | 10.56 | 89.09 | 2/2 | 12/14 |

## 9. Limites e avisos

- **Dados:** os candles M1 ficaram incompletos por um teto do código (`InpMaxCatchupBars`, corrigido na v1.23.1; requer reiniciar o EA e reconstruir); por isso a mineração usa eventos M5/M15/M30/H1 e mede o futuro nas barras M1 que o terminal tem (FORWARD_TIME). Eventos M1 não foram minerados.
- **XAUUSD da FP** ficou fora (EA parou; usado o XAUUSD da IC). **DXY_Z6** é contrato com vencimento (rolagem não tratada).
- **Custo:** spread estimado por perfil de ticks dos últimos ~120 dias (mediana por slot); não inclui slippage, requotes, comissão (declarada 0) nem swap. Em abertura de semana, rolagem e notícias o spread real pode ser muito maior.
- **Sem stop:** os modos `hit` assumem o perfil do operador (sem SL). Perdas raras e grandes podem não estar na amostra; veja a categoria 2.
- **Validação:** uma janela cronológica única (40% finais) e ativos correlacionados (AUDUSD/NZDUSD, USDCHF/USDJPY): achar a mesma coisa em pares correlacionados não é replicação independente.
- **Overlap:** janelas futuras se sobrepõem; a estatística usa amostra efetiva n·min(1, tf/horizonte), ainda assim aproximada.
- **Não é prova de lucro:** é triagem com controle de falso positivo, em dados históricos de 1,5 a 5 anos, sem execução real.
