#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3
productCode=$4

complete=$workdir/$sampleID/shell/AppBQSR.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

function join_by {
	local IFS="$1";
	shift;
	echo "$*";
}

filterStat=()
for i in `find $Workdir/filter/*/*.filter.stat`;do
	filterStat+=($i)
done
filterStatJoin=$(join_by "," ${filterStat[@]})
echo $filterStatJoin

echo `date` Start anno2xlsx
\time -v anno2xlsx \
  -prefix    $Workdir/$sampleID \
  -snv       $Workdir/annotation/$sampleID.out.updateFunc \
  -qc        $Workdir/coverage/coverage.report \
  -large     $workdir/CNVkit/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls \
  -karyotype $workdir/CNVkit/sample_aneuploid.xls \
  -exon      $workdir/ExomeDepth/$sampleID.CNV.calls.anno \
  -smn       $Workdir/cnv/$sampleID.SMA_v2.txt \
  -filterStat $filterStatJoin \
  -wesim \
  -acmg \
  -redis -redisAddr 127.0.0.1:6380 \
  -list $sampleID \
  -product $productCode

echo cp -v $Workdir/$sampleID.qc.tsv $workdir/result/$sampleID/
cp -v $Workdir/$sampleID.qc.tsv $workdir/result/$sampleID/

echo `date` Done

touch $complete
