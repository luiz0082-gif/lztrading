# OuroMomento — impulso + recuo a favor do VWAP (XAUUSD, M1–M30)

## Leitura de preço em 3 perguntas

| Pergunta | Como o EA responde |
|---|---|
| **Quem manda agora?** | O **VWAP** da sessão (ancorado às 07:00 de Londres). É o preço médio que as instituições usam como referência de execução. Preço acima do VWAP = comprador no controle. Abaixo = vendedor. |
| **Tem pegada de dinheiro grande?** | Um **candle de impulso**: corpo de pelo menos 1,2 × ATR, fechando na ponta (nos 25% extremos), a favor de quem manda. |
| **Estou pagando caro?** | O EA **não persegue**. Coloca uma **ordem limitada no meio do corpo do impulso** e espera o recuo por até 5 candles. Se o preço não voltar, cancela. Também não entra se o preço estiver a mais de 2 ATR do VWAP (esticado demais). |

## Por que isso pode ter vantagem (e não é só "padrão de candle")

Ordens institucionais grandes **não são executadas de uma vez**. São fatiadas ao longo de minutos ou horas para não mover o preço. É um dos fatos mais bem documentados da microestrutura de mercado: o sinal do fluxo de ordens tem memória longa (Lillo, Farmer, Bouchaud e outros). O candle de impulso costuma ser a primeira fatia visível. **Se ainda há mais fatias por vir, o fluxo continua na mesma direção.** O recuo é quando os operadores de curto prazo realizam lucro, antes da próxima fatia.

É a sua frase, "o preço é momento", traduzida em regra: seguir o fluxo, sem pagar o pior preço.

## Regras

| Item | Regra |
|---|---|
| Timeframe | M5 por padrão. Aceita M1 a M30 (`InpTF`). |
| Horário | Entradas das 08:00 às 16:00 de Londres (hoje: **04:00–12:00 em Brasília**). Zera tudo às 17:00 de Londres. |
| Entrada | Ordem limitada no meio do corpo do impulso, válida por 5 candles. |
| Stop | Além do extremo do impulso + 0,2 ATR. |
| Alvo | 1,2 R. |
| Saída por tempo | Se em 12 candles o preço não chegou ao alvo nem ao stop, sai. Momentum que não anda não é momentum. |
| Uma por vez | Nunca mais de 1 posição ou ordem aberta. |
| Após um stop | Pausa de 3 candles. Não tenta "se vingar" do mercado. |
| Dia | Máximo de 4 entradas. Meta de US$ 12. **Perda máxima obrigatória** (o EA não liga sem ela). Risco por trade = perda máxima ÷ 2. |

## Qual timeframe usar

- **M5 (recomendado):** o candle de impulso tem tamanho suficiente para o spread do ouro não comer o trade.
- **M1:** os candles são tão pequenos que o spread vira uma fração grande do risco. O filtro de spread vai **bloquear boa parte dos sinais**, e é para bloquear mesmo. Use só com spread muito baixo (conta ECN).
- **M15/M30:** menos sinais e trades mais longos. Stop maior, então lote menor.

## Honestidade

- **"Assertiva" não é sinônimo de lucrativa.** Com alvo de 1,2R, o EA precisa acertar **mais de ~46%** das operações (mais os custos) para empatar. Minha expectativa, sem backtest, é algo entre 48% e 55%. É uma vantagem pequena. Quem promete 80% de acerto em M1 está escondendo stops enormes ou está mentindo.
- **Dias laterais** (preço cruzando o VWAP o tempo todo) geram impulsos falsos. O EA vai tomar stops nesses dias. O limite diário existe para isso.
- **Notícia** (CPI, payroll, FOMC) gera candles gigantes que parecem impulso, mas são ruído. O filtro de 2 ATR de distância do VWAP ajuda, mas não resolve.
- **Não compilei nem testei.** Não há MetaTrader neste ambiente. Primeiro passo: F7.

## Validação

1. Backtest com "Cada tick baseado em ticks reais", de 2020 até hoje, com spread e comissão reais.
2. Rode em **M5, M15 e M30 sem mudar nenhum parâmetro**. Se a vantagem for real, os três devem ter resultado parecido (positivo). Se só um timeframe funcionar, é coincidência.
3. **Não otimize** os parâmetros do setup. Eles são fixos de propósito.
4. Pelo menos 300 trades no backtest antes de confiar em qualquer taxa de acerto.
5. 3 meses em demo.

## Instalação

`FixClock.mqh` em `MQL5/Include/DolarFix/`, o EA em `MQL5/Experts/OuroMomento/`, compile, anexe ao XAUUSD, escolha o timeframe em `InpTF` e **preencha a perda máxima diária**.
