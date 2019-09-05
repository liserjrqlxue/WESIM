#!/usr/bin/env bash
workdir=$1
pipeline=$2

export PATH=$pipeline/tools:$PATH
getFinalQC=$pipeline/getQC/get.final.QC.pl

echo `date` final QC
echo perl $getFinalQC $workdir/sample.info $workdir/result/standard.QC.txt $workdir
perl $getFinalQC $workdir/sample.info $workdir/result/standard.QC.txt $workdir \
&& echo success \
|| { echo error;exit 1; }
echo `date` Done
