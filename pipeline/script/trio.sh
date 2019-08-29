#!/usr/bin/env bash

workdir=$1
pipeline=$2
singleWorkdir=$3
proband=$4
father=$5
mother=$6
HPO=$7

workdir=$singleWorkdir
grep -P "$proband\tpass" $workdir/result/$proband/$proband.QC.txt \
|| { echo `date` sample QC not pass, skip $0;exit 0; }
grep -P "$father\tpass"  $workdir/result/$father/$father.QC.txt   \
|| { echo `date` sample QC not pass, skip $0;exit 0; }
grep -P "$mother\tpass"  $workdir/result/$mother/$mother.QC.txt   \
|| { echo `date` sample QC not pass, skip $0;exit 0; }

Workdir=$workdir/$proband
export PATH=$pipeline/tools:$PATH
cfg=$pipeline/config/config_BGI59M_CG_single.2019.pl
family=$pipeline/Family_anno/bin/family.plus.pl

subdir=annotation
suffix=out.updateFunc
qc=coverage/coverage.report
CNVkit=cnv/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls
exon=CNV.calls.anno
SMA=SMA_v2.txt


echo `date` Start Trio

echo \
  perl \
  $family \
  -o $Workdir/$proband.family.$suffix \
  $workdir/$proband/$subdir/$proband.$suffix \
  $workdir/$father/$subdir/$father.$suffix \
  $workdir/$mother/$subdir/$mother.$suffix \

time \
  perl \
  $family \
  -o $Workdir/$proband.family.$suffix \
  $workdir/$proband/$subdir/$proband.$suffix \
  $workdir/$father/$subdir/$father.$suffix \
  $workdir/$mother/$subdir/$mother.$suffix \
&& echo success \
|| { echo error;exit 1; }

echo `date` TrioAnno2Xlsx

anno2xlsx \
  -prefix $Workdir/$proband \
  -wesim \
  -trio \
  -list $proband,$father,$mother \
  -snv $workdir/$proband/$proband.family.$suffix \
  -qc  $workdir/$proband/$qc,$workdir/$father/$qc,$workdir/$mother/$qc \
  -large $workdir/$proband/$CNVkit,$workdir/$father/$CNVkit,$workdir/$mother/$CNVkit \
  -exon $workdir/$proband/cnv/$proband.$exon,$workdir/$father/cnv/$father.$exon,$workdir/$mother/cnv/$mother.$exon \
  -smn $workdir/$proband/cnv/$proband.$SMA,$workdir/$father/cnv/$father.$SMA,$workdir/$mother/cnv/$mother.$SMA \
&& echo success \
|| { echo error;exit 1; }

echo `date` score for family $proband
sampleID=$proband
export PATH=/home/uploader/anaconda3/bin:$PATH
source /home/uploader/anaconda3/etc/profile.d/conda.sh
conda activate base

mkdir -p $Workdir/score/inputData/file
gzip -dc $Workdir/gatk/$sampleID.filter.vcf.gz > $Workdir/score/inputData/file/$sampleID.filter.vcf \
  && echo success \
  || { echo error;exit 1; }
for i in $Workdir/$sampleID.Tier1*.xlsx;do
  echo cp $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx
  rm -rvf $Workdir/score/inputData/file/$sampleID.Tier1.xlsx && cp -v $i $Workdir/score/inputData/file/$sampleID.Tier1.xlsx \
  && echo success \
  || { echo error;exit 1; }
done
echo $HPO > $Workdir/score/inputData/file/hpo.txt
cat <<< "{\"input_files\":[\"$sampleID.Tier1.xlsx\",\"$sampleID.filter.vcf\"],\"action_type\":4,\"project_name\":\"test\",\"sample_name\":\"$sampleID\"}" >$Workdir/score/input.json

echo `date` start score
time python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $Workdir/score/input.json \
&& echo success \
|| { echo error;exit 1; }

echo `date` create appendix
python3 $pipeline/wes-auto-report/generate-report.py $sampleID $workdir/sample.info $Workdir/score/outputData/file $workdir/result/$sampleID \
&& echo success \
|| { echo error;exit 1; }

echo `date` create $sampleID.reult.tsv
Tier1toResult -xlsx $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx -trio -prefix $workdir/result/$sampleID/$sampleID \
&& echo success \
|| { echo error;exit 1; }


echo `date` copy Tier1.xlsx and qc.tsv to result

echo cp -v $Workdir/$sampleID.qc.tsv $workdir/result/$sampleID/
cp -v $Workdir/$sampleID.qc.tsv $workdir/result/$sampleID/ \
|| { echo error;exit 1; }

echo cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx
cp -v $Workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx \
|| { echo error;exit 1; }

echo xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx
xlsx2txt -xlsx $workdir/result/$sampleID/$sampleID.score.Tier1.xlsx \
|| { echo error;exit 1; }
#done


echo `date` Done
