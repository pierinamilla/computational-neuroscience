program q1cd_main
    use mod_cs_params, only: dp, V0, n0, m0, h0, a0, b0
    use mod_cs_deriv, only: cs_deriv
    use mod_rk4, only: rk4_step
    implicit none

    real(dp), parameter :: dt         = 0.01_dp
    real(dp), parameter :: t_end      = 200.0_dp
    real(dp), parameter :: t_stim_on  = 60.0_dp
    real(dp), parameter :: T_stim     = 140.0_dp   ! ms de estímulo

    integer,  parameter :: N_J = 11
    real(dp) :: J_values(N_J)

    real(dp) :: u(6), u_new(6), t, J, J_now
    integer  :: i, k, Nt
    integer  :: n_spikes
    real(dp) :: t_first_spike, t_prev_spike
    real(dp) :: rate_direct, rate_latency, latency_ms
    real(dp) :: V_prev
    logical  :: first_found

    real(dp), parameter :: spike_thresh = 0.0_dp   ! mV
    real(dp), parameter :: t_min_sep    = 1.0_dp   ! ms (evita doble cuenta)

    ! Rellenar J: 8.0, 8.2, ..., 10.0
    do k = 1, N_J
        J_values(k) = 8.0_dp + (k-1)*0.2_dp
    end do

    Nt = int(t_end/dt)

    open(unit=20, file='data/q1c_fI_direct.dat',  status='replace')
    open(unit=30, file='data/q1d_fI_latency.dat', status='replace')
    write(20,*) '# J    rate_Hz    n_spikes'
    write(30,*) '# J    rate_Hz    latency_ms'

    do k = 1, N_J
        J = J_values(k)
        u = [V0, n0, m0, h0, a0, b0]
        t = 0.0_dp
        n_spikes      = 0
        t_first_spike = -1.0_dp
        t_prev_spike  = -1000.0_dp
        first_found   = .false.

        do i = 0, Nt
            V_prev = u(1)

            if (t >= t_stim_on) then
                J_now = J
            else
                J_now = 0.0_dp
            end if

            call rk4_step(cs_deriv, t, u, J_now, dt, u_new)

            ! Detección de spike: cruce ascendente por spike_thresh
            if (V_prev < spike_thresh .and. u_new(1) >= spike_thresh) then
                if (t - t_prev_spike > t_min_sep) then
                    n_spikes     = n_spikes + 1
                    t_prev_spike = t
                    if (.not. first_found .and. t >= t_stim_on) then
                        t_first_spike = t
                        first_found   = .true.
                    end if
                end if
            end if

            u = u_new
            t = t + dt
        end do

        ! Tasa directa
        rate_direct = real(n_spikes, dp) * 1000.0_dp / T_stim

        ! Tasa por latencia
        if (first_found) then
            latency_ms   = t_first_spike - t_stim_on
            rate_latency = 1000.0_dp / latency_ms
        else
            latency_ms   = -1.0_dp
            rate_latency = 0.0_dp
        end if

        write(20,'(F8.2, 2X, F12.4, 2X, I6)')      J, rate_direct,  n_spikes
        write(30,'(F8.2, 2X, F12.4, 2X, F12.4)')   J, rate_latency, latency_ms

        write(*,'(A,F6.2,A,I4,A,F10.3,A,F10.3)') &
            ' J=', J, '  spikes=', n_spikes, &
            '  f_dir=', rate_direct, '  f_lat=', rate_latency
    end do

    close(20)
    close(30)

end program q1cd_main
