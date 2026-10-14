# Relatório de Análise — CSVs do EA MicroMomentum (v2.00 / v2.10)

- **Data da análise:** 2026-10-05
- **Janela dos dados:** 2026-09-30 02:21 → 2026-10-05 21:56 (hora do servidor)
- **Símbolo / TF:** XAUUSD (M1), magic 1001, lote 0,01–0,10
- **Reprodução:** `python tools/micromomentum/analyze.py` (lê os CSVs sem alterá-los)
- **Método:** `docs/ANALISE-DADOS.md` — integridade primeiro, depois reconstrução, depois performance. Fatos, inferências e hipóteses ficam separados.

> Os dados são **ao vivo**: o EA continuava gravando durante a análise (ex.: `events.csv` foi de 12.276 para 12.288 linhas). Os totais podem variar em poucas unidades numa nova execução.

---

## 1. Resumo executivo

| | Plataforma A | Plataforma B | Total |
|---|---|---|---|
| Corretora (demo) | IC Markets, alavancagem 1:100 | FP Markets, alavancagem 1:30 | |
| Símbolo | XAUUSD | XAUUSD.r | |
| Saldo | 12.130,92 → 12.175,24 | 100.164,35 → 100.247,26 | |
| Sessões do EA (pastas) | 65 | 25 | 90 |
| Trades fechados (`trades.csv`) | 277 | 33 | **310** |
| Net dos trades do EA (USD) | +197,76 | +33,07 | **+230,83** |
| Win rate | 81,6 % | 90,9 % | 82,6 % |
| Ticks gravados | 2,75 M | 0,31 M | 3,06 M |

**Conclusões principais (detalhadas nas seções seguintes):**

1. **O resultado positivo é real nos dados, mas vem de uma estrutura sem stop.** Em **todas as 83 sessões com `params.csv`, `InpSLMode = EXIT_OFF`**. O EA tem alvo curto (~US$ 1,20–1,50) e segura a posição até o alvo. O pior trade fechado perdeu apenas US$ 1,55, mas o pior movimento contra uma posição (MAE) foi **−US$ 42,11 em 0,01 lote (−4.205 pontos), cerca de 35× o alvo**, com posição aberta por até **3,85 h**.
2. **Se existisse um stop em dinheiro, o resultado histórico seria negativo.** Usando o MAE de cada trade, um stop de US$ 3 a US$ 15 teria virado o net para negativo; só com stop ≥ US$ 30 o net seria positivo (+41,69 contra +230,83 reais). Isso é inferência por MAE, ignora slippage do stop, mas indica que o lucro depende de posições perdedoras voltarem ao alvo.
3. **A v2.10 (ESCAPE) trocou a cauda longa por um edge fino.** Na A, a v2.00 fez 140 trades, +US$ 136,08, win 96,4 %. A v2.10 fez 137 trades, +US$ 61,68, win 66,4 %. Nas saídas ESCAPE (84 trades) o lucro bruto foi US$ 25,84 e a **comissão consumiu US$ 13,26 (51 %)**.
4. **Há muitas operações na conta que não são do EA.** Foram **~204 posições** (167 na A, 37 na B), lote majoritariamente 0,01, sem comentário, que aparecem em `transactions.csv` mas não em `trades.csv` nem em `positions.csv`. Algumas ficaram abertas até **~4 dias** e fecharam com perda. **O saldo da conta A não reconcilia com o `trades.csv`**: o saldo subiu +44,32 enquanto o net dos trades do EA foi +197,76. A origem não pode ser provada pelos CSVs.
5. **Execução:** a plataforma A tem slippage médio de entrada de +6,5 pts (p90 28; máx 133) e latência de ~383 ms. A B tem slippage 0 e latência de ~186 ms. Houve 87 fechamentos recusados (`frozen` e `position closed`).
6. **O EA fica ocioso a maior parte do tempo:** em **81 %** dos ticks o estado é `BLOCK_GOAL` (meta diária atingida). A meta foi atingida 24 vezes.
7. **A telemetria é boa para auditoria, mas foge do padrão `docs/CSV.md`** (delimitador, `schema_version`, timezone, rotação, volume). Ver seção 10.

