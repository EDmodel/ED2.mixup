!==========================================================================================!
!==========================================================================================!
!      This is the main driver for the Farquar and Leuning (1995) photosynthesis model.    !
!------------------------------------------------------------------------------------------!
subroutine lphysiol_full(T_L,e_A,C_A,PAR,rb,adens,A_open,A_cl,rsw_open,rsw_cl,veg_co2_open &
                        ,veg_co2_cl,pft,prss,leaf_resp,green_leaf_factor,leaf_aging_factor &
                        ,old_st_data,llspan,vm_bar,ilimit)

   use c34constants   , only : stoma_data               & ! structure
                             , farqdata                 & ! structure
                             , metdat                   & ! structure
                             , solution                 & ! structure
                             , glim                     ! ! structure
   use pft_coms       , only : D0                       & ! intent(in)
                             , cuticular_cond           & ! intent(in)
                             , dark_respiration_factor  & ! intent(in)
                             , stomatal_slope           & ! intent(in)
                             , quantum_efficiency       & ! intent(in)
                             , photosyn_pathway         & ! intent(in)
                             , Vm0                      & ! intent(in)
                             , Vm_low_temp              & ! intent(in)
                             , Vm_high_temp             & ! intent(in)
                             , phenology                ! ! intent(in)
   use physiology_coms, only : istoma_scheme            & ! intent(in)
                             , c34smin_ci               & ! intent(in)
                             , c34smax_ci               & ! intent(in)
                             , c34smin_gsw              & ! intent(in)
                             , c34smax_gsw              ! ! intent(in)
   use phenology_coms , only : vm_tran                  & ! intent(in)
                             , vm_slop                  & ! intent(in)
                             , vm_amp                   & ! intent(in)
                             , vm_min                   ! ! intent(in)
   use therm_lib      , only : rslif                    ! ! function
   use consts_coms    , only : t00                      & ! intent(in)
                             , mmdry1000                & ! intent(in)
                             , epi                      ! ! intent(in)
   implicit none
   !------ Arguments. ---------------------------------------------------------------------!
   real             , intent(in)    :: T_L
   real             , intent(in)    :: e_A
   real             , intent(in)    :: C_A
   real             , intent(in)    :: PAR
   real             , intent(in)    :: rb
   real             , intent(in)    :: adens
   real             , intent(in)    :: prss
   real             , intent(inout) :: A_open
   real             , intent(inout) :: A_cl
   real             , intent(inout) :: rsw_open
   real             , intent(inout) :: rsw_cl
   real             , intent(inout) :: veg_co2_open
   real             , intent(inout) :: veg_co2_cl
   real             , intent(inout) :: leaf_resp
   real             , intent(in)    :: green_leaf_factor
   real             , intent(in)    :: leaf_aging_factor
   integer          , intent(in)    :: pft
   integer          , intent(out)   :: ilimit
   type(stoma_data) , intent(inout) :: old_st_data
   real             , intent(in)    :: llspan
   real             , intent(in)    :: vm_bar
   !----- Local variables. ----------------------------------------------------------------!
   type(farqdata)                   :: gsdata
   type(metdat)                     :: met
   type(solution)                   :: sol
   logical                          :: recalc
   type(glim)                       :: apar
   real                             :: co2cp
   real                             :: vmbar
   real                             :: vmllspan
   !---------------------------------------------------------------------------------------!


   ilimit = -1

   !----- Load physiological parameters into structure. -----------------------------------!
   gsdata%D0    = D0(pft)
   gsdata%b     = cuticular_cond(pft)
   gsdata%gamma = dark_respiration_factor(pft)
   gsdata%m     = stomatal_slope(pft)
   gsdata%alpha = quantum_efficiency(pft)

   !----- Load met into structure. --------------------------------------------------------!
   met%tl    = T_L
   met%ea    = e_A
   met%ca    = C_A
   met%par   = PAR * (1.0e6)
   met%gbc   = adens / (rb*4.06e-8)
   met%gbci  = 1.0 / met%gbc
   met%el    = epi * rslif(prss, met%tl + t00)
   met%compp = co2cp(met%tl)
   met%gbw   = 1.4 * met%gbc
   met%eta   = 1.0 + (met%el-met%ea)/gsdata%d0

   !----- Set up how we look for the solution. --------------------------------------------!
   sol%eps       = 3.0e-8
   sol%ninterval = 6

   !----- Set up the first guess for the new method. --------------------------------------!
   if (rsw_open == 0.0 ) then
      sol%gsw2_1st = sqrt(c34smin_gsw*c34smax_gsw)
   else
      sol%gsw2_1st  = 1.0e9 * adens  / (mmdry1000 * rsw_open)
      if (sol%gsw2_1st < c34smin_gsw .or. sol%gsw2_1st > c34smax_gsw) then
         sol%gsw2_1st = sqrt(c34smin_gsw*c34smax_gsw)
      end if
   end if
   if (veg_co2_open * 1.e-6 < c34smin_ci .or. veg_co2_open * 1.e-6 > c34smax_ci) then
      sol%ci2_1st   = met%ca
   else
      sol%ci2_1st   = veg_co2_open * 1.e-6
   end if

   !----- Set variables for light-controlled phenology. -----------------------------------!
   if (phenology(pft) == 3) then
      vmllspan = vm_amp / (1.0 + (llspan/vm_tran)**vm_slop) + vm_min
      vmbar    = vm_bar
   else
      vmllspan = 0.0
      vmbar    = 0.0
   endif

   !----- Prepare derived terms for both exact and approximate solutions. -----------------!
   call prep_lphys_solution(photosyn_pathway(pft),Vm0(pft),met,Vm_low_temp(pft)            &
                           ,Vm_high_temp(pft),leaf_aging_factor,green_leaf_factor          &
                           ,leaf_resp,vmllspan,vmbar,gsdata,apar)

   !----- Decide whether to do the exact solution or the approximation. -------------------!
   recalc = .true.
   if (istoma_scheme == 1) then
      if (old_st_data%recalc == 0) recalc = .false.
   end if

   if (recalc) call exact_lphys_solution(photosyn_pathway(pft),met,apar,gsdata,sol,ilimit)

   if (istoma_scheme == 1 .and. recalc) then
      call store_exact_lphys_solution(old_st_data,met,prss,leaf_aging_factor               &
                                     ,green_leaf_factor,sol,ilimit,gsdata,apar             &
                                     ,photosyn_pathway(pft),Vm0(pft),Vm_low_temp(pft)      &
                                     ,Vm_high_temp(pft),vmbar)
   end if

   if (recalc) then
      call fill_lphys_sol_exact(A_open,rsw_open,A_cl,rsw_cl,veg_co2_open,veg_co2_cl,sol    &
                               ,adens)
      if (istoma_scheme == 1) old_st_data%recalc = 0
   else
      call fill_lphys_sol_approx(gsdata,met,apar,old_st_data,sol,A_cl,rsw_cl,veg_co2_open  &
                                ,veg_co2_cl,adens,rsw_open,A_open,photosyn_pathway(pft)    &
                                ,prss)
   end if

   return
end subroutine lphysiol_full
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine c3solver(met,apar,gsdata,sol,ilimit)
  use c34constants, only : farqdata, metdat,glim,solution
  implicit none

  
  type(farqdata) :: gsdata
  type(metdat) :: met
  type(glim) :: apar
  type(solution) :: sol
  logical :: success_flag
  integer :: ilimit

  ! Solve par case
  ilimit = 1
  call setapar_c3(gsdata,met,apar,1)
  call solve_closed_case_c3(gsdata,met,apar,sol,1)
  ! Return if nighttime
  if(met%par < 1.0e-3)then
     call closed2open(sol,1)
     ilimit = 0
     return
  endif
  success_flag = .true.
  call solve_open_case_c3(gsdata,met,apar,sol,1,success_flag)
  if(.not. success_flag)then
     call closed2open(sol,1)
     ilimit = -1
     return
  end if

  ! Solve the vm case
  call setapar_c3(gsdata,met,apar,2)
  call solve_closed_case_c3(gsdata,met,apar,sol,2)
  call solve_open_case_c3(gsdata,met,apar,sol,2,success_flag)
  if(.not. success_flag)then
     call closed2open(sol,1)
     ilimit = -2
     return
  end if

  if(sol%a(1,2) < sol%a(1,1))then
     sol%gsw(1,1) = sol%gsw(1,2)
     sol%es(1,1) = sol%es(1,2)
     sol%ci(1,1) = sol%ci(1,2)
     sol%cs(1,1) = sol%cs(1,2)
     sol%a(1,1) = sol%a(1,2)
  endif
  if(sol%a(2,2) < sol%a(2,1))then
     sol%gsw(2,1) = sol%gsw(2,2)
     sol%es(2,1) = sol%es(2,2)
     sol%ci(2,1) = sol%ci(2,2)
     sol%cs(2,1) = sol%cs(2,2)
     sol%a(2,1) = sol%a(2,2)
     ilimit = 2
  endif

  if(sol%cs(2,1) > 1.25e7)then
     success_flag = .false.
     
!     print*,'Stomatal conductance dangerously close to upper limit.  Stopping.'
!     print*,met%ea,met%ca,met%rn,met%tl,met%par,met%gbc,met%gbw,met%ta  &
!          ,met%el,met%compp,met%eta

  endif

  return

end subroutine c3solver
!================================================================

