# LZ Trading

Laboratório e repositório central para desenvolvimento de sistemas de negociação em MQL5.

## Escopo

Este repositório reúne:

- Expert Advisors (EAs);
- indicadores;
- scripts de análise e utilitários;
- motores e bibliotecas reutilizáveis;
- pesquisa e formalização de estratégias;
- backtests e estudos de robustez;
- análise de logs;
- análise de CSV/telemetria;
- painéis operacionais;
- documentação técnica e decisões de projeto.

## Estrutura

```
MQL5/
  Experts/      EAs
  Indicators/   indicadores
  Scripts/      scripts e ferramentas de análise
  Include/      bibliotecas reutilizáveis

docs/            arquitetura, estratégia, telemetria e validação
.claude/         instruções e Skills para desenvolvimento assistido por IA
```

## Regra central

Código de trading deve ser tratado como software de produção e como experimento quantitativo ao mesmo tempo.

Não basta compilar. O sistema precisa ter:

1. lógica objetiva;
2. risco explícito;
3. diagnóstico;
4. telemetria;
5. validação contra dados;
6. critérios de invalidação;
7. documentação que permita reproduzir o resultado.

Consulte `CLAUDE.md` e os documentos em `docs/` antes de iniciar um projeto.
