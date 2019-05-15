#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
cfg=$pipeline/config/config_BGI59M_CG_single.2019.pl
anno=$pipeline/bin/bgicg_anno.pl
acmg=$pipeline/bin/anno.acmg.pl
func=$pipeline/update.Function.pl
prefix=$Workdir/annotation/$sampleID

time $pipeline/perl \
    $anno \
    $cfg \
    -t vcf -n 5 -b 500 -q \
    -o $prefix.out \
    $Workdir/gatk/$sampleID.final.vcf.gz

time $pipeline/perl \
    $acmg \
    $prefix.out \
    >$prefix.out.ACMG

time $pipeline/perl \
    $func \
    $prefix.out.ACMG \
    >$prefix.out.ACMG.updateFunc