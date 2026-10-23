import pandas as pd,numpy as np,glob,sys
def load(path):
    fs=sorted(glob.glob(path+'/raw_ticks_part*.csv')); d=[]
    for f in fs: d.append(pd.read_csv(f,usecols=['time_msc','bid','ask','flags','source'],dtype={'time_msc':'int64','bid':'float64','ask':'float64','flags':'int32','source':'category'}))
    d=pd.concat(d,ignore_index=True); n0=len(d)
    d=d.drop_duplicates(['time_msc','bid','ask']).sort_values('time_msc',kind='stable').reset_index(drop=True)
    return d,n0
if __name__=='__main__':
    R=r'C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer/'
    sym=sys.argv[1]; d,n0=load(R+sym+'/LIVE/RAW_TICKS'); d.to_pickle(f'tk_{sym.split("/")[-1]}.pkl')
    t=d.time_msc.values; day=t//86400000
    print(sym,'linhas',n0,'unicas',len(d),'dup removidas',n0-len(d))
    print('fontes',d.source.value_counts().to_dict())
    dt=np.diff(t); print('gaps >60s:',(dt>60000).sum(),' >10min:',(dt>600000).sum(),' maior gap min:',dt.max()/60000)
    s=(d.ask-d.bid); print('spread mediana',round(s.median(),3),'p90',round(s.quantile(.9),3),'max',s.max())
    print('bid>=ask:',(d.ask<=d.bid).sum(),' ticks/dia:',pd.Series(day).value_counts().sort_index().to_dict())
