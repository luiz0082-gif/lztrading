# Investigação quantitativa — alcance em pontos, horário exato, direção e repetição (MBA, 10 ativos)

**Data:** 2026-10-17 · **Dados:** MarketBehaviorAnalyzer v1.23 (schema 3), `Common\Files\MarketBehaviorAnalyzer` · **Código:** `tools/mba/mba_reach_*.py`
**Saídas completas:** `docs/relatorios/mba/reach/` (um `RELATORIO.md` por ativo com as seções A–I + todos os CSVs, inclusive a tabela minuto a minuto de cada ativo).

> **Resumo em 6 linhas.**
> 1. O **relógio prevê muito bem QUANTO o preço anda** (volatilidade): em qualquer ativo, a chance de andar k pontos varia 2–3× entre horas do dia (ouro: 300 pts em 60 min = 34% às 23h e 74% às 16h do servidor). Isso é real, estável e útil para dimensionar alvo/tempo — **mas não diz a direção.**
> 2. **Direção pelo relógio** quase não existe fora de dois casos: (a) **ouro 12:15–12:29 do servidor (10:15–10:29 Londres) VENDA** — reconfirmado minuto a minuto (M1), em M5 e no bloco de 15 min; (b) um aglomerado pequeno de **COMPRA nos pares de iene às 22:10–22:35 do servidor** (1,3–2 pips líquidos, quase nada depois da comissão).
> 3. Centenas de "horários validados" nos pares de FX caem **na rolagem (23:00–01:15 do servidor)**: o bid afunda com o spread e volta na reabertura. É artefato de cotação, não operável.
> 4. **Corrida simétrica** (alvo k contra limite adverso k): depois do spread, **nenhum ativo passa de 50%** em média (42–51% dos casos decididos). Alvo pequeno "sem stop" acerta 90–99%, mas a média é ditada pela cauda (pior operação de −960 a −13.920 pts).
> 5. **Padrões estruturais** (condição × hora/sessão: rompimentos, sequências, compressão, posição vs máxima/mínima do dia anterior, spread, volume de ticks…): ~1 milhão de testes; **nada que supere o placebo** fora da rolagem/abertura asiática.
> 6. Nenhum padrão aqui é "lucrativo comprovado": os candidatos são hipóteses com validação fora da amostra, sem backtest com execução real nem comissão.

---

## 0. Como a investigação foi feita (reprodutível)

| Passo | Script | O que faz |
|---|---|---|
| 1 | `mba_reach_load.py` | Lê `CANDLES` M1/M5/M15 (schema 3), remove duplicatas, ordena, recalcula UTC pela regra de DST de Nova York (servidor = UTC+3 no verão americano, UTC+2 no resto) e Londres, mede lacunas, inconsistências OHLC, cobertura de spread por tick → `auditoria_candles.csv`, `symbol_specs.json` |
| 2 | `mba_reach.py` | **Motor de primeira passagem.** Para **cada barra** como entrada (na abertura), mede em que barra o preço alcança cada distância k (25…30.000 pts) a favor e contra, dentro de uma janela de relógio de 60 e 240 min. Conferido contra força bruta em 2.000 entradas aleatórias: 0 divergências |
| 3 | `mba_reach_analyze.py` | Relatórios B, C, E, F, G, I por ativo/timeframe/janela |
| 4 | `mba_reach_struct.py` | Relatório D (condições estruturais) |
| 5 | `mba_reach_summary.py` | Relatório H: contagens vs placebo, confirmação entre timeframes, fichas |
| 6 | `mba_reach_report.py` | Gera `docs/relatorios/mba/reach/<ATIVO>/RELATORIO.md` |

