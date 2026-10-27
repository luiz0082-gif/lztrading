# HFTShadow v1.01 — laboratório de ticks em MODO SOMBRA

**Não envia ordens.** Não usa `CTrade`/`OrderSend`; por isso não há setores de Risco/Stop/Profit (stop loss não se aplica). Serve para acumular evidência **fora da amostra** sobre os sinais de fluxo de ticks estudados em `docs/HFT-M1-ESTUDO-2026-10-23.md` (nesse estudo, 0 de 480 combinações ficaram positivas em treino, validação e teste). Se algum dia houver um sinal líquido > 0 aqui, ele só então justifica um EA operacional.

## O que faz
- Ingere ticks por `CopyTicksRange` (cursor em ms, sem perder ticks entre `OnTick`/timer de 50 ms) num buffer circular de 65.536 ticks.
- 5 sinais: momentum de 250 ms / 1 s / 5 s (|Δmid| ≥ limiar) e desequilíbrio de ticks (10 e 30). Limiares = quantil 99,5% do treino do XAUUSD IC (05–15/10/2026), em preço; recalibre para outro símbolo.
- Para cada sinal grava, em **preço por unidade** (US$/oz no ouro), o resultado virtual de **compra** (entra no ask, sai no bid) e de **venda** (entra no bid, sai no ask) para atrasos L = 0/100/300/1000 ms e permanências H = 1/3/10/30 s (32 colunas), mais MFE/MAE de 30 s, spread, taxa de ticks em 500 ms, ping e hora. Seguir/fade se derivam do sinal (`sign`) na análise.
- Resultado válido só se o tick usado tem ≤ 3 s de idade (`valid`).
- Bloqueios: spread > 15 pts, rolagem 23:30–01:15 do servidor.

## Instalação (feito apenas na IC)
`MQL5\Experts\HFTShadow\HFTShadow.mq5/.ex5` no terminal **IC Markets (010E0471…)**. Compilado v1.01: 0 erros, 0 avisos (`compile_v101_IC.log`). **Não executado** em terminal. Anexar a **um** gráfico de XAUUSD (conta demo), qualquer timeframe; deixar ligado nos dias úteis.

## CSV (`MQL5\Files\HFTShadow\`, separador `;`, schema HS1)
`HFTShadow_signals_AAAA-MM.csv` (um sinal por linha), `_heartbeat_` (ticks/s, ping, gaps, pendentes), `_events_` (INIT com parâmetros efetivos, DEINIT, erros).

## Como analisar
Para cada `signal`: `net_follow = ln_* se sign>0 senão sn_*`, `net_fade` = o oposto. Média por (L,H), t por blocos de 1 min, separar por dia (≥ 20 dias úteis) e por hora. Critérios de falsificação em `docs/HFT-M1-ESTUDO-2026-10-23.md` §7. Painel mostra seguir/fade/acerto ao vivo para L=300 ms, H=10 s.

## Limitações
Sem profundidade de mercado; latência real da corretora não medida (só ping do terminal); preço virtual = último tick ≤ t+L (otimista: ordem real pode piorar o preço); sem botão de minimizar no painel.

## Histórico
- **1.01 (2026-10-27):** fila de pendentes 512→4.096 (`InpMaxPending`) — a v1.00 descartou 1.402 sinais em rajadas; evento `DROP` no `_events_`; `imb10` limiar 0,9→1,0 e cooldown próprio de 10 s para desequilíbrio (`InpCooldownImbMs`), pois imb10 era 77% dos sinais (~4.500/dia) e só media o spread. Schema HS1 inalterado (CSVs continuam). Dados da v1.00 (23–27/10) têm sinais perdidos nas rajadas: tratar como amostra parcial.
- 1.00: versão inicial (backup `HFTShadow_v100_backup.mq5`).
