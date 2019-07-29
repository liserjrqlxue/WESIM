#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

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

time gatk \
  MergeSamFiles \
  --TMP_DIR $workdir/$sampleID/javatmp \
  $INPUT \
  -O $Workdir/$sampleID.merge.bam \
  --USE_THREADING \
  -SO coordinate \
  --showHidden=true \
&& rm -rvf $inputBams || echo error

echo `date` Done
