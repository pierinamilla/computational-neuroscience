program ecuacion_membrana_si
    !Resuelve EDO: dVm(t)/dt = (J-Gm*(Vm(t)-E))/Cm
    !Usando metodo de Euler explicito
    implicit none

    !Parametros
    integer,parameter :: itmax=80

    !Variables
    real :: Cm_uF=1.0 ! capacitancia especifica(uF/cm2)
    real :: Gm_uS=100.0 !conductancia especifica (uS/cm2)
    real :: E_mV=0.0 !potencial de equilibrio (mV)
    real :: dt_ms=1.0 !paso de tiempo (ms)
    real :: fc=1. !Factor de correcion debido a unidades diferentes al SI
    real :: J_uA !Densidad de cottiente (uA/cm2)
    
    real :: Vm(0:itmax) !Potencial de membrana absoluto en el tiempo
    integer :: it
    real :: tmin_j_ms,tmax_j_ms!Variables de estimulo de corriente(ms)
   
    
    !Conversión a SI
    real :: Cm=Cm_uF*1e-2
    real :: Gm=Gm_uS*1e-2
    real :: E=E_mV*1e-3
    real :: dt=dt_ms*1e-3
    !real :: t=t_ms*1e-3
    real :: tmin_j=tmin_j_ms*1e-3,tmax_j=tmax_j_ms*1e-3
    real :: J

    !Condicion inicial
    Vm(0)=0.0

    !Metodo de euler
    !Abrir archivo
    open(unit=10,file='potencial_membrana_si.txt',status='unknown')
    write(unit=10,fmt='(A5, A10, A15)') 'it','t(ms)','Vm(mV)'
    do it=0,itmax-1
        t=it*dt
        if(t>=tmin_j .and. t<tmax_j) then
                J_uA=2.0
        else
                J_uA=0.0
                
        end if
        J=J_uA*1e-2 !Conversión a SI de densidad de corriente
        Vm(it+1)=Vm(it)+(J-fc*Gm*(Vm(it)-E))*dt/Cm
        write(*,*) it,t,Vm(it)
        !Guardar
        write(10,*) it,t,Vm(it)
    end do
    !Cerrar archivo
    close(10)
end program ecuacion_membrana_si
