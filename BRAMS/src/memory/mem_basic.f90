!====================================== Change Log ========================================!
! 5.0.0                                                                                    !
!                                                                                          !
!==========================================================================================!
!  Copyright (C)  1990, 1995, 1999, 2000, 2003 - All Rights Reserved                       !
!  Regional Atmospheric Modeling System - RAMS                                             !
!==========================================================================================!
module mem_basic
   use grid_dims, only : nzpmax
   type basic_vars
      !----- Variables to be dimensioned by (nzp,nxp,nyp). --------------------------------!
      real, dimension(:,:,:), pointer :: up
      real, dimension(:,:,:), pointer :: uc
      real, dimension(:,:,:), pointer :: vp
      real, dimension(:,:,:), pointer :: vc
      real, dimension(:,:,:), pointer :: wp
      real, dimension(:,:,:), pointer :: wc
      real, dimension(:,:,:), pointer :: pp
      real, dimension(:,:,:), pointer :: pc
      real, dimension(:,:,:), pointer :: rv
      real, dimension(:,:,:), pointer :: theta
      real, dimension(:,:,:), pointer :: thp
      real, dimension(:,:,:), pointer :: rtp
      real, dimension(:,:,:), pointer :: co2p
      real, dimension(:,:,:), pointer :: pi0
      real, dimension(:,:,:), pointer :: th0
      real, dimension(:,:,:), pointer :: dn0
      real, dimension(:,:,:), pointer :: dn0u
      real, dimension(:,:,:), pointer :: dn0v
      !----- Variables to be dimensioned by (nxp,nyp). ------------------------------------!
      real, dimension(:,:)  , pointer :: fcoru
      real, dimension(:,:)  , pointer :: fcorv
      real, dimension(:,:)  , pointer :: cputime
      !------------------------------------------------------------------------------------!
   end type basic_vars
   
   !----- These are going to be the instantaneous and averaged structures. ----------------!
   type (basic_vars), dimension(:), allocatable :: basic_g
   type (basic_vars), dimension(:), allocatable :: basicm_g
   
   !---------------------------------------------------------------------------------------!
   !  Namelist variables.                                                                  !
   !---------------------------------------------------------------------------------------!
   !----- This variable is going to control how to solve CO2. -----------------------------!
   integer                    :: ico2
   !----- Initial value of CO2, or initial CO2 profile, if constant for the entire domain. !
   real, dimension(nzpmax)    :: co2con
   !---------------------------------------------------------------------------------------!


   !----- This variable is just an alias to set CO2 or not. -------------------------------!
   logical :: co2_on
   !---------------------------------------------------------------------------------------!

   !=======================================================================================!
   !=======================================================================================!



   contains


   !=======================================================================================!
   !=======================================================================================!
   subroutine alloc_basic(basic,n1,n2,n3)

      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      type(basic_vars), intent(inout) :: basic
      integer         , intent(in)    :: n1
      integer         , intent(in)    :: n2
      integer         , intent(in)    :: n3
      !------------------------------------------------------------------------------------!


      !----- Allocate arrays based on options (if necessary). -----------------------------!
      allocate (basic%up      (n1,n2,n3))
      allocate (basic%uc      (n1,n2,n3))
      allocate (basic%vp      (n1,n2,n3))
      allocate (basic%vc      (n1,n2,n3))
      allocate (basic%wp      (n1,n2,n3))
      allocate (basic%wc      (n1,n2,n3))
      allocate (basic%pp      (n1,n2,n3))
      allocate (basic%pc      (n1,n2,n3))
      allocate (basic%thp     (n1,n2,n3))
      allocate (basic%rtp     (n1,n2,n3))
      allocate (basic%rv      (n1,n2,n3))
      allocate (basic%theta   (n1,n2,n3))
      allocate (basic%pi0     (n1,n2,n3))
      allocate (basic%th0     (n1,n2,n3))
      allocate (basic%dn0     (n1,n2,n3))
      allocate (basic%dn0u    (n1,n2,n3))
      allocate (basic%dn0v    (n1,n2,n3))
      allocate (basic%fcoru   (   n2,n3))
      allocate (basic%fcorv   (   n2,n3))
      allocate (basic%cputime (   n2,n3))

      !----- CO2 will be allocated only when ICO2 is non-zero. ----------------------------!
      if (co2_on) then
         allocate (basic%co2p    (n1,n2,n3))
      end if
      return
   end subroutine alloc_basic
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   subroutine nullify_basic(basic)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      type (basic_vars) :: basic
      !------------------------------------------------------------------------------------!
   
      if (associated(basic%up      ))  nullify (basic%up      )
      if (associated(basic%uc      ))  nullify (basic%uc      )
      if (associated(basic%vp      ))  nullify (basic%vp      )
      if (associated(basic%vc      ))  nullify (basic%vc      )
      if (associated(basic%wp      ))  nullify (basic%wp      )
      if (associated(basic%wc      ))  nullify (basic%wc      )
      if (associated(basic%pp      ))  nullify (basic%pp      )
      if (associated(basic%pc      ))  nullify (basic%pc      )
      if (associated(basic%thp     ))  nullify (basic%thp     )
      if (associated(basic%rtp     ))  nullify (basic%rtp     )
      if (associated(basic%co2p    ))  nullify (basic%co2p   )
      if (associated(basic%rv      ))  nullify (basic%rv      )
      if (associated(basic%theta   ))  nullify (basic%theta   )
      if (associated(basic%pi0     ))  nullify (basic%pi0     )
      if (associated(basic%th0     ))  nullify (basic%th0     )
      if (associated(basic%dn0     ))  nullify (basic%dn0     )
      if (associated(basic%dn0u    ))  nullify (basic%dn0u    )
      if (associated(basic%dn0v    ))  nullify (basic%dn0v    )
      if (associated(basic%fcoru   ))  nullify (basic%fcoru   )
      if (associated(basic%fcorv   ))  nullify (basic%fcorv   )
      if (associated(basic%cputime ))  nullify (basic%cputime )
      return
   end subroutine nullify_basic
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   subroutine dealloc_basic(basic)
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      type (basic_vars) :: basic
      !------------------------------------------------------------------------------------!
   
      if (associated(basic%up      ))  deallocate (basic%up      )
      if (associated(basic%uc      ))  deallocate (basic%uc      )
      if (associated(basic%vp      ))  deallocate (basic%vp      )
      if (associated(basic%vc      ))  deallocate (basic%vc      )
      if (associated(basic%wp      ))  deallocate (basic%wp      )
      if (associated(basic%wc      ))  deallocate (basic%wc      )
      if (associated(basic%pp      ))  deallocate (basic%pp      )
      if (associated(basic%pc      ))  deallocate (basic%pc      )
      if (associated(basic%thp     ))  deallocate (basic%thp     )
      if (associated(basic%rtp     ))  deallocate (basic%rtp     )
      if (associated(basic%co2p    ))  deallocate (basic%co2p    )
      if (associated(basic%rv      ))  deallocate (basic%rv      )
      if (associated(basic%theta   ))  deallocate (basic%theta   )
      if (associated(basic%pi0     ))  deallocate (basic%pi0     )
      if (associated(basic%th0     ))  deallocate (basic%th0     )
      if (associated(basic%dn0     ))  deallocate (basic%dn0     )
      if (associated(basic%dn0u    ))  deallocate (basic%dn0u    )
      if (associated(basic%dn0v    ))  deallocate (basic%dn0v    )
      if (associated(basic%fcoru   ))  deallocate (basic%fcoru   )
      if (associated(basic%fcorv   ))  deallocate (basic%fcorv   )
      if (associated(basic%cputime ))  deallocate (basic%cputime )
      return
   end subroutine dealloc_basic
   !=======================================================================================!
   !=======================================================================================!






   !=======================================================================================!
   !=======================================================================================!
   !     This subroutine will fill pointers to arrays into variable tables.                !
   !---------------------------------------------------------------------------------------!
   subroutine filltab_basic(basic,basicm,imean,n1,n2,n3,ng)
      use var_tables
      implicit none
      !----- Arguments. -------------------------------------------------------------------!
      type (basic_vars), intent(inout)   :: basic
      type (basic_vars), intent(inout)   :: basicm
      integer          , intent(in)      :: imean
      integer          , intent(in)      :: n1
      integer          , intent(in)      :: n2
      integer          , intent(in)      :: n3
      integer          , intent(in)      :: ng
      !----- Local variables. -------------------------------------------------------------!
      integer                            :: npts
      !------------------------------------------------------------------------------------!



      !------------------------------------------------------------------------------------!
      !     Three-dimension arrays.                                                        !
      !------------------------------------------------------------------------------------!
      npts=n1*n2*n3
      !----- Acoustic time step variables. ------------------------------------------------!
      if (associated(basic%up))                                                            &
         call vtables2 (basic%up,basicm%up,ng,npts,imean                                   &
                       ,'UP :3:hist:anal:mpti:mpt3:mpt2')
      if (associated(basic%vp))                                                            &
         call vtables2 (basic%vp,basicm%vp,ng,npts,imean                                   &
                       ,'VP :3:hist:anal:mpti:mpt3:mpt2')
      if (associated(basic%wp))                                                            &
         call vtables2 (basic%wp,basicm%wp,ng,npts,imean                                   &
                       ,'WP :3:hist:anal:mpti:mpt3:mpt2')
      if (associated(basic%pp))                                                            &
         call vtables2 (basic%pp,basicm%pp,ng,npts,imean                                   &
                       ,'PP :3:hist:anal:mpti:mpt3:mpt2')
      if (associated(basic%uc))                                                            &
         call vtables2 (basic%uc,basicm%uc,ng,npts,imean                                   &
                       ,'UC :3:hist:mpti:mpt3:mpt2')
      if (associated(basic%vc))                                                            &
         call vtables2 (basic%vc,basicm%vc,ng,npts,imean                                   &
                       ,'VC :3:hist:mpti:mpt3:mpt2')
      if (associated(basic%wc))                                                            &
         call vtables2 (basic%wc,basicm%wc,ng,npts,imean                                   &
                       ,'WC :3:hist:anal:mpt3:mpt2')
      if (associated(basic%pc))                                                            &
         call vtables2 (basic%pc,basicm%pc,ng,npts,imean                                   &
                       ,'PC :3:hist:mpti:mpt3:mpt2')
      !----- "Normal" time step variables. ------------------------------------------------!
      if (associated(basic%thp))                                                           &
         call vtables2 (basic%thp,basicm%thp,ng, npts, imean                               &
                       ,'THP :3:hist:anal:mpti:mpt3:mpt1')
      if (associated(basic%rtp))                                                           &
         call vtables2 (basic%rtp,basicm%rtp,ng, npts, imean                               &
                       ,'RTP :3:hist:anal:mpti:mpt3:mpt1')
      if (associated(basic%co2p))                                                          &
         call vtables2 (basic%co2p,basicm%co2p,ng, npts, imean                             &
                       ,'CO2P :3:hist:anal:mpti:mpt3:mpt1')
      !----- Diagnostic variables. --------------------------------------------------------!
      if (associated(basic%theta))                                                         &
         call vtables2 (basic%theta,basicm%theta,ng, npts, imean                           &
                       ,'THETA :3:hist:anal:mpti:mpt3')
      if (associated(basic%rv))                                                            &
         call vtables2 (basic%rv,basicm%rv,ng, npts, imean                                 &
                       ,'RV :3:hist:anal:mpti:mpt3')
      !----- Reference state variables. ---------------------------------------------------!
      if (associated(basic%pi0))                                                           &
         call vtables2 (basic%pi0,basicm%pi0,ng, npts, imean                               &
                       ,'PI0 :3:mpti')
      if (associated(basic%th0))                                                           &
         call vtables2 (basic%th0,basicm%th0,ng, npts, imean                               &
                       ,'TH0 :3:mpti')
      if (associated(basic%dn0))                                                           &
         call vtables2 (basic%dn0,basicm%dn0,ng, npts, imean                               &
                       ,'DN0 :3:mpti')
      if (associated(basic%dn0u))                                                          &
         call vtables2 (basic%dn0u,basicm%dn0u,ng, npts, imean                             &
                       ,'DN0U :3:mpti')
      if (associated(basic%dn0v))                                                          &
         call vtables2 (basic%dn0v,basicm%dn0v,ng, npts, imean                             &
                       ,'DN0V :3:mpti')
                    
      !------------------------------------------------------------------------------------!
      !     Two-dimension arrays.                                                          !
      !------------------------------------------------------------------------------------!
      npts=n2*n3
      !----- Reference values. ------------------------------------------------------------!
      if (associated(basic%fcoru))                                                         &
         call vtables2 (basic%fcoru,basicm%fcoru,ng, npts, imean                           &
                       ,'FCORU :2:mpti')      
      if (associated(basic%fcorv))                                                         &
         call vtables2 (basic%fcorv,basicm%fcorv,ng, npts, imean                           &
                       ,'FCORV :2:mpti')
      !----- Time spend by each node. -----------------------------------------------------!
      if (associated(basic%cputime))                                                       &
         call vtables2 (basic%cputime,basicm%cputime,ng, npts, imean                       &
                       ,'CPUTIME :2:anal:mpti:mpt3')
    
      return
   end subroutine filltab_basic
   !=======================================================================================!
   !=======================================================================================!
end module mem_basic
!==========================================================================================!
!==========================================================================================!
