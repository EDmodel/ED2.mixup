 !------------------------------------------------------------------------!
!                                                                        !
! Main subroutine for driving the initialization process for             !
! the Ecosystem Demography Model 2.  All compute nodes, including        !
! the node formerly known as master.                                     !
!                                                                        !
!------------------------------------------------------------------------!

subroutine ed_driver
  
  use grid_coms, only: &
       ngrids,          &
       time,            &
       timmax
  
  use ed_state_vars, only: &
       allocate_edglobals, &    ! implicitly interfaced subroutine
       filltab_alltypes, &
       edgrid_g
  
  use ed_misc_coms, only: &
       iyeara,          &
       imontha,         &
       idatea,          &
       itimea,          &
       runtype
       
  use soil_coms, only: alloc_soilgrid
  use ed_node_coms , only: mynum,nnodetot,sendnum,recvnum

  implicit none

  real :: w1,w2,wtime_start  ! wall time
  real, external :: walltime    ! wall time
  character(len=12) :: c0
  character(len=12) :: c1
  integer           :: ifm
  real              :: t1

  !   MPI header
  include 'mpif.h'

  integer :: ierr
  integer :: ping 

  ping = 741776

  wtime_start=walltime(0.)
  w1=walltime(wtime_start)

  !---------------------------------------------------------------------------!
  ! STEP 1: Set the ED model parameters                                       !
  !---------------------------------------------------------------------------!

  if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] Load_Ed_Ecosystem_Params...'
  call load_ed_ecosystem_params()
  
  !---------------------------------------------------------------------------!
  ! STEP 2: Overwrite the parameters in case a XML file is provided           !
  !---------------------------------------------------------------------------!

  ! THIS IS SHOULD ONLY BE TRUE FOR A STAND-ALONE RUN
  if (mynum == nnodetot-1) sendnum = 0

  if (mynum /= 1) call MPI_RECV(ping,1,MPI_INTEGER,recvnum,80,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierr)
  if (mynum == 1) write (unit=*,fmt='(a)') ' [+] Checking for XML config...'
  
  call overwrite_with_xml_config(mynum)
  
  if (mynum < nnodetot ) call MPI_Send(ping,1,MPI_INTEGER,sendnum,80,MPI_COMM_WORLD,ierr)
  if (nnodetot /= 1 ) call MPI_Barrier(MPI_COMM_WORLD,ierr)
  
  !---------------------------------------------------------------------------!
  ! STEP 3: Allocate soil grid arrays                                         !
  !---------------------------------------------------------------------------!
  
  if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] Alloc_Soilgrid...'
  call alloc_soilgrid()
  
  !---------------------------------------------------------------------------------!
  ! STEP 4: Set some polygon-level basic information, such as lon/lat/soil texture  !
  !---------------------------------------------------------------------------------!
  
  if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] Set_Polygon_Coordinates...'
  call set_polygon_coordinates()
  
  !---------------------------------------------------------------------------!
  ! STEP 5: Initialize inherent soil and vegetation properties.               !
  !---------------------------------------------------------------------------!
  
  if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] Sfcdata_ED...'
  call sfcdata_ed()
  
  
  if (trim(runtype) == 'HISTORY' ) then
       
 
     !-----------------------------------------------------------------------!
     ! STEP 6A: Initialize the model state as a replicate image of a previous
     !          state.
     !-----------------------------------------------------------------------!

     if (mynum == nnodetot-1) sendnum = 0
     
     if (mynum /= 1) call MPI_RECV(ping,1,MPI_INTEGER,recvnum,81,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierr)
  
     if (mynum == 1) write (unit=*,fmt='(a)') ' [+] Init_Full_History_Restart...'
     call init_full_history_restart()
     
     if (mynum < nnodetot ) call MPI_Send(ping,1,MPI_INTEGER,sendnum,81,MPI_COMM_WORLD,ierr)
     if (nnodetot /= 1 ) call MPI_Barrier(MPI_COMM_WORLD,ierr)
     
  else
     
     !------------------------------------------------------------------------!
     ! STEP 6B: Initialize state properties of polygons/sites/patches/cohorts !
     !------------------------------------------------------------------------!
     
     if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] Load_Ecosystem_State...'
     call load_ecosystem_state()

  end if


  !-----------------------------------------------------------------------!
  ! STEP 8: Initialize meteorological drivers                             !
  !-----------------------------------------------------------------------!
  
  if (nnodetot /= 1) call MPI_Barrier(MPI_COMM_WORLD,ierr)
  
  if (mynum == nnodetot-1) sendnum = 0

  if (mynum /= 1) call MPI_RECV(ping,1,MPI_INTEGER,recvnum,82,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierr)

  if (mynum == 1) write (unit=*,fmt='(a)') ' [+] Init_Met_Drivers...'
  call init_met_drivers
  
  if (mynum == 1) write (unit=*,fmt='(a)') ' [+] Read_Met_Drivers_Init...'
  call read_met_drivers_init


  if (mynum < nnodetot ) call MPI_Send(ping,1,MPI_INTEGER,sendnum,82,MPI_COMM_WORLD,ierr)
  if (nnodetot /= 1 ) call MPI_Barrier(MPI_COMM_WORLD,ierr)
     
  !-----------------------------------------------------------------------!
  ! STEP 9. Initialize ed fields that depend on the atmosphere
  !-----------------------------------------------------------------------!
  
  if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] Ed_Init_Atm...'
  call ed_init_atm
  

  !--------------------------------------------------------------------------------!
  ! STEP 7: Initialize hydrology related variables                                 !
  !--------------------------------------------------------------------------------!
  if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] initHydrology...'
  call initHydrology()

  !-----------------------------------------------------------------------!
  ! STEP 10. Initialized some derived variables. This must be done        !
  !          outside init_full_history_restart because it depends on some !
  !          meteorological variables that are initialized at step 9.     !
  !-----------------------------------------------------------------------!
  if (trim(runtype) == 'HISTORY') then
     do ifm=1,ngrids
        call update_derived_props(edgrid_g(ifm))
     end do
  end if
  
  !-----------------------------------------------------------------------!
  ! STEP 11. Fill the variable data-tables with all of the state          !
  !          data.  Also calculate the indexing of the vectors            !
  !          to allow for segmented I/O of hyperslabs and referencing     !
  !          of high level hierarchical data types with their parent      !
  !          types.                                                       !
  !-----------------------------------------------------------------------!
  
  if (mynum == nnodetot) write (unit=*,fmt='(a)') ' [+] Filltab_Alltypes...'
  call filltab_alltypes

  !-----------------------------------------------------------------------!
  ! STEP 12. Checking how the output was configure and determining the    !
  !          averaging frequency.                                         !
  !-----------------------------------------------------------------------!
  if (mynum == nnodetot) write(unit=*,fmt='(a)') ' [+] Finding frqsum...'
  call find_frqsum()
  
  
  !-----------------------------------------------------------------------!
  ! STEP 13. Getting the CPU time and printing the banner                 !
  !-----------------------------------------------------------------------!
  call timing(1,t1)
  w2=walltime(wtime_start)
  write(c0,'(f12.2)') t1
  write(c1,'(f12.2)') w2-w1
  write(*,'(/,a,/)') ' === Finish initialization; CPU(sec)='//&
       trim(adjustl(c0))//'; Wall(sec)='//trim(adjustl(c1))//&
       '; Time integration starts (ed_master) ===' 
  
  
  !-----------------------------------------------------------------------!
  ! STEP 14. Running the model or skipping if it is a zero time run       !
  !-----------------------------------------------------------------------!
  if (time < timmax  ) then
     call ed_model()
  end if

  return
