#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
gender=$4

Bin=$pipeline/ExomeDepth
Bam=$workdir/$sampleID/bwa/$sampleID.final.bam
outdir=$workdir/ExomeDepth

$pipeline/Rscript $Bin/run.getBamCount.R $sampleID $Workdir $Bam A       $outdir
$pipeline/Rscript $Bin/run.getBamCount.R $sampleID $Workdir $Bam $gender $outdir