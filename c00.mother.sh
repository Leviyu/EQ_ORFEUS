#!/bin/tcsh
# mother script to execute yearly based data collection for ORFEUS
#
#
# Hongyu@ASU Oct 2017


set YEAR = (2015 )






set PWD = `pwd`
set LOG = $PWD/LOG
set SUPDIR = $PWD/support
set DATADIR = $PWD/DATADIR








mkdir -p $DATADIR
mkdir -p $LOG

foreach year (`echo $YEAR`)
	set INPUT = ($year $PWD $SUPDIR $DATADIR)
	csh $PWD/c01.get_orgeus.sh $INPUT > & $LOG/logfile.${year} &
end 
