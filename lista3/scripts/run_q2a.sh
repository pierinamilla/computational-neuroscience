#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p bin data plots

FC="gfortran"
FFLAGS="-O3 -Wall -Jbin"

echo "=== Compilando módulos del modelo talámico ==="
$FC $FFLAGS -c src/mod_thalamic_params.f90 -o bin/mod_thalamic_params.o
$FC $FFLAGS -c src/mod_thalamic_gating.f90 -o bin/mod_thalamic_gating.o
$FC $FFLAGS -c src/mod_thalamic_deriv.f90  -o bin/mod_thalamic_deriv.o
$FC $FFLAGS -c src/mod_rk4_thalamic.f90    -o bin/mod_rk4_thalamic.o

echo "=== Compilando q2a ==="
$FC $FFLAGS -o bin/q2a src/q2a_main.f90 \
    bin/mod_thalamic_params.o bin/mod_thalamic_gating.o \
    bin/mod_thalamic_deriv.o  bin/mod_rk4_thalamic.o

echo "=== Ejecutando q2a con I_base=-100 pA, I_step=+50 pA ==="
./bin/q2a -100 50

echo "=== Graficando ==="
gnuplot scripts/plot_q2a.gp

echo "Listo. Ver plots/q2a.png"
