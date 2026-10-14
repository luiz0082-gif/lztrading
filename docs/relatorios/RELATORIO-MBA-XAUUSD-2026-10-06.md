# Market Behavior Research Engine — Relatório de Análise (XAUUSD)

Data da análise: 2026-10-06 · Fonte: `Common\Files\MarketBehaviorAnalyzer` (os dois caminhos informados eram idênticos) · Ferramenta: Python/pandas (scripts na scratchpad da sessão; tabela de minutos em `docs/relatorios/mba/`).

> **Leitura em 30 segundos**
> 1. A base tem **~3 pregões** (sex 02/10, seg 05/10, ter 06/10 parcial) de **captura ao vivo**. É pouca história para qualquer conclusão estatística de horário.
> 2. **Direção por minuto (:00–:59): sem repetição distinguível de acaso.** Os "melhores" minutos (:13 = 69% alta; :30 = 32% alta) são exatamente o que o acaso produz ao se olhar 60 minutos (p de permutação do máximo = 0,20; correção BH q ≥ 0,22). A correlação do padrão de minutos entre a 1ª e a 2ª metade do período é **−0,10**.
> 3. O que **é** estruturado por minuto é a **atividade** (volume, ticks, spread, range): :00, :30, :01, :02 concentram mais atividade e spread mais largo; :40–:49 são os mais calmos. Perfil estável entre metades (corr 0,77 volume; 0,58 spread).
> 4. Nenhuma relação com poder preditivo foi encontrada em geometria, volume, tick, estrutura, MTF, padrões clássicos ou sequências. Várias "relações fortes" são **tautologias** (ver §12/§13).
> 5. Nada aqui é regra de operação. Nenhuma hipótese sobreviveu à correção por múltiplos testes.

---

## 1. DATASET OVERVIEW

| Item | XAUUSD | XAUUSD.r |
|---|---|---|
| Origem | LIVE_CAPTURE (nenhum HISTORICAL_SERVER) | LIVE_CAPTURE |
| Intervalo (hora do servidor) | 02/10 07:23 → 06/10 21:03 | 02/10 07:17 → 06/10 21:03 |
| Pregões cobertos | sex (parcial), seg (completo), ter (parcial) + 75 min de domingo à noite | idem |
| Candles M1 / M5 / M15 / M30 / H1 / H4 | 3.481 / 697 / 232 / 115 / 57 / 14 | 3.281 / 657 / 220 / 109 / 55 / 13 |
| W1 / MN1 | **vazios** (0 bytes) | **vazios** |
| Eventos M1 | 3.481 (1:1 com candles) | 3.281 |
| Forward | horizontes 1,2,3,5,10 barras; M1: 2.606.030 linhas brutas → 34.920 únicas (3.526 eventos, inclui alguns de histórico anterior ao início da captura) | idem |
| Ticks brutos (`RAW_TICKS`) | 1.624.088 ticks | 344.321 ticks |
| Agregados de tick | sim (M1…H1; H4/W1/MN1 vazios/mínimos) | sim |
| DOM | sim (≈615 mil snapshots só nas 3 primeiras partes; bid/ask volume saturado, ver §9) | pouco (0,1 MB) |
| Notícias | 183 linhas de calendário, **sem actual/forecast, impact "NA"** → inutilizável | idem |
| Runs | 13 (reinícios do EA) | 18 |
| `discoveries.csv` / pasta `STATS`/`DISCOVERY` | **não existem** | — |

`XAUUSD` e `XAUUSD.r` são o **mesmo mercado** (mesmo ouro; correlação de 0,90 da taxa de alta por minuto entre os dois). **Não são duas amostras independentes**; a segunda serve só como checagem de coerência. Análise principal: `XAUUSD`.

Horário: `server_time` = servidor da corretora; `analysis_time` = servidor − 3 h (declarado em `runs.analysis_offset_hours = -3`, tratado como UTC-like). Minuto-do-hora é idêntico nos dois; hora do dia usa `analysis_time`. Todo o período é de um único regime de horário (sem troca de DST dentro da amostra).

## 2. DATA QUALITY

- **Duplicação massiva em FORWARD:** 2,6 milhões de linhas no M1 para 34.920 (event_id × horizonte) únicos (98,7% duplicadas; ~75× de inflação de N), porque cada novo run reescreve o histórico. Deduplicado por `(event_id, horizon_bars)` antes de qualquer cálculo. Quem ler FORWARD sem deduplicar infla N em ~75× no M1 (e ~370× no M5, 2,6 mi → 7 mil).
- Candles: 0 duplicatas, 0 fora de ordem, 0 com range zero, 0 com tick_volume/tick_count zerado. `real_volume` constante 0 (ouro CFD sem volume real) → só **tick volume** existe. `symbol/timeframe/real_volume/source` constantes.
- **Gaps:** fim de semana (esperado, 2.982 min) + 3 lacunas por reinício do EA/queda: 9 min (04/10 23:07 UTC), 48 min (05/10 13:09), 64 min (05/10 22:02). Candles ausentes afetam sequências e forward ao redor desses pontos.
- **Snapshots que mudam:** o EA continua gravando durante a análise; as leituras sucessivas diferem em 1–3 candles (3.481/3.482/3.484). Diferenças imateriais, mas os números não são byte-reprodutíveis.
- `tick_volume` ≠ `tick_count` em 81% dos candles M1 e `tick_count` do candle ≠ do agregado em 88% (capturas diferentes/início no meio do minuto) → tratar como proxies distintos.
- Os dois símbolos têm taxas de ticks muito diferentes (mediana de ~105 ticks/min em `.r` vs ~380 em `XAUUSD`) → `tick_count`/`tick_density` **não são comparáveis entre feeds**.
- 1 candle com `volatility_state=UNKNOWN` e 3 com `structure_state=UNKNOWN` (início do histórico, sem lookback); mantidos, imateriais.
- Candles ASIA/OFF_SESSION etc. usam definição de sessão do EA, não verificada aqui.
- **Possível vazamento nas colunas MTF/estrutura:** ver §12–13.

