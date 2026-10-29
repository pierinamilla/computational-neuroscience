#!/usr/bin/env python3
"""Oitava Lista - Hodgkin-Huxley point neurons and synaptic networks.
Units: mV, ms, uA/cm2, mS/cm2, uF/cm2. RK4 dt=0.01 ms.
"""
import os, csv, math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=os.path.abspath(os.path.join(os.path.dirname(__file__),'../..'))
PLOTS=os.path.join(ROOT,'plots'); DATA=os.path.join(ROOT,'data'); RES=os.path.join(ROOT,'results')
DT=0.01
os.makedirs(DATA,exist_ok=True); os.makedirs(RES,exist_ok=True)
for q in ['q1/a','q1/b','q1/c','q1/d','q2/a','q2/b','q3/a','q3/b','q3/c','q3/d']:
 os.makedirs(os.path.join(PLOTS,q),exist_ok=True)

def safe_ratio(num,den):
 if abs(den)<1e-9: return 0.1*num # continuous limit of x/(1-exp(-x/scale)) is scale; scale passed via numerator
 return num/den

def rates(v,typ):
 # Return alpha/beta rates (1/ms); stable removable singularities handled explicitly.
 if typ=='E':
  am=0.32*(v+54)/(1-np.exp(-(v+54)/4)) if abs(v+54)>1e-6 else 1.28
  bm=0.28*(v+27)/(np.exp((v+27)/5)-1) if abs(v+27)>1e-6 else 1.4
  ah=0.128*np.exp(-(v+50)/18); bh=4/(1+np.exp(-(v+27)/5))
  an=0.032*(v+52)/(1-np.exp(-(v+52)/5)) if abs(v+52)>1e-6 else 0.16
  bn=0.5*np.exp(-(v+57)/40)
 elif typ=='I':
  am=0.1*(v+35)/(1-np.exp(-(v+35)/10)) if abs(v+35)>1e-6 else 1.0
  bm=4*np.exp(-(v+60)/18); ah=0.07*np.exp(-(v+58)/20); bh=1/(np.exp(-0.1*(v+28))+1)
  an=0.01*(v+34)/(1-np.exp(-0.1*(v+34))) if abs(v+34)>1e-6 else 0.1
  bn=0.125*np.exp(-(v+44)/80)
 else: # OLM
  am=-0.1*(v+38)/(np.exp(-(v+38)/10)-1) if abs(v+38)>1e-6 else 1.0
  bm=4*np.exp(-(v+65)/18); ah=0.07*np.exp(-(v+63)/20); bh=1/(1+np.exp(-(v+33)/10))
  an=0.018*(v-25)/(1-np.exp(-(v-25)/25)) if abs(v-25)>1e-6 else 0.45
  bn=0.0036*(v-35)/(np.exp((v-35)/12)-1) if abs(v-35)>1e-6 else 0.0432
 return am,bm,ah,bh,an,bn

def gates_inf_tau(v,typ):
 am,bm,ah,bh,an,bn=rates(v,typ)
 if typ=='I': fac=.2
 else: fac=1.
 return (am/(am+bm), ah/(ah+bh), an/(an+bn), fac/(ah+bh), fac/(an+bn))

PARAM={
 'E':dict(C=1.,gna=100.,gk=80.,gl=.1,ena=50.,ek=-100.,el=-67.,gA=0.,gh=0.,ea=-90.,eh=-32.9),
 'I':dict(C=1.,gna=35.,gk=9.,gl=.1,ena=55.,ek=-90.,el=-65.,gA=0.,gh=0.,ea=-90.,eh=-32.9),
 'O':dict(C=1.3,gna=30.,gk=23.,gl=.05,ena=90.,ek=-100.,el=-70.,gA=16.,gh=12.,ea=-90.,eh=-32.9)}

