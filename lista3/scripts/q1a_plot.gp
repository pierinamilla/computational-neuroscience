set terminal pngcairo size 1000,700 enhanced font 'Arial,12'
set output 'plots/q1a_gating.png'
set multiplot layout 1,2 title "Connor-Stevens: X_∞(V) y τ_X(V)" font 'Arial,14'

set grid
set xlabel "V (mV)"
set ylabel "X_∞"
set xrange [-100:100]
set yrange [0:1]
plot 'data/q1a_curvas.dat' using 1:2 w l lw 2 lc rgb 'blue'   title 'n_∞', \
     'data/q1a_curvas.dat' using 1:3 w l lw 2 lc rgb 'red'    title 'm_∞', \
     'data/q1a_curvas.dat' using 1:4 w l lw 2 lc rgb 'green'  title 'h_∞', \
     'data/q1a_curvas.dat' using 1:5 w l lw 2 lc rgb 'orange' title 'a_∞', \
     'data/q1a_curvas.dat' using 1:6 w l lw 2 lc rgb 'purple' title 'b_∞'

set ylabel "τ_X (ms)"
set yrange [0:10]
plot 'data/q1a_curvas.dat' using 1:7 w l lw 2 lc rgb 'blue'   title 'τ_n', \
     'data/q1a_curvas.dat' using 1:8 w l lw 2 lc rgb 'red'    title 'τ_m', \
     'data/q1a_curvas.dat' using 1:9 w l lw 2 lc rgb 'green'  title 'τ_h', \
     'data/q1a_curvas.dat' using 1:10 w l lw 2 lc rgb 'orange' title 'τ_a', \
     'data/q1a_curvas.dat' using 1:11 w l lw 2 lc rgb 'purple' title 'τ_b'

unset multiplot
