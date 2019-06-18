# WESIM
WES Integrated machine pipeline


```
# build
export PATH=pipeline/tools:PATH

# samtools
git clone https://github.com/samtools/htslib.git github.com/samtools/htslib
git clone https://github.com/samtools/samtools.git github.com/samtools/samtools
wget -m https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
cd github.com/samtools/samtools
make -j 6
cd ../../..

cd pipeline/tools
ln -sf ../../github.com/samtools/samtools/samtools
cd ../..


## ref
git clone https://github.com/lh3/bwa.git github.com/lh3/bwa
cd github.com/lh3/bwa
make
cd ../../..

cd pipeline/tools
ln -sf ../../github.com/lh3/bwa/bwa
cd ../..

bwa index pipeline/hg19/hg19_chM_male_mask.fa
# [main] Version: 0.7.17-r1198-dirty
# [main] CMD: bwa index hg19_chM_male_mask.fa
# [main] Real time: 7111.844 sec; CPU: 6921.154 sec

samtools faidx pipeline/hg19/hg19_chM_male_mask.fa

## java 8
wget -m https://download.java.net/openjdk/jdk8u40/ri/openjdk-8u40-b25-linux-x64-10_feb_2015.tar.gz
cd download.java.net/openjdk/jdk8u40/ri
tar avxf openjdk-8u40-b25-linux-x64-10_feb_2015.tar.gz
cd ../../../..

cd pipeline/tools
ln -sf ../../download.java.net/openjdk/jdk8u40/ri/java-se-8u40-ri/bin/java
cd ../..



## gatk
wget -m https://github.com/broadinstitute/gatk/releases/download/4.1.2.0/gatk-4.1.2.0.zip
cd github.com/broadinstitute/gatk/releases/download/4.1.2.0
unzip gatk-4.1.2.0.zip
cd ../../../../../..

cd pipeline/tools
ln -sf ../../github.com/broadinstitute/gatk/releases/download/4.1.2.0/gatk-4.1.2.0/gatk
cd ../..


## SOAPnuke
git clone https://github.com/BGI-flexlab/SOAPnuke.git github.com/BGI-flexlab/SOAPnuke
cd github.com/BGI-flexlab/SOAPnuke
make
g++ ./obj/gc.o ./obj/global_variable.o ./obj/Main.o ./obj/peprocess.o ./obj/process_argv.o ./obj/read_filter.o ./obj/seprocess.o ./obj/sequence.o -o SOAPnuke -lz -lpthread -I/home/wangyaoshen/local/include -L/home/wangyaoshen/local/lib
cd ../../..

cd pipeline/tools
ln -sf ../../github.com/BGI-flexlab/SOAPnuke/
cd ../..


## db

for file in dbsnp_138.hg19.vcf Mills_and_1000G_gold_standard.indels.hg19.sites.vcf;do
  wget -m ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg19/$file.gz
  wget -m ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg19/$file.idx.gz
  gzip -dc ftp.broadinstitute.org/bundle/hg19/$file.gz > ftp.broadinstitute.org/bundle/hg19/$file
  gzip -dc ftp.broadinstitute.org/bundle/hg19/$file.idx.gz > ftp.broadinstitute.org/bundle/hg19/$file.idx
  cd pipeline/hg19
  ln -sf ../../ftp.broadinstitute.org/bundle/hg19/$file
  ln -sf ../../ftp.broadinstitute.org/bundle/hg19/$file.idx
  cd ../..
done

## script
git clone ssh://git@192.168.136.114:29418/YCB/CNV_anno.git pipeline/CNV_anno

git clone ssh://git@192.168.136.114:29418/liser.jrqlxue/ExomeDepth.git pipeline/ExomeDepth
cd pipeline/ExomeDepth
Rscript init.R ../hg19/hg19_chM_male_mask.fa
cd ../..
```
