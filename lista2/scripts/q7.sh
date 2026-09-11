#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
FC=${FC:-gfortran}
$FC -O3 -o bin/hh_anodo src/hh_anodo.f90
OUT=data/q7_resultados.txt; TABLE=data/q7_T_vs_resultado.dat
: > "$TABLE"
echo "T(ms) AP t_AP(ms) atraso(ms) Vmax_post(ms)" > "$TABLE"
Tmin=""; Tno=""
for T in 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0; do
  r=$(bin/hh_anodo "$T")
  ap=$(awk '{print $1}' <<< "$r"); tap=$(awk '{print $2}' <<< "$r"); delay=$(awk '{print $3}' <<< "$r"); vmax=$(awk '{print $4}' <<< "$r")
  printf "%.1f %d %.5f %.5f %.5f\n" "$T" "$ap" "$tap" "$delay" "$vmax" >> "$TABLE"
  [[ "$ap" -eq 0 ]] && Tno="$T"
  [[ "$ap" -eq 1 && -z "$Tmin" ]] && Tmin="$T"
done
{
 echo "Q7 - Estimulacion por ruptura de anodo"
 echo "J=-15 uA/cm2; ti=5 ms; dt=0.001 ms; t_total=30 ms"
 cat "$TABLE"
 echo
 echo "Menor T de la grilla con potencial de accion: $Tmin ms"
 r=$(bin/hh_anodo "$Tmin")
 echo "Atraso para T=$Tmin ms: $(awk '{print $3}' <<< "$r") ms"
} | tee "$OUT"
bin/hh_anodo "$Tno" >/dev/null; cp data/anodo.dat data/q7_sin_PA.dat
bin/hh_anodo "$Tmin" >/dev/null; cp data/anodo.dat data/q7_con_PA.dat


# ============================================================
# GRAFICOS
# ============================================================
echo ""
echo "=== Generando graficos ==="

gnuplot scripts/plot_q7.gp

echo "=== Abriendo graficos ==="
eog plots/q7_atraso.png &
eog plots/q7_vmax.png &
eog plots/q7_casos.png &

echo "Listo."

