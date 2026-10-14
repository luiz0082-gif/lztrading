# Diagnóstico MicroMomentum — IC Markets (A) e FP Markets (B)

- **Data:** 2026-10-06 (dados até A 2026-10-07 01:23 e B 2026-10-06 19:18, hora do servidor)
- **Base:** 467 trades (310 do relatório anterior + 157 novos), 7 tipos de CSV, 2 plataformas
- **Reprodução:** `python tools/micromomentum/analyze.py` (lê os CSVs sem alterá-los)
- **Anterior:** `RELATORIO-MICROMOMENTUM-2026-10-05.md`. Os dados são ao vivo e os totais mudam a cada execução.

## 1. Resumo

| | Antes (310 trades) | Agora (467 trades) |
|---|---|---|
| Net dos trades do EA | +230,83 | **+211,46** |
| Win rate | 82,6 % | 77,1 % |
| Pior trade fechado | −1,55 | **−18,75** |
| Pior MAE | −42,11 | **−90,05** |
| Maior hold | 3,85 h | **10,95 h** |

Os 157 trades novos somaram **−19,37**. O que mudou: apareceram as **primeiras perdas realizadas grandes**, todas por `MANUAL_TERMINAL` (6 trades, −68,51), e as versões 2.20 entraram em operação.

## 2. Por versão e plataforma (USD)

| Plataforma | Versão | Trades | Net | Win | Expectativa | Pior trade | Pior MAE |
|---|---|---|---|---|---|---|---|
| A (IC) | v2.00 | 140 | +136,08 | 96 % | +0,97 | −0,70 | −35,39 |
| A (IC) | v2.10 | 246 | +42,40 | 63 % | +0,17 | −14,12 | −90,05 |
| A (IC) | **v2.20** | 15 | +5,68 | 67 % | +0,38 | −0,94 | −35,07 |
| B (FP) | v2.00 | 34 | +14,32 | 88 % | +0,42 | −18,75 | −42,11 |
| B (FP) | **v2.20** | 32 | +12,98 | 94 % | +0,41 | 0,00 | −87,24 |

Total por versão: v2.00 +150,40 (174 trades), v2.10 +42,40 (246), v2.20 +18,66 (47).

**Fatos:** a v2.00 teve a melhor expectativa, mas é a versão mais antiga e com 6 posições e sem ESCAPE. A v2.10 tem 6× menos expectativa por trade. A v2.20 tem 47 trades, amostra pequena.

## 3. A cauda é o problema central

| Medida (467 trades) | Valor |
|---|---|
| Trades com MAE ≤ −500 pts ("profundos") | **52 (11,1 %)**, net conjunto −26,38 |
| Desses, fechados manualmente | 6 (5 na A e 1 na B, −68,51) |
| Net sem os fechamentos manuais | +277,56 |
| Net dos fechamentos manuais (10 trades) | −66,10 |
| Trades com hold > 1 h | 31 (net −39,78) |
| Profundos que eram compras | 41 de 52 (79 %); compras são 68 % de todos os trades |

- **Os profundos não começam bem.** Só 21 % estavam no lucro aos 5 s, contra 36 % dos demais. 63 % chegam a −100 pts em até 60 s (mediana 45 s). Só 15 % chegam a −100 pts em até 10 s.
- **Estado em 5 s prevê a cauda** (todas as 423 posições com leitura):

| Pontos aos ~5 s | Trades | % que vira profundo | Net médio |
|---|---|---|---|
| pior que −60 | 25 | **32 %** | **−0,59** |
| −60 a −30 | 70 | 20 % | +0,57 |
| −30 a −10 | 112 | 9,8 % | +0,27 |
| −10 a 0 | 68 | 11,8 % | +0,55 |
| 0 a +15 | 75 | 8,0 % | +0,62 |
| acima de +15 | 73 | 5,5 % | +0,67 |

- **Empilhar não aumentou a taxa de cauda nesta amostra.** A taxa de profundos é 10,8 % sem posição aberta no mesmo lado, 8,8 % com 1, 14,8 % com 2, 12,5 % com 3–4 e 8 % com mais de 4 (só 25 trades). Isso **não sustenta** a porteira de empilhamento da v2.20 como defesa contra a cauda; a hipótese anterior não se confirmou.

