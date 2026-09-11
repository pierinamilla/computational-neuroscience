# plot_q4.gp - Una figura con 3 subplots (V, gating, J) por cada caso

# ---- Variables (defaults) ----
if (!exists("archivo_in"))    archivo_in    = "data/hh_q4.dat"
if (!exists("archivo_out"))   archivo_out   = "plots/q4.png"
if (!exists("titulo_global")) titulo_global = "Question 4"

# ---- Terminal y salida ----
set terminal pngcairo size 1000,900 enhanced font 'Arial,12'
set output archivo_out

# ---- Multiplot: 3 filas, 1 columna, con título general ----
set multiplot layout 3,1 title titulo_global font 'Arial,14'

# --- Subgrafico 1: V ---
set grid
set ylabel "V (mV)"
set xlabel ""
unset key
plot archivo_in using 1:2 with lines lw 2 lc rgb '#D62728' title "V"

# --- Subgrafico 2: n, m, h ---
set ylabel "Gating variables"
set xlabel ""
set key outside right
plot archivo_in using 1:3 with lines lw 2 lc rgb '#1F77B4' title "n", \
     archivo_in using 1:4 with lines lw 2 lc rgb '#2CA02C' title "m", \
     archivo_in using 1:5 with lines lw 2 lc rgb '#FF7F0E' title "h"

# --- Subgrafico 3: J ---
set ylabel "J (\\mu A/cm^2)"
set xlabel "Time (ms)"
unset key
plot archivo_in using 1:6 with lines lw 2 lc rgb '#9467BD' title "J"

unset multiplot
unset output
