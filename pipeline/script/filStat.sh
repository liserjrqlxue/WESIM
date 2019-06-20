#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4
Workdir=$workdir/$sampleID/filter/$laneName
stat=$pipeline/tools/soapnuke_stat.pl

echo `date` Start FQstat

perl $stat \
    $Workdir/Basic_Statistics_of_Sequencing_Quality.txt \
    $Workdir/Statistics_of_Filtered_Reads.txt \
    >$Workdir/$laneName.filter.stat

echo `date` Done
