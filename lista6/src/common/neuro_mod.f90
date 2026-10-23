! ======================================================================
!  neuro_mod : parametros e rotinas comuns da Lista 6 (LIF, ruido, adaptacao)
!  Unidades: tempo [ms], tensao [mV], corrente [pA], capacitancia [pF],
!            resistencia [MOhm], condutancia [nS].  (1 pA/pF = 1 mV/ms)
! ======================================================================
module neuro_mod
  implicit none
  integer,  parameter :: dp = kind(1.0d0)
  real(dp), parameter :: Vrep = -70.0_dp, Rm = 40.0_dp, Cm = 250.0_dp
  real(dp), parameter :: VL = -50.0_dp, Vredef0 = -65.0_dp, tref = 2.0_dp
  real(dp), parameter :: taum = Rm*Cm*1.0e-3_dp          ! = 10 ms
  real(dp), parameter :: Vpico = 20.0_dp                 ! so para desenhar o disparo
  real(dp), parameter :: tbig = 1.0e30_dp
  logical,  private   :: tem_spare = .false.
  real(dp), private   :: spare = 0.0_dp
contains
  pure function RI(I)                      ! R*I em mV (I em pA, R em MOhm)
    real(dp), intent(in) :: I
    real(dp) :: RI
    RI = Rm*I*1.0e-3_dp
  end function
  ! f-I analitico do LIF com periodo refratario absoluto (Hz)
  pure function f_analitica(I, Vredef) result(f)
    real(dp), intent(in) :: I, Vredef
    real(dp) :: f, x
    x = RI(I)
    if (x <= VL - Vrep) then
      f = 0.0_dp
    else
      f = 1000.0_dp/(tref + taum*log((x - (Vredef - Vrep))/(x - (VL - Vrep))))
    end if
  end function
  subroutine set_seed(k)                   ! semente diferente para cada simulacao
    integer, intent(in) :: k
    integer :: n, i
    integer, allocatable :: seed(:)
    call random_seed(size=n)
    allocate(seed(n))
    do i = 1, n
      seed(i) = int(mod(int(k,8)*2654435761_8 + int(i,8)*40503_8*7919_8 + 12345_8, 2147483647_8))
      if (seed(i) == 0) seed(i) = 1
    end do
    call random_seed(put=seed)
    tem_spare = .false.
  end subroutine
  function gauss() result(g)               ! N(0,1) por Box-Muller
    real(dp) :: g, u1, u2, r
    if (tem_spare) then
      g = spare; tem_spare = .false.; return
    end if
    call random_number(u1); call random_number(u2)
    if (u1 < 1.0e-300_dp) u1 = 1.0e-300_dp
    r = sqrt(-2.0_dp*log(u1))
    g = r*cos(2.0_dp*acos(-1.0_dp)*u2)
    spare = r*sin(2.0_dp*acos(-1.0_dp)*u2); tem_spare = .true.
  end function
  !---------------------------------------------------------------------
  !  Integracao do LIF (Euler / Euler-Maruyama) com:
  !    * corrente I aplicada em ton <= t < toff (constante: ton=-1, toff=tbig)
  !    * ruido sigma [mV/ms^1/2]            (sigma = 0  -> deterministico)
  !    * adaptacao (b [nS], taua [ms]); b = 0 desliga
  !    * free=.true. : mecanismo de disparo desligado (sem limiar/refratario)
  !  Disparo: V_{k+1} >= VL e V_k < VL ; t* por interpolacao linear (Fig. 1).
  !  O gaussiano e' sorteado em TODO passo (mesmo no refratario), assim a
  !  trajetoria com e sem disparos usa exatamente o mesmo ruido.
  !---------------------------------------------------------------------
  subroutine run_lif(I, ton, toff, sigma, Vredef, dt, tmax, b, taua, spk, nspk, &
                     stride, Vtr, Gtr, ntr, free)
    real(dp), intent(in)  :: I, ton, toff, sigma, Vredef, dt, tmax, b, taua
    real(dp), intent(out) :: spk(:)
    integer,  intent(out) :: nspk
    integer,  intent(in),  optional :: stride
    real(dp), intent(out), optional :: Vtr(:), Gtr(:)
    integer,  intent(out), optional :: ntr
    logical,  intent(in),  optional :: free
    integer  :: n, nsteps, st, m
    real(dp) :: t, V, Vn, G, Gn, Iap, xi, refend, tstar, sq
    logical  :: fr, rec, disparou, pend
    fr = .false.; if (present(free)) fr = free
    rec = present(Vtr)
    st = 1; if (present(stride)) st = stride
    nsteps = nint(tmax/dt); sq = sqrt(dt)
    V = Vrep; G = 0.0_dp; refend = -1.0_dp; nspk = 0; m = 0; pend = .false.
    if (rec) then
      Vtr(1) = V; if (present(Gtr)) Gtr(1) = G; m = 1
    end if
    do n = 0, nsteps-1
      t = n*dt
      xi = 0.0_dp; if (sigma > 0.0_dp) xi = gauss()
      Iap = 0.0_dp; if (t >= ton .and. t < toff) Iap = I
      disparou = .false.
      if (.not. fr .and. t < refend) then            ! periodo refratario absoluto
        Vn = Vredef
        Gn = G; if (taua > 0.0_dp) Gn = G - dt*G/taua
      else
        Vn = V + dt*((Vrep - V)/taum + G*(Vredef - V)/Cm + Iap/Cm) + sigma*sq*xi
        Gn = G; if (taua > 0.0_dp) Gn = G - dt*G/taua
        if (.not. fr .and. Vn >= VL .and. V < VL) then
          tstar = t + dt*(VL - V)/(Vn - V)
          nspk = nspk + 1
          if (nspk <= size(spk)) spk(nspk) = tstar
          refend = tstar + tref
          disparou = .true.
        end if
      end if
      V = Vn; G = Gn
      if (disparou) then                              ! disparo "posto a mao"
        pend = .true.; V = Vredef; G = G + b
      end if
      if (rec .and. mod(n+1, st) == 0) then
        m = m + 1
        if (pend) then
          Vtr(m) = Vpico; pend = .false.             ! pico aparece na amostra seguinte ao disparo
        else
          Vtr(m) = V
        end if
        if (present(Gtr)) Gtr(m) = G
      end if
    end do
    if (present(ntr)) ntr = m
  end subroutine
  subroutine isi_stats(spk, nspk, mu, sd, cv)
    real(dp), intent(in)  :: spk(:)
    integer,  intent(in)  :: nspk
    real(dp), intent(out) :: mu, sd, cv
    real(dp), allocatable :: isi(:)
    integer :: k
    mu = 0.0_dp; sd = 0.0_dp; cv = 0.0_dp
    if (nspk < 3) return
    allocate(isi(nspk-1))
    do k = 1, nspk-1
      isi(k) = spk(k+1) - spk(k)
    end do
    mu = sum(isi)/size(isi)
    sd = sqrt(sum((isi-mu)**2)/(size(isi)-1))      ! desvio padrao amostral
    cv = sd/mu
  end subroutine
end module neuro_mod
