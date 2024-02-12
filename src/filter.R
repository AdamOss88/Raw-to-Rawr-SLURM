library(dada2)
#get sample names
sample_names = gsub("_raw_1.fq.gz","",list.files("./raw_data", pattern="_1.fq.gz"))

#paths to trimmed reads
path_trim = "./processed/1.trimmed_primers/"
trimF <- sort(list.files(path_trim, pattern="1.fq.gz", full.names = TRUE, recursive = F))
trimR <- sort(list.files(path_trim, pattern="2.fq.gz", full.names = TRUE, recursive = F))

#paths to filtering output
filtF <- file.path("./processed/2.filtered", paste0(sample_names, "_filt_1.fq.gz"))
filtR <- file.path("./processed/2.filtered", paste0(sample_names, "_filt_2.fq.gz"))

filtered_report <- dada2::filterAndTrim(fwd = trimF, filt = filtF,
                                        rev = trimR, filt.rev = filtR,
                                        minLen = 30,
                                        rm.phix = T,
                                        maxN=0,
                                        truncQ=2,
                                        maxEE=c(2,3),
                                        compress=T,
                                        multithread=T,
                                        verbose=T)
filtered_report = cbind(filtered_report,round(100-(filtered_report[,2] / filtered_report[,1] * 100),2))
colnames(filtered_report)[3] = "%rejected"

print(filtered_report)
#export filtered report
write.csv(filtered_report, file="./reports/dada2_filtered_report.txt")
print("Filtering report saved !")
