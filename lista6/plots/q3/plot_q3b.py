import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from common import *
d = load('q3', 'q3b_fI.dat'); fi = load('q3', 'q3b_fI_fino.dat')
fig_, ax = plt.subplots(1, 2, figsize=(12, 4.4))
ax[0].plot(d[:, 0], d[:, 4], 'o-', color='tab:blue', label='$f_1 = 1/T_1$'); ax[0].plot(d[:, 0], d[:, 5], 's--', color='tab:red', label='$f_\\infty = 1/T_\\infty$')
ax[0].axvline(500, color='gray', ls=':'); ax[0].set_xlabel('I (pA)'); ax[0].set_ylabel('f (Hz)'); ax[0].set_title('Q3(b): curvas f–I'); ax[0].legend()
m = fi[:, 4] > 0
ax[1].plot(fi[m, 0], fi[m, 4], 'o-', color='tab:blue', ms=3, label='$f_1$'); m2 = fi[:, 5] > 0; ax[1].plot(fi[m2, 0], fi[m2, 5], 's--', color='tab:red', ms=3, label='$f_\\infty$')
ax[1].axvline(500, color='gray', ls=':'); ax[1].set_xlabel('I (pA)'); ax[1].set_ylabel('f (Hz)'); ax[1].set_title('Varredura fina perto de $I_L$ = 500 pA'); ax[1].legend()
fig_.tight_layout(); fig_.savefig(fig('q3', 'q3b_fI_adaptacao.png'))
