# ChainScalper v1.13

> Versão atual: **1.13** (janelas de horário, fechamento no fim da janela e painel com hora local). As seções abaixo foram escritas na v1.07; veja "Versões" para o que mudou desde então (1.08–1.13).

Scalper de **corrente de posições** para XAUUSD em M1. Arquivo: `ChainScalper.mq5` (+ `Include/LZ/LZPanel.mqh`, já existente).

**Status (2026-10-07):** compilado no MetaEditor (Exness): 0 erros, 0 avisos. **Não testado no testador nem em conta.** Nenhuma afirmação de lucratividade.

## Tese (hipótese, não evidência)
Com tendência em M1, mercado em movimento e rompimento da máxima/mínima das últimas barras, a continuação costuma andar vários "degraus" seguidos. Em vez de uma posição só, o EA monta uma corrente de 4–8 posições e protege cada uma de forma escalonada, de modo que um recuo feche as posições uma a uma, já com lucro travado.

**Mecanismo esperado:** continuação de momentum de curtíssimo prazo + saída em camadas que captura parte do movimento mesmo se ele reverter.
**Falsificação:** custo (spread + comissão) maior que o degrau; rompimentos que revertem no próprio degrau; resultado concentrado em uma sessão/regime; placebo (inverter a direção) com resultado parecido; resultado que some com spread/slippage reais.

## Fluxo
`OnInit → validação → barra nova (análise) → proteções → gerenciamento da corrente → gatilho → execução → telemetria`

Proteção e trailing da corrente aberta **não dependem de sinal novo**.

### 1. Análise (barras fechadas de `InpSignalTF`, M1 por padrão)
Três portões duros — só o que é necessário, sem empilhar filtros:

| Portão | Regra |
|---|---|
| Tendência | Alta: EMA9 > EMA34, fechamento > EMA34 e EMA34 subindo (5 barras). Baixa: espelho. |
| Mercado parado | ATR14 ≥ 4 × spread **e** ATR14/ATR100 ≥ 0,85 |
| Spread | ≤ `InpMaxSpreadPts` |

### 2. Gatilho (decisão intrabar explícita)
Preço **ao vivo** rompe a máxima (compra) / mínima (venda) das últimas 3 barras **fechadas**. Invalidações antes de entrar:
- `CHASE_TOO_FAR`: rompimento já foi além de 0,6 ATR;
- `INVALIDATION`: barra atual > 3 ATR (spike/exaustão);
- uma corrente por barra + cooldown de 20 s.

### 3. Tamanho da corrente (4–8)
Score 0–5 (1 ponto cada): separação das EMAs ≥ 0,5 ATR; inclinação ≥ 0,4 ATR; ATR14/ATR100 ≥ 1,10; eficiência de Kaufman (10 barras) ≥ 0,35; corpo da última barra ≥ 60% a favor.
`n = min + round((max − min) × score / 5)`. O score **só define o tamanho**, não bloqueia. `n` é reduzido se a corrente passar de 50% da margem livre.

### 4. Escada
- **Degrau fixo `InpStepPoints` (padrão 15 pontos).** Se for menor que o stops/freeze level do broker, o EA **bloqueia** com `STEP_TOO_SMALL` (não altera o valor em silêncio). Se for menor que o spread, o EA avisa no log de INIT.
- **Leg 0** a mercado. **Legs 1..n−1** como ordens **STOP** pré-programadas em `e0 + i·degrau`, no broker, com TP comum. Expiram em `InpPendingTTLSec` (expiração do broker quando suportada). O EA também cancela as pendentes (invalidação da tese, sem input): nenhuma leg aberta ou a tendência virou.
- **Lote fixo** `InpLot` (grupo PROFIT), igual em todas as posições. Sem cálculo de lote por risco.
- **SL inicial: `InpUseStopLoss` (padrão `false`)**, distância `InpStopLossPoints`. Com `false`, nenhuma ordem leva SL.

### 5. Saída escalonada ("1 em 1 para trás") — por software
Cada posição aberta tem um **nível de trava de lucro** guardado no EA, a distância `S × (1,5 + 0,5 × rank)` do preço, onde `rank` = nº de posições abertas **mais novas** que ela (a mais nova trava perto; a mais antiga, larga). O nível só nasce quando já cobre spread + comissão e só sobe. Se o preço recuar até o nível, **o EA fecha aquela posição a mercado**. Num recuo, saem em sequência, das mais novas para as mais antigas, cada uma com lucro. Isso é saída de lucro, não stop de perda; não existe ordem de stop no servidor.

