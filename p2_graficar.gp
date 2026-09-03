
set terminal pngcairo size 800,600
set output 'p2_potencial_membrana.png'
set title "Absolute membrane potential vs time"
set xlabel "Time(ms)"
set ylabel "Vm(mV)"
set grid
plot 'p2_potencial_membrana.txt' using 2:3 with lines title 'Vm(t)'
