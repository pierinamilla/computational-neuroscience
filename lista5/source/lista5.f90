
module models
  implicit none
contains

  subroutine fhn(v,w,I,dv,dw)
    implicit none
    real(8), intent(in) :: v,w,I
    real(8), intent(out) :: dv,dw

    dv = v - v**3/3d0 - w + I
    dw = .08d0*(v + .7d0 - .8d0*w)
  end subroutine fhn


  subroutine ml(V,n,J,modif,dV,dn)
    implicit none
    real(8), intent(in) :: V,n,J
    logical, intent(in) :: modif
    real(8), intent(out) :: dV,dn
    real(8) :: mi,ni,tau,gca,z

    gca = 1.1d0
    if (modif) gca = 1d0

    mi = .5d0*(1d0 + tanh((V+1d0)/15d0))

    if (modif) then
      z = max(-50d0,min(50d0,(V-10d0)/29d0))
      ni = .5d0*(1d0 + tanh((V-10d0)/14.5d0))
      tau = 3d0/cosh(z)
    else
      z = max(-50d0,min(50d0,V/60d0))
      ni = .5d0*(1d0 + tanh(V/30d0))
      tau = 5d0/cosh(z)
    endif

    dV = -gca*mi*(V-100d0) - 2d0*n*(V+70d0) &
         - .5d0*(V+50d0) + J
    dn = (ni-n)/tau
  end subroutine ml


  subroutine ml_ninf(V,modif,n)
    implicit none
    real(8), intent(in) :: V
    logical, intent(in) :: modif
    real(8), intent(out) :: n

    if (modif) then
      n = .5d0*(1d0+tanh((V-10d0)/14.5d0))
    else
      n = .5d0*(1d0+tanh(V/30d0))
    endif
  end subroutine ml_ninf


  subroutine mlres(V,J,modif,f)
    implicit none
    real(8), intent(in) :: V,J
    logical, intent(in) :: modif
    real(8), intent(out) :: f
    real(8) :: dV,dn,n

    call ml_ninf(V,modif,n)
    call ml(V,n,J,modif,dV,dn)
    f = dV
  end subroutine mlres


  subroutine simf(v0,w0,I,tmax,dt,file)
    implicit none
    real(8), intent(in) :: v0,w0,I,tmax,dt
    character(*), intent(in) :: file
    real(8) :: v,w,dv,dw,t
    integer :: u,k,N

    N = nint(tmax/dt)
    v = v0
    w = w0

    open(newunit=u,file=file,status='replace',action='write')
    do k=0,N
      t = k*dt
      write(u,'(3(es18.9,1x))') t,v,w
      call fhn(v,w,I,dv,dw)
      v = v + dt*dv
      w = w + dt*dw
    enddo
    close(u)
  end subroutine simf


  subroutine simml(V0,n0,J,modif,tmax,dt,file)
    implicit none
    real(8), intent(in) :: V0,n0,J,tmax,dt
    logical, intent(in) :: modif
    character(*), intent(in) :: file
    real(8) :: V,n,dV,dn,t
    integer :: u,k,Nsteps

    Nsteps = nint(tmax/dt)
    V = V0
    n = n0

    open(newunit=u,file=file,status='replace',action='write')
    do k=0,Nsteps
      t = k*dt
      write(u,'(3(es18.9,1x))') t,V,n

      call ml(V,n,J,modif,dV,dn)
      V = V + dt*dV
      n = n + dt*dn

      if (abs(V)>1d5) exit
    enddo
    close(u)
  end subroutine simml


  subroutine fhn_eq(I,v,w)
    implicit none
    real(8), intent(in) :: I
    real(8), intent(out) :: v,w
    real(8) :: x,f,df
    integer :: k

    x = -.7d0
    do k=1,200
      f = x - x**3/3d0 - (x+.7d0)/.8d0 + I
      df = 1d0 - x*x - 1.25d0

      if (abs(f)<1d-12) exit
      if (abs(df)<1d-12) exit

      x = x - f/df
    enddo

    v = x
    w = (v+.7d0)/.8d0
  end subroutine fhn_eq


  ! Newton from one initial guess: this does NOT guarantee all roots.
  subroutine mleq(J,modif,V,n)
    implicit none
    real(8), intent(in) :: J
    logical, intent(in) :: modif
    real(8), intent(out) :: V,n
    real(8) :: x,f,fp,df,eps,step
    integer :: k

    x = -60d0
    eps = 1d-5

    do k=1,200
      call mlres(x,J,modif,f)
      if (abs(f)<1d-11) exit

      call mlres(x+eps,J,modif,fp)
      df = (fp-f)/eps
      if (abs(df)<1d-12) exit

      step = f/df
      step = max(-20d0,min(20d0,step))
      x = x-step
    enddo

    V = x
    call ml_ninf(V,modif,n)

    call mlres(V,J,modif,f)
    if (abs(f)>1d-7) then
      write(*,'(a,es12.4)') &
        'Warning: mleq may not have converged; residual = ',f
    endif
  end subroutine mleq


  ! Scan voltage and use bisection for every detected sign change.
  ! Tangential roots without a sign change may not be detected.
  subroutine mleq_all(J,modif,Vroots,nroots)
    implicit none
    real(8), intent(in) :: J
    logical, intent(in) :: modif
    real(8), intent(out) :: Vroots(:)
    integer, intent(out) :: nroots

    integer, parameter :: nscan=20000
    real(8), parameter :: vmin=-150d0,vmax=50d0
    real(8), parameter :: xtol=1d-10,ftol=1d-11
    real(8) :: dx,x1,x2,f1,f2,lo,hi,fa,fm,xm
    integer :: i,it

    Vroots = 0d0
    nroots = 0
    dx = (vmax-vmin)/dble(nscan)

    x1 = vmin
    call mlres(x1,J,modif,f1)

    do i=1,nscan
      x2 = vmin + dble(i)*dx
      call mlres(x2,J,modif,f2)

      if (abs(f1)<ftol) call add_root(x1)

      if (f1*f2<0d0) then
        lo = x1
        hi = x2
        fa = f1

        do it=1,100
          xm = .5d0*(lo+hi)
          call mlres(xm,J,modif,fm)

          if (abs(fm)<ftol .or. abs(hi-lo)<xtol) exit

          if (fa*fm<=0d0) then
            hi = xm
          else
            lo = xm
            fa = fm
          endif
        enddo

        xm = .5d0*(lo+hi)
        call add_root(xm)
      endif

      ! Advance the scan endpoints only after checking the interval.
      x1 = x2
      f1 = f2
    enddo

    if (abs(f1)<ftol) call add_root(x1)

  contains

    subroutine add_root(x)
      implicit none
      real(8), intent(in) :: x
      integer :: q

      if (nroots>=size(Vroots)) return

      do q=1,nroots
        if (abs(Vroots(q)-x)<1d-5) return
      enddo

      nroots = nroots+1
      Vroots(nroots) = x
    end subroutine add_root

  end subroutine mleq_all


 subroutine ml_jacobian(V,n,J,modif,A)
  implicit none
  real(8), intent(in) :: V,n,J
  logical, intent(in) :: modif
  real(8), intent(out) :: A(2,2)
  real(8) :: h,fp,fm,gp,gm,dV,dn
  real(8) :: dV2,dn2

  h = 1d-5

  ! Derivadas respecto de V
  call ml(V+h,n,J,modif,fp,gp)
  call ml(V-h,n,J,modif,fm,gm)
  A(1,1) = (fp-fm)/(2d0*h)
  A(2,1) = (gp-gm)/(2d0*h)

  ! Derivadas respecto de n
  call ml(V,n+h,J,modif,fp,gp)
  call ml(V,n-h,J,modif,fm,gm)
  A(1,2) = (fp-fm)/(2d0*h)
  A(2,2) = (gp-gm)/(2d0*h)
 end subroutine ml_jacobian


 subroutine ml_stability(V,n,J,modif,lambda1,lambda2, &
                         tr,detA)
  implicit none
  real(8), intent(in) :: V,n,J
  logical, intent(in) :: modif
  real(8), intent(out) :: lambda1,lambda2,tr,detA
  real(8) :: A(2,2),disc,scale

  call ml_jacobian(V,n,J,modif,A)

  tr = A(1,1) + A(2,2)
  detA = A(1,1)*A(2,2) - A(1,2)*A(2,1)
  disc = tr*tr - 4d0*detA

  if (disc >= 0d0) then
    lambda1 = 0.5d0*(tr + sqrt(disc))
    lambda2 = 0.5d0*(tr - sqrt(disc))
  else
    ! Para autovalores complejos, se devuelven:
    ! lambda1 = parte real
    ! lambda2 = magnitud de la parte imaginaria
    lambda1 = 0.5d0*tr
    lambda2 = 0.5d0*sqrt(-disc)
  endif
 end subroutine ml_stability


 subroutine write_ml_stability(J,modif,file)
  implicit none
  real(8), intent(in) :: J
  logical, intent(in) :: modif
  character(*), intent(in) :: file

  integer :: nr,k,u
  real(8) :: roots(100),Vstar,nstar
  real(8) :: l1,l2,tr,detA,dV,dn
  real(8) :: residual

  call mleq_all(J,modif,roots,nr)

  open(newunit=u,file=file,status='replace')
  write(u,'(a,es14.5)') '# J = ',J
  write(u,'(a)') &
   '# Vstar nstar trace determinant lambda1 lambda2 residual'

  do k=1,nr
    Vstar=roots(k)

    if (modif) then
      nstar=0.5d0*(1d0+tanh((Vstar-10d0)/14.5d0))
    else
      nstar=0.5d0*(1d0+tanh(Vstar/30d0))
    endif

    call ml_stability(Vstar,nstar,J,modif,l1,l2,tr,detA)
    call ml(Vstar,nstar,J,modif,dV,dn)
    residual=sqrt(dV*dV+dn*dn)

    write(u,'(7(es16.8,1x))') &
      Vstar,nstar,tr,detA,l1,l2,residual
  enddo

  close(u)
 end subroutine write_ml_stability



