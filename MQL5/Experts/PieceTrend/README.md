# PieceTrend v1.20

Alteracoes sobre a v1.10 (original preservada em `historico/PieceTrend_v1.10_original.mq5`). Motivo: o EA nunca abriu ordem; ver `docs/relatorios/RELATORIO-PIECETREND-2026-10-06.md`.

## Telemetria
- CSVs agora em `MQL5\Files\PieceTrend\`, ANSI sem BOM, **cabecalho sempre escrito** (bug do BOM corrigido). Arquivo com cabecalho diferente e renomeado `.schema_old_<data>`, nunca apagado.
- Colunas `schema_version;ea_version;run_id` em todos os arquivos (schema 2). `event_id` nunca vazio.
- `INIT` + `ENV_CHECK` (permissoes de trading, margem, stops level, GMT offset, versao/build) + `PARAMS` (todos os inputs efetivos).
- `PERMISSION_CHANGE` e `STATE_CHANGE` viram eventos; heartbeat padrao 5 s -> 60 s.
- `BAR_ANALYSIS` sempre traz `reason_code` (DEFENSIVE_LOCK, NO_TREND, TRANSITION, ZONE_TOUCH_NO_REJECTION, NO_ZONE_TOUCH_NO_REJECTION, REJECTION_OUTSIDE_ZONE, SETUP_NOT_ARMED, SETUP_ARMED ...).
- PRICEACTION ganhou OHLC da barra[1], flags `zone_touch/rejection/prior_break/sweep/provisional_pullback`, `no_candidate_reason`, `space_mode`, `space_ref_distance`, `defense_state`.

## Logica (hipoteses, nao validadas em backtest)
1. **Gate de espaco**: `InpSpaceMode=AUTO` usa a distancia do TP monetario como referencia quando `InpStopLossEnable=false` (sem SL real a distancia da invalidacao nao e o risco assumido). `RISK` reproduz a v1.10. Limiares viraram inputs: `InpMinSpaceRatio=0.70`, `InpMaxRiskNorm=2.50` (valores iguais aos da v1.10).
2. **Pullback provisorio** (`InpProvisionalPullback=true`): rejeicao na minima/maxima local de 3 barras, com estrutura (HL/LH) intacta e profundidade >= `InpProvisionalMinDepth` x PA_SCALE, sem esperar o swing ser confirmado.

## Stop loss
Nenhum SL foi adicionado por padrao. `InpEmergencyLossEnable=false` e `InpEmergencyOnServer=false` (opt-in). Sem SL real, a posicao depende do TP/trailing do EA; a invalidacao e apenas filtro de entrada, nao fecha posicao.

## Validacao
Compilado no MetaEditor (IC Markets Global): 0 erros, 0 avisos. Nao executado em backtest nem em conta.

## Painel (v1.20)
- Canvas único e **opaco** (`COLOR_FORMAT_XRGB_NOALPHA`) e fontes em **pontos** (tamanho negativo no `FontSet`): era a causa da falta de nitidez (fontes de 8–10 px sobre camada alpha com grade/gradiente).
- Tamanho 500x750 -> **384x592**. Grade de 8 px, tokens de cor (`HC_*`), cartões com barra de acento, sem decoração.
- Ordem: Estado + **motivo atual** ("por que não opera") > Mercado > Estrutura > Setup > Filtros (9) > Resultado > Botões > Rodapé.
- Todo o texto em português (PAUSAR/RETOMAR, FECHAR TUDO, MAPA, filtros, contexto, defesa, motivos).
- Minimizado continua com botão de restaurar (+); arrastar pelo cabeçalho; botões recriados a cada redesenho/minimização.
- Não verificado visualmente em gráfico real nesta sessão (apenas compilação).
