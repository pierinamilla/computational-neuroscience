module mod_rk4
    use mod_cs_params, only: dp
    implicit none
    private
    public :: rk4_step

    abstract interface
        pure subroutine deriv_iface(t, u, J, du)
            import :: dp
            real(dp), intent(in)  :: t, J
            real(dp), intent(in)  :: u(:)
            real(dp), intent(out) :: du(:)
        end subroutine deriv_iface
    end interface

contains

    subroutine rk4_step(f, t, u, J, h, u_new)
        procedure(deriv_iface) :: f
        real(dp), intent(in)  :: t, J, h
        real(dp), intent(in)  :: u(:)
        real(dp), intent(out) :: u_new(:)
        real(dp), allocatable :: k1(:), k2(:), k3(:), k4(:), utmp(:)

        allocate(k1(size(u)), k2(size(u)), k3(size(u)), k4(size(u)), utmp(size(u)))

        call f(t, u, J, k1)
        utmp = u + 0.5_dp * h * k1
        call f(t + 0.5_dp*h, utmp, J, k2)
        utmp = u + 0.5_dp * h * k2
        call f(t + 0.5_dp*h, utmp, J, k3)
        utmp = u + h * k3
        call f(t + h, utmp, J, k4)

        u_new = u + (h/6.0_dp) * (k1 + 2.0_dp*k2 + 2.0_dp*k3 + k4)
    end subroutine rk4_step

end module mod_rk4
