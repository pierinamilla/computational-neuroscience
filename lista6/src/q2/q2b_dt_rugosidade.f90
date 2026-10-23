! Questao 2 (b): rugosidade da trajetoria subliminar vs passo de tempo.
! O MESMO caminho browniano (ruido sorteado no passo mais fino) e' agregado
! para os passos maiores, de modo que as trajetorias sao diretamente comparaveis.
! Uso: q2b_dt_rugosidade sigma [I]       (I = 300 pA por padrao)
program q2b_dt_rugosidade
  use neuro_mod
  implicit none
  integer, parameter :: nlev = 5
  real(dp), parameter :: dtf = 1.0e-5_dp, tmax = 20.0_dp
  real(dp) :: dts(nlev), sigma, I, V, dt, dW, t, dV, sabs, s2, sd2, vold
  real(dp), allocatable :: xi(:)
  integer :: nf, lev, m, n, nsteps, k, strideo
  character(len=64) :: arg, fn
  call get_command_argument(1, arg); read(arg,*) sigma
  I = 300.0_dp
  if (command_argument_count() > 1) then
    call get_command_argument(2, arg); read(arg,*) I
  end if
  dts = (/ 1.0e-2_dp, 1.0e-3_dp, 1.0e-4_dp, 1.0e-5_dp, 1.0e-5_dp /)
  nf = nint(tmax/dtf)
  allocate(xi(nf)); call set_seed(777)
  do k = 1, nf
    xi(k) = gauss()
  end do
  open(20, file='data/q2/q2b_metricas.dat', status='replace')
  write(20,'(A)') '# dt[ms]  mean|dV|[mV]  rms(dV)[mV]  QV=sum(dV^2)[mV^2]  rms(dV/dt)[mV/ms]   sigma^2*T'
  do lev = 1, nlev-1
    dt = dts(lev); m = nint(dt/dtf); nsteps = nint(tmax/dt)
    write(fn,'(A,I0,A)') 'data/q2/q2b_traj_dt', lev, '.dat'
    open(21, file=trim(fn), status='replace')
    write(fn,'(A,I0,A)') 'data/q2/q2b_zoom_dt', lev, '.dat'
    open(22, file=trim(fn), status='replace')
    write(21,'(A,ES10.2)') '# t[ms] V[mV]  dt = ', dt
    write(22,'(A,ES10.2)') '# t[ms] V[mV]  dt = ', dt
    strideo = max(1, nint(1.0e-4_dp/dt))
    V = Vrep; sabs = 0; s2 = 0; sd2 = 0
    write(21,'(2(1x,ES14.6))') 0.0_dp, V
    do n = 0, nsteps-1
      t = n*dt
      dW = sqrt(dtf)*sum(xi(n*m+1:(n+1)*m))
      vold = V
      V = V + dt*((Vrep - V)/taum + I/Cm) + sigma*dW
      dV = V - vold
      sabs = sabs + abs(dV); s2 = s2 + dV**2; sd2 = sd2 + (dV/dt)**2
      if (mod(n+1, strideo) == 0) write(21,'(2(1x,ES14.6))') (n+1)*dt, V
      if ((n+1)*dt >= 10.0_dp .and. (n+1)*dt <= 10.5_dp) write(22,'(2(1x,ES14.6))') (n+1)*dt, V
    end do
    write(20,'(ES10.2,4(1x,ES14.6),1x,ES14.6)') dt, sabs/nsteps, sqrt(s2/nsteps), s2, sqrt(sd2/nsteps), sigma**2*tmax
    close(21); close(22)
  end do
  close(20)
  print *, 'q2b ok'
end program
