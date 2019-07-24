#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

echo `date` Start IndexDupBam
samtools index $Workdir/$sampleID.dup.bam

echo `date` Done
