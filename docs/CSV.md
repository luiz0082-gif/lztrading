# Padrão CSV LZ Trading

## Objetivo

Definir um padrão único para geração, versionamento, rotação, leitura e análise de CSVs de EAs, indicadores, scripts e analisadores.

O padrão precisa permitir que um CSV gerado hoje continue sendo analisável meses depois, inclusive por outro agente de IA.

---

# 1. Princípios

1. Uma linha precisa ter significado claro.
2. Cabeçalho é contrato.
3. Schema deve ser versionado.
4. CORE é estável.
5. Campos específicos ficam separados dos campos comuns.
6. Nunca depender da aparência do arquivo para interpretar seus dados.
7. O CSV observa o sistema; não altera sua lógica.
8. Toda gravação relevante deve ser tolerante a reinício do MT5.
9. Nunca apagar histórico automaticamente sem política definida.
10. Nunca armazenar segredos, senhas, tokens ou credenciais.

# 2. Tipos de CSV

## EVENTS

Uma linha por evento importante.

Nome:

    <EA>_events_<YYYY-MM>.csv

Eventos:

    INIT
    DEINIT
    HEARTBEAT
    MARKET_STATE
    SIGNAL
    BLOCK
    ORDER_SEND
    ORDER_REJECTED
    ORDER_PLACED
    POSITION_OPEN
    POSITION_MODIFY
    POSITION_CLOSE
    RISK
    ERROR
    WARNING
    SESSION_OPEN
    SESSION_CLOSE
    DAY_RESET
    KILL_SWITCH

## TRADES

Uma linha por operação concluída.

Nome:

    <EA>_trades_<YYYY-MM>.csv

Uma operação não deve virar várias linhas neste arquivo.

## DECISIONS

Uma linha por oportunidade avaliada.

Nome:

    <EA>_decisions_<YYYY-MM>.csv

Serve para comparar sinais, bloqueios e entradas executadas.

## MARKET

Snapshots de mercado.

Nome:

    <EA>_market_<YYYY-MM-DD>.csv

Não gerar uma linha por tick por padrão. Alta frequência só quando houver objetivo analítico explícito.

# 3. CSV CORE

O CORE deve ser comum entre EAs.

## Identidade

    schema_version
    timestamp_utc
    server_time
    local_time
    ea_name
    ea_version
    symbol
    timeframe
    magic
    instance_id
    account_currency
    broker

Nunca gravar credenciais.

## Evento

    event_id
    event_type
    severity
    state
    substate
    signal
    decision
    reason_code
    reason_detail

## Mercado

    bid
    ask
    spread_price
    spread_points
    spread_ticks
    tick_size
    point_size
    digits
    tick_volume
    real_volume
    bar_time
    bar_open
    bar_high
    bar_low
    bar_close

## Conta

    balance
    equity
    free_margin
    margin
    margin_level
    daily_start_balance
    daily_start_equity
    daily_pnl
    daily_target
    daily_loss_limit
    drawdown_money
    drawdown_percent
    peak_equity

## Posição

    position_count
    position_direction
    position_volume
    position_price
    position_sl
    position_tp
    position_profit
    position_swap
    position_commission
    position_risk_money
    position_risk_points

## Execução

    request_price
    execution_price
    requested_volume
    executed_volume
    deviation_points
    slippage_points
    retcode
    retcode_description
    order_id
    deal_id
    position_id
    latency_ms

## Sistema

    uptime_sec
    heartbeat_seq
    terminal_connected
    algo_trading_allowed
    ea_trading_allowed
    account_trading_allowed
    symbol_trading_allowed
    data_ready

## Texto

    comment

# 4. TRADES CORE

O CSV de trades deve possuir pelo menos:

    schema_version
    trade_id
    ea_name
    ea_version
    symbol
    timeframe
    magic
    direction
    entry_time
    exit_time
    duration_sec
    volume
    entry_price
    exit_price
    initial_sl
    initial_tp
    final_sl
    final_tp
    gross_profit
    commission
    swap
    net_profit
    risk_money
    planned_rr
    realized_r
    mfe_price
    mae_price
    mfe_money
    mae_money
    exit_reason
    setup
    signal
    regime
    session
    day_of_week

Exit reasons estáveis:

    TP
    SL
    TRAIL
    BREAKEVEN
    TIME_EXIT
    DAILY_TARGET
    DAILY_LOSS
    EMERGENCY
    KILL_SWITCH
    MANUAL
    SESSION_CLOSE
    SIGNAL_EXIT
    UNKNOWN

# 5. DECISIONS CORE

Uma linha por oportunidade avaliada:

    schema_version
    decision_id
    timestamp_utc
    server_time
    ea_name
    ea_version
    symbol
    timeframe
    magic
    state
    setup
    signal
    direction
    trigger_price
    market_price
    invalid_price
    distance_to_trigger
    distance_to_invalidation
    risk_money
    risk_structure
    spread_points
    decision
    reason_code
    reason_detail
    order_sent
    trade_id

