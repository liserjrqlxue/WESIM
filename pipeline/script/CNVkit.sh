#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

bam=$workdir/$sampleID/bwa/$sampleID.bqsr.bam
export PATH=$pipeline/tools:$PATH
Workdir=$workdir/$sampleID/cnv
CNVkitControl=$pipeline/CNVkit/control/MGISEQ_2000_control/201906/MGISEQ-2000_201906

echo `date` Start CNVkitAnalyse
time perl \
  $pipeline/CNVkit/bin/analyse.pl \
  $CNVkitControl \
  $bam \
  cbs \
  $Workdir/$sampleID

echo `date` sh $Workdir/$sampleID.sh
time sh $Workdir/$sampleID.sh

echo `date` Start CNVkitAnnotation
cat $Workdir/$sampleID.gender > $Workdir/sample_gender.xls

time perl \
    $pipeline/CNVkit/bin/merge_result.pl \
    $Workdir/ \
    $Workdir/sample_gender.xls \
    $pipeline/CNVkit/bin/hg19_chM_male_mask.fa.fai \
    $Workdir

time perl \
    $pipeline/CNVkit/bin/merge_result_1K_withN.pl \
    $Workdir/CNVkit_cnv_raw.xls \
    $Workdir/sample_aneuploid.xls \
    $pipeline/CNVkit/bin/data/hg19.N_region \
    $pipeline/CNVkit/bin/data/hg19.cytoBand \
    $Workdir/CNVkit_cnv.xls

time perl \
    $pipeline/CNV_anno/script/add_gene_OMIM.pl \
    $Workdir/CNVkit_cnv.xls \
    $Workdir/CNVkit_cnv_gene.xls

time perl \
    $pipeline/CNV_anno/script/BGI_160.pl \
    $Workdir/CNVkit_cnv_gene.xls \
    $Workdir/sample_gender.xls \
    $Workdir/CNVkit_cnv_gene_BGI160.xls

time perl \
    $pipeline/CNV_anno/script/CNV_anno_Clinvar_Decipher.pl \
    $Workdir/CNVkit_cnv_gene_BGI160.xls \
    $Workdir/sample_gender.xls \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher.xls

time perl \
    $pipeline/CNV_anno/script/add_Clinvar_DGV_BGI45W.pl \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher.xls \
    $Workdir/sample_gender.xls \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher_DGV.xls

time perl \
    $pipeline/CNV_anno/script/add_Pathogenicity.pl \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher_DGV.xls \
    $Workdir/CNVkit_cnv_gene_BGI160_Decipher_DGV_Pathogenicity.xls
echo `date` Done
