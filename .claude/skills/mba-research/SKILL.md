---
name: mba-research
description: Use whenever a request involves the MarketBehaviorAnalyzer (MBA), its EA/core/history collector, MBA CSVs or reports, auditing capture quality, discovering or validating market-behavior patterns, repeated movements, exact clock times, minute-of-hour, point-distance thresholds, BUY/SELL excursions, MFE/MAE, forward horizons, symbol/feed comparisons, or other quantitative research on MBA data. Prefer this skill over generic data-analysis for any MBA-specific investigation, even when the request is informal.
---

# MBA Research — protocolo profissional de análise quantitativa

## 1. Missão e regra de acionamento

Use esta skill para investigar dados do MarketBehaviorAnalyzer, validar sua qualidade, descobrir padrões de repetição e produzir relatórios quantitativos reproduzíveis.

O objetivo é analisar o mercado observado, não confirmar uma hipótese prévia. Pesquise o universo completo definido pelo pedido, inclusive resultados negativos e horários sem evidência suficiente. Não pare na primeira descoberta interessante.

Ative esta skill quando a solicitação mencionar o MBA, MarketBehaviorAnalyzer, arquivos de captura do MBA, comportamento histórico de ativos, repetição por horário, movimentos por pontos, direção BUY/SELL ou uso dos dados do MBA para formular estratégias.

Antes de iniciar:
- Leia docs/MBA.md para compreender a versão, as chaves, a semântica dos campos e as limitações documentadas.
- Leia docs/CSV.md para regras de schema, rotação, compatibilidade e ingestão.
- Leia docs/ANALISE-DADOS.md para os controles gerais de qualidade e relatório.
- Inspecione o código-fonte EA/Core/History quando a pergunta depender de como uma variável foi capturada ou calculada.
- Use mql5-engineering em conjunto quando for necessário alterar ou depurar a implementação MQL5. Use strategy-lab em conjunto quando a tarefa passar de descoberta estatística para formalização e validação de uma estratégia.
- Para análise exclusivamente de telemetria de outros EAs, sem relação com o MBA, use data-analysis.

## 2. Restrições inegociáveis

1. Não invente dados, colunas, horários, conversões, amostras, resultados ou disponibilidade de fontes.
2. Não diga que executou código, compilou, consultou todos os arquivos ou validou uma hipótese se isso não aconteceu.
3. Diferencie fatos observados, inferências estatísticas e hipóteses explicativas.
4. Preserve arquivos de origem. Não edite, apague, deduplique ou sobrescreva os originais. Trabalhe em cópias ou bases derivadas identificadas.
5. Não interprete uma lacuna como ausência de movimento antes de verificar a cobertura de dados daquele intervalo.
6. Não misture schemas incompatíveis, símbolos distintos, corretoras distintas, contratos diferentes, feeds ou fontes de captura sem identificá-los.
7. Não transforme correlação em causalidade. Não chame um padrão de vantagem operacional somente porque a taxa de alcance histórica parece alta.
8. Se um campo essencial estiver ausente, apresente a limitação, calcule apenas o que é sustentado pelos dados e especifique o que falta para concluir.
9. Não esconda achados negativos, falhas de integridade ou resultados que contradigam a hipótese inicial.
10. Nunca prometa ausência absoluta de falhas. Execute controles de consistência e reporte o que foi validado e o que permaneceu sem verificação.

## 3. Inventário e auditoria antes de analisar

Primeiro inventarie os arquivos disponíveis e confirme sua origem. Para cada conjunto, registre:
- caminho e nome do arquivo;
- tipo de dado e finalidade;
- corretora, servidor, símbolo e timeframe, quando existirem;
- data inicial e final;
- versão do schema e cabeçalhos;
- número de linhas, chaves únicas e duplicatas;
- timestamps nulos, inválidos, fora de ordem ou repetidos;
- lacunas temporais e períodos com cobertura insuficiente;
- campos numéricos que não podem ser interpretados;
- origem declarada, como LIVE, BACKFILL_SERVER, HISTORY, CALENDAR ou CALENDAR_BACKFILL;
- limitações conhecidas de captura, sincronização e disponibilidade histórica.

Não concatene arquivos rotativos cegamente. Verifique o cabeçalho de cada parte e trate separadamente versões de schema incompatíveis. Respeite as regras de identidade documentadas em docs/MBA.md. Confirme as chaves efetivamente presentes no arquivo antes de aplicar deduplicação.

