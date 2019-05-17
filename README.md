# WESIM
WES Integrated machine pipeline


```
# build
export PATH=pipeline/tools:PATH

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
cd pipeline/tools
ln -sf /ifs7/B2C_SGD/PROJECT/PP12_Project/analysis_pipeline/HPC_chip/db/aln_db/hg19/dbsnp_138.hg19.vcf
ln -sf /ifs7/B2C_SGD/PROJECT/PP12_Project/analysis_pipeline/HPC_chip/db/aln_db/hg19/dbsnp_138.hg19.vcf.idx
cd ../..

for file in dbsnp_138.hg19.excluding_sites_after_129.vcf Mills_and_1000G_gold_standard.indels.hg19.sites.vcf;do
  wget -m ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg19/$file.gz
  wget -m ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg19/$file.idx.gz
  gzip -d ftp.broadinstitute.org/bundle/hg19/$file.gz
  gzip -d ftp.broadinstitute.org/bundle/hg19/$file.idx.gz
  cd pipeline/hg19
  ln -sf ../../ftp.broadinstitute.org/bundle/hg19/$file
  ln -sf ../../ftp.broadinstitute.org/bundle/hg19/$file.idx
  cd ../..
done

```
