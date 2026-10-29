! Hodgkin-Huxley point-neuron demonstration (E or I), RK4, dt=0.01 ms.
! Output: t_ms,V_mV,h,n. Compile via scripts/run_fortran.sh.
module hh_model
  implicit none
  integer, parameter :: dp=kind(1.0d0)
contains
  real(dp) function exprel(x)
    real(dp), intent(in) :: x
    if (abs(x)<1.d-8) then
      exprel=1.d0
    else
      exprel=x/(1.d0-exp(-x))
    end if
  end function
  subroutine rates(v,typ,am,bm,ah,bh,an,bn)
    real(dp),intent(in)::v
    character(len=1),intent(in)::typ
    real(dp),intent(out)::am,bm,ah,bh,an,bn
    if(typ=='E') then
      am=1.28d0*exprel((v+54.d0)/4.d0)
      if(abs(v+27.d0)<1.d-8) then
        bm=1.4d0
      else
        bm=0.28d0*(v+27.d0)/(exp((v+27.d0)/5.d0)-1.d0)
      end if
      ah=0.128d0*exp(-(v+50.d0)/18.d0); bh=4.d0/(1.d0+exp(-(v+27.d0)/5.d0))
      an=0.16d0*exprel((v+52.d0)/5.d0); bn=0.5d0*exp(-(v+57.d0)/40.d0)
    else
      am=0.1d0*(v+35.d0)/(1.d0-exp(-(v+35.d0)/10.d0))
      if(abs(v+35.d0)<1.d-8) am=1.d0
      bm=4.d0*exp(-(v+60.d0)/18.d0); ah=0.07d0*exp(-(v+58.d0)/20.d0)
      bh=1.d0/(1.d0+exp(-0.1d0*(v+28.d0)))
      an=0.01d0*(v+34.d0)/(1.d0-exp(-0.1d0*(v+34.d0)))
      if(abs(v+34.d0)<1.d-8) an=0.1d0
      bn=0.125d0*exp(-(v+44.d0)/80.d0)
    end if
  end subroutine
  subroutine rhs(y,typ,I,dy)
    real(dp),intent(in)::y(3),I
    character(len=1),intent(in)::typ
    real(dp),intent(out)::dy(3)
    real(dp)::v,h,n,am,bm,ah,bh,an,bn,mi,hi,ni,gna,gk,gl,ena,ek,el,fac
    v=y(1);h=y(2);n=y(3); call rates(v,typ,am,bm,ah,bh,an,bn)
    mi=am/(am+bm); hi=ah/(ah+bh); ni=an/(an+bn)
    if(typ=='E') then
      gna=100.d0;gk=80.d0;gl=0.1d0;ena=50.d0;ek=-100.d0;el=-67.d0;fac=1.d0
    else
      gna=35.d0;gk=9.d0;gl=0.1d0;ena=55.d0;ek=-90.d0;el=-65.d0;fac=0.2d0
    end if
    dy(1)=(gna*mi**3*h*(ena-v)+gk*n**4*(ek-v)+gl*(el-v)+I)
    dy(2)=(hi-h)*fac/(ah+bh);dy(3)=(ni-n)*fac/(an+bn)
  end subroutine
end module
program hh_single
  use hh_model
  implicit none
  real(dp),parameter::dt=0.01d0,tmax=30.d0
  real(dp)::y(3),k1(3),k2(3),k3(3),k4(3),tmp(3),t,I,am,bm,ah,bh,an,bn,mi
  integer::k,nsteps
  character(len=1)::typ
  character(len=128)::arg
  typ='E'; if(command_argument_count()>=1) then; call get_command_argument(1,arg); typ=arg(1:1); end if
  nsteps=int(tmax/dt); y(1)=-65.d0
  call rates(y(1),typ,am,bm,ah,bh,an,bn); y(2)=ah/(ah+bh); y(3)=an/(an+bn)
  open(10,file='hh_single.csv',status='replace');write(10,'(A)') 't_ms,V_mV,h,n'
  do k=0,nsteps
    t=k*dt;write(10,'(F10.4,A,F12.6,A,F12.8,A,F12.8)') t,',',y(1),',',y(2),',',y(3)
    I=0.d0;if(t>=5.d0.and.t<15.d0) I=3.d0
    call rhs(y,typ,I,k1);call rhs(y+0.5d0*dt*k1,typ,I,k2)
    call rhs(y+0.5d0*dt*k2,typ,I,k3);call rhs(y+dt*k3,typ,I,k4)
    y=y+dt*(k1+2.d0*k2+2.d0*k3+k4)/6.d0
  end do
  close(10)
end program
