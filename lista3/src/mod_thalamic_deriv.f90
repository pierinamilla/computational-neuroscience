module mod_thalamic_deriv
    use mod_thalamic_params
    use mod_thalamic_gating
    implicit none
    private
    public :: thalamic_deriv

contains

    ! Estado: u(1)=V, u(2)=h, u(3)=n, u(4)=h_T
    ! m y m_T son algebraicos (evaluados en su steady state)
    pure subroutine thalamic_deriv(t, u, I_inj, du)
        real(dp), intent(in)  :: t, I_inj
        real(dp), intent(in)  :: u(:)
        real(dp), intent(out) :: du(:)
        real(dp) :: V, h, n, hT, m, mT
        real(dp) :: I_L, I_Na, I_K, I_T

        V  = u(1); h  = u(2); n  = u(3); hT = u(4)
        m  = m_inf(V)
        mT = mT_inf(V)

        I_L  = G_L  * (V - E_L)
        I_Na = G_Na * m**3 * h * (V - E_Na)
        I_K  = G_K  * n**4     * (V - E_K)
        I_T  = G_T  * mT**2 * hT * (V - E_Ca)

        du(1) = (-I_L - I_Na - I_K - I_T + I_inj) / C
        du(2) = alpha_h(V) * (1.0_dp - h) - beta_h(V) * h
        du(3) = alpha_n(V) * (1.0_dp - n) - beta_n(V) * n
        du(4) = (hT_inf(V) - hT) / tau_hT(V)
    end subroutine thalamic_deriv

end module mod_thalamic_deriv