### O episódio de 06/10 03:10 (A)

- A sessão A/S125858 (v2.10, **8 posições abertas permitidas**, impulso 30 pts) foi parada às 03:10:04 por mudança de inputs **com 8 posições abertas**. A sessão seguinte (S211004, v2.10, máximo 2) herdou as 8.
- 5 compras abertas entre 01:45 e 02:35, todas contra o mercado em −723 a −1.048 pts, foram fechadas manualmente por volta das 03:17 com −6,54 a −14,12 cada (soma **−49,76**).
- Na B, a posição `411190828` (compra aberta 05/10 16:16, MAE −30,65, 10,95 h) foi fechada manualmente: **−18,75**.

**Inferência:** quando posições de impulso ficam contra o movimento por horas, a saída acaba sendo manual. O resultado real do estilo inclui esses fechamentos. O relatório anterior mostrava só trades que voltaram ao alvo.

## 4. v2.20 em produção (47 trades)

| Medida | Valor |
|---|---|
| Saídas | ESCAPE 35 (74 %), TP_SERVIDOR 7, TP_MONEY 5 |
| Expectativa | +0,40 por trade |
| Trades profundos | 2: A −35,07 (1.750 pts, 75 min até o ESCAPE) e B −87,24 (4.356 pts, **7,2 h** até o ESCAPE, com pullback ligado) |
| Pontos em 1 / 3 / 5 s (mediana) | −3,5 / −3,0 / −3,0 |
| Tempo até o pior ponto (`mae_ms`, mediana, 35 trades) | 7,4 s |

**Filtros (`signals.csv`):**

| Filtro | Bloqueios |
|---|---|
| `impulso_excessivo` | 8 |
| `pilha_posicao_negativa` | 18 |
| `pilha_intervalo` | 3 |
| `janela_bloqueada` | 0 (nenhuma entrada na janela 15:25–15:40) |
| `slip_high` | 0 (nenhuma entrada com slippage ≥ 20 pts) |

**Pullback virtual (só na B/S222400):**

| Evento | Quantidade |
|---|---|
| Armados (`WAIT`) | 486 |
| Disparados (viraram entrada) | 21 (**4,3 %**) |
| `pullback_expirou` | 309 |
| `pullback_cancelado_estado` | **113** |
| `pullback_invalidado` | 5 |
| `pullback_sinal_oposto` | 3 |

Os 21 disparos esperaram em média 801 ms e recuaram em média 42 % do impulso. Resultado: 22 trades, +6,98, win 91 %, incluindo o −87 da seção acima.

**Inferências:**
- **A cauda profunda da v2.20 não vem de entrada ruim.** Nos dois casos o trade andava a favor ou perto de zero nos primeiros segundos (`pts_5s` = +23 no caso A) e o pior ponto veio 26 a 79 min depois. Teto de impulso e pullback atacam o "contra rápido" e não essa reversão lenta.
- **O pullback converte pouco.** 4,3 % dos armamentos viram entrada. Os 113 cancelamentos por estado são muitos e **não foram explicados**: a causa provável é o estado deixar de ser `SCANNING` (cooldown, spread, limite por vela), mas isso é hipótese a conferir no código e nos `STATE_CHANGE`.
- 47 trades é amostra pequena. Nenhum filtro novo tem evidência suficiente de efeito.

## 5. Teste da ideia: ordem posicionada em preço melhor

Usei o caminho de cada posição nos primeiros segundos (`positions.csv`) para simular "e se tivesse entrado d pts melhor que o mercado, esperando até T segundos". É uma aproximação: usa o caminho a partir da entrada a mercado, sem fila nem slippage de limite.

| Espera | d (pts) | Preencheria | Net médio dos preenchidos | Net médio dos não preenchidos | Profundos nos preenchidos | Profundos nos não preenchidos |
|---|---|---|---|---|---|---|
| 1 s | 10 | 79 % | +0,40 | +0,64 | 25 % | 21 % |
| 1 s | 20 | 36 % | +0,47 | +0,44 | 26 % | 23 % |
| 3 s | 20 | 52 % | +0,36 | +0,55 | 29 % | 19 % |
| 3 s | 30 | 31 % | +0,26 | +0,54 | 30 % | 22 % |
| 5 s | 20 | 60 % | +0,39 | +0,55 | 28 % | 18 % |
| 5 s | 30 | 41 % | +0,35 | +0,53 | 32 % | 18 % |

