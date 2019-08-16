#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

grep -P "$sampleID\tpass" $workdir/$sampleID/$sampleID.QC.txt || exit 0

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
prefix=$Workdir/annotation/$sampleID

echo `date` Start anno2xlsx
time anno2xlsx \
  -prefix $workdir/result/$sampleID \
  -snv $prefix.out.updateFunc \
  -qc  $Workdir/coverage/coverage.report \
  -large $Workdir/cnv/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls \
  -exon $Workdir/cnv/$sampleID.CNV.calls.anno \
  -smn $Workdir/cnv/$sampleID.SMA_v2.txt \
  -wesim \
  -acmg \
  -list $sampleID \
  && echo success || echo error

for i in $workdir/result/$sampleID.*Tier1*xlsx $workdir/result/$sampleID.*Tier2*xlsx;do
  echo `date` xlsx2txt -xlsx $i
  time xlsx2txt -xlsx $i \
    && echo success || echo error
done

echo `date` Done
