#!/bin/bash

{
###make folders
mkdir -p ./results/

###run dada2 script
Rscript --vanilla src/dada2.R
} 2>&1 | tee ./processed/module2.out


#echo "otu table and taxonomy table were generated !"