---

## 2. Escopo e inventário dos dados

| | A | B |
|---|---|---|
| Pasta | `…\010E0471…\MQL5\Files\MicroMomentum\XAUUSD_1001` | `…\5194A13C…\MQL5\Files\MicroMomentum\XAUUSD.r_1001` |
| Arquivos | 718 | 277 |
| Volume | 678 MB | 140 MB |
| Sessões | 65 | 25 |
| Dias com dados | 30/09, 01/10, 02/10, 03/10, 04/10, 05/10 | 01/10 a 05/10 |
| Tempo coberto por sessões | ~102 h | ~68 h |

Cada sessão (`S<hhmmss>`) grava 11 CSVs: `account`, `bars`, `chart`, `events`, `orders`, `params`, `positions`, `signals`, `ticks`, `trades`, `transactions`. Sessões grandes geram `ticks_p002.csv` e `ticks_p003.csv` (rotação por tamanho, `InpMaxFileMB = 64`). Há **2 arquivos `.rar`** dentro de pastas de sessão da B (8,6 KB e 8,7 KB), que não são telemetria.

Os dias 03/10 e 04/10 são sábado e domingo. Há registros de conta e ticks, sem trades.

---

## 3. Integridade

### Fatos observados

| Verificação | Resultado |
|---|---|
| Linhas com `seq` duplicado (trades, orders, signals, events, params, account, transactions) | **0** |
| `seq` fora de ordem dentro da sessão | **0** |
| `ticket` duplicado em `trades.csv` | **0** |
| Arquivos de tamanho zero | 0 |
| Cabeçalhos por tipo de CSV | 1 cabeçalho por tipo, exceto `signals` (+`trend_dir`, `trend_er`) e `trades` (+`counter_trend`) |
| Valores não numéricos em colunas numéricas de `trades.csv` | 0 |
| Trades de 20261002/S114641 (A) sem `params.csv` na mesma pasta | 11 (a sessão atravessou a virada do dia; os params estão em 20261001) |
| Lacunas de `account.csv` > 120 s | A: 7, B: 5 (maior: ~22 h na A) |
| Sessões com menos de 5 min | 35 de 90 (reinícios e testes) |
| `POSITION_OPENED` (362) vs `ENTRY_FILLED` (312) | 50 eventos de diferença, **não explicados** |
| Deals do EA com `mine = 0` | 13 (A) e 1 (B). Pelo código, `mine` só é 1 se a posição ainda está em `g_pos` quando a transação chega (`OnTradeTransaction`); deals de fechamento tardios saem com 0. **É artefato do log, não prova de posição alheia** |

### Inferências

- Os dados são consistentes internamente: sem duplicatas e sem sequência quebrada.
- As mudanças de schema entre v2.00 e v2.10 foram aditivas, mas sem `schema_version`. Um leitor automático precisa descobrir a versão pelo cabeçalho.

---

## 4. Configurações testadas

### Fatos observados

- **83 sessões com `params.csv`**: 61 na A e 22 na B.
- **Nenhuma sessão usa stop loss** (`InpSLMode = EXIT_OFF`, `sl_effective = OFF`).
- `InpServerSideStops = true` em todas, ou seja, o TP vai para o servidor.
- Os parâmetros mudaram a cada poucas sessões:

| Parâmetro | Valores observados |
|---|---|
| Lote | 0,01 / 0,02 / 0,10 |
| TP | US$ 1,00 a 2,00; ou 120 pts; (~20 a ~200 pts efetivos) |
| `InpMaxOpenPositions` | 1, 2, 5, 6, 8 |
| `InpMaxSpreadPoints` | 8, 11, 12, 15, 20 |
| `InpMinPointsDisplacement` | 30, 35, 60 |
| Meta diária | US$ 15, 30, 45, 60, 80, 100 |
| Recoil | ligado/desligado |
| v2.10 | adiciona `InpEscape*`, `InpCTEscapeSec`, `InpTrend*` (filtro de tendência por ER) |

