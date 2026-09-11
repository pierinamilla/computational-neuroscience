#!/bin/bash
# Script para encontrar los 4 valores de J de la Pregunta 4

cd "$(dirname "$0")/.."

echo "Busqueda de los 4 valores de J - Pregunta 4"

eje="bin/hh_model"
archivo_datos="data/q4_busqueda.txt"

# Parametros del degrau
t_total=500
dt=0.025
tj_i=50
tj_f=450

> $archivo_datos
echo "Pregunta 4: degrau [$tj_i, $tj_f] ms, dt=$dt, t_total=$t_total" >> $archivo_datos
echo "======================================" >> $archivo_datos

#------------------------------------------------------------
# Funcion que corre el modelo y devuelve el numero de spikes
#------------------------------------------------------------
contar_spikes() {
    local J=$1
    local n
    n=$($eje $J $t_total $dt $tj_i $tj_f 2>/dev/null | grep "SPIKES:" | awk '{print $2}')
    echo "$n"
}

#------------------------------------------------------------
# 1) Reobase: menor J con al menos 1 spike
#------------------------------------------------------------
echo "" >> $archivo_datos
echo "=== 1) Reobase ===" >> $archivo_datos

for J in 1 6 11 16 20; do
    n=$(contar_spikes $J)
    echo "J=$J -> $n spikes" >> $archivo_datos
done

#------------------------------------------------------------
# 2) Dos disparos
#------------------------------------------------------------
echo "" >> $archivo_datos
echo "=== 2) Dos disparos ===" >> $archivo_datos

for J in 5 6 7 8 10 12 15 18 20; do
    n=$(contar_spikes $J)
    echo "J=$J -> $n spikes" >> $archivo_datos
done

#------------------------------------------------------------
# 3) Tren de disparos (muchos spikes)
#------------------------------------------------------------
echo "" >> $archivo_datos
echo "=== 3) Tren de disparos ===" >> $archivo_datos

for J in 10 15 20 25 30 40 50; do
    n=$(contar_spikes $J)
    echo "J=$J -> $n spikes" >> $archivo_datos
done

echo ""
echo "Busqueda terminada. Resultado en $archivo_datos"
