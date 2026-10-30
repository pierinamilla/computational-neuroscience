! =====================================================================
! Lista 8 - Introducao a Neurociencia Computacional (FFCLRP-USP)
! Redes de neuronios E (piramidal, Olufsen), I (Wang-Buzsaki) e O (OLM,
! Tort et al.) com sinapses de Ermentrout-Kopell. Integracao: RK4, dt=0,01 ms.
!
! Uso:  ./rede_EIO caso [fJ] [fg] [ftau]
!   caso : q1a | q1b | q1c | q2a | q2b | q3a | q3b | q3c | q3d
!   (q1a,q1b,q1c: fJ = J0 [uA/cm2], fg = g sinaptico [mS/cm2])
!   fJ   : fator multiplicativo de J_E        (so q3b; padrao 1)
!   fg   : fator multiplicativo de g_IE       (so q3b; padrao 1)
!   ftau : fator multiplicativo de tau_d,I    (so q3b; padrao 1)
! Saidas (pasta ../data): <tag>_V.dat  (t, V_1..V_N a cada 0,1 ms)
!                         <tag>_spk.dat (indice, tipo, tempo do disparo)
! tipos: 1 = E, 2 = I, 3 = O
! =====================================================================
module rede
  implicit none
  integer, parameter :: dp = kind(1.0d0)
  integer, parameter :: NV = 8, NMAX = 12
  integer, parameter :: TE = 1, TI = 2, TO = 3
  integer :: N
  integer :: tipo(NMAX)
  real(dp) :: gmat(NMAX,NMAX)          ! gmat(i,j): pre i -> pos j  (mS/cm2)
  real(dp) :: Jinj(NMAX)               ! corrente injetada constante (uA/cm2)
  ! sinapses por tipo do neuronio PRE-sinaptico (AMPA, GABA_A(I), GABA_A(O))
  real(dp) :: taus(3) = (/ 0.1d0, 0.3d0, 0.2d0 /)
  real(dp) :: taud(3) = (/ 3.0d0, 9.0d0, 20.0d0 /)
  real(dp) :: Erev(3) = (/ 0.0d0, -80.0d0, -80.0d0 /)
  real(dp) :: Cm(3)   = (/ 1.0d0, 1.0d0, 1.3d0 /)
  ! pulso/degrau de corrente no neuronio jp (Q1): amplitude Jp0 em [tON,tOFF)
  integer  :: jp = 0
  real(dp) :: Jp0 = 0.0d0, tON = 0.0d0, tOFF = 0.0d0
  ! indices das variaveis: 1=V 2=h 3=n 4=m 5=a 6=b 7=r 8=s
