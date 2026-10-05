# Workflow de Desenvolvimento

## 1. Definição

Antes de codificar, responder:

- qual problema resolve?
- qual é a tese?
- qual ativo?
- qual timeframe?
- qual horizonte?
- qual unidade econômica de risco?
- o que invalida?
- como será validado?

## 2. Especificação

Escrever:

- matemática;
- estados;
- entradas;
- saídas;
- risco;
- gerenciamento;
- telemetria;
- painel;
- inputs.

## 3. Implementação

Construir primeiro o esqueleto correto e depois adicionar lógica.

Não começar por cosmética.

## 4. Compilação

No MetaEditor:

- compilar;
- eliminar erros;
- revisar warnings;
- verificar includes e dependências.

## 5. Teste funcional

Verificar:

- sinais;
- ordens;
- fechamento;
- SL/TP;
- trailing;
- limites;
- restart;
- dia novo;
- mudança de sessão;
- ausência de dados.

## 6. Telemetria

Conferir se o CSV explica:

- o que aconteceu;
- por que aconteceu;
- quando aconteceu;
- com quais parâmetros.

## 7. Backtest

Executar conforme `docs/BACKTEST.md`.

## 8. Análise

Separar:

- erro de código;
- erro de dados;
- problema de execução;
- fraqueza da estratégia.

## 9. Ajuste

Alterar uma hipótese por vez quando possível.

Registrar o motivo da mudança.

## 10. Comparação

Nunca comparar dois resultados sem garantir:

- mesmo período;
- mesmo símbolo;
- mesmo custo;
- mesma modelagem;
- mesma regra de capital.

## 11. Demo

Depois da validação histórica, observar comportamento em demo/conta mínima antes da exposição maior.

## 12. Produção

Só depois de:

- código compilado;
- risco compreendido;
- execução observada;
- telemetria funcionando;
- limites testados;
- documentação atualizada.

## Ao corrigir um bug

Registrar:

- sintoma;
- causa;
- correção;
- risco de regressão;
- teste que comprova a correção.

Não simplesmente apagar o sintoma.
