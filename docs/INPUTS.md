# Padrão de Inputs (parâmetros de configuração)

Todo EA, indicador e script do LZ Trading organiza os parâmetros em **menus (setores) separados e numerados**, usando `input group` do MQL5. Cada setor tem uma única responsabilidade.

## Regra central

**Nunca misturar o setor de Profit/Alvo com o de Gestão de Risco.** Cada um tem seu próprio menu, com seus próprios inputs, sem compartilhar parâmetros.

- Gestão de Risco: lote, risco por operação, stop (desativado), limites de perda, circuit breaker, exposição, margem.
- Profit/Alvo: take profit, meta diária, parcial, trailing de lucro, break-even, saída por tempo.

Um input pertence a exatamente um setor. Se uma regra depende de dois setores, cada lado fica no seu menu e a ligação é feita no código, nunca no agrupamento.

## Ordem padrão dos setores

| # | Setor | Conteúdo |
|---|-------|----------|
| 01 | Identificação | nome, versão, magic, comentário das ordens |
| 02 | Símbolo e Timeframe | símbolo de execução, timeframe, candle fechado/ativo |
| 03 | Estratégia / Sinal | regras de entrada específicas da tese |
| 04 | Filtros | spread, volatilidade, tendência, regime |
| 05 | Horários e Sessões | janelas de operação, fuso do servidor, dias da semana |
| 06 | Execução | desvio, filling, tentativas, tipo de ordem |
| 07 | Gestão de Risco | lote, risco monetário, limites de perda, circuit breaker, margem |
| 08 | Stop Loss | **desativado por padrão** (`InpUseStopLoss=false`), tipo e distância |
| 09 | Profit / Alvo | take profit, meta diária, parciais, saída por tempo |
| 10 | Gerenciamento de Posição | trailing, break-even, gerenciamento da posição aberta |
| 11 | Limites Diários | perda/ganho máximo do dia, nº máximo de trades |
| 12 | Painel | exibição, posição, minimizar, cores |
| 13 | Telemetria / CSV / Logs | níveis de log, CSV, eventos |
| 14 | Avançado / Diagnóstico | debug, modo teste, flags experimentais |

Setores sem uso no EA são omitidos, mas a numeração relativa e a ordem são preservadas.

## Sintaxe

```mql5
input group "══════ 07 | GESTÃO DE RISCO ══════"
input double InpRiskMoneyPerTrade = 10.0;   // Risco monetário por operação (moeda da conta)
input double InpLotFixed          = 0.01;   // Lote fixo
input double InpMaxDailyLossMoney = 50.0;   // Perda diária máxima (moeda)

input group "══════ 08 | STOP LOSS (desativado) ══════"
input bool   InpUseStopLoss       = false;  // Usar Stop Loss
input double InpStopLossMoney     = 20.0;   // Stop em dinheiro (se ativado)

input group "══════ 09 | PROFIT / ALVO ══════"
input bool   InpUseTakeProfit     = true;   // Usar Take Profit
input double InpTakeProfitMoney   = 15.0;   // Alvo em dinheiro
input double InpDailyProfitGoal   = 100.0;  // Meta diária (moeda)
```

## Convenções

1. Prefixo `Inp` e nome em inglês ou português consistente com o EA.
2. Todo input tem comentário descritivo com a unidade (moeda, pontos, %, segundos, barras).
3. Grupo com título numerado e em maiúsculas, conforme a tabela.
4. Valores monetários em moeda da conta (ver Money-first no `CLAUDE.md`).
5. Dentro de um setor, ordenar: chave liga/desliga primeiro, depois valores, depois opções avançadas.
6. Parâmetros dependentes de uma chave ficam logo abaixo dela.
7. Não renomear inputs existentes sem necessidade (preserva presets `.set`).
8. O log INIT imprime os parâmetros efetivos agrupados pelos mesmos setores.
9. O painel e o CSV podem refletir os setores, mas não alteram o agrupamento dos inputs.

## Checklist antes de entregar

- [ ] Todo input está dentro de um `input group`.
- [ ] Nenhum input de Profit está no grupo de Risco, nem o inverso.
- [ ] Stop Loss existe e está desativado por padrão.
- [ ] Setores seguem a ordem da tabela.
- [ ] Todo input tem comentário com unidade.
- [ ] Parâmetros efetivos são impressos no INIT.
