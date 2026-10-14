# Auditoria FluxMatrix PRO — IC Markets, FP Markets e backtest

- **Data:** 2026-10-09 (dados ao vivo da IC até 2026.10.10 04:59 hora do servidor)
- **Código auditado:** `FluxMatrix_PRO.mq5`, v2.10, build `FMX-20260922-PARITY`, 5047 linhas. IC e FP têm o **mesmo fonte** (SHA-256 `DEF149EF…167E8F`). Citações `:NNNN` abaixo são linhas desse arquivo.
- **Dados lidos:** CSVs da IC (05–09/10) e da FP (22–29/09), logs MQL5 e do terminal, logs do Strategy Tester, `.ini`/`.set` do tester e a saída dos CSVs do último backtest (agente 3001 da FP).
- **Reprodução:** `python tools/fluxmatrix/analyze.py` (somente leitura; aceita `BT=<pasta>`).
- **Nada foi alterado no EA.** Este documento só diagnostica e propõe.

## 1. Veredito

| | |
|---|---|
| **O que funciona** | Execução (129/129 `ORDERSEND_RESULT` com retcode 10009), reconciliação após reinício com cesto aberto, trava da meta diária, filtros de sessão/notícia/spread, trailing ao vivo sem nenhum fechamento negativo. **124 de 124 cestos ao vivo fecharam positivos**; 190 de 193 no backtest (3 perdas, a pior −5,26). |
| **O que preocupa** | O EA é um **martingale em grade sem nenhuma saída de emergência**. Quando a grade esgota, ele só espera. O pior caso medido: **−US$ 2.416 de flutuante por 5,1 dias** no backtest (24 % do depósito de US$ 10 mil). Ao vivo: −US$ 1.020 na FP, −US$ 357 na IC. |
| **O que está quebrado (observabilidade)** | O diagnóstico "por que não entrou" **nunca roda** (função morta); o volume do cesto sai sempre 0.00; a telemetria de execução grava **negócios de outros EAs** (≥ 65 % na IC); o fallback de TP em dinheiro **nunca é chamado**. Nenhum desses afeta a lógica de entrada. |
| **"Dificilmente fica preso"** | Verdade para o caso típico (mediana de 6–7 min por cesto). Não é verdade para a cauda: 30 % dos cestos ao vivo precisaram de 2+ pernas e 4 % chegaram a 5+. Esses ficam horas ou dias. |

**Em uma frase:** o EA é muito bom em colher ~US$ 50/dia e muito mal protegido contra o dia em que a grade não volta. A lucratividade que você viu é real nos dados, mas é a de uma estratégia com **ganho pequeno e frequente contra perda potencial grande e rara**, e a perda rara ainda não aconteceu na amostra.

## 2. Resultados por fonte

| | IC (ao vivo) | FP (ao vivo) | Backtest (FP, ticks reais) |
|---|---|---|---|
| Período | 05/10 04:25 → 09/10 15:30 (107 h) | 22/09 08:19 → 29/09 08:18 (168 h) | 24/08 → 28/09 |
| Capital | ≈ US$ 12 mil (equity) | ≈ US$ 99 mil | US$ 10 mil, 1:500 |
| Cestos fechados | 48 | 76 | 193 |
| Net dos cestos | **+203,89** | **+362,41** | **+936,04** (saldo final 10.931,76) |
| Ganhos / perdas | 48 / 0 | 76 / 0 | 190 / 3 (pior −5,26) |
| Retorno | +1,7 % | +0,37 % | +9,4 % |
| Mediana de duração | 7,3 min | 6,1 min | 3,3 min |
| Cestos > 3 h | 4 (máx 7,0 h) | 0 (máx 2,5 h) | 3 (máx **123 h**) |
| Pior MAE | −360,01 (5 pernas, 0,24 lote) | **−1.020,53** (6 pernas, 0,63 lote) | **−2.416,24** (5 pernas, 0,24 lote) |
| MAE ÷ capital | 3,0 % | 1,0 % | **24,2 %** |
| MAE ÷ média diária de lucro | 8,8 dias | 17 dias | 46 dias |
| Direção | 40 BUY / 8 SELL | 21 BUY / 55 SELL | 77 BUY / 116 SELL |

**Fatos que condicionam a leitura:**

