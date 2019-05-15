#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
Picard=$pipeline/tools/picard

$pipeline/java -Djava.io.tmpdir=$workdir/javatmp \
    -jar $Picard/MarkDuplicates.jar \
    MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=8000 \
    INPUT=$Workdir/bwa/$sampleID.sort.bam \
    OUTPUT=$Workdir/bwa/$sampleID.sort.dup.bam \
    METRICS_FILE=$Workdir/bwa/$sampleID.sort.dup.metrics \
    VALIDATION_STRINGENCY=SILENT

$pipeline/samtools index $Workdir/bwa/$sampleID.sort.dup.bam
