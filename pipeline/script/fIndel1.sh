#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo `date` Start SelectVariantsINDEL
gatk \
  SelectVariants \
  --tmp-dir=$workdir/javatmp \
  -O $Workdir/gatk/$sampleID.indel.raw.vcf \
  -V $Workdir/gatk/$sampleID.vcf.vcf.gz \
  -R $hg19 \
  -select-type INDEL \
  --showHidden
echo `date` Done

