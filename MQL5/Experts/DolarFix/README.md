# DolarFix — o dólar em volta do fixing de Londres

> Ressalva, uma vez só: não tenho capital. Isto é o que eu faria se tivesse. Não é recomendação.

## 1. A tese

Todo dia às **16:00 de Londres** é calculado o **fixing WM/Reuters**, a taxa de câmbio de referência do mundo. Fundos de índice, fundos de pensão que fazem hedge cambial de carteiras estrangeiras, custodiantes e gestores com benchmark **precisam** executar câmbio *naquele preço*. Esse volume não escolhe preço nem horário: é obrigatório.

Krohn, Mueller & Whelan (*Journal of Finance*, 2024, "Foreign Exchange Fixings and Returns Around the Clock") documentam um padrão sistemático: **o dólar tende a se valorizar nas horas que antecedem os grandes fixings e a devolver depois**, com efeito mais forte no fim do mês. A explicação é de microestrutura. Os bancos que absorvem o fluxo do fixing têm balanço limitado e cobram um prêmio para carregar esse estoque: o preço se afasta antes e volta depois.

**Operação:**
- **Perna PRÉ:** compra dólar das 14:00 às 15:55 (Londres).
- **Perna PÓS:** vende dólar das 16:05 às 20:00 (Londres).
- Fora da janela do fixing (15:57:30–16:02:30), porque ali o spread abre e quem executa é o banco, não você.
- Nunca passa do rollover das 22:00: **zero swap**.

## 2. Por que opera o *dólar* e não um par

A tese é sobre USD. Se eu operar só EURUSD, aposto no dólar **e** no euro: metade do risco é ruído que não tem nada a ver com a tese. Uma **cesta** (EUR, GBP, AUD, NZD, JPY, CHF, CAD contra USD), com risco igual por par, isola o fator dólar e dilui o ruído específico de cada moeda. É o que um quant faria. Operar um par só é o que o varejo faz.

## 3. Por que isso não foi arbitrado?

1. **O fluxo é obrigatório.** Benchmark é benchmark. O fundo não pode "esperar um preço melhor" sem gerar erro de rastreamento (tracking error).
2. **O prêmio remunera um risco real:** carregar estoque de câmbio por horas, perto do maior pico de volume do dia. Quem cobra esse prêmio (os bancos) tem limite de balanço, principalmente no fim do mês e no fim do trimestre, quando os bancos precisam mostrar balanço enxuto.
3. **É pequeno para os grandes:** poucos bps por dia, com capacidade limitada.
4. **Depois do escândalo de manipulação do fixing (2013–2015),** a janela foi ampliada de 1 para 5 minutos e os bancos ficaram com medo de antecipar o fluxo. Isso *reduziu* a concorrência dos bancos por essa edge.

**Quanto dura:** enquanto houver benchmarks cotados no fixing das 16:00 e bancos com restrição de balanço. É estrutural, mas **o tamanho varia**: mudança de regulação bancária ou migração do volume para algoritmos de execução ao longo do dia reduz o efeito.

## 4. Ativos: o que entra, o que fica de fora e por quê

| Ativo | Status | Motivo |
|---|---|---|
| EURUSD, GBPUSD, AUDUSD, NZDUSD, USDJPY, USDCHF, USDCAD | **Dentro** | Todos têm USD e formam a cesta do dólar. |
| **Minors** (EURGBP, AUDNZD, EURJPY…) | **Fora** | Não têm USD. Não expressam a tese. Colocar na cesta seria diluir sinal com ruído. |
| **XAUUSD** | **Fora por padrão** (`InpIncludeGold`) | O ouro é anti-dólar *em média*, mas tem fluxo próprio, e o leilão LBMA das 15:00 de Londres cai dentro da perna PRÉ. **Não tenho evidência** de que o padrão vale para o ouro. Ligar isso é uma hipótese, não uma edge. Se você quiser testar, compare no backtest com e sem ouro. Se o ouro não *melhorar* o resultado, fica fora. |

