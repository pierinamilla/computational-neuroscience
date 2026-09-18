#!/usr/bin/env python3
"""
Q2b: Gráficos 3D del barrido 2D (I_base vs I_step).
Lee data/q2b_sweep.dat y genera:
  - plots/q2b_spikes_3D.png   (superficie 3D del número de spikes)
  - plots/q2b_isi_3D.png      (superficie 3D del ISI mínimo)
  - plots/q2b_heatmap.png     (heatmaps 2D lado a lado)
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# --- Rutas ---
ROOT     = Path(__file__).resolve().parent.parent
DATA     = ROOT / "data"
PLOTS    = ROOT / "plots"
PLOTS.mkdir(exist_ok=True)

# --- Cargar datos ---
# Columnas: I_base  I_step  N_spikes  ISI_min
data = np.loadtxt(DATA / "q2b_sweep.dat")

Ib  = data[:, 0]      # 1D, con repeticiones
Is  = data[:, 1]
N   = data[:, 2]
ISI = data[:, 3]
ISI = np.where(ISI > 0, ISI, np.nan)   # descartar centinelas -1000

# --- Pasar a grillas 2D ---
Ib_u  = np.unique(Ib)
Is_u  = np.unique(Is)
n_Ib  = len(Ib_u)
n_Is  = len(Is_u)

N_grid   = np.full((n_Is, n_Ib), np.nan)
ISI_grid = np.full((n_Is, n_Ib), np.nan)

for k in range(len(Ib)):
    i = np.where(Ib_u == Ib[k])[0][0]
    j = np.where(Is_u == Is[k])[0][0]
    N_grid[j, i]   = N[k]
    ISI_grid[j, i] = ISI[k]

# Malla para superficies
Ib_mesh, Is_mesh = np.meshgrid(Ib_u, Is_u)


# =====================================================================
# Figura 1: Número de spikes en 3D
# =====================================================================
fig = plt.figure(figsize=(9, 6))
ax  = fig.add_subplot(111, projection='3d')

surf = ax.plot_surface(Ib_mesh, Is_mesh, N_grid,
                       cmap='hot', edgecolor='none', alpha=0.95)
ax.set_xlabel('I_base (pA)')
ax.set_ylabel('I_step (pA)')
ax.set_zlabel('N spikes')
ax.set_title('Q2b: número de spikes durante el escalón', fontsize=12)
fig.colorbar(surf, ax=ax, shrink=0.6, label='N spikes')
plt.tight_layout()
plt.savefig(PLOTS / "q2b_spikes_3D.png", dpi=150, bbox_inches='tight')
plt.close(fig)
print("Guardado: plots/q2b_spikes_3D.png")


# =====================================================================
# Figura 2: ISI mínimo en 3D
# =====================================================================
fig = plt.figure(figsize=(9, 6))
ax  = fig.add_subplot(111, projection='3d')

# Poner los NaN a un valor grande solo para el plot (no afecta al color)
ISI_plot = np.where(np.isnan(ISI_grid), np.nanmax(ISI_grid), ISI_grid)

surf = ax.plot_surface(Ib_mesh, Is_mesh, ISI_plot,
                       cmap='viridis_r', edgecolor='none', alpha=0.95)
ax.set_xlabel('I_base (pA)')
ax.set_ylabel('I_step (pA)')
ax.set_zlabel('ISI_min (ms)')
ax.set_title('Q2b: intervalo mínimo entre disparos', fontsize=12)
fig.colorbar(surf, ax=ax, shrink=0.6, label='ISI_min (ms)')
plt.tight_layout()
plt.savefig(PLOTS / "q2b_isi_3D.png", dpi=150, bbox_inches='tight')
plt.close(fig)
print("Guardado: plots/q2b_isi_3D.png")


# =====================================================================
# Figura 3: heatmaps 2D lado a lado
# =====================================================================
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel izquierdo: N spikes ---
im0 = axes[0].pcolormesh(Ib_u, Is_u, N_grid, cmap='hot', shading='nearest')
axes[0].set_xlabel('I_base (pA)')
axes[0].set_ylabel('I_step (pA)')
axes[0].set_title('Número de spikes', fontsize=12)
fig.colorbar(im0, ax=axes[0], label='N spikes')

# --- Panel derecho: ISI min ---
im1 = axes[1].pcolormesh(Ib_u, Is_u, ISI_grid, cmap='viridis_r',
                          shading='nearest')
axes[1].set_xlabel('I_base (pA)')
axes[1].set_ylabel('I_step (pA)')
axes[1].set_title('ISI mínimo (ms)', fontsize=12)
fig.colorbar(im1, ax=axes[1], label='ISI_min (ms)')

plt.tight_layout()
plt.savefig(PLOTS / "q2b_heatmap.png", dpi=150, bbox_inches='tight')
plt.close(fig)
print("Guardado: plots/q2b_heatmap.png")

print("\nListo. Revisa plots/")