# 6. CAMPOS ESPECÍFICOS DO EA

Campos próprios da estratégia não devem entrar no CORE apenas porque um EA usa a variável.

Exemplos:

    strategy_adx
    strategy_atr
    breakout_distance
    trend_score
    structure_score

ou:

    pa_scale
    micro_scale
    swing_high
    swing_low
    impulse_score
    pullback_score
    recency_score
    risk_structure_norm

O README do EA deve explicar significado, unidade e condição de preenchimento.

# 7. TIPAGEM

## Datas

Padrão textual:

    YYYY-MM-DD HH:MM:SS

Timezone precisa ser conhecido.

## Booleanos

Usar somente:

    true
    false

## Enumerações

Usar códigos estáveis:

    BUY
    SELL
    BLOCK
    PASS
    TP
    SL

## Números

Não colocar moeda, símbolo ou texto na célula.

Correto:

    12.40

Incorreto:

    $12.40

## Ausência

Campo vazio = valor ausente/desconhecido.

Não usar 0 para representar desconhecido.

# 8. UNIDADES

Todo número precisa possuir unidade conhecida.

Exemplos:

    spread_points
    risk_points
    duration_sec
    latency_ms
    profit_money
    volume
    price

Evitar nomes vagos como:

    distance
    size
    value
    risk

quando a unidade não for inequívoca.

# 9. DELIMITADOR

Padrão do projeto:

    ;

Um mesmo tipo de CSV deve manter o mesmo delimitador.

Campos com delimitador, aspas ou caracteres especiais devem seguir escaping CSV correto.

Não inserir quebras de linha em campos analíticos.

O cabeçalho é sempre a primeira linha.

# 10. NOME DOS ARQUIVOS

Padrão:

    <EA>_<tipo>_<periodo>.csv

Exemplos:

    PieceTrend_events_2026-10.csv
    PieceTrend_trades_2026-10.csv
    PieceTrend_decisions_2026-10.csv
    MarketBehaviorAnalyzer_market_2026-10-05.csv

Evitar:

    dados.csv
    resultado.csv
    teste-final.csv
    novo.csv

# 11. DIRETÓRIOS

Quando possível:

    MQL5/Files/LZTrading/
        <EA>/
            events/
            trades/
            decisions/
            market/
            reports/

Não espalhar CSV de uma mesma estratégia sem necessidade.

# 12. APPEND

O padrão é append.

Ao reiniciar o MT5:

- continuar o arquivo do período atual;
- verificar se o cabeçalho já existe;
- não escrever cabeçalho duplicado;
- preservar os IDs;
- continuar a gravação sem apagar linhas anteriores.

# 13. IDENTIFICADORES

Cada evento deve possuir event_id único dentro da instância.

Cada decisão:

    decision_id

Cada trade:

    trade_id

Quando fornecidos pelo MT5, registrar também:

    order_id
    deal_id
    position_id

Timestamp sozinho não é identificador suficiente.

# 14. ORDEM DAS COLUNAS

A ordem do cabeçalho é contrato.

Não reorganizar colunas apenas por conveniência.

Campos novos devem, preferencialmente, entrar ao final do bloco específico.

# 15. VERSIONAMENTO DO SCHEMA

Exemplo:

    1.0

Mudança compatível:

    1.0 -> 1.1

Mudança incompatível:

    1.x -> 2.0

Incompatível:

- remover coluna;
- mudar significado;
- mudar unidade;
- mudar enum;
- mudar tipo;
- reutilizar coluna para outra finalidade.

Nunca alterar significado mantendo o mesmo schema.

# 16. CABEÇALHO

Exemplo de CORE:

    schema_version;timestamp_utc;server_time;ea_name;ea_version;symbol;timeframe;magic;event_id;event_type;severity;state;signal;decision;reason_code;reason_detail;bid;ask;spread_points;equity;daily_pnl;position_count;position_profit;retcode;retcode_description

Cada linha precisa respeitar exatamente o contrato desse arquivo.

# 17. ROTAÇÃO

Padrão recomendado:

- EVENTS: mensal;
- TRADES: mensal;
- DECISIONS: mensal;
- MARKET: diário ou por volume.

Se um arquivo atingir tamanho operacional alto antes do período normal, pode ser rotacionado.

Rotação nunca pode apagar ou duplicar dados.

# 18. CONCORRÊNCIA

Se várias instâncias puderem escrever:

- preferir arquivo exclusivo por instância/magic;
- ou implementar controle explícito de concorrência.

Não assumir que múltiplos escritores estão seguros.

# 19. PERFORMANCE

Telemetria não pode degradar o EA.

Evitar:

