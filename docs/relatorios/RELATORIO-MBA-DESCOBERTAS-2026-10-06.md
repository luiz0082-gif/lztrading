# MBA — Descobertas de padrões (XAUUSD, 12 semanas, 2 feeds)

Data: 2026-10-06 · Dados: `Raw_Trading_Ltd/XAUUSD` (IC Markets, `ICMarketsSC-Demo`) e `First_Prudential_Markets_Lim/XAUUSD_r` (FP Markets, `FPMarketsSC-Live`) · v1.10 do coletor · Horários em **UTC** (servidor = UTC+3).
Tabelas completas (auditoria): `docs/relatorios/mba/` — `candidatos_direcao_q10_com_cluster_dia.csv`, `retorno_por_horario_q10.csv`, `atividade_minuto_hora_sessao.csv`.

> **Leitura em 1 minuto**
> 1. **Direção por minuto/hora (:00–:59, HH:MM, dia da semana): nenhum viés.** 4.863 testes da direção da própria vela por tempo: 0 sobrevivem à correção.
> 2. **Existem dois padrões de direção que passaram em tudo** (fora da amostra, por dia, por semana, nos dois feeds, e correção de múltiplos testes):
>    **(a) queda do ouro entre 09:15 e 09:30 UTC** (−2,72 USD de média, queda em 73% dos dias, 60 dias) e
>    **(b) repique de ~25 min após quedas no M5/M15** (+50 a +90 pontos, 11–12 das 13 semanas) — só para baixo; para cima não há espelho.
> 3. **O relógio explica muito mais atividade do que direção**: :00, :30, :01, :02 têm 1,25–1,44× o range e ~1,2× o spread; 12–15h UTC têm 1,5–1,7× o range; 20h UTC é a hora mais morta (0,57×).
> 4. Volatilidade **agrupa**: autocorrelação do range 0,39 (M1/M5) e 0,27 (H1), mesmo removendo horário. Após candle M5 com range/ATR > 2, o próximo repete range > 1,25 em 54% (vs 22%).
> 5. **Não confirmaram nada**: padrões clássicos de vela (16), geometria (body, wicks, range/ATR, volume, tick density, spread), sequências, estrutura/MTF, níveis (dia anterior, sessão, swing, abertura), números redondos e dia da semana.
> 6. Achados (a) e (b) são **hipóteses candidatas, não regras**: 60 dias, um regime (jul–out/2026), custo/execução não simulados. Ver §7.

---

## 1. Dados e método

| Item | Valor |
|---|---|
| Período | 14/07 → 06/10/2026 (13 semanas, ~60 pregões) |
| Candles | M1 82.609 (IC) / 82.741 (FP); M5 16.547; M15 5.515; M30 2.757; H1 1.378; H4 359 |
| Qualidade | 0 duplicatas (`event_key`, `forward_key`); `tick_data_ok` 100%; lacunas = pausa diária 21:00–22:00 UTC (60×) + 2 lacunas isoladas (05h e 15h) |
| Feeds | IC e FP são o **mesmo mercado** (mesmo candle de horário). Servem de checagem de coerência, **não** de confirmação independente |
| Divisão | Descoberta = semanas 0–7; **validação fora da amostra = semanas 8–12** (cronológica) |
| Múltiplos testes | Benjamini-Hochberg (q) por família; estabilidade por **dia** (agrupamento, porque janelas de forward se sobrepõem); sign-flip por dia para o máximo (FWER) nos horários |
| Alvos | próxima vela de alta · repetição da direção (persistência) · retorno positivo em +5 barras · retorno/MFE/MAE em pontos · atividade (range, volume, spread, ticks) |

Totais: **69.677 testes de grupo** (direção/persistência/+5) — 4.038 com p<0,05 (o acaso daria ~3.484), 348 com q<0,10, **35 validados fora da amostra**, **41 robustos por dia** (muitos são o mesmo efeito repetido em variantes). Mais 16.308 testes de atividade e 7.268 testes de retorno por horário.

## 2. Todos os tipos de padrão procurados e o veredicto

