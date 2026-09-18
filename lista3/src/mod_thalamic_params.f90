module mod_thalamic_params
    implicit none
    integer, parameter :: dp = kind(1.0d0)

    ! --- Capacitancia (F) ---
    real(dp), parameter :: C = 100.0d-12

    ! --- Conductancias (S) ---
    real(dp), parameter :: G_L  = 10.0d-9
    real(dp), parameter :: G_Na =  3.6d-6
    real(dp), parameter :: G_K  =  1.6d-6
    real(dp), parameter :: G_T  =  0.22d-6

    ! --- Potenciales de reversión (V) ---
    real(dp), parameter :: E_L  = -70.0d-3
    real(dp), parameter :: E_Na =  55.0d-3
    real(dp), parameter :: E_K  = -90.0d-3
    real(dp), parameter :: E_Ca = 120.0d-3

    ! --- Voltaje inicial: en reposo, V = E_L ---
    real(dp), parameter :: V0 = E_L

end module mod_thalamic_params
