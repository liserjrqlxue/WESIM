#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
interval_list=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
ref_fasta=$pipeline/hg19/hg19_chM_male_mask.fa
gvcf_basename=$Workdir/gatk/$sampleID.gvcf
in_bam=$Workdir/bwa/$sampleID.bqsr.bam

echo `date` Start G4HaplotypeCaller
gatk \
  HaplotypeCaller \
  --tmp-dir=$workdir/javatmp \
  -R $ref_fasta \
  -O $gvcf_basename.vcf.gz \
  -I $in_bam \
  -L $interval_list \
  -ERC GVCF \
  --showHidden
  #--max_alternate_alleles 3 \
  #-variant_index_parameter 128000 \
  #-variant_index_type LINEAR \
  #-contamination ${default=0 contamination} \
  #--read_filter OverclippedRead

echo `date` Done
