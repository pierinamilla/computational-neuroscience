# plot_q7.gp - Graficos de la Pregunta 7

# ============================================================
# GRAFICO 1: Atraso del PA vs duracion T
# ============================================================
set terminal pngcairo size 900,600 enhanced font 'Arial,12'
set output 'plots/q7_atraso.png'

set grid
set xlabel "T (ms)"
set ylabel "Atraso do PA (ms)"
set title "Q7: atraso do PA apos fim do pulso hiperpolarizante" font 'Arial,14'
set xrange [0.3:5.2]
set yrange [6:10]

plot 'data/q7_T_vs_resultado.dat' using ($2 > 0.5 ? $1 : 1/0):($2 > 0.5 ? $4 : 1/0) \
     with linespoints lw 2 pt 7 ps 1.5 lc rgb '#1F77B4' title 'Atraso'

# ============================================================
# GRAFICO 2: Vmax post-pulso vs duracion T
# ============================================================
set output 'plots/q7_vmax.png'

set xlabel "T (ms)"
set ylabel "V_{max}^{post} (mV)"
set title "Q7: pico maximo post-pulso vs duracao T" font 'Arial,14'
set xrange [0.3:5.2]
unset yrange

plot 'data/q7_T_vs_resultado.dat' using 1:5 \
     with linespoints lw 2 pt 7 ps 1.5 lc rgb '#D62728' title 'V_{max}^{post}'

# ============================================================
# GRAFICO 3: Casos ilustrativos (sin PA y con PA)
# ============================================================
set output 'plots/q7_casos.png'
set xrange [0:30]
unset yrange
set multiplot layout 2,2 title "Q7: estimulacion por ruptura de anodo (J=-15)" font 'Arial,14'

# --- Caso 1: T = 1.0 ms (sin PA) ---
set ylabel "V (mV)"
set title "T = 1.0 ms (sin PA)" font 'Arial,11'
set xlabel ""
plot 'data/q7_sin_PA.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
set title ""
set xlabel ""
plot 'data/q7_sin_PA.dat' using 1:3 with lines lw 1.5 lc rgb 'red' title 'J(t)'

# --- Caso 2: T = 1.5 ms (con PA) ---
set ylabel "V (mV)"
set title "T = 1.5 ms (con PA)" font 'Arial,11'
set xlabel "t (ms)"
plot 'data/q7_con_PA.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
set title ""
set xlabel "t (ms)"
plot 'data/q7_con_PA.dat' using 1:3 with lines lw 1.5 lc rgb 'red' title 'J(t)'

unset multiplot