**Definições (respeitando o que é executável no instante da decisão):**
- **Entrada:** abertura da barra do horário (nada da própria barra é usado para decidir). BUY entra no **ask** (= bid de abertura + spread), SELL no **bid**.
- **Alcance "bruto"** (comportamento do preço): máxima/mínima de bid posteriores, sem exigir fechamento na distância. **Alcance "líquido"** (operação): BUY sai no bid; SELL recompra no **ask de cada barra** (mínima + spread daquela barra).
- **Ordem dos eventos:** com velas, não se sabe se a máxima veio antes da mínima. Quando alvo e limite adverso caem **na mesma barra**, o caso é **indeterminado** e contado como **perda**. Por isso as corridas com alvos pequenos usam M1 (em M15, 63% das corridas de 50 pts no ouro são indeterminadas; em M1, 31%; a partir de 150 pts, <4%).
- **Custos:** spread medido nos ticks da barra; onde não há tick (dados antigos), mediana do spread por faixa de 30 min do servidor medida nos ticks (o `rates.spread` é 0 em ECN e esconderia o custo). **Swap** cobrado quando a posição está aberta às 00:00 do servidor (triplo na quarta; US30 na sexta). **Comissão não incluída** — os arquivos declaram `commission_known = FALSE`; ver cenário de comissão na tabela final.
- **Testes:** descoberta = primeiros 60% dos dias, validação = últimos 40% (cronológico). Benjamini-Hochberg (BH) na descoberta. Placebos: (i) direção — sinal aleatório por dia, 200×, preservando a correlação entre horários do mesmo dia; (ii) operação — horários embaralhados dentro de cada dia; (iii) estrutural — resultado deslocado 17…113 dias (mantém distribuições, destrói o vínculo condição→resultado). **Um conjunto de padrões só é crível se passa mais vezes do que no placebo.**

### Dois erros que encontrei e corrigi durante a investigação (para não repetir)
1. **Média por dia em sinais condicionais vaza o futuro.** No primeiro passe, "venda após rompimento de máxima no pregão de NY" no ouro dava +550 pts/op na validação. A força bruta mostrou que, por entrada, o resultado era −23 pts. Causa: quando o rompimento continua, surgem várias entradas no mesmo dia (todas perdedoras) e a média por dia diluía essas perdas — o **número de sinais no dia depende do que o preço faz depois**. Corrigido para média por entrada com erro-padrão agrupado por dia. Com isso o ouro foi de 635 "padrões estruturais validados" para **0**.
2. **Saída por tempo da VENDA precisa pagar o spread da barra de saída**, não o da entrada. Sem isso, toda venda que atravessa a rolagem parecia lucrativa (o bid afunda às 23:xx).

---

## A. Qualidade e cobertura dos dados

| Ativo (corretora) | M1 | M5 | M15 | Spread mediano (pts) | Observações |
|---|---|---|---|---|---|
| XAUUSD (IC) | **26/03→16/10/2026 (146 d)** | 15/05/2025→ (369 d) | 22/01/2024→ (708 d) | 5–7 (40 fixo 23:40–23:59) | ponto 0,01 |
| XAGUSD (IC) | 22/01/2024→ (708 d) | 369 d | 708 d | 12–21 | M1 com 571 lacunas >1 min (fora da rolagem) |
| US30 (IC) | **26/03/2026→ (147 d)** | 370 d | 709 d | 120 (fixo) | ponto 0,01; movimentos grandes: grade estendida até 30.000 pts |
| DXY_Z6 (IC) | **11/03/2026→ (158 d)** | 370 d | **10/09/2024→ (543 d)** | 30 (fixo) | futuro dez/26; 437 lacunas >15 min em M15 (horário de pregão restrito) |
| USDJPY (IC) | **06/04/2026→ (140 d)** | 370 d | 711 d | 0,8–1 | |
| EURJPY (IC) | 22/01/2024→ (711 d) | 370 d | 711 d | 2–4 | |
| GBPJPY (IC) | 22/01/2024→ (711 d) | 370 d | 711 d | 3–6 | |
| USDCHF (IC) | **06/04/2026→ (140 d)** | 370 d | 711 d | 0,7–2 | |
| AUDUSD (FP) | **06/04/2026→ (140 d)** | 370 d | 712 d | 12–14 | |
| NZDUSD.r (FP) | **06/04/2026→ (140 d)** | 370 d | 712 d | 1–3 | |

