#!/bin/sh
#$ -pe omp 2
#$ -l h_rt=144:00:00
#$ -N QED2
#$ -V
export OMPI_MCA_btl=tcp,sm,self
cd /usr2/postdoc/apourmok/Github.ED/ED2/ED/run
./ed_2.1-opt
wait
