#!/usr/bin/env python3
"""XAUUSD: catálogo dos dias SEM ALVO dos 10 horários estáveis (compra, alvo ou 23:30).
Para cada dia: cenário, drawdown, quase-acerto, notícia, prata; mais sequência/agrupamento e checkpoints."""
import sys, numpy as np, pandas as pd
sys.path.insert(0, 'tools/mba'); import mba_report as r
sys.stdout.reconfigure(encoding='utf-8')
R = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/Raw_Trading_Ltd/"
OUTD = 'docs/relatorios/mba/xau_horarios/'
COMBOS = [('01:00', 200), ('01:00', 300), ('01:00', 400), ('01:15', 300), ('01:15', 400), ('06:00', 200), ('09:45', 200), ('12:00', 300), ('12:15', 300), ('18:30', 200)]
SP = 20
raw = pd.read_pickle(OUTD + 'raw.pkl')


def load(s):
    d = r.load_candles(R + s + '/LIVE', 'M15').set_index('t').sort_index(); d['d'] = d.index.normalize(); d['hm'] = d.index.strftime('%H:%M'); return d


G = load('XAUUSD'); AG = load('XAGUSD')
news = pd.read_csv(R + 'XAUUSD/LIVE/NEWS/news_part001.csv')
news['t'] = pd.to_datetime(news.event_time_server, format='%Y.%m.%d %H:%M:%S'); news = news[news.importance >= 2]
byday = {d: g for d, g in G[G.hm <= '23:15'].groupby('d')}
agday = {d: g for d, g in AG[AG.hm <= '23:15'].groupby('d')}


def classify(mfe, T, dd2h, wc, has_news):
    """Cenário principal (ordem de prioridade)."""
    if dd2h <= -1000: return 'A. Caiu logo após a entrada (-1000 em 2h)'
    if wc <= -800 and has_news: return 'B. Choque em uma vela com notícia dos EUA'
    if wc <= -800: return 'C. Choque em uma vela sem notícia no calendário'
    return 'D. Queda gradual (sem vela forte)'


rows = []
for slot, T in COMBOS:
    sel = raw[(raw.slot == slot) & (raw.side == 'C') & (raw['T'] == T)].sort_values('d')
    for k, (date, hit, res) in enumerate(zip(sel.d, sel.hit, sel.res)):
        g = byday[date]; g = g[g.hm >= slot]
        op = g.open.iloc[0]
        mfe = (g.high.max() - op) / 0.01; mae = (g.low.min() - op) / 0.01
        i_low = int(g.low.values.argmin()); t_low = g.index[i_low]
        e0 = g.index[0]
        dd2h = (g[g.index < e0 + pd.Timedelta(hours=2)].low.min() - op) / 0.01
        cd = (g.close - g.open) / 0.01; i_w = int(cd.values.argmin()); wc = cd.values[i_w]; t_w = g.index[i_w]
        nb = news[(news.t >= t_w - pd.Timedelta(minutes=30)) & (news.t <= t_w + pd.Timedelta(minutes=30))]
        nb3 = nb[nb.importance == 3]
        ag = agday.get(date); ag = ag[ag.hm >= slot] if ag is not None else None
        ag_ret = 100 * (ag.close.iloc[-1] / ag.open.iloc[0] - 1) if ag is not None and len(ag) > 5 else np.nan
        # checkpoint 15:00 (só se a entrada for antes das 14:30) e +3h
        def pos_at(t):
            x = g[g.index <= t]
            return (x.close.iloc[-1] - op) / 0.01 - SP if len(x) else np.nan
        reached_by = lambda t: ((g[g.index < t].high.max() - op) / 0.01 >= T + SP) if len(g[g.index < t]) else False
        c15 = pd.Timestamp(date) + pd.Timedelta(hours=14, minutes=45) if slot < '14:30' else pd.NaT
        c3 = e0 + pd.Timedelta(hours=3)
        rows.append(dict(slot=slot, alvo=T, data=date, dia=date.strftime('%a'), hit=bool(hit), res=res, quase=bool(mfe >= 2 * T / 3), mfe=mfe, mae=mae, hora_min=t_low.strftime('%H:%M'),
                         h_ate_min=(t_low - e0).total_seconds() / 3600, dd2h=dd2h, pior_vela=wc, hora_pior_vela=t_w.strftime('%H:%M'),
                         news3='; '.join(nb3.event_name.str[:40]), news2n=len(nb), prata=ag_ret,
                         pos15=pos_at(c15) if pd.notna(c15) and not reached_by(c15 + pd.Timedelta(minutes=15)) else np.nan,
                         pos3h=pos_at(c3) if not reached_by(c3 + pd.Timedelta(minutes=15)) else np.nan,
                         bateu_antes15=reached_by(c15 + pd.Timedelta(minutes=15)) if pd.notna(c15) else np.nan,
                         cen=classify(mfe, T, dd2h, wc, len(nb3) > 0 or len(nb) > 0 and wc <= -800 and len(nb3) > 0)))
    print(slot, T, 'ok')
D = pd.DataFrame(rows); D.to_pickle(OUTD + 'falhas_todos.pkl')
F = D[~D.hit].copy(); F.drop(columns=['hit']).to_csv(OUTD + 'falhas_dias_sem_alvo_10_horarios.csv', index=False)

# sequência / agrupamento
seq = []
for (slot, T), x in D.groupby(['slot', 'alvo']):
    x = x.sort_values('data'); f = (~x.hit).values
    pf_prev = f[1:][f[:-1]].mean() if f[:-1].sum() else np.nan
    runs, c = [], 0
    for v in f:
        if v: c += 1
        else:
            if c: runs.append(c)
            c = 0
    if c: runs.append(c)
    # janelas de 10 dias úteis com >=2 falhas
    w2 = int(sum(1 for i in range(len(f) - 9) if f[i:i + 10].sum() >= 2))
    gaps = np.diff(np.where(f)[0])
    seq.append(dict(slot=slot, alvo=T, falhas=int(f.sum()), dias=len(f), uma_a_cada=len(f) / max(f.sum(), 1), p_falha_dia_seguinte=100 * pf_prev, p_base=100 * f.mean(),
                    max_seguidas=max(runs) if runs else 0, n_pares_consecutivos=int(sum(1 for r_ in runs if r_ >= 2)),
                    janelas10_com2=w2, intervalo_mediano=float(np.median(gaps)) if len(gaps) else np.nan, intervalo_min=int(gaps.min()) if len(gaps) else 0,
                    perda_media=x[~x.hit].res.mean(), pior=x.res.min(), reposicao=abs(x[~x.hit].res.mean()) / T))
S = pd.DataFrame(seq); S.to_csv(OUTD + 'falhas_sequencia.csv', index=False)
pd.set_option('display.width', 250)
print(S.round(1).to_string(index=False))
pd.set_option('display.max_columns',20)
print(F.groupby(['slot', 'alvo', 'cen']).size().unstack(fill_value=0).to_string())
print(F.groupby(['slot','alvo']).quase.sum().to_string())