subroutine c4solver(met,apar,gsdata,sol,ilimit)
  use c34constants, only : farqdata, metdat, glim, solution
  implicit none
  

  type(farqdata) :: gsdata
  type(metdat) :: met
  type(glim) :: apar
  type(solution) :: sol
  integer :: success_flag
  integer :: ilimit

  if(apar%vm > gsdata%alpha*met%par)then
     ! Solve par case
     ilimit = 1
     call setapar_c4(gsdata,met,apar,1)
     call solve_closed_case_c4(gsdata,met,apar,sol,1)
     if(met%par < 1.0e-3)then
        call closed2open(sol,1)
        ilimit = 0
        return ! nighttime; return
     endif 
     success_flag = 1
     call solve_open_case_c4(gsdata,met,apar,sol,1,success_flag)
     if(success_flag == 0)then
        call closed2open(sol,1)
        ilimit = -1
        return
     endif
  else
     ! Solve the vm case
     ilimit = 2
     call setapar_c4(gsdata,met,apar,2)
     ! yes, these should be ones below.  
     call solve_closed_case_c4(gsdata,met,apar,sol,1)
     success_flag = 1
     call solve_open_case_c4(gsdata,met,apar,sol,1,success_flag)
     if(success_flag == 0)then
        call closed2open(sol,1)
        ilimit = -2
        return
     endif
  endif
  ! Solve the third case
  call setapar_c4(gsdata,met,apar,3)
  call solve_closed_case_c4(gsdata,met,apar,sol,2)
  call solve_open_case_c4(gsdata,met,apar,sol,2,success_flag)
  if(success_flag == 0)then
     call closed2open(sol,1)
     ilimit = -1
     return
  endif

  if(sol%a(1,2) < sol%a(1,1))then
     sol%gsw(1,1) = sol%gsw(1,2)
     sol%es(1,1)  = sol%es(1,2)
     sol%ci(1,1)  = sol%ci(1,2)
     sol%cs(1,1)  = sol%cs(1,2)
     sol%a(1,1)   = sol%a(1,2)
  endif
  if(sol%a(2,2) < sol%a(2,1))then
     sol%gsw(2,1) = sol%gsw(2,2)
     sol%es(2,1)  = sol%es(2,2)
     sol%ci(2,1)  = sol%ci(2,2)
     sol%cs(2,1)  = sol%cs(2,2)
     sol%a(2,1)   = sol%a(2,2)
     ilimit = 3
  endif

  if(sol%cs(2,1) > 1.25e7)then
     print*,'Stomatal conductance dangerously close to upper limit.  Stopping.'
     success_flag = 0
     print*,met%ea,met%ca,met%rn,met%tl,met%par,met%gbc,met%gbw,met%ta  &
          ,met%el,met%compp,met%eta
  endif

  return

end subroutine c4solver

!=====================================
subroutine setapar_c3(gsdata,met,apar,i)
  use c34constants, only : glim     & ! structure
                         , farqdata & ! structure
                         , metdat   ! ! structure
  implicit none
  

  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  integer :: i

  if(i == 1)then
     apar%rho = gsdata%alpha*met%par
     apar%sigma = -gsdata%alpha*met%par*met%compp
     apar%tau = 2.0*met%compp
  elseif(i == 2)then
     apar%rho = apar%vm
     apar%sigma = -apar%vm*met%compp
     apar%tau = apar%k1*(1.0+apar%k2)
  endif

  return
end subroutine setapar_c3

!=====================================
subroutine setapar_c4(gsdata,met,apar,i)
  use c34constants, only : glim, farqdata, metdat
  implicit none
  

  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  integer :: i

  if(i == 1)then
     apar%rho = 0.0
     apar%sigma = gsdata%alpha*met%par-gsdata%gamma*apar%vm
  elseif(i == 2)then
     apar%rho = 0.0
     apar%sigma = apar%vm*(1.0-gsdata%gamma)
  elseif(i == 3)then
     apar%rho = 18000.0*apar%vm
     apar%sigma = -gsdata%gamma*apar%vm
  endif

  return
end subroutine setapar_c4

!================================================
real function aflux_c3(apar,gsw,ci)
  use c34constants, only : glim
  implicit none
  
  type(glim) :: apar
  real :: gsw,ci

  aflux_c3 = (apar%rho*ci+apar%sigma)/(ci+apar%tau)+apar%nu

  return
end function aflux_c3

!================================================
real function aflux_c4(apar,met,gsw)
  use c34constants, only : glim, metdat
  implicit none
  
  type(glim) :: apar
  type(metdat) :: met
  real :: gsw

  aflux_c4 = apar%rho * gsw * (-gsw*apar%sigma   &
       + met%gbc*met%ca*(1.6*apar%rho+gsw))  &
       /((1.6*apar%rho+gsw)*(apar%rho*gsw+met%gbc*(1.6*apar%rho+gsw))) &
       +apar%sigma*gsw/(1.6*apar%rho+gsw)

  return
end function aflux_c4

!================================================
real function csc_c4(apar,met,gsw)
  use c34constants, only : glim, metdat
  implicit none
  
  type(metdat) :: met
  type(glim) :: apar
  real :: gsw

  csc_c4 = (-gsw*apar%sigma   &
       + met%gbc*met%ca*(1.6*apar%rho+gsw))  &
       /(apar%rho*gsw+met%gbc*(1.6*apar%rho+gsw))


  return
end function csc_c4

!================================================
real function csc_c3(met,a)
  use c34constants, only : metdat
  implicit none
  
  type(metdat) :: met
  real :: a

  csc_c3 = met%ca-a*met%gbci


  return
end function csc_c3

!================================================
real function residual_c3(gsdata,met,apar,x)
  use c34constants, only : farqdata,metdat,glim
  implicit none
  

  type(farqdata) :: gsdata
  type(metdat) :: met
  type(glim) :: apar
  real :: x,ci,a,cs
  logical :: success
  real, external :: quad4ci
  real, external :: aflux_c3
  real, external :: csc_c3

  ci = quad4ci(gsdata,met,apar,x,success)
  if(.not. success)then
     residual_c3 = 9.9e9
     return
  endif
  a = aflux_c3(apar,x,ci)
  cs = csc_c3(met,a)

  residual_c3 = (cs-met%compp)*x**2   &
       + ((met%gbw*met%eta-gsdata%b)*(cs-met%compp)-gsdata%m*a)*x  &
       -gsdata%b*met%eta*met%gbw*(cs-met%compp)-gsdata%m*a*met%gbw

  return
end function residual_c3

!================================================
real function residual_c4(gsdata,met,apar,x)
  use c34constants, only : farqdata,metdat,glim
  implicit none
  

  type(farqdata) :: gsdata
  type(metdat) :: met
  type(glim) :: apar
  real :: a,cs,x
  real, external :: aflux_c4
  real, external :: csc_c4

  a = aflux_c4(apar,met,x)
  cs = csc_c4(apar,met,x)

  residual_c4 = (cs-met%compp)*x**2   &
       + ((met%gbw*met%eta-gsdata%b)*(cs-met%compp)-gsdata%m*a)*x  &
       -gsdata%b*met%eta*met%gbw*(cs-met%compp)-gsdata%m*a*met%gbw


  return
end function residual_c4

!===============================
subroutine zbrak_c3(gsdata,met,apar,x1,x2,n,xb1,xb2,nb)
  use c34constants, only :glim, farqdata,metdat
  use physiology_coms, only : maxroots
  implicit none
  

  real :: x1,x2
  integer :: n,nb,nbb,i
  real :: x,dx,fp,fc
  real, dimension(maxroots) :: xb1,xb2
  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  real, external :: residual_c3

  nbb = nb
  nb = 0
  x = x1
  dx = (x2-x1)/real(n)
  fp = residual_c3(gsdata,met,apar,x)
  do i=1,n
     x = x + dx
     fc = residual_c3(gsdata,met,apar,x)
     if(fc*fp < 0.0)then
        nb = nb + 1
        xb1(nb) = x-dx
        xb2(nb) = x
     endif
     fp = fc
     if(nbb == nb)return
  enddo

  return
end subroutine zbrak_c3

!-----------------------------------
real function zbrent_c3(gsdata,met,apar,x1,x2,tol,success_flag)
  use c34constants, only : glim, farqdata,metdat
  implicit none
  

  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  integer, parameter :: itmax = 100
  real, parameter :: eps = 3.0e-8
  real :: x1,x2,tol,a,b,fa,fb,fc,c,d,e,tol1,s,q,p,r,xm
  integer :: iter
  logical :: success_flag
  real, external :: residual_c3

  a = x1
  b = x2

  fa = residual_c3(gsdata,met,apar,a)
  fb = residual_c3(gsdata,met,apar,b)
  if(fb*fa > 0.0)then
     print*,'Root must be bracketed for ZBRENT_C3.'
     print*,fa,fb
     success_flag = .false.
     zbrent_c3=0.0
     return
  endif
  fc=fb
  do iter = 1,itmax
     if(fb*fc > 0.0)then
        c=a
        fc=fa
        d=b-a
        e=d
     endif
     if(abs(fc) < abs(fb))then
        a=b
        b=c
        c=a
        fa=fb
        fb=fc
        fc=fa
     endif
     tol1=2.0*eps*abs(b)+0.5*tol
     xm = 0.5*(c-b)
     if(abs(xm) <= tol1.or.fb == 0.0)then
        zbrent_c3=b
        return
     endif
     if(abs(e) >= tol1 .and. abs(fa) > abs(fb))then
        s=fb/fa
        if(a == c)then
           p=2.0*xm*s
           q=1.0-s
        else
           q=fa/fc
           r=fb/fc
           p=s*(2.0*xm*q*(q-r)-(b-a)*(r-1.0))
           q=(q-1.0)*(r-1.0)*(s-1.0)
        endif
        if(p > 0.0) q = -q
        p=abs(p)
        if(2.0*p  <  min(3.0*xm*q-abs(tol1*q),abs(e*q)))then
           e=d
           d=p/q
        else
           d=xm
           e=d
        endif
     else
        d=xm
        e=d
     endif
     a=b
     fa=fb
     if(abs(d) > tol1)then
        b=b+d
     else
        b=b+sign(tol1,xm)
     endif
     fb = residual_c3(gsdata,met,apar,b)
  enddo
  write (unit=*,fmt='(a)') 'ZBRENT_C3 exceeding maximum iterations.'
  zbrent_c3=b
  return
end function zbrent_c3

!===============================
subroutine zbrak_c4(gsdata,met,apar,x1,x2,n,xb1,xb2,nb)
  use c34constants, only : glim, farqdata, metdat
  use physiology_coms, only : maxroots
  implicit none
  

  real :: x1,x2
  integer :: n,nb,nbb,i
  real :: x,dx,fp,fc
  real, dimension(maxroots) :: xb1,xb2
  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  real, external :: residual_c4

  nbb = nb
  nb = 0
  x = x1
  dx = (x2-x1)/real(n)
  fp = residual_c4(gsdata,met,apar,x)
  do i=1,n
     x = x + dx
     fc = residual_c4(gsdata,met,apar,x)
     if(fc*fp < 0.0)then
        nb = nb + 1
        xb1(nb) = x-dx
        xb2(nb) = x
     endif
     fp = fc
     if(nbb == nb)return
  enddo

  return
end subroutine zbrak_c4

