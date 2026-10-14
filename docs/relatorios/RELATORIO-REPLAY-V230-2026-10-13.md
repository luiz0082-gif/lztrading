# Replay tick a tick da v2.30 (preset estilo v2.00) — resultado por horário

- **Data:** 2026-10-13
- **Script:** `tools/micromomentum/replay_v230.py` · saídas: `docs/relatorios/mba/replay_v230_trades.csv`, `replay_v230_por_hora.csv`
- **Corretora / símbolo:** IC Markets (`ICMarketsSC-Demo`, conta Raw Trading Ltd), XAUUSD, lote 0,01 (1 oz; US$ 1 por US$ 1 de preço)
- **Horários:** servidor (UTC+3 até 01/11/2026). **Local = servidor − 6 h** (confirmado nos CSVs). Tabelas em horário local.

## 1. O que foi possível com os dados do Market Behavior

O MBA tem M1 desde 20/03/2026 (200 mil candles), agregados de ticks por minuto e **só ~9 h de ticks brutos** (`RAW_TICKS`: 12/10 23:31 → 13/10 08:03). A v2.30 decide em janelas de 1 s com contagem de ticks, o que M1 ou agregados **não** reproduzem. Por isso o replay usa:

| Fonte | Ticks | Período |
|---|---|---|
| `ticks.csv` do próprio MicroMomentum (IC), sessões com `InpLogEveryTick = true` | 2.844.382 | 30/09 a 07/10 (inclui o tempo em que o EA estava parado por meta diária) |
| `RAW_TICKS` do MBA (IC) | 153.753 | 12/10 23:31 → 13/10 08:03 |
| **Total** | **2.998.135** | **103,2 h de dados, 16 trechos contínuos** |

## 2. Modelo

Janela de impulso 1000 ms (≥ 4 ticks, 30 pts, pullback ≤ 35 %, impulso ≥ 1,5 × spread, spread ≤ 10), cooldown 1000 ms (também após fechamento), 2 entradas por vela M1, até 6 posições, sem hedge, TP US$ 1,20 no servidor, recoil 100 pts com lucro > 0,45, comissão US$ 0,08 ida e volta, **latência 400 ms, slippage 3 pts contra**. **Sem meta diária, sem stop diário, sem stop por posição.** Posição sem saída em 6 h, ou até acabar o trecho de ticks, fica aberta e é marcada a mercado (65 entradas censuradas pelo fim do trecho foram excluídas).

**Calibração do detector de sinal contra o que o EA gravou** (2,84 M de ticks): `up` 96,1 % e `dn` 96,0 % dentro de 1 pt; contagem de ticks da janela 89,4 % dentro de ±1.

## 3. Resultado geral

274 entradas resolvidas, net **−US$ 553,70**, 89,4 % chegam ao TP, 10,6 % ficam presas (marcadas em 6 h), 26,6 % passam de −500 pts em algum momento.

| Dia | Entradas | Net | Presas | Profundas |
|---|---|---|---|---|
| 30/09 | 57 | −145,4 | 11 | 21 |
| 01/10 | 58 | +38,6 | 6 | 17 |
| **02/10** | 79 | **−406,1** | 6 | 18 |
| 05/10 | 50 | −74,4 | 6 | 14 |
| 06/10 | 10 | +11,2 | 0 | 1 |
| 07/10 | 1 | +1,1 | 0 | 0 |
| 13/10 | 19 | +21,3 | 0 | 2 |

## 4. Por horário (local; entre parênteses o servidor)