### Inferência

O conjunto de 310 trades é uma **mistura de dezenas de configurações**. Não existe um "resultado do EA" único, e as médias globais descrevem a mistura. Para decidir qualquer coisa é preciso fixar uma configuração e acumular amostra nela.

---

## 5. Performance dos trades (`trades.csv`)

### 5.1 Visão geral (310 trades, USD)

| Métrica | Valor |
|---|---|
| Net | **+230,83** |
| Lucro bruto / comissão | 267,11 / −36,28 (**13,6 %** do bruto) |
| Win rate | 82,6 % |
| Ganho médio / perda média | +0,944 / −0,203 |
| Pior trade fechado / melhor | −1,55 / +2,90 |
| Fator de lucro | 22,1 |
| Expectativa por trade | +0,745 (IC95 bootstrap 0,674–0,815) |
| Participação dos 10 maiores trades no net | 9 % |
| Perdas: quantidade e soma | 47 trades, −10,95 |

> O IC95 assume trades independentes. Como 17 % das entradas ocorrem a ≤ 10 s da anterior e podem ser a mesma tese, o intervalo real é mais largo.

### 5.2 Por motivo de saída

| Saída | Trades | Net | Observação |
|---|---|---|---|
| TP_MONEY | 81 | +106,17 | alvo em dinheiro (EA fecha) |
| TP_SERVIDOR | 95 | +89,44 | alvo executado pelo servidor; 4 com net negativo |
| TP_POINTS | 15 | +17,10 | alvo em pontos |
| ESCAPE | 84 | +12,58 | só v2.10; win 53,6 %, média +0,15 |
| RECOIL | 19 | +6,05 | |
| MANUAL_TERMINAL | 4 | +2,41 | fechamento manual no terminal (todos na A) |
| ESCAPE_CT | 9 | +0,26 | |
| TEMPO_MAX | 3 | −3,18 | 3 perdas, todas na B (sessão com `InpMaxHoldSec = 180`), hold de ~180 s |

### 5.3 Por versão (mapeando a sessão para a versão)

| Plataforma / versão | Trades | Net | Win | Expectativa | Pior trade |
|---|---|---|---|---|---|
| A — v2.00 | 140 | +136,08 | 96,4 % | +0,972 | −0,70 |
| A — v2.10 | 137 | +61,68 | 66,4 % | +0,450 | −1,54 |
| B — v2.00 | 33 | +33,07 | 90,9 % | +1,002 | −1,55 |

### 5.4 Por dia (hora do servidor)

| Dia | Trades | Net | Win |
|---|---|---|---|
| 30/09 (qua) | 109 | +101,88 | 96 % |
| 01/10 (qui) | 17 | +17,88 | 94 % |
| 02/10 (sex) | 26 | +33,60 | 100 % |
| 05/10 (seg) | 158 | +77,47 | 69 % |

A segunda-feira concentra a v2.10 com ESCAPE e a sessão `S125858` (101 trades, +26,93, win 59 %).

### 5.5 Direção

| Direção | Trades | Net | Win | Hold mediano |
|---|---|---|---|---|
| BUY | 216 | +143,26 | 77,8 % | 43 s |
| SELL | 94 | +87,57 | 93,6 % | 136 s |

### 5.6 Por duração

| Duração | Trades | Net | Win | Pior MAE (US$) |
|---|---|---|---|---|
| ≤ 10 s | 60 | +36,09 | 78 % | −3,15 |
| 10–30 s | 60 | +32,80 | 70 % | −6,55 |
| 30–60 s | 35 | +27,96 | 86 % | −4,89 |
| 1–5 min | 64 | +47,09 | 81 % | −7,55 |
| 5–15 min | 38 | +30,89 | 92 % | −13,95 |
| 15–60 min | 32 | +33,49 | 97 % | −15,65 |
| 1–4 h | 21 | +22,51 | 90 % | **−42,11** |

