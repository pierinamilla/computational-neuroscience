program q2a_main
    use mod_thalamic_params, only: dp, V0
    use mod_thalamic_gating, only: h_inf, n_inf, hT_inf
    use mod_thalamic_deriv,  only: thalamic_deriv
    use mod_rk4_thalamic,    only: rk4_step
    implicit none

    real(dp), parameter :: dt         = 0.01d-3          ! 0.01 ms en segundos
    real(dp), parameter :: t_end      = 0.750_dp          ! 750 ms
    real(dp), parameter :: t_step_on  = 0.250_dp
    real(dp), parameter :: t_step_off = 0.500_dp

    real(dp) :: u(4), u_new(4), t, I_inj
    real(dp) :: I_base_A, I_step_A
    integer  :: i, Nt
    character(len=64) :: arg, fname

    ! Leer argumentos: I_base (pA) y I_step (pA)
    if (command_argument_count() < 2) then
        I_base_A = -100.0d-12      ! default: -100 pA
        I_step_A =   50.0d-12      ! default:  +50 pA
    else
        call get_command_argument(1, arg); read(arg,*) I_base_A
        call get_command_argument(2, arg); read(arg,*) I_step_A
        I_base_A = I_base_A * 1.0d-12   ! pA -> A
        I_step_A = I_step_A * 1.0d-12
    end if

    ! Nombre del archivo de salida
    write(fname,'("data/q2a_Ib",I0,"_Is",I0,".dat")') &
        int(I_base_A*1.0d12), int(I_step_A*1.0d12)

    ! Condiciones iniciales: reposo en V0 = E_L
    u(1) = V0
    u(2) = h_inf(V0)
    u(3) = n_inf(V0)
    u(4) = hT_inf(V0)

    t  = 0.0_dp
    Nt = int(t_end / dt)

    open(unit=20, file=trim(fname), status='replace')
    write(20,*) '# t(ms)  V(mV)  h  n  h_T  I_inj(pA)'

    do i = 0, Nt
        if (t < t_step_on) then
            I_inj = I_base_A
        else if (t < t_step_off) then
            I_inj = I_base_A + I_step_A
        else
            I_inj = I_base_A
        end if

        write(20,'(6ES16.8)') t*1.0d3, u(1)*1.0d3, u(2), u(3), u(4), I_inj*1.0d12

        call rk4_step(thalamic_deriv, t, u, I_inj, dt, u_new)
        u = u_new
        t = t + dt
    end do

    close(20)
    print *, 'Archivo generado: ', trim(fname)

end program q2a_main
