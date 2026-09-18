#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p bin data plots

echo "=== Compilando q1_compare ==="
gfortran -O3 -Wall -Jbin -o bin/q1_compare src/q1_compare_main.f90 \
    bin/mod_cs_params.o      bin/mod_cs_gating.o \
    bin/mod_cs_deriv.o       bin/mod_cs_deriv_slowb.o \
    bin/mod_rk4.o

echo "=== Ejecutando q1_compare ==="
./bin/q1_compare

echo "=== Graficando ==="
gnuplot scripts/plot_q1_compare.gp

echo "Listo. Ver plots/q1_compare.png"
