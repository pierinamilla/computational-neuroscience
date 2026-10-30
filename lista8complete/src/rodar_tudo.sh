#!/bin/bash
# Lista 8 - compila, simula e gera as figuras das Questoes 2 e 3.
# Uso: cd src && ./rodar_tudo.sh
set -e
cd "$(dirname "$0")"
mkdir -p ../data ../figuras

echo ">> compilando"
gfortran -O2 -Wall -o rede_EIO rede_EIO.f90

echo ">> Questao 1 (par pre-pos)"
# varreduras auxiliares: numero de disparos do neuronio pre (col. 1 = indice 1) e pos (indice 2)
SCAN=../data/q1_varreduras.txt
echo "# caso  parametro  disparos_pre  disparos_pos" > $SCAN
for J in 0.2 0.4 0.6 0.8 1 1.5 2 3 3.5 3.8 4 5; do        # 1a: E->I, g_EI = 0,05
  ./rede_EIO q1a $J 0.05
  echo "q1a J0=$J $(awk '$1==1' ../data/q1a_spk.dat | wc -l) $(awk '$1==2' ../data/q1a_spk.dat | wc -l)" >> $SCAN
done
for J in 0.5 1 1.5 2 3 4; do                              # 1b: I->E, g_IE = 0,10
  ./rede_EIO q1b $J 0.10
  echo "q1b J0=$J $(awk '$1==1' ../data/q1b_spk.dat | wc -l) $(awk '$1==2' ../data/q1b_spk.dat | wc -l)" >> $SCAN
done
for g in 0.01 0.02 0.03 0.04 0.05 0.06 0.08; do           # inicio da resposta de I em 1c
  ./rede_EIO q1c 1.5 $g
  echo "q1c g=$g $(awk '$1==1' ../data/q1c_g${g}_spk.dat | wc -l) $(awk '$1==2' ../data/q1c_g${g}_spk.dat | wc -l)" >> $SCAN
  rm -f ../data/q1c_g${g}_*.dat
done
# rodadas finais (as que geram as figuras)
./rede_EIO q1a 3   0.05          # 1a: E->I, J0 = 3 uA/cm2, g_EI = 0,05
./rede_EIO q1b 2   0.10          # 1b: I->E, J0 = 2 uA/cm2, g_IE = 0,10
for g in 0.10 0.12 0.14 0.16 0.18 0.20 0.22 0.24 0.26 0.28; do
  ./rede_EIO q1c 1.5 $g          # 1c/1d: degrau de 1,5 uA/cm2 (5-450 ms), 500 ms
done

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