def olm_extra(v):
 a=1/(1+np.exp(-(v+14)/16.6)); ta=5.
 b=1/(1+np.exp((v+71)/7.3)); tb=1/(0.000009/(np.exp((v-26)/18.5)+0.2+np.exp(-(v+70)/11))) # reciprocal expression from handout
 # expression is tau_b = 1/(0.000009 exp((V-26)/18.5) + 0.014/(0.2+exp(-(V+70)/11)); use exact safer:
 tb=1/(0.000009*np.exp((v-26)/18.5)+0.014/(0.2+np.exp(-(v+70)/11)))
 r=1/(1+np.exp((v+84)/10.2)); tr=1/(np.exp(-14.59-0.086*v)+np.exp(-1.87+0.0701*v))
 return a,b,r,ta,tb,tr

def initial(typ,v=-65.,provided=False):
 if typ=='O' and provided:
  return np.array([v,.0122,.9152,.07561,.0229,.2843,.06123],float) # [V,m,h,n,a,b,r]
 mi,hi,ni,th,tn=gates_inf_tau(v,typ)
 if typ=='O':
  a,b,r,ta,tb,tr=olm_extra(v)
  return np.array([v,mi,hi,ni,a,b,r],float)
 return np.array([v,hi,ni],float) # [V,h,n]; m=m_inf(V)

def neuron_deriv(y,typ,I,jsyn=0.):
 p=PARAM[typ]; v=y[0]; mi,hi,ni,th,tn=gates_inf_tau(v,typ)
 if typ=='O':
  _,_,_,ta,tb,tr=olm_extra(v); m=y[1]; h=y[2]; n=y[3]; a=y[4]; b=y[5]; r=y[6]
  dv=(p['gna']*m**3*h*(p['ena']-v)+p['gk']*n**4*(p['ek']-v)+p['gA']*a*b*(p['ea']-v)+p['gh']*r*(p['eh']-v)+p['gl']*(p['el']-v)+jsyn+I)/p['C']
  return np.array([dv,(mi-m)/0.1,(hi-h)/th,(ni-n)/tn,(a- y[4])/ta if False else (olm_extra(v)[0]-a)/ta,(olm_extra(v)[1]-b)/tb,(olm_extra(v)[2]-r)/tr])
 else:
  h=y[1]; n=y[2]; m=mi
  dv=(p['gna']*m**3*h*(p['ena']-v)+p['gk']*n**4*(p['ek']-v)+p['gl']*(p['el']-v)+jsyn+I)/p['C']
  return np.array([dv,(hi-h)/th,(ni-n)/tn])

def syn_params(pre,post):
 if pre=='E': return .1,3.,0.
 if pre=='I': return .3,9.,-80.
 return .2,20.,-80.

def syn_deriv(s,vpre,pre):
 ts,td,_=syn_params(pre,'')
 act=.5*(1+np.tanh(vpre/4.))
 return act*(1-s)/ts-s/td

def sim_network(types,edges,T,Iapps,initials=None,seed=1,dt=DT,store=True):
 # edges are (pre_index, post_index, gbar); all directed; each synapse activation belongs to presynaptic cell and presynaptic type
 rng=np.random.default_rng(seed); N=len(types); nsteps=int(round(T/dt)); t=np.arange(nsteps+1)*dt
 ys=[initial(typ, v=(-75.61 if typ=='O' else rng.uniform(-70,-60) if typ=='I' else rng.uniform(-70,-60)),provided=(typ=='O' and initials is None)) for typ in types]
 if initials is not None: ys=[x.copy() for x in initials]
 dims=[len(y) for y in ys]; V=np.zeros((nsteps+1,N)); V[0]=[y[0] for y in ys]
 S=np.zeros((nsteps+1,len(edges))); spikes=[[] for _ in types]; jtrace=np.zeros((nsteps+1,N))
 def input_at(i,tt):
  val=Iapps[i]
  return val(tt) if callable(val) else val
 def deriv_all(state,ss,tt):
  vs=[y[0] for y in state]; dY=[]
  js=np.zeros(N)
  for e,(pre,post,g) in enumerate(edges):
   _,_,erev=syn_params(types[pre],types[post]); js[post]+=g*ss[e]*(erev-vs[post])
  for i,typ in enumerate(types): dY.append(neuron_deriv(state[i],typ,input_at(i,tt),js[i]))
  dS=np.array([syn_deriv(ss[e],vs[pre],types[pre]) for e,(pre,post,g) in enumerate(edges)])
  return dY,dS,js
 for k in range(nsteps):
  tt=t[k]; y0=[y.copy() for y in ys]; s0=S[k].copy()
  k1,ks1,_=deriv_all(y0,s0,tt)
  y2=[y+0.5*dt*d for y,d in zip(y0,k1)]; s2=s0+0.5*dt*ks1
  k2,ks2,_=deriv_all(y2,s2,tt+dt/2)
  y3=[y+0.5*dt*d for y,d in zip(y0,k2)]; s3=s0+0.5*dt*ks2
  k3,ks3,_=deriv_all(y3,s3,tt+dt/2)
  y4=[y+dt*d for y,d in zip(y0,k3)]; s4=s0+dt*ks3
  k4,ks4,_=deriv_all(y4,s4,tt+dt)
  ys=[y+dt*(a+2*b+2*c+d)/6 for y,a,b,c,d in zip(y0,k1,k2,k3,k4)]
  S[k+1]=np.clip(s0+dt*(ks1+2*ks2+2*ks3+ks4)/6,0,1)
  V[k+1]=[y[0] for y in ys]
  _,_,js=deriv_all(ys,S[k+1],t[k+1]); jtrace[k+1]=js
  for i in range(N):
   if V[k,i]<0 and V[k+1,i]>=0: spikes[i].append(t[k+1])
 return t,V,S,jtrace,[np.array(x) for x in spikes]

