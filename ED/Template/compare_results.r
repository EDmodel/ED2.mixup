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
#------------------------------------------------------------------------------------------#
here    = getwd()                                #   Current directory
srcdir  = "/n/moorcroft_data/mlongo/util/Rsc"    #   Script directory
outroot = paste(here,"twostream_comp",sep="/")   #   Output directory

sites      = c("gyf","cax","m34","s67","s77","s83","ban","pnz","rja","fns","pdg")
simul      = list()
simul[[1]] = list( name   = "pft00_canrad00_sas"
                 , desc   = "Medvigy + SAS"
                 , colour = "chartreuse"
                 )#end list
simul[[2]] = list( name   = "pft00_canrad01_sas"
                 , desc   = "Zhao-Qualls + SAS"
                 , colour = "chartreuse4"
                 )#end list
simul[[3]] = list( name   = "pft00_canrad00_ble"
                 , desc   = "Medvigy + Big Leaf"
                 , colour = "darkorange"
                 )#end list
simul[[4]] = list( name   = "pft00_canrad01_ble"
                 , desc   = "Zhao-Qualls + Big Leaf"
                 , colour = "firebrick"
                 )#end list
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#       Plot options.                                                                      #
#------------------------------------------------------------------------------------------#
outform        = c("eps","png","pdf")  # Formats for output file.  Supported formats are:
                                       #   - "X11" - for printing on screen
                                       #   - "eps" - for postscript printing
                                       #   - "png" - for PNG printing
                                       #   - "pdf" - for PDF printing

byeold         = TRUE                  # Remove old files of the given format?

depth          = 96                    # PNG resolution, in pixels per inch
paper          = "letter"              # Paper size, to define the plot shape
ptsz           = 14                    # Font size.
lwidth         = 2.5                   # Line width
plotgrid       = TRUE                  # Should I plot the grid in the background? 

legwhere       = "topleft"             # Where should I place the legend?
inset          = 0.01                  # Inset between legend and edge of plot region.
legbg          = "white"               # Legend background colour.
fracexp        = 0.40                  # Expansion factor for y axis (to fit legend)
cex.main       = 0.8                   # Scale coefficient for the title
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



#------------------------------------------------------------------------------------------#
#     Eddy flux comparisons.                                                               #
#------------------------------------------------------------------------------------------#
compvar       = list()
compvar[[ 1]] = list( vnam       = "hflxca"
                    , desc       = "Sensible heat flux"
                    , unit       = "[W/m2]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("orange1","chocolate4")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 2]] = list( vnam       = "wflxca"
                    , desc       = "Water vapour flux"
                    , unit       = "[kg/m2/day]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("deepskyblue","royalblue4")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 3]] = list( vnam       = "cflxca"
                    , desc       = "Carbon dioxide flux"
                    , unit       = "[umol/m2/s]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("chartreuse2","darkgreen")
                    , leg.corner = "bottomright"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 4]] = list( vnam       = "cflxst"
                    , desc       = "Carbon dioxide storage"
                    , unit       = "[umol/m2/s]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("lightgoldenrod3","darkorange1")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 5]] = list( vnam       = "gpp"
                    , desc       = "Gross primary productivity"
                    , unit       = "[kgC/m2/yr]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("green3","darkgreen")
                    , leg.corner = "topleft"
                    , sunvar     = TRUE
                    )#end list
compvar[[ 6]] = list( vnam       = "reco"
                    , desc       = "Ecosystem respiration"
                    , unit       = "[kgC/m2/yr]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("yellow3","peru")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 7]] = list( vnam       = "nep"
                    , desc       = "Net ecosystem productivity"
                    , unit       = "[kgC/m2/yr]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("olivedrab2","darkolivegreen4")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 8]] = list( vnam       = "nee"
                    , desc       = "Net ecosystem exchange"
                    , unit       = "[umol/m2/s]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("chartreuse","chartreuse4")
                    , leg.corner = "bottomright"
                    , sunvar     = FALSE
                    )#end list
compvar[[ 9]] = list( vnam       = "ustar"
                    , desc       = "Friction velocity"
                    , unit       = "[m/s]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("mediumpurple1","purple4")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[10]] = list( vnam       = "rlongup"
                    , desc       = "Outgoing longwave radiation"
                    , unit       = "[W/m2]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("gold","orangered")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[11]] = list( vnam       = "rnet"
                    , desc       = "Net radiation"
                    , unit       = "[W/m2]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("gold","orangered")
                    , leg.corner = "topleft"
                    , sunvar     = FALSE
                    )#end list
compvar[[12]] = list( vnam       = "albedo"
                    , desc       = "Albedo"
                    , unit       = "[--]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("orange1","chocolate4")
                    , leg.corner = "topleft"
                    , sunvar     = TRUE
                    )#end list
compvar[[13]] = list( vnam       = "parup"
                    , desc       = "Outgoing PAR"
                    , unit       = "[umol/m2/s]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("chartreuse4","darkolivegreen1")
                    , leg.corner = "topleft"
                    , sunvar     = TRUE
                    )#end list
