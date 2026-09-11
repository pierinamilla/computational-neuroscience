#!/bin/bash
# Script para generar los 4 casos de la Pregunta 4, verificar y graficar

# Ir a la raiz del proyecto
cd "$(dirname "$0")/.."

# Parametros del degrau
t_total="500"
dt="0.025"
ti="50"
tf="450"

# Valores de J para cada caso
J_no_spike="2.23"
J_reobase="2.24"
J_dos="5.90"
J_tren="6.19"

# Crear plot_q4.gp si no existe y limpiar CR
if [ ! -f scripts/plot_q4.gp ]; then
    cp scripts/plot_q2.gp scripts/plot_q4.gp
fi
sed -i 's/\r$//' scripts/plot_q4.gp

#------------------------------------------------------------
# 1) Generar los 4 .dat
#------------------------------------------------------------
echo "=== Generando datos ==="

./bin/hh_model $J_no_spike $t_total $dt $ti $tf
mv data/data_spike.txt data/q4_i_no_spike.dat

./bin/hh_model $J_reobase $t_total $dt $ti $tf
mv data/data_spike.txt data/q4_ii_reobase.dat

./bin/hh_model $J_dos $t_total $dt $ti $tf
mv data/data_spike.txt data/q4_iii_dos.dat

./bin/hh_model $J_tren $t_total $dt $ti $tf
mv data/data_spike.txt data/q4_iv_tren.dat

echo "Datos generados en data/"

#------------------------------------------------------------
# 2) Verificar picos
#------------------------------------------------------------
echo ""
echo "=== Verificacion de picos ==="

for f in q4_i_no_spike q4_ii_reobase q4_iii_dos q4_iv_tren; do
    n=$(awk 'prev < 0 && $2 >= 0 {c++} {prev=$2} END {print c+0}' data/$f.dat)
    echo "$f: $n picos"
done

#------------------------------------------------------------
# 3) Generar los 4 graficos
#------------------------------------------------------------
echo ""
echo "=== Generando graficos ==="

gnuplot -e "archivo_in='data/q4_i_no_spike.dat'; \
            archivo_out='plots/q4_i_no_spike.png'; \
            titulo_global='Q4 (i): J = ${J_no_spike} uA/cm2 (no spikes)'" \
        scripts/plot_q4.gp

gnuplot -e "archivo_in='data/q4_ii_reobase.dat'; \
            archivo_out='plots/q4_ii_reobase.png'; \
            titulo_global='Q4 (ii): J = ${J_reobase} uA/cm2 (rheobase)'" \
        scripts/plot_q4.gp

gnuplot -e "archivo_in='data/q4_iii_dos.dat'; \
            archivo_out='plots/q4_iii_dos.png'; \
            titulo_global='Q4 (iii): J = ${J_dos} uA/cm2 (2 spikes)'" \
        scripts/plot_q4.gp

gnuplot -e "archivo_in='data/q4_iv_tren.dat'; \
            archivo_out='plots/q4_iv_tren.png'; \
            titulo_global='Q4 (iv): J = ${J_tren} uA/cm2 (spike train)'" \
        scripts/plot_q4.gp

echo "Graficos generados en plots/"

#------------------------------------------------------------
# 4) Abrir los 4 graficos
#------------------------------------------------------------
echo ""
echo "=== Abriendo graficos ==="

eog plots/q4_i_no_spike.png &
eog plots/q4_ii_reobase.png &
eog plots/q4_iii_dos.png &
eog plots/q4_iv_tren.png &

echo "Listo."
