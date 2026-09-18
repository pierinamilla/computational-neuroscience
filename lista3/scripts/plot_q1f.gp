# plot_q1f.gp - b inactivation reduced (x0.25), J = 15

set terminal pngcairo size 1000,900 enhanced font 'Arial,12'
set output 'plots/q1f.png'

set multiplot layout 3,1 title "Q1f: inactivación de I_A 4 veces más lenta, J = 15 {/Symbol m}A/cm^2" font 'Arial,13'

# --- V(t) ---
set grid
set xlabel ""
set ylabel "V (mV)"
set xrange [0:300]
set yrange [-90:60]
unset key
plot 'data/q1f.dat' using 1:2 w l lw 1.2 lc rgb 'black' title 'V'

# --- Gating ---
set ylabel "Gating"
set yrange [0:1]
set key outside right
plot 'data/q1f.dat' using 1:3 w l lw 1.2 lc rgb 'blue'   title 'n', \
     'data/q1f.dat' using 1:4 w l lw 1.2 lc rgb 'red'    title 'm', \
     'data/q1f.dat' using 1:5 w l lw 1.2 lc rgb 'green'  title 'h', \
     'data/q1f.dat' using 1:6 w l lw 1.2 lc rgb 'orange' title 'a', \
     'data/q1f.dat' using 1:7 w l lw 1.2 lc rgb 'purple' title 'b'

# --- J(t) ---
set xlabel "t (ms)"
set ylabel "J ({/Symbol m}A/cm^2)"
set yrange [-1:20]
unset key
plot 'data/q1f.dat' using 1:8 w l lw 1.5 lc rgb 'red' title 'J'

unset multiplot
unset output
