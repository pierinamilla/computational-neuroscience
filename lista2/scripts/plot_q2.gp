# plot_spikes.gp
# Dos figuras (no spike y spike), cada una con 3 subgráficos
# Distribución: V, (n, m, h), J

# ============================================================
# FIGURA 1: NO SPIKE (J = 13.09)
# ============================================================
reset
set terminal pngcairo size 1000,900 enhanced font 'Arial,12'
set output 'plots/q2_no_spike.png'
set multiplot layout 3,1 title "J = 13.09 \\mu A/cm^2 (no spike)" font 'Arial,14'

# --- Subgráfico 1: V ---
set grid
set ylabel "V (mV)"
set xlabel ""
unset key
plot 'data/q2_no_spike.dat' using 1:2 with lines lw 2 lc rgb '#D62728' title "V"

# --- Subgráfico 2: n, m, h ---
set ylabel "Gating variables"
set xlabel ""
set key outside right
plot 'data/q2_no_spike.dat' using 1:3 with lines lw 2 lc rgb '#1F77B4' title "n", \
     'data/q2_no_spike.dat' using 1:4 with lines lw 2 lc rgb '#2CA02C' title "m", \
     'data/q2_no_spike.dat' using 1:5 with lines lw 2 lc rgb '#FF7F0E' title "h"

# --- Subgráfico 3: J ---
set ylabel "J (\\mu A/cm^2)"
set xlabel "Time (ms)"
unset key
plot 'data/q2_no_spike.dat' using 1:6 with lines lw 2 lc rgb '#9467BD' title "J"

unset multiplot
unset output

# ============================================================
# FIGURA 2: SPIKE (J = 13.1)
# ============================================================
reset
set terminal pngcairo size 1000,900 enhanced font 'Arial,12'
set output 'plots/q2_spike.png'
set multiplot layout 3,1 title "J = 13.1 \\mu A/cm^2 (spike)" font 'Arial,14'

# --- Subgráfico 1: V ---
set grid
set ylabel "V (mV)"
set xlabel ""
unset key
plot 'data/q2_spike.dat' using 1:2 with lines lw 2 lc rgb '#D62728' title "V"

# --- Subgráfico 2: n, m, h ---
set ylabel "Gating variables"
set xlabel ""
set key outside right
plot 'data/q2_spike.dat' using 1:3 with lines lw 2 lc rgb '#1F77B4' title "n", \
     'data/q2_spike.dat' using 1:4 with lines lw 2 lc rgb '#2CA02C' title "m", \
     'data/q2_spike.dat' using 1:5 with lines lw 2 lc rgb '#FF7F0E' title "h"

# --- Subgráfico 3: J ---
set ylabel "J (\\mu A/cm^2)"
set xlabel "Time (ms)"
unset key
plot 'data/q2_spike.dat' using 1:6 with lines lw 2 lc rgb '#9467BD' title "J"

unset multiplot
unset output
