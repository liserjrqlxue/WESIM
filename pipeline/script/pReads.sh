#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH
GATK=$pipeline/tools/GenomeAnalysisTK.jar
DbSNP=$pipeline/hg19/dbsnp_138.hg19.vcf
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T PrintReads \
    -R $hg19 \
    -BQSR $Workdir/$sampleID.recal_data.grp \
    -I    $Workdir/$sampleID.sort.realn.bam \
    -o    $Workdir/$sampleID.final.bam
