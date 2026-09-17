module mod_cs_gating
        use mod_cs_gating, only:dp
        implicit none
        private
        public :: alpha_n, beta_n, alpha_m, beta_m, alpha_h, beta_h
        public :: inf_n, tau_n, inf_m, tau_m, inf_h, tau_h
        public :: inf_a, tau_a, inf_b, tau_b

        real(dp), parameter :: tol=1.0d-10

contains
        !Tasas alpha y beta ajustadas por COnnor Stevens
        !V:ms,t:ms
        pure function alpha_n(V) result(a)
                real(dp), intent(in) :: V
                real(dp) :: a
                real(dp), parameter :: V0=45.7_dp
                if abs(V+V0)<tol then
                        a=0.1_dp
                else
                        a=0.01_dp*(V+V0)/(1.0_dp-exp(-0.1_dp*(V+V0)))
                end if
        end function alpha_n

        pure function beta_n(V) result(b)
                real(dp), intent(in) :: V
                real(dp)::b
                real(dp),parameter :: V0=55.7_dp
                b=0.125*exp(-0.0125*(V+V0))
        end function beta_n

        ! αm: offset en -29.7, límite L'Hôpital = 1.0
        pure function alpha_m(V) result(a)
            real(dp), intent(in) :: V
            real(dp) :: a
            real(dp), parameter :: V0 = 29.7_dp
            if (abs(V + V0) < TOL) then
                a = 1.0_dp
            else
                a = 0.1_dp * (V + V0) / (1.0_dp - exp(-0.1_dp * (V + V0)))
            end if
        end function alpha_m

        pure function beta_m(V) result(b)
            real(dp), intent(in) :: V
            real(dp) :: b
            b = 4.0_dp * exp(-0.0556_dp * (V + 54.7_dp))
        end function beta_m

        pure function alpha_h(V) result(a)
            real(dp), intent(in) :: V
            real(dp) :: a
            a = 0.07_dp * exp(-0.05_dp * (V + 48.0_dp))
        end function alpha_h

        pure function beta_h(V) result(b)
            real(dp), intent(in) :: V
            real(dp) :: b
            b = 1.0_dp / (1.0_dp + exp(-0.1_dp * (V + 18.0_dp)))
        end function beta_h

    ! ------------------------------------------------------------------
    !  Estados estacionarios y constantes de tiempo
    !  Factores de temperatura: 3.8 en denominador, 2 en numerador de τn
    ! ------------------------------------------------------------------
        pure function inf_n(V) result(x)
            real(dp), intent(in) :: V
            real(dp) :: x, an, bn
            an = alpha_n(V); bn = beta_n(V)
            x = an / (an + bn)
        end function inf_n

        pure function tau_n(V) result(t)
            real(dp), intent(in) :: V
            real(dp) :: t, an, bn
            an = alpha_n(V); bn = beta_n(V)
            t = 2.0_dp / (3.8_dp * (an + bn))
        end function tau_n

        pure function inf_m(V) result(x)
            real(dp), intent(in) :: V
            real(dp) :: x, am, bm
            am = alpha_m(V); bm = beta_m(V)
            x = am / (am + bm)
        end function inf_m

        pure function tau_m(V) result(t)
            real(dp), intent(in) :: V
            real(dp) :: t, am, bm
            am = alpha_m(V); bm = beta_m(V)
            t = 1.0_dp / (3.8_dp * (am + bm))
        end function tau_m

        pure function inf_h(V) result(x)
            real(dp), intent(in) :: V
            real(dp) :: x, ah, bh
            ah = alpha_h(V); bh = beta_h(V)
            x = ah / (ah + bh)
        end function inf_h

        pure function tau_h(V) result(t)
            real(dp), intent(in) :: V
            real(dp) :: t, ah, bh
            ah = alpha_h(V); bh = beta_h(V)
            t = 1.0_dp / (3.8_dp * (ah + bh))
        end function tau_h

    ! ------------------------------------------------------------------
    !  Corriente A (Connor-Stevens / Ermentrout)
    ! ------------------------------------------------------------------
        pure function inf_a(V) result(x)
            real(dp), intent(in) :: V
            real(dp) :: x, num, den
            num = 0.0761_dp * exp(0.0314_dp * (V + 94.22_dp))
            den = 1.0_dp + exp(0.0346_dp * (V + 1.17_dp))
            x = (num / den)**(1.0_dp/3.0_dp)
        end function inf_a

        pure function tau_a(V) result(t)
            real(dp), intent(in) :: V
            real(dp) :: t
            t = 0.3632_dp + 1.158_dp / (1.0_dp + exp(0.0497_dp * (V + 55.96_dp)))
        end function tau_a

        pure function inf_b(V) result(x)
            real(dp), intent(in) :: V
            real(dp) :: x
            x = (1.0_dp / (1.0_dp + exp(0.0688_dp * (V + 53.3_dp))))**4
        end function inf_b

        pure function tau_b(V) result(t)
            real(dp), intent(in) :: V
            real(dp) :: t
            t = 1.24_dp + 2.678_dp / (1.0_dp + exp(0.0624_dp * (V + 50.0_dp)))
        end function tau_b      

end module mod_cs_gating
