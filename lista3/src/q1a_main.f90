program q1a_main
    use mod_cs_params, only: dp
    use mod_cs_gating
    implicit none
    real(dp) :: V, dV
    integer :: i, N

    dV = 0.1_dp
    N  = int(200.0_dp / dV)

    open(unit=10, file='data/q1a_curvas.dat', status='replace')
    write(10,*) '# V  ninf  minf  hinf  ainf  binf  taun  taum  tauh  taua  taub'

    do i = 0, N
        V = -100.0_dp + i*dV
        write(10,'(11F16.8)') V, inf_n(V), inf_m(V), inf_h(V), &
                              inf_a(V), inf_b(V), &
                              tau_n(V), tau_m(V), tau_h(V), &
                              tau_a(V), tau_b(V)
    end do

    close(10)
end program q1a_main
