# Relatório de Análise — Nexus Matrix / Nexus Guard Pro (XAUUSD M1/M5) — 2026-10-06

Escopo: leitura do código das 3 versões + varredura dos CSVs `NEXUS_*_S6_*` (Matrix no terminal `010E…`, Guard no terminal `5194…\NEXUS_GUARD_PRO_TEL6`) + legados.
Decisões do operador registradas: **notícias externas serão abandonadas**; **stop-loss é opcional no operacional** (tratado aqui como decisão, não como bug); **painel precisa de design system PRO**.

Convenção: **[F]** fato medido no CSV/código · **[I]** inferência · **[H]** hipótese não verificada.

## 1. Veredito

1. As três versões compartilham o mesmo motor de sinal. `Matrix R6.4.1` → `FIX1` só acrescenta telemetria TEL6 (diff sem nenhuma linha de lógica de estratégia). `Guard 1.076` = FIX1 + solvers monetários por `OrderCalcProfit`, modo *Runner*, escopo do guard de equity, notícias externas e CSVs extras. **[F]**
2. A base unificada deve ser o **Guard 1.076 sem o módulo de notícias externas** (§7).
3. **Não há evidência de edge.** São 29 trades Matrix + 8 Guard, 7 dias, só XAUUSD, só demo, dois perfis de configuração diferentes e nenhum backtest. O que os dados mostram é um perfil de **ganho pequeno e frequente com cauda de perda grande**, e a cauda apareceu (§3).
4. Dois bugs reais com evidência nos dados: **fechamentos manuais não entram nas estatísticas/limites diários** e **o cooldown não funciona**. Há também um problema de volume de telemetria (82% dos bytes vêm de uma única tabela).

## 2. Inventário e integridade dos CSVs

| Item | Achado | Classe |
|---|---|---|
| Volume | Matrix S6: ~1,07 GB (PROFIT_MANAGEMENT 857 MB = 80%). Guard S6: ~0,37 GB (PROFIT_MANAGEMENT 232 MB). Legados (Audit/Candles/Journal) somam mais ~0,6 GB e duplicam o TEL6 | Telemetria ruidosa |
| Schema | 1 único cabeçalho por assunto, 0 linhas com nº de colunas errado, 0 `EventID` duplicado | OK |
| `SequenceNumber` | "Gaps" por arquivo são esperados: a sequência é global entre assuntos | Esperado |
| Ambiente | 100% `TERMINAL`/`DEMO` (ICMarketsSC-Demo). Zero dados de Strategy Tester | Fato |
| Timezone | `TimestampServer` = UTC+3 (ex.: UTC 00:19 → server 03:19) | Fato |
| `TimestampUTC_Msc` | Segundo×1000, não é milissegundo real (o código já documenta) | Cosmético |
| `DurationSeconds` | **0 em todos os 28 `POSITION_CLOSED`** (posição já fechada quando o log é montado) | **Bug de telemetria** |
| Contas misturadas | 24/09 18:11–19:20, run `318D8214`: balance 322–329 vs 11.9k nas outras. Conta/saldo diferente no mesmo conjunto | Dado a separar |
| Configs misturadas | 11 runs Matrix e 3 Guard com parâmetros diferentes (§3). Sem separar por `StrategyConfigHash`, qualquer média mistura perfis | Dado a separar |
| Procedência | Matrix e Guard rodaram em contas distintas (saldo ~11.9k vs ~99k; comissão −0,04 vs 0,00) | Fato |

Fechamento ausente na telemetria: posição `1955379906` (Matrix) e `403330468` (Guard) terminam a 23/09 ~19:43 sem `POSITION_CLOSED`. O saldo cai 11 934,18 → 11 876,90 (−57,28) e `DailyNet`/`TradesToday`/`ConsecutiveLosses` **não mudam** depois. **[F]** Isso é coerente com fechamento manual (deal com magic 0). **[I]** Confirmar na aba Histórico do MT5.

## 3. Desempenho (fatos, sem extrapolar)

### Perfis efetivamente rodados (Matrix)

