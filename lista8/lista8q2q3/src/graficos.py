#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Lista 8 - Neurociencia Computacional: figuras e metricas das Questoes 2 e 3.
Le os arquivos de ../data gerados por rede_EIO.f90 e grava PNGs em ../figuras
e um resumo numerico em ../data/resumo.txt."""
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

AQUI = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(AQUI, "..", "data")
FIG = os.path.join(AQUI, "..", "figuras")
os.makedirs(FIG, exist_ok=True)
NOMES = {1: "E", 2: "I", 3: "O"}
COR = {1: "tab:green", 2: "k", 3: "tab:red"}
MARC = {1: "D", 2: "|", 3: "|"}
resumo = []

def log(s):
    print(s); resumo.append(s)

def le_V(tag):
    with open(os.path.join(DATA, tag + "_V.dat")) as f:
        tipos = np.array(f.readline().split()[2:], dtype=int)
    d = np.loadtxt(os.path.join(DATA, tag + "_V.dat"), skiprows=1)
    return d[:, 0], d[:, 1:], tipos

def le_spk(tag):
    d = np.loadtxt(os.path.join(DATA, tag + "_spk.dat"), ndmin=2)
    return d[:, 0].astype(int), d[:, 1].astype(int), d[:, 2]

def freq_pop(idx, tp, ts, tp_alvo, t0, t1, n_neur):
    """taxa media de disparo (Hz) de uma populacao na janela [t0,t1]"""
    m = (tp == tp_alvo) & (ts >= t0) & (ts <= t1)
    return 1000.0 * m.sum() / (n_neur * (t1 - t0))

def isi_tipico(idx, tp, ts, tp_alvo, t0):
    """ISI mediano (ms) dos disparos de um tipo apos t0 (por neuronio)"""
    isis = []
    for k in np.unique(idx[tp == tp_alvo]):
        t = ts[(idx == k) & (ts >= t0)]
        isis += list(np.diff(t))
    return np.median(isis), np.mean(isis)

def chi_sync(t, V, tipos, tp_alvo, t0):
    """indice de sincronia de Golomb-Rinzel (1 = sincronia perfeita)"""
    m = t >= t0
    X = V[m][:, tipos == tp_alvo]
    if X.shape[1] < 2:
        return np.nan
    num = X.mean(axis=1).var()
    den = X.var(axis=0).mean()
    return np.sqrt(num/den)

def raster(tag, titulo, arq, zoom=(1000, 1300), t0_est=500):
    t, V, tipos = le_V(tag)
    idx, tp, ts = le_spk(tag)
    N = len(tipos)
    fig, ax = plt.subplots(2, 1, figsize=(9, 6.2))
    for a, (x0, x1) in zip(ax, [(0, t[-1]), zoom]):
        for tpa in (2, 3, 1):
            m = (tp == tpa) & (ts >= x0) & (ts <= x1)
            if m.any():
                a.plot(ts[m], idx[m], MARC[tpa], color=COR[tpa],
                       ms=9 if tpa != 1 else 5, mew=1.4, ls="none",
                       label=f"neurônios {NOMES[tpa]}")
        a.set_xlim(x0, x1); a.set_ylim(0.3, N + 0.7)
        a.set_yticks(range(1, N + 1)); a.set_ylabel("neurônio #")
        for b in [5.5] + ([10.5] if N > 10 else []):
            a.axhline(b, color="0.8", lw=0.8)
    ax[0].set_title(titulo, pad=24)
    ax[0].legend(loc="lower center", bbox_to_anchor=(0.5, 1.0), ncol=3, fontsize=8, frameon=False)
    ax[1].set_xlabel("t (ms)")
    ax[1].set_title("ampliação", fontsize=9)
    fig.tight_layout(); fig.savefig(os.path.join(FIG, arq), dpi=160); plt.close(fig)
    # metricas
    log(f"--- {tag} ({titulo}) ---")
    for tpa in (2, 3, 1):
        n = int((tipos == tpa).sum())
        if n == 0: continue
        med, mean = isi_tipico(idx, tp, ts, tpa, t0_est)
        r = freq_pop(idx, tp, ts, tpa, t0_est, t[-1], n)
        log(f"  tipo {NOMES[tpa]}: taxa media (t>{t0_est} ms) = {r:.1f} Hz | "
            f"ISI mediano = {med:.1f} ms (f = {1000/med:.1f} Hz) | ISI medio = {mean:.1f} ms (f = {1000/mean:.1f} Hz)"
            f" | chi = {chi_sync(t, V, tipos, tpa, t0_est):.3f}")

# ----------------------------- Questao 2 ---------------------------------
raster("q2a", "Q2a: rede ING (5 I + 5 O), $\\bar g_{OI}$ = 0,04 mS/cm²", "Q2a_raster.png")
raster("q2b", "Q2b: rede ING sem sinapses O→I ($\\bar g_{OI}$ = 0)", "Q2b_raster.png")

# ----------------------------- Questao 3a --------------------------------
t, V, tipos = le_V("q3a")
idx, tp, ts = le_spk("q3a")
fig, ax = plt.subplots(2, 1, figsize=(8, 5.5), sharex=True,
                       gridspec_kw={"height_ratios": [2, 1]})
ax[0].plot(t, V[:, 0], color="tab:green", label="E (excitatório)")
ax[0].plot(t, V[:, 1], color="tab:red", label="I (inibitório)")
ax[0].set_ylabel("V (mV)"); ax[0].set_title("Q3a: par E-I (PING), $\\bar g_{EI}=\\bar g_{IE}=0{,}25$ mS/cm², $J_E=1{,}4$ µA/cm²")
ax[0].legend(loc="upper right", fontsize=8)
ax[1].eventplot([ts[idx == 1], ts[idx == 2]], colors=["tab:green", "tab:red"],
                lineoffsets=[1, 0], linelengths=0.8)
ax[1].set_yticks([0, 1]); ax[1].set_yticklabels(["I", "E"]); ax[1].set_xlabel("t (ms)")
ax[1].set_ylabel("disparos")
fig.tight_layout(); fig.savefig(os.path.join(FIG, "Q3a_VEI.png"), dpi=160); plt.close(fig)
tE = ts[idx == 1]; tI = ts[idx == 2]
log("--- q3a ---")
log(f"  disparos de E: {np.round(tE[:4],2)} ...; disparos de I: {np.round(tI[:5],2)} ...")
log(f"  T(E) medio em 200 ms = {np.diff(tE).mean():.2f} ms; I dispara {len(tI)/len(tE):.1f}x por ciclo de E")
log(f"  atraso do 1o disparo de I apos o de E (ciclo 2) = {tI[tI>tE[1]][0]-tE[1]:.2f} ms")

# ----------------------------- Questao 3b --------------------------------
def periodo(tag, t_transiente=300.0):
    idx, tp, ts = le_spk(tag)
    t = ts[(idx == 1) & (ts > t_transiente)]
    return np.diff(t).mean(), np.diff(t).std(), len(t)

T0, s0, n0 = periodo("q3b")
log("--- q3b (simulacoes de 1000 ms, T medido com os disparos de E em t>300 ms) ---")
log(f"  base:        T = {T0:.4f} ms (desvio {s0:.1e}, {n0} disparos)  f = {1000/T0:.2f} Hz")
nomes = {"q3b_J": r"$J_E \to 0{,}99\,J_E$", "q3b_g": r"$\bar g_{IE} \to 1{,}01\,\bar g_{IE}$",
         "q3b_tau": r"$\tau_{d,I} \to 1{,}01\,\tau_{d,I}$"}
dT = {}
for k in nomes:
    T, s, n = periodo(k)
    dT[k] = 100 * (T - T0) / T0
    log(f"  {k:8s}: T = {T:.4f} ms  ->  variacao = {dT[k]:+.3f} %")
fig, ax = plt.subplots(figsize=(6.2, 4))
bars = ax.bar(range(3), [dT[k] for k in nomes], color=["tab:blue", "tab:orange", "tab:purple"])
ax.set_xticks(range(3)); ax.set_xticklabels([nomes[k] for k in nomes])
ax.axhline(0, color="k", lw=0.8)
for b, k in zip(bars, nomes):
    ax.text(b.get_x() + b.get_width()/2, dT[k], f"{dT[k]:+.3f}%", ha="center",
            va="bottom" if dT[k] >= 0 else "top", fontsize=9)
ax.set_ylabel("$\\Delta T / T$ (%)")
ax.set_title(f"Q3b: sensibilidade do período (T = {T0:.2f} ms)")
fig.tight_layout(); fig.savefig(os.path.join(FIG, "Q3b_sensibilidade.png"), dpi=160); plt.close(fig)
mais = max(dT, key=lambda k: abs(dT[k]))
log(f"  parametro com maior efeito sobre T: {mais}")

# ----------------------------- Questao 3c, 3d ----------------------------
raster("q3c", "Q3c: rede E + 5 I + 5 O", "Q3c_raster.png")
raster("q3d", "Q3d: rede E + 5 I + 5 O sem sinapses O→I ($\\bar g_{OI}$ = 0)", "Q3d_raster.png")

with open(os.path.join(DATA, "resumo.txt"), "w") as f:
    f.write("\n".join(resumo) + "\n")
