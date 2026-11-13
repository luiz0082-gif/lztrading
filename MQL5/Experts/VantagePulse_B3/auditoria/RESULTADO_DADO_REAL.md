# Resultado em dados 100% reais (13/11/2026)

## 1. Custos reais da Clear/B3: NAO FECHADOS (fontes publicas divergem)

- B3 (pagina oficial, futuro mini Ibovespa WIN): tarifa unica por faixa de ADV (R$ 1,07 a 1,97 por contrato-base) com reducao de day trade (35% a 75%) e tarifa de liquidacao de R$ 0,30 por contrato. A pagina nao traz a formula nem a vigencia; o custo final do WIN nao foi confirmado. Estimativas de terceiros: R$ 0,03-0,05 (so emolumentos), ~R$ 0,46-0,50 (B3 total) e ~R$ 1,12 (inferencia sobre a tabela).
- Clear: terceiros citam corretagem de R$ 0,50 a R$ 2,50 por contrato conforme o nivel, e outros "corretagem zero em minis". Nao confirmado em fonte primaria (a pagina da Clear respondeu 403).
- **A fonte confiavel e a nota de corretagem do proprio usuario.** Enquanto isso o resultado e dado como CUSTO DE EQUILIBRIO: 1 ponto do WIN = R$ 0,20 por contrato.
- Fontes: https://www.b3.com.br/pt_br/produtos-e-servicos/tarifas/listados-a-vista-e-derivativos/renda-variavel/tarifas-de-ibovespa-e-indice-brasil-50/futuros-e-estruturadas/ , https://www.genialinvestimentos.com.br/artigos/custo-real-day-trade/ (estimativas de terceiros, nao verificadas).

## 2. Simbolo com 100% dos ticks reais (WINZ26_R)

Script `MQL5/Scripts/VantagePulse_BuildRealSymbol.mq5`: 44.509.484 ticks de 13/10-11/11 (08:30-18:30) copiados do proprio terminal para um simbolo customizado, sem perda (origem = gravados em todos os dias; `VP_real_symbol_build.csv`). O tester passa a usar so esses ticks (nada descartado, nada sintetico).

## 3. v1.08 STOP80/TP240, 1 contrato, WINZ26_R, 14/10-11/11, deposito de pesquisa R$ 50.000 (manifesto conferido: parametros = preset)

**-R$ 24.464, PF 0,83, 0 de 20 dias positivos, 24.627 operacoes, acerto 66%, pior dia -R$ 2.545.** Antes dos custos. Com R$ 700 a conta quebra no primeiro dia (14/10: -R$ 714).

Os 5 dias que o tester do usuario ja tratava como "reais" (16, 19-22/10) dao praticamente o mesmo valor aqui (-556, -1.221, -1.844, -992, -738 contra -557, -1.207, -1.828, -966, -738): o tester do usuario so usava ticks reais nesses 5 dias; nos outros 15 o lucro vinha de ticks sinteticos.

(Um primeiro teste neste simbolo, com 1.060 operacoes, rodou com os parametros PADRAO do EA porque o tester nao achou o .set em `Profiles\Tester`; foi descartado e a rotina passou a conferir o MANIFEST de cada teste.)

## 4. Estudo de sinais em ticks reais (tools/vp/study1-4.py)

Metodo: grade de 1 s, entrada no segundo seguinte ao sinal, saida no horizonte H, custo de spread; treino = 10 primeiros pregoes (14-27/10), teste = 10 ultimos (28/10-11/11); criterio fixado antes: t >= 3 no treino.
- 450 combinacoes (momentum, fluxo de agressao, rajadas de atividade; N, limiar, H, a favor/contra): **nenhuma** com t >= 3 no treino (esperam-se ~11 "significativas" por acaso).
- Unica familia consistente nos dois blocos: operar CONTRA rajadas de atividade (N=10, limiar 4x a mediana, H=30 s): +15 pts/op (t 3,1; 14/20 dias).
- **Fora da amostra (WIN$N, 94 pregoes, 01/06-13/10): -2,57 pts/op, t -2,52, 31/94 dias positivos. Reprovada.** Vizinhos tambem negativos. Controle aleatorio: -5,5 pts (custo do spread). Ressalva: o contínuo WIN$N so traz o preco do negocio (sem bid/ask), entao o sinal de atividade nao e identico ao do WINZ26.

## Conclusao

Em ticks reais, nenhum sinal de momentum, fluxo ou rajada testado tem vantagem comprovada depois do spread, dentro e fora da amostra. O VantagePulse nao tem borda demonstrada; os resultados positivos anteriores vinham de ticks sinteticos do tester. Nao operar em conta real.
