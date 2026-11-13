# Auditoria de integridade (13/11/2026): ticks por dia e v1.08

Tudo foi rodado NA PLATAFORMA DO USUARIO (terminal Clear instalado, base dele). O relatorio HTML da v1.08 (21 MB) ficou so nos arquivos locais do usuario, fora do git.

| Arquivo | O que e |
|---|---|
| `VP_tick_audit_13out-11nov.csv` | Saida do script `MQL5/Scripts/VantagePulse_TickAudit.mq5`: por dia, ticks do terminal, ticks com BUY/SELL, barras M1, divergencia de maxima/minima/volume entre barra e ticks, maior intervalo sem tick. |
| `tester_v108_ref_13out-02nov.csv` | Telemetria da v1.08 no teste de referencia (13/10-02/11, preset v108_LOTE1_STOP80_TP240): 11.142 operacoes, +R$ 43.639, 9/14 dias (identico a v1.07). Tem MANIFEST, detalhe de entrada/saida (MAE, tempo ate o pico, slippage, spread, janelas, buffer) e BUFFER_SATURATION. |
| `SHA256_ticks_e_build.txt` | SHA-256 e tamanho da base de ticks (tester e terminal do usuario), historico M1, EX5/MQ5 v1.07 e v1.08 e preset v1.08. |

## Achados (fatos medidos)

1. **A v1.08 e equivalente a v1.07**: as 11.142 entradas (hora, lado, preco) e as 11.142 saidas (hora, motivo) sao identicas.
2. **Base do terminal e completa**, exceto 13/10: 2,0-2,8 milhoes de ticks por pregao (~4.000/min, 94-97% com flag BUY/SELL). 13/10 tem so 261.787 ticks (484/min, 12% dos outros dias). Divergencia de maxima/minima entre barra e ticks e minima (0-3 barras por dia; 27 em 13/10). O volume da barra M1 nunca bate com a contagem de ticks (99,8-100% das barras, todos os dias): o tick_volume da B3 nao e contagem de ticks. E o tipo de divergencia que o log do tester cita como "tick volumes not matched".
3. **Assinatura dos dados vistos pelo EA** (v1.08, mesmo teste):

| | 9 dias positivos | 5 dias negativos (16, 19-22/10) |
|---|---|---|
| Ticks na janela rapida (1 s) | ~51 | ~110 |
| Spread medio na entrada | **5,00 exato em todos os dias** | 5,14-5,27 |
| Saida por sinal oposto | **0%** | 5-7% |
| Trailing | ~11% | ~33% |
| Alvo (TP) | 8,6% | 0,8% |
| Score medio na entrada | 54,9 | 77,8 |
| Pontos por operacao | **+44,9** | **-4,6** |
| BUFFER_SATURATION | 0 | 10 eventos |

   Spread cravado em 5,00, densidade ~51 ticks/s e zero sinais opostos nos 9 dias positivos sao a assinatura de ticks sinteticos gerados a partir das barras. Os 5 dias negativos mostram spread variavel e densidade ~2x, como dado real. Isso bate com o log do tester do usuario (ticks reais descartados em 9 dias, mantidos so em 16, 19-22/10). **Inferencia forte, nao prova direta**: nao ha como ler o tick que o tester entregou dia a dia.
4. **F-04 confirmado**: nos dias de dado real a janela lenta enche o buffer de 4.096 ticks (ex.: 4.095 ticks cobrindo 5,7 s em vez de 8 s). 10 eventos, todos nos 5 dias negativos.

## Nao explicado

- Por que o tester manteve ticks reais so em 16, 19-22/10 se o volume diverge em 100% das barras de todos os dias.
- Por que o harness do Claude (`C:\ClearMM_Tester`), mesmo com base de ticks identica (mesmo hash), nao reproduz a plataforma do usuario (historico M1: 24,6 MB no terminal do usuario x 2,1 MB no harness; hipotese nao verificada).
