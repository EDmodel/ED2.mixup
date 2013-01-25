#==========================================================================================#
#==========================================================================================#
#    This function that defines the size of the figure to be plotted in case of maps.      #
# In case the plot is a map, it correct sizes so the map doesn't look distorted.           #
#------------------------------------------------------------------------------------------#
plotsize = function( proje                 #  Map projection? [T|F]
                   , limlon    = NULL      #  Longitude range, if proje = TRUE
                   , limlat    = NULL      #  Latitude range, if proje = TRUE
                   , deg       = TRUE      #  Are longitude and latitude in degrees?
                   , stdheight = NULL      #  Standard height
                   , stdwidth  = NULL      #  Standard 
                   , extendfc  = FALSE     #  Extend width for filled.contour [T|F]
                   , paper     = "letter"  #  Paper size (ignored if stdXXX aren't NULL)
                   ){


   #---------------------------------------------------------------------------------------#
   #     Check whether projection is TRUE or false.  In case it is TRUE, limlon and limlat #
   # must be given and must be a vector with dimension 2 (longitude and latitude ranges).  #
   #---------------------------------------------------------------------------------------#
   if (proje){
      if (is.null(limlon) && is.null(limlat)){
         stop("Variables limlon and limlat must be defined if proje is TRUE!")
      }else if(length(limlon) != 2 && length(limlat) !=2){
         stop("Variables limlon and limlat must be vectors of length 2 if proje is TRUE!")
      }#end if (is.null(limlon) && is.null(limlat))
      #------------------------------------------------------------------------------------#
   }#end if (proje)
   #---------------------------------------------------------------------------------------#


   #---------------------------------------------------------------------------------------#
   #      Check whether stdheight and stdwidth are both available or both missing.  It is  #
   # not allowed to provide only one of them.  In case they are fine and they are          #
   # provided, override paper and make it "special".  In case they are both NULL, make the #
   # paper name lower case (so it becomes case insentitive).                               #
   #---------------------------------------------------------------------------------------#
   if (is.null(stdheight) != is.null(stdwidth)){
      cat(" Stdheight is NULL: ",is.null(stdheight),"\n")
      cat(" Stdwidth  is NULL: ",is.null(stdwidth ),"\n")
      stop(" Either set both stdheight and stdwidth to NULL or provide both...")
   }else if (! is.null(stdheight)){
      paper = "special"
   }else if (!is.null(paper)){
      paper = tolower(paper)
   }#end if
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #       Find the standard width and height depending on the paper.                      #
   #---------------------------------------------------------------------------------------#
   if (paper == "special") { 
      stdratio = max(c(stdwidth,stdheight))/min(c(stdwidth,stdheight))
   }else if (paper == "letter"){
      stdwidth  =  0.8 * 11.0
      stdheight =  0.8 *  8.5
      stdratio  = 11.0 /  8.5
   }else if (paper == "a4"){
      stdwidth  =  0.8 * 29.7 / 2.54
      stdheight =  0.8 * 21.0 / 2.54
      stdratio  = 29.7 / 21.0
   }else if (paper == "legal"){
      stdwidth  =  0.8 * 14.0
      stdheight =  0.8 *  8.5
      stdratio  = 14.0 /  8.5
   }else if (paper == "executive"){
      stdwidth  =  0.8  * 10.25
      stdheight =  0.8  *  7.25
      stdratio  = 10.25 /  7.25
   }else{
      warning(paste("Unknown paper size (",paper,").  Using letter instead.",sep=""))
      stdwidth  =  0.8 * 11.0
      stdheight =  0.8 *  8.5
      stdratio  = 11.0 /  8.5
   }#end if 
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #    Correct the width and height in case this is a map.                                #
   #---------------------------------------------------------------------------------------#
   if (proje){
      #----- Extend the width in case this will be used for filled.contour. ---------------#
      if (extendfc){
         width.fac = 1.0 + 1/6
      }else{
         width.fac = 1.0
      }#end if extendfc
      #------------------------------------------------------------------------------------#


      #----- Find the actual ratio using the longitude and latitude. ----------------------#
      interx = max(limlon) - min(limlon)
      intery = max(limlat) - min(limlat)
      if (deg){
         ratio = interx * cos(mean(limlat) * pi / 180.) / intery
      }else{
         ratio = interx * cos(mean(limlat)) / intery
      }#end if (deg)
      #------------------------------------------------------------------------------------#



      #------------------------------------------------------------------------------------#
      #     Fix the width or height to account for the sought ratio.                       #
      #------------------------------------------------------------------------------------#
      if (ratio >= stdratio){ 
         height = stdwidth / ratio
         width  = width.fac * stdwidth
      }else{
         height = stdheight
         width  = height * ratio * width.fac
      }#end if(actualratio >= stdratio)
      #------------------------------------------------------------------------------------#

   }else{

      #----- Not a map projection.  Use the standard size. --------------------------------#
      height = stdheight
      width  = stdwidth
      ratio  = stdratio
      #------------------------------------------------------------------------------------#

   }#end if (proje)
   #---------------------------------------------------------------------------------------#


   #---------------------------------------------------------------------------------------#
   #     Append everything to a list.                                                      #
   #---------------------------------------------------------------------------------------#
   ans = list(height=height,width=width,ratio=ratio,paper="special")
   return(ans)
   #---------------------------------------------------------------------------------------#
}#end function
#==========================================================================================#
#==========================================================================================#
