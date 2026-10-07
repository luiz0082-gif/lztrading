# LZ Trading — Instruções do Projeto

## Missão

Este repositório é um laboratório de engenharia quantitativa e desenvolvimento MQL5 para criar, auditar, testar e analisar EAs, indicadores, scripts e estratégias.

O objetivo não é produzir código apenas porque compila. O objetivo é produzir sistemas:

- objetivos;
- auditáveis;
- observáveis;
- reproduzíveis;
- resistentes a erros de execução;
- honestamente validados;
- fáceis de evoluir sem destruir a lógica anterior.

## Perfil do operador (obrigatório)

O operador **NÃO opera com Stop Loss**. Ao criar ou modificar qualquer EA, estratégia ou indicador:

- manter o parâmetro de Stop Loss **configurado e implementado, porém DESATIVADO por padrão** (`InpUseStopLoss = false`, ou equivalente);
- nunca ativar SL por padrão nem como "melhoria" sem pedido explícito;
- a ausência de SL **não** elimina o controle de risco: usar limites monetários, limite diário, circuit breaker, tamanho de lote conservador e telemetria de exposição aberta;
- indicadores e estratégias devem ser desenhados assumindo saída por alvo, gerenciamento, tempo ou invalidação lógica — não por stop fixo;
- documentar no EA e na estratégia o risco real de operar sem SL (exposição aberta, gap, margem), sem esconder o risco;
- a invalidação da tese continua obrigatória (ver "Invalidação antes de entrada"); apenas não é executada por ordem de stop.

## Áreas cobertas

- Expert Advisors;
- indicadores;
- scripts;
- price action;
- estratégias com indicadores;
- estratégias sem indicadores;
- estrutura e fluxo;
- gestão de risco;
- trailing e gerenciamento de posição;
- painéis;
- logs;
- CSV;
- backtests;
- análise estatística e de robustez.

## Regras de engenharia

### Código completo

Quando for solicitado um EA, indicador ou script, entregar o arquivo MQL5 completo e compilável, salvo quando a tarefa for explicitamente apenas análise.

Não usar:

- pseudocódigo disfarçado de código;
- funções vazias;
- placeholders;
- dependências ocultas;
- módulos que o usuário não recebeu;
- nomes de funções inexistentes;
- variáveis declaradas em arquivos ausentes.

Toda dependência criada deve ser entregue e documentada.

### MQL5 real

Respeitar a API real do MQL5. Não importar sintaxe ou convenções do MQL4 sem verificar compatibilidade.

Normalizar preço por tick size quando necessário e volume pelas regras reais do símbolo.

Tratar corretamente:

- `SYMBOL_POINT`;
- `SYMBOL_TRADE_TICK_SIZE`;
- `SYMBOL_TRADE_STOPS_LEVEL`;
- `SYMBOL_VOLUME_MIN`;
- `SYMBOL_VOLUME_MAX`;
- `SYMBOL_VOLUME_STEP`;
- spread;
- filling;
- retcodes de negociação;
- margem;
- modo de negociação do símbolo.

### Timeframe e símbolo

Por padrão, um EA usa um timeframe escolhido e explícito.

Não criar MTF, multisímbolo ou multiinstância implícita sem especificação.

Quando o projeto exigir multissímbolo, documentar claramente:

- símbolo de execução;
- símbolos analisados;
- sincronização de dados;
- origem dos ticks;
- magic;
- risco agregado.

Uma instância deve deixar claro qual é sua unidade econômica de risco.

### Dados e candle

Por padrão, sinais devem ser calculados com candle fechado quando isso fizer sentido para a estratégia.

Uso de candle ativo, tick a tick ou eventos intrabar deve ser uma decisão explícita, documentada e testável.

Evitar look-ahead, acesso acidental a dados futuros ou uso de informação que não estaria disponível no instante da decisão.

### Risco

Separar conceitualmente:

- entrada/sinal;
- risco estrutural;
- risco monetário;
- stop real;
- stop virtual;
- emergência;
- alvo/profit;
- trailing;
- limite diário;
- circuit breaker.

Nunca assumir que um stop virtual protege uma posição se o terminal/VPS perder conexão.

Nenhum EA deve receber martingale, recovery, multiplicação de lote ou piramidagem como comportamento implícito. Só entram mediante decisão explícita do projeto.

### Money-first

Quando houver metas ou limites monetários, registrar valores em dinheiro com precisão adequada ao ambiente. Não esconder risco em número de pontos quando a decisão operacional for monetária.

### Invalidação antes de entrada

Sempre que aplicável, definir primeiro:

- o que precisa ser verdadeiro;
- o que invalida a tese;
- quando a entrada deixa de ser válida;
- quando não perseguir preço.

O EA não deve entrar só porque um conjunto de condições ficou verdadeiro se a estrutura que justificava a entrada já foi invalidada.

## Estratégia

Separar hipótese de fato.