| Família | O que foi testado | Testes | Resultado |
|---|---|---|---|
| Horário — direção | minuto da hora, hora, dia da semana, HH:MM exato, sessão, dia×hora; todos os TFs | 14.545 + 4.863 | Direção da vela: **0**. Efeito aparece só em **retorno (+5 barras)** e em janelas (§3) |
| Horário — atividade | range, volume, spread, ticks por minuto/hora/sessão/HH:MM | 16.308 | **Forte e estável** (§5) |
| Geometria | body, pavios, close position, range/ATR, volume ratio, tick density ratio, spread, volatilidade | 1.775 | 0 validados; ver M1 reversão fraca (§6) |
| Padrões clássicos | 16 padrões (doji, martelo, engolfo, inside/outside, pin, marubozu, harami, tweezer, estrela da manhã/noite…) | 512 | **0** |
| Sequências | direção das últimas 2–5 velas, comprimento de sequência 1–8 | 2.580 | 0 validados; reversão lag-1 no M1 **decai** (§6) |
| Estrutura | `structure_before` (BREAK_UP/DOWN, BULLISH, BEARISH, RANGE) | em CONTEXT | `BREAK_DOWN` → repique (§4); `BREAK_UP` → sem espelho |
| Multi-timeframe | estado M1…W1 fechado **antes** do evento; alinhamento M15+H1 | 3.506 | Só reaparece o repique após queda; alinhamento sem efeito |
| Níveis | dia anterior H/L, sessão H/L, swing, 20 barras, abertura diária | em CONTEXT | `fechamento perto da mínima de 20 barras` → repique; resto 0 |
| Notícias (agenda USD ≥ moderada) | proximidade de evento de alta importância | em CONTEXT | Efeito em **atividade**: range 1,4–2,0× e volume 1,5–2,2× (§5); direção 0 |
| Números redondos | distância a múltiplos de 10/50/100 USD | 454 | 15 com q<0,10 (são o efeito de reversão lag-1), **0 validados** |
| Volatilidade | agrupamento, compressão→expansão | — | **Real** (§5) |
| Combinações de 2 variáveis | 55 pares + horário×direção/range | 41.896 | 145 com q<0,10, 11 validadas — todas variantes de (a)/(b)/§6 |
| Diário | retorno por dia da semana, dia anterior→dia, gap de reabertura | N=30–60 | **Amostra insuficiente**; sem conclusão |

## 3. Padrão de direção A — queda entre 09:15 e 09:30 UTC

| Medida | Valor |
|---|---|
| Janela | 09:15–09:30 UTC (12:15–12:30 no servidor). Barra M15 das 09:15: média −272 pts (t = −5,1) |
| Dias | 60; queda em **73%**; média −272 pts, mediana −258, média aparada −235 |
| Significância | q (BH) < 0,001 em M15; **FWER (sign-flip por dia, 92 horários) p = 0,0003**; M5: p = 0,001 |
| Fora da amostra | metade 1: −252; metade 2: −310 |
| Semanas | 11 de 13 negativas |
| Feeds | IC e FP idênticos (mesmo mercado) |
| Mês | jul −206 (85% dias negativos), ago −257 (62%), set −397 (82%), **out (4 dias) +130 (50%)** |
| Dia da semana | negativo em todos (seg −484 … ter −119) |
| Caminho (M1, médias) | sobe ~+110 até ~09:10, depois cai ~−310 até ~09:30 e devolve cerca de metade até 10:15 |
| Custo | spread ~8–10 pts (0,08–0,10 USD) vs 272 pts de média: **~30× o spread** |

**Interpretação.** Os dados sustentam: neste período, o ouro caiu na janela 09:15–09:30 UTC em 3 de cada 4 dias, com magnitude muito acima do spread, e isso não é efeito de poucos dias. Os dados **não** sustentam: causa (possível relação com o horário de Londres/benchmark do ouro é só hipótese), nem que continue após a mudança de horário de verão do Reino Unido, nem que um sistema seja lucrativo (sem simulação de execução, slippage e risco). Atenção: os 4 dias de outubro vão no sentido oposto (N pequeno, mas é o único sinal de enfraquecimento).

**Teste de falsificação já definido (H1):** a janela fixa 09:15–09:30 UTC deve continuar com média negativa e ≥ 60% de dias negativos nas próximas 6 semanas. **Se estiver ligada ao horário de Londres, desloca-se 1 h** (10:15–10:30 UTC) após **25/10/2026** (fim do BST). Esse deslocamento é um teste forte do mecanismo.

## 4. Padrão de direção B — repique após queda (M5/M15, +5 barras ≈ 25–75 min)

