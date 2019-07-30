#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

echo `date` Start MergeVcfs
time gatk \
  MergeVcfs \
  -I $Workdir/gatk/$sampleID.snp.vcf \
  -I $Workdir/gatk/$sampleID.indel.vcf \
  -O $Workdir/gatk/$sampleID.filter.vcf.gz \
  --showHidden \
  && echo success || echo error

echo `date` Done
