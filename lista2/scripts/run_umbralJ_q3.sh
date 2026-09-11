#!/bin/bash
# Script para buscar el umbral de J con refinamiento sucesivo

# Ir a la raíz del proyecto
cd "$(dirname "$0")/.."
ROOT=$(pwd)

# Duración del pulso (por defecto 0.5 ms)
DURACION=1 #${1:-0.5}

echo "  BUSQUEDA DEL UMBRAL DE J"
echo "  Duración del pulso: $DURACION ms"

# Parámetros
valores_dJ='2 0.5 0.01'
J_inicial='2'
J_final='20'
valor_ti='10'                          # ms
valor_tf=$(echo "$valor_ti + $DURACION" | bc)  # ms

# Configuración
fuente="src/hhmodel_spike.f90"
eje="bin/hh_model"
archivo_datos="data/data_spike_dur_${DURACION}ms.txt"

# Crear carpetas si no existen
mkdir -p bin data plots

# Compilar una sola vez
echo "Compilando..."
gfortran -O3 -Wall -o $eje $fuente || exit 1

# Limpiar archivo de datos
> $archivo_datos

echo "Busqueda del umbral - Pulso [$valor_ti, $valor_tf] ms" >> $archivo_datos
echo "======================================" >> $archivo_datos

#------------------------------------------------------------
# Funcion: prueba un J, devuelve 0 si SPIKE, 1 si NO SPIKE
#------------------------------------------------------------
probar_J() {
    local J=$1
    local resultado

    resultado=$($eje $J $valor_ti $valor_tf 2>/dev/null)

    if echo "$resultado" | grep -q "NO SPIKE"; then
        echo "  J=$J -> NO SPIKE" >> $archivo_datos
        cp data/data_spike.txt data/q3_no_spike.txt
        return 1
    elif echo "$resultado" | grep -q "SPIKE"; then
        echo "  J=$J -> SPIKE" >> $archivo_datos
        cp data/data_spike.txt data/q3_spike.txt
        return 0
    else
        echo "  J=$J -> SALIDA INESPERADA: '$resultado'" >> $archivo_datos
        return 2
    fi
}

#------------------------------------------------------------
# Bucle principal con refinamiento sucesivo
#------------------------------------------------------------
J_prev_global=$J_inicial
J_spike_global=$J_final

for dJ in $valores_dJ; do
    echo "" >> $archivo_datos
    echo "======================================" >> $archivo_datos
    echo "dJ = $dJ" >> $archivo_datos
    echo "======================================" >> $archivo_datos

    echo ""
    echo ">>> Probando dJ = $dJ (rango: [$J_prev_global, $J_spike_global])"

    # Empezar desde el último NO SPIKE conocido
    J=$J_prev_global
    J_prev=$J_prev_global
    ENCONTRADO=0

    # Recorrer el rango [J_prev_global, J_spike_global] con este dJ
    while awk "BEGIN{exit !($J <= $J_spike_global)}"; do
        if probar_J $J; then
            echo "" >> $archivo_datos
            echo "  Intervalo final para dJ=$dJ: [$J_prev, $J]" >> $archivo_datos
            ENCONTRADO=1
            
            # ✅ ACTUALIZAR el rango para el siguiente dJ
            J_prev_global=$J_prev
            J_spike_global=$J
            break
        fi
        J_prev=$J
        J=$(echo "$J + $dJ" | bc -l)
    done

    if [ $ENCONTRADO -eq 0 ]; then
        echo "  No se encontro disparo en [$J_prev_global, $J_spike_global] con dJ=$dJ" >> $archivo_datos
    fi
done

#------------------------------------------------------------
# Resumen final
#------------------------------------------------------------
echo "" >> $archivo_datos
echo "======================================" >> $archivo_datos
echo "RESUMEN DE RESULTADOS" >> $archivo_datos
echo "======================================" >> $archivo_datos

for dJ in $valores_dJ; do
    intervalo=$(grep "Intervalo final para dJ=$dJ" $archivo_datos | tail -1)
    echo "dJ=$dJ : $intervalo" >> $archivo_datos
done

echo ""
echo "Busqueda terminada. Resultado en $archivo_datos"

#------------------------------------------------------------
# Graficos finales
#------------------------------------------------------------
echo ""
echo "Generando graficos..."

if [ -f data/q3_no_spike.dat ]; then
    sed "s|data/hh_q3.dat|data/q3_no_spike.txt|; s|plots/q3.png|plots/q3_no_spike.png|" \
        scripts/plot_q3.gp > /tmp/plot_nospike.gp
    gnuplot /tmp/plot_nospike.gp
fi

if [ -f data/q3_spike.dat ]; then
    sed "s|data/hh_q3.dat|data/q3_spike.txt|; s|plots/q3.png|plots/q3_spike.png|" \
        scripts/plot_q3.gp > /tmp/plot_spike.gp
    gnuplot /tmp/plot_spike.gp
fi

# Caso NO SPIKE
gnuplot -e "archivo_in='data/q3_no_spike.txt'; \
            archivo_out='plots/q3_no_spike.png'; \
            titulo_global='Question 3: 1 ms pulse, J = 6.83 (no spike)'" \
        scripts/plot_q3.gp

# Caso SPIKE
gnuplot -e "archivo_in='data/q3_spike.txt'; \
            archivo_out='plots/q3_spike.png'; \
            titulo_global='Question 3: 1 ms pulse, J = 6.84 (spike)'" \
        scripts/plot_q3.gp

echo "Graficos generados en plots/"
eog plots/q3_no_spike.png &
eog plots/q3_spike.png &