| Condição (conhecida antes do fim da vela) | N (M5, IC) | Alta em +5 | Base | Retorno médio +5 | Semanas acima da base |
|---|---|---|---|---|---|
| `structure_before = BREAK_DOWN` | 1.036 | 56,2% | 49,1% | +56 pts | 11/13 |
| M15 baixista e 2 velas de baixa seguidas | 1.346 | 55,4% | 49,1% | +84 pts | 10/13 |
| fechamento perto da mínima das 20 barras | 490 | 58,6% | 49,1% | +80 pts | 12/13 |

- **Teste por dia** (agrupado): delta médio +11 a +12 pp, t = 4,5 a 5,7, em 63–69 dias; FP idêntico.
- **Robustez:** excluindo 20h–22h UTC (pausa diária) e 09h–10h UTC o resultado praticamente não muda (55–57%; t 3,6–5,4). **Não** é artefato da pausa diária nem do padrão A.
- **Assimetria:** `BREAK_UP` → apenas 49,0% de alta (+15 pts, mediana −15); fechamento perto da máxima → 49,9%. Só a queda repica.
- **Magnitude vs custo:** +50 a +90 pts médios vs spread ~9–10 pts. Sobra margem bruta, mas **execução em barras de bid** (compra no ask, saída no bid) e slippage não foram simulados.
- **Limitações:** as janelas de +5 barras se sobrepõem (por isso o teste por dia); período com preço de 4.056 a 4.169 e amplitude semanal de ±250 USD — um único regime lateral/volátil; assimetria pode refletir o regime, não uma lei do mercado.

**Hipótese H2 (para teste futuro):** após `BREAK_DOWN` no M5, a probabilidade de retorno positivo em 5 barras permanece ≥ 53% e o retorno médio ≥ +30 pts nas próximas 6 semanas. Falsificação: ≤ 51% ou média ≤ +10 pts.

## 5. Padrões de atividade e volatilidade (os mais robustos)

**Minuto da hora (M1, vs mediana geral; 13/13 semanas acima/abaixo; q ≤ 0,001):**

| | range | volume (ticks) | spread |
|---|---|---|---|
| :00 | **1,44×** | **1,52×** | 1,19× |
| :30 | 1,26× | 1,32× | 1,15× |
| :01 | 1,25× | 1,19× | **1,20×** |
| :02/:03 | 1,14× | 1,11×/1,09× | 1,18×/1,12× |
| :31/:32 | 1,10× | 1,12× | 1,19×/1,09× |
| mais calmos | :58 (0,81×), :27, :57, :59, :24 | :43, :58, :47, :57, :39 (≈0,85–0,87×) | :14, :39, :59, :13, :44 (≈0,90×) |

**Hora UTC (M15, range):** 13h 1,70× · 14h 1,51× · 12h 1,49× · 01h 1,38× · 15h 1,30× … 22h 0,61× · **20h 0,57×**. Sessão: sobreposição Londres/NY 1,44×, NY 0,80×, off-session 0,69×. Spread: maior às 20h (1,34×); menor às 11h, 14h, 15h (~0,92×). **Dia da semana não altera o range** (q = 0,88–1,0).

**Mais atividade** (range/volume) em eventos USD de importância ≥ 2 na agenda: faltando <15 min **1,66×** o range (269 vs 162 pts) e **2,25×** o volume; logo depois <15 min **1,98×** o range. Spread quase não muda (8,0–8,4 pts em todos os grupos).

**Volatilidade:** autocorrelação do log-range sem efeito do horário: M1 0,40 (lag 1) → 0,27 (lag 10); M5 0,39 → 0,22; M15 0,37 → 0,16; H1 0,27 → 0,06. M5: após range/ATR < 0,5 o próximo tem P(range/ATR > 1,25) = 10,6% (vs 22%); após range/ATR > 2 → 54%.

**Interpretação.** O relógio (e a agenda de notícias) prevê o **tamanho** do movimento muito melhor do que a **direção**. Útil para dimensionar risco, escolher horário de execução (spread/volume) e evitar horários mortos. Não é sinal de compra/venda.

## 6. Efeitos reais porém fracos ou instáveis