Hold: mediana 60 s, p90 33 min, p99 3,6 h, máximo 3,85 h.

### 5.7 Hora do dia (servidor ≈ UTC+3)

| Faixa | Observação |
|---|---|
| 01h–04h | 85 trades, net +78,4, win 87–100 % |
| 17h | 31 trades, +31,32, win 97 % |
| 18h–20h | 106 trades, net +30,1, **win 56–62 %** |

A faixa 18h–20h coincide com a sessão da v2.10 de 05/10. **Hora e versão estão misturadas**, então esse dado não separa as duas causas.

### 5.8 Custos

- **Comissão:** −US$ 0,08 por 0,01 lote por trade, ida e volta (o degrau de saldo sugere metade na entrada e metade na saída). Em trades ESCAPE (bruto médio ~US$ 0,31) ela consome ~51 %.
- **Spread de entrada médio:** 7,3 pts. Trades com spread de entrada > 9 pts têm expectativa menor (+0,55 contra +0,86 com spread ≤ 5).
- **Slippage de entrada:** trades com slippage > 20 pts têm expectativa de +0,46 contra +0,80 nos demais.
- **Contra-tendência (v2.10):** `counter_trend = 0`: 122 trades, +0,45 por trade. `= 1`: 15 trades, +0,43. Trades sem a coluna (v2.00): 173, +0,98.

---

## 6. Risco e exposição

### Fatos observados

| Medida | A | B |
|---|---|---|
| Posições simultâneas máximas do EA | 8 | 6 |
| Pior flutuante só das posições do EA (`positions.csv`) | −113,73 (01/10 03:54) | **−252,90** (02/10 04:10, 6 posições) |
| Pior flutuante da conta (`account.csv`) | −371,86 (05/10 07:29) | −294,12 (02/10 04:10) |
| Maior drawdown de equity pico→vale | −489,49 (**4,0 %** do pico) | −255,56 (0,26 %) |
| Margem mínima (margin level) | 1.947 % | 10.255 % |
| Segundos com ≥ 6 posições abertas | 11.615 | 12.167 |

- Na B, **4 trades abertos entre 03:06 e 03:11 do dia 02/10 chegaram a −US$ 42 cada** (−4.120 a −4.205 pts) e ficaram ~3,4 h abertos até fecharem no TP (+US$ 1,44 cada). É o pior bloco de risco do conjunto.
- **45 dos 256 trades vencedores (17,6 %)** tiveram MAE pior que −US$ 5. 28 passaram de −US$ 10 e 10 passaram de −US$ 20.
- Ao fim dos dados, na B, o ticket `411190828` (aberto 05/10 16:16) seguia aberto com flutuante −US$ 30,65 e hold de ~5,7 h.

### Stop hipotético (inferência por MAE; sem slippage, sem path dependency)

| Stop | Trades cortados | Net resultante | Net real |
|---|---|---|---|
| US$ 3 | 86 (27,7 %) | −114,95 | +230,83 |
| US$ 5 | 51 (16,5 %) | −76,82 | +230,83 |
| US$ 10 | 30 (9,7 %) | −102,13 | +230,83 |
| US$ 15 | 18 (5,8 %) | −60,63 | +230,83 |
| US$ 20 | 11 (3,5 %) | −2,27 | +230,83 |
| US$ 30 | 6 (1,9 %) | +41,69 | +230,83 |

### Inferências

- O win rate de 82,6 % e o pior trade de −US$ 1,55 **não medem o risco** do sistema, porque a perda fica não realizada enquanto a posição está aberta.
- O risco real é a **cauda de MAE**. Em conta de US$ 12 mil o maior DD foi 4 %, mas com lote 0,10 (testado em 7 trades) ou 8 posições a cauda cresce linearmente.
- O stop virtual ou a saída ESCAPE só protegem enquanto o terminal está conectado. Não há stop de servidor.

---

## 7. Execução (`orders.csv`, `transactions.csv`)