!-----------------------------------
real function zbrent_c4(gsdata,met,apar,x1,x2,tol,success_flag)
  use c34constants, only : glim, farqdata, metdat
  implicit none
  

  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  integer, parameter :: itmax = 100
  real, parameter :: eps = 3.0e-8
  real :: x1,x2,tol,a,b,fa,fb,fc,c,d,e,tol1,s,q,p,r,xm
  integer :: iter,success_flag
  real, external :: residual_c4

  a = x1
  b = x2

  fa = residual_c4(gsdata,met,apar,a)
  fb = residual_c4(gsdata,met,apar,b)
  if(fb*fa > 0.0)then
     print*,'Root must be bracketed for ZBRENT_C4.'
     print*,fa,fb
     success_flag = 0
     zbrent_c4 = 0.0
     print*,met%ea,met%ca,met%rn,met%tl,met%par,met%gbc,met%gbw,met%ta  &
          ,met%el,met%compp,met%eta
     return
  endif
  fc=fb
  do iter = 1,itmax
     if(fb*fc > 0.0)then
        c=a
        fc=fa
        d=b-a
        e=d
     endif
     if(abs(fc) < abs(fb))then
        a=b
        b=c
        c=a
        fa=fb
        fb=fc
        fc=fa
     endif
     tol1=2.0*eps*abs(b)+0.5*tol
     xm = 0.5*(c-b)
     if(abs(xm) <= tol1.or.fb == 0.0)then
        zbrent_c4=b
        return
     endif
     if(abs(e) >= tol1 .and. abs(fa) > abs(fb))then
        s=fb/fa
        if(a == c)then
           p=2.0*xm*s
           q=1.0-s
        else
           q=fa/fc
           r=fb/fc
           p=s*(2.0*xm*q*(q-r)-(b-a)*(r-1.0))
           q=(q-1.0)*(r-1.0)*(s-1.0)
        endif
        if(p > 0.0) q = -q
        p=abs(p)
        if(2.0*p  <  min(3.0*xm*q-abs(tol1*q),abs(e*q)))then
           e=d
           d=p/q
        else
           d=xm
           e=d
        endif
     else
        d=xm
        e=d
     endif
     a=b
     fa=fb
     if(abs(d) > tol1)then
        b=b+d
     else
        b=b+sign(tol1,xm)
     endif
     fb = residual_c4(gsdata,met,apar,b)
  enddo
  print*, 'ZBRENT_C4 exceeding maximum iterations.'  !! pause removed, obsolescent in Fortran 90
  zbrent_c4=b
  return
end function zbrent_c4

!=====================================================
subroutine solve_closed_case_c3(gsdata,met,apar,sol,ilimit)
  use c34constants, only : glim, farqdata, metdat, solution
  implicit none
  

  integer :: ilimit
  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  type(solution) :: sol
  real :: b,c,q
  real, dimension(2) :: ci
  integer :: j
  

  ! Do not allow assimilation

  sol%gsw(1,ilimit) = gsdata%b
  sol%es(1,ilimit) = (met%ea*met%gbw+gsdata%b*met%el)/(gsdata%b+met%gbw)
!  sol%a(1,ilimit) = -gsdata%gamma*apar%vm ![KIM] - buggy if leaf_resp is estimated in a different way
  sol%a(1,ilimit) = apar%nu
  sol%cs(1,ilimit) = met%ca - sol%a(1,ilimit)/met%gbc
  sol%ci(1,ilimit) = sol%cs(1,ilimit) - sol%a(1,ilimit) * 1.6 / gsdata%b
  return

  ! Allow assimilation


  b=apar%tau-met%ca+(apar%rho+apar%nu)*(gsdata%b+1.6*met%gbc)  &
       /(gsdata%b*met%gbc)
  c=(apar%sigma+apar%nu*apar%tau)*(gsdata%b+1.6*met%gbc)/(gsdata%b*met%gbc)  &
       -apar%tau*met%ca
  q=-0.5*b*(1.0+sqrt(1.0-4.0*c/b**2))
  ci(1)=q
  ci(2)=c/q
  if(abs(ci(1)-met%ca) < abs(ci(2)-met%ca))then
     j=1
  else
     j=2
  endif

  sol%gsw(1,ilimit) = gsdata%b
  sol%es(1,ilimit) = (met%ea*met%gbw+gsdata%b*met%el)/(gsdata%b+met%gbw)
  sol%ci(1,ilimit) = ci(j)
  sol%cs(1,ilimit) = (gsdata%b*ci(j)+1.6*met%gbc*met%ca)/(gsdata%b+1.6*met%gbc)
  sol%a(1,ilimit) = met%gbc*(met%ca-sol%cs(1,ilimit))

  return
end subroutine solve_closed_case_c3
!=====================================================
subroutine solve_closed_case_c4(gsdata,met,apar,sol,ilimit)
  use c34constants, only : glim, farqdata, metdat, solution
  implicit none
  

  integer :: ilimit
  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  type(solution) :: sol

  sol%gsw(1,ilimit) = gsdata%b
  sol%es(1,ilimit) = (met%ea*met%gbw+gsdata%b*met%el)/(gsdata%b+met%gbw)
  sol%ci(1,ilimit) = (gsdata%b*met%gbc*met%ca-apar%sigma  &
       *(gsdata%b+1.6*met%gbc)) &
       / (apar%rho*(gsdata%b+1.6*met%gbc)+gsdata%b*met%gbc)
  sol%cs(1,ilimit) = (gsdata%b*sol%ci(1,ilimit)+1.6*met%gbc*met%ca)  &
       /(gsdata%b+1.6*met%gbc)
  sol%a(1,ilimit) = apar%sigma + apar%rho * sol%ci(1,ilimit)

  return
end subroutine solve_closed_case_c4
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine solve_open_case_c3(gsdata,met,apar,sol,ilimit,success_flag)
   use c34constants   , only : glim          & ! structure
                             , farqdata      & ! structure
                             , metdat        & ! structure
                             , solution      ! ! structure
   use physiology_coms, only : new_c3_solver & ! intent(in)
                             , maxroots      ! ! intent(in)
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   integer                     , intent(in)    :: ilimit
   logical                     , intent(inout) :: success_flag
   type(glim)                  , intent(in)    :: apar
   type(farqdata)              , intent(in)    :: gsdata
   type(metdat)                , intent(in)    :: met
   type(solution)              , intent(inout) :: sol
   !----- Local variables. ----------------------------------------------------------------!
   integer                                     :: nroot
   integer                                     :: isol
   integer                                     :: nsteps
   logical                                     :: success_quad
   real                                        :: gswmin
   real                                        :: gswmax
   real                                        :: errnorm
   real   , dimension(maxroots)                :: xb1
   real   , dimension(maxroots)                :: xb2
   real                        , external      :: aflux_c3
   real                        , external      :: quad4ci
   real                        , external      :: zbrent_c3
   real                        , external      :: csc_c3
   !---------------------------------------------------------------------------------------!


   !----- Initialise the acceptable range for gsw and the number of roots. ----------------!
   gswmin = gsdata%b
   gswmax = 1.3e7
   nroot  = maxroots
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !     Here we decide which method we use to solve the conductance and the internal      !
   ! carbon.                                                                               !
   !---------------------------------------------------------------------------------------!
   if (new_c3_solver) then
      !------------------------------------------------------------------------------------!
      !     New method, which solves the internal carbon and conductance simultaneously.   !
      !------------------------------------------------------------------------------------!

      !------ Initial guess for the variables. --------------------------------------------!
      sol%ci (2,ilimit) = sol%ci2_1st
      sol%gsw(2,ilimit) = sol%gsw2_1st
      !------------------------------------------------------------------------------------!


      !------ Solve using the 2-dimensional Newton's method. ------------------------------!
      call gpp_solver2(apar,gsdata,met,sol%ci(2,ilimit),sol%gsw(2,ilimit),errnorm,nsteps   &
                      ,success_flag)
      !------------------------------------------------------------------------------------!


      !----- Compute the other variables in case of success. ------------------------------!
      if (success_flag) then
         sol%a(2,ilimit)  = aflux_c3(apar,sol%gsw(2,ilimit),sol%ci(2,ilimit))
         sol%cs(2,ilimit) = csc_c3(met,sol%a(2,ilimit))
         sol%es(2,ilimit) = (met%ea*met%gbw+sol%gsw(2,ilimit)*met%el)                      &
                          / (sol%gsw(2,ilimit)+met%gbw)
      end if
      !------------------------------------------------------------------------------------!
   else
      !------------------------------------------------------------------------------------!
      !     Old method, which solves the internal carbon and conductance separately.       !
      !------------------------------------------------------------------------------------!

      !------ Find the bracket that is likely to contain the solution. --------------------!
      call zbrak_c3(gsdata,met,apar,gswmin,gswmax,sol%ninterval,xb1,xb2,nroot)
      !------------------------------------------------------------------------------------!


      if(nroot == 0)then
         !---------------------------------------------------------------------------------!
         !     No open case solution.  Values revert to those from closed case.            !
         !---------------------------------------------------------------------------------!
         success_flag = .false.
      else
         !---------------------------------------------------------------------------------!
         !     We did find a solution.                                                     !
         !---------------------------------------------------------------------------------!
         do isol=1,nroot
            sol%gsw(2,ilimit) = zbrent_c3(gsdata,met,apar,xb1(isol),xb2(isol),sol%eps      &
                                         ,success_flag)
            if (.not. success_flag) return
            sol%ci(2,ilimit) = quad4ci(gsdata,met,apar,sol%gsw(2,ilimit),success_quad)
            if (success_quad) then
               sol%a(2,ilimit)  = aflux_c3(apar,sol%gsw(2,ilimit),sol%ci(2,ilimit))
               sol%cs(2,ilimit) = csc_c3(met,sol%a(2,ilimit))
               sol%es(2,ilimit) = (met%ea*met%gbw+sol%gsw(2,ilimit)*met%el)                &
                                / (sol%gsw(2,ilimit)+met%gbw)
            elseif (nroot == 1) then
               success_flag = .false.
           end if
         end do
         !---------------------------------------------------------------------------------!
      end if
   end if

   return
end subroutine solve_open_case_c3
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine solve_open_case_c4(gsdata,met,apar,sol,ilimit,success_flag)
  use c34constants
  implicit none
  

  integer :: ilimit
  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  type(solution) :: sol

  integer, parameter :: maxroots=5
  integer :: nroot,isol
  real :: gswmin,gswmax
  real, dimension(maxroots) :: xb1,xb2
  integer :: success_flag
  real, external :: zbrent_c4

  gswmin = gsdata%b
  gswmax = 1.3e7
  nroot = maxroots

  call zbrak_c4(gsdata,met,apar,gswmin,gswmax,sol%ninterval,xb1,xb2,nroot)
  if(nroot == 0)then
     ! No open case solution.  Values revert to those from closed case.
