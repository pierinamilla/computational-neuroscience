#!/bin/bash
set -e
cd "$(dirname "$0")/.."
#mkdir -p bin data plots

echo "=== Compilando q1e ==="
gfortran -O3 -Wall -Jbin -o bin/q1e src/q1e_main.f90 \
    bin/mod_cs_params.o bin/mod_cs_gating.o \
    bin/mod_cs_deriv.o  bin/mod_rk4.o

echo "=== Ejecutando q1e ==="
./bin/q1e

echo "=== Graficando ==="
gnuplot scripts/plot_q1e.gp

echo "Listo. Ver plots/q1e.png"
