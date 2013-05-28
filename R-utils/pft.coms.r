#==========================================================================================#
#==========================================================================================#
#     This module contains several parameters used in the Farquar Leuning photosynthesis   #
# solver.  The following references are used as a departing point:                         #
# - M09 - Medvigy, D.M., S. C. Wofsy, J. W. Munger, D. Y. Hollinger, P. R. Moorcroft,      #
#         2009: Mechanistic scaling of ecosystem function and dynamics in space and time:  #
#         Ecosystem Demography model version 2.  J. Geophys. Res., 114, G01002,            #
#         doi:10.1029/2008JG000812.                                                        #
# - M06 - Medvigy, D.M., 2006: The State of the Regional Carbon Cycle: results from a      #
#         constrained coupled ecosystem-atmosphere model, 2006.  Ph.D. dissertation,       #
#         Harvard University, Cambridge, MA, 322pp.                                        #
# - M01 - Moorcroft, P. R., G. C. Hurtt, S. W. Pacala, 2001: A method for scaling          #
#         vegetation dynamics: the ecosystem demography model, Ecological Monographs, 71,  #
#         557-586.                                                                         #
# - F96 - Foley, J. A., I. Colin Prentice, N. Ramankutty, S. Levis, D. Pollard, S. Sitch,  #
#         A. Haxeltime, 1996: An integrated biosphere model of land surface processes,     #
#         terrestrial carbon balance, and vegetation dynamics. Glob. Biogeochem. Cycles,   #
#         10, 603-602.                                                                     #
# - L95 - Leuning, R., F. M. Kelliher, D. G. G. de Pury, E. D. Schulze, 1995: Leaf         #
#         nitrogen, photosynthesis, conductance, and transpiration: scaling from leaves to #
#         canopies. Plant, Cell, and Environ., 18, 1183-1200.                              #
# - C91 - Collatz, G. J., J. T. Ball, C. Grivet, J. A. Berry, 1991: Physiological and      #
#         environmental regulation of stomatal conductance, photosynthesis and             #
#         transpiration: A model that includes a laminar boundary layer. Agric. For.       #
#         Meteor., 53, 107-136.                                                            #
# - B01 - Bernacchi, C. J., E. L. Singsaas, C. Pimentel, A. R. Portis Jr., S. P. Long,     #
#         2001: Improved temperature response functions for models of Rubisco-limited      #
#         photosynthesis. Plant, Cell and Environ., 24, 253-259.                           #
# - B02 - Bernacchi, C. J., A. R. Portis, H. Nakano, S. von Caemmerer, S. P. Long,         #
#         2002: Temperature response of mesophyll conductance.  Implications for the       #
#         determination of Rubisco enzyme kinetics and for limitations to photosynthesis   #
#         in vivo.  Plant physiol., 130, 1992-1998.                                        #
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#     Bounds for internal carbon and water stomatal conductance.                           #
#------------------------------------------------------------------------------------------#
c34smin.lint.co2 <<- 10.   * umol.2.mol # Minimum carbon dioxide concentration  [  mol/mol]
c34smax.lint.co2 <<- 1200. * umol.2.mol # Maximum carbon dioxide concentration  [  mol/mol]
c34smax.gsw      <<- 1.e+2              # Max. stomatal conductance (water)     [ mol/m2/s]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     Many parameters in the model are temperature-dependent and utilise a modified        #
# Arrhenius function to determine this dependence.  For that to work, reference values at  #
# a given temperature (tarrh, in Kelvin).                                                  #
#------------------------------------------------------------------------------------------#
tarrh        <<- 15.0+t00
tarrhi       <<- 1./tarrh
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     This is an alternative way to express the temperature dependence, which is used by   #
# C91.  (tcollatz, in Kelvin).  fcollatz is the factor that multiply the temperature       #
# departure from reference.                                                                #
#------------------------------------------------------------------------------------------#
tcollatz        <<- 25.0+t00
fcollatz        <<- 0.1
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#     The next two variables are the parameters for the compensation point as in IBIS.     #
#------------------------------------------------------------------------------------------#
compp.ref.ibis  <<-  o2.ref / (2 * 4500.) # Gamma* reference                     [ mol/mol]
compp.hor.ibis  <<- 5000.                 # Gamma* "Activation energy"           [       K]
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#     The next two variables are the parameters for the compensation point.  Notice that   #
# we give the compensation point rather than tau.                                          #
#------------------------------------------------------------------------------------------#
compp.ref.coll  <<-  o2.ref * 0.57 / (2 * 2600.) # Ref. value at 15C (not 25C)   [ mol/mol]
compp.base.coll <<-  1/0.57                      # Comp. point base parameter    [    ----]
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#     The next three variables are the parameters for the compensation point using         #
# Bernacchi data.  Their equation is the Arrhenius formula, just expressed in a different  #
# way, so here we give the converted values.  They have 2 papers, in which the results are #
# quite different, so I will add both here.                                                #
#------------------------------------------------------------------------------------------#
compp.ref.b01 <<-  25.28064 * umol.2.mol # Reference compensation point at 25 C  [ mol/mol]
compp.hor.b01 <<-  4549.877              # Compensation point "c" parameter      [    ----]
compp.ref.b02 <<-  26.59113 * umol.2.mol # Reference compensation point at 25 C  [ mol/mol]
compp.hor.b02 <<-  2941.845              # Compensation point "c" parameter      [    ----]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#      The following terms are used to find the Michaelis-Menten coefficient for CO2.      #
#------------------------------------------------------------------------------------------#
kco2.ref.ibis  <<- 150. * umol.2.mol # Reference CO2 concentration               [ mol/mol]
kco2.hor.ibis  <<- 6000.             # Reference exponential coefficient         [       K]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     The next two variables are the parameters for the Michaelis-Menten coefficients when #
# using Collatz equation.  Collatz equation uses partial pressure, so we must convert them #
# to mixing ratio.  Also, we use the reference at 15 C rather than 25 C, so Vm is the      #
# same.                                                                                    #
#------------------------------------------------------------------------------------------#
kco2.ref.coll  <<-  30. * mmco2 * mmdryi / prefsea / 2.1 # Ref. CO2 conc.        [ mol/mol]
kco2.base.coll <<-  2.1                                  # Power base            [    ----]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     The next two variables are the parameters for the Michaelis-Menten coefficients when #
# using Bernacchi equations.                                                               #
#------------------------------------------------------------------------------------------#
kco2.ref.b01  <<-  133.38 * umol.2.mol            # Reference CO2 concentration  [ mol/mol]
kco2.hor.b01  <<-  9553.179                       # "Activation energy           [       K]
kco2.ref.b02  <<-  87.828 * umol.2.mol            # Reference CO2 concentration  [ mol/mol]
kco2.hor.b02  <<-  9740.803                       # "Activation energy           [       K]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     These terms are used to find the Michaelis-Menten coefficient for O2.                #
#------------------------------------------------------------------------------------------#
ko2.ref.ibis  <<- 0.250     # Reference O2 concentration.                        [ mol/mol]
ko2.hor.ibis  <<-  1400.    # Reference exponential coefficient                  [       K]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     These terms are used to find the Michaelis-Menten coefficient for O2.  Notice that   #
# the reference must be given at 15 C, not 25 C as usual.                                  #
#------------------------------------------------------------------------------------------#
ko2.ref.coll   <<- 3.e4 * mmo2 * mmdryi / prefsea / 1.2 # Ref. O2 concentration.  [ mol/mol]
ko2.base.coll  <<-  1.2                                 # Power base              [    ----]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     These terms are used to find the Michaelis-Menten coefficient for O2 using the       #
# Bernacchi et al. (2002) method.                                                          #
#------------------------------------------------------------------------------------------#
ko2.ref.b01  <<-  0.1665438                       # Reference O2 concentration   [ mol/mol]
ko2.hor.b01  <<-  4376.483                        # "Activation energy           [       K]
ko2.ref.b02  <<-  0.1190386                       # Reference O2 concentration   [ mol/mol]
ko2.hor.b02  <<-  2852.844                        # "Activation energy           [       K]
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     These are constants obtained in Leuning et al. (1995) and Collatz et al. (1991) to   #
# convert different conductivities.                                                        #
#------------------------------------------------------------------------------------------#
gbh.2.gbw  <<- 1.075               # heat   to water  - leaf boundary layer
gsc.2.gsw  <<- 1.60                # carbon to water  - stomata
gbc.2.gbw  <<- gsc.2.gsw^twothirds # carbon to water  - leaf boundary layer
gsw.2.gsc  <<- 1.0 / gsc.2.gsw     # water  to carbon - stomata
gbw.2.gbc  <<- 1.0 / gbc.2.gbw     # water  to carbon - leaf boundary layer
gsc.2.gsw  <<- 1.0 / gsw.2.gsc     # carbon to water  - stomata
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     This is the minimum threshold for the photosynthetically active radiation, in        #
# umol/m2/s to consider non-night time conditions (day time or twilight).                  #
#------------------------------------------------------------------------------------------#
par.twilight.min <<- 0.5 * Watts.2.Ein # Minimum non-nocturnal PAR.              [mol/m2/s]
#------------------------------------------------------------------------------------------#