**Fatos:**
- Quanto maior o desconto exigido, menor o preenchimento: com 30 pts e 3 s, 31 %.
- Os preenchidos **não têm menos cauda** (profundos 25–32 %, contra 18–24 % nos não preenchidos).
- Os não preenchidos têm net médio maior (cerca de +0,55 contra +0,26 a +0,39).

**Inferência:** esperar o recuo seleciona as entradas em que o impulso falha (seleção adversa) e deixa de fora as em que ele continua. Isso concorda com o resultado ao vivo do pullback (4,3 % de conversão).

**Ressalva:** o benefício do melhor preço de entrada em si (d pts a menos de risco) não está nessa tabela. Com lote 0,02, d = 20 pts vale US$ 0,40 por trade preenchido, que não é desprezível diante de uma expectativa de +0,40 a +0,60 por trade.

## 6. Execução e custos

| | A (IC) | B (FP) |
|---|---|---|
| Slippage médio de abertura | +4,9 pts (p90 26) | 0 |
| Latência mediana | 382 ms | 187 ms |
| Falhas de fechamento (novos dados) | 16 | 1 |
| Comissão total (467 trades) | −57,54 | |

A comissão consome 21 % do lucro bruto agregado (−57,54 sobre ~269). As saídas ESCAPE (118 nos dados novos) rendem +18,56 líquidos.

## 7. Conta

| | A (IC) | B (FP) |
|---|---|---|
| Saldo / equity | 12.262,82 / 12.243,20 | 100.290,33 / 100.265,87 |
| Pior flutuante nos dados novos | −217,36 (06/10 05:35) | −157,84 (06/10 09:03) |
| Menor equity nos dados novos | 11.950,14 | 100.115,50 |
| Maior drawdown de equity (total) | −489,49 | −255,56 |

Esses números incluem operações de outros magics na mesma conta (ver relatório anterior; não foi refeita a reconciliação).

## 8. Fatos, inferências e hipóteses

### Fatos
- 467 trades, net +211,46; os 157 novos somaram −19,37.
- 6 fechamentos manuais (5 na A, 1 na B) somando −68,51, que são as maiores perdas realizadas.
- 11,1 % dos trades tiveram MAE ≤ −500 pts; 79 % deles eram compras.
- Pior que −60 pts aos 5 s: 32 % viram cauda profunda e o net médio é −0,59.
- v2.20: 47 trades, 74 % saídas por ESCAPE, duas posições com MAE de −35 e −87.
- Pullback virtual: 486 armados, 21 entradas.
- A taxa de cauda não aumentou com empilhamento nesta amostra.

### Inferências
- A cauda é majoritariamente reversão lenta depois de entrada boa ou neutra; o filtro de entrada corrige só a parte "contra rápido".
- Esperar recuo reduz muito as entradas e seleciona as piores, pelos dados de caminho.
- O resultado do estilo inclui os fechamentos manuais; o EA sozinho não resolve a cauda.

### Hipóteses
- Uma reação precoce ao caminho (aos 3–5 s) pode reduzir cauda sem stop, mas não foi testada.
- Os 113 cancelamentos por estado indicam que o armamento do pullback está sendo desfeito por outro filtro do EA.
- A diferença de latência entre A e B (382 contra 187 ms) pode fazer ordens posicionadas funcionarem melhor na B.

## 9. Limitações
- 47 trades na v2.20 e 21 no pullback; as comparações entre versões misturam configurações, dias e regimes.
- A simulação da seção 5 não modela fila, rejeição nem slippage de ordem limite.
- A hora e o fuso do servidor são deduzidos, não declarados nos arquivos.
- Não foi testado nada no testador de estratégia; este diagnóstico é só dos CSVs.

## 10. Complemento: ticks na janela, 113 cancelamentos e reação precoce

