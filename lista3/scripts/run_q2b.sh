#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p bin data plots

FC="gfortran"
FFLAGS="-O3 -Wall -Jbin"

echo "=== Compilando q2b ==="
$FC $FFLAGS -o bin/q2b src/q2b_main.f90 \
    bin/mod_thalamic_params.o bin/mod_thalamic_gating.o \
    bin/mod_thalamic_deriv.o  bin/mod_rk4_thalamic.o

echo "=== Ejecutando q2b (barrido 2D, puede tardar varios minutos) ==="
time ./bin/q2b

echo "=== Graficando ==="
gnuplot scripts/plot_q2b.gp

echo "Listo. Ver plots/q2b_*.png"
