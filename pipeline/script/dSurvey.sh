#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
Bin=$pipeline/bin
RegionDir=$pipeline/config/coverage_region_hg19_bychr/
Region=$RegionDir/for500_all_region
samtools=$pipeline/samtools
Bam2depths=$pipeline/bam2depths_shiquan_mgiseq2000.pl
UncoverdRegionSjt=$Bin/uncovered_region_sjt.pl
GenderCorrect=$pipeline/XY_gender_correct.pl

$samtools rmdup $Workdir/bwa/$sampleID.final.bam $Workdir/bwa/$sampleID.rmdup_final.bam
$samtools view -u $Workdir/bwa/$sampleID.final.bam chrX >$Workdir/bwa/chrX.sort.bam
$samtools view -u $Workdir/bwa/$sampleID.final.bam chrY >$Workdir/bwa/chrY.sort.bam
$pipeline/bamdst -p $Region --uncover 5 -o $Workdir/coverage $Workdir/bwa/$sampleID.final.bam
$Bam2depths --bamdir=$Workdir/bwa --region=$RegionDir --out=$Workdir/coverage --flank=100
$pipeline/Rscript $Bin/dis.R  $Workdir/coverage/dis_target.plot  $sampleID $workdir/graph_sigleBaseDepth/$sampleID_perBase.png
$pipeline/Rscript $Bin/cumn.R $Workdir/coverage/cumu_target.plot $sampleID $workdir/graph_sigleBaseDepth/$sampleID_Cumu.png
$pipeline/perl $UncoverdRegionSjt $RegionDir/all_region  $Workdir/coverage/target.detail $Workdir/coverage
$pipeline/gzip -f $Workdir/coverage/target.detail
$pipeline/perl $GenderCorrect $Workdir/coverage/chromosomes.report $Region