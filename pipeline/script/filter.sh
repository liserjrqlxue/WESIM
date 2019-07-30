#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4
fq1=$5
fq2=$6

Workdir=$workdir/$sampleID/filter/$laneName
export PATH=$pipeline/tools:$PATH
stat=$pipeline/tools/soapnuke_stat.pl

echo `date` Start SOAPnuke
time SOAPnuke filter -o $Workdir \
    --fq1 $fq1 \
    --fq2 $fq2 \
    --adapter1 AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA \
    --adapter2 AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG \
    --cleanFq1 $sampleID.$laneName.filter_1.fq.gz \
    --cleanFq2 $sampleID.$laneName.filter_2.fq.gz \
    --nRate 0.05 --lowQual 10  --seqType 0 --qualRate 0.5 -Q 2 -G 2 \
&& echo succes || echo error

echo `date` Start FQstat
time perl $stat \
    $Workdir/Basic_Statistics_of_Sequencing_Quality.txt \
    $Workdir/Statistics_of_Filtered_Reads.txt \
    >$Workdir/$laneName.filter.stat \
&& echo succes || echo error

echo `date` Done
