!==========================================================================================!
!==========================================================================================!
!     This sub-routine extracts a 3-D array from a 4-D variable.                           !
!------------------------------------------------------------------------------------------!
subroutine s4d_to_3d(xmax,ymax,zmax,emax,xact,yact,zact,eact,e,four,three)
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   integer                                , intent(in)  :: xmax
   integer                                , intent(in)  :: ymax
   integer                                , intent(in)  :: zmax
   integer                                , intent(in)  :: emax
   integer                                , intent(in)  :: xact
   integer                                , intent(in)  :: yact
   integer                                , intent(in)  :: zact
   integer                                , intent(in)  :: eact
   integer                                , intent(in)  :: e
   real   , dimension(xmax,ymax,zmax,emax), intent(in)  :: four
   real   , dimension(xact,yact,zact)     , intent(out) :: three
   !----- Local variables. ----------------------------------------------------------------!
   integer                                              :: x
   integer                                              :: y
   integer                                              :: z
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !    Extract the three dimensional array.                                               !
   !---------------------------------------------------------------------------------------!
   do x=1,xact
      do y=1,yact
         do z=1,zact
            three(x,y,z) = four(x,y,z,e)
         end do
      end do
   end do
   return
end subroutine s4d_to_3d
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
      subroutine Ctransvar(n1,n2,n3,a,topo,nzlev,izlev,zt,ztop)
      use rpost_dims
      dimension a(n1,n2,n3),topo(n1,n2),zt(n3)
      real b(nzpmax,4)
      integer izlev(nzpmax)

      do k=1,nzlev
! niveis onde serao interpolados os valores
        b(k,4)=float(izlev(k))
      enddo

      do j=1,n2
         do i=1,n1
            do k=1,n3
               b(k,1)=a(i,j,k)
               b(k,2)=topo(i,j)+zt(k)*(1.-topo(i,j)/ztop)
!	       if(i.eq.50.and.j.eq.50)  print*,i,j,k,topo(i,j),zt(k), &
!        b(k,1),b(k,2)
            enddo
            call htint(n3,b(1,1),b(1,2),nzlev,b(1,3),b(1,4))
            do k=1,nzlev
	     if( b(k,4).lt.topo(i,j)) then
	       a(i,j,k)= -9.99e33
!	       print*,i,j,b(k,4),topo(i,j)
!	       stop
	     else
               a(i,j,k)=b(k,3)
	     endif
!              if(i.eq.50.and.j.eq.50)  print*,b(k,3)
            enddo
         enddo
      enddo
         
      return
      end


