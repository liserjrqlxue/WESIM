#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH
GATK=$pipeline/tools/GenomeAnalysisTK.jar
Bed=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
DbSNP=$pipeline/hg19/dbsnp_138.hg19.vcf
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo Start BQSR `date`
java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T BaseRecalibrator \
    -R $hg19 \
    -L $Bed \
    -knownSites $DbSNP \
    -I $Workdir/$sampleID.sort.realn.bam \
    -o $Workdir/$sampleID.recal_data.grp

echo Done `date`
