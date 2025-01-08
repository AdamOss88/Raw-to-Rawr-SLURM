##needs to be adopted

library(phyloseq)
library(Biostrings)
library(vegan)

#load data
otu_table16S = readRDS("./otu_table16S.RDS")
tax_table16S = readRDS("./tax_table16S.RDS")
sam_data = read.csv2("../sample_data.csv", row.names = 1)
refseq = readDNAStringSet("refseq16S.fasta")

#phyloseq object
bacteria = phyloseq(otu_table(otu_table16S, taxa_are_rows = F), 
         tax_table(tax_table16S), 
         sample_data(sam_data), 
         refseq(refseq))

#Taxa You Lost
TYL = data.frame(initial = rep(NA,2),
                  singletons = rep(NA,2),
                  unaffiliated = rep(NA,2),
                  mitochondria = rep(NA,2),
                  chloroplasts = rep(NA,2),
                  rarefication = rep(NA,2),
                  final = rep(NA,2))
row.names(TYL) = c("number of taxa","removed")
TYL$initial = c(length(taxa_names(bacteria)),0)
#filter
##abundance remove singletons 
table(taxa_sums(bacteria) > 2)
bacteria_filt = prune_taxa(taxa_sums(bacteria) > 2, bacteria)
TYL$singletons= c(length(taxa_names(bacteria_filt)),TYL$initial[1] - length(taxa_names(bacteria_filt)))
##no affiliation
bacteria_filt = subset_taxa(bacteria_filt, Kingdom != "NA" )
TYL$unaffiliated= c(length(taxa_names(bacteria_filt)),TYL$singletons[1] - length(taxa_names(bacteria_filt))) 
##contaminants
###Mitochondia
bacteria_filt = prune_taxa(
  !taxa_names(bacteria_filt) %in% taxa_names(bacteria_filt)[apply(tax_table(bacteria_filt), 1, function(row) any(grepl("Mitochondria", row)))],
bacteria_filt)
TYL$mitochondria= c(length(taxa_names(bacteria_filt)),TYL$unaffiliated[1]-length(taxa_names(bacteria_filt)))
###Chloroplasts
bacteria_filt = prune_taxa(
  !taxa_names(bacteria_filt) %in% taxa_names(bacteria_filt)[apply(tax_table(bacteria_filt), 1, function(row) any(grepl("Chloroplast", row)))],
  bacteria_filt)
TYL$chloroplasts= c(length(taxa_names(bacteria_filt)),TYL$mitochondria[1] -length(taxa_names(bacteria_filt)))
#rarefy
set.seed(456)

pdf("rarecurve_16S.pdf")
rare_curve = vegan::rarecurve(as.matrix(as.data.frame(phyloseq::otu_table(bacteria_filt))), step = 100 , cex=0.5)
dev.off()

bacteria_rare = phyloseq::rarefy_even_depth(bacteria_filt, rngseed=456, sample.size=min(sample_sums(bacteria_filt)), replace=F)
TYL$rarefication= c(length(taxa_names(bacteria_rare)),TYL$chloroplasts[1] - length(taxa_names(bacteria_rare)))
TYL$final= c(length(taxa_names(bacteria_rare)),0)
write.csv(TYL, file = "results/filtering_bacteria.csv")

saveRDS(bacteria_rare, file= "objects/Plastic_16S_filter_rare.rds")
