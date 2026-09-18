#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p bin data plots

echo "=== Compilando mod_cs_deriv_slowb ==="
gfortran -O3 -Wall -Jbin -c src/mod_cs_deriv_slowb.f90 -o bin/mod_cs_deriv_slowb.o

echo "=== Compilando q1f ==="
gfortran -O3 -Wall -Jbin -o bin/q1f src/q1f_main.f90 \
    bin/mod_cs_params.o bin/mod_cs_gating.o \
    bin/mod_cs_deriv_slowb.o bin/mod_rk4.o

echo "=== Ejecutando q1f ==="
./bin/q1f

echo "=== Graficando ==="
gnuplot scripts/plot_q1f.gp

echo "Listo. Ver plots/q1f.png"
