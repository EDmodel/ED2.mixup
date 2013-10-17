#----- Some dimensions based on ED-2.2 default. -------------------------------------------#
npft       <<- 17 # Number of plant functional types
nlu        <<-  3 # Number of land use types.
nstyp      <<- 17 # Number of default soil types
#------------------------------------------------------------------------------------------#



#----- Radiation thresholds. --------------------------------------------------------------#
cosz.min      <<- 0.03 # cos(89*pi/180) # Minimum cosine of zenith angle
cosz.highsun  <<- cos(84*pi/180)        # Zenith angle to not be called sunrise or sunset
cosz.twilight <<- cos(96*pi/180)        # Cosine of the end of civil twilight
fvis.beam.def <<- 0.43
fnir.beam.def <<- 1.0 - fvis.beam.def
fvis.diff.def <<- 0.52
fnir.diff.def <<- 1.0 - fvis.diff.def
phap.min      <<- 25                    # Minimum incoming radiation to be considered 
                                        # daytime
#------------------------------------------------------------------------------------------#


#----- Minimum R2 that we consider meaningful. --------------------------------------------#
r2.min        <<- 0.36
#----- Typical p-value below which we reject the NULL hypothesis. -------------------------#
pval.max      <<- 0.05
#----- p-value below which we reject the NULL hypothesis for u* filters. ------------------#
pval.ustar    <<- 0.05
#------------------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------#
#     Tolerance for root-finding methods.                                                  #
#------------------------------------------------------------------------------------------#
toler  <<- 1.e-6  # Tolerance for the root-finder algorithms
maxfpo <<- 60     # Maximum number of Regula-Falsi iterations
maxit  <<- 150    # Maximum number of iterations in general
#------------------------------------------------------------------------------------------#




#------ Define the colours and labels for IGBP land use maps. -----------------------------#
igbp.col <<- c( H2O = RGB(   0,  20,  82)
              , ENF = RGB(   0, 100, 164)
              , EBF = RGB(   0,  63,   0)
              , DNF = RGB(  85, 192, 255)
              , DBF = RGB(  97, 255,  96)
              , MXF = RGB(   0, 156,  76)
              , CSH = RGB( 255, 105,   0)
              , OSH = RGB( 207, 151, 114)
              , WSV = RGB(  72, 144,   0)
              , SAV = RGB( 150, 255,  40)
              , GSL = RGB( 233, 198,   9)
              , PWL = RGB(  69,  35, 232)
              , CRL = RGB( 166, 131,   0)
              , URB = RGB(  96,  96,  96)
              , CNV = RGB( 115, 158,  80)
              , ICE = RGB(   0, 222, 255)
              , BRN = RGB( 144,   3,   2)
              , UND = RGB( 222, 222, 222)
              )#end igbp.col
igbp.leg <<- names(igbp.col)
igbp.val <<- seq_along(igbp.col)-1
#------------------------------------------------------------------------------------------#




#----- Define some default legend colours and names. --------------------------------------#
lunames   <<- c("Agricultural","Secondary","Primary","Total")
lucols    <<- c("goldenrod","chartreuse","darkgreen",all.colour)

distnames <<- c("Agr->Agr" ,"2nd->Agr" ,"Prim->Agr"
               ,"Agr->2nd" ,"2nd->2nd" ,"Prim->2nd"
               ,"Agr->Prim","2nd->Prim","Prim->Prim")
distcols  <<- c("gold","darkorange2","firebrick"
               ,"lightskyblue","turquoise","steelblue"
               ,"palegreen","chartreuse","forestgreen")
#------------------------------------------------------------------------------------------#


#----- Growth respiration factor (to estimate when the actual variable is not there). -----#
growth.resp.fac <<- c(rep(0.333,times=5),rep(0.4503,times=3),rep(0,times=3)
                     ,rep(0.333,times=4))
#------------------------------------------------------------------------------------------#



#----- fswh is the FSW that plants experience and they are happy (wilting point = 0). -----#
fswh <<- 0.99
#------------------------------------------------------------------------------------------#