| | Perfil A (M1, 21–24/09) | Perfil B (M5, 25–30/09) |
|---|---|---|
| Lote | fixo 0,01 | % risco (0,25%) |
| Stop | `STOP_MONEY` **$150**, proteção **atrasada** 15 min | estrutura limitada a **$15**, proteção atrasada 30 min |
| Alvo / trailing | TP $5 → trailing ativa $4, lock $3,5 | TP $5 → trailing ativa $4,5, lock $4 |
| Cap de risco | OFF | `PLANNED_STOP` |
| TimeStop | desligado | ligado |
| Meta diária | $15 | desligada |

### Resultado realizado (Matrix S6)

| | n | Soma | Média | Pior MAE | MAE mediana | Duração mediana / máx |
|---|---|---|---|---|---|---|
| M1 (perfil A) | 16 | +65,43 | +4,09 | **−62,21** | −3,42 | 26 min / **933 min** |
| M5 (perfil B) | 12 | +51,21 | +4,27 | −45,88 | −4,61 | 6 min / 63 min |
| Posição fechada manualmente (A) | 1 | **−57,28** | — | −65,84 | — | ~11 h |

- **Perfil A inclui a perda manual: 16 ganhos (+65,43) e 1 perda (−57,28) = +8,15 em 17 trades, PF 1,14.** Uma única perda apagou 87% do lucro. Win-rate de equilíbrio com perda de ~$57 e ganho médio $4,09 = **93,3%**; observado 16/17 = 94,1%, folga estatisticamente nula com n=17. **[F]**
- 28/28 trades registrados no TEL6 são positivos porque a perda **não está no TEL6** (§4-C1) e porque o perfil só realiza ganhos pequenos e segura o resto.
- Guard (conta ~99k): 8 trades, 6 ganhos de +$3,50, perdas de −$12,84 (fechada pelo EA, `DELAYED_STOP_ALREADY_BREACHED`) e −$2,65. Posição `403330468` ficou **2,5 dias aberta, pior flutuante −$107** em 0,01 lote, até o fechamento manual de 23/09. **[F]**
- Perfil B: planejado $15 por trade, mas MAE real chegou a **−$45,88 (3,1×)** e −$23,24 (1,5×) porque o stop só liga depois de 30 min negativo. Limite `HardMax 0,5%` = ~$60 não foi violado, mas também não foi o que protegeu. **[F]**
- Slippage de entrada: média +0,045 (máx +0,32) no Matrix; +0,018 no Guard. Modify de SL/TP: 7 de 63 rejeitados (5× `10029` congelado, 2× `10036` posição já fechada). **[F]**
- Concentração: 13 de 28 trades fecharam entre 00:00–05:59 server (49% do lucro); BUY 16 / SELL 12. **[F]** — amostra pequena, não é regra.
- Funil (Matrix, 2 066 decisões): 192 `SWEEP_DETECTED` → 29 ordens aceitas (15%). Perdas do funil: `SETUP_INVALIDATED` 76, `NO_STRUCTURE_SHIFT` 70, `RETEST_EXPIRED` 21, `SCORE_TOO_LOW` 11, `EVENT_SHOCK` 8, `NEWS_BLACKOUT` 47. Spread bloqueou 1 vez (Guard). **[F]**
- Contrafactual (`OPPORTUNITY_OUTCOME`, 31 oportunidades Matrix): 15 `TARGET_BEFORE_STOP`, 3 `STOP_BEFORE_TARGET`, 13 `NEITHER`. Com alvo de $5 e stop de $150 o contrafactual é quase tautológico; **não** valida o setup. **[I]**

### O que isto significa
O sistema em perfil A é uma **venda de opção implícita**: colhe $3–5 por trade e carrega uma posição contrária por horas/dias quando erra. Como o operacional é sem stop (decisão sua), a proteção real passa a ser o **disjuntor de perda flutuante**, que hoje **não existe** (§4-C4).

## 4. Achados no código (Guard 1.076 / FIX1; linhas de `fix1.mq5` quando útil)

