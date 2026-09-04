program membrana_estudio_paso_tiempo
    ! Resuelve EDO: dVm/dt = (J - Gm * (Vm - E)) / Cm
    ! TODAS las unidades en SI
    implicit none

    ! ============================================
    ! CONSTANTES FIJAS (factores de conversión)
    ! ============================================
    real, parameter :: uF_a_F = 1e-2          ! µF/cm² → F/m²
    real, parameter :: uS_a_S = 1e-2          ! µS/cm² → S/m²
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
    real :: tmin_j = 0.0 * ms_a_s             ! s     (5 ms)
    real :: tmax_j = 1000.0 * ms_a_s            ! s     (50 ms)
    ! ============================================
    ! PARÁMETROS DE LA SIMULACIÓN
    ! ============================================
    integer :: itmax
    real :: t_final=20.0*ms_a_s!=20*ms_a_s
    ! ============================================
    ! VARIABLES
    ! ============================================
    real,allocatable :: Vm(:) !arreglo dinamico
    real :: V_analitica
    real :: tau,V0
    real :: error_relativo
    real :: J, t
    integer :: it
    ! ============================================
    ! CONDICIÓN INICIAL
    ! ============================================
    V0=0.0

    itmax=int(t_final/dt)+1
    tau=Cm/Gm

    allocate(Vm(0:itmax))
    Vm(0)=0.0
    ! ============================================
    ! ABRIR ARCHIVO
    ! ============================================
    open(unit=10, file='potencial_membrana_euler_analitica.txt', status='unknown')
    write(10, '(A5, A15, A15, A15, A20)') 'it', 't(s)', 'Vm(V)','V_analitica(V)','Error_relativo'

    t=0.0
    do it = 0, itmax-1
        
        if (t >= tmin_j .and. t < tmax_j) then
            J = J_stim
        else
            J = 0.0
        end if

        !Método de Euler
        
        Vm(it+1) = Vm(it) + (J - Gm * (Vm(it) - E)) * dt / Cm     

        !Solucion analitica
        !Vm(t)=V0*exp^(-t/tau)+(E+J/gm)*(1-exp^(-t/tau))
        V_analitica=V0*exp(-t/tau)+(E+J/Gm)*(1.0-exp(-t/tau))
        
        if (abs(V_analitica)>1e-6) then
            error_relativo = (V_analitica-Vm(it))/V_analitica
        else
            error_relativo = 0.0
        end if

        t = (it+1)*dt

        write(10,*) it, t, Vm(it), V_analitica,error_relativo
    end do

    close(10)
    
    !GUardar informacion  de dt usado en otro archivo
    open(unit=20,file='dt_usado.txt',status='replace')
    write(20,*) dt
    close(20)

    print *, "Simulación completada"
end program membrana_estudio_paso_tiempo
