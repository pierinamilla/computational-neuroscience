#!/bin/bash
#Script para buscar el umbral de J para cada dJ independientemente

#Ir a la raiz del proyecto
cd "$(dirname "$0")/.."
ROOT=$(pwd)

echo "Busqueda del umbral de J"

#Parametros
valores_dJ='0.5 0.05 0.01 0.005'
J_inicial='2'
J_final='20'
valor_ti='10'   #ms
valor_tf='10.5' #ms

#Configuracion
fuente="src/hhmodel_spike.f90"
eje="bin/hh_model"
archivo_datos="data/buscando_potencial_accion.txt"

#Crear carpetas si no existen
mkdir -p bin data plots

#Compilar una sola vez
echo "Compilando..."
gfortran -O3 -Wall -o $eje $fuente || exit 1

#Limpiar archivo de datos
> $archivo_datos

echo "Busqueda del umbral - Pulso [$valor_ti, $valor_tf] ms" >> $archivo_datos
echo "======================================" >> $archivo_datos

#------------------------------------------------------------
#Funcion: prueba un J, devuelve 0 si SPIKE, 1 si NO SPIKE
#------------------------------------------------------------
probar_J() {
    local J=$1
    local resultado

    resultado=$($eje $J $valor_ti $valor_tf 2>/dev/null)

    case "$resultado" in
        "SPIKE")
            echo "  J=$J -> SPIKE" >> $archivo_datos
            cp hh_q2.dat data/q2_spike.dat
            return 0
            ;;
        "NO SPIKE")
            echo "  J=$J -> NO SPIKE" >> $archivo_datos
            cp hh_q2.dat data/q2_no_spike.dat
            return 1
            ;;
        *)
            echo "  J=$J -> SALIDA INESPERADA: '$resultado'" >> $archivo_datos
            return 2
            ;;
    esac
}

#------------------------------------------------------------
#Bucle principal: para cada dJ, busqueda completa
#------------------------------------------------------------
for dJ in $valores_dJ; do
    echo "" >> $archivo_datos
    echo "======================================" >> $archivo_datos
    echo "dJ = $dJ" >> $archivo_datos
    echo "======================================" >> $archivo_datos

    echo ""
    echo ">>> Probando dJ = $dJ"

    J_prev=$J_inicial
    ENCONTRADO=0
    J=$J_inicial

    #Recorrer el rango completo con este dJ
    while awk "BEGIN{exit !($J <= $J_final)}"; do
        if probar_J $J; then
            echo "" >> $archivo_datos
            echo "  Intervalo final para dJ=$dJ: [$J_prev, $J]" >> $archivo_datos
            ENCONTRADO=1
            break
        fi
        J_prev=$J
        J=$(echo "$J + $dJ" | bc -l)
    done

    if [ $ENCONTRADO -eq 0 ]; then
        echo "  No se encontro disparo en [$J_inicial, $J_final] con dJ=$dJ" >> $archivo_datos
    fi
done

#------------------------------------------------------------
#Resumen final
#------------------------------------------------------------
echo "" >> $archivo_datos
echo "======================================" >> $archivo_datos
echo "RESUMEN DE RESULTADOS" >> $archivo_datos
echo "======================================" >> $archivo_datos

#Volver a recorrer para extraer los intervalos finales
for dJ in $valores_dJ; do
    intervalo=$(grep "Intervalo final para dJ=$dJ" $archivo_datos | tail -1)
    echo "dJ=$dJ : $intervalo" >> $archivo_datos
done

echo ""
echo "Busqueda terminada. Resultado en $archivo_datos"

#------------------------------------------------------------
#Graficos finales (del ultimo dJ que encontro disparo)
#------------------------------------------------------------
echo ""
echo "Generando graficos..."

if [ -f data/q2_no_spike.dat ]; then
    sed "s|data/hh_q2.dat|data/q2_no_spike.dat|; s|plots/q2.png|plots/q2_no_spike.png|" \
        scripts/plot_q2.gp > /tmp/plot_nospike.gp
    gnuplot /tmp/plot_nospike.gp
fi

if [ -f data/q2_spike.dat ]; then
    sed "s|data/hh_q2.dat|data/q2_spike.dat|; s|plots/q2.png|plots/q2_spike.png|" \
        scripts/plot_q2.gp > /tmp/plot_spike.gp
    gnuplot /tmp/plot_spike.gp
fi

echo "Graficos guardados en plots/"
