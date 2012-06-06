!==========================================================================================!
!==========================================================================================!
! grell_cupar_driver.f90                                                                   !
!                                                                                          !
!    This file contains the driver that will compute the Cumulus based on Grell-D�v�nyi    !
! parameterization, and send the information needed by the other modules.                  !
!------------------------------------------------------------------------------------------!
subroutine grell_cupar_driver(cldd,clds)

   use catt_start       , only : catt               ! ! Flag for CATT. 
   use extras           , only : extra3d            ! ! Extra scratch for CATT
   use grell_coms       , only : cld2prec           & ! Frac. of cloud water lost to prec.
                               , closure_type       & ! Closure to be used on dyn. control
                               , comp_modif_thermo  & ! Flag - compute the x_* variables
                               , maxens_cap         & ! Ens. size on level of capping inv.
                               , maxens_dyn         & ! Ens. size on dynamic control
                               , maxens_eff         & ! Ens. size on precipitation eff.
                               , maxens_lsf         & ! Ens. size on large scale pert.
                               , mgmzp              & ! Vertical grid size
                               , prec_cld           ! ! Flag - precipitating cloud.
   use io_params        , only : frqanl             ! ! Frequency of analysis.
   use mem_basic        , only : co2_on             ! ! Flag for CO2 presence.
   use mem_cuparm       , only : confrq             & ! Vector with convective frequency
                               , cuparm_g           & ! Structure with convection
                               , nclouds            ! ! Number of clouds available.
   use mem_grid         , only : dtlongn            & ! Time step vector
                               , dtlt               & ! current grid time step
                               , ngrid              & ! current grid ID
                               , time               ! ! Simulation elapsed time
   use mem_scratch      , only : scratch            ! ! Scratch array, to save old info.
   use mem_scratch_grell, only : zero_scratch_grell ! ! Flushes scratch variables to zero.
   use mem_tend         , only : tend_g             ! ! Tendency structure
   use node_mod         , only : mynum              & ! This node ID
                               , mxp                & ! Number of x-points - current grid
                               , myp                & ! Number of y-points - current grid
                               , mzp                & ! Number of z-points - current grid
                               , ia                 & ! westernmost point  - current grid
                               , iz                 & ! easternmost point  - current grid
                               , ja                 & ! southernmost point - current grid
                               , jz                 ! ! northernmost point - current grid
   implicit none

   !----- Arguments. ----------------------------------------------------------------------!
   integer, intent(in)               :: cldd             ! Deepest Grell cloud.
   integer, intent(in)               :: clds             ! Shallowest Grell cloud.
   !----- Local variables. ----------------------------------------------------------------!
   integer                           :: icld             ! Cloud type counter.
   integer                           :: i,j,k            ! Counters for x, y, and z
   integer                           :: iscl             ! Scalar counter
   real                              :: dti              ! confrq/frqanl
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !---------------------------------------------------------------------------------------!
   !                           ----- Main convection block -----                           !
   !---------------------------------------------------------------------------------------!
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   ! 1. Set the time weight.                                                               !
   !---------------------------------------------------------------------------------------!
   dti = confrq / frqanl
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !     Big loop accross the horizontal grid points. Now we call the model column by      !
   ! column.                                                                               !
   !---------------------------------------------------------------------------------------!
   jloop: do j=ja,jz
      iloop: do i=ia,iz

         ![[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[!
         !---------------------------------------------------------------------------------!
         ! 2. We now initialise some variables that don't depend on the cloud spectral     !
         !    size because they must be done only once.                                    !
         !---------------------------------------------------------------------------------!
         ! call grell_cupar_initial(i,j,confrq)
         call grell_cupar_initial(i,j,dtlt)


         !---------------------------------------------------------------------------------!
         ! 3. We will now go through the cloud sizes for the first time, in order to solve !
         !    the static control.                                                          !
         !---------------------------------------------------------------------------------!
         staticloop: do icld = cldd,clds
            call grell_cupar_static_driver(i,j,icld)
         end do staticloop

         !---------------------------------------------------------------------------------!
         ! 4. We now compute the dynamic control, which will determine the characteristic  !
         !    mass flux for each Grell cumulus cloud.                                      !
         !---------------------------------------------------------------------------------!
         ! call grell_cupar_dynamic(cldd,clds,nclouds,confrq,maxens_cap,maxens_eff           &
         !                         ,maxens_lsf,maxens_dyn,mgmzp,closure_type                 &
         !                         ,comp_modif_thermo,prec_cld,cld2prec,mynum,i,j)
         call grell_cupar_dynamic(cldd,clds,nclouds,dtlt,maxens_cap,maxens_eff             &
                                 ,maxens_lsf,maxens_dyn,mgmzp,closure_type                 &
                                 ,comp_modif_thermo,prec_cld,cld2prec,mynum,i,j)

         !---------------------------------------------------------------------------------!
         ! 5. We now go through the cloud sizes again, to compute the feedback to the      !
         !    large scale and any other cloud-dependent variable that needs to be          !
         !    computed.                                                                    !
         !---------------------------------------------------------------------------------!
         call grell_feedback_driver(i,j,cldd,clds,dti)

      end do iloop
   end do jloop
   !---------------------------------------------------------------------------------------!

   return 
end subroutine grell_cupar_driver
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This subroutine will initialise several scratch variables that are needed by the     !
! cloud scheme.  This needs to be done only once per column, and it was removed from       !
! grell_cupar_driver to avoid optimisation loss and dependency check and all the problems  !
! that may arise from this.                                                                !
!------------------------------------------------------------------------------------------!
subroutine grell_cupar_initial(i,j,confrqd)
   !----- The following module variables are supposed to be "intent (in)". ----------------!
   use mem_basic        , only : co2_on             & ! CO2 presence.
                               , co2con             & ! CO2 mixing ratio if constant.
                               , basic_g            ! ! Basic variables structure
   use mem_grid         , only : deltax             & ! Current grid resolution in x (m)
                               , deltay             & ! Current grid resolution in y (m)
                               , dtlt               & ! current grid time step
                               , grid_g             & ! grid structure
                               , ngrid              & ! current grid ID
                               , zt                 & ! Vertical thermodynamic levels
                               , zm                 ! ! Vertical momentum levels
   use mem_micro        , only : micro_g            ! ! Microphysics structure
   use mem_turb         , only : turb_g             & ! Turbulence structure
                               , idiffk             ! ! Turbulence closure flag
   use micphys          , only : availcat           ! ! Flag: hydrometeor is available
   use node_mod         , only : mynum              & ! This node ID
                               , mxp                & ! Number of x-points for current grid
                               , myp                & ! Number of y-points for current grid
                               , mzp                ! ! Number of z-points for current grid
   use therm_lib        , only : level              ! ! Phase complexity level
   !----- The following module variables are supposed to be "intent (inout)". -------------!
   use mem_tend         , only : tend_g             ! ! Tendency structure
   !----- The following module variables are supposed to be "intent (out)". ---------------!
   use mem_scratch      , only : scratch            & ! Scratch array, to save old info.
                               , vctr6              & ! Scratch, liquid water mix. ratio.
                               , vctr7              & ! Scratch, ice mixing ratio.
                               , vctr8              & ! Scratch, CO2 mixing ratio.
                               , vctr9              & ! Scratch, vertical velocity sigma.
                               , vctr18             ! ! Scratch, CO2 tendency.
   !----- The following module variables are supposed to be sub-routines. -----------------!
   use mem_scratch_grell, only : zero_scratch_grell ! ! Flushes scratch variables to zero.
   use grell_coms       , only : mgmzp              ! ! intent(in)
   !---------------------------------------------------------------------------------------!

   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   integer, intent(in)               :: i                ! X position
   integer, intent(in)               :: j                ! Y position
   real   , intent(in)               :: confrqd          ! Frequency
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   ! A. Find the ice and liquid mixing ratio.  Since ice and liquid may not be solved for  !
   ! some user's configuration (level = 1 and 2), we must check that first.                !
   !---------------------------------------------------------------------------------------!
   select case (level)
   !------ No condensed phase, simply set up both to zero. --------------------------------!
   case (0,1)
      call azero(mzp,vctr6(1:mzp))
      call azero(mzp,vctr7(1:mzp))
   !----- Liquid condensation only, use saturation adjustment -----------------------------!
   case (2)
       call atob(mzp,micro_g(ngrid)%rcp(:,i,j),vctr6(1:mzp))
       call azero(mzp,vctr7(1:mzp))
   case (3)
      call integ_liq_ice(mzp,availcat                                                      &
              , micro_g(ngrid)%rcp           (:,i,j), micro_g(ngrid)%rrp           (:,i,j) &
              , micro_g(ngrid)%rpp           (:,i,j), micro_g(ngrid)%rsp           (:,i,j) &
              , micro_g(ngrid)%rap           (:,i,j), micro_g(ngrid)%rgp           (:,i,j) &
              , micro_g(ngrid)%rhp           (:,i,j), micro_g(ngrid)%q6            (:,i,j) &
              , micro_g(ngrid)%q7            (:,i,j), vctr6(1:mzp)                         &
              , vctr7(1:mzp)                        )
   end select
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   ! B. Copy CO2 array to scratch variable, if CO2 is actively prognosed.  Otherwise, put  !
   !    the constant CO2 mixing ratio, although it will not be really used.                !
   !---------------------------------------------------------------------------------------!
   if (co2_on) then
      call atob(mzp,basic_g(ngrid)%co2p(:,i,j), vctr8(1:mzp))
      call atob(mzp,tend_g(ngrid)%co2t(:,i,j) ,vctr18(1:mzp))
   else
      call ae0  (mzp,vctr8(1:mzp) ,co2con(1))
      call azero(mzp,vctr18(1:mzp))
   end if
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   ! C. Copying sigma-w to a scratch array.  This is because it is available only for      !
   !    idiffk = 1 or idiffk = 7.  It's really unlikely that one would use the other       !
   !    TKE-related schemes with cumulus parameterization though, because they are LES     !
   !    schemes.  If that happens, use special flag (sigmaw=0).                            !
   !---------------------------------------------------------------------------------------!
   select case (idiffk(ngrid))
   case (1,7,8)
      call atob(mzp,turb_g(ngrid)%sigw(:,i,j),vctr9(1:mzp))
   case default
      call azero(mzp,vctr9(1:mzp))
   end select
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   ! D. Flushes all scratch variables to zero.                                             !
   !---------------------------------------------------------------------------------------!
   call zero_scratch_grell(3)
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   ! E. Initialise grid-related variables (how many levels, offset, etc.)                  !
   !---------------------------------------------------------------------------------------!
   call initial_grid_grell(mzp,deltax,deltay,zt(1:mzp),zm(1:mzp)                           &
              , grid_g(ngrid)%flpw             (i,j), grid_g(ngrid)%rtgt             (i,j) &
              , confrqd                             , turb_g(ngrid)%kpbl             (i,j) )
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   ! F. Copy the tendencies to the scratch array.                                          !
   !---------------------------------------------------------------------------------------!
   call initial_tend_grell(mzp,tend_g(ngrid)%tht(:,i,j),tend_g(ngrid)%tket(:,i,j)          &
                          ,tend_g(ngrid)%rtt(:,i,j),vctr18(1:mzp))
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   ! G. Initialise pressure, temperature, and mixing ratio with both the past values and   !
   !    the future values in case convection does not happen (previous values plus the     !
   !    large-scale forcing).                                                              !
   !---------------------------------------------------------------------------------------!
   call initial_thermo_grell(mzp,mgmzp,confrqd      , basic_g(ngrid)%thp           (:,i,j) &
              , basic_g(ngrid)%theta         (:,i,j), basic_g(ngrid)%rtp           (:,i,j) &
              , vctr8                        (1:mzp), basic_g(ngrid)%pi0           (:,i,j) &
              , basic_g(ngrid)%pp            (:,i,j), basic_g(ngrid)%pc            (:,i,j) &
              , basic_g(ngrid)%wp            (:,i,j), basic_g(ngrid)%dn0           (:,i,j) &
              , turb_g(ngrid)%tkep           (:,i,j), vctr6                        (1:mzp) &
              , vctr7                        (1:mzp), vctr9                        (1:mzp))
   !---------------------------------------------------------------------------------------!


   return
end subroutine grell_cupar_initial
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This subroutine will drive the remaining steps for a static control for a given      !
! cloud.  The only reason these steps are here is to avoid nasty problems coming from      !
! optimisation loss.                                                                       !
!------------------------------------------------------------------------------------------!
subroutine grell_cupar_static_driver(i,j,icld)
   use grell_coms        , only: & ! All variables here are intent(in)
           comp_noforc_cldwork   & ! I will compute no forced cloud work     [T/F]
          ,checkmass             & ! I will check mass balance               [T/F]
          ,maxens_cap            & ! Ensemble size on level of capping inversion
          ,maxens_eff            & ! Ensemble size on precipitation efficiency
          ,mgmzp                 & ! Vertical grid size
          ,cap_maxs              & ! Maximum depth of capping inversion     [  Pa]
          ,cap_maxs_increment    & ! Extra cap_maxs due to upstream conv.   [  Pa]
          ,cld2prec              & ! Fraction of cloud converted to precip. [ ---]
          ,depth_min             & ! Minimum cloud depth to qualify it      [ hPa]
          ,depth_max             & ! Maximum cloud depth to qualify it      [ hPa]
          ,edtmax                & ! Maximum Grell's epsilon (dnmf/upmf)
          ,edtmin                & ! Minimum Grell's epsilon (dnmf/upmf)
          ,iupmethod             & ! Method to define updraft originating level.
          ,masstol               & ! Maximum mass leak allowed to happen    [ ---]
          ,pmass_left            & ! Fraction of mass left at the ground    [ ---]
          ,prec_cld              & ! This cloud can precipitate             [ T/F]
          ,radius                & ! Radius, for entrainment rate.          [   m]
          ,relheight_down        & ! Relative height for downdraft origin   [ ---]
          ,wnorm_max             & ! Normalised trigger vertical velocity
          ,wnorm_increment       & ! Increments on wnorm_max for ensemble
          ,zkbmax                & ! Top height for updrafts to originate   [   m]
          ,zcutdown              & ! Top height for downdrafts to originate [   m]
          ,z_detr                ! ! Top height for downdraft detrainment   [   m]

   use mem_basic         , only: &
           basic_g               ! ! intent(in) - Basic variables structure

   use mem_cuparm        , only: &
           cuparm_g              ! ! intent(inout) - Structure with convection

   use mem_ensemble, only:       & !
           ensemble_e            & ! intent(inout) - Ensemble structure
          ,zero_ensemble         ! ! subroutine to flush scratch arrays to zero.
   
   use mem_scratch_grell , only: &
           zero_scratch_grell    ! ! Subroutine - Flushes scratch variables to zero.

   use mem_grid          , only: & ! All variables are intent(in)
           jdim                  & ! j-dimension (usually 1 except for rare 2-D runs)
          ,ngrid                 ! ! current grid ID

   use node_mod          , only: & ! All variables are intent(in)
           mynum                 & ! This node ID
          ,mxp                   & ! # of x-points for current grid in this node
          ,myp                   & ! # of y-points for current grid in this node
          ,mzp                   ! ! # of z-points for current grid in this node

   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   integer, intent(in)               :: i                ! X position
   integer, intent(in)               :: j                ! Y position
   integer, intent(in)               :: icld             ! Cloud position
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   ! A. Reset the entire ensemble structure for this cloud.                                !
   !---------------------------------------------------------------------------------------!
   call zero_scratch_grell(1)
   call zero_ensemble(ensemble_e(icld))

   !---------------------------------------------------------------------------------------!
   ! B. Initialise the remainder Grell's scratch variables that uses wind data.  Because   !
   !    winds are in staggered grids, this requires full grid information.                 !
   !---------------------------------------------------------------------------------------!
   call initial_winds_grell(prec_cld(icld),mzp,mxp,myp,i,j,jdim                            &
                         , cuparm_g(ngrid)%dnmf (:,:,icld), basic_g(ngrid)%up              &
                         , basic_g(ngrid)%vp              , ensemble_e(icld)%prev_dnmf     )

         
   !---------------------------------------------------------------------------------------!
   ! C. Call the subroutine which will deal with the static control.                       !
   !---------------------------------------------------------------------------------------!
   call grell_cupar_static(comp_noforc_cldwork,checkmass,iupmethod,maxens_cap,maxens_eff   &
                     , mgmzp,cap_maxs,cap_maxs_increment,wnorm_max,wnorm_increment         &
                     , depth_min(icld),depth_max(icld),edtmax,edtmin,masstol,pmass_left    &
                     , radius(icld),relheight_down,zkbmax,zcutdown,z_detr,cld2prec         &
                     , prec_cld(icld)                                                      &
                     , cuparm_g(ngrid)%aadn(i,j,icld)   , cuparm_g(ngrid)%aaup(i,j,icld)   &
                     , ensemble_e(icld)%dellatheiv_eff  , ensemble_e(icld)%dellathil_eff   &
                     , ensemble_e(icld)%dellaqtot_eff   , ensemble_e(icld)%dellaco2_eff    &
                     , ensemble_e(icld)%pw_eff          , ensemble_e(icld)%edt_eff         &
                     , ensemble_e(icld)%aatot0_eff      , ensemble_e(icld)%aatot_eff       &
                     , ensemble_e(icld)%ierr_cap        , ensemble_e(icld)%comp_down_cap   &
                     , ensemble_e(icld)%klod_cap        , ensemble_e(icld)%klou_cap        &
                     , ensemble_e(icld)%klcl_cap        , ensemble_e(icld)%klfc_cap        &
                     , ensemble_e(icld)%kdet_cap        , ensemble_e(icld)%kstabi_cap      &
                     , ensemble_e(icld)%kstabm_cap      , ensemble_e(icld)%klnb_cap        &
                     , ensemble_e(icld)%ktop_cap        , ensemble_e(icld)%pwav_cap        &
                     , ensemble_e(icld)%pwev_cap        , ensemble_e(icld)%wbuoymin_cap    &
                     , ensemble_e(icld)%cdd_cap         , ensemble_e(icld)%cdu_cap         &
                     , ensemble_e(icld)%mentrd_rate_cap , ensemble_e(icld)%mentru_rate_cap &
                     , ensemble_e(icld)%dbyd_cap        , ensemble_e(icld)%dbyu_cap        &
                     , ensemble_e(icld)%etad_cld_cap    , ensemble_e(icld)%etau_cld_cap    &
                     , ensemble_e(icld)%rhod_cld_cap    , ensemble_e(icld)%rhou_cld_cap    &
                     , ensemble_e(icld)%qliqd_cld_cap   , ensemble_e(icld)%qliqu_cld_cap   &
                     , ensemble_e(icld)%qiced_cld_cap   , ensemble_e(icld)%qiceu_cld_cap   &
                     , i,j,icld,mynum                   )
   return
end subroutine grell_cupar_static_driver
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This subroutine is going to call the subroutines used to determine the feedback to   !
! large scale.  This part was taken out from the main driver to avoid optimisation loss    !
! and some nasty things that happen with the model when this optimisation is lost.         !
!------------------------------------------------------------------------------------------!
subroutine grell_feedback_driver(i,j,cldd,clds,dti)

   use catt_start        , only: &
           catt                  ! ! intent(in) - flag for CATT. 

   use extras            , only: &
           extra3d               ! ! intent(inout) - Extra scratch for CATT

   use grell_coms        , only: & ! All variables here are intent(in)
           closure_type          & ! Flag for closure to be used on dyn. control
          ,maxens_cap            & ! Ensemble size on level of capping inversion
          ,maxens_dyn            & ! Ensemble size on dynamic control
          ,maxens_eff            & ! Ensemble size on precipitation efficiency
          ,maxens_lsf            & ! Ensemble size on large scale perturbations
          ,mgmzp                 & ! Vertical grid size
          ,inv_ensdim            & ! Inverse of ensemble dimension size
          ,max_heat              ! ! Maximum heating scale                  [K/dy]

   use mem_basic         , only: &
           co2_on                ! ! intent(in) - Flag for CO2 presence.

   use mem_cuparm        , only: &
           cuparm_g              ! ! intent(inout) - Structure with convection

   use mem_ensemble, only:       & !
           ensemble_e            & ! intent(inout) - Ensemble structure
          ,zero_ensemble         ! ! subroutine to flush scratch arrays to zero.

   use mem_grid          , only: & ! All variables are intent(in)
           grid_g                & ! grid structure
          ,naddsc                & ! number of additional scalars
          ,ngrid                 & ! current grid ID
          ,zt                    & ! Vertical thermodynamic levels for current grid
          ,zm                    ! ! Vertical momentum levels for current grid

   use mem_mass          , only: &
           imassflx              & ! intent(in) - flag for mass flux outout
          ,mass_g                ! ! intent(inout) - mass structure

   use mem_scratch       , only: &
           scratch       & ! intent(out) - Scratch array, to save old info.
          ,vctr26        & ! intent(out) - Scratch, contains the convective THP forcing.
          ,vctr27        & ! intent(out) - Scratch, contains the convective RTP forcing.
          ,vctr28        ! ! intent(out) - Scratch, contains the convective CO2P forcing.

   use mem_scalar        , only: &
           scalar_g              ! ! intent(inout) - This is used by CATT only.

   use node_mod          , only: & ! All variables are intent(in)
           mynum                 & ! This node ID
          ,mxp                   & ! # of x-points for current grid in this node
          ,myp                   & ! # of y-points for current grid in this node
          ,mzp                   ! ! # of z-points for current grid in this node

   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   integer, intent(in)               :: i                ! X position
   integer, intent(in)               :: j                ! Y position
   integer, intent(in)               :: cldd             ! Deepest cloud
   integer, intent(in)               :: clds             ! Shallowest cloud
   real   , intent(in)               :: dti              ! confrq/frqanl
   !----- Local constants. ----------------------------------------------------------------!
   integer                           :: icld             ! Cloud counter
   integer                           :: iscl             ! Scalar counter
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   ! A. Compute the feedback to the large-scale per se.  This will determine the forcing   !
   !    of large-scale variables, namely ice-liquid potential temperature, total water     !
   !    vapour mixing ratio, and carbon dioxide mixing ratio.                              !
   !---------------------------------------------------------------------------------------!
   do icld = cldd, clds
      call grell_cupar_feedback(mgmzp,maxens_cap,maxens_eff,maxens_lsf,maxens_dyn          &
                            , inv_ensdim, max_heat                                         &
                            , ensemble_e(icld)%dnmf_ens     , ensemble_e(icld)%upmf_ens    &
                            , ensemble_e(icld)%dnmx_ens     , ensemble_e(icld)%upmx_ens    &
                            , ensemble_e(icld)%dnmf_cap     , ensemble_e(icld)%upmf_cap    &
                            , ensemble_e(icld)%dellathil_eff                               &
                            , ensemble_e(icld)%dellaqtot_eff                               &
                            , ensemble_e(icld)%dellaco2_eff                                &
                            , ensemble_e(icld)%pw_eff                                      &
                            , ensemble_e(icld)%outco2                                      &
                            , ensemble_e(icld)%outqtot                                     &
                            , ensemble_e(icld)%outthil                                     &
                            , ensemble_e(icld)%precip                                      &
                            , ensemble_e(icld)%ierr_cap                                    &
                            , ensemble_e(icld)%comp_down_cap                               &
                            , cuparm_g(ngrid)%dnmf(i,j,icld)                               &
                            , cuparm_g(ngrid)%upmf(i,j,icld)                               &
                            , cuparm_g(ngrid)%dnmx(i,j,icld)                               &
                            , cuparm_g(ngrid)%upmx(i,j,icld)                               &
                            , cuparm_g(ngrid)%edt (i,j,icld)                               &
                            , i,j,icld,mynum                                               )
   end do

   !---------------------------------------------------------------------------------------!
   ! B. Find the area covered by each cloud type.  This is called outside the loop because !
   !    the cloud area is scaled by the total area.                                        !
   !---------------------------------------------------------------------------------------!
   call grell_cupar_area_scaler(cldd,clds,mzp,mgmzp,maxens_cap)


   do icld = cldd, clds
      !------------------------------------------------------------------------------------!
      ! C. Reset output variables to zero.                                                 !
      !------------------------------------------------------------------------------------!
      call azero(mzp,vctr28)

      !------------------------------------------------------------------------------------!
      ! D. We now compute the other output variables such as mass fluxes and interesting   !
      !    levels.                                                                         !
      !------------------------------------------------------------------------------------!
      call grell_cupar_output(mzp,mgmzp,maxens_cap                                         &
                 , grid_g(ngrid)%rtgt            (i,j), zm(1:mzp)                          &
                 , zt(1:mzp)                          , cuparm_g(ngrid)%dnmf    (i,j,icld) &
                 , cuparm_g(ngrid)%upmf    (i,j,icld) , cuparm_g(ngrid)%dnmx    (i,j,icld) &
                 , cuparm_g(ngrid)%upmx    (i,j,icld) , ensemble_e(icld)%ierr_cap          &
                 , ensemble_e(icld)%dnmf_cap          , ensemble_e(icld)%upmf_cap          &
                 , ensemble_e(icld)%kdet_cap          , ensemble_e(icld)%klou_cap          &
                 , ensemble_e(icld)%klcl_cap          , ensemble_e(icld)%klfc_cap          &
                 , ensemble_e(icld)%klod_cap          , ensemble_e(icld)%klnb_cap          &
                 , ensemble_e(icld)%ktop_cap          , ensemble_e(icld)%areadn_cap        &
                 , ensemble_e(icld)%areaup_cap        , ensemble_e(icld)%wdndraft_cap      &
                 , ensemble_e(icld)%wupdraft_cap      , ensemble_e(icld)%wbuoymin_cap      &
                 , ensemble_e(icld)%etad_cld_cap      , ensemble_e(icld)%mentrd_rate_cap   &
                 , ensemble_e(icld)%cdd_cap           , ensemble_e(icld)%dbyd_cap          &
                 , ensemble_e(icld)%rhod_cld_cap      , ensemble_e(icld)%etau_cld_cap      &
                 , ensemble_e(icld)%mentru_rate_cap   , ensemble_e(icld)%cdu_cap           &
                 , ensemble_e(icld)%dbyu_cap          , ensemble_e(icld)%rhou_cld_cap      &
                 , ensemble_e(icld)%qliqd_cld_cap     , ensemble_e(icld)%qliqu_cld_cap     &
                 , ensemble_e(icld)%qiced_cld_cap     , ensemble_e(icld)%qiceu_cld_cap     &
                 , ensemble_e(icld)%outco2            , ensemble_e(icld)%outqtot           &
                 , ensemble_e(icld)%outthil           , ensemble_e(icld)%precip            &
                 , cuparm_g(ngrid)%xierr   (i,j,icld) , cuparm_g(ngrid)%zklod   (i,j,icld) &
                 , cuparm_g(ngrid)%zklou   (i,j,icld) , cuparm_g(ngrid)%zklcl   (i,j,icld) &
                 , cuparm_g(ngrid)%zklfc   (i,j,icld) , cuparm_g(ngrid)%zkdet   (i,j,icld) &
                 , cuparm_g(ngrid)%zklnb   (i,j,icld) , cuparm_g(ngrid)%zktop   (i,j,icld) &
                 , cuparm_g(ngrid)%conprr  (i,j,icld) , cuparm_g(ngrid)%thsrc (:,i,j,icld) &
                 , cuparm_g(ngrid)%rtsrc (:,i,j,icld) , vctr28                     (1:mzp) &
                 , cuparm_g(ngrid)%areadn  (i,j,icld) , cuparm_g(ngrid)%areaup  (i,j,icld) &
                 , cuparm_g(ngrid)%wdndraft(i,j,icld) , cuparm_g(ngrid)%wupdraft(i,j,icld) &
                 , cuparm_g(ngrid)%wbuoymin(i,j,icld)                                      &
                 , cuparm_g(ngrid)%cuprliq (:,i,j,icld)                                    &
                 , cuparm_g(ngrid)%cuprice (:,i,j,icld)                                    &
                 , i,j,icld,mynum)

      !------------------------------------------------------------------------------------!
      ! E. Copy the CO2 forcing if CO2 is available.                                       !
      !------------------------------------------------------------------------------------!
      if (co2_on) call atob(mzp,vctr28(1:mzp),cuparm_g(ngrid)%co2src(1:mzp,i,j,icld))

      !------------------------------------------------------------------------------------!
      ! F. If the user needs the full mass flux information to drive Lagrangian models,    !
      !    then do it now.                                                                 !
      !------------------------------------------------------------------------------------!
      if (imassflx == 1) then
         call prep_convflx_to_mass(mzp,mgmzp,maxens_cap                                    &
                     , cuparm_g(ngrid)%dnmf  (i,j,icld) , cuparm_g(ngrid)%upmf  (i,j,icld) &
                     , ensemble_e(icld)%ierr_cap        , ensemble_e(icld)%klod_cap        &
                     , ensemble_e(icld)%klou_cap        , ensemble_e(icld)%klfc_cap        &
                     , ensemble_e(icld)%kdet_cap        , ensemble_e(icld)%ktop_cap        &
                     , ensemble_e(icld)%cdd_cap         , ensemble_e(icld)%cdu_cap         &
                     , ensemble_e(icld)%mentrd_rate_cap , ensemble_e(icld)%mentru_rate_cap &
                     , ensemble_e(icld)%etad_cld_cap    , ensemble_e(icld)%etau_cld_cap    &
                     , mass_g(ngrid)%cfxdn (:,i,j,icld) , mass_g(ngrid)%cfxup (:,i,j,icld) &
                     , mass_g(ngrid)%dfxdn (:,i,j,icld) , mass_g(ngrid)%dfxup (:,i,j,icld) &
                     , mass_g(ngrid)%efxdn (:,i,j,icld) , mass_g(ngrid)%efxup (:,i,j,icld) )
      end if
      !------------------------------------------------------------------------------------!


      !------------------------------------------------------------------------------------!
      ! G. Here are CATT-related procedures.  It does pretty much the same as it used to,  !
      !    except that I took the statistics out from inside grell_cupar_main and brought  !
      !    trans_conv_mflx inside the i/j loop.                                            !
      !------------------------------------------------------------------------------------!
      if (catt == 1) then
         if (icld == 1) then
            call grell_massflx_stats(mzp,icld,.true.,dti,maxens_dyn,maxens_lsf,maxens_eff  &
                                    , maxens_cap,inv_ensdim,closure_type                   &
                                    , ensemble_e(icld)%ierr_cap                            &
                                    , ensemble_e(icld)%upmf_ens                            &
                                    , extra3d(1,ngrid)%d3(:,i,j)                           &
                                    , extra3d(4,ngrid)%d3(:,i,j) )
            call grell_massflx_stats(mzp,icld,.false.,dti,maxens_dyn,maxens_lsf,maxens_eff &
                                    , maxens_cap,inv_ensdim,closure_type                   &
                                    , ensemble_e(icld)%ierr_cap                            &
                                    , ensemble_e(icld)%upmf_ens                            &
                                    , extra3d(1,ngrid)%d3(:,i,j)                           &
                                    , extra3d(4,ngrid)%d3(:,i,j) )
         elseif (icld == 2) then
            call grell_massflx_stats(mzp,icld,.true.,dti,maxens_dyn,maxens_lsf             &
                                    , maxens_eff,maxens_cap,inv_ensdim,closure_type        &
                                    , ensemble_e(icld)%ierr_cap                            &
                                    , ensemble_e(icld)%upmf_ens                            &
                                    , extra3d(2,ngrid)%d3(:,i,j)                           &
                                    , scratch%vt3dp              )
         end if
         do iscl=1,naddsc
            call trans_conv_mflx(icld,iscl,mzp,mxp,myp,maxens_cap,i,j                      &
                         , ensemble_e(icld)%ierr_cap      , ensemble_e(icld)%klod_cap      &
                         , ensemble_e(icld)%klou_cap      , ensemble_e(icld)%klfc_cap      &
                         , ensemble_e(icld)%kdet_cap      , ensemble_e(icld)%kstabi_cap    &
                         , ensemble_e(icld)%kstabm_cap    , ensemble_e(icld)%ktop_cap      &
                         , ensemble_e(icld)%cdd_cap       , ensemble_e(icld)%cdu_cap       &
                         , ensemble_e(icld)%mentrd_rate_cap                                &
                         , ensemble_e(icld)%mentru_rate_cap                                &
                         , ensemble_e(icld)%etad_cld_cap  , ensemble_e(icld)%etau_cld_cap  &
                         , cuparm_g(ngrid)%edt (i,j,icld) , cuparm_g(ngrid)%upmf(i,j,icld) &
                         , scalar_g(iscl,ngrid)%sclt      )
         end do
      end if
   end do
   return
end subroutine grell_feedback_driver
!==========================================================================================!
!==========================================================================================!
