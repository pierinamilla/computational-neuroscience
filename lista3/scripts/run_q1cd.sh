#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p bin data plots

echo "=== Compilando q1cd ==="
gfortran -O3 -Wall -Jbin -o bin/q1cd src/q1cd_main.f90 \
    bin/mod_cs_params.o bin/mod_cs_gating.o \
    bin/mod_cs_deriv.o  bin/mod_rk4.o

echo "=== Ejecutando q1cd ==="
./bin/q1cd

echo "=== Graficando ==="
gnuplot scripts/plot_q1cd.gp

echo "Listo. Ver plots/q1cd_fI.png"
