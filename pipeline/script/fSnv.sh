#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
filterExpression="QD<2.0 || MQ<40.0 || FS>60.0 || HaplotypeScore>13.0 || MQRankSum<-12.5 || ReadPosRankSum<-8.0"

echo `date` Start SelectVariantsSNP
time gatk \
  SelectVariants \
  --tmp-dir=$workdir/javatmp \
  -O $Workdir/gatk/$sampleID.snp.raw.vcf \
  -V $Workdir/gatk/$sampleID.vcf.vcf.gz \
  -R $hg19 \
  -select-type SNP \
  --showHidden \
  && echo success || echo error

echo `date` Start VariantFiltrationSNP
time gatk \
  VariantFiltration \
  -O $Workdir/gatk/$sampleID.snp.vcf \
  -V $Workdir/gatk/$sampleID.snp.raw.vcf \
  -filter "$filterExpression" \
  --filter-name "StandardFilter" \
  -R $hg19 \
  --showHidden \
  && echo success || echo error

echo `date` Done
