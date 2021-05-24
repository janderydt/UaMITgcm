#!/bin/bash --login
#PBS -l select=1
#PBS -l walltime=02:00:00
#PBS -j oe
#PBS -m n
#PBS -r n
####################################################################
# Run Ua.
# Must pass the arguments
# -v UA_DIR=<path to Ua executable directory>,ACC=<Archer budget>
# and
# -A <Archer budget>
####################################################################

# USER VARIABLE
# Path to Matlab Compiler Runtime installation
MCR=$WORK/MCR_2017a/v92/

# Make sure MCR cache (as defined in Ua_MCR.sh) exists
# If you want the cache in a different location, modify it here AND in ua_run/Ua_MCR.sh
if [ ! -d $WORK/mcr_cache ]; then
  mkdir $WORK/mcr_cache
fi

cd $PBS_O_WORKDIR
echo 'Ua starts '`date` >> jobs.log

module swap PrgEnv-intel PrgEnv-gnu
cd $UA_DIR

aprun -N 1 -n 1 ./Ua_MCR.sh $MCR 1>>matlab_std.out 2>>matlab_err.out
OUT=$?

cd $PBS_O_WORKDIR
if [ $OUT == 0 ]; then
    echo 'Ua ends '`date` >> jobs.log
    touch ua_finished
    if [ -e mitgcm_finished ] ; then
        # Ua was the last one to finish
	qsub -A $ACC run_coupler.sh
    fi
    exit 0
else
    echo 'Error in Ua '`date` >> jobs.log
    exit 1
fi