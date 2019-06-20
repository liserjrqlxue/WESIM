#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
echo `date` Start bwaMem
bwa \
    mem -K 100000000 -t 8 -M \
    -R "@RG\tID:$sampleID\tSM:$sampleID\tLB:$laneName\tPL:COMPLETE" \
    $hg19 \
    $Workdir/filter/$laneName/pe.$laneName.1_filter.fq.gz \
    $Workdir/filter/$laneName/pe.$laneName.2_filter.fq.gz \
    | samtools view -S -b \
    -o $Workdir/bwa/sampleID.raw.$laneName.bam \
    -
echo `date` Done
