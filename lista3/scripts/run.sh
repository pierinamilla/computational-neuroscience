#!/bin/bash
set -e
cd "$(dirname "$0")/.."

FC="gfortran"
FFLAGS="-O3 -Wall -Jbin"

mkdir -p bin data plots

# --- Compilar módulos ---
$FC $FFLAGS -c src/mod_cs_params.f90 -o bin/mod_cs_params.o
$FC $FFLAGS -c src/mod_cs_gating.f90 -o bin/mod_cs_gating.o
$FC $FFLAGS -c src/mod_cs_deriv.f90  -o bin/mod_cs_deriv.o
$FC $FFLAGS -c src/mod_rk4.f90       -o bin/mod_rk4.o

# --- Compilar programas ---
$FC $FFLAGS -o bin/q1a src/q1a_main.f90 \
    bin/mod_cs_params.o bin/mod_cs_gating.o

$FC $FFLAGS -o bin/q1b src/q1b_main.f90 \
    bin/mod_cs_params.o bin/mod_cs_gating.o \
    bin/mod_cs_deriv.o  bin/mod_rk4.o

# --- Ejecutar ---
echo "Ejecutando q1a..."
./bin/q1a

echo "Ejecutando q1b..."
./bin/q1b

echo "Datos generados en data/"
ls -la data/

echo "Compilacion terminada"
