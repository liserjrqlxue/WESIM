#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

grep -P "$sampleID\tpass" $workdir/$sampleID/$sampleID.QC.txt || exit 0

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
Bin=$pipeline/ExomeDepth
Bam=$Workdir/bwa/$sampleID.bqsr.bam
outdir=$Workdir/cnv

echo `date` Start ExomeDepth $sampleID
mkdir -p $outdir

control=$pipeline/ExomeDepth/20190108_BGISEQ-50017SZ0000113_7/all

grep "gender Male" $Workdir/coverage/gender.txt && gender=M||gender=F
echo $sampleID gender:$gender
echo `date` Start getBamCount $sampleID
time Rscript $Bin/run.getBamCount.R $sampleID $Bam A       $outdir $Bin
time Rscript $Bin/run.getBamCount.R $sampleID $Bam $gender $outdir $Bin

echo `date` Start getCNVsFromControl $control
time Rscript $Bin/run.getCNVsFromControl.R $sampleID A       $outdir $control.A.my.count.rds
time Rscript $Bin/run.getCNVsFromControl.R $sampleID $gender $outdir $control.$gender.my.count.rds

CNV_anno=$pipeline/CNV_anno

echo `date` Start AnnoCNV
time perl \
  $CNV_anno/script/add_cn_split_gene.pl \
  $sampleID \
  $outdir/$sampleID.A.CNV.calls.tsv,$outdir/$sampleID.$gender.CNV.calls.tsv \
  $gender \
  $CNV_anno/database/database.gene.list.NM \
  $CNV_anno/database/gene_exon.bed \
  $CNV_anno/database/OMIM/OMIM.xls \
  $outdir/$sampleID.CNV.calls.anno.withoutHGMD
time perl \
  $CNV_anno/script/add_HGMD_gross.pl \
  $outdir/$sampleID.CNV.calls.anno.withoutHGMD \
  $CNV_anno/database/hgmd-gross_all-ex1-20190426.tsv \
  $outdir/$sampleID.CNV.calls.anno

echo `date` Done
