# plot_fJ.gp - Curva f-J del modelo Hodgkin-Huxley

set terminal pngcairo size 900,600 enhanced font 'Arial,12'
set output 'plots/curva_fJ.png'

set grid
set xlabel "J (\\mu A/cm^2)"
set ylabel "Frequency (Hz)"
set title "f-J curve for the Hodgkin-Huxley model" font 'Arial,14'

# Filtra los puntos donde f > 0 (descarta los de bloqueo por despolarizacion)
plot 'data/curva_fJ.dat' using ($3 > 0 ? $1 : 1/0):($3 > 0 ? $3 : 1/0) \
     with linespoints lw 2 pt 7 ps 1.2 lc rgb '#D62728' title 'f-J'
