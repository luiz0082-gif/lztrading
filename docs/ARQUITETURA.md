# Arquitetura do LZ Trading

## Objetivo

Separar claramente código de execução, bibliotecas, pesquisa, análise e documentação.

## Estrutura recomendada

```
MQL5/
├── Experts/
│   └── <NomeEA>/
│       ├── <NomeEA>.mq5
│       └── README.md
├── Indicators/
│   └── <NomeIndicador>/
│       ├── <NomeIndicador>.mq5
│       └── README.md
├── Scripts/
│   └── <NomeScript>/
│       ├── <NomeScript>.mq5
│       └── README.md
└── Include/
    └── <Biblioteca>/
        └── *.mqh

docs/
├── ARQUITETURA.md
├── ESTRATEGIAS.md
├── TELEMETRIA.md
├── BACKTEST.md
├── ANALISE-DADOS.md
├── PAINEL.md
└── WORKFLOW.md

.claude/
├── skills/
└── ...
```

## Regra de isolamento

Cada EA deve ser capaz de ser identificado como unidade:

- código;
- dependências;
- documentação;
- inputs;
- telemetria;
- riscos;
- histórico de alterações.

Quando um componente for compartilhado por vários EAs, deve entrar em `MQL5/Include/` e sua interface precisa ser documentada.

## Core vs específico

### Core

Comportamentos que podem ser padronizados:

- normalização de preço;
- normalização de lote;
- identificação de posição;
- cálculo monetário;
- horário;
- logging;
- CSV;
- painel;
- proteção;
- utilidades de histórico.

### Específico

Pertence à estratégia:

- sinal;
- estrutura;
- filtros;
- setup;
- score;
- estados;
- condições de entrada;
- lógica de saída;
- cálculo específico de alvo/trailing.

Não esconder lógica de estratégia dentro de utilitário genérico.

## Estado

Diferenciar:

- estado derivado do mercado;
- estado da posição;
- estado do dia;
- estado do EA;
- estado persistente.

Toda variável persistente deve ter motivo documentado.

## Multiativo

Quando houver vários símbolos:

- explicitar símbolo de cálculo;
- símbolo de execução;
- timeframe de cada série;
- dependência de dados;
- risco agregado.

Não assumir que vários símbolos equivalem a diversificação. Correlação e exposição econômica devem ser contabilizadas.

## Ordem de execução

Fluxo recomendado:

```
OnInit
  ↓
carregar/configurar
  ↓
validar ambiente
  ↓
inicializar telemetria/painel
  ↓
OnTick/OnTimer
  ↓
atualizar dados
  ↓
atualizar estado
  ↓
proteger posições
  ↓
avaliar limites
  ↓
avaliar setup
  ↓
validar entrada
  ↓
executar
  ↓
registrar resultado
```

Gerenciamento de risco de posição aberta não deve depender da existência de um novo sinal.

## Falha segura

Em dúvida crítica, o comportamento padrão deve ser:

- não abrir nova posição;
- manter proteções já existentes;
- registrar o motivo;
- permitir diagnóstico.

Nunca falhar silenciosamente.