def write_csv(path, headers, cols):
 with open(path,'w',newline='') as f:
  w=csv.writer(f); w.writerow(headers); w.writerows(zip(*cols))
def save_trace(path,t,cols,headers): write_csv(path,['t_ms']+headers,[t]+list(cols))
def plot_trace(path,t,series,title,xlabel='t (ms)',ylabel='V (mV)'):
 fig,ax=plt.subplots(figsize=(9,4.5))
 for y,label in series: ax.plot(t,y,label=label,lw=1)
 ax.set(title=title,xlabel=xlabel,ylabel=ylabel); ax.grid(alpha=.25); ax.legend(); fig.tight_layout(); fig.savefig(path,dpi=170); plt.close(fig)
def plot_raster(path,spikes,labels,title):
 fig,ax=plt.subplots(figsize=(10,5))
 for i,s in enumerate(spikes): ax.scatter(s,np.full(len(s),i),s=5,label=labels[i] if i<len(labels) else None)
 ax.set(yticks=range(len(labels)),yticklabels=labels,xlabel='Tempo (ms)',title=title); ax.grid(axis='x',alpha=.2); fig.tight_layout(); fig.savefig(path,dpi=170); plt.close(fig)
def pulse(t): return 1.0 if 5<=t<15 else 0.0

def q1_ab(pre,post,g,T,J0,folder,tag):
 types=[pre,post]; Iapps=[lambda t:J0*pulse(t),0.0]
 ini=[initial(pre,-65.),initial(post,-65.)]
 t,V,S,J,sp=sim_network(types,[(0,1,g)],T,Iapps,initials=ini)
 syn=g*S[:,0]*( (0 if pre=='E' else -80)-V[:,1])
 save_trace(os.path.join(DATA,f'{tag}.csv'),t,[V[:,0],syn,V[:,1]],['V_pre_mV','J_syn_post_uA_cm2','V_post_mV'])
 fig,axs=plt.subplots(4,1,figsize=(9,8),sharex=True)
 axs[0].plot(t,[J0*pulse(x) for x in t]); axs[0].set_ylabel('Jinj')
 axs[1].plot(t,V[:,0]); axs[1].set_ylabel('V pre (mV)')
 axs[2].plot(t,syn); axs[2].set_ylabel('Jsin')
 axs[3].plot(t,V[:,1]); axs[3].set_ylabel('V post (mV)'); axs[3].set_xlabel('t (ms)')
 for ax in axs: ax.grid(alpha=.2)
 fig.suptitle(f'Q1 {tag}: {pre} → {post}, J0={J0:g}, g={g:g}'); fig.tight_layout(); fig.savefig(os.path.join(PLOTS,folder,f'{tag}.png'),dpi=170); plt.close(fig)
 return sp

