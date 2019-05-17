#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4
fq1=$5
fq2=$6
Workdir=$workdir/$sampleID
SOAPnuke=$pipeline/tools/SOAPnuke

echo Start SOAPnuke `date`
$SOAPnuke filter -o $Workdir/filter.$laneName \
    --fq1 $fq1 \
    --fq2 $fq2 \
    --adapter1 AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA \
    --adapter2 AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG \
    --cleanFq1 pe.$laneName.1_filter.fq.gz \
    --cleanFq2 pe.$laneName.2_filter.fq.gz \
    --nRate 0.05 --lowQual 10  --seqType 0 --qualRate 0.5 -Q 2 -G

echo Done `date`
