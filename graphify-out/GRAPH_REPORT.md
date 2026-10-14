# Graph Report - lztrading  (2026-10-05)

## Corpus Check
- Corpus is ~20,073 words - fits in a single context window. You may not need a graph.

## Summary
- 97 nodes · 132 edges · 9 communities (8 shown, 1 thin omitted)
- Extraction: 83% EXTRACTED · 17% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Validacao e Anti-Overfitting
- Regras do Projeto e Skills
- Telemetria e CSV CORE
- Relatorio MicroMomentum
- Script de Analise Python
- WallStreetBreaker e Risco
- Ouro EAs e FixClock
- MicroMomentum v2.20

## God Nodes (most connected - your core abstractions)
1. `CLAUDE.md Instrucoes do Projeto LZ Trading` - 11 edges
2. `docs/CSV.md Padrao CSV LZ Trading` - 10 edges
3. `Relatorio de Analise CSVs MicroMomentum v2.00/v2.10 (2026-10-05)` - 9 edges
4. `main()` - 8 edges
5. `EA DolarFix` - 6 edges
6. `docs/PAINEL.md Design System de Paineis` - 5 edges
7. `docs/BACKTEST.md Padrao de Backtest e Validacao` - 5 edges
8. `Teste placebo (direcao invertida, horario alternativo)` - 5 edges
9. `docs/ESTRATEGIAS.md Laboratorio de Estrategias` - 5 edges
10. `load()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Desafiar a tese (falsificacao, placebo, regime, custo)` --semantically_similar_to--> `Teste placebo (direcao invertida, horario alternativo)`  [INFERRED] [semantically similar]
  .claude/skills/strategy-lab/SKILL.md → docs/BACKTEST.md
- `Invalidacao (premissa falhou) distinta de stop financeiro` --semantically_similar_to--> `Invalidacao antes de entrada`  [INFERRED] [semantically similar]
  docs/ESTRATEGIAS.md → CLAUDE.md
- `Falha segura (nao abrir posicao, manter protecoes, registrar motivo)` --semantically_similar_to--> `Seguranca operacional (nao esconder retcode, nao remover limite de perda)`  [INFERRED] [semantically similar]
  docs/ARQUITETURA.md → CLAUDE.md
- `Modelo de eventos (INIT, SIGNAL, BLOCK, ORDER_SEND, ORDER_REJECTED, POSITION_*, RISK, ERROR)` --semantically_similar_to--> `Eventos minimos de telemetria`  [INFERRED] [semantically similar]
  .claude/skills/ea-observability/SKILL.md → docs/TELEMETRIA.md
- `Diagnostico v2.5 de nao abre ordens (permissoes, WSB2 SCAN, ordem recusada)` --semantically_similar_to--> `Ordem de diagnostico quando EA nao opera (permissoes ate retcode)`  [INFERRED] [semantically similar]
  MQL5/Experts/WallStreetBreaker/README.md → .claude/skills/mql5-engineering/SKILL.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Telemetria, CSV e analise de dados formam o pipeline de observabilidade** — docs_telemetria_telemetria, docs_csv_padrao_csv, docs_analise_dados_analise, claude_skills_ea_observability_skill_ea_observability, claude_skills_data_analysis_skill_data_analysis [INFERRED 0.85]
- **EAs que dependem do relogio Londres FixClock.mqh** — mql5_experts_dolarfix_readme_dolarfix, mql5_experts_ouroabertura_readme_ouroabertura, mql5_experts_ouromomento_readme_ouromomento, mql5_experts_dolarfix_readme_fixclock [EXTRACTED 1.00]
- **Validacao de estrategia: estrategias, backtest, placebo e skill strategy-lab** — docs_estrategias_laboratorio, docs_backtest_padrao, docs_backtest_placebo, claude_skills_strategy_lab_skill_strategy_lab, claude_otimizacao_overfitting [INFERRED 0.85]

## Communities (9 total, 1 thin omitted)

### Community 0 - "Validacao e Anti-Overfitting"
Cohesion: 0.12
Nodes (21): Invalidacao antes de entrada, Politica contra overfitting e otimizacao, Desafiar a tese (falsificacao, placebo, regime, custo), Skill strategy-lab, Analise de concentracao de lucro, Ordem dos testes (sanidade, edge bruta, custos, sensibilidade, placebo, periodos, OOS), docs/BACKTEST.md Padrao de Backtest e Validacao, Teste placebo (direcao invertida, horario alternativo) (+13 more)