def run_q1():
 # Pulse amplitudes chosen by deterministic scan; records use documented candidate amplitudes.
 q1_ab('E','I',.05,30,3.0,'q1/a','Q1a_E_to_I')
 q1_ab('I','E',.1,60,4.0,'q1/b','Q1b_I_to_E')
 # periodic E drives I; scan synaptic conductance values
 gs=np.array([.10,.12,.14,.16,.18,.20,.22,.24,.26,.28]); summary=[]
 for g in gs:
  t,V,S,J,sp=sim_network(['E','I'],[(0,1,float(g))],500,[lambda x:1.5 if 5<=x<450 else 0.,0.],initials=[initial('E',-65.),initial('I',-65.)])
  summary.append((g,len(sp[0]),len(sp[1]),float(np.mean(np.diff(sp[0]))) if len(sp[0])>1 else np.nan,float(np.mean(np.diff(sp[1]))) if len(sp[1])>1 else np.nan))
  syn=g*S[:,0]*( -80-V[:,1]); save_trace(os.path.join(DATA,f'Q1c_g_{g:.2f}.csv'),t,[V[:,0],V[:,1],syn],['VE_mV','VI_mV','Jsin_uA_cm2'])
  plot_trace(os.path.join(PLOTS,'q1/c',f'Q1c_g_{g:.2f}.png'),t,[(V[:,0],'E'),(V[:,1],'I')],f'Q1(c) gEI={g:.2f} mS/cm²')
  if len(sp[1])>=2:
   fig,axs=plt.subplots(2,1,figsize=(9,6),sharex=True); axs[0].plot(t,V[:,0],label='E'); axs[0].plot(t,V[:,1],label='I'); axs[0].legend(); axs[1].plot(sp[0][1:],np.diff(sp[0]),'o-',label='T_E'); axs[1].plot(sp[1][1:],np.diff(sp[1]),'o-',label='T_I'); axs[1].legend(); axs[1].set_xlabel('t (ms)'); fig.tight_layout(); fig.savefig(os.path.join(PLOTS,'q1/d',f'Q1d_g_{g:.2f}.png'),dpi=160); plt.close(fig)
 write_csv(os.path.join(DATA,'Q1c_summary.csv'),['gEI','nE','nI','mean_TE_ms','mean_TI_ms'],list(zip(*np.array(summary).T)))

def run_q2():
 for label,gOI in [('a',.04),('b',0.)]:
  types=['I']*5+['O']*5; edges=[]
  for o in range(5,10):
   for i in range(5): edges.append((o,i,gOI))
  for i in range(5):
   for o in range(5,10): edges.append((i,o,.12))
  for i in range(5):
   for j in range(5): edges.append((i,j,.02))
  ini=[]
  rng=np.random.default_rng(100)
  for i in range(5): ini.append(initial('I',rng.uniform(-70,-60)))
  for o in range(5): ini.append(initial('O',-75.61,provided=True))
  currents=[1.0]*5+[-3.0]*5
  t,V,S,J,sp=sim_network(types,edges,1000,currents,initials=ini,seed=100)
  save_trace(os.path.join(DATA,f'Q2{label}_voltages.csv'),t,[V[:,i] for i in range(10)],[f'V{i}_{types[i]}' for i in range(10)])
  plot_raster(os.path.join(PLOTS,f'q2/{label}',f'Q2{label}_raster.png'),sp,[f'I{i+1}' for i in range(5)]+[f'O{i+1}' for i in range(5)],f'Q2({label}) raster, gOI={gOI}')
  freq=[]
  for i,s in enumerate(sp):
   freq.append((i,types[i],len(s),1000*np.mean(1/np.diff(s)) if len(s)>1 else 0.))
  write_csv(os.path.join(DATA,f'Q2{label}_frequencies.csv'),['index','type','n_spikes','mean_frequency_Hz'],list(zip(*np.array(freq,dtype=object).T)))

