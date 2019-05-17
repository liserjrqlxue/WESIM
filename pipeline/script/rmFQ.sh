#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4

Workdir=$workdir/$sampleID/filter/$laneName

echo Start rmFQ `date`
rm -rvf $Workdir/pe.$laneName.1_filter.fq.gz $Workdir/pe.$laneName.2_filter.fq.gz
echo Done `date`
