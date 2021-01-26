#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/dupMark.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

echo `date` Start MarkDuplicates
\time -v gatk \
  MarkDuplicates \
  -I $Workdir/$sampleID.merge.bam \
  -O $Workdir/$sampleID.dup.bam \
  -M $Workdir/$sampleID.dup.metrics \
  --CREATE_INDEX \
  --CLEAR_DT false \
  --showHidden 

rm -rvf $Workdir/$sampleID.merge.bam

echo `date` Done

touch $complete
