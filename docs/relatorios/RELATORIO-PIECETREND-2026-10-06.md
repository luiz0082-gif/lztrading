# Relatório de Análise — PieceTrend (XAUUSD M5) — 2026-10-06

Escopo: varredura dos 12 CSVs `PieceTrend_XAUUSD_*` em `MQL5\Files` + leitura do código `PieceTrend.mq5` (v1.10) + logs do terminal (`MQL5\Logs`).
Pergunta: por que o EA nunca abriu uma ordem?

## 1. Veredito

**Não é bug de execução. O EA nunca tentou enviar uma ordem.** `TRADES.csv` e `ERRORS.csv` têm só o BOM (2 bytes), há 0 eventos `ORDER_SENT`/`ENTRY_BLOCKED`/`SETUP_CANCELLED`, `mql_retcode` é sempre 0 e o saldo não muda por ordem do EA.
O funil morre **antes** do gatilho: o EA quase nunca forma candidato, e os poucos que formou foram barrados pelos gates de risco/espaço e o preço nunca cruzou a entrada planejada.

## 2. Integridade dos dados (antes de interpretar)

| Item | Achado | Classe |
|---|---|---|
| Cabeçalho | **Nenhum CSV tem cabeçalho.** Arquivos são UTF-16 LE com BOM. `EnsureHeader` testa `FileSize(h)==0`, mas o BOM (2 bytes) já é gravado na abertura, então o cabeçalho nunca é escrito. Schema reconstruído pelas strings do código (CORE 79 col, PA 55, TRADES 37, DAILY 35, ERRORS 22; contagens batem com todas as linhas) | **Bug** |
| Sessões | 26 INIT/DEINIT sequências em 5 dias, 4 magics (220994, 704009269, 707335068, 22091994), `instance_id` 1 e 2 | Operação (recompilações/reinícios) |
| `event_seq` | Reinicia a cada INIT: 10.403 pares (magic,event_seq) repetidos; `event_id` vem vazio no CORE | Bug de telemetria |
| Duplicatas | 12 linhas idênticas no CORE, 3 timestamps de barra repetidos (re-INIT na mesma barra) | Esperado após reinício |
| Volume | 36.245 de 36.913 linhas CORE (98%) são `CORE_HEARTBEAT` idênticos a cada 5 s; arquivo de 38 MB | Telemetria ruidosa |
| Versão | Nenhuma coluna/INIT registra versão/hash. O `.mq5` tem mtime 02/10 18:21 e o `.ex5` 05/10 22:03; eventos `SETUP_NOT_ARMED` só aparecem após 06/10 04:03 (servidor) | **Dado de procedência ausente** |
| Timezone | Logs do terminal estão em hora local; CSV/barras em hora do servidor (diferença observada de +6 h, ex.: 12:31 local = 18:31 servidor) | Confirmar |
| Terminal | "Abnormal termination" em todos os EAs a cada fechamento do terminal (inclusive FluxMatrix e MicroMomentum): é encerramento do terminal, não crash do PieceTrend | Esperado |
| Algo trading | Log mostra "automated trading is disabled" em 03/10 11:48 local, reativado em 04/10 21:47 local (FluxMatrix registrou `TERMINAL_TRADE_DISABLED`). O PieceTrend não loga `TERMINAL_TRADE_ALLOWED`/`MQL_TRADE_ALLOWED` | Não verificável pelo CSV |

Consequência: só as linhas a partir de 06/10 04:03:37 (servidor) são **certamente** do build atual (22 barras). O restante vem de builds anteriores cujo código não temos.

## 3. Funil por barra (616 BAR_ANALYSIS, 613 únicas)

Duas eras de comportamento:

| | Era antiga (sessões ≤14, 01–02/10) | Era recente (≥15, 05–06/10) |
|---|---|---|
| Barras | 287 | 326 |
| `DEFENSIVE_LOCK` (HARD) | **240 (84%)** | 2 (0,6%) |
| defense_score médio | 70,0 (saturado) | 32,4 |
| `NO_TREND` | 35 | 149 |
| `CONTEXT_BUILDING` (tendência válida, sem setup) | 12 | 170 |
| `TRIGGER_WAIT` (candidato) | 0 | 5 linhas = 4 barras únicas |
| `SETUP_ARMED` | 0 | **0** |

- Era antiga: o score de defesa saturava (path_efficiency médio 0,15 contra limiar 0,30/0,12) e travava quase tudo. O comentário "FIX v1.10" no código descreve exatamente isso; os dados confirmam que a recalibração resolveu esse bloqueio (84% → 0,6%).
- Era recente: 177 das 326 barras tinham tendência válida (score ≥ 55), mas só **4 barras (2,3%)** geraram candidato.

### Os 4 candidatos (todos reprovados)

| Barra (servidor) | Dir | Setup | setup_score | risk_norm (≤2,5) | space_ratio (≥0,7) | Resultado |
|---|---|---|---|---|---|---|
| 05/10 18:30 | BUY | SWEEP_RECLAIM | 15,6 | 1,90 | 0,53 | space insuficiente; preço máx. 4140,13 < entrada 4141,31 |
| 06/10 03:40 | SELL | SWEEP_RECLAIM | 14,0 | 3,52 | 0,25 | risco e space; preço mín. 4135,96 > entrada 4135,68 (a 0,28 da entrada) |
| 06/10 04:03 | BUY | BREAK_RETEST | 54,2 | 3,22 | 0,36 | `INVALIDATION_TOO_FAR`; ask máx. 4147,97 < 4151,60 |
| 06/10 05:25 | BUY | SWEEP_RECLAIM | 45,3 | 1,18 | 0,09 | `SPACE_INSUFFICIENT`; ask máx. 4128,66 < 4130,76 |