Para séries temporais, produza uma medida explícita de cobertura: períodos esperados, períodos presentes, gaps, duplicações e intervalos impossíveis de avaliar. Quando a frequência esperada depender do calendário de negociação, feriados, sessões ou estado do feed, não conte esses períodos automaticamente como falhas.

Faça a auditoria de cobertura antes de atribuir um padrão a um horário. Horários com menos dados disponíveis não podem ser comparados como se tivessem o mesmo número de oportunidades.

## 4. Relógio, timezone e horários exatos

Preserve o timestamp original e identifique o fuso de cada registro. Use os campos de offset por registro quando existirem; nunca imponha um UTC offset fixo a todo o histórico sem comprovar que ele vale para o período inteiro.

Quando for possível, mostre:
- horário original do servidor;
- timestamp normalizado em UTC;
- horário local brasileiro somente quando isso for relevante e a conversão estiver fundamentada;
- regra usada para a conversão e limitações históricas.

Não confunda duas perguntas diferentes:

- HORÁRIO EXATO DO DIA: por exemplo, 02:00, 02:01, 02:02. Cada slot HH:MM corresponde a uma observação elegível por data e por regra de referência, não uma observação por hora.
- MINUTO DA HORA: por exemplo, todos os minutos terminados em :00 ou :13. Esse agrupamento pode conter várias observações por dia.

Use o campo indicado pelo schema, como slot_hhmm ou minute, somente depois de verificar sua semântica e seu timezone na versão de dados analisada.

Quando o pedido for uma varredura intradiária, analise o universo completo de horários elegíveis dentro do período disponível, e não apenas os horários que pareceram interessantes. Se apresentar um ranking resumido, disponibilize também a tabela completa ou o arquivo com todos os slots testados. Separe horário exato, sessão, dia da semana, mês e outros agrupamentos.

## 5. Unidade de pontos e comparação entre instrumentos

Antes de calcular distâncias, descubra e documente a unidade realmente usada pelo schema. Não presuma que ponto, pip, tick de preço, _Point e tick size sejam equivalentes.

Verifique, quando disponíveis:
- símbolo exato e especificação do contrato;
- _Point e SYMBOL_POINT;
- SYMBOL_TRADE_TICK_SIZE;
- valor do tick e moeda de lucro;
- número de casas decimais;
- volume mínimo, máximo, step e convenções específicas do contrato;
- a definição usada pelo MBA para campos como future_return_points, mfe_points e mae_points.

Use uma unidade canônica por análise e registre a conversão aplicada. Quando houver ambiguidade, mostre também a distância de preço bruta e não invente equivalências.

Separar obrigatoriamente:
A. Comportamento do preço: pontos, ticks, distância relativa, frequência e trajetória.
B. Resultado financeiro hipotético: volume ou número de contratos, valor de tick, conversão de moeda, spread, comissão e demais custos.

Operar com 1 contrato ou 10 contratos não muda a distância que o preço percorreu. Mude o cálculo financeiro conforme as especificações reais, mas mantenha o estudo de alcance do preço separado. Não compare diretamente pontos absolutos de ativos com convenções distintas sem normalizar e documentar a escala.

## 6. Definição de ocorrência e prevenção de look-ahead

Antes dos cálculos, defina a unidade de observação:
- ativo, feed, corretora e timeframe;
- evento ou ponto de referência;
- preço de referência;
- informação que era conhecida naquele instante;
- direção investigada;
- horizonte de observação e critério de encerramento;
- limiar de alcance;
- condição de sucesso e, se houver, limite adverso.

Distinga contexto anterior ao evento, características do próprio candle e resultados futuros. Siga a separação documentada em docs/MBA.md. Não use estrutura, máxima/mínima, fechamento, volume ou outra característica futura do evento como se fosse conhecida antes da entrada.

Não misture referências diferentes. Abertura do candle, fechamento de candle já concluído e rompimento intrabar são experimentos distintos. Nomeie e calcule cada um separadamente. Caso use o fechamento de candle como referência, não presuma que uma ordem conseguiria ser executada retroativamente naquele fechamento sem modelar a disponibilidade e a execução do preço.

O termo “alcançou o alvo” deve significar que o preço cruzou a distância requerida em algum instante observável dentro do horizonte definido; não exige fechar um candle além do alvo. Mas precisa haver um limite de observação explícito. Um evento sem alvo dentro da janela é uma não ocorrência para aquela janela, desde que o período completo esteja coberto; se a observação termina antes do limite, trate o caso como censurado ou inconclusivo, e não como fracasso automático.

