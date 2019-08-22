#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

grep -P "$sampleID\tpass" $workdir/result/$sampleID/$sampleID.QC.txt \
|| { echo `date` sample QC not pass, skip $0;exit 0; }

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
cfg=$pipeline/config/config_BGI59M_CG_single.2019.pl
anno=$pipeline/bgi_anno/bin/bgicg_anno.pl
prefix=$Workdir/annotation/$sampleID

echo `date` Start Annotation

time perl \
    $anno \
    $cfg \
    -t vcf -n 13 -b 10000 -q \
    -o $prefix.out \
    $Workdir/gatk/$sampleID.filter.vcf.gz \
&& echo success \
|| { echo error;exit 1; }

echo `date` Done
