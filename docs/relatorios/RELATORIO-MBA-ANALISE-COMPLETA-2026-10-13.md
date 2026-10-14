# MBA — Análise completa com a base grande (XAUUSD, 2024–2026, 2 feeds)

Data: 2026-10-13 · Coletor v1.22 · Feeds: IC Markets (`ICMarketsSC-Demo`, `XAUUSD`) e FP Markets (`FPMarketsSC-Live`, `XAUUSD.r`) — o **mesmo mercado**, não duas confirmações independentes.
Tabelas de auditoria: `docs/relatorios/mba/v2_varredura_validados.csv`, `v2_noticias_surpresa_reacao.csv`.

> **Resumo**
> 1. **Achado principal: o ouro cai, em média, no candle M5 das 10:25–10:30 de Londres** (−123 pts, t = −8,8, 70% dos 367 dias, mesmo sinal nos dois feeds). O horário **acompanha o relógio de Londres**, não o UTC: em UTC é 09:25 no verão e 10:25 no inverno. Substitui a hipótese anterior "09:15 UTC".
> 2. **Reversão depois de sequências de queda** (M1–M30): estatisticamente real (t por dia 4–10), mas pequena; só em M15/M30 passa de forma consistente do custo, e enfraqueceu do treino para a validação.
> 3. **Atividade e volatilidade** (por minuto, hora, notícias, agrupamento) continuam sendo o que o relógio prevê melhor; **direção por minuto/hora/vela/geometria: nada**.
> 4. **Notícias:** o preço se move 2,1× mais nos 15 min após a divulgação; **a surpresa (actual − forecast) não prevê direção** com correção de múltiplos testes (melhor: Payroll, nominal t = −2,8, q = 0,14).
> 5. **Erro de fuso corrigido na análise:** o `utc_time` gravado no backfill está 1 h errado no inverno; recalculei UTC pela regra da corretora (Nova York). Ver §1.
> 6. Nada aqui é regra de operação; o achado 1 virou **hipótese com critério de falsificação** (§7).

---

## 1. Base e validação

| TF | Candles (IC / FP) | Início | Observação |
|---|---|---|---|
| M1 | 200.342 / 200.345 | 20/03/2026 | histórico real do servidor; 1 candle isolado de 16/01/2024 excluído |
| M5 | 101.097 / 101.097 | 12/05/2025 | |
| M15 | 64.777 / 64.727 | 17/01/2024 | |
| M30 | 32.380 / 32.359 | 17/01/2024 | |
| H1 | 32.391 / 32.358 | 22/04/2021 | |
| H4 | 15.423 / 10.217 | 2016 / 2020 | |

- 0 `event_key` duplicada em todos os timeframes; M15 sem lacunas além da pausa diária e dos fins de semana.
- **Fuso (problema encontrado e tratado).** Nos candles reconstruídos (`BACKFILL_SERVER`) o EA gravou `server_utc_offset_sec = +10800` para todo o passado. A corretora segue o **fechamento de Nova York**: a pausa diária reabre às 01:00 do servidor no verão **e** no inverno, e o pico de range fica em 15–17h do servidor nas duas estações — logo servidor = UTC+3 durante o horário de verão dos EUA e UTC+2 no resto. O `utc_time` do arquivo está **1 h errado no inverno**. Toda a análise usa UTC recalculado por essa regra (com Londres = UTC+1 no horário de verão da UE e Nova York = servidor − 7 h). Correção no EA pendente (§8).
- **Spread histórico:** só existe para os últimos ~120 dias (ticks); custos de períodos antigos usam o spread mediano de 8,4 pts.
- Barras são de **bid**.

## 2. Achado A — queda no candle de 10:25 (Londres)

**Teste de relógio** (máximo |t| entre todos os horários do dia, com inversão de sinal aleatória por dia = FWER):

| TF | Relógio | Melhor horário | t | Média (pts) | Dias negativos | FWER p |
|---|---|---|---|---|---|---|
| M5 (367 dias) | UTC | 09:25 | −3,65 | −83 | 65% | 0,059 |
| M5 | **Londres** | **10:25** | **−8,77** | **−123** | **70%** | **0,001** |
| M5 | servidor / Nova York | 12:25 / 05:25 | −6,95 | −103 | 69% | 0,001 |
| M15 (706 dias) | UTC | 10:00 (positivo) | 3,86 | +56 | 42% | 0,005 |
| M15 | **Londres** | **10:15** | **−6,21** | **−96** | **61%** | **0,001** |
| M30 / H1 | todos | — | — | — | — | sem horário significativo (exceto reabertura, §6) |

