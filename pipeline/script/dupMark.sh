#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

echo `date` Start MakrDuplicates
gatk \
  MarkDuplicates \
  -I $Workdir/$sampleID.sort.bam \
  -O $Workdir/$sampleID.sort.dup.bam \
  -M $Workdir/$sampleID.sort.dup.metrics \
  --CLEAR_DT false \
  --showHidden

#echo Start index `date`
#samtools index $Workdir/$sampleID.sort.dup.bam

echo `date` Done