## 3. TIMEFRAME SUMMARY

| TF | N | % alta (entre direcionais) | Doji | Range mediano | ATR mediano |
|---|---|---|---|---|---|
| M1 | 3.482 | 49,96% | 0,7% | 1,51 USD | 1,63 |
| M5 | 698 | 48,78% | — | — | — |
| M15 | 232 | 49,57% | — | — | — |
| M30 | 115 | 49,57% | — | — | — |

M1 (percentis): `range` P10/25/50/75/90 = 0,75/1,04/1,51/2,16/3,12; `body_pct` = 0,10/0,24/0,47/0,69/0,85; `range_atr` = 0,55/0,70/0,91/1,20/1,54; `volume_ratio` = 0,68/0,80/0,95/1,13/1,37; `spread_avg_points` = 5,1/5,9/8,2/10,0/11,0. Distribuições são assimétricas à direita (volume_ratio máx 6,8; tick_density_ratio máx 176 — outlier de dado).

Pontos em ouro: `1 ponto = 0,01 USD` (confirmado: forward −71 pts ↔ −0,71 USD).

## 4. HOURLY REPETITION (hora do dia, `analysis_time`)

M1, 23 horas (hora 21 não ocorre): % alta por hora varia de 39% (h02) a 59% (h00). Teste de dispersão por permutação: **p = 0,07**; menor q (BH) = 0,37. Nenhuma hora isolada é distinguível do acaso. M5 por hora: p-perm 0,12; M15: 0,36; M30: 0,08; H1: 0,67 (N = 1–3 por hora, inutilizável).

**Cada hora aparece em apenas 2–3 dias.** Mesmo onde o N de candles é alto (≈180/hora no M1), os dias são 3: a unidade independente real é o par dia×hora.

## 5. DAY + HOUR REPETITION

Dados **insuficientes** para este corte. Dia da semana: sex 48,8% (N=990), seg 50,0% (N=1.319), ter 50,9% (N=1.078), dom 51,4% (N=74). Um slot `hh:mm` do M1 tem N = 1–3 observações; `dia+hh:mm` tem N = 1 (verificado: média 1,0). **Nenhuma conclusão do tipo "segunda 09:00" é possível com esta base.** É necessário 8–12+ semanas para N≈40–60 por slot — e ainda assim com cuidado de múltiplos testes (1.440 slots × 5 dias).

## 6. CANDLE GEOMETRY

Direção por faixa de `body_pct` (M1): <20%: 50,9% alta; 20–40: 49,3; 40–60: 51,0; 60–70: 49,5; 70–80: 48,2; 80–90: 52,1; ≥90: 45,7 (IC95 ±5–7 pp; nenhum p < 0,25). **Body não altera a taxa de direção nem o forward.** Mediana do forward +5 é ruído (−9 a +13 pts) enquanto MFE/MAE medianos ≈ ±150 pts em todas as faixas.

`close_position` e `direction` são quase a mesma variável (close_position <0,2 → 3% alta; >0,8 → 96% alta): **redundantes**, não achado.

`range_atr` (M1): % alta de 44% (1,5–2) a 60% (2–3, N=80, p=0,075) e 67% (>3, N=12): amostras pequenas, não corrigidas, sem repetição em subperíodos. `range_atr` aumenta o range **futuro** não demonstrado; o MFE/MAE sobe levemente nos extremos mas o N é de 80/12.

## 7. CANDLE PATTERNS

Padrões como etiquetas (cada rótulo contado separadamente; M1, N entre 66 e 824):

- Rótulos **direcionais por definição** (BULLISH/BEARISH_ENGULFING, MORNING/EVENING_STAR, TWEEZER_*, HANGING_MAN, SHOOTING_STAR) têm 0%/100% de alta na própria vela — tautologia, não achado.
- Próxima vela M1 após cada padrão: 45,8% a 59,8% de alta (extremos: MORNING_STAR 45,8% N=435; HANGING_MAN 59,8% N=108, p=0,053; INVERTED_HAMMER 57,2% N=161, p=0,081). Com 17 rótulos testados, ~1 p<0,06 é esperado ao acaso.
- Forward +5 mediano por padrão: −23 a +42 pts, sempre dentro de ruído (o desvio-padrão do retorno +5 é 318 pts).
- Nome do padrão ≠ geometria: DOJI (N=371) tem `body_pct` mediano 0,05 mas range_atr 0,76; PIN_BAR (N=824) é rotulado em 24% dos candles — o rótulo é amplo demais para ser informativo.

