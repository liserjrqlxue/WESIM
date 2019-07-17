#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

bam=$workdir/$sampleID/bwa/$sampleID.bqsr.bam
export PATH=$pipeline/tools:$PATH
Workdir=$workdir/$sampleID/bwa
CNVkitControl=$pipeline/CNVkit/control/MGISEQ_2000_control/201906/MGISEQ-2000_201906

echo `date` Start CNVkitAnalyse
time perl \
  $pipeline/CNVkit/bin/analyse.pl \
  $CNVkitControl \
  $bam \
  cbs \
  $Workdir/$sampleID

echo `date` sh $Workdir/$sampleID.sh
time sh $Workdir/$sampleID.sh
echo `date` Done