end module models


program lista5
  use models
  implicit none

  real(8) :: dt,vf,wf,vm,n,J,I,x
  integer :: u,k,ii
  character(120) :: fn

  call execute_command_line('mkdir -p data')
  dt = .001d0

  ! FHN nullclines
  do ii=0,2
    I = 0d0
    if (ii==1) I=1d0
    if (ii==2) I=1.5d0

    write(fn,'("data/fhn_null_",i1,".dat")') ii
    open(newunit=u,file=trim(fn),status='replace',action='write')

    do k=-1500,1000
      x = k/1000d0
      write(u,'(3(es18.9,1x))') &
        x,x-x**3/3d0+I,(x+.7d0)/.8d0
    enddo

    close(u)
  enddo

  ! FHN trajectories
  call fhn_eq(0d0,vf,wf)
  call simf(-.8d0,wf,0d0,40d0,dt,'data/fhn_v_m080.dat')
  call simf(-.65d0,wf,0d0,40d0,dt,'data/fhn_v_m065.dat')
  call simf(-.64d0,wf,0d0,40d0,dt,'data/fhn_v_m064.dat')
  call simf(0d0,wf,0d0,40d0,dt,'data/fhn_v_0.dat')
  call simf(vf,wf,1d0,40d0,dt,'data/fhn_I1.dat')
  call simf(vf,wf,1.5d0,40d0,dt,'data/fhn_I15.dat')

  open(newunit=u,file='data/fhn_equilibria.txt', &
       status='replace',action='write')

  do ii=0,2
    I = 0d0
    if (ii==1) I=1d0
    if (ii==2) I=1.5d0

    call fhn_eq(I,vf,wf)
    write(u,'(a,f4.1,a,2f12.6,a,4f12.6)') &
      'I=',I,' v*,w*=',vf,wf,' Jacobian=', &
      1d0-vf*vf,-1d0,.08d0,-.064d0
  enddo
  close(u)

  ! Base Morris-Lecar: write all detected equilibria at J=15.
  call write_ml_equilibria(15d0,.false.,'data/ml_equilibria.txt')

  call mleq(15d0,.false.,vm,n)
  call simml(-18d0,n,15d0,.false.,20d0,dt,'data/ml_b_m18.dat')
  call simml(-14.8d0,n,15d0,.false.,20d0,dt,'data/ml_b_m148.dat')
  call simml(-14.7d0,n,15d0,.false.,20d0,dt,'data/ml_b_m147.dat')
  call simml(-12d0,n,15d0,.false.,20d0,dt,'data/ml_b_m12.dat')

  call ml_null(15d0,.false.,'data/ml_b_null15.dat')
  call ml_null(24.8d0,.false.,'data/ml_b_null24p8.dat')
  call ml_null(25d0,.false.,'data/ml_b_null25.dat')

  call simml(-60d0,.1d0,24.8d0,.false.,100d0,dt, &
             'data/ml_b_trace24p8.dat')
  call simml(-60d0,.1d0,25d0,.false.,100d0,dt, &
             'data/ml_b_trace25.dat')

  call fi(.false.,20d0,40d0,.5d0,200d0,'data/ml_b_fi.dat')

  ! Modified Morris-Lecar: write all detected equilibria at J=0.
  call write_ml_equilibria(0d0,.true.,'data/ml_mod_equilibria.txt')

  call mleq(0d0,.true.,vm,n)
  call ml_null(0d0,.true.,'data/ml_m_null0.dat')

  call simml(-40d0,n,0d0,.true.,200d0,dt,'data/ml_m_m40.dat')
  call simml(-15d0,n,0d0,.true.,200d0,dt,'data/ml_m_m15.dat')
  call simml(-12d0,n,0d0,.true.,200d0,dt,'data/ml_m_m12.dat')
  call simml(-2d0,n,0d0,.true.,200d0,dt,'data/ml_m_m2.dat')

  call fi(.true.,0d0,20d0,.1d0,300d0,'data/ml_m_fi.dat')

  call ml_null(7.9d0,.true.,'data/ml_m_null7p9.dat')
  call ml_null(8.33d0,.true.,'data/ml_m_null8p33.dat')
  call ml_null(8.35d0,.true.,'data/ml_m_null8p35.dat')

  call simml(-40d0,n,7.9d0,.true.,200d0,dt,'data/ml_m_trace7p9.dat')
  call simml(-40d0,n,8.33d0,.true.,200d0,dt,'data/ml_m_trace8p33.dat')
  call simml(-40d0,n,8.35d0,.true.,200d0,dt,'data/ml_m_trace8p35.dat')