!     call closed2open(sol,ilimit)
     success_flag = 0
  else
     ! We did find a solution
     do isol=1,nroot
        sol%gsw(2,ilimit) = zbrent_c4(gsdata,met,apar  &
             ,xb1(isol),xb2(isol),sol%eps,success_flag)
        if(success_flag == 0)return
        sol%cs(2,ilimit) = (-apar%sigma*sol%gsw(2,ilimit)  &
             +met%gbc*met%ca*(1.6*apar%rho+sol%gsw(2,ilimit)))  &
             /(apar%rho*sol%gsw(2,ilimit)  &
             +met%gbc*(1.6*apar%rho+sol%gsw(2,ilimit)))
        sol%a(2,ilimit) = met%gbc*(met%ca-sol%cs(2,ilimit))
        sol%ci(2,ilimit) = sol%cs(2,ilimit)  &
             -1.6*sol%a(2,ilimit)/sol%gsw(2,ilimit)
        sol%es(2,ilimit) = (met%ea*met%gbw+sol%gsw(2,ilimit)*met%el)  &
             /(sol%gsw(2,ilimit)+met%gbw)

     enddo
  endif

  return
end subroutine solve_open_case_c4

!=====================================================
subroutine closed2open(sol,ilimit)
  use c34constants
  implicit none
  

  type(solution) :: sol
  integer :: ilimit

  sol%gsw(2,ilimit) = sol%gsw(1,ilimit)
  sol%es(2,ilimit) = sol%es(1,ilimit)
  sol%ci(2,ilimit) = sol%ci(1,ilimit)
  sol%cs(2,ilimit) = sol%cs(1,ilimit)
  sol%a(2,ilimit) = sol%a(1,ilimit)

  return
end subroutine closed2open
!=====================================================
real function quad4ci(gsdata,met,apar,x,success)
  use c34constants
  implicit none
  

  type(glim) :: apar
  type(farqdata) :: gsdata
  type(metdat) :: met
  real :: b,c,q,x
  real, dimension(2) :: ci
  logical :: success
  integer, dimension(2) :: sol_flag  
  integer :: isol
  logical,external :: isnan_ext

  b = (apar%rho + apar%nu) * (x + 1.6 * met%gbc) / (x * met%gbc) -   &
       met%ca + apar%tau
  c = (apar%sigma + apar%nu * apar%tau) * (x + 1.6 * met%gbc) /   &
       (x * met%gbc) - apar%tau * met%ca
  if (b == 0.) then
     q = tiny(0.)
  else
     q = -0.5 * b * (1.0 + sqrt(1.0 - 4.0 * c / b**2))
  endif
  ci(1) = q
  ci(2) = c / q
  success = .true.

  ! Test to see if the solutions are greater than zero.
  sol_flag(1:2) = 1
  do isol = 1,2
     if(ci(isol) <= 0.0 .or. ci(isol) /= ci(isol))sol_flag(isol) = 0
  enddo

  if(sol_flag(1) == 0 .and. sol_flag(2) /= 0)then
     quad4ci = ci(2)
  elseif(sol_flag(1) /= 0 .and. sol_flag(2) == 0)then
     quad4ci = ci(1)
  elseif(sol_flag(1) /= 0 .and. sol_flag(2) /= 0)then
     if(abs(ci(1)-met%ca) < abs(ci(2)-met%ca))then
        quad4ci = ci(1)
     else
        quad4ci = ci(2)
     endif
  else
     quad4ci = met%ca
     success = .false.
  endif

  return
end function quad4ci

!=============================================

logical function isnan_ext(rv)
  implicit none
  real :: rv
  if (rv == rv) then
     isnan_ext=.false.
  else
     isnan_ext=.true.
  endif
  return
end function isnan_Ext

!==============================================

real function co2cp(T)
  implicit none
  real :: arrhenius,T
  co2cp = arrhenius(T,2.12e-5,5000.0)
  return
end function co2cp

!=================================================

real function arrhenius(T,c1,c2)
  use consts_coms, only: t00
  implicit none
  real :: T,c1,c2
  real(kind=8) :: arr8
  arr8 = dble(c1) * dexp( dble(c2)*(dble(1.)/dble(288.15)-dble(1.0)/dble(T+t00)))
  arrhenius = sngl(arr8)
  return
end function arrhenius

!=================================================

real(kind=8) function arrhenius8(T,c1,c2)
  use consts_coms, only: t008
  implicit none
  real(kind=8)  :: T,c1,c2
  arrhenius8 = c1 * dexp( c2 *(1.d0/2.8815d2-1.d0/(T+t008)))
  return
end function arrhenius8

!=========================================
subroutine testsolution(gsdata,met,apar,x)

  use c34constants

  implicit none

  type(farqdata) :: gsdata
  type(metdat) :: met
  type(glim) :: apar
  real :: cs,ci,eta,gamma,co2cp,a
  real :: x,es

  eta = 1.0 + (met%el-met%ea)/gsdata%d0
  gamma = co2cp(met%tl)

  a = apar%rho * x * (-x*apar%sigma   &
       + met%gbc*met%ca*(1.6*apar%rho+x))  &
       /((1.6*apar%rho+x)*(apar%rho*x+met%gbc*(1.6*apar%rho+x))) &
       +apar%sigma*x/(1.6*apar%rho+x)
  cs = (-x*apar%sigma   &
       + met%gbc*met%ca*(1.6*apar%rho+x))  &
       /(apar%rho*x+met%gbc*(1.6*apar%rho+x))
  ci = (x*cs/1.6-apar%sigma)/(apar%rho+x/1.6)
  es = (met%ea*met%gbw+x*met%el)/(x+met%gbw)

  return
end subroutine testsolution

!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine prep_lphys_solution(photosyn_pathway, Vm0, met, Vm_low_temp,Vm_high_temp        &
                              ,leaf_aging_factor,green_leaf_factor,leaf_resp,vmllspan      &
                              ,vmbar,gsdata,apar)
   use c34constants
   implicit none
   !------ Arguments. ---------------------------------------------------------------------!
   integer       , intent(in)    :: photosyn_pathway
   real          , intent(in)    :: Vm0
   real          , intent(in)    :: Vm_low_temp
   real          , intent(in)    :: Vm_high_temp
   type(metdat)  , intent(in)    :: met
   real          , intent(in)    :: leaf_aging_factor
   real          , intent(in)    :: green_leaf_factor
   real          , intent(in)    :: vmllspan
   real          , intent(in)    :: vmbar
   real          , intent(out)   :: leaf_resp
   type(farqdata), intent(in)    :: gsdata
   type(glim)    , intent(inout) :: apar
   !----- Local variables. ----------------------------------------------------------------!
   real(kind=8)                  :: vmdble
   real(kind=8)                  :: tdble
   real(kind=8)                  :: Vm_low_temp8
   real(kind=8)                  :: Vm_high_temp8
   real                          :: vmbar_temp
   !----- External functions. -------------------------------------------------------------!
   real(kind=8)  , external      :: arrhenius8
   real          , external      :: arrhenius
   !---------------------------------------------------------------------------------------!

   !----- Saving some variables in double precision. --------------------------------------!
   tdble         = dble(met%tl)
   Vm_low_temp8  = dble(Vm_low_temp)
   Vm_high_temp8 = dble(Vm_high_temp)

   if (photosyn_pathway == 3) then

      !----- C3 parameters. ---------------------------------------------------------------!
      vmdble = dble(Vm0) * arrhenius8(tdble, 1.d0, 3.d3)                                   &
             / ( (1.d0 + dexp(4.d-1 * (Vm_low_temp8 - tdble) ))                            &
               * (1.d0 + dexp(4.d-1 * (met%tl - Vm_high_temp8 ))) )
      apar%vm = sngl(vmdble)

      if (vmllspan > 0.0) then
         vmdble = dble(vmllspan) * arrhenius8(tdble, 1.d0, 3.d3)                           &
                / ( (1.d0 + dexp(4.d-1 *  (Vm_low_temp8 - tdble) ))                        &
                  * (1.d0 + dexp(4.d-1 *  (tdble - Vm_high_temp8 ))) )
         apar%vm = sngl(vmdble)
      end if

      !----- Adjust Vm according to the aging factor. -------------------------------------!
      if (leaf_aging_factor > 0.01 .and. green_leaf_factor > 0.0001) then
         apar%vm = apar%vm * leaf_aging_factor / green_leaf_factor
      end if

      !----- Compute leaf respiration and other constants. --------------------------------!
      leaf_resp = apar%vm * gsdata%gamma

      if (vmbar > 0.0) then
         vmdble = dble(vmbar) * arrhenius8(tdble, 1.d0, 3.d3)                              &
                / ( (1.d0 + dexp(4.d-1 * (Vm_low_temp8 - tdble) ))                         &
                  * (1.d0 + dexp(4.d-1 * (met%tl - Vm_high_temp8 ))) )
         vmbar_temp = sngl(vmdble)
         leaf_resp  = vmbar_temp * gsdata%gamma
      end if  

      apar%nu = -leaf_resp
      apar%k1 = arrhenius(met%tl, 1.5e-4, 6000.0)
      apar%k2 = arrhenius(met%tl, 0.836, -1400.0)

   else
      !----- C4 parameters. ---------------------------------------------------------------!
      vmdble    = dble(Vm0) * arrhenius8(tdble, 1.d0, 3.d3)                                &
                / ( (1.d0 + dexp(4.d-1 * (Vm_low_temp8 - tdble) ))                         &
                  * (1.d0 + dexp(4.d-1 * (met%tl - Vm_high_temp8 ))) )
      apar%vm   = sngl(vmdble)

      leaf_resp = apar%vm * gsdata%gamma

   endif

   return
end subroutine prep_lphys_solution

!===================================================================

subroutine exact_lphys_solution(photosyn_pathway, met, apar, gsdata, sol,ilimit)

  use c34constants

  implicit none

  

  integer, intent(in) :: photosyn_pathway
  type(metdat), intent(in) :: met
  type(glim), intent(inout) :: apar
  type(farqdata), intent(in) :: gsdata
  type(solution), intent(inout) :: sol
  integer, intent(out) :: ilimit


  if(photosyn_pathway == 3)then

     call c3solver(met,apar,gsdata,sol,ilimit)

  else

     call c4solver(met,apar,gsdata,sol,ilimit)

  endif

  return

