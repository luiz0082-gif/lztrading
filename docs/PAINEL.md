# Design System de Painéis para EAs

## Objetivo

Criar um painel operacional consistente entre EAs sem transformar cada EA em uma interface diferente.

## Hierarquia

### Camada 1 — Estado

Mostrar imediatamente:

- EA;
- símbolo;
- timeframe;
- estado geral;
- posição;
- modo de operação.

### Camada 2 — Decisão

Mostrar:

- tendência/estrutura;
- setup;
- sinal;
- direção;
- score, se existir;
- motivo de bloqueio.

### Camada 3 — Risco

Mostrar:

- risco por trade;
- risco aberto;
- P/L da posição;
- P/L diário;
- meta;
- perda máxima;
- circuit breaker.

### Camada 4 — Gerenciamento

Mostrar:

- SL;
- TP;
- trailing;
- breakeven;
- emergência;
- distância relevante.

### Camada 5 — Telemetria

Mostrar:

- último evento;
- última decisão;
- última ordem;
- retcode;
- spread;
- latência;
- heartbeat;
- versão.

## Wireframe base

```
┌─────────────────────────────────────────────────────┐
│ LZ TRADING                     SYMBOL / TF / STATE   │
├─────────────────────────────────────────────────────┤
│ MARKET / STRUCTURE                                  │
│ tendência | estrutura | regime | score              │
├─────────────────────────────────────────────────────┤
│ SETUP / DECISION                                     │
│ setup atual | direção | trigger | invalidation      │
├───────────────────────┬─────────────────────────────┤
│ POSITION              │ RISK                         │
│ side / volume         │ risk $ / daily $ / limits   │
│ entry / P&L           │ target / drawdown            │
├───────────────────────┴─────────────────────────────┤
│ MANAGEMENT                                            │
│ SL | TP | Trail | BE | Emergency                     │
├─────────────────────────────────────────────────────┤
│ TELEMETRY                                            │
│ last event | reason | retcode | spread | heartbeat   │
└─────────────────────────────────────────────────────┘
```

## Regras

O painel deve responder em segundos:

> O que o EA está vendo?

> O que ele decidiu?

> Por que entrou ou não entrou?

> Quanto está em risco?

Não criar dezenas de cards só para preencher espaço.

## Visual

Preferir:

- hierarquia limpa;
- contraste funcional;
- números legíveis;
- estados claros;
- pouca animação;
- atualização sem piscar;
- suporte a minimização;
- drag apenas quando necessário.

## Operacional

Minimizado deve continuar permitindo restaurar o painel.

Botões não podem desaparecer por causa de resize ou minimização.

Informação crítica não pode depender exclusivamente de tooltip.

## Mercado

Linhas e zonas devem ser desenhadas apenas quando fazem parte da lógica do EA.

Não desenhar indicadores ou objetos apenas para deixar o gráfico "bonito".

## Semântica

O mesmo termo deve significar a mesma coisa entre EAs.

Exemplo:

- `RISK` = risco;
- `PROFIT` = resultado/alvo;
- `STATE` = estado de mercado/EA;
- `DECISION` = decisão de entrada;
- `INVALIDATION` = condição que cancela a tese.

O painel de um EA não deve copiar semanticamente o painel de outro se a lógica for diferente.