### Fatos observados

| Medida | A abertura | A fechamento | B abertura | B fechamento |
|---|---|---|---|---|
| Ordens com `retcode 10009` | 277 | 126 | 35 | 6 |
| Slippage médio (pts) | **6,48** | 2,36 | **0** | 0 |
| Slippage p90 / máx | 28,4 / 133 | 19,5 / 71 | 0 / 0 | 0 / 0 |
| Latência mediana | 383 ms | 381 ms | 186 ms | 186 ms |

**Falhas de fechamento (87, `CLOSE_FAILED`):**

| Retcode | Descrição | A | B |
|---|---|---|---|
| 10029 | `frozen` — "Modification failed due to order or position being close to market" | 53 | 0 |
| 10036 | `position closed` — "Position doesn't exist" | 14 | 20 |

- Dos 53 `frozen`, 52 ocorreram em fechamento `TP_MONEY` e 1 em `ESCAPE`.
- Todas as entradas (312) foram aceitas: **0 rejeições de abertura**.
- Slippage de entrada: bucket de spread (5,6] teve slippage médio de 15,5 pts (11 trades), mas a amostra é pequena.

### Inferências

- Os `10036` são provavelmente corrida entre o TP de servidor e o fechamento do EA: a posição já fechou quando o EA tenta fechar. Em geral é inofensivo, mas gera ruído de ERROR.
- Os `10029` mostram que o fechamento em dinheiro às vezes tenta agir perto do preço e a corretora recusa.
- A diferença A×B (slippage 0 e latência metade) sugere diferença de infraestrutura/modelo de execução entre as demos. **O resultado da B é otimista para comparação** e não deve ser extrapolado para conta real.

---

## 8. Sinais e bloqueios

### Fatos observados

- **701 sinais:** 312 `ENTER` (A 277, B 35) e 389 `SKIP` (A 378, B 11).
- Motivos de `SKIP`: `posicao_oposta_aberta` 342, `contra_tendencia_fraco` 47. `ok` 296 e `ok_contra_tendencia` 16 foram entradas.
- **Estados dos 3,06 M ticks:**

| Estado | % |
|---|---|
| BLOCK_GOAL (meta diária atingida) | **80,98 %** |
| IN_POSITION (inclui "limite de posições abertas") | 8,26 % |
| PAUSED (painel) | 3,23 % |
| SCANNING | 2,61 % |
| BLOCK_SPREAD | 2,61 % |
| BLOCK_TRADING (AlgoTrading desligado) | 1,49 % |
| BLOCK_CANDLE | 0,59 % |
| COOLDOWN / BLOCK_LOSSES | 0,24 % |

- **Notas do detector:** `sem_impulso` 68,5 %, `SINAL` 18,2 %, `poucos_ticks` 11,3 %, `pullback_excedido` 2,0 %, `fraco_vs_spread` 0,08 %.
- **Spread:** média 8,54 pts (A 8,40; B 9,82), máximo **700 pts** às 15h do servidor (notícias). Bloqueio por spread é de 48 % dos ticks às 01h, 19 % às 22h e 17 % às 23h.
- **Eventos de atenção:** 24 `DAILY_GOAL_HIT`, 25 `ENV_CHANGE`, 9 `TRADING_NOT_ALLOWED` (AlgoTrading desligado), 1 `LOSS_STREAK_PAUSE`.

### Inferências

- A meta diária de US$ 15–100 é batida rápido com alvos de US$ 1,20, e o EA fica parado. **O limite diário limita o ganho, mas não a perda aberta**, porque não há limite de perda ligado (`InpDailyStopEnable = false`) nem stop.
- O filtro `posicao_oposta_aberta` (342 skips) impede hedge de sinal oposto e é relevante para a leitura de "oportunidades perdidas".

---

## 9. Operações fora do EA e reconciliação do saldo

### Fatos observados

- `transactions.csv` tem 1.038 deals. Pelo identificador de posição:

