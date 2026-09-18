# plot_q2b.gp - barrido 2D del modelo talámico

set terminal pngcairo size 1400,600 enhanced font 'Arial,12'
set output 'plots/q2b_heatmap.png'

set multiplot layout 1,2 title "Q2b: barrido 2D (I_base vs I_step)" font 'Arial,13'

set size square
set xlabel "I_base (pA)"
set ylabel "I_step (pA)"
set xrange [-225:225]
set yrange [-5:105]

# --- Panel 1: N spikes ---
set view map
unset surface
set pm3d
set cblabel "N"
set title "Número de disparos no degrau" font 'Arial,11'
set palette defined (0 "white", 5 "yellow", 15 "orange", 30 "red")
splot 'data/q2b_sweep.dat' using 1:2:(0):3 with pm3d

# --- Panel 2: ISI mínimo ---
set cblabel "ISI_min (ms)"
set title "Intervalo mínimo entre disparos" font 'Arial,11'
set palette defined (0 "dark-red", 5 "red", 15 "yellow", 30 "white")
splot 'data/q2b_sweep.dat' using 1:2:(0):($4 > 0 ? $4 : 1/0) with pm3d

unset multiplot
unset output
