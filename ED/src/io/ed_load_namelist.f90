
subroutine read_nl(namelist_name)

  use ename_coms, only : nl
  
  implicit none
  character(len=*), intent(in) :: namelist_name
  logical :: fexists
  namelist /ED_NL/ nl

  !Open the namelist file
  inquire (file=trim(namelist_name),exist=fexists)
  if (.not. fexists) then
     print*, "The namelist file "//trim(namelist_name)//" is missing."
     stop "Stopping model run."
  endif

  ! READ GRID POINT AND OPTIONS INFORMATION FROM THE NAMELIST
  open(unit=10, status='OLD', file=namelist_name)
  read(unit=10, nml=ED_NL)
  close(unit=10)

  return
end subroutine read_nl

!------------------------------------------------------------------------------------------!
subroutine copy_nl(copy_type)

  use ed_max_dims , only: n_pft, nzgmax
  use ename_coms, only: nl
  use soil_coms, only: isoilflg, nslcon, slmstr, stgoff, zrough, soil_database, &
       isoilstateinit, isoildepthflg, isoilbc, soilstate_db, soildepth_db,   &
                       runoff_time, slz,veg_database
  use met_driver_coms, only: ed_met_driver_db, ishuffle, metcyc1, metcycf,imettype,initial_co2, lapse_scheme
  use mem_sites, only: n_soi, soi_lat, soi_lon, n_ed_region, ed_reg_latmin,  &
       ed_reg_latmax, ed_reg_lonmin, ed_reg_lonmax, grid_res, grid_type, edres, &
       maxpatch, maxcohort
  use physiology_coms, only: istoma_scheme, n_plant_lim
  use phenology_coms, only: iphen_scheme,iphenys1,iphenysf,iphenyf1,iphenyff,phenpath,repro_scheme
  use decomp_coms, only: n_decomp_lim, LloydTaylor
  use disturb_coms, only: include_fire, ianth_disturb,   &
       treefall_disturbance_rate
  use pft_coms, only: include_these_pft,agri_stock,plantation_stock,pft_1st_check

  use ed_misc_coms, only: expnme, runtype, itimez, idatez, imonthz, iyearz,  &
       itimea, idatea, imontha, iyeara, itimeh, idateh, imonthh, iyearh, &
       ifoutput, iclobber, frqfast, &
       sfilin, ied_init_mode, current_time, ed_inputs_dir,   &
       end_time, radfrq, integration_scheme, ffilout, idoutput,imoutput,&
       iyoutput, itoutput, dtlsm, &
       frqstate,sfilout,isoutput,iprintpolys,printvars,npvars,pfmtstr,ipmax,ipmin, &
       iedcnfgf, outfast, outstate,unitfast,unitstate,event_file

  use grid_coms, only: time,centlon,centlat,deltax,deltay,nnxp,nnyp,nstratx, &
                       nstraty,polelat,polelon,ngrids,timmax,time,nzg, nzs

  use ed_misc_coms,only: attach_metadata
  use canopy_air_coms, only:  icanturb, isfclyrm

  use optimiz_coms, only : ioptinpt

  use canopy_radiation_coms, only : crown_mod
  
  use rk4_coms, only : ibranch_thermo

  use ed_para_coms,only: loadmeth


  implicit none

  character(len=*) :: copy_type
  integer :: ifm

  if (copy_type == 'ALL_CASES') then

     ! The namelist variables in this section will always be used from the
     ! namelist, regardless of which type of run this is (a history start or 
     ! not).  This allows model options to be changed if it is a history start.
        
     expnme   = nl%expnme
     runtype  = nl%runtype
     loadmeth = nl%loadmeth

     itimez   = nl%itimez
     idatez   = nl%idatez
     imonthz  = nl%imonthz
     iyearz   = nl%iyearz
     dtlsm    = nl%dtlsm
     radfrq   = nl%radfrq

     ifoutput = nl%ifoutput
     idoutput = nl%idoutput
     imoutput = nl%imoutput
     iyoutput = nl%iyoutput
     itoutput = nl%itoutput
     isoutput = nl%isoutput

     attach_metadata = nl%attach_metadata

     iclobber        = nl%iclobber
     unitfast        = nl%unitfast
     unitstate       = nl%unitstate
     frqfast         = nl%frqfast
     frqstate        = nl%frqstate
     outfast         = nl%outfast
     outstate        = nl%outstate
     
     sfilin          = nl%sfilin
     itimeh          = nl%itimeh
     idateh          = nl%idateh
     imonthh         = nl%imonthh
     iyearh          = nl%iyearh
     
     ffilout         = nl%ffilout
     sfilout         = nl%sfilout
     ied_init_mode   = nl%ied_init_mode

     isoilflg      = nl%isoilflg
     nslcon        = nl%nslcon
     slmstr(1:nzgmax) = nl%slmstr(1:nzgmax)
     stgoff(1:nzgmax) = nl%stgoff(1:nzgmax)

     soil_database = nl%soil_database
     veg_database = nl%veg_database
     ed_inputs_dir = trim(nl%ed_inputs_dir)

     ed_met_driver_db = trim(nl%ed_met_driver_db)
     soilstate_db = nl%soilstate_db
     soildepth_db = nl%soildepth_db
     isoilstateinit = nl%isoilstateinit
     isoildepthflg = nl%isoildepthflg
     isoilbc       = nl%isoilbc

     n_soi         = nl%n_soi
     n_ed_region   = nl%n_ed_region
     grid_res      = nl%grid_res
     grid_type     = nl%grid_type
     soi_lat       = nl%soi_lat
     soi_lon       = nl%soi_lon
     ed_reg_latmin = nl%ed_reg_latmin
     ed_reg_latmax = nl%ed_reg_latmax
     ed_reg_lonmin = nl%ed_reg_lonmin
     ed_reg_lonmax = nl%ed_reg_lonmax

     integration_scheme = nl%integration_scheme
     ibranch_thermo     = nl%ibranch_thermo
     istoma_scheme      = nl%istoma_scheme
     iphen_scheme       = nl%iphen_scheme
     repro_scheme       = nl%repro_scheme
     lapse_scheme       = nl%lapse_scheme
     crown_mod          = nl%crown_mod
     n_plant_lim        = nl%n_plant_lim
     n_decomp_lim       = nl%n_decomp_lim
     include_fire       = nl%include_fire
     ianth_disturb      = nl%ianth_disturb

     !----- Decomp_scheme is not a true ED variable, we save it in LloydTaylor instead. ---!
     LloydTaylor        = nl%decomp_scheme == 1
     
     icanturb           = nl%icanturb
     isfclyrm           = nl%isfclyrm

     include_these_pft = nl%include_these_pft
     agri_stock        = nl%agri_stock
     plantation_stock  = nl%plantation_stock
     pft_1st_check     = nl%pft_1st_check
     
     treefall_disturbance_rate = nl%treefall_disturbance_rate
     runoff_time   = nl%runoff_time

     ! Print control parameters
     iprintpolys   = nl%iprintpolys
     npvars        = nl%npvars
     printvars     = nl%printvars
     pfmtstr       = nl%pfmtstr
     ipmin         = nl%ipmin
     ipmax         = nl%ipmax

     imettype      = nl%imettype
     ishuffle      = nl%ishuffle
     metcyc1       = nl%metcyc1
     metcycf       = nl%metcycf
     initial_co2   = nl%initial_co2
     
     iphenys1      = nl%iphenys1
     iphenysf      = nl%iphenysf
     iphenyf1      = nl%iphenyf1
     iphenyff      = nl%iphenyff
     
     iedcnfgf      = nl%iedcnfgf
     event_file    = nl%event_file
     phenpath      = nl%phenpath
     maxpatch      = nl%maxpatch
     maxcohort     = nl%maxcohort
     ioptinpt      = nl%ioptinpt
     zrough        = nl%zrough
     
     nnxp          = nl%nnxp
     nnyp          = nl%nnyp

     deltax        = nl%deltax
     deltay        = nl%deltay
     
     polelat       = nl%polelat
     polelon       = nl%polelon
     
     centlat       = nl%centlat
     centlon       = nl%centlon
     
     nstratx       = nl%nstratx
     nstraty       = nl%nstraty
     
     edres         = nl%edres

     ! If the grid type is lat/lon, then I reset nnxp and nnyp to fit this new grid
     ! This is going to be useful to distribute the polygons across the nodes.
     ngrids = n_ed_region + n_soi
     
     do ifm=1,n_ed_region
        if (grid_type == 0) then
           nnxp(ifm)=floor(real(nstratx(ifm))*(ed_reg_lonmax(ifm)-ed_reg_lonmin(ifm))/grid_res)
           nnyp(ifm)=floor(real(nstratx(ifm))*(ed_reg_latmax(ifm)-ed_reg_latmin(ifm))/grid_res)
        endif
     end do

     do ifm=n_ed_region+1,ngrids
        nnxp(ifm) = 1
        nnyp(ifm) = 1
        nstratx(ifm)=1
        nstraty(ifm)=1
     enddo

     ! set current time to initial time here.  If this is a history run,
     ! reset current time in subroutine history_start.
     end_time%year = iyearz
     end_time%month = imonthz
     end_time%date = idatez
     end_time%time = real(int(real(itimez) * 0.01)) * 3600.0   &
          + (real(itimez) * 0.01 - real(int(real(itimez)*0.01)))*100.0*60.0

  elseif (copy_type == 'NOT_HISTORY') then
        
     ! The namelist variables in this section either must not be changed on a
     ! history restart or changing them would be irrelevant.  Thus, they are
     ! only copied to main model memory if this is not a history restart.

     itimea   = nl%itimea
     idatea   = nl%idatea
     imontha  = nl%imontha
     iyeara   = nl%iyeara

     nzg      = nl%nzg
     nzs      = nl%nzs

     slz(1:nzgmax) = nl%slz(1:nzgmax)
     
     ! set current time to initial time here.  If this is a history run,
     ! reset current time in subroutine history_start.
     current_time%year = iyeara
     current_time%month = imontha
     current_time%date = idatea
     current_time%time = real(int(real(itimea) * 0.01)) * 3600.0   &
          + (real(itimea) * 0.01 - real(int(real(itimea)*0.01)))*100.0*60.0
     
     time = 0.0d0
  elseif (copy_type == 'HISTORY') then
        
     ! The namelist variables in this section either must not be changed on a
     ! history restart or changing them would be irrelevant.  Thus, they are
     ! only copied to main model memory if this is not a history restart.

     itimea   = nl%itimea
     idatea   = nl%idatea
     imontha  = nl%imontha
     iyeara   = nl%iyeara

     nzg      = nl%nzg
     nzs      = nl%nzs

     slz(1:nzgmax) = nl%slz(1:nzgmax)
     
     ! set current time to initial time here.  If this is a history run,
     ! reset current time in subroutine history_start.

     current_time%year  = nl%iyearh
     current_time%month = nl%imonthh
     current_time%date  = nl%idateh
     current_time%time  = real(int(real(nl%itimeh) * 0.01)) * 3600.0   &
          + (real(nl%itimeh) * 0.01 - real(int(real(nl%itimeh)*0.01)))*100.0*60.0

     ! Calculate the current time
     call date_2_seconds (nl%iyearh,nl%imonthh,nl%idateh,nl%itimeh*100, &
          iyeara,imontha,idatea,itimea*100,time)

  end if

  ! Sorting up the chosen PFTs
  where (include_these_pft < 1) 
     include_these_pft=huge(1)
  end where

  call sort_up(include_these_pft,n_pft)
     
  !  Determine the length of simuation
  call date_2_seconds (iyearz,imonthz,idatez,itimez*100, &
          iyeara,imontha,idatea,itimea*100,timmax)
  return
end subroutine copy_nl
!------------------------------------------------------------------------------------------!
