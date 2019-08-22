#!/usr/bin/env bash
workdir=$1
pipeline=$2
sampleID=$3

Workdir=$workdir/$sampleID
export PATH=$pipeline/tools:$PATH

#Bin=$pipeline/bin
#UncoverdRegionSjt=$Bin/uncovered_region_sjt.pl
#Bam2depths=$pipeline/bam2depths_shiquan_mgiseq2000.pl

GenderCorrect=$pipeline/tools/XY_gender_correct.pl
GetQC=$pipeline/getQC/get.QC.WESIM.pl
RegionDir=$pipeline/config/coverage_region_hg19_bychr/
Region=$RegionDir/for500_all_region
tag=BGI59M


echo `date` Start depthSurvey
#samtools rmdup $Workdir/bwa/$sampleID.bqsr.bam $Workdir/bwa/$sampleID.rmdup_final.bam
#samtools view -u $Workdir/bwa/$sampleID.bqsr.bam chrX >$Workdir/bwa/chrX.sort.bam
#samtools view -u $Workdir/bwa/$sampleID.bqsr.bam chrY >$Workdir/bwa/chrY.sort.bam

echo `date` bamdst -p $Region --uncover 5 -o $Workdir/coverage $Workdir/bwa/$sampleID.bqsr.bam --cutoffdepth 20
time bamdst -p $Region --uncover 5 -o $Workdir/coverage $Workdir/bwa/$sampleID.bqsr.bam --cutoffdepth 20 \
&& echo success || (echo error && exit 1)

#$Bam2depths --bamdir=$Workdir/bwa --region=$RegionDir --out=$Workdir/coverage --flank=100
#$pipeline/Rscript $Bin/dis.R  $Workdir/coverage/dis_target.plot  $sampleID $workdir/graph_sigleBaseDepth/$sampleID_perBase.png
#$pipeline/Rscript $Bin/cumn.R $Workdir/coverage/cumu_target.plot $sampleID $workdir/graph_sigleBaseDepth/$sampleID_Cumu.png
#$pipeline/perl $UncoverdRegionSjt $RegionDir/all_region  $Workdir/coverage/target.detail $Workdir/coverage
#$pipeline/gzip -f $Workdir/coverage/target.detail
echo `date` perl $GenderCorrect $Workdir/coverage/chromosomes.report $tag
time perl $GenderCorrect $Workdir/coverage/chromosomes.report $tag \
&& echo success || (echo error && exit 1)

echo `date` perl $GetQC $sampleID $Workdir
time perl $GetQC $sampleID $Workdir \
&& echo success || (echo error && exit 1)
mkdir -p $workdir/result/$sampleID && cp -v $Workdir/$sampleID.QC.txt $workdir/result/$sampleID/$sampleID.QC.txt \
&& echo success || (echo error && exit 1)

echo `date` Done
