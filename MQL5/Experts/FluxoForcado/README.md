# Fluxo Forçado — o EA que eu rodaria

> Ressalva, uma vez só: eu não tenho dinheiro nem conta. O texto abaixo é o que eu faria se tivesse. Não é recomendação de investimento.

## 1. A tese em uma frase

Nos últimos 30 minutos do pregão de Nova York, participantes **obrigados** a operar (não os que *querem* operar) empurram o S&P 500 na **mesma direção do movimento do dia**. Eu não tento prever o mercado. Tento prever quem vai ser *forçado* a comprar ou vender, e em que horário.

## 2. De onde vem a edge

Três fluxos mecânicos se concentram perto do fechamento, e todos têm o mesmo sinal que o retorno do dia:

| Fluxo | Mecânica | Por que tem a mesma direção do dia |
|---|---|---|
| **ETFs alavancados** (SPXL, UPRO, TQQQ, SQQQ…) | Precisam manter a alavancagem diária. Rebalanceiam perto das 16:00. | Volume de rebalanceamento ≈ L·(L−1)·AUM·r. Seja o fundo 3x ou −3x, **L(L−1) > 0**: em dia de alta todos compram, em dia de queda todos vendem. |
| **Hedge de gamma dos dealers** | Quando os dealers estão *vendidos* em gamma, o delta-hedge obriga a comprar na alta e vender na queda. | Amplifica o movimento. Baltussen et al. (2021) mostram que o momentum intradiário é bem mais forte quando o gamma dos dealers é negativo. |
| **Ordens MOC / fundos que rebalanceiam no fechamento** | Fundos de índice e de risco-alvo executam no leilão de fechamento. | Vol-targeting reduz exposição em dia de queda forte. |

Evidência acadêmica: Gao, Han, Li & Zhou (2018, *JFE*) mostram que o retorno do início do dia prevê o retorno da última meia hora no SPY. Baltussen, Da, Lammers & Martens (2021, *JFE*) confirmam o efeito em mais de 60 índices e o associam ao hedge de gamma.

### Por que isso não foi arbitrado até hoje?

1. **O fluxo é forçado.** Quem gera o fluxo não pode deixar de operar. Arbitragem acaba com anomalias de *preço*, não com necessidades de *execução*.
2. **Já foi parcialmente arbitrado.** HFTs e mesas de prop antecipam esse fluxo, e por isso o efeito é menor que nos papéis originais. O que sobra é pequeno e barulhento demais para um fundo grande perder tempo, mas pode interessar a quem opera 1 lote.
3. **Capacidade limitada.** São alguns bps por dia, em cerca de 30 minutos. Não comporta bilhões. Anomalias que não escalam sobrevivem mais.
4. **Risco de cauda.** Quem opera contra o fluxo tem de carregar risco no momento de maior volume do dia. Nem todo market maker quer isso.

### Quanto tempo pode durar?

Enquanto houver AUM relevante em ETFs alavancados e dealers vendidos em gamma. **Ponto de atenção sério:** desde 2022 as opções 0DTE mudaram o perfil de gamma do mercado, e há estudos indicando que em alguns regimes os dealers ficam *comprados* em gamma, o que amortece o efeito. Eu contaria com uma edge que se degrada aos poucos, não com uma edge permanente. Por isso o EA tem desligamento estatístico.

## 3. Ativo e timeframe

- **US500 / SPX500 / US500.cash (CFD do S&P 500), e só ele.** É onde os fluxos acima são maiores e mais bem documentados, com o menor spread relativo do varejo (~1 bp nesse horário). O US100 funciona pela mesma lógica, mas tem correlação de ~0,9 com o US500: é **a mesma aposta**, não diversificação.
- **Timeframe:** o EA lê candles **M1** e é indiferente ao gráfico onde está anexado. O "timeframe" real é o calendário: **15:30 → 15:58 de Nova York**.
- **Por que não mini-índice (WIN)?** No Brasil não existe o mesmo volume de LETFs nem de dealers de gamma. A mecânica não se transfere. Não misture as coisas.

## 4. Regras objetivas

Todos os horários são de **Nova York** (o EA converte a partir do horário do servidor).

