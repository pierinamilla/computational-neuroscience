#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p bin datos figuras
gfortran -O2 -Wall -Wextra -fcheck=all src/q2_adex.f90 -o bin/q2_adex
# Table 6.1 Gerstner et al.; R=500 MOhm => G=2 nS, C=2*tau_m pF.
# name tau_m a tau_w b reset I
while read -r name tm a tau b reset I; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  bin/q2_adex "$name" "$tm" "$a" "$tau" "$b" "$reset" "$I" 700 100 600 "datos/Q2a_${name}.csv"
done <<'PARAMS'
tonic 20 0 30 60 -55 65
adapting 20 0 100 5 -55 65
initial_burst 5 0.5 100 7 -51 65
bursting 5 -0.5 100 7 -46 65
irregular 9.9 -0.5 100 7 -46 65
transient 10 1 100 10 -60 65
delayed 5 -1 100 10 -60 25
PARAMS
# Q2b: 'initial_burst' with short suprathreshold pulse and alternative tonic current.
bin/q2_adex initial_burst 5 .5 100 7 -51 0 350 100 100 datos/Q2b_i_rest.csv
bin/q2_adex initial_burst 5 .5 100 7 -51 250 350 100 103 datos/Q2b_i_pulse.csv
bin/q2_adex initial_burst 5 .5 100 7 -51 90 550 100 450 datos/Q2b_ii_step.csv
python3 plots/q2_figures.py
