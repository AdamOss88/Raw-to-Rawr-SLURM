library(phyloseq)
library(vegan)

#load data
otu_table = readRDS("./results/otu_table.RDS")
tax_table = readRDS("./results/tax_table.RDS")
#sam_data = read.csv2("../sample_data.csv", row.names = 1)
refseq = Biostrings::readDNAStringSet("results/refseq.fasta")

#phyloseq object
amplicons = phyloseq(otu_table(otu_table, taxa_are_rows = F), 
         tax_table(tax_table), 
#        sample_data(sam_data), 
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
TYL$initial = c(length(taxa_names(amplicons)),0)

#filter
##abundance remove singletons 
amplicons_filt = prune_taxa(taxa_sums(amplicons) > 2, amplicons)
TYL$singletons= c(length(taxa_names(amplicons_filt)),TYL$initial[1] - length(taxa_names(amplicons_filt)))
##no affiliation
amplicons_filt = subset_taxa(amplicons_filt, Kingdom != "NA" )
TYL$unaffiliated= c(length(taxa_names(amplicons_filt)),TYL$singletons[1] - length(taxa_names(amplicons_filt))) 
##contaminants
###Mitochondia
amplicons_filt = prune_taxa(
  !taxa_names(amplicons_filt) %in% taxa_names(amplicons_filt)[apply(tax_table(amplicons_filt), 1, function(row) any(grepl("Mitochondria", row)))],
  amplicons_filt)
TYL$mitochondria= c(length(taxa_names(amplicons_filt)),TYL$unaffiliated[1]-length(taxa_names(amplicons_filt)))
###Chloroplasts
amplicons_filt = prune_taxa(
  !taxa_names(amplicons_filt) %in% taxa_names(amplicons_filt)[apply(tax_table(amplicons_filt), 1, function(row) any(grepl("Chloroplast", row)))],
  amplicons_filt)
TYL$chloroplasts= c(length(taxa_names(amplicons_filt)),TYL$mitochondria[1] -length(taxa_names(amplicons_filt)))
#rarefy
set.seed(456)

pdf("reports/rarecurve.pdf")
rare_curve = vegan::rarecurve(as.matrix(as.data.frame(phyloseq::otu_table(amplicons_filt))), step = 100 , cex=0.5)
dev.off()

amplicons_rare = phyloseq::rarefy_even_depth(amplicons_filt, rngseed=456, sample.size=min(sample_sums(amplicons_filt)), replace=F)
TYL$rarefication= c(length(taxa_names(amplicons_rare)),TYL$chloroplasts[1] - length(taxa_names(amplicons_rare)))
TYL$final= c(length(taxa_names(amplicons_rare)),0)
write.csv(TYL, file = "results/filtering_amplicons.csv")

saveRDS(amplicons_rare, file= "./results/amplicons_filter_rare.rds")