- **Sem duplicatas, sem linhas fora de ordem, sem OHLC inconsistente** em nenhum arquivo. Alinhamento M15 × M1 agregado: 100% (sem deslocamento de barra).
- **Limitação principal:** em 7 dos 10 ativos o M1 só cobre ~5–7 meses de 2026 (efeito do teto de catch-up já conhecido; o EA v1.23.1 corrige, mas o histórico ainda não foi refeito). Nesses ativos, **resultados minuto a minuto são exploratórios** (um regime só, ~85 dias de descoberta e ~57 de validação) e só valem se confirmados em M5/M15.
- Spread medido por tick só existe em 12–62% das barras (ticks recentes); o resto usa o perfil por horário.
- Ativos excluídos: BTCUSD (descartado a pedido em análise anterior) e XAUUSD.r da FP (EA parado em 27/04/2026).
- Barras são de **bid**. Na rolagem (23:00–01:15 do servidor) o bid é distorcido pelo spread: qualquer "padrão" ali precisa de verificação com ask/ticks antes de ser levado a sério.

### Conversão pontos → dinheiro (especificação da corretora)

| Ativo | point | tick value (US$/tick/lote) | US$ por 100 pts: 0,01 lote | 0,1 lote | 1 lote | 10 lotes | swap compra / venda |
|---|---|---|---|---|---|---|---|
| XAUUSD | 0,01 | 1,00 | 1,00 | 10,00 | 100,00 | 1.000,00 | −55,5 / +38,8 pts |
| XAGUSD | 0,001 | 1,00 | 1,00 | 10,00 | 100,00 | 1.000,00 | −7,8 / +5,3 pts |
| US30 | 0,01 | 0,01 | 0,01 | 0,10 | 1,00 | 10,00 | −12,42 / −0,16 US$/lote (≈ −1.242 / −16 pts) |
| DXY_Z6 | 0,001 | 0,10 | 0,10 | 1,00 | 10,00 | 100,00 | 0 |
| USDJPY / EURJPY / GBPJPY | 0,001 | 0,633 | 0,63 | 6,33 | 63,30 | 632,99 | +8,3/−17,1 · +4,2/−10,1 · +10,1/−21,3 pts |
| USDCHF | 0,00001 | 1,213 | 1,21 | 12,13 | 121,33 | 1.213,27 | +6,2 / −13,1 pts |
| AUDUSD / NZDUSD.r | 0,00001 | 1,00 | 1,00 | 10,00 | 100,00 | 1.000,00 | −0,4/−2,7 · −4,5/+0,5 pts |

Quantidade de contratos **não muda a distância** que o preço precisa percorrer: muda só o dinheiro por ponto. Comparações entre ativos devem ser feitas em % de alcance para o mesmo múltiplo de volatilidade, não em pontos absolutos (100 pts de XAUUSD = US$ 1,00 no preço; 100 pts de EURJPY = 0,100 iene = 10 pips).

---

## B. Varredura completa por horário (minuto a minuto)

Para **todos** os minutos (M1), blocos de 5 min (M5) e 15 min (M15), BUY e SELL separados, todos os limiares: `docs/relatorios/mba/reach/<ATIVO>/B_varredura_relogio_<TF>_W<janela>.csv.gz` (colunas: horário, k, n, acertos e % BUY, acertos e % SELL, % sobe-k-primeiro, % cai-k-primeiro, minutos medianos até o alvo, excursão adversa mediana antes do alvo). Os `RELATORIO.md` de cada ativo listam os maiores/menores alcances e a maior assimetria.

**O que a varredura mostra (todos os ativos):**
- O alcance segue o **relógio da volatilidade**, idêntico para BUY e SELL. Ouro, % das entradas M15 que chegaram a +300 pts líquidos em 60 min: 34% (23h) · 45% (01h) · 60% (03h) · 47% (06–07h) · 58% (08–10h) · 53% (11–13h) · **63% (14h) · 72–74% (15–17h)** · 58% (19h) · 44% (22h). O mesmo formato aparece em prata, US30 e FX: pico na abertura de NY (15–17h do servidor = 08–10h NY) e segundo pico na abertura de Londres.
- Em cada minuto, BUY e SELL ficam a 1–3 pontos percentuais um do outro; diferenças maiores só na rolagem.
- **Hora em que se forma a máxima/mínima do dia** (`I_hora_max_min_dia_*.csv`): concentra-se na primeira hora após a reabertura (01h; ouro 10% das máximas e 14% das mínimas) e nas 15–17h. Ou seja: o extremo do dia costuma estar na abertura asiática ou na abertura de NY.

