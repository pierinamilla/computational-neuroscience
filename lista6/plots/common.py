"""Utilidades comuns aos scripts de figuras (executar a partir da raiz do projeto)."""
import os, numpy as np, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.special import erfcx
from scipy.integrate import quad
plt.rcParams.update({'font.size': 10, 'axes.grid': True, 'grid.alpha': .3, 'figure.dpi': 120})
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
def data(*p): return os.path.join(ROOT, 'data', *p)
def fig(*p):
    os.makedirs(os.path.dirname(os.path.join(ROOT, 'figures', *p)), exist_ok=True)
    return os.path.join(ROOT, 'figures', *p)
def load(*p): return np.loadtxt(data(*p), comments='#')
# parametros do modelo (iguais ao Fortran)
Vrep, R, C, VL, Vredef, tref = -70., 40., 250., -50., -65., 2.
taum = R*C*1e-3
def f_det(I, vr=Vredef):
    x = R*I*1e-3
    return np.where(x > VL-Vrep, 1000./(tref + taum*np.log(np.maximum(x-(vr-Vrep), 1e-12)/np.maximum(x-(VL-Vrep), 1e-12))), 0.)
def f_ricciardi(I, sigma, vr=Vredef):
    """Taxa de disparo do LIF com ruido branco (Siegert/Ricciardi), tau_ref absoluto."""
    sv = sigma*np.sqrt(taum)      # sigma_B^2 = 2 Var_estac. (convencao Brunel)
    out = []
    for i in np.atleast_1d(I):
        vinf = Vrep + R*i*1e-3
        lo, hi = (vr-vinf)/sv, (VL-vinf)/sv
        integ, _ = quad(lambda u: erfcx(-u), lo, hi)
        out.append(1000./(tref + taum*np.sqrt(np.pi)*integ))
    return np.array(out)
