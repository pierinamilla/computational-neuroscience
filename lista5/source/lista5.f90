module models
 implicit none
contains
 subroutine fhn(v,w,I,dv,dw)
 real(8),intent(in)::v,w,I
 real(8),intent(out)::dv,dw
 dv=v-v**3/3d0-w+I; dw=.08d0*(v+.7d0-.8d0*w)
 end subroutine
 subroutine ml(V,n,J,modif,dV,dn)
 real(8),intent(in)::V,n,J
 logical,intent(in)::modif
 real(8),intent(out)::dV,dn
 real(8)::mi,ni,tau,gca
 gca=1.1d0; if(modif) gca=1d0
 mi=.5d0*(1d0+tanh((V+1d0)/15d0))
 if(modif) then
  ni=.5d0*(1d0+tanh((V-10d0)/14.5d0)); tau=3d0/cosh(max(-50d0,min(50d0,(V-10d0)/29d0)))
 else
  ni=.5d0*(1d0+tanh(V/30d0)); tau=5d0/cosh(max(-50d0,min(50d0,V/60d0)))
 endif
 dV=-gca*mi*(V-100d0)-2d0*n*(V+70d0)-.5d0*(V+50d0)+J
 dn=(ni-n)/tau
 end subroutine
 subroutine simf(v0,w0,I,tmax,dt,file)
 real(8)::v0,w0,I,tmax,dt,v,w,dv,dw,t
 character(*)::file
 integer::u,k,N
 N=nint(tmax/dt); v=v0; w=w0; open(newunit=u,file=file,status='replace')
 do k=0,N
  t=k*dt; write(u,'(3(es18.9,1x))') t,v,w
  call fhn(v,w,I,dv,dw); v=v+dt*dv; w=w+dt*dw
 enddo
 close(u)
 end subroutine
 subroutine simml(V0,n0,J,modif,tmax,dt,file)
 real(8)::V0,n0,J,tmax,dt,V,n,dV,dn,t
 logical::modif
 character(*)::file
 integer::u,k,Nsteps
 Nsteps=nint(tmax/dt); V=V0; n=n0; open(newunit=u,file=file,status='replace')
 do k=0,Nsteps
  t=k*dt; write(u,'(3(es18.9,1x))') t,V,n
  call ml(V,n,J,modif,dV,dn); V=V+dt*dV; n=n+dt*dn
  if(abs(V)>1d5) exit
 enddo
 close(u)
 end subroutine
 subroutine fhn_eq(I,v,w)
 real(8)::I,v,w,x,f,df
 integer::k
 x=-.7d0
 do k=1,100
  f=x-x**3/3d0-(x+.7d0)/.8d0+I; df=1d0-x*x-1.25d0
  if(abs(df)<1d-10) exit
  x=x-f/df
 enddo
 v=x; w=(v+.7d0)/.8d0
 end subroutine
 subroutine mleq(J,modif,V,n)
 real(8)::J,V,n,x,ni,mi,f,df,eps
 logical::modif
 integer::k
 x=-60d0
 do k=1,200
  call mlres(x,J,modif,f); eps=1d-4; call mlres(x+eps,J,modif,df); df=(df-f)/eps
  if(abs(df)<1d-10) exit
  x=x-f/df
 enddo
 V=x
 if(modif) then; n=.5d0*(1d0+tanh((V-10d0)/14.5d0)); else; n=.5d0*(1d0+tanh(V/30d0)); endif
 end subroutine
 subroutine mlres(V,J,modif,f)
 real(8)::V,J,f,dV,dn,n
 logical::modif
 if(modif) then; n=.5d0*(1d0+tanh((V-10d0)/14.5d0)); else; n=.5d0*(1d0+tanh(V/30d0)); endif
 call ml(V,n,J,modif,dV,dn); f=dV
 end subroutine
