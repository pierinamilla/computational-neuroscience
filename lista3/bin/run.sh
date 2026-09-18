#!/bin/bash
set -e
cd "$(dirname "$0")"

FC="gfortran"
FFLAGS="-03 -Wall - Jbin"

# Compilar módulos (primero los que no dependen de nadie)
$FC $FFLAGS -c src/mod_cs_params.f90 -o bin/mod_cs_params.o
$FC $FFLAGS -c src/mod_cs_gating.f90 -o bin/mod_cs_gating.o
$FC $FFLAGS -c src/mod_cs_deriv.f90 -o bin/mod_cs_deriv.o
$FC $FFLAGS -c src/mod_rk4.f90 -o bin/mod_rk4.f90

# Compilar programas
$FC $FFLAGS


$FC $FFLAGS -o bin/q1b /src/q1b_main.f90 bin/mod_cs_params.o ./mod_cs_gating.o ./mod_cs_deriv.o  ./mod_rk4.o
