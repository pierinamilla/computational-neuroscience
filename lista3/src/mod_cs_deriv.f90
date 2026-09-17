module mod_cs_deriv
    use mod_cs_params
    use mod_cs_gating
    implicit none
    private
    public :: cs_deriv

contains

    ! Estado: u(1)=V, u(2)=n, u(3)=m, u(4)=h, u(5)=a, u(6)=b
    pure subroutine cs_deriv(t, u, J, du)
        real(dp), intent(in)  :: t, J
        real(dp), intent(in)  :: u(:)
        real(dp), intent(out) :: du(:)
        real(dp) :: V, n, m, h, a, b
        real(dp) :: I_Na, I_K, I_L, I_A

        V = u(1); n = u(2); m = u(3); h = u(4); a = u(5); b = u(6)

        I_Na = g_Na * m**3 * h * (V - E_Na)
        I_K  = g_K  * n**4     * (V - E_K)
        I_L  = g_L             * (V - E_L)
        I_A  = g_A  * a**3 * b * (V - E_A)

        du(1) = (-I_Na - I_K - I_L - I_A + J) / C_m
        du(2) = (inf_n(V) - n) / tau_n(V)
        du(3) = (inf_m(V) - m) / tau_m(V)
        du(4) = (inf_h(V) - h) / tau_h(V)
        du(5) = (inf_a(V) - a) / tau_a(V)
        du(6) = (inf_b(V) - b) / tau_b(V)
    end subroutine cs_deriv

end module mod_cs_deriv