!==========================================================================================!
!==========================================================================================!
subroutine define_lim(ng,nxg,nyg,rlat1,dlat,rlon1,dlon,lati,latf,loni,lonf,nxa,nxb,nya,nyb &
                     ,proj,nx,ny,rlat,rlon)

   use rpost_dims
   use misc_coms, only : glong, glatg
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   integer               , intent(in)    :: nx
   integer               , intent(in)    :: ny
   integer               , intent(in)    :: nxg
   integer               , intent(in)    :: nyg
   integer               , intent(in)    :: ng
   real, dimension(nx,ny), intent(in)    :: rlat
   real, dimension(nx,ny), intent(in)    :: rlon
   real                  , intent(in)    :: lati
   real                  , intent(in)    :: latf
   real                  , intent(in)    :: loni
   real                  , intent(in)    :: lonf
   character(len=*)      , intent(in)    :: proj
   integer               , intent(out)   :: nxa
   integer               , intent(out)   :: nxb
   integer               , intent(out)   :: nya
   integer               , intent(out)   :: nyb
   real                  , intent(out)   :: rlat1
   real                  , intent(inout) :: dlat
   real                  , intent(out)   :: rlon1
   real                  , intent(inout) :: dlon
   !----- Local variables. ----------------------------------------------------------------!
   integer                             :: i
   integer                             :: j
   integer                             :: n
   integer                             :: nlon
   integer                             :: nlat
   real                                :: x
   real                                :: xx
   !---------------------------------------------------------------------------------------!
       

   !----- Find the number of grid points. -------------------------------------------------!
   xloop: do i=1,nxg
      if (loni <= glong(i)) exit xloop
   end do xloop
   nxa = max(i,1)

   yloop: do j=1,nyg
      if (lati <= glatg(j)) exit yloop
   end do yloop
   nya = max(j,1)


   nlon = abs( floor( (lonf-loni) / dlon ) ) + 1
   nlat = abs( floor( (latf-lati) / dlat ) ) + 1

   nxb   = min(nxa+nlon,nxg)
   nyb   = min(nya+nlat,nyg)
   rlon1 = glong(nxa)
   rlat1 = glatg(nya)

   if (proj /= 'YES' .and. proj /= 'yes') then
      x  = 0.
      xx = 0.
      do j=nya,nyb
         x  = x  + rlon(nxa,j)
         xx = xx + (rlon(nxb,j)-rlon(nxa,j)) / (nxb-nxa)
      end do
      rlon1 =  x / (nyb-nya+1)
      dlon  = xx / (nyb-nya+1)
   
      x  = 0.
      xx = 0.
      do n=nxa,nxb
         x  =  x + rlat(n,nya)
         xx = xx + (rlat(n,nyb)-rlat(n,nya)) / (nyb-nya)
      end do
      rlat1 =  x / (nxb-nxa+1)
      dlat  = xx / (nxb-nxa+1)
   end if
   
   write (unit=*,fmt='(a,1x,es12.5)') ' LONI  = ',loni
   write (unit=*,fmt='(a,1x,es12.5)') ' LONF  = ',lonf
   write (unit=*,fmt='(a,1x,i6)'    ) ' NLON  = ',nlon
   write (unit=*,fmt='(a,1x,es12.5)') ' RLON1 = ',rlon1
   write (unit=*,fmt='(a,1x,es12.5)') ' DLON  = ',dlon
   write (unit=*,fmt='(a,1x,es12.5)') ' LATI  = ',lati
   write (unit=*,fmt='(a,1x,es12.5)') ' LATF  = ',latf
   write (unit=*,fmt='(a,1x,i6)'    ) ' NLAT  = ',nlat
   write (unit=*,fmt='(a,1x,es12.5)') ' RLAT1 = ',rlat1
   write (unit=*,fmt='(a,1x,es12.5)') ' DLAT  = ',dlat

   return
end subroutine define_lim
!==========================================================================================!
!==========================================================================================!
!----------------------------------------------------------------
       subroutine define_grid2(nx,ny,loni,lonf,lati,latf,nxg,nyg,&
                        rlat,rlon,nxa,nxb,nya,nyb)
       Dimension rlat(nx,ny),rlon(nx,ny)
       nxa=10000
       do j=1,nyg
	 do i=1,nxg
!      print*,loni,rlon(i,j)
	      if( loni .le. rlon(i,j) ) go to 121
	 enddo
	 go to 122
121 continue
	 ia=max(i,1)
	 nxa=min(nxa,ia)
	 print*,j,i,ia,nxa,rlon(i,j)
122 continue
	enddo
!
	nxb=10000
	do j=1,nyg
	 do i=1,nxg
!      print*,loni,rlon(i,j)
	      if( lonf .le. rlon(i,j) ) go to 123
	 enddo
	 go to 124
123 continue
	 ib=max(i,1)
	 nxb=min(nxb,ib)
	 print*,j,i,ib,nxb,rlon(i,j)
124 continue
	 enddo
         nxa=max(nxa,1)
	 nxb=min(nxb,nxg)
!latitude
       nya=10000
       do i=1,nxg
        do j=1,nyg
	      if( lati .le. rlat(i,j) ) go to 141
	 enddo
	 go to 142
141 continue
	 ja=max(j,1)
	 nya=min(nya,ja)
	 print*,j,i,ja,nya,rlat(i,j)
142 continue
	enddo
!
	nyb=10000
	do i=1,nxg
	 do j=1,nyg
	      if( latf .le. rlat(i,j) ) go to 143
	 enddo
	 go to 144
143 continue
	 jb=max(j,1)
	 nyb=min(nyb,jb)
	 print*,j,i,jb,nyb,rlat(i,j)
144 continue
	enddo
        nya=max(nya,1)
	nyb=min(nyb,nyg)

	print*,nxa,nxb,nya,nyb

return
end

