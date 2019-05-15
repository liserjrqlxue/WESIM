#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
GATK=$pipeline/tools/GenomeAnalysisTK.jar
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
filterExpression="QD<2.0 || MQ<40.0 || FS>60.0 || HaplotypeScore>13.0 || MQRankSum<-12.5 || ReadPosRankSum<-8.0"

$pipeline/tabix -f -p vcf $Workdir/gatk/UG/$sampleID.vcf.gz

$pipeline/java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T SelectVariants \
    -R $hg19 \
    -selectType SNP \
    --variant $Workdir/gatk/UG/$sampleID.vcf.gz \
    -o        $Workdir/gatk/UG/snv/$sampleID.snv.raw.vcf

$pipeline/java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T VariantFiltration \
    -R $hg19 \s
    --filterExpression $filterExpression \
    --filterName "StandardFilter" \
    --variant $Workdir/gatk/UG/snv/$sampleID.snp.raw.vcf \
    -o        $Workdir/gatk/UG/snv/$sampleID.snv.filter.vcf

$pipeline/java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T ReadBackedPhasing \
    -R $hg19 \
    -I        $Workdir/bwa/$sampleID.final.bam \
    --variant $Workdir/gatk/UG/snv/$sampleID.snp.filter.vcf \
    -o        $Workdir/gatk/UG/snv/$sampleID.snv.vcf

