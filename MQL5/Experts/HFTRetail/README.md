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
