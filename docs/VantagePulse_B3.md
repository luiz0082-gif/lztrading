# VantagePulse B3 v1.05

EA tick-driven para WIN (B3). Fonte: `MQL5/Experts/VantagePulse_B3/VantagePulse_B3_v1.05.mq5`. Presets em `MQL5/Experts/VantagePulse_B3/presets/`.

## Mudanças em relação à v1.02 (a v1.01 do terminal estava vazia)

- **v1.03**: modo de stops virtuais (`InpVirtualStops`). No tester da Clear, SL/TP de servidor disparam a preço falso (compra e fecha no mesmo segundo, comentário "tp" sem o preço ter sido tocado), o que invalida qualquer teste.
- **v1.03**: cooldown, intervalo entre entradas, retry de fechamento e timeout de ordem usam o horário do **tick** (`NowMs()`), não `GetTickCount64()`. No tester o relógio do PC corre mais rápido que o mercado e a frequência de entradas ficava irreprodutível (mesma config: 97 operações/−49 numa rodada, 73/+128 em outra).
- **v1.04**: escada opcional de contratos (`InpLadderEnable`, desligada por padrão): +`InpLadderStep` por **entrada** até `InpLadderLevels`, depois volta ao início. Não é martingale (nunca sobe por perda).
- **v1.05**: painel novo (só valores líquidos, minimizar/maximizar, FECHAR TUDO em 2 cliques, PAUSAR/RETOMAR), grupos de inputs numerados (Profit, Risco e Stop Loss separados) e chaves liga/desliga: `InpUseHardStop` (**desligado por padrão**), `InpUseTakeProfit`, `InpUseTrailing`, `InpUseMaxHolding`, `InpUseDailyLossLimit`, `InpUseSpreadFilter`.

## Backtest (WINZ26, ticks reais Clear, 13/10–11/11/2026, 21 pregões, depósito R$700, atraso 11 ms, stop virtual)

Preset de sinal: janelas 1000/3000/8000 ms, score ≥34, eficiência rápida ≥0,12, cooldown 200 ms, hold máx 25 s, TP 160, trailing arma 150.

| Stop | Escada | Operações | Líquido | Saldo mín. | Pior queda | Dias positivos |
|---|---|---|---|---|---|---|
| 100 | não (1 ctr) | 9.651 | +R$ 54.138 | R$ 682 | R$ 173 | 21/21 |
| 100 | 1–10 | 9.651 | +R$ 296.025 | R$ 586 | R$ 1.081 | 21/21 |
| 150 | não | 9.200 | +R$ 45.724 | R$ 642 | R$ 204 | 21/21 |
| 150 | 1–10 | 9.200 | +R$ 257.696 | **R$ 162** | R$ 1.578 | 21/21 |

Sensibilidade a latência (lote 1, 13–23/10): 0/150/400/1000 ms → 22,6 / 22,6 / 21,1 / 14,0 pts por operação.

## Recuo (trailing) e stops, 15 pregões (13/10–03/11), R$700, 1 contrato

- O trailing quase nunca disparava (2 de 4.404 saídas; armava em 150 pts, o TP de 160 saía antes; 79% saíam por tempo, devolvendo ~29 pts do pico). Melhor recuo testado: **arma 40 pts, distância 10, 40% do pico** (+R$ 63.858 vs +R$ 54.138 em 21 pregões, PF 2,34).
- Stop 100 pts: +R$ 56.766 (PF 2,34, saldo mín R$ 682). Stop 150: +R$ 50.600. Stop 750 pts (= R$150 com 1 contrato): +R$ 25.107, pior dia −R$ 3.799, saldo mín R$ 390.
- Com escada 1–10: stop 100 +R$ 314.997 (mín R$ 682); stop 150 +R$ 279.809 (mín R$ 183); stop 750 quebra a conta no 1º dia (mín −R$ 39).

## v1.06 (arquivo novo; a v1.05 permanece intacta)

