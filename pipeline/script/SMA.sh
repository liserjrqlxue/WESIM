#!/usr/bin/env bash
workdir=$1
pipeline=$2

Workdir=$workdir/SMA
control=/ifs7/B2C_SGD/PROJECT/PP12_Project/ExomeDepth/workspace/SMA_WES/SMA_v2.txt.control_gene.csv

time sh \
    $pipeline/SMA_WES/Depthofcoverage_gene_SZ.sh \
    $workdir/bam.list \
    $pipeline/SMA_WES/PP100.gene.info.bed \
    $Workdir/coverage_v2

    ls $Workdir/coverage_v2 >$Workdir/coverage.list

time $pipeline/python \
    $pipeline/SMA_WES/SMN_copy_number_detection_v3.py \
    -b $pipeline/SMA_WES/PP100.gene.info.bed \
    -o $Workdir/SMA_v2.txt \
    -c $control \
    -l $Workdir/coverage.list

time $pipeline/python \
    $pipeline/SMA_WES/SMN_copy_number_detection_v3.py \
    -b $pipeline/SMA_WES/PP100.gene.info.bed \
    -o $Workdir/SMA_v2.noControl.txt \
    -l $Workdir/coverage.list