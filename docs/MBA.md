# MarketBehaviorAnalyzer (MBA) — coletor de pesquisa v1.10

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