Toda nova estratégia deve distinguir:

- tese;
- mecanismo esperado;
- observação;
- regra operacional;
- parâmetros;
- custos;
- risco;
- hipóteses não verificadas;
- critérios de falsificação.

Nunca transformar uma correlação observada em causalidade sem evidência.

Nunca afirmar que uma estratégia é lucrativa sem backtest ou evidência correspondente.

## Otimização e overfitting

Otimização não é prova de edge.

Evitar:

- otimização excessiva;
- dezenas de filtros adicionados após olhar o resultado;
- ajuste específico para uma janela curta;
- escolha do melhor parâmetro entre milhares sem teste fora da amostra;
- cherry-picking de períodos.

Preferir:

- out-of-sample;
- walk-forward quando fizer sentido;
- testes por regime;
- análise de sensibilidade;
- superfícies de parâmetros suaves;
- placebo/inversão;
- custos realistas.

## Backtest

Não aceitar como evidência suficiente:

- spread fixo irreal;
- comissão zerada quando há comissão real;
- modelagem que não represente a execução;
- período pequeno;
- apenas um ativo sem justificativa;
- apenas o melhor período;
- resultado sem drawdown e custos.

Registrar sempre:

- corretora;
- símbolo;
- especificação do contrato;
- timeframe;
- período;
- modo de modelagem;
- spread;
- comissão;
- slippage/desvio;
- depósito inicial;
- moeda;
- timezone do servidor;
- parâmetros;
- versão/hash do código.

## Telemetria obrigatória

EA de produção deve possuir observabilidade proporcional à complexidade.

No mínimo, registrar:

- INIT;
- parâmetros efetivos;
- estado do mercado;
- decisão de sinal;
- bloqueios e motivos;
- ordem enviada;
- retcode;
- abertura;
- modificação;
- fechamento;
- risco;
- lucro;
- limites diários;
- erros;
- estado do gerenciamento de posição.

Ver `docs/TELEMETRIA.md`.

## CSV

Separar:

1. CSV CORE — campos comuns a todos os sistemas;
2. CSV específico — variáveis próprias da estratégia;
3. CSV de eventos, quando a densidade do log justificar;
4. arquivo de resumo por operação/período, quando útil.

Cabeçalho deve ser estável. Mudanças incompatíveis exigem versão do schema.

Nunca registrar senhas, tokens ou credenciais.

## Painel

O painel deve ser operacional, não apenas decorativo.

Prioridades:

1. estado atual;
2. risco;
3. posição;
4. sinal;
5. motivo de bloqueio;
6. meta/perda;
7. telemetria.

O usuário deve conseguir descobrir rapidamente por que o EA está operando ou não está operando.

Ver `docs/PAINEL.md`.

## Análise de logs e CSV

Nunca interpretar um CSV apenas pela aparência.

Primeiro:

1. identificar cabeçalho e schema;
2. confirmar timezone;
3. identificar duplicatas;
4. verificar linhas incompletas;
5. contar eventos;
6. separar trades e eventos;
7. validar tipos numéricos;
8. procurar gaps;
9. depois analisar desempenho.

Ao encontrar uma anomalia, distinguir:

- bug;
- comportamento esperado;
- dado inválido;
- execução ruim;
- característica da estratégia.

## Mudança em EA existente

Antes de modificar:

1. ler o código inteiro quando necessário;
2. entender inputs;
3. entender fluxo de entrada;
4. entender gerenciamento;
5. entender telemetria;
6. identificar estado persistente;
7. identificar dependências;
8. preservar o comportamento não solicitado.

Não reescrever um EA inteiro para resolver um problema localizado.

## Presets

Preset não é código.

Quando o usuário pedir preset, modificar parâmetros e não a lógica do EA, salvo solicitação explícita.

Ao propor preset, explicar:

- objetivo;
- risco;
- condições de operação;
- trade-offs;
- parâmetros críticos.

## Naming e versões

Manter o nome definido pelo projeto.

Não renomear EA, inputs, arquivos ou magic sem necessidade.

Quando existir versão formal, atualizar de forma consistente e registrar a mudança.

## Segurança operacional

Nenhuma alteração deve:

- esconder erro de ordem;
- ignorar retcode;
- remover limite de perda sem autorização;
- desligar proteções silenciosamente;
- apagar telemetria existente;
- fazer o EA continuar operando após falha crítica sem decisão explícita.

## Validação final

Antes de declarar terminado:

- compilar;
- revisar warnings;
- executar testes disponíveis;
- conferir logs;
- verificar dependências;
- revisar inputs;
- revisar risco;
- registrar o que não pôde ser testado.

Não afirmar que compilou ou backtestou se isso não foi realmente executado.

## Documentação

Estratégias importantes devem ter documentação própria.

Mudanças arquiteturais devem atualizar os MDs correspondentes.

O documento não substitui o código, e o código não substitui o registro da hipótese.
