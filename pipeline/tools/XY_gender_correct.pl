#!/usr/bin/perl -w
use strict;
use File::Basename;
my $chromosomes_report=shift;
my $bed=shift;
my $rate=0;
my %chromosomes_report=();
#==============filter rate===========================
my $filter=0;
my $gender="_";
if($bed=~/BGI59M/){$filter=10;}
#elsif($bed=~/Nim/ or $bed=~/Agi/){$filter=22;}
#elsif($bed=~/heart143/){$filter=36.5;}
####elsif($bed=~/222/ or $bed=~/BGI59M/){$filter=34;}
#elsif($bed=~/mit1098|ger189/){$filter=20;}
#elsif($bed=~/2181/){$filter=20;}
elsif($bed=~/tumor115/){$filter=0;}
elsif($bed=~/tumor171/){$filter=0;}
#elsif($bed=~/4k/){$filter=30;}
#elsif($bed=~/BGI4\.8M/){$filter=23;}
elsif($bed=~/deaf301/){$filter=0;}
elsif($bed=~/PP600|PP100/){$filter=0;}
elsif($bed=~/top100/){$filter=0;}
elsif($bed=~/Hypophrenia/i){$filter=0;}
elsif($bed=~/newborn/i){$filter=0;}
elsif($bed=~/all/i){$filter=0;}
my $cov_dir=dirname ($chromosomes_report);
my $sample=basename(dirname $cov_dir);
my $sample_dir=dirname($cov_dir);
#=====================================================
open IN_CROM, "<$chromosomes_report" or die "cannot open $chromosomes_report:$!\n";
while (<IN_CROM>) {
    my @column=(split /\t/,$_);
    next if $column[0]=~/#/;
    $column[0]=~s/^\s+|\s+$//g;
    $column[2]=~s/^\s+|\s+$//g;
    $chromosomes_report{$column[0]}=$column[2];
}
if (exists $chromosomes_report{chrY} and exists $chromosomes_report{chrX} ) {
    print "in chrX.mean.depth/chrY.mean.depth mode\n";
    $rate=$chromosomes_report{chrX}/$chromosomes_report{chrY};
    open GD,">$cov_dir/gender.txt"or die;
    if ($filter!=0) {
        if($rate <= $filter){$gender="Male";}
        else{$gender="Female";}
        print GD "chrX.mean.depth $chromosomes_report{chrX}, chrY.mean.depth $chromosomes_report{chrY}, rate $rate, gender $gender\t$sample\n";
	print "$cov_dir/gender.txt\nrate $rate, gender $gender\t$sample\n";
    }else{
        #print GD "chrX.mean.depth $chromosomes_report{chrX}, chrY.mean.depth $chromosomes_report{chrY}, rate $rate\n";
    }
}
#========================get Q30============================
my @stat;
@stat = glob "$sample_dir/filter/*/*.filter.stat";
my $fq_n = 0;
my $q30  = 0;
for my $stat (@stat) {
  open IN, "< $stat" or die $!;
  while (<IN>) {
    chomp;
    my @ln = split /\t/, $_;
    $ln[0] =~ /^Q30\(%\) of fq[12]:$/ or next;
    $fq_n++;
    $q30 += $ln[2];
  }
}
if ($fq_n > 0 and $fq_n % 2 == 0) {
  $q30 /= $fq_n;
} else {
  print STDERR "can not find filter.stat:[@stat]\n\tskip Q30 check\n";
  $q30 = -1;
}
#==================get cov and dep========
open IN_QC, "<$cov_dir/coverage.report" or die "cannot open list:$!\n";
my %qc;
my $Depth;
my $Coverage;
while (<IN_QC>){
	chomp;
	/^#/ and next;
	my ($key, $value) = split /\t/, $_;
	$key =~ s/^\s+//g;
	$value =~ s/\s+//g;
	$value = (split /\%/, $value)[0];
	$qc{$key}= $value;
}
if (exists $qc{"[Target] Average depth(rmdup)"} and exists $qc{"[Target] Coverage (>=20x)"}){
	$Depth    = $qc{"[Target] Average depth(rmdup)"};
	$Coverage = $qc{"[Target] Coverage (>=20x)"};
	
}else{
	$Depth=-1;
	$Coverage=-1;		
}
print "Depth is $Depth\tCoverage is $Coverage\n";
#============qc check==============
my $QCcheck;
if($q30>0 and $Depth>0 and $Coverage>0){
	if($q30 >= 85 and $Depth>=100 and $Coverage>=95){$QCcheck="qualified";}
	else{$QCcheck="unqualified";}
}else{$QCcheck="";}

open OUT_QC, ">$sample_dir/coverage/QC_check.txt" or die "cannot open list:$!\n";
print OUT_QC "$QCcheck\n";