- `InpUseMoneyStop` + `InpMoneyStopAmount`: stop em R$ da posição inteira; vale o mais curto entre pontos e dinheiro (conversão por SYMBOL_TRADE_TICK_VALUE). Validado: R$ 20 com 1 contrato = stop 100 pts (resultado idêntico).
- `InpUseTimeProfitExit` + `InpTimeProfitSeconds` + `InpTimeProfitMinPoints`: saída por tempo no positivo. **Resultado ruim, deixar desligado**: 8 s e 15 s quebram a conta no 1º dia (cortam ganhos em ~15 pts e deixam perdas correrem até o stop); 25 s com espera até 90 s deu +R$ 46.963 (PF 1,92, queda R$ 359) contra +R$ 56.766 (queda R$ 115) sem a saída.

## Diagnóstico ao vivo vs tester (demo, 13/11/2026, v1.05)

Ao vivo (163 saídas): tempo 63% (média −14,8 pts, 31% ganham), stop 12% (−106), trailing 12% (+30), sinal oposto 13% (+33), **alvo 0%**. Tester (8.376 saídas): tempo 58% (+24,6), **alvo 18% (+185 pts)**, stop 13% (−115), trailing 11%, sinal oposto 0%. O lucro do tester vem de movimentos de 160+ pts em 25 s que não apareceram ao vivo (esperado ~29 de 163, obtido 0). Latência ao vivo 31 ms (mediana), slippage de entrada 0. Causa provável (não provada): saltos/ticks faltando no histórico do tester. Tratar o tester como otimista.

## v1.07 (arquivo novo; v1.05 e v1.06 intactas)

- Seletor único `InpStopType` (Desligado/Pontos/Dinheiro) + `InpStopPoints` + `InpStopMoney` (R$ da posição inteira).
- Saída por tempo **só no lucro** (`InpUseTimeExit`, prazo, lucro mínimo): nunca fecha perda por tempo; perda só por stop ou fechamento do dia (`InpForceEndOfDayClose`, 17:40 servidor). Substitui hold máximo e tempo-no-positivo da v1.06.
- Testes 13/10–03/11 (15 pregões), R$700, atraso 12 ms, stop virtual:

| Config | Líquido | PF | Saldo mín | Pior queda | Maior posição aberta |
|---|---|---|---|---|---|
| 1 ctr, stop 100, tempo 25 s | +R$ 47.020 | 1,92 | R$ 679 | R$ 389 | 6 min |
| 1 ctr, stop 100, tempo 10 s | quebra no 1º dia | 0,73 | −R$ 9 | – | – |
| 1 ctr, stop 100, tempo 5 s | quebra no 1º dia | 0,40 | −R$ 5 | – | – |
| 1 ctr, stop 100, tempo 40 s | +R$ 36.265 | 1,69 | R$ 659 | R$ 444 | 6 min |
| 1 ctr, stop 100, tempo 60 s | +R$ 42.964 | 1,78 | R$ 659 | R$ 422 | 7 min |
| 1 ctr, stop 150, tempo 25 s | +R$ 33.576 | 1,61 | R$ 648 | R$ 516 | 11 min |
| Escada 1–10, stop 100, tempo 25 s | +R$ 248.792 | 1,87 | R$ 644 | R$ 2.511 | 6 min |
| Escada 1–10, stop R$150, tempo 25 s | +R$ 182.205 | 1,77 | R$ 320 | R$ 2.852 | **2 h 20 min** |
| Escada 1–10, stop R$300, tempo 25 s | quebra no 1º dia | 0,92 | −R$ 148 | – | – |

Custo da regra "nunca fechar perda por tempo" em relação à v1.05: 1 ctr +R$ 56.766 → +R$ 47.020 (queda máx. R$ 115 → R$ 389); escada +R$ 314.997 → +R$ 248.792 (queda máx. R$ 911 → R$ 2.511).

