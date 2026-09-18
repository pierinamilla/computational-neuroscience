#!/usr/bin/env python3
"""Q2b: 4 regímenes cualitativos en un solo panel."""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

ROOT  = Path(__file__).resolve().parent.parent
DATA  = ROOT / "data"
PLOTS = ROOT / "plots"

# Casos elegidos (ajustar al nombre real del archivo generado por q2a)
casos = [
    ("Silencioso",   "q2a_Ib-175_Is50.dat"),
    ("Burst/rebote", "q2a_Ib-100_Is50.dat"),
    ("Tónico",       "q2a_Ib100_Is50.dat"),
    ("Tónico rápido","q2a_Ib200_Is100.dat"),
]

fig, axes = plt.subplots(2, len(casos), figsize=(4*len(casos), 6), sharex=True)

for col, (nombre, fname) in enumerate(casos):
    # Intentar varias rutas posibles
    f = DATA / fname
    if not f.exists():
        # Probar variantes del nombre (con/sin signo)
        for cand in DATA.glob(fname.replace("_Is", "*_Is")):
            f = cand; break

    if not f.exists():
        axes[0, col].set_title(f"{nombre}\n(no encontrado)")
        continue

    data = np.loadtxt(f)
    t   = data[:, 0]
    V   = data[:, 1]
    hT  = data[:, 4]

    axes[0, col].plot(t, V, 'k', lw=1)
    axes[0, col].set_title(f"{nombre}\n{f.name}", fontsize=10)
    axes[0, col].set_ylabel("V (mV)")
    axes[0, col].set_ylim(-100, 60)
    axes[0, col].grid(alpha=0.3)

    axes[1, col].plot(t, hT, 'purple', lw=1.5)
    axes[1, col].set_ylabel("h_T")
    axes[1, col].set_xlabel("t (ms)")
    axes[1, col].set_ylim(0, 1)
    axes[1, col].grid(alpha=0.3)

plt.tight_layout()
plt.savefig(PLOTS / "q2b_cases.png", dpi=150, bbox_inches='tight')
print("Guardado: plots/q2b_cases.png")