Para uma referência de preço P e unidade de pontos U, documente a fórmula usada para converter a distância. Para estudos direcionais, calcule separadamente a excursão favorável e a adversa de BUY e SELL. Use ticks cronológicos quando disponíveis. Candles OHLC não revelam a ordem intrabar entre máxima e mínima; se alvo e limite adverso forem tocados no mesmo candle e não houver ticks para resolver a sequência, classifique o caso como indeterminado ou use uma hipótese conservadora explícita.

Para simular execução, considere o lado executável apropriado: normalmente compra entra no Ask e sai no Bid; venda entra no Bid e sai no Ask. Se apenas houver candles de um preço ou não houver spread histórico completo, classifique o resultado como estimativa de trajetória, não como execução comprovada.

## 7. Matriz de alcance por pontos

Para cada ativo e timeframe, analise BUY e SELL separadamente. Use uma grade inicial de distâncias compatível com a escala do instrumento, que pode incluir 100, 200, 300, 400, 500, 600, 800, 1.000, 1.500, 2.000, 3.000 e 5.000 pontos. Ajuste ou expanda a grade se os dados do instrumento justificarem. Não force limiares inadequados ao ativo, e não remova silenciosamente limiares solicitados: indique quais foram analisados, inaplicáveis ou sem suporte de dados.

Para cada combinação de ativo, timeframe, referência, horário, direção, distância e horizonte, calcule quando possível:
- total de oportunidades elegíveis;
- contagem de alcances;
- taxa de alcance;
- intervalos de confiança;
- mediana e percentis da excursão favorável e adversa;
- tempo até alcançar a distância;
- frequência de alcançar a distância antes de um limite adverso;
- resultado por dia da semana, semana, mês e regime;
- custos estimados e sensibilidade a spread/comissão, quando houver dados.

Separe a taxa de alcance simples da taxa de sucesso de uma regra com alvo e limite adverso. Não chame a primeira de win rate.

A análise “quanto o preço alcançou, independentemente da rapidez” ainda precisa de uma janela máxima verificável. Não misture alcances dentro de 5 minutos com alcances dentro de 4 horas como se fossem o mesmo resultado. Mostre a curva por horizonte e, quando solicitado, o resultado para o horizonte máximo explicitamente definido.

## 8. Descoberta de padrões e repetições

Pesquise o conjunto completo de variáveis relevantes disponíveis, incluindo:
- horário exato do servidor e minuto da hora;
- dia da semana, sessão, semana e mês;
- direção e sequência de candles;
- corpo, pavios, amplitude, gaps e amplitude relativa;
- volatilidade e atividade anteriores;
- rompimentos, falsas quebras, rejeições e retornos a níveis;
- máximas/mínimas anteriores e distâncias de níveis;
- contexto de timeframes maiores, usando apenas barras conhecidas no instante de referência;
- tick count, intervalo entre ticks, mudanças de Bid/Ask, spread e proxies de liquidez;
- notícias, moeda, importância, previsão, valor divulgado e tempo relativo ao evento, quando os dados forem confiáveis;
- combinações de duas ou mais condições;
- repetição em dias, semanas, meses e regimes diferentes;
- divergência entre fontes ou ativos relacionados, se os respectivos timestamps e dados forem comparáveis.

Procure padrões direcionais, de atividade, volatilidade, range, proxy de liquidez, sequência, estrutura, multi-timeframe, reversão e continuação. Não presuma que as categorias esgotem as possibilidades.

Para cada padrão, defina uma regra reproduzível. Informe quantas oportunidades satisfizeram a condição, quantas não satisfizeram, quando ocorreu, qual foi o resultado futuro e qual era a referência de comparação. Relate padrões negativos e horários sem evidência também.

Não conte candles sobrepostos como milhares de observações independentes quando fazem parte do mesmo movimento. Considere dependência temporal e agrupamento por dia ou semana.

## 9. Rigor estatístico e controle de falsos positivos

Testar milhares de combinações aumenta a probabilidade de encontrar resultados aparentemente fortes por acaso. Aplique controles compatíveis com o desenho da pesquisa:
- conte e reporte as hipóteses testadas;
- informe N, sucessos, fracassos e taxa-base;
- use intervalos de confiança apropriados, como Wilson para proporções, quando pertinente;
- use bootstrap em blocos ou outro método que considere dependência temporal quando necessário;
- controle testes múltiplos, por exemplo com Benjamini–Hochberg ou Bonferroni, justificando o método;
- separe descoberta e validação cronologicamente;
- valide em período posterior que não participou da descoberta;
- verifique estabilidade por semana, mês, sessão e regime;
- teste sensibilidade a custos, parâmetros e pequenas mudanças na definição;
- use placebo, condição invertida ou grupo de comparação quando adequado.

