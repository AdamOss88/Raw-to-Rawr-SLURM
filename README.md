# Raw-to-Rawr-SLURM

This pipeline can be used for processing of pair-end Illumina raw amplicon data on Linux servers. Can be used for 16S and ITS data and potentially other amplicons. This version works on SLURM based systems and is tested on th UMA Picasso server. In other servers you have to make sure all the dependent software in the right version is installed. You can find the list of dependencies at the end of this file.

The pipeline was adapted to SLURM and updated by Belén Delgado Martín. 

The pipeline can be downloaded to the server using command:
```bash
git clone "https://github.com/AdamOss88/Raw-to-Rawr-SLURM.git"
```
*you have to have git installed

It is important to mainatain the dedicated folder structure and file naming convention for the raw data. All the raw data has to be in "/raw_data" folder, named:
XXX_raw_1.fq.gz   AND   XXX_raw_2.fq.gz  where "XXX" is an identifier the same in both paired end reads and unique between samples.

The pipeline also needs the primer sequences to trim them from the reads and they have to be in the file names primers.fasta in fasta format. An example file is provided but remember to change it according to what primers were used otherwise your results will be unrelaiable (but the pipeline will go through).

the example of the primers file:

```
>16S_F
GTGYCAGCMGCCGCGGTAA
>16S_R
GGACTACNVGGGTWTCTAAT
```

For taxonomic classification you need to provide a path to dedicated database for formated for dada2. More info here: https://benjjneb.github.io/dada2/training.html
At this moment you have to provide the path manually in the module2 file. For example in module2-16S.sh:

```
 add databases
#here provide paths to dada2 formated databases
DB=<here provide the path>
speciesDB=<here provide the path>

#exampples:
#DB="/mnt/home/users/<user>/databases/silva_nr99_v138.1_train_set.fa.gz"
#speciesDB="/mnt/home/users/<user>/databases/silva_species_assignment_v138.1.fa.gz"
```

### Running the pipeline
1. Clone the pipeline
2. Copy or link the data to the /raw_data folder
3. Make sure the right primers are in the primers.fasta file
4. Make sure that the right databases are downloaded and the paths are correct 
5. run module 1
```bash
#for 16S
sbatch module1-16S.sh
#for ITS
sbatch module1-ITS.sh
```   
6. check the quality of the data and if youre satisfied continue
7. make sure the path/s to taxonomy reference databases are correct   
8. run module 2
```bash
#for 16S
sbatch module2-16S.sh
#for ITS
sbatch module2-ITS.sh
```  
9. say "rawr!" (only if the results were generated)
10. Download the results

### output
The output of the pipeline is saved in the folder "/results" and includes:
- otu_table.csv 
- tax_table.csv - taxonomy table
- refseq.fasta - ASV sequences in fasta file
all the .csv tables are also saved as .RDS equivalents to be directly loaded to R

The pipeline also generates a series of reports, all in "/reports" folder:
- cutadapt_report.txt - report from trimming primers
- dada2_error_plots.pdf - error model from dada2
-  folder "/quality" with .pdf quality reports from all the reads from fastp

Other output:
- /processing/moduleX.out - command line output to remember what was done and track potential errors
- /processing/Renvironment.RData  - save R environment to get to intermediate states of analysis of you need  

### Dependencies:

seqkit/2.2.0
cutadapt/4.4
fastp/0.23.4
R/4.2.2
dada2/1.26.0
magrittr/2.0.3

R session info :
R version 4.2.2 (2022-10-31)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: SUSE Linux Enterprise Server 15 SP4

Matrix products: default
BLAS:   /mnt/home/soft/erre/programs/R-4.2.2_visual/lib64/R/lib/libRblas.so
LAPACK: /mnt/home/soft/erre/programs/R-4.2.2_visual/lib64/R/lib/libRlapack.so

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] dada2_1.26.0   Rcpp_1.0.12    magrittr_2.0.3

loaded via a namespace (and not attached):
 [1] SummarizedExperiment_1.28.0 tidyselect_1.2.0           
 [3] reshape2_1.4.4              lattice_0.22-5             
 [5] colorspace_2.1-0            vctrs_0.6.5                
 [7] generics_0.1.3              stats4_4.2.2               
 [9] utf8_1.2.4                  rlang_1.1.3                
[11] pillar_1.9.0                glue_1.7.0                 
[13] BiocParallel_1.32.6         BiocGenerics_0.44.0        
[15] RColorBrewer_1.1-3          matrixStats_1.1.0          
[17] jpeg_0.1-10                 GenomeInfoDbData_1.2.9     
[19] lifecycle_1.0.4             plyr_1.8.9                 
[21] stringr_1.5.1               zlibbioc_1.44.0            
[23] MatrixGenerics_1.10.0       Biostrings_2.66.0          
[25] munsell_0.5.0               gtable_0.3.4               
[27] hwriter_1.3.2.1             codetools_0.2-19           
[29] latticeExtra_0.6-30         Biobase_2.58.0             
[31] IRanges_2.32.0              GenomeInfoDb_1.34.9        
[33] parallel_4.2.2              fansi_1.0.6                
[35] scales_1.3.0                DelayedArray_0.24.0        
[37] S4Vectors_0.36.2            RcppParallel_5.1.7         
[39] XVector_0.38.0              ShortRead_1.56.1           
[41] deldir_2.0-2                interp_1.1-4               
[43] Rsamtools_2.14.0            ggplot2_3.4.4              
[45] png_0.1-8                   stringi_1.8.2              
[47] dplyr_1.1.4                 GenomicRanges_1.50.2       
[49] grid_4.2.2                  cli_3.6.2                  
[51] tools_4.2.2                 bitops_1.0-7               
[53] RCurl_1.98-1.13             tibble_3.2.1               
[55] crayon_1.5.2                pkgconfig_2.0.3            
[57] Matrix_1.6-5                R6_2.5.1                   
[59] GenomicAlignments_1.34.1    compiler_4.2.2   