**Nenhum padrão clássico mostra poder preditivo nesta amostra.**

## 8. SEQUENCES

M1: P(próxima vela igual | anterior) = 49,1% (alta→alta, N=1.716, IC 46,8–51,5) e 49,3% (baixa→baixa, N=1.721). Autocorrelação lag-1 de corpos = +0,05; lag-2 = −0,004. M5: 48,8%/51,3% (N≈340). M15: 40,9%/42,2% (N≈115, IC amplo 32–51%, p=0,06/0,11 — sugere leve reversão, não validada).

Continuação após k velas iguais (M1): k=1: 50,2%; k=2: 46,6% (N=875, p=0,05); k=3: 50,7%; k=4: 53,2%; **k=5: 32,4% (N=108, p<0,001); k=6: 68,6% (N=35, p=0,04)**. A sequência k=5→6 inverte de sinal em amostras aninhadas e sobrepostas (as de k=6 são subconjunto de k=5) → **instável/artefato provável**, 6 testes feitos, nenhum replicado.

## 9. TICK ACTIVITY

- Imbalance de ticks (`up_ratio − down_ratio`) vs direção **da própria vela**: corr = **+0,38** (quintil superior 79,8% alta; inferior 21,8%). É **concorrente** (mesmo candle), não preditivo.
- Mesmo imbalance vs **próxima** vela: corr +0,014; vs forward +5: +0,010; % alta da próxima vela por quintil: 48,5–51,5%. **Sem poder preditivo.**
- `tick_density_ratio` vs `volume_ratio`: corr 0,17 (colunas diferentes; a segunda sobre tick_volume e a primeira sobre contagem de ticks capturada). Correlação parcial `range_atr ~ tick_density | volume_ratio` = −0,09: **tick density não adiciona informação sobre o range além do volume**.
- `spread_avg` vs range: corr 0,06 (praticamente independente do range; depende do horário).
- **DOM:** `total_bid_volume`/`total_ask_volume` ≈ 38.600 em ~91% dos snapshots (saturado/placeholder), imbalance ≠ 0 em só 9% dos snapshots, ~10 níveis. É a profundidade **disponibilizada pelo broker/feed**, não do mercado global, e aqui é quase constante. Não utilizável como sinal.

## 10. VOLUME (volume_ratio, M1)

| Classe | N | % alta | próxima vela %alta | med fwd+5 |
|---|---|---|---|---|
| <0,75 | 604 | 51,8 | 50,4 | +21 |
| 0,75–1 | 1.400 | 49,5 | 49,8 | −10 |
| 1–1,25 | 930 | 48,9 | 49,6 | −6 |
| 1,25–1,5 | 320 | 49,2 | 50,9 | −3 |
| 1,5–2 | 167 | 52,7 | 48,5 | 0 |
| 2–3 | 53 | 49,1 | 52,8 | 0 |
| >3 | 10 | 80,0 | 50,0 | +114,5 |

Volume relativo **não diferencia direção**. A classe >3 (N=10) e o forward +114 pts são amostra minúscula (média +197 vs mediana +114: assimetria por outlier). `<0,75` mostra mediana +21 pts mas `P(>0)`=55%, N=604 — não corrigido nem replicado.

## 11. VOLATILITY

`volatility_state` (M1): VERY_LOW 192, LOW 1.292, NORMAL 1.238, HIGH 565, EXTREME 196. % alta 47–54% em todos (p ≥ 0,17). Em regimes EXTREME o MAE mediano é −201 pts (vs −113 em VERY_LOW): **o tamanho do movimento escala com a volatilidade (esperado, definicional)**, a **direção não**.

## 12. MARKET STRUCTURE

`BREAK_UP` = 100% alta e `BREAK_DOWN` = 0% alta na própria vela: a classificação **usa o fechamento do candle atual** → tautologia. O forward após BREAK_UP é **negativo** (mediana +5: −23 pts, N=223; média −36) e após BREAK_DOWN também (−31 mediana): sugere reversão a curto prazo, mas é N≈230, não corrigido, não replicado. BULLISH/BEARISH/RANGE: 49–51% alta, nada.

## 13. MULTI-TIMEFRAME CONTEXT

- `mtf_M5` BREAK_UP → 74,0% alta, BREAK_DOWN → 31,1% alta (N≈200 cada): isso **não é contexto de timeframe superior independente**; o M5 em formação contém a própria vela M1. É **vazamento parcial/auto-referência** da coluna MTF e **não deve ser usado como informação disponível antes do fechamento da vela**.
- `mtf_M15` BREAK_UP 65,2% / BREAK_DOWN 33,3% (N=187/148): mesmo problema, efeito diluído.
- `mtf_H1`: nenhuma classe distinguível (48–54% alta, p ≥ 0,22).
- **Alinhamento M15+H1:** bull-bull (N=616) 49,6%; bear-bear (N=539) 46,8%; misto (N=2.329) 50,8%. Forward +5 mediano: −6/−6/+2 pts. **O alinhamento não altera o comportamento observado.**

Recomendação de engenharia (para o EA coletor, não para estratégia): gravar o estado do TF superior usando **apenas o último candle fechado** daquele TF no instante do evento.

## 14. FORWARD BEHAVIOR

Todos os eventos M1 (N≈3.470, dedupado):

