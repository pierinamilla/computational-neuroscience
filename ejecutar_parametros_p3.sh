#!/bin/bash
#Script para ejecutar simulaciones con diferentes parámetros

echo "-------------------------------"
echo "Simulaciones de ecuación de la  membrana con múltiples parámetros"
echo "_______________________________"
echo ""

#Parametros a probar
valores_gm='200 100 50 20 10' #Valores de conductancia especifica(uS/cm2)
valores_dt='1.0' #Valores de dt
#valores_cm='1.0' #Valores de conductancia especifica
#valores_J='2.0' #Valores de densidad de corriente

#Configuracion
fuente='p2_ecuacion_membrana.f90'
archivo_datos='potencial_membrana_completo.txt'

#Limpiar archivo de datos existente
> $archivo_datos

#Bucle principal
for dt in $valores_dt; do
	echo "Probando dt=$dt ms"

	for gm in $valores_gm; do
		echo " -> gm=$gm uS/cm2"

		#Copia temporal del codigo fuente
		copia_fuente='copia_fuente.f90'
		cp $fuente $copia_fuente

		#Modificar parámetros en la copia de archivo
		sed -i "s/dt=[0-9.]*/dt=$dt/g" $copia_fuente
		sed -i "s/Gm=[0-9.]*/Gm=$gm/g" $copia_fuente

		#Compilar
		gfortran -Wall -g -o copia_fuente_eje $copia_fuente

		#Ejecutar
		if [ $? -eq 0 ];then
			./copia_fuente_eje
			#Archivo de resultados
			mv p2_potencial_membrana.txt "p3_potencial_membrana_gm${gm}_dt${dt}.txt"
			#Escribir encabezado en el archivo general total
			echo "Gm=$gm dt=$dt" >> $archivo_datos
			echo "---" >> $archivo_datos
			cat "p3_potencial_membrana_gm${gm}_dt${dt}.txt" >> $archivo_datos
			echo "" >> $archivo_datos
		else
			echo "Error compilando para Gm=$gm, dt=$dt"

		fi

		#Limpiar archivo temporal

		rm -f $copia_fuente copia_fuente_eje
	done
        echo ""
done
echo "Todas las simulaciones completadas"
echo "Resultados guardados en:"
ls -la p3_potencial_membrana_gm*.txt
