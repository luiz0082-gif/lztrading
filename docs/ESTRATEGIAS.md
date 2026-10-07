# Laboratório de Estratégias

## Objetivo

Transformar uma ideia de mercado em uma hipótese operacional que possa ser falsificada.

## Ciclo

```
Observação
→ Hipótese
→ Mecanismo
→ Regras
→ Invalidação
→ Risco
→ Custo
→ Backtest
→ Robustez
→ OOS
→ Demo
→ Produção
→ Monitoramento
```

## 1. Observação

Registrar o que foi observado sem explicar por que acontece.

Exemplo:

> Depois de uma expansão de range em M5, alguns recuos curtos retomam a direção original.

Isso é observação, não edge.

## 2. Hipótese

Escrever uma explicação testável:

> Participantes que ficaram fora do impulso usam o recuo para completar execução na mesma direção.

A hipótese precisa permitir um teste que possa dar errado.

## 3. Mecanismo

Definir por que o comportamento deveria existir:

- fluxo;
- liquidez;
- microestrutura;
- comportamento recorrente;
- horário;
- estrutura;
- posicionamento;
- reação a informação.

Não usar uma explicação causal apenas porque ela parece intuitiva.

## 4. Regra operacional

Transformar a tese em regras mensuráveis.

Toda regra deve responder:

- quando começa a observar;
- o que é sinal;
- qual preço dispara;
- quando cancela;
- onde invalida;
- quando sai;
- quando não opera.

Evitar termos subjetivos como "forte", "bonito", "bom movimento" sem uma definição matemática.

> **Perfil do operador:** sem Stop Loss. A regra operacional deve prever saída por alvo, gerenciamento, tempo ou invalidação lógica; o SL, se existir, fica implementado e desativado por padrão.

## 5. Invalidação

A estratégia precisa ter uma condição clara que diga:

> a tese deixou de ser verdadeira.

Isso é diferente de stop financeiro.

- invalidação = a premissa da entrada falhou;
- stop financeiro = limite máximo de perda.

## 6. Custos

Antes de julgar edge, descontar:

- spread;
- comissão;
- slippage;
- swaps, se existirem;
- impacto de execução;
- horário de liquidez.

Uma edge menor que seu custo líquido não é edge operacional.

## 7. Parâmetros

Classificar cada parâmetro:

### Estrutural

Deriva da tese e deve ser alterado com cautela.

### Operacional

Necessário por limitações do broker/execução.

### Adaptativo

Calculado a partir do mercado.

### Otimizável

Pode ser estudado, mas precisa de controle contra overfitting.

### Segurança

Protege a conta e a execução, não deve ser escolhido pelo melhor backtest.

## 8. Falsificação

Toda estratégia deve ter pelo menos um teste que deveria quebrá-la:

- direção invertida;
- horário placebo;
- símbolo placebo;
- parâmetro deslocado;
- regime contrário;
- custo maior;
- entrada atrasada;
- saída antecipada.

Se o placebo também funciona, a explicação da edge está fraca.

## 9. Robustez

Preferir zonas de desempenho a pontos ótimos.

Exemplo ruim:

> 17 minutos funciona melhor que todos os outros valores.

Exemplo saudável:

> 12–22 minutos permanecem positivos e com drawdown semelhante.

## 10. OOS e walk-forward

O dado usado para escolher regras não pode ser tratado como validação independente.

Separar:

- desenvolvimento;
- validação;
- fora da amostra.

Registrar quando uma decisão foi alterada depois de observar resultados.

## 11. Regime

Analisar por:

- ano;
- mês;
- sessão;
- volatilidade;
- tendência/range;
- dia da semana;
- horário;
- eventos macroeconômicos, quando aplicável.

Uma estratégia que funciona em um único regime deve ser classificada como dependente de regime.

## 12. Critério de sobrevivência

Não basta lucro.

Avaliar:

- retorno líquido;
- drawdown;
- profit factor;
- expectativa por trade;
- distribuição de ganhos/perdas;
- sequência máxima de perdas;
- custo médio;
- estabilidade mensal;
- estabilidade anual;
- concentração do resultado;
- sensibilidade de parâmetros.

## Registro

Cada estratégia importante deve ter um README dentro de seu diretório com:

- tese;
- versão;
- ativos;
- timeframe;
- regras;
- risco;
- inputs;
- validação;
- resultados;
- limitações;
- data da última revisão.

## Registro de estratégias

| EA | Tese | Status |
|---|---|---|
| ChainScalper (`MQL5/Experts/ChainScalper/`) | Rompimento em M1 a favor da tendência → corrente de 4–8 posições (STOPs pré-programados) com trailing escalonado por posição | v1.00 compilada; sem backtest |
