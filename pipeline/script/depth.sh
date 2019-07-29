#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

hg19=$pipeline/hg19/hg19_chM_male_mask.fa
bed=$pipeline/SMA_WES/PP100.gene.info.bed

echo `date` Start samtoolsDepth
mkdir -p $Workdir/cnv
echo -e "Chr\tPos\tDepth_for_${sampleID}" >$Workdir/cnv/$sampleID.bqsr.bam.depth
time samtools \
  depth -aa \
  -b $bed \
  $Workdir/bwa/$sampleID.bqsr.bam \
  >> $Workdir/cnv/$sampleID.bqsr.bam.depth
echo `date` Done
