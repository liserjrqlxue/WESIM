#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
Bin=$pipeline/ExomeDepth
Bam=$Workdir/bwa/$sampleID.bqsr.bam
outdir=$Workdir/bwa

grep "gender Male" $Workdir/coverage/gender.txt && gender=M||gender=F

echo `date` Start getBamCount
echo $sampleID gender:$gender
time Rscript $Bin/run.getBamCount.R $sampleID $Bam A       $outdir $Bin
time Rscript $Bin/run.getBamCount.R $sampleID $Bam $gender $outdir $Bin
echo `date` Done