1. **O lucro é limitado pela meta diária, não pela estratégia.** No backtest os 18 dias fecham entre 35 e 62, em torno de `InpDailyProfitTarget=50` do `.ini`. Ao vivo, IC (24–66) e FP (48–77) seguem o mesmo padrão; a meta da IC mudou ao longo da semana (`DAILY_TARGET_REACHED` com `Today=` 20,75 em 06/10, 50,79 em 08/10, 57,24 em 09/10). O EA colhe a meta e para (`DAILY_TARGET_LOCK`: 53 rejeições na IC, 390 na FP, 290 no backtest). É um bom controle de exposição, mas significa que "lucro/dia" mede a meta, não o edge.
2. **A direção segue a tendência do período** (IC comprou, FP vendeu). É o `TREND_EMA200_HARD` funcionando como desenhado — e também significa que a amostra é de um regime só.
3. **A IC não é um teste estável.** Em 5 dias houve **20 inícios de EA e 10 `ConfigHash` diferentes** (lote, multiplicador, níveis, grade, janela, trailing on/off). A configuração atual (hash `11598039…`) tem 25 cestos (10/08 → 10/09), incluindo o de −360.
4. **O backtest é uma janela só** (5 semanas) e **17 variações de input** dessa mesma janela estão em cache no tester da FP. Os 5 resultados visíveis no log foram 10.427, 10.430, 10.488, 10.932 e 11.010. A configuração auditada é a de 10.932. Isso é otimização na amostra.

## 3. O que está funcionando

| Item | Evidência |
|---|---|
| Execução das ordens | `ORDERSEND_RESULT`: 48/48 (IC) e 81/81 (FP) com `Retcode=10009`. 1 `INITIAL_ORDER_FAILED` (domingo, `TERMINAL_TRADE_DISABLED`, correto). |
| Tamanho das pernas | Recovery segue a regra (0,02 → 0,03 → 0,04 → 0,06 → 0,09 com mult. 1,5 e truncamento; 0,01 → … → 0,32 com mult. 2). IC: 22 recoveries confirmados, todos sequenciais, sem nível repetido. |
| Reinícios | Os 4 "Abnormal termination" do FluxMatrix na IC (05/10 09:22, 12:31, 12:49 e 08/10 14:48, hora local) são **fechamentos normais do terminal**: o diário mostra `Terminal exit with code 0` e todas as EAs removidas na mesma hora, não falha do EA. Reinícios com cesto aberto: 3 na IC (4, 4 e 3 posições) e 4 na FP (3, 1, 3 e 4). Em todos o EA reassumiu (`STARTUP_RECONCILED`, `StateLoaded=true`) e fechou o cesto normalmente, sem duplicar. |
| Meta diária | Trava corretamente; `Today=` bate com a soma dos cestos do dia (57,24 em 10/09). |
| Notícia/sessão/spread | `NEWS_BLOCK` (2 na IC), `SESSION_*` e `SPREAD_BLOCK` (18 na FP) aparecem e bloqueiam entrada. O recovery news guard respondeu `CLEAR` 8 vezes na FP e **nunca bloqueou** nos dados; seu comportamento de bloqueio não foi observado. |
| Trailing | Ao vivo: 18 saídas na IC e 15 na FP, **todas positivas** (mín. +0,58 na IC). No backtest as 3 perdas foram saídas por trailing (−5,26 e −0,69 em cestos de 5 pernas; −0,38 em perna única). |
| Dados | Cabeçalho estável nas 3 versões de schema (`SchemaVersion` na coluna 1). |
| Margem/lote | `PreflightOrder` usa `OrderCalcMargin`, `OrderCheck`, step real do símbolo. Boa prática. |

## 4. A cauda: o ponto central

### 4.1 Quão fundo a grade vai

Probabilidade de o cesto atingir cada nível (inclui o inicial):

| Pernas ≥ | Ao vivo (IC+FP, 124) | Backtest (193) |
|---|---|---|
| 2 | 37 (29,8 %) | 39 (20,2 %) |
| 3 | 16 (12,9 %) | 18 (9,3 %) |
| 4 | 9 (7,3 %) | 11 (5,7 %) |
| 5 | 5 (4,0 %) | 7 (3,6 %) |
| 6 | 1 (0,8 %) | — |