contains

  ! x/(1-exp(-x/k)) com o limite x->0 tratado (singularidades removiveis)
  function vtrap(x, k) result(f)
    real(dp), intent(in) :: x, k
    real(dp) :: f
    if (abs(x/k) < 1.0d-7) then
      f = k
    else
      f = x/(1.0d0 - exp(-x/k))
    end if
  end function vtrap

  ! x_inf e tau_x das variaveis m, h, n de cada tipo (eqs. 4-12, 15-17)
  subroutine gates(tp, V, minf, taum, hinf, tauh, ninf, taun)
    integer, intent(in)   :: tp
    real(dp), intent(in)  :: V
    real(dp), intent(out) :: minf, taum, hinf, tauh, ninf, taun
    real(dp) :: am, bm, ah, bh, an, bn, fat
    select case (tp)
    case (TE)
      am = 0.32d0*vtrap(V+54.0d0, 4.0d0)
      bm = 0.28d0*vtrap(-(V+27.0d0), 5.0d0)
      ah = 0.128d0*exp(-(V+50.0d0)/18.0d0)
      bh = 4.0d0/(1.0d0 + exp(-(V+27.0d0)/5.0d0))
      an = 0.032d0*vtrap(V+52.0d0, 5.0d0)
      bn = 0.5d0*exp(-(V+57.0d0)/40.0d0)
      fat = 1.0d0
    case (TI)
      am = 0.1d0*vtrap(V+35.0d0, 10.0d0)
      bm = 4.0d0*exp(-(V+60.0d0)/18.0d0)
      ah = 0.07d0*exp(-(V+58.0d0)/20.0d0)
      bh = 1.0d0/(exp(-0.1d0*(V+28.0d0)) + 1.0d0)
      an = 0.01d0*vtrap(V+34.0d0, 10.0d0)
      bn = 0.125d0*exp(-(V+44.0d0)/80.0d0)
      fat = 0.2d0
    case default  ! TO
      am = 0.1d0*vtrap(V+38.0d0, 10.0d0)
      bm = 4.0d0*exp(-(V+65.0d0)/18.0d0)
      ah = 0.07d0*exp(-(V+63.0d0)/20.0d0)
      bh = 1.0d0/(1.0d0 + exp(-(V+33.0d0)/10.0d0))
      an = 0.018d0*vtrap(V-25.0d0, 25.0d0)
      bn = 0.0036d0*vtrap(-(V-35.0d0), 12.0d0)
      fat = 1.0d0
    end select
    minf = am/(am+bm);  taum = 1.0d0/(am+bm)
    hinf = ah/(ah+bh);  tauh = fat/(ah+bh)
    ninf = an/(an+bn);  taun = fat/(an+bn)
  end subroutine gates

  ! lado direito do sistema completo (rede de N neuronios)
  subroutine deriv(y, dy)
    real(dp), intent(in)  :: y(NV,NMAX)
    real(dp), intent(out) :: dy(NV,NMAX)
    integer  :: i, j
    real(dp) :: V, m, h, nn, Isyn, Iion
    real(dp) :: minf, taum, hinf, tauh, ninf, taun
    real(dp) :: ainf, binf, rinf, taub, taur
    dy = 0.0d0
    do j = 1, N
      V  = y(1,j);  h = y(2,j);  nn = y(3,j)
      Isyn = 0.0d0                                   ! eq. (23)
      do i = 1, N
        if (gmat(i,j) /= 0.0d0) Isyn = Isyn + gmat(i,j)*y(8,i)*(Erev(tipo(i)) - V)
      end do
      call gates(tipo(j), V, minf, taum, hinf, tauh, ninf, taun)
      select case (tipo(j))
      case (TE)
        m = minf                                     ! m = m_inf(V)
        Iion = 100.0d0*m**3*h*(50.0d0-V) + 80.0d0*nn**4*(-100.0d0-V) + 0.1d0*(-67.0d0-V)
      case (TI)
        m = minf
        Iion = 35.0d0*m**3*h*(55.0d0-V) + 9.0d0*nn**4*(-90.0d0-V) + 0.1d0*(-65.0d0-V)
      case default
        m = y(4,j)
        ainf = 1.0d0/(1.0d0 + exp(-(V+14.0d0)/16.6d0))
        binf = 1.0d0/(1.0d0 + exp((V+71.0d0)/7.3d0))
        taub = 1.0d0/(0.000009d0/exp((V-26.0d0)/18.5d0) + 0.014d0/(0.2d0+exp(-(V+70.0d0)/11.0d0)))
        rinf = 1.0d0/(1.0d0 + exp((V+84.0d0)/10.2d0))
        taur = 1.0d0/(exp(-14.59d0-0.086d0*V) + exp(-1.87d0+0.0701d0*V))
        Iion = 30.0d0*m**3*h*(90.0d0-V) + 23.0d0*nn**4*(-100.0d0-V) &
             + 16.0d0*y(5,j)*y(6,j)*(-90.0d0-V) + 12.0d0*y(7,j)*(-32.9d0-V) &
             + 0.05d0*(-70.0d0-V)
        dy(4,j) = (minf-m)/taum
        dy(5,j) = (ainf-y(5,j))/5.0d0
        dy(6,j) = (binf-y(6,j))/taub
        dy(7,j) = (rinf-y(7,j))/taur
      end select
      dy(1,j) = (Iion + Isyn + Jinj(j))/Cm(tipo(j))
      dy(2,j) = (hinf-h)/tauh
      dy(3,j) = (ninf-nn)/taun
      dy(8,j) = 0.5d0*(1.0d0+tanh(V/4.0d0))*(1.0d0-y(8,j))/taus(tipo(j)) &
              - y(8,j)/taud(tipo(j))                  ! eq. (22)
    end do
  end subroutine deriv

  ! condicao inicial "estacionaria" em h, n (e m, a, b, r) para um dado V
  subroutine ini_estac(j, V, y)
    integer, intent(in) :: j
    real(dp), intent(in) :: V
    real(dp), intent(inout) :: y(NV,NMAX)
    real(dp) :: minf, taum, hinf, tauh, ninf, taun
    call gates(tipo(j), V, minf, taum, hinf, tauh, ninf, taun)
    y(:,j) = 0.0d0
    y(1,j) = V;  y(2,j) = hinf;  y(3,j) = ninf;  y(4,j) = minf
    y(5,j) = 1.0d0/(1.0d0 + exp(-(V+14.0d0)/16.6d0))
    y(6,j) = 1.0d0/(1.0d0 + exp((V+71.0d0)/7.3d0))
    y(7,j) = 1.0d0/(1.0d0 + exp((V+84.0d0)/10.2d0))
  end subroutine ini_estac

  subroutine ini_O(j, y)         ! valores iniciais dados no enunciado (Q2a)
    integer, intent(in) :: j
    real(dp), intent(inout) :: y(NV,NMAX)
    y(:,j) = 0.0d0
    y(1,j) = -75.61d0;  y(4,j) = 0.0122d0;  y(3,j) = 0.07561d0
    y(2,j) = 0.9152d0;  y(7,j) = 0.06123d0; y(5,j) = 0.0229d0; y(6,j) = 0.2843d0
  end subroutine ini_O

  function sorteio() result(V)   ! V ~ U(-70,-60) mV
    real(dp) :: V, u
    call random_number(u)
    V = -70.0d0 + 10.0d0*u
  end function sorteio