end subroutine ed_driver
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine find_frqsum()
   use ed_misc_coms, only:  &
        unitfast,        &
        unitstate,       &
        isoutput,        &
        ifoutput,        &
        itoutput,        &
        imoutput,        &
        idoutput,        &
        frqstate,        &
        frqfast,         &
        frqsum
   use consts_coms, only: day_sec

   implicit none 

   !---------------------------------------------------------------------------------------!
   ! Determining which frequency I should use to normalize variables. FRQSUM should never  !
   ! exceed 1 day.                                                                         !
   !---------------------------------------------------------------------------------------!
   if (ifoutput == 0 .and. isoutput == 0 .and. idoutput == 0 .and. imoutput == 0 .and.     &
       itoutput == 0 ) then
      write(unit=*,fmt='(a)') '---------------------------------------------------------'
      write(unit=*,fmt='(a)') '  WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! '
      write(unit=*,fmt='(a)') '  WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! '
      write(unit=*,fmt='(a)') '  WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! '
      write(unit=*,fmt='(a)') '  WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! '
      write(unit=*,fmt='(a)') '  WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! '
      write(unit=*,fmt='(a)') '  WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! '
      write(unit=*,fmt='(a)') '---------------------------------------------------------'
      write(unit=*,fmt='(a)') ' You are running a simulation that will have no output...'
      frqsum=day_sec ! This avoids the number to get incredibly large.

   !---------------------------------------------------------------------------------------!
   !     Either no instantaneous output was requested, or the user is outputting it at     !
   ! monthly or yearly scale, force it to be one day.                                      !
   !---------------------------------------------------------------------------------------!
   elseif ((isoutput == 0 .and. (ifoutput == 0 .and. itoutput == 0)) .or.                  &
           ((ifoutput == 0.and. itoutput == 0) .and.                                       &
             isoutput  > 0 .and. unitstate > 1) .or.                                       &
           (isoutput == 0 .and. (ifoutput > 0 .or. itoutput > 0) .and. unitfast  > 1) .or. &
           ((ifoutput  > 0 .or. itoutput > 0) .and.                                        &
             isoutput  > 0 .and. unitstate > 1 .and. unitfast > 1)                         &
          ) then
      frqsum=day_sec
   !---------------------------------------------------------------------------------------!
   !    Only restarts, and the unit is in seconds, test which frqsum to use.               !
   !---------------------------------------------------------------------------------------!
   elseif (ifoutput == 0 .and. itoutput == 0 .and. isoutput > 0) then
      frqsum=min(frqstate,day_sec)
   !---------------------------------------------------------------------------------------!
   !    Only fast analysis, and the unit is in seconds, test which frqsum to use.          !
   !---------------------------------------------------------------------------------------!
   elseif (isoutput == 0 .and. (ifoutput > 0 .or. itoutput > 0)) then
      frqsum=min(frqfast,day_sec)
   !---------------------------------------------------------------------------------------!
   !    Both are on and both outputs are in seconds or day scales. Choose the minimum      !
   ! between them and one day.                                                             !
   !---------------------------------------------------------------------------------------!
   elseif (unitfast < 2 .and. unitstate < 2) then 
      frqsum=min(min(frqstate,frqfast),day_sec)
   !---------------------------------------------------------------------------------------!
   !    Both are on but unitstate is in month or years. Choose the minimum between frqfast !
   ! and one day.                                                                          !
   !---------------------------------------------------------------------------------------!
   elseif (unitfast < 2) then 
      frqsum=min(frqfast,day_sec)
   !---------------------------------------------------------------------------------------!
   !    Both are on but unitfast is in month or years. Choose the minimum between frqstate !
   ! and one day.                                                                          !
   !---------------------------------------------------------------------------------------!
   else
      frqsum=min(frqstate,day_sec)
   end if

   return
end subroutine find_frqsum
!==========================================================================================!
!==========================================================================================!