end subroutine exact_lphys_solution

!========================================================================

subroutine store_exact_lphys_solution(old_st_data, met, prss,   &
     leaf_aging_factor, green_leaf_factor, sol, ilimit, gsdata, apar,  &
     photosyn_pathway, Vm0, Vm_low_temp, Vm_high_temp, vmbar)

  use c34constants
  use therm_lib, only: rslif
  use consts_coms, only: t00,epi
  implicit none

  

  integer, intent(in) :: photosyn_pathway
  type(stoma_data), intent(inout) :: old_st_data
  type(metdat), intent(inout) :: met
  real, intent(in) :: prss
  real, intent(in) :: leaf_aging_factor
  real, intent(in) :: green_leaf_factor
  type(solution), intent(in) :: sol
  integer, intent(in) :: ilimit
  type(farqdata), intent(in) :: gsdata
  type(glim), intent(inout) :: apar
  real, intent(in) :: Vm0
  real, intent(in) :: Vm_low_temp
  real, intent(in) :: Vm_high_temp
  real, intent(in) :: vmbar


  real, external :: co2cp
  real, external :: arrhenius
  real :: dprss
  real, external :: residual_c3
  real, external :: residual_c4
  real :: vmbar_temp

  ! Save old meteorological information
  old_st_data%T_L = met%tl
  old_st_data%e_a = met%ea
  old_st_data%par = met%par
  old_st_data%rb_factor = met%gbc
  old_st_data%prss = prss
  old_st_data%phenology_factor = leaf_aging_factor / green_leaf_factor
  old_st_data%gsw_open = sol%gsw(2,1)
  old_st_data%ilimit = ilimit
  
  if(ilimit == -1)then

     ! In this case, no open-stomata solution was found to exist.

     old_st_data%gsw_residual = 0.0
     old_st_data%t_l_residual = 0.0
     old_st_data%e_a_residual = 0.0
     old_st_data%par_residual = 0.0
     old_st_data%rb_residual = 0.0
     old_st_data%prss_residual = 0.0
     old_st_data%leaf_residual = 0.0

  else

     if(photosyn_pathway == 3)then

        ! Set parameters
        call setapar_c3(gsdata,met,apar,ilimit)

        ! stomatal conductance derivative
        old_st_data%gsw_residual = residual_c3(gsdata,met,apar,  &
             sol%gsw(2,1)*1.01) / (0.01*sol%gsw(2,1))
        
        ! Temperature derivative
        met%tl = met%tl + 0.1
        met%el = epi * rslif(prss,met%tl + t00)
        met%compp = co2cp(met%tl)
        apar%vm = Vm0 * arrhenius(met%tl,1.0,3000.0)  &
             /(1.0+exp(0.4*(Vm_low_temp-met%tl)))  &
             /(1.0+exp(0.4*(met%tl-Vm_high_temp))) 
        if(leaf_aging_factor > 0.01)then
           apar%vm = apar%vm * leaf_aging_factor   &
                / green_leaf_factor
        endif
        apar%nu = -apar%vm * gsdata%gamma
        if (vmbar > 0.0) then
           vmbar_temp = vmbar * arrhenius(met%tl, 1.0, 3000.0) / ( &
             (1.0 + exp(0.4*(Vm_low_temp - met%tl))) * &
             (1.0 + exp(0.4*(met%tl - Vm_high_temp ))) )
           apar%nu = -vmbar_temp * gsdata%gamma
        endif  
        apar%k1 = arrhenius(met%tl,1.5e-4,6000.0)
        apar%k2 = arrhenius(met%tl,0.836,-1400.0)
        call setapar_c3(gsdata,met,apar,ilimit)
        old_st_data%T_L_residual = residual_c3(gsdata,met,apar,  &
             sol%gsw(2,1)) / (0.1 * old_st_data%gsw_residual)

        ! Reset parameters
        met%tl = met%tl - 0.1
        met%el = epi * rslif(prss,met%tl+t00)
        met%compp = co2cp(met%tl)
        apar%vm = Vm0 * arrhenius(met%tl,1.0,3000.0)  &
             /(1.0+exp(0.4*(Vm_low_temp-met%tl)))  &
             /(1.0+exp(0.4*(met%tl-Vm_high_temp))) 
        if(leaf_aging_factor > 0.01)then
           apar%vm = apar%vm * leaf_aging_factor   &
                / green_leaf_factor
        endif
        apar%nu = -apar%vm * gsdata%gamma
        if (vmbar > 0.0) then
           vmbar_temp = vmbar * arrhenius(met%tl, 1.0, 3000.0) / ( &
             (1.0 + exp(0.4*(Vm_low_temp - met%tl))) * &
             (1.0 + exp(0.4*(met%tl - Vm_high_temp ))) )
           apar%nu = -vmbar_temp * gsdata%gamma
        endif  
        apar%k1 = arrhenius(met%tl,1.5e-4,6000.0)
        apar%k2 = arrhenius(met%tl,0.836,-1400.0)
        
        ! humidity derivative
        met%ea = met%ea * 0.99
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0
        call setapar_c3(gsdata,met,apar,ilimit)
        old_st_data%e_a_residual = residual_c3(gsdata,met,apar,sol%gsw(2,1)) &
             / (met%ea*(1.0-1.0/0.99)*old_st_data%gsw_residual)
        met%ea = met%ea / 0.99
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0

        ! PAR derivative
        met%par = met%par * 1.01
        call setapar_c3(gsdata,met,apar,ilimit)
        old_st_data%par_residual = residual_c3(gsdata,met,apar,sol%gsw(2,1)) &
             / (met%par*(1.0-1.0/1.01)*old_st_data%gsw_residual)
        met%par = met%par / 1.01

        ! aerodynamics resistance derivative
        met%gbc = met%gbc * 1.01
        call setapar_c3(gsdata,met,apar,ilimit)
        old_st_data%rb_residual = residual_c3(gsdata,met,apar,sol%gsw(2,1)) &
             / (met%gbc*(1.0-1.0/1.01)*old_st_data%gsw_residual)
        met%gbc = met%gbc / 1.01

        ! pressure derivative
        dprss = prss * 1.005
        met%el = epi * rslif(dprss,met%tl+t00)
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0
        call setapar_c3(gsdata,met,apar,ilimit)
        old_st_data%prss_residual = residual_c3(gsdata,met,apar,sol%gsw(2,1)) &
             / (dprss*(1.0-1.0/1.005)*old_st_data%gsw_residual)
        met%el = epi * rslif(prss,met%tl+t00)
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0

     else

        ! Now do the same for C4 plants
        
        call setapar_c4(gsdata,met,apar,ilimit)
        old_st_data%gsw_residual = residual_c4(gsdata,met,apar,  &
             sol%gsw(2,1)*1.01) / (0.01*sol%gsw(2,1))
        
        met%tl = met%tl + 0.1
        met%el = epi * rslif(prss,met%tl+t00)
        met%compp = co2cp(met%tl)
        apar%vm = Vm0 * arrhenius(met%tl,1.0,3000.0)  &
             /(1.0+exp(0.4*(Vm_low_temp-met%tl)))/(1.0+exp(0.4*(met%tl-Vm_high_temp))) 
        call setapar_c4(gsdata,met,apar,ilimit)
        old_st_data%T_L_residual =   &
             residual_c4(gsdata,met,apar,sol%gsw(2,1)) &
             / (0.1 * old_st_data%gsw_residual)
        met%tl = met%tl - 0.1
        met%el = epi * rslif(prss,met%tl+t00)
        met%compp = co2cp(met%tl)
        apar%vm = Vm0 * arrhenius(met%tl,1.0,3000.0)  &
             /(1.0+exp(0.4*(Vm_low_temp-met%tl)))/(1.0+exp(0.4*(met%tl-Vm_high_temp))) 
        
        met%ea = met%ea * 0.99
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0
        call setapar_c4(gsdata,met,apar,ilimit)
        old_st_data%e_a_residual =   &
             residual_c4(gsdata,met,apar,sol%gsw(2,1)) &
             / (met%ea*(1.0-1.0/0.99)*old_st_data%gsw_residual)
        met%ea = met%ea / 0.99
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0
        
        met%par = met%par * 1.01
        call setapar_c4(gsdata,met,apar,ilimit)
        old_st_data%par_residual =   &
             residual_c4(gsdata,met,apar,sol%gsw(2,1)) &
             / (met%par*(1.0-1.0/1.01)*old_st_data%gsw_residual)
        met%par = met%par / 1.01
        
        met%gbc = met%gbc * 1.01
        call setapar_c4(gsdata,met,apar,ilimit)
        old_st_data%rb_residual =   &
             residual_c4(gsdata,met,apar,sol%gsw(2,1)) &
             / (met%gbc*(1.0-1.0/1.01)*old_st_data%gsw_residual)
        met%gbc = met%gbc / 1.01
        
        dprss = prss * 1.005
        met%el = epi * rslif(dprss,met%tl+t00)
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0
        call setapar_c4(gsdata,met,apar,ilimit)
        old_st_data%prss_residual = residual_c4(gsdata,met,apar,sol%gsw(2,1)) &
             / (dprss*(1.0-1.0/1.005)*old_st_data%gsw_residual)
        met%el = epi * rslif(prss,met%tl+t00)
        met%eta = 1.0 + (met%el-met%ea)/gsdata%d0
        
     endif
  endif

  return
end subroutine store_exact_lphys_solution
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!      This subroutine will make the appropriate conversions for the output.               !
!------------------------------------------------------------------------------------------!
subroutine fill_lphys_sol_exact(A_open, rsw_open, A_cl, rsw_cl, veg_co2_open,veg_co2_cl    &
                               ,sol, adens)

   use consts_coms , only : mmdry1000 ! ! structure
   use c34constants, only : solution  ! ! structure
   implicit none

   !----- Arguments. ----------------------------------------------------------------------!
   real          , intent(out) :: A_open
   real          , intent(out) :: A_cl
   real          , intent(out) :: rsw_open
   real          , intent(out) :: rsw_cl
   real          , intent(out) :: veg_co2_open
   real          , intent(out) :: veg_co2_cl
   type(solution), intent(in)  :: sol
   real          , intent(in)  :: adens

   !----- Copy the open stomata case. -----------------------------------------------------!
   A_open       = sol%a(2,1)
   rsw_open     = 1.0e9 * adens / (mmdry1000 * sol%gsw(2,1))
   veg_co2_open = sol%ci(2,1) * 1.e6

   !----- Copy the open stomata case. -----------------------------------------------------!
   A_cl         = sol%a(1,1)
   rsw_cl       = 1.0e9 * adens / (mmdry1000 * sol%gsw(1,1))
   veg_co2_cl   = sol%ci(1,1) * 1.e6

   return
