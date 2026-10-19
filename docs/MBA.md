# MarketBehaviorAnalyzer (MBA) — coletor de pesquisa v1.23

Não negocia. Coleta observações de mercado (candles, eventos, forward, ticks, calendário) para estudo estatístico.
Código: `MQL5/Experts/MarketBehaviorAnalyzer/` (EA + `MBA_Core.mqh`) e `MQL5/Scripts/MarketBehaviorAnalyzer/` (histórico).
Backup da v1.00: `MQL5/Experts/MarketBehaviorAnalyzer/_backup_v1.00/`.

## Correções da v1.10 (origem: relatório `RELATORIO-MBA-XAUUSD-2026-10-06.md`)

| Problema na v1.00 | Evidência | Correção |
|---|---|---|
| FORWARD reescrito a cada segundo (`OnTimer` → `UpdateForwardQueue`) | 2,6 mi linhas → 35 mil únicas no M1 (98,7%); H1 100% | Escrito **uma vez**, quando o candle do horizonte fecha |
| Agregado de tick M1 gravado 2× (live + CopyTicks) | 7.063 linhas p/ 3.531 candles (50%) | Uma linha por candle (CopyTicks) |
| Notícias regravadas a cada restart | 28 de 183 duplicadas | Dedup persistente (lê o CSV ao iniciar) |
| Restart/queda perdia candles | gaps de 9, 48 e 64 min | Retoma do último candle gravado e preenche do histórico do servidor (`BACKFILL_SERVER`) |
| MTF usava o candle em formação | `mtf_M5 BREAK_UP` = 74% alta | MTF só com barras **fechadas antes da abertura** do evento (`mtf_basis`) |
| `structure_state` incluía o próprio candle | `BREAK_UP` = 100% alta | Separado: `structure_before` (conhecido antes) e `structure_at_close` (resultado) |
| `tick_density_ratio` = ticks / média de **tick_volume** (unidades diferentes) | outliers 176× | Ticks / média de ticks das barras anteriores; vazio quando indisponível |
| Fuso fixo (−3 h) | quebra no fim do horário de verão | `server_utc_offset_sec` por linha; `analysis_time` = UTC real |
| Dois terminais/corretoras na mesma pasta de símbolo | `XAUUSD` e `XAUUSD.r` misturados sem corretora | Pasta `root\<corretora>\<símbolo>\LIVE`; `broker` e `server` em toda linha |
| Calendário sem importância/moeda/nome/valores | `impact=NA`, valores vazios | Importância, moeda, país, nome; filtro por moeda (`USD`) e importância ≥ 2 |
| DOM saturado (total constante 38.600) ocupando disco | 25 MB × 12 partes em 1,5 dia | `InpWriteDOM=false` por padrão; throttle de 1 s; níveis opcionais |

## Identidade determinística

```
event_key   = broker | symbol | timeframe | bar_time_server | data_source(LIVE|HISTORY)
forward_key = event_key | horizon_bars
```
`run_id` é só auditoria e **nunca** entra na chave. O mesmo evento não pode virar nova observação.
`data_source` = `LIVE` (EA, inclusive back-fill do servidor) ou `HISTORY` (script). Os dois não se misturam: o script grava em `HISTORY\<run>`.

## Contexto × resultado (anti look-ahead)

- **Conhecido antes do evento:** `structure_before`, `mtf_*` (barras fechadas antes da abertura), distâncias a níveis (dia anterior, sessão, swing, abertura diária/semanal/mensal), `news_*` (agenda).
- **Descreve o próprio candle (resultado do evento):** `direction`, `body_pct`, `range_atr`, `volume_ratio`, `tick_*`, `spread_*`, `pattern`, `structure_at_close`.
- **Depois do evento:** somente em FORWARD.

`mfe_points`/`mae_points` são relativos à **direção do candle do evento** (`mfe_mae_basis=EVENT_CANDLE_DIRECTION`); `future_return_points` é bruto (1 ponto = tick de preço do símbolo, ouro 0,01).

## Novas colunas úteis

`slot_hhmm` (HH:MM em UTC), `week_start` (segunda-feira da semana: bloco independente), `gap_bars`, `utc_basis`, `tick_data_ok`,
`prev_day_high/low_distance_atr`, `session_high/low_distance_atr`, `swing_high/low_distance_atr`, `news_events_60m`, `news_high_events_60m`,
`news_min_to_next_high`, `news_min_since_last_high`, `schema_version`.

