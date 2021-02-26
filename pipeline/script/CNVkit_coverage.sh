#!/usr/bin/env bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate cnvkit
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/CNVkit_coverage.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

export PATH=$pipeline/tools:$PATH

CNVkitControl=$pipeline/CNVkit/control/MGISEQ_2000_control/201906/MGISEQ-2000_201906
genderCoverage=$pipeline/CNVkit/bin/gender_coverage.pl 
targetsBed=$CNVkitControl.targets.bed
antitargetsBed=$CNVkitControl.antitargets.bed
Workdir=$workdir/CNVkit
mkdir -p $Workdir

bam=$workdir/$sampleID/bwa/$sampleID.bqsr.bam

\time -v \
	cnvkit.py \
	coverage \
	-p 12 \
	$bam \
	$targetsBed \
	-o $Workdir/$sampleID.targetcoverage.cnn
	#-o $bam.targetcoverage.cnn \

\time -v \
	cnvkit.py \
	coverage \
	-p 12 \
	$bam \
	$antitargetsBed \
	-o $Workdir/$sampleID.antitargetcoverage.cnn
	#-o $bam.antitargetcoverage.cnn \

perl \
	$genderCoverage \
	$Workdir/$sampleID.antitargetcoverage.cnn \
	$Workdir/$sampleID.gender 

echo `date` Done

touch $complete
