#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
GATK=$pipeline/tools/GenomeAnalysisTK.jar
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
filterExpression="QD<2.0 || ReadPosRankSum<-20.0 || InbreedingCoeff<-0.8 || FS>200.0"

$pipeline/tabix -f -p vcf $Workdir/gatk/HC/$sampleID.vcf.gz

$pipeline/java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T SelectVariants \
    -R $hg19 \
    -selectType INDEL \
    --variant $Workdir/gatk/HC/$sampleID.vcf.gz \
    -o        $Workdir/gatk/HC/short_indel/$sampleID.indel.raw.vcf

$pipeline/java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T VariantFiltration \
    -R $hg19 \
    -selectType INDEL \
    --filterExpression $filterExpression \
    --filterName "StandardFilter" \
    --variant  $Workdir/gatk/HC/short_indel/$sampleID.indel.raw.vcf \
    -o         $Workdir/gatk/HC/short_indel/$sampleID.indel.vcf