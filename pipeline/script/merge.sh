#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

shift 3
inputBams=""
for i in $@;do
    inputBams="$inputBams $Workdir/bwa/sampleID.raw.$i.bam"
done

Workdir=$workdir/$sampleID/bwa
Picard=$pipeline/tools/picard

$pipeline/samtools \
    merge \
    -f $Workdir/sampleID.raw.bam \
    $inputBamss

$pipeline/java -Djava.io.tmpdir=$workdir/javatmp \
    -jar $Picard/SortSam.jar \
    INPUT=$Workdir/bwa/$sampleID.raw.bam \
    OUTPUT=$Workdir/bwa/$sampleID.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=SILENT

$pipeline/samtools index $Workdir/bwa/$sampleID.sort.bam
