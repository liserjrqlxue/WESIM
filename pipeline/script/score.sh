#!/bin/bash
workdir=$1
pipeline=$2
sampleID=$3
HPO=$4

complete=$workdir/$sampleID/shell/score.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

export PATH=/home/uploader/anaconda3/bin:$PATH
source /home/uploader/anaconda3/etc/profile.d/conda.sh
conda activate base

echo `date` Start
mkdir -p $Workdir/score/inputData/file

gzip -dc $Workdir/gatk/$sampleID.filter.vcf.gz > $Workdir/score/inputData/file/$sampleID.filter.vcf

for i in $Workdir/$sampleID.Tier1*.xlsx;do
  echo cp $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx
  rm -rvf $Workdir/score/inputData/file/$sampleID.Tier1.xlsx && cp -v $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx
done

echo $HPO > $Workdir/score/inputData/file/hpo.txt 
cat <<< "{\"input_files\":[\"$sampleID.Tier1.xlsx\",\"$sampleID.filter.vcf\"],\"action_type\":4,\"project_name\":\"test\",\"sample_name\":\"$sampleID\"}" >$Workdir/score/input.json

echo `date` python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $Workdir/score/input.json
\time -v python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $Workdir/score/input.json

echo `date` create appendix
echo `date` python3 $pipeline/wes-auto-report/generate-report.py $sampleID $workdir/sample.info $Workdir/score/outputData/file $workdir/result/$sampleID
\time -v python3 $pipeline/wes-auto-report/generate-report.py $sampleID $workdir/sample.info $Workdir/score/outputData/file $workdir/result/$sampleID

echo `date` create $sampleID.reult.tsv
\time -v Tier1toResult -xlsx $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx -prefix $workdir/result/$sampleID/$sampleID

echo cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx 
cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx


echo xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx
\time -v xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx

echo `date` Done

touch $complete
