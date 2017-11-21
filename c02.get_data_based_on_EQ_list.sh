#!/bin/tcsh
# daughter scrip to execute collectiong process for each year
#



set ID = $1
set PWD = $2
set SUPDIR = $3
set DATADIR = $4
set eq_list = $5

set WORKDIR = $DATADIR/${ID}
set network_list = $SUPDIR/ORFEUS_NETWORK
set INFILE = $PWD/INFILE
set EVENTS = $SUPDIR/EVENTS
mkdir -p $WORKDIR

cd $WORKDIR

set depth_limit = `cat $INFILE|grep Event_Depth|awk '{print $2}'`
set minutes_len = `cat $INFILE|grep Time_Series_Length|awk '{print $2}'`
set rdseed_file = `cat $INFILE|grep rdseed_absolute_path|awk '{print $2}'`


foreach EQ (`cat $eq_list`)
	echo "---> Collecting $EQ"
	mkdir -p $WORKDIR/$EQ
	cd $WORKDIR/$EQ

	# check if eventStation exist, if does , skip
	set eventStation_num = `cat $WORKDIR/$EQ/eventStation.${EQ}|wc -l`
	if($eventStation_num > 20) then
		echo " $EQ is collected, skip"
		continue
	endif

	set year = `echo $EQ |cut -c 1-4`
	set month = `echo $EQ |cut -c 5-6`
	set day = `echo $EQ |cut -c 7-8`
	set hour = `echo $EQ |cut -c 9-10`
	set min = `echo $EQ |cut -c 11-12`
	set start = ${year}-${month}-${day}T${hour}:${min}:00
	set end = `date +"%Y-%m-%d-%H-%M" -d "${year}-${month}-${day} + ${hour} hours + ${min} minutes + ${minutes_len} minutes" `

	set nyear = `echo $end |awk -F"-" '{print $1}'`
	set nmonth = `echo $end |awk -F"-" '{print $2}'`
	set nday = `echo $end |awk -F"-" '{print $3}'`
	set nhour = `echo $end |awk -F"-" '{print $4}'`
	set nmin = `echo $end |awk -F"-" '{print $5}'`
	set end = ${nyear}-${nmonth}-${nday}T${nhour}:${nmin}:00
	cp $PWD/trans.sh .
	cat $EVENTS|awk -v sss=$EQ '$1==sss {print $0}' >! $WORKDIR/$EQ/EVENT
	cp $rdseed_file rdseed

	foreach NETNAME (`cat $network_list`)

		set xml_file = orfeus.${NETNAME}.xml
		set dataless_file = orfeus.${NETNAME}.dataless
		wget -O $xml_file "http://www.orfeus-eu.org/fdsnws/station/1/query?network=${NETNAME}&station=*&level=response&starttime=${year}-${month}-${day}&endtime=${nyear}-${nmonth}-${nday}" > & /dev/null

		set num = `cat $xml_file|wc -l`
		if($num == 0) then
			/bin/rm $xml_file > & /dev/null
			continue
		endif

		set STA = "*"
		set seed_file = orfeus.${NETNAME}.seed
		wget -O $seed_file "http://www.orfeus-eu.org/fdsnws/dataselect/1/query?network=${NETNAME}&station=${STA}&start=${start}&end=${end}" >& /dev/null
		set num = `cat $seed_file|wc -l`
		if($num == 0) then
			/bin/rm $seed_file > & /dev/null
			continue
		endif

		# convert dataless to seed
		set script = $PWD/stationxml-converter-1.0.9.jar

		echo "   ==> Collection Network $NETNAME "
		java -jar $script --seed --output $dataless_file $xml_file > & /dev/null 
		./trans.sh $dataless_file $seed_file

	end # NETNAME


### clean up
/bin/rm orfeus.* > & /dev/null &
/bin/rm rdseed > & /dev/null  &
/bin/rm -rf EVENT problem_record sac.log trans.sh > & /dev/null &
end 

