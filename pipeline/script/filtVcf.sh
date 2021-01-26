#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/AppBQSR.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID/gatk
export PATH=$pipeline/tools:$PATH
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
filterExpressionSNP="QD<2.0 || MQ<40.0 || FS>60.0 || HaplotypeScore>13.0 || MQRankSum<-12.5 || ReadPosRankSum<-8.0"
filterExpressionINDEL="QD<2.0 || ReadPosRankSum<-20.0 || InbreedingCoeff<-0.8 || FS>200.0"

echo `date` Start SelectVariantsSNP
\time -v gatk \
  SelectVariants \
  --tmp_dir $workdir/javatmp \
  -O $Workdir/$sampleID.snp.raw.vcf \
  -V $Workdir/$sampleID.vcf.vcf.gz \
  -R $hg19 \
  -select-type SNP \
  --showHidden 

echo `date` Start VariantFiltrationSNP
\time -v gatk \
  VariantFiltration \
  -O $Workdir/$sampleID.snp.vcf \
  -V $Workdir/$sampleID.snp.raw.vcf \
  -filter "$filterExpressionSNP" \
  --filter-name "StandardFilter" \
  -R $hg19 \
  --showHidden 


echo `date` Start SelectVariantsINDEL
\time -v gatk \
  SelectVariants \
  --tmp_dir $workdir/javatmp \
  -O $Workdir/$sampleID.indel.raw.vcf \
  -V $Workdir/$sampleID.vcf.vcf.gz \
  -R $hg19 \
  -select-type INDEL \
  --showHidden 

echo `date` Start VariantFiltrationINDEL
\time -v gatk \
  VariantFiltration \
  -O $Workdir/$sampleID.indel.vcf \
  -V $Workdir/$sampleID.indel.raw.vcf \
  -filter "$filterExpressionINDEL" \
  --filter-name "StandardFilter" \
  -R $hg19 \
  --showHidden

echo `date` Start MergeVcfs
\time -v gatk \
  MergeVcfs \
  -I $Workdir/$sampleID.snp.vcf \
  -I $Workdir/$sampleID.indel.vcf \
  -O $Workdir/$sampleID.filter.vcf.gz \
  --showHidden 

echo `date` Done

touch $complete
