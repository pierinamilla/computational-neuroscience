#!/bin/bash
# Lista 8 - compila, simula e gera as figuras das Questoes 2 e 3.
# Uso: cd src && ./rodar_tudo.sh
set -e
cd "$(dirname "$0")"
mkdir -p ../data ../figuras

echo ">> compilando"
gfortran -O2 -Wall -o rede_EIO rede_EIO.f90

echo ">> Questao 2 (ING)"
./rede_EIO q2a          # 2a: 5 I + 5 O, gOI = 0,04
./rede_EIO q2b          # 2b: idem com gOI = 0

echo ">> Questao 3 (PING)"
./rede_EIO q3a                  # 3a: par E-I, 200 ms
./rede_EIO q3b                  # 3b: base (1000 ms, para medir T no regime estacionario)
./rede_EIO q3b 0.99 1    1      # (i)   J_E   -> 0,99 J_E
./rede_EIO q3b 1    1.01 1      # (ii)  g_IE  -> 1,01 g_IE
./rede_EIO q3b 1    1    1.01   # (iii) tau_d,I -> 1,01 tau_d,I
./rede_EIO q3c          # 3c: E + 5 I + 5 O
./rede_EIO q3d          # 3d: idem com gOI = 0

echo ">> figuras e metricas"
python3 graficos.py
echo ">> pronto: figuras em ../figuras, resumo em ../data/resumo.txt"