end subroutine fill_lphys_sol_exact
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine fill_lphys_sol_approx(gsdata, met, apar, old_st_data, sol,   &
     A_cl, rsw_cl, veg_co2_open, veg_co2_cl, adens, rsw_open, A_open, photosyn_pathway &
      , prss)

  use c34constants
  use consts_coms, only : mmdry1000

  implicit none

  

  type(farqdata), intent(in) :: gsdata
  type(metdat), intent(in) :: met
  type(glim), intent(inout) :: apar
  type(stoma_data), intent(in) :: old_st_data
  type(solution), intent(inout) :: sol
  real, intent(out) :: A_cl
  real, intent(out) :: A_open
  real, intent(out) :: rsw_cl 
  real, intent(out) :: rsw_open
  real, intent(out) :: veg_co2_open
  real, intent(out) :: veg_co2_cl
  real, intent(in) :: adens
  integer, intent(in) :: photosyn_pathway
  real, intent(in) :: prss

  logical :: success
  real :: gsw_update
  real :: ci_approx
  real, external :: aflux_c4
  real, external :: aflux_c3
  real, external :: quad4ci

  if(photosyn_pathway == 3)then
     call setapar_c3(gsdata,met,apar,max(1,old_st_data%ilimit))
     call solve_closed_case_c3(gsdata,met,apar,sol,1)
  else
     call setapar_c4(gsdata,met,apar,max(1,old_st_data%ilimit))
     call solve_closed_case_c4(gsdata,met,apar,sol,1)
  endif

  A_cl = sol%a(1,1)
  rsw_cl = 1.0e9 * adens / (mmdry1000 * sol%gsw(1,1))
!  rsw_cl = (2.9e-8 * adens) / sol%gsw(1,1)
  if(old_st_data%ilimit /= -1)then
     gsw_update = old_st_data%gsw_open - &
          old_st_data%t_l_residual * (met%tl - old_st_data%t_l) - &
          old_st_data%e_a_residual * (met%ea - old_st_data%e_a) - &
          old_st_data%par_residual * (met%par - old_st_data%par) - &
          old_st_data%rb_residual * (met%gbc - old_st_data%rb_factor) - &
          old_st_data%prss_residual * (prss - old_st_data%prss)
     
     if(photosyn_pathway == 3)then
        ci_approx = quad4ci(gsdata,met,apar,gsw_update,success)
        if(success)then
           A_open = aflux_c3(apar,gsw_update,ci_approx)
           rsw_open = 1.0e9 * adens / (mmdry1000 * gsw_update)
!           rsw_open = (2.9e-8 * adens) / gsw_update
        else
           A_open = A_cl
           rsw_open = rsw_cl
        endif
     else
        A_open = aflux_c4(apar,met,gsw_update)
        rsw_open = 1.0e9 * adens / (mmdry1000 * gsw_update)
!        rsw_open = (2.9e-8 * adens) / gsw_update
     endif
  else
     A_open   = A_cl
     rsw_open = rsw_cl
  end if
  if (old_st_data%ilimit >= 1) then
     veg_co2_open  = sol%ci(2,old_st_data%ilimit) * 1.e6
     veg_co2_cl    = sol%ci(1,old_st_data%ilimit) * 1.e6
  else
     veg_co2_open  = met%ca * 1.e6
     veg_co2_cl    = met%ca * 1.e6 
  end if
  return
