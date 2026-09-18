# plot_q2a.gp - Simulación individual (750 ms con escalón)

set terminal pngcairo size 1000,1100 enhanced font 'Arial,12'
set output 'plots/q2a.png'

# Ajusta aquí el nombre del archivo si usaste otro I_base / I_step
infile = 'data/q2a_Ib-100_Is50.dat'

set multiplot layout 4,1 title "Q2a: neurona de relé talámico (I_base=-100 pA, I_step=+50 pA)" font 'Arial,13'

# --- V(t) ---
set grid
set xlabel ""
set ylabel "V (mV)"
set xrange [0:750]
unset key
plot infile using 1:2 w l lw 1.5 lc rgb 'black' title 'V'

# --- h(t) ---
set ylabel "h (Na inactivation)"
set yrange [0:1]
plot infile using 1:3 w l lw 1.5 lc rgb 'green' title 'h'

# --- n(t) ---
set ylabel "n (K activation)"
set yrange [0:1]
plot infile using 1:4 w l lw 1.5 lc rgb 'blue' title 'n'

# --- h_T(t) ---
set xlabel "t (ms)"
set ylabel "h_T (Ca,T inactivation)"
set yrange [0:1]
plot infile using 1:5 w l lw 1.5 lc rgb 'purple' title 'h_T'

unset multiplot
unset output
