#!/bin/bash
source $(conda info --base)/etc/profile.d/conda.sh
conda activate wzh
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3
HPO=${4:-"HP:0000113,HP:0000356"}

complete=$workdir/$sampleID/shell/score.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

export PATH=$pipeline/tools:$PATH
export PYTHONPATH=$pipeline/sort-report/autopvs1:$PYTHONPATH
export PYTHONPATH=$pipeline/sort-report/auto_cnv:$PYTHONPATH
export PYTHONPATH=$pipeline/sort-report/wes-auto-report:$PYTHONPATH
export PYTHONPATH=$pipeline/sort-report/bio_toolkit:$PYTHONPATH
export PYTHONPATH=$pipelinesort-report/auto_prioritize:$PYTHONPATH

Workdir=$workdir/$sampleID
vcf=$Workdir/gatk/$sampleID.filter.vcf.gz
tier1=$Workdir/score/$sampleID.Tier1.xlsx
cnv=$workdir/CNVkit/CNVkit_cnv.xls
score=$Workdir/score

report=$pipeline/wes-auto-report/generate-report-add-intro.py


mkdir -p $score
for i in $Workdir/$sampleID.Tier1*.xlsx;do
  echo cp $i $tier1
  rm -rvf $tier1 && cp -v $i $tier1
done

complete1=$score/auuto_prioritize.complete
if [ -e "$complete1" ];then
	echo "$complete1 and skip"
else
	echo single variants sort
	echo \time -v \
		python \
		-m auto_prioritize \
		-hpo "$HPO" \
		-tier1 $tier1 \
		-sample_id $sampleID \
		-vcf $vcf \
		-cnv $cnv \
		-o $score

	\time -v \
		python \
		-m auto_prioritize \
		-hpo "$HPO" \
		-tier1 $tier1 \
		-sample_id $sampleID \
		-vcf $vcf \
		-cnv $cnv \
		-o $score
	touch $complete1
fi

echo `date` create appendix
echo `date` python3 $pipeline/wes-auto-report/generate-report.py $sampleID $workdir/sample.info $Workdir/score $workdir/result/$sampleID
python3 $pipeline/wes-auto-report/generate-report.py $sampleID $workdir/sample.info $Workdir/score $workdir/result/$sampleID \


echo `date` create $sampleID.reult.tsv
\time -v Tier1toResult -xlsx $Workdir/score/$sampleID.rank.xlsx -prefix $workdir/result/$sampleID/$sampleID

echo cp -v $Workdir/score/$sampleID.rank.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx 
cp -v $Workdir/score/$sampleID.rank.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx

echo xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx
\time -v xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx

echo `date` Done

touch $complete
