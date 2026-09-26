#!/usr/bin/env python3
"""Generate the v1 fixed odds catalog once; no runtime odds generation."""
from itertools import combinations, permutations
from pathlib import Path
odds={1:58,2:124,3:28,4:246,5:101,6:41,7:367,8:89,9:183,10:521}
rows={}
for name,count,ordered,factor in [('単勝',1,False,1),('複勝',1,False,.30),('馬連',2,False,.54),('ワイド',2,False,.25),('馬単',2,True,1.08),('三連複',3,False,.30),('三連単',3,True,1.30)]:
 for ns in (permutations(odds,count) if ordered else combinations(odds,count)):
  product=1
  for n in ns: product*=odds[n]/10
  value=odds[ns[0]] if name=='単勝' else max(11,round(product*factor*10))
  rows[name+':'+','.join(map(str,ns))]=value
rows.update({'複勝:3':14,'複勝:6':18,'複勝:1':21,'馬連:3,6':62,'ワイド:3,6':29,'ワイド:1,3':34,'ワイド:1,6':41,'馬単:3,6':124,'三連複:1,3,6':198,'三連単:3,6,1':856})
assert len(rows)==1040
body='import Foundation\n\n// Pre-generated, immutable v1 odds. Values are in tenths.\nenum FixedOdds {\n    static let values: [String: Int] = [\n'
body+='\n'.join('        "'+key+'": '+str(value)+',' for key,value in sorted(rows.items()))
body+='\n    ]\n}\n'
Path('Data/FixedOdds.swift').write_text(body)
print('Fixed odds entries:',len(rows))