! ---------------------------------------------------------------
! -   SUBROUTINE PTRANSVAR : LOAD RAMS VARIABLE FROM ANALYSIS   -
! ---------------------------------------------------------------

      subroutine ptransvar(a,nx,ny,nz,nplev,iplev,pi,zlev,zplev,topo)
      use rpost_dims
      real b(nzpmax,4)
      real a(nx,ny,nz),topo(nx,ny),pi(nx,ny,nz), &
           zlev(*),zplev(nx,ny,20)
      integer nx,ny,nz,nplev,iplev(20)

!      print*,nx,ny,nz,nplev,iplev


      do i=1,nplev
        b(nplev-i+1,4)=1004.*(iplev(i)/1000.)**.286
      enddo

      do j=1,ny
        do i=1,nx
          do k=1,nz
            kk=nz-k+1
            b(kk,1)=a(i,j,k)
            b(kk,2)=pi(i,j,k)
          enddo
          call htint(nz,b(1,1),b(1,2),nplev,b(1,3),b(1,4))
          do k=1,nplev
!            print*,i,j,k,a(i,j,k),b(k,3),pi(i,j,k),b(k,4)
            a(i,j,nplev-k+1)=b(k,3)

          enddo
          
          do k=1,nz
            kk=nz-k+1
            b(kk,1)=zlev(k)+topo(i,j)
            b(kk,2)=pi(i,j,k)
          enddo
          call htint(nz,b(1,1),b(1,2),nplev,b(1,3),b(1,4))
          do k=1,nplev
            zplev(i,j,nplev-k+1)=b(k,3)
          enddo
        enddo
      enddo
      
      return
      end
!***************************************************************************

!***************************************************************************
!***************************************************************************

!--------------------------------------------------
      subroutine select_sigmaz(n1,n2,n3,a,nzlev,izlev)
      use rpost_dims
      dimension a(n1,n2,n3)
      real b(nzpmax,4)
      integer izlev(nzpmax)

      do k=1,nzlev
       do j=1,n2
         do i=1,n1
	    a(i,j,k)=a(i,j,izlev(k))
         enddo
       enddo
      enddo
 
      return
      end
!-------------------------------------------------------------------
subroutine date1(ib,iy,im,id)
iy=int(ib/10000)
im=int( (ib-iy*10000)/100 )
id=ib - (iy*10000 + im*100)
return
end

!-------------------------------------------------------------------
      subroutine cape_cine(nx,ny,nz,press,TEMPK,UR,dummy,name,indef)
!      subroutine cape_cine(nz,nt,nomeIN,nomeOUT,&
!                     nSzP,nSzpP,nSzT,nSzpT,nSzUR,nSzpUR,lit,indef)
      real PRESS(nx,ny,nz), TEMPK(nx,ny,nz),UR(nx,ny,nz),indef
      real dummy(nx,ny,nz)
      real cine(nx,ny),cape(nx,ny)
      real press2(nz),temp2(nz),ur2(nz)
      character nomeIN*100,nomeOUT*100
      character(len=*) :: name
      integer t,z,x,y
      erro0=5.e-5

!      OPEN(34,FILE=nomeIN,STATUS='UNKNOWN'&
!            ,FORM='UNFORMATTED',ACCESS='DIRECT',RECL=nx*ny*4)
!      OPEN(35,FILE=nomeOUT,STATUS='UNKNOWN'&
!            ,FORM='UNFORMATTED',ACCESS='DIRECT',RECL=nx*ny*4)
      
