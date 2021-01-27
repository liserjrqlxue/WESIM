#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
input=$workdir/input.list

complete=$workdir/shell/eDepth_batch.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

export PATH=$pipeline/tools:$PATH
Bin=$pipeline/ExomeDepth
outdir=$workdir/ExomeDepth
mkdir -p $outdir

echo `date` Start ExomeDepth 
mkdir -p $outdir

\time -v perl $Bin/createScript.batch.pl $workdir $input $outdir
cd $outdir
\time -v sh $outdir/run.sh

echo `date` Done

touch $complete