end module
program lista5
 use models
 implicit none
 real(8)::dt,vf,wf,vm,n,J,I,x
 integer::u,k,jj,ii
 character(120)::fn
 call execute_command_line('mkdir -p data')
 dt=.001d0
 ! FHN nullclines, time traces, equilibria
 do ii=0,2
  I=0d0; if(ii==1) I=1d0; if(ii==2) I=1.5d0
  write(fn,'("data/fhn_null_",i1,".dat")') ii; open(newunit=u,file=trim(fn),status='replace')
  do k=-1500,1000
   x=k/1000d0; write(u,'(3(es18.9,1x))') x,x-x**3/3d0+I,(x+.7d0)/.8d0
  enddo
  close(u)
 enddo
 call fhn_eq(0d0,vf,wf)
 call simf(-.8d0,wf,0d0,40d0,dt,'data/fhn_v_m080.dat')
 call simf(-.65d0,wf,0d0,40d0,dt,'data/fhn_v_m065.dat')
 call simf(-.64d0,wf,0d0,40d0,dt,'data/fhn_v_m064.dat')
 call simf(0d0,wf,0d0,40d0,dt,'data/fhn_v_0.dat')
 call simf(vf,wf,1d0,40d0,dt,'data/fhn_I1.dat'); call simf(vf,wf,1.5d0,40d0,dt,'data/fhn_I15.dat')
 open(newunit=u,file='data/fhn_equilibria.txt',status='replace')
 do ii=0,2
  I=0d0; if(ii==1) I=1d0; if(ii==2) I=1.5d0; call fhn_eq(I,vf,wf)
  write(u,'(a,f4.1,a,2f12.6,a,4f12.6)') 'I=',I,' v*,w*=',vf,wf,' Jacobian=',1d0-vf*vf,-1d0,.08d0,-.064d0
 enddo
 close(u)
 ! Base Morris-Lecar, J=15
 call mleq(15d0,.false.,vm,n)
 open(newunit=u,file='data/ml_equilibria.txt',status='replace'); write(u,'(a,2f14.7)') 'Morris-Lecar base J=15: V*, n* = ',vm,n; close(u)
 call simml(-18d0,n,15d0,.false.,20d0,dt,'data/ml_b_m18.dat'); call simml(-14.8d0,n,15d0,.false.,20d0,dt,'data/ml_b_m148.dat'); call simml(-14.7d0,n,15d0,.false.,20d0,dt,'data/ml_b_m147.dat'); call simml(-12d0,n,15d0,.false.,20d0,dt,'data/ml_b_m12.dat')
 call ml_null(15d0,.false.,'data/ml_b_null15.dat'); call ml_null(24.8d0,.false.,'data/ml_b_null24p8.dat'); call ml_null(25d0,.false.,'data/ml_b_null25.dat')
 call simml(-60d0,.1d0,24.8d0,.false.,100d0,dt,'data/ml_b_trace24p8.dat')
 call simml(-60d0,.1d0,25d0,.false.,100d0,dt,'data/ml_b_trace25.dat')
 call fi(.false.,20d0,40d0,.5d0,50d0,'data/ml_b_fi.dat')
 ! Modified ML, J=0
 call mleq(0d0,.true.,vm,n)
 open(newunit=u,file='data/ml_mod_equilibria.txt',status='replace'); write(u,'(a,2f14.7)') 'Morris-Lecar modificado J=0: V*, n* = ',vm,n; close(u)
 call ml_null(0d0,.true.,'data/ml_m_null0.dat')
 call simml(-40d0,n,0d0,.true.,200d0,dt,'data/ml_m_m40.dat'); call simml(-15d0,n,0d0,.true.,200d0,dt,'data/ml_m_m15.dat'); call simml(-12d0,n,0d0,.true.,200d0,dt,'data/ml_m_m12.dat'); call simml(-2d0,n,0d0,.true.,200d0,dt,'data/ml_m_m2.dat')
 call fi(.true.,0d0,20d0,.1d0,300d0,'data/ml_m_fi.dat')
 call ml_null(7.9d0,.true.,'data/ml_m_null7p9.dat'); call ml_null(8.33d0,.true.,'data/ml_m_null8p33.dat'); call ml_null(8.35d0,.true.,'data/ml_m_null8p35.dat')
 call simml(-40d0,n,7.9d0,.true.,200d0,dt,'data/ml_m_trace7p9.dat'); call simml(-40d0,n,8.33d0,.true.,200d0,dt,'data/ml_m_trace8p33.dat'); call simml(-40d0,n,8.35d0,.true.,200d0,dt,'data/ml_m_trace8p35.dat')
contains
 subroutine ml_null(J,modif,file)
 real(8)::J,V,ni,mi,nv,gca
 logical::modif
 character(*)::file
 integer::uu,kk
 gca=1.1d0; if(modif) gca=1d0
 open(newunit=uu,file=file,status='replace')
 do kk=-900,500
  V=kk/10d0; mi=.5d0*(1d0+tanh((V+1d0)/15d0)); nv=(-gca*mi*(V-100d0)-.5d0*(V+50d0)+J)/(2d0*(V+70d0))
  if(modif) then; ni=.5d0*(1d0+tanh((V-10d0)/14.5d0)); else; ni=.5d0*(1d0+tanh(V/30d0)); endif
  write(uu,'(3(es18.9,1x))') V,nv,ni
 enddo
 close(uu)
 end subroutine
 subroutine fi(modif,jmin,jmax,dj,tmax,file)
 logical::modif
 real(8)::jmin,jmax,dj,tmax,Jval,Vv,nn,dV,dn,rate,prev,dtloc
 character(*)::file
 integer::uu,jj,kk,ns
 dtloc=.001d0; ns=nint(tmax/dtloc); open(newunit=uu,file=file,status='replace')
 jj=0
 do
  Jval=jmin+jj*dj; if(Jval>jmax+1d-8) exit
  Vv=-60d0; nn=.1d0; prev=Vv; rate=0d0
  do kk=1,ns
   call ml(Vv,nn,Jval,modif,dV,dn); Vv=Vv+dtloc*dV; nn=nn+dtloc*dn
   if(kk>ns/2 .and. prev<0d0 .and. Vv>=0d0) rate=rate+1d0
   prev=Vv; if(abs(Vv)>1d5) exit
  enddo
  rate=rate/(tmax/2d0)*1000d0; write(uu,'(2(es18.9,1x))') Jval,rate; jj=jj+1
 enddo
 close(uu)
 end subroutine
end program