### Alto
- **C1 — Fechamento manual/externo é invisível ao motor de risco.** `CalculateHistoryStats` (L3380) e `OnTradeTransaction` (L5117) filtram por `DEAL_MAGIC`. Fechamento manual no terminal grava deal sem magic → fora de `DailyNet`, `TradesToday`, `ConsecutiveLosses`, `MAX_DAILY_LOSS`. Evidência no §2. Correção: classificar o deal pela posição (`DEAL_POSITION_ID` → deal de entrada com magic Nexus), não pelo deal de saída.
- **C2 — Cooldown não funciona.** `g_last_trade_bar` só é gravado após `OrderSend` (L3677). `RejectCandidate` (L2906) entra em `ST_COOLDOWN` sem gravar nada; `ProcessNewBar` (L4911) mede a idade desde o último trade e libera na mesma barra. Além disso conta da barra de **abertura**, não do fechamento. Nenhuma linha `COOLDOWN` aparece em 2 066 decisões. **[F]**
- **C3 — Sem disjuntor de perda flutuante.** Com stop opcional, nada limita a perda aberta: `MAX_DAILY_LOSS` usa equity mas só bloqueia **novas entradas** (L4897, L3503) e não fecha nada. Pior flutuante observado: −$107 (Guard), −$65,84 e −$62,21 (Matrix) em 0,01 lote. Proposta: gatilho opcional, em dinheiro, por posição e por conta (pausar / fechar tudo), independente do stop.

### Médio
- **C4 — Risco planejado ≠ risco realizado com proteção atrasada.** `HardRiskEnforcedAtEntry` (L714) trata o stop planejado como garantia mesmo sem SL no broker; o painel mostra "SL REF". Mostrar e registrar `risco_efetivo_sem_stop` (MAE em tempo real vs planejado).
- **C5 — `MinimumExpectedR` é ignorado em `MONEY_THEN_TRAILING`** (L3242). Intencional (comentário), mas resulta em R esperado de 0,033 (5/150) no perfil A sem nenhum alerta. Registrar `expected_r` e exigir confirmação explícita do perfil de cauda.
- **C6 — Baseline diário não detecta depósito/saque/troca de saldo.** Run `318D8214`: `DAY_EQUITY` ~11,9k vs equity 622 → `DailyLossPercent` 94,8% e bloqueio `MAX_DAILY_LOSS` por 90 leituras. Falha segura, mas falso. Rebasear em `DEAL_TYPE_BALANCE` ou mudança brusca de saldo.
- **C7 — Telemetria `PROFIT_MANAGEMENT` grava a cada tick.** O hash de estado (L2088) inclui P/L a 2 casas → linha a cada variação. 1,31 M linhas / 857 MB para 29 trades (posição de 933 min = 557 897 linhas). Amostrar por tempo (ex.: 5 s) + delta ≥ $0,50 ou mudança de SL/TP/trail.
- **C8 — Spam de decisões bloqueadas.** `BlockFreshCandidate` (L2804) grava `GLOBAL_BLOCK` a cada chamada: Guard 28 280 linhas `CONFIG_INVALIDA` em 2,5 dias; Matrix 1 424 `DAILY_PROFIT_TARGET`. Gravar só em mudança de causa.
- **C9 — Config inválida bloqueia em silêncio.** Guard run de 21/09: runner com ativação $4,20 < piso $5,00 → `CONFIG_INVALIDA` por 2,5 dias. A validação funcionou (falha fechada), mas ninguém foi avisado. Usar `Alert()` + banner persistente + linha única no painel.
- **C10 — Desempenho.** `PositionNetEstimate` (L3870) faz `HistorySelectByPosition` e é chamada 2–3× por tick por posição (ManagePosition, MaybeWriteProfitState, WriteProfitManagement). `CheckNews` faz 4 chamadas ao calendário por barra. Cachear por tick/posição e por minuto.
- **C11 — Instâncias com o mesmo magic.** Default 62031061 em Matrix, Guard, M1 e M5. `HasOwnPositionForSymbol` (L3352) bloqueia por símbolo em todas as instâncias, então M1 e M5 do mesmo ativo competem entre si. **[H]** Definir "uma instância = uma unidade econômica" e documentar.

