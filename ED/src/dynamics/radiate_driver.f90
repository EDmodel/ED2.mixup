!==========================================================================================!
!==========================================================================================!
!     This subroutine will control the two-stream radiation scheme.  This is called every  !
! step, but not every sub-step.                                                            !
!------------------------------------------------------------------------------------------!
subroutine radiate_driver(cgrid)
   use ed_misc_coms          , only : current_time          & ! intent(in)
                                    , radfrq                & ! intent(in)
                                    , dtlsm                 ! ! intent(in)
   use ed_state_vars         , only : edtype                & ! structure
                                    , polygontype           & ! structure
                                    , sitetype              & ! structure
                                    , patchtype             ! ! structure
   use canopy_radiation_coms , only : par_beam_norm         & ! intent(in)
                                    , par_diff_norm         & ! intent(in)
                                    , nir_beam_norm         & ! intent(in)
                                    , nir_diff_norm         & ! intent(in)
                                    , cosz_min              & ! intent(in)
                                    , rshort_twilight_min   ! ! intent(in)
   use consts_coms           , only : pio180                ! ! intent(in)
   use grid_coms             , only : nzg                   & ! intent(in)
                                    , nzs                   ! ! intent(in)
   implicit none
   !----- Argument. -----------------------------------------------------------------------!
   type(edtype)     , target   :: cgrid
   !----- Local variables. ----------------------------------------------------------------!
   type(polygontype), pointer  :: cpoly
   type(sitetype)   , pointer  :: csite
   type(patchtype)  , pointer  :: cpatch
   real                        :: rshort_tot
   integer                     :: maxcohort
   integer                     :: ipy
   integer                     :: isi
   integer                     :: ipa
   integer                     :: tuco
   logical                     :: daytime
   logical                     :: twilight
   real                        :: hrangl
   real                        :: sloperad
   real                        :: aspectrad
   real                        :: sum_norm
   !----- External functions. -------------------------------------------------------------!
   real             , external :: ed_zen
   !---------------------------------------------------------------------------------------!


   !----- Check whether it is time to update radiative fluxes and heating rates -----------!
   if (mod(current_time%time + .001,radfrq) < dtlsm) then

      !----- Loop over polygons and sites. ------------------------------------------------!

      polyloop: do ipy = 1,cgrid%npolygons

         !----- Find the solar zenith angle [cosz] -----------------------------------------!
         cgrid%cosz(ipy) = ed_zen(cgrid%lon(ipy),cgrid%lat(ipy),current_time)
         !---------------------------------------------------------------------------------!

         cpoly => cgrid%polygon(ipy)

         siteloop: do isi = 1,cpoly%nsites

            csite => cpoly%site(isi)

            !------------------------------------------------------------------------------!
            !     Update angle of incidence.                                               !
            !------------------------------------------------------------------------------!
            hrangl    = 15. * pio180                                                       &
                      * (mod(current_time%time + cgrid%lon(ipy) / 15. + 24., 24.) - 12.)
            sloperad  = cpoly%slope(isi)  * pio180
            aspectrad = cpoly%aspect(isi) * pio180
            call angle_of_incid(cpoly%cosaoi(isi),cgrid%cosz(ipy),hrangl                   &
                               ,sloperad,aspectrad)
            !------------------------------------------------------------------------------!


            !------------------------------------------------------------------------------!
            !    Find the two logicals, that will tell which part of the day we are at     !
            ! least.                                                                       !
            !------------------------------------------------------------------------------!
            daytime  = cpoly%cosaoi(isi) > cosz_min .and.                                  &
                       cpoly%met(isi)%rshort > rshort_twilight_min
            twilight = cpoly%met(isi)%rshort > rshort_twilight_min
            !------------------------------------------------------------------------------!




            !------------------------------------------------------------------------------!
            !      In case the angle of incidence is too high (i.e., its cosine is too     !
            ! close to zero), eliminate all direct radiation.   This is different from the !
            ! cosine of the zenith angle because mountains can hide the sun even when it   !
            ! is still above the horizon.                                                  !
            !------------------------------------------------------------------------------!
            if (daytime) then
               rshort_tot    = cpoly%met(isi)%rshort
               par_beam_norm = max( 1.d-5 , dble(cpoly%met(isi)%par_beam   )               &
                                          / dble(cpoly%met(isi)%rshort     ) )
               par_diff_norm = max( 1.d-5 , dble(cpoly%met(isi)%par_diffuse)               &
                                          / dble(cpoly%met(isi)%rshort     ) )
               nir_beam_norm = max( 1.d-5 , dble(cpoly%met(isi)%nir_beam   )               &
                                          / dble(cpoly%met(isi)%rshort     ) )
               nir_diff_norm = max( 1.d-5 , dble(cpoly%met(isi)%nir_diffuse)               &
                                          / dble(cpoly%met(isi)%rshort     ) )
               sum_norm      = par_beam_norm + par_diff_norm                               &
                             + nir_beam_norm + nir_diff_norm
            elseif (twilight) then
               rshort_tot    = cpoly%met(isi)%rshort_diffuse
               par_beam_norm = 1.d-5
               par_diff_norm = 1.d-5
               nir_beam_norm = max(1.d-5, dble(cpoly%met(isi)%nir_beam   )                 &
                                        / dble(cpoly%met(isi)%rshort     ) )
               nir_diff_norm = max(1.d-5, dble(cpoly%met(isi)%nir_diffuse)                 &
                                        / dble(cpoly%met(isi)%rshort     ) )
               sum_norm      = par_beam_norm + par_diff_norm                               &
                             + nir_beam_norm + nir_diff_norm
            else 
               !---------------------------------------------------------------------------!
               !     Night-time, nothing will happen, fill split equally to the 4          !
               ! components.                                                               !
               !---------------------------------------------------------------------------!
               rshort_tot    = 0.0
               par_beam_norm = 2.5d-1
               par_diff_norm = 2.5d-1
               nir_beam_norm = 2.5d-1
               nir_diff_norm = 2.5d-1
               sum_norm      = 1.d0
            end if
            !------------------------------------------------------------------------------!
            !     Because we must tweak the radiation so none of the terms are zero, we    !
            ! must correct the normalised radiation variables so they add up to one.       !
            !------------------------------------------------------------------------------!
            par_beam_norm = par_beam_norm / sum_norm
            par_diff_norm = par_diff_norm / sum_norm
            nir_beam_norm = nir_beam_norm / sum_norm
            nir_diff_norm = nir_diff_norm / sum_norm
            !------------------------------------------------------------------------------!





            !------------------------------------------------------------------------------!
            !    Loop over subgrid-scale patches.  These routines can be done as arrays.   !
            !------------------------------------------------------------------------------!
            maxcohort = 1
            do ipa = 1,csite%npatches
               cpatch=>csite%patch(ipa)
               if ( cpatch%ncohorts>maxcohort ) maxcohort = cpatch%ncohorts
            end do
            !------------------------------------------------------------------------------!


            !----- Get unnormalized radiative transfer information. -----------------------!
            call sfcrad_ed(cgrid%cosz(ipy),cpoly%cosaoi(isi),csite,nzg,nzs                 &
                          ,cpoly%ntext_soil(:,isi),maxcohort,tuco                          &
                          ,rshort_tot,cpoly%met(isi)%rshort_diffuse,daytime,twilight)
            !------------------------------------------------------------------------------!



            !----- Normalize the absorbed radiations. -------------------------------------!
            call scale_ed_radiation(tuco,rshort_tot,cpoly%met(isi)%rshort_diffuse          &
                                   ,cpoly%met(isi)%rlong,csite)
            !------------------------------------------------------------------------------!

         end do siteloop
      end do polyloop

      !----- Update the average radiation for phenology. ----------------------------------!
      call update_rad_avg(cgrid)
      !------------------------------------------------------------------------------------!

   end if

   !---------------------------------------------------------------------------------------!
   !     At this point, all meteorologic driver data for the land surface model has been   !
   ! updated for the current timestep.  Perform the time space average for the output      !
   ! diagnostic.                                                                           !
   !---------------------------------------------------------------------------------------!
   call int_met_avg(cgrid)

   return
