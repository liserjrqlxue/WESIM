#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

echo `date` Start Merge
shift 3
inputBams=""
for i in $@;do
    inputBams="$inputBams $Workdir/sampleID.raw.$i.bam"
done

echo Start merge `date`
samtools \
    merge \
    -@ 8 \
    -f $Workdir/$sampleID.raw.bam \
    $inputBams

echo `date` Done
