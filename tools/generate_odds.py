#!/usr/bin/env python3
"""組み合わせオッズの事前生成（Harville方式）。出力: Packages/KeibaCore/Sources/KeibaCore/Data/OddsTable+Generated.swift
オッズは0.1倍単位の整数（tenths）で保持。0.1倍未満切り捨て、最低1.1倍。"""
import itertools, pathlib
WIN = {1:58,2:124,3:28,4:246,5:101,6:41,7:367,8:89,9:183,10:521}  # 単勝(×10)
TAKE = {"place":0.20,"quinella":0.225,"wide":0.225,"exacta":0.25,"trio":0.25,"trifecta":0.275}
inv = {k:10.0/v for k,v in WIN.items()}; s = sum(inv.values()); p = {k:v/s for k,v in inv.items()}
N = list(WIN)
def ex(i,j): return p[i]*p[j]/(1-p[i])
def tri(i,j,k): return ex(i,j)*p[k]/(1-p[i]-p[j])
def tenths(prob, take): return max(11, int((1-take)/prob*10 + 1e-9))
key = lambda t: "-".join(map(str,t))
T = {"win": {str(k):v for k,v in WIN.items()}}
T["place"] = {str(i): tenths(sum(tri(*t) for t in itertools.permutations(N,3) if i in t), TAKE["place"]) for i in N}
T["quinella"] = {key(c): tenths(ex(*c)+ex(c[1],c[0]), TAKE["quinella"]) for c in itertools.combinations(N,2)}
T["wide"] = {key(c): tenths(sum(tri(*t) for t in itertools.permutations(N,3) if c[0] in t and c[1] in t), TAKE["wide"]) for c in itertools.combinations(N,2)}
T["exacta"] = {key(c): tenths(ex(*c), TAKE["exacta"]) for c in itertools.permutations(N,2)}
T["trio"] = {key(c): tenths(sum(tri(*t) for t in itertools.permutations(c)), TAKE["trio"]) for c in itertools.combinations(N,3)}
T["trifecta"] = {key(c): tenths(tri(*c), TAKE["trifecta"]) for c in itertools.permutations(N,3)}
out = ["// 自動生成ファイル: tools/generate_odds.py で再生成すること。手編集禁止。",
       "// オッズは0.1倍単位の整数（例: 48 = 4.8倍）。", "", "extension OddsTable {",
       "    public static let generated: OddsTable = OddsTable(entries: ["]
for bt in ["win","place","quinella","wide","exacta","trio","trifecta"]:
    out.append(f"        .{bt}: [")
    items = list(T[bt].items())
    for n in range(0, len(items), 6):
        out.append("            " + " ".join(f'"{k}": {v},' for k,v in items[n:n+6]))
    out.append("        ],")
out += ["    ])", "}", ""]
path = pathlib.Path(__file__).resolve().parent.parent / "Packages/KeibaCore/Sources/KeibaCore/Data/OddsTable+Generated.swift"
path.parent.mkdir(parents=True, exist_ok=True); path.write_text("\n".join(out), encoding="utf-8")
print({k:len(v) for k,v in T.items()}, "quinella 3-6:", T["quinella"]["3-6"], "trifecta 3-6-1:", T["trifecta"]["3-6-1"])
