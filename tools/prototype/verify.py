import json
from engine import simulate
from horses import make,P
M=(1<<64)-1; SALT=int(open("salt").read())
H=make(json.load(open('sp_final.json')))
def rs(seed): return (seed ^ ((SALT*0x9E3779B97F4A7C15)&M))&M
c=[0]*10; tmin=1e9;tmax=0;lastmax=0
for sd in range(1,10001):
    o,ft,_,_=simulate(H,rs(sd)); c[o[0]-1]+=1
    tmin=min(tmin,min(ft)); lastmax=max(lastmax,max(ft))
w=[x/10000 for x in c]
bad=[(i+1,round(w[i],3),round(P[i],3)) for i in range(10) if abs(w[i]-P[i])>max(0.015,0.2*P[i])]
print('win',[round(x,3) for x in w]); print('P  ',[round(x,3) for x in P]); print('bad',bad)
print('fastest winner',round(tmin,2),'slowest last',round(lastmax,2))
o,ft,fr,pace=simulate(H,rs(20260927),True)
print(o,pace,[round(f,2) for f in ft])
# leader changes / rank changes
import itertools
def ranks(f): s=sorted(range(10),key=lambda i:-f[i]); return [s.index(i) for i in range(10)]
chg=sum(1 for a,b in zip(fr,fr[1:]) if ranks(a)!=ranks(b)); print('rank-change frames',chg,len(fr))
for k in [20,100,160,220,270]:
    f=fr[k]; print(k*0.25,[i+1 for i in sorted(range(10),key=lambda i:-f[i])])