#----- Years for which we have eddy flux tower. -------------------------------------------#
eft.year <<- c(     1998,     1999,     2000,     2001,     2002,     2003,     2004
              ,     2005,     2006,     2007,     2008,     2009,     2010,     2011
              ,     2012,     2013)
eft.pch  <<- c(        0,        1,        6,        3,        4,        5,       13
              ,       15,       16,       17,       18,        9,        8,        7
              ,       14,        2)
eft.col  <<- c("#7D6E93","#B49ED2","#39025D","#520485","#042E88","#0742C3","#00480E"
              ,"#006715","#31B223","#46FF32","#AB8C3D","#F5C858","#B23C00","#FF5700"
              ,"#70000E","#A00014")
#------------------------------------------------------------------------------------------#



#----- Standard colours and names for soil classes. ---------------------------------------#
stext.cols  <<- c("gold","chartreuse","limegreen","darkgreen","purple3"
                 ,"deepskyblue","aquamarine","slateblue2","darkorange3","sienna"
                 ,"firebrick","grey61","grey29","orchid","olivedrab","goldenrod"
                 ,"steelblue")
stext.names <<- c("Sand","Loamy Sand","Sandy loam","Silt loam","Loam","Sandy clay loam"
                 ,"Silty clay loam","Clayey loam","Sandy clay","Silty clay","Clay","Peat"
                 ,"Bedrock","Silt","Heavy clay","Clayey sand","Clayey silt")
stext.acron <<- c("Sa","LoSa","SaLo","SiLo","Lo","SaClLo","SiClLo","ClLo"
                 ,"SaCl","SiCl","Cl","Pe","Br","Si","HCl","ClSa","ClSi")
#------------------------------------------------------------------------------------------#




#==========================================================================================#
#==========================================================================================#
#     Patch information for POV-Ray.                                                       #
#------------------------------------------------------------------------------------------#
pov.dbh.min    <<-    5    # Minimum DBH to be plotted
pov.patch.xmax <<-   16    # Size of each sub-plot in the x direction [m]
pov.patch.ymax <<-   16    # Size of each sub-plot in the y direction [m]
pov.nx.patch   <<-   25    # Number of sub-plots in each x transect
pov.ny.patch   <<-   25    # Number of sub-plots in each y transect
pov.nxy.patch  <<- pov.nx.patch  * pov.ny.patch
pov.total.area <<- pov.nxy.patch * pov.patch.xmax * pov.patch.ymax
pov.x0         <<- rep( x     = -200 + seq(from=0,to=pov.nx.patch-1) * pov.patch.xmax
                      , times = pov.ny.patch
                      )#end rep
pov.y0         <<- rep( x     = -200 + seq(from=0,to=pov.ny.patch-1) * pov.patch.ymax
                      , each  = pov.nx.patch
                      )#end rep
#------------------------------------------------------------------------------------------#




#==========================================================================================#
#==========================================================================================#
#     Census-related thresholds.  If the script has different values, ignore these and     #
# use whatever the main script says.                                                       #
#------------------------------------------------------------------------------------------#
#----- Minimum height to be considered for "ground-based observations". -------------------#
if ( "census.height.min" %in% ls()){
   census.height.min <<- census.height.min
}else{
   census.height.min <<- 1.5 
}#end if
#----- Minimum DBH to be considered for "ground-based observations". ----------------------#
if ( "census.dbh.min" %in% ls()){
   census.dbh.min <<- census.dbh.min
}else{
   census.dbh.min <<- 10.
}#end if
#----- Minimum DBH to be considered for "ground-based observations". ----------------------#
if ( "recruit.dbh.min" %in% ls()){
   recruit.dbh.min <<- recruit.dbh.min
}else{
   recruit.dbh.min <<- 0.16
}#end if
#------------------------------------------------------------------------------------------#


