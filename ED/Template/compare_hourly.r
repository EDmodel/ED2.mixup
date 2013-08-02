#==========================================================================================#
#==========================================================================================#
#     Reset session.                                                                       #
#------------------------------------------------------------------------------------------#
rm(list=ls())
graphics.off()
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#      Here is the user defined variable section.                                          #
#------------------------------------------------------------------------------------------#
here    = getwd()                               #   Current directory
srcdir  = "/n/home00/mlongo/util/Rsc"           #   Script directory
ibackground    = 0                              # Make figures compatible to background
                                                # 0 -- white
                                                # 1 -- black
                                                # 2 -- dark grey
#----- Output directory -------------------------------------------------------------------#
outroot = file.path(here,paste("hourly_comp_ibg",sprintf("%2.2i",ibackground),sep=""))
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#     Site settings:                                                                       #
# eort      -- first letter ("e" or "t")                                                   #
# sites     -- site codes ("IATA")                                                         #
# sites.pch -- site symbols                                                                #
#------------------------------------------------------------------------------------------#
eort           = "t"
sites          = c("gyf","s67","s83","pdg","rja","m34")  # ,"pnz","ban","cax"
sites.pch      = c(    2,    5,    9,   13,    1,    6)  # ,    4,    8,    0
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#    Simulation settings:                                                                  #
# name -- the suffix of the simulations (list all combinations.                            #
# desc -- description (for legends)                                                        #
# verbose -- long description (for titles)                                                 #
# colour  -- colour to represent this simulation                                           #
#------------------------------------------------------------------------------------------#
sim.struct     = list( name     = c("ble_iage30_pft02","ble_iage30_pft05"
                                   ,"sas_iage01_pft02","sas_iage01_pft05"
                                   ,"sas_iage30_pft02","sas_iage30_pft05"
                                   )#end c
                     , desc     = c("Big leaf, 2 PFTs"    ,"Big leaf, 5 PFTs"
                                   ,"Size only, 2 PFTs"   ,"Size only, 5 PFTs"
                                   ,"Size and age, 2 PFTs","Size and age, 5 PFTs"
                                   )#end c
                     , verbose  = c("Big leaf, 2 PFTs"    ,"Big leaf, 5 PFTs"
                                   ,"Size only, 2 PFTs"   ,"Size only, 5 PFTs"
                                   ,"Size and age, 2 PFTs","Size and age, 5 PFTs"
                                   )#end c
                     , colour   = c("slateblue4" ,"purple1"     
                                   ,"dodgerblue3","deepskyblue" 
                                   ,"chartreuse4","chartreuse"  
                                   )#end c
                     )#end list
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#       Plot options.                                                                      #
#------------------------------------------------------------------------------------------#
outform        = c("pdf")              # Formats for output file.  Supported formats are:
                                       #   - "X11" - for printing on screen
                                       #   - "eps" - for postscript printing
                                       #   - "png" - for PNG printing
                                       #   - "pdf" - for PDF printing

byeold         = TRUE                  # Remove old files of the given format?

depth          = 96                    # PNG resolution, in pixels per inch
paper          = "letter"              # Paper size, to define the plot shape
ptsz           = 18                    # Font size.
lwidth         = 2.5                   # Line width
plotgrid       = TRUE                  # Should I plot the grid in the background? 

legwhere       = "topleft"             # Where should I place the legend?
inset          = 0.01                  # Inset between legend and edge of plot region.
fracexp        = 0.40                  # Expansion factor for y axis (to fit legend)
cex.main       = 0.8                   # Scale coefficient for the title

st.cex.min     = 0.7                   # Minimum and maximum sizes for points in the 
st.cex.max     = 2.0                   #     Skill and Taylor diagrams
st.lwd.min     = 1.3                   # Minimum and maximum sizes for points in the 
st.lwd.max     = 3.0                   #     Skill and Taylor diagrams
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#      NO NEED TO CHANGE ANYTHING BEYOND THIS POINT UNLESS YOU ARE DEVELOPING THE CODE...  #
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------#



#----- Load some packages. ----------------------------------------------------------------#
source(file.path(srcdir,"load.everything.r"))
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     Eddy flux comparisons.                                                               #
#------------------------------------------------------------------------------------------#
compvar       = list()
compvar[[ 1]] = list( vnam       = "ustar"
                    , symbol     = expression(u^symbol("\052"))
                    , desc       = "Friction velocity"
                    , unit       = untab$mos
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(purple.bg,purple.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 2]] = list( vnam       = "cflxca"
                    , symbol     = expression(F(CO[2]))
                    , desc       = "Carbon dioxide flux"
                    , unit       = untab$umolcom2os
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(green.bg,green.fg)
                    , leg.corner = "bottomright"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 3]] = list( vnam       = "cflxst"
                    , symbol     = expression(S(CO[2]))
                    , desc       = "Carbon dioxide storage"
                    , unit       = untab$umolcom2os
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(orange.bg,orange.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 4]] = list( vnam       = "nee"
                    , symbol     = expression(NEE)
                    , desc       = "Net ecosystem exchange"
                    , unit       = untab$umolcom2os
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(green.bg,green.fg)
                    , leg.corner = "bottomright"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 5]] = list( vnam       = "nep"
                    , symbol     = expression(NEP)
                    , desc       = "Net ecosystem productivity"
                    , unit       = untab$kgcom2oyr
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(olive.bg,olive.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 6]] = list( vnam       = "reco"
                    , symbol     = expression(R[Eco])
                    , desc       = "Ecosystem respiration"
                    , unit       = untab$kgcom2oyr
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(yellow.bg,yellow.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 7]] = list( vnam       = "gpp"
                    , symbol     = expression(GPP)
                    , desc       = "Gross primary productivity"
                    , unit       = untab$kgcom2oyr
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(green.bg,green.fg)
                    , leg.corner = "topleft"
                    , sunvar     = TRUE
                    )#end list
compvar[[ 8]] = list( vnam       = "parup"
                    , symbol     = expression(PAR^symbol("\335"))
                    , desc       = "Outgoing PAR"
                    , unit       = untab$umolom2os
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(olive.bg,olive.fg)
                    , leg.corner = "topleft"
                    , sunvar     = TRUE
                    )#end list
compvar[[ 9]] = list( vnam       = "rshortup"
                    , symbol     = expression(SW^symbol("\335"))
                    , desc       = "Outgoing shortwave radiation"
                    , unit       = untab$wom2
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(indigo.bg,indigo.fg)
                    , leg.corner = "topleft"
                    , sunvar     = TRUE
                    )#end list