> **Interpretação adotada.** "Programando 1 em 1 para trás, se recuar já lucra" = escada de STOPs à frente + saída escalonada atrás. Se a intenção era outra (ordens **limit** recuando a cada avanço), é mudança de módulo.

## Entradas de recuo (LIMIT) — "para trás"
Além da escada a favor (ordens STOP), o EA programa **entradas de recuo o mais perto possível do preço**, conforme a vela vai esticando a favor:
- A cada novo extremo a favor de `InpPullbackAdvancePoints` (15 pts) desde o último recuo programado, o EA envia **uma** ordem **LIMIT** (compra abaixo / venda acima) a `InpPullbackDistPoints` (15 pts) do extremo. A distância nunca é menor que o mínimo do broker (stops/freeze level): "o mais perto possível".
- Se o preço recuar, a ordem executa num preço melhor e **tem TP próprio** (`InpUsePullbackTP`, `InpPullbackTpPoints` = 30 pts): é um scalp do retorno. É essa a leitura de "se recuar já lucra": o recuo vira entrada, não perda.
- No máximo `InpMaxPullbackOrders` (4) recuos pendentes ao mesmo tempo, sem empilhar dois no mesmo nível. Cancelados por validade (`InpPendingTTLSec`, **por ordem**), choque de M15/H1, virada de tendência, fora da sessão ou fim da corrente. Sem pernas abertas, só a escada a favor é cancelada; os recuos seguem até a validade.
- Cada recuo executado é uma perna da corrente (slots 8–15; comentário `CS<id>_<8..15>`), com as mesmas travas de lucro e proteções. No CSV: `setup = PULLBACK_LIMIT`.
- Exige `InpUsePendingTTL = true` (senão as ordens ficariam para sempre).

## Perda da corrente lê a volatilidade
Mesmo escolhendo o limite em dinheiro (`InpChainLossMoney`), o EA **lê o ATR do M1**: o limite efetivo é `max(InpChainLossMoney, InpChainLossAtrMult × ATR × valor por unidade de preço × volume aberto)`, com `InpChainLossAtrMult` = 2,0. Assim um recuo normal de uma vela não estoura o limite. Em 07/10, 4 pernas de 0,01 com ATR de US$ 2,77 perderam US$ 11,67 num recuo de 1 vela e foram fechadas pelo limite de US$ 10. Agora o piso seria ≈ US$ 22. `InpChainLossReadsVol` liga/desliga. O log do `CHAIN_LOSS` mostra o limite usado.

## Contexto de M15 e H1 (não é filtro)
O EA decide no M1, mas **enxerga** o M15 e o H1. Velas grandes de M15/H1 não bloqueiam nada. Só há reação quando uma vela **recém-aberta** (ou que acabou de fechar, até 1/3 do período) tem corpo ≥ `InpHtfShockMult` (2,0) × a mediana do range das 20 velas anteriores **contra a direção** do EA:
- sem corrente: não abre nova corrente (`HTF_SHOCK`, "aguardando");
- com corrente: cancela as pendentes (não estende a escada contra o choque). As posições abertas seguem com as proteções de sempre.
Passado 1/3 do período da vela, a condição some sozinha. Liga/desliga em `InpUseHtfShockGuard`. O painel mostra o choque de M15 e H1 em múltiplos da mediana. Motivação: a corrente 2 de 07/10 abriu com compra no M1 enquanto M15/H1 derretiam.

## Reinício com posições abertas
Ao carregar o EA (gráfico reaberto, queda do terminal), ele **reconstrói a corrente** pelos comentários das posições (`CS<id>_<perna>`) e passa a gerenciá-la: perda máxima da corrente, perda diária, cancelamento de pendentes, TP e travas (que recomeçam do zero). Evento `CHAIN_ADOPTED`. Posições sem comentário do EA não podem ser reconstruídas (`ORPHAN`, o EA não abre nova corrente). **Atenção:** se a perda já passou do limite, o EA fecha tudo logo ao carregar.

## Limite de perda obrigatório
O EA **recusa iniciar** se SL, perda máxima da corrente e perda diária estiverem **todos** desligados. Cada um continua com o seu true/false; basta um ligado. Motivo: em 07/10, com os três desligados, quatro posições ficaram abertas sem nenhum limite e o ouro caiu ~US$ 28 (−195 de equity no pior ponto).

## Preset de teste
Arquivo: `presets/ChainScalper_v107_teste_XAUUSD.set` (UTF-16, formato do MT5). **Preset não é código**: só altera 9 inputs em relação ao padrão e **não é preset otimizado, não há backtest nem evidência de edge**.

