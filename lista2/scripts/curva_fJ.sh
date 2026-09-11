#!/bin/bash
# Script para construir la curva f-J de la Pregunta 5

cd "$(dirname "$0")/.."

eje="bin/hh_model"
salida="data/curva_fJ.dat"
t_total="500"
dt="0.025"
ti="50"
tf="450"

# Rango de J: desde 6.19 (tren minimo) hasta 50
valores_J="2.24 5.9 6.19 6.5 7 8 10 12 15 20 25 30 40 50 60 70 80 100"
> $salida
echo "# J  n_spikes  f(Hz)" >> $salida

for J in $valores_J; do
    resultado=$($eje $J $t_total $dt $ti $tf 2>/dev/null)
    n=$(echo "$resultado" | grep SPIKES | awk '{print $2}')
    f=$(echo "$resultado" | grep SPIKES | awk '{print $4}')
    echo "$J $n $f" >> $salida
    echo "J=$J -> $n spikes, f=$f Hz"
done

echo ""
echo "Curva f-J guardada en $salida"

gnuplot scripts/plot_fJ.gp
eog plots/curva_fJ.png &
