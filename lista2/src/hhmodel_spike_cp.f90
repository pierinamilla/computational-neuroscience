program hh_model_spike
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
    real(dp) :: J, J_inj
    real(dp), parameter :: tol = 1.0d-10
    real(dp) :: t_total, tj_i, tj_f
    integer :: n_spikes, i_prev_spike
    logical :: spike
    character(len=64) :: arg

    ! Defaults
    J_inj   = 0.0_dp
    t_total = 30.0_dp
    dt      = 0.001_dp
    tj_i    = 10.0_dp
    tj_f    = 10.5_dp

    ! Leer argumentos: J, t_total, dt, tj_i, tj_f
    if (command_argument_count() >= 5) then
        call get_command_argument(1, arg); read(arg,*) J_inj
        call get_command_argument(2, arg); read(arg,*) t_total
        call get_command_argument(3, arg); read(arg,*) dt
        call get_command_argument(4, arg); read(arg,*) tj_i
        call get_command_argument(5, arg); read(arg,*) tj_f
    end if

    u = [V0, n0, m0, h0]
    itmax = int(t_total / dt)
    spike = .false.
    n_spikes = 0
    i_prev_spike = -1000000   ! muy negativo para el primer pico

    open(unit=10, file='data/data_spike.txt', status='replace')

    do i = 0, itmax
        t = i * dt
        V = u(1); n = u(2); m = u(3); h = u(4)

        if (t >= tj_i .and. t <= tj_f) then
            J = J_inj
        else
            J = 0.0_dp
        end if

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
                              - g_V * (V - E_V) &
                              + J )
        f(2) = alpha_n * (1.0_dp - n) - beta_n * n
        f(3) = alpha_m * (1.0_dp - m) - beta_m * m
        f(4) = alpha_h * (1.0_dp - h) - beta_h * h

        u_new = u + dt * f

        ! Deteccion de pico: cruce ascendente de 0 mV
        if (u(1) < 0.0_dp .and. u_new(1) >= 0.0_dp) then
            if (i - i_prev_spike > 5) then   ! evita doble conteo
                n_spikes = n_spikes + 1
                i_prev_spike = i
            end if
        end if

        write(10,*) t, u(1), u(2), u(3), u(4), J
        u = u_new
    end do

    close(10)

    ! Reportar numero de spikes a pantalla
    write(*,*) "SPIKES:", n_spikes

end program hh_model_spike
