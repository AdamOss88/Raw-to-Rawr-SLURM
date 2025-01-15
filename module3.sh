#!/bin/bash
#SBATCH -J module3.sh
#SBATCH --cpus-per-task=64
#SBATCH --mem=100gb
#SBATCH --time=10:00:00
#SBATCH --constraint=cal
#SBATCH --output=output_module3.%J.out

echo "start "
echo "$(date +'%d/%m/%Y %H:%M')"

module purge
module load mafft iqtree R
#performing standard filtering and rarefaction
Rscript --vanilla src/module3.R
#alignment
mafft --thread 64 ./results/refseq_filter_rare.fasta > ./results/refseq_filter_rare.ali 
#tree
iqtree2 -s ./results/refseq_filter_rare.ali -m GTR+I+G -T AUTO
#making some order
mkdir -p ./results/phylogeny
mv ./results/refseq_filter_rare.ali* ./results/phylogeny

#finish
echo "end "
echo "$(date +'%d/%m/%Y %H:%M')"

mv output_module3* reports/
