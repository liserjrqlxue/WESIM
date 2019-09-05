#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

grep -P "$sampleID\tpass" $workdir/$sampleID/$sampleID.QC.txt \
|| { echo `date` sample QC not pass, skip $0;exit 0; }

Workdir=$workdir/$sampleID/annotation
export PATH=$pipeline/tools:$PATH
func=$pipeline/bin/update.Function.pl
prefix=$Workdir/$sampleID

echo `date` Start UpdateFunction
time perl \
  $func \
  $prefix.out \
  >$prefix.out.updateFunc \
&& echo success \
|| { echo error;exit 1; }

echo `date` Done