Cestos com 5+ pernas (média por cesto no backtest): MAE médio **−635**, duração média **19 h**, ganho médio **+16**. Ou seja, o EA aceita carregar centenas de dólares de flutuante para ganhar uns 16.

### 4.2 O que acontece depois do último nível

Quando `recoveryLevel >= InpMaxRecoveryLevels` (`CanAttemptRecovery` :2769) ou o próximo lote estoura `InpMaxBasketVolume` (`PreflightOrder` :2854), o recovery para e **não há mais nada**: sem saída por dinheiro, por tempo, por % de equity, sem hedge. Confirmado por busca no fonte: nenhum `EquityFloor`, `MaxLoss`, `Emergency`, `CircuitBreaker`, `DailyLoss` ou equivalente. (O build `FMX-20260922`, anterior ao PARITY, tinha `DailyLossMoney`/`DailyLossPercent`; a FP registrou `DailyLoss=OFF`. Foram removidos no PARITY.)

O que sobra de proteção na versão atual:

| Proteção | Valor observado | Efetivo? |
|---|---|---|
| `InpMinMarginLevelPct` (200–500 %) | menor margem vista: 1.076 % (FP), 1.145 % (IC), **4.051 % (backtest, em −2.416)** | **Não.** Com 1:500 e 0,24 lote a margem nunca é o limite; o limite é o equity. |
| `InpMaxBasketVolume` (0,22 / 0,30 / 0,65) | corta o último nível | Só limita o *tamanho*, não a *perda*. |
| `InpMaxRecoveryLevels` (3–6) | limita o nº de pernas | Idem. |
| Meta diária | trava entradas após a meta | Não limita perda. |

### 4.3 O episódio de 17–22/09 no backtest

Cesto SELL aberto em 17/09 08:3x, **5 pernas (0,24 lote) em 30 minutos** (grade esgotada), depois 5,1 dias de flutuante entre −145 e **−2.416** (pior em 18/09 10:51), fechando em 22/09 11:31 com **+55,26**. Durante esses 5 dias o EA não abriu nenhum outro cesto (um cesto por vez): perdeu 3 dias de meta (17, 18 e 21/09 ausentes no resultado diário). Mesma história, em menor escala, na IC (10/09: 4,2 h preso entre 11:21 e 15:30, −357) e na FP (25/09: 0,63 lote, −1.020).

**Sensibilidade (aritmética, não previsão):** com 0,24 lote cada US$ 1 de movimento contra vale US$ 24; com 0,63, US$ 63. A grade esgota com ~US$ 16 de adverso (4 níveis × ~US$ 4). Um movimento adicional de US$ 100 custa **−US$ 2.400 / −US$ 6.300**. Nenhuma dessas perdas foi realizada ainda porque o preço voltou; a amostra não contém o dia em que não volta.

### 4.4 Como ler "98 % de acerto"

A taxa de acerto de um martingale com TP curto é alta por construção. Ela não distingue "entrada boa" de "grade que sempre espera o preço voltar". Hoje os dados **não permitem separar as duas coisas**. O teste que separa é o placebo da seção 7 (E5).

## 5. Problemas encontrados

Ordem por gravidade. "Confirmado" = visto em código **e** nos dados.

### 5.1 Risco

| # | Problema | Evidência | Gravidade |
|---|---|---|---|
| R1 | Sem saída de emergência nem limite de perda monetária (cesto, equity, tempo). | Seção 4.2; busca no fonte; backtest −2.416 por 5,1 dias. | **Alta** |
| R2 | `MaxRecoveryLevels` incompatível com `MaxBasketVolume` gera tentativa de ordem impossível a cada cooldown. Na FP 25/09: nível desejado 6, `ORDER_FAILURE_COOLDOWN` **170 vezes** entre 04:11 e 05:45. A causa não ficou registrada (o `Print` de 25/09 já não existe), mas a mais provável é o teto de volume: o 7º lote seria 0,64 e 0,63 + 0,64 > 0,65. (`PreflightOrder` :2854, `CanAttemptRecovery` :2761) | `RECOVERY_DECISIONS` da FP; `RISK_PROJECTION` (22/09) com `MaxRecoveryLevels=6` e `WorstCaseTotalVolume=1.27` contra cap 0,65. | Média |
| R3 | `RISK_PROJECTION` mostra só margem estimada e volume teórico (:793). Ignora o cap, o truncamento de lote (projeta 0,26; real 0,24) e não diz quanto dinheiro se perde por US$ 1 ou por US$ 50. | Logs `RISK_PROJECTION`. | Média |
| R4 | Fallback de TP em dinheiro **morto**: `MonitorTakeProfitMoney()` (:3543) é declarada, definida e **nunca chamada**. Se o TP broker-side não puder ser posto (`gTPMoneyMonitorOnly=true`, setado em :2932, :2938, :3374 e :3410 — esta última sem log), o cesto fica sem alvo e nada o fecha. Hoje 0 ocorrências de `TP_MONEY_SOLVER_FAILED`, então é risco latente. | Busca de chamadas. | Média |
| R5 | Recovery news guard e filtro de notícia **desligados no tester** (:1509, :1581). O backtest opera em janelas de notícia que o ao vivo bloqueia, e o ao vivo pode ficar sem poder promediar durante a notícia. Os dois resultados não são comparáveis nesse ponto. | `RECOVERY_NEWS_GUARD_TESTER_BYPASS`. | Média |

