import numpy as np, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from pathlib import Path
D=Path('datos');F=Path('figuras');F.mkdir(exist_ok=True)
def read(f):return np.genfromtxt(f,delimiter=',',names=True)
def save(name):plt.tight_layout();plt.savefig(F/name,dpi=160);plt.close()
a=read(D/'Q1a.csv');fig,axs=plt.subplots(3,1,figsize=(11,8),sharex=True)
for ax,k,label in zip(axs,['I','V','u'],['I (pA)','V (mV)','u (pA)']):ax.plot(a['t'],a[k],lw=.65);ax.set_ylabel(label);ax.grid(alpha=.2)
axs[-1].set_xlabel('t (ms)');fig.suptitle('Questão 1(a) — AdEx: estímulo, potencial e adaptação');save('Q1a_AdEx.png')
cur=[];f1=[];fin=[]
for j in range(20):
 d=read(D/f'Q1b_{j}.csv');sp=d['t'][d['spike']==1];cur.append(200+300*j/19)
 f1.append(1000/(sp[1]-sp[0]) if len(sp)>1 else np.nan)
 fin.append(1000/np.mean(np.diff(sp[-min(6,len(sp)):])) if len(sp)>2 else np.nan)
plt.figure(figsize=(8,5));plt.plot(cur,f1,'o-',label='f1');plt.plot(cur,fin,'s-',label='f∞ (últimos 5 ISI)');plt.xlabel('I (pA)');plt.ylabel('f (Hz)');plt.title('Questão 1(b) — curvas f-I');plt.legend();plt.grid(alpha=.3);save('Q1b_fI.png')
np.savetxt(D/'Q1b_frequencies.csv',np.column_stack([cur,f1,fin]),delimiter=',',header='I_pA,f1_Hz,fin_Hz',comments='')
P={2:(150,-75,-45,1.2,.01,5,0,-56,130,50,[300,370,500,550]),3:(50,-60,-40,1.5,.03,1,0,-40,150,25,[200,300,400,500]),4:(25,-50,-30,1,.5,25,.009,-40,0,10,[200,400,470,500,600])}
def fixed(kind,I):
 C,vr,vl,k,a,b,p,*_=P[kind]
 # k(v-vr)(v-vl) - b(v-vr)-p(v-vr)^3 + I = 0
 coeff=[-p, k-p*0, -k*(vr+vl)-b, k*vr*vl+b*vr+I]
 roots=np.roots(coeff if p else coeff[1:]);out=[]
 for r in roots:
  if abs(r.imag)>1e-7:continue
  v=float(r.real);u=b*(v-vr)+p*(v-vr)**3
  jac=np.array([[k*(2*v-vr-vl)/C,-1/C],[a*(b+3*p*(v-vr)**2),-a]])
  eig=np.linalg.eigvals(jac);out.append((v,u,eig))
 return out
for kind in (2,3,4):
 C,vr,vl,k,a,b,p,reset,jump,peak,currents=P[kind]
 fig,axs=plt.subplots(len(currents),1,figsize=(11,2.25*len(currents)),sharex=True)
 for ax,I in zip(axs,currents):
  d=read(D/f'Q3_{kind}_{I}.csv');ax.plot(d['t'],d['V'],lw=.7);ax.set_ylabel(f'{I} pA\nV (mV)');ax.grid(alpha=.2)
 axs[-1].set_xlabel('t (ms)');fig.suptitle(f'Questão 3({"abc"[kind-2]})(ii) — voltagens');save(f'Q3_{"abc"[kind-2]}_ii_voltagens.png')
 cases=[0]+currents
 fig,axs=plt.subplots(1,len(cases),figsize=(4*len(cases),4),sharex=True,sharey=True)
 for ax,I in zip(axs,cases):
  vgrid=np.linspace(vr-20,peak,700);nv=k*(vgrid-vr)*(vgrid-vl)+I;nu=b*(vgrid-vr)+p*(vgrid-vr)**3
  ax.plot(vgrid,nv,label='dV/dt=0');ax.plot(vgrid,nu,label='du/dt=0')
  if I:
   d=read(D/f'Q3_{kind}_{I}.csv');ax.plot(d['V'],d['u'],lw=.65,alpha=.8,label='trajetória');ax.scatter(d['V'][d['reset']==1],d['u'][d['reset']==1],s=8,c='black',label='reset')
  for v,u,e in fixed(kind,I):
   ax.scatter(v,u,s=55,marker='x',c='red');ax.annotate('('+','.join(f'{x.real:.2g}' for x in e)+')',(v,u),fontsize=7)
  ax.set_title(f'I={I} pA');ax.set_xlabel('v (mV)');ax.grid(alpha=.2)
 axs[0].set_ylabel('u (pA)');axs[0].legend(fontsize=7);fig.suptitle(f'Questão 3({"abc"[kind-2]})(i,iii) — nulclinas, equilíbrios, trajetórias');save(f'Q3_{"abc"[kind-2]}_i_iii_fase.png')
 with open(D/f'Q3_{kind}_equilibria.txt','w') as out:
  for I in cases:
   out.write(f'I={I} pA\n')
   for v,u,e in fixed(kind,I):out.write(f' v={v:.6f} u={u:.6f} eig={e}\n')
