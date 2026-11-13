"""Estudo de sinais em ticks REAIS do WINZ26 (14/10-11/11/2026): treino (10 primeiros pregoes) x teste (10 ultimos).
Grade de 1 s. Entrada no toque (compra no ask, venda no bid), saida no horizonte H no toque oposto.
Resultado em PONTOS por operacao (1 ponto = R$0,20 por contrato), ja com o spread real; custo de corretagem fora.
Nada e selecionado olhando o teste: criterios fixados antes (t>=3 no treino, media liquida > 0)."""
import glob, itertools, os, sys
import numpy as np

DT = np.dtype([('t', '<i8'), ('bid', '<i4'), ('ask', '<i4'), ('last', '<i4'), ('vol', '<i4'), ('flags', '<u4'), ('pad', '<i4')])
FLAG_BUY, FLAG_SELL = 32, 64

def load_day(path):
    a = np.fromfile(path, dtype=DT)
    day0 = (a['t'][0] // 86400000) * 86400000
    t = a['t'] - day0
    sec = (t // 1000).astype(np.int64)
    S = 18 * 3600 + 1800
    # so cotacoes validas: bid>0, ask>=bid e spread plausivel (<= 60 pts); o resto e carregado do ultimo tick valido
    valid = (a['bid'] > 0) & (a['ask'] >= a['bid']) & ((a['ask'] - a['bid']) <= 60)
    vidx = np.maximum.accumulate(np.where(valid, np.arange(len(a)), -1))
    idx = np.searchsorted(sec, np.arange(S + 1), side='right') - 1     # ultimo tick ate o fim de cada segundo
    idx = np.where(idx >= 0, vidx[np.clip(idx, 0, None)], -1)
    ok = idx >= 0
    idx = np.clip(idx, 0, None)
    bid = a['bid'][idx].astype(np.float64); ask = a['ask'][idx].astype(np.float64)
    last = a['last'][idx].astype(np.float64)
    bid[~ok] = np.nan; ask[~ok] = np.nan
    n = np.bincount(sec, minlength=S + 1)[:S + 1].astype(np.float64)
    v = a['vol'].astype(np.float64)
    buy = np.bincount(sec, weights=v * ((a['flags'] & FLAG_BUY) != 0), minlength=S + 1)[:S + 1]
    sell = np.bincount(sec, weights=v * ((a['flags'] & FLAG_SELL) != 0), minlength=S + 1)[:S + 1]
    # sessao de pregao 09:10-17:30 (hora do servidor)
    s0, s1 = 9 * 3600 + 600, 17 * 3600 + 1800
    return dict(bid=bid, ask=ask, last=last, n=n, buy=buy, sell=sell, s0=s0, s1=s1, name=os.path.basename(path)[9:17])

def rolling(x, w):
    c = np.concatenate([[0.0], np.cumsum(np.nan_to_num(x))])
    out = np.full(len(x), np.nan); out[w:] = c[w + 1:len(x) + 1] - c[1:len(x) - w + 1]
    return out

def signals(d, fam, N, thr):
    bid, ask = d['bid'], d['ask']; mid = (bid + ask) / 2
    if fam == 'MOM':      # variacao do mid nos ultimos N s
        r = np.full(len(mid), np.nan); r[N:] = mid[N:] - mid[:-N]; return np.where(r >= thr, 1, np.where(r <= -thr, -1, 0))
    if fam == 'FLOW':     # desequilibrio de agressao nos ultimos N s
        b, s = rolling(d['buy'], N), rolling(d['sell'], N); tot = b + s
        imb = np.where(tot > 0, (b - s) / np.where(tot > 0, tot, 1), 0.0); ok = tot >= 20
        return np.where(ok & (imb >= thr), 1, np.where(ok & (imb <= -thr), -1, 0))
    if fam == 'BURST':    # explosao de atividade com direcao do ultimo N s
        act = rolling(d['n'], N); base = np.nanmedian(act[d['s0']:d['s1']])
        r = np.full(len(mid), np.nan); r[N:] = mid[N:] - mid[:-N]
        hot = act >= thr * base
        return np.where(hot & (r > 0), 1, np.where(hot & (r < 0), -1, 0))
    raise ValueError(fam)

def trade(d, sig, H, mode):
    """mode +1 = segue o sinal; -1 = contra. Um trade por vez (cooldown H). Retorna array de resultados liquidos em pontos."""
    bid, ask = d['bid'], d['ask']; out = []; t = d['s0']; s1 = d['s1'] - H - 1
    idx = np.nonzero(sig[:s1] != 0)[0]; idx = idx[idx >= d['s0']]
    nxt = -1
    for i in idx:
        if i < nxt: continue
        direction = int(sig[i]) * mode
        if np.isnan(bid[i + 1]) or np.isnan(bid[i + 1 + H]): continue
        # entra no segundo seguinte ao sinal (1 s de atraso, conservador), sai H s depois
        if direction > 0: out.append(bid[i + 1 + H] - ask[i + 1])
        else: out.append(bid[i + 1] - ask[i + 1 + H])
        nxt = i + 1 + H
    return np.array(out)

def stats(x):
    if len(x) < 30: return len(x), np.nan, np.nan
    return len(x), x.mean(), x.mean() / (x.std(ddof=1) / np.sqrt(len(x)) + 1e-12)

if __name__ == '__main__':
    files = sorted(glob.glob(r'C:\VP_data\VP_ticks_*.bin'))
    days = [load_day(f) for f in files]
    print('dias carregados:', [d['name'] for d in days])
    train, test = days[:10], days[10:]
    spread = np.nanmean([np.nanmean((d['ask'] - d['bid'])[d['s0']:d['s1']]) for d in days])
    print('spread medio na sessao: %.2f pts | 1 ponto = R$0,20 por contrato | R$1 de custo = 5 pts' % spread)
    grid = []
    for N in (1, 2, 5, 10, 30):
        for thr in (10, 20, 40, 80): grid.append(('MOM', N, thr))
        for thr in (0.3, 0.5, 0.7): grid.append(('FLOW', N, thr))
        for thr in (2, 4): grid.append(('BURST', N, thr))
    Hs = (5, 15, 30, 60, 120)
    rows = []; tried = 0
    for fam, N, thr in grid:
        sigs_tr = [signals(d, fam, N, thr) for d in train]; sigs_te = [signals(d, fam, N, thr) for d in test]
        for H in Hs:
            for mode in (1, -1):
                tried += 1
                a = np.concatenate([trade(d, s, H, mode) for d, s in zip(train, sigs_tr)])
                b = np.concatenate([trade(d, s, H, mode) for d, s in zip(test, sigs_te)])
                rows.append((fam, N, thr, H, mode, stats(a), stats(b)))
    print('\ncombinacoes testadas:', tried, '(correcao de multiplicidade: com 5%% de falso positivo esperam-se ~%d "significativas" por acaso)' % int(tried * 0.025))
    print('\nMELHORES NO TREINO (media liquida em pts, t) e o que aconteceu no TESTE:')
    rows.sort(key=lambda r: -(r[5][2] if r[5][2] == r[5][2] else -99))
    print('%-6s %3s %5s %4s %4s | %6s %8s %6s | %6s %8s %6s' % ('fam', 'N', 'thr', 'H', 'modo', 'n_tr', 'pts/op', 't', 'n_te', 'pts/op', 't'))
    for r in rows[:15]:
        fam, N, thr, H, mode, a, b = r
        print('%-6s %3d %5s %4d %4s | %6d %+8.2f %6.1f | %6d %+8.2f %6.1f' % (fam, N, thr, H, 'segue' if mode > 0 else 'contra', a[0], a[1], a[2], b[0], b[1], b[2]))
    best_tr = [r for r in rows if r[5][2] == r[5][2] and r[5][1] > 0 and r[5][2] >= 3]
    print('\ncombinacoes com media>0 e t>=3 no TREINO:', len(best_tr))
    surv = [r for r in best_tr if r[6][1] == r[6][1] and r[6][1] > 0 and r[6][2] >= 2]
    print('  das quais positivas tambem no TESTE (media>0 e t>=2):', len(surv))
    for r in surv[:10]:
        fam, N, thr, H, mode, a, b = r
        print('   ', fam, N, thr, H, 'segue' if mode > 0 else 'contra', 'treino %+.2f (t %.1f, n %d)  teste %+.2f (t %.1f, n %d)' % (a[1], a[2], a[0], b[1], b[2], b[0]))
    allp = [r for r in rows if r[6][1] == r[6][1]]
    print('\nmaior media LIQUIDA no teste entre todas as %d: %+.2f pts (R$ %.2f por contrato)' % (len(allp), max(r[6][1] for r in allp), 0.2 * max(r[6][1] for r in allp)))
