# AccelChain v1.00

Micro-scalper de **aceleração** para XAUUSD, com escada de 4–8 pernas. Arquivo: `AccelChain.mq5` (+ `Include/LZ/LZPanel.mqh`, já existente). EA **separado** do `ChainScalper`: outro motor de sinal, outra pasta, outro magic (26100201).

**Status (2026-10-07):** compilado no MetaEditor (IC): 0 erros, 0 avisos. **Não testado no testador nem em conta.** Nenhuma afirmação de lucratividade.

## Tese (hipótese, não evidência)
Quando o XAUUSD passa de "movimento" para **aceleração direcional** (estrutura do M1 a favor + velocidade, eficiência e pressão de ticks, em mercado ativo e custo aceitável), a continuação tende a andar vários degraus. O EA entra na aceleração e usa a escada de pernas para explorá-la, travando lucro nas pernas anteriores a cada avanço.

**Falsificação:** custo (spread + slippage) maior que o degrau; scores altos que não separam resultado dos baixos; resultado concentrado em uma sessão/regime; placebo (sinal invertido) com resultado parecido; resultado que some com ticks reais e spread real. As pesquisas de microestrutura citadas no desenho justificam *testar* essas variáveis; não provam edge neste símbolo/corretora.

## Quatro motores
Sem EMA, ATR, ADX, RSI ou qualquer indicador clássico.

| Motor | O que mede | Como |
|---|---|---|
| **Direção** | Estrutura do M1 | Swings por fractal (`InpSwingBars` de cada lado) nas últimas `InpStructLookback` barras fechadas. Viés −100..+100 = 25% HH/LH + 25% HL/LL + 25% preço ao vivo rompeu o último swing + 25% deriva (variação de 8 barras / 3× mediana de range) |
| **Momento** | Aceleração real | Janela de ticks: deslocamento em `InpImpulseSec`, eficiência (líquido/percurso) e pressão (altas − baixas)/(altas + baixas) em 10 s, aceleração (v3s / v10s) |
| **Atividade** | Mercado parado | 50% ticks/s dos últimos 10 s vs média de 5 min + 50% range do M1 atual/anterior vs mediana |
| **Execução** | Custo | Spread relativo ao degrau, penalizado pela média móvel do slippage recente das pernas |

`Score = 35% Direção + 30% Momento + 20% Atividade + 15% Execução` (0–100).

## Entrada
**Portões duros (só estes):** spread ≤ `InpMaxSpreadToStep` × degrau; atividade ≥ `InpMinActivity` (mercado parado = proibido); |viés| ≥ `InpMinBias`; score ≥ `InpMinScore`. Mais sessão, blackout manual, cooldown e permissões.

**Gatilhos (cada um com true/false):**
- **A. Rompimento com momentum** (`InpUseBreakout`): preço ao vivo rompe o micro topo/fundo das últimas `InpBreakBars` barras **fechadas**, com deslocamento ≥ `InpImpulseSteps` degraus na janela, eficiência ≥ `InpMinEfficiency` e pressão ≥ `InpMinPressure`. Não persegue: `CHASE_TOO_FAR` além de `InpMaxChaseSteps` degraus.
- **B. Micro-pullback + reaceleração** (`InpUsePullback`): em 20 s, impulso ≥ 3 degraus (1,5 × `InpImpulseSteps`), recuo entre `InpPullbackMinPct`–`InpPullbackMaxPct` % do impulso, e retomada ≥ 0,5 degrau com pressão de 3 s a favor.

Decisão intrabar é **explícita**: o gatilho usa ticks ao vivo; a estrutura usa só barras fechadas.

**Pernas:** score `[min, min+10)` → `InpLegsNormal` (4); `[min+10, min+20)` → `InpLegsStrong` (6); `≥ min+20` → `InpLegsExceptional` (8). Reduzidas se a corrente passar de 50% da margem livre.

