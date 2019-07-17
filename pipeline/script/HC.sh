#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
GATK=$pipeline/tools/GenomeAnalysisTK.jar
Bed=$pipeline/config/cns_region_hg19_bychr/for500_region.bed
hg19=$pipeline/hg19/hg19_chM_male_mask.fa

java  -Djava.io.tmpdir=$workdir/javatmp \
    -jar $GATK \
    -T HaplotypeCaller \
    -R $hg19 \
    -L $Bed \
    -l INFO \
    -rf BadCigar \
    -A AlleleBalance \
    -A HaplotypeScore \
    -stand_call_conf 30.0 \
    -stand_emit_conf 10.0 \
    -I $Workdir/bwa/$sampleID.bqsr.bam \
    -o $Workdir/gatk/HC/$sampleID.vcf

bgzip -f $Workdir/gatk/HC/$sampleID.vcf
