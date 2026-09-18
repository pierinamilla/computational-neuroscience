module mod_thalamic_gating
    use mod_thalamic_params, only: dp
    implicit none
    private
    public :: alpha_m, beta_m, m_inf
    public :: alpha_h, beta_h, h_inf
    public :: alpha_n, beta_n, n_inf
    public :: mT_inf, hT_inf, tau_hT

    real(dp), parameter :: TOL = 1.0d-12

contains

    ! ---------------- Sodio: activación m ----------------
    pure function alpha_m(V) result(a)
        real(dp), intent(in) :: V
        real(dp) :: a
        real(dp), parameter :: V0 = 0.035_dp
        if (abs(V + V0) < TOL) then
            a = 1000.0_dp          ! L'Hôpital: 1e5/100
        else
            a = 1.0d5 * (V + V0) / (1.0_dp - exp(-100.0_dp * (V + V0)))
        end if
    end function alpha_m

    pure function beta_m(V) result(b)
        real(dp), intent(in) :: V
        real(dp) :: b
        b = 4000.0_dp * exp(-(V + 0.06_dp) / 0.018_dp)
    end function beta_m

    pure function m_inf(V) result(x)
        real(dp), intent(in) :: V
        real(dp) :: x, am, bm
        am = alpha_m(V); bm = beta_m(V)
        x = am / (am + bm)
    end function m_inf

    ! ---------------- Sodio: inactivación h ----------------
    pure function alpha_h(V) result(a)
        real(dp), intent(in) :: V
        real(dp) :: a
        a = 350.0_dp * exp(-50.0_dp * (V + 0.058_dp))
    end function alpha_h

    pure function beta_h(V) result(b)
        real(dp), intent(in) :: V
        real(dp) :: b
        b = 5000.0_dp / (1.0_dp + exp(-100.0_dp * (V + 0.028_dp)))
    end function beta_h

    pure function h_inf(V) result(x)
        real(dp), intent(in) :: V
        real(dp) :: x, ah, bh
        ah = alpha_h(V); bh = beta_h(V)
        x = ah / (ah + bh)
    end function h_inf

    ! ---------------- Potasio: activación n ----------------
    pure function alpha_n(V) result(a)
        real(dp), intent(in) :: V
        real(dp) :: a
        real(dp), parameter :: V0 = 0.034_dp
        if (abs(V + V0) < TOL) then
            a = 500.0_dp           ! L'Hôpital: 5e4/100
        else
            a = 5.0d4 * (V + V0) / (1.0_dp - exp(-100.0_dp * (V + V0)))
        end if
    end function alpha_n

    pure function beta_n(V) result(b)
        real(dp), intent(in) :: V
        real(dp) :: b
        b = 625.0_dp * exp(-12.5_dp * (V + 0.044_dp))
    end function beta_n

    pure function n_inf(V) result(x)
        real(dp), intent(in) :: V
        real(dp) :: x, an, bn
        an = alpha_n(V); bn = beta_n(V)
        x = an / (an + bn)
    end function n_inf

    ! ---------------- Calcio T ----------------
    pure function mT_inf(V) result(x)
        real(dp), intent(in) :: V
        real(dp) :: x
        x = 1.0_dp / (1.0_dp + exp(-(V + 0.052_dp) / 0.0074_dp))
    end function mT_inf

    pure function hT_inf(V) result(x)
        real(dp), intent(in) :: V
        real(dp) :: x
        x = 1.0_dp / (1.0_dp + exp(500.0_dp * (V + 0.076_dp)))
    end function hT_inf

    pure function tau_hT(V) result(t)
        real(dp), intent(in) :: V
        real(dp) :: t
        if (V < -0.080_dp) then
            t = 0.001_dp * exp(15.0_dp * (V + 0.467_dp))
        else
            t = 0.028_dp + 0.001_dp * exp(-(V + 0.022_dp) / 0.0105_dp)
        end if
    end function tau_hT

end module mod_thalamic_gating
