#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
Picard=$pipeline/tools/picard
samtools=$pipeline/tools/samtools
echo Start SortSam `date`
$pipeline/java -Djava.io.tmpdir=$workdir/javatmp \
    -jar $Picard/SortSam.jar \
    INPUT=$Workdir/bwa/$sampleID.raw.bam \
    OUTPUT=$Workdir/bwa/$sampleID.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=SILENT

$samtools index $Workdir/bwa/$sampleID.sort.bam
echo Done `date`
