#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
GATK=$pipeline/tools/GenomeAnalysisTK.jar
DbSNP=$pipeline/hg19/dbsnp_138.hg19.vcf
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

$pipeline/java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T PrintReads \
    -R $hg19 \
    -BQSR $Workdir/bwa/$sampleID.recal_data.grp
    -I    $Workdir/bwa/$sampleID.sort.realn.bam \
    -o    $Workdir/bwa/$sampleID.final.bam