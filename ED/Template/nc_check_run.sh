#!/bin/sh
here=`pwd`
lonlat=${here}'/joborder.txt'

#----- Determine the number of polygons to run. -------------------------------------------#
let npolys=`wc -l ${lonlat} | awk '{print $1 }'`-3
echo 'Number of polygons: '${npolys}'...'


#------------------------------------------------------------------------------------------#
#     Loop over all polygons.                                                              #
#------------------------------------------------------------------------------------------#
ff=0
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
   polycol=`echo ${oi}      | awk '{print $18}'`
   slzres=`echo ${oi}       | awk '{print $19}'`
   queue=`echo ${oi}        | awk '{print $20}'`
   metdriver=`echo ${oi}    | awk '{print $21}'`
   dtlsm=`echo ${oi}        | awk '{print $22}'`
   vmfactc3=`echo ${oi}     | awk '{print $23}'`
   vmfactc4=`echo ${oi}     | awk '{print $24}'`
   mphototrc3=`echo ${oi}   | awk '{print $25}'`
   mphototec3=`echo ${oi}   | awk '{print $26}'`
   mphotoc4=`echo ${oi}     | awk '{print $27}'`
   bphotoblc3=`echo ${oi}   | awk '{print $28}'`
   bphotonlc3=`echo ${oi}   | awk '{print $29}'`
   bphotoc4=`echo ${oi}     | awk '{print $30}'`
   kwgrass=`echo ${oi}      | awk '{print $31}'`
   kwtree=`echo ${oi}       | awk '{print $32}'`
   gammac3=`echo ${oi}      | awk '{print $33}'`
   gammac4=`echo ${oi}      | awk '{print $34}'`
   d0grass=`echo ${oi}      | awk '{print $35}'`
   d0tree=`echo ${oi}       | awk '{print $36}'`
   alphac3=`echo ${oi}      | awk '{print $37}'`
   alphac4=`echo ${oi}      | awk '{print $38}'`
   klowco2=`echo ${oi}      | awk '{print $39}'`
   rrffact=`echo ${oi}      | awk '{print $40}'`
   growthresp=`echo ${oi}   | awk '{print $41}'`
   lwidthgrass=`echo ${oi}  | awk '{print $42}'`
   lwidthbltree=`echo ${oi} | awk '{print $43}'`
   lwidthnltree=`echo ${oi} | awk '{print $44}'`
   q10c3=`echo ${oi}        | awk '{print $45}'`
   q10c4=`echo ${oi}        | awk '{print $46}'`
   h2olimit=`echo ${oi}     | awk '{print $47}'`
   isfclyrm=`echo ${oi}     | awk '{print $48}'`
   icanturb=`echo ${oi}     | awk '{print $49}'`
   ubmin=`echo ${oi}        | awk '{print $50}'`
   ugbmin=`echo ${oi}       | awk '{print $51}'`
   ustmin=`echo ${oi}       | awk '{print $52}'`
   gamm=`echo ${oi}         | awk '{print $53}'`
   gamh=`echo ${oi}         | awk '{print $54}'`
   tprandtl=`echo ${oi}     | awk '{print $55}'`
   ribmax=`echo ${oi}       | awk '{print $56}'`
   atmco2=`echo ${oi}       | awk '{print $57}'`
   thcrit=`echo ${oi}       | awk '{print $58}'`
   smfire=`echo ${oi}       | awk '{print $59}'`
   ifire=`echo ${oi}        | awk '{print $60}'`
   fireparm=`echo ${oi}     | awk '{print $61}'`
   ipercol=`echo ${oi}      | awk '{print $62}'`
   isoilbc=`echo ${oi}      | awk '{print $63}'`
   runoff=`echo ${oi}       | awk '{print $64}'`
   imetrad=`echo ${oi}      | awk '{print $65}'`
   ibranch=`echo ${oi}      | awk '{print $66}'`
   icanrad=`echo ${oi}      | awk '{print $67}'`
   crown=`echo   ${oi}      | awk '{print $68}'`
   ltransvis=`echo ${oi}    | awk '{print $69}'`
   lreflectvis=`echo ${oi}  | awk '{print $70}'`
   ltransnir=`echo ${oi}    | awk '{print $71}'`
   lreflectnir=`echo ${oi}  | awk '{print $72}'`
   orienttree=`echo ${oi}   | awk '{print $73}'`
   orientgrass=`echo ${oi}  | awk '{print $74}'`
   clumptree=`echo ${oi}    | awk '{print $75}'`
   clumpgrass=`echo ${oi}   | awk '{print $76}'`
   ivegtdyn=`echo ${oi}     | awk '{print $77}'`
   igndvap=`echo ${oi}      | awk '{print $78}'`
   iphen=`echo ${oi}        | awk '{print $79}'`
   iallom=`echo ${oi}       | awk '{print $80}'`
   ibigleaf=`echo ${oi}     | awk '{print $81}'`
   irepro=`echo ${oi}       | awk '{print $82}'`
   #---------------------------------------------------------------------------------------#


   ncname=${polyname}'.out'
   ncerror=${polyname}'_err.out'
    
   if [ -s ${here}/${polyname}/${ncname}  ]
   then
      if [ -s ${here}/${polyname}/${ncerror} ]
      then
         ncDONE=`grep "Successfully completed" ${here}/${polyname}/${ncerror} | wc -l`
         if [ ${ncDONE} -gt 0 ]
         then
            echo ':-D ncfile for '${polyname}' has finished ...'
         else
            echo ':-( looks like ncfile '${polyname}' has crashed ... <============='
         fi
      else
         WAITING=`grep "Waiting for file..." ${here}/${polyname}/${ncname} | tail -n1`
         wcheck=`grep "Waiting for file..." ${here}/${polyname}/${ncname} | tail -n1 | wc -l`
         simulating=`grep "file /" ${here}/${polyname}/${ncname} | tail -n1`
         scheck=`grep "file /" ${here}/${polyname}/${ncname}  | tail -n1 | wc -l`
         if [ ${wcheck} -gt 0 ]
         then 
            if [ ${scheck} -gt 0 ]
            then
                echo ':-) '${polyname}' has loaded '${simulating:(-47):23}' and is waiting. '${WAITING: -13}'  ...'
            else
                echo ':-| '${polyname}' has waited '${WAITING: -6}'  ...'
            fi
         elif [ ${scheck} -gt 0 ]
         then
            echo ':-) '${polyname}' is running. '${simulating: -47}'...'
         else
            echo ':-| '${polyname}' is pending ...'
         fi
      fi
   fi

done

