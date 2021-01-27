#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2

export PATH=$pipeline/tools:$PATH
getFinalQC=$pipeline/tools/getQC/get.final.QC.pl

echo `date` final QC
echo perl $getFinalQC $workdir/sample.info $workdir/result/standard.QC.txt $workdir
\time -v perl $getFinalQC $workdir/sample.info $workdir/result/standard.QC.txt $workdir

touch $workdir/shell/fQC.sh.complete
echo `date` Done
