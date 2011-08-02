!==========================================================================================!
!==========================================================================================!
!    This module contains several parameters used in the canopy radiation solver.          !
!                                                                                          !
!  IMPORTANT: Do not initialize non-parameters in their modules - not all compilers will   !
!             actually initialize them.  Instead, assign them at init_can_rad_params sub-  !
!             routine (ed_params.f90).                                                     !
!------------------------------------------------------------------------------------------!
module canopy_radiation_coms

   use ed_max_dims , only : n_pft
   implicit none 


   !---------------------------------------------------------------------------------------!
   ! ICANRAD -- Specifies how canopy radiation is solved.  This variable sets both short-  !
   !            wave and longwave.                                                         !
   !            0.  Two-stream model (Medvigy 2006), with the possibility to apply         !
   !                finite crown area to direct shortwave radiation.                       !
   !            1.  Multiple-scattering model (Zhao and Qualls 2005,2006), with the        !
   !                possibility to apply finite crown area to all radiation fluxes.        !
   !---------------------------------------------------------------------------------------!
   integer :: icanrad
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !     Leaf angle distribution parameter (dimensionless).  Let mu' be the cosine of leaf !
   ! angle and G(mu') be the distribution of mu'.  Then, mubar = (integral from 0 to 1)    !
   ! (d mu'   mu' / G(mu')).  See, for example, Dickinson 1983.                            !
   !---------------------------------------------------------------------------------------!
   real(kind=8) :: mu_bar_lw
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !     Fraction of solar radiation in the PAR band.  Used every time step.               !
   !---------------------------------------------------------------------------------------!
   real :: visible_fraction
   !---------------------------------------------------------------------------------------!




   !----- Fraction of direct solar radiation in the PAR band. -----------------------------!
   real :: visible_fraction_dir
   !---------------------------------------------------------------------------------------!





   !---------------------------------------------------------------------------------------!
   !     Fraction of diffuse solar radiation in the PAR band.  Used every time step        !
   !---------------------------------------------------------------------------------------!
   real :: visible_fraction_dif
   !---------------------------------------------------------------------------------------!





   !---------------------------------------------------------------------------------------!
   !     Fraction of diffuse solar radiation in the PAR band.  Used when you don't know    !
   ! the direct/diffuse breakdown.                                                         !
   !---------------------------------------------------------------------------------------!
   real :: fvis_beam_def
   real :: fvis_diff_def
   real :: fnir_beam_def
   real :: fnir_diff_def
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !     These are the normalised variables that will be used in the two-stream model.     !
   !---------------------------------------------------------------------------------------!
   real(kind=8) :: par_beam_norm
   real(kind=8) :: par_diff_norm
   real(kind=8) :: nir_beam_norm
   real(kind=8) :: nir_diff_norm
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !     Factors that define the orientation and clumping of leaves.                       !
   ! CLUMPING FACTOR - factor indicating the degree of clumpiness of leaves.               !
   ! ORIENT_FACTOR   - mean leaf orientation.                                              !
   !                     0 -- leaves are randomly oriented                                 !
   !                     1 -- all leaves are perfectly horizontal                          !
   !                    -1 -- all leaves are perfectly vertical.                           !
   !---------------------------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: clumping_factor
   real(kind=8), dimension(n_pft) :: orient_factor
   !---------------------------------------------------------------------------------------!



   !---------------------------------------------------------------------------------------!
   !     Reflectance coefficients.                                                         !
   !---------------------------------------------------------------------------------------!
   !----- Visible (PAR). ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_reflect_vis
   real(kind=8), dimension(n_pft) :: wood_reflect_vis
   !----- Near infrared. ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_reflect_nir
   real(kind=8), dimension(n_pft) :: wood_reflect_nir
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !     Transmittance coefficients.                                                       !
   !---------------------------------------------------------------------------------------!
   !----- Visible (PAR). ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_trans_vis
   real(kind=8), dimension(n_pft) :: wood_trans_vis
   !----- Near infrared. ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_trans_nir
   real(kind=8), dimension(n_pft) :: wood_trans_nir
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !     Scattering coefficients.                                                          !
   !---------------------------------------------------------------------------------------!
   !----- Visible (PAR). ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_scatter_vis
   real(kind=8), dimension(n_pft) :: wood_scatter_vis
   !----- Near infrared. ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_scatter_nir
   real(kind=8), dimension(n_pft) :: wood_scatter_nir
   !---------------------------------------------------------------------------------------!




   !---------------------------------------------------------------------------------------!
   !     Fraction of diffuse radiation that is upscattered.                                !
   !---------------------------------------------------------------------------------------!
   !----- Visible (PAR). ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_backscatter_vis
   real(kind=8), dimension(n_pft) :: wood_backscatter_vis
   !----- Near infrared. ------------------------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_backscatter_nir
   real(kind=8), dimension(n_pft) :: wood_backscatter_nir
   !---------------------------------------------------------------------------------------!




   !----- Emissivity of the vegetation. ---------------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_emis
   real(kind=8), dimension(n_pft) :: wood_emis
   !---------------------------------------------------------------------------------------!




   !----- Backscattering of thermal infrared. ---------------------------------------------!
   real(kind=8), dimension(n_pft) :: leaf_backscatter_tir
   real(kind=8), dimension(n_pft) :: wood_backscatter_tir
   !---------------------------------------------------------------------------------------!





   !---------------------------------------------------------------------------------------!
   !     The following variables control whether to call things that should be called      !
   ! when there is still some light.                                                       !
   !---------------------------------------------------------------------------------------!
   real(kind=4)    :: rshort_twilight_min
   real(kind=4)    :: cosz_min
   real(kind=8)    :: cosz_min8
   !---------------------------------------------------------------------------------------!


end module canopy_radiation_coms
!==========================================================================================!
!==========================================================================================!