O relógio de Londres dá o t mais forte e é o único em que o mesmo horário vale no verão e no inverno. Teste direto: em dias de verão (BST) o melhor horário em UTC é 09:15 (t = −6,6); em dias de inverno (GMT) é 10:15 UTC (t = −2,5; N menor). O FP dá resultados idênticos.

**Detalhes (IC; FP idêntico):**
- Candle M5 de 10:25 (Londres): −123 pts, mediana −109, 70% negativos. Vizinhos não significativos (10:20: −38, t = −2,5; 10:30: −26, t = −1,6).
- Janela 10:15–10:30: média −168, mediana −143, 66% negativos, t = −6,1. BST −141 (t = −5,7); GMT −234 (t = −3,2).
- Por ano (M15 das 10:15): 2024 −24 (t = −2,3; 56%), 2025 −57 (t = −2,7; 62%), **2026 −237 (t = −5,3; 68%)** — mesmo sinal em todos os anos, **mas cresceu muito em 2026**.
- Dia da semana: negativo em todos (seg −300, ter −114, qua −191, qui −170, sex −64).
- **M1 (178 dias de 2026):** a queda se espalha de 10:25 a 10:31, com pico às 10:29 (−65 pts, t = −5,5; 67% negativos), acumulado −251 até 10:30 e repique às 10:32 (+25).
- Possível relação com o leilão LBMA da manhã (10:30 em Londres) é **hipótese**, não testada.

**Ordem de grandeza econômica (não é backtest):** vender no open do M5 das 10:25 e recomprar no fechamento das 10:30, com spread + slippage de 8,4 / 15 / 25 pts: média líquida +114 / +108 / +98 pts por dia (1 pt = 0,01 USD; ≈ US$ 1 por lote de 100 oz), 66–68% dos dias positivos, pior dia −683 pts, drawdown acumulado −1.339 pts em 367 dias. Por trimestre (média líquida em pts): 2025-T2 +8, T3 +47, T4 +66, 2026-T1 +145, T2 +172, T3 +126. **Limitações:** barras de bid (entrada exata no open não é garantida), spread em horários de notícia pode ser maior, um regime, o efeito é recente e concentrado em 2026, sem simulação tick a tick.

## 3. Achado B — reversão após quedas (fraco)

Probabilidade de a próxima barra ser de alta e retorno médio da próxima barra, após sequência de baixa (IC, base ≈ 0–7 pts, spread mediano 8,5 pts, t por dia entre parênteses):

| TF | ≥ 4 de baixa seguidas | ≥ 5 de baixa seguidas |
|---|---|---|
| M1 | 52,0% alta, +6,9 pts (t = 4,6) | 52,5%, +7,1 (4,6) |
| M5 | 54,8%, +14,8 (5,1) | 53,6%, +4,4 (4,2) |
| M15 | 54,1%, +27,1 (7,5) | 55,6%, +42,6 (6,9) |
| M30 | 55,6%, +15,3 (8,3) | 57,3%, +52,8 (5,6) |

- Depois de sequências de **alta** o repique inverso é fraco ou nulo (retorno ≈ base), exceto na taxa de acerto (t de dia −3 a −7).
- **Desgaste:** M5 depois de 4 quedas: 57,3% (treino) → 53,0% (validação). Em M1/M5 o ganho em pontos é menor que o spread; em M15/M30 sobra pouco.
- `BREAK_DOWN` antes do evento: taxa de alta de +1 a +5 pp sobre a base em todos os anos/TFs (t por dia 3–9), mas `BREAK_UP` também reverte (t −3 a −6) e o retorno médio em pontos é inconsistente entre anos (M5 2026: −4 pts vs base −1). **Conclusão:** reversão de curto prazo detectável em probabilidade, **sem prova de valor econômico**.

## 4. Atividade e volatilidade (M1, 178 dias, horário corrigido)