## Escada
- **Degrau fixo `InpStepPoints` (padrão 15 pontos).** Leg 0 a mercado; legs 1..n−1 como ordens **STOP** pré-programadas em `e0 + i·degrau`, no broker. Se o degrau for menor que o stops/freeze level, **bloqueia** (`STEP_TOO_SMALL`), sem alterar o valor.
- **Lote fixo `InpLot`.** `InpUseDecreasingLots` (padrão false): perna i = base × `InpLotDecay`^i, nunca abaixo do mínimo do símbolo (use lote base maior, senão tudo vira o mínimo).
- **Escada de lucro** (`InpUseProfitLock`): quando a perna *k+1* executa, a perna *k* ganha um nível de trava = entrada de *k+1* − `InpLockStepFrac` × degrau (nunca abaixo da entrada + spread + comissão). Num recuo, as pernas saem uma a uma, da mais nova para a mais antiga. A última perna não tem trava (só os stops/proteções abaixo).
  Por padrão a trava é **software**: o EA fecha a perna a mercado quando o preço volta ao nível. Com `InpLockOnServer = true` o nível vira SL no servidor (e o EA ainda fecha a mercado como rede de segurança).
- **TP** (`InpUseTP`, padrão **false**): a ideia é capturar a aceleração e desmontar na exaustão, não fixar alvo.
- **Saída por exaustão** (`InpUseExhaustionExit`): 4 sinais (pressão < 0,10; deslocamento de 3 s contra; eficiência < 0,25; atividade < 30). 2 sinais → cancela pendentes (`MOMENTUM_FADE`); 3 sustentados por 2 s → cancela pendentes e fecha tudo (`EXHAUSTION`). Só avalia com ≥ 2 pernas abertas ou ≥ 5 s de corrente.
- **Cancelamento antes de completar:** nenhuma perna aberta; viés da estrutura virou contra (`STRUCTURE_FLIP`); validade; sessão/blackout. Não existe obrigação de executar as 8.

## Parâmetros por grupo
Regra do projeto: **todo stop/proteção tem o seu próprio `true/false`; nunca "0 = desligado"**. O valor só é lido se o botão estiver `true`; o EA recusa iniciar com proteção ligada e valor inválido ou com lote não aceito pelo símbolo.

**CORRENTE / SCORE:** `InpStepPoints` 15 · `InpMinScore` 60 · `InpLegsNormal/Strong/Exceptional` 4/6/8.

**PROFIT**

| Input | Padrão | |
|---|---|---|
| `InpLot` | 0,01 | Lote fixo base |
| `InpUseDecreasingLots` / `InpLotDecay` | false / 0,80 | Lotes decrescentes |
| `InpUseTP` / `InpTPExtraSteps` | **false** / 3,0 | TP comum |
| `InpUseProfitLock` / `InpLockStepFrac` / `InpLockOnServer` | true / 0,5 / false | Escada de lucro; trava no servidor |
| `InpUseExhaustionExit` | true | Saída por exaustão |
| `InpUseDailyTarget` / `InpDailyTargetMoney` | false / 50 | Meta diária |
| `InpCommissionPerLotRT` | 0 | Custo considerado na trava |

**STOPS E PROTEÇÕES**

| Input | Padrão | |
|---|---|---|
| `InpUseStopLoss` / `InpStopLossPoints` | **false** / 300 | Airbag: SL no servidor em cada ordem |
| `InpUseInvalidation` / `InpInvalidationMaxSteps` | true / 6 | Último swing contra (no máx. a 6 degraus): cancela e zera a corrente |
| `InpUseChainLossStop` / `InpChainLossMoney` | true / 10 | Corrente (realizada + flutuante) ≤ −valor: fecha tudo (software) |
| `InpUseDailyLossStop` / `InpDailyLossMoney` | true / 30 | Perda diária: fecha tudo e para o dia |
| `InpUsePendingTTL` / `InpPendingTTLSec` | true / 120 | Validade das pendentes |
| `InpUseMaxSeqAge` / `InpMaxSeqAgeSec` | true / 180 | Idade máxima da corrente |
| `InpUseFailCooldown` / `InpFailCooldownSec` | true / 60 | Pausa após corrente perdedora |

**SESSÃO:** `InpUseSession` 7–20 GMT; `InpUseBlackout` (false) 12–14 GMT para notícia manual.

