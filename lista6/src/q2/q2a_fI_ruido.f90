! Questao 2 (a): f-I do LIF com ruido (Euler-Maruyama). Uso: q2a_fI_ruido sig1 sig2 ...
!   Saida: data/q2/q2a_fI_sigma_<sig>.dat  (I  f[Hz])    sigma em mV/ms^(1/2)
program q2a_fI_ruido
  use neuro_mod
  implicit none
  real(dp), parameter :: dt = 0.01_dp, tmax = 2000.0_dp
  real(dp) :: I, sigma, spk(20000)
  integer :: nspk, k, ia, na
  character(len=32) :: arg
  na = command_argument_count()
  do ia = 1, na
    call get_command_argument(ia, arg); read(arg,*) sigma
    open(10, file='data/q2/q2a_fI_sigma_'//trim(arg)//'.dat', status='replace')
    write(10,'(A,F8.3)') '# I[pA]  f[Hz]   sigma = ', sigma
    do k = 0, 130
      I = 300.0_dp + 10.0_dp*k                     ! 300 ... 1600 pA
      call set_seed(100000*ia + k + 1)             ! sequencia diferente por corrente
      call run_lif(I, -1.0_dp, tbig, sigma, Vredef0, dt, tmax, 0.0_dp, 0.0_dp, spk, nspk)
      write(10,'(F8.1,1x,F12.5)') I, nspk*1000.0_dp/tmax
    end do
    close(10)
  end do
  print *, 'q2a ok'
end program
