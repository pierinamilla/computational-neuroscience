program ecuacion_membrana_si
    ! Resuelve EDO: dVm/dt = (J - Gm * (Vm - E)) / Cm
    ! TODAS las unidades en SI
    implicit none

    ! ============================================
    ! CONSTANTES FIJAS (factores de conversión)
    ! ============================================
    real, parameter :: uF_a_F = 1e-2          ! µF/cm² → F/m²
    real, parameter :: uS_a_S = 1e-1          ! µS/cm² → S/m²
    real, parameter :: mV_a_V = 1e-3          ! mV → V
    real, parameter :: uA_a_A = 1e-2          ! µA/cm² → A/m²
    real, parameter :: ms_a_s = 1e-3          ! ms → s

    ! ============================================
    ! PARÁMETROS MODIFICABLES (se pueden cambiar con sed)
    ! ============================================
    real :: Cm = 1.0 * uF_a_F                 ! F/m²  (1 µF/cm²)
    real :: Gm = 100.0 * uS_a_S               ! S/m²  (100 µS/cm²)
    real :: E = 0.0 * mV_a_V                  ! V     (0 mV)
    real :: J_stim = 2.0 * uA_a_A             ! A/m²  (2 µA/cm²)
    real :: dt = 1.0 * ms_a_s                 ! s     (1 ms)
    real :: tmin_j = 5.0 * ms_a_s             ! s     (5 ms)
    real :: tmax_j = 50.0 * ms_a_s            ! s     (50 ms)

    ! ============================================
    ! PARÁMETROS DE LA SIMULACIÓN
    ! ============================================
    integer, parameter :: itmax = 80

    ! ============================================
    ! VARIABLES
    ! ============================================
    real :: Vm(0:itmax)
    real :: J, t
    integer :: it

    ! ============================================
    ! CONDICIÓN INICIAL
    ! ============================================
    Vm(0) = 0.0

    ! ============================================
    ! ABRIR ARCHIVO
    ! ============================================
    open(unit=10, file='potencial_membrana_si.txt', status='unknown')
    write(10, '(A5, A15, A15)') 'it', 't(s)', 'Vm(V)'

    ! ============================================
    ! MÉTODO DE EULER
    ! ============================================
    do it = 0, itmax-1
        t = it * dt
        
        if (t >= tmin_j .and. t < tmax_j) then
            J = J_stim
        else
            J = 0.0
        end if
        
        Vm(it+1) = Vm(it) + (J - Gm * (Vm(it) - E)) * dt / Cm
        
        write(10, *) it, t, Vm(it)
    end do

    close(10)

    print *, "✅ Simulación completada en SI"
    print *, "📄 Resultados guardados en p4_potencial_membrana_si.txt"
    print *, "⚠️ Unidades: Vm(V), t(s), J(A/m²), Gm(S/m²), Cm(F/m²)"
    print *, "   Parámetros modificables: Cm, Gm, dt, J_stim, tmin_j, tmax_j"

end program ecuacion_membrana_si
