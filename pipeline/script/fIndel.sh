#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
filterExpression="QD<2.0 || ReadPosRankSum<-20.0 || InbreedingCoeff<-0.8 || FS>200.0"

echo `date` Start SelectVariantsINDEL
time gatk \
  SelectVariants \
  --tmp-dir=$workdir/javatmp \
  -O $Workdir/gatk/$sampleID.indel.raw.vcf \
  -V $Workdir/gatk/$sampleID.vcf.vcf.gz \
  -R $hg19 \
  -select-type INDEL \
  --showHidden \
  && echo success || echo error

echo `date` Start VariantFiltrationINDEL
time gatk \
  VariantFiltration \
  -O $Workdir/gatk/$sampleID.indel.vcf \
  -V $Workdir/gatk/$sampleID.indel.raw.vcf \
  -filter "$filterExpression" \
  --filter-name "StandardFilter" \
  -R $hg19 \
  --showHidden \
  && echo success || echo error

echo `date` Done