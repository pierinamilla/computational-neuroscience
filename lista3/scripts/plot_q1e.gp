# plot_q1e.gp - pulso negativo + corriente positiva sostenida

set terminal pngcairo size 1000,900 enhanced font 'Arial,12'
set output 'plots/q1e.png'

set multiplot layout 3,1 title "Q1e: pulso -50 {/Symbol m}A/cm^2 (5 ms) + J = +20 {/Symbol m}A/cm^2" font 'Arial,13'

# --- Panel 1: V(t) ---
set grid
set xlabel ""
set ylabel "V (mV)"
set xrange [0:200]
set yrange [-100:60]
unset key
plot 'data/q1e.dat' using 1:2 w l lw 1.5 lc rgb 'black' title 'V'

# --- Panel 2: gating ---
set ylabel "Gating"
set yrange [0:1]
set key outside right
plot 'data/q1e.dat' using 1:3 w l lw 1.5 lc rgb 'blue'   title 'n', \
     'data/q1e.dat' using 1:4 w l lw 1.5 lc rgb 'red'    title 'm', \
     'data/q1e.dat' using 1:5 w l lw 1.5 lc rgb 'green'  title 'h', \
     'data/q1e.dat' using 1:6 w l lw 1.5 lc rgb 'orange' title 'a', \
     'data/q1e.dat' using 1:7 w l lw 1.5 lc rgb 'purple' title 'b'

# --- Panel 3: J(t) ---
set xlabel "t (ms)"
set ylabel "J ({/Symbol m}A/cm^2)"
set yrange [-60:30]
unset key
plot 'data/q1e.dat' using 1:8 w l lw 1.5 lc rgb 'red' title 'J'

unset multiplot
unset output