compvar[[10]] = list( vnam       = "rnet"
                    , symbol     = expression(R[Net])
                    , desc       = "Net radiation"
                    , unit       = untab$wom2
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(sky.bg,sky.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[11]] = list( vnam       = "rlongup"
                    , symbol     = expression(LW^symbol("\335"))
                    , desc       = "Outgoing longwave radiation"
                    , unit       = untab$wom2
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(red.bg,red.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[12]] = list( vnam       = "hflxca"
                    , symbol     = expression(F(theta))
                    , desc       = "Sensible heat flux"
                    , unit       = untab$wom2
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(orange.bg,orange.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[13]] = list( vnam       = "wflxca"
                    , symbol     = expression(F(H[2]*O))
                    , desc       = "Water vapour flux"
                    , unit       = untab$kgwom2oday
                    , col.obser  = c(grey.bg,grey.fg)
                    , col.model  = c(blue.bg,blue.fg)
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     Input variables.                                                                     #
#------------------------------------------------------------------------------------------#
control       = list()
control[[ 1]] = list( vnam       = "rshort"
                    , desc       = "Incoming shortwave radiation"
                    , unit       = untab$wom2
                    )#end list
control[[ 2]] = list( vnam       = "rlong"
                    , desc       = "Incoming longwave radiation"
                    , unit       = untab$wom2
                    )#end list
control[[ 3]] = list( vnam       = "atm.prss"
                    , desc       = "Air pressure"
                    , unit       = untab$hpa
                    )#end list
control[[ 4]] = list( vnam       = "atm.temp"
                    , desc       = "Air temperature"
                    , unit       = untab$degC
                    )#end list
control[[ 5]] = list( vnam       = "atm.shv"
                    , desc       = "Air specific humidity"
                    , unit       = untab$gwokg
                    )#end list
control[[ 6]] = list( vnam       = "atm.vels"
                    , desc       = "Wind speed"
                    , unit       = untab$mos
                    )#end list
control[[ 7]] = list( vnam       = "rain"
                    , desc       = "Precipitation rate"
                    , unit       = untab$kgwom2oday
                    )#end list
control[[ 8]] = list( vnam       = "bsa"
                    , desc       = "Basal area"
                    , unit       = untab$cm2om2
                    )#end list
control[[ 9]] = list( vnam       = "wdens"
                    , desc       = "Mean wood density"
                    , unit       = untab$kgom3
                    )#end list
control[[10]] = list( vnam       = "global"
                    , desc       = "Global index"
                    , unit       = untab$empty
                    )#end list
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#     Statistics.                                                                          #
#------------------------------------------------------------------------------------------#
good = list()
good[[ 1]] = list( vnam      = "bias"
                 , desc      = "Mean bias"
                 , spider    = TRUE
                 , normalise = TRUE
                 )#end list
good[[ 2]] = list( vnam      = "rmse"
                 , desc      = "Root mean square error"
                 , spider    = TRUE
                 , normalise = TRUE
                 )#end list
good[[ 3]] = list( vnam      = "r.squared"
                 , desc      = "Coefficient of determination"
                 , spider    = FALSE
                 , normalise = FALSE
                 )#end list
good[[ 4]] = list( vnam      = "fvue"
                 , desc      = "Fraction of variability unexplained"
                 , spider    = TRUE
                 , normalise = FALSE
                 )#end list
good[[ 5]] = list( vnam      = "sw.stat"
                 , desc      = "Shapiro-Wilk statistic"
                 , spider    = TRUE
                 , normalise = FALSE
                 )#end list
good[[ 6]] = list( vnam      = "ks.stat"
                 , desc      = "Kolmogorov-Smirnov statistic"
                 , spider    = TRUE
                 , normalise = FALSE
                 )#end list
good[[ 7]] = list( vnam      = "lsq.lnlike"
                 , desc      = "Scaled support based on least squares"
                 , spider    = FALSE
                 , normalise = FALSE
                 )#end list
good[[ 8]] = list( vnam      = "sn.lnlike"
                 , desc      = "Scaled support based on skew normal distribution"
                 , spider    = FALSE
                 , normalise = FALSE
                 )#end list
good[[ 9]] = list( vnam      = "norm.lnlike"
                 , desc      = "Scaled support based on normal distribution"
                 , spider    = FALSE
                 , normalise = FALSE
                 )#end list
#------------------------------------------------------------------------------------------#


#----- Set how many formats we must output. -----------------------------------------------#
outform = tolower(outform)
nout    = length(outform)
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#     Combine all structures into a consistent list.                                       #
#------------------------------------------------------------------------------------------#
n.sim       = length(sim.struct$name)
#----- Simulation keys. -------------------------------------------------------------------#
simul.key   = sim.struct$name
#----- Description. -----------------------------------------------------------------------#
simleg.key  = sim.struct$desc
#---- Create the colours and line type for legend. ----------------------------------------#
simcol.key     = sim.struct$colour
simlty.key     = rep("solid",times=n.sim)
simcex.key     = rep(2.0    ,times=n.sim)
simlwd.key     = rep(2.0    ,times=n.sim)
simpch.key     = rep(21     ,times=n.sim)
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     Dump the information to a list.                                                      #
#------------------------------------------------------------------------------------------#
simul       = data.frame( name             = simul.key
                        , desc             = simleg.key
                        , colour           = simcol.key
                        , lty              = simlty.key
                        , cex              = simcex.key
                        , lwd              = simlwd.key
                        , pch              = simpch.key
                        , stringsAsFactors = FALSE
                        )#end data.frame
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#      List the keys for all dimensions.                                                   #
#------------------------------------------------------------------------------------------#
sites.key    = sites
sites.desc   = poilist$longname[match(sites.key,poilist$iata)]
control.key  = apply(X = sapply(X=control,FUN=c),MARGIN=1,FUN=unlist)[,"vnam"]
compvar.key  = apply(X = sapply(X=compvar,FUN=c),MARGIN=1,FUN=unlist)$vnam
compvar.sym  = apply(X = sapply(X=compvar,FUN=c),MARGIN=1,FUN=unlist)$symbol
good.key     = apply(X = sapply(X=good   ,FUN=c),MARGIN=1,FUN=unlist)[,"vnam"]
season.key   = season.list
diel.key     = c("night","rise.set","day","all.hrs")
diel.desc    = c("Nighttime","Sun Rise/Set","Daytime","All hours")
#------------------------------------------------------------------------------------------#



#----- Set the various dimensions associated with variables, simulations, and sites. ------#
nsites   = length(sites.key  )
nsimul   = length(simul.key  )
ncompvar = length(compvar.key)
ncontrol = length(control.key)
ngood    = length(good.key   )
nseason  = length(season.key )
ndiel    = length(diel.key   )
#------------------------------------------------------------------------------------------#



#----- Load observations. -----------------------------------------------------------------#
obser.file = paste(srcdir,"LBA_MIP.nogapfill.RData",sep="/")
load(file=obser.file)
#------------------------------------------------------------------------------------------#



#----- Define plot window size ------------------------------------------------------------#
size = plotsize(proje=FALSE,paper=paper)
#------------------------------------------------------------------------------------------#



#----- Find the best set up for plotting all seasons in the same plot. --------------------#
lo.box = pretty.box(n=nseason-1)
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#      Create all output directories, separated by format.                                 #
#------------------------------------------------------------------------------------------#
if (! file.exists(outroot)) dir.create(outroot)
out = list()
for (o in 1:nout){
   is.figure   = ! outform[o] %in% c("quartz","x11")
   this.form   = outform[o]


   #---- Main path for this output format. ------------------------------------------------#
   o.form = list()
   o.form$main = file.path(outroot,this.form)
   if (is.figure && ! file.exists(o.form$main)) dir.create(o.form$main)
   #---------------------------------------------------------------------------------------#




   #---------------------------------------------------------------------------------------#
   #     Create paths for the "spider web" plots.                                          #
   #---------------------------------------------------------------------------------------#
   o.spider                = list()
   o.spider$main           = file.path(o.form$main,"spider")
   if (is.figure && ! file.exists(o.spider$main)) dir.create(o.spider$main)
   for (d in 1:ndiel){
      this.diel        = diel.key [d]
      o.diel           = list()
      o.diel$main      = file.path(o.spider$main,this.diel  )
      o.diel$sites     = file.path(o.diel$main  ,"sites"    )
      o.diel$variables = file.path(o.diel$main  ,"variables")
      if (is.figure){
         if (! file.exists(o.diel$main     )) dir.create(o.diel$main     )
         if (! file.exists(o.diel$sites    )) dir.create(o.diel$sites    )
         if (! file.exists(o.diel$variables)) dir.create(o.diel$variables)
      }#end if (is.figure)
      #------------------------------------------------------------------------------------#
      o.spider[[this.diel]] = o.diel
   }#end for (d in 1:ndiel)
   o.form$spider = o.spider
   #---------------------------------------------------------------------------------------#




   #---------------------------------------------------------------------------------------#
   #     Create paths for the skill diagrams.                                              #
   #---------------------------------------------------------------------------------------#
   o.skill                = list()
   o.skill$main           = file.path(o.form$main,"skill")
   if (is.figure && ! file.exists(o.skill$main)) dir.create(o.skill$main)
   for (d in sequence(ndiel)){
      this.diel        = diel.key [d]
      o.diel           = file.path(o.skill$main,this.diel  )
      if (is.figure){
         if (! file.exists(o.diel)) dir.create(o.diel)
      }#end if (is.figure)
      #------------------------------------------------------------------------------------#
      o.skill[[this.diel]] = o.diel
   }#end for (d in 1:ndiel)
   o.form$skill = o.skill
   #---------------------------------------------------------------------------------------#




   #---------------------------------------------------------------------------------------#
   #     Create paths for the Taylor diagrams.                                             #
   #---------------------------------------------------------------------------------------#
   o.taylor      = list()
   o.taylor$main = file.path(o.form$main,"taylor")
   if (is.figure && ! file.exists(o.taylor$main)) dir.create(o.taylor$main)
   for (d in sequence(ndiel)){
      this.diel  = diel.key [d]
      o.diel     = file.path(o.taylor$main,this.diel)
      if (is.figure){
         if (! file.exists(o.diel)) dir.create(o.diel)
      }#end if (is.figure)
      #------------------------------------------------------------------------------------#
      o.taylor[[this.diel]] = o.diel
   }#end for (d in 1:ndiel)
   o.form$taylor = o.taylor
   #---------------------------------------------------------------------------------------#


   #----- Save the full list to the main path list. ---------------------------------------#
   out[[this.form]] = o.form
   #---------------------------------------------------------------------------------------#
}#end for (o in 1:nout)
#------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------#
#   Loop through the sites.                                                                #
#------------------------------------------------------------------------------------------#
cat (" + Add season and diel keys to seasons and diel...","\n")
for (p in 1:nsites){
   #----- Grab the observation. -----------------------------------------------------------#
   obser      = get(paste("obs",sites[p],sep="."))
   #---------------------------------------------------------------------------------------#


   #----- Create some variables to describe season and time of the day. -------------------#
   if (! "season" %in% names(obser)) obser$season = season(obser$when,add.year=FALSE)
   if (! "diel" %in% names(obser))   obser$diel   = (! obser$nighttime) + obser$highsun
   #---------------------------------------------------------------------------------------#



   #----- Save the variables to the observations. -----------------------------------------#
   dummy = assign(paste("obs",sites[p],sep="."),obser)
   #---------------------------------------------------------------------------------------#
}#end for (p in sequence(nsites))
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#      Retrieve all data.                                                                  #
#------------------------------------------------------------------------------------------#
cat (" + Retrieve model results for all sites...","\n")
res = list()
for (p in sequence(nsites)){
   #----- Get the basic information. ------------------------------------------------------#
   iata          = sites[p]
   im            = match(iata,poilist$iata)
   this          = list()
   this$short    = poilist$short   [im]
   this$longname = poilist$longname[im]
   this$iata     = poilist$iata    [im]
   this$lon      = poilist$lon     [im]
   this$lat      = poilist$lat     [im]
   this$sim      = list()
   this$ans      = list()
   cat("   - Site :",this$longname,"...","\n")
   #---------------------------------------------------------------------------------------#


   #---------------------------------------------------------------------------------------#
   #     Get observations, and make sure everything matches.                               #
   #---------------------------------------------------------------------------------------#
   obser      = get(paste("obs",iata,sep="."))
   nobser     = length(obser$when)
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Get all the statistics and actual values for every simulation.                    #
   #---------------------------------------------------------------------------------------#
   trimmed    = FALSE
   for (s in sequence(nsimul)){
      cat("    * Simulation: ",simul$desc[s],"...","\n")


      #----- Load pre-calculated statistics. ----------------------------------------------#
      sim.name = paste(eort,iata,"_",simul$name[s],sep="")
      sim.path = paste(here,sim.name,sep="/")
      sim.file = paste(sim.path,"rdata_hour",paste("comp-",sim.name,".RData",sep="")
                      ,sep="/")
      load(sim.file)
      #------------------------------------------------------------------------------------#



      #----- Load hourly averages. --------------------------------------------------------#
      ans.name = paste("t",iata,"_",simul$name[s],sep="")
      ans.path = paste(here,sim.name,sep="/")
      ans.file = paste(sim.path,"rdata_hour",paste(sim.name,".RData",sep="")
                      ,sep="/")
      load(ans.file)
      nmodel     = length(model$when)
      #------------------------------------------------------------------------------------#


      #====================================================================================#
      #====================================================================================#
      #      In case the models and observations don't match perfectly, we trim            #
      # observations.  This can be done only once, otherwise the models don't have the     #
      # same length, which is unacceptable.                                                #
      #------------------------------------------------------------------------------------#
      if (nobser != nmodel && ! trimmed){
         trimmed = TRUE

         #----- Get the model time range. -------------------------------------------------#
         this.whena = min(as.numeric(model$when))
         this.whenz = max(as.numeric(model$when))
         sel.obser  = obser$when >= this.whena & obser$when <= this.whenz
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #     Loop over all observed variables and trim them to the same model period.    #
         #---------------------------------------------------------------------------------#
         for ( vname in names(obser)){
            if       (length(obser[[vname]]) == nobser){
               obser[[vname]] = obser[[vname]][sel.obser]
            }else if (length(obser[[vname]]) != 1     ){
               sel.now = obser[[vname]] >= this.whena & obser[[vname]] <= this.whenz
               obser[[vname]] = obser[[vname]][sel.now]
            }#end if
         }#end for
         nobser     = length(obser$when)
         #---------------------------------------------------------------------------------#


         #----- Save the variables to the observations. -----------------------------------#
         dummy = assign(paste("obs",sites[p],sep="."),obser)
         #---------------------------------------------------------------------------------#
      }else if (nobser == nmodel){
         #----- Datasets match, switch trimmed to TRUE. -----------------------------------#
         trimmed = TRUE
         #---------------------------------------------------------------------------------#
      }else{
         cat(" -> Simulation:"   ,ans.name          ,"\n")
         cat(" -> Length(obser):",length(obser$when),"\n")
         cat(" -> Length(model):",length(model$when),"\n")
         stop(" Model and obser must have the same length")
      }#end if
      #------------------------------------------------------------------------------------#



      #------------------------------------------------------------------------------------#
      #      Check whether the model and observations are synchronised.                    #
      #------------------------------------------------------------------------------------#
      if (any(as.numeric(model$when-obser$when) > 1/48,na.rm=TRUE)){
         stop(" All times in the model and observations must match!!!")
      }#end if
      #------------------------------------------------------------------------------------#





      #----- Save the data and free some memory. ------------------------------------------#
      this$sim[[simul$name[s]]] = dist.comp
      this$ans[[simul$name[s]]] = model
      rm(list=c("dist.comp","model","eddy.complete","eddy.tresume"))
      #------------------------------------------------------------------------------------#
   }#end for
   #---------------------------------------------------------------------------------------#



   #----- Copy the data to the results. ---------------------------------------------------#
   res[[iata]] = this
   rm(this)
   #---------------------------------------------------------------------------------------#
}#end for
#------------------------------------------------------------------------------------------#





#------------------------------------------------------------------------------------------#
#      Plot the spider web for all sites and all variables, for statistics that may can be #
# plotted in a spider web (i.e., positive defined).                                        #
#------------------------------------------------------------------------------------------#
cat(" + Plot the spider web diagrams for all sites and all variables...","\n")
good.loop = which(unlist(sapply(X=good,FUN=c)["spider",]))
for (g in good.loop){
   #---- Copy structured variables to convenient scratch scalars. -------------------------#
   this.good = good[[g]]$vnam
   desc.good = good[[g]]$desc
   norm.good = good[[g]]$normalise
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #      Load all data to an array.                                                       #
   #---------------------------------------------------------------------------------------#
   cat("   - ",desc.good,"...","\n")
   web = array( dim      = c   (nsimul,nsites,ncompvar,ndiel,nseason)
              , dimnames = list(simul.key,sites.key,compvar.key,diel.key,season.key)
              )#end array 
   for (v in sequence(ncompvar)){
      this.vnam     = compvar[[v]]$vnam
      this.measured = paste("measured",this.vnam,sep=".")

      #------------------------------------------------------------------------------------#
      #     Loop over all sites.                                                           #
      #------------------------------------------------------------------------------------#
      for (p in 1:nsites){
         iata = sites.key[p]
         sfac = matrix(data=1,nrow=ndiel,ncol=nseason,dimnames=list(diel.key,season.key))

         #---------------------------------------------------------------------------------#
         #     Find the scale factors for variables that have units.                       #
         #---------------------------------------------------------------------------------#
         if (norm.good){
            obs  = get(paste("obs",iata,sep="."))

            #----- Find out when this output variable is finite and measured. -------------#
            p.sel = is.finite(obs[[this.vnam]]) & obs[[this.measured]]
            #------------------------------------------------------------------------------#

            dd = sequence(ndiel-1)
            ee = sequence(nseason-1)

            #----- Find the components. ---------------------------------------------------#
            for (dd in sequence(ndiel)){
               d.sel = obs$diel == dd | dd == ndiel
               for (ee in sequence(nseason)){
                  e.sel = obs$season == ee | ee == nseason
                  sel   = p.sel & d.sel & e.sel
                  if (any(sel)) sfac[dd,ee] = sd(obs[[this.vnam]][sel],na.rm=TRUE)
               }#end for
            }#end for
            #------------------------------------------------------------------------------#
         }#end if (norm.good)
         sfac = ifelse(sfac == 0.,NA,1/sfac)
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #     Grab the data for this simulation.                                          #
         #---------------------------------------------------------------------------------#
         for (s in sequence(nsimul)){
            this         = res[[iata]]$sim[[s]][[this.vnam]][[this.good]]
            use.season   = paste(sprintf("%2.2i",sequence(nseason)),season.key,sep="-")
            web[s,p,v,,] = abs(this[diel.key,use.season]) * sfac
         }#end for (s in 1:nsimul)
         #---------------------------------------------------------------------------------#
      }#end for (p in 1:nsites)
      #------------------------------------------------------------------------------------#
   }#end for (v in 1:ncompvar)
   #---------------------------------------------------------------------------------------#





   #---------------------------------------------------------------------------------------#
   #     Plot the spider webs by diel and variable.                                        #
   #---------------------------------------------------------------------------------------#
   for (d in sequence(ndiel)){
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #     Webs by site (all variables).                                                  #
      #------------------------------------------------------------------------------------#
      for (p in sequence(nsites)){
         iata     = sites.key[p]

         letitre = paste(desc.good," - ",sites.desc[p],"\n",diel.desc[d],sep="")

         if (any(is.finite(web[,p,,d,nseason]))){
            v.sel = is.finite(colSums(web[,p,,d,nseason]))

            if (this.good %in% "sw.stat"){
               web.range = c(0,1)
            }else{
               web.range = range(c(0,web[,p,v.sel,d,nseason]),na.rm=TRUE)
            }#end if
            if (ptsz <= 11){
               web.lim   = pretty(web.range,n=5)
            }else if (ptsz <= 14){
               web.lim   = pretty(web.range,n=4)
            }else{
               web.lim   = pretty(web.range,n=3)
            }#end if

            #------------------------------------------------------------------------------#
            #     Webs by variable (all sites).                                            #
            #------------------------------------------------------------------------------#
            for (o in sequence(nout)){
               #----- Make the file name. -------------------------------------------------#
               out.web = out[[outform[o]]]$spider[[diel.key[d]]]$sites
               fichier   = file.path(out.web,paste("spider-",this.good,"-",iata
                                            ,"-",diel.key[d],".",outform[o],sep="")
                                    )#end file.path
               if (outform[o] == "x11"){
                  X11(width=size$width,height=size$height,pointsize=ptsz)
               }else if(outform[o] == "png"){
                  png(filename=fichier,width=size$width*depth,height=size$height*depth
                     ,pointsize=ptsz,res=depth)
               }else if(outform[o] == "eps"){
                  postscript(file=fichier,width=size$width,height=size$height
                            ,pointsize=ptsz,paper=size$paper)
               }else if(outform[o] == "pdf"){
                  pdf(file=fichier,onefile=FALSE,width=size$width,height=size$height
                     ,pointsize=ptsz,paper=size$paper)
               }#end if
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Split the window into 3, and add site and simulation legends at the   #
               # bottom.                                                                   #
               #---------------------------------------------------------------------------#
               par(par.user)
               par.orig = par(no.readonly = TRUE)
               mar.orig = par.orig$mar
               par(oma = c(0.2,3,3.0,0))
               layout(mat = rbind(2,1),height = c(18,4))
               #---------------------------------------------------------------------------#




               #----- Legend: the simulations. --------------------------------------------#
               par(mar=c(0.2,0.1,0.1,0.1))
               plot.new()
               plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
               legend ( x       = "bottom"
                      , inset   = 0.0
                      , legend  = simul$desc
                      , fill    = simul$col
                      , border  = simul$col
                      , ncol    = 2
                      , title   = expression(bold("Structure"))
                      , cex     = cex.ptsz
                      , xpd     = TRUE
                      )#end legend
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Plot the spider web.                                                  #
               #---------------------------------------------------------------------------#
               radial.flex( lengths          = web[,p,v.sel,d,nseason]
                          , labels           = as.expression(compvar.sym[v.sel])
                          , lab.col          = foreground
                          , lab.bg           = background
                          , radlab           = FALSE
                          , start            = 90
                          , clockwise        = TRUE
                          , rp.type          = "p"
                          , label.prop       = 1.15 * max(1,sqrt(ptsz / 14))
                          , main             = ""
                          , line.col         = simul$col
                          , lty              = simul$lty
                          , lwd              = 3.0
                          , show.grid        = TRUE
                          , show.grid.labels = 4
                          , show.radial.grid = TRUE
                          , grid.col         = grid.colour
                          , radial.lim       = web.lim
                          , radial.col       = foreground
                          , radial.bg        = background
                          , poly.col         = NA
                          , mar              = c(2,1,2,1)+0.1
                          , cex.lab          = 0.5
                          )#end radial.plot
               #---------------------------------------------------------------------------#


               #---------------------------------------------------------------------------#
               #     Plot the global title.                                                #
               #---------------------------------------------------------------------------#
               par(las=0)
               mtext(text=letitre,side=3,outer=TRUE,cex=1.1,font=2)
               #---------------------------------------------------------------------------#


               #----- Close the device. ---------------------------------------------------#
               if (outform[o] == "x11"){
                  locator(n=1)
                  dev.off()
               }else{
                  dev.off()
               }#end if
               dummy = clean.tmp()
               #---------------------------------------------------------------------------#

            }#end for (o in 1:nout)
            #------------------------------------------------------------------------------#
         }#end if (any(is.finite(web[,,v,d,nseason])))
         #---------------------------------------------------------------------------------#
      }#end for (v in 1:ncompvar)
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#




      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #     Webs by variable (all sites).                                                  #
      #------------------------------------------------------------------------------------#
      for (v in 1:ncompvar){
         this.vnam     = compvar[[v]]$vnam
         this.desc     = compvar[[v]]$desc

         letitre = paste(desc.good," - ",this.desc,"\n",diel.desc[d],sep="")

         if (any(is.finite(web[,,v,d,nseason]))){
            p.sel = is.finite(colSums(web[,,v,d,nseason]))

            if (this.good %in% "sw.stat"){
               web.range = c(0,1)
            }else{
               web.range = range(c(0,web[,p.sel,v,d,nseason]),na.rm=TRUE)
            }#end if
            web.lim   = pretty(web.range,n=4)

            #------------------------------------------------------------------------------#
            #     Webs by variable (all sites).                                            #
            #------------------------------------------------------------------------------#
            for (o in 1:nout){
               #----- Make the file name. -------------------------------------------------#
               out.web = out[[outform[o]]]$spider[[diel.key[d]]]$variables
               fichier   = file.path(out.web,paste("spider-",this.good,"-",this.vnam,"-"
                                                  ,diel.key[d],".",outform[o],sep=""))
               if (outform[o] == "x11"){
                  X11(width=size$width,height=size$height,pointsize=ptsz)
               }else if(outform[o] == "png"){
                  png(filename=fichier,width=size$width*depth,height=size$height*depth
                     ,pointsize=ptsz,res=depth)
               }else if(outform[o] == "eps"){
                  postscript(file=fichier,width=size$width,height=size$height
                            ,pointsize=ptsz,paper=size$paper)
               }else if(outform[o] == "pdf"){
                  pdf(file=fichier,onefile=FALSE,width=size$width,height=size$height
                     ,pointsize=ptsz,paper=size$paper)
               }#end if
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Split the window into 3, and add site and simulation legends at the   #
               # bottom.                                                                   #
               #---------------------------------------------------------------------------#
               par(par.user)
               par.orig = par(no.readonly = TRUE)
               mar.orig = par.orig$mar
               par(oma = c(0.2,3,3.0,0))
               layout(mat = rbind(2,1),height = c(5.0,1.0))
               #---------------------------------------------------------------------------#




               #----- Legend: the simulations. --------------------------------------------#
               par(mar=c(0.2,0.1,0.1,0.1))
               plot.new()
               plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
               legend ( x       = "bottom"
                      , inset   = 0.0
                      , legend  = simul$desc
                      , fill    = simul$col
                      , border  = simul$col
                      , ncol    = 2
                      , title   = expression(bold("Structure"))
                      , pt.cex  = simul$cex
                      , cex     = cex.ptsz
                      )#end legend
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Plot the spider web.                                                  #
               #---------------------------------------------------------------------------#
               radial.flex( lengths          = web[,p.sel,v,d,nseason]
                          , labels           = toupper(sites.key[p.sel])
                          , radlab           = FALSE
                          , start            = 90
                          , clockwise        = TRUE
                          , rp.type          = "p"
                          , main             = ""
                          , line.col         = simul$col
                          , lty              = simul$lty
                          , lwd              = 3.0
                          , show.grid        = TRUE
                          , show.grid.labels = 4
                          , show.radial.grid = TRUE
                          , grid.col         = grid.colour
                          , radial.lim       = web.lim
                          , poly.col         = NA
                          , mar              = c(2,1,2,1)+0.1
                          , cex.lab          = 0.5
                          )#end radial.plot
               #---------------------------------------------------------------------------#


               #---------------------------------------------------------------------------#
               #     Plot the global title.                                                #
               #---------------------------------------------------------------------------#
               par(las=0)
               mtext(text=letitre,side=3,outer=TRUE,cex=1.1,font=2)
               #---------------------------------------------------------------------------#


               #----- Close the device. ---------------------------------------------------#
               if (outform[o] == "x11"){
                  locator(n=1)
                  dev.off()
               }else{
                  dev.off()
               }#end if
               dummy = clean.tmp()
               #---------------------------------------------------------------------------#

            }#end for (o in 1:nout)
            #------------------------------------------------------------------------------#
         }#end if (any(is.finite(web[,,v,d,nseason])))
         #---------------------------------------------------------------------------------#
      }#end for (v in 1:ncompvar)
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
   }#end for (d in 1:ndiel)
   #---------------------------------------------------------------------------------------#
}#end for (g in good.loop)
#------------------------------------------------------------------------------------------#







#------------------------------------------------------------------------------------------#
#         Plot the Skill and Taylor diagrams.                                              #
#------------------------------------------------------------------------------------------#
cat (" + Plot cross-model and cross-site diagrams (Skill and Taylor)...","\n")
for (v in sequence(ncompvar)){
   #----- Copy the variable information. --------------------------------------------------#
   this.vnam     = compvar[[v]]$vnam
   this.desc     = compvar[[v]]$desc
   this.unit     = compvar[[v]]$unit
   this.sun      = compvar[[v]]$sunvar
   this.measured = paste("measured",this.vnam,sep=".")
   cat("   - ",this.desc,"...","\n")
   #---------------------------------------------------------------------------------------#




   #---------------------------------------------------------------------------------------#
   #      Loop over all parts of the day.                                                  #
   #---------------------------------------------------------------------------------------#
   for (d in sequence(ndiel)){
      cat("     * ",diel.desc[d],"...","\n")


      #------------------------------------------------------------------------------------#
      #      Loop over all sites, normalise the data and create the vector for the model.  #
      #------------------------------------------------------------------------------------#
      obs.diel    = list()
      mod.diel    = list()
      cnt.diel    = rep(x=NA,times=nsites); names(cnt.diel) = sites
      bias.range  = NULL
      sigma.range = NULL
      for (p in sequence(nsites)){
         iata  = sites[p]
         obs   = get(paste("obs",iata,sep="."))
         nwhen = length(obs$when)


         #----- Select this diel (or everything for all day). -----------------------------#
         d.sel = (obs$diel == (d-1) | d == ndiel) & ((! this.sun) | obs$highsun)
         sel   = d.sel & is.finite(obs[[this.vnam]]) & obs[[this.measured]]
         sel   = sel   & is.finite(sel)
         n.sel = sum(sel)
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #     Find the standard deviation of this observation.  Skip the site if every-   #
         # thing is zero.                                                                  #
         #---------------------------------------------------------------------------------#
         this.obs     = obs[[this.vnam]][sel]
         sdev.obs.now = sd(this.obs,na.rm=TRUE)
         sel          = sel & is.finite(sdev.obs.now) & sdev.obs.now > 0
         #---------------------------------------------------------------------------------#



         #----- Copy the observed data. ---------------------------------------------------#
         obs.diel[[iata]] = this.obs
         #---------------------------------------------------------------------------------#



         #----- Copy the modelled data, and update ranges. --------------------------------#
         mod.diel[[iata]] = matrix(ncol=nsimul,nrow=n.sel,dimnames=list(NULL,simul.key))
         if (any(sel)){
            for (s in sequence(nsimul)){



               #----- Copy simulation. ----------------------------------------------------#
               this.mod             = res[[iata]]$ans[[simul.key[s]]][[this.vnam]][sel]
               this.res             = this.mod - this.obs
               mod.diel[[iata]][,s] = this.mod
               #---------------------------------------------------------------------------#

               #----- Check number of valid entries. --------------------------------------#
               if (! is.null(cnt.diel[[iata]])) cnt.diel[[iata]] = sum(is.finite(this.res))
               #---------------------------------------------------------------------------#

               #----- Find the normalised bias and model standard deviation. --------------#
               bias.now    = mean(this.res, na.rm=TRUE) / sdev.obs.now
               sigma.now   = sd  (this.res, na.rm=TRUE) / sdev.obs.now
               bias.range  = c(bias.range ,bias.now   )
               sigma.range = c(sigma.range,sigma.now  )
               #---------------------------------------------------------------------------#
            }#end for (s in sequence(nsimul))
            #------------------------------------------------------------------------------#
         }#end if (any(sel))
         #---------------------------------------------------------------------------------#
      }#end for (p in 1:nsites)
      #------------------------------------------------------------------------------------#




      #------------------------------------------------------------------------------------#
      #     Plot Taylor and skill plots only if there is anything to plot.                 #
      #------------------------------------------------------------------------------------#
      ok.taylor.skill = ( length(unlist(obs.diel)) > 0  && any(cnt.diel > 0)           &&
                          any(is.finite(bias.range))    && any(is.finite(sigma.range))    )
      if (ok.taylor.skill){
         #---- Fix ranges. ----------------------------------------------------------------#
         xy.range    = 1.04 * max(abs(c(bias.range,sigma.range)),na.rm=TRUE)
         bias.range  = 1.04 * xy.range  * c(-1,1)
         sigma.range = 1.04 * xy.range  * c( 1,0)
         r2.range    = range(1-xy.range^2,1)
         #---------------------------------------------------------------------------------#




         #---------------------------------------------------------------------------------#
         #     Calculate the size for the points in the Skill and Taylor diagrams.  Make   #
         # it proportional to the number of points used to evaluate each place.            #
         #---------------------------------------------------------------------------------#
         st.cnt.min = min (cnt.diel[cnt.diel > 0] , na.rm = TRUE)
         st.cnt.max = max (cnt.diel[cnt.diel > 0] , na.rm = TRUE)
         st.cnt.med = round(mean(c(st.cnt.min,st.cnt.max)))
         cex.diel   = pmax( st.cex.min, ( st.cex.min + ( st.cex.max  - st.cex.min )
                                                     * (    cnt.diel - st.cnt.min )
                                                     / ( st.cnt.max  - st.cnt.min )
                                        )#end cex.diel
                          )#end pmax
         lwd.diel   = pmax( st.lwd.min, ( st.lwd.min + ( st.lwd.max  - st.lwd.min )
                                                     * (    cnt.diel - st.cnt.min )
                                                     / ( st.cnt.max  - st.cnt.min )
                                        )#end cex.diel
                         )#end pmax
         st.cex.med = mean(c(st.cex.min,st.cex.max))
         #---------------------------------------------------------------------------------#


         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
         #     Skill plot.                                                                 #
         #---------------------------------------------------------------------------------#

         #---------------------------------------------------------------------------------#
         #     Plot title.                                                                 #
         #---------------------------------------------------------------------------------#
         letitre = paste(" Skill diagram - ",this.desc,"\n",diel.desc[d],sep="")
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #      Loop over all formats.                                                     #
         #---------------------------------------------------------------------------------#
         for (o in sequence(nout)){
            #----- Make the file name. ----------------------------------------------------#
            out.skill = out[[outform[o]]]$skill[[diel.key[d]]]
            fichier   = file.path(out.skill,paste("skill-",this.vnam,"-",diel.key[d]
                                                 ,".",outform[o],sep="")
                                 )#end file.path
            if (outform[o] == "x11"){
               X11(width=size$width,height=size$height,pointsize=ptsz)
            }else if(outform[o] == "png"){
               png(filename=fichier,width=size$width*depth,height=size$height*depth
                  ,pointsize=ptsz,res=depth)
            }else if(outform[o] == "eps"){
               postscript(file=fichier,width=size$width,height=size$height,pointsize=ptsz
                         ,paper=size$paper)
            }else if(outform[o] == "pdf"){
               pdf(file=fichier,onefile=FALSE,width=size$width,height=size$height
                  ,pointsize=ptsz,paper=size$paper)
            }#end if
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Split the window into 3, and add site and simulation legends at the      #
            # bottom.                                                                      #
            #------------------------------------------------------------------------------#
            par(par.user)
            par.orig = par(no.readonly = TRUE)
            mar.orig = par.orig$mar
            par(oma = c(0.2,3,3.0,0))
            layout(mat = rbind(c(4,4,4,4,4,4,4),c(1,1,2,3,3,3,3)),height = c(5.0,1.0))
            #------------------------------------------------------------------------------#




            #----- Legend: the sites. -----------------------------------------------------#
            par(mar=c(0.2,0.1,0.1,0.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "bottom"
                   , inset   = 0.0
                   , legend  = toupper(sites.key)
                   , col     = foreground
                   , pt.bg   = foreground
                   , pch     = sites.pch
                   , ncol    = min(4,pretty.box(nsites)$ncol)
                   , title   = expression(bold("Sites"))
                   , pt.cex  = st.cex.med
                   , cex     = 1.1 * cex.ptsz
                   , xpd     = TRUE
                   )#end legend
            #------------------------------------------------------------------------------#




            #----- Legend: the counts. ----------------------------------------------------#
            par(mar=c(0.2,0.1,0.1,0.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "bottom"
                   , inset   = 0.0
                   , legend  = c(st.cnt.min,st.cnt.med,st.cnt.max)
                   , col     = foreground
                   , pt.bg   = foreground
                   , pch     = 15
                   , ncol    = 1
                   , title   = expression(bold("Number Obs."))
                   , pt.cex  = c(st.cex.min,st.cex.med,st.cex.max)
                   , cex     = 1.0 * cex.ptsz
                   , xpd     = TRUE
                   )#end legend
            #------------------------------------------------------------------------------#




            #----- Legend: the simulations. -----------------------------------------------#
            par(mar=c(0.2,0.1,0.1,0.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "bottom"
                   , inset   = 0.0
                   , legend  = simul$desc
                   , fill    = simul$col
                   , border  = simul$col
                   , pch     = simul$pch
                   , ncol    = 2
                   , title   = expression(bold("Structure"))
                   , cex     = 1.0 * cex.ptsz
                   , xpd     = TRUE
                   )#end legend
            #------------------------------------------------------------------------------#


            #------------------------------------------------------------------------------#
            #     Loop over sites.                                                         #
            #------------------------------------------------------------------------------#
            myskill = NULL
            for (p in sequence(nsites)){
               iata = sites[p]

               #----- Skip the site if there is no data. ----------------------------------#
               ok.iata = length(obs.diel[[iata]]) > 0 && any(is.finite(obs.diel[[iata]]))
               ok.iata = ok.iata && ( ! is.na(ok.iata))
               if (ok.iata){
                  #------------------------------------------------------------------------#
                  #     We call skill twice for each site in case the site has two PCHs.   #
                  #------------------------------------------------------------------------#
                  myskill = skill.plot( obs           = obs.diel[[iata]]
                                      , obs.options   = list( col = foreground
                                                            , cex = 2.0
                                                            )#end list
                                      , mod           = mod.diel[[iata]]
                                      , mod.options   = list( col = simul$col
                                                            , bg  = simul$col
                                                            , pch = sites.pch[p]
                                                            , cex = cex.diel [p]
                                                            , lty = "solid"
                                                            , lwd = lwd.diel [p]
                                                            )#end list
                                      , main           = ""
                                      , bias.lim       = bias.range
                                      , r2.lim         = r2.range
                                      , r2.options     = list( col = grid.colour)
                                      , nobias.options = list( col = khaki.mg   )
                                      , rmse.options   = list( col = orange.mg
                                                             , lty = "dotdash"
                                                             , lwd = 1.2
                                                             , bg  = background
                                                             )#end list
                                      , cex.xyzlab     = 1.4
                                      , cex.xyzat      = 1.4
                                      , skill          = myskill
                                      , normalise      = TRUE
                                      , mar            = c(5,4,4,3)+0.1
                                      )#end skill.plot
                  #------------------------------------------------------------------------#
               }#end if (length(obs.diel[[iata]] > 0)
               #---------------------------------------------------------------------------#
            }#end for (p in 1:nsites)
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Plot the global title.                                                   #
            #------------------------------------------------------------------------------#
            par(las=0)
            mtext(text=letitre,side=3,outer=TRUE,cex=1.1,font=2)
            #------------------------------------------------------------------------------#



            #----- Close the device. ------------------------------------------------------#
            if (outform[o] == "x11"){
               locator(n=1)
               dev.off()
            }else{
               dev.off()
            }#end if
            dummy = clean.tmp()
            #------------------------------------------------------------------------------#
         }#end for (o in 1:nout) 
         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#




         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
         #      Taylor plot.                                                               #
         #---------------------------------------------------------------------------------#

         #---------------------------------------------------------------------------------#
         #     Plot title.                                                                 #
         #---------------------------------------------------------------------------------#
         letitre = paste(" Taylor diagram - ",this.desc,"\n",diel.desc[d],sep="")
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #      Loop over all formats.                                                     #
         #---------------------------------------------------------------------------------#
         for (o in sequence(nout)){
            #----- Make the file name. ----------------------------------------------------#
            out.taylor = out[[outform[o]]]$taylor[[diel.key[d]]]
            fichier    = file.path(out.taylor,paste("taylor-",this.vnam,"-",diel.key[d]
                                                   ,".",outform[o],sep=""))
            if (outform[o] == "x11"){
               X11(width=size$width,height=size$height,pointsize=ptsz)
            }else if(outform[o] == "png"){
               png(filename=fichier,width=size$width*depth,height=size$height*depth
                  ,pointsize=ptsz,res=depth)
            }else if(outform[o] == "eps"){
               postscript(file=fichier,width=size$width,height=size$height,pointsize=ptsz
                         ,paper=size$paper)
            }else if(outform[o] == "pdf"){
               pdf(file=fichier,onefile=FALSE,width=size$width,height=size$height
                  ,pointsize=ptsz,paper=size$paper)
            }#end if
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Split the window into 3, and add site and simulation legends at the      #
            # bottom.                                                                      #
            #------------------------------------------------------------------------------#
            par(par.user)
            par.orig = par(no.readonly = TRUE)
            mar.orig = par.orig$mar
            par(oma = c(0.2,3,3.0,0))
            layout(mat = rbind(c(4,4,4,4,4,4,4),c(1,1,2,3,3,3,3)),height = c(5.0,1.0))
            #------------------------------------------------------------------------------#




            #----- Legend: the sites. -----------------------------------------------------#
            par(mar=c(0.2,0.1,0.1,0.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "bottom"
                   , inset   = 0.0
                   , legend  = toupper(sites.key)
                   , col     = foreground
                   , pt.bg   = foreground
                   , pch     = sites.pch
                   , ncol    = min(4,pretty.box(nsites)$ncol)
                   , title   = expression(bold("Sites"))
                   , pt.cex  = st.cex.med
                   , cex     = 1.1 * cex.ptsz
                   , xpd     = TRUE
                   )#end legend
            #------------------------------------------------------------------------------#




            #----- Legend: the counts. ----------------------------------------------------#
            par(mar=c(0.2,0.1,0.1,0.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "bottom"
                   , inset   = 0.0
                   , legend  = c(st.cnt.min,st.cnt.med,st.cnt.max)
                   , col     = foreground
                   , pt.bg   = foreground
                   , pch     = 15
                   , ncol    = 1
                   , title   = expression(bold("Number Obs."))
                   , pt.cex  = c(st.cex.min,st.cex.med,st.cex.max)
                   , cex     = 1.0 * cex.ptsz
                   , xpd     = TRUE
                   )#end legend
            #------------------------------------------------------------------------------#




            #----- Legend: the simulations. -----------------------------------------------#
            par(mar=c(0.2,0.1,0.1,0.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "bottom"
                   , inset   = 0.0
                   , legend  = simul$desc
                   , fill    = simul$col
                   , border  = simul$col
                   , pch     = simul$pch
                   , ncol    = 2
                   , title   = expression(bold("Structure"))
                   , cex     = 1.0 * cex.ptsz
                   , xpd     = TRUE
                   )#end legend
            #------------------------------------------------------------------------------#


            #------------------------------------------------------------------------------#
            #     Loop over sites.                                                         #
            #------------------------------------------------------------------------------#
            add = FALSE
            for (p in sequence(nsites)){
               iata = sites[p]

               #----- Skip the site if there is no data. ----------------------------------#
               ok.iata = length(obs.diel[[iata]]) > 0 && any(is.finite(obs.diel[[iata]]))
               ok.iata = ok.iata && ( ! is.na(ok.iata))
               if (ok.iata){
                  #------------------------------------------------------------------------#
                  #     We call skill twice for each site in case the site has two PCHs.   #
                  #------------------------------------------------------------------------#
                  mytaylor = taylor.plot( obs        = obs.diel[[iata]]
                                        , mod        = mod.diel[[iata]]
                                        , add        = add
                                        , pos.corr   = NA
                                        , pt.col     = simul$col
                                        , pt.bg      = simul$col
                                        , pt.pch     = sites.pch[p]
                                        , pt.cex     = cex.diel [p]
                                        , pt.lwd     = lwd.diel [p]
                                        , obs.col    = foreground
                                        , gamma.col  = sky.mg
                                        , gamma.bg   = background
                                        , sd.col     = grey.fg
                                        , sd.obs.col = yellow.mg
                                        , corr.col   = foreground
                                        , main       = ""
                                        , normalise  = TRUE
                                        )#end taylor.plot
                  add = TRUE
               }#end if (length(obs.diel[[iata]]) > 0.)
               #---------------------------------------------------------------------------#
            }#end for (p in 1:nsites)
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Plot the global title.                                                   #
            #------------------------------------------------------------------------------#
            par(las=0)
            mtext(text=letitre,side=3,outer=TRUE,cex=1.1,font=2)
            #------------------------------------------------------------------------------#



            #----- Close the device. ------------------------------------------------------#
            if (outform[o] == "x11"){
               locator(n=1)
               dev.off()
            }else{
               dev.off()
            }#end if
            dummy = clean.tmp()
            #------------------------------------------------------------------------------#
         }#end for (o in 1:nout) 
         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
         #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      }#end if (length(ref) > 2)
      #------------------------------------------------------------------------------------#
   }#end for (d in 1:ndiel)
   #---------------------------------------------------------------------------------------#
}#end for (v in 1:ncompvar)
#------------------------------------------------------------------------------------------#

