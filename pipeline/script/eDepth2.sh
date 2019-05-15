#!/usr/bin/env bash
workdir=$1
pipeline=$2

Bin=$pipeline/ExomeDepth
outdir=$workdir/ExomeDepth
Rscript $Bin/run.getAllCounts.R $outdir/sample.list.checked A $outdir
Rscript $Bin/run.getAllCounts.R $outdir/sample.list.checked M $outdir
Rscript $Bin/run.getAllCounts.R $outdir/sample.list.checked F $outdir