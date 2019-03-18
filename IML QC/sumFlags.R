##sum all flags

files <- list.files('~/BIOCHEM/IML QC/BCD/', pattern = '_flag_summary', recursive = T)

x <- matrix(nrow = length(unique(data$DATA_TYPE_METHOD)), ncol = 8)
st <- as.data.frame(t(x) )
names(st) <- as.character(unique(data$DATA_TYPE_METHOD))
for (i in 1:length(files)){
  tt <- read.csv(paste0(getwd(),'/BCD/', files[i]), header = F)
  flagindex <- as.numeric(tt[1,2:length(tt[1,])]) +1
  for (f in flagindex){
    for (j in 1:length(tt[,1])){
      g <- grep(names(st), pattern = paste0('^', as.character(tt[j,1]), '$'))
      st[f, g] <- tt[j,f]
    }
  }
  
}
