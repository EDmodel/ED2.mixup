#==========================================================================================#
#==========================================================================================#
#      This subroutine computes the split between direct and diffuse radiation, and        #
# between visible and near-infrared radiation using the method suggested by:               #
#                                                                                          #
# Weiss, A., J. M. Norman, 1985: Partitioning solar radiation into direct and diffuse,     #
#     visible and near-infrared components.  Agric. For. Meteorol., 34, 205-213. (WN85)    #
#                                                                                          #
# Input variables:                                                                         #
#                                                                                          #
#    * rad.in   - The incoming radiation at surface, in W/m2.  This can be either PAR,     #
#                 NIR, or the total shortwave radiation, but it must be in W/m2 in any of  #
#                 the cases.                                                               #
#    * atm.prss - The atmospheric pressure at the surface, in Pa.  An actual measurement   #
#                 is better, but if you don't have one just use some typical value given   #
#                 the place altitude (higher elevation sites get more radiation).          #
#    * cosz     - The cosine of zenith angle.  This can be estimated using function ed.zen #
#                 in file zen.r
#    * rad.type - The type of radiation provided in rad.in.  Default is total shortwave    #
#                 radiation, but the function also accepts PAR or NIR.  The value is case  #
#                 insensitive and only the first letter is checked.  "p" means PAR, "n"    #
#                 means NIR, and any other letter will be assumed shortwave.               #
#------------------------------------------------------------------------------------------#
predict.rshort.bdown = function(x,rad.in,atm.prss,cosz,rad.type="rshort"){
   #---------------------------------------------------------------------------------------#
   #    Local constants.                                                                   #
   #---------------------------------------------------------------------------------------#
   #----- Extinction coefficient. (equations 1 and 4 of WN85) -----------------------------#
   par.beam.expext  = -exp(x[ 1])
   nir.beam.expext  = -exp(x[ 2])
   #----- This is the typical conversion of diffuse radiation in sunny days. --------------#
   par2diff.sun = inv.logit(x[ 3])
   nir2diff.sun = inv.logit(x[ 4])
   #----- Coefficients for various equations in WN85. -------------------------------------#
   wn85.06 = c( x[ 5], x[ 6], x[ 7] )
   req     = c( x[ 8], x[ 9]        )
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Make rad type case insensitive, and retain only the first letter.                 #
   #---------------------------------------------------------------------------------------#
   rty = substring(tolower(rad.type),1,1)
   #---------------------------------------------------------------------------------------#


   #------ Initialise the radiation with NAs. ---------------------------------------------#
   par.beam    = NA * rad.in
   nir.beam    = NA * rad.in
   par.diff    = NA * rad.in
   nir.diff    = NA * rad.in
   par.full    = NA * rad.in
   nir.full    = NA * rad.in
   rshort.beam = NA * rad.in
   rshort.diff = NA * rad.in
   rshort.full = NA * rad.in
   par.max     = NA * rad.in
   nir.max     = NA * rad.in
   rshort.max  = NA * rad.in


   #------ Make day and night flags. ------------------------------------------------------#
   ntimes = length(cosz)
   night  = cosz <= cosz.min
   day    = ! night 
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     First thing to check is whether this is daytime or "night-time".  If the zenith   #
   # angle is too close to horizon, we assume it's dawn/dusk and all radiation goes to     #
   # diffuse.                                                                              #
   #---------------------------------------------------------------------------------------#
   par.beam    [night] = 0.0
   nir.beam    [night] = 0.0
   if (rty == "p"){
      par.diff    [night] = rad.in[night]
      nir.diff    [night] = fnir.diff.def * rad.in[night] / fvis.diff.def
   }else if(rty == "n"){
      par.diff    [night] = fvis.diff.def * rad.in[night] / fnir.diff.def
      nir.diff    [night] = rad.in[night]
   }else{
      par.diff    [night] = fvis.diff.def * rad.in[night]
      nir.diff    [night] = fnir.diff.def * rad.in[night]
   }#end if
   par.full    [night] = par.beam   [night] + par.diff   [night]
   nir.full    [night] = nir.beam   [night] + nir.diff   [night]
   rshort.beam [night] = par.beam   [night] + nir.beam   [night]
   rshort.diff [night] = par.diff   [night] + nir.diff   [night]
   rshort.full [night] = rshort.beam[night] + rshort.diff[night]
   par.max     [night] = 0.0
   nir.max     [night] = 0.0
   rshort.max  [night] = 0.0
   #---------------------------------------------------------------------------------------#



   #----- Save 1/cos(zen), which is the secant.  We will use this several times. ----------#
   secz      = 1. / cosz[day]
   log10secz = log10(secz)
   #---------------------------------------------------------------------------------------#


   #----- Total radiation at the top [  W/m2], using ED defaults. -------------------------#
   par.beam.top = fvis.beam.def * solar
   nir.beam.top = fnir.beam.def * solar
   #---------------------------------------------------------------------------------------#

   #---------------------------------------------------------------------------------------#
   #    Find the potential PAR components (beam, diffuse, total), using equations 1, 3,    #
   # and 9 of WN85.                                                                        #
   #---------------------------------------------------------------------------------------#
   par.beam.pot = ( par.beam.top
                  * exp ( par.beam.expext * (atm.prss[day] / prefsea) * secz) * cosz[day])
   par.diff.pot = par2diff.sun * (par.beam.top - par.beam.pot) * cosz[day]
   par.full.pot = par.beam.pot + par.diff.pot
   #------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Find the NIR absorption of 10 mm of precipitable water, using WN85 equation 6.    #
   #---------------------------------------------------------------------------------------#
   w10 = solar * 10 ** ((wn85.06[1]) + log10secz * (wn85.06[2] + wn85.06[3] * log10secz))
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Find the potential direct and diffuse near-infrared radiation, using equations    #
   # 4, 5, and 10 of WN85.                                                                 #
   #---------------------------------------------------------------------------------------#
   nir.beam.pot = ( ( nir.beam.top
                    * exp ( nir.beam.expext * (atm.prss[day] / prefsea) * secz) - w10 )
                  * cosz[day] )
   nir.diff.pot = nir2diff.sun * ( nir.beam.top - nir.beam.pot - w10 ) * cosz[day]
   nir.full.pot = nir.beam.pot + nir.diff.pot
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Total maximum radiation.                                                          #
   #---------------------------------------------------------------------------------------#
   par.max   [day] = par.full.pot
   nir.max   [day] = nir.full.pot
   rshort.max[day] = par.full.pot + nir.full.pot
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Find the actual total for PAR and NIR, using equations 7 and 8.                   #
   #---------------------------------------------------------------------------------------#
   if (rty == "p"){
      ratio      = rad.in[day] / par.full.pot
   }else if (rty == "n"){
      ratio      = rad.in[day] / nir.full.pot
   }else{
      ratio      = rad.in[day] / (par.full.pot + nir.full.pot)
   }#end if
   par.full[day] = ratio * par.full.pot
   nir.full[day] = ratio * nir.full.pot
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Find the fraction of PAR and NIR that stays as beam, using equations 11 and 12    #
   # of WN85.                                                                              #
   #---------------------------------------------------------------------------------------#
   #----- Make sure that the ratio is bounded. --------------------------------------------#
   ratio.correct = inv.logit(req[1] * (ratio + req[2]))
   fvis.beam.act = par.beam.pot / par.full.pot * ratio.correct
   fnir.beam.act = nir.beam.pot / nir.full.pot * ratio.correct
   fvis.diff.act = 1. - fvis.beam.act
   fnir.diff.act = 1. - fnir.beam.act
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Find the radiation components.                                                    #
   #---------------------------------------------------------------------------------------#
   par.beam    [day] = fvis.beam.act * par.full[day]
   par.diff    [day] = fvis.diff.act * par.full[day]
   nir.beam    [day] = fnir.beam.act * nir.full[day]
   nir.diff    [day] = fnir.diff.act * nir.full[day]
   rshort.beam [day] = par.beam   [day] + nir.beam   [day]
   rshort.diff [day] = par.diff   [day] + nir.diff   [day]
   rshort.full [day] = rshort.beam[day] + rshort.diff[day]
   #---------------------------------------------------------------------------------------#
   rshort.bdown = list( par.beam    = par.beam
                      , par.diff    = par.diff
                      , par.full    = par.full
                      , nir.beam    = nir.beam
                      , nir.diff    = nir.diff
                      , nir.full    = nir.full
                      , rshort.beam = rshort.beam
                      , rshort.diff = rshort.diff
                      , rshort.full = rshort.full
                      , par.max     = par.max
                      , nir.max     = nir.max
                      , rshort.max  = rshort.max
                      )#end list
   return(rshort.bdown)
}#end function optim.rshort.bdown
#==========================================================================================#
#==========================================================================================#