Sei que o ouro é o seu ativo favorito. Colocá-lo por padrão para agradar seria exatamente o tipo de mentira que você pediu que eu não contasse.

**Timeframe:** o EA lê barras H1 só para medir volatilidade (ATR). O "timeframe" real é o relógio de Londres. Anexe em **um único gráfico** (ex.: EURUSD, qualquer TF). Ele opera todos os pares pelo timer.

## 5. Regras objetivas

| Item | Regra |
|---|---|
| Entrada PRÉ | 14:00 Londres (janela de 10 min): compra USD em todos os pares da cesta aprovados pelo filtro de spread. |
| Saída PRÉ | 15:55 Londres, por tempo. |
| Entrada PÓS | 16:05 Londres: vende USD na cesta. |
| Saída PÓS | 20:00 Londres, por tempo. |
| Stop | **Catastrófico**, por par: 3 × ATR(H1, 24) × √(horas da perna). Raramente atingido. |
| Take profit / trailing | **Nenhum.** A edge é um *deslocamento médio ao longo da janela*. TP e trailing cortam os dias bons e deixam os ruins inteiros. |
| Filtro | Pula o par se o spread passar de 2 bps. Se sobrarem menos de 3 pares, não opera: sem cesta não é aposta no dólar. |
| Fim de mês | Risco × 1,5 no último dia útil (fluxo de rebalanceamento maior). `InpMonthEndOnly = true` opera só nesses dias. |

## 6. Gestão de risco

- **Risco por perna:** 0,6% do equity **para a cesta inteira**, dividido igualmente entre os pares (paridade de volatilidade: cada par tem stop em ATR próprio e o mesmo risco em dinheiro). Os pares são correlacionados pelo dólar, então trate 0,6% como o risco de *uma* aposta, não de sete.
- **Posições simultâneas:** até 7 (8 com ouro), mas é **uma posição econômica**: long ou short USD. As pernas PRÉ e PÓS nunca se sobrepõem.
- **Drawdown esperado:** 5–10% em regime normal. O kill switch fica em **12%** do pico.
- **Kill switch estatístico:** nas últimas **100 pernas**, t-stat do retorno médio < −1,5 → desliga. Não religa sozinho: apague a variável global `DF_<magic>_killed` (F3) só depois de reavaliar.
- **Exigência de conta:** com 7 pares, 0,6% ÷ 7 ≈ 0,086% de risco por par. Em conta pequena o lote calculado fica abaixo de 0,01 e o par é pulado (o EA **não** arredonda risco para cima). Na prática, precisa de algo **acima de ~US$ 5–10 mil** para a cesta ficar completa. Em conta menor, reduza a cesta para 4 pares (EUR, GBP, JPY, CHF), não aumente o risco.

## 7. Validação honesta: nesta ordem

**Passo 0: o script `FixProfile` (antes de qualquer backtest).**
Rode o script em `Scripts/DolarFix/FixProfile.mq5` só na **metade antiga** dos dados (padrão: 2016–2020). Ele mostra o retorno médio do dólar em cada meia hora do dia de Londres, com t-stat, separando dias normais e fim de mês.
- **O que deve aparecer:** coluna "acumulado" subindo até ~16:00 e caindo depois.
- **Se não aparecer:** pare. A tese não se sustenta nos dados da sua corretora e o EA não deve ser ligado. Isso vale mais do que qualquer backtest.
- **Custo:** compare o tamanho do movimento (em bps) com o spread + comissão que o script imprime. Se o custo de ida e volta passar da metade do movimento médio da janela, não compensa.

**Passo 1: backtest na metade nova (2021–hoje), sem mexer em nada.**
Os parâmetros vêm da literatura e do passo 0 feito na metade antiga. A metade nova é o **fora da amostra** de verdade. "Cada tick baseado em ticks reais", comissão real, `InpKillEnabled = false`.

**O que é FIXO (não otimize):** horários das janelas, direção das pernas, stop, lookback do ATR, cesta.
**O que você pode ajustar no passo 0 (só com a metade antiga):** mover as janelas em ±30 min *se* o perfil da sua corretora mostrar claramente o pico em outro ponto. Nada além disso.

