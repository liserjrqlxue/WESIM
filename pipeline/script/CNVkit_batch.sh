#!/usr/bin/env bash

workdir=$1
pipeline=$2
input=$workdir/input.list

complete=$workdir/shell/CNVkit_batch.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

export PATH=$pipeline/tools:$PATH
source /home/bgi902/miniconda3/etc/profile.d/conda.sh
conda activate wzh
set -euo pipefail
batchControl=$pipeline/CNVkit/bin/batch_control.pl
ref=$pipeline/CNVkit/bin/data/hg19_chM_male_mask.fa
CNVkitControl=$pipeline/CNVkit/control/MGISEQ_2000_control/201906/MGISEQ-2000_201906
Workdir=$workdir/CNVkit

mkdir -p $Workdir/Control
mkdir -p $Workdir/Control/Male
mkdir -p $Workdir/Control/Female
cnvkitControl=$Workdir/Control/CNVkitControl
ln -sf $CNVkitControl.targets.bed $cnvkitControl.targets.bed
ln -sf $CNVkitControl.antitargets.bed $cnvkitControl.antitargets.bed
ln -sf $CNVkitControl\_Male.targets.bed $cnvkitControl\_Male.targets.bed
ln -sf $CNVkitControl\_Male.antitargets.bed $cnvkitControl\_Male.antitargets.bed
ln -sf $CNVkitControl\_Female.targets.bed $cnvkitControl\_Female.targets.bed
ln -sf $CNVkitControl\_Female.antitargets.bed $cnvkitControl\_Female.antitargets.bed

echo perl \
	$batchControl \
	$input \
	$ref \
	$Workdir \
	$Workdir/Control \
	$cnvkitControl

perl \
	$batchControl \
	$input \
	$ref \
	$Workdir \
	$Workdir/Control \
	$cnvkitControl

echo \time -v \
	sh \
	$Workdir/Control/CNVkit_control.sh \
	1>$Workdir/Control/CNVkit_control.sh.o \
	2>$Workdir/Control/CNVkit_control.sh.e \

\time -v \
	sh \
	$Workdir/Control/CNVkit_control.sh \
	1>$Workdir/Control/CNVkit_control.sh.o \
	2>$Workdir/Control/CNVkit_control.sh.e \

echo `date` Done

touch $complete
