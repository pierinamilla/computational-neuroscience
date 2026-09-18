program q1f_main
    use mod_cs_params, only: dp, V0, n0, m0, h0, a0, b0
    use mod_cs_deriv_slowb, only: cs_deriv_slowb
    use mod_rk4, only: rk4_step
    implicit none

    real(dp), parameter :: dt       = 0.01_dp
    real(dp), parameter :: t_end    = 300.0_dp   ! más largo, latencia grande
    real(dp), parameter :: t_stim   = 60.0_dp
    real(dp), parameter :: J_inj    = 15.0_dp

    real(dp) :: u(6), u_new(6), t, J_now
    integer  :: i, Nt
    real(dp) :: V_prev
    real(dp) :: t_first_spike, t_prev_spike
    real(dp) :: isi_mean, isi_sum
    integer  :: n_spikes, n_isi
    logical  :: first_found

    real(dp), parameter :: spike_thresh = 0.0_dp
    real(dp), parameter :: t_min_sep    = 1.0_dp

    Nt = int(t_end/dt)

    open(unit=20, file='data/q1f.dat', status='replace')
    write(20,*) '# t  V  n  m  h  a  b  J'

    u = [V0, n0, m0, h0, a0, b0]
    t = 0.0_dp
    t_first_spike = -1.0_dp
    t_prev_spike  = -1000.0_dp
    isi_sum       = 0.0_dp
    n_isi         = 0
    n_spikes      = 0
    first_found   = .false.

    do i = 0, Nt
        if (t >= t_stim) then
            J_now = J_inj
        else
            J_now = 0.0_dp
        end if

        V_prev = u(1)
        write(20,'(8F16.8)') t, u(1), u(2), u(3), u(4), u(5), u(6), J_now

        call rk4_step(cs_deriv_slowb, t, u, J_now, dt, u_new)

        ! Detección de spike
        if (V_prev < spike_thresh .and. u_new(1) >= spike_thresh) then
            if (t - t_prev_spike > t_min_sep) then
                n_spikes = n_spikes + 1
                if (.not. first_found .and. t >= t_stim) then
                    t_first_spike = t
                    first_found   = .true.
                else if (first_found) then
                    isi_sum = isi_sum + (t - t_prev_spike)
                    n_isi   = n_isi + 1
                end if
                t_prev_spike = t
            end if
        end if

        u = u_new
        t = t + dt
    end do

    close(20)

    ! Reporte
    print *, '--- Q1f (b_inactivation x 0.25) ---'
    print *, 'n_spikes =', n_spikes
    if (first_found) then
        print *, 'Latencia del 1er spike (ms) =', t_first_spike - t_stim
    else
        print *, 'No hubo spike'
    end if
    if (n_isi > 0) then
        isi_mean = isi_sum / real(n_isi, dp)
        print *, 'ISI medio (ms) =', isi_mean
        print *, 'frecuencia (Hz) =', 1000.0_dp / isi_mean
    else
        print *, 'No hay ISIs (menos de 2 spikes)'
    end if

end program q1f_main
