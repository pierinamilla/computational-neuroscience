#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p build plots
FC=${FC:-gfortran}
"$FC" -O2 -std=f2008 -ffree-line-length-none -J build source/lista5.f90 -o build/lista5
./build/lista5
if command -v python3 >/dev/null 2>&1; then
  python3 scripts/plots.py
else
  echo 'Datos generados en data/. Para PNG instala Python 3 y matplotlib.'
fi
