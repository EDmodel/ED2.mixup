# DO NOT DELETE THIS LINE - used by make depend
rcio.o: micro_coms.mod rpost_coms.mod somevars.mod therm_lib.mod
rpost_main.o: brams_data.mod misc_coms.mod rpost_coms.mod rpost_dims.mod
rpost_misc.o: misc_coms.mod rpost_dims.mod
variables.o: an_header.mod brams_data.mod leaf_coms.mod micro_coms.mod
variables.o: misc_coms.mod rconstants.mod rpost_coms.mod rpost_dims.mod
variables.o: somevars.mod therm_lib.mod
dted.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/Ramspost/src/include/utils_sub_names.h
dted.o:
eenviron.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/Ramspost/src/include/utils_sub_names.h
eenviron.o:
interp_lib.o: misc_coms.mod
leaf_coms.o: rconstants.mod therm_lib.mod
parlib.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/Ramspost/src/include/utils_sub_names.h
parlib.o:
rams_read_header.o: an_header.mod
rnamel.o: misc_coms.mod
therm_lib.o: rconstants.mod
tmpname.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/Ramspost/src/include/utils_sub_names.h
tmpname.o:
vformat_brams3.3.o: misc_coms.mod
brams_data.o: rpost_dims.mod
micro_coms.o: rpost_dims.mod
misc_coms.o: rpost_dims.mod
rpost_coms.o: rpost_dims.mod
numutils.o: rconstants.mod therm_lib.mod
polarst.o: rconstants.mod
utils_c.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/Ramspost/src/include/utils_sub_names.h
utils_c.o:
utils_f.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/Ramspost/src/include/interface.h
utils_f.o: an_header.mod misc_coms.mod
~utils_c.o: /n/Moorcroft_Lab/Users/mlongo/EDBRAMS/Ramspost/src/include/utils_sub_names.h
~utils_c.o:
an_header.mod: an_header.o
brams_data.mod: brams_data.o
leaf_coms.mod: leaf_coms.o
micro_coms.mod: micro_coms.o
misc_coms.mod: misc_coms.o
rconstants.mod: rconstants.o
rpost_coms.mod: rpost_coms.o
rpost_dims.mod: rpost_dims.o
somevars.mod: somevars.o
therm_lib.mod: therm_lib.o
