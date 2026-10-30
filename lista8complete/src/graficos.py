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
                       label=f"{NOMES[tpa]} neurons")
        a.set_xlim(x0, x1); a.set_ylim(0.3, N + 0.7)
        a.set_yticks(range(1, N + 1)); a.set_ylabel("neuron #")
        for b in [5.5] + ([10.5] if N > 10 else []):
            a.axhline(b, color="0.8", lw=0.8)
    ax[0].set_title(titulo, pad=24)
    ax[0].legend(loc="lower center", bbox_to_anchor=(0.5, 1.0), ncol=3, fontsize=8, frameon=False)
    ax[1].set_xlabel("t (ms)")
    ax[1].set_title("zoom", fontsize=9)
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
raster("q2a", "Q2a: ING network (5 I + 5 O), $\\bar g_{OI}$ = 0.04 mS/cm$^2$", "Q2a_raster.png")
raster("q2b", "Q2b: ING network without O$\\rightarrow$I synapses ($\\bar g_{OI}$ = 0)", "Q2b_raster.png")

# ----------------------------- Questao 3a --------------------------------
t, V, tipos = le_V("q3a")
idx, tp, ts = le_spk("q3a")
fig, ax = plt.subplots(2, 1, figsize=(8, 5.5), sharex=True,
                       gridspec_kw={"height_ratios": [2, 1]})
ax[0].plot(t, V[:, 0], color="tab:green", label="E (excitatory)")
ax[0].plot(t, V[:, 1], color="tab:red", label="I (inhibitory)")
ax[0].set_ylabel("V (mV)"); ax[0].set_title("Q3a: E-I pair (PING), $\\bar g_{EI}=\\bar g_{IE}=0.25$ mS/cm$^2$, $J_E=1.4\\ \\mu$A/cm$^2$")
ax[0].legend(loc="upper right", fontsize=8)
ax[1].eventplot([ts[idx == 1], ts[idx == 2]], colors=["tab:green", "tab:red"],
                lineoffsets=[1, 0], linelengths=0.8)
ax[1].set_yticks([0, 1]); ax[1].set_yticklabels(["I", "E"]); ax[1].set_xlabel("t (ms)")
ax[1].set_ylabel("spikes")
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
ax.set_title(f"Q3b: period sensitivity (T = {T0:.2f} ms)")
fig.tight_layout(); fig.savefig(os.path.join(FIG, "Q3b_sensibilidade.png"), dpi=160); plt.close(fig)
mais = max(dT, key=lambda k: abs(dT[k]))
log(f"  parametro com maior efeito sobre T: {mais}")

# ----------------------------- Questao 3c, 3d ----------------------------
raster("q3c", "Q3c: network E + 5 I + 5 O", "Q3c_raster.png")
raster("q3d", "Q3d: network E + 5 I + 5 O without O$\\rightarrow$I synapses ($\\bar g_{OI}$ = 0)", "Q3d_raster.png")


# ============================= QUESTAO 1 ==================================
# (rodar_tudo.sh gera: q1a [J0=3], q1b [J0=2], q1c_gX.XX [J0=1.5])
G_LISTA = ["0.10", "0.12", "0.14", "0.16", "0.18", "0.20", "0.22", "0.24", "0.26", "0.28"]

def le_q1(tag):
    d = np.loadtxt(os.path.join(DATA, tag + "_V.dat"), skiprows=1)
    s = np.loadtxt(os.path.join(DATA, tag + "_s.dat"))
    idx, tp, ts = le_spk(tag)
    return d[:, 0], d[:, 1], d[:, 2], s[:, 1], idx, ts