## META/symbol_spec

Uma linha por run: corretora, servidor, moeda, alavancagem, especificação do contrato (tick size/value, volume, stops level, swap, modos), offset UTC, build do terminal, comissão **declarada** pelo usuário (`InpCommissionPerLotDeclared`, 0 = desconhecida). Necessário para registrar custos (CLAUDE.md, Backtest).

## Compatibilidade

Cabeçalhos mudaram (schema 2). O gravador **abre uma nova parte** (`_partNNN`) quando o cabeçalho da última parte difere, então arquivos v1.00 e v2 podem conviver na mesma pasta, cada parte com seu cabeçalho. Ao ler, use um loader por parte. Os dados v1.00 ficam na pasta antiga (sem `<corretora>`).

Limpar dados antigos (não altera os originais):
```
python tools/mba/mba_dedupe.py --root "<Common>/Files/MarketBehaviorAnalyzer" --symbol XAUUSD --out clean
```

## Histórico inicial feito pelo próprio EA

Na primeira execução (sem CSV v2 para aquele timeframe) o EA monta `InpInitialBackfillDays` dias (padrão 30; 0 desliga) a partir do histórico do servidor e depois segue ao vivo. O trabalho é feito em lotes de até `InpBackfillBudgetMs` (700 ms) por segundo, um candle por timeframe por vez, então o gráfico não trava; M1 de 30 dias leva alguns minutos ou mais. Linhas ficam com `source=BACKFILL_SERVER`; `tick_data_ok=FALSE` quando o servidor não tem ticks daquele período. Mais de 30 dias: aumentar o input (limitado pelo histórico que a corretora guarda) ou usar o script `MarketBehaviorAnalyzer_History` (pasta `HISTORY\<run>`, nunca misturada com `LIVE`).

## Histórico do calendário (v1.11)

Ao iniciar, se `InpInitialBackfillDays` > 0, o EA grava no CSV de notícias os valores do calendário dos últimos `InpInitialBackfillDays + 2` dias (moeda `InpNewsCurrencies`, importância >= `InpNewsMinImportance`) com `source=CALENDAR_BACKFILL`. Isso permite estudar surpresa (actual x forecast) e a reação do preço.

- Chave de deduplicação: `calendar_value_id | revision | actual_value` (exatamente como gravado). Reiniciar não repete linhas; uma revisão ou um actual novo gera linha nova. A v1.10 comparava o actual bruto com o texto do CSV e **não deduplicava entre reinícios**; corrigido.
- `CALENDAR_BACKFILL` = valores como o servidor os tem **agora** (podem incluir revisões posteriores à divulgação). `CALENDAR` = capturado ao vivo.
- Cada execução registra uma linha `INFO:CalendarBackfill` em `LOGS/errors` com quantas linhas foram gravadas (não é erro).
- Candles e ticks só são reconstruídos do servidor numa **primeira** execução (sem CSV v2). Se já existe CSV, o EA só preenche lacunas até o presente. Para ampliar o histórico de candles, use outra pasta de saída ou o script `MarketBehaviorAnalyzer_History`.

## v1.20 - historico maximo (padrao do EA, sem preset)

Padrao: `InpBackfillMaxHistory=true`. Na primeira execucao (sem CSV v2) o EA procura, por timeframe, o candle mais antigo que o terminal consegue fornecer: limitado pela primeira data do servidor, pelo `Max bars in chart` do terminal e por `InpBackfillMaxDays` (3650). Espera ate `InpBackfillSyncWaitSec` (120 s) o terminal baixar o historico e registra em `LOGS/errors` uma linha `INFO:BackfillStart` por timeframe (primeiro candle, barras locais, `max_bars_in_chart`, `limited_by_max_bars`).

- **Limite do M1:** `Max bars in chart` = 100000 nos dois terminais (FP e IC) = ~72 pregoes de M1. Para M1 mais antigo: Ferramentas > Opcoes > Graficos > Maximo de barras no grafico = Ilimitado e reiniciar o terminal. M5 chega a ~1 ano, M15 a ~3 anos com 100000.
- **Ticks:** so sao reconstruidos (tick_count, spread, imbalance) para candles de ate `InpTickHistoryDays` (120) dias; mais antigos saem com `tick_data_ok=FALSE`. Evita baixar anos de ticks.
- **Calendario:** `InpNewsHistoryDays` (1095) dias.
- **Disco:** estimativa ~700 MB por ano de M1 por feed (forward M1 e o maior). Candles/events/forward de timeframes maiores sao pequenos.
- Com CSV ja existente o EA nao volta mais no tempo: arquive a pasta `LIVE` e reinicie.