---

## C. Distâncias percorridas (probabilidade de alcançar k pontos, líquido de spread)

M15, todas as entradas seg–sex, janela de 60 e 240 min (n = 63–68 mil entradas por ativo; DXY 46 mil). "–" = fora da faixa testada (quase sempre ou quase nunca alcançada).

| ativo | janela | lado | ≥100 | ≥200 | ≥300 | ≥500 | ≥1000 | ≥2000 | ≥3000 | ≥5000 | ≥10000 | ≥20000 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| XAUUSD | 60 | BUY | 82% | 68% | 56% | 39% | 18% | 5% | 2% | – | – | – |
| XAUUSD | 60 | SELL | 81% | 66% | 55% | 39% | 19% | 6% | 3% | – | – | – |
| XAUUSD | 240 | BUY | 92% | 85% | 77% | 64% | 41% | 19% | 10% | 3% | – | – |
| XAUUSD | 240 | SELL | 90% | 81% | 74% | 61% | 40% | 20% | 11% | 4% | – | – |
| XAGUSD | 60 | BUY | 36% | 21% | 14% | 7% | 2% | – | – | – | – | – |
| XAGUSD | 240 | BUY | 60% | 40% | 30% | 18% | 8% | 2% | 1% | – | – | – |
| XAGUSD | 240 | SELL | 60% | 43% | 32% | 20% | 9% | 3% | 1% | – | – | – |
| US30 | 60 | BUY | – | 92% | 90% | 86% | 76% | 60% | 47% | 30% | 12% | 3% |
| US30 | 240 | BUY | – | – | 96% | 94% | 89% | 80% | 71% | 56% | 33% | 13% |
| US30 | 240 | SELL | – | – | 95% | 93% | 88% | 79% | 70% | 55% | 33% | 14% |
| DXY_Z6 | 240 | BUY | 35% | 14% | 6% | 2% | – | – | – | – | – | – |
| USDJPY | 60 | BUY | 39% | 15% | 6% | 2% | – | – | – | – | – | – |
| USDJPY | 240 | BUY | 66% | 42% | 26% | 10% | 2% | – | – | – | – | – |
| EURJPY | 240 | BUY | 66% | 42% | 26% | 10% | 1% | – | – | – | – | – |
| GBPJPY | 240 | BUY | 72% | 51% | 35% | 16% | 3% | – | – | – | – | – |
| USDCHF | 240 | BUY | 39% | 14% | 6% | 1% | – | – | – | – | – | – |
| AUDUSD | 240 | BUY | 35% | 12% | 5% | 1% | – | – | – | – | – | – |
| NZDUSD.r | 240 | BUY | 35% | 11% | 4% | – | – | – | – | – | – | – |

(Tabela completa, BUY e SELL de todas as janelas, IC95, tempo até o alvo e excursão adversa: `C_distancias_*.csv` de cada ativo.)

**Corrida alvo k × limite adverso k (M1, só casos decididos):** ouro 43–51%, USDJPY 42–55%, EURJPY 39–52%, US30 27–45%. Quanto menor o k, pior — o spread pesa mais. **Com alvo = limite, em média se perde.** Para ganhar no simétrico seria preciso uma direção de pelo menos alguns pontos percentuais acima de 50% *depois* do spread — e isso só aparece nos horários da seção G.

**Excursão adversa antes do alvo** (M1, janela 60): ouro, para alcançar +300 o preço anda em média 190–200 pts contra antes (mediana); USDJPY +100 → 25 pts contra; US30 +1.000 → 870–920 pts contra. Para quem opera sem stop isso é o "preço de entrada" do alvo.

---

## D. Padrões estruturais (condição × horário)

