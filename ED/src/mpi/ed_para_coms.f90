!############################# Change Log ##################################
! 5.0.0
!
!###########################################################################
!  Copyright (C)  1990, 1995, 1999, 2000, 2003 - All Rights Reserved
!  Regional Atmospheric Modeling System - RAMS
!###########################################################################


module ed_para_coms

  use ed_max_dims, only : maxmach

  !---------------------------------------------------------------------------
  integer                             :: mainnum,nmachs,iparallel,machsize
  integer, dimension(maxmach)         :: machnum
  integer                             :: loadmeth
!  integer, dimension(maxmach,maxgrds) :: nxbeg,nxend,nybeg,nyend,nxbegc      &
!                                        ,nxendc,nybegc,nyendc,ixoff,iyoff    &
!                                        ,npxy,ibcflg,ixb,ixe,iyb,iye
  !---------------------------------------------------------------------------

end module ed_para_coms
