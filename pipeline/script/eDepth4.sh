#!/usr/bin/env bash
workdir=$1
pipeline=$2

outdir=$workdir/ExomeDepth
CNV_anno=$pipeline/CNV_anno

time $pipeline/perl \
    $CNV_anno/script/add_cn_split_gene.batch.pl \
    $outdir/all.CNV.calls.list \
    $outdir/sample.list.checked \
    $CNV_anno/database/database.gene.list.NM \
    $CNV_anno/database/gene_exon.bed \
    $CNV_anno/database/OMIM/OMIM.xls \
    $outdir/all.CNV.calls.anno