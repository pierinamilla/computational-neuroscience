#!/bin/bash
# Script para el estudio del paso de tiempo (Pregunta 5)
# Adaptado para membrana_estudio_paso_tiempo.f90

echo "=========================================="
echo "  ESTUDIO DEL PASO DE TIEMPO (∆t)"
echo "  Pregunta 5 - Análisis de precisión"
echo "=========================================="
echo ""

# ============================================
# CONFIGURACIÓN
# ============================================
FUENTE="ecuacion_membrana_estudio_tiempo.f90"
EJECUTABLE="estudio_paso_tiempo"

# Valores de dt a probar (en segundos)
VALORES_DT="5e-4 1e-3 2e-3 1e-2 1e-1"

# Nombre base para los resultados
RESULTADO_BASE="potencial_membrana_euler_analitica"

# ============================================
# VERIFICAR DEPENDENCIAS
# ============================================
echo "🔍 Verificando dependencias..."

if ! command -v gfortran &> /dev/null; then
    echo "❌ gfortran no está instalado"
    exit 1
fi

if ! command -v gnuplot &> /dev/null; then
    echo "⚠️ gnuplot no está instalado. Instalando..."
    sudo apt install gnuplot -y
fi

echo "✅ Dependencias verificadas"
echo ""

# ============================================
# COMPILAR CÓDIGO FUENTE
# ============================================
echo "📦 Compilando código fuente..."
gfortran -Wall -g -o $EJECUTABLE $FUENTE

if [ $? -ne 0 ]; then
    echo "❌ Error en la compilación"
    exit 1
fi
echo "✅ Compilación exitosa"
echo ""

# ============================================
# BUCLE PARA CADA VALOR DE dt
# ============================================
echo "⚡ Ejecutando simulaciones..."

# Archivo para guardar tiempos de ejecución
> tiempos_ejecucion.txt

for DT in $VALORES_DT; do
    echo ""
    echo "----------------------------------------"
    echo "Probando dt = $DT s (equivalente a $(echo "$DT * 1000" | bc) ms)"
    echo "----------------------------------------"
    
    # Modificar dt en el código fuente (usando sed)
    # Buscar "dt = " seguido de número y reemplazar
    cp $FUENTE temp_${DT}.f90
    sed -i "s/dt = [0-9.e+-]*/dt = $DT/g" temp_${DT}.f90
    
    # Compilar el código modificado
    gfortran -Wall -g -o ${EJECUTABLE}_temp temp_${DT}.f90
    
    if [ $? -ne 0 ]; then
        echo "❌ Error compilando para dt = $DT"
        rm -f temp_${DT}.f90
        continue
    fi
    
    # Medir tiempo de ejecución
    START_TIME=$(date +%s%N)
    
    # Ejecutar
    ./${EJECUTABLE}_temp
    
    END_TIME=$(date +%s%N)
    ELAPSED_TIME=$(echo "scale=6; ($END_TIME - $START_TIME) / 1000000000" | bc)
    
    # Guardar tiempo de ejecución
    echo "$DT $ELAPSED_TIME" >> tiempos_ejecucion.txt
    
    # Renombrar archivo de resultados
    DT_LABEL=$(echo $DT | sed 's/\./_/g')
    mv ${RESULTADO_BASE}.txt "p5_resultados_dt_${DT_LABEL}.txt"
    
    # Limpiar archivos temporales
    rm -f temp_${DT}.f90 ${EJECUTABLE}_temp
    
    echo "   ✅ Simulación completada en $ELAPSED_TIME s"
done

echo ""
echo "✅ Todas las simulaciones completadas"
echo ""

# ============================================
# GENERAR GRÁFICO 1: V vs t (Analítica + Numéricas)
# ============================================
echo "📈 Generando gráfico V vs t..."

cat > p5_graficar_comparacion.gp << 'EOF'
set terminal pngcairo size 1200,800 enhanced font 'Arial,14'
set output 'p5_comparacion_V_vs_t.png'
set title "Comparación: Solución Analítica vs Numéricas (Euler)"
set xlabel "Tiempo (ms)"
set ylabel "Vm (mV)"
set grid
set key outside right
set xrange [0:20]

# Colores para las curvas
set style line 1 lc rgb '#000000' lw 3 lt 1   # Negro - Analítica
set style line 2 lc rgb '#D62728' lw 2 lt 1   # Rojo - dt=5e-4
set style line 3 lc rgb '#1F77B4' lw 2 lt 1   # Azul - dt=1e-3
set style line 4 lc rgb '#2CA02C' lw 2 lt 1   # Verde - dt=2e-3
set style line 5 lc rgb '#FF7F0E' lw 2 lt 1   # Naranja - dt=1e-2
set style line 6 lc rgb '#9467BD' lw 2 lt 1   # Púrpura - dt=1e-1

