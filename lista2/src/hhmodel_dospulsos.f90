program hh_dospulsos
    implicit none
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(4) :: u_new, u, f
    integer :: i, itmax
    real(dp) :: dt, t
    real(dp), parameter :: g_Na = 120.0_dp, g_K = 36.0_dp, g_V = 0.3_dp
    real(dp), parameter :: E_Na = 50.0_dp, E_K = -77.0_dp, E_V = -54.4_dp
    real(dp), parameter :: Cm = 1.0_dp
    real(dp), parameter :: V0 = -65.0_dp, n0 = 0.32_dp, m0 = 0.05_dp, h0 = 0.6_dp
    real(dp) :: V, n, m, h
    real(dp) :: alpha_n, beta_n, alpha_m, beta_m, alpha_h, beta_h
    real(dp) :: J, J1, J2
    real(dp), parameter :: tol = 1.0d-10
    real(dp) :: t_total, t1, dur, L, t2
    integer :: n_spikes_total, n_spikes_after2
    integer :: i_prev_spike
    real(dp) :: Vmax_after2
    logical :: spike
    character(len=64) :: arg

    ! Defaults
    J1      = 20.0_dp
    J2      = 20.0_dp
    t_total = 100.0_dp
    dt      = 0.001_dp
    t1      = 10.0_dp
    dur     = 0.5_dp
    L       = 10.0_dp

    if (command_argument_count() >= 7) then
        call get_command_argument(1, arg); read(arg,*) J1
        call get_command_argument(2, arg); read(arg,*) J2
        call get_command_argument(3, arg); read(arg,*) t_total
        call get_command_argument(4, arg); read(arg,*) dt
        call get_command_argument(5, arg); read(arg,*) t1
        call get_command_argument(6, arg); read(arg,*) dur
        call get_command_argument(7, arg); read(arg,*) L
    end if

    t2 = t1 + L

    u = [V0, n0, m0, h0]
    itmax = int(t_total / dt)
    n_spikes_total  = 0
    n_spikes_after2 = 0
    i_prev_spike    = -1000000
    Vmax_after2     = -1000.0_dp

    open(unit=10, file='data/dos_pulsos.dat', status='replace')

    do i = 0, itmax
        t = i * dt
        V = u(1); n = u(2); m = u(3); h = u(4)

        ! Estimulo: dos pulsos
        J = 0.0_dp
        if (t >= t1      .and. t <= t1 + dur)      J = J1
        if (t >= t2      .and. t <= t2 + dur)      J = J + J2

        ! Regla de L'Hopital
        if (abs(V + 55.0_dp) < tol) then
            alpha_n = 0.1_dp
        else
            alpha_n = 0.01_dp * (V + 55.0_dp) / (1.0_dp - exp(-(V + 55.0_dp)/10.0_dp))
        end if
        beta_n = 0.125_dp * exp(-(V + 65.0_dp)/80.0_dp)

        if (abs(V + 40.0_dp) < tol) then
            alpha_m = 1.0_dp
        else
            alpha_m = 0.1_dp * (V + 40.0_dp) / (1.0_dp - exp(-(V + 40.0_dp)/10.0_dp))
        end if
        beta_m = 4.0_dp * exp(-(V + 65.0_dp)/18.0_dp)

        alpha_h = 0.07_dp * exp(-(V + 65.0_dp)/20.0_dp)
        beta_h  = 1.0_dp / (exp(-(V + 35.0_dp)/10.0_dp) + 1.0_dp)

        f(1) = (1.0_dp/Cm) * ( -g_Na * (m**3) * h * (V - E_Na) &
                              - g_K * (n**4) * (V - E_K) &
                              - g_V * (V - E_V) + J )
        f(2) = alpha_n * (1.0_dp - n) - beta_n * n
        f(3) = alpha_m * (1.0_dp - m) - beta_m * m
        f(4) = alpha_h * (1.0_dp - h) - beta_h * h

        u_new = u + dt * f

        ! Deteccion de spike (cruce ascendente por 0 mV)
        spike = .false.
        if (u(1) < 0.0_dp .and. u_new(1) >= 0.0_dp) then
            if (i - i_prev_spike > 5) then
                n_spikes_total = n_spikes_total + 1
                i_prev_spike = i
                if (t >= t2) n_spikes_after2 = n_spikes_after2 + 1
                spike = .true.
            end if
        end if

        ! Pico maximo despues del 2do pulso
        if (t >= t2 .and. u_new(1) > Vmax_after2) then
            Vmax_after2 = u_new(1)
        end if

        write(10,*) t, u(1), u(2), u(3), u(4), J
        u = u_new
    end do

    close(10)

    ! Reporte para el shell: "N_SPIKES_AFTER2 VMAX_AFTER2 N_SPIKES_TOTAL"
    write(*,'(I6, F12.4, I6)') n_spikes_after2, Vmax_after2, n_spikes_total

end program hh_dospulsos
