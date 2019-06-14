#!/usr/bin/env bash

workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
cfg=$pipeline/config/config_BGI59M_CG_single.2019.pl
anno=$pipeline/bgi_anno/bin/bgicg_anno.pl
acmg=$pipeline/acmg2015/bin/anno.acmg.pl
func=$pipeline/bin/update.Function.pl
prefix=$Workdir/annotation/$sampleID

echo `date` Start Annotation

time perl \
    $anno \
    $cfg \
    -t vcf -n 5 -b 500 -q \
    -o $prefix.out \
    $Workdir/gatk/$sampleID.final.vcf.gz

time perl \
    $acmg \
    $prefix.out \
    >$prefix.out.ACMG

time perl \
    $func \
    $prefix.out.ACMG \
    >$prefix.out.ACMG.updateFunc

echo `date` Done