compvar[[14]] = list( vnam       = "rshortup"
                    , desc       = "Outgoing shortwave radiation"
                    , unit       = "[W/m2]"
                    , col.obser  = c("grey42","grey21")
                    , col.model  = c("royalblue4","deepskyblue")
                    , leg.corner = "topleft"
                    , sunvar     = TRUE
                    )#end list
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     Input variables.                                                                     #
#------------------------------------------------------------------------------------------#
control       = list()
control[[ 1]] = list( vnam       = "rshort"
                    , desc       = "Incoming shortwave radiation"
                    , unit       = "[W/m2]"
                    )#end list
control[[ 2]] = list( vnam       = "rlong"
                    , desc       = "Incoming longwave radiation"
                    , unit       = "[W/m2]"
                    )#end list
control[[ 3]] = list( vnam       = "atm.prss"
                    , desc       = "Air pressure"
                    , unit       = "[hPa]"
                    )#end list
control[[ 4]] = list( vnam       = "atm.temp"
                    , desc       = "Air temperature"
                    , unit       = "[degC]"
                    )#end list
control[[ 5]] = list( vnam       = "atm.shv"
                    , desc       = "Air specific humidity"
                    , unit       = "[g/kg]"
                    )#end list
control[[ 6]] = list( vnam       = "atm.vels"
                    , desc       = "Wind speed"
                    , unit       = "[m/s]"
                    )#end list
control[[ 7]] = list( vnam       = "rain"
                    , desc       = "Precipitation rate"
                    , unit       = "[kg/m2/day]"
                    )#end list
control[[ 8]] = list( vnam       = "bsa"
                    , desc       = "Basal area"
                    , unit       = "[cm2/m2]"
                    )#end list
control[[ 9]] = list( vnam       = "wdens"
                    , desc       = "Mean wood density"
                    , unit       = "[kg/m3]"
                    )#end list
control[[10]] = list( vnam       = "global"
                    , desc       = "Global index"
                    , unit       = "[--]"
                    )#end list
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#     Statistics.                                                                          #
#------------------------------------------------------------------------------------------#
good = list()
good[[ 1]] = list( vnam = "bias"
                 , desc = "Mean bias"
                 )#end list
good[[ 2]] = list( vnam = "rmse"
                 , desc = "Root mean square error"
                 )#end list
good[[ 3]] = list( vnam = "r.squared"
                 , desc = "Coefficient of determination"
                 )#end list
good[[ 4]] = list( vnam = "fvue"
                 , desc = "Fraction of variability unexplained"
                 )#end list
good[[ 5]] = list( vnam = "sw.stat"
                 , desc = "Shapiro-Wilk statistic"
                 )#end list
good[[ 6]] = list( vnam = "ks.stat"
                 , desc = "Kolmogorov-Smirnov statistic"
                 )#end list
good[[ 7]] = list( vnam = "lsq.lnlike"
                 , desc = "Scaled support based on least squares"
                 )#end list
good[[ 8]] = list( vnam = "sn.lnlike"
                 , desc = "Scaled support based on skew normal distribution"
                 )#end list
good[[ 9]] = list( vnam = "norm.lnlike"
                 , desc = "Scaled support based on normal distribution"
                 )#end list
#------------------------------------------------------------------------------------------#



#----- Load some packages. ----------------------------------------------------------------#
source(file.path(srcdir,"load.everything.r"))
#------------------------------------------------------------------------------------------#


#----- In case there is some graphic still opened. ----------------------------------------#
graphics.off()
#------------------------------------------------------------------------------------------#


#----- Set how many formats we must output. -----------------------------------------------#
outform = tolower(outform)
nout    = length(outform)
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#      List the keys for all dimensions.                                                   #
#------------------------------------------------------------------------------------------#
simul.key    = apply(X = sapply(X=simul,FUN=c),MARGIN=1,FUN=unlist)[,  "name"]
simleg.key   = apply(X = sapply(X=simul,FUN=c),MARGIN=1,FUN=unlist)[,  "desc"]
simcol.key   = apply(X = sapply(X=simul,FUN=c),MARGIN=1,FUN=unlist)[,"colour"]
sites.key    = sites
control.key  = apply(X = sapply(X=control,FUN=c),MARGIN=1,FUN=unlist)[,"vnam"]
compvar.key  = apply(X = sapply(X=compvar,FUN=c),MARGIN=1,FUN=unlist)$vnam
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



#----- Avoid unecessary and extremely annoying beeps. -------------------------------------#
options(locatorBell=FALSE)
#------------------------------------------------------------------------------------------#



#----- Load observations. -----------------------------------------------------------------#
obser.file = paste(srcdir,"LBA_MIP.nogapfill.RData",sep="/")
load(file=obser.file)
#------------------------------------------------------------------------------------------#



#----- Define plot window size ------------------------------------------------------------#
size = plotsize(proje=FALSE,paper=paper)
#------------------------------------------------------------------------------------------#



#----- Create the output directory in case there isn't one. -------------------------------#
if (! file.exists(outroot)) dir.create(outroot)
#------------------------------------------------------------------------------------------#