| Horiz. | ret P10 / P50 / P90 (pts) | média | desvio | MFE med | MAE med |
|---|---|---|---|---|---|
| +1 | −149 / 0 / +139 | −0,5 | 138 | +62 | −64 |
| +2 | −209 / −3,5 / +208 | −1,0 | 200 | +91 | −95 |
| +3 | −256 / −7 / +247 | −1,6 | 246 | +112 | −118 |
| +5 | −338 / −1 / +324 | −2,7 | 318 | +153 | −150 |
| +10 | −479 / −7 / +453 | −6,2 | 455 | +226 | −215 |

Sem viés direcional incondicional; MFE ≈ |MAE| (razão 0,95–1,05). O ouro subiu/caiu sem drift mensurável nos 3 dias. M5/M15/M30: idem, N menor (698/232/115) e dispersão proporcionalmente maior.

## 15. MFE / MAE

A assimetria condicional que apareceu (ex.: `volume_ratio >3`: MFE med 346 vs MAE −234; sessão LONDON_NY_OVERLAP: MFE +201/MAE −204; NEW_YORK: +120/−112) reflete **tamanho de movimento maior em sessões/regimes de maior volatilidade**, não vantagem direcional. A razão MFE/|MAE| fica entre 0,8 e 1,1 em quase todas as condições. Tempo até MFE/MAE medianos: 3 barras/3 barras no +5 (sem diferença).

## 16. DISCOVERY GROUPS

Não há `discoveries.csv` na pasta. Rodei um scan próprio e **deliberadamente transparente** (1.037 hipóteses: 1 e 2 condições sobre hora, minuto, dia, body, range_atr, volume, tick, spread, sessão, estrutura, MTF, direção, padrão; N ≥ 30):

| Alvo | Testes | p<0,05 observados | p<0,05 esperados ao acaso | q<0,05 (BH) |
|---|---|---|---|---|
| Próxima vela M1 de alta | 1.037 | 33 | ~52 | **0** (q<0,10: 0) |
| Fwd +5 barras positivo | 1.037 | 132 | ~52 | **0** (q<0,10: 18) |

Para a próxima vela há **menos** achados do que o acaso produziria. Para fwd+5, o excesso vem de janelas **sobrepostas** (a mesma subida/queda conta várias vezes) e de condições "hora=X & TF=Y" que representam **2–3 dias** — não são independentes. Nenhum achado tem q<0,05. Os 18 com q<0,10 (ex.: `hour=15 & mtf_H1=RANGE`: 31% de alta, N=106) são de um único dia ou dois e **não foram replicados**.

## 17. STABILITY BY SUBPERIOD

- Terços do M1: 50,0% / 49,8% / 50,1% alta (estável porque é ruído em torno de 50%).
- **Minuto-do-hora:** correlação do % alta por minuto entre a 1ª e a 2ª metade = **−0,10**; entre pares de dias = −0,02 / −0,02 / −0,08. Dos 10 minutos mais extremos na 1ª metade, **4/10** mantêm o lado na 2ª; edge assinado médio na 2ª metade = **−0,003**.
- Minutos com o mesmo lado nos 3 dias: 12 de 60 (acaso esperado: ~15).
- **Atividade por minuto** (contraste): corr entre metades volume_ratio 0,77; tick_density 0,76; spread 0,58; range_atr 0,45; range 0,37 → **estrutura real**.

## 18. POSSIBLE ROBUST RELATIONSHIPS

Apenas relações de **atividade/custo**, não de direção:

1. **Atividade e spread por minuto do relógio.** Maior `volume_ratio` mediano: :00 (1,40), :30 (1,25), :01 (1,21), :02 (1,12), :05 (1,10); menor: :40 (0,81), :39, :42, :47, :49 (0,84). Maior spread mediano: :31 (10,0), :01 (9,8), :02 (9,8), :00 (9,5), :32 (9,5); menor: :42 (5,85), :40 (5,91), :41 (6,2). Maior range/ATR: :00 (1,23), :30 (1,16), :01 (1,09). Testes de permutação (300 shuffles): `volume_ratio`, `tick_density`, `spread`, `range`, `range_atr`, `tick_count` com p ≈ 0,003 (o mínimo da permutação) e perfil estável entre metades. Mecanismo plausível (hipótese): fluxo concentrado na virada de hora/meia hora (algoritmos/relógio, fechamentos de barras de 30/60 min, referências de preço). **Isso é observação de atividade, não de direção.**
2. O movimento posterior (MFE/MAE) escala com a volatilidade vigente (óbvio, mas útil para dimensionamento).
3. Imbalance de ticks acompanha a direção da vela corrente (concorrente; não preditivo).

## 19. RELATIONSHIPS THAT LOOK INTERESTING BUT NEED VALIDATION

