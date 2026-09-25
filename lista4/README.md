# Lista 4 — Pinsky–Rinzel en Fortran + shell

## Archivos
- `lista4_pr.f90`: modelo y soluciones Q1–Q6.
- `run_lista4.sh`: compila y ejecuta.
- `plot_lista4.gp`: gráficos con gnuplot.

## Uso
```bash
chmod +x run_lista4.sh
./run_lista4
```

También se puede ejecutar por inciso:
```bash
./run_lista4 q1
./run_lista4 q2 q3 q4
./run_lista4 q5 q6
```

## Figuras generadas

### Q1
- `q1_voltage_rates.png`
- `q1_ca_rates.png`

### Q2
- `q2.png`: simulación completa de 0 a 2 s.
- `q2_zoom.png`: zoom de 0.86 a 0.91 s.

### Q3
- `q3.png`: Gc = 0, 10, 50 y 100 nS.

### Q4
- `q4.png`: mismos cuatro valores de Gc que Q3, con k duplicado.

### Q5
- `q5_dendrite.png`: ID = 50, 100 y 200 pA, IS = 0.
- `q5_soma.png`: IS = 50, 100 y 200 pA, ID = 0.

### Q6
- `q6_mh_rates.png`: mh,infinity y tau_mh.
- `q6.png`: respuesta de 6 s para Gh = 0, 5, 10 y 15 nS.
- `q6_zoom.png`: ventana de +/-25 ms alrededor del primer burst, alineada por tiempo.
- `q6_dendrite.png`: respuesta dendrítica de 6 s, como gráfico complementario.

## Unidades
El código usa SI internamente:
- V: volt
- t: segundo
- I: ampere
- G: siemens
- C: farad
- [Ca]: mol/L
- tasas de gating: s^-1

## Detección
Para los spikes se usa:
- cruce de Vs por -10 mV hacia arriba;
- el siguiente spike sólo se cuenta después de Vs < -30 mV.

Para Q6, el burst dendrítico se detecta cuando Vd cruza 0 mV hacia arriba y termina cuando Vd < -50 mV.

Q4 repite explícitamente los cuatro valores de Gc de Q3 con k duplicado.
Q5 incluye tanto inyección dendrítica como somática.