def fig_par(tag, J0, g, Erev, nome_pre, nome_pos, arq, titulo, cor_pre, cor_pos):
    t, Vpre, Vpos, s_pre, idx, ts = le_q1(tag)
    Jinj = np.where((t >= 5.0) & (t < 15.0), J0, 0.0)
    Jsin = g * s_pre * (Erev - Vpos)                      # eq. (21)
    fig, ax = plt.subplots(4, 1, figsize=(8, 8.5), sharex=True)
    ax[0].plot(t, Jinj, color="tab:blue"); ax[0].set_ylabel(r"$J_{\rm inj}$ ($\mu$A/cm$^2$)")
    ax[1].plot(t, Vpre, color=cor_pre); ax[1].set_ylabel(f"$V_{{{nome_pre}}}$ (mV)")
    ax[2].plot(t, Jsin, color="tab:purple"); ax[2].set_ylabel(r"$J_{\rm sin}$ ($\mu$A/cm$^2$)")
    ax[3].plot(t, Vpos, color=cor_pos); ax[3].set_ylabel(f"$V_{{{nome_pos}}}$ (mV)")
    ax[3].set_xlabel("t (ms)"); ax[0].set_title(titulo)
    for a in ax: a.set_xlim(0, t[-1])
    fig.tight_layout(); fig.savefig(os.path.join(FIG, arq), dpi=160); plt.close(fig)
    return t, Vpre, Vpos, Jsin, idx, ts

log("=== Questao 1 ===")
# --- (a) E -> I, J0 = 3, g_EI = 0,05
t, Vpre, Vpos, Jsin, idx, ts = fig_par("q1a", 3.0, 0.05, 0.0, "E", "I", "Q1a_E_to_I.png",
        r"Q1a: E$\rightarrow$I, $\bar g_{EI}=0.05$ mS/cm$^2$, $J_0=3\ \mu$A/cm$^2$", "tab:green", "tab:red")
log(f"  q1a: disparos de E = {np.round(ts[idx==1],2)}; disparos de I = {np.round(ts[idx==2],2)}; "
    f"max|Jsin| = {np.abs(Jsin).max():.3f}; V_I min = {Vpos.min():.2f} mV")
# --- (b) I -> E, J0 = 2, g_IE = 0,1
t, Vpre, Vpos, Jsin, idx, ts = fig_par("q1b", 2.0, 0.1, -80.0, "I", "E", "Q1b_I_to_E.png",
        r"Q1b: I$\rightarrow$E, $\bar g_{IE}=0.1$ mS/cm$^2$, $J_0=2\ \mu$A/cm$^2$", "tab:red", "tab:green")
log(f"  q1b: disparos de I (pre) = {np.round(ts[idx==1],2)}; disparos de E (pos) = {np.round(ts[idx==2],2)}; "
    f"V_E min = {Vpos.min():.2f} mV em t = {t[Vpos.argmin()]:.1f} ms; max|Jsin| = {np.abs(Jsin).max():.3f}")

# --- (c) degrau de 1,5 uA/cm2, varredura em g_EI
def ciclos(tE, tI, t0, t1):
    out = []
    for a, b in zip(tE[:-1], tE[1:]):
        if a < t0 or b > t1: continue
        out.append(tI[(tI >= a) & (tI < b)] - a)
    return out

def classifica(tE, tI):
    cyc = ciclos(tE, tI, 100.0, 445.0)
    n = len(cyc)
    for m in range(1, 13):
        if all(len(cyc[k]) == len(cyc[k+m]) and np.all(np.abs(cyc[k] - cyc[k+m]) < 0.15)
               for k in range(n-m-14, n-m)):
            q = sum(len(c) for c in cyc[-m:])
            return m, q
    return None, None

dados = {}
for g in G_LISTA:
    tag = f"q1c_g{g}"
    t, VE, VI, sE, idx, ts = le_q1(tag)
    tE = ts[idx == 1]; tI = ts[idx == 2]
    m, q = classifica(tE, tI)
    dados[g] = (t, VE, VI, tE, tI, m, q)
    TE = np.diff(tE[tE < 445]).mean()
    log(f"  q1c g={g}: nE={len(tE)} nI={len(tI)}  T_E={TE:.3f} ms ({1000/TE:.1f} Hz)  "
        + (f"travamento: {m} disparo(s) de E : {q} de I" if m else "sem travamento estrito em 450 ms"))