# Graficar solución analítica (usando el archivo con dt más pequeño como referencia)
plot "p5_resultados_dt_5e-4.txt" using ($2*1000):($4*1000) with lines ls 1 title "Analítica (exacta)", \
     "p5_resultados_dt_5e-4.txt" using ($2*1000):($3*1000) with lines ls 2 title "Numérica (dt=5e-4 s)", \
     "p5_resultados_dt_1e-3.txt" using ($2*1000):($3*1000) with lines ls 3 title "Numérica (dt=1e-3 s)", \
     "p5_resultados_dt_2e-3.txt" using ($2*1000):($3*1000) with lines ls 4 title "Numérica (dt=2e-3 s)", \
     "p5_resultados_dt_1e-2.txt" using ($2*1000):($3*1000) with lines ls 5 title "Numérica (dt=1e-2 s)", \
     "p5_resultados_dt_1e-1.txt" using ($2*1000):($3*1000) with lines ls 6 title "Numérica (dt=1e-1 s)"
EOF

gnuplot p5_graficar_comparacion.gp

if [ -f "p5_comparacion_V_vs_t.png" ]; then
    echo "✅ Gráfico generado: p5_comparacion_V_vs_t.png"
    rm -f p5_graficar_comparacion.gp
else
    echo "❌ Error al generar el gráfico comparativo"
fi
echo ""

# ============================================
# GENERAR GRÁFICO 2: Error Relativo vs t
# ============================================
echo "📈 Generando gráfico de Error Relativo..."

cat > p5_graficar_error.gp << 'EOF'
set terminal pngcairo size 1200,800 enhanced font 'Arial,14'
set output 'p5_error_relativo.png'
set title "Error Relativo: Solución Analítica vs Numérica"
set xlabel "Tiempo (ms)"
set ylabel "Error Relativo"
set grid
set key outside right
set xrange [0:20]
set yrange [-0.05:0.05]

set style line 1 lc rgb '#D62728' lw 2 lt 1
set style line 2 lc rgb '#1F77B4' lw 2 lt 1
set style line 3 lc rgb '#2CA02C' lw 2 lt 1
set style line 4 lc rgb '#FF7F0E' lw 2 lt 1
set style line 5 lc rgb '#9467BD' lw 2 lt 1

plot "p5_resultados_dt_5e-4.txt" using ($2*1000):($5) with lines ls 1 title "Error (dt=5e-4 s)", \
     "p5_resultados_dt_1e-3.txt" using ($2*1000):($5) with lines ls 2 title "Error (dt=1e-3 s)", \
     "p5_resultados_dt_2e-3.txt" using ($2*1000):($5) with lines ls 3 title "Error (dt=2e-3 s)", \
     "p5_resultados_dt_1e-2.txt" using ($2*1000):($5) with lines ls 4 title "Error (dt=1e-2 s)", \
     "p5_resultados_dt_1e-1.txt" using ($2*1000):($5) with lines ls 5 title "Error (dt=1e-1 s)"
EOF

gnuplot p5_graficar_error.gp

if [ -f "p5_error_relativo.png" ]; then
    echo "✅ Gráfico generado: p5_error_relativo.png"
    rm -f p5_graficar_error.gp
else
    echo "❌ Error al generar el gráfico de errores"
fi
echo ""

# ============================================
# GENERAR TABLA DE TIEMPOS
# ============================================
echo ""
echo "=========================================="
echo "  TABLA DE TIEMPOS DE EJECUCIÓN"
echo "=========================================="
printf "  %-12s %-12s %-15s\n" "∆t (s)" "∆t (ms)" "Tiempo (s)"
echo "------------------------------------------"

while read DT TIME; do
    DT_MS=$(echo "$DT * 1000" | bc)
    printf "  %-12s %-12.3f %-15.6f\n" "$DT" "$DT_MS" "$TIME"
done < tiempos_ejecucion.txt

echo "=========================================="
echo ""

# ============================================
# MOSTRAR INFORMACIÓN DE τ
# ============================================
echo "📊 Información adicional:"
echo "   Constante de tiempo τ = Cm/Gm = 1 ms"
echo ""
echo "   Relación τ/∆t para cada caso:"
while read DT TIME; do
    RATIO=$(echo "scale=2; 0.001 / $DT" | bc)
    printf "   ∆t = %-8s s  →  τ/∆t = %.2f\n" "$DT" "$RATIO"
done < tiempos_ejecucion.txt

echo ""
echo "=========================================="

# ============================================
# ABRIR GRÁFICOS
# ============================================
echo ""
echo "🖼️  Abriendo gráficos..."

if command -v explorer.exe &> /dev/null; then
    explorer.exe p5_comparacion_V_vs_t.png &
    sleep 1
    explorer.exe p5_error_relativo.png &
elif command -v eog &> /dev/null; then
    eog p5_comparacion_V_vs_t.png &
    eog p5_error_relativo.png &
elif command -v xdg-open &> /dev/null; then
    xdg-open p5_comparacion_V_vs_t.png &
    xdg-open p5_error_relativo.png &
else
    echo "⚠️ No se encontró un visor de imágenes"
    echo "   Los gráficos están en:"
    echo "   - p5_comparacion_V_vs_t.png"
    echo "   - p5_error_relativo.png"
fi

echo ""
echo "✅ Estudio completado"
echo ""
echo "📄 Archivos generados:"
ls -la p5_*.txt p5_*.png 2>/dev/null | awk '{print "   " $9}'
