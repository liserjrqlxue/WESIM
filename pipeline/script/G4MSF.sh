#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/G4MSF.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

echo `date` Start MergeSamFiles $sampleID
shift 3
inputBams=""
INPUT=""
for i in $@;do
    inputBams="$inputBams $Workdir/$sampleID.raw.$i.bam"
    INPUT="$INPUT -I $Workdir/$sampleID.raw.$i.bam"
done

\time -v gatk \
  MergeSamFiles \
  --TMP_DIR $workdir/$sampleID/javatmp \
  $INPUT \
  -O $Workdir/$sampleID.merge.bam \
  --USE_THREADING \
  -SO coordinate \
  --showHidden true 

echo `date` Done

touch $complete
