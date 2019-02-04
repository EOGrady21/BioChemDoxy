library(readxl)


d <- read_xls('C:/Users/ChisholmE/Documents/BIOCHEM/DATA/pre2013/HUD2008009/hudson_2008009_bottle_oxygen_08Dec2008.xls' )


dd <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/DATA/pre2013/HUD2008009/HUD2008009_QAT.csv')


#oxy <-d
oxy <- d[9:725,]
names(oxy) <- d[8,]
x <- matrix(NA, nrow = 717, ncol = 3 )
meta <- as.data.frame(x )

for(i in 1:717){
  g <- grep(dd$Sample.id, pattern = oxy$ID[i])
  if (length(g) != 0){
  meta$V1[i] <- dd$Latitude[g]
  meta$V2[i] <- dd$Longitude[g]
  meta$V3[i] <- dd$Pressure[g]
  }
}

noxy <- as.data.frame(c(meta, oxy))


write.csv(noxy, file = 'HUD2008009_oxyupd.csv')
