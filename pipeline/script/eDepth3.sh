#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
gender=$4

Bin=$pipeline/ExomeDepth
outdir=$workdir/ExomeDepth
gender=$gender

$pipeline/Rscript $Bin/run.getCNVs.R $smapleID A        $outdir
$pipeline/Rscript $Bin/run.getCNVs.R $sampleID $gender  $outdir