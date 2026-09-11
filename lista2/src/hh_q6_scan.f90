program hh_q6_scan
 implicit none
 integer,parameter::dp=kind(1d0),NJ=14
 real(dp),parameter::J2s(NJ)=(/100d0,120d0,150d0,175d0,200d0,250d0,300d0,400d0,500d0,700d0,1000d0,1500d0,2000d0,3000d0/)
 real(dp)::J1,Lcrit,Llo,Lhi,Lmid
 integer::k
 integer::j
 real(dp)::L,firstL,recoveryL
 J1=100d0
 do k=1,NJ
   firstL=-1d0; recoveryL=-1d0
   ! Busca exhaustiva: la condicion no es monotona en L.
   do j=0,1450
      L=0.50d0+0.01d0*j
      if(is_second_spike(J1,J2s(k),L)) then
         firstL=L; exit
      endif
   enddo
   if(firstL>0d0) then
      Llo=max(0.50d0,firstL-0.01d0); Lhi=firstL
      do while(Lhi-Llo>0.0001d0)
         Lmid=0.5d0*(Llo+Lhi)
         if(is_second_spike(J1,J2s(k),Lmid)) then; Lhi=Lmid; else; Llo=Lmid; endif
      enddo
      firstL=Lhi
   endif
   write(*,'(F8.1,1X,F10.4)')J2s(k),firstL
 enddo
contains
 subroutine coarse(j1,j2,lo,hi)
  real(dp),intent(in)::j1,j2;real(dp),intent(out)::lo,hi
  real(dp)::L;hi=-1d0;lo=0d0;L=0.05d0
  do while(L<=15d0)
   if(is_second_spike(j1,j2,L))then;hi=L;return;endif
   lo=L;L=L+0.05d0
  enddo
 end subroutine
 logical function is_second_spike(j1,j2,L)
  real(dp),intent(in)::j1,j2,L
  real(dp)::dt,t,t2,V,n,m,h,Vn,nn,mn,hn,an,bn,am,bm,ah,bh,J
  real(dp),parameter::gNa=120d0,gK=36d0,gV=.3d0,ENa=50d0,EK=-77d0,EV=-54.4d0,tol=1d-10
  integer::i,itmax,nc;real(dp)::tc1,tc2
  dt=.001d0;itmax=30000;t2=10d0+L;V=-65d0;n=.32d0;m=.05d0;h=.6d0;nc=0;tc1=-1d0;tc2=-1d0
  do i=0,itmax
   t=i*dt;J=0d0;if(t>=10d0 .and. t<10.5d0)J=J+j1;if(t>=t2 .and. t<t2+.5d0)J=J+j2
   if(abs(V+55d0)<tol)then;an=.1d0;else;an=.01d0*(V+55d0)/(1d0-exp(-(V+55d0)/10d0));endif
   bn=.125d0*exp(-(V+65d0)/80d0);if(abs(V+40d0)<tol)then;am=1d0;else;am=.1d0*(V+40d0)/(1d0-exp(-(V+40d0)/10d0));endif
   bm=4d0*exp(-(V+65d0)/18d0);ah=.07d0*exp(-(V+65d0)/20d0);bh=1d0/(exp(-(V+35d0)/10d0)+1d0)
   Vn=V+dt*(-gNa*m**3*h*(V-ENa)-gK*n**4*(V-EK)-gV*(V-EV)+J);nn=n+dt*(an*(1d0-n)-bn*n);mn=m+dt*(am*(1d0-m)-bm*m);hn=h+dt*(ah*(1d0-h)-bh*h)
   if(V<0d0 .and. Vn>=0d0)then;nc=nc+1;if(nc==1)tc1=t+dt;if(nc==2)tc2=t+dt;endif
   V=Vn;n=nn;m=mn;h=hn
  enddo
  is_second_spike=(tc1>=10d0 .and. tc1<t2 .and. tc2>=t2)
 end function
end program

