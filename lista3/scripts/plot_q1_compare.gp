# plot_q1_compare.gp - Comparación de V(t) y b(t) para cinética normal vs lenta

set terminal pngcairo size 1100,900 enhanced font 'Arial,12'
set output 'plots/q1_compare.png'

set multiplot layout 3,2 title "Q1: cinética normal de b vs b 4 veces más lenta (J = 15)" font 'Arial,13'

# --- Fila 1: V(t) ---
set grid
set xlabel ""
set ylabel "V (mV)"
set xrange [0:500]
set yrange [-90:60]
set title "Normal" font 'Arial,11'
unset key
plot 'data/q1_compare_norm.dat' using 1:2 w l lw 1.2 lc rgb 'black'

set title "b lento (x0.25)" font 'Arial,11'
plot 'data/q1_compare_slow.dat' using 1:2 w l lw 1.2 lc rgb 'black'

# --- Fila 2: b(t) ---
set ylabel "b (gating de I_A)"
set yrange [0:1]
set title ""
plot 'data/q1_compare_norm.dat' using 1:7 w l lw 1.5 lc rgb 'purple'

plot 'data/q1_compare_slow.dat' using 1:7 w l lw 1.5 lc rgb 'purple'

# --- Fila 3: J(t) ---
set xlabel "t (ms)"
set ylabel "J ({/Symbol m}A/cm^2)"
set yrange [-1:20]
plot 'data/q1_compare_norm.dat' using 1:8 w l lw 1.5 lc rgb 'red'

set xlabel "t (ms)"
plot 'data/q1_compare_slow.dat' using 1:8 w l lw 1.5 lc rgb 'red'

unset multiplot
unset output
