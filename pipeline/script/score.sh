#!/bin/bash
workdir=$1
pipeline=$2
sampleID=$3
HPO=$4

grep -P "$sampleID\tpass" $workdir/result/$sampleID/$sampleID.QC.txt \
|| { echo `date` sample QC not pass, skip $0;exit 0; }

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

export PATH=/home/uploader/anaconda3/bin:$PATH
source /home/uploader/anaconda3/etc/profile.d/conda.sh
conda activate base

echo `date` Start
mkdir -p $Workdir/score/inputData/file \
  || { echo error;exit 1; }
gzip -dc $Workdir/gatk/$sampleID.filter.vcf.gz > $Workdir/score/inputData/file/$sampleID.filter.vcf \
  || { echo error;exit 1; }
for i in $Workdir/$sampleID.Tier1*.xlsx;do
  echo cp $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx
  rm -rvf $Workdir/score/inputData/file/$sampleID.Tier1.xlsx && cp -v $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx \
    || { echo error;exit 1; }
done
echo $HPO > $Workdir/score/inputData/file/hpo.txt \
  || { echo error;exit 1; }
cat <<< "{\"input_files\":[\"$sampleID.Tier1.xlsx\",\"$sampleID.filter.vcf\"],\"action_type\":4,\"project_name\":\"test\",\"sample_name\":\"$sampleID\"}" >$Workdir/score/input.json \
  || { echo error;exit 1; }

echo `date` python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $Workdir/score/input.json
python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $Workdir/score/input.json \
  && echo success \
  || { echo error;exit 1; }

echo `date` python3 $pipeline/wes-auto-report/generate-report.py $sampleID $workdir/sample.info $Workdir/score/outputData/file $workdir/result/$sampleID
python3 $pipeline/wes-auto-report/generate-report.py $sampleID $workdir/sample.info $Workdir/score/outputData/file $workdir/result/$sampleID \
  && echo success \
  || { echo error;exit 1; }

echo cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx 
cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx \
  || { echo error;exit 1; }


echo xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx
xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx \
  || { echo error;exit 1; }

echo `date` Done
