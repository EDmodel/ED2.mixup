 #!/bin/sh

here=`pwd`
there=${here}
lonlat=${here}'/joborder.txt'

#----- Determine the number of polygons to run. -------------------------------------------#
let npolys=`wc -l ${lonlat} | awk '{print $1 }'`-3
echo 'Number of polygons: '${npolys}'...'

#------------------------------------------------------------------------------------------#
#     Loop over all polygons.                                                              #
#------------------------------------------------------------------------------------------#
ff=0
if [ -s ${here}/nc_files ]
then
    echo 'nc_files already exists, make sure you are not going to overwrite nc files'
    echo 'I am giving you a few seconds to kill this script in case you change your mind...'
    repfun=7
    while [ ${repfun} -gt 1 ]
    do
       let repfun=${repfun}-1
       echo '  - Script will start in '${repfun}' seconds...'
       sleep 1
    done
else
    mkdir ${here}/nc_files
fi

while [ ${ff} -lt ${npolys} ]
do
   let ff=${ff}+1
   let line=${ff}+3

   #---------------------------------------------------------------------------------------#
   #      Read the ffth line of the polygon list.  There must be smarter ways of doing     #
   # this, but this works.  Here we obtain the polygon name, and its longitude and         #
   # latitude.                                                                             #
   #---------------------------------------------------------------------------------------#
   oi=`head -${line} ${lonlat} | tail -1`
   polyname=`echo ${oi}     | awk '{print $1 }'`
   polyiata=`echo ${oi}     | awk '{print $2 }'`
   polylon=`echo ${oi}      | awk '{print $3 }'`
   polylat=`echo ${oi}      | awk '{print $4 }'`
   yeara=`echo ${oi}        | awk '{print $5 }'`
   montha=`echo ${oi}       | awk '{print $6 }'`
   datea=`echo ${oi}        | awk '{print $7 }'`
   timea=`echo ${oi}        | awk '{print $8 }'`
   yearz=`echo ${oi}        | awk '{print $9 }'`
   monthz=`echo ${oi}       | awk '{print $10}'`
   datez=`echo ${oi}        | awk '{print $11}'`
   timez=`echo ${oi}        | awk '{print $12}'`
   polyisoil=`echo ${oi}    | awk '{print $13}'`
   polyntext=`echo ${oi}    | awk '{print $14}'`
   polysand=`echo ${oi}     | awk '{print $15}'`
   polyclay=`echo ${oi}     | awk '{print $16}'`
   polydepth=`echo ${oi}    | awk '{print $17}'`
   polysoilbc=`echo ${oi}   | awk '{print $18}'`
   polysldrain=`echo ${oi}  | awk '{print $19}'`
   polycol=`echo ${oi}      | awk '{print $20}'`
   slzres=`echo ${oi}       | awk '{print $21}'`
   queue=`echo ${oi}        | awk '{print $22}'`
   metdriver=`echo ${oi}    | awk '{print $23}'`
   dtlsm=`echo ${oi}        | awk '{print $24}'`
   vmfactc3=`echo ${oi}     | awk '{print $25}'`
   vmfactc4=`echo ${oi}     | awk '{print $26}'`
   mphototrc3=`echo ${oi}   | awk '{print $27}'`
   mphototec3=`echo ${oi}   | awk '{print $28}'`
   mphotoc4=`echo ${oi}     | awk '{print $29}'`
   bphotoblc3=`echo ${oi}   | awk '{print $30}'`
   bphotonlc3=`echo ${oi}   | awk '{print $31}'`
   bphotoc4=`echo ${oi}     | awk '{print $32}'`
   kwgrass=`echo ${oi}      | awk '{print $33}'`
   kwtree=`echo ${oi}       | awk '{print $34}'`
   gammac3=`echo ${oi}      | awk '{print $35}'`
   gammac4=`echo ${oi}      | awk '{print $36}'`
   d0grass=`echo ${oi}      | awk '{print $37}'`
   d0tree=`echo ${oi}       | awk '{print $38}'`
   alphac3=`echo ${oi}      | awk '{print $39}'`
   alphac4=`echo ${oi}      | awk '{print $40}'`
   klowco2=`echo ${oi}      | awk '{print $41}'`
   rrffact=`echo ${oi}      | awk '{print $42}'`
   growthresp=`echo ${oi}   | awk '{print $43}'`
   lwidthgrass=`echo ${oi}  | awk '{print $44}'`
   lwidthbltree=`echo ${oi} | awk '{print $45}'`
   lwidthnltree=`echo ${oi} | awk '{print $46}'`
   q10c3=`echo ${oi}        | awk '{print $47}'`
   q10c4=`echo ${oi}        | awk '{print $48}'`
   h2olimit=`echo ${oi}     | awk '{print $49}'`
   imortscheme=`echo ${oi}  | awk '{print $50}'`
   ddmortconst=`echo ${oi}  | awk '{print $51}'`
   isfclyrm=`echo ${oi}     | awk '{print $52}'`
   icanturb=`echo ${oi}     | awk '{print $53}'`
   ubmin=`echo ${oi}        | awk '{print $54}'`
   ugbmin=`echo ${oi}       | awk '{print $55}'`
   ustmin=`echo ${oi}       | awk '{print $56}'`
   gamm=`echo ${oi}         | awk '{print $57}'`
   gamh=`echo ${oi}         | awk '{print $58}'`
   tprandtl=`echo ${oi}     | awk '{print $59}'`
   ribmax=`echo ${oi}       | awk '{print $60}'`
   atmco2=`echo ${oi}       | awk '{print $61}'`
   thcrit=`echo ${oi}       | awk '{print $62}'`
   smfire=`echo ${oi}       | awk '{print $63}'`
   ifire=`echo ${oi}        | awk '{print $64}'`
   fireparm=`echo ${oi}     | awk '{print $65}'`
   ipercol=`echo ${oi}      | awk '{print $66}'`
   runoff=`echo ${oi}       | awk '{print $67}'`
   imetrad=`echo ${oi}      | awk '{print $68}'`
   ibranch=`echo ${oi}      | awk '{print $69}'`
   icanrad=`echo ${oi}      | awk '{print $70}'`
   crown=`echo   ${oi}      | awk '{print $71}'`
   ltransvis=`echo ${oi}    | awk '{print $72}'`
   lreflectvis=`echo ${oi}  | awk '{print $73}'`
   ltransnir=`echo ${oi}    | awk '{print $74}'`
   lreflectnir=`echo ${oi}  | awk '{print $75}'`
   orienttree=`echo ${oi}   | awk '{print $76}'`
   orientgrass=`echo ${oi}  | awk '{print $77}'`
   clumptree=`echo ${oi}    | awk '{print $78}'`
   clumpgrass=`echo ${oi}   | awk '{print $79}'`
   ivegtdyn=`echo ${oi}     | awk '{print $80}'`
   igndvap=`echo ${oi}      | awk '{print $81}'`
   iphen=`echo ${oi}        | awk '{print $82}'`
   iallom=`echo ${oi}       | awk '{print $83}'`
   ibigleaf=`echo ${oi}     | awk '{print $84}'`
   irepro=`echo ${oi}       | awk '{print $85}'`
   treefall=`echo ${oi}     | awk '{print $86}'`
   #---------------------------------------------------------------------------------------#



   #----- Find time and minute. -----------------------------------------------------------#
   houra=`echo ${timea}  | awk '{print substr($1,1,2)}'`
   minua=`echo ${timea}  | awk '{print substr($1,3,2)}'`
   hourz=`echo ${timez}  | awk '{print substr($1,1,2)}'`
   minuz=`echo ${timez}  | awk '{print substr($1,3,2)}'`
   #---------------------------------------------------------------------------------------#




   echo 'Order: '${ff}', creating gen_nc file for polygon '${polyname}'...'
   #----- Copy the Template directory to a unique polygon directory. ----------------------#
   cp -f ${here}/Template/gen_netcdf.m ${here}/${polyname}/gen_netcdf.m
   cp -f ${here}/Template/mrun.sh ${here}/${polyname}/mrun.sh
   #---------------------------------------------------------------------------------------#


   #----- Use default year for beginning of the time period. ------------------------------#
   thisyeara=${yeara}
   #---------------------------------------------------------------------------------------#



   #---------------------------------------------------------------------------------------#
   #     Find the last day with full diurnal cycle.                                        #
   #---------------------------------------------------------------------------------------#
   if [ ${hourz} -lt 23 ]
   then
      #------------------------------------------------------------------------------------#
      #     Last day is not complete, use previous day instead.                            #
      #------------------------------------------------------------------------------------#
      let thisdatez=${datez}-1
      if [ ${thisdatez} -eq 0 ]
      then
         #----- Last time is on the first day of the month, go back one month. ------------#
         let thismonthz=${monthz}-1
         if [ ${thismonthz} -eq 0 ]
         then
            #----- Last time is in January, go back to December on the previous year. -----#
            thismonthz=12
            let thisyearz=${yearz}-1
         else
            #----- Last time is not January, keep the same year. --------------------------#
            thisyearz=${yearz}
         fi

         #----- Find the last date with full diurnal cycle. -------------------------------#
         case thismonth in
         1|3|5|7|8|10|12)
            thisdatez=31
            ;;
         4|6|9|11)
            thisdatez=30
            ;;
         2)
            #------ Previous month is February, find out whether it's a leap year. --------#
            let rem400=${thisyear}%400
            let rem100=${thisyear}%100
            let rem4=${thisyear}%4
            
            if [ ${rem400} -eq 0 ] || [ ${rem4} -eq 0 -a ${rem100} -ne 0 ]
            then
               thisdatez=29
            else
               thisdatez=28
            fi
            ;;
         esac
      else
         thismonthz=${monthz}
         thisyearz=${yearz}
      fi
      #------------------------------------------------------------------------------------#
   else
      #------------------------------------------------------------------------------------#
      #     Last day is complete, use the last day as is.                                  #
      #------------------------------------------------------------------------------------#
      thisdatez=${datez}
      thismonthz=${monthz}
      thisyearz=${yearz}
   fi
   #---------------------------------------------------------------------------------------#



   #----- Pad zeroes to the left of date and month if needed be. --------------------------#
   usethismonthz=`printf "%02d" ${thismonthz}`
   usethisdatez=`printf "%02d" ${thisdatez}`

   #---------------------------------------------------------------------------------------#
   #     Change the gen_netcdf file.                                                       #
   #---------------------------------------------------------------------------------------#
   genNC=${here}'/'${polyname}'/gen_netcdf.m'
   sed -i s@paththere@${there}@g         ${genNC}
   sed -i s@myyeara@${thisyeara}@g       ${genNC}
   sed -i s@mymontha@${montha}@g         ${genNC}
   sed -i s@myyearz@${thisyearz}@g       ${genNC}
   sed -i s@mydatez@${usethisdatez}@g    ${genNC}
   sed -i s@mymonthz@${usethismonthz}@g  ${genNC}
   sed -i s@thispoly@${polyname}@g       ${genNC}
   #---------------------------------------------------------------------------------------#


   #---------------------------------------------------------------------------------------#
   #    Prepare the script to run the netCDF
   #---------------------------------------------------------------------------------------#
   mrun=${here}'/'${polyname}'/mrun.sh'
   sed -i s@thisqueue@${queue}@g ${mrun}
   #---------------------------------------------------------------------------------------#
done
