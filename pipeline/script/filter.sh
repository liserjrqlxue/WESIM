#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4
fq1=$5
fq2=$6
Workdir=$workdir/$sampleID
SOAPnuke=$pipeline/tools/SOAPnuke
stat=$pipeline/tools/soapnuke_stat.pl

echo Start SOAPnuke `date`
$SOAPnuke filter -o $Workdir \
    --fq1 $fq1 \
    --fq2 $fq2 \
    --adapter1 AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA \
    --adapter2 AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG \
    --cleanFq1 pe.$laneName.1_filter.fq.gz \
    --cleanFq2 pe.$laneName.2_filter.fq.gz \
    --nRate 0.05 --lowQual 10  --seqType 0 --qualRate 0.5 -Q 2 -G

echo Start stat `date`
perl $soapnuke_stat.pl \
    $Workdir/filter.$laneName/Basic_Statistics_of_Sequencing_Quality.txt \
    $Workdir/filter.$laneName/Statistics_of_Filtered_Reads.txt \
    >$Workdir/filter.$laneName/$laneName.filter.stat

echo Done `date`
