#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

tag=""
control=$pipeline/CNVkit/control/MGISEQ_2000_control/201811/MGISEQ-2000_201811
bam=$Workdir/$sampleID.bqsr.bam

echo `date` Start ${tag}TargetCoverage
cnvkit.py \
  coverage \
  -p 12 \
  $bam \
  $control.${tag}targets.bed \
  -o $Workdir/$sampleID.${tag}targetcoverage.cnn
echo `date` Done

