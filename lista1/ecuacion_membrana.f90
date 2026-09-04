program ecuacion_membrana
    !Resuelve EDO: dVm(t)/dt = (J-10^3*Gm*(Vm(t)-E))/Cm
    !Usando metodo de Euler explicito
    implicit none

    !Parametros
    integer,parameter :: itmax=80
    real :: Cm=1.0 ! capacitancia especifica(uF/cm2)
    real :: Gm=100.0 !conductancia especifica (uS/cm2)
    real :: E=0.0 !potencial de equilibrio (mV)
    real :: dt=1.0 !paso de tiempo
    real :: fc=1e-3 !Factor de correcion debido a unidades diferentes al SI
    real :: J !Densidad de cottiente (uA/cm2)
    
    !Variables
    real :: Vm(0:itmax) !Potencial de membrana absoluto en el tiempo
    integer :: it
    real :: t

    !Condicion inicial
    Vm(0)=0.0

    !Metodo de euler
    !Abrir archivo
    open(unit=10,file='p2_potencial_membrana.txt',status='unknown')
    write(unit=10,fmt='(A5, A10, A15)') 'it','t(ms)','Vm(mV)'
    do it=0,itmax-1
        t=it*dt
        if(t>=5 .and. t<50) then
                J=2.0
        else
                J=0.0
        end if
        Vm(it+1)=Vm(it)+(J-fc*Gm*(Vm(it)-E))*dt/Cm
        write(*,*) it,t,Vm(it)
        !Guardar
        write(10,*) it,t,Vm(it)
    end do
    !Cerrar archivo
    close(10)
end program ecuacion_membrana
