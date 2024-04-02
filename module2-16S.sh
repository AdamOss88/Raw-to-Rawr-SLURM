#!/bin/bash
#SBATCH -J module2.sh
#SBATCH --cpus-per-task=16
#SBATCH --mem=180gb
#SBATCH --time=10:00:00
#SBATCH --constraint=cal
#SBATCH --error=processed/module2.%J.err
#SBATCH --output=processed/module2.%J.out

#load software
module load dada2/1.26.0

# add databases
DB=~/belendm/databases/dada2/silva_nr99_v138.1_train_set.fa.gz
speciesDB=~/belendm/databases/dada2/silva_species_assignment_v138.1.fa.gz

###make folders
mkdir -p ./results/

###run dada2 script
Rscript --vanilla src/dada2.R $DB $speciesDB


#echo "otu table and taxonomy table were generated !"
