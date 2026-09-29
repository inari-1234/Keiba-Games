import json
from engine import simulate
from horses import make
sp=[round(x,4) for x in json.load(open('sp0.json'))]; H=make(sp)
M=(1<<64)-1
for salt in range(1,60000):
    o=simulate(H,(20260927 ^ (salt*0x9E3779B97F4A7C15))&M)[0]
    if o[:5]==[3,6,1,8,5]: print(salt,o); break
json.dump(sp,open('sp_final.json','w')); print(sp)