#----- Find the best set up for plotting all seasons in the same plot. --------------------#
lo.box = pretty.box(n=nseason-1)
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#      Retrieve all data.                                                                  #
#------------------------------------------------------------------------------------------#
cat (" + Retrieve data for all sites...","\n")
res = list()
for (p in 1:nsites){
   #----- Get the basic information. ------------------------------------------------------#
   iata = sites[p]
   im   = match(iata,poilist$iata)

   this          = list()
   this$short    = poilist$short   [im]
   this$longname = poilist$longname[im]
   this$iata     = poilist$iata    [im]
   this$lon      = poilist$lon     [im]
   this$lat      = poilist$lat     [im]
   this$sim      = list()

   cat("   - Site :",this$longname,"...","\n")
   for (s in 1:nsimul){
      cat("    * Simulation: ",simul[[s]]$desc,"...","\n")
      sim.name = paste("t",iata,"_",simul[[s]]$name,sep="")
      sim.path = paste(here,sim.name,sep="/")
      sim.file = paste(sim.path,"rdata_hour",paste("comp-",sim.name,".RData",sep="")
                      ,sep="/")
      load(sim.file)
      
      this$sim[[simul[[s]]$name]] = dist.comp
      rm(dist.comp)
   }#end for

   res[[iata]] = this
   rm(this)
}#end for
#------------------------------------------------------------------------------------------#




#------------------------------------------------------------------------------------------#
#         Plot the various statistics as functions of the site "completion".               #
#------------------------------------------------------------------------------------------#
cat (" + Plot statistics as functions of model and fraction of input data...","\n")
performance = array( data     = NA
                   , dim      = c(ncompvar,ngood,nsimul)
                   , dimnames = list(compvar.key,good.key,simul.key)
                   )#end array