#----- This is a flag for the maximum representable number in R. --------------------------#
discard <<- 2^1023
#------------------------------------------------------------------------------------------#



#----- Fudging parameters to try to tune photosynthesis. ----------------------------------#
if (! "alpha.c3" %in% ls()){
   alpha.c3  <<-   0.08
}else{
   alpha.c3  <<-   alpha.c3
}#end if
if (! "alpha.c4" %in% ls()){
   alpha.c4  <<-   0.053
}else{
   alpha.c4  <<-   alpha.c4
}#end if
if (! "vmfact.c3" %in% ls()){
   vmfact.c3  <<-   1.0   
}else{
   vmfact.c3  <<-   vmfact.c3
}#end if
if (! "vmfact.c4" %in% ls()){
   vmfact.c4  <<-   1.0   
}else{
   vmfact.c4  <<-   vmfact.c4
}#end if
if (! "mphoto.c3" %in% ls()){
   mphoto.c3  <<-   8.0   
}else{
   mphoto.c3  <<-   mphoto.c3
}#end if
if (! "mphoto.aa" %in% ls()){
   mphoto.aa  <<-   6.4   
}else{
   mphoto.aa  <<-   mphoto.aa
}#end if
if (! "mphoto.c4" %in% ls()){
   mphoto.c4  <<-   4.0
}else{
   mphoto.c4  <<-   mphoto.c4
}#end if
if (! "gamma.c3" %in% ls()){
   gamma.c3  <<-   0.020
}else{
   gamma.c3  <<-   gamma.c3
}#end if
if (! "gamma.aa" %in% ls()){
   gamma.aa  <<-   0.028
}else{
   gamma.aa  <<-   gamma.aa
}#end if
if (! "gamma.c4" %in% ls()){
   gamma.c4  <<-   0.040
}else{
   gamma.c4  <<-   gamma.c4
}#end if
if (! "d0.grass" %in% ls()){
   d0.grass      <<-   0.01
}else{
   d0.grass      <<-   d0.grass
}#end if
if (! "d0.tree" %in% ls()){
   d0.tree      <<-   0.01
}else{
   d0.tree      <<-   d0.tree
}#end if