end subroutine fill_lphys_sol_approx
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine gpp_solver2(apar,gsdata,met,ci,gsw,errnorm,n,converged)
   use c34constants   , only : glim          & ! structure
                             , farqdata      & ! structure
                             , metdat        ! ! structure
   use physiology_coms, only : c34smin_ci    & ! intent(out)
                             , c34smax_ci    & ! intent(out)
                             , c34smin_gsw   & ! intent(out)
                             , c34smax_gsw   & ! intent(out)
                             , nudgescal     & ! intent(out)
                             , alfls         & ! intent(out)
                             , maxmdne       & ! intent(out)
                             , normstmax     & ! intent(out)
                             , hugenum       & ! intent(out)
                             , xdim          ! ! intent(out)
   use therm_lib      , only : toler         ! ! intent(in)

   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   type(glim)    , intent(in)               :: apar
   type(farqdata), intent(in)               :: gsdata
   type(metdat)  , intent(in)               :: met
   real(kind=4)  , intent(inout)            :: ci
   real(kind=4)  , intent(inout)            :: gsw
   real(kind=4)  , intent(out)              :: errnorm     ! Norm of the norm. error.
   integer       , intent(out)              :: n           ! Iteration counter
   logical       , intent(out)              :: converged   ! The method converged.
   !----- Local variables. ----------------------------------------------------------------!
   integer                                  :: i           ! Best alpha
   logical                                  :: singular    ! Matrix is singular
   logical                                  :: dxconv      ! Check for spurious conv. 
   real(kind=4), dimension(xdim,xdim)       :: jacob       ! Array with the Jacobian
   real(kind=4), dimension(xdim,xdim)       :: jacobt      ! Transpose of the Jacobian
   real(kind=4), dimension(xdim)            :: x           ! Current normalised guess.
   real(kind=4), dimension(xdim)            :: xtry        ! Potential new guess
   real(kind=4), dimension(xdim)            :: xsmin       ! Lower bounds
   real(kind=4), dimension(xdim)            :: xsmax       ! Higher bounds
   real(kind=4), dimension(xdim)            :: s           ! Characteristic scales
   real(kind=4), dimension(xdim)            :: xnudge      ! Nudging perturbation in x
   real(kind=4), dimension(xdim)            :: dx          ! Vector with the increment
   real(kind=4), dimension(xdim)            :: dxnorm      ! Standardised increment
   real(kind=4), dimension(xdim)            :: error       ! Error vector (auxiliary)
   real(kind=4), dimension(xdim)            :: gradfn2     ! Gradient of fn2.
   real(kind=4), dimension(xdim)            :: fun         ! Function eval of curr. guess
   real(kind=4), dimension(xdim)            :: funtry      ! Function eval of new guess
   real(kind=4)                             :: fn2         ! 1/2 F dot F
   real(kind=4)                             :: fn2try      ! New guess 1/2 F dot F
   real(kind=4)                             :: fn2pbt      ! Previous back track
   real(kind=4)                             :: stepmax     ! Maximum step to be taken.
   real(kind=4)                             :: stepsize    ! Size of this new step.
   real(kind=4)                             :: slope       ! Slope of the descent
   real(kind=4)                             :: lambda      ! Lambda scale
   real(kind=4)                             :: lambdapbt   ! Lambda of the back track
   real(kind=4)                             :: lambdatry   ! Attempt for next lambda
   real(kind=4)                             :: lambdamin   ! Minimum lambda
   real(kind=4)                             :: rhstry      ! Auxiliary variable
   real(kind=4)                             :: rhspbt      ! Auxiliary variable
   real(kind=4)                             :: abask       ! Auxiliary variable
   real(kind=4)                             :: bbask       ! Auxiliary variable
   real(kind=4)                             :: discr       ! Auxiliary variable
   !----- Locally saved variables. --------------------------------------------------------!
   logical                     , save       :: firsttime  = .true.
   !---------------------------------------------------------------------------------------!




   !------ Initialise the random number generator. ----------------------------------------!
   if (firsttime) then
      call random_seed()
      firsttime = .false.
   end if
   !---------------------------------------------------------------------------------------!



   !------ Initialise the convergence flag. -----------------------------------------------!
   converged = .false.
   singular  = .false.
   n         = 0
   errnorm   = huge(1.)
   !---------------------------------------------------------------------------------------!


   !------ Initialise the edges and scale. ------------------------------------------------!
   xsmin = (/ c34smin_ci, c34smin_gsw /)  ! Minimum values that will be accepted.
   xsmax = (/ c34smax_ci, c34smax_gsw /)  ! Maximum values that will be accepted.
   s     = (/ ci        , gsw         /)  ! s1 and s2  -> first guess of Ci and gsw
   !---------------------------------------------------------------------------------------!



   !------ Initialise the "x" vector with the first guess. --------------------------------!
   xtry  = (/  1., 1. /)
   where (xtry(:)*s(:) < xsmin(:)) 
      xtry(:) = xsmin(:) / s(:)
   end where
   where (xtry(:)*s(:) > xsmax(:))
      xtry(:) = xsmax(:) / s(:)
   end where
   !---------------------------------------------------------------------------------------!



   !------ Initialise the function evaluation. --------------------------------------------!
   call gppsolver2_fun(xtry,s,xsmin,xsmax, apar, met, gsdata,funtry)
   fn2try = 0.5 * sum(funtry(:)*funtry(:))
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   !      Unlikely, but if we are really lucky and hit the jackpot with the first guess,   !
   ! we quit, that is indeed what we were looking for, and if we continue the iteration    !
   ! may send the guess away...                                                            !
   !---------------------------------------------------------------------------------------!
   if (all(funtry == 0.)) then
      converged = .true.
      errnorm   = 0.0
      ci        = xtry(1)*s(1)
      gsw       = xtry(2)*s(2)
      return
   end if
   !---------------------------------------------------------------------------------------!


      
   !---------------------------------------------------------------------------------------!
   !     Define the maximum allowed step.  The step is normalised to make our comparisons  !
   ! more independent on the size of each component.                                       !
   !---------------------------------------------------------------------------------------!
   stepmax = normstmax * max(sqrt(sum(xtry(:)*xtry(:))),real(xdim))
   !---------------------------------------------------------------------------------------!



   !-----Big loop for Newton's method. ----------------------------------------------------!
   newtonloop: do n=1,maxmdne
      !----- Update the old guess. --------------------------------------------------------!
      x      = xtry(:)
      fun    = funtry(:)
      fn2    = fn2try

      !----- Compute the Jacobian. --------------------------------------------------------!
      call gppsolver2_jacob(x,s,xsmin,xsmax,apar,met,gsdata,jacob)
      !----- Comput the gradient of the fn2. ----------------------------------------------!
      gradfn2 = matmul(jacob,fun)

      !----- Solve the linear system. -----------------------------------------------------!
      funtry = -fun
      call lisys_solver(xdim,jacob,funtry,dx,singular)
      
      !------------------------------------------------------------------------------------! 
      !    Check whether we have a solution or not, based on the Jacobian condition        !
      ! number.                                                                            !
      !------------------------------------------------------------------------------------! 
      if (singular) then
         !---------------------------------------------------------------------------------!
         !     In case it is indeed a singularity, the only remedy is to start over but    !
         ! applying some random noise to the current guess, and hopefully this will make   !
         ! the method to approach the solution through a more reasonable path.             !
         !---------------------------------------------------------------------------------!
         call random_number(xnudge)
         xnudge(:) = (2*xnudge(:) - 1.) * nudgescal
         xtry(:)   = xtry(:) * (1. + xnudge(:))
         where (xtry(:)*s(:) < xsmin(:))
            xtry(:) = xsmin(:)/s(:)
         end where
         where (xtry(:)*s(:) > xsmax(:))
            xtry(:) = xsmax(:)/s(:)
         end where
   
         call gppsolver2_fun(xtry,s,xsmin,xsmax, apar, met, gsdata,funtry)
         fn2try = 0.5 * sum(funtry(:)*funtry(:))

         !---------------------------------------------------------------------------------!
         !      Unlikely, but if we are really lucky and hit the jackpot with the first    !
         ! guess, we quit, that is indeed what we were looking for, and if we continue the !
         ! iteration may send the guess away...                                            !
         !---------------------------------------------------------------------------------!
         if (all(funtry == 0.)) then
            converged = .true.
            errnorm   = 0.
            ci        = xtry(1)*s(1)
            gsw       = xtry(2)*s(2)
            return
         end if
         !---------------------------------------------------------------------------------!


         !---------------------------------------------------------------------------------!
         !     Define the maximum allowed step.  The step is normalised to make our        !
         ! comparisons more independent on the size of each component.                     !
         !---------------------------------------------------------------------------------!
         stepmax = normstmax * max(sqrt( sum(xtry(:)*xtry(:))), real(xdim))
         !---------------------------------------------------------------------------------!
         cycle newtonloop
      end if
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     Now we decide whether this step is safe or not to be taken.  First thing,      !
      ! we check whether the step is too big, and in case it is, we shorten the size of    !
      ! the step.                                                                          !
      !------------------------------------------------------------------------------------!
      stepsize = sqrt(sum(dx(:)*dx(:)))
      if (stepsize > stepmax) dx(:) = dx(:) * stepmax / stepsize
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     Check the slope of the step we are about to take.  Hopefully this is going to  !
      ! be always negative.  Also, we check whether the step we are about to take will     !
      ! keep guesses in the right place.  In case it is not, we may need to start over.    !
      !------------------------------------------------------------------------------------!
      slope   = sum(gradfn2(:)*dx(:))
      xtry(:) = x(:) + dx(:)
      if (slope >= 0. .or. any(xtry(:)*s(:) < 0.90*xsmin(:))  .or.                         &
                           any(xtry(:)*s(:) > 1.10*xsmax(:)) ) then
         call random_number(xnudge)
         xnudge(:) = (2*xnudge(:) - 1.) * nudgescal
         xtry(:)   = xtry(:) * (1. + xnudge(:))
         where (xtry(:)*s(:) < xsmin(:))
            xtry(:) = xsmin(:) / s(:)
         end where
         where (xtry(:)*s(:) > xsmax(:))
            xtry(:) = xsmax(:) / s(:)
         end where
   
         call gppsolver2_fun(xtry,s,xsmin,xsmax, apar, met, gsdata, funtry)
         fn2try = 0.5 * sum(funtry(:)*funtry(:))

         !---------------------------------------------------------------------------------!
         !      Unlikely, but if we are really lucky and hit the jackpot with the first    !
         ! guess, we quit, that is indeed what we were looking for, and if we continue the !
         ! iteration may send the guess away...                                            !
         !---------------------------------------------------------------------------------!
         if (all(funtry == 0.)) then
            converged = .true.
            errnorm   = 0
            ci       = xtry(1)*s(1)
            gsw      = xtry(2)*s(2)
            return
         end if
         !---------------------------------------------------------------------------------!


         !---------------------------------------------------------------------------------! 
         !     Define the maximum allowed step.  The step is normalised to make our        !
         ! comparisons more independent on the size of each component.                     !
         !---------------------------------------------------------------------------------! 
         stepmax = normstmax * max(sqrt( sum(xtry(:)*xtry(:))),real(xdim))
         !---------------------------------------------------------------------------------! 

         cycle newtonloop
      end if
      !------------------------------------------------------------------------------------!




      !------------------------------------------------------------------------------------!
      !     Now we compute the minimum lambda.  First we obtain the scale for it.          !
      !------------------------------------------------------------------------------------!
      where (abs(x(:)) < 1.)
         dxnorm(:) = abs(dx(:))
      elsewhere
         dxnorm(:) = abs(dx(:))/abs(x(:))
      end where
      lambdamin = toler/maxval(dxnorm)
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     Initialise lambda.  It's good to be optimistic, so we start with lambda=1,     !
      ! which corresponds to the "normal" Newton's method.                                 !
      !------------------------------------------------------------------------------------!
      lambda = 1.

      !------------------------------------------------------------------------------------!
      !     This loop is going to do the line search, seeking a step that will be the      !
      ! fastest possible, but playing it safe, and taking a shorter step if the full step  !
      ! is too dangerous.                                                                  !
      !------------------------------------------------------------------------------------!
      linesearch: do
         !----- Update the guess. ---------------------------------------------------------!
         xtry = x(:) + lambda * dx(:)
         
         !----- Find the updated function and the fn2 term. -------------------------------!
         call gppsolver2_fun(xtry,s,xsmin,xsmax, apar, met, gsdata,funtry)
         fn2try = 0.5 * sum(funtry(:)*funtry(:))
         
         if (lambda < lambdamin) then
            !------------------------------------------------------------------------------!
            !     Convergence on delta x, the check outside this loop should check whether !
            ! this has achieve convergence or if this is a spurious convergence.           !
            !------------------------------------------------------------------------------!
            xtry(:) = x(:)
            dxconv = .true.
            exit linesearch
         elseif (fn2try <= fn2 + alfls * lambda * slope) then
            !----- The function is going to the right direction, quit line search. --------!
            dxconv = .false.
            exit linesearch
         elseif (lambda == 1.) then
            !----- First call of the back track, we use a simple expression. --------------!
            dxconv    = .false.
            lambdatry = - slope / (2. * (fn2try - fn2 -slope))
         else
            !------------------------------------------------------------------------------!
            !     Back track, the calls other than the first one.  In this case we use     !
            ! the information from the previous attempt, and we use a cubic polynomial     !
            ! to minimise the value of the gradient as a function of lambda.  Following    !
            ! Press et al. (1992), section 9.7, we approximate the function to a cubic     !
            ! polynomial in lambda, and we use both the most recent value and the value    !
            ! right before that (lambda, and lambdapbt, respectively).                     !
            !------------------------------------------------------------------------------!
            dxconv = .false.

            rhstry   = fn2try - fn2 - lambda    * slope
            rhspbt   = fn2pbt - fn2 - lambdapbt * slope
            
            abask  = ( rhstry/(lambda*lambda) - rhspbt/(lambdapbt*lambdapbt) )             &
                     / (lambda - lambdapbt)
            bbask  = ( lambda    * rhspbt / (lambdapbt * lambdapbt)                        &
                     - lambdapbt * rhstry / (lambda    * lambda   ) )                      &
                   / ( lambda - lambdapbt )

            if (abask == 0.) then 
               lambdatry = - slope / (2. * bbask)
            else
               discr = bbask * bbask - 3. * abask * slope
               if (discr < 0.) then
                  lambdatry = 0.5 * lambda
               elseif (bbask <= 0.) then 
                  lambdatry = ( - bbask + sqrt(discr)) / (3. * abask)
               else
                  lambdatry = - slope / (bbask + sqrt(discr))
               end if
            end if
            !------------------------------------------------------------------------------!

            
            !------------------------------------------------------------------------------!
            !     Here we impose that the new lambda should not exceed half the previous   !
            ! lambda.                                                                      !
            !------------------------------------------------------------------------------!
            lambdatry = min(0.5 * lambda,lambdatry)
            !------------------------------------------------------------------------------!
         end if
         
         !---------------------------------------------------------------------------------!
         !     We also want to make the new lambda at least 10% of the previous, even when !
         ! this is the first call of the back track.                                       !
         !---------------------------------------------------------------------------------!
         lambdatry = max(lambdatry, 0.1 * lambda)

         !------ Update the older guess. --------------------------------------------------!
         lambdapbt = lambda
         fn2pbt    = fn2try
         lambda    = lambdatry
      end do linesearch
      !------------------------------------------------------------------------------------!




      !------------------------------------------------------------------------------------!
      !     Check the results, and assume success if we hit the true solution, or if we    !
      ! are sufficently close to the true solution.                                        !
      !------------------------------------------------------------------------------------!
      error = abs(funtry(:))
      errnorm  = maxval(error)

      !------------------------------------------------------------------------------------!
      !      If Newton's method succeeded, we update the output and quit the sub-routine   !
      ! now.                                                                               !
      !------------------------------------------------------------------------------------!
      if (dxconv .and. errnorm < toler) then
         !----- The gradient is small but we are indeed close to zero. --------------------!
         converged = .true.
         ci        = xtry(1)*s(1)
         gsw       = xtry(2)*s(2)
         return
      elseif (dxconv) then
         !---------------------------------------------------------------------------------!
         !     Here we have hit a spurious zero gradient (a bad thing), because the        !
         ! function evaluation is not within the tolerance.  The only remedy is to start   !
         ! over but applying some random noise to the current guess, and hopefully this    !
         ! will make the method to approach the solution through a better path.            !
         !---------------------------------------------------------------------------------!
         call random_number(xnudge)
         xnudge(:) = (2*xnudge(:) - 1.) * nudgescal
         xtry(:)   = xtry(:) * (1. + xnudge(:))
         where (xtry(:)*s(:) < xsmin(:))
            xtry(:) = xsmin(:) / s(:)
         end where
         where (xtry(:)*s(:) > xsmax(:))
            xtry(:) = xsmax(:) / s(:)
         end where

         call gppsolver2_fun(xtry,s,xsmin,xsmax, apar, met, gsdata, funtry)
         fn2try = 0.5 * sum(funtry(:)*funtry(:))

         !---------------------------------------------------------------------------------!
         !      Unlikely, but if we are really lucky and hit the jackpot with the first    !
         ! guess, we quit, that is indeed what we were looking for, and if we continue the !
         ! iteration may send the guess away...                                            !
         !---------------------------------------------------------------------------------!
         if (all(funtry == 0.)) then
            converged = .true.
            errnorm   = 0.
            ci        = xtry(1)*s(1)
            gsw       = xtry(2)*s(2)
            return
         end if
         !---------------------------------------------------------------------------------!


         !---------------------------------------------------------------------------------!
         !     Define the maximum allowed step.  The step is normalised to make our        !
         ! comparisons more independent on the size of each component.                     !
         !---------------------------------------------------------------------------------!
         stepmax = normstmax * max(sqrt(sum(xtry(:)*xtry(:))),real(xdim))
         !---------------------------------------------------------------------------------!

         cycle newtonloop
      else
         !----- Check for convergence on delta-x. -----------------------------------------!
         where (x(:) < 1.)
            error(:) = abs(xtry(:)-x(:))
         elsewhere
            error(:) = abs(xtry(:)-x(:)) / abs(x(:))
         end where
         errnorm  = max(errnorm,maxval(error))
         !---------------------------------------------------------------------------------!
         !      If Newton's method succeeded, we update the output and quit the sub-       !
         ! routine now.                                                                    !
         !---------------------------------------------------------------------------------!
         if (errnorm < toler) then
            converged = .true.
            ci        = xtry(1)*s(1)
            gsw       = xtry(2)*s(2)
            return
         end if
         !---------------------------------------------------------------------------------!
      end if
   end do newtonloop
   !---------------------------------------------------------------------------------------!
   !---------------------------------------------------------------------------------------!
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   !     If we have reached this point, this means that both Newton's with linear search-  !
   ! ing method failed to converge.  We will acknowledge that  but we fill the output      !
   ! variables with what we have.                                                          !
   !---------------------------------------------------------------------------------------!
   ci        = xtry(1)*s(1)
   gsw       = xtry(2)*s(2)
   converged = .false.
   !---------------------------------------------------------------------------------------!

   return