- abrir/fechar arquivo a cada tick;
- serialização pesada;
- Print excessivo;
- cálculos de análise dentro da gravação;
- dados de mercado desnecessários.

Preferir:

- eventos relevantes;
- candle fechado;
- amostragem;
- bufferização quando segura.

Eventos críticos não devem ser descartados silenciosamente.

# 20. LOG HUMANO VS CSV

## Log humano

Para:

- diagnóstico rápido;
- MetaTrader Experts;
- acompanhar erros.

## EVENTS CSV

Para:

- auditoria;
- análise estruturada;
- reconstrução temporal.

## TRADES CSV

Para:

- estatística;
- comparação entre backtests;
- live vs tester.

## MARKET CSV

Para:

- pesquisa de mercado;
- microestrutura;
- estudo de contexto.

Não misturar os quatro sem motivo.

# 21. BLOQUEIOS

Todo bloqueio deve possuir:

    decision=BLOCK
    reason_code=<codigo>
    reason_detail=<explicacao>

Exemplo:

    BLOCK;SPREAD_HIGH;spread 42 points > max 30

Nunca registrar apenas BLOCK.

Códigos recomendados:

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
    DATA_NOT_READY
    NEWS_BLOCK
    BROKER_REJECT

# 22. ORDENS

Fluxo esperado:

    SIGNAL
    -> ORDER_SEND
    -> ORDER_PLACED / ORDER_REJECTED
    -> POSITION_OPEN
    -> POSITION_MODIFY
    -> POSITION_CLOSE

Se o fluxo parar em uma etapa, a telemetria precisa permitir descobrir onde.

# 23. RISCO

Quando relevante, registrar:

- risco planejado;
- risco estrutural;
- risco monetário;
- exposição;
- perda diária;
- meta diária;
- drawdown;
- limite de cesta.

Não inferir risco somente pelo lote quando o EA possui cálculo monetário próprio.

# 24. TRAILING

Quando existir trailing, registrar no evento de modificação:

    trail_mode
    trail_active
    activation_profit
    distance_target
    distance_actual
    old_sl
    new_sl
    profit_at_modify
    reason_code

Isso permite descobrir:

- se ativou;
- por que não modificou;
- se a corretora recusou;
- se a posição fechou antes da atualização.

# 25. ERROS

Erro relevante:

    event_type=ERROR
    severity=ERROR
    reason_code
    reason_detail
    retcode
    retcode_description

Não substituir erro técnico por mensagem genérica.

# 26. INTEGRIDADE

A análise precisa detectar:

    cabeçalho inválido
    schema incompatível
    coluna ausente
    coluna extra
    linha quebrada
    data inválida
    número inválido
    ID duplicado
    timestamp fora de ordem
    POSITION_CLOSE sem POSITION_OPEN
    ORDER_REJECTED sem ORDER_SEND
    exit_time < entry_time
    volume <= 0
    spread < 0

# 27. RECONSTRUÇÃO DE TRADE

O conjunto de CSVs deve permitir reconstruir:

    mercado
    -> sinal
    -> decisão
    -> ordem
    -> execução
    -> posição
    -> gerenciamento
    -> saída
    -> resultado

Se isso não for possível, a observabilidade está incompleta.

# 28. ANÁLISE AUTOMÁTICA

A ferramenta de análise deve começar por:

    1. descobrir arquivos
    2. identificar schema
    3. validar integridade
    4. normalizar tipos
    5. reconstruir trades
    6. resumir eventos
    7. analisar performance
    8. procurar anomalias
    9. gerar hipóteses

Nunca começar pela explicação do problema antes de validar os dados.

# 29. COMPATIBILIDADE COM IA

Todo CSV importante deve estar documentado.

No mínimo:

    <EA>/README.md
    docs/TELEMETRIA.md
    docs/CSV.md

Para cada campo específico:

- nome;
- tipo;
- unidade;
- origem;
- frequência;
- condição de preenchimento;
- relacionamento com outros campos.

# 30. CHECKLIST

Antes de considerar o CSV pronto:

    [ ] schema_version
    [ ] cabeçalho estável
    [ ] CORE definido
    [ ] campos específicos definidos
    [ ] unidades documentadas
    [ ] enums documentados
    [ ] IDs únicos
    [ ] append seguro
    [ ] rotação definida
    [ ] concorrência avaliada
    [ ] performance avaliada
    [ ] eventos de ordem
    [ ] eventos de posição
    [ ] eventos de risco
    [ ] bloqueios com reason_code
    [ ] erros com retcode
    [ ] CSV de trades
    [ ] CSV de decisões quando necessário
    [ ] integridade analisável
    [ ] documentação atualizada

# 31. Regra final

O CSV não é um log mais bonito.

Ele é a interface de dados do EA com o mundo externo.

Se uma decisão importante não pode ser reconstruída pelo CSV, a observabilidade do EA está incompleta.