if (! "klowin" %in% ls()){
   klowin      <<-   18000.
}else{
   klowin    <<-   klowin
}#end if
if (! "base.c3" %in% ls()){
   base.c3       <<-   2.4
}else{
   base.c3       <<-   base.c3
}#end if
if (! "base.c4" %in% ls()){
   base.c4       <<-   2.0
}else{
   base.c4       <<-   base.c4
}#end if
if (! "b.c3" %in% ls()){
   b.c3       <<-   10000.
}else{
   b.c3       <<-   b.c3
}#end if
if (! "b.aa" %in% ls()){
   b.aa       <<-   1000.
}else{
   b.aa       <<-   b.aa
}#end if
if (! "b.c4" %in% ls()){
   b.c4       <<-    8000.
}else{
   b.c4       <<-   b.c4
}#end if
if (! "orient.tree" %in% ls()){
   orient.tree     <<-   0.00
}else{
   orient.tree     <<-   orient.tree
}#end if
if (! "orient.aa" %in% ls()){
   orient.aa       <<-   0.00
}else{
   orient.aa       <<-   orient.aa
}#end if
if (! "orient.grass" %in% ls()){
   orient.grass    <<-  0.00
}else{
   orient.grass    <<-   orient.grass
}#end if
if (! "clumping.tree" %in% ls()){
   clumping.tree     <<-   0.735
}else{
   clumping.tree     <<-   clumping.tree
}#end if
if (! "clumping.aa" %in% ls()){
   clumping.aa       <<-   0.735
}else{
   clumping.aa       <<-   clumping.aa
}#end if
if (! "clumping.grass" %in% ls()){
   clumping.grass    <<-  1.0
}else{
   clumping.grass    <<-   clumping.grass
}#end if
if (! "lwidth.grass" %in% ls()){
   lwidth.grass      <<-   0.05
}else{
   lwidth.grass      <<-   lwidth.grass
}#end if
if (! "lwidth.bltree" %in% ls()){
   lwidth.bltree     <<-   0.10
}else{
   lwidth.bltree     <<-   lwidth.bltree
}#end if
if (! "lwidth.nltree" %in% ls()){
   lwidth.nltree     <<-   0.05
}else{
   lwidth.nltree     <<-   lwidth.nltree
}#end if
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#    The following parameter is the k coefficient in Foley et al. (1996) that is used to   #
# determine the CO2-limited photosynthesis for C4 grasses.                                 #
#------------------------------------------------------------------------------------------#
klowco2      <<- klowin * mmco2 /mmdry  # Coefficient for low CO2      [ mol/mol]
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#    These parameters will be assigned to the PFT structure.  Notice that depending on the #
# physiology method (Foley or Collatz), some of them will be used, and some of them will   #
# not.                                                                                     #
#------------------------------------------------------------------------------------------#
vm.hor          <<- 3000.      # Ref. exp. coeff. for carboxylase fctn.          [       K]
vm.base.c3      <<- base.c3    # Base Vm for C3 - Collatz et al. (1991)          [mol/m2/s]
vm.base.c4      <<- base.c4    # Base Vm for C4 - Collatz et al. (1992)          [mol/m2/s]
vm.decay.a      <<- 220000.    # Decay function for warm temperatures -- A       [   J/mol]
vm.decay.b      <<- 695.       # Decay function for warm temperatures -- B       [ J/mol/K]

vm.tcold.c3temp <<- 4.7137
vm.tcold.c3trop <<- 8.0
vm.tcold.aa     <<- 4.7137
vm.tcold.c4     <<- 8.0

vm.thot.c3      <<- 45.0
vm.thot.aa      <<- 45.0
vm.thot.c4      <<- 45.0

vm.decay.e.c3   <<- 0.4
vm.decay.e.aa   <<- 0.4
vm.decay.e.c4   <<- 0.4

lr.hor          <<- 3000.      # Ref. exp. coeff. for carboxylase fctn.          [       K]
lr.base.c3      <<- base.c3
lr.base.c4      <<- base.c4

lr.tcold.c3temp <<- vm.tcold.c3temp
lr.tcold.c3trop <<- vm.tcold.c3trop
lr.tcold.aa     <<- vm.tcold.aa
lr.tcold.c4     <<- vm.tcold.c4

lr.thot.c3      <<- vm.thot.c3
lr.thot.aa      <<- vm.thot.aa
lr.thot.c4      <<- vm.thot.c3

lr.decay.e.c3   <<- 0.4
lr.decay.e.aa   <<- 0.4
lr.decay.e.c4   <<- 0.4

#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#    Define some common values to make it easier to change the list below...               #
#------------------------------------------------------------------------------------------#
C2B    <<- 2.0
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#    These variables define the allometry to use                                           #
# 0 - ED-2.1                                                                               #
# 1 - a.  AGB is based on Baker et al. (2004), Chave formula, keeping the same Bleaf as    #
#         ED-2.1 and Bdead to make up the difference.                                      #
#     b.  Use the crown area as in Poorter et al. (2006) for tropical PFTs                 #
#     c.  Use a simple rooting depth ranging from 0.5 to 5.0                               #
# 2 - Same as 1, but using the height as in Poorter et al. (2006) for tropical PFTs, and   #
#     finding a fit similar to Baker et al. (2004) that doesn't depend on height, using    #
#     Saldarriaga et al. (1988) as a starting point.                                       #
#------------------------------------------------------------------------------------------#
if ("iallom" %in% ls()){
   iallom <<- iallom
}else{
   iallom <<- 2
}#end if
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#     These constants will help defining the allometric parameters for IALLOM 1 and 2.     #
#------------------------------------------------------------------------------------------#
odead.small = c( -1.11382700, 2.44048300,  2.18063200)
odead.large = c(  0.13625460, 2.42173900,  6.94835320)
ndead.small = c( -1.26395300, 2.43236100,  1.80180100)
ndead.large = c( -0.83468050, 2.42557360,  2.68228050)
nleaf       = c(  0.01925119, 0.97494935,  2.58585087)
ncrown.area = c(  0.11842950, 1.05211970)
#------------------------------------------------------------------------------------------#



