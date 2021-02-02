#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/CNVkit_call.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

export PATH=$pipeline/tools:$PATH
source /home/bgi902/miniconda3/etc/profile.d/conda.sh
conda activate wzh
set -euo pipefail

genderFix=$pipeline/CNVkit/bin/gender_fix.pl
Workdir=$workdir/CNVkit

perl \
	$genderFix \
	$Workdir/$sampleID \
	$Workdir/$sampleID.gender \
	$Workdir/Control/CNVkitControl \
	$Workdir/$sampleID.fix.sh

\time -v \
	sh $Workdir/$sampleID.fix.sh \
	1> $Workdir/$sampleID.fix.sh.o \
	2> $Workdir/$sampleID.fix.sh.e 

echo \time -v \
        cnvkit.py \
	segment \
	-m cbs \
	-p 12 \
	$Workdir/$sampleID.cnr \
	-o $Workdir/$sampleID.cbs.cns

\time -v \
        cnvkit.py \
	segment \
	-m cbs \
	-p 12 \
	$Workdir/$sampleID.cnr \
	-o $Workdir/$sampleID.cbs.cns

echo \time -v \
	cnvkit.py \
	segmetrics \
	$Workdir/$sampleID.cnr \
	-s $Workdir/$sampleID.cbs.cns \
	--sem --ci \
	-o $Workdir/$sampleID.cbs.segmetrics.cns

\time -v \
	cnvkit.py \
	segmetrics \
	$Workdir/$sampleID.cnr \
	-s $Workdir/$sampleID.cbs.cns \
	--sem --ci \
	-o $Workdir/$sampleID.cbs.segmetrics.cns

echo \time -v \
	cnvkit.py \
	call \
	--filter cn \
	$Workdir/$sampleID.cbs.segmetrics.cns \
	-o $Workdir/$sampleID.cbs.call.cns

\time -v \
	cnvkit.py \
	call \
	--filter cn \
	$Workdir/$sampleID.cbs.segmetrics.cns \
	-o $Workdir/$sampleID.cbs.call.cns

echo `date` Done

touch $complete
