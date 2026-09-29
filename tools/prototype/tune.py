import sys,math,json
from engine import simulate
from horses import make,P
from multiprocessing import Pool
def wins(args):
    sp,a,b=args; H=make(sp); c=[0]*10
    for sd in range(a,b):
        o,_,_,_=simulate(H,sd); c[o[0]-1]+=1
    return c
def rate(sp,N,off=0):
    c=wins((sp,off+1,off+1+N)); return [x/N for x in c]
import os
sp=json.load(open('sp0.json')) if os.path.exists('sp0.json') else [1.0]*10
for it in range(int(sys.argv[1])):
    N=int(sys.argv[2])
    w=rate(sp,N,off=it*100000)
    err=max(abs(w[i]-P[i]) for i in range(10))
    print(it,round(err,4),[round(x,3) for x in w],flush=True)
    sp=[sp[i]*(1.0+float(sys.argv[3])*max(-1.5,min(1.5,math.log(max(P[i],2e-3)/max(w[i],2e-3))))) for i in range(10)]
    m=sum(sp)/10; sp=[x/m for x in sp]
json.dump(sp,open('sp0.json','w')); print([round(x,5) for x in sp]); print([round(x,3) for x in P])
