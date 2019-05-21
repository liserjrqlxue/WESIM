#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
gender=$4

export PATH=$pipeline/tools:$PATH
Bin=$pipeline/ExomeDepth
outdir=$workdir/ExomeDepth
gender=$gender
echo `date` Start ExomeDepth3

echo `date` Rscript $Bin/run.getCNVs.R $sampleID A        $outdir
Rscript $Bin/run.getCNVs.R $sampleID A        $outdir
echo `date` Rscript $Bin/run.getCNVs.R $sampleID $gender  $outdir
Rscript $Bin/run.getCNVs.R $sampleID $gender  $outdir

echo `date` Done
