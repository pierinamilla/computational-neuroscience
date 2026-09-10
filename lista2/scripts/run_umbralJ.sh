#!/bin/bash
#Script para buscar el umbral de J iterando con varios pasos dJ

#Ir a la raiz del proyecto
cd "$(dirname "$0")/.."
ROOT=$(pwd)

echo "Busqueda del umbral de J"

#Parametros
valores_dJ='0.5 0.05 0.01 0.005'
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
            echo "J=$J -> SPIKE" >> $archivo_datos
            return 0
            ;;
        "NO SPIKE")
            echo "J=$J -> NO SPIKE" >> $archivo_datos
            return 1
            ;;
        *)
            echo "J=$J -> SALIDA INESPERADA: '$resultado'" >> $archivo_datos
            return 2
            ;;
    esac
}

#------------------------------------------------------------
#Funcion: refina un intervalo [J_lo, J_hi] con paso dJ
#Devuelve el nuevo intervalo en NUEVO_LO y NUEVO_HI
#------------------------------------------------------------
refinar() {
    local J_lo=$1
    local J_hi=$2
    local dJ=$3
    local J
    local J_prev=$J_lo

    echo "" >> $archivo_datos
    echo "--- Nivel paso $dJ : [$J_lo, $J_hi] ---" >> $archivo_datos

    J=$J_lo
    while awk "BEGIN{exit !($J <= $J_hi)}"; do
        if probar_J $J; then
            #Primer J que dispara
            NUEVO_LO=$J_prev
            NUEVO_HI=$J
            return 0
        fi
        J_prev=$J
        J=$(echo "$J + $dJ" | bc -l)
    done

    #Si llegamos aqui, ningun J disparo
    NUEVO_LO=$J_lo
    NUEVO_HI=$J_hi
    return 1
}

#------------------------------------------------------------
#Nivel 0: busqueda gruesa de 2 a 20 con paso 2
#------------------------------------------------------------
echo "" >> $archivo_datos
echo "=== NIVEL 0: paso 2 ===" >> $archivo_datos

J_prev=0
ENCONTRADO=0
for J in 2 4 6 8 10 12 14 16 18 20; do
    if probar_J $J; then
        NUEVO_LO=$J_prev
        NUEVO_HI=$J
        ENCONTRADO=1
        break
    fi
    J_prev=$J
done

if [ $ENCONTRADO -eq 0 ]; then
    echo "No se encontro disparo hasta J=20. Aumenta el rango." >> $archivo_datos
    exit 1
fi

echo "" >> $archivo_datos
echo "Intervalo nivel 0: [$NUEVO_LO, $NUEVO_HI]" >> $archivo_datos

#------------------------------------------------------------
#Niveles sucesivos de refinamiento
#------------------------------------------------------------
for dJ in $valores_dJ; do
    J_lo=$NUEVO_LO
    J_hi=$NUEVO_HI

    #Verificar ancho del intervalo
    ancho=$(echo "$J_hi - $J_lo" | bc -l)
    if awk "BEGIN{exit !($ancho < $dJ)}"; then
        echo "Intervalo [$J_lo, $J_hi] mas estrecho que dJ=$dJ. Deteniendo." >> $archivo_datos
        break
    fi

    if ! refinar $J_lo $J_hi $dJ; then
        echo "refinar fallo con dJ=$dJ en [$J_lo, $J_hi]" >> $archivo_datos
        break
    fi

    echo "Intervalo nivel $dJ: [$NUEVO_LO, $NUEVO_HI]" >> $archivo_datos
done

#------------------------------------------------------------
#Resultado final
#------------------------------------------------------------
echo "" >> $archivo_datos
echo "======================================" >> $archivo_datos
echo "UMBRAL FINAL: entre $NUEVO_LO y $NUEVO_HI uA/cm^2" >> $archivo_datos
echo "NO dispara con J = $NUEVO_LO" >> $archivo_datos
echo "SI dispara con J = $NUEVO_HI" >> $archivo_datos

echo ""
echo "Busqueda terminada. Resultado en $archivo_datos"
echo "Umbral: [$NUEVO_LO, $NUEVO_HI]"