### 10.1 Mínimo de ticks na janela (FP)

Medido nos momentos em que o impulso já passava de 30 pts (`ticks.csv`, `win_ticks`):

| | IC (A) | FP (B) |
|---|---|---|
| Ticks por segundo (`account.csv`, mediana) | 6,4 (média 8,7) | 2,0 (média 1,96) |
| `win_ticks` mediana / p90 / p99 | 26 / 46 / 72 | 3 / 4 / 4 |
| Janelas com ≥ 4 ticks | 99,9 % | 17,5 % |
| Janelas com ≥ 6 ticks | 99,5 % | **0 %** |
| Janelas com ≤ 3 ticks | 0,1 % | 82,5 % |
| `poucos_ticks` entre os momentos de impulso | 0,1 % | 25,5 % |
| `win_ticks` nas entradas | 4 a 42 (mediana 12) | 3 a 4 |

**Fato:** na FP a janela nunca tem 6 ticks e raramente tem 4. Com `InpMinTicksInWindow = 6` a FP não entra nunca; com 4 entra em 17,5 % das janelas; com 3, nas demais. Quatro sessões da FP rodaram com mínimo 6.

Spread: na FP, 19,7 % dos ticks e **28 % dos ticks em impulso** têm spread > 12 (p90 = 14, só 0,9 % > 15). Na IC são 0,5 %.

### 10.2 Os 113 cancelamentos do pullback

**Fato:** os 113 `pullback_cancelado_estado` (FP, sessão S222400) foram imediatamente precedidos (seq anterior) por um `STATE_CHANGE: SCANNING -> BLOCK_SPREAD | spread N > 12`. Nenhum foi por outro motivo. Na sessão houve 1.072 transições para `BLOCK_SPREAD`.

**Inferência:** o filtro de spread (máximo 12) oscila durante o impulso na FP e desfaz o armamento. É o comportamento do código, não um bug de lógica. O custo real: 23 % dos armamentos (113 de 486) morreram por spread.

**Consequência para as versões novas:** a v2.40 (pendente real) **não cancela por `BLOCK_SPREAD`**; só por TTL, fuga/recuo do preço, sinal oposto, limite de posições ou bloqueios duros (pausa, meta, trading desligado).

### 10.3 Reação precoce: o que o histórico diz

Simulação sobre o caminho de cada trade (`positions.csv`, 467 trades): se a posição estava pior que −X pts no instante T e saísse no zero a zero ao voltar, o resultado seria ~0 nas que voltam e o real nas que não voltam.

| T | X | Trades afetados | Net real | Net estimado | Variação |
|---|---|---|---|---|---|
| 5 s | 60 pts | 26 | −14,55 | −10,00 | **+4,55** |
| 5 s | 45 pts | 53 | −0,75 | −11,29 | −10,54 |
| 5 s | 30 pts | 96 | +25,36 | −11,29 | −36,65 |
| 10 s | 60 pts | 53 | +7,55 | 0,00 | −7,55 |
| 60 s | 100 pts | 61 | −7,30 | −44,20 | −36,90 |
| 300 s | 200 pts | 33 | −10,03 | −32,87 | −22,84 |
| 600 s | 300 pts | 37 | +25,77 | −6,54 | −32,31 |

**Fatos:**
- Em quase todas as faixas a variação é **negativa**: mais de 90 % das posições fracas voltam ao zero a zero e cerca de metade termina em TP (+1,20). Sair cedo no zero a zero troca esses TPs por ~0.
- A única faixa positiva é 5 s / 60 pts (+4,55 em 26 trades), dentro do ruído.
- Entradas feitas enquanto outra posição estava ≤ −60 pts (246 de 467): net médio +0,38 contra +0,53 nas demais; profundos 10 % contra 13 %. Bloquear essas entradas custaria cerca de US$ 94 no período e não reduz a taxa de cauda.

**Inferência:** com estes dados a reação precoce **tende a reduzir o lucro**; o que ela entrega é menos tempo de exposição nos casos fracos, não mais expectativa. A cauda real (−68,51 em fechamentos manuais) vem das poucas posições que não voltam, e nenhum limiar testado as separa das que voltam sem sacrificar os TPs.
