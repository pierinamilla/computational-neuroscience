# plot_q1cd.gp - Curvas f-I: método directo vs latencia

set terminal pngcairo size 900,600 enhanced font 'Arial,12'
set output 'plots/q1cd_fI.png'

set grid
set xlabel "J ({/Symbol m}A/cm^2)"
set ylabel "f (Hz)"
set title "Connor-Stevens: curva f-I" font 'Arial,14'
set xrange [7.8:10.2]
set yrange [0:*]

plot 'data/q1c_fI_direct.dat'  using 1:2 w lp lw 2 pt 7 ps 1.4 lc rgb '#1F77B4' title 'Método directo', \
     'data/q1d_fI_latency.dat' using 1:2 w lp lw 2 pt 5 ps 1.4 lc rgb '#D62728' title 'Método latencia'
