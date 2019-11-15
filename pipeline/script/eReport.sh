#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3
productCode=$4

grep -P "$sampleID\tpass" $workdir/$sampleID/$sampleID.QC.txt \
|| { echo `date` sample QC not pass, skip $0;exit 0; }

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
time anno2xlsx \
  -prefix    $Workdir/$sampleID \
  -snv       $Workdir/annotation/$sampleID.out.updateFunc \
  -qc        $Workdir/coverage/coverage.report \
  -large     $Workdir/cnv/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls \
  -karyotype $Workdir/cnv/sample_aneuploid.xls \
  -exon      $Workdir/cnv/$sampleID.CNV.calls.anno \
  -smn       $Workdir/cnv/$sampleID.SMA_v2.txt \
  -filterStat $filterStatJoin \
  -wesim \
  -acmg \
  -redis -redisAddr 127.0.0.1:6380 \
  -list $sampleID \
  -product $productCode \
  -specVarList $pipeline/spec.var.lite.list \
&& echo success \
|| { echo error;exit 1; }

echo cp -v $Workdir/$sampleID.qc.tsv $workdir/result/$sampleID/
cp -v $Workdir/$sampleID.qc.tsv $workdir/result/$sampleID/ \
|| { echo error;exit 1; }

echo `date` Done