end subroutine gpp_solver2
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine gppsolver2_fun(x,s,xsmin,xsmax, apar, met, gsdata,fun)
   use c34constants   , only : glim          & ! structure
                             , farqdata      & ! structure
                             , metdat        ! ! structure
   use physiology_coms, only : hugenum       & ! intent(in)
                             , xdim          ! ! intent(in)

   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   real(kind=4), dimension(xdim), intent(in)  :: x        ! Normalised variable vector.
   real(kind=4), dimension(xdim), intent(in)  :: s        ! Characteristic scale
   real(kind=4), dimension(xdim), intent(in)  :: xsmin    ! Lowest acceptable bounds
   real(kind=4), dimension(xdim), intent(in)  :: xsmax    ! Highest acceptable bounds
   type(glim)                   , intent(in)  :: apar
   type(farqdata)               , intent(in)  :: gsdata
   type(metdat)                 , intent(in)  :: met
   real(kind=4), dimension(xdim), intent(out) :: fun      ! The vector with the functions
   !----- Local variables. ----------------------------------------------------------------!
   real(kind=4), dimension(xdim)              :: xs       ! Re-scaled variables.
   real(kind=4)                               :: a1       ! Auxiliary coefficient
   real(kind=4)                               :: a2       ! Auxiliary coefficient
   real(kind=4)                               :: b1       ! Auxiliary coefficient
   real(kind=4)                               :: b2       ! Auxiliary coefficient
   real(kind=4)                               :: c1i      ! Auxiliary coefficient
   real(kind=4)                               :: c2       ! Auxiliary coefficient
   real(kind=4)                               :: ao       ! Auxiliary coefficient
   real(kind=4)                               :: qq       ! Auxiliary coefficient
   real(kind=4)                               :: rr       ! Auxiliary coefficient
   !---------------------------------------------------------------------------------------!



   !----- Re-scale the variables. ---------------------------------------------------------!
   xs(:) = x(:) * s(:)
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   !     This is to avoid floating point exceptions.  If the guess goes off the reasonable !
   ! range, then we make the function evaluation poor.                                     !
   !---------------------------------------------------------------------------------------!
   if (any(xs < 0.90 * xsmin .or. xs > 1.10 * xsmax)) then
      fun(:) = hugenum
      return
   end if
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   !      Function 1, solving Ci polynomial.                                               !
   !---------------------------------------------------------------------------------------!
   b1 =  apar%tau - met%ca + (apar%rho + apar%nu) * (1.0/(1.4 * met%gbc)) 
   b2 = (apar%rho + apar%nu) / 1.6
  
   c1i = 1.                                                                                &
       / (-apar%tau * met%ca + (apar%sigma + apar%nu * apar%tau) * (1.0 / (1.4 * met%gbc)))
   c2  =  (apar%sigma + apar%nu * apar%tau) / 1.6

   fun(1) =  c1i * (xs(1)*xs(1) + b1 * xs(1)  + b2 * xs(1)/xs(2) + c2 /xs(2)) + 1.
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !      Function 2, solving gsw polynomial.                                              !
   !---------------------------------------------------------------------------------------!
   ao = (apar%rho * xs(1) + apar%sigma) / (xs(1) + apar.tau) + apar.nu
   qq = met%gbc * met%eta - gsdata%b
   rr = gsdata%b * met%eta * met%gbc

   a1 = met%ca - met%compp
   a2 = - 1. / (1.4 * met%gbc)

   b1 = qq * a1
   b2 = -1.0 * (qq/(1.4*met%gbc) + gsdata%m)

   c1i = 1./ (-rr * a1)
   c2  = rr / (1.4 * met%gbc) - gsdata%m * met%gbc
 
   fun(2) = c1i * ((a1 + a2*ao)*xs(2)*xs(2) + (b1 + b2*ao) * xs(2)  + c2 * ao) + 1.
   !---------------------------------------------------------------------------------------!

   return
end subroutine gppsolver2_fun
!==========================================================================================!
!==========================================================================================!





!==========================================================================================!
!==========================================================================================!
subroutine gppsolver2_jacob(x,s,xsmin,xsmax, apar, met, gsdata,jacob)
   use c34constants   , only : glim          & ! structure
                             , farqdata      & ! structure
                             , metdat        ! ! structure
   use physiology_coms, only : xdim          ! ! intent(in)
       

   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   real(kind=4), dimension(xdim)     , intent(in)  :: x      ! Normalised variable vector.
   real(kind=4), dimension(xdim)     , intent(in)  :: s      ! Characteristic scale
   real(kind=4), dimension(xdim)     , intent(in)  :: xsmin  ! Lowest acceptable bounds
   real(kind=4), dimension(xdim)     , intent(in)  :: xsmax  ! Highest acceptable bounds
   type(glim)                        , intent(in)  :: apar
   type(farqdata)                    , intent(in)  :: gsdata
   type(metdat)                      , intent(in)  :: met
   real(kind=4), dimension(xdim,xdim), intent(out) :: jacob  ! Jacobian matrix
   !----- Local variables. ----------------------------------------------------------------!
   real(kind=4), dimension(xdim)                   :: xs       ! Re-scaled variables.
   real(kind=4)                                    :: a1       ! Auxiliary coefficient
   real(kind=4)                                    :: a2       ! Auxiliary coefficient
   real(kind=4)                                    :: b1       ! Auxiliary coefficient
   real(kind=4)                                    :: b2       ! Auxiliary coefficient
   real(kind=4)                                    :: c1i      ! Auxiliary coefficient
   real(kind=4)                                    :: c2       ! Auxiliary coefficient
   real(kind=4)                                    :: ao       ! A_open
   real(kind=4)                                    :: daodt    ! derivative of A_open
   real(kind=4)                                    :: qq       ! Auxiliary coefficient
   real(kind=4)                                    :: rr       ! Auxiliary coefficient
   !---------------------------------------------------------------------------------------!



   !----- Re-scale the variables. ---------------------------------------------------------!
   xs(:) = x(:) * s(:)

   !----- This should never happen. -------------------------------------------------------!
   if (any(xs < 0.90 * xsmin .or. xs > 1.10 * xsmax)) then
      jacob(:,:) = 0.
      return
   end if

   !---------------------------------------------------------------------------------------!
   !      Derivatives of function 1, solving Ci polynomial.                                !
   !---------------------------------------------------------------------------------------!
   b1 =  apar%tau - met%ca + (apar%rho + apar%nu) * (1.0/(1.4 * met%gbc)) 
   b2 = (apar%rho + apar%nu) / 1.6
  
   c1i = 1.                                                                                &
       / (-apar%tau * met%ca + (apar%sigma + apar%nu * apar%tau) * (1.0 / (1.4 * met%gbc)))
   c2  =  (apar%sigma + apar%nu * apar%tau) / 1.6

   jacob(1,1) = c1i * (2*xs(1)*s(1) + b1 * s(1) + b2*s(1)/xs(2))
   jacob(1,2) = c1i * (-b2*xs(1)*s(2)/(xs(2)*xs(2)) - c2*s(2)/(xs(2)*xs(2)))
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !      Derivatives of function 2, solving gsw polynomial.                               !
   !---------------------------------------------------------------------------------------!
   ao    = (apar%rho * xs(1) + apar%sigma) / (xs(1) + apar.tau) + apar.nu
   dAodt = (s(1) * (apar%rho * (xs(1) + apar%tau) - apar%rho*xs(1) - apar%sigma))          &
         / ((xs(1) + apar%tau) * (xs(1) + apar%tau))
   qq    = met%gbc * met%eta - gsdata%b
   rr    = gsdata%b * met%eta * met%gbc

   a1 = met%ca - met%compp
   a2 = - 1. / (1.4 * met%gbc)

   b1 = qq * a1
   b2 = -1.0 * (qq/(1.4*met%gbc) + gsdata%m)

   c1i = 1./ (-rr * a1)
   c2  = rr / (1.4 * met%gbc) - gsdata%m * met%gbc

   jacob(2,1) = dAodt * c1i * (a2 * (xs(2)*xs(2)) + b2*xs(2) + c2) * s(1)
   jacob(2,2) = c1i * (2*(a1+a2*ao)*xs(2)*s(2)  + (b1+b2*ao)*s(2))
   !---------------------------------------------------------------------------------------!

   return
end subroutine gppsolver2_jacob
!==========================================================================================!
!==========================================================================================!