| Input | Padrão | Preset | Por quê |
|---|---|---|---|
| `InpStepPoints` | 15 | **40** | CSV real da IC (07/10): comissão US$ 8/lote ida+volta (= 8 pts por 0,01 lote) + spread típico 10 pts ≈ 18 pts de custo por perna, fora o slippage (p90 = 20 pts). Degrau de 15 pts não paga o custo; 40 pts deixa o custo em ~45% do degrau |
| `InpMaxSpreadPts` | 40 | 20 | Não entrar com spread alto (típico 10, máximo visto 43) |
| `InpCommissionPerLotRT` | 0 | 8,0 | Custo real, para a trava de lucro não "travar" abaixo do custo |
| `InpPullbackDistPoints` / `InpPullbackAdvancePoints` / `InpMaxPullbackOrders` / `InpPullbackTpPoints` | 15 / 15 / 4 / 30 | 20 / 40 / 3 / 40 | Recuos proporcionais ao degrau novo (um recuo por degrau; TP maior que o custo) |
| `InpChainLossMoney` / `InpDailyLossMoney` | 10 / 30 | 15 / 40 | Com o piso de volatilidade (2× ATR) o limite efetivo é o maior dos dois |

Mantidos: sem SL (perfil do operador), lote 0,01, guarda de M15/H1 ligada, validade 120 s. Sessão (desde a v1.10): janelas A 01–05 e B 12–15 do servidor.

**Faixas de sensibilidade** (flag `N` no arquivo; troque por `Y` para varrer, só para ver a *forma* do resultado, não para escolher o melhor ponto): `InpStepPoints` 30–60 (passo 10), `InpTrailBaseSteps` 1,0–2,5 (0,5), `InpChainLossAtrMult` 1,5–3,0 (0,5).

**Configuração do Testador:** XAUUSD, M1, conta **HEDGING**, modelagem **"Todos os ticks baseados em ticks reais"**, spread real (não fixo), depósito e moeda da conta, fuso do servidor registrado. Período: pelo menos 4 semanas com dias de tendência e de lateralidade; separe as semanas (por exemplo 2 de ajuste e 2 fora da amostra). Registre corretora, comissão, versão (1.07) e o `.set`.

**O que olhar, nesta ordem:** (1) `events`/`chains` para conferir pernas, recuos, cancelamentos e retcodes; (2) resultado **por gatilho** (`PULLBACK_LIMIT` vs escada a favor) e por número de pernas; (3) `net` por perna **depois do custo** e `SPREAD_HIGH`/`DEAD_MARKET`/`HTF_SHOCK` (quanto tempo ficou bloqueado); (4) placebo (direção invertida) e sensibilidade do degrau. **Falsificação:** se o resultado some com degrau 40–60 e comissão 8, ou se só um dia/uma sessão carrega o saldo, não há edge utilizável.

**Risco:** sem stop no servidor, perda da corrente e perda diária são feitas pelo EA e não valem com o terminal desconectado nem em gap.

## Parâmetros por grupo
Regra do projeto: **todo stop/proteção tem o seu próprio `true/false`; nunca "0 = desligado"**. O valor só é lido se o botão estiver `true`, e o EA recusa iniciar se a proteção estiver ligada com valor inválido ou se o lote não for aceito pelo símbolo.

**CORRENTE**: `InpMinLegs` 4, `InpMaxLegs` 8, `InpStepPoints` 15 (pontos).

**PROFIT**

| Input | Padrão | O que faz |
|---|---|---|
| `InpLot` | 0,01 | Lote fixo por posição |
| `InpUseTP` / `InpTPExtraSteps` | true / 3,0 | TP comum da corrente no servidor, em degraus além do último |
| `InpUseProfitLock` | true | Saída escalonada por posição, por software (seção 5) |
| `InpTrailBaseSteps`, `InpTrailRankSteps` | 1,5 / 0,5 | Distância da trava (mais nova / acréscimo por posição mais nova), em degraus |
| `InpUsePullbackLimits` | true | Entradas LIMIT de recuo |
| `InpPullbackDistPoints`, `InpPullbackAdvancePoints`, `InpMaxPullbackOrders` | 15 / 15 / 4 | Distância ao extremo, avanço que programa o próximo, máximo pendentes |
| `InpUsePullbackTP` / `InpPullbackTpPoints` | true / 30 | TP dos recuos |
| `InpUseDailyTarget` / `InpDailyTargetMoney` | false / 50 | Meta diária: para de abrir correntes |
| `InpCommissionPerLotRT` | 0 | Custo (ida+volta por lote) considerado na trava de lucro; não é proteção |