#----- Define reference height and coefficients for tropical allometry. -------------------#
if (iallom == 0 | iallom == 1){
   hgt.ref.trop = NA
   b1Ht.trop    = 0.37 * log(10)
   b2Ht.trop    = 0.64
}else if (iallom == 2){
   hgt.ref.trop = 61.7
   b1Ht.trop    = 0.0352
   b2Ht.trop    = 0.694 
}#end if
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#     The following variables will define the PFT characteristics regarding the            #
# photosynthesis.                                                                          #
#------------------------------------------------------------------------------------------#
pft01 = list( name               = "C4 grass"
            , key                = "C4G"
            , colour             = "gold"
            , tropical           = TRUE
            , pathway            = 4
            , d0                 = d0.grass
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c4
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c4   + t00
            , vm.high.temp       = vm.thot.c4    + t00
            , vm.decay.e         = vm.decay.e.c4
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c4
            , lr.low.temp        = lr.tcold.c4   + t00
            , lr.high.temp       = lr.thot.c4    + t00
            , lr.decay.e         = lr.decay.e.c4
            , vm0                = 12.5 * vmfact.c4 * umol.2.mol
            , m                  = mphoto.c4
            , alpha              = alpha.c4
            , b                  = b.c4 * umol.2.mol
            , gamma.resp         = gamma.c4
            , effarea.transp     = 1.0
            , rho                = 0.20
            , leaf.turnover.rate = 2.0
            , root.turnover.rate = 2.0
            , SLA                = 22.7
            , hgt.ref            = hgt.ref.trop
            , b1Ht               = b1Ht.trop
            , b2Ht               = b2Ht.trop
            , b1Bl               = NA
            , b2Bl               = NA
            , b1Bs.small         = NA
            , b2Bs.small         = NA
            , b1Bs.large         = NA
            , b2Bs.large         = NA
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.99
            , b2Cl               = 1.00
            , b1WAI              = 0.00
            , b2WAI              = 1.00
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 0.5
            , hgt.max            = 1.5
            , qroot              = 1.0
            , qsw                = 22.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = orient.grass
            , clumping.factor    = clumping.grass
            , leaf.width         = lwidth.grass
            , init.density       = 0.1
            , veg.hcap.min       = 3.68093E+00
            )

pft02 = list( name               = "Early tropical"
            , key                = "ETR"
            , colour             = "chartreuse"
            , tropical           = TRUE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3trop + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3trop + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 18.75 * vmfact.c3 * umol.2.mol
            , m                  = mphoto.c3
            , alpha              = alpha.c3
            , b                  = b.c3 * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = 0.53
            , leaf.turnover.rate = 1.0
            , root.turnover.rate = 1.0
            , SLA                = NA
            , hgt.ref            = hgt.ref.trop
            , b1Ht               = b1Ht.trop
            , b2Ht               = b2Ht.trop
            , b1Bl               = NA
            , b2Bl               = NA
            , b1Bs.small         = NA
            , b2Bs.small         = NA
            , b1Bs.large         = NA
            , b2Bs.large         = NA
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0192 * 0.5
            , b2WAI              = 2.0947
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 0.5
            , hgt.max            = 35.0
            , qroot              = 1.0
            , qsw                = 16.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = orient.tree
            , clumping.factor    = clumping.tree
            , leaf.width         = lwidth.bltree
            , init.density       = 0.1
            , veg.hcap.min       = 9.75446E+00
            )

pft03 = list( name               = "Mid tropical"
            , key                = "MTR"
            , colour             = "chartreuse4"
            , tropical           = TRUE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3trop + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3trop + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 12.5 * vmfact.c3 * umol.2.mol
            , m                  = mphoto.c3
            , alpha              = alpha.c3
            , b                  = b.c3 * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = 0.71
            , leaf.turnover.rate = 0.50
            , root.turnover.rate = 0.50
            , SLA                = NA
            , hgt.ref            = hgt.ref.trop
            , b1Ht               = b1Ht.trop
            , b2Ht               = b2Ht.trop
            , b1Bl               = NA
            , b2Bl               = NA
            , b1Bs.small         = NA
            , b2Bs.small         = NA
            , b1Bs.large         = NA
            , b2Bs.large         = NA
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0192 * 0.5
            , b2WAI              = 2.0947
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 0.5
            , hgt.max            = 35.0
            , qroot              = 1.0
            , qsw                = 11.6 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = orient.tree
            , clumping.factor    = clumping.tree
            , leaf.width         = lwidth.bltree
            , init.density       = 0.1
            , veg.hcap.min       = 1.30673E+01
            )

pft04 = list( name               = "Late tropical"
            , key                = "LTR"
            , colour             = "#004E00"
            , tropical           = TRUE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3trop + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3trop + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 6.25 * vmfact.c3 * umol.2.mol
            , m                  = mphoto.c3
            , alpha              = alpha.c3
            , b                  = b.c3 * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = 0.90
            , leaf.turnover.rate = 1./3.
            , root.turnover.rate = 1./3.
            , SLA                = NA
            , hgt.ref            = hgt.ref.trop
            , b1Ht               = b1Ht.trop
            , b2Ht               = b2Ht.trop
            , b1Bl               = NA
            , b2Bl               = NA
            , b1Bs.small         = NA
            , b2Bs.small         = NA
            , b1Bs.large         = NA
            , b2Bs.large         = NA
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0192 * 0.5
            , b2WAI              = 2.0947
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 0.5
            , hgt.max            = 35.0
            , qroot              = 1.0
            , qsw                = 9.67 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = orient.tree
            , clumping.factor    = clumping.tree
            , leaf.width         = lwidth.bltree
            , init.density       = 0.1
            , veg.hcap.min       = 1.65642E+01
            )