### 5.2 Observabilidade (CSV/painel/log)

| # | Problema | Evidência | Gravidade |
|---|---|---|---|
| T1 | `BuildSetupDiagnosis()` (:4228) **nunca é chamada**. `gSetupHead` fica `"INICIANDO"` para sempre. O painel não explica por que está parado e o funil grava `NO_SETUP | INICIANDO` em 100 % dos casos (3.637/3.637 IC, 5.813/5.813 FP, 27.093/27.093 backtest). O `CaptureMarketSnapshot` (:2330) já calcula tudo que ela precisa. | `SIGNAL_FUNNEL`. | **Alta** (viola "o usuário deve descobrir por que não opera") |
| T2 | `OnTradeTransaction` (:1131) registra **qualquer** transação da conta, sem filtro de símbolo/magic, em `EXECUTION` e `DEALS_EXPORT`, e chama `SaveState` a cada uma (:1151-1157). Na IC, 908 de 1.390 deals (65 %) caem **fora de qualquer janela de cesto**, ou seja, são certamente de outros EAs. Esperado do FluxMatrix: ~136 deals (68 pernas × 2). No backtest a conta é exata (268 pernas = 536 deals, 0 alheios), o que valida o cálculo. | `DEALS_EXPORT`; `analyze.py`. | **Alta** (CSV inutilizável para atribuição; I/O desnecessário) |
| T3 | `Volume=0.00` em 100 % das linhas de `BASKET_SUMMARY`. `CsvBasketRow` (:2482) lê `gBasket.totalVolume` depois de `RefreshBasketState` ter zerado. | Todas as 124 linhas ao vivo. | Média |
| T4 | `RUN_CONFIG`/`CONFIG` (:738, :750) não gravam os inputs efetivos (lote, multiplicador, níveis, grade, TP/trailing em dinheiro, meta). Imprimem `InitialTP=200 \| BasketTP=250` mesmo com `TakeProfitUnit=MONEY`. Só o `ConfigHash` identifica a configuração, e ele não é reversível. Reconstruí a configuração real a partir do `.ini` do tester e dos lotes. | `RUN_CONFIG`. | Média |
| T5 | 66 linhas de deal duplicadas na IC (mesmo `Deal`, mesmo segundo, `SequenceNumber` +3), todas numa única execução (run de 05/10 06:03). Causa não determinada. | `DEALS_EXPORT`. | Baixa |
| T6 | Snapshot de risco duplicado: `OnTimer` (:912, evento `LIVE`) e `OnTick` (:1027, `LIVE_INTERVAL`) gravam o mesmo a cada 10 s enquanto há cesto. | Pares idênticos em `RISK_STATE`. | Baixa |
| T7 | Famílias vazias: `CALENDAR_STATE` e `BASKET_STATE` (0 linhas na IC). Notícia/spread só vão para `Print`, não para CSV. | Arquivos de 0 byte. | Baixa |
| T8 | Contexto de entrada perdido no reinício: 2 de 48 cestos com `EntryLiquidity=NONE, EntryScore=0` (`gLastSignal` não persiste). | `BASKET_SUMMARY`. | Baixa |
| T9 | `Combined` do CSV de barras é 0 sempre que algum filtro reprova (:2383), então não há "quase-sinal" para análise de limiar. | Código. | Baixa |
| T10 | Custo da telemetria: `TelemetryFile` (:4874) abre cada parte existente para medir o tamanho a cada linha (backtest chegou a 13 partes de `MARKET_STATE`), e cada linha abre/fecha/flush. Pode pesar no tester (os 5 backtests levaram 11 a 19 min para 3,6 M ticks). | Código; tempo dos testes. | Baixa |

