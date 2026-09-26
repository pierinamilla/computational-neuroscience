set terminal pngcairo size 1100,750 enhanced font "DejaVu Sans,11"
set datafile separator whitespace
set grid
set key outside

# ---------------- Q1 ----------------
set output "q1_voltage_rates.png"
set multiplot layout 2,2 title "Q1: constantes de tasa vs V"
set xlabel "V (mV)"; set ylabel "rate (s^-1)"
plot "q1_voltage.dat" u 1:2 w l t "alpha_m", \
     "q1_voltage.dat" u 1:3 w l t "beta_m"
plot "q1_voltage.dat" u 1:4 w l t "alpha_h", \
     "q1_voltage.dat" u 1:5 w l t "beta_h"
plot "q1_voltage.dat" u 1:6 w l t "alpha_n", \
     "q1_voltage.dat" u 1:7 w l t "beta_n"
plot "q1_voltage.dat" u 1:8 w l t "alpha_mCa", \
     "q1_voltage.dat" u 1:9 w l t "beta_mCa", \
     "q1_voltage.dat" u 1:10 w l t "alpha_mKCa", \
     "q1_voltage.dat" u 1:11 w l t "beta_mKCa"
unset multiplot

set output "q1_ca_rates.png"
set xlabel "[Ca] (M)"; set ylabel "rate / factor"
plot "q1_ca.dat" u 1:2 w l t "alpha_mKAHP", \
     "q1_ca.dat" u 1:3 w l t "beta_mKAHP", \
     "q1_ca.dat" u 1:4 w l t "chi"

# ---------------- Q2 ----------------
set output "q2.png"
set xrange [0:2]
set xlabel "t (s)"; set ylabel "V (mV)"
plot "q2.dat" u 1:($2*1000) w l t "Vs", \
     "q2.dat" u 1:($3*1000) w l t "Vd"

set output "q2_zoom.png"
set xrange [0.86:0.91]
set xlabel "t (s)"; set ylabel "V (mV)"
plot "q2.dat" u 1:($2*1000) w l t "Vs", \
     "q2.dat" u 1:($3*1000) w l t "Vd"
unset xrange

# ---------------- Q3 ----------------
set output "q3.png"
set xrange [0:2]
set xlabel "t (s)"; set ylabel "V (mV)"
plot "q3_Gc_0nS.dat"   u 1:($2*1000) w l t "Gc=0 nS", \
     "q3_Gc_10nS.dat"  u 1:($2*1000) w l t "Gc=10 nS", \
     "q3_Gc_50nS.dat"  u 1:($2*1000) w l t "Gc=50 nS", \
     "q3_Gc_100nS.dat" u 1:($2*1000) w l t "Gc=100 nS"

# ---------------- Q4 ----------------
set output "q4.png"
set xrange [0:2]
set xlabel "t (s)"; set ylabel "V_S (mV)"
plot "q4_Gc_0nS.dat"   u 1:($2*1000) w l t "Gc=0 nS", \
     "q4_Gc_10nS.dat"  u 1:($2*1000) w l t "Gc=10 nS", \
     "q4_Gc_50nS.dat"  u 1:($2*1000) w l t "Gc=50 nS", \
     "q4_Gc_100nS.dat" u 1:($2*1000) w l t "Gc=100 nS"

# ---------------- Q5 ----------------
# Dendritic injection
set output "q5_dendrite.png"
set xrange [0:6]
set multiplot layout 3,1 title "Q5: current injected in dendrite"
set xlabel "t (s)"; set ylabel "V (mV)"
plot "q5_ID_50pA.dat"  u 1:($2*1000) w l t "Vs 50 pA", \
     "q5_ID_50pA.dat"  u 1:($3*1000) w l t "Vd 50 pA"
plot "q5_ID_100pA.dat" u 1:($2*1000) w l t "Vs 100 pA", \
     "q5_ID_100pA.dat" u 1:($3*1000) w l t "Vd 100 pA"
plot "q5_ID_200pA.dat" u 1:($2*1000) w l t "Vs 200 pA", \
     "q5_ID_200pA.dat" u 1:($3*1000) w l t "Vd 200 pA"
unset multiplot

# Somatic injection
set output "q5_soma.png"
set xrange [0:6]
set multiplot layout 3,1 title "Q5: current injected in soma"
set xlabel "t (s)"; set ylabel "V (mV)"
plot "q5_IS_50pA.dat"  u 1:($2*1000) w l t "Vs 50 pA", \
     "q5_IS_50pA.dat"  u 1:($3*1000) w l t "Vd 50 pA"
plot "q5_IS_100pA.dat" u 1:($2*1000) w l t "Vs 100 pA", \
     "q5_IS_100pA.dat" u 1:($3*1000) w l t "Vd 100 pA"
