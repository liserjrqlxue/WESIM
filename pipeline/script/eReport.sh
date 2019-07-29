#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
prefix=$Workdir/annotation/$sampleID

echo `date` Start anno2xlsx
anno2xlsx \
  -prefix $workdir/result/$sampleID \
  -snv $prefix.out.ACMG.updateFunc \
  -qc  $Workdir/coverage/coverage.report \
  -large $Workdir/cnv/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls \
  -exon $Workdir/cnv/$sampleID.CNV.calls.anno \
  -smn $Workdir/cnv/$sampleID.SMA_v2.txt 
  -wesim \
  -list $sampleID \

for i in $workdir/result/$preoband.*Tier1*xlsx $workdir/result/$preoband.*Tier2*xlsx;do
  echo xlsx2txt -xlsx $i
  xlsx2txt -xlsx $i
done

echo `date` Done
