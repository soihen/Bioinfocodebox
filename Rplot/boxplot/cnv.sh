#! /usr/bin/bash

#bed='/public/test_data/CNV_enhance/cnvkat/data/bed/CFanno.bed'
#pon='/public/test_data/CNV_enhance/cnvkat/data/database/CF.flat.cnn'
#empty='/data/ngs/database/soft_database/cnvkit_resources/references/empty.cnn'
#threads=8
#
#sampleid=$1
#data_path=$2
#result_path=$3
#
#python3 /data/ngs/softs/cnvkit/cnvkit.py coverage ${data_path}/${sampleid}.sorted.dedup.bam ${bed} -p ${threads} -o ${result_path}/${sampleid}.targetcoverage.cnn
#python3 /data/ngs/softs/cnvkit/cnvkit.py fix ${sampleid}.targetcoverage.cnn ${empty} ${pon} -o ${sampleid}.cnr


bed='/public/test_data/CNV_enhance/HRDana/data/bed/hrdanno.bed'
pon='/public/test_data/CNV_enhance/HRDana/data/database/hrd.flat.cnn'
empty='/data/ngs/database/soft_database/cnvkit_resources/references/empty.cnn'
threads=8

#bam dir
data_path=$1
#normal dir&tumor dir
result_path=$2

bash /public/test_data/CNV_enhance/cnvkat/script/qc.sh ${data_path} ${result_path}/qc ${bed}

for i in ${data_path}/*.bam;do
  sampleid=`basename $i .sorted.dedup.bam`
  python3 /data/ngs/softs/cnvkit/cnvkit.py coverage ${data_path}/${sampleid}.sorted.dedup.bam ${bed} -p ${threads} -o ${result_path}/cnn/${sampleid}.targetcoverage.cnn
  python3 /data/ngs/softs/cnvkit/cnvkit.py fix ${result_path}/cnn/${sampleid}.targetcoverage.cnn ${empty} ${pon} -o ${result_path}/cnr/${sampleid}.cnr
done
