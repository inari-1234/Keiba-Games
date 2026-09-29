M=(1<<64)-1
class RNG:
    def __init__(s,seed): s.s=seed&M
    def next(s):
        s.s=(s.s+0x9E3779B97F4A7C15)&M; z=s.s
        z=((z^(z>>30))*0xBF58476D1CE4E5B9)&M
        z=((z^(z>>27))*0x94D049BB133111EB)&M
        return z^(z>>31)
    def d(s): return (s.next()>>11)*(1.0/9007199254740992.0)
# style 0逃げ 1先行 2差し 3追込 ; cond 0↑ 1→ 2↓
STYLE_EARLY=[1.03,1.015,0.99,0.975]
COND=[1.04,1.00,0.96]
PACE_BOOST=[0.02,0.04,0.06]; PACE_FADE=[0.03,0.05,0.08]
def pace_of(H):
    sc=0
    for h in H:
        if h['style']==0: sc=sc+2
        elif h['style']==1: sc=sc+1
    return 2 if sc>=6 else (1 if sc>=3 else 0)
def simulate(H,seed,frames=False):
    r=RNG(seed); n=len(H); pace=pace_of(H)
    rf=[]; amp=[]
    for h in H:
        a=0.04*(1.0-0.5*h['consistency']); amp.append(a)
        u=r.d(); rf.append(1.0+a*0.6*(2.0*u-1.0))
    wob=[]
    for seg in range(16):
        row=[]
        for i in range(n):
            u=r.d(); row.append(amp[i]*0.4*(2.0*u-1.0))
        wob.append(row)
    base=[]
    for i,h in enumerate(H):
        pm=1.0-0.01*abs(h['pacePref']-pace)
        base.append(21.0*h['speed']*COND[h['cond']]*h['distAff']*pm*rf[i])
    D=1600.0; dt=0.25; x=[0.0]*n; ft=[-1.0]*n; t=0.0; fr=[]
    left=n; steps=0
    while left>0 and steps<2000:
        for i,h in enumerate(H):
            p=x[i]/D
            if p>=1.0: p=0.9999
            seg=int(p*16.0)
            se=STYLE_EARLY[h['style']]
            if p<0.55: ph=se
            else:
                q=(p-0.55)/0.45
                ph=se+q*(2.0*(1.0-se))+q*(h['kick']*PACE_BOOST[pace]-(1.0-h['stamina'])*PACE_FADE[pace])
            ramp=0.35+t*h['accel']
            if ramp>1.0: ramp=1.0
            v=base[i]*(1.0+wob[seg][i])*ph*ramp
            if v<1.0: v=1.0
            nx=x[i]+v*dt
            if ft[i]<0.0 and nx>=D:
                ft[i]=t+(D-x[i])/v; left=left-1
            x[i]=nx
        t=t+dt; steps=steps+1
        if frames: fr.append([xi/D for xi in x])
    order=sorted(range(n),key=lambda i:(ft[i],i))
    return [H[i]['no'] for i in order],ft,fr,pace
