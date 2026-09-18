# plot_q1b.gp - un PNG por cada J

set terminal pngcairo size 1000,900 enhanced font 'Arial,11'

# Variable con el valor de J, se pasa por línea de comandos
if (!exists("Jval")) Jval = 10

set output 'plots/q1b_J'.Jval.'.png'

set multiplot layout 3,1 title "Connor-Stevens: J = ".Jval." {/Symbol m}A/cm^2" font 'Arial,13'

# --- Panel 1: V(t) ---
set grid
set xlabel ""
set ylabel "V (mV)"
set xrange [0:200]
set yrange [-90:60]
unset key
plot 'data/q1b_J'.Jval.'.dat' using 1:2 w l lw 1.5 lc rgb 'black' title 'V'

# --- Panel 2: gating ---
set ylabel "Gating"
set yrange [0:1]
set key outside right
plot 'data/q1b_J'.Jval.'.dat' using 1:3 w l lw 1.5 lc rgb 'blue'   title 'n', \
     'data/q1b_J'.Jval.'.dat' using 1:4 w l lw 1.5 lc rgb 'red'    title 'm', \
     'data/q1b_J'.Jval.'.dat' using 1:5 w l lw 1.5 lc rgb 'green'  title 'h', \
     'data/q1b_J'.Jval.'.dat' using 1:6 w l lw 1.5 lc rgb 'orange' title 'a', \
     'data/q1b_J'.Jval.'.dat' using 1:7 w l lw 1.5 lc rgb 'purple' title 'b'

# --- Panel 3: J(t) ---
set xlabel "t (ms)"
set ylabel "J ({/Symbol m}A/cm^2)"
set yrange [-1:25]
unset key
plot 'data/q1b_J'.Jval.'.dat' using 1:8 w l lw 1.5 lc rgb 'red' title 'J'

unset multiplot
unset output
