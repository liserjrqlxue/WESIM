#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/AppBQSR.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID/bwa
export PATH=$pipeline/tools:$PATH

hg19=$pipeline/hg19/hg19_chM_male_mask.fa

echo `date` Start ApplyBQSR $sampleID

\time -v gatk \
  ApplyBQSR \
  --tmp_dir $workdir/javatmp \
  -R $hg19 \
  -I $Workdir/$sampleID.dup.bam \
  -O $Workdir/$sampleID.bqsr.bam \
  --create-output-bam-index \
  -bqsr $Workdir/$sampleID.recal_data.grp 

rm -rvf $Workdir/$sampleID.dup.bam 

echo `date` Done

touch $complete
