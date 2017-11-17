#!/bin/tcsh
# mother script to execute yearly based data collection for ORFEUS
#
#
# Hongyu@ASU Oct 2017

set PWD = `pwd`
set INFILE = $PWD/INFILE
set YEAR = 2013
set PROCESS = 10

set LOG = $PWD/LOG
set SUPDIR = $PWD/support
set DATADIR = $PWD/DATADIR
mkdir -p $DATADIR
mkdir -p $LOG
echo "--> Work on $YEAR "


set ID = orfeus_on_EQ1_${YEAR}
mkdir -p $PWD/DATADIR/$ID
cd $PWD/DATADIR/$ID

set BIG_EQ_LIST = $PWD/DATADIR/$ID/list.${ID}
get_EQLIST_all |awk -v sss=$YEAR '$5==sss&&$10==1 {print $14}' >! $BIG_EQ_LIST

cd $PWD/DATADIR/$ID
divide_file list.${ID} $PROCESS



set current_process = 0
while ($current_process < $PROCESS)
	set EQ_LIST = $PWD/DATADIR/${ID}/.list.${ID}.${current_process}
	set INPUT = ($ID $PWD $SUPDIR $DATADIR $EQ_LIST)
	csh $PWD/c02.get_orfeus_based_on_eq_list.sh $INPUT > & $LOG/logfile.${ID}.${current_process} &

sleep 1s
@ current_process ++
end 
