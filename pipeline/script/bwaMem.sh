#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3
laneName=$4

complete=$workdir/$sampleID/shell/bwaMem.$laneName.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
hg19=$pipeline/hg19/hg19_chM_male_mask.fa
echo `date` Start bwaMem
\time -v bwa \
    mem -K 100000000 -t 8 -M \
    -R "@RG\tID:$sampleID\tSM:$sampleID\tLB:$laneName\tPL:COMPLETE" \
    $hg19 \
    $Workdir/filter/$laneName/$sampleID.$laneName.filter_1.fq.gz \
    $Workdir/filter/$laneName/$sampleID.$laneName.filter_2.fq.gz \
    | samtools view -S -b \
    -o $Workdir/bwa/$sampleID.raw.$laneName.bam \
    - 

rm -rvf $Workdir/filter/$laneName/$sampleID.$laneName.filter_{1,2}.fq.gz

echo `date` Done

touch $complete