## v1.07: 16 testes em período único de 30 dias (13/10–11/11/2026, 21 pregões, R$700, atraso 12 ms, TP 160 salvo indicação)

1 contrato (tempo no lucro 25 s, salvo indicação): stop 100 +R$ 51.225 (PF 1,87, DD 389); stop 100 prazo 60 s +R$ 46.336; stop 80 +R$ 58.869 (PF 2,05, DD 292); stop 120 +R$ 43.777; stop 100 TP240 +R$ 62.891 (PF 2,28); **stop 80 TP240 +R$ 69.990 (PF 2,54, DD 283)**; **stop 60 TP240 +R$ 77.023 (PF 2,87, DD 200)**; SEM stop +R$ 4.394, 13/21 dias positivos, pior dia −R$ 1.988, posição aberta até 8 h.

Escada 1–10: stop 100 +R$ 271.958 (DD 2.511); stop 100 prazo 60 s +R$ 253.030; stop 80 +R$ 326.846 (PF 2,06); stop 120 +R$ 237.039; stop R$200 (posição inteira) quebra a conta; **stop 80 TP240 +R$ 377.657 (PF 2,51, DD 1.616)**; **stop 60 TP240 +R$ 437.498 (PF 2,98, DD 1.463)**; SEM stop quebra a conta (pior dia −R$ 20.429).

Todos os que sobreviveram: 21/21 dias positivos. Stops mais curtos são melhores no tester porque ele executa o stop no preço exato; ao vivo, slippage e spread pesam mais num stop curto (stop 80 é a escolha mais conservadora). Presets: `VantagePulse_B3_v107_{LOTE1,ESCADA1a10}_{STOP80,STOP60}_TP240.set`.

## Erro de preset corrigido (13/11/2026)

Os `.set` v105/v106/v107 gerados antes usavam o padrão do código para parâmetros que os testes herdavam do ini antigo (MaxMidCounterMovePts 15→10, MaxSlowCounterMovePts 30→25, MaxSpreadPoints 10→15, MinMidTicks 6→8). Rodando o arquivo como entregue, a conta quebrou em 16/10. Todos foram removidos e regenerados por `tools/vp/make_presets.py` (valores exatos dos testes, todas as chaves explícitas) e **verificados rodando o próprio arquivo**: `LOTE1_STOP80_TP240` = +R$ 62.086 (13/10–02/11, 14/14 dias positivos), igual à config testada. Regra: todo preset novo deve ser gerado dos valores testados e reexecutado a partir do arquivo antes de ser entregue. Nota: só 4 parâmetros fora do valor testado foram suficientes para a conta quebrar, o que indica sensibilidade alta (sinal de ajuste fino ao período).

## Presets finais (13 arquivos, todos verificados rodando o próprio .set)

Em `MQL5/Experts/VantagePulse_B3/presets/` e, no terminal Clear, em `MQL5\Presets` e `MQL5\Profiles\Tester`. Geradores: `tools/vp/make_presets.py` (v1.07) e `tools/vp/make_presets_old.py` (v1.05/v1.06; só copia se o resultado do arquivo bater com o informado, tolerância 2%). A latência do tester não faz parte do `.set`: usar 11 ms (v1.05) e 12 ms (v1.06/v1.07).

| Arquivo | Período do teste | Resultado informado |
|---|---|---|
| v105 LOTE1_STOP100 / STOP150 | 13/10–03/11 | +R$ 56.766 (8.497 ops) / +R$ 50.600 (8.123) |
| v105 ESCADA1a10_STOP100 / STOP150 | 13/10–03/11 | +R$ 314.997 / +R$ 279.809 |
| v106 LOTE1_STOP100 e LOTE1_DINHEIRO_R20 | 13/10–03/11 | +R$ 56.792 (8.497 ops), idênticos |
| v106 ESCADA1a10_STOP100 | 13/10–03/11 | +R$ 315.132 |
| v107 LOTE1 STOP60_TP240 / STOP80_TP240 / STOP100_TP160 | 13/10–11/11 (ToDate 12/11) | +R$ 77.023 / +R$ 69.990 / +R$ 51.225 (21/21 dias positivos) |
| v107 ESCADA1a10 STOP60_TP240 / STOP80_TP240 / STOP100_TP160 | 13/10–11/11 (ToDate 12/11) | +R$ 437.498 / +R$ 377.657 / +R$ 271.958 (21/21 dias positivos) |

