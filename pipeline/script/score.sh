#!/bin/bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

export PATH=/home/uploader/anaconda3/bin:$PATH
source /home/uploader/anaconda3/etc/profile.d/conda.sh
conda activate base

echo `date` Start
mkdir -p $Workdir/score/inputData/file 
gzip -dc $Workdir/gatk/$sampleID.filter.vcf.gz > $Workdir/score/inputData/file/$sampleID.filter.vcf
for i in $workdir/result/$sampleID.*Tier1*.xlsx;do
  echo ln -sf $i $workdir/score/inputData/file/$sampleID.Tier1.xlsx 
  ln -sf $i $workdir/score/inputData/file/$sampleID.Tier1.xlsx 
done
echo 'HP:0000407,HP:0000405,HP:0001730' > $Workdir/score/inputData/file/hpo.txt
cat <<< "{\"input_files\":[\"$sampleID.Tier1.xlsx\",\"$sampleID.filter.vcf\"],\"action_type\":4,\"project_name\":\"test\",\"sample_name\":\"$sampleID\"}" >$Workdir/score/input.json

time python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $Workdir/score/input.json
xlsx2txt -xlsx $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx -prefix result/$sampleID.score.Tier1
echo `date` Done