!      irec=1
!      irecP=-nSzpP
!      irecT=-nSzpT
!      irecUR=-nSzpUR
!      do t=1,nt
!        print*,t,' de ',nt
!        irecP=irecP + nSzP + nSzpP
!        irecT=irecT + nSzT + nSzpT
!        irecUR=irecUR + nSzUR + nSzpUR
!        do z=1,nz
!          irecP=irecP+1
!          irecT=irecT+1
!          irecUR=irecUR+1
!          read(34,rec=irecP) ((PRESS(i,j,z),i=1,nx),j=1,ny)
!          read(34,rec=irecT) ((TEMPK(i,j,z),i=1,nx),j=1,ny)
!          read(34,rec=irecUR) ((UR(i,j,z),i=1,nx),j=1,ny)
!          
!        enddo
 
        !print*,'------------------------------------------'
        do i=1,nx
          do j=1,ny
            do z=1,nz-1
              press2(z)=PRESS(i,j,z+1)
              temp2 (z)=TEMPK(i,j,z+1)-273.16
              ur2   (z)=   UR(i,j,z+1)
            enddo
	    if(name == 'cape') then
              cape(i,j)=calccape(nz-1,1,press2,temp2,ur2,erro0,indef)
	      dummy(i,j,1)=cape(i,j)
	    endif
	    if(name == 'cine') then	   
               cine(i,j)=calccine(nz-1,1,press2,temp2,ur2,erro0,indef)
	       dummy(i,j,1)=cine(i,j)
	    endif
	    !print*,'i,j,cape=',i,j,cape(i,j)
	    !print*,PRESS(i,j,2),tempk(i,j,2),ur(i,j,2)
          enddo
        enddo
!        write(35,rec=irec) cape
!        irec=irec+1
!        write(35,rec=irec) cine
!        irec=irec+1
!      enddo

!      close (35)
!      close (34)

      return
      end
      
      
!************************************************************************
!*  Esta fun��o calcula a CINE de uma determinada sondagem              *
!************************************************************************
      real function calccine(num,i0,pres,temp,urel,erro0,indef)
       implicit none !Tens de declarar tudo...
       real pres(*),temp(*),urel(*)
       real indef,pncl0,rmis0,tpot0,tpeq0,tamb,ramb,tvamb         !Ambiente
       real pres1,pres2,inte1,inte2                               !Comuns
       real tpar1,tpar2,rpar1,rpar2,tvpar                         !Parcela
       real presdoncl,tempvirtual,vartvarp,potencial,potencialeq
       real razaodemistura,varrvarp,integrando,epsi,cine,erro0
       real tparcela,rparcela
       integer num,i0,i
       logical fim
       parameter (epsi=0.62198)
       cine=0.
       fim=.false.
       if (pres(i0).eq.indef.or.temp(i0).eq.indef.or.urel(i0).eq.indef) then
           calccine=indef
           return
       endif
!* Tomo os primeiros valores, para depois jog�-los aos valores velhos...
       pncl0=presdoncl(pres(i0),temp(i0),urel(i0),indef)
       rmis0=razaodemistura(pres(i0),temp(i0),urel(i0),indef)
       tpot0=potencial(pres(i0),temp(i0)+273.16,rmis0,indef)
       tpeq0=potencialeq(pres(i0),temp(i0)+273.16,rmis0,indef)
       pres2=pres(i0)
       tamb=temp(i0)+273.16
       ramb=razaodemistura(pres2,tamb-273.16,urel(i0),indef)
       tvamb=tempvirtual(pres2,tamb,ramb,indef)
       tpar2=temp(i0)+273.16 !Come�a com mesma temperatura do ambiente
       rpar2=rmis0           !Come�a com mesmo rmis do ambiente
       tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
       inte2=0.
       i=i0+1
       do while (.not.fim.and.i.le.num)
         if (pres(i).ne.indef.and.temp(i).ne.indef.and.urel(i).ne.indef)then
! Passo os valores de algumas vari�veis para o valor "velho"
             pres1=pres2
             tpar1=tpar2
             rpar1=rpar2
             inte1=inte2
! Recalculo estas vari�veis e calculo a contribui��o para o CINE
             pres2=pres(i)
             tamb=temp(i)+273.16
             ramb=razaodemistura(pres2,tamb-273.16,urel(i),indef)
             tvamb=tempvirtual(pres2,tamb,ramb,indef)
             tpar2=tparcela(pres2,pncl0,tpot0,tpeq0,rmis0,erro0,indef)
             rpar2=rparcela(pres2,pncl0,rmis0,tpar2,indef)
             tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
             inte2=integrando(tvamb,tvpar,indef)
             if (inte2.lt.0.) then 
                 fim=.true.
               else             
                 cine=cine-0.5*(inte1+inte2)*log(pres2/pres1)
             endif             
         endif 
         i=i+1
       enddo
!   Caso tenha acabado at� aqui, indefini-lo-ei, pois na realidade ele
! vale infinito.....
       if (.not.fim) cine=indef 
       calccine=cine
       return
      end





