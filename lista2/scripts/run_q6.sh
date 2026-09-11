#!/bin/bash
# Pregunta 6: periodos refractarios del modelo HH

cd "$(dirname "$0")/.."

eje="bin/hh_dospulsos"
T=100
dt=0.001
t1=10
dur=0.5
J1=100.0

archivo="data/q6_resultados.txt"
> $archivo

# ------------------------------------------------------------
# Funcion: dado L y J2, devuelve 0 si hay spike del 2do pulso
# ------------------------------------------------------------
hay_spike() {
    local L=$1
    local J2=$2
    local out nsp
    out=$($eje $J1 $J2 $T $dt $t1 $dur $L 2>/dev/null)
    nsp=$(echo "$out" | awk '{print $1}')
    if [ "$nsp" -ge 1 ]; then
        return 0
    else
        return 1
    fi
}

# ------------------------------------------------------------
# PR relativo (J2 = J1)
# ------------------------------------------------------------
echo "=== PR relativo (J2 = J1 = $J1) ===" | tee -a $archivo

L_rel_lo=""
L_rel_hi=""

L=20.0
while awk "BEGIN{exit !($L >= 0.1)}"; do
    if hay_spike $L $J1; then
        L_rel_hi=$L
    else
        L_rel_lo=$L
        break
    fi
    L=$(echo "$L - 0.5" | bc -l)
done

if [ -z "$L_rel_lo" ]; then
    echo "No se encontro transicion hasta L=0.1" | tee -a $archivo
    L_relativo=0.1
else
    echo "Intervalo grueso: [$L_rel_lo, $L_rel_hi]" | tee -a $archivo
    for paso in 0.05 0.005 0.0005; do
        L=$L_rel_lo
        L_prev=$L_rel_lo
        while awk "BEGIN{exit !($L <= $L_rel_hi + 0.0001)}"; do
            if hay_spike $L $J1; then
                L_rel_hi=$L
                break
            fi
            L_prev=$L
            L=$(echo "$L + $paso" | bc -l)
        done
        L_rel_lo=$L_prev
        echo "Refinamiento paso $paso: [$L_rel_lo, $L_rel_hi]" | tee -a $archivo
    done
    L_relativo=$L_rel_hi
fi

# ------------------------------------------------------------
# PR absoluto (J2 grande)
# ------------------------------------------------------------
echo "" | tee -a $archivo
echo "=== PR absoluto (J2 muy grande) ===" | tee -a $archivo

J2_list="20 50 100 200 500 1000 2000"
L_abs_lo=0.0
L_abs_hi=5.0

L=0.5
while awk "BEGIN{exit !($L <= 5.0)}"; do
    disparo=0
    for J2p in $J2_list; do
        if hay_spike $L $J2p; then
            disparo=1
            break
        fi
    done
    echo "L=$L -> disparo? $disparo" | tee -a $archivo
    if [ $disparo -eq 1 ]; then
        L_abs_hi=$L
        break
    else
        L_abs_lo=$L
    fi
    L=$(echo "$L + 0.5" | bc -l)
done

for paso in 0.05 0.01 0.002; do
    L=$L_abs_lo
    L_prev=$L_abs_lo
    while awk "BEGIN{exit !($L <= $L_abs_hi + 0.0001)}"; do
        disparo=0
        for J2p in $J2_list; do
            if hay_spike $L $J2p; then
                disparo=1
                break
            fi
        done
        if [ $disparo -eq 1 ]; then
            L_abs_hi=$L
            break
        fi
        L_prev=$L
        L=$(echo "$L + $paso" | bc -l)
    done
    L_abs_lo=$L_prev
done
L_absoluto=$L_abs_hi

# ------------------------------------------------------------
# Curva L vs J2
# ------------------------------------------------------------
echo "" | tee -a $archivo
echo "=== Curva L vs J2 ===" | tee -a $archivo

curva_archivo="data/q6_curva_LvsJ2.dat"
> $curva_archivo
echo "# J2  L_min" >> $curva_archivo

for J2p in 100 150 200 300 500 700 1000 1500 2000; do
    L=0.1
    L_min=""
    while awk "BEGIN{exit !($L <= 5.0)}"; do
        if hay_spike $L $J2p; then
            L_min=$L
            break
        fi
        L=$(echo "$L + 0.1" | bc -l)
    done

    if [ -z "$L_min" ]; then
        echo "# J2=$J2p no_dispara_hasta_L=5.0" >> $curva_archivo
    else
        L_lo=$(echo "$L_min - 0.1" | bc -l)
        L=$L_lo
        L_min=$L
        while awk "BEGIN{exit !($L <= $L_lo + 0.1)}"; do
            if hay_spike $L $J2p; then
                L_min=$L
                break
            fi
            L=$(echo "$L + 0.01" | bc -l)
        done
        echo "$J2p $L_min" >> $curva_archivo
        echo "J2=$J2p -> L_min=$L_min ms" | tee -a $archivo
    fi
done

# ------------------------------------------------------------
# Guardar dat para graficos ilustrativos
# ------------------------------------------------------------
echo "" | tee -a $archivo
echo "=== Generando .dat para graficos ilustrativos ===" | tee -a $archivo

# Caso dentro del PR absoluto: L muy chico, J2 muy grande
$eje $J1 1000 $T $dt $t1 $dur 0.3
mv data/dos_pulsos.dat data/q6_dentro_abs.dat

# Caso fuera del PR absoluto
L_fuera=$(echo "$L_absoluto + 0.3" | bc -l)
$eje $J1 1000 $T $dt $t1 $dur $L_fuera
mv data/dos_pulsos.dat data/q6_fuera_abs.dat

# Caso PR relativo
$eje $J1 $J1 $T $dt $t1 $dur $L_relativo
mv data/dos_pulsos.dat data/q6_relativo.dat

# ------------------------------------------------------------
# Resumen
# ------------------------------------------------------------
echo "" | tee -a $archivo
echo "======================================" | tee -a $archivo
echo "RESUMEN Q6" | tee -a $archivo
echo "J1 = $J1" | tee -a $archivo
echo "PR relativo (J2=J1):  $L_relativo ms" | tee -a $archivo
echo "PR absoluto (J2>>J1): $L_absoluto ms" | tee -a $archivo
echo "======================================" | tee -a $archivo

# Generar graficos
gnuplot scripts/plot_q6.gp
gnuplot scripts/plot_q6_casos.gp

# Ver
eog plots/q6_L_vs_J2.png &
eog plots/q6_casos.png &