| Plataforma | Deals de posições que estão no `trades.csv` | Deals de posições **fora** do `trades.csv` |
|---|---|---|
| A | 576 | **328** (≈ 167 posições) |
| B | 66 | **68** (≈ 37 posições, inclui 2 abertas do EA) |

- As posições fora do `trades.csv`: lote 0,01 (388 de 396 deals), campo `req_comment` vazio, hold mediano ~3 min na A, máximo **5.664 min (~3,9 dias)**.
- **Degraus de saldo não explicados** na A (posições com ticket ausente do `trades.csv`; o EA só gerencia o magic 1001): −117,76 (01/10 03:14), −39,02, −5,81, −20,64, −24,73, −40,11, −55,08 (01/10 18:26), −29,12, −29,29, −29,32 (05/10 14:11), entre outros. Ex.: o fechamento de −117,76 foi de uma posição SELL aberta fora do EA, com o EA em estado `PAUSED`.
- Reconciliação por dia (A): saldo 30/09 +153,68 contra trades +101,88; 01/10 **−182,30** contra +17,88; 02/10 +57,78 contra +16,32; 05/10 +15,16 contra +61,68.
- O maior drawdown da A (−489,49) e o pior flutuante (−371,86, 05/10 07:29) incluem essas posições. O flutuante do EA sozinho naquele dia foi −97,09.

### Inferências

- Há outro agente operando XAUUSD nas mesmas contas (outro EA, outro magic, ou operação manual), com resultado líquido **negativo** na A em 01/10. Nada nos CSVs identifica quem.
- O saldo da conta **não deve ser usado** para avaliar o MicroMomentum. Usar `trades.csv`.

### Hipóteses (não comprovadas)

- Os fechamentos de maior perda (−117, −55, −3×29) podem ser fechamentos manuais de posições antigas ou o stop-out de outro robô. Para confirmar, é preciso o histórico de deals da conta com `DEAL_MAGIC` e `DEAL_REASON`.

---

## 10. Aderência ao padrão `docs/CSV.md`

| Item do padrão | Estado no MicroMomentum |
|---|---|
| Delimitador `;` | usa **`,`** |
| `schema_version` e `ea_version` por linha | não existe; versão só em `params.csv` |
| Timezone declarado | não declarado. Há `t_server` e `t_local`; a diferença observada é +6 h (servidor ≈ UTC+3 se o local for UTC−3, **suposição**) |
| Tipos de CSV | 11 por sessão, mais finos que o padrão; **não há CSV de decisões**. `signals.csv` cobre parte |
| `reason_code`/`reason_detail` em bloqueios | `block_reason` em texto livre, com números embutidos ("spread 11 > 8"), o que dificulta agrupar |
| `trade_id` e IDs de ordem/deal/posição | `ticket`, `deal`, `order` presentes |
| MFE/MAE, retcode, latência, slippage | presentes. **Ponto forte** |
| Rotação | por sessão e por tamanho (64 MB). Não segue o padrão mensal/diário |
| Volume | `positions.csv` (1,3 M linhas) e `ticks.csv` (1 linha por tick, `InpLogEveryTick = true`): `ticks` 573 MB, `positions` 222 MB e `account` 92 MB (606 mil linhas) de um total de ~890 MB |
| `chart.csv` | registra eventos de UI/objetos de gráfico; valor analítico baixo |
| Flag de propriedade do deal | `mine` não é confiável (depende de a posição ainda estar em memória); registrar `DEAL_MAGIC` |
| Risco por trade | não há `risk_money`, `planned_rr` nem `realized_r`, porque não existe stop |

---

## 11. Fatos, inferências e hipóteses

### Fatos observados

