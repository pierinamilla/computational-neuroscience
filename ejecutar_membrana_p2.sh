#!/bin/bash
#Script para compilar y ejecutar ecuacion_membrana

echo "===Compilando programa Fortran"
gfortran -Wall -g -o p2_membrana ecuacion_membrana.f90
if [ $? -eq 0 ]; then
	echo "Compilación exitosa"
	echo ""
	echo "Ejecutando simulación"
	./p2_membrana
	echo ""
	echo "Simulación completada"
	echo "Resultados guardados en p2_potencial_membrana.txt"

	#Verifico que existe el archivo
	if [ -f "p2_potencial_membrana.txt" ]; then
		echo "===Generando gráfico"

		#Archivo gnuplot para graficar
		cat > p2_graficar.gp << 'EOF' #EOF:End Of File

set terminal pngcairo size 800,600
set output 'p2_potencial_membrana.png'
set title "Absolute membrane potential vs time"
set xlabel "Time(ms)"
set ylabel "Vm(mV)"
set grid
plot 'p2_potencial_membrana.txt' using 2:3 with lines title 'Vm(t)'
EOF

            #Ejecutar gnuplot
	    gnuplot p2_graficar.gp

	    #Limpiar script temporal
	    rm -f graficar.gp

	    echo "Gráfico generado: potencial_membrana.png"
	    echo ""

	    #Abrir el gráfico
	    eog p2_potencial_membrana.png
    else
	    echo "Error: No se generó el archivo de resultados"
	    exit 1
    fi    
else
        echo "Error en la compilación"
        exit 1
fi

echo ""
echo "==Proceso completado=="