### 5.3 Execução e gerenciamento

| # | Problema | Evidência | Gravidade |
|---|---|---|---|
| E1 | `POSITION_MODIFY_FAILED`: 43 na IC (30 × 10029 `frozen` + 8 × 10016 `invalid stops` em `TP_MONEY`; 5 em trailing). Log é limitado a 1 por 30 s, então o real é maior. Ocorre quando o preço está dentro do freeze level do TP. Sem consequência financeira vista (o TP antigo permanece), mas é ruído e tentativa repetida a cada tick. | Logs MQL5 IC. | Baixa |
| E2 | `UpdateStaticBasketTP` (:3348) refaz a **bisseção do TP em dinheiro a cada tick** (`SolveBasketTPMoney` :3505): dezenas de `OrderCalcProfit` por perna, limite de 100 × pernas, mesmo sem mudança de posição. O TP também "dança": 4136,10 → 4135,92 → 4135,96 em 3 s (diário do terminal). | Código + diário. | Baixa |
| E3 | Trailing consome o lucro: nas saídas únicas da IC o trailing rendeu **US$ 1,42** contra **US$ 4,21** do TP (34 %); 15 de 38 cestos de perna única. Não dá para dizer que é perda (evita reversão para a grade), mas é o maior custo de oportunidade mensurável e **não foi testado A/B**. | `BASKET_SUMMARY`. | Info |
| E4 | `ConfigHash` inclui inputs operacionais (meta diária, janelas). Qualquer ajuste durante um cesto aberto invalida o estado do trailing (`STATE_CONFIG_MISMATCH`, 11 vezes na IC). Há reconciliação, então é seguro, mas perde `TrailingFloor`/`Peak`. | `RISK_STATE`. | Baixa |

## 6. Melhorias recomendadas

Nada abaixo muda a lógica de entrada. Seguem as regras do projeto: SL continua desligado por padrão, cada proteção com `bool` próprio (nunca `0 = off`), grupos separados (Profit ≠ Risco ≠ Stops). **Preciso da sua decisão nos itens marcados.**

### Prioridade 1 — risco

1. **Grupo "PROTEÇÕES MONETÁRIAS" (decisão sua).** Três degraus independentes, cada um com seu `bool`:
   - **Alerta** por flutuante do cesto em % do equity (telemetria + painel + `SendNotification`). Não age.
   - **Bloqueio** de novas entradas L0 (e opcionalmente de novos níveis) quando o flutuante passa de X % ou o cesto passa de N horas. Não fecha nada.
   - **Encerramento** do cesto por dinheiro/% (`InpUseBasketLossClose`). **Desligado por padrão**, como o seu perfil pede, mas implementado e testado.
   Como calibrar: o replay de 17–22/09 do backtest e o episódio da FP em 25/09 são os dois casos reais. Pontos de partida para testar, não recomendações: alerta em 3 % do equity, bloqueio em 8 %, encerramento só se você optar.
2. **Validar no `OnInit`:** recusar (ou avisar alto) se `InitialLot × Σ multiplicador^k` truncado excede `InpMaxBasketVolume`. Quando o preflight falhar por `MAX_BASKET_VOLUME`/`MAX_RECOVERY_LEVEL`, marcar o cesto como "teto atingido" e **parar de tentar**, em vez de cair no cooldown de 60 s.
3. **`RISK_PROJECTION` útil:** usar os lotes reais truncados, aplicar o cap e imprimir *perda por US$ 1*, *por US$ 25* e *por US$ 100 de movimento* e % do equity.
4. **Religar ou remover o fallback de TP** (`MonitorTakeProfitMoney`). Se religar: chamar em `ManageOpenBasketTick`; logar a entrada em `gTPMoneyMonitorOnly` em :3410.

### Prioridade 2 — observabilidade