- **4/4 falham em `space_ratio`**; 2/4 também em `risk_norm`. Em nenhum o preço cruzou a entrada planejada, por isso `CanEnter` nunca rodou.
- `PULLBACK_REJECTION`, o setup principal, **nunca** gerou candidato em 616 barras, apesar de 148 barras com contexto PULLBACK.
- Só 2 dos 4 candidatos geraram evento `SETUP_NOT_ARMED`; os outros 2 pertencem a build sem esse log (ver procedência acima).

## 4. Causas prováveis (hipóteses ordenadas — não verificadas em backtest)

1. **Gate `space_ratio ≥ 0,7` mal calibrado para o desenho do setup.** `spaceRatio = distância até o próximo major swing oposto ÷ distância da invalidação`. A invalidação fica atrás de varrida/zona (1,2–3,5 × pa_scale) e o obstáculo é qualquer major high/low próximo; o quociente sai estruturalmente baixo (0,09–0,53 observado). O gate mede uma relação "risco:espaço" mesmo com `InpStopLossEnable=false` (não há SL real; o alvo é monetário de US$ 5–10), então o filtro descreve um risco que o EA não assume.
2. **Zona de pullback muito estreita e ancorada no último swing já confirmado.** Zona = âncora ± 0,3×pa_scale (≈ 2,3 pontos). A âncora é `majorLows[0]`/`majorHighs[0]`, que só existe após 2 barras de confirmação; o primeiro repique no fundo do pullback não toca nada. O setup só dispara em reteste de um fundo já confirmado. Isso explica 0 `PULLBACK_REJECTION`.
3. **Candle de rejeição + toque de zona simultâneos na barra[1]** (pavio ≥35%, fechamento ≥55% do range, corpo ≥20%): baixa frequência combinada. Não consegui medir com precisão porque o CSV não grava OHLC da barra. Uma reconstrução aproximada pelo bid dos heartbeats (amostra de 5 s subestima o range real) achou 7 barras que *pareciam* válidas e o EA registrou 0 — não é evidência de bug, e sim de que **falta OHLC na telemetria**.
4. **Gatilho exige cruzar `high/low da barra[1] ± buffer` dentro da própria barra seguinte** e o candidato é descartado na barra após. Em 3 dos 4 casos o preço ficou longe; em 1 (SELL 03:40) ficou a 0,28.
5. **Operacional:** 26 reinícios em 5 dias (recompilações, troca de magic/instância, fechamento do terminal) fragmentam a leitura de estrutura (o EA recalcula o histórico no INIT, mas perde o candidato corrente) e impedem uma amostra contínua. Algo trading ficou desligado no terminal de 03/10 a 04/10 (local).

## 5. Riscos observados na configuração (não relacionados ao "não opera", mas relevantes quando operar)

- `InpStopLossEnable=false`, `InpEmergencyLossEnable=false`, `InpMaxLossMoneyEnable=false`: ao abrir, a posição ficará **sem SL real e sem emergência**, protegida só por invalidação virtual/trailing do EA. Isso contraria a regra do projeto (stop virtual não protege se o terminal/VPS cair; `Abnormal termination` aconteceu 12 vezes em 5 dias).
- Conta com saldo ≈ US$ 12.100; lote fixo 0,01 (risco monetário real = f(invalidação), registrado no CORE só depois do candidato).
- `daily_target`/`daily_loss_limit` nos CSVs mostram 15/20, diferente do default do código (20/20), o que indica preset customizado; os flags de enable não são logados.

## 6. O que NÃO foi possível verificar

- Se o botão "Algo Trading" do gráfico/EA estava ativo durante as barras com candidato (não logado).
- Se o `.ex5` rodando corresponde ao `.mq5` analisado (mtime copiado; sem versão/hash nos logs).
- Frequência real de rejeição/zona (sem OHLC no CSV); nenhum backtest foi executado.
- Nenhuma alteração de código foi feita.

## 7. Próximos passos sugeridos (aguardando decisão)

1. **Telemetria (sem mudar lógica):** gravar cabeçalho (corrigir `EnsureHeader` para checar tamanho ≤ 2 ou usar `FILE_ANSI`/`FILE_TXT`), versão + hash no INIT, `TERMINAL_TRADE_ALLOWED/MQL_TRADE_ALLOWED/ACCOUNT_TRADE_ALLOWED`, OHLC da barra[1] e flags de cada condição (`zone_touch`, `rejection`, `prior_break`, `sweep`) no PRICEACTION, motivo de "sem candidato", todos os parâmetros efetivos no INIT, `event_id` preenchido, e heartbeat só quando o estado mudar ou a cada ≥60 s.
2. **Diagnóstico de funil por backtest** (M5 XAUUSD, modelagem tick real, ≥ 3 meses): contar barras → tendência válida → setup → armado → cruzou entrada → ordem, por setup, antes de tocar em parâmetros.
3. **Decisões de projeto para você escolher** (cada uma muda o comportamento e precisa ser testada fora da amostra): redefinir o gate de espaço quando não há SL real; ampliar/ancorar a zona no swing provisório; separar "armado" de "elegível".
4. Organizar os CSVs em subpasta `PieceTrend\` (EA hoje grava na raiz de `MQL5\Files`; 12 arquivos, 36,9 MB).
