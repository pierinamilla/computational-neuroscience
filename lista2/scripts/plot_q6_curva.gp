# plot_q6_curva.gp - Curva L vs J2

set terminal pngcairo size 900,600 enhanced font 'Arial,12'
set output 'plots/q6_L_vs_J2.png'

set grid
set xlabel "J2 ({/Symbol m}A/cm^2)"
set ylabel "L_{min} (ms)"
set title "Q6: latencia minima para el 2do disparo" font 'Arial,14'
set logscale x
set xrange [80:4000]
set yrange [0:3]

# Linea horizontal en el PR absoluto
set arrow from 80, 1.7441 to 4000, 1.7441 nohead lc rgb 'gray' dt 2 lw 1
set label "PR absoluto = 1.7441 ms" at 150, 1.85 font 'Arial,10' tc rgb 'gray'

plot 'data/q6_curva_LvsJ2.dat' using 1:2 with linespoints lw 2 pt 7 ps 1.5 lc rgb '#D62728' title 'L_{min}(J_2)'
