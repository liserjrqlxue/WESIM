#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

hg19=$pipeline/hg19/hg19_chM_male_mask.fa
bed=$pipeline/SMA_WES/PP100.gene.info.bed

echo `date` Start samtoolsBedcov
mkdir -p $Workdir/cnv
echo -e "Chr\tStart\tEnd\tStrand\tGene\tExon\tTrans\tPrimarytag\tGenelength\t${sampleID}_total_cvg" > $Workdir/cnv/$sampleID.bqsr.bam.bedcov
time samtools \
  bedcov \
  $bed \
  $Workdir/bwa/$sampleID.bqsr.bam \
  >> $Workdir/cnv/$sampleID.bqsr.bam.bedcov
echo `date` Done
