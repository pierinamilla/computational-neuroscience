program hh_anodo
    implicit none
    integer, parameter :: dp=kind(1.0d0)
    real(dp), parameter :: g_Na=120.0_dp,g_K=36.0_dp,g_V=0.3_dp
    real(dp), parameter :: E_Na=50.0_dp,E_K=-77.0_dp,E_V=-54.4_dp,Cm=1.0_dp
    real(dp), parameter :: V0=-65.0_dp,n0=0.32_dp,m0=0.05_dp,h0=0.6_dp
    real(dp), parameter :: Jinj=-15.0_dp,tol=1.0d-10
    real(dp) :: T,t_total,dt,t_i,t_f,tnow,J,V,n,m,h,Vn,nn,mn,hn
    real(dp) :: alpha_n,beta_n,alpha_m,beta_m,alpha_h,beta_h
    real(dp) :: t_ap,delay,Vmax
    integer :: i,itmax,ap,ios
    character(len=64) :: arg

    T=0.5_dp; t_total=30.0_dp; dt=0.001_dp; t_i=5.0_dp
    if (command_argument_count() < 1) stop 'Uso: T [t_total] [dt]'
    call get_command_argument(1,arg); read(arg,*) T
    if (command_argument_count() >= 2) then
        call get_command_argument(2,arg); read(arg,*) t_total
    end if
    if (command_argument_count() >= 3) then
        call get_command_argument(3,arg); read(arg,*) dt
    end if

    t_f=t_i+T; itmax=nint(t_total/dt)
    V=V0; n=n0; m=m0; h=h0
    t_ap=-1.0_dp; Vmax=-huge(1.0_dp)

    open(10,file='data/anodo.dat',status='replace',iostat=ios)
    if (ios /= 0) stop 'No se pudo abrir data/anodo.dat'

    do i=0,itmax
        tnow=i*dt
        J=0.0_dp
        if (tnow >= t_i .and. tnow < t_f) J=Jinj

        if (abs(V+55.0_dp)<tol) then
            alpha_n=0.1_dp
        else
            alpha_n=0.01_dp*(V+55.0_dp)/(1.0_dp-exp(-(V+55.0_dp)/10.0_dp))
        end if
        beta_n=0.125_dp*exp(-(V+65.0_dp)/80.0_dp)
        if (abs(V+40.0_dp)<tol) then
            alpha_m=1.0_dp
        else
            alpha_m=0.1_dp*(V+40.0_dp)/(1.0_dp-exp(-(V+40.0_dp)/10.0_dp))
        end if
        beta_m=4.0_dp*exp(-(V+65.0_dp)/18.0_dp)
        alpha_h=0.07_dp*exp(-(V+65.0_dp)/20.0_dp)
        beta_h=1.0_dp/(exp(-(V+35.0_dp)/10.0_dp)+1.0_dp)

        Vn=V+dt*((-g_Na*m**3*h*(V-E_Na)-g_K*n**4*(V-E_K) &
                  -g_V*(V-E_V)+J)/Cm)
        nn=n+dt*(alpha_n*(1.0_dp-n)-beta_n*n)
        mn=m+dt*(alpha_m*(1.0_dp-m)-beta_m*m)
        hn=h+dt*(alpha_h*(1.0_dp-h)-beta_h*h)

        if (tnow >= t_f .and. Vn>Vmax) Vmax=Vn
        ! Criterio pedido en Q7: inicio del PA cuando V >= 20 mV.
        if (tnow >= t_f .and. t_ap < 0.0_dp .and. V < 20.0_dp .and. Vn >= 20.0_dp) &
            t_ap=tnow+dt

        write(10,'(3ES18.8)') tnow,V,J
        V=Vn; n=nn; m=mn; h=hn
    end do
    close(10)

    ap=0
    if (t_ap >= 0.0_dp) ap=1
    if (ap==1) then
        delay=t_ap-t_f
    else
        delay=-1.0_dp
    end if
    write(*,'(I2,1X,F10.5,1X,F10.5,1X,F10.5)') ap,t_ap,delay,Vmax
end program hh_anodo
