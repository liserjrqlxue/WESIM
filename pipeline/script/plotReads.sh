#!/usr/bin/env bash
set -euo pipefail

workdir=$1
pipeline=$2
sampleID=$3

complete=$workdir/$sampleID/shell/plotReads.sh.complete
if [ -e "$complete" ];then
	echo "$complete and skip"
	exit 0
fi

Workdir=$workdir/result/$sampleID
export PATH=$pipeline/tools:$PATH
export PERL5LIB=$pipeline/perl5/lib64/perl5:$PERL5LIB

ref=$pipeline/hg19/hg19_chM_male_mask.fa
bam=$workdir/$sampleID/bwa/$sampleID.bqsr.bam
lst=$workdir/$sampleID/$sampleID.Tier1.xlsx.filter_variants.txt
outDir=$Workdir/reads_graph

mkdir -p $outDir

awk 'NR>1{print $2,$3,$4}' $lst|sort -V|uniq |gargs -p 8 -l $outDir/log -v "perl $pipeline/reads_graph/reads_graph.pl -b $bam -c {0} -p {1}to{2} -prefix $outDir/$sampleID -t $pipeline/tools/samtools -refdir $ref -r $ref -f 20 -d -a -l 100"

tail -n1 $outDir/log|grep -w SUCCESS

echo `date` Done

touch $complete
