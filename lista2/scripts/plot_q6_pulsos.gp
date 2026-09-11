# plot_q6_pulsos.gp - Ilustracion de los tres casos

set terminal pngcairo size 1000,1200 enhanced font 'Arial,11'
set output 'plots/q6_pulsos.png'

set grid
set xrange [0:40]

set multiplot layout 3,2 title "Q6: estimulacion con dos pulsos (J1=100)" font 'Arial,14'

# --- Caso 1: DENTRO del PR absoluto (no dispara el 2do) ---
set ylabel "V (mV)"
set title "Dentro del PR absoluto (L=0.3, J2=1000)" font 'Arial,10'
set xlabel ""
plot 'data/q6_dentro_abs.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
set title ""
set xlabel ""
plot 'data/q6_dentro_abs.dat' using 1:6 with lines lw 1.5 lc rgb 'red' title 'J(t)'

# --- Caso 2: FUERA del PR absoluto (si dispara el 2do) ---
set ylabel "V (mV)"
set title "Fuera del PR absoluto (L mayor, J2=1000)" font 'Arial,10'
set xlabel ""
plot 'data/q6_fuera_abs.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
set title ""
set xlabel ""
plot 'data/q6_fuera_abs.dat' using 1:6 with lines lw 1.5 lc rgb 'red' title 'J(t)'

# --- Caso 3: En el PR relativo (J2=J1, apenas dispara) ---
set ylabel "V (mV)"
set title "En el PR relativo (L=1.7441, J2=J1=100)" font 'Arial,10'
set xlabel "t (ms)"
plot 'data/q6_relativo.dat' using 1:2 with lines lw 1.5 lc rgb 'black' title 'V(t)'

set ylabel "J ({/Symbol m}A/cm^2)"
set title ""
set xlabel "t (ms)"
plot 'data/q6_relativo.dat' using 1:6 with lines lw 1.5 lc rgb 'red' title 'J(t)'

unset multiplot
