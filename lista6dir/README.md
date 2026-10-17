# Lista 6 — Introdução à Neurociência Computacional (FFCLRP-USP)

Modelos LIF (Q1), LIF com ruído (Q2) e LIF com corrente adaptativa (Q3). Código em Fortran 90 (Euler / Euler–Maruyama), figuras em Python (matplotlib/scipy).

```
lista6/
├── Makefile                 make run  -> compila e roda tudo | make plots -> figuras | make clean
├── src/
│   ├── common/neuro_mod.f90 parâmetros, RNG gaussiano, integrador LIF (ruído, adaptação), CV_ISI
│   ├── q1/q1a_fI_lif.f90                 Q1(a)  f-I numérica x analítica
│   ├── q2/q2a_fI_ruido.f90               Q2(a)  f-I com ruído, σ na linha de comando
│   ├── q2/q2b_dt_rugosidade.f90          Q2(b)  rugosidade x Δt (mesmo caminho browniano)
│   ├── q2/q2c_cv_isi.f90                 Q2(c)  regular x irregular, ISI e CV
│   ├── q3/q3a_pulso_adaptacao.f90        Q3(a)  pulso de 501 pA
│   └── q3/q3b_fI_adaptacao.f90           Q3(b)  f1 e f_inf x I
├── build/{bin,mod}/         executáveis e módulos (gerados)
├── data/{q1,q2,q3}/         saídas numéricas (.dat) de cada item
├── plots/{q1,q2,q3}/        um script Python por item (plot_q1a.py, ...) + plots/common.py
├── figures/{q1,q2,q3}/      figuras geradas
└── report/main.tex          relatório (LaTeX) + figures/
```
Unidades: ms, mV, pA, pF, MΩ, nS (1 pA/pF = 1 mV/ms; 1 nS·mV = 1 pA).
Parâmetros escolhidos (editáveis no Makefile): σ₁ = 0,5 e σ₂ = 1,5 mV/ms^½; I_abaixo = 400 pA, I_acima = 800 pA.
