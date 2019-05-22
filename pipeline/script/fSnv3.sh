#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
GATK=$pipeline/tools/GenomeAnalysisTK.jar
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo `date` Start ReadBackedPhasing
java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T ReadBackedPhasing \
    -R $hg19 \
    -I        $Workdir/bwa/$sampleID.final.bam \
    --variant $Workdir/gatk/UG/snv/$sampleID.snv.filter.vcf \
    -o        $Workdir/gatk/UG/snv/$sampleID.snv.vcf

echo `date` Done