| Local (servidor) | Horas de dados | Entradas | TP | Presas | Net | Net por hora de dados |
|---|---|---|---|---|---|---|
| 19h (01) | 5,1 | 11 | 100 % | 0 % | +12,3 | +2,41 |
| 20h (02) | 5,5 | 16 | 94 % | 6 % | +5,2 | +0,94 |
| 21h (03) | 5,2 | 13 | 69 % | 31 % | −2,6 | −0,51 |
| 22h (04) | 5,0 | 10 | 100 % | 0 % | +11,2 | +2,24 |
| **23h (05)** | 5,0 | 16 | 62 % | 38 % | **−8,4** | −1,69 |
| 00h (06) | 5,0 | 5 | 100 % | 0 % | +5,6 | +1,12 |
| 01h (07) | 5,0 | 7 | 100 % | 0 % | +7,8 | +1,57 |
| **02h (08)** | 4,1 | 3 | 33 % | 67 % | **−49,0** | −11,96 |
| **03h (09)** | 4,0 | 8 | 50 % | 50 % | **−69,1** | −17,27 |
| 04h (10) | 4,0 | 11 | 100 % | 0 % | +12,3 | +3,08 |
| 05h (11) | 4,0 | 8 | 100 % | 0 % | +9,0 | +2,24 |
| **06h (12)** | 4,0 | 20 | 100 % | 0 % | +22,4 | **+5,60** |
| **07h (13)** | 4,0 | 17 | 100 % | 0 % | +19,0 | **+4,76** |
| **08h (14)** | 4,0 | 24 | 100 % | 0 % | +26,9 | **+6,72** |
| **09h (15)** | 3,4 | 15 | 87 % | 13 % | **−159,0** | −46,99 |
| **10h (16)** | 3,9 | 24 | 58 % | 42 % | **−471,3** | **−122,41** |
| 11h (17) | 3,7 | 13 | 100 % | 0 % | +14,6 | +3,92 |
| 12h (18) | 4,0 | 18 | 100 % | 0 % | +20,2 | +5,04 |
| 14h (20) | 4,8 | 6 | 100 % | 0 % | +6,7 | +1,40 |
| 15h (21) | 5,0 | 10 | 100 % | 0 % | +11,2 | +2,24 |
| 16h (22) | 5,1 | 6 | 100 % | 0 % | +6,7 | +1,32 |
| 17h (23) | 5,3 | 12 | 100 % | 0 % | +13,4 | +2,51 |

Sem amostra suficiente: 13h local (servidor 19h, 1 entrada).

## 5. Notícias

O calendário do MBA tem 21 eventos de importância 2–3 nesse período. Bloquear novas entradas de **5 min antes a 60 min depois** de cada evento remove 32 entradas e muda o net de **−553,70 para −95,00**. **17 dessas entradas são de 02/10** (dia do Payroll; 15:30 do servidor = 09:30 local) e somam **−475,60**, 86 % do prejuízo total. Com janela de +30 min o net só vai a −398,10.

## 6. Fatos, inferências e hipóteses

**Fatos**
- O detector de sinal reproduz o que o EA gravou em ~96 % dos ticks.
- Sem meta diária, o replay perde US$ 553,70 em 103 h de dados; 86 % dessa perda está em entradas feitas na janela de um evento em 02/10.
- Em 12 faixas locais (19h, 22h, 00h, 01h, 04h–08h, 11h–12h, 14h–17h) o replay deu TP em 100 % das entradas, mas com 5 a 21 % de entradas que andaram mais de 500 pts contra antes de voltar.
- Nas faixas 02h–03h, 09h–10h e 23h locais o replay teve 31 a 67 % de posições presas após 6 h.

**Inferências**
- Os resultados positivos reais da v2.30, v2.00 e v2.10 receberam ajuda da meta diária: ela parou o EA antes das quedas de 30/09 (16h servidor) e 02/10 (15h–16h servidor), que o replay mostra.
- As faixas boas estão boas nesta amostra: 4 a 5 horas de dados por faixa; uma tendência forte no período muda o ranking.

**Hipóteses**
- Bloquear entradas perto de eventos de importância 3 elimina a maior parte do prejuízo; o teste usa um evento dominante (Payroll de 02/10) e pode não se repetir.
- O ranking por horário deve ser refeito com mais dias de ticks (o EA com `InpLogEveryTick = false` não gera essa base).

## 7. Limitações

- **Não é o terminal:** latência fixa de 400 ms, slippage fixo de 3 pts, sem fila, sem rejeições, sem `frozen`/`position closed`.
- **Cobertura:** 103 h em 8 dias, um regime, 16 trechos; entre 3 e 5 h de dados por horário.
- **Throughput menor que o real:** nas mesmas horas o replay faz entre 40 e 60 % das entradas do EA real (por exemplo 30/09, 14h servidor: 8 simuladas contra 12 reais); o resultado por trade nas faixas boas é parecido (+1,12 contra +1,1 a +1,2).
- **MTM em 6 h:** posições que o EA real seguraria por mais tempo (68 % das profundas voltaram ao TP, mediana 169 min) entram como perda marcada em 6 h, o que exagera a cauda.
- **Sem comparação direta com o EA real no mesmo trecho**, porque a v2.30 rodou com `InpLogEveryTick = false` (sem ticks).