### v1.21 - profundidade por timeframe

`InpDaysM1` 1000 (~jan/2024), `InpDaysM5` 520, `InpDaysM15` 1000, `InpDaysM30` 1000, `InpDaysH1` 2000, `InpDaysH4/W1/MN1` 3650 (todos limitados por `InpBackfillMaxDays` e pelo `Max bars in chart` do terminal). Para M1 de 1000 dias o terminal precisa de `Max bars in chart` >= ~1.000.000 (Ilimitado). Estimativa: ~1 milhao de candles M1 por feed, ~2,7 GB por feed com events/forward/ticks.

## v1.12 - retomada sem regravar candles

Bug da 1.10/1.11: ao iniciar com a serie do terminal ainda desatualizada (apos o terminal ficar offline), o EA ignorava o ultimo candle gravado e retomava do candle desatualizado, regravando candles ja existentes (FP, run de 06/10: 1.275 candles M1 duplicados, 1,4%). Corrigido: a retomada usa sempre o ultimo candle do CSV; so avanca quando o terminal tem candle mais novo.

Dados limpos (originais intactos): `Common\Files\MarketBehaviorAnalyzer_CLEAN\<corretora>\<simbolo>\LIVE` via `tools/mba/mba_dedupe.py`. Duplicatas de noticias (87 FP / 65 IC) eram todas `CALENDAR` x `CALENDAR` de reinicios da v1.10; o backfill da 1.11 nao duplicou. Noticias limpas: 416 linhas, 248 com actual e forecast (12 semanas).

## Presets

No projeto: `MQL5/Experts/MarketBehaviorAnalyzer/presets/MarketBehaviorAnalyzer_EA.set` e `MQL5/Scripts/MarketBehaviorAnalyzer/presets/MarketBehaviorAnalyzer_History.set`.
No terminal o MT5 lê de `<pasta de dados>\MQL5\Presets` (MT5: Arquivo > Abrir pasta de dados). Copie o `.set` para lá; na janela do EA, aba Entradas > Carregar, cole o caminho completo no campo Nome do arquivo.

## Pesquisa por horário — dois estudos diferentes

- `MINUTE_OF_HOUR` (todo `:13`): ~1 observação por hora de negociação → N cresce rápido (≈58 em 3 dias).
- `EXACT_TIME` (`09:13`): 1 observação por dia → ≈3 em 3 dias, ≈60 em 12 semanas, ≈200 em ~40 semanas.

Use `slot_hhmm` (exato) ou `minute` (minuto da hora) conforme a pergunta. Cada descoberta deve informar N, taxa-base, taxa condicional, delta, IC de Wilson, p, correção de múltiplos testes e estabilidade por `week_start`.
`BEHAVIOR_TYPE` sugerido para classificar achados: DIRECTIONAL, ACTIVITY, VOLATILITY, RANGE, LIQUIDITY_PROXY, SEQUENCE, STRUCTURAL, MTF, REVERSAL, CONTINUATION.

## Não verificado em execução

Compilado com 0 erros e 0 avisos (MetaEditor). **Não foi executado em terminal**. Conferir no primeiro run: pasta `<corretora>`, `META/symbol_spec`, forward com `forward_key` único, uma linha de tick agregado por candle, news com importância, preenchimento (`BACKFILL_SERVER`) após reiniciar, e que `CalendarValueHistory` filtra por moeda na corretora usada.

## v1.23 — integridade da coleta (schema 3)

Origem: auditoria externa (`Melhorias-no-MBA.pdf`) conferida linha a linha no código. Só entrou o que procedeu.