!***********************************************************************
!  Esta fun��o calcula o NCE de uma determinada sondagem               *
!***********************************************************************
       real function calcnce(num,i0,pres,temp,urel,erro0,indef)
       implicit none !Tens de declarar tudo...
       real pres(*),temp(*),urel(*)
       real indef,pncl0,rmis0,tpot0,tpeq0,tamb,ramb,tvamb         !Ambiente
       real pres1,pres2                                           !Comuns
       real tpar1,tpar2,rpar1,rpar2,tvpar                         !Parcela
       real presdoncl,tempvirtual,vartvarp,potencial,potencialeq
       real razaodemistura,varrvarp,integrando,epsi,nce,erro0
       real tparcela,rparcela
       integer num,i0,i
       logical fim
       parameter (epsi=0.62198)
       nce=0.
       fim=.false.
       if (pres(i0).eq.indef.or.temp(i0).eq.indef.or.urel(i0).eq.indef)then
           nce=indef
           return
       endif
! Tomo os primeiros valores, para depois jog�-los aos valores velhos...
       pncl0=presdoncl(pres(i0),temp(i0),urel(i0),indef)
       rmis0=razaodemistura(pres(i0),temp(i0),urel(i0),indef)
       tpot0=potencial(pres(i0),temp(i0)+273.16,rmis0,indef)
       tpeq0=potencialeq(pres(i0),temp(i0)+273.16,rmis0,indef)
       pres2=pres(i0)
       tamb=temp(i0)+273.16
       ramb=razaodemistura(pres2,tamb-273.16,urel(i0),indef)
       tvamb=tempvirtual(pres2,tamb,ramb,indef)
       tpar2=temp(i0)+273.16 !Come�a com mesma temperatura do ambiente
       rpar2=rmis0           !Come�a com mesmo rmis do ambiente
       tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
       i=i0+1
       do while (.not.fim.and.i.le.num)
         if (pres(i).ne.indef.and.temp(i).ne.indef.and.urel(i).ne.indef)then
! Passo os valores de algumas vari�veis para o valor "velho"
             pres1=pres2
             tpar1=tpar2
             rpar1=rpar2
! Recalculo estas vari�veis e calculo a contribui��o para o CINE
             pres2=pres(i)
             tamb=temp(i)+273.16
             ramb=razaodemistura(pres2,tamb-273.16,urel(i),indef)
             tvamb=tempvirtual(pres2,tamb,ramb,indef)
             tpar2=tparcela(pres2,pncl0,tpot0,tpeq0,rmis0,erro0,indef)
             rpar2=rparcela(pres2,pncl0,rmis0,tpar2,indef)
             tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
             if (tvpar.gt.tvamb) then 
                 fim=.true.
                 nce=0.5*(pres1+pres2)
             endif             
         endif 
         i=i+1
       enddo
!*   Caso tenha acabado at� aqui, zero-o, numa forma de dizer que � inating�vel
       if (.not.fim) nce=0.
       calcnce=nce
       return
      end





!************************************************************************
!*  Esta fun��o calcula a CAPE de uma determinada sondagem              *
!************************************************************************
      real function calccape(num,i0,pres,temp,urel,erro0,indef)
       implicit none !Tens de declarar tudo...
       real pres(*),temp(*),urel(*)
       real indef,pncl0,rmis0,tpot0,tpeq0,tamb,ramb,tvamb         !Ambiente
       real pres1,pres2,inte1,inte2                               !Comuns
       real tpar1,tpar2,rpar1,rpar2,tvpar                         !Parcela
       real presdoncl,tempvirtual,vartvarp,potencial,potencialeq
       real razaodemistura,varrvarp,integrando,epsi,cape,erro0
       real tparcela,rparcela
       integer num,i0,i
       logical fim,embaixo
       parameter (epsi=0.62198)
       cape=0.
       fim=.false.
       embaixo=.true.
       if (pres(i0).eq.indef.or.temp(i0).eq.indef.or.urel(i0).eq.indef)then
           calccape=indef
           return
       endif