### Baixo
- `ProcessRetest` usa CLV 0,55/0,45 fixos (L2974) em vez de input. `DetectNewCandidate` (L2823) pega o **primeiro** nível qualificado, não o melhor. Slippage de saída chegou a −$0,92 sobre o lock em um trade M5.
- `TEL6WriteTradeLifecycle` não calcula duração no fechamento (§2).
- Rejeições de modify `10029/10036`: sem backoff/retry classificado.

## 5. Pontos positivos (aproveitar)

- Sinal em vela fechada, flags `CurrentOpenBarUsed=false`/`FutureDataUsed=false` gravadas em cada linha.
- Preflight completo: `OrderCheck`, margem projetada, modo de negociação, stops level, filling, deviation, drift de entrada.
- Spread adaptativo por percentil aprendido, com warm-up.
- Resultado sempre **líquido** (profit+swap+comissão+fee); `ClosedPositionNetResult` correto.
- Configuração fail-closed com mensagens claras; `RUN_CONFIG` com hashes de estratégia/telemetria/visual; BuildID.
- Schema 6 versionado, chaves por `RunID/OpportunityID/SignalID/IntentID`, claim atômico de deal (sem duplicata entre instâncias), rotação PART00N.
- Contrafactual com MFE/MAE por oportunidade (`OPPORTUNITY_OUTCOME`): melhor ativo de pesquisa do projeto.
- Guard: solvers de preço por dinheiro com busca binária sobre `OrderCalcProfit` e diagnóstico (mais robusto que o `PriceForMoney` de 1 tick), `ReconcileRunnerFromBrokerStop`, escopo de guard `NEXUS_MAGIC` (isola o P/L de outros EAs na conta).
- Persistência de estado por posição em `GlobalVariable` (sobrevive a troca de TF e reinício).

## 6. Painel — diagnóstico

Evidência de código (não vi screenshot; confirmar com print do seu terminal):
1. **Layout misto px/pt sem DPI.** Retângulos em pixel, fontes em pontos; nada usa `TERMINAL_SCREEN_DPI`. Em Windows com escala ≠100% o texto cresce e o box não. `SX()` escala posições e fonte pelo mesmo fator, mas a fonte não escala linearmente.
2. **Truncamento por estimativa errada.** `FitPanelText` (Guard) usa largura = `font*0,62` px/char; Consolas tem avanço de 0,55 em, ≈ `pt×1,33×0,55 = 0,73×pt` px. Subestima ~18% → texto passa da célula. No Matrix não há truncamento: `SPREAD_V` (x=80, ~54 chars) invade `NIVEL` (x=260).
3. **Âncora ausente.** Sem `OBJPROP_ANCHOR`; em canto direito/inferior o painel desloca.
4. **Coordenadas absolutas por linha** (y=62, 80, 96…): qualquer linha nova desalinha o resto; blocos `Block()` com altura manual.
5. **Redesenha tudo** (~60 objetos + `ChartRedraw`) a cada timer/transação.
6. Informação crítica só no tooltip (`LabelCell` empurra o texto cheio para o tooltip).

### Design system proposto (alinhado a `docs/PAINEL.md`)
- **Tokens**: grade de 8 px, escala tipográfica (título 10 / corpo 8 / legenda 7), papéis de cor (`ok`, `warn`, `danger`, `info`, `muted`) e raio/borda únicos.
- **Medição real** com `TextSetFont`/`TextGetSize` para truncar e para alinhar números à direita (âncora direita), nunca estimativa.
- **Fator DPI** = `TERMINAL_SCREEN_DPI/96`, aplicado a posição **e** fonte.
- **Grid de células** (cabeçalho · estado/decisão · risco · posição · gestão · telemetria) com altura derivada do conteúdo.
- **Faixa "POR QUE NÃO ESTÁ OPERANDO"** sempre no topo (motivo de bloqueio + próxima condição).
- **Bloco de risco para operação sem SL**: P/L flutuante, MAE da posição, tempo no negativo, distância ao disjuntor, meta/perda do dia.
- Atualização por diferença (só reescreve o objeto cujo texto mudou); botões estáveis na minimização.

