#!/usr/bin/env python3
"""XAUUSD: o que aconteceu nos dias em que a compra das 01:00 (alvo 300, ou 23:30) NÃO bateu o alvo."""
import sys, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r
sys.stdout.reconfigure(encoding='utf-8')
R = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/Raw_Trading_Ltd/"
PT = {'XAUUSD': 0.01}
raw = pd.read_pickle('docs/relatorios/mba/xau_horarios/raw.pkl')
SLOT, SIDE, T = '01:00', 'C', 300
sel = raw[(raw.slot == SLOT) & (raw.side == SIDE) & (raw['T'] == T)].set_index('d')
unhit = sel[~sel.hit].index
def load(s):
    d = r.load_candles(R + s + '/LIVE', 'M15').set_index('t').sort_index(); d['d'] = d.index.normalize(); d['hm'] = d.index.strftime('%H:%M'); return d
G = load('XAUUSD'); others = {s: load(s) for s in ['XAGUSD', 'US500', 'USTEC', 'US30', 'DE40', 'XTIUSD']}
news = pd.read_csv(R + 'XAUUSD/LIVE/NEWS/news_part001.csv')
news['t'] = pd.to_datetime(news.event_time_server, format='%Y.%m.%d %H:%M:%S'); news = news[news.importance >= 2]
def day_ret(d, date, a='01:00', b='23:15'):
    x = d[(d.d == date)]
    if x[x.hm == a].empty or x[x.hm == b].empty: return np.nan
    return 100 * (x[x.hm == b].close.iloc[0] / x[x.hm == a].open.iloc[0] - 1)
rows = []
dates = sorted(sel.index)
for date in dates:
    g = G[(G.d == date) & (G.hm >= SLOT) & (G.hm <= '23:15')]
    if g.empty or g.hm.iloc[0] != SLOT: continue
    op = g.open.iloc[0]
    i_low = g.low.values.argmin(); low = g.low.values[i_low]
    hi = g.high.max(); hi_t = g.index[g.high.values.argmax()]
    dr = g.close.diff().fillna(g.close - g.open) / 0.01      # variação por vela de 15 min
    i_big = dr.values.argmin()
    prev = G[G.d < date].tail(96)
    prev_close = G[(G.d < date)].close.iloc[-1]
    # contexto: variação de 1 dia e 5 dias antes da entrada, e alcance (máx - mín) das 00:00 às 01:00
    d1 = 100 * (op / G[(G.d < date) & (G.hm == '23:15')].close.iloc[-1] - 1) if len(G[(G.d < date) & (G.hm == '23:15')]) else np.nan
    c5 = G[(G.d < date) & (G.hm == '23:15')].close
    d5 = 100 * (op / c5.iloc[-5] - 1) if len(c5) >= 5 else np.nan
    # notícias entre a entrada e o ponto mínimo
    t0, t1 = g.index[0], g.index[i_low] + pd.Timedelta(minutes=15)
    nw = news[(news.t >= t0) & (news.t <= t1) & (news.importance == 3)]
    tb = g.index[i_big]
    nb = news[(news.t >= tb - pd.Timedelta(minutes=30)) & (news.t <= tb + pd.Timedelta(minutes=30)) & (news.importance >= 2)]
    rows.append(dict(data=date, dia=date.strftime('%a'), hit=bool(sel.loc[date, 'hit']), res=sel.loc[date, 'res'],
        queda_max=(low - op) / 0.01, hora_min=g.index[i_low].strftime('%H:%M'), alta_max=(hi - op) / 0.01, hora_max=hi_t.strftime('%H:%M'),
        fecha=(g.close.iloc[-1] - op) / 0.01, pior_vela=dr.values[i_big], hora_pior_vela=tb.strftime('%H:%M'),
        d1=d1, d5=d5,
        news_imp3_ate_min='; '.join(f"{r_.t.strftime('%H:%M')} {r_.event_name} (real {r_.actual_value:g} / prev {r_.forecast_value:g})" if pd.notna(r_.actual_value) and pd.notna(r_.forecast_value) else f"{r_.t.strftime('%H:%M')} {r_.event_name}" for r_ in nw.itertuples()),
        news_na_pior_vela='; '.join(f"{r_.t.strftime('%H:%M')} {r_.event_name} [imp {r_.importance}]" for r_ in nb.itertuples()),
        **{f'ret_{s}': day_ret(o, date) for s, o in others.items()}, ret_XAU=day_ret(G, date)))
D = pd.DataFrame(rows); D.to_pickle('docs/relatorios/mba/xau_horarios/why_01_00.pkl'); D.to_csv('docs/relatorios/mba/xau_horarios/dias_sem_alvo_01_00_compra_300.csv', index=False)
U = D[~D.hit]; H = D[D.hit]
print('dias totais', len(D), 'sem alvo', len(U))
print('\nPor dia da semana (sem alvo / total):'); print(pd.concat([U.dia.value_counts(), D.dia.value_counts()], axis=1, keys=['sem_alvo', 'total']).assign(pct=lambda x: 100 * x.sem_alvo / x.total).round(1))
print('\nContexto (média): ', 'sem alvo vs com alvo'); 
for c in ['d1', 'd5', 'queda_max', 'alta_max', 'fecha', 'pior_vela'] + [c for c in D.columns if c.startswith('ret_')]:
    print(f'{c:12s} {U[c].mean():8.2f} {H[c].mean():8.2f}   mediana {U[c].median():8.2f} {H[c].median():8.2f}')
print('\nHora da mínima (sem alvo):'); print(U.hora_min.str[:2].value_counts().sort_index().to_dict())
print('\nHora da pior vela de 15 min (sem alvo):'); print(U.hora_pior_vela.str[:2].value_counts().sort_index().to_dict())
print('\nDias com notícia imp 3 antes da mínima:', (U.news_imp3_ate_min != '').sum(), '/', len(U), '| nos dias COM alvo (mesma janela até 23:15 não aplicável)')
pd.set_option('display.width', 300); pd.set_option('display.max_colwidth', 120)
print(U[['data', 'dia', 'res', 'queda_max', 'hora_min', 'fecha', 'pior_vela', 'hora_pior_vela', 'ret_XAGUSD', 'ret_US500', 'ret_XTIUSD']].round(1).to_string(index=False))