!* Tomo os primeiros valores, para depois jog�-los aos valores velhos...
       pncl0=presdoncl(pres(i0),temp(i0),urel(i0),indef)
       rmis0=razaodemistura(pres(i0),temp(i0),urel(i0),indef)
       tpot0=potencial(pres(i0),temp(i0)+273.16,rmis0,indef)
       tpeq0=potencialeq(pres(i0),temp(i0)+273.16,rmis0,indef)
       pres2=pres(i0)
       tamb=temp(i0)+273.16
       ramb=razaodemistura(pres2,tamb-273.16,urel(i0),indef)
       tvamb=tempvirtual(pres2,tamb,ramb,indef)
       tpar2=temp(i0)+273.16 !Come�a com mesma temperatura do ambiente
       rpar2=rmis0           !Come�a com mesmo rmis do ambiente
       tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
       inte2=0.
       i=i0+1
       do while (.not.fim.and.i.le.num)
         if (pres(i).ne.indef.and.temp(i).ne.indef.and.urel(i).ne.indef)then
!* Passo os valores de algumas vari�veis para o valor "velho"
             pres1=pres2
             tpar1=tpar2
             rpar1=rpar2
             inte1=inte2
!* Recalculo estas vari�veis e calculo a contribui��o para o CINE
             pres2=pres(i)
             tamb=temp(i)+273.16
             ramb=razaodemistura(pres2,tamb-273.16,urel(i),indef)
             tvamb=tempvirtual(pres2,tamb,ramb,indef)
             tpar2=tparcela(pres2,pncl0,tpot0,tpeq0,rmis0,erro0,indef)
             rpar2=rparcela(pres2,pncl0,rmis0,tpar2,indef)
             tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
             inte2=integrando(tvamb,tvpar,indef)
             if (.not.embaixo.and.inte2.gt.0.) then 
                 fim=.true.
               elseif (inte2.le.0) then
                 embaixo=.false.         
                 cape=cape+0.5*(inte1+inte2)*log(pres2/pres1)
             endif             
         endif 
         i=i+1
       enddo
!*   Caso tenha acabado at� aqui, indefini-lo-ei, pois na realidade ele
!* vale infinito.....
       if (.not.fim) cape=0.
       calccape=cape
       return
      end





!************************************************************************
!*  Esta fun��o calcula o NPE de uma determinada sondagem		*
!************************************************************************
      real function calcnpe(num,i0,pres,temp,urel,erro0,indef)
       implicit none !Tens de declarar tudo...
       real pres(*),temp(*),urel(*)
       real indef,pncl0,rmis0,tpot0,tpeq0,tamb,ramb,tvamb         !Ambiente
       real pres1,pres2,inte1,inte2                               !Comuns
       real tpar1,tpar2,rpar1,rpar2,tvpar                         !Parcela
       real presdoncl,tempvirtual,vartvarp,potencial,potencialeq
       real razaodemistura,varrvarp,integrando,epsi,npe,erro0
       real tparcela,rparcela
       integer num,i0,i
       logical fim,embaixo
       parameter (epsi=0.62198)
       npe=0.
       fim=.false.
       embaixo=.true.
       if (pres(i0).eq.indef.or.temp(i0).eq.indef.or.urel(i0).eq.indef)then
           calcnpe=indef
           return
       endif
!* Tomo os primeiros valores, para depois jog�-los aos valores velhos...
       pncl0=presdoncl(pres(i0),temp(i0),urel(i0),indef)
       rmis0=razaodemistura(pres(i0),temp(i0),urel(i0),indef)
       tpot0=potencial(pres(i0),temp(i0)+273.16,rmis0,indef)
       tpeq0=potencialeq(pres(i0),temp(i0)+273.16,rmis0,indef)
       pres2=pres(i0)
       tamb=temp(i0)+273.16
       ramb=razaodemistura(pres2,tamb-273.16,urel(i0),indef)
       tvamb=tempvirtual(pres2,tamb,ramb,indef)
       tpar2=temp(i0)+273.16 !Come�a com mesma temperatura do ambiente
       rpar2=rmis0           !Come�a com mesmo rmis do ambiente
       tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
       inte2=0.
       i=i0+1
       do while (.not.fim.and.i.le.num)
         if (pres(i).ne.indef.and.temp(i).ne.indef.and.urel(i).ne.indef)then
!* Passo os valores de algumas vari�veis para o valor "velho"
             pres1=pres2
             tpar1=tpar2
             rpar1=rpar2
