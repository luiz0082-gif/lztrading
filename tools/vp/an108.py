import csv,re,collections,statistics as st
rows=[r for r in csv.reader(open('auditoria/tester_v108_ref_13out-02nov.csv',encoding='latin-1')) if len(r)>=12]
kv=lambda s:dict(re.findall(r'(\w+)=(-?[\d.]+(?:/[\d]+)?)',s))
trades=[];cur=None
for r in rows:
    if r[2]=='ENTRY_CONFIRMED': cur=dict(kv(r[3]),day=r[0][:10],t=r[0],dir=r[4],score=float(r[5]))
    elif r[2]=='EXIT_SENT' and cur is not None:
        m=re.match(r'(\w+) \| pts=(-?[\d.]+) pico=(-?[\d.]+)',r[3]); d=kv(r[3])
        cur.update(reason=m.group(1),pts=float(m.group(2)),pico=float(m.group(3)),mae=float(d.get('mae',0)),tp=float(d.get('t_pico_ms',0)),dur=float(d.get('dur_ms',0))); trades.append(cur); cur=None
print(len(trades),'operacoes pareadas (de 11142)')
sat=[r for r in rows if r[2]=='BUFFER_SATURATION']; print('BUFFER_SATURATION: %d eventos nos dias %s'%(len(sat),sorted(set(r[0][:10] for r in sat)))); print('  ex:',sat[0][3][:150])
BAD={'2026.10.16','2026.10.19','2026.10.20','2026.10.21','2026.10.22'}
def agg(sel):
    T=[t for t in trades if sel(t['day'])]; f=lambda k:st.mean(float(t[k]) for t in T); L=[t for t in T if t['pts']<=0]
    pc=lambda r:100*sum(t['reason']==r for t in T)/len(T)
    return dict(n=len(T),pts=f('pts'),win=100*sum(t['pts']>0 for t in T)/len(T),f_ticks=f('f_ticks'),f_span=f('f_span_ms'),f_net=f('f_net'),spread=f('spread_pts'),score=f('score'),slip=f('slip_pts'),
        mae_loser=st.mean(t['mae'] for t in L),pico=f('pico'),dur_s=f('dur')/1000,t_pico_s=f('tp')/1000,stop=pc('STOP_VIRTUAL'),tp=pc('TP_VIRTUAL'),tl=pc('TEMPO_LUCRO'),tr=pc('TRAILING_PICO'),op=pc('SINAL_OPOSITO_FORTE'),buy=100*sum(t['dir']=='BUY' for t in T)/len(T))
for k,v,nd in (('5 DIAS NEGATIVOS (16,19,20,21,22/10)',lambda d:d in BAD,5),('9 DIAS POSITIVOS',lambda d:d not in BAD,9)):
    a=agg(v); print('\n==',k); print('  ops/dia %.0f | pts/op %+.1f | acerto %.0f%% | pico medio %.1f | MAE medio dos perdedores %.1f | duracao %.0fs | tempo ate o pico %.0fs'%(a['n']/nd,a['pts'],a['win'],a['pico'],a['mae_loser'],a['dur_s'],a['t_pico_s']))
    print('  na entrada: ticks janela rapida %.1f | span %.0f ms | deslocamento %+.1f | spread %.2f | score %.1f | slippage %.2f | %%compra %.0f'%(a['f_ticks'],a['f_span'],a['f_net'],a['spread'],a['score'],a['slip'],a['buy']))
    print('  saidas: stop %.0f%% | TP %.1f%% | tempo-lucro %.0f%% | trailing %.0f%% | sinal oposto %.0f%%'%(a['stop'],a['tp'],a['tl'],a['tr'],a['op']))
print('\nPOR DIA:')
for d in sorted(set(t['day'] for t in trades)):
    a=agg(lambda x:x==d); print('  %s ops %4d pts/op %+6.1f f_ticks %5.1f span %4.0fms spread %.2f stop %2.0f%% trail %2.0f%% oposto %2.0f%% %s'%(d,a['n'],a['pts'],a['f_ticks'],a['f_span'],a['spread'],a['stop'],a['tr'],a['op'],'<-- NEG' if d in BAD else ''))
