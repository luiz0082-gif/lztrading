# Graph Report - lztrading  (2026-10-19)

## Corpus Check
- Large corpus: 199 files · ~623,984 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 676 nodes · 1408 edges · 33 communities (24 shown, 9 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 76 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Ajuste ChainScalper (Python)
- Relatorios MBA AUDUSD
- Pipeline MBA (coleta/processamento)
- Analise de alcance MBA
- Analise FluxMatrix/CSV
- Relatorios por ativo (open)
- Consolidacao MBA
- Metodo de mineracao MBA
- Skills e docs de analise
- Telemetria e estrategias
- Strategy-lab e backtest
- Gerador DOCX scan
- Gerador DOCX XBR80
- Gerador DOCX XAU carry
- Gerador DOCX XAU
- Gerador DOCX XBR
- Relatorio XAUUSD Londres
- Gerador DOCX XAU falhas
- Padrao de inputs e painel
- Relatorios de alcance
- Padroes USTEC/XAGUSD
- Relatorio Nexus Guard
- Relatorio Vegar
- EA WallStreetBreaker
- Hipotese vs fato
- Overfitting e backtest
- Risco money-first

## God Nodes (most connected - your core abstractions)
1. `Placebo (return time-shift) test` - 22 edges
2. `Discovery 60% / validation 40% split` - 22 edges
3. `Server time UTC+2/+3, NY+7h, London -2h` - 22 edges
4. `Costs: tick spread only, no commission/slippage` - 22 edges
5. `Target or 23:30 server exit, no stop` - 19 edges
6. `main()` - 16 edges
7. `main()` - 14 edges
8. `main()` - 14 edges
9. `md_table()` - 12 edges
10. `main()` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Modelo de eventos (INIT, SIGNAL, BLOCK, ORDER_SEND, ORDER_REJECTED, POSITION_*, RISK, ERROR)` --semantically_similar_to--> `Eventos minimos de telemetria`  [INFERRED] [semantically similar]
  .claude/skills/ea-observability/SKILL.md → docs/TELEMETRIA.md
- `Desafiar a tese (falsificacao, placebo, regime, custo)` --semantically_similar_to--> `Teste placebo (direcao invertida, horario alternativo)`  [INFERRED] [semantically similar]
  .claude/skills/strategy-lab/SKILL.md → docs/BACKTEST.md
- `Skill data-analysis` --implements--> `Separacao fatos, inferencias e hipoteses`  [INFERRED]
  .claude/skills/data-analysis/SKILL.md → docs/ANALISE-DADOS.md
- `Skill ea-panel` --implements--> `Hierarquia de 5 camadas do painel (Estado, Decisao, Risco, Gerenciamento, Telemetria)`  [INFERRED]
  .claude/skills/ea-panel/SKILL.md → docs/PAINEL.md
- `EA DolarFix` --implements--> `Teste placebo (direcao invertida, horario alternativo)`  [INFERRED]
  MQL5/Experts/DolarFix/README.md → docs/BACKTEST.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **EAs que dependem do relogio Londres FixClock.mqh** — mql5_experts_dolarfix_readme_dolarfix, mql5_experts_ouroabertura_readme_ouroabertura, mql5_experts_ouromomento_readme_ouromomento, mql5_experts_dolarfix_readme_fixclock [EXTRACTED 1.00]
- **Validacao de estrategia: estrategias, backtest, placebo e skill strategy-lab** — docs_backtest_padrao, docs_backtest_placebo, claude_skills_strategy_lab_skill_strategy_lab [INFERRED 0.85]
- **LZ scalper EAs sharing no-SL default and money-based loss limits** — mql5_experts_accelchain_readme_accelchain_ea, mql5_experts_chainscalper_readme_chainscalper_ea, mql5_experts_hftretail_readme_hft_retail_ea, mql5_experts_micromomentum_readme_micromomentum_ea, mql5_experts_londondrop_readme_londondrop_ea [INFERRED 0.85]
- **MBA intraday/hourly research reports** — docs_relatorios_horarios_intraday_0100_2330_mba_2026_10_17_report, docs_relatorios_investigacao_alcance_horario_mba_2026_10_17_report, docs_relatorios_padroes_horarios_mba_2026_10_17_report, docs_relatorios_padroes_intraday_ate_2330_mba_2026_10_17_report [INFERRED 0.95]
- **Achados de relogio do ouro (Londres 10:25)** — docs_relatorios_relatorio_mba_analise_completa_2026_10_13_achado_queda_1025_londres, docs_relatorios_relatorio_mba_descobertas_2026_10_06_queda_0915_0930_utc, docs_relatorios_relatorio_mba_xauusd_2026_10_06_atividade_por_minuto [INFERRED 0.75]
- **Escala de confianca por ativo** — docs_relatorios_tabela_resumo_ativos_mba_2026_10_18_xauusd_conf_a, docs_relatorios_tabela_resumo_ativos_mba_2026_10_18_de40_conf_b_mais, docs_relatorios_tabela_resumo_ativos_mba_2026_10_18_indices_conf_c [EXTRACTED 1.00]
- **Relatórios MBA por ativo** — docs_relatorios_mba_ativos_nzdusd_nzdusd_open, docs_relatorios_mba_ativos_us30_us30, docs_relatorios_mba_ativos_us30_us30_open, docs_relatorios_mba_ativos_usdchf_usdchf, docs_relatorios_mba_ativos_usdchf_usdchf_open, docs_relatorios_mba_ativos_usdjpy_usdjpy, docs_relatorios_mba_ativos_usdjpy_usdjpy_open, docs_relatorios_mba_ativos_xauusd_xauusd, docs_relatorios_mba_ativos_xauusd_xauusd_open [INFERRED 0.85]
- **MBA pattern reports shared methodology** — concept_mba_placebo_time_shift_test, concept_mba_discovery_validation_split, concept_mba_target_or_eod_exit_no_stop, concept_mba_server_time_convention, concept_mba_costs_spread_only [INFERRED 0.85]
- **Relatorios MBA de alcance por ativo (10 ativos)** — docs_relatorios_mba_reach_audusd_relatorio, docs_relatorios_mba_reach_dxy_z6_relatorio, docs_relatorios_mba_reach_eurjpy_relatorio, docs_relatorios_mba_reach_gbpjpy_relatorio, docs_relatorios_mba_reach_xauusd_relatorio [INFERRED 0.85]
- **Relatorios MBA de padroes M1 (USTEC, XAGUSD, XBRUSD, XTIUSD)** — docs_relatorios_mba_padroes_m1_ustec_m1, docs_relatorios_mba_padroes_m1_xagusd_m1, docs_relatorios_mba_padroes_m1_xbrusd_m1, docs_relatorios_mba_padroes_m1_xtiusd_m1 [INFERRED 0.85]

## Communities (33 total, 9 thin omitted)

### Community 0 - "Ajuste ChainScalper (Python)"
Cohesion: 0.05
Nodes (51): cell_label(), day_outcomes(), describe(), ev_stress(), main(), merge_adjacent(), pooled(), scan_clock() (+43 more)

### Community 1 - "Relatorios MBA AUDUSD"
Cohesion: 0.05
Nodes (47): AUDUSD relatorio MBA, AUDUSD (FP) spread/ATR 0,63, Mineracao ret/hit/open audusd, AUDUSD relatorio MBA modo open, Mineracao modo open aud, Veredito automatico do ativo aud, BTCUSD relatorio MBA, BTCUSD (FP) (+39 more)

### Community 2 - "Pipeline MBA (coleta/processamento)"
Cohesion: 0.07
Nodes (18): build(), main(), swap_info(), approve(), build(), main(), tval(), first_passage() (+10 more)

### Community 3 - "Analise de alcance MBA"
Cohesion: 0.08
Nodes (26): bh_mask(), clock_keys(), collapse_day(), daily_extremes(), Data, fmt_slot(), give_back(), grp_stats() (+18 more)

### Community 4 - "Analise FluxMatrix/CSV"
Cohesion: 0.08
Nodes (21): baskets(), kv(), load(), num(), pt(), report(), main(), rows() (+13 more)

### Community 5 - "Relatorios por ativo (open)"
Cohesion: 0.08
Nodes (11): Correção BH de múltiplos testes, Efeito de relógio (slot horário), Padrões por horário (janelas, hora do servidor), custo_sobre_ATR (spread/ATR), DE40 COMPRA 09:00 servidor M30 45min, DXY_Z6: nenhum padrão operável (0 BH), XAUUSD: 3 candidatas marginais após BH, Placebo por deslocamento temporal do retorno (+3 more)

### Community 6 - "Consolidacao MBA"
Cohesion: 0.10
Nodes (19): key(), readall(), bullet(), clock_table(), cond_table(), esc(), fixed_table(), fmt() (+11 more)

### Community 7 - "Metodo de mineracao MBA"
Cohesion: 0.33
Nodes (27): Costs: tick spread only, no commission/slippage, Discovery 60% / validation 40% split, Placebo (return time-shift) test, Server time UTC+2/+3, NY+7h, London -2h, Target or 23:30 server exit, no stop, AUDUSD padroes_dia, DE40 padroes_dia, DXY padroes_dia (+19 more)

### Community 8 - "Skills e docs de analise"
Cohesion: 0.10
Nodes (22): Skill data-analysis, Skill ea-observability, Modelo de eventos (INIT, SIGNAL, BLOCK, ORDER_SEND, ORDER_REJECTED, POSITION_*, RISK, ERROR), Skill ea-panel, Checagem de integridade de CSV antes da analise, Separacao fatos, inferencias e hipoteses, Core vs especifico (logica de estrategia nao vai em utilitario generico), Falha segura (nao abrir posicao, manter protecoes, registrar motivo) (+14 more)

### Community 9 - "Telemetria e estrategias"
Cohesion: 0.09
Nodes (22): Mandatory EA telemetry, CSV standard (EVENTS, TRADES, schema versioning), LondonDrop strategy (XAUUSD sell 10:20 London), Context vs result (anti look-ahead) in MBA, MarketBehaviorAnalyzer (MBA) research collector v1.23, MicroMomentum diagnostic 2026-10-06 (467 trades), Deep-MAE tail is the central problem, Intraday hours 01:00-23:30 scan (all assets) (+14 more)

### Community 10 - "Strategy-lab e backtest"
Cohesion: 0.12
Nodes (20): Desafiar a tese (falsificacao, placebo, regime, custo), Skill strategy-lab, Analise de concentracao de lucro, Ordem dos testes (sanidade, edge bruta, custos, sensibilidade, placebo, periodos, OOS), docs/BACKTEST.md Padrao de Backtest e Validacao, Teste placebo (direcao invertida, horario alternativo), Cesta de 7 pares com USD, risco igual por par, EA DolarFix (+12 more)

### Community 11 - "Gerador DOCX scan"
Cohesion: 0.17
Nodes (14): bullet(), esc(), fmt(), h1(), h2(), h3(), note(), para() (+6 more)

### Community 12 - "Gerador DOCX XBR80"
Cohesion: 0.17
Nodes (13): bullet(), esc(), fmt(), h1(), h2(), h3(), note(), para() (+5 more)

### Community 13 - "Gerador DOCX XAU carry"
Cohesion: 0.16
Nodes (12): bullet(), d8(), esc(), fmt(), h1(), h2(), h3(), note() (+4 more)

### Community 14 - "Gerador DOCX XAU"
Cohesion: 0.18
Nodes (13): bullet(), esc(), fmt(), h1(), h2(), h3(), note(), para() (+5 more)

### Community 15 - "Gerador DOCX XBR"
Cohesion: 0.18
Nodes (13): bullet(), esc(), fmt(), h1(), h2(), h3(), note(), para() (+5 more)

### Community 16 - "Relatorio XAUUSD Londres"
Cohesion: 0.12
Nodes (13): Relatorio MBA analise completa XAUUSD, Achado A: ouro cai no M5 10:25 de Londres (-123 pts, t=-8,8), Criterios de falsificacao a partir de 14/10/2026, Surpresa de noticia nao preve direcao, Achado B: reversao apos quedas (fraco), Relatorio MBA descobertas XAUUSD, Padrao A: queda do ouro 09:15-09:30 UTC (hipotese anterior), Padrao B: repique ~25 min apos queda M5/M15 (+5 more)

### Community 17 - "Gerador DOCX XAU falhas"
Cohesion: 0.18
Nodes (11): bullet(), esc(), fmt(), h1(), h2(), h3(), note(), para() (+3 more)

### Community 18 - "Padrao de inputs e painel"
Cohesion: 0.17
Nodes (14): EA no-trade debugging order, mql5-engineering skill, Input group standard (14 numbered sectors), LZ Design System panel HUD (CLZPanel), Development workflow, AccelChain v1.00 (acceleration micro-scalper), Four-engine score (Direction, Momentum, Activity, Execution), Profit-lock ladder (4-8 leg chain) (+6 more)

### Community 19 - "Relatorios de alcance"
Cohesion: 0.21
Nodes (11): AUDUSD relatorio de alcance, DXY_Z6 relatorio de alcance, EURJPY relatorio de alcance, GBPJPY relatorio de alcance, NZDUSD_r relatorio de alcance, US30 relatorio de alcance, USDCHF relatorio de alcance, USDJPY relatorio de alcance (+3 more)

### Community 20 - "Padroes USTEC/XAGUSD"
Cohesion: 0.29
Nodes (9): USTEC padroes por horario (M1, 0 passaram), USTEC padroes intraday alvo ou saida 23:30, Metodo alvo ou saida 23:30 sem stop (ev_estresse_pts), XAGUSD padroes por horario (M1), XAGUSD padroes intraday alvo ou saida 23:30 (0 horarios puros), XBRUSD padroes por horario (4 passaram, placebo max 3), XBRUSD padroes intraday alvo ou saida 23:30 (571 horarios puros), XTIUSD padroes por horario (M1) (+1 more)

### Community 21 - "Relatorio Nexus Guard"
Cohesion: 0.20
Nodes (5): Relatorio Nexus Matrix/Guard Pro, Guard 1.076 como base unificada (sem noticias externas), Painel PRO / design system proposto, Volume excessivo de telemetria CSV, Relatorio PieceTrend

### Community 22 - "Relatorio Vegar"
Cohesion: 0.50
Nodes (3): Relatorio Vegar, Funil sweep -> MSS -> deslocamento -> reteste, Replay de 62 oportunidades completas

### Community 23 - "EA WallStreetBreaker"
Cohesion: 0.50
Nodes (4): Limite de perda da cesta de piramidacao (InpMaxBasketLossUsd), Diagnostico v2.5 de nao abre ordens (permissoes, WSB2 SCAN, ordem recusada), SL de emergencia no servidor (InpEmergencyOnServer), EA WallStreetBreaker v2.4/v2.5

## Knowledge Gaps
- **65 isolated node(s):** `Tese do fixing WM/Reuters de Londres (PRE compra USD, POS vende USD)`, `Cesta de 7 pares com USD, risco igual por par`, `Tese: fluxo forcado nos ultimos 30 min do S&P 500 na direcao do dia (ETFs alavancados, gamma, MOC)`, `Rompimento da faixa de abertura (Londres e NY) no XAUUSD`, `Impulso + recuo a favor do VWAP (limite no meio do corpo)` (+60 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 218 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `main()` connect `Analise de alcance MBA` to `Ajuste ChainScalper (Python)`, `Pipeline MBA (coleta/processamento)`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **What connects `Tese do fixing WM/Reuters de Londres (PRE compra USD, POS vende USD)`, `Cesta de 7 pares com USD, risco igual por par`, `Tese: fluxo forcado nos ultimos 30 min do S&P 500 na direcao do dia (ETFs alavancados, gamma, MOC)` to the rest of the system?**
  _65 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Ajuste ChainScalper (Python)` be split into smaller, more focused modules?**
  _Cohesion score 0.05451829723674384 - nodes in this community are weakly interconnected._
- **Why does `main()` connect `Ajuste ChainScalper (Python)` to `Pipeline MBA (coleta/processamento)`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **Should `Relatorios MBA AUDUSD` be split into smaller, more focused modules?**
  _Cohesion score 0.05021173623714459 - nodes in this community are weakly interconnected._
- **Should `Pipeline MBA (coleta/processamento)` be split into smaller, more focused modules?**
  _Cohesion score 0.06676342525399129 - nodes in this community are weakly interconnected._
- **Should `Analise de alcance MBA` be split into smaller, more focused modules?**
  _Cohesion score 0.07510204081632653 - nodes in this community are weakly interconnected._