# plot_q2b.gp - Barrido 2D: número de spikes e ISI mínimo

set terminal pngcairo size 1200,600 enhanced font 'Arial,12'

# =====================================================
# Panel 1: Número de spikes
# =====================================================
set output 'plots/q2b_spikes.png'
set multiplot layout 1,2 title "Q2b: barrido 2D (I_base vs I_step)" font 'Arial,13'

set dgrid3d 30,30 gauss 0.5

set view 60,30,1.2,1.2
set xlabel "I_base (pA)"
set ylabel "I_step (pA)"
set zlabel "N spikes"
set title "Número de spikes" font 'Arial,11'
splot 'data/q2b_sweep.dat' using 1:2:3 with pm3d

# =====================================================
# Panel 2: ISI mínimo
# =====================================================
unset dgrid3d
set dgrid3d 30,30 gauss 0.5
set zlabel "ISI_min (ms)"
set title "ISI mínimo" font 'Arial,11'
splot 'data/q2b_sweep.dat' using 1:2:($4 > 0 ? $4 : 1/0) with pm3d

unset multiplot
unset output

# =====================================================
# Versión alternativa: heatmaps 2D (más claros)
# =====================================================
set terminal pngcairo size 1200,550 enhanced font 'Arial,12'
set output 'plots/q2b_heatmap.png'

set multiplot layout 1,2 title "Q2b: heatmaps del barrido 2D" font 'Arial,13'

# Heatmap 1: N spikes
set view map
unset surface
set dgrid3d 30,30 gauss 0.5
set pm3d map interpolate 0,0
set xlabel "I_base (pA)"
set ylabel "I_step (pA)"
set title "Número de spikes" font 'Arial,11'
splot 'data/q2b_sweep.dat' using 1:2:3 with pm3d

# Heatmap 2: ISI min
set title "ISI mínimo (ms)" font 'Arial,11'
splot 'data/q2b_sweep.dat' using 1:2:($4 > 0 ? $4 : 1/0) with pm3d

unset multiplot
unset output
