#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
func=$pipeline/bin/update.Function.pl
prefix=$Workdir/annotation/$sampleID

echo `date` Start UpdateFunction

time perl \
  $func \
  $prefix.out.ACMG \
  >$prefix.out.ACMG.updateFunc \
  && echo success || echo error

echo `date` Done
