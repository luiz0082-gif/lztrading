# MicroMomentum

Scalper de micro-momentum em ticks para XAUUSD (M1). Entra quando o preço faz um impulso rápido, sai por TP em dinheiro, recoil ou anti-preso (ESCAPE). **Stop loss opcional e desligado por padrão** (estilo do projeto: sem stop, agressivo).

| Arquivo | O que é |
|---|---|
| `MicroMomentum_v210.mq5` | Cópia de referência da v2.10 em uso (não alterada) |
| `MicroMomentum_v220.mq5` | v2.20: v2.10 + filtros de entrada, pullback virtual, escape anti-slippage e telemetria nova |
| `presets/MicroMomentum_v210_recomendado.set` | Preset recomendado para a v2.10 |
| `presets/MicroMomentum_v220_recomendado.set` | Preset recomendado para a v2.20 |
| `presets/MicroMomentum_v220_pullback_AB.set` | v2.20 com pullback ligado, magic 1002, para teste A/B |

A v2.20 é gerada a partir da v2.10 por `python tools/micromomentum/make_v220.py` (cada patch exige o trecho exato; se a v2.10 mudar, o script falha). Compilada no MetaEditor build 6230: **0 erros, 0 avisos**.

Os `.set` estão em UTF-16 (formato nativo do MT5). Para usar: copie para `MQL5\Profiles\Tester` ou carregue com *Carregar* na janela de inputs do EA.

## Origem das mudanças

Vêm de `docs/relatorios/RELATORIO-MICROMOMENTUM-2026-10-05.md` (310 trades, 6 dias). Medido nos dados: 26,5 % das entradas andam 40 pts ou mais contra em até 5 s. Entre os trades analisados:

| Padrão | Efeito observado |
|---|---|
| Impulso maior | 22 % de "contra rápido" (≤ 30 pts) → 41–43 % (> 60 pts) |
| Slippage de entrada > 20 pts | 56 % de "contra rápido", net +0,46 contra +0,80 |
| Spread > 10 pts | 37 % de "contra rápido", net +0,51 |
| Entrada ≤ 10 s após a anterior | 36 % de "contra rápido", 41 % com MAE ≤ −200 pts |

São indícios de uma amostra pequena e com configurações misturadas. Cada filtro novo deve ser testado isoladamente.

## Novidades da v2.20

Todos os inputs novos nascem **desligados** (0, vazio ou `false`). Com os padrões do código, a v2.20 opera como a v2.10.

| Input | Efeito | Motivo no `signals.csv` |
|---|---|---|
| `InpMaxImpulsePts` | Não entra se o impulso passar de N pts (anti-pico). Deve ser ≥ `InpMinPointsDisplacement`. | `impulso_excessivo` |
| `InpBlockWindows` | Janelas sem entrada na hora do servidor, `"HH:MM-HH:MM;..."`. Fim exclusivo; aceita virada de dia. Posições abertas continuam sendo gerenciadas. | `janela_bloqueada` |
| `InpStackGateMoney` | Não abre nova posição se alguma aberta estiver pior que −US$ N (líquido). Não é stop: não fecha nada. | `pilha_posicao_negativa` |
| `InpStackMinGapMs` | Intervalo mínimo entre entradas quando já há posição aberta. | `pilha_intervalo` |
| `InpPullbackEntry` + `Pct` / `InvalidPct` / `WaitMs` | Em vez de entrar no fim do impulso, arma uma ordem **virtual** e entra quando o preço recuar `Pct` % do impulso desde o extremo. Cancela se recuar mais que `InvalidPct` % ou passar de `WaitMs`. Usa ordem a mercado no disparo, não pendente. | `WAIT aguarda_pullback`; cancelamentos `pullback_invalidado`, `pullback_expirou`, `pullback_sinal_oposto`, `pullback_cancelado_estado` |
| `InpSlipHighPts` + `InpSlipEscapeSec` | Posição com slippage de entrada ≥ N pts usa um ESCAPE mais cedo. Só sai no zero a zero ou lucro, nunca no negativo. Exige `InpEscapeSec > 0`. | saída `ESCAPE_SLIP` |

### Telemetria nova (`trades.csv`, colunas ao final; schema aditivo)

| Coluna | Significado |
|---|---|
| `mae_ms` | ms entre a abertura e o pior ponto em pontos |
| `pts_1s`, `pts_3s`, `pts_5s` | pontos da posição por volta de 1 s, 3 s e 5 s após a abertura (vazio se não houve tick na janela) |
| `entry_impulse_pts` | impulso (pts) na direção da entrada |
| `pb_wait_ms`, `pb_retrace_pct` | espera e recuo quando entrou por pullback (vazio nas demais) |
| `slip_high` | 1 se o slippage de entrada ≥ `InpSlipHighPts` |

Vazio significa ausente. Com isso dá para medir quanto tempo as entradas "vão contra rápido" e testar cada filtro com dados.

