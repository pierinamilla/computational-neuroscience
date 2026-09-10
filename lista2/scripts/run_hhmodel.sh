#!/usr/bin/env bash
set -e #detener si hay algun error

#ir a raiz del proyecto
cd "$(dirname "$0")/.."
ROOT=$(pwd)

#Configuracion
FC="gfortran"
FCFLAGS="-O3 -march=native -Wall -Wextra -fimplicit-none"
SRC="src/hh_model.f90"
BIN="bin/hh_model" #ejecutable

#Compilar
echo "Compilando..."
mkdir -p bin 

$FC $FCFLAGS -o $BIN $SRC

echo "Ejecutando simulación"
mkdir -p data
cd data
../bin/hh_model
cd "$ROOT"

echo "Graficando"
gnuplot scripts/plot_q1.gp

eog plots/q1.png &
