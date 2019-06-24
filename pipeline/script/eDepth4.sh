#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
gender=$4

export PATH=$pipeline/tools:$PATH
CNV_anno=$pipeline/CNV_anno
Bin=$pipeline/ExomeDepth
outdir=$workdir/ExomeDepth
gender=$gender

echo `date` Start ExomeDepth4
time perl \
    $CNV_anno/script/add_cn_split_gene.pl \
    $sampleID \
    $outdir/$sampleID.A.CNV.calls.tsv \
    $gender \
    $CNV_anno/database/database.gene.list.NM \
    $CNV_anno/database/gene_exon.bed \
    $CNV_anno/database/OMIM/OMIM.xls \
    $workdir/$sampleID/$sampleID.CNV.calls.anno
echo `date` Done
