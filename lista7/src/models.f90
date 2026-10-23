module models
 implicit none
 real(8),parameter::dt=.001d0
contains
 subroutine rhs(kind,v,u,I,dv,du)
 integer,intent(in)::kind
 real(8),intent(in)::v,u,I
 real(8),intent(out)::dv,du
 real(8)::C,G,vr,vl,dl,a,tau,k,b,p
 select case(kind)
 case(1)
 C=100;G=10;vr=-70;vl=-50;dl=2;a=2;tau=200
 dv=(-G*(v-vr)+G*dl*exp(min(60d0,(v-vl)/dl))-u+I)/C
 du=(a*(v-vr)-u)/tau
 case(2)
 C=150;vr=-75;vl=-45;k=1.2d0;a=.01d0;b=5
 dv=(k*(v-vr)*(v-vl)-u+I)/C;du=a*(b*(v-vr)-u)
 case(3)
 C=50;vr=-60;vl=-40;k=1.5d0;a=.03d0;b=1
 dv=(k*(v-vr)*(v-vl)-u+I)/C;du=a*(b*(v-vr)-u)
 case(4)
 C=25;vr=-50;vl=-30;k=1;a=.5d0;b=25;p=.009d0
 dv=(k*(v-vr)*(v-vl)-u+I)/C;du=a*(b*(v-vr)+p*(v-vr)**3-u)
 end select
 end subroutine
 subroutine run(kind,Iamp,tmax,on,off,filename)
 integer,intent(in)::kind
 real(8),intent(in)::Iamp,tmax,on,off
 character(*),intent(in)::filename
 real(8)::v,u,I,t,dv,du,vnew,unew,peak,reset,jump
 integer::j,n,unit
 select case(kind)
 case(1);v=-70;peak=50;reset=-80;jump=20
 case(2);v=-75;peak=50;reset=-56;jump=130
 case(3);v=-60;peak=25;reset=-40;jump=150
 case(4);v=-50;peak=10;reset=-40;jump=0
 end select
 u=0;open(newunit=unit,file=filename,status='replace')
 write(unit,'(a)') 't,V,u,I,spike,reset'
 n=nint(tmax/dt)
 do j=0,n
 t=j*dt;I=0
 if(t>=on.and.t<off)I=Iamp
 if(mod(j,100)==0)write(unit,'(f12.5,a,f14.6,a,f14.6,a,f12.4,a,i1,a,i1)')t,',',v,',',u,',',I,',',0,',',0
 if(j==n)exit
 call rhs(kind,v,u,I,dv,du)
 vnew=v+dt*dv;unew=u+dt*du
 if(vnew>=peak)then
 write(unit,'(f12.5,a,f14.6,a,f14.6,a,f12.4,a,i1,a,i1)')t+dt,',',peak,',',unew,',',I,',',1,',',0
 vnew=reset;unew=unew+jump
 write(unit,'(f12.5,a,f14.6,a,f14.6,a,f12.4,a,i1,a,i1)')t+dt,',',vnew,',',unew,',',I,',',0,',',1
 endif
 v=vnew;u=unew
 enddo
 close(unit)
 end subroutine
end module