plot "q5_IS_200pA.dat" u 1:($2*1000) w l t "Vs 200 pA", \
     "q5_IS_200pA.dat" u 1:($3*1000) w l t "Vd 200 pA"
unset multiplot
unset xrange

# ---------------- Q6 ----------------
# Q6a
set output "q6_mh_rates.png"
unset xrange
unset yrange
set multiplot layout 1,2 title "Q6a: cinética de Ih"
set xlabel "V_D (mV)"
set ylabel "m_h,infinity"
plot "q6_mh_rates.dat" u 1:2 w l lw 2 t "m_h,infinity"
set xlabel "V_D (mV)"
set ylabel "tau_mh (ms)"
plot "q6_mh_rates.dat" u 1:($3*1000) w l lw 2 t "tau_mh"
unset multiplot

# Q6b: overview
set output "q6.png"
set xrange [0:6]
set xlabel "t (s)"; set ylabel "V_S (mV)"
plot "q6_Gh_0nS.dat"  u 1:($2*1000) w l lw 0.7 lc rgb '#1f77b4' t "Gh=0 nS",  \
     "q6_Gh_5nS.dat"  u 1:($2*1000) w l lw 0.7 lc rgb '#2ca02c' t "Gh=5 nS",  \
     "q6_Gh_10nS.dat" u 1:($2*1000) w l lw 0.7 lc rgb '#ff7f0e' t "Gh=10 nS", \
     "q6_Gh_15nS.dat" u 1:($2*1000) w l lw 0.7 lc rgb '#d62728' t "Gh=15 nS"

# Q6b: zoom
set output "q6_zoom.png"
set xrange [-25:25]
set xlabel "t - t_{pn} (ms)"; set ylabel "V_S (mV)"
plot "q6_Gh_0nS_zoom.dat"  u 1:($2*1000) w l lw 2 lc rgb '#1f77b4' t "Gh=0 nS",  \
     "q6_Gh_5nS_zoom.dat"  u 1:($2*1000) w l lw 2 lc rgb '#2ca02c' t "Gh=5 nS",  \
     "q6_Gh_10nS_zoom.dat" u 1:($2*1000) w l lw 2 lc rgb '#ff7f0e' t "Gh=10 nS", \
     "q6_Gh_15nS_zoom.dat" u 1:($2*1000) w l lw 2 lc rgb '#d62728' t "Gh=15 nS"

# Q6b: dendritic overview
set output "q6_dendrite.png"
set xrange [0:6]
set xlabel "t (s)"; set ylabel "V_D (mV)"
plot "q6_Gh_0nS.dat"  u 1:($3*1000) w l lw 0.7 lc rgb '#1f77b4' t "Gh=0 nS",  \
     "q6_Gh_5nS.dat"  u 1:($3*1000) w l lw 0.7 lc rgb '#2ca02c' t "Gh=5 nS",  \
     "q6_Gh_10nS.dat" u 1:($3*1000) w l lw 0.7 lc rgb '#ff7f0e' t "Gh=10 nS", \
     "q6_Gh_15nS.dat" u 1:($3*1000) w l lw 0.7 lc rgb '#d62728' t "Gh=15 nS"

# Q6b: separate panel layout
set output "q6_separated.png"
set multiplot layout 4,2 title "Q6b: efecto de Gh sobre el patrón somático" font 'Arial,12'

set xrange [2:6]; unset yrange
set ylabel "V_S (mV)" font 'Arial,9'; unset xlabel
plot "q6_Gh_0nS.dat" u 1:($2*1000) w l lw 0.5 lc rgb 'black' notitle
set xrange [-25:25]
plot "q6_Gh_0nS_zoom.dat" u 1:($2*1000) w l lw 1.2 lc rgb 'black' notitle

set xrange [2:6]
plot "q6_Gh_5nS.dat" u 1:($2*1000) w l lw 0.5 lc rgb 'black' notitle
set xrange [-25:25]
plot "q6_Gh_5nS_zoom.dat" u 1:($2*1000) w l lw 1.2 lc rgb 'black' notitle

set xrange [2:6]
plot "q6_Gh_10nS.dat" u 1:($2*1000) w l lw 0.5 lc rgb 'black' notitle
set xrange [-25:25]
plot "q6_Gh_10nS_zoom.dat" u 1:($2*1000) w l lw 1.2 lc rgb 'black' notitle

set xrange [2:6]
set xlabel "Time (s)" font 'Arial,9'
plot "q6_Gh_15nS.dat" u 1:($2*1000) w l lw 0.5 lc rgb 'black' notitle
set xrange [-25:25]
set xlabel "Time (ms)" font 'Arial,9'
plot "q6_Gh_15nS_zoom.dat" u 1:($2*1000) w l lw 1.2 lc rgb 'black' notitle

unset multiplot