- **Reversão lag-1 no M1.** Após vela M1 que fecha na parte baixa (`close_position < 0,2`), a próxima é de alta 52,0% (treino) e 49,8% (validação) — o efeito **encolheu**: coeficiente `P(alta|baixa anterior) − P(alta|alta anterior)` por semana: 0,036 0,043 0,041 0,024 0,019 0,014 0,024 0,011 0,004 0,001 0,008 0,019 0,013. Retorno médio da próxima vela: +1,5 a +2,0 pts vs custo 8–10 pts → **inoperável**. Provável efeito de microestrutura (barras de bid) que perde força.
- **Slot 09:23 UTC** (e 09:21–09:25): retorno em +5 barras −130 pts em 60 dias (12/13 semanas negativas, q = 0,001). É o mesmo efeito de §3, visto por outra janela.
- **Slot 17:39 UTC** (M1): −74 pts em 60 dias, q = 0,04, **isolado** (nenhum vizinho). Tratar como possível falso positivo de múltiplos testes.
- **19:45–20:00 UTC:** barras M5/M15/M30 das 19:50–20:00 negativas (−150 a −230 pts), mas a janela somada não é significativa (média −21 pts, t = −0,3). **Não confirmado.**
- **Artefato 20:54–20:57 UTC:** "retorno positivo +5 barras" 71–80% dos dias, +200 pts. O spread está **fixo em 40 pts** de 20:50 a 20:59 e cai para 10 pts às 22:00; o candle é de bid → o que aparece é o **estreitamento do spread na reabertura**, não alta de preço. Não usar.

## 7. O que os dados permitem, e o que não

**A. Fatos observados.** (1) Nenhuma direção por minuto/hora/dia/HH:MM. (2) Queda do ouro em 09:15–09:30 UTC (73% dos dias, −272 pts) em jul–set. (3) Repique após quedas no M5/M15, só para baixo. (4) Atividade, spread e volatilidade têm estrutura forte e estável por relógio, sessão e agenda de notícias.

**B. Relações estatísticas.** A e B acima, com q, FWER, validação fora da amostra, teste por dia, coerência semanal e idêntico nos dois feeds. A atividade por relógio e a volatilidade clusterizada são as mais robustas de todas.

**C. Hipóteses para teste futuro** (a validar a partir de 07/10/2026, **sem alterar a regra**):
H1 — janela 09:15–09:30 UTC negativa; deslocamento de +1 h após 25/10. H2 — repique após `BREAK_DOWN` M5 (≥ 53% em +5, média ≥ +30 pts). H3 — atividade 12–15h UTC > 1,4× o range e 20h < 0,6× (já estável; usar como filtro de risco). H4 — reversão M1 lag-1 continua a diminuir.

**D. O que ainda não é permitido afirmar.** Que A ou B sejam estratégia lucrativa; que continuem em outro regime, outro mês ou depois da mudança de horário do Reino Unido/EUA; qualquer causa (benchmark, abertura de mercado, fluxo); efeito de notícias na direção (o histórico do calendário não foi gravado, só o contexto de agenda); qualquer conclusão diária (N = 30–60).

## 8. Limitações

1. **12 semanas, 60 pregões, um regime** (ouro entre 3.960 e 4.697 USD). Horário exato (HH:MM) tem ~60 observações.
2. IC e FP são o mesmo mercado: coerência entre feeds ≠ replicação independente.
3. Barras de **bid**; compra a mercado paga o ask; slippage, comissão e swap não entram.
4. Horizontes de +5 barras se sobrepõem; por isso o teste por dia.
5. Pausa diária 21:00–22:00 UTC: forward que atravessa a pausa mistura gap + spread (excluído onde indicado).
6. `price_position_*` está em pontos desde a abertura; `news_*` usa a agenda (programada), não valores divulgados.
7. **Lacuna da coleta:** o calendário histórico (actual/forecast) não foi gravado no backfill; só aparece o que o EA vê ao vivo (11 linhas). Corrigir antes de estudar surpresas.
8. A classificação BEHAVIOR_TYPE abaixo é nossa; achados A e B foram descobertos dentro do mesmo conjunto usado para varrer ~70 mil hipóteses — a validação fora da amostra e a janela futura são o que importa.

## Classificação BEHAVIOR_TYPE dos achados

| Achado | BEHAVIOR_TYPE | Status |
|---|---|---|
| Queda 09:15–09:30 UTC | DIRECTIONAL (janela de horário) | candidato forte, falta amostra futura |
| Repique após BREAK_DOWN | REVERSAL (STRUCTURAL) | candidato |
| Relógio → range/volume/spread | ACTIVITY / VOLATILITY / LIQUIDITY_PROXY | robusto |
| Agenda de notícias → range/volume | ACTIVITY | robusto (agenda), direção não medida |
| Agrupamento de volatilidade | VOLATILITY | robusto |
| Reversão lag-1 M1 | SEQUENCE | decaindo, inoperável |
| Candles clássicos, geometria, MTF, níveis, números redondos | — | nada |
