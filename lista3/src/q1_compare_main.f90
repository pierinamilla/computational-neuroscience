program q1_compare_main
    use mod_cs_params, only: dp, V0, n0, m0, h0, a0, b0
    use mod_cs_deriv,       only: cs_deriv
    use mod_cs_deriv_slowb, only: cs_deriv_slowb
    use mod_rk4, only: rk4_step
    implicit none

    ! --- Parámetros de simulación ---
    real(dp), parameter :: dt       = 0.01_dp
    real(dp), parameter :: t_end    = 500.0_dp
    real(dp), parameter :: t_stim   = 60.0_dp
    real(dp), parameter :: J_inj    = 15.0_dp
    real(dp), parameter :: Vth      = 0.0_dp       ! umbral de spike (mV)
    real(dp), parameter :: t_min_sep = 1.0_dp      ! separación mínima entre spikes

    ! --- Estructura de resultados ---
    type :: result_t
        integer  :: n_spikes
        real(dp) :: t_first         ! tiempo del primer spike (ms, absoluto)
        real(dp) :: latency         ! t_first - t_stim
        real(dp) :: isi_mean
        real(dp) :: freq
    end type

    type(result_t) :: res_norm, res_slow

    ! --- Correr ambas simulaciones ---
    call run_case(cs_deriv,      'data/q1_compare_norm.dat', res_norm)
    call run_case(cs_deriv_slowb,'data/q1_compare_slow.dat', res_slow)

    ! --- Reporte ---
    print *
    print *, '=========================================================='
    print *, '  Comparación: cinética normal vs cinética de b lenta'
    print *, '  J =', J_inj, ' uA/cm^2   (estímulo desde t =', t_stim, 'ms)'
    print *, '=========================================================='
    print '(A,T20,A,T40,A)', 'Cantidad', 'Normal', 'b lento (x0.25)'
    print '(A,T20,A,T40,A)', '--------', '------', '---------------'
    print '(A,T20,I10,T40,I10)', 'n_spikes',      res_norm%n_spikes,  res_slow%n_spikes
    print '(A,T20,F10.3,T40,F10.3)', 'Latencia (ms)',  res_norm%latency,   res_slow%latency
    print '(A,T20,F10.3,T40,F10.3)', 'ISI medio (ms)', res_norm%isi_mean,  res_slow%isi_mean
    print '(A,T20,F10.3,T40,F10.3)', 'Frecuencia (Hz)',res_norm%freq,      res_slow%freq
    print *, '=========================================================='
    print *

contains

    ! ------------------------------------------------------------------
    ! Corre una simulación con la subroutine de derivadas que se le pase
    ! ------------------------------------------------------------------
    subroutine run_case(deriv, fname, res)
        interface
            pure subroutine deriv(t, u, J, du)
                import :: dp
                real(dp), intent(in)  :: t, J
                real(dp), intent(in)  :: u(:)
                real(dp), intent(out) :: du(:)
            end subroutine deriv
        end interface

        character(len=*),       intent(in)  :: fname
        type(result_t),         intent(out) :: res

        real(dp) :: u(6), u_new(6), t, J_now, V_prev
        real(dp) :: t_first, t_prev, isi_sum
        integer  :: i, Nt, n_isi
        logical  :: first_found

        Nt = int(t_end / dt)

        open(unit=20, file=trim(fname), status='replace')
        write(20,*) '# t  V  n  m  h  a  b  J'

        u = [V0, n0, m0, h0, a0, b0]
        t = 0.0_dp
        res%n_spikes = 0
        t_first      = -1.0_dp
        t_prev       = -1000.0_dp
        isi_sum      = 0.0_dp
        n_isi        = 0
        first_found  = .false.

        do i = 0, Nt
            if (t >= t_stim) then
                J_now = J_inj
            else
                J_now = 0.0_dp
            end if

            V_prev = u(1)
            write(20,'(8F16.8)') t, u(1), u(2), u(3), u(4), u(5), u(6), J_now

            call rk4_step(deriv, t, u, J_now, dt, u_new)

            ! Detección de spike (cruce ascendente por Vth)
            if (V_prev < Vth .and. u_new(1) >= Vth) then
                if (t - t_prev > t_min_sep) then
                    res%n_spikes = res%n_spikes + 1
                    if (.not. first_found .and. t >= t_stim) then
                        t_first     = t
                        first_found = .true.
                    else if (first_found) then
                        isi_sum = isi_sum + (t - t_prev)
                        n_isi   = n_isi + 1
                    end if
                    t_prev = t
                end if
            end if

            u = u_new
            t = t + dt
        end do

        close(20)

        ! Cálculos finales
        if (first_found) then
            res%t_first = t_first
            res%latency = t_first - t_stim
        else
            res%t_first = -1.0_dp
            res%latency = -1.0_dp
        end if

        if (n_isi > 0) then
            res%isi_mean = isi_sum / real(n_isi, dp)
            res%freq     = 1000.0_dp / res%isi_mean
        else
            res%isi_mean = -1.0_dp
            res%freq     = 0.0_dp
        end if
    end subroutine run_case

end program q1_compare_main