pft05 = list( name               = "Temperate C3 Grass"
            , key                = "TTG"
            , colour             = "mediumpurple1"
            , tropical           = FALSE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3temp + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3temp + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 18.3   * umol.2.mol
            , m                  = mphoto.c3
            , alpha              = alpha.c3
            , b                  = b.c3 * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = 0.32
            , leaf.turnover.rate = 2.0
            , root.turnover.rate = 2.0
            , SLA                = 22.0
            , hgt.ref            = 0.0
            , b1Ht               = 0.4778
            , b2Ht               = -0.750
            , b1Bl               = 0.08
            , b2Bl               = 1.00
            , b1Bs.small         = 1.e-5
            , b2Bs.small         = 1.0
            , b1Bs.large         = 1.e-5
            , b2Bs.large         = 1.0
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.99
            , b2Cl               = 1.0
            , b1WAI              = 0.0
            , b2WAI              = 1.0
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 0.15
            , hgt.max            = 0.95 * 0.4778
            , qroot              = 1.0
            , qsw                = 22.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = -0.30
            , clumping.factor    =  1.00
            , leaf.width         = lwidth.grass
            , init.density       = 0.1
            , veg.hcap.min       = 9.16551E+00
            )

pft06 = list( name               = "North Pine"
            , key                = "NPN"
            , colour             = "deepskyblue"
            , tropical           = FALSE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3temp + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3temp + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 15.625 * 0.7264 * umol.2.mol
            , m                  = mphoto.c3 * 6.3949 / 8.0
            , alpha              = alpha.c3
            , b                  = 1000. * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 2.0
            , rho                = NA
            , leaf.turnover.rate = 1./3.
            , root.turnover.rate = 3.927218
            , SLA                = 6.0
            , hgt.ref            = 1.3
            , b1Ht               = 27.14
            , b2Ht               = -0.03884
            , b1Bl               = 0.024
            , b2Bl               = 1.899
            , b1Bs.small         = 0.147
            , b2Bs.small         = 2.238
            , b1Bs.large         = 0.147
            , b2Bs.large         = 2.238
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0553 * 0.5
            , b2WAI              = 1.9769
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 1.5
            , hgt.max            = 0.999 * 27.14
            , qroot              = 0.3463
            , qsw                = 6.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = 0.01
            , clumping.factor    = 0.735
            , leaf.width         = lwidth.nltree
            , init.density       = 0.1
            , veg.hcap.min       = 2.34683E-01
            )

pft07 = list( name               = "South Pine"
            , key                = "SPN"
            , colour             = "mediumturquoise"
            , tropical           = FALSE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3temp + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3temp + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 15.625 * 0.7264 * umol.2.mol
            , m                  = mphoto.c3 * 6.3949 / 8.0
            , alpha              = alpha.c3
            , b                  = 1000. * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 2.0
            , rho                = NA
            , leaf.turnover.rate = 1./3.
            , root.turnover.rate = 4.117847
            , SLA                = 9.0
            , hgt.ref            = 1.3
            , b1Ht               = 27.14
            , b2Ht               = -0.03884
            , b1Bl               = 0.024
            , b2Bl               = 1.899
            , b1Bs.small         = 0.147
            , b2Bs.small         = 2.238
            , b1Bs.large         = 0.147
            , b2Bs.large         = 2.238
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0553 * 0.5
            , b2WAI              = 1.9769
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 1.5
            , hgt.max            = 0.999 * 27.14
            , qroot              = 0.3463
            , qsw                = 9.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = 0.01
            , clumping.factor    = 0.735
            , leaf.width         = lwidth.nltree
            , init.density       = 0.1
            , veg.hcap.min       = 2.34683E-01
            )

pft08 = list( name               = "Late conifer"
            , key                = "LCN"
            , colour             = "royalblue4"
            , tropical           = FALSE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3temp + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3temp + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 6.25 * 0.7264 * umol.2.mol
            , m                  = mphoto.c3 * 6.3949 / 8.0
            , alpha              = alpha.c3
            , b                  = 1000. * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 2.0
            , rho                = NA
            , leaf.turnover.rate = 1./3.
            , root.turnover.rate = 3.800132
            , SLA                = 10.0
            , hgt.ref            = 1.3
            , b1Ht               = 22.79
            , b2Ht               = -0.04445
            , b1Bl               = 0.0454
            , b2Bl               = 1.6829
            , b1Bs.small         = 0.1617
            , b2Bs.small         = 2.1536
            , b1Bs.large         = 0.1617
            , b2Bs.large         = 2.1536
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0553 * 0.5
            , b2WAI              = 1.9769
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 1.5
            , hgt.max            = 0.999 * 22.79
            , qroot              = 0.3463
            , qsw                = 10.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = 0.01
            , clumping.factor    = 0.735
            , leaf.width         = lwidth.nltree
            , init.density       = 0.1
            , veg.hcap.min       = 6.80074E-01
            )

pft09 = list( name               = "Early hardwood"
            , key                = "EHW"
            , colour             = "darkorange"
            , tropical           = FALSE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3temp + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3temp + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 18.25  * 1.1171 * umol.2.mol
            , m                  = mphoto.c3 * 6.3949 / 8.0
            , alpha              = alpha.c3
            , b                  = 20000. * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = NA
            , leaf.turnover.rate = NA
            , root.turnover.rate = 5.772506
            , SLA                = 30.0
            , hgt.ref            = 1.3
            , b1Ht               = 22.6799
            , b2Ht               = -0.06534
            , b1Bl               = 0.0129
            , b2Bl               = 1.7477
            , b1Bs.small         = 0.02648
            , b2Bs.small         = 2.95954
            , b1Bs.large         = 0.02648
            , b2Bs.large         = 2.95954
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0192 * 0.5
            , b2WAI              = 2.0947
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 1.5
            , hgt.max            = 0.999 * 22.6799
            , qroot              = 1.1274
            , qsw                = 30.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = 0.25
            , clumping.factor    = 0.84
            , leaf.width         = lwidth.bltree
            , init.density       = 0.1
            , veg.hcap.min       = 8.95049E-02
            )

