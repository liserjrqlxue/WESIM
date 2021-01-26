#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
input=$workdir/input.list

complete=$workdir/shell/CNVkit_batch.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

export PATH=$pipeline/tools:$PATH
CNVkitControl=$pipeline/CNVkit/control/MGISEQ_2000_control/201906/MGISEQ-2000_201906
Workdir=$workdir/CNVkit
mkdir -p $Workdir
mkdir -p $Workdir/Control
mkdir -p $Workdir/Control/Male
mkdir -p $Workdir/Control/Female
cnvkitControl=$Workdir/Control/CNVkitControl
ln -sf $CNVkitControl.targets.bed $cnvkitControl.targets.bed
ln -sf $CNVkitControl.antitargets.bed $cnvkitControl.antitargets.bed
ln -sf $CNVkitControl\_Male.targets.bed $cnvkitControl\_Male.targets.bed
ln -sf $CNVkitControl\_Male.antitargets.bed $cnvkitControl\_Male.antitargets.bed
ln -sf $CNVkitControl\_Female.targets.bed $cnvkitControl\_Female.targets.bed
ln -sf $CNVkitControl\_Female.antitargets.bed $cnvkitControl\_Female.antitargets.bed

echo `date` Start CNVkitAnalyse
\time -v perl \
  $pipeline/CNVkit/bin/analyse_batch.pl \
  $CNVkitControl \
  $input \
  cbs \
  $workdir \
  $Workdir

echo `date` sh $Workdir/CNVkit.sh
\time -v sh $Workdir/CNVkit.sh

echo `date` Start CNVkitAnnotation
cat $Workdir/*.gender > $Workdir/sample_gender.xls

\time -v perl \
    $pipeline/CNVkit/bin/merge_result.pl \
    $Workdir/ \
    $Workdir/sample_gender.xls \
    $pipeline/CNVkit/bin/hg19_chM_male_mask.fa.fai \
    $Workdir

\time -v perl \
    $pipeline/CNVkit/bin/merge_result_1K_withN.pl \
    $Workdir/CNVkit_cnv_raw.xls \
    $Workdir/sample_aneuploid.xls \
    $pipeline/CNVkit/bin/data/hg19.N_region \
    $pipeline/CNVkit/bin/data/hg19.cytoBand \
    $Workdir/CNVkit_cnv.xls

\time -v perl \
    $pipeline/CNV_anno/script/add_gene_OMIM.pl \
    $Workdir/CNVkit_cnv.xls \
    $Workdir/CNVkit_cnv_gene.xls

\time -v perl \
    $pipeline/CNV_anno/script/BGI_160.pl \
    $Workdir/CNVkit_cnv_gene.xls \
    $Workdir/sample_gender.xls \
    $Workdir/CNVkit_cnv_gene_BGI160.xls

\time -v perl \
    $pipeline/CNV_anno/script/CNV_anno_Clinvar_Decipher.pl \
    $Workdir/CNVkit_cnv_gene_BGI160.xls \
    $Workdir/sample_gender.xls \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher.xls

\time -v perl \
    $pipeline/CNV_anno/script/add_Clinvar_DGV_BGI45W.pl \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher.xls \
    $Workdir/sample_gender.xls \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher_DGV.xls

\time -v perl \
    $pipeline/CNV_anno/script/add_Pathogenicity.pl \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher_DGV.xls \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls

echo `date` Done

touch $complete
