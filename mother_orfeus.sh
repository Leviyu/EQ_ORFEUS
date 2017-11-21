#!/bin/tcsh
# mother script to execute yearly based data collection for ORFEUS
#
#
# Hongyu@ASU Oct 2017

set PWD = `pwd`
set ID = $1
set INPUT_EQ_LIST = $2
set PROCESS = $3

set LOG = $PWD/LOG
set SUPDIR = $PWD/support
set DATADIR = $PWD/DATADIR
mkdir -p $DATADIR
mkdir -p $LOG


mkdir -p $PWD/DATADIR/$ID

set BIG_EQ_LIST = $PWD/DATADIR/$ID/EQ_LIST
cp $INPUT_EQ_LIST $BIG_EQ_LIST
cd $PWD/DATADIR/$ID
divide_file EQ_LIST $PROCESS


set current_process = 0
while ($current_process < $PROCESS)
	set EQ_LIST = $PWD/DATADIR/${ID}/.EQ_LIST.${current_process}
	set INPUT = ($ID $PWD $SUPDIR $DATADIR $EQ_LIST)
	set logfile = $DATADIR/$ID/logfile.${ID}.${current_process}
	csh $PWD/c02.get_orfeus_based_on_eq_list.sh $INPUT > & $logfile &
sleep 1s
@ current_process ++
end 
