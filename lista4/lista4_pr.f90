module pr_model
  implicit none
  integer, parameter :: dp = kind(1.0d0)

  type :: Params
     real(dp) :: p
     real(dp) :: C_s, C_d
     real(dp) :: GLs, GLd, GNa, GK, GCa, GKCa, GKAHP, Gc, Gh
     real(dp) :: ENa, EK, ECa, EL, Eh
     real(dp) :: tauCa, kCa
  end type Params

contains

  pure real(dp) function sexp(x)
    real(dp), intent(in) :: x
    if (x > 700.0_dp) then
       sexp = exp(700.0_dp)
    else if (x < -700.0_dp) then
       sexp = exp(-700.0_dp)
    else
       sexp = exp(x)
    end if
  end function sexp

  pure real(dp) function x_over_expm1(x)
    real(dp), intent(in) :: x
    if (abs(x) < 1.0e-7_dp) then
       x_over_expm1 = 1.0_dp - x/2.0_dp + x*x/12.0_dp
    else
       x_over_expm1 = x/(sexp(x)-1.0_dp)
    end if
  end function x_over_expm1

  pure real(dp) function logistic(z)
    real(dp), intent(in) :: z
    if (z >= 0.0_dp) then
       logistic = 1.0_dp/(1.0_dp + sexp(-z))
    else
       logistic = sexp(z)/(1.0_dp + sexp(z))
    end if
  end function logistic

  subroutine set_base(P, Gc_nS, k_M_per_C)
    type(Params), intent(out) :: P
    real(dp), intent(in) :: Gc_nS, k_M_per_C
    P%p = 1.0_dp/3.0_dp

    P%C_s   = P%p*100.0e-12_dp
    P%C_d   = (1.0_dp-P%p)*100.0e-12_dp

    P%GLs   = P%p*5.0e-9_dp
    P%GLd   = (1.0_dp-P%p)*5.0e-9_dp
    P%GNa   = P%p*3.0e-6_dp
    P%GK    = P%p*2.0e-6_dp
    P%GCa   = (1.0_dp-P%p)*2.0e-6_dp
    P%GKCa  = (1.0_dp-P%p)*2.5e-6_dp
    P%GKAHP = (1.0_dp-P%p)*40.0e-9_dp
    P%Gc    = Gc_nS*1.0e-9_dp
    P%Gh    = 0.0_dp

    P%ENa =  0.060_dp
    P%EK  = -0.075_dp
    P%ECa =  0.080_dp
    P%EL  = -0.060_dp
    P%Eh  = -0.020_dp

    P%tauCa = 50.0e-3_dp
    P%kCa   = k_M_per_C
  end subroutine set_base

  subroutine set_q6(P, Gh_nS)
    type(Params), intent(out) :: P
    real(dp), intent(in) :: Gh_nS
    P%p = 1.0_dp/3.0_dp

    P%C_s   = P%p*100.0e-12_dp
    P%C_d   = (1.0_dp-P%p)*100.0e-12_dp

    P%GLs   = P%p*1.0e-9_dp
    P%GLd   = (1.0_dp-P%p)*1.0e-9_dp
    P%GNa   = P%p*3.0e-6_dp
    P%GK    = P%p*2.0e-6_dp
    P%GCa   = (1.0_dp-P%p)*2.5e-6_dp
    P%GKCa  = (1.0_dp-P%p)*5.0e-6_dp
    P%GKAHP = (1.0_dp-P%p)*0.06e-6_dp
    P%Gc    = 25.0e-9_dp
    P%Gh    = Gh_nS*1.0e-9_dp

    P%ENa =  0.060_dp
    P%EK  = -0.075_dp
    P%ECa =  0.080_dp
    P%EL  = -0.060_dp
    P%Eh  = -0.020_dp

    P%tauCa = 50.0e-3_dp
    P%kCa   = 1.0e6_dp/(1.0_dp-P%p)
  end subroutine set_q6

  subroutine rates(Vs,Vd,Ca, am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi)
    real(dp), intent(in) :: Vs,Vd,Ca
    real(dp), intent(out) :: am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi
    real(dp) :: x

    ! Soma: sodium activation m, sodium inactivation h, K activation n.
    x = 250.0_dp*(Vs+0.0469_dp)
    am = 320.0e3_dp*(Vs+0.0469_dp)/(1.0_dp-sexp(-x))
    if (abs(Vs+0.0469_dp) < 1.0e-9_dp) am = 320.0e3_dp/250.0_dp

    x = 200.0_dp*(Vs+0.0199_dp)
    if (abs(x) < 1.0e-7_dp) then
       bm = 280.0e3_dp/200.0_dp
    else
       bm = 280.0e3_dp*(Vs+0.0199_dp)/(sexp(x)-1.0_dp)
    end if

    ah = 128.0_dp*sexp(-55.556_dp*(Vs+0.043_dp))
    bh = 4000.0_dp/(1.0_dp+sexp(-200.0_dp*(Vs+0.020_dp)))

    x = 200.0_dp*(Vs+0.0249_dp)
    an = 16.0e3_dp*(Vs+0.0249_dp)/(1.0_dp-sexp(-x))
    if (abs(Vs+0.0249_dp) < 1.0e-9_dp) an = 16.0e3_dp/200.0_dp
    bn = 250.0_dp*sexp(-25.0_dp*(Vs+0.040_dp))

    ! Dendritic Ca activation.
    amCa = 1600.0_dp/(1.0_dp+sexp(-72.0_dp*(Vd-0.005_dp)))
    if (abs(Vd+0.0089_dp) < 1.0e-9_dp) then
       bmCa = 100.0_dp
    else
       bmCa = 2.0e4_dp*(Vd+0.0089_dp)/(sexp(200.0_dp*(Vd+0.0089_dp))-1.0_dp)
    end if

    ! Fast Ca-dependent K activation.
    if (Vd > -0.010_dp) then
       amKCa = 2000.0_dp*sexp(-37.037_dp*(Vd+0.0535_dp))
       bmKCa = 0.0_dp
    else
       amKCa = sexp((Vd+0.050_dp)/0.011_dp - &
                    (Vd+0.0535_dp)/0.027_dp)/0.018975_dp
       bmKCa = 2000.0_dp*sexp(-(Vd+0.0535_dp)/0.027_dp) - amKCa
       bmKCa = max(bmKCa,0.0_dp)
    end if

    chi = min(4000.0_dp*Ca,1.0_dp)

    ! Slow AHP K activation, Ca-dependent.
    amA = min(20.0_dp,20000.0_dp*Ca)
    bA  = 4.0_dp
  end subroutine rates

  subroutine rhs(y, P, IS, ID, dy)
    type(Params), intent(in) :: P
    real(dp), intent(in) :: y(:), IS, ID
    real(dp), intent(out) :: dy(size(y))

    real(dp) :: Vs,Vd,Ca,m,h,n,mCa,mKCa,mA,mh
    real(dp) :: am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi
    real(dp) :: mh_inf,tau_mh

    Vs=y(1); Vd=y(2); Ca=y(3)
    m=y(4); h=y(5); n=y(6); mCa=y(7); mKCa=y(8); mA=y(9)
    mh=0.0_dp
    if (size(y) >= 10) mh=y(10)

    call rates(Vs,Vd,Ca,am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi)

    dy=0.0_dp

    dy(1) = ( -P%GLs*(Vs-P%EL) &
              -P%GNa*m*m*h*(Vs-P%ENa) &
              -P%GK*n*n*(Vs-P%EK) &
              +P%Gc*(Vd-Vs) + IS )/P%C_s

    dy(2) = ( -P%GLd*(Vd-P%EL) &
              -P%GCa*mCa*mCa*(Vd-P%ECa) &
              -P%GKCa*mKCa*chi*(Vd-P%EK) &
              -P%GKAHP*mA*(Vd-P%EK) &
              -P%Gh*mh*(Vd-P%Eh) &
              +P%Gc*(Vs-Vd) + ID )/P%C_d

    dy(3) = -Ca/P%tauCa - P%kCa*P%GCa*mCa*mCa*(Vd-P%ECa)

    dy(4) = am*(1.0_dp-m)-bm*m
    dy(5) = ah*(1.0_dp-h)-bh*h
    dy(6) = an*(1.0_dp-n)-bn*n
    dy(7) = amCa*(1.0_dp-mCa)-bmCa*mCa
    dy(8) = amKCa*(1.0_dp-mKCa)-bmKCa*mKCa
    dy(9) = amA*(1.0_dp-mA)-bA*mA

    if (size(y) >= 10) then
       mh_inf = 1.0_dp/(1.0_dp+sexp(166.667_dp*(Vd+0.070_dp)))
       tau_mh = 0.272_dp + 1.499_dp/(1.0_dp+sexp(-114.548_dp*(Vd+0.0422_dp)))
       dy(10)=(mh_inf-mh)/tau_mh
    end if
  end subroutine rhs

  subroutine rk4(y,dt,P,IS,ID)
    real(dp), intent(inout) :: y(:)
    real(dp), intent(in) :: dt,IS,ID
    type(Params), intent(in) :: P
    real(dp), allocatable :: k1(:),k2(:),k3(:),k4(:),yt(:)
    integer :: n
    n=size(y)
    allocate(k1(n),k2(n),k3(n),k4(n),yt(n))
    call rhs(y,P,IS,ID,k1)
    yt=y+0.5_dp*dt*k1
    call rhs(yt,P,IS,ID,k2)
    yt=y+0.5_dp*dt*k2
    call rhs(yt,P,IS,ID,k3)
    yt=y+dt*k3
    call rhs(yt,P,IS,ID,k4)
    y=y+dt*(k1+2.0_dp*k2+2.0_dp*k3+k4)/6.0_dp
    deallocate(k1,k2,k3,k4,yt)
  end subroutine rk4

  subroutine init(y, P, steady)
    real(dp), intent(out) :: y(:)
    type(Params), intent(in) :: P
    logical, intent(in) :: steady
    real(dp) :: am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi
    real(dp) :: Vs,Vd,Ca

    y=0.0_dp
    Vs=P%EL; Vd=P%EL; Ca=0.0_dp
    y(1)=Vs; y(2)=Vd; y(3)=Ca

    if (.not.steady) then
       y(4)=0.0_dp; y(5)=0.5_dp; y(6)=0.4_dp
       y(7)=0.0_dp; y(8)=0.2_dp; y(9)=0.2_dp
    else
       call rates(Vs,Vd,Ca,am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi)
       y(4)=am/(am+bm)
       y(5)=ah/(ah+bh)
       y(6)=an/(an+bn)
       y(7)=amCa/(amCa+bmCa)
       y(8)=amKCa/(amKCa+bmKCa)
       y(9)=amA/(amA+bA)
    end if

    if (size(y)>=10) then
       y(10)=1.0_dp/(1.0_dp+sexp(166.667_dp*(Vd+0.070_dp)))
    end if
  end subroutine init

  subroutine write_state(u,t,y)
    integer, intent(in) :: u
    real(dp), intent(in) :: t,y(:)
    write(u,'(es16.8,1x,10(es16.8,1x))') t,y
  end subroutine write_state

