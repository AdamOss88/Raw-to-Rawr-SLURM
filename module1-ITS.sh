#!/bin/bash
#SBATCH -J module1-16S.Raw-to-Rawr
#SBATCH --cpus-per-task=16
#SBATCH --mem=4gb
#SBATCH --time=01:00:00
#SBATCH --constraint=cal
#SBATCH --output=output_module1-ITS.%J.out

###make folders
mkdir -p processed/1.trimmed_primers
mkdir -p processed/2.filtered
mkdir -p reports/quality
mkdir -p temp

###quality check of the rawdata
#fastqc ./raw_data/*.gz -o ./raw_data/quality/
#multiqc -f ./raw_data/quality/ -o ./raw_data/quality/

###trimming
##read primers
module load seqkit/2.2.0

primF=`awk 'NR==2' primers.fasta`
primR=`awk 'NR==4' primers.fasta`
seqkit seq -p -r -t dna primers.fasta > temp/primers_RC.fasta
primFrc=`awk 'NR==2' temp/primers_RC.fasta`
primRrc=`awk 'NR==4' temp/primers_RC.fasta`

##trim primers
cd raw_data/

module load cutadapt/4.4

for F in *_1.fq.gz; do
echo "trimming " $primF " and " $primR " in " $F " and " ${F//_1.fq.gz/_2.fq.gz}
cutadapt -g $primF -G $primR -a $primFrc -A $primRrc -n 2 \
 -o ../processed/1.trimmed_primers/${F//raw_1.fq.gz/trim_1.fq.gz} \
 -p ../processed/1.trimmed_primers/${F//raw_1.fq.gz/trim_2.fq.gz} \
 --minimum-length 30 --cores 0 --report=minimal $F ${F//_1.fq.gz/_2.fq.gz} \
1>> ../reports/cutadapt_report.txt
done
cd ..
rm temp/primers_RC.fasta

## quality filtering with fastp

cd processed/1.trimmed_primers/

module load fastp/0.23.4 multiqc/1.13a

for F in *_1.fq.gz; do
echo "working on " $F " and " ${F//_1.fq.gz/_2.fq.gz}
fastp -i $F -I ${F//_1.fq.gz/_2.fq.gz} \
-o ../2.filtered/${F//trim_1.fq.gz/filt_1.fq.gz} \
-O ../2.filtered/${F//trim_1.fq.gz/filt_2.fq.gz} \
-h ../../reports/quality/${F//_trim_1.fq.gz/}.html -R ${F//_trim_1.fq.gz/} \
-j ../../reports/quality/${F//_trim_1.fq.gz/}.json \
-y -l 30 -r --cut_window_size 4 --cut_mean_quality 23 \
--n_base_limit 0
done
#running multiqc
cd ../../reports/quality/
for i in *.json; do mv $i ${i//.json/.fastp.json}; done
multiqc ./
cd ../..

## optionally you can use the inbuild dada2 quality filtering tool  
## run an R script to filter and trim
#Rscript --vanilla src/filter.R
##
module purge
echo "Check the quality before going further !"
mv output_module* reports/
