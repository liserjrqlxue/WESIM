#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
chipCode=$4
StandardTag=${5:-N}

Workdir=$workdir/result
export PATH=$pipeline/tools:$PATH

if [ $StandardTag == "Y" ];then
	echo -e "$sampleID\t$chipCode\tPASS" >> $Workdir/standard.QC.txt \
	&& echo success \
	|| { echo error;exit 1; }
fi
