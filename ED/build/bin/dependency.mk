# DO NOT DELETE THIS LINE - used by make depend
ed_1st.o: ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod
ed_driver.o: consts_coms.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod
ed_driver.o: fuse_fiss_utils.mod grid_coms.mod soil_coms.mod
ed_met_driver.o: canopy_air_coms.mod consts_coms.mod ed_max_dims.mod
ed_met_driver.o: ed_misc_coms.mod ed_state_vars.mod grid_coms.mod hdf5_utils.mod
ed_met_driver.o: mem_polygons.mod met_driver_coms.mod therm_lib.mod
ed_model.o: consts_coms.mod disturb_coms.mod ed_misc_coms.mod ed_node_coms.mod
ed_model.o: ed_state_vars.mod grid_coms.mod mem_polygons.mod rk4_coms.mod
ed_model.o: rk4_driver.mod
canopy_struct_dynamics.o: allometry.mod canopy_air_coms.mod consts_coms.mod
canopy_struct_dynamics.o: ed_state_vars.mod met_driver_coms.mod pft_coms.mod
canopy_struct_dynamics.o: physiology_coms.mod rk4_coms.mod soil_coms.mod
disturbance.o: allometry.mod consts_coms.mod decomp_coms.mod disturb_coms.mod
disturbance.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
disturbance.o: ed_therm_lib.mod fuse_fiss_utils.mod grid_coms.mod
disturbance.o: mem_polygons.mod pft_coms.mod phenology_coms.mod
euler_driver.o: canopy_air_coms.mod canopy_struct_dynamics.mod consts_coms.mod
euler_driver.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod
euler_driver.o: hydrology_coms.mod met_driver_coms.mod rk4_coms.mod
euler_driver.o: rk4_driver.mod rk4_stepper.mod soil_coms.mod
events.o: allometry.mod consts_coms.mod decomp_coms.mod disturbance_utils.mod
events.o: ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod
events.o: fuse_fiss_utils.mod grid_coms.mod pft_coms.mod therm_lib.mod
farq_leuning.o: c34constants.mod consts_coms.mod pft_coms.mod phenology_coms.mod
farq_leuning.o: physiology_coms.mod rk4_coms.mod therm_lib8.mod
fire.o: allometry.mod consts_coms.mod disturb_coms.mod ed_state_vars.mod
fire.o: grid_coms.mod soil_coms.mod
forestry.o: allometry.mod disturb_coms.mod disturbance_utils.mod ed_max_dims.mod
forestry.o: ed_state_vars.mod fuse_fiss_utils.mod grid_coms.mod
growth_balive.o: allometry.mod consts_coms.mod decomp_coms.mod ed_max_dims.mod
growth_balive.o: ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod
growth_balive.o: grid_coms.mod mortality.mod pft_coms.mod phenology_coms.mod
growth_balive.o: physiology_coms.mod
heun_driver.o: canopy_air_coms.mod canopy_struct_dynamics.mod consts_coms.mod
heun_driver.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod
heun_driver.o: hydrology_coms.mod met_driver_coms.mod rk4_coms.mod
heun_driver.o: rk4_driver.mod rk4_stepper.mod soil_coms.mod
lsm_hyd.o: consts_coms.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod
lsm_hyd.o: grid_coms.mod hydrology_coms.mod hydrology_constants.mod pft_coms.mod
lsm_hyd.o: soil_coms.mod therm_lib.mod
mortality.o: consts_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod
mortality.o: ed_state_vars.mod pft_coms.mod
phenology_aux.o: allometry.mod consts_coms.mod ed_max_dims.mod ed_state_vars.mod
phenology_aux.o: ed_therm_lib.mod grid_coms.mod pft_coms.mod phenology_coms.mod
phenology_aux.o: soil_coms.mod
phenology_driv.o: allometry.mod consts_coms.mod decomp_coms.mod ed_max_dims.mod
phenology_driv.o: ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod
phenology_driv.o: grid_coms.mod pft_coms.mod phenology_coms.mod soil_coms.mod
photosyn_driv.o: consts_coms.mod ed_max_dims.mod ed_misc_coms.mod
photosyn_driv.o: ed_state_vars.mod farq_leuning.mod met_driver_coms.mod
photosyn_driv.o: pft_coms.mod physiology_coms.mod soil_coms.mod
radiate_driver.o: canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod
radiate_driver.o: ed_misc_coms.mod ed_state_vars.mod grid_coms.mod soil_coms.mod
reproduction.o: allometry.mod consts_coms.mod decomp_coms.mod ed_max_dims.mod
reproduction.o: ed_state_vars.mod ed_therm_lib.mod fuse_fiss_utils.mod
reproduction.o: grid_coms.mod mem_polygons.mod pft_coms.mod phenology_coms.mod
rk4_derivs.o: canopy_struct_dynamics.mod consts_coms.mod ed_max_dims.mod
rk4_derivs.o: ed_misc_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod
rk4_derivs.o: rk4_coms.mod soil_coms.mod therm_lib8.mod
rk4_driver.o: canopy_air_coms.mod canopy_struct_dynamics.mod consts_coms.mod
rk4_driver.o: ed_misc_coms.mod ed_state_vars.mod grid_coms.mod
rk4_driver.o: met_driver_coms.mod rk4_coms.mod soil_coms.mod therm_lib.mod
rk4_integ_utils.o: canopy_air_coms.mod consts_coms.mod ed_max_dims.mod
rk4_integ_utils.o: ed_misc_coms.mod ed_state_vars.mod grid_coms.mod
rk4_integ_utils.o: hydrology_coms.mod rk4_coms.mod rk4_stepper.mod soil_coms.mod
rk4_integ_utils.o: therm_lib8.mod
rk4_misc.o: canopy_air_coms.mod canopy_struct_dynamics.mod consts_coms.mod
rk4_misc.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod
rk4_misc.o: grid_coms.mod rk4_coms.mod soil_coms.mod therm_lib8.mod
rk4_stepper.o: ed_state_vars.mod grid_coms.mod rk4_coms.mod soil_coms.mod
soil_respiration.o: consts_coms.mod decomp_coms.mod ed_state_vars.mod
soil_respiration.o: pft_coms.mod soil_coms.mod
structural_growth.o: allometry.mod consts_coms.mod decomp_coms.mod
structural_growth.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
structural_growth.o: ed_therm_lib.mod pft_coms.mod phenology_coms.mod
twostream_rad.o: canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod
twostream_rad.o: pft_coms.mod rk4_coms.mod
vegetation_dynamics.o: consts_coms.mod disturb_coms.mod disturbance_utils.mod
vegetation_dynamics.o: ed_misc_coms.mod ed_state_vars.mod fuse_fiss_utils.mod
vegetation_dynamics.o: grid_coms.mod growth_balive.mod mem_polygons.mod
ed_init.o: consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod
ed_init.o: ed_state_vars.mod ed_work_vars.mod grid_coms.mod mem_polygons.mod
ed_init.o: phenology_coms.mod phenology_startup.mod rk4_coms.mod soil_coms.mod
ed_init_atm.o: canopy_struct_dynamics.mod consts_coms.mod ed_misc_coms.mod
ed_init_atm.o: ed_node_coms.mod ed_state_vars.mod ed_therm_lib.mod
ed_init_atm.o: fuse_fiss_utils.mod grid_coms.mod met_driver_coms.mod
ed_init_atm.o: pft_coms.mod soil_coms.mod therm_lib.mod
ed_nbg_init.o: allometry.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod
ed_nbg_init.o: ed_state_vars.mod ed_therm_lib.mod fuse_fiss_utils.mod
ed_nbg_init.o: grid_coms.mod pft_coms.mod physiology_coms.mod
ed_params.o: allometry.mod canopy_air_coms.mod canopy_radiation_coms.mod
ed_params.o: consts_coms.mod decomp_coms.mod disturb_coms.mod ed_max_dims.mod
ed_params.o: ed_misc_coms.mod fusion_fission_coms.mod grid_coms.mod
ed_params.o: hydrology_coms.mod met_driver_coms.mod pft_coms.mod
ed_params.o: phenology_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod
ed_type_init.o: allometry.mod canopy_air_coms.mod consts_coms.mod
ed_type_init.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
ed_type_init.o: ed_therm_lib.mod grid_coms.mod pft_coms.mod phenology_coms.mod
ed_type_init.o: soil_coms.mod therm_lib.mod
init_hydro_sites.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
init_hydro_sites.o: grid_coms.mod mem_polygons.mod soil_coms.mod
landuse_init.o: consts_coms.mod disturb_coms.mod ed_max_dims.mod
landuse_init.o: ed_misc_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod
phenology_startup.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
phenology_startup.o: grid_coms.mod phenology_coms.mod
average_utils.o: allometry.mod canopy_radiation_coms.mod consts_coms.mod
average_utils.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
average_utils.o: grid_coms.mod pft_coms.mod therm_lib.mod
ed_init_full_history.o: allometry.mod c34constants.mod consts_coms.mod
ed_init_full_history.o: ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod
ed_init_full_history.o: ed_state_vars.mod ed_therm_lib.mod
ed_init_full_history.o: fusion_fission_coms.mod grid_coms.mod 
ed_init_full_history.o: hdf5_coms.mod phenology_startup.mod soil_coms.mod
ed_init_full_history.o: therm_lib.mod
ed_load_namelist.o: canopy_air_coms.mod canopy_radiation_coms.mod
ed_load_namelist.o: consts_coms.mod decomp_coms.mod disturb_coms.mod
ed_load_namelist.o: ed_max_dims.mod ed_misc_coms.mod ed_para_coms.mod
ed_load_namelist.o: ename_coms.mod grid_coms.mod mem_polygons.mod
ed_load_namelist.o: met_driver_coms.mod optimiz_coms.mod pft_coms.mod
ed_load_namelist.o: phenology_coms.mod physiology_coms.mod rk4_coms.mod
ed_load_namelist.o: soil_coms.mod
ed_opspec.o: canopy_air_coms.mod canopy_radiation_coms.mod consts_coms.mod
ed_opspec.o: decomp_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod
ed_opspec.o: ed_para_coms.mod grid_coms.mod mem_polygons.mod met_driver_coms.mod
ed_opspec.o: pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod
ed_opspec.o: soil_coms.mod
ed_print.o: ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod
ed_print.o: ed_var_tables.mod
ed_read_ed10_20_history.o: allometry.mod consts_coms.mod disturb_coms.mod
ed_read_ed10_20_history.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
ed_read_ed10_20_history.o: fuse_fiss_utils.mod grid_coms.mod mem_polygons.mod
ed_read_ed10_20_history.o: pft_coms.mod
ed_read_ed21_history.o: allometry.mod consts_coms.mod disturb_coms.mod
ed_read_ed21_history.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod
ed_read_ed21_history.o: fuse_fiss_utils.mod grid_coms.mod  hdf5_coms.mod
ed_read_ed21_history.o: pft_coms.mod
ed_xml_config.o: canopy_radiation_coms.mod decomp_coms.mod disturb_coms.mod
ed_xml_config.o: ed_max_dims.mod ed_misc_coms.mod fusion_fission_coms.mod
ed_xml_config.o: grid_coms.mod hydrology_coms.mod met_driver_coms.mod
ed_xml_config.o: pft_coms.mod phenology_coms.mod physiology_coms.mod
ed_xml_config.o: rk4_coms.mod soil_coms.mod
edio.o: c34constants.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod
edio.o: ed_node_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod
edio.o: soil_coms.mod therm_lib.mod
h5_output.o: an_header.mod c34constants.mod ed_max_dims.mod ed_misc_coms.mod
h5_output.o: ed_node_coms.mod ed_state_vars.mod ed_var_tables.mod
h5_output.o: fusion_fission_coms.mod grid_coms.mod  hdf5_coms.mod
leaf_database.o: grid_coms.mod hdf5_utils.mod soil_coms.mod
canopy_air_coms.o: consts_coms.mod therm_lib.mod therm_lib8.mod
canopy_radiation_coms.o: ed_max_dims.mod
consts_coms.o: 
decomp_coms.o: ed_max_dims.mod
disturb_coms.o: ed_max_dims.mod
ed_max_dims.o: 
ed_mem_alloc.o: ed_max_dims.mod ed_mem_grid_dim_defs.mod ed_node_coms.mod
ed_mem_alloc.o: ed_state_vars.mod ed_work_vars.mod grid_coms.mod
ed_mem_alloc.o: mem_polygons.mod
ed_misc_coms.o: ed_max_dims.mod
ed_state_vars.o: c34constants.mod disturb_coms.mod ed_max_dims.mod
ed_state_vars.o: ed_misc_coms.mod ed_node_coms.mod ed_var_tables.mod
ed_state_vars.o: fusion_fission_coms.mod grid_coms.mod met_driver_coms.mod
ed_state_vars.o: phenology_coms.mod soil_coms.mod
ed_var_tables.o: ed_max_dims.mod
ed_work_vars.o: ed_max_dims.mod
ename_coms.o: ed_max_dims.mod
fusion_fission_coms.o: ed_max_dims.mod
grid_coms.o: ed_max_dims.mod
hdf5_coms.o: 
mem_polygons.o: ed_max_dims.mod
met_driver_coms.o: ed_max_dims.mod
optimiz_coms.o: ed_max_dims.mod
pft_coms.o: ed_max_dims.mod
phenology_coms.o: ed_max_dims.mod
physiology_coms.o: ed_max_dims.mod
rk4_coms.o: consts_coms.mod ed_max_dims.mod ed_misc_coms.mod grid_coms.mod
rk4_coms.o: soil_coms.mod therm_lib8.mod
soil_coms.o: ed_max_dims.mod grid_coms.mod 
ed_mpass_init.o: canopy_air_coms.mod canopy_radiation_coms.mod decomp_coms.mod
ed_mpass_init.o: disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod
ed_mpass_init.o: ed_node_coms.mod ed_para_coms.mod ed_state_vars.mod
ed_mpass_init.o: ed_work_vars.mod grid_coms.mod mem_polygons.mod
ed_mpass_init.o: met_driver_coms.mod optimiz_coms.mod pft_coms.mod
ed_mpass_init.o: phenology_coms.mod physiology_coms.mod rk4_coms.mod
ed_mpass_init.o: soil_coms.mod
ed_node_coms.o: ed_max_dims.mod
ed_para_coms.o: ed_max_dims.mod
ed_para_init.o: ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod
ed_para_init.o: ed_para_coms.mod ed_work_vars.mod grid_coms.mod 
ed_para_init.o: hdf5_coms.mod mem_polygons.mod soil_coms.mod
allometry.o: consts_coms.mod ed_misc_coms.mod grid_coms.mod pft_coms.mod
allometry.o: rk4_coms.mod soil_coms.mod therm_lib.mod
budget_utils.o: consts_coms.mod ed_max_dims.mod ed_misc_coms.mod
budget_utils.o: ed_state_vars.mod grid_coms.mod rk4_coms.mod soil_coms.mod
dateutils.o: consts_coms.mod
ed_filelist.o: ed_max_dims.mod
ed_grid.o: consts_coms.mod ed_max_dims.mod ed_node_coms.mod grid_coms.mod
ed_therm_lib.o: allometry.mod consts_coms.mod ed_max_dims.mod ed_state_vars.mod
ed_therm_lib.o: grid_coms.mod pft_coms.mod rk4_coms.mod soil_coms.mod
ed_therm_lib.o: therm_lib.mod therm_lib8.mod
fatal_error.o: ed_node_coms.mod
fuse_fiss_utils.o: allometry.mod consts_coms.mod decomp_coms.mod
fuse_fiss_utils.o: disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod
fuse_fiss_utils.o: ed_node_coms.mod ed_state_vars.mod fusion_fission_coms.mod
fuse_fiss_utils.o: grid_coms.mod mem_polygons.mod pft_coms.mod soil_coms.mod
fuse_fiss_utils.o: therm_lib.mod
great_circle.o: consts_coms.mod
hdf5_utils.o: hdf5_coms.mod
invmondays.o: ed_misc_coms.mod
lapse.o: consts_coms.mod ed_state_vars.mod met_driver_coms.mod
numutils.o: consts_coms.mod therm_lib.mod
stable_cohorts.o: ed_max_dims.mod ed_state_vars.mod pft_coms.mod
stable_cohorts.o: phenology_coms.mod
therm_lib.o: consts_coms.mod
therm_lib8.o: consts_coms.mod therm_lib.mod
update_derived_props.o: allometry.mod canopy_air_coms.mod consts_coms.mod
update_derived_props.o: ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod
update_derived_props.o: fuse_fiss_utils.mod grid_coms.mod soil_coms.mod
update_derived_props.o: therm_lib.mod
utils_c.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/ED/src/include/utils_sub_names.h
utils_c.o:
allometry.mod: allometry.o
an_header.mod: an_header.o
c34constants.mod: c34constants.o
canopy_air_coms.mod: canopy_air_coms.o
canopy_radiation_coms.mod: canopy_radiation_coms.o
canopy_struct_dynamics.mod: canopy_struct_dynamics.o
consts_coms.mod: consts_coms.o
decomp_coms.mod: decomp_coms.o
disturb_coms.mod: disturb_coms.o
disturbance_utils.mod: disturbance.o
ed_max_dims.mod: ed_max_dims.o
ed_mem_grid_dim_defs.mod: ed_mem_grid_dim_defs.o
ed_misc_coms.mod: ed_misc_coms.o
ed_node_coms.mod: ed_node_coms.o
ed_para_coms.mod: ed_para_coms.o
ed_state_vars.mod: ed_state_vars.o
ed_therm_lib.mod: ed_therm_lib.o
ed_var_tables.mod: ed_var_tables.o
ed_work_vars.mod: ed_work_vars.o
ename_coms.mod: ename_coms.o
farq_leuning.mod: farq_leuning.o
fuse_fiss_utils.mod: fuse_fiss_utils.o
fusion_fission_coms.mod: fusion_fission_coms.o
grid_coms.mod: grid_coms.o
growth_balive.mod: growth_balive.o
hdf5_coms.mod: hdf5_coms.o
hdf5_utils.mod: hdf5_utils.o
hydrology_coms.mod: hydrology_coms.o
hydrology_constants.mod: hydrology_constants.o
libxml2f90_interface_module.mod: libxml2f90.f90_pp.o
libxml2f90_module.mod: libxml2f90.f90_pp.o
libxml2f90_strings_module.mod: libxml2f90.f90_pp.o
ll_module.mod: libxml2f90.f90_pp.o
mem_polygons.mod: mem_polygons.o
met_driver_coms.mod: met_driver_coms.o
mortality.mod: mortality.o
optimiz_coms.mod: optimiz_coms.o
pft_coms.mod: pft_coms.o
phenology_coms.mod: phenology_coms.o
phenology_startup.mod: phenology_startup.o
physiology_coms.mod: physiology_coms.o
rk4_coms.mod: rk4_coms.o
rk4_driver.mod: rk4_driver.o
rk4_stepper.mod: rk4_stepper.o
soil_coms.mod: soil_coms.o
therm_lib.mod: therm_lib.o
therm_lib8.mod: therm_lib8.o