| Problema na v1.22 | Correção na v1.23 |
|---|---|
| `ProcessBar` avançava o cursor (`g_last_bar`) quando `CopyRates` falhava: o candle nunca era retentado | O cursor só avança **depois** de o candle estar gravado. Falha → retentativa (`InpMaxBarRetries`=5, `InpRetryDelayMs`). Estourou o limite → `CRITICAL:BarSkipped` em `LOGS/errors` e `bars_skipped` em `META/data_quality`. O backfill inicial (`g_bf_first`) também não é mais descartado numa falha (antes pulava o histórico inteiro para o live). Linhas de tick/evento/forward só são escritas após o candle, então a retentativa não duplica |
| RAW_TICKS via `OnTick` perdia ticks (eventos NewTick são fundidos) | Captura por `CopyTicksRange` com cursor persistente (último `time_msc` do arquivo + nº de ticks no mesmo ms). Primeira execução faz backfill de `InpRawTickBackfillDays` (14). `OnTick` virou só gatilho (250 ms). `source` = `CAPTURE_RANGE` / `BACKFILL_RANGE`. Dados antigos `LIVE_CAPTURE` continuam no mesmo arquivo e são **incompletos** |
| UTC do backfill usava o offset atual (1 h errada no inverno) | `InpDstMode`: AUTO (regra NY-close se a corretora está em +2/+3 e bate com a regra hoje), `US_NY_CLOSE`, `FIXED_CURRENT`, `FIXED_INPUT`. `utc_basis` = `RULE_NY_CLOSE_US_DST`; o `server_time` original continua gravado. Notícias também usam a regra da data do evento. Exness (UTC+0) cai em `FIXED_CURRENT`. Linhas ao vivo são comparadas com o relógio do servidor (`dst_rule_mismatch`) |
| MAE podia sair positivo/negativo conforme o caso | `mfe_points` e `mae_points` **sempre ≥ 0** (distância a partir do fechamento do evento, relativa à direção do candle). Novos `max_up_points` / `max_down_points` (independentes de direção). `time_to_*` = -1 quando a excursão não ocorreu. Doji: `DOJI_SYMMETRIC` |
| Forward só até 10 candles | Novo `FORWARD_TIME` (ver abaixo); o `FORWARD` por barras continua |
| Sem D1 | D1 incluído (`InpDaysD1`, coluna `mtf_D1`). M2…H12 **não** foram adicionados: são derivados do M1 e só multiplicariam disco |
| `tick_data_ok` = “≥1 tick” | Agregado de ticks ganhou `max_tick_interval_ms`, `first_tick_offset_ms`, `last_tick_to_end_ms`, `bid/ask_first/last` |
| Nada provava que o candle da corretora = ticks | Colunas `ohlc_vs_ticks` (OK/DIFF/NA) e `ohlc_dev_points` por candle (só gráfico em Bid; tolerância `InpOhlcTolerancePoints`). Novo `bar_spread_points` (spread gravado pelo servidor) |

### FORWARD_TIME (horizontes por tempo)
Para eventos de timeframes até H4 (`InpTimeFwdMaxTFSec`=14400), medido em barras **M1** a partir do fechamento do evento. Horizontes em `InpTimeHorizonsMin` (padrão 1,3,5,10,15,30,60,120,240). Linha escrita quando o maior horizonte fecha (atraso de até 4 h; cursor = último `event_time` do arquivo, então reinício e backfill funcionam).
Colunas: `ret`, `max_up/down`, `mfe/mae` (positivos), `time_to_mfe/mae_min`, `m1_bars_found/expected/complete`, `event_spread_points`, `cost_points` (spread + comissão declarada convertida em pontos), `net_return_dir_points`, e tempo até o primeiro toque (`hit_up/dn_a050/a100/a200_min` = 0,5/1/2 ATR; `hit_up/dn_p1..p3_min` = alvos absolutos `InpTimeFwdTargetP1..3`, padrão 100/200/300 pontos; vazio = não tocou no horizonte). Resolução do toque = 1 minuto (fim da barra M1); toque de alvo de alta e de baixa no mesmo minuto é ambíguo. “Alvo antes do stop” = comparar os dois tempos.
Limitações: horizonte em tempo de relógio (fechamento de mercado dentro da janela reduz `m1_bars_found`; filtrar por `complete`); eventos mais antigos que o M1 do terminal são pulados (`tfwd_skipped_no_m1`).

### META/data_quality
Uma linha por série a cada `InpQualityIntervalSec` (300 s) e no encerramento: barras esperadas (`Bars()` entre a primeira e a última desta execução) × candles gravados, `missing_vs_terminal`, retentativas, barras puladas, falhas de escrita, ticks ok/ausentes, conferência OHLC×ticks (qtd, divergentes, desvio máximo), gaps, `dst_rule_mismatch`, e para RAW_TICKS: linhas gravadas, cursor, atraso e erros. `status`: OK / CHECK / NO_BARS_THIS_RUN / WAITING_HISTORY.