12 condições observáveis no fechamento da barra anterior (vela anterior forte/fraca, retorno das 4 últimas, sequência de cores, compressão, posição vs máxima/mínima do dia anterior, distância da abertura do dia, rompimento de máxima/mínima de 20 barras com fechamento fora ou falha, movimento extremo, spread alto, volume de ticks, dia anterior, dia da semana) × hora (24), e pares de condições × sessão. Resultado medido **acima do efeito do relógio** (menos a média do mesmo horário na descoberta).

| Ativo | testes | validados | placebo (média / máx.) | leitura |
|---|---|---|---|---|
| XAUUSD | 94.164 | 1 | 6,0 / 15 | nada |
| XAGUSD | 94.590 | 11 | 11,0 / 31 | nada |
| US30 | 99.984 | 11 | 14,4 / 39 | nada |
| DXY_Z6 | 94.188 | 0 | 7,1 / 33 | nada |
| USDJPY | 100.686 | 3 | 13,6 / 42 | nada |
| EURJPY | 100.968 | 9 | 4,9 / 16 | no limite do acaso |
| GBPJPY | 100.692 | 35 | 7,8 / 21 | acima — **31 de 35 são rolagem/sessão tardia/spread alto**; resto: reversão após rompimento de mínima na Ásia |
| USDCHF | 101.688 | 103 | 27,5 / 84 | acima — **78 de 103 são rolagem/spread alto**; resto: sexta 20–21h (janela truncada pelo fechamento semanal) e reversão de queda na Ásia |
| AUDUSD | 101.496 | 72 | 97,9 / 241 | nada |
| NZDUSD.r | 101.970 | 61 | 151 / 522 | nada |

**Conclusão D:** rompimentos, falsos rompimentos, compressão→expansão, sequências, posição vs PDH/PDL, movimentos extremos, volume de ticks — **nenhum** desses padrões muda de forma consistente o que vem depois, além do que o horário já explica. O único resíduo (reversão de queda nas primeiras horas da Ásia em CHF/JPY) mistura-se com a reabertura do mercado e precisa de ticks/ask para ser checado.

---

## E. BUY × SELL (direção por horário, contra a média do próprio dia)

| Ativo | horários validados fora da rolagem (M5/M15) | o que são |
|---|---|---|
| **XAUUSD** | **12:20–12:29 (M1, 11 minutos seguidos), 12:25 (M5)** — cai k antes de subir k em 69–73% dos dias (k 150–600) | o padrão de Londres 10:2x já conhecido |
| XAGUSD | 01:30–01:45 (M1) | reabertura |
| US30 | 20:30 BUY (M5), 03:00/17:15 (M15) | isolados, não se repetem em outro TF |
| USDJPY | 12:20 BUY (M5), 15:00 SELL (M15) | isolados |
| EURJPY / GBPJPY | 1–4 isolados por TF | não se repetem |
| USDCHF | 05:05–06:15 BUY (M5) e 04:15 (M15) | **pista** (aparece em 2 TFs), sem resultado líquido validado |
| NZDUSD.r | 06:20–06:40 e 13:10–13:25 BUY (M5) | não confirmado em M15 |
| AUDUSD, DXY_Z6 | nenhum | |

- Nos pares de FX a hora **23h do servidor** é fortemente "SELL" e a **00h/01h** fortemente "BUY" (−20 a −51 pontos percentuais na corrida). É o bid afundando com o spread da rolagem e voltando na reabertura — **artefato de cotação**.
- No ouro, a "compra 23:45–23:58 com 240 min" (sobe k antes em ~70% dos dias, t até 9,5) também está nessa zona: spread fixo de **40 pts** das 23:40 às 23:59, swap de −55 pts e entrada no bid distorcido. Depois de custos e swap, só sobrevivem variantes de alvo grande (+800/+1.000) com t≈3 e sem BH — **não confiável**.
- **Dia anterior → dia:** sinais iguais em 44–48% no ouro, prata e US30 (leve reversão diária; z ≈ −1,5 a −2,1, não significativo após múltiplos testes). Sessão → sessão: nada estável (|z| > 2 em apenas 1 dos 2 períodos).

---

## F. Distância × tempo

