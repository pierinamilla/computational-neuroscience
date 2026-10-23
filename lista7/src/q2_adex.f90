module q2_core
 implicit none
 real(8),parameter::dt=.001d0,vr=-70d0,vl=-50d0,delta=2d0,G=2d0,peak=20d0
contains
 subroutine simulate(label,tau_m,a,tau,b,reset,amp,tmax,on,off,filename)
 character(*),intent(in)::label,filename
 real(8),intent(in)::tau_m,a,tau,b,reset,amp,tmax,on,off
 real(8)::v,u,t,I,dv,du,vnext,unext,C,ex
 integer::j,n,unit
 C=G*tau_m;v=vr;u=0;n=nint(tmax/dt)
 open(newunit=unit,file=filename,status='replace')
 write(unit,'(a)') 't,V,u,I,spike,reset'
 do j=0,n
 t=j*dt;I=0
 if(t>=on.and.t<off)I=amp
 if(mod(j,100)==0)write(unit,'(f12.5,a,f14.6,a,f14.6,a,f12.4,a,i1,a,i1)')t,',',v,',',u,',',I,',',0,',',0
 if(j==n)exit
 ex=exp(min(60d0,(v-vl)/delta))
 dv=(-G*(v-vr)+G*delta*ex-u+I)/C
 du=(a*(v-vr)-u)/tau
 vnext=v+dt*dv;unext=u+dt*du
 if(vnext>=peak)then
 write(unit,'(f12.5,a,f14.6,a,f14.6,a,f12.4,a,i1,a,i1)')t+dt,',',peak,',',unext,',',I,',',1,',',0
 vnext=reset;unext=unext+b
 write(unit,'(f12.5,a,f14.6,a,f14.6,a,f12.4,a,i1,a,i1)')t+dt,',',vnext,',',unext,',',I,',',0,',',1
 endif
 v=vnext;u=unext
 enddo
 close(unit)
 end subroutine
end module
program q2
 use q2_core
 implicit none
 character(40)::name
 character(256)::file,arg
 real(8)::tm,a,tau,b,r,I,tmax,on,off
 integer::ios
 call get_command_argument(1,name)
 if(len_trim(name)==0)stop 'Usage: q2 name tau_m a tau_w b reset I tmax on off output'
 call get_command_argument(2,arg);read(arg,*,iostat=ios)tm
 if(ios/=0)stop 'bad tau_m'
 call get_command_argument(3,arg);read(arg,*)a
 call get_command_argument(4,arg);read(arg,*)tau
 call get_command_argument(5,arg);read(arg,*)b
 call get_command_argument(6,arg);read(arg,*)r
 call get_command_argument(7,arg);read(arg,*)I
 call get_command_argument(8,arg);read(arg,*)tmax
 call get_command_argument(9,arg);read(arg,*)on
 call get_command_argument(10,arg);read(arg,*)off
 call get_command_argument(11,file)
 call simulate(trim(name),tm,a,tau,b,r,I,tmax,on,off,trim(file))
end program
