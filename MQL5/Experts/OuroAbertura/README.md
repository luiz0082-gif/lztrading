# OuroAbertura — rompimento da faixa de abertura no XAUUSD

## A ideia

Nas aberturas de **Londres** e de **Nova York**, o volume do ouro aumenta de uma vez: bancos europeus, a abertura da COMEX e os dados americanos das 8:30. Esse aumento de volatilidade é **previsível**. A direção não é. A estratégia não tenta adivinhar a direção: marca a faixa dos primeiros 15 minutos e entra **para o lado que romper**, apostando que o fluxo de abertura continua na direção em que saiu.

Base: o rompimento da faixa de abertura (opening range breakout) é estudado há décadas (Toby Crabel; Holmberg, Lönnbark & Lundström, 2013, em futuros de petróleo; Zarattini & Aziz, 2023, em ações). **Não é uma ideia original, nem pretende ser.** Para operações rápidas com poucas entradas por dia, é a estrutura com mais base que conheço. O que torna este EA diferente dos genéricos é o controle de risco, não a entrada.

## Horários

| Sessão | Faixa | Entradas até | Sai tudo | Em Brasília (hoje / a partir do fim de out.) |
|---|---|---|---|---|
| Londres | 08:00–08:15 Londres | 10:30 | 12:00 | faixa **04:00** / 05:00 · saída 08:00 / 09:00 |
| Nova York | 08:30–08:45 NY | 10:30 | 11:30 | faixa **09:30** / 10:30 · saída 12:30 / 13:30 |

A sessão de Londres acontece de madrugada no Brasil. Rode numa **VPS**, não no seu PC.

## Regras

1. Ao fim da faixa, coloca uma **compra stop** acima da máxima e uma **venda stop** abaixo da mínima (com uma folga pequena).
2. **Stop:** do outro lado da faixa. **Alvo:** 1,5 vezes o risco. **Breakeven:** quando o lucro chega a 1 vez o risco, o stop vai para o preço de entrada.
3. **Ganhou ou saiu no zero:** a sessão acaba e a outra ordem é cancelada.
4. **Perdeu:** a ordem do lado oposto continua valendo, porque um rompimento falso costuma virar movimento na direção contrária. No máximo 2 trades por sessão.
5. **Filtro:** se a faixa for pequena demais (ruído) ou grande demais (o movimento já aconteceu), a sessão é pulada.
6. **Limites diários:** no máximo **3 entradas**. **Bateu a meta: fecha tudo e para. Bateu a perda máxima: fecha tudo e para.**

## Meta e perda diária

- `InpDailyTarget` = **12** (US$). Você pediu 10–15.
- `InpDailyMaxLoss` = **0**, e com zero **o EA não liga**. Você disse que define depois, então este campo fica obrigatório até lá.
- **Risco por trade = perda diária ÷ 2.** Dois stops cheios encerram o dia. Nunca passa de 1% da conta por trade.

**Sugestão para a conta de US$ 10.000:** perda diária de **US$ 20–30**. Com isso:
- risco por trade de US$ 10–15, que dá 0,01 a 0,02 lote no ouro;
- cada trade vencedor rende ~US$ 15–22 (1,5 vez o risco);
- **1 trade vencedor já bate a meta**, na maioria dos dias.

## Honestidade obrigatória

- **Você não vai bater a meta todo dia.** Numa estratégia de rompimento com alvo de 1,5R, o normal é acertar 40–50% das operações. Espere algo como **4 em cada 10 dias com meta**, alguns dias no zero (sem sinal ou no breakeven) e **3 a 4 dias por semana, ou mais, com perda**. O que importa é o resultado do **mês**, não o do dia.
- **A meta não cria vantagem.** Ela só corta o dia. Parar na meta **reduz** um pouco o ganho esperado (você deixa de pegar os dias grandes), em troca de disciplina. Aceito essa troca para você, porque sei que sem ela a tentação é continuar operando.
- **Rompimento falso é o inimigo.** Em dias sem direção, o ouro rompe um lado, volta, rompe o outro e volta de novo. É por isso que o limite é de 2 trades por sessão: esse dia custa no máximo a perda diária, e não mais.
- **Notícia forte** (payroll, CPI, FOMC) pode abrir gap e passar do stop. A perda real pode ultrapassar o limite diário por algum slippage.
- **É um padrão conhecido e disputado.** A vantagem é pequena e o spread do ouro pesa. Com spread acima de ~30 centavos, o resultado piora muito.
- **Não compilei nem testei.** Não há MetaTrader neste ambiente. Primeiro passo: F7.

## Validação antes de ligar em conta real

1. Backtest com **"Cada tick baseado em ticks reais"**, de 2019 até hoje, com o spread e a comissão da sua corretora.
2. **Não otimize** alvo, breakeven e filtros. Se o resultado só ficar bom depois de mexer neles, a vantagem não existe.
3. **Olhe o resultado mensal**, não o diário. Mais de 60% dos meses positivos já é bom.
4. Teste cada sessão separada (`InpLonOn` / `InpNYOn`). Se uma perder de forma consistente, desligue-a.
5. **3 meses em demo** antes de colocar dinheiro real.

## Contas

| Conta | Funciona? |
|---|---|
| US$ 10.000 | Sim, com perda diária de US$ 20–30. |
| US$ 623 | O EA limita a perda diária a 5% da conta (~US$ 31). Com isso, o risco por trade fica em ~US$ 6 e 0,01 lote muitas vezes arrisca mais que isso: vários dias sem operar. Uma meta de US$ 10–15 aqui seria ~2% ao dia, o que é irreal. |
| US$ 125 | Não opera. O EA recusa, e está certo. |

## Instalação

1. `FixClock.mqh` em `MQL5/Include/DolarFix/` (o mesmo relógio do DolarFix).
2. `OuroAbertura.mq5` em `MQL5/Experts/OuroAbertura/`. Compile.
3. Anexe ao gráfico do **XAUUSD** (qualquer timeframe).
4. Preencha a **perda máxima diária**. Confira no log os horários de Londres e NY impressos na inicialização.