### Auditoria externa
`python tools/mba/mba_audit.py --live "<Common>/Files/MarketBehaviorAnalyzer/<corretora>/<símbolo>/LIVE"` (somente leitura): duplicatas, gaps, OHLC incoerente, UTC×regra, agregado×candle, FORWARD_TIME, último `data_quality`, tempo de RAW_TICKS.

### Atualizando da v1.22
O cabeçalho mudou (schema 3). O gravador abre partes novas, **mas** a retomada só enxerga partes com o cabeçalho atual, então a v1.23 refaz todo o histórico. Antes do primeiro run: mover a pasta `LIVE` antiga (ex.: `LIVE_v2_arquivo`). O script History usa pasta própria por execução. Parâmetro novo do script: `InpDstMode` substitui `InpUtcRule`.
Disco: FORWARD_TIME de M1 é o maior arquivo novo (até 9 linhas por evento M1); desligue com `InpWriteTimeForward=false` ou reduza `InpTimeHorizonsMin`.

### Não verificado em execução
Compilado com 0 erros e 0 avisos nos três terminais (IC, FP, Exness). **Não foi executado em terminal.** Conferir no primeiro run: `LOGS/errors` (`INFO:UtcMode`, `WARN:SchemaChange`, `INFO:RawTickStart`), `META/data_quality` sem `CHECK`, `ohlc_vs_ticks` majoritariamente OK, RAW_TICKS crescendo com `source=CAPTURE_RANGE`, FORWARD_TIME com `complete=TRUE`, e rodar `mba_audit.py`. A regra de DST é por dia (correta para barras de mercado, que reabrem após a troca).

### v1.23.1 — M1 incompleto (bug do teto de catch-up)
`CatchUpOne` limitava o passo a `InpMaxCatchupBars` (200000): quando faltavam mais barras que isso, o EA pulava para a barra 200000 contando de hoje e **descartava o resto do histórico**. No M1 (1000 dias ≈ 1 milhão de barras) isso deixava só 200.001 candles (a partir de ~mar/2026) em vários símbolos. **Não era limite da corretora**: o terminal tem M1 desde 2021 (o FORWARD_TIME lê M1 direto do terminal e achou 60 barras por hora em 2021). Corrigido: sempre processa a próxima barra. Para recuperar o M1: parar o EA, mover a pasta `CANDLES/EVENTS/FORWARD/FORWARD_TIME/TICKS` do M1 (ou a pasta `LIVE` inteira) e reiniciar; o M1 de 1000 dias leva horas por símbolo e ~700 MB por ano.

### Ferramentas de pesquisa (tools/mba)
- `mba_audit.py` — auditoria estrutural de uma pasta LIVE.
- `mba_mine.py` — minerador simples (descoberta/validação/placebo/BH).
- `mba_report.py` — relatório completo por ativo (descritivo + mineração `ret`/`hit`/`open`, custo por spread de ticks por slot de NY, vantagem contra a média, famílias deduplicadas). Saída em `docs/relatorios/mba/ativos/<ATIVO>/`.
- `mba_consolidate.py` — comparativo entre ativos: `docs/relatorios/RELATORIO-MBA-8-PARES-2026-10-16.md`.
- Estudo de alcance (primeira passagem por barra, BUY/SELL executáveis, minuto a minuto): `mba_reach_load.py` → `mba_reach.py` → `mba_reach_analyze.py` / `mba_reach_struct.py` → `mba_reach_summary.py` → `mba_reach_report.py`. Relatório: `docs/relatorios/INVESTIGACAO-ALCANCE-HORARIO-MBA-2026-10-17.md`; saídas por ativo em `docs/relatorios/mba/reach/<ATIVO>/`.

Armadilhas aprendidas: (1) `rates.spread` histórico é 0 em contas ECN e menor que o spread real; usar o spread medido nos ticks. (2) `atr`/`range` dos candles são gravados com 2 casas (0.00 em FX de 5 dígitos): recalcular do OHLC. (3) Para vender com barras de Bid o custo é o spread da SAÍDA; cobrar o da entrada gera falsos lucros na rolagem. (4) Testar contra a média de todas as velas, senão a tendência do ativo vira "padrão". (5) Sinais condicionais: nunca tirar média por dia — o número de sinais no dia depende do futuro (vaza resultado); usar média por entrada com erro agrupado por dia. (6) Barras de Bid entre 23:00 e 01:15 do servidor geram "padrões" de rolagem; excluir ou usar ask dos ticks.
