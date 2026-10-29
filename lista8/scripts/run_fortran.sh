#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/results"
gfortran -O2 -std=f2008 "$ROOT/src/fortran/hh_single.f90" -o hh_single
./hh_single E