pft10 = list( name               = "Mid hardwood"
            , key                = "MHW"
            , colour             = "orangered"
            , tropical           = FALSE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3temp + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3temp + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 15.625  * 1.1171 * umol.2.mol
            , m                  = mphoto.c3 * 6.3949 / 8.0
            , alpha              = alpha.c3
            , b                  = 20000. * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = NA
            , leaf.turnover.rate = NA
            , root.turnover.rate = 5.083700
            , SLA                = 24.2
            , hgt.ref            = 1.3
            , b1Ht               = 25.18
            , b2Ht               = -0.04964
            , b1Bl               = 0.048
            , b2Bl               = 1.455
            , b1Bs.small         = 0.1617
            , b2Bs.small         = 2.4572
            , b1Bs.large         = 0.1617
            , b2Bs.large         = 2.4572
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0192 * 0.5
            , b2WAI              = 2.0947
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 1.5
            , hgt.max            = 0.999 * 25.18
            , qroot              = 1.1274
            , qsw                = 24.2 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = 0.25
            , clumping.factor    = 0.84
            , leaf.width         = lwidth.bltree
            , init.density       = 0.1
            , veg.hcap.min       = 7.65271E-01
            )

pft11 = list( name               = "Late hardwood"
            , key                = "LHW"
            , colour             = "firebrick"
            , tropical           = FALSE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3temp + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3temp + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 6.25  * 1.1171 * umol.2.mol
            , m                  = mphoto.c3 * 6.3949 / 8.0
            , alpha              = alpha.c3
            , b                  = 20000. * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = NA
            , leaf.turnover.rate = NA
            , root.turnover.rate = 5.070992
            , SLA                = 60.0
            , hgt.ref            = 1.3
            , b1Ht               = 23.3874
            , b2Ht               = -0.05404
            , b1Bl               = 0.017
            , b2Bl               = 1.731
            , b1Bs.small         = 0.235
            , b2Bs.small         = 2.2518
            , b1Bs.large         = 0.235
            , b2Bs.large         = 2.2518
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0192 * 0.5
            , b2WAI              = 2.0947
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 1.5
            , hgt.max            = 0.999 * 23.3874
            , qroot              = 1.1274
            , qsw                = 60.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = 0.25
            , clumping.factor    = 0.84
            , leaf.width         = lwidth.bltree
            , init.density       = 0.1
            , veg.hcap.min       = 1.60601E-01
            )

pft12 = pft05; pft12$name = "C3 crop"   ; pft12$key = "CC3"; pft12$colour="purple4"
pft13 = pft05; pft13$name = "C3 pasture"; pft13$key = "PC3"; pft13$colour="darkorchid1"
pft14 = pft01; pft14$name = "C4 crop"   ; pft14$key = "CC4"; pft14$colour="darkgoldenrod"
pft15 = pft01; pft15$name = "C4 pasture"; pft15$key = "PC4"; pft15$colour="khaki"

pft16 = list( name               = "C3 grass"
            , key                = "C3G"
            , colour             = "lightgoldenrod3"
            , tropical           = TRUE
            , pathway            = 3
            , d0                 = d0.grass
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.c3trop + t00
            , vm.high.temp       = vm.thot.c3      + t00
            , vm.decay.e         = vm.decay.e.c3
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.c3trop + t00
            , lr.high.temp       = lr.thot.c3      + t00
            , lr.decay.e         = lr.decay.e.c3
            , vm0                = 20.833333333 * vmfact.c3 * umol.2.mol
            , m                  = mphoto.c3
            , alpha              = alpha.c3
            , b                  = b.c3 * umol.2.mol
            , gamma.resp         = gamma.c3
            , effarea.transp     = 1.0
            , rho                = 0.20
            , leaf.turnover.rate = 2.0
            , root.turnover.rate = 2.0
            , SLA                = 22.7
            , hgt.ref            = hgt.ref.trop
            , b1Ht               = b1Ht.trop
            , b2Ht               = b2Ht.trop
            , b1Bl               = NA
            , b2Bl               = NA
            , b1Bs.small         = NA
            , b2Bs.small         = NA
            , b1Bs.large         = NA
            , b2Bs.large         = NA
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.99
            , b2Cl               = 1.00
            , b1WAI              = 0.0
            , b2WAI              = 1.0
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 0.5
            , hgt.max            = 1.5
            , qroot              = 1.0
            , qsw                = 22.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = orient.grass
            , clumping.factor    = clumping.grass
            , leaf.width         = lwidth.grass
            , init.density       = 0.1
            , veg.hcap.min       = 3.68093E+00
            )

