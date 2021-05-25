#!/usr/bin/env bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate cnvkit
set -euo pipefail
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/plotCNVkitChr.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/result/$sampleID
export PATH=$pipeline/tools:$PATH

outDir=$Workdir/cnv_chr_graph
prefix=$outDir/$sampleID.chr
vcf=$workdir/$sampleID/gatk/$sampleID.vcf.vcf.gz

mkdir -p $outDir

cns=$(find $workdir/CNVkit/ -name $sampleID.cbs.cns)
cnr=$(find $workdir/CNVkit/ -name $sampleID.cnr    )

echo `seq 22` X Y|sed 's| |\n|g'|gargs -p 8 -l $outDir/log -v "cnvkit.py scatter -c chr{0} -s $cns $cnr -o $prefix{0}_vcf.pdf -v $vcf"

tail -n1 $outDir/log|grep -w SUCCESS

echo `date` Done

touch $complete