**ACHADO #001**
TF: M1 · HORARIO: minuto :13 de qualquer hora (UTC-like)
CONDICAO: candle com `minute == 13`
AMOSTRA: N=58 (40 altas, 18 baixas); em `XAUUSD.r`: N=55, 65,5% alta
RESULTADO OBSERVADO: 69,0% alta (IC95 Wilson 56–79%)
BASE RATE: 49,96% · DELTA: +19,0 pp · p exato = 0,004
FORWARD: mediana +1: −8,5 / +3: −32,5 / +5: −2,5 pts (sem continuação)
MFE/MAE: +179 / −123 pts (+5, medianos)
ESTABILIDADE: sex 69%, seg 61%, ter 78% (3/3 dias acima de 50%); por grupo de horas 62/67/82/57%
LIMITACOES: 60 minutos testados → q (BH) = 0,225; p de permutação do **máximo** entre 60 minutos = 0,20 (o acaso produz um extremo desse tamanho 1 vez em 5); `XAUUSD.r` **não é replicação independente** (corr 0,90); o padrão de minutos não persiste entre metades do período.
INTERPRETACAO: sustentado: nos 3 dias observados, M1 :13 teve mais altas que baixas. NÃO sustentado: que exista viés de direção em :13, nem edge operacional, nem mecanismo causal.

**ACHADO #002**
TF: M1 · HORARIO: minuto :30
CONDICAO: candle com `minute == 30`
AMOSTRA: N=57 (18 altas, 39 baixas); `XAUUSD.r`: N=54, 30,2% alta
RESULTADO OBSERVADO: 31,6% alta (IC95 21–45%) · BASE: 49,96% · DELTA: −18,4 pp · p = 0,008
FORWARD: mediana +1: +1 / +3: +5 / +5: +2 pts
MFE/MAE: +186 / −177 pts
ESTABILIDADE: 35% / 24% / 39% nos 3 dias (3/3 abaixo de 50%); por grupo de horas 18/41/38/29%
LIMITACOES: q (BH) = 0,225; máximo-de-60 por permutação p = 0,20; minuto com a maior atividade do dia (volume 1,25×, spread alto) → **muito mais ruído de execução/spread**; o seguimento (forward) não acompanha a direção.
INTERPRETACAO: sustentado: em :30 houve mais baixas que altas nesta amostra. NÃO sustentado: viés bearish em :30; poderia ser coincidência da combinação dos dias (não há mecanismo testado).

**ACHADO #003**
TF: M1 · CONDICAO: sequência de 5 velas iguais, depois 6ª vela
AMOSTRA: N=108 → 32,4% continuação (IC95 24–42%, p<0,001); N=35 → 68,6% (k=6)
LIMITACOES: grupos aninhados e sobrepostos; sinal invertido entre k=5 e k=6; 6 valores de k testados; sem replicação.
INTERPRETACAO: instável; provavelmente artefato de nesting/multiplicidade. Hipótese de reversão após 5 velas não suportada.

**ACHADO #004**
TF: M1 · CONDICAO: `structure_state = BREAK_UP` (e BREAK_DOWN)
RESULTADO: forward +5 mediano −23 e −31 pts (N=223 / 235); média −36 / −21
LIMITACOES: classificação inclui o próprio candle (vazamento parcial); p não corrigido; 3 dias.
INTERPRETACAO: possível reversão curta pós-rompimento; só tratar como hipótese após ter o estado classificado com info estritamente anterior.

**ACHADO #005**
TF: M15 · CONDICAO: continuação da direção (alta→alta, baixa→baixa)
RESULTADO: 40,9% / 42,2% (N=115/116), p=0,06/0,11 · limitações: N pequeno, duas direções testadas, 3 dias. Pode indicar reversão M15 (anti-persistência); **não validado**.

## 20. DATA LIMITATIONS

1. **Tamanho:** ~3 pregões. Para N por minuto ≥ 200 com Wilson ± 7 pp seriam necessários ≥ 12 semanas de M1 (e para *dia da semana × minuto* bem mais).
2. **Regime único:** uma semana de ouro, sem notícias com valor (calendário sem actual/forecast), sem Treasury/Fed/NFP identificáveis no dataset.
3. **Live capture com reinícios** (13/18 runs), lacunas de 9/48/64 min e leituras não-reprodutíveis.
4. **FORWARD gigantesco e duplicado** (98,7% de repetição no M1): 25 MB × 22 partes por TF para 0,2–35 mil linhas únicas.
5. **W1/MN1 vazios**, H4 com 14 candles; DOM saturado; real_volume = 0.
6. **Proxies:** tick_volume/tick_count/spread/DOM são observáveis do servidor/feed da corretora, não liquidez global. Contagem de ticks varia ~3,6× entre `XAUUSD` e `XAUUSD.r`.
7. **Candles de TF superior no contexto MTF** podem conter a própria vela → não usar como info prévia.
8. **Sem custos:** spread médio ~8,4 pts (0,084 USD) vs desvio-padrão do retorno +1 de 138 pts; edge direcional pequeno seria facilmente consumido por custo e slippage — não testado.
9. Timezone: `analysis_time` = servidor − 3 h por declaração do EA; **não verificado** contra o relógio UTC real.
10. Sem out-of-sample, sem walk-forward, sem validação cruzada entre períodos independentes.

---

## CONCLUSÃO — A/B/C/D

**A. FATO OBSERVADO NOS DADOS**
- 3 pregões de ouro (M1: 3.481 candles); 49,96% de altas entre candles direcionais; autocorrelação ≈ 0 (+0,05).
- Spread, volume e range são maiores em :00, :30, :01, :02 e menores em :40–:49.
- Nominalmente, :13 teve 69% de altas e :30 teve 32% (N≈57 cada).
- Forward M1 (+1…+10) tem mediana ≈ 0 e MFE ≈ |MAE| em todas as condições testadas.

