program q1b_main
    use mod_cs_params, only: dp, V0, n0, m0, h0, a0, b0
    use mod_cs_deriv, only: cs_deriv
    use mod_rk4, only: rk4_step
    implicit none
    real(dp) :: u(6), u_new(6), t, dt, J, t_end
    real(dp) :: J_values(4) = [5.0_dp, 10.0_dp, 15.0_dp, 20.0_dp]
    integer  :: i, k, Nt
    character(len=64) :: fname

    dt    = 0.01_dp
    t_end = 200.0_dp
    Nt    = int(t_end/dt)

    do k = 1, size(J_values)
        write(fname,'("data/q1b_J",I0,".dat")') int(J_values(k))
        open(unit=20, file=trim(fname), status='replace')
        write(20,*) '# t  V  n  m  h  a  b  J'

        u = [V0, n0, m0, h0, a0, b0]
        t = 0.0_dp

        do i = 0, Nt
            if (t >= 60.0_dp) then
                J = J_values(k)
            else
                J = 0.0_dp
            end if

            write(20,'(8F16.8)') t, u(1), u(2), u(3), u(4), u(5), u(6), J

            call rk4_step(cs_deriv, t, u, J, dt, u_new)
            u = u_new
            t = t + dt
        end do

        close(20)
    end do
end program q1b_main
