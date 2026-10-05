# Padrão de Backtest e Validação

## Objetivo

Descobrir se a estratégia sobrevive aos dados e aos custos, não encontrar uma configuração bonita no Strategy Tester.

## Configuração mínima

Registrar:

- corretora;
- servidor;
- símbolo;
- especificação;
- timeframe;
- período;
- saldo inicial;
- moeda;
- modelo de ticks;
- spread;
- comissão;
- slippage/desvio;
- timezone;
- parâmetros;
- versão do código.

## Ordem dos testes

### 1. Sanidade

Verificar:

- o EA abre e fecha;
- horários corretos;
- volume correto;
- cálculo de SL/TP;
- limites diários;
- posições duplicadas;
- comportamento após restart;
- retcodes;
- telemetria.

### 2. Edge bruta

Rodar a estratégia sem kill switches que possam esconder sua distribuição real, salvo proteções obrigatórias de segurança.

Objetivo: entender a lógica antes das camadas defensivas.

### 3. Custos reais

Aplicar custos coerentes com a corretora.

Comparar:

```
resultado bruto
resultado após spread
resultado após comissão
resultado após slippage
resultado líquido
```

### 4. Sensibilidade

Variar parâmetros próximos do valor escolhido.

Não procurar apenas o máximo.

### 5. Placebo

Aplicar pelo menos um teste falso:

- direção invertida;
- horário alternativo;
- entrada deslocada;
- sinal embaralhado, quando metodologicamente possível.

### 6. Períodos

Separar:

- anos;
- meses;
- regimes;
- sessões;
- volatilidade.

### 7. OOS

Nunca chamar período usado para escolher parâmetros de "fora da amostra".

## Métricas

Não olhar apenas lucro líquido.

Avaliar:

- expectativa por trade;
- profit factor;
- drawdown máximo;
- drawdown relativo;
- Sharpe/Sortino quando apropriado;
- percentual de meses positivos;
- sequência máxima de perdas;
- concentração do lucro;
- retorno por unidade de risco;
- custo como percentual do gross profit;
- distribuição de duração.

## Concentração

Perguntar:

- quanto do lucro vem dos 5 melhores trades?
- quanto vem de um único mês?
- um único ano?
- um único ativo?
- um único horário?

Concentração excessiva é risco de fragilidade.

## Execução

Para EAs intraday, observar:

- spread na entrada;
- slippage;
- atraso;
- rejeição;
- requote;
- diferença entre preço solicitado e executado.

## Walk-forward

Quando aplicável:

1. treinar/calibrar em janela A;
2. validar em janela B;
3. avançar;
4. repetir;
5. consolidar todos os blocos OOS.

## Critério de conclusão

Um backtest não deve terminar em:

> "deu lucro".

Deve terminar em:

> "a tese permanece válida sob estas condições, falha nestas outras, e os limites de utilização são estes."

