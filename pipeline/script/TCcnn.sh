#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

tag=""
control=$pipeline/CNVkit/control/MGISEQ_2000_control/201811/MGISEQ-2000_201811
bam=$Workdir/bwa/$sampleID.bqsr.bam

echo `date` Start ${tag}TargetCoverage $sampleID
mkdir -p $Workdir/cnv
time cnvkit.py \
  coverage \
  -p 12 \
  $bam \
  $control.${tag}targets.bed \
  -o $Workdir/cnv/$sampleID.${tag}targetcoverage.cnn
echo `date` Done