Não escolha o melhor resultado de um universo enorme e apresente sua taxa bruta como evidência confirmada. O ranking exploratório deve ser rotulado como exploratório até a validação fora da amostra. Se a amostra for insuficiente, classifique a evidência como insuficiente, sem converter ausência de evidência em evidência de ausência.

## 10. Estrutura obrigatória do relatório

Organize o relatório por ativo, feed, timeframe e período. Inclua, conforme os dados permitirem:

1. Resumo executivo: principais descobertas, negativas e limitações.
2. Escopo: arquivos, versões de schema, datas, ativos, timeframes e timezone.
3. Auditoria dos dados: linhas, chaves, duplicatas, gaps, cobertura e campos disponíveis.
4. Unidades: especificação do símbolo e conversão de pontos usada.
5. Varredura completa por horário exato e minuto da hora.
6. Matriz de alcance por distância, direção e horizonte.
7. Excursões favoráveis/adversas, tempo até a meta e sequência dos eventos.
8. Padrões recorrentes, regras exatas e comparação com a taxa-base.
9. Diferenças entre BUY e SELL e entre ativos, sem misturar escalas.
10. Custos e limitações de execução.
11. Validação fora da amostra, robustez, incerteza e testes múltiplos.
12. Outras descobertas fora das perguntas iniciais.
13. Lista de análises impossíveis ou inconclusivas e dados necessários para concluí-las.

Para cada padrão relevante, reporte ao menos: ativo/feed, timeframe, período, timezone, horário, referência, direção, condição, distância e unidade, horizonte, oportunidades elegíveis, sucessos, taxa de alcance, excursão adversa, tempo até a meta, custos quando disponíveis, estabilidade e validação.

Separe explicitamente:
- Fatos observados: números diretamente auditáveis.
- Inferências: resultados de procedimentos estatísticos declarados.
- Hipóteses: possíveis explicações que ainda precisam de teste.

Inclua ranking resumido para leitura rápida, mas não substitua a tabela completa quando a solicitação exigir uma varredura integral. Para resultados grandes, grave tabelas completas em CSV/Parquet e entregue também um resumo legível.

## 11. Reprodutibilidade e artefatos

A análise deve ser reproduzível. Registre:
- definição formal do evento e dos alvos;
- filtros e exclusões;
- campos e unidades usados;
- timezone e conversão;
- janelas/horizontes;
- tratamento de faltantes, duplicatas e censura;
- fórmulas ou código utilizado;
- quantidade de hipóteses testadas;
- versão ou hash dos arquivos de entrada, quando disponível;
- outputs gerados.

Para arquivos volumosos, use processamento por chunks ou ferramentas analíticas apropriadas; não carregue milhões de linhas na memória sem necessidade. Prefira scripts de análise reutilizáveis e dados derivados claramente separados dos originais.

No contexto deste repositório, salve relatórios em docs/relatorios quando a tarefa solicitar um artefato persistente ou quando o fluxo de trabalho do usuário exigir isso. Não faça commits de dados brutos, relatórios ou alterações de código sem respeitar o pedido e o workflow vigente.

## 12. Checklist de encerramento

Antes de apresentar a conclusão, confirme:
- Os arquivos realmente usados foram identificados.
- O schema e a unidade de pontos foram confirmados.
- O timezone foi tratado sem offset presumido indevidamente.
- O universo temporal e os limiares pesquisados correspondem ao pedido.
- BUY e SELL foram separados.
- O preço foi avaliado pela excursão posterior, não apenas pelo fechamento do candle.
- Eventos com sequência intrabar ambígua foram tratados corretamente.
- Gaps e cobertura insuficiente não foram interpretados como ausência de movimento.
- O tamanho da amostra e os testes múltiplos foram considerados.
- Descoberta exploratória foi separada de validação.
- As limitações restantes estão escritas com clareza.
- Nenhuma execução, compilação ou teste foi alegado sem ter sido realizado.

A missão é investigar profundamente, demonstrar numericamente e manter a conclusão proporcional à evidência. Precisão significa rastreabilidade, definição correta das unidades, cobertura auditada e inferência honesta — não produzir uma certeza artificial.