#==========================================================================================#
#==========================================================================================#
#     Define which DBH classes to use based on the DBH flag.                               #
#------------------------------------------------------------------------------------------#
if ("idbh.type" %in% ls()){
   idbh.type <<- idbh.type
}else{
   idbh.type <<- 1   
}#end if
if (idbh.type == 1){
   ndbh       <<- 11
   ddbh       <<- 10
   classdbh   <<- seq(from=0,to=(ndbh-1)*ddbh,by=ddbh)
   breakdbh   <<- c(-Inf,classdbh[-1],Inf)
   dbhlabel   <<- "11_szclss"
   dbhkeys    <<- paste(classdbh,"-",c(classdbh[-1],Inf),sep="")
   dbhnames   <<- paste( c("<",paste(classdbh[-c(1,ndbh)],"-",sep=""),">")
                       , c(classdbh[-1],classdbh[ndbh]),"cm"
                       , sep=""
                       )#end paste
   dbhcols    <<- c(         "purple3",   "mediumpurple1",      "royalblue4"
                   ,      "steelblue3",     "deepskyblue",         "#004E00"
                   ,     "chartreuse3",      "olivedrab3", "lightgoldenrod3"
                   ,         "yellow3",     "darkorange1",       "firebrick"
                   ,        all.colour
                   )#end c

}else if (idbh.type == 2){
   ndbh       <<-  5
   classdbh   <<- c(0,10,20,35,55)
   breakdbh   <<- c(-Inf,classdbh[-1],Inf)
   dbhlabel   <<- "05_szclss"
   dbhkeys    <<- paste(classdbh,"-",c(classdbh[-1],Inf),sep="")
   dbhnames   <<- paste( c("<",paste(classdbh[-c(1,ndbh)],"-",sep=""),">")
                       , c(classdbh[-1],classdbh[ndbh]),"cm"
                       , sep=""
                       )#end paste
   dbhcols    <<- c(      "royalblue3",     "chartreuse3" ,         "yellow3"
                   ,     "darkorange1",       "firebrick" ,        all.colour
                   )#end c
}else if (idbh.type == 3){
   ndbh       <<-  4
   classdbh   <<- c(0,10,35,55)
   dbhlabel   <<- "04_szclss"
   breakdbh   <<- c(-Inf,classdbh[-1],Inf)
   dbhkeys    <<- paste(classdbh,"-",c(classdbh[-1],Inf),sep="")
   dbhnames   <<- paste( c("<",paste(classdbh[-c(1,ndbh)],"-",sep=""),">")
                       , c(classdbh[-1],classdbh[ndbh]),"cm"
                       , sep=""
                       )#end paste
   dbhcols    <<- c(      "royalblue3",     "chartreuse3"
                   ,         "yellow3",     "darkorange1",         all.colour
                   )#end c
}else if (idbh.type == 4){
   ndbh       <<-  6
   classdbh   <<- c(0,2,10,20,45,70)
   breakdbh   <<- c(-Inf,classdbh[-1],Inf)
   dbhlabel   <<- "06_szclss"
   dbhkeys    <<- paste(classdbh,"-",c(classdbh[-1],Inf),sep="")
   dbhnames   <<- paste( c("<",paste(classdbh[-c(1,ndbh)],"-",sep=""),">")
                       , c(classdbh[-1],classdbh[ndbh]),"cm"
                       , sep=""
                       )#end paste
   dbhcols    <<- c(         "purple3",       "royalblue3",     "chartreuse3"
                   ,         "yellow3",      "darkorange1",       "firebrick"
                   ,        all.colour
                   )#end c
}else{
   cat(" In globdims.r:","\n")
   cat(" IDBH.TYPE = ",idbh.type,"\n")
   stop(" Invalid IDBH.TYPE, it must be between 1 and 5 (feel free to add more options.")
}#end if
#==========================================================================================#
#==========================================================================================#