pft17 = list( name               = "Araucaria"
            , key                = "ARC"
            , colour             = "steelblue3"
            , tropical           = TRUE
            , pathway            = 3
            , d0                 = d0.tree
            , vm.hor             = vm.hor
            , vm.base            = vm.base.c3
            , vm.decay.a         = vm.decay.a
            , vm.decay.b         = vm.decay.b
            , vm.low.temp        = vm.tcold.aa + t00
            , vm.high.temp       = vm.thot.aa  + t00
            , vm.decay.e         = vm.decay.e.aa
            , lr.hor             = lr.hor
            , lr.base            = lr.base.c3
            , lr.low.temp        = lr.tcold.aa + t00
            , lr.high.temp       = lr.thot.aa  + t00
            , lr.decay.e         = lr.decay.e.aa
            , vm0                = 15.625  * vmfact.c3 * umol.2.mol
            , m                  = mphoto.aa
            , alpha              = alpha.c3
            , b                  = b.aa * umol.2.mol
            , gamma.resp         = gamma.aa
            , effarea.transp     = 2.0
            , rho                = 0.59
            , leaf.turnover.rate = 1./6.
            , root.turnover.rate = 1./6.
            , SLA                = 10.0
            , hgt.ref            = hgt.ref.trop
            , b1Ht               = b1Ht.trop
            , b2Ht               = b2Ht.trop
            , b1Bl               = NA
            , b2Bl               = NA
            , b1Bs.small         = NA
            , b2Bs.small         = NA
            , b1Bs.large         = NA
            , b2Bs.large         = NA
            , b1Ca               = 2.490154
            , b2Ca               = 0.8068806
            , b1Cl               = 0.3106775
            , b2Cl               = 1.098
            , b1WAI              = 0.0553 * 0.5
            , b2WAI              = 1.9769
            , b1Vol              = 0.65 * pi * 0.11 * 0.11
            , b2Vol              = 0.65 * pi * 0.11 * 0.11
            , hgt.min            = 0.5
            , hgt.max            = 35.0
            , qroot              = 1.0
            , qsw                = 10.0 / 3900.
            , agf.bs             = 0.7
            , orient.factor      = orient.aa
            , clumping.factor    = clumping.aa
            , leaf.width         = lwidth.nltree
            , init.density       = 0.1
            , veg.hcap.min       = 9.93851E+00
            )
pft18 = pft07; pft18$name = "Total"   ; pft18$key = "ALL"; pft18$colour=all.colour
#------------------------------------------------------------------------------------------#



#----- Build the structure of photosynthesis parameters by PFT. ---------------------------#
pft = list()
for (p in 1:(npft+1)){
  ppp  = substring(100+p,2,3)
  phph = paste("pft",ppp,sep="")
  if (p == 1){
     pft = get(phph)
  }else{
     phmerge = get(phph)
     for (n in union(names(pft),names(phmerge))){
        pft[[n]] = c(pft[[n]],phmerge[[n]])
     } #end for
  }# end if
} #end for


#----- Minimum and Maximum DBH. -----------------------------------------------------------#
pft$dbh.min  = rep(NA,times=npft+1)
pft$dbh.crit = rep(NA,times=npft+1)
for (ipft in 1:npft){
   if (pft$tropical[ipft]){
      if (iallom == 0 | iallom == 1){
         pft$dbh.min [ipft] = exp((log(pft$hgt.min[ipft])-pft$b1Ht[ipft])/pft$b2Ht[ipft])
         pft$dbh.crit[ipft] = exp((log(pft$hgt.max[ipft])-pft$b1Ht[ipft])/pft$b2Ht[ipft])
      }else if (iallom == 2){
         pft$dbh.min [ipft] = ( log(   pft$hgt.ref[ipft]
                                   / ( pft$hgt.ref[ipft] - pft$hgt.min[ipft]) )
                              / pft$b1Ht[ipft] ) ^ (1.0 / pft$b2Ht[ipft])
         pft$dbh.crit[ipft] = ( log(   pft$hgt.ref[ipft]
                                   / ( pft$hgt.ref[ipft] - pft$hgt.max[ipft]) )
                              / pft$b1Ht[ipft] ) ^ (1.0 / pft$b2Ht[ipft])
     }#end if
   }else{
      pft$dbh.min [ipft] = ( log(1.0 - (pft$hgt.min[ipft]-pft$hgt.ref[ipft])
                                       / pft$b1Ht[ipft] ) / pft$b2Ht[ipft] )
      pft$dbh.crit[ipft] = ( log(1.0 - (pft$hgt.max[ipft]-pft$hgt.ref[ipft])
                                       / pft$b1Ht[ipft]) / pft$b2Ht[ipft] )
   }#end if
}#end for


#------------------------------------------------------------------------------------------#
#    Specific leaf area for those PFTs whose specific leaf area depends on the leaf turn-  #
# over rate.                                                                               #
#------------------------------------------------------------------------------------------#
pft$SLA = rep(NA,times=npft+1)
for (ipft in 1:npft){
   if (is.na(pft$SLA[ipft])){
      pft$SLA[ipft] = ( 10^( (2.4 - 0.46 * log10(12./pft$leaf.turnover.rate[ipft]))) 
                      * C2B * 0.1 )
   }#end if
}#end for
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#    Minimum bleaf and leaf area index that is resolvable.                                 #
#------------------------------------------------------------------------------------------#
pft$bleaf.min = c(dbh2bl(dbh=pft$dbh.min[1:npft],ipft=1:npft),NA)
pft$lai.min   = onesixth * pft$init.dens * pft$bleaf.min * pft$SLA
#------------------------------------------------------------------------------------------#