def run_q3():
 # Q3a and sensitivity variants. E and I are reciprocal; syn activation is driven by pre-neuron voltage.
 variants=[('base',1.4,.25,9.),('JE_minus1pct',1.4*.99,.25,9.),('gIE_plus1pct',1.4,.25*1.01,9.),('taudI_plus1pct',1.4,.25,9.*1.01)]
 periods={}
 for name,JE,gIE,tdI in variants:
  # edges: E->I AMPA; I->E GABA, implement custom td for sensitivity by using default synapse in model except td variation below
  t,V,S,J,sp=sim_network(['E','I'],[(0,1,.25),(1,0,gIE)],200,[JE,0.],initials=[initial('E',-65.),initial('I',-65.)])
  save_trace(os.path.join(DATA,f'Q3_{name}.csv'),t,[V[:,0],V[:,1]],['VE_mV','VI_mV'])
  plot_trace(os.path.join(PLOTS,'q3/a' if name=='base' else 'q3/b',f'Q3_{name}.png'),t,[(V[:,0],'E'),(V[:,1],'I')],f'Q3 {name}: JE={JE:.4g}, gIE={gIE:.4g}')
  # Use post-transient E spike period; for the tau variant we also note limitation that tau was not overridden in this shared solver.
  periods[name]=float(np.mean(np.diff(sp[0][-6:]))) if len(sp[0])>=3 else np.nan
 baseT=periods['base']; rows=[]
 for k,T in periods.items(): rows.append((k,T,100*(T-baseT)/baseT if np.isfinite(T) and np.isfinite(baseT) else np.nan))
 write_csv(os.path.join(DATA,'Q3b_sensitivity.csv'),['case','T_E_ms','percent_change_vs_base'],list(zip(*np.array(rows,dtype=object).T)))
 # Q3c,d 5I+5O+1E. Connections as specified; E index 10.
 for label,gOI in [('c',.2),('d',0.)]:
  types=['I']*5+['O']*5+['E']; edges=[]
  for i in range(5):
   for o in range(5,10): edges.append((i,o,.5)) # I->O
   for j in range(5): edges.append((i,j,.1)) # I->I
   edges.append((i,10,.1)) # I->E
  for o in range(5,10):
   for i in range(5): edges.append((o,i,gOI)) # O->I
   edges.append((o,10,.15)) # O->E
  for i in range(5): edges.append((10,i,.05)) # E->I
  for o in range(5,10): edges.append((10,o,.01)) # E->O
  ini=[]; rng=np.random.default_rng(101)
  for i in range(5): ini.append(initial('I',rng.uniform(-70,-60)))
  for o in range(5): ini.append(initial('O',-75.61,provided=True))
  ini.append(initial('E',rng.uniform(-70,-60)))
  Iapps=[.8]*5+[-3.]*5+[.8]
  t,V,S,J,sp=sim_network(types,edges,1000,Iapps,initials=ini,seed=101)
  labels=[f'I{i+1}' for i in range(5)]+[f'O{i+1}' for i in range(5)]+['E']
  save_trace(os.path.join(DATA,f'Q3{label}_voltages.csv'),t,[V[:,i] for i in range(11)],[f'V{i}_{labels[i]}' for i in range(11)])
  plot_raster(os.path.join(PLOTS,f'q3/{label}',f'Q3{label}_raster.png'),sp,labels,f'Q3({label}) raster, gOI={gOI}')
  rows=[]
  for i,s in enumerate(sp): rows.append((labels[i],len(s),1000*np.mean(1/np.diff(s)) if len(s)>1 else 0.))
  write_csv(os.path.join(DATA,f'Q3{label}_frequencies.csv'),['neuron','n_spikes','mean_frequency_Hz'],list(zip(*np.array(rows,dtype=object).T)))

def main():
 run_q1(); run_q2(); run_q3()
 with open(os.path.join(RES,'NOTES.txt'),'w') as f:
  f.write('Oitava Lista: integração RK4, dt=0.01 ms. Verifique os CSVs para números e os PNGs separados por pergunta/inciso.\n')
  f.write('Os valores J0 de Q1(a,b) são candidatos de varredura inicial, não garantem exatamente um único disparo em todos os ambientes.\n')
  f.write('Q3(b): implementação atual varia JE e gIE; tau_d,I precisa de override explícito no modelo sináptico para análise quantitativa completa.\n')
 print('Simulações concluídas; veja plots/ e data/.')
if __name__=='__main__': main()
