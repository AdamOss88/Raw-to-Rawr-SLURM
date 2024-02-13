# Raw-to-Rawr-server

This pipeline can be used for processing of pair-end Illumina raw amplicon data on Linux servers. Can be used for 16S and ITS data and potentially other amplicons.

The pipeline can be downloaded to the server using command:
```bash
git clone "https://github.com/AdamOss88/Raw-to-Rawr-server.git"
```
*you have to have git installed

The user has to install and activate the conda envronment specified in AmpliconENV.yml file. 
```bash
conda env create -f AmpliconENV.yml
conda activate AmpliconENV
```

It is important to mainatain the dedicated folder structure and file naming convention for the raw data. All the raw data has to be in "/raw_data" folder, named:
XXX_raw_1.fq.gz   AND   XXX_raw_2.fq.gz  where "XXX" is an identifier the same in both paired end reads and unique between samples.

The pipeline also needs the primer sequences to trim them from the reads and they have to be in the file names primers.fasta in fasta format. An example file is provided but remember to change it according to what primers were used otherwise your results will be unrelaiable (but the pipeline will go through). 

### Running the pipeline
1. Clone the pipeline
2. Copy or link the data to the /raw_data folder
3. Make sure the right primers are in the primers.fasta file
4. Activate the conda environment
5. run module 1
```bash
#for 16S
./module1-16S.sh
#for ITS
./module1-ITS.sh
```   
6. check the quality of the data and if youre satisfied continue
7. run module 2
```bash
#for 16S
./module2-16S.sh
#for ITS
./module2-ITS.sh
```  
8. say "rawr!" (only if the results were generated)
9. Download the results

###output
The output of the pipeline is saved in the folder "/results" and includes:
- otu_table.csv 
- tax_table.csv - taxonomy table
- refseq.fasta - ASV sequences in fasta file
all the .csv tables are also saved as .RDS equivalents to be directly loaded to R

The pipeline also generates a series of reports, all in "/reports" folder:
- cutadapt_report.txt - report from trimming primers
- dada2_error_plots.pdf - error model from dada2
-  folder "/quality" with .pdf quality reports from all the reads from fastp
  