(Tabelas completas em `C_distancias_*` e `F_devolucao_apos_alvo_*`.)
- Ouro (M1, janela 60): mediana de **1 min** até +100, **4 min** até +200, **7 min** até +300, **13 min** até +500; p90 entre 15 e 43 min. US30: +1.000 em 4 min (p90 29). FX: +100 em 20–26 min (p90 ~50).
- O tempo depende do horário: o mesmo alvo sai na metade do tempo às 15–17h do servidor.
- **Devolução:** das entradas de ouro que tocaram +300 (M15, 240 min), **35% (BUY) e 41% (SELL) terminaram a janela no prejuízo**. Para +1.000: 21% / 25%. Tocar o alvo não é ganhar — só ganha quem tem ordem de saída no alvo.

---

## G. Qualidade operacional (resultado líquido por horário)

Para cada horário × lado × k × limite adverso (k, 2k, ou nenhum = sai no fim da janela) foi calculada a média líquida (spread + swap). Contagem de horários aprovados (descoberta t≥3, validação t≥1,645, média > 0 nos dois) contra o placebo de horários embaralhados no dia:

| Ativo | M15 (3 anos) aprovados / placebo máx. | M5 (17 meses) aprovados / placebo máx. | leitura |
|---|---|---|---|
| XAUUSD | 1 / 4 (240 min) | 23 / 18 (60 min) · 17 / 9 (240) | só 12:15–12:25 VENDA e 18:00 COMPRA (alvo pequeno) se repetem |
| EURJPY | 24 / 0 · 5 / 0 | 39 / 0 · 62 / 1 | acima do acaso, quase tudo na rolagem + aglomerado 22:10–22:35 BUY |
| GBPJPY | 34 / 0 · 11 / 0 | 25 / 0 · 52 / 1 | idem |
| USDJPY | 41 / 1 · 4 / 1 | 78 / 4 · 31 / 4 | idem + 19:30–19:45 e 12:20–12:35 BUY |
| USDCHF / NZDUSD.r | 18 / 0 · 29 / 0 ; 12 / 0 · 3 / 0 | 15–92 / 0–1 | quase tudo 23:00–01:00 (rolagem) |
| XAGUSD, US30, AUDUSD, DXY_Z6 | 0–2 / 0–2 | 0–5 / 0–6 | indistinguível do acaso |

Em M1 dos ativos com histórico curto (ouro, US30, USDJPY), o placebo também aprova dezenas a centenas de combinações (regime único de 2026), então M1 sozinho **não** serve de evidência.

---

## H. Validação — padrões que sobrevivem, que perdem força e que não têm amostra

**Critério para entrar na tabela final:** média líquida > 0 e t ≥ 3 na descoberta, t ≥ 1,645 na validação, todos os anos positivos, perdas presentes na validação (sem "100% de acerto" degenerado) e **o mesmo lado a ±10 min aprovado em outro timeframe**. A coluna "Confiança" é **forte** só se também passar no BH, com t de validação ≥ 3 em M15 (3 anos).

Comissão: não declarada. Cenário de referência (conta Raw, ~US$ 7 por lote ida+volta — **confirme na sua conta**): ouro ≈ 7 pts/op; pares de iene ≈ 11 pts/op; US30 normalmente 0.

### Tabela final para decisão