!* Recalculo estas vari�veis e calculo a contribui��o para o CINE
             pres2=pres(i)
             tamb=temp(i)+273.16
             ramb=razaodemistura(pres2,tamb-273.16,urel(i),indef)
             tvamb=tempvirtual(pres2,tamb,ramb,indef)
             tpar2=tparcela(pres2,pncl0,tpot0,tpeq0,rmis0,erro0,indef)
             rpar2=rparcela(pres2,pncl0,rmis0,tpar2,indef)
             tvpar=tempvirtual(pres2,tpar2,rpar2,indef)
             if (.not.embaixo.and.tvpar.lt.tvamb) then 
                 fim=.true.
                 npe=0.5*(pres1+pres2)
               elseif (tvpar.ge.tvamb) then
                 embaixo=.false.         
             endif             
         endif 
         i=i+1
       enddo
!*   Caso tenha acabado at� aqui, indefini-lo-ei, pois na realidade ele
!* vale infinito.....
       if (.not.fim) npe=indef
       calcnpe=npe
       return
      end







!************************************************************************
!* Fun��o que calcula a press�o do NCL a partir de p,T,Urel		*
!************************************************************************  
      real function presdoncl(pres0,temp0,urel0,indef)
       implicit none !Tens de declarar tudo....
       real pres0,temp0,urel0,indef,tempk,tpot,tncl
       if (pres0.eq.indef.or.temp0.eq.indef.or.urel0.eq.indef) then
           presdoncl=indef
         else
           tempk=temp0+273.16
           tpot=tempk*((1000./pres0)**0.286)
           tncl=1/(1/(tempk-55.)-log(urel0/100.)/2840.)+55.
           presdoncl=1000.*((tncl/tpot)**3.4965035)
       endif
       return
      end
      

!
!
!************************************************************************
!* Fun��o que calcula a temperatura virtual do ar                       *
!************************************************************************
      real function tempvirtual(pres0,temp0,rmis0,indef)
       implicit none !Tens de declarar tudo....
       real pres0,temp0,rmis0,umes,epsi,pvap,indef
       parameter (epsi=0.62198)
       if (pres0.eq.indef.or.temp0.eq.indef.or.rmis0.eq.indef) then
           tempvirtual=indef
         else
          umes=rmis0/(rmis0+1)
          tempvirtual=temp0*(1+0.61*umes)
       endif
       return
      end

!
!
!************************************************************************
!* Fun��o que calcula a raz�o de mistura em kg/kg                       *
!************************************************************************
      real function razaodemistura(pres0,temp0,urel0,indef)
       implicit none !Tens de declarar tudo....
       real pres0,temp0,urel0,pvap,indef,epsi
       parameter (epsi=0.62198)
       if (pres0.eq.indef.or.temp0.eq.indef.or.urel0.eq.indef) then
           razaodemistura=indef
         else
           pvap=0.01*urel0*6.112*exp(17.67*temp0/(temp0+243.5))
           razaodemistura=epsi*pvap/(pres0-pvap)
       endif
       return
      end

!
!
!************************************************************************
!* Fun��o que calcula a temperatura potencial da parcela                *
!************************************************************************
      real function potencial(pres0,temp0,rmis0,indef)
       implicit none !Tens de declarar tudo
       real pres0,temp0,rmis0,indef,epsi
       parameter (epsi=0.62198)
       if (pres0.eq.indef.or.temp0.eq.indef) then
           potencial=indef
         elseif (rmis0.eq.indef) then
           potencial=temp0*((1000./pres0)**0.2854)
         else
           potencial=temp0*((1000./pres0)**(0.2854*(1-0.28*rmis0)))
       endif
       return
      end



!************************************************************************
!* Fun��o que calcula a temperatura potencial equivalente da parcela    *
!************************************************************************
      real function potencialeq(pres0,temp0,rmis0,indef)
       implicit none !Tens de declarar tudo...
       real pres0,temp0,rmis0,indef,pvap,tncl,epsi,tpot
       parameter (epsi=0.62198)
       if (pres0.eq.indef.or.temp0.eq.indef.or.rmis0.eq.indef) then
           potencialeq=indef
         else
           pvap=pres0*rmis0/(epsi+rmis0)
           tncl=2840./(3.5*log(temp0)-log(pvap)-4.805)+55.
           tpot=temp0*((1000./pres0)**(0.2854*(1-0.28*rmis0)))
           potencialeq=tpot*exp((3.376/tncl-0.00254)*&
                       1000.*rmis0*(1+0.81*rmis0))
       endif
       return
      end

