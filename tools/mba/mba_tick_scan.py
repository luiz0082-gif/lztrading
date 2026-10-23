import pandas as pd,numpy as np,sys,math,itertools
sym=sys.argv[1]; MAXSPR=None
d=pd.read_pickle(f'tk_{sym}.pkl'); t=d.time_msc.values; bid=d.bid.values; ask=d.ask.values; mid=(bid+ask)/2; spr=ask-bid; N=len(t); MAXSPR=1.6*float(np.median(spr))
day=t//86400000; days=np.unique(day); nd=len(days); dix=np.searchsorted(days,day)
tr_end,va_end=int(nd*.6),int(nd*.8)
split=np.where(dix<tr_end,0,np.where(dix<va_end,1,2))
sod=(t//1000)%86400
ok_time=~((sod>=23*3600+30*60)|(sod<1*3600+15*60))        # fora da rolagem/pausa
def at(q): return np.searchsorted(t,q,'right')-1
# sinais
sig={}
for W in [250,1000,5000]:
    j=at(t-W); sig[f'mom{W}']=mid-mid[np.maximum(j,0)]
ds=np.sign(np.diff(mid,prepend=mid[0])); cs=np.cumsum(ds); 
for K in [10,30]:
    sig[f'imb{K}']=(cs-np.concatenate([np.zeros(K),cs[:-K]]))/K
sig['rate500']=(np.arange(N)-at(t-500)).astype(float)   # ticks nos ultimos 500ms (atividade)
rows=[]
for name,s in sig.items():
    if name=='rate500': continue
    for q in [0.90,0.97,0.995]:
        thr=np.quantile(np.abs(s[(split==0)&ok_time]),q)
        if thr==0: continue
        fire=(np.abs(s)>=thr)&ok_time&(spr<=MAXSPR)
        idx=np.where(fire)[0]
        # cooldown 2 s
        keep=[];last=-10**12
        for i in idx:
            if t[i]-last>=2000: keep.append(i);last=t[i]
        idx=np.array(keep)
        for mode in ['seguir','fade']:
            dirn=np.sign(s[idx])*(1 if mode=='seguir' else -1)
            for L in [0,100,300,1000]:
                e=at(t[idx]+L)
                for H in [1000,3000,10000,30000]:
                    x=at(t[idx]+L+H); good=(x<N)&(t[x]-(t[idx]+L+H)>-3000)&(spr[e]<=MAXSPR)&(spr[np.minimum(x,N-1)]<=MAXSPR)&(t[e]-t[idx]<=L+3000)
                    ent=np.where(dirn>0,ask[e],bid[e]); ex=np.where(dirn>0,bid[x],ask[x]); net=dirn*(ex-ent); gross=dirn*(mid[x]-mid[e])
                    for sp,nm in [(0,'tr'),(1,'va'),(2,'te')]:
                        m=good&(split[idx]==sp)
                        if m.sum()<30: continue
                        blk=(t[idx][m]//60000); g=pd.Series(net[m]).groupby(blk).mean()
                        rows.append(dict(sig=name,q=q,mode=mode,L=L,H=H,split=nm,n=int(m.sum()),gross=gross[m].mean(),net=net[m].mean(),hit=100*(net[m]>0).mean(),t_blk=g.mean()/(g.std(ddof=1)/math.sqrt(len(g))) if len(g)>5 and g.std()>0 else np.nan,spread=(ask[e]-bid[e])[m].mean()))
R=pd.DataFrame(rows); R.to_pickle(f'tk_scan_{sym}.pkl')
P=R.pivot_table(index=['sig','q','mode','L','H'],columns='split',values=['n','gross','net','t_blk']).reset_index()
P.columns=['_'.join([str(c) for c in col if c!='']) for col in P.columns]
P.to_pickle(f'tk_piv_{sym}.pkl')
pd.set_option('display.width',250,'display.max_columns',40)
print('testes:',len(P),'| mediana spread pago $%.3f'%R.spread.median())
print('\nTOP por net no TREINO, mostrando validação e teste:'); print(P.sort_values('net_tr',ascending=False).head(12).round(3)[['sig','q','mode','L','H','n_tr','gross_tr','net_tr','t_blk_tr','net_va','t_blk_va','net_te','t_blk_te']].to_string(index=False))
pos=P[(P.net_tr>0)&(P.net_va>0)&(P.net_te>0)]; print('\nnet>0 em treino, validação e teste:',len(pos)); print(pos.sort_values('net_te',ascending=False).head(10).round(3)[['sig','q','mode','L','H','n_tr','n_te','gross_tr','net_tr','net_va','net_te','t_blk_te']].to_string(index=False))
print('\nmelhor gross (antes de spread), L=0,H=1000 e 3000:'); print(P[P.L==0].sort_values('gross_tr',ascending=False).head(6).round(3)[['sig','q','mode','H','gross_tr','net_tr','gross_te','net_te']].to_string(index=False))
