#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
laneInput=${3:-null}

Workdir=$workdir/result
export PATH=$pipeline/tools:$PATH
GetLaneQC=$pipeline/tools/getQC/get.lane.QC.batch.pl

echo -e "sampleID\tQC\tchip_code" > $Workdir/standard.QC.txt 

if [ $laneInput == "null" ];then
	echo no laneInput
	exit 0
fi

echo `date` Start GetLaneQC

\time -v perl $GetLaneQC $laneInput $Workdir

touch $workdir/shell/first.sh.complete
echo `date` Done
