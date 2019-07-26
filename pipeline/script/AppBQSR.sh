#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo `date` Start ApplyBQSR $sampleID

time gatk \
  ApplyBQSR \
  --tmp-dir=$workdir/javatmp \
  -R $hg19 \
  -I $Workdir/$sampleID.dup.bam \
  -O $Workdir/$sampleID.bqsr.bam \
  --create-output-bam-index \
  -bqsr $Workdir/$sampleID.recal_data.grp \
&& rm -rvf $Workdir/$sampleID.dup.bam || echo error

echo `date` Done
