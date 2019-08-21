#!/usr/bin/env bash
workdir=$1
pipeline=$2
laneInput=${3:-null}

Workdir=$workdir
export PATH=$pipeline/tools:$PATH
GetLaneQC=$pipeline/getQC/get.lane.QC.batch.pl

echo -e "sampleID\tQC" > $workdir/standard.QC.txt

if [ $laneInput == "null" ];then
	echo no laneInput
	exit 0
fi

echo `date` Start GetLaneQC
time perl $GetLaneQC $laneInput $Workdir && echo succes || (echo error && exit 1)
echo `date` Done
