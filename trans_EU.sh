#!/bin/sh

# =================================================================
# This code deal with data collection from breqFast EU nets for BH?
#
# Input: file, EVETN
#        file, *fseed or *seed
#
#
# Shule Yu
# Feb 10 2014
# Modified by Hongyu Oct 2017
# =================================================================

dataless=$1
inputdata=$2

# 0. clean up everything. only *fseed and EVENT and this script exists.
mkdir -p problem_record
read EQ EVENTTIMEH EVENTTIMEM EVENTTIMES EVLA EVLO EVDE EVMAG MAGTYPE < EVENT 

# 1. decompress every *fseed and *seed file
rdseed -pdf ${inputdata} -g $dataless

# 2. get all station name, that's what we should get.
saclst kstnm f `ls *.SAC` | awk '{print $2}' | sort | uniq > NTWORKS
NSTA=`wc -l NTWORKS |awk '{print $1}'`

# 3. however we throw away stations who gave us segament data.
#    a little bit heavy hand here.
while read STname
do
    if [ $(( `ls *.${STname}.*BHN*.SAC |wc -l`+`ls *.${STname}.*BHE*.SAC |wc -l`+`ls *.${STname}.*BHZ*.SAC |wc -l`)) -ne 3 ]
    then
        mv *.${STname}.*.SAC problem_record
        mv SAC_*_${STname}_* problem_record
    fi
done < NTWORKS

# 4. rtr, rmean, taper, transfer response.
#    change name, clean pzfiles
for file in `ls *SAC 2> /dev/null`
do
    name=`saclst kstnm f $file | awk '{print $2}'`
    comp=`saclst kcmpnm f $file | awk '{print $2}'`
    NTWORK=`saclst knetwk f $file | awk '{print $2}'`
    file1="${EQ}.${NTWORK}.${name}.${comp}.sac"
    mv $file $file1
    echo "$file -> $file1"

    pzfile=`ls SAC_*_${name}_* |grep ${comp}`
    if [ -z ${pzfile} ]
    then
        mv *.${name}.*sac problem_record
        mv SAC_*_${name}_* problem_record
        continue
    fi
    sac << EOF >> sac.log
setbb pzfile "$pzfile"
r $file1
rtr
rmean
taper
TRANS FROM POLEZERO S %pzfile TO NONE FREQ 0.005 0.01 1e5 1e6
chnhdr evla $EVLA evlo $EVLO evdp $EVDE mag ${EVMAG}
w over
q
EOF
done
rm SAC_* > /dev/null 2>&1

# 5. set O marker, for taup_setsac use.
saclst kztime f `ls *sac` | awk -F'[: ]'+ '{print $1" "$2" "$3" "$4}' > Omarker

while read file DATATIMEH DATATIMEM DATATIMES
do
    Omarker=`echo "$EVENTTIMEH $DATATIMEH $EVENTTIMEM $DATATIMEM $EVENTTIMES $DATATIMES" | awk '{print ($2-$1)*3600+($4-$3)*60+($6-$5)}'`
    sac << EOF >> sac.log
r $file
chnhdr ALLT $Omarker
chnhdr O 0
w over
q
EOF
## 5.1 use taup_setsac to set markers.
taup_setsac  -mod prem -ph P-0,Pdiff-0,pP-1,S-2,Sdiff-2,sS-3,PP-4,SS-5,SKKS-6,PKP-7,SKS-8,ScS-9 $file
done < Omarker

# 6. rotate. before that we need cut.
for file in `ls *sac |awk  'BEGIN {FS="BHE"} {print $1}' | grep -v sac`
do
    sac <<EOF >>sac.log
cuterr fillz
cut O 0 7200
r ${file}BHN.sac ${file}BHE.sac
rotate
w ${file}BHR.sac ${file}BHT.sac
q
EOF

if ! [ `saclst NPTS f ${file}BHR.sac | awk '{print $2}'` = `saclst NPTS f ${file}BHT.sac | awk '{print $2}'` ]
then
    mv ${file}*.sac  ./problem_record
    echo "=======================" >> cut_problem
    echo Cut problem! >> cut_problem
    echo "=======================" >> cut_problem
    echo "${file}" >> cut_problem
fi

done

# 7. add component info to header
for file in `ls *BHR.sac 2>/dev/null`
do
    sac << EOF >> sac.log
r ${file}
chnhdr KCMPNM BHR
w over
q
EOF
done
for file in `ls *BHT.sac 2>/dev/null`
do
    sac << EOF >> sac.log
r ${file}
chnhdr KCMPNM BHT
w over
q
EOF
done

# 8. remove E and N data
rm `ls *E.sac`  > /dev/null 2>&1
rm `ls *N.sac`  > /dev/null 2>&1

# 9. write eventStation file
saclst KSTNM KNETWK GCARC AZ BAZ STLA STLO EVLA EVLO EVDP  f `ls *BHR.sac` \
    |awk  '{print $2" "$3" "$4" DEGREE "$5" deg "$6" deg "$7" "$8" "$9" "$10" "$11/1000" km"}'  > tmp

awk -v M=${MAGTYPE} '{print $0" "M}' tmp \
    |awk -v M=${EVMAG} '{print $0" "M" VEBSN EIDA "}' \
    |awk -v E=${EQ} '{print $0" "E}' \
    > eventStation.${EQ}

NSTA2=`wc -l eventStation.${EQ} | awk '{print $1}'`

# 10. clean up
rm Omarker rdseed.err_log tmp NTWORKS > /dev/null 2>&1

echo "${NSTA2}/${NSTA} records is collected." > result.txt
echo "`date`" >> result.txt
exit 0
