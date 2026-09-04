#!/bin/bash
echo "----------------------------------"
echo "Pregunta 4: Manejar data en unidades SI"
echo "Ecuación de la membrana en Sistema Internacional"
echo "----------------------------------"
echo ""

#Configuración

fuente="ecuacion_membrana_si.f90"
ejecutable="membrana_si"
resultados="potencial_membrana_si.txt"
grafico="potencial_membrana_p4.png"

#Verificar que existe el codigo fuente
if [ ! -f "$fuente" ]; then
	echo "Error: No se encuentra $fuente"
	exit 1
fi

echo "Codigo fuente: $fuente"
echo ""

#Compilar
echo "Compilando..."
gfortran -Wall -g -o $ejecutable $fuente

if [ $? -ne 0 ]; then
	echo "Error en la compilación"
	exit 1
fi

echo "Compilación exitosa"
echo ""

#Ejecutar
echo "Ejecutando simulación en SI"
./$ejecutable

if [ $? -ne 0 ]; then
	echo "Error en la ejecución"
	exit 1
fi
echo "Simulación completada"
echo ""

#Verificar resultados
if [ ! -f "$resultados" ]; then
	echo "Error: No se generó $resultados"
	exit 1
fi

echo "Resultados guardados en: $resultados"
echo ""

#Generar gráfico
echo "Generando gráfico"

cat > graficar_p4.gp << 'EOF'
set terminal pngcairo size 1000,700 enhanced font 'Arial,12'
set output "potencial_membrana_p4.png"
set title "Membrana Absolute Potential vs Time"
set xlabel "Time (ms)"
set ylabel "Vm (mV)"
set grid
set key outside right

# Los datos están en SI (segundos, volts), convertimos a ms y mV
plot 'potencial_membrana_si.txt' using ($2*1000):($3*1000) with lines lw 2 title 'Vm(t) (SI)'
EOF

gnuplot graficar_p4.gp

if [ $? -ne 0 ]; then
    echo "Error al generar el gráfico"
    exit 1
fi

# Limpiar script temporal
rm -f graficar_p4.gp

echo "Gráfico generado"
echo ""

eog $grafico








