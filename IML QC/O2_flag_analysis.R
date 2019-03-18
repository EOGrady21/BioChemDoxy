##Investigate flags##


files <- list.files('~/BIOCHEM/IML QC/BCD/', pattern = 'flag_summary', recursive = T)

#sink('O2_flag_summary.txt')
for (i in 1:length(files)){
  #read flag summary file
  d <- read.csv(paste0('~/BIOCHEM/IML QC/BCD/', files[i]), header = F)
  #name data based on flas present in summary
  names(d) <- c('DATA_TYPE_METHOD', d[1,][2:length(d[1,])])
  d <- d[-1,] #remove flag ident row (used as names)
  
  #find oxygen flags
  g <- grep(d$DATA_TYPE_METHOD, pattern = '^O2_')
  
  #print O2 summary report
  # cat(paste('>>', files[i]))
  # cat('   \n')
  # print(d[g,])
  
  for( j in 1:length(g)){
    d[g[j],]
  }
  
  
}
#sink()