!************************************************************************
!* Fun��o iterativa que calcula a temperatura da parcela                *
!************************************************************************
      real function tparcela(pres0,pncl0,tpot0,tpeq0,rmis0,erro0,indef)
       implicit none !Tens de declarar tudo...
       real pres0,pncl0,tpot0,tpeq0,rmis0,erro0,indef
       real erro,epsi,tparnovo,tparm0,tparm1,esatm0,esatm1,rsatm0
       real rsatm1,tpotm0,tpotm1,tpeqm0,tpeqm1
       parameter (epsi=0.62198)
       tparnovo=273.16
       erro=2.*erro0
       if (pres0.eq.indef.or.pncl0.eq.indef) then
           tparnovo=indef
         elseif(pncl0.eq.0.) then !Press�o do NCL inating�vel
           tparnovo=indef
         elseif(pres0.gt.pncl0) then !Iterage com temperatura potencial
           do while (erro.gt.erro0)
             tparm0=tparnovo
             tparm1=tparm0+1.
             rsatm0=1000.*rmis0 !S� por via das d�vidas
             tpotm0=tparm0*((1000./pres0)**(0.2854*(1-0.28e-3*rsatm0)))
             tpotm1=tparm1*((1000./pres0)**(0.2854*(1-0.28e-3*rsatm0)))
             tparnovo=tparm0+(tpot0-tpotm0)/(tpotm1-tpotm0)
             erro=200.*(tparnovo-tparm0)/(tparnovo+tparm0) !O erro est� em %
           enddo           
         else !Iterage com temperatura potencial equivalente
           do while (erro.gt.erro0)
             tparm0=tparnovo
             tparm1=tparm0+1.
             esatm0=6.112*exp(17.67*(tparm0-273.16)/(tparm0-29.66))
             esatm1=6.112*exp(17.67*(tparm1-273.16)/(tparm1-29.66))
             rsatm0=1000.*epsi*esatm0/(pres0-esatm0)
             rsatm1=1000.*epsi*esatm1/(pres0-esatm1)
             tpotm0=tparm0*((1000./pres0)**(0.2854*(1-0.28e-3*rsatm0)))
             tpotm1=tparm1*((1000./pres0)**(0.2854*(1-0.28e-3*rsatm1)))
             tpeqm0=tpotm0*exp((3.376/tparm0-0.00254)*rsatm0*(1+0.81e-3*rsatm0))
             tpeqm1=tpotm1*exp((3.376/tparm1-0.00254)*rsatm1*(1+0.81e-3*rsatm1))
             tparnovo=tparm0+(tpeq0-tpeqm0)/(tpeqm1-tpeqm0)
             erro=abs(200.*(tparnovo-tparm0)/(tparnovo+tparm0)) !O erro est� em %
           enddo
       endif
       tparcela=tparnovo
       return
      end

!************************************************************************
!* Fun��o que calcula a raz�o de mistura da parcela                     *
!************************************************************************
      real function rparcela(pres0,pncl0,rmis0,tpar,indef)
       implicit none !Tens de declarar tudo...
       real pres0,pncl0,rmis0,tpar,indef,razaodemistura
       if (pres0.eq.indef.or.pncl0.eq.0) then
           rparcela=indef
         elseif (pres0.gt.pncl0) then
           rparcela=rmis0
         else
           rparcela=razaodemistura(pres0,tpar-273.16,0.*tpar+100.,indef)
       endif
       return
      end


!************************************************************************
!* Fun��o que calcula o termo integrando da CINE e CAPE                 *
!************************************************************************
      real function integrando(tvamb,tvpar,indef)
       implicit none !Tens de declarar tudo....
       real tvamb,tvpar,ra,indef
       parameter (ra=287.04)
       if (tvamb.eq.indef.or.tvpar.eq.indef) then
           integrando=indef
         else
           integrando=-ra*(tvpar-tvamb)
       endif
       return
      end

!***********************************************************************


        
