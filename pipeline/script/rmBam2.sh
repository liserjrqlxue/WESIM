#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
echo Start rmRawBam `date`
rm -rvf $Workdir/$sampleID.raw.bam
echo Done `date`
