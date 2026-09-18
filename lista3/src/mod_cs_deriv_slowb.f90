module mod_cs_deriv_slowb
    use mod_cs_params
    use mod_cs_gating
    implicit none
    private
    public :: cs_deriv_slowb

    real(dp), parameter :: B_SCALE = 0.25_dp

contains

    ! Igual que cs_deriv pero con db/dt multiplicado por 0.25
    pure subroutine cs_deriv_slowb(t, u, J, du)
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
        du(6) = B_SCALE * (inf_b(V) - b) / tau_b(V)   ! <-- factor 0.25
    end subroutine cs_deriv_slowb

end module mod_cs_deriv_slowb
