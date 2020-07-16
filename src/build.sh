#!/bin./bash 

# getQC
git clone ssh://git@gitlab.genomics.cn:2200/wangyaoshen/getqc.git getQC

# bwa
wget -m https://github.com/lh3/bwa/releases/download/v0.7.17/bwa-0.7.17.tar.bz2
tar avxf bwa-0.7.17.tar.bz2 
cd bwa-0.7.17
make #-j 6
cd ..

# java 1.8
wget https://download.java.net/openjdk/jdk8u41/ri/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz
tar avxf openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz 

# gatk
wget https://github.com/broadinstitute/gatk/releases/download/4.1.8.0/gatk-4.1.8.0.zip
unzip gatk-4.1.8.0.zip 

# samtools
wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
tar avxf samtools-1.10.tar.bz2 
cd samtools-1.10
make #-j 6
cd ..

# SOAPnuke
wget https://github.com/BGI-flexlab/SOAPnuke/archive/SOAPnuke2.1.0.tar.gz
tar avxf SOAPnuke2.1.0.tar.gz 
cd SOAPnuke-SOAPnuke2.1.0
make #-j 6
cd ..