5. Chamar o diagnóstico de setup antes de gravar `NO_SETUP` (ou derivá-lo de `gSnap`), de modo que o painel e o `SIGNAL_FUNNEL` digam *qual* filtro falhou (tendência, liquidez, fluxo, confluência). Isso responde "por que não entrou" e permite medir o funil.
6. Filtrar `OnTradeTransaction` por `trans.symbol == _Symbol` e magic próprio (via `HistoryDealSelect` + `DEAL_MAGIC`), e só salvar estado quando for do EA.
7. Corrigir `Volume` no `BASKET_SUMMARY` (capturar antes do reset).
8. `RUN_CONFIG` com **todos** os inputs efetivos (uma linha por `ConfigHash`), mais `ProfitUnit` correto.
9. Persistir `gLastSignal` (contexto de entrada) no `state`.
10. Gravar `Combined` mesmo quando o filtro reprova (guardar `combRaw`) para análise de quase-sinais.

### Prioridade 3 — eficiência

11. Cachear parte/tamanho corrente em `TelemetryFile`; manter um único timer de snapshot de risco; popular ou remover `BASKET_STATE`/`CALENDAR_STATE`.
12. Cachear o resultado do solver de TP enquanto (pernas, volume, média) não mudar; não tentar `PositionModify` quando a distância ao TP estiver dentro do freeze level.
13. Separar `ConfigHash` em "estratégia" e "operacional" para não zerar o trailing ao mudar meta/janela.

## 7. Testes que ainda faltam

Ordem sugerida. Todos com custos reais (comissão e spread da conta usada), registrando corretora, símbolo, modelo, depósito, timezone e hash do código.

| ID | Teste | Pergunta que responde |
|---|---|---|
| E1 | **Janela fora da amostra.** Rodar 2026.01.10 → 08.23 com os mesmos inputs (a FP tem cache de 01.10–09.18, mas **não consegui decodificar os `.tst`**; exporte o relatório HTML). | O resultado de 24/08–28/09 sobrevive em outro regime? |
| E2 | Mesmo período em **IC e FP** e com `Model=4`. | O resultado depende da corretora? |
| E3 | **Trailing ligado × desligado**, tudo igual. | Os 34 % do TP que o trailing devolve compram proteção real? |
| E4 | Sensibilidade: níveis (3/4/5), multiplicador (1,3–2,0), grade ATR (2–3). Medir **pior DD, tempo submerso e dias de meta perdidos**, não lucro. | Há superfície suave ou só um ponto "bom"? |
| E5 | **Placebo:** mesma grade/TP/meta, mas entradas em horário aleatório alinhadas à tendência (e outra com direção invertida). | Quanto do resultado vem do sinal de liquidez+fluxo e quanto da mecânica de grade+TP? |
| E6 | **Replay de 17–22/09 com a proteção de R1** nos três degraus. | Quanto custa o degrau de encerramento versus esperar? |
| E7 | **Monte Carlo** reamostrando cestos (preservando clusters de dias). | Distribuição do pior flutuante e do tempo submerso. |
| E8 | Backtest com **calendário histórico** embutido (CSV de eventos USD de alto impacto). | Fecha a lacuna R5 entre tester e ao vivo. |

**Critérios de falsificação** (dizem quando a tese cai):
- Se E5 (placebo) tiver distribuição de pernas/tempo-até-TP indistinguível do EA, o sinal não tem edge; o que existe é a mecânica de grade.
- Se E1 mostrar prejuízo líquido ou DD > 2× o da amostra, a configuração está ajustada à janela.
- Se E4 só funcionar em um ponto isolado, é sobre-ajuste.

## 8. Limites desta análise

- **Amostra pequena.** 107 h (IC) + 168 h (FP) ao vivo e 5 semanas de backtest. Nada disso inclui um dia de tendência forte *contra* a grade além do de 17/09.
- **FP parou.** Último CSV da FP em 29/09; os logs do terminal FP a partir de 01/10 não têm `FluxMatrix`. O EA não roda mais lá (rodam outros). Não existem logs MQL5 da FP anteriores a 01/10.
- **Backtest ↔ `.ini`.** Associei o backtest de 10.931,76 ao `.ini` das 16:32 porque `TradingWindow`, `TrailMinDistance`, news guard, `MaxBasketVolume=0.30` e lote 0,02 batem com o `RUN_CONFIG`/riscos. Os outros 4 resultados do log não têm CSV preservado.
- **Soma dos cestos × saldo final:** 10.936,04 contra 10.931,76 (−4,28). Não identifiquei a causa (comissão ou posição aberta no fim).
- **Não decodifiquei** os `.tst` do cache do tester nem rodei compilação/backtest novos. Tudo aqui vem de arquivos já gerados.
- **Deals alheios:** a contagem "esperada 2 × pernas" foi validada no backtest (exata) e aplicada à IC; o mínimo certo de alheios (fora de janela) é 908.
- As 66 duplicatas de deal são observadas, não explicadas. Os 11 `STATE_CONFIG_MISMATCH` da IC são coerentes com as 10 configurações diferentes, mas não os cruzei um a um.
- Sem acesso ao painel gráfico: a afirmação de que ele mostra "INICIANDO" vem do código (`GetActivityStatus` :4547 devolve `gSetupHead`) e do `MARKET_STATE`, não de captura de tela.

