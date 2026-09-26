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
# Dendritic injection: ventana completa de 6 s
set output "q5_dendrite.png"
set xrange [0:6]
set multiplot layout 3,1 title "Q5: current injected in dendrite"
set xlabel "t (s)"; set ylabel "V (mV)"
plot "q5_ID_50pA.dat"  u 1:($2*1000) w l t "Vs 50 pA",  "q5_ID_50pA.dat"  u 1:($3*1000) w l t "Vd 50 pA"
plot "q5_ID_100pA.dat" u 1:($2*1000) w l t "Vs 100 pA", "q5_ID_100pA.dat" u 1:($3*1000) w l t "Vd 100 pA"
plot "q5_ID_200pA.dat" u 1:($2*1000) w l t "Vs 200 pA", "q5_ID_200pA.dat" u 1:($3*1000) w l t "Vd 200 pA"
unset multiplot

# Somatic injection: ventana completa de 6 s
set output "q5_soma.png"
set xrange [0:6]
set multiplot layout 3,1 title "Q5: current injected in soma"
set xlabel "t (s)"; set ylabel "V (mV)"
plot "q5_IS_50pA.dat"  u 1:($2*1000) w l t "Vs 50 pA",  "q5_IS_50pA.dat"  u 1:($3*1000) w l t "Vd 50 pA"
plot "q5_IS_100pA.dat" u 1:($2*1000) w l t "Vs 100 pA", "q5_IS_100pA.dat" u 1:($3*1000) w l t "Vd 100 pA"
plot "q5_IS_200pA.dat" u 1:($2*1000) w l t "Vs 200 pA", "q5_IS_200pA.dat" u 1:($3*1000) w l t "Vd 200 pA"
unset multiplot
unset xrange

# ---------------- Q6 ----------------
# Q6a: m_h(infinity) y tau_mh (ya en mV en el .dat)
set output "q6_mh_rates.png"
unset xrange
unset yrange
set multiplot layout 1,2 title "Q6a: cinética de Ih"
set xlabel "V_D (mV)"
set ylabel "m_h,infinity"
plot "q6_mh_rates.dat" u 1:2 w l t "m_h,infinity"
set xlabel "V_D (mV)"
set ylabel "tau_mh (s)"
plot "q6_mh_rates.dat" u 1:3 w l t "tau_mh"
unset multiplot

# Q6b: 6 s overview
set output "q6.png"
unset xrange
set xrange [0:6]
set xlabel "t (s)"; set ylabel "V_S (mV)"
plot "q6_Gh_0nS.dat"  u 1:($2*1000) w l t "Gh=0 nS", \
     "q6_Gh_5nS.dat"  u 1:($2*1000) w l t "Gh=5 nS", \
     "q6_Gh_10nS.dat" u 1:($2*1000) w l t "Gh=10 nS", \
     "q6_Gh_15nS.dat" u 1:($2*1000) w l t "Gh=15 nS"

# Q6b: zoom +/-25 ms alrededor de la primera burst
set output "q6_zoom.png"
unset xrange
set xrange [-0.025:0.025]
set xlabel "t - t_firstburst (s)"; set ylabel "V_S (mV)"
plot "q6_Gh_0nS_zoom.dat"  u 1:($2*1000) w l t "Gh=0 nS", \
     "q6_Gh_5nS_zoom.dat"  u 1:($2*1000) w l t "Gh=5 nS", \
     "q6_Gh_10nS_zoom.dat" u 1:($2*1000) w l t "Gh=10 nS", \
     "q6_Gh_15nS_zoom.dat" u 1:($2*1000) w l t "Gh=15 nS"

# Q6b: dendritic overview
set output "q6_dendrite.png"
unset xrange
set xrange [0:6]
set xlabel "t (s)"; set ylabel "V_D (mV)"
plot "q6_Gh_0nS.dat"  u 1:($3*1000) w l t "Gh=0 nS", \
     "q6_Gh_5nS.dat"  u 1:($3*1000) w l t "Gh=5 nS", \
     "q6_Gh_10nS.dat" u 1:($3*1000) w l t "Gh=10 nS", \
     "q6_Gh_15nS.dat" u 1:($3*1000) w l t "Gh=15 nS"

unset xrange
