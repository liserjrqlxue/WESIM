#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/HC4.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
interval_list=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
ref_fasta=$pipeline/hg19/hg19_chM_male_mask.fa
gvcf_basename=$Workdir/gatk/$sampleID.gvcf
in_bam=$Workdir/bwa/$sampleID.bqsr.bam

echo `date` Start G4HaplotypeCaller
\time -v gatk \
  HaplotypeCaller \
  --tmp-dir $workdir/javatmp \
  -R $ref_fasta \
  -O $gvcf_basename.vcf.gz \
  -I $in_bam \
  -L $interval_list \
  -ERC GVCF \
  --showHidden \

echo `date` Done

touch $complete