end module rede

! ---------------------------------------------------------------------
program rede_EIO
  use rede
  implicit none
  character(len=16) :: caso, arg
  real(dp) :: fJ, fg, ftau
  real(dp) :: y(NV,NMAX), yn(NV,NMAX), k1(NV,NMAX), k2(NV,NMAX), k3(NV,NMAX), k4(NV,NMAX)
  real(dp), parameter :: dt = 0.01d0
  real(dp) :: tmax, t, tsp
  integer  :: nsteps, it, i, j, iE, nout, uV, uS, uQ
  integer, allocatable :: seed(:)
  integer :: nseed
  character(len=64) :: fV, fS, fQ, tag

  call get_command_argument(1, caso)
  fJ = 1.0d0; fg = 1.0d0; ftau = 1.0d0
  call get_command_argument(2, arg); if (len_trim(arg) > 0) read(arg,*) fJ
  call get_command_argument(3, arg); if (len_trim(arg) > 0) read(arg,*) fg
  call get_command_argument(4, arg); if (len_trim(arg) > 0) read(arg,*) ftau

  ! semente fixa => resultados reprodutiveis
  call random_seed(size=nseed); allocate(seed(nseed)); seed = 20261030
  call random_seed(put=seed)

  gmat = 0.0d0; Jinj = 0.0d0; y = 0.0d0; tipo = 0; iE = 0
  select case (trim(caso))

  case ('q2a', 'q2b')                      ! 5 I (1-5) + 5 O (6-10), mecanismo ING
    N = 10; tmax = 1500.0d0
    tipo(1:5) = TI; tipo(6:10) = TO
    do i = 1, 5
      do j = 1, 5
        gmat(i,j) = 0.02d0                 ! I -> I (inclui autapse)
      end do
      do j = 6, 10
        gmat(i,j) = 0.12d0                 ! I -> O
        if (trim(caso) == 'q2a') gmat(j,i) = 0.04d0   ! O -> I (zero em q2b)
      end do
    end do
    Jinj(1:5) = 1.0d0;  Jinj(6:10) = -3.0d0
    do i = 1, 5; call ini_estac(i, sorteio(), y); end do
    do i = 6, 10; call ini_O(i, y); end do

  case ('q3a', 'q3b')                      ! par E-I, mecanismo PING
    N = 2
    if (trim(caso) == 'q3a') then; tmax = 200.0d0; else; tmax = 1000.0d0; end if
    tipo(1) = TE; tipo(2) = TI
    gmat(1,2) = 0.25d0                     ! E -> I
    gmat(2,1) = 0.25d0*fg                  ! I -> E
    taud(TI)  = 9.0d0*ftau
    Jinj(1) = 1.4d0*fJ;  Jinj(2) = 0.0d0
    call ini_estac(1, -65.0d0, y); call ini_estac(2, -65.0d0, y)

  case ('q3c', 'q3d')                      ! 5 I (1-5) + 5 O (6-10) + 1 E (11)
    N = 11; tmax = 1500.0d0; iE = 11
    tipo(1:5) = TI; tipo(6:10) = TO; tipo(11) = TE
    do i = 1, 5
      do j = 1, 5
        gmat(i,j) = 0.1d0                  ! g_II
      end do
      do j = 6, 10
        gmat(i,j) = 0.5d0                  ! g_IO
        if (trim(caso) == 'q3c') gmat(j,i) = 0.2d0    ! g_OI (zero em q3d)
      end do
      gmat(i,iE) = 0.1d0                   ! g_IE
      gmat(iE,i) = 0.05d0                  ! g_EI
    end do
    do j = 6, 10
      gmat(j,iE) = 0.15d0                  ! g_OE
      gmat(iE,j) = 0.01d0                  ! g_EO
    end do
    Jinj(1:5) = 0.8d0;  Jinj(6:10) = -3.0d0;  Jinj(iE) = 0.8d0
    do i = 1, 5; call ini_estac(i, sorteio(), y); end do
    do i = 6, 10; call ini_O(i, y); end do
    call ini_estac(iE, sorteio(), y)

  case ('q1a', 'q1b', 'q1c')              ! Q1: par pre -> pos, corrente externa na pre
    N = 2
    if (trim(caso) == 'q1a') then; tmax = 30.0d0;  tOFF = 15.0d0; end if
    if (trim(caso) == 'q1b') then; tmax = 100.0d0; tOFF = 15.0d0; end if
    if (trim(caso) == 'q1c') then; tmax = 500.0d0; tOFF = 450.0d0; end if
    tON = 5.0d0;  jp = 1;  Jp0 = fJ                   ! fJ = J0 (uA/cm2)
    if (trim(caso) == 'q1b') then
      tipo(1) = TI; tipo(2) = TE                      ! I -> E
    else
      tipo(1) = TE; tipo(2) = TI                      ! E -> I
    end if
    gmat(1,2) = fg                                    ! fg = g_pre,pos (mS/cm2)
    call ini_estac(1, -65.0d0, y); call ini_estac(2, -65.0d0, y)

  case default
    write(*,*) 'caso invalido: ', trim(caso); stop 1
  end select

  tag = trim(caso)
  if (trim(caso) == 'q1c') write(tag,'(A,F4.2)') 'q1c_g', fg
  fV = '../data/' // trim(tag) // '_V.dat'
  fS = '../data/' // trim(tag) // '_spk.dat'
  fQ = '../data/' // trim(tag) // '_s.dat'
  if (trim(caso) == 'q3b') then
    if (fJ /= 1.0d0)   then; fV = '../data/q3b_J_V.dat';   fS = '../data/q3b_J_spk.dat';   end if
    if (fg /= 1.0d0)   then; fV = '../data/q3b_g_V.dat';   fS = '../data/q3b_g_spk.dat';   end if
    if (ftau /= 1.0d0) then; fV = '../data/q3b_tau_V.dat'; fS = '../data/q3b_tau_spk.dat'; end if
  end if
  open(newunit=uV, file=trim(fV), status='replace')
  open(newunit=uS, file=trim(fS), status='replace')
  open(newunit=uQ, file=trim(fQ), status='replace')
  write(uV,'(A,*(1X,I1))') '# tipos', tipo(1:N)

  nsteps = nint(tmax/dt);  nout = 10
  do it = 0, nsteps - 1
    t = it*dt
    if (jp > 0) Jinj(jp) = merge(Jp0, 0.0d0, it >= nint(tON/dt) .and. it < nint(tOFF/dt))
    if (mod(it, nout) == 0) then
      write(uV,'(F10.3,*(1X,F9.4))') t, y(1,1:N)
      write(uQ,'(F10.3,*(1X,ES12.4))') t, y(8,1:N)
    end if
    call deriv(y, k1)
    yn = y + 0.5d0*dt*k1;  call deriv(yn, k2)
    yn = y + 0.5d0*dt*k2;  call deriv(yn, k3)
    yn = y + dt*k3;        call deriv(yn, k4)
    yn = y + dt/6.0d0*(k1 + 2.0d0*k2 + 2.0d0*k3 + k4)
    do j = 1, N                            ! disparo = cruzamento ascendente de 0 mV
      if (y(1,j) < 0.0d0 .and. yn(1,j) >= 0.0d0) then
        tsp = t + dt*(0.0d0 - y(1,j))/(yn(1,j) - y(1,j))
        write(uS,'(I3,1X,I2,1X,F12.5)') j, tipo(j), tsp
      end if
    end do
    y = yn
  end do
  close(uV); close(uS); close(uQ)
end program rede_EIO
