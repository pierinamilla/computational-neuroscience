program hh_model
    implicit none
    integer, parameter :: dp = kind(1.0d0)
    real(dp), dimension(4) :: u_new, u, f
    integer :: i, itmax
    real(dp) :: dt           ! ms
    real(dp) :: t            ! ms
    real(dp), parameter :: g_Na = 120.0_dp, g_K = 36.0_dp, g_V = 0.3_dp   ! mS/cm2
    real(dp), parameter :: E_Na = 50.0_dp, E_K = -77.0_dp, E_V = -54.4_dp ! mV
    real(dp), parameter :: Cm = 1.0_dp                                     ! uF/cm2
    real(dp), parameter :: V0 = -65.0_dp, n0 = 0.32_dp, m0 = 0.05_dp, h0 = 0.6_dp
    real(dp) :: V, n, m, h
    real(dp) :: alpha_n, beta_n, alpha_m, beta_m, alpha_h, beta_h
    real(dp) :: J=0.0_dp, J_inj
    real(dp), parameter :: tol = 1.0d-10
    real(dp), parameter :: t_total = 30.0_dp
    real(dp), parameter :: tj_i = 10.0_dp, tj_f = 20.0_dp

    ! Condición inicial
    u = [V0, n0, m0, h0]

    ! Parámetros de simulación
    dt = 0.001_dp
    itmax = int(t_total / dt)

    ! Amplitud del estímulo
    J_inj = 0.0_dp

    ! Abrir archivo
    open(unit=10, file='hh_q1.dat', status='replace')

    do i = 0, itmax
        t = i * dt

        ! Extraer variables
        V = u(1); n = u(2); m = u(3); h = u(4)

        ! Estímulo de corriente
        if (t >= tj_i .and. t <= tj_f) then
            J = J_inj
        else
            J = 0.0_dp
        end if

        ! Regla de L'Hôpital
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

        ! Función f (derivadas)
        f(1) = (1.0_dp/Cm) * ( -g_Na * (m**3) * h * (V - E_Na) &
                              - g_K * (n**4) * (V - E_K) &
                              - g_V * (V - E_V) &
                              + J )
        f(2) = alpha_n * (1.0_dp - n) - beta_n * n
        f(3) = alpha_m * (1.0_dp - m) - beta_m * m
        f(4) = alpha_h * (1.0_dp - h) - beta_h * h

        ! Método de Euler
        u_new = u + dt * f

        ! Guardar
        write(10,*) t, u(1), u(2), u(3), u(4), J

        ! Actualizar
        u = u_new
    end do

    close(10)

end program hh_model