## Presets

| | v2.10 recomendado | v2.20 recomendado |
|---|---|---|
| Base | sessão A/S004259: 24 trades, win 95,8 %, +US$ 28,78 | igual |
| Lote / TP | 0,02 / US$ 1,20 líquido (~60 pts) | igual |
| Impulso / janela / ticks | 60 pts / 1500 ms / 6 | igual |
| Pullback interno / disp ÷ spread | 25 % / 3,0 | igual |
| Spread máximo | 12 | 12 |
| Posições abertas | 2 | **3** (a porteira limita a cauda) |
| SL | desligado | desligado |
| Anti-preso (ESCAPE) | 8 s, CT 4 s, arma em −US$ 0,30 | igual |
| Recoil | 100 pts, lucro mín. US$ 0,30 | igual |
| Contra-tendência: impulso × | 2,0 | 2,0 |
| Meta diária | US$ 30, sem stop diário | igual |
| Pausa por perdas | 3 seguidas → 30 min | igual |
| `InpDeviationPoints` / retries | 15 / 2 | 15 / 2 |
| `InpLogEveryTick` | `false` | `false` |
| Teto de impulso | n/a | 100 pts |
| Janela sem entrada | n/a | 15:25–15:40 |
| Porteira de empilhamento | n/a | −US$ 5; intervalo 10 s |
| Anti-slippage | n/a | ≥ 20 pts → escape em 3 s |

Observações:

- **O ESCAPE da sessão-base estava desligado.** Nos dados a sessão S004259 usou `InpEscapeSec = 0` e `InpMaxOpenPositions = 1`. Os presets ligam o ESCAPE (8 s) para liberar o slot quando a posição fica presa, mas essa combinação específica não foi medida.
- **`InpDeviationPoints` provavelmente não reduz slippage na conta A.** O slippage chegou a 133 pts com desvio de 15–20, o que sugere execução a mercado em que o desvio é ignorado. Por isso a reação à slippage é pós-fill (`ESCAPE_SLIP`).
- **A janela 15:25–15:40** é hora do servidor. Os dados mostram servidor ≈ UTC+3 (**suposição**, não declarada nos arquivos); ajuste se o seu servidor for outro.
- `InpLogEveryTick = false` reduz volume (em 6 dias `ticks.csv` ocupou 573 MB). Ligue só se for analisar tick a tick.
- Lote e posições mudam o risco em proporção: dobrar o lote ou as posições dobra a cauda.

## Teste A/B sugerido

1. Terminal A: `v220_recomendado` (magic 1001).
2. Terminal B: `v220_pullback_AB` (magic 1002).
3. Não mudar parâmetros durante a coleta. Registrar o nome do preset junto com a data.
4. Comparar por `signals.csv` (motivos de skip) e `trades.csv` (`mae_ms`, `pts_1s/3s/5s`, net, MAE).

Limitação: as contas A (IC Markets) e B (FP Markets) têm execução diferente (na B o slippage foi 0). Para comparar o pullback de forma justa, o ideal é rodar os dois presets na mesma corretora, em magics diferentes.

## Limites conhecidos

- A v2.20 foi compilada, **não foi testada em execução nem no testador**. O pullback virtual e os filtros precisam de um teste antes de uso com capital.
- Sem stop: o risco continua sendo a cauda de MAE (até −US$ 42 em 0,01 lote nos dados). A porteira de empilhamento e o teto de impulso reduzem a exposição, mas não eliminam esse risco.
- Entrada em duas etapas (metade do lote, completa com confirmação) **não** foi implementada.
- Há posições na conta A que não são do EA (ver relatório). Use um magic exclusivo por EA e por conta de teste.

---

# v2.30 e v2.40 (2026-10-06)

Geradas a partir da v2.20 por `tools/micromomentum/make_v230.py` e `make_v240.py`. Compiladas no MetaEditor build 6230: **0 erros, 0 avisos**. **Não foram testadas em execução nem no testador.** Cada versão tem só o recurso novo; os recursos da v2.20 continuam disponíveis.

| Arquivo | O que é |
|---|---|
| `MicroMomentum_v230.mq5` | v2.20 + **reação precoce ao caminho** (teste na IC) |
| `MicroMomentum_v240.mq5` | v2.20 + **ordem pendente real** (teste na FP) |
| `presets/MicroMomentum_v230_IC.set`, `_v230_FP.set` | Presets da v2.30 por corretora (magic 1030) |
| `presets/MicroMomentum_v240_IC.set`, `_v240_FP.set` | Presets da v2.40 por corretora (magic 1040) |

Diagnóstico de origem: `docs/relatorios/DIAGNOSTICO-MICROMOMENTUM-2026-10-06.md`.

## Presets por corretora

| | IC Markets | FP Markets |
|---|---|---|
| `InpMinTicksInWindow` | 6 | **3** |
| `InpMaxSpreadPoints` | 12 | **14** |
| Motivo | a janela tem 26 ticks (mediana) | a janela tem no máximo 4 ticks; 6 nunca ocorre. Spread normal 9–14 pts |

