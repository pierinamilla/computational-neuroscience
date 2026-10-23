! Questao 1 (a): curva f-I do LIF com periodo refratario; numerica x analitica
!   Saida: data/q1/q1a_fI.dat  (I[pA]  f_num[Hz]  f_analitica[Hz])
program q1a_fI_lif
  use neuro_mod
  implicit none
  real(dp), parameter :: dt = 0.01_dp, tmax = 2000.0_dp
  real(dp) :: I, spk(5000)
  integer :: nspk, k
  open(10, file='data/q1/q1a_fI.dat', status='replace')
  write(10,'(A)') '# I[pA]  f_num[Hz]  f_analitica[Hz]    (IL = 500 pA)'
  do k = 0, 120
    I = 400.0_dp + 10.0_dp*k                       ! 400 ... 1600 pA
    call run_lif(I, -1.0_dp, tbig, 0.0_dp, Vredef0, dt, tmax, 0.0_dp, 0.0_dp, spk, nspk)
    write(10,'(F8.1,2(1x,F12.5))') I, nspk*1000.0_dp/tmax, f_analitica(I, Vredef0)
  end do
  close(10)
  print *, 'q1a ok'
end program
