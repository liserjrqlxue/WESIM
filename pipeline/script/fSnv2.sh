#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
GATK=$pipeline/tools/GenomeAnalysisTK.jar
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
filterExpression="QD<2.0 || MQ<40.0 || FS>60.0 || HaplotypeScore>13.0 || MQRankSum<-12.5 || ReadPosRankSum<-8.0"

echo `date` Start VariantFiltration

java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T VariantFiltration \
    -R $hg19 \
    --filterExpression "$filterExpression" \
    --filterName "StandardFilter" \
    --variant $Workdir/gatk/UG/snv/$sampleID.snv.raw.vcf \
    -o        $Workdir/gatk/UG/snv/$sampleID.snv.filter.vcf

echo `date` Done
