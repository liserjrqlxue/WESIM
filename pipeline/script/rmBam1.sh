#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
samtools=$pipeline/tools/samtools

shift 3
inputBams=""
for i in $@;do
    inputBams="$inputBams $Workdir/sampleID.raw.$i.bam"
done

echo Start rmLaneBam `date`
rm -rvf $inputBams

echo Done `date`