#----- Constants shared by both bdead and bleaf -------------------------------------------#
a1    =  -1.981
b1    =   1.047
dcrit = 100.0
#----- Constants used by bdead only -------------------------------------------------------#
c1d   =   0.572
d1d   =   0.931
a2d   =  -1.086
b2d   =   0.876
c2d   =   0.604
d2d   =   0.871
#----- Constants used by bleaf only -------------------------------------------------------#
c1l   =  -0.584
d1l   =   0.550
a2l   =  -4.111
b2l   =   0.605
c2l   =   0.848
d2l   =   0.438
#------------------------------------------------------------------------------------------#
pft$b1Bl       = rep(NA,times=npft+1)
pft$b2Bl       = rep(NA,times=npft+1)
pft$b1Bs.small = rep(NA,times=npft+1)
pft$b2Bs.small = rep(NA,times=npft+1)
pft$b1Bs.large = rep(NA,times=npft+1)
pft$b2Bs.large = rep(NA,times=npft+1)
pft$b1Ca       = rep(NA,times=npft+1)
pft$b2Ca       = rep(NA,times=npft+1)
for (ipft in 1:npft){
   if (pft$tropical[ipft]){
      #------------------------------------------------------------------------------------#
      #      Fill in the leaf biomass parameters.                                          #
      #------------------------------------------------------------------------------------#
      if (iallom == 0 || iallom == 1){
         #---- ED-2.1 allometry. ----------------------------------------------------------#
         pft$b1Bl      [ipft] = exp(a1 + c1l * pft$b1Ht[ipft] + d1l * log(pft$rho[ipft]))
         aux                  = ( (a2l - a1) + pft$b1Ht[ipft] * (c2l - c1l) 
                                + log(pft$rho[ipft]) * (d2l - d1l)) * (1.0/log(dcrit))
         pft$b2Bl      [ipft] = C2B * b2l + c2l * pft$b2Ht[ipft] + aux
      }else if(iallom == 2){
         pft$b1Bl      [ipft] = C2B * exp(nleaf[1]) * pft$rho[ipft] / nleaf[3]
         pft$b2Bl      [ipft] = nleaf[2]
      }#end if
      #------------------------------------------------------------------------------------#


      #------------------------------------------------------------------------------------#
      #      Fill in the structural biomass parameters.                                    #
      #------------------------------------------------------------------------------------#
      if (iallom == 0){
         #---- ED-2.1 allometry. ----------------------------------------------------------#
         pft$b1Bs.small[ipft] = exp(a1 + c1d * pft$b1Ht[ipft] + d1d * log(pft$rho[ipft]))
         pft$b1Bs.large[ipft] = exp(a1 + c1d * log(pft$hgt.max[ipft]) 
                                       + d1d * log(pft$rho[ipft]))
         aux                  = ( (a2d - a1) + pft$b1Ht[ipft] * (c2d - c1d)
                                + log(pft$rho[ipft]) * (d2d - d1d) ) * (1.0/log(dcrit))
         pft$b2Bs.small[ipft] = C2B * b2d + c2d * pft$b2Ht[ipft] + aux

         aux                  = ( (a2d - a1) + log(pft$hgt.max[ipft]) * (c2d - c1d)
                                + log(pft$rho[ipft]) * (d2d - d1d)) * (1.0/log(dcrit))
         pft$b2Bs.large[ipft] = C2B * b2d + aux

      }else if (iallom == 1){
         #---- Based on modified Chave et al. (2001) allometry. ---------------------------#
         pft$b1Bs.small[ipft] = C2B * exp(odead.small[1]) * pft$rho[ipft] / odead.small[3]
         pft$b2Bs.small[ipft] = odead.small[2]
         pft$b1Bs.large[ipft] = C2B * exp(odead.large[1]) * pft$rho[ipft] / odead.large[3]
         pft$b2Bs.large[ipft] = odead.large[2]
      }else if (iallom == 2){
         #---- Based an alternative modification of Chave et al. (2001) allometry. --------#
         pft$b1Bs.small[ipft] = C2B * exp(ndead.small[1]) * pft$rho[ipft] / ndead.small[3]
         pft$b2Bs.small[ipft] = ndead.small[2]
         pft$b1Bs.large[ipft] = C2B * exp(ndead.large[1]) * pft$rho[ipft] / ndead.large[3]
         pft$b2Bs.large[ipft] = ndead.large[2]
      }#end if
      #------------------------------------------------------------------------------------#



      #------------------------------------------------------------------------------------#
      #      Replace the coefficients if we are going to use Poorter et al. (2006)         #
      # parameters for crown area.                                                         #
      #------------------------------------------------------------------------------------#
      if (iallom == 1){
         pft$b1Ca[ipft] = exp(-1.853) * exp(pft$b1Ht[ipft]) ^ 1.888
         pft$b2Ca[ipft] = pft$b2Ht[ipft] * 1.888
      }else if (iallom == 2){
         pft$b1Ca[ipft] = exp(ncrown.area[1])
         pft$b2Ca[ipft] = ncrown.area[2]
      }#end if
   }#end if
}#end do



#------------------------------------------------------------------------------------------#
#    Rooting depth coefficients.                                                                               #
#------------------------------------------------------------------------------------------#
pft$b1Rd = rep(NA,times=npft+1)
if (iallom == 0){
   #----- Original ED-2.1 scheme, based on standing volume. -------------------------------#
   pft$b1Rd[ 1:17] = NA
   pft$b1Rd[    1] = -0.700
   pft$b1Rd[  2:4] = -exp(0.545 * log(10.))
   pft$b1Rd[    5] = -0.700
   pft$b1Rd[ 6:11] = -exp(0.545 * log(10.))
   pft$b1Rd[12:16] = -0.700
   pft$b1Rd[   17] = -exp(0.545 * log(10.))
   pft$b2Rd[ 1:17] = NA
   pft$b2Rd[    1] = 0.000
   pft$b2Rd[  2:4] = 0.277
   pft$b2Rd[    5] = 0.000
   pft$b2Rd[ 6:11] = 0.277
   pft$b2Rd[12:16] = 0.000
   pft$b2Rd[   17] = 0.277

}else if (iallom == 1 || iallom == 2){
   #----- Simple allometry (0.5 m for seedlings, 5.0m for 35-m trees. ---------------------#
   pft$b1Rd[1:17]  = -1.1140580
   pft$b2Rd[1:17]  =  0.4223014

}#end if
#------------------------------------------------------------------------------------------#

#----- Make it global. --------------------------------------------------------------------#
pft <<- pft
#------------------------------------------------------------------------------------------#
