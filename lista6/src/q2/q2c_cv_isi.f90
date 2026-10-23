! Questao 2 (c): regime regular x irregular. Uso: q2c_cv_isi sigma Iabaixo Iacima
!   data/q2/q2c_trace_{abaixo,acima}.dat : t  V_sem_disparo  V_com_disparo
!   data/q2/q2c_spikes_{abaixo,acima}.dat: instantes dos disparos e ISIs
!   data/q2/q2c_stats.dat                : <ISI>, sd(ISI), CV (uma realizacao)
!   data/q2/q2c_cv_ensemble.dat          : CV medio sobre 100 sementes
program q2c_cv_isi
  use neuro_mod
  implicit none
  real(dp), parameter :: dt = 0.01_dp, tmax = 2000.0_dp
  integer, parameter :: stride = 10, nmax = int(tmax/dt)/stride + 2
  real(dp) :: sigma, Is(2), spk(20000), mu, sd, cv, I
  real(dp), allocatable :: Vf(:), Vo(:)
  integer :: nspk, nt, nt2, ic, k, js, nr
  real(dp) :: cvs(100), rates(100), cm_, cs_
  character(len=16) :: lab(2), arg
  character(len=64) :: fn
  call get_command_argument(1, arg); read(arg,*) sigma
  call get_command_argument(2, arg); read(arg,*) Is(1)
  call get_command_argument(3, arg); read(arg,*) Is(2)
  lab = (/ 'abaixo', 'acima ' /)
  allocate(Vf(nmax), Vo(nmax))
  open(30, file='data/q2/q2c_stats.dat', status='replace')
  write(30,'(A,F7.3)') '# sigma = ', sigma
  write(30,'(A)') '# caso  I[pA]  Nspk  <ISI>[ms]  sd(ISI)[ms]  CV'
  do ic = 1, 2
    call set_seed(5000 + ic)
    call run_lif(Is(ic), -1.0_dp, tbig, sigma, Vredef0, dt, tmax, 0.0_dp, 0.0_dp, spk, nspk, stride, Vo, ntr=nt)
    call set_seed(5000 + ic)                        ! mesmo ruido, disparos desligados
    call run_lif(Is(ic), -1.0_dp, tbig, sigma, Vredef0, dt, tmax, 0.0_dp, 0.0_dp, spk(1:1), nr, stride, Vf, ntr=nt2, free=.true.)
    call set_seed(5000 + ic)
    call run_lif(Is(ic), -1.0_dp, tbig, sigma, Vredef0, dt, tmax, 0.0_dp, 0.0_dp, spk, nspk)
    call isi_stats(spk, nspk, mu, sd, cv)
    write(30,'(A8,F8.1,I6,3(1x,F10.4))') trim(lab(ic)), Is(ic), nspk, mu, sd, cv
    fn = 'data/q2/q2c_trace_'//trim(lab(ic))//'.dat'
    open(31, file=trim(fn), status='replace')
    write(31,'(A)') '# t[ms]  V_sem_disparo[mV]  V_com_disparo[mV]'
    do k = 1, nt
      write(31,'(F10.3,2(1x,F10.4))') (k-1)*stride*dt, Vf(k), Vo(k)
    end do
    close(31)
    fn = 'data/q2/q2c_spikes_'//trim(lab(ic))//'.dat'
    open(31, file=trim(fn), status='replace')
    write(31,'(A)') '# k  t_k[ms]  ISI_k[ms]  (ultimo disparo: ISI = 0)'
    do k = 1, nspk
      if (k < nspk) then
        write(31,'(I5,2(1x,F12.4))') k, spk(k), spk(k+1)-spk(k)
      else
        write(31,'(I5,2(1x,F12.4))') k, spk(k), 0.0_dp
      end if
    end do
    close(31)
  end do
  close(30)
  ! ensemble: CV e taxa vs I (30 sementes por corrente), mesmo sigma
  open(32, file='data/q2/q2c_cv_ensemble.dat', status='replace')
  write(32,'(A,F7.3)') '# I[pA]  <CV>  sd(CV)  <rate>[Hz]     sigma = ', sigma
  do k = 0, 30
    I = 300.0_dp + 20.0_dp*k
    nr = 0
    do js = 1, 30
      call set_seed(900000 + 100*k + js)
      call run_lif(I, -1.0_dp, tbig, sigma, Vredef0, dt, tmax, 0.0_dp, 0.0_dp, spk, nspk)
      call isi_stats(spk, nspk, mu, sd, cv)
      if (nspk >= 3) then
        nr = nr + 1; cvs(nr) = cv
      end if
      rates(js) = nspk*1000.0_dp/tmax
    end do
    if (nr > 1) then
      cm_ = sum(cvs(1:nr))/nr; cs_ = sqrt(sum((cvs(1:nr)-cm_)**2)/(nr-1))
    else
      cm_ = 0; cs_ = 0
    end if
    write(32,'(F8.1,3(1x,F10.4))') I, cm_, cs_, sum(rates(1:30))/30
  end do
  close(32)
  print *, 'q2c ok'
end program
