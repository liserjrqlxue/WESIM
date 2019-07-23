#!/usr/bin/env bash

workdir=$1
pipeline=$2
singleWorkdir=$3
proband=$4
father=$5
mother=$6

export PATH=$pipeline/tools:$PATH
cfg=$pipeline/config/config_BGI59M_CG_single.2019.pl
family=$pipeline/Family_anno/bin/family.plus.pl 
prefix=$Workdir/annotation/$sampleID

subdir=annotation
suffix=out.ACMG.updateFunc
qc=coverage/coverage.report
CNVkit=bwa/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls
exon=CNV.calls.anno
SMA=$singleWorkdir/SMA/SMA_v2.txt


echo `date` Start Trio

echo \
  perl \
  $family \
  -o $workdir/$proband.family.$suffix \
  $workdir/$proband/$subdir/$proband.$suffix \
  $workdir/$father/$subdir/$father.$suffix \
  $workdir/$mother/$subdir/$mother.$suffix \

time \
  perl \
  $family \
  -o $workdir/$proband.family.$suffix \
  $workdir/$proband/$subdir/$proband.$suffix \
  $workdir/$father/$subdir/$father.$suffix \
  $workdir/$mother/$subdir/$mother.$suffix \
&&echo `date` family merge done

echo `date` TrioAnno2Xlsx
  
anno2xlsx \
  -prefix $workdir/result/$proband \
  -wesim \
  -trio \
  -list $proband,$father,$mother \
  -snv $workdir/$proband.family.$suffix \
  -qc  $workdir/$proband/$qc,$workdir/$father/$qc,$workdir/$mother/$qc \
  -large $workdir/$proband/$CNVkit,$workdir/$father/$CNVkit,$workdir/$mother/$CNVkit \
  -exon $workdir/$proband/$proband.$exon,$workdir/$father/$father.$exon,$workdir/$mother/$mother.$exon \
  -smn $SMA \
&&echo `date` Done