## 9. Resumo para decisão

1. **Manter** o EA rodando como está é defensável para colher meta diária, mas o risco real é **a cauda sem proteção**. O cenário de −2.416 já apareceu em backtest com lote 0,02 e deposit US$ 10 mil.
2. **A correção de maior valor não mexe em entrada:** o grupo de proteções monetárias (R1) e a validação de níveis × volume (R2).
3. **A segunda de maior valor é diagnóstica:** religar o diagnóstico de setup (T1) e filtrar a telemetria de execução (T2). Sem isso, a análise de dados futura continua enviesada.
4. **Antes de aumentar lote ou ligar mais contas**, rodar E1, E3 e E5.

## 10. Adendo — backtest IC com ticks reais (`FluxmatricPro.html`, build v2.11, proteções desligadas)

Período 10/09 → 08/10 (M1, 100 % ticks reais, IC Raw, depósito US$ 5.000, 1:500). Inputs: lote 0,01, mult. 1,5, 3 níveis, grade FIXA 600, TP US$ 4/12, trailing em dinheiro, meta diária 20, `MaxBasketVolume` 0,22, janela 08–18 sem sexta.

| Medida | Valor |
|---|---|
| Lucro líquido | **+354,67 (+7,1 %)** |
| Cestos (reconstruídos dos deals) | 69, **69 ganhos**; 15 dias, todos entre 17 e 30 (meta = 20) |
| Rebaixamento do saldo | 9,75 (0,19 %) |
| **Rebaixamento do equity** | **412,17 (8,09 %)** |
| Fator de recuperação | 0,86 (o mês inteiro rende menos que o pior DD) |
| Cestos com 4 pernas (teto) | 9 de 69 (13 %) |
| Maior duração | **75 h 03 min** (17/09 08:30 → 22/09 11:33) |

**Leitura:**
1. **É o mesmo episódio de 17–22/09**, agora com ticks da IC: 5,1 dias preso, DD de equity de 412 com 0,04 lote. No teste da FP com 0,24 lote foram −2.416. A razão (≈ 6×) bate com a razão de lotes, o que confirma que o evento é do mercado, não da corretora.
2. **O gráfico de saldo é liso e esconde o risco:** DD de saldo 0,19 % contra 8,09 % de equity. Fator de lucro 5,62 e Sharpe 5,01 refletem a cauda ainda não realizada. Avalie o EA pelo DD de equity e pelo tempo submerso, não pela curva de saldo.
3. **Armadilha de configuração:** com lote 0,01 e mult. 1,5, `NormalizeVolume` trunca 0,015 para 0,01. **Todas as 224 ordens saíram com 0,01**: não há martingale nesse teste, é uma grade de lotes iguais. Multiplicador só funciona se o lote inicial for grande o bastante para o resultado não cair no mesmo step (ex.: 0,02 × 1,5 = 0,03). O `RISK_REAL` da v2.11 sinaliza essa diferença no log de inicialização.
4. **Trailing:** 31 dos 69 cestos (45 %) saíram por trailing. Perna única: TP rende 4,13 contra 1,82 do trailing (44 %), mesma ordem de grandeza dos 34 % medidos ao vivo. Continua sem A/B (E3).
5. **O teste não responde E1/E5:** é a mesma janela de setembro/outubro. Sobreposição de 09/10–24/09 com o backtest da FP, portanto não é amostra independente.
6. Com as proteções desligadas não há como comparar com a v2.10 neste arquivo (inputs diferentes dos anteriores).
