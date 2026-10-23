import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from common import *
fig_, ax = plt.subplots(1, 2, figsize=(12, 4.4)); cols = {'0': 'k', '0.5': 'tab:blue', '1.5': 'tab:red'}
for s, c in cols.items():
    d = load('q2', f'q2a_fI_sigma_{s}.dat')
    ax[0].plot(d[:, 0], d[:, 1], 'o', ms=3, color=c, label=f'σ = {s} mV/ms$^{{1/2}}$')
    if s != '0': ax[0].plot(d[:, 0], f_ricciardi(d[:, 0], float(s)), '-', color=c, lw=1)
ax[0].plot([], [], 'k-', lw=1, label='teoria (Ricciardi), linhas'); ax[0].axvline(500, color='gray', ls=':')
ax[0].set_xlabel('I (pA)'); ax[0].set_ylabel('f (Hz)'); ax[0].set_title('Q2(a): f–I com ruído (Euler–Maruyama)'); ax[0].legend(fontsize=8)
d0 = load('q2', 'q2a_fI_sigma_0.dat')
for s in ('0.5', '1.5'):
    d = load('q2', f'q2a_fI_sigma_{s}.dat'); ax[1].plot(d[:, 0], d[:, 1]-d0[:, 1], color=cols[s], label=f'σ = {s}')
ax[1].axhline(0, color='k', lw=.6); ax[1].axvline(500, color='gray', ls=':'); ax[1].set_xlabel('I (pA)'); ax[1].set_ylabel('f(σ) − f(0) (Hz)')
ax[1].set_title('Efeito do ruído sobre a curva f–I'); ax[1].legend(fontsize=8)
fig_.tight_layout(); fig_.savefig(fig('q2', 'q2a_fI_ruido.png'))
# comparacao quantitativa com a teoria
for s in ('0.5', '1.5'):
    d = load('q2', f'q2a_fI_sigma_{s}.dat'); print('q2a sigma', s, 'max|f-teoria| = %.1f Hz' % abs(d[:, 1]-f_ricciardi(d[:, 0], float(s))).max())
