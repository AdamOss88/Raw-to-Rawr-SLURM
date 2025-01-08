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
#alignment
mafft --thread 64 results/refseq.fasta > results/refseq.ali 
#tree
iqtree2 -s results/refseq.ali -T AUTO

#performing standard filtering and rarefaction
Rscript --vanilla src/module3.R

echo "end "
echo "$(date +'%d/%m/%Y %H:%M')"

mv output_module3* reports/
