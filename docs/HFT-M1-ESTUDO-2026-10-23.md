# HFT / scalping de ticks — o que os dados do MBA sustentam (2026-10-23)

Status: **pesquisa. Nenhuma estratégia de HFT com vantagem foi encontrada.** Este documento separa fatos, inferências, hipóteses e a estrutura proposta para testar com honestidade.

## 1. Dados usados (fatos)
- `RAW_TICKS` do MBA v1.23 (bid, ask, `time_msc` em ms, relógio do servidor). XAUUSD (IC/Raw): 8.806.031 ticks únicos (114 duplicatas removidas), 05→23/10/2026, **15 dias úteis**, 0 casos bid ≥ ask, 14 gaps > 60 s (fins de semana/pausa). Outros: XAGUSD 1,45 M, USTEC 2,79 M, US30 1,26 M, BTCUSD (FP) 0,78 M ticks (poucos dias).
- Custo medido nos ticks: ouro spread mediano US$ 0,09/oz (p90 0,12); prata 0,011; USTEC 0,96; US30 0,92; BTC 21,1.
- Scripts: `tools/mba/mba_tick_load.py` (carga/dedupe/qualidade) e `tools/mba/mba_tick_scan.py` (varredura).

## 2. Experimento (definição)
Sinal calculado só com ticks até t. Entrada: compra no **ask**, venda no **bid**, em t+L (L = 0/100/300/1000 ms, atraso de execução). Saída: lado oposto em t+L+H (H = 1/3/10/30 s). Cooldown 2 s. Fora de 23:30–01:15 servidor e com spread ≤ 1,6× mediana. Sinais: momentum de preço em 0,25 s/1 s/5 s e desequilíbrio de ticks (10/30), limiares pelos quantis 90/97/99,5% **do treino**, modos seguir e fade. Divisão cronológica por dia 60/20/20; t por blocos de 1 min. 480 combinações por ativo.

## 3. Resultado (fatos observados)
- **0 de 480** combinações com líquido > 0 em treino, validação e teste, em **XAUUSD, XAGUSD, USTEC, US30 e BTCUSD**.
- Melhor do ouro (momentum de 5 s no quantil 99,5%, seguir, segurar 30 s): bruto +US$ 0,33/oz e líquido +0,23 no treino, **−0,45 na validação e −3,0 (t de bloco) no teste**. O ganho bruto máximo de qualquer sinal (≈ US$ 0,3) é do tamanho de 3–4 spreads e some fora da amostra.
- Movimento absoluto do ouro (apenas magnitude, **sem direção**): mediana em 30 s de US$ 0,31–0,85 por hora do servidor, contra spread de 0,09. Maior em **15–17h** (NY) e **03–05h** (mediana 30 s: 0,56–0,85; 0,56–0,74). Menor em 23–02h.

## 4. Inferências
- Há movimento suficiente para pagar o spread (5–9×), mas **sem direção previsível por fluxo de ticks**: o preço de ticks do varejo não revela vantagem de latência. Com ordens a mercado, quem paga o spread e atrasa ~100–300 ms precisa de acerto > 0,5 + spread/(2·movimento). Com movimento de ≈ US$ 0,8 em 30 s e spread de 0,09, o mínimo seria ≈ 55%.
- A janela de 15–17h/03–05h do servidor serve como **filtro de atividade**, não como sinal direcional (coerente com o estudo de alcance: "relógio prevê volatilidade, não direção").
- Os achados de horário do MBA (ouro 10:25 Londres/12:15 servidor VENDA, iene 22:1x COMPRA) são trades de minutos/horas, **não HFT**.

## 5. Hipóteses ainda não testadas (candidatas, sem evidência)
1. Reação a notícia de alta importância nos primeiros segundos (surpresa × direção). Exige tick + calendário em volume; poucas amostras (< 15 dias).
2. Desequilíbrio ask/bid de atualizações (quote flicker) como indicador de pressão — só com profundidade de mercado (DOM está desligado no MBA).
3. Correlação ouro × DXY/USDJPY em ticks (lead-lag entre ativos): exige coleta simultânea sincronizada.
4. Reversão após rajada acima do p99,9 de atividade (rate500) — não coberto aqui (sinal `rate500` não foi usado como gatilho).

## 6. Estrutura proposta (se houver hipótese que passe os testes)
Princípio: **orçamento de borda**. Só operar quando ganho esperado bruto ≥ 2× custo medido no momento; caso contrário o EA não envia ordem.
- Camada de dados: buffer circular de ticks em memória (ring buffer), sem `iCustom`/handles no caminho quente; `OnTick` + `CopyTicksRange` com cursor; relógio do servidor.
- Camada de sinal: funções puras sobre o buffer (momentum, imbalance, taxa de ticks), parâmetros em `input group` numerados, estado persistente mínimo.
- Filtros: spread ≤ limite (ex.: 1,6× mediana), janela de sessão (15–17h, 03–05h servidor como filtro), fora de 23:30–01:15, idade do tick, notícia alta.
- Execução: `CTrade` com `SetAsyncMode` só se necessário, volume e preço pré-calculados e normalizados (tick size, volume step), filling IOC/FOK, `deviation` configurável, medição de latência (envio → `retcode` → `DEAL_TIME_MSC`), telemetria de slippage.
- Saída: alvo em dinheiro, **tempo máximo curto (ex.: 5–30 s)** e invalidação por perda flutuante em dinheiro; **sem stop loss por padrão** (perfil do operador); limite diário, circuit breaker, lote conservador. Lição do EA_HFT v1.07: 100% das perdas vieram de posições abertas > 120 s — o tempo máximo é obrigatório.
- Telemetria: CSV CORE + específico (sinal, spread, latência, MFE/MAE em ms), registro de cada bloqueio e motivo.
- Validação: primeiro em **modo sombra** (calcula o sinal e a posição virtual, sem enviar ordens) em demo/IC por ≥ 20 dias úteis; depois lote mínimo.

## 7. Critérios de falsificação (definidos antes)
- Rejeitar qualquer sinal cujo líquido por operação (ask-entrada/bid-saída, atraso L ≥ 300 ms) seja ≤ 0 em validação **ou** teste, ou cujo ganho bruto seja < 2× spread.
- Rejeitar se o resultado mudar de sinal entre treino e teste (como o momentum de 5 s no ouro).
- Exigir ≥ 30 dias úteis de ticks e ≥ 2 corretoras/feeds antes de lote real.

## 8. Limitações
- 15 dias úteis por ativo (teste de 3 dias); sem profundidade de mercado; ticks de varejo (sem fila, sem tamanho); latência do EA e do corretor não medidas; barras e ticks de 1 corretora (IC) para o ouro. Nada foi testado em terminal ao vivo.
