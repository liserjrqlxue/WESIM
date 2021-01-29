#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/CNVkit_call.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

export PATH=$pipeline/tools:$PATH
export PATH=/share/backup/zhongwenwei/app/R-3.2.1/bin:$PATH
export R_LIBS_USER=/share/backup/zhongwenwei/app/R-3.2.1/library
export PATH=/share/backup/zhongwenwei/app/Python-2.7.13/bin:$PATH
export CPATH=/share/backup/zhongwenwei/app/Python-2.7.13/include:$CPATH
export LD_LIBRARY_PATH=/share/backup/zhongwenwei/app/Python-2.7.13/lib:$LD_LIBRARY_PATH
export PYTHONIOENCODING=UTF-8

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

\time -v \
        cnvkit.py \
	segment \
	-m cbs \
	-p 12 \
	$Workdir/$sampleID.cnr \
	-o $Workdir/$sampleID.cbs.cns

\time -v \
	cnvkit.py \
	segmetrics \
	$Workdir/$sampleID.cnr \
	-s $Workdir/$sampleID.cbs.cns \
	--sem --ci \
	-o $Workdir/$sampleID.cbs.segmetrics.cns

\time -v \
	cnvkit.py \
	call \
	--filter cn \
	$Workdir/$sampleID.cbs.segmetrics.cns \
	-o $Workdir/$sampleID.cbs.call.cn

echo `date` Done

touch $complete
