#!/bin/bash

workdir=$1
pipeline=$2
sampleID=$3
HPO=${4:-"HP:0000113,HP:0000356"}

complete=$workdir/$sampleID/shell/score.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

source /ifs7/B2C_RD_P2/USER/wangzhonghua/miniconda3/etc/profile.d/conda.sh
conda activate wes-sort-report
set -euo pipefail

export PYTHONPATH=/ifs7/B2C_RD_P2/USER/wangzhonghua/workspace/sort-report/autopvs1:$PYTHONPATH
export PYTHONPATH=/ifs7/B2C_RD_P2/USER/wangzhonghua/workspace/sort-report/auto_cnv:$PYTHONPATH
export PYTHONPATH=/ifs7/B2C_RD_P2/USER/wangzhonghua/workspace/sort-report/wes-auto-report:$PYTHONPATH
export PYTHONPATH=/ifs7/B2C_RD_P2/USER/wangzhonghua/workspace/sort-report/bio_toolkit:$PYTHONPATH
export PYTHONPATH=/ifs7/B2C_RD_P2/USER/wangzhonghua/workspace/sort-report/auto_prioritize:$PYTHONPATH




Workdir=$workdir/$sampleID
vcf=$Workdir/gatk/$sampleID.filter.vcf.gz
tier1=$Workdir/score/$sampleID.Tier1.xlsx
cnv=$workdir/CNVkit/CNVkit_cnv.xls
score=$Workdir/score

report=/ifs7/B2C_RD_P2/USER/wangzhonghua/miniconda3/envs/wes-sort-report/bin/cnvkit.py


mkdir -p $score
for i in $Workdir/$sampleID.Tier1*.xlsx;do
  echo cp $i $tier1
  rm -rvf $tier1 && cp -v $i $tier1
done

echo single variants sort
\time -v \
	python \
	-m auto_prioritize \
	-hpo "$HPO" \
	-tier1 $tier1 \
	-sample_id $sampleID \
	-vcf $vcf \
	-cnv $cnv \
	-o $score

echo single report
\time -v \
	python \
	$report \
	$score/$sampleID.info \
	$score
	$score

echo `date` create $sampleID.reult.tsv
\time -v Tier1toResult -xlsx $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx -prefix $workdir/result/$sampleID/$sampleID

echo cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx 
cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx

echo xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx
\time -v xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx

echo `date` Done

touch $complete
