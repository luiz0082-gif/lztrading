# WallStreetBreaker v2.4: correções sobre a v2.3

A **lógica de entrada e saída não mudou**: rompimento de 12 candles M15 com filtro de ATR e ADX, TP em $, trailing em $ e piramidação. As mudanças são de segurança e de bugs.

| # | Problema na v2.3 | Correção na v2.4 | Muda o backtest? |
|---|---|---|---|
| 1 | Stop de emergência só existia **dentro do EA**. Se a VPS caísse, o MT5 travasse ou a internet falhasse, a posição ficava **sem proteção nenhuma**. | SL real no servidor, na mesma distância em $ (`InpEmergencyOnServer`). | Quase nada. Só em gaps a execução pode sair um pouco diferente. |
| 2 | Posição atravessava o fim de semana. **No seu relatório 1: stop de $50 virou -$80,78 em 19/01/2026 às 01:01** (gap de abertura de segunda). | Zera na sexta às 22h do servidor (`InpCloseFriday`). | Sim, pode mudar alguns trades. |
| 3 | Perda diária atingida só **bloqueava novas entradas**. A posição aberta continuava perdendo. | Fecha as posições (`InpCloseOnDailyLoss`). | Pouco (raro com lote 0,01). |
| 4 | Com piramidação, cada posição tinha o próprio limite de $30: 4 posições = até $120 de perda. | Limite para o conjunto das posições (`InpMaxBasketLossUsd`). | Só em dias com piramidação. |
| 5 | Piramidação ignorava sessão, circuit breaker e meta/perda do dia. | Agora obedece. | Pouco. |
| 6 | Reiniciar o MT5 no meio do dia **zerava a perda diária e a contagem de trades**. Depois de um dia ruim, o EA "esquecia" o prejuízo. | Equity do início do dia e contagem de trades salvas e recuperadas do histórico. | Não (o backtest não reinicia). |
| 7 | Trailing podia mandar modify **a cada tick** e ignorava o stop level da corretora (erros "invalid stops"; algumas corretoras punem excesso de requisições). | Passo mínimo de $0,20 e respeito ao stop level. | Mínimo. |
| 8 | Piramidação com fator 0,6 sobre 0,01 dava 0,006, e a v2.3 **arredondava para cima** até 0,01. O fator não fazia nada. | `InpPyramidForceMinLot`: `true` = igual à v2.3; `false` = pula a piramidação se o lote ficar abaixo do mínimo. | Não, com o padrão `true`. |
| 9 | Variáveis globais de posições fechadas pelo SL no servidor ficavam acumuladas para sempre. | Limpeza periódica. | Não. |
| 10 | `#property strict` (é de MQL4) e preços sem normalizar pelo tick size. | Removido e normalizado. | Não. |

**Rode o backtest de novo com a v2.4** antes de qualquer outra coisa. Os resultados vão mudar um pouco (itens 2 a 5).

# v2.5: diagnóstico de "não abre ordens"

| O que mostra | Onde aparece |
|---|---|
| **Permissões**, ao iniciar e em todo candle: botão Algo Trading, "Permitir Algo Trading" nas propriedades do EA, login com senha de investidor, conta que não aceita robôs, símbolo bloqueado. | Aba **Experts** (e um Alert, se estiver bloqueado) |
| **Varredura dos últimos 30 dias:** quantas vezes ADX, ATR e rompimento passaram, e quantos **sinais completos** houve. Se der ~0, o EA não está quebrado: o sinal é que não aconteceu. | Aba Experts: `WSB2 SCAN` |
| **Motivo de cada candle M15** (PASS / BLOCK e por quê). | Aba Experts (`InpVerbose`) |
| **Ordem recusada pela corretora**, com o código e a descrição. | Aba Experts: `WSB2 ORDEM RECUSADA` |
| Desvio máximo agora configurável (`InpDeviationPts = 50`). Os 15 pontos fixos da v2.3 equivalem a US$ 0,15 no ouro, o que gera requote em conta real com execução instantânea. No testador isso nunca acontece. | Input |
