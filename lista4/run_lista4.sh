#!/usr/bin/env bash
set -euo pipefail

FC="${FC:-gfortran}"
EXE="lista4"

echo "[1/2] Compilando Fortran..."
"$FC" -O3 -std=f2008 -Wall -Wextra -ffast-math lista4_pr.f90 -o "$EXE"

run_mode() {
  echo
  echo "===== $1 ====="
  "./$EXE" "$1"
}

if [[ $# -eq 0 ]]; then
  for q in q1 q2 q3 q4 q5 q6; do run_mode "$q"; done
else
  for q in "$@"; do run_mode "$q"; done
fi

if command -v gnuplot >/dev/null 2>&1; then
  echo
  echo "Generando PNGs con gnuplot..."
  gnuplot plot_lista4.gp
else
  echo
  echo "gnuplot no está instalado. Los .dat ya fueron generados."
  echo "En Debian/Ubuntu: sudo apt install gnuplot"
fi
