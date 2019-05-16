#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
java=$pipeline/tools/java
GATK=$pipeline/tools/GenomeAnalysisTK.jar
Bed=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo Start IndelRealigner `date`
$java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T IndelRealigner \
    -R $hg19 \
    -filterNoBases \
    -targetIntervals $Workdir/bwa/$sampleID.realn_data.intervals \
    -I $Workdir/bwa/$sampleID.sort.dup.bam \
    -o $Workdir/bwa/$sampleID.sort.realn.bam

echo Done `date`