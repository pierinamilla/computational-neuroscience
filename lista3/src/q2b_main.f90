program q2b_main
    use mod_thalamic_params, only: dp, V0
    use mod_thalamic_gating, only: h_inf, n_inf, hT_inf
    use mod_thalamic_deriv,  only: thalamic_deriv
    use mod_rk4_thalamic,    only: rk4_step
    implicit none

    real(dp), parameter :: dt         = 0.01d-3
    real(dp), parameter :: t_end      = 0.750_dp
    real(dp), parameter :: t_step_on  = 0.250_dp
    real(dp), parameter :: t_step_off = 0.500_dp
    real(dp), parameter :: Vth        = 0.0_dp     ! umbral de spike (V)
    real(dp), parameter :: t_sep      = 1.0d-3     ! separación mínima entre spikes (s)

    integer, parameter :: N_Ib = 17    ! -200 a +200 paso 25
    integer, parameter :: N_Is = 11    ! 0 a +100 paso 10

    real(dp) :: Ib_list(N_Ib), Is_list(N_Is)
    real(dp) :: Ib_pA, Is_pA, I_inj
    real(dp) :: u(4), u_new(4), t
    real(dp) :: V_prev, t_last_spike, isi_min
    integer  :: i, k, m, Nt, n_spikes
    logical  :: first_spike

    ! Grillas
    do i = 1, N_Ib
        Ib_list(i) = -200.0_dp + (i-1) * 25.0_dp    ! pA
    end do
    do k = 1, N_Is
        Is_list(k) = 0.0_dp + (k-1) * 10.0_dp       ! pA
    end do

    Nt = int(t_end / dt)

    open(unit=30, file='data/q2b_sweep.dat', status='replace')
    write(30,*) '# I_base(pA)  I_step(pA)  N_spikes  ISI_min(ms)'

    do i = 1, N_Ib
        do k = 1, N_Is
            Ib_pA = Ib_list(i)
            Is_pA = Is_list(k)

            ! Reset
            u(1) = V0
            u(2) = h_inf(V0)
            u(3) = n_inf(V0)
            u(4) = hT_inf(V0)
            t = 0.0_dp
            V_prev = V0
            t_last_spike = -1.0d3
            isi_min = -1.0_dp
            n_spikes = 0
            first_spike = .false.

            do m = 0, Nt
                if (t < t_step_on) then
                    I_inj = Ib_pA * 1.0d-12
                else if (t < t_step_off) then
                    I_inj = (Ib_pA + Is_pA) * 1.0d-12
                else
                    I_inj = Ib_pA * 1.0d-12
                end if

                call rk4_step(thalamic_deriv, t, u, I_inj, dt, u_new)

                ! Detección de spike (cruce ascendente por Vth)
                if (V_prev < Vth .and. u_new(1) >= Vth) then
                    if (t - t_last_spike > t_sep) then
                        ! Solo cuenta spikes en la ventana del escalón
                        if (t >= t_step_on .and. t < t_step_off) then
                            n_spikes = n_spikes + 1
                            if (first_spike) then
                                if (isi_min < 0.0_dp .or. &
                                    (t - t_last_spike) < isi_min) then
                                    isi_min = t - t_last_spike
                                end if
                            end if
                            first_spike = .true.
                        end if
                        t_last_spike = t
                    end if
                end if

                u = u_new
                t = t + dt
                V_prev = u(1)
            end do

            ! Escribir: ISI_min en ms
            write(30,'(F10.2, 2X, F10.2, 2X, I6, 2X, F10.4)') &
                Ib_pA, Is_pA, n_spikes, isi_min*1.0d3
        end do
    end do

    close(30)
    print *, 'Archivo generado: data/q2b_sweep.dat'

end program q2b_main
