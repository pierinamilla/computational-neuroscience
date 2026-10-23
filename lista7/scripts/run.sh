#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p bin datos figuras
gfortran -O2 -Wall -Wextra -fcheck=all src/models.f90 src/main.f90 -o bin/simulate
bin/simulate 1 221 3000 500 2500 datos/Q1a.csv
for i in $(seq 0 19); do I=$(awk -v i="$i" 'BEGIN{printf "%.8f",200+300*i/19}'); bin/simulate 1 "$I" 5000 0 5000 "datos/Q1b_${i}.csv"; done
for kind in 2 3 4; do
 if [ "$kind" -eq 2 ]; then currents='300 370 500 550'; end=450; duration=500; fi
 if [ "$kind" -eq 3 ]; then currents='200 300 400 500'; end=450; duration=500; fi
 if [ "$kind" -eq 4 ]; then currents='200 400 470 500 600'; end=180; duration=200; fi
 bin/simulate "$kind" 0 80 100 100 "datos/Q3_${kind}_rest.csv"
 for I in $currents; do bin/simulate "$kind" "$I" "$duration" 20 "$end" "datos/Q3_${kind}_${I}.csv"; done
done
python3 plots/figures.py
