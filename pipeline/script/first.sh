#!/usr/bin/env bash
workdir=$1
pipeline=$2
laneInput=${3:-null}

Workdir=$workdir/result
export PATH=$pipeline/tools:$PATH
GetLaneQC=$pipeline/tools/getQC/get.lane.QC.batch.pl

echo -e "sampleID\tQC\tchip_code" > $Workdir/standard.QC.txt \
|| { echo error;exit 1; }

if [ $laneInput == "null" ];then
	echo no laneInput
	exit 0
fi

echo `date` Start GetLaneQC
time perl $GetLaneQC $laneInput $Workdir \
&& echo success \
|| { echo error;exit 1; }
echo `date` Done
