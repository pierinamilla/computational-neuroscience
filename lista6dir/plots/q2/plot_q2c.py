import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from common import *
fig_, ax = plt.subplots(2, 2, figsize=(14, 7), sharex=True)
for j, (lab, tit) in enumerate([('abaixo', 'I abaixo de $I_L$'), ('acima', 'I acima de $I_L$')]):
    d = load('q2', f'q2c_trace_{lab}.dat'); m = d[:, 0] <= 1000
    ax[0, j].plot(d[m, 0], d[m, 1], 'k', lw=.7); ax[0, j].axhline(-50, color='r', ls='--', lw=1, label='limiar $V_L$')
    ax[1, j].plot(d[m, 0], d[m, 2], 'k', lw=.7); ax[0, j].set_title(tit); ax[0, j].legend(loc='lower right', fontsize=8)
    ax[0, j].set_ylabel('V (mV) – disparo desligado'); ax[1, j].set_ylabel('V (mV) – disparo ligado'); ax[1, j].set_xlabel('t (ms)')
fig_.suptitle('Q2(c): σ = 1,5 mV/ms$^{1/2}$ (primeiros 1000 ms de 2 s); I = 400 pA (esq.), 800 pA (dir.)'); fig_.tight_layout(); fig_.savefig(fig('q2', 'q2c_regular_irregular.png'))
# ISI e CV
fig_, ax = plt.subplots(1, 3, figsize=(15, 4))
for lab, c in (('abaixo', 'tab:blue'), ('acima', 'tab:red')):
    s = load('q2', f'q2c_spikes_{lab}.dat'); isi = s[:-1, 2]
    ax[0].hist(isi, bins=np.linspace(0, 150, 31), alpha=.6, color=c, label=f'{lab}: CV = {isi.std(ddof=1)/isi.mean():.2f}')
ax[0].set_xlabel('ISI (ms)'); ax[0].set_ylabel('contagem'); ax[0].legend(); ax[0].set_title('Distribuições de ISI')
e = load('q2', 'q2c_cv_ensemble.dat')
ax[1].errorbar(e[:, 0], e[:, 1], e[:, 2], fmt='o-', ms=3, capsize=2); ax[1].axvline(500, color='gray', ls=':'); ax[1].axhline(1, color='k', ls='--', lw=.8)
ax[1].set_xlabel('I (pA)'); ax[1].set_ylabel('CV_ISI (média ± dp, 30 realizações)'); ax[1].set_title('CV vs I'); ax[1].text(310, 1.02, 'Poisson (CV=1)')
ax[2].plot(e[:, 0], e[:, 3], 'o-', ms=3); ax[2].set_xlabel('I (pA)'); ax[2].set_ylabel('taxa média (Hz)'); ax[2].set_title('Taxa média')
fig_.tight_layout(); fig_.savefig(fig('q2', 'q2c_ISI_CV.png'))
