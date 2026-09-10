# plot_q1.gp - Gráficos de la Pregunta 1
 
set terminal pngcairo size 900,900 enhanced font 'Arial,11'
set output 'plots/q1.png'

# Estilo general
set grid
set xlabel 't (ms)'
set title 'Questão 1: Estado de reposo'

# Layout: dos paneles apilados verticalmente
set multiplot layout 3,1

#V(t)
set ylabel 'V (mV)'
plot 'data/hh_q1.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

#Panel inferior: n, m, h
set ylabel 'Variables de compuerta'
unset title
plot 'data/hh_q1.dat' using 1:3 with lines lw 1.5 lc rgb 'blue'   title 'n', \
     'data/hh_q1.dat' using 1:4 with lines lw 1.5 lc rgb 'orange' title 'm', \
     'data/hh_q1.dat' using 1:5 with lines lw 1.5 lc rgb 'green'  title 'h'

set ylabel 'J (uA/cm²)'
plot 'data/hh_q1.dat' using 1:6 with lines lw 1.5 lc rgb 'red' title 'J'
unset multiplot
