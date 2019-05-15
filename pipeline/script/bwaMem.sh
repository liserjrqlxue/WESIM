#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
laneName=$4

Workdir=$workdir/$sampleID
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
bwa=$pipeline/tools/bwa
echo Start `date`
$bwa \
    mem -t 8 -M \
    -R "@RG\tID:$sampleID\tSM:$sampleID\tLB:$laneName\tPL:COMPLETE" \
    $hg19 \
    $Workdir/filter.$laneName/pe.$laneName.1_filter.fq.gz \
    $Workdir/filter.$laneName/pe.$laneName.2_filter.fq.gz \
    | samtools view -S -b \
    -o $Workdir/bwa/sampleID.raw.$laneName.bam \
    -
echo Done `date`
