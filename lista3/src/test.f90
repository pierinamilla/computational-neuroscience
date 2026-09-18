program test_ic
    use mod_cs_params, only: dp, V0, n0, m0, h0, a0, b0
    use mod_cs_gating
    implicit none
    write(*,'(A,F10.4)') 'V0 = ', V0
    write(*,'(A,F10.6,A,F10.6)') 'n_inf(V0) = ', inf_n(V0), '   esperado n0 = ', n0
    write(*,'(A,F10.6,A,F10.6)') 'm_inf(V0) = ', inf_m(V0), '   esperado m0 = ', m0
    write(*,'(A,F10.6,A,F10.6)') 'h_inf(V0) = ', inf_h(V0), '   esperado h0 = ', h0
    write(*,'(A,F10.6,A,F10.6)') 'a_inf(V0) = ', inf_a(V0), '   esperado a0 = ', a0
    write(*,'(A,F10.6,A,F10.6)') 'b_inf(V0) = ', inf_b(V0), '   esperado b0 = ', b0
end program test_ic
