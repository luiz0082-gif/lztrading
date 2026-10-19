# HFT_RETAIL

Scalper de ticks (XAUUSD) com votação de 3 sinais (OFI, reversão por sequência, momentum). `HFT_RETAIL_v240_original.mq5` é a referência intacta da v2.4 (a que rodou na IC).

## v2.5 (2026-10-06) — correções, sem mudar a lógica do sinal
Compilada no MetaEditor (IC): **0 erros, 0 avisos**. **Não testada em execução nem no testador.**

| Problema na v2.4 | Correção |
|---|---|
| TP/SL em dinheiro nunca fechava por software (`ticket=0` antes de `CloseSymbol`) | Ticket só é liberado após o pedido de fechamento; motivo registrado |
| Kill switch só era avaliado ocioso e não fechava posição | Avaliado a todo tick; `InpKillSwitchClosePos` fecha posições; um fechamento não desfaz o estado |
| Sessão usava hora do servidor rotulada "GMT" (EA nunca operou: todas as execuções caíram em 22–08h do servidor) | `TimeGMT()`; motivo de bloqueio no painel e no CSV |
| "R$" fixo | Moeda da conta |
| Envio sem validação, retry em qualquer erro | Pré-checagem (AutoTrading, modo do símbolo, stops level, margem); retry só em requote/preço; TP/SL normalizados por tick size; cada tentativa em `orders.csv` |
| CSV sem hora real, painel/metrics a 4 Hz, `trades.csv` com motivo fixo | Schema `v25` em `HFT_Logs\v25\<data>\`; `time_server` em toda linha; snapshots só em mudança ou a cada `InpSnapshotSec`; `trades.csv` com lote, entrada/saída, duração e `exit_reason` real; DOM desligado por padrão |

Inalterado e **sem evidência de edge**: o ensemble. `InpMinConfidence` é inerte (a confiança é sempre ≥ 0,5 por construção). Stop Loss continua desligado por padrão: a proteção é o kill switch por drawdown de equity.
Multissímbolo: `OnTick` só recebe ticks do símbolo do gráfico; use 1 símbolo.

## v2.72 (2026-10-19) — sessão em janelas de horário, sem mexer no sinal
Arquivo: `HFT_RETAIL_v270.mq5` (nome mantido; versão interna **v2.72**, CSV schema `v26` inalterado). Compilada na IC e na FP: **0 erros, 0 avisos**. **Não testada no testador nem em conta.**

| O que | Como |
|---|---|
| Janelas A e B | `InpSessionMode = SESSAO_JANELAS` (padrão). A **04–06** e B **15–18** no relógio do **servidor** (`InpSessionClock`, ou GMT). Cada janela tem `true/false`, hora de início (inclusive) e fim (exclusive; início > fim cruza a meia-noite). |
| Sem entradas no fim | `InpUseNoNewBeforeEnd` / `InpNoNewMinBeforeEnd` (true / 5 min). Motivo no painel e em `decisions.csv`: `sessao: ultimos 5 min da janela, sem entradas novas`. |
| Fechar no fim da janela | `InpUseFlattenAtEnd` (**false** por padrão): fecha a posição a mercado (`exit_reason = SESSION_CLOSE`, evento `SESSION_FLATTEN`). Realiza lucro **ou** perda; deixa de valer a regra "sem fechamento forçado" da v2.71, por isso fica desligada. |
| Modo antigo | `InpSessionMode = SESSAO_BLOCOS_GMT` volta ao Londres/NY/Ásia/rollover em GMT (grupo "Sessão: blocos GMT"). |
| Painel | Seção HORARIO: hora **local** do PC e do servidor, janela atual, tempo restante ou próxima janela, A/B em hora do servidor e local, e se o fim fecha a posição. Faixa ATENCAO se houver posição aberta fora da janela. Largura 480 px e quebra de linha nas faixas de decisão (nada cortado). |
| Log | Evento `SESSAO` no INIT (modo, relógio, janelas, deslocamento da hora local). O EA recusa iniciar com janela inválida (nenhuma ligada, hora fora de 0–23/0–24, início = fim). |

Por que 04–06 e 15–18 (hipótese, **amostra pequena**): 302 trades fechados em 8 dias (IC, todos no TP, +US$ 220,86): 156 deles e US$ 113 entre 04:00 e 05:59, com 8% acima de 10 min; 54 trades e US$ 40 entre 15:00 e 17:59, com mediana de 23 s. No M1 do ouro (proxy com alvo de 70 pts, entrada em cada minuto) essas duas faixas têm o alvo mais rápido e menos posições presas após 2 h. Evitar 22:00–00:59 do servidor (spread 20–40 pt; até 21% sem bater o alvo em 2 h). Só 11 trades da v2.70 e nenhum da v2.71 entram nessa conta; até a v2.64 a tendência estava invertida.

Preset: `presets/HFT_RETAIL_v272_janelas.set` (o `HFT_RETAIL_v271_sem_stop.set` não tem os inputs novos: ao carregá-lo na v2.72 valem as janelas padrão; para o comportamento antigo, `InpSessionMode = 1`).
