#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
laneInput=${3:-null}

complete=$workdir/shell/first.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/result
export PATH=$pipeline/tools:$PATH
GetLaneQC=$pipeline/tools/getQC/get.lane.QC.batch.pl

echo -e "sampleID\tQC\tchip_code" > $Workdir/standard.QC.txt 

if [ $laneInput == "null" ];then
	echo no laneInput
	touch $complete
	exit 0
fi

echo `date` Start GetLaneQC

\time -v perl $GetLaneQC $laneInput $Workdir

echo `date` Done
touch $complete
