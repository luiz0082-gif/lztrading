# LondonDrop v1.02

EA de **demo/teste** para ouro: uma operação por dia no horário de Londres (padrão: venda às 10:20), sem stop loss por padrão, meta em dinheiro (TP US$ 5), saída de emergência em perda de US$ 15 e saída obrigatória às 23:30 do servidor. O trailing no estilo PieceTrend existe mas vem desligado.

Tese, regra, custos, riscos e critérios de falsificação: [`docs/LondonDrop.md`](../../../docs/LondonDrop.md).

## Instalação rápida
1. Copiar `LondonDrop.mq5` para `MQL5\Experts\LondonDrop\` do terminal e compilar.
2. Anexar ao gráfico do **XAUUSD** (qualquer timeframe), conta **demo**, com "Permitir negociação algorítmica".
3. Presets em `presets/`: **`LondonDrop_BOM_TP5_emerg15.set`** (igual ao padrão do EA), `_sem_emergencia`, `_US15_lote003` (US$ 15 com 0,03 lote) e `_ANTIGO_trailing150` (não recomendado).

## Inputs (grupos numerados, tudo opcional)
| Grupo | Conteúdo principal |
|---|---|
| 01 Identificação | liga/desliga ordens, magic, instância |
| 02 Símbolo | exige ouro (XAU/GOLD) |
| 03 Estratégia | direção, relógio (Londres/servidor/UTC), hora e minuto da entrada, janela, dias da semana, datas a pular |
| 04 Filtros | spread, idade do tick, notícia (calendário) |
| 05 Horários | regra servidor→UTC, não entrar perto da saída |
| 06 Execução | desvio, tentativas, espera |
| 07 Risco | lote (fixo ou pela meta), lote máximo, margem, emergência por perda flutuante, limite semanal, circuit breaker |
| 08 Stop Loss | **desativado**; stop opcional e stop de desastre opcional |
| 09 Profit/Alvo | TP (dinheiro ou pontos), meta diária, saída 23:30, tempo máximo de posição |
| 10 Posição | trailing (ativação em pontos ou dinheiro, ratio, expoente, servidor/virtual) |
| 11 Limites diários | operações por dia, perda diária |
| 12 Painel | mostrar, posição, minimizar |
| 13 Telemetria | CSV, heartbeat, log |
| 14 Avançado | debug |

## Relação lote × dinheiro
Com 0,01 lote, 1 ponto = US$ 0,01. Meta de US$ 5 = 500 pts; US$ 15 = 1.500 pts (sem suporte nos dados). Para US$ 15 com 500 pts use 0,03 lote (`InpLotFixed=0.03`, `InpTakeProfitMoney=15`) ou `InpLotMode=BY_TARGET` com a meta de US$ 15 e `InpLotTargetPoints=500`.

## Painel
Estado, relógios (Londres e servidor), posição, gestão (TP, trailing, SL, saída), risco (dia, semana, limites, circuit breaker), telemetria. Botões: **PAUSAR ENTRADAS/RETOMAR**, **FECHAR AGORA**, **RESETAR CB**, **−/+** minimizar.

## Kill switch
Variável global do terminal `LondonDrop_<magic>_KILL`: `1` bloqueia novas entradas; `2` também fecha a posição aberta.

## CSV
`MQL5\Files\LondonDrop\` — `events`, `trades`, `daily`, `decisions` (separador `;`, schema `LD1`).
Campos de `trades`: tempos em servidor e Londres, preços, TP/SL inicial e final, lucro bruto/comissão/swap/líquido, MFE/MAE em dinheiro e pontos, trailing ativado, motivo de saída (`TP`, `TRAIL`, `TIME_EXIT`, `EMERGENCY`, `DAILY_LOSS`, `KILL_SWITCH`, `MANUAL`, `SL`...).

## Não verificado
Compilado, **não executado** em terminal nem no Strategy Tester. A primeira execução deve ser em demo, observando o painel, o log Experts e o CSV `events`.