**Testes de sanidade:**
1. **Placebo:** `InpPlaceboInvert = true` → precisa perder aproximadamente edge + custo.
2. **Pernas separadas:** rode só PRÉ e só PÓS. Se só uma funcionar, desligue a outra, e registre que isso *é* uma decisão com o dado na mão (conta como um grau de liberdade gasto).
3. **Por ano:** mais de 70% dos anos positivos. Se 2022 (ciclo de alta do Fed, dólar forte) responder pela maior parte do lucro, você está operando tendência do dólar, não fixing.
4. **Fim de mês vs dias normais:** fim de mês precisa ser igual ou mais forte. Se for mais fraco, a explicação do fluxo de rebalanceamento está errada.

**Amostra mínima:** são ~2 pernas × 250 dias = 500 observações por ano. Mas elas são correlacionadas pelo regime do dólar, então conte **no mínimo 3 anos fora da amostra** antes de acreditar, e mais 6 meses em demo para medir o custo real.

## 8. Honestidade: onde perde e por que pode morrer

- **Custo é o inimigo número 1.** 7 pares × 2 pernas = 14 idas e voltas por dia. Numa conta *standard* com spread de 1–2 pips, **a estratégia não sobrevive**. Ela exige conta **ECN/raw** com comissão baixa. Não tente "compensar" com lote maior.
- **Magnitude incerta.** Cito o estudo de Krohn, Mueller & Whelan de memória, e o tamanho do efeito em bps precisa ser verificado por você com o script. Não confie nos meus números. Confie no FixProfile rodando nos seus dados.
- **Dias de notícia dominam.** Payroll, CPI e FOMC (14:00/19:00 Londres) caem dentro das janelas e geram movimentos 10 vezes maiores que a edge. Em média se cancelam, mas aumentam muito a variância. Não filtrei esses dias de propósito: filtro escolhido depois do backtest é overfitting.
- **Tendência forte do dólar** (2022, por exemplo) favorece a perna PRÉ e destrói a PÓS, ou o contrário. O resultado *combinado* deve ser neutro em relação à tendência. Se não for, é sinal de alerta.
- **Pode morrer por:** (1) execução de benchmarks migrando do fixing para algoritmos ao longo do dia, (2) mudança na metodologia do WM/R, (3) bancos com mais balanço disponível (desregulação), (4) mais gente operando isso. Qualquer um desses encolhe a edge devagar. O kill switch existe para isso.
- **O que eu não fiz:** **não compilei nem backtestei.** Não há MetaTrader neste ambiente. O código segue a API padrão do MQL5 e foi revisado, mas o primeiro passo é F7 no MetaEditor.

## 9. Instalação

1. Copie `MQL5/Include/DolarFix/FixClock.mqh` para `MQL5/Include/DolarFix/` do seu terminal.
2. Copie o EA e o script para `MQL5/Experts/DolarFix/` e `MQL5/Scripts/DolarFix/`. Compile os dois.
3. **Relógio:** a maioria das corretoras usa GMT+2/+3 com o horário de verão dos EUA (padrão do EA). O log de inicialização imprime "16:00 Londres = HH:MM no servidor". **Confira.** Relógio errado = estratégia aleatória.
4. Sufixo: se os pares se chamam `EURUSD.r`, preencha `InpSuffix = ".r"`.
5. Rode o **FixProfile** primeiro. Sem ele, não ligue o EA.

## 10. Toque final

> "Dizem que é impossível quebrar a Wall Street com um EA de varejo."

Correto. Este EA não quebra ninguém. Ele cobra o mesmo pedágio que os bancos cobram para carregar o fluxo do fixing, só que em escala de formiga, onde os bancos não se dão ao trabalho de competir.

Na melhor hipótese, é uma edge pequena, honesta e documentada, que paga se o custo for baixo. Na pior, o script FixProfile vai te mostrar em 10 segundos que ela não existe nos seus dados, e você terá economizado meses de conta real.

É o máximo que eu consigo prometer sem mentir.
