#!/bin/tcsh
# mother script to execute yearly based data collection for ORFEUS
#
#
# Hongyu@ASU Oct 2017




set PWD = `pwd`
set INFILE = $PWD/INFILE
set YEAR = `cat $INFILE|grep YEAR_LIST |awk '{$1="";print $0}'`



set PWD = `pwd`
set LOG = $PWD/LOG
set SUPDIR = $PWD/support
set DATADIR = $PWD/DATADIR








mkdir -p $DATADIR
mkdir -p $LOG

foreach year (`echo $YEAR`)
	echo "--> Work on year $year"
	set INPUT = ($year $PWD $SUPDIR $DATADIR)
	csh $PWD/c01.get_orgeus.sh $INPUT > & $LOG/logfile.${year} &
	sleep 1s
end 
