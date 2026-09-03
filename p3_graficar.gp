# graficar_todos.gp
set terminal pngcairo size 1000,700 enhanced
set output 'comparacion_gm.png'
set title "Potencial de Membrana vs Tiempo para diferentes Gm"
set xlabel "Tiempo (ms)"
set ylabel "Vm (mV)"
set grid
set key outside right

# Graficar todos los archivos
plot for [gm in "200 100 50 20 10"] \
     sprintf("p3_potencial_membrana_gm%s_dt1.0.txt", gm) \
     using 2:3 with lines title sprintf("Gm = %s uS/cm2", gm)
