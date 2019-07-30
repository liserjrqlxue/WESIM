#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID/annotation
export PATH=$pipeline/tools:$PATH
acmg=$pipeline/acmg2015/bin/anno.acmg.pl
func=$pipeline/bin/update.Function.pl
prefix=$Workdir/$sampleID

echo `date` Start ACMG2015V1
time perl \
  $acmg \
  $prefix.out \
  >$prefix.out.ACMG \
  && echo success || echo error

echo `date` Start UpdateFunction
time perl \
  $func \
  $prefix.out.ACMG \
  >$prefix.out.ACMG.updateFunc \
  && echo success || echo error

echo `date` Done
