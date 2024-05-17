#!/bin/bash
#SBATCH -J module2.sh
#SBATCH --cpus-per-task=128
#SBATCH --mem=1000gb
#SBATCH --time=10:00:00
#SBATCH --constraint=cal
#SBATCH --output=output_module2-16.%J.out

echo "start "
echo $(date +%H:%M:%S)

# add databases
#here provide paths to dada2 formated databases
DB=<here provide the path>
speciesDB=<here provide the path>

#exampples:
#DB="/mnt/home/users/<user>/databases/silva_nr99_v138.1_train_set.fa.gz"
#speciesDB="/mnt/home/users/<user>/databases/silva_species_assignment_v138.1.fa.gz"

###make folders
mkdir -p ./results/

###run dada2 script
module load dada2/1.26.0

Rscript --vanilla src/dada2.R $DB $speciesDB

echo "check if the otu table and taxonomy tables were generated !"
echo "end "
mv output_module2* reports/
echo $(date +%H:%M:%S)
