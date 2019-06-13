#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
GATK=$pipeline/tools/GenomeAnalysisTK.jar
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo `date` Start SelectVariantsINDEL
tabix -f -p vcf $Workdir/gatk/HC/$sampleID.vcf.gz

java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T SelectVariants \
    -R $hg19 \
    -selectType INDEL \
    --variant $Workdir/gatk/HC/$sampleID.vcf.gz \
    -o        $Workdir/gatk/HC/short_indel/$sampleID.indel.raw.vcf

echo `date` Done