**STOPS E PROTEÇÕES**

| Input | Padrão | O que faz |
|---|---|---|
| `InpUseStopLoss` / `InpStopLossPoints` | **false** / 200 | SL inicial no servidor |
| `InpUseChainLossStop` / `InpChainLossMoney` | true / 10 | Corrente (realizada + flutuante) ≤ −valor: fecha tudo (software) |
| `InpChainLossReadsVol` / `InpChainLossAtrMult` | true / 2,0 | Piso de volatilidade do limite acima (x ATR do M1 na exposição aberta) |
| `InpUseDailyLossStop` / `InpDailyLossMoney` | true / 30 | Perda diária: fecha tudo e para o dia |
| `InpUsePendingTTL` / `InpPendingTTLSec` | true / 120 | Validade das pendentes |

**OUTROS TFs**: `InpUseHtfShockGuard` true, `InpHtfShockMult` 2,0.

**SESSÃO (janelas de horário, v1.10)**: `InpUseSession` liga o controle; `InpSessionClock` escolhe o relógio das janelas (`SERVER` = hora do servidor, padrão; `GMT`). Duas janelas, cada uma com o seu `true/false` e hora cheia de início (inclusive, 0–23) e fim (exclusive, 0–24; início > fim cruza a meia-noite):

| Janela | Padrão (servidor) | Motivo |
|---|---|---|
| A (`InpUseWindowA`, `InpWindowAStartHour`/`EndHour`) | 01–05 | Melhor faixa nos logs (14 correntes, 100% de acerto, +US$ 43) e recuos médios menores no M1 do ouro. Hipótese, amostra pequena. |
| B (`InpUseWindowB`, `InpWindowBStartHour`/`EndHour`) | 12–15 | Faixa secundária, neutra nos logs; termina antes da abertura/dados dos EUA (15:30 do servidor = 08:30 em NY). Desligue se preferir só a A. |

Fora das janelas o EA não abre correntes novas e cancela pendentes (`SESSION_CLOSED` / `SESSION_CLOSE`). **Desde a v1.11**, com `InpUseFlattenAtEnd = true` (padrão) ele também fecha todas as posições abertas no fim da janela, para não deixar lucro ou perda flutuando; nos últimos `InpNoNewMinBeforeEnd` minutos (padrão 10) não abre corrente nova (`SESSION_ENDING`). Com `InpUseFlattenAtEnd = false`, posições abertas seguem com TP, trava de lucro e saídas lógicas. Evitados de propósito: 15:00–18:59 (recuos grandes e muitos bloqueios por risco) e 23:00–00:59 (spread de 20–40 pts na virada do dia). O servidor é UTC+3 no horário de verão dos EUA e UTC+2 no resto do ano; em GMT a janela A é 22–02 (UTC+3) ou 23–03 (UTC+2). O EA recusa iniciar se a sessão estiver ligada sem nenhuma janela ligada ou com hora inválida.

**MANUTENÇÃO**: `InpResetDailyPnl` (false). Marque `true`, carregue o EA uma vez e volte para `false`: o resultado do dia passa a contar de zero (e a trava de perda/meta do dia é liberada). Se ficar `true`, zera a cada carga.

Camadas: `lote fixo → margem (50% da livre, fixo no código) → guarda de M15/H1 → stops acima`. **Pelo menos um** entre SL, perda da corrente e perda diária precisa estar ligado.
**Tudo marcado como "software" só funciona com o terminal/VPS conectado e não limita gap/slippage.** Com `InpUseStopLoss = false` não existe stop no servidor.