| Item | Regra |
|---|---|
| Sinal | `r = ln(P_15:30 / P_fechamento_anterior_16:00)` |
| Filtro | Operar só se `|r| ≥ K × média(|r|)` dos últimos 20 pregões (K = 1,0). Dia sem movimento = sem fluxo = sem trade. |
| Direção | `r > 0` → compra. `r < 0` → venda. |
| Entrada | A mercado, na primeira cotação após 15:30 (janela máxima de 5 min). |
| Stop loss | **Catastrófico**: 2,5 × média de `|ln(P_15:58/P_15:30)|` dos últimos 20 pregões. Na prática é atingido em poucos dias. |
| Take profit | **Nenhum.** O fluxo se concentra nos minutos finais (leilão). TP ou trailing cortariam o trade justamente antes do pagamento. |
| Trailing | **Nenhum**, pelo mesmo motivo. |
| Saída | Por tempo, às 15:58. Nunca dorme posicionado: sem swap e sem gap. |
| Frequência | No máximo 1 trade por dia. Estimo 35–45% dos dias com sinal (~90 trades/ano). |
| Dias sem dado às 15:30 | Meio pregão (Black Friday, véspera de Natal) e feriados são pulados automaticamente. |

## 5. Gestão de risco

- **Tamanho:** 0,5% do equity até o stop catastrófico. Como o stop fica longe e a saída costuma ser por tempo, a perda típica fica em torno de 0,15–0,25% do equity.
- **Operações simultâneas:** 1. Com `InpOnePerMagic = true`, se você colocar o EA em US500 e US100 com o mesmo magic, só o primeiro opera. Se quiser os dois de propósito, use magics diferentes e **reduza o risco à metade** em cada um.
- **Drawdown esperado:** estimo 6–10% em operação normal (sequências de 8–12 perdas pequenas são comuns em edge de ~52–55% de acerto). Se passar disso, algo mudou.
- **Desligamento automático (kill switch):**
  1. Equity cai **15%** do pico → fecha e desliga.
  2. Nos últimos **60 trades**, t-stat do retorno médio **< −1,5** → desliga. Isso significa evidência estatística de que a edge virou negativa, não apenas azar.
  3. O EA **não** religa sozinho. Para religar, apague a variável global `FF_<magic>_<símbolo>_killed` (F3). Só faça isso depois de entender o que aconteceu.
- **Custo do kill switch:** com uma edge verdadeira mas pequena, a regra do t-stat tem ~2% de chance de disparar por azar em cada janela independente de 60 trades. Em 5 anos isso acumula. É o preço de não sangrar até zero quando a edge morrer. Eu aceito esse custo.
- Depósitos e saques distorcem o pico de equity guardado em variável global. Depois de movimentar a conta, apague `FF_<magic>_<símbolo>_peak`.

## 6. Instalação: o ponto que mais derruba EAs de horário

1. Copie `FluxoForcado.mq5` para `MQL5/Experts/` e compile (F7) no MetaEditor.
2. **Configure o relógio.** A maioria das corretoras de CFD usa GMT+2 no inverno / GMT+3 no verão seguindo o horário de verão dos EUA (valores padrão: `InpServerGMTOffset = 2`, `InpServerDST = SRV_DST_US`). **Confira** com um teste simples: no gráfico M1 do US500, o pico de volume da abertura (09:30 NY) precisa cair no horário que o EA imprime no log ao iniciar (`09:30 NY hoje = 16:30 no servidor`, por exemplo). Se não bater, ajuste antes de fazer qualquer outra coisa. Um relógio errado transforma a estratégia em aleatoriedade.

## 7. Como fazer um backtest honesto

**Configuração:** "Cada tick baseado em ticks reais", com o histórico da **sua** corretora, comissão configurada e spread real (não fixo). Período: o máximo disponível, idealmente de 2015 em diante.

**O que é FIXO (vem da tese, não do otimizador):**
- Horário de entrada 15:30 e saída 15:58.
- Direção = sinal do retorno do dia.
- Lookback de 20 dias, K = 1,0, stop de 2,5×.

