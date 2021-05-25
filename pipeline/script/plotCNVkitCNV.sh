#!/usr/bin/env bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate cnvkit
set -euo pipefail
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/plotCNVkitCNV.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/result/$sampleID
export PATH=$pipeline/tools:$PATH

outDir=$Workdir/cnv_area_graph
prefix=$outDir/$sampleID
lst=$Workdir/$sampleID.score.Tier1.xlsx.large_cnv.txt
vcf=$workdir/$sampleID/gatk/$sampleID.vcf.vcf.gz

mkdir -p $outDir



cns=$(find $workdir/CNVkit/ -name $sampleID.cbs.cns)
cnr=$(find $workdir/CNVkit/ -name $sampleID.cnr    )

grep -v SMN $lst|awk 'NR>1&&$4>1000000{print $2,$3,$4}'|gargs -p 8 -l $outDir/log -v "cnvkit.py scatter -c {0}:{1}-{2} -s $cns $cnr -o $prefix.{0}-{1}-{2}.pdf -v $vcf"

tail -n1 $outDir/log|grep -w SUCCESS

echo `date` Done

touch $complete