contains

  subroutine write_ml_equilibria(Jval,modif,file)
    implicit none
    real(8), intent(in) :: Jval
    logical, intent(in) :: modif
    character(*), intent(in) :: file
    real(8) :: roots(20),vstar,nstar
    integer :: uu,nfound,q

    call mleq_all(Jval,modif,roots,nfound)

    open(newunit=uu,file=file,status='replace',action='write')
    write(uu,'(a,es12.4)') '# Applied current J = ',Jval
    write(uu,'(a,i0)') '# Detected equilibria = ',nfound
    write(uu,'(a)') '# Vstar(mV)  nstar'

    do q=1,nfound
      vstar = roots(q)
      call ml_ninf(vstar,modif,nstar)
      write(uu,'(2(es18.9,1x))') vstar,nstar
    enddo

    close(uu)
    write(*,'(a,a,a,i0)') 'Wrote ',trim(file), &
      '; detected equilibria: ',nfound
  end subroutine write_ml_equilibria


  subroutine ml_null(Jval,modif,file)
    implicit none
    real(8), intent(in) :: Jval
    logical, intent(in) :: modif
    character(*), intent(in) :: file
    real(8) :: V,ni,mi,nv,gca,den,num
    integer :: uu,kk

    gca = 1.1d0
    if (modif) gca = 1d0

    open(newunit=uu,file=file,status='replace',action='write')

    do kk=-900,500
      V = kk/10d0
      mi = .5d0*(1d0+tanh((V+1d0)/15d0))
      num = -gca*mi*(V-100d0) - .5d0*(V+50d0) + Jval
      den = 2d0*(V+70d0)

      if (modif) then
        ni = .5d0*(1d0+tanh((V-10d0)/14.5d0))
      else
        ni = .5d0*(1d0+tanh(V/30d0))
      endif

      ! The rearranged formula is singular at V=-70 mV.
      ! Keep three columns; NaN marks the undefined plotted value.
      if (abs(den)<1d-12) then
        write(uu,'(es18.9,1x,a,1x,es18.9)') V,'NaN',ni
      else
        nv = num/den
        write(uu,'(3(es18.9,1x))') V,nv,ni
      endif
    enddo

    close(uu)
  end subroutine ml_null


  subroutine fi(modif,jmin,jmax,dj,tmax,file)
    implicit none
    logical, intent(in) :: modif
    real(8), intent(in) :: jmin,jmax,dj,tmax
    character(*), intent(in) :: file
    real(8) :: Jval,Vv,nn,dV,dn,dtloc
    real(8) :: prevV,tprev,tcur,tcross,tfirst,tlast,rate
    integer :: uu,jj,kk,ns,ncross
    logical :: havefirst

    dtloc = .001d0
    ns = nint(tmax/dtloc)

    open(newunit=uu,file=file,status='replace',action='write')
    write(uu,'(a)') '# J  frequency_Hz'

    jj = 0
    do
      Jval = jmin + jj*dj
      if (Jval>jmax+1d-8) exit

      Vv = -60d0
      nn = .1d0
      prevV = Vv
      tprev = 0d0
      ncross = 0
      havefirst = .false.
      tfirst = 0d0
      tlast = 0d0

      do kk=1,ns
        call ml(Vv,nn,Jval,modif,dV,dn)
        Vv = Vv + dtloc*dV
        nn = nn + dtloc*dn
        tcur = kk*dtloc

        if (tcur>tmax/2d0 .and. prevV<0d0 .and. Vv>=0d0) then
          tcross = tprev + dtloc*(-prevV)/(Vv-prevV)
          ncross = ncross+1

          if (.not.havefirst) then
            tfirst = tcross
            havefirst = .true.
          endif
          tlast = tcross
        endif

        prevV = Vv
        tprev = tcur
        if (abs(Vv)>1d5) exit
      enddo

      rate = 0d0
      if (ncross>=2 .and. tlast>tfirst) then
        rate = 1000d0*dble(ncross-1)/(tlast-tfirst)
      endif

      write(uu,'(2(es18.9,1x))') Jval,rate
      jj = jj+1
    enddo

    close(uu)
  end subroutine fi

call write_ml_stability(15d0,.false., &
                        'data/ml_stability.txt')

call write_ml_stability(0d0,.true., &
                        'data/ml_mod_stability.txt')
end program lista5
