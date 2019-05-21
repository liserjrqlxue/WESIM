#!/usr/bin/env bash
workdir=$1
pipeline=$2

export PATH=$pipeline/tools:$PATH
Bin=$pipeline/ExomeDepth
outdir=$workdir/ExomeDepth
echo `date` Start ExomeDepth2

echo `date` Rscript $Bin/run.getAllCounts.R $workdir/sample.list A $outdir
Rscript $Bin/run.getAllCounts.R $workdir/sample.list A $outdir
echo `date` Rscript $Bin/run.getAllCounts.R $workdir/sample.list M $outdir
Rscript $Bin/run.getAllCounts.R $workdir/sample.list M $outdir
echo `date` Rscript $Bin/run.getAllCounts.R $workdir/sample.list F $outdir
Rscript $Bin/run.getAllCounts.R $workdir/sample.list F $outdir

echo `date` Done 
