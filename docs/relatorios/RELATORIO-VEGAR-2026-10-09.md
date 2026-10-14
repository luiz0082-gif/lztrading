# Relatório Vegar — 2026-10-09

Fonte: `MQL5/Files/VEGAR/*.csv` do terminal IC Markets (conta demo ICMarketsSC, XAUUSD), 22/09 a 09/10/2026. Código: `MQL5/Experts/VEGAR_SOURCE/`.

## 1. Por que nunca operou
`Vegar_Execution.mqh:230` exigia `OrderCheck.retcode` 10009/10008. No MQL5 o `OrderCheck` aprovado devolve **0** ("Done"). As 9 tentativas de 25/09 a 02/10 foram todas rejeitadas com `OrderCheckRetcode=0`, `OrderSendCalled=0`. Corrigido (`retcode==0` aceito, também em `Vegar.mq5`). Depois da correção: 2 operações reais (07/10 e 09/10).

## 2. Operações reais
| Data | Lado | Resultado | Observação |
|---|---|---|---|
| 07/10 | BUY 4119.25 | +5,63 | 7h23 aberta; Runner falhou com 10029 e pediu fechamento a mercado; o TP executou junto |
| 09/10 | SELL 4175.02 | −0,04 | fechada 17:17:41, logo após reinício do terminal; **origem do fechamento não registrada** |

## 3. Funil (22/09–09/10)
470 setups iniciados → 276 sweep → 157 MSS → 126 aguardando deslocamento → 41 deslocamento → 16 reteste → 15 passaram em todos os gates. Principais descartes: `SWEEP_TOO_DEEP` 151 (todos MICRO_CONTINUATION; o log não traz a profundidade), `DISPLACEMENT_NOT_CONFIRMED` 115, `MSS_NOT_CONFIRMED` 113, `RETEST_EXPIRED` 23.

## 4. Replay de oportunidades (62 completas)
| Janela | n | alvo antes do stop | stop antes do alvo | nenhum | MFE med. | MAE med. |
|---|---|---|---|---|---|---|
| 23/09–01/10 | 31 | 10 | 6 | 15 | 2,91 | 6,65 |
| 01/10–09/10 | 31 | 15 | 5 | 11 | 4,34 | 4,74 |

Leitura honesta: 25/36 decididos bateram o alvo (≈69 %), mas a perda média no stop-primeiro é ≈ 8,4 contra alvo de 5, e 28/62 têm `CostModelIncomplete=1`. A expectativa aproximada fica perto de zero (≈ +0,9 por oportunidade decidida) com amostra pequena. **Não é evidência de edge.** O replay só cobre oportunidades promovidas; **não existe contrafactual dos setups descartados**, então não dá para dizer se relaxar `SWEEP_TOO_DEEP` ou os prazos do MSS ajudaria. Nenhum filtro foi alterado.

## 5. Mudanças feitas (versão 1.02.0, schema 2101)
- **Runner removido.** Inputs `InpModoGestaoLucro`, `InpAtivarRunner`, `InpLucroParaAtivarRunner`, `InpLucroInicialProtegido`, `InpDistanciaRunnerMoney`, `InpPassoRunnerMoney` e o enum de modo foram retirados.
- **Trailing estilo PieceTrend** (menu próprio "TRAILING"): `InpAtivarTrailing` (false por padrão), `InpTrailingAtivacaoMoney` (A), `InpTrailingRazao` (0,60), `InpTrailingExpoente` (0,82), `InpTrailingRemoverTP` (true). Regra: arma com pico líquido ≥ A; `D = razão·A·max(pico/A,1)^expoente`; piso = pico − D (sempre > 0 e não decrescente). Dois mecanismos: SL de lucro na corretora (refeito no máximo 1×/s até aceitar) e saída por software se o lucro líquido tocar o piso. **Falha ao instalar o SL não fecha mais a posição.** Não foi portado o componente estrutural (maior swing) do PieceTrend, porque o Vegar não tem a lista de swings principais.
- **Origem do fechamento:** `DEAL_EXIT` do `TRADE_LIFECYCLE` agora traz `ExitOrigin` (`DEAL_REASON`: manual, mobile, web, EXPERT, SL, TP, stop-out…) e `EARequestedClose`; novo evento `POSITION_EXIT_ORIGIN` no DIAGNOSTIC.
- **Ruído de log:** `UI_LABEL_COLLISION_AVOIDED` só com `InpLogarColisaoRotulosUI=true` (padrão false); `MOMENT_STATE` passa a gravar mudanças só de fluxo com intervalo mínimo `InpMomentIntervaloSegundos` (padrão 2 s). Mudança de zona/estado do setup continua sendo gravada sempre.
- **Schema 2101:** colunas do `RUN_CONFIG` (`TrailEnabled`, `TrailActivation`, `TrailRatio`, `TrailExponent`, `TrailRemoveTP`; `ProfitMode` e `Runner*` removidas) e do `PROFIT_MANAGEMENT` (`TrailActive`, `TrailDistanceMoney`, `LastTrailUpdate`, `BrokerTPRemovedForTrail`). Os arquivos novos usam o prefixo `S2101` e não se misturam com os `S2100`.
- **Painel:** novo visual HUD (LZ Design System v2.0, `docs/PAINEL_DS.md`).

## 6. Riscos e limites
- **O trailing cria um SL de corretora** (de lucro). O operador não usa SL inicial; este SL só existe depois que o lucro líquido passa de A. Desligue com `InpAtivarTrailing=false` se não quiser.
- Com `InpTrailingRemoverTP=true`, o TP é removido ao armar: a saída passa a depender do trailing, o que pode devolver parte do alvo (no FluxMatrix o trailing rendeu 34 % do TP nas saídas únicas). **Hipótese não testada**; testar trailing ligado × desligado.
- Compilou (0 erros, 0 avisos) mas **não foi testado em conta nem em tester**: o trailing, os novos logs e o painel precisam de uma sessão em demo.
- Não há contrafactual dos setups bloqueados. Antes de mexer em `SWEEP_TOO_DEEP` e prazos, gravar a profundidade do sweep e um replay dos descartados e validar fora da amostra.
- Feche posições abertas antes de trocar de versão: o estado persistido do Runner antigo não é lido pelas chaves novas.