| Ativo | TF / janela | Horário (servidor) | Direção | Condição objetiva | Alvo | Ocorr. | Sucessos (taxa) | Excursão adversa antes do alvo | Tempo até a meta | Resultado líquido (spread+swap) | Após comissão (cenário) | Estabilidade | Validação | Confiança |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **XAUUSD** | M5 / 60 min | **12:15** (Londres 10:15) | **SELL** | vende na abertura da barra 12:15; sai em +200 líquido ou às 13:15 | 200 pts (US$ 2,00) | 368 | 316 (85,9%; IC 81,9–89,1) | mediana 182, p90 643 | mediana 5 min, p90 25 | **+94,8 pts/op** (desc. +70, val. +132); pior −2.089 | ≈ +88 | 2025 +74, 2026 +111; 16/18 meses positivos; seg 95% … sex 86% | t 3,2 → 6,1; confirmado em M1 (12:20–12:29) e no bloco de 15 min | **limitada** (sem BH em M5; 2 anos) |
| XAUUSD | M5 / 60 | 12:20 / 12:25 | SELL | idem, alvo +300 / +400, sem limite | 300–400 | 368 | 80% / 72% | — | — | +145 / +174 pts/op | ≈ +138 / +167 | 2/2 anos | t 4,7→5,8 e 5,5→5,3; **BH sim** | limitada→forte (falta M15) |
| XAUUSD | M5 / 240 | 18:00 (NY 11:00) | BUY | compra 18:00; +100 ou saída 22:00 | 100 | 365 | 354 (97,0%) | mediana 272, p90 952 | mediana 0 min | +67,9 (desc. +62, val. +77); **pior −2.623** | ≈ +61 | 17/18 meses; seg–sex 95–100% | t 4,0→4,7; BH sim; confirmado em M15 | limitada — **cauda**: 3% de perdas valem ~22 ganhos cada |
| USDJPY | M15 / 60 | 22:15 | BUY | compra 22:15; +150 ou −150; senão sai 23:15 | 150 (15 pips) | 711 | 98 (13,8%) — limite 9,0%, nenhum 77% | mediana 17 | mediana 30 min | +17,0 (desc. +14, val. +22); pior −150 | ≈ +6 | 2024 +13, 2025 +21, 2026 +16; 28/34 meses | t 3,3→4,8; BH sim; confirmado M1+M5 | forte estatisticamente, **economicamente marginal** |
| GBPJPY | M1 / 60 | 22:14 | BUY | +150 / −150 | 150 | 711 | 20,1% | 36 | 39 min | +19,4 | ≈ +8 | 3/3 anos; 28/34 meses | t 3,3→4,4; confirmado M5+M15 | limitada |
| EURJPY | M1 / 60 | 22:13–22:15 | BUY | +100 / −200 | 100 | 711 | 24% | 25 | 33 min | +14,0 | ≈ +3 | 3/3 anos; 28–31/34 meses | t 3,1→4,3; confirmado M5+M15 | limitada, ~zero após comissão |
| USDJPY | M5 / 240 | 19:30–19:45 | BUY | +150, sem limite, sai 4 h depois | 150 | 369 | 40–43% | 36–38 | 75–85 min | +33 a +34; pior −891 | ≈ +22 | 2/2 anos; 15–16/18 meses | t 3,1→3,4; confirmado M1 | limitada |
| EURJPY | M1 / 240 | 19:40–19:47 | BUY | +100, sem limite | 100 | 710 | 56–59% | 44–46 | 48–65 min | +22 a +26; pior −1.041 | ≈ +12 | 3/3 anos; 30/34 meses | t 3,1→4,0; confirmado M5 | limitada |
| USDJPY | M5 / 60 | 12:20 | BUY | +100, sem limite | 100 | 369 | 38,8% | 23 | 25 min | +20,9; pior −641 | ≈ +10 | 17/18 meses | t 3,2→3,2; confirmado M1 | limitada |
| US30 | M5 / 240 | 10:25 | SELL | +400, sem limite | 400 (4 pontos do índice) | 369 | 97,8% | **mediana 970, p90 3.870** | 0 min | +264; **pior −13.920** | ≈ +264 | 15/18 meses | t 3,6→2,9; BH sim; só M1 confirma | limitada — cauda domina |
| *(rolagem)* GBPJPY/EURJPY/USDJPY/USDCHF | M15 / 60 | **01:00** | BUY | compra na reabertura | 25–50 | 709 | 64–91% | — | 0 min | +15 a +36; t de validação 12–24 | — | 3/3 anos | passa tudo | **insuficiente: bid ainda distorcido na 1ª barra** |
| *(rolagem)* NZDUSD.r / GBPJPY | M5–M15 | 23:00–23:45 | SELL | venda antes da rolagem | 25–100 | 290–560 | — | — | — | +17 a +21 | — | — | passa tudo | **insuficiente: artefato do spread** |

Fichas completas (todas as colunas pedidas + últimas 10 ocorrências): `docs/relatorios/mba/reach/H_fichas_candidatos.csv`.