**B. RELAÇÃO ESTATÍSTICA OBSERVADA**
- Atividade por minuto-do-relógio: sim, significativa e estável entre metades do período.
- Direção por minuto-do-relógio: **não** distinguível do acaso (perm p=0,20; BH q ≥ 0,22; corr entre metades −0,10).
- Direção/forward vs body, range_atr, volume_ratio, tick density, spread, volatilidade, estrutura, MTF, padrões, sequências: nenhuma relação que sobreviva à correção de multiplicidade (0 de 1.037 hipóteses com q<0,05 para a próxima vela).
- Imbalance de ticks: correlaciona com a direção da vela **corrente** (r=0,38), não com a seguinte (r=0,01).

**C. HIPÓTESES PARA TESTE FUTURO** (não são regras)
1. H1: o custo (spread) e a atividade mudam sistematicamente por minuto do relógio (:00/:30/:01/:02 caros e voláteis; :40–:49 baratos e calmos). Teste: replicar com ≥ 12 semanas; se persistir, vira filtro de **horário de execução** (custo), não de direção.
2. H2: pode haver direção específica em :13/:30 (ou algum slot). Critério de falsificação: fixar a lista de slots agora (ex.: só :13 e :30), coletar **novas** semanas, exigir Wilson excluindo 50% e mesmo sinal em ≥ 80% das semanas. Se corr entre períodos ficar ≈ 0, descartar.
3. H3: reversão após rompimento de estrutura (BREAK_UP/DOWN) e anti-persistência no M15. Pré-requisito: reclassificar usando só informação anterior ao candle.
4. H4: o range futuro escala com `range_atr`/volume atuais (útil para dimensionar risco, não direção).

**D. O QUE OS DADOS AINDA NÃO PERMITEM AFIRMAR**
- Que algum minuto, hora, dia ou combinação tenha viés direcional.
- Que algum padrão de vela, sequência, estrutura ou contexto MTF tenha poder preditivo.
- Qualquer lucratividade — não há backtest com custos, comissão, slippage e execução.
- Causalidade (por que :00/:30 concentram atividade).
- Qualquer coisa sobre outro símbolo, regime (alta volatilidade macro, notícias) ou outro mês.

## Próximos passos recomendados (engenharia da coleta, não estratégia)
1. **Coletar ≥ 12 semanas contínuas** (idealmente HISTORICAL_SERVER via `CopyRates`, que não sofre com reinícios) e comparar com LIVE.
2. **Deduplicar FORWARD na origem** (gravar cada evento uma única vez ou só o novo por run): hoje ~99% é repetição.
3. **MTF sem vazamento:** registrar o estado do último candle **fechado** de cada TF.
4. Corrigir `news` (gravar actual/forecast/impact), `W1/MN1`, e a taxa de captura do DOM (volume saturado em 38.600).
5. Adicionar ao CSV `slot_hhmm`, `week_id` e `cluster_day` para facilitar análise com blocos independentes.

---

## Apêndice — Minuto do relógio (M1, :00 a :59), XAUUSD

Legenda: horário `analysis_time`; "%alta" entre candles direcionais; Δ vs 49,96%; p exato bilateral vs base; q = Benjamini-Hochberg sobre os 60 minutos. `fwd+5 med` em pontos (1 pt = 0,01 USD). Colunas Sex/Seg/Ter = % alta no dia.

