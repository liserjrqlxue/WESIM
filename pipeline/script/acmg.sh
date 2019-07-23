#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
acmg=$pipeline/acmg2015/bin/anno.acmg.pl
prefix=$Workdir/annotation/$sampleID

echo `date` Start ACMG2015V1

time perl \
    $acmg \
    $prefix.out \
    >$prefix.out.ACMG

echo `date` Done