`TP`, `airbag` e trava no servidor são as únicas ordens de saída no servidor, e as três estão **desligadas** por padrão. **Com o airbag desligado não existe stop no servidor:** a proteção (invalidação, perda da corrente, perda diária, exaustão, trava) é feita pelo EA e **só funciona com terminal/VPS conectado; não limita gap/slippage.**

## Aviso sobre o degrau de 15 pontos
No ouro de varejo o spread típico é da ordem de 10–25 pontos. Com o padrão `InpMaxSpreadToStep = 1,0` e degrau de 15 pontos, o EA **ficará em `SPREAD_HIGH` sempre que o spread passar de 15 pontos** (o log de INIT avisa). Isso não é bug: o custo de cada degrau excederia o próprio degrau. Para operar com spread maior, aumente o degrau (teste 30–60) ou, sabendo do custo, o `InpMaxSpreadToStep`.

## Limitações conhecidas
- **Exige conta HEDGING** (o EA recusa iniciar em netting).
- **Execução síncrona** (`OrderSend` bloqueante). O envio assíncrono com máquina de estados por `OnTradeTransaction` fica para uma versão futura, depois de medir `latency_ms` no CSV.
- Uma instância = um símbolo = uma corrente por vez.
- Reinício com posições abertas: ficam **órfãs** (sem contexto de corrente). O EA cancela pendentes, não abre nova corrente e elas só têm o TP/SL de servidor, se ligados.
- Os ticks são guardados em memória (8192): os ~20 s iniciais após ligar o EA são aquecimento (`DATA_NOT_READY`).
- No testador, use **todos os ticks baseados em ticks reais**; ticks sintéticos distorcem pressão, eficiência e atividade.
- Constantes fixas no código (não são inputs): pesos do score, limites de exaustão, 50% de margem. Documentadas acima.
- Sem filtro automático de notícias (decisão do projeto); só o blackout manual.
- Não testado: execução real, rejeições por stops/freeze level da corretora, expiração de pendentes.

## Telemetria — schema `1.0`
`MQL5/Files/LZTrading/AccelChain/{events,trades,chains,decisions}/` — delimitador `;`, append, rotação mensal, cabeçalho verificado.

| Arquivo | Conteúdo |
|---|---|
| `events` | INIT, DEINIT, HEARTBEAT, SIGNAL, BLOCK, ORDER_SEND/PLACED/REJECTED/CANCEL, POSITION_OPEN/MODIFY/CLOSE, RISK, KILL_SWITCH, DAY_RESET, WARNING, ERROR, **CHAIN_END** (extensão). `old_lock`/`new_lock` registram a escada; `activity` e `score` do momento do evento. |
| `trades` | Uma linha por **perna**: lote, MFE/MAE, slippage de entrada, `exit_reason` ∈ TP/SL/TRAIL/TIME_EXIT/DAILY_LOSS/EMERGENCY/INVALIDATION/EXHAUSTION/MANUAL/UNKNOWN, `setup` = gatilho. |
| `chains` | Uma linha por corrente: pernas, score e componentes (D/M/E), gatilho, atividade, líquido, pico/vale flutuante, motivo de cancelamento e fim. |
| `decisions` | Uma linha por oportunidade no gatilho (PASS ou BLOCK com `reason_code`), com score, D/M/A/E, viés e gatilho. |

`risk_money` e `realized_r` só são preenchidos quando a perna tem SL (airbag ligado).

## Como validar
1. Testador "todos os ticks baseados em ticks reais", **conta hedging**, spread real, comissão em `InpCommissionPerLotRT`.
2. Conferir primeiro `events`/`chains`: pernas enchendo na ordem, pendentes cancelando, `old_lock → new_lock`, retcodes, `latency_ms`.
3. Depois resultado: por gatilho (A vs B), por score (o score separa algo?), por número de pernas, por sessão, `SPREAD_HIGH`/`DEAD_MARKET` (quanto tempo bloqueado).
4. Placebo (direção invertida), sensibilidade em `InpStepPoints` (15/30/45/60), `InpMinScore`, `InpLockStepFrac`; out-of-sample.
5. Demo antes de qualquer capital real.

## Versões
- **1.00 (2026-10-07)** — primeira versão.
