# Padrão de Telemetria

## Objetivo

Fazer o EA explicar o que está fazendo sem depender de interpretação visual.

## Princípios

1. Todo evento importante deve ser rastreável.
2. Motivo de bloqueio deve ser explícito.
3. Valores usados na decisão devem poder ser auditados.
4. Ordem aceita e ordem rejeitada são eventos diferentes.
5. Telemetria não pode alterar a lógica de trading.

## CSV CORE

Campos recomendados:

```
timestamp
server_time
symbol
timeframe
magic
ea_name
ea_version
event_id
event_type
severity
state
signal
decision
reason
bid
ask
spread_points
spread_money
equity
balance
daily_pnl
daily_target
daily_loss_limit
position_count
position_direction
position_volume
entry_price
stop_price
take_price
profit_money
risk_money
retcode
retcode_description
latency_ms
comment
```

## Eventos mínimos

### INIT

Registra:

- versão;
- símbolo;
- timeframe;
- magic;
- parâmetros críticos;
- permissões;
- especificação do ativo.

### MARKET_STATE

Estado calculado do mercado no momento relevante.

### SIGNAL

Condições do setup e direção.

### BLOCK

Entrada recusada pelo próprio EA.

O campo `reason` é obrigatório.

### ORDER_SEND

Tentativa de envio.

Registrar:

- direção;
- volume;
- preço;
- SL;
- TP;
- desvio;
- resultado.

### ORDER_REJECTED

Sempre registrar retcode e descrição.

Não assumir que `OrderSend` retornar sem erro implica execução concluída.

### POSITION_OPEN

Registrar preço e volume efetivos.

### POSITION_MODIFY

Registrar alteração de SL/TP e motivo.

### POSITION_CLOSE

Registrar:

- preço;
- lucro;
- comissão;
- swap;
- motivo;
- duração.

### RISK

Eventos de:

- limite diário;
- perda máxima;
- emergency;
- circuit breaker;
- kill switch;
- proteção de cesta.

### ERROR

Erro interno ou externo relevante.

## Razão de bloqueio

Exemplos:

```
NO_TREND
SPREAD_HIGH
DAILY_TARGET_REACHED
DAILY_LOSS_REACHED
SESSION_CLOSED
INVALIDATION
CHASE_TOO_FAR
RISK_TOO_HIGH
NO_MARGIN
SYMBOL_DISABLED
TRADING_NOT_ALLOWED
COOLDOWN
MAX_POSITIONS
```

Não registrar apenas `BLOCK`. Dizer por quê.

## Rotação

Quando a quantidade de eventos for grande:

- usar arquivos por EA e por período;
- evitar arquivo gigantesco;
- preservar cabeçalho;
- não apagar histórico sem política documentada.

## Schema

Mudanças de colunas devem ser tratadas como mudança de schema.

Se a análise automática depender do formato, versionar o schema.

## Diagnóstico

Um EA bem instrumentado deve permitir responder:

> Por que não entrou?

> Por que fechou?

> Por que o SL mudou?

> Qual era o risco no instante?

> Qual regra bloqueou?

> A corretora recusou ou o EA nem tentou?

## Separação

Não misturar indiscriminadamente:

- log humano detalhado;
- CSV analítico;
- resumo de trade;
- dados de alta frequência.

Cada um existe para uma pergunta diferente.