| min | N | Alta/Baixa | % alta | IC95 Wilson | Δ pp | p (exato) | q (BH) | Sex/Seg/Ter %alta | vol_ratio med | range/ATR med | spread med (pts) | fwd+5 med (pts) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| :00 | 56 | 30/25 | 54.5 | 42–67 | +4.6 | 0.504 | 0.88 | 56/52/56 | 1.40 | 1.23 | 9.5 | +20 |
| :01 | 56 | 30/26 | 53.6 | 41–66 | +3.6 | 0.596 | 0.88 | 50/57/53 | 1.21 | 1.09 | 9.8 | -13 |
| :02 | 57 | 28/29 | 49.1 | 37–62 | -0.8 | 1.000 | 1.00 | 44/41/63 | 1.12 | 1.07 | 9.8 | +11 |
| :03 | 57 | 32/25 | 56.1 | 43–68 | +6.2 | 0.358 | 0.88 | 44/68/53 | 1.07 | 1.01 | 9.2 | -18 |
| :04 | 57 | 31/24 | 56.4 | 43–69 | +6.4 | 0.349 | 0.88 | 67/62/42 | 1.05 | 0.92 | 9.1 | -28 |
| :05 | 56 | 27/29 | 48.2 | 36–61 | -1.7 | 0.894 | 0.94 | 31/59/50 | 1.11 | 0.93 | 8.4 | -34 |
| :06 | 56 | 29/27 | 51.8 | 39–64 | +1.8 | 0.791 | 0.94 | 44/55/56 | 1.00 | 0.91 | 8.1 | -77 |
| :07 | 57 | 24/33 | 42.1 | 30–55 | -7.9 | 0.289 | 0.88 | 50/27/56 | 0.95 | 0.87 | 7.8 | -24 |
| :08 | 57 | 32/25 | 56.1 | 43–68 | +6.2 | 0.358 | 0.88 | 56/64/44 | 0.92 | 0.85 | 7.9 | -3 |
| :09 | 58 | 31/27 | 53.4 | 41–66 | +3.5 | 0.603 | 0.88 | 44/48/72 | 0.91 | 0.83 | 7.5 | +2 |
| :10 | 58 | 28/29 | 49.1 | 37–62 | -0.8 | 1.000 | 1.00 | 62/36/50 | 1.04 | 0.87 | 7.9 | +26 |
| :11 | 58 | 23/33 | 41.1 | 29–54 | -8.9 | 0.229 | 0.88 | 25/52/44 | 0.95 | 0.88 | 7.3 | +26 |
| :12 | 58 | 25/33 | 43.1 | 31–56 | -6.9 | 0.358 | 0.88 | 44/35/56 | 1.00 | 0.91 | 8.0 | +8 |
| :13 | 58 | 40/18 | 69.0 | 56–79 | +19.0 | 0.004 | 0.23 | 69/61/78 | 0.92 | 0.82 | 8.0 | -2 |
| :14 | 58 | 27/30 | 47.4 | 35–60 | -2.6 | 0.791 | 0.94 | 50/52/41 | 0.88 | 0.89 | 8.0 | -44 |
| :15 | 58 | 24/34 | 41.4 | 30–54 | -8.6 | 0.237 | 0.88 | 12/43/67 | 1.04 | 1.04 | 8.4 | -44 |
| :16 | 58 | 24/34 | 41.4 | 30–54 | -8.6 | 0.237 | 0.88 | 44/35/44 | 1.05 | 1.07 | 9.5 | +26 |
| :17 | 58 | 30/28 | 51.7 | 39–64 | +1.8 | 0.795 | 0.94 | 50/61/44 | 0.95 | 0.87 | 9.4 | +44 |
| :18 | 58 | 27/31 | 46.6 | 34–59 | -3.4 | 0.694 | 0.94 | 69/35/39 | 0.88 | 0.88 | 8.4 | +3 |
| :19 | 58 | 26/31 | 45.6 | 33–58 | -4.3 | 0.597 | 0.88 | 44/43/47 | 0.88 | 0.90 | 8.0 | -28 |
| :20 | 58 | 28/30 | 48.3 | 36–61 | -1.7 | 0.896 | 0.94 | 50/43/56 | 0.90 | 0.96 | 8.8 | +33 |
| :21 | 58 | 33/24 | 57.9 | 45–70 | +7.9 | 0.237 | 0.88 | 44/61/65 | 0.89 | 0.94 | 9.1 | -2 |
| :22 | 57 | 24/32 | 42.9 | 31–56 | -7.1 | 0.350 | 0.88 | 44/52/33 | 0.93 | 0.90 | 9.0 | -10 |
| :23 | 58 | 33/24 | 57.9 | 45–70 | +7.9 | 0.237 | 0.88 | 41/62/72 | 0.92 | 0.88 | 8.2 | -36 |
| :24 | 58 | 32/25 | 56.1 | 43–68 | +6.2 | 0.358 | 0.88 | 50/68/44 | 0.95 | 0.94 | 8.4 | -6 |
| :25 | 58 | 31/27 | 53.4 | 41–66 | +3.5 | 0.603 | 0.88 | 59/59/39 | 0.98 | 0.96 | 8.3 | -102 |
| :26 | 58 | 24/34 | 41.4 | 30–54 | -8.6 | 0.237 | 0.88 | 53/36/39 | 0.89 | 0.83 | 8.2 | -31 |
| :27 | 58 | 25/33 | 43.1 | 31–56 | -6.9 | 0.358 | 0.88 | 53/36/39 | 0.88 | 0.86 | 7.1 | +21 |
| :28 | 58 | 31/27 | 53.4 | 41–66 | +3.5 | 0.603 | 0.88 | 47/68/39 | 0.93 | 0.89 | 6.9 | -8 |
| :29 | 58 | 30/28 | 51.7 | 39–64 | +1.8 | 0.795 | 0.94 | 65/36/61 | 0.94 | 0.80 | 6.9 | -34 |
| :30 | 57 | 18/39 | 31.6 | 21–44 | -18.4 | 0.007 | 0.23 | 35/24/39 | 1.25 | 1.16 | 8.9 | +2 |
| :31 | 58 | 30/26 | 53.6 | 41–66 | +3.6 | 0.596 | 0.88 | 59/48/59 | 1.03 | 0.93 | 10.0 | +11 |
| :32 | 58 | 31/27 | 53.4 | 41–66 | +3.5 | 0.603 | 0.88 | 59/41/67 | 0.97 | 1.04 | 9.5 | -6 |
| :33 | 58 | 30/28 | 51.7 | 39–64 | +1.8 | 0.795 | 0.94 | 59/45/50 | 0.94 | 1.04 | 8.9 | +14 |
| :34 | 58 | 26/32 | 44.8 | 33–58 | -5.1 | 0.512 | 0.88 | 47/50/33 | 0.93 | 1.01 | 8.8 | -15 |
| :35 | 58 | 32/26 | 55.2 | 42–67 | +5.2 | 0.435 | 0.88 | 47/50/67 | 1.00 | 0.96 | 8.2 | +18 |
| :36 | 58 | 34/24 | 58.6 | 46–70 | +8.7 | 0.192 | 0.88 | 53/64/61 | 0.97 | 0.82 | 7.7 | -14 |
| :37 | 59 | 24/33 | 42.1 | 30–55 | -7.9 | 0.289 | 0.88 | 24/55/50 | 0.93 | 0.82 | 7.8 | -7 |
| :38 | 59 | 30/29 | 50.8 | 38–63 | +0.9 | 0.897 | 0.94 | 47/59/39 | 0.90 | 0.80 | 7.2 | -22 |
| :39 | 59 | 30/29 | 50.8 | 38–63 | +0.9 | 0.897 | 0.94 | 47/55/50 | 0.84 | 0.82 | 6.8 | -51 |
| :40 | 59 | 26/33 | 44.1 | 32–57 | -5.9 | 0.435 | 0.88 | 29/64/33 | 0.81 | 0.80 | 5.9 | -36 |
| :41 | 59 | 27/31 | 46.6 | 34–59 | -3.4 | 0.694 | 0.94 | 41/41/61 | 0.90 | 0.85 | 6.2 | -19 |
| :42 | 59 | 28/31 | 47.5 | 35–60 | -2.5 | 0.795 | 0.94 | 41/45/56 | 0.84 | 0.87 | 5.8 | -6 |
| :43 | 59 | 27/32 | 45.8 | 34–58 | -4.2 | 0.603 | 0.88 | 35/36/67 | 0.86 | 0.86 | 7.4 | -57 |
| :44 | 59 | 24/35 | 40.7 | 29–53 | -9.3 | 0.193 | 0.88 | 35/36/50 | 0.87 | 0.83 | 6.6 | +0 |
| :45 | 59 | 26/33 | 44.1 | 32–57 | -5.9 | 0.435 | 0.88 | 29/41/61 | 0.99 | 0.97 | 7.3 | +34 |
| :46 | 59 | 29/29 | 50.0 | 38–62 | +0.0 | 1.000 | 1.00 | 47/57/39 | 0.98 | 1.02 | 8.0 | +40 |
| :47 | 59 | 31/28 | 52.5 | 40–65 | +2.6 | 0.699 | 0.94 | 53/59/44 | 0.84 | 0.86 | 7.4 | -7 |
| :48 | 59 | 32/27 | 54.2 | 42–66 | +4.3 | 0.519 | 0.88 | 47/73/39 | 0.86 | 0.79 | 6.7 | +16 |
| :49 | 59 | 33/26 | 55.9 | 43–68 | +6.0 | 0.366 | 0.88 | 76/41/56 | 0.84 | 0.85 | 6.4 | +12 |
| :50 | 59 | 27/32 | 45.8 | 34–58 | -4.2 | 0.603 | 0.88 | 53/32/61 | 0.95 | 1.00 | 8.0 | -14 |
| :51 | 59 | 36/22 | 62.1 | 49–73 | +12.1 | 0.067 | 0.88 | 41/71/67 | 1.01 | 0.96 | 7.9 | -28 |
| :52 | 59 | 22/37 | 37.3 | 26–50 | -12.7 | 0.068 | 0.88 | 41/41/28 | 0.92 | 0.90 | 7.7 | -7 |
| :53 | 59 | 28/30 | 48.3 | 36–61 | -1.7 | 0.896 | 0.94 | 47/48/44 | 0.92 | 0.90 | 7.3 | +25 |
| :54 | 59 | 28/31 | 47.5 | 35–60 | -2.5 | 0.795 | 0.94 | 71/45/28 | 0.98 | 0.87 | 7.3 | +59 |
| :55 | 59 | 34/23 | 59.7 | 47–71 | +9.7 | 0.148 | 0.88 | 62/64/53 | 1.01 | 0.93 | 7.5 | +47 |
| :56 | 58 | 29/28 | 50.9 | 38–63 | +0.9 | 0.896 | 0.94 | 62/41/53 | 0.98 | 1.01 | 8.2 | +116 |
| :57 | 58 | 32/26 | 55.2 | 42–67 | +5.2 | 0.435 | 0.88 | 50/68/39 | 0.91 | 0.96 | 8.0 | +111 |
| :58 | 58 | 34/24 | 58.6 | 46–70 | +8.7 | 0.192 | 0.88 | 69/55/61 | 0.94 | 0.80 | 7.7 | +51 |
| :59 | 56 | 31/25 | 55.4 | 42–68 | +5.4 | 0.427 | 0.88 | 62/43/61 | 0.96 | 0.91 | 6.9 | +26 |

**Leitura do apêndice:** 60 minutos testados → esperam-se ~3 com p<0,05 por acaso; observados 2 (:13 e :30), ambos com q=0,225. Perm p do extremo máximo = 0,20; estatística de dispersão total (qui-quadrado de permutação) p = 0,41. Mesmo cálculo em `XAUUSD.r`: perm p = 0,19 / 0,32 (mesma conclusão, mas **não independente**).

Granularidades maiores: M5 por minuto (:00,:05,…,:55): perm p = 0,52 (único nominal: :55, 63,2% alta, N=57, q=0,40); M15 (:00/:15/:30/:45): p = 0,60; M30 (:00/:30): p = 1,0.
