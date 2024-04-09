#libs
library("dada2")
library("magrittr")

#functions
source("./src/novaseq.R")

#get sample names
sample_names = gsub("_raw_1.fq.gz","",list.files("./raw_data", pattern="_1.fq.gz"))

#################filtering; provide path to trimmed reads - path trim

#paths to filtered reads
filtF <- sort(list.files("./processed/2.filtered/", pattern="1.fq.gz", full.names = TRUE)) 
filtR <- sort(list.files("./processed/2.filtered/", pattern="2.fq.gz", full.names = TRUE))

################# learning error rates for novaseq sequencing
##make sure "magrittr" is loaded
set.seed(35) # makes the error learning consistent

errF <- dada2::learnErrors(filtF,
                    nbases = 1e8,
                    errorEstimationFunction = loessErrfun_mod4,# skip for NOT novaseq
                    randomize = T,
                    MAX_CONSIST = 12,
                    multithread =8,
                    verbose = T)

errR <- dada2::learnErrors(filtR,
                    nbases = 1e8,
                    errorEstimationFunction = loessErrfun_mod4, # skip for NOT novaseq
                    randomize = T,
                    MAX_CONSIST = 12,
                    multithread =8,
                    verbose = T)

####saving error graphs
pdf(file = "./reports/dada2_error_plots.pdf")
plotErrors(errF)
plotErrors(errR)
dev.off()
####


##checkpoint
save.image(file = "./processed/Renvironment.RData")
##

################# dereplication
derepF = dada2::derepFastq(filtF, verbose=T)
names(derepF) = sample_names
derepR = dada2::derepFastq(filtR, verbose=T)
names(derepR) = sample_names


################# sample interference
dadaF = dada2::dada(derepF, err=errF, multithread=T, pool=F) # pool sensitivity vs. time
dadaR = dada2::dada(derepR, err=errR, multithread=T, pool=F)

################# merging reads
mergers = dada2::mergePairs(dadaF, derepF, dadaR, derepR, minOverlap = 12, verbose=T)

################# Construct ASV table
seqtab = dada2::makeSequenceTable(mergers)

################# Chimeras removal
otu_table = dada2::removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)

################# Taxonomy asssignment 
tax_table = dada2::assignTaxonomy(otu_table, $DB , multithread=TRUE, verbose=T)

##checkpoint
save.image(file = "./processed/Renvironment.RData")

#species assignemnt - generally optional
tax_table = dada2::addSpecies(tax_table, $speciesDB , verbose=T)

##checkpoint
save.image(file = "./processed/Renvironment.RData")

################ Creating sequence reference file and saving it
refseq = NULL
for (i in 1:length(colnames(otu_table))) {refseq = c(refseq,paste0(">ASV",i),colnames(otu_table)[i])}
writeLines(refseq,"./results/refseq.fasta")

################ changing sequences in ASV names to ASV[number]
colnames(otu_table) = paste0(rep("ASV",length(colnames(otu_table))), 1:length(colnames(otu_table)))
row.names(tax_table) = colnames(otu_table) 

################# Save the otu table and taxonomy table
saveRDS(otu_table, file="./results/otu_table.RDS")
write.csv(otu_table, file="./results/otu_table.csv", row.names=T)

saveRDS(tax_table, file="./results/tax_table.RDS")
write.csv(tax_table, file="./results/tax_table.csv", row.names=T)

##checkpoint
save.image(file = "./processed/Renvironment.RData")