- **Minuto da hora (range / ticks vs mediana):** :00 1,47× / 1,56×; :30 1,32× / 1,32×; :01 1,25× / 1,27×; :02 1,18×; :03 1,15×; mais calmos :58 (0,85×), :59, :54.
- **Hora (UTC corrigido):** 13h 1,74×; 14h 1,68×; 01h 1,46×; 12h 1,33×; 15h 1,30×; **20h 0,54×**, 04h 0,70×, 22h 0,72×.
- **Direção por minuto da hora:** faixa 47,7%–52,2%; 6 minutos com p < 0,05 (esperado 3); **0 com q < 0,05**; :13 = 49,6%, :30 = 50,0% (os "destaques" de 3 dias eram acaso).
- Notícias: média do |retorno| em 15 min após divulgação **666 pts vs 310 pts** de um M15 típico (2,1×; importância 3: 707 pts).

## 5. Notícias — surpresa × direção

3.212 valores com actual e forecast (77 tipos de evento), 2.701 com reação medida; 71 tipos com N suficiente. Reação de 30 min comparando "acima" × "abaixo do esperado":
- **Nenhum passa a correção (q mínimo 0,14).** |t| > 2 em 10 dos 71 (esperado ≈ 3,5).
- Melhor caso: **Payroll não-agrícola** (N = 31): acima do esperado → −911 pts em 30 min, abaixo → +1.436 pts (t = −2,8; q = 0,14). Sinal economicamente coerente (dado forte, ouro cai), mas **não confirmado**.
- Hipótese para teste futuro; exige mais ocorrências (12 por ano).

## 6. O que a varredura grande não confirmou

- 76.314 testes de grupo (direção, persistência, +5 barras) nos dois feeds, M1–H1, com treino nos primeiros 65% do tempo e validação nos 35% finais. Validados (q < 0,10 no treino, mesmo sinal e p < 0,05 na validação): 520.
- A grande maioria são variações de **reversão de curto prazo** (§3) e do **candle das 10:25** (§2); os 16 padrões clássicos de vela, geometria, volume, tick density, spread, níveis (dia anterior, sessão, swing), números redondos e dia da semana não produzem relação própria.
- Artefato: o horário de **reabertura da pausa diária** (01:00 do servidor) aparece com retorno positivo em H1 (+77 pts, FWER 5%); o spread cai de 40 para 10 pts ali (candle de bid). Não usar.
- Marginais não confirmados: M15 às 01:30 de Londres (+79 pts, t = 3,6) e 10:00 (+48, t = 3,5).

## 7. Hipóteses e critérios de falsificação (a partir de 14/10/2026, sem mudar a regra)

- **H1 (candle 10:25 de Londres):** média ≤ −60 pts e ≥ 55% dos dias negativos nas próximas 40 sessões (inclui a mudança do relógio do Reino Unido em **25/10/2026**: o horário deve ficar em 10:25 de Londres = 10:25 UTC, 1 h depois em UTC). **Falsificada** se a média for > −30 pts ou < 52% de dias negativos. **Também falsificada** se, depois de 25/10, o efeito permanecer em 09:25 UTC.
- **H2 (reversão após ≥ 4 quedas no M15):** mantém ≥ 53,5% de alta na barra seguinte e média ≥ +15 pts. Falsificada com ≤ 51,5% ou média ≤ base.
- **H3 (Payroll):** acima do esperado → retorno médio negativo em 30 min; avaliar a cada divulgação.
- **H4:** a assimetria de H1 em 2026 (−237 pts vs −24 em 2024) é regime, não lei — precisa ser acompanhada por trimestre.

## 8. Limitações e pendências

- **EA:** o backfill grava `utc_time` com o offset de hoje; corrigir para a regra Nova York (servidor = UTC+3 no horário de verão dos EUA, UTC+2 no resto) ou gravar só `server_time`. Até lá, recalcular na análise.
- **M1** só tem ~6 meses (limite do servidor); ticks (spread, contagem) só dos últimos 120 dias.
- IC e FP são o mesmo mercado; a replicação entre eles não é independente.
- Exatidão da execução: barras de bid, sem slippage tick a tick, sem comissão/swap.
- Achado A foi encontrado depois de varrer centenas de horários; a validação é o FWER, a consistência por ano e o teste futuro (H1).
- Mais anos de M5/M1 em outras corretoras ajudariam a confirmar a mudança de relógio (2024 tem só M15).
