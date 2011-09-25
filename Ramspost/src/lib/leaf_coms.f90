!====================================== Change Log ========================================!
! 5.0.0                                                                                    !
!                                                                                          !
!==========================================================================================!
!  Copyright (C)  1990, 1995, 1999, 2000, 2003 - All Rights Reserved                       !
!  Regional Atmospheric Modeling System - RAMS                                             !
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!    This module contains some variables used in LEAF-3.                                   !
!------------------------------------------------------------------------------------------!
module leaf_coms
   use rconstants, only: grav      & ! intent(in)
                       , vonk      & ! intent(in)
                       , twothirds ! ! intent(in)

   !----- Values that are read in rcio. ---------------------------------------------------!
   real :: ubmin          ! Minimum velocity                                     [     m/s]
   real :: ugbmin         ! Minimum leaf-level velocity                          [     m/s]
   real :: ustmin         ! Minimum ustar                                        [     m/s]
   real :: gamm           ! Gamma used by Businger et al. (1971) - momentum.
   real :: gamh           ! Gamma used by Businger et al. (1971) - heat.
   real :: tprandtl       ! Turbulent Prandtl number.
   real :: ribmax         ! Maximum bulk Richardson number
   real :: min_patch_area ! Minimum patch area to consider. 
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !      Constants for surface layer models.                                              !
   !---------------------------------------------------------------------------------------!
   real, parameter :: vh2vr    = 0.13          ! Vegetation roughness:vegetation hgt ratio
   real, parameter :: vh2dh    = 0.63          ! Displacement height:vegetation hgt ratio
   !----- Louis (1979) model. -------------------------------------------------------------!
   real, parameter :: bl79       = 5.0    ! b prime parameter
   real, parameter :: csm        = 7.5    ! C* for momentum (eqn. 20, not co2 char. scale)
   real, parameter :: csh        = 5.0    ! C* for heat (eqn.20, not co2 char. scale)
   real, parameter :: dl79       = 5.0    ! ???
   !----- Oncley and Dudhia (1995) model. -------------------------------------------------!
   real, parameter :: beta_s     = 5.0    ! Beta used by Businger et al. (1971)
   !----- Beljaars and Holtslag (1991) model. ---------------------------------------------!
   real, parameter :: abh91       = -1.00         ! -a from equation  (28) and (32)
   real, parameter :: bbh91       = -twothirds    ! -b from equation  (28) and (32)
   real, parameter :: cbh91       =  5.0          !  c from equations (28) and (32)
   real, parameter :: dbh91       =  0.35         !  d from equations (28) and (32)
   real, parameter :: ebh91       = -twothirds    ! the 2/3 factor in equation (32)
   real, parameter :: fbh91       =  1.50         ! exponent in equation (32)
   real, parameter :: cod         = cbh91/dbh91   ! c/d
   real, parameter :: bcod        = bbh91 * cod   ! b*c/d
   real, parameter :: fm1         = fbh91 - 1.0   ! f-1
   real, parameter :: ate         = abh91 * ebh91 ! a * e
   real, parameter :: atetf       = ate   * fbh91 ! a * e * f
   real, parameter :: z0moz0h     = 1.0           ! z0(M)/z0(h)
   real, parameter :: z0hoz0m     = 1. / z0moz0h  ! z0(M)/z0(h)
   !----- Modified CLM (2004) model.   These will be initialised later. -------------------!
   real   :: beta_vs     ! Beta for the very stable case (CLM eq. 5.30)
   real   :: chim        ! CLM coefficient for very unstable case (momentum)
   real   :: chih        ! CLM coefficient for very unstable case (heat)
   real   :: zetac_um    ! critical zeta below which it becomes very unstable (momentum)
   real   :: zetac_uh    ! critical zeta below which it becomes very unstable (heat)
   real   :: zetac_sm    ! critical zeta above which it becomes very stable   (momentum)
   real   :: zetac_sh    ! critical zeta above which it becomes very stable   (heat)
   real   :: zetac_umi   ! 1. / zetac_umi
   real   :: zetac_uhi   ! 1. / zetac_uhi
   real   :: zetac_smi   ! 1. / zetac_smi
   real   :: zetac_shi   ! 1. / zetac_shi
   real   :: zetac_umi16 ! 1/(-zetac_umi)^(1/6)
   real   :: zetac_uhi13 ! 1/(-zetac_umi)^(1/6)
   real   :: psimc_um    ! psim evaluation at zetac_um
   real   :: psihc_uh    ! psih evaluation at zetac_uh
   !---------------------------------------------------------------------------------------!

   contains
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     This sub-routine initialises several parameters for the surface layer model.      !
   !---------------------------------------------------------------------------------------!
   subroutine sfclyr_init_params(istar)
      use rconstants, only : onesixth ! ! intent(in)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      integer, intent(in) :: istar
      !----- External functions. ----------------------------------------------------------!
      real   , external   :: cbrt
      !------------------------------------------------------------------------------------!
      
      !----- Similar to CLM (2004), but with different phi_m for very unstable case. ------!
      zetac_um    = -1.5
      zetac_uh    = -0.5
      zetac_sm    =  1.0
      zetac_sh    =  zetac_sm
      !----- Define chim and chih so the functions are continuous. ------------------------!
      chim        = (-zetac_um) ** onesixth / sqrt(sqrt(1.0 - gamm * zetac_um))
      chih        = cbrt(-zetac_uh) / sqrt(1.0 - gamh * zetac_uh)
      beta_vs     = 1.0 - (1.0 - beta_s) * zetac_sm
      !----- Define derived values to speed up the code a little. -------------------------!
      zetac_umi   = 1.0 / zetac_um
      zetac_uhi   = 1.0 / zetac_uh
      zetac_smi   = 1.0 / zetac_sm
      zetac_shi   = 1.0 / zetac_sh
      zetac_umi16 = 1.0 / (- zetac_um) ** onesixth
      zetac_uhi13 = 1.0 / cbrt(-zetac_uh)

      !------------------------------------------------------------------------------------!
      !     Initialise these values with dummies, it will be updated after we define the   !
      ! functions.                                                                         !
      !------------------------------------------------------------------------------------!
      psimc_um  = 0.
      psimc_um  = psim(zetac_um,.false.,istar)
      psihc_uh  = 0.
      psihc_uh  = psih(zetac_uh,.false.,istar)
      !------------------------------------------------------------------------------------!

      return
   end subroutine sfclyr_init_params
   !=======================================================================================!
   !=======================================================================================!





   !=======================================================================================!
   !=======================================================================================!
   !    This function computes the stability  correction function for momentum.            !
   !---------------------------------------------------------------------------------------!
   real function psim(zeta,stable,istar)
      use rconstants, only : halfpi   & ! intent(in)
                           , onesixth ! ! intent(in)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      real   , intent(in) :: zeta   ! z/L, z is the height, and L the Obukhov length [ ---]
      logical, intent(in) :: stable ! Flag... This surface layer is stable           [ T|F]
      integer, intent(in) :: istar  ! Which surface layer closure I should use
      !----- Local variables. -------------------------------------------------------------!
      real                :: xx
      !----- External functions. ----------------------------------------------------------!
      real   , external   :: cbrt
      !------------------------------------------------------------------------------------!
      if (stable) then
         select case (istar)
         case (2) !----- Oncley and Dudhia (1995). ----------------------------------------!
            psim = - beta_s * zeta 
         case (3) !----- Beljaars and Holtslag (1991). ------------------------------------!
            psim = abh91 * zeta                                                            &
                 + bbh91 * (zeta - cod) * exp(max(-38.,-dbh91 * zeta))                     &
                 + bcod
         case (4) !----- CLM (2004) (including neglected terms). --------------------------!
            if (zeta > zetac_sm) then
               !----- Very stable case. ---------------------------------------------------!
               psim = (1.0 - beta_vs) * log(zeta * zetac_smi)                              &
                    + (1.0 - beta_s ) * zetac_sm - zeta
            else
               !----- Normal stable case. -------------------------------------------------!
               psim = - beta_s * zeta
            end if
         end select
      else
         select case (istar)
         case (2,3) !----- Oncley and Dudhia (1995) and Beljaars and Holtslag (1991). -----!
            xx   = sqrt(sqrt(1.0 - gamm * zeta))
            psim = log(0.125 * (1.0+xx) * (1.0+xx) * (1.0 + xx*xx)) - 2.0*atan(xx) + halfpi
         case (4)   !----- CLM (2004) (including neglected terms). ------------------------!
            if (zeta < zetac_um) then
               !----- Very unstable case. -------------------------------------------------!
               psim = log(zeta * zetac_umi)                                                &
                    + 6.0 * chim * ((- zeta) ** (-onesixth) - zetac_umi16)                 &
                    + psimc_um
            else
               !----- Normal unstable case. -----------------------------------------------!
               xx   = sqrt(sqrt(1.0 - gamm * zeta))
               psim = log(0.125 * (1.0+xx) * (1.0+xx) * (1.0 + xx*xx))                     &
                    - 2.0*atan(xx) + halfpi
            end if
         end select
      end if

      return
   end function psim
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !    This function computes the stability  correction function for heat (and vapour,    !
   ! and carbon dioxide too.)                                                              !
   !---------------------------------------------------------------------------------------!
   real function psih(zeta,stable,istar)
      use rconstants, only : halfpi   & ! intent(in)
                           , onesixth ! ! intent(in)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      real   , intent(in) :: zeta   ! z/L, z is the height, and L the Obukhov length [ ---]
      logical, intent(in) :: stable ! Flag... This surface layer is stable           [ T|F]
      integer, intent(in) :: istar  ! Which surface layer closure I should use
      !----- Local variables. -------------------------------------------------------------!
      real                :: yy
      !----- External functions. ----------------------------------------------------------!
      real   , external   :: cbrt
      !------------------------------------------------------------------------------------!
      if (stable) then
         select case (istar)
         case (2) !----- Oncley and Dudhia (1995). ----------------------------------------!
            psih = - beta_s * zeta 
         case (3) !----- Beljaars and Holtslag (1991). ------------------------------------!
            psih = 1.0 - (1.0 + ate * zeta)**fbh91                                         &
                 + bbh91 * (zeta - cod) * exp(max(-38.,-dbh91 * zeta)) + bcod
         case (4) !----- CLM (2004). ------------------------------------------------------!
            if (zeta > zetac_sh) then
               !----- Very stable case. ---------------------------------------------------!
               psih = (1.0 - beta_vs) * log(zeta * zetac_shi)                              &
                    + (1.0 - beta_s ) * zetac_sh - zeta
            else
               !----- Normal stable case. -------------------------------------------------!
               psih = - beta_s * zeta 
            end if
         end select
      else
         select case (istar)
         case (2,3) !----- Oncley and Dudhia (1995) and Beljaars and Holtslag (1991). -----!
            yy   = sqrt(1.0 - gamh * zeta)
            psih = log(0.25 * (1.0+yy) * (1.0+yy))
         case (4)   !----- CLM (2004) (including neglected terms). ------------------------!
            if (zeta < zetac_um) then
               !----- Very unstable case. -------------------------------------------------!
               psih = log(zeta * zetac_uhi)                                                &
                    + 3.0 * chih * (1./cbrt(-zeta) - zetac_uhi13)                          &
                    + psihc_uh
            else
               !----- Normal unstable case. -----------------------------------------------!
               yy   = sqrt(1.0 - gamh * zeta)
               psih = log(0.25 * (1.0+yy) * (1.0+yy))
            end if
         end select
      end if
      return
   end function psih
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !    This function computes the derivative of the stability correction function for     !
   ! momentum with respect to zeta.                                                        !
   !---------------------------------------------------------------------------------------!
   real function dpsimdzeta(zeta,stable,istar)
      use rconstants, only : halfpi   & ! intent(in)
                           , onesixth ! ! intent(in)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      real   , intent(in) :: zeta   ! z/L, z is the height, and L the Obukhov length [ ---]
      logical, intent(in) :: stable ! Flag... This surface layer is stable           [ T|F]
      integer, intent(in) :: istar  ! Which surface layer closure I should use
      !----- Local variables. -------------------------------------------------------------!
      real                :: xx
      !------------------------------------------------------------------------------------!

      if (stable) then
         select case (istar)
         case (2) !----- Oncley and Dudhia (1995). ----------------------------------------!
            dpsimdzeta = - beta_s 
         case (3) !----- Beljaars and Holtslag (1991). ------------------------------------!
            dpsimdzeta = abh91 + bbh91 * (1.0 - dbh91 * zeta + cbh91)                      &
                               * exp(max(-38.,-dbh91 * zeta))
         case (4) !----- CLM (2004). ------------------------------------------------------!
            if (zeta > zetac_sm) then
               !----- Very stable case. ---------------------------------------------------!
               dpsimdzeta = (1.0 - beta_vs) / zeta - 1.0
            else
               !----- Normal stable case. -------------------------------------------------!
               dpsimdzeta = - beta_s 
            end if
         end select
      else
         select case (istar)
         case (2,3) !----- Oncley and Dudhia (1995) and Beljaars and Holtslag (1991). -----!
            xx         = sqrt(sqrt(1.0 - gamm * zeta))
            dpsimdzeta = - gamm / (xx * (1.0+xx) * (1.0 + xx*xx)) 
         case (4)   !----- CLM (2004) (including neglected terms). ------------------------!
            if (zeta < zetac_um) then
               !----- Very unstable case. -------------------------------------------------!
               dpsimdzeta = (1.0 - chim * (-zeta)**onesixth) / zeta
            else
               !----- Normal unstable case. -----------------------------------------------!
               xx         = sqrt(sqrt(1.0 - gamm * zeta))
               dpsimdzeta = - gamm / (xx * (1.0+xx) * (1.0 + xx*xx))
            end if
         end select
      end if

      return
   end function dpsimdzeta
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !    This function computes the derivative of the stability correction function for     !
   ! heat/moisture/CO2 with respect to zeta.                                               !
   !---------------------------------------------------------------------------------------!
   real function dpsihdzeta(zeta,stable,istar)
      use rconstants, only : halfpi   & ! intent(in)
                           , onesixth ! ! intent(in)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      real   , intent(in) :: zeta   ! z/L, z is the height, and L the Obukhov length [ ---]
      logical, intent(in) :: stable ! Flag... This surface layer is stable           [ T|F]
      integer, intent(in) :: istar  ! Which surface layer closure I should use
      !----- Local variables. -------------------------------------------------------------!
      real                :: yy
      !----- External functions. ----------------------------------------------------------!
      real   , external   :: cbrt
      !------------------------------------------------------------------------------------!
      if (stable) then
         select case (istar)
         case (2) !----- Oncley and Dudhia (1995). ----------------------------------------!
            dpsihdzeta = - beta_s
         case (3) !----- Beljaars and Holtslag (1991). ------------------------------------!
            dpsihdzeta = - atetf * (1.0 + ate * zeta)**fm1                                 &
                         + bbh91 * (1.0 - dbh91 * zeta + cbh91)                            &
                         * exp(max(-38.,-dbh91 * zeta))
         case (4) !----- CLM (2004). ------------------------------------------------------!
            if (zeta > zetac_sh) then
               !----- Very stable case. ---------------------------------------------------!
               dpsihdzeta = (1.0 - beta_vs) / zeta - 1.0
            else
               !----- Normal stable case. -------------------------------------------------!
               dpsihdzeta = - beta_s
            end if
         end select
      else
         select case (istar)
         case (2,3) !----- Oncley and Dudhia (1995) and Beljaars and Holtslag (1991). -----!
            yy   = sqrt(1.0 - gamh * zeta)
            dpsihdzeta = -gamh / (yy * (1.0 + yy))
         case (4)   !----- CLM (2004) (including neglected terms). ------------------------!
            if (zeta < zetac_um) then
               !----- Very unstable case. -------------------------------------------------!
               dpsihdzeta = (1.0 + chih / cbrt(zeta)) / zeta
            else
               !----- Normal unstable case. -----------------------------------------------!
               yy   = sqrt(1.0 - gamh * zeta)
               dpsihdzeta = -gamh / (yy * (1.0 + yy))
            end if
         end select
      end if

      return
   end function dpsihdzeta
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     This function finds the value of zeta for a given Richardson number, reference    !
   ! height and the roughness scale.  This is solved by using the definition of Obukhov    !
   ! length scale as stated in Louis (1979) equation (10), modified to define z/L rather   !
   ! than L.  The solution is found  iteratively since it's not a simple function to       !
   ! invert.  It tries to use Newton's method, which should take care of most cases.  In   !
   ! the unlikely case in which Newton's method fails, switch back to modified Regula      !
   ! Falsi method (Illinois).                                                              !
   !---------------------------------------------------------------------------------------!
   real function zoobukhov(rib,zref,rough,zoz0m,lnzoz0m,zoz0h,lnzoz0h,stable,istar)
      use therm_lib, only : toler  & ! intent(in)
                          , maxfpo & ! intent(in)
                          , maxit  ! ! intent(in)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      real   , intent(in) :: rib       ! Bulk Richardson number                    [   ---]
      real   , intent(in) :: zref      ! Reference height                          [     m]
      real   , intent(in) :: rough     ! Roughness length scale                    [     m]
      real   , intent(in) :: zoz0m     ! zref/roughness(momentum)                  [   ---]
      real   , intent(in) :: lnzoz0m   ! ln[zref/roughness(momentum)]              [   ---]
      real   , intent(in) :: zoz0h     ! zref/roughness(heat)                      [   ---]
      real   , intent(in) :: lnzoz0h   ! ln[zref/roughness(heat)]                  [   ---]
      logical, intent(in) :: stable    ! Flag... This surface layer is stable      [   T|F]
      integer, intent(in) :: istar     ! Which surface layer closure I should use
      !----- Local variables. -------------------------------------------------------------!
      real                :: ribuse    ! Richardson number to use                  [   ---]
      real                :: fm        ! lnzoz0m - psim(zeta) + psim(zeta0m)       [   ---]
      real                :: fh        ! lnzoz0h - psih(zeta) + psih(zeta0h)       [   ---]
      real                :: dfmdzeta  ! d(fm)/d(zeta)                             [   ---]
      real                :: dfhdzeta  ! d(fh)/d(zeta)                             [   ---]
      real                :: z0moz     ! Roughness(momentum) / Reference height    [   ---]
      real                :: zeta0m    ! Roughness(momentum) / Obukhov length      [   ---]
      real                :: z0hoz     ! Roughness(heat) / Reference height        [   ---]
      real                :: zeta0h    ! Roughness(heat) / Obukhov length          [   ---]
      real                :: zetaa     ! Smallest guess (or previous guess)        [   ---]
      real                :: zetaz     ! Largest guess (or new guess in Newton's)  [   ---]
      real                :: deriv     ! Function Derivative                       [   ---]
      real                :: fun       ! Function for which we seek a root.        [   ---]
      real                :: funa      ! Smallest guess function.                  [   ---]
      real                :: funz      ! Largest guess function.                   [   ---]
      real                :: delta     ! Aux. var --- 2nd guess for bisection      [   ---]
      real                :: zetamin   ! Minimum zeta for stable case.             [   ---]
      real                :: zetamax   ! Maximum zeta for unstable case.           [   ---]
      real                :: zetasmall ! Zeta dangerously close to zero            [   ---]
      integer             :: itb       ! Iteration counters                        [   ---]
      integer             :: itn       ! Iteration counters                        [   ---]
      integer             :: itp       ! Iteration counters                        [   ---]
      logical             :: converged ! Flag... The method converged!             [   T|F]
      logical             :: zside     ! Flag... I'm on the z-side.                [   T|F]
      !------------------------------------------------------------------------------------!



      !----- Define some values that won't change during the iterative method. ------------!
      z0moz = 1. / zoz0m
      z0hoz = 1. / zoz0h
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     First thing, check whether this is a stable case and we are running methods 2  !
      ! or 4.  In these methods, there is a singularity that must be avoided.              !
      !------------------------------------------------------------------------------------!
      select case (istar)
      case (2,4)
         ribuse = min(rib, (1.0 - toler) * tprandtl / (beta_s * (1.0 - min(z0moz,z0hoz))))

         !---------------------------------------------------------------------------------!
         !    Stable case, using Oncley and Dudhia, we can solve it analytically.          !
         !---------------------------------------------------------------------------------!
         if (stable .and. istar == 2) then
            zoobukhov = ribuse * min(lnzoz0m,lnzoz0h)                                      &
                      / (tprandtl - beta_s * (1.0 - min(z0moz,z0hoz)) *ribuse)
            return
         end if
         !---------------------------------------------------------------------------------!
      case default
         ribuse = rib
      end select
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     If the bulk Richardson number is zero or almost zero, then we rather just      !
      ! assign z/L to be the one similar to Oncley and Dudhia (1995).  This saves time and !
      ! also avoids the risk of having zeta with the opposite sign.                        !
      !------------------------------------------------------------------------------------!
      zetasmall = ribuse * min(lnzoz0m,lnzoz0h)
      if (ribuse <= 0. .and. zetasmall > - z0moz0h * toler) then
         zoobukhov = zetasmall / tprandtl
         return
      elseif (ribuse > 0. .and. zetasmall < z0moz0h * toler) then
         zoobukhov = zetasmall / (tprandtl - beta_s * (1.0 - min(z0moz,z0hoz)) * ribuse)
         return
      else
         zetamin    =  toler
         zetamax    = -toler
      end if
      !------------------------------------------------------------------------------------!

      !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
      !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!
      !write(unit=89,fmt='(60a1)') ('-',itn=1,60)
      !write(unit=89,fmt='(5(a,1x,f11.4,1x),a,l1)')                                         &
      !   'Input values: Rib =',rib,'zref=',zref,'rough=',rough,'zoz0=',zoz0                &
      !           ,'lnzoz0=',lnzoz0,'stable=',stable
      !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
      !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!

      !------------------------------------------------------------------------------------!
      !     First guess, using Oncley and Dudhia (1995) approximation for unstable case.   !
      ! We won't use the stable case to avoid FPE or zeta with opposite sign when          !
      ! Ri > 0.20.                                                                         !
      !------------------------------------------------------------------------------------!
      zetaa = ribuse * lnzoz0m / tprandtl

      !----- Finding the function and its derivative. -------------------------------------!
      zeta0m   = zetaa * z0moz
      zeta0h   = zetaa * z0hoz
      fm       = lnzoz0m - psim(zetaa,stable,istar) + psim(zeta0m,stable,istar)
      fh       = lnzoz0h - psih(zetaa,stable,istar) + psih(zeta0h,stable,istar)
      dfmdzeta = z0moz * dpsimdzeta(zeta0m,stable,istar)-dpsimdzeta(zetaa,stable,istar)
      dfhdzeta = z0hoz * dpsihdzeta(zeta0h,stable,istar)-dpsihdzeta(zetaa,stable,istar)
      funa     = ribuse * fm * fm / (tprandtl * fh) - zetaa
      deriv    = ribuse * (2. * fm * dfmdzeta * fh - fm * fm * dfhdzeta)                   &
               / (tprandtl * fh * fh) - 1.

      !----- Copying just in case it fails at the first iteration. ------------------------!
      zetaz = zetaa
      fun   = funa

      !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
      !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!
      !write(unit=89,fmt='(a,1x,i5,1x,a,1x,l1,1x,7(1x,a,1x,es12.5))')                       &
      !   '1STGSS: itn=',0,'bisection=',.false.,'zetaz=',zetaz,'fun=',fun,'fm=',fm          &
      !  ,'fh=',fh,'dfmdzeta=',dfmdzeta,'dfhdzeta=',dfhdzeta,'deriv=',deriv
      !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
      !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!

      !----- Enter Newton's method loop. --------------------------------------------------!
      converged = .false.
      newloop: do itn = 1, maxfpo/6
         !---------------------------------------------------------------------------------!
         !     Newton's method converges fast when it's on the right track, but there are  !
         ! cases in which it becomes ill-behaved.  Two situations are known to cause       !
         ! trouble:                                                                        !
         ! 1.  If the derivative is tiny, the next guess can be too far from the actual    !
         !     answer;                                                                     !
         ! 2.  For this specific problem, when zeta is too close to zero.  In this case    !
         !     the derivative will tend to infinity at this point and Newton's method is   !
         !     not going to perform well and can potentially enter in a weird behaviour or !
         !     lead to the wrong answer.  In any case, so we rather go with bisection.     !
         !---------------------------------------------------------------------------------!
         if (abs(deriv) < toler) then
            exit newloop
         elseif(stable .and. (zetaz - fun/deriv < zetamin)) then
            exit newloop
         elseif((.not. stable) .and. (zetaz - fun/deriv > zetamax)) then
            exit newloop
         end if

         !----- Copying the previous guess ------------------------------------------------!
         zetaa = zetaz
         funa  = fun
         !----- New guess, its function and derivative evaluation -------------------------!
         zetaz = zetaa - fun/deriv

         zeta0m   = zetaz * z0moz
         zeta0h   = zetaz * z0hoz
         fm       = lnzoz0m - psim(zetaz,stable,istar) + psim(zeta0m,stable,istar)
         fh       = lnzoz0h - psih(zetaz,stable,istar) + psih(zeta0h,stable,istar)
         dfmdzeta = z0moz * dpsimdzeta(zeta0m,stable,istar)-dpsimdzeta(zetaz,stable,istar)
         dfhdzeta = z0hoz * dpsihdzeta(zeta0h,stable,istar)-dpsihdzeta(zetaz,stable,istar)
         fun      = ribuse * fm * fm / (tprandtl * fh) - zetaz
         deriv    = ribuse * (2. * fm * dfmdzeta * fh - fm * fm * dfhdzeta)                &
                  / (tprandtl * fh * fh) - 1.

         !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
         !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!
         !write(unit=89,fmt='(a,1x,i5,1x,a,1x,l1,1x,7(1x,a,1x,es12.5))')                       &
         !   'NEWTON: itn=',itn,'bisection=',.false.,'zetaz=',zetaz,'fun=',fun,'fm=',fm        &
         !  ,'fh=',fh,'dfmdzeta=',dfmdzeta,'dfhdzeta=',dfhdzeta,'deriv=',deriv
         !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
         !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!
         converged = abs(zetaz-zetaa) < toler * abs(zetaz)

         if (converged) then
            zoobukhov = 0.5 * (zetaa+zetaz)
            return
         elseif (fun == 0.0) then !---- Converged by luck. --------------------------------!
            zoobukhov = zetaz
            return
         end if
      end do newloop

      !------------------------------------------------------------------------------------!
      !     If we reached this point then it's because Newton's method failed or it has    !
      ! become too dangerous.  We use the Regula Falsi (Illinois) method, which is just a  !
      ! fancier bisection.  For this we need two guesses, and the guesses must have        !
      ! opposite signs.                                                                    !
      !------------------------------------------------------------------------------------!
      if (funa * fun < 0.0) then
         funz  = fun
         zside = .true. 
      else
         if (abs(fun-funa) < 100. * toler * abs(zetaa)) then
            if (stable) then
               delta = max(0.5 * abs(zetaa-zetamin),100. * toler * abs(zetaa))
            else
               delta = max(0.5 * abs(zetaa-zetamax),100. * toler * abs(zetaa))
            end if
         else
            if (stable) then
               delta = max(abs(funa * (zetaz-zetaa)/(fun-funa))                            &
                          ,100. * toler * abs(zetaa)                                       &
                          ,0.5 * abs(zetaa-zetamin))
            else
               delta = max(abs(funa * (zetaz-zetaa)/(fun-funa))                            &
                          ,100. * toler * abs(zetaa)                                       &
                          ,0.5 * abs(zetaa-zetamax))
            end if
         end if
         if (stable) then
            zetaz = max(zetamin,zetaa + delta)
         else
            zetaz = min(zetamax,zetaa + delta)
         end if
         zside = .false.
         zgssloop: do itp=1,maxfpo
            if (stable) then
               zetaz    = max(zetamin,zetaa + real((-1)**itp * (itp+3)/2) * delta)
            else
               zetaz    = min(zetamax,zetaa + real((-1)**itp * (itp+3)/2) * delta)
            end if
            zeta0m   = zetaz * z0moz
            zeta0h   = zetaz * z0hoz
            fm       = lnzoz0m - psim(zetaz,stable,istar) + psim(zeta0m,stable,istar)
            fh       = lnzoz0h - psih(zetaz,stable,istar) + psih(zeta0h,stable,istar)
            funz     = ribuse * fm * fm / (tprandtl * fh) - zetaz
            zside    = funa * funz < 0.0
            !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
            !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!
            !write(unit=89,fmt='(a,1x,i5,1x,a,1x,l1,1x,7(1x,a,1x,es12.5))')                 &
            !   '2NDGSS: itp=',itp,'zside=',zside,'zetaa=',zetaa,'zetaz=',zetaz             &
            !  ,'funa=',funa,'funz=',funz,'fm=',fm,'fh=',fh,'delta=',delta
            !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
            !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!
            if (zside) exit zgssloop
         end do zgssloop
         if (.not. zside) then
            write (unit=*,fmt='(a)') '=================================================='
            write (unit=*,fmt='(a)') '    No second guess for you...'
            write (unit=*,fmt='(a)') '=================================================='
            write (unit=*,fmt='(2(a,1x,es14.7,1x))') 'zref   =',zref   ,'rough  =',rough
            write (unit=*,fmt='(2(a,1x,es14.7,1x))') 'lnzoz0m=',lnzoz0m,'lnzoz0h=',lnzoz0h
            write (unit=*,fmt='(1(a,1x,es14.7,1x))') 'rib    =',rib    ,'ribuse =',ribuse
            write (unit=*,fmt='(1(a,1x,l1,1x))')     'stable =',stable
            write (unit=*,fmt='(2(a,1x,es14.7,1x))') 'fun    =',fun    ,'delta  =',delta
            write (unit=*,fmt='(2(a,1x,es14.7,1x))') 'zetaa  =',zetaa  ,'funa   =',funa
            write (unit=*,fmt='(2(a,1x,es14.7,1x))') 'zetaz  =',zetaz  ,'funz   =',funz
            call abort_run('Failed finding the second guess for regula falsi'              &
                            ,'zoobukhov','leaf_coms.f90')
         end if
      end if

      !----- Now we are ready to start the regula falsi method. ---------------------------!
      bisloop: do itb=itn,maxfpo
         zoobukhov = (funz*zetaa-funa*zetaz)/(funz-funa)

         !---------------------------------------------------------------------------------!
         !     Now that we updated the guess, check whether they are really close. If so,  !
         ! it converged, I can use this as my guess.                                       !
         !---------------------------------------------------------------------------------!
         converged = abs(zoobukhov-zetaa) < toler * abs(zoobukhov)
         if (converged) exit bisloop

         !------ Finding the new function -------------------------------------------------!
         zeta0m   = zoobukhov * z0moz
         zeta0h   = zoobukhov * z0hoz
         fm       = lnzoz0m - psim(zoobukhov,stable,istar) + psim(zeta0m,stable,istar)
         fh       = lnzoz0h - psih(zoobukhov,stable,istar) + psih(zeta0h,stable,istar)
         fun      = ribuse * fm * fm / (tprandtl * fh) - zoobukhov

         !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
         !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!
         !write(unit=89,fmt='(a,1x,i5,1x,a,1x,l1,1x,7(1x,a,1x,es12.5))')                       &
         !   'REGULA: itn=',itb,'bisection=',.true.,'zetaa=',zetaa,'zetaz=',zetaz,'fun=',fun   &
         !  ,'funa=',funa,'funz=',funz,'fm=',fm,'fh=',fh
         !<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>!
         !><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><!

         !------ Defining my new interval based on the intermediate value theorem. --------!
         if (fun*funa < 0. ) then
            zetaz = zoobukhov
            funz  = fun
            !----- If we are updating zside again, modify aside (Illinois method) ---------!
            if (zside) funa = funa * 0.5
            !----- We just updated zside, setting zside to true. --------------------------!
            zside = .true.
         else
            zetaa = zoobukhov
            funa  = fun
            !----- If we are updating aside again, modify aside (Illinois method) ---------!
            if (.not. zside) funz = funz * 0.5
            !----- We just updated aside, setting aside to true. --------------------------!
            zside = .false.
         end if
      end do bisloop

      if (.not.converged) then
         write (unit=*,fmt='(a)') '-------------------------------------------------------'
         write (unit=*,fmt='(a)') ' Zeta finding didn''t converge!!!'
         write (unit=*,fmt='(a,1x,i5,1x,a)') ' I gave up, after',maxfpo,'iterations...'
         write (unit=*,fmt='(a)') ' '
         write (unit=*,fmt='(a)') ' Input values.'
         write (unit=*,fmt='(a)') ' '
         write (unit=*,fmt='(a,1x,f12.4)' ) 'rib             [   ---] =',rib
         write (unit=*,fmt='(a,1x,f12.4)' ) 'ribuse          [   ---] =',ribuse
         write (unit=*,fmt='(a,1x,f12.4)' ) 'zref            [     m] =',zref
         write (unit=*,fmt='(a,1x,f12.4)' ) 'rough           [     m] =',rough
         write (unit=*,fmt='(a,1x,f12.4)' ) 'zoz0m           [   ---] =',zoz0m
         write (unit=*,fmt='(a,1x,f12.4)' ) 'lnzoz0m         [   ---] =',lnzoz0m
         write (unit=*,fmt='(a,1x,f12.4)' ) 'zoz0h           [   ---] =',zoz0h
         write (unit=*,fmt='(a,1x,f12.4)' ) 'lnzoz0h         [   ---] =',lnzoz0h
         write (unit=*,fmt='(a,1x,l1)'    ) 'stable          [   T|F] =',stable
         write (unit=*,fmt='(a)') ' '
         write (unit=*,fmt='(a)') ' Last iteration outcome (downdraft values).'
         write (unit=*,fmt='(a,1x,f12.4)' ) 'zetaa           [   ---] =',zetaa
         write (unit=*,fmt='(a,1x,f12.4)' ) 'zetaz           [   ---] =',zetaz
         write (unit=*,fmt='(a,1x,f12.4)' ) 'fun             [   ---] =',fun
         write (unit=*,fmt='(a,1x,f12.4)' ) 'fm              [   ---] =',fm
         write (unit=*,fmt='(a,1x,f12.4)' ) 'fh              [   ---] =',fh
         write (unit=*,fmt='(a,1x,f12.4)' ) 'funa            [   ---] =',funa
         write (unit=*,fmt='(a,1x,f12.4)' ) 'funz            [   ---] =',funz
         write (unit=*,fmt='(a,1x,f12.4)' ) 'deriv           [   ---] =',deriv
         write (unit=*,fmt='(a,1x,es12.4)') 'toler           [   ---] =',toler
         write (unit=*,fmt='(a,1x,es12.4)') 'error           [   ---] ='                   &
                                                            ,abs(zetaz-zetaa)/abs(zetaz)
         write (unit=*,fmt='(a,1x,f12.4)' ) 'zoobukhov       [   ---] =',zoobukhov
         write (unit=*,fmt='(a)') '-------------------------------------------------------'

         call abort_run('Zeta didn''t converge, giving up!!!'                              &
                         ,'zoobukhov','leaf_coms.f90')
      end if

      return
   end function zoobukhov
   !=======================================================================================!
   !=======================================================================================!
end module leaf_coms
!==========================================================================================!
!==========================================================================================!