Lote final gerado e verificado em 13/11/2026 (todos os 13 arquivos com o mesmo horário de criação): `tools/vp/make_presets_all.py`. Dias positivos: v105 e v106 15/15; v107 21/21. Pior dia: v105 LOTE1 STOP100 +R$ 1.714, ESCADA STOP100 +R$ 9.795; v107 LOTE1 STOP80 +R$ 446, ESCADA STOP80 +R$ 3.031.

## Melhores horários (stop 80, TP 240, 30 dias, horário do servidor)

1 contrato: 09h +R$ 9.142; **10h +R$ 21.500**; **11h +R$ 16.126**; 12h +R$ 6.750; 13h +R$ 4.114; 14h +R$ 3.043; 15h +R$ 4.145; 16h +R$ 4.017; 17h +R$ 1.153. Escada: 10h +R$ 120.747, 11h +R$ 85.661, 09h +R$ 48.484; tarde (13–16h) entre +R$ 16 mil e +R$ 24 mil por hora. Todas as horas positivas; lucro por operação cai de ~R$ 10 (10–11h) para ~R$ 4–5 (tarde).

## CORREÇÃO IMPORTANTE (13/11/2026, 17h): base de ticks do harness incompleta

Rodando o preset `v107_LOTE1_STOP80_TP240` **na plataforma do usuário** (Clear instalado, sem e com modo visual, resultados idênticos): 11.142 operações, **+R$ 43.639**, PF 1,73, **9/14 dias positivos**: 16/10 −557, 19/10 −1.207, 20/10 −1.828, 21/10 −966, 22/10 −738. Os demais dias são iguais ao harness. No harness o mesmo arquivo dava 7.370 operações, +R$ 62.086, 14/14 dias positivos.

Causa: a base de ticks convertida pelo tester do harness (`C:\ClearMM_Tester\Tester\bases\...\WINZ26\202610.tkc`, 85,6 MB) tem ~3 MB a menos que a do tester do usuário (88,6 MB), embora venham do mesmo arquivo do terminal. Faltavam ticks em 16–22/10 e o sinal lucrava com os "saltos". **Todos os resultados do harness que incluem 16–22/10 (e possivelmente outros dias) estão superestimados**, inclusive "21/21 dias positivos". Os resultados válidos são os da plataforma do usuário; o harness precisa usar a base do tester do usuário antes de qualquer novo teste.

## Limitações (não omitir)

- **Sem custos**: o tester não cobra corretagem/emolumentos; são ~460 operações/dia.
- **Mesmos dias** usados para escolher os filtros; não há janela independente anterior a 13/10.
- Ganho de ~28 pts/operação em tick scalping é incomum; tratar como hipótese a confirmar em demo.
- Stop **virtual não protege** se terminal/VPS/internet cair. Stop de servidor não pôde ser testado no tester da Clear.
- O painel foi compilado (0 erros) e rodou sem erro no tester, mas **não foi inspecionado visualmente** num gráfico.
- Os limites diários da v1.04/v1.05 com `InpIncludeFloatingInDaily=true` se auto-bloqueiam no tester da Clear (POSITION_PROFIT quebrado); nos testes usei `false`.
- Os testes rodaram numa cópia isolada do terminal Clear (`C:\ClearMM_Tester`) que **conecta na conta Clear** enquanto roda; ela não tem EA conectado e não envia ordens reais.