#==========================================================================================#
#==========================================================================================#
#     Define which height classes to use based on the DBH flag.                            #
#------------------------------------------------------------------------------------------#
if ("ihgt.type" %in% ls()){
   ihgt.type <<- ihgt.type
}else{
   ihgt.type <<- 1   
}#end if
if (ihgt.type == 1){
   nhgt       <<- 8
   classhgt   <<- c(0,5,10,15,20,25,30,35)-0.001
   roundhgt   <<- round(classhgt,0)
   breakhgt   <<- c(-Inf,classhgt[-1],Inf)
   hgtlabel   <<- "08_htclss"
   hgtkeys    <<- paste(classhgt,"-",c(roundhgt[-1],Inf),sep="")
   hgtnames   <<- paste( c("<",paste(roundhgt[-c(1,nhgt)],"-",sep=""),">")
                       , c(roundhgt[-1],roundhgt[nhgt]),"m"
                       , sep=""
                       )#end paste
   hgtcols    <<- c(      "slateblue4",      "steelblue3",     "deepskyblue"
                   ,         "#004E00",     "chartreuse3", "lightgoldenrod3"
                   ,     "darkorange1",       "firebrick",        all.colour
                   )#end c
}else if (ihgt.type == 2){
   nhgt       <<-  13
   classhgt   <<- c(0,1,4,7,10,13,16,19,22,25,28,31,34)
   hgtlabel   <<- "13_szclss"
   breakhgt   <<- c(-Inf,classhgt[-1],Inf)
   hgtkeys    <<- paste(classhgt,"-",c(classhgt[-1],Inf),sep="")
   hgtnames   <<- paste( c("<",paste(classhgt[-c(1,nhgt)],"-",sep=""),">")
                       , c(classhgt[-1],classhgt[nhgt]),"cm"
                       , sep=""
                       )#end paste
   hgtcols    <<- c(         "purple3",   "mediumpurple1",      "royalblue4"
                   ,      "steelblue3",     "deepskyblue",         "#004E00"
                   ,     "chartreuse3",      "olivedrab3", "lightgoldenrod3"
                   ,         "yellow3",     "darkorange1",            "red3"
                   ,      "firebrick4",        all.colour
                   )#end c
}else{
   cat(" In globdims.r:","\n")
   cat(" IHGT.TYPE = ",ihgt.type,"\n")
   stop(" Invalid IHGT.TYPE, it must be between 1 and 2 (feel free to add more options.")
}#end if
#==========================================================================================#
#==========================================================================================#





#==========================================================================================#
#==========================================================================================#
#     Define which height classes to use based on the DBH flag.                            #
#------------------------------------------------------------------------------------------#
if ("isld.type" %in% ls()){
   isld.type <<- isld.type
}else{
   isld.type <<- 1
}#end if
if (isld.type == 1){
   nsld       <<- 12
   belowsld   <<- c(-6.0,-5.5,-5.0,-4.5,-4.0,-3.5,-3.0,-2.5,-2.0,-1.5,-1.0,-0.5)
   abovesld   <<- c(belowsld[-1],0)
   thicksld  <<- diff(c(belowsld,0))
   roundsld   <<- round(belowsld,2)
   breaksld   <<- c(-Inf,belowsld[-1],Inf)
   sldlabel   <<- "cc_sdclss"
   sldkeys    <<- paste(roundsld,"-",c(roundsld[-1],0),sep="")
   sldnames   <<- paste( c("<",paste(roundsld[-c(1,nsld)],"-",sep=""),">")
                       , c(roundsld[-1],roundsld[nhgt]),"m"
                       , sep=""
                       )#end paste
   sldcols    <<- c(         "purple3",   "mediumpurple1",      "royalblue4"
                   ,      "steelblue3",     "deepskyblue",         "#004E00"
                   ,     "chartreuse3",      "olivedrab3", "lightgoldenrod3"
                   ,         "yellow3",     "darkorange1",            "red3"
                   ,      "firebrick4",        all.colour
                   )#end c
}else{
   cat(" In globdims.r:","\n")
   cat(" ISLD.TYPE = ",isld.type,"\n")
   stop(" Invalid ISLD.TYPE, it must be C or H (feel free to add more options.")
}#end if
#==========================================================================================#
#==========================================================================================#





#==========================================================================================#
#==========================================================================================#
#     Define default weighting factor for carbon balance.                                  #
#------------------------------------------------------------------------------------------#
if ("klight" %in% ls()){
   klight <<- klight
}else{
   klight <<- 0.8
}#end if 
#==========================================================================================#
#==========================================================================================#
