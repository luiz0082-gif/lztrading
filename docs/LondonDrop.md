# LondonDrop — documento da estratégia (hipótese em teste)

EA: `MQL5/Experts/LondonDrop/LondonDrop.mq5` · Versão 1.02 · **EA de demonstração/teste. Nenhuma lucratividade está provada.**
Origem: `docs/relatorios/RELATORIO-MBA-ANALISE-COMPLETA-2026-10-13.md` e a varredura de horários de 2026-10-13.

## 1. Tese e mecanismo esperado

**Tese.** O ouro (XAUUSD) tende a cair no candle M5 das 10:25 de Londres e arredores (09:50–10:25), em dias úteis.

**Mecanismo esperado (hipótese, não testada).** Possível relação com o leilão de ouro das 10:30 de Londres. Não há evidência causal; o horário acompanha o relógio de Londres (muda 1 h em UTC com o horário de verão do Reino Unido).

## 2. O que foi observado (fatos medidos)

- Candle M5 de 10:25 de Londres: média −123 pts, 70% dos 367 dias negativos, t = −8,8, FWER p = 0,001 (IC e FP). Por ano (M15 de 10:15): 2024 −24, 2025 −57, 2026 −237 pts.
- Venda às 10:20/10:25 de Londres, meta 350 pts, saída em 60 min (IC, 367 dias, spread real por horário + 2 pts de slippage): média líquida +147 a +158 pts/dia, pior dia −2.004 a −2.128, drawdown −2.537 a −2.872.
- Segurar até 23:30 sem proteção: pior dia −16.264 pts. Com trailing ativando em 150 pts: −6.105 (10:25) / −3.194 (10:20), média +135 a +166 (versão otimista) e +128 a +143 (conservadora).
- Metas ≥ 500 pts (incluindo 1.500 pts = US$ 15 em 0,01 lote) **não têm suporte**: nenhum horário valida e a média líquida é ≤ 0.
- Comprar, outros horários e outros padrões: reprovados na varredura.

## 3. Regra operacional (padrões do EA)

| Item | Valor padrão | Onde configurar |
|---|---|---|
| Direção | VENDA | 03 |
| Entrada | 10:20 no relógio de Londres (12:20 do servidor; Brasília = servidor − 6 h, −7 h depois de 01/11), janela de 120 s | 03 |
| Operações por dia | 1 | 11 |
| Lote | 0,01 (fixo) ou calculado pela meta (opcional) | 07 |
| Alvo | US$ 5,00 por operação (500 pts em 0,01 lote), enviado ao servidor | 09 |
| Meta diária | US$ 5,00 (para de operar no dia) | 09 |
| Trailing | **desligado por padrão** (opcional). Estilo PieceTrend: ativa em 150 pts, distância D = 0,60·A·(máx/A)^0,82, vira SL no servidor; o TP é retirado ao ativar (por isso fechava ganhos em centavos) | 10 |
| Stop loss | **desativado** (existe e é opcional) | 08 |
| Saída por tempo | 23:30 do servidor (obrigatória, ligada); saída por tempo máximo de posição opcional | 09 |

Ligação entre setores feita no código: a meta em dinheiro (09) vira pontos pelo lote (07); o modo de lote `BY_TARGET` usa a meta do setor 09.

## 4. Invalidação e bloqueios

O EA **não entra** (e registra o motivo no CSV) quando: spread > 25 pts, tick velho (> 15 s), notícia USD de alta importância a ±10 min da entrada, dia da semana/data bloqueada, meta diária atingida, perda diária ou semanal acima do limite, circuit breaker ativo, pausa manual ou kill switch, margem insuficiente, janela de entrada perdida, negociação desabilitada.

## 5. Custos assumidos nos testes

Barras de bid; spread mediano por horário dos últimos 120 dias (≈ 8–10 pts) + 2 pts de slippage; sem comissão e sem swap (o fechamento antes de 00:00 do servidor evita o swap). **O spread real em horário de notícia pode ser maior.**

## 6. Riscos

