# Análise de Logs e CSVs

## Objetivo

Transformar telemetria em diagnóstico de execução e evidência sobre a estratégia.

## Antes da análise

Verificar:

- nome do arquivo;
- período;
- timezone;
- símbolo;
- EA;
- versão;
- schema;
- quantidade de linhas;
- colunas faltantes;
- tipos;
- duplicatas;
- gaps temporais.

## Integridade

Checar:

```
timestamp crescente?
IDs duplicados?
trades duplicados?
eventos sem INIT?
POSITION_CLOSE sem OPEN?
ORDER_REJECTED sem ORDER_SEND?
retcode ausente?
valores impossíveis?
spread negativo?
volume fora do step?
```

## Reconstrução de trade

Quando houver eventos suficientes, reconstruir:

```
SIGNAL
→ ORDER_SEND
→ POSITION_OPEN
→ MODIFY
→ POSITION_CLOSE
```

Uma análise de trade deve, quando possível, separar:

- resultado da entrada;
- risco assumido;
- gerenciamento;
- saída;
- custo;
- slippage.

## Perguntas principais

### Frequência

- quantos sinais?
- quantas entradas?
- quantos bloqueios?
- por qual motivo?

### Execução

- quantas ordens recusadas?
- quais retcodes?
- spread médio;
- spread nos trades;
- slippage médio;
- horários problemáticos.

### Estratégia

- win rate;
- expectativa;
- MAE;
- MFE;
- duração;
- distribuição por sessão;
- distribuição por regime.

### Gerenciamento

- quantos trades atingiram trailing?
- quantos saíram por tempo?
- quantos chegaram ao alvo?
- quantos foram encerrados por limite diário?

## Análise por motivo

Um dos relatórios mais úteis:

```
Motivo                  Ocorrências   % dos sinais
---------------------------------------------------
NO_TREND
SPREAD_HIGH
INVALIDATION
CHASE_TOO_FAR
DAILY_LIMIT
SESSION_CLOSED
...
```

Isso diferencia falta de oportunidade de bug.

## Bug vs estratégia

Sinais de possível bug:

- evento impossível;
- estado incoerente;
- volume inválido;
- preço fora da faixa;
- sequência lógica quebrada;
- posição gerenciada sem registro;
- diferença inexplicável entre ordem enviada e posição.

Sinais de característica da estratégia:

- muitos bloqueios no mesmo regime;
- perdas agrupadas em determinada sessão;
- sinais raros mas coerentes;
- drawdown concentrado em regime conhecido.

## CSVs grandes

Para arquivos grandes:

1. ler em chunks;
2. agregar antes de visualizar;
3. trabalhar por período;
4. não carregar milhões de linhas na memória sem necessidade.

## Resultado

Todo relatório deve terminar separando:

### Fatos observados

Dados diretamente presentes no arquivo.

### Inferências

Conclusões derivadas dos dados.

### Hipóteses

Explicações ainda não comprovadas.

Nunca misturar os três.