### Community 1 - "Regras do Projeto e Skills"
Cohesion: 0.16
Nodes (15): CLAUDE.md Instrucoes do Projeto LZ Trading, Money-first, Regra de mudanca em EA existente (mudanca localizada), Seguranca operacional (nao esconder retcode, nao remover limite de perda), Skill ea-panel, Skill mql5-engineering, Validacao final (compilar, nao afirmar o que nao foi executado), Core vs especifico (logica de estrategia nao vai em utilitario generico) (+7 more)

### Community 2 - "Telemetria e CSV CORE"
Cohesion: 0.18
Nodes (14): Skill data-analysis, Skill ea-observability, Modelo de eventos (INIT, SIGNAL, BLOCK, ORDER_SEND, ORDER_REJECTED, POSITION_*, RISK, ERROR), Checagem de integridade de CSV antes da analise, Separacao fatos, inferencias e hipoteses, CSV CORE schema, DECISIONS CORE, Delimitador ponto-e-virgula, append seguro e rotacao mensal (+6 more)

### Community 3 - "Relatorio MicroMomentum"
Cohesion: 0.20
Nodes (12): Versionamento de schema e cabecalho como contrato, Aderencia do MicroMomentum ao padrao CSV (delimitador, schema_version, timezone), 81% dos ticks em BLOCK_GOAL (meta diaria atingida), Risco real = cauda de MAE sem stop (MAE max -US$ 42,11, hold 3,85 h), Execucao A (IC Markets, slippage 6,5 pts) vs B (FP Markets, slippage 0), Amostra mistura dezenas de configuracoes em 6 dias, ~204 posicoes fora do EA contaminam saldo (reconciliacao falha), Relatorio de Analise CSVs MicroMomentum v2.00/v2.10 (2026-10-05) (+4 more)

### Community 4 - "Script de Analise Python"
Cohesion: 0.33
Nodes (5): load(), main(), section(), trade_stats(), ts()

### Community 5 - "WallStreetBreaker e Risco"
Cohesion: 0.33
Nodes (6): Separacao conceitual de risco (sinal, stop real/virtual, emergencia, circuit breaker), Ordem de diagnostico quando EA nao opera (permissoes ate retcode), Limite de perda da cesta de piramidacao (InpMaxBasketLossUsd), Diagnostico v2.5 de nao abre ordens (permissoes, WSB2 SCAN, ordem recusada), SL de emergencia no servidor (InpEmergencyOnServer), EA WallStreetBreaker v2.4/v2.5

### Community 6 - "Ouro EAs e FixClock"
Cohesion: 0.40
Nodes (6): FixClock.mqh (relogio Londres/servidor compartilhado), Meta diaria e perda maxima obrigatoria (zero = EA nao liga), Rompimento da faixa de abertura (Londres e NY) no XAUUSD, EA OuroAbertura, Impulso + recuo a favor do VWAP (limite no meio do corpo), EA OuroMomento

### Community 7 - "MicroMomentum v2.20"
Cohesion: 0.40
Nodes (5): TRADES CORE e exit reasons estaveis, ESCAPE anti-preso e ESCAPE_SLIP, Entrada por pullback virtual, Colunas novas em trades.csv (mae_ms, pts_1s/3s/5s, entry_impulse_pts, slip_high), MicroMomentum v2.20 (filtros, pullback virtual, ESCAPE_SLIP, telemetria nova)

## Knowledge Gaps
- **23 isolated node(s):** `Money-first`, `Validacao final (compilar, nao afirmar o que nao foi executado)`, `Regra de mudanca em EA existente (mudanca localizada)`, `Regra central: codigo de trading como producao e experimento quantitativo`, `Core vs especifico (logica de estrategia nao vai em utilitario generico)` (+18 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 28 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CLAUDE.md Instrucoes do Projeto LZ Trading` connect `Regras do Projeto e Skills` to `Validacao e Anti-Overfitting`, `Telemetria e CSV CORE`, `WallStreetBreaker e Risco`?**
  _High betweenness centrality (0.375) - this node is a cross-community bridge._
- **What connects `Money-first`, `Validacao final (compilar, nao afirmar o que nao foi executado)`, `Regra de mudanca em EA existente (mudanca localizada)` to the rest of the system?**
  _23 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Validacao e Anti-Overfitting` be split into smaller, more focused modules?**
  _Cohesion score 0.11904761904761904 - nodes in this community are weakly interconnected._
- **Why does `docs/CSV.md Padrao CSV LZ Trading` connect `Telemetria e CSV CORE` to `Relatorio MicroMomentum`, `MicroMomentum v2.20`?**
  _High betweenness centrality (0.291) - this node is a cross-community bridge._
- **Why does `Politica contra overfitting e otimizacao` connect `Validacao e Anti-Overfitting` to `Regras do Projeto e Skills`?**
  _High betweenness centrality (0.213) - this node is a cross-community bridge._