- 310 trades, net +US$ 230,83, win 82,6 %, pior trade fechado −US$ 1,55.
- Nenhuma sessão usou stop loss.
- MAE máximo −US$ 42,11 (−4.205 pts) em posição de 0,01 lote aberta por 3,4 h; hold máximo de 3,85 h.
- v2.00: win 96 %, expectativa +0,97 por trade (A). v2.10: win 66 %, expectativa +0,45.
- Comissão = 13,6 % do lucro bruto; 51 % do bruto nas saídas ESCAPE.
- 81 % dos ticks em `BLOCK_GOAL`.
- Plataforma A: slippage de entrada médio +6,5 pts, latência 383 ms. Plataforma B: slippage 0, latência 186 ms.
- Existem ~204 posições na conta que não estão em `trades.csv`; o saldo da A não reconcilia com o `trades.csv`.
- Os arquivos não têm duplicatas nem `seq` fora de ordem.

### Inferências

- O lucro do EA depende de posições adversas voltarem ao alvo; com stop em dinheiro ≤ US$ 20 o histórico seria negativo.
- A v2.10 reduz o tempo exposto, mas o edge por trade é fino e sensível a comissão e slippage.
- A amostra mistura ~dezenas de configurações, seis dias e um único regime de XAUUSD (4.126–4.216). Não permite concluir que a estratégia tem vantagem estatística.
- O saldo das contas está contaminado por operações de terceiros.

### Hipóteses

- A vantagem aparente da v2.00 pode ser característica de um regime de reversão à média intradiária; um movimento direcional forte de ouro com 6–8 posições abertas e sem stop produziria perda muito maior que a observada.
- As posições estranhas na conta são de outro EA ou de operação manual (não verificado).
- A queda de win rate na v2.10 em 05/10 pode vir do ESCAPE (saída precoce) e não de piora do sinal.

---

## 12. Recomendações

Estas são sugestões. Nenhuma alteração foi feita nos EAs.

1. **Stop de emergência e circuit breaker de equity** (separados do TP), idealmente como stop real no servidor. Primeiro medir no testador o stop mínimo compatível com o MAE (a tabela da seção 6 mostra que stops curtos destroem o resultado atual).
2. **Limite de perda aberta em dinheiro** (soma flutuante das posições do EA) e **limite de posições por direção**, já que as 6–8 posições se acumulam no mesmo lado.
3. **Congelar uma configuração** e acumular amostra nela. Gravar em cada linha de `trades.csv` um `config_id`/hash dos parâmetros e a `ea_version`.
4. **Identificar as posições de terceiros:** registrar `DEAL_MAGIC`, `DEAL_REASON` e `DEAL_COMMENT` em `transactions.csv`, e conferir o histórico da conta. Enquanto isso, usar contas separadas por EA.
5. **TP líquido de custos:** com comissão de US$ 0,16 por 0,02 lote de ida e volta, o TP precisa ser definido em dinheiro líquido, e a expectativa avaliada depois de comissão e slippage.
6. **Tratar `10036` como evento esperado** (INFO/WARN) em vez de ERROR, e revisar a política de retentativa dos `10029`.
7. **Alinhar a telemetria ao `docs/CSV.md`:** `schema_version`, delimitador `;`, timezone/UTC explícito, `reason_code` estável (separado do detalhe numérico), `trade_id`, rotação por período, e reduzir o `InpLogEveryTick` para eventos/amostragem. Corrigir a flag `mine` e explicar os 50 `POSITION_OPENED` sem `ENTRY_FILLED`.
8. **Validar fora da amostra:** backtest em tick real com os mesmos custos, e forward em conta com execução realista (a B tem slippage 0, otimista).

---

## 13. Limitações desta análise

- 6 dias, um símbolo, um regime. Sem fora de amostra.
- Os trades se sobrepõem no tempo e são correlacionados; os intervalos de confiança estão subestimados.
- O MAE do what-if de stop não considera slippage nem a ordem temporal dentro do trade.
- A atribuição de hora, versão e configuração está confundida no período de 05/10.
- A conclusão sobre operações de terceiros se baseia na ausência do ticket em `trades.csv`/`positions.csv` (o EA só gerencia o magic 1001 e `transactions.csv` registra todas as posições do símbolo); a origem real é desconhecida.
- O fuso horário do servidor foi deduzido, não declarado nos arquivos.
