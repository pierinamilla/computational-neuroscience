program q1e_main
    use mod_cs_params, only: dp, V0, n0, m0, h0, a0, b0
    use mod_cs_deriv, only: cs_deriv
    use mod_rk4, only: rk4_step
    implicit none

    real(dp), parameter :: dt        = 0.01_dp
    real(dp), parameter :: t_end     = 200.0_dp
    real(dp), parameter :: t_neg_on  = 60.0_dp
    real(dp), parameter :: t_neg_off = 65.0_dp
    real(dp), parameter :: J_neg     = -50.0_dp
    real(dp), parameter :: J_pos     =  20.0_dp

    real(dp) :: u(6), u_new(6), t, J_now
    integer  :: i, Nt

    Nt = int(t_end/dt)

    open(unit=20, file='data/q1e.dat', status='replace')
    write(20,*) '# t  V  n  m  h  a  b  J'

    u = [V0, n0, m0, h0, a0, b0]
    t = 0.0_dp

    do i = 0, Nt
        ! Protocolo de corriente
        if (t < t_neg_on) then
            J_now = 0.0_dp
        else if (t < t_neg_off) then
            J_now = J_neg
        else
            J_now = J_pos
        end if

        write(20,'(8F16.8)') t, u(1), u(2), u(3), u(4), u(5), u(6), J_now

        call rk4_step(cs_deriv, t, u, J_now, dt, u_new)
        u = u_new
        t = t + dt
    end do

    close(20)
    print *, 'q1e.dat generado'

end program q1e_main