fig, ax = plt.subplots(5, 2, figsize=(11, 11), sharex=True, sharey=True)
for a, g in zip(ax.T.ravel(), G_LISTA):
    t, VE, VI, tE, tI, m, q = dados[g]
    a.plot(t, VE, color="tab:green", lw=0.7, label="E")
    a.plot(t, VI, color="k", lw=0.9, label="I")
    for x in tE: a.axvline(x, color="r", ls=":", lw=0.8)
    a.set_xlim(250, 340); a.set_ylim(-100, 50)
    a.set_title(rf"$\bar g_{{EI}}$ = {g}  (I: {len(tI)} spikes)", fontsize=9)
for a in ax[-1]: a.set_xlabel("t (ms)")
for a in ax[:, 0]: a.set_ylabel("V (mV)")
ax[0, 0].legend(loc="lower left", fontsize=7, ncol=2)
fig.suptitle("Q1c: $J_0$ = 1.5 $\\mu$A/cm$^2$; V of E (green) and I (black); red lines = E spikes", y=0.995)
fig.tight_layout(); fig.savefig(os.path.join(FIG, "Q1c_sweep.png"), dpi=150); plt.close(fig)

# --- (d) sincronizacao e travamento de fase: delta = I - E
def deltas(tE, tI):
    d1, d2 = [], []
    for a, b in zip(tE[:-1], tE[1:]):
        c = tI[(tI >= a) & (tI < b)] - a
        d1.append(c[0] if len(c) > 0 else np.nan)
        d2.append(c[1] if len(c) > 1 else np.nan)
    return np.array(d1), np.array(d2)

fig, ax = plt.subplots(5, 2, figsize=(10, 11), sharex=True, sharey=True)
for a, g in zip(ax.T.ravel(), G_LISTA):
    t, VE, VI, tE, tI, m, q = dados[g]
    d1, d2 = deltas(tE, tI)
    k = np.arange(1, len(d1) + 1)
    a.plot(k, d1, "ko", ms=3, label="1st I spike after E")
    a.plot(k, d2, "o", mfc="none", mec="r", ms=4, label="2nd I spike")
    rot = f"{m}:{q}" if m else "no strict locking"
    a.set_title(rf"$\bar g_{{EI}}$ = {g}  ({rot})", fontsize=9)
    a.set_ylim(0, 20)
for a in ax[-1]: a.set_xlabel("E spike #")
for a in ax[:, 0]: a.set_ylabel(r"$\delta$ (ms)")
ax[0, 0].legend(loc="upper right", fontsize=7)
fig.suptitle(r"Q1d: interval $\delta$ between each E spike and the following I spikes", y=0.995)
fig.tight_layout(); fig.savefig(os.path.join(FIG, "Q1d_delta.png"), dpi=150); plt.close(fig)

# exemplo no formato da Figura 3 do enunciado: g = 0,28
t, VE, VI, tE, tI, m, q = dados["0.28"]
fig, ax = plt.subplots(2, 1, figsize=(7.5, 7))
ax[0].plot(t, VI, "k", lw=1)
for x in tE: ax[0].axvline(x, color="r", ls="--", lw=0.8)
ax[0].set_xlim(0, 500); ax[0].set_ylim(-100, 50)
ax[0].set_xlabel("t (ms)"); ax[0].set_ylabel("V (mV)")
ax[0].set_title(r"Q1d: $\bar g_{EI}$ = 0.28 mS/cm$^2$  (red: E spikes; black: V$_I$)")
d1, d2 = deltas(tE, tI); k = np.arange(1, len(d1) + 1)
ax[1].plot(k, d1, "ko", ms=4, label="1st I spike"); ax[1].plot(k, d2, "o", mfc="none", mec="r", ms=5, label="2nd I spike")
ax[1].set_xlabel("spike #"); ax[1].set_ylabel(r"$\delta$ (ms)"); ax[1].set_ylim(0, 20); ax[1].legend(fontsize=8)
fig.tight_layout(); fig.savefig(os.path.join(FIG, "Q1d_g_0.28.png"), dpi=160); plt.close(fig)

with open(os.path.join(DATA, "resumo.txt"), "w") as f:
    f.write("\n".join(resumo) + "\n")
