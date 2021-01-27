#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/bgiAnno.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH
cfg=$pipeline/config/config_BGI59M_CG_single.2019.pl
anno=$pipeline/bgi_anno/bin/bgicg_anno.pl
prefix=$Workdir/annotation/$sampleID

echo `date` Start Annotation

echo perl \
    $anno \
    $cfg \
    -t vcf -n 16 -b 20000 -q \
    -o $prefix.out \
    $Workdir/gatk/$sampleID.filter.vcf.gz

\time -v perl \
    $anno \
    $cfg \
    -t vcf -n 16 -b 20000 -q \
    -o $prefix.out \
    $Workdir/gatk/$sampleID.filter.vcf.gz

echo `date` Done

touch $complete
