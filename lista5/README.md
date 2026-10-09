# Lista 5 — FitzHugh–Nagumo y Morris–Lecar

Proyecto organizado para compilar las simulaciones en Fortran, guardar los datos numéricos y generar los gráficos.

## Estructura

- `source/`: código fuente Fortran (`lista5.f90`).
- `scripts/`: script de ejecución y scripts de graficación (Python y gnuplot).
- `data/`: datos numéricos generados por las simulaciones.
- `plots/`: gráficos PNG ya incluidos; al ejecutar se regeneran aquí.
- `results/`: archivo con puntos fijos y notas de interpretación.
- `build/`: ejecutable y archivos de compilación generados localmente.

## Requisitos

- `gfortran`
- Python 3 con `numpy` y `matplotlib` para regenerar los gráficos.

En una terminal, entra en la carpeta `lista5_organizado` y ejecuta:

```bash
bash scripts/run.sh
```

El script compila `source/lista5.f90`, ejecuta las simulaciones, escribe los datos en `data/` y crea los PNG en `plots/`. Si solo quieres ver los gráficos ya preparados, abre la carpeta `plots/` sin ejecutar nada.

## Convenciones del modelo

- FHN: las nulclinas son `w=v-v^3/3+I` y `w=(v+0.7)/0.8`.
- Morris–Lecar base: los incisos de respuesta a pulso usan la corriente constante de fondo `J=15 µA/cm²`; las curvas f-I y los planos de fase para `J=24.8` y `J=25` usan el valor de J especificado, sin sumar de nuevo la corriente de fondo.
- Morris–Lecar modificado: usa `n∞=0.5[1+tanh((V-10)/14.5)]`, `τn=3/cosh((V-10)/29)` y `gCa=1 mS/cm²`.
- La frecuencia se estima contando cruces ascendentes de `V=0 mV` durante la segunda mitad de cada simulación. El umbral puede variar ligeramente con el paso y la duración.
