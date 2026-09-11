#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
FC=${FC:-gfortran}
$FC -O3 -o bin/hh_q6_scan src/hh_q6_scan.f90
bin/hh_q6_scan > data/q6_curva_LvsJ2.dat
{
  echo "Q6 - Periodo refractario del modelo HH"
  echo "J1=100 uA/cm2; dur=0.5 ms; t1=10 ms; dt=0.001 ms"
  echo
  printf "J2      L_min(ms)\n"
  cat data/q6_curva_LvsJ2.dat
  echo
  awk 'NR==1{min=$2} $2<min{min=$2} NR==1{rel=$2} END{printf "PR relativo (J2=J1): %.4f ms\nPR absoluto (minimo para J2 grande): %.4f ms\n",rel,min}' data/q6_curva_LvsJ2.dat
} | tee data/q6_resultados.txt

echo "=== Generando graficos ==="
gnuplot scripts/plot_q6_curva.gp
gnuplot scripts/plot_q6_pulsos.gp

echo "=== Abriendo ==="
eog plots/q6_L_vs_J2.png &
eog plots/q6_pulsos.png &

echo "Listo."
