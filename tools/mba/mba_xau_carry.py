#!/usr/bin/env python3
"""XAUUSD: o que acontece com as operações SEM ALVO às 23:30 se a posição for mantida depois das 23:30.
Mede em quanto tempo (após 23:30) o alvo foi atingido, ou se nunca foi até o fim dos dados; e a exposição acumulada."""
import sys, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r
sys.stdout.reconfigure(encoding='utf-8')
R = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/Raw_Trading_Ltd/"
OUTD = 'docs/relatorios/mba/xau_horarios/'
COMBOS = [('01:00', 200), ('01:00', 300), ('01:00', 400), ('01:15', 300), ('01:15', 400), ('06:00', 200), ('09:45', 200), ('12:00', 300), ('12:15', 300), ('18:30', 200)]
SP = 20; PT = 0.01
G = r.load_candles(R + 'XAUUSD/LIVE', 'M15').set_index('t').sort_index(); G = G[G.open.notna()]
idx = G.index; hi = G.high.values; lo = G.low.values; cl = G.close.values; op_ = G.open.values; N = len(G)
END = idx[-1]
raw = pd.read_pickle(OUTD + 'raw.pkl')
rows = []; expo = []
for slot, T in COMBOS:
    sel = raw[(raw.slot == slot) & (raw.side == 'C') & (raw['T'] == T)].sort_values('d')
    cnt = np.zeros(N + 1); sumop = np.zeros(N + 1); pos = []
    for date, hit0 in zip(sel.d, sel.hit):
        t0 = pd.Timestamp(date) + pd.Timedelta(hours=int(slot[:2]), minutes=int(slot[3:]))
        i = idx.searchsorted(t0)
        if i >= N or idx[i] != t0: continue
        o = op_[i]; thr = o + (T + SP) * PT
        ok = hi[i:] >= thr
        j = i + int(ok.argmax()) if ok.any() else N        # N = nunca (até o fim dos dados)
        cnt[i] += 1; cnt[min(j, N)] -= 1; sumop[i] += o; sumop[min(j, N)] -= o
        cut = idx.searchsorted(pd.Timestamp(date) + pd.Timedelta(hours=23, minutes=30))   # primeiro candle >= 23:30
        if not hit0:
            e_h = ((idx[j] - idx[cut]).total_seconds() / 3600) if j < N else np.nan
            seg = lo[i:(j + 1 if j < N else N)]
            mae = (seg.min() - o) / PT
            mae_after = (lo[cut:(j + 1 if j < N else N)].min() - o) / PT if cut < (j if j < N else N) else np.nan
            rows.append(dict(slot=slot, alvo=T, data=date, bateu_dps=j < N, horas_apos_2330=e_h, dias_corridos=(idx[j] - idx[i]).total_seconds() / 86400 if j < N else np.nan,
                             quando=str(idx[j]) if j < N else '', mae_ate_alvo=mae, mae_apos_2330=mae_after,
                             flutuante_fim=(cl[-1] - o) / PT - SP if j >= N else np.nan, recente=(END - idx[i]).days))
    c = np.cumsum(cnt[:N]); so = np.cumsum(sumop[:N])
    fl_lo = c * lo - so           # pior flutuante agregado por candle (1 lote por posição, em "pts")
    fl_cl = c * cl - so
    # em pts por posição: dividir por PT
    expo.append(dict(slot=slot, alvo=T, max_abertas=int(c.max()), data_max_abertas=str(idx[int(c.argmax())]),
                     pior_flut_pts=float(fl_lo.min() / PT), data_pior_flut=str(idx[int(fl_lo.argmin())]), abertas_no_pior=int(c[int(fl_lo.argmin())]),
                     abertas_no_fim=int(c[-1]), flut_fim_pts=float(fl_cl[-1] / PT)))
C = pd.DataFrame(rows); E = pd.DataFrame(expo)
C.to_csv(OUTD + 'carry_falhas.csv', index=False); E.to_csv(OUTD + 'carry_exposicao.csv', index=False)
pd.set_option('display.width', 250); pd.set_option('display.max_columns', 30)
# faixas de tempo após 23:30
bins = [(0, 1), (1, 3), (3, 6), (6, 12), (12, 24), (24, 48), (48, 24 * 5), (24 * 5, 24 * 10), (24 * 10, 24 * 30), (24 * 30, 1e9)]
names = ['até 1h', '1–3h', '3–6h', '6–12h', '12–24h', '1–2 dias', '2–5 dias', '5–10 dias', '10–30 dias', '>30 dias']
out = []
for (s, T), x in C.groupby(['slot', 'alvo']):
    row = dict(slot=s, alvo=T, falhas=len(x))
    for (a, b), n in zip(bins, names):
        row[n] = int(((x.horas_apos_2330 > a) & (x.horas_apos_2330 <= b) | ((a == 0) & (x.horas_apos_2330 == 0))).sum())
    row['nunca (até 16/10/26)'] = int((~x.bateu_dps).sum())
    row['nunca e entrada >60d'] = int(((~x.bateu_dps) & (x.recente > 60)).sum())
    out.append(row)
O = pd.DataFrame(out); O.to_csv(OUTD + 'carry_faixas.csv', index=False)
print(O.to_string(index=False))
print()
print(E.round(0).to_string(index=False))
# acumulado
for (s, T), x in C.groupby(['slot', 'alvo']):
    b = x[x.bateu_dps]
    print(s, T, 'falhas', len(x), '| bateu depois', len(b), f'({100*len(b)/len(x):.0f}%)', '| em até 6h:', int((b.horas_apos_2330 <= 6).sum()), '| até 24h:', int((b.horas_apos_2330 <= 24).sum()), '| até 5 dias:', int((b.horas_apos_2330 <= 120).sum()),
          '| mediana horas', round(b.horas_apos_2330.median(), 1), '| MAE até alvo p50/p90/pior', round(b.mae_ate_alvo.median()), round(b.mae_ate_alvo.quantile(.1)), round(b.mae_ate_alvo.min()),
          '| nunca', int((~x.bateu_dps).sum()), 'flutuante fim médio', round(x.flutuante_fim.mean()) if (~x.bateu_dps).any() else '')
