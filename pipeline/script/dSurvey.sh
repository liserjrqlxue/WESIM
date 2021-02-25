#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3
QChistory=${4:-""}

complete=$workdir/$sampleID/shell/dSurvey.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

GenderCorrect=$pipeline/tools/XY_gender_correct.pl
GetQC=$pipeline/tools/getQC/get.QC.WESIM.pl
bed=$pipeline/config/V4.coverage.bed
tag=BGI59M


echo `date` Start depthSurvey

bamdstComplete=$workdir/$sampleID/coverage/bamdst.complete
if [ -e "$bamdstComplete" ];then
	echo "$bamdstComplete and skip"
else
	echo `date` bamdst -p $bed --uncover 5 -o $Workdir/coverage $Workdir/bwa/$sampleID.bqsr.bam --cutoffdepth 20
	\time -v bamdst -p $bed --uncover 5 -o $Workdir/coverage $Workdir/bwa/$sampleID.bqsr.bam --cutoffdepth 20 
	touch $bamdstComplete
fi

echo `date` perl $GenderCorrect $Workdir/coverage/chromosomes.report $tag
perl $GenderCorrect $Workdir/coverage/chromosomes.report $tag

echo `date` perl $GetQC $sampleID $Workdir $Workdir $QChistory
perl $GetQC $sampleID $Workdir $Workdir $QChistory 

echo `date` Done

touch $complete
