# Relatório HFTShadow — 23/10 a 02/11/2026 (XAUUSD, IC Markets demo)

Status: **resultado negativo. Nenhum sinal de fluxo de ticks gera lucro depois de pagar o spread.** Hipótese de vantagem de HFT por fluxo de ticks: **não sustentada** pelos dados ao vivo.

## 1. Dados e auditoria (fatos)
- Arquivos: `MQL5\Files\HFTShadow\HFTShadow_{signals,heartbeat,events}_*.csv` do terminal IC (schema HS1; EA v1.00 e v1.01).
- Brutos: 38.399 linhas de sinais. **Anomalias encontradas (causa: bug do EA, não Strategy Tester):** os logs do Tester (`Tester\logs`) mostram só FluxMatrix e MicroMomentum; o HFTShadow nunca rodou nele. As anomalias vieram do EA ao vivo: cada **reconexão da conta (`reason=6`)** reinicia todos os EAs (o MicroMomentum registra "troca de conta/reconexão" no mesmo segundo). No reinício o `SymbolInfoTick` devolvia um tick antigo (ex.: 10/09/2026 no INIT) e o `CopyTicksRange` reprocessava milhões de ticks históricos (um DEINIT contou 5,79 M ticks): isso gerou sinais "do passado" (15–16/10), encheu a fila de pendentes (blocos de 4.096 linhas, 0% válidos, eventos `DROP`) e duplicou 2.348 sinais.
- Base limpa usada: apenas `valid=1` (tick de preço com ≤ 3 s de idade) e sem duplicatas por (`time_msc`, sinal, bid, ask): **25.277 sinais**, 23/10 21:37 → 02/11 16:22 (servidor), **7 dias com sinais** (6 úteis completos). Por sinal: imb10 17.050, imb30 3.677, mom250 2.493, mom1000 1.275, mom5000 782.
- **Inputs:** o EA ao vivo continuou com `imb10 = 0,90` mesmo na v1.01 (os inputs salvos no gráfico mantiveram o valor antigo; o novo padrão 1,0 não foi aplicado). imb10 segue sendo 67% dos sinais.
- Heartbeat: ping do terminal mediano 124 ms (valor quase constante, não é medida por tick); spread mediano 9 pts (US$ 0,09/oz), p90 12 pts.
- A base limpa remove os blocos inválidos e as cópias idênticas; sinais históricos reprocessados que ficaram válidos podem existir, mas são ticks reais e as duplicatas por (`time_msc`, sinal, bid, ask) foram removidas.

## 2. Método (definição)
Sinal calculado só com ticks até t. Compra: entra no **ask** em t+L, sai no **bid** em t+L+H. Venda: entra no **bid**, sai no **ask**. L = 0/100/300/1000 ms, H = 1/3/10/30 s. "Seguir" = na direção do sinal; "fade" = contra. Valores em US$ por onça (≈ 0,01 lote). t calculado por blocos de 1 minuto. 5 sinais × 4 L × 4 H × 2 modos = **160 combinações**.

## 3. Resultados (fatos observados)
- **0 das 160** combinações têm média positiva com t > 2.
- Referência (L=300 ms, H=10 s), média por sinal em US$/oz (seguir | fade | acerto ao seguir):

| Sinal | N | Seguir | Fade | Acerto (seguir) | t bloco (seguir) |
|---|---|---|---|---|---|
| imb10 | 17.050 | −0,092 | −0,081 | 40% | −11,0 |
| imb30 | 3.677 | −0,107 | −0,076 | 40% | −5,5 |
| mom250 | 2.493 | −0,074 | −0,129 | 45% | −3,9 |
| mom1000 | 1.275 | −0,055 | −0,158 | 46% | −1,8 |
| mom5000 | 782 | −0,156 | −0,067 | 46% | −1,4 |

- Melhores combinações (sem significância): mom5000 seguir, L 0 ms, H 30 s: +US$ 0,099/oz, 52% de acerto, t = −0,52 e positiva em só 2 de 6 dias; mom1000 seguir H 3 s: +0,050, t = −0,69.
- Por dia, o momentum fica negativo em **todos** os dias, seguindo ou não (−0,07 a −0,15). Por hora do servidor não aparece janela estável positiva.
- Excursão mediana de 30 s: ±US$ 0,56 contra spread de US$ 0,09: o preço se mexe, mas sem direção previsível por fluxo de ticks.

## 4. Inferência e hipóteses
- Os dados ao vivo **reproduzem o estudo em ticks históricos** (0/480 positivas em 5 ativos): sinais de fluxo de ticks de varejo custam mais (spread + atraso) do que rendem. Isso vale para os atrasos testados (0 a 1.000 ms).
- Hipótese não testada: a vantagem poderia estar em outro tipo de informação (notícia em segundos, liderança entre ativos, profundidade de mercado), que este EA não captura.

## 5. Limitações
- 6 dias úteis, preço virtual otimista (último tick ≤ t+L); latência real do corretor não medida; ouro apenas; reinícios por reconexão podem ter perdido sinais ao vivo nos minutos seguintes (bug corrigido na v1.02).

## 6. Critérios de falsificação (definidos antes, ver docs/HFT-M1-ESTUDO-2026-10-23.md §7)
- Rejeitar sinal com líquido ≤ 0 em validação/teste ou bruto < 2× spread → **atendido por todos os 5 sinais**. Os sinais de fluxo estão **rejeitados** para o ouro.

## 7. Recomendações
1. Encerrar o experimento de sinais de fluxo (ou deixar só como coletor de latência). Não há base para operar HFT por esses sinais.
2. v1.02 (feita em 02/11): janela de catch-up de 10 s no (re)início, `STREAM_RESET` registrado, referência de tick velha descartada. Reaplicar os inputs padrão (imb10 = 1,0) ao reanexar.
3. Direcionar o esforço aos candidatos de minutos/horas já documentados (ouro 12:15 servidor, LondonDrop), e testar notícia em ticks quando houver dados.

Arquivos: `docs/relatorios/mba/hftshadow_resultados_2026-11-02.csv` (160 combinações).
