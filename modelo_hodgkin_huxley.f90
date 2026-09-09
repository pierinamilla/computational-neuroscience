program hm_model
    implicit none
    real(dp),dimension(4) :: u_new,u

    
    do i=0,itmax
        !Metodo de Euler
        u_new=u+dt*f

    enddo



end program hm_model