end module pr_model


program lista4
  use pr_model
  implicit none

  character(len=32) :: mode
  call get_command_argument(1,mode)

  select case(trim(mode))
  case('q1'); call q1()
  case('q2'); call q2()
  case('q3'); call q3()
  case('q4'); call q4()
  case('q5'); call q5()
  case('q6'); call q6()
  case default
     print *, 'Uso: ./lista4 q1|q2|q3|q4|q5|q6'
  end select

contains

  subroutine q1()
    type(Params) :: P
    real(dp) :: V,Ca,am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi
    integer :: i,nv,nc
    call set_base(P,20.0_dp,3.75e6_dp)
    nv=2701; nc=1001

    open(10,file='q1_voltage.dat',status='replace')
    do i=0,nv-1
       V=(-0.085_dp + 0.135_dp*real(i,dp)/real(nv-1,dp))
       ! Fix: usar V tanto para Vs como para Vd, para ver la dependencia
       ! completa de todas las tasas del dendrito con la voltaje.
       call rates(V, V, 0.0_dp, am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi)
       write(10,'(11(es18.10,1x))') V*1000.0_dp,am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa
    end do
    close(10)

    open(11,file='q1_ca.dat',status='replace')
    do i=0,nc-1
       Ca=2.0e-3_dp*real(i,dp)/real(nc-1,dp)
       call rates(-0.060_dp,-0.060_dp,Ca,am,bm,ah,bh,an,bn,amCa,bmCa,amKCa,bmKCa,amA,bA,chi)
       write(11,'(4(es18.10,1x))') Ca,amA,bA,chi
    end do
    close(11)
    print *, 'Q1: q1_voltage.dat and q1_ca.dat generated.'
  end subroutine q1

  subroutine q2()
    type(Params) :: P
    real(dp) :: y(10),dt,t,IS,ID,prev
    integer :: i,n,spk,armed,save_every
    call set_base(P,20.0_dp,3.75e6_dp)
    call init(y,P,.false.)
    dt=1.0e-6_dp; n=int(2.0_dp/dt); save_every=10
    open(20,file='q2.dat',status='replace')
    call write_state(20,0.0_dp,y)
    prev=y(1); spk=0; armed=1
    do i=1,n
       t=i*dt; IS=0.0_dp; ID=0.0_dp
       call rk4(y,dt,P,IS,ID)
       if (armed==1 .and. prev < -0.010_dp .and. y(1)>=-0.010_dp) then
          spk=spk+1; armed=0
       end if
       if (armed==0 .and. y(1)<-0.030_dp) armed=1
       prev=y(1)
       if(mod(i,save_every)==0) call write_state(20,t,y)
    end do
    close(20)
    print *, 'Q2: somatic spikes = ',spk
  end subroutine q2

  subroutine q3()
    type(Params) :: P
    real(dp) :: y(10),dt,t,prev,ID,IS
    real(dp),dimension(4) :: gcs
    integer :: i,j,n,spk,armed,save_every,u
    character(len=16) :: mode_name
    gcs=(/0.0_dp,10.0e-9_dp,50.0e-9_dp,100.0e-9_dp/)
    dt=2.0e-6_dp; n=int(2.0_dp/dt); save_every=10
    do j=1,4
       call set_base(P,gcs(j)*1.0e9_dp,3.75e6_dp)
       call init(y,P,.false.)
       write(mode_name,'(i0)') int(gcs(j)*1.0e9_dp)
       u=30+j
       open(u,file='q3_Gc_'//trim(mode_name)//'nS.dat',status='replace')
       call write_state(u,0.0_dp,y)
       prev=y(1); spk=0; armed=1
       do i=1,n
          t=i*dt; IS=0.0_dp; ID=0.0_dp
          call rk4(y,dt,P,IS,ID)
          if (armed==1 .and. prev < -0.010_dp .and. y(1)>=-0.010_dp) then
             spk=spk+1; armed=0
          end if
          if (armed==0 .and. y(1)<-0.030_dp) armed=1
          prev=y(1)
          if(mod(i,save_every)==0) call write_state(u,t,y)
       end do
       close(u)
       print '(a,f6.1,a,i4)', 'Q3 Gc=',gcs(j)*1.0e9_dp,' nS: spikes=',spk
    end do
  end subroutine q3

  subroutine q4()
    type(Params) :: P
    real(dp) :: y(10),dt,t,prev,IS,ID
    real(dp),dimension(4) :: gcs
    integer :: i,j,n,spk,armed,save_every,u
    character(len=16) :: mode_name
    gcs=(/0.0_dp,10.0e-9_dp,50.0e-9_dp,100.0e-9_dp/)
    dt=2.0e-6_dp; n=int(2.0_dp/dt); save_every=10
    do j=1,4
       call set_base(P,gcs(j)*1.0e9_dp,7.5e6_dp)
       call init(y,P,.false.)
       write(mode_name,'(i0)') int(gcs(j)*1.0e9_dp)
       u=40+j
       open(u,file='q4_Gc_'//trim(mode_name)//'nS.dat',status='replace')
       call write_state(u,0.0_dp,y)
       prev=y(1); spk=0; armed=1
       do i=1,n
          t=i*dt; IS=0.0_dp; ID=0.0_dp
          call rk4(y,dt,P,IS,ID)
          if (armed==1 .and. prev < -0.010_dp .and. y(1)>=-0.010_dp) then
             spk=spk+1; armed=0
          end if
          if (armed==0 .and. y(1)<-0.030_dp) armed=1
          prev=y(1)
          if(mod(i,save_every)==0) call write_state(u,t,y)
       end do
       close(u)
       print '(a,f6.1,a,i4)', 'Q4 (2k) Gc=',gcs(j)*1.0e9_dp,' nS: spikes=',spk
    end do
  end subroutine q4

  subroutine q5()
    type(Params) :: P
    real(dp) :: y(10),dt,t,prev,IS,ID
    real(dp),dimension(3) :: Ilist
    integer :: i,j,n,spk,armed,save_every,u
    character(len=16) :: s
    Ilist=(/50.0e-12_dp,100.0e-12_dp,200.0e-12_dp/)
    call set_base(P,50.0_dp,7.5e6_dp)
    dt=1.0e-6_dp; n=int(6.0_dp/dt); save_every=50

    ! Current injected in the dendrite: IS=0, ID=Ilist.
    do j=1,3
       call init(y,P,.false.)
       write(s,'(i0)') int(Ilist(j)*1.0e12_dp)
       u=50+j
       open(u,file='q5_ID_'//trim(s)//'pA.dat',status='replace')
       call write_state(u,0.0_dp,y)
       prev=y(1); spk=0; armed=1
       do i=1,n
          t=i*dt; IS=0.0_dp; ID=Ilist(j)
          call rk4(y,dt,P,IS,ID)
          if (armed==1 .and. prev < -0.010_dp .and. y(1)>=-0.010_dp) then
             spk=spk+1; armed=0
          end if
          if (armed==0 .and. y(1)<-0.030_dp) armed=1
          prev=y(1)
          if(mod(i,save_every)==0) call write_state(u,t,y)
       end do
       close(u)
       print '(a,i4,a,i4)', 'Q5 dendrite ID=',int(Ilist(j)*1e12_dp),' pA: spikes=',spk
    end do

    ! Current injected in the soma: ID=0, IS=Ilist.
    do j=1,3
       call init(y,P,.false.)
       write(s,'(i0)') int(Ilist(j)*1.0e12_dp)
       u=70+j
       open(u,file='q5_IS_'//trim(s)//'pA.dat',status='replace')
       call write_state(u,0.0_dp,y)
       prev=y(1); spk=0; armed=1
       do i=1,n
          t=i*dt; IS=Ilist(j); ID=0.0_dp
          call rk4(y,dt,P,IS,ID)
          if (armed==1 .and. prev < -0.010_dp .and. y(1)>=-0.010_dp) then
             spk=spk+1; armed=0
          end if
          if (armed==0 .and. y(1)<-0.030_dp) armed=1
          prev=y(1)
          if(mod(i,save_every)==0) call write_state(u,t,y)
       end do
       close(u)
       print '(a,i4,a,i4)', 'Q5 soma IS=',int(Ilist(j)*1e12_dp),' pA: spikes=',spk
    end do
  end subroutine q5

  subroutine q6()
    type(Params) :: P
    real(dp) :: y(10),dt,t,IS,ID,prevD
    real(dp) :: mh_inf,tau_mh,V
    real(dp), allocatable :: ts(:),vs(:),vd(:),burst_starts(:)
    real(dp),dimension(4) :: ghlist
    integer :: i,j,n,save_every,u,nsave,k,n_bursts
    integer :: inburst !, tpn_idx
    real(dp) :: tpn, t_rel_ms
    character(len=16) :: ss
    logical :: got_penultimate

    ! --- Q6a: mh_inf and tau_mh vs V_D ---
    open(70,file='q6_mh_rates.dat',status='replace')
    do i=0,1000
       V=-0.100_dp + 0.100_dp*real(i,dp)/1000.0_dp
       mh_inf=1.0_dp/(1.0_dp+sexp(166.667_dp*(V+0.070_dp)))
       tau_mh=0.272_dp + 1.499_dp/(1.0_dp+sexp(-114.548_dp*(V+0.0422_dp)))
       write(70,'(3(es18.10,1x))') V*1000.0_dp,mh_inf,tau_mh
    end do
    close(70)

    ! --- Q6b: 6 s simulations ---
    ghlist=(/0.0_dp,5.0_dp,10.0_dp,15.0_dp/)
    dt=1.0e-6_dp; n=int(6.0_dp/dt); save_every=100
    nsave=n/save_every+1
    allocate(ts(0:nsave-1),vs(0:nsave-1),vd(0:nsave-1))
    allocate(burst_starts(1:nsave))

    do j=1,4
       call set_q6(P,ghlist(j))
       call init(y,P,.false.)
       y(10)=1.0_dp/(1.0_dp+sexp(166.667_dp*(y(2)+0.070_dp)))
       write(ss,'(i0)') int(ghlist(j))

       u=60+j
       open(u,file='q6_Gh_'//trim(ss)//'nS.dat',status='replace')
       call write_state(u,0.0_dp,y)

       ts(0)=0.0_dp; vs(0)=y(1); vd(0)=y(2)
       inburst=0; prevD=y(2); k=1; n_bursts=0

       do i=1,n
          t=i*dt; IS=0.0_dp; ID=0.0_dp
          call rk4(y,dt,P,IS,ID)

          ! Inicio de burst: VD cruza 0 mV desde abajo
          if(inburst==0 .and. prevD<0.0_dp .and. y(2)>=0.0_dp) then
             inburst=1
             n_bursts = n_bursts + 1
             if(n_bursts <= nsave) burst_starts(n_bursts) = t
          end if
          ! Fin de burst: VD < -50 mV
          if(inburst==1 .and. y(2)<-0.050_dp) inburst=0
          prevD=y(2)

          if(mod(i,save_every)==0 .and. k<=nsave-1) then
             call write_state(u,t,y)
             ts(k)=t; vs(k)=y(1); vd(k)=y(2); k=k+1
          end if
       end do
       close(u)

       ! Buscar el penúltimo burst en [2, 6] s (igual que Python)
       tpn = -1.0_dp
       got_penultimate = .false.
       do i = n_bursts, 1, -1
          if(burst_starts(i) >= 2.0_dp .and. burst_starts(i) <= 6.0_dp) then
             if(.not. got_penultimate) then
                ! este es el ultimo en [2,6]; guardar y seguir
                tpn = burst_starts(i)
                got_penultimate = .true.
             else
                ! este es el penultimo
                tpn = burst_starts(i)
                exit
             end if
          end if
       end do

       if(tpn < 0.0_dp) then
          print '(a,f5.1,a)', 'Q6 Gh=',ghlist(j),' nS: no burst in [2,6] s.'
          cycle
       end if

       print '(a,f5.1,a,i3,a,f8.4,a)', 'Q6 Gh=',ghlist(j), &
          ' nS: total bursts=', n_bursts, ' tpn=', tpn, ' s'

       ! Escribir el zoom: ±25 ms alrededor de tpn, eje en ms
       open(80+j, file='q6_Gh_'//trim(ss)//'nS_zoom.dat', status='replace')
       do i=0, k-1
          t_rel_ms = (ts(i) - tpn) * 1000.0_dp   ! ms relativo a tpn
          if(t_rel_ms >= -25.0_dp .and. t_rel_ms <= 25.0_dp) then
             write(80+j,'(3(es18.10,1x))') t_rel_ms, vs(i), vd(i)
          end if
       end do
       close(80+j)
    end do

    deallocate(ts,vs,vd,burst_starts)
  end subroutine q6

end program lista4
