#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4
Workdir=$workdir/$sampleID
stat=$pipeline/tools/soapnuke_stat.pl

echo Start stat `date`
perl $stat \
    $Workdir/filter.$laneName/Basic_Statistics_of_Sequencing_Quality.txt \
    $Workdir/filter.$laneName/Statistics_of_Filtered_Reads.txt \
    >$Workdir/filter.$laneName/$laneName.filter.stat

echo Done `date`