Os demais valores são iguais: lote 0,02, impulso 60 pts, janela 1500 ms, TP US$ 1,20 líquido, sem stop, ESCAPE 8 s, meta diária US$ 30, `InpMaxOpenPositions = 2`, teto de impulso 100 pts, janela sem entrada 15:25–15:40 (servidor), `InpLogEveryTick = false`. A porteira de empilhamento da v2.20 fica **desligada**: nos 467 trades a taxa de cauda não aumentou com empilhamento. O pullback virtual também fica desligado.

Para trocar de corretora sem trocar de versão, use o `_IC` ou o `_FP` da mesma versão.

## v2.30: reação precoce ao caminho

Aos `InpEarlyCheckMs` (5 s) a posição é avaliada uma vez. Se estiver pior que `-InpEarlyWeakPts` (60 pts) ela é marcada **fraca** (evento `EARLY_WEAK`). Reações, todas configuráveis:

| Input | Efeito |
|---|---|
| `InpEarlyExitEnable` + `InpEarlyExitMoney` | A posição fraca sai (`ESCAPE_EARLY`) assim que o líquido chegar a `InpEarlyExitMoney` (0 = zero a zero). Nunca no negativo se o limiar for ≥ 0. |
| `InpEarlyBlockEntries` | Sem novas entradas enquanto houver posição fraca aberta (`reacao_precoce_bloqueio`). |

Telemetria nova em `trades.csv` (final): `early_pts`, `early_weak`.

**O histórico não sustenta ganho de lucro.** Em 467 trades, sair no zero a zero das posições fracas reduziu o resultado estimado em quase todos os limiares (de −7 a −65 USD). A faixa 5 s / 60 pts, usada no preset, ficou perto de neutra (+4,55 em 26 trades, dentro do ruído). O teste na IC serve para medir o efeito real; compare com a v2.20 sem a reação (`InpEarlyEnable = false`). O bloqueio de entradas fica desligado nos presets porque, pelos dados, custaria cerca de US$ 94 sem reduzir a cauda.

## v2.40: ordem pendente real

No lugar da entrada a mercado o EA envia uma **ordem pendente de verdade** ao servidor e a cancela em milissegundos se o movimento mudar. Uma pendente por vez.

| Modo (`InpPendMode`) | Preço da ordem | Preenche quando | Cancela se |
|---|---|---|---|
| `PEND_LIMIT` (padrão do preset) | preço atual menos o recuo (`InpPendLimitPct` % do impulso, mínimo `InpPendMinOffsetPts`) | o preço recua até ela | passar `InpPendTtlMs`; o preço fugir `InpPendCancelPts` além do extremo; sinal oposto |
| `PEND_STOP` | preço atual mais `InpPendStopPts` | o movimento continua | passar `InpPendTtlMs`; o preço recuar `InpPendCancelPts` do extremo; sinal oposto |

Em ambos também cancela por limite de posições ou bloqueio duro (pausa, meta, trading desligado, sessão, perdas). **Não cancela por `BLOCK_SPREAD`**, que foi a causa dos 113 cancelamentos do pullback virtual na FP.

Detalhes:
- TP/SL do servidor ancorados no preço da ordem; expiração no servidor como rede de segurança, quando o símbolo permite (`SYMBOL_EXPIRATION_MODE`).
- Preenchimento: tenta `RETURN`, depois `IOC`, depois `FOK`, só se o erro for de filling.
- `InpPendRearmMs` evita colocar e cancelar a cada tick.
- Eventos: `PEND_PLACED`, `PEND_FILLED`, `PEND_GONE`, `PEND_REJECTED`; em `orders.csv`: `PEND_OPEN`, `PEND_CANCEL`; em `signals.csv`: `WAIT pendente_limit|pendente_stop` e `SKIP pend_*`.
- Em `trades.csv`, `pb_wait_ms` passa a ser a espera até o preenchimento e `entry_slip_pts` é medido contra o preço da ordem (negativo = melhor que a ordem).
- `InpPendEnable` e `InpPullbackEntry` não podem estar ligados juntos.

**Riscos e hipóteses:**
- Nos dados, esperar o recuo seleciona as entradas em que o impulso falha (diagnóstico, seção 5): com 20 pts e 3 s, 52 % preencheriam, e os preenchidos não têm menos cauda. O ganho esperado é preço de entrada e latência, não menos cauda.
- O cancelamento leva uma ida e volta (~190 ms na FP, ~380 ms na IC) e pode perder a corrida contra um preenchimento.
- Cada corretora aceita certos tipos de preenchimento e expiração para ordens pendentes; isso só se confirma rodando. Verifique `PEND_REJECTED` e `PEND_OPEN` com `retcode` em `orders.csv` nos primeiros minutos.
