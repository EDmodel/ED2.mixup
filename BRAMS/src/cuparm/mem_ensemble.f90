!==========================================================================================!
!==========================================================================================!
!    Module mem_ensemble - This module contains all Grell's scratch variables that do      !
! depend on ensemble dimensions. Since shallow and deep convection have different ensemble !
! sizes, two scratch arrays are allocated, one for each spectral size                      !
!------------------------------------------------------------------------------------------!
module mem_ensemble

   
   type ensemble_vars

      !------ 4D dependence (maxens_dyn,maxens_lsf,maxens_eff,maxens_cap) -----------------!
      real, pointer, dimension(:,:,:,:) :: &
            dnmf_ens                       & ! Reference downdraft mass flux      [kg/m�/s]
           ,upmf_ens                       & ! Reference updraft mass flux        [kg/m�/s]
           ,dnmx_ens                       & ! Potential downdraft mass flux      [kg/m�/s]
           ,upmx_ens                       ! ! Potential updraft mass flux        [kg/m�/s]
      !------------------------------------------------------------------------------------!
      
      !------------------------------------------------------------------------------------!
      !     The following variable is associated with each member of the ensemble, plus    !
      ! the effect of on cloud on the other.                                               !
      !------------------------------------------------------------------------------------!
      !------ 4D dependence (nclouds,maxens_lsf,maxens_eff,maxens_cap) --------------------!
      real, pointer, dimension(:,:,:,:) :: & ! 
            x_aatot                        ! ! Cloud work function of a state perturbed
                                           ! !    by another cloud                [   J/kg]



      !------------------------------------------------------------------------------------!
      !    These variables are associated with each member of the second kind of ensemble, !
      ! that varies the precipitation efficiency. As described by Grell and D�v�nyi, the   !
      ! precipitation efficiency has a huge impact on the final answer, so that is a good  !
      ! variable to test for sensibility.                                                  !
      !------------------------------------------------------------------------------------!
      !------ 2D dependence (maxens_eff,maxens_cap) ---------------------------------------!
      real, pointer, dimension(:,:) ::   &
            edt_eff                      & ! Precipitation efficiency for each member
           ,aatot0_eff                   & ! Current total cloud work function    [   J/kg]
           ,aatot_eff                    ! ! Total cloud work func. (forced)      [   J/kg]

      !------ 3D dependence (mgmzp,maxens_eff,maxens_cap) ---------------------------------!
      real, pointer, dimension(:,:,:) ::   & ! These are changes per unit of mass.
            dellatheiv_eff                 & ! Change in ice-liquid potential temperature
           ,dellathil_eff                  & ! Change in ice-liquid potential temperature
           ,dellaqtot_eff                  & ! Change in total mixing ratio
           ,dellaco2_eff                   & ! Change in CO2 mixing ratio
           ,pw_eff                         ! ! Water that doesn't evaporate (aka rain).
      !------------------------------------------------------------------------------------!


      !------------------------------------------------------------------------------------!
      !     These variables are associated to each static control member.                  !
      !------------------------------------------------------------------------------------!


      !------------------------------------------------------------------------------------!
      !    This flag states whether convection happened or failed.  When ierr=0, then      !
      ! convection happened, otherwise something went wrong and the cloud couldn't exist.  !
      ! Each thing that can go wrong and thus impeach convection is assigned a different   !
      ! number.  The error table is the following:                                         !
      !                                                                                    !
      !  0. Nothing, convection did happen;                                                !
      !  1. Grell scheme wasn't called for this cloud. This happens when it is too early   !
      !     in the simulation for convection to be called or for clouds that are solved    !
      !     with other closures.                                                           !
      !  2. The level where updrafts originate would be above the maximum height allowed;  !
      !  3. The level of free convection is too far from the level where updrafts origin-  !
      !     ate, so it is out of reach;                                                    !
      !  4. We couldn't find a layer with negative buoyancy for downdrafts;                !
      !  5. We couldn't find a suitable cloud top, it would be above the domain top;       !
      !  6. This cloud would be too thin to fall in this spectral type;                    !
      !  7. This cloud would be too thick to fall in this spectral type;                   !
      !  8. Forced downdraft layer would have positive buoyancy, which doesn't make sense; !
      !  9. This cloud didn't have any condensation;                                       !
      ! 10. Cloud work function associated with updraft is zero;                           !
      ! 11. Reference upward mass flux is zero;                                            !
      ! 12. Downdrafts would happen below the updrafts origin;                             !
      ! 13. Dynamic control didn't leave any positive member of reference mass flux, so    !
      !     this cloud can't exist.                                                        !
      !------------------------------------------------------------------------------------!
      !------ 1D dependence (maxens_cap) --------------------------------------------------!
      integer, pointer, dimension(:) :: &
            ierr_cap                    ! ! Convection failure flag.
       !------ 1D dependence (maxens_cap) --------------------------------------------------!
      logical, pointer, dimension(:) :: &
            comp_down_cap               ! ! Downdraft flag.
     !------------------------------------------------------------------------------------!
      !------ 1D dependence (maxens_cap) --------------------------------------------------!
      integer, pointer, dimension(:)   :: &
            klod_cap                      & ! Level of origin of downdrafts
           ,klou_cap                      & ! Level of origin of updrafts
           ,klfc_cap                      & ! Level of free convection
           ,klcl_cap                      & ! Level of free convection
           ,kdet_cap                      & ! Top of downdraft detrainemnt layer
           ,kstabi_cap                    & ! cloud stable layer base
           ,kstabm_cap                    & ! cloud stable layer top
           ,klnb_cap                      & ! Level of neutral buoyancy
           ,ktop_cap                      ! ! cloud top
      real   , pointer, dimension(:)   :: &
            pwav_cap                      & ! Integrated condensation             [  kg/kg]
           ,pwev_cap                      & ! Integrated evaporation              [  kg/kg]
           ,dnmf_cap                      & ! Reference downdraft mass flux       [    m/s]
           ,upmf_cap                      & ! Reference updraft mass flux         [    m/s]
           ,areadn_cap                    & ! Downdraft relative area             [    ---]
           ,areaup_cap                    & ! Updraft relative area               [    ---]
           ,wdndraft_cap                  & ! Downdraft velocity at LOD           [    m/s]
           ,wupdraft_cap                  & ! Updraft velocity at LOU             [    m/s]
           ,wbuoymin_cap                  ! ! Minimum buoyant velocity            [    m/s]
      !------------------------------------------------------------------------------------!


      !------------------------------------------------------------------------------------!
      !     These variables depend on the static control level, and they must be saved     !
      ! here in order to compute the proper dynamic control and feedback.                  !
      !------------------------------------------------------------------------------------!
      real, pointer, dimension(:,:) ::   &
            cdd_cap                      & ! normalised downdraft detrainment rate  [  ---]
           ,cdu_cap                      & ! normalised updraft detrainment rate    [  ---]
           ,mentrd_rate_cap              & ! normalised downdraft entrainment rate  [  ---]
           ,mentru_rate_cap              & ! normalised updraft entrainment rate    [  ---]
           ,dbyd_cap                     & ! Buoyancy associated with downdrafts    [ m/s�]
           ,dbyu_cap                     & ! Buoyancy associated with updrafts      [ m/s�]
           ,etad_cld_cap                 & ! normalised downdraft mass flux         [  ---]
           ,etau_cld_cap                 & ! normalised updraft mass flux           [  ---]
           ,rhod_cld_cap                 & ! Downdraft density                      [kg/m�]
           ,rhou_cld_cap                 & ! Updraft density                        [kg/m�]
           ,qliqd_cld_cap                & ! Liquid water mixing ratio at downdraft [kg/kg]
           ,qliqu_cld_cap                & ! Liquid water mixing ratio at updraft   [kg/kg]
           ,qiced_cld_cap                & ! Ice mixing ratio at downdraft          [kg/kg]
           ,qiceu_cld_cap                ! ! Ice mixing ratio at updraft            [kg/kg]
      !------------------------------------------------------------------------------------!


      real, pointer, dimension(:)     :: &
            outco2                       & ! CO2 mixing ratio tendency           [   ppm/s]
           ,outqtot                      & ! Total water mixing ratio tendency   [ kg/kg/s]
           ,outthil                      ! ! Ice-liquid pot. temperature tendency[     K/s]  

      !------------------------------------------------------------------------------------!
      !      Scalars, for dynamic control ensemble calculation and feedback.               !
      !------------------------------------------------------------------------------------!
      real, pointer, dimension(:) :: prev_dnmf ! Dndraft mass flux last time      [kg/m�/s]
      real, pointer, dimension(:) :: precip    ! Precipitation rate               [kg/m�/s]

   end type ensemble_vars

   type(ensemble_vars), allocatable, dimension(:) :: ensemble_e
   !=======================================================================================!
   !=======================================================================================!


   contains



   !=======================================================================================!
   !=======================================================================================!
   subroutine alloc_ensemble(ensemble,nclouds,mgmzp,maxens_dyn,maxens_lsf,maxens_eff       &
                            ,maxens_cap)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      type(ensemble_vars), intent(inout) :: ensemble
      integer            , intent(in)    :: mgmzp
      integer            , intent(in)    :: nclouds
      integer            , intent(in)    :: maxens_dyn
      integer            , intent(in)    :: maxens_lsf
      integer            , intent(in)    :: maxens_eff
      integer            , intent(in)    :: maxens_cap
      !----- Local variables. -------------------------------------------------------------!
      integer                            :: iscal
      !------------------------------------------------------------------------------------!

      allocate (ensemble%dnmf_ens       (maxens_dyn,maxens_lsf,maxens_eff,maxens_cap))
      allocate (ensemble%upmf_ens       (maxens_dyn,maxens_lsf,maxens_eff,maxens_cap))
      allocate (ensemble%dnmx_ens       (maxens_dyn,maxens_lsf,maxens_eff,maxens_cap))
      allocate (ensemble%upmx_ens       (maxens_dyn,maxens_lsf,maxens_eff,maxens_cap))

      allocate (ensemble%x_aatot        (nclouds   ,maxens_lsf,maxens_eff,maxens_cap))

      allocate (ensemble%edt_eff                              (maxens_eff,maxens_cap))
      allocate (ensemble%aatot_eff                            (maxens_eff,maxens_cap))
      allocate (ensemble%aatot0_eff                           (maxens_eff,maxens_cap))

      allocate (ensemble%dellathil_eff                  (mgmzp,maxens_eff,maxens_cap))
      allocate (ensemble%dellatheiv_eff                 (mgmzp,maxens_eff,maxens_cap))
      allocate (ensemble%dellaqtot_eff                  (mgmzp,maxens_eff,maxens_cap))
      allocate (ensemble%dellaco2_eff                   (mgmzp,maxens_eff,maxens_cap))
      allocate (ensemble%pw_eff                         (mgmzp,maxens_eff,maxens_cap))

      allocate (ensemble%ierr_cap                                        (maxens_cap))
      allocate (ensemble%comp_down_cap                                   (maxens_cap))
      allocate (ensemble%klod_cap                                        (maxens_cap))
      allocate (ensemble%klou_cap                                        (maxens_cap))
      allocate (ensemble%klcl_cap                                        (maxens_cap))
      allocate (ensemble%klfc_cap                                        (maxens_cap))
      allocate (ensemble%kdet_cap                                        (maxens_cap))
      allocate (ensemble%kstabi_cap                                      (maxens_cap))
      allocate (ensemble%kstabm_cap                                      (maxens_cap))
      allocate (ensemble%klnb_cap                                        (maxens_cap))
      allocate (ensemble%ktop_cap                                        (maxens_cap))

      allocate (ensemble%pwav_cap                                        (maxens_cap))
      allocate (ensemble%pwev_cap                                        (maxens_cap))
      allocate (ensemble%dnmf_cap                                        (maxens_cap))
      allocate (ensemble%upmf_cap                                        (maxens_cap))
      allocate (ensemble%areadn_cap                                      (maxens_cap))
      allocate (ensemble%areaup_cap                                      (maxens_cap))
      allocate (ensemble%wdndraft_cap                                    (maxens_cap))
      allocate (ensemble%wupdraft_cap                                    (maxens_cap))
      allocate (ensemble%wbuoymin_cap                                    (maxens_cap))

      allocate (ensemble%cdd_cap                        (mgmzp           ,maxens_cap))
      allocate (ensemble%cdu_cap                        (mgmzp           ,maxens_cap))
      allocate (ensemble%mentrd_rate_cap                (mgmzp           ,maxens_cap))
      allocate (ensemble%mentru_rate_cap                (mgmzp           ,maxens_cap))
      allocate (ensemble%dbyd_cap                       (mgmzp           ,maxens_cap))
      allocate (ensemble%dbyu_cap                       (mgmzp           ,maxens_cap))
      allocate (ensemble%etad_cld_cap                   (mgmzp           ,maxens_cap))
      allocate (ensemble%etau_cld_cap                   (mgmzp           ,maxens_cap))
      allocate (ensemble%rhod_cld_cap                   (mgmzp           ,maxens_cap))
      allocate (ensemble%rhou_cld_cap                   (mgmzp           ,maxens_cap))
      allocate (ensemble%qliqd_cld_cap                  (mgmzp           ,maxens_cap))
      allocate (ensemble%qliqu_cld_cap                  (mgmzp           ,maxens_cap))
      allocate (ensemble%qiced_cld_cap                  (mgmzp           ,maxens_cap))
      allocate (ensemble%qiceu_cld_cap                  (mgmzp           ,maxens_cap))

      allocate (ensemble%outqtot                        (mgmzp)                      )
      allocate (ensemble%outthil                        (mgmzp)                      )
      allocate (ensemble%outco2                         (mgmzp)                      )


      allocate (ensemble%prev_dnmf                      (    1)                      )
      allocate (ensemble%precip                         (    1)                      )
      return
   end subroutine alloc_ensemble
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   subroutine nullify_ensemble(ensemble)

      implicit none
      type(ensemble_vars) :: ensemble

      nullify(ensemble%dnmf_ens       )
      nullify(ensemble%upmf_ens       )
      nullify(ensemble%dnmx_ens       )
      nullify(ensemble%upmx_ens       )

      nullify(ensemble%x_aatot        )

      nullify(ensemble%edt_eff        )
      nullify(ensemble%aatot0_eff     )
      nullify(ensemble%aatot_eff      )

      nullify(ensemble%dellatheiv_eff )
      nullify(ensemble%dellathil_eff  )
      nullify(ensemble%dellaqtot_eff  )
      nullify(ensemble%dellaco2_eff   )
      nullify(ensemble%pw_eff         )

      nullify(ensemble%ierr_cap       )
      nullify(ensemble%comp_down_cap  )
      nullify(ensemble%klod_cap       )
      nullify(ensemble%klou_cap       )
      nullify(ensemble%klcl_cap       )
      nullify(ensemble%klfc_cap       )
      nullify(ensemble%kdet_cap       )
      nullify(ensemble%kstabi_cap     )
      nullify(ensemble%kstabm_cap     )
      nullify(ensemble%klnb_cap       )
      nullify(ensemble%ktop_cap       )
      nullify(ensemble%pwav_cap       )
      nullify(ensemble%pwev_cap       )
      nullify(ensemble%dnmf_cap       )
      nullify(ensemble%upmf_cap       )
      nullify(ensemble%areadn_cap     )
      nullify(ensemble%areaup_cap     )
      nullify(ensemble%wdndraft_cap   )
      nullify(ensemble%wupdraft_cap   )
      nullify(ensemble%wbuoymin_cap   )


      nullify(ensemble%cdd_cap        )
      nullify(ensemble%cdu_cap        )
      nullify(ensemble%mentrd_rate_cap)
      nullify(ensemble%mentru_rate_cap)
      nullify(ensemble%dbyd_cap       )
      nullify(ensemble%dbyu_cap       )
      nullify(ensemble%etad_cld_cap   )
      nullify(ensemble%etau_cld_cap   )
      nullify(ensemble%rhod_cld_cap   )
      nullify(ensemble%rhou_cld_cap   )
      nullify(ensemble%qliqd_cld_cap  )
      nullify(ensemble%qliqu_cld_cap  )
      nullify(ensemble%qiced_cld_cap  )
      nullify(ensemble%qiceu_cld_cap  )


      nullify(ensemble%outco2         )
      nullify(ensemble%outqtot        )
      nullify(ensemble%outthil        )

      nullify(ensemble%prev_dnmf      )
      nullify(ensemble%precip         )

      return
   end subroutine nullify_ensemble
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   subroutine dealloc_ensemble(ensemble)

      implicit none
      type(ensemble_vars) :: ensemble

      if(associated(ensemble%dnmf_ens       ))  deallocate(ensemble%dnmf_ens       )
      if(associated(ensemble%upmf_ens       ))  deallocate(ensemble%upmf_ens       )
      if(associated(ensemble%dnmx_ens       ))  deallocate(ensemble%dnmx_ens       )
      if(associated(ensemble%upmx_ens       ))  deallocate(ensemble%upmx_ens       )

      if(associated(ensemble%x_aatot        ))  deallocate(ensemble%x_aatot        )

      if(associated(ensemble%edt_eff        ))  deallocate(ensemble%edt_eff        )
      if(associated(ensemble%aatot0_eff     ))  deallocate(ensemble%aatot0_eff     )
      if(associated(ensemble%aatot_eff      ))  deallocate(ensemble%aatot_eff      )

      if(associated(ensemble%dellatheiv_eff ))  deallocate(ensemble%dellatheiv_eff )
      if(associated(ensemble%dellathil_eff  ))  deallocate(ensemble%dellathil_eff  )
      if(associated(ensemble%dellaqtot_eff  ))  deallocate(ensemble%dellaqtot_eff  )
      if(associated(ensemble%dellaco2_eff   ))  deallocate(ensemble%dellaco2_eff   )
      if(associated(ensemble%pw_eff         ))  deallocate(ensemble%pw_eff         )

      if(associated(ensemble%ierr_cap       ))  deallocate(ensemble%ierr_cap       )
      if(associated(ensemble%comp_down_cap  ))  deallocate(ensemble%comp_down_cap  )
      if(associated(ensemble%klod_cap       ))  deallocate(ensemble%klod_cap       )
      if(associated(ensemble%klou_cap       ))  deallocate(ensemble%klou_cap       )
      if(associated(ensemble%klcl_cap       ))  deallocate(ensemble%klcl_cap       )
      if(associated(ensemble%klfc_cap       ))  deallocate(ensemble%klfc_cap       )
      if(associated(ensemble%kdet_cap       ))  deallocate(ensemble%kdet_cap       )
      if(associated(ensemble%kstabi_cap     ))  deallocate(ensemble%kstabi_cap     )
      if(associated(ensemble%kstabm_cap     ))  deallocate(ensemble%kstabm_cap     )
      if(associated(ensemble%klnb_cap       ))  deallocate(ensemble%klnb_cap       )
      if(associated(ensemble%ktop_cap       ))  deallocate(ensemble%ktop_cap       )
      if(associated(ensemble%pwav_cap       ))  deallocate(ensemble%pwav_cap       )
      if(associated(ensemble%pwev_cap       ))  deallocate(ensemble%pwev_cap       )
      if(associated(ensemble%dnmf_cap       ))  deallocate(ensemble%dnmf_cap       )
      if(associated(ensemble%upmf_cap       ))  deallocate(ensemble%upmf_cap       )
      if(associated(ensemble%areadn_cap     ))  deallocate(ensemble%areadn_cap     )
      if(associated(ensemble%areaup_cap     ))  deallocate(ensemble%areaup_cap     )
      if(associated(ensemble%wdndraft_cap   ))  deallocate(ensemble%wdndraft_cap   )
      if(associated(ensemble%wupdraft_cap   ))  deallocate(ensemble%wupdraft_cap   )
      if(associated(ensemble%wbuoymin_cap   ))  deallocate(ensemble%wbuoymin_cap   )


      if(associated(ensemble%cdd_cap        ))  deallocate(ensemble%cdd_cap        )
      if(associated(ensemble%cdu_cap        ))  deallocate(ensemble%cdu_cap        )
      if(associated(ensemble%mentrd_rate_cap))  deallocate(ensemble%mentrd_rate_cap)
      if(associated(ensemble%mentru_rate_cap))  deallocate(ensemble%mentru_rate_cap)
      if(associated(ensemble%dbyd_cap       ))  deallocate(ensemble%dbyd_cap       )
      if(associated(ensemble%dbyu_cap       ))  deallocate(ensemble%dbyu_cap       )
      if(associated(ensemble%etad_cld_cap   ))  deallocate(ensemble%etad_cld_cap   )
      if(associated(ensemble%etau_cld_cap   ))  deallocate(ensemble%etau_cld_cap   )
      if(associated(ensemble%rhod_cld_cap   ))  deallocate(ensemble%rhod_cld_cap   )
      if(associated(ensemble%rhou_cld_cap   ))  deallocate(ensemble%rhou_cld_cap   )
      if(associated(ensemble%qliqd_cld_cap  ))  deallocate(ensemble%qliqd_cld_cap  )
      if(associated(ensemble%qliqu_cld_cap  ))  deallocate(ensemble%qliqu_cld_cap  )
      if(associated(ensemble%qiced_cld_cap  ))  deallocate(ensemble%qiced_cld_cap  )
      if(associated(ensemble%qiceu_cld_cap  ))  deallocate(ensemble%qiceu_cld_cap  )


      if(associated(ensemble%outco2         ))  deallocate(ensemble%outco2         )
      if(associated(ensemble%outqtot        ))  deallocate(ensemble%outqtot        )
      if(associated(ensemble%outthil        ))  deallocate(ensemble%outthil        )

      if(associated(ensemble%prev_dnmf      ))  deallocate(ensemble%prev_dnmf      )
      if(associated(ensemble%precip         ))  deallocate(ensemble%precip         )

      return
   end subroutine dealloc_ensemble
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   subroutine zero_ensemble(ensemble)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      type(ensemble_vars), intent(inout) :: ensemble
      !------------------------------------------------------------------------------------!

      if(associated(ensemble%dnmf_ens       ))  ensemble%dnmf_ens        = 0.
      if(associated(ensemble%upmf_ens       ))  ensemble%upmf_ens        = 0.
      if(associated(ensemble%dnmx_ens       ))  ensemble%dnmx_ens        = 0.
      if(associated(ensemble%upmx_ens       ))  ensemble%upmx_ens        = 0.

      if(associated(ensemble%x_aatot        ))  ensemble%x_aatot         = 0.

      if(associated(ensemble%edt_eff        ))  ensemble%edt_eff         = 0.
      if(associated(ensemble%aatot0_eff     ))  ensemble%aatot0_eff      = 0.
      if(associated(ensemble%aatot_eff      ))  ensemble%aatot_eff       = 0.

      if(associated(ensemble%dellatheiv_eff ))  ensemble%dellatheiv_eff  = 0.
      if(associated(ensemble%dellathil_eff  ))  ensemble%dellathil_eff   = 0.
      if(associated(ensemble%dellaqtot_eff  ))  ensemble%dellaqtot_eff   = 0.
      if(associated(ensemble%dellaco2_eff   ))  ensemble%dellaco2_eff    = 0.
      if(associated(ensemble%pw_eff         ))  ensemble%pw_eff          = 0.

      if(associated(ensemble%ierr_cap       ))  ensemble%ierr_cap        = 1      ! Integer
      if(associated(ensemble%comp_down_cap  ))  ensemble%comp_down_cap   = .true. ! Logical
      if(associated(ensemble%klod_cap       ))  ensemble%klod_cap        = 0
      if(associated(ensemble%klou_cap       ))  ensemble%klou_cap        = 0
      if(associated(ensemble%klcl_cap       ))  ensemble%klcl_cap        = 0
      if(associated(ensemble%klfc_cap       ))  ensemble%klfc_cap        = 0
      if(associated(ensemble%kdet_cap       ))  ensemble%kdet_cap        = 0
      if(associated(ensemble%kstabi_cap     ))  ensemble%kstabi_cap      = 0
      if(associated(ensemble%kstabm_cap     ))  ensemble%kstabm_cap      = 0
      if(associated(ensemble%klnb_cap       ))  ensemble%klnb_cap        = 0
      if(associated(ensemble%ktop_cap       ))  ensemble%ktop_cap        = 0

      if(associated(ensemble%pwav_cap       ))  ensemble%pwav_cap        = 0.
      if(associated(ensemble%pwev_cap       ))  ensemble%pwev_cap        = 0.
      if(associated(ensemble%dnmf_cap       ))  ensemble%dnmf_cap        = 0.
      if(associated(ensemble%upmf_cap       ))  ensemble%upmf_cap        = 0.
      if(associated(ensemble%areadn_cap     ))  ensemble%areadn_cap      = 0.
      if(associated(ensemble%areaup_cap     ))  ensemble%areaup_cap      = 0.
      if(associated(ensemble%wdndraft_cap   ))  ensemble%wdndraft_cap    = 0.
      if(associated(ensemble%wupdraft_cap   ))  ensemble%wupdraft_cap    = 0.
      if(associated(ensemble%wbuoymin_cap   ))  ensemble%wbuoymin_cap    = 0.

      if(associated(ensemble%cdd_cap        ))  ensemble%cdd_cap         = 0.
      if(associated(ensemble%cdu_cap        ))  ensemble%cdu_cap         = 0.
      if(associated(ensemble%mentrd_rate_cap))  ensemble%mentrd_rate_cap = 0.
      if(associated(ensemble%mentru_rate_cap))  ensemble%mentru_rate_cap = 0.
      if(associated(ensemble%dbyd_cap       ))  ensemble%dbyd_cap        = 0.
      if(associated(ensemble%dbyu_cap       ))  ensemble%dbyu_cap        = 0.
      if(associated(ensemble%etad_cld_cap   ))  ensemble%etad_cld_cap    = 0.
      if(associated(ensemble%etau_cld_cap   ))  ensemble%etau_cld_cap    = 0.
      if(associated(ensemble%rhod_cld_cap   ))  ensemble%rhod_cld_cap    = 0.
      if(associated(ensemble%rhou_cld_cap   ))  ensemble%rhou_cld_cap    = 0.
      if(associated(ensemble%qliqd_cld_cap  ))  ensemble%qliqd_cld_cap   = 0.
      if(associated(ensemble%qliqu_cld_cap  ))  ensemble%qliqu_cld_cap   = 0.
      if(associated(ensemble%qiced_cld_cap  ))  ensemble%qiced_cld_cap   = 0.
      if(associated(ensemble%qiceu_cld_cap  ))  ensemble%qiceu_cld_cap   = 0.

      if(associated(ensemble%outco2         ))  ensemble%outco2          = 0.
      if(associated(ensemble%outqtot        ))  ensemble%outqtot         = 0.
      if(associated(ensemble%outthil        ))  ensemble%outthil         = 0.

      !----- Real variables ----------------------------------------------------------------!
      if(associated(ensemble%prev_dnmf      ))  ensemble%prev_dnmf       = 0.
      if(associated(ensemble%precip         ))  ensemble%precip          = 0.
      !-------------------------------------------------------------------------------------!

      return
   end subroutine zero_ensemble
   !=======================================================================================!
   !=======================================================================================!
end module mem_ensemble
!==========================================================================================!
!==========================================================================================!
