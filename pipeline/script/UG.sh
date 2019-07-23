#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

export PATH=$pipeline/tools:$PATH
Workdir=$workdir/$sampleID
GATK=$pipeline/tools/GenomeAnalysisTK.jar
Bed=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
#DbSNP=$pipeline/hg19/dbsnp_138.hg19.vcf
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T UnifiedGenotyper \
    -R $hg19 \
    -L $Bed \
    --genotype_likelihoods_model BOTH \
    -stand_call_conf 30.0 \
    -stand_emit_conf 10.0 \
    -I $Workdir/bwa/$sampleID.bqsr.bam \
    -o $Workdir/gatk/UG/$sampleID.vcf
    #--dbsnp $DbSNP \

bgzip -f $Workdir/gatk/UG/$sampleID.vcf

