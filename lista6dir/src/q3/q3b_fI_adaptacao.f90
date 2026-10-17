! Questao 3 (b): f1 = 1/T1 e f_inf = 1/T_inf vs I (400..800 pA, passo 20 pA), T = 5 s
!   data/q3/q3b_fI.dat      : I  Nspk  T1  Tinf  f1  finf      (T em ms, f em Hz)
!   data/q3/q3b_fI_fino.dat : varredura fina perto de IL = 500 pA (so f1)
program q3b_fI_adaptacao
  use neuro_mod
  implicit none
  real(dp), parameter :: dt = 0.01_dp, tmax = 5000.0_dp, Vredef = -80.0_dp
  real(dp), parameter :: b = 1.0_dp, taua = 200.0_dp
  real(dp) :: I, spk(5000), T1, Tinf, f1, finf
  integer :: nspk, k
  open(10, file='data/q3/q3b_fI.dat', status='replace')
  write(10,'(A)') '# I[pA]  Nspk  T1[ms]  Tinf[ms]  f1[Hz]  finf[Hz]   (0 = indefinido)'
  do k = 0, 20
    I = 400.0_dp + 20.0_dp*k
    call medidas(I)
    write(10,'(F8.1,I6,4(1x,F12.4))') I, nspk, T1, Tinf, f1, finf
  end do
  close(10)
  open(11, file='data/q3/q3b_fI_fino.dat', status='replace')
  write(11,'(A)') '# I[pA]  Nspk  T1[ms]  Tinf[ms]  f1[Hz]  finf[Hz]'
  do k = 0, 40
    I = 500.0_dp + 0.05_dp*k**2 /1.0_dp             ! 500 ... 580 pA, mais denso perto de IL
    call medidas(I)
    write(11,'(F9.3,I6,4(1x,F12.4))') I, nspk, T1, Tinf, f1, finf
  end do
  close(11)
  print *, 'q3b ok'
contains
  subroutine medidas(I)
    real(dp), intent(in) :: I
    call run_lif(I, -1.0_dp, tbig, 0.0_dp, Vredef, dt, tmax, b, taua, spk, nspk)
    T1 = 0; Tinf = 0; f1 = 0; finf = 0
    if (nspk >= 2) then
      T1 = spk(2) - spk(1); f1 = 1000.0_dp/T1
    end if
    if (nspk >= 3) then
      Tinf = spk(nspk) - spk(nspk-1); finf = 1000.0_dp/Tinf   ! ultimo ISI (regime estacionario)
    end if
  end subroutine
end program
