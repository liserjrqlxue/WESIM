#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

bam=$workdir/$sampleID/bwa/$sampleID.bqsr.bam
export PATH=$pipeline/tools:$PATH
Workdir=$workdir/CNVkit

echo time perl \
    $pipeline/CNVkit/bin/analyse.pl \
    $pipeline/CNVkit/control/MGISEQ_2000_control/201811/MGISEQ-2000_201811 \
    $bam \
    cbs \
    $Workdir/$sampleID

time perl \
    $pipeline/CNVkit/bin/analyse.pl \
    $pipeline/CNVkit/control/MGISEQ_2000_control/201811/MGISEQ-2000_201811 \
    $bam \
    cbs \
    $Workdir/$sampleID

sh $Workdir/$sampleID.sh
