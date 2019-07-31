#!/usr/bin/env bash

workdir=$1
pipeline=$2
singleWorkdir=$3
proband=$4
father=$5
mother=$6
HPO=$7

grep -P "$proband\tpass" $workdir/$proband/$proband.QC.txt || exit 0
grep -P "$father\tpass"  $workdir/$father/$father.QC.txt   || exit 0
grep -P "$mother\tpass"  $workdir/$mother/$mother.QC.txt   || exit 0

export PATH=$pipeline/tools:$PATH
cfg=$pipeline/config/config_BGI59M_CG_single.2019.pl
family=$pipeline/Family_anno/bin/family.plus.pl

subdir=annotation
suffix=out.ACMG.updateFunc
qc=coverage/coverage.report
CNVkit=cnv/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls
exon=CNV.calls.anno
SMA=SMA_v2.txt


echo `date` Start Trio

echo \
  perl \
  $family \
  -o $workdir/$proband.family.$suffix \
  $workdir/$proband/$subdir/$proband.$suffix \
  $workdir/$father/$subdir/$father.$suffix \
  $workdir/$mother/$subdir/$mother.$suffix \

time \
  perl \
  $family \
  -o $workdir/$proband.family.$suffix \
  $workdir/$proband/$subdir/$proband.$suffix \
  $workdir/$father/$subdir/$father.$suffix \
  $workdir/$mother/$subdir/$mother.$suffix \
&&echo `date` family merge done

echo `date` TrioAnno2Xlsx

anno2xlsx \
  -prefix $workdir/result/$proband \
  -wesim \
  -trio \
  -list $proband,$father,$mother \
  -snv $workdir/$proband.family.$suffix \
  -qc  $workdir/$proband/$qc,$workdir/$father/$qc,$workdir/$mother/$qc \
  -large $workdir/$proband/$CNVkit,$workdir/$father/$CNVkit,$workdir/$mother/$CNVkit \
  -exon $workdir/$proband/cnv/$proband.$exon,$workdir/$father/cnv/$father.$exon,$workdir/$mother/cnv/$mother.$exon \
  -smn $workdir/$proband/cnv/$proband.$SMA,$workdir/$father/cnv/$father.$SMA,$workdir/$mother/cnv/$mother.$SMA \
&& echo success || echo error

for i in $workdir/result/$preoband.*Tier1*xlsx $workdir/result/$preoband.*Tier2*xlsx;do
  echo xlsx2txt -xlsx $i
  xlsx2txt -xlsx $i
done


echo `date` score for family
sampleID=$proband
export PATH=/home/uploader/anaconda3/bin:$PATH
source /home/uploader/anaconda3/etc/profile.d/conda.sh
conda activate base

mkdir -p $workdir/score/inputData/file
gzip -dc $workdir/$proband/gatk/$sampleID.filter.vcf.gz > $Workdir/score/inputData/file/$sampleID.filter.vcf
for i in $workdir/result/$sampleID.*Tier1*.xlsx;do
  echo ln -sf $i $workdir/score/inputData/file/$sampleID.Tier1.xlsx
  ln -sf $i $workdir/score/inputData/file/$sampleID.Tier1.xlsx
done
echo $HPO > $workdir/score/inputData/file/hpo.txt
cat <<< "{\"input_files\":[\"$sampleID.Tier1.xlsx\",\"$sampleID.filter.vcf\"],\"action_type\":4,\"project_name\":\"test\",\"sample_name\":\"$sampleID\"}" >$workdir/score/input.json

time python /home/uploader/uploader-WES/score/sample_score/run_three_uploader.py -i $workdir/score/input.json
xlsx2txt -xlsx $workdir/score/outputData/file/Result_new_$sampleID.Tier1.xlsx -prefix result/$sampleID.score.Tier1
echo `date` Done
