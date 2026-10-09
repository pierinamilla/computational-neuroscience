#!/usr/bin/env python3
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
D=Path('data')
P=Path('plots'); P.mkdir(parents=True, exist_ok=True)
def dat(name): return np.loadtxt(D/name)
def save(name,xlabel,ylabel,series,phase=False):
    fig,ax=plt.subplots(figsize=(8.5,5.4))
    for file,col,label in series:
        a=dat(file); ax.plot(a[:,col[0]],a[:,col[1]],label=label,lw=1.2)
    ax.set_xlabel(xlabel); ax.set_ylabel(ylabel); ax.grid(True,alpha=.3); ax.legend(); fig.tight_layout(); fig.savefig(P/name,dpi=150); plt.close(fig)
# FHN time plots
save('fhn_v_time.png','t','v',[(f'fhn_v_{s}.dat',(0,1),lab) for s,lab in [('m080','v(0)=-0.8'),('m065','v(0)=-0.65'),('m064','v(0)=-0.64'),('0','v(0)=0')]])
save('fhn_w_time.png','t','w',[(f'fhn_v_{s}.dat',(0,2),lab) for s,lab in [('m080','v(0)=-0.8'),('m065','v(0)=-0.65'),('m064','v(0)=-0.64'),('0','v(0)=0')]])
for idx,tag in [(0,'I0'),(1,'I1'),(2,'I15')]:
    a=dat(f'fhn_null_{idx}.dat')
    fig,ax=plt.subplots(figsize=(7,5.5)); ax.plot(a[:,0],a[:,1],label='nulclina de v'); ax.plot(a[:,0],a[:,2],label='nulclina de w')
    files=[]
    if idx==0: files=[('fhn_v_m080.dat','v(0)=-0.8'),('fhn_v_m065.dat','v(0)=-0.65'),('fhn_v_m064.dat','v(0)=-0.64'),('fhn_v_0.dat','v(0)=0')]
    elif idx==1: files=[('fhn_I1.dat','I=1')]
    else: files=[('fhn_I15.dat','I=1.5')]
    for f,l in files:
        z=dat(f); ax.plot(z[:,1],z[:,2],label=l,lw=1)
    ax.set_xlabel('v'); ax.set_ylabel('w'); ax.grid(True,alpha=.3); ax.legend(); fig.tight_layout(); fig.savefig(P/f'fhn_phase_{tag}.png',dpi=150); plt.close(fig)
save('fhn_I1_I15_time.png','t','v',[('fhn_I1.dat',(0,1),'I=1'),('fhn_I15.dat',(0,1),'I=1.5')])
save('fhn_I1_I15_w_time.png','t','w',[('fhn_I1.dat',(0,2),'I=1'),('fhn_I15.dat',(0,2),'I=1.5')])
# ML base pulse responses
base=[('ml_b_m18.dat','V0=-18'),('ml_b_m148.dat','V0=-14.8'),('ml_b_m147.dat','V0=-14.7'),('ml_b_m12.dat','V0=-12')]
save('ml_base_V_time.png','t (ms)','V (mV)',[(f,(0,1),l) for f,l in base])
save('ml_base_n_time.png','t (ms)','n',[(f,(0,2),l) for f,l in base])
a=dat('ml_b_null15.dat'); series=[('ml_b_null15.dat',(0,1),'nulclina V'),('ml_b_null15.dat',(0,2),'nulclina n')]+[(f,(1,2),l) for f,l in base]
save('ml_base_phase_pulses.png','V (mV)','n',series)
save('ml_base_fI.png','J (µA/cm²)','frecuencia (Hz)',[('ml_b_fi.dat',(0,1),'Morris–Lecar base')])
for j,tag in [(24.8,'24p8'),(25,'25')]:
    f=f'ml_b_null{tag}.dat'; z=dat(f); ser=[(f,(0,1),f'nulclina V, J={j}'),(f,(0,2),'nulclina n')]
    if j==24.8: ser.append(('ml_b_trace24p8.dat',(1,2),'trayectoria'))
    if j==25: ser.append(('ml_b_trace25.dat',(1,2),'trayectoria'))
    save(f'ml_base_phase_J{tag}.png','V (mV)','n',ser)
save('ml_base_trace_J25.png','t (ms)','V (mV)',[('ml_b_trace25.dat',(0,1),'J=25')])
# Modified ML
mod=[('ml_m_m40.dat','V0=-40'),('ml_m_m15.dat','V0=-15'),('ml_m_m12.dat','V0=-12'),('ml_m_m2.dat','V0=-2')]
save('ml_mod_V_time.png','t (ms)','V (mV)',[(f,(0,1),l) for f,l in mod])
save('ml_mod_n_time.png','t (ms)','n',[(f,(0,2),l) for f,l in mod])
series=[('ml_m_null0.dat',(0,1),'nulclina V'),('ml_m_null0.dat',(0,2),'nulclina n')]+[(f,(1,2),l) for f,l in mod]
save('ml_mod_phase_pulses.png','V (mV)','n',series)
save('ml_mod_fI.png','J (µA/cm²)','frecuencia (Hz)',[('ml_m_fi.dat',(0,1),'Morris–Lecar modificado')])
save('ml_mod_threshold_traces.png','t (ms)','V (mV)',[(f'ml_m_trace{tag}.dat',(0,1),f'J={label}') for tag,label in [('7p9','7.9'),('8p33','8.33'),('8p35','8.35')]])
for tag,label in [('7p9','7.9'),('8p33','8.33'),('8p35','8.35')]:
    f=f'ml_m_null{tag}.dat'; series=[(f,(0,1),f'nulclina V, J={label}'),(f,(0,2),'nulclina n'),(f'ml_m_trace{tag}.dat',(1,2),'trayectoria')]
    save(f'ml_mod_phase_J{tag}.png','V (mV)','n',series)
print('PNG generados.')
