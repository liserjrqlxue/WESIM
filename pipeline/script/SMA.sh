#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/SMA
export PATH=$pipeline/tools:$PATH
control=$pipeline/SMA_WES/SMA_v2.txt.control_gene.csv

echo `date` Start SMA
perl \
  $pipeline/SMA_WES/run_SMN_CNV_v3.pl \
  $workdir/bam.list \
  $pipeline/SMA_WES/PP100.gene.info.bed \
  $control \
  $Workdir/ \
&&echo `date` sh $Workdir/run_SMN_CNV.sh

sh $Workdir/run_SMN_CNV.sh \
&&echo `date` Done