## Limitações conhecidas
- **Exige conta HEDGING** (em netting as legs se fundiriam; o EA recusa iniciar).
- Uma instância = um símbolo = um timeframe = uma corrente por vez. Magic identifica a corrente.
- Reinício com posições abertas: o EA reconstrói e gerencia a corrente (ver seção própria). Só posições **sem comentário do EA** ficam órfãs e bloqueiam novas correntes.
- **Com `InpUseStopLoss = false`:** queda do terminal/VPS ou gap deixa as posições sem SL de servidor até o EA voltar; as proteções por software (perda da corrente, perda diária, travas) só valem com o EA rodando e conectado.
- Fim de sessão (v1.11): cancela pendentes e fecha todas as posições (`InpUseFlattenAtEnd`, padrão true). Fechamento é a mercado, com o spread e a possível derrapagem do momento; só funciona com o terminal conectado e o mercado aberto.
- Sem filtro de notícias (decisão do projeto). Spread no tester pode ser irreal em XAUUSD: use spread variável/real.
- Comissão flutuante de posições abertas não entra no P/L diário em tempo real (entra ao fechar).
- Janelas de sessão em hora do servidor (`TimeCurrent()`) por padrão, ou em GMT (`TimeGMT()`) com `InpSessionClock`; virada do dia pela data do servidor. Os horários padrão vêm de 83 correntes em ~10 dias (IC e FP, 5 versões misturadas): é hipótese, não evidência.
- Não testado: execução real, rejeições de `OrderSend` por stops/freeze level da Exness, comportamento com `SYMBOL_EXPIRATION_MODE`.

## Telemetria — schema `1.1` (1.0 + coluna `final_lock_price` no fim de `trades`)
Pasta: `MQL5/Files/LZTrading/ChainScalper/{events,trades,chains,decisions}/` — delimitador `;`, append, rotação mensal, cabeçalho verificado (se divergir, cria arquivo novo com sufixo do schema).

| Arquivo | Conteúdo |
|---|---|
| `events` | INIT, DEINIT, HEARTBEAT, SIGNAL, BLOCK, ORDER_SEND/PLACED/REJECTED/CANCEL, POSITION_OPEN/MODIFY/CLOSE, RISK, KILL_SWITCH, DAY_RESET, WARNING, ERROR, **CHAIN_END** (extensão). A trava de lucro registra `old_sl`/`new_sl` = nível de trava antigo/novo (virtual), `trail_rank`, `trail_dist_price`. |
| `trades` | Uma linha por **leg** fechada (MFE/MAE, slippage de entrada, `exit_reason` ∈ TP/SL/TRAIL/TIME_EXIT/KILL_SWITCH/DAILY_LOSS/SESSION_CLOSE/EMERGENCY/MANUAL/UNKNOWN). |
| `chains` | Uma linha por corrente: legs planejadas/abertas/canceladas, risco planejado, líquido, `net_over_planned_risk`, pico/vale flutuante, motivo de cancelamento e de fim. |
| `decisions` | Uma linha por oportunidade no gatilho (PASS ou BLOCK com `reason_code`), com score, ATR, expansão e eficiência. |

Bloqueios gerais usam os `reason_code` de `docs/CSV.md` (NO_TREND, SPREAD_HIGH, DEAD_MARKET, SESSION_CLOSED, CHASE_TOO_FAR, INVALIDATION, RISK_TOO_HIGH, NO_MARGIN, COOLDOWN, DAILY_LOSS_REACHED, TRADING_NOT_ALLOWED, SYMBOL_DISABLED, DATA_NOT_READY, BROKER_REJECT) mais `DEAD_MARKET`, `ORPHAN`, `DIRECTION_OFF`.

## Painel
Estado e motivo de bloqueio no topo; análise (tendência, score, ATR, nível de rompimento); **escada** com um chip por leg (STOP / ABERTA / FECHADA / CANC); risco (perda do dia, DD, perdedoras seguidas); telemetria. Minimizável.

## Como validar (ordem sugerida)
1. Testador "todos os ticks baseados em ticks reais", **conta hedging**, spread real da Exness, comissão preenchida em `InpCommissionPerLotRT`, depósito e moeda iguais à conta.
2. Conferir primeiro `events`/`chains`: legs enchendo na ordem, pendentes expirando/cancelando, trailing escalonado de fato (`trail_rank`), retcodes.
3. Só depois olhar resultado: por sessão, por score (o score separa algo?), por tamanho da corrente, e `net_over_planned_risk`.
4. Placebo: `InpAllowBuy`/`InpAllowSell` com direção invertida no código ou rompimento oposto; sensibilidade em `InpStepAtr` (0,35–0,8), `InpTrailBaseSteps` e `InpMaxLegs`; out-of-sample em período não usado.
5. Demo antes de qualquer capital real.

