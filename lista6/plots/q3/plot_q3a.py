import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from common import *
d = load('q3', 'q3a_trace.dat')
fig_, ax = plt.subplots(3, 1, figsize=(9, 8), sharex=True)
ax[0].plot(d[:, 0], d[:, 1], 'k'); ax[0].set_ylabel('I (pA)')
ax[1].plot(d[:, 0], d[:, 2], 'k', lw=.8); ax[1].axhline(-50, color='r', ls='--', lw=.8); ax[1].set_ylabel('V (mV)')
ax[2].plot(d[:, 0], d[:, 3], 'tab:green'); ax[2].set_ylabel('$G_a$ (nS)'); ax[2].set_xlabel('t (ms)')
fig_.suptitle('Q3(a): LIF com corrente adaptativa, pulso de 501 pA entre 0,5 e 1,0 s'); fig_.tight_layout(); fig_.savefig(fig('q3', 'q3a_pulso_adaptacao.png'))
