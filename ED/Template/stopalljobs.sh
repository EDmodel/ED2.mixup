#!/bin/sh
here=`pwd`
lonlat=${here}'/joborder.txt'
desc=`basename ${here}`

#----- Determine the number of polygons to run. -------------------------------------------#
let npolys=`wc -l ${lonlat} | awk '{print $1 }'`-3

echo 'Are you sure that you want to stop all jobs? [y/N]'
read proceed

if [ ${proceed} != 'y' -a ${proceed} != 'Y' ]
then
   exit
fi

echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
echo ' '
echo '     Look, this will really stop ALL your jobs... Are you sure? [y/N]'
echo ' '
echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
read proceed

if [ ${proceed} != 'y' -a ${proceed} != 'Y' ]
then
   exit
fi

echo 'Okay then, but if you regret later do not say that I did not warn you...'
echo 'I am giving you a few seconds to kill this script in case you change your mind...'
delfun=11
while [ ${delfun} -gt 1 ]
do
   delfun=`expr ${delfun} - 1`
   echo '  - Job stopping will begin in '${delfun}' seconds...'
   sleep 1
done


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
   polyname=`echo ${oi}    | awk '{print $1 }'`
   polyiata=`echo ${oi}    | awk '{print $2 }'`
   polylon=`echo ${oi}     | awk '{print $3 }'`
   polylat=`echo ${oi}     | awk '{print $4 }'`
   yeara=`echo ${oi}       | awk '{print $5 }'`
   montha=`echo ${oi}      | awk '{print $6 }'`
   datea=`echo ${oi}       | awk '{print $7 }'`
   timea=`echo ${oi}       | awk '{print $8 }'`
   yearz=`echo ${oi}       | awk '{print $9 }'`
   monthz=`echo ${oi}      | awk '{print $10}'`
   datez=`echo ${oi}       | awk '{print $11}'`
   timez=`echo ${oi}       | awk '{print $12}'`
   polyisoil=`echo ${oi}   | awk '{print $13}'`
   polyntext=`echo ${oi}   | awk '{print $14}'`
   polysand=`echo ${oi}    | awk '{print $15}'`
   polyclay=`echo ${oi}    | awk '{print $16}'`
   polydepth=`echo ${oi}   | awk '{print $17}'`
   queue=`echo ${oi}       | awk '{print $18}'`
   metdriver=`echo ${oi}   | awk '{print $19}'`
   dtlsm=`echo ${oi}       | awk '{print $20}'`
   vmfact=`echo ${oi}      | awk '{print $21}'`
   mfact=`echo ${oi}       | awk '{print $22}'`
   kfact=`echo ${oi}       | awk '{print $23}'`
   gamfact=`echo ${oi}     | awk '{print $24}'`
   d0fact=`echo ${oi}      | awk '{print $25}'`
   alphafact=`echo ${oi}   | awk '{print $26}'`
   rrffact=`echo ${oi}     | awk '{print $27}'`
   growthresp=`echo ${oi}  | awk '{print $28}'`
   icanturb=`echo ${oi}    | awk '{print $29}'`
   atmco2=`echo ${oi}      | awk '{print $30}'`
   thcrit=`echo ${oi}      | awk '{print $31}'`
   smfire=`echo ${oi}      | awk '{print $32}'`
   isoilbc=`echo ${oi}     | awk '{print $33}'`
   imetrad=`echo ${oi}     | awk '{print $34}'`
   ibranch=`echo ${oi}     | awk '{print $35}'`
   icanrad=`echo ${oi}     | awk '{print $36}'`
   ltransvis=`echo ${oi}   | awk '{print $37}'`
   lreflectvis=`echo ${oi} | awk '{print $38}'`
   ltransnir=`echo ${oi}   | awk '{print $39}'`
   lreflectnir=`echo ${oi} | awk '{print $40}'`
   orienttree=`echo ${oi}  | awk '{print $41}'`
   orientgrass=`echo ${oi} | awk '{print $42}'`
   clumptree=`echo ${oi}   | awk '{print $43}'`
   clumpgrass=`echo ${oi}  | awk '{print $44}'`
   ivegtdyn=`echo ${oi}    | awk '{print $45}'`
   #---------------------------------------------------------------------------------------#

   bkill -J ${desc}-${polyname} -q ${queue}
done
#------------------------------------------------------------------------------------------#