## Versões
- **1.13 (2026-10-19)** — painel sem informação cortada: largura 480 px e quebra de linha por palavras nas faixas de BLOQUEIO, CORRENTE e ATENCAO (função `StripWrap`; a v1.12 cortava com `~`, removido). Textos completos de `SESSION_CLOSED` (janelas em forma curta `A 01-05, B 12-15 srv`) e `SESSION_ENDING`. Só interface; lógica igual à v1.11. Compilada na IC e na FP (0 erros, 0 avisos); painel não conferido no gráfico.
- **1.12 (2026-10-19)** — painel: textos de bloqueio/alerta mais curtos e cortados para caber na linha (função `PFit`), rótulo `POSICOES` sem sobreposição; detalhe do bloqueio `SESSION_CLOSED` agora remete à seção HORARIO. Só interface; lógica igual à v1.11. Compilada na IC e na FP (0 erros, 0 avisos); painel não conferido no gráfico.
- **1.11 (2026-10-19)** — **nada fica flutuando fora da janela:** `InpUseFlattenAtEnd` (padrão true) cancela as pendentes e fecha todas as posições a mercado no fim de cada janela (`exit_reason`/`end_reason` = `SESSION_CLOSE`; evento `RISK`/`SESSION_FLATTEN`). `InpUseNoNewBeforeEnd`/`InpNoNewMinBeforeEnd` (true / 10 min): nos minutos finais da janela não abre corrente nem novos recuos (`SESSION_ENDING`, estado `FIM JANELA`). **Painel:** seção HORARIO com **hora local** (a do PC) e do servidor, janela atual, tempo restante ou próxima janela, as janelas A/B em hora do servidor e em hora local, e se o fim fecha tudo; linha de SPREAD (atual / máximo), FLUTUANTE total, POSICOES ABERTAS e PENDENTES; faixa ATENCAO se houver posição aberta fora da janela. Log `INIT_SESSION`. Compilada na IC e na FP (0 erros, 0 avisos); **não testada no testador nem em conta**. Ao carregar o EA fora da janela com posições abertas, elas são fechadas (por isso o fechamento no fim vale também para posições adotadas).
- **1.10 (2026-10-19)** — sessão em janelas de horário: A (01–05) e B (12–15), cada uma com `true/false`, em hora do servidor (padrão) ou GMT (`InpSessionClock`). Substitui `InpSessionStartGMT`/`InpSessionEndGMT` (removidos; presets atualizados). Validação de inputs e log INIT com as janelas. Compilada na IC e na FP (0 erros, 0 avisos); **não testada no testador nem em conta**.
- **1.09** — saídas lógicas (não são SL): perna de recuo no prejuízo fecha quando a tendência vira contra (`InpUseTrendFlipExit`) ou após o tempo máximo (`InpUseLegMaxTime`, `InpLegMaxMin`); `end_reason` deixa de chamar de SL o que não foi SL (`TREND_FLIP_EXIT`, `LEG_TIMEOUT`, `LOSS`). Já estava nas cópias da IC e da FP; o arquivo do projeto foi sincronizado com ela em 2026-10-19.
- **1.07 (2026-10-07)** — `InpResetDailyPnl`: zera o resultado do dia ao carregar o EA (base gravada em variável global do terminal, vale só para o dia atual; histórico e CSV não são alterados).
- **1.06 (2026-10-07)** — entradas LIMIT de recuo programadas conforme o preço estica a favor; perda da corrente com piso de volatilidade; TTL por ordem; `NO_OPEN_LEGS` cancela só a escada a favor.
- **1.05 (2026-10-07)** — após a corrente 2 de 07/10 ficar sem limite de perda: EA recusa iniciar sem ao menos um limite de perda ligado; reinício assume e gerencia as posições abertas (`CHAIN_ADOPTED`); contexto de M15/H1 (`HTF_SHOCK`) que só segura em vela forte e rápida contra.
- **1.04 (2026-10-07)** — lote fixo no grupo PROFIT (sem cálculo de lote por risco); degrau em pontos (padrão 15); stops reduzidos a: SL inicial, perda máxima da corrente, perda diária e validade das pendentes (cada um com true/false). Removidos: kill switch por equity, tempo máximo, stall, pausa por perdas seguidas, fechar no fim da sessão, teto de risco da corrente, limites de lote/margem como inputs. Schema CSV 1.1: `risk_money` e `planned_chain_risk_money` ficam vazios sem SL.
- 1.03 — cada stop/proteção com `true/false` próprio (sem "0 = desligado"); inputs agrupados em PROFIT / RISCO / STOPS; SL inicial volta como opção (`InpUseStopLoss`, padrão false); validação de inputs por botão.
- 1.02 — sem stop em nenhuma ordem; trava de lucro escalonada por software; `CHAIN_LOSS`; schema CSV 1.1.
- 1.01 — teste interno com SL opcional; descartada.
- **1.00 (2026-10-07)** — primeira versão.