## 7. Plano de unificação

**Base**: Guard Pro 1.076 (já tem TEL6, rotação, solvers, runner opcional, escopo de equity).

| Ação | Item |
|---|---|
| **Remover** | Todo o módulo de notícias externas: `NGP_*` (HTTP/JSON/XML/RSS), providers FED/BLS/BEA/GDELT/Kitco, `WebRequest`, `ExternalNews*`, `WriteNewsDecision/Intelligence`, CSVs `NEWS_*`, linhas de painel `ext news`. Manter o **calendário MQL5** (`CheckNews`) que já funciona |
| **Manter** | Motor de sinal, preflight, spread adaptativo, solvers monetários, trailing monetário, delayed protection (opcional), TEL6, `RUN_CONFIG`, contrafactual |
| **Manter, desligado por padrão** | Runner (`TARGET_MONEY_THEN_RUNNER`) e `EQUITY_GUARD_NEXUS_MAGIC`: **nenhum trade live os exercitou** (a run Guard com runner nunca operou por config inválida) |
| **Corrigir** | C1, C2, C6, C7, C8, C9, C10, duração do lifecycle, retry de modify |
| **Adicionar** | Disjuntor de perda flutuante (C3), `risco efetivo sem stop` (C4), alerta de config |
| **Desligar** | `InpTEL6WriteLegacyCSVs=false` (legado duplica TEL6 e custou ~0,6 GB) |
| **Redesenhar** | Painel (§6) |

Presets (parâmetros, sem mexer na lógica):
- **A — "Scalp sem SL"**: M1, lote fixo, TP/lock em $, proteção `NONE` ou `DELAYED`, **com disjuntor obrigatório**. Objetivo: alta taxa de acerto. Risco: cauda; ratio ganho/perda ~1:15 a 1:40.
- **B — "Risco controlado"**: M5, % risco, stop estrutural limitado por dinheiro, TimeStop ligado, proteção imediata. Objetivo: R positivo sem depender de win-rate extremo.

## 8. Organização dos CSVs (proposta, nada foi movido)

```
Nexus_Data/
  Matrix/<versão>/<YYYY-MM-DD>_<TF>_<RunID8>/   SIGNAL_DECISIONS, EXECUTION, TRADE_LIFECYCLE, RISK_STATE, RUN_CONFIG, OPPORTUNITY_*
  Guard/<versão>/...
  _heavy/PROFIT_MANAGEMENT, OBJECT_STATE, MOMENT_STATE, INTRABAR_TRACE   (pode ser arquivado/compactado)
  _legacy/Audit, Candles, Journal, Trades, Snapshot                      (descartáveis após a unificação)
  manifest.csv   arquivo;conta;run;config_hash;tf;linhas;MB;periodo
```
Os 3 diretórios `MQL5\Files` hoje misturam FluxMatrix, LFR, Lumera, GPA, MicroMomentum, PieceTrend etc. com o Nexus. A pasta fica **fora do OneDrive** (≈2 GB) e é recriada por script com `--dry-run` por padrão.

## 9. Não verificado / limites

- Confirmar fechamento manual de `1955379906` e `403330468` no Histórico.
- Nenhum backtest (Strategy Tester) existe; sem custos modelados além dos reais da demo.
- Nada foi compilado nesta análise. Nenhum `.mq5` foi alterado.
- Persistência do M1 vs M5 e "uma instância por símbolo" dependem de como você anexa os gráficos. **[H]**
- Perfil Runner e escopo `NEXUS_MAGIC` sem dados live.
- Não vi o painel renderizado; o §6 é leitura de código.

## 10. Falsificação sugerida para validar o perfil A

Rejeitar a tese "ganho pequeno/frequente é positivo" se, em ≥300 trades com custos reais e por regime, ocorrer qualquer um: expectativa líquida ≤ 0 incluindo a pior perda; win-rate observado < win-rate de equilíbrio + 3 desvios; pior MAE flutuante > 2× o disjuntor configurado; resultado dependente de < 3 dias.
