#!/usr/bin/env bash
conda activate cnvkit
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/SMA.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

hg19=$pipeline/hg19/hg19_chM_male_mask.fa
bed=$pipeline/SMA_WES/PP100.gene.info.bed
control=$pipeline/SMA_WES/SMA_v2.txt.control_gene.csv

mkdir -p $Workdir/cnv

echo `date` Start samtoolsBedcov
if [ ! -s "$Workdir/cnv/$sampleID.bqsr.bam.bedcov" ];then
	echo -e "Chr\tStart\tEnd\tStrand\tGene\tExon\tTrans\tPrimarytag\tGenelength\t${sampleID}_total_cvg" > $Workdir/cnv/$sampleID.bqsr.bam.bedcov

	\time -v samtools \
	  bedcov \
	  $bed \
	  $Workdir/bwa/$sampleID.bqsr.bam \
	  >> $Workdir/cnv/$sampleID.bqsr.bam.bedcov
fi

echo `date` Start samtoolsDepth
if [ ! -s "$Workdir/cnv/$sampleID.bqsr.bam.depth" ];then
	echo -e "Chr\tPos\tDepth_for_${sampleID}" >$Workdir/cnv/$sampleID.bqsr.bam.depth

	\time -v samtools \
	  depth -aa \
	  -b $bed \
	  $Workdir/bwa/$sampleID.bqsr.bam \
	  >> $Workdir/cnv/$sampleID.bqsr.bam.depth
fi

echo `date` Start SMA

\time -v python3 $pipeline/SMA_WES/SMN_copy_number_detection_v3.single.py \
  -b $pipeline/SMA_WES/PP100.gene.info.bed \
  -o $Workdir/cnv/$sampleID.SMA_v2.txt \
  -l $Workdir/cnv/$sampleID.bqsr.bam \
  -c $control

echo `date` Done

touch $complete
