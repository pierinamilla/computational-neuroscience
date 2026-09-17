module mod_cs_params
    implicit none
    integer, parameter :: dp = kind(1.0d0)

    ! Conductancias máximas (mS/cm²)
    real(dp), parameter :: g_Na = 120.0_dp
    real(dp), parameter :: g_K  =  20.0_dp
    real(dp), parameter :: g_L  =   0.3_dp
    real(dp), parameter :: g_A  =  47.7_dp

    ! Potenciales de reversión (mV)
    real(dp), parameter :: E_Na =  55.0_dp
    real(dp), parameter :: E_K  = -72.0_dp
    real(dp), parameter :: E_L  = -17.0_dp
    real(dp), parameter :: E_A  = -75.0_dp

    ! Capacitancia específica (µF/cm²)
    real(dp), parameter :: C_m = 1.0_dp

    ! Condiciones iniciales de Ermentrout
    real(dp), parameter :: V0 = -67.976_dp
    real(dp), parameter :: n0 =   0.1558_dp
    real(dp), parameter :: m0 =   0.01_dp
    real(dp), parameter :: h0 =   0.965_dp
    real(dp), parameter :: a0 =   0.5404_dp
    real(dp), parameter :: b0 =   0.2885_dp

end module mod_cs_params
