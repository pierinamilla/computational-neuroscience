! Questao 3 (a): LIF com corrente adaptativa; pulso I = 501 pA entre 0,5 e 1,0 s
!   data/q3/q3a_trace.dat (t[ms] I[pA] V[mV] Ga[nS]) ; data/q3/q3a_spikes.dat
program q3a_pulso_adaptacao
  use neuro_mod
  implicit none
  real(dp), parameter :: dt = 0.01_dp, tmax = 1500.0_dp, Ip = 501.0_dp
  real(dp), parameter :: Vredef = -80.0_dp, b = 1.0_dp, taua = 200.0_dp
  integer, parameter :: stride = 10, nmax = int(tmax/dt)/stride + 2
  real(dp) :: spk(2000), t
  real(dp), allocatable :: V(:), G(:)
  integer :: nspk, nt, k
  allocate(V(nmax), G(nmax))
  call run_lif(Ip, 500.0_dp, 1000.0_dp, 0.0_dp, Vredef, dt, tmax, b, taua, spk, nspk, stride, V, G, nt)
  open(10, file='data/q3/q3a_trace.dat', status='replace')
  write(10,'(A)') '# t[ms]  I[pA]  V[mV]  Ga[nS]'
  do k = 1, nt
    t = (k-1)*stride*dt
    write(10,'(F10.3,F8.1,2(1x,F12.5))') t, merge(Ip, 0.0_dp, t >= 500.0_dp .and. t < 1000.0_dp), V(k), G(k)
  end do
  close(10)
  open(11, file='data/q3/q3a_spikes.dat', status='replace')
  write(11,'(A)') '# k  t_k[ms]  ISI_k[ms]  (ultimo disparo: ISI = 0)'
  do k = 1, nspk
    if (k < nspk) then
      write(11,'(I4,2(1x,F12.4))') k, spk(k), spk(k+1)-spk(k)
    else
      write(11,'(I4,2(1x,F12.4))') k, spk(k), 0.0_dp
    end if
  end do
  close(11)
  print *, 'q3a ok: ', nspk, ' disparos; t1 = ', spk(1) - 500.0_dp, ' ms apos o inicio do pulso'
end program
