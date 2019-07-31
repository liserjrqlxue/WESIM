#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

grep -P "$sampleID\tpass" $workdir/$sampleID/$sampleID.QC.txt || exit 0

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

hg19=$pipeline/hg19/hg19_chM_male_mask.fa
bed=$pipeline/SMA_WES/PP100.gene.info.bed
control=$pipeline/SMA_WES/SMA_v2.txt.control_gene.csv

mkdir -p $Workdir/cnv
echo `date` Start samtoolsBedcov
echo -e "Chr\tStart\tEnd\tStrand\tGene\tExon\tTrans\tPrimarytag\tGenelength\t${sampleID}_total_cvg" > $Workdir/cnv/$sampleID.bqsr.bam.bedcov
time samtools \
  bedcov \
  $bed \
  $Workdir/bwa/$sampleID.bqsr.bam \
  >> $Workdir/cnv/$sampleID.bqsr.bam.bedcov \
  && echo success || echo error

echo `date` Start samtoolsDepth
echo -e "Chr\tPos\tDepth_for_${sampleID}" >$Workdir/cnv/$sampleID.bqsr.bam.depth
time samtools \
  depth -aa \
  -b $bed \
  $Workdir/bwa/$sampleID.bqsr.bam \
  >> $Workdir/cnv/$sampleID.bqsr.bam.depth \
  && echo success || echo error

echo `date` Start SMA
time python2 $pipeline/SMA_WES/v1/SMN_copy_number_detection_v3.single.py \
  -b $pipeline/SMA_WES/PP100.gene.info.bed \
  -o $Workdir/cnv/$sampleID.SMA_v2.txt \
  -l $Workdir/cnv/$sampleID.bqsr.bam.depth \
  -c $control \
  && echo success || echo error

echo `date` Done