#==========================================================================================#
#==========================================================================================#
#
#------------------------------------------------------------------------------------------#





#==========================================================================================#
#==========================================================================================#
#       This function finds the sum of the squares, which is the log likelihood if we      #
# asume the errors to be independent and normally distributed (a big assumption).          #
#==========================================================================================#
#==========================================================================================#
rshort.in.wn.support <<- function(x,rshort.in,atm.prss,cosz,par.in,nir.in,par.diff
                                 ,sigma.par.full,sigma.nir.full,sigma.par.diff){

   rsbdown.try = predict.rshort.bdown( x        = x
                                     , rad.in   = rshort.in
                                     , atm.prss = atm.prss
                                     , cosz     = cosz
                                     , rad.type = "rshort"
                                     )#end predict.rshort.bdown

   residual.par.full = rsbdown.try$par.full - par.in
   residual.nir.full = rsbdown.try$nir.full - nir.in
   residual.par.diff = rsbdown.try$par.diff - par.diff

   residual          = c(residual.par.full,residual.nir.full,residual.par.diff)
   sigma             = c(sigma.par.full   ,sigma.nir.full   ,sigma.par.diff   )
   chi.square        = sum((residual/sigma)^2,na.rm=TRUE)

   support      = - chi.square
   return(support)
}#end function rlong.in.mmi.lnlike
#==========================================================================================#
#==========================================================================================#