end subroutine radiate_driver
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This subroutine will drive the distribution of radiation among crowns, snow layers,  !
! and soil.                                                                                !
!------------------------------------------------------------------------------------------!
subroutine sfcrad_ed(cosz,cosaoi,csite,mzg,mzs,ntext_soil,maxcohort,tuco                   &
                    ,rshort_tot,rshort_diffuse,daytime,twilight)

   use ed_state_vars        , only : sitetype             & ! structure
                                   , patchtype            ! ! structure
   use canopy_layer_coms    , only : crown_mod            ! ! intent(in)
   use canopy_radiation_coms, only : ican_swrad           & ! intent(in)
                                   , cosz_min             & ! intent(in)
                                   , par_beam_norm        & ! intent(in)
                                   , par_diff_norm        & ! intent(in)
                                   , nir_beam_norm        & ! intent(in)
                                   , nir_diff_norm        ! ! intent(in)
   use soil_coms            , only : soil                 & ! intent(in)
                                   , emisg                ! ! intent(in)
   use consts_coms          , only : stefan               ! ! intent(in)
   use ed_max_dims          , only : n_pft                ! ! intent(in)
   use allometry            , only : h2crownbh            ! ! intent(in)

   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   type(sitetype)                  , target      :: csite
   integer                         , intent(in)  :: mzg
   integer                         , intent(in)  :: mzs
   integer         , dimension(mzg), intent(in)  :: ntext_soil
   real                            , intent(in)  :: rshort_tot
   real                            , intent(in)  :: rshort_diffuse
   real                            , intent(in)  :: cosaoi
   real                            , intent(in)  :: cosz
   integer                         , intent(in)  :: maxcohort
   logical                         , intent(in)  :: daytime
   logical                         , intent(in)  :: twilight
   integer                         , intent(out) :: tuco
   !----- Local variables. ----------------------------------------------------------------!
   type(patchtype) , pointer                    :: cpatch
   integer         , dimension(maxcohort)       :: pft_array
   integer                                      :: il
   integer                                      :: ipa
   integer                                      :: ico
   integer                                      :: cohort_count
   integer                                      :: nsoil
   integer                                      :: k
   integer                                      :: ksn
   real                                         :: fcpct
   real                                         :: albedo_soil_par
   real                                         :: albedo_soil_nir
   real                                         :: albedo_sfcw_par
   real                                         :: albedo_sfcw_nir
   real                                         :: rad_par
   real                                         :: rad_nir
   real                                         :: fractrans_par
   real                                         :: fractrans_nir
   real            , dimension(mzs)             :: fracabs_par
   real            , dimension(mzs)             :: fracabs_nir
   real                                         :: abs_ground_par
   real                                         :: abs_ground_nir
   real                                         :: albedo_ground_par
   real                                         :: albedo_ground_nir
   real                                         :: downward_par_below_beam
   real                                         :: upward_par_above_beam
   real                                         :: downward_nir_below_beam
   real                                         :: upward_nir_above_beam
   real(kind=8)    , dimension(maxcohort)       :: leaf_temp_array
   real(kind=8)    , dimension(maxcohort)       :: wood_temp_array
   real(kind=8)    , dimension(maxcohort)       :: lai_array
   real(kind=8)    , dimension(maxcohort)       :: wai_array
   real(kind=8)    , dimension(maxcohort)       :: CA_array
   real(kind=8)    , dimension(maxcohort)       :: htop_array
   real(kind=8)    , dimension(maxcohort)       :: hbot_array
   real(kind=8)    , dimension(maxcohort)       :: lambda_array
   real(kind=8)    , dimension(maxcohort)       :: beam_level_array
   real(kind=8)    , dimension(maxcohort)       :: diff_level_array
   real(kind=8)    , dimension(maxcohort)       :: light_level_array
   real(kind=8)    , dimension(maxcohort)       :: light_beam_level_array
   real(kind=8)    , dimension(maxcohort)       :: light_diff_level_array
   real            , dimension(maxcohort)       :: par_v_beam_array
   real            , dimension(maxcohort)       :: rshort_v_beam_array
   real            , dimension(maxcohort)       :: par_v_diffuse_array
   real            , dimension(maxcohort)       :: rshort_v_diffuse_array
   real            , dimension(maxcohort)       :: lw_v_surf_array
   real            , dimension(maxcohort)       :: lw_v_incid_array
   real                                         :: downward_par_below_diffuse
   real                                         :: upward_par_above_diffuse
   real                                         :: downward_nir_below_diffuse
   real                                         :: upward_nir_above_diffuse 
   real(kind=8)                                 :: lambda_tot
   real                                         :: T_surface
   real                                         :: emissivity
   real                                         :: downward_lw_below_surf
   real                                         :: downward_lw_below_incid
   real                                         :: upward_lw_below_surf
   real                                         :: upward_lw_below_incid
   real                                         :: upward_lw_above_surf
   real                                         :: upward_lw_above_incid
   real                                         :: downward_rshort_below_beam
   real                                         :: downward_rshort_below_diffuse
   real                                         :: surface_absorbed_longwave_surf
   real                                         :: surface_absorbed_longwave_incid
   real                                         :: weight_leaf
   real                                         :: weight_wood
   !----- External function. --------------------------------------------------------------!
   real            , external                   :: sngloff
   !----- Local constants. ----------------------------------------------------------------!
   real(kind=8)    , parameter                  :: tiny_offset = 1.d-20
   !---------------------------------------------------------------------------------------!


   !----- Loop over the patches -----------------------------------------------------------!
   do ipa = 1,csite%npatches
      cpatch => csite%patch(ipa)
      

      !------------------------------------------------------------------------------------!
      !     Cohort_count is the number of cohorts that affect the radiation balance (i.e.  !
      ! those which are flagged as resolvable.                                             !
      !------------------------------------------------------------------------------------!
      cohort_count = 0
      tuco         = 0
      !------------------------------------------------------------------------------------!



      !----- Recalc the maximum photosynthetic rates next time around. --------------------!
      csite%old_stoma_data_max(1:n_pft,ipa)%recalc = 1
      !------------------------------------------------------------------------------------!



      !----- Set the light extinction to zero, just in case it is night time... -----------!
      csite%lambda_light(ipa) = 0.0 
      lambda_tot              = 0.d0
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     Initialise par_l_ as zero just in case it is night time or if there is no      !
      ! resolvable cohort.                                                                 !
      !------------------------------------------------------------------------------------!
      csite%par_l_beam_max   (ipa) = 0.0
      csite%par_l_diffuse_max(ipa) = 0.0
      csite%par_l_max        (ipa) = 0.0
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     Loop over cohorts.  Unusually, we here start at the shortest. Required by      !
      ! radiation schemes.                                                                 !
      !------------------------------------------------------------------------------------!
      do ico = cpatch%ncohorts,1,-1
         
         !----- Initialize values. --------------------------------------------------------!
         cpatch%par_l(ico)                 = 0.0
         cpatch%par_l_beam(ico)            = 0.0
         cpatch%par_l_diffuse(ico)         = 0.0
         
         cpatch%rshort_l(ico)              = 0.0
         cpatch%rshort_l_beam(ico)         = 0.0
         cpatch%rshort_l_diffuse(ico)      = 0.0
         
         cpatch%rlong_l(ico)               = 0.0
         cpatch%rlong_l_incid(ico)         = 0.0
         cpatch%rlong_l_surf(ico)          = 0.0
         
         cpatch%rshort_w(ico)              = 0.0
         cpatch%rshort_w_beam(ico)         = 0.0
         cpatch%rshort_w_diffuse(ico)      = 0.0
         
         cpatch%rlong_w(ico)               = 0.0
         cpatch%rlong_w_incid(ico)         = 0.0
         cpatch%rlong_w_surf(ico)          = 0.0

         cpatch%old_stoma_data(ico)%recalc = 1
         
         cpatch%light_level     (ico)      = 0.0
         cpatch%light_level_beam(ico)      = 0.0
         cpatch%light_level_diff(ico)      = 0.0
         cpatch%lambda_light    (ico)      = 0.0
         cpatch%beamext_level   (ico)      = 0.0
         cpatch%diffext_level   (ico)      = 0.0

         !------ Transfer information from linked lists to arrays. ------------------------!
         
         if (cpatch%leaf_resolvable(ico) .or. cpatch%wood_resolvable(ico)) then
            !----- This will eventually have the index of the tallest used cohort. --------!
            tuco = ico

            cohort_count                          = cohort_count + 1
            pft_array              (cohort_count) = cpatch%pft(ico)
            !------------------------------------------------------------------------------!
            !     Here we only tell the true LAI if the leaf is resolvable, and the true   !
            ! WAI if the wood is resolvable.                                               !
            !------------------------------------------------------------------------------!
            if (cpatch%leaf_resolvable(ico)) then
               lai_array              (cohort_count) = dble(cpatch%lai(ico))
            else
               lai_array              (cohort_count) = 0.d0
            end if
            if (cpatch%wood_resolvable(ico)) then
               wai_array              (cohort_count) = dble(cpatch%wai(ico))
            else
               wai_array              (cohort_count) = 0.d0
            end if

            leaf_temp_array        (cohort_count) = dble(cpatch%leaf_temp(ico))
            wood_temp_array        (cohort_count) = dble(cpatch%wood_temp(ico))
            rshort_v_beam_array    (cohort_count) = 0.0
            par_v_beam_array       (cohort_count) = 0.0
            rshort_v_diffuse_array (cohort_count) = 0.0
            par_v_diffuse_array    (cohort_count) = 0.0
            lambda_array           (cohort_count) = 0.d0
            beam_level_array       (cohort_count) = 0.d0
            diff_level_array       (cohort_count) = 0.d0
            light_level_array      (cohort_count) = 0.d0
            light_beam_level_array (cohort_count) = 0.d0
            light_diff_level_array (cohort_count) = 0.d0
            htop_array             (cohort_count) = dble(cpatch%hite(ico))
            hbot_array             (cohort_count) = dble(h2crownbh(cpatch%hite(ico)        &
                                                                  ,cpatch%pft(ico) ) )
            !------------------------------------------------------------------------------!
            !      Decide whether to assume infinite crown, or the crown area allometry    !
            ! method as in Dietze and Clark (2008).                                        !
            !------------------------------------------------------------------------------!
            select case (crown_mod)
            case (0)
               CA_array           (cohort_count) = 1.d0
            case (1,2)
               CA_array           (cohort_count) = dble(cpatch%crown_area(ico))
            end select
            !------------------------------------------------------------------------------!
         end if

      end do
      csite%rshort_s_diffuse(:,ipa) = 0.0
      csite%rshort_s_beam   (:,ipa) = 0.0
      !------------------------------------------------------------------------------------!




      !------------------------------------------------------------------------------------!
      !     Find the ground albedo as a function of soil water relative moisture of the    !
      ! top layer.                                                                         !
      !------------------------------------------------------------------------------------!
      ! nsoil = ntext_soil(mzg)
      ! select case (nsoil)
      ! case (13)
      !    !----- Bedrock, no soil moisture, use dry soil albedo. -------------------------!
      !    alg = soil(nsoil)%albdry
      ! case default
      !    !-------------------------------------------------------------------------------!
      !    !     Find relative soil moisture.  Not sure about this one, but I am assuming  !
      !    ! that albedo won't change below the dry air soil moisture, and that should be  !
      !    ! the dry value.                                                                !
      !    !-------------------------------------------------------------------------------!
      !    fcpct = max(0., min(1., (csite%soil_water(mzg,ipa) - soil(nsoil)%soilcp)        &
      !                          / (soil(nsoil)%slmsts        - soil(nsoil)%soilcp) ) )
      !    alg   = soil(nsoil)%albdry + fcpct * (soil(nsoil)%albwet - soil(nsoil)%albdry)
      ! end select
      nsoil = ntext_soil(mzg)
      select case (nsoil)
      case (13)
         !----- Bedrock, use constants soil value for granite. ----------------------------!
         albedo_soil_par = soil(nsoil)%albdry
         albedo_soil_nir = soil(nsoil)%albdry
      case (12)
         !----- Peat, follow McCumber and Pielke (1981). ----------------------------------!
         fcpct = csite%soil_water(mzg,ipa) / soil(nsoil)%slmsts
         albedo_soil_par   = max (0.07, 0.14 * (1.0 - fcpct))
         albedo_soil_nir   = albedo_soil_par
      case default
         !---------------------------------------------------------------------------------!
         !      Other soils, we use the soil numbers from CLM.  We don't have soil colour  !
         ! but here we assume soils to be of class 1 (the lightest one).  The reason is    !
         ! because we don't have a litter layer, which usually has a high reflectance,     !
         ! especially in the near infra-red at least in the tropics.                       !
         !---------------------------------------------------------------------------------!
         fcpct           = max(0., 0.11 - 0.40 * csite%soil_water(mzg,ipa))
         albedo_soil_par = min(0.24, 0.12 + fcpct)
         albedo_soil_nir = min(0.48, 0.24 + fcpct)
         !---------------------------------------------------------------------------------!
      end select
      !------------------------------------------------------------------------------------!





      !------------------------------------------------------------------------------------!
      !     Decide what is our surface temperature.  When the soil is exposed, then that   !
      ! is the surface temperature.  Otherwise, we pick the temporary surface water or     !
      ! snow layer.                                                                        !
      !------------------------------------------------------------------------------------!
      rad_par           = 1.0
      rad_nir           = 1.0
      albedo_ground_par = 1.0
      albedo_ground_nir = 1.0
      ksn               = csite%nlev_sfcwater(ipa)
      if (ksn == 0) then
         emissivity = emisg(ntext_soil(mzg))
         T_surface  = csite%soil_tempk(mzg,ipa)
      else
         !---------------------------------------------------------------------------------!
         !      Sfcwater albedo ALS ranges from wet-soil value .14 for all-liquid to .5    !
         ! for all-ice.  For the time being, we will leave the values constant, but we     !
         ! should consider using different values for different bands.  CLM may be a good  !
         ! starting point.                                                                 !
         !---------------------------------------------------------------------------------!
         albedo_sfcw_par = 0.5 - 0.36 * csite%sfcwater_fracliq(ksn,ipa)
         albedo_sfcw_nir = albedo_sfcw_par
         !----- Fraction shortwave absorbed into sfcwater + soil. -------------------------!
         rad_par = 1.0 - albedo_sfcw_par
         rad_nir = 1.0 - albedo_sfcw_nir
         
         do k = ksn,1,-1
            
            !------------------------------------------------------------------------------!
            !      Fractrans is fraction of shortwave entering each sfcwater layer that    !
            ! gets transmitted through that layer.                                         !
            !------------------------------------------------------------------------------!
            fractrans_par = exp(-20.0 * csite%sfcwater_depth(k,ipa))
            fractrans_nir = fractrans_par
            
            !------------------------------------------------------------------------------!
            !      Fracabs(k) is fraction of total incident shortwave (at top of top       !
            ! sfcwater layer) that is absorbed in each sfcwater layer.                     !
            !------------------------------------------------------------------------------!
            fracabs_par(k) = rad_par * (1.0 - fractrans_par)
            fracabs_nir(k) = rad_nir * (1.0 - fractrans_nir)

            !------------------------------------------------------------------------------!
            !      Rad is fraction of total incident shortwave (at top of top sfcwater     !
            ! layer) that remains at bottom of current sfcwater layer.                     !
            !------------------------------------------------------------------------------!
            rad_par = rad_par * fractrans_par
            rad_nir = rad_nir * fractrans_nir

            !------------------------------------------------------------------------------!
            !      Albedo_ground will ultimately be the albedo of the soil+sfcwater.  So   !
            ! subtract out whatever is being absorbed by sfcwater.                         !
            !------------------------------------------------------------------------------!
            albedo_ground_par = albedo_ground_par - fracabs_par(k)
            albedo_ground_nir = albedo_ground_nir - fracabs_nir(k)
         end do

         !----- Long wave parameter if sfcwater exists. -----------------------------------!
         emissivity = 1.0
         T_surface  = csite%sfcwater_tempk(csite%nlev_sfcwater(ipa),ipa)
      end if
      !------------------------------------------------------------------------------------!




      !------------------------------------------------------------------------------------!
      !     This is the fraction of below-canopy radiation that is absorbed by the ground. !
      !------------------------------------------------------------------------------------!
      abs_ground_par = (1.0 - albedo_soil_par) * rad_par
      abs_ground_nir = (1.0 - albedo_soil_nir) * rad_nir
      !------------------------------------------------------------------------------------!




      !----- Subtract off ground absorption to obtain the soil+sfcwater albedo. -----------!
      albedo_ground_par = albedo_ground_par - abs_ground_par
      albedo_ground_nir = albedo_ground_nir - abs_ground_nir
      !------------------------------------------------------------------------------------!




      !------------------------------------------------------------------------------------!
      !     Decide whether to call the radiation or not.  If there is no cohort, we can    !
      ! bypass it entirely.                                                                !
      !------------------------------------------------------------------------------------!
      if (cohort_count > 0) then

         !---------------------------------------------------------------------------------!
         !     Solve long wave first.  Check whether to solve cohort by cohort, or layer   !
         ! by layer.                                                                       !
         !---------------------------------------------------------------------------------!
         select case (crown_mod)
         case (0,1)
            call lw_twostream(cohort_count,emissivity,T_surface,pft_array(1:cohort_count)  &
                             ,LAI_array(1:cohort_count),WAI_array(1:cohort_count)          &
                             ,CA_array(1:cohort_count)                                     &
                             ,leaf_temp_array(1:cohort_count)                              &
                             ,wood_temp_array(1:cohort_count)                              &
                             ,lw_v_surf_array(1:cohort_count)                              &
                             ,lw_v_incid_array(1:cohort_count),downward_lw_below_surf      &
                             ,downward_lw_below_incid, upward_lw_below_surf                &
                             ,upward_lw_below_incid, upward_lw_above_surf                  &
                             ,upward_lw_above_incid)
         case (2)
            call lw_twostream_layer(cohort_count,emissivity,T_surface                      &
                                   ,pft_array(1:cohort_count)                              &
                                   ,LAI_array(1:cohort_count),WAI_array(1:cohort_count)    &
                                   ,CA_array(1:cohort_count),htop_array(1:cohort_count)    &
                                   ,hbot_array(1:cohort_count)                             &
                                   ,leaf_temp_array(1:cohort_count)                        &
                                   ,wood_temp_array(1:cohort_count)                        &
                                   ,lw_v_surf_array(1:cohort_count)                        &
                                   ,lw_v_incid_array(1:cohort_count)                       &
                                   ,downward_lw_below_surf                                 &
                                   ,downward_lw_below_incid, upward_lw_below_surf          &
                                   ,upward_lw_below_incid, upward_lw_above_surf            &
                                   ,upward_lw_above_incid)
         end select
         !---------------------------------------------------------------------------------!



         !----- Upwelling long wave radiation at the top of the canopy. -------------------!
         csite%rlongup(ipa)      = upward_lw_above_surf
         csite%rlong_albedo(ipa) = upward_lw_above_incid
         !---------------------------------------------------------------------------------!



         !----- Long wave absorbed by either soil or sfcwater. ----------------------------!
         surface_absorbed_longwave_surf  = downward_lw_below_surf  - upward_lw_below_surf
         surface_absorbed_longwave_incid = downward_lw_below_incid - upward_lw_below_incid
         !---------------------------------------------------------------------------------!



         !---------------------------------------------------------------------------------!
         !     Compute short wave only if it is daytime or at least twilight.              !
         !---------------------------------------------------------------------------------!
         if (twilight) then

            !------------------------------------------------------------------------------!
            !     We must check which crown model we are using.                            !
            !------------------------------------------------------------------------------!
            select case (crown_mod)
            case (0,1)
               !---------------------------------------------------------------------------!
               !    No vertical distribution / horizontal competition of canopy.  There is !
               ! a chance that the user wants to use Beers' law, so we must check here.    !
               !---------------------------------------------------------------------------!
               select case (ican_swrad)
               case (0)
                  call sw_beers_clump    (albedo_ground_par,albedo_ground_nir              &
                                         ,cosz,cosaoi,cohort_count                         &
                                         ,pft_array(1:cohort_count)                        &
                                         ,LAI_array(1:cohort_count)                        &
                                         ,WAI_array(1:cohort_count)                        &
                                         ,CA_array(1:cohort_count)                         &
                                         ,par_v_beam_array(1:cohort_count)                 &
                                         ,par_v_diffuse_array(1:cohort_count)              &
                                         ,rshort_v_beam_array(1:cohort_count)              &
                                         ,rshort_v_diffuse_array(1:cohort_count)           &
                                         ,downward_par_below_beam                          &
                                         ,downward_par_below_diffuse                       &
                                         ,upward_par_above_beam,upward_par_above_diffuse   &
                                         ,downward_nir_below_beam                          &
                                         ,downward_nir_below_diffuse                       &
                                         ,upward_nir_above_beam,upward_nir_above_diffuse   &
                                         ,beam_level_array,diff_level_array                &
                                         ,light_level_array,light_beam_level_array         &
                                         ,light_diff_level_array,lambda_array,lambda_tot)
               case (1)
                  call sw_twostream_clump(albedo_ground_par,albedo_ground_nir              &
                                         ,cosz,cosaoi,cohort_count                         &
                                         ,pft_array(1:cohort_count)                        &
                                         ,LAI_array(1:cohort_count)                        &
                                         ,WAI_array(1:cohort_count)                        &
                                         ,CA_array(1:cohort_count)                         &
                                         ,par_v_beam_array(1:cohort_count)                 &
                                         ,par_v_diffuse_array(1:cohort_count)              &
                                         ,rshort_v_beam_array(1:cohort_count)              &
                                         ,rshort_v_diffuse_array(1:cohort_count)           &
                                         ,downward_par_below_beam                          &
                                         ,downward_par_below_diffuse                       &
                                         ,upward_par_above_beam,upward_par_above_diffuse   &
                                         ,downward_nir_below_beam                          &
                                         ,downward_nir_below_diffuse                       &
                                         ,upward_nir_above_beam,upward_nir_above_diffuse   &
                                         ,beam_level_array,diff_level_array                &
                                         ,light_level_array,light_beam_level_array         &
                                         ,light_diff_level_array,lambda_array,lambda_tot)
               end select
               !---------------------------------------------------------------------------!



               !---------------------------------------------------------------------------!
               !    Since there is no horizontal competition, assuming that the maximum    !
               ! possible PAR is just the PAR from the tallest resolvable cohort is good   !
               ! enough.                                                                   !
               !---------------------------------------------------------------------------!
               weight_leaf = sngloff( LAI_array(cohort_count)                              &
                                    / (LAI_array(cohort_count) + WAI_array(cohort_count))  &
                                    , tiny_offset)
               csite%par_l_beam_max(ipa)    = par_v_beam_array(cohort_count)               &
                                            * weight_leaf
               csite%par_l_diffuse_max(ipa) = par_v_diffuse_array(cohort_count)            &
                                            * weight_leaf
            case (2)

               !---------------------------------------------------------------------------!
               !    Solve the top cohort by itself using the normal subroutine.  This is   !
               ! to find the maximum possible PAR (so even the tallest cohort won't be     !
               ! with cbr_bar = 1 if it is facing light competition).                      !
               !---------------------------------------------------------------------------!
               call sw_twostream_clump(albedo_ground_par,albedo_ground_nir                 &
                                      ,cosz,cosaoi,1,pft_array(cohort_count)               &
                                      ,LAI_array(cohort_count),WAI_array(cohort_count)     &
                                      ,CA_array(cohort_count)                              &
                                      ,par_v_beam_array(1),par_v_diffuse_array(1)          &
                                      ,rshort_v_beam_array(1),rshort_v_diffuse_array(1)    &
                                      ,downward_par_below_beam,downward_par_below_diffuse  &
                                      ,upward_par_above_beam,upward_par_above_diffuse      &
                                      ,downward_nir_below_beam,downward_nir_below_diffuse  &
                                      ,upward_nir_above_beam,upward_nir_above_diffuse      &
                                      ,beam_level_array(1),diff_level_array(1)             &
                                      ,light_level_array(1),light_beam_level_array(1)      &
                                      ,light_diff_level_array(1),lambda_array,lambda_tot)

               !---------------------------------------------------------------------------!
               !    Since there is no horizontal competition, assuming that the maximum    !
               ! possible PAR is just the PAR from the tallest resolvable cohort is good   !
               ! enough.                                                                   !
               !---------------------------------------------------------------------------!
               weight_leaf = sngloff( LAI_array(1) / (LAI_array(1) + WAI_array(1))         &
                                    , tiny_offset)
               csite%par_l_beam_max   (ipa) = par_v_beam_array   (1) * weight_leaf
               csite%par_l_diffuse_max(ipa) = par_v_diffuse_array(1) * weight_leaf
               !---------------------------------------------------------------------------!


               !---------------------------------------------------------------------------!
               !    Now we solve the radiation for all resolvable cohorts, using the       !
               ! layer-by-layer approach.                                                  !
               !---------------------------------------------------------------------------!
               call sw_twostream_layer(albedo_ground_par,albedo_ground_nir                 &
                                      ,cosz,cosaoi,cohort_count                            &
                                      ,pft_array(1:cohort_count),LAI_array(1:cohort_count) &
                                      ,WAI_array(1:cohort_count),CA_array(1:cohort_count)  &
                                      ,htop_array(1:cohort_count)                          &
                                      ,hbot_array(1:cohort_count)                          &
                                      ,par_v_beam_array(1:cohort_count)                    &
                                      ,par_v_diffuse_array(1:cohort_count)                 &
                                      ,rshort_v_beam_array(1:cohort_count)                 &
                                      ,rshort_v_diffuse_array(1:cohort_count)              &
                                      ,downward_par_below_beam,downward_par_below_diffuse  &
                                      ,upward_par_above_beam,upward_par_above_diffuse      &
                                      ,downward_nir_below_beam,downward_nir_below_diffuse  &
                                      ,upward_nir_above_beam,upward_nir_above_diffuse      &
                                      ,beam_level_array,diff_level_array                   &
                                      ,light_level_array,light_beam_level_array            &
                                      ,light_diff_level_array,lambda_array,lambda_tot)
               !---------------------------------------------------------------------------!

            end select

            !----- Below-canopy downwelling radiation. ------------------------------------!
            downward_rshort_below_beam    = downward_par_below_beam                        &
                                          + downward_nir_below_beam
            downward_rshort_below_diffuse = downward_par_below_diffuse                     &
                                          + downward_nir_below_diffuse

            !----- Soil+sfcwater+veg albedo (different for diffuse and beam radiation). ---!
            csite%albedo_beam(ipa)    = ( upward_par_above_beam                            &
                                        + upward_nir_above_beam )                          &
                                      / sngloff( par_beam_norm + nir_beam_norm             &
                                               , tiny_offset )
            csite%albedo_diffuse(ipa) = ( upward_par_above_diffuse                         &
                                        + upward_nir_above_diffuse )                       &
                                      / sngloff( par_diff_norm + nir_diff_norm             &
                                               , tiny_offset )
            csite%albedo(ipa) = ( upward_par_above_beam    + upward_nir_above_beam         &
                                + upward_par_above_diffuse + upward_nir_above_diffuse )
            csite%lambda_light(ipa)   = sngloff(lambda_tot,tiny_offset)
         else

            !----- The code expects values for these, even when it is not daytime. --------!
            downward_par_below_beam       = par_beam_norm
            downward_par_below_diffuse    = par_diff_norm
            downward_nir_below_beam       = nir_beam_norm
            downward_nir_below_diffuse    = nir_diff_norm
            downward_rshort_below_beam    = par_beam_norm + nir_beam_norm
            downward_rshort_below_diffuse = par_diff_norm + nir_diff_norm
            csite%albedo_beam         (ipa) = ( albedo_ground_par * par_beam_norm          &
                                              + albedo_ground_nir * nir_beam_norm )        &
                                            / ( par_beam_norm + nir_beam_norm )
            csite%albedo_diffuse      (ipa) = ( albedo_ground_par * par_diff_norm          &
                                              + albedo_ground_nir * nir_diff_norm )        &
                                            / ( par_diff_norm + nir_diff_norm )
            csite%albedo              (ipa) = albedo_ground_par * par_beam_norm            &
                                            + albedo_ground_nir * nir_beam_norm            &
                                            + albedo_ground_par * par_diff_norm            &
                                            + albedo_ground_nir * nir_diff_norm
            csite%lambda_light(ipa)       = 0.0
         end if

         !----- Absorption rates of PAR, rshort, and rlong of the vegetation. -------------!
         il = 0

         do ico = cpatch%ncohorts,1,-1
            if (cpatch%leaf_resolvable(ico) .or. cpatch%wood_resolvable(ico)) then
               il = il + 1
               
               !---------------------------------------------------------------------------!
               weight_leaf = sngloff( LAI_array(il) / (LAI_array(il) + WAI_array(il))      &
                                    , tiny_offset)
               weight_wood = 1. - weight_leaf

               cpatch%par_l_beam       (ico) = par_v_beam_array              (il)          &
                                             * weight_leaf
               cpatch%par_l_diffuse    (ico) = par_v_diffuse_array           (il)          &
                                             * weight_leaf
               cpatch%rshort_l_beam    (ico) = rshort_v_beam_array           (il)          &
                                             * weight_leaf
               cpatch%rshort_l_diffuse (ico) = rshort_v_diffuse_array        (il)          &
                                             * weight_leaf
               cpatch%rlong_l_surf     (ico) = lw_v_surf_array               (il)          &
                                             * weight_leaf
               cpatch%rlong_l_incid    (ico) = lw_v_incid_array              (il)          &
                                             * weight_leaf
               cpatch%rshort_w_beam    (ico) = rshort_v_beam_array           (il)          &
                                             * weight_wood
               cpatch%rshort_w_diffuse (ico) = rshort_v_diffuse_array        (il)          &
                                             * weight_wood
               cpatch%rlong_w_surf     (ico) = lw_v_surf_array               (il)          &
                                             * weight_wood
               cpatch%rlong_w_incid    (ico) = lw_v_incid_array              (il)          &
                                             * weight_wood


               cpatch%lambda_light     (ico) = sngloff(lambda_array          (il)          &
                                                      ,tiny_offset )
               cpatch%beamext_level    (ico) = sngloff(beam_level_array      (il)          &
                                                      ,tiny_offset )
               cpatch%diffext_level    (ico) = sngloff(diff_level_array      (il)          &
                                                      ,tiny_offset )
               cpatch%light_level      (ico) = sngloff(light_level_array     (il)          &
                                                      ,tiny_offset )
               cpatch%light_level_beam (ico) = sngloff(light_beam_level_array(il)          &
                                                      ,tiny_offset )
               cpatch%light_level_diff (ico) = sngloff(light_diff_level_array(il)          &
                                                      ,tiny_offset )
            end if
         end do

      else
         
         !----- This is the case where there is no vegetation. ----------------------------!
         downward_par_below_beam         = par_beam_norm
         downward_par_below_diffuse      = par_diff_norm
         downward_nir_below_beam         = nir_beam_norm
         downward_nir_below_diffuse      = nir_diff_norm
         downward_rshort_below_beam      = par_beam_norm + nir_beam_norm
         downward_rshort_below_diffuse   = par_diff_norm + nir_diff_norm
         surface_absorbed_longwave_surf  = - emissivity * stefan * T_surface**4
         surface_absorbed_longwave_incid = emissivity
         csite%albedo_beam         (ipa) = ( albedo_ground_par * par_beam_norm             &
                                           + albedo_ground_nir * nir_beam_norm )           &
                                         / ( par_beam_norm + nir_beam_norm )
         csite%albedo_diffuse      (ipa) = ( albedo_ground_par * par_diff_norm             &
                                           + albedo_ground_nir * nir_diff_norm )           &
                                         / ( par_diff_norm + nir_diff_norm )
         csite%albedo              (ipa) = albedo_ground_par * par_beam_norm               &
                                         + albedo_ground_nir * nir_beam_norm               &
                                         + albedo_ground_par * par_diff_norm               &
                                         + albedo_ground_nir * nir_diff_norm  
         csite%rlongup             (ipa) = - surface_absorbed_longwave_surf
         csite%rlong_albedo        (ipa) = 1.0 - surface_absorbed_longwave_incid
      
      end if
      
      !----- Absorption rate of short wave by the soil. -----------------------------------!
      csite%rshort_g_beam   (ipa) = downward_par_below_beam    * abs_ground_par            &
                                  + downward_nir_below_beam    * abs_ground_nir
      csite%rshort_g_diffuse(ipa) = downward_par_below_diffuse * abs_ground_par            &
                                  + downward_nir_below_diffuse * abs_ground_nir


      !----- Absorption rate of short wave by the surface water. --------------------------!
      do k=1,csite%nlev_sfcwater(ipa)
         csite%rshort_s_beam   (k,ipa) = downward_par_below_beam    * fracabs_par(k)       &
                                       + downward_nir_below_beam    * fracabs_nir(k)
         csite%rshort_s_diffuse(k,ipa) = downward_par_below_diffuse * fracabs_par(k)       &
                                       + downward_nir_below_beam    * fracabs_nir(k)
      end do

      !----- Long wave absorption rate at the surface. ------------------------------------!
      if (csite%nlev_sfcwater(ipa) == 0) then
         csite%rlong_s_surf (ipa) = 0.0
         csite%rlong_s_incid(ipa) = 0.0
         csite%rlong_g_surf (ipa) = surface_absorbed_longwave_surf
         csite%rlong_g_incid(ipa) = surface_absorbed_longwave_incid
      else
         csite%rlong_s_surf (ipa) = surface_absorbed_longwave_surf
         csite%rlong_s_incid(ipa) = surface_absorbed_longwave_incid
         csite%rlong_g_surf (ipa) = 0.0
         csite%rlong_g_incid(ipa) = 0.0
      end if
      !------------------------------------------------------------------------------------!
   end do
   return
end subroutine sfcrad_ed
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This function computes the cosine of the zenith angle.                               !
!------------------------------------------------------------------------------------------!
real function ed_zen(plon,plat,when)
   use ed_misc_coms , only : simtime      ! ! structure
   use consts_coms  , only : pio1808      & ! intent(in)
                           , twopi8       & ! intent(in)
                           , hr_sec8      & ! intent(in)
                           , tiny_num8    ! ! intent(in)
   implicit none
   !------ Arguments. ---------------------------------------------------------------------!
   real(kind=4) , intent(in) :: plon
   real(kind=4) , intent(in) :: plat
   type(simtime), intent(in) :: when
   !------ Local variables. ---------------------------------------------------------------!
   integer                   :: doy     ! Day of year ("Julian" day)
   real(kind=8)              :: declin  ! Declination
   real(kind=8)              :: sdec    ! Sine of declination
   real(kind=8)              :: cdec    ! Cosine of declination
   real(kind=8)              :: dayhr   ! Hour of day 
   real(kind=8)              :: radlat  ! Latitude in radians
   real(kind=8)              :: clat    ! Cosine of latitude 
   real(kind=8)              :: slat    ! Sine of latitude
   real(kind=8)              :: dayhrr  ! Hour of day in radians
   real(kind=8)              :: hrangl  ! Hour angle
   !----- Local constants. ----------------------------------------------------------------!
   real(kind=8), parameter   :: capri    = -2.344d1 ! Tropic of Capricornium latitude
   real(kind=8), parameter   :: ndaysnl  =  3.65d2  ! Number of days of year (no leap years)
   real(kind=8), parameter   :: ndayslp  =  3.66d2  ! Number of days of year (leap years)
   integer     , parameter   :: shsummer = -10      ! DoY of Southern Hemisphere summer
   !----- External functions. -------------------------------------------------------------!
   integer     , external    :: julday  ! Function to find day of year ("Julian" day)
   logical     , external    :: isleap  ! Function to determine whether the year is leap
   real        , external    :: sngloff ! Function to safely convert double to single prec.
   !---------------------------------------------------------------------------------------!



   !----- Find the day of the year. -------------------------------------------------------!
   doy    = julday(when%month, when%date, when%year)
   !---------------------------------------------------------------------------------------!



   !----- Find the hour angle, then get cosine of zenith angle. ---------------------------!
   dayhr = dble(when%time) / hr_sec8
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !   declin is the solar latitude in degrees (also known as declination).                !
   !   sdec - sine of declination                                                          !
   !   cdec - cosine of declination.                                                       !
   !---------------------------------------------------------------------------------------!
   if (isleap(when%year)) then
      declin = capri * cos(twopi8 * dble(doy - shsummer) / ndaysnl) * pio1808
   else
      declin = capri * cos(twopi8 * dble(doy - shsummer) / ndayslp) * pio1808
   end if
   sdec   = dsin(declin)
   cdec   = dcos(declin)
   !---------------------------------------------------------------------------------------!

   !----- Find the latitude in radians. ---------------------------------------------------!
   radlat = dble(plat) * pio1808
   clat   = dcos(radlat)
   slat   = dsin(radlat)
   !---------------------------------------------------------------------------------------!

   !------ Find the hour angle. -----------------------------------------------------------!
   dayhrr = dmod(dayhr+dble(plon)/1.5d1+2.4d1,2.4d1)
   hrangl = 1.5d1 * (dayhrr - 1.2d1) * pio1808

   ed_zen = sngloff(slat * sdec + clat * cdec * dcos(hrangl),tiny_num8)

   return
end function ed_zen
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This function computes the average secant of the daytime zenith angle.  In case the  !
! period of integration is that accounts for the zenith angle is 0. or less than one time  !
! step, then the average is the actual value.  Night-time periods are ignored and if there !
! is no daytime value, then we set it to 0.                                                !
!------------------------------------------------------------------------------------------!
real function mean_daysecz(plon,plat,whena,dt,tmax)
   use ed_misc_coms         , only : simtime     ! ! structure
   use canopy_radiation_coms, only : cosz_min    ! ! intent(in)
   implicit none
   !------ Arguments. ---------------------------------------------------------------------!
   real(kind=4) , intent(in) :: plon
   real(kind=4) , intent(in) :: plat
   type(simtime), intent(in) :: whena
   real(kind=4) , intent(in) :: dt
   real(kind=4) , intent(in) :: tmax
   !------ Local variables. ---------------------------------------------------------------!
   type(simtime)             :: now          ! Current time
   integer                   :: is           ! Step counter
   integer                   :: nsteps       ! Number of steps to perform the average
   real                      :: dtfit        ! Delta-t that nicely fits within tmax
   real                      :: dtnow        ! Delta-t for this time
   real                      :: cosz         ! Declination
   real                      :: daytot       ! Total time that was daytime
   real                      :: mean_daycosz ! Average cosine of zenith angle
   !----- External functions. -------------------------------------------------------------!
   real(kind=4), external    :: ed_zen   ! Function to find day of year ("Julian" day)
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   !     Check whether tmax is less than the time step.  In case it is, we only have one   !
   ! time, so we don't need to do the average.                                             !
   !---------------------------------------------------------------------------------------!
   if (dt >= tmax) then
      !----- Less than one time, no average necessary. ------------------------------------!
      cosz = ed_zen(plon,plat,whena)
      if (cosz > cosz_min) then
         mean_daysecz = 1.0 / cosz
      else
         !----- Night-time, set the mean to zero. -----------------------------------------!
         mean_daysecz = 0.0
      end if

   else
      !------------------------------------------------------------------------------------!
      !     Several times, first find the number of steps, then the delta-t that fits      !
      ! nicely within the time span.                                                       !
      !------------------------------------------------------------------------------------!
      nsteps = ceiling(tmax / dt)
      dtfit  = tmax / real(nsteps)
      !------------------------------------------------------------------------------------!

      mean_daycosz = 0.0
      daytot       = 0.0
      do is=1,nsteps
         !----- Get the current time. -----------------------------------------------------!
         now   = whena
         dtnow = dtfit * (real(is) - 0.5)
         call update_model_time_dm(now,dtnow)

         !----- Get the cosine of the zenith angle. ---------------------------------------!
         cosz = ed_zen(plon,plat,now)

         !----- Add to the integral only if it this value is valid. -----------------------!
         if (cosz > cosz_min) then
            mean_daycosz = mean_daycosz + dtfit * cosz 
            daytot       = daytot       + dtfit
         end if
         !---------------------------------------------------------------------------------!
      end do
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     Find the normalisation factor.                                                 !
      !------------------------------------------------------------------------------------!
      if (daytot > 0.0 .and. mean_daycosz > 0.0) then
         mean_daycosz = mean_daycosz / daytot
         mean_daysecz = 1.0 / mean_daycosz
      else
         mean_daysecz = 0.0
      end if
      !------------------------------------------------------------------------------------!
   end if

   return
end function mean_daysecz
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine scale_ed_radiation(tuco,rshort,rshort_diffuse,rlong,csite)

   use ed_state_vars        , only : sitetype             & ! intent(in)
                                   , patchtype            ! ! intent(in)
   use canopy_radiation_coms, only : cosz_min             ! ! intent(in)
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   type(sitetype)  , target     :: csite
   integer         , intent(in) :: tuco
   real            , intent(in) :: rshort
   real            , intent(in) :: rshort_diffuse
   real            , intent(in) :: rlong
   !----- Local variables. ----------------------------------------------------------------!
   type(patchtype) , pointer    :: cpatch
   integer                      :: ipa,ico, k
   !----- This should be false unless you really want to turn off radiation. --------------!
   logical         , parameter  :: skip_rad = .false.
   !----- External functions. -------------------------------------------------------------!
   real            , external   :: sngloff
   !---------------------------------------------------------------------------------------!

   if (skip_rad) then
      do ipa = 1, csite%npatches
         cpatch => csite%patch(ipa)
         do ico = 1, cpatch%ncohorts
            if (cpatch%leaf_resolvable(ico) .or. cpatch%wood_resolvable(ico)) then
               cpatch%par_l_beam       (ico) = 0.0
               cpatch%par_l_diffuse    (ico) = 0.0
               cpatch%par_l            (ico) = 0.0
               cpatch%rshort_l_beam    (ico) = 0.0
               cpatch%rshort_l_diffuse (ico) = 0.0
               cpatch%rshort_l         (ico) = 0.0
               cpatch%rlong_l_incid    (ico) = 0.0
               cpatch%rlong_l_surf     (ico) = 0.0
               cpatch%rlong_l          (ico) = 0.0
               cpatch%rshort_w_beam    (ico) = 0.0
               cpatch%rshort_w_diffuse (ico) = 0.0
               cpatch%rshort_w         (ico) = 0.0
               cpatch%rlong_w_incid    (ico) = 0.0
               cpatch%rlong_w_surf     (ico) = 0.0
               cpatch%rlong_w          (ico) = 0.0
               cpatch%light_level      (ico) = 0.0
               cpatch%light_level_diff (ico) = 0.0
               cpatch%light_level_beam (ico) = 0.0
            end if
         end do
         
         csite%rshort_g_beam(ipa)    = 0.
         csite%rshort_g_diffuse(ipa) = 0.
         csite%rshort_g(ipa)         = 0.
         !----- Absorption rate of short wave by the surface water. -----------------------!
         do k=1,csite%nlev_sfcwater(ipa)
            csite%rshort_s_beam(k,ipa)    = 0.
            csite%rshort_s_diffuse(k,ipa) = 0.
            csite%rshort_s(k,ipa)         = 0.
         end do
         csite%rlong_s_incid(ipa) = 0.
         csite%rlong_g_incid(ipa) = 0.
         csite%rlong_s_surf(ipa)  = 0.
         csite%rlong_g_surf(ipa)  = 0.
      
         csite%rlong_s(ipa)       = 0.
         csite%rlong_g(ipa)       = 0.
      end do
      return
   end if



   do ipa = 1,csite%npatches

      cpatch => csite%patch(ipa)
      do ico = 1,cpatch%ncohorts
         
         if (cpatch%leaf_resolvable(ico) .or. cpatch%wood_resolvable(ico)) then

            cpatch%par_l_beam(ico)       = cpatch%par_l_beam(ico)    * rshort
            cpatch%par_l_diffuse(ico)    = cpatch%par_l_diffuse(ico) * rshort
            cpatch%par_l(ico)            = cpatch%par_l_beam(ico)                          &
                                         + cpatch%par_l_diffuse(ico)

            cpatch%rshort_l_beam(ico)    = cpatch%rshort_l_beam(ico)    * rshort
            cpatch%rshort_l_diffuse(ico) = cpatch%rshort_l_diffuse(ico) * rshort
            cpatch%rshort_l(ico)         = cpatch%rshort_l_beam(ico)                       &
                                         + cpatch%rshort_l_diffuse(ico)

            cpatch%rlong_l_incid(ico)    = cpatch%rlong_l_incid(ico) * rlong
            cpatch%rlong_l(ico)          = cpatch%rlong_l_incid(ico)                       &
                                         + cpatch%rlong_l_surf(ico)

            cpatch%rshort_w_beam(ico)    = cpatch%rshort_w_beam(ico)    * rshort
            cpatch%rshort_w_diffuse(ico) = cpatch%rshort_w_diffuse(ico) * rshort
            cpatch%rshort_w(ico)         = cpatch%rshort_w_beam(ico)                       &
                                         + cpatch%rshort_w_diffuse(ico)
            cpatch%rlong_w_incid(ico)    = cpatch%rlong_w_incid(ico) * rlong
            cpatch%rlong_w(ico)          = cpatch%rlong_w_incid(ico)                       &
                                         + cpatch%rlong_w_surf(ico)
         end if
      end do
      csite%par_l_beam_max(ipa)    = csite%par_l_beam_max(ipa)    * rshort
      csite%par_l_diffuse_max(ipa) = csite%par_l_diffuse_max(ipa) * rshort
      csite%par_l_max(ipa)         = csite%par_l_beam_max(ipa)                             &
                                   + csite%par_l_diffuse_max(ipa)

      csite%rshort_g_beam(ipa)    = csite%rshort_g_beam(ipa)    * rshort
      csite%rshort_g_diffuse(ipa) = csite%rshort_g_diffuse(ipa) * rshort
      csite%rshort_g(ipa)         = csite%rshort_g_beam(ipa) + csite%rshort_g_diffuse(ipa)
      
      !----- Absorption rate of short wave by the surface water. --------------------------!
      do k=1,csite%nlev_sfcwater(ipa)
         csite%rshort_s_beam(k,ipa)    = csite%rshort_s_beam   (k,ipa) * rshort
         csite%rshort_s_diffuse(k,ipa) = csite%rshort_s_diffuse(k,ipa) * rshort
         csite%rshort_s(k,ipa)         = csite%rshort_s_beam   (k,ipa)                     &
                                       + csite%rshort_s_diffuse(k,ipa)
      end do

      csite%rlong_s_incid(ipa) = csite%rlong_s_incid(ipa) * rlong
      csite%rlong_g_incid(ipa) = csite%rlong_g_incid(ipa) * rlong
      
      csite%rlong_s(ipa)       = csite%rlong_s_surf(ipa) + csite%rlong_s_incid(ipa)
      csite%rlong_g(ipa)       = csite%rlong_g_surf(ipa) + csite%rlong_g_incid(ipa)


   end do

   return
end subroutine scale_ed_radiation
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This subroutine calculates angle of incidence based on local slope and aspect.       !
!------------------------------------------------------------------------------------------!
subroutine angle_of_incid(aoi,cosz,solar_hour_aspect,slope,terrain_aspect)
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   real, intent(in)  :: cosz              ! Cosine of zenithal angle
   real, intent(in)  :: slope             ! Terrain slope
   real, intent(in)  :: solar_hour_aspect ! horizontal location of the sun defined with the
                                          !    same reference as terrain aspect.
   real, intent(in)  :: terrain_aspect    ! Terrain aspect
   real, intent(out) :: aoi               ! Angle of incidence
   !----- Local variables. ----------------------------------------------------------------!
   real(kind=8)      :: cosz8             ! Double prec. counterpart of cosz
   real(kind=8)      :: sinz8             ! Sine of zenithal angle
   real(kind=8)      :: slope8            ! Double prec. counterpart of slope
   real(kind=8)      :: sh_asp8           ! Double prec. counterpart of solar_hour_aspect
   real(kind=8)      :: terr_asp8         ! Double prec. counterpart of terrain_aspect
   real(kind=8)      :: aoi8              ! Double prec. counterpart of aoi
   !----- Local parameters. ---------------------------------------------------------------!
   real(kind=8), parameter :: tiny_offset=1.d-20
   !----- External functions. -------------------------------------------------------------!
   real        , external  :: sngloff           
   !---------------------------------------------------------------------------------------!

   cosz8     = dble(cosz)
   sinz8     = sqrt(1.d0-cosz8*cosz8)
   slope8    = dble(slope)
   sh_asp8   = dble(solar_hour_aspect)
   terr_asp8 = dble(terrain_aspect)
   if (cosz8 < 0.d0) then
      aoi8 = 0.d0
   else
      aoi8 = max(0.d0, cosz8*dcos(slope8) + sinz8*dsin(slope8)*dcos(sh_asp8-terr_asp8))
   end if

   aoi = sngloff(aoi8,tiny_offset) 

   return
end subroutine angle_of_incid
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This sub-routine solves the within canopy radiation for short wave radiation, using  !
! the simplified Beers law.  It will take into account the crown area and/or branches in   !
! case the user wants so.                                                                  !
!     This sub-routine is added for very simple tests only, and it shouldn't be used for   !
! long-term simulations.                                                                   !
!------------------------------------------------------------------------------------------!
subroutine sw_beers_clump(salbedo_par,salbedo_nir,scosz,scosaoi,ncoh,pft                   &
                         ,lai,wai,canopy_area                                              &
                         ,par_beam_flip,par_diffuse_flip,sw_abs_beam_flip                  &
                         ,sw_abs_diffuse_flip,dw_vislo_beam,dw_vislo_diffuse               &
                         ,uw_vishi_beam,uw_vishi_diffuse,dw_nirlo_beam                     &
                         ,dw_nirlo_diffuse,uw_nirhi_beam,uw_nirhi_diffuse                  &
                         ,beam_level,diff_level,light_level,light_beam_level               &
                         ,light_diff_level,lambda_coh,lambda_tot)

   use ed_max_dims          , only : n_pft                   ! ! intent(in)
   use pft_coms             , only : clumping_factor         & ! intent(in)
                                   , phenology               ! ! intent(in)
   use canopy_radiation_coms, only : par_beam_norm           & ! intent(in)
                                   , par_diff_norm           & ! intent(in)
                                   , nir_beam_norm           & ! intent(in)
                                   , nir_diff_norm           & ! intent(in)
                                   , cosz_min8               ! ! intent(in)
   use consts_coms          , only : tiny_num8               ! ! intent(in)
   implicit none
   !----- Arguments -----------------------------------------------------------------------!
   integer, dimension(ncoh)     , intent(in)    :: pft
   integer                      , intent(in)    :: ncoh
   real(kind=8), dimension(ncoh), intent(in)    :: LAI
   real(kind=8), dimension(ncoh), intent(in)    :: WAI
   real(kind=8), dimension(ncoh), intent(in)    :: canopy_area
   real(kind=4)                 , intent(in)    :: salbedo_par
   real(kind=4)                 , intent(in)    :: salbedo_nir
   real(kind=4)                 , intent(in)    :: scosz
   real(kind=4)                 , intent(in)    :: scosaoi
   real(kind=4), dimension(ncoh), intent(out)   :: PAR_beam_flip
   real(kind=4), dimension(ncoh), intent(out)   :: PAR_diffuse_flip
   real(kind=4), dimension(ncoh), intent(out)   :: SW_abs_beam_flip
   real(kind=4), dimension(ncoh), intent(out)   :: SW_abs_diffuse_flip
   real(kind=4)                 , intent(out)   :: UW_vishi_beam
   real(kind=4)                 , intent(out)   :: UW_vishi_diffuse
   real(kind=4)                 , intent(out)   :: UW_nirhi_beam
   real(kind=4)                 , intent(out)   :: UW_nirhi_diffuse
   real(kind=4)                 , intent(out)   :: DW_vislo_beam
   real(kind=4)                 , intent(out)   :: DW_vislo_diffuse
   real(kind=4)                 , intent(out)   :: DW_nirlo_beam
   real(kind=4)                 , intent(out)   :: DW_nirlo_diffuse
   real(kind=8), dimension(ncoh), intent(out)   :: beam_level
   real(kind=8), dimension(ncoh), intent(out)   :: diff_level
   real(kind=8), dimension(ncoh), intent(out)   :: light_level
   real(kind=8), dimension(ncoh), intent(out)   :: light_beam_level
   real(kind=8), dimension(ncoh), intent(out)   :: light_diff_level
   real(kind=8), dimension(ncoh), intent(out)   :: lambda_coh
   real(kind=8)                 , intent(out)   :: lambda_tot
   !----- Local variables -----------------------------------------------------------------!
   integer                                      :: il
   integer                                      :: ipft
   real(kind=8)                                 :: lambda
   real(kind=8)                                 :: cosz
   real(kind=8)                                 :: cosaoi
   real(kind=8)                                 :: albedo
   real(kind=8)                                 :: abscoh
   real(kind=8), dimension(ncoh)                :: beam_bot
   real(kind=8), dimension(ncoh)                :: beam_bot_crown
   real(kind=8), dimension(ncoh)                :: eff_tai
   real(kind=8), dimension(ncoh)                :: tai
   real(kind=8)                                 :: beam_top
   real(kind=8)                                 :: diff_top
   !----- External functions. -------------------------------------------------------------!
   real(kind=4)                 , external      :: sngloff
   !---------------------------------------------------------------------------------------!

   
   !----- Convert input variables to double precision. ------------------------------------!
   albedo = 5.d-1 * (dble(salbedo_par) + dble(salbedo_nir))
   cosz   = max(cosz_min8,dble(scosz))
   cosaoi = max(cosz_min8,dble(scosaoi))
   !---------------------------------------------------------------------------------------!



   !----- Lambda is the extinction coefficient. -------------------------------------------!
   lambda     = 5.d-1/cosaoi
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !    Find the light extinction coefficients.                                            !
   !---------------------------------------------------------------------------------------!
   lambda_tot = 0.0d0
   do il=1,ncoh
      ipft           = pft(il)
      lambda_tot     = lambda_tot + clumping_factor(ipft)
      tai       (il) = lai(il) + wai(il)
      eff_tai   (il) = clumping_factor(ipft) * lai(il) + wai(il)
      lambda_coh(il) = lambda * eff_tai(il) / ( canopy_area(il) * tai(il))
   end do
   lambda_tot = lambda_tot * lambda / dble(ncoh)
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !    Find the light extinction curve.                                                   !
   !---------------------------------------------------------------------------------------!
   beam_bot_crown(ncoh)  = exp(-lambda * eff_tai(ncoh) / canopy_area(ncoh))
   beam_level(ncoh)      = exp(-5.d-1 * lambda * eff_tai(ncoh) / canopy_area(ncoh))
   beam_bot  (ncoh)      = (1.d0 - canopy_area(ncoh))                                      &
                         + canopy_area(ncoh) * beam_bot_crown(ncoh)
   do il=ncoh-1,1,-1
      beam_bot_crown(il) = beam_bot(il+1) * exp(-lambda*eff_tai(il)/canopy_area(il))
      beam_bot      (il) = beam_bot(il+1)*(1.d0-canopy_area(il))                           &
                         + canopy_area(il)*beam_bot_crown(il)
      beam_level    (il) = beam_bot(il+1)                                                  &
                         * exp(-5.d-1*lambda*eff_tai(il)/canopy_area(il))                  &
                         * canopy_area(il)                                                 &
                         + (1.d0-canopy_area(il)) * beam_bot(il+1)
   end do
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !    Currently we simply use the light extinction curve to determine PAR and total      !
   ! shortwave radiation.                                                                  !
   !---------------------------------------------------------------------------------------!
   do il=1,ncoh-1
      diff_level         (il) = 5.d-1 * (beam_bot(il+1) + beam_bot(il))
      abscoh                  = beam_bot(il+1) - beam_bot(il)
      PAR_beam_flip      (il) = sngloff(par_beam_norm * abscoh, tiny_num8)
      PAR_diffuse_flip   (il) = sngloff(par_diff_norm * abscoh, tiny_num8)
      SW_abs_beam_flip   (il) = sngloff(                abscoh, tiny_num8)
      SW_abs_diffuse_flip(il) = sngloff(                abscoh, tiny_num8)
   end do
   abscoh                     = 1.d0 - beam_bot(ncoh)
   PAR_beam_flip       (ncoh) = sngloff(par_beam_norm * abscoh,tiny_num8)
   PAR_diffuse_flip    (ncoh) = sngloff(par_diff_norm * abscoh,tiny_num8)
   SW_abs_beam_flip    (ncoh) = sngloff(                abscoh,tiny_num8)
   SW_abs_diffuse_flip (ncoh) = sngloff(                abscoh,tiny_num8)

   light_level       (1:ncoh) = diff_level(1:ncoh)
   light_beam_level  (1:ncoh) = diff_level(1:ncoh)
   light_diff_level  (1:ncoh) = diff_level(1:ncoh)
   beam_level        (1:ncoh) = diff_level(1:ncoh)
   !---------------------------------------------------------------------------------------!





   !----- Copy to the output variables. ---------------------------------------------------!
   DW_vislo_beam    = sngloff(par_beam_norm          * beam_bot(1), tiny_num8)
   DW_vislo_diffuse = sngloff(par_diff_norm          * beam_bot(1), tiny_num8)
   UW_vishi_beam    = sngloff(par_beam_norm * albedo * beam_bot(1), tiny_num8)
   UW_vishi_diffuse = sngloff(par_diff_norm * albedo * beam_bot(1), tiny_num8)
   DW_nirlo_beam    = sngloff(nir_beam_norm          * beam_bot(1), tiny_num8)
   DW_nirlo_diffuse = sngloff(nir_diff_norm          * beam_bot(1), tiny_num8)
   UW_nirhi_beam    = sngloff(nir_beam_norm * albedo * beam_bot(1), tiny_num8)
   UW_nirhi_diffuse = sngloff(nir_diff_norm * albedo * beam_bot(1), tiny_num8)
   !---------------------------------------------------------------------------------------!

   return
end subroutine sw_beers_clump
!==========================================================================================!
!==========================================================================================!


