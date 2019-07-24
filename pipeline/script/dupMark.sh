#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

echo `date` Start MarkDuplicates
gatk \
  MarkDuplicates \
  -I $Workdir/$sampleID.sort.bam \
  -O $Workdir/$sampleID.dup.bam \
  -M $Workdir/$sampleID.dup.metrics \
  --CREATE_INDEX \
  --CLEAR_DT false \
  --showHidden \
&& rm -rvf $Workdir/$sampleID.sort.bam || echo error

#echo Start index `date`
#samtools index $Workdir/$sampleID.sort.dup.bam

echo `date` Done
