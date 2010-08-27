!==========================================================================================!
!==========================================================================================!
!     This subroutine will control the photosynthesis scheme (Farquar and Leuning).  This  !
! is called every step, but not every sub-step.                                            !
!------------------------------------------------------------------------------------------!
subroutine canopy_photosynthesis(csite,ipa,vels,atm_tmp,prss,ed_ktrans,ntext_soil          &
                                   ,soil_water,soil_fracliq,lsl,sum_lai_rbi                &
                                   ,leaf_aging_factor,green_leaf_factor)
   use ed_state_vars         , only : sitetype           & ! structure
                                    , patchtype          ! ! structure
   use ed_max_dims           , only : n_pft              ! ! intent(in)
   use pft_coms              , only : leaf_width         & ! intent(in)
                                    , water_conductance  & ! intent(in)
                                    , q                  & ! intent(in)
                                    , qsw                & ! intent(in)
                                    , include_pft        ! ! intent(in)
   use grid_coms             , only : nzg                ! ! intent(in)
   use soil_coms             , only : soil               & ! intent(in)
                                    , dslz               ! ! intent(in)
   use consts_coms           , only : t00                & ! intent(in)
                                    , epi                & ! intent(in)
                                    , wdnsi              & ! intent(in)
                                    , wdns               & ! intent(in)
                                    , kgCday_2_umols     ! ! intent(in)
   use ed_misc_coms          , only : current_time       ! ! intent(in)
   implicit none
   !----- Arguments -----------------------------------------------------------------------!
   type(sitetype)            , target      :: csite             ! Current site
   integer, dimension(nzg)   , intent(in)  :: ntext_soil        ! Soil texture class
   integer                   , intent(in)  :: ipa               ! Current patch #
   integer                   , intent(in)  :: lsl               ! Lowest soil level
   real   , dimension(nzg)   , intent(in)  :: soil_water        ! Soil water
   real   , dimension(nzg)   , intent(in)  :: soil_fracliq      ! Soil liq. water fraction
   real                      , intent(in)  :: vels              ! Wind speed
   real                      , intent(in)  :: atm_tmp           ! Atm. temperature
   real                      , intent(in)  :: prss              ! Atmospheric pressure
   real   , dimension(n_pft) , intent(in)  :: leaf_aging_factor ! 
   real   , dimension(n_pft) , intent(in)  :: green_leaf_factor ! 
   integer, dimension(nzg)   , intent(out) :: ed_ktrans         ! 
   real                      , intent(out) :: sum_lai_rbi       ! 
   !----- Local variables -----------------------------------------------------------------!
   type(patchtype)           , pointer     :: cpatch             ! Current site
   integer                                 :: ico                ! Current cohort #
   integer                                 :: tuco               ! Tallest used cohort
   integer                                 :: ipft
   integer                                 :: k1
   integer                                 :: k2
   integer                                 :: nts
   logical, dimension(nzg)                 :: root_depth_indices ! 
   logical                                 :: las
   real   , dimension(nzg)                 :: available_liquid_water
   real                                    :: leaf_resp
   real                                    :: mixrat
   real                                    :: parv_o_lai
   real                                    :: P_op
   real                                    :: P_cl
   real                                    :: slpotv
   real                                    :: swp
   real                                    :: water_demand
   real                                    :: water_supply
   real                                    :: broot_tot
   real                                    :: broot_loc
   real                                    :: pss_available_water
   real                                    :: can_co2_loc
   !----- Local constants -----------------------------------------------------------------!
   real   , parameter                      :: vels_min    = 1.0
   logical, parameter                      :: print_debug = .false.
   !----- Saved variables -----------------------------------------------------------------!
   logical, dimension(n_pft) , save        :: first_time=.true.
   !---------------------------------------------------------------------------------------!


   !----- Pointing to the cohort structures -----------------------------------------------!
   cpatch => csite%patch(ipa)

   !----- Finding the patch-level Total Leaf and Wood Area Index. -------------------------!
   csite%lai(ipa) = 0.0
   csite%wpa(ipa) = 0.0
   csite%wai(ipa) = 0.0
   do ico=1,cpatch%ncohorts
      csite%lai(ipa)  = csite%lai(ipa)  + cpatch%lai(ico)
      csite%wpa(ipa)  = csite%wpa(ipa)  + cpatch%wpa(ico)
      csite%wai(ipa)  = csite%wai(ipa)  + cpatch%wai(ico)
   end do


   !----- Compute local co2 mixing ratio (KLUGE!!!) ---------------------------------------!
   can_co2_loc = max(100.,csite%can_co2(ipa)-380.+278.)

   !----- Calculate liquid water available for transpiration. -----------------------------!
   available_liquid_water(nzg) = wdns * dslz(nzg) * soil_fracliq(nzg)                      &
                               * max(0.0, soil_water(nzg) - soil(ntext_soil(nzg))%soilwp )
   do k1 = nzg-1, lsl, -1
      available_liquid_water(k1) = available_liquid_water(k1+1)                            &
                                 + wdns * dslz(k1) * soil_fracliq(k1)                      &
                                 * max(0.0, soil_water(k1) - soil(ntext_soil(k1))%soilwp )
   end do
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   !     Initialize the array of maximum photosynthesis rates used in the mortality        !
   ! function.                                                                             !
   !---------------------------------------------------------------------------------------!
   csite%A_o_max(1:n_pft,ipa) = 0.0
   csite%A_c_max(1:n_pft,ipa) = 0.0

   !---------------------------------------------------------------------------------------!
   !     Find the tallest cohort with TAI above minimum, sufficient heat capacity, and not !
   ! buried in snow.  The first two conditions are redundant, but we will keep them for    !
   ! the time being, so it is going to be safer.                                           !
   !---------------------------------------------------------------------------------------!
   las = .false.
   do ico = 1,cpatch%ncohorts
      !----- If this is the tallest cohort to be used, we save its index. -----------------!
      if (.not. las .and. cpatch%solvable(ico)) then
         las  = .true.
         tuco = ico
      end if
   end do

   !---------------------------------------------------------------------------------------!
   !---------------------------------------------------------------------------------------!
   !    There is at least one cohort that meet requirements.  And this is tallest one, so  !
   ! we can use it to compute the maximum photosynthetic rates, i.e., the rate the cohort  !
   ! would have if it were at the top of the canopy.  This is used for the mortality       !
   ! function.                                                                             !
   !---------------------------------------------------------------------------------------!
   if (las) then
      !----- We now loop over PFTs, not cohorts, skipping those we are not using. ---------!
      do ipft = 1, n_pft
         if (include_pft(ipft) == 1)then

            !------------------------------------------------------------------------------!
            !    Convert specific humidity to mixing ratio.  I am not sure about this one, !
            ! if we should convert here to mixing ratio, or convert everything inside to   !
            ! specific humidity.  Also, scale photosynthetically active radiation per unit !
            ! of leaf.                                                                     !
            !------------------------------------------------------------------------------!
            mixrat     = csite%can_shv(ipa) / (1. - csite%can_shv(ipa))
            parv_o_lai = cpatch%par_v(tuco) / cpatch%lai(tuco)

            !----- Calling the photosynthesis for maximum photosynthetic rates. -----------!
            call lphysiol_full(            & !
                 cpatch%veg_temp(tuco)-t00 & ! Vegetation temperature       [           �C]
               , mixrat*epi                & ! Vapour mixing ratio          [      mol/mol]
               , can_co2_loc*1e-6   & ! CO2 mixing ratio             [      mol/mol]
               , parv_o_lai                & ! Absorbed PAR                 [ Ein/m�leaf/s]
               , cpatch%rb(tuco)           & ! Aerodynamic resistance       [          s/m]
               , csite%can_rhos(ipa)       & ! Air density                  [        kg/m�]
               , csite%A_o_max(ipft,ipa)   & ! Max. open photosynth. rate   [�mol/m�leaf/s]
               , csite%A_c_max(ipft,ipa)   & ! Max. closed photosynth. rate [�mol/m�leaf/s]
               , P_op                      & ! Open stomata res. for water  [          s/m]
               , P_cl                      & ! Closed stomata res. for water[          s/m]
               , ipft                      & ! PFT                          [         ----]
               , csite%can_prss(ipa)       & ! Pressure                     [         N/m�]
               , leaf_resp                 & ! Leaf respiration rate        [�mol/m�leaf/s]
               , green_leaf_factor(ipft)   & ! Fraction of actual green leaves relative to 
                                           ! !      on-allometry value.
               , leaf_aging_factor(ipft)   &
               , csite%old_stoma_data_max(ipft,ipa) &
               , cpatch%llspan(tuco) &
               , cpatch%vm_bar(tuco))
         end if
      end do
         
   else
      !---- There is no "active" cohort. --------------------------------------------------!
      csite%A_o_max(1:n_pft,ipa) = 0.0
      csite%A_c_max(1:n_pft,ipa) = 0.0
   end if
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !    Initialize some variables.                                                         !
   !---------------------------------------------------------------------------------------!
   !----- LAI/rb, summed over all cohorts.  Used in the Euler scheme. ---------------------!
   sum_lai_rbi = 0.0
   !----- Total root biomass (in kgC/m2) and patch sum available water. -------------------!
   pss_available_water = 0.0
   broot_tot           = 0.0
   !----- Initialize variables for transpiration calculation. -----------------------------!
   root_depth_indices(:) = .false.
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   !    Loop over all cohorts, from tallest to shortest.                                   !
   !---------------------------------------------------------------------------------------!
   cohortloop: do ico = 1,cpatch%ncohorts
         
      !------------------------------------------------------------------------------------!
      !     Only need to worry about photosyn if radiative transfer has been  done for     !
      ! this cohort.                                                                       !
      !------------------------------------------------------------------------------------!
      if (cpatch%solvable(ico)) then

            !----- Alias for PFT ----------------------------------------------------------!
            ipft = cpatch%pft(ico)

            !----- Updating total LAI/RB --------------------------------------------------!
            sum_lai_rbi = sum_lai_rbi + cpatch%lai(ico) / cpatch%rb(ico)

            !------------------------------------------------------------------------------!
            !    Convert specific humidity to mixing ratio.  I am not sure about this one, !
            ! if we should convert here to mixing ratio, or convert everything inside to   !
            ! specific humidity.  Also, scale photosynthetically active radiation per unit !
            ! of leaf.                                                                     !
            !------------------------------------------------------------------------------!
            mixrat     = csite%can_shv(ipa) / (1. - csite%can_shv(ipa))
            parv_o_lai = cpatch%par_v(ico) / cpatch%lai(ico) 

            !----- Calling the photosynthesis for maximum photosynthetic rates. -----------!
            call lphysiol_full(            & !
                 cpatch%veg_temp(ico)-t00  & ! Vegetation temperature       [           �C]
               , mixrat*epi                & ! Vapour mixing ratio          [      mol/mol]
               , can_co2_loc*1e-6   & ! CO2 mixing ratio             [      mol/mol]
               , parv_o_lai                & ! Absorbed PAR                 [ Ein/m�leaf/s]
               , cpatch%rb(ico)            & ! Aerodynamic resistance       [          s/m]
               , csite%can_rhos(ipa)       & ! Air density                  [        kg/m�]
               , cpatch%A_open(ico)        & ! Max. open photosynth. rate   [�mol/m�leaf/s]
               , cpatch%A_closed(ico)      & ! Max. closed photosynth. rate [�mol/m�leaf/s]
               , cpatch%rsw_open(ico)      & ! Open stomata res. for water  [          s/m]
               , cpatch%rsw_closed(ico)    & ! Closed stomata res. for water[          s/m]
               , ipft                      & ! PFT                          [         ----]
               , csite%can_prss(ipa)       & ! Pressure                     [         N/m�]
               , leaf_resp                 & ! Leaf respiration rate        [�mol/m�leaf/s]
               , green_leaf_factor(ipft)   & ! Fraction of actual green leaves relative to 
                                           ! !      on-allometry value.
               , leaf_aging_factor(ipft)   &
               , cpatch%old_stoma_data(ico) &
               , cpatch%llspan(ico) &
               , cpatch%vm_bar(ico)) ! Type containing the exact stomatal deriv-
                                             !     atives and meteorological info

            !----- Leaf respiration, converting it to [�mol/m�ground/s] -------------------!
            cpatch%leaf_respiration(ico) = leaf_resp * cpatch%lai(ico)
            cpatch%mean_leaf_resp(ico)   = cpatch%mean_leaf_resp(ico)                      &
                                         + cpatch%leaf_respiration(ico)
            cpatch%today_leaf_resp(ico)  = cpatch%today_leaf_resp(ico)                     &
                                         + cpatch%leaf_respiration(ico)

            !----- Demand for water [kg/m2/s].  Psi_open is from last time step. ----------!
            water_demand = cpatch%Psi_open(ico)

            !----- Supply of water. -------------------------------------------------------!
            water_supply = water_conductance(ipft)                                         &
                         * available_liquid_water(cpatch%krdepth(ico)) * wdnsi             &
                         * q(ipft) * cpatch%balive(ico)                                    &
                         / (1.0 + q(ipft) + cpatch%hite(ico) * qsw(ipft) )                 &
                         * cpatch%nplant(ico)

            root_depth_indices(cpatch%krdepth(ico)) = .true.

            broot_loc = q(ipft) * cpatch%balive(ico)                                       &
                      / (1.0 + q(ipft) + cpatch%hite(ico) * qsw(ipft) )                    &
                      * cpatch%nplant(ico)
            broot_tot = broot_tot + broot_loc
            pss_available_water = pss_available_water                                      &
                                + available_liquid_water(cpatch%krdepth(ico)) * broot_loc

            !----- Weighting between open/closed stomata. ---------------------------------!
            cpatch%fsw(ico) = water_supply / max(1.0e-30,water_supply + water_demand)


            !------------------------------------------------------------------------------!
            !      Photorespiration can become important at high temperatures.  If so,     !
            ! close down the stomata.                                                      !
            !------------------------------------------------------------------------------!
            if (cpatch%A_open(ico) < cpatch%A_closed(ico)) then
               cpatch%fs_open(ico) = 0.0
            else
               cpatch%fs_open(ico) = cpatch%fsw(ico) * cpatch%fsn(ico)
            end if

            !----- Net stomatal resistance. -----------------------------------------------!
            cpatch%stomatal_resistance(ico) = 1.0                                          &
                                            / ( cpatch%fs_open(ico)/cpatch%rsw_open(ico)   &
                                              + (1.0 - cpatch%fs_open(ico))                &
                                                / cpatch%rsw_closed(ico) )

            !----- GPP, averaged over frqstate. -------------------------------------------!
            cpatch%gpp(ico)       = cpatch%lai(ico)                                        &
                                  * ( cpatch%fs_open(ico) * cpatch%A_open(ico)             &
                                    + (1.0 - cpatch%fs_open(ico)) * cpatch%A_closed(ico) ) &
                                  + cpatch%leaf_respiration(ico)
            cpatch%mean_gpp(ico)  = cpatch%mean_gpp(ico) + cpatch%gpp(ico)

            !----- GPP, summed over 1 day. [�mol/m�ground] --------------------------------!
            cpatch%today_gpp(ico) = cpatch%today_gpp(ico) + cpatch%gpp(ico)

            !----- Potential GPP if no N limitation. [�mol/m�ground] ----------------------!
            cpatch%today_gpp_pot(ico) = cpatch%today_gpp_pot(ico)                          &
                                      + cpatch%lai(ico)                                    &
                                      * ( cpatch%fsw(ico) * cpatch%A_open(ico)             &
                                        + (1.0 - cpatch%fsw(ico)) * cpatch%A_closed(ico))  &
                                      + cpatch%leaf_respiration(ico)

            !----- Maximum GPP if at the top of the canopy [�mol/m�ground] ----------------!
            cpatch%today_gpp_max(ico) = cpatch%today_gpp_max(ico)                          &
                                      + cpatch%lai(ico)                                    &
                                      * ( cpatch%fs_open(ico) * csite%A_o_max(ipft,ipa)    &
                                        + (1.0 - cpatch%fs_open(ico))                      &
                                          * csite%A_c_max(ipft,ipa))                       &
                                      + cpatch%leaf_respiration(ico)

      else
         !----- If the cohort wasn't solved, we must assign some zeroes. ------------------!
         cpatch%A_open(ico)              = 0.0
         cpatch%A_closed(ico)            = 0.0
         cpatch%Psi_open(ico)            = 0.0
         cpatch%Psi_closed(ico)          = 0.0
         cpatch%rsw_open(ico)            = 0.0
         cpatch%rsw_closed(ico)          = 0.0
         cpatch%rb(ico)                  = 0.0
         cpatch%stomatal_resistance(ico) = 0.0
         cpatch%gpp(ico)                 = 0.0
         cpatch%leaf_respiration(ico)    = 0.0
      end if
      
      !------------------------------------------------------------------------------------!
      !    Not really a part of the photosynthesis scheme, but this will do it.  We must   !
      ! integrate the "mean" of the remaining respiration terms, except for the root one.  !
      ! This is done regardless on whether the cohort is doing photosynthesis.  Also, we   !
      ! convert units so all fast respiration terms are in [�mol/m�ground/s].              !
      !------------------------------------------------------------------------------------!
      cpatch%mean_growth_resp (ico) = cpatch%mean_growth_resp (ico)                        &
                                    + cpatch%growth_respiration (ico) * kgCday_2_umols     &
                                    * cpatch%nplant(ico)
      cpatch%mean_storage_resp(ico) = cpatch%mean_storage_resp(ico)                        &
                                    + cpatch%storage_respiration(ico) * kgCday_2_umols     &
                                    * cpatch%nplant(ico)
      cpatch%mean_vleaf_resp  (ico) = cpatch%mean_vleaf_resp  (ico)                        &
                                    + cpatch%vleaf_respiration  (ico) * kgCday_2_umols     &
                                    * cpatch%nplant(ico)                                    
      !------------------------------------------------------------------------------------!
   end do cohortloop

   !---------------------------------------------------------------------------------------!
   !     Add the contribution of this time step to the average available water.            !
   !---------------------------------------------------------------------------------------!
   if (broot_tot > 1.e-20) then
      csite%avg_available_water(ipa) = csite%avg_available_water(ipa)                      &
                                     + pss_available_water / broot_tot
   !else
   !  Add nothing, the contribution of this time is zero since no cohort can transpire... 
   end if

   !---------------------------------------------------------------------------------------!
   !     For plants of a given rooting depth, determine soil level from which transpired   !
   ! water is to be extracted.                                                             !
   !---------------------------------------------------------------------------------------!
   ed_ktrans(:) = 0
   do k1 = lsl, nzg
      !---- Assign a very large negative, so it will update it at least once. -------------!
      swp = -huge(1.)
      if (root_depth_indices(k1)) then
         do k2 = k1, nzg
            nts = ntext_soil(k2)
            !------------------------------------------------------------------------------!
            !      Find slpotv using the available liquid water, since ice is unavailable  !
            ! for transpiration.                                                           !
            !------------------------------------------------------------------------------!
            slpotv = soil(nts)%slpots * soil_fracliq(k2)                                   &
                   * (soil(nts)%slmsts / soil_water(k2)) ** soil(nts)%slbs

            !------------------------------------------------------------------------------!
            !      Find layer in root zone with highest slpotv AND soil_water above        !
            ! minimum soilwp.  Set ktrans to this layer.                                   !
            !------------------------------------------------------------------------------!
            if (slpotv > swp .and. soil_water(k2) > soil(nts)%soilwp) then
               swp = slpotv
               ed_ktrans(k1) = k2
            end if
         end do
      end if
   end do

   !---------------------------------------------------------------------------------------!
   ! Printing debugging stuff                                                              !
   !---------------------------------------------------------------------------------------!
   if (print_debug) then
      do ico=1,cpatch%ncohorts
         ipft=cpatch%pft(ico)
         if (first_time(ipft)) then
            write(unit=80+ipft,fmt='(356a)') ('-',k1=1,356)
            write(unit=80+ipft,fmt='(28(a,1x))') '     CURRENT_TIME','PFT'                 &
             ,'      NPLANT','       BLEAF','         LAI','         WAI','     HCAPVEG'   &
             ,'   VEG_WATER','    VEG_TEMP',' CAN_MIX_RAT','    CAN_TEMP','    AIR_TEMP'   &
             ,'    PRESSURE','    CAN_RHOS','       PAR_V','         GPP','   LEAF_RESP'   &
             ,'          RB',' STOM_RESIST','      A_OPEN','    A_CLOSED','    RSW_OPEN'   &
             ,'  RSW_CLOSED','    PSI_OPEN','  PSI_CLOSED','         FSW','         FSN'   &
             ,'     FS_OPEN'
             
            write(unit=80+ipft,fmt='(356a)') ('-',k1=1,356)
            first_time(ipft)=.false.
         end if
         write(unit=80+ipft,fmt='(i4.4,2(a,i2.2),1x,f6.0,1x,i3,26(1x,es12.5))')            &
            current_time%year,'-',current_time%month,'-',current_time%date                 &
           ,current_time%time,cpatch%pft(ico),cpatch%nplant(ico),cpatch%bleaf(ico)         &
           ,cpatch%lai(ico),cpatch%wai(ico),cpatch%hcapveg(ico),cpatch%veg_water(ico)      &
           ,cpatch%veg_temp(ico),csite%can_shv(ipa),csite%can_temp(ipa),atm_tmp,prss       &
           ,csite%can_rhos(ipa),cpatch%par_v(ico),cpatch%gpp(ico)                          &
           ,cpatch%leaf_respiration(ico),cpatch%rb(ico),cpatch%stomatal_resistance(ico)    &
           ,cpatch%A_open(ico),cpatch%A_closed(ico),cpatch%rsw_open(ico)                   &
           ,cpatch%rsw_closed(ico),cpatch%Psi_open(ico),cpatch%Psi_closed(ico)             &
           ,cpatch%fsw(ico),cpatch%fsn(ico),cpatch%fs_open(ico)
      end do
   end if

   return
end subroutine canopy_photosynthesis