**Operar sem stop loss.** A perda não é limitada por ordem de stop. O risco vem de dias de tendência contra a venda.
- Pior dia observado na janela de 60 min: −2.128 pts. Segurando até 23:30 sem proteção: −16.337 pts (US$ 163 em 0,01 lote).
- Perda flutuante máxima observada (entrada 10:25, saída 60 min): 2.379 pts. Entrada 09:50, saída 240 min: 5.468 pts.
- O stop de desastre no servidor (setor 08) e a saída de emergência por perda (setor 07) são opcionais e estão desligados.
- O trailing depende de o preço **atingir a ativação**; dias que andam contra desde a abertura não são protegidos por ele.
- O programa depende de terminal e conexão ativos; se o terminal cair, só o TP e o trailing já enviados ao servidor continuam valendo. A saída das 23:30 e o trailing virtual param.
- Gap de fim de semana e swap não são cobertos pela saída das 23:30 se o EA estiver parado.

## 7. Hipóteses não verificadas

- Que o efeito continue depois de 25/10/2026 (mudança de horário do Reino Unido), em outros regimes de volatilidade e fora de 2025–2026.
- Que a execução real (spread, slippage, requotes) bata com os custos assumidos.
- Que o trailing se comporte em tempo real como na simulação (a simulação usa barras M5/M1; a ordem dos preços dentro da barra é desconhecida).
- Que o efeito tenha causa em fluxo ligado ao leilão do ouro.

## 8. Critérios de falsificação (teste em demo, a partir da entrada em operação)

Avaliar após 40 sessões úteis (ou 8 semanas), sem mudar a regra no meio:
- **Rejeitar** se a média líquida por operação for ≤ +30 pts (≈ US$ 0,30 em 0,01 lote) ou se menos de 52% dos dias forem positivos, ou se o pior dia superar −4.000 pts.
- **Rejeitar** se, depois de 25/10, o ganho médio no candle das 10:25 de Londres ficar acima de −30 pts (efeito sumiu) ou se o padrão aparecer no horário de UTC fixo (não acompanha Londres).
- **Aprovar para lote real pequeno** somente se a média ≥ +100 pts, ≥ 60% de dias positivos e drawdown ≤ −3.500 pts.

## 9. Telemetria

CSV em `MQL5\Files\LondonDrop\` (separador `;`, ANSI): `LondonDrop_events_AAAA-MM.csv`, `_trades_`, `_daily_`, `_decisions_`. Schema `LD1`. Os motivos de bloqueio estão em `reason_code` (por exemplo `SPREAD_HIGH`, `NEWS_NEAR`, `DAILY_TARGET_REACHED`).

## 10. Versão

**1.02 (2026-10-13):** padrões alterados após a operação de 13/10/2026 (fechou com US$ 0,63 pelo trailing e o ouro caiu mais ~3.700 pts depois): trailing **desligado**, saída de emergência por perda flutuante **ligada em US$ 15** (1.500 pts em 0,01 lote). Preset `LondonDrop_BOM_TP5_emerg15.set`. Em 367 dias (M5, entrada 12:20 do servidor, TP 500 pts, saída 23:30): média +192 pts/dia, 84% dos dias positivos, pior dia −1.500 pts (emergência), drawdown −6.000 pts, TP batido em 309 dias, emergência acionada em 56. No M1 de 2026 (145 dias): média +197. Sem emergência: média +195, 93% positivos, mas pior dia −16.337 pts.

**1.01 (2026-10-13):** corrige bug do horário de entrada. A janela era comparada no relógio de Londres, mas o dia do servidor vira às 00:00 (Londres ainda em 22h/23h do dia anterior); por isso, depois do primeiro dia, todo dia era marcado `SKIP:MISSED_WINDOW` na virada do dia e nenhuma operação era feita (visto no Strategy Tester: 0 operações). Agora o horário de entrada é convertido para hora do servidor (com o deslocamento do relógio escolhido) e comparado no relógio do servidor.


1.00: primeira versão. Compilada sem erros nem avisos. **Não foi executada em terminal nem em Strategy Tester.**
