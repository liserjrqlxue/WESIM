# WESIM
WES Integrated machine pipeline


```
# build
git clone https://github.com/lh3/bwa.git github.com/lh3/bwa
cd github.com/lh3/bwa
make
cd ../../pipeline/tools
ln -sf ../../github.com/lh3/bwa/bwa


pipeline/tools/bwa index pipeline/hg19/hg19_chM_male_mask.fa
# [main] Version: 0.7.12-r1039
# [main] CMD: pipeline/tools/bwa index hg19_chM_male_mask.fa
# [main] Real time: 7111.844 sec; CPU: 6921.154 sec

```
