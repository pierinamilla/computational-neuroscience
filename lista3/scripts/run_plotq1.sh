#!/bin/bash
set -e
cd "$(dirname "$0")/.."

mkdir -p plots

# Q1a
gnuplot scripts/q1a_plot.gp

# Q1b
for J in 5 10 15 20; do
    gnuplot -e "Jval=$J" scripts/q1b_plot.gp
done

echo "Listo. Revisa plots/"
