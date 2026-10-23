import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from common import *
dts = [1e-2, 1e-3, 1e-4, 1e-5]; cols = ['tab:blue', 'tab:orange', 'tab:green', 'tab:red']
fig_, ax = plt.subplots(1, 3, figsize=(16, 4.4))
for k, (dt, c) in enumerate(zip(dts, cols), 1):
    d = load('q2', f'q2b_traj_dt{k}.dat'); z = load('q2', f'q2b_zoom_dt{k}.dat')
    ax[0].plot(d[:, 0], d[:, 1], color=c, lw=.8, label=f'Δt = {dt:g} ms'); ax[1].plot(z[:, 0], z[:, 1], color=c, lw=.8, label=f'Δt = {dt:g} ms')
ax[0].set_xlabel('t (ms)'); ax[0].set_ylabel('V (mV)'); ax[0].set_title('I = 300 pA, mesmo caminho browniano'); ax[0].legend(fontsize=8)
ax[1].set_xlabel('t (ms)'); ax[1].set_ylabel('V (mV)'); ax[1].set_title('Ampliação: 10–10,5 ms')
m = load('q2', 'q2b_metricas.dat')
ax[2].loglog(m[:, 0], m[:, 1], 'o-', label='⟨|ΔV|⟩ (mV)'); ax[2].loglog(m[:, 0], m[:, 4], 's-', label='rms(ΔV/Δt) (mV/ms)')
ax[2].loglog(m[:, 0], m[0, 1]*np.sqrt(m[:, 0]/m[0, 0]), 'k--', lw=.8, label='∝ Δt$^{1/2}$'); ax[2].loglog(m[:, 0], m[0, 4]*(m[:, 0]/m[0, 0])**-.5, 'k:', lw=.8, label='∝ Δt$^{-1/2}$')
ax[2].set_xlabel('Δt (ms)'); ax[2].set_title('Rugosidade vs passo'); ax[2].legend(fontsize=8)
fig_.tight_layout(); fig_.savefig(fig('q2', 'q2b_rugosidade_dt.png'))
print('q2b: variacao quadratica sum(dV^2) =', m[:, 3], ' sigma^2 T =', m[0, 5])
