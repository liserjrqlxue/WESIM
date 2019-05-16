#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
java=$pipeline/tools/java
Picard=$pipeline/tools/picard
samtools=$pipeline/tools/samtools

echo Start SortSam `date`
$java -Djava.io.tmpdir=$workdir/javatmp \
    -jar $Picard/SortSam.jar \
    INPUT=$Workdir/$sampleID.raw.bam \
    OUTPUT=$Workdir/$sampleID.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=SILENT

$samtools index $Workdir/$sampleID.sort.bam

echo Done `date`
