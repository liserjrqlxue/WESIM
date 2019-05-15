#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
GATK=$pipeline/tools/GenomeAnalysisTK.jar
IndelPhasing=$pipeline/bin/indel_phasing.pl
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

$pipeline/tabix -f -p vcf $Workdir/gatk/HC/$sampleID.vcf.gz

$pipeline/java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T CombineVariants \
    -R $hg19 \
    -genotypeMergeOptions UNSORTED \
    --variant $Workdir/gatk/UG/snv/$sampleID.snv.vcf \
    --variant $Workdir/gatk/HC/short_indel/$sampleID.indel.vcf \
    -o $Workdir/gatk/$sampleID.filter.vcf

$pipeline/perl $IndelPhasing \
    -b $Workdir/bwa/$sampleID.final.bam \
    -v $Workdir/gatk/$sampleID.filter.vcf \
    -o $Workdir/gatk/$sampleID.final.vcf

$pipeline/bgzip -f  $Workdir/gatk/$sampleID.final.vcf

$pipeline/tabix -f -p vcf $Workdir/gatk/$sampleID.final.vcf.gz