**Não otimize nada.** O objetivo não é achar o melhor parâmetro, é descobrir se a tese se sustenta. Em vez de otimizar, faça um **teste de robustez**:
- Entrada em 15:00 / 15:15 / 15:30 / 15:45 e K em 0,5 / 1,0 / 1,5. Na tese verdadeira, **todas** as combinações ficam positivas e a superfície é suave. Se só uma funcionar, é ruído. Descarte.

**Testes obrigatórios de sanidade:**
1. **Placebo:** `InpPlaceboInvert = true` (inverte a direção). O resultado deve ficar perto de −(edge + custos). Se o invertido também der lucro, há bug ou look-ahead.
2. **Placebo de horário:** mesma lógica às 11:00 → 11:28. A tese prevê edge perto de zero ali. Se lá também der lucro, a explicação não é fluxo de fechamento, e você não sabe o que está operando.
3. **Por regime:** separe 2015–2019, 2020–2021 e 2022–hoje (era 0DTE). Espere o último período mais fraco. Se ele for **negativo**, eu não ligaria em conta real.
4. **Por ano:** mais de 70% dos anos positivos. Se um ano sozinho responde por mais de 50% do lucro (2020, por exemplo), a edge depende de crise.
5. Rode o primeiro backtest com `InpKillEnabled = false` para ver a edge crua.

**Tamanho mínimo de amostra:** com Sharpe por trade de ~0,08–0,10 (realista), um t-stat de 2 exige **n ≈ (2/0,1)² = 400 trades**, ou seja, ~4–5 anos de sinais. Menos que isso é anedota. Depois do backtest, rode **6 meses em demo ou com o lote mínimo** e compare o custo real (spread às 15:30, slippage) com o do backtest.

## 8. Honestidade: onde e por que perde

- **Edge pequena.** Estimo de 2 a 6 bps líquidos por trade. Uma corretora com spread de 2–3 pontos no US500 ou comissão alta **anula a estratégia inteira**. Custo não é detalhe aqui, é o que decide se ela funciona.
- **Reversões de fim de dia.** Em dia de "short squeeze" tardio ou de notícia às 15:40 (discursos do Fed, tarifas, geopolítica), o fluxo inverte e você está do lado errado.
- **Regime de gamma positivo.** Mercado calmo com dealers comprados em gamma = momentum de fechamento vira reversão à média. O EA não observa o gamma dos dealers (não há esse dado no MT5). O filtro K só reduz o problema, não o resolve.
- **Dias de FOMC, CPI e vencimento trimestral** trazem mais ruído. Não criei filtro para eles de propósito: filtro escolhido depois de ver o backtest é overfitting disfarçado.
- **O CFD não é o índice.** O preço às 16:00 no CFD reflete o futuro ES, não o leilão de fechamento do cash. A diferença é pequena, mas existe.
- **Por que pode parar de funcionar:** (1) crescimento das 0DTE mudando o sinal do gamma, (2) queda do AUM de ETFs alavancados, (3) mais participantes antecipando o fluxo, (4) mudança de regulação no leilão de fechamento. Qualquer um desses mata a edge **sem aviso**. O kill switch existe porque eu vou demorar a perceber.
- **O que eu não fiz:** este EA **não foi compilado nem backtestado por mim**. Não há MetaTrader neste ambiente. O código foi escrito para compilar sem erros e segue a API padrão do MQL5, mas a primeira coisa a fazer é F7 e depois os testes da seção 7. Não confie em nenhum número deste documento antes de reproduzi-lo com os dados da sua corretora.

## 9. Toque final

> "Dizem que é impossível quebrar a Wall Street com um EA de varejo."

E dizem certo. Este EA não quebra a Wall Street. Ele fica ao lado dela, no mesmo horário em que ela é **obrigada** a fazer o que faz, e cobra alguns bps de pedágio por dia. Na melhor das hipóteses, é um Sharpe entre 0,5 e 1,0 antes de você errar alguma coisa. Na pior, é o custo de descobrir, com risco de 0,5% por trade, que os HFTs chegaram antes.

O melhor que um EA de varejo consegue fazer sem mentir: **operar pouco, saber exatamente por que está ganhando, e desligar sozinho quando essa razão desaparecer.**
