#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

hg19=$pipeline/hg19/hg19_chM_male_mask.fa
bed=$pipeline/SMA_WES/PP100.gene.info.bed

echo `date` Start samtoolsBedcov
samtools \
  bedcov \
  $bed \
  $Workdir/$sampleID.bqsr.bam \
  > $Workdir/$sampleID.bqsr.bam.bedcov
echo `date` Done
