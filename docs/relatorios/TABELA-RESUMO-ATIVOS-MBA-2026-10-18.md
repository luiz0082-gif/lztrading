# Tabela-resumo por ativo — o que o MBA encontrou

Gerada em 18/10/2026 a partir das análises intraday (entrada no horário, saída no alvo ou às 23:30 do servidor, sem stop). Hora = **hora do servidor** (Londres = servidor−2h, NY = servidor−7h). Resultados retrospectivos (2024-01 a 2026-10), sem comissão e slippage. Dados de apoio: `docs/relatorios/mba/resumo_por_ativo.csv`.

## Como ler as colunas
- **Custo** = spread medido nos ticks ÷ ATR M5. Até ~0,1 é barato; acima de ~0,3 o custo come o movimento de minutos.
- **Horário puro vs. acaso** = quantos horários passaram nos critérios, comparado com o máximo que o teste com dados embaralhados no tempo (placebo) aprova. Só vale se for **maior** que o placebo.
- **Padrão com condição** = horário + condição conhecida antes da abertura (por exemplo, "H4 em baixa"). `Base` = % de dias que **qualquer** horário bate o mesmo alvo, para ver quanto a condição melhora.
- **Pior dia** = pior resultado de um único dia no histórico (sem stop).
- **Confiança:** **A** = acima do acaso e consistente nos anos; **B** = pista que merece conferir no gráfico; **C** = sem evidência ou dominado por viés de alta/custo.

## A tabela

| Ativo | Custo | Horários puros vs. acaso | Padrão mais promissor (hora do servidor) | Acerto (base) · média real | Pior dia | Confiança |
|---|---|---|---|---|---|---|
| **XAUUSD** (ouro) | 0,02 | **32 vs. 6** → acima | Venda 12:25 (M5, 5 min); compras 01:00–01:15 (alvo 500), 23:00 (3 h) | 69% · +96 pts; 89% (alvo 500) · +89 | −17.707 pts | **A** (cauda grande) |
| **XAGUSD** (prata) | 0,21 | 0 vs. 1 → nada | Nenhum. O 12:25 do ouro na prata: 54,5% (ouro 68,8%) | condição não melhora (78% vs 79%) | −6.458 | **C** |
| **USDJPY** | 0,07 | 17 vs. 33 → acaso | **Compra 03–04h, 07h, 10h** (Ásia) com H4 rompendo para baixo, alvo 300 | 71% (39%) · +32 | −3.051 | **B** |
| **EURJPY** | n/d (dados movidos) | 42 vs. 33 → marginal | **Compra 03–06h** com H4 em baixa e notícia distante, alvo 300 | 72% (40%) · +60 | −3.042 | **B** |
| **GBPJPY** | n/d (dados movidos) | 71 vs. 71 → acaso | **Compra 03–06h** (Ásia) com semanal em baixa, alvo 300; **07h** com D1 em baixa | 81% (51%) · +71; 80% · +123 | −5.691 | **B** |
| **USDCHF** | 0,22 | 5 vs. 13 → acaso | **Venda 10–11h** após rompimento de baixa no M30 sem notícia recente, alvo 300 | 56% (20%) · +73 | −1.059 | **B−** |
| **NZDUSD** | 0,26 | 5 vs. 10 → acaso | **Venda às segundas 01–02h**, alvo 90 | 86% (57%) · +31 | −873 | **B−** |
| **AUDUSD** | 0,63 | 0 vs. 0 → nada | Fraco: compra 01h com M15 em baixa, alvo 300 | 41% (20%) · +22 | −2.998 | **C** (spread alto) |
| **DXY** | 1,19 | 0 vs. 0 → nada | Fraco: compra 03–07h com semanal rompendo para cima | 51% (18%) · +63 | −875 | **C** (spread 30 pts > ATR) |
| **US30** | 0,05 | 28 vs. 3 → acima | Só compras com alvos enormes (7.525 pts), qualquer hora 01–16h | 81% (73%) · +597 | −129.580 | **C** (viés de alta) |
| **DE40** (DAX) | 0,05 | 55 vs. 32 → acima | **Compra 09:00 por 45 min** (M30): 58% acerto, 51% fecha ≥ 300 pts líquidos, média +503 pts, 3/3 anos | 79% · +530 (intraday) | −143.160 | **B+** |
| **USTEC** (Nasdaq) | 0,055 | 27 vs. 3 → acima | Compras 01:15–02:15 etc.; vendas condicionais (segunda 01h, quinta 05–07h) | 81% (73%) · +726 | −146.320 | **C** (viés de alta) |
| **US500** (S&P) | 0,15 | 32 vs. 2 → acima | Compras 01:15–03:00 | 81% (72%) · +130 | −21.635 | **C** (viés de alta) |
| **XTIUSD** (WTI) | 0,16 | 16 vs. 4 → acima | **Venda 02h** quando semanal em alta, alvo 370 | 86% (68%) · +44 | −5.030 | **B** |
| **XBRUSD** (Brent) | 0,08 | 33 vs. 0 → acima | **Venda 05–09h** (Ásia) com ATR anterior alto, alvo 370 | 88% (67%) · +92 | −9.490 | **B** |
| **BTCUSD** | 0,11 | — | Nada (descartado) | — | — | **C** |

## O que sai desta tabela
1. **Padrões que passam em tudo (A):** só o ouro. É o único em que o horário puro está acima do acaso, com ganho na escala de centenas de pontos e positivo todos os anos.
2. **Melhor hipótese nova (B+):** DE40, compra às 09:00 do servidor por 45 minutos.
3. **Famílias de pistas (B):**
   - **Iene (USDJPY, EURJPY, GBPJPY):** compra de manhã na Ásia quando os timeframes maiores estão em baixa. Os três compartilham a perna do iene, então não são confirmações independentes.
   - **Petróleo (XTIUSD, XBRUSD):** venda de madrugada/Ásia em certas condições (semanal em alta, ATR anterior alto).
4. **Sem evidência (C):** prata, AUDUSD, DXY e BTC. Os índices (US30, USTEC, US500) têm quase só compras por causa da alta do período, então o "padrão" é a tendência, com perdas potenciais enormes num único dia.

## Ressalvas
- A confiança **B** significa "conferir no gráfico", não "operar". São 2 a 3 anos de dados.
- Em todos os ativos, o pior dia sem stop é de várias vezes o ganho médio por operação.
- Comissão, slippage e swap não estão incluídos.
- Os valores de EURJPY e GBPJPY não têm custo numérico porque os dados brutos deles saíram da pasta; a análise foi feita antes disso.
