!==========================================================================================!
!==========================================================================================!
!   This module contains a list of plant-functional type dependent properties.             !
!                                                                                          !
! IMPORTANT: DO NOT INITIALIZE PARAMETERS IN THEIR MODULES - NOT ALL COMPILERS WILL        !
!            ACTUALLY INITIALIZE THEM.  See "init_pft_*_coms" (ed_params.f90) to check     !
!            the default values.                                                           !
!==========================================================================================!
!==========================================================================================!
module pft_coms

   use ed_max_dims, only: n_pft
   !---------------------------------------------------------------------------------------!
   !  PFT | Name                                | Grass   | Tropical | agriculture?        !
   !------+-------------------------------------+---------+----------+---------------------!
   !    1 | C4 grass                            |     yes |      yes |                 yes !
   !    2 | Early tropical                      |      no |      yes |                  no !
   !    3 | Mid tropical                        |      no |      yes |                  no !
   !    4 | Late tropical                       |      no |      yes |                  no !
   !    5 | C3 grass                            |     yes |       no |                 yes !
   !    6 | Northern pines                      |      no |       no |                  no !
   !    7 | Southern pines                      |      no |       no |                  no !
   !    8 | Late conifers                       |      no |       no |                  no !
   !    9 | Early temperate deciduous           |      no |       no |                  no !
   !   10 | Mid temperate deciduous             |      no |       no |                  no !
   !   11 | Late temperate deciduous            |      no |       no |                  no !
   !   12 | C3 pasture                          |     yes |       no |                 yes !
   !   13 | C3 crop (e.g.,wheat, rice, soybean) |     yes |       no |                 yes !
   !   14 | C4 pasture                          |     yes |      yes |                 yes !
   !   15 | C4 crop (e.g.,corn/maize)           |     yes |      yes |                 yes !
   !------+-------------------------------------+---------+----------+---------------------!



   !=======================================================================================!
   !=======================================================================================!
   !     Variables that are provided by the user's namelist.  They control PFT habits such !
   ! as which PFT should be used for agriculture, which one goes for forest plantation.    !
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   !     This variable is provided by the user through namelist, and contains the list of  !
   ! PFTs he or she wants to use.                                                          !
   !---------------------------------------------------------------------------------------!
   integer, dimension(n_pft) :: include_these_pft

   !---------------------------------------------------------------------------------------!
   !     This flag determines what to do at the PFT initialization.  This option is        !
   ! ignored for near-bare ground simulations:                                             !
   !  0. Stop if a undesired PFT is at the restart file;                                   !
   !  1. Include the PFT in the list of usable pfts (recompute include_these_pft and       !
   !     include_pft);                                                                     !
   !  2. Ignore the cohort and keep going.                                                 !
   !---------------------------------------------------------------------------------------!
   integer :: pft_1st_check

   !---------------------------------------------------------------------------------------!
   !     These are the flags that indicate which PFTs should be used for agriculture and   !
   ! plantation stock should go. They are currently a single PFT, but they should become:  !
   ! vectors eventually (so multiple PFTs can be used...).                                 !
   !---------------------------------------------------------------------------------------!
   integer :: agri_stock 
   integer :: plantation_stock
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !    The following variables are flags that control which PFTs mare used in general,    !
   ! for agriculture and grasses.                                                          !
   !---------------------------------------------------------------------------------------!
   
   
   !---------------------------------------------------------------------------------------!
   !    This is the list of PFTs that are included.  0 means off, 1 means on.              !
   !---------------------------------------------------------------------------------------!
   integer, dimension(n_pft) :: include_pft

   !---------------------------------------------------------------------------------------!
   !    This is the list of grass PFTs that may be included in agricultural patches.  Only !
   ! PFTs included here and at the include_these_pft will be used for agricultural         !
   ! patches.                                                                              !
   !---------------------------------------------------------------------------------------!
   integer, dimension(n_pft) :: grass_pft

   !---------------------------------------------------------------------------------------!
   !    This flag specifies what non-agricutural PFTs (i.e., grass)  can grow on agri-     !
   ! culture patches.  Set to 1 if you want to include this PFT on agriculture patches     !
   !---------------------------------------------------------------------------------------!
   integer, dimension(n_pft) :: include_pft_ag

   !---------------------------------------------------------------------------------------!
   !    The following logical flags will tell whether the PFTs are tropical and also       !
   ! check whether it is a grass or tree PFT (this may need to be switched to integer if   !
   ! we start adding bush-like PFTs).                                                      !
   !---------------------------------------------------------------------------------------!
   logical, dimension(n_pft)    :: is_tropical
   logical, dimension(n_pft)    :: is_grass
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     Photosynthesis and stomatal conductance properties.                               !
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   !   Stomata begin to rapidly close once the difference between intercellular and        !
   ! boundary layer H2O mixing ratios exceed this value. [mol_H2O/mol_air].                !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: D0 

   !----- Temperature [�C] below which leaf metabolic activity begins to rapidly decline. -!
   real, dimension(n_pft) :: Vm_low_temp 

   !----- Temperature [�C] above which leaf metabolic activity begins to rapidly decline. -!
   real, dimension(n_pft) :: Vm_high_temp 

   !----- Maximum photosynthetic capacity at a reference temperature [�mol/m2/s]. ---------!
   real, dimension(n_pft) :: Vm0 

   !----- Slope of the Ball/Berry stomatal conductance-photosynthesis relationship. -------!
   real, dimension(n_pft) :: stomatal_slope

   !----- Intercept of the Ball/Berry stomatal conductance relationship [�mol/m2/s]. ------!
   real, dimension(n_pft) :: cuticular_cond

   !----- Efficiency of using PAR to fix CO2 [ ----]. -------------------------------------!
   real, dimension(n_pft) :: quantum_efficiency

   !----- Specifies photosynthetic pathway.  3 corresponds to C3, 4 corresponds to C4. ----!
   integer, dimension(n_pft) :: photosyn_pathway
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     Respiration and turnover properties.                                              !
   !---------------------------------------------------------------------------------------!
  
   !---------------------------------------------------------------------------------------!
   !   This variable determines level of growth respiration.  Starting with accumulated    !
   ! photosynthesis (P), leaf (Rl) and root respiration (Rr) are first subtracted.  Then,  !
   ! the growth respiration = (growth_resp_factor) * (P - Rl - Rr).                        !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: growth_resp_factor

   !----- This is the inverse of leaf life span [1/year]. ---------------------------------!
   real, dimension(n_pft) :: leaf_turnover_rate

   !----- This is the inverse of fine root life span [1/year]. ----------------------------!
   real, dimension(n_pft) :: root_turnover_rate

   !---------------------------------------------------------------------------------------!
   !    This variable sets the rate of dark (i.e., leaf) respiration.  It is dimensionless !
   ! because it is relative to Vm0.                                                        !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: dark_respiration_factor

   !----- Turnover rate of plant storage pools [1/year]. ----------------------------------!
   real, dimension(n_pft) :: storage_turnover_rate 

   !---------------------------------------------------------------------------------------!
   !    This variable sets the contribution of roots to respiration.  Its units is         !
   ! umol_CO2/kg_fine_roots/second.                                                        !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: root_respiration_factor 
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !   Mortality and survivorship parameters.                                              !
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   !     This variable controls the time scale at which plants out of carbon balance       !
   ! suffer mortality [1/years].                                                           !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: mort1

   !---------------------------------------------------------------------------------------!
   !     This variable determines how poor the carbon balance needs to be before plants    !
   ! suffer large mortality rates.                                                         !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: mort2

   !---------------------------------------------------------------------------------------!
   !     This variable controls the density-independent mortality rate due to ageing       !
   ! [1/years].                                                                            !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: mort3 

   !---------------------------------------------------------------------------------------!
   !     This variable determines how rapidly trees die if it is too cold for them         !
   ! [1/years].                                                                            !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: frost_mort  

   !----- Fraction of seedlings that suffer mortality without becoming a recruit. ---------!
   real, dimension(n_pft) :: seedling_mortality

   !---------------------------------------------------------------------------------------!
   !     Survivorship fraction for trees with heights greater than treefall_hite_threshold !
   ! (see disturbance_coms.f90).                                                           !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: treefall_s_gtht

   !---------------------------------------------------------------------------------------!
   !     Survivorship fraction for trees with heights less than treefall_hite_threshold    !
   ! (see disturbance_coms.f90).                                                           !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: treefall_s_ltht

   !----- Below this temperature, mortality rapidly increases. ----------------------------!
   real, dimension(n_pft) :: plant_min_temp
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   ! Nitrogen and water requirements  -- see "initialize_pft_nitro_params".                !
   !---------------------------------------------------------------------------------------!
   !----- Carbon to Nitrogen ratio, slow pool. --------------------------------------------!
   real :: c2n_slow
   !----- Carbon to Nitrogen ratio, structural pool. --------------------------------------!
   real :: c2n_structural
   !----- Carbon to Nitrogen ratio, storage pool. -----------------------------------------!
   real :: c2n_storage
   !----- Carbon to Nitrogen ratio, structural stem. --------------------------------------!
   real, dimension(n_pft) :: c2n_stem
   !----- Carbon to Nitrogen ratio, structural stem. --------------------------------------!
   real :: l2n_stem
   !----- Leaf carbon to nitrogen ratio. --------------------------------------------------!
   real, dimension(n_pft) :: c2n_leaf
   !----- Recruit carbon to nitrogen ratio. -----------------------------------------------!
   real, dimension(n_pft) :: c2n_recruit 
   !----- Carbon-to-biomass ratio of plant tissues. ---------------------------------------!
   real :: C2B
   !----- Fraction of structural stem that is assumed to be above ground. -----------------!
   real :: agf_bs
   !----- Supply coefficient for plant nitrogen uptake [m2/kgC_fine_root/day].  -----------!
   real :: plant_N_supply_scale
   !---------------------------------------------------------------------------------------!
   !    Supply coefficient for plant water uptake [m2_ground/kgC_root/sec].                !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: water_conductance  
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   ! Allocation and allometry.                                                             !
   !---------------------------------------------------------------------------------------!
   !----- Wood density.  Used only for tropical PFTs and grasses [ g/cm�]. ----------------!
   real   , dimension(n_pft)    :: rho
   !----- Specific Leaf Area (m�leaf/kg_C]. -----------------------------------------------!
   real   , dimension(n_pft)    :: SLA
   !----- Mass ratio between fine root and leaves [kg_fine_roots]/[kg_leaves]. ------------!
   real   , dimension(n_pft)    :: q
   !----- Mass ratio between sapwood and leaves [kg_sapwood]/[kg_leaves]. -----------------!
   real   , dimension(n_pft)    :: qsw
   real   , dimension(n_pft)    :: sapwood_ratio ! AREA ratio
   real   , dimension(n_pft)    :: hgt_ref ! ref height for diam/ht allom (Temperate)
   real   , dimension(n_pft)    :: b1Ht  !  DBH-height allometry intercept (m).  Temperate PFTs only.
   real   , dimension(n_pft)    :: b2Ht  !  DBH-height allometry slope (1/cm).  Temperate PFTs only.
   real   , dimension(n_pft)    :: b1Bs  !  DBH-stem allometry intercept (kg stem biomass / plant * cm^{-b2Bs}).  Temperate PFTs only.
   real   , dimension(n_pft)    :: b2Bs  !  DBH-stem allometry slope (dimensionless).  Temperate PFTs only.
   real   , dimension(n_pft)    :: b1Bl  !  DBH-leaf allometry intercept (kg leaf biomass / plant * cm^{-b2Bl}).  Temperate PFTs only.
   real   , dimension(n_pft)    :: b2Bl  !  DBH-leaf allometry slope (dimensionless).  Temperate PFTs only.
   real   , dimension(n_pft)    :: max_dbh !  Maximum DBH attainable by this PFT (cm)
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   ! Leaf habit and physical properties.                                                   !
   !---------------------------------------------------------------------------------------!

   !---------------------------------------------------------------------------------------!
   ! Phenology indicates the leaf habit regarding phenology:                               !
   ! 0. Evergreen coniferous;                                                              !
   ! 1. Drought deciduous;                                                                 !
   ! 2. Cold deciduous;                                                                    !
   ! 3. Light controlled;                                                                  !
   ! 4. Drought deciduous - based on 10day average.                                        !
   !---------------------------------------------------------------------------------------!
   integer, dimension(n_pft) :: phenology 

   !----- A 0-1 factor indicating degree of clumpiness of leaves and shoots. --------------!
   real(kind=8), dimension(n_pft) :: clumping_factor

   !----- Leaf width [m], which is used to compute the leaf boundary layer conductance. ---!
   real, dimension(n_pft) :: leaf_width

   !---------------------------------------------------------------------------------------!
   !     The fraction of the total depth of the canopy where the levaes reside, assuming   !
   ! they are uniformly distributed in this zone.                                          !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: crown_depth_fraction  
   
   !---------------------------------------------------------------------------------------!
   !    Fraction of vertical branches.  Values are from Poorter et al. (2006):             !
   !                                                                                       !
   !    Poorter, L.; Bongers, L.; Bongers, F., 2006: Architecture of 54 moist-forest tree  !
   ! species: traits, trade-offs, and functional groups. Ecology, 87, 1289-1301.           !
   ! For simplicity, we assume similar numbers for temperate PFTs.                         !
   !---------------------------------------------------------------------------------------!
   real, dimension(n_pft) :: horiz_branch
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !   Parameters used for vegetation heat capacity calculation.                           !
   !---------------------------------------------------------------------------------------!
   !----- Specific heat capacity of dry leaf biomass [J/kg/K]. ----------------------------!
   real, dimension(n_pft) :: c_grn_leaf_dry
   !----- Specific heat capacity of dry non-green biomass [J/kg/K]. -----------------------!
   real, dimension(n_pft) :: c_ngrn_biom_dry
   !----- Ratio of tissue water to dry mass in green leaves [kg_h2o/kg_leaves]. -----------!
   real, dimension(n_pft) :: wat_dry_ratio_grn
   !----- Ratio of water to dry mass in wood biomass [kg_h2o/kg_wood]. --------------------!
   real, dimension(n_pft) :: wat_dry_ratio_ngrn
   !-----  Second term in the RHS of equation 5 of Gu et al. (2007), assuming T=t3ple. ----!
   real, dimension(n_pfT) :: delta_c
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !    The following parameters are used in the branching parametrisation (J�rvel� 2004). !
   !---------------------------------------------------------------------------------------!
   !----- Branching ratio. ----------------------------------------------------------------!
   real   , dimension(n_pft)    :: rbranch
   !----- Diameter ratio. -----------------------------------------------------------------!
   real   , dimension(n_pft)    :: rdiamet
   !----- Length ratio. -------------------------------------------------------------------!
   real   , dimension(n_pft)    :: rlength
   !----- Minimum diameter allowed. -------------------------------------------------------!
   real   , dimension(n_pft)    :: diammin
   !----- Number of trunks (usually one). -------------------------------------------------!
   real   , dimension(n_pft)    :: ntrunk
   !---------------------------------------------------------------------------------------!
   !     The following parameters are used only for effective branch area index, fitting a !
   !  smooth curve for Conijn (1995) numbers.  This should be switched by a more realistic !
   !  calculation at some point soon.                                                      !
   !---------------------------------------------------------------------------------------!
   real   , dimension(n_pft)    :: conijn_a
   real   , dimension(n_pft)    :: conijn_b
   real   , dimension(n_pft)    :: conijn_c
   real   , dimension(n_pft)    :: conijn_d
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     Reproduction and recruitment.                                                     !
   !---------------------------------------------------------------------------------------!
   !----- Initial plant density in a near-bare-ground run [plant/m�]. ---------------------!
   real   , dimension(n_pft)    :: init_density
   !----- Minimum height of an individual [m]. --------------------------------------------!
   real   , dimension(n_pft)    :: hgt_min
   !----- Minimum biomass density [kgC/m�] required to form a new recruit. ----------------!
   real, dimension(n_pft) :: min_recruit_size
   !----- Fraction of (positive) carbon balance devoted to reproduction. ------------------!
   real, dimension(n_pft) :: r_fract
   !----- External input of seeds [kgC/m�/year]. ------------------------------------------!
   real, dimension(n_pft) :: seed_rain
   !----- Fraction of seed dispersal that is gridcell-wide. -------------------------------!
   real, dimension(n_pft) :: nonlocal_dispersal !  
   !----- Minimum height plants need to attain before allocating to reproduction. ---------!
   real, dimension(n_pft) :: repro_min_h 
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     The following variables control the cohort existence/termination.                 !
   !---------------------------------------------------------------------------------------! 
   !---------------------------------------------------------------------------------------! 
   !    Minimum size (measured as biomass of living and structural tissues) allowed in a   !
   ! cohort.  Cohorts with less biomass than this are going to be terminated.              !
   !---------------------------------------------------------------------------------------! 
   real, dimension(n_pft) :: min_cohort_size
   !---------------------------------------------------------------------------------------! 
   !    The following variable is the absolute minimum cohort population that a cohort can !
   ! have.  This should be used only to avoid nplant=0, but IMPORTANT: this will lead to a !
   ! ridiculously small cohort almost guaranteed to be extinct and SHOULD BE USED ONLY IF  !
   ! THE AIM IS TO ELIMINATE THE COHORT.                                                   !
   !---------------------------------------------------------------------------------------! 
   real, dimension(n_pft) :: negligible_nplant
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     The following variable is an identifier for the PFT, for some of the debugging    !
   ! output.                                                                               !
   !---------------------------------------------------------------------------------------!
   character(len=16), dimension(n_pft) :: pft_name16
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !    Structure containing information needed for recruits.                              !
   !---------------------------------------------------------------------------------------!
   type recruittype
      integer :: pft
      real    :: veg_temp
      real    :: hite
      real    :: dbh
      real    :: bdead
      real    :: bleaf
      real    :: balive
      real    :: nplant
   end type recruittype
   !=======================================================================================!
   !=======================================================================================!
   
   
   contains



   !=======================================================================================!
   !=======================================================================================!
   !    This subroutine simply resets a recruittype structure.                             !
   !---------------------------------------------------------------------------------------!
   subroutine zero_recruit(maxp,recruit)
      implicit none
      !----- Argument. --------------------------------------------------------------------!
      integer                           , intent(in)  :: maxp
      type(recruittype), dimension(maxp), intent(out) :: recruit
      !----- Local variable. --------------------------------------------------------------!
      integer                                         :: p
      !------------------------------------------------------------------------------------!

      do p=1,maxp
         recruit(p)%pft      = 0
         recruit(p)%veg_temp = 0.
         recruit(p)%hite     = 0.
         recruit(p)%dbh      = 0.
         recruit(p)%bdead    = 0.
         recruit(p)%bleaf    = 0.
         recruit(p)%balive   = 0.
         recruit(p)%nplant   = 0.
      end do

      return
   end subroutine zero_recruit
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !    This subroutine simply copies a recruittype structure.                             !
   !---------------------------------------------------------------------------------------!
   subroutine copy_recruit(recsource,rectarget)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      type(recruittype), intent(in)  :: recsource
      type(recruittype), intent(out) :: rectarget
      !------------------------------------------------------------------------------------!

      rectarget%pft      = recsource%pft
      rectarget%veg_temp = recsource%veg_temp
      rectarget%hite     = recsource%hite
      rectarget%dbh      = recsource%dbh
      rectarget%bdead    = recsource%bdead
      rectarget%bleaf    = recsource%bleaf
      rectarget%balive   = recsource%balive
      rectarget%nplant   = recsource%nplant

      return
   end subroutine copy_recruit
   !=======================================================================================!
   !=======================================================================================!
end module pft_coms
!==========================================================================================!
!==========================================================================================!