### O que perdeu força ou não se sustenta
- **Ouro compra 23:45–01:00** (relatórios anteriores): com spread de 40 pts e swap de −55, só sobrevive com alvos grandes, sem BH e só em M5 → **não confirmado**.
- **"Horário com 90–99% de acerto"** em qualquer ativo, com alvo pequeno e sem stop: o acerto é real, mas a média é determinada pela cauda (pior dia 10–40× o alvo). Em M15 (3 anos) o placebo produz tantos quanto o real (ouro: 1 aprovado vs placebo máx. 4).
- **Gap de segunda-feira:** fecha no mesmo dia em 83–91% das segundas, 5–24 pontos percentuais acima da chance de andar a mesma distância nos outros dias. Mas, nos pares de FX, 70–84% dos gaps são **para baixo** — típico de bid deprimido pelo spread da abertura da semana. Só vale investigar no ouro e no US30 (gaps equilibrados: 51% e 61% para cima; excesso de +10 e +13 p.p. nos gaps grandes), **com cotação ask/ticks**.
- **Todos os M1 dos ativos com histórico curto:** amostra insuficiente sozinha (140–158 dias, um regime).

---

## I. Outras descobertas

1. **Relógio de volatilidade estável e forte** em todos os ativos (seção B): serve para escolher alvo e tempo de forma objetiva — por exemplo, no ouro um alvo de 300 pts em 60 min tem 72–74% de alcance às 15–17h e 34% às 23h. Não indica direção, mas indica **quando não vale operar** (alvo não sai) e quando a excursão adversa será maior.
2. **Extremos do dia** se formam sobretudo na primeira hora após a reabertura (01h) e na abertura de NY (15–17h).
3. **Leve reversão diária** no ouro, prata e US30 (dia seguinte com sinal oposto em 53–56% dos casos) — fraca, não significativa após correção, mas com o mesmo sinal nos dois períodos do ouro.
4. **Aglomerado 22:10–22:35 do servidor (15:10–15:35 NY) de COMPRA nos três pares de iene ao mesmo tempo:** o mesmo horário e a mesma direção em USDJPY, EURJPY e GBPJPY sugere um fator comum (iene fraco perto do fim da sessão americana). É a regularidade direcional mais consistente fora do ouro (3/3 anos, 28–31 de 34 meses positivos), mas pequena: 1,3–2 pips líquidos de spread, quase nada depois da comissão.
5. **Rolagem como armadilha sistemática:** qualquer varredura feita com velas de bid encontra "padrões" entre 23:00 e 01:15 do servidor. Todo estudo futuro do MBA deve excluir essa faixa ou usar o ask dos ticks (`RAW_TICKS`).

---

## Pendências e próximos passos

1. **Refazer o histórico M1** dos 7 ativos cortados (MBA v1.23.1) e rodar de novo `mba_reach.py` + `mba_reach_analyze.py` — o minuto a minuto do ouro e do US30 passa de 146 para ~700 dias.
2. **Teste prospectivo do ouro 12:15–12:29 VENDA** (já existe o LondonDrop EA em demo): a semana de **26 a 30/10/2026** é o teste de falsificação natural: Londres já estará em horário de inverno (UTC+0) e o servidor ainda em UTC+3 (o horário de verão americano só termina em 01/11). Nessa semana, 10:15–10:29 de Londres = **13:15–13:29 do servidor**. Se o padrão seguir Londres, a queda deve aparecer às 13:15–13:29 e sumir às 12:15–12:29; se ficar às 12:15, o relógio é outro. A partir de 02/11 os dois voltam a coincidir (12:15 servidor = 10:15 Londres).
3. Para o aglomerado de **iene 22:10–22:35**, confirmar a comissão real da conta; se for ~US$ 7/lote, o resultado líquido é ≈ 0 e não vale um EA.
4. Verificar gap de segunda e reabertura de 01:00 com **ask/ticks** antes de descartar ou aceitar.
5. Nenhum dos itens acima foi backtestado no Strategy Tester (ticks reais, comissão, slippage). **Nada aqui é afirmação de lucratividade.**
