#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
gender=$4

export PATH=$pipeline/tools:$PATH
Bin=$pipeline/ExomeDepth
Bam=$workdir/$sampleID/bwa/$sampleID.bqsr.bam
outdir=$workdir/ExomeDepth

Rscript $Bin/run.getBamCount.R $sampleID $Bam A       $outdir $Bin
Rscript $Bin/run.getBamCount.R $sampleID $Bam $gender $outdir $Bin
