#!/bin/bash
workdir=$1
pipeline=$2
sampleID=$3
HPO=$4

grep -P "$sampleID\tpass" $workdir/$sampleID/$sampleID.QC.txt || exit 0

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

export PATH=/home/uploader/anaconda3/bin:$PATH
source /home/uploader/anaconda3/etc/profile.d/conda.sh
conda activate base

echo `date` Start
mkdir -p $Workdir/score/inputData/file
gzip -dc $Workdir/gatk/$sampleID.filter.vcf.gz > $Workdir/score/inputData/file/$sampleID.filter.vcf
for i in $workdir/result/$sampleID.*Tier1*.xlsx;do
  echo ln -sf $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx
  ln -sf $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx
done
echo $HPO > $Workdir/score/inputData/file/hpo.txt
cat <<< "{\"input_files\":[\"$sampleID.Tier1.xlsx\",\"$sampleID.filter.vcf\"],\"action_type\":4,\"project_name\":\"test\",\"sample_name\":\"$sampleID\"}" >$Workdir/score/input.json

echo `date` score
time python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $Workdir/score/input.json \
  && echo success || echo error
time xlsx2txt -xlsx $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx -prefix $workdir/result/$sampleID.score.Tier1 \
  && echo success || echo error
echo `date` Done
