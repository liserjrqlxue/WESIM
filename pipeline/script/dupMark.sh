#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
java=$pipeline/tools/java
Picard=$pipeline/tools/picard

echo Start MakrDuplicates `date`
$java -Djava.io.tmpdir=$workdir/javatmp \
    -jar $Picard/MarkDuplicates.jar \
    MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=8000 \
    INPUT=$Workdir/$sampleID.sort.bam \
    OUTPUT=$Workdir/$sampleID.sort.dup.bam \
    METRICS_FILE=$Workdir/$sampleID.sort.dup.metrics \
    VALIDATION_STRINGENCY=SILENT

$pipeline/samtools index $Workdir/$sampleID.sort.dup.bam

echo Done `date`
