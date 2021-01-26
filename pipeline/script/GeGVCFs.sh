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

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
interval_list=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
ref_fasta=$pipeline/hg19/hg19_chM_male_mask.fa
gvcf_basename=$Workdir/gatk/$sampleID.gvcf
vcf_basename=$Workdir/gatk/$sampleID.vcf

echo `date` Start GenotypeGVCFs
\time -v gatk \
  GenotypeGVCFs \
  --tmp_dir $workdir/javatmp \
  -R $ref_fasta \
  -O $vcf_basename.vcf.gz \
  -V $gvcf_basename.vcf.gz \
  -L $interval_list \
  --showHidden \

echo `date` Done

touch $complete
