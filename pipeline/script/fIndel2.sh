#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
GATK=$pipeline/tools/GenomeAnalysisTK.jar
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
filterExpression="QD<2.0 || ReadPosRankSum<-20.0 || InbreedingCoeff<-0.8 || FS>200.0"

echo `date` Start VariantFiltrationINDEL

java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -R $hg19 \
    -T VariantFiltration \
    --filterExpression "$filterExpression" \
    --filterName "StandardFilter" \
    --variant  $Workdir/gatk/HC/short_indel/$sampleID.indel.raw.vcf \
    -o         $Workdir/gatk/HC/short_indel/$sampleID.indel.vcf

echo `date` Done