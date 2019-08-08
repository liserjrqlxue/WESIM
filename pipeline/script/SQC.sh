#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
StandardTag=$4

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

if [ $StandardTag == "Y" ];then
	echo -e "sampleID\tQC\n$sampleID\tPASS" > $workdir/standard.QC.txt
fi
