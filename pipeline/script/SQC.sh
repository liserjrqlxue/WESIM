#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3
chipCode=$4
StandardTag=${5:-N}

Workdir=$workdir/result
export PATH=$pipeline/tools:$PATH

if [ $StandardTag == "Y" ];then
	grep -P "$sampleID\tpass" $workdir/$sampleID/$sampleID.QC.txt && tag="PASS" || tag="FAIL"
	echo -e "$sampleID\t$tag\t$chipCode" >> $Workdir/standard.QC.txt 
fi

touch $workdir/$sampleID/shell/SQC.sh.complete
echo `date` Done