for (v in 1:ncompvar){
   #----- Copy the variable information. --------------------------------------------------#
   this.vnam     = compvar[[v]]$vnam
   this.desc     = compvar[[v]]$desc
   this.unit     = compvar[[v]]$unit
   this.sun      = compvar[[v]]$sunvar
   this.measured = paste("measured",this.vnam,sep=".")
   cat("   - ",this.desc,"...","\n")
   #---------------------------------------------------------------------------------------#




   #---------------------------------------------------------------------------------------#
   #     Loop over all sites, seasons, and diel and get the average score for all input    #
   # variables for when the observations are valid.                                        #
   #---------------------------------------------------------------------------------------#
   input.score = array( data     = 0.
                      , dim      = c(ndiel,nseason,ncontrol,nsites)
                      , dimnames = list(diel.key,season.key,control.key,sites.key)
                      )#end score
   output.nobs = array( data     = 0.
                      , dim      = c(ndiel,nseason,nsites)
                      , dimnames = list(diel.key,season.key,sites.key)
                      )#end score
   for (p in 1:nsites){
      #----- Grab the observation. --------------------------------------------------------#
      obs        = get(paste("obs",sites[p],sep="."))
      #------------------------------------------------------------------------------------#


      #----- Create some variables to describe season and time of the day. ----------------#
      if (! "season" %in% names(obs)) obs$season = season(obs$when,add.year=FALSE)
      if (! "diel" %in% names(obs))   obs$diel   = (! obs$nighttime) + obs$highsun
      #------------------------------------------------------------------------------------#



      #----- Find out when this output variable is finite and measured. -------------------#
      p.sel = is.finite(obs[[this.vnam]]) & obs[[this.measured]]
      #------------------------------------------------------------------------------------#


      #------------------------------------------------------------------------------------#
      #      Loop over all seasons.                                                        #
      #------------------------------------------------------------------------------------#
      for (e in 1:nseason){
         #----- Select this season (or everything for all seasons). -----------------------#
         e.sel = obs$season == e | e == nseason
         #---------------------------------------------------------------------------------#


         #---------------------------------------------------------------------------------#
         #      Loop over all parts of the day.                                            #
         #---------------------------------------------------------------------------------#
         for (d in 1:ndiel){
            #----- Select this diel (or everything for all day). --------------------------#
            d.sel = obs$diel == (d-1) | d == ndiel
            d.sel = d.sel & ((! this.sun) | obs$highsun)
            #------------------------------------------------------------------------------#


            #------------------------------------------------------------------------------#
            #      Combine the selections.                                                 #
            #------------------------------------------------------------------------------#
            sel   = e.sel & d.sel & p.sel
            #------------------------------------------------------------------------------#


            #------------------------------------------------------------------------------#
            #      Loop over all control variables (except the "global" one).              #
            #------------------------------------------------------------------------------#
            for (u in 1:(ncontrol-1)){
               #---- Get the score for this variable. -------------------------------------#
               control.vnam = paste("score",control[[u]]$vnam,sep=".")
               obs.score    = obs[[control.vnam]]
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #      Combine all the selections and find the mean score.                  #
               #---------------------------------------------------------------------------#
               input.score[d,e,u,p] = mean(obs.score[sel],na.rm=TRUE)
               #---------------------------------------------------------------------------#
            }#end for
            #------------------------------------------------------------------------------#


            #------------------------------------------------------------------------------#
            #      Find the general score and number of observations.                      #
            #------------------------------------------------------------------------------#
            input.score[d,e,ncontrol,p] = mean(input.score[d,e,1:(ncontrol-1),p],na.rm=TRUE)
            output.nobs[d,e,p]          = sum(sel,na.rm=TRUE)
            #------------------------------------------------------------------------------#
         }#end for (d in 1:ndiel)
         #---------------------------------------------------------------------------------#
      }#end for (e in 1:nseason)
      #------------------------------------------------------------------------------------#
   }#end for (p in 1:nsites)
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #      Make sure that non-finite scores are NA.                                         #
   #---------------------------------------------------------------------------------------#
   input.score[! is.finite(input.score)] = NA
   #---------------------------------------------------------------------------------------#




   #---------------------------------------------------------------------------------------#
   #      Create the output path in case it doesn't exist.                                 #
   #---------------------------------------------------------------------------------------#
   outcomp = paste(outroot,this.vnam,sep="/")
   if (! file.exists(outcomp)) dir.create(outcomp)
   outdiel = paste(outcomp,diel.key ,sep="/")
   for (d in 1:ndiel) if (! file.exists(outdiel[d])) dir.create(outdiel[d])
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #      Loop over all sites and simulations, and grab the data.                          #
   #---------------------------------------------------------------------------------------#
   for (g in 1:ngood){
      nobs.good = output.nobs


      this.good = good[[g]]$vnam
      desc.good = good[[g]]$desc
      cat ("     * ",desc.good,"\n")
      stat    = array( data     = NA
                     , dim      = c(ndiel,nseason,nsimul,nsites)
                     , dimnames = list(diel.key,season.key,simul.key,sites.key)
                     )#end array
      nvars   = array( data     = NA
                     , dim      = c(ndiel,nseason,nsites)
                     , dimnames = list(diel.key,season.key,sites.key)
                     )#end array
      colstat = array( data     = NA_character_
                     , dim      = c(nsimul,nsites)
                     , dimnames = list(simul.key,sites.key)
                     )#end array
      #------------------------------------------------------------------------------------#
      #      Loop over all sites and simulations.                                          #
      #------------------------------------------------------------------------------------#
      for (p in 1:nsites){
         iata         = sites[p]
         obs          = get(paste("obs",sites[p],sep="."))
         for (s in 1:nsimul){
            colstat[s,p]   = simul[[s]]$colour
            this           = res[[iata]]$sim[[s]][[this.vnam]][[this.good]]

            use.season  = paste(sprintf("%2.2i",sequence(nseason)),season.key,sep="-")
            stat[,,s,p] = this[diel.key,use.season]
         }#end for
         #---------------------------------------------------------------------------------#
      }#end for
      bye            = apply(X=(! is.finite(stat)),MARGIN=c(1,2,4),FUN=sum,na.rm=TRUE)
      bye            = bye != 0
      nobs.good[bye] = -1
      #------------------------------------------------------------------------------------#



      #------------------------------------------------------------------------------------#
      #     Standardise the log-likelihood so the data are more comparable.                #
      #------------------------------------------------------------------------------------#
      if (this.good %in% c("lsq.lnlike","sn.lnlike","norm.lnlike")){
         stat.min  = apply(X = stat, MARGIN=c(1,2,4),FUN=min,na.rm=TRUE)
         stat.max  = apply(X = stat, MARGIN=c(1,2,4),FUN=max,na.rm=TRUE)
         stat.orig = stat
         for (s in 1:nsimul){
           stat[,,s,] = 100. * ( (stat.orig[,,s,] - stat.max)/ (stat.max - stat.min) )
         }#end for
      }else if(this.good %in% "r.squared"){
         orig.stat  = stat
         sel        = is.finite(stat) & stat < -1
         stat[sel]  = -1
      }#end if
      #------------------------------------------------------------------------------------#





      #------------------------------------------------------------------------------------#
      #       Plot the box plots.                                                          #
      #------------------------------------------------------------------------------------#
      for (d in 1:ndiel){
         #---------------------------------------------------------------------------------#
         #      Find the limits for the bar plot.                                          #
         #---------------------------------------------------------------------------------#
         xlimit  = c(0,nsites*(nsimul+1))+0.5
         xat     = seq(from=0,to=(nsites-1)*(nsimul+1),by=nsimul+1)+1+0.5*nsimul
         xlines  = seq(from=0,to=nsites*(nsimul+1),by=nsimul+1)+0.5
         if (this.good %in% c("r.squared")){
            y.nobs =  1.10
            y.r2   = -1.10
            ylimit = c(-1.2,1.2)
         }else{
            ylimit  = range(stat[d,,,],na.rm=TRUE)
            if (  any(! is.finite(ylimit)) || (ylimit[1] == ylimit[2] && ylimit[1] == 0)){
               y.nobs    = 0.90
               ylimit    = c(-1,1)
            }else if (ylimit[1] == ylimit[2] ){
               y.nobs    = ylimit[2] * ( 1. + sign(ylimit[2]) * 0.50 * fracexp )
               ylimit[1] = ylimit[1] * ( 1. - sign(ylimit[1])        * fracexp )
               ylimit[2] = ylimit[2] * ( 1. + sign(ylimit[2])        * fracexp )
            }else{
               y.nobs    = ylimit[2] + 0.15 * fracexp * diff(ylimit)
               ylimit[2] = ylimit[2] + 0.30 * fracexp * diff(ylimit)
            }#end if
         }#end if
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #     Loop over all output formats.                                               #
         #---------------------------------------------------------------------------------#
         out.barplot = paste(outdiel[d],"barplot",sep="/")
         if (! file.exists(out.barplot)) dir.create(out.barplot)
         for (o in 1:nout){
            #----- Make the file name. ----------------------------------------------------#
            fichier = paste(out.barplot,"/bplot-byseason-",this.vnam,"-",this.good,"-"
                                       ,diel.key[d],".",outform[o],sep="")
            if (outform[o] == "x11"){
               X11(width=size$width,height=size$height,pointsize=ptsz)
            }else if(outform[o] == "png"){
               png(filename=fichier,width=size$width*depth
                  ,height=size$height*depth,pointsize=ptsz,res=depth)
            }else if(outform[o] == "eps"){
               postscript(file=fichier,width=size$width,height=size$height
                         ,pointsize=ptsz,paper=size$paper)
            }else if(outform[o] == "pdf"){
               pdf(file=fichier,onefile=FALSE
                  ,width=size$width,height=size$height,pointsize=ptsz,paper=size$paper)
            }#end if
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Split the window into several smaller windows.  Add a bottom row to fit  #
            # the legend.                                                                  #
            #------------------------------------------------------------------------------#
            par.orig = par(no.readonly = TRUE)
            mar.orig = par.orig$mar
            par(oma = c(0.2,3,4,0))
            layout(mat    = rbind(1+lo.box$mat,rep(1,times=lo.box$ncol))
                  ,height = c(rep(5/lo.box$nrow,times=lo.box$nrow),1)
                  )#end layout
            #------------------------------------------------------------------------------#



            #----- Plot legend. -----------------------------------------------------------#
            par(mar=c(0.1,0.1,0.1,0.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "bottom"
                   , inset   = 0.0
                   , legend  = simleg.key
                   , fill    = simcol.key
                   , border  = "black"
                   , bg      = "white"
                   , ncol    = min(3,pretty.box(nsimul)$ncol)
                   , title   = expression(bold("Simulation"))
                   , cex     = 1.0
                   )#end legend
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Loop over all seasons, and plot the bar plots.                           #
            #------------------------------------------------------------------------------#
            for (e in 1:(nseason-1)){
               #----- Find out where is this box going, and set up axes and margins. ------#
               left    = (e %% lo.box$ncol) == 1
               right   = (e %% lo.box$ncol) == 0
               top     = e <= lo.box$ncol
               bottom  = e > (lo.box$nrow - 1) * lo.box$ncol
               mar.now = c(4 + 0 * bottom,1 + 1 * left,3 + 0 * top,1 + 1 * right) + 0.1
               #---------------------------------------------------------------------------#


               #----- Set up the title for each plot. -------------------------------------#
               lesub = paste(season.full[e],sep="")
               #---------------------------------------------------------------------------#


               #---------------------------------------------------------------------------#
               #     Order the sites by amount of information.                             #
               #---------------------------------------------------------------------------#
               op   = order(nobs.good[d,e,],na.last=FALSE)
               #---------------------------------------------------------------------------#



               #----- Plot window and grid. -----------------------------------------------#
               par(mar=mar.now,xpd=FALSE,las=2)
               plot.new()
               plot.window(xlim=xlimit,ylim=ylimit,xaxt="n",yaxt="n")
               axis(side=1,at=xat,labels=toupper(sites.key[op]))
               if (left  ) axis(side=2)
               box()
               title(main=lesub)
               if (plotgrid) abline(h=axTicks(2),v=xlines,col="grey83",lty="solid")
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Add the bar plot.                                                     #
               #---------------------------------------------------------------------------#
               xbp = barplot(height=stat[d,e,,op],col=colstat,beside=TRUE,border="grey22"
                            ,add=TRUE,axes=FALSE,axisnames=FALSE,xpd=FALSE)
               text   (x=xat,y=y.nobs,labels=nobs.good[d,e,op],cex=0.7)
               if (this.good %in% c("r.squared")){
                  ybp = y.r2 - 100 * ( orig.stat[d,e,,op] >= -1.0)
                  text(x=xbp,y=ybp,labels=rep("*",times=length(ybp))
                      ,font=2,col="saddlebrown")
               }#end if
               #---------------------------------------------------------------------------#
            }#end for



            #------------------------------------------------------------------------------#
            #     Make the title and axis labels.                                          #
            #------------------------------------------------------------------------------#
            letitre = paste(desc.good," - ",this.desc,"\n",diel.desc[d],sep="")
            if (this.good %in% c("bias","rmse")){
               ley  = paste(desc.good,this.unit,sep=" ")
            }else{
               ley  = paste(desc.good," [--]",sep="")
            }#end if
            lex     = "Sites"
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Plot the global title.                                                   #
            #------------------------------------------------------------------------------#
            par(las=0)
            mtext(text=ley    ,side=2,outer=TRUE,padj=-0.75)
            mtext(text=letitre,side=3,outer=TRUE,cex=1.1,font=2)
            #------------------------------------------------------------------------------#



            #----- Close the device. ------------------------------------------------------#
            if (outform[o] == "x11"){
               locator(n=1)
               dev.off()
            }else{
               dev.off()
            }#end if
            #------------------------------------------------------------------------------#

         }#end for
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #     Plot all seasons together.                                                  #
         #---------------------------------------------------------------------------------#
         #----- Make the title and axis labels. -------------------------------------------#
         letitre = paste(desc.good," - ",this.desc,"\n",diel.desc[d]," - All seasons"
                        ,sep="")
         if (this.good %in% c("bias","rmse")){
            ley  = paste(desc.good,this.unit,sep=" ")
         }else{
            ley  = paste(desc.good," [--]",sep="")
         }#end if
         lex     = "Sites"
         #-----  Order the sites by amount of information. --------------------------------#
         nobs = nobs.good[d,nseason,]
         op   = order(nobs,na.last=FALSE)
         #----- Loop over all formats. ----------------------------------------------------#
         for (o in 1:nout){
            #----- Make the file name. ----------------------------------------------------#
            fichier = paste(out.barplot,"/bplot-allyear-",this.vnam,"-",this.good,"-"
                           ,diel.key[d],".",outform[o],sep="")
            if (outform[o] == "x11"){
               X11(width=size$width,height=size$height,pointsize=ptsz)
            }else if(outform[o] == "png"){
               png(filename=fichier,width=size$width*depth
                  ,height=size$height*depth,pointsize=ptsz,res=depth)
            }else if(outform[o] == "eps"){
               postscript(file=fichier,width=size$width,height=size$height
                         ,pointsize=ptsz,paper=size$paper)
            }else if(outform[o] == "pdf"){
               pdf(file=fichier,onefile=FALSE
                  ,width=size$width,height=size$height,pointsize=ptsz,paper=size$paper)
            }#end if
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Split the window into several smaller windows.  Add a bottom row to fit  #
            # the legend.                                                                  #
            #------------------------------------------------------------------------------#
            par.orig = par(no.readonly = TRUE)
            mar.orig = par.orig$mar
            layout(mat = rbind(2,1), height = c(5,1))
            #------------------------------------------------------------------------------#



            #----- Plot legend. -----------------------------------------------------------#
            par(mar=c(0.1,4.1,0.1,4.1))
            plot.new()
            plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
            legend ( x       = "top"
                   , inset   = 0.0
                   , legend  = simleg.key
                   , fill    = simcol.key
                   , border  = "black"
                   , bg      = "white"
                   , ncol    = min(3,pretty.box(nsimul)$ncol)
                   , title   = expression(bold("Simulation"))
                   , cex     = 0.7
                   )#end legend
            #------------------------------------------------------------------------------#


            #----- Set up the title for each plot. ----------------------------------------#
            lesub = paste("All seasons",sep="")
            #------------------------------------------------------------------------------#



            #----- Plot window and grid. --------------------------------------------------#
            par(mar=c(5,4,3,2)+0.1,xpd=FALSE,las=2)
            plot.new()
            plot.window(xlim=xlimit,ylim=ylimit,xaxt="n",yaxt="n")
            title(main=letitre,xlab=lex,ylab=ley)
            axis(side=1,at=xat,labels=toupper(sites.key[op]))
            axis(side=2)
            box()
            if (plotgrid) abline(h=axTicks(2),v=xlines,col="grey83",lty="solid")
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Add the bar plot.                                                        #
            #------------------------------------------------------------------------------#
            barplot(height=stat[d,nseason,,op],col=colstat,beside=TRUE,border="grey22"
                   ,add=TRUE,axes=FALSE,axisnames=FALSE,xpd=FALSE)
            text(x=xat,y=y.nobs,labels=nobs.good[d,nseason,op],cex=0.9,col="grey22")
            if (this.good %in% c("r.squared")){
               ybp = y.r2 - 100 * ( orig.stat[d,nseason,,op] >= -1.0)
               text(x=xbp,y=ybp,labels=rep("*",times=length(ybp)),font=2,col="saddlebrown")
            }#end if
            #------------------------------------------------------------------------------#



            #----- Close the device. ------------------------------------------------------#
            if (outform[o] == "x11"){
               locator(n=1)
               dev.off()
            }else{
               dev.off()
            }#end if
            #------------------------------------------------------------------------------#

         }#end for
         #---------------------------------------------------------------------------------#



         #---------------------------------------------------------------------------------#
         #      Plot the statistics as a function of the quality of the data.              #
         #---------------------------------------------------------------------------------#
         out.quality = paste(outdiel[d],"quality",sep="/")
         if (! file.exists(out.quality)) dir.create(out.quality)
         for (u in 1:ncontrol){
            this.qual = control[[u]]
            qual.vnam = this.qual$vnam
            qual.desc = this.qual$desc
            qual.unit = this.qual$unit


            #------------------------------------------------------------------------------#
            #     Create the path for the quality due to this particular variable.         #
            #------------------------------------------------------------------------------#
            out.qualnow = paste(out.quality,qual.vnam,sep="/")
            if (! file.exists(out.qualnow)) dir.create(out.qualnow)
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #      Find the limits for the bar plot.                                       #
            #------------------------------------------------------------------------------#
            xlimit  = range(input.score[d,,u,],na.rm=TRUE)
            ylimit  = range(stat       [d,,, ],na.rm=TRUE)
            if (  any(! is.finite(xlimit)) || (xlimit[1] == xlimit[2] && xlimit[1] == 0)){
               xlimit    = c(0,10)
            }else if (xlimit[1] == xlimit[2] ){
               xlimit[1] = xlimit[1] * ( 1. - sign(xlimit[1]) * fracexp)
               xlimit[2] = xlimit[2] * ( 1. + sign(xlimit[2]) * fracexp)
            }#end if
            if (this.good %in% c("r.squared")){
               ylimit = c(-1,1)
            }else{
               ylimit  = range(stat[d,,,],na.rm=TRUE)
               if (  any(! is.finite(ylimit)) 
                  || (ylimit[1] == ylimit[2] && ylimit[1] == 0) ){
                  ylimit    = c(-1,1)
               }else if (ylimit[1] == ylimit[2] ){
                  ylimit[1] = ylimit[1] * ( 1. - sign(ylimit[1]) * fracexp)
                  ylimit[2] = ylimit[2] * ( 1. + sign(ylimit[2]) * fracexp)
               }#end if
            }#end if
            #------------------------------------------------------------------------------#



            #------------------------------------------------------------------------------#
            #     Loop over all output formats.                                            #
            #------------------------------------------------------------------------------#
            for (o in 1:nout){
               #----- Make the file name. -------------------------------------------------#
               fichier = paste(out.qualnow,"/qual-byseason-",this.vnam,"-",qual.vnam,"-"
                              ,this.good,"-",diel.key[d],".",outform[o],sep="")
               if (outform[o] == "x11"){
                  X11(width=size$width,height=size$height,pointsize=ptsz)
               }else if(outform[o] == "png"){
                  png(filename=fichier,width=size$width*depth
                     ,height=size$height*depth,pointsize=ptsz,res=depth)
               }else if(outform[o] == "eps"){
                  postscript(file=fichier,width=size$width,height=size$height
                            ,pointsize=ptsz,paper=size$paper)
               }else if(outform[o] == "pdf"){
                  pdf(file=fichier,onefile=FALSE
                     ,width=size$width,height=size$height,pointsize=ptsz,paper=size$paper)
               }#end if
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Split the window into several smaller windows.  Add a bottom row to   #
               # fit the legend.                                                           #
               #---------------------------------------------------------------------------#
               par.orig = par(no.readonly = TRUE)
               mar.orig = par.orig$mar
               par(oma = c(0.2,3,4,0))
               layout(mat    = rbind(1+lo.box$mat,rep(1,times=lo.box$ncol))
                     ,height = c(rep(5/lo.box$nrow,times=lo.box$nrow),1)
                     )#end layout
               #---------------------------------------------------------------------------#



               #----- Plot legend. --------------------------------------------------------#
               par(mar=c(0.1,0.1,0.1,0.1))
               plot.new()
               plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
               legend ( x       = "bottom"
                      , inset   = 0.0
                      , legend  = simleg.key
                      , fill    = simcol.key
                      , border  = "black"
                      , bg      = "white"
                      , ncol    = min(3,pretty.box(nsimul)$ncol)
                      , title   = expression(bold("Simulation"))
                      , cex     = 1.0
                      )#end legend
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Loop over all seasons, and plot the bar plots.                        #
               #---------------------------------------------------------------------------#
               for (e in 1:(nseason-1)){
                  #----- Find out where is this box going, and set up axes and margins. ---#
                  left    = (e %% lo.box$ncol) == 1
                  right   = (e %% lo.box$ncol) == 0
                  top     = e <= lo.box$ncol
                  bottom  = e > (lo.box$nrow - 1) * lo.box$ncol
                  mar.now = c(1 + 3 * bottom,1 + 1 * left,1 + 2 * top,1 + 1 * right) + 0.1
                  #------------------------------------------------------------------------#


                  #----- Set up the title for each plot. ----------------------------------#
                  lesub = paste(season.full[e],sep="")
                  #------------------------------------------------------------------------#



                  #----- Plot window and grid. --------------------------------------------#
                  par(mar=mar.now,xpd=FALSE,las=1)
                  plot.new()
                  plot.window(xlim=xlimit,ylim=ylimit,xaxt="n",yaxt="n")
                  if (bottom) axis(side=1)
                  if (left  ) axis(side=2)
                  box()
                  title(main=lesub)
                  if (plotgrid) grid(col="grey83",lty="solid")
                  #------------------------------------------------------------------------#



                  #------------------------------------------------------------------------#
                  #     Add the bar plot.                                                  #
                  #------------------------------------------------------------------------#
                  for (s in 1:nsimul){
                     points(x=input.score[d,e,u,],y=stat[d,e,s,],pch=15
                           ,col=simul[[s]]$colour,cex=1.0)
                  }#end for
                  #------------------------------------------------------------------------#
               }#end for
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Make the title and axis labels.                                       #
               #---------------------------------------------------------------------------#
               letitre = paste(desc.good," - ",this.desc,"\n",diel.desc[d],sep="")
               if (this.good %in% c("bias","rmse")){
                  ley  = paste(desc.good,this.unit,sep=" ")
               }else{
                  ley  = paste(desc.good," [--]",sep="")
               }#end if
               lex     = paste("Quality index - ",qual.desc,sep="")
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Plot the global title.                                                #
               #---------------------------------------------------------------------------#
               par(las=0)
               mtext(text=lex    ,side=1,outer=TRUE,padj=-6.00)
               mtext(text=ley    ,side=2,outer=TRUE,padj=-0.75)
               mtext(text=letitre,side=3,outer=TRUE,cex=1.1,font=2)
               #---------------------------------------------------------------------------#



               #----- Close the device. ---------------------------------------------------#
               if (outform[o] == "x11"){
                  locator(n=1)
                  dev.off()
               }else{
                  dev.off()
               }#end if
               #---------------------------------------------------------------------------#
            }#end for (o in 1:nout)
            #------------------------------------------------------------------------------#






            #------------------------------------------------------------------------------#
            #      Plot the combined data for all seasons.                                 #
            #------------------------------------------------------------------------------#
            #----- Make the title and axis labels. ----------------------------------------#
            letitre = paste(desc.good," - ",this.desc,"\n",diel.desc[d]," - All seasons"
                           ,sep="")
            if (this.good %in% c("bias","rmse")){
               ley  = paste(desc.good,this.unit,sep=" ")
            }else{
               ley  = paste(desc.good," [--]",sep="")
            }#end if
            lex     = paste("Quality index - ",qual.desc,sep="")
            #----- Loop over all output formats. ------------------------------------------#
            for (o in 1:nout){
               #----- Make the file name. -------------------------------------------------#
               fichier = paste(out.qualnow,"/qual-allyear-",this.vnam,"-",qual.vnam,"-"
                              ,this.good,"-",diel.key[d],".",outform[o],sep="")
               if (outform[o] == "x11"){
                  X11(width=size$width,height=size$height,pointsize=ptsz)
               }else if(outform[o] == "png"){
                  png(filename=fichier,width=size$width*depth
                     ,height=size$height*depth,pointsize=ptsz,res=depth)
               }else if(outform[o] == "eps"){
                  postscript(file=fichier,width=size$width,height=size$height
                            ,pointsize=ptsz,paper=size$paper)
               }else if(outform[o] == "pdf"){
                  pdf(file=fichier,onefile=FALSE
                     ,width=size$width,height=size$height,pointsize=ptsz,paper=size$paper)
               }#end if
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Split the window into several smaller windows.  Add a bottom row to   #
               # fit the legend.                                                           #
               #---------------------------------------------------------------------------#
               par.orig = par(no.readonly = TRUE)
               mar.orig = par.orig$mar
               layout(mat=rbind(2,1),height=c(5,1))
               #---------------------------------------------------------------------------#



               #----- Plot legend. --------------------------------------------------------#
               par(mar=c(0.1,4.1,0.1,4.1))
               plot.new()
               plot.window(xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n")
               legend ( x       = "top"
                      , inset   = 0.0
                      , legend  = simleg.key
                      , fill    = simcol.key
                      , border  = "black"
                      , bg      = "white"
                      , ncol    = min(3,pretty.box(nsimul)$ncol)
                      , title   = expression(bold("Simulation"))
                      , cex     = 1.0
                      )#end legend
               #---------------------------------------------------------------------------#



               #---------------------------------------------------------------------------#
               #     Plot the annual data, with not distinction between day and night.     #
               #---------------------------------------------------------------------------#
               #----- Plot window and grid. -----------------------------------------------#
               par(mar=c(5,4,3,2)+0.1,xpd=FALSE,las=1)
               plot.new()
               plot.window(xlim=xlimit,ylim=ylimit,xaxt="n",yaxt="n")
               title(main=letitre,xlab=lex,ylab=ley)
               axis(side=1)
               axis(side=2)
               box()
               if (plotgrid) grid(col="grey83",lty="solid")
               #---------------------------------------------------------------------------#



               #---- Add the bar plot. ----------------------------------------------------#
               for (s in 1:nsimul){
                  points(x=input.score[d,nseason,u,],y=stat[d,nseason,s,],pch=15
                        ,col=simul[[s]]$colour,cex=1.0)
               }#end for
               #---------------------------------------------------------------------------#



               #----- Close the device. ---------------------------------------------------#
               if (outform[o] == "x11"){
                  locator(n=1)
                  dev.off()
               }else{
                  dev.off()
               }#end if
               #---------------------------------------------------------------------------#
            }#end for (o in 1:nout)
            #------------------------------------------------------------------------------#





         }#end for (u in 1:ncontrol)
         #---------------------------------------------------------------------------------#
      }#end for (d in 1:ndiel)
      #------------------------------------------------------------------------------------#



      #------------------------------------------------------------------------------------#
      #      Find the general score for all variables.                                     #
      #------------------------------------------------------------------------------------#
      for (s in 1:nsimul){
         performance[v,g,s] = weighted.mean( x = stat       [,,s       ,]
                                           , w = input.score[,,ncontrol,] 
                                               * nobs.good  [,,         ]
                                           , na.rm = TRUE
                                           )#end weighted.mean
      }#end for
      #------------------------------------------------------------------------------------#
   }#end for (g in 1:ngood)
   #---------------------------------------------------------------------------------------#
}#end for (v in 1:ncompvar)
#------------------------------------------------------------------------------------------#
