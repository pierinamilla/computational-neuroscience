program hh_dospulsos
    implicit none
    integer, parameter :: dp = kind(1.0d0)
    real(dp), parameter :: g_Na=120.0_dp, g_K=36.0_dp, g_V=0.3_dp
    real(dp), parameter :: E_Na=50.0_dp, E_K=-77.0_dp, E_V=-54.4_dp
    real(dp), parameter :: Cm=1.0_dp, V0=-65.0_dp, n0=0.32_dp
    real(dp), parameter :: m0=0.05_dp, h0=0.6_dp, tol=1.0d-10
    real(dp) :: J1,J2,t_total,dt,t1,dur,L,t,t2,J
    real(dp) :: V,n,m,h,Vn,nn,mn,hn
    real(dp) :: alpha_n,beta_n,alpha_m,beta_m,alpha_h,beta_h
    real(dp) :: t_cross1,t_cross2,Vmax2
    integer :: i,itmax,ncross,ap2,ios
    character(len=64) :: arg

    J1=100.0_dp; J2=100.0_dp; t_total=100.0_dp; dt=0.001_dp
    t1=10.0_dp; dur=0.5_dp; L=10.0_dp
    if (command_argument_count() < 7) stop 'Uso: J1 J2 T dt t1 dur L'
    call get_command_argument(1,arg); read(arg,*) J1
    call get_command_argument(2,arg); read(arg,*) J2
    call get_command_argument(3,arg); read(arg,*) t_total
    call get_command_argument(4,arg); read(arg,*) dt
    call get_command_argument(5,arg); read(arg,*) t1
    call get_command_argument(6,arg); read(arg,*) dur
    call get_command_argument(7,arg); read(arg,*) L

    t2=t1+L
    itmax=nint(t_total/dt)
    V=V0; n=n0; m=m0; h=h0
    ncross=0; t_cross1=-1.0_dp; t_cross2=-1.0_dp
    Vmax2=-huge(1.0_dp); ap2=0

    open(10,file='data/dos_pulsos.dat',status='replace',iostat=ios)
    if (ios /= 0) stop 'No se pudo abrir data/dos_pulsos.dat'

    do i=0,itmax
        t=i*dt
        J=0.0_dp
        if (t >= t1 .and. t < t1+dur) J=J+J1
        if (t >= t2 .and. t < t2+dur) J=J+J2

        if (abs(V+55.0_dp) < tol) then
            alpha_n=0.1_dp
        else
            alpha_n=0.01_dp*(V+55.0_dp)/(1.0_dp-exp(-(V+55.0_dp)/10.0_dp))
        end if
        beta_n=0.125_dp*exp(-(V+65.0_dp)/80.0_dp)
        if (abs(V+40.0_dp) < tol) then
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

        ! Um potencial de ação é identificado por um cruzamento ascendente de 0 mV.
        if (V < 0.0_dp .and. Vn >= 0.0_dp) then
            ncross=ncross+1
            if (ncross == 1) t_cross1=t+dt
            if (ncross == 2) t_cross2=t+dt
        end if

        if (t >= t2 .and. Vn > Vmax2) Vmax2=Vn

        write(10,'(6ES18.8)') t,V,n,m,h,J
        V=Vn; n=nn; m=mn; h=hn
    end do
    close(10)

    ! O primeiro spike deve ter acontecido antes do segundo pulso;
    ! o segundo cruzamento de 0 mV deve ocorrer a partir de t2.
    if (t_cross1 >= t1 .and. t_cross1 < t2 .and. t_cross2 >= t2) ap2=1

    ! Saida: AP2  t_cruzamento1  t_cruzamento2  Vmax_despues_t2  N_cross
    write(*,'(I2,1X,F12.5,1X,F12.5,1X,F12.5,1X,I4)') &
        ap2,t_cross1,t_cross2,Vmax2,ncross
end program hh_dospulsos

