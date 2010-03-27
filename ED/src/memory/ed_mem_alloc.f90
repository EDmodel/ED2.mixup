!==========================================================================================!
!==========================================================================================!
subroutine ed_mem_alloc(proc_type)

   use ed_max_dims            , only: n_pft,                  & ! intent(in)
                                   n_dist_types,           & ! intent(in)
                                   n_dbh,                  & ! intent(in)
                                   maxvars,                & ! intent(in)
                                   maxgrds                 ! ! intent(in)
   use ed_mem_grid_dim_defs, only: define_grid_dim_pointer ! ! subroutine
   use ed_state_vars       , only: gdpy,                   & ! intent(in)  
                                   edgrid_g,               & ! intent(out)
                                   allocate_edglobals,     & ! subroutine
                                   nullify_edtype,         & ! subroutine
                                   allocate_edtype         ! ! subroutine
   use grid_coms          , only : nnxp,                   & ! intent(in)
                                   nnyp,                   & ! intent(in)
                                   ngrids                  ! ! intent(in)
   use mem_sites          , only : grid_type
   use ed_work_vars       , only : work_e,                 & ! intent(out)
                                   ed_alloc_work,          & ! subroutine
                                   ed_nullify_work         ! ! subroutine
   
   use ed_misc_coms          , only : idoutput,               & ! intent(in)
                                   imoutput                ! ! intent(in)
   use ed_node_coms       , only : mmxp, mmyp, mynum

   implicit none
!----- Arguments: -------------------------------------------------------------------------!
   integer       , intent(in)                :: proc_type
!----- Local Variables: -------------------------------------------------------------------!
   integer       , pointer    , dimension(:) :: nmxp,nmyp
   integer                                   :: ng
!------------------------------------------------------------------------------------------!


!------------------------------------------------------------------------------------------!
! First, depending on type of process, define grid point pointers correctly.               !
!------------------------------------------------------------------------------------------!
   select case (proc_type)
   case (0,1)
      !  This is the call for either a single processor run or
      !    for the master process
      nmxp => nnxp
      nmyp => nnyp
   case (2)
      !  This is the call for a initial compute node process
      nmxp => mmxp
      nmyp => mmyp
   case default 
      call fatal_error('Invalid proc_type','ed_mem_alloc','ed_mem_alloc.f90')
   end select

!------------------------------------------------------------------------------------------!
! Changed this part. The structure will not be allocated at the nodes at this moment, and  !
! even at the master node we will have deallocated to reallocate with the node size rather !
! than the full domain. Also, we will need to use this structure even for latlon grid,     !
! because it will be used to assign the polygon information.                               !
!------------------------------------------------------------------------------------------!

   write (unit=*,fmt='(a,i5,a)') ' + Work allocation, node ',mynum,';'
   allocate(work_e(ngrids))
   do ng = 1,ngrids
      call ed_nullify_work(work_e(ng))
      call ed_alloc_work(work_e(ng),nmxp(ng),nmyp(ng))
   end do
   
!------------------------------------------------------------------------------------------!
!   Allocate the top most hierachical memory structures for the ED2 LSM. We changed the    !
! the way the standalone deals with different regions ans sites of interest. Now it        !
! allocates each region and each soi in a different grid. This is done to ease the way the !
! parallel code is implemented, to take full advantage of MPI. By doing this, we can split !
! the polygons among the different nodes for the regional run, and split the patches and   !
! cohorts in different nodes in the SOI grids --- the latter is yet to be implemented.     !
!------------------------------------------------------------------------------------------!
   write (unit=*,fmt='(a,i5,a)') ' + Polygon array allocation, node ',mynum,';'

   call allocate_edglobals(ngrids)
   do ng=1,ngrids
      call ed_newgrid(ng)
      call allocate_edtype(edgrid_g(ng),gdpy(mynum,ng))
   end do

   write (unit=*,fmt='(a,i5,a)') ' + Memory successfully allocated on none ',mynum,';'
   return
end subroutine ed_mem_alloc
!==========================================================================================!
!==========================================================================================!
