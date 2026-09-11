# plot_q6_casos.gp - Tres casos ilustrativos de la Pregunta 6

set terminal pngcairo size 1000,1100 enhanced font 'Arial,11'
set output 'plots/q6_casos.png'

set multiplot layout 3,2 title "Q6: periodos refractarios - casos ilustrativos" font 'Arial,14'

# --- Caso 1: dentro del PR absoluto ---
set ylabel "V (mV)"
set title "Dentro del PR absoluto (L=0.3, J2=1000)" font 'Arial,11'
set xrange [0:40]
plot 'data/q6_dentro_abs.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
unset title
plot 'data/q6_dentro_abs.dat' using 1:6 with lines lw 1.5 lc rgb 'red' title 'J(t)'

# --- Caso 2: fuera del PR absoluto ---
set ylabel "V (mV)"
set title "Fuera del PR absoluto (L mayor, J2=1000)" font 'Arial,11'
plot 'data/q6_fuera_abs.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
unset title
plot 'data/q6_fuera_abs.dat' using 1:6 with lines lw 1.5 lc rgb 'red' title 'J(t)'

# --- Caso 3: en el PR relativo ---
set ylabel "V (mV)"
set title "En el PR relativo (J2=J1)" font 'Arial,11'
set xlabel "t (ms)"
plot 'data/q6_relativo.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
set xlabel "t (ms)"
unset title
plot 'data/q6_relativo.dat' using 1:6 with lines lw 1.5 lc rgb 'red' title 'J(t)'

unset multiplot
