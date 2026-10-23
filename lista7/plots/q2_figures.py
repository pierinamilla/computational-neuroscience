import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from pathlib import Path
D=Path('datos'); F=Path('figuras'); F.mkdir(exist_ok=True)
P={'tonic':(20,0,30,60,-55,65),'adapting':(20,0,100,5,-55,65),'initial_burst':(5,.5,100,7,-51,65),'bursting':(5,-.5,100,7,-46,65),'irregular':(9.9,-.5,100,7,-46,65),'transient':(10,1,100,10,-60,65),'delayed':(5,-1,100,10,-60,25)}
def read(path):return np.genfromtxt(path,delimiter=',',names=True)
def save(filename):plt.tight_layout();plt.savefig(F/filename,dpi=170);plt.close()
def equilibria(I,a):
 # 0= -G*(V-vr)+G*delta*exp((V-vl)/delta)-a*(V-vr)+I
 v=np.linspace(-100,-30,20001); f=-(2+a)*(v+70)+4*np.exp(np.clip((v+50)/2,-100,30))+I
 roots=[]
 for k in np.where(f[:-1]*f[1:]<0)[0]:
  l,r=v[k:k+2]
  for _ in range(48):
   m=(l+r)/2
   fm=-(2+a)*(m+70)+4*np.exp(np.clip((m+50)/2,-100,30))+I
   if (-(2+a)*(l+70)+4*np.exp(np.clip((l+50)/2,-100,30))+I)*fm<=0:r=m
   else:l=m
  x=(l+r)/2;roots.append(x)
 return roots
def classify(v,a,tm,tau):
 C=2*tm
 jac=np.array([[(-2+2*np.exp(np.clip((v+50)/2,-100,30)))/C,-1/C],[a/tau,-1/tau]])
 eig=np.linalg.eigvals(jac)
 if np.prod(eig).real<0:return 'silla',eig
 if np.max(eig.real)<0:return ('foco estable' if np.any(abs(eig.imag)>1e-7) else 'nodo estable'),eig
 return ('foco inestable' if np.any(abs(eig.imag)>1e-7) else 'nodo inestable'),eig
fig,axes=plt.subplots(4,2,figsize=(13,11),sharex=True)
for ax,(name,(tm,a,tau,b,reset,I)) in zip(axes.flat,P.items()):
 d=read(D/f'Q2a_{name}.csv');ax.plot(d['t'],d['V'],lw=.7);ax.axvspan(100,300,alpha=.07,color='gray');ax.set_title(f'Q2(a) — {name} ({I} pA)');ax.set_ylabel('V (mV)');ax.grid(alpha=.2)
axes.flat[-1].axis('off')
for ax in axes[-1]:ax.set_xlabel('t (ms)')
save('Q2a_padroes_7.png')
name='initial_burst';tm,a,tau,b,reset,I=P[name]
fig,axes=plt.subplots(2,2,figsize=(12,8))
for ax,(case,amp) in zip(axes.flat[:2],[('i_pulse',250),('ii_step',90)]):
 d=read(D/f'Q2b_{case}.csv');ax.plot(d['t'],d['V'],lw=.8);ax.set_title(f'Q2(b)({"i" if case=="i_pulse" else "ii"}) V(t), I={amp} pA');ax.set_xlabel('t (ms)');ax.set_ylabel('V (mV)');ax.grid(alpha=.2)
for ax,(case,amp) in zip(axes.flat[2:],[('i_pulse',250),('ii_step',90)]):
 d=read(D/f'Q2b_{case}.csv');ax.plot(d['t'],d['u'],lw=.8);ax.set_title(f'Q2(b)({"i" if case=="i_pulse" else "ii"}) u(t)');ax.set_xlabel('t (ms)');ax.set_ylabel('u (pA)');ax.grid(alpha=.2)
save('Q2b_i_ii_tempos.png')
with open(D/'Q2_equilibria.txt','w') as out:
 for case,I in [('i_rest',0),('i_pulse',0),('ii_step',90)]:
  d=read(D/f'Q2b_{case}.csv');v=np.linspace(-85,0,1100)
  nv=-2*(v+70)+4*np.exp(np.clip((v+50)/2,-100,30))+I
  nu=a*(v+70)
  fig,ax=plt.subplots(figsize=(9,6))
  ax.plot(v,nv,label='nulclina dV/dt=0');ax.plot(v,nu,label='nulclina du/dt=0')
  # exclude event-to-reset artificial connecting segments, and include reset markers
  mask=(d['spike']==0)&(d['reset']==0)
  x=d['V'].copy();y=d['u'].copy();x[~mask]=np.nan;y[~mask]=np.nan
  # insert NaN before reset, avoiding spurious trajectory connecting peak and reset
  for k in np.where(d['reset']==1)[0]:
   if k+1<len(x):x[k+1]=np.nan;y[k+1]=np.nan
  ax.plot(x,y,lw=.65,alpha=.7,label='trajetória contínua')
  ax.scatter(d['V'][d['reset']==1],d['u'][d['reset']==1],marker='s',s=22,facecolors='none',edgecolors='black',label='reset',zorder=4)
  for root in equilibria(I,a):
   stability,eig=classify(root,a,tm,tau)
   u=a*(root+70)
   ax.scatter([root],[u],marker='o' if 'estable' in stability and 'inestable' not in stability else 'x',s=70,zorder=5)
   ax.annotate(f'{stability}\nV={root:.3f}',(root,u),xytext=(8,10),textcoords='offset points',fontsize=8)
   out.write(f'{case},I={I},V={root:.9f},u={u:.9f},tipo={stability},autovalores={eig}\n')
  ax.set_xlim(-85,5);ax.set_ylim(-45,210);ax.set_xlabel('V (mV)');ax.set_ylabel('u (pA)');ax.set_title(f'Q2(b) {case}: plano de fase, I={I} pA');ax.grid(alpha=.2);ax.legend(fontsize=8,loc='upper left');save(f'Q2b_{case}_fase.png')
with open(D/'Q2_spike_summary.csv','w') as f:
 f.write('pattern,I_pA,n_spikes,first_spike_ms,first_ISI_ms,last_ISI_ms\n')
 for name,params in P.items():
  d=read(D/f'Q2a_{name}.csv');sp=d['t'][d['spike']==1];f.write(f'{name},{params[-1]},{len(sp)},{sp[0] if len(sp) else np.nan},{sp[1]-sp[0] if len(sp)>1 else np.nan},{sp[-1]-sp[-2] if len(sp)>1 else np.nan}\n')
