#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/BQSR.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH
Bed=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
DbSNP=$pipeline/hg19/dbsnp_138.hg19.vcf
GoldIndels=$pipeline/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo `date` Start BQSR $sampleID
mkdir -p $workdir/javatmp
\time -v gatk \
  BaseRecalibrator \
  --tmp-dir $workdir/javatmp \
  -I $Workdir/$sampleID.dup.bam \
  -O $Workdir/$sampleID.recal_data.grp \
  --known-sites $DbSNP \
  --known-sites $GoldIndels \
  -R $hg19 \
  -L $Bed \
  --showHidden 

echo `date` Done

touch $complete
